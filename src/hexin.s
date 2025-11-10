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
.include "screen.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export read_hex8
.export read_hex16

;------------------------------------------------------------------------------
.segment "CODE"

; PETSCII table for reference:
;
;   +-----+-----+------+
;   | Dec | Hex | Char |
;   +-----+-----+------+
;   | 47  | $2F |  /   |
;   | 48  | $30 |  0   |
;   | 49  | $31 |  1   |
;   | 50  | $32 |  2   |
;   | 51  | $33 |  3   |
;   | 52  | $34 |  4   |
;   | 53  | $35 |  5   |
;   | 54  | $36 |  6   |
;   | 55  | $37 |  7   |
;   | 56  | $38 |  8   |
;   | 57  | $39 |  9   |
;   | 58  | $3A |  :   |
;   | 59  | $3B |  ;   |
;   | 60  | $3C |  <   |
;   | 61  | $3D |  =   |
;   | 62  | $3E |  >   |
;   | 63  | $3F |  ?   |
;   | 64  | $40 |  @   |
;   | 65  | $41 |  A   |
;   | 66  | $42 |  B   |
;   | 67  | $43 |  C   |
;   | 68  | $44 |  D   |
;   | 69  | $45 |  E   |
;   | 70  | $46 |  F   |
;   | 71  | $47 |  G   |
;   +-----+-----+------+

read_hex4:
        screen_cursor_print
        io_key_in_blocking
        cmp #key_code_esc   ; Abort on ESC key.
        sec
        beq @abort
        cmp #$0d            ; Abort on RETURN key.
        sec
        beq @abort

        ; Check for valid hex character.
        cmp #'0'        ; <'0'?
        bcc read_hex4
        cmp #'F'+1      ; >='G'?
        bcs read_hex4
        cmp #'A'        ; >='A'?
        bcs @valid
        cmp #'9'+1      ; >=':'?
        bcs read_hex4

@valid:
        jsr chrout
        sec
        sbc #$30
        cmp #$0a    ; 0x00..0x09?
        bcc @done   ; Yes.
        sec
        sbc #$07    ; 0x0a..0x0f.
@done:
        clc             ; OK
@abort:
        rts

;-----------------------------------------------------------------------------
; Read 8 bit hex number from keyboard.
;
; In:   -
; Out:  A: Read value high byte
; Out:  C: 0 - OK, 1 - Abort
;-----------------------------------------------------------------------------
read_hex8:
        jsr read_hex4
        bcs @abort
        asl
        asl
        asl
        asl
        sta gs_hexin
        jsr read_hex4
        bcs @abort
        ora gs_hexin
@abort:
        rts

;-----------------------------------------------------------------------------
; Read 16 bit hex number from keyboard.
;
; In:   -
; Out:  A: Read value high byte
; Out:  Y: Read value high low
; Out:  C: 0 - OK, 1 - Abort
;-----------------------------------------------------------------------------
read_hex16:
        jsr read_hex8
        bcs @abort
        pha
        jsr read_hex8
        tay
        pla
@abort:
        rts
