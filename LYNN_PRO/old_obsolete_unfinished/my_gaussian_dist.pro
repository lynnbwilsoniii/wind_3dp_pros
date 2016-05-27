;+
;*****************************************************************************************
;
;  FUNCTION :   my_gaussian_dist.pro
;  PURPOSE  :   Creates a Gaussian Distribution Function (GDF) from an user defined
;                 amplitude, thermal speed, and array of velocities to define the GDF
;                 at.  The only note to be careful of is to make sure the thermal
;                 speed and array of velocities are in the same units.
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
;               VELS   :  N-element array of velocities (units) 
;               VTHER  :  Scalar defining the thermal speed
;
;  EXAMPLES:
;               n  = 24L
;               vv = (DINDGEN(2*n+1)/n-1) * 2d4
;               vt = 3d3
;               am = 1d-14
;               ldist = my_gaussian_dist(am,vv,vt,MPOW=2)
;               IDL> help, ldist
;               LDIST            DOUBLE    = Array[49]
;
;  KEYWORDS:  
;               MPOW   :  Power of Gaussian (Default = 2 for normal Gaussian)
;                          **[must be an even number > or = 2]**
;               DRIFT  :  Set to a scaler defining the drift speed of the Maxwellian
;
;   CHANGED:  1)  Added keyword:  DRIFT                       [04/15/2009   v1.1.0]
;             2)  Changed how program deals with odd powers   [06/04/2009   v1.1.1]
;
;   CREATED:  02/17/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/04/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  my_gaussian_dist,amp,vels,vther,MPOW=mpow,DRIFT=drift

IF NOT KEYWORD_SET(mpow) THEN mm = 2d0 ELSE mm = DOUBLE(mpow)
IF NOT KEYWORD_SET(drift) THEN vd = 0d0 ELSE vd = DOUBLE(drift)
mtest  = mm MOD 2d0 NE 0
IF mtest THEN BEGIN  ; => power is an odd number
  temp_v = -1d0*(ABS((vels - vd)/vther)^mm)
ENDIF ELSE BEGIN     ; => power is even
  temp_v = -1d0*((vels - vd)/vther)^mm
ENDELSE

g_dist = amp*EXP(temp_v)

RETURN,g_dist
END