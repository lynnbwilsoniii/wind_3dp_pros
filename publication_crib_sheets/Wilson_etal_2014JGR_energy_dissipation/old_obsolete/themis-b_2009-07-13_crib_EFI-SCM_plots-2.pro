;-----------------------------------------------------------------------------------------
; => Constants
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
epo    = 8.854187817d-12   ; => Permittivity of free space (F/m)
muo    = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
me     = 9.10938291d-31    ; => Electron mass (kg) [2010 value]
mp     = 1.672621777d-27   ; => Proton mass (kg) [2010 value]
ma     = 6.64465675d-27    ; => Alpha-Particle mass (kg) [2010 value]
qq     = 1.602176565d-19   ; => Fundamental charge (C) [2010 value]
kB     = 1.3806488d-23     ; => Boltzmann Constant (J/K) [2010 value]
K_eV   = 1.1604519d4       ; => Factor [Kelvin/eV] [2010 value]
c      = 2.99792458d8      ; => Speed of light in vacuum (m/s)
R_E    = 6.37814d3         ; => Earth's Equitorial Radius (km)

; => Compile necessary routines
@comp_lynn_pros
; => Date/Time and Probe
tdate     = '2009-07-13'
tr_00     = tdate[0]+'/'+['07:50:00','10:10:00']
date      = '071309'
probe     = 'b'
;-----------------------------------------------------------------------------------------
; => Load all relevant data
;-----------------------------------------------------------------------------------------
themis_load_all_inst,DATE=date[0],PROBE=probe[0],/LOAD_EFI,/LOAD_SCM,/TRAN_FAC,         $
                         /TCLIP_FIELDS,SE_T_EFI_OUT=tr_all_efi,SE_T_SCM_OUT=tr_all_scm, $
                         /NO_EXTRA,/NO_SPEC,/POYNT_FLUX,TRANGE=time_double(tr_00)

;; Reconfigure graphics
old_dev = !D.NAME             ;  save current device name
SET_PLOT,'PS'                 ;  change to PS so we can edit the font mapping
loadct2,43
;DEVICE,/SYMBOL,FONT_INDEX=19  ;set font !19 to Symbol
!P.FONT = -1
SET_PLOT,old_dev              ;  revert to old device
!P.FONT = -1
loadct2,43
DEVICE,DECOMPOSE=0,RETAIN=2
;; initialize font in popen
popen,FONT=-1
pclose
SPAWN,'rm -rf plot.ps'

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100


nefi           = N_ELEMENTS(REFORM(tr_all_efi[*,0]))
nscm           = N_ELEMENTS(REFORM(tr_all_scm[*,0]))
PRINT,'; ', nefi, nscm
;           17          17

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;-----------------------------------------------------------------------------------------
; => Plot data
;-----------------------------------------------------------------------------------------
tr_eb   = tdate[0]+'/'+['08:50:00','09:45:00']
treb    = time_double(tr_eb)

sc      = probe[0]
pref    = 'th'+sc[0]+'_'
;coord   = 'gse'
coord   = 'dsl'

fgmnm   = pref[0]+'fgh_'+['mag',coord[0]]
efwnm   = pref[0]+'efw_cal_'+coord[0]+'_corrected*'
scwnm   = pref[0]+'scw_cal_'+coord[0]+'*'
names   = [fgmnm,efwnm,scwnm]


tplot,names,TRANGE=treb
;;----------------------------------------------------------------------------------------
;; => Save Plots
;;----------------------------------------------------------------------------------------
sc             = probe[0]
scu            = STRUPCASE(sc[0])
pref           = 'th'+sc[0]+'_'
coord          = 'gse'
fgmnm          = pref[0]+'fgh_'+['mag',coord[0]]  ;; FGM TPLOT handles

ind            = LINDGEN(nefi)
s_ind          = STRTRIM(STRING(ind,FORMAT='(I3.3)'),2L)
isuffx         = '_INT'+s_ind
stpref         = 'S__TimeSeries_'
;; => Rotate Poynting flux to GSE
in_names       = pref[0]+stpref[0]+'dsl'+isuffx
out_names      = pref[0]+stpref[0]+coord[0]+isuffx
FOR j=0L, nefi - 1L DO BEGIN $
  thm_cotrans,in_names[j],out_names[j],IN_COORD='dsl',OUT_COORD=coord[0],VERBOSE=0
;; => Fix YTITLE
poyn_names     = out_names
options,poyn_names,'YTITLE'
options,poyn_names,'YTITLE','S ['+STRUPCASE(coord[0])+', !7l!3W/m!U-2!N]',/DEF


efwpre         = 'efw_cal_'
scwpre         = 'scw_cal_'
ffname         = ['efw','scw']
tfname         = ['corrected'+['','_DownSampled'],'HighPass']
;; => Define TPLOT handles
efc__names     = pref[0]+efwpre[0]+tfname[0]+'_'+coord[0]+isuffx
efds_names     = pref[0]+efwpre[0]+tfname[1]+'_'+coord[0]+isuffx
bfhp_names     = pref[0]+scwpre[0]+tfname[2]+'_'+coord[0]+isuffx

;; => Determine time ranges
tra_all        = DBLARR(nefi,2)
FOR j=0L, nefi - 1L DO BEGIN                                         $
  aname  = [fgmnm,efds_names[j],bfhp_names[j],poyn_names[j]]       & $
  get_data,aname[2],DATA=tempe                                     & $
  get_data,aname[3],DATA=tempb                                     & $
  get_data,aname[4],DATA=temps                                     & $
  tra_l  = MIN([tempe.X,tempb.X,temps.X],/NAN) - 2d0               & $
  tra_h  = MAX([tempe.X,tempb.X,temps.X],/NAN) + 2d0               & $
  tra_all[j,*] = [tra_l[0],tra_h[0]]


;; => Define file name prefixes
s_fsuff = 'PoyntingFlux_'
f_pref  = 'FGM-fgh-GSE_TH-'+scu[0]+'_efw-cor-DownSampled_scw-HighPass_'+s_fsuff[0]

FOR j=0L, nefi - 1L DO BEGIN                                         $
  aname  = [fgmnm,efds_names[j],bfhp_names[j],poyn_names[j]]       & $
;  tra    = REFORM(tr_all_efi[j,*]) + [-1d0,1d0]*2d0                & $
  tra    = REFORM(tra_all[j,*])                                    & $
  get_data,aname[3],DATA=temp                                      & $
  testx  = (TOTAL(FINITE(temp.Y[*,0])) EQ 0)                       & $
  testy  = (TOTAL(FINITE(temp.Y[*,1])) EQ 0)                       & $
  testz  = (TOTAL(FINITE(temp.Y[*,2])) EQ 0)                       & $
  IF (testx OR testy OR testz) THEN CONTINUE                       & $
  fnm    = file_name_times(tra,PREC=3)                             & $
  ftimes = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)             & $
  fname  = f_pref[0]+ftimes[0]+isuffx[j]                           & $
  tplot,aname,TRANGE=tra,/NOM                                      & $
  popen,fname[0],/PORT                                             & $
    tplot,aname,TRANGE=tra,/NOM                                    & $
  pclose
;;----------------------------------------------------------------------------------------
;; => Load Wavelets
;;----------------------------------------------------------------------------------------
tplot,[fgmnm,efds_names[j],bfhp_names[j],poyn_names[j]],/NOM,TRANGE=REFORM(tra_all[j,*])

