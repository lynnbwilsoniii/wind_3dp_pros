;;----------------------------------------------------------------------------------------
;;  Status Bar Legend
;;
;;    yellow       :  slow survey
;;    red          :  fast survey
;;    black below  :  particle burst
;;    black above  :  wave burst
;;
;;----------------------------------------------------------------------------------------

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
;;  Compile necessary routines
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  Potential Interesting VDFs:  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe A

;;  Probe B

probe          = 'b'
tdate          = '2008-07-14'
date           = '071408'

probe          = 'b'
tdate          = '2008-07-22'
date           = '072208'

probe          = 'b'
tdate          = '2008-07-26'
date           = '072608'

probe          = 'b'
tdate          = '2008-07-30'
date           = '073008'

probe          = 'b'
tdate          = '2008-08-07'
date           = '080708'

probe          = 'b'
tdate          = '2008-08-11'
date           = '081108'

probe          = 'b'
tdate          = '2008-08-23'
date           = '082308'

probe          = 'b'
tdate          = '2009-07-13'
date           = '071309'

;;  Probe C
;probe          = 'c'
;tdate          = '2008-06-21'
;date           = '062108'

;probe          = 'c'
;tdate          = '2008-06-26'
;date           = '062608'

probe          = 'c'
tdate          = '2008-07-14'
date           = '071408'

;probe          = 'c'
;tdate          = '2008-07-15'
;date           = '071508'

;probe          = 'c'
;tdate          = '2008-08-11'
;date           = '081108'

probe          = 'c'
tdate          = '2008-08-12'
date           = '081208'

probe          = 'c'
tdate          = '2008-08-19'
date           = '081908'

;probe          = 'c'
;tdate          = '2008-08-22'
;date           = '082208'

probe          = 'c'
tdate          = '2008-09-08'
date           = '090808'

;probe          = 'c'
;tdate          = '2008-09-09'
;date           = '090908'

probe          = 'c'
tdate          = '2008-09-16'
date           = '091608'

probe          = 'c'
tdate          = '2008-10-03'
date           = '100308'

;probe          = 'c'
;tdate          = '2008-10-06'
;date           = '100608'

probe          = 'c'
tdate          = '2008-10-09'
date           = '100908'

probe          = 'c'
tdate          = '2008-10-12'
date           = '101208'

;probe          = 'c'
;tdate          = '2008-10-20'
;date           = '102008'

;probe          = 'c'
;tdate          = '2008-10-22'
;date           = '102208'

probe          = 'c'
tdate          = '2008-10-29'
date           = '102908'

;probe          = 'c'
;tdate          = '2009-07-12'
;date           = '071209'

;probe          = 'c'
;tdate          = '2009-07-15'
;date           = '071509'

;probe          = 'c'
;tdate          = '2009-07-16'
;date           = '071609'

probe          = 'c'
tdate          = '2009-07-25'
date           = '072509'

;probe          = 'c'
;tdate          = '2009-07-26'
;date           = '072609'

;probe          = 'c'
;tdate          = '2009-09-06'
;date           = '090609'

;probe          = 'c'
;tdate          = '2009-10-02'
;date           = '100209'

;probe          = 'c'
;tdate          = '2009-10-05'
;date           = '100509'

;probe          = 'c'
;tdate          = '2009-10-13'
;date           = '101309'

;;  Probe D

;;  Probe E


