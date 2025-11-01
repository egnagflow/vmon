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

;-----------------------------------------------------------------------------
; CHROUT
;-----------------------------------------------------------------------------
.macro screen_chrout
        jsr screen_memmap_chrout_fn
.endmacro

;-----------------------------------------------------------------------------
; Cursor handling
;-----------------------------------------------------------------------------
.macro screen_cursor_move_left
        jsr screen_memmap_cursor_move_left_fn
.endmacro

.macro screen_cursor_move_right
        jsr screen_memmap_cursor_move_right_fn
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

.if CONFIG_ENABLE_CURSOR_DISPLAY
.macro screen_print_cursor
        jsr screen_memmap_print_cursor
.endmacro
.endif

.endif ; _SCREEN_MEMMAP_H_
