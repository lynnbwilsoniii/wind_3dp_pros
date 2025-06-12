;+
;*****************************************************************************************
;
;  FUNCTION :   calc_doppler_shifted_whistler_dispersion.pro
;  PURPOSE  :   This routine takes an input wave unit vector, background plasma
;                 parameters, and spacecraft frame (SCF) frequency to find the plasma
;                 rest frame (PRF) properties of a whistler mode wave.  The routine
;                 solves a 3rd order polynomial given by:
;                   A K^3 + B K^2 + C K + D = 0
;                      A  =  V
;                      B  = (Cos(theta_kB) + D)
;                      C  = V
;                      D  = -wsc/Ωce_avg
;                 where V = Vsw/VAe Cos(theta_kV) and K  = (kc/wpe).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               @load_constants_fund_em_atomic_c2014_batch.pro
;               @load_constants_extra_part_co2014_ci2015_batch.pro
;               @load_constants_astronomical_aa2015_batch.pro
;               is_a_3_vector.pro
;               is_a_number.pro
;               test_plot_axis_range.pro
;               perturb_dot_prod_angle.pro
;               lbw_perturb_input.pro
;               mag__vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               KHAT          :  [N,3]-Element [numeric] array of wave unit vectors
;               FLOW          :  [N]-Element [numeric] array of SCF frequencies [Hz] for
;                                  the lower bound of a frequency filter (i.e., the
;                                  solutions are assumed to come from a bandpass filtered
;                                  minimum variance analysis)
;               FUPP          :  [N]-Element [numeric] array of SCF frequencies [Hz]
;                                  the upper bound of a frequency filter
;               BVEC          :  [N,3]-Element [numeric] array defining the 3-vector
;                                  quasi-static magnetic field [nT] vector
;               VVEC          :  [N,3]-Element [numeric] array defining the 3-vector
;                                  bulk flow velocity [km/s] vector of the plasma
;               DENS          :  [N]-Element [numeric] array defining the scalar
;                                  number density [cm^(-3)] of the plasma
;
;  EXAMPLES:    
;               [calling sequence]
;               test = calc_doppler_shifted_whistler_dispersion(khat,flow,fupp,bvec,vvec,dens  $
;                                                  [,DKUV=dkuv] [,DBVC=dbvc] [,DVVC=dvvc]      $    ;;  Inputs
;                                                  [,DDEN=dden] [,USE_MED=use_med]             $
;                                                  [,WRN_RAN=wrn_ran] [,KBR_RAN=kbr_ran]       $
;                                                  [,THETA_KB=theta_kb] [,THETA_KV=theta_kv]   $    ;;  Outputs
;                                                  [,KBAR=kbar] [,KMAG=kmag] [,LAMBDA=lambda]  $
;                                                  [,WRNOR=wrnor] [,F_REST=f_rest]             $
;                                                  [,VPH_PRF=vph_prf])
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               DKUV          :  [N,3]-Element [numeric] array defining the uncertainty
;                                  in the wave unit vectors
;                                  [Default = REPLICATE(0d0,N,3)]
;               DBVC          :  [N,3]-Element [numeric] array defining the uncertainty
;                                  in the quasi-static magnetic field [nT] vectors
;                                  [Default = REPLICATE(0d0,N,3)]
;               DVVC          :  [N,3]-Element [numeric] array defining the uncertainty
;                                  in the bulk flow velocity [km/s] vector of the plasma
;                                  [Default = REPLICATE(0d0,N,3)]
;               DDEN          :  [N]-Element [numeric] array defining the uncertainty
;                                  in the scalar number density [cm^(-3)] of the plasma
;               USE_MED       :  If set, routine will use the median instead of the mean
;                                  for the output wave numbers etc.
;                                  [Default = FALSE]
;               WRN_RAN       :  [2]-Element [numeric] array defining the range of allowed
;                                  normalized frequency values to consider for outputs
;                                  Given this routine is for whistlers, the range should
;                                  fall between zero and one, i.e., 0 ≤ w/wce ≤ 1
;                                  [Default = [0,1]]
;               KBR_RAN       :  [2]-Element [numeric] array defining the range of allowed
;                                  normalized wavenumber values to consider for outputs
;                                  [Default = [0,1d3]]
;               **********************************
;               ***       DIRECT OUTPUTS       ***
;               **********************************
;               THETA_KB      :  Set to a named variable to return the wave normal angles
;                                  [deg] with respect to the quasi-static magnetic field
;                                  [N,2]-element array --> {value,uncertainty}
;               THETA_KV      :  Set to a named variable to return the wave normal angles
;                                  [deg] with respect to the bulk flow velocity
;                                  [N,2]-element array --> {value,uncertainty}
;               KBAR          :  " " the normalized wavenumber
;                                  [N,F,M,S]-element array (see notes)
;               KMAG          :  " " the wavenumber magnitude, |k| [m^(-1)]
;               LAMBDA        :  " " the wavelength, lambda [m] = 2π/|k|
;               WRNOR         :  " " the normalized PRF frequency, Ω = w_rest/wce
;               F_REST        :  " " the PRF frequency [Hz]
;               VPH_PRF       :  " " the PRF phase speed [km/s] = w_rest/|k|
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [01/23/2025   v1.0.0]
;             2)  Fixed an empty line in Man. page
;                                                                   [02/25/2025   v1.0.0]
;
;   NOTES:      
;               1)  Definitions:
;                 c          =  speed of light in vacuum [m/s]
;                                 [ 299,792,458 m/s ]
;                 ∑_o        =  permittivity of free space [F m^(-1) or C V^(-1)]
;                                 [ 8.854187817 x 10^(-12) F m^(-1) ]
;                 µ_o        =  permeability of free space [H m^(-1) or T m^(+2) A^(-1)]
;                                 [ 4π x 10^(-7) H m^(-1) ]
;                 e          =  fundamental charge [C]
;                                 [ 1.6021766208 x 10^(-19) C ]
;                 k_B        =  Boltzmann constant [J K^(-1)]
;                                 [ 1.38064851 x 10^(-23) J K^(-1) ]
;                 ms         =  mass of species s [kg]
;                 ns         =  number density of species s [m^(-3)]
;                 qs         =  charge of species s [C]
;                 Zs         =  charge state species s [N/A]
;                 Bo         =  quasi-static magnetic field vector [T]
;                 Ts         =  scalar temperature of species s [K]
;                 wps        =  nonrelativistic angular plasma frequency [rad/s] of species s
;                 Ωcs        =  angular cyclotron frequency [rad/s] of species s
;                 Ωcso       =  modulus of Ωcs in particle rest frame [rad/s]
;                 V_Ts       =  1D most probable thermal speed [m/s] of species s
;                 V_A        =  Alfven speed [m/s]
;                 V_Ae       =  electron Alfven speed [m/s]
;                 L_s        =  inertial length of species s [m]
;                 rho_cs     =  thermal gyroradius of species s [m]
;                 gamma      =  relativistic Lorentz factor [N/A]
;                 k          =  wave vector [m^(-1)]
;                 w          =  rest frame angular frequency [rad/s]
;                 kbar       =  |k| normalized to L_e [N/A]
;                 gbar       =  Ωceo normalized to wave frequency [N/A]
;                 wbar       =  wave frequency normalized to Ωceo [N/A]
;                 khat       =  unit vector parallel to k
;                 that       =  unit vector orthogonal to k but coplanar with Vgr
;                                 [counter-clockwise sense relative to wave vector]
;                 Vph        =  rest frame phase speed [m/s]
;                 Vgr        =  rest frame group velocity vector [m/s]
;                 Vgk        =  projection of group velocity along k [m/s]
;                 Vgt        =  projection of group velocity along theta-hat [m/s]
;                 alp        =  angle between k and Vgr [rad]
;                 the        =  angle between k and Bo [rad] (i.e., wave normal angle)
;               2)  General Parameter Expressions:
;                 qs         =  Zs e
;                 gamma      =  [ 1 + (v/c)^2 ]^(-1/2)
;                 Ωcs        =  qs |Bo|/(gamma ms)
;                 Ωcso       =  | qs |Bo|/ms |
;                 wps        =  [ ns qs^2 / ( ∑_o ms ) ]^(1/2)
;                 wlh        =  [ Ωceo Ωcpo ]^(1/2) = Ωceo [ me/Mp ]^(1/2)
;                 V_Ts       =  [ 2 k_B Ts / ms ]^(1/2)
;                 L_s        =  c/wps
;                 rho_cs     =  V_Ts/Ωcs
;                 V_A        =  |Bo|/[ µ_o n Mi ]^(1/2)
;                 V_Ae       =  |Bo|/[ µ_o n me ]^(1/2) = V_A [ Mi/me ]^(1/2)
;                 Vph        =  w/|k|
;                 kbar       =  |k| L_e = (k c / wpe)
;                 gbar       =  Ωceo/w
;                 wbar       =  w/Ωceo
;                 Vgr        =  ∂w/∂k  =  khat ∂w/∂|k| + that/|k| ∂w/∂the
;                 Vgk        =  (Vgr . khat)
;                 Vgt        =  (Vgr . that)
;                 Tan[alp]   =  1/|k| (∂w/∂the) / (∂w/∂|k|)
;                 the        =  ArcCos[ (k . Bo)/( |k| |Bo| ) ]
;               3)  Whistler Parameter Expressions:
;                 [*** High density limit --> (wpe/Ωceo)^2 >> 1 ***]
;                 wbar       =  kbar^2 Cos[the] / (1 + kbar^2)
;                 kbar       =  [ gbar Cos[the] - 1 ]^(-1/2)
;                 Vph        =  kbar V_Ae Cos[the]/(1 + kbar^2)
;                            =  V_Ae [ gbar Cos[the] - 1 ]^(1/2) / gbar
;                 Vgk        =  2 kbar V_Ae Cos[the] / (1 + kbar^2)^2
;                            =  2 V_Ae [ gbar Cos[the] - 1 ]^(3/2) / ( gbar^2 Cos[the] )
;                 Vgt        =  - kbar V_Ae Sin[the] / (1 + kbar^2)
;                            =  - V_Ae Sin[the] [ gbar Cos[the] - 1 ]^(1/2) / ( gbar Cos[the] )
;                 Vgr        =  Vph [ khat 2/(1 + kbar^2) - that Tan[the] ]
;                 Tan[alp]   =  - (1 + kbar^2)/2 Tan[the]
;                            =  - gbar Sin[the] / [ 2 ( gbar Cos[the] - 1 ) ]
;               4)  Whistler wave observation summary:
;                     Giagkiozis et al. [2018] (lion roars):
;                       wbar   ~ 0.023--0.72
;                       kbar   ~ 0.2--10
;                     Wilson et al. [2013] (lion roars):
;                       wbar   ~ 0.03--0.43
;                       kbar   ~ 0.2--1.0
;                     Wilson et al. [2013] (fast/magnetosonic-whistlers):
;                       wbar   ~ 0.0016--0.117
;                       kbar   ~ 0.02--5.0
;                     Wilson et al. [2017] (precursors):
;                       wbar   ~ 0.00054--0.023
;                       kbar   ~ 0.02--5.9
;                     Hull et al. [2024] JGR doi:10.1029/2023JA031630
;                       wbar   ~ 0.001--0.15
;                       kbar   ~ 0.018--0.48
;                       f_rest ~ 0.7--40 Hz <--> ~0.04--6.30 flh <--> ~1.7--270 fcp
;                       lambda ~ 10s to 100s km <--> ~0.3--8.0 L_i <--> ~13--343 L_e
;                       Vph_n  ~ 200--1400 km/s [along shock normal in NIF]
;               5)  The output will be multi-dimensional arrays where the elements are
;                     defined as follows
;                       N  :  # of MVA solutions                 = N
;                       P  :  # of perturbations to solutions    = 3
;                       M  :  + or - of wave unit vector         = 2
;                       F  :  lower and upper frequency bound    = 2
;                       S  :  # of solutions to cubic equation   = 3
;                       V  :  # of vector components             = 3
;
;  REFERENCES:  
;               0)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;               1)  Stix, T.H. (1992), "Waves in Plasmas," Springer-Verlag,
;                      New York Inc.,  American Institute of Physics,
;                      ISBN:0-88318-859-7.
;               2)  Sazhin, S.S. (1993), "Whistler-mode Waves in a Hot Plasma,"
;                      Cambridge University Press, The Edinburgh Building,
;                      Cambridge CB2 2RU, UK, ISBN:0-521-40165-8.
;               3)  Giagkiozis, S., et al., "Statistical study of the properties of
;                      magnetosheath lion roars," J. Geophys. Res. 123,
;                      doi:10.1029/2018JA025343, 2018.
;               4)  Wilson III, L.B., et al., "Electromagnetic waves and electron
;                      anisotropies downstream of supercritical interplanetary shocks,"
;                      J. Geophys. Res. 118(1), pp. 5--16,
;                      doi:10.1029/2012JA018167, 2013a.
;               5)  Wilson III, L.B., et al., "Revisiting the structure of low-Mach
;                      number, low-beta, quasi-perpendicular shocks,"
;                      J. Geophys. Res. 122(9), pp. 9115--9133,
;                      doi:10.1002/2017JA024352, 2017.
;               6)  Hull, A.J., et al., "Energy Transport and Conversion Within Earth's
;                      Supercritical Bow Shock: The Role of Intense Lower‐Hybrid
;                      Whistler Waves," J. Geophys. Res. 129, pp. e2023JA031630,
;                      doi:10.1029/2023JA031630, 2024.
;
;   CREATED:  01/17/2025
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/25/2025   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_doppler_shifted_whistler_dispersion,khat,flow,fupp,bvec,vvec,dens,         $
                                                  DKUV=dkuv,DBVC=dbvc,DVVC=dvvc,         $    ;;  Inputs
                                                  DDEN=dden,USE_MED=use_med,             $
                                                  WRN_RAN=wrn_ran,KBR_RAN=kbr_ran,       $
                                                  THETA_KB=theta_kb,THETA_KV=theta_kv,   $    ;;  Outputs
                                                  KBAR=kbar,KMAG=kmag,LAMBDA=lambda,     $
                                                  WRNOR=wrnor,F_REST=f_rest,             $
                                                  VPH_PRF=vph_prf

