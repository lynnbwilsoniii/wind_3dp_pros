;+
;NAME: ptr_extract
;Function: ptrs = ptr_extract(p,EXCEPT=EXCEPT)
;Purpose:
;   Recursively searches the input (of any type) and returns an array of all
;   pointers found.
;   This is useful for freeing pointers contained within some complicated
;   structure heirachy or pointer list.
;   if no pointers are found then a scaler null pointer is returned.
;   This routine ignores object pointers!
;Keywords:
;   EXCEPTPTRS = an array of pointers that should not be included in the output.
;Created by Davin Larson. May 2002.
;-
function ptr_extract,p,exceptptrs=exceptptrs
dt = size(/type,p)
n  = n_elements(p)
nul = ptr_new()
ret = nul
if n_elements(exceptptrs) eq 0 then exceptptrs=ptr_new()

if dt eq 10 then begin     ; Pointers
   for i=0,n-1 do begin
      if total(exceptptrs eq p[i]) gt 0 then continue              ; already encountered
      ret = [ret,p[i]]
      exceptptrs = [exceptptrs,p[i]]
      if ptr_valid(p[i]) then $
          ret = [ret,ptr_extract(*p[i],exceptptrs=exceptptrs)]
   endfor
endif

if dt eq 8 then begin    ; Structures
   tags = tag_names(p)
   ntag = n_elements(tags)
   for i=0,ntag-1 do begin
      r = ptr_extract(p.(i),exceptptrs=exceptptrs)
      if keyword_set(r) then ret=[ret,r]
   endfor
end

w = where(ret ne nul,nw)

return,nw gt 0 ? ret[w] : nul
end

