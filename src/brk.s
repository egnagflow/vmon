;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.if CONFIG_HANDLE_BRK

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export brk_handler_init

;------------------------------------------------------------------------------
.segment "CODE"

brk_handler_init:
        lda #<brk_handler
        sta brk_vector
        lda #>brk_handler
        sta brk_vector+1
        rts

brk_handler:
        lda $104,x      ; status register
        sta virt_reg_f
        lda $105,x      ; PC lo
        sec
        sbc #2
        sta pc_lo
        lda $106,x      ; PC hi
        sbc #0
        sta pc_hi
        txa
        clc
        adc #6
        sta virt_reg_sp

        pla
        sta virt_reg_y
        pla
        sta virt_reg_x
        pla
        sta virt_reg_a

        jmp mon_brk_entry

.endif ; CONFIG_HANDLE_BRK
