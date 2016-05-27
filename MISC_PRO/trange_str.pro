;+
;FUNCTION:   trange_str,t1,t2
;INPUT:  t1,t2   doubles,   seconds since 1970
;OUTPUT:  string  with the format:  'YYYY-MM-DD/HH:MM:SS - HH:MM:SS'
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)trange_str.pro	1.10 01/23/2008
;    MODIFIED BY: Lynn B. Wilson III
;-

function trange_str, t1,t2,msec=msec,prec=prec

if n_params() eq 1 then return,trange_str(min(t1,/nan),max(t1,/nan),msec=msec,prec=prec)

prec=0
if keyword_set(msec) then prec=3

s1 = time_string(t1,prec=prec)
s2 = time_string(t2,prec=prec)

if strmid(s1,0, 10) ne strmid(s2,0,10) then begin 	;more than one day
	return, strmid(s1,0,10)+' - '+strmid(s2,0,10)
endif else return, s1+' - '+strmid(s2,strpos(s2,'/')+1,30)


end



