;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_mms_nbin_sum_fpi_vdf.pro
;  PURPOSE  :   This routine sums adjacent VDFs from the FPI instruments on MMS
;                 within a user-defined number of VDF time stamps (i.e., VDF bins)
;                 and computes the reduced mean of the conversion factors.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               lbw_mms_compute_counts_from_f_df.pro
;               is_a_number.pro
;               delete_variable.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries; and
;               2)  latest SPEDAS libraries
;
;  INPUT:
;               DAT_TPN      :  Scalar [string or integer] defining the TPLOT handle
;                                 associated with the particle data
;                                 [e.g., 'mms1_des_dist_brst']
;               ERR_TPN      :  Scalar [string or integer] defining the TPLOT handle
;                                 associated with the error in the particle data
;                                 [e.g., 'mms1_des_disterr_brst']
;               NVDF         :  Scalar [numeric] defining the # of adjacent VDFs to sum
;                                 in units of counts before converting back to phase
;                                 space density
;                                 [Default = 2]
;
;  EXAMPLES:    
;               [calling sequence]
;               nsum_vdf = lbw_mms_nbin_sum_fpi_vdf(dat_tpn, err_tpn [,NEW_FAC=new_fac] $
;                                                   [,TRANGE=trange]                    )
;
;  KEYWORDS:    
;               NEW_FAC      :  Set to a named variable to return an [N,A,P,E]-element
;                                 array of conversion factors between counts and the
;                                 data in phase space density units [e.g., # s^(+3)
;                                 cm^(-6)] where N = # of time stamps, A = # of azimuthal
;                                 angle bins, P = # of poloidal/latitudinal angle bins,
;                                 and E = # of energy bins.
;                                 [output units = length^(+6) time^(-3)]
;               TRANGE       :  [2]-Element [double] array specifying the Unix time range
;                                 on which to limit the output analysis
;                                 [Default = [MIN(T_IN),MAX(T_IN)] ]
;
;   CHANGED:  1)  Finished writing routine (mostly just completed Man. page)
;                                                                   [07/12/2018   v1.0.0]
;
;   NOTES:      
;               1)  The data structures for the MMS FPI VDFs are originally loaded into
;                     TPLOT with the routine mms_load_fpi.pro and then this routine grabs
;                     them and performs calculations on them.
;               2)  The calculations to/from counts are as follows:
;                     f  =  A * C
;                     df =  A * C^(1/2)
;                   where f is the phase space density, df is the Poisson statistical
;                   error, A is the unit conversion factors, and C are counts.  We can
;                   then compute C and A as follows:
;                     C  =  (f/df)^2
;                     A  =  (f/C)  =  df^2/f
;                   We then sum the adjacent NVDF arrays of counts and compute the new
;                   conversion factors in the following way:
;                     A_n  =  1/(∑_i 1/A_i )
;                   i.e., similar to a reduced mean approach.
;               3)  The MMS FPI distributions stored in TPLOT have the following
;                     structure tag formats:
;                       X  :  [N]-Element array of Unix times
;                       Y  :  [N,Z,L,E]-Element array of data values [s^(+3) cm^(-6)]
;                       V1 :  [N,Z]-Element array of azimuthal angle bin values [deg]
;                       V2 :  [L]-Element array of poloidal angle bin values [deg]
;                       V3 :  [N,E]-Element array of energy bin values [eV]
;
;  REFERENCES:  
;               0)  Pollock, C., et al., "Fast Plasma Investigation for Magnetospheric
;                      Multiscale," Space Sci. Rev. 199, pp. 331--406,
;                      doi:10.1007/s11214-016-0245-4, (2016).
;               1)  Gershman, D.J., J.C. Dorelli, A.F.- Vinas, and C.J. Pollock "The
;                      calculation of moment uncertainties from velocity distribution
;                      functions with random errors," J. Geophys. Res. 120,
;                      pp. 6633--6645, doi:10.1002/2014JA020775, 2015.
;               2)  Gershman, D.J., U. Gliese, J.C. Dorelli, L.A. Avanov, A.C. Barrie,
;                      D.J. Chornay, E.A. MacDonald, M.P. Holland, B.L. Giles, and
;                      C.J. Pollock "The parameterization of microchannel-plate-based
;                      detection systems," J. Geophys. Res. 121, pp. 10,005--10,018,
;                      doi:10.1002/2016JA022563, 2016.
;               3)  Gershman, D.J., L.A. Avanov, S.A. Boardsen, J.C. Dorelli, U. Gliese,
;                      A.C. Barrie, C. Schiff, W.R. Paterson, R.B. Torbert, B.L. Giles,
;                      and C.J. Pollock "Spacecraft and Instrument Photoelectrons
;                      Measured by the Dual Electron Spectrometers on MMS," J. Geophys.
;                      Res. 122, pp. 11,548--11,558, doi:10.1002/2017JA024518, 2017.
;
;   CREATED:  07/06/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/12/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_mms_nbin_sum_fpi_vdf,dat_tpn,err_tpn,nvdf,NEW_FAC=new_fac,TRANGE=trange

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN RETURN,0b
;;  Get data in units of counts and the associated conversion factors
cnt_str        = lbw_mms_compute_counts_from_f_df(dat_tpn,err_tpn,FACTORS=factors,TRANGE=trange)
IF (SIZE(cnt_str,/TYPE) NE 8) THEN RETURN,0b
;;  Check NVDF
IF (is_a_number(nvdf[0],/NOMSSG)) THEN nsum = LONG(ABS(nvdf[0])) > 2L ELSE nsum = 2L
;;  cnt_str.Y  :  [N,A,P,E]-element array of data in counts
;;  factors    :  " " of conversion factors from counts to phase space density
;;
;;          N  :  # of time stamps
;;          A  :  # of azimuthal angle bins
;;          P  :  # of poloidal/latitudinal angle bins
;;          E  :  # of energy bins
nn             = N_ELEMENTS(cnt_str.X)                 ;;  N
aa             = N_ELEMENTS(factors[0,*,0,0])          ;;  A
pp             = N_ELEMENTS(factors[0,0,*,0])          ;;  P
ee             = N_ELEMENTS(factors[0,0,0,*])          ;;  E
;;  Make sure NVDF is not too large
IF (1d0*nsum[0] GT 5d-1*nn[0]) THEN nsum = LONG(nsum[0]/2d0) > 2L
;;----------------------------------------------------------------------------------------
;;  Define indices to idenfity start/stop of each summing interval
;;----------------------------------------------------------------------------------------
nn_even        = ((nn[0] MOD 2) EQ 0)
ns_even        = ((nsum[0] MOD 2) EQ 0)
ns_remd        = (nn[0] MOD nsum[0])                   ;;  Remainder
ni             = (nn[0]/nsum[0]) + (nsum[0] - 1L)
nmax           = (nn[0] - 1L)
ind            = LINDGEN(ni[0])*nsum[0]
IF (ns_remd[0] NE 0) THEN BEGIN
  ;;  Some remainder --> cutoff index array
  bad            = WHERE(ind GT nmax[0],bd,COMPLEMENT=good,NCOMPLEMENT=gd)
  IF (gd[0] EQ 0) THEN STOP    ;;  Should not happen --> debug
  gind           = [ind[good],nmax[0]]
