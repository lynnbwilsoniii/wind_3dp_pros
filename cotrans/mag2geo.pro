;+
; NAME:
;      mag2geo.pro
;
; PURPOSE:
;     Convert from geomagnetic to geographic coordinates
;
; CALLING SEQUENCE:
;       mag2geo, data_in, data_out, time
;
; INPUT:
;       data_in = an [n,3] element array of position data in km and in
;                MAG coordinates or a tplot variable
;                
;       time = an n-element array containing double precision time values 
;              corresponding to the points in data_in
;
; KEYWORD INPUTS:
;               None
;
; OUTPUT:
;       data_out = an [n,3] element array of position data in km in
;                 newly transformed GEO coordinates
;
; EXAMPLE:
;    if data_in is a tplot variable:
;       IDL> mag2geo, data_in, data_out
;    otherwise:
;       IDL> mag2geo, data_in, data_out, time 
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
PRO mag2geo, data_in, data_out, time

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
xyz_to_polar, geo,  magnitude=r, theta=lat, phi=long  

; convert to radians
long=long*!DPI/180.
lat=lat*!DPI/180.

npts = long(n_elements(data[*,0])-1)
d_out= data

FOR i=0L,npts DO BEGIN

        x = data[i,0]
        y = data[i,1]
        z = data[i,2]

        ;First rotation : in the plane of the current meridian from magnetic 
        ;pole to geographic pole.
        geolat = dblarr(3,3)
        geolat[0,0] = cos(!DPI/2-lat[i])
        geolat[0,2] = sin(!DPI/2-lat[i])
        geolat[2,0] = -sin(!DPI/2-lat[i])
        geolat[2,2] = cos(!DPI/2-lat[i])
        geolat[1,1] = 1.
        out = geolat # [x,y,z]

        ;Second rotation matrix : rotation around plane of the equator, from
        ;the meridian containing the magnetic poles to the Greenwich meridian.
        geolong = dblarr(3,3)
        geolong[0,0] = cos(long[i])
        geolong[0,1] = -sin(long[i])
        geolong[1,0] = sin(long[i])
        geolong[1,1] = cos(long[i])
        geolong[2,2] = 1.
        d_out[i,*] = geolong # out

ENDFOR

IF n_params() EQ 2 THEN BEGIN
   d.y = d_out
   dl.data_att.coord_sys='geo'
   store_data, data_out, data=d, dlimits=dl, limits=l
ENDIF ELSE BEGIN
   data_out = d_out
ENDELSE
        
END
;====================================================================================