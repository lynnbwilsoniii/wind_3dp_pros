;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
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

wpefac         = SQRT(1d6*qq[0]^2/(epo[0]*me[0]))
wpifac         = SQRT(1d6*qq[0]^2/(epo[0]*mp[0]))
wcefac         = qq[0]*1d-9/me[0]
wcifac         = qq[0]*1d-9/mp[0]
VTefac         = SQRT(2d0*J_1eV[0]/me[0])
VTifac         = SQRT(2d0*J_1eV[0]/mp[0])
ckm            = c[0]*1d-3            ;;  m --> km
;;  Setup margins
!X.MARGIN      = [15,5]
!Y.MARGIN      = [8,4]
;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

;;  NEW Average Shock Terms [1st Crossing]
vshn_up        =    -53.49635000d0
dvshnup        =      1.66223732d0
ushn_up        =   -275.05217133d0
dushnup        =      1.22384042d0
ushn_dn        =    -41.70433879d0
dushndn        =      1.64706296d0
gnorm          = [     0.99533337d0,     0.02216223d0,    -0.09391658d0]
magf_up        = [    -3.04437196d0,     1.33834842d0,    -1.48370236d0]
magf_dn        = [    -6.20271850d0,     9.76619744d0,   -12.12637782d0]
theta_Bn       =     38.21430845d0

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_b_data_2009-07-13_batch.pro

WINDOW,1,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,2,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,3,RETAIN=2,XSIZE=800,YSIZE=1100
;;  Define mask and "UV" speeds
v_thresh       = [35e1,35e1,35e1,35e1,35e1]
v_uv           = 50e1
i_time0        = dat_igse.TIME
i_time1        = dat_igse.END_TIME
tr_bi0         = time_double(tdate[0]+'/'+['08:59:42','09:02:41'])
tr_bi1         = time_double(tdate[0]+'/'+['09:18:03','09:18:31'])
tr_bi2         = time_double(tdate[0]+'/'+['09:19:23','09:19:39'])
tr_bi3         = time_double(tdate[0]+'/'+['09:23:50','09:24:18'])
tr_bi4         = time_double(tdate[0]+'/'+['09:24:47','09:40:31'])
bad00          = WHERE(i_time0 GE tr_bi0[0] AND i_time1 LE tr_bi0[1],bd0)
bad01          = WHERE(i_time0 GE tr_bi1[0] AND i_time1 LE tr_bi1[1],bd1)
bad02          = WHERE(i_time0 GE tr_bi2[0] AND i_time1 LE tr_bi2[1],bd2)
bad03          = WHERE(i_time0 GE tr_bi3[0] AND i_time1 LE tr_bi3[1],bd3)
bad04          = WHERE(i_time0 GE tr_bi4[0] AND i_time1 LE tr_bi4[1],bd4)
;;----------------------------------------------------------------------------------------
;;  Clean up
;;----------------------------------------------------------------------------------------
store_data,DELETE=tnames(pref[0]+'efw*')
store_data,DELETE=tnames(pref[0]+'efp*')
store_data,DELETE=tnames(pref[0]+'scw*')
store_data,DELETE=tnames(pref[0]+'scp*')

;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
testbad        = [N_ELEMENTS(bad00),N_ELEMENTS(bad01),N_ELEMENTS(bad02),$
                  N_ELEMENTS(bad03),N_ELEMENTS(bad04),N_ELEMENTS(bad05),$
                  N_ELEMENTS(bad06),N_ELEMENTS(bad07),N_ELEMENTS(bad08),$
                  N_ELEMENTS(bad09),N_ELEMENTS(bad10),N_ELEMENTS(bad11),$
                  N_ELEMENTS(bad12),N_ELEMENTS(bad13),N_ELEMENTS(bad14),$
                  N_ELEMENTS(bad15),N_ELEMENTS(bad16),N_ELEMENTS(bad17),$
                  N_ELEMENTS(bad18),N_ELEMENTS(bad19),N_ELEMENTS(bad20),$
                  N_ELEMENTS(bad21),N_ELEMENTS(bad22),N_ELEMENTS(bad23),$
                  N_ELEMENTS(bad24),N_ELEMENTS(bad25),N_ELEMENTS(bad26),$
                  N_ELEMENTS(bad27),N_ELEMENTS(bad28),N_ELEMENTS(bad29)] GT 0
