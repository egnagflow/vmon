;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "io.h"
.include "mem_access.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export print_mem_dump_lines

.export num_mem_lines
.export mem_addr_hi
.export mem_addr_lo

;-----------------------------------------------------------------------------
; Number of mem dump lines
;-----------------------------------------------------------------------------
num_mem_lines_init = mem_dump_num_lines_low
decl_init_var num_mem_lines, num_mem_lines_init

; Address to use for hex dump display.
decl_init_var mem_addr_lo, 0      ; LO Address of memory dump
decl_init_var mem_addr_hi, 0      ; HI Address of memory dump

;------------------------------------------------------------------------------
.segment "CODE"

;-----------------------------------------------------------------------------
; Print memory dump
;-----------------------------------------------------------------------------
print_mem_dump_lines:
        chrout_set_color color_memdump
        lda mem_addr_hi
        ldy mem_addr_lo
        stay_mem_rd_vec
        ldx num_mem_lines   ; line count
print_mem_line:
        lday_mem_rd_vec
        jsr print_hex16_ay

.if mem_dump_num_bytes = 8
        jsr chrout_space    ; for 40 column screens
.endif ; mem_dump_num_bytes == 8

        ; Print HEX
        ldy #0
print_byte:
        jsr chrout_space
        jsr lda_mem_y
        jsr print_hex8
        iny
        cpy #mem_dump_num_bytes
        bne print_byte

.if mem_dump_num_bytes = 8
        jsr chrout_space    ; for 40 column screens
.endif ; mem_dump_num_bytes == 8

        ; Print ASCII
        jsr chrout_space
        ldy #0
print_ascii:
        jsr lda_mem_y
        jsr print_ascii_dump
        iny
        cpy #mem_dump_num_bytes
        bne print_ascii
        jsr chrout_space

        add_mem_rd_vec mem_dump_num_bytes
        dex             ; line count
        bne print_mem_line
        rts

print_ascii_dump:
        and #$7f
        cmp #$20        ; ' '
        bmi print_dot
        cmp #$5b        ; 'Z'+1
        bpl print_dot
        .byte $2c       ; BIT abs
print_dot:
        lda #'.'
        jmp chrout


