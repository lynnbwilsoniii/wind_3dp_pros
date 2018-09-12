;;----------------------------------------------------------------------------------------
;; => Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;; => Correct initial Rankine-Hugoniot results
;;----------------------------------------------------------------------------------------
crn_str_out    = ';;  NEW Average Shock Terms ['+['1st','2nd','3rd']+' Crossing]'

;;  Load Rankine-Hugoniot initial results
thm_load_bowshock_rhsolns,R_STRUCT=diss_rates
n_cross        = N_TAGS(diss_rates)                  ;;  # of bow shock crossings
jj             = 5L                                  ;;  Indices for 2009-09-26
k              = 0L
bo_up          = diss_rates.(jj[k]).UP.BO            ;;  [N,3]-Element array of upstream B-field vectors [nT]
bo_dn          = diss_rates.(jj[k]).DOWN.BO          ;;  [N,3]-Element array of downstream B-field vectors [nT]
ni_up          = diss_rates.(jj[k]).UP.NI            ;;  [N]-Element array of upstream number densities [cm^(-3)]
ni_dn          = diss_rates.(jj[k]).DOWN.NI          ;;  [N]-Element array of downstream number densities [cm^(-3)]
vsw_up         = diss_rates.(jj[k]).UP.VSW           ;;  [N,3]-Element array of upstream bulk flow velocity vectors [km/s]
vsw_dn         = diss_rates.(jj[k]).DOWN.VSW         ;;  [N,3]-Element array of downstream bulk flow velocity vectors [km/s]
n_vec          = diss_rates.(jj[k]).SHOCK.NVEC[*,0]  ;;  [3]-Element array defining the initial shock normal vector [GSE]
dnvec          = diss_rates.(jj[k]).SHOCK.NVEC[*,1]  ;;  Uncertainty in N_VEC

;;  Find the "correct" solutions by forcing co-planarity
.compile find_coplanarity_from_rhsolns.pro
coplane        = find_coplanarity_from_rhsolns(n_vec,dnvec,bo_up,bo_dn,V_UP=vsw_up,$
                                               N_UP=ni_up,V_DN=vsw_dn,N_DN=ni_dn)
;;  New Shock Parameters
vshn_up        = coplane.SPEEDS.V_SHN_UP[0]
dvshnup        = coplane.SPEEDS.V_SHN_UP[2]
ushn_up        = coplane.SPEEDS.U_SHN_UP[0]
dushnup        = coplane.SPEEDS.U_SHN_UP[2]
ushn_dn        = coplane.SPEEDS.U_SHN_DN[0]
dushndn        = coplane.SPEEDS.U_SHN_DN[2]
gnorm          = coplane.NEW_NVEC
;;  New Avg. upstream/downstream Bo
magf_up        = coplane.BO_AVG_UP
magf_dn        = coplane.BO_AVG_DN
;;  New theta_Bn
bvec_up        = magf_up/NORM(magf_up)
n_dot_Bo       = my_dot_prod(gnorm,bvec_up,/NOM)
angle0         = ACOS(n_dot_Bo)*18d1/!DPI
theta_Bn       = angle0[0] < (18d1 - angle0[0])

;;  Print out new parameters
nf             = 'f15.8'
vecform        = '("[",'+nf[0]+',"d0,",'+nf[0]+',"d0,",'+nf[0]+',"d0]")'
scaform        = '('+nf[0]+',"d0")'
FOR i=0L, 9L DO BEGIN                                                                 $
  IF (i EQ 0) THEN PRINT, crn_str_out[k]                                            & $
  IF (i EQ 0) THEN PRINT, 'vshn_up        = '+STRING(vshn_up[0],FORMAT=scaform[0])  & $
  IF (i EQ 1) THEN PRINT, 'dvshnup        = '+STRING(dvshnup[0],FORMAT=scaform[0])  & $
  IF (i EQ 2) THEN PRINT, 'ushn_up        = '+STRING(ushn_up[0],FORMAT=scaform[0])  & $
  IF (i EQ 3) THEN PRINT, 'dushnup        = '+STRING(dushnup[0],FORMAT=scaform[0])  & $
  IF (i EQ 4) THEN PRINT, 'ushn_dn        = '+STRING(ushn_dn[0],FORMAT=scaform[0])  & $
  IF (i EQ 5) THEN PRINT, 'dushndn        = '+STRING(dushndn[0],FORMAT=scaform[0])  & $
  IF (i EQ 6) THEN PRINT, 'gnorm          = '+STRING(gnorm,FORMAT=vecform[0])       & $
  IF (i EQ 7) THEN PRINT, 'magf_up        = '+STRING(magf_up,FORMAT=vecform[0])     & $
  IF (i EQ 8) THEN PRINT, 'magf_dn        = '+STRING(magf_dn,FORMAT=vecform[0])     & $
  IF (i EQ 9) THEN PRINT, 'theta_Bn       = '+STRING(theta_Bn[0],FORMAT=scaform[0])

