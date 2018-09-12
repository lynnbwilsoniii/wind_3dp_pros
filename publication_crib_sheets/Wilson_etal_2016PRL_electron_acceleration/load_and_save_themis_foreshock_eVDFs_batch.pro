;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;;  Electron mass [kg]
mp             = 1.6726217770d-27     ;;  Proton mass [kg]
ma             = 6.6446567500d-27     ;;  Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;;  Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;;  Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;;  Fundamental charge [C]
kB             = 1.3806488000d-23     ;;  Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;;  Planck Constant [J s]
GG             = 6.6738400000d-11     ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [J]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;;  Earth's Equatorial Radius [km]
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
all_scs        = ['a','b','c','d','e']
coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
;;----------------------------------------------------------------------------------------
;;  Define and times/dates Probe from input
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
scpref         = pref[0]
scu            = STRUPCASE(sc[0])
;;  Default to entire day
tr_00          = tdate[0]+'/'+['00:00:00.000','23:59:59.999']
;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
;themis_load_all_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00),$
;                     /LOAD_EESA_DF,EESA_DF_OUT=poynter_peeb,/LOAD_IESA_DF, $
;                     IESA_DF_OUT=poynter_peib,ESA_BF_TYPE='both'
themis_load_fgm_esa_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00), $
                         /LOAD_EESA_DF,EESA_DF_OUT=poynter_peeb,/LOAD_IESA_DF, $
                         IESA_DF_OUT=poynter_peib,ESA_BF_TYPE='both'
;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'

nnw            = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01

;;  Change options for energy spectrogram counts
;;    --> Fix Y-Axis ranges
scpref         = 'th'+sc[0]+'_'
tpn_en_cnt_e   = tnames(scpref[0]+'pee*_en_counts')
tpn_en_cnt_i   = tnames(scpref[0]+'pei*_en_counts')
options,[tpn_en_cnt_e,tpn_en_cnt_i],'YRANGE'
options,[tpn_en_cnt_e,tpn_en_cnt_i],'YRANGE',[5d0,35d3],/DEF
;;    --> Fix interpolation options
options,[tpn_en_cnt_e,tpn_en_cnt_i],'X_NO_INTERP'
options,[tpn_en_cnt_e,tpn_en_cnt_i],'Y_NO_INTERP'
options,[tpn_en_cnt_e,tpn_en_cnt_i],'X_NO_INTERP',0,/DEF
options,[tpn_en_cnt_e,tpn_en_cnt_i],'Y_NO_INTERP',0,/DEF
;;    --> Fix # of Z-Axis tick marks
options,[tpn_en_cnt_e,tpn_en_cnt_i],'ZTICKS'
options,[tpn_en_cnt_e,tpn_en_cnt_i],'ZTICKS',4,/DEF

;;  Open window
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*9d-1
WINDOW,0,RETAIN=2,XSIZE=wsz[0],YSIZE=wsz[1],TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'
;;----------------------------------------------------------------------------------------
;;  Fix Y-Axis subtitles
;;----------------------------------------------------------------------------------------
scpref         = 'th'+sc[0]+'_'

modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm+'_'
fgm_mag        = tnames(fgm_pren[*]+'mag')
tplot,fgm_mag

;;  Find all fgs TPLOT handles
options,scpref[0]+'fgs_fci_flh_fce','YTITLE' 
options,scpref[0]+'fgs_fci_flh_fce','YTITLE',mode_fgm[0]+' [fci,flh,fce]',/DEF
;;----------------------------------------------------------------------------------------
;;  Save moments
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
;mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
;fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]
tplot_save,FILENAME=fname[0]
;;----------------------------------------------------------------------------------------
;;  Define ESA DF IDL Data Structures
;;----------------------------------------------------------------------------------------
all_scs        = ['a','b','c','d','e']
p_test         = WHERE(all_scs EQ sc[0],pt)
p_t_arr        = [(p_test[0] EQ 0),(p_test[0] EQ 1),(p_test[0] EQ 2),(p_test[0] EQ 3),(p_test[0] EQ 4)]

nef            = 0L
nif            = 0L
neb            = 0L
nib            = 0L
mergedstre     = merge_themis_esa_structs(poynter_peeb)
IF (SIZE(mergedstre,/TYPE) EQ 8) THEN nef = N_ELEMENTS(mergedstre.FULL)
IF (SIZE(mergedstre,/TYPE) EQ 8) THEN neb = N_ELEMENTS(mergedstre.BURST)
mergedstri     = merge_themis_esa_structs(poynter_peib)
IF (SIZE(mergedstri,/TYPE) EQ 8) THEN nif = N_ELEMENTS(mergedstri.FULL)
IF (SIZE(mergedstri,/TYPE) EQ 8) THEN nib = N_ELEMENTS(mergedstri.BURST)