nm             = LONG(TOTAL(testbad))
vth_strs       = STRING(v_thresh,FORMAT='(I3.3)')
ex_str_pref    = 'str_element,all_bad_els,'

FOR j=0L, nm[0] - 1L DO BEGIN                                                            $
  jbstr                 = STRING(j[0],FORMAT='(I2.2)')                                 & $
  jstr                  = 'VTH_'+jbstr[0]+'_'+vth_strs[j]                              & $
  ex_string    = ex_str_pref[0]+"'"+jstr[0]+"',bad"+jbstr[0]+',/ADD_REPLACE'           & $
  result       = EXECUTE(ex_string[0])

;;  Make sure it worked
HELP,all_bad_els,/STRUC
;;----------------------------------------------------------------------------------------
;;  Define masks
;;----------------------------------------------------------------------------------------
dat_copy       = dat_igse

FOR j=0L, nm[0] - 1L DO BEGIN                                                  $
  bind    = all_bad_els.(j)                                                  & $
  jbstr   = STRING(j[0],FORMAT='(I2.2)')                                     & $
  jstr    = 'VTH_'+jbstr[0]+'_'+vth_strs[j]                                  & $
  v_th    = v_thresh[j]                                                      & $
  dat     = dat_copy[bind]                                                   & $
  mask0   = remove_uv_and_beam_ions(dat,V_THRESH=v_th[0],V_UV=v_uv[0])       & $
  str_element,all_masks,jstr[0],mask0,/ADD_REPLACE                           & $
  masked  = dat.DATA*mask0                                                   & $
  submask = dat.DATA - masked                                                & $
  str_element,masked_data,jstr[0],masked,/ADD_REPLACE                        & $
  str_element,subtra_mask,jstr[0],submask,/ADD_REPLACE

;;  Make sure it worked
HELP,all_masks,masked_data,subtra_mask,/STRUC
;;----------------------------------------------------------------------------------------
;;  Apply masks
;;----------------------------------------------------------------------------------------
dumm_m         = dat_igse        ;;  core solar wind beam only
dumm_s         = dat_igse        ;;  without " "

FOR j=0L, nm[0] - 1L DO BEGIN                                          $
  bind    = all_bad_els.(j)                                          & $
  masked  = masked_data.(j)                                          & $
  submask = subtra_mask.(j)                                          & $
  dumm_m[bind].DATA = masked                                         & $
  dumm_s[bind].DATA = submask
;;----------------------------------------------------------------------------------------
;;  Calculate moments [both core and "residue"]
;;----------------------------------------------------------------------------------------
sform          = moments_3d_new()
n_i            = N_ELEMENTS(dumm_m)
str_element,sform,'END_TIME',0d0,/ADD_REPLACE
momb_e         = REPLICATE(sform[0],n_i[0])   ;;  Moments for entire velocity distribution
momb_m         = REPLICATE(sform[0],n_i[0])   ;;  " " core solar wind beam only
momb_s         = REPLICATE(sform[0],n_i[0])   ;;  " " everything except core solar wind beam
true_vbulk     = REFORM(dumm_s.VSW)
true_magf      = REFORM(dumm_s.MAGF)
true_scpot     = REFORM(dumm_s.SC_POT[0])
FOR j=0L, n_i - 1L DO BEGIN                                                        $
  tmome   = 0                                                                    & $
  tmomm   = 0                                                                    & $
  tmoms   = 0                                                                    & $
  dele    = dat_igse[j]                                                          & $
  delm    = dumm_m[j]                                                            & $
  dels    = dumm_s[j]                                                            & $
  pot     = true_scpot[j]                                                        & $
  tmagf   = REFORM(true_magf[*,j])                                               & $
  tvsw    = REFORM(true_vbulk[*,j])                                              & $
  ex_str  = {FORMAT:sform,DOMEGA_WEIGHTS:1,TRUE_VBULK:tvsw,MAGDIR:tmagf}         & $
  tmome   = moments_3d_new(dele,SC_POT=pot[0],_EXTRA=ex_str)                     & $
  tmomm   = moments_3d_new(delm,SC_POT=pot[0],_EXTRA=ex_str)                     & $
  tmoms   = moments_3d_new(dels,SC_POT=pot[0],_EXTRA=ex_str)                     & $
  str_element,tmome,'END_TIME',dele[0].END_TIME,/ADD_REPLACE                     & $
  str_element,tmomm,'END_TIME',delm[0].END_TIME,/ADD_REPLACE                     & $
  str_element,tmoms,'END_TIME',dels[0].END_TIME,/ADD_REPLACE                     & $
  momb_e[j] = tmome[0]                                                           & $
  momb_m[j] = tmomm[0]                                                           & $
  momb_s[j] = tmoms[0]

