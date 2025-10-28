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
.include "key_handler.h"

.if CONFIG_KEY_HANDLER_MEM_TOGGLE
;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

add_key_handler KEY_TOGGLE_MEMORY_DISPLAY, handle_key_toggle_memory_display

;-----------------------------------------------------------------------------
.segment "CODE"

handle_key_toggle_memory_display:
        lda num_opcode_lines
        eor #13             ; Toggle between 13 and 0
        sta num_opcode_lines
        beq full
        lda #mem_dump_num_lines_low
        .byte $2c
full:
        lda #mem_dump_num_lines_full
        sta num_mem_lines
        rts

.endif ; CONFIG_KEY_HANDLER_MEM_TOGGLE
