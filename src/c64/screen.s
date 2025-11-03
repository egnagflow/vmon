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

.export screen_switch_to_mon_fn
.export screen_switch_to_user_fn
.export screen_cursor_pos_set_xy_fn

;-----------------------------------------------------------------------------
; Screen header
;-----------------------------------------------------------------------------
.segment "ROM"
screen_header:  .byte $13
.if CONFIG_OPTIMIZE_MEM_SIZE
        .byte ":",$80|39," "
        .byte "A:",$1d,$1d,$80|29," SP:01",$80|2,$1d
        .byte "X:",$1d,$1d,$80|11,' ',$80|8,$1d,$80|10," PC:",$80|4,$1d
        .byte "Y:",$1d,$1d,$80|11," NV-BDIZC",$80|11," F:",$80|4,$1d,$00
.else
        .byte ":                                       "
        .byte "A:",$1d,$1d,"                             SP:01",$1d,$1d
        .byte "X:",$1d,$1d,"           ",$1d,$1d,$1d,$1d,$1d,$1d,$1d,$1d,"          PC:",$1d,$1d,$1d,$1d
        .byte "Y:",$1d,$1d,"           NV-BDIZC","           F:",$1d,$1d,$1d,$1d,$00
.endif

;-----------------------------------------------------------------------------
; Font color editing
;-----------------------------------------------------------------------------
.if CONFIG_ENABLE_COLOREDIT_FONT

; Border and background colors
decl_init_var color_frame, color_frame_default
decl_init_var color_bg, color_bg_default

.endif ; CONFIG_ENABLE_COLOREDIT_FONT

;-----------------------------------------------------------------------------
; Frame and background colors
;-----------------------------------------------------------------------------
.if CONFIG_ENABLE_COLOR
.segment "DATA"
save_color_frame:   .res 1
save_color_bg:      .res 1
.endif ; CONFIG_ENABLE_COLOR

;-----------------------------------------------------------------------------
; Additional implementation used by API macros
;-----------------------------------------------------------------------------
.segment "CODE"

screen_switch_to_user_fn:
        lda #(<((screen_addr_native & $3c00) >> 6)) | $05
        sta viccr_screen_addr

.if CONFIG_ENABLE_COLOR
        lda save_color_frame
        sta viccr_color_frame
        lda save_color_bg
        sta viccr_color_bg
.if CONFIG_SAVE_COLOR_RAM
        ldx #0
:       lda color_ram_save_addr,x
        sta color_ram_addr,x
        lda color_ram_save_addr+$100,x
        sta color_ram_addr+$100,x
        lda color_ram_save_addr+$200,x
        sta color_ram_addr+$200,x
        lda color_ram_save_addr+$300,x
        sta color_ram_addr+$300,x
        inx
        bne :-
.endif ; CONFIG_SAVE_COLOR_RAM
.endif ; CONFIG_ENABLE_COLOR
        rts

;-----------------------------------------------------------------------------
screen_switch_to_mon_fn:
        lda #(<((screen_addr_mon & $3c00) >> 6)) | $05
        sta viccr_screen_addr

.if CONFIG_ENABLE_COLOR
        lda viccr_color_frame
        sta save_color_frame
        lda viccr_color_bg
        sta save_color_bg
.if CONFIG_ENABLE_COLOREDIT_FONT
        lda color_frame
.else
        lda #color_frame
.endif ; CONFIG_ENABLE_COLOREDIT_FONT
        sta viccr_color_frame
.if CONFIG_ENABLE_COLOREDIT_FONT
        lda color_bg
.else
        lda #color_bg
.endif ; CONFIG_ENABLE_COLOREDIT_FONT
        sta viccr_color_bg

.if CONFIG_SAVE_COLOR_RAM
        ldx #0
:       lda color_ram_addr,x
        sta color_ram_save_addr,x
        lda color_ram_addr+$100,x
        sta color_ram_save_addr+$100,x
        lda color_ram_addr+$200,x
        sta color_ram_save_addr+$200,x
        lda color_ram_addr+$300,x
        sta color_ram_save_addr+$300,x
        inx
        bne :-
.endif ; CONFIG_SAVE_COLOR_RAM
.endif ; CONFIG_ENABLE_COLOR
        rts

;-----------------------------------------------------------------------------
; CLR / HOME
;-----------------------------------------------------------------------------
screen_clr_fn:
        lda #' '
        ldx #0
:       sta screen_addr_mon,x
        sta screen_addr_mon+$100,x
        sta screen_addr_mon+$200,x
        sta screen_addr_mon+$300,x
        inx
        bne :-
        jmp chrout_home

;-----------------------------------------------------------------------------
; Cursor handling
;-----------------------------------------------------------------------------
screen_cursor_pos_set_xy_fn:
        txa
        stx screen_vec_wr_lo
        ldx #0
        stx screen_vec_wr_hi

        ldx #5 ; X*32
@mul_32:
        asl screen_vec_wr_lo
        rol screen_vec_wr_hi
        dex
        bne @mul_32

@plus_8x:
        asl
        asl
        asl
        vec_add_a screen_vec_wr_lo

        ; Add Y offset to result.
        tya
        vec_add_a screen_vec_wr_lo

        ; Set screen memory base address.
        vec_add_i16 screen_vec_wr_lo, screen_addr_mon
        rts
