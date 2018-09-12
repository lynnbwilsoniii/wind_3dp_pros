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
;;  Potential Interesting VDFs:  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe A
testp_a        = (sc[0] EQ 'a')

;;  Probe B
testp_b        = (sc[0] EQ 'b')

;;  Probe C
testp_c        = (sc[0] EQ 'c')
testd_c        = WHERE([(tdate[0] EQ '2008-06-21'),(tdate[0] EQ '2008-06-26'),$
                        (tdate[0] EQ '2008-07-07'),(tdate[0] EQ '2008-07-14'),$
                        (tdate[0] EQ '2008-07-14'),(tdate[0] EQ '2008-07-14'),$
                        (tdate[0] EQ '2008-07-14'),(tdate[0] EQ '2008-07-15'),$
                        (tdate[0] EQ '2008-07-15'),(tdate[0] EQ '2008-07-15'),$
                        (tdate[0] EQ '2008-08-11'),(tdate[0] EQ '2008-08-11'),$
                        (tdate[0] EQ '2008-08-11'),(tdate[0] EQ '2008-08-11'),$
                        (tdate[0] EQ '2008-08-12'),(tdate[0] EQ '2008-08-19'),$
                        (tdate[0] EQ '2008-08-19'),(tdate[0] EQ '2008-08-19'),$
                        (tdate[0] EQ '2008-08-22'),(tdate[0] EQ '2008-09-08'),$
                        (tdate[0] EQ '2008-09-08'),(tdate[0] EQ '2008-09-08'),$
                        (tdate[0] EQ '2008-09-09'),(tdate[0] EQ '2008-09-16'),$
                        (tdate[0] EQ '2008-10-03'),(tdate[0] EQ '2008-10-06'),$
                        (tdate[0] EQ '2008-10-09'),(tdate[0] EQ '2008-10-12'),$
                        (tdate[0] EQ '2008-10-20'),(tdate[0] EQ '2008-10-22'),$
                        (tdate[0] EQ '2008-10-29'),(tdate[0] EQ '2009-07-12'),$
                        (tdate[0] EQ '2009-07-12'),(tdate[0] EQ '2009-07-15'),$
                        (tdate[0] EQ '2009-07-16'),(tdate[0] EQ '2009-07-16'),$
                        (tdate[0] EQ '2009-07-25'),(tdate[0] EQ '2009-07-26'),$
                        (tdate[0] EQ '2009-07-26'),(tdate[0] EQ '2009-07-26'),$
                        (tdate[0] EQ '2009-07-26'),(tdate[0] EQ '2009-07-26'),$
                        (tdate[0] EQ '2009-09-06'),(tdate[0] EQ '2009-10-02'),$
                        (tdate[0] EQ '2009-10-05'),(tdate[0] EQ '2009-10-05'),$
                        (tdate[0] EQ '2009-10-05'),(tdate[0] EQ '2009-10-05'),$
                        (tdate[0] EQ '2009-10-13'),(tdate[0] EQ '2009-10-13')],tdc)
