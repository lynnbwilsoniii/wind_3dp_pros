;+
;PROCEDURE: get_momplph,dat
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
;	 "MOM3D"
;
;
;CREATED BY:   Davin Larson   
;LAST MODIFICATION:  %E%
;FILE: %M%
;VERSION %I%
;-
pro get_mom_plph,name=name,trange=trange, $
  sc_pot=sc_pot,  $
  dens_name =dens_name,  $
  plbkg = plbkg, $
  phbkg = phbkg, $
  pot_name = pot_name, $
  mag_name = mag_name, $
  data=ds


start =systime(1)
get_dat='pl'
time = call_function('get_'+get_dat,/times)
start_index = 0l
if keyword_set(trange) then begin
  tr = minmax_range(trange)
  w = where(time ge tr[0] and time le tr[1],c)
  if c gt 0 then time =time[w]
  start_index = w[0]
endif

max = n_elements(time)

phtime=get_ph(/times)
phindex = round( interp(time,lindgen(max)+start_index,phtime) )


if not keyword_set(time) then begin
  print,"No data for ",get_dat
  return
endif

  if keyword_set(dens_name) then  dens = data_cut(dens_name,time)
  if keyword_set(pot_name) then  pot = data_cut(pot_name,time)
;  if  keyword_set(dens) eq 0 and keyword_set(pot) eq 0 then  comp=1
;  help,time,dens,pot,comp



str_format = mom3d()

if not keyword_set(mag_name) then begin
   mag_name = (tnames('wi_B3 wi_B wi_Bhkp'))[0]
   print,'Using ',mag_name,' for the field direction'
endif
magf = data_cut(mag_name,time)
if not keyword_set(magf) then begin
   magf=replicate(!values.f_nan,max,3)
   message,/info,'No Magnetic field data!'
endif

ds = replicate(str_format,max)

for n=0l,max-1 do begin
    dat = call_function('get_'+get_dat,index=n + start_index)
;    ph = get_eh(index=ehindex[n])
    ph = get_ph(dat.time-1)
    if keyword_set(plbkg) then  dat=sub3d(dat,plbkg)
    if keyword_set(phbkg) then  ph =sub3d(ph,phbkg)
    if dat.valid then begin
      dat.magf = reform(magf[n,*])
;     if keyword_set(pot)  then  pot_n=pot[n] else  pot_n=0.
;     if keyword_set(dens) then begin
;       ds[n] = mom3d_plph(dat,dens[n],format=str_format)
;     endif else    ds[n] = mom3d(dat,erange=er,format=str_format)
      ds[n] = mom_plph(dat,ph,format=str_format,sc_pot=sc_pot)
;      ds[n] = mom_plph(dat,ph,format=str_format)
    endif
    print,n,max,'  ',time_string(dat.time),dat.time-ph.time
endfor



print," number of data points = ",n

  xyz_to_polar,transpose(ds.velocity),mag=mag,theta=th,phi=phi,/ph_0_360
  add_str_element,ds,'vel_mag',mag
  add_str_element,ds,'vel_th',th
  add_str_element,ds,'vel_phi',phi


  

if not keyword_set(name) then name = 'plhm

comment='None
store_data,name,data = ds,dlim={comment:comment}

message,/info,string(systime(1)-start)+ ' seconds'

return
end
