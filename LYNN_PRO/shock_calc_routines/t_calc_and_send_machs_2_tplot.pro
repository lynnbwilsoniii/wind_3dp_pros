;+
;*****************************************************************************************
;
;  PROCEDURE:   t_calc_and_send_machs_2_tplot.pro
;  PURPOSE  :   This routine calculates several relevant Mach numbers and sends the
;                 results to TPLOT for later use.  The speeds used can include,
;                 depending on inputs:
;                   - Alfvén speed
;                       V_A      = B_o/[ µ_o n_o M_i ]^(1/2)
;                   - ion-acoustic sound speed
;                       C_s      = [k_B (Z_i ¥_e T_e + ¥_i T_i)/(M_i + m_e)]^(1/2)
;                   - root mean square (thermal) speed
;                       V_Trms,j = [k_B T_j/M_j]^(1/2)
;                   - most probable (thermal) speed
;                       V_Tmps,j = [2 k_B T_j/M_j]^(1/2)
;                   - MHD slow mode speed
;                       V_s      = [(b^2 - [b^4 + c^2]^(1/2))/2]^(1/2)
;                   - MHD fast mode speed
;                       V_f      = [(b^2 + [b^4 + c^2]^(1/2))/2]^(1/2)
;                 where we have used the following definitions:
;                       µ_o      = permeability of free space
;                       M_i      = ion mass
;                       m_e      = electron mass
;                       k_B      = Boltzmann constant
;                       ¥_j      = adiabatic or polytrope index of species j
;                                    (where j = e or i)
;                       Z_i      = charge state of the ions
;                       n_o      = # density of plasma (assumes n_e = Z_i n_i)
;                       B_o      = magnitude of magnetic field
;                       T_j      = average temperature of species j
;                       b        = V_ms (i.e., MHD magnetosonic speed)
;                       V_ms     = [V_A^2 + C_s^2]^(1/2)
;                       c        = 2 V_A C_s Sin(ø)
;                       ø        = wave normal angle relative to direction of B_o
;                 Then to calculate the relevant Mach numbers, one has:
;                       M_j      = Un/V_j
;                 where j defines the relevant communication speed (e.g., Alfvén speed)
;                 and Un is the bulk flow speed along the shock normal vector.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               tnames.pro
;               test_tplot_handle.pro
;               is_a_number.pro
;               get_data.pro
;               tplot_struct_format_test.pro
;               t_resample_tplot_struc.pro
;               calc_relevant_speeds.pro
;               is_a_3_vector.pro
;               store_data.pro
;               options.pro
;
;  REQUIRES:    
;               1)  SPEDAS IDL libraries and UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TPN__UN   :  Scalar [string or integer] defining the TPLOT handle
;                              associated with the bulk flow speed [km/s] along
;                              the shock normal vector
;               TPN__NO   :  Scalar [string or integer] defining the TPLOT handle
;                              associated with the number density [cm^(-3)] to use
;               TPN__BO   :  Scalar [string or integer] defining the TPLOT handle
;                              associated with the magnetic field magnitude [nT] to use
;               **********************************
;               ***      OPTIONAL  INPUTS      ***
;               **********************************
;               LOG___T   :  Scalar [byte] defining to which variable's time stamps all
;                              others will be interpolated
;                                1  :  Use TPN__UN
;                                2  :  Use TPN__NO
;                                3  :  Use TPN__BO
;                                [Default = 3]
;
;  EXAMPLES:    
;               [calling sequence]
;               t_calc_and_send_machs_2_tplot, tpn__un, tpn__no, tpn__bo [,log___t]    $
;                                             [,TPN__TE=tpn__te] [,TPN__TI=tpn__ti]    $
;                                             [,TPN_THE=tpn_the] [,GAMM_E=gamm_e]      $
;                                             [,GAMM_I=gamm_i] [,Z_I=z_i] [,M_I=m_i]   $
;                                             [,TPN_VA_OUT=tpn_va_out]                 $
;                                             [,TPN_CS_OUT=tpn_cs_out]                 $
;                                             [,TPN_VM_OUT=tpn_vm_out]                 $
;                                             [,TPN_VS_OUT=tpn_vs_out]                 $
;                                             [,TPN_VF_OUT=tpn_vf_out]                 $
;                                             [,TPNVTE_OUT=tpnvte_out]                 $
;                                             [,TPNVTI_OUT=tpnvti_out]                 $
;                                             [,TPN_MA_OUT=tpn_ma_out]                 $
;                                             [,TPN_MC_OUT=tpn_mc_out]                 $
;                                             [,TPN_MM_OUT=tpn_mm_out]                 $
;                                             [,TPN_MS_OUT=tpn_ms_out]                 $
;                                             [,TPN_MF_OUT=tpn_mf_out]                 $
;                                             [,TPNACS_OUT=tpnacs_out]
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               TPN__TE     :  Scalar [string or integer] defining the TPLOT handle
;                                associated with the electron temperature [eV] to use
;                                [Default = not used]
;               TPN__TI     :  Scalar [string or integer] defining the TPLOT handle
;                                associated with the ion temperature [eV] to use
;                                [Default = not used]
;               TPN_THE     :  Scalar [string or integer] defining the TPLOT handle
;                                associated with the shock normal angle [deg]
;                                [Default = 90 degrees is used by subroutine]
;               GAMM_E      :  Scalar [numeric] defining the adiabatic or polytrope index
;                                of the electrons (i.e., ratio of specific heats)
;                                 [Default = GAMM_I if set, else = 1]
;               GAMM_I      :  Scalar [numeric] defining the adiabatic or polytrope index
;                                of the ions (i.e., ratio of specific heats)
;                                 [Default = 5/3]
;               Z_I         :  Scalar [numeric] defining the charge state of the ions
;                                (e.g., enter +2 for alpha-particles)
;                                 [Default = 1 (i.e., protons)]
;               M_I         :  Scalar [numeric] defining the ion mass [with units kg]
;                                 [Default = M_p (i.e., proton mass)]
;               *******************************************
;               ***      INDIRECT OUTPUTS:  Speeds      ***
;               *******************************************
;               TPN_VA_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the Alfvén speed to TPLOT
;                                [Default = not sent to TPLOT]
;               TPN_CS_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the ion-acoustic sound speed
;                                to TPLOT
;                                [Default = not sent to TPLOT]
;               TPN_VM_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the MHD magnetosonic speed
;                                to TPLOT
;                                [Default = not sent to TPLOT]
;               TPN_VS_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the MHD slow mode speed to TPLOT
;                                [Default = not sent to TPLOT]
;               TPN_VF_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the MHD fast mode speed to TPLOT
;                                [Default = not sent to TPLOT]
;               TPNVTE_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the RMS and MPS electron thermal
;                                speeds to TPLOT
;                                [Default = not sent to TPLOT]
;               TPNVTI_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the RMS and MPS ion thermal
;                                speeds to TPLOT
;                                [Default = not sent to TPLOT]
;               *********************************************
;               ***      INDIRECT OUTPUTS:  Mach #'s      ***
;               *********************************************
;               TPN_MA_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the Alfvén Mach # to TPLOT
;                                [Default = not sent to TPLOT]
;               TPN_MC_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the ion-acoustic sound Mach #
;                                to TPLOT
;                                [Default = not sent to TPLOT]
;               TPN_MM_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the MHD magnetosonic Mach #
;                                to TPLOT
;                                [Default = not sent to TPLOT]
;               TPN_MS_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the MHD slow mode Mach # to TPLOT
;                                [Default = not sent to TPLOT]
;               TPN_MF_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to send the MHD fast mode Mach # to TPLOT
;                                [Default = not sent to TPLOT]
;               TPNACS_OUT  :  Scalar [string] defining the TPLOT handle to use if the
;                                user decides to combine the Alfvén, ion-acoustic sound,
;                                and the MHD fast mode Mach #'s into one TPLOT handle
;                                [Default = not sent to TPLOT]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [01/15/2016   v1.0.0]
;             2)  Fixed typo in calculation for TPNACS_OUT output
;                                                                   [01/28/2016   v1.0.1]
;             3)  Added new keyword to avoid intervals for t_resample_tplot_struc.pro
;                                                                   [08/10/2018   v1.0.2]
;
;   NOTES:      
;               0)  ***  Still needs more testing  ***
;
;               1)  If the Z_I is set to a value not equal to +1, then the M_I keyword
;                     MUST be set to the corresponding ion mass
;               2)  Rules for TEMP_E and TEMP_I keywords:
;                     A)  TEMP_E = TRUE,  TEMP_I = FALSE  -->  ignore Ti in C_s calculation
;                     B)  TEMP_E = FALSE, TEMP_I = TRUE   -->  ignore Te in C_s calculation
;                     C)  TEMP_E = FALSE, TEMP_I = FALSE  -->  Ignore all T-dependent speeds
;                     D)  TEMP_E = TRUE,  TEMP_I = TRUE   -->  Proceed normally
;               3)  Rules for V_TRMS_OUT and V_TMPS_OUT keywords:
;                     V_T{RMS,MPS}_OUT[*,0] = electron thermal speeds
;                     V_T{RMS,MPS}_OUT[*,1] = ion thermal speeds
;
;  REFERENCES:  
;               0)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;               1)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, T.L. Aggson,
;                      R.R. Anderson, J.T. Gosling, G. Paschmann, and C.T. Russell
;                      (1986a) "The Resolved Layer of a Collisionless, High ß,
;                      Supercritical, Quasi-Perpendicular Shock Wave 1:
;                      Rankine-Hugoniot Geometry, Currents, and Stationarity,"
;                      J. Geophys. Res. Vol. 91, pp. 11,019-11,052.
;               2)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, T.L. Aggson
;                      (1986b) "The Resolved Layer of a Collisionless, High ß,
;                      Supercritical, Quasi-Perpendicular Shock Wave 2:
;                      Dissipative Fluid Electrodynamics," J. Geophys. Res. Vol. 91,
;                      pp. 11,053-11,073.
;               3)  Scudder, J.D., A. Mangeney, C. Lacombe, C.C. Harvey, C.S. Wu,
;                      R.R. Anderson (1986c) "The Resolved Layer of a Collisionless,
;                      High ß, Supercritical, Quasi-Perpendicular Shock Wave 3:
;                      Vlasov Electrodynamics," J. Geophys. Res. Vol. 91,
;                      pp. 11,075-11,097.
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst., (1998).
;               5)  Viñas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               6)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               7)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;               8)  Russell, C.T., J.T. Gosling, R.D. Zwickl, and E.J. Smith (1983),
;                      "Multiple spacecraft observations of interplanetary shocks:  ISEE
;                      Three-Dimensional Plasma Measurements," J. Geophys. Res. 88,
;                      pp. 9941-9947.
;               9)  Stix, T.H. (1962), "The Theory of Plasma Waves,"
;                      McGraw-Hill Book Company, USA.
;
;   CREATED:  01/14/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2018   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO t_calc_and_send_machs_2_tplot,tpn__un,tpn__no,tpn__bo,log___t,TPN__TE=tpn__te,     $
                                  TPN__TI=tpn__ti,TPN_THE=tpn_the,GAMM_E=gamm_e,       $
                                  GAMM_I=gamm_i,Z_I=z_i,M_I=m_i,                       $
                                  TPN_VA_OUT=tpn_va_out,TPN_CS_OUT=tpn_cs_out,         $
                                  TPN_VM_OUT=tpn_vm_out,TPN_VS_OUT=tpn_vs_out,         $
                                  TPN_VF_OUT=tpn_vf_out,TPNVTE_OUT=tpnvte_out,         $
                                  TPNVTI_OUT=tpnvti_out,                               $
                                  TPN_MA_OUT=tpn_ma_out,TPN_MC_OUT=tpn_mc_out,         $
                                  TPN_MM_OUT=tpn_mm_out,TPN_MS_OUT=tpn_ms_out,         $
                                  TPN_MF_OUT=tpn_mf_out,TPNACS_OUT=tpnacs_out

