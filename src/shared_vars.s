;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
; Globally shared variables.
;-----------------------------------------------------------------------------
.segment "DATA"

;-----------------------------------------------------------------------------
.export gs_key_handler_memop
.export gs_key_handler_memop_vec
gs_key_handler_memop:
gs_key_handler_memop_vec:
                    .res 1

.export gs_key_handler_regs
gs_key_handler_regs:
                    .res 1

;-----------------------------------------------------------------------------
.export gs_hexin
.export gs_opcode_6502
gs_hexin:
gs_opcode_6502:
                    .res 1

;-----------------------------------------------------------------------------
.export gs_keyscan
.export gs_key_handler_exec
.export gs_key_handler_nav

gs_keyscan:
gs_key_handler_exec:
gs_key_handler_nav:
                   .res 1
