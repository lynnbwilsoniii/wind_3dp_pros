;;----------------------------------------------------------------------------------------
;; => Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;; => Correct initial Rankine-Hugoniot results
;;----------------------------------------------------------------------------------------

;;  NEW Average Shock Terms [1st Crossing]
vshn_up        =    -77.71897065d0
dvshnup        =      4.80469178d0
ushn_up        =   -269.64752023d0
dushnup        =      0.90093028d0
ushn_dn        =    -60.11173950d0
dushndn        =      8.88906398d0
gnorm          = [     0.91986927d0,     0.36689695d0,     0.13866201d0]
magf_up        = [     0.61279484d0,    -0.57618533d0,    -0.29177513d0]
magf_dn        = [     2.96029421d0,    -8.57990003d0,     1.29101706d0]
theta_Bn       =     69.49713994d0

;;  NEW Average Shock Terms [2nd Crossing]
vshn_up        =   -120.42239904d0
dvshnup        =     17.10918890d0
ushn_up        =   -219.90948937d0
dushnup        =      0.55434394d0
ushn_dn        =    -42.80976250d0
dushndn        =     14.02234390d0
gnorm          = [     0.92968239d0,     0.30098043d0,    -0.21237099d0]
magf_up        = [    -1.07332678d0,    -1.06251983d0,    -0.23281553d0]
magf_dn        = [    -2.95333773d0,    -5.69773245d0,    -6.91488147d0]
theta_Bn       =     33.91071437d0

;;  NEW Average Shock Terms [3rd Crossing]
vshn_up        =      0.98265883d0
dvshnup        =     15.08311669d0
ushn_up        =   -357.43730189d0
dushnup        =      0.51836578d0
ushn_dn        =    -63.81670800d0
dushndn        =     12.47117700d0
gnorm          = [     0.93123543d0,     0.29478399d0,     0.21424979d0]
magf_up        = [    -0.27134223d0,    -1.27554421d0,    -0.27749658d0]
magf_dn        = [     0.40841404d0,    -6.53712225d0,    -1.06389594d0]
theta_Bn       =     58.92700155d0
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_c_data_2009-09-05_batch.pro




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
coord_dsl      = 'dsl'
scp_names      = tnames(pref[0]+'scp_cal_'+coord_dsl[0]+'*')
efp_names      = tnames(pref[0]+'efp_cal_'+coord_dsl[0]+'*')
names          = [fgm_mag[1],scp_names,efp_names,efw_names]
tplot,names

kill_data_tr,NAMES=[scp_names[0],efp_names[0]]
kill_data_tr,NAMES=scp_names[0]
kill_data_tr,NAMES=efp_names[0]

;; => Remove "spikes" by hand
coord_dsl      = 'dsl'
scw_names      = tnames(pref[0]+'scw_cal_'+coord_dsl[0]+'*')
efw_names      = tnames(pref[0]+'efw_cal_'+coord_dsl[0]+'*')
names          = [fgm_mag[1],scw_names,efw_names]
tplot,names

kill_data_tr,NAMES=[scw_names[0],efw_names[0]]
kill_data_tr,NAMES=scw_names[0]
kill_data_tr,NAMES=efw_names[0]

nk             = 4L
kill_data_tr,NAMES=efw_names[0],NKILL=nk


;;-------------------------------------
;; => Remove "spikes" in efp data
;;-------------------------------------
get_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
test_efp       = (ABS(temp_efp.Y[*,0]) LT 2d2)
good_efp       = WHERE(test_efp,gdefp,COMPLEMENT=bad_efp,NCOMPLEMENT=bdefp)
PRINT,';; ', gdefp, bdefp
;;       223589      398491

IF (bdefp GT 0) THEN temp_efp.Y[bad_efp,*] = f
IF (gdefp GT 0) THEN store_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp


nk             = 4L
kill_data_tr,NAMES=efp_names[0],NKILL=nk




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
;;       230912      262656      230912      520704


IF (gdscp GT 0) THEN temp_scp = {X:temp_scp.X[good_scp],Y:temp_scp.Y[good_scp,*]} ELSE temp_scp = 0
IF (gdscw GT 0) THEN temp_scw = {X:temp_scw.X[good_scw],Y:temp_scw.Y[good_scw,*]} ELSE temp_scw = 0
IF (gdefp GT 0) THEN temp_efp = {X:temp_efp.X[good_efp],Y:temp_efp.Y[good_efp,*]} ELSE temp_efp = 0
IF (gdefw GT 0) THEN temp_efw = {X:temp_efw.X[good_efw],Y:temp_efw.Y[good_efw,*]} ELSE temp_efw = 0
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
;;-----------------------------------------------------------
;;  Try smoothing without using autoregressive backcasting
;;-----------------------------------------------------------
get_data,efp_names[0]+'_with_spikes',DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
;;  Find intervals
efp__t         = temp_efp.X
efp__v         = temp_efp.Y

