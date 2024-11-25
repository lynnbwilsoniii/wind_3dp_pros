;+
;*****************************************************************************************
;
;  PROCEDURE:   lbw_calc_relevant_plasma_params.pro
;  PURPOSE  :   This routine returns several characteristic parameters in plasmas as
;                 passive outputs through named variable keywords.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               load_constants_fund_em_atomic_c2014_batch.pro
;               load_constants_extra_part_co2014_ci2015_batch.pro
;               load_constants_astronomical_aa2015_batch.pro
;               is_a_number.pro
;               is_a_3_vector.pro
;               calc_coulomb_collision_rates.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               N1          :  [N]-Element [numeric] array of plasma # densities
;                                for 1st species [with units cm^(-3)]
;               N2          :  [N]-Element [numeric] array of plasma # densities
;                                for 2nd species [with units cm^(-3)]
;               T1          :  [N,3]-Element [numeric] array of plasma temperatures
;                                for 1st species {para,perp, tot} [with units eV]
;               T2          :  [N,3]-Element [numeric] array of plasma temperatures
;                                for 2nd species {para,perp, tot} [with units eV]
;               BO          :  [N]-Element [numeric] array of magnetic field magnitudes
;                                [with units nT]
;               
;
;  EXAMPLES:    
;               [calling sequence]
;               
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               SPECIES1    :  Scalar [integer] defining the first particle species with
;                                the following allowed inputs:
;                                  0  :  Electrons [Default]
;                                  1  :  Protons
;                                  2  :  Alpha-particles
;               SPECIES2    :  Scalar [integer] defining the second particle species with
;                                the following allowed inputs:
;                                  0  :  Electrons
;                                  1  :  Protons [Default]
;                                  2  :  Alpha-particles
;               **********************************
;               ***       DIRECT OUTPUTS       ***
;               **********************************
;               WC1[2]      :  Set to a named variable to return the angular cyclotron
;                                frequency [rad/s] of species 1[2]
;                                ( [N]-Element array )
;               WP1[2]      :  Set to a named variable to return the angular plasma
;                                frequency [rad/s] of species 1[2]
;                                ( [N]-Element array )
;               FC1[2]      :  Set to a named variable to return the cyclotron
;                                frequency [Hz] of species 1[2]
;                                ( [N]-Element array )
;               FP1[2]      :  Set to a named variable to return the plasma
;                                frequency [Hz] of species 1[2]
;                                ( [N]-Element array )
;               VT1[2]      :  Set to a named variable to return the most probable
;                                thermal speeds of species 1[2]
;                                ( [N,3]-Element array )
;               IL1[2]      :  Set to a named variable to return the inertial length [km]
;                                of species 1[2]
;                                ( [N]-Element array )
;               RC1[2]      :  Set to a named variable to return the thermal gyroradii [km]
;                                of species 1[2]
;                                ( [N,3]-Element array )
;               NU_CC__12   :  Set to a named variable to return the binary Coulomb
;                                collision rates between particle species 1 & 2
;                                ( [N]-Element array )
;               L_MFP_12    :  Set to a named variable to return the mean free path for
;                                Coulomb collisions assuming
;                                L_mfp_ab ~ V_rmss / nu_ab
;                                ( [N]-Element array )
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  General and Fundamental Parameter Definitions
;                     epo                            :  Permittivity of free space
;                     kB                             :  Boltzmann constant
;                     ms or m_s                      :  Mass of species s
;                     Ts                             :  Temperature of species s
;                     ns                             :  Number density of species s
;                     qs = Zs e                      :  Charge of species s
;                     Zs or Z_s                      :  Charge state of species s
;               1)  Frequency Definitions
;                     wps^2 = (ns*qs^2)/(epo*ms)     :  plasma frequency of species s
;               2)  Thermal Speed Definitions
;                     V_Ts^2  = 2*kB*Ts/ms           :  1D most probable speed
;                     V_rmss^2 = kB*Ts/ms            :  1D root mean square speed
;                     V_Tab^2  = (V_Ta^2 + V_Tb^2)   :  Effective thermal speed of 2 species
;               3)  Reduced Mass and Charge State Definitions
;                     mu_ab = m_a m_b/(m_a + m_b)    :  Reduced mass of species a and b
;                     zfac_ab = 2^(1/2) Z_a Z_b e^2  :  Effective charge state of 2 species
;               4)  Coulomb Logarithm Definition
;                     numer_ab = (4π epo)*mu_ab*V_Tab^2
;                     denom_ab = zfac_ab * [ (wpa/Vta)^2 + (wpb/Vtb)^2 ]^(1/2)
;                     Lambda_ab = numer_ab/denom_ab  :  Coulomb logarithm of species a and b
;               5)  Coulomb Collision Rate Definition
;                     const_ab                       :  Constant depending on species a and b
;                       const_ee   = C_ee*e^4/[3*(4π epo)^2*mu_ee^2]
;                       const_pp   = C_pp*e^4/[3*(4π epo)^2*mu_pp^2]
;                       const_aa   = C_aa*e^4/[3*(4π epo)^2*mu_aa^2]
;                       const_ep   = C_ep*e^4/[3*(4π epo)^2*mu_ep^2]
;                       const_ea   = C_ea*e^4/[3*(4π epo)^2*mu_ea^2]
;                       const_pa   = C_pa*e^4/[3*(4π epo)^2*mu_pa^2]
;                       C_ee       = 4*[2π]^(1/2)
;                       C_pp       = 4*[2π]^(1/2)
;                       C_aa       = 64*[2π]^(1/2)
;                       C_ep       = 2*[4π]^(1/2)
;                       C_ea       = 8*[4π]^(1/2)
;                       C_pa       = 8*[2π]^(1/2)
;                       factor_ab  = const_ab * n_b * V_Tab^(-3)
;                     nu_ab                          :  Coulomb coll. freq. betwween species a and b
;                                  = factor_ab*ln|Lambda_ab|
;               6)  Symmetries
;                     const_ab  = const_ba
;                     mu_ab     = mu_ba
;                     zfac_ab   = zfac_ba
;                     V_Tab     = V_Tba
;                     Lambda_ab = Lambda_ba
;
;  REFERENCES:  
;               1)  Viñas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               2)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               3)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;               4)  Russell, C.T., J.T. Gosling, R.D. Zwickl, and E.J. Smith (1983),
;                      "Multiple spacecraft observations of interplanetary shocks:  ISEE
;                      Three-Dimensional Plasma Measurements," J. Geophys. Res. 88,
;                      pp. 9941-9947.
;               5)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;               6)  Stix, T.H. (1962), "The Theory of Plasma Waves,"
;                      McGraw-Hill Book Company, USA.
;               7)  See the notes and Refs. in the following Stack Exchange post:
;                     http://physics.stackexchange.com/a/179057/59023
;               8)  2014 CODATA/NIST at:
;                     http://physics.nist.gov/cuu/Constants/index.html
;               9)  2015 Astronomical Almanac at:
;                     http://asa.usno.navy.mil/SecK/Constants.html
;              10)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2018.
;
;   CREATED:  10/10/2024
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/10/2024   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO lbw_calc_relevant_plasma_params,n1,n2,T1,T2,Bo,SPECIES1=species1,SPECIES2=species2,  $
                                    WC1=wc1,WC2=wc2,WP1=wp1,WP2=wp2,                     $       ;;  angular frequencies
                                    FC1=fc1,FC2=fc2,FP1=fp1,FP2=fp2,                     $       ;;  regular frequencies
                                    VT1=vt1,VT2=vt2,                                     $       ;;  thermal speeds
                                    IL1=lambda_1,IL2=lambda_2,                           $       ;;  inertial lengths
                                    RC1=rho_c1,RC2=rho_c2,                               $       ;;  thermal gyroradii
                                    NU_CC__12=nu_cc__12,L_MFP_12=l_mfp_12                        ;;  collision rate values

