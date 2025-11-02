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
.include "api.h"

;-----------------------------------------------------------------------------
; KEY HANDLING
;-----------------------------------------------------------------------------
api_macro_map io_key_in_poll,       keyscan_key_poll
api_macro_map io_key_in_blocking,   io_key_in_blocking_fn

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
        .local @string
@string:
        .byte str,0
.popseg
        print_str_ptr @string
.endmacro

.macro print_str_at posx, posy, str
        screen_cursor_pos_set posx,posy
        print_str str
.endmacro

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
