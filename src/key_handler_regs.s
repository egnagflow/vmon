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

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

add_key_handler KEY_SET_PROGRAM_COUNTER, handle_key_set_program_counter

.if CONFIG_KEY_HANDLER_REG_SET
add_key_handler KEY_SET_REGISTER_VALUE, handle_key_set_register_value
.endif

;-----------------------------------------------------------------------------
.segment "CODE"

;-----------------------------------------------------------------------------
; Set PC
;-----------------------------------------------------------------------------
handle_key_set_program_counter:
        lda #KEY_SET_PROGRAM_COUNTER
        jsr key_handler_read_hex16
        bcs abort_set_pc  ; Abort
        sta pc_hi
        sty pc_lo
abort_set_pc:
        rts

;-----------------------------------------------------------------------------
; Set register values
;-----------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_REG_SET

handle_key_set_register_value:
        screen_cursor_pos_set 0,1
        lda #KEY_SET_REGISTER_VALUE
        jsr chrout
read_reg_name:
        io_key_in_blocking
        cmp #key_code_esc
        beq abort_set_reg
        ldx #(_reg_names_end - _reg_names)
check_reg_name:
        cmp _reg_names,x
        beq found
        dex
        bpl check_reg_name
        bmi read_reg_name

found:
        stx gs_key_handler_regs
        jsr chrout          ; Print register name
        jsr chrout_space
        jsr read_hex8
        bcs abort_set_reg
        ldx gs_key_handler_regs
        sta virt_reg_a,x
abort_set_reg:
        rts

.segment "ROM"
_reg_names:     .byte 'A','X','Y','F','S'
_reg_names_end:

.endif ; CONFIG_KEY_HANDLER_REG_SET
