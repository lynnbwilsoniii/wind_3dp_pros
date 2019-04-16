;+
;*****************************************************************************************
;
;  FUNCTION :   remove_uv_and_beam_ions.pro
;  PURPOSE  :   This routine attempts to create a mask to remove "contamination" due
;                 to ion beams and/or UV light in a spherical top-hat electrostatic
;                 ion analyzer [e.g. THEMIS IESA].  The routine does so through the
;                 following steps:
;                   1)  Convert into Solar Wind (SW) rest frame
;                   2)  Create mask for data to remove values > V_thresh, where
;                         V_thresh can come from, e.g. the specular reflection ion
;                         gyrospeed estimate
;                   3)  Kill data within ±15 deg of sun direction below V_uv, where
;                         V_uv ~ 500-750 km/s [in SW frame]
;                   4)  Find remaining finite data bins to create a new mask
;                   5)  Return new mask to user
;                   6)  User can use new mask to keep only the desired bins when
;                         calculating new ion moments that are not contaminated by
;                         ion beams [e.g. gyrating ions] or UV-light-driven effects
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               cart_to_sphere.pro
;               test_wind_vs_themis_esa_struct.pro
;               is_a_number.pro
;               dat_3dp_str_names.pro
;               convert_ph_units.pro
;               conv_units.pro
;               struct_value.pro
;               is_a_3_vector.pro
;               transform_vframe_3d_array.pro
;               energy_to_vel.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT       :  [N]-Element array of data structures associated with
;                              THEMIS IESA Burst [see get_th?_peib.pro, ? = a-f] or
;                              Wind/3DP PESA High Burst [see get_phb.pro]
;
;  EXAMPLES:    
;               [calling sequence]
;               mask_ind = remove_uv_and_beam_ions(dat [,V_THRESH=v_thresh] [,V_UV=v_uv] $
;                                                  [,THE_THR=the_thr] [,PHI_THR=phi_thr] )
;
;  KEYWORDS:    
;               V_THRESH  :  Scalar [numeric] defining the largest velocity [km/s] to
;                              use for the "core" of the distribution in the bulk flow
;                              rest frame
;                              [Default = 500 km/s]
;               V_UV      :  Scalar [numeric] defining the largest velocity [km/s] for
;                              the observed UV "contamination" => Plot first!
;                              [Default = 500 km/s]
;               THE_THR   :  Scalar [numeric] defining the largest poloidal angle [deg]
;                              away from the sun direction to remove from the data
;                              [Default = 15 deg]
;               PHI_THR   :  Scalar [numeric] defining the largest azimthal angle [deg]
;                              away from the sun direction to remove from the data
;                              [Default = 15 deg]
;
;   CHANGED:  1)  Updated the Man. page and now calls
;                   transform_vframe_3d_array.pro, is_a_number.pro, convert_ph_units.pro,
;                   dat_3dp_str_names.pro, struct_value.pro, is_a_3_vector.pro, and
;                   transform_vframe_3d_array.pro
;                                                                   [04/03/2018   v1.1.0]
;
;   NOTES:      
;               1)  MUST use my version of conv_units.pro as it allows for arrays of
;                     data structures
;               2)  If DAT are from THEMIS IESA, then this routine assumes that they
;                     have already been modified prior to calling by:
;                     modify_themis_esa_struc.pro
;                     rotate_esa_thetaphi_to_gse.pro
;                         --> GSE coordinates
;                     [technically not necessary if all else is consistent]
;               3)  To only mask core and ignore UV contributions, set V_UV=0e0
;
;  REFERENCES:  
;               0)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 1. Analysis Techniques and Methodology,"
;                      J. Geophys. Res. 119(8), pp. 6455--6474, 2014a.
;               1)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 2. Waves and Dissipation,"
;                      J. Geophys. Res. 119(8), pp. 6475--6495, 2014b.
;
;   CREATED:  08/09/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/03/2018   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION remove_uv_and_beam_ions,dat,V_THRESH=v_thresh,V_UV=v_uv,$
                                 THE_THR=the_thr,PHI_THR=phi_thr

;*****************************************************************************************
ex_start       = SYSTIME(1)
;*****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
sunv           = [1d0,0d0,0d0]  ;;  Sun direction in GSE coordinates
def_uconv_r_th = ['thm_convert_esa_units_lbwiii','thm_convert_sst_units_lbwiii']
;;  convert sun direction to polar angles
;;       [theta,phi] = [0,0]  {should be this result}
cart_to_sphere,1d0,0d0,0d0,rs,the_s,phi_s,PH_0_360=1

