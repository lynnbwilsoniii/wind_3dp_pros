;+
;*****************************************************************************************
;
;  FUNCTION :   t_4sc_normal_calc.pro
;  PURPOSE  :   This routine takes the TPLOT handles associated with spacecraft positions
;                 from at least 4 spacecraft and calculates the associated normal unit
;                 vector associated with user defined time stamps.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_tplot_handle.pro
;               get_data.pro
;               tplot_struct_format_test.pro
;               t_resample_tplot_struc.pro
;               lbw_diff.pro
;               mag__vec.pro
;               unit_vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TPHANDLES    :  [4]-Element [string] array defining set and valid TPLOT
;                                 handles associated with spacecraft positions all in
;                                 the same coordinate basis
;               UNIX         :  [N,4]-Element [double] array defining the time stamps of
;                                 points of interest to use for calculating the normal
;                                 unit vector.
;
;  EXAMPLES:    
;               [calling sequence]
;               struc = t_4sc_normal_calc(tphandles,unix [,PERTDT=pertdt] [,/NOMSSG])
;
;  KEYWORDS:    
;               PERTDT       :  Scalar [numeric] defining the delta-t for the perturbing
;                                 time stamps about the time of interest
;                                 [Default = 0.01]
;               NOMSSG       :  If set, routine will not inform user of elapsed
;                                 computational time [s]
;                                 [Default = FALSE]
;
;   CHANGED:  1)  Updated calculation to include permutations of possible SC
;                   combinations
;                                                                   [08/25/2012   v1.0.1]
;             2)  Since the permutations of every SC combination yielded the same results
;                   after properly implemented, the new approach is to perturb the time
;                   about which the user is interested and return an array of results
;                   for stability analysis/comparison and output structure no longer
;                   contains the M_VEC_ALL tag and
;                   added keyword:  PERTDT
;                                                                   [09/02/2012   v1.1.0]
;
;   NOTES:      
;               1)  This routine uses LU decomposition
;                     A . X = B
;                       A_ijk = (∆r_ij)_k
;                       B_ijk = (T_i - T_j)_k
;               2)  ICB  =  Input Coordinate Basis
;               3)  Coordinate Systems
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
;                     ICB    :  Input Coordinate Basis (e.g., GSE)
;
;  REFERENCES:  
;               0)  See IDL's documentation for:
;                     https://www.harrisgeospatial.com/docs/LA_LUDC.html
;                     https://www.harrisgeospatial.com/docs/LA_LUSOL.html
;               1)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;
;   CREATED:  08/12/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/02/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_4sc_normal_calc,tphandles,unix,PERTDT=pertdt,NOMSSG=nomssg

ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
npert          = 33L                                   ;;  # of perturbing points about selected time
npmid          = 16L                                   ;;  Element of midpoint in perturbing array
perd           = DINDGEN(npert[0]) - npmid[0]          ;;  Array of perturbing elements
usearr         = LINDGEN(5) + (npmid[0] - 2L)          ;;  Array of perturbing elements to use in analysis
;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
;;  Define some default strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_bcs      = 'bcs'                    ;;  Body Coordinate System (of MMS spacecraft)
coord_dbcs     = 'dbcs'                   ;;  despun-BCS
coord_dmpa     = 'dmpa'                   ;;  Despun, Major Principal Axis (coordinate system)
coordj2000     = 'j2000'                  ;;  GEI/J2000
coord_mag      = 'mag'
vec_str        = ['x','y','z']
vec_col        = [250,150, 50]
fac_lab        = ['par','per','tot']
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
;;  Error messages
noinput_mssg   = 'No input was supplied...'
no_tpns_mssg   = 'Not enough valid TPLOT handles supplied...'
badinpt_mssg   = 'Incorrect input format was supplied:  UNIX must be an [N,4]-element [double] array'
battpdt_mssg   = 'The TPLOT handles supplied did not contain data...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2 OR SIZE(tphandles,/TYPE) NE 7 OR is_a_number(unix,/NOMSSG) EQ 0) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = test_tplot_handle(tphandles,TPNMS=tpns)
good           = WHERE(tpns NE '',gd)
IF (gd[0] LT 4 OR ~test[0]) THEN BEGIN
  MESSAGE,no_tpns_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
sznd           = SIZE(unix,/N_DIMENSIONS)
szdd           = SIZE(unix,/DIMENSIONS)
test           = ((N_ELEMENTS(unix) MOD 4) NE 0) OR ((sznd[0] NE 2) AND (N_ELEMENTS(unix) NE 4))
IF (test[0]) THEN BEGIN
  MESSAGE,badinpt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define relevant info
