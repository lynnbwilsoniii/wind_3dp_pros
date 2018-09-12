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
;; => Define time zooms around ramp
;;----------------------------------------------------------------------------------------
tz_facs        = [2.5d0,5d0,7.5d0,1d1,15d0,22.5d0,3d1,45d0,6d1,75d0,1d2]
tz_strs        = '_'+STRTRIM(STRING(2d0*tz_facs,FORMAT='(I3.3)'),2)+'-sec-window'
ntz            = N_ELEMENTS(tz_facs)
tzoom0         = DBLARR(ntz,2L)
tzoom1         = DBLARR(ntz,2L)
tzoom2         = DBLARR(ntz,2L)

tzoom0[*,0]    = t_ramp0[0] - tz_facs
tzoom0[*,1]    = t_ramp0[0] + tz_facs
tzoom1[*,0]    = t_ramp1[0] - tz_facs
tzoom1[*,1]    = t_ramp1[0] + tz_facs
tzoom2[*,0]    = t_ramp2[0] - tz_facs
tzoom2[*,1]    = t_ramp2[0] + tz_facs

fnm_s0         = file_name_times(tzoom0[*,0],PREC=4)
fnm_e0         = file_name_times(tzoom0[*,1],PREC=4)
fnm_s1         = file_name_times(tzoom1[*,0],PREC=4)
fnm_e1         = file_name_times(tzoom1[*,1],PREC=4)
fnm_s2         = file_name_times(tzoom2[*,0],PREC=4)
fnm_e2         = file_name_times(tzoom2[*,1],PREC=4)

