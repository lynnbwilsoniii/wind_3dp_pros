tp_hand0  = ['T_avg','V_Therm','N','Velocity','Tpara','Tperp','Tanisotropy','Pressure']
xsuff     = ''
v_units   = ' (km/s)'
t_units   = ' (eV)'
p_units   = ' (eV/cm!U3!N'+')'
d_units   = ' (#/cm!U3!N'+')'
t_pref    = ['T!D','!N'+t_units]
v_pref    = ['V!D','!N'+v_units]
p_pref    = ['P!D','!N'+p_units]
d_pref    = ['N!D','!N'+d_units]
t_ttle    = t_pref[0]+xsuff+t_pref[1]
vv_ttle   = v_pref[0]+xsuff+v_pref[1]
vt_ttle   = v_pref[0]+'T'+xsuff+v_pref[1]
den_ttle  = d_pref[0]+xsuff+d_pref[1]
tpa_ttle  = t_pref[0]+'!9#!3'+xsuff+t_pref[1]
tpe_ttle  = t_pref[0]+'!9x!3'+xsuff+t_pref[1]
pre_ttle  = p_pref[0]+xsuff+p_pref[1]
tan_ttle  = t_pref[0]+'!9x!3'+xsuff+'!N'+'/'+t_pref[0]+'!9#!3'+xsuff+'!N'
tp_ttles  = [t_ttle,vt_ttle,den_ttle,vv_ttle,tpa_ttle,tpe_ttle,tan_ttle,pre_ttle]

;-----------------------------------------------------------------------------------------
; => Constants
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
epo    = 8.854187817d-12   ; => Permittivity of free space (F/m)
muo    = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
me     = 9.10938291d-31    ; => Electron mass (kg) [2010 value]
mp     = 1.672621777d-27   ; => Proton mass (kg) [2010 value]
ma     = 6.64465675d-27    ; => Alpha-Particle mass (kg) [2010 value]
qq     = 1.602176565d-19   ; => Fundamental charge (C) [2010 value]
kB     = 1.3806488d-23     ; => Boltzmann Constant (J/K) [2010 value]
K_eV   = 1.1604519d4       ; => Factor [Kelvin/eV] [2010 value]
c      = 2.99792458d8      ; => Speed of light in vacuum (m/s)
R_E    = 6.37814d3         ; => Earth's Equitorial Radius (km)

; => Compile necessary routines
@comp_lynn_pros
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/SCIENCE_PRO/plot_map.pro
thm_init
; => Load all relevant data
tdate     = '2009-07-13'
tr_00     = tdate[0]+'/'+['07:50:00','10:10:00']
date      = '071309'
probe     = 'b'
;themis_load_all_inst,DATE=date[0],PROBE=probe[0],TRANGE=time_double(tr_00)
;; => Load packet info for structures
;thm_load_esa_pkt,PROBE=probe[0]

;; => Restore TPLOT session
mdir      = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_tplot_save/')
fpref     = 'TPLOT_save_file_FGM-ALL_EESA-IESA-Moments_Vsw-Corrected_'
fnm       = file_name_times(tr_00,PREC=0)
ftimes    = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx    = ftimes[0]+'-'+STRMID(ftimes[1],11L)
fname     = fpref[0]+tsuffx[0]+'.tplot'
file      = FILE_SEARCH(mdir,fname[0])
tplot_restore,FILENAME=file[0],VERBOSE=0

!themis.VERBOSE = 0
tplot_options,'VERBOSE',0

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100

coord   = 'gse'
sc      = probe[0]
pref    = 'th'+sc[0]+'_'
velname = pref[0]+'peib_velocity_'+coord[0]
magname = pref[0]+'fgh_'+coord[0]
tr_jj     = time_double(tdate[0]+'/'+['08:58:30','09:02:15'])

tplot,pref[0]+'fgh_'+['mag',coord[0]],TRANGE=tr_jj
;-----------------------------------------------------------------------------------------
; => Load ESA Save Files
;-----------------------------------------------------------------------------------------
sc      = probe[0]
enames  = 'EESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'
inames  = 'IESA_Burst_THEMIS_'+sc[0]+'_Structures_'+tdate[0]+'_lz_counts.sav'

mdir    = FILE_EXPAND_PATH('IDL_stuff/themis_data_dir/themis_esa_save/'+tdate[0]+'/')
efiles  = FILE_SEARCH(mdir,enames[0])
ifiles  = FILE_SEARCH(mdir,inames[0])

RESTORE,efiles[0]
RESTORE,ifiles[0]

;; => Redefine structures
dat_i     = peib_df_arr_b
dat_e     = peeb_df_arr_b
;; Keep only structures between defined time range
trtt      = time_double(tr_00)
i_time0   = dat_i.TIME
i_time1   = dat_i.END_TIME
e_time0   = dat_e.TIME
e_time1   = dat_e.END_TIME
good_i    = WHERE(i_time0 GE trtt[0] AND i_time1 LE trtt[1],gdi)
good_e    = WHERE(e_time0 GE trtt[0] AND e_time1 LE trtt[1],gde)
dat_i     = peib_df_arr_b[good_i]
dat_e     = peeb_df_arr_b[good_e]

n_i       = N_ELEMENTS(dat_i)
n_e       = N_ELEMENTS(dat_e)
PRINT,';', n_i, n_e
;        1172        1174
;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
vname_n   = velname[0]+'_fixed'
magname   = pref[0]+'fgh_'+coord[0]
spperi    = pref[0]+'state_spinper'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
scname    = tnames(pref[0]+'pe*b_sc_pot')

modify_themis_esa_struc,dat_i
modify_themis_esa_struc,dat_e

;; add SC potential to structures
add_scpot,dat_e,scname[0]
add_scpot,dat_i,scname[1]

;; => Rotate DAT structure (theta,phi)-angles DSL --> GSE
dat_igse  = dat_i
rotate_esa_thetaphi_to_gse,dat_igse,MAGF_NAME=magname,VEL_NAME=vname_n

magn_1    = pref[0]+'fgs_'+coord[0]
magn_2    = pref[0]+'fgh_'+coord[0]
add_magf2,dat_igse,magn_1[0],/LEAVE_ALONE
add_magf2,dat_igse,magn_2[0],/LEAVE_ALONE
;;----------------------------------------------------------------------------------------
;;  Calculate moments myself
;;    1)  Convert in Solar Wind (SW) frame
;;    2)  Create mask for data to remove values > V_thresh [from specular ref. estimate]
;;    3)  Kill data within ±15 deg of sun dir below ~500 km/s [SW frame]
;;    4)  Find remaining finite data bins to create a new mask
;;    5)  Use new mask to keep only the desired bins when calculating ion moments
;;----------------------------------------------------------------------------------------
;; Ion DFs consist primarily of gyrating ions between:
;;
;;  [Start Times]
;;    08:59:42.362 [384/1371] - 09:02:40.439 [443/1371] UT
;;
;;    09:18:03.472 [675/1371] - 09:18:30.184 [684/1371] UT
;;
;;    09:19:23.607 [702/1371] - 09:19:38.447 [707/1371] UT
;;
;;    09:23:50.723 [792/1371] - 09:24:17.435 [800/1371] UT
;;
;;    09:24:47.114 [810/1371] - 09:40:30.923 [1128/1371] UT
;;
;;----------------------------------------------------
;;  Define overall mask
;;----------------------------------------------------
v_thresh   = 35e1
v_uv       = 50e1
mask_aa    = remove_uv_and_beam_ions(dat_igse,V_THRESH=v_thresh[0],V_UV=v_uv[0])
;;----------------------------------------------------
;;  Create a dummy copy of spacecraft (SC) frame structures and kill bad data
;;----------------------------------------------------
i_time0    = dat_igse.TIME
i_time1    = dat_igse.END_TIME
tr_bi0     = time_double(tdate[0]+'/'+['08:59:42','09:02:41'])
tr_bi1     = time_double(tdate[0]+'/'+['09:18:03','09:18:31'])
tr_bi2     = time_double(tdate[0]+'/'+['09:19:23','09:19:39'])
tr_bi3     = time_double(tdate[0]+'/'+['09:23:50','09:24:18'])
tr_bi4     = time_double(tdate[0]+'/'+['09:24:47','09:40:31'])

dummy      = dat_igse
dummk      = dat_igse
data       = dummy.DATA             ;; Data [counts]
data      *= mask_aa
dummk.DATA = data
;; => Only use these structures when gyrating ions present
bad0       = WHERE(i_time0 GE tr_bi0[0] AND i_time1 LE tr_bi0[1],bd0)
bad1       = WHERE(i_time0 GE tr_bi1[0] AND i_time1 LE tr_bi1[1],bd1)
bad2       = WHERE(i_time0 GE tr_bi2[0] AND i_time1 LE tr_bi2[1],bd2)
bad3       = WHERE(i_time0 GE tr_bi3[0] AND i_time1 LE tr_bi3[1],bd3)
bad4       = WHERE(i_time0 GE tr_bi4[0] AND i_time1 LE tr_bi4[1],bd4)
IF (bd0 GT 0) THEN dummy[bad0] = dummk[bad0]
IF (bd1 GT 0) THEN dummy[bad1] = dummk[bad1]
IF (bd2 GT 0) THEN dummy[bad2] = dummk[bad2]
IF (bd3 GT 0) THEN dummy[bad3] = dummk[bad3]
IF (bd4 GT 0) THEN dummy[bad4] = dummk[bad4]

;;----------------------------------------------------
;;  Calculate moments [just core]
;;----------------------------------------------------
sform      = moments_3du()
str_element,sform,'END_TIME',0d0,/ADD_REPLACE
dumb       = REPLICATE(sform[0],n_i)
FOR j=0L, n_i - 1L DO BEGIN                                             $
  del     = dummy[j]                                                  & $
  pot     = del[0].SC_POT                                             & $
  tmagf   = REFORM(del[0].MAGF)                                       & $
  tmoms   = moments_3du(del,FORMAT=sform,SC_POT=pot[0],MAGDIR=tmagf)  & $
  str_element,tmoms,'END_TIME',del[0].END_TIME,/ADD_REPLACE           & $
  dumb[j] = tmoms[0]

