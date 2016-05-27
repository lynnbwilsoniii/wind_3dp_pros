;-------------------------------------------------------------
;+
; NAME:
;       LINT
; PURPOSE:
;       Find the intersection of two lines in the XY plane.
; CATEGORY:
; CALLING SEQUENCE:
;       lint, a, b, c, d, i
; INPUTS:
;       a, b = Points on line 1.          in
;       c, d = Points on line 2.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         FLAG=f  Returned flag:
;           0 means no intersections (lines parallel).
;           1 means one intersection.
;           2 means all points intersect (lines coincide).
;         /COND print condition number for linear system.
; OUTPUTS:
;       i1, i2 = Returned intersection.   out
;         Both i1 and i2 should be the same.
; COMMON BLOCKS:
; NOTES:
;       Notes: Each point has the form [x,y].
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Feb 4
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro lint, a, b, c, d, i1, i2, flag=flag, cond=cnd, help=hlp
 
	if (n_params(0) lt 5) or keyword_set(hlp) then begin
	  print,' Find the intersection of two lines in the XY plane.'
	  print,' lint, a, b, c, d, i'
	  print,'   a, b = Points on line 1.          in'
	  print,'   c, d = Points on line 2.          in'
	  print,'   i1, i2 = Returned intersection.   out'
	  print,'     Both i1 and i2 should be the same.'
	  print,' Keywords:'
	  print,'   FLAG=f  Returned flag:'
	  print,'     0 means no intersections (lines parallel).'
	  print,'     1 means one intersection.'
	  print,'     2 means all points intersect (lines coincide).'
	  print,'   /COND print condition number for linear system.'
	  print,' Notes: Each point has the form [x,y].'
	  return
	endif
 
	;----------------------------------------------------------
	;	Find intersection point by solving 2 simultaneous
	;	parametric line equations.
	;
	;	L1(t) = A + t*(B-A)   Line through points A and B.
	;	L2(s) = C + s*(D-C)   Line through points C and D.
	;
	;	At intersection point I L1(t0) = L2(s0) giving
	;	XA + t0(XB-XA) = XC + s0(XD-XC)   for X
	;	YA + t0(YB-YA) = YC + s0(YD-YC)   for Y.
	;
	;	In matrix form (Ax = b):
	;
	;	| (XD-XC)  -(XB-XA) | | s0 |   | (XA-XC) |
	;	|                   | |    | = |         |
	;	| (YD-YC)  -(YB-YA) | | t0 |   | (YA-YC) |
	;
	;	Solve for x (s0, t0).
	;----------------------------------------------------------
 
	;------  First test lines  -----------
	vab = b-a	; Vector from A to B.
	vcd = d-c	; Vector from C to D.
	pcd = [-vcd(1),vcd(0)]	; Perpendicular to vector C to D.
	pt = total(vab*pcd)	; 0 if lines parallel.
	ds = total((c-a)*pcd)	; 0 if A is on CD.
	flag = 1				; Assume 1 point.
	if pt eq 0 then begin			; Lines parallel.
	  if ds eq 0 then flag=2 else flag=0	; Lines coincide.
	endif
	if flag ne 1 then return
 
	;------  Set up matrix A for left side of the linear system  -------
	aa = [ [(d(0)-c(0)), -(b(0)-a(0))], $
	      [(d(1)-c(1)), -(b(1)-a(1))] ]
	if keyword_set(cnd) then print,' Condition number = ',cond(aa)
 
	;------  Set up right side of the linear system  --------
	bb = [ (a(0)-c(0)), (a(1)-c(1)) ]
 
	;------  Use Singular Value Decomposition and back-substitution  -----
	svdc,aa,w,u,v,/double
	par = svsol(u,w,v,bb,/double)	; par = [s0,t0]
 
	;------  Find intersection point  ---------
	s0 = par(0)
	t0 = par(1)
	i1 = a + t0*vab		; t0 solution.
	i2 = c + s0*vcd		; s0 solution.
 
	return
	end