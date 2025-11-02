;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.include "screen.h"
.include "init_vars.h"
.include "io.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export mon_main_from_cartridge
.export mon_main_from_basic

.export mon_brk_entry

;------------------------------------------------------------------------------
.export vec_mon_exit

.export tmp_var_lo
.export tmp_var_hi

.export shared_tmp

;-----------------------------------------------------------------------------
; Variables
;-----------------------------------------------------------------------------
.segment "DATA"
; Global temps
tmp_var_lo:             .res 1
tmp_var_hi:             .res 1

shared_tmp:             .res 1 ; Globally available tmp variable

;-----------------------------------------------------------------------------
; To save original BASIC warm start vector. Called when monitor exits.
;-----------------------------------------------------------------------------
vec_mon_exit:           .res 2

;-----------------------------------------------------------------------------
; Monitor entry points
;-----------------------------------------------------------------------------
.segment "INIT"
mon_main_from_basic:
        sei
        lda io_vec_basic_warm_start
        sta vec_mon_exit
        lda io_vec_basic_warm_start+1
        sta vec_mon_exit+1

;-----------------------------------------------------------------------------
; BASIC relocation
;-----------------------------------------------------------------------------
.if CONFIG_INIT_RELOCATE_BASIC_START
        ; We only need to relocate the BASIC start if it is different from the
        ; requested relocation address.
        lda #>CONFIG_BASIC_START
        cmp basic_start_hi
        bne @do_relocate_basic_start
        lda #<CONFIG_BASIC_START+1
        cmp basic_start_lo
        beq @skip_relocate_basic_start

        lda #>CONFIG_BASIC_START
@do_relocate_basic_start:
        sta basic_start_hi
        lda #<CONFIG_BASIC_START+1
        sta basic_start_lo
.endif ; CONFIG_INIT_RELOCATE_BASIC_START

.if CONFIG_INIT_RELOCATE_BASIC_END  
@skip_relocate_basic_start:
        lda #>CONFIG_BASIC_END
        cmp basic_end_hi
        bne @do_relocate_basic_end
        lda #<CONFIG_BASIC_END
        cmp basic_end_lo
        beq @skip_relocate_basic_end
        
@do_relocate_basic_end:
        lda #>CONFIG_BASIC_END
        sta basic_end_hi
        lda #<CONFIG_BASIC_END
        sta basic_end_lo
.endif ; CONFIG_INIT_RELOCATE_BASIC_END

.if CONFIG_INIT_RELOCATE_BASIC_START || CONFIG_INIT_RELOCATE_BASIC_END
        ; Note:
        ;   jsr basic_new will reset the stack to $fc and discard the
        ;   return address of whoever called us.
        ;
        ; Zero flag must be set when calling basic_new, otherwise the
        ; call will return immediately.
        lda #0
.if CONFIG_INIT_RELOCATE_BASIC_START
        sta CONFIG_BASIC_START
.endif
        jsr basic_new
.if !CONFIG_INIT_RELOCATE_BASIC_END
@skip_relocate_basic_start:
.endif
@skip_relocate_basic_end:
.endif ; CONFIG_INIT_RELOCATE_BASIC_START || CONFIG_INIT_RELOCATE_BASIC_END

;-----------------------------------------------------------------------------
; Entry point for monitor when running from a ROM cartridge
;-----------------------------------------------------------------------------
mon_main_from_cartridge:

;-----------------------------------------------------------------------------
; Clear stack
;-----------------------------------------------------------------------------
.if CONFIG_INIT_CLEAR_STACK
        ; Clear "user" stack $180-$1ff
        lda #CONFIG_INIT_CLEAR_STACK_VALUE
        ldx #$7f
:
        sta $180,x
        dex
        bpl :-
.endif ; CONFIG_INIT_CLEAR_STACK

;-----------------------------------------------------------------------------
; Set BRK handler vector
;-----------------------------------------------------------------------------
.if CONFIG_HANDLE_BRK
        jsr brk_handler_init
.endif ; CONFIG_HANDLE_BRK

;-----------------------------------------------------------------------------
; Set up initialized variables
;-----------------------------------------------------------------------------
        ; Initialize variables
        setup_init_vars

;-----------------------------------------------------------------------------
; Monitor entry point for BRK instruction
;-----------------------------------------------------------------------------
; Entry for handling BRK instruction
mon_brk_entry:

        ; Set stack to $17f for monitor
        ldx #$7f
        txs

.if !CONFIG_USE_BUILT_IN_KEYSCAN
        ; If we do not use the built in keyscan, we need to rely on the
        ; interrupt driven system keyscan routines. Therefore, we need to
        ; enable interrupts here.
        cli
.endif ; !CONFIG_USE_BUILT_IN_KEYSCAN

;-----------------------------------------------------------------------------
; Screen initialization
;-----------------------------------------------------------------------------
        ; Init screen
        screen_init_target

        screen_switch_to_mon
        screen_clr
        ; Fall through

; NOTE:
;   We'll include the main_loop in the "INIT" segment. Otherwise we
;   would not be able to fall through and waste 3 bytes for a JMP.

;-----------------------------------------------------------------------------
; Main loop
;-----------------------------------------------------------------------------
main_loop:
        jsr screen_draw
        jsr key_handler_run
        jmp main_loop

;-----------------------------------------------------------------------------
; Dummy CODE_END segment
;
; This is used to determine the end of the monitor code for relocating
; BASIC memory if needed.
;-----------------------------------------------------------------------------
.segment "CODE_END"
