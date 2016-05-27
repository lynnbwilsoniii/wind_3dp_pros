;+
;*****************************************************************************************
;
;  FUNCTION :   my_lorentzian_dist.pro
;  PURPOSE  :   Creates a Lorentzian Distribution Function (LDF) from an user defined
;                 amplitude, thermal speed, and array of velocities to define the LDF
;                 at.  The only note to be careful of is to make sure the thermal
;                 speed and array of velocities are in the same units.
;                 [See Thomsen et. al. (1983), JGR Vol. 88, pg. 3035-3045]
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
;               ldist = my_lorentzian_dist(am,vv,vt,MPOW=2)
;               IDL> help, ldist
;               LDIST            DOUBLE    = Array[49]
;
;  KEYWORDS:  
;               MPOW   :  Power of Lorentzian (Default = 2 for solar wind)
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   CREATED:  02/17/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/17/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  my_lorentzian_dist,amp,vels,vther,MPOW=mpow

IF NOT KEYWORD_SET(mpow) THEN mm = 2d0 ELSE mm = DOUBLE(mpow)

l_dist = amp*(1 + (vels/vther)^(2d0*mm))^(-1d0*(mm + 1d0)/mm)

RETURN,l_dist
END