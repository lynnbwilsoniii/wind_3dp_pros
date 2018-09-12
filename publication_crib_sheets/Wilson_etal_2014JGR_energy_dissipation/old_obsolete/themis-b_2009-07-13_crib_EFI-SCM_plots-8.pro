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
;; => Date/Time and Probe
tdate          = '2009-07-13'
tr_00          = tdate[0]+'/'+['07:50:00','10:10:00']
date           = '071309'
probe          = 'b'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
;; => Shock Ramp Times
t_ramp_1       = time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290'])
t_ramp_2       = time_double(tdate[0]+'/'+['09:24:43.340','09:24:55.100'])
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
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='EFI&SCM Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01

coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
modes_pw       = ['p','w']
mode_efi       = 'ef'+modes_pw
mode_scm       = 'sc'+modes_pw
velname        = pref[0]+'peib_velocity_'+coord[0]
magname        = pref[0]+'fgh_'+coord[0]
fgmnm          = pref[0]+'fgh_'+['mag',coord[0]]
tr_jj          = time_double(tdate[0]+'/'+['08:50:00.000','09:30:00.000'])

tplot,fgmnm,TRANGE=tr_jj
;;----------------------------------------------------------------------------------------
;; => Load E&B-Fields
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

;; => Remove "spikes" by hand
coord_in       = 'dsl'
scp_names      = tnames(pref[0]+'scp_cal_'+coord_in[0]+'*')
efp_names      = tnames(pref[0]+'efp_cal_'+coord_in[0]+'*')
all_fields     = [scp_names,efp_names]
names          = [fgmnm,all_fields]
tplot,names

.compile kill_data_tr
;;  Remove unused time ranges
kill_data_tr,NAMES=[efp_names[0],scp_names[0]]
kill_data_tr,NAMES=efp_names[0]

;; => Remove "spikes" by hand
coord_in       = 'dsl'
scw_names      = tnames(pref[0]+'scw_cal_'+coord_in[0]+'*')
efw_names      = tnames(pref[0]+'efw_cal_'+coord_in[0]+'*')
all_fields     = [scw_names,efw_names]
names          = [fgmnm,all_fields]
tplot,names

;;  Remove unused time ranges
kill_data_tr,NAMES=[efw_names[0],scw_names[0]]
kill_data_tr,NAMES=efw_names[0]


;; => Specify # of "spikes" to remove by hand each time and save time ranges
coord_in       = 'dsl'
efp_names      = tnames(pref[0]+'efp_cal_'+coord_in[0]+'*')
efw_names      = tnames(pref[0]+'efw_cal_'+coord_in[0]+'*')
kill_tags      = 'T_'+STRING(LINDGEN(50),FORMAT='(I3.3)')
tr_pp          = time_double(tdate[0]+'/'+['08:54:44.000','09:38:18.000'])
tr_pp1         = time_double(tdate[0]+'/'+['08:54:49.000','09:10:35.000'])
tr_pp2         = time_double(tdate[0]+'/'+['09:14:10.000','09:38:13.000'])


jj             = 0L
nk             = 37L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 31L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 22L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 19L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 23L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 31L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 22L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 23L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 18L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 10L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 1L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 6L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 19L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 2L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 20L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 17L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 14L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 3L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 6L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 7L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 5L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 6L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 7L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 7L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 4L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 4L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 7L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 7L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 4L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 5L & jj += 1L & tra_nk_efp_0 = 0
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE



;;  Print out time ranges removed from efp
ntra           = N_TAGS(tra_nk_efp_all)
FOR j=0L, ntra - 1L DO BEGIN           $
  tra_str0 = tra_nk_efp_all.(j)      & $
  nt       = N_TAGS(tra_str0)        & $
  FOR i=0L, nt - 1L DO BEGIN           $
    PRINT,';;  ',time_string(tra_str0.(i),PREC=4)



tr_ww          = time_double(tdate[0]+'/'+['08:59:32.000','09:20:12.000'])
tr_ww0         = time_double(tdate[0]+'/'+['08:59:42.770','08:59:55.760'])
tr_ww00        = time_double(tdate[0]+'/'+['08:59:42.770','08:59:49.290'])
tr_ww01        = time_double(tdate[0]+'/'+['08:59:49.298','08:59:55.760'])

kill_tags      = 'T_'+STRING(LINDGEN(50),FORMAT='(I3.3)')
jj             = 0L
nk             = 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L & tra_nk_efw_0 = 0
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L & tra_nk_efw_0 = 0
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L & tra_nk_efw_0 = 0
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L & tra_nk_efw_0 = 0
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE


;;  Print out time ranges removed from efw
ntra           = N_TAGS(tra_nk_efw_all)
FOR j=0L, ntra - 1L DO BEGIN           $
  tra_str0 = tra_nk_efw_all.(j)      & $
  nt       = N_TAGS(tra_str0)        & $
  FOR i=0L, nt - 1L DO BEGIN           $
    PRINT,';;  ',time_string(tra_str0.(i),PREC=4)




;; => Remove NaNs in data
get_data,scp_names[0],DATA=temp_scp,DLIM=dlim_scp,LIM=lim_scp
get_data,scw_names[0],DATA=temp_scw,DLIM=dlim_scw,LIM=lim_scw
get_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
get_data,efw_names[0],DATA=temp_efw,DLIM=dlim_efw,LIM=lim_efw

test_scp       = FINITE(temp_scp.Y[*,0]) AND FINITE(temp_scp.Y[*,1]) AND FINITE(temp_scp.Y[*,2])
good_scp       = WHERE(test_scp,gdscp)
test_scw       = FINITE(temp_scw.Y[*,0]) AND FINITE(temp_scw.Y[*,1]) AND FINITE(temp_scw.Y[*,2])
good_scw       = WHERE(test_scw,gdscw)
test_efp       = FINITE(temp_efp.Y[*,0]) AND FINITE(temp_efp.Y[*,1]) AND FINITE(temp_efp.Y[*,2])
good_efp       = WHERE(test_efp,gdefp)
test_efw       = FINITE(temp_efw.Y[*,0]) AND FINITE(temp_efw.Y[*,1]) AND FINITE(temp_efw.Y[*,2])
good_efw       = WHERE(test_efw,gdefw)
PRINT,';; ', gdscp, gdscw, gdefp, gdefw
;;       272550      156672      265083      417286

