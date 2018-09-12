;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
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

; => Compile necessary routines
@comp_lynn_pros
thm_init
; => Date/Time and Probe
tdate          = '2009-09-26'
tr_00          = tdate[0]+'/'+['12:00:00','17:40:00']
date           = '092609'
probe          = 'a'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
;; => Restore TPLOT session
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]+'.tplot'
file           = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0

!themis.VERBOSE = 2
tplot_options,'VERBOSE',2


pref           = 'th'+sc[0]+'_'
pos_gse        = 'th'+sc[0]+'_state_pos_gse'
dtxncn_tpn     = pref[0]+'dx_n_dt_tramp'
dtxnrci_tpn    = pref[0]+'dxn_rci_dt_tramp'
dtxnLii_tpn    = pref[0]+'dxn_Lii_dt_tramp'
;;  Define tick marks
names2         = [REVERSE(pos_gse[0]+['_x','_y','_z']),dtxncn_tpn[0],dtxnrci_tpn[0],dtxnLii_tpn[0]]
tplot_options,VAR_LABEL=names2
options,tnames(),'LABFLAG',2,/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='EFI & SCM Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01

coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
velname        = pref[0]+'peib_velocity_'+coord[0]
magname        = pref[0]+'fgh_'+coord[0]
fgmnm          = pref[0]+'fgh_'+['mag',coord[0]]
tr_jj          = time_double(tdate[0]+'/'+['15:48:20','15:58:25'])

tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;; => Get |S(w,k)| and *eta* |j|^2
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_in       = 'gse'
coord_out      = 'nif_S1986a'
n_pint         = 2L
int_snum       = STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
tsuffix        = '_INT'+int_snum
nsm            = 10L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
suffx          = '_sm'+nsms[0]+'pts'

;;  *eta* TPLOT name
name0          = 'Anom_Resistivities'
mid_nme2       = 'efw_cal-cor_DS_'
eta_name       = tnames(pref[0]+mid_nme2[0]+name0[0]+tsuffix)
;;  |S(w,k)| TPLOT names
mid_nmsP       = 'efw-scw-cal_ExB-Power_'
out_SnameP     = tnames(pref[0]+mid_nmsP[0]+coord_out[0]+tsuffix)
;;  |j|^2 TPLOT name
mid_j2sm       = 'jmags_fgh_nif_S1986a_squared'+suffx[0]
cur_nmmag2     = tnames(pref[0]+mid_j2sm[0])
;;---------------------------------------
;; => Get TPLOT data
;;---------------------------------------
;;  |S(w,k)|
get_data,out_SnameP[0],DATA=temp_SP0,DLIM=dlim_SP0,LIM=lim_SP0
get_data,out_SnameP[1],DATA=temp_SP1,DLIM=dlim_SP1,LIM=lim_SP1
;;  *eta*
get_data,eta_name[0],DATA=temp_eta0,DLIM=dlim_eta0,LIM=lim_eta0
get_data,eta_name[1],DATA=temp_eta1,DLIM=dlim_eta1,LIM=lim_eta1
;;  |j|^2
get_data,cur_nmmag2[0],DATA=temp_j20,DLIM=dlim_j20,LIM=lim_j20
;;---------------------------------------
;; => Define time range
;;---------------------------------------
t_minj         =  MIN(temp_j20.X,/NAN)
t_maxj         =  MAX(temp_j20.X,/NAN)
t_min          =  MIN([temp_SP0.X,temp_eta0.X],/NAN) > t_minj[0]
t_max          = (MAX([temp_SP1.X,temp_eta1.X],/NAN) < t_maxj[0]) > t_min[0]
PRINT,';;  ', t_min[0] MOD 864d2, t_max[0] MOD 864d2, t_max[0] - t_min[0]
;;         57182.692       57195.567       12.874878

;; => Keep only data between these time ranges
jmag__t        = temp_j20.X
jmag_sq        = temp_j20.Y*1d-6  ;; A^(+2) m^(-2)
good           = WHERE(jmag__t GE t_min[0] AND jmag__t LE t_max[0],gd)
PRINT,';;  ', gd
;;          1648

IF (gd GT 0) THEN jmag_sq_t   = jmag__t[good] ELSE jmag_sq_t   = d
IF (gd GT 0) THEN jmag_sq_val = jmag_sq[good] ELSE jmag_sq_val = d
;;---------------------------------------
;; => Combine intervals
;;---------------------------------------
;;  *eta*
eta__t__int0   = temp_eta0.X
eta_val_int0   = temp_eta0.Y      ;; Ω m
eta__t__int1   = temp_eta1.X
eta_val_int1   = temp_eta1.Y      ;; Ω m
eta_vals       = [eta_val_int0,eta_val_int1]
eta_t          = [eta__t__int0,eta__t__int1]
;;  |S(w,k)|
SPF__t__int0   = temp_SP0.X
SPF_val_int0   = temp_SP0.Y       ;; µW m^(-2)
SPF__t__int1   = temp_SP1.X
SPF_val_int1   = temp_SP1.Y       ;; µW m^(-2)
SPF_vals       = [SPF_val_int0,SPF_val_int1]
SPF_t          = [SPF__t__int0,SPF__t__int1]

nsm            = 10L
sm_SPF_vals    = SMOOTH(SPF_vals,nsm[0],/NAN,/EDGE_TRUNCATE)
;;-------------------------------------------------------
;; => Interpolate |S(w,k)| and *eta* to |j|^2 timestamps
;;-------------------------------------------------------
SPF_vals_jt    = interp(SPF_vals,SPF_t,jmag_sq_t,/NO_EXTRAP)
sm_SPF_vals_jt = interp(sm_SPF_vals,SPF_t,jmag_sq_t,/NO_EXTRAP)

