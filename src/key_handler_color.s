;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.if CONFIG_ENABLE_COLOR && CONFIG_ENABLE_COLOREDIT_FONT
.include "key_handler.h"

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

add_key_handler KEY_COLOR_CHANGE_REGISTERS, handle_key_color_change_registers
add_key_handler KEY_COLOR_CHANGE_DISASSEM, handle_key_color_change_disassem
add_key_handler KEY_COLOR_CHANGE_MEMDUMP, handle_key_color_change_memdump

;------------------------------------------------------------------------------
.segment "CODE"

handle_key_color_change_registers:
        ldx #0
        .byte $2c ; BIT abs
handle_key_color_change_disassem:
        ldx #1
        .byte $2c ; BIT abs
handle_key_color_change_memdump:
        ldx #2
        lda color_header,x
        clc
        adc #1
        and #$7
        sta color_header,x
        rts
.endif ; CONFIG_ENABLE_COLOR && CONFIG_ENABLE_COLOREDIT_FONT