test_efp       = (ABS(efp__v[*,0]) LT 25d0)
good_efp       = WHERE(test_efp,gdefp,COMPLEMENT=bad_efp,NCOMPLEMENT=bdefp)
PRINT,';; ', gdefp, bdefp
;;       213331       17581


temp_efp__v    = temp_efp.Y
IF (bdefp GT 0) THEN temp_efp__v[bad_efp,*] = f
IF (gdefp GT 0) THEN temp_efp__v[*,0]       = interp(efp__v[good_efp,0],efp__t[good_efp],efp__t,/NO_EXTRAP)
IF (gdefp GT 0) THEN temp_efp__v[*,1]       = interp(efp__v[good_efp,1],efp__t[good_efp],efp__t,/NO_EXTRAP)
IF (gdefp GT 0) THEN temp_efp__v[*,2]       = interp(efp__v[good_efp,2],efp__t[good_efp],efp__t,/NO_EXTRAP)

interv         = t_interval_find(efp__t,GAP_THRESH=1d0)
HELP, interv
;; INTERV          LONG      = Array[3, 2]

efp__v_i0      = REFORM(temp_efp__v[interv[0,0]:interv[0,1],*])
efp__v_i1      = REFORM(temp_efp__v[interv[1,0]:interv[1,1],*])
efp__v_i2      = REFORM(temp_efp__v[interv[2,0]:interv[2,1],*])