eta__iawL88_jt = interp(eta_vals[*,0],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_lhdiC85_jt = interp(eta_vals[*,1],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_lhdiL88_jt = interp(eta_vals[*,2],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_ecdiL88_jt = interp(eta_vals[*,3],eta_t,jmag_sq_t,/NO_EXTRAP)
;;---------------------------------------
;; => Compare |S(w,k)| with *eta* |j|^2
;;---------------------------------------
eta_j2__iawL88 = (eta__iawL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_lhdiC85 = (eta_lhdiC85_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_lhdiL88 = (eta_lhdiL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_ecdiL88 = (eta_ecdiL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
all_eta_j2     = [[eta_j2__iawL88],[eta_j2_lhdiC85],[eta_j2_lhdiL88],[eta_j2_ecdiL88]]
;;---------------------------------------
;; => Print values to ASCII file
;;---------------------------------------
fname          = 'Integrated-FFT-Poynting-Flux-Sm-NotSm_Dissipation-Rate_'+tdate[0]+'.txt'
mform          = '(a30,2E15.5,4E15.5)'

scets          = time_string(jmag_sq_t,PREC=3)
nvals          = N_ELEMENTS(scets)

;;  Open file
OPENW,gunit,fname[0],/GET_LUN
FOR i=0L, nvals - 1L DO BEGIN    $
  PRINTF,gunit,FORMAT=mform,scets[i],SPF_vals_jt[i],sm_SPF_vals_jt[i],REFORM(all_eta_j2[i,*])
;;  Close file
FREE_LUN,gunit





;;----------------------------------------------------------------------------------------
;; => Get |S(w,k)| and *eta* |j|^2 from ASCII files
;;----------------------------------------------------------------------------------------
mform          = '(a30,2E15.5,4E15.5)'
mdir           = FILE_EXPAND_PATH('')
tdate0         = '2009-07-13'
tdate1         = '2009-09-26'
tdate_01       = '['+tdate0[0]+', '+tdate1[0]+']'
tdate_01f      = tdate0[0]+'_and_'+tdate1[0]

fname0         = 'Integrated-FFT-Poynting-Flux-Sm-NotSm_Dissipation-Rate_'+tdate0[0]+'.txt'
fname1         = 'Integrated-FFT-Poynting-Flux-Sm-NotSm_Dissipation-Rate_'+tdate1[0]+'.txt'
file0          = FILE_SEARCH(mdir,fname0[0])
file1          = FILE_SEARCH(mdir,fname1[0])

nl0            = FILE_LINES(file0[0])
nl1            = FILE_LINES(file1[0])
n              = nl0 + nl1

scets_01       = STRARR(n)           ;; e.g., 2009-09-26/15:53:02.695
SPF_jt_01      = DBLARR(n)
sm_SPF_jt_01   = DBLARR(n)
all_eta_j2_01  = DBLARR(n,4L)

a              = ''
b              = DBLARR(2)
c              = DBLARR(4)
;;  Open 1st file
OPENR,gunit,file0[0],/GET_LUN
FOR i=0L, nl0 - 1L DO BEGIN                $
  READF,gunit,FORMAT=mform,a,b,c         & $
  scets_01[i]         = STRTRIM(a[0],2)  & $
  SPF_jt_01[i]        = b[0]             & $
  sm_SPF_jt_01[i]     = b[1]             & $
  all_eta_j2_01[i,0]  = c[0]             & $
  all_eta_j2_01[i,1]  = c[1]             & $
  all_eta_j2_01[i,2]  = c[2]             & $
  all_eta_j2_01[i,3]  = c[3]
;;  Close file
FREE_LUN,gunit


a              = ''
b              = DBLARR(2)
c              = DBLARR(4)
;;  Open 2nd file
OPENR,gunit,file1[0],/GET_LUN
FOR j=0L, nl1 - 1L DO BEGIN                $
  i                   = j[0] + nl0[0]    & $
  READF,gunit,FORMAT=mform,a,b,c         & $
  scets_01[i]         = STRTRIM(a[0],2)  & $
  SPF_jt_01[i]        = b[0]             & $
  sm_SPF_jt_01[i]     = b[1]             & $
  all_eta_j2_01[i,0]  = c[0]             & $
  all_eta_j2_01[i,1]  = c[1]             & $
  all_eta_j2_01[i,2]  = c[2]             & $
  all_eta_j2_01[i,3]  = c[3]
;;  Close file
FREE_LUN,gunit


;;---------------------------------------
;; => Save correlation plots
;;---------------------------------------
Delta_str      = STRUPCASE(get_greek_letter('delta'))
mu__str        = get_greek_letter('mu')
muo_str        = mu__str[0]+'!Do!N'
eta_str        = get_greek_letter('eta')
omega_str      = get_greek_letter('omega')

yttle          = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle          = '|S| [FFT Power, '+mu__str[0]+'W/m!U-2!N'+']'
pttle          = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate_01[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1}
WSET,1
PLOT,SPF_jt_01,all_eta_j2_01[*,0],_EXTRA=pstr
  OPLOT,SPF_jt_01,all_eta_j2_01[*,0],PSYM=2,COLOR=50
  OPLOT,sm_SPF_jt_01,all_eta_j2_01[*,0],PSYM=7,COLOR=250

ind_0          = LINDGEN(nl0)
ind_1          = LINDGEN(nl1) + nl0
WSET,1
  PLOT,SPF_jt_01,all_eta_j2_01[*,0],_EXTRA=pstr
    OPLOT,SPF_jt_01[ind_0],all_eta_j2_01[ind_0,0],PSYM=2,COLOR= 50
    OPLOT,SPF_jt_01[ind_1],all_eta_j2_01[ind_1,0],PSYM=2,COLOR=250
    ;; output legend
    XYOUTS,0.15,0.90,'* = '+tdate0[0],/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'* = '+tdate1[0],/NORMAL,COLOR=250



pttle = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate_01[0]
popen,'Dissipation-Rate_vs_Integrated-FFT-Poynting-Flux_'+tdate_01f[0],/LAND
;  mu__strps      = mu__str[0]
;  eta_strps      = eta_str[0]
  mu__strps      = get_greek_letter('mu')
  eta_strps      = get_greek_letter('eta')
  yttleps        = eta_strps[0]+'|j|!U2!N [Dissipation, '+mu__strps[0]+'W m!U-3!N'+']'
  xttleps        = '|S| [FFT Power, '+mu__strps[0]+'W/m!U-2!N'+']'
  pstrps         = {TITLE:pttle,XTITLE:xttleps,YTITLE:yttleps,YLOG:1,XLOG:1,NODATA:1}
  PLOT,SPF_jt_01,all_eta_j2_01[*,0],_EXTRA=pstr
    OPLOT,SPF_jt_01[ind_0],all_eta_j2_01[ind_0,0],PSYM=2,COLOR= 50
    OPLOT,SPF_jt_01[ind_1],all_eta_j2_01[ind_1,0],PSYM=2,COLOR=250
    ;; output legend
    XYOUTS,0.15,0.90,'* = '+tdate0[0],/NORMAL,COLOR= 50
    XYOUTS,0.15,0.85,'* = '+tdate1[0],/NORMAL,COLOR=250
pclose














;;----------------------------------------------------------------------------------------
;; => Define NIF rotations
;;     => 1st set of time ranges [shock RH solutions]
;;        {Use Scudder et al., [1986a]}
;;----------------------------------------------------------------------------------------
;;  Shock Parameters
vshn_up        =   26.23459d0
ushn_up        = -335.99324d0
gnorm          = [0.95576882d0,-0.18012919d0,-0.14100009d0]  ;; GSE
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-307.345d0,65.0927d0,30.3775d0]
vswi_dn        = [-54.9544d0,43.4793d0,-18.3793d0]
magf_up        = [1.54738d0,-0.185112d0,-2.65947d0]
magf_dn        = [-1.69473d0,-14.2039d0,1.26029d0]

;; => X'-vector
xvnor          = gnorm/NORM(REFORM(gnorm))
;; => Y'-vector
yvect          = my_crossp_2(magf_dn,magf_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))
;; => Z'-vector
zvect          = my_crossp_2(xvnor,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))
;; => Rotation Matrix from NIF to GSE
rotgse         = TRANSPOSE([[xvnor],[yvnor],[zvnor]])
;; => Define rotation from GSE to NIF
rotnif         = LA_INVERT(rotgse)
PRINT,rotnif
;;      0.76459876     -0.34728280      -1.3434516
;;      0.26808354      0.21143269       1.5470961
;;     -0.15983501     -0.97395870      0.16080181


;;----------------------------------------------------------------------------------------
;;  Rotate FGM B-fields into NIF
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
fgm_pren       = pref[0]+['fgs_','fgl_','fgh_']
coord_in       = 'gse'
coord_out      = 'nif_S1986a'
fgm_nin        = fgm_pren+coord_in[0]
fgm_nout       = fgm_pren+coord_out[0]

;;------------------------------------
;;  fgs
;;------------------------------------
mode           = 'fgs'
jj             = 0L
ytcoordout     = 'NIF[S1986a]'
get_data,fgm_nin[jj],DATA=temp,DLIM=dlim,LIM=lim
fgm_t          = temp.X
fgm_B          = temp.Y
;;  Define sample rate
srate_fgm      = DOUBLE(sample_rate(fgm_t,GAP_THRESH=6d0,/AVE))
sr_fgm_str     = STRTRIM(STRING(srate_fgm[0],FORMAT='(f15.2)'),2L)
;;  Fix YSUBTITLE
ysubttle       = '[th'+sc[0]+' '+sr_fgm_str[0]+' sps, L2]'
str_element,dlim,'YSUBTITLE',ysubttle[0],/ADD_REPLACE
;; => Send back to TPLOT but without the unnecessary *_IND* tags
store_data,fgm_nin[jj],DATA={X:fgm_t,Y:fgm_B},DLIM=dlim,LIM=lim
;;  Fix YSUBTITLE for all th*_fgs_*
fgs_nms        = tnames(fgm_pren[0]+'*')
options,'tha_fgs_fci_flh_fce','YTITLE' 
options,'tha_fgs_fci_flh_fce','YTITLE',mode[0]+' [fci,flh,fce]',/DEF
options,fgs_nms,'YSUBTITLE'
options,fgs_nms,'YSUBTITLE',ysubttle[0],/DEF

;; => Change YTITLE and coordinates in DLIM
yttle          = 'B ['+STRUPCASE(mode[0])+', '+ytcoordout[0]+', nT]'
str_element,dlim,'YTITLE',yttle[0],/ADD_REPLACE
str_element,dlim,'DATA_ATT.COORD_SYS','nif',/ADD_REPLACE
;; => Rotate B-fields
B_nif          = REFORM(rotnif ## fgm_B)
;; => Send NIF B-fields to TPLOT [but without the unnecessary *_IND* tags]
store_data,fgm_nout[jj],DATA={X:fgm_t,Y:B_nif},DLIM=dlim,LIM=lim

;;------------------------------------
;;  fgl
;;------------------------------------
mode           = 'fgl'
jj             = 1L
ytcoordout     = 'NIF[S1986a]'
get_data,fgm_nin[jj],DATA=temp,DLIM=dlim,LIM=lim
fgm_t          = temp.X
fgm_B          = temp.Y
;; => Send back to TPLOT but without the unnecessary *_IND* tags
store_data,fgm_nin[jj],DATA={X:fgm_t,Y:fgm_B},DLIM=dlim,LIM=lim

;; => Change YTITLE and coordinates in DLIM
yttle          = 'B ['+STRUPCASE(mode[0])+', '+ytcoordout[0]+', nT]'
str_element,dlim,'YTITLE',yttle[0],/ADD_REPLACE
str_element,dlim,'DATA_ATT.COORD_SYS','nif',/ADD_REPLACE
;; => Rotate B-fields
B_nif          = REFORM(rotnif ## fgm_B)
;; => Send NIF B-fields to TPLOT [but without the unnecessary *_IND* tags]
store_data,fgm_nout[jj],DATA={X:fgm_t,Y:B_nif},DLIM=dlim,LIM=lim

;;------------------------------------
;;  fgh
;;------------------------------------
mode           = 'fgh'
jj             = 2L
ytcoordout     = 'NIF[S1986a]'
get_data,fgm_nin[jj],DATA=temp,DLIM=dlim,LIM=lim
fgm_t          = temp.X
fgm_B          = temp.Y
;; => Send back to TPLOT but without the unnecessary *_IND* tags
store_data,fgm_nin[jj],DATA={X:fgm_t,Y:fgm_B},DLIM=dlim,LIM=lim

;; => Change YTITLE and coordinates in DLIM
yttle          = 'B ['+STRUPCASE(mode[0])+', '+ytcoordout[0]+', nT]'
str_element,dlim,'YTITLE',yttle[0],/ADD_REPLACE
str_element,dlim,'DATA_ATT.COORD_SYS','nif',/ADD_REPLACE
;; => Rotate B-fields
B_nif          = REFORM(rotnif ## fgm_B)
;; => Send NIF B-fields to TPLOT [but without the unnecessary *_IND* tags]
store_data,fgm_nout[jj],DATA={X:fgm_t,Y:B_nif},DLIM=dlim,LIM=lim


;; Define new labels
niflabs        = ['n','y = (b!D2!N x b!D1!N'+')','z = (n x y)']
options,fgm_nout,'LABELS',niflabs,/DEF
note           = '[data in NIF and NIF basis]'
options,fgm_nout,'DATA_ATT.NOTE',note[0],/DEF
;;----------------------------------------------------------------------------------------
;; => Rotate and transform other vectors into NIF
;;----------------------------------------------------------------------------------------
;;  Shock Parameters
vshn_up        =   26.23459d0
ushn_up        = -335.99324d0
gnorm          = [0.95576882d0,-0.18012919d0,-0.14100009d0]  ;; GSE
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-307.345d0,65.0927d0,30.3775d0]
vswi_dn        = [-54.9544d0,43.4793d0,-18.3793d0]
magf_up        = [1.54738d0,-0.185112d0,-2.65947d0]
magf_dn        = [-1.69473d0,-14.2039d0,1.26029d0]

;; => X'-vector
xvnor          = gnorm/NORM(REFORM(gnorm))
;; => Y'-vector
yvect          = my_crossp_2(magf_dn,magf_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))
;; => Z'-vector
zvect          = my_crossp_2(xvnor,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))
;; => Rotation Matrix from NIF to GSE
rotgse         = TRANSPOSE([[xvnor],[yvnor],[zvnor]])
;; => Define rotation from GSE to NIF
rotnif         = LA_INVERT(rotgse)
;;------------------------------------
;; => Get Vsw
;;------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_in       = 'gse'
coord_out      = 'nif_S1986a'
in_name        = pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV_2'
out_name       = pref[0]+coord_out[0]+'_Velocity_peib_no_GIs_UV_2'
get_data,in_name[0],DATA=temp,DLIM=dlim,LIM=lim
Vsw_t          = temp.X
Vsw_gse        = temp.Y
;; Calculate V_u [upstream shock rest frame inflow velocity]
vsh_nn         = REPLICATE(vshn_up[0],N_ELEMENTS(Vsw_t))
V_ux           = Vsw_gse[*,0] - vsh_nn*xvnor[0]
V_uy           = Vsw_gse[*,1] - vsh_nn*xvnor[1]
V_uz           = Vsw_gse[*,2] - vsh_nn*xvnor[2]
V_u            = [[V_ux],[V_uy],[V_uz]]
;; Calculate V_NIF transformation velocity
;;    V_NIF = n x (V_u x n)
;;          = n x [(Vsw - Vsh n) x n]
;;          = n x (Vsw x n) - Vsh [n x (n x n)]
;;          = n x (Vsw x n)
V_NIF_tr       = my_crossp_2(xvnor,my_crossp_2(Vsw_gse,xvnor,/NOM),/NOM)
;; Transform Vsw into NIF
;;  Calculate Vsw in NIF in the GSE basis
V_NIF          = V_u - V_NIF_tr
yttle          = 'V!Dbulk!N [th'+sc[0]+', km/s, NIF(S1986a)]'
nifgselabs     = ['x','y','z']
str_element,dlim,'YTITLE',yttle[0],/ADD_REPLACE
str_element,dlim,'LABELS',nifgselabs,/ADD_REPLACE
;; Send Vsw in NIF to TPLOT
store_data,out_name[0],DATA={X:Vsw_t,Y:V_NIF},DLIM=dlim,LIM=lim
note           = '[data in NIF but still in GSE basis]'
options,out_name[0],'DATA_ATT.NOTE',note[0],/DEF
;;  Note:
;;        If we apply the rotation from the GSE basis to the NIF basis, one finds
;;      that the only velocity components are along the X-NIF coordinate.
;;
test = reform(rotnif ## V_NIF)
PRINT, ';;', minmax(test[*,0])
;;      -356.21411       38.382372
PRINT, ';;', minmax(test[*,1])
;;  -2.3980817e-14   4.2632564e-14
PRINT, ';;', minmax(test[*,2])
;;  -3.0198066e-14   1.9539925e-14

;;---------------------------------------------
;;---------------------------------------------
;; => Convert EFI data into NIF
;;---------------------------------------------
;;---------------------------------------------
n_pint         = 2L
tsuffix        = '_INT'+STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
;;  Calculate E_NIF in the GSE basis
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
mid_nm         = 'efw_cal_corrected_DownSampled_'
coord_in       = 'gse'
coord_out      = 'nif_S1986a'
in_names       = tnames(pref[0]+mid_nm[0]+coord_in[0]+tsuffix)
out_names      = pref[0]+mid_nm[0]+coord_out[0]+tsuffix
;;  Calculate E_conv in the GSE basis
in_name        = pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV_2'
get_data,in_name[0],DATA=temp,DLIM=dlim,LIM=lim
Vsw_t          = temp.X
Vsw_gse        = temp.Y
get_data,fgm_nin[2],DATA=temp,DLIM=dlim,LIM=lim
fgm_t          = temp.X
fgm_B          = temp.Y
;; => Define convection velocity difference between SC Frame and NIF 
delta_V        = Vsw_gse - V_NIF  ;; or = (Vsh . n) + V_NIF_tr
;; => Interpolate Bo to ion timestamps
tempx          = interp(fgm_B[*,0],fgm_t,Vsw_t,/NO_EXTRAP)
tempy          = interp(fgm_B[*,1],fgm_t,Vsw_t,/NO_EXTRAP)
tempz          = interp(fgm_B[*,2],fgm_t,Vsw_t,/NO_EXTRAP)
magf_it        = [[tempx],[tempy],[tempz]]
;; => Define E_conv (GSE basis)
e_fac          = 1d3*1d-9*1d3  ;;  km/s -> m/s, nT -> T, V/m -> mV/m
E_conv         = -1d0*my_crossp_2(delta_V,magf_it,/NOM)*e_fac[0]
;;  Transform E into NIF in the GSE basis
note           = '[data in NIF but still in GSE basis]'
yttle          = 'E [NIF (GSE basis), mV/m]'
FOR i=0L, n_pint - 1L DO BEGIN                                                 $
  get_data,in_names[i],DATA=temp,DLIM=dlim,LIM=lim                           & $
  tempx          = interp(E_conv[*,0],Vsw_t,temp.X,/NO_EXTRAP)               & $
  tempy          = interp(E_conv[*,1],Vsw_t,temp.X,/NO_EXTRAP)               & $
  tempz          = interp(E_conv[*,2],Vsw_t,temp.X,/NO_EXTRAP)               & $
  econ0          = [[tempx],[tempy],[tempz]]                                 & $
  e_nif_gse      = temp.Y - econ0                                            & $
  struct         = {X:temp.X,Y:e_nif_gse}                                    & $
  store_data,out_names[i],DATA=struct,DLIM=dlim,LIM=lim                      & $
  options,out_names[i],'DATA_ATT.NOTE',note[0],/DEF                          & $
  options,out_names[i],'YTITLE',yttle[0],/DEF

;;---------------------------------------------
;;---------------------------------------------
;; => Calculate S in NIF [GSE basis]
;;---------------------------------------------
;;---------------------------------------------
sfac           = 1d-3*1d-9*1d6/muo[0]       ;; mV->V, nT->T, W->µW, divide by µ_o
nfft           = 128L
nshft          = 32L
flow           = 1d1

n_pint         = 2L
int_snum       = STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
tsuffix        = '_INT'+int_snum
yttl_pout      = '|S| [FFT Power, 10^(-6) W/m^2, Int. '+int_snum+']'
yttl_vout      = 'S [NIF (GSE basis), 10^(-6) W/m^2]'
;;  Calculate E_NIF in the GSE basis
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
mid_nme        = 'efw_cal_corrected_DownSampled_'
mid_nmb        = 'scw_cal_HighPass_'
coord_in       = 'gse'
coord_out      = 'nif_S1986a'
efi_names      = tnames(pref[0]+mid_nme[0]+coord_out[0]+tsuffix)
scm_names      = tnames(pref[0]+mid_nmb[0]+coord_in[0]+tsuffix)
get_data,scm_names[0],DATA=tempb
get_data,efi_names[0],DATA=tempe
srate_scw      = DOUBLE(ROUND(sample_rate(tempb.X,GAP_THRESH=2d0,/AVE)))
srate_efw      = DOUBLE(ROUND(sample_rate(tempe.X,GAP_THRESH=2d0,/AVE)))
PRINT,';;  ', srate_scw[0], srate_efw[0]
;;         8192.0000       8192.0000
srate_wstr     = STRTRIM(STRING(srate_scw[0],FORMAT='(f15.0)'),2L)
;; remove '.'
srate_wstr     = STRMID(srate_wstr[0],0L,STRLEN(srate_wstr[0]) - 1L)
ysub_spow      = '[th'+sc[0]+' '+srate_wstr[0]+'sps, 128 Fbins, 32 pt-shift]'
ysub_svec      = '[th'+sc[0]+' '+srate_wstr[0]+'sps, Int. '+int_snum+']'
note           = '[data in NIF but still in GSE basis]'
;; Define DATA_ATT structures
data_att_nif_v = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[0],UNITS:'microW/m^2',NOTE:note[0]}
;; Define output TPLOT names
mid_nmsV       = 'efw-scw-cal_ExB_'
mid_nmsP       = 'efw-scw-cal_ExB-Power_'
out_SnameV     = pref[0]+mid_nmsV[0]+coord_out[0]+tsuffix
out_SnameP     = pref[0]+mid_nmsP[0]+coord_out[0]+tsuffix

FOR i=0L, n_pint - 1L DO BEGIN                                                            $
  get_data,scm_names[i],DATA=tempb,DLIM=dlimb,LIM=limb                                  & $
  get_data,efi_names[i],DATA=tempe,DLIM=dlime,LIM=lime                                  & $
  ExB  = my_crossp_2(tempe.Y,tempb.Y,/NOM)*sfac[0]                                      & $
  temp = calc_poynting_flux_freq(tempe,tempb,FLOW=flow[0],NFFT=nfft[0],NSHFT=nshft[0])  & $
  stru = {X:tempb.X,Y:ExB}                                                              & $
  store_data,out_SnameV[i],DATA=stru,DLIM=dlime,LIM=lime                                & $
  store_data,out_SnameP[i],DATA=temp,DLIM=dlime,LIM=lime                                & $
  options,[out_SnameV[i],out_SnameP[i]],'CDF',/DEF                                      & $
  options,[out_SnameV[i],out_SnameP[i]],'DATA_ATT',data_att_nif_v,/DEF                  & $
  options,out_SnameV[i],'YTITLE',yttl_vout[0],/DEF                                      & $
  options,out_SnameP[i],'YTITLE',yttl_pout[i],/DEF                                      & $
  options,out_SnameV[i],'YSUBTITLE',ysub_svec[i],/DEF                                   & $
  options,out_SnameP[i],'YSUBTITLE',ysub_spow[0],/DEF                                   & $
  options,out_SnameP[i],'LABELS',/DEF                                                   & $
  options,out_SnameP[i],'COLORS',/DEF

options,out_SnameP[*],'YLOG',1,/DEF

;;----------------------------------------------------------------------------------------
;; => Define spatial scale along shock normal [km]
;;----------------------------------------------------------------------------------------
wpi_fac        = SQRT(1d6*qq[0]^2/(mp[0]*epo[0]))
wci_fac        = qq[0]*1d-9/mp[0]
ckm            = c[0]*1d-3

vshn_up        =   26.23459d0        ;;  shock normal speed [SC frame, km/s]
ushn_up        = -335.99324d0
gnorm          = [0.95576882d0,-0.18012919d0,-0.14100009d0]  ;; GSE
;;  Avg. upstream/downstream Ni, Vsw, and Bo
dens_up        =    9.66698d0
dens_dn        =   40.56430d0
vswi_up        = [-307.345d0,65.0927d0,30.3775d0]
vswi_dn        = [-54.9544d0,43.4793d0,-18.3793d0]
magf_up        = [1.54738d0,-0.185112d0,-2.65947d0]
magf_dn        = [-1.69473d0,-14.2039d0,1.26029d0]

vmag_up        = SQRT(TOTAL(vswi_up^2,/NAN))
vmag_dn        = SQRT(TOTAL(vswi_dn^2,/NAN))
bmag_up        = SQRT(TOTAL(magf_up^2,/NAN))
bmag_dn        = SQRT(TOTAL(magf_dn^2,/NAN))
;;  Define upstream ion inertial length [km]
wpi_up         = wpi_fac[0]*SQRT(dens_up[0])
wpi_dn         = wpi_fac[0]*SQRT(dens_dn[0])
Lii_up         = ckm[0]/wpi_up[0]
PRINT,';;  ', wpi_up[0], wpi_dn[0], Lii_up[0]
;;         4093.3846       8385.1171       73.238283

;;  Define convected ion gyroradii [km]
wci_up         = wci_fac[0]*bmag_up[0]
wci_dn         = wci_fac[0]*bmag_dn[0]
rho_convi      = ABS(ushn_up[0])/wci_dn[0]
PRINT,';;  ', wci_up[0], wci_dn[0], rho_convi[0]
;;        0.29526173       1.3755259       244.26530


pref           = 'th'+sc[0]+'_'
pos_gse        = 'th'+sc[0]+'_state_pos_gse'
names          = [pref[0]+'_Rad',pos_gse[0]+['_x','_y','_z']]
get_data,names[0],DATA=temp
times          = temp.X
i_low          = LINDGEN(N_ELEMENTS(times) - 1L)
i_high         = i_low + 1L
;;  Define scales for tick marks
;;  => Define center of ramp [now well defined here, but close...]
t_center       = time_double(tdate[0]+'/15:53:09.921')
dt_cent        = times - t_center[0]        ;;  time from center of ramp
delta_xncen    = vshn_up[0]*dt_cent         ;;  displacement along shock normal [km]
delta_xncenr   = delta_xncen/rho_convi[0]   ;;  displacement along shock normal [r_conv,i]
delta_xncenL   = delta_xncen/Lii_up[0]      ;;  displacement along shock normal [c/wpi_up]

dtxncn_tpn     = pref[0]+'dx_n_dt_tramp'
dtxnrci_tpn    = pref[0]+'dxn_rci_dt_tramp'
dtxnLii_tpn    = pref[0]+'dxn_Lii_dt_tramp'
store_data,dtxncn_tpn[0],DATA={X:times,Y:delta_xncen}
store_data,dtxnrci_tpn[0],DATA={X:times,Y:delta_xncenr}
store_data,dtxnLii_tpn[0],DATA={X:times,Y:delta_xncenL}
options,[dtxncn_tpn[0],dtxnrci_tpn[0],dtxnLii_tpn[0]],'YTITLE'
options,dtxncn_tpn[0],'YTITLE','L!Dxn!N [km]',/DEF
options,dtxnrci_tpn[0],'YTITLE','L!Dxn!N [r!Dconv,i!N'+']',/DEF
options,dtxnLii_tpn[0],'YTITLE','L!Dxn!N [c/w!Dpi,up!N'+']',/DEF
options,[dtxncn_tpn[0],dtxnrci_tpn[0],dtxnLii_tpn[0]],'YSUBTITLE'
options,[dtxncn_tpn[0],dtxnrci_tpn[0],dtxnLii_tpn[0]],'YSUBTITLE',/DEF
;options,dtxncn_tpn[0],'YSUBTITLE','[= V!Dshn!N (dx . n)]',/DEF

;;  Define new tick marks
names2         = [REVERSE(pos_gse[0]+['_x','_y','_z']),dtxncn_tpn[0],dtxnrci_tpn[0],dtxnLii_tpn[0]]
tplot_options,VAR_LABEL=names2

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01

;;----------------------------------------------------------------------------------------
;;  Define scales for current calculations
;;----------------------------------------------------------------------------------------
j_fac          = 1d-9*1d6/muo[0]

mode           = 'fgh'
jj             = 2L
get_data,fgm_nout[jj],DATA=temp,DLIM=dlim,LIM=lim
fgh_t          = temp.X
fgh_B          = temp.Y
fgh_Bmag       = SQRT(TOTAL(fgh_B^2,2L,/NAN))  ;; |B|
;;  Define sample rate
max_gap        = 1d0
srate_fgh      = DOUBLE(sample_rate(fgh_t,GAP_THRESH=max_gap[0],/AVE))
sr_fgh_str     = STRTRIM(STRING(srate_fgh[0],FORMAT='(f15.0)'),2L)
sr_fgh_str     = STRMID(sr_fgh_str[0],0L,STRLEN(sr_fgh_str[0]) - 1L)  ;; remove '.'
;;  Define adjacent indices
n_fgh          = N_ELEMENTS(fgh_t)
i_low          = LINDGEN(n_fgh - 1L)
i_high         = i_low + 1L
;;  Define time different between adjacent timestamps, ∆t_{i} = (t_{k} - t_{j})
delta_t        = (fgh_t[i_high] - fgh_t[i_low])
bad            = WHERE(delta_t GT max_gap[0],bd)
IF (bd GT 0) THEN delta_t[bad] = d
;;  Define new timestamps, T_{i} = (t_{k} + t_{j})/2
t_new          = (fgh_t[i_high] + fgh_t[i_low])/2d0
IF (bd GT 0) THEN t_new[bad] = d
;;  Define spatial scale, ∆x_{i} = Vshn ∆t_{i}
delta_xn       = vshn_up[0]*delta_t*1d3  ;; [m]
;;  Define [∆B(T_{i})]_{m} = [B(t_{k}) - B(t_{j})]_{m}
delta_Bx       = (fgh_B[i_high,0] - fgh_B[i_low,0])
delta_By       = (fgh_B[i_high,1] - fgh_B[i_low,1])
delta_Bz       = (fgh_B[i_high,2] - fgh_B[i_low,2])
;;  Define |∆B| [nT]
mag_delta_B    = SQRT(delta_Bx^2 + delta_By^2 + delta_Bz^2)
;;  Define ∆|B| [nT]
delta_Bmag     = (fgh_Bmag[i_high] - fgh_Bmag[i_low])
IF (bd GT 0) THEN delta_Bx[bad] = d
IF (bd GT 0) THEN delta_By[bad] = d
IF (bd GT 0) THEN delta_Bz[bad] = d
IF (bd GT 0) THEN mag_delta_B[bad] = d
IF (bd GT 0) THEN delta_Bmag[bad] = d
;;  j = (∆ x B)/µ  [NIF]
;;  =>  j_ny = -(∂Bz/∂x)/µ ~ (∆Bz/∆x)/µ
j_ny           = -1d0*j_fac[0]*delta_Bz/delta_xn                  ;;  [µA m^(-2)]
;;  =>  j_nz =  (∂By/∂x)/µ ~ (∆By/∆x)/µ
j_nz           =      j_fac[0]*delta_By/delta_xn                  ;;  [µA m^(-2)]
;;  |j|  = |(∆ x B)/µ| ~ |∆B|/(|∆x| µ)
j_mag          =      j_fac[0]*mag_delta_B/delta_xn               ;;  [µA m^(-2)]
;;  ∆|j| = (∆ x |B|)/µ ~ ∆|B|/(|∆x| µ)   [ = pseudo-current]
dj_Bmag        =      j_fac[0]*ABS(delta_Bmag)/delta_xn           ;;  [µA m^(-2)]
;;  j-vector, |j|, and ∆|j|
j_nx           = REPLICATE(d,n_fgh - 1L)
j_vec          = [[j_nx],[j_ny],[j_nz]]
jmag_dj        = [[j_mag],[dj_Bmag]]
;; => Send [NIF] currents to TPLOT
cur_nmvec      = pref[0]+'jvec_fgh_nif_S1986a'
cur_nmmag      = pref[0]+'jmags_fgh_nif_S1986a'
store_data,cur_nmmag[0],DATA={X:t_new,Y:jmag_dj}
store_data,cur_nmvec[0],DATA={X:t_new,Y:j_vec}
;; => Define YTITLEs
yttl_vec       = 'J [NIF, x10!U-6!N A m!U-2!N'+']'
yttl_mag       = '|J| [ x10!U-6!N A m!U-2!N'+']'
mode           = 'fgh'
ysubttle       = '[th'+sc[0]+', L2 '+mode[0]+': '+sr_fgh_str[0]+' sps]'
options,cur_nmmag[0],'YTITLE',yttl_mag[0],/DEF
options,cur_nmvec[0],'YTITLE',yttl_vec[0],/DEF
options,[cur_nmmag[0],cur_nmvec[0]],'YSUBTITLE',ysubttle[0],/DEF
;; Define vector labels
niflabs        = ['n','y = (b!D2!N x b!D1!N'+')','z = (n x y)']
options,cur_nmvec[0],'LABELS',niflabs,/DEF
options,cur_nmvec[0],'COLORS',[250,150,50],/DEF
;; Define |j| and ∆|j| labels
Delta_str      = STRUPCASE(get_greek_letter('delta'))
muo_str        = get_greek_letter('mu')+'!Do!N'
denom_str      = '('+Delta_str[0]+'x '+muo_str[0]+')'
maglabs        = ['|j| = |'+Delta_str[0]+'B|/'+denom_str[0],$
                  Delta_str[0]+'|j| = '+Delta_str[0]+'|B|/'+denom_str[0]]
options,cur_nmmag[0],'LABELS',maglabs,/DEF
options,cur_nmmag[0],'COLORS',[250,50],/DEF
options,cur_nmmag[0],'YLOG',1,/DEF
options,cur_nmmag[0],'YMINOR',9,/DEF


nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
options,nnw,'LABFLAG',2,/DEF
;;---------------------------------------
;; => Smooth currents and send to TPLOT
;;---------------------------------------
cur_nmmag2     = pref[0]+'jmags_fgh_nif_S1986a_squared'

get_data,cur_nmvec[0],DATA=tempvec,DLIM=dlimvec,LIM=limvec
get_data,cur_nmmag[0],DATA=tempmag,DLIM=dlimmag,LIM=limmag

nsm            = 10L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
suffx          = '_sm'+nsms[0]+'pts'
mode           = 'fgh'
ysubttle       = '[th'+sc[0]+', L2 '+mode[0]+': '+sr_fgh_str[0]+' sps]'
ysubttle       = ysubttle[0]+'!C'+'[Smoothed: '+nsms[0]+' pts]'
;;  j-vector
temp_smvx      = SMOOTH(tempvec.Y[*,0],nsm[0],/NAN,/EDGE_TRUNCATE)
temp_smvy      = SMOOTH(tempvec.Y[*,1],nsm[0],/NAN,/EDGE_TRUNCATE)
temp_smvz      = SMOOTH(tempvec.Y[*,2],nsm[0],/NAN,/EDGE_TRUNCATE)
j_vec_sm       = [[temp_smvx],[temp_smvy],[temp_smvz]]
jmag_dj_sm2    = TOTAL((j_vec_sm*1d-6)^2,2L,/NAN)  ;; squared value
;; |j| and ∆|j|
temp_smmx      = SMOOTH(tempmag.Y[*,0],nsm[0],/NAN,/EDGE_TRUNCATE)
temp_smmy      = SMOOTH(tempmag.Y[*,1],nsm[0],/NAN,/EDGE_TRUNCATE)
jmag_dj_sm     = [[temp_smmx],[temp_smmy]]

;; Send to TPLOT
store_data,cur_nmmag[0]+suffx[0],DATA={X:tempmag.X,Y:jmag_dj_sm},DLIM=dlimmag,LIM=limmag
store_data,cur_nmvec[0]+suffx[0],DATA={X:tempmag.X,Y:j_vec_sm},DLIM=dlimvec,LIM=limvec
store_data,cur_nmmag2[0]+suffx[0],DATA={X:tempmag.X,Y:jmag_dj_sm2*1d6},DLIM=dlimmag,LIM=limmag
;; Change subtitle
options,[cur_nmmag[0],cur_nmvec[0],cur_nmmag2[0]]+suffx[0],'YSUBTITLE',ysubttle[0],/DEF
yttl_mag       = '|J|!U2!N [ x10!U-6!N A!U2!N m!U-4!N'+']'
options,cur_nmmag2[0]+suffx[0],'YTITLE',yttl_mag[0],/DEF
options,cur_nmmag2[0]+suffx[0],'LABELS','|j|!U2!N',/DEF
options,cur_nmmag2[0]+suffx[0],'COLORS',50,/DEF


sc             = probe[0]
pref           = 'th'+sc[0]+'_'
fgm_pren       = pref[0]+'fgh_'
coord_out      = 'nif_S1986a'
fgh_tnm        = fgm_pren+['mag',coord_out[0]]
coord_in       = 'gse'
sfw_gse_out    = tnames(pref[0]+'efw-scw-cal_ExB-Power_'+coord_out[0]+'_INT*')
cur_nm_sm      = tnames([cur_nmmag[0],cur_nmvec[0],cur_nmmag2[0]]+suffx[0])
all_tpnm       = [fgh_tnm,sfw_gse_out,cur_nm_sm]
tplot,all_tpnm


sc             = probe[0]
pref           = 'th'+sc[0]+'_'
fgm_pren       = pref[0]+'fgh_'
coord_out      = 'nif_S1986a'
fgh_tnm        = fgm_pren+['mag',coord_out[0]]
coord_in       = 'gse'
sfw_gse_out    = tnames(pref[0]+'efw-scw-cal_ExB-Power_'+coord_in[0]+'_INT*')
cur_nm_sm      = tnames([cur_nmmag[0],cur_nmvec[0],cur_nmmag2[0]]+suffx[0])
all_tpnm       = [fgh_tnm,sfw_gse_out,cur_nm_sm]
tplot,all_tpnm


scu            = 'THA'
tags           = 'T'+STRTRIM(STRING(LINDGEN(5),FORMAT='(I2.2)'),2)
bmstr          = CREATE_STRUCT(tags,'fgh','B','','mag','')
bfstr          = CREATE_STRUCT(tags,'fgh','B','','nif','')
sfstr0         = CREATE_STRUCT(tags,'ExB','S','','pow','cal-Int0')
sfstr1         = CREATE_STRUCT(tags,'ExB','S','','pow','cal-Int1')
jmstr          = CREATE_STRUCT(tags,'fgh','J','','mag','')
jvstr          = CREATE_STRUCT(tags,'fgh','J','','nif','')
j2str          = CREATE_STRUCT(tags,'fgh','J2','','mag','')
;;---------------------------------------
;;   
;; save plot
;;   
;;---------------------------------------
cur_nm_sm      = tnames([cur_nmmag[0],cur_nmvec[0]]+suffx[0])
all_tpnm       = [fgh_tnm,sfw_gse_out,cur_nm_sm]
tplot,all_tpnm
fstr  = [bmstr,bfstr,sfstr0,sfstr1,jmstr,jvstr]
ps_quick_file,SPACECRAFT=scu[0],FIELDS=fstr,_EXTRA={LAND:0,PORT:1}


cur_nm_sm      = tnames([cur_nmmag2[0],cur_nmvec[0]]+suffx[0])
all_tpnm       = [fgh_tnm,sfw_gse_out,cur_nm_sm]
tplot,all_tpnm
fstr  = [bmstr,bfstr,sfstr0,sfstr1,j2str,jvstr]
ps_quick_file,SPACECRAFT=scu[0],FIELDS=fstr,_EXTRA={LAND:0,PORT:1}

cur_nm_sm      = tnames([cur_nmmag2[0],cur_nmvec[0]]+suffx[0])
all_tpnm       = [fgh_tnm[0],sfw_gse_out,cur_nm_sm]
tplot,all_tpnm
fstr  = [bmstr,sfstr0,sfstr1,j2str,jvstr]
ps_quick_file,SPACECRAFT=scu[0],FIELDS=fstr,_EXTRA={LAND:0,PORT:1}
;;----------------------------------------------------------------------------------------
;;  Calculate quasi-linear anomalous resistivities
;;
;;  REFERENCES:  
;;               1)  Spitzer, L. and R. Harm (1953), "Transport Phenomena in a
;;                      Completely Ionized Gas," Phys. Rev., Vol. 89, pp. 977.
;;               2)  Labelle, J.W. and R.A. Treumann (1988), "Plasma Waves at the
;;                      Dayside Magnetopause," Space Sci. Rev., Vol. 47, pp. 175.
;;               3)  Coroniti, F.V. (1985), "Space Plasma Turbulent Dissipation:
;;                      Reality or Myth?," Space Sci. Rev., Vol. 42, pp. 399.
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_out      = 'nif_S1986a'
frbsuf         = ['b','r','f']
frbytt         = ['Burst','Reduced','Full']
ei_mid         = ['e','i']
emid           = 'pee'+frbsuf
imid           = 'pei'+frbsuf
iden__mid      = 'N_'
itemp_mid      = 'T_avg_'
mom_suffx      = '_no_GIs_UV'
eden__suffx    = '_density'
etemp_suffx    = '_avgtemp'
;; => define interval suffix for TPLOT names
n_pint         = 2L
int_snum       = STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
tsuffix        = '_INT'+int_snum

;;  Electron TPLOT moment names
dens_ebn       = pref[0]+emid[0]+eden__suffx[0]
temp_ebn       = pref[0]+emid[0]+etemp_suffx[0]
;;  Corrected Ion TPLOT moment names
dens_ibn       = pref[0]+iden__mid[0]+imid[0]+mom_suffx[0]
temp_ibn       = pref[0]+itemp_mid[0]+imid[0]+mom_suffx[0]
;;  E-Field [AC-Coupled] TPLOT names
mid_nme        = 'efw_cal_corrected_DownSampled_'
coord_out      = 'nif_S1986a'
efi_names      = tnames(pref[0]+mid_nme[0]+coord_out[0]+tsuffix)
;;  B-Field [quasi-static] TPLOT names
bmag_nm        = tnames(pref[0]+'fgh_mag')

get_data,efi_names[0],DATA=tempe,DLIM=dlime,LIM=lime
data_att_e0    = dlime.DATA_ATT

;; => Define some defaults
r_struct       = 0  ;; define dummy value which will be overwritten by routine
res_labs       = ['IAW[LT1988]','LHDI[C1985]','LHDI[LT1988]','ECDI[LT1988]']
res_cols       = [250,200,100,30]
yttl           = 'Anomalous Resistivities [Ohm m]'
note           = '[data in NIF but still in GSE basis]'
;; => Define default plot limits structure
data_att_res   = data_att_e0
str_element,data_att_res,'COORD_SYS','scalar',/ADD_REPLACE
str_element,data_att_res,'UNITS','Ohm m',/ADD_REPLACE
str_element,data_att_res,'NOTE',note[0],/ADD_REPLACE
dlim0          = dlime
str_element,dlim0,'CDF',/DELETE
str_element,dlim0,'DATA_ATT',data_att_res,/ADD_REPLACE
str_element,dlim0,'COLORS',res_cols,/ADD_REPLACE
str_element,dlim0,'LABELS',res_labs,/ADD_REPLACE
str_element,dlim0,'YTITLE',yttl,/ADD_REPLACE
str_element,dlim0,'YLOG',1,/ADD_REPLACE
;; => Define output TPLOT plot limits structures
res_dlim       = dlim0
res_lim        = lime
;; => Define output TPLOT name
name0          = 'Anom_Resistivities'
mid_nme2       = 'efw_cal-cor_DS_'
eta_name       = pref[0]+mid_nme2[0]+name0[0]+tsuffix
FOR j=0L, n_pint - 1L DO BEGIN                                                           $
  dE_nm    = efi_names[j]                                                              & $
  bo_nm    = bmag_nm[0]                                                                & $
  resistivity_calc_wrapper,dens_ibn[0],temp_ebn[0],DE_NAME=dE_nm[0],BO_NAME=bo_nm[0],    $
                           TI_NAME=temp_ibn[0],R_STRUCT=r_struct                       & $
  IF (SIZE(r_struct,/TYPE) NE 8L) THEN CONTINUE                                        & $
  times        = r_struct.ABSCISSA                                                     & $
  SH1953_res   = r_struct.ELECTRONION_RESISTIVITY_SH1953                               & $
  iaw_LT1988   = r_struct.IAW_RESISTIVITY_LT1988                                       & $
  lhdi_C1985   = r_struct.LHDI_RESISTIVITY_C1985                                       & $
  lhdi_L1988   = r_struct.LHDI_RESISTIVITY_LT1988                                      & $
  ecdi_L1988   = r_struct.ECDI_RESISTIVITY_LT1988                                      & $
  all_resits   = [[iaw_LT1988],[lhdi_C1985],[lhdi_L1988],[ecdi_L1988]]                 & $
  store_data,eta_name[j],DATA={X:times,Y:all_resits},DLIM=res_dlim,LIM=res_lim         & $
  str_element,SH1953_str,'T'+int_snum[j],{X:times,Y:SH1953_res},/ADD_REPLACE           & $
  r_struct     = 0



;;----------------------------------------------------------------------------------------
;;  Correlate |S(w,k)| with |j|^2
;;----------------------------------------------------------------------------------------
;;  Steps:  
;;          1)  get both intervals for |S(w,k)| and *eta* and combine them
;;          2)  get |j|^2 and downsample |S(w,k)| and *eta* to |j|^2 timestamps
;;          3)  multiply *eta* by |j|^2
;;          4)  compare |S(w,k)| with *eta* |j|^2
;;----------------------------------------------------------------------------------------
nsm            = 10L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
suffx          = '_sm'+nsms[0]+'pts'

sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_in       = 'gse'
coord_out      = 'nif_S1986a'
;; => Define interval suffix for TPLOT names
n_pint         = 2L
int_snum       = STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
tsuffix        = '_INT'+int_snum
;;  E-Field [AC-Coupled] TPLOT names
mid_nme        = 'efw_cal_corrected_DownSampled_'
efi_names      = tnames(pref[0]+mid_nme[0]+coord_out[0]+tsuffix)
;;  B-Field [AC-Coupled] TPLOT names
mid_nmb        = 'scw_cal_HighPass_'
scm_names      = tnames(pref[0]+mid_nmb[0]+coord_in[0]+tsuffix)
;;  |S(w,k)| TPLOT names
mid_nmsP       = 'efw-scw-cal_ExB-Power_'
out_SnameP     = tnames(pref[0]+mid_nmsP[0]+coord_out[0]+tsuffix)
;;  *eta* TPLOT name
name0          = 'Anom_Resistivities'
mid_nme2       = 'efw_cal-cor_DS_'
eta_name       = tnames(pref[0]+mid_nme2[0]+name0[0]+tsuffix)
;;  |j|^2 TPLOT name
cur_nmmag2     = tnames(pref[0]+'jmags_fgh_nif_S1986a_squared'+suffx[0])
;;---------------------------------------
;; => Get TPLOT data
;;---------------------------------------
;;  E [NIF (GSE basis)]
get_data,efi_names[0],DATA=temp_ef0,DLIM=dlim_ef0,LIM=lim_ef0
get_data,efi_names[1],DATA=temp_ef1,DLIM=dlim_ef1,LIM=lim_ef1
;;  B [NIF (GSE basis) = GSE]
get_data,scm_names[0],DATA=temp_bf0,DLIM=dlim_bf0,LIM=lim_bf0
get_data,scm_names[1],DATA=temp_bf1,DLIM=dlim_bf1,LIM=lim_bf1
;;  |S(w,k)|
get_data,out_SnameP[0],DATA=temp_SP0,DLIM=dlim_SP0,LIM=lim_SP0
get_data,out_SnameP[1],DATA=temp_SP1,DLIM=dlim_SP1,LIM=lim_SP1
;;  *eta*
get_data,eta_name[0],DATA=temp_eta0,DLIM=dlim_eta0,LIM=lim_eta0
get_data,eta_name[1],DATA=temp_eta1,DLIM=dlim_eta1,LIM=lim_eta1
;;  |j|^2
get_data,cur_nmmag2[0],DATA=temp_j20,DLIM=dlim_j20,LIM=lim_j20
;;---------------------------------------
;; => Define time range
;;---------------------------------------
t_minj         =  MIN(temp_j20.X,/NAN)
t_maxj         =  MAX(temp_j20.X,/NAN)
t_min          =  MIN([temp_SP0.X,temp_eta0.X],/NAN) > t_minj[0]
t_max          = (MAX([temp_SP1.X,temp_eta1.X],/NAN) < t_maxj[0]) > t_min[0]
PRINT,';;  ', t_min[0] MOD 864d2, t_max[0] MOD 864d2, t_max[0] - t_min[0]
;;         57182.692       57195.567       12.874878

