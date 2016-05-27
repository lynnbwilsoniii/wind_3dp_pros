;+
;FUNCTION:	cal_bsn2(sx,sy,sz,bx,by,bz,vmag,bow=bow)
;INPUT:
;	sx,sy,sz:	x, y, and z coodinates of spacecraft in GSE with
;			units of Re
;	bx,by,bz:	magnetic field direction
;OPTIONS:
;	bow:	structure containing {L,ecc,x0}
;		L:	standoff parameter with units of Re
;		ecc:	eccentricity of shock
;		x0:	focus location in Re
;
;       hyperbolic bow shock, see JGR 1981, p.11401, Slavin Fig.7
;       r = L/(1+ecc*cos(theta))
;       1 = (x-x0-c)^2/a^2 - (y^2+z^2)/b^2
;       default L = b^2/a = 23.5
;               ecc = c/a = 1.15
;               xoffset= 3
;               c = (a^2 + b^2)^.5 = L*e/(e^2-1) = 83.8
;               a = L/(e^2-1) = 72.87
;               b = L/(e^2-1)^.5 = 41.38
;PURPOSE:
;	Function returns a structure that describes the interaction of a B-field
;	with a hyperboloid bow shock model.
;	Returned structure elements include:
;		th_bn: the angle (in degrees) between shock normal and the
;			field line that passes through the spacecraft
;		l1: the distance along the field line to the shock
;		l2: the distance from a point that is missdist from the
;			spacecraft in x to the tangent point
;		d,m: the distance along x from the spacecraft to a point
;			where the B field line would be tangent to the
;			bow shock.  A postive d means that the field
;			line has already intersected the shock.  A positive
;			m indicates that the field line has not yet
;			intersected the shock.
;		intpos: position vector in GSE of point where field line
;			originating at spacecraft intersects bow shock
;	All distances are in Re.
;CREATED BY:
;	P. Schroeder
;LAST MODIFICATION: 
;       L. Winslow 9/15/00
;LAST MODIFICATION: %W% %E%
;-

function cal_bsn2, sx, sy, sz, bx, by, bz, vmag, bow=bow

if keyword_set(bow)  then begin
   if data_type(bow) ne 8 then $
          bow={standoff:23.5,eccentricity:1.15,x_offset:3.0}
endif else begin
          bow={standoff:23.5,eccentricity:1.15,x_offset:3.0}
endelse
 
L=bow.standoff
ecc=bow.eccentricity
xoffset=bow.x_offset

a = L/(ecc^2-1.)
b = L/(ecc^2-1.)^.5
c = L*ecc/(ecc^2-1.)

x0 = sx-xoffset-c
y0 = sy
z0 = sz

aa = b^2*bx^2-a^2*by^2-a^2*bz^2
bb = 2.*b^2*bx*x0-2.*a^2*by*y0-2.*a^2*bz*z0
cc = b^2*x0^2-a^2*y0^2-a^2*z0^2-a^2*b^2

crittest=bb^2-4.*aa*cc

haveint = float(crittest ge 0.)
crittest = haveint*crittest

t1 = (-bb+sqrt(crittest))/2./aa
t2 = (-bb-sqrt(crittest))/2./aa

p1x = x0+t1*bx
p1y = y0+t1*by
p1z = z0+t1*bz
p2x = x0+t2*bx
p2y = y0+t2*by
p2z = z0+t2*bz

p1l0 = float(p1x lt 0.)
p2l0 = float(p2x lt 0.)
t1gt2 = float(abs(t1) gt abs(t2))

havenint = float((p1l0+p2l0) gt 0)
haveint = havenint*haveint

mypx = p1x*p1l0 + p2x*p2l0 - p1x*t1gt2*p1l0*p2l0 - p2x*(not t1gt2)*p1l0*p2l0 + $
	1.*(not p1l0)*(not p2l0)
mypy = p1y*p1l0 + p2y*p2l0 - p1y*t1gt2*p1l0*p2l0 - p2y*(not t1gt2)*p1l0*p2l0 + $
	1.*(not p1l0)*(not p2l0)
mypz = p1z*p1l0 + p2z*p2l0 - p1z*t1gt2*p1l0*p2l0 - p2z*(not t1gt2)*p1l0*p2l0 + $
	1.*(not p1l0)*(not p2l0)
l1pllb = float((bx*(mypx-x0)+by*(mypy-y0)+bz*(mypz-z0)) ge 0.)

magb = sqrt(bx^2+by^2+bz^2)
magdelf = sqrt(4.*mypx^2/a^4+4.*mypy^2/b^4+4.*mypz^2/b^4)
costheta = -(2.*mypx/a^2*bx-2.*mypy/b^2*by-2.*mypz/b^2*bz)/magb/magdelf

