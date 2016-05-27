;+
;PROCEDURE:	tplot_keys
;PURPOSE:
;	Sets up function keys on user keyboard to perform frequent "tplot"
;	functions and procedures.  Definitions will be explained when run.
;INPUT:	(none)
;OUTPUT: (none)
;CREATED BY:	Davin Larson
;LAST MODIFIED:	@(#)tplot_keys.pro	1.5 02/11/22
;-
pro tplot_keys
setup_keys
; define_key,'HELP','help,/str,'
; define_key,'F1','printdat,'   ; CDE reinterprets this key.
define_key,'F2','tplot',/term
define_key,'F3','tlimit',/term
define_key,'F4','ctime,t',/term
define_key,'F5','tplot,/add,'
define_key,'F6','tplot_names'
define_key,'F7','printdat,'
define_key,'F8','.go',/term
define_key,'F9','.continue',/term
define_key,'F10','tplot_names'   ;,/term

print,'Current key definitions:'
help,/keys,'F1'
help,/keys,'F2'
help,/keys,'F3'
help,/keys,'F4'
help,/keys,'F5'
help,/keys,'F6'
help,/keys,'F7'
help,/keys,'F8'
help,/keys,'F9'
help,/keys,'F10'
help,/keys,'F11'
help,/keys,'F12'

end
