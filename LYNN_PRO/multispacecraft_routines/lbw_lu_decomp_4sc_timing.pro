;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_lu_decomp_4sc_timing.pro
;  PURPOSE  :   This is a simple wrapper for the LU decomposition routines in IDL to be
;                 used on the relative positions and times of 4 spacecraft to determine
;                 a velocity on output.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               mag__vec.pro
;               unit_vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DR_STRUC  :  Scalar [structure] containing [N]-tags each having a tensor
;                              of relative positions [km] between two spacecraft with
;                              [3,3]-elements (i.e., DR_STRUC.(0)[*,0] is all x-components)
;               DT_STRUC  :  Scalar [structure] containing [N]-tags each having a tensor
;                              of relative times [seconds] between each spacecraft pair
;                              with [3]-elements
;
;  EXAMPLES:    
;               [calling sequence]
;               struc = lbw_lu_decomp_4sc_timing(dr_struc,dt_struc [,DEL_R=del_r] [,DEL_T=del_t] [,/NOMSSG])
;
;  KEYWORDS:    
;               DEL_R     :  Scalar [numeric] uncertainty to use for positions in DR_STRUC
;                              [Default = 1d0 (i.e., 1 km)]
;               DEL_T     :  Scalar [numeric] uncertainty to use for times in DT_STRUC
;                              [Default = 1d-6 (i.e., 1 microsecond)]
;               NOMSSG    :  If set, routine will not inform user of elapsed computational
;                              time [s]
;                              [Default = FALSE]
;
;   CHANGED:  1)  Fixed a bug where I forgot to define ALUDC array
;                                                                   [10/08/2020   v1.0.1]
;             2)  Realized this routine is actually calculating group velocity, so major
;                   changes to fix this issue
;                                                                   [10/16/2020   v2.0.0]
;             3)  Fixed a bug
;                                                                   [10/17/2020   v2.0.1]
;             4)  Not sure why I initially required DR_STRUC and DT_STRUC to have at
;                   minimum 3 tags but this seems odd since each decomposition is
;                   independent of the others --> now only requires 1
;                                                                   [10/27/2022   v2.0.2]
;
;   NOTES:      
;               0)  Please limit number of structure tags to < 50 and ≥3
;               1)  This routine uses LU decomposition
;                     A . X = B
;                       A_ijm = (∆r_ij)_m
;                       B_ijm = (t_i - t_j)_m
;                       X     = (g/|g|)/V_gr,sc
;               2)  ∆r . k = V_gr,sc ∆t
;                       V_gr,sc         = 1/|X|
;                       (g/|g|)         = X/|X|
;                       V_gr,sc (g/|g|) = V_gr (g/|g|) + (g/|g|) . Vsw
;                       V_gr (g/|g|)    = V_gr,sc (g/|g|) - [(g/|g|) . Vsw]
;               3)  ICB  =  Input Coordinate Basis
;               4)  Coordinate Systems
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
;                     https://www.harrisgeospatial.com/docs/C_CORRELATE.html
;               1)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;
;   CREATED:  10/07/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/27/2022   v2.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_lu_decomp_4sc_timing,dr_struc,dt_struc,DEL_R=del_r,DEL_T=del_t,NOMSSG=nomssg

ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
del            = [-1d0,-5d-1,0d0,5d-1,1d0]
nd             = N_ELEMENTS(del)
;;  Error messages
noinput_mssg   = 'No input was supplied...'
badmtch_mssg   = 'Incorrect input format was supplied:  DR_STRUC and DT_STRUC must both be structures with [N]-tags'
badindr_mssg   = 'Incorrect input format was supplied:  All tags within DR_STRUC must be [3,3]-element [numeric] arrays'
badindt_mssg   = 'Incorrect input format was supplied:  All tags within DT_STRUC must be [3]-element [numeric] arrays'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2 OR SIZE(dr_struc,/TYPE) NE 8 OR SIZE(dt_struc,/TYPE) NE 8) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
ntr            = N_TAGS(dr_struc)
ntt            = N_TAGS(dt_struc)
IF (ntr[0] NE ntt[0] OR ntr[0] GT 50L OR ntr[0] LT 1L) THEN BEGIN
  MESSAGE,badmtch_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
nt             = ntr[0]
test           = 0b
FOR j=0L, nt[0] - 1L DO test += (N_ELEMENTS(dr_struc.(j[0])) NE 9L)
IF (test[0] GT 0) THEN BEGIN
  MESSAGE,badindr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = 0b
FOR j=0L, nt[0] - 1L DO test += (N_ELEMENTS(dt_struc.(j[0])) NE 3L)
IF (test[0] GT 0) THEN BEGIN
  MESSAGE,badindt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DEL_R
