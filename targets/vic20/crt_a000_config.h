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

CONFIG_SPLASH_SHOW_COPYRIGHT                    := 1

CONFIG_CARTRIDGE                                := 1
CONFIG_ROM_BUILD                                := 1

CONFIG_ENABLE_CURSOR_DISPLAY                    := 1

CONFIG_INIT_CLEAR_STACK                         := 1
CONFIG_HANDLE_BRK                               := 1
CONFIG_USE_BUILT_IN_KEYSCAN                     := 1
CONFIG_STACK_RESTORE                            := 1

CONFIG_KEY_HANDLER_HELP                         := 1
CONFIG_KEY_HANDLER_REG_SET                      := 1

CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS   := 1
CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS   := 1
CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR  := 1

CONFIG_KEY_HANDLER_SCREEN_SHOW                  := 1

CONFIG_KEY_HANDLER_MEM_TOGGLE                   := 1
CONFIG_KEY_HANDLER_MEM_EDIT                     := 1
CONFIG_KEY_HANDLER_MEM_FILL                     := 1
CONFIG_KEY_HANDLER_MEM_COPY                     := 1
