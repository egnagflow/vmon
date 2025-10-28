;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.ifndef _SCREEN_H_
_SCREEN_H_ := 1

.include "screen_config.h"

.macro screen_chrout
        jsr screen_chrout_fn
.endmacro

.macro screen_cursor_move_left
        jsr screen_cursor_move_left_fn
.endmacro

.macro screen_cursor_move_right
        jsr screen_cursor_move_right_fn
.endmacro

.macro screen_cursor_pos_set posx, posy
        lda #>(screen_addr_mon + posx * screen_size_y + posy)
        sta screen_vec_wr_hi
        lda #<(screen_addr_mon + posx * screen_size_y + posy)
        sta screen_vec_wr_lo
.endmacro

.macro screen_cursor_pos_set_home
        screen_cursor_pos_set 0,0
.endmacro

.macro screen_cursor_pos_set_xy
        jsr screen_cursor_pos_set_xy_fn
.endmacro

.macro screen_clr
        jsr screen_clr_fn
.endmacro

.macro screen_switch_to_user
        jsr screen_switch_to_user_fn
.endmacro

.macro screen_switch_to_mon
        jsr screen_switch_to_mon_fn
.endmacro

.macro screen_init_platform
.endmacro

.endif ; _SCREEN_H_
