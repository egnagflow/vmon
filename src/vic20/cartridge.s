;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"
.include "io.h"
.include "init_vars.h"

.if CONFIG_CARTRIDGE

.segment "CARTRIDGE_HEADER"
        .word vec_start
        .word $fec7
        .byte $41, $30, $c3, $c2, $cd

;-----------------------------------------------------------------------------
; PAL and NTSC versions of the VIC20 require different initialization of the
; VIC chip and therefore have different kernal ROMs.
;-----------------------------------------------------------------------------
.segment "ROM"
vic_video_init_tab:
.if CONFIG_VIC20_NTSC
        ; Init table copied from NTSC kernal ROM (901486-06) at $EDE4.
        .byte $05, $19, $16, $2e, $00, $c0, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $1b
.else ; PAL version
        ; Init table copied from PAL kernal ROM (901486-07) at $EDE4.
        .byte $0c, $26, $16, $2e, $00, $c0, $00, $00
        .byte $00, $00, $00, $00, $00, $00, $00, $1b
.endif

;-----------------------------------------------------------------------------
.segment "CODE"

vec_start:
        ; Initialize the video chip. This code has been copied
        ; from the kernal ROM at $E5C3.
        ldx #$10
@copy_vic_regs:
        lda vic_video_init_tab-1,x
        sta viccr_base-1,x
        dex
        bne @copy_vic_regs

; If dynamic color is configured we need to set color_bg,
; otherwise we get the wrong color scheme when calling
; screen_switch_to_mon
        screen_init_target
        setup_init_vars
        screen_clr
        screen_switch_to_mon

        ; Print splash screen.
        chrout_set_color 0  ; Black.
.if CONFIG_SPLASH_SHOW_COPYRIGHT
        xpos .set 3
        print_str_at xpos, 9, "VMON"
        xpos .set xpos + 1
        xpos .set xpos + 1
        print_str_at xpos, 5, "(C)1986-2025"
        xpos .set xpos + 1
        xpos .set xpos + 1
        print_str_at xpos, 1, "WOLFGANG REISSNEGGER"
.endif
        print_str_at 11, 1, "START MONITOR (Y/N)?"

        ; Wait for "Y" or "N" key
wait_for_yn:
        io_key_in_blocking
        cmp #'Y'
        bne check_n

        ; "Y" key pressed, set up the QUIT vector
        ; "RESET" so we will cleanly exit VMON
        ; later.
        lda #<cartridge_quit
        sta vec_mon_exit
        lda #>cartridge_quit
        sta vec_mon_exit+1

        jmp mon_main_from_cartridge

        ; Check for "N" key
check_n:
        cmp #'N'
        bne wait_for_yn

        ; "N" key pressed.
        ; Regular boot or QUIT from VMON
        ; after it has been started at boot
cartridge_quit:
        ; This code is identical to the ROM RESET code.
        ; We can't jump there directly, though, as
        ; we need to set up the BRK handler after
        ; the IO vectors have been initialized.
        sei
        jsr kernal_init_ram
        jsr kernal_restore_io_vec
        jsr kernal_init_io
        jsr kernal_init_hw

.if CONFIG_HANDLE_BRK
        ; Set up the BRK handler so we enter
        ; VMON if a BRK instruction is executed.
        jsr brk_handler_init
.endif ; CONFIG_HANDLE_BRK

        cli
        jmp ($c000) ; BASIC

.endif ; CONFIG_CARTRIDGE
