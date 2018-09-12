;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Astronomical
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2016 AA values]
M_E            = 5.9722000d24             ;;  Earth's mass [kg, 2015 AA values]
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km

coord_ssl      = 'ssl'
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_mag      = 'mag'
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
;;  Define dummy time range arrays for later use
dt_70          = [-1,1]*7d1
dt_140         = [-1,1]*14d1
dt_200         = [-1,1]*20d1
dt_250         = [-1,1]*25d1
dt_400         = [-1,1]*40d1
;;----------------------------------------------------------------------------------------
;;  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe A

;;  Probe B

;;  Probe C

probe          = 'c'
tdate          = '2008-07-14'
date           = '071408'

probe          = 'c'
tdate          = '2008-08-19'   ;;  tons of shocklets and SLAMS for this pass
date           = '081908'

probe          = 'c'
tdate          = '2008-09-08'
date           = '090808'

probe          = 'c'
tdate          = '2008-09-16'
date           = '091608'

;;  Probe D

;;  Probe E

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@$HOME/Desktop/swidl-0.1/IDL_Stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE

;;  Plot FGM data
fgs_tpns       = scpref[0]+'fgs_'+[coord_mag[0],coord_gse[0]]
fgl_tpns       = scpref[0]+'fgl_'+[coord_mag[0],coord_gse[0]]
fgh_tpns       = scpref[0]+'fgh_'+[coord_mag[0],coord_gse[0]]
tra_all        = time_double(tr_00)
tplot,fgs_tpns,TRANGE=tra_all
tplot,fgl_tpns,TRANGE=tra_all
tplot,fgh_tpns,TRANGE=tra_all
;;----------------------------------------------------------------------------------------
;;  Define times of TIFP
;;----------------------------------------------------------------------------------------
;;  Define center-times for specific TIFP
IF (tdate[0] EQ '2008-07-14') THEN t_slam_cent = tdate[0]+'/'+['13:16:26','13:19:30']
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__cent = tdate[0]+'/'+['15:21:00','22:37:22']
IF (tdate[0] EQ '2008-07-14') THEN t_fb___cent = tdate[0]+'/'+['20:03:21','21:55:45','21:58:10']

IF (tdate[0] EQ '2008-08-19') THEN t_slam_cent = tdate[0]+'/'+['21:48:55','21:53:45','22:17:35','22:18:30','22:22:30','22:37:45','22:42:48']
IF (tdate[0] EQ '2008-08-19') THEN t_hfa__cent = tdate[0]+'/'+['12:50:57','21:46:17','22:41:00']
IF (tdate[0] EQ '2008-08-19') THEN t_fb___cent = tdate[0]+'/'+['20:43:35','21:51:45']

IF (tdate[0] EQ '2008-09-08') THEN t_slam_cent = tdate[0]+'/'+['17:28:23','20:24:50','20:36:11','21:12:24','21:15:33']
IF (tdate[0] EQ '2008-09-08') THEN t_hfa__cent = tdate[0]+'/'+['17:01:41','19:13:57','20:26:44']
IF (tdate[0] EQ '2008-09-08') THEN t_fb___cent = tdate[0]+'/20:25:22'

