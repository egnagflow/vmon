;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.ifndef _INIT_VARS_H_
_INIT_VARS_H_ := 1

.include "target.h"

;-----------------------------------------------------------------------------
; Macro to declare initialized variables.
;-----------------------------------------------------------------------------

;--- ROM build ----------------------------------------------------------------
.if CONFIG_ROM_BUILD
  .macro decl_init_var name, val
  .pushseg
  .segment "INITVARS_RAM"
  name:   .res 1
  .segment "INITVARS_ROM"
          .byte val
  .popseg
  .endmacro

  .macro setup_init_vars
          jsr setup_init_vars_fn
  .endmacro

;--- RAM build ----------------------------------------------------------------
.else
  ; Place variable in RAM.
  .macro decl_init_var name, val
  .pushseg
  .segment "DATA"
  name:   .byte val
  .popseg
  .endmacro

  .macro setup_init_vars
          ; Nothing to do for non-ROM builds
          ; Note:
          ;  For non-ROM builds the variables will only be
          ;  initialized at load time, i.e. when quitting and
          ;  restarting the monitor, the variables will retain
          ;  their last state.
  .endmacro
.endif ; CONFIG_ROM_BUILD

.endif ; _INIT_VARS_H_
