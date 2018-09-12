;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
;@$HOME/Desktop/Old_or_External_IDL/TDAS/tdas_8_00/idl/comp_lynn_pros
.compile $HOME/Desktop/swidl-0.1/wind_3dp_pros/SCIENCE_PRO/spec3d.pro

thm_init
;;----------------------------------------------------------------------------------------
;;  Default and dummy variables
;;----------------------------------------------------------------------------------------
vec_str        = ['x','y','z']
fac_dir_str    = ['para','perp','anti']
vec_col        = [250,150,50]
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
th_data_dir    = '.'+slash[0]

def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;----------------------------------------------------------------------------------------
;;  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe A

;;  Probe B

probe          = 'b'
tdate          = '2008-07-14'
date           = '071408'

probe          = 'b'
tdate          = '2008-07-22'
date           = '072208'

probe          = 'b'
tdate          = '2008-07-26'
date           = '072608'

probe          = 'b'
tdate          = '2008-07-30'
date           = '073008'

probe          = 'b'
tdate          = '2008-08-07'
date           = '080708'

probe          = 'b'
tdate          = '2008-08-11'
date           = '081108'

probe          = 'b'
tdate          = '2008-08-23'
date           = '082308'

probe          = 'b'
tdate          = '2009-07-13'
date           = '071309'

;;  Probe C

probe          = 'c'
tdate          = '2008-07-14'
date           = '071408'

probe          = 'c'
tdate          = '2008-08-12'
date           = '081208'

probe          = 'c'
tdate          = '2008-08-19'
date           = '081908'

probe          = 'c'
tdate          = '2008-09-08'
date           = '090808'

probe          = 'c'
tdate          = '2008-09-16'
date           = '091608'

probe          = 'c'
tdate          = '2008-10-03'
date           = '100308'

probe          = 'c'
tdate          = '2008-10-09'
date           = '100908'

probe          = 'c'
tdate          = '2008-10-12'
date           = '101208'

probe          = 'c'
tdate          = '2008-10-29'
date           = '102908'

probe          = 'c'
tdate          = '2009-07-25'
date           = '072509'

;;  Probe D

;;  Probe E

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
;@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_foreshock_eVDFs_batch.pro
;@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_batch.pro
@$HOME/Desktop/swidl-0.1/wind_3dp_pros/wind_3dp_cribs/load_thm_fgm_efi_scm_2_tplot_batch.pro
;n_e            = N_ELEMENTS(dat_egse)
set_tplot_times

tplot_options,   'THICK',1.5
tplot_options,'CHARSIZE',1.00
tplot_options, 'XMARGIN',[20,10]
tplot_options, 'YMARGIN',[4,4]

magf__tpn      = scpref[0]+['fgh_'+[coord_mag[0],coord_dsl[0]],'fgl_'+coord_mag[0]]
vbulk_tpn      = scpref[0]+'peib_velocity_'+coord_gse[0]
densi_tpn      = scpref[0]+'peib_density'
eitem_tpn      = scpref[0]+['peib','peeb']+'_avgtemp'
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'b') THEN options,eitem_tpn[0],MAX_VALUE=500.
nna            = [magf__tpn,vbulk_tpn[0],densi_tpn[0],eitem_tpn]
tplot,nna

mach_tpn       = scpref[0]+'MA_MCs_Mms'         ;;  Mach numbers TPLOT handle
;;  ∂B/Bo [fgh] TPLOT handles
db_bov_dsl_tpn = 'dB_Bovec_'+modes_fgm[2]+'_'+coord_dsl[0]
db_bom_dsl_tpn = 'dB_Bomag_'+modes_fgm[2]+'_'+coord_dsl[0]
db_bom_mag_tpn = 'dB_Bomag_'+modes_fgm[2]+'_'+coord_mag[0]
;;  ∂B/Bo [scp and scw] TPLOT handles
scp_bo_dsl_tpn = 'dB_Bomag_'+modes_scm[1]+'_'+coord_dsl[0]
scw_bo_dsl_tpn = 'dB_Bomag_'+modes_scm[2]+'_'+coord_dsl[0]
scp_bo_mag_tpn = 'dB_Bomag_'+modes_scm[1]+'_'+coord_mag[0]
scw_bo_mag_tpn = 'dB_Bomag_'+modes_scm[2]+'_'+coord_mag[0]

fgh_dB_Bo_tpns = [db_bov_dsl_tpn[0],db_bom_dsl_tpn[0],db_bom_mag_tpn[0]]
scm_dB_Bo_tpns = [scp_bo_dsl_tpn[0],scw_bo_dsl_tpn[0],scp_bo_mag_tpn[0],scw_bo_mag_tpn[0]]

all_efp_tpns   = tnames(scpref[0]+'efp_l1_cal_*_corrected_rmspikes_'+[coord_dsl[0],coord_fac[0]])
all_scp_tpns   = tnames(scpref[0]+'scp_l1_cal_*_'+[coord_dsl[0],coord_fac[0]])
all_efw_tpns   = tnames(scpref[0]+'efw_l1_cal_*_corrected_rmspikes_'+[coord_dsl[0],coord_fac[0]])
all_scw_tpns   = tnames(scpref[0]+'scw_l1_cal_*_'+[coord_dsl[0],coord_fac[0]])

;;  Fix YTITLE and YSUBTITLE for scp
yttls          = 'B [SCP, '+STRUPCASE(coord_dsl[0])+', nT]'
ysubt_cor      = '[th'+sc[0]+' 128. sps, Cal., DC]'
options,all_scp_tpns[0],'YTITLE' 
options,all_scp_tpns[0],'YSUBTITLE'
options,all_scp_tpns[0],YTITLE=yttls[0],YSUBTITLE=ysubt_cor[0],/DEF

;;  Plot results
nna            = [magf__tpn,vbulk_tpn[0],densi_tpn[0],eitem_tpn,mach_tpn[0]]
tplot,nna

;;  Plot results
nna            = [magf__tpn,vbulk_tpn[0],densi_tpn[0],eitem_tpn,mach_tpn[0],fgh_dB_Bo_tpns[1:2]]
tplot,nna

nna            = [magf__tpn,vbulk_tpn[0],densi_tpn[0],eitem_tpn,mach_tpn[0],scm_dB_Bo_tpns[2:3]]
tplot,nna

nna            = [magf__tpn,vbulk_tpn[0],densi_tpn[0],eitem_tpn,mach_tpn[0],all_efw_tpns,all_scw_tpns]
tplot,nna

nna            = [magf__tpn[0:1],eitem_tpn,all_efw_tpns,all_scw_tpns]
tplot,nna

nna            = [magf__tpn[0:1],all_efw_tpns,all_scw_tpns]
tplot,nna

;;----------------------------------------------------------------------------------------
;;  Remove "spikes" or edge effects by hand
;;----------------------------------------------------------------------------------------
;;  Zoom to an interesting time range and save it quickly...
temp_tr        = t_get_current_trange()
temp_trs       = time_string(temp_tr,PREC=6)
PRINT,';;  '+temp_trs[0]+' - '+temp_trs[1]+'  for  th'+probe[0]+', on '+tdate[0]
;;  2008-08-12/00:10:10.600000 - 2008-08-12/00:20:16.700000  for  thc, on 2008-08-12