;;  Show location of SLAMS, HFAs, and FBs
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30
;;----------------------------------------------------------------------------------------
;;  Define relevant time ranges for calculating <Bo>, <No>, <Te>, etc.
;;----------------------------------------------------------------------------------------
;;  Define time range to use for foreshock overviews
IF (tdate[0] EQ '2008-07-14') THEN tr_bs_cal = time_double(tdate[0]+'/'+['11:52:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-08-19') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:00:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-09-08') THEN tr_bs_cal = time_double(tdate[0]+'/'+['16:30:00','21:32:00'])
IF (tdate[0] EQ '2008-07-14') THEN tra_overv = tr_bs_cal + [-1,1]*6d1*1d1                 ;;  expand by ±10 mins
IF (tdate[0] EQ '2008-08-19') THEN tra_overv = time_double(tr_jj) + [1,-6e0/4e0]*4d1*6d1  ;;  shrink by 40 minutes at start
IF (tdate[0] EQ '2008-09-08') THEN tra_overv = tr_bs_cal
;;  Define time of last bow shock crossings
IF (tdate[0] EQ '2008-07-14') THEN t_bs_last = time_double(tdate[0]+'/'+'12:32:18')
;;  Need upstream averages for later...
IF (tdate[0] EQ '2008-07-14') THEN t_slam_upst = time_double(tdate[0]+'/'+['13:43:00','13:43:00'])
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__upst = time_double(tdate[0]+'/'+['15:35:00','22:42:00'])
IF (tdate[0] EQ '2008-07-14') THEN t_fb___upst = time_double(tdate[0]+'/'+['20:42:00','22:30:00','22:30:00'])
IF (tdate[0] EQ '2008-07-14') THEN t_slam_upen = time_double(tdate[0]+'/'+['13:46:00','13:46:00'])
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__upen = time_double(tdate[0]+'/'+['15:38:00','22:45:00'])
IF (tdate[0] EQ '2008-07-14') THEN t_fb___upen = time_double(tdate[0]+'/'+['20:45:00','22:33:00','22:33:00'])
;;  Show location of time ranges
time_bar,t_slam_upst,COLOR=250
time_bar,t_hfa__upst,COLOR=150
time_bar,t_fb___upst,COLOR= 75
time_bar,t_slam_upen,COLOR=200
time_bar,t_hfa__upen,COLOR=100
time_bar,t_fb___upen,COLOR= 30
;;----------------------------------------------------------------------------------------
;;  Calculate <Bo>, <No>, <Te>, etc.
;;----------------------------------------------------------------------------------------
thm__magf_tpn  = fgl_tpns[1]
thm_vbulk_tpn  = scpref[0]+'peir_velocity_'+coord_gse[0]
thm_idens_tpn  = scpref[0]+'peir_density'
thm_itemp_tpn  = scpref[0]+'peir_avgtemp'
thm_etemp_tpn  = scpref[0]+'peer_avgtemp'
nna            = [fgl_tpns,thm_idens_tpn[0],thm_vbulk_tpn[0],thm_itemp_tpn[0],thm_etemp_tpn[0]]
  tplot,nna,TRANGE=tra_overv
  time_bar,t_slam_upst,COLOR=250
  time_bar,t_hfa__upst,COLOR=150
  time_bar,t_fb___upst,COLOR= 75
  time_bar,t_slam_upen,COLOR=200
  time_bar,t_hfa__upen,COLOR=100
  time_bar,t_fb___upen,COLOR= 30

;;  Get Bo [nT, GSE]
get_data,thm__magf_tpn[0],DATA=t_magf
;;  Get Vi [km/s, GSE]
get_data,thm_vbulk_tpn[0],DATA=t_visw
;;  Get Ni [cm^(-3), GSE]
get_data,thm_idens_tpn[0],DATA=t_iden
;;  Get Ti [eV, GSE]
get_data,thm_itemp_tpn[0],DATA=t_item
;;  Get Te [eV, GSE]
get_data,thm_etemp_tpn[0],DATA=t_etem
HELP,t_magf,t_visw,t_iden,t_item,t_etem
;;------------------------------------------
;;  Clip parameters to relevant time ranges
;;------------------------------------------
;;  1st define time ranges
nn_tr          = [N_ELEMENTS(t_slam_upst),N_ELEMENTS(t_hfa__upst),N_ELEMENTS(t_fb___upst)]
ntr            = N_ELEMENTS(nn_tr)
;ttags          = 'T'+STRTRIM(STRING(LINDGEN(ntr[0]),FORMAT='(I3.3)'),2)
ttags          = ['SLAMS','HFAS','FBS']
t_tifp_upst    = CREATE_STRUCT(ttags,t_slam_upst,t_hfa__upst,t_fb___upst)
t_tifp_upen    = CREATE_STRUCT(ttags,t_slam_upen,t_hfa__upen,t_fb___upen)
FOR j=0L, ntr[0] - 1L DO BEGIN                                                          $
  tra_0st = t_tifp_upst.(j)                                                           & $
  tra_0en = t_tifp_upen.(j)                                                           & $
  tra_0   = REPLICATE(d,nn_tr[j],2L)                                                  & $
  FOR k=0L, nn_tr[j] - 1L DO tra_0[k,*] = [tra_0st[k],tra_0en[k]]                     & $
  str_element,tr_tifp_up,ttags[j],tra_0,/ADD_REPLACE

;;  2nd define parameter structure
ptags          = ['MAGF','VBULK','NI','TI','TE']
pstruc         = CREATE_STRUCT(ptags,t_magf,t_visw,t_iden,t_item,t_etem)
nps            = N_TAGS(pstruc)
;;  3rd clip each parameter by each time range creating a new structure
pstr_0         = 0          ;;  Initialize variable
kstruc         = 0
FOR pp=0L, nps[0] - 1L DO BEGIN                                                          $     ;;  Parameters
  parm    = pstruc.(pp)                                                                & $
  dumb    = TEMPORARY(pstr_0)                                                          & $
  FOR tt=0L, ntr[0] - 1L DO BEGIN                                                        $     ;;  TIFP time ranges
    tra_0   = tr_tifp_up.(tt)                                                          & $
    ktags   = 'TR_'+STRTRIM(STRING(LINDGEN(nn_tr[tt]),FORMAT='(I3.3)'),2)              & $
    dumb    = TEMPORARY(kstruc)                                                        & $
    FOR kk=0L, nn_tr[tt] - 1L DO BEGIN                                                   $     ;;  Time ranges
      tran  = REFORM(tra_0[kk,*])                                                      & $
      temp  = trange_clip_data(parm,TRANGE=tran,PREC=3)                                & $
      str_element,kstruc,ktags[kk],temp,/ADD_REPLACE                                   & $
    ENDFOR                                                                             & $
    str_element,pstr_0,ttags[tt],kstruc,/ADD_REPLACE                                   & $
  ENDFOR                                                                               & $
  str_element,param_str,ptags[pp],pstr_0,/ADD_REPLACE

;;  4th calculate averages
pstr_0         = 0          ;;  Initialize variable
kstruc         = 0
FOR pp=0L, nps[0] - 1L DO BEGIN                                                          $     ;;  Parameters
  dumb    = TEMPORARY(pstr_0)                                                          & $
  FOR tt=0L, ntr[0] - 1L DO BEGIN                                                        $     ;;  TIFP time ranges
    ktags   = 'AVG_'+STRTRIM(STRING(LINDGEN(nn_tr[tt]),FORMAT='(I3.3)'),2)             & $
    dumb    = TEMPORARY(kstruc)                                                        & $
    FOR kk=0L, nn_tr[tt] - 1L DO BEGIN                                                   $     ;;  Time ranges
      parm    = param_str.(pp).(tt).(kk).Y                                             & $
      test    = average(parm,1,/NAN)                                                   & $
      str_element,kstruc,ktags[kk],test,/ADD_REPLACE                                   & $
    ENDFOR                                                                             & $
    str_element,pstr_0,ttags[tt],kstruc,/ADD_REPLACE                                   & $
  ENDFOR                                                                               & $
  str_element,param_avg,ptags[pp],pstr_0,/ADD_REPLACE


;;  Print out upstream average results [duplicates occur when two TIFP share the "same" upstreams]
linea          = ';;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
lineh          = pref[0]+'        Start            End            Box            Boy            Boz           Vix            Viy            Viz             Ni            Ti              Te'
line0          = ';;------------------------------------------'
pref           = ';;  '
eform          = '(f15.5)'
PRINT,linea[0]  & $
PRINT,lineh[0]  & $
PRINT,linea[0]  & $
FOR tt=0L, ntr[0] - 1L DO BEGIN                                                          $     ;;  TIFP time ranges
  PRINT,line0[0]                                                                       & $
  PRINT,pref[0]+ttags[tt]                                                              & $
  PRINT,line0[0]                                                                       & $
  tra_0     = tr_tifp_up.(tt)                                                          & $
  tout_st   = time_string(tra_0[*,0],PREC=0)                                           & $
  tout_en   = STRMID(time_string(tra_0[*,1],PREC=0),11L)                               & $
  tr_out    = tout_st+' - '+tout_en                                                    & $
  FOR kk=0L, nn_tr[tt] - 1L DO BEGIN                                                     $     ;;  Time ranges
    sout      = pref[0]+tr_out[kk]                                                     & $
    FOR pp=0L, nps[0] - 1L DO BEGIN                                                      $     ;;  Parameters
      parm = param_avg.(pp).(tt).(kk)                                                  & $
      sparm = STRING(parm,FORMAT=eform[0])                                             & $
      ns    = N_ELEMENTS(sparm)                                                        & $
      FOR ss=0L, ns[0] - 1L DO sout = sout[0]+sparm[ss]                                & $
    ENDFOR                                                                             & $
    PRINT,sout[0]                                                                      & $
  ENDFOR                                                                               & $
  test = (tt[0] EQ (ntr[0] - 1L))                                                      & $
  IF (test[0]) THEN PRINT,linea[0]

;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;          Start            End            Box            Boy            Boz           Vix            Viy            Viz             Ni            Ti              Te
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------
;;  SLAMS
;;------------------------------------------
;;  2008-07-14/13:43:00 - 13:46:00        0.85049       -0.31672        3.88123     -650.22908       90.15677       42.21723        1.91967      109.77699        8.23216
;;  2008-07-14/13:43:00 - 13:46:00        0.85049       -0.31672        3.88123     -650.22908       90.15677       42.21723        1.91967      109.77699        8.23216
;;------------------------------------------
;;  HFAS
;;------------------------------------------
;;  2008-07-14/15:35:00 - 15:38:00        2.48377       -2.48814        1.89316     -640.43485       82.70524       46.93154        1.64736      119.51045       10.19904
;;  2008-07-14/22:42:00 - 22:45:00        0.19018       -3.03753        1.62743     -641.21237       45.39197       43.38304        1.14985      160.68942        7.91641
;;------------------------------------------
;;  FBS
;;------------------------------------------
;;  2008-07-14/20:42:00 - 20:45:00        1.20617        0.49537        3.32983     -647.11353       92.40317       47.82591        1.53499      110.96140        7.75536
;;  2008-07-14/22:30:00 - 22:33:00        2.67225       -2.01985       -0.68892     -611.82270       67.34560       34.61422        1.40825      136.74590       10.34374
;;  2008-07-14/22:30:00 - 22:33:00        2.67225       -2.01985       -0.68892     -611.82270       67.34560       34.61422        1.40825      136.74590       10.34374
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Calculate bow shock parameters
;;----------------------------------------------------------------------------------------
;;    bow shock model [Slavin and Holzer, [1981]]
ecc            = (1.10 + 1.20)/2d0                       ;;  eccentricity      [Table 4 estimates]
Lsemi          = (22.9 + 23.5)/2d0                       ;;  semi-latus rectum [Re, Table 4 estimates]
xo             = 3.0d0                                   ;;  position of focus along X-axis
IF (tdate[0] EQ '2008-07-14') THEN xo = 2.40
;xo             = 1.2d0
bow            = {STANDOFF:Lsemi[0],ECCENTRICITY:ecc[0],X_OFFSET:xo[0]}
;;  Define model bow shock location for reference
n2             = 2000L
themx          = 11d1*!DPI/18d1
theta          = DINDGEN(n2)*2d0*themx[0]/((n2 - 1L)) - themx[0]  ;;  radians
rad            = Lsemi[0]/(1d0 + ecc[0]*COS(theta))               ;;  Distance from focus [Re]
rad_sh         = xo[0] + rad                                      ;;  radial distance (polar) to BS [Re]
the_sh         = theta                                            ;;  polar angle [radians]
;;  Define some circles of constant radius for reference
nc             = 10L
na             = 100L
circs          = DINDGEN(nc[0])*5d0 + 5d0
the            = DINDGEN(na[0])*2d0*!DPI/(na[0] - 1L)
circx          = REPLICATE(d,nc,na[0])
circy          = REPLICATE(d,nc,na[0])
FOR j=0L, nc - 1L DO BEGIN             $
  circx[j,*] = circs[j]*COS(the)     & $
  circy[j,*] = circs[j]*SIN(the)
;;----------------------------------------------------------------------------------------
;;  Plot orbit for reference
;;    -->  Below is example for 2008-07-14
;;----------------------------------------------------------------------------------------
;;  Open a window
wi,1,xsize=800,ysize=800
wi,2,xsize=800,ysize=800
;;  Get Bo [nT, GSE]
get_data,fgl_tpns[1],DATA=thm_gse_mag
;;  Get SC position [km, GSE]
get_data,scpref[0]+'state_pos_'+coord_gse[0],DATA=thm_gse_pos
;;------------------------------------------
;;  Define parameters
;;------------------------------------------
posi_t         = thm_gse_pos.X                 ;;  Unix times for positions
posi_x         = thm_gse_pos.Y[*,0]/R_E[0]     ;;  Xgse position, km --> Re
posi_y         = thm_gse_pos.Y[*,1]/R_E[0]     ;;  Ygse position, km --> Re
posi_z         = thm_gse_pos.Y[*,2]/R_E[0]     ;;  Zgse position, km --> Re
posi_xyz       = [[posi_x],[posi_y],[posi_z]]
;;  Clip position data to only show foreshock pass
struc          = {X:posi_t,Y:posi_xyz}
temp2          = trange_clip_data(struc,TRANGE=tra_overv,PREC=3)
temp3          = trange_clip_data(thm_gse_mag,TRANGE=tra_overv,PREC=3)
;;  Redefine parameters
posi_t         = temp2.X                       ;;  Unix times for positions
posi_xyz       = temp2.Y                       ;;  XYZ GSE positions [Re]
norb           = N_ELEMENTS(posi_xyz[*,0])
se             = [0L,norb[0] - 1L]
;;  Increase time resolution for positions of TIFP
vec_v          = posi_xyz
vec_t          = posi_t
new_t          = temp3.X
ups_posi       = resample_2d_vec(vec_v,vec_t,new_t,/SPLINE,/NO_EXTRAPOLATE)
;;  Define SC locations at time of events
ind_slam       = VALUE_LOCATE(new_t,time_double(t_slam_cent))
ind__hfa       = VALUE_LOCATE(new_t,time_double(t_hfa__cent))
ind___fb       = VALUE_LOCATE(new_t,time_double(t_fb___cent))
ind_bscr       = VALUE_LOCATE(new_t,time_double(t_bs_last))
;;------------------------------------------
;;  Setup plot params
;;------------------------------------------
x_ran          = [-1./20.,1]*20e0                ;;  Use -1 -- +20 Re for X-range
y_ran          = [-1,1]*10e0                   ;;  Use ±10 Re for Y-range
z_ran          = [-1,1]*10e0                   ;;  Use ±10 Re for Z-range
xyzrange       = [[x_ran],[y_ran],[z_ran]]
thck           = 2e0                           ;;  for THICK keyword
thck_s         = [2e0,1e0]
sysz_s         = [1e0,2e0]                     ;;  for SYMSIZE keyword
tr_ttl0        = time_string(tra_overv,PREC=3)
tr_ttl1        = tr_ttl0[0]+' - '+STRMID(tr_ttl0[1],11)
pttl           = 'TH'+scu[0]+':  Foreshock Orbit '+tr_ttl1[0]
xttl           = 'Xgse [Re] (Diamond = SLAMS, Triangle = HFA, Square = FB)'
yttl           = 'Ygse [Re] (start = +, end = X, last BS crossing = *)'
zttl           = 'Zgse [Re] (start = +, end = X, last BS crossing = *)'
pstr_yx        = {XRANGE:x_ran,YRANGE:y_ran,XSTYLE:1,YSTYLE:1,NODATA:1,TITLE:pttl[0],$
                  XTITLE:xttl[0],YTITLE:yttl[0],THICK:thck[0]}
pstr_zx        = {XRANGE:x_ran,YRANGE:z_ran,XSTYLE:1,YSTYLE:1,NODATA:1,TITLE:pttl[0],$
                  XTITLE:xttl[0],YTITLE:zttl[0],THICK:thck[0]}
;;  Define plotting data
xyz_pos_slam   = ups_posi[ind_slam,*]
xyz_pos__hfa   = ups_posi[ind__hfa,*]
xyz_pos___fb   = ups_posi[ind___fb,*]
xyz_pos_bscr   = ups_posi[ind_bscr,*]
nn_tifp        = [N_ELEMENTS(xyz_pos_slam[*,0]),N_ELEMENTS(xyz_pos__hfa[*,0]),N_ELEMENTS(xyz_pos___fb[*,0])]
xyz_pos_str    = CREATE_STRUCT(ttags,xyz_pos_slam,xyz_pos__hfa,xyz_pos___fb)
;;------------------------------------------
;;  Define arrows for output
;;------------------------------------------
barrxy_str     = 0
barrxz_str     = 0
varrxy_str     = 0
varrxz_str     = 0
arr_len        = 2d0
xyind          = [0,1]
xzind          = [0,2]
vec_str        = ['x','y','z']
arr_tags       = [vec_str[0:1]+'0',vec_str[0:1]+'1']
FOR tt=0L, ntr[0] - 1L DO BEGIN                                                          $     ;;  TIFP time ranges
  xyz_0    = xyz_pos_str.(tt)                                                          & $
  dumb      = TEMPORARY(barrxy_str)                                                    & $
  dumb      = TEMPORARY(barrxz_str)                                                    & $
  dumb      = TEMPORARY(varrxy_str)                                                    & $
  dumb      = TEMPORARY(varrxz_str)                                                    & $
  ktags     = 'ARROW_'+STRTRIM(STRING(LINDGEN(nn_tr[tt]),FORMAT='(I3.3)'),2)           & $
  FOR kk=0L, nn_tr[tt] - 1L DO BEGIN                                                     $     ;;  Time ranges
    bvec_0 = param_avg.(0).(tt).(kk)                                                   & $
    vvec_0 = param_avg.(1).(tt).(kk)                                                   & $
    arr_st = REFORM(xyz_0[kk,*])                                                       & $
    ubvec  = unit_vec(bvec_0,/NAN)                                                     & $
    uvvec  = unit_vec(vvec_0,/NAN)                                                     & $
    ubv_mgs = [mag__vec([ubvec[xyind],0d0],/NAN),mag__vec([0d0,ubvec[xzind]],/NAN)]    & $
    uvv_mgs = [mag__vec([uvvec[xyind],0d0],/NAN),mag__vec([0d0,uvvec[xzind]],/NAN)]    & $
    arr_bxy_en = arr_len[0]*ubvec[xyind]/ubv_mgs[0] + arr_st[xyind]                    & $
    arr_bxz_en = arr_len[0]*ubvec[xzind]/ubv_mgs[1] + arr_st[xzind]                    & $
    arr_vxy_en = arr_len[0]*uvvec[xyind]/uvv_mgs[0] + arr_st[xyind]                    & $
    arr_vxz_en = arr_len[0]*uvvec[xzind]/uvv_mgs[1] + arr_st[xzind]                    & $
    arr_bxy = CREATE_STRUCT(arr_tags,arr_st[0],arr_st[1],arr_bxy_en[0],arr_bxy_en[1])  & $
    arr_bxz = CREATE_STRUCT(arr_tags,arr_st[0],arr_st[2],arr_bxz_en[0],arr_bxz_en[1])  & $
    arr_vxy = CREATE_STRUCT(arr_tags,arr_st[0],arr_st[1],arr_vxy_en[0],arr_vxy_en[1])  & $
    arr_vxz = CREATE_STRUCT(arr_tags,arr_st[0],arr_st[2],arr_vxz_en[0],arr_vxz_en[1])  & $
    str_element,barrxy_str,ktags[kk],arr_bxy,/ADD_REPLACE                              & $
    str_element,barrxz_str,ktags[kk],arr_bxz,/ADD_REPLACE                              & $
    str_element,varrxy_str,ktags[kk],arr_vxy,/ADD_REPLACE                              & $
    str_element,varrxz_str,ktags[kk],arr_vxz,/ADD_REPLACE                              & $
  ENDFOR                                                                               & $
  str_element,bxy_arrows,ttags[tt],barrxy_str,/ADD_REPLACE                             & $
  str_element,bxz_arrows,ttags[tt],barrxz_str,/ADD_REPLACE                             & $
  str_element,vxy_arrows,ttags[tt],varrxy_str,/ADD_REPLACE                             & $
  str_element,vxz_arrows,ttags[tt],varrxz_str,/ADD_REPLACE

;;------------------------------------------
;;  Plot:  Ygse vs. Xgse Plane
;;------------------------------------------
ix             = 0L             ;;  Index for horizontal axis
iy             = 1L             ;;  Index for vertical axis
b_arrows       = bxy_arrows
v_arrows       = vxy_arrows
pstr           = pstr_yx
WSET,1
WSHOW,1
IF (!D.NAME[0] EQ 'PS') THEN lthck = thck_s[0] ELSE lthck = thck_s[1]
IF (!D.NAME[0] EQ 'PS') THEN sysz  = sysz_s[0] ELSE sysz  = sysz_s[1]
;;  Initialize plot
PLOT,posi_xyz[*,ix],posi_xyz[*,iy],_EXTRA=pstr
  ;;  Output crosshairs to show origin
  OPLOT,REFORM(xyzrange[*,ix]),[0,0],COLOR=20,THICK=thck[0]
  OPLOT,[0,0],REFORM(xyzrange[*,iy]),COLOR=20,THICK=thck[0]
  ;;  Output circles of constant radii
  FOR j=0L, nc - 1L DO OPLOT,REFORM(circx[j,*]),REFORM(circy[j,*]),LINESTYLE=2
  ;;  Output Model Bow Shock Location [Slavin and Holzer, [1990,1991]]
  OPLOT,rad_sh,the_sh,/POLAR,COLOR=200,THICK=lthck[0]
  ;;  Output spacecraft position
  OPLOT,posi_xyz[*,ix],posi_xyz[*,iy],COLOR= 50,LINESTYLE=0,THICK=lthck[0]
  ;;  Output start/end location spacecraft position
  OPLOT,[posi_xyz[se[0],ix]],[posi_xyz[se[0],iy]],COLOR= 20,PSYM=1,SYMSIZE=sysz[0]
  OPLOT,[posi_xyz[se[1],ix]],[posi_xyz[se[1],iy]],COLOR= 20,PSYM=7,SYMSIZE=sysz[0]
  ;;  Output TIFP locations along spacecraft trajectory
  FOR j=0L, nn_tifp[0] - 1L DO OPLOT,[xyz_pos_slam[j,ix]],[xyz_pos_slam[j,iy]],COLOR=250,PSYM=4,SYMSIZE=sysz[0]
  FOR j=0L, nn_tifp[1] - 1L DO OPLOT,[xyz_pos__hfa[j,ix]],[xyz_pos__hfa[j,iy]],COLOR=200,PSYM=5,SYMSIZE=sysz[0]
  FOR j=0L, nn_tifp[2] - 1L DO OPLOT,[xyz_pos___fb[j,ix]],[xyz_pos___fb[j,iy]],COLOR= 30,PSYM=6,SYMSIZE=sysz[0]
  ;;  Output last BS crossing location along spacecraft trajectory
  OPLOT,[xyz_pos_bscr[0,ix]],[xyz_pos_bscr[0,iy]],PSYM=2,SYMSIZE=sysz[0]
  ;;  Output Avg. Bo and Vsw at each TIFP
  FOR tt=0L, ntr[0] - 1L DO BEGIN                                                          $     ;;  TIFP time ranges
    FOR kk=0L, nn_tr[tt] - 1L DO BEGIN                                                     $     ;;  Time ranges
      b_arr = b_arrows.(tt).(kk)                                                         & $
      v_arr = v_arrows.(tt).(kk)                                                         & $
      ARROW,b_arr.X0,b_arr.Y0,b_arr.X1,b_arr.Y1,COLOR=250,/DATA,THICK=lthck[0]           & $
      ARROW,v_arr.X0,v_arr.Y0,v_arr.X1,v_arr.Y1,COLOR=150,/DATA,THICK=lthck[0]
  ;;  Output Avg. Bo and Vsw labels
  XYOUTS,0.15,0.50,'Avg. Bo',/NORMAL,COLOR=250
  XYOUTS,0.15,0.45,'Avg. Vbulk',/NORMAL,COLOR=150

;;------------------------------------------
;;  Plot:  Zgse vs. Xgse Plane
;;------------------------------------------
ix             = 0L             ;;  Index for horizontal axis
iy             = 2L             ;;  Index for vertical axis
b_arrows       = bxz_arrows
v_arrows       = vxz_arrows
pstr           = pstr_zx
WSET,2
WSHOW,2
IF (!D.NAME[0] EQ 'PS') THEN lthck = thck_s[0] ELSE lthck = thck_s[1]
IF (!D.NAME[0] EQ 'PS') THEN sysz  = sysz_s[0] ELSE sysz  = sysz_s[1]
;;  Initialize plot
PLOT,posi_xyz[*,ix],posi_xyz[*,iy],_EXTRA=pstr
  ;;  Output crosshairs to show origin
  OPLOT,REFORM(xyzrange[*,ix]),[0,0],COLOR=20,THICK=thck[0]
  OPLOT,[0,0],REFORM(xyzrange[*,iy]),COLOR=20,THICK=thck[0]
  ;;  Output circles of constant radii
  FOR j=0L, nc - 1L DO OPLOT,REFORM(circx[j,*]),REFORM(circy[j,*]),LINESTYLE=2
  ;;  Output Model Bow Shock Location [Slavin and Holzer, [1990,1991]]
  OPLOT,rad_sh,the_sh,/POLAR,COLOR=200,THICK=lthck[0]
  ;;  Output spacecraft position
  OPLOT,posi_xyz[*,ix],posi_xyz[*,iy],COLOR= 50,LINESTYLE=0,THICK=lthck[0]
  ;;  Output start/end location spacecraft position
  OPLOT,[posi_xyz[se[0],ix]],[posi_xyz[se[0],iy]],COLOR= 20,PSYM=1,SYMSIZE=sysz[0]
  OPLOT,[posi_xyz[se[1],ix]],[posi_xyz[se[1],iy]],COLOR= 20,PSYM=7,SYMSIZE=sysz[0]
  ;;  Output TIFP locations along spacecraft trajectory
  FOR j=0L, nn_tifp[0] - 1L DO OPLOT,[xyz_pos_slam[j,ix]],[xyz_pos_slam[j,iy]],COLOR=250,PSYM=4,SYMSIZE=sysz[0]
  FOR j=0L, nn_tifp[1] - 1L DO OPLOT,[xyz_pos__hfa[j,ix]],[xyz_pos__hfa[j,iy]],COLOR=200,PSYM=5,SYMSIZE=sysz[0]
  FOR j=0L, nn_tifp[2] - 1L DO OPLOT,[xyz_pos___fb[j,ix]],[xyz_pos___fb[j,iy]],COLOR= 30,PSYM=6,SYMSIZE=sysz[0]
  ;;  Output last BS crossing location along spacecraft trajectory
  OPLOT,[xyz_pos_bscr[0,ix]],[xyz_pos_bscr[0,iy]],PSYM=2,SYMSIZE=sysz[0]
  ;;  Output Avg. Bo and Vsw at each TIFP
  FOR tt=0L, ntr[0] - 1L DO BEGIN                                                          $     ;;  TIFP time ranges
    FOR kk=0L, nn_tr[tt] - 1L DO BEGIN                                                     $     ;;  Time ranges
      b_arr = b_arrows.(tt).(kk)                                                         & $
      v_arr = v_arrows.(tt).(kk)                                                         & $
      ARROW,b_arr.X0,b_arr.Y0,b_arr.X1,b_arr.Y1,COLOR=250,/DATA,THICK=lthck[0]           & $
      ARROW,v_arr.X0,v_arr.Y0,v_arr.X1,v_arr.Y1,COLOR=150,/DATA,THICK=lthck[0]
  ;;  Output Avg. Bo and Vsw labels
  XYOUTS,0.15,0.50,'Avg. Bo',/NORMAL,COLOR=250
  XYOUTS,0.15,0.45,'Avg. Vbulk',/NORMAL,COLOR=150



;;------------------------------------------
;;  Define parameters for saving
;;------------------------------------------
;;  Define POPEN structure for saving
postruc        = {PORT:1,UNITS:'inches',XSIZE:8.,YSIZE:8.,ASPECT:1.}
;;  Define file names
fnm_times      = file_name_times(tra_overv,PREC=0)
f_times        = fnm_times.F_TIME[0]+'-'+STRMID(fnm_times.F_TIME[1],11L)
fpref          = 'THM-'+scu[0]+'_foreshock_orbit_'
fmid           = 'TIFP-centers_red-SLAMS_orange-HFA_purple-FB_'
fplanes        = ['Ygse','Zgse']+'_vs_Xgse_Plane_'
fnames         = fpref[0]+fmid[0]+fplanes+f_times[0]
;;------------------------------------------
;;  Save:  Ygse vs. Xgse Plane
;;------------------------------------------
ix             = 0L             ;;  Index for horizontal axis
iy             = 1L             ;;  Index for vertical axis
b_arrows       = bxy_arrows
v_arrows       = vxy_arrows
pstr           = pstr_yx
popen,fnames[0],_EXTRA=postruc
  IF (!D.NAME[0] EQ 'PS') THEN lthck = thck_s[0] ELSE lthck = thck_s[1]
  IF (!D.NAME[0] EQ 'PS') THEN sysz  = sysz_s[0] ELSE sysz  = sysz_s[1]
  ;;  Initialize plot
  PLOT,posi_xyz[*,ix],posi_xyz[*,iy],_EXTRA=pstr
    ;;  Output crosshairs to show origin
    OPLOT,REFORM(xyzrange[*,ix]),[0,0],COLOR=20,THICK=thck[0]
    OPLOT,[0,0],REFORM(xyzrange[*,iy]),COLOR=20,THICK=thck[0]
    ;;  Output circles of constant radii
    FOR j=0L, nc - 1L DO OPLOT,REFORM(circx[j,*]),REFORM(circy[j,*]),LINESTYLE=2
    ;;  Output Model Bow Shock Location [Slavin and Holzer, [1990,1991]]
    OPLOT,rad_sh,the_sh,/POLAR,COLOR=200,THICK=lthck[0]
    ;;  Output spacecraft position
    OPLOT,posi_xyz[*,ix],posi_xyz[*,iy],COLOR= 50,LINESTYLE=0,THICK=lthck[0]
    ;;  Output start/end location spacecraft position
    OPLOT,[posi_xyz[se[0],ix]],[posi_xyz[se[0],iy]],COLOR= 20,PSYM=1,SYMSIZE=sysz[0]
    OPLOT,[posi_xyz[se[1],ix]],[posi_xyz[se[1],iy]],COLOR= 20,PSYM=7,SYMSIZE=sysz[0]
    ;;  Output TIFP locations along spacecraft trajectory
    FOR j=0L, nn_tifp[0] - 1L DO OPLOT,[xyz_pos_slam[j,ix]],[xyz_pos_slam[j,iy]],COLOR=250,PSYM=4,SYMSIZE=sysz[0]
    FOR j=0L, nn_tifp[1] - 1L DO OPLOT,[xyz_pos__hfa[j,ix]],[xyz_pos__hfa[j,iy]],COLOR=200,PSYM=5,SYMSIZE=sysz[0]
    FOR j=0L, nn_tifp[2] - 1L DO OPLOT,[xyz_pos___fb[j,ix]],[xyz_pos___fb[j,iy]],COLOR= 30,PSYM=6,SYMSIZE=sysz[0]
    ;;  Output last BS crossing location along spacecraft trajectory
    OPLOT,[xyz_pos_bscr[0,ix]],[xyz_pos_bscr[0,iy]],PSYM=2,SYMSIZE=sysz[0]
    ;;  Output Avg. Bo and Vsw at each TIFP
    FOR tt=0L, ntr[0] - 1L DO BEGIN                                                          $     ;;  TIFP time ranges
      FOR kk=0L, nn_tr[tt] - 1L DO BEGIN                                                     $     ;;  Time ranges
        b_arr = b_arrows.(tt).(kk)                                                         & $
        v_arr = v_arrows.(tt).(kk)                                                         & $
        ARROW,b_arr.X0,b_arr.Y0,b_arr.X1,b_arr.Y1,COLOR=250,/DATA,THICK=lthck[0]           & $
        ARROW,v_arr.X0,v_arr.Y0,v_arr.X1,v_arr.Y1,COLOR=150,/DATA,THICK=lthck[0]
    ;;  Output Avg. Bo and Vsw labels
    XYOUTS,0.15,0.50,'Avg. Bo',/NORMAL,COLOR=250
    XYOUTS,0.15,0.45,'Avg. Vbulk',/NORMAL,COLOR=150
pclose

;;------------------------------------------
;;  Save:  Zgse vs. Xgse Plane
;;------------------------------------------
ix             = 0L             ;;  Index for horizontal axis
iy             = 2L             ;;  Index for vertical axis
b_arrows       = bxz_arrows
v_arrows       = vxz_arrows
pstr           = pstr_zx
popen,fnames[1],_EXTRA=postruc
  IF (!D.NAME[0] EQ 'PS') THEN lthck = thck_s[0] ELSE lthck = thck_s[1]
  IF (!D.NAME[0] EQ 'PS') THEN sysz  = sysz_s[0] ELSE sysz  = sysz_s[1]
  ;;  Initialize plot
  PLOT,posi_xyz[*,ix],posi_xyz[*,iy],_EXTRA=pstr
    ;;  Output crosshairs to show origin
    OPLOT,REFORM(xyzrange[*,ix]),[0,0],COLOR=20,THICK=thck[0]
    OPLOT,[0,0],REFORM(xyzrange[*,iy]),COLOR=20,THICK=thck[0]
    ;;  Output circles of constant radii
    FOR j=0L, nc - 1L DO OPLOT,REFORM(circx[j,*]),REFORM(circy[j,*]),LINESTYLE=2
    ;;  Output Model Bow Shock Location [Slavin and Holzer, [1990,1991]]
    OPLOT,rad_sh,the_sh,/POLAR,COLOR=200,THICK=lthck[0]
    ;;  Output spacecraft position
    OPLOT,posi_xyz[*,ix],posi_xyz[*,iy],COLOR= 50,LINESTYLE=0,THICK=lthck[0]
    ;;  Output start/end location spacecraft position
    OPLOT,[posi_xyz[se[0],ix]],[posi_xyz[se[0],iy]],COLOR= 20,PSYM=1,SYMSIZE=sysz[0]
    OPLOT,[posi_xyz[se[1],ix]],[posi_xyz[se[1],iy]],COLOR= 20,PSYM=7,SYMSIZE=sysz[0]
    ;;  Output TIFP locations along spacecraft trajectory
    FOR j=0L, nn_tifp[0] - 1L DO OPLOT,[xyz_pos_slam[j,ix]],[xyz_pos_slam[j,iy]],COLOR=250,PSYM=4,SYMSIZE=sysz[0]
    FOR j=0L, nn_tifp[1] - 1L DO OPLOT,[xyz_pos__hfa[j,ix]],[xyz_pos__hfa[j,iy]],COLOR=200,PSYM=5,SYMSIZE=sysz[0]
    FOR j=0L, nn_tifp[2] - 1L DO OPLOT,[xyz_pos___fb[j,ix]],[xyz_pos___fb[j,iy]],COLOR= 30,PSYM=6,SYMSIZE=sysz[0]
    ;;  Output last BS crossing location along spacecraft trajectory
    OPLOT,[xyz_pos_bscr[0,ix]],[xyz_pos_bscr[0,iy]],PSYM=2,SYMSIZE=sysz[0]
    ;;  Output Avg. Bo and Vsw at each TIFP
    FOR tt=0L, ntr[0] - 1L DO BEGIN                                                          $     ;;  TIFP time ranges
      FOR kk=0L, nn_tr[tt] - 1L DO BEGIN                                                     $     ;;  Time ranges
        b_arr = b_arrows.(tt).(kk)                                                         & $
        v_arr = v_arrows.(tt).(kk)                                                         & $
        ARROW,b_arr.X0,b_arr.Y0,b_arr.X1,b_arr.Y1,COLOR=250,/DATA,THICK=lthck[0]           & $
        ARROW,v_arr.X0,v_arr.Y0,v_arr.X1,v_arr.Y1,COLOR=150,/DATA,THICK=lthck[0]
    ;;  Output Avg. Bo and Vsw labels
    XYOUTS,0.15,0.50,'Avg. Bo',/NORMAL,COLOR=250
    XYOUTS,0.15,0.45,'Avg. Vbulk',/NORMAL,COLOR=150
pclose