;;  Let IDL know that the following are functions
FORWARD_FUNCTION tnames, test_tplot_handle, is_a_number, tplot_struct_format_test,     $
                 t_resample_tplot_struc, is_a_3_vector
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  TPLOT dummy variables
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters for TPLOT
vec_col        = [250,150,50]
vec_str        = ['x','y','z']
vs__labs       = ['Value','Smoothed']
vs__cols       = vec_col[[2,0]]
rms_mps_labs   = ['rms','mps']
check_t        = [(SIZE(tpn_va_out,/TYPE) EQ 7),(SIZE(tpn_cs_out,/TYPE) EQ 7),$
                  (SIZE(tpn_vm_out,/TYPE) EQ 7),(SIZE(tpn_vs_out,/TYPE) EQ 7),$
                  (SIZE(tpn_vf_out,/TYPE) EQ 7),(SIZE(tpnvte_out,/TYPE) EQ 7),$
                  (SIZE(tpnvti_out,/TYPE) EQ 7),                              $
                  (SIZE(tpn_ma_out,/TYPE) EQ 7),(SIZE(tpn_mc_out,/TYPE) EQ 7),$
                  (SIZE(tpn_mm_out,/TYPE) EQ 7),(SIZE(tpn_ms_out,/TYPE) EQ 7),$
                  (SIZE(tpn_mf_out,/TYPE) EQ 7),(SIZE(tpnacs_out,/TYPE) EQ 7) ]
