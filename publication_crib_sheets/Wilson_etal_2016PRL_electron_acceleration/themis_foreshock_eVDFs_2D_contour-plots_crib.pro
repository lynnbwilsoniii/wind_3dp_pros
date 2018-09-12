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
R_E            = 6.37814d3            ;;  Earth's Equatorial Radius [km]
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  Potential Interesting VDFs:  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe B

probe          = 'b'
tdate          = '2009-07-13'
date           = '071309'
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
;@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_foreshock_eVDFs_batch.pro
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_themis_foreshock_eVDFs_batch.pro
n_e            = N_ELEMENTS(dat_egse)
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

tr_egse        = [[dat_egse.TIME],[dat_egse.END_TIME]]
se__posx       = REPLICATE(d,n_e[0],2L)
se__posy       = REPLICATE(d,n_e[0],2L)
se__posz       = REPLICATE(d,n_e[0],2L)
FOR k=0L, 1L DO BEGIN                                                        $
  se__posx[*,k]   = INTERPOL(posstr.Y[*,0],posstr.X,tr_egse[*,k],/SPLINE)   & $
  se__posy[*,k]   = INTERPOL(posstr.Y[*,1],posstr.X,tr_egse[*,k],/SPLINE)   & $
  se__posz[*,k]   = INTERPOL(posstr.Y[*,2],posstr.X,tr_egse[*,k],/SPLINE)

;;  Define averages for each component
avg_posx       = (se__posx[*,0] + se__posx[*,1])/2d0
avg_posy       = (se__posy[*,0] + se__posy[*,1])/2d0
avg_posz       = (se__posz[*,0] + se__posz[*,1])/2d0
avg_pos        = [[avg_posx],[avg_posy],[avg_posz]]
avg_posu       = unit_vec(avg_pos)
;;----------------------------------------------------------------------------------------
;;  Calculate moments [both core and "residue"]
;;----------------------------------------------------------------------------------------
sform          = moments_3d_new()
str_element,sform,'END_TIME',0d0,/ADD_REPLACE
momb_e         = REPLICATE(sform[0],n_e[0])   ;;  Moments for entire velocity distribution
true_vbulk     = REFORM(dat_egse.VSW)
true_magf      = REFORM(dat_egse.MAGF)
true_scpot     = REFORM(dat_egse.SC_POT[0])
FOR j=0L, n_e - 1L DO BEGIN                                                        $
  tmome   = 0                                                                    & $
  dele    = dat_egse[j]                                                          & $
  pot     = true_scpot[j]                                                        & $
  tmagf   = REFORM(true_magf[*,j])                                               & $
  tvsw    = REFORM(true_vbulk[*,j])                                              & $
  ex_str  = {FORMAT:sform,DOMEGA_WEIGHTS:1,TRUE_VBULK:tvsw,MAGDIR:tmagf}         & $
  tmome   = moments_3d_new(dele,SC_POT=pot[0],_EXTRA=ex_str)                     & $
  str_element,tmome,'END_TIME',dele[0].END_TIME,/ADD_REPLACE                     & $
  momb_e[j] = tmome[0]

times          = momb_e.TIME
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
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot individual electron contour plots
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
WINDOW,1,RETAIN=2,XSIZE=800,YSIZE=1100,TITLE='Y vs. X Plane'
WINDOW,2,RETAIN=2,XSIZE=800,YSIZE=1100,TITLE='X vs. Z Plane'
WINDOW,3,RETAIN=2,XSIZE=800,YSIZE=1100,TITLE='Z vs. Y Plane'