temp_trw0      = t_get_current_trange()
temp_trs       = time_string(temp_trw0,PREC=6)
PRINT,';;  '+temp_trs[0]+' - '+temp_trs[1]+'  for  th'+probe[0]+', on '+tdate[0]
;;  2008-08-12/00:14:13.000000 - 2008-08-12/00:14:21.270000  for  thc, on 2008-08-12

temp_trw1      = t_get_current_trange()
temp_trs       = time_string(temp_trw1,PREC=6)
PRINT,';;  '+temp_trs[0]+' - '+temp_trs[1]+'  for  th'+probe[0]+', on '+tdate[0]
;;  2008-08-12/00:15:10.399000 - 2008-08-12/00:15:18.625000  for  thc, on 2008-08-12


;;  Remove all components from all fields
kill_data_tr,NAMES=[all_efw_tpns,all_scw_tpns]

;;  Remove ONLY last component from all E-fields
kill_data_tr,NAMES=all_efw_tpns,IND_2D=[2]

;;  Remove ONLY first component from ONLY DSL E-fields
kill_data_tr,NAMES=all_efw_tpns[0],IND_2D=[0]


;;  Shift to the next time window and print new time range to screen
t_tr_nplfz,/NEXT,/PRINT_NT
;;  Shift to the previous time window and print new time range to screen
t_tr_nplfz,/PREVIOUS,/PRINT_NT
;;  Shift to the right by 50 ms keeping the same duration as the current time window
;;    and print new time range to screen
t_tr_nplfz,DT_PAN=50d-3,/PRINT_NT
;;  Zoom in by a factor of 2
t_tr_nplfz,T_ZOOM=5d-1,/PRINT_NT
;;  Zoom out by a factor of 2
t_tr_nplfz,T_ZOOM=2d0,/PRINT_NT


;;  Now re-define the FAC data
.compile $HOME/Desktop/temp_idl/temp_t_vec_2_fac.pro
;;  efp
in__name       = all_efp_tpns[0]
out_name       = STRMID(in__name[0],0L,STRLEN(in__name[0])-4L)
temp_t_vec_2_fac,in__name[0],magf__tpn[1],OUT_TPN=out_name[0],SM_WIDTH=11L,TPNS_OUT=tpns_out
efp_fac_tpns   = tpns_out
;;  efw
in__name       = all_efw_tpns[0]
out_name       = STRMID(in__name[0],0L,STRLEN(in__name[0])-4L)
temp_t_vec_2_fac,in__name[0],magf__tpn[1],OUT_TPN=out_name[0],SM_WIDTH=11L,TPNS_OUT=tpns_out
efw_fac_tpns   = tpns_out
;;  scp
in__name       = all_scp_tpns[0]
out_name       = STRMID(in__name[0],0L,STRLEN(in__name[0])-4L)
temp_t_vec_2_fac,in__name[0],magf__tpn[1],OUT_TPN=out_name[0],SM_WIDTH=11L,TPNS_OUT=tpns_out
scp_fac_tpns   = tpns_out
;;  scw
in__name       = all_scw_tpns[0]
out_name       = STRMID(in__name[0],0L,STRLEN(in__name[0])-4L)
temp_t_vec_2_fac,in__name[0],magf__tpn[1],OUT_TPN=out_name[0],SM_WIDTH=11L,TPNS_OUT=tpns_out
scw_fac_tpns   = tpns_out

;;  Fix YTITLE and YSUBTITLE for scp
yttls          = 'B [SCP, '+STRUPCASE(coord_fac[0])+', nT]'
options,scp_fac_tpns[0],'YTITLE' 
options,scp_fac_tpns[0],YTITLE=yttls[0],/DEF
yttls          = 'E [EFP, '+STRUPCASE(coord_fac[0])+', mV/m]'
options,efp_fac_tpns[0],'YTITLE' 
options,efp_fac_tpns[0],YTITLE=yttls[0],/DEF


;;  Save changes
file_out       = STRMID(tpn__file[0],0L,STRLEN(tpn__file[0])-6L)
tplot_save,FILENAME=file_out[0]   ;;  tpn__file defined in load_thm_fgm_efi_scm_2_tplot_batch.pro

;;----------------------------------------------------------------------------------------
;;  Calculate the outer envelope of AC-coupled fields
;;    --> as a proxy for average wave amplitudes
;;----------------------------------------------------------------------------------------
tpname         = [efp_fac_tpns[0],efw_fac_tpns[0],scp_fac_tpns[0],scw_fac_tpns[0]]
sm_width       = 3L                     ;;  Smooth envelope over 3 points
rm_edges       = 1b                     ;;  remove edges to eliminate extrapolations
lo_01          = [16L,128L]
length         = [lo_01,lo_01]          ;;  envelope window width = 128 points
offset         = [lo_01,lo_01]          ;;  shift by 128 points for each new envelope window
;length         = 128L      ;;  envelope window width = 128 points
;offset         = 128L      ;;  shift by 128 points for each new envelope window
a_load         = 1b                     ;;  load envelopes for all vector components
sep_int        = 0b                     ;;  do NOT create unique TPLOT handles for each interval

FOR jj=0L, N_ELEMENTS(tpname) - 1L DO BEGIN                                           $
  in_name = tpname[jj]                                                              & $
  lbw_vec_waveform_envelope_2_tplot,in_name,OUT_TPN=out_tpn,SEP_INT=sep_int,          $
                                    X_LOAD=x_load,Y_LOAD=y_load,                      $
                                    Z_LOAD=z_load,A_LOAD=a_load,                      $
                                    SM_WIDTH=sm_width,RM_EDGES=rm_edges,              $
                                    LENGTH=length[jj],OFFSET=offset[jj],              $
                                    TPNS_OUT=tpns_out                               & $
  IF (jj EQ 0) THEN efp_env_tpns = tpns_out                                         & $
  IF (jj EQ 1) THEN efw_env_tpns = tpns_out                                         & $
  IF (jj EQ 2) THEN scp_env_tpns = tpns_out                                         & $
  IF (jj EQ 3) THEN scw_env_tpns = tpns_out

;;  Save changes
file_out       = STRMID(tpn__file[0],0L,STRLEN(tpn__file[0])-6L)
tplot_save,FILENAME=file_out[0]   ;;  tpn__file defined in load_thm_fgm_efi_scm_2_tplot_batch.pro


;;----------------------------------------------------------------------------------------
;;  Define file paths and names to fit results
;;----------------------------------------------------------------------------------------
eVDF_dir       = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'TPLOT_THEMIS_PLOTS'+slash[0]+'eVDF_Fits'+slash[0]
fpref_dir      = 'eVDF_'+scpref[0]+'Fits_'+tdate[0]
fpref          = 'THEMIS_EESA_*_'+sc[0]+'_SWF_SCF_Power_Law_Exponential_Fit-Results_'
fname          = fpref[0]+tdate[0]+'*.sav'
dir            = eVDF_dir[0]+fpref_dir[0]+slash[0]
file           = FILE_SEARCH(dir[0],fname[0])
RESTORE,file[0]

