;+
;*****************************************************************************************
;
;  FUNCTION :   corr_dens_pl.pro
;  PURPOSE  :   Calculates a corrected ion density given the original raw density,
;                 solar wind magnitude, ion thermal speed, and guesses at the
;                 detector efficiency and dead time.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               rate_max_o.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               PL_DENS     :  [N]-Element array of densities [cm^(-3)] from
;                                PESA Low 8x8 array on-board moments
;               VSW_MAG     :  [N]-Element array of Vsw magnitudes [km/s]
;               VTI_O       :  [N]-Element array of ion thermal speeds [km/s]
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
;   CHANGED:  1)  Added error handling to account for possibility of dead time
;                   corrections causing corrected estimate < 0  [07/20/2011   v1.0.1]
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
;
;   CREATED:  07/19/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/20/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION corr_dens_pl,pl_dens,vsw_mag,vti_o,efficiency,deadtime

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
nio        = REFORM(pl_dens)          ; => [N]-Element array
vswm       = REFORM(vsw_mag)          ; => [N]-Element array
vti        = REFORM(vti_o)            ; => [N]-Element array
eff        = efficiency[0]
deadt      = deadtime[0]
;-----------------------------------------------------------------------------------------
; => Determine max rate
;-----------------------------------------------------------------------------------------
rmax       = rate_max_o(nio,vswm,vti)  ; => [# s^(-1)]
;-----------------------------------------------------------------------------------------
; => Calculate the guess at the corrected density
;-----------------------------------------------------------------------------------------
ni_cor     = eff[0]*nio/(1d0 - deadt[0]*rmax)
;-----------------------------------------------------------------------------------------
; => Check for negative values [i.e. deadtime correction > 1.0 = BAD]
;-----------------------------------------------------------------------------------------
bad        = WHERE(ni_cor LT 0,bd)
IF (bd GT 0) THEN ni_cor[bad] = d
;-----------------------------------------------------------------------------------------
; => Return the corrected density
;-----------------------------------------------------------------------------------------

RETURN,ni_cor
END