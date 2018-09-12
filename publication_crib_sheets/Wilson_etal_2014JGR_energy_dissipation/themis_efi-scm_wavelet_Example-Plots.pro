;;----------------------------------------------------------------------------------------
;; => Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;; => Electron mass [kg]
mp             = 1.6726217770d-27     ;; => Proton mass [kg]
ma             = 6.6446567500d-27     ;; => Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;; => Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;; => Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;; => Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;; => Fundamental charge [C]
kB             = 1.3806488000d-23     ;; => Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;; => Planck Constant [J s]
GG             = 6.6738400000d-11     ;; => Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;; => Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;; => Energy associated with 1 eV of energy [J]
;; => Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;; => Earth's Equitorial Radius [km]

;; => Compile necessary routines
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;; => Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  2009-07-13 [1 Crossing]
tdate          = '2009-07-13'
tr_00          = tdate[0]+'/'+['07:50:00','10:10:00']
date           = '071309'
probe          = 'b'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
tr_jj          = time_double(tdate[0]+'/'+['08:50:00.000','09:30:00.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = d
t_ramp2        = d
;;  Example wavelet times
tr_ww          = time_double(tdate[0]+'/'+['08:59:40.000','08:59:57.000'])
tr_whi         = time_double(tdate[0]+'/'+['08:59:51.200','08:59:51.600'])
tr_ecdi        = time_double(tdate[0]+'/'+['08:59:52.890','08:59:52.930'])

;;-------------------------------------
;;  2009-07-21 [1 Crossing]
;;-------------------------------------
tdate          = '2009-07-21'
tr_00          = tdate[0]+'/'+['14:00:00','23:00:00']
date           = '072109'
probe          = 'c'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
tr_jj          = time_double(tdate[0]+'/'+['19:09:30.000','19:29:24.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['19:24:47.704','19:24:49.509'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = d
t_ramp2        = d

;;-------------------------------------
;;  2009-07-23 [3 Crossings]
;;-------------------------------------
tdate          = '2009-07-23'
tr_00          = tdate[0]+'/'+['12:00:00','21:00:00']
date           = '072309'
probe          = 'c'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
tr_jj          = time_double(tdate[0]+'/'+['17:57:30.000','18:30:00.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['18:07:07.340','18:07:08.100'])
t_ramp_ra2     = time_double(tdate[0]+'/'+['18:24:24.910','18:24:49.450'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = MEAN(t_ramp_ra1,/NAN)
t_ramp2        = MEAN(t_ramp_ra2,/NAN)

;;-------------------------------------
;;  2009-09-26 [1 Crossing]
;;-------------------------------------
tdate          = '2009-09-26'
tr_00          = tdate[0]+'/'+['12:00:00','17:40:00']
date           = '092609'
probe          = 'a'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
tr_jj          = time_double(tdate[0]+'/'+['15:48:20.000','15:58:25.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['15:53:09.911','15:53:10.249'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = d
t_ramp2        = d
;;  Example wavelet times
tr_ww          = time_double(tdate[0]+'/'+['15:53:02.500','15:53:15.600'])
tr_esw0        = time_double(tdate[0]+'/'+['15:53:03.475','15:53:03.500'])  ;;  train of ESWs [efw, Int. 0]
tr_esw1        = time_double(tdate[0]+'/'+['15:53:04.474','15:53:04.503'])  ;;  train of ESWs [efw, Int. 0]
tr_esw2        = time_double(tdate[0]+'/'+['15:53:09.910','15:53:09.940'])  ;;  two      ESWs [efw, Int. 1]
tr_whi         = time_double(tdate[0]+'/'+['15:53:10.860','15:53:11.203'])  ;;  example whistlers [scw, Int. 1]
tr_ww1         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:15.590'])
tr_ww2         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:12.500'])

;;-------------------------------------
;;  2011-10-24 [2 Crossings]
;;-------------------------------------
tdate          = '2011-10-24'
tr_00          = tdate[0]+'/'+['16:00:00','23:59:59']
date           = '102411'
probe          = 'e'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
tr_jj          = time_double(tdate[0]+'/'+['18:00:00.000','23:59:59.000'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['18:31:56.880','18:31:57.290'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['23:28:14.596','23:28:16.086'])
t_ramp0        = MEAN(t_ramp_ra0,/NAN)
t_ramp1        = MEAN(t_ramp_ra1,/NAN)
t_ramp2        = d
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
;; => Restore TPLOT session
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]+'.tplot'
file           = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0


!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
options,tnames(),'LABFLAG',2,/DEF
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'
tplot_options,'NO_INTERP',0  ;;  Allow interpolation in spectrograms

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Bow Shock Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;; => Plot fgh
;;----------------------------------------------------------------------------------------
coord          = 'gse'
sc             = probe[0]
scpref         = 'th'+sc[0]+'_'
magname        = scpref[0]+'fgh_'+coord[0]
fgmnm          = scpref[0]+'fgh_'+['mag',coord[0]]

tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;; => Calculate Wavelets
;;----------------------------------------------------------------------------------------
coord_in       = 'fac'
scpref         = 'th'+sc[0]+'_'
fciflhfce_nm   = tnames(scpref[0]+'fgh_fci_flh_fce')
options,fciflhfce_nm[0],'YLOG'
options,fciflhfce_nm[0],'YLOG',1,/DEF
options,fciflhfce_nm[0],'COLORS'
options,fciflhfce_nm[0],'COLORS',/DEF
options,fciflhfce_nm[0],'THICK'
options,fciflhfce_nm[0],'THICK',2,/DEF


modes_pw       = ['p','w']
mode_efi       = 'ef'+modes_pw
mode_scm       = 'sc'+modes_pw
efw_midnm      = mode_efi[1]+'_cal_corrected_DownSampled_'+coord_in[0]
scw_midnm      = mode_scm[1]+'_cal_HighPass_'+coord_in[0]
scw_names      = tnames(scpref[0]+scw_midnm[0]+'_INT*')
efw_names      = tnames(scpref[0]+efw_midnm[0]+'_INT*')

tplot,[fgmnm,efw_names,scw_names],TRANGE=tr_ww
;;-----------------------------------------------------
;; => EFI Wavelets
;;-----------------------------------------------------
efw_names_x    = efw_names[*]+'_Bo_x_Xgse_x_Bo'
efw_names_y    = efw_names[*]+'_Bo_x_Xgse'
efw_names_z    = efw_names[*]+'_Bo'
in_names       = efw_names
out_name0      = [[efw_names_x],[efw_names_y],[efw_names_z]]
out_names      = out_name0

sc_name        = 'THEMIS-'+STRUPCASE(sc[0])
units          = 'mV/m'
instrum        = 'efi'
themis_load_wavelets,in_names,out_name0,COORD=coord_in[0],UNITS=units[0],$
                         INSTRUMENT=instrum[0],SPACECRAFT=sc_name[0]

options,REFORM(out_names[0,*]),'YRANGE'
options,REFORM(out_names[0,*]),'YRANGE',/DEF
options,REFORM(out_names[1,*]),'YRANGE'
options,REFORM(out_names[1,*]),'YRANGE',/DEF

efw_wave_nms_x   = efw_names_x[*]+'_wavelet'
efw_wave_nms_y   = efw_names_y[*]+'_wavelet'
efw_wave_nms_z   = efw_names_z[*]+'_wavelet'
all_efw_wave_nms = [efw_wave_nms_x,efw_wave_nms_y,efw_wave_nms_z]
IF (date EQ '071309') THEN wav_yra = [1d0,4d3]
IF (date EQ '071309') THEN efw_zra = [1d-4,1d0]

IF (date EQ '092609') THEN wav_yra = [1d0,4d3]
IF (date EQ '092609') THEN efw_zra = [1d-4,1d1]

IF (N_ELEMENTS(wav_yra) NE 0) THEN options,all_efw_wave_nms+'*','YRANGE'
IF (N_ELEMENTS(wav_yra) NE 0) THEN options,all_efw_wave_nms+'*','YRANGE',wav_yra,/DEF
IF (N_ELEMENTS(efw_zra) NE 0) THEN options,all_efw_wave_nms,'ZRANGE'
IF (N_ELEMENTS(efw_zra) NE 0) THEN options,all_efw_wave_nms,'ZRANGE',efw_zra,/DEF

options,all_efw_wave_nms+'*','YLOG'
options,all_efw_wave_nms+'*','YLOG',1,/DEF
IF (N_ELEMENTS(wav_yra) NE 0) THEN options,fciflhfce_nm[0],'YRANGE'
IF (N_ELEMENTS(wav_yra) NE 0) THEN options,fciflhfce_nm[0],'YRANGE',wav_yra,/DEF

;; set labels in case routine failed to do so
options,efw_wave_nms_x,'LABELS','(Bo x Xgse) x Bo',/DEF
options,efw_wave_nms_y,'LABELS','Bo x Xgse',/DEF
options,efw_wave_nms_z,'LABELS','Bo',/DEF

nna            = [fciflhfce_nm[0],efw_names_x[0],efw_wave_nms_x[0],efw_names_y[0],$
                  efw_wave_nms_y[0],efw_names_z[0],efw_wave_nms_z[0]]
tplot,nna,TRANGE=tr_ww

nna            = [fciflhfce_nm[0],efw_names_x[1],efw_wave_nms_x[1],efw_names_y[1],$
                  efw_wave_nms_y[1],efw_names_z[1],efw_wave_nms_z[1]]
tplot,nna,TRANGE=tr_ww

;;-----------------------------------------------------
;; => SCM Wavelets
;;-----------------------------------------------------
scw_names_x    = scw_names[*]+'_Bo_x_Xgse_x_Bo'
scw_names_y    = scw_names[*]+'_Bo_x_Xgse'
scw_names_z    = scw_names[*]+'_Bo'
in_names       = scw_names
out_name0      = [[scw_names_x],[scw_names_y],[scw_names_z]]
out_names      = out_name0

sc_name        = 'THEMIS-'+STRUPCASE(sc[0])
units          = 'nT'
instrum        = 'scm'
themis_load_wavelets,in_names,out_name0,COORD=coord_in[0],UNITS=units[0],$
                         INSTRUMENT=instrum[0],SPACECRAFT=sc_name[0]

scw_wave_nms_x   = scw_names_x[*]+'_wavelet'
scw_wave_nms_y   = scw_names_y[*]+'_wavelet'
scw_wave_nms_z   = scw_names_z[*]+'_wavelet'
all_scw_wave_nms = [scw_wave_nms_x,scw_wave_nms_y,scw_wave_nms_z]
IF (date EQ '071309') THEN wav_yra = [1d0,4d3]
IF (date EQ '071309') THEN scw_zra = [1d-8,1d-3]
IF (date EQ '092609') THEN wav_yra = [1d0,4d3]
IF (date EQ '092609') THEN scw_zra = [1d-7,1d-2]
IF (N_ELEMENTS(wav_yra) NE 0) THEN options,all_scw_wave_nms+'*','YRANGE'
IF (N_ELEMENTS(wav_yra) NE 0) THEN options,all_scw_wave_nms+'*','YRANGE',wav_yra,/DEF
IF (N_ELEMENTS(scw_zra) NE 0) THEN options,all_scw_wave_nms,'ZRANGE'
IF (N_ELEMENTS(scw_zra) NE 0) THEN options,all_scw_wave_nms,'ZRANGE',scw_zra,/DEF
options,all_scw_wave_nms+'*','YLOG'
options,all_scw_wave_nms+'*','YLOG',1,/DEF

tplot,all_scw_wave_nms,TRANGE=tr_ww

;;-----------------------------------------------------
;; => ESWs Examples
;;-----------------------------------------------------
comps          = ['Bo_x_Xgse_x_Bo','Bo_x_Xgse','Bo']
lims           = CREATE_STRUCT('LEVELS',1.0,'C_ANNOTATION','95%','YLOG',1,'C_THICK',2.0)

;;  1st Example ESW
nna_vec        = [efw_names_x[0],efw_names_y[0],efw_names_z[0]]
nna_wav        = [efw_wave_nms_x[0],efw_wave_nms_y[0],efw_wave_nms_z[0]]
tra00          = tr_esw0
IF (date EQ '092609') THEN yran_vec = [-1d0,1d0]*4d1
IF (N_ELEMENTS(yran_vec) NE 0) THEN options,nna_vec,'YRANGE'
IF (N_ELEMENTS(yran_vec) NE 0) THEN options,nna_vec,'YRANGE',yran_vec,/DEF

;;  2nd Example ESW
nna_vec        = [efw_names_x[0],efw_names_y[0],efw_names_z[0]]
nna_wav        = [efw_wave_nms_x[0],efw_wave_nms_y[0],efw_wave_nms_z[0]]
tra00          = tr_esw1
IF (date EQ '092609') THEN yran_vec = [-1d0,1d0]*23d1
IF (N_ELEMENTS(yran_vec) NE 0) THEN options,nna_vec,'YRANGE'
IF (N_ELEMENTS(yran_vec) NE 0) THEN options,nna_vec,'YRANGE',yran_vec,/DEF

;;  3rd Example ESW
nna_vec        = [efw_names_x[1],efw_names_y[1],efw_names_z[1]]
nna_wav        = [efw_wave_nms_x[1],efw_wave_nms_y[1],efw_wave_nms_z[1]]
tra00          = tr_esw2
IF (date EQ '092609') THEN yran_vec = [-1d0,1d0]*25d1
IF (N_ELEMENTS(yran_vec) NE 0) THEN options,nna_vec,'YRANGE'
IF (N_ELEMENTS(yran_vec) NE 0) THEN options,nna_vec,'YRANGE',yran_vec,/DEF


;;------------------------------
;;------------------------------
;;  Plot 3 examples
;;------------------------------
;;------------------------------
fnm_tra        = file_name_times(tra00,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
f_pref         = prefu[0]+'efw-wavelet_fci-flh-fce_'
fnames         = f_pref[0]+ftime[0]+'_'+comps

nna_v          = [nna_vec[0],nna_wav[0]]
nna_o          = fciflhfce_nm[0]
  oplot_tplot_spec,nna_v,nna_o,TRANGE=tra00,LIMITS=lims

nna_o          = fciflhfce_nm[0]
FOR k=0L, 2L DO BEGIN                                         $
  nna_v          = [nna_vec[k],nna_wav[k]]                  & $
  fname          = fnames[k]                                & $
  popen,fname[0],/PORT                                      & $
    oplot_tplot_spec,nna_v,nna_o,TRANGE=tra00,LIMITS=lims   & $
  pclose


;;-----------------------------------------------------
;; => High Freq. Whistler Example
;;-----------------------------------------------------
vec_str        = ['x','y','z']
comps          = ['Bo_x_Xgse_x_Bo','Bo_x_Xgse','Bo']
lims           = CREATE_STRUCT('LEVELS',1.0,'C_ANNOTATION','95%','YLOG',1,'C_THICK',2.0)

nna_vec        = [scw_names_x[1],scw_names_y[1],scw_names_z[1]]
nna_wav        = [scw_wave_nms_x[1],scw_wave_nms_y[1],scw_wave_nms_z[1]]
tra00          = tr_whi
IF (date EQ '071309') THEN yran_vec = [-1d0,1d0]*0.5d0
IF (date EQ '092609') THEN yran_vec = [-1d0,1d0]*1.2d0
IF (date EQ '092609') THEN yran_wav = [1d0,1d3]
IF (N_ELEMENTS(yran_vec) NE 0) THEN options,nna_vec,'YRANGE'
IF (N_ELEMENTS(yran_vec) NE 0) THEN options,nna_vec,'YRANGE',yran_vec,/DEF
IF (N_ELEMENTS(yran_wav) NE 0) THEN options,[fciflhfce_nm[0],nna_wav],'YRANGE'
IF (N_ELEMENTS(yran_wav) NE 0) THEN options,[fciflhfce_nm[0],nna_wav],'YRANGE',yran_wav,/DEF

fnm_tra        = file_name_times(tra00,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
f_pref         = prefu[0]+'scw-wavelet_fci-flh-fce_'
fnames         = f_pref[0]+ftime[0]+'_'+comps

nna_v          = [nna_vec[0],nna_wav[0]]
nna_o          = fciflhfce_nm[0]
  oplot_tplot_spec,nna_v,nna_o,TRANGE=tra00,LIMITS=lims

nna_o          = fciflhfce_nm[0]
FOR k=0L, 2L DO BEGIN                                         $
  nna_v          = [nna_vec[k],nna_wav[k]]                  & $
  fname          = fnames[k]                                & $
  popen,fname[0],/PORT                                      & $
    oplot_tplot_spec,nna_v,nna_o,TRANGE=tra00,LIMITS=lims   & $
  pclose

;;-----------------------------------------------------
;; Create nfce and (n+1/2)fce variable
;;-----------------------------------------------------
fgmnm          = scpref[0]+'fgh_'+['mag',coord[0]]
get_data,fgmnm[0],DATA=fgm_bmag,DLIM=dlim,LIM=lim
bmag           = fgm_bmag.Y
fcefac         = qq[0]*1d-9/(2d0*!DPI*me[0])
fce_1          = fcefac[0]*bmag             ;; electron cyclotron frequency [Hz]
nf             = 4L
n_fce          = DINDGEN(nf) + 1d0
n_12_fce       = DINDGEN(nf) + 1d0/2d0
nfce           = DBLARR(N_ELEMENTS(fce_1),nf)
n12fce         = DBLARR(N_ELEMENTS(fce_1),nf)
FOR k=0L, nf - 1L DO nfce[*,k]   = fce_1*n_fce[k]
FOR k=0L, nf - 1L DO n12fce[*,k] = fce_1*n_12_fce[k]

nfce_str      = STRTRIM(STRING(n_fce,FORMAT='(I1.1)'),2L)
n12fce_st0    = STRTRIM(STRING(n_12_fce,FORMAT='(I1.1)'),2L)
n12fce_num    = LONG(n12fce_st0)*2L + 1L
n12fce_str    = STRTRIM(STRING(n12fce_num,FORMAT='(I1.1)'),2L)+'/2'

nfce_labs     = nfce_str+' f!Dce!N'
n12fce_labs   = n12fce_str+' f!Dce!N'
fce_cols      = LINDGEN(nf)*(250 - 30)/(nf - 1L) + 30L

op_nfce       = scpref[0]+'fgh_nfce'
store_data,op_nfce[0],DATA={X:fgm_bmag.X,Y:nfce},LIM=lim
options,op_nfce,'YLOG',1,/DEF
options,op_nfce,'YTITLE','n f!Dce!N [Hz]',/DEF
options,op_nfce,'LABELS',nfce_labs,/DEF

op_n12_fce    = scpref[0]+'fgh_n12_fce'
store_data,op_n12_fce[0],DATA={X:fgm_bmag.X,Y:n12fce},LIM=lim
options,op_n12_fce,'YLOG',1,/DEF
options,op_n12_fce,'YTITLE','n f!Dce!N [Hz]',/DEF
options,op_n12_fce,'LABELS',n12fce_labs,/DEF

IF (date EQ '071309') THEN yran = wav_yra
IF (N_ELEMENTS(yran) NE 0) THEN options,[op_nfce[0],op_n12_fce[0]],'YRANGE',yran,/DEF
options,[op_nfce[0],op_n12_fce[0]],'COLORS',fce_cols,/DEF
;;-----------------------------------------------------
;; => ECDI Example
;;-----------------------------------------------------

comps          = ['Bo_x_Xgse_x_Bo','Bo_x_Xgse','Bo']
lims           = CREATE_STRUCT('LEVELS',1.0,'C_ANNOTATION','95%','YLOG',1,'C_THICK',2.0)
nna_vec        = [efw_names_x[1],efw_names_y[1],efw_names_z[1]]
nna_wav        = [efw_wave_nms_x[1],efw_wave_nms_y[1],efw_wave_nms_z[1]]

efi_names      = [[efw_names_x],[efw_names_y],[efw_names_z]]
options,REFORM(efi_names[1,*]),'YRANGE'
options,REFORM(efi_names[1,*]),'YSTYLE',1
options,REFORM(efi_names[1,*]),'YRANGE',[-1d0,1d0]*2d2,/DEF

yran           = [1d1,4d3]
options,all_efw_wave_nms+'*','YRANGE',yran,/DEF
options,[op_nfce[0],op_n12_fce[0]],'YRANGE',yran,/DEF
;options,all_efw_wave_nms,'X_NO_INTERP',0,/DEF
;options,all_efw_wave_nms,'Y_NO_INTERP',0,/DEF

tplot,[scw_names[1],efw_names[1]],TRANGE=tr_ecdi,/NOM

fnm_tra        = file_name_times(tr_ecdi,PREC=4)
ftime1         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
f_prefn        = prefu[0]+'efw-wavelet_nfce_'
f_prefn12      = prefu[0]+'efw-wavelet_n1-2-fce_'
fnamesn        = f_prefn[0]+ftime1[0]+'_'+comps
fnamesn12      = f_prefn12[0]+ftime1[0]+'_'+comps

nna_v          = [nna_vec[0],nna_wav[0]]
nna_o          = op_nfce[0]
tra00          = tr_ecdi
  oplot_tplot_spec,nna_v,nna_o,TRANGE=tra00,LIMITS=lims

;;  nfce plots
nna_o          = op_nfce[0]
fnames         = fnamesn
tra00          = tr_ecdi
FOR k=0L, 2L DO BEGIN                                          $
  nna_v          = [nna_vec[k],nna_wav[k]]                   & $
  fname          = fnames[k]                                 & $
  popen,fname[0],/PORT                                       & $
    oplot_tplot_spec,nna_v,nna_o,TRANGE=tra00,LIMITS=lims    & $
  pclose

;;  (n+1/2)fce plots
nna_o          = op_n12_fce[0]
fnames         = fnamesn12
tra00          = tr_ecdi
FOR k=0L, 2L DO BEGIN                                          $
  nna_v          = [nna_vec[k],nna_wav[k]]                   & $
  fname          = fnames[k]                                 & $
  popen,fname[0],/PORT                                       & $
    oplot_tplot_spec,nna_v,nna_o,TRANGE=tra00,LIMITS=lims    & $
  pclose


;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Check uncertainties for |j| calculation
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
t_ramp         = t_ramp0[0]
;;  Shock Parameters
vshn_up        =   26.234590d0
d_vshn_up      =    7.630707d0  ;;  Std. Dev. of the Mean
ushn_up        = -335.993240d0
ushn_dn        =  -83.998692d0
gnorm          = [0.95576882d0,-0.18012919d0,-0.14100009d0]  ;; GSE
theta_Bn       =   51.464211d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-307.345d0,65.0927d0,30.3775d0]
vswi_dn        = [-54.9544d0,43.4793d0,-18.3793d0]
magf_up        = [1.54738d0,-0.185112d0,-2.65947d0]
magf_dn        = [-1.69473d0,-14.2039d0,1.26029d0]
dens_up        =    9.66698d0
dens_dn        =   40.5643d0
Ti___up        =   17.52810d0
Ti___dn        =  145.3160d0
Te___up        =    7.87657d0
Te___dn        =   31.0342d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_gse      = 'gse'
vsw_tpnm       = tnames(pref[0]+coord_gse[0]+'_Velocity_peib_no_GIs_UV_2')
nsm            = 10L
nif_suffx      = '-RHS01'

modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm+'_'
fgh_gse        = tnames(fgm_pren[2]+coord_gse[0])     ;;  FGM TPLOT handles [GSE basis]
fgh_mag        = tnames(fgm_pren[2]+'mag')
pos_gse        = tnames(scpref[0]+'state_pos_'+coord_gse[0])
tra            = time_double(tr_jj)
;;-----------------------------------------------------
;;  Calculate ∆x, E_conv, j, etc.
;;-----------------------------------------------------
;;  For Vshn Low
str_element,nif_str,'V_SHN',vshn_up[0] - d_vshn_up[0],/ADD_REPLACE
struct_low     = t_nif_s1986a_scale_norm(nif_str,VSW_TPNM=vsw_tpnm[0],MAGF_TPNM=fgh_gse[0], $
                                         SCPOS_TPNM=pos_gse[0],NSM=nsm[0],TRANGE=tra,       $
                                         TRAMP=t_ramp[0])

;;  For Vshn Mid
str_element,nif_str,'V_SHN',vshn_up[0],/ADD_REPLACE
struct_mid     = t_nif_s1986a_scale_norm(nif_str,VSW_TPNM=vsw_tpnm[0],MAGF_TPNM=fgh_gse[0], $
                                         SCPOS_TPNM=pos_gse[0],NSM=nsm[0],TRANGE=tra,       $
                                         TRAMP=t_ramp[0])

;;  For Vshn High
str_element,nif_str,'V_SHN',vshn_up[0] + d_vshn_up[0],/ADD_REPLACE
struct_hig     = t_nif_s1986a_scale_norm(nif_str,VSW_TPNM=vsw_tpnm[0],MAGF_TPNM=fgh_gse[0], $
                                         SCPOS_TPNM=pos_gse[0],NSM=nsm[0],TRANGE=tra,       $
                                         TRAMP=t_ramp[0])
;;-----------------------------------------------------
;; => Get current densities
;;-----------------------------------------------------
;;  For Vshn Low
j_struc_low    = struct_low.DELTA_JSTR.DELTA_J_NIF_STR
j_struc_low_sm = struct_low.DELTA_JSTR.DELTA_J_SM_NIF_STR
j_time_low     = j_struc_low.TIME                         ;;  timestamps for current densities
j_vec__low     = j_struc_low.JVEC_NIF                     ;;  j-vector NIF [NCB, µA m^(-2)]
j_mag__low     = j_struc_low.JMAG_NIF                     ;;  |j| [µA m^(-2)]
j_vec__low_sm  = j_struc_low_sm.JVEC_NIF_SM               ;;  smoothed j-vector
j_mag__low_sm  = j_struc_low_sm.JMAG_NIF_SM               ;;  smoothed |j|


;;  For Vshn Mid
j_struc_mid    = struct_mid.DELTA_JSTR.DELTA_J_NIF_STR
j_struc_mid_sm = struct_mid.DELTA_JSTR.DELTA_J_SM_NIF_STR
j_time_mid     = j_struc_mid.TIME                         ;;  timestamps for current densities
j_vec__mid     = j_struc_mid.JVEC_NIF                     ;;  j-vector NIF [NCB, µA m^(-2)]
j_mag__mid     = j_struc_mid.JMAG_NIF                     ;;  |j| [µA m^(-2)]
j_vec__mid_sm  = j_struc_mid_sm.JVEC_NIF_SM               ;;  smoothed j-vector
j_mag__mid_sm  = j_struc_mid_sm.JMAG_NIF_SM               ;;  smoothed |j|


;;  For Vshn High
j_struc_hig    = struct_hig.DELTA_JSTR.DELTA_J_NIF_STR
j_struc_hig_sm = struct_hig.DELTA_JSTR.DELTA_J_SM_NIF_STR
j_time_hig     = j_struc_hig.TIME                         ;;  timestamps for current densities
j_vec__hig     = j_struc_hig.JVEC_NIF                     ;;  j-vector NIF [NCB, µA m^(-2)]
j_mag__hig     = j_struc_hig.JMAG_NIF                     ;;  |j| [µA m^(-2)]
j_vec__hig_sm  = j_struc_hig_sm.JVEC_NIF_SM               ;;  smoothed j-vector
j_mag__hig_sm  = j_struc_hig_sm.JMAG_NIF_SM               ;;  smoothed |j|



;; => Define TPLOT handles for current density vector and magnitudes [µA m^(-2)]
nsm            = 10L
vec_str        = ['x','y','z']
lmh_str        = ['min','mid','max']
mu__str        = get_greek_letter('mu')

yttl_jvec      = 'J'+vec_str+' [NIF, '+mu__str[0]+'A m!U-2!N'+']'
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
sm_suffx       = '_sm'+nsms[0]+'pts'
nif_suffx      = '-RHS01'
coord_nif      = 'nif_S1986a'+nif_suffx[0]
cur_tp_suffx   = mode_fgm[2]+'_'+coord_nif[0]
cur_nmvec      = tnames(scpref[0]+'jvec_'+cur_tp_suffx[0])
cur_nmvec_sm   = tnames(scpref[0]+'jvec_'+cur_tp_suffx[0]+sm_suffx[0])  ;; smoothed...

get_data,cur_nmvec[0],DATA=jvec_str,DLIM=dlim,LIM=lim
get_data,cur_nmvec_sm[0],DATA=jvec_str_sm,DLIM=dlim_sm,LIM=lim_sm

;;  Define new output names
cur_nm_xyz     = scpref[0]+'j_'+vec_str+'_'+cur_tp_suffx[0]
cur_nm_xyz_sm  = scpref[0]+'j_'+vec_str+'_'+cur_tp_suffx[0]+sm_suffx[0]
;;  Define new output labels
cur_xyz_labs   = STRARR(3,3)
FOR j=0L, 2L DO cur_xyz_labs[j,*] = 'j!D'+vec_str+','+lmh_str[j]+'!N'

j_times        = j_time_hig
FOR j=0L, 2L DO BEGIN                                                                                       $
  j_v_comp    = [[REFORM(j_vec__low[*,j])],[REFORM(j_vec__mid[*,j])],[REFORM(j_vec__hig[*,j])]]           & $
  j_v_comp_sm = [[REFORM(j_vec__low_sm[*,j])],[REFORM(j_vec__mid_sm[*,j])],[REFORM(j_vec__hig_sm[*,j])]]  & $
  str_element,   dlim,'YTITLE',yttl_jvec[j],/ADD_REPLACE                                                  & $
  str_element,dlim_sm,'YTITLE',yttl_jvec[j],/ADD_REPLACE                                                  & $
  str_element,   dlim,'LABELS',cur_xyz_labs[*,j],/ADD_REPLACE                                             & $
  str_element,dlim_sm,'LABELS',cur_xyz_labs[*,j],/ADD_REPLACE                                             & $
  store_data,   cur_nm_xyz[j],DATA={X:j_times,Y:j_v_comp},   DLIM=dlim,   LIM=lim                         & $
  store_data,cur_nm_xyz_sm[j],DATA={X:j_times,Y:j_v_comp_sm},DLIM=dlim_sm,LIM=lim_sm



tra00          = tr_ww1
tra00          = tr_ww2
fnm_tra        = file_name_times(tra00,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
f_pref         = prefu[0]+'fgh-mag-gse_jyz-low-mid-high'+sm_suffx[0]
fnames         = f_pref[0]+'_'+ftime[0]+'_compare-uncertainties'

nna            = [fgh_mag[0],fgh_gse[0],cur_nm_xyz_sm[1:2]]
  tplot,nna,TRANGE=tra00
  time_bar,t_ramp[0],COLOR=150
popen,fnames[0],/PORT
  tplot,nna,TRANGE=tra00
  time_bar,t_ramp[0],COLOR=150
pclose

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Check uncertainties for |j| calculation
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
t_ramp         = t_ramp0[0]
;;  Shock Parameters and Uncertainties
vshn_up        =   26.234590d0
d_vshn_up      =    7.630707d0  ;;  Std. Dev. of the Mean
ushn_up        = -335.993240d0
d_ushn_up      =    7.680440d0
ushn_dn        =  -83.998692d0
d_ushn_up      =    4.055204d0
gnorm          = [0.95576882d0,-0.18012919d0,-0.14100009d0]  ;; GSE
d_gnorm        = [0.03659218d0, 0.14968821d0, 0.10214679d0]
theta_Bn       =   51.464211d0
d_theta_Bn     =   10.156295d0
;;  Avg. upstream/downstream Vsw and Bo
;;    => Use Std. Dev. of the Mean for uncertainties
magf_up        = [1.5473849d0,-0.18511195d0,-2.6594720d0]
d_magf_up      = [0.10056366d0,0.058641853d0,0.092365710d0]
vswi_up        = [-307.34454d0,65.092682d0,30.377501d0]
d_vswi_up      = [0.15787491d0,0.070408187d0,0.063574656d0]
dens_up        =    9.6669788d0
d_dens_up      =    0.070733681d0
Te___up        =    7.8765683d0
d_Te___up      =    0.060812390d0
Ti___up        =   17.528111d0
d_Ti___up      =   0.13017347d0


magf_dn        = [-1.6947349d0,-14.203903d0,1.2602856d0]
d_magf_dn      = [1.0371751d0,0.91914374d0,1.8421996d0]
vswi_dn        = [-54.954391d0,43.479301d0,-18.379349d0]
d_vswi_dn      = [3.8926710d0,2.7266483d0,4.1654075d0]
dens_dn        = 40.564289d0
d_dens_dn      = 0.95647218d0
Te___dn        = 31.034185d0
d_Te___dn      = 0.46331807d0
Ti___dn        = 145.31645d0
d_Ti___dn      = 4.1920613d0

;;  Define dummy RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

;;-----------------------------------------------------
;;  Define range of parameters to use
;;     9  -  Elements from Bo [per region]
;;     9  -  Elements from Vsw [per region]
;;     9  -  Elements from n
;;     3  -  Elements from Vshn
;;-----------------------------------------------------
range_Bo_up    = DBLARR(3L,3L)  ;;  [ {low, mid, high}, {x, y, z} ]
range_Bo_dn    = DBLARR(3L,3L)
range_n__up    = DBLARR(3L,3L)
range__Vshn    = DBLARR(3L)
multi_fac      = [-1d0,0d0,1d0]
FOR j=0L, 2L DO BEGIN                                         $
  range_Bo_up[*,j] = magf_up[j] + multi_fac*d_magf_up[j]    & $
  range_Bo_dn[*,j] = magf_dn[j] + multi_fac*d_magf_dn[j]    & $
  range_n__up[*,j] =   gnorm[j] + multi_fac*d_gnorm[j]

range__Vshn    = vshn_up[0] + multi_fac*d_vshn_up[0]
;;-----------------------------------------------------
;;  Define empty arrays for j
;;-----------------------------------------------------
coord_gse      = 'gse'
vsw_tpnm       = tnames(pref[0]+coord_gse[0]+'_Velocity_peib_no_GIs_UV_2')
nsm            = 10L
nif_suffx      = '-RHS01'

modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm+'_'
fgh_gse        = tnames(fgm_pren[2]+coord_gse[0])     ;;  FGM TPLOT handles [GSE basis]
fgh_mag        = tnames(fgm_pren[2]+'mag')
pos_gse        = tnames(scpref[0]+'state_pos_'+coord_gse[0])
tra            = time_double(tr_jj)

tra            = time_double(tr_jj)
get_data,fgh_mag[0],DATA=fgh_mag_str
fgh_t          = fgh_mag_str.X
good           = WHERE(fgh_t GE tra[0] AND fgh_t LE tra[1],gd)
PRINT,';; ', gd
;;        76288

n_jv           = gd - 1L                   ;;  # of j-vectors [smoothed]
jv_lmh_y       = DBLARR(n_jv,3L,3L,3L,3L)  ;;  [ N, Bup{low, mid, high}, Bdn{low, mid, high}, n{low, mid, high}, Vshn{low, mid, high} ]
jv_lmh_z       = DBLARR(n_jv,3L,3L,3L,3L)  ;;  [ N, Bup{low, mid, high}, Bdn{low, mid, high}, n{low, mid, high}, Vshn{low, mid, high} ]
jv_t           = DBLARR(n_jv)
;;-----------------------------------------------------
;;  Calculate j
;;-----------------------------------------------------
FOR i=0L, 2L DO BEGIN                                                                         $  ;;  Bup{low, mid, high}
  FOR j=0L, 2L DO BEGIN                                                                       $  ;;  Bdn{low, mid, high}
    FOR k=0L, 2L DO BEGIN                                                                     $  ;;  Vshn{low, mid, high}
      FOR m=0L, 2L DO BEGIN                                                                   $  ;;  n{low, mid, high}
        test_st = (i EQ 0) AND (j EQ 0) AND (k EQ 0) AND (m EQ 0)                           & $
        struct  = 0                                                                         & $
        j_strc  = 0                                                                         & $
        str_element,nif_str, 'B_UP',REFORM(range_Bo_up[i,*]),/ADD_REPLACE                   & $
        str_element,nif_str, 'B_DN',REFORM(range_Bo_up[j,*]),/ADD_REPLACE                   & $
        str_element,nif_str,'V_SHN',          range__Vshn[k],/ADD_REPLACE                   & $
        str_element,nif_str, 'NORM',REFORM(range_n__up[m,*]),/ADD_REPLACE                   & $
        struct = t_nif_s1986a_scale_norm(nif_str,VSW_TPNM=vsw_tpnm[0],MAGF_TPNM=fgh_gse[0],   $
                                         SCPOS_TPNM=pos_gse[0],NSM=nsm[0],TRANGE=tra,         $
                                         TRAMP=t_ramp[0])                                   & $
        j_strc = struct.DELTA_JSTR.DELTA_J_SM_NIF_STR                                       & $
        IF (test_st) THEN jv_t = j_strc.TIME                                                & $
        jv_lmh_y[*,i,j,k,m] = j_strc.JVEC_NIF_SM[*,1]                                       & $
        jv_lmh_z[*,i,j,k,m] = j_strc.JVEC_NIF_SM[*,2]

;;-----------------------------------------------------
;;  Calculate Min., Max., <>, and Std. Dev. for each t
;;-----------------------------------------------------
d              = !VALUES.D_NAN
sdafac         = 1d0/SQRT(1d0*N_ELEMENTS(REFORM(jv_lmh_y[0L,*,*,*,*])))
jv_mnmxavst_y  = REPLICATE(d,n_jv,5L)  ;;  [ N, {Min., Max., Avg., Std. Dev., (Std. Dev.)/sqrt(K)} ]
jv_mnmxavst_z  = REPLICATE(d,n_jv,5L)  ;;  [ N, {Min., Max., Avg., Std. Dev., (Std. Dev.)/sqrt(K)} ]
FOR i=0L, n_jv - 1L DO BEGIN                                                                 $
  y  = REFORM(jv_lmh_y[i,*,*,*,*])                                                         & $
  z  = REFORM(jv_lmh_z[i,*,*,*,*])                                                         & $
  dy = [MIN(y,/NAN), MAX(y,/NAN), MEAN(y,/NAN), STDDEV(y,/NAN), STDDEV(y,/NAN)*sdafac[0]]  & $
  dz = [MIN(z,/NAN), MAX(z,/NAN), MEAN(z,/NAN), STDDEV(z,/NAN), STDDEV(z,/NAN)*sdafac[0]]  & $
  goody = WHERE(dy NE 0 AND FINITE(dy),gdy,COMPLEMENT=bady,NCOMPLEMENT=bdy)                & $
  goodz = WHERE(dz NE 0 AND FINITE(dz),gdz,COMPLEMENT=badz,NCOMPLEMENT=bdz)                & $
  IF (bdy GT 0) THEN dy[bady] = d                                                          & $
  IF (bdz GT 0) THEN dz[badz] = d                                                          & $
  jv_mnmxavst_y[i,*] = dy                                                                  & $
  jv_mnmxavst_z[i,*] = dz


;; => Define TPLOT handles for current density vector and magnitudes [µA m^(-2)]
mu__str        = get_greek_letter('mu')
sigma_str      = get_greek_letter('sigma')
nsm            = 10L
vec_cols       = [250L,200L,150L,100L, 50L]
vec_str        = ['x','y','z']
lmh_str        = ['min','max','avg',sigma_str[0],'<'+sigma_str[0]+'>']

yttl_jvec      = 'J'+vec_str+' [NIF, '+mu__str[0]+'A m!U-2!N'+']'
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
sm_suffx       = '_sm'+nsms[0]+'pts'
unc_suffx      = '_nxastsa'
nif_suffx      = '-RHS01'
coord_nif      = 'nif_S1986a'+nif_suffx[0]
cur_tp_suffx   = mode_fgm[2]+'_'+coord_nif[0]
cur_nmvec_sm   = tnames(scpref[0]+'jvec_'+cur_tp_suffx[0]+sm_suffx[0])  ;; smoothed...

get_data,cur_nmvec_sm[0],DATA=jvec_str_sm,DLIM=dlim_sm,LIM=lim_sm

;;  Define new output names
cur_nm_xyz_sm  = scpref[0]+'j_'+vec_str+'_'+cur_tp_suffx[0]+sm_suffx[0]+unc_suffx[0]
;;  Define new output labels
cur_xyz_labs   = STRARR(5,3)
FOR j=0L, 4L DO cur_xyz_labs[j,*] = 'j!D'+vec_str+','+lmh_str[j]+'!N'

str_element,dlim_sm,'COLORS',vec_cols,/ADD_REPLACE

j              = 1L
str_element,dlim_sm,'YTITLE',yttl_jvec[j],/ADD_REPLACE
str_element,dlim_sm,'LABELS',cur_xyz_labs[*,j],/ADD_REPLACE
store_data,cur_nm_xyz_sm[j],DATA={X:jv_t,Y:jv_mnmxavst_y},DLIM=dlim_sm,LIM=lim_sm

j              = 2L
str_element,dlim_sm,'YTITLE',yttl_jvec[j],/ADD_REPLACE
str_element,dlim_sm,'LABELS',cur_xyz_labs[*,j],/ADD_REPLACE
store_data,cur_nm_xyz_sm[j],DATA={X:jv_t,Y:jv_mnmxavst_z},DLIM=dlim_sm,LIM=lim_sm


;;-----------------------------------------------------
;;  j + [-∑, 0, +∑]
;;-----------------------------------------------------
;;  Define new output names
unc_suffx      = '_avg_pm_stdmean'
cur_nm_xyz_sm  = scpref[0]+'j_'+vec_str+'_'+cur_tp_suffx[0]+sm_suffx[0]+unc_suffx[0]

lmh_str        = 'avg'+[' - '+'<'+sigma_str[0]+'>','',' + '+'<'+sigma_str[0]+'>']
;;  Define new output labels
cur_xyz_labs   = STRARR(3,3)
FOR j=0L, 2L DO cur_xyz_labs[j,*] = 'j!D'+vec_str+','+lmh_str[j]+'!N'

get_data,cur_nmvec_sm[0],DATA=jvec_str_sm,DLIM=dlim_sm,LIM=lim_sm

multi_fac      = [-1d0,0d0,1d0]
jy_pm_std      = REPLICATE(d,n_jv,3L)
jz_pm_std      = REPLICATE(d,n_jv,3L)
std_jy         = 2d0*REFORM(jv_mnmxavst_y[*,4L])
std_jz         = 2d0*REFORM(jv_mnmxavst_z[*,4L])
FOR j=0L, 2L DO jy_pm_std[*,j] = jvec_str_sm.Y[*,1] + multi_fac[j]*std_jy
FOR j=0L, 2L DO jz_pm_std[*,j] = jvec_str_sm.Y[*,2] + multi_fac[j]*std_jz

j              = 1L
str_element,dlim_sm,'YTITLE',yttl_jvec[j],/ADD_REPLACE
str_element,dlim_sm,'LABELS',cur_xyz_labs[*,j],/ADD_REPLACE
store_data,cur_nm_xyz_sm[j],DATA={X:jv_t,Y:jy_pm_std},DLIM=dlim_sm,LIM=lim_sm

j              = 2L
str_element,dlim_sm,'YTITLE',yttl_jvec[j],/ADD_REPLACE
str_element,dlim_sm,'LABELS',cur_xyz_labs[*,j],/ADD_REPLACE
store_data,cur_nm_xyz_sm[j],DATA={X:jv_t,Y:jz_pm_std},DLIM=dlim_sm,LIM=lim_sm



;;  Just varying Vshn gives better results...




































































































