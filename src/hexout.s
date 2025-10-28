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
.export print_hex8
.export print_hex16_ay

.segment "CODE"
;-----------------------------------------------------------------------------
; Print helper functions
;-----------------------------------------------------------------------------
print_hex16_ay:
        jsr print_hex8
        tya
        ; Fall through.

;-----------------------------------------------------------------------------
print_hex8:
        pha
        lsr
        lsr
        lsr
        lsr
        jsr print_nibble
        pla
        and #$0f
        ; Fall through.

print_nibble:
        clc
        adc #$30
        cmp #$3a
        bcc :+
        adc #$06 ; Add $07 as carry is set here.
:
        jmp chrout
