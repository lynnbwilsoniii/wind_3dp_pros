;+
;*****************************************************************************************
;
;  FUNCTION :   wind_orbit_to_tplot.pro
;  PURPOSE  :   Reads in Wind spacecraft orbit data, calculates Solar Magnetic (SM)
;                 coordinates and MLT, then sends to TPLOT.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               read_wind_orbit.pro
;               get_data.pro
;               interp.pro
;               store_data.pro
;               options.pro
;               cotrans.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII Files created by SPDF Data Orbit Services
;                     [see read_wind_orbit.pro for more details]
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               t           = '1996-11-11/'+['14:12:16','16:12:16']
;               date        = '111196'
;               tr3         = time_double(t)
;               ;.........................................................................
;               ; => Load B-field data
;               ;.........................................................................
;               mfi3s       = read_wind_mfi(TRANGE=tr3)
;               bgse        = mfi3s.BGSE
;               bmags       = mfi3s.MAG
;               store_data,'wi_B3_MAG',DATA=bmags
;               store_data,'wi_B3_GSE',DATA=bgse
;               ;.........................................................................
;               ; => Load orbit data
;               ;.........................................................................
;               wind_orbit_to_tplot,BNAME='wi_B3_GSE',TRANGE=tr3
;
;  KEYWORDS:    
;               DATE     :  [string] Scalar or array of the form:
;                             'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE   :  [Double] 2 element array specifying the range over 
;                             which to get data structures [Unix time]
;               BNAME    :  Scalar string defining the TPLOT name of the B-field
;                             times you wish to interpolate the positions to
;                             [Default = first TPLOT handle available]
;
;   CHANGED:  1)  Added an error handling statement for when read_wind_orbit.pro
;                   does not return a structure                    [03/20/2012   v1.0.1]
;
;   NOTES:      
;               1)  If no TPLOT handles are found or set, then the time stamps in the
;                     ASCII files are used
;
;   CREATED:  02/10/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/20/2012   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO wind_orbit_to_tplot,DATE=date,TRANGE=trange,BNAME=bname

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
R_e            = 6.37814d3             ; => Earth's Equitorial Radius (km)

IF KEYWORD_SET(bname) THEN tbname = bname[0] ELSE tbname = (tnames())[0]
;-----------------------------------------------------------------------------------------
; => Load orbit data
;-----------------------------------------------------------------------------------------
read_wind_orbit,DATE=date,TRANGE=trange,DATA=windloc
;-----------------------------------------------------------------------------------------
; => Define orbit data elements
;-----------------------------------------------------------------------------------------
IF (SIZE(windloc,/TYPE) NE 8) THEN RETURN
gseunx  = windloc.UNIX             ; => Unix times for positions

gseloc  = windloc.GSE_POSITION     ; => GSE Cartesian position (km)
gselat  = windloc.GSE_LAT          ; => GSE Latitude (deg)
gselon  = windloc.GSE_LONG         ; => GSE Longitude (deg)
gsmloc  = windloc.GSM_POSITION     ; => GSM Cartesian position (km)
gsmlat  = windloc.GSM_LAT          ; => GSM Latitude (deg)
gsmlon  = windloc.GSM_LONG         ; => GSM Longitude (deg)
radial  = windloc.RADIAL_DISTANCE  ; => Radial distance from Earth (km)
radial *= 1d0/R_e

lshell  = windloc.LSHELL           ; => Magnetic L-Shell
invlat  = windloc.INVAR_LAT        ; => Invariant Latitude (deg)

IF (tbname[0] NE '') THEN BEGIN
  ; => TPLOT handle found
  get_data,tbname[0],DATA=tpstr
  tp_t    = tpstr.X
  ; => Interpolate data to TPLOT times
  testx   = INTERPOL(gseloc[*,0],gseunx,tp_t,/SPLINE)
  testy   = INTERPOL(gseloc[*,1],gseunx,tp_t,/SPLINE)
  testz   = INTERPOL(gseloc[*,2],gseunx,tp_t,/SPLINE)
  gse_pos = [[testx],[testy],[testz]]
  gse_lat = interp(gselat,gseunx,tp_t,/NO_EXTRAP)
  gse_lon = interp(gselon,gseunx,tp_t,/NO_EXTRAP)
  testx   = INTERPOL(gsmloc[*,0],gseunx,tp_t,/SPLINE)
  testy   = INTERPOL(gsmloc[*,1],gseunx,tp_t,/SPLINE)
  testz   = INTERPOL(gsmloc[*,2],gseunx,tp_t,/SPLINE)
  gsm_pos = [[testx],[testy],[testz]]
  gsm_lat = interp(gsmlat,gseunx,tp_t,/NO_EXTRAP)
  gsm_lon = interp(gsmlon,gseunx,tp_t,/NO_EXTRAP)
  rad_pos = INTERPOL(radial,gseunx,tp_t,/SPLINE)
  lsh_pos = INTERPOL(lshell,gseunx,tp_t,/SPLINE)
  inv_lat = INTERPOL(invlat,gseunx,tp_t,/SPLINE)
