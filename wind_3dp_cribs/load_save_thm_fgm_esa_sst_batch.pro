;+
;*****************************************************************************************
;
;  BATCH    :   load_save_thm_fgm_esa_sst_batch.pro
;  PURPOSE  :   This is a batch file to be called from the command line using the
;                 standard method of calling
;                 (i.e., @load_save_thm_fgm_esa_sst_batch.pro).
;
;  CALLED BY:   
;               load_save_thm_fgm_esa_sst_crib.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_tdate_format.pro
;               time_double.pro
;               get_valid_trange.pro
;               @load_save_themis_fgm_esa_batch.pro
;               tnames.pro
;               add_scpot.pro
;               add_magf2.pro
;               add_vsw2.pro
;               thm_part_dist_array.pro
;               get_os_slash.pro
;               add_os_slash.pro
;
;  REQUIRES:    
;               1)  THEMIS SPEDAS IDL libraries and UMN Modified Wind/3DP IDL Libraries
;               2)  MUST run comp_lynn_pros.pro prior to calling this routine
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  Load all State, ESA, SST, and FGM data for 2008-07-26 for Probe B
;               ;;  **********************************************
;               ;;  **  variable names MUST exactly match these **
;               ;;  **********************************************
;               probe          = 'b'
;               tdate          = '2008-07-26'
;               date           = '072608'
;               @load_save_thm_fgm_esa_sst_batch.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This batch routine expects a date (in two formats) and a probe,
;                     all input on the command line prior to calling (see EXAMPLES)
;               2)  If your paths are not set correctly, you may need to provide a full
;                     path to this routine, e.g., on my machine this is:
;               @$HOME/wind_3dp_pros/wind_3dp_cribs/load_save_thm_fgm_esa_sst_batch.pro
;
;  REFERENCES:  
;               1)  McFadden, J.P., C.W. Carlson, D. Larson, M. Ludlam, R. Abiad,
;                      B. Elliot, P. Turin, M. Marckwordt, and V. Angelopoulos
;                      "The THEMIS ESA Plasma Instrument and In-flight Calibration,"
;                      Space Sci. Rev. 141, pp. 277-302, (2008).
;               2)  McFadden, J.P., C.W. Carlson, D. Larson, J.W. Bonnell,
;                      F.S. Mozer, V. Angelopoulos, K.-H. Glassmeier, U. Auster
;                      "THEMIS ESA First Science Results and Performance Issues,"
;                      Space Sci. Rev. 141, pp. 477-508, (2008).
;               3)  Auster, H.U., K.-H. Glassmeier, W. Magnes, O. Aydogar, W. Baumjohann,
;                      D. Constantinescu, D. Fischer, K.H. Fornacon, E. Georgescu,
;                      P. Harvey, O. Hillenmaier, R. Kroth, M. Ludlam, Y. Narita,
;                      R. Nakamura, K. Okrafka, F. Plaschke, I. Richter, H. Schwarzl,
;                      B. Stoll, A. Valavanoglou, and M. Wiedemann "The THEMIS Fluxgate
;                      Magnetometer," Space Sci. Rev. 141, pp. 235-264, (2008).
;               4)  Angelopoulos, V. "The THEMIS Mission," Space Sci. Rev. 141,
;                      pp. 5-34, (2008).
;               5)  Ni, B., Y. Shprits, M. Hartinger, V. Angelopoulos, X. Gu, and
;                      D. Larson "Analysis of radiation belt energetic electron phase
;                      space density using THEMIS SST measurements: Cross‐satellite
;                      calibration and a case study," J. Geophys. Res. 116, A03208,
;                      doi:10.1029/2010JA016104, 2011.
;               6)  Turner, D.L., V. Angelopoulos, Y. Shprits, A. Kellerman, P. Cruce,
;                      and D. Larson "Radial distributions of equatorial phase space
;                      density for outer radiation belt electrons," Geophys. Res. Lett.
;                      39, L09101, doi:10.1029/2012GL051722, 2012.
;
;   CREATED:  04/13/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/13/2016   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
;;  Define dummy error messages
dummy_errmsg   = ['You have not defined the proper input!',          $
                  'This batch routine expects three inputs',         $
                  'with following EXACT variable names:',            $
                  "date   ;; e.g., '072608' for July 26, 2008",      $
                  "tdate  ;; e.g., '2008-07-26' for July 26, 2008",  $
                  "probe  ;; e.g., 'b' for Probe B"                  ]