th_bn = replicate(!values.f_nan,n_elements(sx))
l1 = replicate(!values.f_nan,n_elements(sx))
intpos = replicate(!values.f_nan,3,n_elements(sx))
normal = intpos
indxint = where(haveint,cnt)
if cnt ne 0 then begin
	th_bn(indxint) = acos(costheta(indxint))*180./!pi
	l1(indxint) =sqrt((mypx(indxint)-x0(indxint))^2+ $
		(mypy(indxint)-y0(indxint))^2+(mypz(indxint)-z0(indxint))^2)
	intpos(0,indxint) = mypx(indxint)+xoffset+c
	intpos(1,indxint) = mypy(indxint)
	intpos(2,indxint) = mypz(indxint)
        normal(0,indxint) = 2.*mypx(indxint)/a^2
        normal(1,indxint) = 2.*mypy(indxint)/b^2
        normal(2,indxint) = 2.*mypz(indxint)/b^2
endif

ajunk = (a*by/b/bx)^2-1.
bjunk = 2.*(a/b/bx)^2*by*bz
cjunk = (a*bz/b/bx)^2-1.

a_t = ajunk*by^2+bjunk*by*bz+cjunk*bz^2
b_t = 2.*ajunk*by*y0+bjunk*(bz*y0+by*z0)+2.*cjunk*bz*z0
c_t = ajunk*y0^2+bjunk*y0*z0+cjunk*z0^2-b^2

tpointcrit = b_t^2-4.*a_t*c_t
havetpoint = float(tpointcrit ge 0.)
tpointcrit = tpointcrit*havetpoint

tt1 = (-b_t+sqrt(tpointcrit))/2./a_t
tt2 = (-b_t-sqrt(tpointcrit))/2./a_t

ytang1 = y0 + tt1*by
ytang2 = y0 + tt2*by

ztang1 = z0 + tt1*bz
ztang2 = z0 + tt2*bz

xtang1 = (a/b)^2/bx*(ytang1*by+ztang1*bz)
xtang2 = (a/b)^2/bx*(ytang2*by+ztang2*bz)
xt1lt0 = float(xtang1 lt 0.)

xtang = xtang1*xt1lt0 + xtang2*(not xt1lt0)
ytang = ytang1*xt1lt0 + ytang2*(not xt1lt0)
ztang = ztang1*xt1lt0 + ztang2*(not xt1lt0)
x0tang = xtang - tt1*bx*xt1lt0 - tt2*bx*(not xt1lt0)

d = replicate(!values.f_nan,n_elements(sx))
l2 = replicate(!values.f_nan,n_elements(sx))
indxtpoint = where(havetpoint,cnt)
if cnt ne 0 then begin
	d(indxtpoint) = x0tang(indxtpoint)-x0(indxtpoint)
	l2(indxtpoint) = sqrt((x0tang(indxtpoint)-xtang(indxtpoint))^2+ $
		(y0(indxtpoint)-ytang(indxtpoint))^2+ $
		(z0(indxtpoint)-ztang(indxtpoint))^2)
endif

outstruct = {th_bn: 0., l: 0., lc: !values.f_nan, lm: !values.f_nan,$
	d: 0., m: 0., vc: 0.,intpos: replicate(0.,3),normal: replicate(0., 3)}
outarr = replicate(outstruct,n_elements(sx))
if n_elements(sx) eq 1 then begin
	outarr.th_bn = th_bn(0)
	if l1pllb(0) then begin
		outarr.l = l1(0)
		l2 = l2(0)
	endif else begin
		outarr.l = -l1(0)
		l2 = -l2(0)
	endelse	
	if d(0) ge 0. then begin
		outarr.d = d(0)
		outarr.m = !values.f_nan
		outarr.lc = l2
	endif else begin
		outarr.d = !values.f_nan
		outarr.m = -d(0)
		outarr.lm = l2
	endelse
	outarr.vc = vmag(0)*outarr.lc/outarr.d
	outarr.intpos = intpos
        outarr.normal = normal
endif else begin
	outarr.th_bn = th_bn
	outarr.l = l1*l1pllb - l1*(not l1pllb)
	l2 = l2*l1pllb - l2*(not l1pllb)
	dge0 = where(d ge 0.,cnt1)
	if cnt1 eq 1 then dge0 = dge0(0)
	dlt0 = where(d lt 0.,cnt2)
	if cnt2 eq 1 then dlt0 = dlt0(0)
	outarr.d = d
	outarr.m = -d
	if cnt2 ne 0 then begin
		outarr(dlt0).d = !values.f_nan
		outarr(dlt0).lm = l2(dlt0)
	endif
	if cnt1 ne 0 then begin
		outarr(dge0).m = !values.f_nan
		outarr(dge0).lc = l2(dge0)
	endif
	outarr.vc = vmag*outarr.lc/outarr.d
	outarr.intpos = intpos
        outarr.normal = normal
endelse
return,outarr

end