;; => Keep only data between these time ranges
jmag__t        = temp_j20.X
jmag_sq        = temp_j20.Y*1d-6  ;; A^(+2) m^(-2)
good           = WHERE(jmag__t GE t_min[0] AND jmag__t LE t_max[0],gd)
PRINT,';;  ', gd
;;          1648

IF (gd GT 0) THEN jmag_sq_t   = jmag__t[good] ELSE jmag_sq_t   = d
IF (gd GT 0) THEN jmag_sq_val = jmag_sq[good] ELSE jmag_sq_val = d
;;---------------------------------------
;; => Combine intervals
;;---------------------------------------
;;  E-Fields
efi__t__int0   = temp_ef0.X
efi_val_int0   = temp_ef0.Y*1d-3 ;; V/m
efi__t__int1   = temp_ef1.X
efi_val_int1   = temp_ef1.Y*1d-3 ;; V/m
efi_vals       = [efi_val_int0,efi_val_int1]
efi_t          = [efi__t__int0,efi__t__int1]
;;  B-Fields
scm__t__int0   = temp_bf0.X
scm_val_int0   = temp_bf0.Y*1d-9 ;; T
scm__t__int1   = temp_bf1.X
scm_val_int1   = temp_bf1.Y*1d-9 ;; T
scm_vals       = [scm_val_int0,scm_val_int1]
scm_t          = [scm__t__int0,scm__t__int1]
;;  *eta*
eta__t__int0   = temp_eta0.X
eta_val_int0   = temp_eta0.Y      ;; Ω m
eta__t__int1   = temp_eta1.X
eta_val_int1   = temp_eta1.Y      ;; Ω m
eta_vals       = [eta_val_int0,eta_val_int1]
eta_t          = [eta__t__int0,eta__t__int1]
;;  |S(w,k)|
SPF__t__int0   = temp_SP0.X
SPF_val_int0   = temp_SP0.Y       ;; µW m^(-2)
SPF__t__int1   = temp_SP1.X
SPF_val_int1   = temp_SP1.Y       ;; µW m^(-2)
SPF_vals       = [SPF_val_int0,SPF_val_int1]
SPF_t          = [SPF__t__int0,SPF__t__int1]