nderrmsg       = N_ELEMENTS(dummy_errmsg) - 1L
;;----------------------------------------------------------------------------------------
;;  Define and times/dates Probe from input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(date) EQ 0) OR (N_ELEMENTS(tdate) EQ 0) OR $
                 (N_ELEMENTS(probe) EQ 0)
IF (test) THEN FOR pj=0L, nderrmsg[0] DO PRINT,dummy_errmsg[pj]
IF (test) THEN STOP        ;;  Stop before user runs into issues
;;  Check TDATE format
test           = test_tdate_format(tdate)
IF (test EQ 0) THEN STOP        ;;  Stop before user runs into issues

sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
scpref         = pref[0]
scu            = STRUPCASE(sc[0])
;;  Default to entire day
tr_00          = tdate[0]+'/'+['00:00:00.000','23:59:59.999']
;;  Make sure valid time range
trange         = time_double(tr_00)
test           = get_valid_trange(TRANGE=trange,PRECISION=6)
IF (SIZE(test,/TYPE) NE 8) THEN STOP        ;;  Stop before user runs into issues
;;----------------------------------------------------------------------------------------
;;  Load all STATE, ESA, and FGM data
;;----------------------------------------------------------------------------------------
no_clean       = 1b                         ;;  keep ESA structures after loading
@$HOME/wind_3dp_pros/wind_3dp_cribs/load_save_themis_fgm_esa_batch.pro
;;----------------------------------------------------------------------------------------
;;  Define ESA structure arrays
;;----------------------------------------------------------------------------------------
n_i            = N_ELEMENTS(dat_i)
n_e            = N_ELEMENTS(dat_e)
PRINT,';;  Ni = ', n_i[0]
PRINT,';;  Ne = ', n_e[0]
;;----------------------------------------------------------------------------------------
;;  Define relevant TPLOT handles
;;----------------------------------------------------------------------------------------
vbulk_tpn_dsl  = tnames(scpref[0]+'peib_velocity_'+coord_dsl[0])
spperi_tpn     = tnames(scpref[0]+'state_spinper')
scname_tpn     = tnames(scpref[0]+'peeb_sc_pot')
scnami_tpn     = tnames(scpref[0]+'peib_sc_pot')
bvec_s_tp_dsl  = tnames(scpref[0]+'fgs_'+coord_gse[0])
bvec_l_tp_dsl  = tnames(scpref[0]+'fgl_'+coord_gse[0])
bvec_h_tp_dsl  = tnames(scpref[0]+'fgh_'+coord_gse[0])
;;----------------------------------------------------------------------------------------
;;  Add data to structures
;;----------------------------------------------------------------------------------------
;;  Add SC potential to ESA structures
IF (scnami_tpn[0] NE '') THEN add_scpot,dat_i,scnami_tpn[0],/LEAVE_ALONE
IF (scname_tpn[0] NE '') THEN add_scpot,dat_e,scname_tpn[0],/LEAVE_ALONE
;;  Add bulk flow velocity to ESA structures
IF (vbulk_tpn_dsl[0] NE '') THEN add_vsw2,dat_i,vbulk_tpn_dsl[0],/LEAVE_ALONE,VBULK_TAG='VELOCITY'
IF (vbulk_tpn_dsl[0] NE '') THEN add_vsw2,dat_e,vbulk_tpn_dsl[0],/LEAVE_ALONE,VBULK_TAG='VELOCITY'
;;  Add quasi-static magnetic field to ESA structures
IF (bvec_s_tp_dsl[0] NE '') THEN add_magf2,dat_i,bvec_s_tp_dsl[0],/LEAVE_ALONE
IF (bvec_s_tp_dsl[0] NE '') THEN add_magf2,dat_e,bvec_s_tp_dsl[0],/LEAVE_ALONE
IF (bvec_l_tp_dsl[0] NE '') THEN add_magf2,dat_i,bvec_l_tp_dsl[0],/LEAVE_ALONE
IF (bvec_l_tp_dsl[0] NE '') THEN add_magf2,dat_e,bvec_l_tp_dsl[0],/LEAVE_ALONE
IF (bvec_h_tp_dsl[0] NE '') THEN add_magf2,dat_i,bvec_h_tp_dsl[0],/LEAVE_ALONE
IF (bvec_h_tp_dsl[0] NE '') THEN add_magf2,dat_e,bvec_h_tp_dsl[0],/LEAVE_ALONE
;;----------------------------------------------------------------------------------------
;;  Get just SST data in units of counts
;;----------------------------------------------------------------------------------------
IF (bvec_s_tp_dsl[0] NE '') THEN magname    = bvec_s_tp_dsl[0]
IF (vbulk_tpn_dsl[0] NE '') THEN vbulk_name = vbulk_tpn_dsl[0]