ENDIF ELSE BEGIN
  ;;  No remainder --> good
  gind           = ind
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Sum counts and average conversion factors
;;----------------------------------------------------------------------------------------
ni2            = N_ELEMENTS(gind) - 1L
new_unx        = REPLICATE(0d0,ni2[0])                    ;;  New Unix time stamps
new_cnt        = REPLICATE(0d0,ni2[0],aa[0],pp[0],ee[0])  ;;  New array of counts
new_fac        = REPLICATE(0d0,ni2[0],aa[0],pp[0],ee[0])  ;;  New array of conversion factors

FOR jst=0L, ni2[0] - 1L DO BEGIN
  jen          = jst[0] + 1L                              ;;  end index of index array
  ist          = gind[jst[0]]                             ;;  start index of input array
  ien          = gind[jen[0]]                             ;;  end index of input array
  IF ((ist[0] EQ ien[0]) OR (jen[0] GT (ni[0] - 1L))) THEN CONTINUE
  tt0          = cnt_str.X[ist[0]:ien[0]]                 ;;  array of unix times to average
  cc0          = cnt_str.Y[ist[0]:ien[0],*,*,*]           ;;  array of counts to sum
  fc0          = factors[ist[0]:ien[0],*,*,*]             ;;  array of conversion factors to average
  ;;  Prevent NaNs when summing
  bad          = WHERE(FINITE(cc0) EQ 0 OR cc0 LT 0,bd)
  IF (bd[0] GT 0) THEN cc0[bad] = 0d0
  tavg         = MEAN(tt0,/NAN,/DOUBLE)                   ;;  Avg of Unix times
  csum         = TOTAL(cc0,1,/NAN,/DOUBLE)                ;;  Sum of counts over time steps, [A,P,E]-element array
  favg         = 1d0/TOTAL(1d0/fc0,1,/NAN,/DOUBLE)        ;;  Reduced average of conversion factors, [A,P,E]-element array
  ;;  Define outputs
  new_unx[jst]       = tavg[0]
  new_cnt[jst,*,*,*] = csum
  new_fac[jst,*,*,*] = favg
ENDFOR
;;  Clean up to save space
delete_variable,cnt_str,factors
;;----------------------------------------------------------------------------------------
;;  Convert back to phase space density and define output
;;----------------------------------------------------------------------------------------
output         = {X:new_unx,Y:new_fac*new_cnt}
;;  Clean up to save space
delete_variable,new_unx,new_cnt
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END


























