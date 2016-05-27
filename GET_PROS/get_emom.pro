;+
;PROCEDURE:	get_emom
;PURPOSE:	Gets moment data for eesa, including velocity,density,and 
;		temperature.
;INPUT:	
;	none, but "load_3dp_data" must be called 1st.
;KEYWORDS:
;	dens:	Optionally returns density directly as well as storing it.
;	temp:	Optionally returns temperature directly as well as storing it.
;	vx:	Optionally returns vx directly as well as storing it.
;	vy:	Optionally returns vy directly as well as storing it.
;	vz:	Optionally returns vz directly as well as storing it.
;	pe:	Optionally returns Pe directly as well as storing it.
;	qe:	Optionally returns Qe directly as well as storing it.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)get_emom.pro	1.9 97/09/08
;
;
; MODIFIED BY: Lynn B. Wilson III
;  DATE MODIFIED: 06-13-2007
;-

pro get_emom, $
   DENS = dens, $
   TEMP = temp, $
   VX   = vx, $
   VY   = vy, $
   VZ   = vz, $
   Pe   = pres_e, $
   Qe   = heat_flux
@wind_com.pro
if n_elements(wind_lib) eq 0 then begin
   print,'You must first load some data'
   return
endif
num = call_external(wind_lib,'get_emom_data')
time = dblarr(num)
dens = fltarr(num)
temp = fltarr(num)
vx = fltarr(num)
vy = fltarr(num)
vz = fltarr(num)
pres_e = fltarr(num, 6)
heat_flux = fltarr(num, 3)
num = call_external(wind_lib,'get_emom_data',num,time,dens,temp,vx,vy,vz,   $
	pres_e, heat_flux)
  dens = {x:time,y:dens}
  temp = {x:time,y:temp}
  vtot = {x:time,y:[[vx],[vy],[vz]]}
;  vx =   {x:time,y:vx}
;  vy =   {x:time,y:vy}
;  vz =   {x:time,y:vz}
  mass = 5.6856591e-6             ;added by fvm
  ;pres_e is actually v#v.  pe = n * m v#v
  
;*****************************************************************************
; The mass is actually a compilation of values
;  m_e/K_B = 6.59767e-8 (deg K s^2/m^2)
;  The velocities are in km/s => need to convert
;  Since it's v^2, then the conversion factor is 10^6
; 10.^6 * 6.59767e-8 = 0.0659767 (" ")
;
; The energy associated w/ 1 deg K = 8.6174e-5 eV
;
; => 0.0659767*8.6174e-5 = 5.68548e-6
;
  
  FOR i=0,5 DO pres_e(*,i) = pres_e(*,i)*dens.y
  pe =   {x:time,y:pres_e*mass}
  qe =   {x:time,y:heat_flux}
store_data,'Ne',data=dens
store_data,'Te',data=temp
;store_data,'Vex',data=vx
;store_data,'Vey',data=vy
;store_data,'Vez',data=vz
store_data,'Ve',data=vtot
store_data,'Pe',data=pe
store_data,'Qe',data=qe
return
end

