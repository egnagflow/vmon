;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.include "screen.h"
.include "io.h"

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export key_handler_read_hex16

;-----------------------------------------------------------------------------
.segment "CODE"

;-----------------------------------------------------------------------------
; Set cursor, print key character and read a 16 bit hex number.
;-----------------------------------------------------------------------------
key_handler_read_hex16:
        pha
        screen_cursor_pos_set 0,1
        pla
        jsr chrout
        jmp read_hex16
