;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.ifndef _API_H_
_API_H_ := 1

.macro api_macro_map macro_name, func_name
  .define macro_name       jsr func_name
.endmacro

.macro api_macro_map_if build_flag, macro_name, func_name
.if build_flag
  api_macro_map macro_name, func_name
.else
  .define macro_name
.endif
.endmacro

.macro api_macro_not_implemented macro_name
.define macro_name
.endmacro

.endif ; _API_H_