n_ct           = N_ELEMENTS(check_t)
tags           = 'T'+STRTRIM(STRING(LINDGEN(n_ct),FORMAT='(I)'),2L)
Spd_labs       = ['V_A','C_s','V_ms','V_s','V_f','V_Te','V_Ti']
Spd_yttl       = Spd_labs+' [km/s]'
Mch_yttl       = ['Alfvenic','Sound','Magnetosonic','Slow Mode','Fast Mode']
Mnacyttl       = 'Mach #s'
Mch_labs       = ['M_A','M_cs','M_ms','M_s','M_f']
Mch_ysub       = 'Mach #'
Mnacysub       = '[M_A, M_cs, and M_f]'
;;  Define structures for indexing later
all_labs       = CREATE_STRUCT(tags,'V_A','C_s','V_ms','V_s','V_f',                   $
                               'V_Te_'+rms_mps_labs,'V_Ti_'+rms_mps_labs,             $
                               'M_A','M_cs','M_ms','M_s','M_f',Mch_labs[[0,1,4]])
all_cols       = CREATE_STRUCT(tags,vec_col[2],vec_col[2],vec_col[2],vec_col[2],      $
                               vec_col[2],vs__cols,vs__cols,vec_col[2],vec_col[2],    $
                               vec_col[2],vec_col[2],vec_col[2],vec_col)
