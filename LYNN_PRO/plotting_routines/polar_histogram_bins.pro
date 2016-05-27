;+
;*****************************************************************************************
;
;  FUNCTION :   polar_histogram_bins.pro
;  PURPOSE  :   Creates and returns a structure which defines the XY-Coordinates of
;                 a wedge in polar space (see example below) for points A through D.
;                 The structure also contains the counts in each bin defined by the 
;                 number of radii and angles that fall in that area.
;
;
;            C
;           /          D
;          /        .
;         B       .
;        /      A
;       /    .
;      /  .
;
;  CALLED BY:   
;               
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               RAD     :  An N-Element array of radii to be used for the histogram
;               THETA   :  " " of angles (deg)
;
;  EXAMPLES:    
;               bin_vals = polar_histogram_bins(rad,theta,NBIN_R=20,NBIN_T=20)
;
;  KEYWORDS:    
;               XRANGE   :  A scalar used to define the max x-range value for X-Axis
;               YRANGE   :  A scalar used to define the max y-range value for Y-Axis
;               NBIN_R   :  A scalar used to define the number of bins in the radial
;                             direction [Default = 8]
;               NBIN_T   :  A scalar used to define the number of bins in the azimuthal
;                             direction [Default = 8]
;               DATA     :  N-Element array of data at the polar coordinates of
;                             RAD and THETA
;               THETA_R  :  If set, program uses input thetas to determine the range
;                             of angles to consider
;                             [Default = 0 to 360 degrees]
;               POLAR    :  If set, XRANGE is assumed to be the range for radial 
;                             distance and YRANGE is assumed to be the range for
;                             the polar angles
;
;   CHANGED:  1)  Added keywords:  DATA, THETA_R, and POLAR         [05/23/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  05/03/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/23/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION polar_histogram_bins,rad,theta,XRANGE=xra,YRANGE=yra,$
                              NBIN_R=nbin_r,NBIN_T=nbin_t,    $
                              DATA=data,THETA_R=theta_r,      $
                              POLAR=polar

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN

IF KEYWORD_SET(nbin_r) THEN nb_r = nbin_r ELSE nb_r = 8L
IF KEYWORD_SET(nbin_t) THEN nb_t = nbin_t ELSE nb_t = 8L

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
r1    = REFORM(rad)
t1    = REFORM(theta)

IF KEYWORD_SET(xra) OR KEYWORD_SET(yra) THEN BEGIN
  IF KEYWORD_SET(xra) THEN xran = xra ELSE xran = yra
  IF KEYWORD_SET(yra) THEN yran = yra ELSE yran = xra
ENDIF ELSE BEGIN
  xran  = [MIN(r1,/NAN),MAX(r1,/NAN)]
  yran  = [MIN(t1,/NAN),MAX(t1,/NAN)]
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define bin boundaries (Polar Coordinates)
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(polar) THEN BEGIN
  mnra  = MIN(xran,/NAN)
  mxra  = MAX(xran,/NAN)
  r_lft = DINDGEN(nb_r+1L)*(mxra[0] - mnra[0])/(nb_r) + mnra[0]
ENDIF ELSE BEGIN
  mxra  = MAX([xran,yran],/NAN)
  mnra  = MIN(r1,/NAN)
  r_lft = DINDGEN(nb_r+1L)*(mxra[0] - mnra[0])/(nb_r) + mnra[0]
ENDELSE

IF KEYWORD_SET(theta_r) THEN BEGIN
  IF KEYWORD_SET(polar) THEN BEGIN
    mnra  = MIN(yran,/NAN)
    mxra  = MAX(yran,/NAN)
    t_lft = DINDGEN(nb_t+1L)*(mxra[0] - mnra[0])/(nb_t) + mnra[0]
  ENDIF ELSE BEGIN
    t_lft = DINDGEN(nb_t+1L)*(MAX(t1,/NAN) - MIN(t1,/NAN))/(nb_t) + MIN(t1,/NAN)
  ENDELSE
ENDIF ELSE BEGIN
  t_lft = DINDGEN(nb_t+1L)*(36d1 - 0d0)/(nb_t) + 0d0
ENDELSE

IF KEYWORD_SET(polar) THEN BEGIN
  ; => X-Range is assumed to be the range for the radial distances
  xran  = [-1e0*MAX(xran,/NAN),MAX(xran,/NAN)]
  ; => Force Aspect ratio to 1.0
  yran  = xran
ENDIF
; => Define bin elements for upper and lower limits
;up_r    = LINDGEN(nb_r - 1L) + 1L
;dn_r    = LINDGEN(nb_r - 1L)
;up_t    = LINDGEN(nb_t - 1L) + 1L
;dn_t    = LINDGEN(nb_t - 1L)
up_r    = LINDGEN(nb_r) + 1L
dn_r    = LINDGEN(nb_r)
up_t    = LINDGEN(nb_t) + 1L
dn_t    = LINDGEN(nb_t)
num_bin = REPLICATE(0d0,nb_r,nb_t)       ; => # of data points that fall within each bin
FOR i=0L, nb_r - 1L DO BEGIN
  upr = r_lft[up_r[i]] 
  dnr = r_lft[dn_r[i]] 
  FOR j=0L, nb_t - 1L DO BEGIN
    upt  = t_lft[up_t[j]]
    dnt  = t_lft[dn_t[j]]
    test = (r1 LT upr[0]) AND (r1 GE dnr[0]) AND     $
           (t1 LT upt[0]) AND (t1 GE dnt[0])
    good = WHERE(test,gd)
    IF KEYWORD_SET(data) THEN BEGIN
      IF (gd GT 0) THEN BEGIN
        tempd = MEAN(data[good],/NAN,/DOUBLE)
      ENDIF ELSE BEGIN
        tempd = DOUBLE(gd)
      ENDELSE
    ENDIF ELSE BEGIN
      tempd = DOUBLE(gd)
    ENDELSE
    num_bin[i,j] = tempd
  ENDFOR
ENDFOR
;-----------------------------------------------------------------------------------------
; => Define bin boundaries (Cartesian Coordinates)
;-----------------------------------------------------------------------------------------
;xpt_A = DBLARR(nb_r - 1L,nb_t - 1L)   ; => X-Coordinate of Point A (see man page for reference)
;xpt_B = DBLARR(nb_r - 1L,nb_t - 1L)   ; => " " Point B
;xpt_C = DBLARR(nb_r - 1L,nb_t - 1L)   ; => " " Point C
;xpt_D = DBLARR(nb_r - 1L,nb_t - 1L)   ; => " " Point D
;ypt_A = DBLARR(nb_r - 1L,nb_t - 1L)   ; => Y-Coordinate of Point A 
;ypt_B = DBLARR(nb_r - 1L,nb_t - 1L)   ; => " " Point B
;ypt_C = DBLARR(nb_r - 1L,nb_t - 1L)   ; => " " Point C
;ypt_D = DBLARR(nb_r - 1L,nb_t - 1L)   ; => " " Point D

xpt_A = DBLARR(nb_r,nb_t)   ; => X-Coordinate of Point A (see man page for reference)
xpt_B = DBLARR(nb_r,nb_t)   ; => " " Point B
xpt_C = DBLARR(nb_r,nb_t)   ; => " " Point C
xpt_D = DBLARR(nb_r,nb_t)   ; => " " Point D

ypt_A = DBLARR(nb_r,nb_t)   ; => Y-Coordinate of Point A 
ypt_B = DBLARR(nb_r,nb_t)   ; => " " Point B
ypt_C = DBLARR(nb_r,nb_t)   ; => " " Point C
ypt_D = DBLARR(nb_r,nb_t)   ; => " " Point D
FOR i=0L, nb_r - 1L DO BEGIN
  upr = r_lft[up_r[i]]
  dnr = r_lft[dn_r[i]]
  FOR j=0L, nb_t - 1L DO BEGIN
    upt  = t_lft[up_t[j]]
    dnt  = t_lft[dn_t[j]]
    xpt_A[i,j] = dnr[0]*COS(dnt[0]*!DPI/18d1)
    xpt_B[i,j] = dnr[0]*COS(upt[0]*!DPI/18d1)
    xpt_C[i,j] = upr[0]*COS(upt[0]*!DPI/18d1)
    xpt_D[i,j] = upr[0]*COS(dnt[0]*!DPI/18d1)
    ypt_A[i,j] = dnr[0]*SIN(dnt[0]*!DPI/18d1)
    ypt_B[i,j] = dnr[0]*SIN(upt[0]*!DPI/18d1)
    ypt_C[i,j] = upr[0]*SIN(upt[0]*!DPI/18d1)
    ypt_D[i,j] = upr[0]*SIN(dnt[0]*!DPI/18d1)
  ENDFOR
ENDFOR
;-----------------------------------------------------------------------------------------
; => Check data ranges
;-----------------------------------------------------------------------------------------
; => Check X-Ranges
bad = WHERE(xpt_A GT xran[1] OR xpt_A LT xran[0],bdA)
IF (bdA GT 0) THEN BEGIN
  bind = ARRAY_INDICES(xpt_A,bad)
  num_bin[bind[0,*],bind[1,*]] = d
ENDIF
bad = WHERE(xpt_B GT xran[1] OR xpt_B LT xran[0],bdB)
IF (bdB GT 0) THEN BEGIN
  bind = ARRAY_INDICES(xpt_B,bad)
  num_bin[bind[0,*],bind[1,*]] = d
ENDIF
bad = WHERE(xpt_C GT xran[1] OR xpt_C LT xran[0],bdC)
IF (bdC GT 0) THEN BEGIN
  bind = ARRAY_INDICES(xpt_C,bad)
  num_bin[bind[0,*],bind[1,*]] = d
ENDIF
bad = WHERE(xpt_D GT xran[1] OR xpt_D LT xran[0],bdD)
IF (bdD GT 0) THEN BEGIN
  bind = ARRAY_INDICES(xpt_D,bad)
  num_bin[bind[0,*],bind[1,*]] = d
ENDIF
; => Check Y-Ranges
bad = WHERE(ypt_A GT yran[1] OR ypt_A LT yran[0],bdA)
IF (bdA GT 0) THEN BEGIN
  bind = ARRAY_INDICES(ypt_A,bad)
  num_bin[bind[0,*],bind[1,*]] = d
ENDIF
bad = WHERE(ypt_B GT yran[1] OR ypt_B LT yran[0],bdB)
IF (bdB GT 0) THEN BEGIN
  bind = ARRAY_INDICES(ypt_B,bad)
  num_bin[bind[0,*],bind[1,*]] = d
ENDIF
bad = WHERE(ypt_C GT yran[1] OR ypt_C LT yran[0],bdC)
IF (bdC GT 0) THEN BEGIN
  bind = ARRAY_INDICES(ypt_C,bad)
  num_bin[bind[0,*],bind[1,*]] = d
ENDIF
bad = WHERE(ypt_D GT yran[1] OR ypt_D LT yran[0],bdD)
IF (bdD GT 0) THEN BEGIN
  bind = ARRAY_INDICES(ypt_D,bad)
  num_bin[bind[0,*],bind[1,*]] = d
ENDIF
;-----------------------------------------------------------------------------------------
; => Define Return Structure
;-----------------------------------------------------------------------------------------
tags  = ['XPT_A','XPT_B','XPT_C','XPT_D','YPT_A','YPT_B','YPT_C','YPT_D',$
         'COUNTS']
struc = CREATE_STRUCT(tags,xpt_A,xpt_B,xpt_C,xpt_D,ypt_A,ypt_B,ypt_C,ypt_D,num_bin)

RETURN,struc
END