nsm            = 10L
sm_SPF_vals    = SMOOTH(SPF_vals,nsm[0],/NAN,/EDGE_TRUNCATE)
;;-----------------------------------------------------------
;; => Construct the Maxwell stress Tensor, T_ij [J m^(-3)]
;;      [N,3,3]-element array
;;-----------------------------------------------------------
neb            = N_ELEMENTS(efi_t)
csq            = c[0]^2       ;; (m/s)^2

;; => Define dot-products
e_dot_e        = my_dot_prod(efi_vals,efi_vals,/NOM)  ;; [N]-element array
b_dot_b        = my_dot_prod(scm_vals,scm_vals,/NOM)
;; expand to [N,3,3]-element array
e_dot_e_3x3    = DBLARR(neb,3L,3L)
b_dot_b_3x3    = DBLARR(neb,3L,3L)
FOR j=0L, 2L DO BEGIN                $
  e_dot_e_3x3[*,j,j] = e_dot_e[*]  & $
  b_dot_b_3x3[*,j,j] = b_dot_b[*]
;; Define outer products
ef_outer       = DBLARR(neb,3L,3L)
bf_outer       = DBLARR(neb,3L,3L)
FOR i=0L, 2L DO BEGIN                                $
  FOR j=0L, 2L DO BEGIN                              $
    ef_outer[*,i,j] = efi_vals[*,i]*efi_vals[*,j]  & $
    bf_outer[*,i,j] = scm_vals[*,i]*scm_vals[*,j]

;; Define:  DF_ij = F_i*F_j - (F.F)/2 * ∂_ij
;;            where F = E or B
ef_tensor      = DBLARR(neb,3L,3L)
bf_tensor      = DBLARR(neb,3L,3L)
ef_tensor      = ef_outer - e_dot_e_3x3/2d0
bf_tensor      = bf_outer - b_dot_b_3x3/2d0
;; => Define Maxwell stress Tensor:
;;            T_ij = ∑_o [DE_ij + c^2 DB_ij]
Ms_tensor      = DBLARR(neb,3L,3L)                      ;; [J m^(-3)]
Ms_tensor      = epo[0]*(ef_tensor + csq[0]*bf_tensor)
;; => Define Maxwell stress Tensor component along shock normal:
;;            ∑_{j} (T_ij . n_j)
Ms_ten_n       = DBLARR(neb,3L)                              ;; [J m^(-3)]
gnorm          = [0.95576882d0,-0.18012919d0,-0.14100009d0]  ;; GSE
xvnor          = gnorm/NORM(REFORM(gnorm))
nn_xvnor       = REPLICATE(1d0,neb) # xvnor
FOR j=0L, 2L DO Ms_ten_n[*,j] = TOTAL(REFORM(Ms_tensor[*,j,*])*nn_xvnor,2,/NAN)

;;-------------------------------------------------------
;; => Interpolate |S(w,k)| and *eta* to |j|^2 timestamps
;;-------------------------------------------------------
SPF_vals_jt    = interp(SPF_vals,SPF_t,jmag_sq_t,/NO_EXTRAP)
sm_SPF_vals_jt = interp(sm_SPF_vals,SPF_t,jmag_sq_t,/NO_EXTRAP)

