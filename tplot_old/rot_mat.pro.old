; +
;FUNCTION:      rot_mat(v1,v2)
;INPUT: 
;       v1:     3 component vector,             
;       v2:     3 component vector,             
;PURPOSE:
;       Returns a rotation matrix that rotates v1,v2 to the x-z plane
;       v1 is rotated to the z'-axis and v2 into the x'-z' plane
;NOTES: 
;
;CREATED BY:
;       Davin Larson
; -
function rot_mat,v1,v2

a=v1/(total(v1^2))^.5
if not keyword_set(v2) then v2 = [1.d,0.d,0.d]

b=crossp(a,v2)
b=b/sqrt(total(b^2))

c=crossp(b,a)

rot = [[c],[b],[a]]
 
return, rot
end