IF (tdc[0] GT 0) THEN                                             $
  times_int     = ([['2008-06-21/07:21:00','2008-06-21/07:23:00'],$
                    ['2008-06-26/21:12:00','2008-06-26/21:14:00'],$
                    ['2008-07-07/05:21:00','2008-07-07/05:23:00'],$
                    ['2008-07-14/11:59:00','2008-07-14/15:01:00'],$
                    ['2008-07-14/20:03:00','2008-07-14/20:05:00'],$
                    ['2008-07-14/21:57:00','2008-07-14/21:59:00'],$
                    ['2008-07-14/23:25:00','2008-07-14/23:59:59'],$
                    ['2008-07-15/08:53:00','2008-07-15/08:55:00'],$
                    ['2008-07-15/09:13:00','2008-07-15/09:15:00'],$
                    ['2008-07-15/12:45:00','2008-07-15/12:47:00'],$
                    ['2008-08-11/05:08:00','2008-08-11/05:10:00'],$
                    ['2008-08-11/05:20:00','2008-08-11/05:22:00'],$
                    ['2008-08-11/05:28:00','2008-08-11/05:30:00'],$
                    ['2008-08-11/18:49:00','2008-08-11/18:51:00'],$
                    ['2008-08-12/01:05:00','2008-08-12/01:07:00'],$
                    ['2008-08-19/07:53:00','2008-08-19/07:55:00'],$
                    ['2008-08-19/12:49:00','2008-08-19/12:51:00'],$
                    ['2008-08-19/23:38:00','2008-08-19/23:40:00'],$
                    ['2008-08-22/22:18:00','2008-08-22/22:20:00'],$
                    ['2008-09-08/10:56:00','2008-09-08/10:58:00'],$
                    ['2008-09-08/17:01:00','2008-09-08/17:03:00'],$
                    ['2008-09-08/20:26:00','2008-09-08/20:28:00'],$
                    ['2008-09-09/19:26:00','2008-09-09/19:28:00'],$
                    ['2008-09-16/02:14:00','2008-09-16/02:16:00'],$
                    ['2008-10-03/19:34:00','2008-10-03/19:36:00'],$
                    ['2008-10-06/10:18:00','2008-10-06/10:20:00'],$
                    ['2008-10-09/23:30:00','2008-10-09/23:32:00'],$
                    ['2008-10-12/11:01:00','2008-10-12/11:03:00'],$
                    ['2008-10-20/07:58:00','2008-10-20/08:00:00'],$
                    ['2008-10-22/09:38:00','2008-10-22/09:40:00'],$
                    ['2008-10-29/22:13:00','2008-10-29/22:15:00'],$
                    ['2009-07-12/03:25:00','2009-07-12/03:27:00'],$
                    ['2009-07-12/03:51:00','2009-07-12/03:53:00'],$
                    ['2009-07-15/23:58:00','2009-07-16/00:00:00'],$
                    ['2009-07-16/07:14:00','2009-07-16/07:16:00'],$
                    ['2009-07-16/09:53:00','2009-07-16/09:55:00'],$
                    ['2009-07-25/22:30:00','2009-07-25/22:32:00'],$
                    ['2009-07-26/05:20:00','2009-07-26/05:22:00'],$
                    ['2009-07-26/05:42:00','2009-07-26/05:44:00'],$
                    ['2009-07-26/05:43:00','2009-07-26/05:45:00'],$
                    ['2009-07-26/09:34:00','2009-07-26/09:36:00'],$
                    ['2009-07-26/15:13:00','2009-07-26/15:15:00'],$
                    ['2009-09-06/12:44:00','2009-09-06/12:46:00'],$
                    ['2009-10-02/20:39:00','2009-10-02/20:41:00'],$
                    ['2009-10-05/13:54:00','2009-10-05/13:56:00'],$
                    ['2009-10-05/14:03:00','2009-10-05/14:05:00'],$
                    ['2009-10-05/14:13:00','2009-10-05/14:15:00'],$
                    ['2009-10-05/14:23:00','2009-10-05/14:25:00'],$
                    ['2009-10-13/01:33:00','2009-10-13/01:35:00'],$
                    ['2009-10-13/01:38:00','2009-10-13/01:40:00'] ])[*,testd_c]

;;  Probe D
testp_d        = (sc[0] EQ 'd')

;;  Probe E
testp_e        = (sc[0] EQ 'e')

