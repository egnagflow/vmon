;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"
.include "key_handler.h"
.include "screen.h"
.include "io.h"
.include "macros.h"

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

add_key_handler KEY_SINGLE_STEP_OVER, handle_key_single_step_over
add_key_handler KEY_SINGLE_STEP_INTO, handle_key_single_step_into

.if CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS
add_key_handler KEY_CONT_STEP_INTO_UNTIL_RTS, handle_key_cont_step_into_until_rts
.endif

.if CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS
add_key_handler KEY_CONT_STEP_OVER_UNTIL_RTS, handle_key_cont_step_over_until_rts
.endif

.if CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR
add_key_handler KEY_CONT_STEP_OVER_UNTIL_ADDR, handle_key_cont_step_into_until_addr
.endif

;-----------------------------------------------------------------------------
.segment "CODE"

;-----------------------------------------------------------------------------
; Single step over / into
;-----------------------------------------------------------------------------
handle_key_single_step_over:
        lda #$20    ; Will be used in exec_cur_code_line.
        .byte $2c   ; BIT abs
handle_key_single_step_into:
        lda #$4c    ; Will be used in exec_cur_code_line.
        sta tmp_var_lo
        jmp exec_cur_code_line

;-----------------------------------------------------------------------------
; INSPECT while single-stepping until RTS
;-----------------------------------------------------------------------------
.segment "DATA"
handle_key_cont_step_sp_save:   .res 1

.segment "CODE"

.if CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS
handle_key_cont_step_into_until_rts:
        ldy virt_reg_sp
        sty handle_key_cont_step_sp_save

handle_key_i_update:
        jsr handle_key_single_step_into
        jsr screen_draw

        jsr check_pause_abort_execution

        jsr lda_pc_y0
        cmp #$60            ; Did we reach a RTS?
        bne handle_key_i_update
        ldy handle_key_cont_step_sp_save
        cpy virt_reg_sp     ; Are we in the stack frame we started from?
        bne handle_key_i_update
        rts
.endif ; CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS

;-----------------------------------------------------------------------------
; CONTINUE single-stepping until RTS
;-----------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS
handle_key_cont_step_over_until_rts:
        jsr handle_key_single_step_over
        jsr screen_draw

        jsr check_pause_abort_execution

        jsr lda_pc_y0
        cmp #$60 ; RTS
        bne handle_key_cont_step_over_until_rts
        rts
.endif ; CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS

;-----------------------------------------------------------------------------
; Step into until given address
;-----------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR
.pushseg
.segment "DATA"
until_addr:     .res 2
.popseg

handle_key_cont_step_into_until_addr:
        screen_cursor_pos_set 0,1
        lda #KEY_CONT_STEP_OVER_UNTIL_ADDR
        jsr chrout
        jsr read_hex16
        bcs @abort  ; Abort
        vec_set_ay until_addr

@next_line:
        jsr handle_key_single_step_over
        jsr screen_draw

        jsr check_pause_abort_execution

        vec_cmp pc_lo, until_addr
        bne @next_line
@abort:
        rts
.endif ; CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR

;-----------------------------------------------------------------------------
check_pause_abort_execution:
        io_key_in_poll
        beq @exit       ; No key pressed
.if CONFIG_KEY_HANDLER_SCREEN_SHOW
        cmp #KEY_SHOW_SCREEN
        bne @no_show_screen
        jmp handle_key_show_screen
.endif ; CONFIG_KEY_HANDLER_SCREEN_SHOW
@no_show_screen:
        cmp #KEY_PAUSE_ABORT
        bne @abort
        io_key_in_blocking
        rts
@abort:
        pla
        pla
@exit:
        rts