tra_sst        = time_double(tr_00)
fb_string      = ['f','b']
ssti_fb        = 'psi'+fb_string
sste_fb        = 'pse'+fb_string
sst_suffx      = '_cal'
;;  SST Ion Full
sst_cal        = STREGEX(ssti_fb[0],'ps[ei]r',/BOOL,/FOLD_CASE) ? 0b:1b
ssti_f_ptr     = thm_part_dist_array(PROBE=sc[0],TRANGE=tra_sst,DATATYPE=ssti_fb[0],$
                                     SST_CAL=sst_cal,MAG_DATA=mag_name[0],          $
                                     VEL_DATA=vbulk_name[0],                        $
                                     METHOD_SUNPULSE_CLEAN='z_score_mod')

;;  SST Electron Full
sst_cal        = STREGEX(sste_fb[0],'ps[ei]r',/BOOL,/FOLD_CASE) ? 0b:1b
sste_f_ptr     = thm_part_dist_array(PROBE=sc[0],TRANGE=tra_sst,DATATYPE=sste_fb[0],$
                                     SST_CAL=sst_cal,MAG_DATA=mag_name[0],          $
                                     VEL_DATA=vbulk_name[0],                        $
                                     METHOD_SUNPULSE_CLEAN='z_score_mod')

;;  SST Electron Burst
sst_cal        = STREGEX(sste_fb[1],'ps[ei]r',/BOOL,/FOLD_CASE) ? 0b:1b
sste_b_ptr     = thm_part_dist_array(PROBE=sc[0],TRANGE=tra_sst,DATATYPE=sste_fb[1],$
                                     SST_CAL=sst_cal,MAG_DATA=mag_name[0],          $
                                     VEL_DATA=vbulk_name[0],                        $
                                     METHOD_SUNPULSE_CLEAN='z_score_mod')
;;----------------------------------------------------------------------------------------
;;  Merge SST pointers into structure arrays
;;----------------------------------------------------------------------------------------
;;  Structure format is constant for SST-Ions
n_mode         = N_ELEMENTS(ssti_f_ptr)
FOR mm=0L, n_mode[0] - 1L DO BEGIN                                   $
  IF (mm EQ 0) THEN temp = (*ssti_f_ptr[mm]) ELSE temp = [temp,(*ssti_f_ptr[mm])]
;;  Sort by time
sp             = SORT(temp.TIME)
temp           = TEMPORARY(temp[sp])
ssti_f         = temp
temp           = 0       ;;  clean up

n_mode         = N_ELEMENTS(sste_f_ptr)
FOR mm=0L, n_mode[0] - 1L DO BEGIN                                   $
  IF (mm EQ 0) THEN temp = (*sste_f_ptr[mm]) ELSE temp = [temp,(*sste_f_ptr[mm])]
;;  Sort by time
sp             = SORT(temp.TIME)
temp           = TEMPORARY(temp[sp])
sste_f         = temp
temp           = 0       ;;  clean up

n_mode         = N_ELEMENTS(sste_b_ptr)
FOR mm=0L, n_mode[0] - 1L DO BEGIN                                   $
  IF (mm EQ 0) THEN temp = (*sste_b_ptr[mm]) ELSE temp = [temp,(*sste_b_ptr[mm])]
;;  Sort by time
sp             = SORT(temp.TIME)
temp           = TEMPORARY(temp[sp])
sste_b         = temp
temp           = 0       ;;  clean up
;;----------------------------------------------------------------------------------------
;;  Clean up pointers
;;----------------------------------------------------------------------------------------
n_mode         = N_ELEMENTS(ssti_f_ptr)
FOR mm=0L, n_mode[0] - 1L DO BEGIN                                   $
  PTR_FREE,ssti_f_ptr[mm]                                          & $
  HEAP_FREE,ssti_f_ptr[mm],/PTR