;;  Dummy error messages
notstr_mssg    = 'Must be an IDL structure...'
nostate_mssg   = 'No State data available for date and probe...'
nomagf_mssg    = 'No FGM data available for date and probe...'
notvdf_msg     = 'Must be an ion velocity distribution IDL structure...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() EQ 0) THEN RETURN,0b
str            = dat[0]   ;;  in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test0          = test_wind_vs_themis_esa_struct(str,/NOM)
test           = (test0.(0) + test0.(1)) NE 1
IF (test[0]) THEN BEGIN
  MESSAGE,notvdf_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check V_THRESH
IF (is_a_number(v_thresh,/NOMSSG) EQ 0) THEN v_thresh = 50e1 ELSE v_thresh = ABS(v_thresh[0])
;;  Check V_UV
IF (is_a_number(v_uv,/NOMSSG)     EQ 0) THEN v_uv     = 50e1 ELSE v_uv     = ABS(v_uv[0])
;;  Check THE_THR
IF (is_a_number(the_thr,/NOMSSG)  EQ 0) THEN the_thr  = 15e0 ELSE the_thr  = ABS(the_thr[0])
;;  Check PHI_THR
IF (is_a_number(phi_thr,/NOMSSG)  EQ 0) THEN phi_thr  = 15e0 ELSE phi_thr  = ABS(phi_thr[0])

;;  Define angular range to remove for UV contamination
phi_ls         = phi_s[0] + [-1d0,1d0]*phi_thr[0]
the_ls         = the_s[0] + [-1d0,1d0]*the_thr[0]
;;----------------------------------------------------------------------------------------
;;  Convert units to phase space density
;;----------------------------------------------------------------------------------------
IF (test0.(0)) THEN BEGIN
  ;;-------------------------------------------
  ;; Wind
  ;;-------------------------------------------
  ;;  Check which instrument is being used
  strns          = dat_3dp_str_names(dat[0])
  IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
    ;;  Incorrect structure type
    MESSAGE,badstr_mssg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF
  shnme          = STRLOWCASE(STRMID(strns.SN[0],0L,2L))
  data           = dat
  CASE shnme[0] OF
    'ph' :  convert_ph_units,data,'df'
    ELSE :  data    = conv_units(dat,'df')
  ENDCASE
  ;;  Define the bulk flow velocity structure tag
  veltag         = 'VSW'
ENDIF ELSE BEGIN
  ;;-------------------------------------------
  ;; THEMIS
  ;;-------------------------------------------
  ;;  make sure the structure has been modified
  temp_proc      = STRLOWCASE(dat[0].UNITS_PROCEDURE)
  test_un        = (temp_proc[0] NE def_uconv_r_th[0]) AND (temp_proc[0] NE def_uconv_r_th[1])
  IF (test_un[0]) THEN veltag = 'VELOCITY' ELSE veltag = 'VSW'
  ;;  structure modified appropriately so convert units
  data           = conv_units(dat,'df')
ENDELSE
n_n            = N_ELEMENTS(dat)
;;  Define spacecraft frame angles
phi_sc         = data.PHI MOD 36e1       ;; Azimuthal angle (from sun direction) [deg]
the_sc         = data.THETA              ;; Poloidal angle (from ecliptic plane) [deg]
;;  Define bulk flow velocities for frame transformations
dvel0          = struct_value(data[0],veltag[0],INDEX=index)
test           = (index[0] LT 0) AND (test0.(1))
IF (test[0]) THEN BEGIN
  ;;  Try a different tag
  veltag         = 'VSW'
  dvel0          = struct_value(data[0],veltag[0],INDEX=index)
  IF (index[0] LT 0) THEN BEGIN
    ;;  None of the bulk flow velocity tags were found --> return
    MESSAGE,'No bulk flow velocity tag found...',/CONTINUE,/INFORMATIONAL
    RETURN,0b
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Convert into Solar Wind (SW) frame
;;----------------------------------------------------------------------------------------
test           = is_a_3_vector(data.(index[0]),V_OUT=vtran2d)
IF (test[0]) THEN BEGIN
  ;;  None of the bulk flow velocity tags were found --> return
  MESSAGE,'Bulk flow velocity tag found but not formatted as a 3-vector...',/CONTINUE,/INFORMATIONAL
  RETURN,0b
