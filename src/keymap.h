;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

; Show help screen
KEY_HELP_SCREEN='H'

; Toggle the memory hexdump between bottom display and
; full screen
KEY_TOGGLE_MEMORY_DISPLAY='T'

; Set the address of the program counter (PC).
KEY_SET_PROGRAM_COUNTER='P'

; Set the address of the memory hexdump
KEY_SET_MEMORY_ADDRESS='M'

; Set the value of a register
KEY_SET_REGISTER_VALUE='R'

; Single step instruction into subroutines
KEY_SINGLE_STEP_INTO='S'

; Single step over instruction (call subroutine, don't step
; into it)
KEY_SINGLE_STEP_OVER='N'

; Continue execution until RTS is encountered. Execute using
; the "single step over" method
KEY_CONT_STEP_OVER_UNTIL_RTS='C'

; Continue execution until address
KEY_CONT_STEP_OVER_UNTIL_ADDR='U'

; Continue step over execution until RTS
KEY_CONT_STEP_INTO_UNTIL_RTS='I'

; Fill memory
KEY_FILL_MEMORY='F'

; Copy memory
KEY_COPY_MEMORY='Y'

; Edit memory
KEY_EDIT_MEMORY='E'

; Edit memory inline
KEY_EDIT_MEMORY_INLINE='D'

; Show the user screen
KEY_SHOW_SCREEN='B'

; Scroll up memory display one line
KEY_MEMORY_SCROLL_UP=','

; Page up memory display
KEY_MEMORY_PAGE_UP='<'

; Scroll down memory display one line
KEY_MEMORY_SCROLL_DOWN='.'

; Page down memory display
KEY_MEMORY_PAGE_DOWN='>'

; Scroll up disassembly display one line
KEY_DISASS_SCROLL_UP=key_code_crsr_up

; Scroll down disassembly display one line
KEY_DISASS_SCROLL_DOWN=key_code_crsr_dn

; Quit the monitor
KEY_QUIT='Q'

; Pause / abort execution
KEY_PAUSE_ABORT=' '

; Change colors
KEY_COLOR_CHANGE_REGISTERS='1'
KEY_COLOR_CHANGE_DISASSEM='2'
KEY_COLOR_CHANGE_MEMDUMP='3'
