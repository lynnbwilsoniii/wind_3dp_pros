;+
;*****************************************************************************************
;
;  FUNCTION :   check_input_cor_pl.pro
;  PURPOSE  :   This is an error handling routine that makes sure the input values from
;                 the wrapping routine have the correct format.
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
;               PL_DENS     :  [N]-Element array of densities [cm^(-3)] from
;                                PESA Low 8x8 array on-board moments that have
;                                not been corrected
;               VSW_MAG     :  [N]-Element array of Vsw magnitudes [km/s]
;               VTI_O       :  [N]-Element array of ion thermal speeds [km/s]
;               DENS_TRUE   :  [N]-Element array of densities [cm^(-3)] from
;                                Wind/SWE which represent the "true" ion density
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed typo in man page                            [07/25/2011   v1.0.1]
;
;   NOTES:      
;               1)  This routine redefines the input values, so be careful!
;
;   CREATED:  07/20/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/25/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION check_input_cor_pl,pl_dens,vsw_mag,dens_true,vti_o

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

szno       = SIZE(nio,/DIMENSIONS)
szvo       = SIZE(vswm,/DIMENSIONS)
szto       = SIZE(vti,/DIMENSIONS)
sznt       = SIZE(nit,/DIMENSIONS)
bad        = (N_ELEMENTS(szno) GT 1) OR (N_ELEMENTS(szvo) GT 1) OR $
             (N_ELEMENTS(szto) GT 1) OR (N_ELEMENTS(sznt) GT 1)
IF (bad) THEN RETURN,0
; => now we know they are one-dimensional

bad        = (szno[0] NE szvo[0]) OR (szno[0] NE szto[0]) OR (szno[0] NE sznt[0]) $
             (szvo[0] NE szto[0]) OR (szvo[0] NE sznt[0]) OR (szto[0] NE sznt[0])
IF (bad) THEN RETURN,0
;-----------------------------------------------------------------------------------------
; => now we know they have the correct format
;      => redefine input
;-----------------------------------------------------------------------------------------
pl_dens    = nio
vsw_mag    = vswm
vti_o      = vti
dens_true  = nit

RETURN,1
END






