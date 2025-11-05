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
.include "version.h"

;-----------------------------------------------------------------------------
; Public API
;-----------------------------------------------------------------------------
.export exec_cur_code_line
.export exec_custom_jsr_ay

;-----------------------------------------------------------------------------
; Initialized virtual registers
;-----------------------------------------------------------------------------
.export virt_reg_a
.export virt_reg_x
.export virt_reg_y
.export virt_reg_f
.export virt_reg_sp

; Virtual registers
decl_init_var virt_reg_a,  VERSION_MAJOR
decl_init_var virt_reg_x,  VERSION_MINOR
decl_init_var virt_reg_y,  VERSION_PATCH
decl_init_var virt_reg_f,  $00
decl_init_var virt_reg_sp, $fd

;------------------------------------------------------------------------------
.segment "CODE"

;-----------------------------------------------------------------------------
; Opcode execution
;-----------------------------------------------------------------------------
exec_handle_jmp:
        ; Assumption:
        ;   Y is always 0 when we get here when
        ;   called from exec_cur_code_line.
        iny
        jsr lda_pc_y    ; Low byte of JMP address.
        tax
        iny
        jsr lda_pc_y    ; High byte of JMP address.
        sta pc_hi
        stx pc_lo
        rts

;-----------------------------------------------------------------------------
exec_handle_jmp_ind:
        ; Assumption:
        ;   Y is always 0 when we get here when
        ;   called from exec_cur_code_line.
        iny
        jsr lda_pc_y    ; Low byte of indirect vector.
        sta mem_vec_rd_lo
        iny
        jsr lda_pc_y    ; High byte of indirect vector.
        sta mem_vec_rd_hi
        jsr lda_mem_y0  ; Note, this will set Y to 0.
        sta pc_lo
        iny
        jsr lda_mem_y
        sta pc_hi
        rts

;-----------------------------------------------------------------------------
exec_handle_jsr:
        ldy virt_reg_sp
        dey
        lda pc_lo
        clc
        adc #$02
        sta $100,y
        lda pc_hi
        adc #0
        sta $101,y
        dey
        sty virt_reg_sp

        ldy #1
        jsr lda_pc_y
        tax
        iny
        jsr lda_pc_y
        sta pc_hi
        stx pc_lo
        rts

;-----------------------------------------------------------------------------
exec_handle_rts:
        ldy virt_reg_sp
        iny
        lda $100,y
        sta pc_lo
        lda $101,y
        sta pc_hi
        iny
        sty virt_reg_sp
        jmp pc_inc

;-----------------------------------------------------------------------------
exec_cur_code_line:
        ; JMP abs, JMP (ind) and RTS will be handled in their respective
        ; handlers, regardless of STEP_INTO vs STEP_OVER.
        jsr lda_pc_y0
        cmp #$4c                ; JMP abs
        beq exec_handle_jmp

        cmp #$6c                ; JMP (ind)
        beq exec_handle_jmp_ind

        cmp #$60                ; RTS
        beq exec_handle_rts

        tay                     ; Save opcode to Y for later.
        and #$0f                ; Check if it is a branch instruction.
        bne exec_inline         ; No, do regular execute.

        ; If we get here we have either a branch instruction or a JSR.
        ;
        ; tmp_var_lo is being set to either $20 (STEP_INTO was pressed) or $4c
        ; (STEP_OVER was pressed) by the calling code.
        ;
        ; If 'STEP_OVER' was pressed and the opcode is JSR ($20) then the cpy
        ; below will be true and JSR calls will be executed inline.
        ;
        ; If 'STEP_INTO' was pressed and the opcode is JSR ($20) then the cpy
        ; below will be false and the JSR instruction will be handled in the
        ; exec_handle_jsr call.
        ;
        cpy tmp_var_lo          ; Execute JSR?
        bne exec_single_step    ; No, single-step

        screen_switch_to_user   ; Yes, switch screen and
        jmp exec_inline         ; execute JSR inline.

exec_single_step:
        cpy #$20
        beq exec_handle_jsr

        tya                     ; opcode -> A.
        and #%00010000          ; Branches have bit 4 set.
        beq exec_inline         ; Not a branch.

        ; If we get here we have a branch instruction.
        tya                     ; opcode -> A.
        lsr
        lsr
        lsr
        lsr
        lsr

        ; At this point A contains the opcode >> 5.
        ; Hence BPL=0, BMI=1, BVC=2, BVS=3...
        tay
        and #1 ; result 0 == branch if clear, 1 == branch if set.
        php
        tya
        lsr
        tay
        lda virt_reg_f
        and branch_mask_table,y
        bne flag_is_set

        ; Flag is clear
        plp
        beq exec_branch_adj_pc
        jmp pc_inc_by_2

exec_branch_adj_pc:
        ldy #$01            ; Compute the new address based on the
        jsr lda_pc_y        ; branch offset and set the PC.
        jsr get_rel_pc_addr_ay
        sta pc_hi
        sty pc_lo
        rts

;-----------------------------------------------------------------------------
.segment "ROM"
branch_mask_table:  ; b=0  b=1
        .byte $80   ; BPL, BMI
        .byte $40   ; BVC, BVS
        .byte $01   ; BCC, BCS
        .byte $02   ; BNE, BEQ