ftimes0        = fnm_s0.F_TIME+'-'+STRMID(fnm_e0.F_TIME,11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
ftimes1        = fnm_s1.F_TIME+'-'+STRMID(fnm_e1.F_TIME,11L)
ftimes2        = fnm_s2.F_TIME+'-'+STRMID(fnm_e2.F_TIME,11L)

f_suffx0       = '_1st-BS-Crossing'
f_suffx1       = '_2nd-BS-Crossing'
f_suffx2       = '_3rd-BS-Crossing'
;;----------------------------------------------------------------------------------------
;; => Define different FGM TPLOT handles
;;----------------------------------------------------------------------------------------
mode_fgm       = ['fgs','fgl','fgh']
tpnm_fgm_bmag  = tnames(scpref[0]+mode_fgm+'_mag')

IF (date EQ '071309') THEN fgm_yra = [0d0,35d0]
IF (date EQ '072109') THEN fgm_yra = [0d0,35d0]
IF (date EQ '092609') THEN fgm_yra = [0d0,50d0]
test_fgm       = (N_ELEMENTS(fgm_yra) NE 0)
IF (test_fgm) THEN options,tpnm_fgm_bmag,'YRANGE'
IF (test_fgm) THEN options,tpnm_fgm_bmag,'YRANGE',fgm_yra,/DEF

tplot,tpnm_fgm_bmag,TRANGE=REFORM(tzoom0[6,*])
tplot,tpnm_fgm_bmag,TRANGE=REFORM(tzoom0[7,*])

f_pref         = prefu[0]+'fgs-fgl-fgh_mag_compare_'
fnames0        = f_pref[0]+ftimes0+tz_strs+f_suffx0[0]
fnames1        = f_pref[0]+ftimes1+tz_strs+f_suffx1[0]
fnames2        = f_pref[0]+ftimes2+tz_strs+f_suffx2[0]

IF (date EQ '072309') THEN fgm_yra  = [0d0,50d0]
IF (date EQ '102411') THEN fgm_yra  = [0d0,70d0]
IF (date EQ '072309' OR date EQ '102411') THEN test_fgm = (N_ELEMENTS(fgm_yra) NE 0)
IF (test_fgm AND (date EQ '072309' OR date EQ '102411')) THEN options,tpnm_fgm_bmag,'YRANGE'
IF (test_fgm AND (date EQ '072309' OR date EQ '102411')) THEN options,tpnm_fgm_bmag,'YRANGE',fgm_yra,/DEF
fname          = fnames0
tzoom          = tzoom0
tramp          = t_ramp0[0]
FOR i=0L, ntz - 1L DO BEGIN                            $
  j = (ntz - 1L) - i[0]                              & $
  IF (j GT 0) THEN k = j - 1L ELSE k = j             & $
  popen,fname[j],/LAND                               & $
    tplot,tpnm_fgm_bmag,TRANGE=REFORM(tzoom[j,*])    & $
    time_bar,REFORM(tzoom[k,*]),COLOR=250            & $
    time_bar,tramp[0],COLOR=150                      & $
  pclose

IF (date EQ '072309') THEN fgm_yra  = [0d0,45d0]
IF (date EQ '102411') THEN fgm_yra  = [0d0,11d1]
IF (date EQ '072309' OR date EQ '102411') THEN test_fgm = (N_ELEMENTS(fgm_yra) NE 0)
IF (test_fgm AND (date EQ '072309' OR date EQ '102411')) THEN options,tpnm_fgm_bmag,'YRANGE'
IF (test_fgm AND (date EQ '072309' OR date EQ '102411')) THEN options,tpnm_fgm_bmag,'YRANGE',fgm_yra,/DEF
fname          = fnames1
tzoom          = tzoom1
tramp          = t_ramp1[0]
FOR i=0L, ntz - 1L DO BEGIN                            $
  j = (ntz - 1L) - i[0]                              & $
  IF (j GT 0) THEN k = j - 1L ELSE k = j             & $
  popen,fname[j],/LAND                               & $
    tplot,tpnm_fgm_bmag,TRANGE=REFORM(tzoom[j,*])    & $
    time_bar,REFORM(tzoom[k,*]),COLOR=250            & $
    time_bar,tramp[0],COLOR=150                      & $
  pclose

IF (date EQ '072309') THEN fgm_yra  = [0d0,45d0]
IF (date EQ '072309') THEN test_fgm = (N_ELEMENTS(fgm_yra) NE 0)
IF (test_fgm AND date EQ '072309') THEN options,tpnm_fgm_bmag,'YRANGE'
IF (test_fgm AND date EQ '072309') THEN options,tpnm_fgm_bmag,'YRANGE',fgm_yra,/DEF
fname          = fnames2
tzoom          = tzoom2
tramp          = t_ramp2[0]
FOR i=0L, ntz - 1L DO BEGIN                            $
  j = (ntz - 1L) - i[0]                              & $
  IF (j GT 0) THEN k = j - 1L ELSE k = j             & $
  popen,fname[j],/LAND                               & $
    tplot,tpnm_fgm_bmag,TRANGE=REFORM(tzoom[j,*])    & $
    time_bar,REFORM(tzoom[k,*]),COLOR=250            & $
    time_bar,tramp[0],COLOR=150                      & $
  pclose



f_pref         = prefu[0]+'fgs-fgl-fgh_mag_compare_ALL-Zooms_'
fnames0        = f_pref[0]+ftimes0+tz_strs+f_suffx0[0]
fnames1        = f_pref[0]+ftimes1+tz_strs+f_suffx1[0]
fnames2        = f_pref[0]+ftimes2+tz_strs+f_suffx2[0]

IF (date EQ '072309') THEN fgm_yra  = [0d0,50d0]
IF (date EQ '102411') THEN fgm_yra  = [0d0,70d0]
IF (date EQ '072309' OR date EQ '102411') THEN test_fgm = (N_ELEMENTS(fgm_yra) NE 0)
IF (test_fgm AND (date EQ '072309' OR date EQ '102411')) THEN options,tpnm_fgm_bmag,'YRANGE'
IF (test_fgm AND (date EQ '072309' OR date EQ '102411')) THEN options,tpnm_fgm_bmag,'YRANGE',fgm_yra,/DEF
fname          = fnames0
tzoom          = tzoom0
tramp          = t_ramp0[0]
FOR j=0L, ntz - 1L DO BEGIN                            $
  popen,fname[j],/LAND                               & $
    tplot,tpnm_fgm_bmag,TRANGE=REFORM(tzoom[j,*])    & $
    time_bar,tramp[0],COLOR=150                      & $
    time_bar,REFORM(tzoom[*,0]),COLOR=250            & $
    time_bar,REFORM(tzoom[*,1]),COLOR=250            & $
  pclose

IF (date EQ '072309') THEN fgm_yra  = [0d0,45d0]
IF (date EQ '102411') THEN fgm_yra  = [0d0,11d1]
IF (date EQ '072309' OR date EQ '102411') THEN test_fgm = (N_ELEMENTS(fgm_yra) NE 0)
IF (test_fgm AND (date EQ '072309' OR date EQ '102411')) THEN options,tpnm_fgm_bmag,'YRANGE'
IF (test_fgm AND (date EQ '072309' OR date EQ '102411')) THEN options,tpnm_fgm_bmag,'YRANGE',fgm_yra,/DEF
fname          = fnames1
tzoom          = tzoom1
tramp          = t_ramp1[0]
FOR j=0L, ntz - 1L DO BEGIN                            $
  popen,fname[j],/LAND                               & $
    tplot,tpnm_fgm_bmag,TRANGE=REFORM(tzoom[j,*])    & $
    time_bar,tramp[0],COLOR=150                      & $
    time_bar,REFORM(tzoom[*,0]),COLOR=250            & $
    time_bar,REFORM(tzoom[*,1]),COLOR=250            & $
  pclose

IF (date EQ '072309') THEN fgm_yra  = [0d0,45d0]
IF (date EQ '072309') THEN test_fgm = (N_ELEMENTS(fgm_yra) NE 0)
IF (test_fgm AND date EQ '072309') THEN options,tpnm_fgm_bmag,'YRANGE'
IF (test_fgm AND date EQ '072309') THEN options,tpnm_fgm_bmag,'YRANGE',fgm_yra,/DEF
fname          = fnames2
tzoom          = tzoom2
tramp          = t_ramp2[0]
FOR j=0L, ntz - 1L DO BEGIN                            $
  popen,fname[j],/LAND                               & $
    tplot,tpnm_fgm_bmag,TRANGE=REFORM(tzoom[j,*])    & $
    time_bar,tramp[0],COLOR=150                      & $
    time_bar,REFORM(tzoom[*,0]),COLOR=250            & $
    time_bar,REFORM(tzoom[*,1]),COLOR=250            & $
  pclose
;;----------------------------------------------------------------------------------------
;; => Plot velocity moment results
;;----------------------------------------------------------------------------------------
coord          = 'gse'
nif_suffx      = '-RHS02'
coord_nif      = 'nif_S1986a'+nif_suffx[0]
mode_fgm       = ['fgs','fgl','fgh']
magname        = tnames(scpref[0]+mode_fgm[0]+'_'+coord[0])
tpnm_fgm_bmag  = tnames(scpref[0]+mode_fgm+'_mag')
tpnm_fgm_bgse  = tnames(scpref[0]+mode_fgm+'_'+coord[0])
tpnm_fgm_bnif  = tnames(scpref[0]+mode_fgm+'_'+coord_nif[0])
fgs_gse_nm     = [tpnm_fgm_bmag[0],magname[0]]

IF (date EQ '072309') THEN vel_suffx = 'Velocity_peib_no_GIs_UV_2'
den_suffx      = 'N_peib_no_GIs_UV'
itemp_suffx    = 'T_avg_peib_no_GIs_UV'
etemp_suffx    = 'peeb_avgtemp'

;;  Define "corrected" core ion velocity moment TPLOT handles
N_i_core       = tnames(scpref[0]+den_suffx[0])
T_i_core       = tnames(scpref[0]+itemp_suffx[0])
T_e_bulk       = tnames(scpref[0]+etemp_suffx[0])
V_i_core       = tnames(scpref[0]+vel_suffx[0])

;;  Reset default Y-Axis ranges
IF (date EQ '072309') THEN Nic_yra  = [0d0,25d0]
IF (date EQ '072309') THEN Tic_yra  = [0d0,35d1]
IF (date EQ '072309') THEN Te__yra  = [0d0,80d0]
IF (date EQ '072309') THEN Vic_yra  = [-550d0,200d0]

IF (N_ELEMENTS(Nic_yra) NE 0 AND date EQ '072309') THEN options,N_i_core[0],'YRANGE',Nic_yra,/DEF
IF (N_ELEMENTS(Tic_yra) NE 0 AND date EQ '072309') THEN options,T_i_core[0],'YRANGE',Tic_yra,/DEF
IF (N_ELEMENTS(Te__yra) NE 0 AND date EQ '072309') THEN options,T_e_bulk[0],'YRANGE',Te__yra,/DEF
IF (N_ELEMENTS(Vic_yra) NE 0 AND date EQ '072309') THEN options,V_i_core[0],'YRANGE',Vic_yra,/DEF

IF (N_ELEMENTS(Vic_yra) NE 0 AND date EQ '072309') THEN options,V_i_core[0],'YTICKS',5,/DEF
IF (N_ELEMENTS(Te__yra) NE 0 AND date EQ '072309') THEN options,T_e_bulk[0],'YTICKS',8,/DEF
IF (N_ELEMENTS(Vic_yra) NE 0 AND date EQ '072309') THEN options,V_i_core[0],'YMINOR',5,/DEF
IF (N_ELEMENTS(Te__yra) NE 0 AND date EQ '072309') THEN options,T_e_bulk[0],'YMINOR',5,/DEF

;;  Reset default Y-Axis tick lengths
all_mom_names  = [N_i_core[0],T_i_core[0],T_e_burst[0],Vel_i_core[0]]
options,all_mom_names,'YTICKLEN'
options,all_mom_names,'YTICKLEN',/DEF
options,all_mom_names,'YTICKLEN',1.0       ;;  use full-length tick marks
options,all_mom_names,'YGRIDSTYLE',1       ;;  use dotted lines

;;  For 2009-07-23
tz_tra         = REFORM(tzoom1[7,*]) + [-20d0,-10d0]
fnm_tra        = file_name_times(tz_tra,PREC=4)
ftime1         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
f_pref         = prefu[0]+'fgs-gse-mag_Nic_Tic_Te__Vic_ALL-Zooms_'
fname1         = f_pref[0]+ftime1+f_suffx1[0]
tzoom          = tzoom1
tramp          = t_ramp1[0]


nna            = [fgs_gse_nm,all_mom_names]
  tplot,nna,TRANGE=tz_tra
  time_bar,tramp[0],COLOR=150
  time_bar,REFORM(tzoom[*,0]),COLOR=250
  time_bar,REFORM(tzoom[*,1]),COLOR=250
popen,fname1[0],/PORT
  tplot,nna,TRANGE=tz_tra
  time_bar,tramp[0],COLOR=150
  time_bar,REFORM(tzoom[*,0]),COLOR=250
  time_bar,REFORM(tzoom[*,1]),COLOR=250
pclose


;;----------------------------------------------------------------------------------------
;; => Plot dB/Bo
;;----------------------------------------------------------------------------------------
coord          = 'gse'
nif_suffx      = '-RHS02'
coord_nif      = 'nif_S1986a'+nif_suffx[0]
mode_fgm       = ['fgs','fgl','fgh']
tpnm_fgm_bmag  = tnames(scpref[0]+mode_fgm+'_mag')
tpnm_fgm_bgse  = tnames(scpref[0]+mode_fgm+'_'+coord[0])

;;  Output TPLOT handles for dB/Bo
tpnm_fgm_db_bo = scpref[0]+mode_fgm+'_dBmag_Bo'
tpnm_fgm_db_bv = scpref[0]+mode_fgm+'_dBvec_B'
tpnmfgm_dBmB_B = scpref[0]+mode_fgm+'_dBmagBo_Bo'
tpnmfgm_dBvB_B = scpref[0]+mode_fgm+'_dBvecBvec_Bo'


;;  For 2nd Crossing on 2009-07-23
IF (date EQ '072309') THEN gnorm   = [0.99615338d0,-0.079060538d0,-0.0026399172d0]
IF (date EQ '072309') THEN magf_up = [-0.114245d0,0.135357d0,-6.06984d0]
IF (date EQ '072309') THEN magf_dn = [1.48669d0,-17.6263d0,-15.3921d0]

bmag_up        = SQRT(TOTAL(magf_up^2,/NAN))
bmag_dn        = SQRT(TOTAL(magf_dn^2,/NAN))
PRINT,';;', bmag_up[0], bmag_dn[0]
;;       6.0724238       23.448101


;;  |B|/<|B|>_{up}
get_data,tpnm_fgm_bmag[2],DATA=temp_bmag,DLIM=dlim_bmag,LIM=lim_bmag
bmag00         = temp_bmag.Y
db_bo          = bmag00/bmag_up[0]
struct         = {X:temp_bmag.X,Y:db_bo}
yttle          = '|B|/<|B|>!Dup!N ['+mode_fgm[2]+', unitless]'
str_element,dlim_bmag,'YTITLE',yttle[0],/ADD_REPLACE
store_data,tpnm_fgm_db_bo[2],DATA=struct,DLIM=dlim_bmag,LIM=lim_bmag

;;  B/<B>_{up}
get_data,tpnm_fgm_bgse[2],DATA=temp_bvec,DLIM=dlim_bvec,LIM=lim_bvec
bvec00         = temp_bvec.Y
;dbx_box        = (bvec00[*,0]/ABS(magf_up[0]))
;dby_boy        = (bvec00[*,1]/ABS(magf_up[1]))
;dbz_boz        = (bvec00[*,2]/ABS(magf_up[2]))
dbx_box        = (bvec00[*,0]/ABS(bmag_up[0]))
dby_boy        = (bvec00[*,1]/ABS(bmag_up[0]))
dbz_boz        = (bvec00[*,2]/ABS(bmag_up[0]))
dbv_bov        = [[dbx_box],[dby_boy],[dbz_boz]]
struct         = {X:temp_bvec.X,Y:dbv_bov}
yttle          = 'B/<|B|>!Dup!N ['+mode_fgm[2]+', GSE, unitless]'
str_element,dlim_bvec,'YTITLE',yttle[0],/ADD_REPLACE
store_data,tpnm_fgm_db_bv[2],DATA=struct,DLIM=dlim_bvec,LIM=lim_bvec

;;  (d|B| - <|B|>_{up})/<|B|>_{up}
get_data,tpnm_fgm_bmag[2],DATA=temp_bmag,DLIM=dlim_bmag,LIM=lim_bmag
bmag00         = temp_bmag.Y
db_bo          = (bmag00 - bmag_up[0])/bmag_up[0]
struct         = {X:temp_bmag.X,Y:db_bo}
yttle          = '(|B| - <|B|>!Dup!N'+')/<|B|>!Dup!N ['+mode_fgm[2]+', unitless]'
str_element,dlim_bmag,'YTITLE',yttle[0],/ADD_REPLACE
store_data,tpnmfgm_dBmB_B[2],DATA=struct,DLIM=dlim_bmag,LIM=lim_bmag

;;  (dB - <B>_{up})/<|B|>_{up}
get_data,tpnm_fgm_bgse[2],DATA=temp_bvec,DLIM=dlim_bvec,LIM=lim_bvec
bvec00         = temp_bvec.Y
dbx_box        = (bvec00[*,0] - magf_up[0])/ABS(bmag_up[0])
dby_boy        = (bvec00[*,1] - magf_up[1])/ABS(bmag_up[0])
dbz_boz        = (bvec00[*,2] - magf_up[2])/ABS(bmag_up[0])
dbv_bov        = [[dbx_box],[dby_boy],[dbz_boz]]
struct         = {X:temp_bvec.X,Y:dbv_bov}
yttle          = '(B - <B>!Dup!N'+')/<|B|>!Dup!N ['+mode_fgm[2]+', GSE, unitless]'
str_element,dlim_bvec,'YTITLE',yttle[0],/ADD_REPLACE
store_data,tpnmfgm_dBvB_B[2],DATA=struct,DLIM=dlim_bvec,LIM=lim_bvec


jj             = 5L
tz_tra         = REFORM(tzoom1[jj,*])
fnm_tra        = file_name_times(tz_tra,PREC=4)
ftime1         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
f_pref         = prefu[0]+'fgh-mag-gse_Bmag_Boup_Bvec_Bvup_ALL-Zooms_'
fname1         = f_pref[0]+ftime1[0]+tz_strs[jj]+f_suffx1[0]
tzoom          = tzoom1
tramp          = t_ramp1[0]
nna            = [tpnm_fgm_bmag[2],tpnm_fgm_bgse[2],tpnm_fgm_db_bo[2],tpnm_fgm_db_bv[2]]
  tplot,nna,TRANGE=tz_tra
  time_bar,tramp[0],COLOR=150
  time_bar,REFORM(tzoom[*,0]),COLOR=250
  time_bar,REFORM(tzoom[*,1]),COLOR=250
popen,fname1[0],/PORT
  tplot,nna,TRANGE=tz_tra
  time_bar,tramp[0],COLOR=150
  time_bar,REFORM(tzoom[*,0]),COLOR=250
  time_bar,REFORM(tzoom[*,1]),COLOR=250
pclose



tz_tra         = REFORM(tzoom1[jj,*])
fnm_tra        = file_name_times(tz_tra,PREC=4)
ftime1         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
f_pref         = prefu[0]+'fgh-mag-gse_Bmag-Boup_Boup_Bvec-Bvup_Boup_ALL-Zooms_'
fname1         = f_pref[0]+ftime1[0]+tz_strs[jj]+f_suffx1[0]
tzoom          = tzoom1
tramp          = t_ramp1[0]
nna            = [tpnm_fgm_bmag[2],tpnm_fgm_bgse[2],tpnmfgm_dBmB_B[2],tpnmfgm_dBvB_B[2]]
  tplot,nna,TRANGE=tz_tra
  time_bar,tramp[0],COLOR=150
  time_bar,REFORM(tzoom[*,0]),COLOR=250
  time_bar,REFORM(tzoom[*,1]),COLOR=250
popen,fname1[0],/PORT
  tplot,nna,TRANGE=tz_tra
  time_bar,tramp[0],COLOR=150
  time_bar,REFORM(tzoom[*,0]),COLOR=250
  time_bar,REFORM(tzoom[*,1]),COLOR=250
pclose





























































;;----------------------------------------------------------------------------------------
;; => Extra [For 2009-07-23]
;;----------------------------------------------------------------------------------------

gnorm          = [0.99615338d0,-0.079060538d0,-0.0026399172d0]
magf_up        = [-0.114245d0,0.135357d0,-6.06984d0]
magf_dn        = [1.48669d0,-17.6263d0,-15.3921d0]
;; => Define NCB rotation matrix
;;        {Use Scudder et al., [1986a]}

;; => X'-vector
xvnor          = gnorm/NORM(REFORM(gnorm))
;;  Get rotation Matrix from NCB(ICB) to ICB(NCB)
rmats          = r_matrix_nif_s1986a(magf_up,magf_dn,xvnor)
;; => Rotation Matrix from NCB to ICB
rotgse         = rmats.R_NCB_2_ICB
;; => Define rotation from ICB to NCB
rotnif         = rmats.R_ICB_2_NCB


;; => Y'-vector
yvect          = my_crossp_2(magf_dn,magf_up,/NOM)
yvnor          = yvect/NORM(REFORM(yvect))      ;;  Re-normalize
;; => Z'-vector
zvect          = my_crossp_2(xvnor,yvnor,/NOM)
zvnor          = zvect/NORM(REFORM(zvect))      ;;  Re-normalize


print, reform(rotnif ## xvnor)
print, reform(rotnif ## yvnor)
print, reform(rotnif ## zvnor)







