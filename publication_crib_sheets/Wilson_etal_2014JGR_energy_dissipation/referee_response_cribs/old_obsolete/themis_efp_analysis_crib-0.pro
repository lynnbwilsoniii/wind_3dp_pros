;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

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
R_E            = 6.37814d3            ;;  Earth's Equitorial Radius [km]
;;----------------------------------------------------------------------------------------
;;  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  2009-09-26 [1 Crossing]
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
;;  Example waveform times
tr_ww          = time_double(tdate[0]+'/'+['15:53:02.500','15:53:15.600'])
tr_esw0        = time_double(tdate[0]+'/'+['15:53:03.475','15:53:03.500'])  ;;  train of ESWs [efw, Int. 0]
tr_esw1        = time_double(tdate[0]+'/'+['15:53:04.474','15:53:04.503'])  ;;  train of ESWs [efw, Int. 0]
tr_esw2        = time_double(tdate[0]+'/'+['15:53:09.910','15:53:09.940'])  ;;  two      ESWs [efw, Int. 1]
tr_whi         = time_double(tdate[0]+'/'+['15:53:10.860','15:53:11.203'])  ;;  example whistlers [scw, Int. 1]
tr_ww1         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:15.590'])
tr_ww2         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:12.500'])
;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scu            = STRUPCASE(sc[0])
prefu          = STRUPCASE(pref[0])
scpref         = 'th'+sc[0]+'_'

themis_load_all_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00)
;;----------------------------------------------------------------------------------------
;;  Correct ion bulk flow velocities
;;----------------------------------------------------------------------------------------
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
ion_mid_nm     = 'peib_velocity_'
vsw_nm_dsl     = tnames(scpref[0]+ion_mid_nm[0]+coord_dsl[0])
vsw_nm_gse     = tnames(scpref[0]+ion_mid_nm[0]+coord_gse[0])
vsw_nm_gsm     = tnames(scpref[0]+ion_mid_nm[0]+coord_gsm[0])

;;  Get TPLOT data
get_data,vsw_nm_gse[0],DATA=ti_vsw,DLIM=dlim,LIM=lim
vbulk          = ti_vsw.Y
;;  Define components of V_new
smvx           = vbulk[*,0]
smvy           = vbulk[*,1]
smvz           = vbulk[*,2]

;;  Corrected GSE velocities
bind           = [0431L,0432L,0433L,0434L,0435L,0436L,0437L,0438L,0439L,0440L,0441L,0442L,0443L,0444L,0445L,0446L,0447L,0448L,0449L,0450L,0451L,0452L,0453L,0454L,0455L,0456L,0457L,0458L,0459L,0460L,0461L,0462L,0463L,0464L,0465L,0466L,0467L,0468L,0469L,0470L,0471L,0472L]
vswx_fix_2     = [-137.9495d0,-110.2283d0,-105.3032d0,-105.9883d0, -71.2267d0,-102.2990d0,-109.5847d0, -66.4465d0, -75.5031d0, -87.8034d0,-100.6902d0, -95.5636d0, -83.2152d0, -80.4176d0, -61.3938d0,-268.7820d0,-228.2926d0,-175.1602d0,-145.4946d0, -72.1457d0,-208.7206d0,-225.9606d0, -58.1883d0,-209.6236d0,-185.5990d0,-242.4396d0,-227.9896d0,-206.2243d0,-281.9052d0,-246.9158d0,-275.3937d0,-293.4430d0,-276.7850d0,-288.7143d0,-289.0691d0,-293.1015d0,-307.5211d0,-295.7074d0,-302.7530d0,-311.4771d0,-300.4407d0,-304.2030d0]
vswy_fix_2     = [  75.6631d0, -14.8001d0,  50.6739d0,  95.4643d0,  35.3232d0,  52.1533d0,   9.4318d0,  18.5063d0,  36.7798d0,   6.7589d0, -14.2377d0,  14.5795d0,   8.9486d0,  30.5933d0, -11.2194d0, -52.9654d0, -59.7955d0, -86.4655d0,-114.5890d0, -78.5700d0,-126.2231d0, -34.1284d0,  86.0834d0, -44.8225d0, -42.6352d0, -53.9310d0, -36.0743d0, -38.2412d0,  51.1507d0, -26.6392d0,  44.2013d0,  31.3775d0,  78.9969d0,  83.1941d0,  86.6903d0,  79.7859d0,  71.0870d0,  82.1187d0,  72.7096d0,  58.5958d0,  71.0253d0,  69.0152d0]
vswz_fix_2     = [ 96.1632d0, 62.1760d0, 44.9703d0, 21.9975d0, 21.8700d0, 14.2218d0, 42.6332d0, 36.8999d0, -2.6429d0,  1.5962d0, 25.8590d0, 40.1858d0, -2.0704d0,  5.9990d0,  6.3821d0, 26.8731d0, 16.4429d0, -5.4312d0, 22.0415d0, 26.1776d0,-29.3434d0, 42.9462d0, -4.0278d0, 28.0028d0,-30.3545d0, 37.2253d0, 39.8258d0, 42.6363d0, 20.9123d0, 35.1928d0, 45.4029d0,  5.9471d0, 35.6257d0, 25.2030d0, 29.5523d0, 27.5498d0, 15.1370d0, 25.8282d0, 14.3992d0, 29.6708d0, 28.4041d0, 28.4948d0]

;; Replace "bad" values
smvx[bind]     = vswx_fix_2
smvy[bind]     = vswy_fix_2
smvz[bind]     = vswz_fix_2
smvel3         = [[smvx],[smvy],[smvz]]

;;  Send corrected GSE velocities to TPLOT
vnew_str       = {X:ti_vsw.X,Y:smvel3}                            ;;  TPLOT structure
vname_n3       = vsw_nm_gse[0]+'_fixed_3'                         ;;  TPLOT handle
yttl           = 'V!Dbulk!N [km/s, '+STRUPCASE(coord_gse[0])+']'  ;;  Y-Axis title
ysubt          = '[Shifted to DF Peak, 3s]'                       ;;  Y-Axix subtitle
str_element,dlim,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim,'YSUBTITLE',ysubt[0],/ADD_REPLACE
store_data,vname_n3[0],DATA=vnew_str

;;  Rotate corrected GSE velocities to DSL and GSM
new_out_nms    = [vsw_nm_dsl[0],vsw_nm_gsm[0]]+'_fixed_3'
thm_cotrans,vname_n3[0],new_out_nms[0],IN_COORD=coord_gse[0],OUT_COORD=coord_dsl[0]
thm_cotrans,vname_n3[0],new_out_nms[1],IN_COORD=coord_gse[0],OUT_COORD=coord_gsm[0]

;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'
;;  Use default colors
all_coords     = [coord_dsl[0],coord_gse[0],coord_gsm[0]]
FOR j=0L, N_ELEMENTS(all_coords) - 1L DO BEGIN       $
  options,tnames('*_'+all_coords[j]+'*'),'COLORS'  & $
  options,tnames('*_'+all_coords[j]+'*'),'COLORS',[250,150, 50],/DEF

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;;  Fix Y-Axis subtitles
;;----------------------------------------------------------------------------------------
scpref         = 'th'+sc[0]+'_'

coord_dsl      = 'dsl'
modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm+'_'
fgm_mag        = tnames(fgm_pren[*]+'mag')
fgm_dsl        = tnames(fgm_pren[*]+coord_dsl[0])