kill_data_tr,names=[efds_names[j],bfhp_names[j],poyn_names[j]]
;;  Bad indices
;;  j  =  3
;;  j  =  4
;;  j  =  5
;;  j  =  9
;;  j  = 10
;;  j  = 12
;;  j  = 13
;;  j  = 14
;;  j  = 16

ind            = LINDGEN(nefi)
test           = (ind LT 3) OR ((ind GT  5) AND ((ind NE  9) AND (ind NE 10) AND $
                                                 (ind NE 12) AND (ind NE 13) AND $
                                                 (ind NE 14) AND (ind NE 16)))
good           = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
gind           = REPLICATE(0b,nefi)
bind           = REPLICATE(1b,nefi)
bind[good]     = 0b
gind[good]     = 1b

vec_s          = ['x','y','z']
units          = 'mV/m'
sc             = probe[0]
scu            = STRUPCASE(sc[0])
coord          = 'gse'
instr          = 'efw'
yran           = [1d1,4096d0]
inpre          = 'thb_efw_cal_corrected_DownSampled_gse'
in_names       = inpre[0]+isuffx
out_names      = STRARR(nefi,3L)
FOR k=0L, 2L DO out_names[*,k] = inpre[0]+'_'+vec_s[k]+isuffx

;; keep only "good" names
in_names       = in_names[good]
out_names      = out_names[good,*]

;; => Load EFI Wavelets
themis_load_wavelets,in_names,out_names,COORD=coord[0],UNITS=units[0],$
                     INSTRUMENT=instr[0],SPACECRAFT='THEMIS-'+scu[0], $
                     NSCALE=nscale

efi_gse__namex = out_names.(0)
efi_wvlt_namex = efi_gse__namex+'_wavelet'
efi_conf_namex = efi_wvlt_namex+'_Conf_Level_95'
efi_gse__namey = out_names.(1)
efi_wvlt_namey = efi_gse__namey+'_wavelet'
efi_conf_namey = efi_wvlt_namey+'_Conf_Level_95'
efi_gse__namez = out_names.(2)
efi_wvlt_namez = efi_gse__namez+'_wavelet'
efi_conf_namez = efi_wvlt_namez+'_Conf_Level_95'
;; => Define options
efi_gse__names = [[efi_gse__namex],[efi_gse__namey],[efi_gse__namez]]
efi_wvlt_names = [[efi_wvlt_namex],[efi_wvlt_namey],[efi_wvlt_namez]]
efi_conf_names = [[efi_conf_namex],[efi_conf_namey],[efi_conf_namez]]
efi_wnms       = [out_names.(0),out_names.(1),out_names.(2)]+'_wavelet*'

options,efi_wnms,'YRANGE'
options,efi_wnms,'YRANGE',yran,/DEF
options,efi_wnms,'YLOG'
options,efi_wnms,'YLOG',1,/DEF
FOR k=0L, 2L DO options,efi_wvlt_names[*,k],'MIN_VALUE'
FOR k=0L, 2L DO options,efi_wvlt_names[*,k],'MIN_VALUE',1d-6,/DEF


units          = 'nT'
instr          = 'scw'
inpre          = 'thb_scw_cal_HighPass_gse'
in_names       = inpre[0]+isuffx
out_names      = STRARR(nefi,3L)
FOR k=0L, 2L DO out_names[*,k] = inpre[0]+'_'+vec_s[k]+isuffx
;; keep only "good" names
in_names       = in_names[good]
out_names      = out_names[good,*]

;; => Load SCM Wavelets
themis_load_wavelets,in_names,out_names,COORD=coord[0],UNITS=units[0],$
                     INSTRUMENT=instr[0],SPACECRAFT='THEMIS-'+scu[0], $
                     NSCALE=nscale

scm_gse__namex = out_names.(0)
scm_wvlt_namex = scm_gse__namex+'_wavelet'
scm_conf_namex = scm_wvlt_namex+'_Conf_Level_95'
scm_gse__namey = out_names.(1)
scm_wvlt_namey = scm_gse__namey+'_wavelet'
scm_conf_namey = scm_wvlt_namey+'_Conf_Level_95'
scm_gse__namez = out_names.(2)
scm_wvlt_namez = scm_gse__namez+'_wavelet'
scm_conf_namez = scm_wvlt_namez+'_Conf_Level_95'
;; => Define options
scm_gse__names = [[scm_gse__namex],[scm_gse__namey],[scm_gse__namez]]
scm_wvlt_names = [[scm_wvlt_namex],[scm_wvlt_namey],[scm_wvlt_namez]]
scm_conf_names = [[scm_conf_namex],[scm_conf_namey],[scm_conf_namez]]
scm_wnms       = [out_names.(0),out_names.(1),out_names.(2)]+'_wavelet*'

options,scm_wnms,'YRANGE'
options,scm_wnms,'YRANGE',yran,/DEF
options,scm_wnms,'YLOG'
options,scm_wnms,'YLOG',1,/DEF
FOR k=0L, 2L DO options,scm_wvlt_names[*,k],'MIN_VALUE'
FOR k=0L, 2L DO options,scm_wvlt_names[*,k],'MIN_VALUE',1d-8,/DEF


;; => Create nfce and (n+1/2)fce variable
get_data,fgmnm[0],DATA=fgm_bmag
bmag          = fgm_bmag.Y
fcefac        = qq[0]*1d-9/(2d0*!DPI*me[0])
fce_1         = fcefac[0]*bmag             ;; electron cyclotron frequency [Hz]
nf            = 4L
n_fce         = DINDGEN(nf) + 1d0
n_12_fce      = DINDGEN(nf) + 1d0/2d0
nfce          = DBLARR(N_ELEMENTS(fce_1),nf)
n12fce        = DBLARR(N_ELEMENTS(fce_1),nf)
FOR k=0L, nf - 1L DO nfce[*,k]   = fce_1*n_fce[k]
FOR k=0L, nf - 1L DO n12fce[*,k] = fce_1*n_12_fce[k]

nfce_str      = STRTRIM(STRING(n_fce,FORMAT='(I1.1)'),2L)
n12fce_st0    = STRTRIM(STRING(n_12_fce,FORMAT='(I1.1)'),2L)
n12fce_num    = LONG(n12fce_st0)*2L + 1L
n12fce_str    = STRTRIM(STRING(n12fce_num,FORMAT='(I1.1)'),2L)+'/2'

nfce_labs     = nfce_str+' f!Dce!N'
n12fce_labs   = n12fce_str+' f!Dce!N'
fce_cols      = LINDGEN(nf)*(250 - 30)/(nf - 1L) + 30L

op_nfce       = 'thb_fgh_nfce'
store_data,op_nfce[0],DATA={X:fgm_bmag.X,Y:nfce}
options,op_nfce,'YRANGE',yran,/DEF
options,op_nfce,'YLOG',1,/DEF
options,op_nfce,'YTITLE','n f!Dce!N [Hz]',/DEF
options,op_nfce,'LABELS',nfce_labs,/DEF

op_n12_fce    = 'thb_fgh_n12_fce'
store_data,op_n12_fce[0],DATA={X:fgm_bmag.X,Y:n12fce}
options,op_n12_fce,'YRANGE',yran,/DEF
options,op_n12_fce,'YLOG',1,/DEF
options,op_n12_fce,'YTITLE','n f!Dce!N [Hz]',/DEF
options,op_n12_fce,'LABELS',n12fce_labs,/DEF

options,[op_nfce[0],op_n12_fce[0]],'COLORS',fce_cols,/DEF


nnw           = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;; => Save Wavelet Plots
;;----------------------------------------------------------------------------------------
tplot_options,'NO_INTERP',0       ;; allows interpolation in spectrograms