;;  EESA Full
IF (p_t_arr[0]) THEN IF (nef[0] GT 0) THEN peef_df_arr_a = mergedstre.FULL
IF (p_t_arr[1]) THEN IF (nef[0] GT 0) THEN peef_df_arr_b = mergedstre.FULL
IF (p_t_arr[2]) THEN IF (nef[0] GT 0) THEN peef_df_arr_c = mergedstre.FULL
IF (p_t_arr[3]) THEN IF (nef[0] GT 0) THEN peef_df_arr_d = mergedstre.FULL
IF (p_t_arr[4]) THEN IF (nef[0] GT 0) THEN peef_df_arr_e = mergedstre.FULL

;;  EESA Burst
IF (p_t_arr[0]) THEN IF (neb[0] GT 0) THEN peeb_df_arr_a = mergedstre.BURST
IF (p_t_arr[1]) THEN IF (neb[0] GT 0) THEN peeb_df_arr_b = mergedstre.BURST
IF (p_t_arr[2]) THEN IF (neb[0] GT 0) THEN peeb_df_arr_c = mergedstre.BURST
IF (p_t_arr[3]) THEN IF (neb[0] GT 0) THEN peeb_df_arr_d = mergedstre.BURST
IF (p_t_arr[4]) THEN IF (neb[0] GT 0) THEN peeb_df_arr_e = mergedstre.BURST


;;  IESA Full
IF (p_t_arr[0]) THEN IF (nif[0] GT 0) THEN peif_df_arr_a = mergedstri.FULL
IF (p_t_arr[1]) THEN IF (nif[0] GT 0) THEN peif_df_arr_b = mergedstri.FULL
IF (p_t_arr[2]) THEN IF (nif[0] GT 0) THEN peif_df_arr_c = mergedstri.FULL
IF (p_t_arr[3]) THEN IF (nif[0] GT 0) THEN peif_df_arr_d = mergedstri.FULL
IF (p_t_arr[4]) THEN IF (nif[0] GT 0) THEN peif_df_arr_e = mergedstri.FULL

;;  IESA Burst
IF (p_t_arr[0]) THEN IF (nib[0] GT 0) THEN peib_df_arr_a = mergedstri.BURST
IF (p_t_arr[1]) THEN IF (nib[0] GT 0) THEN peib_df_arr_b = mergedstri.BURST
IF (p_t_arr[2]) THEN IF (nib[0] GT 0) THEN peib_df_arr_c = mergedstri.BURST
IF (p_t_arr[3]) THEN IF (nib[0] GT 0) THEN peib_df_arr_d = mergedstri.BURST
IF (p_t_arr[4]) THEN IF (nib[0] GT 0) THEN peib_df_arr_e = mergedstri.BURST

;;  Inform user of defined parameters
HELP, peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e
HELP, peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e
HELP, peef_df_arr_a,peef_df_arr_b,peef_df_arr_c,peef_df_arr_d,peef_df_arr_e
HELP, peif_df_arr_a,peif_df_arr_b,peif_df_arr_c,peif_df_arr_d,peif_df_arr_e

;;  Combine Full and Burst
tests          = [(N_ELEMENTS(peef_df_arr_a) GT 0),$
                  (N_ELEMENTS(peef_df_arr_b) GT 0),$
                  (N_ELEMENTS(peef_df_arr_c) GT 0),$
                  (N_ELEMENTS(peef_df_arr_d) GT 0),$
                  (N_ELEMENTS(peef_df_arr_e) GT 0)]
IF (p_t_arr[0]) THEN IF (tests[0]) THEN peeb_df_arr_a = [peeb_df_arr_a,peef_df_arr_a]
IF (p_t_arr[1]) THEN IF (tests[1]) THEN peeb_df_arr_b = [peeb_df_arr_b,peef_df_arr_b]
IF (p_t_arr[2]) THEN IF (tests[2]) THEN peeb_df_arr_c = [peeb_df_arr_c,peef_df_arr_c]
IF (p_t_arr[3]) THEN IF (tests[3]) THEN peeb_df_arr_d = [peeb_df_arr_d,peef_df_arr_d]
IF (p_t_arr[4]) THEN IF (tests[4]) THEN peeb_df_arr_e = [peeb_df_arr_e,peef_df_arr_e]
tests          = [(N_ELEMENTS(peif_df_arr_a) GT 0),$
                  (N_ELEMENTS(peif_df_arr_b) GT 0),$
                  (N_ELEMENTS(peif_df_arr_c) GT 0),$
                  (N_ELEMENTS(peif_df_arr_d) GT 0),$
                  (N_ELEMENTS(peif_df_arr_e) GT 0)]
