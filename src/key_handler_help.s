;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"
.if CONFIG_KEY_HANDLER_HELP

.include "screen.h"
.include "io.h"

.include "key_handler.h"

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

;-----------------------------------------------------------------------------
add_key_handler KEY_HELP_SCREEN, handle_key_help_screen

;-----------------------------------------------------------------------------
; Helper macro for conditionally printing help based on feature definition and
; key mapping.
;-----------------------------------------------------------------------------
.macro print_help key, msg
    print_str_at xpos, 0, .concat(.sprintf("%c", key), ": ", msg)
    xpos .set xpos + 1
.endmacro

.macro print_help_ifdef cond, key, msg
.if cond
    print_help key, msg
.endif
.endmacro

;-----------------------------------------------------------------------------
; Print help screen
;-----------------------------------------------------------------------------
.segment "CODE"

handle_key_help_screen:
        screen_clr

        xpos .set 0
;-----------------------------------------------------------------------------
; Help for small screen sizes with less than 40 columns.
;-----------------------------------------------------------------------------
.if screen_size_y < 40
        print_str_at xpos, 2,                                                                           "*** VMON HELP ***"
        xpos .set xpos + 1
        print_help                                                       KEY_SET_PROGRAM_COUNTER,       "SET PC  (ADDR)"

        print_help                                                       KEY_SET_MEMORY_ADDRESS,        "SET MEM (ADDR)"
        print_help_ifdef CONFIG_KEY_HANDLER_REG_SET,                     KEY_SET_REGISTER_VALUE,        "SET REG (VAL)"

        print_help                                                       KEY_SINGLE_STEP_INTO,          "SINGLE STEP INTO"
        print_help                                                       KEY_SINGLE_STEP_OVER,          "SINGLE STEP OVER"
        print_help_ifdef CONFIG_KEY_HANDLER_SINGLE_STEP_INTO_UNTIL_RTS,  KEY_CONT_STEP_OVER_UNTIL_RTS,  "SSTP OVER UNTIL RTS"
        print_help_ifdef CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_RTS,  KEY_CONT_STEP_INTO_UNTIL_RTS,  "SSTP INTO UNTIL RTS"
        print_help_ifdef CONFIG_KEY_HANDLER_SINGLE_STEP_OVER_UNTIL_ADDR, KEY_CONT_STEP_OVER_UNTIL_ADDR, "SSTP OVER TO (ADDR)"
        print_help_ifdef CONFIG_KEY_HANDLER_RESUME_LAST_RUN_MODE,        KEY_RESME_LAST_RUN_MODE,       "RESUME EXECUTION"

        print_help_ifdef CONFIG_KEY_HANDLER_SCREEN_SHOW,                 KEY_SHOW_SCREEN,               "SHOW DEBUG SCREEN"

        print_help_ifdef CONFIG_KEY_HANDLER_MEM_TOGGLE,                  KEY_TOGGLE_MEMORY_DISPLAY,     "TOGGLE MEMORY SIZE"
        print_help                                                       KEY_MEMORY_SCROLL_UP,          "MEMORY SCROLL UP"
        print_help                                                       KEY_MEMORY_SCROLL_DOWN,        "MEMORY SCROLL DOWN"
        print_help                                                       KEY_MEMORY_PAGE_UP,            "MEMORY PAGE UP"
        print_help                                                       KEY_MEMORY_PAGE_DOWN,          "MEMORY PAGE DOWN"

        print_str_at xpos, 0,                                                                           "CRSR UP/DN: OPC UP/DN"

        xpos .set xpos + 1
        xpos .set xpos + 1
        print_help                                                       KEY_QUIT,                      "QUIT"
;-----------------------------------------------------------------------------
; Help for larger screens.
;-----------------------------------------------------------------------------
.else
        print_str_at xpos, 1, "VMON (C) 1986-2025 W.REISSNEGGER"
        xpos .set xpos + 1
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_SET_PROGRAM_COUNTER), " - SET PROGRAM COUNTER (ADDR)")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_SET_MEMORY_ADDRESS), " - SET MEMORY ADDRESS (ADDR)")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_SET_REGISTER_VALUE), " - SET REGISTER VALUE (VAL)")
        xpos .set xpos + 1
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_SINGLE_STEP_INTO), " - SINGLE STEP COMMAND - STEP INTO")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_SINGLE_STEP_OVER), " - SINGLE STEP COMMAND - STEP OVER")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_CONT_STEP_OVER_UNTIL_RTS), " - CONTINUE EXECUTION (X) UNTIL RTS")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_CONT_STEP_OVER_UNTIL_ADDR), " - CONTINUE EXECUTION (X) UNTIL (ADDR)")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_CONT_STEP_INTO_UNTIL_RTS), " - CONTINUE EXECUTION (S) UNTIL RTS")
        xpos .set xpos + 1
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_FILL_MEMORY), " - FILL MEMORY (FROM-TO-VAL)")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_COPY_MEMORY), " - COPY MEMORY (FROM-TO-DEST)")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_EDIT_MEMORY), " - EDIT MEMORY (ADDR-VAL-...)")
        xpos .set xpos + 1
        xpos .set xpos + 1
.if CONFIG_KEY_HANDLER_SCREEN_SHOW
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_SHOW_SCREEN), " - SHOW DEBUG SCREEN")
        xpos .set xpos + 1
.endif ; CONFIG_KEY_HANDLER_SCREEN_SHOW
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_TOGGLE_MEMORY_DISPLAY), " - TOGGLE MEMORY SIZE")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_MEMORY_SCROLL_UP), " - SCROLL UP MEMORY")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_MEMORY_SCROLL_DOWN), " - SCROLL DOWN MEMORY")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_MEMORY_PAGE_UP), " - PAGE UP MEMORY")
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_MEMORY_PAGE_DOWN), " - PAGE DOWN MEMORY")
        xpos .set xpos + 1
        xpos .set xpos + 1
        print_str_at xpos, 0, "CRSR UP/DN - SCROLL ASSEMBLY"
        xpos .set xpos + 1
        xpos .set xpos + 1
        print_str_at xpos, 0, .concat(.sprintf("%c", KEY_QUIT), " - QUIT")
.endif ; if screen_size_y < 40

        io_key_in_blocking
        rts

.endif ; CONFIG_KEY_HANDLER_HELP
