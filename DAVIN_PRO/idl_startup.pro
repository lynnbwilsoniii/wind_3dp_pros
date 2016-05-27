
!quiet=1
on_error,1          ;  returns to main program whenever errors occur

;repath   ; ,except='obsolete' ; resets path

init_devices

tplot_options,window=0
tplot_options,'verbose',1
tplot_options,'psym_lim',100
tplot_options,'ygap',.5
;  tplot_keys    ; uncomment this line to enable the function keys for tplot

;!warn.obs_routines = 1
;!warn.OBS_SYSVARS = 1
;!warn.PARENS = 1
;!warn.TRUNCATED_FILENAME = 1
!quiet = 1
