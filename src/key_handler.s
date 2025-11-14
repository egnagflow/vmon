;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "io.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export key_handler_run

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

;-----------------------------------------------------------------------------
; Key handler entry point
;-----------------------------------------------------------------------------
.segment "CODE"

key_handler_run:
        io_key_in_blocking

        ldy #<(__KEY_CODE_TABLE_SIZE__ -1)
next_key:
        cmp __KEY_CODE_TABLE_LOAD__,y
        beq exec_cmd
        dey
        bpl next_key
        rts ; back to key_main_loop

exec_cmd:
        lda __KEY_HANDLER_JUMP_TABLE_HI_LOAD__,y
        pha
        lda __KEY_HANDLER_JUMP_TABLE_LO_LOAD__,y
        pha
        chrout_set_color color_header
        rts ; jump to handler