;times          = (momb_m.TIME + momb_m.END_TIME)/2d0
times          = momb_m.TIME
p_els          = [0L,4L,8L]                   ;;  Diagonal elements of a 3x3 matrix
;;----------------------------------------------------------------------------------------
;;  Define relevant quantities
;;----------------------------------------------------------------------------------------
;;  Moments for entire velocity distribution
avgtemp_e      = REFORM(momb_e.AVGTEMP)       ;;  Avg. Particle Temp (eV)
v_therm_e      = REFORM(momb_e.VTHERMAL)      ;;  Avg. Particle Thermal Speed (km/s)
tempvec_e      = TRANSPOSE(momb_e.MAGT3)      ;;  Vector Temp [perp1,perp2,para] (eV)
velocity_e     = TRANSPOSE(momb_e.VELOCITY)   ;;  Velocity vectors (km/s)
p_tensor_e     = TRANSPOSE(momb_e.PTENS)      ;;  Pressure tensor [eV cm^(-3)]
density_e      = REFORM(momb_e.DENSITY)       ;;  Particle density [# cm^(-3)]

t_perp_e       = 5e-1*(tempvec_e[*,0] + tempvec_e[*,1])
t_para_e       = REFORM(tempvec_e[*,2])
tanis_e        = t_perp_e/t_para_e
pressure_e     = TOTAL(p_tensor_e[*,p_els],2,/NAN)/3.

;;  Moments for core solar wind beam only
avgtemp_m      = REFORM(momb_m.AVGTEMP)       ;;  Avg. Particle Temp (eV)
v_therm_m      = REFORM(momb_m.VTHERMAL)      ;;  Avg. Particle Thermal Speed (km/s)
tempvec_m      = TRANSPOSE(momb_m.MAGT3)      ;;  Vector Temp [perp1,perp2,para] (eV)
velocity_m     = TRANSPOSE(momb_m.VELOCITY)   ;;  Velocity vectors (km/s)
p_tensor_m     = TRANSPOSE(momb_m.PTENS)      ;;  Pressure tensor [eV cm^(-3)]
density_m      = REFORM(momb_m.DENSITY)       ;;  Particle density [# cm^(-3)]

t_perp_m       = 5e-1*(tempvec_m[*,0] + tempvec_m[*,1])
t_para_m       = REFORM(tempvec_m[*,2])
tanis_m        = t_perp_m/t_para_m
pressure_m     = TOTAL(p_tensor_m[*,p_els],2,/NAN)/3.

;;  Moments for everything except core solar wind beam
avgtemp_s      = REFORM(momb_s.AVGTEMP)       ;;  Avg. Particle Temp (eV)
v_therm_s      = REFORM(momb_s.VTHERMAL)      ;;  Avg. Particle Thermal Speed (km/s)
tempvec_s      = TRANSPOSE(momb_s.MAGT3)      ;;  Vector Temp [perp1,perp2,para] (eV)
velocity_s     = TRANSPOSE(momb_s.VELOCITY)   ;;  Velocity vectors (km/s)
p_tensor_s     = TRANSPOSE(momb_s.PTENS)      ;;  Pressure tensor [eV cm^(-3)]
density_s      = REFORM(momb_s.DENSITY)       ;;  Particle density [# cm^(-3)]

t_perp_s       = 5e-1*(tempvec_s[*,0] + tempvec_s[*,1])
t_para_s       = REFORM(tempvec_s[*,2])
tanis_s        = t_perp_s/t_para_s
pressure_s     = TOTAL(p_tensor_s[*,p_els],2,/NAN)/3.
;;----------------------------------------------------------------------------------------
;;  Define spacecraft GSE positions at start/end times of vDFs
;;----------------------------------------------------------------------------------------
coord          = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
magname        = pref[0]+'fgh_'+coord[0]   ;; 'fgh' GSE TPLOT handle
spperi         = pref[0]+'state_spinper'   ;; spacecraft spin period TPLOT handle
vname_nc       = pref[0]+'Velocity_peib_no_GIs_UV'  ;;  "corrected" bulk flow velocities [km/s, GSE]
;;  Get spacecraft GSE positions [km]
tpn_stategse   = pref[0]+'state_pos_gse'
get_data,tpn_stategse[0],DATA=posstr,DLIM=dlim,LIM=lim

tr_igse        = [[dat_igse.TIME],[dat_igse.END_TIME]]
n_i            = N_ELEMENTS(dat_igse)
se__posx       = REPLICATE(d,n_i[0],2L)
se__posy       = REPLICATE(d,n_i[0],2L)
se__posz       = REPLICATE(d,n_i[0],2L)
FOR k=0L, 1L DO BEGIN                                                        $
  se__posx[*,k]   = INTERPOL(posstr.Y[*,0],posstr.X,tr_igse[*,k],/SPLINE)   & $
  se__posy[*,k]   = INTERPOL(posstr.Y[*,1],posstr.X,tr_igse[*,k],/SPLINE)   & $
  se__posz[*,k]   = INTERPOL(posstr.Y[*,2],posstr.X,tr_igse[*,k],/SPLINE)

;;  Define averages for each component
avg_posx       = (se__posx[*,0] + se__posx[*,1])/2d0
avg_posy       = (se__posy[*,0] + se__posy[*,1])/2d0
avg_posz       = (se__posz[*,0] + se__posz[*,1])/2d0
avg_pos        = [[avg_posx],[avg_posy],[avg_posz]]
avg_posu       = unit_vec(avg_pos)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot individual ion contour plots
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
oldthick       = !P.THICK

;;  Define which vDF to use
jj             = 195L           ;;  TH-B IESA at 09:00:12.041 UT on 2009-07-13
dat_e0         = dat_igse[jj]   ;;  Entire velocity distribution
dat_c0         = dumm_m[jj]     ;;  core solar wind beam only
dat_r0         = dumm_s[jj]     ;;  everything except core solar wind beam
;;  Moments derived from this vDF
ndens_ecr      = [density_e[jj],density_m[jj],density_s[jj]]
atemp_ecr      = [avgtemp_e[jj],avgtemp_m[jj],avgtemp_s[jj]]
tanis_ecr      = [  tanis_e[jj],  tanis_m[jj],  tanis_s[jj]]
str_prefx      = ';;  '+['<Ni>_s =          ','<Ti>_s =          ','(Tperp/Tpara)_s = ']
str_suffx      = '  --> For  '+time_string(dat_e0[0].TIME,PREC=3)
FOR j=0L, 2L DO BEGIN $
  IF (j EQ 0) THEN x = ndens_ecr ELSE IF (j EQ 1) THEN x = atemp_ecr ELSE x = tanis_ecr  & $
  PRINT,str_prefx[j],x[0],x[1],x[2],str_suffx[0]
;;-----------------------------------------------------------------------------------------------
;;                          Entire        Core         Halo
;;===============================================================================================
;;  <Ni>_s =                9.42774      6.94853      2.47921  --> For  2009-07-13/09:00:12.041
;;  <Ti>_s =                277.516      29.1062      973.738  --> For  2009-07-13/09:00:12.041
;;  (Tperp/Tpara)_s =       1.13949      1.26153      1.13002  --> For  2009-07-13/09:00:12.041
;;-----------------------------------------------------------------------------------------------

ngrid          = 30L               ;;  # of grid points to use
xname          = 'B!Do!N'          ;;  name of VEC1 (see below)
yname          = 'V!Dsw!N'         ;;  name of VEC2 (see below)
vlim           = 15e2
;vlim           = 10e2
;;  Put a circle of constant energy
;;    gyrospeed of specularly reflected ion for this shock = 503.19490 km/s
Vgy_rs         = [v_thresh[0],v_uv[0]]
;;  Define the # of points to smooth the cuts of the DF
ns             = 4L
smc            = 1
smct           = 1
;;  Define the min/max allowable range in DF plots
dfmax          = 1d-4
dfmin          = 1d-15
dfra           = [1d-13,1d-7]
;;  Define the shock normal vector
gnorm          = REFORM(unit_vec(gnorm))
normnm         = 'Shock Normal[0]'
Earthuvec      = -1d0*REFORM(avg_posu[jj,*])
Earthnm        = 'Earth Dir.'

;;  Do not interpolate back to original energies after frame transformation
inter          = 0
vcirc          = Vgy_rs
;;  Define the two vectors which define the XY-plane
vec1           = dat_e0[0].MAGF
vec2           = dat_e0[0].VSW
!P.THICK       = 1.75   ;;  use 2.0 for X11 and 3.0 for PS files
pp             = ['xy','xz','yz']

k              = 0L
;;  Plot vDFs in different planes
WSET,1
WSHOW,1
contour_3d_1plane,dat_e0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[k],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]

WSET,2
WSHOW,2
contour_3d_1plane,dat_c0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[k],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_r0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[k],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]


;;-----------------------------------------------------------------------------------------------
;;  Save Plots
;;-----------------------------------------------------------------------------------------------
dat_e0         = dat_igse[jj]   ;;  Entire velocity distribution
dat_c0         = dumm_m[jj]     ;;  core solar wind beam only
dat_r0         = dumm_s[jj]     ;;  everything except core solar wind beam
sm_str         = '_SmthCutCont-'+STRTRIM(STRING(ns[0],FORMAT='(I2.2)'),2)+'pts'
vl_str         = '_VLIM-'+STRTRIM(STRING(vlim[0],FORMAT='(I4.4)'),2)+'km-s'
df_sfxa        = STRCOMPRESS(STRING(dfra,FORMAT='(E10.1)'),/REMOVE_ALL)
df_suff        = '_DF_'+df_sfxa[0]+'-'+df_sfxa[1]
;;  Define time strings (file name format) associated with chosen vDF
fnm_tra        = file_name_times([dat_e0[0].TIME,dat_e0[0].END_TIME],PREC=3)
fntime         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
;;  Define strings associated with each plane
xyzvecf        = ['V1','V1xV2xV1','V1xV2']
xy_suff        = xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff        = xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff        = xyzvecf[2]+'_vs_'+xyzvecf[1]
plane_strs     = [xy_suff[0],xz_suff[0],yz_suff[0]]
planes         = ['xy','xz','yz']
vDFpop_str     = ['Entire','CoreSW','HaloSW']
fnm_prefx      = 'IESA_Burst_Corrected-Vbulk_'+vDFpop_str+'_'+fntime[0]+'_'
fnames         = REPLICATE('',3L,3L)
FOR k=0L, 2L DO fnames[*,k] = fnm_prefx[*]+plane_strs[k]+sm_str[0]+vl_str[0]+df_suff[0]
all_vdfs       = {T0:dat_e0[0],T1:dat_c0[0],T2:dat_r0[0]}

vec1           = dat_e0[0].MAGF
vec2           = dat_e0[0].VSW
!P.THICK       = 3.0    ;;  use 2.0 for X11 and 3.0 for PS files
FOR j=0L, 2L DO BEGIN                                                               $
  dat_0 = all_vdfs.(j)                                                            & $
  FOR k=0L, 2L DO BEGIN                                                             $
    pp    = planes[k]                                                             & $
    fname = fnames[j,k]                                                           & $
    popen,fname[0],/PORT                                                          & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,          $
                            YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,              $
                            DFRA=dfra,VCIRC=vcirc,PLANE=pp[0],EX_VEC1=Earthuvec,    $
                            EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],       $
                            SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],      $
                            DFMAX=dfmax[0]                                        & $
    pclose


