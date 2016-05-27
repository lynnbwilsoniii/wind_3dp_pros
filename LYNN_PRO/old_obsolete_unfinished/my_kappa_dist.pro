;+
;*****************************************************************************************
;
;  FUNCTION :   my_kappa_dist.pro
;  PURPOSE  :   Creates a kappa Distribution Function (KDF) from an user defined
;                 amplitude, thermal speed, and array of velocities to define the KDF
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
;               VTH    :  Scalar defining the thermal speed
;
;  EXAMPLES:
;               n  = 24L
;               vv = (DINDGEN(2*n+1)/n-1) * 2d4
;               vt = 3d3
;               am = 1d-14
;               kdist = my_kappa_dist(am,vv,vt,KAPPA=2)
;               IDL> help, kdist
;               KDIST            DOUBLE    = Array[49]
;
;  KEYWORDS:  
;               MPOW   :  Power of Kappa Distribution (Default = 3 for solar wind)
;                           **[Note:  kappa > 3/2 ALWAYS!]**
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

FUNCTION  my_kappa_dist,amp,vels,vth,MPOW=mpow

IF NOT KEYWORD_SET(mpow) THEN kk = 3d0 ELSE kk = DOUBLE(mpow)
IF (kk LT 3d0/2d0) THEN BEGIN
  PRINT,'kappa must be > 3/2 !! => using default = 3'
  kk = 3d0
ENDIF
vther  = vth*SQRT((kk - 3d0/2d0)/kk)
gammf  = GAMMA(kk + 1d0)/ GAMMA(kk - 5d-1)
k_dist = amp*gammf*(1 + (vels/(vther*SQRT(kk)))^2d0)^(-1d0*(kk + 1d0))

RETURN,k_dist
END