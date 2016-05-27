;+
;*****************************************************************************************
;
;  FUNCTION :   cart_to_sphere.pro
;  PURPOSE  :   Transforms from cartesian to spherical coordinates.
;
;  CALLED BY: 
;               xyz_to_polar.pro
;               add_df2dp.pro
;               add_df2d_to_ph.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               X            :  N-Element array of cartesian X-component data points
;               Y            :  N-Element array of cartesian Y-component data points
;               Z            :  N-Element array of cartesian Z-component data points
;               R            :  Named variable to return the radial magnitudes in 
;                                 spherical coordinates
;               THETA        :  Named variable to return the poloidal angles (deg)
;               PHI          :  Named variable to return the azimuthal angles (deg)
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               PH_0_360     :  IF > 0, 0 <= PHI <= 360
;                               IF = 0, -180 <= PHI <= 180
;                               IF < 0, ***if negative, best guess phi range returned***
;               PH_HIST      :  2-Element array of max and min values for PHI
;                                 [e.g. IF PH_0_360 NOT set and PH_HIST=[-220,220] THEN
;                                   if d(PHI)/dt is positive near 180, then
;                                   PHI => PHI+360 when PHI passes the 180/-180 
;                                   discontinuity until phi reaches 220.]
;               CO_LATITUDE  :  If set, THETA returned between 0.0 and 180.0 degrees
;               MIN_VALUE    :  ? Not really sure ?
;               MAX_VALUE    :  ? Not really sure ?
;
;   CHANGED:  1)  Davin Larson changed something...       [04/17/2002   v1.0.13]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/21/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO cart_to_sphere,x,y,z,r,theta,phi,PH_0_360=ph_0_360,PH_HIST=ph_hist,     $
                                     CO_LATITUDE=co_lat,MIN_VALUE=min_value,$
                                     MAX_VALUE=max_value

;-----------------------------------------------------------------------------------------
; => Define some parameters
;-----------------------------------------------------------------------------------------
rho   = x*x + y*y                     ; => Cylindrical coordinate \rho
r     = SQRT(rho + z*z)               ; => Spherical coordinate radius
phi   = 18e1/!DPI*ATAN(y,x)           ; => Spherical coordinate azimuthal angle (deg)
theta = 18e1/!DPI*ATAN(z/ SQRT(rho))  ; => " " poloidal angle (deg)
IF KEYWORD_SET(co_lat) THEN theta = 9e1 - theta

ph_mid = 0                      ; => middle value of phi
IF NOT KEYWORD_SET(ph_0_360) THEN ph_0_360 = 0
IF (ph_0_360 NE 0) THEN BEGIN
  tmp_phi = phi                 
  a = WHERE((phi GE -180) AND (phi LT 0),acount)
  IF (acount ne 0) THEN tmp_phi[a] = tmp_phi[a] + 360        ; => Make 0 <= tmp_phi <= 360
  IF ((ph_0_360 LT 0) AND (N_ELEMENTS(phi) GT 1)) THEN BEGIN ; => Auto range phi
    subt = [[-1],[1]]                                        ; => [a,b] ## subt = b - a
    mmp  = (CEIL(minmax(phi,    MIN=-360,MAX=360)##subt))[0] ; => phi range
    mmtp = (CEIL(minmax(tmp_phi,MIN=-360,MAX=360)##subt))[0] ; => tmp range
    IF (mmp eq mmtp) THEN BEGIN ; => if ranges are equal, choose one with fewer branch cuts
      a = WHERE(ABS(TS_DIFF(phi,    1)) GT 300,bcount)
      a = WHERE(ABS(TS_DIFF(tmp_phi,1)) GT 300,ccount)
      IF (bcount GT ccount) THEN ph_mid = 180
    ENDIF ELSE IF (mmp GT mmtp) THEN ph_mid = 180 
  ENDIF ELSE ph_mid = 180                                    ; => if ph_0_360 positive
  IF (ph_mid EQ 180) THEN phi = tmp_phi
  tmp_phi = 0                                                ; => deallocate memory
ENDIF 

IF KEYWORD_SET(ph_hist) THEN BEGIN
  ndim0 = (SIZE(ph_hist,/DIMENSIONS))[0]
  ntyp0 = (SIZE(ph_hist,/TYPE))[0]
  IF (ndim0 NE 2) OR (ntyp0 GE 6) THEN BEGIN
    PRINT,'PH_HIST should be a two element array of numbers'
    PRINT,'Ignoring request.'
  ENDIF ELSE BEGIN
    FOR i=1L, N_ELEMENTS(phi) - 1L DO BEGIN
      test0 = (phi[i-1] GT ph_mid)
      test1 = (phi[i] LT ph_mid)
      test2 = (phi[i] LT ph_hist[1] - 360)
      testf = (test0 AND test1 AND test2)
      IF (testf) THEN phi[i] += 36e1
      test0 = (phi[i-1] LT ph_mid)
      test1 = (phi[i] GT ph_mid)
      test2 = (phi[i] GT ph_hist[1] - 360)
      testf = (test0 AND test1 AND test2)
      IF (testf) THEN phi[i] -= 36e1
    ENDFOR
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Define min ranges
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(min_value) NE 0) THEN BEGIN
   bad  = WHERE(x LE min_value,count)
   minx = MIN(x,/NAN)
   IF (count NE 0) THEN BEGIN
      r[bad]     = minx[0]
      theta[bad] = minx[0]
      phi[bad]   = minx[0]
   ENDIF
ENDIF
;-----------------------------------------------------------------------------------------
; => Define max ranges
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(max_value) NE 0) THEN BEGIN
   bad = WHERE(x GE max_value,count)
   maxx = MAX(x,/NAN)
   IF (count NE 0) THEN BEGIN
      r[bad]     = maxx[0]
      theta[bad] = maxx[0]
      phi[bad]   = maxx[0]
   ENDIF
ENDIF
;-----------------------------------------------------------------------------------------
; => If x input is float, make angles floats
;-----------------------------------------------------------------------------------------
ntyp0 = (SIZE(x[0],/TYPE))[0]
IF (ntyp0 EQ 4) THEN BEGIN 
  theta = FLOAT(theta)
  phi   = FLOAT(phi)
ENDIF

RETURN
END

