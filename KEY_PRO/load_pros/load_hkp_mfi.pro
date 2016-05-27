;+
;PROCEDURE:	load_hkp_mfi
;PURPOSE:
;	Creates TPLOT magnetic field variables from 3DP housekeeping data.
;	To be used when key parameter file is not available.
;INPUTS:
;	none
;KEYWORDS:
;	none
;NOTES:
;	3DP housekeeping data gives direction of magnetic field only.  A
;	magnitude of 1 is assumed to create these variables.
;CREATED BY:	Peter Schroeder
;LAST MODIFIED:	%W% %E%
;-
pro load_hkp_mfi
	get_hkp
	get_data,'hkp_magel',ptr=magel
	get_data,'hkp_magaz',ptr=magaz
	newmagel = double(*magel.y) - 90d
	newmagaz = 360d - double(*magaz.y)/4096d*360d
	sphere_to_cart,1.,newmagel,newmagaz,magx,magy,magz
	magf = dblarr(n_elements(magx),3)
	magf(*,0) = magx
	magf(*,1) = magy
	magf(*,2) = magz
	store_data,'wi_B',data={x: magel.x, y: magf}
	get_data,'wi_B',ptr=pdata
	store_data,'wi_B3',data=pdata
return
end