ENDIF ELSE BEGIN
  ; => TPLOT handle not found
  ;      load given values
  gse_pos = gseloc
  gse_lat = gselat
  gse_lon = gselon
  gsm_pos = gsmloc
  gsm_lat = gsmlat
  gsm_lon = gsmlon
  rad_pos = radial
  lsh_pos = lshell
  inv_lat = invlat
  ; => define time stamp
  tp_t    = gseunx
ENDELSE
;-----------------------------------------------------------------------------------------
; => Send orbit data to TPLOT
;-----------------------------------------------------------------------------------------
store_data,'Wind_Radial_Distance',DATA={X:tp_t,Y:rad_pos}
store_data,'Wind_GSE_Location',DATA={X:tp_t,Y:gse_pos}
store_data,'Wind_GSE_Latitude',DATA={X:tp_t,Y:gse_lat}
store_data,'Wind_GSE_Longitude',DATA={X:tp_t,Y:gse_lon}
store_data,'Wind_GSM_Location',DATA={X:tp_t,Y:gsm_pos}
store_data,'Wind_GSM_Latitude',DATA={X:tp_t,Y:gsm_lat}
store_data,'Wind_GSM_Longitude',DATA={X:tp_t,Y:gsm_lon}
store_data,'Wind_L-Shell',DATA={X:tp_t,Y:lsh_pos}
store_data,'Wind_Invariant_Latitude',DATA={X:tp_t,Y:inv_lat}

nn0     = ['Wind_GSE_Location','Wind_GSM_Location']
; => define some TPLOT options
options,nn0,'COLORS',[250,150,50]
options,'Wind_Radial_Distance',   'YTITLE','Radial Distance [R!DE!N'+']'
options,'Wind_GSE_Location',      'YTITLE','Wind Position [GSE, km]'
options,'Wind_GSE_Latitude',      'YTITLE','Wind Latitude [GSE, deg]'
options,'Wind_GSE_Longitude',     'YTITLE','Wind Longitude [GSE, deg]'
options,'Wind_GSM_Location',      'YTITLE','Wind Position [GSM, km]'
options,'Wind_GSM_Latitude',      'YTITLE','Wind Latitude [GSM, deg]'
options,'Wind_GSM_Longitude',     'YTITLE','Wind Longitude [GSM, deg]'
options,'Wind_L-Shell',           'YTITLE','L-Shell'
options,'Wind_Invariant_Latitude','YTITLE','Invariant Latitude [deg]'
;-----------------------------------------------------------------------------------------
; => Convert GSM to SM
;-----------------------------------------------------------------------------------------
cotrans,'Wind_GSM_Location','Wind_SM_Location',/GSM2SM
get_data,'Wind_SM_Location',DATA=wind_sm_loc
;-----------------------------------------------------------------------------------------
; => Calculate Magnetic Local Time (MLT)
;-----------------------------------------------------------------------------------------
nm       = N_ELEMENTS(tp_t)
mloctime = DBLARR(nm)  ; => Magnetic Local Time
mloctime = ATAN(wind_sm_loc.Y[*,1]/wind_sm_loc.Y[*,0])*18d1/!DPI/15d0 + 12d0
; => Check for negative X-SM coordinate points
low_tmp  = WHERE(wind_sm_loc.Y[*,0] LT 0d0,lwtp)
IF (lwtp GT 0L) THEN BEGIN
  t_x               = wind_sm_loc.Y[low_tmp,0]
  t_y               = wind_sm_loc.Y[low_tmp,1]
  mloctime[low_tmp] = (ATAN(t_y/t_x) + !DPI)*18d1/(!DPI*15d0) + 12d0
ENDIF
; => Check for MLTs > 24
hig_mloc = WHERE(mloctime GE 24d0,mlc)
IF (mlc GT 0L) THEN BEGIN
  mloctime[hig_mloc] = mloctime[hig_mloc] - 24d0
ENDIF
dlim = {LABLES:['MLT'],YSUBTITLE:'[hr]',LABFLAG:-1,CONSTANT:0,YTITLE:'Wind MLT'}
store_data,'Wind_MLT',DATA={X:tp_t,Y:mloctime},DLIM=dlim

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------

RETURN
END