IF (p_t_arr[0]) THEN IF (tests[0]) THEN peib_df_arr_a = [peib_df_arr_a,peif_df_arr_a]
IF (p_t_arr[1]) THEN IF (tests[1]) THEN peib_df_arr_b = [peib_df_arr_b,peif_df_arr_b]
IF (p_t_arr[2]) THEN IF (tests[2]) THEN peib_df_arr_c = [peib_df_arr_c,peif_df_arr_c]
IF (p_t_arr[3]) THEN IF (tests[3]) THEN peib_df_arr_d = [peib_df_arr_d,peif_df_arr_d]
IF (p_t_arr[4]) THEN IF (tests[4]) THEN peib_df_arr_e = [peib_df_arr_e,peif_df_arr_e]
IF (TOTAL(tests) GT 0) THEN smid_fnm = '_Both_THEMIS_' ELSE smid_fnm = '_Burst_THEMIS_'

;;----------------------------------------------------------------------------------------
;;  Use Generalized Save Commands
;;----------------------------------------------------------------------------------------
enames         = 'EESA'+smid_fnm[0]+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = 'IESA'+smid_fnm[0]+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'

ei_str         = ['e','i']
inst_str       = 'pe'+ei_str+'b_df_arr_'
ei_suffx       = ',FILENAME='+ei_str+'names[0]'
exc_str_ei     = 'SAVE,'+inst_str+sc[0]+ei_suffx

;;----------------------------------------------------------------------------------------
;;  Save ESA DF IDL Data Structures
;;----------------------------------------------------------------------------------------
;;   Save Electrons
test_e         = EXECUTE(exc_str_ei[0])
;;   Save Ions
test_i         = EXECUTE(exc_str_ei[1])

DELVAR,peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e
DELVAR,peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e
DELVAR,testj,temp,p_t_arr,p_test,mergedstre,mergedstri
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------











