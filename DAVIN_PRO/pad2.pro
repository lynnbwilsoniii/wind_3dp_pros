; +
;FUNCTION:	pad2
;PURPOSE:	makes a data pad from a 3d structure
;INPUT:	
;	dat:	A 3d data structure such as those gotten from get_el,get_pl,etc.
;		e.g. "get_el"
;KEYWORDS:
;	bdir:	Add B direction
;	bins:	bins to sum over
;	num_pa:	number of the pad
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	%W% %E%
; -

function pad2 ,dat,  $
  MAGF = magf,  $
  VSW = vsw,    $
  BINS=bins,    $
  NUM_E = num_e, $
  INTERPGRID = interpgrid, $
  NUM_PA=num_pa

str_element,dat,'magf',val=magf
str_element,dat,'vsw',val=vsw



nbins=dat.nbins
nenergy=dat.nenergy

if n_elements(num_pa) eq 0 then num_pa = 24
if n_elements(num_e) eq 0 then num_e = nenergy

case ndimen(bins) of
   -1 or 0: ind = indgen(nenergy*nbins)
    1:      ind = where(replicate(1,nenergy) # bins)
    2:      ind = where(bins)
endcase

ndat = conv_units(dat,'df')

df_dat = ndat.data(ind)
vmag=(2.*ndat.energy(ind)/dat.mass)^.5
theta = ndat.theta(ind)
phi = ndat.phi(ind)

vrange = minmax_range(vmag) * [.99,1.01]

nd = n_elements(ind)

sphere_to_cart,vmag,theta,phi,vx,vy,vz

vel = [[vx],[vy],[vz]]
vel = vel - replicate(1.,nd) # vsw

rot = rot_mat(magf,vsw)
vd2d=reform(vsw # rot)

newvel = vel # rot

cart_to_sphere,newvel(*,0),newvel(*,1),newvel(*,2),vmag,theta,phi,/co_lat

pabins = fix(theta/180.*num_pa)
   
ebins = fix( alog(vmag/vrange(0)) / alog(vrange(1)/vrange(0)) * num_e )

data =   fltarr(num_e,num_pa)
veloc =  fltarr(num_e,num_pa)
pang =   fltarr(num_e,num_pa)
nsamples  = fltarr(num_e,num_pa)


for i=0,nd-1 do begin
   e = ebins(i)
   b = pabins(i)
   if e ge 0 and e lt num_e then begin
      data(e,b)   = data(e,b)  + df_dat(i)
      veloc(e,b)  = veloc(e,b) + vmag(i)
      pang(e,b)   = pang(e,b)  + theta(i)
      nsamples(e,b)  = nsamples(e,b) + 1
   endif
endfor

good = where(data gt 0)



veloc = veloc(good)/nsamples(good)
pang = pang(good)/nsamples(good)
data = data(good)/nsamples(good)

energy = .5*ndat.mass*veloc^2

if keyword_set(interpgrid) then begin
energy = alog(energy)*20
   triangulate, energy, pang, tr, b

;win=!d.window
;wset,2
plot,energy,pang,psym=1
for i=0,n_elements(tr)/3-1 do begin
 t = [tr(*,i),tr(0,i)]
 plots,energy(t),pang(t)  
endfor
;wset,win

   erange = minmax_range(energy)
   if ndimen(interpgrid) ne 2 then interpgrid = [num_e,num_pa]
   gs=[erange(1)-erange(0),180.]/(interpgrid+1)
   xylim=[erange(0),0.,erange(1),180.]
print,interpgrid
print,gs
print,xylim
   
data = alog(data)
   data  = trigrid(energy, pang, data, tr, gs, xylim)
print,dimen(data)
data = exp(data)
   dim = dimen(data)
   energy  = gs(0)*findgen(dim(0)) + xylim(0)
   pang   =  gs(1)*findgen(dim(1)) + xylim(1)
  
 energy = energy # replicate(1.,dim(1))
 pang   = replicate(1.,dim(0)) # pang

  energy = exp(energy/20)
endif



pad = {project_name:ndat.project_name,data_name:ndat.data_name+' PAD', $
       valid:1,  units_name:ndat.units_name, $
       time:ndat.time,  end_time:ndat.end_time,  integ_t:ndat.integ_t,  $
       nbins:num_pa,nenergy:num_e, $
       data:data,energy:energy,angles:pang,  $
       magf:magf,vsw:vsw,   $
;       bth:bth,  bph:bph,  $
       mass:ndat.mass,units_procedure:ndat.units_procedure}

return,pad
end

