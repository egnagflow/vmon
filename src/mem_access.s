;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"
.include "init_vars.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export lda_pc_y0
.export lda_pc_y

.export pc_lo
.export pc_hi
.export pc_add
.export pc_inc
.export pc_inc_by_2

.export lda_mem_y0
.export lda_mem_y

.export mem_vec_rd_lo
.export mem_vec_rd_hi

.export mem_vec_wr_lo
.export mem_vec_wr_hi

.export sta_mem_y

;-----------------------------------------------------------------------------
; We use these memory access functions so we don't have to use any zero-page
; memory for storing vectors. We don't want to make assumptions about which
; zero-page memory is available.
;
; These access functions live in "regular", non-zero-page memory.
;-----------------------------------------------------------------------------

; LDY #0
decl_init_var lda_pc_y0,        $a0
decl_init_var lda_pc_y0_arg,    $00

; LDA (pc_lo),y equiv
decl_init_var lda_pc_y,         $b9
.if CONFIG_EXAMPLE_CODE
decl_init_var pc_lo,            <example_code
decl_init_var pc_hi,            >example_code
.else
decl_init_var pc_lo,            $00
decl_init_var pc_hi,            $00
.endif
decl_init_var lda_pc_y_rts,     $60

; LDY #0
decl_init_var lda_mem_y0,       $a0
decl_init_var lda_mem_y0_arg,   $00

; LDA (mem_vec_rd_lo),y equiv
decl_init_var lda_mem_y,        $b9
decl_init_var mem_vec_rd_lo,    $00
decl_init_var mem_vec_rd_hi,    $00
decl_init_var lda_mem_y_rts,    $60

; STA (mem_vec_wr_lo),y equiv
decl_init_var sta_mem_y,        $99
decl_init_var mem_vec_wr_lo,    $00
decl_init_var mem_vec_wr_hi,    $00
decl_init_var sta_mem_y_rts,    $60

;------------------------------------------------------------------------------
.segment "CODE"

pc_inc_by_2:
        lda #2
        .byte $2c   ; BIT abs
pc_inc:
        lda #1
pc_add:
        clc
        adc pc_lo
        sta pc_lo
        bcc skip
        inc pc_hi
skip:
        rts
