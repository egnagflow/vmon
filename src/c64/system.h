;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Key Code definitions for emulator
;-----------------------------------------------------------------------------
key_code_crsr_up    = $91
key_code_crsr_dn    = $11
key_code_crsr_lt    = $9d
key_code_crsr_rt    = $1d
key_code_esc        = $03
key_code_backspace  = $14

;
; **** zp absolute adresses ****
;
basic_start_lo      = $2b
basic_start_hi      = $2c
basic_end_lo        = $37
basic_end_hi        = $38
insert_key_counter  = $d3
num_keys_in_buf     = $d6

zp_user1_lo         = $fb
zp_user1_hi         = $fc
zp_user2_lo         = $fd
zp_user2_hi         = $fe
;
; **** pointers ****
;
color_addr_mon      = color_ram_addr
color_ram_addr      = $d800
color_ram_save_addr = CONFIG_COLOR_RAM_SAVE_ADDR
;
; **** predefined labels ****
;
viccr_screen_addr   = $d018
viccr_color_frame   = $d020
viccr_color_bg      = $d021

cia1drb             = $dc00
cia1dra             = $dc01
cia1ddrb            = $dc02
cia1ddra            = $dc03

cia2drb             = $dd00
cia2dra             = $dd01
cia2ddrb            = $dd02
cia2ddra            = $dd03
;
; **** external jumps ****
;
basic_new           = $a642

.if !CONFIG_USE_BUILT_IN_KEYSCAN
keyscan_key_poll    = $ffe4
.endif

io_vec_error_message        = $0300
io_vec_basic_warm_start     = $0302
io_vec_basic_token          = $0304
io_vec_print_token          = $0306
io_vec_start_new_basic_code = $0308

kernal_init_vic             = $e5a0

kernal_init_io_devs         = $fda3
kernal_init_mem_vec         = $fd50
kernal_restore_io_vec       = $fd15
kernal_init_screen_kbd      = $ff5b
;
; **** system vectors ****
;
brk_vector                  = $316

;-----------------------------------------------------------------------------
; Color codes
;-----------------------------------------------------------------------------
color_code_black    = 0
color_code_white    = 1
color_code_red      = 2
color_code_cyan     = 3
color_code_purple   = 4
color_code_green    = 5
color_code_blue     = 6
color_code_yellow   = 7
color_code_orange   = 8
color_code_ltorange = 9
color_code_pink     = 10
color_code_ltcyan   = 11
color_code_ltpurple = 12
color_code_ltgreen  = 13
color_code_ltblue   = 14
color_code_ltyellow = 15

.if CONFIG_ENABLE_COLOREDIT_FONT
color_frame_default     = color_code_purple
color_bg_default        = color_code_yellow
color_header_default    = color_code_black
color_opcodes_default   = color_code_red
color_memdump_default   = color_code_blue
.else
color_frame             = color_code_purple
color_bg                = color_code_yellow
color_header            = color_code_black
color_opcodes           = color_code_red
color_memdump           = color_code_blue
.endif

screen_addr_mon     = CONFIG_MON_SCREEN_ADDR
screen_addr_native  = $0400