;;----------------------------------------------------------------------------------------
;;  Constants/Defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
pert           = [-1d0,0d0,1d0]                    ;;  Array used for perturbing data about accepted value
mnmx_90ang     = [0d0,90d0]                        ;;  Angle range limits for perturbing theta_kB and theta_kV
mnmx_18ang     = [9d1,18d1]                        ;;  Angle range limits for perturbing theta_kB and theta_kV
def_wrnran     = [0d0,1d0]                         ;;  Default allowed range for w/wce
def_kbrran     = [0d0,1d3]                         ;;  Default allowed range for kc/wpe
;;  Get fundamental and astronomical
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
@load_constants_astronomical_aa2015_batch.pro
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]                       ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]                    ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]                       ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]                       ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;  Frequency factors
wcefac         = 1d-9*qq[0]/me[0]
fcefac         = wcefac[0]/(2d0*!DPI)
neinvf         = (2d0*!DPI)^2d0*epo[0]*me[0]/qq[0]^2d0
wpefac         = SQRT(1d6*qq[0]^2d0/(me[0]*epo[0]))
fpefac         = wpefac[0]/(2d0*!DPI)
;;  Speed factors
vtefac         = SQRT(2d0*eV2J[0]/me[0])*1d-3      ;;  [km/s eV^(-1/2)]
valf_fac       = 1d-9/SQRT(muo[0]*1d6*mp[0])*1d-3  ;;  [km/s kg^(+1/2) nT^(-1)]
vale_fac       = valf_fac[0]*SQRT(mp[0]/me[0])     ;;  [km/s kg^(+1/2) nT^(-1)]
;;  Error messages
noinput_mssg   = 'No or incomplete input was supplied...'
badinvc_mssg   = 'KHAT, BVEC, and VVEC must be [N,3]-element arrays of 3-vectors...'
badinfq_mssg   = 'FLOW, FUPP, and DENS must be [N]-element arrays...'
badnelm_mssg   = 'All inputs must share the same number of elements, N, in first dimension...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF ((N_PARAMS() NE 6)) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check input format of 3-vectors
test           = (is_a_3_vector(khat,/NOMSSG) EQ 0) OR (is_a_3_vector(bvec,/NOMSSG) EQ 0) OR $
                 (is_a_3_vector(vvec,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badinvc_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(flow,/NOMSSG) EQ 0) OR (is_a_number(fupp,/NOMSSG) EQ 0) OR $
                 (is_a_number(dens,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badinfq_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Make sure dimensions match
szdkh          = SIZE(khat,/DIMENSIONS)
szdfl          = SIZE(flow,/DIMENSIONS)
szdfu          = SIZE(fupp,/DIMENSIONS)
szdbv          = SIZE(bvec,/DIMENSIONS)
szdvv          = SIZE(vvec,/DIMENSIONS)
szddn          = SIZE(dens,/DIMENSIONS)
test           = (szdkh[0] NE szdfl[0]) OR (szdkh[0] NE szdfu[0]) OR (szdkh[0] NE szdbv[0]) OR $
                 (szdkh[0] NE szdvv[0]) OR (szdkh[0] NE szddn[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badnelm_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
nv             = szdkh[0]                  ;;  # of unique wave solutions to find
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DKUV
IF (is_a_3_vector(dkuv,V_OUT=dkht,/NOMSSG)) THEN BEGIN
  szdv1          = SIZE(dkht,/DIMENSIONS)
  IF (szdv1[0] NE nv[0] OR szdv1[1] NE 3L) THEN dkht = REPLICATE(0d0,nv[0],3L)
ENDIF ELSE BEGIN
  dkht           = REPLICATE(0d0,nv[0],3L)
ENDELSE
;;  Check DBVC
IF (is_a_3_vector(dbvc,V_OUT=dbvv,/NOMSSG)) THEN BEGIN
  szdv1          = SIZE(dbvv,/DIMENSIONS)
  IF (szdv1[0] NE nv[0] OR szdv1[1] NE 3L) THEN dbvv = REPLICATE(0d0,nv[0],3L)
ENDIF ELSE BEGIN
  dbvv           = REPLICATE(0d0,nv[0],3L)
ENDELSE
;;  Check DVVC
IF (is_a_3_vector(dvvc,V_OUT=dvvv,/NOMSSG)) THEN BEGIN
  szdv1          = SIZE(dvvv,/DIMENSIONS)
  IF (szdv1[0] NE nv[0] OR szdv1[1] NE 3L) THEN dvvv = REPLICATE(0d0,nv[0],3L)
ENDIF ELSE BEGIN
  dvvv           = REPLICATE(0d0,nv[0],3L)
ENDELSE
;;  Check DDEN
IF (is_a_number(dden,/NOMSSG)) THEN BEGIN
  szdv1          = SIZE(dden,/DIMENSIONS)
  IF (szdv1[0] NE nv[0]) THEN ddns = REPLICATE(0d0,nv[0]) ELSE ddns = dden
ENDIF ELSE BEGIN
  ddns           = REPLICATE(0d0,nv[0])
ENDELSE
;;  Check USE_MED
IF ((N_ELEMENTS(use_med) GE 1) AND KEYWORD_SET(use_med)) THEN med_on = 1b ELSE med_on = 0b
;;  Check WRN_RAN
IF (test_plot_axis_range(wrn_ran,/NOMSSG)) THEN BEGIN
  wrnran         = REFORM(wrn_ran)
  wrnlim         = 1b
ENDIF ELSE BEGIN
  wrnran         = def_wrnran
  wrnlim         = 0b
ENDELSE
;;  Check KBR_RAN
IF (test_plot_axis_range(kbr_ran,/NOMSSG)) THEN BEGIN
  kbrran         = REFORM(kbr_ran)
  kbrlim         = 1b
ENDIF ELSE BEGIN
  kbrran         = def_kbrran
  kbrlim         = 0b
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate wave normal angles
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  theta_kB from Bo
vec1           = khat
dv_1           = dkht
vec2           = bvec
dv_2           = dbvv
;;  Output = [N,2]-element array:  {value,uncertainty}
theta_kB       = perturb_dot_prod_angle(vec1,vec2,/NAN,DELTA_V1=dv_1,DELTA_V2=dv_2,/USE_MED)
;;  theta_kV from Vsw
vec1           = khat
dv_1           = dkht
vec2           = vvec
dv_2           = dvvv
;;  Output = [N,2]-element array:  {value,uncertainty}
theta_kV       = perturb_dot_prod_angle(vec1,vec2,/NAN,DELTA_V1=dv_1,DELTA_V2=dv_2,/USE_MED)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate relevant plasma parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define array element definitions
;;     N  :  # of MVA solutions                 = N
;;     P  :  # of perturbations to solutions    = 3
;;     M  :  + or - of wave unit vector         = 2
;;     F  :  lower and upper frequency bound    = 2
;;     S  :  # of solutions to cubic equation   = 3
;;     V  :  # of vector components             = 3
;;----------------------------------------------------------------------------------------
;;  Perturb Bo, Vsw, and n
bv_pert        = lbw_perturb_input(bvec,dbvv)      ;;  [P,N,V]-Element arrays
vv_pert        = lbw_perturb_input(vvec,dvvv)      ;;  [P,N,V]-Element arrays
no_per0        = lbw_perturb_input(dens,ddns)      ;;  [P,N]-Element arrays
no_pert        = TRANSPOSE(no_per0)                ;;  [N,P]-Element array
;;  Check output
sizes          = {BB:N_ELEMENTS(bv_pert),VV:N_ELEMENTS(vv_pert),NN:N_ELEMENTS(no_pert)}
test           = (sizes.BB[0] LT 9) OR (sizes.NN[0] LT 9) OR (sizes.NN[0] LT 3)
IF (test[0]) THEN BEGIN
  ;;  This should not happen but it did --> fix it...
  MESSAGE,'This should not happen but it did --> fix it...',/INFORMATIONAL,/CONTINUE
  STOP
ENDIF
bad            = WHERE(no_pert LT 0,bd)
IF (bd[0] GT 0) THEN no_pert[bad] = d
;;  Calculate |Bo| and |Vsw|
Bm_pert        = REPLICATE(d,nv[0],3L)             ;;  [N,P]-Element array
Vm_pert        = Bm_pert
FOR j=0L, 2L DO BEGIN
  bv0            = REFORM(bv_pert[j,*,*])
  vv0            = REFORM(vv_pert[j,*,*])
  Bm_pert[*,j]   = mag__vec(bv0,/NAN)
  Vm_pert[*,j]   = mag__vec(vv0,/NAN)
ENDFOR
;;  Calculate Ωce [rad/s], wpe [rad/s], and c/wpe [m]
wce            = wcefac[0]*Bm_pert                 ;;  [N,P]-Element array
wpe            = wpefac[0]*SQRT(no_pert)           ;;  [N,P]-Element array
L_e            = c[0]/wpe                          ;;  [N,P]-Element array
;;  Calculate V_Ae [km/s]
vae_per0       = REPLICATE(d,nv[0],3L,3L)          ;;  [N,P,P]-Element array
FOR j=0L, 2L DO BEGIN
  bm0             = REFORM(Bm_pert[*,j]) # REPLICATE(1d0,3L)
  vae_per0[*,*,j] = vale_fac[0]*bm0/SQRT(no_pert)
ENDFOR
vae_avg        = MEAN(MEAN(vae_per0,/NAN,DIMENSION=3),/NAN,DIMENSION=2)
vae_min        = MIN(MIN(vae_per0,/NAN,DIMENSION=3),/NAN,DIMENSION=2)
vae_max        = MAX(MAX(vae_per0,/NAN,DIMENSION=3),/NAN,DIMENSION=2)
vae_unc        = ABS(vae_max - vae_min)/2d0
vae_per1       = lbw_perturb_input(vae_avg,vae_unc)        ;;  [P,N]-Element arrays
vae_pert       = TRANSPOSE(vae_per1)                       ;;  [N,P]-Element array
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Solve 3rd order polynomial
;;    A K^3 + B K^2 + C K + D = 0
;;       A  =  V
;;       B  = (Cos(theta_kB) + D)
;;       C  = V
;;       D  = -wsc/Ωce
;;       {where V = Vsw/VAe Cos(theta_kV) and K  = (kc/wpe)}
;;
;;    FZ_ROOTS([D,C,B,A],/DOUBLE,EPS=1d-8)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Perturb theta_kB and theta_kV and find complementary angles to serve as ±k solutions
thekBp         = REPLICATE(d,nv[0],3L,2L)                  ;;  [N,P,M]-Element array
thekVp         = REPLICATE(d,nv[0],3L,2L)
;;  Determine where initial wave normal angles lie (i.e., 0-90 or 90-180)
good_90B       = WHERE(theta_kB[*,0] LE 9d1,gd90B,COMPLEMENT=good_18B,NCOMPLEMENT=gd18B)
good_90V       = WHERE(theta_kV[*,0] LE 9d1,gd90V,COMPLEMENT=good_18V,NCOMPLEMENT=gd18V)
FOR j=0L, 2L DO BEGIN
  ;;  Define initial perturbed angle values
  tempB          = theta_kB[*,0] + pert[j]*theta_kB[*,1]
  tempV          = theta_kV[*,0] + pert[j]*theta_kV[*,1]
  ;;  Make sure perturbation did not flip effective sign of k
  ;;    (e.g., if original is in 0-90 deg, then keep all perturbed values in same range)
  IF (gd90B[0] GT 0) THEN tempB[good_90B] = (tempB[good_90B] > mnmx_90ang[0]) < mnmx_90ang[1]
  IF (gd18B[0] GT 0) THEN tempB[good_18B] = (tempB[good_18B] > mnmx_18ang[0]) < mnmx_18ang[1]
  IF (gd90V[0] GT 0) THEN tempV[good_90V] = (tempV[good_90V] > mnmx_90ang[0]) < mnmx_90ang[1]
  IF (gd18V[0] GT 0) THEN tempV[good_18V] = (tempV[good_18V] > mnmx_18ang[0]) < mnmx_18ang[1]
  ;;  Define perturbed output angles
  thekBp[*,j,0]  = tempB
  thekVp[*,j,0]  = tempV
ENDFOR
;;  Calculate complementary angles
thekBp[*,*,1L] = (18d1 - thekBp[*,*,0L])
thekVp[*,*,1L] = (18d1 - thekVp[*,*,0L])
;;  Calculate cosine of these angles
cothkB         = COS(thekBp*!DPI/18d1)                     ;;  [N,P,M]-Element array
cothkV         = COS(thekVp*!DPI/18d1)
;;----------------------------------------------------------------------------------------
;;  Calculate wsc/Ωce
;;----------------------------------------------------------------------------------------
wlow           = 2d0*!DPI*flow
wupp           = 2d0*!DPI*fupp
wbar           = REPLICATE(d,nv[0],3L,2L)
wratl          = (wlow # REPLICATE(1d0,3L))/wce
wratu          = (wupp # REPLICATE(1d0,3L))/wce
wbar[*,*,0L]   = wratl
wbar[*,*,1L]   = wratu
;;----------------------------------------------------------------------------------------
;;  Calculate Vsw/VAe
;;----------------------------------------------------------------------------------------
vrat0          = REPLICATE(d,nv[0],3L,3L)                  ;;  [N,P,P]-Element array
FOR j=0L, 2L DO BEGIN
  vm0            = REFORM(Vm_pert[*,j]) # REPLICATE(1d0,3L)
  vrat0[*,*,j]   = vm0/vae_pert
ENDFOR
vrt_avg        = MEAN(MEAN(vrat0,/NAN,DIMENSION=3),/NAN,DIMENSION=2)
vrt_min        = MIN(MIN(vrat0,/NAN,DIMENSION=3),/NAN,DIMENSION=2)
vrt_max        = MAX(MAX(vrat0,/NAN,DIMENSION=3),/NAN,DIMENSION=2)
vrt_unc        = ABS(vrt_max - vrt_min)/2d0
vrat_per0      = lbw_perturb_input(vrt_avg,vrt_unc)        ;;  [P,N]-Element array
vrat_pert      = TRANSPOSE(vrat_per0)                      ;;  [N,P]-Element array
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate K numerically
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
ksoln0         = DCOMPLEXARR(nv[0],3L,3L,3L,3L,2L,2L,3L)          ;;  [N,P,P,P,P,F,M,S]-elements
;;  Perturb:  Vsw/VAe, wsc/Ωce, Cos(theta_kB), and Cos(theta_kV) separately
FOR j=0L, 2L DO BEGIN
  ;;  Define Vsw/VAe
  vrat0          = REFORM(vrat_pert[*,j])                         ;;  [N]-element array
  FOR w=0L, 2L DO BEGIN
    ;;  Define wsc/Ωce
    wrat0          = REFORM(wbar[*,w,*])                          ;;  [N,F]-element array
    FOR cb=0L, 2L DO BEGIN
      ;;  Define Cos(theta_kB)
      cthkB0         = REFORM(cothkB[*,cb,*])                     ;;  [N,M]-element array
      FOR cv=0L, 2L DO BEGIN
        ;;  Define Cos(theta_kV)
        cthkV0         = REFORM(cothkV[*,cv,*])                   ;;  [N,M]-element array
        FOR ff=0L, 1L DO BEGIN
          FOR mm=0L, 1L DO BEGIN
            FOR nn=0L, nv[0] - 1L DO BEGIN
              ;;  Define polynomial coefficients
              dd             = -1d0*wrat0[nn,ff]
              aa             = vrat0[nn]*cthkV0[nn,mm]
              bb             = cthkB0[nn,mm] + dd[0]
              cc             = aa[0]
              ;;  Find roots of 3rd order polynomial
              result         = FZ_ROOTS([dd[0],cc[0],bb[0],aa[0]],/DOUBLE,EPS=1d-8)
              IF ((N_ELEMENTS(result) NE 3) OR (SIZE(result,/TYPE) NE 9)) THEN CONTINUE
              ;;  Fill dummy array
              ksoln0[nn,j,w,cb,cv,ff,mm,*] = result
            ENDFOR
          ENDFOR
        ENDFOR
      ENDFOR
    ENDFOR
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate rest frame parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Output should be an [N,F,M,S]-element [numeric] array
IF (med_on[0]) THEN BEGIN
  ;;  Use median instead of mean
  kbar           = MEDIAN(MEDIAN(MEDIAN(MEDIAN(REAL_PART(ksoln0),DIMENSION=5),DIMENSION=4),DIMENSION=3),DIMENSION=2)
ENDIF ELSE BEGIN
  kbar           = MEAN(MEAN(MEAN(MEAN(REAL_PART(ksoln0),/NAN,DIMENSION=5),/NAN,DIMENSION=4),/NAN,DIMENSION=3),/NAN,DIMENSION=2)
ENDELSE
;;  Define |k| [m^(-1)]
kmag           = REPLICATE(d,nv[0],2L,2L,3L)               ;;  [N,F,M,S]-elements
FOR ff=0L, 1L DO FOR mm=0L, 1L DO FOR ss=0L, 2L DO kmag[*,ff,mm,ss] = kbar[*,ff,mm,ss]/L_e[*,1L]
;;  Define lambda [m] = 2π/|k|
lambda         = 2d0*!DPI/kmag
;;  Define normalized rest frame frequency Ω = w_rest/wce
;;    Ω = £^2 Cos(theta_kB)/[1 + £^2]
;;    where Ω = w/wce, £ = kc/wpe
wrnor          = REPLICATE(d,nv[0],2L,2L,3L)               ;;  [N,F,M,S]-elements
FOR ff=0L, 1L DO BEGIN
  FOR mm=0L, 1L DO BEGIN
    FOR ss=0L, 2L DO BEGIN
      wrnor[*,ff,mm,ss] = kbar[*,ff,mm,ss]^2d0*REFORM(cothkB[*,1L,mm])/(1d0 + kbar[*,ff,mm,ss]^2d0)
    ENDFOR
  ENDFOR
ENDFOR
;;  Define rest frame frequency f_rest [Hz]
f_rest         = REPLICATE(d,nv[0],2L,2L,3L)               ;;  [N,F,M,S]-elements
FOR ff=0L, 1L DO FOR mm=0L, 1L DO FOR ss=0L, 2L DO f_rest[*,ff,mm,ss] = wrnor[*,ff,mm,ss]*wce[*,1L]/(2d0*!DPI)
;;  Define rest frame phase speed w_rest/|k| [km/s]
Vph_prf        = (2d0*!DPI*f_rest)/kmag*1d-3               ;;  m --> km
;;----------------------------------------------------------------------------------------
;;  Check if user wanted to limit the range of normalized frequencies and wave numbers
;;----------------------------------------------------------------------------------------
;;  Check for w/wce limits
IF (wrnlim[0]) THEN BEGIN
  ;;  Limit by user-defined range of w/wce values
  bad_wrn        = WHERE(ABS(wrnor) LE wrnran[0] OR ABS(wrnor) GE wrnran[1],bd_wrn)
  IF (bd_wrn[0] GT 0) THEN BEGIN
    ;;  Remove values outside user-defined range for w/wce
    kbar[bad_wrn]    = d
    kmag[bad_wrn]    = d
    lambda[bad_wrn]  = d
    wrnor[bad_wrn]   = d
    f_rest[bad_wrn]  = d
    Vph_prf[bad_wrn] = d
  ENDIF
ENDIF
;;  Check for kc/wpe limits
IF (kbrlim[0]) THEN BEGIN
  ;;  Limit by user-defined range of w/wce values
  bad_kbr        = WHERE(ABS(kbar) LE kbrran[0] OR ABS(kbar) GE kbrran[1],bd_kbr)
  IF (bd_kbr[0] GT 0) THEN BEGIN
    ;;  Remove values outside user-defined range for w/wce
    kbar[bad_kbr]    = d
    kmag[bad_kbr]    = d
    lambda[bad_kbr]  = d
    wrnor[bad_kbr]   = d
    f_rest[bad_kbr]  = d
    Vph_prf[bad_kbr] = d
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,kbar
END




























