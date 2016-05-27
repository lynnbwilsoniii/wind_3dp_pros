;+
;FUNCTION:	accum_pad,dat,apad
;PURPOSE:	makes a data pad from a 3d structure
;INPUT:	
;	dat:	A 3d data structure such as those gotten from get_el,get_pl,etc.
;		e.g. "get_el"
;KEYWORDS:
;	bdir:	Add B direction
;	esteps:	Energy steps to use
;	bins:	bins to sum over
;	num_pa:	number of the pad
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	%W% %E%
;-

pro accum_pad,apad,data=dat,  $
  ESTEPS = esteps,  $
  lim=plim, $
  BINS=bins,   $
  NUM_PA=num_pa,  $
  NUM_VEL=num_vel, vlim=vlim

if data_type(apad) ne 8 then begin
   if not keyword_set(num_pa) then num_pa = 10
   if not keyword_set(num_vel) then num_vel = 40
   vlim= [5.,545000.]
   d=fltarr(num_vel,num_pa)
   apad = {project_name:'', $
           data_name:'PAD Accumulation', $
           units_name:'df',  $
           mass:0., $
           time:1d10, end_time:0.d, $
           nbins:fix(num_pa) , nenergy:fix(num_vel), $
           vlim:vlim, $
           data:double(d) , ddata:double(d), energy:d, angles:d, cnt:d, $
           units_procedure: 'convert_pad_units', $
           valid:1   }

endif

num_vel = apad.nbins
nenergy = apad.nenergy

apad.time = apad.time < dat.time
apad.end_time = apad.end_time > dat.end_time
apad.mass = dat.mass

case ndimen(bins) of
   -1 or 0: ind = indgen(dat.nenergy*dat.nbins)
    1:      ind = where(replicate(1,dat.nenergy) # bins)
    2:      ind = where(bins)
endcase


ndat = conv_units(dat,'df')
df_dat = double(ndat.data(ind))
help,df_dat

; Modified by REE for relativistic electrons.
; vmag=(2.*ndat.energy(ind)/dat.mass)^.5 ; Not relativistic!
c = 2.9979d5      ;      Davin_units_to_eV = 8.9875e10
E0 = double(dat.mass*c^2)
gamma =  ( double(ndat.energy(ind)) + E0 ) / E0
vmag = sqrt(1.0d - 1.0d/(gamma*gamma) ) * c ; Velocity in km/s

theta = ndat.theta(ind)
phi = ndat.phi(ind)

nd = n_elements(ind)

sphere_to_cart,vmag,theta,phi,vx,vy,vz

vel = [[vx],[vy],[vz]]
vel = vel - replicate(1.,nd) # dat.vsw

rot = rot_mat(dat.magf,dat.vsw)
;vd2d=reform(dat.vsw # rot)

newvel = vel # rot

cart_to_sphere,newvel(*,0),newvel(*,1),newvel(*,2),vmag,theta,phi,/co_lat


vmag = .5*dat.mass*vmag^2

vbin = alog(vmag)
lim =  alog(apad.vlim)
numv = apad.nenergy
nump = apad.nbins

vbin = fix( (vbin-lim(0))/(lim(1)-lim(0)) * numv )
pbin = fix( theta/180. * nump) 
;stop
for i = 0,nd-1 do begin
   v = vbin(i)
   p = pbin(i)
   if(v ge 0 and v lt numv and p ge 0 and p lt nump) then begin
     apad.energy(v,p) = apad.energy(v,p) + vmag(i)
     apad.angles(v,p) = apad.angles(v,p) + theta(i)
     apad.data(v,p)   = apad.data(v,p)   + df_dat(i)
     apad.ddata(v,p)  = apad.ddata(v,p)  + df_dat(i)^2
     apad.cnt(v,p)    = apad.cnt(v,p)    + 1
   endif
endfor

if keyword_set(lim) then begin
   cols = bytescale(pure=numv)
   plots,theta,df_dat,psym=3,color=cols(vbin)
endif

end