ltag          = ['LEVELS','C_ANNOTATION','YLOG','C_THICK']
lims          = CREATE_STRUCT(ltag,1.0,'95%',1,1.5)

vec_su        = STRUPCASE(['x','y','z'])
iwavsfx       = isuffx[good]
tra_wav       = tra_all[good,*]
ntr           = N_ELEMENTS(tra_wav[*,0])
;; => Determine wavelet time ranges
FOR j=0L, ntr - 1L DO BEGIN                                            $
  tra    = REFORM(tra_wav[j,*])                                      & $
  FOR k=0L, 2L DO BEGIN                                                $
    get_data,efi_gse__names[j,k],DATA=tempe                          & $
    get_data,efi_wvlt_names[j,k],DATA=tempw                          & $
    testx = (FINITE(tempe.Y) NE 0) AND (ABS(tempe.Y) GT 0.)          & $
    goodx = WHERE(testx,gdx)                                         & $
    tra_wav[j,0] = tra[0] > MIN(tempe.X[goodx],/NAN)                 & $
    tra_wav[j,1] = tra[1] < MAX(tempe.X[goodx],/NAN)
;; clean up
DELVAR,tempe,tempw,testx,goodx
;; Define EFI time ranges
tre_wav       = tra_wav




nz            = 21L
zmax_arr      = 1d1^(DINDGEN(nz)*20d0/(nz - 1) - 10d0)
;; => Determine EFI wavelet ranges
FOR j=0L, ntr - 1L DO BEGIN                                            $
  FOR k=0L, 2L DO BEGIN                                                $
    get_data,efi_wvlt_names[j,k],DATA=tempw                          & $
    testx = [MEAN(tempw.Y,/NAN),MAX(tempw.Y,/NAN)]                   & $
    IF (k EQ 0) THEN zra_0 = testx                                   & $
    zra_0[0] = zra_0[0] < testx[0]                                   & $
    zra_0[1] = zra_0[1] > testx[1]                                   & $
  ENDFOR                                                             & $
  gmin  = (WHERE(zmax_arr GE zra_0[0]))[0] - 1L                      & $
  gmax  = (WHERE(zmax_arr GE zra_0[1]))[0] - 1L                      & $
  options,REFORM(efi_wvlt_names[j,*]),'ZRANGE'                       & $
  options,REFORM(efi_wvlt_names[j,*]),'ZRANGE',[zmax_arr[gmin],zmax_arr[gmax]],/DEF
;; clean up
DELVAR,tempe,tempw,testx,tests

;; => Determine SCM wavelet ranges
FOR j=0L, ntr - 1L DO BEGIN                                            $
  FOR k=0L, 2L DO BEGIN                                                $
    get_data,scm_wvlt_names[j,k],DATA=tempw                          & $
    testx = [MEAN(tempw.Y,/NAN),MAX(tempw.Y,/NAN)]                   & $
    IF (k EQ 0) THEN zra_0 = testx                                   & $
    zra_0[0] = zra_0[0] < testx[0]                                   & $
    zra_0[1] = zra_0[1] > testx[1]                                   & $
  ENDFOR                                                             & $
  gmin  = (WHERE(zmax_arr GE zra_0[0]))[0] - 1L                      & $
  gmax  = (WHERE(zmax_arr GE zra_0[1]))[0] - 1L                      & $
  options,REFORM(scm_wvlt_names[j,*]),'ZRANGE'                       & $
  options,REFORM(scm_wvlt_names[j,*]),'ZRANGE',[zmax_arr[gmin],zmax_arr[gmax]],/DEF
;; clean up
DELVAR,tempe,tempw,testx,tests




;; => Define file name prefixes
s_fsuff       = 'wavelet_n1-2-fce_'  ;; use (n+1/2)fce
f_pref        = 'EFI_GSE-'+vec_su+'_TH-'+scu[0]+'_efw-cor-DownSampled_'+s_fsuff[0]
opname        = op_n12_fce[0]

FOR j=0L, ntr - 1L DO BEGIN                                            $
  tra    = REFORM(tre_wav[j,*])                                      & $
  fnm    = file_name_times(tra,PREC=3)                               & $
  ftimes = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)               & $
  FOR k=0L, 2L DO BEGIN                                                $
    aname  = [efi_gse__names[j,k],efi_wvlt_names[j,k]]               & $
;    opname = [efi_conf_names[j,k],op_n12_fce[0]]                     & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[j]                          & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra      & $
    popen,fname[0],/LAND                                             & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra      & $
    pclose



;; => Define file name prefixes
s_fsuff       = 'wavelet_n1-2-fce_'
f_pref        = 'SCM_GSE-'+vec_su+'_TH-'+scu[0]+'_scw-HighPass_'+s_fsuff[0]
opname        = op_n12_fce[0]

FOR j=0L, ntr - 1L DO BEGIN                                            $
  tra    = REFORM(tre_wav[j,*])                                      & $
  fnm    = file_name_times(tra,PREC=3)                               & $
  ftimes = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)               & $
  FOR k=0L, 2L DO BEGIN                                                $
    aname  = [scm_gse__names[j,k],scm_wvlt_names[j,k]]               & $
;    opname = [scm_conf_names[j,k],op_n12_fce[0]]                     & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[j]                          & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra      & $
    popen,fname[0],/LAND                                             & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra      & $
    pclose



;;----------------------------------------------------------------------------------------
;; => Zoom-in on Wavelet Plots
;;----------------------------------------------------------------------------------------

;;--------------------------------------------------
;; Interval 0
;;--------------------------------------------------
jj               = 0L
temp0            = tdate[0]+'/'+['08:59:43.488','08:59:43.789']
temp1            = tdate[0]+'/'+['08:59:43.982','08:59:44.460']
temp2            = tdate[0]+'/'+['08:59:44.580','08:59:44.769']
temp3            = tdate[0]+'/'+['08:59:44.761','08:59:44.894']
temp4            = tdate[0]+'/'+['08:59:44.911','08:59:45.057']
temp5            = tdate[0]+'/'+['08:59:45.246','08:59:45.414']
temp6            = tdate[0]+'/'+['08:59:45.496','08:59:45.616']
temp7            = tdate[0]+'/'+['08:59:45.616','08:59:45.909']
temp8            = tdate[0]+'/'+['08:59:45.943','08:59:46.235']
temp9            = tdate[0]+'/'+['08:59:46.240','08:59:46.566']
temp10           = tdate[0]+'/'+['08:59:46.661','08:59:47.087']
temp11           = tdate[0]+'/'+['08:59:47.087','08:59:47.332']
temp12           = tdate[0]+'/'+['08:59:47.383','08:59:47.590']
temp13           = tdate[0]+'/'+['08:59:47.740','08:59:48.020']
temp14           = tdate[0]+'/'+['08:59:48.015','08:59:48.243']
temp15           = tdate[0]+'/'+['08:59:48.299','08:59:48.544']
temp16           = tdate[0]+'/'+['08:59:48.652','08:59:48.940']
temp17           = tdate[0]+'/'+['08:59:48.948','08:59:49.232']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13],[temp14],[temp15],[temp16],[temp17]])