;;  NEW Average Shock Terms [1st Crossing]
vshn_up        =     29.30846018d0
dvshnup        =      7.55206074d0
ushn_up        =   -339.45568562d0
dushnup        =      0.15896800d0
ushn_dn        =    -84.80839576d0
dushndn        =      3.97398740d0
gnorm          = [     0.99876535d0,    -0.03063744d0,    -0.03910405d0]
magf_up        = [     2.23681456d0,     0.21691634d0,    -2.02624458d0]
magf_dn        = [     5.41577923d0,    -7.90257120d0,    13.88976979d0]
theta_Bn       =     40.33263596d0


;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_a_data_2009-09-26_batch.pro






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
kill_data_tr,NAMES=efp_names[0]

;; => Remove "spikes" by hand
coord_in       = 'dsl'
scw_names      = tnames(pref[0]+'scw_cal_'+coord_in[0]+'*')
efw_names      = tnames(pref[0]+'efw_cal_'+coord_in[0]+'*')
all_fields     = [scw_names,efw_names]
names          = [fgmnm,all_fields]
tplot,names

.compile kill_data_tr
kill_data_tr,NAMES=efw_names[0]

;; => Specify # of "spikes" to remove by hand each time and save time ranges
kill_tags      = 'T_'+STRING(LINDGEN(50),FORMAT='(I3.3)')
jj             = 0L
nk             = 2L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 17L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 14L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 33L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 34L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 35L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 28L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 34L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 5L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 19L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 18L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 3L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 22L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 21L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efp_names[0],NKILL=nk,TRA_KILLED=tra_nk_efp_0
str_element,tra_nk_efp_all,kill_tags[jj],tra_nk_efp_0,/ADD_REPLACE
;;  Print out time ranges removed from efp
ntra           = N_TAGS(tra_nk_efp_all)
FOR j=0L, ntra - 1L DO BEGIN           $
  tra_str0 = tra_nk_efp_all.(j)      & $
  nt       = N_TAGS(tra_str0)        & $
  FOR i=0L, nt - 1L DO BEGIN           $
    PRINT,';;  ',time_string(tra_str0.(i),PREC=4)


tr_ww          = time_double(tdate[0]+'/'+['15:53:02.000','15:53:15.700'])

jj             = 0L
nk             = 2L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 2L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 2L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
kill_data_tr,NAMES=efw_names[0],NKILL=nk,TRA_KILLED=tra_nk_efw_0
str_element,tra_nk_efw_all,kill_tags[jj],tra_nk_efw_0,/ADD_REPLACE
nk             = 1L & jj += 1L
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
;;        50457      104448       40790      205201

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
;;        50367      208896


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
t_ramp         = time_double(tdate[0]+'/15:53:09.921')
;;  Shock Parameters
;vshn_up        =   26.234590d0
;ushn_up        = -335.993240d0
;ushn_dn        =  -83.998692d0
;gnorm          = [0.95576882d0,-0.18012919d0,-0.14100009d0]  ;; GSE
theta_Bn       =   51.464211d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-307.345d0,65.0927d0,30.3775d0]
vswi_dn        = [-54.9544d0,43.4793d0,-18.3793d0]
;magf_up        = [1.54738d0,-0.185112d0,-2.65947d0]
;magf_dn        = [-1.69473d0,-14.2039d0,1.26029d0]
dens_up        =    9.66698d0
dens_dn        =   40.5643d0
Ti___up        =   17.52810d0
Ti___dn        =  145.3160d0
Te___up        =    7.87657d0
Te___dn        =   31.0342d0

;;  NEW Average Shock Terms [1st Crossing]
vshn_up        =     29.30846018d0
dvshnup        =      7.55206074d0
ushn_up        =   -339.45568562d0
dushnup        =      0.15896800d0
ushn_dn        =    -84.80839576d0
dushndn        =      3.97398740d0
gnorm          = [     0.99876535d0,    -0.03063744d0,    -0.03910405d0]
magf_up        = [     2.23681456d0,     0.21691634d0,    -2.02624458d0]
magf_dn        = [     5.41577923d0,    -7.90257120d0,    13.88976979d0]
;theta_Bn       =     40.33263596d0


