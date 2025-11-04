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

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export print_opcode_lines

; get_rel_pc_addr_ay
;
; Returns the address of a relative branch at pc_hi/lo in A, Y.
;
; In:   A: Brnach opcode, pc_hi, pc_lo
; Out:  A: Branch address hi byte
; Out:  X: Branch address hi byte
; Out:  Y: Branch address lo byte
; Mod:  A, X, Y, flags
.export get_rel_pc_addr_ay

.export num_opcode_lines

;------------------------------------------------------------------------------
; Number of disassembly lines
num_opcode_lines_init = 13
decl_init_var num_opcode_lines, num_opcode_lines_init

;------------------------------------------------------------------------------
.segment "CODE"

;-----------------------------------------------------------------------------
; Print opcode section
;-----------------------------------------------------------------------------
print_opcode_lines:
        chrout_set_color color_opcodes
        screen_cursor_pos_set 4,0

        ; Save PC.
        lda pc_hi
        pha
        lda pc_lo
        pha

        lda num_opcode_lines
        beq exit_print_opcode_lines

print_opcode_line:
        pha     ; line count

        ; Print PC address
        lda pc_hi
        ldy pc_lo
        jsr print_hex16_ay
        jsr chrout_space

        ; Print opcode hex bytes
        jsr lda_pc_y0
        pha     ; Save opcode for peeking later.
        jsr opcode_len
        tax     ; Number bytes to print for this opcode -> X.
print_opcode_byte:
        jsr lda_pc_y
        jsr print_hex8
        iny
        dex
        bne print_opcode_byte
print_space:
        cpy #3
        beq @done
        jsr chrout_space    ; Print 2 spaces per "missing"
        jsr chrout_space    ; hex value.
        iny
        bne print_space     ; Y is never $00 here, always take branch.
@done:
        jsr chrout_space

        ; Print opcode ASCII
        pla     ; peek opcode
        pha
        
        jsr opcode_str
        jsr chrout
        txa
        jsr chrout
        tya
        jsr chrout

        jsr chrout_space

        pla     ; peek opcode
        pha
        jsr opcode_addr_mode
        pha     ; addr mode

        jsr print_opcode_arg
        pla     ; addr mode
        tax

        ; Get the number of remaining spaces to print to fill the rest
        ; of the screen line
        lda spaces_to_print,x
        beq set_pc
        tay
print_remaining_space:
        jsr chrout_space
        dey
        bne print_remaining_space

        ; Set PC to next opcode
set_pc:
        pla     ; opcode
        jsr opcode_len
        jsr pc_add

        pla     ; line count
        sec
        sbc #1
        bne print_opcode_line

exit_print_opcode_lines:
        ; Done with opcodes. Restore PC and return.
        pla
        sta pc_lo
        pla
        sta pc_hi
        rts

;-----------------------------------------------------------------------------
; Opcode argument printing
;-----------------------------------------------------------------------------
PRT_ARG_MARKER = (1 << 7) ; N flag
PRT_ARG_REL    = (PRT_ARG_MARKER | 0)
PRT_ARG_8      = (PRT_ARG_MARKER | 1)
PRT_ARG_16     = (PRT_ARG_MARKER | 2)

;-----------------------------------------------------------------------------
.segment "ROM"
; These numbers are based on the original implementation for the VIC20 with 22
; columns. When we added other build targets, we added an offset relative to the
; screen width, hence the convoluted code.
;
spaces_to_print:
        .byte 3 + (screen_size_y - 22)    ; immediate
        .byte 4 + (screen_size_y - 22)    ; zp
        .byte 2 + (screen_size_y - 22)    ; zp,x
        .byte 2 + (screen_size_y - 22)    ; zp,y
        .byte 0 + (screen_size_y - 22)    ; (zp,x)
        .byte 0 + (screen_size_y - 22)    ; (zp),y
        .byte 2 + (screen_size_y - 22)    ; absolute
        .byte 0 + (screen_size_y - 22)    ; abs,x
        .byte 0 + (screen_size_y - 22)    ; abs,y
        .byte 0 + (screen_size_y - 22)    ; (ind)
        .byte 2 + (screen_size_y - 22)    ; relative
        .byte 6 + (screen_size_y - 22)    ; no operand