;; => EFI Plots
s_fsuff          = 'wavelet_n1-2-fce_'  ;; use (n+1/2)fce
f_pref           = 'EFI_GSE-'+vec_su+'_TH-'+scu[0]+'_efw-cor-DownSampled_'+s_fsuff[0]
opname           = op_n12_fce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [efi_gse__names[jj,k],efi_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

;; => SCM Plots
s_fsuff       = 'wavelet_n1-2-fce_'
f_pref        = 'SCM_GSE-'+vec_su+'_TH-'+scu[0]+'_scw-HighPass_'+s_fsuff[0]
opname        = op_n12_fce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [scm_gse__names[jj,k],scm_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

;; => EFI, SCM, and Poynting Flux Plots
s_fsuff = 'PoyntingFlux_'
f_pref  = 'FGM-fgh-GSE_TH-'+scu[0]+'_efw-cor-DownSampled_scw-HighPass_'+s_fsuff[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  aname       = [efds_names[jj],bfhp_names[jj],poyn_names[jj]]               & $
  fname       = f_pref[0]+ftimes[0]+iwavsfx[jj]                              & $
    tplot,aname,TRANGE=tra,/NOM                                              & $
  popen,fname[0],/PORT                                                       & $
    tplot,aname,TRANGE=tra,/NOM                                              & $
  pclose


;;--------------------------------------------------
;; Interval 1
;;--------------------------------------------------
jj               = 1L
temp0            = tdate[0]+'/'+['08:59:49.326','08:59:50.241']
temp1            = tdate[0]+'/'+['08:59:50.301','08:59:50.605']
temp2            = tdate[0]+'/'+['08:59:50.635','08:59:50.905']
temp3            = tdate[0]+'/'+['08:59:51.080','08:59:51.392']
temp4            = tdate[0]+'/'+['08:59:51.422','08:59:51.504']
temp5            = tdate[0]+'/'+['08:59:51.555','08:59:51.630']
temp6            = tdate[0]+'/'+['08:59:51.683','08:59:51.876']
temp7            = tdate[0]+'/'+['08:59:51.987','08:59:52.252']
temp8            = tdate[0]+'/'+['08:59:52.496','08:59:52.595']
temp9            = tdate[0]+'/'+['08:59:52.864','08:59:52.945']
temp10           = tdate[0]+'/'+['08:59:53.574','08:59:53.771']
temp11           = tdate[0]+'/'+['08:59:54.370','08:59:54.570']
temp12           = tdate[0]+'/'+['08:59:54.875','08:59:55.055']
temp13           = tdate[0]+'/'+['08:59:55.393','08:59:55.701']
temp14           = tdate[0]+'/'+['08:59:52.830','08:59:52.966']
temp15           = tdate[0]+'/'+['08:59:52.870','08:59:52.940']
temp16           = tdate[0]+'/'+['08:59:52.890','08:59:52.930']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13],[temp14],[temp15],[temp16]])

;; => EFI Plots
s_fsuff          = 'wavelet_n1-2-fce_'  ;; use (n+1/2)fce
f_pref           = 'EFI_GSE-'+vec_su+'_TH-'+scu[0]+'_efw-cor-DownSampled_'+s_fsuff[0]
opname           = op_n12_fce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [efi_gse__names[jj,k],efi_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

s_fsuff          = 'wavelet_n-fce_'  ;; use nfce
f_pref           = 'EFI_GSE-'+vec_su+'_TH-'+scu[0]+'_efw-cor-DownSampled_'+s_fsuff[0]
opname           = op_nfce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [efi_gse__names[jj,k],efi_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

;; => SCM Plots
s_fsuff          = 'wavelet_n1-2-fce_'
f_pref           = 'SCM_GSE-'+vec_su+'_TH-'+scu[0]+'_scw-HighPass_'+s_fsuff[0]
opname           = op_n12_fce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [scm_gse__names[jj,k],scm_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

s_fsuff          = 'wavelet_n-fce_'
f_pref           = 'SCM_GSE-'+vec_su+'_TH-'+scu[0]+'_scw-HighPass_'+s_fsuff[0]
opname           = op_nfce[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  FOR k=0L, 2L DO BEGIN                                                        $
    aname       = [scm_gse__names[jj,k],scm_wvlt_names[jj,k]]                & $
    fname  = f_pref[k]+ftimes[0]+iwavsfx[jj]                                 & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    popen,fname[0],/LAND                                                     & $
      oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM,TRANGE=tra              & $
    pclose

;; => EFI, SCM, and Poynting Flux Plots
s_fsuff          = 'PoyntingFlux_'
f_pref           = 'FGM-fgh-GSE_TH-'+scu[0]+'_efw-cor-DownSampled_scw-HighPass_'+s_fsuff[0]
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  aname       = [efds_names[jj],bfhp_names[jj],poyn_names[jj]]               & $
  fname       = f_pref[0]+ftimes[0]+iwavsfx[jj]                              & $
    tplot,aname,TRANGE=tra,/NOM                                              & $
  popen,fname[0],/PORT                                                       & $
    tplot,aname,TRANGE=tra,/NOM                                              & $
  pclose



;;----------------------------------------------------------------------------------------
;; => Zoom-in and plot hodograms
;;----------------------------------------------------------------------------------------
magenta          = get_color_by_name('Magenta')
fgreen           = get_color_by_name('Forest Green')
orange           = get_color_by_name('Orange')
sunsym           = get_font_symbol('sun')
;; Define shock normal vector
gnorm            = [0.99012543d0,0.086580460d0,-0.0038282813d0]
;; renormalize
gnorm           /= SQRT(TOTAL(gnorm^2,/NAN))
;; Define shock normal string
gnorm_str        = 'n = '+format_vector_string(gnorm,PREC=4)+' [GSE]'
;; Define sun vector
sunv             = [1d0,0d0,0d0]
mag_name         = fgmnm[1]
get_data,mag_name[0],DATA=temp_bo,DLIM=dlim_bo,LIM=lim_bo
tmagf            = temp_bo.Y
tmagt            = temp_bo.X

chsz             = 1.25
multip           = '1 3'
xsize            = 500
ysize            = 1100
hscale           = 1d0
xposi            = hscale[0]*0.95 - 0.10
yposi            = hscale[0]*[0.99,0.90,0.81] - 0.10
zeros            = TRANSPOSE([0d0,0d0])
WINDOW,1,RETAIN=2,XSIZE=xsize,YSIZE=ysize
;; scale n to plot range
nvecxy           = TRANSPOSE(gnorm[[0,1]]*hscale[0]/SQRT(gnorm[0]^2 + gnorm[1]^2))
nvecxz           = TRANSPOSE(gnorm[[0,2]]*hscale[0]/SQRT(gnorm[0]^2 + gnorm[2]^2))
nvecyz           = TRANSPOSE(gnorm[[1,2]]*hscale[0]/SQRT(gnorm[1]^2 + gnorm[2]^2))
;; scale Xgse to plot range [50% shorter to avoid covering normal vector]
xvecxy           = TRANSPOSE(sunv[[0,1]]*hscale[0]/SQRT(sunv[0]^2 + sunv[1]^2))*5d-1
xvecxz           = TRANSPOSE(sunv[[0,2]]*hscale[0]/SQRT(sunv[0]^2 + sunv[2]^2))*5d-1
xvecyz           = TRANSPOSE(sunv[[1,2]]*hscale[0]/SQRT(sunv[1]^2 + sunv[2]^2))*5d-1
IF (TOTAL(FINITE(xvecyz)) EQ 0) THEN sun_sym = sunsym ELSE sun_sym = ''

;ath              = 1.75
ath              = 2.50
vec_shodo        = ['YvsX','ZvsX','ZvsY']
s_fsuff          = 'hodograms_'
f_pref           = 'EFI_GSE_TH-'+scu[0]+'_efw-cor-DownSampled_'+s_fsuff[0]
ex_bv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:magenta,THICK:ath,HTHICK:ath}
ex_nv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:fgreen,THICK:ath,HTHICK:ath}
ex_sv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:orange,THICK:ath,HTHICK:ath}

;;--------------------------------------------------
;; Interval 0
;;--------------------------------------------------
jj               = 0L
temp0            = tdate[0]+'/'+['08:59:43.488','08:59:43.789']
temp1            = tdate[0]+'/'+['08:59:43.982','08:59:44.460']
temp2            = tdate[0]+'/'+['08:59:44.580','08:59:44.769']
temp3            = tdate[0]+'/'+['08:59:44.761','08:59:44.894']
temp4            = tdate[0]+'/'+['08:59:44.911','08:59:45.057']
temp5            = tdate[0]+'/'+['08:59:45.246','08:59:45.414']
temp6            = tdate[0]+'/'+['08:59:45.496','08:59:45.616']
temp7            = tdate[0]+'/'+['08:59:45.616','08:59:45.909']
temp8            = tdate[0]+'/'+['08:59:45.943','08:59:46.235']
temp9            = tdate[0]+'/'+['08:59:46.240','08:59:46.566']
temp10           = tdate[0]+'/'+['08:59:46.661','08:59:47.087']
temp11           = tdate[0]+'/'+['08:59:47.087','08:59:47.332']
temp12           = tdate[0]+'/'+['08:59:47.383','08:59:47.590']
temp13           = tdate[0]+'/'+['08:59:47.740','08:59:48.020']
temp14           = tdate[0]+'/'+['08:59:48.015','08:59:48.243']
temp15           = tdate[0]+'/'+['08:59:48.299','08:59:48.544']
temp16           = tdate[0]+'/'+['08:59:48.652','08:59:48.940']
temp17           = tdate[0]+'/'+['08:59:48.948','08:59:49.232']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13],[temp14],[temp15],[temp16],[temp17]])
;;--------------------------------------------------
;; Interval 1
;;--------------------------------------------------
jj               = 1L
temp0            = tdate[0]+'/'+['08:59:49.326','08:59:50.241']
temp1            = tdate[0]+'/'+['08:59:50.301','08:59:50.605']
temp2            = tdate[0]+'/'+['08:59:50.635','08:59:50.905']
temp3            = tdate[0]+'/'+['08:59:51.080','08:59:51.392']
temp4            = tdate[0]+'/'+['08:59:51.422','08:59:51.504']
temp5            = tdate[0]+'/'+['08:59:51.555','08:59:51.630']
temp6            = tdate[0]+'/'+['08:59:51.683','08:59:51.876']
temp7            = tdate[0]+'/'+['08:59:51.987','08:59:52.252']
temp8            = tdate[0]+'/'+['08:59:52.496','08:59:52.595']
temp9            = tdate[0]+'/'+['08:59:52.864','08:59:52.945']
temp10           = tdate[0]+'/'+['08:59:53.574','08:59:53.771']
temp11           = tdate[0]+'/'+['08:59:54.370','08:59:54.570']
temp12           = tdate[0]+'/'+['08:59:54.875','08:59:55.055']
temp13           = tdate[0]+'/'+['08:59:55.393','08:59:55.701']
temp14           = tdate[0]+'/'+['08:59:52.830','08:59:52.966']
temp15           = tdate[0]+'/'+['08:59:52.870','08:59:52.940']
temp16           = tdate[0]+'/'+['08:59:52.890','08:59:52.930']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13],[temp14],[temp15],[temp16]])



