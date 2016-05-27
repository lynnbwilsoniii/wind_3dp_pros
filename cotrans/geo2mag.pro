;+
; NAME:
;       geo2mag
;
; PURPOSE:
;       Convert from geographic to geomagnetic coordinates
;
; CALLING SEQUENCE:
;       geo2mag, data_in, data_out, time
;
; INPUT:
;       time = an array [n] of double precision time in seconds from 1970-Jan-01/00:00:00.000
;       data_in = an array [n,3] of position data in km. in GEO coordinates or a tplot variable
;
; KEYWORD INPUTS:
;       None
;
; OUTPUT:
;       data_out = an array [n,3] of the input data in MAG coordinates                    
;
; EXAMPLE:
;    if data_in is a tplot variable:
;       IDL> geo2mag, data_in, data_out
;    otherwise:
;       IDL> geo2mag, data_in, data_out, time
;
; NOTES:
;
;       The algorithm and rotational matrices were developed by Pascal Saint-Hilaire 
;       (Saint-Hilaire@astro.phys.ethz.ch), May 2002
;
; MODIFICATION HISTORY:
;               
;-

;====================================================================================
PRO geo2mag, data_in, data_out, time

; if this is a tplot variable retrieve the data
IF n_params() EQ 2 THEN BEGIN
   get_data, data_in, data=d, dlimits=dl, limits=l
   time=d.x
   data=d.y
ENDIF ELSE BEGIN 
   data=data_in
ENDELSE

; longitude and latitude (in degrees) of Earth's magnetic south pole
; (which is near the geographic north pole!) 
; create array sm=[0,0,1] - essentially the position of the pole
sm = make_array(n_elements(time), 3, /double)
sm[*,2] = 1.d
gsm = sm

;disable transform notifications, as the trick below is not actually transforming the requested data, the dprint messages can be a little confusing
dprint,getdebug=gd
dprint,setdebug=-10

; convert sm to geo
cotrans, sm, gsm, time, /SM2GSM
cotrans, gsm, gse, time, /GSM2GSE
cotrans, gse, gei, time, /GSE2GEI
cotrans, gei, geo, time, /GEI2GEO

;restore previous verbosity
dprint,setdebug=gd

; convert cartesian to spherical coordinates
xyz_to_polar, geo, magnitude=r, theta=lat, phi=long

; convert to radians
long=long*!DPI/180.
lat=lat*!DPI/180.

npts = long(n_elements(data[*,0])-1)
d_out= data

FOR i=0L,npts DO BEGIN

        x = data[i,0]
        y = data[i,1]
        z = data[i,2]

        ;Compute 1st rotation matrix : rotation around plane of the equator,
        ;from the Greenwich meridian to the meridian containing the magnetic
        ;dipole pole.
        maglong = dblarr(3,3)
        maglong[0,0] = cos(long[i])
        maglong[0,1] = sin(long[i])
        maglong[1,0] = -sin(long[i])
        maglong[1,1] = cos(long[i])
        maglong[2,2] = 1.
        out=maglong # [x,y,z]

        ;Second rotation : in the plane of the current meridian from geographic
        ;                  pole to magnetic dipole pole.
        maglat = dblarr(3,3)
        maglat[0,0] = cos(!DPI/2-lat[i])
        maglat[0,2] = -sin(!DPI/2-lat[i])
        maglat[2,0] = sin(!DPI/2-lat[i])
        maglat[2,2] = cos(!DPI/2-lat[i])
        maglat[1,1] = 1.
        d_out[i,*]= maglat # out
 
ENDFOR

; update tplot variable or return data array
IF n_params() EQ 2 THEN BEGIN
   d.y = d_out
   dl.data_att.coord_sys='mag'
   store_data, data_out, data=d, dlimits=dl, limits=l
ENDIF ELSE BEGIN
   data_out = d_out
ENDELSE
               
END
;===============================================================================