;-----------------------------------------------------------------------------
.segment "CODE"
        ; Flag is set
flag_is_set:
        plp
        bne exec_branch_adj_pc
        ; Fall through

exec_inline:
        jsr lda_pc_y0
        pha             ; Remember opcode for monitor switch test later.
        jsr opcode_len
        tay
        tax             ; Remember opcode len for pc_add below.

        ; HACK for now put NOPs in case we need them.
        lda #$ea
        sta exec_buf_opcode+1
        sta exec_buf_opcode+2

        ; Put opcode to be executed into exec buffer.
        dey
copy:
        jsr lda_pc_y
        sta exec_buf_opcode,y
        dey
        bpl copy
        iny             ; Set Y=0.

        txa             ; Opcode len in X.
        jsr pc_add      ; Adjust PC to after current opcode.

do_exec_custom_inline:
.if CONFIG_STACK_RESTORE
        ; Save the stack bytes around SP. These bytes may be
        ; overwritten by the pha/plp - php/pla combination below. We want
        ; to preserve these bytes and restore them after we emulated the
        ; instruction so from the user's point of view these bytes never
        ; changed.
        ;
        ; Fb = Flags before emulated instruction.
        ; Fa = Flags after  emulated instruction.
        ; SP = User Stack Pointer.
        ; vv = User Stack Pointer -1 _before_ execution.
        ;
        ; Note:
        ;   Decrementing the current stack pointer makes the comparison
        ;   after the execution of the opcode simpler as we only need to
        ;   compare for 'new SP >= vv' (C=1)  to determine if it was a
        ;   push and we need to leave byte 55 alone.
        ;
        ; Initial state      vv
        ;           11 22 33 44 55 66 77 88 99
        ;                       SP
        ;
        ; 1) NOP             vv
        ;           11 22 33 44 Fa 66 77 88 99
        ;                       SP
        ;
        ; 2) PHx val=AA      vv
        ;           11 22 33 Fa AA 66 77 88 99
        ;                    SP
        ;
        ; 3) PLx val=66      vv
        ;           11 22 33 44 Fb Fa 77 88 99
        ;                          SP
        ldx virt_reg_sp
        dex             ; SP--
        lda $0100,x     ; Save stack byte 44
        pha
        lda $0101,x     ; Save stack byte 55
        pha
        lda $0102,x     ; Save stack byte 66
        pha
        txa             ; Save original user SP-1 (vv)
        pha
.endif ; CONFIG_STACK_RESTORE

        tsx             ; Save monitor's SP
        stx tmp_var_lo

        ; Load up emulated registers
        ldx virt_reg_sp
        txs
        lda virt_reg_f
        pha
        lda virt_reg_a
        ldx virt_reg_x
        ldy virt_reg_y
        jmp exec_buf_plp

        ; Opcode execution trampoline.
        ; Space for PLP, up to 3 byte opcode, PHP, SEI and JMP-back
        ; instruction.
decl_init_var exec_buf_plp,     $28        ; Load emulated flags
decl_init_var exec_buf_opcode,  $ea        ; Opcode to execute
decl_init_var exec_buf_opcode1, $ea        ;         "
decl_init_var exec_buf_opcode2, $ea        ;         "
decl_init_var exec_buf_php,     $08        ; Save emulated flags
decl_init_var exec_buf_sei,     $78        ; Disable IRQ again, in case we executed a CLI
decl_init_var exec_buf_jmp,     $4c        ; Jump back to opcode handler
decl_init_var exec_buf_jmp1,    <exec_cont ;         "
decl_init_var exec_buf_jmp2,    >exec_cont ;         "

.segment "CODE"
exec_cont:
        ; Save emulated registers.
        sta virt_reg_a
        stx virt_reg_x
        sty virt_reg_y
        pla
        sta virt_reg_f
        tsx
        stx virt_reg_sp

        ; Restore monitor's SP.
        ldx tmp_var_lo
        txs

.if CONFIG_STACK_RESTORE
        ; Restore the saved stack byte(s).
        ; We always restore byte 44 and byte 66. If it was a PHx
        ; instruction then SP == vv and we don't restore byt 55.
        pla             ; Original user SP-1 (vv).
        tax
        cmp virt_reg_sp ; New SP == vv? -> Case 2) -> C=1.

        pla             ; Original byte 66.
        sta $0102,x
        pla             ; Original byte 55.
        bcs no_inc      ; It was a push, skip restoring byte 55
        sta $0101,x
no_inc:
        pla             ; Original byte 44.
        sta $0100,x
.endif ; CONFIG_STACK_RESTORE

        ; At this time we may need to switch back the screen
        ; if we executed a JSR.
        pla             ; Get saved opcode.
        cmp #$20
        bne no_set_mon
        screen_switch_to_mon
no_set_mon:
        rts

;-----------------------------------------------------------------------------
exec_custom_jsr_ay:
        sty exec_buf_opcode+1
        sta exec_buf_opcode+2
        screen_switch_to_user
        lda #$20
        pha
        sta exec_buf_opcode
        bne do_exec_custom_inline   ; BRA
