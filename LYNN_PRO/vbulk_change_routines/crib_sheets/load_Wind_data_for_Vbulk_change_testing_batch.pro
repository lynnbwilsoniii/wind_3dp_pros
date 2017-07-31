;;  ***  Change paths accordingly for your machine and location of this software!!!  ***


;;  @/Users/lbwilson/Desktop/temp_idl/temp_gen_change_vbulk/load_Wind_data_for_Vbulk_change_testing_batch.pro

;;----------------------------------------------------------------------------------------
;;  IDL system and OS stuff
;;----------------------------------------------------------------------------------------
vers           = !VERSION.OS_FAMILY   ;;  e.g., 'unix'
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Fundamental
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23         ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
hh             = 6.6260700400d-34         ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Atomic
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
mn             = 1.6749274710d-27         ;;  Neutron mass [kg, 2014 CODATA/NIST]
ma             = 6.6446572300d-27         ;;  Alpha particle mass [kg, 2014 CODATA/NIST]
;;  --> Define mass of particles in units of energy [eV]
ma_eV          = ma[0]*c[0]^2/qq[0]       ;;  ~3727.379378(23) [MeV, 2014 CODATA/NIST]
me_eV          = me[0]*c[0]^2/qq[0]       ;;  ~0.5109989461(31) [MeV, 2014 CODATA/NIST]
mn_eV          = mn[0]*c[0]^2/qq[0]       ;;  ~939.5654133(58) [MeV, 2014 CODATA/NIST]
mp_eV          = mp[0]*c[0]^2/qq[0]       ;;  ~938.2720813(58) [MeV, 2014 CODATA/NIST]
;;  Astronomical
R_S___m        = 6.9600000d08             ;;  Sun's Mean Equatorial Radius [m, 2015 AA values]
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
M_S__kg        = 1.9884000d30             ;;  Sun's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
;;----------------------------------------------------------------------------------------
;;  Conversion Factors
;;----------------------------------------------------------------------------------------
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz}]
eV2J           = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J}]
eV2K           = qq[0]/kB[0]          ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]          ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
;;  Define some coordinate strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_fac      = 'fac'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
vec_str        = ['x','y','z']
tensor_str     = ['x'+vec_str,'y'+vec_str[1:2],'zz']
fac_vec_str    = ['perp1','perp2','para']
fac_dir_str    = ['para','perp','anti']
vec_col        = [250,150, 50]
;;----------------------------------------------------------------------------------------
;;  Define date strings
;;----------------------------------------------------------------------------------------
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'

