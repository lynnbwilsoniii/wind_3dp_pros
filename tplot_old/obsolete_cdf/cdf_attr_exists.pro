;+
; FUNCTION: cdf_attr_exists, cdf, attrname
;
; PURPOSE:
;     determines if a specified CDF file has an attribute with a specified name
;
; INPUTS:
;     cdf:
;         either the cdf_id of an open CDF file, or the name of a CDF file
;     attrname:
;         name of the attribute to be asked about
;
; KEYWORDS:
;     scope:
;         if set, return the scope of the attribute (if it is present). The scope
;         may be either of the strings 'GLOBAL_SCOPE' or 'VARIABLE_SCOPE'.
;         The value of this variable is only meaningful if the return value is 1.
;
; OUTPUTS:
;     return value is 1 if yes, 0 if no
;
; CREATED BY: Vince Saba
;
; LAST MODIFICATION: @(#)cdf_attr_exists.pro	1.1 98/04/14
;-

function cdf_attr_exists, cdf, attrname, scope=scope
if data_type(cdf) eq 7 then id = cdf_open(cdf) else id = cdf
attr_exists = 0
inq = cdf_inquire(id)
n_attr = inq.natts
for i = 0, n_attr - 1 do begin
    cdf_attinq, id, i, returned_attrname, attr_scope, dummy2, dummy3
    if attrname eq returned_attrname then begin
        attr_exists = 1
	scope = attr_scope
	goto, endofloop
    endif
endfor
endofloop:
if data_type(cdf) eq 7 then cdf_close, id
return, attr_exists
end