eta__iawL88_jt = interp(eta_vals[*,0],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_lhdiC85_jt = interp(eta_vals[*,1],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_lhdiL88_jt = interp(eta_vals[*,2],eta_t,jmag_sq_t,/NO_EXTRAP)
eta_ecdiL88_jt = interp(eta_vals[*,3],eta_t,jmag_sq_t,/NO_EXTRAP)
;;---------------------------------------
;; => Compare |S(w,k)| with *eta* |j|^2
;;---------------------------------------
eta_j2__iawL88 = (eta__iawL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_lhdiC85 = (eta_lhdiC85_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_lhdiL88 = (eta_lhdiL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
eta_j2_ecdiL88 = (eta_ecdiL88_jt*jmag_sq_val)*1d6  ;; µW m^(-3)
all_eta_j2     = [[eta_j2__iawL88],[eta_j2_lhdiC85],[eta_j2_lhdiL88],[eta_j2_ecdiL88]]
;;  Calculate |S(w,k)|/(*eta* |j|^2)  [km]
ratio__iawL88  = SPF_vals/eta_j2__iawL88*1d-3
ratio_lhdiC85  = SPF_vals/eta_j2_lhdiC85*1d-3
ratio_lhdiL88  = SPF_vals/eta_j2_lhdiL88*1d-3
ratio_ecdiL88  = SPF_vals/eta_j2_ecdiL88*1d-3
all_ratio      = [[ratio__iawL88],[ratio_lhdiC85],[ratio_lhdiL88],[ratio_ecdiL88]]

;;---------------------------------------
;; => Send to TPLOT
;;---------------------------------------
Delta_str      = STRUPCASE(get_greek_letter('delta'))
mu__str        = get_greek_letter('mu')
muo_str        = mu__str[0]+'!Do!N'
eta_str        = get_greek_letter('eta')
omega_str      = get_greek_letter('omega')
nsm            = 10L
nsms           = STRING(FORMAT='(I3.3)',nsm[0])
suffx          = '_sm'+nsms[0]+'pts'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'

;;  Combined intervals for |S(w,k)|
mid_nmsP       = 'efw-scw-cal_ExB-Power_'
out_SnameP01   = pref[0]+mid_nmsP[0]+coord_out[0]+'_INT-All'
dlim_SP01      = dlim_SP0
lim_SP01       = lim_SP0
yttl__out      = '|S| [FFT Power, 10^(-6) W/m^2, All Int.]'
str_element,dlim_SP01,'YTITLE',yttl__out,/ADD_REPLACE
spf_labs       = ['|S|','|S| [10 pt smoothed]']
str_element,dlim_SP01,'LABELS',spf_labs,/ADD_REPLACE
str_element,dlim_SP01,'COLORS',[ 50,250],/ADD_REPLACE
stru           = {X:SPF_t,Y:[[SPF_vals],[sm_SPF_vals]]}
store_data,out_SnameP01[0],DATA=stru,DLIM=dlim_SP01,LIM=lim_SP01

;;  *eta* |j|^2
diss_nme       = pref[0]+'eta-j-squared'+suffx[0]
ratio_nme      = pref[0]+'ratio_ExB-Power_to_eta-j-squared'+suffx[0]
dlim_etaj2     = dlim_j20
lim_etaj2      = lim_j20
yttl__out      = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
res_labs       = ['IAW[LT1988]','LHDI[C1985]','LHDI[LT1988]','ECDI[LT1988]']
res_cols       = [250,200,100,30]
str_element,dlim_etaj2,'COLORS',res_cols,/ADD_REPLACE
str_element,dlim_etaj2,'LABELS',res_labs,/ADD_REPLACE
str_element,dlim_etaj2,'YTITLE',yttl__out,/ADD_REPLACE
str_element,dlim_etaj2,'YLOG',1,/ADD_REPLACE
stru           = {X:jmag_sq_t,Y:all_eta_j2}
store_data,diss_nme[0],DATA=stru,DLIM=dlim_etaj2,LIM=lim_etaj2

;;  |S(w,k)|/(*eta* |j|^2)
note           = '[Ratio of (Integrated FFT Poynting Flux)/(Ohmic Dissipation Rate) -> scale length]'
yttl__out      = '|S('+omega_str[0]+',k)|/('+eta_str[0]+'|j|!U2!N'+')  [km]'
dlim_ratio     = dlim_SP0
lim_ratio      = lim_SP0
str_element,dlim_ratio,'COLORS',res_cols,/ADD_REPLACE
str_element,dlim_ratio,'LABELS',res_labs,/ADD_REPLACE
str_element,dlim_ratio,'YTITLE',yttl__out,/ADD_REPLACE
str_element,dlim_ratio,'YLOG',1,/ADD_REPLACE
str_element,dlim_ratio,'DATA_ATT.UNITS','km',/ADD_REPLACE
str_element,dlim_ratio,'DATA_ATT.NOTE',note[0],/ADD_REPLACE
stru           = {X:jmag_sq_t,Y:all_ratio}
store_data,ratio_nme[0],DATA=stru,DLIM=dlim_ratio,LIM=lim_ratio


;;---------------------------------------
;; => Print values to ASCII file
;;---------------------------------------
fname          = 'Integrated-FFT-Poynting-Flux-Sm-NotSm_Dissipation-Rate_'+tdate[0]+'.txt'
mform          = '(a30,2E15.5,4E15.5)'

scets          = time_string(jmag_sq_t,PREC=3)
nvals          = N_ELEMENTS(scets)

;;  Open file
OPENW,gunit,fname[0],/GET_LUN
FOR i=0L, nvals - 1L DO BEGIN    $
  PRINTF,gunit,FORMAT=mform,scets[i],SPF_vals_jt[i],sm_SPF_vals_jt[i],REFORM(all_eta_j2[i,*])
;;  Open file
FREE_LUN,gunit












WSET,1
PLOT,SPF_vals_jt,jmag_sq_val,/YLOG,/XLOG,/NODATA
  OPLOT,SPF_vals_jt,jmag_sq_val,PSYM=2,COLOR=50
  OPLOT,sm_SPF_vals_jt,jmag_sq_val,PSYM=7,COLOR=250


yttle = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
xttle = '|S| [FFT Power, '+mu__str[0]+'W/m!U-2!N'+']'
pttle = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate[0]
pstr  = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1}
WSET,1
PLOT,SPF_vals_jt,all_eta_j2[*,0],_EXTRA=pstr
  OPLOT,SPF_vals_jt,all_eta_j2[*,0],PSYM=2,COLOR=50
  OPLOT,sm_SPF_vals_jt,all_eta_j2[*,0],PSYM=7,COLOR=250



pttle = 'Dissipation Rate vs. Integrated FFT Poynting Flux '+tdate[0]
popen,'Dissipation-Rate_vs_Integrated-FFT-Poynting-Flux_'+tdate[0],/LAND
  mu__strps      = get_greek_letter('mu')
  eta_strps      = get_greek_letter('eta')
  yttleps        = eta_strps[0]+'|j|!U2!N [Dissipation, '+mu__strps[0]+'W m!U-3!N'+']'
  xttleps        = '|S| [FFT Power, '+mu__strps[0]+'W/m!U-2!N'+']'
  pstrps         = {TITLE:pttle,XTITLE:xttleps,YTITLE:yttleps,YLOG:1,XLOG:1,NODATA:1}
  PLOT,SPF_vals_jt,all_eta_j2[*,0],_EXTRA=pstrps
    OPLOT,SPF_vals_jt,all_eta_j2[*,0],PSYM=2,COLOR=50
pclose


xttle = eta_str[0]+'|j|!U2!N [Dissipation, '+mu__str[0]+'W m!U-3!N'+']'
yttle = '|S| [FFT Power, '+mu__str[0]+'W/m!U-2!N'+']'
pttle = 'Integrated FFT Poynting Flux vs. Dissipation Rate '+tdate[0]
pstr  = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:1,XLOG:1,NODATA:1}
WSET,1
PLOT,all_eta_j2[*,0],SPF_vals_jt,_EXTRA=pstr
  OPLOT,all_eta_j2[*,0],SPF_vals_jt,PSYM=2,COLOR=50
  OPLOT,all_eta_j2[*,0],sm_SPF_vals_jt,PSYM=7,COLOR=250























































;;----------------------------------------------------------------------------------------
;; => Rotate and transform other vectors into NIF
;;----------------------------------------------------------------------------------------






























wi,1
tra_zm = time_double(tdate[0]+'/15:5'+['2:38.300','3:40.900'])
good_tn0 = where(t_new ge tra_zm[0] and t_new le tra_zm[1],gdtn0)

wset,1
plot,t_n0[good_tn0],dj_Bmag[good_tn0],/nodata,/xstyle,/ystyle,/ylog
  oplot,t_n0[good_tn0],dj_Bmag[good_tn0],color=50
  oplot,t_n0[good_tn0],smooth(dj_Bmag[good_tn0],10,/edge_trun,/nan),color=150

wset,1
plot,t_n0[good_tn0],j_mag[good_tn0],/nodata,/xstyle,/ystyle,/ylog
  oplot,t_n0[good_tn0],j_mag[good_tn0],color=50
  oplot,t_n0[good_tn0],smooth(j_mag[good_tn0],10,/edge_trun,/nan),color=150

;;----------------------------------------------------------------------------------------
;; => Fix NIF rotations
;;     => 1st set of time ranges [shock RH solutions]
;;----------------------------------------------------------------------------------------
evxbfac        = -1d0*1d3*1d-9*1d3  ;;  km/s -> m/s, nT -> T, V/m -> mV/m

vshn_up        =   26.23459d0
ushn_up        = -335.99324d0
gnorm          = [0.95576882d0,-0.18012919d0,-0.14100009d0]
;vshn_up        =   -0.34323890d0
;ushn_up        = -309.10030d0
;gnorm          = [0.97873770d0,-0.11229654d0,-0.059902080d0]
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn)

;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-307.345d0,65.0927d0,30.3775d0]
vswi_dn        = [-54.9544d0,43.4793d0,-18.3793d0]
magf_up        = [1.54738d0,-0.185112d0,-2.65947d0]
magf_dn        = [-1.69473d0,-14.2039d0,1.26029d0]
;vswi_up        = [-306.830d0,65.3250d0,30.0793d0]
;vswi_dn        = [-66.1083d0,50.1763d0,-6.33199d0]
;magf_up        = [2.03877d0,-0.451179d0,-3.02909d0]
;magf_dn        = [-0.601265d0,-15.0333d0,-4.21656d0]
;; Calculate V_NIF
;;    V_NIF = n x (V_u x n)
;;          = n x [(Vsw - Vsh n) x n]
;;          = n x (Vsw x n) - Vsh [n x (n x n)]
;;          = n x (Vsw x n)
pref           = 'th'+sc[0]+'_'
coord_in       = ['gse','fac','nif']
vsw_name       = tnames(pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV_2')
fglgse         = tnames(pref[0]+'fgl_'+coord_in[0])
get_data,vsw_name[0],DATA=vsw_str,DLIM=dlim__v,LIM=lim__v
get_data,fglgse[0],DATA=fgl_str,DLIM=dlim_Bo,LIM=lim_Bo
;; interpolate Bo to ion timestamps
nvsw           = N_ELEMENTS(vsw_str.X)
tempx          = interp(fgl_str.Y[*,0],fgl_str.X,vsw_str.X,/NO_EXTRAP)
tempy          = interp(fgl_str.Y[*,1],fgl_str.X,vsw_str.X,/NO_EXTRAP)
tempz          = interp(fgl_str.Y[*,2],fgl_str.X,vsw_str.X,/NO_EXTRAP)
magf_it        = [[tempx],[tempy],[tempz]]

;;  V_u     = Vsw - (Vsh n)
;;          = upstream bulk velocity in shock rest frame
u_norm         = gnorm/NORM(REFORM(gnorm))  ;; normalized
tempx          = vsw_str.Y[*,0] - vshn_up[0]*u_norm[0]
tempy          = vsw_str.Y[*,1] - vshn_up[0]*u_norm[1]
tempz          = vsw_str.Y[*,2] - vshn_up[0]*u_norm[2]
V_u            = [[tempx],[tempy],[tempz]]
;;    V_NIF = n x (V_u x n)
;;          = transformation velocity into the NIF
nxVuxn         = my_crossp_2(u_norm,my_crossp_2(V_u,u_norm,/NOM),/NOM)
;;    U_NIF = V_u - V_NIF
;;          = bulk velocity in the NIF
U_NIF          = V_u - nxVuxn
;;    E_NIF = -(U_NIF x B_u)
;;          = convection electric field in the NIF
E_NIF          = evxbfac[0]*my_crossp_2(U_NIF,magf_up,/NOM)


nxVxn          = my_crossp_2(u_norm,my_crossp_2(vsw_str.Y,u_norm,/NOM),/NOM)
vsh_nhat       = REPLICATE(1d0,nvsw) # (vshn_up[0]*u_norm)
;; convection velocity [km/s]
;;  V_conv = Vsh n + V_NIF
V_conv         = vsh_nhat + nxVxn
;; convection E-field [mV/m]
E_conv         = evxbfac[0]*my_crossp_2(V_conv,magf_it,/NOM)

;; construct rotation matrix
;;    V_NIF = n x (V_u x n)
v_nif08        = my_crossp_2(u_norm,my_crossp_2(vswi_up,u_norm,/NOM),/NOM)
;;    V'    = (Vsh n) + V_NIF
v_tran08       = vshn_up[0]*u_norm + v_nif08
;;    E_NIF = E_sc + (V' x Bo)
e_tran08       = evxbfac[0]*my_crossp_2(v_tran08,magf_u,/NOM)
u_e_tr08       = e_tran08/NORM(REFORM(e_tran08))  ;; normalized
;;    E_sc  = -(Vsw x Bo)
e_conv_sw      = -1d0*my_crossp_2(vsw_up,magf_u,/NOM)
e_cnmagsw      = NORM(REFORM(e_conv_sw))
u_e_conv_sw    = e_conv_sw/e_cnmagsw  ;; normalized


;; => Y'-vector
yvect          = my_crossp_2(magf_dn,magf_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))
;; => Z'-vector
zvect          = my_crossp_2(u_norm,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))
;; => Rotation Matrix from NIF to GSE
rotgse         = TRANSPOSE([[u_norm],[u_e_conv_sw],[u_bmax]])
;; => Define rotation from GSE to NIF
rotnif         = LA_INVERT(rotgse)
PRINT,rotnif




;;----------------------------------------------------------------------------------------
;; => Calculate S = (E x B)/µ_o [Time Domain]
;;----------------------------------------------------------------------------------------
sfac           = 1d-3*1d-9*1d6/muo[0]       ;; mV->V, nT->T, W->µW, divide by µ_o
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_in       = ['gse','fac','nif']
;; Calc. sample rates [sps]
get_data,(tnames(pref[0]+'scp_cal_dsl'))[0],DATA=tempb
get_data,(tnames(pref[0]+'efp_cal_dsl'))[0],DATA=tempe
srate_scp      = DOUBLE(ROUND(sample_rate(tempb.X,GAP_THRESH=2d0,/AVE)))
srate_efp      = DOUBLE(ROUND(sample_rate(tempe.X,GAP_THRESH=2d0,/AVE)))
PRINT,';;  ', srate_scp[0], srate_efp[0]
;;         128.00000       128.00000

get_data,(tnames(pref[0]+'scw_cal_dsl'))[0],DATA=tempb
get_data,(tnames(pref[0]+'efw_cal_dsl_corrected_DownSampled'))[0],DATA=tempe
srate_scw      = DOUBLE(ROUND(sample_rate(tempb.X,GAP_THRESH=2d0,/AVE)))
srate_efw      = DOUBLE(ROUND(sample_rate(tempe.X,GAP_THRESH=2d0,/AVE)))
PRINT,';;  ', srate_scw[0], srate_efw[0]
;;         8192.0000       8192.0000

srate_pstr     = STRTRIM(STRING(srate_scp[0],FORMAT='(f15.0)'),2L)
srate_wstr     = STRTRIM(STRING(srate_scw[0],FORMAT='(f15.0)'),2L)
;; remove '.'
srate_pstr     = STRMID(srate_pstr[0],0L,STRLEN(srate_pstr[0]) - 1L)
srate_wstr     = STRMID(srate_wstr[0],0L,STRLEN(srate_wstr[0]) - 1L)

;;------------------------------------
;;  Particle Burst
;;------------------------------------
scp_pref       = pref[0]+'scp_cal_'
efp_pref       = pref[0]+'efp_cal_'
scp_suff       = coord_in+'_INT*'
efp_suff       = coord_in+'_INT*'
scp_gse_names  = tnames(scp_pref[0]+scp_suff[0])
efp_gse_names  = tnames(efp_pref[0]+efp_suff[0])
scp_fac_names  = tnames(scp_pref[0]+scp_suff[1])
efp_fac_names  = tnames(efp_pref[0]+efp_suff[1])
scp_nif_names  = tnames(scp_pref[0]+scp_suff[2])
efp_nif_names  = tnames(efp_pref[0]+efp_suff[2])
scp_name_str   = {T0:scp_gse_names,T1:scp_fac_names,T2:scp_nif_names}
efp_name_str   = {T0:efp_gse_names,T1:efp_fac_names,T2:efp_nif_names}
n_pint         = N_ELEMENTS(scp_gse_names)  ;; # of SCP time intervals
;;  Define output names
tsuffix        = '_INT'+STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
sfp_gse_out    = pref[0]+'efp-scp-cal_ExB_'+coord_in[0]+tsuffix
sfp_fac_out    = pref[0]+'efp-scp-cal_ExB_'+coord_in[1]+tsuffix
sfp_nif_out    = pref[0]+'efp-scp-cal_ExB_'+coord_in[2]+tsuffix
sfp_name_str   = {T0:sfp_gse_out,T1:sfp_fac_out,T2:sfp_nif_out}
;;  Define output structures
data_att_gse   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[0],UNITS:'microW/m^2'}
data_att_fac   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[1],UNITS:'microW/m^2'}
data_att_nif   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[2],UNITS:'microW/m^2'}
data_att_s     = {T0:data_att_gse,T1:data_att_fac,T2:data_att_nif}
;;  Calculate S [µW m^(-2)]
FOR i=0L, 2L DO BEGIN                                                 $
  scp_names = scp_name_str.(i)                                      & $
  efp_names = efp_name_str.(i)                                      & $
  data_atts = data_att_s.(i)                                        & $
  sfp_nmout = sfp_name_str.(i)                                      & $
  yttl_out  = 'S ['+STRUPCASE(coord_in[i])+', 10^(-6) W/m^2]'       & $
  FOR j=0L, n_pint - 1L DO BEGIN                                      $
    get_data,scp_names[j],DATA=t_scp,DLIM=dlimb,LIM=limb            & $
    get_data,efp_names[j],DATA=t_efp,DLIM=dlime,LIM=lime            & $
    tempx        = interp(t_efp.Y[*,0],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempy        = interp(t_efp.Y[*,1],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempz        = interp(t_efp.Y[*,2],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempef       = [[tempx],[tempy],[tempz]]                        & $
    sfp_dat      = my_crossp_2(tempef,t_scp.Y,/NOM)*sfac[0]         & $
    t_sfp        = {X:t_scp.X,Y:sfp_dat}                            & $
    dlims        = dlimb                                            & $
    str_element,dlims,'DATA_ATT',data_atts,/ADD_REPLACE             & $
    str_element,dlims,'YTITLE',yttl_out[0],/ADD_REPLACE             & $
    str_element,dlims,'CDF',/DELETE                                 & $
    store_data,sfp_nmout[j],DATA=t_sfp,DLIM=dlims,LIM=limb

;;------------------------------------
;; Wave Burst
;;------------------------------------
scw_pref       = pref[0]+'scw_cal_HighPass_'
efw_pref       = pref[0]+'efw_cal_corrected_DownSampled_'
scw_suff       = coord_in+'_INT*'
efw_suff       = coord_in+'_INT*'
scw_gse_names  = tnames(scw_pref[0]+scw_suff[0])
efw_gse_names  = tnames(efw_pref[0]+efw_suff[0])
scw_fac_names  = tnames(scw_pref[0]+scw_suff[1])
efw_fac_names  = tnames(efw_pref[0]+efw_suff[1])
scw_nif_names  = tnames(scw_pref[0]+scw_suff[2])
efw_nif_names  = tnames(efw_pref[0]+efw_suff[2])
scw_name_str   = {T0:scw_gse_names,T1:scw_fac_names,T2:scw_nif_names}
efw_name_str   = {T0:efw_gse_names,T1:efw_fac_names,T2:efw_nif_names}
n_wint         = N_ELEMENTS(scw_gse_names)  ;; # of SCW time intervals
;;  Define output names
tsuffix        = '_INT'+STRING(LINDGEN(n_wint),FORMAT='(I3.3)')
sfw_gse_out    = pref[0]+'efw-scw-cal_ExB_'+coord_in[0]+tsuffix
sfw_fac_out    = pref[0]+'efw-scw-cal_ExB_'+coord_in[1]+tsuffix
sfw_nif_out    = pref[0]+'efw-scw-cal_ExB_'+coord_in[2]+tsuffix
sfw_name_str   = {T0:sfw_gse_out,T1:sfw_fac_out,T2:sfw_nif_out}
;;  Define output structures
data_att_gse   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[0],UNITS:'microW/m^2'}
data_att_fac   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[1],UNITS:'microW/m^2'}
data_att_nif   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[2],UNITS:'microW/m^2'}
data_att_s     = {T0:data_att_gse,T1:data_att_fac,T2:data_att_nif}
;;  Calculate S [µW m^(-2)]
FOR i=0L, 2L DO BEGIN                                                 $
  scw_names = scw_name_str.(i)                                      & $
  efw_names = efw_name_str.(i)                                      & $
  data_atts = data_att_s.(i)                                        & $
  sfw_nmout = sfw_name_str.(i)                                      & $
  yttl_out  = 'S ['+STRUPCASE(coord_in[i])+', 10^(-6) W/m^2]'       & $
  FOR j=0L, n_wint - 1L DO BEGIN                                      $
    get_data,scw_names[j],DATA=t_scw,DLIM=dlimb,LIM=limb            & $
    get_data,efw_names[j],DATA=t_efw,DLIM=dlime,LIM=lime            & $
    tempx        = interp(t_efw.Y[*,0],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempy        = interp(t_efw.Y[*,1],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempz        = interp(t_efw.Y[*,2],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempef       = [[tempx],[tempy],[tempz]]                        & $
    sfw_dat      = my_crossp_2(tempef,t_scw.Y,/NOM)*sfac[0]         & $
    t_sfw        = {X:t_scw.X,Y:sfw_dat}                            & $
    dlims        = dlimb                                            & $
    str_element,dlims,'DATA_ATT',data_atts,/ADD_REPLACE             & $
    str_element,dlims,'YTITLE',yttl_out[0],/ADD_REPLACE             & $
    str_element,dlims,'CDF',/DELETE                                 & $
    store_data,sfw_nmout[j],DATA=t_sfw,DLIM=dlims,LIM=limb
;;----------------------------------------------------------------------------------------
;; => Calculate S = (E x B)/µ_o [Frequency Domain]
;;----------------------------------------------------------------------------------------
sfac           = 1d-3*1d-9*1d6/muo[0]       ;; mV->V, nT->T, W->µW, divide by µ_o
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
coord_in       = ['gse','fac','nif']

;;------------------------------------
;;  Particle Burst
;;------------------------------------
nfft           = 32L
nshft          = 8L
flow           = 0d0
yttl_out       = '|S| [Freq. Power, 10^(-6) W/m^2]'
ysub           = '[th'+sc[0]+' '+srate_pstr[0]+'sps, 32 Fbins, 8 pt-shift]'

scp_pref       = pref[0]+'scp_cal_'
efp_pref       = pref[0]+'efp_cal_'
scp_suff       = coord_in+'_INT*'
efp_suff       = coord_in+'_INT*'
scp_gse_names  = tnames(scp_pref[0]+scp_suff[0])
efp_gse_names  = tnames(efp_pref[0]+efp_suff[0])
scp_fac_names  = tnames(scp_pref[0]+scp_suff[1])
efp_fac_names  = tnames(efp_pref[0]+efp_suff[1])
scp_nif_names  = tnames(scp_pref[0]+scp_suff[2])
efp_nif_names  = tnames(efp_pref[0]+efp_suff[2])
scp_name_str   = {T0:scp_gse_names,T1:scp_fac_names,T2:scp_nif_names}
efp_name_str   = {T0:efp_gse_names,T1:efp_fac_names,T2:efp_nif_names}
n_pint         = N_ELEMENTS(scp_gse_names)  ;; # of SCP time intervals
;;  Define output names
tsuffix        = '_INT'+STRING(LINDGEN(n_pint),FORMAT='(I3.3)')
sfp_gse_out    = pref[0]+'efp-scp-cal_ExB-Power_'+coord_in[0]+tsuffix
sfp_fac_out    = pref[0]+'efp-scp-cal_ExB-Power_'+coord_in[1]+tsuffix
sfp_nif_out    = pref[0]+'efp-scp-cal_ExB-Power_'+coord_in[2]+tsuffix
sfp_name_str   = {T0:sfp_gse_out,T1:sfp_fac_out,T2:sfp_nif_out}
;;  Define output structures
data_att_gse   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[0],UNITS:'microW/m^2'}
data_att_fac   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[1],UNITS:'microW/m^2'}
data_att_nif   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[2],UNITS:'microW/m^2'}
data_att_s     = {T0:data_att_gse,T1:data_att_fac,T2:data_att_nif}
;;  Calculate S [µW m^(-2)]
FOR i=0L, 2L DO BEGIN                                                 $
  scp_names = scp_name_str.(i)                                      & $
  efp_names = efp_name_str.(i)                                      & $
  data_atts = data_att_s.(i)                                        & $
  sfp_nmout = sfp_name_str.(i)                                      & $
  FOR j=0L, n_pint - 1L DO BEGIN                                      $
    get_data,scp_names[j],DATA=t_scp,DLIM=dlimb,LIM=limb            & $
    get_data,efp_names[j],DATA=t_efp,DLIM=dlime,LIM=lime            & $
    tempx        = interp(t_efp.Y[*,0],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempy        = interp(t_efp.Y[*,1],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempz        = interp(t_efp.Y[*,2],t_efp.X,t_scp.X,/NO_EXTRAP)  & $
    tempef       = [[tempx],[tempy],[tempz]]                        & $
    efp2         = {X:t_scp.X,Y:tempef}                             & $
    temp         = calc_poynting_flux_freq(efp2,t_scp,FLOW=flow[0],NFFT=nfft[0],NSHFT=nshft[0])  & $
    dlims        = dlimb                                            & $
    str_element,dlims,'DATA_ATT',data_atts,/ADD_REPLACE             & $
    str_element,dlims,'YTITLE',yttl_out[0],/ADD_REPLACE             & $
    str_element,dlims,'YSUBTITLE',ysub[0],/ADD_REPLACE              & $
    str_element,dlims,'CDF',/DELETE                                 & $
    str_element,dlims,'COLORS',/DELETE                              & $
    str_element,dlims,'LABELS',/DELETE                              & $
    store_data,sfp_nmout[j],DATA=temp,DLIM=dlims,LIM=limb

;; clean up options
FOR i=0L, 2L DO BEGIN                                                 $
  sfp_nmout = sfp_name_str.(i)                                      & $
  FOR j=0L, n_pint - 1L DO BEGIN                                      $
    options,sfp_nmout[j],'COLOR_TABLE',/DEF                         & $
    options,sfp_nmout[j],'COLOR_TABLE'                              & $
    options,sfp_nmout[j],'COLORS',/DEF                              & $
    options,sfp_nmout[j],'COLORS'                                   & $
    options,sfp_nmout[j],'YLOG',1,/DEF                              & $
    options,sfp_nmout[j],'LABELS',/DEF                              & $
    options,sfp_nmout[j],'LABELS'

;;------------------------------------
;; Wave Burst
;;------------------------------------
nfft           = 128L
nshft          = 32L
flow           = 1d1
yttl_out       = '|S| [Freq. Power, 10^(-6) W/m^2]'
ysub           = '[th'+sc[0]+' '+srate_wstr[0]+'sps, 128 Fbins, 32 pt-shift]'

scw_pref       = pref[0]+'scw_cal_HighPass_'
efw_pref       = pref[0]+'efw_cal_corrected_DownSampled_'
scw_suff       = coord_in+'_INT*'
efw_suff       = coord_in+'_INT*'
scw_gse_names  = tnames(scw_pref[0]+scw_suff[0])
efw_gse_names  = tnames(efw_pref[0]+efw_suff[0])
scw_fac_names  = tnames(scw_pref[0]+scw_suff[1])
efw_fac_names  = tnames(efw_pref[0]+efw_suff[1])
scw_nif_names  = tnames(scw_pref[0]+scw_suff[2])
efw_nif_names  = tnames(efw_pref[0]+efw_suff[2])
scw_name_str   = {T0:scw_gse_names,T1:scw_fac_names,T2:scw_nif_names}
efw_name_str   = {T0:efw_gse_names,T1:efw_fac_names,T2:efw_nif_names}
n_wint         = N_ELEMENTS(scw_gse_names)  ;; # of SCW time intervals
;;  Define output names
tsuffix        = '_INT'+STRING(LINDGEN(n_wint),FORMAT='(I3.3)')
sfw_gse_out    = pref[0]+'efw-scw-cal_ExB-Power_'+coord_in[0]+tsuffix
sfw_fac_out    = pref[0]+'efw-scw-cal_ExB-Power_'+coord_in[1]+tsuffix
sfw_nif_out    = pref[0]+'efw-scw-cal_ExB-Power_'+coord_in[2]+tsuffix
sfw_name_str   = {T0:sfw_gse_out,T1:sfw_fac_out,T2:sfw_nif_out}
;;  Define output structures
data_att_gse   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[0],UNITS:'microW/m^2'}
data_att_fac   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[1],UNITS:'microW/m^2'}
data_att_nif   = {DATA_TYPE:'calibrated',COORD_SYS:coord_in[2],UNITS:'microW/m^2'}
data_att_s     = {T0:data_att_gse,T1:data_att_fac,T2:data_att_nif}
;;  Calculate S [µW m^(-2)]
FOR i=0L, 2L DO BEGIN                                                 $
  scw_names = scw_name_str.(i)                                      & $
  efw_names = efw_name_str.(i)                                      & $
  data_atts = data_att_s.(i)                                        & $
  sfw_nmout = sfw_name_str.(i)                                      & $
  FOR j=0L, n_wint - 1L DO BEGIN                                      $
    get_data,scw_names[j],DATA=t_scw,DLIM=dlimb,LIM=limb            & $
    get_data,efw_names[j],DATA=t_efw,DLIM=dlime,LIM=lime            & $
    tempx        = interp(t_efw.Y[*,0],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempy        = interp(t_efw.Y[*,1],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempz        = interp(t_efw.Y[*,2],t_efw.X,t_scw.X,/NO_EXTRAP)  & $
    tempef       = [[tempx],[tempy],[tempz]]                        & $
    efw2         = {X:t_scw.X,Y:tempef}                             & $
    temp         = calc_poynting_flux_freq(efw2,t_scw,FLOW=flow[0],NFFT=nfft[0],NSHFT=nshft[0])  & $
    dlims        = dlimb                                            & $
    str_element,dlims,'DATA_ATT',data_atts,/ADD_REPLACE             & $
    str_element,dlims,'YTITLE',yttl_out[0],/ADD_REPLACE             & $
    str_element,dlims,'YSUBTITLE',ysub[0],/ADD_REPLACE              & $
    str_element,dlims,'CDF',/DELETE                                 & $
    str_element,dlims,'COLORS',/DELETE                              & $
    str_element,dlims,'LABELS',/DELETE                              & $
    store_data,sfw_nmout[j],DATA=temp,DLIM=dlims,LIM=limb

;; clean up options
FOR i=0L, 2L DO BEGIN                                                 $
  sfw_nmout = sfw_name_str.(i)                                      & $
  FOR j=0L, n_wint - 1L DO BEGIN                                      $
    options,sfw_nmout[j],'COLOR_TABLE',/DEF                         & $
    options,sfw_nmout[j],'COLOR_TABLE'                              & $
    options,sfw_nmout[j],'COLORS',/DEF                              & $
    options,sfw_nmout[j],'COLORS'                                   & $
    options,sfw_nmout[j],'YLOG',1,/DEF                              & $
    options,sfw_nmout[j],'LABELS',/DEF                              & $
    options,sfw_nmout[j],'LABELS'











;; Save corrected fields
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]
tplot_save,FILENAME=fname[0]

;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
;; => Restore TPLOT session
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]+'.tplot'
file           = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0

