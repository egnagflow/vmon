;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;
; Vector handling macros
;
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Get / Set
;-----------------------------------------------------------------------------
.macro vec_get_ay vec
        ldy vec
        lda vec+1
.endmacro

;-----------------------------------------------------------------------------
.macro vec_set_ay vec
        sty vec
        sta vec+1
.endmacro

;-----------------------------------------------------------------------------
.macro vec_set vec, val
        lda #<val
        sta vec
        lda #>val
        sta vec+1
.endmacro

;-----------------------------------------------------------------------------
; Increment / Decrement
;-----------------------------------------------------------------------------
.macro vec_inc vec
        .local @skip
        inc vec
        bne @skip
        inc vec+1
@skip:
.endmacro

;-----------------------------------------------------------------------------
.macro vec_dec vec
        .local @skip
        lda vec
        bne @skip
        dec vec+1
@skip:
        dec vec
.endmacro

;-----------------------------------------------------------------------------
; Add / Sub
;-----------------------------------------------------------------------------
.macro vec_add_i8 vec, val
        .local @skip
        lda vec
        clc
        adc #val
        sta vec
        bcc @skip
        inc vec+1
@skip:
.endmacro

;-----------------------------------------------------------------------------
.macro vec_add_i16 vec, val
        lda vec
        clc
        adc #<val
        sta vec
        lda vec+1
        adc #>val
        sta vec+1
.endmacro

;-----------------------------------------------------------------------------
.macro vec_sub_i8 vec, val
        .local @skip
        lda vec
        sec
        sbc #val
        sta vec
        bcs @skip
        dec vec+1
@skip:
.endmacro


;-----------------------------------------------------------------------------
; Comparison
;-----------------------------------------------------------------------------
.macro vec_cmp vec1, vec2
        .local @skip
        lda vec1+1
        cmp vec2+1
        bne @skip
        lda vec1
        cmp vec2
@skip:
.endmacro

;-----------------------------------------------------------------------------
.macro vec_cmp_i16 vec, val
        .local @skip
        lda vec+1
        cmp #>val
        bne @skip
        lda vec
        sbc #<val
@skip:
.endmacro
