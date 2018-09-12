;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_e_data_2010-08-23_batch.pro

;;----------------------------------------------------------------------------------------
;;  Define instrument-dependent and coordinate basis strings
;;----------------------------------------------------------------------------------------
;;  instruments
mode_fgm       = ['fgs','fgl','fgh']
mode_efi       = 'ef'+['p','w']
mode_scm       = 'sc'+['p','w']

;;  coordinates
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_fac      = 'fac'

;;----------------------------------------------------------------------------------------
;;  Define TPLOT handles
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scpref         = pref[0]

;;  FGM TPLOT handles
fgm_midnm      = scpref[0]+mode_fgm[2]+'_'
fgh_mag_nm     = tnames(fgm_midnm[0]+'mag')
fgh_dsl_nm     = tnames(fgm_midnm[0]+coord_dsl[0])

;;  SCM TPLOT handles
scm_midnm      = '_cal_'
low__suffx     = '_LowPassFilt_*Hz'
high_suffx     = 'HighPassFilt_*Hz'
scw_dsl_nm     = tnames(scpref[0]+mode_scm[1]+scm_midnm[0]+coord_dsl[0]+'*')

;;  EFI TPLOT handles
efi_midnm      = '_cal_rmDCoffsets_'
low__suffx     = '_LowPassFilt_*Hz'
high_suffx     = 'HighPassFilt_*Hz'
efw_dsl_nm     = tnames(scpref[0]+mode_efi[1]+efi_midnm[0]+coord_dsl[0]+'*')










;;----------------------------------------------------------------------------------------
;;  Plot and save data
;;----------------------------------------------------------------------------------------
coord          = coord_dsl[0]

;;  EFI Plots
f_pref         = prefu[0]+'fgh-mag-'+coord[0]+'_efw-cal-rmDCoff-LP10-100Hz-HP500Hz-'+coord[0]+'_'
nna            = [fgh_mag_nm[0],fgh_dsl_nm[0],efw_dsl_nm]

;;  SCM Plots
f_pref         = prefu[0]+'fgh-mag-'+coord[0]+'_scw-cal-LP0.1-100-BP10-100Hz-BP100-500Hz-HP500Hz-'+coord[0]+'_'
nna            = [fgh_mag_nm[0],fgh_dsl_nm[0],scw_dsl_nm]


traz           = t_get_current_trange()
fnm_tra        = file_name_times(traz,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fnames         = f_pref[0]+ftime[0]
PRINT, fnames[0]

;  tplot,nna,TRANGE=traz
popen,fnames[0],/PORT
  tplot,nna,TRANGE=traz
pclose
  tplot,/NOM
tlimit,/LAST







































































