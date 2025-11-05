;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "init_vars.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export screen_memmap_chrout_fn
.export screen_memmap_cursor_move_right_fn
.export screen_memmap_cursor_move_left_fn
.if CONFIG_ENABLE_CURSOR_DISPLAY
.export screen_memmap_print_cursor
.endif


.export screen_vec_wr_lo
.export screen_vec_wr_hi

.export sta_screen
.export lda_screen

;-----------------------------------------------------------------------------
; We use these memory access functions so we don't have to use any zero-page
; memory for storing vectors. We don't want to make assumptions about which
; zero-page memory is available.
;
; These access functions live in the DATA (RAM build) or INITVARS_RAM (ROM
; build) segment.
;-----------------------------------------------------------------------------

; STA screen_vec_wr_lo
decl_init_var sta_screen,       $8d    ; STA abs
decl_init_var screen_vec_wr_lo, $00    ; address lo
decl_init_var screen_vec_wr_hi, $00    ; address hi
decl_init_var sta_screen_rts,   $60    ; RTS

.segment "CODE"

; Adding hacky LDA version of sta_screen. This could likely be
; implement more elegantly at some point :-) ...
lda_screen:
        lda #$ad        ; LDA abs
        sta sta_screen
        jsr sta_screen
        pha
        lda #$8d        ; STA abs
        sta sta_screen
        pla
        rts

;-----------------------------------------------------------------------------
; Cursor control
;-----------------------------------------------------------------------------
screen_memmap_cursor_move_left_fn:
        lda screen_vec_wr_lo
        bne :+
        dec screen_vec_wr_hi
:
        dec screen_vec_wr_lo
        rts

screen_memmap_cursor_move_right_fn:
        inc screen_vec_wr_lo
        bne :+
        inc screen_vec_wr_hi
:
        rts

.if CONFIG_ENABLE_CURSOR_DISPLAY
screen_memmap_print_cursor:
        jsr lda_screen
        ora #$80
        jmp sta_screen
.endif ; CONFIG_ENABLE_CURSOR_DISPLAY

;-----------------------------------------------------------------------------
; Chrout related routines
;
; TODO:
;   This code is kinda specific to how the screen and color memories are
;   mapped on the commodore machines. Probably need to have refactor this at
;   some point.
;-----------------------------------------------------------------------------
screen_memmap_chrout_fn:
        pha         ; chrout should not mangle A. Save it.
        and #<~$40
        jsr sta_screen
.if CONFIG_ENABLE_COLOR
        lda screen_vec_wr_hi
        pha
        eor #>(screen_addr_mon ^ color_addr_mon)
        sta screen_vec_wr_hi
        lda chrout_color
        jsr sta_screen
        pla
        sta screen_vec_wr_hi
.endif ; CONFIG_ENABLE_COLOR
        pla         ; Restore A.
        rts
