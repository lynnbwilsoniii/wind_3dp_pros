;+
; function: in_set
; 
; purpose: simple boolean function to check whether an element is a member of 
;          a set(array).  It is mainly syntactic sugar for a frequently repeated
;          operation.
;          
; inputs: ele: The element to be searched for
;         set: The set to be searched
;         
; output: 1=yes, 0=no
; 
; $LastChangedBy: pcruce $
; $LastChangedDate: 2008-11-10 12:47:28 -0800 (Mon, 10 Nov 2008) $
; $LastChangedRevision: 3952 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/misc/SSW/in_set.pro $
;- 


;checks if an item is inside a set, right now it only includes simple
;array based sets
function in_set,ele,set

  compile_opt idl2,hidden
  
  idx = where(ele eq set)
  
  if idx[0] eq -1 then begin
    return,0
  endif else begin
    return,1
  endelse

end