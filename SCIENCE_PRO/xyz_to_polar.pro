;+
;*****************************************************************************************
;
;  FUNCTION :   xyz_to_polar.pro
;  PURPOSE  :   Calculates the radial magnitude, theta and phi given a 3 vector
;
;  CALLED BY:   NA
;
;  CALLS:
;               xyz_to_polar.pro
;               get_data.pro
;               str_element.pro
;               store_data.pro
;               cart_to_sphere.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA         :  Several options are allowed for the input xyz vec.
;                                 String:  TPLOT name to get data to use
;                                 Structure:  data.Y is assumed to contain [[x],[y],[z]]
;                                 [N,3]-Element Array:  [[x],[y],[z]]
;                                 [Note:  Returns values through the keywords with the
;                                    same data type as the input.]
;
;  EXAMPLES:
;               ******************
;               **Passing Arrays**
;               ******************
;               x   = FINDGEN(100)
;               y   = 2*x
;               z   = x-20
;               vec = [[x],[y],[z]]
;               xyz_to_polar,vec,MAGNITUDE=mag  ; => mag will be the magnitude
;               **********************
;               **Passing Structures**
;               **********************
;               dat = {YTITLE:'Vector',X:FINDGEN(100),Y:vec}
;               xyz_to_polar,dat,MAGNITUDE=mag,THETA=th,PHI=ph
;                        ; => mag, th, and ph will all be structures
;               *******************
;               **Passing Strings**
;               *******************
;               xyz_to_polar,'Vp'
;                        ; => new TPLOT quantities, 'Vp_mag','Vp_th','Vp_ph' will be 
;                               created
;
;  KEYWORDS:  
;               MAGNITUDE    :  Named variable to return the radial magnitude
;               THETA        :  Named variable to return the poloidal angles (deg)
;               PHI          :  Named variable to return the azimuthal angles (deg)
;               TAGNAME      :  String defining the structure tag name to use
;               MAX_VALUE    :  Named variable to return the 
;               MIN_VALUE    :  Named variable to return the 
;               MISSING      :  Set to the value you wish to replace "bad" data with
;               CLOCK        :  If set, when calling cart_to_sphere.pro set the 
;                                 Y-Parameter to its negative
;               CO_LATITUDE  :  If set, THETA returned between 0.0 and 180.0 degrees
;               PH_0_360     :  IF > 0, 0 <= PHI <= 360
;                               IF = 0, -180 <= PHI <= 180
;                               IF < 0, ***if negative, best guess phi range returned***
;               PH_HIST      :  2-Element array of max and min values for PHI
;                                 [e.g. IF PH_0_360 NOT set and PH_HIST=[-220,220] THEN
;                                   if d(PHI)/dt is positive near 180, then
;                                   PHI => PHI+360 when PHI passes the 180/-180 
;                                   discontinuity until phi reaches 220.]
;
;   CHANGED:  1)  Davin Larson changed something...       [??/??/????   v1.0.?]
;             2)  Re-wrote and cleaned up                 [06/21/2009   v1.1.0]
;             3)  Fixed typo in re-write                  [09/26/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/26/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO xyz_to_polar,data, MAGNITUDE=magnitude, THETA=theta, PHI=phi, TAGNAME=tagname, $
                       MAX_VALUE=max_value, MIN_VALUE=min_value, MISSING=missing,  $
                       CLOCK=clock, CO_LATITUDE=co_latitude, PH_0_360=ph_0_360,    $
                       PH_HIST=ph_hist

;-----------------------------------------------------------------------------------------
; => Determine type code of input
;-----------------------------------------------------------------------------------------
ntyp0 = (SIZE(data,/TYPE))[0]
CASE ntyp0 OF
  ;---------------------------------------------------------------------------------------
  ; => Strings
  ;---------------------------------------------------------------------------------------
  7    : BEGIN
    get_data,data,DATA=struct                   ;,limits=lim
    str_element,struct,'MAX_VALUE',VALUE=max_value
    str_element,struct,'MIN_VALUE',VALUE=min_value
    ntyp1 = (SIZE(struct,/TYPE))[0]
    ;-------------------------------------------------------------------------------------
    IF (ntyp1 NE 8L) THEN RETURN       ; => Error
    ;-------------------------------------------------------------------------------------
    xyz_to_polar,struct,MAGNITUDE=mag_struct,THETA=th_struct,PHI=ph_struct,          $
                 TAGNAME=tagname,CLOCK=clock,MAX_VALUE=max_value,MIN_VALUE=min_value,$
                 CO_LATITUDE=co_latitude,PH_0_360=ph_0_360,PH_HIST=ph_hist
    magnitude = data+'_mag'
    theta     = data+ (KEYWORD_SET(clock) ? '_con' : '_th')
    phi       = data+ (KEYWORD_SET(clock) ? '_clk' : '_phi')
    ;-------------------------------------------------------------------------------------
    ; => Send new data to TPLOT
    ;-------------------------------------------------------------------------------------
    store_data,magnitude,DATA=mag_struct
    store_data,theta    ,DATA=th_struct
    store_data,phi      ,DATA=ph_struct,DLIM={YNOZERO:1}
  END
  ;---------------------------------------------------------------------------------------
  ; => Structures
  ;---------------------------------------------------------------------------------------
  8    : BEGIN
    IF KEYWORD_SET(tagname) THEN BEGIN
      str_element,data,tagname,VALUE=v
      v = TRANSPOSE(v)
    ENDIF ELSE BEGIN
      v = data.Y
    ENDELSE
    ;-------------------------------------------------------------------------------------
    ; => Re-Run with appropriate input
    ;-------------------------------------------------------------------------------------
    xyz_to_polar,v,MAGNITUDE=mag_val,THETA=theta_val,PHI=phi_val,$
                   MAX_VALUE=max_value,MIN_VALUE=min_value,      $
                   MISSING=missing,CLOCK=clock,PH_HIST=ph_hist,  $
                   CO_LATITUDE=co_latitude,PH_0_360=ph_0_360
    IF KEYWORD_SET(tagname) THEN BEGIN
      str_element,/ADD_REPLACE,data,tagname+'_MAG',mag_val
      str_element,/ADD_REPLACE,data,tagname+'_TH',theta_val
      str_element,/ADD_REPLACE,data,tagname+'_PHI',phi_val
    ENDIF ELSE BEGIN
      str_element,data,'YTITLE',VALUE=yt
      IF KEYWORD_SET(yt) THEN yt = yt ELSE yt = ''
      magnitude = {X:data.X, Y:mag_val}
      theta     = {X:data.X, Y:theta_val}
      phi       = {X:data.X, Y:phi_val}
;      IF (yt[0] NE '') THEN str_element,/ADD_REPLACE,magnitude,'YTITLE',yt[0]+' (mag)'
;      IF (yt[0] NE '') THEN str_element,/ADD_REPLACE,theta,'YTITLE',yt[0]+' (theta)'
;      IF (yt[0] NE '') THEN str_element,/ADD_REPLACE,phi,'YTITLE',yt[0]+' (phi)'
    ENDELSE
  END
  ;---------------------------------------------------------------------------------------
  ; => Float/Double Arrays
  ;---------------------------------------------------------------------------------------
  ELSE : BEGIN
    ndim0 = (SIZE(data,/N_DIMENSIONS))[0]
    IF (ndim0 EQ 2) THEN BEGIN
      x = data[*,0]
      y = data[*,1]
      z = data[*,2]
    ENDIF ELSE BEGIN
      x = data[0]
      y = data[1]
      z = data[2]
    ENDELSE
    ;-------------------------------------------------------------------------------------
    ; => Get polar angles
    ;-------------------------------------------------------------------------------------
    IF KEYWORD_SET(clock) THEN BEGIN
      cart_to_sphere,z,-y,x,magnitude,theta,phi,$
                     CO_LATITUDE=co_latitude,PH_0_360=ph_0_360,PH_HIST=ph_hist
    ENDIF ELSE BEGIN
      cart_to_sphere,x,y,z,magnitude,theta,phi,$
                     CO_LATITUDE=co_latitude,PH_0_360=ph_0_360,PH_HIST=ph_hist
    ENDELSE
    IF KEYWORD_SET(max_value) THEN BEGIN
      ind = WHERE(x GE max_value,count)
      IF (count GT 0) THEN BEGIN
        IF (N_ELEMENTS(missing) EQ 0) THEN missing = MAX(x,/NAN)
        magnitude[ind] = missing
        theta[ind]     = missing
        phi[ind]       = missing
      ENDIF
    ENDIF
    IF KEYWORD_SET(min_value) THEN BEGIN
      ind = WHERE(x LE min_value,count)
      IF (count GT 0) THEN BEGIN
        IF (N_ELEMENTS(missing) EQ 0) THEN missing = MIN(x,/NAN)
        magnitude[ind] = missing
        theta[ind]     = missing
        phi[ind]       = missing
      ENDIF
    ENDIF
  END
ENDCASE

RETURN
END