!themis.VERBOSE = 0
tplot_options,'VERBOSE',2

pref           = 'th'+sc[0]+'_'
pos_gse        = 'th'+sc[0]+'_state_pos_gse'
names          = [pref[0]+'_Rad',pos_gse[0]+['_x','_y','_z']]
tplot_options,VAR_LABEL=names
options,tnames(),'LABFLAG',2,/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01

coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
magname   = pref[0]+'fgh_'+coord[0]
fgmnm     = pref[0]+'fgl_'+['mag',coord[0]]
tr_jj     = time_double(tdate[0]+'/'+['15:48:20','15:58:25'])

tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;; => Fix Fields
;;----------------------------------------------------------------------------------------
mode           = 'efp efw'
coord_in       = 'dsl'
coord_out      = 'gse'
typee          = 'calibrated'
fmin_b         = 10.
fcut_b         = 10.
despinb        = 0
nk             = 256L
flow           = 0.1
no_extra       = 1
no_spec        = 1
tran_fac       = 0
poynt_flux     = 0
loadefi        = 1
loadscm        = 1
tclip_fs       = 0
tra            = time_double(tr_00)

wrapper_thm_load_efiscm,PROBE=probe,TRANGE=tra,/GET_SUPPORT,POYNT_FLUX=poynt_flux,    $
                        TRAN_FAC=tran_fac,COORD_IN=coord_in[0],DATATYPE=mode[0],      $
                        LOAD_EFI=loadefi,TYPE_E=typee[0],SE_T_EFI_OUT=se_tefi,        $
                        LOAD_SCM=loadscm,TYPE_B=typee[0],SE_T_SCM_OUT=se_tscm,NK=nk,  $
                        /EDGE_TRUN,FMIN_B=fmin_b,FCUT_B=fcut_b,                       $
                        DESPIN_B=despin_b,FLOW=flow,NO_EXTRA=no_extra,                $
                        NO_SPEC=no_spec,DIRECT_CROSS=direct,TCLIP_FIELDS=tclip_fs,    $
                        COORD_OUT=coord_out[0]