xyz_name         = efds_names[jj]
get_data,xyz_name[0],DATA=temp_f,DLIM=dlim0,LIM=lim0

ttle             = dlim0.YTITLE  ;; Plot title
xyzmax           = MAX(ABS(temp_f.Y),/NAN)*1.05d0
xyran            = [-1d0,1d0]*xyzmax[0]

;; Define all XY-Ranges and Avg. B-field vectors
d                = !VALUES.D_NAN
n_tr             = N_ELEMENTS(temp_a[*,0])
xy_ran           = REPLICATE(!VALUES.D_NAN,n_tr,2L)
avg_bf           = REPLICATE(!VALUES.D_NAN,n_tr,3L)
FOR i=0L, n_tr - 1L DO BEGIN                                                   $
  xymx        = 0d0                                                          & $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  good_bo     = WHERE(temp_f.X GE tra[0] AND temp_f.X LE tra[1],gdbo)        & $
  IF (gdbo GT 0) THEN xymx = MAX(ABS(temp_f.Y[good_bo,*]),/NAN)*1.05d0       & $
  IF (xymx EQ 0) THEN xymx = xyzmax[0]                                       & $
  xy_ran[i,*] = [-1d0,1d0]*xymx[0]                                           & $
  good_bo     = WHERE(tmagt GE tra[0] AND tmagt LE tra[1],gdbo)              & $
  IF (gdbo GT 0) THEN abx = MEAN(tmagf[good_bo,0],/NAN) ELSE abx = d         & $
  IF (gdbo GT 0) THEN aby = MEAN(tmagf[good_bo,1],/NAN) ELSE aby = d         & $
  IF (gdbo GT 0) THEN abz = MEAN(tmagf[good_bo,2],/NAN) ELSE abz = d         & $
  avg_bf[i,*] = [abx[0],aby[0],abz[0]]

;; Define all Avg. B-field strings
avg_bf_str       = REPLICATE('',n_tr)
FOR i=0L, n_tr - 1L DO BEGIN                                                   $
  bvec        = REFORM(avg_bf[i,*])                                          & $
  bv_str      = format_vector_string(bvec,PREC=3)+' [nT, GSE]'               & $
  avg_bf_str[i] = 'Bo = '+bv_str[0]

;; Define all Avg. B-field magnitudes
avg_bm           = SQRT(TOTAL(avg_bf^2,2,/NAN)) # REPLICATE(1d0,3L)
;; normalize vectors
avg_bv           = avg_bf/avg_bm
;; Define all Avg. projection B-field magnitudes
avg_bxy          = SQRT(TOTAL(avg_bv[*,[0,1]]^2,2,/NAN)) # REPLICATE(1d0,2L)
avg_bxz          = SQRT(TOTAL(avg_bv[*,[0,2]]^2,2,/NAN)) # REPLICATE(1d0,2L)
avg_byz          = SQRT(TOTAL(avg_bv[*,[1,2]]^2,2,/NAN)) # REPLICATE(1d0,2L)
;; scale b to plot range
avg_b_vxy        = avg_bv[*,[0,1]]*hscale[0]/avg_bxy
avg_b_vxz        = avg_bv[*,[0,2]]*hscale[0]/avg_bxz
avg_b_vyz        = avg_bv[*,[1,2]]*hscale[0]/avg_byz