; => Define relevant quantities
p_els     = [0L,4L,8L]                 ; => Diagonal elements of a 3x3 matrix
avgtemp   = REFORM(dumb.AVGTEMP)       ; => Avg. Particle Temp (eV)
v_therm   = REFORM(dumb.VTHERMAL)      ; => Avg. Particle Thermal Speed (km/s)
tempvec   = TRANSPOSE(dumb.MAGT3)      ; => Vector Temp [perp1,perp2,para] (eV)
velocity  = TRANSPOSE(dumb.VELOCITY)   ; => Velocity vectors (km/s)
p_tensor  = TRANSPOSE(dumb.PTENS)      ; => Pressure tensor [eV cm^(-3)]
density   = REFORM(dumb.DENSITY)       ; => Particle density [# cm^(-3)]

t_perp    = 5e-1*(tempvec[*,0] + tempvec[*,1])
t_para    = REFORM(tempvec[*,2])
tanis     = t_perp/t_para
pressure  = TOTAL(p_tensor[*,p_els],2,/NAN)/3.
i_moments = dumb

tp_hands  = pref[0]+tp_hand0+'_peib_no_GIs_UV'
scup      = STRUPCASE(sc[0])
ysubs     = '[TH-'+scup[0]+', IESA Burst]'+'!C'+'[Corrected]'
;; => Define dummy structure with data quantities
times     = (i_moments.TIME + i_moments.END_TIME)/2d0
dstr      = CREATE_STRUCT(tp_hands,avgtemp,v_therm,density,velocity,t_para,t_perp,$
                          tanis,pressure)
FOR j=0L, N_ELEMENTS(tp_hands) - 1L DO BEGIN                                $
  dat_0  = dstr.(j)                                                       & $
  store_data,tp_hands[j],DATA={X:times,Y:dat_0}                           & $
  options,tp_hands[j],'YTITLE',tp_ttles[j],/DEF                           & $
  options,tp_hands[j],'YSUBTITLE',ysubs[0],/DEF                           & $
  IF (tp_hand0[j] EQ 'Velocity') THEN gcols = 1 ELSE gcols = 0            & $
  IF (gcols) THEN options,tp_hands[j],'COLORS',[250L,150L,50L],/DEF


;;----------------------------------------------------
;;  Calculate density difference [# cm^(-3)] and ratio
;;----------------------------------------------------
denname   = pref[0]+'peib_density'
get_data,denname[0],DATA=dens_lv2
good      = array_where(dens_lv2.X,times,/N_UNIQ)
good      = good[*,0]

ni_halo   = dens_lv2.Y[good] - i_moments.DENSITY
ni_ratio  = test_nh/dens_lv2.Y[good]
bad       = WHERE(ni_halo LE 0,bd)
IF (bd GT 0) THEN ni_halo[bad] = f
IF (bd GT 0) THEN ni_ratio[bad] = f
;;  Send to TPLOT
n_denhalo = pref[0]+'peib_density_halo'
n_denrat  = pref[0]+'peib_density_halo2core'
struct1   = {X:times,Y:ni_halo}
struct2   = {X:times,Y:ni_ratio}
store_data,n_denhalo[0],DATA=struct1
store_data,n_denrat[0],DATA=struct2
options,n_denhalo[0],'YTITLE','N!Di,halo!N [cm!U-3!N'+']',/DEF
options,n_denrat[0],'YTITLE','N!Di,halo!N'+'/N!Di!N',/DEF
options,n_denrat[0],'YLOG',1,/DEF
options,n_denrat[0],'YRANGE',[1e-4,1e0],/DEF

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01


;;  Plot comparisons
coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
magsufx   = 'fgl_'+['mag',coord[0]]
;magsufx   = 'fgs_'+['mag',coord[0]]
esasufx   = [['N','T_avg']+'_peib_no_GIs_UV','peib_velocity_gse_fixed']
nna       = pref[0]+[magsufx,esasufx]
fpref     = 'THB_fgl-mag-gse_Ni_Ti_Vi_corrected_level-2_'
;fpref     = 'THB_fgs-mag-gse_Ni_Ti_Vi_corrected_level-2_'

;; force temporary Y-Ranges
options,nna[2],'YRANGE',[0e0,7e1]
options,nna[3],'YRANGE',[1e1,5e2]
options,nna[3],'YLOG',1
options,nna[4],'YRANGE',[-35e1,2e2]


tr_jj     = time_double(tdate[0]+'/'+['08:57:00','09:02:30'])
fnm       = file_name_times(tr_jj,PREC=0)
ftimes    = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
sftime    = ftimes[0]+'-'+STRMID(ftimes[1],11L)

  tplot,nna,TRANGE=tr_jj
  time_bar,dat_0[0].TIME,VARNAME=nna,COLOR=250L
  time_bar,dat_0[0].END_TIME,VARNAME=nna,COLOR= 50L
popen,fpref[0]+sftime[0],/PORT
  tplot,nna,TRANGE=tr_jj
  time_bar,dat_0[0].TIME,VARNAME=nna,COLOR=250L
  time_bar,dat_0[0].END_TIME,VARNAME=nna,COLOR= 50L
pclose

options,nna[2:4],'YRANGE'
options,nna[2:4],'YLOG'


coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
magsufx   = 'fgl_'+['mag',coord[0]]
;magsufx   = 'fgs_'+['mag',coord[0]]
esasufx   = ['peib_density','peib_avgtemp','peib_velocity_'+coord[0]]
nna       = pref[0]+[magsufx,esasufx]
fpref     = 'THB_fgl-mag-gse_Ni_Ti_Vi_level-2_'
;fpref     = 'THB_fgs-mag-gse_Ni_Ti_Vi_level-2_'

;; force temporary Y-Ranges
options,nna[2],'YRANGE',[0e0,7e1]
options,nna[3],'YRANGE',[1e1,5e2]
options,nna[3],'YLOG',1
options,nna[4],'YRANGE',[-35e1,2e2]

tr_jj     = time_double(tdate[0]+'/'+['08:57:00','09:02:30'])
fnm       = file_name_times(tr_jj,PREC=0)
ftimes    = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
sftime    = ftimes[0]+'-'+STRMID(ftimes[1],11L)

  tplot,nna,TRANGE=tr_jj
  time_bar,dat_0[0].TIME,VARNAME=nna,COLOR=250L
  time_bar,dat_0[0].END_TIME,VARNAME=nna,COLOR= 50L
popen,fpref[0]+sftime[0],/PORT
  tplot,nna,TRANGE=tr_jj
  time_bar,dat_0[0].TIME,VARNAME=nna,COLOR=250L
  time_bar,dat_0[0].END_TIME,VARNAME=nna,COLOR= 50L
pclose

options,nna[2:4],'YRANGE'
options,nna[2:4],'YLOG'

;;----------------------------------------------------
;;  Calculate moments [entire DF]
;;----------------------------------------------------
;sform      = moments_3du()
;str_element,sform,'END_TIME',0d0,/ADD_REPLACE
;dumb       = REPLICATE(sform[0],n_i)
;FOR j=0L, n_i - 1L DO BEGIN                                             $
;  del     = dat_igse[j]                                               & $
;  pot     = del[0].SC_POT                                             & $
;  tmagf   = REFORM(del[0].MAGF)                                       & $
;  tmoms   = moments_3du(del,FORMAT=sform,SC_POT=pot[0],MAGDIR=tmagf)  & $
;  str_element,tmoms,'END_TIME',del[0].END_TIME,/ADD_REPLACE           & $
;  dumb[j] = tmoms[0]
;a_moments = dumb
;
;ni_halo   = a_moments.DENSITY - i_moments.DENSITY
;ni_ratio  = ni_halo/i_moments.DENSITY
;
;;calc,"'thb_density_halo_only' = 'thb_peib_density' - 'thb_N_peib_no_GIs_UV'"
;;----------------------------------------------------------------------------------------
;; TPLOT stuff
;;----------------------------------------------------------------------------------------
coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
magname   = pref[0]+'fgh_'+coord[0]
spperi    = pref[0]+'state_spinper'

get_data,vname_n[0],DATA=vbulk_str
vbulk     = vbulk_str.Y
v_t       = vbulk_str.X

i_t       = (dat_i.TIME + dat_i.END_TIME)/2d0
vbulkix   = interp(vbulk[*,0],v_t,i_t,/NO_EXTRAP)
vbulkiy   = interp(vbulk[*,1],v_t,i_t,/NO_EXTRAP)
vbulkiz   = interp(vbulk[*,2],v_t,i_t,/NO_EXTRAP)
vbulk_i   = [[vbulkix],[vbulkiy],[vbulkiz]]
;-----------------------------------------------------
; IESA
;-----------------------------------------------------
i_time0   = dat_i.TIME
i_time1   = dat_i.END_TIME
tbow0     = time_double(tdate[0]+'/'+['08:56:00.000','09:10:00.000'])
tbow1     = time_double(tdate[0]+'/'+['09:14:00.000','09:30:00.000'])
tbow2     = time_double(tdate[0]+'/'+['09:30:00.000','09:44:00.000'])
good_i0   = WHERE(i_time0 GE tbow0[0] AND i_time1 LE tbow0[1],gdi0)
good_i1   = WHERE(i_time0 GE tbow1[0] AND i_time1 LE tbow1[1],gdi1)
good_i2   = WHERE(i_time0 GE tbow2[0] AND i_time1 LE tbow2[1],gdi2)
PRINT,';', gdi0, gdi1, gdi2
;         281         318         279

dat_i0    = dat_i[good_i0]
dat_i1    = dat_i[good_i1]
dat_i2    = dat_i[good_i2]
vsw_i0    = vbulk_i[good_i0,*]
vsw_i1    = vbulk_i[good_i1,*]
vsw_i2    = vbulk_i[good_i2,*]
;;----------------------------------------------------------------------------------------
;; => Set up plot windows and defaults
;;----------------------------------------------------------------------------------------
WINDOW,1,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,2,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,3,RETAIN=2,XSIZE=800,YSIZE=1100


gnorm_0  = [0.98744623d0,-0.053346692d0,0.0093557489d0]
Vgy_rs   = [380.78971d0,488.58513d0]   ;; solutions from 1st and 2nd bow shock crossing

ngrid    = 30L
sunv     = [1.,0.,0.]
sunn     = 'Sun Dir.'
xname    = 'B!Do!N'
yname    = 'V!Dsw!N'
vlim     = 25e2
ns       = 7L
smc      = 1
smct     = 1
dfmax    = 1d-1
dfmin    = 1d-15
gnorm    = gnorm_0
normnm   = 'Shock Normal[0]'
vcirc    = Vgy_rs            ;; use both solutions
dfra     = [1d-14,1d-8]
interpo  = 0

;;----------------------------------------------------
;; => Plot using 'fgh' B-fields
;;----------------------------------------------------
j        = 79L
dat_0    = dat_i0[j]
vec2     = REFORM(vsw_i0[j,*])

WSET,1
contour_esa_htr_1plane,dat_0,magname[0],vec2,spperi[0],VLIM=vlim[0],NGRID=ngrid[0],    $
                       XNAME=xname[0],YNAME=yname[0],SM_CUTS=smc[0],NSMOOTH=ns[0],     $
                       /ONE_C,VCIRC=vcirc,EX_VEC0=gnorm,EX_VN0=normnm[0],              $
                       EX_VEC1=sunv,EX_VN1=sunn[0],PLANE='xy',/NO_REDF,INTERP=interpo, $
                       SM_CONT=smct[0],DFRA=dfra,DFMIN=dfmin[0],DFMAX=dfmax[0],        $
                       MAGF_NAME=magname[0],VEL_NAME=vname_n[0]

WSET,2
contour_esa_htr_1plane,dat_0,magname[0],vec2,spperi[0],VLIM=vlim[0],NGRID=ngrid[0],    $
                       XNAME=xname[0],YNAME=yname[0],SM_CUTS=smc[0],NSMOOTH=ns[0],     $
                       /ONE_C,VCIRC=vcirc,EX_VEC0=gnorm,EX_VN0=normnm[0],              $
                       EX_VEC1=sunv,EX_VN1=sunn[0],PLANE='xz',/NO_REDF,INTERP=interpo, $
                       SM_CONT=smct[0],DFRA=dfra,DFMIN=dfmin[0],DFMAX=dfmax[0],        $
                       MAGF_NAME=magname[0],VEL_NAME=vname_n[0]

WSET,3
contour_esa_htr_1plane,dat_0,magname[0],vec2,spperi[0],VLIM=vlim[0],NGRID=ngrid[0],    $
                       XNAME=xname[0],YNAME=yname[0],SM_CUTS=smc[0],NSMOOTH=ns[0],     $
                       /ONE_C,VCIRC=vcirc,EX_VEC0=gnorm,EX_VN0=normnm[0],              $
                       EX_VEC1=sunv,EX_VN1=sunn[0],PLANE='yz',/NO_REDF,INTERP=interpo, $
                       SM_CONT=smct[0],DFRA=dfra,DFMIN=dfmin[0],DFMAX=dfmax[0],        $
                       MAGF_NAME=magname[0],VEL_NAME=vname_n[0]




;;----------------------------------------------------
;; => Plot using 3s averaged B-fields
;;----------------------------------------------------
j        = good_i0[0] + 79L
dat_0    = dat_igse[j]

vec1     = dat_0.MAGF
vec2     = dat_0.VSW
dfra     = [1d-14,1d-8]

WSET,1
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='xy',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='xz',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,3
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='yz',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]



;; save plot near SDA example at 09:25:10 UT
magsufx = ['fgh_mag','fgh_'+coord[0]]
esasufx = [['N','T_avg']+'_peib_no_GIs_UV','peib_velocity_gse_fixed']
nna     = pref[0]+[magsufx,esasufx]
fpref   = 'THB_fgh-mag-gse_Ni_Ti_Vi_corrected_2009-07-13_0924x12-0927x11'
popen,fpref[0]+'_0',/PORT
  tplot,nna
  time_bar,dat_0[0].TIME,VARNAME=nna,COLOR=250L
  time_bar,dat_0[0].END_TIME,VARNAME=nna,COLOR= 50L
pclose


;;----------------------------------------------------
;; save examples
;;----------------------------------------------------
j         = 195L
dat_0     = dat_igse[j]

vec1      = dat_0.MAGF
vec2      = dat_0.VSW
dfra      = [1d-14,1d-8]
fnm       = file_name_times(dat_0.TIME,PREC=3)
ftimes    = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
fpref     = 'THB_IESA-Burst_corrected-Vbulk_'+ftimes[0]

popen,fpref[0]+'_plane-1',/PORT
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='xy',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]
pclose


popen,fpref[0]+'_plane-3',/PORT
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='xz',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]
pclose

popen,fpref[0]+'_plane-2',/PORT
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='yz',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]
pclose


;; use old bulk flow velocities
velname   = pref[0]+'peib_velocity_'+coord[0]
get_data,velname[0],DATA=vbulk_old
vbulko    = vbulk_old.Y
v_to      = vbulk_old.X

i_t       = (dat_igse.TIME + dat_igse.END_TIME)/2d0
vbulkox   = interp(vbulko[*,0],v_to,i_t,/NO_EXTRAP)
vbulkoy   = interp(vbulko[*,1],v_to,i_t,/NO_EXTRAP)
vbulkoz   = interp(vbulko[*,2],v_to,i_t,/NO_EXTRAP)
vbulk_o   = [[vbulkox],[vbulkoy],[vbulkoz]]

dat_0     = dat_igse[j]

vec1      = dat_0.MAGF
vec2      = REFORM(vbulk_o[j,*])
dat_0.VSW = vec2
dfra      = [1d-14,1d-8]
fnm       = file_name_times(dat_0.TIME,PREC=3)
ftimes    = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
fpref     = 'THB_IESA-Burst_original-Vbulk_'+ftimes[0]


popen,fpref[0]+'_plane-1',/PORT
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='xy',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]
pclose


popen,fpref[0]+'_plane-3',/PORT
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='xz',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]
pclose

popen,fpref[0]+'_plane-2',/PORT
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='yz',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]
pclose

;;----------------------------------------------------
;; => Look at DFs without "core"
;;----------------------------------------------------
dfmax    = 1d-6
dfmin    = 1d-14
vcirc    = 35e1

j        = good_i0[0] + 79L
dat_0    = dat_igse[j]
data     = dat_0[0].DATA - dummy[j].DATA
dat_0[0].DATA = data

vec1     = dat_0.MAGF
vec2     = dat_0.VSW

WSET,1
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      VCIRC=vcirc,PLANE='xy',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      VCIRC=vcirc,PLANE='xz',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,3
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      VCIRC=vcirc,PLANE='yz',EX_VEC1=sunv,    $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]












;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Step-by-Step
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
vlim      = 25e2
coord     = 'gse'
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
velname   = pref[0]+'peib_velocity_'+coord[0]
magname   = pref[0]+'fgh_'+coord[0]
spperi    = pref[0]+'state_spinper'