tplot,fgm_mag
;;----------------------------------------------------------------------------------------
;;  Load E&B-Fields
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
;;----------------------------------------------------------------------------------------
;;  Try removing DC-offsets from efw
;;----------------------------------------------------------------------------------------
coord_dsl      = 'dsl'
modes_efi      = 'ef'+['p','w']
modes_scm      = 'sc'+['p','w']
efi_midnm      = '_cal_'
scm_midnm      = '_cal_'
;;  EFI TPLOT handles
efp_names      = tnames(pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0]+'*')
efw_names      = tnames(pref[0]+modes_efi[1]+efi_midnm[0]+coord_dsl[0]+'*')
;;  SCM TPLOT handles
scp_names      = tnames(pref[0]+modes_scm[0]+scm_midnm[0]+coord_dsl[0]+'*')
scw_names      = tnames(pref[0]+modes_scm[1]+scm_midnm[0]+coord_dsl[0]+'*')

;;  Get EFI data
get_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp
;;  Define parameters
efp_t          = temp_efp.X
efp_v          = temp_efp.Y
;;  1st remove any DC-offsets from efw
sratefp        = DOUBLE(sample_rate(efp_t,GAP_THRESH=6d0,/AVE))
se_pels        = t_interval_find(efp_t,GAP_THRESH=4d0/sratefp[0])
pint           = N_ELEMENTS(se_pels[*,0])

;;  Smooth and then remove DC-offsets
mxpts          = 50L
efp_v_nodc     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $  ;; stay away from end pts
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  t_efpvx  = SMOOTH(efp_v[inds,0],10L,/NAN,/EDGE_TRUNCATE)                           & $
  t_efpvy  = SMOOTH(efp_v[inds,1],10L,/NAN,/EDGE_TRUNCATE)                           & $
  t_efpvz  = SMOOTH(efp_v[inds,2],10L,/NAN,/EDGE_TRUNCATE)                           & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  avgs     = [MEAN(t_efpv[*,0],/NAN),MEAN(t_efpv[*,1],/NAN),MEAN(t_efpv[*,2],/NAN)]  & $
  FOR k=0L, 2L DO efp_v_nodc[inds,k] = efp_v[inds,k] - avgs[k]


;;  Send efp without DC-offsets to TPLOT
efi_nodcnm     = '_cal_rmDCoffsets_'
rmDC_nm        = 'efp(rm DC-offsets)'
nodc_tpnm      = pref[0]+modes_efi[0]+efi_nodcnm[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+rmDC_nm[0]+', '+coord_up[0]+', mV/m]'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:efp_t,Y:efp_v_nodc}
store_data,nodc_tpnm[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

;;----------------------------------------------------------------------------------------
;;  Perform high and low pass filters
;;----------------------------------------------------------------------------------------
;;--------------------------------------------
;;  EFI data
;;--------------------------------------------
lowf0          = 1d-2
lowf1          = 1d1
midf           = 1d1
higf           = 1d5   ;;  Set well above Nyquist frequency
;;  Define the sample rate
srate          = sratefp[0]
;;  Define strings associated with sample rates and filters
cutf_str       = STRTRIM(STRING(lowf0[0],FORMAT='(f10.2)'),2L)
sr_str         = STRTRIM(STRING(srate[0],FORMAT='(I)'),2L)
lowf_str       = STRTRIM(STRING(lowf1[0],FORMAT='(I)'),2L)
midf_str       = STRTRIM(STRING(midf[0],FORMAT='(I)'),2L)
;;  Define dummy arrays
efp_v_lowp     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
efp_v_higp     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  t_efpv   = efp_v_nodc[se_pels[j,0]:se_pels[j,1],*]                                 & $
  vec_lp   = vector_bandpass(t_efpv,srate[0],lowf0[0],lowf1[0],/MIDF)                & $
  vec_hp   = vector_bandpass(t_efpv,srate[0],midf[0],higf[0],/MIDF)                  & $
  efp_v_lowp[se_pels[j,0]:se_pels[j,1],*] = vec_lp                                   & $
  efp_v_higp[se_pels[j,0]:se_pels[j,1],*] = vec_hp

;;  Define TPLOT handles
efi_midnm      = '_cal_rmDCoffsets_'
low__suffx     = '_LowPassFilt_'+cutf_str[0]+'-'+lowf_str[0]+'Hz'
high_suffx     = '_HighPassFilt_'+midf_str[0]+'Hz'
low__tpnm      = pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0]+low__suffx[0]
high_tpnm      = pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0]+high_suffx[0]
;;  Define new subtitles
coord_up       = STRUPCASE(coord_dsl[0])
rmDC_nm        = 'efp(rm DC-offsets)'
yttl           = 'E ['+rmDC_nm[0]+', '+coord_up[0]+', mV/m]'
yttl_sub_lp    = '['+sr_str[0]+' sps, LP: '+lowf_str[0]+'Hz]'
yttl_sub_hp    = '['+sr_str[0]+' sps, HP: '+midf_str[0]+'Hz]'

