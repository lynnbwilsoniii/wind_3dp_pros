;+
;*****************************************************************************************
;
;  FUNCTION :   my_bimaxwellian_dist.pro
;  PURPOSE  :   Creates a Bi-Maxwellian Distribution Function (MDF) from an user 
;                 defined amplitude, thermal speed, and array of velocities to define 
;                 the MDF at.  The only note to be careful of is to make sure the
;                 thermal speed and array of velocities are in the same units.
;
;  CALLED BY: 
;               my_eesa_df_flattop.pro
;               my_eesa_df_adjust.pro
;               my_eesa_dist_fit.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               AMP    :  Maximum amplitude of distribution function desired (units)
;               VELPA  :  N-Element array of parallel velocities (units) 
;               VELPE  :  N-Element array of perpendicular velocities (units) 
;               VTHER  :  2-Element defining the thermal speed [para,perp]
;
;  EXAMPLES:
;               n  = 24L
;               vv = (DINDGEN(2*n+1)/n-1) * 2d4
;               vv = REPLICATE(1.,2*n+1) # vv
;               vt = [3d3,3.5d3]
;               am = 1d-14
;               ldist = my_gaussian_dist(am,vv,vt,MPOW=2)
;               IDL> help, ldist
;               LDIST            DOUBLE    = Array[49]
;
;  KEYWORDS:  
;               MPOW   :  Power of Gaussian (Default = 2 for normal Maxwellian)
;                          **[must be an even number > or = 2]**
;               DRIFT  :  Set to a scaler defining the drift speed of the Maxwellian
;
;   CHANGED:  1)  NA                                          [04/15/2009   v1.0.0]
;             2)  Changed how program deals with odd powers   [06/04/2009   v1.0.1]
;
;   CREATED:  04/15/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/04/2009   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  my_bimaxwellian_dist,amp,velpa,velpe,vther,MPOW=mpow,DRIFT=drift

IF NOT KEYWORD_SET(mpow) THEN mm = 2d0 ELSE mm = DOUBLE(mpow)
IF NOT KEYWORD_SET(drift) THEN vd = 0d0 ELSE vd = DOUBLE(drift)
mtest  = mm MOD 2d0 NE 0
nva    = N_ELEMENTS(velpa)
nve    = N_ELEMENTS(velpe)
g_dist = DBLARR(nva,nve)

FOR j = 0L, nve - 1L DO BEGIN
  FOR k = 0L, nva - 1L DO BEGIN
    vpara       = (velpa[j] - vd[0])/vther[0]
    vperp       = velpe[k]/vther[1]
    IF mtest THEN BEGIN  ; => power was an odd number
      temp_v      = -1d0*( ABS(vpara)^mm + ABS(vperp)^mm)
    ENDIF ELSE BEGIN
      temp_v      = -1d0*( (vpara)^mm + (vperp)^mm)
    ENDELSE
    g_dist[k,j] = amp[0]*EXP(temp_v)
  ENDFOR
ENDFOR

RETURN,g_dist
END