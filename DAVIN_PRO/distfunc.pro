;+
;*****************************************************************************************
;
;  FUNCTION :   distfunc.pro
;  PURPOSE  :   Interpolates distribution function in a smooth manner returning a
;                 data structure with the velocities parallel and perpendicular to the
;                 magnetic field for each given data point.
;
;  CALLED BY:   NA
;
;  CALLS:
;               velocity.pro
;               distfunc.pro
;               distfunc_template.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               VPAR     :  An array of data corresponding to either the energy or 
;                             parallel(wrt B-field) velocity associated with the data
;               VPERP    :  An array of data corresponding to either the angle or the
;                             perpendicular velocity associated with the data
;
;  EXAMPLES:
;               test  = distfunc(dat.ENERGY,dat.ANGLE,MASS=dat.MASS,DF=dat.DATA)
;               test  = distfunc(vpar,vperp,PARAM=dfpar) 
;               
;               dfpar = distfunc(vx0,vy0,df=df0)   
;                   => Create structure dfpar using values of df0 known at the 
;                         positions of vx0,vy0 as a structure
;               df_new = distfunc(vx_new,vy_new,par=dfpar)   
;                   => returns interpolated values of df at the new points as an array
;
;  KEYWORDS:  
;               TEMPLATE :  used to create a template of what data structure 
;                            should look like if sending in an array of structures 
;                            with possible bad data
;               DF       :  [float] Array of data from my_pad_dist.pro
;               PARAM    :  A 3D data structure with the tag names VX0, VY0, and DFC
;               MASS     :  [float] Value representing the mass of particles for the
;                             distribution of interest [eV/(km/sec)^2]
;               DEBUG    :  Forces program to stop before returning for debugging
;
;   CHANGED:  1)  Davin Larson changed something...          [??/??/????   v1.0.?]
;             2)  Got rid of pointers                        [09/15/2007   v1.1.0]
;             3)  Forced a universal array size to be returned if DF is set
;                  {prevents conflicting data structures when multiple calls 
;                    to this program are made}               [11/20/2007   v1.2.0]
;             4)  Created a dummy structure template for returning if no data
;                  is finite or available for error handling in multiple calls
;                  [calls my_distfunc_template.pro]          [02/05/2008   v1.3.9]
;             5)  Updated man page                           [02/25/2009   v1.3.10]
;             6)  Changed return values and robustness       [02/25/2009   v1.3.11]
;             7)  Nothing functional changed                 [04/08/2009   v1.3.12]
;             8)  Updated man page and cleaned up            [06/22/2009   v1.4.0]
;             9)  Changed my_distfunc_template.pro to distfunc_template.pro
;                                                            [07/20/2009   v1.4.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  07/20/2009   v1.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  distfunc,vpar,vperp,DF=df,PARAM=dfpar,MASS=mass,DEBUG=debug,TEMPLATE=mytemp

;-----------------------------------------------------------------------------------------
; => Check input parameters
;-----------------------------------------------------------------------------------------
IF (SIZE(vpar,/TYPE) EQ 8) THEN BEGIN
   RETURN,distfunc(vpar.ENERGY,vpar.ANGLES,MASS=vpar.MASS,PARAM=dfpar,DF=df)
ENDIF
IF KEYWORD_SET(mytemp) THEN BEGIN
  dftemp = mytemp
ENDIF ELSE BEGIN
  dftemp = distfunc_template(vpar,vperp,DF=df,PARAM=dfpar,MASS=mass)
ENDELSE

IF KEYWORD_SET(mass) THEN BEGIN
   vx = velocity(vpar,mass) * COS(vperp*!DTOR)
   vy = velocity(vpar,mass) * SIN(vperp*!DTOR)
ENDIF ELSE BEGIN
   vx = vpar
   vy = vperp
ENDELSE
;-----------------------------------------------------------------------------------------
; => Create a distribution
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(df) THEN BEGIN
  ;---------------------------------------------------------------------------------------
  ; => Get ONLY finite data
  ;---------------------------------------------------------------------------------------
  good = WHERE(FINITE(vx) AND FINITE(vy) AND FINITE(df))
  IF (good[0] NE -1) THEN BEGIN   
    vx0 = DOUBLE(vx[good])
    vy0 = DOUBLE(vy[good])
    df0 = DOUBLE(df[good])
  ENDIF ELSE BEGIN
    MESSAGE,"No FINITE Data!",/INFORMATIONAL,/CONTINUE
    RETURN,dftemp
  ENDELSE
  ;---------------------------------------------------------------------------------------
  ; => Get ONLY positive real data
  ;---------------------------------------------------------------------------------------
  good = WHERE(df0 GT 0.)        ; -Non zero only
  IF (good[0] NE -1) THEN BEGIN   
    vx0 = vx0[good]
    vy0 = vy0[good]
    df0 = df0[good]
  ENDIF ELSE BEGIN
    MESSAGE,"No POSITIVE REAL Data!",/INFORMATIONAL,/CONTINUE
    RETURN,dftemp
  ENDELSE

  n = N_ELEMENTS(df0)
  m = n + 2             ; -# of Eqns to solve
  a = DBLARR(m, m)      ; -LHS
  ;---------------------------------------------------------------------------------------
  ; => Calc. velocity distribution function (forced isotropy in last 2 lines)
  ;---------------------------------------------------------------------------------------
  FOR i=0, n-1 DO BEGIN 
    FOR j=i,n-1 DO BEGIN
      d1 = ((vx0[i] - vx0[j])^2 + (vy0[i] - vy0[j])^2) > 1d-100  ; => [(km/s)^2]
      d2 = ((vx0[i] - vx0[j])^2 + (vy0[i] + vy0[j])^2) > 1d-100  ; => [(km/s)^2]
      d = (d1*ALOG(d1)+d2*ALOG(d2))/2.                           ; => [(km/s)^2]
      a[i,j] = d
      a[j,i] = d
    ENDFOR
  ENDFOR
  ;---------------------------------------------------------------------------------------
  ; =>Fill rest of array
  ;---------------------------------------------------------------------------------------
  a[n,0:(n-1L)]      = 1.
  a[(n+1L),0:(n-1L)] = vx0
  a[0:(n-1L),n]      = 1.
  a[0:(n-1L),(n+1L)] = vx0

  b        = DBLARR(m)                        ; => Unitless
  b[0:n-1] = REFORM(ALOG(df0),n)
  c        = REFORM(b # INVERT(a))            ; => [(km/s)^2]

  IF KEYWORD_SET(debug) THEN STOP
  ;---------------------------------------------------------------------------------------
  ; => Force all arrays to be of the same size to prevent "Conflicting Data Structures"
  ;     errors when concatinating arrays of structures
  ;---------------------------------------------------------------------------------------
  vx01 = REPLICATE(-0.0145,500)
  vy01 = REPLICATE(-0.0145,500)
  dfc1 = REPLICATE(-0.0145,500)
  nvx  = N_ELEMENTS(vx0) - 1L
  nvy  = N_ELEMENTS(vy0) - 1L
  ndf  = N_ELEMENTS(c) - 1L

  vx01[0:nvx] = vx0
  vy01[0:nvy] = vy0
  dfc1[0:ndf] = c   
    
  mystr = CREATE_STRUCT('vx0',vx01,'vy0',vy01,'dfc',dfc1)
  RETURN, mystr
ENDIF
;-----------------------------------------------------------------------------------------
; => Create a distribution from given data
;-----------------------------------------------------------------------------------------
vx0 = dfpar.VX0
vy0 = dfpar.VY0
c   = dfpar.DFC
;*****************************************************************************************
; => prior use of distfunc.pro may have produced extra array elements with
;      values of -0.0145 which was a unique value chosen to mark "empty" 
;      data elements for later removal to avoid "Conflicting Data Structures"
;      errors
; => It is also important to remove non-finite quantities to avoid 
;      "Infinite Plot Range" errors in the calculation of a new distribution
;      function
;*****************************************************************************************
gdvx = WHERE(vx0 NE -0.0145 AND FINITE(vx0),gvx)
gdvy = WHERE(vy0 NE -0.0145 AND FINITE(vy0),gvy)
gdfc = WHERE(c   NE -0.0145 AND FINITE(c),gdf)

IF (gvx GT 0 AND gvy GT 0 AND gdf GT 0) THEN BEGIN
  IF (gvx EQ gvy AND gdf EQ gvx+2L) THEN BEGIN
    vx1  = vx0[gdvx]
    vy1  = vy0[gdvy]
    c1   = c[gdfc]
  ENDIF ELSE BEGIN
    vx2  = vx0[gdvx]
    vy2  = vy0[gdvy]
    c2   = c[gdfc]
    mynn = MIN([gvx,gvy,gdf],/NAN)           ; -# of data points to interpolate
    vx1  = CONGRID(vx0,mynn,0,0,CUBIC=-0.5)  ; -Resample using a cubic interpolation
    vy1  = CONGRID(vy0,mynn,0,0,CUBIC=-0.5)
    c1   = CONGRID(c,mynn+2L,0,0,CUBIC=-0.5)
  ENDELSE
ENDIF ELSE BEGIN
  MESSAGE,"No data available to interpret!",/INFORMATIONAL,/CONTINUE
  RETURN,dftemp
ENDELSE
;-----------------------------------------------------------------------------------------
; => Calculate a new distribution function from input data
;-----------------------------------------------------------------------------------------
n   = N_ELEMENTS(vx1)
nc  = N_ELEMENTS(c1)
IF (n + 2L EQ nc) THEN BEGIN
  s = c1[n] + c1[n+1L] * vx      ; => Last terms
ENDIF ELSE BEGIN
  MESSAGE,"Incorrect array sizes...",/INFORMATIONAL,/CONTINUE
  RETURN,dftemp
ENDELSE

FOR i=0L, n - 1L DO BEGIN
  d1 = ((vx1[i] - vx)^2 + (vy1[i] - vy)^2)
  wz = WHERE(d1 EQ 0.,count)
  IF (count NE 0L) THEN BEGIN
    winz   = ARRAY_INDICES(d1,wz)
    d1[winz[0,*],winz[1,*]] = 1d-100
  ENDIF 
  d2 = ((vx1[i] - vx)^2 + (vy1[i] + vy)^2)
  wz = WHERE(d2 EQ 0.,count)
  IF (count NE 0L) THEN BEGIN 
    winz   = ARRAY_INDICES(d2,wz)
    d2[winz[0,*],winz[1,*]] = 1d-100
  ENDIF
  d = (d1*ALOG(d1) + d2*ALOG(d2))/2.
  s = s + d * c1[i]
ENDFOR

IF KEYWORD_SET(debug) THEN STOP
RETURN,EXP(s)
END