DELVAR,ssti_f_ptr

n_mode         = N_ELEMENTS(sste_f_ptr)
FOR mm=0L, n_mode[0] - 1L DO BEGIN                                   $
  PTR_FREE,sste_f_ptr[mm]                                          & $
  HEAP_FREE,sste_f_ptr[mm],/PTR
DELVAR,sste_f_ptr

n_mode         = N_ELEMENTS(sste_b_ptr)
FOR mm=0L, n_mode[0] - 1L DO BEGIN                                   $
  PTR_FREE,sste_b_ptr[mm]                                          & $
  HEAP_FREE,sste_b_ptr[mm],/PTR
DELVAR,sste_b_ptr
;;----------------------------------------------------------------------------------------
;;  Setup variables for IDL save file for SST data
;;----------------------------------------------------------------------------------------
all_scs        = ['a','b','c','d','e']
all_midn       = ['Full','Burst','Both']
ei_str         = ['e','i']
bf_str         = ['b','f']
inst_suffx     = '_df_arr_'+sc[0]           ;;  e.g., '_df_arr_c'
inst_epref     = 'ps'+ei_str[0]+bf_str      ;;  e.g., 'pseb'
inst_ipref     = 'ps'+ei_str[1]+bf_str      ;;  e.g., 'psif'
inst_estrs     = inst_epref+inst_suffx[0]   ;;  e.g., 'pseb_df_arr_c'
inst_istrs     = inst_ipref+inst_suffx[0]   ;;  e.g., 'psif_df_arr_c'
p_test         = WHERE(all_scs EQ sc[0],pt)
p_t_arr        = [(p_test[0] EQ 0),(p_test[0] EQ 1),(p_test[0] EQ 2),(p_test[0] EQ 3),(p_test[0] EQ 4)]
smid_fnms      = '_'+all_midn+'_THEMIS_'

nsef           = 0L
nseb           = 0L
nsif           = 0L
nsib           = 0L
IF (SIZE(sste_f,/TYPE) EQ 8) THEN nsef = N_ELEMENTS(sste_f)
IF (SIZE(sste_b,/TYPE) EQ 8) THEN nseb = N_ELEMENTS(sste_b)
IF (SIZE(ssti_f,/TYPE) EQ 8) THEN nsif = N_ELEMENTS(ssti_f)
IF (SIZE(ssti_b,/TYPE) EQ 8) THEN nsib = N_ELEMENTS(ssti_b)
PRINT,';; ',nseb[0],nsef[0],nsib[0],nsif[0],'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;         1347         658           0       14009  For Probe:  THC on 2008-07-14
;;         1338         655           0       14019  For Probe:  THC on 2008-08-19
;;         1188         662           0       14092  For Probe:  THC on 2008-09-08
;;         1386         661           0       14091  For Probe:  THC on 2008-09-16

IF (nsef[0] GT 0 AND nseb[0] GT 0) THEN sste_midn = smid_fnms[2] ELSE $
  IF (nsef[0] GT 0) THEN sste_midn = smid_fnms[0] ELSE sste_midn = smid_fnms[1]

IF (nsef[0] GT 0 AND nseb[0] GT 0) THEN inste_str = inst_estrs[0]+', '+inst_estrs[1] ELSE $
  IF (nsef[0] GT 0) THEN inste_str = inst_estrs[1] ELSE inste_str = inst_estrs[0]

IF (nsif[0] GT 0 AND nsib[0] GT 0) THEN ssti_midn = smid_fnms[2] ELSE $
  IF (nsif[0] GT 0) THEN ssti_midn = smid_fnms[0] ELSE ssti_midn = smid_fnms[1]

IF (nsif[0] GT 0 AND nsib[0] GT 0) THEN insti_str = inst_istrs[0]+', '+inst_istrs[1] ELSE $
  IF (nsif[0] GT 0) THEN insti_str = inst_istrs[1] ELSE insti_str = inst_istrs[0]