;; => Remove data outside time range of interest
coord_in       = 'dsl'
scw_names      = tnames(pref[0]+'scw_cal_'+coord_in[0]+'*')
efw_names      = tnames(pref[0]+'efw_cal_'+coord_in[0]+'*')
scp_names      = tnames(pref[0]+'scp_cal_'+coord_in[0]+'*')
efp_names      = tnames(pref[0]+'efp_cal_'+coord_in[0]+'*')
all_fields     = [scp_names,scw_names,efp_names,efw_names]
kill_data_tr,NAMES=all_fields

;; => Remove "spikes" by hand
coord_in       = 'dsl'
scp_names      = tnames(pref[0]+'scp_cal_'+coord_in[0]+'*')
efp_names      = tnames(pref[0]+'efp_cal_'+coord_in[0]+'*')
all_fields     = [scp_names,efp_names]
names          = [fgmnm,all_fields]
tplot,names

kill_data_tr,NAMES=all_fields[1]

;; => Remove "spikes" by hand
coord_in       = 'dsl'
scw_names      = tnames(pref[0]+'scw_cal_'+coord_in[0]+'*')
efw_names      = tnames(pref[0]+'efw_cal_'+coord_in[0]+'*')
all_fields     = [scw_names,efw_names]
names          = [fgmnm,all_fields]
tplot,names

kill_data_tr,NAMES=all_fields[1]
;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI
;;----------------------------------------------------------------------------------------
magf_up        = [2.03877d0,-0.451179d0,-3.02909d0]
magf_dn        = [-0.601265d0,-15.0333d0,-4.21656d0]
vswi_up        = [-306.830d0,65.3250d0,30.0793d0]
vswi_dn        = [-66.1083d0,50.1763d0,-6.33199d0]
vshn_up        =   -0.34323890d0
ushn_up        = -309.10030d0
gnorm          = [0.97873770d0,-0.11229654d0,-0.059902080d0]
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn)

.compile temp_thm_cal_rot_ebfields
temp_thm_cal_rot_ebfields,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str

del_data,tnames('tha_*_cal_dsl_HighPass*')
del_data,tnames('tha_*_cal_*_INT*')
del_data,tnames('tha_*_cal_*_fac*')
del_data,tnames('tha_*_cal_*_corrected*')



















;; Save corrected fields
mdir           = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
prefu          = STRUPCASE(pref[0])
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_EFI-SCM-Corrected_'
fnm            = file_name_times(tr_00,PREC=0)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname          = fpref[0]+tsuffx[0]
tplot_save,FILENAME=fname[0]

























;;----------------------------------------------------------------------------------------
;; => Plot data
;;----------------------------------------------------------------------------------------
treb    = tr_jj

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
;; => Restore saved DFs
;;----------------------------------------------------------------------------------------
sc      = probe[0]
enames  = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames  = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'

mdir    = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_esa_save/'+tdate[0]+'/')
efiles  = FILE_SEARCH(mdir,enames[0])
ifiles  = FILE_SEARCH(mdir,inames[0])

RESTORE,ifiles[0]
;; => Redefine structures
dat_i     = peib_df_arr_a
;; Keep only structures between defined time range
trtt      = time_double(tr_00)
i_time0   = dat_i.TIME
i_time1   = dat_i.END_TIME
good_i    = WHERE(i_time0 GE trtt[0] AND i_time1 LE trtt[1],gdi)
dat_i     = peib_df_arr_a[good_i]
n_i       = N_ELEMENTS(dat_i)
PRINT,';', n_i
;         791


RESTORE,efiles[0]
;; => Redefine structures
dat_e     = peeb_df_arr_a
;; Keep only structures between defined time range
trtt      = time_double(tr_00)
e_time0   = dat_e.TIME
e_time1   = dat_e.END_TIME
good_e    = WHERE(e_time0 GE trtt[0] AND e_time1 LE trtt[1],gde)
dat_e     = peeb_df_arr_a[good_e]

n_e       = N_ELEMENTS(dat_e)
PRINT,';', n_e
;         790
;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
vname_n   = velname[0]+'_fixed_3'
magname   = pref[0]+'fgh_'+coord[0]
spperi    = pref[0]+'state_spinper'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
scname    = tnames(pref[0]+'pe*b_sc_pot')

modify_themis_esa_struc,dat_i
;; add SC potential to structures
add_scpot,dat_i,scname[1]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_igse  = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname,VEL_NAME=velname
;; make sure MAGF tag is defined
magn_1    = pref[0]+'fgs_'+coord[0]
magn_2    = pref[0]+'fgh_'+coord[0]
add_magf2,dat_igse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_igse,magn_2[0],/LEAVE_ALONE
;; make sure VSW tag is defined
add_vsw2,dat_igse,velname[0],/LEAVE_ALONE
add_vsw2,dat_igse,vname_n[0],/LEAVE_ALONE


modify_themis_esa_struc,dat_e
;; add SC potential to structures
add_scpot,dat_e,scname[0]
;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_egse  = dat_e
rotate_esa_thetaphi_to_gse,dat_egse,MAGF_NAME=magname,VEL_NAME=velname
;; make sure MAGF tag is defined
magn_1    = pref[0]+'fgs_'+coord[0]
magn_2    = pref[0]+'fgh_'+coord[0]
add_magf2,dat_egse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_egse,magn_2[0],/LEAVE_ALONE
;; make sure VSW tag is defined
add_vsw2,dat_egse,velname[0],/LEAVE_ALONE
add_vsw2,dat_egse,vname_n[0],/LEAVE_ALONE






;; Upstream/Downstream determination
tr_up     = tdate[0]+'/'+['15:54:25','15:57:30']
tr_dn     = tdate[0]+'/'+['15:49:30','15:51:55']

