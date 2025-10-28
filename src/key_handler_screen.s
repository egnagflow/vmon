;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.if CONFIG_KEY_HANDLER_SCREEN_SHOW
.include "key_handler.h"
.include "screen.h"
.include "io.h"

.export handle_key_show_screen

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

add_key_handler KEY_SHOW_SCREEN, handle_key_show_screen

;-----------------------------------------------------------------------------
.segment "CODE"

handle_key_show_screen:
        screen_switch_to_user
        io_key_in_blocking
        screen_switch_to_mon
        rts

.endif ; CONFIG_KEY_HANDLER_SCREEN_SHOW