;;  Check on results
IF (SIZE(times_int,/TYPE) EQ 7) THEN times_int = REFORM(times_int)
IF (SIZE(times_int,/TYPE) EQ 7) THEN tr_jj     = minmax(time_double(times_int)) ELSE tr_jj = time_double(tr_00)
;;----------------------------------------------------------------------------------------
;;  Find all relevant data
;;----------------------------------------------------------------------------------------
;;  Restore TPLOT session
cur_wdir       = FILE_EXPAND_PATH(FILE_DIRNAME('',/MARK_DIRECTORY))
;;  Check for trailing '/'
ll             = STRMID(cur_wdir[0], STRLEN(cur_wdir[0]) - 1L,1L)
test_ll        = (ll[0] NE slash[0])
IF (test_ll[0]) THEN cur_wdir = cur_wdir[0]+slash[0]
;;  Define location of IDL save files
th_data_dir    = cur_wdir[0]+'IDL_stuff'+slash[0]+'themis_data_dir'+slash[0]
tpnsave_dir    = th_data_dir[0]+'themis_tplot_save'
esasave_dir    = th_data_dir[0]+'themis_esa_save'+slash[0]+tdate[0]
;;  Define file names for the IDL save files
tpn_fpref      = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = tpn_fpref[0]+tsuffx[0]+'.tplot'
enames         = 'EESA_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames         = 'IESA_*_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
;;  Find IDL save files
tpn__file      = FILE_SEARCH(tpnsave_dir[0],fname[0])
eesa_file      = FILE_SEARCH(esasave_dir[0],enames[0])
iesa_file      = FILE_SEARCH(esasave_dir[0],inames[0])
;;  Define tests
test_tpnf      = (tpn__file[0] NE '')
;;  If file was not found, try again without specific time range
IF (test_tpnf[0] EQ 0) THEN fname     = tpn_fpref[0]+tdate[0]+'*.tplot'
IF (test_tpnf[0] EQ 0) THEN tpn__file = FILE_SEARCH(tpnsave_dir[0],fname[0])
IF (test_tpnf[0] EQ 0) THEN test_tpnf = (tpn__file[0] NE '')
test_eesa      = (eesa_file[0] NE '')
test_iesa      = (iesa_file[0] NE '')
;;  If file was not found, try again with slightly different name
IF (test_tpnf[0] EQ 0) THEN tpn_fpref = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_*'
IF (test_tpnf[0] EQ 0) THEN fname     = tpn_fpref[0]+tdate[0]+'*.tplot'
IF (test_tpnf[0] EQ 0) THEN tpn__file = FILE_SEARCH(tpnsave_dir[0],fname[0])
IF (test_tpnf[0] EQ 0) THEN test_tpnf = (tpn__file[0] NE '')
;;----------------------------------------------------------------------------------------
;;  Load TPLOT data
;;----------------------------------------------------------------------------------------
IF (test_tpnf[0] EQ 0) THEN STOP
IF (test_tpnf[0]) THEN tplot_restore,FILENAME=tpn__file[0],VERBOSE=0
;;  Set defaults

IF (test_tpnf[0]) THEN !themis.VERBOSE = 2
IF (test_tpnf[0]) THEN tplot_options,'VERBOSE',2
IF (test_tpnf[0]) THEN options,tnames(),'LABFLAG',2,/DEF
;;  Remove color table from default options
IF (test_tpnf[0]) THEN options,tnames(),'COLOR_TABLE',/DEF
IF (test_tpnf[0]) THEN options,tnames(),'COLOR_TABLE'
IF (test_tpnf[0]) THEN tplot_options,'NO_INTERP',0  ;;  Allow interpolation in spectrograms
;;  Define tick marks
IF (test_tpnf[0]) THEN coord_gse      = 'gse'
IF (test_tpnf[0]) THEN pos_gse        = tnames(scpref[0]+'state_pos_'+coord_gse[0]+'_*')
IF (test_tpnf[0]) THEN rad_pos_tpnm   = tnames(scpref[0]+'_Rad')
IF (test_tpnf[0]) THEN names2         = [pos_gse,rad_pos_tpnm[0]]
IF (test_tpnf[0]) THEN tplot_options,VAR_LABEL=names2
IF (test_tpnf[0]) THEN nnw            = tnames()
IF (test_tpnf[0]) THEN options,nnw,'YSTYLE',1
IF (test_tpnf[0]) THEN options,nnw,'PANEL_SIZE',2.
IF (test_tpnf[0]) THEN options,nnw,'XMINOR',5
IF (test_tpnf[0]) THEN options,nnw,'XTICKLEN',0.04
IF (test_tpnf[0]) THEN options,nnw,'YTICKLEN',0.01

