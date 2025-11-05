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
CONFIG_INIT_RELOCATE_MONITOR                    := 1
CONFIG_INIT_RELOCATE_BASIC_START                := 1

CONFIG_OPTIMIZE_MEM_SIZE                        := 1

CONFIG_EXAMPLE_CODE                             := 1

CONFIG_ENABLE_COLOR                             := 1
CONFIG_ENABLE_COLOREDIT_FONT                    := 1
CONFIG_ENABLE_CURSOR_DISPLAY                    := 1

CONFIG_PRG_HEADER                               := 1
CONFIG_BASIC_SYS_LINE                           := 1
CONFIG_BASIC_SYS_ADDR                           := $080D
CONFIG_BASIC_START                              := $1000
CONFIG_BASIC_END                                := $A000

CONFIG_HANDLE_BRK                               := 1
CONFIG_USE_BUILT_IN_KEYSCAN                     := 1
CONFIG_STACK_RESTORE                            := 1

CONFIG_KEY_HANDLER_HELP                         := 1

CONFIG_KEY_HANDLER_SCREEN_SHOW                  := 1

CONFIG_KEY_HANDLER_REG_SET                      := 1

CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS   := 1
CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS   := 1
CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR  := 1
CONFIG_KEY_HANDLER_RESUME_LAST_RUN_MODE         := 1

CONFIG_KEY_HANDLER_MEM_TOGGLE                   := 1
CONFIG_KEY_HANDLER_MEM_EDIT                     := 1
CONFIG_KEY_HANDLER_MEM_FILL                     := 1
CONFIG_KEY_HANDLER_MEM_COPY                     := 1

; Address of screen memory used by the monitor.
; This value needs to be in the range between $0800 and $3c00
; in $0400 increments.
;
; Typically, there are three options:
;  1) Place screen at the beginning and move BASIC start
;  2) Place screen at the end and move BASIC end
;  3) Place screen anywhere if BASIC is no needed
CONFIG_MON_SCREEN_ADDR                          := $0800

; Address for saving color RAM when switching between monitor
; and native screen.
; This is 1 KB of size and can placed anywhere in the address
; space where RAM is available.
CONFIG_COLOR_RAM_SAVE_ADDR                      := $0C00
CONFIG_SAVE_COLOR_RAM                           := 1
