;+
; FUNCTION: cdf_var_exists, cdf, varname
;
; PURPOSE:
;     determines if a specified CDF file has a variable with a specified name
;
; INPUTS:
;     cdf:
;         either the cdf_id of an open CDF file, or the name of a CDF file
;     attrname:
;         name of the variable to be asked about
;
; KEYWORDS:
;
; OUTPUTS:
;     return value is 1 if yes, 0 if no
;
; CREATED BY: Vince Saba
;
; LAST MODIFICATION: @(#)cdf_var_exists.pro	1.1 98/04/14
;-

function cdf_var_exists, cdf, varname
if data_type(cdf) eq 7 then id = cdf_open(cdf) else id = cdf
var_exists = 0
inq = cdf_inquire(id)
for i = 0, inq.nvars - 1 do begin
    varinq = cdf_varinq(id, i)
    if varinq.name eq varname then begin
        var_exists = 1
	goto, endofloop
    endif
endfor
for i = 0, inq.nzvars - 1 do begin
    varinq = cdf_varinq(id, i, /zvariable)
    if varinq.name eq varname then begin
        var_exists = 1
	goto, endofloop
    endif
endfor
endofloop:
if data_type(cdf) eq 7 then cdf_close, id
return, var_exists
end

