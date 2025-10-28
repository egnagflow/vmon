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
keyscan_outport_dir     = via2ddrb
keyscan_outport_val     = via2drb

keyscan_inport_dir      = via2ddra
keyscan_inport_val      = via2dra

.endif
