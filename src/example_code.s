;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.if CONFIG_EXAMPLE_CODE
;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export example_code

;-----------------------------------------------------------------------------
; Example code to point the PC to when VMON starts.
;
; When VMON starts, the memory dump address is set to $0000.
; Therefore, the example uses this memory so its effect is visible without
; having to change the memory dump address.
;-----------------------------------------------------------------------------
vec     = $4
dest    = $8

.segment "CODE"
.if CONFIG_EXAMPLE_CODE_NOPS
        ; Pad the example code with a bunch of NOPs
        .res $10, $ea
.endif

example_code:
        jsr hello_world
        jsr how_are_you
        jmp example_code

print:
        stx vec
        sty vec+1
        ldy #0
:
        lda (vec),y
        beq :+
        sta dest,y
        iny
        bne :-
:
        rts

hello_world:
        ldx #<hello_world_txt
        ldy #>hello_world_txt
        jsr print
        rts

how_are_you:
        ldx #<how_are_you_txt
        ldy #>how_are_you_txt
        jmp print

hello_world_txt:   .byte "HELLO WORLD!", 0
how_are_you_txt:   .byte "HOW ARE YOU?", 0

.if CONFIG_EXAMPLE_CODE_NOPS
        ; More NOPs at the end
        .res $10, $ea
.endif

.endif ; CONFIG_EXAMPLE_CODE
