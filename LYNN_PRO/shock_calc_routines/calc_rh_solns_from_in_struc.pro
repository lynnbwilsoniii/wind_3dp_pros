;+
;*****************************************************************************************
;
;  FUNCTION :   calc_rh_solns_from_in_struc.pro
;  PURPOSE  :   This routine is a wrapping routine for my Rankine-Hugoniot and critical
;                 Mach number software that calculates (and prints of user desires) the
;                 relevant shock parameters and returns them to the user as a structure.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               @load_constants_fund_em_atomic_c2014_batch.pro
;               @load_constants_extra_part_co2014_ci2015_batch.pro
;               tplot_struct_format_test.pro
;               test_plot_axis_range.pro
;               is_a_number.pro
;               time_double.pro
;               time_string.pro
;               trange_clip_data.pro
;               t_get_struc_unix.pro
;               remove_nans.pro
;               str_element.pro
;               t_resample_tplot_struc.pro
;               mag__vec.pro
;               calc_1var_stats.pro
;               rh_solve_lmq.pro
;               sign.pro
;               unit_vec.pro
;               perturb_dot_prod_angle.pro
;               lbw_crit_mf.pro
;               format_vector_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               BVEC_STR  :  Scalar [TPLOT structure] containing the magnetic field
;                              3-vectors [nT, ICB]
;               NO___STR  :  Scalar [TPLOT structure] containing the total number
;                              density [cm^(-3)]
;               TI___STR  :  Scalar [TPLOT structure] containing the total ion
;                              temperature [eV]
;               TE___STR  :  Scalar [TPLOT structure] containing the total electron
;                              temperature [eV]
;               VIN__STR  :  Scalar [TPLOT structure] containing the incident velocity
;                              3-vectors [km/s, ICB]
;               TRAN__UP  :  [2]-Element [double] array of Unix times specifying the start
;                              and end times of corresponding to the upstream region
;               TRAN__DN  :  [2]-Element [double] array of Unix times specifying the start
;                              and end times of corresponding to the downstream region
;
;  EXAMPLES:    
;               [calling sequence]
;               shstr = calc_rh_solns_from_in_struc(bvec_str,No___str,Ti___str,Te___str,Vin__str,$
;                                         tran__up,tran__dn [,NMAX=ngrid] [,FORWARD=forward]     $
;                                         [,PRINTOUT=printout] [,SCNAME=scname])
;
;  KEYWORDS:    
;               NMAX      :  Scalar [long] defining the number of grid points to use
;                              in the Rankine-Hugoniot analysis software.  The number
;                              must satisfy 75 ≤ NMAX ≤ 1000.
;                              [Default = 100L]
;               FORWARD   :  If set, routine assumes the shock in question is a fast
;                              forward shock
;                              [Default = TRUE]
;               PRINTOUT  :  If set, routine will print out the results of the
;                              Rankine-Hugoniot analysis
;                              [Default = FALSE]
;               SCNAME    :  Scalar [string] defining the spacecraft name for output
;                              [Default = 'SC']
;               PHRAN     :  [2]-Element [numeric] array defining the range of azimuthal
;                              angles [degrees] to limit to in the solution finding
;                              [Default = [0,360]]
;               THRAN     :  [2]-Element [numeric] array defining the range of latitudinal
;                              angles [degrees] to limit to in the solution finding
;                              [Default = [-90,90]]
;
;   CHANGED:  1)  Added keywords:  PHRA and THRA
;                                                                   [08/28/2020   v1.0.1]
;             2)  Now smoothes data prior to sending it to the RH software
;                                                                   [08/31/2020   v1.0.2]
;
;   NOTES:      
;               1)  TPLOT structures must have at least the following tags:
;                     X  :  Unix/epoch [double] times [s] serving as abscissa
;                     Y  :  Data array
;               2)  Coordinate Systems
;                     ICB    :  Input Coordinate Basis (e.g., GSE)
;                     SPG    :  Spinning Probe Geometric
;                     SSL    :  Spinning Sun-Sensor L-Vector
;                     DSL    :  Despun Sun-L-VectorZ (THEMIS and MMS Mission)
;                     BCS    :  Body Coordinate System (MMS Mission)
;                     DBCS   :  despun-BCS (MMS Mission)
;                     SMPA   :  Spinning, Major Principal Axis (MMS Mission)
;                     DMPA   :  Despun, Major Principal Axis (MMS Mission)
;                     GEI    :  Geocentric Equatorial Inertial
;                     GEO    :  Geographic
;                     GSE    :  Geocentric Solar Ecliptic
;                     GSM    :  Geocentric Solar Magnetospheric
;                     NCB    :  Normal Incidence Frame Coordinate Basis
;               2)  Reference Frames
;                     SCF    :  SpaceCraft Frame
;                     SHF    :  SHock rest Frame (generic that can include NIF)
;                     NIF    :  Normal Incidence Frame
;                     dHT    :  de Hoffmann-Teller frame
;
;  REFERENCES:  
;               0)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;               1)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               2)  Viñas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               3)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               4)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;               5)  Russell, C.T., J.T. Gosling, R.D. Zwickl, and E.J. Smith (1983),
;                      "Multiple spacecraft observations of interplanetary shocks:  ISEE
;                      Three-Dimensional Plasma Measurements," J. Geophys. Res. 88,
;                      pp. 9941-9947.
;               6)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, T.L. Aggson,
;                      R.R. Anderson, J.T. Gosling, G. Paschmann, and C.T. Russell
;                      (1986a) "The Resolved Layer of a Collisionless, High ß,
;                      Supercritical, Quasi-Perpendicular Shock Wave 1:
;                      Rankine-Hugoniot Geometry, Currents, and Stationarity,"
;                      J. Geophys. Res. Vol. 91, pp. 11,019-11,052.
;               7)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, T.L. Aggson
;                      (1986b) "The Resolved Layer of a Collisionless, High ß,
;                      Supercritical, Quasi-Perpendicular Shock Wave 2:
;                      Dissipative Fluid Electrodynamics," J. Geophys. Res. Vol. 91,
;                      pp. 11,053-11,073.
;               8)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, C.S. Wu,
;                      R.R. Anderson (1986c) "The Resolved Layer of a Collisionless,
;                      High ß, Supercritical, Quasi-Perpendicular Shock Wave 3:
;                      Vlasov Electrodynamics," J. Geophys. Res. Vol. 91,
;                      pp. 11,075-11,097.
;
;   CREATED:  08/26/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/31/2020   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_rh_solns_from_in_struc,bvec_str,No___str,Ti___str,Te___str,Vin__str,      $
                                     tran__up,tran__dn,NMAX=ngrid,FORWARD=forward,      $
                                     PRINTOUT=printout,SCNAME=scname,PHRAN=phran,THRAN=thran

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
def_forw       = 1b
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]          ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]          ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;  Error messages
noinput_mssg   = 'No input was supplied...'
not_tpst_mssg  = 'Invalid TPLOT structures supplied...'
not_tran_mssg  = 'Invalid time ranges supplied for upstream and/or downstream...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 7) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (tplot_struct_format_test(bvec_str,/NOMSSG,/YVECT) EQ 0) OR $
                 (tplot_struct_format_test(No___str,/NOMSSG)        EQ 0) OR $
                 (tplot_struct_format_test(Ti___str,/NOMSSG)        EQ 0) OR $
                 (tplot_struct_format_test(Te___str,/NOMSSG)        EQ 0) OR $
                 (tplot_struct_format_test(Vin__str,/NOMSSG,/YVECT) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,not_tpst_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (test_plot_axis_range(tran__up,/NOMSSG) EQ 0) OR (test_plot_axis_range(tran__dn,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,not_tran_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check Keywords
;;----------------------------------------------------------------------------------------
;;  Check NMAX
IF (is_a_number(ngrid,/NOMSSG)) THEN nmax = LONG((ngrid[0] < 1000L) > 75L) ELSE nmax = 100L
;;  Check FORWARD
IF ~KEYWORD_SET(forward) THEN forward = 0b ELSE IF KEYWORD_SET(forward) THEN forward = 1b ELSE forward = def_forw[0]
;;  Check SCNAME
IF (SIZE(scname,/TYPE) NE 7) THEN sc = 'SC' ELSE sc = scname[0]
;;----------------------------------------------------------------------------------------
;;  Clip data
;;----------------------------------------------------------------------------------------
;;  Upstream
tra_up_u       = time_double(tran__up)
tr_up          = time_string(tra_up_u,PREC=3)
bv_str_up      = trange_clip_data(bvec_str,TRANGE=tra_up_u,PRECISION=3)
No_str_up      = trange_clip_data(No___str,TRANGE=tra_up_u,PRECISION=3)
Ti_str_up      = trange_clip_data(Ti___str,TRANGE=tra_up_u,PRECISION=3)
Te_str_up      = trange_clip_data(Te___str,TRANGE=tra_up_u,PRECISION=3)
Vi_str_up      = trange_clip_data(Vin__str,TRANGE=tra_up_u,PRECISION=3)
;;  Downstream
tra_dn_u       = time_double(tran__dn)
tr_dn          = time_string(tra_dn_u,PREC=3)
bv_str_dn      = trange_clip_data(bvec_str,TRANGE=tra_dn_u,PRECISION=3)
No_str_dn      = trange_clip_data(No___str,TRANGE=tra_dn_u,PRECISION=3)
Ti_str_dn      = trange_clip_data(Ti___str,TRANGE=tra_dn_u,PRECISION=3)
Te_str_dn      = trange_clip_data(Te___str,TRANGE=tra_dn_u,PRECISION=3)
Vi_str_dn      = trange_clip_data(Vin__str,TRANGE=tra_dn_u,PRECISION=3)
tr_mid         = MEAN([tra_up_u,tra_dn_u])
tdate          = STRMID(time_string(tr_mid[0],PREC=3),0L,10L)                   ;;  'YYYY-MM-DD'
;;----------------------------------------------------------------------------------------
;;  Interpolate out NaNs
;;----------------------------------------------------------------------------------------
;;  Define combined structures
all_str_up     = {T0:bv_str_up,T1:Vi_str_up,T2:No_str_up,T3:Ti_str_up,T4:Te_str_up}
all_str_dn     = {T0:bv_str_dn,T1:Vi_str_dn,T2:No_str_dn,T3:Ti_str_dn,T4:Te_str_dn}
nstr           = N_TAGS(all_str_up)
tags           = TAG_NAMES(all_str_up)
;;  Determine how many points to use
all_n_up       = [N_ELEMENTS(bv_str_up.X),N_ELEMENTS(Vi_str_up.X),N_ELEMENTS(No_str_up.X),N_ELEMENTS(Ti_str_up.X),N_ELEMENTS(Te_str_up.X)] > 0L
all_n_dn       = [N_ELEMENTS(bv_str_dn.X),N_ELEMENTS(Vi_str_dn.X),N_ELEMENTS(No_str_dn.X),N_ELEMENTS(Ti_str_dn.X),N_ELEMENTS(Te_str_dn.X)] > 0L
n_up           = MIN(all_n_up,l_up)
n_dn           = MIN(all_n_dn,l_dn)
;;  Fix NaNs in upstream/downstream structures
FOR j=0, nstr[0] - 1L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Upstream structures
  ;;--------------------------------------------------------------------------------------
  struc = all_str_up.(j)
  ddms  = SIZE(struc.Y,/DIMENSIONS)
  ndms  = SIZE(struc.Y,/N_DIMENSIONS)
  IF (ndms[0] EQ 1) THEN nkk = 1L ELSE nkk = ddms[1]
  unix  = t_get_struc_unix(struc)
  dumb  = REPLICATE(d,ddms)
  FOR k=0L, nkk[0] - 1L DO BEGIN
    IF (ndms[0] EQ 1) THEN temp = struc.Y ELSE temp = struc.Y[*,k]
    test = TOTAL(FINITE(temp)) NE N_ELEMENTS(temp)
    IF (test[0]) THEN out = remove_nans(unix,temp,/NO_EXTRAPOLATE) ELSE out = temp
    IF (ndms[0] EQ 1) THEN dumb = out ELSE dumb[*,k] = out
  ENDFOR
  struc.Y = dumb
  str_element,all_str_up,tags[j],struc,/ADD_REPLACE
  ;;--------------------------------------------------------------------------------------
  ;;  Downstream structures
  ;;--------------------------------------------------------------------------------------
  struc = all_str_dn.(j)
  ddms  = SIZE(struc.Y,/DIMENSIONS)
  ndms  = SIZE(struc.Y,/N_DIMENSIONS)
  IF (ndms[0] EQ 1) THEN nkk = 1L ELSE nkk = ddms[1]
  unix  = t_get_struc_unix(struc)
  dumb  = REPLICATE(d,ddms)
  FOR k=0L, nkk[0] - 1L DO BEGIN
    IF (ndms[0] EQ 1) THEN temp = struc.Y ELSE temp = struc.Y[*,k]
    test = TOTAL(FINITE(temp)) NE N_ELEMENTS(temp)
    IF (test[0]) THEN out = remove_nans(unix,temp,/NO_EXTRAPOLATE) ELSE out = temp
    IF (ndms[0] EQ 1) THEN dumb = out ELSE dumb[*,k] = out
  ENDFOR
  struc.Y = dumb
  str_element,all_str_dn,tags[j],struc,/ADD_REPLACE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Interpolate onto a uniform grid
;;----------------------------------------------------------------------------------------
;;  Define time stamps to use for each region
g_unix_up      = all_str_up.(l_up[0]).X
g_unix_dn      = all_str_dn.(l_dn[0]).X
n_ud           = n_up[0] < n_dn[0]
n_all          = n_ud[0]                         ;;  # of points to use
IF (n_all[0] LT 7L) THEN STOP                    ;;  Not enough points --> Should we continue?
g_unix_up      = g_unix_up[0L:(n_ud[0] - 1L)]    ;;  Make sure up/down have same # of elements
g_unix_dn      = g_unix_dn[0L:(n_ud[0] - 1L)]    ;;  Make sure up/down have same # of elements
FOR j=0, nstr[0] - 1L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Upstream structures
  ;;--------------------------------------------------------------------------------------
  struc = all_str_up.(j)
  i_str = t_resample_tplot_struc(struc,g_unix_up,/NO_EXTRAPOLATE,/IGNORE_INT)
  str_element,int_str_up,tags[j],i_str,/ADD_REPLACE
  ;;--------------------------------------------------------------------------------------
  ;;  Downstream structures
  ;;--------------------------------------------------------------------------------------
  struc = all_str_dn.(j)
  i_str = t_resample_tplot_struc(struc,g_unix_dn,/NO_EXTRAPOLATE,/IGNORE_INT)
  str_element,int_str_dn,tags[j],i_str,/ADD_REPLACE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define parameters for input Rankine-Hugoniot analysis software
;;----------------------------------------------------------------------------------------
magf_up        = int_str_up.(0).Y
vsw__up        = int_str_up.(1).Y
dens_up        = int_str_up.(2).Y
temi_up        = int_str_up.(3).Y
teme_up        = int_str_up.(4).Y

magf_dn        = int_str_dn.(0).Y
vsw__dn        = int_str_dn.(1).Y
dens_dn        = int_str_dn.(2).Y
temi_dn        = int_str_dn.(3).Y
teme_dn        = int_str_dn.(4).Y
test_up        = FINITE(magf_up[*,0]) AND FINITE(magf_up[*,1]) AND FINITE(magf_up[*,2]) AND $
                 FINITE(vsw__up[*,0]) AND FINITE(vsw__up[*,1]) AND FINITE(vsw__up[*,2]) AND $
                 FINITE(dens_up)      AND FINITE(temi_up)      AND FINITE(teme_up)
test_dn        = FINITE(magf_dn[*,0]) AND FINITE(magf_dn[*,1]) AND FINITE(magf_dn[*,2]) AND $
                 FINITE(vsw__dn[*,0]) AND FINITE(vsw__dn[*,1]) AND FINITE(vsw__dn[*,2]) AND $
                 FINITE(dens_dn)      AND FINITE(temi_dn)      AND FINITE(teme_dn)
good_up        = WHERE(test_up,gd_up)
good_dn        = WHERE(test_dn,gd_dn)
IF (gd_up[0] LE 3 OR gd_dn[0] LE 3) THEN STOP
test           = (gd_up[0] NE n_all[0]) AND (gd_dn[0] NE n_all[0])
IF (test[0]) THEN BEGIN
  IF (gd_up[0] LT gd_dn[0]) THEN good_dn = good_dn[0L:(gd_up[0] - 1L)] ELSE good_up = good_up[0L:(gd_dn[0] - 1L)]
  n_all          = N_ELEMENTS(good_up)
ENDIF ELSE BEGIN
  test           = (gd_up[0] NE n_all[0]) OR (gd_dn[0] NE n_all[0])
  IF (test[0]) THEN BEGIN
    IF (gd_up[0] LT gd_dn[0]) THEN good_dn = good_dn[0L:(gd_up[0] - 1L)] ELSE good_up = good_up[0L:(gd_dn[0] - 1L)]
  ENDIF
  n_all          = N_ELEMENTS(good_up)
ENDELSE
;;  Redefine variables if necessary
IF (n_all[0] NE n_ud[0]) THEN BEGIN
  magf_up        = magf_up[good_up,*]
  vsw__up        = vsw__up[good_up,*]
  dens_up        = dens_up[good_up]
  temi_up        = temi_up[good_up]
  teme_up        = teme_up[good_up]
  g_unix_up      = g_unix_up[good_up]
  magf_dn        = magf_dn[good_dn,*]
  vsw__dn        = vsw__dn[good_dn,*]
  dens_dn        = dens_dn[good_dn]
  temi_dn        = temi_dn[good_dn]
  teme_dn        = teme_dn[good_dn]
  g_unix_dn      = g_unix_dn[good_dn]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Smooth the data to reduce noise/fluctuations
;;----------------------------------------------------------------------------------------
n_all          = N_ELEMENTS(dens_up)
IF (n_all[0] LT 16) THEN wdth = 3L ELSE IF (n_all[0] GE 16 AND n_all[0] LT  30) THEN wdth =  4L ELSE $
                                        IF (n_all[0] GE 30 AND n_all[0] LT  50) THEN wdth =  6L ELSE $
                                        IF (n_all[0] GE 50 AND n_all[0] LT  70) THEN wdth =  8L ELSE $
                                        IF (n_all[0] GE 70 AND n_all[0] LT 100) THEN wdth = 10L ELSE $
                                        IF (n_all[0] GT 100) THEN wdth = 12L
tempx          = SMOOTH(magf_up[*,0],wdth[0],/NAN,/EDGE_TRUNCATE)
tempy          = SMOOTH(magf_up[*,1],wdth[0],/NAN,/EDGE_TRUNCATE)
tempz          = SMOOTH(magf_up[*,2],wdth[0],/NAN,/EDGE_TRUNCATE)
magf_up        = [[tempx],[tempy],[tempz]]
tempx          = SMOOTH(vsw__up[*,0],wdth[0],/NAN,/EDGE_TRUNCATE)
tempy          = SMOOTH(vsw__up[*,1],wdth[0],/NAN,/EDGE_TRUNCATE)
tempz          = SMOOTH(vsw__up[*,2],wdth[0],/NAN,/EDGE_TRUNCATE)
vsw__up        = [[tempx],[tempy],[tempz]]
tempx          = SMOOTH(     dens_up,wdth[0],/NAN,/EDGE_TRUNCATE)
dens_up        = tempx
tempx          = SMOOTH(     temi_up,wdth[0],/NAN,/EDGE_TRUNCATE)
temi_up        = tempx
tempx          = SMOOTH(     teme_up,wdth[0],/NAN,/EDGE_TRUNCATE)
teme_up        = tempx
tempx          = SMOOTH(magf_dn[*,0],wdth[0],/NAN,/EDGE_TRUNCATE)
tempy          = SMOOTH(magf_dn[*,1],wdth[0],/NAN,/EDGE_TRUNCATE)
tempz          = SMOOTH(magf_dn[*,2],wdth[0],/NAN,/EDGE_TRUNCATE)
magf_dn        = [[tempx],[tempy],[tempz]]
tempx          = SMOOTH(vsw__dn[*,0],wdth[0],/NAN,/EDGE_TRUNCATE)
tempy          = SMOOTH(vsw__dn[*,1],wdth[0],/NAN,/EDGE_TRUNCATE)
tempz          = SMOOTH(vsw__dn[*,2],wdth[0],/NAN,/EDGE_TRUNCATE)
vsw__dn        = [[tempx],[tempy],[tempz]]
tempx          = SMOOTH(     dens_dn,wdth[0],/NAN,/EDGE_TRUNCATE)
dens_dn        = tempx
tempx          = SMOOTH(     temi_dn,wdth[0],/NAN,/EDGE_TRUNCATE)
temi_dn        = tempx
tempx          = SMOOTH(     teme_dn,wdth[0],/NAN,/EDGE_TRUNCATE)
teme_dn        = tempx
;;----------------------------------------------------------------------------------------
;;  Calculate/Define input parameters
;;----------------------------------------------------------------------------------------
;;  Compute magnitudes
bmag_up        = mag__vec(magf_up,/NAN)
bmag_dn        = mag__vec(magf_dn,/NAN)
Vmag_up        = mag__vec(vsw__up,/NAN)
Vmag_dn        = mag__vec(vsw__dn,/NAN)
;;  First compute:  Te + Ti
temp_up        = teme_up + temi_up
temp_dn        = teme_dn + temi_dn
;;----------------------------------------------------------------------------------------
;;  Calculate one-variable stats on input parameters
;;----------------------------------------------------------------------------------------
;;  Define upstream plasma parameter medians and standard deviations
onev_magx_up   = calc_1var_stats(magf_up[*,0],/NAN)
onev_magy_up   = calc_1var_stats(magf_up[*,1],/NAN)
onev_magz_up   = calc_1var_stats(magf_up[*,2],/NAN)
onev_velx_up   = calc_1var_stats(vsw__up[*,0],/NAN)
onev_vely_up   = calc_1var_stats(vsw__up[*,1],/NAN)
onev_velz_up   = calc_1var_stats(vsw__up[*,2],/NAN)
onev_bmag_up   = calc_1var_stats(bmag_up,/NAN)
onev_Vmag_up   = calc_1var_stats(Vmag_up,/NAN)
onev_dens_up   = calc_1var_stats(dens_up,/NAN)
onev_teme_up   = calc_1var_stats(teme_up,/NAN)
onev_temi_up   = calc_1var_stats(temi_up,/NAN)
;;  Define downstream plasma parameter medians and standard deviations
onev_magx_dn   = calc_1var_stats(magf_dn[*,0],/NAN)
onev_magy_dn   = calc_1var_stats(magf_dn[*,1],/NAN)
onev_magz_dn   = calc_1var_stats(magf_dn[*,2],/NAN)
onev_velx_dn   = calc_1var_stats(vsw__dn[*,0],/NAN)
onev_vely_dn   = calc_1var_stats(vsw__dn[*,1],/NAN)
onev_velz_dn   = calc_1var_stats(vsw__dn[*,2],/NAN)
onev_bmag_dn   = calc_1var_stats(bmag_dn,/NAN)
onev_Vmag_dn   = calc_1var_stats(Vmag_dn,/NAN)
onev_dens_dn   = calc_1var_stats(dens_dn,/NAN)
onev_teme_dn   = calc_1var_stats(teme_dn,/NAN)
onev_temi_dn   = calc_1var_stats(temi_dn,/NAN)
;;  Define plasma parameters
B_gse_up       = [onev_magx_up[3],onev_magy_up[3],onev_magz_up[3]]
V_gse_up       = [onev_velx_up[3],onev_vely_up[3],onev_velz_up[3]]
dBgse_up       = [onev_magx_up[4],onev_magy_up[4],onev_magz_up[4]]
dVgse_up       = [onev_velx_up[4],onev_vely_up[4],onev_velz_up[4]]
B_mag_up       = onev_bmag_up[3:4]
V_mag_up       = onev_Vmag_up[3:4]
N_tot_up       = onev_dens_up[3:4]
Teavg_up       = onev_teme_up[3:4]
Tiavg_up       = onev_temi_up[3:4]
B_gse_dn       = [onev_magx_dn[3],onev_magy_dn[3],onev_magz_dn[3]]
V_gse_dn       = [onev_velx_dn[3],onev_vely_dn[3],onev_velz_dn[3]]
dBgse_dn       = [onev_magx_dn[4],onev_magy_dn[4],onev_magz_dn[4]]
dVgse_dn       = [onev_velx_dn[4],onev_vely_dn[4],onev_velz_dn[4]]
B_mag_dn       = onev_bmag_dn[3:4]
V_mag_dn       = onev_Vmag_dn[3:4]
N_tot_dn       = onev_dens_dn[3:4]
Teavg_dn       = onev_teme_dn[3:4]
Tiavg_dn       = onev_temi_dn[3:4]
;;  Define compression ratio
comprat        = onev_dens_dn[3]/onev_dens_up[3]
dcomp_r        = comprat[0]*SQRT((onev_dens_up[4]/onev_dens_up[3])^2d0 + (onev_dens_dn[4]/onev_dens_dn[3])^2d0)
;;----------------------------------------------------------------------------------------
;;  Define software inputs
;;----------------------------------------------------------------------------------------
vsw            = [[[vsw__up]],[[vsw__dn]]]
mag            = [[[magf_up]],[[magf_dn]]]
dens           = [[dens_up],[dens_dn]]
temp           = [[temp_up],[temp_dn]]
nmax           = 150L
;;----------------------------------------------------------------------------------------
;;  Solve Rankine-Hugoniot relations
;;----------------------------------------------------------------------------------------
rever          = (forward[0] EQ 0b)
nqq            = [1,0,1,0,0]
chisq00        = rh_solve_lmq(dens,vsw,mag,temp,NMAX=nmax,NEQS=nqq,SOLN=soln00,PHRAN=phran,THRAN=thran,REVER=rever[0])
nqq            = [1,1,1,1,0]
chisq10        = rh_solve_lmq(dens,vsw,mag,temp,NMAX=nmax,NEQS=nqq,SOLN=soln10,PHRAN=phran,THRAN=thran,REVER=rever[0])
nqq            = [1,1,1,1,1]
chisq20        = rh_solve_lmq(dens,vsw,mag,temp,NMAX=nmax,NEQS=nqq,SOLN=soln20,PHRAN=phran,THRAN=thran,REVER=rever[0])
;;----------------------------------------------------------------------------------------
;;  Define shock parameters
;;----------------------------------------------------------------------------------------
all__Vshn_up   = ABS([soln00.VSHN[0],soln10.VSHN[0],soln20.VSHN[0]])
all_dVshn_up   = ABS([soln00.VSHN[1],soln10.VSHN[1],soln20.VSHN[1]])
all__nshx_up   = [soln00.SH_NORM[0,0],soln10.SH_NORM[0,0],soln20.SH_NORM[0,0]]
all__nshy_up   = [soln00.SH_NORM[1,0],soln10.SH_NORM[1,0],soln20.SH_NORM[1,0]]
all__nshz_up   = [soln00.SH_NORM[2,0],soln10.SH_NORM[2,0],soln20.SH_NORM[2,0]]
all_dnshx_up   = [soln00.SH_NORM[0,1],soln10.SH_NORM[0,1],soln20.SH_NORM[0,1]]
all_dnshy_up   = [soln00.SH_NORM[1,1],soln10.SH_NORM[1,1],soln20.SH_NORM[1,1]]
all_dnshz_up   = [soln00.SH_NORM[2,1],soln10.SH_NORM[2,1],soln20.SH_NORM[2,1]]
all__nsh__up   = [[all__nshx_up],[all__nshy_up],[all__nshz_up]]
all_dnsh__up   = [[all_dnshx_up],[all_dnshy_up],[all_dnshz_up]]
all__Ushn_up   = ABS([soln00.USHN_UP[0],soln10.USHN_UP[0],soln20.USHN_UP[0]])
all_dUshn_up   = ABS([soln00.USHN_UP[1],soln10.USHN_UP[1],soln20.USHN_UP[1]])
all__Ushn_dn   = ABS([soln00.USHN_DN[0],soln10.USHN_DN[0],soln20.USHN_DN[0]])
all_dUshn_dn   = ABS([soln00.USHN_DN[1],soln10.USHN_DN[1],soln20.USHN_DN[1]])
;IF (forward[0] EQ 0b) THEN BEGIN
;  ;;  Need to recalculate Ushn
;  pert           = [-1,0,1]
;  ushnup0        = REPLICATE(d,3,3,3)
;  ushndn0        = REPLICATE(d,3,3,3)
;  FOR j=0L, 2L DO BEGIN
;    vswup  = V_gse_up + pert[j]*dVgse_up
;    vswdn  = V_gse_dn + pert[j]*dVgse_dn
;    FOR k=0L, 2L DO BEGIN
;      FOR i=0L, 2L DO BEGIN
;        vshnu  = all__Vshn_up[k] + pert[i]*all_dVshn_up[k]
;        nsh_0  = [all__nshx_up[k],all__nshy_up[k],all__nshz_up[k]] + pert[i]*[all_dnshx_up[k],all_dnshy_up[k],all_dnshz_up[k]]
;        nsh_1  = REFORM(unit_vec(nsh_0))
;        vshup  = vswup + vshnu[0]*nsh_1
;        vshdn  = vswdn + vshnu[0]*nsh_1
;        ushnup0[k,j,i] = ABS(TOTAL(vshup,/NAN))
;        ushndn0[k,j,i] = ABS(TOTAL(vshdn,/NAN))
;      ENDFOR
;    ENDFOR
;  ENDFOR
;  ;;  Redefine Ushn,j
;  Ushn_up0       = MEDIAN(ABS(ushnup0),DIMENSION=3)
;  Ushn_dn0       = MEDIAN(ABS(ushndn0),DIMENSION=3)
;  dUshn_up       = ABS((MAX(ushnup0,/NAN,DIMENSION=3) - MIN(ushnup0,/NAN,DIMENSION=3))/2d0)
;  dUshn_dn       = ABS((MAX(ushndn0,/NAN,DIMENSION=3) - MIN(ushndn0,/NAN,DIMENSION=3))/2d0)
;  all_dUshn_up   = ABS((MAX(dUshn_up,/NAN,DIMENSION=2) - MIN(dUshn_up,/NAN,DIMENSION=2))/2d0)
;  all_dUshn_dn   = ABS((MAX(dUshn_dn,/NAN,DIMENSION=2) - MIN(dUshn_dn,/NAN,DIMENSION=2))/2d0)
;  all__Ushn_up   = MEDIAN(Ushn_up0,DIMENSION=2)
;  all__Ushn_dn   = MEDIAN(Ushn_dn0,DIMENSION=2)
;ENDIF ELSE BEGIN
;  all__Ushn_up   = ABS([soln00.USHN_UP[0],soln10.USHN_UP[0],soln20.USHN_UP[0]])
;  all_dUshn_up   = ABS([soln00.USHN_UP[1],soln10.USHN_UP[1],soln20.USHN_UP[1]])
;  all__Ushn_dn   = ABS([soln00.USHN_DN[0],soln10.USHN_DN[0],soln20.USHN_DN[0]])
;  all_dUshn_dn   = ABS([soln00.USHN_DN[1],soln10.USHN_DN[1],soln20.USHN_DN[1]])
;ENDELSE
;;  Make sure sign of shock normal is correct
;;    FORWARD = TRUE --> Nshx < 0
nsoln          = N_ELEMENTS(all__nshx_up)
s_nx           = sign(all__nshx_up)
ones           = REPLICATE(1d0,nsoln[0])
testr          = (s_nx LT 0) AND ~forward[0]
testf          = (s_nx GT 0) AND  forward[0]
bad            = WHERE(testr OR testf,bd)
IF (bd[0] GT 0) THEN all__nsh__up[bad,*] *= -1d0
;;----------------------------------------------------------------------------------------
;;  Recalculate n_sh with proper normalization
;;----------------------------------------------------------------------------------------
gnorms         = REPLICATE(d,nsoln[0],5L,3L)
pert           = [-1,-0.5,0,0.5,1]
norm_gse       = REPLICATE(d,nsoln[0],3L)
dnormgse       = REPLICATE(d,nsoln[0],3L)
FOR j=0L, nsoln[0] - 1L DO BEGIN
  norm_sh  = REFORM(all__nsh__up[j,*])
  dnormsh  = REFORM(all_dnsh__up[j,*])
  FOR k=0L, N_ELEMENTS(pert) - 1L DO BEGIN
    gnorms[j,k,*] = unit_vec(norm_sh + pert[k]*dnormsh,/NAN)
  ENDFOR
  onev_nshx      = calc_1var_stats(REFORM(gnorms[j,*,0]),/NAN)
  onev_nshy      = calc_1var_stats(REFORM(gnorms[j,*,1]),/NAN)
  onev_nshz      = calc_1var_stats(REFORM(gnorms[j,*,2]),/NAN)
  ;;  Define normal as median of values
  norm_gse[j,*]  = REFORM(unit_vec([onev_nshx[3],onev_nshy[3],onev_nshz[3]],/NAN))
  dnormgse[j,*]  = [onev_nshx[4],onev_nshy[4],onev_nshz[4]]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Calculate shock normal angles
;;----------------------------------------------------------------------------------------
dumb           = REPLICATE(d,nsoln[0],n_all[0],3L)
v_1            = dumb
v_2            = dumb
dv1            = dumb
dv2            = dumb
a_da           = dumb[*,*,0]
FOR j=0L, nsoln[0] - 1L DO BEGIN
  v_2[j,*,*] = magf_up
  FOR k=0L, 2L DO BEGIN
    v_1[j,*,k] = norm_gse[j,k]
    dv1[j,*,k] = dnormgse[j,k]
    dv2[j,*,k] = dBgse_up[k]
  ENDFOR
  temp      = perturb_dot_prod_angle(REFORM(v_1[j,*,*]),REFORM(v_2[j,*,*]),/NAN,/TH_0_90,DELTA_V1=REFORM(dv1[j,*,*]),DELTA_V2=REFORM(dv2[j,*,*]),/USE_MED,/USE_STAND)
  a_da[j,*] = temp[*,0]
ENDFOR
theta_Bn0      = REFORM(a_da)
onev_thBn0     = REPLICATE(d,nsoln[0],13L)
FOR j=0L, nsoln[0] - 1L DO onev_thBn0[j,*] = calc_1var_stats(theta_Bn0[j,*],/NAN)
all__thbn      = REFORM(onev_thBn0[*,3L])      ;;  Median values [deg] for 3 methods
all_dthbn      = REFORM(onev_thBn0[*,4L])      ;;  Std. Dev. values [deg] for 3 methods
;;----------------------------------------------------------------------------------------
;;  Calculate upstream speeds [km/s] and Mach numbers
;;----------------------------------------------------------------------------------------
;;    Speeds
valf_fac       = 1d-9/SQRT(muo[0]*1d6*mp[0])*1d-3
cs_fac         = SQRT(5d0/3d0*eV2J[0]/mp[0])*1d-3
;;  Calculate Alfven and Sound speeds [km/s]
v_alfven_0     = valf_fac[0]*bmag_up/SQRT(dens_up)
v_sound__0     = cs_fac[0]*SQRT(temp_up/2d0)
;;  Define median of speeds [km/s]
onev_va        = calc_1var_stats(REFORM(v_alfven_0,N_ELEMENTS(v_alfven_0)),/NAN)
onevcs0        = calc_1var_stats(REFORM(v_sound__0,N_ELEMENTS(v_sound__0)),/NAN)
V_a_up         = onev_va[3:4]
Cs0_up         = onevcs0[3:4]
;;  Calculate fast mode speeds [km/s]
cos2thbn       = COS(all__thbn*!DPI/18d1)^2d0
v_fast___0     = REPLICATE(d,nsoln[0],n_all[0])
onevvf0        = REPLICATE(d,nsoln[0],13L)
FOR j=0L, nsoln[0] - 1L DO BEGIN
  term0           = (v_alfven_0^2d0 + v_sound__0^2d0)
  term1           = 4d0*(v_alfven_0^2d0)*(v_sound__0^2d0)
  vfsqx2          = term0 + SQRT(term0^2d0 - term1*cos2thbn[j])
  v_fast___0[j,*] = SQRT(vfsqx2/2d0)
  ;;  Calculate median and Std. Dev. values [km/s]
  onevvf0[j,*]    = calc_1var_stats(REFORM(v_fast___0[j,*]),/NAN)
ENDFOR
;;  Define median and Std. Dev. values [km/s]
Vf0_up         = REPLICATE(d,nsoln[0],2L)
Vf0_up[*,0]    = onevvf0[*,3L]
Vf0_up[*,1]    = onevvf0[*,4L]
;;  Define Mach numbers and uncertainties
M_A__up        = REPLICATE(d,nsoln[0],2L)
MCs0_up        = M_A__up
M_f0_up        = M_A__up
M_A__up[*,0]   = all__Ushn_up/V_a_up[0]
MCs0_up[*,0]   = all__Ushn_up/Cs0_up[0]
M_f0_up[*,0]   = all__Ushn_up/Vf0_up[*,0]
M_A__up[*,1]   = M_A__up[*,0]*SQRT((V_a_up[1]/V_a_up[0])^2d0 + (all_dUshn_up/all__Ushn_up)^2d0)
MCs0_up[*,1]   = MCs0_up[*,0]*SQRT((Cs0_up[1]/Cs0_up[0])^2d0 + (all_dUshn_up/all__Ushn_up)^2d0)
M_f0_up[*,1]   = M_f0_up[*,0]*SQRT((Vf0_up[*,1]/Vf0_up[*,0])^2d0 + (all_dUshn_up/all__Ushn_up)^2d0)
;;----------------------------------------------------------------------------------------
;;  Calculate critical Mach numbers
;;----------------------------------------------------------------------------------------
;;  ß = (3/5) (Cs/VA)^2
betat0_up      = 3d0/5d0*Cs0_up[0]^2d0/V_a_up[0]^2d0
dbetat0up      = 2d0*betat0_up*SQRT((Cs0_up[1]/Cs0_up[0])^2d0 + (V_a_up[1]/V_a_up[0])^2d0)
;;  Define perturbed variable values
ones           = [-1,0,1]
betat0_up_lmh  = REPLICATE(d,nsoln[0],3L)               ;;  i.e., [A - ∂A, A, A + ∂A]
thetbn_up_lmh  = betat0_up_lmh
FOR k=0L, 2L DO BEGIN
  betat0_up_lmh[*,k] = (betat0_up[0] + ones[k]*dbetat0up[0]) > 1d-4
  FOR j=0L, nsoln[0] - 1L DO thetbn_up_lmh[j,k] = all__thbn[j] + ones[k]*all_dthbn[j]
ENDFOR
;;  Define 1st critical Mach numbers
gg             = 5d0/3d0
Mcr_EK84_0     = REPLICATE(d,nsoln[0],2L)          ;;  1st critical Mach number, Mcr1, and uncertainty [Edmiston&Kennel, 1984]
FOR j=0L, nsoln[0] - 1L DO BEGIN
  ;;  Define dummy variables
  temp_Mcr0        = REPLICATE(d,3L,3L)
  x0               = REFORM(betat0_up_lmh[j,*])
  yy               = REFORM(thetbn_up_lmh[j,*])
  FOR ii=0L, 2L DO FOR jj=0L, 2L DO temp_Mcr0[ii,jj] = lbw_crit_mf(gg[0],x0[ii],yy[jj],TYPE='1',/SILENT)
  onevs0           = calc_1var_stats(temp_Mcr0,/NAN)
  Mcr_EK84_0[j,0]  = onevs0[2]
  Mcr_EK84_0[j,1]  = onevs0[4]
ENDFOR
;;  Define Mf/Mcr
MfMcEK840      = REPLICATE(d,nsoln[0],2L)          ;;  Mf/Mcr1
MfMcEK840[*,0] = M_f0_up[*,0]/Mcr_EK84_0[*,0]
MfMcEK840[*,1] = MfMcEK840[*,0]*SQRT((Mcr_EK84_0[*,1]/Mcr_EK84_0[*,0])^2d0 + (M_f0_up[*,1]/M_f0_up[*,0])^2d0)
;;----------------------------------------------------------------------------------------
;;  Calculate quality flags
;;----------------------------------------------------------------------------------------
nt             = 3L
err_vshn_up    = REPLICATE(d,nt[0])
err_ushn_up    = err_vshn_up
err_ushn_dn    = err_vshn_up
err_m_f__up    = err_vshn_up
err_thbn_up    = err_vshn_up
err_tot_all    = err_vshn_up
FOR j=0L, nt[0] - 1L DO BEGIN
  err_vshn_up[j]      = all_dVshn_up[j]/all__Vshn_up[j]
  err_ushn_up[j]      = all_dUshn_up[j]/all__Ushn_up[j]
  err_ushn_dn[j]      = all_dUshn_dn[j]/all__Ushn_dn[j]
  err_thbn_up[j]      = all_dthbn[j]/all_dthbn[j]
  err_m_f__up[j]      = M_f0_up[j,1]/M_f0_up[j,0]
ENDFOR
err_tot_all    = err_vshn_up + err_ushn_up + err_ushn_dn + err_thbn_up + err_m_f__up
qual__flags    = REPLICATE(0,nt[0])
good_10        = WHERE(err_tot_all GE 0.0 AND err_tot_all LT 0.8,gd_10)
good_09        = WHERE(err_tot_all GE 0.8 AND err_tot_all LT 1.0,gd_09)
good_08        = WHERE(err_tot_all GE 1.0 AND err_tot_all LT 1.1,gd_08)
good_07        = WHERE(err_tot_all GE 1.1 AND err_tot_all LT 2.0,gd_07)
good_06        = WHERE(err_tot_all GE 2.0 AND err_tot_all LT 3.0,gd_06)
good_05        = WHERE(err_tot_all GE 3.0 AND err_tot_all LT 4.0,gd_05)
good_04        = WHERE(err_tot_all GE 4.0 AND err_tot_all LT 5.0,gd_04)
good_03        = WHERE(err_tot_all GE 5.0 AND err_tot_all LT 6.0,gd_03)
good_02        = WHERE(err_tot_all GE 6.0 AND err_tot_all LT 7.0,gd_02)
good_01        = WHERE(err_tot_all GE 7.0 AND err_tot_all LT 8.0,gd_01)
good_00        = WHERE(err_tot_all GE 8.0 AND err_tot_all LT 1e5,gd_00)
IF (gd_10[0] GT 0) THEN qual__flags[good_10] = 10
IF (gd_09[0] GT 0) THEN qual__flags[good_09] =  9
IF (gd_08[0] GT 0) THEN qual__flags[good_08] =  8
IF (gd_07[0] GT 0) THEN qual__flags[good_07] =  7
IF (gd_06[0] GT 0) THEN qual__flags[good_06] =  6
IF (gd_05[0] GT 0) THEN qual__flags[good_05] =  5
IF (gd_04[0] GT 0) THEN qual__flags[good_04] =  4
IF (gd_03[0] GT 0) THEN qual__flags[good_03] =  3
IF (gd_02[0] GT 0) THEN qual__flags[good_02] =  2
IF (gd_01[0] GT 0) THEN qual__flags[good_01] =  1
IF (gd_00[0] GT 0) THEN qual__flags[good_00] =  0
;;----------------------------------------------------------------------------------------
;;  Define some printing options
;;----------------------------------------------------------------------------------------
nt             = 3L
IF KEYWORD_SET(printout) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Print out to screen
  ;;--------------------------------------------------------------------------------------
  ;;  Define some header/info stuff
  nallstr        = STRTRIM(STRING(n_all[0],FORMAT='(I5.5)'),2L)
  line0          = ';;----------------------------------------------------------------------------------------'
  line2          = ';;  ----------------------'
  line3          = ';;  ==============================='
  lineup         = ';;  Upstream Plasma Parameters ['+nallstr[0]+' pts]'
  linedp         = ';;  Downstream Plasma Parameters ['+nallstr[0]+' pts]'
  lineus         = ';;  Upstream Shock Parameters'
  mform          = '(a25,f9.3,"  +/-",f8.3)'
  ;;  Define date/probe strings
  print_suffx    = ';; For '+STRUPCASE(sc[0])+' on '+tdate[0]+'  ['+(['Reverse','Forward'])[forward[0]]+' Shock]'
  print_tr_up    = ':  '+STRMID(tr_up[0],11,8)+' -- '+STRMID(tr_up[1],11,8)+' UTC'
  print_tr_dn    = ':  '+STRMID(tr_dn[0],11,8)+' -- '+STRMID(tr_dn[1],11,8)+' UTC'
  print_outup    = print_suffx[0]+', Upstream'+print_tr_up[0]
  print_outdn    = print_suffx[0]+', Downstream'+print_tr_dn[0]
  forrev_strs    = '['+(['Reverse','Forward'])[forward[0]]+' Shock]'
  ;;  Define solution strings
  linemE2n4s     = ';;  => Equations 2 and 4, For '+STRUPCASE(sc[0])+' '+forrev_strs[0]+' IP shock on '+tdate[0]
  linemE2t5s     = ';;  => Equations 2, 3, 4, and 5, For '+STRUPCASE(sc[0])+' '+forrev_strs[0]+' IP shock on '+tdate[0]
  linemE2t6s     = ';;  => Equations 2, 3, 4, 5, and 6, For '+STRUPCASE(sc[0])+' '+forrev_strs[0]+' IP shock on '+tdate[0]
  linemEabc      = [linemE2n4s[0],linemE2t5s[0],linemE2t6s[0]]
  line1s         = ';;  For '+STRUPCASE(sc[0])+' on '+tdate[0]+' '+forrev_strs[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Print out header info
  ;;--------------------------------------------------------------------------------------
  PRINT,line0[0]
  PRINT,line0[0]
  PRINT,print_suffx[0]+', Rankine-Hugoniot Results'
  PRINT,print_outup[0]
  PRINT,print_outdn[0]
  PRINT,line0[0]
  PRINT,line0[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Print out quality flag definitions
  ;;--------------------------------------------------------------------------------------
  PRINT,';;  Quality Flag Definitions'
  PRINT,';;  0.0 < error < 0.8  :  10  (i.e., best)'
  PRINT,';;  0.8 ≤ error < 1.0  :   9'
  PRINT,';;  1.0 ≤ error < 1.1  :   8'
  PRINT,';;  1.1 ≤ error < 2.0  :   7'
  PRINT,';;  2.0 ≤ error < 3.0  :   6'
  PRINT,';;  3.0 ≤ error < 4.0  :   5'
  PRINT,';;  4.0 ≤ error < 5.0  :   4'
  PRINT,';;  5.0 ≤ error < 6.0  :   3'
  PRINT,';;  6.0 ≤ error < 7.0  :   2'
  PRINT,';;  7.0 ≤ error < 8.0  :   1'
  PRINT,';;  8.0 ≤ error        :   0'
  PRINT,';;'
  PRINT,';;'
  line1          = line1s[0]
  ;;--------------------------------------------------------------------------------------
  ;;  Print upstream plasma parameters
  ;;--------------------------------------------------------------------------------------
  PRINT,line0[0]
  PRINT,line0[0]
  PRINT,line0[0]
  PRINT,line1[0]
  PRINT,line2[0]
  PRINT,';;'
  PRINT,lineup[0]
  PRINT,line3[0]
  PRINT,';;  Box [GSE, nT]       :',B_gse_up[0],dBgse_up[0],FORMAT=mform[0]
  PRINT,';;  Boy [GSE, nT]       :',B_gse_up[1],dBgse_up[1],FORMAT=mform[0]
  PRINT,';;  Boz [GSE, nT]       :',B_gse_up[2],dBgse_up[2],FORMAT=mform[0]
  PRINT,';;  Vpx [GSE, km/s]     :',V_gse_up[0],dVgse_up[0],FORMAT=mform[0]
  PRINT,';;  Vpy [GSE, km/s]     :',V_gse_up[1],dVgse_up[1],FORMAT=mform[0]
  PRINT,';;  Vpz [GSE, km/s]     :',V_gse_up[2],dVgse_up[2],FORMAT=mform[0]
  PRINT,';;  Bo  [Mag, nT]       :',B_mag_up[0],B_mag_up[1],FORMAT=mform[0]
  PRINT,';;  Vp  [Mag, km/s]     :',V_mag_up[0],V_mag_up[1],FORMAT=mform[0]
  PRINT,';;  Np  [Mag, cm^(-3)]  :',N_tot_up[0],N_tot_up[1],FORMAT=mform[0]
  PRINT,';;  Te  [Mag, eV]       :',Teavg_up[0],Teavg_up[1],FORMAT=mform[0]
  PRINT,';;  Ti  [Mag, eV]       :',Tiavg_up[0],Tiavg_up[1],FORMAT=mform[0]
  PRINT,';;  V_A_up [km/s]       :',V_a_up[0],V_a_up[1],FORMAT=mform[0]
  PRINT,';;  C_s_up [km/s]       :',Cs0_up[0],Cs0_up[1],FORMAT=mform[0]
  PRINT,';;  beta_tot_up [N/A]   :',betat0_up[0],dbetat0up[0],FORMAT=mform[0]
  PRINT,';;'
  ;;--------------------------------------------------------------------------------------
  ;;  Print downstream plasma parameters
  ;;--------------------------------------------------------------------------------------
  PRINT,';;'
  PRINT,linedp[0]
  PRINT,line3[0]
  PRINT,';;  Box [GSE, nT]       :',B_gse_dn[0],dBgse_dn[0],FORMAT=mform[0]
  PRINT,';;  Boy [GSE, nT]       :',B_gse_dn[1],dBgse_dn[1],FORMAT=mform[0]
  PRINT,';;  Boz [GSE, nT]       :',B_gse_dn[2],dBgse_dn[2],FORMAT=mform[0]
  PRINT,';;  Vpx [GSE, km/s]     :',V_gse_dn[0],dVgse_dn[0],FORMAT=mform[0]
  PRINT,';;  Vpy [GSE, km/s]     :',V_gse_dn[1],dVgse_dn[1],FORMAT=mform[0]
  PRINT,';;  Vpz [GSE, km/s]     :',V_gse_dn[2],dVgse_dn[2],FORMAT=mform[0]
  PRINT,';;  Bo  [Mag, nT]       :',B_mag_dn[0],B_mag_dn[1],FORMAT=mform[0]
  PRINT,';;  Vp  [Mag, km/s]     :',V_mag_dn[0],V_mag_dn[1],FORMAT=mform[0]
  PRINT,';;  Np  [Mag, cm^(-3)]  :',N_tot_dn[0],N_tot_dn[1],FORMAT=mform[0]
  PRINT,';;  Te  [Mag, eV]       :',Teavg_dn[0],Teavg_dn[1],FORMAT=mform[0]
  PRINT,';;  Ti  [Mag, eV]       :',Tiavg_dn[0],Tiavg_dn[1],FORMAT=mform[0]
  PRINT,';;'
  ;;--------------------------------------------------------------------------------------
  ;;  Print shock parameters
  ;;--------------------------------------------------------------------------------------
  FOR j=0L, nt[0] - 1L DO BEGIN
    linemEs        = linemEabc[j]
    nshgse_str     = format_vector_string(REFORM(norm_gse[j,*]),PREC=3)
    dnshgsestr     = format_vector_string(REFORM(dnormgse[j,*]),PREC=3)
    PRINT,';;'
    PRINT,lineus[0]
    PRINT,line2[0]
    PRINT,linemEs[0]
    PRINT,line2[0]
    PRINT,line3[0]
    PRINT,';;  Fit Quality Flag    :   ',qual__flags[j]
    PRINT,';;  N_sh [GSE]          :   '+nshgse_str[0]+'  +/-  '+dnshgsestr[0]
    PRINT,';;  Theta_Bn [deg]      :',all__thbn[j],all_dthbn[j],FORMAT=mform[0]
    PRINT,';;  Vshn_up [km/s]      :',all__Vshn_up[j],all_dVshn_up[j],FORMAT=mform[0]
    PRINT,';;  Ushn_up [km/s]      :',all__Ushn_up[j],all_dUshn_up[j],FORMAT=mform[0]
    PRINT,';;  Ushn_dn [km/s]      :',all__Ushn_dn[j],all_dUshn_dn[j],FORMAT=mform[0]
    PRINT,';;  V_f__up [km/s]      :',Vf0_up[j,0],Vf0_up[j,1],FORMAT=mform[0]
    PRINT,';;  M_Cs_up [N/A]       :',MCs0_up[j,0],MCs0_up[j,1],FORMAT=mform[0]
    PRINT,';;  M_A__up [N/A]       :',M_A__up[j,0],M_A__up[j,1],FORMAT=mform[0]
    PRINT,';;  M_f__up [N/A]       :',M_f0_up[j,0],M_f0_up[j,1],FORMAT=mform[0]
    PRINT,';;  M_cr_up [N/A]       :',Mcr_EK84_0[j,0],Mcr_EK84_0[j,1],FORMAT=mform[0]
    PRINT,';;  M_f_up/Mcr_up [N/A] :',MfMcEK840[j,0],MfMcEK840[j,1],FORMAT=mform[0]
    PRINT,line0[0]
    PRINT,line0[0]
    PRINT,';;'
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
C_s_up         = Cs0_up
V_f_up         = Vf0_up
M_Cs_up        = MCs0_up
M_f__up        = M_f0_up
beta_t_up      = [betat0_up[0],dbetat0up[0]]
Mcr_EK84       = Mcr_EK84_0
MfMcEK84       = MfMcEK840
gind_sh        = [0,1,2]
;;  Define plasma parameter structure
tags           = ['bgse_vec','vgse_vec','bgse_mag','vgse_mag','dens_tot','Te_val','Ti_val']
up_struc       = CREATE_STRUCT(tags,[[B_gse_up],[dBgse_up]],[[V_gse_up],[dVgse_up]],B_mag_up,V_mag_up,$
                                    N_tot_up,Teavg_up,Tiavg_up)
dn_struc       = CREATE_STRUCT(tags,[[B_gse_dn],[dBgse_dn]],[[V_gse_dn],[dVgse_dn]],B_mag_dn,V_mag_dn,$
                                    N_tot_dn,Teavg_dn,Tiavg_dn)
;;  Define shock parameter structure
tags           = ['N2_N1_ratio','nsh_gse_vec','theta_Bn','beta_tot_up','Cs_up','VA_up','Vf_up','Vshn_up','Ushn_up','Ushn_dn','Ms_up','MA_up','Mf_up','M_cr1','Mf_Mcr']
nsh_out        = {Y:REFORM(norm_gse[gind_sh,*]),DY:REFORM(dnormgse[gind_sh,*])}
thbn_out       = {Y:REFORM(all__thbn[gind_sh]),DY:REFORM(all_dthbn[gind_sh])}
V_f_up_out     = {Y:REFORM(V_f_up[gind_sh,0]),DY:REFORM(V_f_up[gind_sh,1])}
Vshnup_out     = {Y:REFORM(all__Vshn_up[gind_sh]),DY:REFORM(all_dVshn_up[gind_sh])}
Ushnup_out     = {Y:REFORM(all__Ushn_up[gind_sh]),DY:REFORM(all_dUshn_up[gind_sh])}
Ushndn_out     = {Y:REFORM(all__Ushn_dn[gind_sh]),DY:REFORM(all_dUshn_dn[gind_sh])}
MCs_up_out     = {Y:REFORM(M_Cs_up[gind_sh,0]),DY:REFORM(M_Cs_up[gind_sh,1])}
M_A_up_out     = {Y:REFORM(M_A__up[gind_sh,0]),DY:REFORM(M_A__up[gind_sh,1])}
M_f_up_out     = {Y:REFORM(M_f__up[gind_sh,0]),DY:REFORM(M_f__up[gind_sh,1])}
Mcr_up_out     = {Y:REFORM(Mcr_EK84[gind_sh,0]),DY:REFORM(Mcr_EK84[gind_sh,1])}
Mf2Mcr_out     = {Y:REFORM(MfMcEK84[gind_sh,0]),DY:REFORM(MfMcEK84[gind_sh,1])}
sh_struc       = CREATE_STRUCT(tags,[comprat[0],dcomp_r[0]],nsh_out,thbn_out,beta_t_up,$
                                    C_s_up,V_a_up,V_f_up_out,Vshnup_out,Ushnup_out,    $
                                    Ushndn_out,MCs_up_out,M_A_up_out,M_f_up_out,       $
                                    Mcr_up_out,Mf2Mcr_out)
;;  Define output structure
tags           = ['UP_PLASMA_PARAMS','DN_PLASMA_PARAMS','SHOCK_PARAMS','FORWARD','TR_UP','TR_DN','PROBE']
out_struc      = CREATE_STRUCT(tags,up_struc,dn_struc,sh_struc,forward[0],tr_up,tr_dn,sc[0])
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,out_struc
END