all_yttl       = CREATE_STRUCT(tags,Spd_yttl[0],Spd_yttl[1],Spd_yttl[2],Spd_yttl[3],  $
                               Spd_yttl[4],Spd_yttl[5],Spd_yttl[6],Mch_yttl[0],       $
                               Mch_yttl[1],Mch_yttl[2],Mch_yttl[3],Mch_yttl[4],       $
                               Mnacyttl[0])
all_ysub       = CREATE_STRUCT(tags,'','','','','','','',Mch_ysub[0],Mch_ysub[0],     $
                               Mch_ysub[0],Mch_ysub[0],Mch_ysub[0],Mnacysub[0])
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
;;----------------------------------------------------------------------------------------
;;  Error messages
;;----------------------------------------------------------------------------------------
noinput_mssg   = 'Incorrect number of inputs were supplied...'
no_tplot       = 'User must first load some data into TPLOT before calling this routine!'
bad_tpn_msg    = 'Incorrect input:  TPN__UN, TPN__NO, and TPN__BO must ALL be valid and existing TPLOT handles...'
badtstr_msg    = 'Incorrect input:  TPN__UN, TPN__NO, and TPN__BO must ALL be associated with valid TPLOT structures...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 3)
IF (test) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check to see if TPLOT has been started
test           = ((tnames())[0] EQ '')
IF (test[0]) THEN BEGIN
  ;;  No TPLOT handles loaded yet --> quit
  MESSAGE,no_tplot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check TPLOT handles