; Table of format string that describe how the addressing modes need to
; be printed, similar to printf formatting. The N flag in the format
; indicates that an hex argument needs to be printed. Bit [1:0]
; indicate how many bytes are in the hex argument. If bit[1:0] are 0 a
; relative branch argument needs to be printed.
;
; Note that prt_fmt_str_table does not need to be in any specifc order,
; while prt_fmt_str_offset_table needs to be ordered the same way as
; the addressing modes in opcode.tas as opcode_addr_mode will proved
; the lookup index into prt_fmt_str_offset_table.
;
prt_fmt_str_table:
prt_imm:    .byte "#" ; Use the arg from prt_zp below.
prt_zp:     .byte PRT_ARG_8, 0
prt_zpx:    .byte PRT_ARG_8, ",X", 0
prt_zpy:    .byte PRT_ARG_8, ",Y", 0
prt_izx:    .byte "(", PRT_ARG_8, ",X)", 0
prt_izy:    .byte "(", PRT_ARG_8, "),Y", 0
prt_abl:    .byte PRT_ARG_16, 0
prt_abx:    .byte PRT_ARG_16, ",X", 0
prt_aby:    .byte PRT_ARG_16, ",Y", 0
prt_ind:    .byte "(", PRT_ARG_16, ")" ; Use $00 from prt_non below.
prt_non:    .byte 0
prt_rel:    .byte PRT_ARG_REL ; No need for $00 end marker as this is
                              ; handled as a special case in
                              ; print_relative.

prt_fmt_str_offset_table:
        .byte prt_imm - prt_imm
        .byte prt_zp  - prt_imm
        .byte prt_zpx - prt_imm
        .byte prt_zpy - prt_imm
        .byte prt_izx - prt_imm
        .byte prt_izy - prt_imm
        .byte prt_abl - prt_imm
        .byte prt_abx - prt_imm
        .byte prt_aby - prt_imm
        .byte prt_ind - prt_imm
        .byte prt_rel - prt_imm
        .byte prt_non - prt_imm

;------------------------------------------------------------------------------
.segment "CODE"

print_opcode_arg:
        tax     ; A contains addressing mode.
        lda prt_fmt_str_offset_table,x
        tax
        
        ; Print the argument text
print_arg:
        lda prt_fmt_str_table,x
        beq @done       ; $00 end marker, we're done.
        bmi print_hex   ; Bit 7 set, let's print the arg.
        jsr chrout
        inx
        bne print_arg
@done:
        rts

print_hex:
        and #$03
        tay
        beq print_relative
print_arg_hex:
        jsr lda_pc_y
        jsr print_hex8
        dey
        bne print_arg_hex
        inx
        bne print_arg   ; X will never be $00 here. Always take branch.

print_relative:
        iny         ; Y is 0 when we get here, need to increment.
        jsr lda_pc_y
        jsr get_rel_pc_addr_ay
        ; We can return after this, we know there's no more chars to
        ; print.
        jmp print_hex16_ay

;-----------------------------------------------------------------------------
get_rel_pc_addr_ay:
        clc         ; CLC now so it will be pushed for later ADC #2.
        php         ; Remember sign of branch for later.
        ldx pc_hi   ; Add branch offset to PC.
        adc pc_lo   ; PC is still set to the branch instruction address here.
        bcc :+
        inx
:       plp         ; was it a backwards branch?
        bpl :+      ; no
        dex
:       adc #2      ; Adjust to actual PC used for branching, i.e. next instruction.
        bcc :+
        inx
:       tay
        txa
        rts         ; A=hi, X=hi, Y=lo
