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

























































































































