old_chsz         = !P.CHARSIZE
!P.CHARSIZE      = 0.75
FOR i=0L, n_tr - 1L DO BEGIN                                                   $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  xyra        = REFORM(xy_ran[i,*])                                          & $
  n_scl       = xyra[1]/hscale[0]*0.95                                       & $
  nxpos       = (xposi[0]-0.20)*n_scl[0]                                     & $
  nxpo2       = (xposi[0]+0.30)*n_scl[0]                                     & $
  nypos       = yposi*n_scl[0]                                               & $
  d_tr        = tra[1] - tra[0]                                              & $
  timespan,tra[0],d_tr[0],/SECONDS                                           & $
  tra_str     = time_string(tra,PREC=3)                                      & $
  tra_ttl     = tra_str[0]+'-'+STRMID(tra_str[1],11L)                        & $
  mttle       = 'EFW-GSE '+tra_ttl[0]                                        & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  fname       = f_pref[0]+ftimes[0]+iwavsfx[jj]                              & $
  xy_bo       = {DATA:1,COLOR:magenta,CHARSIZE:0.60,ORIENTATION:-90.}        & $
  xy_no       = {DATA:1,COLOR:fgreen ,CHARSIZE:0.60,ORIENTATION:-90.}        & $
  ex_xy       = {VERSUS:'xy',XRANGE:xyra,YRANGE:xyra,MULTI:multip,COLOR:250} & $
  ex_xz       = {VERSUS:'xz',XRANGE:xyra,YRANGE:xyra,ADDPANEL:1,COLOR:150}   & $
  ex_yz       = {VERSUS:'yz',XRANGE:xyra,YRANGE:xyra,ADDPANEL:1,COLOR: 50}   & $
  popen,fname[0],/PORT                                                       & $
    tplotxy,xyz_name[0],_EXTRA=ex_xy,MTITLE=mttle[0]                         & $
      plotxyvec,zeros,avg_b_vxy[i,*]*n_scl[0],_EXTRA=ex_bv                   & $
      plotxyvec,zeros,nvecxy*n_scl[0],_EXTRA=ex_nv                           & $
      plotxyvec,zeros,xvecxy*n_scl[0],_EXTRA=ex_sv                           & $
      XYOUTS,nxpo2[0],nypos[0],avg_bf_str[i],_EXTRA=xy_bo                    & $
      XYOUTS,nxpos[0],nypos[2],'Xgse',/DATA,COLOR=orange,CHARSIZE=chsz       & $
    tplotxy,xyz_name[0],_EXTRA=ex_xz,TITLE=''                                & $
      plotxyvec,zeros,avg_b_vxz[i,*]*n_scl[0],_EXTRA=ex_bv                   & $
      plotxyvec,zeros,nvecxz*n_scl[0],_EXTRA=ex_nv                           & $
      plotxyvec,zeros,xvecxz*n_scl[0],_EXTRA=ex_sv                           & $
      XYOUTS,nxpo2[0],nypos[1],gnorm_str[0],_EXTRA=xy_no                     & $
    tplotxy,xyz_name[0],_EXTRA=ex_yz,TITLE=''                                & $
      plotxyvec,zeros,avg_b_vyz[i,*]*n_scl[0],_EXTRA=ex_bv                   & $
      plotxyvec,zeros,nvecyz*n_scl[0],_EXTRA=ex_nv                           & $
      XYOUTS,nxpos[0],nypos[2],sun_sym,/DATA,COLOR=orange,CHARSIZE=1.50      & $
  pclose
!P.CHARSIZE      = old_chsz
























;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
; => Old
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
ath              = 2.5
ex_bv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:magenta,THICK:ath,HTHICK:ath}
ex_nv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:fgreen,THICK:ath,HTHICK:ath}
ex_sv            = {OVERPLOT:1,HSIZE:1.5,UARROWSIDE:'none',COLOR:orange,THICK:ath,HTHICK:ath}
tra         = time_double(REFORM(temp_a[i,*]))
xyra        = REFORM(xy_ran[i,*])
n_scl       = xyra[1]/hscale[0]*0.95
nxpos       = xposi[0]*n_scl[0]
nypos       = yposi*n_scl[0]
d_tr        = tra[1] - tra[0]
timespan,tra[0],d_tr[0],/SECONDS
tra_str     = time_string(tra,PREC=3)
tra_ttl     = tra_str[0]+'-'+STRMID(tra_str[1],11L)
mttle       = 'EFW-GSE '+tra_ttl[0]
fnm         = file_name_times(tra,PREC=3)
ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)
fname       = f_pref[0]+ftimes[0]+iwavsfx[jj]
ex_xy       = {VERSUS:'xy',XRANGE:xyra,YRANGE:xyra,MULTI:multip,COLOR:250}
ex_xz       = {VERSUS:'xz',XRANGE:xyra,YRANGE:xyra,ADDPANEL:1,COLOR:150}
ex_yz       = {VERSUS:'yz',XRANGE:xyra,YRANGE:xyra,ADDPANEL:1,COLOR: 50}
  tplotxy,xyz_name[0],_EXTRA=ex_xy,MTITLE=mttle[0]
    plotxyvec,zeros,avg_b_vxy[i,*]*n_scl[0],_EXTRA=ex_bv
    plotxyvec,zeros,nvecxy*n_scl[0],_EXTRA=ex_nv
    plotxyvec,zeros,xvecxy*n_scl[0],_EXTRA=ex_sv
    XYOUTS,nxpos[0],nypos[0],'B',/DATA,COLOR=magenta,  CHARSIZE=chsz
    XYOUTS,nxpos[0],nypos[1],'n',/DATA,COLOR=fgreen,   CHARSIZE=chsz
    XYOUTS,nxpos[0],nypos[2],'Xgse',/DATA,COLOR=orange,CHARSIZE=chsz
  tplotxy,xyz_name[0],_EXTRA=ex_xz,TITLE=''
    plotxyvec,zeros,avg_b_vxz[i,*]*n_scl[0],_EXTRA=ex_bv
    plotxyvec,zeros,nvecxz*n_scl[0],_EXTRA=ex_nv
    plotxyvec,zeros,xvecxz*n_scl[0],_EXTRA=ex_sv
  tplotxy,xyz_name[0],_EXTRA=ex_yz,TITLE=''
    plotxyvec,zeros,avg_b_vyz[i,*]*n_scl[0],_EXTRA=ex_bv
    plotxyvec,zeros,nvecyz*n_scl[0],_EXTRA=ex_nv
    XYOUTS,nxpos[0]*.90,nypos[2],sun_sym,/DATA,COLOR=orange,CHARSIZE=chsz


i                = 0L
;; Define time range
tra              = time_double(REFORM(temp_a[i,*]))
d_tr             = tra[1] - tra[0]
timespan,tra[0],d_tr[0],/SECONDS
;; Define plot title with time range
tra_str          = time_string(tra,PREC=3)
tra_ttl          = tra_str[0]+'-'+STRMID(tra_str[1],11L)
mttle            = 'EFW-GSE '+tra_ttl[0]

;; Determine Avg. Bo vector
good_bo          = WHERE(tmagt GE tra[0] AND tmagt LE tra[1],gdbo)
IF (gdbo GT 0) THEN avgbx = MEAN(tmagf[good_bo,0],/NAN) ELSE avgbx = !VALUES.D_NAN
IF (gdbo GT 0) THEN avgby = MEAN(tmagf[good_bo,1],/NAN) ELSE avgby = !VALUES.D_NAN
IF (gdbo GT 0) THEN avgbz = MEAN(tmagf[good_bo,2],/NAN) ELSE avgbz = !VALUES.D_NAN
avg_bmag         = SQRT(avgbx[0]^2 + avgby[0]^2 + avgbz[0]^2)
IF (FINITE(avg_bmag) EQ 0) THEN avg_bmag = 1d0
;; normalize vector
bvecxyz          = [avgbx[0],avgby[0],avgbz[0]]/avg_bmag[0]
;; scale b to plot range
bvecxy           = bvecxyz[[0,1]]*hscale[0]/SQRT(bvecxyz[0]^2 + bvecxyz[1]^2)
bvecxz           = bvecxyz[[0,2]]*hscale[0]/SQRT(bvecxyz[0]^2 + bvecxyz[2]^2)
bvecyz           = bvecxyz[[1,2]]*hscale[0]/SQRT(bvecxyz[1]^2 + bvecxyz[2]^2)



