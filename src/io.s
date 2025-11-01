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
.include "io.h"
.include "init_vars.h"
.include "macros.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export chrout_home
.export chrout
.export chrout_space
.export strout

.export io_key_in_blocking_fn

.if CONFIG_ENABLE_COLOR
.export chrout_color

.if CONFIG_ENABLE_COLOREDIT_FONT
.export color_header
.export color_opcodes
.export color_memdump
.endif ; CONFIG_ENABLE_COLOREDIT_FONT
.endif ; CONFIG_ENABLE_COLOR

.segment "CODE"

;-----------------------------------------------------------------------------
; KEY HANDLING
;-----------------------------------------------------------------------------
io_key_in_blocking_fn:
        io_key_in_poll
        cmp #$00
        beq io_key_in_blocking_fn
        rts

;-----------------------------------------------------------------------------
; CHARACTER PRINTING
;-----------------------------------------------------------------------------
chrout_space:
        lda #' '
        ; Fall through.
chrout:
        screen_chrout
        ; Fall through.

chrout_cursor_r:
        screen_cursor_move_right
        rts

chrout_parse:
.if CONFIG_ENABLE_CURSOR_DISPLAY
        cmp #$9d            ; CRSR left?
        bne check_cursor_r

chrout_cursor_l:
        screen_cursor_move_left
        rts
.endif ; CONFIG_ENABLE_CURSOR_DISPLAY

check_cursor_r:
        cmp #$1d            ; CRSR right?
        beq chrout_cursor_r

        cmp #$13            ; HOME?
        bne chrout

chrout_home:
        screen_cursor_pos_set_home
        rts

;-----------------------------------------------------------------------------
; COLOR SUPPORT
;-----------------------------------------------------------------------------
.if CONFIG_ENABLE_COLOR
  .segment "DATA"
  chrout_color:   .res 1
  
  .if CONFIG_ENABLE_COLOREDIT_FONT
    decl_init_var color_header,  color_header_default
    decl_init_var color_opcodes, color_opcodes_default
    decl_init_var color_memdump, color_memdump_default
  .endif ; CONFIG_ENABLE_COLOREDIT_FONT
.endif ; CONFIG_ENABLE_COLOR

;-----------------------------------------------------------------------------
; Print the string pointed to by Y/A (H/L).
;
; This routine imlements a poor man's run time length encoding:
;   If a characted in the string has bit 7 set it means that it is not a
;   printable character but a counter and the following character should be
;   printed that many times.
;-----------------------------------------------------------------------------
.segment "CODE"

.if CONFIG_OPTIMIZE_MEM_SIZE
strout:
        vec_set_ay mem_vec_rd_lo
        ldy #0
single_chr:
        ldx #1
next_chr:
        jsr lda_mem_y
        beq @done           ; Terminating \0?
        bpl @loop           ; Counter?
        and #$7f            ; Get counter in X
        tax
        iny                 ; Point to next character
        bne next_chr       ; And print X times
@loop:
        jsr chrout_parse
        dex
        bne @loop
        iny
        bne single_chr
@done:
        rts
.else
strout:
        vec_set_ay mem_vec_rd_lo
        ldy #0
next_chr:
        jsr lda_mem_y
        beq @done
        jsr chrout_parse
        iny
        bne next_chr
@done:
        rts
.endif
