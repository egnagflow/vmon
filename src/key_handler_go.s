;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.if CONFIG_KEY_HANDLER_GO
.include "key_handler.h"
.include "screen.h"
.include "io.h"

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

add_key_handler KEY_GO, handle_key_go

;-----------------------------------------------------------------------------
.segment "CODE"

;-----------------------------------------------------------------------------
; Set PC
;-----------------------------------------------------------------------------
handle_key_go:
        screen_cursor_pos_set 0,1
        lda #KEY_GO
        jsr chrout
        jsr read_hex16
        bcs abort_go            ; Abort
        ; At this point Y = lo addrs, A = Hi addr.
        jmp exec_custom_jsr_ay
abort_go:
        rts

.endif ; CONFIG_KEY_HANDLER_REG_SET
