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
        .word cartridge_vec_start
        .word $fec7 ; ???
        .byte $c3, $c2, $cd, $38, $30

;-----------------------------------------------------------------------------
.segment "CODE"
cartridge_vec_start:
        jsr kernal_init_vic
        screen_init_target

; If dynamic color is configured we need to set color_bg,
; otherwise we get the wrong color scheme when calling
; screen_switch_to_mon
        setup_init_vars
        screen_clr
        screen_switch_to_mon

.if CONFIG_SPLASH_SHOW_COPYRIGHT
        xpos .set 3
        print_str_at xpos, 18, "VMON"
        xpos .set xpos + 1
        xpos .set xpos + 1
        print_str_at xpos, 14, "(C)1986-2025"
        xpos .set xpos + 1
        xpos .set xpos + 1
        print_str_at xpos, 10, "WOLFGANG REISSNEGGER"
.endif

        print_str_at 12, 10, "START MONITOR (Y/N)?"

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
        jsr kernal_init_io_devs
        jsr kernal_init_mem_vec
        jsr kernal_restore_io_vec
        jsr kernal_init_screen_kbd

.if CONFIG_HANDLE_BRK
        ; Set up the BRK handler so we enter
        ; VMON if a BRK instruction is executed.
        jsr brk_handler_init
.endif ; CONFIG_HANDLE_BRK

        cli
        jmp ($a000) ; BASIC

.endif ; CONFIG_CARTRIDGE