;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_in       = 'gse'
vsw_tpnm       = tnames(pref[0]+coord_in[0]+'_Velocity_peib_no_GIs_UV_2')
tramp          = t_ramp[0]
nsm            = 10L
nif_suffx      = '-RHS01'
;;  do NOT need to remove them by hand and then rename SCW and S b/c they have different
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
;bind           = [3,4]
;del_data,tnames('*_scw_cal_*'+isuffx[bind])
;del_data,tnames('*_efw_cal_corrected_DownSampled_*'+isuffx[bind])
;del_data,tnames('*_S__TimeSeries_*'+isuffx[bind])
;bind           = [3,4,5]
;del_data,tnames('*_efw_cal_gse'+isuffx[bind])
;del_data,tnames('*_efw_cal_corrected_gse'+isuffx[bind])
;store_data,'thc_efw_cal_gse_INT006',NEWNAME='thc_efw_cal_gse_INT005'
;store_data,'thc_efw_cal_gse_INT007',NEWNAME='thc_efw_cal_gse_INT006'
;store_data,'thc_efw_cal_corrected_gse_INT006',NEWNAME='thc_efw_cal_corrected_gse_INT005'
;store_data,'thc_efw_cal_corrected_gse_INT007',NEWNAME='thc_efw_cal_corrected_gse_INT006'
gind           = [0L,1L]
.c

options,tnames(),'LABFLAG',2,/DEF

;;----------------------------------------------------------------------------------------
;; => Print values to ASCII file
;;----------------------------------------------------------------------------------------
nsm            = 10L
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = time_double(tdate[0]+'/15:53:09.921')
gint           = [0L]
fsuffx         = '_1st-BS-Crossing-0'
magf_up        = [     2.23681456d0,     0.21691634d0,    -2.02624458d0]
;magf_up        = [1.54738d0,-0.185112d0,-2.65947d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],$
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,   $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0])

nsm            = 10L
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = time_double(tdate[0]+'/15:53:09.921')
gint           = [1L]
fsuffx         = '_1st-BS-Crossing'
magf_up        = [     2.23681456d0,     0.21691634d0,    -2.02624458d0]
;magf_up        = [1.54738d0,-0.185112d0,-2.65947d0]
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




















































