get_data,spperi[0],DATA=sp_per
get_data,magname[0],DATA=bgse_htr

j         = 79L
dat0      = dat_i0[j]
data      = conv_units(dat_i0g[j],'df')

PRINT,';;',dat0.VSW
PRINT,';;',data.VSW
;;      -160.70730       52.027693       147.01220
;;      -160.70730       52.027693       147.01220

;; => Calculate spin rate [deg s^(-1)]
sp_t      = sp_per.X          ;; Unix times
sp_p      = sp_per.Y          ;; Spacecraft spin period [s]
n_e       = dat0.NENERGY      ;; => # of energy bins
n_a       = dat0.NBINS        ;; => # of angle bins
t0        = dat0.TIME[0]      ;; => Unix time at start of ESA sample period
t1        = dat0.END_TIME[0]  ;; => Unix time at end of ESA sample period
del_t     = t1[0] - t0[0]     ;; => Total time of data sample
;; => Create array of dummy timestamps
dumbt     = DINDGEN(n_e,n_a)*del_t[0]/(n_e[0]*n_a[0] - 1L) + t0[0]
;; => Calculate spin period [s/rotation] at ESA structure time
spp0      = MEAN(interp(sp_p,sp_t,dumbt,/NO_EXTRAP),/NAN)
;; => Calculate spin rate [deg s^(-1)] at ESA structure time
sprate    = 36d1/spp0[0]      ;;  [deg s^(-1)]
PRINT,';;', spp0[0], sprate[0]
;;       2.9679534       121.29570

;; => Determine the time stamps for each angle bin
t_esa     = timestamp_esa_angle_bins(dat0,sprate[0])

;;------------------------------------------------------------
;; => Convert into solar wind frame
;;------------------------------------------------------------
data2     = data
transform_vframe_3d,data,/EASY_TRAN

;;------------------------------------------------------------
;; => Rotate DF into new reference frame
;;------------------------------------------------------------
vec2      = data.VSW          ;; GSE velocity [km/s]
n_e       = data.NENERGY             ;; => # of energy bins [ = E]
n_a       = data.NBINS               ;; => # of angle bins  [ = A]
kk        = n_e*n_a
ind_2d    = INDGEN(n_e,n_a)         ; => original indices of angle bins

energy    = data.ENERGY              ; => Energy bin values [eV]
df_dat    = data.DATA                ; => Data values [data.UNITS_NAME]

phi       = data.PHI                 ; => Azimuthal angle (from sun direction) [deg]
dphi      = data.DPHI                ; => Uncertainty in phi
theta     = data.THETA               ; => Poloidal angle (from ecliptic plane) [deg]
dtheta    = data.DTHETA              ; => Uncertainty in theta

tacc      = data.DT                  ; => Accumulation time [s] of each angle bin
t0        = data.TIME[0]             ; => Unix time at start of 3DP sample period
t1        = data.END_TIME[0]         ; => Unix time at end of 3DP sample period
del_t     = t1[0] - t0[0]           ; => Total time of data sample
;; => Reform 2D arrays into 1D
phi_1d    = REFORM(phi,kk)
the_1d    = REFORM(theta,kk)
dat_1d    = REFORM(df_dat,kk)
ener_1d   = REFORM(energy,kk)
ind_1d    = REFORM(ind_2d,kk)
tesa_1d   = REFORM(t_esa,kk)
;; => Define BGSE_HTR structure parameters
htr_t     = bgse_htr.X        ; => Unix times
htr_b     = bgse_htr.Y        ; => GSE B-field [nT]
;; => Interpolate HTR MFI data to 3dp angle bin times
magfx     = interp(htr_b[*,0],htr_t,tesa_1d,/NO_EXTRAP)  ;; [K]-Element array
magfy     = interp(htr_b[*,1],htr_t,tesa_1d,/NO_EXTRAP)  ;; [K]-Element array
magfz     = interp(htr_b[*,2],htr_t,tesa_1d,/NO_EXTRAP)  ;; [K]-Element array
bmag      = SQRT(magfx^2 + magfy^2 + magfz^2)            ;; [K]-Element array

;; plot fields
WINDOW,1,RETAIN=2,XSIZE=1200,YSIZE=800
!P.MULTI  = [0,1,2]
yrab      = [MIN(bmag,/NAN)/1.05,MAX(bmag,/NAN)*1.05]
yraf      = [-1d0,1d0]*MAX(ABS([magfx,magfy,magfz]),/NAN)*1.05
tt0       = tesa_1d - MIN(tesa_1d,/NAN)
WSET,1
PLOT,tt0,bmag,YRANGE=yrab,/YSTYLE,/XSTYLE,/NODATA
  OPLOT,tt0,bmag,PSYM=2
PLOT,tt0,magfx,YRANGE=yraf,/YSTYLE,/XSTYLE,/NODATA
  OPLOT,tt0,magfx,PSYM=2,COLOR=250
  OPLOT,tt0,magfy,PSYM=2,COLOR=150
  OPLOT,tt0,magfz,PSYM=2,COLOR= 50
!P.MULTI  = 0

;; => define corresponding unit vectors
umagfx    = magfx/bmag
umagfy    = magfy/bmag
umagfz    = magfz/bmag
umagf     = [[umagfx],[umagfy],[umagfz]]                 ;; [K,3]-Element array
;; => Convert [Energies,Angles]  -->  Velocities
;; => Magnitude of velocities from energy (km/s)
nvmag     = energy_to_vel(ener_1d,data[0].MASS[0])
coth      = COS(the_1d*!DPI/18d1)
sith      = SIN(the_1d*!DPI/18d1)
coph      = COS(phi_1d*!DPI/18d1)
siph      = SIN(phi_1d*!DPI/18d1)
;; => Define directions
swfv      = DBLARR(kk,3L)              ;;  [K,3]-Element array
swfv[*,0] = nvmag*coth*coph            ;; => Define X-Velocity per energy per data bin
swfv[*,1] = nvmag*coth*siph            ;; => Define Y-Velocity per energy per data bin
swfv[*,2] = nvmag*sith                 ;; => Define Z-Velocity per energy per data bin

mx_df     = MAX(dat_1d,l_df,/NAN)
PRINT,';;', mx_df[0], l_df[0]
;;  4.13944e-06        1935

PRINT,';;', REFORM(swfv[l_df[0],*])
;;      -126.17095      0.97644134      -123.93565

vpeak     = REFORM(swfv[l_df[0],*])    ;;  Velocity at peak [km/s]
swpv      = DBLARR(kk,3L)              ;;  [K,3]-Element array
swpv[*,0] = swfv[*,0] - vpeak[0]
swpv[*,1] = swfv[*,1] - vpeak[1]
swpv[*,2] = swfv[*,2] - vpeak[2]
PRINT,';;', REFORM(swpv[l_df[0],*])
;;       0.0000000       0.0000000       0.0000000

vsw_vp    = data[0].VSW + vpeak
PRINT,';;', data[0].VSW
PRINT,';;', vsw_vp
;;      -160.70730       52.027693       147.01220
;;      -286.87825       53.004134       23.076549


v_new     = fix_vbulk_ions(data)
PRINT,';;', v_new.VSW_OLD
PRINT,';;', v_new.VSW_NEW
;;      -160.70730       52.027693       147.01220
;;      -286.87825       53.004134       23.076549


;; => Define rotations to planes defined by Bo and Vsw
v1        = umagf                       ;; [K,3]-Element array
v2        = vec2/NORM(vec2)             ;; normalize
v2d       = REPLICATE(1d0,kk) # v2      ;; [K,3]-Element array
;; => Define rotation matrices equivalent to cal_rot.pro
rotm      = rot_matrix_array_dfs(v1,v2d,/CAL_ROT)  ;;  [K,3,3]-element array
;; => Define rotation matrices equivalent to rot_mat.pro
rotz      = rot_matrix_array_dfs(v1,v2d)           ;;  [K,3,3]-element array
;; => Rotate velocities into new coordinate basis and triangulate
r_vels    = rotate_and_triangulate_dfs(swfv,dat_1d,rotm,rotz,VLIM=vlim)

str_xy    = r_vels.PLANE_XY
str_xz    = r_vels.PLANE_XZ
str_yz    = r_vels.PLANE_YZ
;; => Regularly gridded velocities (for contour plots)
vx2d      = r_vels.VX2D
vy2d      = r_vels.VY2D

mx_xy     = MAX(str_xy.DF2D_XY,l_xy,/NAN)
mx_xz     = MAX(str_xz.DF2D_XZ,l_xz,/NAN)
mx_yz     = MAX(str_yz.DF2D_YZ,l_yz,/NAN)
PRINT,';;', l_xy[0], l_xz[0], l_yz[0]
;;        4799        5299        5298

ind_xy    = ARRAY_INDICES(str_xy.DF2D_XY,l_xy)
ind_xz    = ARRAY_INDICES(str_xz.DF2D_XZ,l_xz)
ind_yz    = ARRAY_INDICES(str_yz.DF2D_YZ,l_yz)
PRINT,';;', ind_xy
PRINT,';;', ind_xz
PRINT,';;', ind_yz
;;          52          47
;;          47          52
;;          46          52

PRINT,';;', vx2d[ind_xy[0]], vy2d[ind_xy[1]]
PRINT,';;', vx2d[ind_xz[0]], vy2d[ind_xz[1]]
PRINT,';;', vx2d[ind_yz[0]], vy2d[ind_yz[1]]
;;      100.000     -150.000
;;     -150.000      100.000
;;     -200.000      100.000




;; => Rotate DF into new reference frame
vec2      = data.VSW          ;; GSE velocity [km/s]
rotate_esa_htr_structure,data,t_esa,bgse_htr,vec2,VLIM=vlim
;; => Define B-field at start of DF
t00       = data.TIME
magx      = interp(bgse_htr.Y[*,0],bgse_htr.X,t00,/NO_EXTRAP)
magy      = interp(bgse_htr.Y[*,1],bgse_htr.X,t00,/NO_EXTRAP)
magz      = interp(bgse_htr.Y[*,2],bgse_htr.X,t00,/NO_EXTRAP)
magf_st   = [magx,magy,magz]













;; => Rotate velocities into new coordinate basis and triangulate
vel_r     = DBLARR(kk,3L)                   ;;  Velocity rotated by ROTM
vel_z     = DBLARR(kk,3L)                   ;;  Velocity rotated by ROTZ

temp_r    = REBIN(swfv,kk,3L,3L)            ;;  expand to a [K,3,3]-element array
;; => Apply rotations [vectorized]
temp_rm   = TOTAL(temp_r*rotm,2L)           ;; Sum over the 2nd column {[K,3]-Elements}
temp_rz   = TOTAL(temp_r*rotz,2L)           ;; Sum over the 2nd column {[K,3]-Elements}
vel_r     = temp_rm
vel_z     = temp_rz
;; => Define new basis velocities components [cal_rot.pro]
vel2dx        = REFORM(vel_r[*,0])
vyz2d         = SQRT(TOTAL(vel_r[*,1:2]^2,2,/NAN))
vel2dy        = vyz2d*REFORM(vel_r[*,1])/ABS(REFORM(vel_r[*,1]))
vel2dz        = vyz2d*REFORM(vel_r[*,2])/ABS(REFORM(vel_r[*,2]))
;; => Define new basis velocities components [rot_mat.pro]
vyz2d_z       = SQRT(TOTAL(vel_z[*,1:2]^2,2,/NAN))
vel2dx_z      = REFORM(vel_z[*,0])
vel2dy_z      = vyz2d_z*REFORM(vel_z[*,1])/ABS(REFORM(vel_z[*,1]))
vel2dz_z      = vyz2d_z*REFORM(vel_z[*,2])/ABS(REFORM(vel_z[*,2]))
; => Y vs. X Plane projection
TRIANGULATE, vel2dx, vel2dy, tr
; => put DF on regular grid
dgs           = vlim[0]/5e1
gs            = [dgs,dgs]               ;; => grid spacing for triangulation used later
xylim         = [-1*vlim[0],-1*vlim[0],vlim[0],vlim[0]]
df2d_xy       = TRIGRID(vel2dx,vel2dy,dat_1d,tr,gs,xylim,MISSING=f)



;; => Temporarily turn off messages b/c TDAS is too chatty
PREF_SET,'IDL_QUIET',1,/COMMIT
;; => Turn on messages
PREF_SET,'IDL_QUIET',0,/COMMIT

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------












;;----------------------------------------------------
;; => Convert into SW frame
;;----------------------------------------------------
del       = dat_igse[0]
transform_vframe_3d,del,/EASY_TRAN

dumb_i    = REPLICATE(del[0],n_i)
FOR j=0L, n_i - 1L DO BEGIN                     $
  del       = dat_igse[j]                     & $
  transform_vframe_3d,del,/EASY_TRAN          & $
  dumb_i[j] = del[0]

