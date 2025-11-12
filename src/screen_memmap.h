;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.ifndef _SCREEN_MEMMAP_H_
_SCREEN_MEMMAP_H_ := 1

.include "api.h"

;-----------------------------------------------------------------------------
; CHROUT
;-----------------------------------------------------------------------------
api_macro_map screen_chrout,            screen_memmap_chrout_fn

;-----------------------------------------------------------------------------
; Cursor handling
;-----------------------------------------------------------------------------
api_macro_map screen_cursor_move_left,  screen_memmap_cursor_move_left_fn
api_macro_map screen_cursor_move_right, screen_memmap_cursor_move_right_fn

api_macro_map_if CONFIG_SCREEN_ENABLE_CURSOR_DISPLAY, screen_print_cursor, screen_memmap_print_cursor

.macro screen_cursor_pos_set posx, posy
        lda #>(screen_addr_mon + posx * screen_size_y + posy)
        sta screen_vec_wr_hi
        lda #<(screen_addr_mon + posx * screen_size_y + posy)
        sta screen_vec_wr_lo
.endmacro

.macro screen_cursor_pos_set_home
        screen_cursor_pos_set 0,0
.endmacro

.endif ; _SCREEN_MEMMAP_H_
