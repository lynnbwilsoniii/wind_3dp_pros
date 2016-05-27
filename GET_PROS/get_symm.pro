;+
;PROCEDURE:	get_symm
;PURPOSE:	Gets symmetry direction of magnetic field
;INPUT:
;	none
;KEYWORDS:
;	use_mag:
;	use_q:
;	use_dir:
;	time:
;	stheta:
;	sphi:
;
;CREATED BY: 	Davin Larson
;LAST MODIFICATION:	@(#)get_symm.pro	1.5 95/08/24
;-

pro get_symm,      $
   USE_MAG = use_mag,  $
   USE_Q   = use_q,  $
   USE_DIR = dir, $
   TIME = time,    $
   STHETA  = sth,  $
   SPHI   = sph
n = 0
max = 3000
time = dblarr(max)
sx  = fltarr(max)
sy  = fltarr(max)
sz  = fltarr(max)
;sth = fltarr(max)
;sph = fltarr(max)

if keyword_set(use_q) then napp=' (S.Q>0)' else napp=''

if dimen1(dir) ne 3 then dir = [-1.,0.,0.]  ; -x direction
esteps = [1,4]

dat = get_el(1)
t = dat.time

while dat.valid ne 0  do begin
   pt = prestens(dat,estep=esteps)
   if keyword_set(use_q)  then dir = heatflux(dat,estep=esteps)
   b = symm3d(pt)
   bdotq = total(b*dir)
   if bdotq lt 0 then b = -b
   sx(n) = b(0)
   sy(n) = b(1)
   sz(n) = b(2)
   time(n) = (dat.time+dat.end_time)/2
   n=n+1
   dat = get_el(t)
end
sx = sx(0:n-1)
sy = sy(0:n-1)
sz = sz(0:n-1)
time = time(0:n-1)

if keyword_set(use_mag) then begin
   sexp = [ [sx],[sy],[sz] ]
   dir = data_cut('Bexp',time) 
; help,dir,sexp
   dot = total(dir * sexp,2)
   sign = (dot gt 0)*2 -1
   sx = sign * sx
   sy = sign * sy
   sz = sign * sz  
   napp='  (S.B>0)'
endif

sexp = [ [sx],[sy],[sz] ]
cart_to_sphere,sx,sy,sz,r,sth,sph

store_data,"Sth",data={ytitle:"Sth"+napp,x:time,y:sth,yrange:[-90.,90.]}
store_data,"Sph",data={ytitle:"Sph"+napp,x:time,y:sph,yrange:[-180.,180.]}
store_data,"Sexp",data={ytitle:"Sexp"+napp,x:time,y:sexp,yrange :[-1.,1.]}

return

end
