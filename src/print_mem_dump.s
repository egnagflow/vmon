;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "io.h"
.include "init_vars.h"
.include "macros.h"

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
.if CONFIG_EXAMPLE_CODE
; If the example code is enabled we set the memory dump address to the region
; the example code is operating on. This way we can see what's going on. See
; example_code.s.
;
decl_init_var mem_addr_lo, $f8    ; LO Address of memory dump
decl_init_var mem_addr_hi, 0      ; HI Address of memory dump
.else
decl_init_var mem_addr_lo, 0      ; LO Address of memory dump
decl_init_var mem_addr_hi, 0      ; HI Address of memory dump
.endif

;------------------------------------------------------------------------------
.segment "CODE"

;-----------------------------------------------------------------------------
; Print memory dump
;-----------------------------------------------------------------------------
print_mem_dump_lines:
        chrout_set_color color_memdump
        vec_get_ay mem_addr_lo
        vec_set_ay mem_vec_rd_lo
        ldx num_mem_lines   ; line count

@print_mem_line:
        vec_get_ay mem_vec_rd_lo
        jsr print_hex16_ay

.if mem_dump_num_bytes = 8
        jsr chrout_space    ; for 40 column screens
.endif ; mem_dump_num_bytes == 8

        ; Print HEX
        ldy #0
@print_byte:
        jsr chrout_space
        jsr lda_mem_y
        jsr print_hex8
        iny
        cpy #mem_dump_num_bytes
        bne @print_byte

.if mem_dump_num_bytes = 8
        jsr chrout_space    ; for 40 column screens
.endif ; mem_dump_num_bytes == 8

        ; Print ASCII
        jsr chrout_space
        ldy #0
@print_ascii:
        jsr lda_mem_y

        and #$7f
        cmp #$20        ; ' '
        bmi @print_dot
        cmp #$5b        ; 'Z'+1
        bpl @print_dot
        .byte $2c       ; BIT abs
@print_dot:
        lda #'.'
        jsr chrout

        iny
        cpy #mem_dump_num_bytes
        bne @print_ascii
        jsr chrout_space

        vec_add_i8 mem_vec_rd_lo, mem_dump_num_bytes
        dex             ; line count
        bne @print_mem_line
        rts