HELP, plexp_fit_pnt
gnne           = N_ELEMENTS(plexp_fit_pnt[*,1])
plexp_scf_ptr  = PTRARR(gnne[0],/ALLOCATE_HEAP)
plexp_swf_ptr  = PTRARR(gnne[0],/ALLOCATE_HEAP)
FOR j=0L, gnne[0] - 1L DO BEGIN                       $
  *plexp_scf_ptr[j] = *plexp_fit_pnt[j,1]           & $
  *plexp_swf_ptr[j] = *plexp_fit_pnt[j,0]

;;  Clean up
FOR frame=0L, 1L DO BEGIN                                            $
  FOR j=0L, gnne[0] - 1L DO BEGIN                                    $
    PTR_FREE,plexp_fit_pnt[j,frame]                                & $
    HEAP_FREE,plexp_fit_pnt[j,frame],/PTR
DELVAR,plexp_fit_pnt

;;----------------------------------------------------------------------------------------
;;  Define fit parameter results
;;----------------------------------------------------------------------------------------
;;------------------------------------------------
;;  (Power-Law + Exponential) Fits
;;    Y = A X^(B) e^(C X) + D
;;------------------------------------------------
n_fits         = N_ELEMENTS(plexp_swf_ptr)
unix_sten      = REPLICATE(d,n_fits[0],2L)
magf_vals      = REPLICATE(d,n_fits[0],3L)       ;;  GSE B-field vectors for each event [nT]
vsw__vals      = REPLICATE(d,n_fits[0],3L)       ;;  GSE bulk flow velocity vectors for each event [km/s]
fit_params     = REPLICATE(d,n_fits[0],4L,3L)    ;;  [N,4,3] --> 3 = Para, Perp, Anti
sig_params     = REPLICATE(d,n_fits[0],4L,3L)
fit_status     = REPLICATE(d,n_fits[0],3L)
dof__chisq     = REPLICATE(d,n_fits[0],2L,3L)

FOR j=0L, n_fits[0] - 1L DO BEGIN                                                        $
  st_unix   = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.TIME[0]                              & $
  en_unix   = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.END_TIME[0]                          & $
  temp_bgse = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.MAGF                                 & $
  temp_vgse = (*plexp_swf_ptr[j]).INIT_STRUC.DATA.VSW                                  & $
  temp_par  = (*plexp_swf_ptr[j]).FIT_PARA_STRUC.FIT                                   & $
  temp_per  = (*plexp_swf_ptr[j]).FIT_PERP_STRUC.FIT                                   & $
  temp_ant  = (*plexp_swf_ptr[j]).FIT_ANTI_STRUC.FIT                                   & $
  temp_parm = [[temp_par.FIT_PARAMS],[temp_per.FIT_PARAMS],[temp_ant.FIT_PARAMS]]      & $
  temp_sigp = [[temp_par.SIG_PARAM],[temp_per.SIG_PARAM],[temp_ant.SIG_PARAM]]         & $
  temp_chi2 = [temp_par.CHISQ[0],temp_per.CHISQ[0],temp_ant.CHISQ[0]]                  & $
  temp_dof  = [temp_par.DOF[0],temp_per.DOF[0],temp_ant.DOF[0]]                        & $
  temp_stat = [temp_par.STATUS[0],temp_per.STATUS[0],temp_ant.STATUS[0]]               & $
  unix_sten[j,*] = [st_unix[0],en_unix[0]]                                             & $
  magf_vals[j,*] = temp_bgse                                                           & $
  vsw__vals[j,*] = temp_vgse                                                           & $
  fit_params[j,*,*] = temp_parm                                                        & $
  sig_params[j,*,*] = temp_sigp                                                        & $
  fit_status[j,*]   = temp_stat                                                        & $
  dof__chisq[j,0,*] = temp_dof                                                         & $
  dof__chisq[j,1,*] = temp_chi2

;;  Calculate the reduced chi-squared value
red_chisq      = REFORM(dof__chisq[*,1,*])/REFORM(dof__chisq[*,0,*])
;;----------------------------------------------------------------------------------------
;;  Define constraints to determine "quality"
;;----------------------------------------------------------------------------------------
;;  Find strahl direction
;.compile $HOME/Desktop/temp_idl/temp_electron_fitting_routines/find_strahl_direction.pro
;.compile $HOME/Desktop/temp_idl/get_power_of_ten_ticks.pro
strahl_dir     = find_strahl_direction(magf_vals)
;;  Define relevant time range
tra_eVDFs      = minmax(unix_sten)
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN tra_eVDFs = minmax(unix_sten[0L:(n_fits[0] - 2L),*])
;;  Define some constraints
min_Eo         = 75d0
max_B          = 1.5d0
max_rchi2      = 3d3
min_A          = 1d5

;;  Define tests to determine the "quality" of any given fit
bad_A_par_test = (fit_params[*,0,0] LT min_A[0]) OR (red_chisq[*,0] GT max_rchi2[0])
bad_A_per_test = (fit_params[*,0,1] LT min_A[0]) OR (red_chisq[*,1] GT max_rchi2[0])
bad_A_ant_test = (fit_params[*,0,2] LT min_A[0]) OR (red_chisq[*,1] GT max_rchi2[0])
bad_B_par_test = (fit_params[*,1,0] GT 0) OR (ABS(fit_params[*,1,0]) GT max_B[0])
bad_B_per_test = (fit_params[*,1,1] GT 0) OR (ABS(fit_params[*,1,1]) GT max_B[0])
bad_B_ant_test = (fit_params[*,1,2] GT 0) OR (ABS(fit_params[*,1,2]) GT max_B[0])
bad_C_par_test = (fit_params[*,2,0] GT 0) OR ((1d0/ABS(fit_params[*,2,0])) LT min_Eo[0])
bad_C_per_test = (fit_params[*,2,1] GT 0) OR ((1d0/ABS(fit_params[*,2,1])) LT min_Eo[0])
bad_C_ant_test = (fit_params[*,2,2] GT 0) OR ((1d0/ABS(fit_params[*,2,2])) LT min_Eo[0])

bad_par_test   = bad_A_par_test OR bad_B_par_test OR bad_C_par_test OR (strahl_dir GT 0d0)
bad_per_test   = bad_A_per_test OR bad_B_per_test OR bad_C_per_test
bad_ant_test   = bad_A_ant_test OR bad_B_ant_test OR bad_C_ant_test OR (strahl_dir LT 0d0)
bad_stats_test = (fit_status[*,0] LE 0) OR (fit_status[*,1] LE 0) OR (fit_status[*,2] LE 0)

bad_par        = WHERE(bad_par_test OR bad_stats_test,bd_par,COMPLEMENT=good_par,NCOMPLEMENT=gd_par)
bad_per        = WHERE(bad_per_test OR bad_stats_test,bd_per,COMPLEMENT=good_per,NCOMPLEMENT=gd_per)
bad_ant        = WHERE(bad_ant_test OR bad_stats_test,bd_ant,COMPLEMENT=good_ant,NCOMPLEMENT=gd_ant)
PRINT,';;',gd_par[0],gd_per[0],gd_ant[0],'  For '+tdate[0]+', Probe '+scu[0] & $
PRINT,';;',bd_par[0],bd_per[0],bd_ant[0],'  For '+tdate[0]+', Probe '+scu[0]
;;         617         915          88  For 2008-07-14, Probe B
;;         770         472        1299  For 2008-07-14, Probe B
;;         655         846          56  For 2008-07-14, Probe C
;;         323         132         922  For 2008-07-14, Probe C
;;         131         154           7  For 2008-08-12, Probe C
;;          71          48         195  For 2008-08-12, Probe C


