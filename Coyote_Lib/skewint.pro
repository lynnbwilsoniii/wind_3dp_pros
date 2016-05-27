;-------------------------------------------------------------
;+
; NAME:
;       SKEWINT
; PURPOSE:
;       Give the near-intersection point for two skew lines.
; CATEGORY:
; CALLING SEQUENCE:
;       skewint, a, b, c, d, m, e
; INPUTS:
;       a, b = two points on line 1.          in
;       c, d = two points on line 2.          in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       m = midpoint of closest approach.     out
;       e = distance between lines.           out
;           -1 for parallel lines.
; COMMON BLOCKS:
; NOTES:
;       Notes: a,b,c,d,m are 3 element arrays (x,y,z),
;         e is a scalar.  Two lines in 3-d that should
;         intersect will, because of errors, in general
;         miss.  This routine gives the point halfway
;         between the two lines at closest approach.
; MODIFICATION HISTORY:
;       R. Sterner. 30 Dec, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
	pro skewint, a, b, c, d, mid, err, help
 
	if (n_params(0) lt 6) or keyword_set(hlp) then begin
	  print,' Give the near-intersection point for two skew lines.
	  print,'   skewint, a, b, c, d, m, e'
	  print,'     a, b = two points on line 1.          in'
	  print,'     c, d = two points on line 2.          in'
	  print,'     m = midpoint of closest approach.     out'
	  print,'     e = distance between lines.           out'
	  print,'         -1 for parallel lines.'
	  print,' Notes: a,b,c,d,m are 3 element arrays (x,y,z),'
	  print,'   e is a scalar.  Two lines in 3-d that should'
	  print,'   intersect will, because of errors, in general'
	  print,'   miss.  This routine gives the point halfway'
	  print,'   between the two lines at closest approach.'
	  return
	endif
 
	AB = B - A			; vector from A to B.
	U1 = AB/SQRT(TOTAL(AB*AB))	; unit vector along AB.
	CD = D - C			; vector from C to D.
	U2 = CD/SQRT(TOTAL(CD*CD))	; unit vector along CD.
	V3 = CROSSP(U1, U2)		; vector perpendicular to U1 and U2.
	M3 = SQRT(TOTAL(V3*V3))		; length of vector T.
	IF M3 EQ 0. THEN BEGIN		; Check for parallel lines.
	  ERR = -1			;   Set distance to invalid value -1.
	  RETURN
	END
	U3 = V3/M3			; unit vector along T1.
	E = TOTAL((A - C)*U3)*U3	; displacement vector from L2 to L1.
 
	AC2 = C + E - A			; Vector from A to projected C (C').
	V4 = AC2 - TOTAL(AC2*U1)*U1	; displacement vector of C' from L1.
	M4 = SQRT(TOTAL(V4*V4))		; magnitude of displacement vector.
	IF M4 EQ 0 THEN BEGIN		; C' is on L1.
	  MID = C + E/2			;  just shift C by E/2.
	ENDIF ELSE BEGIN		; C' not on L1.
	  U4 = V4/M4			;   unit vector along V.
	  DV4 = TOTAL(V4*U4)		;   projection of V along U4.
	  DU2 = TOTAL(U2*U4)		;   projection of U2 along U4.
	  T = -DV4/DU2			;   distance from C' to I'.
	  MID = C + T*U2 + E/2.		;   nearest intersection point.
	ENDELSE
	ERR = SQRT(TOTAL(E*E))		; distance between lines.
 
	RETURN
	END