;;----------------------------------------------------
;; => Define DAT structure parameters
;;----------------------------------------------------
n_e       = dumb_i[0].NENERGY       ;; => # of energy bins     [ = E]
n_a       = dumb_i[0].NBINS         ;; => # of angle bins      [ = A]
n_n       = n_i                     ;; => # of data structures [ = N]
mass      = dumb_i[0].MASS          ;; proton mass [eV c^(-2), with c in km/s]
;;  The following are:  [E,A,N]-Element Arrays
energy    = dumb_i.ENERGY           ;; Energy bin values [eV]
phi       = dumb_i.PHI              ;; Azimuthal angle (from sun direction) [deg]
theta     = dumb_i.THETA            ;; Poloidal angle (from ecliptic plane) [deg]
data      = dumb_i.DATA             ;; Data [s^(+3) cm^(-3) km^(-3)]
;;  Define spacecraft frame angles
phi_sc    = dat_igse.PHI MOD 36e1   ;; Azimuthal angle (from sun direction) [deg]
the_sc    = dat_igse.THETA          ;; Poloidal angle (from ecliptic plane) [deg]
;;----------------------------------------------------
;;  Convert energy/angles into cartesian velocities
;;----------------------------------------------------
coth      = COS(theta*!DPI/18d1)
sith      = SIN(theta*!DPI/18d1)
coph      = COS(phi*!DPI/18d1)
siph      = SIN(phi*!DPI/18d1)
;;    => Magnitude of velocities from energy (km/s)
nvmag     = energy_to_vel(energy,mass[0])
;; => Define directions
swfv      = DBLARR(n_e,n_a,n_n,3L)  ;; cartesian velocities [km/s]
swfv[*,*,*,0] = nvmag*coth*coph     ;; => Define X-Velocity per energy per data bin
swfv[*,*,*,1] = nvmag*coth*siph     ;; => Define Y-Velocity per energy per data bin
swfv[*,*,*,2] = nvmag*sith          ;; => Define Z-Velocity per energy per data bin

;;----------------------------------------------------
;;  Define gyrating ion mask [good for |V| ≤ V_thresh]
;;----------------------------------------------------
v_thresh  = 3e2
mask_gi   = REPLICATE(0e0,n_e,n_a,n_n)
FOR j=0L, n_i - 1L DO BEGIN                                $
  temp0     = REPLICATE(0e0,n_e,n_a)                     & $
  vmag0     = nvmag[*,*,j]                               & $
  good      = WHERE(vmag0 LE v_thresh[0],gd)             & $
  IF (gd GT 0) THEN temp0[good]    = 1e0                 & $
  mask_gi[*,*,j] = temp0

;  IF (gd GT 0) THEN gind = ARRAY_INDICES(vmag0,good)     & $
;  IF (gd GT 0) THEN mask_gi[gind[0,*],gind[1,*],j] = 1e0

;;----------------------------------------------------
;;  Define UV contamination mask [bad for |V| < 500 km/s and within ±15 deg of sun dir]
;;----------------------------------------------------
sunv      = [1d0,0d0,0d0]
;; => convert sun direction to polar angles
cart_to_sphere,1d0,0d0,0d0,rs,the_s,phi_s,PH_0_360=1
PRINT,';', rs, the_s, phi_s
;       1.0000000       0.0000000       0.0000000

v_uv      = 50e1
the_thr   = 15e0
phi_thr   = 15e0
;; => Define angular range to remove for UV contamination
phi_ls    = phi_s[0] + [-1d0,1d0]*phi_thr[0]
the_ls    = the_s[0] + [-1d0,1d0]*the_thr[0]

mask_uv   = REPLICATE(1e0,n_e,n_a,n_n)
FOR j=0L, n_i - 1L DO BEGIN                                                    $
  temp0     = REPLICATE(0e0,n_e,n_a)                                         & $
  vmag0     = nvmag[*,*,j]                                                   & $
  test0     = (vmag0 LE v_uv[0])                                             & $
  test1     = (phi_sc[*,*,j] LE phi_ls[1]) AND (phi_sc[*,*,j] GE phi_ls[0])  & $
  test2     = (the_sc[*,*,j] LE the_ls[1]) AND (the_sc[*,*,j] GE the_ls[0])  & $
  test      = test0 AND test1 AND test2                                      & $
  bad       = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)                  & $
  IF (gd GT 0) THEN temp0[good]    = 1e0                                     & $
  mask_uv[*,*,j] = temp0

;  test1 = (ABS(phi[*,*,j]) LE phi_ls[0])                 & $
;  test2 = (ABS(theta[*,*,j]) LE the_ls[0])               & $
;  IF (bd GT 0) THEN bind = ARRAY_INDICES(vmag0,bad)      & $
;  IF (bd GT 0) THEN mask_uv[bind[0,*],bind[1,*],j] = 0e0

;;----------------------------------------------------
;;  Define overall mask
;;----------------------------------------------------
mask_aa  = REPLICATE(0e0,n_e,n_a,n_n)
FOR j=0L, n_i - 1L DO BEGIN                                $
  temp0     = REPLICATE(0e0,n_e,n_a)                     & $
  t_mask_gi = REFORM(mask_gi[*,*,j]) GT 0                & $
  t_mask_uv = REFORM(mask_uv[*,*,j]) GT 0                & $
  good      = WHERE(t_mask_gi AND t_mask_uv,gd)          & $
  IF (gd GT 0) THEN temp0[good]    = 1e0                 & $
  mask_aa[*,*,j] = temp0

;  IF (gd GT 0) THEN gind = ARRAY_INDICES(t_mask_gi,good) & $
;  IF (gd GT 0) THEN mask_aa[gind[0,*],gind[1,*],j] = 1e0





;;----------------------------------------------------------------------------------------
;; => Modify structures so they work in my plotting routines
;;----------------------------------------------------------------------------------------
modify_themis_esa_struc,dat_i
modify_themis_esa_struc,dat_e

;; add SC potential to structures
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
scname    = tnames(pref[0]+'pe*b_sc_pot')

add_scpot,dat_e,scname[0]
add_scpot,dat_i,scname[1]

;; => Rotate IESA (theta,phi)-angles DSL --> GSE
coord    = 'gse'
sc       = probe[0]
vel_name = pref[0]+'peib_velocity_'+coord[0]
mag_name = pref[0]+'fgh_'+coord[0]
rotate_esa_thetaphi_to_gse,dat_i,MAGF_NAME=mag_name,VEL_NAME=vel_name


;; => Rotate EESA (theta,phi)-angles DSL --> GSE
coord    = 'gse'
sc       = probe[0]
vel_name = pref[0]+'peeb_velocity_'+coord[0]
mag_name = pref[0]+'fgh_'+coord[0]
rotate_esa_thetaphi_to_gse,dat_e,MAGF_NAME=mag_name,VEL_NAME=vel_name
;-----------------------------------------------------------------------------------------
; => Set up plot windows and defaults
;-----------------------------------------------------------------------------------------
WINDOW,1,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,2,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,3,RETAIN=2,XSIZE=800,YSIZE=1100

; => setup colors
LOADCT,39
DEVICE,DECOMPOSED=0


; => Define shock parameters
;;        => flip solutions to outward normal [contour min in opposite direction]
vshn_0  = -1d0*(3.6977553d0)
ushn_0  = -1d0*(204.62596d0)
gnorm_0 = -1d0*[-0.54904591d0,-0.068017244d0,0.82887820d0]
; => Vsw [GSE], |Vsw| (km/s)
vsw_up0 = [-252.883d0,-7.32447d0,83.2220d0]
vmag_u0 = NORM(vsw_up0)
; => B [GSE], |B| (nT)
mag_up0 = [-2.88930d0,1.79045d0,-1.37976d0]
bmag_u0 = NORM(mag_up0)

; => flip solutions to outward normal [contour min in opposite direction]
vshn_1  = -1d0*8.3990575d0
ushn_1  = -1d0*272.10318d0
gnorm_1 = -1d0*[-0.98231348d0,-0.10981114d0,0.019119436d0]
; => Vsw [GSE], |Vsw| (km/s)
vsw_up1 = [-284.261d0,-14.5620d0,-17.2934d0]
vmag_u1 = NORM(vsw_up1)
; => B [GSE], |B| (nT)
mag_up1 = [-2.16373d0,-1.43950d0,1.97681d0]
bmag_u1 = NORM(mag_up1)

vshn_2  = vshn_1[0]
ushn_2  = ushn_1[0]
gnorm_2 = gnorm_1
vsw_up2 = vsw_up1
vmag_u2 = vmag_u1
mag_up2 = mag_up1
bmag_u2 = bmag_u1

;-----------------------------------------------------
; => Calculate gyrospeeds of specular reflection
;-----------------------------------------------------

; => calculate unit vectors
bhat0    = mag_up0/bmag_u0[0]
vhat0    = vsw_up0/vmag_u0[0]
bhat1    = mag_up1/bmag_u1[0]
vhat1    = vsw_up1/vmag_u1[0]
bhat2    = bhat1
vhat2    = vhat1
; => calculate upstream inflow velocity
v_up_0   = vsw_up0 - gnorm_0*vshn_0[0]
v_up_1   = vsw_up1 - gnorm_1*vshn_1[0]
v_up_2   = v_up_1
; => Eq. 2 from Gosling et al., [1982]
;      [specularly reflected ion velocity]
Vref_0   = v_up_0 - gnorm_0*(2d0*my_dot_prod(v_up_0,gnorm_0,/NOM))
Vref_1   = v_up_1 - gnorm_1*(2d0*my_dot_prod(v_up_1,gnorm_1,/NOM))
Vref_2   = Vref_1
; => Eq. 4 and 3 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion]
Vper_r0  = v_up_0 - bhat0*my_dot_prod(v_up_0,bhat0,/NOM)  ; => Eq. 4
Vper_r1  = v_up_1 - bhat1*my_dot_prod(v_up_1,bhat1,/NOM)  ; => Eq. 4
Vper_r2  = Vper_r1
Vgc_r_0  = Vper_r0 + bhat0*(my_dot_prod(Vref_0,bhat0,/NOM))
Vgc_r_1  = Vper_r1 + bhat1*(my_dot_prod(Vref_1,bhat1,/NOM))
Vgc_r_2  = Vgc_r_1
; => Eq. 6 from Gosling et al., [1982]
;      [gyro-velocity of a specularly reflected ion]
Vgy_r_0  = Vref_0 - Vgc_r_0
Vgy_r_1  = Vref_1 - Vgc_r_1
Vgy_r_2  = Vgy_r_1
; => Eq. 7 and 9 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion perp. to shock surface]
Vgcn_r_0 = my_dot_prod(Vgc_r_0,gnorm_0,/NOM)
Vgcn_r_1 = my_dot_prod(Vgc_r_1,gnorm_1,/NOM)
Vgcn_r_2 = Vgcn_r_1
;      [guiding center velocity of a specularly reflected ion para. to B-field]
Vgcb_r_0 = my_dot_prod(Vgc_r_0,bhat0,/NOM)
Vgcb_r_1 = my_dot_prod(Vgc_r_1,bhat1,/NOM)
Vgcb_r_2 = Vgcb_r_1
; => gyrospeed
Vgy_rs_0 = NORM(REFORM(Vgy_r_0))
Vgy_rs_1 = NORM(REFORM(Vgy_r_1))
Vgy_rs_2 = Vgy_rs_1

PRINT,';', Vgy_rs_0[0], Vgy_rs_1[0], Vgy_rs_2[0]
;       406.31657       374.12222       374.12222


Vgy_rs   = [406.31657d0,374.12222d0,374.12222d0]
;-----------------------------------------------------
; IESA
;-----------------------------------------------------
i_time0 = dat_i.TIME
i_time1 = dat_i.END_TIME
tbow0   = time_double(tdate[0]+'/'+['08:56:00.000','09:10:00.000'])
tbow1   = time_double(tdate[0]+'/'+['09:14:00.000','09:30:00.000'])
tbow2   = time_double(tdate[0]+'/'+['09:30:00.000','09:44:00.000'])
good_i0 = WHERE(i_time0 GE tbow0[0] AND i_time1 LE tbow0[1],gdi0)
good_i1 = WHERE(i_time0 GE tbow1[0] AND i_time1 LE tbow1[1],gdi1)
good_i2 = WHERE(i_time0 GE tbow2[0] AND i_time1 LE tbow2[1],gdi2)
PRINT,';', gdi0, gdi1, gdi2
;         281         318         279

dat_i0  = dat_i[good_i0]
dat_i1  = dat_i[good_i1]
dat_i2  = dat_i[good_i2]

;gnorm   = [0.,1.,0.]
;normnm  = 'Y-GSE'
;vcirc   = 750d0             ; => Put a circle of constant energy at  750 km/s on contours

ngrid   = 30L
sunv    = [1.,0.,0.]
sunn    = 'Sun Dir.'
xname   = 'B!Do!N'
yname   = 'V!Dsw!N'

vlim    = 25e2
ns      = 7L
smc     = 1
smct    = 1
;dfmin   = 1d-20
dfmax   = 1d-1
dfmin   = 1d-15
;dfmax   = 1d-5

;j       = 102L
j       = 79L
tr_ie   = tbow0
dat_0   = dat_i0[j]
gnorm   = gnorm_0
normnm  = 'Shock Normal[0]'
vcirc   = Vgy_rs[0]
;tr_ie   = tbow1
;dat_0   = dat_i1[j]
;gnorm   = gnorm_1
;normnm  = 'Shock Normal[1]'
;vcirc   = Vgy_rs[1]
;tr_ie   = tbow2
;dat_0   = dat_i2[j]
;gnorm   = gnorm_2
;normnm  = 'Shock Normal[2]'
;vcirc   = Vgy_rs[2]
WSET,0
mode    = 'fgh'
names   = 'th'+sc[0]+'_'+[mode[0]+['_mag','_gsm'],'efw_cal_gsm','scw_gsm_L2']
  tplot,names,/NOM,TRANGE=tr_ie
  time_bar,dat_0[0].TIME,VARNAME=names,COLOR=250L
  time_bar,dat_0[0].END_TIME,VARNAME=names,COLOR= 50L

