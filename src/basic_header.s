;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.if CONFIG_BASIC_SYS_LINE
.segment "BASIC_HEADER"
        .word next_line ; next line
        .word 10        ; line number
        .byte $9e       ; SYS
        .byte .sprintf("%d", CONFIG_BASIC_SYS_ADDR)
        .byte 0
next_line:
        .word 0   ; no next line

.endif ; CONFIG_BASIC_SYS_LINE