;;  Define arrays for the power-law indices and energy cutoffs
powerlaws_gb   = REPLICATE(d,n_fits[0],3L,2L)
enercutof_gb   = REPLICATE(d,n_fits[0],3L,2L)
;;  Define arrays for the fit status and reduced chi-squared
fitstat___gb   = REPLICATE(d,n_fits[0],3L,2L)
red_chisq_gb   = REPLICATE(d,n_fits[0],3L,2L)
;;  Fill arrays
IF (gd_par GT 0) THEN powerlaws_gb[good_par,0L,0L] = fit_params[good_par,1,0]
IF (gd_per GT 0) THEN powerlaws_gb[good_per,1L,0L] = fit_params[good_per,1,1]
IF (gd_ant GT 0) THEN powerlaws_gb[good_ant,2L,0L] = fit_params[good_ant,1,2]
IF (bd_par GT 0) THEN powerlaws_gb[ bad_par,0L,1L] = fit_params[ bad_par,1,0]
IF (bd_per GT 0) THEN powerlaws_gb[ bad_per,1L,1L] = fit_params[ bad_per,1,1]
IF (bd_ant GT 0) THEN powerlaws_gb[ bad_ant,2L,1L] = fit_params[ bad_ant,1,2]

IF (gd_par GT 0) THEN enercutof_gb[good_par,0L,0L] = 1d0/ABS(fit_params[good_par,2,0])
IF (gd_per GT 0) THEN enercutof_gb[good_per,1L,0L] = 1d0/ABS(fit_params[good_per,2,1])
IF (gd_ant GT 0) THEN enercutof_gb[good_ant,2L,0L] = 1d0/ABS(fit_params[good_ant,2,2])
IF (bd_par GT 0) THEN enercutof_gb[ bad_par,0L,1L] = 1d0/ABS(fit_params[ bad_par,2,0])
IF (bd_per GT 0) THEN enercutof_gb[ bad_per,1L,1L] = 1d0/ABS(fit_params[ bad_per,2,1])
IF (bd_ant GT 0) THEN enercutof_gb[ bad_ant,2L,1L] = 1d0/ABS(fit_params[ bad_ant,2,2])

IF (gd_par GT 0) THEN fitstat___gb[good_par,0L,0L] = fit_status[good_par,0]
IF (gd_per GT 0) THEN fitstat___gb[good_per,1L,0L] = fit_status[good_per,1]
IF (gd_ant GT 0) THEN fitstat___gb[good_ant,2L,0L] = fit_status[good_ant,2]
IF (bd_par GT 0) THEN fitstat___gb[ bad_par,0L,1L] = fit_status[ bad_par,0]
IF (bd_per GT 0) THEN fitstat___gb[ bad_per,1L,1L] = fit_status[ bad_per,1]
IF (bd_ant GT 0) THEN fitstat___gb[ bad_ant,2L,1L] = fit_status[ bad_ant,2]

IF (gd_par GT 0) THEN red_chisq_gb[good_par,0L,0L] = red_chisq[good_par,0]
IF (gd_per GT 0) THEN red_chisq_gb[good_per,1L,0L] = red_chisq[good_per,1]
IF (gd_ant GT 0) THEN red_chisq_gb[good_ant,2L,0L] = red_chisq[good_ant,2]
IF (bd_par GT 0) THEN red_chisq_gb[ bad_par,0L,1L] = red_chisq[ bad_par,0]
IF (bd_per GT 0) THEN red_chisq_gb[ bad_per,1L,1L] = red_chisq[ bad_per,1]
IF (bd_ant GT 0) THEN red_chisq_gb[ bad_ant,2L,1L] = red_chisq[ bad_ant,2]

;;  Add offsets to keep status' from overlapping in plots
fitstat___gb[*,1L,*] += 0.2
fitstat___gb[*,2L,*] += 0.4
;;----------------------------------------------------------------------------------------
;;  Send results to TPLOT
;;----------------------------------------------------------------------------------------
;;  Define output structures
avg_unix       = (unix_sten[*,0] + unix_sten[*,1])/2d0
good_pl_str    = {X:avg_unix,Y:powerlaws_gb[*,*,0]}
bad__pl_str    = {X:avg_unix,Y:powerlaws_gb[*,*,1]}
good_Eo_str    = {X:avg_unix,Y:enercutof_gb[*,*,0]}
bad__Eo_str    = {X:avg_unix,Y:enercutof_gb[*,*,1]}
good_fs_str    = {X:avg_unix,Y:fitstat___gb[*,*,0]}
bad__fs_str    = {X:avg_unix,Y:fitstat___gb[*,*,1]}
good_rc_str    = {X:avg_unix,Y:red_chisq_gb[*,*,0]}
bad__rc_str    = {X:avg_unix,Y:red_chisq_gb[*,*,1]}

;;  Define TPLOT handles
tpn_suffx_pe   = ['powerlaws','ener_cutoffs','fit_status','red_chisq']
tpn_suffx_gb   = ['good','bad']
good_pl_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[0]+'_'+tpn_suffx_gb[0]
bad__pl_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[0]+'_'+tpn_suffx_gb[1]
good_Eo_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[1]+'_'+tpn_suffx_gb[0]
bad__Eo_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[1]+'_'+tpn_suffx_gb[1]
good_fs_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[2]+'_'+tpn_suffx_gb[0]
bad__fs_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[2]+'_'+tpn_suffx_gb[1]
good_rc_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[3]+'_'+tpn_suffx_gb[0]
bad__rc_tpn    = scpref[0]+'peeb_'+tpn_suffx_pe[3]+'_'+tpn_suffx_gb[1]

;;  Define YTITLE's and YSUBTITLE's
;good_pl_ysubt  = '[Good: Sat. Constraints]'
;bad__pl_ysubt  = '[Bad: Failed Constraints]'
good_pl_yttle  = 'Power Law Index'
bad__pl_yttle  = good_pl_yttle[0]
good_pl_ysubt  = '[Good Const.]'
bad__pl_ysubt  = '[Bad Const.]'
good_Eo_yttle  = 'Energy Cutoff [eV]'
good_Eo_ysubt  = good_pl_ysubt[0]
bad__Eo_yttle  = good_Eo_yttle[0]
bad__Eo_ysubt  = bad__pl_ysubt[0]
good_fs_yttle  = 'Fit Status'
good_fs_ysubt  = good_pl_ysubt[0]
bad__fs_yttle  = good_fs_yttle[0]
bad__fs_ysubt  = bad__pl_ysubt[0]
good_rc_yttle  = 'Red. Chi^2'
good_rc_ysubt  = good_pl_ysubt[0]
bad__rc_yttle  = good_rc_yttle[0]
bad__rc_ysubt  = bad__pl_ysubt[0]

