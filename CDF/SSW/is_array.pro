;+
;
;Name: is_array
;
;Purpose: determines if input is an array
;
;Inputs: input: the input can of any type
;
;Outputs: 1:yes 0:no
;
; $LastChangedBy: pcruce $
; $LastChangedDate: 2008-09-15 16:21:35 -0700 (Mon, 15 Sep 2008) $
; $LastChangedRevision: 3498 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/misc/SSW/is_array.pro $
;-

function is_array,input

  if (size(input,/dimensions))[0] eq 0 then begin
    return,0
  endif else begin
    return,1
  endelse
  
end