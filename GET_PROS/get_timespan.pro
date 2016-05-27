;+
;PROCEDURE:	get_timespan
;PURPOSE:	To get timespan from tplot_com or by using timespan, if 
;		tplot time range not set.
;INPUT:		
;	t, actually returned to you
;KEYWORDS:	
;	none
;
;SEE ALSO:	"timespan"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)get_timespan.pro	1.9 97/06/02
;
;-

pro get_timespan,t
@tplot_com.pro
str_element,tplot_vars,'options.trange_full',trange_full
if n_elements(trange_full) ne 2 then timespan
if tplot_vars.options.trange_full(0) ge tplot_vars.options.trange_full(1) then $
	timespan
t = tplot_vars.options.trange_full
return
end