vec1    = dat_0.MAGF
vec2    = dat_0.VSW

WSET,1
WSHOW,1
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,2
WSHOW,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xz',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='yz',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]
;-----------------------------------------------------
; => Make a ?? fps movie
;-----------------------------------------------------
tbow0      = time_double(tdate[0]+'/'+['08:56:00.000','09:10:00.000'])
tbow1      = time_double(tdate[0]+'/'+['09:14:00.000','09:30:00.000'])
tbow2      = time_double(tdate[0]+'/'+['09:30:00.000','09:44:00.000'])
sunv       = [1.,0.,0.]     ; => sun direction in GSE coordinates
sunn       = 'Sun Dir.'     ; => string associated with sun direction
timename   = ['thb_fgh_mag','thb_fgh_gse']

dat_aa     = dat_i0
gnorm      = gnorm_0
normnm     = 'Shock Normal[0]'
vcirc      = Vgy_rs[0]
;tr_aa      = tbow0

;dat_aa     = dat_i1
;gnorm      = gnorm_1
;normnm     = 'Shock Normal[1]'
;vcirc      = Vgy_rs[1]
;tr_aa      = tbow1

ngrid      = 30L
xname      = 'B!Do!N'
yname      = 'V!Dsw!N'
vlim       = 25e2
ns         = 7L
smc        = 1
smct       = 1
dfmax      = 1d-6
dfmin      = 1d-15
fps        = 4L             ; frames per second

;tr_aa      = time_double(tdate[0]+'/'+['09:00:00.000','09:03:00.000'])
tr_aa      = time_double(tdate[0]+'/'+['09:00:00.000','09:04:00.000'])

contour_df_pos_slide_wrapper,timename,dat_aa,VLIM=vlim[0],NGRID=ngrid[0],XNAME=xname[0],  $
                              YNAME=yname[0],VCIRC=vcirc[0],EX_VEC0=gnorm,                $
                              EX_VN0=normnm[0],EX_VEC1=sunv,EX_VN1=sunn[0],               $
                              PLANE='xy',SM_CONT=smct,DFRA=dfra,TRANGE=tr_aa,TROUTER=21d0,$
                              TSNAMES='FGM-fgh-GSE_',FRAMERATE=fps[0],/KEEP_SNAPS


; => try making a movie with:
;     x-axis = n
;     y-axis = (n x Xgse) x Xgse
niesa      = N_ELEMENTS(dat_aa)
xname      = 'n!Dsh!N'
yname      = 'X!Dgse!N'
vector10   = gnorm_0
vector20   = [1d0,0d0,0d0]
vec1       = DBLARR(niesa,3L)
vec2       = DBLARR(niesa,3L)
FOR k=0L, 2L DO vec1[*,k] = vector10[k]
FOR k=0L, 2L DO vec2[*,k] = vector20[k]

contour_df_pos_slide_wrapper,timename,dat_aa,VLIM=vlim[0],NGRID=ngrid[0],XNAME=xname[0], $
                              YNAME=yname[0],VCIRC=vcirc[0],PLANE='xy',                  $
                              SM_CONT=smct,DFRA=dfra,TRANGE=tr_aa,TROUTER=21d0,          $
                              TSNAMES='FGM-fgh-GSE_',FRAMERATE=fps[0],VECTOR1=vec1,      $
                              VECTOR2=vec2,EX_VEC0=gnorm,EX_VN0=normnm[0],EX_VEC1=sunv,  $
                              EX_VN1=sunn[0]

;-----------------------------------------------------
; => full time range
;-----------------------------------------------------
dat_aa     = dat_i0
gnorm      = gnorm_0
normnm     = 'Shock Normal[0]'
vcirc      = Vgy_rs[0]
tr_aa      = tbow0

ngrid      = 30L
xname      = 'B!Do!N'
yname      = 'V!Dsw!N'
vlim       = 25e2
ns         = 7L
smc        = 1
smct       = 1
dfmax      = 1d-6
dfmin      = 1d-15
fps        = 5L             ; frames per second

niesa      = N_ELEMENTS(dat_aa)
xname      = 'n!Dsh!N'
yname      = 'X!Dgse!N'
vector10   = gnorm_0
vector20   = [1d0,0d0,0d0]
vec1       = DBLARR(niesa,3L)
vec2       = DBLARR(niesa,3L)
FOR k=0L, 2L DO vec1[*,k] = vector10[k]
FOR k=0L, 2L DO vec2[*,k] = vector20[k]

contour_df_pos_slide_wrapper,timename,dat_aa,VLIM=vlim[0],NGRID=ngrid[0],XNAME=xname[0], $
                              YNAME=yname[0],VCIRC=vcirc[0],PLANE='xy',                  $
                              SM_CONT=smct,DFRA=dfra,TRANGE=tr_aa,TROUTER=21d0,          $
                              TSNAMES='FGM-fgh-GSE_',FRAMERATE=fps[0],VECTOR1=vec1,      $
                              VECTOR2=vec2,EX_VEC0=gnorm,EX_VN0=normnm[0],EX_VEC1=sunv,  $
                              EX_VN1=sunn[0]


; => shorter:
tr_aa      = time_double(tdate[0]+'/'+['08:59:10.000','09:03:35.000'])
ngrid      = 30L
xname      = 'B!Do!N'
yname      = 'V!Dsw!N'
vlim       = 25e2
ns         = 7L
smc        = 1
smct       = 1
dfmax      = 1d-6
dfmin      = 1d-15
fps        = 5L             ; frames per second

niesa      = N_ELEMENTS(dat_aa)
xname      = 'n!Dsh!N'
yname      = 'X!Dgse!N'
vector10   = gnorm_0
vector20   = [1d0,0d0,0d0]
vec1       = DBLARR(niesa,3L)
vec2       = DBLARR(niesa,3L)
FOR k=0L, 2L DO vec1[*,k] = vector10[k]
FOR k=0L, 2L DO vec2[*,k] = vector20[k]
contour_df_pos_slide_wrapper,timename,dat_aa,VLIM=vlim[0],NGRID=ngrid[0],XNAME=xname[0], $
                              YNAME=yname[0],VCIRC=vcirc[0],PLANE='xy',                  $
                              SM_CONT=smct,DFRA=dfra,TRANGE=tr_aa,TROUTER=21d0,          $
                              TSNAMES='FGM-fgh-GSE_',FRAMERATE=fps[0],VECTOR1=vec1,      $
                              VECTOR2=vec2,EX_VEC0=gnorm,EX_VN0=normnm[0],EX_VEC1=sunv,  $
                              EX_VN1=sunn[0]

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------
; => Save plots
;-----------------------------------------------------
ngrid   = 30L
sunv    = [1.,0.,0.]
sunn    = 'Sun Dir.'
xname   = 'B!Do!N'
yname   = 'V!Dsw!N'

vlim    = 25e2
ns      = 7L
smc     = 1
smct    = 1
dfmin   = 1d-14
dfmax   = 1d-5

dat_aa  = dat_i0
gnorm   = gnorm_0
normnm  = 'Shock Normal[0]'
vcirc   = Vgy_rs_0[0]
;dat_aa  = dat_i1
;gnorm   = gnorm_1
;normnm  = 'Shock Normal[1]'
;vcirc   = Vgy_rs_1[0]
;dat_aa  = dat_i2
;gnorm   = gnorm_2
;normnm  = 'Shock Normal[2]'
;vcirc   = Vgy_rs_2[0]

niesa   = N_ELEMENTS(dat_aa)
fnm     = file_name_times(dat_aa.TIME,PREC=3)
ftimes  = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494


scu     = STRUPCASE(probe[0])
df_sfxa = STRCOMPRESS(STRING(dfmin[0],FORMAT='(E10.1)'),/REMOVE_ALL)
vlim_st = STRING(vlim[0],FORMAT='(I5.5)')
xyzvecs = ['(V.B)','(BxV)xB','(BxV)']
xyzvecf = ['V1','V1xV2xV1','V1xV2']
planes  = ['xy','xz','yz']
xy_suff = '_'+xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff = '_'+xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff = '_'+xyzvecf[2]+'_vs_'+xyzvecf[1]
;xy_suff = '_'+xyzvecs[1]+'_vs_'+xyzvecs[0]
;xz_suff = '_'+xyzvecs[0]+'_vs_'+xyzvecs[2]
;yz_suff = '_'+xyzvecs[2]+'_vs_'+xyzvecs[1]
midstr  = '_Cuts-DF-Above_'

pref_a  = 'IESA_TH-'+scu[0]+'_'+ftimes+'_30Grids_'+vlim_st[0]+'km-s'
fnamexy = pref_a+xy_suff[0]+midstr[0]+df_sfxa
fnamexz = pref_a+xz_suff[0]+midstr[0]+df_sfxa
fnameyz = pref_a+yz_suff[0]+midstr[0]+df_sfxa
fnames  = [[fnamexy],[fnamexz],[fnameyz]]

FOR j=0L, niesa - 1L DO BEGIN                                                    $
  dat_0   = dat_aa[j]                                                          & $
  vec1    = dat_0.MAGF                                                         & $
  vec2    = dat_0.VSW                                                          & $
  FOR k=0L, 2L DO BEGIN                                                          $
    popen,fnames[j,k],/PORT                                                    & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,       $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,               $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE=planes[k],EX_VEC1=sunv,   $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],           $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],       $
                        DFMAX=dfmax[0]                                         & $
    pclose

;; # Bash commands
mv IESA_TH-B_*_V1_vs_V1xV2_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1_vs_V1xV2/
mv IESA_TH-B_*_V1xV2_vs_V1xV2xV1_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2_vs_V1xV2xV1/
mv IESA_TH-B_*_V1xV2xV1_vs_V1_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2xV1_vs_V1/

;;-----------------------------------------------------
;; => Force DF range for emphasizing contours
;;-----------------------------------------------------
dfra    = [1d-14,1d-8]
scu     = STRUPCASE(probe[0])
df_sfx0 = STRCOMPRESS(STRING(dfra[0],FORMAT='(E10.1)'),/REMOVE_ALL)
df_sfx1 = STRCOMPRESS(STRING(dfra[1],FORMAT='(E10.1)'),/REMOVE_ALL)
df_sfxa = df_sfx0[0]+'-'+df_sfx1[0]
vlim_st = STRING(vlim[0],FORMAT='(I5.5)')
xyzvecs = ['(V.B)','(BxV)xB','(BxV)']
xyzvecf = ['Bo','BoxVswxBo','BoxVsw']
planes  = ['xy','xz','yz']
xy_suff = '_'+xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff = '_'+xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff = '_'+xyzvecf[2]+'_vs_'+xyzvecf[1]
midstr  = '_Cuts-DF_'

pref_a  = 'ContourOnly_IESA_TH-'+scu[0]+'_'+ftimes+'_30Grids_'+vlim_st[0]+'km-s'
fnamexy = pref_a+xy_suff[0]+midstr[0]+df_sfxa[0]
fnamexz = pref_a+xz_suff[0]+midstr[0]+df_sfxa[0]
fnameyz = pref_a+yz_suff[0]+midstr[0]+df_sfxa[0]
fnames  = [[fnamexy],[fnamexz],[fnameyz]]

FOR j=0L, niesa - 1L DO BEGIN                                                    $
  dat_0   = dat_aa[j]                                                          & $
  vec1    = dat_0.MAGF                                                         & $
  vec2    = dat_0.VSW                                                          & $
  FOR k=0L, 2L DO BEGIN                                                          $
    popen,fnames[j,k],/PORT                                                    & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,       $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,               $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE=planes[k],EX_VEC1=sunv,   $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],           $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],       $
                        DFMAX=dfmax[0]                                         & $
    pclose

;; # Bash commands
mv ContourOnly_IESA_TH-B_*_Bo_vs_BoxVsw_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1_vs_V1xV2/
mv ContourOnly_IESA_TH-B_*_BoxVsw_vs_BoxVswxBo_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2_vs_V1xV2xV1/
mv ContourOnly_IESA_TH-B_*_BoxVswxBo_vs_Bo_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2xV1_vs_V1/


;;-----------------------------------------------------
;; => Use shock normal as horizontal
;;      +Xgse as vertical
;;-----------------------------------------------------
ngrid   = 30L
sunv    = [1d0,0d0,0d0]
gnorm   = gnorm_0
yname   = 'X!Dgse!N'
xname   = 'n!Dsh!N'
exnm0   = 'B!Do!N'
exnm1   = 'X!Dgse!N'
exv1    = [1d0,0d0,0d0]

vlim    = 25e2
ns      = 7L
smc     = 1
smct    = 1
dfmin   = 1d-14
dfmax   = 1d-5
dfra    = [1d-14,1d-8]
vcirc   = Vgy_rs[0]

dat_aa  = dat_i0
niesa   = N_ELEMENTS(dat_aa)
fnm     = file_name_times(dat_aa.TIME,PREC=3)
ftimes  = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494

scu     = STRUPCASE(probe[0])
df_sfx0 = STRCOMPRESS(STRING(dfra[0],FORMAT='(E10.1)'),/REMOVE_ALL)
df_sfx1 = STRCOMPRESS(STRING(dfra[1],FORMAT='(E10.1)'),/REMOVE_ALL)
df_sfxa = df_sfx0[0]+'-'+df_sfx1[0]
vlim_st = STRING(vlim[0],FORMAT='(I5.5)')
xyzvecs = ['(V.B)','(BxV)xB','(BxV)']
xyzvecf = ['n','nxXGSExn','nxXGSE']
planes  = ['xy','xz','yz']
xy_suff = '_'+xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff = '_'+xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff = '_'+xyzvecf[2]+'_vs_'+xyzvecf[1]
midstr  = '_Cuts-DF_'

