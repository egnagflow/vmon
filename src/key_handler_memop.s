;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"
.include "key_handler.h"
.include "screen.h"
.include "mem_access.h"
.include "io.h"

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

add_key_handler KEY_SET_MEMORY_ADDRESS, handle_key_set_memory_address

.if CONFIG_KEY_HANDLER_MEM_EDIT
add_key_handler KEY_EDIT_MEMORY, handle_key_edit_memory
.endif

.if CONFIG_KEY_HANDLER_MEM_EDIT_INLINE
add_key_handler KEY_EDIT_MEMORY_INLINE, handle_key_edit_memory_inline
.endif

.if CONFIG_KEY_HANDLER_MEM_FILL
add_key_handler KEY_FILL_MEMORY, handle_key_fill_memory
.endif

.if CONFIG_KEY_HANDLER_MEM_COPY
add_key_handler KEY_COPY_MEMORY, handle_key_copy_memory
.endif

;-----------------------------------------------------------------------------
.segment "CODE"

;------------------------------------------------------------------------------
; Set memory address
;------------------------------------------------------------------------------
handle_key_set_memory_address:
        screen_cursor_pos_set 0,1
        lda #KEY_SET_MEMORY_ADDRESS
        jsr chrout
        jsr read_hex16
        bcs rts_exit        ; Abort
        sta mem_addr_hi
        sty mem_addr_lo
rts_exit:
        rts

;------------------------------------------------------------------------------
; Edit memory inline
;------------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_MEM_EDIT_INLINE
handle_key_edit_memory_inline:
        lda #screen_size_x
        sec
        sbc num_mem_lines
        tax
        ldy #5
        screen_cursor_pos_set_xy

        lda mem_addr_hi
        ldy mem_addr_lo
        stay_mem_wr_vec
@next_byte:
        jsr read_hex8
        bcs rts_exit
        ldy #$00
        jsr sta_mem_y
        inc_mem_wr_vec
        jsr chrout_space
        jmp @next_byte
.endif

;------------------------------------------------------------------------------
; Edit memory
;------------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_MEM_EDIT
handle_key_edit_memory:
        screen_cursor_pos_set 0,1
        lda #KEY_EDIT_MEMORY
        jsr chrout
        jsr read_hex16
        bcs rts_exit        ; Abort
        stay_mem_wr_vec
read_next_byte:
        jsr chrout_space
        jsr read_hex8
        bcs rts_exit        ; Abort
        ldy #$00
        jsr sta_mem_y
        inc_mem_wr_vec

wait_key:
        io_key_in_poll
        cmp #$00
        beq wait_key
        cmp #$0d
        beq rts_exit
        cmp #':'
        bne read_next_byte

        jsr screen_draw
        screen_cursor_pos_set 0,1
        lday_mem_wr_vec
        jsr print_hex16_ay
        jmp read_next_byte
.endif ; CONFIG_KEY_HANDLER_MEM_EDIT

;-----------------------------------------------------------------------------
; FILL memory range
;-----------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_MEM_FILL
handle_key_fill_memory:
        screen_cursor_pos_set 0,1
        lda #KEY_FILL_MEMORY
        jsr chrout
        jsr read_hex16
        bcs @abort  ; Abort
        stay_mem_wr_vec
        jsr chrout_space
        jsr read_hex16
        bcs @abort  ; Abort
        sta tmp_var_hi
        sty tmp_var_lo
        jsr chrout_space
        jsr read_hex8
        bcs @abort  ; Abort

@next_byte:
        ldy #0
        jsr sta_mem_y
        inc_mem_wr_vec

        ; Check if we reached the target address
        pha
        lda tmp_var_lo
        ldy tmp_var_hi
        cmpya_mem_wr_vec
        pla
        bcs @next_byte
@abort:
        rts
.endif ; CONFIG_KEY_HANDLER_MEM_FILL

;-----------------------------------------------------------------------------
; copY memory
;-----------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_MEM_COPY
handle_key_copy_memory:
        screen_cursor_pos_set 0,1
        lda #KEY_COPY_MEMORY
        jsr chrout
        stay_mem_rd_vec
        jsr read_hex16      ; FROM START
        bcs @abort          ; Abort

        jsr chrout_space
        jsr read_hex16      ; FROM END
        bcs @abort          ; Abort
        sta tmp_var_hi
        sty tmp_var_lo

        jsr chrout_space
        jsr read_hex16      ; TO
        bcs @abort          ; Abort

@next_byte:
        jsr lda_mem_y0
        jsr sta_mem_y

        inc_mem_rd_vec
        inc_mem_wr_vec

        ; Check if we reached the end address
        ldy tmp_var_hi
        lda tmp_var_lo
        cmpya_mem_rd_vec
        bcs @next_byte
@abort:
        rts
.endif ; CONFIG_KEY_HANDLER_MEM_COPY