;;-----------------------------------------------------------------------------------------------
;;  Plot with "bad" (level-2) Vsw values
;;-----------------------------------------------------------------------------------------------
tr_igse        = [[dat_igse.TIME],[dat_igse.END_TIME]]
coord_gse      = 'gse'
sc             = probe[0]
pref           = 'th'+sc[0]+'_'
vname_L2       = pref[0]+'peib_velocity_'+coord_gse[0]  ;;  level-2 bulk flow velocities [km/s, GSE]
get_data,vname_L2[0],DATA=vsw_L2,DLIM=dlim_vsw_L2,LIM=lim_vsw_L2
;;  Convert to new time stamps
old_v          = vsw_L2.Y
old_t          = vsw_L2.X
new_t          = REFORM(tr_igse[*,0])
vsw_L2_s       = resample_2d_vec(old_v,old_t,new_t,/NO_EXTRAPOLATE)
new_t          = REFORM(tr_igse[*,1])
vsw_L2_e       = resample_2d_vec(old_v,old_t,new_t,/NO_EXTRAPOLATE)
vsw_L2_a       = (vsw_L2_s + vsw_L2_e)/2d0
new_t          = (REFORM(tr_igse[*,0]) + REFORM(tr_igse[*,1]))/2d0
vsw_L2_at      = resample_2d_vec(old_v,old_t,new_t,/NO_EXTRAPOLATE)