;;----------------------------------------------------------------------------------------
;;  Save ESA DF IDL Data Structures
;;----------------------------------------------------------------------------------------
;nef            = N_ELEMENTS(poynter_peeb.FULL)
;nif            = N_ELEMENTS(poynter_peib.FULL)
;neb            = N_ELEMENTS(poynter_peeb.BURST)
;nib            = N_ELEMENTS(poynter_peib.BURST)
;all_scs        = ['a','b','c','d','e']
;p_test         = WHERE(all_scs EQ sc[0],pt)
;p_t_arr        = [(p_test[0] EQ 0),(p_test[0] EQ 1),(p_test[0] EQ 2),(p_test[0] EQ 3),(p_test[0] EQ 4)]
;
;;;  EESA Full
;FOR j=0L, nef[0] - 1L DO BEGIN                                                                              $
;  temp  = *(poynter_peeb.FULL)[j]                                                                         & $
;  testj = (j[0] EQ 0)                                                                                     & $
;  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peef_df_arr_a = temp ELSE peef_df_arr_a = [peef_df_arr_a,temp]  & $ ;;  Probe A
;  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peef_df_arr_b = temp ELSE peef_df_arr_b = [peef_df_arr_b,temp]  & $ ;;  Probe B
;  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peef_df_arr_c = temp ELSE peef_df_arr_c = [peef_df_arr_c,temp]  & $ ;;  Probe C
;  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peef_df_arr_d = temp ELSE peef_df_arr_d = [peef_df_arr_d,temp]  & $ ;;  Probe D
;  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peef_df_arr_e = temp ELSE peef_df_arr_e = [peef_df_arr_e,temp]      ;;  Probe E
;
;;;  EESA Burst
;FOR j=0L, neb[0] - 1L DO BEGIN                                                                              $
;  temp  = *(poynter_peeb.BURST)[j]                                                                        & $
;  testj = (j[0] EQ 0)                                                                                     & $
;  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peeb_df_arr_a = temp ELSE peeb_df_arr_a = [peeb_df_arr_a,temp]  & $ ;;  Probe A
;  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peeb_df_arr_b = temp ELSE peeb_df_arr_b = [peeb_df_arr_b,temp]  & $ ;;  Probe B
;  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peeb_df_arr_c = temp ELSE peeb_df_arr_c = [peeb_df_arr_c,temp]  & $ ;;  Probe C
;  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peeb_df_arr_d = temp ELSE peeb_df_arr_d = [peeb_df_arr_d,temp]  & $ ;;  Probe D
;  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peeb_df_arr_e = temp ELSE peeb_df_arr_e = [peeb_df_arr_e,temp]      ;;  Probe E
;
;;;  IESA Full
;FOR j=0L, nif[0] - 1L DO BEGIN                                                                              $
;  temp  = *(poynter_peib.FULL)[j]                                                                         & $
;  testj = (j[0] EQ 0)                                                                                     & $
;  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peif_df_arr_a = temp ELSE peif_df_arr_a = [peif_df_arr_a,temp]  & $ ;;  Probe A
;  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peif_df_arr_b = temp ELSE peif_df_arr_b = [peif_df_arr_b,temp]  & $ ;;  Probe B
;  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peif_df_arr_c = temp ELSE peif_df_arr_c = [peif_df_arr_c,temp]  & $ ;;  Probe C
;  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peif_df_arr_d = temp ELSE peif_df_arr_d = [peif_df_arr_d,temp]  & $ ;;  Probe D
;  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peif_df_arr_e = temp ELSE peif_df_arr_e = [peif_df_arr_e,temp]      ;;  Probe E
;
;;;  IESA Burst
;FOR j=0L, nib[0] - 1L DO BEGIN                                                                              $
;  temp  = *(poynter_peib.BURST)[j]                                                                        & $
;  testj = (j[0] EQ 0)                                                                                     & $
;  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peib_df_arr_a = temp ELSE peib_df_arr_a = [peib_df_arr_a,temp]  & $ ;;  Probe A
;  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peib_df_arr_b = temp ELSE peib_df_arr_b = [peib_df_arr_b,temp]  & $ ;;  Probe B
;  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peib_df_arr_c = temp ELSE peib_df_arr_c = [peib_df_arr_c,temp]  & $ ;;  Probe C
;  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peib_df_arr_d = temp ELSE peib_df_arr_d = [peib_df_arr_d,temp]  & $ ;;  Probe D
;  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peib_df_arr_e = temp ELSE peib_df_arr_e = [peib_df_arr_e,temp]      ;;  Probe E
;
;HELP, peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e
;HELP, peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e
;HELP, peef_df_arr_a,peef_df_arr_b,peef_df_arr_c,peef_df_arr_d,peef_df_arr_e
;HELP, peif_df_arr_a,peif_df_arr_b,peif_df_arr_c,peif_df_arr_d,peif_df_arr_e
;
;;;  Combine Full and Burst
;tests          = [(N_ELEMENTS(peef_df_arr_a) GT 0),$
;                  (N_ELEMENTS(peef_df_arr_b) GT 0),$
;                  (N_ELEMENTS(peef_df_arr_c) GT 0),$
;                  (N_ELEMENTS(peef_df_arr_d) GT 0),$
;                  (N_ELEMENTS(peef_df_arr_e) GT 0)]
;IF (p_t_arr[0]) THEN IF (tests[0]) THEN peeb_df_arr_a = [peeb_df_arr_a,peef_df_arr_a]
;IF (p_t_arr[1]) THEN IF (tests[1]) THEN peeb_df_arr_b = [peeb_df_arr_b,peef_df_arr_b]
;IF (p_t_arr[2]) THEN IF (tests[2]) THEN peeb_df_arr_c = [peeb_df_arr_c,peef_df_arr_c]
;IF (p_t_arr[3]) THEN IF (tests[3]) THEN peeb_df_arr_d = [peeb_df_arr_d,peef_df_arr_d]
;IF (p_t_arr[4]) THEN IF (tests[4]) THEN peeb_df_arr_e = [peeb_df_arr_e,peef_df_arr_e]
;IF (p_t_arr[0]) THEN IF (tests[0]) THEN peib_df_arr_a = [peib_df_arr_a,peif_df_arr_a]
;IF (p_t_arr[1]) THEN IF (tests[1]) THEN peib_df_arr_b = [peib_df_arr_b,peif_df_arr_b]
;IF (p_t_arr[2]) THEN IF (tests[2]) THEN peib_df_arr_c = [peib_df_arr_c,peif_df_arr_c]
;IF (p_t_arr[3]) THEN IF (tests[3]) THEN peib_df_arr_d = [peib_df_arr_d,peif_df_arr_d]
;IF (p_t_arr[4]) THEN IF (tests[4]) THEN peib_df_arr_e = [peib_df_arr_e,peif_df_arr_e]
;IF (TOTAL(tests) GT 0) THEN smid_fnm = '_Both_THEMIS_' ELSE smid_fnm = '_Burst_THEMIS_'
;
;;;  Generalized Save Commands
;enames         = 'EESA'+smid_fnm[0]+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
;inames         = 'IESA'+smid_fnm[0]+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
;
;ei_str         = ['e','i']
;inst_str       = 'pe'+ei_str+'b_df_arr_'
;ei_suffx       = ',FILENAME='+ei_str+'names[0]'
;exc_str_ei     = 'SAVE,'+inst_str+sc[0]+ei_suffx
;
;;;   Save Electrons
;test_e         = EXECUTE(exc_str_ei[0])
;;;   Save Ions
;test_i         = EXECUTE(exc_str_ei[1])
;
;DELVAR,peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e
;DELVAR,peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e
;DELVAR,testj,temp,p_t_arr,p_test