;;---------------------------------------------
;;  Interesting time ranges [for THEMIS-C]
;;---------------------------------------------
;;  YYYY-MM-DD/hh:mm  YYYY-MM-DD/hh:mm
;;=============================================
;;  2008-06-21/07:21  2008-06-21/07:23
;;  2008-06-26/21:12  2008-06-26/21:14
;;  2008-07-07/05:21  2008-07-07/05:23
;;  2008-07-14/14:59  2008-07-14/15:01
;;  2008-07-14/20:03  2008-07-14/20:05
;;  2008-07-14/21:57  2008-07-14/21:59
;;  2008-07-14/23:25  2008-07-14/23:27
;;  2008-07-15/08:53  2008-07-15/08:55
;;  2008-07-15/09:13  2008-07-15/09:15
;;  2008-07-15/12:45  2008-07-15/12:47
;;  2008-08-11/05:08  2008-08-11/05:10
;;  2008-08-11/05:20  2008-08-11/05:22
;;  2008-08-11/05:28  2008-08-11/05:30
;;  2008-08-11/18:49  2008-08-11/18:51
;;  2008-08-12/01:05  2008-08-12/01:07
;;  2008-08-19/07:53  2008-08-19/07:55
;;  2008-08-19/12:49  2008-08-19/12:51
;;  2008-08-19/23:38  2008-08-19/23:40
;;  2008-08-22/22:18  2008-08-22/22:20
;;  2008-09-08/10:56  2008-09-08/10:58
;;  2008-09-08/17:01  2008-09-08/17:03
;;  2008-09-08/20:26  2008-09-08/20:28
;;  2008-09-09/19:26  2008-09-09/19:28
;;  2008-09-16/02:14  2008-09-16/02:16
;;  2008-10-03/19:34  2008-10-03/19:36
;;  2008-10-06/10:18  2008-10-06/10:20
;;  2008-10-09/23:30  2008-10-09/23:32
;;  2008-10-12/11:01  2008-10-12/11:03
;;  2008-10-20/07:58  2008-10-20/08:00
;;  2008-10-22/09:38  2008-10-22/09:40
;;  2008-10-29/22:13  2008-10-29/22:15
;;  2009-07-12/03:25  2009-07-12/03:27
;;  2009-07-12/03:51  2009-07-12/03:53
;;  2009-07-15/23:58  2009-07-16/00:00
;;  2009-07-16/07:14  2009-07-16/07:16
;;  2009-07-16/09:53  2009-07-16/09:55
;;  2009-07-25/22:30  2009-07-25/22:32
;;  2009-07-26/05:20  2009-07-26/05:22
;;  2009-07-26/05:42  2009-07-26/05:44
;;  2009-07-26/05:43  2009-07-26/05:45
;;  2009-07-26/09:34  2009-07-26/09:36
;;  2009-07-26/15:13  2009-07-26/15:15
;;  2009-09-06/12:44  2009-09-06/12:46
;;  2009-10-02/20:39  2009-10-02/20:41
;;  2009-10-05/13:54  2009-10-05/13:56
;;  2009-10-05/14:03  2009-10-05/14:05
;;  2009-10-05/14:13  2009-10-05/14:15
;;  2009-10-05/14:23  2009-10-05/14:25
;;  2009-10-13/01:33  2009-10-13/01:35
;;  2009-10-13/01:38  2009-10-13/01:40
;;---------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_and_save_themis_foreshock_eVDFs_batch.pro

;;  Manually zoom to time range including fgh
tlimit

;;  Define |Bo| for fgs, fgl, and fgh
coord_mag      = 'mag'
fgm_modes      = 'fg'+['s','l','h']
tpn_names      = scpref[0]+fgm_modes+'_'+coord_mag[0]
scname         = STRUPCASE(STRMID(scpref[0],0,3))
;;  Define structures for ps_quick_file.pro
tags           = 'T'+STRTRIM(STRING(LINDGEN(5),FORMAT='(I2.2)'),2)
fgs_str        = CREATE_STRUCT(tags,fgm_modes[0],'B','DC',coord_mag[0],'L2')
fgl_str        = CREATE_STRUCT(tags,fgm_modes[1],'B','DC',coord_mag[0],'L2')
fgh_str        = CREATE_STRUCT(tags,fgm_modes[2],'B','DC',coord_mag[0],'L2')
fstr           = [fgs_str,fgl_str,fgh_str]
ps_quick_file,SPACECRAFT=scname[0],FIELDS=fstr

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
;;  Default to loading entire day
tr_00          = tdate[0]+'/'+['00:00:00.000','23:59:59.999']

sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scu            = STRUPCASE(sc[0])
prefu          = STRUPCASE(pref[0])

themis_load_all_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00),$
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
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]
tplot_save,FILENAME=fname[0]
;;----------------------------------------------------------------------------------------
;;  Save ESA DF IDL Data Structures
;;----------------------------------------------------------------------------------------
nef            = N_ELEMENTS(poynter_peeb.FULL)
nif            = N_ELEMENTS(poynter_peib.FULL)
neb            = N_ELEMENTS(poynter_peeb.BURST)
nib            = N_ELEMENTS(poynter_peib.BURST)
all_scs        = ['a','b','c','d','e']
p_test         = WHERE(all_scs EQ sc[0],pt)
p_t_arr        = [(p_test[0] EQ 0),(p_test[0] EQ 1),(p_test[0] EQ 2),(p_test[0] EQ 3),(p_test[0] EQ 4)]

;;  EESA Full
FOR j=0L, nef[0] - 1L DO BEGIN                                                                              $
  temp  = *(poynter_peeb.FULL)[j]                                                                         & $
  testj = (j[0] EQ 0)                                                                                     & $
  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peef_df_arr_a = temp ELSE peef_df_arr_a = [peef_df_arr_a,temp]  & $ ;;  Probe A
  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peef_df_arr_b = temp ELSE peef_df_arr_b = [peef_df_arr_b,temp]  & $ ;;  Probe B
  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peef_df_arr_c = temp ELSE peef_df_arr_c = [peef_df_arr_c,temp]  & $ ;;  Probe C
  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peef_df_arr_d = temp ELSE peef_df_arr_d = [peef_df_arr_d,temp]  & $ ;;  Probe D
  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peef_df_arr_e = temp ELSE peef_df_arr_e = [peef_df_arr_e,temp]      ;;  Probe E

