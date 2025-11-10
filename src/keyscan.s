;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.if CONFIG_USE_BUILT_IN_KEYSCAN

.include "init_vars.h"
.include "keyscan.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export keyscan_key_poll

;-----------------------------------------------------------------------------
; Built in keyscan implementaion 
;
; This implementation works for VIC20 and C64 as they use the same method to
; scan key presses. It may also work for other machines.
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
; keyscan_key_poll
;-----------------------------------------------------------------------------
decl_init_var keyscan_key_repeat_delay_counter, 0
decl_init_var keyscan_key_last_pressed, 0

.segment "CODE"
; keyscan_key_poll
;
; Poll for character input from the keyboard.
;
; In:   -
; Out:  A: Character code if key pressed, $00 otherwise
; Mod:  A, X, Y, flags
keyscan_key_poll:
        jsr keyscan_get_key
        bne have_key
        ldy #0
        beq keyscan_key_out

        ; We have a valid key.
        ; Check if the repeat delay counter has expired.
have_key:
        dec keyscan_key_repeat_delay_counter
        bmi keyscan_key_valid

        ; Repeat delay counter has not yet expired.
        ; Return "no key".
keyscan_no_key:
        lda #0
        rts

keyscan_key_valid:
        ; Long delay initially, short delay when repeating
        ; held key.
        ldy #20
        cmp keyscan_key_last_pressed
        beq keyscan_key_out
        ldy #120
keyscan_key_out:
        sty keyscan_key_repeat_delay_counter
        sta keyscan_key_last_pressed
        rts

keyscan_get_key:
        ldx #$ff
        stx keyscan_outport_dir ; Set output port.
        inx
        stx keyscan_inport_dir  ; Set input port.
        stx keyscan_outport_val ; Set all lines to low.

debounce:
        ldx #0
debounce_timeout:
        lda keyscan_inport_val
        cmp keyscan_inport_val
        bne debounce
        dex
        bne debounce_timeout
        cmp #$ff
        beq keyscan_no_key

        ; Check the row of the key pressed.
        ; x=0 here.
next_row:
        lsr
        bcc keyscan_row_found
        inx
        bne next_row    ; Always take branch.

keyscan_row_found:
        stx gs_keyscan  ; Save row number.

        ldy #0
        lda #%11111110
scan_col:
        sta keyscan_outport_val
        ldx keyscan_inport_val
        cpx #$ff
        bne keyscan_col_found
        iny
        cpy #8
        beq keyscan_no_key
        sec
        rol
        bne scan_col

keyscan_col_found:
        lda gs_keyscan  ; Get row number.
        asl             ; and multiply by 8.
        asl
        asl
        clc             ; Add column offset.
        sty gs_keyscan
        adc gs_keyscan
        tay
        
        lda keyscan_key_table,y
        rts

.endif ; CONFIG_USE_BUILT_IN_KEYSCAN