;;-----------------------------------------------------------
;;  Save corrected fields
;;-----------------------------------------------------------
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
;;   2009-09-26/15:53:02.9271 2009-09-26/15:53:02.9588
;;   2009-09-26/15:53:03.0979 2009-09-26/15:53:03.1230
;;   2009-09-26/15:48:18.6200 2009-09-26/15:48:18.8800
;;   2009-09-26/15:48:19.9700 2009-09-26/15:48:20.4900
;;   2009-09-26/15:48:21.5900 2009-09-26/15:48:21.8900
;;   2009-09-26/15:48:22.9900 2009-09-26/15:48:23.5700
;;   2009-09-26/15:48:24.6400 2009-09-26/15:48:24.9200
;;   2009-09-26/15:48:26.0100 2009-09-26/15:48:26.6000
;;   2009-09-26/15:48:27.6700 2009-09-26/15:48:27.9700
;;   2009-09-26/15:48:29.1000 2009-09-26/15:48:29.5700
;;   2009-09-26/15:48:30.7500 2009-09-26/15:48:30.9500
;;   2009-09-26/15:48:32.1400 2009-09-26/15:48:32.5800
;;   2009-09-26/15:48:33.7800 2009-09-26/15:48:34.0100
;;   2009-09-26/15:48:35.1900 2009-09-26/15:48:35.6500
;;   2009-09-26/15:48:36.7700 2009-09-26/15:48:37.0600
;;   2009-09-26/15:48:38.2000 2009-09-26/15:48:38.6400
;;   2009-09-26/15:48:39.8700 2009-09-26/15:48:40.0300
;;   2009-09-26/15:48:41.2500 2009-09-26/15:48:41.6900
;;   2009-09-26/15:48:42.9200 2009-09-26/15:48:43.0100
;;   2009-09-26/15:48:44.3100 2009-09-26/15:48:44.6600
;;   2009-09-26/15:48:45.9500 2009-09-26/15:48:46.0500
;;   2009-09-26/15:48:47.3300 2009-09-26/15:48:47.7000
;;   2009-09-26/15:48:48.9800 2009-09-26/15:48:49.0900
;;   2009-09-26/15:48:50.3100 2009-09-26/15:48:50.8000
;;   2009-09-26/15:48:52.0000 2009-09-26/15:48:52.1300
;;   2009-09-26/15:48:53.4200 2009-09-26/15:48:53.7600
;;   2009-09-26/15:48:55.0400 2009-09-26/15:48:55.1400
;;   2009-09-26/15:48:56.4000 2009-09-26/15:48:56.8300
;;   2009-09-26/15:48:58.0600 2009-09-26/15:48:58.2200
;;   2009-09-26/15:48:59.4800 2009-09-26/15:48:59.8100
;;   2009-09-26/15:49:01.1200 2009-09-26/15:49:01.1900
;;   2009-09-26/15:49:02.4800 2009-09-26/15:49:02.8800
;;   2009-09-26/15:49:04.1100 2009-09-26/15:49:04.2700
;;   2009-09-26/15:49:05.4800 2009-09-26/15:49:05.9100
;;   2009-09-26/15:49:07.1500 2009-09-26/15:49:07.3100
;;   2009-09-26/15:49:08.5200 2009-09-26/15:49:08.9400
;;   2009-09-26/15:49:10.2200 2009-09-26/15:49:10.3100
;;   2009-09-26/15:49:11.6200 2009-09-26/15:49:11.9100
;;   2009-09-26/15:49:13.2500 2009-09-26/15:49:13.3200
;;   2009-09-26/15:49:14.6200 2009-09-26/15:49:14.9500
;;   2009-09-26/15:49:16.2600 2009-09-26/15:49:16.3900
;;   2009-09-26/15:49:17.5600 2009-09-26/15:49:18.0800
;;   2009-09-26/15:49:19.2900 2009-09-26/15:49:19.4200
;;   2009-09-26/15:49:20.6300 2009-09-26/15:49:21.1200
;;   2009-09-26/15:49:22.3000 2009-09-26/15:49:22.4600
;;   2009-09-26/15:49:23.6700 2009-09-26/15:49:24.1200
;;   2009-09-26/15:49:25.3600 2009-09-26/15:49:25.4600
;;   2009-09-26/15:49:26.7400 2009-09-26/15:49:27.0900
;;   2009-09-26/15:49:28.4000 2009-09-26/15:49:28.5000
;;   2009-09-26/15:49:29.8000 2009-09-26/15:49:30.1300
;;   2009-09-26/15:49:31.4400 2009-09-26/15:49:31.5000
;;   2009-09-26/15:49:32.8700 2009-09-26/15:49:33.1000
;;   2009-09-26/15:49:34.4700 2009-09-26/15:49:34.5400
;;   2009-09-26/15:49:35.9700 2009-09-26/15:49:36.1400
;;   2009-09-26/15:49:37.5100 2009-09-26/15:49:37.6100
;;   2009-09-26/15:49:39.0100 2009-09-26/15:49:39.1400
;;   2009-09-26/15:49:40.5100 2009-09-26/15:49:40.6400
;;   2009-09-26/15:49:41.9500 2009-09-26/15:49:42.2100
;;   2009-09-26/15:49:43.5500 2009-09-26/15:49:43.6500
;;   2009-09-26/15:49:45.0500 2009-09-26/15:49:45.2500
;;   2009-09-26/15:49:46.5900 2009-09-26/15:49:46.6800
;;   2009-09-26/15:49:48.0200 2009-09-26/15:49:48.3200
;;   2009-09-26/15:49:49.5900 2009-09-26/15:49:49.7500
;;   2009-09-26/15:49:51.0900 2009-09-26/15:49:51.2900
;;   2009-09-26/15:49:52.6600 2009-09-26/15:49:52.7600
;;   2009-09-26/15:49:54.0900 2009-09-26/15:49:54.3200
;;   2009-09-26/15:49:55.6800 2009-09-26/15:49:55.7800
;;   2009-09-26/15:49:57.1500 2009-09-26/15:49:57.3900
;;   2009-09-26/15:49:58.7200 2009-09-26/15:49:58.7900
;;   2009-09-26/15:50:00.1600 2009-09-26/15:50:00.4300
;;   2009-09-26/15:50:01.7300 2009-09-26/15:50:01.8300
;;   2009-09-26/15:50:03.1700 2009-09-26/15:50:03.4700
;;   2009-09-26/15:50:04.7700 2009-09-26/15:50:04.8800
;;   2009-09-26/15:50:06.1700 2009-09-26/15:50:06.5200
;;   2009-09-26/15:50:07.8200 2009-09-26/15:50:07.9200
;;   2009-09-26/15:50:09.2500 2009-09-26/15:50:09.5200
;;   2009-09-26/15:50:10.8200 2009-09-26/15:50:10.9600
;;   2009-09-26/15:50:12.2900 2009-09-26/15:50:12.5300
;;   2009-09-26/15:50:13.8700 2009-09-26/15:50:13.9700
;;   2009-09-26/15:50:15.3400 2009-09-26/15:50:15.5800
;;   2009-09-26/15:50:16.8800 2009-09-26/15:50:16.9800
;;   2009-09-26/15:50:18.4100 2009-09-26/15:50:18.5200
;;   2009-09-26/15:50:19.9200 2009-09-26/15:50:20.0200
;;   2009-09-26/15:50:21.3200 2009-09-26/15:50:21.7300
;;   2009-09-26/15:50:22.9600 2009-09-26/15:50:23.0600
;;   2009-09-26/15:50:24.3300 2009-09-26/15:50:24.7700
;;   2009-09-26/15:50:26.0000 2009-09-26/15:50:26.1100
;;   2009-09-26/15:50:27.3400 2009-09-26/15:50:27.7800
;;   2009-09-26/15:50:29.0100 2009-09-26/15:50:29.1500
;;   2009-09-26/15:50:30.3800 2009-09-26/15:50:30.7900
;;   2009-09-26/15:50:32.0600 2009-09-26/15:50:32.1600
;;   2009-09-26/15:50:33.4200 2009-09-26/15:50:33.8300
;;   2009-09-26/15:50:35.1000 2009-09-26/15:50:35.2000
;;   2009-09-26/15:50:36.4700 2009-09-26/15:50:36.8400
;;   2009-09-26/15:50:38.1100 2009-09-26/15:50:38.2400
;;   2009-09-26/15:50:39.5400 2009-09-26/15:50:39.8500
;;   2009-09-26/15:50:41.1500 2009-09-26/15:50:41.2500
;;   2009-09-26/15:50:42.5500 2009-09-26/15:50:42.8900
;;   2009-09-26/15:50:44.1900 2009-09-26/15:50:44.3000
;;   2009-09-26/15:50:45.5600 2009-09-26/15:50:45.9400
;;   2009-09-26/15:50:47.2400 2009-09-26/15:50:47.3000
;;   2009-09-26/15:50:48.6200 2009-09-26/15:50:48.9700
;;   2009-09-26/15:50:50.2500 2009-09-26/15:50:50.3600
;;   2009-09-26/15:50:51.6800 2009-09-26/15:50:51.9600
;;   2009-09-26/15:50:53.2700 2009-09-26/15:50:53.3800
;;   2009-09-26/15:50:54.7300 2009-09-26/15:50:54.9700
;;   2009-09-26/15:50:56.3300 2009-09-26/15:50:56.4000
;;   2009-09-26/15:50:57.7900 2009-09-26/15:50:58.0300
;;   2009-09-26/15:50:59.3500 2009-09-26/15:50:59.4500
;;   2009-09-26/15:51:00.8400 2009-09-26/15:51:01.0500
;;   2009-09-26/15:51:02.3700 2009-09-26/15:51:02.4700
;;   2009-09-26/15:51:03.7500 2009-09-26/15:51:04.1000
;;   2009-09-26/15:51:05.4200 2009-09-26/15:51:05.5200
;;   2009-09-26/15:51:06.8100 2009-09-26/15:51:07.1600
;;   2009-09-26/15:51:08.4400 2009-09-26/15:51:08.5400
;;   2009-09-26/15:51:09.7900 2009-09-26/15:51:10.2100
;;   2009-09-26/15:51:11.4600 2009-09-26/15:51:11.5600
;;   2009-09-26/15:51:12.8500 2009-09-26/15:51:13.1900
;;   2009-09-26/15:51:14.5100 2009-09-26/15:51:14.6200
;;   2009-09-26/15:51:15.8700 2009-09-26/15:51:16.2500
;;   2009-09-26/15:51:17.5300 2009-09-26/15:51:17.6400
;;   2009-09-26/15:51:18.9200 2009-09-26/15:51:19.3000
;;   2009-09-26/15:51:20.5500 2009-09-26/15:51:20.6900
;;   2009-09-26/15:51:21.9400 2009-09-26/15:51:22.3200
;;   2009-09-26/15:51:23.6100 2009-09-26/15:51:23.7100
;;   2009-09-26/15:51:24.9900 2009-09-26/15:51:25.3400
;;   2009-09-26/15:51:26.6200 2009-09-26/15:51:26.7600
;;   2009-09-26/15:51:28.0100 2009-09-26/15:51:28.3900
;;   2009-09-26/15:51:29.6800 2009-09-26/15:51:29.7800
;;   2009-09-26/15:51:31.0000 2009-09-26/15:51:31.4500
;;   2009-09-26/15:51:32.6600 2009-09-26/15:51:32.8000
;;   2009-09-26/15:51:34.0900 2009-09-26/15:51:34.4300
;;   2009-09-26/15:51:35.7200 2009-09-26/15:51:35.8200
;;   2009-09-26/15:51:37.0400 2009-09-26/15:51:37.5600
;;   2009-09-26/15:51:38.7400 2009-09-26/15:51:38.9100
;;   2009-09-26/15:51:13.1200 2009-09-26/15:51:13.2600
;;   2009-09-26/15:51:40.1700 2009-09-26/15:51:40.5200
;;   2009-09-26/15:51:41.7400 2009-09-26/15:51:41.9400
;;   2009-09-26/15:51:43.1300 2009-09-26/15:51:43.6000
;;   2009-09-26/15:51:44.7700 2009-09-26/15:51:44.9900
;;   2009-09-26/15:51:46.1900 2009-09-26/15:51:46.5900
;;   2009-09-26/15:51:47.8500 2009-09-26/15:51:47.9800
;;   2009-09-26/15:51:49.2000 2009-09-26/15:51:49.6200
;;   2009-09-26/15:51:50.8400 2009-09-26/15:51:51.0400
;;   2009-09-26/15:51:52.2100 2009-09-26/15:51:52.7000
;;   2009-09-26/15:51:53.8500 2009-09-26/15:51:54.1000
;;   2009-09-26/15:51:55.2400 2009-09-26/15:51:55.7400
;;   2009-09-26/15:51:56.9600 2009-09-26/15:51:57.0600
;;   2009-09-26/15:51:58.3300 2009-09-26/15:51:58.7000
;;   2009-09-26/15:51:59.9900 2009-09-26/15:52:00.0900
;;   2009-09-26/15:52:01.3600 2009-09-26/15:52:01.7300
;;   2009-09-26/15:52:02.9000 2009-09-26/15:52:03.2500
;;   2009-09-26/15:52:04.3200 2009-09-26/15:52:04.8700
;;   2009-09-26/15:52:05.9100 2009-09-26/15:52:06.3800
;;   2009-09-26/15:52:07.2300 2009-09-26/15:52:08.0000
;;   2009-09-26/15:52:08.8700 2009-09-26/15:52:09.4200
;;   2009-09-26/15:52:10.2400 2009-09-26/15:52:11.0100
;;   2009-09-26/15:52:11.3600 2009-09-26/15:52:11.4300
;;   2009-09-26/15:52:11.9100 2009-09-26/15:52:12.4300
;;   2009-09-26/15:52:13.3700 2009-09-26/15:52:13.9700
;;   2009-09-26/15:52:14.3900 2009-09-26/15:52:14.4700
;;   2009-09-26/15:52:14.9400 2009-09-26/15:52:15.5100
;;   2009-09-26/15:52:16.3800 2009-09-26/15:52:17.0300
;;   2009-09-26/15:52:17.4300 2009-09-26/15:52:17.5000
;;   2009-09-26/15:52:18.0000 2009-09-26/15:52:18.4500
;;   2009-09-26/15:52:19.4200 2009-09-26/15:52:20.0700
;;   2009-09-26/15:52:20.4700 2009-09-26/15:52:20.5400
;;   2009-09-26/15:52:20.9900 2009-09-26/15:52:21.5400
;;   2009-09-26/15:52:22.4100 2009-09-26/15:52:23.0800
;;   2009-09-26/15:52:23.4800 2009-09-26/15:52:23.5600
;;   2009-09-26/15:52:24.0300 2009-09-26/15:52:24.5300
;;   2009-09-26/15:52:25.4800 2009-09-26/15:52:26.1000
;;   2009-09-26/15:52:26.5300 2009-09-26/15:52:26.6000
;;   2009-09-26/15:52:27.1000 2009-09-26/15:52:27.5200
;;   2009-09-26/15:52:28.5200 2009-09-26/15:52:29.1400
;;   2009-09-26/15:52:29.5700 2009-09-26/15:52:29.6200
;;   2009-09-26/15:52:30.1700 2009-09-26/15:52:30.5400
;;   2009-09-26/15:52:31.5600 2009-09-26/15:52:32.1600
;;   2009-09-26/15:52:32.5800 2009-09-26/15:52:32.6600
;;   2009-09-26/15:52:33.1600 2009-09-26/15:52:33.6100
;;   2009-09-26/15:52:34.6000 2009-09-26/15:52:35.1500
;;   2009-09-26/15:52:36.2000 2009-09-26/15:52:36.6200
;;   2009-09-26/15:52:37.6200 2009-09-26/15:52:38.2500
;;   2009-09-26/15:52:38.6400 2009-09-26/15:52:38.7400
;;   2009-09-26/15:52:39.2400 2009-09-26/15:52:39.6400
;;   2009-09-26/15:52:40.6600 2009-09-26/15:52:41.2400
;;   2009-09-26/15:52:41.6900 2009-09-26/15:52:41.7600
;;   2009-09-26/15:52:42.1600 2009-09-26/15:52:42.7800
;;   2009-09-26/15:52:43.6100 2009-09-26/15:52:44.3800
;;   2009-09-26/15:52:44.6800 2009-09-26/15:52:44.8000
;;   2009-09-26/15:52:45.2800 2009-09-26/15:52:45.7300
;;   2009-09-26/15:52:46.7700 2009-09-26/15:52:47.2500
;;   2009-09-26/15:52:48.3900 2009-09-26/15:52:48.6700
;;   2009-09-26/15:52:49.8400 2009-09-26/15:52:50.2100
;;   2009-09-26/15:52:51.5400 2009-09-26/15:52:51.6100
;;   2009-09-26/15:52:52.8600 2009-09-26/15:52:53.3100
;;   2009-09-26/15:52:54.5500 2009-09-26/15:52:54.6800
;;   2009-09-26/15:52:44.7800 2009-09-26/15:52:44.8500
;;   2009-09-26/15:52:35.6300 2009-09-26/15:52:35.7000
;;   2009-09-26/15:52:44.6300 2009-09-26/15:52:44.7800
;;   2009-09-26/15:52:46.6700 2009-09-26/15:52:47.3000
;;   2009-09-26/15:52:47.7500 2009-09-26/15:52:47.8200
;;   2009-09-26/15:52:50.7900 2009-09-26/15:52:50.8900
;;   2009-09-26/15:52:55.9400 2009-09-26/15:52:56.2700
;;   2009-09-26/15:52:57.2400 2009-09-26/15:52:58.0800
;;   2009-09-26/15:52:58.6100 2009-09-26/15:52:59.6500
;;   2009-09-26/15:52:59.6100 2009-09-26/15:53:00.0500
;;   2009-09-26/15:53:00.3500 2009-09-26/15:53:01.0500
;;   2009-09-26/15:53:01.7900 2009-09-26/15:53:02.5200
;;   2009-09-26/15:53:03.4200 2009-09-26/15:53:04.0600
;;   2009-09-26/15:53:04.8300 2009-09-26/15:53:05.4300
;;   2009-09-26/15:53:06.5600 2009-09-26/15:53:06.8600
;;   2009-09-26/15:53:07.9700 2009-09-26/15:53:08.4700
;;   2009-09-26/15:53:09.6100 2009-09-26/15:53:09.9700
;;   2009-09-26/15:53:10.9400 2009-09-26/15:53:11.6800
;;   2009-09-26/15:53:12.3800 2009-09-26/15:53:13.0100
;;   2009-09-26/15:53:14.1200 2009-09-26/15:53:14.5500
;;   2009-09-26/15:53:17.1200 2009-09-26/15:53:17.5600
;;   2009-09-26/15:53:18.7000 2009-09-26/15:53:19.0300
;;   2009-09-26/15:53:20.2000 2009-09-26/15:53:20.6700
;;   2009-09-26/15:53:21.7000 2009-09-26/15:53:22.2000
;;   2009-09-26/15:53:23.0100 2009-09-26/15:53:23.6400
;;   2009-09-26/15:53:02.8200 2009-09-26/15:53:03.0900
;;   2009-09-26/15:53:11.9800 2009-09-26/15:53:12.1800
;;   2009-09-26/15:53:15.7900 2009-09-26/15:53:15.8500
;;   2009-09-26/15:53:29.3200 2009-09-26/15:53:29.6200
;;   2009-09-26/15:53:38.4100 2009-09-26/15:53:38.6800
;;   2009-09-26/15:53:35.4000 2009-09-26/15:53:35.6400
;;   2009-09-26/15:53:32.3600 2009-09-26/15:53:32.6300
;;   2009-09-26/15:53:24.8100 2009-09-26/15:53:25.0800
;;   2009-09-26/15:53:26.3500 2009-09-26/15:53:26.5500
;;   2009-09-26/15:53:30.8900 2009-09-26/15:53:31.0900
;;   2009-09-26/15:53:27.8900 2009-09-26/15:53:28.0200
;;   2009-09-26/15:53:33.9700 2009-09-26/15:53:34.0700
;;   2009-09-26/15:53:36.9800 2009-09-26/15:53:37.1400
;;   2009-09-26/15:53:40.0200 2009-09-26/15:53:40.1200
;;   2009-09-26/15:53:41.5200 2009-09-26/15:53:41.6500
;;   2009-09-26/15:53:43.0200 2009-09-26/15:53:43.1600
;;   2009-09-26/15:53:44.5300 2009-09-26/15:53:44.7000
;;   2009-09-26/15:53:46.0700 2009-09-26/15:53:46.2000
;;   2009-09-26/15:53:05.9400 2009-09-26/15:53:05.9900
;;   2009-09-26/15:53:14.0500 2009-09-26/15:53:14.6900
;;   2009-09-26/15:53:18.0700 2009-09-26/15:53:18.1700
;;   2009-09-26/15:53:47.6000 2009-09-26/15:53:47.7100
;;   2009-09-26/15:53:49.1100 2009-09-26/15:53:49.2000
;;   2009-09-26/15:53:50.6200 2009-09-26/15:53:50.7500
;;   2009-09-26/15:53:52.1300 2009-09-26/15:53:52.2600
;;   2009-09-26/15:53:53.6700 2009-09-26/15:53:53.7600
;;   2009-09-26/15:53:55.1800 2009-09-26/15:53:55.2900
;;   2009-09-26/15:53:56.6900 2009-09-26/15:53:56.8000
;;   2009-09-26/15:53:58.2000 2009-09-26/15:53:58.3100
;;   2009-09-26/15:53:59.7200 2009-09-26/15:53:59.8300
;;   2009-09-26/15:54:01.2100 2009-09-26/15:54:01.3400
;;   2009-09-26/15:54:02.7400 2009-09-26/15:54:02.8700
;;   2009-09-26/15:54:04.3000 2009-09-26/15:54:04.3600
;;   2009-09-26/15:54:05.7600 2009-09-26/15:54:05.9000
;;   2009-09-26/15:54:07.3000 2009-09-26/15:54:07.4100
;;   2009-09-26/15:54:08.8100 2009-09-26/15:54:08.9400
;;   2009-09-26/15:54:10.3200 2009-09-26/15:54:10.4500
;;   2009-09-26/15:54:11.8400 2009-09-26/15:54:11.9700
;;   2009-09-26/15:54:13.3700 2009-09-26/15:54:13.5000
;;   2009-09-26/15:54:14.8800 2009-09-26/15:54:14.9900
;;   2009-09-26/15:54:16.3900 2009-09-26/15:54:16.4800
;;   2009-09-26/15:54:17.9300 2009-09-26/15:54:18.0200
;;   2009-09-26/15:54:19.4400 2009-09-26/15:54:19.5300
;;   2009-09-26/15:54:20.9400 2009-09-26/15:54:21.0400
;;   2009-09-26/15:54:22.4600 2009-09-26/15:54:22.5500
;;   2009-09-26/15:54:23.9900 2009-09-26/15:54:24.0700
;;   2009-09-26/15:54:25.4900 2009-09-26/15:54:25.5700
;;   2009-09-26/15:54:27.0200 2009-09-26/15:54:27.1200
;;   2009-09-26/15:54:28.5200 2009-09-26/15:54:28.6000
;;   2009-09-26/15:54:30.0400 2009-09-26/15:54:30.1500
;;   2009-09-26/15:54:31.5500 2009-09-26/15:54:31.6500
;;   2009-09-26/15:54:33.0900 2009-09-26/15:54:33.1800
;;   2009-09-26/15:54:34.5800 2009-09-26/15:54:34.7000
;;   2009-09-26/15:54:36.1000 2009-09-26/15:54:36.2300
;;   2009-09-26/15:54:37.6300 2009-09-26/15:54:37.7100
;;   2009-09-26/15:54:39.1300 2009-09-26/15:54:39.2600
;;   2009-09-26/15:54:40.6300 2009-09-26/15:54:40.7400
;;   2009-09-26/15:54:42.1600 2009-09-26/15:54:42.2800
;;   2009-09-26/15:54:43.6800 2009-09-26/15:54:43.7900
;;   2009-09-26/15:54:45.2100 2009-09-26/15:54:45.3100
;;   2009-09-26/15:54:46.7100 2009-09-26/15:54:46.8200
;;   2009-09-26/15:54:48.2400 2009-09-26/15:54:48.3400
;;   2009-09-26/15:54:49.7200 2009-09-26/15:54:49.8700
;;   2009-09-26/15:54:51.2700 2009-09-26/15:54:51.3900
;;   2009-09-26/15:54:51.9000 2009-09-26/15:58:20.5000