str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
str_element,dlim_efp,'YSUBTITLE',yttl_sub_lp[0],/ADD_REPLACE
struct         = {X:efp_t,Y:efp_v_lowp}
store_data,low__tpnm[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

str_element,dlim_efp,'YSUBTITLE',yttl_sub_hp[0],/ADD_REPLACE
struct         = {X:efp_t,Y:efp_v_higp}
store_data,high_tpnm[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

;;  Add note to explain 0.01 Hz cutoff at low end
cutf_str       = STRTRIM(STRING(lowf0[0],FORMAT='(I)'),2L)
opt_snm        = 'DATA_ATT.NOTE_FILT'
opt_str_lp     = '[Filtered:  '+cutf_str[0]+'-'+lowf_str[0]+' Hz]'
opt_str_hp     = '[Filtered:  >'+midf_str[0]+' Hz]'
nna            = [low__tpnm[0],high_tpnm[0]]
options,nna[0],opt_snm[0],opt_str_lp[0],/DEF
options,nna[1],opt_snm[0],opt_str_hp[0],/DEF

;;  Remove "spikes" and edge-effects by hand
nna            = [low__tpnm[0],high_tpnm[0]]
kill_data_tr,NAMES=nna
;;----------------------------------------------------------------------------------------
;;  Try detrending the data
;;----------------------------------------------------------------------------------------

;;  Smooth data
mxpts          =  0L
smpts          = 10L      ;;  # of points to smooth
efp_v_smth     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  t_efpvx  = SMOOTH(efp_v[inds,0],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpvy  = SMOOTH(efp_v[inds,1],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpvz  = SMOOTH(efp_v[inds,2],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  FOR k=0L, 2L DO efp_v_smth[inds,k] = t_efpv[*,k]

;;  Subtract smoothed data from original
diff_efp       = efp_v - efp_v_smth

;;  Send detrended efp to TPLOT
efi_smthnm     = '_cal_detrended_'
rmDC_nm        = 'efp(detrended)'
smth_tpnm      = pref[0]+modes_efi[0]+efi_smthnm[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+rmDC_nm[0]+', '+coord_up[0]+', mV/m]'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:efp_t,Y:diff_efp}
store_data,smth_tpnm[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp


;;----------------------------------------------------------------------------------------
;;  Use derivative to find and remove "spikes"
;;----------------------------------------------------------------------------------------
vec_t          = efp_t
vec_v          = diff_efp
mxpts          =  0L
efp_v_dEdt     = REPLICATE(d,SIZE(efp_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  t_efpvx  = DERIV(vec_t[inds],vec_v[inds,0])                                        & $
  t_efpvy  = DERIV(vec_t[inds],vec_v[inds,1])                                        & $
  t_efpvz  = DERIV(vec_t[inds],vec_v[inds,2])                                        & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  FOR k=0L, 2L DO efp_v_dEdt[inds,k] = t_efpv[*,k]

;;  Send derivative of efp to TPLOT
efi_dEdtnm     = '_cal_detrended_dEdt_'
rmDC_nm        = 'efp(detrended --> dE/dt)'
dEdt_tpnm      = pref[0]+modes_efi[0]+efi_dEdtnm[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+rmDC_nm[0]+', '+coord_up[0]+', mV/m]'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:vec_t,Y:efp_v_dEdt}
store_data,dEdt_tpnm[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

;;  Get EFI data
get_data,nodc_tpnm[0],DATA=temp_efp_nodc,DLIM=dlim_efp_nodc,LIM=lim_efp_nodc
get_data,dEdt_tpnm[0],DATA=temp_efp_dEdt,DLIM=dlim_efp_dEdt,LIM=lim_efp_dEdt
;;  Define parameters
efp_nodc_t     = temp_efp_nodc.X
efp_nodc_v     = temp_efp_nodc.Y
efp_dEdt_t     = temp_efp_dEdt.X
efp_dEdt_v     = temp_efp_dEdt.Y

;;  Define "bad" regions
despiked_efp_v = efp_nodc_v
thsh_noDC      = 5d1
thsh_dEdt      = 2d1
test_dEdt      = (ABS(efp_dEdt_v[*,0]) GE thsh_dEdt[0]) OR $
                 (ABS(efp_dEdt_v[*,1]) GE thsh_dEdt[0])
test_noDC      = (ABS(efp_nodc_v[*,0]) GE thsh_noDC[0]) OR $
                 (ABS(efp_nodc_v[*,1]) GE thsh_noDC[0])
test           = test_dEdt OR test_noDC
bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
PRINT, ';;  ', bd, gd
;;         72919      240937

;;  Set "bad" regions to NaNs
IF (bd GT 0) THEN despiked_efp_v[bad,0L:1L] = d

;;  Send de-spiked efp, without DC-offsets, to TPLOT
efi_despke     = '_cal_rmDCoffsets_despiked_'
despke_nm      = 'efp(rm DC-offsets --> de-spiked)'
despke_tp      = pref[0]+modes_efi[0]+efi_despke[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+despke_nm[0]+', '+coord_up[0]+', mV/m]'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:efp_nodc_t,Y:despiked_efp_v}
store_data,despke_tp[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp


;;  Remove remaining "spikes" and edge-effects by hand
nna            = [despke_tp[0]]
kill_data_tr,NAMES=nna

;;----------------------------------------------------------------------------------------
;;  Smooth de-spiked efp and use to detrend
;;----------------------------------------------------------------------------------------
vec_t          = efp_nodc_t
vec_v          = despiked_efp_v
;;  Linearly interpolate NaNs
;;  Use a cubic spline to interpolate NaNs
IF (gd GT 0) THEN t_efpvx = remove_nans(vec_t,vec_v[*,0],/NO_EXTRAPOLATE,/SPLINE)
IF (gd GT 0) THEN t_efpvy = remove_nans(vec_t,vec_v[*,1],/NO_EXTRAPOLATE,/SPLINE)
IF (gd GT 0) THEN t_efpvz = remove_nans(vec_t,vec_v[*,2],/NO_EXTRAPOLATE,/SPLINE)
IF (gd GT 0) THEN t_efpv  = [[t_efpvx],[t_efpvy],[t_efpvz]]
IF (gd GT 0) THEN vec_v   = t_efpv

mxpts          =  0L
smpts          = 32L      ;;  # of points to smooth
nsms           = STRING(FORMAT='(I3.3)',smpts[0])
sm_suffx       = nsms[0]+'pts'
despk_sm_efp_v = REPLICATE(d,SIZE(vec_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  t_efpvx  = SMOOTH(vec_v[inds,0],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpvy  = SMOOTH(vec_v[inds,1],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpvz  = SMOOTH(vec_v[inds,2],smpts[0],/NAN,/EDGE_TRUNCATE)                      & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  FOR k=0L, 2L DO despk_sm_efp_v[inds,k] = t_efpv[*,k]

;;  Send smoothed de-spiked efp, without DC-offsets, to TPLOT
efi_despksm    = '_cal_rmDCoffsets_despiked_sm'+sm_suffx[0]+'_'
despksm_nm     = 'efp(rm DC --> de-spiked, Sm:'+sm_suffx[0]+')'
despksm_tp     = pref[0]+modes_efi[0]+efi_despksm[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+coord_up[0]+', mV/m]'+'!C'+'['+despksm_nm[0]+']'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:vec_t,Y:despk_sm_efp_v}
store_data,despksm_tp[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

tplot,[38,30,109,115,117,120,122,123]
;;----------------------------------------------------------------------------------------
;;  Determine spin phase
;;----------------------------------------------------------------------------------------
state_midnm    = 'state_'
sp_per_suff    = state_midnm[0]+'spinper'
sp_phs_suff    = state_midnm[0]+'spinphase'
sp_per_tpnm    = tnames(scpref[0]+sp_per_suff[0])
sp_phs_tpnm    = tnames(scpref[0]+sp_phs_suff[0])

;;  Force Y-Range of spin phase to -5 -> 365
options,sp_phs_tpnm[0],'YRANGE',[-5d0,365d0],/DEF

;;  Get EFI data
get_data,efp_names[0],DATA=temp_efp,DLIM=dlim_efp,LIM=lim_efp

;;  Get spin phase and period
get_data,sp_per_tpnm[0],DATA=temp_sp_per,DLIM=dlim_sp_per,LIM=lim_sp_per
get_data,sp_phs_tpnm[0],DATA=temp_sp_phs,DLIM=dlim_sp_phs,LIM=lim_sp_phs

;;  Define parameters
efp_t          = temp_efp.X
efp_v          = temp_efp.Y
sp_per_t       = temp_sp_per.X
sp_per_v       = temp_sp_per.Y
sp_phs_t       = temp_sp_phs.X
sp_phs_v       = temp_sp_phs.Y
;;  Define spin rate [deg s^(-1)]
fac            = 36d1
spin_rate      = fac[0]/sp_per_v

;;  Interpolate spin phase
model          = spinmodel_get_ptr(sc[0],USE_ECLIPSE_CORRECTIONS=use_eclipse_corrections)
spinmodel_interp_t,MODEL=model,TIME=efp_t,SPINPHASE=phase,SPINPER=spinper,USE_SPINPHASE_CORRECTION=1       ;a la J. L.
;;  Send to TPLOT
spphs_int_tpnm = tnames(sp_phs_tpnm[0])+'_int'
struct         = {X:efp_t,Y:phase}
store_data,spphs_int_tpnm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
yttl           = STRUPCASE(sc[0])+' Spin Phase'+'!C'+'[interpolated to efp]'
options,spphs_int_tpnm[0],'YTITLE'
options,spphs_int_tpnm[0],'YTITLE',yttl[0],/DEF
options,spphs_int_tpnm[0],'YRANGE',[-5d0,365d0],/DEF

nnw            = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01


;;  Find derivative of spin phase
new_t          = efp_t
new_v          = phase
dT_dt          = DERIV(new_t,new_v)

;;  Clean up first
DELVAR,neg_1st,gdneg1,pos_1st,gdpos1,last
;;  Find where f'(t) < 0  --> compare magnitude to pts where f'(t) > 0
last           = 0L
FOR j=0L, pint - 1L DO BEGIN                                                           $
  test           = (dT_dt[se_pels[j,0]:se_pels[j,1]] LT 0)                           & $
  tneg           = WHERE(test,gdn1,COMPLEMENT=tpos,NCOMPLEMENT=gdp1)                 & $
  tneg          += last[0]                                                           & $
  tpos          += last[0]                                                           & $
  IF (j EQ 0) THEN neg_1st = tneg ELSE neg_1st = [neg_1st,tneg]                      & $
  IF (j EQ 0) THEN pos_1st = tpos ELSE pos_1st = [pos_1st,tpos]                      & $
  IF (j EQ 0) THEN gdneg1  = gdn1[0] ELSE gdneg1 += gdn1[0]                          & $
  IF (j EQ 0) THEN gdpos1  = gdp1[0] ELSE gdpos1 += gdp1[0]                          & $
  last          += N_ELEMENTS(dT_dt[se_pels[j,0]:se_pels[j,1]])                      & $
  PRINT,'gdn1 = ', gdn1[0], ' gdp1 = ', gdp1[0]

PRINT, ';;  ', gdneg1, gdpos1
;;          1618      312238

;test           = (dT_dt LT 0)
;neg_1st        = WHERE(test,gdneg1,COMPLEMENT=pos_1st,NCOMPLEMENT=gdpos1)
;PRINT, ';;  ', gdneg1, gdpos1
;;;          1618      312238

;;  Send derivative to TPLOT
dTdt_spphs_nm  = sp_phs_tpnm[0]+'_dTdt'
yttl           = 'dT/dt'+'!C'+'[slope of spin phase]'
str_element,dlim_sp_phs,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:new_t,Y:dT_dt}
store_data,dTdt_spphs_nm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
;options,dTdt_spphs_nm[0],'YRANGE',[-1d0,1d0]*2d0,/DEF


;;  Define intervals
;new_t          = efp_t
;new_v          = dT_dt
;IF (gdneg1 GT 0) THEN new_v[neg_1st] = d
;IF (gdneg1 GT 0) THEN new_t[neg_1st] = d

;;----------------------------------------------------------------------------------------
;;  Turn sawtooth into straight line
;;----------------------------------------------------------------------------------------
sratefp        = DOUBLE(sample_rate(new_t,GAP_THRESH=6d0,/AVE))
n_efp          = N_ELEMENTS(efp_t)
se             = [0L,n_efp - 1L]
a_ind          = DINDGEN(n_efp)
;IF (gdneg1 GT 0) THEN FOR j=0L, gdneg1 - 1L DO a_ind[neg_1st[j]:se[1]] += 5d0
se_sphase0     = t_interval_find(a_ind[pos_1st],GAP_THRESH=1d0)
;;  Make sure this is indexed correctly
n_spint        = N_ELEMENTS(se_sphase0[*,1])
t_sphs         = pos_1st[se_sphase0]
;;  Redefine intervals
se_sphase      = t_sphs
n_spint        = N_ELEMENTS(se_sphase[*,1])
se_sphase[0L:(n_spint - 2L),1L] += 1L
se_sphase[1L:(n_spint - 1L),0L] -= 1L

diff           = se_sphase[*,0] - SHIFT(se_sphase[*,1],1)
diff[0]        = 0L
n_inds         = se_sphase[*,1] - se_sphase[*,0] + 1L  ;;  # of elements per interval

new_v          = phase
phase_line     = REPLICATE(d,n_efp)
phase_line     = new_v
;phase_line[se_sphase[0,0]:se_sphase[0,1]] = new_v[se_sphase[0,0]:se_sphase[0,1]]
FOR j=1L, n_spint - 1L DO BEGIN                                                        $
  last = j - 1L                                                                      & $
  lind = LINDGEN(n_inds[last]) + se_sphase[last,0]                                   & $
  gind = LINDGEN(n_inds[j]) + (se_sphase[last,1] + 1L)                               & $
;  gind = LINDGEN(n_inds[j] + diff[j] - 1L) + (se_sphase[last,1] + 1L)                & $
  check  = (MIN(gind,/NAN) - MAX(lind,/NAN))                                         & $
  IF (check LE 0) THEN PRINT,'bad j = ',j,' MAX - MIN = ',check                      & $
  mxlast  = MAX(phase_line[lind],/NAN)                                               & $
  mod360  = 36d1 - (mxlast[0] MOD 36d1)                                              & $
  mxlast += mod360[0]                                                                & $
  phase_line[gind] += mxlast[0]                                                      & $
  IF ((j MOD 50L) EQ 0) THEN PRINT,'mxlast = ',mxlast[0]


;;  Now that it works, create sine wave and use to detrend DC-Coupled E-field

wi,1
wset,1
tind = LINDGEN(10000L)
plot, phase_line[tind],/ylog,/xlog,xrange=[1d0,MAX(tind)]
;plot, phase_line,/ylog,/xlog,xrange=[1d0,313856d0]
  oplot,reform(se_sphase[1,*]),phase_line[reform(se_sphase[1,*])],color=250,psym=2


;;----------------------------------------------------------------------------------------
;;  Determine magnitude of original efp in DSL
;;----------------------------------------------------------------------------------------
coord_mag      = 'mag'
efi_nodcnm     = '_cal_rmDCoffsets_'
efi_midnm      = '_cal_'
efp_names      = tnames(pref[0]+modes_efi[0]+efi_midnm[0]+coord_dsl[0]+'*')
nodc_tpnm      = tnames(pref[0]+modes_efi[0]+efi_nodcnm[0]+coord_dsl[0])
efp_mag_tpnm   = pref[0]+modes_efi[0]+efi_midnm[0]+coord_mag[0]
PRINT, ';; ', efp_mag_tpnm[0] & PRINT, ';; ', efp_names[0]
;; tha_efp_cal_mag
;; tha_efp_cal_dsl

;;  Get EFI data [DSL]
get_data,efp_names[0],DATA=temp_e0,DLIM=dlim_e0,LIM=lim_e0
;;  Calcluate magnitude of vector
e0_vec         = temp_e0.Y
calc,'temp = "tha_efp_cal_dsl"^2'
e0_mag         = SQRT(TOTAL(temp,2,/NAN))
;;  Remove "spikes"
thsh_noDC      = 5d1
thsh_dEdt      = 2d1
test_dEdt      = (ABS(efp_dEdt_v[*,0]) GE thsh_dEdt[0]) OR $
                 (ABS(efp_dEdt_v[*,1]) GE thsh_dEdt[0])
test_noDC      = (ABS(efp_nodc_v[*,0]) GE thsh_noDC[0]) OR $
                 (ABS(efp_nodc_v[*,1]) GE thsh_noDC[0])
test           = test_dEdt OR test_noDC
bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
PRINT, ';;  ', bd, gd
;;         72919      240937

e1_mag         = e0_mag
IF (bd GT 0) THEN e1_mag[bad] = d

store_data,efp_mag_tpnm[0],DATA={X:temp_e0.X,Y:e1_mag},DLIM=dlim_e0,LIM=lim_e0
options,efp_mag_tpnm[0],'COLORS'
options,efp_mag_tpnm[0],'COLORS',/DEF
options,efp_mag_tpnm[0],'LABELS'
options,efp_mag_tpnm[0],'LABELS',/DEF

;;  Remove NaNs (linearly) and then kill original data that exceeds |Eo|
vec_t          = temp_e0.X
vec_v          = e1_mag
IF (gd GT 0) THEN t_efpmg = remove_nans(vec_t,vec_v,/NO_EXTRAPOLATE)

store_data,efp_mag_tpnm[0],DATA={X:vec_t,Y:t_efpmg},DLIM=dlim_e0,LIM=lim_e0
options,efp_mag_tpnm[0],'YTITLE','|Eo| [mV/m]',/DEF
options,efp_mag_tpnm[0],'COLORS'
options,efp_mag_tpnm[0],'COLORS',/DEF
options,efp_mag_tpnm[0],'LABELS'
options,efp_mag_tpnm[0],'LABELS',/DEF

;;  Remove remaining "spikes" and edge-effects by hand
nna            = [efp_mag_tpnm[0]]
kill_data_tr,NAMES=nna

;;  Retrieve de-spiked |Eo|
get_data,efp_mag_tpnm[0],DATA=temp_emag0,DLIM=dlim_emag0,LIM=lim_emag0
e2_mag         = temp_emag0.Y


test           = (e0_mag GT e2_mag) OR (FINITE(e2_mag) EQ 0)
bad_emag       = WHERE(test,bd_emag,COMPLEMENT=good_emag,NCOMPLEMENT=gd_emag)
PRINT, ';;  ', bd_emag, gd_emag
;;         46272      267584

;;  Set "bad" regions to NaNs
e1_vec         = e0_vec
IF (bd_emag GT 0) THEN e1_vec[bad_emag,0L:1L] = d

efi_despke2    = '_cal_despiked_'
despke_nm2     = 'efp(de-spiked)'
despke_tp2     = pref[0]+modes_efi[0]+efi_despke2[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+despke_nm2[0]+', '+coord_up[0]+', mV/m]'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
vec_t          = temp_e0.X
struct         = {X:vec_t,Y:e1_vec}
store_data,despke_tp2[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

;;----------------------------------------------------------------------------------------
;;  Calculate E_conv = - Vsw x Bo
;;----------------------------------------------------------------------------------------
efac           = -1d0*1d3*1d-9*1d3    ;;  km --> m, nT --> T, V --> mV
;;  Get Vsw data [DSL]
get_data,vsw_nm_dsl[0]+'_fixed_3',DATA=Vsw_dsl,DLIM=dlim_Vsw_dsl,LIM=lim_Vsw_dsl
;;  Get Bo data [DSL]
get_data,all_fgh_tpnm[1],DATA=fgh_dsl,DLIM=dlim_fgh_dsl,LIM=lim_fgh_dsl

;;  Define Vsw and Bo parameters
vsw_t          = Vsw_dsl.X
vsw_v          = Vsw_dsl.Y
fgh_t          = fgh_dsl.X
fgh_v          = fgh_dsl.Y
;;  Upsample Vsw to Bo times
up_vsw_x       = interp(vsw_v[*,0],vsw_t,fgh_t,/NO_EXTRAPOLATE)
up_vsw_y       = interp(vsw_v[*,1],vsw_t,fgh_t,/NO_EXTRAPOLATE)
up_vsw_z       = interp(vsw_v[*,2],vsw_t,fgh_t,/NO_EXTRAPOLATE)
up_vsw_v       = [[up_vsw_x],[up_vsw_y],[up_vsw_z]]
;;  Calculate E_conv = - Vsw x Bo
e_conv         = efac[0]*my_crossp_2(up_vsw_v,fgh_v,/NOM)

;;  Linearly interpolate NaNs
vec_t          = temp_e0.X
vec_v          = e1_vec
t_efpvx        = remove_nans(vec_t,vec_v[*,0],/NO_EXTRAPOLATE)
t_efpvy        = remove_nans(vec_t,vec_v[*,1],/NO_EXTRAPOLATE)
t_efpvz        = remove_nans(vec_t,vec_v[*,2],/NO_EXTRAPOLATE)
t_efpv         = [[t_efpvx],[t_efpvy],[t_efpvz]]

;;  Remove E_conv from observed Eo
e0_rest        = t_efpv - e_conv

;;  Send de-spiked efp, without E_conv, to TPLOT
efi_despke3    = '_cal_despiked_rmEconv_'
despke_nm3     = 'efp(de-spiked --> Eo - E!Dconv!N'+')'
despke_tp3     = pref[0]+modes_efi[0]+efi_despke3[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E ['+coord_up[0]+', mV/m]'+'!C'+'['+despke_nm3[0]+']'
str_element,dlim_efp,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:vec_t,Y:e0_rest}
store_data,despke_tp3[0],DATA=struct,DLIM=dlim_efp,LIM=lim_efp

;;  Now remove DC-offsets from Eo_rest
get_data,despke_tp3[0],DATA=temp_Eor,DLIM=dlim_Eor,LIM=lim_Eor
;;  Smooth and then remove DC-offsets
vec_t          = temp_Eor.X
vec_v          = temp_Eor.Y
;;  Set "bad" regions to NaNs
vec_v1         = vec_v
IF (bd_emag GT 0) THEN vec_v1[bad_emag,0L:1L] = d
smpts          = 10L
mxpts          = 50L
Eor_v_nodc     = REPLICATE(d,SIZE(vec_v,/DIMENSIONS))
FOR j=0L, pint - 1L DO BEGIN                                                           $
  st       = se_pels[j,0] + mxpts[0]                                                 & $  ;; stay away from end pts
  en       = se_pels[j,1] - mxpts[0]                                                 & $
  inds     = st[0] + LINDGEN(en[0] - st[0] + 1L)                                     & $
  t_efpvx  = SMOOTH(vec_v1[inds,0],smpts[0],/NAN,/EDGE_TRUNCATE)                     & $
  t_efpvy  = SMOOTH(vec_v1[inds,1],smpts[0],/NAN,/EDGE_TRUNCATE)                     & $
  t_efpvz  = SMOOTH(vec_v1[inds,2],smpts[0],/NAN,/EDGE_TRUNCATE)                     & $
  t_efpv   = [[t_efpvx],[t_efpvy],[t_efpvz]]                                         & $
  avgs     = [MEAN(t_efpv[*,0],/NAN),MEAN(t_efpv[*,1],/NAN),MEAN(t_efpv[*,2],/NAN)]  & $
  FOR k=0L, 2L DO Eor_v_nodc[inds,k] = vec_v1[inds,k] - avgs[k]

;;  Send de-spiked efp, without E_conv and DC-offsets, to TPLOT
efi_despk_nodc = '_cal_despiked_rmEconv_rmDC_'
despk_nodc_nm  = 'Eo - E!Dconv!N -> rm DCoffsets'
despk_nodc_tp  = pref[0]+modes_efi[0]+efi_despk_nodc[0]+coord_dsl[0]
coord_up       = STRUPCASE(coord_dsl[0])
yttl           = 'E [efp, '+coord_up[0]+', mV/m, de-spiked]'+'!C'+'['+despk_nodc_nm[0]+']'
str_element,dlim_Eor,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:vec_t,Y:Eor_v_nodc}
store_data,despk_nodc_tp[0],DATA=struct,DLIM=dlim_Eor,LIM=lim_Eor

;;  Remove "spikes" and edge-effects by hand
nna            = [despk_nodc_tp[0]]
kill_data_tr,NAMES=nna

;;----------------------------------------------------------------------------------------
;;  Plot results
;;----------------------------------------------------------------------------------------
coord          = coord_dsl[0]
all_fgl_tpnm   = [fgm_mag[1],fgm_dsl[1]]
all_fgh_tpnm   = [fgm_mag[2],fgm_dsl[2]]
all_fgm_tpnm   = all_fgl_tpnm
all_scp_tpnm   = scp_names[0]
all_efp_tpnm   = [efp_names[0],smth_tpnm[0],despke_tp2[0],despk_nodc_tp[0]]

nna            = [all_fgm_tpnm,all_scp_tpnm,all_efp_tpnm]
tra            = t_ramp0[0] + [-1d0,1d0]*115d0  ;; 330 s window centered on ramp
tplot,nna,TRANGE=tra

;;  fgl, EFI & SCM Plots
all_fgm_tpnm   = all_fgl_tpnm
f_pref         = prefu[0]+'fgl-mag-'+coord[0]+'_scp-cal-'+coord[0]+'_efp-cal-detrend-despike-rmEswDCoff-'+coord[0]+'_'
nna            = [all_fgm_tpnm,all_scp_tpnm[0],all_efp_tpnm]

;;  fgh, EFI & SCM Plots
all_fgm_tpnm   = all_fgh_tpnm
f_pref         = prefu[0]+'fgh-mag-'+coord[0]+'_scp-cal-'+coord[0]+'_efp-cal-detrend-despike-rmEswDCoff-'+coord[0]+'_'
nna            = [all_fgm_tpnm,all_scp_tpnm[0],all_efp_tpnm]


traz           = t_get_current_trange()
fnm_tra        = file_name_times(traz,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fnames         = f_pref[0]+ftime[0]
PRINT, fnames[0]

popen,fnames[0],/PORT
  tplot,nna,TRANGE=traz
pclose
  tplot,/NOM

;;----------------------------------------------------------------------------------------
;;  Calculate spin fit of altered data
;;----------------------------------------------------------------------------------------
;;  Get spin phase and period
get_data,sp_per_tpnm[0],DATA=temp_sp_per,DLIM=dlim_sp_per,LIM=lim_sp_per
get_data,sp_phs_tpnm[0],DATA=temp_sp_phs,DLIM=dlim_sp_phs,LIM=lim_sp_phs
;;  Get Eo data [DSL]
get_data,despk_nodc_tp[0],DATA=temp_Eornodc,DLIM=dlim_Eornodc,LIM=lim_Eornodc
;;  Define parameters
vec_t          = temp_Eornodc.X
vec_v          = temp_Eornodc.Y
sp_per_t       = temp_sp_per.X
sp_per_v       = temp_sp_per.Y
sp_phs_t       = temp_sp_phs.X
sp_phs_v       = temp_sp_phs.Y
;;  Calculate sunpulse data
state_midnm    = 'state_'
sunpulse_nm    = scpref[0]+state_midnm[0]+'sun_pulse'
thm_sunpulse,sp_per_t,sp_phs_v,sp_per_v,sunpulse,sunp_spinper,PROBE=sc[0],SUNPULSE_NAME=sunpulse_nm[0]
;;  Get sunpulse
get_data,sunpulse_nm[0],DATA=thx_sunpulse_times
sunp_t         = thx_sunpulse_times.X
sunp_v         = thx_sunpulse_times.Y

;;  First clean up de-spiked efp, without E_conv and DC-offsets
;;  Use a cubic spline to interpolate NaNs
t_efpvx        = remove_nans(vec_t,vec_v[*,0],/NO_EXTRAPOLATE,/SPLINE)
t_efpvy        = remove_nans(vec_t,vec_v[*,1],/NO_EXTRAPOLATE,/SPLINE)
t_efpvz        = remove_nans(vec_t,vec_v[*,2],/NO_EXTRAPOLATE,/SPLINE)
t_efpv         = [[t_efpvx],[t_efpvy],[t_efpvz]]
vec_v          = t_efpv
;;  Only use indices near shock
gind           = LONG(a_ind[se_pels[2,0]:se_pels[2,1]])

;;  Find X-Axis fit
plane_dim      = 0
axis_dim       = 0
sun2sensor     = 0d0
spinfit,$
          vec_t[gind],vec_v[gind,*],sunp_t,sunp_v,     $         ;;  Input
          a,b,c,spin_axis,med_axis,sig,npts,sun_data,  $         ;;  Output
          MIN_POINTS=min_points,ALPHA=alpha,BETA=beta, $
          PLANE_DIM=plane_dim,AXIS_DIM=axis_dim,PHASE_MASK_STARTS=phase_mask_starts,$
          PHASE_MASK_ENDS=phase_mask_ends,SUN2SENSOR=sun2sensor

;;  Send to TPLOT
fit_tpns       = ['a','b','c','sig','npts']
boomfit        = 'x'
temp_tpn       = 'test_spinfit_efp_'+boomfit[0]+'_'
ysubt          = '[Spinfit to efp]'

str_element, lim_Eornodc,'LABELS',/DELETE
str_element,dlim_Eornodc,'LABELS',/DELETE
str_element,dlim_Eornodc,'COLORS',50,/ADD_REPLACE

store_data,temp_tpn[0]+fit_tpns[0],   DATA={X:sun_data,   Y:a},DLIM=dlim_Eornodc,LIM=lim_Eornodc
store_data,temp_tpn[0]+fit_tpns[1],   DATA={X:sun_data,   Y:b},DLIM=dlim_Eornodc,LIM=lim_Eornodc
store_data,temp_tpn[0]+fit_tpns[2],   DATA={X:sun_data,   Y:c},DLIM=dlim_Eornodc,LIM=lim_Eornodc
store_data,temp_tpn[0]+fit_tpns[3],   DATA={X:sun_data, Y:sig},DLIM=dlim_Eornodc,LIM=lim_Eornodc
store_data,temp_tpn[0]+fit_tpns[4],   DATA={X:sun_data,Y:npts},DLIM=dlim_Eornodc,LIM=lim_Eornodc
options,temp_tpn[0]+fit_tpns[0],'YTITLE','Spinfit Param. '+fit_tpns[0]
options,temp_tpn[0]+fit_tpns[1],'YTITLE','Spinfit Param. '+fit_tpns[1]
options,temp_tpn[0]+fit_tpns[2],'YTITLE','Spinfit Param. '+fit_tpns[2]
options,temp_tpn[0]+fit_tpns[3],'YTITLE','Spinfit Param. '+fit_tpns[3]
options,temp_tpn[0]+fit_tpns[4],'YTITLE','Spinfit Param. '+fit_tpns[4]
options,temp_tpn[0]+fit_tpns[0],'YSUBTITLE',ysubt[0]
options,temp_tpn[0]+fit_tpns[1],'YSUBTITLE',ysubt[0]
options,temp_tpn[0]+fit_tpns[2],'YSUBTITLE',ysubt[0]
options,temp_tpn[0]+fit_tpns[3],'YSUBTITLE',ysubt[0]
options,temp_tpn[0]+fit_tpns[4],'YSUBTITLE',ysubt[0]


nna            = [all_fgh_tpnm,despk_nodc_tp[0],temp_tpn[0]+'*']
  tplot,nna,TRANGE=traz


get_data,spphs_int_tpnm[0],DATA=spphs_int,DLIM=dlim_sp_phs,LIM=lim_sp_phs
sphase_t       = spphs_int.X
sphase_v       = spphs_int.Y
sphase_vr      = sphase_v*!DPI/18d1


;;  Reconstruct Eo_x
smpts          = 10L      ;;  # of points to smooth
up_t           = vec_t[gind]
a_up           = interp(SMOOTH(a,smpts[0],/NAN,/EDGE_TRUNCATE),sun_data,up_t,/NO_EXTRAPOLATE)
b_up           = interp(SMOOTH(b,smpts[0],/NAN,/EDGE_TRUNCATE),sun_data,up_t,/NO_EXTRAPOLATE)
c_up           = interp(SMOOTH(c,smpts[0],/NAN,/EDGE_TRUNCATE),sun_data,up_t,/NO_EXTRAPOLATE)
Eo_x_fit       = a_up + b_up*COS(sphase_vr) + c_up*SIN(sphase_vr)

wi,1
WSET,1
PLOT,Eo_x_fit,/NODATA,/XSTYLE,/YSTYLE
  OPLOT,Eo_x_fit,COLOR=250
  OPLOT,vec_v[gind,0],COLOR= 50,PSYM=3

;;----------------------------------------------------------------------------------------
;;  Save data for tomorrow
;;----------------------------------------------------------------------------------------
fpref          = 'TPLOT_save_file_'+prefu[0]+'FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fsuff          = 'efp-despiked_rmEconv-DC-despun_'
traz           = t_get_current_trange()
fnm_tra        = file_name_times(traz,PREC=4)
ftime          = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
fname          = fpref[0]+fsuff[0]+ftime[0]
PRINT, fname[0]

tplot_save,FILENAME=fname[0]


;;----------------------------------------------------------------------------------------
;;  NOTE:  hypothesis = correct
;;  Test hypothesis that large spikes are due to shadow and wake effects
;;----------------------------------------------------------------------------------------

;;  Get spin phase data
get_data,spphs_int_tpnm[0],DATA=temp_sp0,DLIM=dlim_sp0,LIM=lim_sp0
;;  Get EFI data [DSL]
get_data,efp_names[0],DATA=temp_e0,DLIM=dlim_e0,LIM=lim_e0
;;  Get Vsw data [DSL]
get_data,vsw_nm_dsl[0]+'_fixed_3',DATA=Vsw_dsl,DLIM=dlim_Vsw_dsl,LIM=lim_Vsw_dsl

;;  Define spin phase parameters
sp0_d          = temp_sp0.Y
sp0_r          = temp_sp0.Y*!DPI/18d1        ;;  convert to radians
sp0_rn         = sp0_r/(2d0*!DPI)            ;;  normalize to 2π

;;  Define EFI parameters
e0_vec         = temp_e0.Y
e0_mag         = SQRT(TOTAL(e0_vec^2,2,/NAN))
e0_uvec        = e0_vec/(e0_mag # REPLICATE(1d0,3))
gind           = LONG(a_ind[se_pels[2,0]:se_pels[2,1]])  ;;  Only use indices near shock
up_t           = temp_e0.X[gind]  ;;  upsample times

;;  Define Vsw parameters
smvel3         = Vsw_dsl.Y
;;  Upsample to EFI times
up_vsw_x       = interp(smvel3[*,0],ti_vsw.X,up_t,/NO_EXTRAPOLATE)
up_vsw_y       = interp(smvel3[*,1],ti_vsw.X,up_t,/NO_EXTRAPOLATE)
up_vsw_z       = interp(smvel3[*,2],ti_vsw.X,up_t,/NO_EXTRAPOLATE)
up_vsw_v       = [[up_vsw_x],[up_vsw_y],[up_vsw_z]] 
up_vsw_m       = SQRT(TOTAL(up_vsw_v^2,2,/NAN))
upvsw_uv       = up_vsw_v/(up_vsw_m # REPLICATE(1d0,3))


;;-----------------------------------------
;;  Plot parameters
;;-----------------------------------------
wi,1


;;  Ex_u vs. ø [rad]
xdat           = sp0_r[gind]
ydat           = ABS(e0_uvec[gind,0])
xran           = [0d0,2d0*!DPI]
yran           = [0d0,1d0]
xlog           = 0
ylog           = 0
nsum           = 1

;;  |Ex_u|/|Vswx_u| vs. |Ey_u|/|Vswy_u|
xdat           = ABS(e0_uvec[gind,0])/ABS(upvsw_uv[*,0])
ydat           = ABS(e0_uvec[gind,1])/ABS(upvsw_uv[*,1])
xran           = [1d-2,2d1]
yran           = xran
xlog           = 1
ylog           = 1
nsum           = 20

WSET,1
pstr           = {XSTYLE:1,YSTYLE:1,XRANGE:xran,YRANGE:yran,XLOG:xlog,YLOG:ylog,NODATA:1}
PLOT,xdat,ydat,_EXTRA=pstr
  OPLOT,xdat,ydat,PSYM=2,COLOR=250,NSUM=nsum


;;  Ex_u vs. ø [deg]
xdat0          = sp0_d[gind]
xdat1          = (xdat0 + 9d1) MOD 36d1
ydat0          = ABS(e0_uvec[gind,0])
ydat1          = ABS(e0_uvec[gind,1])
xran           = [0d0,365d0]
yran           = [0d0,1.1d0]

;;  Ex_u vs. ø [deg, shifted]
;;  +Y-SPG is -45 deg from +X-SSL at start of sun pulse and
;;    +X-SPG is -135 deg from +X-SSL " "
;xdat0          = ((sp0_d[gind] - 135d0) + 36d1) MOD 36d1
xdat0          = ((sp0_d[gind] - 45d0) + 36d1) MOD 36d1
xdat1          = (xdat0 + 9d1) MOD 36d1
ydat0          = ABS(e0_uvec[gind,0])
ydat1          = ABS(e0_uvec[gind,1])
xran           = [0d0,365d0]
yran           = [0d0,1.1d0]

;;  (Ex_u vs. Vswx_u) and (Ey_u vs. Vswy_u)
xdat0          = ABS(upvsw_uv[*,0])
xdat1          = ABS(upvsw_uv[*,1])
ydat0          = ABS(e0_uvec[gind,0])
ydat1          = ABS(e0_uvec[gind,1])
xran           = [0d0,1d0]
yran           = [0d0,1d0]


WSET,1
pstr           = {XSTYLE:1,YSTYLE:1,XRANGE:xran,YRANGE:yran,NODATA:1}
PLOT,xdat0,ydat0,_EXTRA=pstr
  OPLOT,xdat0,ydat0,PSYM=1,COLOR=250
  OPLOT,xdat1,ydat1,PSYM=1,COLOR= 50











;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Wrong
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------



;;  Define initial and final conditions
efp_t_if       = [MIN(efp_t,/NAN),MAX(efp_t,/NAN)]
T_sp_if        = interp(sp_per_v,sp_per_t,efp_t_if,/NO_EXTRAPOLATE)
w_sp_if        = interp(spin_rate,sp_per_t,efp_t_if,/NO_EXTRAPOLATE)
phase_if       = interp(sp_phs_v,sp_phs_t,efp_t_if,/NO_EXTRAPOLATE)

test           = (sp_per_t GE efp_t_if[0]) AND (sp_per_t LE efp_t_if[1])
good_spp       = WHERE(test,gdspp)
test           = (sp_phs_t GE efp_t_if[0]) AND (sp_phs_t LE efp_t_if[1])
good_sph       = WHERE(test,gdsph)
PRINT, ';;  ', gdspp, gdsph
;;           306         306

;;  Find derivative of spin phase
dT_dt          = DERIV(sp_phs_t,sp_phs_v)
;;  Send derivative to TPLOT
dTdt_spphs_nm  = sp_phs_tpnm[0]+'_dTdt'
yttl           = 'dT/dt'+'!C'+'[slope of spin phase]'
str_element,dlim_sp_phs,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:sp_phs_t,Y:dT_dt}
store_data,dTdt_spphs_nm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
options,dTdt_spphs_nm[0],'YRANGE',[-1d0,1d0]*2d0,/DEF

;;  Find 2nd derivative of spin phase
d2T_dt2        = DERIV(sp_phs_t,dT_dt)
;;  Send 2nd derivative to TPLOT
dTdt2_spphs_nm = sp_phs_tpnm[0]+'_d2Tdt2'
yttl           = 'd!U2!NT/dt!U2!N'+'!C'+'[curvature of spin phase]'
str_element,dlim_sp_phs,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:sp_phs_t,Y:d2T_dt2}
store_data,dTdt2_spphs_nm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
options,dTdt2_spphs_nm[0],'YRANGE',[-1d0,1d0]*3d-2,/DEF

;;  Find 3rd derivative of spin phase
d3T_dt3        = DERIV(sp_phs_t,d2T_dt2)
;;  Send 3rd derivative to TPLOT
dTdt3_spphs_nm = sp_phs_tpnm[0]+'_d3Tdt3'
yttl           = 'd!U3!NT/dt!U3!N'+'!C'+'[jerk? of spin phase]'
str_element,dlim_sp_phs,'YTITLE',yttl[0],/ADD_REPLACE
struct         = {X:sp_phs_t,Y:d3T_dt3}
store_data,dTdt3_spphs_nm[0],DATA=struct,DLIM=dlim_sp_phs,LIM=lim_sp_phs
options,dTdt3_spphs_nm[0],'YRANGE',[-1d0,1d0]*5d-4,/DEF



;;  Remove edge-effects by hand
nna            = [dTdt_spphs_nm[0],dTdt2_spphs_nm[0],dTdt3_spphs_nm[0]]
kill_data_tr,NAMES=nna


;;  Find where f'(t) < 0  --> compare magnitude to pts where f'(t) > 0
test           = (dT_dt LT 0)
neg_1st        = WHERE(test,gdneg1,COMPLEMENT=pos_1st,NCOMPLEMENT=gdpos1)
PRINT, ';;  ', gdneg1, gdpos1
;;           839         601

IF (gdneg1 GT 0) THEN only_neg1_v = dT_dt[neg_1st]
IF (gdpos1 GT 0) THEN only_pos1_v = dT_dt[pos_1st]
x              = ABS(only_neg1_v)
stats_neg1     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x)]
x              = ABS(only_pos1_v)
stats_pos1     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x)]
PRINT, ';;', stats_neg1  &  PRINT, ';;', stats_pos1
;;       1.0860140       1.2573963       1.2517498       1.2553566
;;       1.7426592       1.9095670       1.7477805       1.7446431



;;  1st pt where f"(t) < 0  --> roll over point
;;    => break up into intervals
test           = (d2T_dt2 LT 0)
neg_2nd        = WHERE(test,gdneg,COMPLEMENT=pos_2nd,NCOMPLEMENT=gdpos)
PRINT, ';;  ', gdneg2, gdpos2
;;           727         713

only_neg_t     = sp_phs_t
only_neg_v     = d2T_dt2
IF (gdneg2 GT 0) THEN only_neg_t = only_neg_t[neg_2nd]
IF (gdneg2 GT 0) THEN only_neg_v = only_neg_v[neg_2nd]

srate_sp       = DOUBLE(sample_rate(sp_phs_t,GAP_THRESH=61d0,/AVE))
se_spel        = t_interval_find(only_neg_t,GAP_THRESH=1d0/srate_sp[0])
spint          = N_ELEMENTS(se_spel[*,0])



;;  Look for large ∆f(t)
nsp            = N_ELEMENTS(sp_phs_t)
se             = [0L, nsp[0] - 1L]
diff           = sp_phs_v - SHIFT(sp_phs_v,1)
diff[se]       = d



.compile /Users/lbwilson/Desktop/temp_idl/find_inv_mod.pro
test = find_inv_mod(sp_phs_v[5],36d1)
print, test























;;  Load sun pulse times
sunpulse_nm    = scpref[0]+state_midnm[0]+'sun_pulse'
thm_sunpulse,sp_per_t,sp_phs_v,sp_per_v,sunpulse,sunp_spinper,PROBE=sc[0],SUNPULSE_NAME=sunpulse_nm[0]
;;  sunpulse     = sun pulse times
;;  sunp_spinper = spin period at sun pulse times

;;  Calculate spin phase at sun pulse times
new_t          = sunpulse
new_v          = sunp_spinper
thm_spin_phase,new_t,spinpha_int,new_t,new_v
;;  spinpha_int  = spin phase (interpolated) at sun pulse times



















;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

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
R_E            = 6.37814d3            ;;  Earth's Equitorial Radius [km]
;;----------------------------------------------------------------------------------------
;;  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  2009-09-26 [1 Crossing]
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
;;  Example waveform times
tr_ww          = time_double(tdate[0]+'/'+['15:53:02.500','15:53:15.600'])
tr_esw0        = time_double(tdate[0]+'/'+['15:53:03.475','15:53:03.500'])  ;;  train of ESWs [efw, Int. 0]
tr_esw1        = time_double(tdate[0]+'/'+['15:53:04.474','15:53:04.503'])  ;;  train of ESWs [efw, Int. 0]
tr_esw2        = time_double(tdate[0]+'/'+['15:53:09.910','15:53:09.940'])  ;;  two      ESWs [efw, Int. 1]
tr_whi         = time_double(tdate[0]+'/'+['15:53:10.860','15:53:11.203'])  ;;  example whistlers [scw, Int. 1]
tr_ww1         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:15.590'])
tr_ww2         = time_double(tdate[0]+'/'+['15:53:09.165','15:53:12.500'])
;;----------------------------------------------------------------------------------------
;;  Define timespan
;;----------------------------------------------------------------------------------------
timespan,tdate[0],1.0,/DAY

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
scu            = STRUPCASE(sc[0])
prefu          = STRUPCASE(pref[0])

thm_load_fgm,  PROBE=sc[0],LEVEL=1,TYPE='raw'
thm_load_efi,  PROBE=sc[0],LEVEL=1,TYPE='raw'
thm_load_state,PROBE=sc[0],/GET_SUPPORT_DATA

options,[1,2,3,4,5,6],'COLORS'
options,[1,2,3,4,5,6],'COLORS',[250,150, 50],/DEF

;;----------------------------------------------------------------------------------------
;;  Set defaults
;;----------------------------------------------------------------------------------------
!themis.VERBOSE = 2
tplot_options,'VERBOSE',2
options,tnames(),'LABFLAG',2,/DEF
;;  Remove color table from default options
options,tnames(),'COLOR_TABLE',/DEF
options,tnames(),'COLOR_TABLE'

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='THEMIS-'+scu[0]+' Plots ['+tdate[0]+']'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01
;;----------------------------------------------------------------------------------------
;;  Plot
;;----------------------------------------------------------------------------------------
scpref         = 'th'+sc[0]+'_'

coord_dsl      = 'dsl'
modes_slh      = ['s','l','h']
mode_fgm       = 'fg'+modes_slh
fgm_pren       = scpref[0]+mode_fgm
fgm_tpnm       = tnames(fgm_pren[*])


;;  perform spin fit on fgh data and have it return A, B, C fit parameters plus the
;;  standard deviation and number of points remaining in curve.

;;  fit magnetic field data
thm_spinfit,scpref[0]+'fg?',/SIGMA,/NPOINTS

;;  fit electric field data
thm_spinfit,scpref[0]+'fg?',/SIGMA,/NPOINTS


;;  Now load on board spin fit data to compare.
thm_load_fit,PROBE=sc[0],TYPE='raw'
















