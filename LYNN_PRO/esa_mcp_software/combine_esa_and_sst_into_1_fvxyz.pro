;+
;*****************************************************************************************
;
;  FUNCTION :   combine_esa_and_sst_into_1_fvxyz.pro
;  PURPOSE  :   This routine acts as a wrapper for conv_vdfidlstr_2_f_vs_vxyz_thm_wi.pro
;                 to combine arrays of ESA and SST distributions to produce a single
;                 structure of phase space densities [# s^(+3) km^(-3) cm^(-3)] with
;                 associated 3-vector velocities [km/s], Unix start and end times, and
;                 indices of input structurre arrays.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               define_particle_charge.pro
;               test_wind_vs_themis_esa_struct.pro
;               conv_vdfidlstr_2_f_vs_vxyz_thm_wi.pro
;               find_overlapping_trans.pro
;               delete_variable.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT_ESA    :  Scalar or [N]-element [structure] array associated with a
;                               known THEMIS ESA data structure
;                               [see get_th?_pe*b.pro, ? = a-f]
;                               or a Wind/3DP data structure
;                               [see get_?.pro, ? = el, elb, pl, ph, eh, etc.]
;               DAT_SST    :  Scalar or [N]-element [structure] array associated with a
;                               known THEMIS SST data structure
;                               [see get_th?_ps*b.pro, ? = a-f]
;                               or a Wind/3DP data structure
;                               [see get_?.pro, ? = sf, sfb, so, sob]
;
;  EXAMPLES:    
;               [calling sequence]
;               test = combine_esa_and_sst_into_1_fvxyz(dat_esa,dat_sst)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This works well when both instruments are in burst mode and have
;                     roughly the same total duration.  It has not been tested on
;                     intervals that mix instrument modes.
;
;  REFERENCES:  
;               0)  Harten, R. and K. Clark "The Design Features of the GGS Wind and
;                      Polar Spacecraft," Space Sci. Rev. Vol. 71, pp. 23--40, 1995.
;               1)  Carlson et al., "An instrument for rapidly measuring plasma
;                      distribution functions with high resolution," Adv. Space Res.
;                      2, pp. 67--70, 1983.
;               2)  Curtis et al., "On-board data analysis techniques for space plasma
;                      particle instruments," Rev. Sci. Inst. 60, pp. 372--380, 1989.
;               3)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      71, pp. 125--153, 1995.
;               4)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                      Intl. Space Sci. Inst., 1998.
;               5)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277--302, 2008.
;               6)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477--508, 2008.
;               7)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235--264, 2008.
;               8)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5--34, 2008.
;               9)  Ipavich, F.M. "The Compton-Getting effect for low energy particles,"
;                      Geophys. Res. Lett. 1(4), pp. 149--152, 1974.
;              10)  Ni, B., Y. Shprits, M. Hartinger, V. Angelopoulos, X. Gu, and
;                      D. Larson "Analysis of radiation belt energetic electron phase
;                      space density using THEMIS SST measurements: Cross‐satellite
;                      calibration and a case study," J. Geophys. Res. 116, A03208,
;                      doi:10.1029/2010JA016104, 2011.
;              11)  Turner, D.L., V. Angelopoulos, Y. Shprits, A. Kellerman, P. Cruce,
;                      and D. Larson "Radial distributions of equatorial phase space
;                      density for outer radiation belt electrons," Geophys. Res. Lett.
;                      39, L09101, doi:10.1029/2012GL051722, 2012.
;
;   CREATED:  11/28/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/28/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION combine_esa_and_sst_into_1_fvxyz,dat_esa,dat_sst

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy error messages
noinpt_msg     = 'User must supply two velocity distribution functions as IDL structures...'
notstr_msg     = 'DAT_ESA and DAT_SST must be IDL structures...'
notvdf_msg     = 'DAT_ESA and DAT_SST must be velocity distribution functions as an IDL structures...'
diffsc_msg     = 'DAT_ESA and DAT_SST must come from the same spacecraft...'
badvdf_msg     = 'Input must be an IDL structure with similar format to Wind/3DP or THEMIS/ESA...'
not3dp_msg     = 'Input must be a velocity distribution IDL structure from Wind/3DP...'
notthm_msg     = 'Input must be a velocity distribution IDL structure from THEMIS/ESA...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN BEGIN
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
dat0           = dat_esa[0]
dat1           = dat_sst[0]
test           = (SIZE(dat0,/TYPE) NE 8L OR N_ELEMENTS(dat0) LT 1) OR $
                 (SIZE(dat1,/TYPE) NE 8L OR N_ELEMENTS(dat1) LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define sign of particle charge and energy shift
charge0        = define_particle_charge(dat0,E_SHIFT=e_shift0)
charge1        = define_particle_charge(dat1,E_SHIFT=e_shift1)
IF (charge0[0] EQ 0 OR charge1[0] EQ 0 OR charge0[0] NE charge1[0]) THEN BEGIN
  MESSAGE,notvdf_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Make sure the distributions come from the same spacecraft (i.e., no mixing!)
test_esa0      = test_wind_vs_themis_esa_struct(dat0[0],/NOM)
test_sst0      = test_wind_vs_themis_esa_struct(dat1[0],/NOM)
test           = (test_esa0.(0) EQ test_sst0.(0)) AND (test_esa0.(1) EQ test_sst0.(1))
IF (test[0] EQ 0) THEN BEGIN
  MESSAGE,diffsc_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check for existence of E_SHIFT structure tag
;;----------------------------------------------------------------------------------------
n_esa          = N_ELEMENTS(dat_esa)           ;;  # of ESA data structures
n_sst          = N_ELEMENTS(dat_sst)           ;;  # of SST data structures
IF (N_ELEMENTS(e_shift0) GT 0) THEN e_sh_on0 = 1b ELSE e_sh_on0 = 0b
IF (N_ELEMENTS(e_shift1) GT 0) THEN e_sh_on1 = 1b ELSE e_sh_on1 = 0b
;;----------------------------------------------------------------------------------------
;;  Define the spacecraft potentials
;;    -->  Assume charge does not change between structures
;;----------------------------------------------------------------------------------------
scpot0         = dat_esa.SC_POT[0]*charge0[0]    ;;  ø < 0 (electrons), ø > 0 (ions)
scpot1         = dat_sst.SC_POT[0]*charge1[0]    ;;  ø < 0 (electrons), ø > 0 (ions)
bad_scp0       = WHERE(FINITE(scpot0) EQ 0,bd_scp0)
bad_scp1       = WHERE(FINITE(scpot1) EQ 0,bd_scp1)
IF (bd_scp0[0] GT 0) THEN BEGIN
  scpot0[bad_scp0]         = 0e0
  dat_esa[bad_scp0].SC_POT = 0e0
ENDIF
IF (bd_scp1[0] GT 0) THEN BEGIN
  scpot1[bad_scp1]         = 0e0
  dat_sst[bad_scp1].SC_POT = 0e0
ENDIF
mass0          = dat_esa[0].MASS[0]            ;;  particle mass [eV km^(-2) s^(2)]
mass1          = dat_sst[0].MASS[0]            ;;  particle mass [eV km^(-2) s^(2)]
;;----------------------------------------------------------------------------------------
;;  Convert from F[E,Ω,ø] to G[Vx,Vy,Vz]
;;----------------------------------------------------------------------------------------
n_e0           = dat_esa[0].NENERGY            ;;  # of energy bins
n_a0           = dat_esa[0].NBINS              ;;  # of angle bins
n_e1           = dat_sst[0].NENERGY            ;;  # of energy bins
n_a1           = dat_sst[0].NBINS              ;;  # of angle bins
n_s0           = n_e0[0]*n_a0[0]
n_s1           = n_e1[0]*n_a1[0]
;;  Define dummy arrays to fill later
fofv0          = REPLICATE(d,n_esa[0],n_s0[0])
vel_0          = REPLICATE(d,n_esa[0],n_s0[0],3L)
fofv1          = REPLICATE(d,n_sst[0],n_s1[0])
vel_1          = REPLICATE(d,n_sst[0],n_s1[0],3L)
;;  Loop through ESA structures [vectorize later...]
FOR j=0L, n_esa[0] - 1L DO BEGIN
  temp = dat_esa[j]
  dumb = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(temp)
  IF (SIZE(dumb,/TYPE) NE 8) THEN CONTINUE
  fofv0[j,*]   = dumb[0].VDF
  vel_0[j,*,*] = dumb[0].VELXYZ
ENDFOR
;;  Loop through SST structures [vectorize later...]
FOR j=0L, n_sst[0] - 1L DO BEGIN
  temp = dat_sst[j]
  dumb = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(temp)
  IF (SIZE(dumb,/TYPE) NE 8) THEN CONTINUE
  fofv1[j,*]   = dumb[0].VDF
  vel_1[j,*,*] = dumb[0].VELXYZ
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Find overlapping elements
;;----------------------------------------------------------------------------------------
tran_esa       = [[dat_esa.TIME],[dat_esa.END_TIME]]
tran_sst       = [[dat_sst.TIME],[dat_sst.END_TIME]]
gind_all       = find_overlapping_trans(tran_esa,tran_sst,MIN_OVR=0d0,MAX_OVR=1d30,PREC=3)
gind_esa0      = REFORM(gind_all[*,0])
gind_sst0      = REFORM(gind_all[*,1])
good0          = WHERE(gind_esa0 GE 0,gd0)
good1          = WHERE(gind_sst0 GE 0,gd1)
IF (gd0[0] GT 0) THEN gind_esa = gind_esa0[good0] ELSE gind_esa = -1L
IF (gd1[0] GT 0) THEN gind_sst = gind_sst0[good1] ELSE gind_sst = -1L
IF (gd0[0] EQ 0 OR gd1[0] EQ 0) THEN STOP         ;;  No overlapping time ranges
;;  Define good outputs
unix_se_e      = tran_esa[gind_esa,*]
unix_se_s      = tran_sst[gind_sst,*]
fofve          = fofv0[gind_esa,*]
vel_e          = vel_0[gind_esa,*,*]
fofvs          = fofv1[gind_sst,*]
vel_s          = vel_1[gind_sst,*,*]
;;  Clean up
delete_variable,fofv0,vel_0,fofv1,vel_1,gind_all,gind_esa0,gind_sst0
;;----------------------------------------------------------------------------------------
;;  Merge into one output
;;----------------------------------------------------------------------------------------
n_out          = (gd0[0] < gd1[0])
n_san          = n_s0[0] + n_s1[0]
nupp           = n_out[0] - 1L
eupp           = n_s0[0] - 1L
elow           = 0L
sl_o           = n_s0[0]
su_o           = n_san[0] - 1L
slow           = 0L
supp           = n_s1[0] - 1L
;;  Define fill arrrays
fofv_out       = REPLICATE(d,n_out[0],n_san[0])
vel__out       = REPLICATE(d,n_out[0],n_san[0],3L)
unix_out       = REPLICATE(d,n_out[0],2L)
;;  Fill arrays
fofv_out[*,elow[0]:eupp[0]]    = fofve[0L:nupp[0],*]
fofv_out[*,sl_o[0]:su_o[0]]    = fofvs[0L:nupp[0],*]
vel__out[*,elow[0]:eupp[0],*]  = vel_e[0L:nupp[0],*,*]
vel__out[*,sl_o[0]:su_o[0],*]  = vel_s[0L:nupp[0],*,*]
unix_out[*,0]                  = unix_se_e[0L:nupp[0],0]
unix_out[*,1]                  = unix_se_e[0L:nupp[0],1]
;;  Clean up
delete_variable,fofve,vel_e,fofvs,vel_s
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
struct         = {UNIX:unix_out,VDF:fofv_out,VELXYZ:vel__out,IND_ESA:gind_esa,IND_SST:gind_sst}
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END












