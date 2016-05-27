;+
;*****************************************************************************************
;
;  FUNCTION :   rate_max_o.pro
;  PURPOSE  :   Calculates the peak count rate of an ideal analyzer in response to a
;                 drifting Maxwellian.
;
;  CALLED BY:   
;               calc_pl_mcp_eff_dt.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               PL_DENS  :  [N]-Element array of densities [cm^(-3)] from 
;                             PESA Low 8x8 array on-board moments
;               VSW_MAG  :  [N]-Element array of Vsw magnitudes [km/s]
;               VTI_O    :  [N]-Element array of ion thermal speeds [km/s]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Cleaned up and added a note about the 10^6 factor [07/20/2011   v1.0.1]
;             2)  Fixed typo in man page                            [07/25/2011   v1.0.2]
;
;   NOTES:      
;               1)  See get_pmom2.pro usage of NOFIXMCP keyword
;
;  REFERENCES:  
;               1)  Wuest, M., D.S. Evans, and R. von Steiger (2007), "Calibration of
;                      Particle Instruments in Space Physics," ISSI/ESA Publications
;                      Division, Keplerlaan 1, 2200 AG Noordwijk, The Netherlands.
;                      [Chapter 4.4.5 primarily]
;
;   CREATED:  07/19/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/25/2011   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rate_max_o,pl_dens,vsw_mag,vti_o

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
nio        = REFORM(pl_dens)          ; => [N]-Element array
vti        = REFORM(vti_o)            ; => [N]-Element array
vswm       = REFORM(vsw_mag)          ; => [N]-Element array
;-----------------------------------------------------------------------------------------
; => Calculate the max rates
;-----------------------------------------------------------------------------------------
factor     = nio*(vswm^4/vti^3)       ; => [# cm^(-3) km/s]
rmax       = factor/1d6               ; => [# s^(-1)]
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Note:  I do NOT know where the 10^(6) factor comes from.  It appears to be a kludge
;          that makes the correction factor close to unity.  A conversation with
;          D. Larson did not reveal any more information either, as he said he did not
;          know where it came from.  I assume it is for a unit conversion.
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;-----------------------------------------------------------------------------------------
; => Return the max rates
;-----------------------------------------------------------------------------------------

RETURN,rmax
END