;;----------------------------------------------------------------------------------------
;;  IDL system and OS stuff
;;----------------------------------------------------------------------------------------
vers           = !VERSION.OS_FAMILY   ;;  e.g., 'unix'
vern           = !VERSION.RELEASE     ;;  e.g., '7.1.1'
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Make sure parallel processing is on
nthreads       = !CPU.HW_NCPU[0]
CPU,TPOOL_MIN_ELTS=10000L,/VECTOR_ENABLE,TPOOL_NTHREADS=nthreads[0]
PREF_SET,'IDL_CPU_TPOOL_NTHREADS',nthreads[0],/COMMIT
PREF_SET,'IDL_CPU_TPOOL_MIN_ELTS',10000L,/COMMIT
PREF_SET,'IDL_CPU_VECTOR_ENABLE',1b,/COMMIT
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
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
;;  Angular frequency factors [results in rad/s]
wcefac         = 1d-9*qq[0]/me[0]
wcpfac         = 1d-9*qq[0]/mp[0]
wcafac         = 2d-9*qq[0]/ma[0]
wpefac         = SQRT(1d6*qq[0]^2d0/(me[0]*epo[0]))
wppfac         = SQRT(1d6*qq[0]^2d0/(mp[0]*epo[0]))
wpafac         = SQRT(4d0*1d6*qq[0]^2d0/(ma[0]*epo[0]))
;;  Frequency factors [results in Hz]
fcefac         = wcefac[0]/(2d0*!DPI)
fcpfac         = wcpfac[0]/(2d0*!DPI)
fcafac         = wcafac[0]/(2d0*!DPI)
fpefac         = wpefac[0]/(2d0*!DPI)
fppfac         = wppfac[0]/(2d0*!DPI)
fpafac         = wpafac[0]/(2d0*!DPI)
neinvf         = (2d0*!DPI)^2d0*epo[0]*me[0]/qq[0]^2d0
;;  Speed factors
vtefac         = SQRT(2d0*eV2J[0]/me[0])*1d-3                   ;;  [km s^(-1) eV^(-1/2)]
vtpfac         = SQRT(2d0*eV2J[0]/mp[0])*1d-3                   ;;  [km s^(-1) eV^(-1/2)]
vtafac         = SQRT(2d0*eV2J[0]/ma[0])*1d-3                   ;;  [km s^(-1) eV^(-1/2)]
valf_fac       = 1d-9/SQRT(1d6*muo[0]*mp[0])*1d-3
cs___fac       = vtpfac[0]*SQRT(mp[0]/(2d0*(mp[0] + me[0])))
;;  Lengths [results in m and km]
ldebyefac      = vtefac[0]/(wpefac[0]*SQRT(2d0))*1d3            ;;  [m eV^(-1/2) cm^(+3)]
linerefac      = c[0]/wpefac[0]*1d-3                            ;;  [km cm^(+3)]
linerpfac      = c[0]/wppfac[0]*1d-3                            ;;  [km cm^(+3)]
linerafac      = c[0]/wpafac[0]*1d-3                            ;;  [km cm^(+3)]
rho_cefac      = vtefac[0]/wcefac[0]                            ;;  [km eV^(-1/2) nT^(-1) ]
rho_cpfac      = vtpfac[0]/wcpfac[0]                            ;;  [km eV^(-1/2) nT^(-1) ]
rho_cafac      = vtafac[0]/wcafac[0]                            ;;  [km eV^(-1/2) nT^(-1) ]
;;  plasma beta factor [N/A]
beta_fac       = 2d0*muo[0]*1d6*eV2J[0]/(1d-9)^2d0
;;  Defaults
def_sp1        = 0               ;;  Default SPECIES1
def_sp2        = 1               ;;  Default SPECIES2
def_spa        = [0,1,2]         ;;  Allowed inputs for SPECIES[1,2]
;;----------------------------------------------------------------------------------------
;;  Error messages
;;----------------------------------------------------------------------------------------
noinput_mssg   = 'Incorrect number of inputs were supplied...'
baddfor_msg    = 'Incorrect input format:  N1[N2], T1[T2], and BO must have the same # of elements in first dimension...'
baddinp_msg    = 'Incorrect input:  N1[N2] and BO must all be [N]-element numeric arrays...'
badTinp_msg    = 'Incorrect input:  T1[T2] must be an [N,3]-element numeric array...'
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 5) OR (is_a_number(n1,/NOMSSG) EQ 0) OR (is_a_number(n2,/NOMSSG) EQ 0) OR      $
                 (is_a_number(bo,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check size of inputs
n_1            = REFORM(n1)
n_2            = REFORM(n2)
b_o            = REFORM(bo)
szdn1          = SIZE(n_1,/DIMENSIONS)
szdn2          = SIZE(n_2,/DIMENSIONS)
szdbo          = SIZE(b_o,/DIMENSIONS)
;;  Make sure data format is okay
test           = (N_ELEMENTS(szdn1) NE 1) OR (N_ELEMENTS(szdn2) NE 1) OR (N_ELEMENTS(szdbo) NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,baddinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
test0          = (is_a_3_vector(T1,V_OUT=T3_1,/NOMSSG) EQ 0) OR (is_a_3_vector(T2,V_OUT=T3_2,/NOMSSG) EQ 0)
szdT1          = SIZE(T3_1,/DIMENSIONS)
szdT2          = SIZE(T3_2,/DIMENSIONS)
test           = (N_ELEMENTS(szdT1) NE 2) OR (N_ELEMENTS(szdT2) NE 2) OR ~test0[0]
IF (test[0]) THEN BEGIN
  MESSAGE,badTinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Make sure data all have N columns
test           = (szdn1[0] NE szdbo[0]) OR (szdn2[0] NE szdbo[0]) OR $
                 (szdT1[0] NE szdbo[0]) OR (szdT2[0] NE szdbo[0])
IF (test[0]) THEN BEGIN
  MESSAGE,baddfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
kk             = szdn1[0]         ;;  # of unique values
ones           = REPLICATE(1d0,kk[0])
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check SPECIES1
test           = (is_a_number(species1,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  spec1 = def_sp1[0]
ENDIF ELSE BEGIN
  test  = (TOTAL(species1[0] EQ def_spa) LT 1)
  IF (test[0]) THEN spec1 = def_sp1[0] ELSE spec1 = species1[0]
ENDELSE
;;  Check SPECIES2
test           = (is_a_number(species2,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  spec2 = def_sp2[0]
ENDIF ELSE BEGIN
  test  = (TOTAL(species2[0] EQ def_spa) LT 1)
  IF (test[0]) THEN spec2 = def_sp2[0] ELSE spec2 = species2[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Determine species-dependent factors
;;----------------------------------------------------------------------------------------
;;  SPECIES1
CASE spec1[0] OF
  0     :  BEGIN
    ;;  Electrons
    wc1fac         = wcefac[0]
    wp1fac         = wpefac[0]
    fc1fac         = fcefac[0]
    fp1fac         = fpefac[0]
    vt1fac         = vtefac[0]
    il1fac         = linerefac[0]
    rc1fac         = rho_cefac[0]
  END
  1     :  BEGIN
    ;;  Protons
    wc1fac         = wcpfac[0]
    wp1fac         = wppfac[0]
    fc1fac         = fcpfac[0]
    fp1fac         = fppfac[0]
    vt1fac         = vtpfac[0]
    il1fac         = linerpfac[0]
    rc1fac         = rho_cpfac[0]
  END
  2     :  BEGIN
    ;;  Alpha-particles
    wc1fac         = wcafac[0]
    wp1fac         = wpafac[0]
    fc1fac         = fcafac[0]
    fp1fac         = fpafac[0]
    vt1fac         = vtafac[0]
    il1fac         = linerafac[0]
    rc1fac         = rho_cafac[0]
  END
  ELSE  :  STOP     ;;  Should NOT happen!
ENDCASE
;;  SPECIES2
CASE spec1[0] OF
  0     :  BEGIN
    ;;  Electrons
    wc2fac         = wcefac[0]
    wp2fac         = wpefac[0]
    fc2fac         = fcefac[0]
    fp2fac         = fpefac[0]
    vt2fac         = vtefac[0]
    il2fac         = linerefac[0]
    rc2fac         = rho_cefac[0]
  END
  1     :  BEGIN
    ;;  Protons
    wc2fac         = wcpfac[0]
    wp2fac         = wppfac[0]
    fc2fac         = fcpfac[0]
    fp2fac         = fppfac[0]
    vt2fac         = vtpfac[0]
    il2fac         = linerpfac[0]
    rc2fac         = rho_cpfac[0]
  END
  2     :  BEGIN
    ;;  Alpha-particles
    wc2fac         = wcafac[0]
    wp2fac         = wpafac[0]
    fc2fac         = fcafac[0]
    fp2fac         = fpafac[0]
    vt2fac         = vtafac[0]
    il2fac         = linerafac[0]
    rc2fac         = rho_cafac[0]
  END
  ELSE  :  STOP     ;;  Should NOT happen!
ENDCASE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  SPECIES1
bmag2d         = (b_o # ones)
den12d         = (n_1 # ones)
beta__1_aet    = beta_fac[0]*den12d*T3_1/bmag2d^2d0                 ;;  beta_1 [N/A, {para,perp, tot}]
wc1            = wc1fac[0]*b_o                                      ;;  wc1 [rad/s]
wp1            = wp1fac[0]*SQRT(n_1)                                ;;  wp1 [rad/s]
fc1            = fc1fac[0]*b_o                                      ;;  fc1 [Hz]
fp1            = fp1fac[0]*SQRT(n_1)                                ;;  fp1 [Hz]
vt1            = vt1fac[0]*SQRT(T3_1)                               ;;  V_T1 [km/s, {para,perp, tot}]  (most probable speed)
lambda_1       = il1fac[0]/SQRT(n_1)                                ;;  c/wp1 [km]
rho_c1         = rc1fac[0]*SQRT(T3_1)/bmag2d^2d0                    ;;  rho_c1 [km, {para,perp, tot}]
;;----------------------------------------------------------------------------------------
;;  SPECIES2
;;----------------------------------------------------------------------------------------
den22d         = (n_2 # ones)
beta__2_aet    = beta_fac[0]*den22d*T3_2/bmag2d^2d0                 ;;  beta_2 [N/A, {para,perp, tot}]
wc2            = wc2fac[0]*b_o                                      ;;  wc2 [rad/s]
wp2            = wp2fac[0]*SQRT(n_2)                                ;;  wp2 [rad/s]
fc2            = fc2fac[0]*b_o                                      ;;  fc2 [Hz]
fp2            = fp2fac[0]*SQRT(n_2)                                ;;  fp2 [Hz]
vt2            = vt2fac[0]*SQRT(T3_2)                               ;;  V_T2 [km/s, {para,perp, tot}]  (most probable speed)
lambda_2       = il2fac[0]/SQRT(n_2)                                ;;  c/wp2 [km]
rho_c2         = rc2fac[0]*SQRT(T3_2)/bmag2d^2d0                    ;;  rho_c2 [km, {para,perp, tot}]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate Coulomb collision rate parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
nu_cc__12      = calc_coulomb_collision_rates(n_1,n_2,T3_1[*,2],T3_2[*,2],              $
                                              SPECIES1=spec1[0],SPECIES2=spec1[0],      $
                                              L_MFP_12=l_mfp_12)

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN
END















