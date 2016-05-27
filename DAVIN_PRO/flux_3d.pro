


function flux_3d, data, sc_pot ,pardens=pardens

if n_elements(sc_pot) eq 0 then sc_pot = 0.

if data.valid eq 0 then begin
  print,'Invalid Data'
  return, !values.f_nan
endif

data3d = conv_units(data,"eflux")		; Use Energy Flux

e = data3d.energy
de = data3d.denergy
domega = replicate(1.,data3d.nenergy) # data3d.domega

dvolume =  de / e * domega
data_dv = data3d.data * dvolume

e_inf = (e - sc_pot) > 0.

mass = data3d.mass


;Density calculation:

dweight = sqrt(e_inf)/e
pardens = data_dv * dweight
density = sqrt(mass/2.) * total(pardens) * 1e-5  ; 1/cm^3

;FLUX calculation

sin_phi = sin(data3d.phi/!radeg)
cos_phi = cos(data3d.phi/!radeg)
sin_th  = sin(data3d.theta/!radeg)
cos_th  = cos(data3d.theta/!radeg)
cos2_th = cos_th^2
cthsth  = cos_th*sin_th

fwx = cos_phi * cos_th * e_inf / e
fwy = sin_phi * cos_th * e_inf / e
fwz = sin_th * e_inf / e

parfluxx = data_dv * fwx
parfluxy = data_dv * fwy
parfluxz = data_dv * fwz
fx = total(parfluxx)
fy = total(parfluxy)
fz = total(parfluxz)

flux = [fx,fy,fz]     ; Units: 1/s/cm^2


vfww  = data_dv * e_inf^1.5 / e

pvfwxx = cos_phi^2 * cos2_th          * vfww
pvfwyy = sin_phi^2 * cos2_th          * vfww
pvfwzz = sin_th^2                     * vfww
pvfwxy = cos_phi * sin_phi * cos2_th  * vfww
pvfwxz = cos_phi * cthsth             * vfww
pvfwyz = sin_phi * cthsth             * vfww

vfxx = total(pvfwxx) 
vfyy = total(pvfwyy)
vfzz = total(pvfwzz)
vfxy = total(pvfwxy)
vfxz = total(pvfwxz)
vfyz = total(pvfwyz)

mftens = [vfxx,vfyy,vfzz,vfxy,vfxz,vfyz] * (sqrt(2/mass) * 1e5)
; units:   1/cm/s^2

return, mftens
end