test_un        = test_tplot_handle(tpn__un,TPNMS=un__tpn)
test_no        = test_tplot_handle(tpn__no,TPNMS=no__tpn)
test_bo        = test_tplot_handle(tpn__bo,TPNMS=bo__tpn)
test           = (test_un[0] EQ 0) OR (test_no[0] EQ 0) OR (test_bo[0] EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Not valid TPLOT handles --> Return to user
  MESSAGE,bad_tpn_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check LOG___T
test           = (N_ELEMENTS(log___t) LT 1) OR (is_a_number(log___t,/NOM) EQ 0)
IF (test[0]) THEN logic = 3b ELSE logic = BYTE(log___t[0])
;;----------------------------------------------------------------------------------------
;;  Get minimum necessary data
;;----------------------------------------------------------------------------------------
get_data,un__tpn[0],DATA=temp_un,DLIM=dlim_un,LIM=lim_un
get_data,no__tpn[0],DATA=temp_no,DLIM=dlim_no,LIM=lim_no
get_data,bo__tpn[0],DATA=temp_bo,DLIM=dlim_bo,LIM=lim_bo
;;  Test result
test_un        = tplot_struct_format_test(temp_un,YNDIM=1,/NOMSSG)
test_no        = tplot_struct_format_test(temp_no,YNDIM=1,/NOMSSG)
test_bo        = tplot_struct_format_test(temp_bo,YNDIM=1,/NOMSSG)
test           = (test_un[0] EQ 0) OR (test_no[0] EQ 0) OR (test_bo[0] EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Not valid TPLOT structures --> Return to user
  MESSAGE,badtstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Good --> Define parameters
bmag_t         = temp_bo.X
dens_t         = temp_no.X
Ushn_t         = temp_un.X
;;  Determine to which time stamp all others will be interpolated
CASE logic[0] OF
  1     :  new__t = Ushn_t
  2     :  new__t = dens_t
  3     :  new__t = bmag_t
  ELSE  :  new__t = bmag_t  ;;  This should not happen, but use default anyways
ENDCASE
;;  Interpolate parameters to new times
temp_un2       = t_resample_tplot_struc(temp_un,new__t,/NO_EXTRAPOLATE,/IGNORE_INT)
temp_no2       = t_resample_tplot_struc(temp_no,new__t,/NO_EXTRAPOLATE,/IGNORE_INT)
temp_bo2       = t_resample_tplot_struc(temp_bo,new__t,/NO_EXTRAPOLATE,/IGNORE_INT)
test           = (SIZE(temp_un2,/TYPE) NE 8) OR (SIZE(temp_no2,/TYPE) NE 8) OR (SIZE(temp_bo2,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  ;;  Something failed --> Return to user
  MESSAGE,'Interpolation to new time stamps failed --> Returning...',/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Define newly interpolated parameters
bmag_v         = ABS(temp_bo2.Y)
dens_v         = ABS(temp_no2.Y)
Ushn_v         = ABS(temp_un2.Y)
nn             = N_ELEMENTS(bmag_v)
;;----------------------------------------------------------------------------------------
;;  Check input keywords
;;----------------------------------------------------------------------------------------
;;  Check TPN__TE
test_te        = test_tplot_handle(tpn__te,TPNMS=te__tpn)
IF (test_te[0]) THEN BEGIN
  ;;  TPLOT handle found  -->  Check TPLOT structure
  get_data,te__tpn[0],DATA=temp_te,DLIM=dlim_te,LIM=lim_te
  test_te        = tplot_struct_format_test(temp_te,YNDIM=1,/NOMSSG)
  IF (test_te[0]) THEN BEGIN
    ;;  Good  -->  Interpolate parameters to new times
    temp_te2       = t_resample_tplot_struc(temp_te,new__t,/NO_EXTRAPOLATE,/IGNORE_INT)
    ;;  Define newly interpolated parameters
    IF (SIZE(temp_te2,/TYPE) EQ 8) THEN te___v = ABS(temp_te2.Y)
  ENDIF
ENDIF
;;  Check TPN__TI
test_ti        = test_tplot_handle(tpn__ti,TPNMS=ti__tpn)
IF (test_ti[0]) THEN BEGIN
  ;;  TPLOT handle found  -->  Check TPLOT structure
  get_data,ti__tpn[0],DATA=temp_ti,DLIM=dlim_ti,LIM=lim_ti
  test_ti        = tplot_struct_format_test(temp_ti,YNDIM=1,/NOMSSG)
  IF (test_ti[0]) THEN BEGIN
    ;;  Good  -->  Interpolate parameters to new times
    temp_ti2       = t_resample_tplot_struc(temp_ti,new__t,/NO_EXTRAPOLATE,/IGNORE_INT)
    ;;  Define newly interpolated parameters
    IF (SIZE(temp_ti2,/TYPE) EQ 8) THEN ti___v = ABS(temp_ti2.Y)
  ENDIF
ENDIF
;;  Check TPN_THE
test_th        = test_tplot_handle(tpn_the,TPNMS=the_tpn)
IF (test_th[0]) THEN BEGIN
  ;;  TPLOT handle found  -->  Check TPLOT structure
  get_data,the_tpn[0],DATA=temp_th,DLIM=dlim_th,LIM=lim_th
  test_th        = tplot_struct_format_test(temp_th,YNDIM=1,/NOMSSG)
  IF (test_th[0]) THEN BEGIN
    ;;  Good  -->  Interpolate parameters to new times
    temp_th2       = t_resample_tplot_struc(temp_th,new__t,/NO_EXTRAPOLATE,/IGNORE_INT)
    ;;  Define newly interpolated parameters
    IF (SIZE(temp_th2,/TYPE) EQ 8) THEN the__v = temp_th2.Y
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check output keywords
;;----------------------------------------------------------------------------------------
check_v        = BYTARR(n_ct)
tpn_out        = STRARR(n_ct)
FOR j=0L, n_ct[0] - 1L DO BEGIN
  CASE j[0] OF
     0L  :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpn_va_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpn_va_out[0]
       ENDIF
     END
     1L  :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpn_cs_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpn_cs_out[0]
       ENDIF
     END
     2L  :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpn_vm_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpn_vm_out[0]
       ENDIF
     END
     3L  :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpn_vs_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpn_vs_out[0]
       ENDIF
     END
     4L  :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpn_vf_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpn_vf_out[0]
       ENDIF
     END
     5L  :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpnvte_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpnvte_out[0]
       ENDIF
     END
     6L  :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpnvti_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpnvti_out[0]
       ENDIF
     END
     7L  :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpn_ma_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpn_ma_out[0]
       ENDIF
     END
     8L  :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpn_mc_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpn_mc_out[0]
       ENDIF
     END
     9L  :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpn_mm_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpn_mm_out[0]
       ENDIF
     END
     10L :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpn_ms_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpn_ms_out[0]
       ENDIF
     END
     11L :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpn_mf_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpn_mf_out[0]
       ENDIF
     END
     12L :  BEGIN
       IF (check_t[j]) THEN BEGIN
         check_v[j] = (IDL_VALIDNAME(tpnacs_out) NE '')
         IF (check_v[j]) THEN tpn_out[j] = tpnacs_out[0]
       ENDIF
     END
  ENDCASE
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate relevant speeds
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
calc_relevant_speeds,dens_v,bmag_v,TEMP_E=te___v,TEMP_I=ti___v,GAMM_E=gamm_e,         $
                                   GAMM_I=gamm_i,Z_I=z_i,M_I=m_i,THETA=the__v,        $
                                   V_A_OUT=v_a,C_S_OUT=c_s,V_S_OUT=v_s,V_F_OUT=v_f,   $
                                   V_MS_OUT=v_ms,V_TRMS_OUT=v_trms,V_TMPS_OUT=v_tmps
;;----------------------------------------------------------------------------------------
;;  Define outputs
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(v_a)  NE nn[0]) THEN v_a  = 0
IF (N_ELEMENTS(c_s)  NE nn[0]) THEN c_s  = 0
IF (N_ELEMENTS(v_s)  NE nn[0]) THEN v_s  = 0
IF (N_ELEMENTS(v_f)  NE nn[0]) THEN v_f  = 0
IF (N_ELEMENTS(v_ms) NE nn[0]) THEN v_ms = 0
test           = (N_ELEMENTS(v_trms) NE 2*nn[0]) OR (SIZE(v_trms,/N_DIMENSIONS) NE 2)
IF (test[0]) THEN BEGIN
  v_te_rms = 0
  v_ti_rms = 0
ENDIF ELSE BEGIN
  v_te_rms = v_trms[*,0]
  v_ti_rms = v_trms[*,1]
ENDELSE
test           = (N_ELEMENTS(v_tmps) NE 2*nn[0]) OR (SIZE(v_tmps,/N_DIMENSIONS) NE 2)
IF (test[0]) THEN BEGIN
  v_te_mps = 0
  v_ti_mps = 0
ENDIF ELSE BEGIN
  v_te_mps = v_tmps[*,0]
  v_ti_mps = v_tmps[*,1]
ENDELSE
;;  Define thermal speeds
v_te           = [[v_te_rms],[v_te_mps]]
v_ti           = [[v_ti_rms],[v_ti_mps]]
;;  Define Mach #'s
M__a           = Ushn_v/v_a
M_cs           = Ushn_v/c_s
M_ms           = Ushn_v/v_ms
M__s           = Ushn_v/v_s
M__f           = Ushn_v/v_f
;Machs          = [[M__a],[M__s],[M__f]]
;;  LBW III  01/28/2016   v1.0.1
Machs          = [[M__a],[M_cs],[M__f]]
;;  Define indexing structure
all_data       = CREATE_STRUCT(tags,v_a,c_s,v_ms,v_s,v_f,v_te,v_ti,$
                                    M__a,M_cs,M_ms,M__s,M__f,Machs)
;;----------------------------------------------------------------------------------------
;;  Send results to TPLOT, if user desires
;;----------------------------------------------------------------------------------------
FOR j=0L, n_ct[0] - 1L DO BEGIN
  data    = all_data.(j)
  sznd    = SIZE(data,/N_DIMENSIONS)
  testn   = (sznd[0] EQ 1)
  IF (testn[0]) THEN BEGIN
    ;;  1D array
    testd  = (N_ELEMENTS(data) EQ nn[0])
  ENDIF ELSE BEGIN
    ;;  2D array
    test3v = is_a_3_vector(data,V_OUT=data2,/NOM)
    IF (test3v[0]) THEN n2 = 3*nn[0] ELSE n2 = 2*nn[0]
    testd  = (N_ELEMENTS(data2) EQ n2[0])
  ENDELSE
;  IF (testn[0]) THEN testd = (N_ELEMENTS(data) EQ nn[0]) ELSE testd = (N_ELEMENTS(data) GE 2*nn[0])
  testv   = check_v[j] AND (tpn_out[j] NE '')
  test    = testv[0] AND testd[0]
  IF (test[0] EQ 0) THEN CONTINUE        ;;  Skip to next iteration...
  ;;  Good  -->  Send to TPLOT
  struc   = {X:new__t,Y:data}
  store_data,tpn_out[j],DATA=struc,LIMIT=def__lim
  options,tpn_out[j],YTITLE=all_yttl.(j),YSUBTITLE=all_ysub.(j),COLORS=all_cols.(j),$
                     LABELS=all_labs.(j),/DEF
  IF (j[0] GE 7L) THEN options,tpn_out[j],YGRIDSTYLE=2,YTICKLEN=1e0
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