oldthick       = !P.THICK
;;  Define which vDF to use
jj             = 1368L             ;;  TH-B EESA at 2009-07-13/10:06:26.130 UT
dat_e0         = dat_egse[jj]      ;;  Entire velocity distribution
;;  Moments derived from this vDF
n_T_Tanis      = FLOAT([density_e[jj],avgtemp_e[jj],  tanis_e[jj]])
str_prefx      = ';;  <Ne>           <Te>           (Tperp/Tpara)_e '
str_suffx      = '  --> For  '+time_string(dat_e0[0].TIME,PREC=3)
PRINT,';;',n_T_Tanis[0],n_T_Tanis[1],n_T_Tanis[2],str_suffx[0]
;;---------------------------------------------------------------------------
;;       <Ne>         <Te>      (Tanis)_e
;;===========================================================================
;;      12.9760      11.1001     0.875577  --> For  2009-07-13/10:05:32.707
;;      12.8794      11.2978     0.868419  --> For  2009-07-13/10:06:26.130
;;---------------------------------------------------------------------------
ngrid          = 30L               ;;  # of grid points to use
xname          = 'B!Do!N'          ;;  name of VEC1 (see below)
yname          = 'V!Dsw!N'         ;;  name of VEC2 (see below)
vlim           = 25d3
;;  Put a circles of constant energy
;Vgy_rs         = [1d0,2d0,3d0,4d0,5d0]*5d3
Vgy_rs         = [1d0,2d0,3d0]*5d3
;;  Define the # of points to smooth the cuts of the DF
ns             = 3L
smc            = 1
smct           = 1
;;  Define the min/max allowable range in DF plots
dfmax          = 1d-4
dfmin          = 1d-20
dfra           = [1d-19,1d-9]
;;  Define the shock normal vector
gnorm          = REFORM(unit_vec(gnorm))
normnm         = 'Shock Normal[0]'
Earthuvec      = -1d0*REFORM(avg_posu[jj,*])
Earthnm        = 'Earth Dir.'

;;  Do not interpolate back to original energies after frame transformation
inter          = 0
vcirc          = Vgy_rs
;;  Define the two vectors which define the XY-plane
!P.THICK       = 1.75   ;;  use 2.0 for X11 and 3.0 for PS files
pp             = ['xy','xz','yz']

;;  Plot vDFs in different planes
WSET,1
WSHOW,1
vec1           = dat_e0[0].MAGF
vec2           = dat_e0[0].VSW
contour_3d_1plane,dat_e0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[0],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]

WSET,2
WSHOW,2
contour_3d_1plane,dat_e0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[1],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_e0,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                      DFRA=dfra,VCIRC=vcirc,PLANE=pp[2],EX_VEC1=Earthuvec, $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],   $
                      DFMAX=dfmax[0]



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot individual ion contour plots
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define which vDF to use
ji             = 1365L             ;;  TH-B IESA at 2009-07-13/10:05:32.707 UT
dat_i0         = dat_igse[ji]      ;;  Entire velocity distribution

ngrid          = 30L               ;;  # of grid points to use
xname          = 'B!Do!N'          ;;  name of VEC1 (see below)
yname          = 'V!Dsw!N'         ;;  name of VEC2 (see below)
vlimi          = 15e2
;;  Put a circles of constant energy
Vgy_rsi        = [1d0,2d0]*5d2
;;  Define the # of points to smooth the cuts of the DF
nsi            = 4L
smc            = 1
smct           = 1
;;  Define the min/max allowable range in DF plots
dfrai          = [1d-13,1d-5]
;;  Define the shock normal vector
gnorm          = REFORM(unit_vec(gnorm))
normnm         = 'Shock Normal[0]'

;;  Do not interpolate back to original energies after frame transformation
inter          = 0
vcirci         = Vgy_rsi
;;  Define the two vectors which define the XY-plane
!P.THICK       = 1.75   ;;  use 2.0 for X11 and 3.0 for PS files
pp             = ['xy','xz','yz']

;;  Plot vDFs in different planes
WSET,1
WSHOW,1
vec1           = dat_i0[0].MAGF
vec2           = dat_i0[0].VSW
contour_3d_1plane,dat_i0,vec1,vec2,VLIM=vlimi,NGRID=ngrid,XNAME=xname,            $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=nsi,/ONE_C,                 $
                      DFRA=dfrai,VCIRC=vcirci,PLANE=pp[0],EX_VEC1=Earthuvec,      $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],           $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],          $
                      DFMAX=dfmax[0]

WSET,2
WSHOW,2
contour_3d_1plane,dat_i0,vec1,vec2,VLIM=vlimi,NGRID=ngrid,XNAME=xname,            $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=nsi,/ONE_C,                 $
                      DFRA=dfrai,VCIRC=vcirci,PLANE=pp[1],EX_VEC1=Earthuvec,      $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],           $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],          $
                      DFMAX=dfmax[0]

WSET,3
WSHOW,3
contour_3d_1plane,dat_i0,vec1,vec2,VLIM=vlimi,NGRID=ngrid,XNAME=xname,            $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=nsi,/ONE_C,                 $
                      DFRA=dfrai,VCIRC=vcirci,PLANE=pp[2],EX_VEC1=Earthuvec,      $
                      EX_VN1=Earthnm[0],EX_VEC0=gnorm,EX_VN0=normnm[0],           $
                      SM_CONT=smct,/NO_REDF,INTERP=inter,DFMIN=dfmin[0],          $
                      DFMAX=dfmax[0]