tplotxy,xyz_name[0],VERSUS='xy',XRANGE=xyran,YRANGE=xyran,MULTI=multip,COLOR=250,MTITLE=mttle[0]
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(bvecxy),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=magenta
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(nvecxy),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=fgreen
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(xvecxy),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=orange
  XYOUTS,xposi[0],yposi[0],'B',/DATA,COLOR=magenta,  CHARSIZE=chsz
  XYOUTS,xposi[0],yposi[1],'n',/DATA,COLOR=fgreen,   CHARSIZE=chsz
  XYOUTS,xposi[0],yposi[2],'Xgse',/DATA,COLOR=orange,CHARSIZE=chsz
tplotxy,xyz_name[0],VERSUS='xz',XRANGE=xyran,YRANGE=xyran,/ADDPANEL,COLOR=150
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(bvecxz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=magenta
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(nvecxz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=fgreen
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(xvecxz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=orange
tplotxy,xyz_name[0],VERSUS='yz',XRANGE=xyran,YRANGE=xyran,/ADDPANEL,COLOR= 50
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(bvecyz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=magenta
  plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(nvecyz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=fgreen
  IF (TOTAL(FINITE(xvecyz)) NE 0) THEN plotxyvec,TRANSPOSE([0d0,0d0]),TRANSPOSE(xvecyz),/OVERPLOT,HSIZE=1.5,UARROWSIDE='none',COLOR=orange
  IF (TOTAL(FINITE(xvecyz)) EQ 0) THEN XYOUTS,xposi[0]*.90,yposi[2],sun_sym,/DATA,COLOR=orange,CHARSIZE=chsz


;-----------------------------------------------------------------------------------------
; => Save Plots
;-----------------------------------------------------------------------------------------
sc      = probe[0]
scu     = STRUPCASE(sc[0])
pref    = 'th'+sc[0]+'_'
coord   = 'gse'
fgmnm   = pref[0]+'fgh_'+['mag',coord[0]]


stpref  = 'S__TimeSeries_'
sppref  = 'S__PowerSpectra_'
efwpre  = 'efw_cal_'
scwpre  = 'scw_cal_'
ffname  = ['efw','scw']
tfname  = ['corrected','HighPass']

s_fsuff = 'PoyntingFlux_'
fepref  = 'FGM-fgh-GSE_TH-'+scu[0]+'_'+ffname[0]+'_'+s_fsuff[0]
fbpref  = 'FGM-fgh-GSE_TH-'+scu[0]+'_'+ffname[1]+'_'+s_fsuff[0]

;;  Poynting flux TPLOT handles
st_nm   = tnames(pref[0]+stpref[0]+coord[0]+'*')
sp_nm   = tnames(pref[0]+sppref[0]+coord[0]+'*')
n_st    = N_ELEMENTS(st_nm)
f_suffx = '_INT'+STRING(LINDGEN(n_st),FORMAT='(I3.3)')

;;  EFI TPLOT handles
efinm   = tnames(pref[0]+efwpre[0]+coord[0]+'_'+tfname[0]+'*')

;;  SCM TPLOT handles
scmnm   = tnames(pref[0]+scwpre[0]+coord[0]+'_'+tfname[1]+'*')

;;  Save EFI Plots
FOR j=0L, nefi - 1L DO BEGIN                                         $
  aname  = [fgmnm,efinm,st_nm[j],sp_nm[j]]                         & $
  tra    = REFORM(tr_all_efi[j,*])                                 & $
  fnm    = file_name_times(tra,PREC=3)                             & $
  ftimes = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)             & $
  fname  = fepref[0]+ftimes[0]+f_suffx[j]                          & $
  tplot,aname,TRANGE=tra,/NOM                                      & $
  popen,fname[0],/PORT                                             & $
    tplot,aname,TRANGE=tra,/NOM                                    & $
  pclose



;;  Save SCM Plots
FOR j=0L, nscm - 1L DO BEGIN                                         $
  aname  = [fgmnm,scmnm,st_nm[j],sp_nm[j]]                         & $
  tra    = REFORM(tr_all_scm[j,*])                                 & $
  fnm    = file_name_times(tra,PREC=3)                             & $
  ftimes = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)             & $
  fname  = fbpref[0]+ftimes[0]+f_suffx[j]                          & $
  tplot,aname,TRANGE=tra,/NOM                                      & $
  popen,fname[0],/PORT                                             & $
    tplot,aname,TRANGE=tra,/NOM                                    & $
  pclose

;-----------------------------------------------------------------------------------------
; => Plot specific zoomed in views
;-----------------------------------------------------------------------------------------
st_nm   = tnames(pref[0]+stpref[0]+coord[0]+'*')
efinm   = tnames(pref[0]+efwpre[0]+coord[0]+'*')
scmnm   = tnames(pref[0]+scwpre[0]+coord[0]+'*')

n_st    = N_ELEMENTS(st_nm)
f_suffx = '_INT'+STRING(LINDGEN(n_st),FORMAT='(I3.3)')

s_fsuff = 'PoyntingFlux_'
fapref  = 'FGM-fgh-GSE_TH-'+scu[0]+'_efw-scw_'+s_fsuff[0]


;; Int 0
temp0            = tdate[0]+'/'+['08:59:43.488','08:59:43.789']
temp1            = tdate[0]+'/'+['08:59:43.982','08:59:44.460']
temp2            = tdate[0]+'/'+['08:59:44.580','08:59:44.769']
temp3            = tdate[0]+'/'+['08:59:44.761','08:59:44.894']
temp4            = tdate[0]+'/'+['08:59:44.911','08:59:45.057']
temp5            = tdate[0]+'/'+['08:59:45.246','08:59:45.414']
temp6            = tdate[0]+'/'+['08:59:45.496','08:59:45.616']
temp7            = tdate[0]+'/'+['08:59:45.616','08:59:45.909']
temp8            = tdate[0]+'/'+['08:59:45.943','08:59:46.235']
temp9            = tdate[0]+'/'+['08:59:46.240','08:59:46.566']
temp10           = tdate[0]+'/'+['08:59:46.661','08:59:47.087']
temp11           = tdate[0]+'/'+['08:59:47.087','08:59:47.332']
temp12           = tdate[0]+'/'+['08:59:47.383','08:59:47.590']
temp13           = tdate[0]+'/'+['08:59:47.740','08:59:48.020']
temp14           = tdate[0]+'/'+['08:59:48.015','08:59:48.243']
temp15           = tdate[0]+'/'+['08:59:48.299','08:59:48.544']
temp16           = tdate[0]+'/'+['08:59:48.652','08:59:48.940']
temp17           = tdate[0]+'/'+['08:59:48.948','08:59:49.232']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13],[temp14],[temp15],[temp16],[temp17]])
jj               = 0L
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  anames      = [fgmnm,efinm,scmnm,st_nm[jj]]                                & $
  fname_a     = fapref[0]+ftimes[0]+f_suffx[jj]                              & $
  tplot,anames,TRANGE=tra,/NOM                                               & $
  popen,fname_a[0],/PORT                                                     & $
    tplot,anames,TRANGE=tra,/NOM                                             & $
  pclose