;; => Interpolate gaps
;;  efp
IF (gdefp GT 0) THEN temp_efpx = interp(temp_efp.Y[good_efp,0],temp_efp.X[good_efp],temp_efp.X,/NO_EXTRAP) ELSE temp_efpx = 0
IF (gdefp GT 0) THEN temp_efpy = interp(temp_efp.Y[good_efp,1],temp_efp.X[good_efp],temp_efp.X,/NO_EXTRAP) ELSE temp_efpy = 0
IF (gdefp GT 0) THEN temp_efpz = interp(temp_efp.Y[good_efp,2],temp_efp.X[good_efp],temp_efp.X,/NO_EXTRAP) ELSE temp_efpz = 0
;;  efw
IF (gdefw GT 0) THEN temp_efwx = interp(temp_efw.Y[good_efw,0],temp_efw.X[good_efw],temp_efw.X,/NO_EXTRAP) ELSE temp_efwx = 0
IF (gdefw GT 0) THEN temp_efwy = interp(temp_efw.Y[good_efw,1],temp_efw.X[good_efw],temp_efw.X,/NO_EXTRAP) ELSE temp_efwy = 0
IF (gdefw GT 0) THEN temp_efwz = interp(temp_efw.Y[good_efw,2],temp_efw.X[good_efw],temp_efw.X,/NO_EXTRAP) ELSE temp_efwz = 0
;; => Try again with efp and efw
temp_efpv      = [[temp_efpx],[temp_efpy],[temp_efpz]]
temp_efwv      = [[temp_efwx],[temp_efwy],[temp_efwz]]
test_efp       = FINITE(temp_efpv[*,0]) AND FINITE(temp_efpv[*,1]) AND FINITE(temp_efpv[*,2])
good_efp       = WHERE(test_efp,gdefp)
test_efw       = FINITE(temp_efwv[*,0]) AND FINITE(temp_efwv[*,1]) AND FINITE(temp_efwv[*,2])
good_efw       = WHERE(test_efw,gdefw)
PRINT,';; ', gdefp, gdefw
;;       301553      626688


IF (gdscp GT 0) THEN temp_scp = {X:temp_scp.X[good_scp],Y:temp_scp.Y[good_scp,*]} ELSE temp_scp = 0
IF (gdscw GT 0) THEN temp_scw = {X:temp_scw.X[good_scw],Y:temp_scw.Y[good_scw,*]} ELSE temp_scw = 0
IF (gdefp GT 0) THEN temp_efp = {X:temp_efp.X[good_efp],Y:temp_efpv[good_efp,*]} ELSE temp_efp = 0
IF (gdefw GT 0) THEN temp_efw = {X:temp_efw.X[good_efw],Y:temp_efwv[good_efw,*]} ELSE temp_efw = 0
IF (gdscp GT 0) THEN store_data,scp_names[0],DATA=temp_scp,DLIM=dlim_scp,LIM=lim_scp
IF (gdscw GT 0) THEN store_data,scw_names[0],DATA=temp_scw,DLIM=dlim_scw,LIM=lim_scw
IF (gdefp GT 0) THEN store_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
IF (gdefw GT 0) THEN store_data,efw_names[0],DATA=temp_efw,DLIM=dlim_efw,LIM=lim_efw
IF (gdscp EQ 0) THEN del_data,scp_names[0]
IF (gdscw EQ 0) THEN del_data,scw_names[0]
IF (gdefp EQ 0) THEN del_data,efp_names[0]
IF (gdefw EQ 0) THEN del_data,efw_names[0]

;; => Clean up
DELVAR, test_scp, good_scp, test_scw, good_scw
DELVAR, test_efp, good_efp, test_efw, good_efw
;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI [1st shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
t_ramp         = MEAN(time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290']),/NAN)
;;  Shock Parameters
vshn_up        =  -52.769597d0
ushn_up        = -271.85307d0
ushn_dn        =  -41.225873d0
gnorm          = [0.99012543d0,0.086580460d0,-0.0038282813d0]
theta_Bn       =   42.213702d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-328.746d0,10.8691d0,16.8013d0]
vswi_dn        = [ -97.0335d0,23.6190d0,-9.12016d0]
magf_up        = [-2.88930d0,1.79045d0,-1.37976d0]
magf_dn        = [  -3.85673d0,10.8180d0,-8.72761d0]
dens_up        =    7.21921d0
dens_dn        =   47.84030d0
Ti___up        =   30.1554d0
Ti___dn        =  158.597d0
Te___up        =   11.2373d0
Te___dn        =   30.5007d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_in       = 'gse'
vsw_tpnm       = tnames(pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV')
tramp          = t_ramp[0]
nsm            = 10L
nif_suffx      = '-RHS01'
;;  need to remove them by hand and then rename SCW and S b/c they have different
;;    # of intervals
;;
;;    Intervals [0L,1L] are good for the following:
;;      *_scw_cal_*
;;      *_efw_cal_corrected_DownSampled_*
;;      *_S__TimeSeries_*
;;
;;    Intervals [0L,1L] are good for the following:
;;      *_efw_cal_gse_*
;;      *_efw_cal_corrected_gse_*
;;
;gint           = [0L,5L,6L]
gint           = LINDGEN(15)

.compile temp_thm_cal_rot_ebfields
.compile temp_calc_j_S_nif_etc
temp_thm_cal_rot_ebfields,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,$
                          VSW_TPNM=vsw_tpnm,TRAMP=tramp,NSM=nsm,   $
                          GINT=gint,NIF_SUFFX=nif_suffx[0]
;;  Enter the following by hand at 1st STOP statement in temp_thm_cal_rot_ebfields.pro
bind           = LINDGEN(9) + 2L
del_data,tnames('*_scw_cal_*'+isuffx[bind])
del_data,tnames('*_efw_cal_corrected_DownSampled_*'+isuffx[bind])
del_data,tnames('*_S__TimeSeries_*'+isuffx[bind])
del_data,tnames('*_efw_cal_gse'+isuffx[bind])
del_data,tnames('*_efw_cal_corrected_gse'+isuffx[bind])
gind           = [0L,1L]
.c

;;  Note:  There are 3 BS crossings for this apogee pass, but only the 1st has
;;           efw and scw data in the ramp

;;----------------------------------------------------------------------------------------
;; => Print values to ASCII file
;;----------------------------------------------------------------------------------------
nsm            = 10L
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290']),/NAN)
gint           = [0L]
fsuffx         = '_1st-BS-Crossing-0'
magf_up        = [-2.88930d0,1.79045d0,-1.37976d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],$
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,   $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0])

