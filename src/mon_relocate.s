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

.include "macros.h"

;-----------------------------------------------------------------------------
; Size of the monitor code.
monitor_len       = (__CODE_END_LOAD__ - __INIT_LOAD__)

; Monitor target start and end _run_ addresses.
monitor_dst_start = (__INIT_LOAD__)
monitor_dst_end   = (monitor_dst_start + monitor_len)

; Monitor source start and end _load_ address.
monitor_src_start = (__BASIC_HEADER_LOAD__ + __BASIC_HEADER_SIZE__)
monitor_src_end   = (monitor_src_start + monitor_len)

;-----------------------------------------------------------------------------
.segment "BASIC_HEADER"
mon_relocate:
        ; Relocate monitor - copying back to front.
        ;
        ; Note:
        ;   This code is known to always reside in RAM, so we can use
        ;   self-modifying code.
@copy_loop:
@rd:
        lda monitor_src_end
@wr:
        sta monitor_dst_end

        vec_dec @rd+1
        vec_dec @wr+1

        vec_cmp_i16 @rd+1, monitor_src_start
        bcs @copy_loop

        ; Jump to monitor entry point.
        jmp __INIT_LOAD__

.endif ; CONFIG_INIT_RELOCATE_MONITOR
