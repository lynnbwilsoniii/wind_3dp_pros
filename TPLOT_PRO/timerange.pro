;+
;FUNCTION:  timerange
;PURPOSE:	To get timespan from tplot_com or by using timespan, if 
;		tplot time range not set.
;INPUT:		
;	tr (optional)
;KEYWORDS:	
;	none
;RETURNS:
;    two element time range vector.  (double)
;
;SEE ALSO:	"timespan"
;REPLACES:  "get_timespan"
;CREATED BY:	Davin Larson
;
;-



function timerange,trange,current=current
@tplot_com.pro
if keyword_set(trange) then return,minmax(time_double(trange))
str_element,tplot_vars,'options.trange_full',trange_full
if n_elements(trange_full) ne 2 then timespan
if tplot_vars.options.trange_full[0] ge tplot_vars.options.trange_full[1] then $
	timespan
t = tplot_vars.options.trange_full
if keyword_set(current) then t = tplot_vars.options.trange_current
return,t
end

