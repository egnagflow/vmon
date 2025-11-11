;-----------------------------------------------------------------------------
;
; (c) 1986-2025 Wolfgang G. Reißnegger <w.reissnegger@gmx.net>
; 
; Project: https://github.com/egnagflow/vmon
; License: https://github.com/egnagflow/vmon/blob/main/LICENSE
;
;-----------------------------------------------------------------------------

.ifndef _SCREEN_H_
_SCREEN_H_ := 1

.include "screen_config.h"

;-----------------------------------------------------------------------------
; Include API macros for memmapped screens
;-----------------------------------------------------------------------------
.include "screen_memmap.h"

;-----------------------------------------------------------------------------
; Screen clear and switching
;-----------------------------------------------------------------------------
api_macro_map screen_clr,               screen_clr_fn
api_macro_map screen_switch_to_user,    screen_switch_to_user_fn
api_macro_map screen_switch_to_mon,     screen_switch_to_mon_fn

;-----------------------------------------------------------------------------
; Screen platform dependent INIT
;-----------------------------------------------------------------------------
api_macro_not_implemented screen_init_target

;-----------------------------------------------------------------------------
; Screen color handling
;-----------------------------------------------------------------------------
api_macro_map_if CONFIG_ENABLE_COLOREDIT_BACKGROUND, screen_color_background_cycle, screen_color_background_cycle_fn
api_macro_map_if CONFIG_ENABLE_COLOREDIT_BACKGROUND, screen_color_frame_cycle, screen_color_frame_cycle_fn

.endif ; _SCREEN_H_
