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
; **** system vectors ****
;
brk_vector          = $316
;
; **** predefined labels ****
;
viccr_base          = $9000
viccr2              = $9002
viccr5              = $9005
viccr_color         = $900f

via1drb             = $9110
via1dra             = $9111
via1ddrb            = $9112
via1ddra            = $9113

via2drb             = $9120
via2dra             = $9121
via2ddrb            = $9122
via2ddra            = $9123
;
; **** external jumps ****
;
basic_new           = $c642
.if !CONFIG_USE_BUILT_IN_KEYSCAN
keyscan_key_poll    = $ffe4
.endif

io_vec_error_message        = $0300
io_vec_basic_warm_start     = $0302
io_vec_basic_token          = $0304
io_vec_print_token          = $0306
io_vec_start_new_basic_code = $0308

kernal_init_ram         = $fd8d
kernal_restore_io_vec   = $fd52
kernal_init_io          = $fdf9
kernal_init_hw          = $e518
kernal_init_vic         = $e5c3

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

;-----------------------------------------------------------------------------
; Screen definitions
;-----------------------------------------------------------------------------
.if CONFIG_ENABLE_COLOREDIT_FONT
color_bg_default        = color_code_ltyellow << 4 | $8 | color_code_purple
color_header_default    = color_code_black
color_opcodes_default   = color_code_red
color_memdump_default   = color_code_blue
.else
color_bg                = color_code_ltyellow << 4 | $8 | color_code_purple
color_header            = color_code_black
color_opcodes           = color_code_red
color_memdump           = color_code_blue
.endif

;-----------------------------------------------------------------------------
; Memory Expansion / Layout
;-----------------------------------------------------------------------------
.if CONFIG_VIC20_RAM_EXPANSION = 0 ; unexpanded
; $1000 - $1bff         ; BASIC RAM after RESET
; $1000 - CODE_END -1   ; VMON code when loaded as BASIC PRG
; CODE_END - $1bff      ; Relocated BASIC RAM
; $1c00 - $1dff         ; VMON screen
; $1e00 - $1fff         ; Native screen
; Screen/color memory addresses
screen_addr_native  = $1e00
color_addr_native   = $9600
screen_addr_mon     = $1c00
color_addr_mon      = $9400

CONFIG_BASIC_END    = $1c00

.elseif CONFIG_VIC20_RAM_EXPANSION = 3
; $0400 - $1bff         ; BASIC RAM after RESET
; $0400 - CODE_END -1   ; VMON code when loaded as BASIC PRG
; CODE_END - $1bff      ; Relocated BASIC RAM
; $1c00 - $1dff         ; VMON screen
; $1e00 - $1fff         ; Native screen
; Screen/color memory addresses
screen_addr_native  = $1e00
color_addr_native   = $9600
screen_addr_mon     = $1c00
color_addr_mon      = $9400

CONFIG_BASIC_END    = $1c00

.elseif CONFIG_VIC20_RAM_EXPANSION = 8
; $1000 - ...           ; Native BASIC RAM
; $1000 - $11ff         ; Native screen
; $1200 - $13ff         ; VMON screen
; $1400 - CODE_END -1   ; VMON code when loaded as BASIC PRG
; CODE_END - ...        ; Relocated BASIC RAM
; Screen/color memory addresses
screen_addr_native  = $1000
color_addr_native   = $9400
screen_addr_mon     = $1200
color_addr_mon      = $9600

CONFIG_BASIC_END    = $4000 ; Assume 8K, override in specific config

.else
.warning "Invalid memory size. CONFIG_VIC20_RAM_EXPANSION must be 0, 3 or 8"
.endif ; RAM configurations

.if CONFIG_INIT_RELOCATE_BASIC_START
CONFIG_BASIC_START  = __CODE_END_LOAD__
.endif
