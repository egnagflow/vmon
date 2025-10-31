;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.ifndef _KEYSCAN_H_
_KEYSCAN_H_ := 1

;-----------------------------------------------------------------------------
; Keyscan HW register mapping
;-----------------------------------------------------------------------------
keyscan_outport_dir     = cia1ddra
keyscan_outport_val     = cia1dra

keyscan_inport_dir      = cia1ddrb
keyscan_inport_val      = cia1drb

.endif