wd             = 128L
efp_vx_i0      = SMOOTH(efp__v_i0[*,0],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vy_i0      = SMOOTH(efp__v_i0[*,1],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vz_i0      = SMOOTH(efp__v_i0[*,2],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vx_i1      = SMOOTH(efp__v_i1[*,0],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vy_i1      = SMOOTH(efp__v_i1[*,1],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vz_i1      = SMOOTH(efp__v_i1[*,2],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vx_i2      = SMOOTH(efp__v_i2[*,0],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vy_i2      = SMOOTH(efp__v_i2[*,1],wd[0],/NAN,/EDGE_TRUNCATE)
efp_vz_i2      = SMOOTH(efp__v_i2[*,2],wd[0],/NAN,/EDGE_TRUNCATE)

efp__vx        = [efp_vx_i0,efp_vx_i1,efp_vx_i2]
efp__vy        = [efp_vy_i0,efp_vy_i1,efp_vy_i2]
efp__vz        = [efp_vz_i0,efp_vz_i1,efp_vz_i2]
efp__v_sm      = [[efp__vx],[efp__vy],[efp__vz]]

temp_efp_sm    = {X:temp_efp.X,Y:efp__v_sm}
sm_str         = STRTRIM(STRING(wd[0],FORMAT='(I4.4)'),2)
tp_suffx       = '_with_spikes_boxcar_sm'+sm_str[0]+'pts'

store_data,efp_names[0]+tp_suffx[0],DATA=temp_efp_sm,DLIM=dlim_efp,LIM=lim_efp

;;  Subtract detrended values from original
del_efp_vx     = efp__v[*,0] - efp__v_sm[*,0]
del_efp_vy     = efp__v[*,1] - efp__v_sm[*,1]
del_efp_vz     = efp__v[*,2] - efp__v_sm[*,2]

del_efp_v      = [[del_efp_vx],[del_efp_vy],[del_efp_vz]]
tp_suffx       = '_subtract_boxcar_sm'+sm_str[0]+'pts'
temp_efp_dt    = {X:efp__t,Y:del_efp_v}
store_data,efp_names[0]+tp_suffx[0],DATA=temp_efp_dt,DLIM=dlim_efp,LIM=lim_efp

;;  Now remove spikes from detrended values
test_efp_dt    = (ABS(del_efp_v[*,0]) LT 25d0) AND (ABS(del_efp_v[*,1]) LT 25d0)
good_efp_dt    = WHERE(test_efp_dt,gdefpdt,COMPLEMENT=bad_efp_dt,NCOMPLEMENT=bdefpdt)
PRINT,';; ', gdefpdt, bdefpdt
;;       214586       16326

interv_bd      = t_interval_find(efp__t[bad_efp_dt],GAP_THRESH=1d-1)
bad_low        = bad_efp_dt[REFORM(interv_bd[*,0])]
bad_hig        = bad_efp_dt[REFORM(interv_bd[*,1])]
;;  Add to end/start points
bad_low        = (bad_low - 6L) > 0
bad_hig        = (bad_hig + 6L) < (N_ELEMENTS(efp__t) - 1L)

tempdt_efp__v  = del_efp_v
;IF (bdefpdt GT 0) THEN tempdt_efp__v[bad_efp_dt,*] = f
FOR j=0L, N_ELEMENTS(bad_low) - 1L DO tempdt_efp__v[bad_low[j]:bad_hig[j],*] = f


tp_suffx       = '_detrend_subtract_boxcar_sm'+sm_str[0]+'pts_no-spikes'
temp_efp_dt_2  = {X:efp__t,Y:tempdt_efp__v}
store_data,efp_names[0]+tp_suffx[0],DATA=temp_efp_dt_2,DLIM=dlim_efp,LIM=lim_efp
;;----------------------------------------------------------------------------------------
;;  Remove detrended fields before moving on
;;----------------------------------------------------------------------------------------
x   = LINDGEN(135 - 131 + 1L) + 131L
PRINT, minmax(x)
nna = tnames(x)
n = N_ELEMENTS(x)
FOR j=0L, n - 1L DO BEGIN $
  get_data,nna[j],data=temp,dlim=dlim,lim=lim  & $
  str_element,struct,nna[j],{DATA:temp,DLIM:dlim,LIM:lim},/ADD_REPLACE

del_data,nna

;fname = pref[0]+'efp_efw_scp_scw_dsl_all.sav'
;SAVE,struct,FILENAME=fname[0]

;mdir           = FILE_EXPAND_PATH('')
;fname = pref[0]+'efp_efw_scp_scw_dsl_all.sav'
;file           = FILE_SEARCH(mdir,fname[0])

;;  Restore detrended fields

;RESTORE,file[0]
tp_names       = STRLOWCASE(TAG_NAMES(struct))
n              = N_ELEMENTS(tp_names)
FOR j=0L, n - 1L DO BEGIN $
  store_data,tp_names[j],DATA=struct.(j).DATA,DLIM=struct.(j).DLIM,LIM=struct.(j).LIM


;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI [1st shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [1st Shock]
t_ramp         = MEAN(time_double(tdate[0]+'/'+['16:11:32.910','16:11:33.800']),/NAN)
;;  NEW Average Shock Terms [1st Crossing]
vshn_up        =    -77.71897065d0
dvshnup        =      4.80469178d0
ushn_up        =   -269.64752023d0
dushnup        =      0.90093028d0
ushn_dn        =    -60.11173950d0
dushndn        =      8.88906398d0
gnorm          = [     0.91986927d0,     0.36689695d0,     0.13866201d0]
theta_Bn       =     69.49713994d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-378.828d0,5.58287d0,-6.79777d0]
vswi_dn        = [-165.168d0,90.3355d0,28.6917d0]
magf_up        = [ 0.61279484d0,-0.57618533d0,-0.29177513d0]
magf_dn        = [ 2.96029421d0,-8.57990003d0, 1.29101706d0]
;;  Avg. upstream/downstream density and temperatures
dens_up        = 2.61508d0
dens_dn        = 18.0038d0
Ti___up        = 8.18439d0
Ti___dn        = 63.5619d0
Te___up        = 13.6383d0
Te___dn        = 40.2853d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_gse      = 'gse'
vsw_tpnm       = tnames(pref[0]+'Velocity_'+coord_gse[0]+'_peib_no_GIs_UV')
tramp          = t_ramp[0]
nsm            = 10L
nif_suffx      = '-RHS01'

;;  need to remove them by hand and then rename SCW and S b/c they have different
;;    # of intervals
;;
;;    Intervals [0L,1L,2L,4L] are good for the following:
;;      *_scw_cal_gse_*
;;
;;    Intervals [0L,1L,2L,5L,8L,9L] are good for the following:
;;      *_efw_cal_gse_*
;;      *_efw_cal_corrected_gse_*
;;
;;    Intervals [0L,1L,3L,5L] are good for the following:
;;      *_scw_cal_HighPass_*
;;      *_efw_cal_corrected_DownSampled_*
;;      *_S__TimeSeries_*
;;


gint           = LINDGEN(15)

.compile themis_clean_cal_efi
.compile temp_calc_j_S_nif_etc
.compile temp_thm_cal_rot_ebfields
temp_thm_cal_rot_ebfields,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,$
                          VSW_TPNM=vsw_tpnm,TRAMP=tramp,NSM=nsm,   $
                          GINT=gint,NIF_SUFFX=nif_suffx[0]

;;  Enter the following by hand at 1st STOP statement in temp_thm_cal_rot_ebfields.pro
coord_gse      = 'gse'
gind0          = [0L,1L,2L,4L]
bind0          = [3L]
scw_n0         = tnames('*_scw_cal_'+coord_gse[0]+'_*')
del_data,scw_n0[bind0]
store_data,scw_n0[gind0[2]],NEWNAME=scpref[0]+'scw_cal_gse_INT003'
store_data,scw_n0[gind0[3]],NEWNAME=scpref[0]+'scw_cal_gse_INT005'

gind1          = [0L,1L,3L,5L]
bind1          = [2L,4L]
bscw_n1        = tnames('*_scw_cal_HighPass_*'+isuffx[bind1])
befw_n1        = tnames('*_efw_cal_corrected_DownSampled_*'+isuffx[bind1])
bExB_n1        = tnames('*_S__TimeSeries_*'+isuffx[bind1])
del_data,bscw_n1
del_data,befw_n1
del_data,bExB_n1

gind2          = [0L,1L,2L,5L,8L,9L]
bind2          = [6L,7L]
bsuffx         = '_INT'+STRING(bind2,FORMAT='(I3.3)')
befw_n2        = tnames('*_efw_cal_'+coord_gse[0]+bsuffx)
befw_n3        = tnames('*_efw_cal_corrected_'+coord_gse[0]+bsuffx)
del_data,befw_n2
del_data,befw_n3
aefw_n2        = tnames('*_efw_cal_'+coord_gse[0]+'_*')
aefw_n3        = tnames('*_efw_cal_corrected_'+coord_gse[0]+'_*')
;;  Combine:   [0 & 1] --> 0
;;                2    --> 1
;;                5    --> 3
;;  Combine:   [8 & 9] --> 5
;;------------------------------------------------
;;      *_efw_cal_gse_*
;;------------------------------------------------
bind3          = [4L,5L]
gsuffx         = '_INT'+STRING(gind1,FORMAT='(I3.3)')
efwcal_name    = aefw_n2
efwcal_new     = scpref[0]+'efw_cal_'+coord_gse[0]+gsuffx
ysubttles      = '[th'+sc[0]+' !9l!X 16384 sps, Int. '+STRING(gind1,FORMAT='(I3.3)')+']'
;;------------------------------------------------
;;      *_efw_cal_corrected_gse_*
;;------------------------------------------------
bind3          = [4L,5L]
gsuffx         = '_INT'+STRING(gind1,FORMAT='(I3.3)')
efwcal_name    = aefw_n3
efwcal_new     = scpref[0]+'efw_cal_corrected_'+coord_gse[0]+gsuffx
ysubttles      = '[th'+sc[0]+' !9l!X 16384 sps, Int. '+STRING(gind1,FORMAT='(I3.3)')+']'

;;  New 0
get_data,efwcal_name[0],DATA=temp0,DLIM=dlim0,LIM=lim0
get_data,efwcal_name[1],DATA=temp1,DLIM=dlim1,LIM=lim1
newdat0        = {X:[temp0.X,temp1.X],Y:[temp0.Y,temp1.Y]}
newdlim0       = dlim0
newlim0        = lim0
str_element,newdlim0,'YSUBTITLE',ysubttles[0],/ADD_REPLACE
;;  New 1
get_data,efwcal_name[2],DATA=temp0,DLIM=dlim0,LIM=lim0
newdat1        = {X:temp0.X,Y:temp0.Y}
newdlim1       = dlim0
newlim1        = lim0
str_element,newdlim1,'YSUBTITLE',ysubttles[1],/ADD_REPLACE
;;  New 3
get_data, efwcal_name[3],DATA=temp0,DLIM=dlim0,LIM=lim0
newdat3        = {X:temp0.X,Y:temp0.Y}
newdlim3       = dlim0
newlim3        = lim0
str_element,newdlim3,'YSUBTITLE',ysubttles[2],/ADD_REPLACE
;;  New 5
get_data,efwcal_name[4],DATA=temp2,DLIM=dlim2,LIM=lim2
get_data,efwcal_name[5],DATA=temp3,DLIM=dlim3,LIM=lim3
newdat5        = {X:[temp2.X,temp3.X],Y:[temp2.Y,temp3.Y]}
newdlim5       = dlim2
newlim5        = lim2
str_element,newdlim5,'YSUBTITLE',ysubttles[3],/ADD_REPLACE
;;  Send New data to TPLOT
store_data,efwcal_name[0],DATA=newdat0,DLIM=newdlim0,LIM=newlim0
store_data,efwcal_name[1],DATA=newdat1,DLIM=newdlim1,LIM=newlim1
store_data,efwcal_name[2],DATA=newdat3,DLIM=newdlim3,LIM=newlim3
store_data,efwcal_name[3],DATA=newdat5,DLIM=newdlim5,LIM=newlim5
;;  Remove old data from TPLOT
del_data,efwcal_name[bind3]
store_data,efwcal_name[0],NEWNAME=efwcal_new[0]
store_data,efwcal_name[1],NEWNAME=efwcal_new[1]
store_data,efwcal_name[2],NEWNAME=efwcal_new[2]
store_data,efwcal_name[3],NEWNAME=efwcal_new[3]

gind           = [0L,1L,3L,5L]
.c

;;  Remove intervals 3 and 5 from 1st crossing
del_data,tnames('*-RHS01*_INT003')
del_data,tnames('*-RHS01*_INT005')

;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI [2nd shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [2nd Shock]
t_ramp         = MEAN(time_double(tdate[0]+'/'+['16:37:58.272','16:37:59.000']),/NAN)
;;  NEW Average Shock Terms [2nd Crossing]
vshn_up        =   -120.42239904d0
dvshnup        =     17.10918890d0
ushn_up        =   -219.90948937d0
dushnup        =      0.55434394d0
ushn_dn        =    -42.80976250d0
dushndn        =     14.02234390d0
gnorm          = [ 0.92968239d0, 0.30098043d0,-0.21237099d0]
theta_Bn       =     33.91071437d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-356.562d0, -31.5722d0, -3.10936d0]
vswi_dn        = [-198.972d0,  29.2785d0, -60.9125d0]
magf_up        = [-1.07332678d0,-1.06251983d0,-0.23281553d0]
magf_dn        = [-2.95333773d0,-5.69773245d0,-6.91488147d0]
;;  Avg. upstream/downstream density and temperatures
dens_up        = 2.65507d0
dens_dn        = 14.1623d0
Ti___up        = 7.46431d0
Ti___dn        = 148.327d0
Te___up        = 11.8844d0
Te___dn        = 30.8271d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_gse      = 'gse'
vsw_tpnm       = tnames(pref[0]+'Velocity_'+coord_gse[0]+'_peib_no_GIs_UV')
tramp          = t_ramp[0]
nsm            = 10L
nif_suffx      = '-RHS02'
gint           = [0L,1L,3L,5L]
;;  Only call 2nd half of program
modes_pw       = ['p','w']
mode_efi       = 'ef'+modes_pw
mode_scm       = 'sc'+modes_pw
efi_name       = tnames(pref[0]+mode_efi[1]+'_cal_corrected_DownSampled_'+coord_gse[0]+'_INT*')
scm_name       = tnames(pref[0]+mode_scm[1]+'_cal_HighPass_'+coord_gse[0]+'_INT*')
get_data,efi_name[0],DATA=efw,DLIM=dlime,LIM=lime
get_data,scm_name[0],DATA=scw,DLIM=dlimb,LIM=limb
smrate         = DOUBLE(ROUND(sample_rate(efw.X,GAP_THRESH=2d0,/AVE)))
smratb         = DOUBLE(ROUND(sample_rate(scw.X,GAP_THRESH=2d0,/AVE)))

.compile temp_calc_j_S_nif_etc
temp_calc_j_S_nif_etc,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,       $
                      VSW_TPNM=vsw_tpnm,TRAMP=tramp[0],NSM=nsm,       $
                      GINT=gint,NIF_SUFFX=nif_suffx,                  $
                      SRATE_E=smrate[0],SRATE_B=smratb[0]

;;  Remove intervals 0, 1, and 5 from 1st crossing
pref_arr       = ['*_efw','*_scw','*_n-dot-S','*_ndotS-n','*_nxSxn']
del_data,tnames(pref_arr+'*-RHS02*_INT000')
del_data,tnames(pref_arr+'*-RHS02*_INT001')
del_data,tnames(pref_arr+'*-RHS02*_INT005')



;;----------------------------------------------------------------------------------------
;; => Calibrate and Rotate SCM and EFI [3rd shock solutions]
;;----------------------------------------------------------------------------------------
;; => Avg. terms [3rd Shock]
t_ramp         = MEAN(time_double(tdate[0]+'/'+['16:54:31.240','16:54:33.120']),/NAN)
;;  NEW Average Shock Terms [3rd Crossing]
vshn_up        =      0.98265883d0
dvshnup        =     15.08311669d0
ushn_up        =   -357.43730189d0
dushnup        =      0.51836578d0
ushn_dn        =    -63.81670800d0
dushndn        =     12.47117700d0
gnorm          = [ 0.93123543d0, 0.29478399d0, 0.21424979d0]
theta_Bn       =     58.92700155d0
;;  Avg. upstream/downstream Vsw and Bo
vswi_up        = [-380.332d0, -7.41865d0, -0.418070d0]
vswi_dn        = [-85.8305d0,  42.2396d0,   21.6701d0]
magf_up        = [-0.27134223d0,-1.27554421d0,-0.27749658d0]
magf_dn        = [ 0.40841404d0,-6.53712225d0,-1.06389594d0]
;;  Avg. upstream/downstream density and temperatures
dens_up        = 2.56415d0
dens_dn        = 15.8713d0
Ti___up        = 7.80712d0
Ti___dn        = 203.460d0
Te___up        = 17.0562d0
Te___dn        = 36.2439d0

;;  Define RH Parameter Structure
tags           = ['NORM','U_SHN','V_SHN','B_UP','B_DN','VSW_UP','VSW_DN','N_UP','N_DN']
nif_str        = CREATE_STRUCT(tags,gnorm,ushn_up,vshn_up,magf_up,magf_dn,vswi_up,vswi_dn,dens_up,dens_dn)

coord_gse      = 'gse'
vsw_tpnm       = tnames(pref[0]+'Velocity_'+coord_gse[0]+'_peib_no_GIs_UV')
tramp          = t_ramp[0]
nsm            = 10L
nif_suffx      = '-RHS03'
gint           = [0L,1L,3L,5L]
;;  Only call 2nd half of program
modes_pw       = ['p','w']
mode_efi       = 'ef'+modes_pw
mode_scm       = 'sc'+modes_pw
efi_name       = tnames(pref[0]+mode_efi[1]+'_cal_corrected_DownSampled_'+coord_gse[0]+'_INT*')
scm_name       = tnames(pref[0]+mode_scm[1]+'_cal_HighPass_'+coord_gse[0]+'_INT*')
get_data,efi_name[0],DATA=efw,DLIM=dlime,LIM=lime
get_data,scm_name[0],DATA=scw,DLIM=dlimb,LIM=limb
smrate         = DOUBLE(ROUND(sample_rate(efw.X,GAP_THRESH=2d0,/AVE)))
smratb         = DOUBLE(ROUND(sample_rate(scw.X,GAP_THRESH=2d0,/AVE)))

.compile temp_calc_j_S_nif_etc
temp_calc_j_S_nif_etc,PROBE=sc[0],TRANGE=tr_jj,NIF_STR=nif_str,       $
                      VSW_TPNM=vsw_tpnm,TRAMP=tramp[0],NSM=nsm,       $
                      GINT=gint,NIF_SUFFX=nif_suffx,                  $
                      SRATE_E=smrate[0],SRATE_B=smratb[0]

;;  Remove intervals 0, 1, and 3 from 1st crossing
pref_arr       = ['*_efw','*_scw','*_n-dot-S','*_ndotS-n','*_nxSxn']
del_data,tnames(pref_arr+'*-RHS03*_INT000')
del_data,tnames(pref_arr+'*-RHS03*_INT001')
del_data,tnames(pref_arr+'*-RHS03*_INT003')


;;-----------------------------------------------------------
;;  Remove edge effects
;;-----------------------------------------------------------
pref_arr       = ['*_efw','*_S_','*_n-dot-S','*_ndotS-n','*_nxSxn']
nnall          = tnames(pref_arr+'*_INT000')
nnall          = tnames(pref_arr+'*_INT001')
nnall          = tnames(pref_arr+'*_INT003')
nnall          = tnames(pref_arr+'*_INT005')
tplot,nnall

kill_data_tr,NAMES=nnall

;;----------------------------------------------------------------------------------------
;; => Print values to ASCII file
;;----------------------------------------------------------------------------------------
nsm            = 10L                     ;;  # of points to smooth Jo
;;-------------------------------------
;;  2009-09-05 [3 Crossings]
;;-------------------------------------
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['16:11:32.910','16:11:33.800']),/NAN)
magf_up        = [ 0.61279484d0,-0.57618533d0,-0.29177513d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [0L]
fsuffx         = '_1st-BS-Crossing-0'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       /UPSAMPLE)

gint           = [1L]
fsuffx         = '_1st-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       /UPSAMPLE)

;; => ASCII [2nd Shock]
nif_suffx      = '-RHS02'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['16:37:58.272','16:37:59.000']),/NAN)
magf_up        = [-1.07332678d0,-1.06251983d0,-0.23281553d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [3L]
fsuffx         = '_2nd-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       /UPSAMPLE)

;; => ASCII [3rd Shock]
nif_suffx      = '-RHS03'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['16:54:31.240','16:54:33.120']),/NAN)
magf_up        = [-0.27134223d0,-1.27554421d0,-0.27749658d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [5L]
fsuffx         = '_3rd-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       /UPSAMPLE)




















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





























































































;;-----------------------------------------------------------
;;  Try detrending the data
;;-----------------------------------------------------------
get_data,efp_names[0]+'_with_spikes',DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
;;  Find intervals
efp__t         = temp_efp.X
efp__v         = temp_efp.Y

interv         = t_interval_find(efp__t,GAP_THRESH=1d0)
HELP, interv
;; INTERV          LONG      = Array[3, 2]

efp__v_i0      = REFORM(efp__v[interv[0,0]:interv[0,1],*])
efp__v_i1      = REFORM(efp__v[interv[1,0]:interv[1,1],*])
efp__v_i2      = REFORM(efp__v[interv[2,0]:interv[2,1],*])

;;  Smooth data in each interval using autoregressive backcasting
wd             = 128L
efp_vx_i0      = remove_noise(efp__v_i0[*,0],NBINS=wd[0])
efp_vy_i0      = remove_noise(efp__v_i0[*,1],NBINS=wd[0])
efp_vz_i0      = remove_noise(efp__v_i0[*,2],NBINS=wd[0])

efp_vx_i1      = remove_noise(efp__v_i1[*,0],NBINS=wd[0])
efp_vy_i1      = remove_noise(efp__v_i1[*,1],NBINS=wd[0])
efp_vz_i1      = remove_noise(efp__v_i1[*,2],NBINS=wd[0])

efp_vx_i2      = remove_noise(efp__v_i2[*,0],NBINS=wd[0])
efp_vy_i2      = remove_noise(efp__v_i2[*,1],NBINS=wd[0])
efp_vz_i2      = remove_noise(efp__v_i2[*,2],NBINS=wd[0])

efp__vx        = [efp_vx_i0,efp_vx_i1,efp_vx_i2]
efp__vy        = [efp_vy_i0,efp_vy_i1,efp_vy_i2]
efp__vz        = [efp_vz_i0,efp_vz_i1,efp_vz_i2]
efp__v_sm      = [[efp__vx],[efp__vy],[efp__vz]]

temp_efp_sm    = {X:temp_efp.X,Y:efp__v_sm}
sm_str         = STRTRIM(STRING(wd[0],FORMAT='(I3.3)'),2)
tp_suffx       = '_with_spikes_ARBC_sm'+sm_str[0]+'pts'
tp_suffx2      = tp_suffx[0]+'_2'
tp_suffx3      = tp_suffx[0]+'_3'

store_data,efp_names[0]+tp_suffx[0],DATA=temp_efp_sm,DLIM=dlim_efp,LIM=lim_efp

test_efp       = (ABS(temp_efp_sm.Y[*,0]) LT 25d0)
good_efp       = WHERE(test_efp,gdefp,COMPLEMENT=bad_efp,NCOMPLEMENT=bdefp)
PRINT,';; ', gdefp, bdefp
;;       156894       74018

efp__t_sm      = temp_efp_sm.X
efp__v_sm      = temp_efp_sm.Y
ind_efp        = LINDGEN(N_ELEMENTS(efp__t_sm))

interv_bd      = t_interval_find(efp__t_sm[bad_efp],GAP_THRESH=1d0)
bad_low        = bad_efp[REFORM(interv_bd[*,0])]
bad_hig        = bad_efp[REFORM(interv_bd[*,1])]
;;  Add to end/start points
bad_low        = (bad_low - 6L) > 0
bad_hig        = (bad_hig + 6L) < (N_ELEMENTS(efp__t_sm) - 1L)

IF (bdefp GT 0) THEN FOR j=0L, N_ELEMENTS(bad_low) - 1L DO efp__v_sm[bad_low[j]:bad_hig[j],0] = f
temp_efp_sm_2  = {X:efp__t_sm,Y:efp__v_sm}
IF (gdefp GT 0) THEN store_data,efp_names[0]+tp_suffx2[0],DATA=temp_efp_sm_2,DLIM=dlim_efp,LIM=lim_efp

;;  Smooth to remove NaNs
dumb           = REPLICATE(1,N_ELEMENTS(efp__t_sm))
temp_v_sm_2    = efp__v_sm[*,0]
temp_t_sm_2    = efp__t_sm
FOR j=0L, N_ELEMENTS(bad_low) - 1L DO BEGIN  $
  bind = dumb                              & $
  bind[bad_low[j]:bad_hig[j]] = 0          & $
  gind = WHERE(bind,gd)                    & $
  temp0 = INTERPOL(temp_v_sm_2[gind],temp_t_sm_2[gind],temp_t_sm_2,/SPLINE)   & $
  temp_v_sm_2 = temp0
;;  Remove extrapolated points
mx0            = MAX(ABS(efp__v_sm[*,0]),/NAN)*1.1
bad            = WHERE(ABS(temp_v_sm_2) GT mx0[0],bd)
IF (bd GT 0) THEN temp_v_sm_2[bad] = f
efp__v_sm_2    = [[temp_v_sm_2],[efp__v_sm[*,1]],[efp__v_sm[*,2]]]
temp_efp_sm_3  = {X:temp_t_sm_2,Y:efp__v_sm_2}
store_data,efp_names[0]+tp_suffx3[0],DATA=temp_efp_sm_3,DLIM=dlim_efp,LIM=lim_efp



;;  Subtract from original
get_data,efp_names[0]+'_with_spikes',DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
get_data,efp_names[0]+tp_suffx2[0],DATA=temp_efp_sm_2,DLIM=dlim_efp_sm_2,LIM=lim_efp_sm_2
efp__t         = temp_efp.X
efp__v         = temp_efp.Y
efp__t_sm_2    = temp_efp_sm_2.X
efp__v_sm_2    = temp_efp_sm_2.Y

;;  Smooth to remove NaNs
smwd           = 150L
temp_vx_sm_2   = SMOOTH(efp__v_sm_2[*,0],smwd[0],/NAN,/EDGE_TRUNCATE)
temp_vy_sm_2   = SMOOTH(efp__v_sm_2[*,1],smwd[0],/NAN,/EDGE_TRUNCATE)
temp_vz_sm_2   = SMOOTH(efp__v_sm_2[*,2],smwd[0],/NAN,/EDGE_TRUNCATE)
temp_efp_sm_22 = {X:temp_efp_sm_2.X,Y:[[temp_vx_sm_2],[temp_vy_sm_2],[temp_vz_sm_2]]}
store_data,efp_names[0]+tp_suffx2[0],DATA=temp_efp_sm_22,DLIM=dlim_efp_sm_2,LIM=lim_efp_sm_2

;;  Subtract detrended values from original
del_efp_vx     = efp__v[*,0] - temp_vx_sm_2
del_efp_vy     = efp__v[*,1] - temp_vy_sm_2
del_efp_vz     = efp__v[*,2] - temp_vz_sm_2
;bad_efp_vx     = WHERE(FINITE(efp__v_sm_2[*,0]) EQ 0,bdefp_vx)
;IF (bdefp GT 0) THEN del_efp_vx[bad_efp_vx] = f

;test_efp       = (ABS(del_efp_vx) LT 3d1)
;good_efp       = WHERE(test_efp,gdefp,COMPLEMENT=bad_efp,NCOMPLEMENT=bdefp)
;IF (bdefp GT 0) THEN del_efp_vx[bad_efp] = f

del_efp_v      = [[del_efp_vx],[del_efp_vy],[del_efp_vz]]
tp_suffx       = '_detrend_subtract_ARBC_sm'+sm_str[0]+'pts'
temp_efp_dt    = {X:efp__t,Y:del_efp_v}
store_data,efp_names[0]+tp_suffx[0],DATA=temp_efp_dt,DLIM=dlim_efp,LIM=lim_efp

;;  Subtract new result from original
del_efp_vx_2   = efp__v[*,0] - del_efp_v[*,0]
del_efp_vy_2   = efp__v[*,1] - del_efp_v[*,1]
del_efp_vz_2   = efp__v[*,2] - del_efp_v[*,2]
del_efp_v_2    = [[del_efp_vx_2],[del_efp_vy_2],[del_efp_vz_2]]
tp_suffx2      = '_detrend_subtract_ARBC_sm'+sm_str[0]+'pts_2'
temp_efp_dt_2  = {X:efp__t,Y:del_efp_v_2}
store_data,efp_names[0]+tp_suffx2[0],DATA=temp_efp_dt_2,DLIM=dlim_efp,LIM=lim_efp








