;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Build configuration
;------------------------------------------------------------------------------
CONFIG_EXAMPLE_CODE                             := 1

CONFIG_ENABLE_COLOREDIT_FONT                    := 1
CONFIG_ENABLE_COLOR                             := 1

CONFIG_CARTRIDGE                                := 1
CONFIG_ROM_BUILD                                := 1
CONFIG_SPLASH_SHOW_COPYRIGHT                    := 1

CONFIG_SCREEN_ENABLE_CURSOR_DISPLAY             := 1

CONFIG_INIT_CLEAR_STACK                         := 1
CONFIG_HANDLE_BRK                               := 1
CONFIG_USE_BUILT_IN_KEYSCAN                     := 1
CONFIG_STACK_RESTORE                            := 1

CONFIG_KEY_HANDLER_HELP                         := 1
CONFIG_KEY_HANDLER_REG_SET                      := 1

CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS   := 1
CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS   := 1
CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR  := 1
CONFIG_KEY_HANDLER_RESUME_LAST_RUN_MODE         := 1

CONFIG_KEY_HANDLER_MEM_TOGGLE                   := 1
CONFIG_KEY_HANDLER_MEM_EDIT                     := 1

; Address of screen memory used by VMON.
; This value needs to be in the range between $0800 and $3c00
; in $0400 increments.
;
; Typically, there are three options:
;  1) Place screen at the beginning and move BASIC start
;  2) Place screen at the end and move BASIC end
;  3) Place screen anywhere if BASIC is no needed
CONFIG_MON_SCREEN_ADDR                          := $3c00

; Address for saving color RAM when switching between VMON
; and native screen.
; This is 1 KB of size and can placed anywhere in the address
; space where RAM is available.
CONFIG_COLOR_RAM_SAVE_ADDR                      := $4000
CONFIG_SAVE_COLOR_RAM                           := 1