nsm            = 10L
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290']),/NAN)
gint           = [1L]
fsuffx         = '_1st-BS-Crossing'
magf_up        = [-2.88930d0,1.79045d0,-1.37976d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],$
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,   $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0])
;;--------------------------------
;;--------------------------------
;;  Merge the above 2 by hand
;;--------------------------------
;;--------------------------------




































































































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


























































;;  Print out time ranges removed from efp
ntra           = N_TAGS(tra_nk_efp_all)
FOR j=0L, ntra - 1L DO BEGIN           $
  tra_str0 = tra_nk_efp_all.(j)      & $
  nt       = N_TAGS(tra_str0)        & $
  FOR i=0L, nt - 1L DO BEGIN           $
    PRINT,';;  ',time_string(tra_str0.(i),PREC=4)
;;   2009-07-13/08:54:53.9700 2009-07-13/08:54:54.1200
;;   2009-07-13/08:54:54.7900 2009-07-13/08:54:54.8800
;;   2009-07-13/08:54:55.5300 2009-07-13/08:54:55.6100
;;   2009-07-13/08:54:56.2800 2009-07-13/08:54:56.3700
;;   2009-07-13/08:54:57.0200 2009-07-13/08:54:57.1000
;;   2009-07-13/08:54:57.7700 2009-07-13/08:54:57.8400
;;   2009-07-13/08:54:58.5100 2009-07-13/08:54:58.5900
;;   2009-07-13/08:54:59.2800 2009-07-13/08:54:59.3500
;;   2009-07-13/08:55:00.0000 2009-07-13/08:55:00.0600
;;   2009-07-13/08:55:00.7300 2009-07-13/08:55:00.8200
;;   2009-07-13/08:55:01.4900 2009-07-13/08:55:01.5700
;;   2009-07-13/08:55:02.2200 2009-07-13/08:55:02.2900
;;   2009-07-13/08:55:02.9700 2009-07-13/08:55:03.0600
;;   2009-07-13/08:55:03.7100 2009-07-13/08:55:03.7700
;;   2009-07-13/08:55:04.4400 2009-07-13/08:55:04.5300
;;   2009-07-13/08:55:05.2000 2009-07-13/08:55:05.2700
;;   2009-07-13/08:55:05.9300 2009-07-13/08:55:06.0200
;;   2009-07-13/08:55:06.6600 2009-07-13/08:55:06.7600
;;   2009-07-13/08:55:07.3800 2009-07-13/08:55:07.5300
;;   2009-07-13/08:55:08.1600 2009-07-13/08:55:08.2500
;;   2009-07-13/08:55:08.9100 2009-07-13/08:55:08.9800
;;   2009-07-13/08:55:09.6200 2009-07-13/08:55:09.7300
;;   2009-07-13/08:55:10.3600 2009-07-13/08:55:10.4500
;;   2009-07-13/08:55:11.1400 2009-07-13/08:55:11.2000
;;   2009-07-13/08:55:11.8500 2009-07-13/08:55:11.9800
;;   2009-07-13/08:55:12.5500 2009-07-13/08:55:12.6900
;;   2009-07-13/08:55:13.3400 2009-07-13/08:55:13.4100
;;   2009-07-13/08:55:14.0900 2009-07-13/08:55:14.2000
;;   2009-07-13/08:55:14.8500 2009-07-13/08:55:14.9200
;;   2009-07-13/08:55:15.5600 2009-07-13/08:55:15.6500
;;   2009-07-13/08:55:16.3200 2009-07-13/08:55:16.3900
;;   2009-07-13/08:55:17.0500 2009-07-13/08:55:17.1600
;;   2009-07-13/08:55:17.8000 2009-07-13/08:55:17.8800
;;   2009-07-13/08:55:18.5400 2009-07-13/08:55:18.6300
;;   2009-07-13/08:55:19.2700 2009-07-13/08:55:19.3700
;;   2009-07-13/08:55:19.8500 2009-07-13/08:55:20.1700
;;   2009-07-13/08:55:20.7800 2009-07-13/08:55:20.8500
;;   2009-07-13/08:55:21.5300 2009-07-13/08:55:21.5800
;;   2009-07-13/08:55:22.2300 2009-07-13/08:55:22.3700
;;   2009-07-13/08:55:22.9900 2009-07-13/08:55:23.0800
;;   2009-07-13/08:55:23.7400 2009-07-13/08:55:23.8300
;;   2009-07-13/08:55:24.4500 2009-07-13/08:55:24.5900
;;   2009-07-13/08:55:25.2200 2009-07-13/08:55:25.2900
;;   2009-07-13/08:55:25.9800 2009-07-13/08:55:26.0300
;;   2009-07-13/08:55:26.7200 2009-07-13/08:55:26.7900
;;   2009-07-13/08:55:27.4600 2009-07-13/08:55:27.5100
;;   2009-07-13/08:55:28.1600 2009-07-13/08:55:28.2700
;;   2009-07-13/08:55:28.9400 2009-07-13/08:55:29.0600
;;   2009-07-13/08:55:29.6800 2009-07-13/08:55:29.7700
;;   2009-07-13/08:55:30.4000 2009-07-13/08:55:30.5100
;;   2009-07-13/08:55:31.1600 2009-07-13/08:55:31.2500
;;   2009-07-13/08:55:31.9000 2009-07-13/08:55:31.9900
;;   2009-07-13/08:55:32.6400 2009-07-13/08:55:32.7300
;;   2009-07-13/08:55:33.3900 2009-07-13/08:55:33.4700
;;   2009-07-13/08:55:34.1200 2009-07-13/08:55:34.2000
;;   2009-07-13/08:55:34.8900 2009-07-13/08:55:35.0100
;;   2009-07-13/08:55:35.5800 2009-07-13/08:55:35.7400
;;   2009-07-13/08:55:36.3500 2009-07-13/08:55:36.5600
;;   2009-07-13/08:55:37.1100 2009-07-13/08:55:37.2000
;;   2009-07-13/08:55:37.8100 2009-07-13/08:55:37.9400
;;   2009-07-13/08:55:39.2800 2009-07-13/08:55:39.4900
;;   2009-07-13/08:55:39.9800 2009-07-13/08:55:40.2100
;;   2009-07-13/08:55:40.7900 2009-07-13/08:55:40.9700
;;   2009-07-13/08:55:42.1800 2009-07-13/08:55:42.4100
;;   2009-07-13/08:55:43.7700 2009-07-13/08:55:43.8500
;;   2009-07-13/08:55:44.5100 2009-07-13/08:55:44.6300
;;   2009-07-13/08:55:43.0100 2009-07-13/08:55:43.1300
;;   2009-07-13/08:55:38.5500 2009-07-13/08:55:38.6400
;;   2009-07-13/08:55:45.2400 2009-07-13/08:55:45.3500
;;   2009-07-13/08:55:46.7000 2009-07-13/08:55:46.8300
;;   2009-07-13/08:55:48.2100 2009-07-13/08:55:48.2900
;;   2009-07-13/08:55:49.6900 2009-07-13/08:55:49.8600
;;   2009-07-13/08:55:51.1500 2009-07-13/08:55:51.3000
;;   2009-07-13/08:55:52.6500 2009-07-13/08:55:52.7800
;;   2009-07-13/08:55:54.0900 2009-07-13/08:55:54.2800
;;   2009-07-13/08:55:55.5900 2009-07-13/08:55:55.7700
;;   2009-07-13/08:55:57.1200 2009-07-13/08:55:57.2700
;;   2009-07-13/08:55:58.6000 2009-07-13/08:55:58.7300
;;   2009-07-13/08:56:00.0800 2009-07-13/08:56:00.1900
;;   2009-07-13/08:56:01.4700 2009-07-13/08:56:01.7600
;;   2009-07-13/08:56:03.0200 2009-07-13/08:56:03.1300
;;   2009-07-13/08:56:04.5200 2009-07-13/08:56:04.6300
;;   2009-07-13/08:56:06.0300 2009-07-13/08:56:06.1400
;;   2009-07-13/08:56:07.5100 2009-07-13/08:56:07.6200
;;   2009-07-13/08:56:08.9900 2009-07-13/08:56:09.0800
;;   2009-07-13/08:56:10.4700 2009-07-13/08:56:10.5600
;;   2009-07-13/08:56:11.9500 2009-07-13/08:56:12.0600
;;   2009-07-13/08:56:13.4300 2009-07-13/08:56:13.5700
;;   2009-07-13/08:56:14.9200 2009-07-13/08:56:15.0300
;;   2009-07-13/08:56:16.4200 2009-07-13/08:56:16.5300
;;   2009-07-13/08:56:17.8700 2009-07-13/08:56:17.9800
;;   2009-07-13/08:56:19.3600 2009-07-13/08:56:19.4700
;;   2009-07-13/08:56:20.8600 2009-07-13/08:56:20.9400
;;   2009-07-13/08:56:22.3500 2009-07-13/08:56:22.4500
;;   2009-07-13/08:56:23.7900 2009-07-13/08:56:23.9800
;;   2009-07-13/08:56:24.5700 2009-07-13/08:56:24.6600
;;   2009-07-13/08:56:25.3200 2009-07-13/08:56:25.4400
;;   2009-07-13/08:56:26.8300 2009-07-13/08:56:26.8800
;;   2009-07-13/08:56:28.2800 2009-07-13/08:56:28.3700
;;   2009-07-13/08:56:29.7800 2009-07-13/08:56:29.8600
;;   2009-07-13/08:56:31.2700 2009-07-13/08:56:31.3500
;;   2009-07-13/08:56:32.7300 2009-07-13/08:56:32.8600
;;   2009-07-13/08:56:34.2300 2009-07-13/08:56:34.3200
;;   2009-07-13/08:56:35.6600 2009-07-13/08:56:35.8100
;;   2009-07-13/08:56:37.2000 2009-07-13/08:56:37.3200
;;   2009-07-13/08:56:38.6400 2009-07-13/08:56:38.7600
;;   2009-07-13/08:56:40.1300 2009-07-13/08:56:40.2700
;;   2009-07-13/08:56:41.6400 2009-07-13/08:56:41.7300
;;   2009-07-13/08:56:43.1200 2009-07-13/08:56:43.2100
;;   2009-07-13/08:56:42.3900 2009-07-13/08:56:42.4700
;;   2009-07-13/08:56:44.5700 2009-07-13/08:56:44.6800
;;   2009-07-13/08:56:46.1000 2009-07-13/08:56:46.1700
;;   2009-07-13/08:56:47.5900 2009-07-13/08:56:47.6800
;;   2009-07-13/08:56:49.0400 2009-07-13/08:56:49.1900
;;   2009-07-13/08:56:50.5300 2009-07-13/08:56:50.7000
;;   2009-07-13/08:56:52.0400 2009-07-13/08:56:52.2800
;;   2009-07-13/08:56:53.4700 2009-07-13/08:56:53.6400
;;   2009-07-13/08:56:54.9800 2009-07-13/08:56:55.1500
;;   2009-07-13/08:56:56.4000 2009-07-13/08:56:56.6200
;;   2009-07-13/08:56:57.9400 2009-07-13/08:56:58.0900
;;   2009-07-13/08:56:59.4500 2009-07-13/08:56:59.5500
;;   2009-07-13/08:57:00.9400 2009-07-13/08:57:01.0400
;;   2009-07-13/08:57:02.3800 2009-07-13/08:57:02.6000
;;   2009-07-13/08:57:03.9000 2009-07-13/08:57:04.0000
;;   2009-07-13/08:57:05.3400 2009-07-13/08:57:05.5100
;;   2009-07-13/08:57:06.8500 2009-07-13/08:57:07.0000
;;   2009-07-13/08:57:08.3200 2009-07-13/08:57:08.4700
;;   2009-07-13/08:57:09.8100 2009-07-13/08:57:09.9600
;;   2009-07-13/08:57:11.2800 2009-07-13/08:57:11.4300
;;   2009-07-13/08:57:12.7700 2009-07-13/08:57:12.9000
;;   2009-07-13/08:57:14.2600 2009-07-13/08:57:14.4300
;;   2009-07-13/08:56:52.6200 2009-07-13/08:56:52.7100
;;   2009-07-13/08:57:09.0700 2009-07-13/08:57:09.2000
;;   2009-07-13/08:57:15.7200 2009-07-13/08:57:15.8900
;;   2009-07-13/08:57:17.2200 2009-07-13/08:57:17.3600
;;   2009-07-13/08:57:18.6900 2009-07-13/08:57:18.8600
;;   2009-07-13/08:57:20.2000 2009-07-13/08:57:20.3300
;;   2009-07-13/08:57:21.7000 2009-07-13/08:57:21.8000
;;   2009-07-13/08:57:23.1700 2009-07-13/08:57:23.3100
;;   2009-07-13/08:57:24.6100 2009-07-13/08:57:24.8800
;;   2009-07-13/08:57:26.0800 2009-07-13/08:57:26.2800
;;   2009-07-13/08:57:27.6500 2009-07-13/08:57:27.7500
;;   2009-07-13/08:57:29.0900 2009-07-13/08:57:29.2900
;;   2009-07-13/08:57:30.6200 2009-07-13/08:57:30.7900
;;   2009-07-13/08:57:32.0300 2009-07-13/08:57:32.2300
;;   2009-07-13/08:57:33.5700 2009-07-13/08:57:33.6700
;;   2009-07-13/08:57:35.0400 2009-07-13/08:57:35.1700
;;   2009-07-13/08:57:36.5100 2009-07-13/08:57:36.7100
;;   2009-07-13/08:57:38.0100 2009-07-13/08:57:38.1100
;;   2009-07-13/08:57:39.4500 2009-07-13/08:57:39.6500
;;   2009-07-13/08:57:40.9500 2009-07-13/08:57:41.1500
;;   2009-07-13/08:57:42.4600 2009-07-13/08:57:42.5900
;;   2009-07-13/08:57:43.7900 2009-07-13/08:57:44.0900
;;   2009-07-13/08:57:45.4000 2009-07-13/08:57:45.6300
;;   2009-07-13/08:57:46.9000 2009-07-13/08:57:47.1000
;;   2009-07-13/08:57:48.4000 2009-07-13/08:57:48.5000
;;   2009-07-13/08:57:49.7700 2009-07-13/08:57:50.0700
;;   2009-07-13/08:57:51.3400 2009-07-13/08:57:51.4800
;;   2009-07-13/08:57:52.8500 2009-07-13/08:57:52.9800
;;   2009-07-13/08:57:54.2500 2009-07-13/08:57:54.6200
;;   2009-07-13/08:57:55.7900 2009-07-13/08:57:55.9900
;;   2009-07-13/08:57:57.2300 2009-07-13/08:57:57.5600
;;   2009-07-13/08:57:58.7600 2009-07-13/08:57:58.9000
;;   2009-07-13/08:58:00.2900 2009-07-13/08:58:00.3800
;;   2009-07-13/08:58:01.7100 2009-07-13/08:58:01.9000
;;   2009-07-13/08:58:03.2300 2009-07-13/08:58:03.3800
;;   2009-07-13/08:58:04.7100 2009-07-13/08:58:04.8800
;;   2009-07-13/08:58:06.2300 2009-07-13/08:58:06.3600
;;   2009-07-13/08:58:07.7100 2009-07-13/08:58:07.8100
;;   2009-07-13/08:58:09.1800 2009-07-13/08:58:09.2900
;;   2009-07-13/08:58:10.6600 2009-07-13/08:58:10.7700
;;   2009-07-13/08:58:12.1400 2009-07-13/08:58:12.2700
;;   2009-07-13/08:58:13.6200 2009-07-13/08:58:13.7500
;;   2009-07-13/08:58:15.1000 2009-07-13/08:58:15.2500
;;   2009-07-13/08:58:16.6000 2009-07-13/08:58:16.7000
;;   2009-07-13/08:58:18.1000 2009-07-13/08:58:18.2000
;;   2009-07-13/08:58:19.5700 2009-07-13/08:58:19.6800
;;   2009-07-13/08:58:21.0700 2009-07-13/08:58:21.2500
;;   2009-07-13/08:58:22.5300 2009-07-13/08:58:22.7000
;;   2009-07-13/08:58:24.0300 2009-07-13/08:58:24.1600
;;   2009-07-13/08:58:25.5100 2009-07-13/08:58:25.6600
;;   2009-07-13/08:58:26.9600 2009-07-13/08:58:27.1400
;;   2009-07-13/08:58:28.4800 2009-07-13/08:58:28.5900
;;   2009-07-13/08:58:29.9600 2009-07-13/08:58:30.0700
;;   2009-07-13/08:58:31.3800 2009-07-13/08:58:31.5900
;;   2009-07-13/08:58:32.9200 2009-07-13/08:58:33.0700
;;   2009-07-13/08:58:34.4000 2009-07-13/08:58:34.5100
;;   2009-07-13/08:58:35.8800 2009-07-13/08:58:35.9900
;;   2009-07-13/08:58:37.3600 2009-07-13/08:58:37.4700
;;   2009-07-13/08:58:38.8400 2009-07-13/08:58:38.9700
;;   2009-07-13/08:58:40.3400 2009-07-13/08:58:40.4300
;;   2009-07-13/08:58:41.8300 2009-07-13/08:58:41.9800
;;   2009-07-13/08:58:43.2800 2009-07-13/08:58:43.4400
;;   2009-07-13/08:58:44.7600 2009-07-13/08:58:44.9600
;;   2009-07-13/08:58:46.2200 2009-07-13/08:58:46.4400
;;   2009-07-13/08:58:47.7300 2009-07-13/08:58:47.8800
;;   2009-07-13/08:58:49.2500 2009-07-13/08:58:49.3400
;;   2009-07-13/08:58:50.7500 2009-07-13/08:58:50.8600
;;   2009-07-13/08:58:52.1900 2009-07-13/08:58:52.4500
;;   2009-07-13/08:58:53.6500 2009-07-13/08:58:53.8700
;;   2009-07-13/08:58:55.1900 2009-07-13/08:58:55.3500
;;   2009-07-13/08:58:56.6100 2009-07-13/08:58:56.8100
;;   2009-07-13/08:58:58.0200 2009-07-13/08:58:58.3100
;;   2009-07-13/08:58:59.6400 2009-07-13/08:58:59.7900
;;   2009-07-13/08:59:01.1400 2009-07-13/08:59:01.2300
;;   2009-07-13/08:59:02.5800 2009-07-13/08:59:02.7500
;;   2009-07-13/08:59:03.9700 2009-07-13/08:59:04.2500
;;   2009-07-13/08:59:05.5600 2009-07-13/08:59:05.7500
;;   2009-07-13/08:59:07.0300 2009-07-13/08:59:07.1500
;;   2009-07-13/08:59:08.5300 2009-07-13/08:59:08.6700
;;   2009-07-13/08:59:09.9900 2009-07-13/08:59:10.1500
;;   2009-07-13/08:59:11.5300 2009-07-13/08:59:11.6000
;;   2009-07-13/08:59:13.0100 2009-07-13/08:59:13.0800
;;   2009-07-13/08:59:14.4900 2009-07-13/08:59:14.6500
;;   2009-07-13/08:59:15.9700 2009-07-13/08:59:16.0600
;;   2009-07-13/08:59:17.4600 2009-07-13/08:59:17.5800
;;   2009-07-13/08:59:18.9600 2009-07-13/08:59:19.0100
;;   2009-07-13/08:59:20.4400 2009-07-13/08:59:20.5100
;;   2009-07-13/08:59:23.3900 2009-07-13/08:59:23.5100
;;   2009-07-13/08:59:24.7800 2009-07-13/08:59:24.9900
;;   2009-07-13/08:59:26.3300 2009-07-13/08:59:26.4700
;;   2009-07-13/08:59:27.8300 2009-07-13/08:59:27.9400
;;   2009-07-13/08:59:29.2300 2009-07-13/08:59:29.4400
;;   2009-07-13/08:59:30.7100 2009-07-13/08:59:31.0500
;;   2009-07-13/08:59:32.3000 2009-07-13/08:59:32.3900
;;   2009-07-13/08:59:21.8700 2009-07-13/08:59:22.0800
;;   2009-07-13/08:59:33.7820 2009-07-13/08:59:33.8500
;;   2009-07-13/08:59:35.2870 2009-07-13/08:59:35.3340
;;   2009-07-13/08:59:36.7580 2009-07-13/08:59:36.8190
;;   2009-07-13/08:59:37.5070 2009-07-13/08:59:37.5880
;;   2009-07-13/08:59:38.2560 2009-07-13/08:59:38.3030
;;   2009-07-13/08:59:39.7340 2009-07-13/08:59:39.7950
;;   2009-07-13/08:59:40.7190 2009-07-13/08:59:40.8000
;;   2009-07-13/08:59:41.5960 2009-07-13/08:59:41.6980
;;   2009-07-13/08:59:42.7100 2009-07-13/08:59:42.8180
;;   2009-07-13/08:59:42.3990 2009-07-13/08:59:42.5010
;;   2009-07-13/08:59:44.9200 2009-07-13/08:59:44.9820
;;   2009-07-13/08:59:45.2490 2009-07-13/08:59:45.3130
;;   2009-07-13/08:59:46.5630 2009-07-13/08:59:46.6270
;;   2009-07-13/08:59:48.0730 2009-07-13/08:59:48.1870
;;   2009-07-13/08:59:48.6480 2009-07-13/08:59:48.6850
;;   2009-07-13/08:59:50.1270 2009-07-13/08:59:50.1810
;;   2009-07-13/08:59:50.8380 2009-07-13/08:59:50.9070
;;   2009-07-13/08:59:51.5800 2009-07-13/08:59:51.6800
;;   2009-07-13/08:59:52.8400 2009-07-13/08:59:53.1700
;;   2009-07-13/08:59:54.5300 2009-07-13/08:59:54.6500
;;   2009-07-13/08:59:55.7600 2009-07-13/08:59:55.8400
;;   2009-07-13/08:59:56.0200 2009-07-13/08:59:56.1600
;;   2009-07-13/08:59:57.4900 2009-07-13/08:59:57.6400
;;   2009-07-13/08:59:58.9900 2009-07-13/08:59:59.1800
;;   2009-07-13/09:00:00.4900 2009-07-13/09:00:00.6000
;;   2009-07-13/09:00:02.0000 2009-07-13/09:00:02.0700
;;   2009-07-13/09:00:03.4300 2009-07-13/09:00:03.5500
;;   2009-07-13/09:00:04.9500 2009-07-13/09:00:05.0700
;;   2009-07-13/09:00:06.4000 2009-07-13/09:00:06.5200
;;   2009-07-13/09:00:07.9200 2009-07-13/09:00:08.0300
;;   2009-07-13/09:00:09.4100 2009-07-13/09:00:09.5100
;;   2009-07-13/09:00:10.8900 2009-07-13/09:00:10.9800
;;   2009-07-13/09:00:12.3300 2009-07-13/09:00:12.5200
;;   2009-07-13/09:00:13.8500 2009-07-13/09:00:13.9400
;;   2009-07-13/09:00:15.3300 2009-07-13/09:00:15.4200
;;   2009-07-13/09:00:01.0000 2009-07-13/09:00:01.0900
;;   2009-07-13/09:00:05.2500 2009-07-13/09:00:05.3500
;;   2009-07-13/09:00:10.3300 2009-07-13/09:00:10.4600
;;   2009-07-13/09:01:42.8900 2009-07-13/09:01:42.9900
;;   2009-07-13/09:01:43.5200 2009-07-13/09:01:43.8400
;;   2009-07-13/09:01:45.8200 2009-07-13/09:01:46.0000
;;   2009-07-13/09:01:47.2800 2009-07-13/09:01:47.4500
;;   2009-07-13/09:01:48.8000 2009-07-13/09:01:48.9400
;;   2009-07-13/09:01:50.2900 2009-07-13/09:01:50.3900
;;   2009-07-13/09:01:51.7700 2009-07-13/09:01:51.9200
;;   2009-07-13/09:01:53.2300 2009-07-13/09:01:53.3700
;;   2009-07-13/09:01:54.7500 2009-07-13/09:01:54.8900
;;   2009-07-13/09:01:56.2000 2009-07-13/09:01:56.3400
;;   2009-07-13/09:01:57.7200 2009-07-13/09:01:57.8600
;;   2009-07-13/09:01:59.1700 2009-07-13/09:01:59.3200
;;   2009-07-13/09:02:00.6600 2009-07-13/09:02:00.8700
;;   2009-07-13/09:02:02.0800 2009-07-13/09:02:02.3300
;;   2009-07-13/09:02:03.6000 2009-07-13/09:02:03.8100
;;   2009-07-13/09:02:05.1200 2009-07-13/09:02:05.2700
;;   2009-07-13/09:02:06.5800 2009-07-13/09:02:06.7900
;;   2009-07-13/09:02:08.0600 2009-07-13/09:02:08.2800
;;   2009-07-13/09:02:09.5100 2009-07-13/09:02:09.7300
;;   2009-07-13/09:02:11.0400 2009-07-13/09:02:11.2500
;;   2009-07-13/09:02:12.4900 2009-07-13/09:02:12.6700
;;   2009-07-13/09:02:13.9800 2009-07-13/09:02:14.2600
;;   2009-07-13/09:02:15.4300 2009-07-13/09:02:15.6800
;;   2009-07-13/09:02:16.9900 2009-07-13/09:02:17.2000
;;   2009-07-13/09:02:18.4700 2009-07-13/09:02:18.6200
;;   2009-07-13/09:02:19.9600 2009-07-13/09:02:20.1000
;;   2009-07-13/09:02:21.4100 2009-07-13/09:02:21.7000
;;   2009-07-13/09:02:22.9000 2009-07-13/09:02:23.0800
;;   2009-07-13/09:02:24.3900 2009-07-13/09:02:24.5600
;;   2009-07-13/09:02:25.8000 2009-07-13/09:02:26.1200
;;   2009-07-13/09:02:27.3600 2009-07-13/09:02:27.5700
;;   2009-07-13/09:02:28.7800 2009-07-13/09:02:29.1700
;;   2009-07-13/09:02:30.3000 2009-07-13/09:02:30.6200
;;   2009-07-13/09:02:31.7500 2009-07-13/09:02:32.1100
;;   2009-07-13/09:02:33.2800 2009-07-13/09:02:33.5200
;;   2009-07-13/09:02:34.3000 2009-07-13/09:02:34.4400
;;   2009-07-13/09:02:34.8000 2009-07-13/09:02:34.9400
;;   2009-07-13/09:02:37.7900 2009-07-13/09:02:37.8800
;;   2009-07-13/09:02:39.3000 2009-07-13/09:02:39.3900
;;   2009-07-13/09:02:40.7600 2009-07-13/09:02:40.8500
;;   2009-07-13/09:02:42.4800 2009-07-13/09:02:42.5500
;;   2009-07-13/09:02:43.9600 2009-07-13/09:02:44.0100
;;   2009-07-13/09:02:45.2300 2009-07-13/09:02:45.3200
;;   2009-07-13/09:02:46.7000 2009-07-13/09:02:46.7800
;;   2009-07-13/09:02:47.6900 2009-07-13/09:02:47.7800
;;   2009-07-13/09:02:48.2000 2009-07-13/09:02:48.2900
;;   2009-07-13/09:02:48.8800 2009-07-13/09:02:49.0900
;;   2009-07-13/09:02:50.2700 2009-07-13/09:02:50.3900
;;   2009-07-13/09:02:51.5800 2009-07-13/09:02:51.7000
;;   2009-07-13/09:02:52.6200 2009-07-13/09:02:52.7200
;;   2009-07-13/09:02:50.5800 2009-07-13/09:02:50.6300
;;   2009-07-13/09:02:53.2070 2009-07-13/09:02:53.2340
;;   2009-07-13/09:02:54.0390 2009-07-13/09:02:54.0900
;;   2009-07-13/09:02:52.9580 2009-07-13/09:02:52.9850
;;   2009-07-13/09:02:54.3720 2009-07-13/09:02:54.4870
;;   2009-07-13/09:02:55.0690 2009-07-13/09:02:55.1830
;;   2009-07-13/09:02:56.0900 2009-07-13/09:02:56.1910
;;   2009-07-13/09:02:59.0500 2009-07-13/09:02:59.1100
;;   2009-07-13/09:02:59.3210 2009-07-13/09:02:59.3940
;;   2009-07-13/09:03:00.6910 2009-07-13/09:03:00.7410
;;   2009-07-13/09:03:01.5690 2009-07-13/09:03:01.6000
;;   2009-07-13/09:03:03.4860 2009-07-13/09:03:03.5610
;;   2009-07-13/09:03:04.4470 2009-07-13/09:03:04.6110
;;   2009-07-13/09:03:05.0950 2009-07-13/09:03:05.1760
;;   2009-07-13/09:03:05.8800 2009-07-13/09:03:06.1000
;;   2009-07-13/09:03:09.4320 2009-07-13/09:03:09.8340
;;   2009-07-13/09:03:10.4500 2009-07-13/09:03:10.5130
;;   2009-07-13/09:03:14.3570 2009-07-13/09:03:14.4350
;;   2009-07-13/09:03:14.5270 2009-07-13/09:03:14.5980
;;   2009-07-13/09:03:15.9830 2009-07-13/09:03:16.0410
;;   2009-07-13/09:03:16.2960 2009-07-13/09:03:16.4530
;;   2009-07-13/09:03:19.2870 2009-07-13/09:03:19.6000
;;   2009-07-13/09:03:22.2460 2009-07-13/09:03:22.4140
;;   2009-07-13/09:03:22.6560 2009-07-13/09:03:22.7990
;;   2009-07-13/09:03:26.6730 2009-07-13/09:03:26.8820
;;   2009-07-13/09:03:27.3590 2009-07-13/09:03:27.5600
;;   2009-07-13/09:03:28.2460 2009-07-13/09:03:28.3460
;;   2009-07-13/09:03:30.3460 2009-07-13/09:03:30.5300
;;   2009-07-13/09:03:31.2270 2009-07-13/09:03:31.3200
;;   2009-07-13/09:03:32.6890 2009-07-13/09:03:32.7960
;;   2009-07-13/09:03:34.1940 2009-07-13/09:03:34.2870
;;   2009-07-13/09:03:37.1460 2009-07-13/09:03:37.2460
;;   2009-07-13/09:03:37.9130 2009-07-13/09:03:37.9630
;;   2009-07-13/09:03:38.6650 2009-07-13/09:03:38.7150
;;   2009-07-13/09:03:40.1340 2009-07-13/09:03:40.2060
;;   2009-07-13/09:17:48.8900 2009-07-13/09:17:49.1500
;;   2009-07-13/09:17:51.8300 2009-07-13/09:17:52.1900
;;   2009-07-13/09:18:00.6400 2009-07-13/09:18:01.1600
;;   2009-07-13/09:18:01.3200 2009-07-13/09:18:01.8700
;;   2009-07-13/09:18:02.2500 2009-07-13/09:18:02.5500
;;   2009-07-13/09:18:00.0000 2009-07-13/09:18:00.3200
;;   2009-07-13/09:17:58.5500 2009-07-13/09:17:58.8000
;;   2009-07-13/09:17:52.6000 2009-07-13/09:17:52.8500
;;   2009-07-13/09:17:54.8200 2009-07-13/09:17:55.0900
;;   2009-07-13/09:17:58.0700 2009-07-13/09:17:58.1400
;;   2009-07-13/09:17:59.3200 2009-07-13/09:17:59.5200
;;   2009-07-13/09:21:22.4700 2009-07-13/09:21:22.9000
;;   2009-07-13/09:21:25.4100 2009-07-13/09:21:25.9000
;;   2009-07-13/09:21:23.3000 2009-07-13/09:21:23.6300
;;   2009-07-13/09:21:28.4800 2009-07-13/09:21:28.7900
;;   2009-07-13/09:21:10.7800 2009-07-13/09:21:10.8600
;;   2009-07-13/09:21:19.6900 2009-07-13/09:21:19.7700
;;   2009-07-13/09:21:21.1800 2009-07-13/09:21:21.2700
;;   2009-07-13/09:21:24.1300 2009-07-13/09:21:24.2300
;;   2009-07-13/09:21:26.3400 2009-07-13/09:21:26.5300
;;   2009-07-13/09:21:27.1100 2009-07-13/09:21:27.1800
;;   2009-07-13/09:21:31.5500 2009-07-13/09:21:31.6500
;;   2009-07-13/09:22:18.8500 2009-07-13/09:22:19.0900
;;   2009-07-13/09:22:20.3400 2009-07-13/09:22:20.7300
;;   2009-07-13/09:22:42.6900 2009-07-13/09:22:42.9500
;;   2009-07-13/09:22:21.9000 2009-07-13/09:22:22.1700
;;   2009-07-13/09:22:15.9400 2009-07-13/09:22:16.3600
;;   2009-07-13/09:22:19.5800 2009-07-13/09:22:20.2400
;;   2009-07-13/09:22:39.7100 2009-07-13/09:22:39.9500
;;   2009-07-13/09:22:15.1400 2009-07-13/09:22:15.4100
;;   2009-07-13/09:22:21.1200 2009-07-13/09:22:21.4600
;;   2009-07-13/09:22:24.9600 2009-07-13/09:22:25.1000
;;   2009-07-13/09:22:26.4400 2009-07-13/09:22:26.6200
;;   2009-07-13/09:23:30.0600 2009-07-13/09:23:30.5800
;;   2009-07-13/09:24:35.2300 2009-07-13/09:24:35.8400
;;   2009-07-13/09:24:36.1100 2009-07-13/09:24:36.4600
;;   2009-07-13/09:24:38.3000 2009-07-13/09:24:38.9100
;;   2009-07-13/09:24:39.0800 2009-07-13/09:24:39.6100








;;  Print out time ranges removed from efw
ntra           = N_TAGS(tra_nk_efw_all)
FOR j=0L, ntra - 1L DO BEGIN           $
  tra_str0 = tra_nk_efw_all.(j)      & $
  nt       = N_TAGS(tra_str0)        & $
  FOR i=0L, nt - 1L DO BEGIN           $
    PRINT,';;  ',time_string(tra_str0.(i),PREC=4)
;;   2009-07-13/08:59:51.6312 2009-07-13/08:59:51.6369
;;   2009-07-13/08:59:52.3739 2009-07-13/08:59:52.3791
;;   2009-07-13/08:59:53.1220 2009-07-13/08:59:53.1292
;;   2009-07-13/08:59:53.8627 2009-07-13/08:59:53.8678
;;   2009-07-13/08:59:54.5985 2009-07-13/08:59:54.6058











