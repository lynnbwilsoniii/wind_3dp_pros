;+
;PROCEDURE:	get_pmom
;PURPOSE:	Gets moment data for pesa, including velocity,density,and 
;		temperature.
;INPUT:	
;	none, but "load_3dp_data" must be called first.
;KEYWORDS:
;   NONE.
;CREATED BY:	Davin Larson
;FILE:  get_pmom.pro
;VERSION:  1.13
;LAST MODIFICATION:  97/09/08
;-
pro get_pmom, $
   
   DENSP = dens_p, $
   TEMPP = temp_p, $
   VXP   = vx_p, $
   VYP   = vy_p, $
   VZP   = vz_p, $
   PP    = pres_p, $
   DENSA = dens_a, $
   TEMPA = temp_a, $
   VXA   = vx_a, $
   VYA   = vy_a, $
   VZA   = vz_a, $
   PA    = pres_a
@wind_com.pro
if n_elements(wind_lib) eq 0 then begin
   print,'You must first load some data'
   return
endif
num = call_external(wind_lib,'get_pmom_data')
time = dblarr(num)
vcomp = intarr(num)
dens_p = fltarr(num)
temp_p = fltarr(num)
vx_p = fltarr(num)
vy_p = fltarr(num)
vz_p = fltarr(num)
pres_p = fltarr(num, 6)
dens_a = fltarr(num)
temp_a = fltarr(num)
vx_a = fltarr(num)
vy_a = fltarr(num)
vz_a = fltarr(num)
pres_a = fltarr(num, 6)

num = call_external(wind_lib,'get_pmom_data',num,time,    $
	dens_p,temp_p,vx_p,vy_p,vz_p,pres_p,              $
	dens_a,temp_a,vx_a,vy_a,vz_a,pres_a, vcomp)
  densp = {x:time,y:dens_p}
  tempp = {x:time,y:temp_p}
  vtotp = {x:time,y:[[vx_p],[vy_p],[vz_p]]}
;  vxp  =   {x:time,y:vx_p}
;  vyp  =   {x:time,y:vy_p}
;  vzp  =   {x:time,y:vz_p}
  vcomp = {x:time,y:vcomp}
  mass  = 5.6856591e-6 * 1836     ;added by fvm
  ;pres_p is actually v#v.  pp = n * m v#v
  FOR i=0,5 DO pres_p(*,i) = pres_p(*,i)*dens_p
  pres_p= pres_p*mass
  pp    = {x:time,y:pres_p}
  densa = {x:time,y:dens_a}
  tempa = {x:time,y:temp_a}
  vtota = {x:time,y:[[vx_a],[vy_a],[vz_a]]}
;  vxa  =   {x:time,y:vx_a}
;  vya  =   {x:time,y:vy_a}
;  vza  =   {x:time,y:vz_a}
  ;pres_a is actually v#v.  pa = n * m v#v
  mass  = mass*4                  ;added by fvm
  FOR i=0,5 DO pres_a(*,i) = pres_a(*,i)*dens_a
  pres_a= pres_a*mass
  pa    = {x:time,y:pres_a}
store_data,'Np',data=densp
store_data,'Tp',data=tempp
;store_data,'Vpx',data=vxp
;store_data,'Vpy',data=vyp
;store_data,'Vpz',data=vzp
store_data,'Vp',data=vtotp
store_data,'Vc',data=vcomp
store_data,'Pp',data=pp
store_data,'Na',data=densa
store_data,'Ta',data=tempa
;store_data,'Vax',data=vxa
;store_data,'Vay',data=vya
;store_data,'Vaz',data=vza
store_data,'Va',data=vtota
store_data,'Pa',data=pa
return
end


