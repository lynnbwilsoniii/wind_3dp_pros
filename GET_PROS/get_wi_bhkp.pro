pro get_wi_bhkp,polar=polar

get_hkp,data=d,/no_tplot
newmagel = float(d.magel) - 90.
;newmagel = 90. - float(d.magel) 
newmagaz = 360. - float(d.magaz)/4096.*360.
sphere_to_cart,1.,newmagel,newmagaz,magx,magy,magz
magf = fltarr(n_elements(magx),3)
magf(*,0) = magx
magf(*,1) = magy
magf(*,2) = magz
store_data,'wi_Bhkp',data={x: d.time, y: magf}
if keyword_set(polar) then xyz_to_polar,'wi_Bhkp',/ph_0_360
end
