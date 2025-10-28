;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "init_vars.h"

;-----------------------------------------------------------------------------
; Convenience helpers to operate on memory vectors
;-----------------------------------------------------------------------------
.macro add_mem_rd_vec val
        lda mem_vec_rd_lo
        clc
        adc #val
        sta mem_vec_rd_lo
        bcc :+
        inc mem_vec_rd_hi
:
.endmacro

.macro inc_mem_rd_vec
        inc mem_vec_rd_lo
        bne :+
        inc mem_vec_rd_hi
:
.endmacro

.macro stay_mem_rd_vec ; A/Y -> H/L
        sta mem_vec_rd_hi
        sty mem_vec_rd_lo
.endmacro

.macro stya_mem_rd_vec ; Y/A -> H/L
        sty mem_vec_rd_hi
        sta mem_vec_rd_lo
.endmacro

.macro stxa_mem_rd_vec ; X/A -> H/L
        stx mem_vec_rd_hi
        sta mem_vec_rd_lo
.endmacro

.macro ldya_mem_rd_vec ; Y/A -> H/L
        ldy mem_vec_rd_hi
        lda mem_vec_rd_lo
.endmacro

.macro lday_mem_rd_vec ; A/Y -> H/L
        lda mem_vec_rd_hi
        ldy mem_vec_rd_lo
.endmacro

.macro cmpya_mem_rd_vec ; Y/A -> H/L
        sec
        sbc mem_vec_rd_lo
        tya
        sbc mem_vec_rd_hi
.endmacro

;------------------------------------------------------------------------------
.macro inc_mem_wr_vec
        inc mem_vec_wr_lo
        bne :+
        inc mem_vec_wr_hi
:
.endmacro

.macro stay_mem_wr_vec ; A/Y -> H/L
        sta mem_vec_wr_hi
        sty mem_vec_wr_lo
.endmacro

.macro stya_mem_wr_vec ; Y/A -> H/L
        sty mem_vec_wr_hi
        sta mem_vec_wr_lo
.endmacro

.macro stxa_mem_wr_vec ; X/A -> H/L
        stx mem_vec_wr_hi
        sta mem_vec_wr_lo
.endmacro

.macro lday_mem_wr_vec ; A/Y -> H/L
        lda mem_vec_wr_hi
        ldy mem_vec_wr_lo
.endmacro

.macro ldya_mem_wr_vec ; Y/A -> H/L
        ldy mem_vec_wr_hi
        lda mem_vec_wr_lo
.endmacro

.macro cmpya_mem_wr_vec ; Y/A -> H/L
        sec
        sbc mem_vec_wr_lo
        tya
        sbc mem_vec_wr_hi
.endmacro
