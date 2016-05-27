;+
;*****************************************************************************************
;
;  FUNCTION :   ts_array_esa_angle_bins.pro
;  PURPOSE  :   This routine determines the Unix time stamps associated with each angle
;                 bin in an array of THEMIS ESA velocity distribution functions (VDFs)
;                 supplied as IDL data structures.  These time stamps provide the user
;                 with an effectively higher time resolution than the total duration
;                 of the distribution, which is typically the spin period or ~3 sec.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_wind_vs_themis_esa_struct.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar (or [N]-element array) [structure] associated with
;                               a() known THEMIS ESA IDL data structure(s)
;                               [e.g., see get_th?_p*@b.pro, ? = a-f, * = e @ = e,i]
;               SPPERI     :  Scalar (or [N]-element array) [numeric] of spacecraft body
;                               spin rate(s) [deg/s] at the time(s) of DAT
;
;  EXAMPLES:    
;               [calling sequence]
;               t_phi_esa = ts_array_esa_angle_bins(dat, spperi)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See also:  timestamp_esa_angle_bins.pro and ts_array_sst_angle_bins.pro
;               2)  Input structure(s) DAT should still have THETA/PHI defined in the
;                     DSL coordinate basis
;
;  REFERENCES:  
;               1)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               2)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               3)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               4)  Schwartz, S.J., E. Henley, J.J. Mitchell, and V. Krasnoselskikh
;                      "Electron temperature gradient scale at collisionless shocks,"
;                      Phys. Rev. Lett. 107, 215002, doi:10.1103/PhysRevLett.107.215002,
;                      (2011).
;               5)  Wilson III, L.B., A. Koval, A. Szabo, A.W. Breneman, C.A. Cattell,
;                      K. Goetz, P.J. Kellogg, K. Kersten, J.C. Kasper, B.A. Maruca, and
;                      M. Pulupa "Observations of electromagnetic whistler precursors at
;                      supercritical interplanetary shocks," Geophys. Res. Lett. 39,
;                      L08109, doi:10.1029/2012GL051581, (2012).
;
;   CREATED:  03/11/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/11/2016   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION ts_array_esa_angle_bins,dat,spperi

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, test_wind_vs_themis_esa_struct
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
bad_inp_msg    = 'Incorrect input:  DAT and SPPERI must both be supplied on input...'
notstr_msg     = 'DAT must be a scalar or array of IDL structures...'
badvfor_msg    = 'Incorrect input format:  SPPERI must be a scalar or [N]-element [numeric] array...'
baddfor_msg    = 'Incorrect input format:  DAT and SPPERI must have the same number of elements...'
badvdf_msg     = 'Input must be an IDL structure from one of the THEMIS ESA instruments...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for both inputs
test           = (N_PARAMS() LT 2)
IF (test[0]) THEN BEGIN
  MESSAGE,bad_inp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check DAT type
test           = (SIZE(dat,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check SPPERI type
test           = (is_a_number(spperi,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check size of DAT and SPPERI
szdd           = SIZE(dat,/DIMENSIONS)
szds           = SIZE(spperi,/DIMENSIONS)
test           = (szdd[0] NE szds[0]) OR ((N_ELEMENTS(szdd) NE 1) OR (N_ELEMENTS(szds) NE 1))
IF (test[0]) THEN BEGIN
  MESSAGE,baddfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check DAT format
dat0           = dat[0]
test0          = test_wind_vs_themis_esa_struct(dat0,/NOM)
test           = (test0.(1) NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,badvdf_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
dat0           = REFORM(dat)                        ;;  [N]-Element array of VDFs as IDL structures
sp_rate        = REFORM(spperi)                     ;;  [N]-Element array of spin rates [deg/s]
;;  Define ESA-dependent variables
n_esa          = N_ELEMENTS(dat0)                   ;;  Number of ESA data structures
n_e            = dat0[0].NENERGY                    ;;  # of energy bins
n_a            = dat0[0].NBINS                      ;;  # of angle bins
t_s            = dat0.TIME                          ;;  Unix time at start of each VDF ([N]-Element array)
t_e            = dat0.END_TIME                      ;;  Unix time at end of each VDF ([N]-Element array)
phi            = DOUBLE(dat0.PHI)                   ;;  [E,A,N]-Element array of azimuthal angles [deg]
int_t          = DOUBLE(dat0.INTEG_T[0])            ;;  [N]-Element array of integration times [s]
dt_arr         = DOUBLE(dat0.DT_ARR)                ;;  [E,A,N]-Element array of anode accumulation times per bin for rate and dead time corrections
;;  Assume zeroth bin corresponds to the zeroth time --> define time offsets relative to first bin
t_zero_esa     = REFORM(phi[0,0,*])/sp_rate         ;;  [N]-Element array of initial time offset [s] from start of VDF
;;  Define dummy arrays to fill later
dt_esa         = DBLARR(n_e[0],n_a[0],n_esa[0])     ;;  Total accumulation times [s] for each ESA bin
t_off_av_esa   = DBLARR(n_e[0],n_a[0],n_esa[0])     ;;  Time offsets [s] of each energy/angle bin
dt_off_st_esa  = DBLARR(n_e[0],n_a[0],n_esa[0])     ;;  Time offsets [s] adjusted by accumulation times
t_phi_esa      = DBLARR(n_e[0],n_a[0],n_esa[0])     ;;  Time stamps [Unix] of every energy/angle bin for each VDF
;;----------------------------------------------------------------------------------------
;;  Define offsets by azimuthal angles [deg, DSL]
;;----------------------------------------------------------------------------------------
FOR j=0L, n_esa[0] - 1L DO BEGIN
  ;;  Calculate accumulation times [s]
  tacc                 = int_t[j]*dt_arr[*,*,j]
  dt_esa[*,*,j]        = tacc
  ;;  Calculate time offsets
  t_phi                = phi[*,*,j]/sp_rate[j]             ;;  Azimuthal angle converted to time offset
  t_off                = t_phi - t_zero_esa[j]             ;;  Initial time offset [s] estimates
  ;;  Remove smallest offsets to force T_0 = 0.0 s
  t_off               -= MIN(t_off,/NAN)
  ;;  Define time offsets [s]
  t_off_av_esa[*,*,j]  = t_off
  ;;  Define time offsets [s] adjusted by 1/2 total accumulation times
  dt_off               = t_off + tacc/2d0
  dt_off_st_esa[*,*,j] = dt_off
  ;;  Define Unix times for every offset
  t_phi_unix           = t_s[j] + dt_off
  t_phi_esa[*,*,j]     = t_phi_unix
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,t_phi_esa
END
