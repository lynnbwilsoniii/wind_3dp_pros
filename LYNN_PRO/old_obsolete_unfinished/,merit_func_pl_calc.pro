;+
;*****************************************************************************************
;
;  FUNCTION :   merit_func_pl_calc.pro
;  PURPOSE  :   Calculates the merit function for the equation used to correct the
;                 PESA Low ion density described in Chapter 4.4.5 of
;                 Wuest et al., [2007] for the maximum response of an ideal detector
;                 to a drifting Maxwellian.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               corr_dens_pl.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               PL_DENS     :  [N]-Element array of densities [cm^(-3)] from
;                                PESA Low 8x8 array on-board moments that have
;                                not been corrected
;               VSW_MAG     :  [N]-Element array of Vsw magnitudes [km/s]
;               VTI_O       :  [N]-Element array of ion thermal speeds [km/s]
;               DENS_TRUE   :  [N]-Element array of densities [cm^(-3)] from
;                                Wind/SWE which represent the "true" ion density
;               EFFICIENCY  :  Scalar estimate of the absolute counting efficiency
;                                of the PESA Low MCP
;               DEADTIME    :  Scalar estimate of the detector dead time [seconds]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  MCP = multi-channel plate
;               2)  The dead time for PESA Low is not a fixed preamp electronic
;                     dead time, so it is not one microsecond as one might guess
;                     since the instrument paper says the Wind/3DP detector uses
;                     a 2 MHz counter.
;
;  REFERENCES:  
;               1)  Wuest, M., D.S. Evans, and R. von Steiger (2007), "Calibration of
;                      Particle Instruments in Space Physics," ISSI/ESA Publications
;                      Division, Keplerlaan 1, 2200 AG Noordwijk, The Netherlands.
;                      [Chapter 4.4.5 primarily]
;               2)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               3)  Levenberg-Marquardt Method in any Numerical Recipes book
;
;   CREATED:  07/20/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/20/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION merit_func_pl_calc,pl_dens,vsw_mag,dens_true,vti_o,efficiency,deadtime

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
nio        = REFORM(pl_dens)          ; => PESA Low ion Densities [cm^(-3)]
vswm       = REFORM(vsw_mag)          ; => PESA Low Vsw [km/s]
vti        = REFORM(vti_o)            ; => PESA Low ion thermal speed [km/s]
nit        = REFORM(dens_true)        ; => Wind/SWE ion Densities [cm^(-3)]
eff        = efficiency[0]
deadt      = deadtime[0]
;-----------------------------------------------------------------------------------------
; => Calculate the guess at the corrected density
;-----------------------------------------------------------------------------------------
ni_cor     = corr_dens_pl(nio,vswm,vti,eff,deadt)
; => Use the variance of the corrected estimate for sigma in merit function
sigma      = STDDEV(ni_cor,/NAN,/DOUBLE)*(1d0*N_ELEMENTS(ni_cor))
;-----------------------------------------------------------------------------------------
; => Calculate the difference between guess and true density
;-----------------------------------------------------------------------------------------
diff_dens  = nit - ni_cor
;-----------------------------------------------------------------------------------------
; => Calculate the merit function
;-----------------------------------------------------------------------------------------
temp       = (diff_dens/sigma[0])^2
merit_func = TOTAL(temp,/NAN,/DOUBLE)
;-----------------------------------------------------------------------------------------
; => Return the merit function result
;-----------------------------------------------------------------------------------------

RETURN,merit_func
END