jj             = 195L           ;;  TH-B IESA at 09:00:12.041 UT on 2009-07-13
PRINT,';; ',REFORM(vsw_L2_s[jj,*])
PRINT,';; ',REFORM(vsw_L2_e[jj,*])
PRINT,';; ',REFORM(vsw_L2_a[jj,*])
PRINT,';; ',REFORM(vsw_L2_at[jj,*])
;;       -206.18514       29.382454       129.93003
;;       -220.77772       15.267494       120.94570
;;       -213.48143       22.324974       125.43787
;;       -213.97245       21.950059       125.11780

;;  Use value interpolated to middle of vDF time range
vsw0           = [-213.97245,21.950059,125.11780]
dat_e0         = dat_igse[jj]   ;;  Entire velocity distribution
dat_c0         = dumm_m[jj]     ;;  core solar wind beam only
dat_r0         = dumm_s[jj]     ;;  everything except core solar wind beam
;;  Redefine value assigned to VSW tag
dat_e0[0].VSW  = vsw0
dat_c0[0].VSW  = vsw0
dat_r0[0].VSW  = vsw0

ngrid          = 30L               ;;  # of grid points to use
xname          = 'B!Do!N'          ;;  name of VEC1 (see below)
yname          = 'V!Dsw!N'         ;;  name of VEC2 (see below)
vlim           = 15e2
;;  Put a circle of constant energy at the gyrospeed
Vgy_rs         = [v_thresh[0],v_uv[0]]
;;  Define the # of points to smooth the cuts of the DF
ns             = 4L
smc            = 1
smct           = 1
;;  Define the min/max allowable range in DF plots
dfmax          = 1d-4
dfmin          = 1d-15
dfra           = [1d-13,1d-7]
;;  Define the shock normal vector
gnorm          = REFORM(unit_vec(gnorm))
normnm         = 'Shock Normal[0]'
Earthuvec      = -1d0*REFORM(avg_posu[jj,*])
Earthnm        = 'Earth Dir.'