IF (is_a_number(del_r,/NOMSSG)) THEN dr = ABS(1d0*del_r[0]) ELSE dr = 1d0
;;  Check DEL_T
IF (is_a_number(del_t,/NOMSSG)) THEN dt = ABS(1d0*del_t[0]) ELSE dt = 1d-6
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Decompose tensors
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  - Use LU decomposition to find (i.e., t_4sc_normal_calc.pro)
;;      A . X = B
;;        A_ijm = (∆r_ij)_m
;;        B_ijm = (t_i - t_j)_m
;;        X     = (g/|g|)/V_gr,sc
;;  - V_gr,sc = 1/|X| and (g/|g|) = X/|X|
drmag          = REPLICATE(d,nt[0],3L,2L)
mvec0          = drmag[*,*,0L]
mmag0          = drmag[*,0L,0L]
dtmag          = drmag
drmag[*,*,1]   = dr[0]                       ;;  Assume DEL_R position uncertainty
dtmag[*,*,1]   = dt[0]                       ;;  Assume DEL_T timing uncertainty
FOR k=0L, nt[0] - 1L DO BEGIN
  ;;  Reset variables
  IF (k[0] GT 0) THEN BEGIN
    dumb           = TEMPORARY(index)
    dumb           = TEMPORARY(stat)
    dumb           = TEMPORARY(bvec)
    dumb           = TEMPORARY(aludc)
  ENDIF
  drten          = dr_struc.(k[0])
  dtten          = dt_struc.(k[0])
  drmag[k,*,0]   = mag__vec(drten,/NAN)
  dtmag[k,*,0]   = dtten
  aludc          = drten
  bvec           = dtten
  LA_LUDC,aludc,index,/DOUBLE,STATUS=stat
  IF (stat[0] GT 0) THEN BEGIN
    MESSAGE,'LU decomposition failed!  Check input for colinearity or NaNs',/INFORMATIONAL,/CONTINUE
    ;;  Jump to next iteration
    CONTINUE
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Success --> Find LU solutions
  ;;--------------------------------------------------------------------------------------
  ;;  Define slowness 3-vector
  mvec0[k,*]     = LA_LUSOL(aludc,index,bvec,/DOUBLE)
  ;;  Define slowness 3-vector magnitude
  mmag0[k]       = (mag__vec(REFORM(mvec0[k,*]),/NAN))[0]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define group speed, velocity, and group velocity unit vector
;;----------------------------------------------------------------------------------------
Vgrv_scf       = REPLICATE(d,nt[0],3L,2L)
Vgrs_scf       = REPLICATE(d,nt[0],2L)
ghat_scf       = Vgrv_scf
;;  (dVn/Vn)^2 = ∑ [(dr/r)^2 + (dt/t)^2]
dv_v_sq        = TOTAL((drmag[*,*,1]/drmag[*,*,0])^2d0 + (dtmag[*,*,1]/dtmag[*,*,0])^2d0,2L,/NAN)
umvc0          = REFORM(unit_vec(mvec0,/NAN))
;;  Define V_gr [km/s]
Vgrs_scf[*,0L]   = ABS(1d0/mmag0)
Vgrs_scf[*,1L]   = Vgrs_scf[*,0L]*SQRT(dv_v_sq)
;;  Define g [ICB]
ghat_scf[*,*,0L] = umvc0
dumbv            = REPLICATE(d,nt[0],nd[0],3L)
dumbg            = dumbv
FOR k=0L, nd[0] - 1L DO BEGIN
  v1d            = (Vgrs_scf[*,0L] + del[k]*Vgrs_scf[*,1L])
  v2d            = v1d # REPLICATE(1d0,3L)
  guv            = REFORM(ghat_scf[*,*,0L])
  dumbv[*,k,*]   = guv*v2d
ENDFOR
Vgrv_scf[*,*,0]  = MEDIAN(dumbv,DIMENSION=2)
Vgrv_scf[*,*,1]  = STDDEV(dumbv,DIMENSION=2,/NAN)
;;  Calculate ∂g
FOR k=0L, nd[0] - 1L DO BEGIN
  v2d            = Vgrv_scf[*,*,0] + del[k]*Vgrv_scf[*,*,1]
  guv            = REFORM(unit_vec(v2d,/NAN))
  dumbg[*,k,*]   = guv
ENDFOR
ghat_scf[*,*,1L] = STDDEV(dumbg,DIMENSION=2,/NAN)
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
tags           = ['VGR_SC_SPD','VGR_SC_VEC','GHAT_ICB']
struc          = CREATE_STRUCT(tags,Vgrs_scf,Vgrv_scf,ghat_scf)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
ex_time        = SYSTIME(1) - ex_start[0]
IF ~KEYWORD_SET(nomssg) THEN MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL

RETURN,struc[0]
END

















