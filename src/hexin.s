;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"
.include "io.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export read_hex8
.export read_hex16

;------------------------------------------------------------------------------
.segment "CODE"

;------------------------------------------------------------------------------
read_hex4:
        show_cursor
        io_key_in_blocking
        cmp #key_code_esc
        sec
        beq @abort
        cmp #'0'
        bmi read_hex4

        jsr chrout
        sec
        sbc #$30
        bmi read_hex4
        cmp #$0a
        bmi @ok
        sec
        sbc #$07
        cmp #$10
        bpl read_hex4
@ok:
        clc             ; OK
@abort:
        rts

read_hex8:
        jsr read_hex4
        bcs @abort
        asl
        asl
        asl
        asl
        sta shared_tmp
        jsr read_hex4
        bcs @abort
        ora shared_tmp
@abort:
        rts

read_hex16:
        jsr read_hex8
        bcs @abort
        pha
        jsr read_hex8
        tay
        pla
@abort:
        rts