;;  Print out time ranges removed from efw
ntra           = N_TAGS(tra_nk_efw_all)
FOR j=0L, ntra - 1L DO BEGIN           $
  tra_str0 = tra_nk_efw_all.(j)      & $
  nt       = N_TAGS(tra_str0)        & $
  FOR i=0L, nt - 1L DO BEGIN           $
    PRINT,';;  ',time_string(tra_str0.(i),PREC=4)
;;   2009-09-26/15:53:02.9341 2009-09-26/15:53:02.9500
;;   2009-09-26/15:53:03.1098 2009-09-26/15:53:03.1137
;;   2009-09-26/15:53:03.6492 2009-09-26/15:53:03.6550
;;   2009-09-26/15:53:03.6875 2009-09-26/15:53:03.7056
;;   2009-09-26/15:53:05.2072 2009-09-26/15:53:05.2280
;;   2009-09-26/15:53:03.6875 2009-09-26/15:53:03.7056
;;   2009-09-26/15:53:05.9658 2009-09-26/15:53:05.9751
;;   2009-09-26/15:53:03.6875 2009-09-26/15:53:03.7056
;;   2009-09-26/15:53:06.7193 2009-09-26/15:53:06.7414
;;   2009-09-26/15:53:03.6875 2009-09-26/15:53:03.7056
;;   2009-09-26/15:53:08.2388 2009-09-26/15:53:08.2666
;;   2009-09-26/15:53:03.6875 2009-09-26/15:53:03.7056
;;   2009-09-26/15:53:08.9948 2009-09-26/15:53:09.0058
;;   2009-09-26/15:53:03.6875 2009-09-26/15:53:03.7056
;;   2009-09-26/15:53:09.7516 2009-09-26/15:53:09.7657
;;   2009-09-26/15:53:03.6875 2009-09-26/15:53:03.7056
;;   2009-09-26/15:53:11.2705 2009-09-26/15:53:11.2909
;;   2009-09-26/15:53:11.3068 2009-09-26/15:53:11.3105
;;   2009-09-26/15:53:12.0291 2009-09-26/15:53:12.0440
;;   2009-09-26/15:53:12.7824 2009-09-26/15:53:12.8001
;;   2009-09-26/15:53:13.5392 2009-09-26/15:53:13.5449
;;   2009-09-26/15:53:14.3018 2009-09-26/15:53:14.3120
;;   2009-09-26/15:53:15.0608 2009-09-26/15:53:15.0666


