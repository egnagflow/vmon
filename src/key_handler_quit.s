;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"
.include "key_handler.h"
.include "screen.h"

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

add_key_handler KEY_QUIT, handle_key_quit

;------------------------------------------------------------------------------
.segment "CODE"

handle_key_quit:
        screen_switch_to_user
        ldx #$ff
        txs
        cld
        cli
        jmp (vec_mon_exit)
