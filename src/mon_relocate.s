;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.include "target.h"

.if CONFIG_INIT_RELOCATE_MONITOR

;-----------------------------------------------------------------------------
vec_src = $10
vec_dst = $12

;-----------------------------------------------------------------------------
; Size of the monitor code.
monitor_len       = (__ROM_LOAD__ + __ROM_SIZE__ - __INIT_LOAD__)

; Monitor target start and end address.
monitor_dst_start = (__INIT_LOAD__)
monitor_dst_end   = (__INIT_LOAD__ + monitor_len)

; Monitor source start and end address.
monitor_src_start = (__BASIC_HEADER_LOAD__ + __BASIC_HEADER_SIZE__)
monitor_src_end   = (monitor_src_start + monitor_len)

;-----------------------------------------------------------------------------
.segment "BASIC_HEADER"
mon_relocate:
        ; Disable interrupts while we copy the code around.
        sei

        ; Save the zeropage pointers we are going to use
        lda vec_src
        pha
        lda vec_src+1
        pha
        lda vec_dst
        pha
        lda vec_dst+1
        pha

        ; Relocate monitor.
        lda #<monitor_src_end
        sta vec_src
        lda #>monitor_src_end
        sta vec_src+1

        lda #<monitor_dst_end
        sta vec_dst
        lda #>monitor_dst_end
        sta vec_dst+1

        ldy #0
@copy_loop:
        lda (vec_src),y
        sta (vec_dst),y

        ; Decrement source vector.
        lda vec_src
        sec
        sbc #1
        sta vec_src
        lda vec_src+1
        sbc #0
        sta vec_src+1

        ; Decrement destination vector.
        lda vec_dst
        sec
        sbc #1
        sta vec_dst
        lda vec_dst+1
        sbc #0
        sta vec_dst+1

        ; Compare destination vector with monitor code start.
        lda vec_src+1
        cmp #>monitor_src_start
        bne @copy_loop

        lda vec_src
        cmp #<monitor_src_start
        bcs @copy_loop

        ; Restore zeropage pointers.
        pla
        sta vec_dst+1
        pla
        sta vec_dst
        pla
        sta vec_src+1
        pla
        sta vec_src

        ; Enable interrupts again and jump to monitor entry point.
        cli
        jmp __INIT_LOAD__

.endif ; CONFIG_INIT_RELOCATE_MONITOR
