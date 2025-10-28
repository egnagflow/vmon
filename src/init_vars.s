;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.if CONFIG_ROM_BUILD
;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export setup_init_vars_fn

;-----------------------------------------------------------------------------
; For ROM builds we need to copy the initialized data section to RAM.
;-----------------------------------------------------------------------------
.segment "CODE"

setup_init_vars_fn:
        ldy #<__INITVARS_ROM_SIZE__
:
        lda __INITVARS_ROM_LOAD__,y
        sta __INITVARS_RAM_LOAD__,y
        dey
        bpl :-
        rts

.endif ; CONFIG_ROM_BUILD
