;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "io.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export print_registers

;------------------------------------------------------------------------------
.segment "CODE"

;-----------------------------------------------------------------------------
; Print header and register values
;-----------------------------------------------------------------------------
print_registers:
        ; Set colors and print header template.
        chrout_set_color color_header
        print_str_ptr screen_header

        ; Print A
        screen_cursor_pos_set 1,2
        lda virt_reg_a
        jsr print_hex8
        ; Print X
        screen_cursor_pos_set 2,2
        lda virt_reg_x
        jsr print_hex8
        ; Print Y
        screen_cursor_pos_set 3,2
        lda virt_reg_y
        jsr print_hex8
        ; Print F
        screen_cursor_pos_set 3,(screen_size_y -4)
        lda virt_reg_f
        jsr print_hex8
        ; Print PC
        screen_cursor_pos_set 2,(screen_size_y -4)
        lda pc_hi
        ldy pc_lo
        jsr print_hex16_ay

        ; Print flag bits
        screen_cursor_pos_set 2,screen_flags_bin_offset
        lda virt_reg_f

        ldx #$08
print_flag:
        asl     ; Shift flag into carry.
        pha
        lda #('0' >> 1)
        rol
        jsr chrout
        pla
        dex
        bne print_flag  ; Next flag bit.

        ; Print SP
        screen_cursor_pos_set 1,(screen_size_y -2)
        lda virt_reg_sp
        jmp print_hex8
