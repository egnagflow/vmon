;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; Helper macro to conditionally define default values.
;-----------------------------------------------------------------------------

; Default configuration, set option to 0.
.macro defcfg name
.ifndef name
name := 0
.endif
.endmacro

; Default configuration, set option to val.
.macro cfg name, val
.ifndef name
name := val
.endif
.endmacro

;-----------------------------------------------------------------------------
; VIC20 specific configuration
;-----------------------------------------------------------------------------
; Select NTSC vs PAL versions of the VIC20. This option is only required when
; building the cartridge versions of VMON as the cartridge will initialize the
; VIC chip rather than relying on the kernal ROM.
; Default is PAL if CONFIG_VIC20_NTSC is not set.
defcfg CONFIG_VIC20_NTSC

defcfg CONFIG_VIC20_RAM_EXPANSION

;-----------------------------------------------------------------------------
; Splash screen
;-----------------------------------------------------------------------------
defcfg CONFIG_SPLASH_SHOW_COPYRIGHT

;-----------------------------------------------------------------------------
; Memory size configuration & optimization
;-----------------------------------------------------------------------------
defcfg CONFIG_OPTIMIZE_MEM_SIZE

defcfg CONFIG_EXAMPLE_CODE
defcfg CONFIG_EXAMPLE_CODE_NOPS

;-----------------------------------------------------------------------------
; Screen configuration
;-----------------------------------------------------------------------------
defcfg CONFIG_ENABLE_COLOR
defcfg CONFIG_ENABLE_COLOREDIT_FONT
defcfg CONFIG_ENABLE_COLOREDIT_BACKGROUND
defcfg CONFIG_SCREEN_ENABLE_CURSOR_DISPLAY

;-----------------------------------------------------------------------------
; Build configuration
;-----------------------------------------------------------------------------
defcfg CONFIG_CARTRIDGE
defcfg CONFIG_ROM_BUILD

defcfg CONFIG_PRG_HEADER
defcfg CONFIG_BASIC_SYS_LINE
cfg    CONFIG_BASIC_SYS_ADDR        , $0000

;-----------------------------------------------------------------------------
; Features
;-----------------------------------------------------------------------------
defcfg CONFIG_HANDLE_BRK
defcfg CONFIG_USE_BUILT_IN_KEYSCAN

;-----------------------------------------------------------------------------
; Key Commands
;-----------------------------------------------------------------------------
defcfg CONFIG_KEY_HANDLER_SCREEN_SHOW

defcfg CONFIG_KEY_HANDLER_REG_SET

cfg CONFIG_KEY_HANDLER_GO, 1

defcfg CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS
defcfg CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS
defcfg CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR
defcfg CONFIG_KEY_HANDLER_RESUME_LAST_RUN_MODE

defcfg CONFIG_KEY_HANDLER_MEM_TOGGLE
defcfg CONFIG_KEY_HANDLER_MEM_EDIT
defcfg CONFIG_KEY_HANDLER_MEM_FILL
defcfg CONFIG_KEY_HANDLER_MEM_COPY

defcfg CONFIG_KEY_HANDLER_HELP

;-----------------------------------------------------------------------------
; Init
;-----------------------------------------------------------------------------
defcfg CONFIG_INIT_CLEAR_STACK
cfg    CONFIG_INIT_CLEAR_STACK_VALUE        , $00

defcfg CONFIG_INIT_RELOCATE_BASIC_START
defcfg CONFIG_INIT_RELOCATE_BASIC_END

defcfg CONFIG_STACK_RESTORE

defcfg CONFIG_INIT_RELOCATE_MONITOR
