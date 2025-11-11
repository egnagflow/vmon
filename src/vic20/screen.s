;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"
.include "init_vars.h"
.include "macros.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export screen_clr_fn
.export screen_header

.if CONFIG_ENABLE_COLOREDIT_BACKGROUND
.export screen_color_background_cycle_fn
.export screen_color_frame_cycle_fn
.endif

.export screen_switch_to_mon_fn
.export screen_switch_to_user_fn

;-----------------------------------------------------------------------------
;
; Screen mapping depending on available memory expansions.
;
; Expn   Native  Native   VMON    VMON     BASIC
;        Char    Color    Char    Color    Start
; ------------------------------------------------
; None   $1E00   $9600    $1C00   $9400    $1000
; 3K     $1E00   $9600    $1C00   $9400    $0400
; 8K+    $1000   $9400    $3C00   $9600    $1200
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Screen Layout
;
; NOTE: Coordinate system on VIC20 is swapped.
;
;                +--- Y resolution 22 --+
;                |                      |
;                v                      v
;
;           +->  +----------------------+
;           |    |:                     |
;           |    |a:a0           sp:01fd|
;           |    |x:a0  10110000 pc:a519|
;           |    |y:c9  nv-bdizc  f:b0  |
;           |    |a519 48     pha       |
;           |    |a51a 18     clc       |
;           |    |a51b 692a   adc #2a   |
;           |    |a51d a8     tay       |
;           |    |a51e 68     pla       |
;           |    |a51f e8     pla       |
;           |    |a51f e608   inc 08    |
; X res 23 -{    |a521 d0f3   bne a516  |
;           |    |a523 e609   inc 09    |
;           |    |a525 4c16a5 jmp a516  |
;           |    |a528 ad4401 lda 0144  |
;           |    |a52b 8d2101 sta 0121  |
;           |    |a52e a9d8   lda #d8   |
;           |    |0000 00 00 ff ff .... |  <-+
;           |    |0004 ff ff 00 00 .... |    | 6 rows of
;           |    |0008 a0 00 ff ff  ... |    | 4 bytes
;           |    |000c ff ff 00 00 .... |    | for hexdump
;           |    |0010 00 00 ff ff .... |    |
;           |    |0014 ff ff 00 00 .... |  <-+
;           +->  +----------------------+
;
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Screen header
;-----------------------------------------------------------------------------
.segment "ROM"

screen_header:   .byte $13
.if CONFIG_OPTIMIZE_MEM_SIZE
        .byte ":",$80|21," "
        .byte "A:",$1d,$1d,$80|11," SP:01",$80|2,$1d
        .byte "X:",$1d,$1d,"  ",$80|8,$1d," PC:",$80|4,$1d
        .byte "Y:",$1d,$1d,"  NV-BDIZC  F:",$80|4,$1d,$00
.else
        .byte ":                     "
        .byte "A:",$1d,$1d,"           SP:01",$1d,$1d
        .byte "X:",$1d,$1d,"  ",$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d," PC:",$1d,$1d,$1d,$1d
        .byte "Y:",$1d,$1d,"  NV-BDIZC  F:",$1d,$1d,$1d,$1d,$00
.endif

;-----------------------------------------------------------------------------
; Font color editing
;-----------------------------------------------------------------------------
.if CONFIG_ENABLE_COLOREDIT_FONT
decl_init_var color_bg, color_bg_default  ; Background color
.endif ; CONFIG_ENABLE_COLOREDIT_FONT

;-----------------------------------------------------------------------------
; Frame / background color
;-----------------------------------------------------------------------------
.if CONFIG_ENABLE_COLOR
.segment "DATA"
save_color:     .res 1
.endif ; CONFIG_ENABLE_COLOR

;-----------------------------------------------------------------------------
; Additional implementation used by API macros
;-----------------------------------------------------------------------------
.segment "CODE"

screen_switch_to_user_fn:
        lda #($16 | ((screen_addr_native >> 2) & $80))
        sta viccr2   ;$9002 - number of columns, part of screen map addr.
        lda #($80 | ((screen_addr_native >> 6) & $70))
        sta viccr5   ;$9005 - screen map & character map address
.if CONFIG_ENABLE_COLOR
        lda save_color
        sta viccr_color
.endif ; CONFIG_ENABLE_COLOR
        rts

;-----------------------------------------------------------------------------
screen_switch_to_mon_fn:
        lda #($16 | ((screen_addr_mon >> 2) & $80))
        sta viccr2   ;$9002 - number of columns, part of screen map addr.
        lda #($80 | ((screen_addr_mon >> 6) & $70))
        sta viccr5   ;$9005 - screen map & character map address
.if CONFIG_ENABLE_COLOR
        lda viccr_color
        sta save_color
.if CONFIG_ENABLE_COLOREDIT_FONT
        lda color_bg
.else
        lda #color_bg
.endif ; CONFIG_ENABLE_COLOREDIT_FONT
screen_color_reg_write:
        sta viccr_color
.endif ; CONFIG_ENABLE_COLOR
        rts

;-----------------------------------------------------------------------------
.if CONFIG_ENABLE_COLOREDIT_BACKGROUND

;  viccr_color:
;  +---+---+---+---+---+---+---+---+
;  | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
;  +---+---+---+---+---+---+---+---+
;  | backgrnd col  | R | frame col |
;  +---+---+---+---+---+---+---+---+

screen_color_frame_cycle_fn:
        lda color_bg
        tax
        and #%11110000          ; Save background color bits.
        sta color_bg
        inx                     ; Increment frame color.
        txa
        and #%00000111          ; Mask out frame color bits.
        ora #%00001000          ; Set R(everse) bit.
        ora color_bg            ; Combine with background color.
        bne screen_color_commit ; BRA: Z is always 0 here.

screen_color_background_cycle_fn:
        lda color_bg
        clc
        adc #%00010000          ; Increment background color.
screen_color_commit:
        sta color_bg
        bne screen_color_reg_write ; BRA: Z is always 0 here.
.endif

;-----------------------------------------------------------------------------
; CLR / HOME
;-----------------------------------------------------------------------------
screen_clr_fn:
        lda #' '
        ldx #0
:
        sta screen_addr_mon,x
        sta screen_addr_mon+256,x
        inx
        bne :-
        jmp chrout_home
