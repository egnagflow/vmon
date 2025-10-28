;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.ifndef _KEY_HANDLER_H_
_KEY_HANDLER_H_ := 1

;-----------------------------------------------------------------------------
; Helper macro to add an entry to the above tables
;-----------------------------------------------------------------------------

.macro add_key_handler keycode, handler
.segment "KEY_CODE_TABLE"
        .byte keycode

.segment "KEY_HANDLER_JUMP_TABLE_HI"
        .byte >(handler -1)
.segment "KEY_HANDLER_JUMP_TABLE_LO"
        .byte <(handler -1)
.endmacro

.endif ; _KEY_HANDLER_H_