pref_a  = 'ContourOnly_IESA_TH-'+scu[0]+'_'+ftimes+'_30Grids_'+vlim_st[0]+'km-s'
fnamexy = pref_a+xy_suff[0]+midstr[0]+df_sfxa[0]
fnamexz = pref_a+xz_suff[0]+midstr[0]+df_sfxa[0]
fnameyz = pref_a+yz_suff[0]+midstr[0]+df_sfxa[0]
fnames  = [[fnamexy],[fnamexz],[fnameyz]]

FOR j=0L, niesa - 1L DO BEGIN                                                    $
  dat_0   = dat_aa[j]                                                          & $
  vec1    = gnorm                                                              & $
  vec2    = sunv                                                               & $
  exv0    = dat_0.MAGF                                                         & $
  FOR k=0L, 2L DO BEGIN                                                          $
    popen,fnames[j,k],/PORT                                                    & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,       $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,               $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE=planes[k],EX_VEC1=exv1,   $
                        EX_VN1=exnm1[0],EX_VEC0=exv0,EX_VN0=exnm0[0],            $
                        SM_CONT=smct,/NO_REDF,INTERP=inter                     & $
    pclose



;; # Bash commands
mv ContourOnly_IESA_TH-B_*_n_vs_nxXGSE_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1_vs_V1xV2/
mv ContourOnly_IESA_TH-B_*_nxXGSE_vs_nxXGSExn_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2_vs_V1xV2xV1/
mv ContourOnly_IESA_TH-B_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/IESA_Burst_DF/Plane_V1xV2xV1_vs_V1/
;;-----------------------------------------------------
;; => Plot FGM with zoom times
;;-----------------------------------------------------
WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100
i_time  = dat_aa.TIME

sc      = probe[0]
pref    = 'th'+sc[0]+'_'
coord   = 'gse'
;fgmnm   = pref[0]+'fgl_'+['mag',coord[0]]
fgmnm   = pref[0]+'fgh_'+['mag',coord[0]]

tr_dd   = time_double(tdate[0]+'/'+['08:50:32.000','09:02:12.000'])
tr_dd   = time_double(tdate[0]+'/'+['08:57:02.000','09:02:12.000'])
tr_dd   = time_double(tdate[0]+'/'+['08:58:40.000','09:01:00.000'])
tr_dd   = time_double(tdate[0]+'/'+['08:59:00.000','09:00:20.000'])

fnm     = file_name_times(tr_dd,PREC=3)
ftpref  = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)  ; e.g. 1998-08-09_0801x09.494
;fpref   = 'FGM-fgl-GSE_TH-B_'
fpref   = 'FGM-fgh-GSE_TH-B_'
fsuff   = '_IESA-Times'
fname   = fpref[0]+ftpref[0]+fsuff[0]

  tplot,fgmnm,/NOM,TRANGE=tr_dd
  time_bar,i_time,VARNAME=fgmnm,COLOR=250L
popen,fname[0],/LAND
  tplot,fgmnm,/NOM,TRANGE=tr_dd
  time_bar,i_time,VARNAME=fgmnm,COLOR=250L
pclose
;-----------------------------------------------------
; EESA
;-----------------------------------------------------
e_time0 = dat_e.TIME
e_time1 = dat_e.END_TIME
tbow0   = time_double(tdate[0]+'/'+['08:56:00.000','09:10:00.000'])
tbow1   = time_double(tdate[0]+'/'+['09:14:00.000','09:30:00.000'])
tbow2   = time_double(tdate[0]+'/'+['09:30:00.000','09:44:00.000'])
good_e0 = WHERE(e_time0 GE tbow0[0] AND e_time1 LE tbow0[1],gde0)
good_e1 = WHERE(e_time0 GE tbow1[0] AND e_time1 LE tbow1[1],gde1)
good_e2 = WHERE(e_time0 GE tbow2[0] AND e_time1 LE tbow2[1],gde2)
PRINT,';', gde0, gde1, gde2
;         282         319         279

dat_e0  = dat_e[good_e0]
dat_e1  = dat_e[good_e1]
dat_e2  = dat_e[good_e2]

;gnorm   = [0.,1.,0.]
;normnm  = 'Y-GSE'

ngrid   = 30L
sunv    = [1.,0.,0.]
sunn    = 'Sun Dir.'
xname   = 'B!Do!N'
yname   = 'V!Dsw!N'
planes  = ['xy','xz','yz']

;vlim    = 100e3
;vlim    = 60e3
; => Put circles every 5,000 km/s
vcirc   = 5d3*[1d0,2d0,3d0,4d0];,5d0]
ns      = 3L
smc     = 1
smct    = 1
dfmin   = 1d-18
inter   = 0

j       = 72L
vlim    = 40e3
tr_ee   = tbow0
dat_0   = dat_e0[j]
gnorm   = gnorm_0
normnm  = 'Shock Normal[0]'
;vlim    = 40e3
;tr_ee   = tbow1
;dat_0   = dat_e1[j]
;gnorm   = gnorm_1
;normnm  = 'Shock Normal[1]'
;vlim    = 40e3
;tr_ee   = tbow2
;dat_0   = dat_e2[j]
;gnorm   = gnorm_2
;normnm  = 'Shock Normal[2]'
WSET,0
mode    = 'fgh'
names   = 'th'+sc[0]+'_'+[mode[0]+['_mag','_gsm'],'efw_cal_gsm','scw_gsm_L2']
  tplot,names,/NOM,TRANGE=tr_ee
  time_bar,dat_0[0].TIME,VARNAME=names,COLOR=250L
  time_bar,dat_0[0].END_TIME,VARNAME=names,COLOR= 50L

vec1    = dat_0.MAGF
vec2    = dat_0.VSW

WSET,1
WSHOW,1
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,          $
                      DFRA=dfra,VCIRC=vcirc,PLANE=planes[0],EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],      $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0]

WSET,2
WSHOW,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,          $
                      DFRA=dfra,VCIRC=vcirc,PLANE=planes[1],EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],      $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,          $
                      DFRA=dfra,VCIRC=vcirc,PLANE=planes[2],EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],      $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0]

;-----------------------------------------------------
; => Save plots
;-----------------------------------------------------
ngrid   = 30L
sunv    = [1.,0.,0.]
sunn    = 'Sun Dir.'
xname   = 'B!Do!N'
yname   = 'V!Dsw!N'
planes  = ['xy','xz','yz']

; => Put circles every 5,000 km/s
vcirc   = 5d3*[1d0,2d0,3d0,4d0];,5d0]
ns      = 3L
smc     = 1
smct    = 1
dfmin   = 1d-18
inter   = 0
vlim    = 20e3
;vlim    = 40e3

dat_aa  = dat_e0
gnorm   = gnorm_0
normnm  = 'Shock Normal[0]'
;dat_aa  = dat_e1
;gnorm   = gnorm_1
;normnm  = 'Shock Normal[1]'
;dat_aa  = dat_e2
;gnorm   = gnorm_2
;normnm  = 'Shock Normal[2]'
neesa   = N_ELEMENTS(dat_aa)
fnm     = file_name_times(dat_aa.TIME,PREC=3)
ftimes  = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494

scu     = STRUPCASE(probe[0])
df_sfxa = STRCOMPRESS(STRING(dfmin[0],FORMAT='(E10.1)'),/REMOVE_ALL)
vlim_st = STRING(vlim[0],FORMAT='(I5.5)')
xyzvecs = ['(V.B)','(BxV)xB','(BxV)']
xyzvecf = ['Bo','BoxVswxBo','BoxVsw']
planes  = ['xy','xz','yz']
xy_suff = '_'+xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff = '_'+xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff = '_'+xyzvecf[2]+'_vs_'+xyzvecf[1]
midstr  = '_no-interp_Cuts-DF-Above_'

pref_a  = 'EESA_TH-'+scu[0]+'_'+ftimes+'_30Grids_'+vlim_st[0]+'km-s'
fnamexy = pref_a+xy_suff[0]+midstr[0]+df_sfxa
fnamexz = pref_a+xz_suff[0]+midstr[0]+df_sfxa
fnameyz = pref_a+yz_suff[0]+midstr[0]+df_sfxa
fnames  = [[fnamexy],[fnamexz],[fnameyz]]

FOR j=0L, neesa - 1L DO BEGIN                                                    $
  dat_0   = dat_aa[j]                                                          & $
  vec1    = dat_0.MAGF                                                         & $
  vec2    = dat_0.VSW                                                          & $
  FOR k=0L, 2L DO BEGIN                                                          $
    popen,fnames[j,k],/PORT                                                    & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,       $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,               $
                        DFRA=dfra,VCIRC=vcirc,PLANE=planes[k],EX_VEC1=sunv,      $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],           $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0]      & $
    pclose

;; # Bash commands
mv EESA_TH-B_*_Bo_vs_BoxVsw_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/EESA_Burst_DF/Plane_V1_vs_V1xV2/
mv EESA_TH-B_*_BoxVsw_vs_BoxVswxBo_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/EESA_Burst_DF/Plane_V1xV2_vs_V1xV2xV1/
mv EESA_TH-B_*_BoxVswxBo_vs_Bo_* ../TPLOT_THEMIS_PLOTS/esa_contours/2009-07-13/THEMIS_B/EESA_Burst_DF/Plane_V1xV2xV1_vs_V1/






;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;; => Convert into bulk flow frame and find new bulk flow velocities
;;----------------------------------------------------------------------------------------
vbulk_new = REPLICATE(d,n_i,3L)
FOR j=0L, n_i - 1L DO BEGIN $
  dat0 = dat_igse[j]                          & $
  transform_vframe_3d,dat0,/EASY_TRAN         & $
  vstr = fix_vbulk_ions(dat0)                 & $
  vnew = vstr.VSW_NEW                         & $
  vbulk_new[j,*] = vnew

tt0       = (dat_i.TIME + dat_i.END_TIME)/2d0
smvx      = vbulk_new[*,0]
smvy      = vbulk_new[*,1]
smvz      = vbulk_new[*,2]
test      = (ABS(smvx) GE 1d3) OR (ABS(smvy) GE 1d3) OR (ABS(smvz) GE 1d3)
bad       = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN smvx[bad] = d
IF (bd GT 0) THEN smvy[bad] = d
IF (bd GT 0) THEN smvz[bad] = d
IF (gd GT 0) THEN smvx      = interp(smvx[good],tt0[good],tt0,/NO_EXTRAP)
IF (gd GT 0) THEN smvy      = interp(smvy[good],tt0[good],tt0,/NO_EXTRAP)
IF (gd GT 0) THEN smvz      = interp(smvz[good],tt0[good],tt0,/NO_EXTRAP)

vsm       = 5L
smvx      = SMOOTH(smvx,vsm[0],/EDGE_TRUNCATE,/NAN)
smvy      = SMOOTH(smvy,vsm[0],/EDGE_TRUNCATE,/NAN)
smvz      = SMOOTH(smvz,vsm[0],/EDGE_TRUNCATE,/NAN)
smvel     = [[smvx],[smvy],[smvz]]

vnew_str  = {X:tt0,Y:smvel}
vname_n   = velname[0]+'_fixed'
yttl      = 'V!Dbulk!N [km/s, '+STRUPCASE(coord[0])+']'
ysubt     = '[Shifted to Peak in DF, 3s]'

store_data,vname_n[0],DATA=vnew_str
options,vname_n[0],'COLORS',[250,150, 50],/DEF
options,vname_n[0],'LABELS',['x','y','z'],/DEF
options,vname_n[0],'YTITLE',yttl[0],/DEF
options,vname_n[0],'YSUBTITLE',ysubt[0],/DEF

nnw       = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
options,nnw,'YTICKLEN',0.01


tr_11     = time_double(tdate[0]+'/'+['08:50:00','10:10:00'])
nna       = [pref[0]+'fgh_'+['mag',coord[0]],velname[0],vname_n[0]]
tplot,nna,TRANGE=tr_11

;; remove bad points in magnetosheath
kill_data_tr,NAMES=vname_n[0]








;;----------------------------------------------------------------------------------------
;; define new velocity for Rankine-Hugoniot solutions
;;   [see themis-b_2009-07-13_crib_bowshock_RH-Solns_plots.txt]
;;----------------------------------------------------------------------------------------
t_up      = time_double(tdate[0]+'/'+['09:00:08.700','09:01:38.800'])
t_dn      = time_double(tdate[0]+'/'+['08:57:35.000','08:59:00.000'])
get_data,vname_n[0],DATA=vbulk_str
vbulk     = vbulk_str.Y
v_t       = vbulk_str.X
badx      = WHERE(FINITE(vbulk[*,0]) EQ 0,bdx,COMPLEMENT=goodx,NCOMPLEMENT=gdx)
bady      = WHERE(FINITE(vbulk[*,1]) EQ 0,bdy,COMPLEMENT=goody,NCOMPLEMENT=gdy)
badz      = WHERE(FINITE(vbulk[*,2]) EQ 0,bdz,COMPLEMENT=goodz,NCOMPLEMENT=gdz)
IF (gdx GT 0) THEN vswx = interp(vbulk[goodx,0],v_t[goodx],v_t,/NO_EXTRAP) ELSE vswx = REPLICATE(d,n_i)
IF (gdy GT 0) THEN vswy = interp(vbulk[goody,1],v_t[goody],v_t,/NO_EXTRAP) ELSE vswy = REPLICATE(d,n_i)
IF (gdz GT 0) THEN vswz = interp(vbulk[goodz,2],v_t[goodz],v_t,/NO_EXTRAP) ELSE vswz = REPLICATE(d,n_i)

