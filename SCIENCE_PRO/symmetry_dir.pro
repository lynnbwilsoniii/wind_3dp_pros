;+
;FUNCTION:	symmetry_dir
;PURPOSE:	Calculates symmetry direction
;INPUT:
;	Pt:	array of pts
;KEYWORDS:
;	none
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)symmetry_dir.pro	1.3 95/08/24
;-

function symmetry_dir ,Pt

tr = (Pt(0,0) + Pt(1,1) + Pt(2,2))/3.
Pxx = Pt(0,0) - tr
Pyy = Pt(1,1) - tr
Pzz = Pt(2,2) - tr
Pxy = Pt(0,1)
Pxz = Pt(0,2)
Pyz = Pt(1,2)

a = (Pxx*(Pxx-Pyy) + Pyy*(Pyy-Pzz) + Pzz*(Pzz-Pxx))/9. + (Pxy*Pxy + Pyz*Pyz + Pxz*Pxz)/3.
b = Pxx*Pyz*Pyz + Pyy*Pxz*Pxz + Pzz*Pxy*Pxy - Pxx*Pyy*Pzz - 2.*Pxy*Pyz*Pxz 
c = 2.*sqrt(a)

;f1 = c/2.;
if b lt 0. then c = -c;
;   f2 = 1. - exp(alog(b)/3.)/f1  ;	/* 2D check */
;f1 = f1 * 3./(tr-c)   ;		/* Assym */

Pxx = Pxx + c;
Pyy = Pyy + c;
Pzz = Pzz + c;
if(abs(Pxx) lt abs(Pyy)) then begin
   if(abs(Pxx) lt abs(Pzz)) then i = 0  else i = 2
endif else begin
   if(abs(Pyy) lt abs(Pzz))  then i = 1  else i = 2
endelse

sym = dblarr(3)
case i of
   0 : begin
          sym(0) = Pyy*Pzz - Pyz*Pyz
          sym(1) = Pxz*Pyz - Pxy*Pzz
          sym(2) = Pxy*Pyz - Pxz*Pyy
       end		
   1 : begin
          sym(1) = Pzz*Pxx - Pxz*Pxz
          sym(2) = Pxy*Pxz - Pyz*Pxx
          sym(0) = Pyz*Pxz - Pxy*Pzz
       end
   2 : begin
          sym(2) = Pxx*Pyy - Pxy*Pxy
          sym(0) = Pyz*Pxy - Pxz*Pyy
          sym(1) = Pxz*Pxy - Pyz*Pxx
       end
endcase
tr = sqrt(total(sym*sym,/double))
if sym(0) lt 0  then tr = -tr ;   Force x component to be positive
sym = sym/tr
return,sym
end