ENDIF
;;  Lorentz transform the data into the bulk flow rest frame
dumb_i    = transform_vframe_3d_array(data,vtran2d)
;;----------------------------------------------------------------------------------------
;;  Define DAT structure parameters
;;----------------------------------------------------------------------------------------
n_e            = dumb_i[0].NENERGY       ;;  # of energy bins     [ = E]
n_a            = dumb_i[0].NBINS         ;;  # of angle bins      [ = A]
mass           = dumb_i[0].MASS          ;;  proton mass [eV c^(-2), with c in km/s]
;;  The following are:  [E,A,N]-Element Arrays
energy         = dumb_i.ENERGY           ;;  Energy bin values [eV]
phi            = dumb_i.PHI              ;;  Azimuthal angle (from sun direction) [deg]
theta          = dumb_i.THETA            ;;  Poloidal angle (from ecliptic plane) [deg]
;;  Magnitude of velocities from energy [km/s]
nvmag          = energy_to_vel(energy,mass[0])
;;----------------------------------------------------------------------------------------
;;  Define |V| and (theta,phi) tests
;;----------------------------------------------------------------------------------------
test_vth       = (nvmag LE v_thresh[0]) AND FINITE(nvmag)
test_vuv       = (nvmag LE v_uv[0])
test_phi       = (phi_sc LE phi_ls[1]) AND (phi_sc GE phi_ls[0])
test_the       = (the_sc LE the_ls[1]) AND (the_sc GE the_ls[0])
;;----------------------------------------------------------------------------------------
;;  Define gyrating ion and UV contamination masks
;;----------------------------------------------------------------------------------------
mask           = REPLICATE(0e0,n_e[0],n_a[0],n_n[0])  ;; overall mask
dumb           = REPLICATE(0e0,n_e[0],n_a[0])
mask_gi        = dumb                                 ;;  gyrating ion mask [TRUE for |V| ≤ V_thresh]
mask_uv        = dumb                                 ;;  UV contamination mask [FALSE for |V| ≤ V_UV and within ±ø of sun dir]
FOR j=0L, n_n[0] - 1L DO BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Determine gyrating ion elements to remove
  ;;--------------------------------------------------------------------------------------
  test           = test_vth[*,*,j]
  good           = WHERE(test,gd)
  IF (gd[0] GT 0) THEN mask_gi[good] = 1e0
  ;;--------------------------------------------------------------------------------------
  ;;  Determine UV contamination elements to remove
  ;;--------------------------------------------------------------------------------------
  ;; Find angles within "bad" UV range
  test0          = test_vuv[*,*,j]
  test1          = test_phi[*,*,j]
  test2          = test_the[*,*,j]
  test           = test0 AND test1 AND test2
  bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
  IF (gd[0] GT 0) THEN mask_uv[good] = 1e0
  ;;--------------------------------------------------------------------------------------
  ;;  Define overall mask
  ;;--------------------------------------------------------------------------------------
  mask[*,*,j]    = (mask_gi*mask_uv)
  ;;  Clean up
  test0          = 0 & test1   = 0 & test2   = 0 & test    = 0
  good           = 0 & bad     = 0
  ;;  Reset masks
  mask_gi       *= 0e0
  mask_uv       *= 0e0
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return mask to user
;;----------------------------------------------------------------------------------------
;*****************************************************************************************
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time)+' seconds execution time.',/CONTINUE,/INFORMATIONAL
;*****************************************************************************************

RETURN,mask
END


;IF ~KEYWORD_SET(v_thresh) THEN v_thresh = 50e1 ELSE v_thresh = v_thresh[0]
;IF ~KEYWORD_SET(v_uv)     THEN v_uv     = 50e1 ELSE v_uv     = v_uv[0]
;IF ~KEYWORD_SET(the_thr)  THEN the_thr  = 15e0 ELSE the_thr  = ABS(the_thr[0])
;IF ~KEYWORD_SET(phi_thr)  THEN phi_thr  = 15e0 ELSE phi_thr  = ABS(phi_thr[0])
;
;dumb      = data[0]
;transform_vframe_3d,dumb,/EASY_TRAN
;
;dumb_i    = REPLICATE(dumb[0],n_n)
;FOR j=0L, n_n - 1L DO BEGIN
;  del       = data[j]
;  transform_vframe_3d,del,/EASY_TRAN
;  dumb_i[j] = del[0]
;ENDFOR
;
;
;  mask_gi = REPLICATE(0e0,n_e[0],n_a[0])  ;;  gyrating ion mask [TRUE for |V| ≤ V_thresh]
;  vmag0   = nvmag[*,*,j]
;  test    = (vmag0 LE v_thresh[0]) AND FINITE(vmag0)
;  IF (gd GT 0) THEN BEGIN
;    mask_gi[good] = 1e0
;  ENDIF
;  mask_uv = REPLICATE(0e0,n_e[0],n_a[0])  ;;  UV contamination mask [FALSE for |V| ≤ V_UV and within ±ø of sun dir]
;  test0   = (vmag0 LE v_uv[0])
;  test1   = (phi_sc[*,*,j] LE phi_ls[1]) AND (phi_sc[*,*,j] GE phi_ls[0])
;  test2   = (the_sc[*,*,j] LE the_ls[1]) AND (the_sc[*,*,j] GE the_ls[0])
;  IF (gd GT 0) THEN BEGIN
;    mask_uv[good] = 1e0
;  ENDIF



