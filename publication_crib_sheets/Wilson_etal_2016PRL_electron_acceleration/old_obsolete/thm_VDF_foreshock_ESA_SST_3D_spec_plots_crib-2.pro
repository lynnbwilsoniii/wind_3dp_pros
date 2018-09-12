;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
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
no_load_vdfs   = 0b                    ;;  --> do load particle VDFs
;no_load_vdfs   = 1b                    ;;  --> do NOT load particle VDFs

ex_start       = SYSTIME(1)            ;;  Time the execution of all events within
@$HOME/Desktop/swidl-0.1/IDL_Stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_all_data_batch.pro
MESSAGE,STRING(SYSTIME(1) - ex_start[0])+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;;  Default to entire day
tr_00          = tdate[0]+'/'+['00:00:00.000','23:59:59.999']
;;  Define time range to use for foreshock overviews
IF (tdate[0] EQ '2008-07-14') THEN tr_bs_cal = time_double(tdate[0]+'/'+['11:52:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-08-19') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:00:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-09-08') THEN tr_bs_cal = time_double(tdate[0]+'/'+['16:30:00','21:32:00'])
IF (tdate[0] EQ '2008-09-16') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:20:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-07-14') THEN tra_overv = tr_bs_cal + [-1,1]*6d1*1d1                 ;;  expand by ±10 mins
IF (tdate[0] EQ '2008-08-19') THEN tra_overv = tr_bs_cal + [1,0e0]*4d1*6d1                ;;  shrink by 40 minutes at start
IF (tdate[0] EQ '2008-09-08') THEN tra_overv = tr_bs_cal
IF (tdate[0] EQ '2008-09-16') THEN tra_overv = tr_bs_cal
;;  Define time of last (i.e., crossing at largest distance from Earth) bow shock crossings
IF (tdate[0] EQ '2008-07-14') THEN t_bs_last = time_double(tdate[0]+'/'+'12:32:18')
IF (tdate[0] EQ '2008-08-19') THEN t_bs_last = time_double(tdate[0]+'/'+'22:43:42')
IF (tdate[0] EQ '2008-09-08') THEN t_bs_last = time_double(tdate[0]+'/'+'21:18:10')
IF (tdate[0] EQ '2008-09-16') THEN t_bs_last = time_double(tdate[0]+'/'+'18:08:50')
;;  Define center-times for specific TIFP
IF (tdate[0] EQ '2008-07-14') THEN t_slam_cent = tdate[0]+'/'+['13:16:26','13:19:30']
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__cent = tdate[0]+'/'+['15:21:00','22:37:22']
IF (tdate[0] EQ '2008-07-14') THEN t_fb___cent = tdate[0]+'/'+['20:03:21','21:55:45','21:58:10']

IF (tdate[0] EQ '2008-08-19') THEN t_slam_cent = tdate[0]+'/'+['21:48:55','21:53:45','22:17:35','22:18:30','22:22:30','22:37:45','22:42:48']
IF (tdate[0] EQ '2008-08-19') THEN t_hfa__cent = tdate[0]+'/'+['12:50:57','21:46:17','22:41:00']
IF (tdate[0] EQ '2008-08-19') THEN t_fb___cent = tdate[0]+'/'+['20:43:35','21:51:45']

IF (tdate[0] EQ '2008-09-08') THEN t_slam_cent = tdate[0]+'/'+['17:28:23','20:24:50','20:36:11','21:12:24','21:15:33']
IF (tdate[0] EQ '2008-09-08') THEN t_hfa__cent = tdate[0]+'/'+['17:01:41','19:13:57','20:26:44']
IF (tdate[0] EQ '2008-09-08') THEN t_fb___cent = tdate[0]+'/'+['20:25:22']

IF (tdate[0] EQ '2008-09-16') THEN t_slam_cent = tdate[0]+'/'+['00:00:00']
IF (tdate[0] EQ '2008-09-16') THEN t_hfa__cent = tdate[0]+'/'+['17:26:45']
IF (tdate[0] EQ '2008-09-16') THEN t_fb___cent = tdate[0]+'/'+['17:46:13']

tlimit,tra_overv

;;  Plot FGM data
tplot,fgs_tpns,TRANGE=tra_overv
tplot,fgl_tpns,TRANGE=tra_overv
tplot,fgh_tpns,TRANGE=tra_overv
;;  Show location of SLAMS, HFAs, and FBs
time_bar,t_slam_cent,COLOR=250
time_bar,t_hfa__cent,COLOR=200
time_bar,t_fb___cent,COLOR= 30
;;----------------------------------------------------------------------------------------
;;  Plot individual spectra
;;----------------------------------------------------------------------------------------
;;  Below is an example for the THC 2008-07-14 foreshock pass
tra0           = (time_double(t_fb___cent[2]) + dt_250) + [-0.4,4]*5d1
;tra0           = REFORM(tr_fb___250[2,*]) + [-0.4,4]*5d1
nna            = [fgh_tpns,eeomni_fac[0],ieomni_fac[0],sebfomnifac[0],sifomnifac[0]]
  tplot,nna,TRANGE=tra0
  time_bar,t_slam_cent,COLOR=250
  time_bar,t_hfa__cent,COLOR=200
  time_bar,t_fb___cent,COLOR= 30
;;  Get example structures
;dat0           = dat_e
dat0           = dat_egse
dat1           = dat_seb
;;  Limit to time range with enhancements
tra1           = MEAN(time_double(t_fb___cent[2]) + dt_70,/NAN) + [-1,1]*6d1  ;;  in this case, ±1 minute
;tra1           = MEAN(tr_fb___70[2,*],/NAN) + [-1,1]*6d1  ;;  in this case, ±1 minute
test0          = (dat0.TIME GE tra1[0]) AND (dat0.END_TIME LE tra1[1])
test1          = (dat1.TIME GE tra1[0]) AND (dat1.END_TIME LE tra1[1])
good0          = WHERE(test0,gd0)
good1          = WHERE(test1,gd1)
PRINT,';;',gd0,gd1,'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;          38          38  For Probe:  THC on 2008-07-14


;;  Define the units in which to plot data
;units          = 'flux'
;units          = 'eflux'
units          = 'df'
IF (units[0] EQ 'flux') THEN yran_esa = [1e-1,1e6]
IF (units[0] EQ 'flux') THEN yran_sst = [1e-4,2e-1]
IF (units[0] EQ   'df') THEN yran_esa = [1e-19,2e-12]
IF (units[0] EQ   'df') THEN yran_sst = [1e-26,1e-20]
xran_esa       = [5e1,2e4]
xran_sst       = [1e4,2e5]
;;  Setup options
lim0           = {XSTYLE:1,YSTYLE:1,XMINOR:9,YMINOR:9,XMARGIN:[10,10],YMARGIN:[5,5],XLOG:1,YLOG:1}
extract_tags,lime_str,lim0
extract_tags,lims_str,lim0
str_element,lime_str, 'XRANGE',     xran_esa,/ADD_REPLACE
str_element,lime_str, 'YRANGE',     yran_esa,/ADD_REPLACE
str_element,lims_str, 'XRANGE',     xran_sst,/ADD_REPLACE
str_element,lims_str, 'YRANGE',     yran_sst,/ADD_REPLACE


sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
imax           = MIN([gd0[0],gd1[0]],/NAN)
exsuffx        = 'BVec'
leg_sffx       = '(Bo)'
.compile $HOME/Desktop/temp_idl/temp_plot_esa_sst_combined_spec3d.pro
dat00          = dat0[good0]
dat11          = dat1[good1]
FOR ii=0L, imax[0] - 1L DO BEGIN                                                          $
  tdate_sw       = dat00[ii]                                                            & $
  tdats_sw       = dat11[ii]                                                            & $
  p_angle        = 1b                                                                   & $
  sundir         = 0b                                                                   & $
  vec            = 0b                                                                   & $
  temp_plot_esa_sst_combined_spec3d,tdate_sw,tdats_sw,LIM_ESA=lime_str,LIM_SST=lims_str,  $
                                    ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                  $
                                    SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,    $
                                    SUNDIR=sundir,VECTOR=vec,UNITS=units,EX_SUFFX=exsuffx,$
                                    LEG_SFFX=leg_sffx

;;  Define Earth direction for each distribution
sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
imax           = MIN([gd0[0],gd1[0]],/NAN)
exsuffx        = 'EarthDir'
leg_sffx       = '(Earth Dir.)'
.compile $HOME/Desktop/temp_idl/temp_plot_esa_sst_combined_spec3d.pro
dat00          = dat0[good0]
dat11          = dat1[good1]
dat00.MAGF     = TRANSPOSE(avg_eesa_earth[good0,*])
dat11.MAGF     = TRANSPOSE(avg_essb_earth[good1,*])
FOR ii=0L, imax[0] - 1L DO BEGIN                                                          $
  tdate_sw       = dat00[ii]                                                            & $
  tdats_sw       = dat11[ii]                                                            & $
  p_angle        = 1b                                                                   & $
  sundir         = 0b                                                                   & $
  vec            = 0b                                                                   & $
  temp_plot_esa_sst_combined_spec3d,tdate_sw,tdats_sw,LIM_ESA=lime_str,LIM_SST=lims_str,  $
                                    ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                  $
                                    SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,    $
                                    SUNDIR=sundir,VECTOR=vec,UNITS=units,EX_SUFFX=exsuffx,$
                                    LEG_SFFX=leg_sffx


;;----------------------------------------------------------------------------------------
;;  Use FB shock normal [for 2008-07-14 THC FB at ~21:58:00 UT only]
;;    --> ~/Desktop/TPLOT_THEMIS_PLOTS/Results_produced_for_others/DrewTurner_Foreshock_Bubble/cribs/DTurner_foreshock_bubble_RH-Solns_crib.pro
;;----------------------------------------------------------------------------------------
;;  Avg. terms for 1st shock paramters
avg_magf_up    = [   3.59595d0,0.45215d0,-2.71916d0]
avg_vswi_up    = [-616.03000d0,68.28110d0,31.65950d0]
bmag_up        = NORM(avg_magf_up)
vmag_up        = NORM(avg_vswi_up)
avg_dens_up    =    2.10073d0
avg_Ti_up      =   89.6337d0
avg_Te_up      =   10.9142d0
ushn_up        =  -957.13082d0
vshn_up        =  409.98961d0
gnorm          = REFORM(unit_vec([0.90173977d0,0.27319347d0,-0.32522940d0]))
b_dot_n        = my_dot_prod(gnorm,avg_magf_up,/NOM)/(bmag_up[0]*NORM(gnorm))
theta_Bn       = ACOS(b_dot_n[0])*18d1/!DPI
theta_Bn       = theta_Bn[0] < (18d1 - theta_Bn[0])
nkT_up         = (avg_dens_up[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_up[0] + avg_Ti_up[0]))  ;; plasma pressure [J m^(-3)]
sound_up       = SQRT(5d0*nkT_up[0]/(3d0*(avg_dens_up[0]*1d6)*mp[0]))                ;; sound speed [m/s]
alfven_up      = (bmag_up[0]*1d-9)/SQRT(muo[0]*(avg_dens_up[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2      = (sound_up[0]^2 + alfven_up[0]^2)
b2_4ac         = Vs_p_Va_2[0]^2 + 4d0*sound_up[0]^2*alfven_up[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_up        = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;;  Mach numbers
Ma_up          = ABS(ushn_up[0]*1d3/alfven_up[0])
Ms_up          = ABS(ushn_up[0]*1d3/sound_up[0])
Mf_up          = ABS(ushn_up[0]*1d3/fast_up[0])
PRINT,';;', theta_Bn[0], Ma_up[0], Ms_up[0], Mf_up[0]
;;       19.754005       14.037022       7.5544720       6.5883032

;;  Downstream
avg_magf_dn    = [ 1.91813d0,-5.59941d0,-18.2852d0]
avg_vswi_dn    = [ 155.367d0,266.634d0,-247.306d0]
bmag_dn        = NORM(avg_magf_dn)
vmag_dn        = NORM(avg_vswi_dn)
avg_dens_dn    =   17.2654d0
avg_Ti_dn      =  280.707d0
avg_Te_dn      =  120.290d0
ushn_dn        =  -116.61474d0
nkT_dn         = (avg_dens_dn[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_dn[0] + avg_Ti_dn[0]))  ;; plasma pressure [J m^(-3)]
sound_dn       = SQRT(5d0*nkT_dn[0]/(3d0*(avg_dens_dn[0]*1d6)*mp[0]))
alfven_dn      = (bmag_dn[0]*1d-9)/SQRT(muo[0]*(avg_dens_dn[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2      = (sound_dn[0]^2 + alfven_dn[0]^2)
b2_4ac         = Vs_p_Va_2[0]^2 + 4d0*sound_dn[0]^2*alfven_dn[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_dn        = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;;  Mach numbers
Ma_dn          = ABS(ushn_dn[0]*1d3/alfven_dn[0])
Ms_dn          = ABS(ushn_dn[0]*1d3/sound_dn[0])
Mf_dn          = ABS(ushn_dn[0]*1d3/fast_dn[0])
PRINT,';;', theta_Bn[0], Ma_dn[0], Ms_dn[0], Mf_dn[0], avg_dens_dn[0]/avg_dens_up[0]
;;       19.754005       1.1558679      0.46089522      0.42528774       8.2187620

;;-----------------------------------------------------
;;  Calculate gyrospeeds of specular reflection
;;-----------------------------------------------------
;;  calculate unit vectors
bhat         = REFORM(unit_vec(avg_magf_up))
vhat         = REFORM(unit_vec(avg_vswi_up))
;;  calculate upstream inflow velocity
v_up         = avg_vswi_up - gnorm*ABS(vshn_up[0])
;;  Eq. 2 from Gosling et al., [1982]
;;      [specularly reflected ion velocity]
Vref_s       = v_up - gnorm*(2d0*my_dot_prod(v_up,gnorm,/NOM))
;;  Eq. 4 and 3 from Gosling et al., [1982]
;;      [guiding center velocity of a specularly reflected ion]
Vper_r       = v_up - bhat*my_dot_prod(v_up,bhat,/NOM)  ;;  Eq. 4
Vgc_r        = Vper_r + bhat*(my_dot_prod(Vref_s,bhat,/NOM))
;;  Eq. 6 from Gosling et al., [1982]
;;      [gyro-velocity of a specularly reflected ion]
Vgy_r        = Vref_s - Vgc_r
;;  Eq. 7 and 9 from Gosling et al., [1982]
;;      [guiding center velocity of a specularly reflected ion perp. to shock surface]
Vgcn_r       = my_dot_prod(Vgc_r,gnorm,/NOM)
;;      [guiding center velocity of a specularly reflected ion para. to B-field]
Vgcb_r       = my_dot_prod(Vgc_r,bhat,/NOM)
;;  gyrospeed and guiding center speed
Vgy_rs       = mag__vec(Vgy_r,/NAN)
Vgc_rs       = mag__vec(Vgc_r,/NAN)

PRINT,';;', Vgy_rs[0], Vgc_rs[0] & $
PRINT,';;', Vgcn_r[0], Vgcb_r[0]
;;       648.18687       1029.2529
;;       739.83011       917.99294

n_essb         = nseb[0]
tr_essb        = [[dat_seb.TIME],[dat_seb.END_TIME]]
avg_tessb      = (tr_essb[*,0] + tr_essb[*,1])/2d0
se_essb_norm   = REPLICATE(d,n_essb[0],3L)         ;;  [N,{X,Y,Z}]-Element array
FOR k=0L, 2L DO se_essb_norm[*,k] = gnorm[k]
struc          = {X:avg_tessb,Y:se_essb_norm}
coords         = [coord_dsl[0],coord_gse[0]]
store_data,scpref[0]+'fb_sh_norm_'+coords[0],DATA=struc

in__name       = scpref[0]+'fb_sh_norm_'+coords[0]
out_name       = scpref[0]+'fb_sh_norm_'+coords[1]
thm_cotrans,in__name[0],out_name[0],IN_COORD=coords[1],OUT_COORD=coords[0],VERBOSE=0

;;  Define FB shock normal direction for each distribution
get_data,out_name[0],DATA=struc
norm_dsl       = struc.Y
sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
imax           = MIN([gd0[0],gd1[0]],/NAN)
exsuffx        = 'FB_nsh'
leg_sffx       = '(N_sh)'
.compile $HOME/Desktop/temp_idl/temp_plot_esa_sst_combined_spec3d.pro
dat00          = dat0[good0]
dat11          = dat1[good1]
FOR k=0L, 2L DO dat00.MAGF[k] = gnorm[k]
dat11.MAGF     = TRANSPOSE(norm_dsl[good1,*])
FOR ii=0L, imax[0] - 1L DO BEGIN                                                          $
  tdate_sw       = dat00[ii]                                                            & $
  tdats_sw       = dat11[ii]                                                            & $
  p_angle        = 1b                                                                   & $
  sundir         = 0b                                                                   & $
  vec            = 0b                                                                   & $
  temp_plot_esa_sst_combined_spec3d,tdate_sw,tdats_sw,LIM_ESA=lime_str,LIM_SST=lims_str,  $
                                    ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                  $
                                    SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,    $
                                    SUNDIR=sundir,VECTOR=vec,UNITS=units,EX_SUFFX=exsuffx,$
                                    LEG_SFFX=leg_sffx




;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot examples
ii             = 17L
jj             = good0[ii]
tdate_sw       = dat0[jj]
kk             = good1[ii]
tdats_sw       = dat1[kk]

sc_frame       = 0b
cut_ran        = 22.5d0
p_angle        = 1b
sundir         = 0b
vec            = 0b
units          = 'flux'

.compile $HOME/Desktop/temp_idl/temp_plot_esa_sst_combined_spec3d.pro
temp_plot_esa_sst_combined_spec3d,tdate_sw,tdats_sw,LIM_ESA=lime_str,LIM_SST=lims_str,$
                                  ESA_ERAN=xran_esa,SST_ERAN=xran_sst,                $
                                  SC_FRAME=sc_frame,CUT_RAN=cut_ran,P_ANGLE=p_angle,  $
                                  SUNDIR=sundir,VECTOR=vec,UNITS=units



;;  Open windows
wi,1,xsize=800,ysize=800
wi,2,xsize=800,ysize=800
wi,3,xsize=800,ysize=800

;;  Setup options
str_element,lim0, 'XSTYLE',        1,/ADD_REPLACE
str_element,lim0, 'YSTYLE',        1,/ADD_REPLACE
str_element,lim0, 'XMINOR',        9,/ADD_REPLACE
str_element,lim0, 'YMINOR',        9,/ADD_REPLACE
str_element,lim0,'XMARGIN',  [10,10],/ADD_REPLACE
str_element,lim0,'YMARGIN',  [ 5, 5],/ADD_REPLACE

get_data,eeomni_fac[0],DATA=temp,DLIMIT=dlim,LIMIT=lim
extract_tags,lime_str,lim,TAGS=['YRANGE','YTICKNAME','YTICKV','YTICKS']
extract_tags,lime_str,lim0

get_data,sebfomnifac[0],DATA=temp,DLIMIT=dlim,LIMIT=lim
extract_tags,lims_str,lim,TAGS=['YRANGE','YTICKNAME','YTICKV','YTICKS']
extract_tags,lims_str,lim0

xran           = [5e1,2e4]
yran           = [1e-1,1e6]
str_element,lime_str, 'XRANGE',     xran,/ADD_REPLACE
str_element,lime_str, 'YRANGE',     yran,/ADD_REPLACE
xran           = [1e4,2e5]
yran           = [1e-4,2e-1]
str_element,lims_str, 'XRANGE',     xran,/ADD_REPLACE
str_element,lims_str, 'YRANGE',     yran,/ADD_REPLACE
;;  Define power-law lines
f_at_10keV     = yran[1]
a_o            = f_at_10keV[0]*(xran[0])^2
fplaw_2        = a_o[0]*xran^(-2d0)

;;  Plot examples
units          = 'flux'
jj             = good0[17]
tdate_sw       = dat0[jj]
kk             = good1[17]
tdats_sw       = dat1[kk]
transform_vframe_3d,tdate_sw,/EASY_TRAN
transform_vframe_3d,tdats_sw,/EASY_TRAN

WSET,1
DELVAR,xdat_eesa,ydat_eesa,pang_eesa
lbw_spec3d,tdate_sw,LIMITS=lime_str,/SUNDIR,/LABEL,XDAT=xdat_eesa,YDAT=ydat_eesa,PITCHANGLE=pang_eesa
  OPLOT,xran,fplaw_2,LINESTYLE=2,THICK=2

WSET,2
DELVAR,xdat_nf_sd,ydat_nf_sd,pang
lbw_spec3d,tdats_sw,LIMITS=lims_str,/SUNDIR,/LABEL,XDAT=xdat_nf_sd,YDAT=ydat_nf_sd,PITCHANGLE=pang
  OPLOT,xran,fplaw_2,LINESTYLE=2,THICK=2

;;  Check "bad" energy bins (i.e., where ∆E --> 0)
bad_eesa_en    = WHERE(tdate_sw.ENERGY[*,0] GE 2e4,bd_eesa_en,COMPLEMENT=good_eesa_en,NCOMPLEMENT=gd_eesa_en)
bad_ener       = WHERE(tdats_sw.DENERGY[*,0] LE 0,bd_ener,COMPLEMENT=good_ener,NCOMPLEMENT=gd_ener)
PRINT,';;',bd_eesa_en,gd_eesa_en,'  For EESA on Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0] & $
PRINT,';;',bd_ener,gd_ener,'  For SSTe on Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;           3          29  For EESA on Probe:  THC on 2008-07-14
;;           5          11  For SSTe on Probe:  THC on 2008-07-14

;;  Define range of pitch-angles to use
cut_aran       = 22.5d0
cut_mids       = [22.5d0,9d1,157.5d0]
cut_lows       = cut_mids - cut_aran[0]
cut_high       = cut_mids + cut_aran[0]

test_para      = (pang_eesa LE cut_high[0]) AND (pang_eesa GE cut_lows[0])
test_perp      = (pang_eesa LE cut_high[1]) AND (pang_eesa GE cut_lows[1])
test_anti      = (pang_eesa LE cut_high[2]) AND (pang_eesa GE cut_lows[2])
good_para      = WHERE(test_para,gd_para)
good_perp      = WHERE(test_perp,gd_perp)
good_anti      = WHERE(test_anti,gd_anti)
PRINT,';;',gd_para,gd_perp,gd_anti,'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;          14          38           8  For Probe:  THC on 2008-07-14

;;  Redefine
good_para_eesa = good_para
good_perp_eesa = good_perp
good_anti_eesa = good_anti

;;  w/rt sun direction
test_para      = (pang LE cut_high[0]) AND (pang GE cut_lows[0])
test_perp      = (pang LE cut_high[1]) AND (pang GE cut_lows[1])
test_anti      = (pang LE cut_high[2]) AND (pang GE cut_lows[2])
good_para      = WHERE(test_para,gd_para)
good_perp      = WHERE(test_perp,gd_perp)
good_anti      = WHERE(test_anti,gd_anti)
PRINT,';;',gd_para,gd_perp,gd_anti,'  For Probe:  TH'+STRUPCASE(sc[0])+' on '+tdate[0]
;;           8          24           8  For Probe:  THC on 2008-07-14

;;  Redefine
good_para_sste = good_para
good_perp_sste = good_perp
good_anti_sste = good_anti

;;  Define data over which to average
data_para_eesa = ydat_eesa[*,good_para_eesa]
data_perp_eesa = ydat_eesa[*,good_perp_eesa]
data_anti_eesa = ydat_eesa[*,good_anti_eesa]
ener_para_eesa = xdat_eesa[*,good_para_eesa]
ener_perp_eesa = xdat_eesa[*,good_perp_eesa]
ener_anti_eesa = xdat_eesa[*,good_anti_eesa]
pang_para_eesa =   pang_eesa[good_para_eesa]
pang_perp_eesa =   pang_eesa[good_perp_eesa]
pang_anti_eesa =   pang_eesa[good_anti_eesa]

data_para_sste = ydat_nf_sd[*,good_para_sste]
data_perp_sste = ydat_nf_sd[*,good_perp_sste]
data_anti_sste = ydat_nf_sd[*,good_anti_sste]
ener_para_sste = xdat_nf_sd[*,good_para_sste]
ener_perp_sste = xdat_nf_sd[*,good_perp_sste]
ener_anti_sste = xdat_nf_sd[*,good_anti_sste]
pang_para_sste =         pang[good_para_sste]
pang_perp_sste =         pang[good_perp_sste]
pang_anti_sste =         pang[good_anti_sste]

;;  Keep only good energies now
data_para_eesa = data_para_eesa[good_eesa_en,*]
data_perp_eesa = data_perp_eesa[good_eesa_en,*]
data_anti_eesa = data_anti_eesa[good_eesa_en,*]
ener_para_eesa = ener_para_eesa[good_eesa_en,*]
ener_perp_eesa = ener_perp_eesa[good_eesa_en,*]
ener_anti_eesa = ener_anti_eesa[good_eesa_en,*]

data_para_sste = data_para_sste[good_ener,*]
data_perp_sste = data_perp_sste[good_ener,*]
data_anti_sste = data_anti_sste[good_ener,*]
ener_para_sste = ener_para_sste[good_ener,*]
ener_perp_sste = ener_perp_sste[good_ener,*]
ener_anti_sste = ener_anti_sste[good_ener,*]

;;  Average data over each direction
Avgf_para_eesa = TOTAL(data_para_eesa,2L,/NAN)/TOTAL(FINITE(data_para_eesa),2L,/NAN)
AvgE_para_eesa = TOTAL(ener_para_eesa,2L,/NAN)/TOTAL(FINITE(ener_para_eesa),2L,/NAN)
Avgf_perp_eesa = TOTAL(data_perp_eesa,2L,/NAN)/TOTAL(FINITE(data_perp_eesa),2L,/NAN)
AvgE_perp_eesa = TOTAL(ener_perp_eesa,2L,/NAN)/TOTAL(FINITE(ener_perp_eesa),2L,/NAN)
Avgf_anti_eesa = TOTAL(data_anti_eesa,2L,/NAN)/TOTAL(FINITE(data_anti_eesa),2L,/NAN)
AvgE_anti_eesa = TOTAL(ener_anti_eesa,2L,/NAN)/TOTAL(FINITE(ener_anti_eesa),2L,/NAN)

Avgf_para_sste = TOTAL(data_para_sste,2L,/NAN)/TOTAL(FINITE(data_para_sste),2L,/NAN)
AvgE_para_sste = TOTAL(ener_para_sste,2L,/NAN)/TOTAL(FINITE(ener_para_sste),2L,/NAN)
Avgf_perp_sste = TOTAL(data_perp_sste,2L,/NAN)/TOTAL(FINITE(data_perp_sste),2L,/NAN)
AvgE_perp_sste = TOTAL(ener_perp_sste,2L,/NAN)/TOTAL(FINITE(ener_perp_sste),2L,/NAN)
Avgf_anti_sste = TOTAL(data_anti_sste,2L,/NAN)/TOTAL(FINITE(data_anti_sste),2L,/NAN)
AvgE_anti_sste = TOTAL(ener_anti_sste,2L,/NAN)/TOTAL(FINITE(ener_anti_sste),2L,/NAN)

yran           = [1e-4,1e6]
xran           = [5e1,2e5]
pstr           = lim0
str_element,pstr,  'YLOG',            1,/ADD_REPLACE
str_element,pstr,  'XLOG',            1,/ADD_REPLACE
str_element,pstr,'YTITLE',       'flux',/ADD_REPLACE
str_element,pstr,'XTITLE','Energy [eV]',/ADD_REPLACE
str_element,pstr, 'TITLE','SST-e Burst',/ADD_REPLACE
str_element,pstr,'XRANGE',         xran,/ADD_REPLACE
str_element,pstr,'YRANGE',         yran,/ADD_REPLACE
;;  Define power-law lines
f_at_50eV      = yran[1]
a_o            = f_at_50eV[0]*(xran[0])^2
fplaw_2        = a_o[0]*xran^(-2d0)
f_at_50eV      = yran[1]*10
a_o            = f_at_50eV[0]*(xran[0])^3
fplaw_3        = a_o[0]*xran^(-3d0)

WSET,3
PLOT,AvgE_para_eesa,Avgf_para_eesa,_EXTRA=pstr
  ;;  Plot EESA data
  OPLOT,AvgE_para_eesa,Avgf_para_eesa,COLOR=250
  OPLOT,AvgE_perp_eesa,Avgf_perp_eesa,COLOR=150
  OPLOT,AvgE_anti_eesa,Avgf_anti_eesa,COLOR= 50
  ;;  Plot SSTe data
  OPLOT,AvgE_para_sste,Avgf_para_sste,COLOR=250
  OPLOT,AvgE_perp_sste,Avgf_perp_sste,COLOR=150
  OPLOT,AvgE_anti_sste,Avgf_anti_sste,COLOR= 50
  OPLOT,xran,fplaw_2,LINESTYLE=2,THICK=2
  OPLOT,xran,fplaw_3,LINESTYLE=3,THICK=2

;;  Save plots
fname          = 'THC_EESA_SSTe_on_2008-07-14_at_2158x03_para-red_perp-green_anti-blue_wrt_sundir'
popen_str      = {PORT:1,UNITS:'inches',XSIZE:8.5,YSIZE:8.5,ASPECT:1}
popen,fname[0],_EXTRA=popen_str
  PLOT,AvgE_para_eesa,Avgf_para_eesa,_EXTRA=pstr
    ;;  Plot EESA data
    OPLOT,AvgE_para_eesa,Avgf_para_eesa,COLOR=250
    OPLOT,AvgE_perp_eesa,Avgf_perp_eesa,COLOR=150
    OPLOT,AvgE_anti_eesa,Avgf_anti_eesa,COLOR= 50
    ;;  Plot SSTe data
    OPLOT,AvgE_para_sste,Avgf_para_sste,COLOR=250
    OPLOT,AvgE_perp_sste,Avgf_perp_sste,COLOR=150
    OPLOT,AvgE_anti_sste,Avgf_anti_sste,COLOR= 50
    OPLOT,xran,fplaw_2,LINESTYLE=2,THICK=2
    OPLOT,xran,fplaw_3,LINESTYLE=3,THICK=2
pclose