def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:50L,LABELS:'1',LABFLAG:2}
;;----------------------------------------------------------------------------------------
;;  Define time range
;;----------------------------------------------------------------------------------------
;test           = get_valid_trange(TDATE=tdate,TRANGE=trange,PRECISION=6)   ;;  Make sure format is valid
;tr_st_d        = tura[0] - 36d2*2
;tr_en_d        = tura[0] + 36d2*2
;trange         = [tr_st_d[0],tr_en_d[0]]
;t              = time_string(trange,PREC=3)
IF (SIZE(start_t,/TYPE) NE 7) THEN start_t = start_of_day[0]
IF (SIZE(end___t,/TYPE) NE 7) THEN end___t = end___of_day[0]
t              = [tdate[0]+'/'+start_t[0],tdate[0]+'/'+end___t[0]]
trange         = time_double(t)
;;----------------------------------------------------------------------------------------
;;  Find and define files
;;----------------------------------------------------------------------------------------
;;  Define save directory
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'temp_idl'+slash[0]+'temp_gen_change_vbulk'+slash[0]+'sav_files'+slash[0]
;;  Define file prefixes
fnm_tplot_pre  = scpref[0]+'mfi_pesalow_sweions_wavesradio_'
fnm_pesa__pre  = 'Pesa_3DP_Structures_'
fnm_eesa__pre  = 'Eesa_3DP_Structures_'
fnm_sstfo_pre  = 'SST-Foil-Open_3DP_Structures_'
;;  Define file suffixes
fnm_3dp_suffx  = '*_w-Vsw-Ni-SCPot.sav'
fnm_tplot_suf  = '*.tplot'
;;  Define file names
fname_tplot    = FILE_SEARCH(sav_dir[0],fnm_tplot_pre[0]+fnm_tplot_suf[0])
fname__pesa    = FILE_SEARCH(sav_dir[0],fnm_pesa__pre[0]+fnm_3dp_suffx[0])
fname__eesa    = FILE_SEARCH(sav_dir[0],fnm_eesa__pre[0]+fnm_3dp_suffx[0])
fname_sstfo    = FILE_SEARCH(sav_dir[0],fnm_sstfo_pre[0]+fnm_3dp_suffx[0])
;;----------------------------------------------------------------------------------------
;;  Load TPLOT data
;;----------------------------------------------------------------------------------------
;;  Load MFI data
wind_h0_mfi_2_tplot,TRANGE=trange
;;  Load SWE data
wind_h1_swe_to_tplot,TRANGE=trange,/NO_SWE_B
;;  Load orbit data
Bgse_tpnm      = 'Wind_B_3sec_gse'        ;;  TPLOT handle associated with Bo [GSE, nT]
wind_orbit_to_tplot,BNAME=Bgse_tpnm[0],TRANGE=trange
;;  Change Y-Axis titles
options,'Wind_Radial_Distance','YTITLE','Radial Dist. (R!DE!N)'
options,'Wind_GSE_Latitude','YTITLE','GSE Lat. [deg]'
options,'Wind_GSE_Longitude','YTITLE','GSE Lon. [deg]'
;;  Add these variables as tick mark labels
gnames         = ['Wind_Radial_Distance','Wind_GSE_Latitude','Wind_GSE_Longitude','Wind_MLT']
tplot_options,VAR_LABEL=gnames
;test_tpnf      = (fname_tplot[0] NE '')
;;;  Load new TPLOT data (make sure to append so as to not delete currently loaded data)
;IF (test_tpnf[0]) THEN tplot_restore,FILENAMES=fname_tplot[0],/APPEND,/SORT; ELSE STOP
;;----------------------------------------------------------------------------------------
;;  Define some TPLOT defaults
;;----------------------------------------------------------------------------------------
tplot_options,'XMARGIN',[ 20, 15]
tplot_options,'YMARGIN',[ 5, 5]
;;  Set TPLOT time range
dt             = (trange[1] - trange[0])
timespan,trange[0],dt[0],/SECONDS
;;----------------------------------------------------------------------------------------
;;  Open window
;;----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=s_size
wsz            = s_size*7d-1
win_ttl        = sc[0]+' Plots'
win_str        = {RETAIN:2,XSIZE:wsz[0],YSIZE:wsz[1],TITLE:win_ttl[0],XPOS:10,YPOS:10}
WINDOW,0,_EXTRA=win_str
;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
tplot,[1,2]
set_tplot_times
lbw_tplot_set_defaults
tplot_options,'XMARGIN',[ 20, 15]
tplot_options,'YMARGIN',[ 5, 5]
;;----------------------------------------------------------------------------------------
;;  Load 3DP data
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(no_load_vdfs) THEN STOP

test__pesa     = (fname__pesa[0] NE '')
test__eesa     = (fname__eesa[0] NE '')
test_sstfo     = (fname_sstfo[0] NE '')
IF (test__pesa[0]) THEN RESTORE,fname__pesa[0]
IF (test__eesa[0]) THEN RESTORE,fname__eesa[0]
IF (test_sstfo[0]) THEN RESTORE,fname_sstfo[0]
;;----------------------------------------------------------------------------------------
;;  Limit 3DP data to time range
;;----------------------------------------------------------------------------------------
IF (SIZE(apl_,/TYPE) EQ 8) THEN n_pl_ = N_ELEMENTS(apl_) ELSE n_pl_ = 0
IF (SIZE(aplb,/TYPE) EQ 8) THEN n_plb = N_ELEMENTS(aplb) ELSE n_plb = 0
IF (SIZE(aph_,/TYPE) EQ 8) THEN n_ph_ = N_ELEMENTS(aph_) ELSE n_ph_ = 0
IF (SIZE(aphb,/TYPE) EQ 8) THEN n_phb = N_ELEMENTS(aphb) ELSE n_phb = 0
IF (SIZE(ael_,/TYPE) EQ 8) THEN n_el_ = N_ELEMENTS(ael_) ELSE n_el_ = 0
IF (SIZE(aelb,/TYPE) EQ 8) THEN n_elb = N_ELEMENTS(aelb) ELSE n_elb = 0
IF (SIZE(aeh_,/TYPE) EQ 8) THEN n_eh_ = N_ELEMENTS(aeh_) ELSE n_eh_ = 0
IF (SIZE(aehb,/TYPE) EQ 8) THEN n_ehb = N_ELEMENTS(aehb) ELSE n_ehb = 0
IF (SIZE(asf_,/TYPE) EQ 8) THEN n_sf_ = N_ELEMENTS(asf_) ELSE n_sf_ = 0
IF (SIZE(asfb,/TYPE) EQ 8) THEN n_sfb = N_ELEMENTS(asfb) ELSE n_sfb = 0
IF (SIZE(aso_,/TYPE) EQ 8) THEN n_so_ = N_ELEMENTS(aso_) ELSE n_so_ = 0
IF (SIZE(asob,/TYPE) EQ 8) THEN n_sob = N_ELEMENTS(asob) ELSE n_sob = 0
;;  First sort by time
IF (n_pl_[0] GT 0) THEN sp_pl_ = SORT(apl_.TIME )
IF (n_plb[0] GT 0) THEN sp_plb = SORT(aplb.TIME)
IF (n_ph_[0] GT 0) THEN sp_ph_ = SORT(aph_.TIME )
IF (n_phb[0] GT 0) THEN sp_phb = SORT(aphb.TIME)
IF (n_el_[0] GT 0) THEN sp_el_ = SORT(ael_.TIME )
IF (n_elb[0] GT 0) THEN sp_elb = SORT(aelb.TIME)
IF (n_eh_[0] GT 0) THEN sp_eh_ = SORT(aeh_.TIME )
IF (n_ehb[0] GT 0) THEN sp_ehb = SORT(aehb.TIME)
IF (n_sf_[0] GT 0) THEN sp_sf_ = SORT(asf_.TIME )
IF (n_sfb[0] GT 0) THEN sp_sfb = SORT(asfb.TIME)
IF (n_so_[0] GT 0) THEN sp_so_ = SORT(aso_.TIME )
IF (n_sob[0] GT 0) THEN sp_sob = SORT(asob.TIME)