goodup_Vi = WHERE(v_t GE t_up[0] AND v_t LE t_up[1],gdupVi)
gooddn_Vi = WHERE(v_t GE t_dn[0] AND v_t LE t_dn[1],gddnVi)
PRINT,';', gdupVi, gddnVi
;          29          29

vswx_up   = vswx[goodup_Vi]
vswy_up   = vswy[goodup_Vi]
vswz_up   = vswz[goodup_Vi]

vswx_dn   = vswx[gooddn_Vi]
vswy_dn   = vswy[gooddn_Vi]
vswz_dn   = vswz[gooddn_Vi]

PRINT,';', vswx_up
PRINT,';', vswy_up
PRINT,';', vswz_up
;      -320.82899      -329.31008      -329.32112      -329.33138      -329.33052      -329.33460      -329.33687      -329.34234      -329.35161      -329.36254      -329.37261      -329.37844      -329.32725      -329.27605      -329.22486      -329.17367      -329.12248      -329.07129      -329.07096      -328.75797      -328.43982      -328.74635      -328.73999      -328.73264      -329.04316      -329.35040      -329.34451      -329.34597      -329.35919
;       57.639585       58.797191       58.799164       58.801070       58.800989       58.801785       58.802262       58.803310       58.804959       58.806909       58.808708       58.809747       54.535780       50.261812       45.987845       41.713877       37.439910       33.165942       33.165882       7.5228728      -18.119787       7.5239078       7.5227732       7.5214640       33.164033       58.804744       58.803696       58.803957       58.806315
;       25.651326       26.294485       26.295354       26.296157       26.296070       26.296376       26.296544       26.296963       26.297682       26.298536       26.299323       26.299772       26.055474       25.811176       25.566877       25.322579       25.078281       24.833983       24.833941       23.367873       21.901465       23.367097       23.366576       23.365969       24.831807       26.297310       26.296821       26.296926       26.297969

PRINT,';', vswx_dn
PRINT,';', vswy_dn
PRINT,';', vswz_dn
;      -44.650947      -46.491606      -59.388951      -50.616866      -51.676682      -51.000787      -47.568337      -30.487679      -27.704227      -26.622642      -28.035446      -25.539669      -36.242518      -27.439843      -30.354413      -30.637748      -35.006063      -26.531462      -58.190300      -52.906059      -53.671140      -66.500486      -81.354571      -68.593182      -81.906454      -100.95397      -99.632686      -84.947185      -92.611346
;       3.4180840       3.8689363       13.679326       4.0730874       16.284395       22.603145       25.213298       16.804887       26.167883       13.981644       7.2178755       10.794942       15.880573       16.304070       25.060337       32.014073       21.924772       14.963302       28.341341       32.607451       28.957298       44.493452       54.778984       47.924732       65.448506       85.303958       85.902050       64.425482       69.761957
;      -8.3478504      -8.9548649      -17.017722      -1.7720715      -12.506955      -22.230618      -21.232881      -19.417307      -25.374246      -14.655825      -8.3610180      -12.933943      -21.813721      -24.035431      -30.766572      -33.963792      -30.018278      -21.538887      -9.7196706      -12.070784      -8.8150368      -2.6501244      -4.0659275      -13.461803      -3.2278752      0.35607327      -9.7417412       1.1866107      -1.4163832


; => Upstream values
dens_up  = [10.492314,9.6057987,9.4848032,9.6199398,9.2339535,8.6731071,8.7769480,8.7919569,8.4657831,8.7491970,7.9786835,7.9909315,7.8905368,7.9880352,7.9813509,7.9611845,7.8424263,8.0624046,8.0674877,7.7535858,8.1734800,8.1494284,8.5141010,8.4393463,8.3660755,8.5864878,9.1271343,10.491794,9.3186817]
ti_avgu  = [325.91592,320.36951,312.16245,314.90503,286.88147,346.91653,327.72598,322.68387,305.82150,301.62271,309.02533,298.84399,271.75247,233.62141,231.43066,250.44740,257.12958,247.18892,257.91678,270.90842,273.82373,287.68024,285.42651,279.09427,268.98788,240.55653,227.58278,218.83661,237.16356]
te_avgu  = [13.419991,13.863358,13.106758,13.336205,12.009370,12.239438,12.080978,11.955414,11.705899,11.211782,10.994113,10.554955,10.480340,10.783696,10.806020,10.523615,10.393574,10.187079,10.405693,10.176997,10.471030,10.561646,10.689648,10.669145,10.496284,10.878242,11.117191,10.504341,10.257567]
vsw_x_up = [-320.82899d0,-329.31008d0,-329.32112d0,-329.33138d0,-329.33052d0,-329.33460d0,-329.33687d0,-329.34234d0,-329.35161d0,-329.36254d0,-329.37261d0,-329.37844d0,-329.32725d0,-329.27605d0,-329.22486d0,-329.17367d0,-329.12248d0,-329.07129d0,-329.07096d0,-328.75797d0,-328.43982d0,-328.74635d0,-328.73999d0,-328.73264d0,-329.04316d0,-329.35040d0,-329.34451d0,-329.34597d0,-329.35919d0]
vsw_y_up = [  57.639585d0,58.797191d0,58.799164d0,58.801070d0,58.800989d0,58.801785d0,58.802262d0,58.803310d0,58.804959d0,58.806909d0,58.808708d0,58.809747d0,54.535780d0,50.261812d0,45.987845d0,41.713877d0,37.439910d0,33.165942d0,33.165882d0,7.5228728d0,-18.119787d0,7.5239078d0,7.5227732d0,7.5214640d0,33.164033d0,58.804744d0,58.803696d0,58.803957d0,58.806315d0]
vsw_z_up = [  25.651326d0,26.294485d0,26.295354d0,26.296157d0,26.296070d0,26.296376d0,26.296544d0,26.296963d0,26.297682d0,26.298536d0,26.299323d0,26.299772d0,26.055474d0,25.811176d0,25.566877d0,25.322579d0,25.078281d0,24.833983d0,24.833941d0,23.367873d0,21.901465d0,23.367097d0,23.366576d0,23.365969d0,24.831807d0,26.297310d0,26.296821d0,26.296926d0,26.297969d0]
vsw_up   = FLOAT([[vsw_x_up],[vsw_y_up],[vsw_z_up]])
mag_x_up = [-2.7192060,-2.6376725,-2.5702988,-2.6122175,-2.6400749,-2.7351387,-2.8183972,-2.8607154,-2.8569902,-2.8982759,-2.8591297,-2.7951906,-2.8362705,-2.8673473,-2.9045445,-2.9343462,-2.9633883,-2.9528928,-2.9624804,-3.0070106,-2.9752134,-3.0340722,-3.0465501,-2.9671180,-2.9246921,-3.0090747,-3.0474292,-3.1893663,-3.1646801]
mag_y_up = [ 2.7671735, 2.6188984, 2.5163856, 2.4362860, 2.2564358, 2.2115386, 2.2104804, 2.1529355, 2.0273837, 1.8847899, 1.8351192, 1.9359179, 1.9476682, 1.8638392, 1.7336992, 1.6462637, 1.4978774, 1.3967050, 1.3196643, 1.2559367, 1.3341023, 1.3724965, 1.3811557, 1.3744155, 1.4782682, 1.4131823, 1.4019568, 1.3458211, 1.3065934]
mag_z_up = [-1.3305667,-1.2441086,-1.2338506,-1.3351701,-1.4759293,-1.3427092,-1.2674976,-1.2604535,-1.2483755,-1.2147603,-1.2646037,-1.3124555,-1.3703716,-1.4483315,-1.5009355,-1.4908366,-1.5134633,-1.5278235,-1.4219461,-1.4350906,-1.4860166,-1.4945576,-1.4829331,-1.5328459,-1.4284302,-1.3508222,-1.4287311,-1.2851691,-1.2842954]
magf_up  = [[mag_x_up],[mag_y_up],[mag_z_up]]
;;  ** Don't trust the upstream ion temperature b/c DFs are dominated by gyrating ions **
temp_up  = 2*te_avgu
PRINT,';', MEAN(dens_up,/NAN),  MEAN(te_avgu,/NAN),  MEAN(te_avgu,/NAN)
PRINT,';', MEAN(vsw_up[*,0],/NAN), MEAN(vsw_up[*,1],/NAN), MEAN(vsw_up[*,2],/NAN)
PRINT,';', MEAN(mag_x_up,/NAN), MEAN(mag_y_up,/NAN), MEAN(mag_z_up,/NAN)
;      8.64058      11.2373      11.2373
;     -328.887      44.1759      25.4417
;     -2.88930      1.79045     -1.37976


; => Downstream values
dens_dn  = [ 52.572590, 49.544201, 53.476055, 53.381714, 52.855297, 49.557495, 49.088287, 47.304909, 44.780872, 45.153786, 46.521297, 47.797813, 46.300930, 47.967556, 45.199181, 46.862720, 45.899021, 50.133743, 47.308235, 49.807289, 49.679493, 47.188217, 47.125824, 46.934185, 44.569477, 47.994122, 47.762924, 46.972439, 41.862568]
ti_avgd  = [133.40675, 144.66283, 136.78729, 137.93518, 138.11736, 147.69276, 141.22292, 149.32677, 153.58955, 153.86572, 159.97891, 153.03134, 155.32594, 158.63811, 164.98531, 160.27780, 165.74371, 159.15602, 169.79881, 163.35986, 165.10753, 160.45644, 165.71205, 166.13878, 161.94643, 167.75491, 171.83630, 168.35246, 188.84258]
te_avgd  = [ 35.406406, 34.393063, 33.861195, 33.000744, 32.686584, 32.196697, 31.433306, 31.007446, 29.682556, 29.368334, 29.072641, 28.929550, 28.681007, 29.549097, 29.599649, 30.301203, 29.394709, 29.820700, 30.366074, 30.013323, 28.911736, 29.536995, 29.632919, 29.459883, 28.830835, 29.714483, 31.672815, 29.366831, 28.629313]
vsw_x_dn = [ -44.650947d0,-46.491606d0,-59.388951d0,-50.616866d0,-51.676682d0,-51.000787d0,-47.568337d0,-30.487679d0,-27.704227d0,-26.622642d0,-28.035446d0,-25.539669d0,-36.242518d0,-27.439843d0,-30.354413d0,-30.637748d0,-35.006063d0,-26.531462d0,-58.190300d0,-52.906059d0,-53.671140d0,-66.500486d0,-81.354571d0,-68.593182d0,-81.906454d0,-100.95397d0,-99.632686d0,-84.947185d0,-92.611346d0]
vsw_y_dn = [   3.4180840d0,3.8689363d0,13.679326d0,4.0730874d0,16.284395d0,22.603145d0,25.213298d0,16.804887d0,26.167883d0,13.981644d0,7.2178755d0,10.794942d0,15.880573d0,16.304070d0,25.060337d0,32.014073d0,21.924772d0,14.963302d0,28.341341d0,32.607451d0,28.957298d0,44.493452d0,54.778984d0,47.924732d0,65.448506d0,85.303958d0,85.902050d0,64.425482d0,69.761957d0]
vsw_z_dn = [  -8.3478504d0,-8.9548649d0,-17.017722d0,-1.7720715d0,-12.506955d0,-22.230618d0,-21.232881d0,-19.417307d0,-25.374246d0,-14.655825d0,-8.3610180d0,-12.933943d0,-21.813721d0,-24.035431d0,-30.766572d0,-33.963792d0,-30.018278d0,-21.538887d0,-9.7196706d0,-12.070784d0,-8.8150368d0,-2.6501244d0,-4.0659275d0,-13.461803d0,-3.2278752d0,0.35607327d0,-9.7417412d0,1.1866107d0,-1.4163832d0]
vsw_dn   = FLOAT([[vsw_x_dn],[vsw_y_dn],[vsw_z_dn]])
mag_x_dn = [-2.8525374,-4.3879070,-5.2507427,-5.7155547,-5.0950556,-5.0701934,-3.5066737,-2.0339705,-0.55957812,-1.0386611,-1.6948897,-2.3018063,-3.0439483,-3.7818925,-3.7942682,-3.0214442,-2.5547477,-1.6815118,-1.5683706,-1.8819460,-2.5338890,-3.1938584,-4.3861152,-3.6844606,-3.0118556,-6.6655889,-8.2971833,-10.294554,-8.9420468]
mag_y_dn = [ 9.1088986, 8.9860832, 9.7564074, 10.975603, 12.065201, 11.915290, 11.236278, 11.048807, 10.507234, 10.808046, 10.638352, 11.700957, 11.940225, 12.291933, 11.432767, 10.680565, 9.7978622, 8.8189577, 9.0566689, 10.492625, 12.326349, 12.654887, 10.501751, 10.019947, 10.378610, 11.516831, 10.790333, 11.526929, 10.747037]
mag_z_dn = [-11.789103,-10.946490,-10.221192,-8.8420235,-8.1617246,-8.5990727,-9.5687483,-10.367598,-10.032216,-10.881957,-12.206065,-14.241420,-13.340018,-11.649970,-9.9184042,-11.209746,-11.660910,-9.9031451,-6.0482782,-1.2043294,-1.5950029,-2.8608864,-5.0263366,-5.0150090,-6.2197600,-5.0383142,-6.3336373,-9.4235157,-10.795819]
magf_dn  = [[mag_x_dn],[mag_y_dn],[mag_z_dn]]
temp_dn  = te_avgd + ti_avgd
PRINT,';', MEAN(dens_dn,/NAN),  MEAN(ti_avgd,/NAN),  MEAN(te_avgd,/NAN)
PRINT,';', MEAN(vsw_dn[*,0],/NAN), MEAN(vsw_dn[*,1],/NAN), MEAN(vsw_dn[*,2],/NAN)
PRINT,';', MEAN(mag_x_dn,/NAN), MEAN(mag_y_dn,/NAN), MEAN(mag_z_dn,/NAN)
;      47.9863      157.347      30.5007
;     -52.3194      30.9724     -13.7437
;     -3.85673      10.8180     -8.72761