;; Int 1
temp0            = tdate[0]+'/'+['08:59:49.326','08:59:50.241']
temp1            = tdate[0]+'/'+['08:59:50.301','08:59:50.605']
temp2            = tdate[0]+'/'+['08:59:50.635','08:59:50.905']
temp3            = tdate[0]+'/'+['08:59:51.080','08:59:51.392']
temp4            = tdate[0]+'/'+['08:59:51.422','08:59:51.504']
temp5            = tdate[0]+'/'+['08:59:51.555','08:59:51.630']
temp6            = tdate[0]+'/'+['08:59:51.683','08:59:51.876']
temp7            = tdate[0]+'/'+['08:59:51.987','08:59:52.252']
temp8            = tdate[0]+'/'+['08:59:52.496','08:59:52.595']
temp9            = tdate[0]+'/'+['08:59:52.864','08:59:52.945']
temp10           = tdate[0]+'/'+['08:59:53.574','08:59:53.771']
temp11           = tdate[0]+'/'+['08:59:54.370','08:59:54.570']
temp12           = tdate[0]+'/'+['08:59:54.875','08:59:55.055']
temp13           = tdate[0]+'/'+['08:59:55.393','08:59:55.701']
temp_a           = TRANSPOSE([[temp0],[temp1],[temp2],[temp3],[temp4],[temp5],[temp6],[temp7],[temp8],[temp9],$
                    [temp10],[temp11],[temp12],[temp13]])
jj               = 1L
FOR i=0L, N_ELEMENTS(temp_a[*,0]) - 1L DO BEGIN                                $
  tra         = time_double(REFORM(temp_a[i,*]))                             & $
  fnm         = file_name_times(tra,PREC=3)                                  & $
  ftimes      = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)                  & $
  anames      = [fgmnm,efinm,scmnm,st_nm[jj]]                                & $
  fname_a     = fapref[0]+ftimes[0]+f_suffx[jj]                              & $
  tplot,anames,TRANGE=tra,/NOM                                               & $
  popen,fname_a[0],/PORT                                                     & $
    tplot,anames,TRANGE=tra,/NOM                                             & $
  pclose












;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
; => Extras
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
inpre       = 'thb_efw_cal_corrected_DownSampled_gse'
in_names    = inpre[0]+'_INT00'+['0','1']
out_name0   = inpre[0]+['x','y','z']+'_INT000'
out_name1   = inpre[0]+['x','y','z']+'_INT001'
out_names   = TRANSPOSE([[out_name0],[out_name1]])

themis_load_wavelets,in_names,out_names,COORD='gse',UNITS='mV/m',INSTRUMENT='efw',SPACECRAFT='THEMIS-B'



ltag        = ['LEVELS','C_ANNOTATION','YLOG','C_THICK']
lims        = CREATE_STRUCT(ltag,1.0,'95%',1,1.5)
enames      = out_name1
wnames      = enames+'_wavelet'
op_conf     = wnames+'_Conf_Level_95'
op_fce      = 'thb_fgh_fci_flh_fce'
vec_s       = ['x','y','z']
vec_su      = STRUPCASE(vec_s)

options,wnames+'*','yrange'
options,wnames+'*','yrange',[1d1,4096d0],/def
options,op_fce,'yrange'
options,op_fce,'yrange',[1d1,4096d0],/def
options,op_fce,'ylog'
options,op_fce,'ylog',1,/def

;t_suff      = '2009-07-13_0859x50.651-0859x50.931'
t_suff      = '2009-07-13_0859x51.075-0859x51.233'
;t_suff      = '2009-07-13_0859x52.830-0859x52.966'
t_prefs     = 'efw_corrected_DownSampled_'+t_suff[0]

FOR k=0L, 2L DO BEGIN                                   $
  aname  = [enames[k],wnames[k]]                      & $
  opname = [op_conf[k],op_fce[0]]                     & $
  fname  = t_prefs[0]+'_'+vec_su[k]+'-GSE'            & $
    oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM    & $
  popen,fname[0],/LAND                                & $
    oplot_tplot_spec,aname,opname,LIMITS=lims,/NOM    & $
  pclose





; => Load ESA Save Files
sc      = probe[0]
inames  = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
mdir    = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_esa_save/'+tdate[0]+'/')
ifiles  = FILE_SEARCH(mdir,inames[0])
RESTORE,ifiles[0]

;; => Redefine structures
dat_i     = peib_df_arr_b
i_time0   = dat_i.TIME
i_time1   = dat_i.END_TIME
;; Keep only structures between defined time range
;tr_jj     = tdate[0]+'/09:'+['18:34.000','20:10.000']
tr_jj     = tdate[0]+'/'+['08:50:00.000','09:20:10.000']
trtt      = time_double(tr_jj)
good_i    = WHERE(i_time0 GE trtt[0] AND i_time1 LE trtt[1],gdi)
PRINT,';', gdi
;          31




coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
magname   = pref[0]+'fgh_'+coord[0]   ;; 'fgh' GSE TPLOT handle
spperi    = pref[0]+'state_spinper'   ;; spacecraft spin period TPLOT handle
vel_name  = pref[0]+'peib_velocity_'+coord[0]
scname    = tnames(pref[0]+'peib_sc_pot')

dat_i     = peib_df_arr_b[good_i]
modify_themis_esa_struc,dat_i
dat_igse  = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname,VEL_NAME=vname_n

add_scpot,dat_igse,scname[0]
magn_1    = pref[0]+'fgs_dsl'
magn_2    = pref[0]+'fgh_dsl'
add_magf2,dat_igse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_igse,magn_2[0],/LEAVE_ALONE
add_vsw2,dat_i0,vel_name[0],/LEAVE_ALONE


dat_0   = dat_igse[j]
vec1    = dat_0.MAGF
vec2    = dat_0.VSW
WSET,2
WSHOW,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]






dat_i0    = peib_df_arr_b[good_i]
modify_themis_esa_struc,dat_i0

coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
magname   = pref[0]+'fgh_'+coord[0]   ;; 'fgh' GSE TPLOT handle
spperi    = pref[0]+'state_spinper'   ;; spacecraft spin period TPLOT handle
vel_name  = pref[0]+'peib_velocity_'+coord[0]
scname    = tnames(pref[0]+'peib_sc_pot')

add_scpot,dat_i0,scname[0]
magn_1    = pref[0]+'fgs_gse'
magn_2    = pref[0]+'fgh_gse'
add_magf2,dat_i0,magn_1[0],/LEAVE_ALONE
add_magf2,dat_i0,magn_2[0],/LEAVE_ALONE
add_vsw2,dat_i0,vel_name[0],/LEAVE_ALONE


ngrid    = 30L
sunv     = [1.,0.,0.]
sunn     = 'Sun Dir.'
xname    = 'B!Do!N'
yname    = 'V!Dsw!N'
vlim     = 25e2
ns       = 7L
smc      = 1
smct     = 1
dfmax    = 1d-1
dfmin    = 1d-15
normnm   = 'Shock Normal[0]'
vcirc    = 5d2
dfra     = [1d-14,1d-8]
interpo  = 0

j        = 4L
dat_0    = dat_i0[j]
vec2     = dat_0[0].VSW
WSET,1
WSHOW,1
contour_esa_htr_1plane,dat_0,magname[0],vec2,spperi[0],VLIM=vlim[0],NGRID=ngrid[0],    $
                       XNAME=xname[0],YNAME=yname[0],SM_CUTS=smc[0],NSMOOTH=ns[0],     $
                       /ONE_C,VCIRC=vcirc,EX_VEC0=gnorm,EX_VN0=normnm[0],              $
                       EX_VEC1=sunv,EX_VN1=sunn[0],PLANE='xy',/NO_REDF,INTERP=interpo, $
                       SM_CONT=smct[0],DFRA=dfra,DFMIN=dfmin[0],DFMAX=dfmax[0],        $
                       MAGF_NAME=magname[0],VEL_NAME=vel_name[0]






