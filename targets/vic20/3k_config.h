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
;
; BASIC loader for VIC20 with 3k RAM expansion.
;------------------------------------------------------------------------------
CONFIG_VIC20_RAM_EXPANSION                      := 3 ; 3k RAM expansion
CONFIG_INIT_RELOCATE_BASIC_START                := 1
CONFIG_INIT_RELOCATE_BASIC_END                  := 1

CONFIG_EXAMPLE_CODE                             := 1

CONFIG_OPTIMIZE_MEM_SIZE                        := 1

CONFIG_ENABLE_COLOR                             := 1
CONFIG_ENABLE_COLOREDIT_FONT                    := 1
CONFIG_ENABLE_COLOREDIT_BACKGROUND              := 1
CONFIG_ENABLE_CURSOR_DISPLAY                    := 1

CONFIG_PRG_HEADER                               := 1
CONFIG_BASIC_SYS_LINE                           := 1
CONFIG_BASIC_SYS_ADDR                           := $40D

CONFIG_HANDLE_BRK                               := 1
CONFIG_USE_BUILT_IN_KEYSCAN                     := 1
CONFIG_STACK_RESTORE                            := 1

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
