;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"
.include "screen.h"
.include "key_handler.h"
.include "macros.h"

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

add_key_handler KEY_MEMORY_SCROLL_DOWN, handle_key_memory_scroll_down
add_key_handler KEY_MEMORY_PAGE_DOWN, handle_key_memory_page_down

add_key_handler KEY_MEMORY_SCROLL_UP, handle_key_memory_scroll_up
add_key_handler KEY_MEMORY_PAGE_UP, handle_key_memory_page_up

add_key_handler KEY_DISASS_SCROLL_UP, handle_key_opcode_prev
add_key_handler KEY_DISASS_SCROLL_DOWN, handle_key_opcode_next

.segment "CODE"

;-----------------------------------------------------------------------------
; Hexdump navigation
;-----------------------------------------------------------------------------
handle_key_memory_page_down:
        ldy num_mem_lines
        .byte $2c   ; BIT abs
handle_key_memory_scroll_down:
        ldy #1

add_line:
        vec_add_i8 mem_addr_lo, mem_dump_num_bytes
        dey
        bne add_line
        rts

;-----------------------------------------------------------------------------
handle_key_memory_page_up:
        ldy num_mem_lines
        .byte $2c   ; BIT abs
handle_key_memory_scroll_up:
        ldy #1

sub_line:
        vec_sub_i8 mem_addr_lo, mem_dump_num_bytes
        dey
        bne sub_line
        rts

;-----------------------------------------------------------------------------
; Disassembly navigation
;-----------------------------------------------------------------------------
handle_key_opcode_prev:
        dec pc_hi       ; Start scanning at (PC -$100 + $c0) and
        ldy #$c0        ; step over opcodes until we reach current PC

next_opcode:
        jsr lda_pc_y
        jsr opcode_len
        sta shared_tmp
        tax
add_y:
        iny             ; Y += X
        dex
        bne add_y

        tya             ; Have we reached or overshot original PC?
        bmi next_opcode

        sec             ; Subtract len of last opcode from PC
        sbc shared_tmp  ; (PC = (PC - $100) + (Y - last_opcode_len))
        jmp pc_add

;-----------------------------------------------------------------------------
handle_key_opcode_next:
        jsr lda_pc_y0
        jsr opcode_len
        jmp pc_add
