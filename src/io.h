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

;-----------------------------------------------------------------------------
; KEY HANDLING
;-----------------------------------------------------------------------------
.macro io_key_in_poll
        jsr keyscan_key_poll
.endmacro

.macro io_key_in_blocking
        jsr io_key_in_blocking_fn
.endmacro

;-----------------------------------------------------------------------------
; GENERIC SCREEN INIT
;-----------------------------------------------------------------------------
.macro screen_init_common
        ; Set up screen
        screen_init_platform
.endmacro

;-----------------------------------------------------------------------------
; STRING PRINTING FUNCTIONS
;-----------------------------------------------------------------------------
.macro print_str_ptr str
        lda #>str
        ldy #<str
        jsr strout
.endmacro

.macro print_str str
.pushseg
.segment "ROM"
:       .byte str,0
.popseg
        print_str_ptr :-
.endmacro

.macro print_str_at posx, posy, str
        screen_cursor_pos_set posx,posy
        print_str str
.endmacro

;-----------------------------------------------------------------------------
; VISIBLE CURSOR SUPPORT
;-----------------------------------------------------------------------------
.if CONFIG_ENABLE_CURSOR_DISPLAY
  .macro show_cursor
        jsr print_cursor
  .endmacro
.else ; CONFIG_ENABLE_CURSOR_DISPLAY
  .macro show_cursor
    ; Empty macro
  .endmacro
.endif ; CONFIG_ENABLE_CURSOR_DISPLAY

;-----------------------------------------------------------------------------
; COLOR SUPPORT
;-----------------------------------------------------------------------------
.if CONFIG_ENABLE_COLOR
  .if CONFIG_ENABLE_COLOREDIT_FONT
    .macro chrout_set_color color
            lda color
            sta chrout_color
    .endmacro
  .else ; CONFIG_ENABLE_COLOREDIT_FONT
    .macro chrout_set_color color
            lda #color
            sta chrout_color
    .endmacro
  .endif ; CONFIG_ENABLE_COLOREDIT_FONT
  
.else ; CONFIG_ENABLE_COLOR
  .macro chrout_set_color color
    ; Empty macro
  .endmacro
.endif ; CONFIG_ENABLE_COLOR