;;  EESA Burst
FOR j=0L, neb[0] - 1L DO BEGIN                                                                              $
  temp  = *(poynter_peeb.BURST)[j]                                                                        & $
  testj = (j[0] EQ 0)                                                                                     & $
  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peeb_df_arr_a = temp ELSE peeb_df_arr_a = [peeb_df_arr_a,temp]  & $ ;;  Probe A
  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peeb_df_arr_b = temp ELSE peeb_df_arr_b = [peeb_df_arr_b,temp]  & $ ;;  Probe B
  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peeb_df_arr_c = temp ELSE peeb_df_arr_c = [peeb_df_arr_c,temp]  & $ ;;  Probe C
  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peeb_df_arr_d = temp ELSE peeb_df_arr_d = [peeb_df_arr_d,temp]  & $ ;;  Probe D
  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peeb_df_arr_e = temp ELSE peeb_df_arr_e = [peeb_df_arr_e,temp]      ;;  Probe E

;;  IESA Full
FOR j=0L, nif[0] - 1L DO BEGIN                                                                              $
  temp  = *(poynter_peib.FULL)[j]                                                                         & $
  testj = (j[0] EQ 0)                                                                                     & $
  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peif_df_arr_a = temp ELSE peif_df_arr_a = [peif_df_arr_a,temp]  & $ ;;  Probe A
  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peif_df_arr_b = temp ELSE peif_df_arr_b = [peif_df_arr_b,temp]  & $ ;;  Probe B
  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peif_df_arr_c = temp ELSE peif_df_arr_c = [peif_df_arr_c,temp]  & $ ;;  Probe C
  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peif_df_arr_d = temp ELSE peif_df_arr_d = [peif_df_arr_d,temp]  & $ ;;  Probe D
  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peif_df_arr_e = temp ELSE peif_df_arr_e = [peif_df_arr_e,temp]      ;;  Probe E

;;  IESA Burst
FOR j=0L, nib[0] - 1L DO BEGIN                                                                              $
  temp  = *(poynter_peib.BURST)[j]                                                                        & $
  testj = (j[0] EQ 0)                                                                                     & $
  IF (p_t_arr[0]) THEN IF (testj[0]) THEN peib_df_arr_a = temp ELSE peib_df_arr_a = [peib_df_arr_a,temp]  & $ ;;  Probe A
  IF (p_t_arr[1]) THEN IF (testj[0]) THEN peib_df_arr_b = temp ELSE peib_df_arr_b = [peib_df_arr_b,temp]  & $ ;;  Probe B
  IF (p_t_arr[2]) THEN IF (testj[0]) THEN peib_df_arr_c = temp ELSE peib_df_arr_c = [peib_df_arr_c,temp]  & $ ;;  Probe C
  IF (p_t_arr[3]) THEN IF (testj[0]) THEN peib_df_arr_d = temp ELSE peib_df_arr_d = [peib_df_arr_d,temp]  & $ ;;  Probe D
  IF (p_t_arr[4]) THEN IF (testj[0]) THEN peib_df_arr_e = temp ELSE peib_df_arr_e = [peib_df_arr_e,temp]      ;;  Probe E

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
IF (p_t_arr[0]) THEN IF (tests[0]) THEN peib_df_arr_a = [peib_df_arr_a,peif_df_arr_a]
IF (p_t_arr[1]) THEN IF (tests[1]) THEN peib_df_arr_b = [peib_df_arr_b,peif_df_arr_b]
IF (p_t_arr[2]) THEN IF (tests[2]) THEN peib_df_arr_c = [peib_df_arr_c,peif_df_arr_c]
IF (p_t_arr[3]) THEN IF (tests[3]) THEN peib_df_arr_d = [peib_df_arr_d,peif_df_arr_d]
IF (p_t_arr[4]) THEN IF (tests[4]) THEN peib_df_arr_e = [peib_df_arr_e,peif_df_arr_e]
IF (TOTAL(tests) GT 0) THEN smid_fnm = '_Both_THEMIS_' ELSE smid_fnm = '_Burst_THEMIS_'

;;  Generalized Save Commands
enames         = 'EESA'+smid_fnm[0]+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = 'IESA'+smid_fnm[0]+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'

ei_str         = ['e','i']
inst_str       = 'pe'+ei_str+'b_df_arr_'
ei_suffx       = ',FILENAME='+ei_str+'names[0]'
exc_str_ei     = 'SAVE,'+inst_str+sc[0]+ei_suffx

;;   Save Electrons
test_e         = EXECUTE(exc_str_ei[0])
;;   Save Ions
test_i         = EXECUTE(exc_str_ei[1])

DELVAR,peeb_df_arr_a,peeb_df_arr_b,peeb_df_arr_c,peeb_df_arr_d,peeb_df_arr_e
DELVAR,peib_df_arr_a,peib_df_arr_b,peib_df_arr_c,peib_df_arr_d,peib_df_arr_e
DELVAR,testj,temp,p_t_arr,p_test
































