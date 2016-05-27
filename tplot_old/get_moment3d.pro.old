;+
;PROCEDURE: get_moment3d,dat,ERANGE=erange,BINS=bins,HIGHRANGE=highrange
;INPUT:	
;   dat:function (string)   function that returns 3d data structures
;				function name must be "get_"+"dat"  
;				dat = 'pl' for get_pl, 
;				dat = 'el' for get_el, etc.
;KEYWORDS (all optional) 
;   erange:	intarr(2),     min,max energy bin numbers for integration
;PURPOSE:
;	To generate moment time series data for TPLOT 
;SEE ALSO:	
;	 "MOMENT_3D"
;
;
;CREATED BY:   Davin Larson   
;LAST MODIFICATION:  %E%
;FILE: %M%
;VERSION %I%
;-
pro get_moment3d,get_dat,ERANGE=er,name=name,trange=trange, $
  dens_name =dens_name,  $
  bkg = bkg, $
  pot_name = pot_name, $
  mag_name = mag_name, $
  bins=bins, $
  eesalow=eesalow,protons=protons,alphas=alphas, $
  data=ds

ions = keyword_set(protons) or keyword_set(alphas)
if keyword_set(eesalow) then begin
  if not keyword_set(get_dat) then get_dat='el'
endif
if ions then  get_dat='pl'

start =systime(1)
time = call_function('get_'+get_dat,/times)
start_index = 0l
if keyword_set(trange) then begin
  tr = minmax_range(trange)
  w = where(time ge tr[0] and time le tr[1],c)
  if c gt 0 then time =time[w]
  start_index = w[0]
endif


max = n_elements(time)

if not keyword_set(time) then begin
  print,"No data for ",get_dat
  return
endif

if keyword_set(eesalow) then begin 
  if keyword_set(dens_name) then  dens = data_cut(dens_name,time)
  if keyword_set(pot_name) then  pot = data_cut(pot_name,time)
  if  keyword_set(dens) eq 0 and keyword_set(pot) eq 0 then  comp=1
  help,time,dens,pot,comp
  if not keyword_set(name) then name='em'
endif

if keyword_set(alphas) then name='am'
if keyword_set(protons) then name='pm'


str_format = moments_3d()
if keyword_set(alphas) or keyword_set(protons) then str_element,/add,'mxb',0

if not keyword_set(mag_name) then mag_name = 'wi_B3'
magf = data_cut(mag_name,time)
if not keyword_set(magf) then begin
   magf=replicate(!values.f_nan,max,3)
   message,/info,'No Magnetic field data!'
endif

ds = replicate(str_format,max)

for n=0l,max-1 do begin
    dat = call_function('get_'+get_dat,index=n + start_index)
    if keyword_set(bkg) then  dat=sub3d(dat,bkg)
    if dat.valid then begin
     dat.magf = reform(magf[n,*])
     if ions then begin
        tdat = total(dat.data,2)
        mx = max(tdat,mxb)
        if keyword_set(protons) then er=[mxb-3,13] else er = [0,mxb-4]
        if keyword_set(alphas) then begin 
          dat.energy = dat.energy*2
          dat.mass = dat.mass*4
        endif
     endif
    if keyword_set(pot)  then  pot_n=pot[n] else  pot_n=0.
    if keyword_set(dens) then dens_n=dens[n] else dens_n=0.
    ds[n] = moments_3d(dat,erange=er,format=str_format, $
       true_dens=dens_n ,comp=comp,bins=bins)
    endif
    print,n,max
endfor



print," number of data points = ",n

  xyz_to_polar,transpose(ds.velocity),mag=mag,theta=th,phi=phi,/ph_0_360
  add_str_element,ds,'vel_mag',mag
  add_str_element,ds,'vel_th',th
  add_str_element,ds,'vel_phi',phi

if keyword_set(protons) then begin
  vth_v = ds.vthermal /  ds.vel_mag
  vth_v2 = sqrt(vth_v^2 - .055^2)
  vth2 = vth_v2 * ds.vel_mag
  temp2 = .5 * dat.mass * vth2^2
  add_str_element,ds,'temp2',temp2

endif

  
if keyword_set(er) then comment = string('Energy range: ',er) else comment='Full energy range'

if not keyword_set(name) then name = get_dat+'_mom'

store_data,name,data = ds,dlim={comment:comment}

message,/info,string(systime(1)-start)+ ' seconds'

return
end
