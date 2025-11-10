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
.include "init_vars.h"
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

.if CONFIG_KEY_HANDLER_RESUME_LAST_RUN_MODE
add_key_handler KEY_RESME_LAST_RUN_MODE, handle_key_resume_last_run_mode
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
        sta gs_key_handler_exec
        jmp exec_cur_code_line

;-----------------------------------------------------------------------------
; Context data for the various run modes
;-----------------------------------------------------------------------------
.segment "DATA"
.if CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS || CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR
sp_save:
until_addr:
        .res 1
.endif
.if CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR
        .res 1 ; High byte of until_addr.
.endif

.if CONFIG_KEY_HANDLER_RESUME_LAST_RUN_MODE
.define RUN_MODE_STEP_INTO_UNTIL_RTS    $00   ; BEQ
.define RUN_MODE_STEP_OVER_UNTIL_RTS    $80   ; BMI
.define RUN_MODE_STEP_INTO_UNTIL_ADDR   $01   ; LSR, BCS
.define RUN_MODE_NONE                   $02
decl_init_var run_mode, RUN_MODE_NONE
.endif

.segment "CODE"

;-----------------------------------------------------------------------------
; Execute 'step into' until we hit a RTS instruction at the _current_ stack
; frame. 
;-----------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS
handle_key_cont_step_into_until_rts:
        ldy virt_reg_sp
        sty sp_save

.if CONFIG_KEY_HANDLER_RESUME_LAST_RUN_MODE
        lda #RUN_MODE_STEP_INTO_UNTIL_RTS
        sta run_mode
.endif

handle_key_cont_step_into_until_rts_continue:
handle_key_i_update:
        jsr handle_key_single_step_into
        jsr screen_draw

        jsr check_abort_execution

        jsr lda_pc_y0
        cmp #$60            ; Did we reach a RTS?
        bne handle_key_i_update
        ldy sp_save
        cpy virt_reg_sp     ; Are we in the stack frame we started from?
        bne handle_key_i_update
        rts
.endif ; CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS

;-----------------------------------------------------------------------------
; Execute 'step over' until we hit a RTS instruction at the _current_ stack
; frame. 
;-----------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS
handle_key_cont_step_over_until_rts:
.if CONFIG_KEY_HANDLER_RESUME_LAST_RUN_MODE
        lda #RUN_MODE_STEP_OVER_UNTIL_RTS
        sta run_mode
.endif

handle_key_cont_step_over_until_rts_continue:
        jsr handle_key_single_step_over
        jsr screen_draw

        jsr check_abort_execution

        jsr lda_pc_y0
        cmp #$60 ; RTS
        bne handle_key_cont_step_over_until_rts
        rts
.endif ; CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS

;-----------------------------------------------------------------------------
; Execute 'step over' until we hit the specified address.
;-----------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR
handle_key_cont_step_into_until_addr:
        lda #KEY_CONT_STEP_OVER_UNTIL_ADDR
        jsr key_handler_read_hex16
        bcs handle_key_cont_step_into_until_addr_abort  ; Abort
        vec_set_ay until_addr

.if CONFIG_KEY_HANDLER_RESUME_LAST_RUN_MODE
        lda #RUN_MODE_STEP_INTO_UNTIL_ADDR
        sta run_mode
.endif

handle_key_cont_step_into_until_addr_continue:
@next_line:
        jsr handle_key_single_step_over
        jsr screen_draw

        jsr check_abort_execution

        vec_cmp pc_lo, until_addr
        bne @next_line
handle_key_cont_step_into_until_addr_abort:
        rts
.endif ; CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR

;-----------------------------------------------------------------------------
; Resume last run mode.
;-----------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_RESUME_LAST_RUN_MODE
handle_key_resume_last_run_mode:
        lda run_mode
.if CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS
        beq handle_key_cont_step_into_until_rts_continue
.endif
.if CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS
        bmi handle_key_cont_step_over_until_rts_continue
.endif
.if CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR
        lsr
        bcs handle_key_cont_step_into_until_addr_continue
.endif
        rts
.endif

;-----------------------------------------------------------------------------
; Helper function to exit run mode on any key press
;-----------------------------------------------------------------------------
check_abort_execution:
        io_key_in_poll
        beq @exit       ; No key pressed
        pla
        pla
@exit:
        rts
