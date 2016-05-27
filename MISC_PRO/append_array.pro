;+
;PROCEDURE:	append_array, a0, a1
;PURPOSE:
;	Append an array to another array.  Can also copy an array into a
;	subset of another. 
;INPUT:
;	a0:	Array to modify.
;	a1:	Array to append to, or copy into, a0.
;KEYWORDS:
;	index:	Index of a0 at which to append or copy a1.  If index is
;		greater than the number of elements of a0, then
;		a0 is enlarged to append a1. Returns the index of the first
;		element of a0 past the section copied from a1.
;	done:	If set, make a0 equal to the first index elements of a0.
;CREATED BY:	Davin Larson
;LAST MODIFIED:	@(#)append_array.pro	1.6 98/08/13
;-
pro append_array,a0,a1,index=index,done=done

if arg_present(index) then begin
  if keyword_set(done) then begin
    if not keyword_set(index) then return
     a0 = a0[0:index-1]
     return
  endif
  xfactor = .5
  n0 = n_elements(a0)
  n1 = n_elements(a1)
  if not keyword_set(index) then begin
     index = 0l
     n0 = 0l
  endif
  if n1+index ge n0 then begin
     ;message,/info,"Enlarging array"
     add = floor(n0 * xfactor + n1)
     if index ne 0 then a0 = [a0,replicate(a1[0],add)] $
     else a0 = replicate(a1[0],add)
     n0=n0+add
  endif
  a0[index:index+n1-1] = a1
  index = index + n1
  return
endif


if keyword_set(a0) then a0=[a0,a1] else a0=[a1]

end