;;  Open window
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*9d-1
WINDOW,0,RETAIN=2,XSIZE=wsz[0],YSIZE=wsz[1],TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'

;;  Plot fgh
IF (test_tpnf[0]) THEN magname        = scpref[0]+'fgh_'+coord_gse[0]
IF (test_tpnf[0]) THEN fgmnm          = scpref[0]+'fgh_'+['mag',coord_gse[0]]
IF (test_tpnf[0]) THEN tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;;  Load ESA data
;;----------------------------------------------------------------------------------------
IF (test_eesa[0]) THEN RESTORE,eesa_file[0]
IF (test_iesa[0]) THEN RESTORE,iesa_file[0]

IF (test_iesa[0] AND testp_a[0]) THEN dat_i = peib_df_arr_a
IF (test_iesa[0] AND testp_b[0]) THEN dat_i = peib_df_arr_b
IF (test_iesa[0] AND testp_c[0]) THEN dat_i = peib_df_arr_c
IF (test_iesa[0] AND testp_d[0]) THEN dat_i = peib_df_arr_d
IF (test_iesa[0] AND testp_e[0]) THEN dat_i = peib_df_arr_e

IF (test_eesa[0] AND testp_a[0]) THEN dat_e = peeb_df_arr_a
IF (test_eesa[0] AND testp_b[0]) THEN dat_e = peeb_df_arr_b
IF (test_eesa[0] AND testp_c[0]) THEN dat_e = peeb_df_arr_c
IF (test_eesa[0] AND testp_d[0]) THEN dat_e = peeb_df_arr_d
IF (test_eesa[0] AND testp_e[0]) THEN dat_e = peeb_df_arr_e

n_i            = N_ELEMENTS(dat_i)
n_e            = N_ELEMENTS(dat_e)
PRINT,';;  Ni = ', n_i[0]
PRINT,';;  Ne = ', n_e[0]
;;----------------------------------------------------------------------------------------
;;  Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
velname        = tnames(scpref[0]+'peib_velocity_'+coord_gse[0])
spperi         = tnames(scpref[0]+'state_spinper')
magn_0         = tnames(scpref[0]+'fgs_'+coord_gse[0])
magn_1         = tnames(scpref[0]+'fgl_'+coord_gse[0])
magn_2         = tnames(scpref[0]+'fgh_'+coord_gse[0])
scname         = tnames(scpref[0]+'peeb_sc_pot')
scnami         = tnames(scpref[0]+'peib_sc_pot')
IF (magn_2[0]  NE '') THEN magname = magn_2[0]
IF (magname[0] EQ '') THEN magname = magn_1[0]
IF (magname[0] EQ '') THEN magname = magn_0[0]

;;  Add additional structure tags to IESA structures
modify_themis_esa_struc,dat_i
;;  Add SC potential to IESA structures
add_scpot,dat_i,scnami[0]
;;  Rotate IESA structures (theta,phi)-angles DSL --> GSE
dat_igse       = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname[0],VEL_NAME=velname[0]
;;  Check that MAGF tag is defined
add_magf2,dat_igse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_igse,magn_2[0],/LEAVE_ALONE
;;  Check that VSW tag is defined
add_vsw2,dat_igse,velname[0],/LEAVE_ALONE


;;  Add additional structure tags to EESA structures
modify_themis_esa_struc,dat_e
;;  Add SC potential to EESA structures
add_scpot,dat_e,scname[0]
;;  Rotate IESA structures (theta,phi)-angles DSL --> GSE
dat_egse       = dat_e
rotate_esa_thetaphi_to_gse,dat_egse,MAGF_NAME=magname[0],VEL_NAME=velname[0]
;;  Check that MAGF tag is defined
add_magf2,dat_egse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_egse,magn_2[0],/LEAVE_ALONE
;;  Check that VSW tag is defined
add_vsw2,dat_egse,velname[0],/LEAVE_ALONE

PRINT,''
PRINT,';;  Successfully loaded data for Probe-'+scu[0]+' on '+tdate[0]
PRINT,''