IF (n_pl_[0] GT 0) THEN apl_ = TEMPORARY(apl_[sp_pl_])
IF (n_plb[0] GT 0) THEN aplb = TEMPORARY(aplb[sp_plb])
IF (n_ph_[0] GT 0) THEN aph_ = TEMPORARY(aph_[sp_ph_])
IF (n_phb[0] GT 0) THEN aphb = TEMPORARY(aphb[sp_phb])
IF (n_el_[0] GT 0) THEN ael_ = TEMPORARY(ael_[sp_el_])
IF (n_elb[0] GT 0) THEN aelb = TEMPORARY(aelb[sp_elb])
IF (n_eh_[0] GT 0) THEN aeh_ = TEMPORARY(aeh_[sp_eh_])
IF (n_ehb[0] GT 0) THEN aehb = TEMPORARY(aehb[sp_ehb])
IF (n_sf_[0] GT 0) THEN asf_ = TEMPORARY(asf_[sp_sf_])
IF (n_sfb[0] GT 0) THEN asfb = TEMPORARY(asfb[sp_sfb])
IF (n_so_[0] GT 0) THEN aso_ = TEMPORARY(aso_[sp_so_])
IF (n_sob[0] GT 0) THEN asob = TEMPORARY(asob[sp_sob])

;;  Keep only those structures within the desired time range
IF (n_pl_[0] GT 0) THEN tse_pl_ = [[apl_.TIME],[apl_.END_TIME]]
IF (n_plb[0] GT 0) THEN tse_plb = [[aplb.TIME],[aplb.END_TIME]]
IF (n_ph_[0] GT 0) THEN tse_ph_ = [[aph_.TIME],[aph_.END_TIME]]
IF (n_phb[0] GT 0) THEN tse_phb = [[aphb.TIME],[aphb.END_TIME]]
IF (n_el_[0] GT 0) THEN tse_el_ = [[ael_.TIME],[ael_.END_TIME]]
IF (n_elb[0] GT 0) THEN tse_elb = [[aelb.TIME],[aelb.END_TIME]]
IF (n_eh_[0] GT 0) THEN tse_eh_ = [[aeh_.TIME],[aeh_.END_TIME]]
IF (n_ehb[0] GT 0) THEN tse_ehb = [[aehb.TIME],[aehb.END_TIME]]
IF (n_sf_[0] GT 0) THEN tse_sf_ = [[asf_.TIME],[asf_.END_TIME]]
IF (n_sfb[0] GT 0) THEN tse_sfb = [[asfb.TIME],[asfb.END_TIME]]
IF (n_so_[0] GT 0) THEN tse_so_ = [[aso_.TIME],[aso_.END_TIME]]
IF (n_sob[0] GT 0) THEN tse_sob = [[asob.TIME],[asob.END_TIME]]

