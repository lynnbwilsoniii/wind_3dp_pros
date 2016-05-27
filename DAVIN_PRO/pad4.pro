;+
;FUNCTION:	pad4
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
;LAST MODIFICATION:	@(#)pad.pro	1.20 98/07/10
;-

function pad4 ,dat,  $
  magf = magf,  $
  ESTEPS = esteps,  $
  accum = accum, $
  BINS=bins,   $
  NUM_PA=num_pa

if n_elements(num_pa) eq 0 then num_pa = 8

nenergy = dat.nenergy

if keyword_set(accum) then begin
  num_pa = accum.num_pa
endif else begin
  w = replicate(0.,nenergy,num_pa)
  accum ={trange:dat.trange,integ_t:0.,n:0,num_pa:num_pa,magf:[0.,0.,0.], $
     w:w,we:w,wa:w,wf:w,wf2:w}
endelse


if not keyword_set(magf) then magf=dat.magf
xyz_to_polar,magf,theta=bth,phi=bph

pa = pangle(dat.theta,dat.phi,bth,bph)


pab = floor(pa/180.*num_pa)  < (num_pa-1) 
enb = indgen(nenergy) # replicate(1,dat.nbins)

pabin = pab * nenergy + enb

;bad=where(pab lt 0,c)
;if c ne 0 then pabin[bad]=-1   not needed!


h = histogram(pabin,min=0,max=nenergy*num_pa-1,reverse=ri)
;h = reform(h,nenergy,num_pa,/overwrite)


if not keyword_set(weight) then weight= float(dat.bins ne 0)
weight_e = weight * dat.energy
weight_a = weight * pa
weight_f = weight * dat.data
weight_f2 = weight_f * dat.data

whn0 = where(h ne 0,count)
for j=0,count-1 do begin
  i = whn0[j]
  ind = ri[ ri[i]: ri[i+1]-1 ]
  accum.w[i]   = accum.w[i] + total(weight[ind])
  accum.we[i]  = accum.we[i] + total(weight_e[ind])
  accum.wa[i]  = accum.wa[i] + total(weight_a[ind])
  accum.wf[i]  = accum.wf[i] + total(weight_f[ind])
  accum.wf2[i] = accum.wf2[i] + total(weight_f2[ind])
endfor


data   = accum.wf / accum.w
energy = accum.we / accum.w
pang   = accum.wa / accum.w
ddata  = sqrt( (accum.wf2/accum.w) - data^2)
accum.trange = minmax_range([dat.trange,accum.trange])
accum.integ_t = accum.integ_t + dat.integ_t
accum.magf = accum.magf + magf
accum.n = accum.n+1


pad = {project_name:dat.project_name,data_name:dat.data_name+' PAD', $
       valid:1,  units_name:dat.units_name, $
       time:accum.trange[0], end_time:accum.trange[1], integ_t:accum.integ_t,  $
       trange: accum.trange, $
       nbins:num_pa,nenergy:nenergy, $
       data:data,energy:energy,angles:pang, $
       ddata:ddata, $
       magf:accum.magf/accum.n, $
       mass:dat.mass,units_procedure:dat.units_procedure }
       

return,pad
end