;;  Do not interpolate back to original energies after frame transformation
inter          = 0
vcirc          = Vgy_rs
;;  Define the two vectors which define the XY-plane
vec1           = dat_e0[0].MAGF
vec2           = dat_e0[0].VSW
!P.THICK       = 1.75   ;;  use 2.0 for X11 and 3.0 for PS files
pp             = ['xy','xz','yz']

k              = 0L
;;  Plot vDFs in different planes
WSET,1
WSHOW,1
contour_3d_1plane,dat_e0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[k],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]

WSET,2
WSHOW,2
contour_3d_1plane,dat_c0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[k],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_r0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[k],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]



;;  Save Plots
sm_str         = '_SmthCutCont-'+STRTRIM(STRING(ns[0],FORMAT='(I2.2)'),2)+'pts'
vl_str         = '_VLIM-'+STRTRIM(STRING(vlim[0],FORMAT='(I4.4)'),2)+'km-s'
df_sfxa        = STRCOMPRESS(STRING(dfra,FORMAT='(E10.1)'),/REMOVE_ALL)
df_suff        = '_DF_'+df_sfxa[0]+'-'+df_sfxa[1]
;;  Define time strings (file name format) associated with chosen vDF
fnm_tra        = file_name_times([dat_e0[0].TIME,dat_e0[0].END_TIME],PREC=3)
fntime         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
;;  Define strings associated with each plane
xyzvecf        = ['V1','V1xV2xV1','V1xV2']
xy_suff        = xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff        = xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff        = xyzvecf[2]+'_vs_'+xyzvecf[1]
plane_strs     = [xy_suff[0],xz_suff[0],yz_suff[0]]
planes         = ['xy','xz','yz']
vDFpop_str     = ['Entire','CoreSW','HaloSW']
fnm_prefx      = 'IESA_Burst_L2-Vbulk_'+vDFpop_str+'_'+fntime[0]+'_'
fnames         = REPLICATE('',3L,3L)
FOR k=0L, 2L DO fnames[*,k] = fnm_prefx[*]+plane_strs[k]+sm_str[0]+vl_str[0]+df_suff[0]
all_vdfs       = {T0:dat_e0[0],T1:dat_c0[0],T2:dat_r0[0]}

