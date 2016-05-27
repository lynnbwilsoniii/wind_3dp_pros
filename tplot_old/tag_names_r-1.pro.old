;+
; FUNCTION:  TAG_NAMES_R(STRUCTURE, [TYPE=dt] )
; PURPOSE:  Very similar to the TAG_NAMES function but recursively
;           obtains all structure names within imbedded structures as well.
; INPUT: STRUCTURE: A structure typically.
;              If input is not a structure then a null string is returned
; KEYWORDS:
;       TYPE=var; Named variable in which to return and array of data types.
; RETURNS:  Returns an array of strings
;-
function tag_names_r,structure,type=dtype,count=count

count = 0
dtype = size(/type,structure)

if dtype ne 8 then   return,''   else  begin
    struct0 = structure[0]
    tags = tag_names(struct0)
    for i=0,n_elements(tags)-1 do begin
        tgs = tag_names_r( struct0.(i), type=dt )
        dtype   = i eq 0 ? dt      : [dtype,dt]
        if  keyword_set(tgs) then begin
           tgs = tags[i] + '.' + tgs
           alltags = i eq 0 ? tgs     : [alltags,tgs]
        endif else begin
           alltags = i eq 0 ? tags[i] : [alltags,tags[i]]
        endelse
    endfor
    count = n_elements(dtype)
    return,alltags
endelse

end