;;  Define YRANGE's
good_pl_yran   = [-155e-2,0e00]
bad__pl_yran   = [MIN(bad__pl_str.Y,/NAN),MAX(bad__pl_str.Y,/NAN)]
good_Eo_yran   = [1e1,(MAX(good_Eo_str.Y,/NAN) > 1e2) < 1e6]
bad__Eo_yran   = [1e1,(MAX(bad__Eo_str.Y,/NAN) > 1e2) < 1e6]
good_Eo_ytick  = get_power_of_ten_ticks(good_Eo_yran)
bad__Eo_ytick  = get_power_of_ten_ticks(bad__Eo_yran)
good_fs_yran   = [0e0,1e1]
bad__fs_yran   = [-19e0,1e0]
good_rc_yran   = [(MIN(good_rc_str.Y,/NAN)) < 9e-1,max_rchi2[0]]
bad__rc_yran   = [1e-1,(MAX(bad__rc_str.Y,/NAN) > 1e1) < 1e6]

;;  Send to TPLOT
store_data,good_pl_tpn[0],DATA=good_pl_str,DLIM=def_dlim,LIM=def__lim
store_data,bad__pl_tpn[0],DATA=bad__pl_str,DLIM=def_dlim,LIM=def__lim
store_data,good_Eo_tpn[0],DATA=good_Eo_str,DLIM=def_dlim,LIM=def__lim
store_data,bad__Eo_tpn[0],DATA=bad__Eo_str,DLIM=def_dlim,LIM=def__lim
store_data,good_fs_tpn[0],DATA=good_fs_str,DLIM=def_dlim,LIM=def__lim
store_data,bad__fs_tpn[0],DATA=bad__fs_str,DLIM=def_dlim,LIM=def__lim
store_data,good_rc_tpn[0],DATA=good_rc_str,DLIM=def_dlim,LIM=def__lim
store_data,bad__rc_tpn[0],DATA=bad__rc_str,DLIM=def_dlim,LIM=def__lim

;;  Alter options
symb          = 2
options,good_pl_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=good_pl_yttle[0],YLOG=0,YMINOR=4,/DEF
options,bad__pl_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=bad__pl_yttle[0],YLOG=0,YMINOR=4,/DEF
options,good_Eo_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=good_Eo_yttle[0],YLOG=1,YMINOR=9,/DEF
options,bad__Eo_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=bad__Eo_yttle[0],YLOG=1,YMINOR=9,/DEF
options,good_pl_tpn[0],YRANGE=good_pl_yran,YSUBTITLE=good_pl_ysubt[0],PSYM=symb[0],/DEF
options,bad__pl_tpn[0],YRANGE=bad__pl_yran,YSUBTITLE=bad__pl_ysubt[0],PSYM=symb[0],/DEF
options,good_Eo_tpn[0],YRANGE=good_Eo_yran,YSUBTITLE=good_Eo_ysubt[0],PSYM=symb[0],/DEF
options,bad__Eo_tpn[0],YRANGE=bad__Eo_yran,YSUBTITLE=bad__Eo_ysubt[0],PSYM=symb[0],/DEF
options,good_Eo_tpn[0],YTICKNAME=good_Eo_ytick.YTICKNAME,YTICKV=good_Eo_ytick.YTICKV,YTICKS=good_Eo_ytick.YTICKS,/DEF
options,bad__Eo_tpn[0],YTICKNAME=bad__Eo_ytick.YTICKNAME,YTICKV=bad__Eo_ytick.YTICKV,YTICKS=bad__Eo_ytick.YTICKS,/DEF
options,good_fs_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=good_fs_yttle[0],YLOG=0,YMINOR=4,/DEF
options,bad__fs_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=bad__fs_yttle[0],YLOG=0,YMINOR=4,/DEF
options,good_fs_tpn[0],YRANGE=good_fs_yran,YSUBTITLE=good_fs_ysubt[0],PSYM=symb[0],/DEF
options,bad__fs_tpn[0],YRANGE=bad__fs_yran,YSUBTITLE=bad__fs_ysubt[0],PSYM=symb[0],/DEF
options,good_rc_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=good_rc_yttle[0],YLOG=1,YMINOR=9,/DEF
options,bad__rc_tpn[0],LABELS=fac_dir_str,COLORS=vec_col,YTITLE=bad__rc_yttle[0],YLOG=1,YMINOR=9,/DEF
options,good_rc_tpn[0],YRANGE=good_rc_yran,YSUBTITLE=good_rc_ysubt[0],PSYM=symb[0],/DEF
options,bad__rc_tpn[0],YRANGE=bad__rc_yran,YSUBTITLE=bad__rc_ysubt[0],PSYM=symb[0],/DEF


;;  Plot results
all_pl_tpns    = [good_pl_tpn[0],bad__pl_tpn[0]]
all_Eo_tpns    = [good_Eo_tpn[0],bad__Eo_tpn[0]]
all_fs_tpns    = [good_fs_tpn[0],bad__fs_tpn[0]]
all_rc_tpns    = [good_rc_tpn[0],bad__rc_tpn[0]]
all_gd_tpns    = [all_pl_tpns[0],all_Eo_tpns[0],all_fs_tpns[0],all_rc_tpns[0]]
all_bd_tpns    = [all_pl_tpns[1],all_Eo_tpns[1],all_fs_tpns[1],all_rc_tpns[1]]
par_per_ant_ii = [1L,4L,7L]
pl_gb_tpns     = [all_gd_tpns[0],all_bd_tpns[0]]
eo_gb_tpns     = [all_gd_tpns[1],all_bd_tpns[1]]
all_dB_Bo_tpns = [db_bov_gse_tpn[0],db_bom_gse_tpn[0],db_bom_mag_tpn[0]]

nna            = [magf__tpn[0:1],densi_tpn[0],eitem_tpn,all_pl_tpns,all_Eo_tpns]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],eitem_tpn,all_pl_tpns,all_Eo_tpns]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_pl_tpns,all_Eo_tpns]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_pl_tpns[0],all_Eo_tpns[0]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_pl_tpns[0],all_Eo_tpns[0],all_dB_Bo_tpns]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_pl_tpns,all_Eo_tpns,all_dB_Bo_tpns[1:2]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_pl_tpns[0],all_Eo_tpns[0],all_dB_Bo_tpns[1:2]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_fs_tpns,all_rc_tpns,all_dB_Bo_tpns[1:2]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_fs_tpns[0],all_rc_tpns[0],all_dB_Bo_tpns[1:2]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],all_gd_tpns,fgh_dB_Bo_tpns[1:2]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],all_gd_tpns[0:1],fgh_dB_Bo_tpns[1:2]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],all_gd_tpns,scm_dB_Bo_tpns[2:3]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],all_gd_tpns[0:1],scm_dB_Bo_tpns[2:3]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],eo_gb_tpns,scm_dB_Bo_tpns[2:3]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],pl_gb_tpns,scm_dB_Bo_tpns[2:3]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_bd_tpns[0:1],efp_env_tpns[10],scp_env_tpns[10]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_bd_tpns[0:1],efw_env_tpns[10],scw_env_tpns[10]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_gd_tpns[0:1],efp_env_tpns[10],scp_env_tpns[10]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],mach_tpn[0],all_gd_tpns[0:1],efw_env_tpns[10],scw_env_tpns[10]]
tplot,nna,TRANGE=tra_eVDFs

nna            = [magf__tpn[0:1],pl_gb_tpns,efp_env_tpns[par_per_ant_ii],scp_env_tpns[par_per_ant_ii]]
tplot,nna