vec1           = dat_e0[0].MAGF
vec2           = dat_e0[0].VSW
!P.THICK       = 3.0    ;;  use 2.0 for X11 and 3.0 for PS files
FOR j=0L, 2L DO BEGIN                                                               $
  dat_0 = all_vdfs.(j)                                                            & $
  FOR k=0L, 2L DO BEGIN                                                             $
    pp    = planes[k]                                                             & $
    fname = fnames[j,k]                                                           & $
    popen,fname[0],/PORT                                                          & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,          $
                            YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,              $
                            DFRA=dfra,VCIRC=vcirc,PLANE=pp[0],EX_VEC1=Earthuvec,    $
                            EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],       $
                            SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],      $
                            DFMAX=dfmax[0]                                        & $
    pclose


;;-----------------------------------------------------------------------------------------------
;;  Plot in SC-Frame
;;-----------------------------------------------------------------------------------------------
jj             = 195L           ;;  TH-B IESA at 09:00:12.041 UT on 2009-07-13
vsw0           = [1e-1,0e0,0e0]
dat_e0         = dat_igse[jj]   ;;  Entire velocity distribution
dat_c0         = dumm_m[jj]     ;;  core solar wind beam only
dat_r0         = dumm_s[jj]     ;;  everything except core solar wind beam
;;  Redefine value assigned to VSW tag
dat_e0[0].VSW  = vsw0
dat_c0[0].VSW  = vsw0
dat_r0[0].VSW  = vsw0

ngrid          = 30L               ;;  # of grid points to use
xname          = 'B!Do!N'          ;;  name of VEC1 (see below)
yname          = 'V!Dsw!N'         ;;  name of VEC2 (see below)
vlim           = 15e2
;;  Put a circle of constant energy at the gyrospeed
Vgy_rs         = [v_thresh[0],v_uv[0]]
;;  Define the # of points to smooth the cuts of the DF
ns             = 4L
smc            = 1
smct           = 1
;;  Define the min/max allowable range in DF plots
dfmax          = 1d-4
dfmin          = 1d-15
dfra           = [1d-13,1d-7]
;;  Define the shock normal vector
gnorm          = REFORM(unit_vec(gnorm))
normnm         = 'Shock Normal[0]'
Earthuvec      = -1d0*REFORM(avg_posu[jj,*])
Earthnm        = 'Earth Dir.'

;;  Do not interpolate back to original energies after frame transformation
inter          = 0
vcirc          = Vgy_rs
;;  Define the two vectors which define the XY-plane
vec1           = dat_e0[0].MAGF
vec2           = dat_e0[0].VSW
!P.THICK       = 1.75   ;;  use 2.0 for X11 and 3.0 for PS files
pp             = ['xy','xz','yz']

k              = 0L
;;  Plot vDFs in different planes
WSET,1
WSHOW,1
contour_3d_1plane,dat_e0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[k],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]

WSET,2
WSHOW,2
contour_3d_1plane,dat_c0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[k],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_r0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[k],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]



