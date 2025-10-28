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
; BASIC loader for unexpanded VIC20.
;
; This is a pretty minimal configuration with most commands and features
; disable so vmon can fit into unexpanded BASIC memory.
;------------------------------------------------------------------------------
CONFIG_INIT_RELOCATE_BASIC_START                := 1
CONFIG_INIT_RELOCATE_BASIC_END                  := 1

CONFIG_EXAMPLE_CODE                             := 1

CONFIG_OPTIMIZE_MEM_SIZE                        := 1

CONFIG_ENABLE_COLOREDIT_FONT                    := 1
CONFIG_ENABLE_COLOR                             := 1

CONFIG_PRG_HEADER                               := 1
CONFIG_BASIC_SYS_LINE                           := 1
CONFIG_BASIC_SYS_ADDR                           := $100D

CONFIG_USE_BUILT_IN_KEYSCAN                     := 1
CONFIG_STACK_RESTORE                            := 1

CONFIG_KEY_HANDLER_REG_SET                      := 1

CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS   := 1

CONFIG_KEY_HANDLER_MEM_TOGGLE                   := 1