inst_str       = [inste_str[0],insti_str[0]]
;;----------------------------------------------------------------------------------------
;;  Modify SST routines
;;----------------------------------------------------------------------------------------
;;  Modify unit conversion procedure
IF (nsef[0] GT 0) THEN sste_f.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nseb[0] GT 0) THEN sste_b.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nsif[0] GT 0) THEN ssti_f.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'
IF (nsib[0] GT 0) THEN ssti_b.UNITS_PROCEDURE = 'thm_convert_sst_units_lbwiii'

;;  Modify particle charge
IF (nsef[0] GT 0) THEN sste_f.CHARGE = -1e0
IF (nseb[0] GT 0) THEN sste_b.CHARGE = -1e0
IF (nsif[0] GT 0) THEN ssti_f.CHARGE =  1e0
IF (nsib[0] GT 0) THEN ssti_b.CHARGE =  1e0
;;----------------------------------------------------------------------------------------
;;  Sort structures by time
;;----------------------------------------------------------------------------------------
IF (nsef[0] GT 0) THEN sp             =      SORT(sste_f.TIME)
IF (nsef[0] GT 0) THEN sste_f         = TEMPORARY(sste_f[sp])
IF (nseb[0] GT 0) THEN sp             =      SORT(sste_b.TIME)
IF (nseb[0] GT 0) THEN sste_b         = TEMPORARY(sste_b[sp])
IF (nsif[0] GT 0) THEN sp             =      SORT(ssti_f.TIME)
IF (nsif[0] GT 0) THEN ssti_f         = TEMPORARY(ssti_f[sp])
IF (nsib[0] GT 0) THEN sp             =      SORT(ssti_b.TIME)
IF (nsib[0] GT 0) THEN ssti_b         = TEMPORARY(ssti_b[sp])
;;----------------------------------------------------------------------------------------
;;  Define structures to save
;;----------------------------------------------------------------------------------------
;;  SST Electron Full
IF (p_t_arr[0]) THEN IF (nsef[0] GT 0) THEN psef_df_arr_a = sste_f
IF (p_t_arr[1]) THEN IF (nsef[0] GT 0) THEN psef_df_arr_b = sste_f
IF (p_t_arr[2]) THEN IF (nsef[0] GT 0) THEN psef_df_arr_c = sste_f
IF (p_t_arr[3]) THEN IF (nsef[0] GT 0) THEN psef_df_arr_d = sste_f
IF (p_t_arr[4]) THEN IF (nsef[0] GT 0) THEN psef_df_arr_e = sste_f

;;  SST Electron Burst
IF (p_t_arr[0]) THEN IF (nseb[0] GT 0) THEN pseb_df_arr_a = sste_b
IF (p_t_arr[1]) THEN IF (nseb[0] GT 0) THEN pseb_df_arr_b = sste_b
IF (p_t_arr[2]) THEN IF (nseb[0] GT 0) THEN pseb_df_arr_c = sste_b
IF (p_t_arr[3]) THEN IF (nseb[0] GT 0) THEN pseb_df_arr_d = sste_b
IF (p_t_arr[4]) THEN IF (nseb[0] GT 0) THEN pseb_df_arr_e = sste_b

;;  SST Ion Full
IF (p_t_arr[0]) THEN IF (nsif[0] GT 0) THEN psif_df_arr_a = ssti_f
IF (p_t_arr[1]) THEN IF (nsif[0] GT 0) THEN psif_df_arr_b = ssti_f
IF (p_t_arr[2]) THEN IF (nsif[0] GT 0) THEN psif_df_arr_c = ssti_f
IF (p_t_arr[3]) THEN IF (nsif[0] GT 0) THEN psif_df_arr_d = ssti_f
IF (p_t_arr[4]) THEN IF (nsif[0] GT 0) THEN psif_df_arr_e = ssti_f

