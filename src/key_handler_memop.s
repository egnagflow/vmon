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
.include "io.h"
.include "macros.h"

;-----------------------------------------------------------------------------
; Key command mapping table
;-----------------------------------------------------------------------------
.include "keymap.h"

add_key_handler KEY_SET_MEMORY_ADDRESS, handle_key_set_memory_address

.if CONFIG_KEY_HANDLER_MEM_EDIT
add_key_handler KEY_EDIT_MEMORY, handle_key_edit_memory
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
        lda #KEY_SET_MEMORY_ADDRESS
        jsr key_handler_read_hex16  ; Get address
        bcs rts_exit                ; Abort
        vec_set_ay mem_addr_lo

inc_mem_vec_wr:
        ; Instead of using this macro throughout the code below,
        ; we make it a call. This way we save 7 bytes.
        ;
        ; By placing it here we can also re-use the RTS. It won't
        ; have any effect on handle_key_set_memory_address.
        ;
        vec_inc mem_vec_wr_lo
rts_exit:
        rts

;------------------------------------------------------------------------------
; Edit memory
;------------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_MEM_EDIT
handle_key_edit_memory:
        lda #KEY_EDIT_MEMORY
        jsr key_handler_read_hex16  ; EDIT address
        bcs rts_exit                ; Abort

        vec_set_ay mem_vec_wr_lo
read_next_line:
        ; Number of bytes per edit line.
        lda #mem_dump_num_bytes
        sta gs_key_handler_memop

read_next_byte:
        jsr chrout_space
        jsr read_hex8       ; Value
        bcs rts_exit        ; Abort
        ldy #0
        jsr sta_mem_y
        jsr inc_mem_vec_wr

        dec gs_key_handler_memop
        bne read_next_byte

        ; The line is full. Redraw the screen so we can see the
        ; effects of the memory writes.
        jsr screen_draw

        ; Set cursor, color and print the next edit address.
        screen_cursor_pos_set 0,1

        chrout_set_color color_header
        lda #KEY_EDIT_MEMORY
        jsr chrout
        vec_get_ay mem_vec_wr_lo
        jsr print_hex16_ay

        jmp read_next_line
.endif ; CONFIG_KEY_HANDLER_MEM_EDIT

;-----------------------------------------------------------------------------
; FILL memory range
;-----------------------------------------------------------------------------
.if CONFIG_KEY_HANDLER_MEM_FILL
handle_key_fill_memory:
        lda #KEY_FILL_MEMORY
        jsr key_handler_read_hex16  ; START address
        bcs @abort                  ; Abort
        vec_set_ay mem_vec_wr_lo

        jsr chrout_space
        jsr read_hex16      ; END address
        bcs @abort          ; Abort
        vec_set_ay gs_key_handler_memop_vec

        jsr chrout_space
        jsr read_hex8       ; Value
        bcs @abort          ; Abort

@next_byte:
        ldy #0
        jsr sta_mem_y
        jsr inc_mem_vec_wr

        ; Check if we reached the end address
        pha
        vec_cmp gs_key_handler_memop_vec, mem_vec_wr_lo
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
        lda #KEY_COPY_MEMORY
        jsr key_handler_read_hex16  ; FROM START
        bcs @abort                  ; Abort
        vec_set_ay mem_vec_rd_lo

        jsr chrout_space
        jsr read_hex16      ; FROM END
        bcs @abort          ; Abort
        vec_set_ay gs_key_handler_memop_vec

        jsr chrout_space
        jsr read_hex16      ; TO
        bcs @abort          ; Abort
        vec_set_ay mem_vec_wr_lo

@next_byte:
        jsr lda_mem_y0
        jsr sta_mem_y

        vec_inc mem_vec_rd_lo
        jsr inc_mem_vec_wr

        ; Check if we reached the end address
        vec_cmp gs_key_handler_memop_vec, mem_vec_rd_lo
        bcs @next_byte
@abort:
        rts
.endif ; CONFIG_KEY_HANDLER_MEM_COPY