IF (sznd[0] NE 2) THEN BEGIN
  times = 1d0*REFORM(unix,1,4)
ENDIF ELSE BEGIN
  IF (szdd[1] NE 4) THEN times = 1d0*TRANSPOSE(unix) ELSE times = 1d0*unix
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check PERTDT
IF (is_a_number(pertdt,/NOMSSG)) THEN pdt = ABS(1d0*pertdt[0]) ELSE pdt = 1d-2
;;  Define perturbing time array
pert           = perd*pdt[0]                             ;;  Converted to ∆t about t_j
;;----------------------------------------------------------------------------------------
;;  Calculate spacecraft positions at time of interest
;;----------------------------------------------------------------------------------------
;;  Get positions
get_data,tpns[0],DATA=scpos0
get_data,tpns[1],DATA=scpos1
get_data,tpns[2],DATA=scpos2
get_data,tpns[3],DATA=scpos3
test           = (tplot_struct_format_test(scpos0,/NOMSSG) EQ 0) OR $
                 (tplot_struct_format_test(scpos1,/NOMSSG) EQ 0) OR $
                 (tplot_struct_format_test(scpos2,/NOMSSG) EQ 0) OR $
                 (tplot_struct_format_test(scpos3,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,battpdt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define times of SC positions
unix0          = t_get_struc_unix(scpos0,TSHFT_ON=tshft_on)
unix1          = t_get_struc_unix(scpos1,TSHFT_ON=tshft_on)
unix2          = t_get_struc_unix(scpos2,TSHFT_ON=tshft_on)
unix3          = t_get_struc_unix(scpos3,TSHFT_ON=tshft_on)
;;  Define params for looping
nt             = N_ELEMENTS(times[*,0])
;;  [T,P,S,V] {T = # of times, P = # of perturbed pts, S = # of SC, V = # of vector components}
new_posi       = REPLICATE(d,nt[0],5L,4L,3L)
new_unix       = REPLICATE(d,nt[0],5L,4L)
posi_str       = {T0:scpos0,T1:scpos1,T2:scpos2,T3:scpos3}
unix_str       = {T0:unix0,T1:unix1,T2:unix2,T3:unix3}
FOR k=0L, 3L DO BEGIN
  refts          = times[*,k]
  d_pos          = posi_str.(k)
  FOR j=0L, nt[0] - 1L DO BEGIN
    newt               = refts[j] + pert
    d_spl              = t_resample_tplot_struc(d_pos,newt,/ISPLINE,/NO_EXTRAPOLATE,/IGNORE_INT)
    IF (SIZE(d_spl,/TYPE) NE 8) THEN CONTINUE
    new_pos0           = REFORM(d_spl.Y[usearr,*])
    new_unix[j,*,k]    = newt[usearr]
    new_posi[j,*,k,*]  = new_pos0
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Perform LU decomposition
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return 5 solutions corresponding to perturbed points on either side of desired solution
;;    to check for stability of results
V_out__n       = REPLICATE(d,nt[0],5L,2L)      ;;  Speed along outward normal [distance units per second]
n_icb_st       = REPLICATE(d,nt[0],5L,3L,2L)   ;;  Outward normal unit vector [ICB]
FOR j=0L, nt[0] - 1L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Construct difference 3x3 tensors
  ;;--------------------------------------------------------------------------------------
  ;;  ∆r_ij = r_i - r_j
  dr_12_st       = lbw_diff(REFORM(new_posi[j,0L,0L,*]),REFORM(new_posi[j,0L,1L,*]),/NAN)
  dr_13_st       = lbw_diff(REFORM(new_posi[j,0L,0L,*]),REFORM(new_posi[j,0L,2L,*]),/NAN)
  dr_14_st       = lbw_diff(REFORM(new_posi[j,0L,0L,*]),REFORM(new_posi[j,0L,3L,*]),/NAN)
  dr_21_st       = lbw_diff(REFORM(new_posi[j,1L,0L,*]),REFORM(new_posi[j,1L,1L,*]),/NAN)
  dr_23_st       = lbw_diff(REFORM(new_posi[j,1L,0L,*]),REFORM(new_posi[j,1L,2L,*]),/NAN)
  dr_24_st       = lbw_diff(REFORM(new_posi[j,1L,0L,*]),REFORM(new_posi[j,1L,3L,*]),/NAN)
  dr_31_st       = lbw_diff(REFORM(new_posi[j,2L,0L,*]),REFORM(new_posi[j,2L,1L,*]),/NAN)
  dr_32_st       = lbw_diff(REFORM(new_posi[j,2L,0L,*]),REFORM(new_posi[j,2L,2L,*]),/NAN)
  dr_34_st       = lbw_diff(REFORM(new_posi[j,2L,0L,*]),REFORM(new_posi[j,2L,3L,*]),/NAN)
  dr_41_st       = lbw_diff(REFORM(new_posi[j,3L,0L,*]),REFORM(new_posi[j,3L,1L,*]),/NAN)
  dr_42_st       = lbw_diff(REFORM(new_posi[j,3L,0L,*]),REFORM(new_posi[j,3L,2L,*]),/NAN)
  dr_43_st       = lbw_diff(REFORM(new_posi[j,3L,0L,*]),REFORM(new_posi[j,3L,3L,*]),/NAN)
  dr_51_st       = lbw_diff(REFORM(new_posi[j,4L,0L,*]),REFORM(new_posi[j,3L,1L,*]),/NAN)
  dr_52_st       = lbw_diff(REFORM(new_posi[j,4L,0L,*]),REFORM(new_posi[j,3L,2L,*]),/NAN)
  dr_53_st       = lbw_diff(REFORM(new_posi[j,4L,0L,*]),REFORM(new_posi[j,3L,3L,*]),/NAN)
  ;;  ∆t_ij = t_i - t_j
  dt_12_st       = lbw_diff(REFORM(new_unix[j,0L,0L]),REFORM(new_unix[j,0L,1L]),/NAN)
  dt_13_st       = lbw_diff(REFORM(new_unix[j,0L,0L]),REFORM(new_unix[j,0L,2L]),/NAN)
  dt_14_st       = lbw_diff(REFORM(new_unix[j,0L,0L]),REFORM(new_unix[j,0L,3L]),/NAN)
  dt_21_st       = lbw_diff(REFORM(new_unix[j,1L,0L]),REFORM(new_unix[j,1L,1L]),/NAN)
  dt_23_st       = lbw_diff(REFORM(new_unix[j,1L,0L]),REFORM(new_unix[j,1L,2L]),/NAN)
  dt_24_st       = lbw_diff(REFORM(new_unix[j,1L,0L]),REFORM(new_unix[j,1L,3L]),/NAN)
  dt_31_st       = lbw_diff(REFORM(new_unix[j,2L,0L]),REFORM(new_unix[j,2L,1L]),/NAN)
  dt_32_st       = lbw_diff(REFORM(new_unix[j,2L,0L]),REFORM(new_unix[j,2L,2L]),/NAN)
  dt_34_st       = lbw_diff(REFORM(new_unix[j,2L,0L]),REFORM(new_unix[j,2L,3L]),/NAN)
  dt_41_st       = lbw_diff(REFORM(new_unix[j,3L,0L]),REFORM(new_unix[j,3L,1L]),/NAN)
  dt_42_st       = lbw_diff(REFORM(new_unix[j,3L,0L]),REFORM(new_unix[j,3L,2L]),/NAN)
  dt_43_st       = lbw_diff(REFORM(new_unix[j,3L,0L]),REFORM(new_unix[j,3L,3L]),/NAN)
  dt_51_st       = lbw_diff(REFORM(new_unix[j,4L,0L]),REFORM(new_unix[j,4L,1L]),/NAN)
  dt_52_st       = lbw_diff(REFORM(new_unix[j,4L,0L]),REFORM(new_unix[j,4L,2L]),/NAN)
  dt_53_st       = lbw_diff(REFORM(new_unix[j,4L,0L]),REFORM(new_unix[j,4L,3L]),/NAN)
  ;;  Define tensors
  dr_tens_st_1   = [[dr_12_st],[dr_13_st],[dr_14_st]]
  dt_tens_st_1   = [dt_12_st[0],dt_13_st[0],dt_14_st[0]]
  dr_tens_st_2   = [[dr_21_st],[dr_23_st],[dr_24_st]]
  dt_tens_st_2   = [dt_21_st[0],dt_23_st[0],dt_24_st[0]]
  dr_tens_st_3   = [[dr_31_st],[dr_32_st],[dr_34_st]]
  dt_tens_st_3   = [dt_31_st[0],dt_32_st[0],dt_34_st[0]]
  dr_tens_st_4   = [[dr_41_st],[dr_42_st],[dr_43_st]]
  dt_tens_st_4   = [dt_41_st[0],dt_42_st[0],dt_43_st[0]]
  dr_tens_st_5   = [[dr_51_st],[dr_52_st],[dr_53_st]]
  dt_tens_st_5   = [dt_51_st[0],dt_52_st[0],dt_53_st[0]]
  ;;--------------------------------------------------------------------------------------
  ;;  Find unit normal vector using LU decomposition
  ;;--------------------------------------------------------------------------------------
  ;;  Use LU decomposition
  ;;    A . X = B
  ;;      A_ijk = (∆r_ij)_k
  ;;      B_ijk = (T_i - T_j)_k
  mvec0          = REPLICATE(d,5L,3L)
  mmag0          = REPLICATE(d,5L)
  drmag          = REPLICATE(d,5L,3L,2L)
  dtmag          = drmag
  drmag[*,*,1]   = 1d0                       ;;  Assume 1 km position uncertainty
  dtmag[*,*,1]   = 50d-6                     ;;  Assume 50 µs timing uncertainty
  dr_tens_st_s   = {T1:dr_tens_st_1,T2:dr_tens_st_2,T3:dr_tens_st_3,T4:dr_tens_st_4,T5:dr_tens_st_5}
  dt_tens_st_s   = {T1:dt_tens_st_1,T2:dt_tens_st_2,T3:dt_tens_st_3,T4:dt_tens_st_4,T5:dt_tens_st_5}
  FOR k=0L, 4L DO BEGIN
    ;;  Reset variables
    IF (k[0] GT 0) THEN BEGIN
      dumb           = TEMPORARY(index)
      dumb           = TEMPORARY(stat)
      dumb           = TEMPORARY(bvec)
      dumb           = TEMPORARY(aludc)
    ENDIF
    aludc          = dr_tens_st_s.(k)
    drmag[k,*,0]   = mag__vec(dr_tens_st_s.(k),/NAN)
    dtmag[k,*,0]   = dt_tens_st_s.(k)
    bvec           = dt_tens_st_s.(k)
    LA_LUDC,aludc,index,/DOUBLE,STATUS=stat
    IF (stat[0] GT 0) THEN BEGIN
      MESSAGE,'LU decomposition failed!  Check input for colinearity or NaNs',/INFORMATIONAL,/CONTINUE
      ;;  Jump to next iteration
      CONTINUE
    ENDIF
    mvec0[k,*]     = LA_LUSOL(aludc,index,bvec,/DOUBLE)
    mmag0[k]       = (mag__vec(REFORM(mvec0[k,*]),/NAN))[0]
  ENDFOR
  ;;  (dVn/Vn)^2 = ∑ [(dr/r)^2 + (dt/t)^2]
  dv_v_sq        = TOTAL((drmag[*,*,1]/drmag[*,*,0])^2d0 + (dtmag[*,*,1]/dtmag[*,*,0])^2d0,2L,/NAN)
  umvc0          = REFORM(unit_vec(mvec0,/NAN))
  ;;  Define V_n in spacecraft frame and n [ICB]
  V_out__n[j,*,0]    = 1d0/mmag0                              ;;  speed [distance units per second]
  V_out__n[j,*,1]    = V_out__n[j,*,0]*SQRT(dv_v_sq)          ;;  uncertainty in " "
  n_icb_st[j,*,*,0]  = umvc0                                  ;;  shock normal vector [ICB]
  n_icb_st[j,*,*,1]  = 1d-1*ABS(umvc0)                        ;;  uncertainty in " "
;  mvecall[j,*,*] = REFORM(mvec0)
;  mmag           = MEAN(mmag0,/NAN)
;  dvno           = STDDEV(1d0/mmag0)
;  umvc           = MEAN(umvc0,/NAN,DIMENSION=1)
;  dumv           = STDDEV(umvc0,/NAN,DIMENSION=1)
;  V_out__n[j,0]    = 1d0/mmag[0]                              ;;  speed [distance units per second]
;  V_out__n[j,1]    = V_out__n[j,0]*SQRT(MEAN(dv_v_sq,/NAN))   ;;  uncertainty in " "
;  n_icb_st[j,*,0]  = umvc                                     ;;  shock normal vector [ICB]
;  n_icb_st[j,*,1]  = 1d-1*ABS(umvc)                           ;;  uncertainty in " "
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
;tags           = ['UNIX','SC_POSI','V_N_OUT','N_ICB_OUT','M_VEC_ALL']
;struc          = CREATE_STRUCT(tags,new_unix,new_posi,V_out__n,n_icb_st,mvecall)
tags           = ['UNIX','SC_POSI','V_N_OUT','N_ICB_OUT']
struc          = CREATE_STRUCT(tags,new_unix,new_posi,V_out__n,n_icb_st)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
IF ~KEYWORD_SET(nomssg) THEN MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

RETURN,struc[0]
END