nna            = [magf__tpn[0:1],pl_gb_tpns,efw_env_tpns[par_per_ant_ii],scw_env_tpns[par_per_ant_ii]]
tplot,nna

nna            = [magf__tpn[0:1],eo_gb_tpns,efp_env_tpns[par_per_ant_ii],scp_env_tpns[par_per_ant_ii]]
tplot,nna

nna            = [magf__tpn[0:1],eo_gb_tpns,efw_env_tpns[par_per_ant_ii],scw_env_tpns[par_per_ant_ii]]
tplot,nna

;;  Save changes
file_out       = STRMID(tpn__file[0],0L,STRLEN(tpn__file[0])-12L)+'_with_eVDF_fit_results'
tplot_save,FILENAME=file_out[0]   ;;  tpn__file defined in load_thm_fgm_efi_scm_2_tplot_batch.pro


;;  Try plotting one vs. another

xyttles        = ['para','perp','anti']
one_out        = eo_gb_tpns[0]
xyran          = [1d1,1d4]
xylog          = 1
ex_str         = {WINDOW:1,XSIZE:800,YSIZE:800,MULTI:'1 3',PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[0],YTITLE:xyttles[1],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='xy',_EXTRA=ex_str
ex_str         = {PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[2],YTITLE:xyttles[0],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='xz',/ADD,_EXTRA=ex_str
ex_str         = {PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[1],YTITLE:xyttles[2],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='yz',/ADD,_EXTRA=ex_str

one_out        = eo_gb_tpns[1]
xyran          = [1d1,1d4]
xylog          = 1
ex_str         = {WINDOW:1,XSIZE:800,YSIZE:800,MULTI:'1 3',PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[0],YTITLE:xyttles[1],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='xy',_EXTRA=ex_str
ex_str         = {PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[2],YTITLE:xyttles[0],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='xz',/ADD,_EXTRA=ex_str
ex_str         = {PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[1],YTITLE:xyttles[2],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='yz',/ADD,_EXTRA=ex_str

xyttles        = ['para','perp','anti']
one_out        = pl_gb_tpns[0]
xyran          = [-1.6,0d0]
xylog          = 0
ex_str         = {WINDOW:1,XSIZE:800,YSIZE:800,MULTI:'1 3',PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[0],YTITLE:xyttles[1],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='xy',_EXTRA=ex_str
ex_str         = {PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[2],YTITLE:xyttles[0],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='xz',/ADD,_EXTRA=ex_str
ex_str         = {PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[1],YTITLE:xyttles[2],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='yz',/ADD,_EXTRA=ex_str

one_out        = pl_gb_tpns[1]
xyran          = [-3.5d0,1d0]
xylog          = 0
ex_str         = {WINDOW:1,XSIZE:800,YSIZE:800,MULTI:'1 3',PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[0],YTITLE:xyttles[1],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='xy',_EXTRA=ex_str
ex_str         = {PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[2],YTITLE:xyttles[0],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='xz',/ADD,_EXTRA=ex_str
ex_str         = {PSYM:2,XRANGE:xyran,YRANGE:xyran,XTITLE:xyttles[1],YTITLE:xyttles[2],NOISOTROPIC:0,XLOG:xylog[0],YLOG:xylog[0]}
tplotxy,one_out[0],VERSUS='yz',/ADD,_EXTRA=ex_str

;;----------------------------------------------------------------------------------------
;;  Compare ∂B/Bo with fit parameters
;;----------------------------------------------------------------------------------------
bmag_n_sm_t    = db_bom_mag_str.X        ;;  Unix times for smoothed |dB|/|Bo|
bmag_n_sm_v    = db_bom_mag_str.Y[*,1]   ;;  smoothed |dB|/|Bo|
;;  Find intervals between t_(j-1) and t_(j+1)
evdf_t_bda     = REPLICATE(d,n_fits[0] + 2L,3L)  ;;  bda --> before, during, after
n_bda          = N_ELEMENTS(evdf_t_bda[*,0L])
nl             = n_bda[0] - 1L
ind            = LINDGEN(n_fits[0]) + 1L
evdf_t_bda[ind,0L] = unix_sten[*,0]
evdf_t_bda[ind,1L] = avg_unix
evdf_t_bda[ind,2L] = unix_sten[*,1]
evdf_t_bda[0L,*]   = evdf_t_bda[1L,*] - 3d0
evdf_t_bda[nl,*]   = evdf_t_bda[nl[0] - 1L,*] + 3d0
;;  Define dummy variables for peak value of smoothed |dB|/|Bo| within intervals
pk__db_Bo_sm   = REPLICATE(d,n_bda[0])      ;;  Peak value between t_(j-1) and t_(j+1)
avg_db_Bo_sm   = REPLICATE(d,n_bda[0])      ;;  Avg. value between t_(j-1) and t_(j+1)
med_db_Bo_sm   = REPLICATE(d,n_bda[0])      ;;  Median value between t_(j-1) and t_(j+1)
vat_db_Bo_sm   = REPLICATE(d,n_bda[0])      ;;  Value at t_j
FOR j=0L, n_bda[0] - 1L DO BEGIN                                                        $
  evdf_ts = REFORM(evdf_t_bda[j,*])                                                   & $
  test    = (bmag_n_sm_t GE evdf_ts[0]) AND (bmag_n_sm_t LE evdf_ts[2])               & $
  good    = WHERE(test,gd)                                                            & $
  IF (gd GT 0) THEN pk__db_Bo_sm[j] = MAX(bmag_n_sm_v[good],/NAN)                     & $
  IF (gd GT 0) THEN avg_db_Bo_sm[j] = MEAN(bmag_n_sm_v[good],/NAN)                    & $
  IF (gd GT 0) THEN med_db_Bo_sm[j] = MEDIAN(bmag_n_sm_v[good])
;;  Define values at t_j
vat_db_Bo_sm   = interp(bmag_n_sm_v,bmag_n_sm_t,REFORM(evdf_t_bda[*,1L]),/NO_EXTRAP)

;;----------------------------------------------------------------------------------------
;;  Find the hardest power-laws satisfying constraints
;;----------------------------------------------------------------------------------------
test_hd_par_pl = (ABS(powerlaws_gb[*,0L,0L]) LT 0.5) AND FINITE(powerlaws_gb[*,0L,0L])
test_hd_per_pl = (ABS(powerlaws_gb[*,1L,0L]) LT 0.5) AND FINITE(powerlaws_gb[*,1L,0L])
test_hd_ant_pl = (ABS(powerlaws_gb[*,2L,0L]) LT 0.5) AND FINITE(powerlaws_gb[*,2L,0L])

good_hd_par_pl = WHERE(test_hd_par_pl,gd_hd_par_pl,COMPLEMENT=bad_hd_par_pl,NCOMPLEMENT=bd_hd_par_pl)
good_hd_per_pl = WHERE(test_hd_per_pl,gd_hd_per_pl,COMPLEMENT=bad_hd_per_pl,NCOMPLEMENT=bd_hd_per_pl)
good_hd_ant_pl = WHERE(test_hd_ant_pl,gd_hd_ant_pl,COMPLEMENT=bad_hd_ant_pl,NCOMPLEMENT=bd_hd_ant_pl)
PRINT,';;',gd_hd_par_pl[0],gd_hd_per_pl[0],gd_hd_ant_pl[0],'  For '+tdate[0]+', Probe '+scu[0] & $
PRINT,';;',bd_hd_par_pl[0],bd_hd_per_pl[0],bd_hd_ant_pl[0],'  For '+tdate[0]+', Probe '+scu[0]
;;         126           5           0  For 2008-07-14, Probe B
;;        1261        1382        1387  For 2008-07-14, Probe B
;;         303          88           6  For 2008-07-14, Probe C
;;         675         890         972  For 2008-07-14, Probe C
;;          37          20           1  For 2008-08-12, Probe C
;;         165         182         201  For 2008-08-12, Probe C

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot Eo and |¥| vs. various parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
WINDOW,1,RETAIN=2
WINDOW,2,RETAIN=2
WINDOW,3,RETAIN=2
;;  Setup margins
xmargin        = [20,15]
ymargin        = [6,2]
chsz           = 1.75
;;----------------------------------------------------------------------------------------
;;  Plot Eo and |¥| vs. smoothed |dB|/|Bo|
;;----------------------------------------------------------------------------------------
pk_av_md_str   = ['Peak','Avg.','Median']
xttl           = pk_av_md_str+' |dB|/|Bo| [smoothed]'
yttl           = 'Eo [eV]'
ttle           = 'Eo vs. '+pk_av_md_str+' |dB|/|Bo|'
gysubt         = '[Constraints Are Satisfied]'
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [5e-3,2e0]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [6e1,3e3]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:1,YTITLE:yttl,SUBTITLE:gysubt,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1,CHARSIZE:chsz}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr,'XRANGE',xrange,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE
xdat           = [[pk__db_Bo_sm],[avg_db_Bo_sm],[med_db_Bo_sm]]
ind            = LINDGEN(n_fits[0]) + 1L
xdat           = TEMPORARY(xdat[ind,*])
tt             = good_eo_str.X
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
ydat           = ABS(good_eo_str.Y[sp,*])

WSET,1
WSHOW,1
!P.MULTI       = [0,1,3]
FOR pamv=0L, 2L DO BEGIN                                                        $
  PLOT,xdat[*,pamv],ydat[*,0],_EXTRA=pstr,XTITLE=xttl[pamv],TITLE=ttle[pamv]  & $
    FOR k=0L, 2L DO OPLOT,xdat[*,pamv],ydat[*,k],COLOR=vec_col[k],PSYM=2
!P.MULTI       = 0


yttl           = '|gamma| [or |B| fit parameter]'
gysubt         = '[Constraints Are Satisfied]'
ttle           = '|gamma| vs. '+pk_av_md_str+' |dB|/|Bo|'
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [1e-3,2e0]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [0e0,2e0]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:0,YTITLE:yttl,SUBTITLE:gysubt,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1,CHARSIZE:chsz}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr,'XRANGE',xrange,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

xdat           = [[pk__db_Bo_sm],[avg_db_Bo_sm],[med_db_Bo_sm]]
ind            = LINDGEN(n_fits[0]) + 1L
xdat           = TEMPORARY(xdat[ind,*])
tt             = good_pl_str.X
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
ydat           = ABS(good_pl_str.Y[sp,*])

WSET,2
WSHOW,2
!P.MULTI       = [0,1,3]
FOR pamv=0L, 2L DO BEGIN                                                        $
  PLOT,xdat[*,pamv],ydat[*,0],_EXTRA=pstr,XTITLE=xttl[pamv],TITLE=ttle[pamv]  & $
    FOR k=0L, 2L DO OPLOT,xdat[*,pamv],ydat[*,k],COLOR=vec_col[k],PSYM=2
!P.MULTI       = 0


yttl           = '|gamma| [or |B| fit parameter]'
gysubt         = '[Constraints Not Satisfied]'
ttle           = '|gamma| vs. '+pk_av_md_str+' |dB|/|Bo|'
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [1e-3,2e0]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [0e0,3e0]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:0,YTITLE:yttl,SUBTITLE:gysubt,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1,CHARSIZE:chsz}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr,'XRANGE',xrange,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

xdat           = [[pk__db_Bo_sm],[avg_db_Bo_sm],[med_db_Bo_sm]]
ind            = LINDGEN(n_fits[0]) + 1L
xdat           = TEMPORARY(xdat[ind,*])
tt             = bad__pl_str.X
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
ydat           = ABS(bad__pl_str.Y[sp,*])

WSET,3
WSHOW,3
!P.MULTI       = [0,1,3]
FOR pamv=0L, 2L DO BEGIN                                                        $
  PLOT,xdat[*,pamv],ydat[*,0],_EXTRA=pstr,XTITLE=xttl[pamv],TITLE=ttle[pamv]  & $
    FOR k=0L, 2L DO OPLOT,xdat[*,pamv],ydat[*,k],COLOR=vec_col[k],PSYM=2
!P.MULTI       = 0


yttl           = '|gamma| [or |B| fit parameter]'
gysubt         = '[All Values]'
ttle           = '|gamma| vs. '+pk_av_md_str+' |dB|/|Bo|'
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [1e-3,2e0]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [0e0,3e0]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:0,YTITLE:yttl,SUBTITLE:gysubt,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1,CHARSIZE:chsz}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr,'XRANGE',xrange,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

xdat           = [[pk__db_Bo_sm],[avg_db_Bo_sm],[med_db_Bo_sm]]
ind            = LINDGEN(n_fits[0]) + 1L
xdat           = TEMPORARY(xdat[ind,*])
tt             = unix_sten[*,0]
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
ydat           = ABS(REFORM(fit_params[*,1,*]))

WSET,3
WSHOW,3
!P.MULTI       = [0,1,3]
FOR pamv=0L, 2L DO BEGIN                                                        $
  PLOT,xdat[*,pamv],ydat[*,0],_EXTRA=pstr,XTITLE=xttl[pamv],TITLE=ttle[pamv]  & $
    FOR k=0L, 2L DO OPLOT,xdat[*,pamv],ydat[*,k],COLOR=vec_col[k],PSYM=2
!P.MULTI       = 0


yttl           = 'Eo [eV]'
gysubt         = '[All Values]'
ttle           = 'Eo vs. '+pk_av_md_str+' |dB|/|Bo|'
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [1e-3,2e0]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [1e1,3e3]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:1,YTITLE:yttl,SUBTITLE:gysubt,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1,CHARSIZE:chsz}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr,'XRANGE',xrange,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

xdat           = [[pk__db_Bo_sm],[avg_db_Bo_sm],[med_db_Bo_sm]]
ind            = LINDGEN(n_fits[0]) + 1L
xdat           = TEMPORARY(xdat[ind,*])
tt             = unix_sten[*,0]
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
ydat           = 1d0/ABS(REFORM(fit_params[*,2,*]))

WSET,3
WSHOW,3
!P.MULTI       = [0,1,3]
FOR pamv=0L, 2L DO BEGIN                                                        $
  PLOT,xdat[*,pamv],ydat[*,0],_EXTRA=pstr,XTITLE=xttl[pamv],TITLE=ttle[pamv]  & $
    FOR k=0L, 2L DO OPLOT,xdat[*,pamv],ydat[*,k],COLOR=vec_col[k],PSYM=2
!P.MULTI       = 0

;;----------------------------------------------------------------------------------------
;;  Plot Eo and |¥| vs. Mach numbers
;;----------------------------------------------------------------------------------------
;;  Define defaults
xttl           = 'M_'+['A','Cs','MS']+' [Mach Number = Vsw/V_j]'
yttl           = 'Eo [eV]'
gysubt         = '[Constraints Are Satisfied]'
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [1e-2,5e1]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yrange = [6e1,5e3]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [1e-1,3e1]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [6e1,3e3]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:1,YTITLE:yttl,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1,CHARSIZE:chsz}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr,'XRANGE',xrange,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

tt             = good_eo_str.X
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
xdat           = resample_2d_vec(mach_struc.Y,mach_struc.X,tt,/NO_EXTRAPOLATE)
ydat           = ABS(good_eo_str.Y[sp,*])

WSET,1
WSHOW,1
!P.MULTI       = [0,1,3]
FOR mach=0L, 2L DO BEGIN                                                       $
  PLOT,xdat[*,mach],ydat[*,0],_EXTRA=pstr,SUBTITLE=gysubt,XTITLE=xttl[mach]  & $
    FOR k=0L, 2L DO OPLOT,xdat[*,mach],ydat[*,k],COLOR=vec_col[k],PSYM=2
!P.MULTI       = 0


xttl           = 'M_'+['A','Cs','MS']+' [Mach Number = Vsw/V_j]'
yttl           = '|gamma| [or |B| fit parameter]'
gysubt         = '[Constraints Are Satisfied]'
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [1e-2,5e1]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yrange = [0e0,2e0]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [1e-1,3e1]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [0e0,3e0]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:0,YTITLE:yttl,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1,CHARSIZE:chsz}
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

tt             = good_pl_str.X
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
xdat           = resample_2d_vec(mach_struc.Y,mach_struc.X,tt,/NO_EXTRAPOLATE)
ydat           = ABS(good_pl_str.Y[sp,*])

WSET,2
WSHOW,2
!P.MULTI       = [0,1,3]
FOR mach=0L, 2L DO BEGIN                                                       $
  PLOT,xdat[*,mach],ydat[*,0],_EXTRA=pstr,SUBTITLE=gysubt,XTITLE=xttl[mach]  & $
    FOR k=0L, 2L DO OPLOT,xdat[*,mach],ydat[*,k],COLOR=vec_col[k],PSYM=2
!P.MULTI       = 0


xttl           = 'M_'+['A','Cs','MS']+' [Mach Number = Vsw/V_j]'
yttl           = '|gamma| [or |B| fit parameter]'
gysubt         = '[Constraints Are Satisfied]'
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [1e-2,5e1]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yrange = [0e0,2e0]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [1e-1,3e1]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [1e-2,5e0]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:1,YTITLE:yttl,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1,CHARSIZE:chsz}
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

tt             = good_pl_str.X
sp             = SORT(tt)
tt             = TEMPORARY(tt[sp])
xdat           = resample_2d_vec(mach_struc.Y,mach_struc.X,tt,/NO_EXTRAPOLATE)
ydat           = ABS(good_pl_str.Y[sp,*])

WSET,3
WSHOW,3
!P.MULTI       = [0,1,3]
FOR mach=0L, 2L DO BEGIN                                                       $
  PLOT,xdat[*,mach],ydat[*,0],_EXTRA=pstr,SUBTITLE=gysubt,XTITLE=xttl[mach]  & $
    FOR k=0L, 2L DO OPLOT,xdat[*,mach],ydat[*,k],COLOR=vec_col[k],PSYM=2
!P.MULTI       = 0


;;----------------------------------------------------------------------------------------
;;  Plot Eo vs. |¥|
;;----------------------------------------------------------------------------------------

;;  Define defaults
xttl           = '|gamma| [or |B| fit parameter]'
yttl           = 'Eo [eV]'
gysubt         = '[Constraints Are Satisfied]'

;IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [1e-3,2e0]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [0e0,2e0]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yrange = [6e1,5e3]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [0e0,2e0]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [6e1,3e3]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:0,YLOG:1,XTITLE:xttl,YTITLE:yttl,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr,'XRANGE',xrange,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

sp             = SORT(good_pl_str.X)
xdat           = ABS(good_pl_str.Y[sp,*])
sp             = SORT(good_eo_str.X)
ydat           = ABS(good_eo_str.Y[sp,*])

WSET,1
WSHOW,1
  PLOT,xdat[*,0],ydat[*,0],_EXTRA=pstr,SUBTITLE=gysubt
    FOR k=0L, 2L DO OPLOT,xdat[*,k],ydat[*,k],COLOR=vec_col[k],PSYM=2



bysubt         = '[Constraints Not Satisfied]'
xttl2          = 'gamma [or B fit parameter]'
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrang2 = [-4e0,1e0]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yrang2 = [1e1,5e4]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [-4e0,1e0]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [6e1,3e3]
pstr2          = {XSTYLE:1,YSTYLE:1,XLOG:0,YLOG:1,XTITLE:xttl2,YTITLE:yttl,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr2,'XRANGE',xrang2,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr2,'YRANGE',yrang2,/ADD_REPLACE

sp             = SORT(bad__pl_str.X)
xdat           =      bad__pl_str.Y[sp,*]
sp             = SORT(bad__Eo_str.X)
ydat           =  ABS(bad__Eo_str.Y[sp,*])

WSET,2
WSHOW,2
  PLOT,xdat[*,0],ydat[*,0],_EXTRA=pstr2,SUBTITLE=bysubt
    FOR k=0L, 2L DO OPLOT,xdat[*,k],ydat[*,k],COLOR=vec_col[k],PSYM=2





;;  Define defaults
xttl           = '|gamma| [or |B| fit parameter]'
yttl           = 'Eo [eV]'
gysubt         = '[Constraints Are Satisfied]'
bysubt         = '[Constraints Not Satisfied]'

;IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [1e-3,2e0]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN xrange = [1e-2,2e0]
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN yrange = [6e1,5e3]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN xrange = [1e-2,2e0]
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN yrange = [6e1,3e3]
pstr           = {XSTYLE:1,YSTYLE:1,XLOG:1,YLOG:1,XTITLE:xttl,YTITLE:yttl,$
                  XMARGIN:xmargin,YMARGIN:ymargin,NODATA:1}
IF (N_ELEMENTS(xrange) EQ 2) THEN str_element,pstr,'XRANGE',xrange,/ADD_REPLACE
IF (N_ELEMENTS(yrange) EQ 2) THEN str_element,pstr,'YRANGE',yrange,/ADD_REPLACE

sp             = SORT(good_pl_str.X)
xdat           = ABS(good_pl_str.Y[sp,*])
sp             = SORT(good_eo_str.X)
ydat           = ABS(good_eo_str.Y[sp,*])

WSET,3
WSHOW,3
  PLOT,xdat[*,0],ydat[*,0],_EXTRA=pstr,SUBTITLE=gysubt
    FOR k=0L, 2L DO OPLOT,xdat[*,k],ydat[*,k],COLOR=vec_col[k],PSYM=2

