;;  SST Ion Burst
IF (p_t_arr[0]) THEN IF (nsib[0] GT 0) THEN psib_df_arr_a = ssti_b
IF (p_t_arr[1]) THEN IF (nsib[0] GT 0) THEN psib_df_arr_b = ssti_b
IF (p_t_arr[2]) THEN IF (nsib[0] GT 0) THEN psib_df_arr_c = ssti_b
IF (p_t_arr[3]) THEN IF (nsib[0] GT 0) THEN psib_df_arr_d = ssti_b
IF (p_t_arr[4]) THEN IF (nsib[0] GT 0) THEN psib_df_arr_e = ssti_b
;;----------------------------------------------------------------------------------------
;;  Create IDL save file for SST data
;;----------------------------------------------------------------------------------------
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char = '.'+slash[0]
cur_wdir       = FILE_EXPAND_PATH(cwd_char[0])
new_ts_dir     = add_os_slash(cur_wdir[0])
new_sst_dir    = new_ts_dir[0]+'themis_sst_save'+slash[0]+tdate[0]+slash[0]
FILE_MKDIR,new_sst_dir[0]
esname         = new_sst_dir[0]+'SSTE'+sste_midn[0]+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
isname         = new_sst_dir[0]+'SSTI'+ssti_midn[0]+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
ei_suffx       = ',FILENAME='+ei_str+'sname[0]'
exc_str_ei     = 'SAVE,'+inst_str+ei_suffx
;;   Save Electrons
test_e         = EXECUTE(exc_str_ei[0])
;;   Save Ions
test_i         = EXECUTE(exc_str_ei[1])

;;  Clean up
DELVAR,sste_f,sste_b,ssti_f,ssti_b
DELVAR,psef_df_arr_a,psef_df_arr_b,psef_df_arr_c,psef_df_arr_d,psef_df_arr_e
DELVAR,pseb_df_arr_a,pseb_df_arr_b,pseb_df_arr_c,pseb_df_arr_d,pseb_df_arr_e
DELVAR,psif_df_arr_a,psif_df_arr_b,psif_df_arr_c,psif_df_arr_d,psif_df_arr_e
DELVAR,psib_df_arr_a,psib_df_arr_b,psib_df_arr_c,psib_df_arr_d,psib_df_arr_e
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------










;test_e         = WHERE([(N_ELEMENTS(peeb_df_arr_a) GT 0),$
;                        (N_ELEMENTS(peeb_df_arr_b) GT 0),$
;                        (N_ELEMENTS(peeb_df_arr_c) GT 0),$
;                        (N_ELEMENTS(peeb_df_arr_d) GT 0),$
;                        (N_ELEMENTS(peeb_df_arr_e) GT 0)],gd_e)
;test_i         = WHERE([(N_ELEMENTS(peib_df_arr_a) GT 0),$
;                        (N_ELEMENTS(peib_df_arr_b) GT 0),$
;                        (N_ELEMENTS(peib_df_arr_c) GT 0),$
;                        (N_ELEMENTS(peib_df_arr_d) GT 0),$
;                        (N_ELEMENTS(peib_df_arr_e) GT 0)],gd_i)
;test_eesa      = (gd_e[0] GT 0)
;test_iesa      = (gd_i[0] GT 0)
;;test_eesa      = (nef[0] GE 0) OR (neb[0] GE 0)
;;test_iesa      = (nif[0] GE 0) OR (nib[0] GE 0)
;
;;;  Define EESA structures [angles in DSL still]
;IF (test_eesa[0] AND (test_e[0] EQ 0)) THEN dat_e = peeb_df_arr_a
;IF (test_eesa[0] AND (test_e[0] EQ 1)) THEN dat_e = peeb_df_arr_b
;IF (test_eesa[0] AND (test_e[0] EQ 2)) THEN dat_e = peeb_df_arr_c
;IF (test_eesa[0] AND (test_e[0] EQ 3)) THEN dat_e = peeb_df_arr_d
;IF (test_eesa[0] AND (test_e[0] EQ 4)) THEN dat_e = peeb_df_arr_e
;;;  Define IESA structures [angles in DSL still]
;IF (test_iesa[0] AND (test_i[0] EQ 0)) THEN dat_i = peib_df_arr_a
;IF (test_iesa[0] AND (test_i[0] EQ 1)) THEN dat_i = peib_df_arr_b
;IF (test_iesa[0] AND (test_i[0] EQ 2)) THEN dat_i = peib_df_arr_c
;IF (test_iesa[0] AND (test_i[0] EQ 3)) THEN dat_i = peib_df_arr_d
;IF (test_iesa[0] AND (test_i[0] EQ 4)) THEN dat_i = peib_df_arr_e
;;;  Clean up
;DELVAR,peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e
;DELVAR,peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e

;new_ts_dir     = add_os_slash(cur_wdir[0]);+'themis_data_dir'+slash[0]