; => combine terms
vsw      = [[[vsw_up]],[[vsw_dn]]]
mag      = [[[magf_up]],[[magf_dn]]]
dens     = [[dens_up],[dens_dn]]
temp     = [[temp_up],[temp_dn]]

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/rh_pros/temp_rh_soln_print.pro
temp_rh_soln_print,dens,vsw,mag,temp,tdate[0]
;; => Print out best fit poloidal angles
PRINT,';', soln.THETA*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-13 bow shock
;;===========================================================
;;       1.0909091       7.0813994
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-13 bow shock
;;===========================================================
;;      0.53719008       7.1617274
;;-----------------------------------------------------------

;; => Print out best fit azimuthal angles
PRINT,';', soln.PHI*18d1/!DPI
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-13 bow shock
;;===========================================================
;;      -2.6737968       4.7289179
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-13 bow shock
;;===========================================================
;;      -3.0909091       4.9035943
;;-----------------------------------------------------------

;; => Print out best fit shock normal speed in spacecraft frame [km/s]
PRINT,';', soln.VSHN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-13 bow shock
;;===========================================================
;;       6.5757381       27.115276
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-13 bow shock
;;===========================================================
;;       6.5830201       27.368172
;;-----------------------------------------------------------

;; => Print out best fit upstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_UP
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-13 bow shock
;;===========================================================
;;      -333.11548       28.097287
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-13 bow shock
;;===========================================================
;;      -333.46002       28.388274
;;-----------------------------------------------------------

;; => Print out best fit downstream shock normal speed in shock frame [km/s]
PRINT,';', soln.USHN_DN
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-13 bow shock
;;===========================================================
;;      -59.964814       6.2173595
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-13 bow shock
;;===========================================================
;;      -60.026496       6.2586121
;;-----------------------------------------------------------

;; => Print out best fit shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,0]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-13 bow shock
;;===========================================================
;;      0.98812888    -0.046169253     0.018973733
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-13 bow shock
;;===========================================================
;;      0.98744623    -0.053346692    0.0093557489
;;-----------------------------------------------------------

;; => Print out best fit uncertainty in shock normal vector [GSE coordinates]
PRINT,';', soln.SH_NORM[*,1]
;;-----------------------------------------------------------
;;         Avg.          Std. Dev.
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, and 5 for 2009-07-13 bow shock
;;===========================================================
;;    0.0059766883     0.079301828      0.12167072
;;-----------------------------------------------------------
;;  => Equations 2, 3, 4, 5, and 6 for 2009-07-13 bow shock
;;===========================================================
;;    0.0065514366     0.082574711      0.12316928
;;-----------------------------------------------------------

avg_dens_up  = 8.64058d0
avg_Te_up    = 11.2373d0
gnorm        = [0.98744623d0,-0.053346692d0,0.0093557489d0]
avg_magf_up  = [-2.88930d0,1.79045d0,-1.37976d0]
avg_vswi_up  = [-328.887d0,44.1759d0,25.4417d0]
bmag_up      = NORM(avg_magf_up)
vmag_up      = NORM(avg_vswi_up)
avg_magf_dn  = [-3.85673d0,10.8180d0,-8.72761d0]
avg_vswi_dn  = [-52.3194d0,30.9724d0,-13.7437d0]
bmag_dn      = NORM(avg_magf_dn)
vmag_dn      = NORM(avg_vswi_dn)

vshn_up      =    6.5830201d0
ushn_up      = -333.46002d0
b_dot_n      = my_dot_prod(gnorm,avg_magf_up,/NOM)/(bmag_up[0]*NORM(gnorm))
theta_Bn     = ACOS(b_dot_n[0])*18d1/!DPI
theta_Bn     = theta_Bn[0] < (18d1 - theta_Bn[0])
nkT_up       = (avg_dens_up[0]*1d6)*(kB[0]*K_eV[0]*(avg_Te_up[0] + avg_Te_up[0]))  ;; plasma pressure [J m^(-3)]
sound_up     = SQRT(5d0*nkT_up[0]/(3d0*(avg_dens_up[0]*1d6)*mp[0]))                ;; sound speed [m/s]
alfven_up    = (bmag_up[0]*1d-9)/SQRT(muo[0]*(avg_dens_up[0]*1d6)*mp[0])           ;; Alfven speed [m/s]
Vs_p_Va_2    = (sound_up[0]^2 + alfven_up[0]^2)
b2_4ac       = Vs_p_Va_2[0]^2 + 4d0*sound_up[0]^2*alfven_up[0]^2*SIN(theta_Bn[0]*!DPI/18d1)^2
fast_up      = SQRT((Vs_p_Va_2[0] + SQRT(b2_4ac[0]))/2d0)
;  Mach numbers
Ma_up        = ABS(ushn_up[0]*1d3/alfven_up[0])
Ms_up        = ABS(ushn_up[0]*1d3/sound_up[0])
Mf_up        = ABS(ushn_up[0]*1d3/fast_up[0])
PRINT,';', theta_Bn[0], Ma_up[0], Ms_up[0], Mf_up[0], bmag_dn[0]/bmag_up[0], vmag_up[0]/vmag_dn[0]
;       35.282616       12.250019       5.5669472       4.9571628       3.9321254       5.3392319

;-----------------------------------------------------
; => Calculate gyrospeeds of specular reflection
;-----------------------------------------------------
; => calculate unit vectors
bhat         = avg_magf_up/bmag_up[0]
vhat         = avg_vswi_up/vmag_up[0]
; => calculate upstream inflow velocity
v_up         = avg_vswi_up - gnorm*vshn_up[0]
; => Eq. 2 from Gosling et al., [1982]
;      [specularly reflected ion velocity]
Vref_s       = v_up - gnorm*(2d0*my_dot_prod(v_up,gnorm,/NOM))
; => Eq. 4 and 3 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion]
Vper_r       = v_up - bhat*my_dot_prod(v_up,bhat,/NOM)  ; => Eq. 4
Vgc_r        = Vper_r + bhat*(my_dot_prod(Vref_s,bhat,/NOM))
; => Eq. 6 from Gosling et al., [1982]
;      [gyro-velocity of a specularly reflected ion]
Vgy_r        = Vref_s - Vgc_r
; => Eq. 7 and 9 from Gosling et al., [1982]
;      [guiding center velocity of a specularly reflected ion perp. to shock surface]
Vgcn_r       = my_dot_prod(Vgc_r,gnorm,/NOM)
;      [guiding center velocity of a specularly reflected ion para. to B-field]
Vgcb_r       = my_dot_prod(Vgc_r,bhat,/NOM)
; => gyrospeed and guiding center speed
Vgy_rs       = NORM(REFORM(Vgy_r))
Vgc_rs       = NORM(REFORM(Vgc_r))

PRINT,';', Vgy_rs[0], Vgc_rs[0]
PRINT,';', Vgcn_r[0], Vgcb_r[0]
;       380.78971       327.55811
;       101.12483      -261.81441





;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------













dat_i0    = dat_i[0]
HELP,dat_i0,/STRUCTURES,OUTPUT=out
FOR j=0L, N_ELEMENTS(out) - 1L DO PRINT,';;  ',out[j]
;;----------------------------------------------------------------------------------------
;;  ** Structure <1865408>, 38 tags, length=152272, data length=152247, refs=3:
;;     PROJECT_NAME    STRING    'THEMIS'
;;     SPACECRAFT      STRING    'b'
;;     DATA_NAME       STRING    'IESA 3D burst'
;;     APID            INT            456
;;     UNITS_NAME      STRING    'counts'
;;     UNITS_PROCEDURE STRING    'thm_convert_esa_units'
;;     VALID           BYTE         1
;;     TIME            DOUBLE       1.2474697e+09
;;     END_TIME        DOUBLE       1.2474697e+09
;;     DELTA_T         DOUBLE           2.9679589
;;     INTEG_T         DOUBLE        0.0028983974
;;     DT_ARR          FLOAT     Array[32, 88]
;;     CONFIG1         BYTE         2
;;     CONFIG2         BYTE         1
;;     AN_IND          INT              1
;;     EN_IND          INT              1
;;     MODE            INT              2
;;     NENERGY         INT             32
;;     ENERGY          FLOAT     Array[32, 88]
;;     DENERGY         FLOAT     Array[32, 88]
;;     EFF             DOUBLE    Array[32, 88]
;;     BINS            INT       Array[32, 88]
;;     NBINS           INT             88
;;     THETA           FLOAT     Array[32, 88]
;;     DTHETA          FLOAT     Array[32, 88]
;;     PHI             FLOAT     Array[32, 88]
;;     DPHI            FLOAT     Array[32, 88]
;;     DOMEGA          FLOAT     Array[32, 88]
;;     GF              FLOAT     Array[32, 88]
;;     GEOM_FACTOR     FLOAT        0.00153000
;;     DEAD            FLOAT       1.70000e-07
;;     MASS            FLOAT         0.0104389
;;     CHARGE          FLOAT           1.00000
;;     SC_POT          FLOAT           0.00000
;;     MAGF            FLOAT     Array[3]
;;     BKG             FLOAT     Array[32, 88]
;;     DATA            FLOAT     Array[32, 88]
;;     VELOCITY        DOUBLE    Array[3]
;;----------------------------------------------------------------------------------------



;;----------------------------------------------------------------------------------------
;;  Create timestamps for each energy-angle bin
;;----------------------------------------------------------------------------------------


sc        = probe[0]
pref      = 'th'+sc[0]+'_'
get_data,pref[0]+'state_spinper',DATA=sp_per
sp_t      = sp_per.X
sp_p      = sp_per.Y          ;; Spacecraft spin period [s]


dat       = dat_e[0]
n_e       = dat.NENERGY       ;; => # of energy bins
n_a       = dat.NBINS         ;; => # of angle bins

phi       = dat.PHI           ;; [E,A]-Element Array of azimuthal angles [deg, DSL]
;; => Accumulation time [s] of each angle bin
tacc      = dat[0].INTEG_T[0]*dat[0].DT_ARR
t0        = dat.TIME[0]       ;; => Unix time at start of ESA sample period
t1        = dat.END_TIME[0]   ;; => Unix time at end of ESA sample period
del_t     = t1[0] - t0[0]     ;; => Total time of data sample
;; => Create array of dummy time stamps
dumbt     = DINDGEN(n_e,n_a)*del_t[0]/(n_e[0]*n_a[0] - 1L) + t0[0]
;; => Calculate spin period [s/rotation] at ESA structure time
spp0      = interp(sp_p,sp_t,dumbt,/NO_EXTRAP)
;; => Calculate spin rate [deg s^(-1)] at ESA structure time
sprate    = 36d1/spp0

phi_00    = phi[0,0]          ;; => 1st DSL azimuthal angle sampled
;; => Shift the rest of the angles so that phi_00 = 0d0
sh_phi    = phi - phi_00[0]
;; => Adjust negative values so they are > 360
shphi36   = sh_phi
low_phi   = WHERE(sh_phi LT 0,glw)
IF (glw GT 0) THEN shphi36[low_phi] += 36d1
;; => Define time diff. [s] from middle of first data point
d_t_phi   = shphi36/sprate
;; => These times are actually 1/2 an accumulation time from the true start time of each bin
d_t_trp   = d_t_phi + tacc/2d0
;; => Define the associated time stamps for each angle bin
ti_angs   = t0[0] + d_t_trp


dat       = dat_e[0]
name      = pref[0]+'state_spinper'
.compile timestamp_esa_angle_bins
ti_angs2  = timestamp_esa_angle_bins(dat,name[0])
diff      = ti_angs2 - ti_angs
PRINT,';; ',minmax(diff)
;;        0.0000000       0.0000000


dat_e2    = dat_e
modify_themis_esa_struc,dat_e2
;; add SC potential to structures
sc        = probe[0]
pref      = 'th'+sc[0]+'_'
scname    = tnames(pref[0]+'pe*b_sc_pot')
add_scpot,dat_e2,scname[0]
;; => Rotate IESA (theta,phi)-angles DSL --> GSE
coord     = 'gse'
sc        = probe[0]
vel_name  = pref[0]+'peib_velocity_'+coord[0]
mag_name  = pref[0]+'fgh_'+coord[0]
rotate_esa_thetaphi_to_gse,dat_e2,MAGF_NAME=mag_name,VEL_NAME=vel_name


dat       = dat_e2[0]
name      = pref[0]+'state_spinper'
.compile timestamp_esa_angle_bins
ti_angs3  = timestamp_esa_angle_bins(dat,name[0])

diff      = ti_angs3 - ti_angs2
PRINT,';; ',minmax(diff)
;;       -2.8897061       2.9633517



