;+
;FUNCTION:	pad
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
;LAST MODIFICATION:	@(#)pad.pro	1.21 02/04/17
;-

function pad ,dat,  $
  BDIR = bdir,  $
  magf = magf,  $
  ESTEPS = esteps,  $
  BINS=bins,   $
  NUM_PA=num_pa

if n_elements(num_pa) eq 0 then num_pa = 8
if n_params() eq 1 then use_symm=1

if not keyword_set(magf) then magf=dat.magf
xyz_to_polar,magf,theta=bth,phi=bph

if n_elements(bins) ne 0 then ind=where(bins) else ind=indgen(dat.nbins)
nbins = n_elements(ind)

pa = pangle(dat.theta,dat.phi,bth,bph)
pab = fix(pa/180.*num_pa)  < (num_pa-1) 
;angles = (findgen(num_pa)+.5)*180./num_pa

if bth gt 90 or bth lt -90 then pab(*,*)=0
    
;print,minmax(pab)
;print,minmax(pa)
;print,dat.theta
;print,where(finite(dat.theta) eq 0)

nenergy = dat.nenergy

data =   fltarr(nenergy,num_pa)
geom =   fltarr(nenergy,num_pa)
dt =     fltarr(nenergy,num_pa)
energy = fltarr(nenergy,num_pa)
pang =   fltarr(nenergy,num_pa)
count  = fltarr(nenergy,num_pa)
deadtime = fltarr(nenergy,num_pa)

for i=0,nbins-1 do begin
   b = ind(i)
   e = lindgen(nenergy)
   n_e = e
   n_b = pab(n_e,b)
   n_b_indx = where(n_b ge 0 and n_b lt num_pa,n_b_cnt)
   if n_b_cnt gt 0 then begin
   	e = e(n_b_indx)
   	n_e = e
   	n_b = n_b(n_b_indx)
        data(n_e,n_b)   = data(n_e,n_b)  + dat.data(e,b)
        geom(n_e,n_b)   = geom(n_e,n_b)  + dat.gf(e,b)
        dt(n_e,n_b)     = dt(n_e,n_b)  +   dat.dt(e,b)
        energy(n_e,n_b)   = energy(n_e,n_b)  + dat.energy(e,b)
        pang(n_e,n_b)   = pang(n_e,n_b)  + pa(e,b)
        count(n_e,n_b)  = count(n_e,n_b) + 1
        deadtime(n_e,n_b) = deadtime(n_e,n_b) + dat.deadtime(e,b)
    endif
endfor

energy = energy/count
pang = pang/count
if strlowcase(dat.units_name) ne 'counts' then data = data/count

;geom = reform(geom(6,*))


pad = {project_name:dat.project_name,data_name:dat.data_name+' PAD', $
       valid:1,  units_name:dat.units_name, $
       time:dat.time,  end_time:dat.end_time,  integ_t:dat.integ_t,  $
       nbins:num_pa,nenergy:nenergy, $
       data:data,energy:energy,angles:pang, denergy:dat.denergy, $
       bth:bth,  bph:bph,  $
       gf:geom,dt:dt,geomfactor:dat.geomfactor, $
       mass:dat.mass,units_procedure:dat.units_procedure, $
       deadtime:deadtime }

return,pad
end

