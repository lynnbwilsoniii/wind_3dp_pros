;+
;*****************************************************************************************
;
;  FUNCTION :   calc_pl_mcp_eff_dt.pro
;  PURPOSE  :   This is the main level routine which calculates the dead time and
;                 efficiency corrections for the PESA Low detector onboard
;                 the Wind spacecraft.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               check_input_cor_pl.pro
;               rate_max_o.pro
;               remove_noise.pro
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
;               ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               ; => The following values are for 2000-05-15 from 12:00 to 23:59 UT
;               ;      using:  (1)  the wi_k0_swe_20000515_v01.cdf file from CDAWeb for
;               ;      the SWE proton densities and (2)  level zero onboard ion moments
;               ;      produced by the following command:
;               ;          get_pmom2,/PROTONS,PREFIX='p_',MAGNAME='wi_B3(GSE)',/NOFIXMCP
;               ;      after running:
;               ;          load_3dp_data,'00-05-15/00:00:00',150,qu=2,memsize=200.
;               ;
;               ;      Then, one interpolates (linearly) to the SWE ion density times
;               ;      to an array of 3DP values for density, velocity, and thermal
;               ;      speed [np_3dp, vp_3dp, vt_3dp, respectively].
;               ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               
;               IDL> np_3dp = [10.87,9.26,10.31,9.17,6.98,5.40,5.22]
;               IDL> vp_3dp = [457.43,425.29,416.45,418.42,414.81,398.80,414.72]
;               IDL> vt_3dp = [42.04,44.25,43.52,41.86,40.30,38.54,26.30]
;               IDL> np_swe = [11.77,10.34,11.94,10.60,6.37,5.11,5.33]
;               IDL> nmax   = 400L
;               IDL> calc_pl_mcp_eff_dt,np_3dp,vp_3dp,vt_3dp,np_swe,EFFICIENCY=eff,$
;                                       DEADTIME=deadt,NMAX=nmax
;               IDL> PRINT,';', eff[0], deadt[0]
;               ;       1.0375940    0.0039490372
;
;  KEYWORDS:    
;               EFFICIENCY  :  Set to a named variable to return the scalar estimate
;                                of the absolute counting efficiency of the
;                                PESA Low MCP
;               DEADTIME    :  Set to a named variable to return the scalar estimate
;                                of the detector dead time [seconds]
;               NMAX        :  Scalar number of numerical estimates of the
;                                unknown parameters to use when estimating the
;                                chi-squared distribution
;                                [Default = 300]
;               CHI_SQ      :  Set to a named variable to return the chi^2 array
;                                produced by this routine, the dummy efficiencies,
;                                and the dummy dead times
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  MCP = multi-channel plate
;               2)  The dead time for PESA Low is not a fixed preamp electronic
;                     dead time, so it is not one microsecond as one might guess
;                     since the instrument paper says the Wind/3DP detector uses
;                     a 2 MHz counter.
;               3)  This routine assumes the "true" and "measured" densities are linearly
;                     related with the slope between the two being a function of both
;                     efficiency and dead time.
;
;  REFERENCES:  
;               1)  Wuest, M., D.S. Evans, and R. von Steiger (2007), "Calibration of
;                      Particle Instruments in Space Physics," ISSI/ESA Publications
;                      Division, Keplerlaan 1, 2200 AG Noordwijk, The Netherlands.
;                      [Chapter 4.4.5 primarily]
;               2)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               3)  See get_pmom2.pro which uses a similar approach (though different)
;
;   CREATED:  07/22/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/22/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO calc_pl_mcp_eff_dt,pl_dens,vsw_mag,vti_o,dens_true,EFFICIENCY=efficiency, $
                       DEADTIME=deadtime,NMAX=nmax,CHI_SQ=chi_sq

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
; => define initial guesses for 2 unknowns
eff0       = 0.10                     ; => theory of ion MCPs suggest this as upper limit
tau0       = 1d-6                     ; => deadtime of a 2 MHz clock
imat       = IDENTITY(2,/DOUBLE)      ; => 2x2 Identity Matrix
lambda0    = 1d-3                     ; => Initial start lambda
no         = 100L
IF ~KEYWORD_SET(nmax) THEN nn = no ELSE nn = LONG(nmax[0])
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
nio        = REFORM(pl_dens)          ; => PESA Low ion Densities [cm^(-3)]
vswm       = REFORM(vsw_mag)          ; => PESA Low Vsw [km/s]
vti        = REFORM(vti_o)            ; => PESA Low ion thermal speed [km/s]
nit        = REFORM(dens_true)        ; => Wind/SWE ion Densities [cm^(-3)]
check      = check_input_cor_pl(nio,vswm,nit,vti)
IF (check[0] EQ 0) THEN BEGIN
  errmsg = 'Incorrect input format...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Remove NaNs
;-----------------------------------------------------------------------------------------
r_max   = rate_max_o(nio,vswm,vti)
good    = WHERE(FINITE(nio) AND FINITE(nit),gd)
IF (gd EQ 0) THEN BEGIN
  errmsg = 'No finite data...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF

nio        = nio[good]
nit        = nit[good]
r_max      = r_max[good]
;-----------------------------------------------------------------------------------------
; => Find slope(s)
;-----------------------------------------------------------------------------------------
slope      = nit/nio
; => Smooth Slope
width      = CEIL(1d-2*gd)
so         = remove_noise(slope,NBINS=width)
; => Calculate the Std. Dev. of the Slopes
sig_s      = STDDEV(so,/NAN)*gd
;-----------------------------------------------------------------------------------------
; => Create chi-squared distribution
;-----------------------------------------------------------------------------------------
effmn    = 3d-1         ; => Min. effective efficiency
taumn    = 1d-6         ; => Min. dead time (s) corresponding to 2 MHz clock
; => Create dummy arrays of possible efficiencies and dead times
eff      = DINDGEN(nn)*( 1.2d0 - effmn[0])/(nn - 1L) + effmn[0]
tau      = DINDGEN(nn)*( 1d0 - ALOG10(taumn[0]))/(nn - 1L) + ALOG10(taumn[0])
tau      = 1d1^tau

chisq    = DBLARR(nn,nn)  ; => chi^2
FOR j=0L, nn - 1L DO BEGIN
  FOR k=0L, nn - 1L DO BEGIN
    t_y        = eff[j]/(1d0 - tau[k]*r_max)
    num        = (so - t_y)/sig_s[0]
    temp       = TOTAL(num^2,/NAN,/DOUBLE)
    chisq[j,k] = temp[0]
  ENDFOR
ENDFOR
; => define return structure for user
chi_sq     = {CHISQ:chisq,EFF:eff,DEADT:tau}
;-----------------------------------------------------------------------------------------
; => Find minimum
;-----------------------------------------------------------------------------------------
minchisq   = MIN(chisq,/NAN,ln)
; => Find corresponding element
gmin       = ARRAY_INDICES(chisq,ln)
;-----------------------------------------------------------------------------------------
; => Return values to user
;-----------------------------------------------------------------------------------------
efficiency = eff[gmin[0]]
deadtime   = tau[gmin[1]]

RETURN
END