IF (n_pl_[0] GT 0) THEN good_pl_ = WHERE(tse_pl_[*,0] GT trange[0] AND tse_pl_[*,1] LT trange[1],gd_pl_) ELSE gd_pl_ = 0
IF (n_plb[0] GT 0) THEN good_plb = WHERE(tse_plb[*,0] GT trange[0] AND tse_plb[*,1] LT trange[1],gd_plb) ELSE gd_plb = 0
IF (n_ph_[0] GT 0) THEN good_ph_ = WHERE(tse_ph_[*,0] GT trange[0] AND tse_ph_[*,1] LT trange[1],gd_ph_) ELSE gd_ph_ = 0
IF (n_phb[0] GT 0) THEN good_phb = WHERE(tse_phb[*,0] GT trange[0] AND tse_phb[*,1] LT trange[1],gd_phb) ELSE gd_phb = 0
IF (n_el_[0] GT 0) THEN good_el_ = WHERE(tse_el_[*,0] GT trange[0] AND tse_el_[*,1] LT trange[1],gd_el_) ELSE gd_el_ = 0
IF (n_elb[0] GT 0) THEN good_elb = WHERE(tse_elb[*,0] GT trange[0] AND tse_elb[*,1] LT trange[1],gd_elb) ELSE gd_elb = 0
IF (n_eh_[0] GT 0) THEN good_eh_ = WHERE(tse_eh_[*,0] GT trange[0] AND tse_eh_[*,1] LT trange[1],gd_eh_) ELSE gd_eh_ = 0
IF (n_ehb[0] GT 0) THEN good_ehb = WHERE(tse_ehb[*,0] GT trange[0] AND tse_ehb[*,1] LT trange[1],gd_ehb) ELSE gd_ehb = 0
IF (n_sf_[0] GT 0) THEN good_sf_ = WHERE(tse_sf_[*,0] GT trange[0] AND tse_sf_[*,1] LT trange[1],gd_sf_) ELSE gd_sf_ = 0
IF (n_sfb[0] GT 0) THEN good_sfb = WHERE(tse_sfb[*,0] GT trange[0] AND tse_sfb[*,1] LT trange[1],gd_sfb) ELSE gd_sfb = 0
IF (n_so_[0] GT 0) THEN good_so_ = WHERE(tse_so_[*,0] GT trange[0] AND tse_so_[*,1] LT trange[1],gd_so_) ELSE gd_so_ = 0
IF (n_sob[0] GT 0) THEN good_sob = WHERE(tse_sob[*,0] GT trange[0] AND tse_sob[*,1] LT trange[1],gd_sob) ELSE gd_sob = 0

IF (gd_pl_[0] GT 0) THEN gapl_ = apl_[good_pl_]
IF (gd_plb[0] GT 0) THEN gaplb = aplb[good_plb]
IF (gd_ph_[0] GT 0) THEN gaph_ = aph_[good_ph_]
IF (gd_phb[0] GT 0) THEN gaphb = aphb[good_phb]
IF (gd_el_[0] GT 0) THEN gael_ = ael_[good_el_]
IF (gd_elb[0] GT 0) THEN gaelb = aelb[good_elb]
IF (gd_eh_[0] GT 0) THEN gaeh_ = aeh_[good_eh_]
IF (gd_ehb[0] GT 0) THEN gaehb = aehb[good_ehb]
IF (gd_sf_[0] GT 0) THEN gasf_ = asf_[good_sf_]
IF (gd_sfb[0] GT 0) THEN gasfb = asfb[good_sfb]
IF (gd_so_[0] GT 0) THEN gaso_ = aso_[good_so_]
IF (gd_sob[0] GT 0) THEN gasob = asob[good_sob]

;;  Clean up
DELVAR,sp_pl_,sp_plb,sp_ph_,sp_phb,sp_el_,sp_elb,sp_eh_,sp_ehb,sp_sf_,sp_sfb,sp_so_,sp_sob
DELVAR,apl_,aplb,aph_,aphb,ael_,aelb,aeh_,aehb,asf_,asfb,aso_,asob
DELVAR,tse_pl_,tse_plb,tse_ph_,tse_phb,tse_el_,tse_elb,tse_eh_,tse_ehb,tse_sf_,tse_sfb,tse_so_,tse_sob
DELVAR,good_pl_,good_plb,good_ph_,good_phb,good_el_,good_elb,good_eh_,good_ehb,good_sf_,good_sfb,good_so_,good_sob