;;  Save Plots
sm_str         = '_SmthCutCont-'+STRTRIM(STRING(ns[0],FORMAT='(I2.2)'),2)+'pts'
vl_str         = '_VLIM-'+STRTRIM(STRING(vlim[0],FORMAT='(I4.4)'),2)+'km-s'
df_sfxa        = STRCOMPRESS(STRING(dfra,FORMAT='(E10.1)'),/REMOVE_ALL)
df_suff        = '_DF_'+df_sfxa[0]+'-'+df_sfxa[1]
;;  Define time strings (file name format) associated with chosen vDF
fnm_tra        = file_name_times([dat_e0[0].TIME,dat_e0[0].END_TIME],PREC=3)
fntime         = fnm_tra.F_TIME[0]+'-'+STRMID(fnm_tra.F_TIME[1],11L)  ;; e.g., 2009-07-13_0859x41.8650-0859x51.8650
;;  Define strings associated with each plane
xyzvecf        = ['V1','V1xV2xV1','V1xV2']
xy_suff        = xyzvecf[1]+'_vs_'+xyzvecf[0]
xz_suff        = xyzvecf[0]+'_vs_'+xyzvecf[2]
yz_suff        = xyzvecf[2]+'_vs_'+xyzvecf[1]
plane_strs     = [xy_suff[0],xz_suff[0],yz_suff[0]]
planes         = ['xy','xz','yz']
vDFpop_str     = ['Entire','CoreSW','HaloSW']
fnm_prefx      = 'IESA_Burst_SC-Frame_'+vDFpop_str+'_'+fntime[0]+'_'
fnames         = REPLICATE('',3L,3L)
FOR k=0L, 2L DO fnames[*,k] = fnm_prefx[*]+plane_strs[k]+sm_str[0]+vl_str[0]+df_suff[0]
all_vdfs       = {T0:dat_e0[0],T1:dat_c0[0],T2:dat_r0[0]}

vec1           = dat_e0[0].MAGF
vec2           = dat_e0[0].VSW
!P.THICK       = 3.0    ;;  use 2.0 for X11 and 3.0 for PS files
FOR j=0L, 2L DO BEGIN                                                               $
  dat_0 = all_vdfs.(j)                                                            & $
  FOR k=0L, 2L DO BEGIN                                                             $
    pp    = planes[k]                                                             & $
    fname = fnames[j,k]                                                           & $
    popen,fname[0],/PORT                                                          & $
      contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,          $
                            YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,              $
                            DFRA=dfra,VCIRC=vcirc,PLANE=pp[0],EX_VEC1=Earthuvec,    $
                            EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],       $
                            SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],      $
                            DFMAX=dfmax[0]                                        & $
    pclose
















;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;se_posx        = INTERPOL(posstr.Y[*,0],posstr.X,tr_igse,/SPLINE)
;se_posy        = INTERPOL(posstr.Y[*,1],posstr.X,tr_igse,/SPLINE)
;se_posz        = INTERPOL(posstr.Y[*,2],posstr.X,tr_igse,/SPLINE)
;se_pos         = [[se_posx],[se_posy],[se_posz]]
;avg_pos        = DBLARR(3)
;FOR j=0L, 2L DO avg_pos[j] = MEAN(se_pos[*,j],/NAN)
;avg_posu       = REFORM(unit_vec(avg_pos))

;sunv           = [1.,0.,0.]
;sunn           = 'Sun Dir.'        ;;  name of extra vector

;Vgy_rs         = 5d2               ;;  Put a circle of constant energy at the gyrospeed
;Vgy_rs         = 3d2               ;;  Put a circle of constant energy at the gyrospeed

;dat_0[0].VSW   = vsw0
;vec2           = vsw0





WSET,2
WSHOW,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='xz',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='yz',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]


popen,'example_ivDF_XY-plane_1Bo'+vl_str[0],/PORT
  contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv, $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                        DFMAX=dfmax[0]
pclose

popen,'example_ivDF_ZX-plane_1Bo'+vl_str[0],/PORT
  contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE='xz',EX_VEC1=sunv, $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                        DFMAX=dfmax[0]
pclose

popen,'example_ivDF_YZ-plane_1Bo'+vl_str[0],/PORT
  contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE='yz',EX_VEC1=sunv, $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                        DFMAX=dfmax[0]
pclose





WSET,2
WSHOW,2
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='xz',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc,PLANE='yz',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                      DFMAX=dfmax[0]


;;  Save Plots
!P.THICK       = 3.0    ;;  use 2.0 for X11 and 3.0 for PS files
popen,'example_ivDF_XY-plane_1Bo'+vl_str[0],/PORT
  contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv, $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                        DFMAX=dfmax[0]
pclose

popen,'example_ivDF_ZX-plane_1Bo'+vl_str[0],/PORT
  contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE='xz',EX_VEC1=sunv, $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                        DFMAX=dfmax[0]
pclose

popen,'example_ivDF_YZ-plane_1Bo'+vl_str[0],/PORT
  contour_3d_1plane,dat_0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                        YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                        DFRA=dfra,VCIRC=vcirc[0],PLANE='yz',EX_VEC1=sunv, $
                        EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                        SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],$
                        DFMAX=dfmax[0]
pclose










