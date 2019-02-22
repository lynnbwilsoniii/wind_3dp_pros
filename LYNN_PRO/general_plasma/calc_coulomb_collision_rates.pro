;+
;*****************************************************************************************
;
;  FUNCTION :   calc_coulomb_collision_rates.pro
;  PURPOSE  :   This routine calculates the Coulomb collision frequency from two arrays
;                 of input densities and temperatures with species identified through
;                 user defined keyword settings.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               lbw__add.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DENS_1      :  [N]-Element [numeric] array of first particle species
;                                number densities [# cm^(-3)]
;               DENS_2      :  [N]-Element [numeric] array of second particle species
;                                number densities [# cm^(-3)]
;               TEMP_1      :  [N]-Element [numeric] array of first particle species
;                                temperatures [eV]
;               TEMP_2      :  [N]-Element [numeric] array of second particle species
;                                temperatures [eV]
;
;  EXAMPLES:    
;               [calling sequence]
;               nu12 = calc_coulomb_collision_rates(dens_1,dens_2,temp_1,temp_2, $
;                                      [,SPECIES1=species1] [,SPECIES2=species2] $
;                                      [,L_MFP_12=l_mfp_12])
;
;  KEYWORDS:    
;               ***  INPUTS  ***
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
;               ***  OUTPUTS  ***
;               L_MFP_12    :  Set to a named variable to return the mean free path for
;                                Coulomb collisions assuming
;                                L_mfp_ab ~ V_rmss / nu_ab
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
;               0)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2018.
;
;   CREATED:  02/12/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/12/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_coulomb_collision_rates,dens_1,dens_2,temp_1,temp_2,                $
                                      SPECIES1=species1,SPECIES2=species2,        $
                                      L_MFP_12=l_mfp_12

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
;;  Astronomical lengths
R_Ea__m        = 6.3781366d06             ;;  Earth's Mean Equatorial Radius [m, 2015 AA values]
R_E            = R_Ea__m[0]*1d-3          ;;  m --> km
au             = 1.49597870700d+11        ;;  1 astronomical unit or AU [m, from Mathematica 10.1 on 2015-04-21]
aukm           = au[0]*1d-3               ;;  m --> km
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;    Speed and Frequency
vtefac         = SQRT(2d0*eV2J[0]/me[0])
vtpfac         = SQRT(2d0*eV2J[0]/mp[0])
vtafac         = SQRT(2d0*eV2J[0]/ma[0])
wpefac         = SQRT(1d0*qq[0]^2d0/(me[0]*epo[0]))
wppfac         = SQRT(1d0*qq[0]^2d0/(mp[0]*epo[0]))
wpafac         = SQRT(4d0*qq[0]^2d0/(ma[0]*epo[0]))
wpsfac         = [wpefac[0],wppfac[0],wpafac[0]]
vtsfac         = [vtefac[0],vtpfac[0],vtafac[0]]
;;  Calculate the reduced masses
;;        mu_ab = m_a m_b/(m_a + m_b)
mu_ee          = me[0]*me[0]/(me[0] + me[0])
mu_pp          = mp[0]*mp[0]/(mp[0] + mp[0])
mu_aa          = ma[0]*ma[0]/(ma[0] + ma[0])
mu_ep          = me[0]*mp[0]/(me[0] + mp[0])
mu_ea          = me[0]*ma[0]/(me[0] + ma[0])
mu_pa          = ma[0]*mp[0]/(ma[0] + mp[0])
;;  Calculate charge state contributions
;;         zfac_ab = 2^(1/2) |Z_a| |Z_b| e^2
zfac___ee      = SQRT(2d0)*qq[0]^2d0
zfac___ep      = SQRT(2d0)*qq[0]^2d0
zfac___pp      = SQRT(2d0)*qq[0]^2d0
zfac___pa      = SQRT(2d0)*2d0*qq[0]^2d0
zfac___ea      = SQRT(2d0)*2d0*qq[0]^2d0
zfac___aa      = SQRT(2d0)*4d0*qq[0]^2d0
;;  Constant for collision frequency used later
fac0           =  3d0*(4d0*!DPI*epo[0])^2d0            ;;  ~3.71397 x 10^(-20)
const_ee       =  4d0*SQRT(2d0*!DPI)*qq[0]^4d0/fac0[0]/mu_ee[0]^2d0
const_pp       =  4d0*SQRT(2d0*!DPI)*qq[0]^4d0/fac0[0]/mu_pp[0]^2d0
const_aa       = 64d0*SQRT(2d0*!DPI)*qq[0]^4d0/fac0[0]/mu_aa[0]^2d0
const_ep       =  2d0*SQRT(4d0*!DPI)*qq[0]^4d0/fac0[0]/mu_ep[0]^2d0
const_ea       =  8d0*SQRT(4d0*!DPI)*qq[0]^4d0/fac0[0]/mu_ea[0]^2d0
const_pa       =  8d0*SQRT(2d0*!DPI)*qq[0]^4d0/fac0[0]/mu_pa[0]^2d0
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
notnum_msg     = 'DENS_[1,2] and TEMP_[1,2] must be of numeric type...'
badfor_msg     = 'DENS_[1,2] and TEMP_[1,2] must all be [N]-element numeric arrays...'
;;  Defaults
def_sp1        = 0               ;;  Default SPECIES1
def_sp2        = 1               ;;  Default SPECIES2
def_spa        = [0,1,2]         ;;  Allowed inputs for SPECIES[1,2]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 4) THEN BEGIN
  ;;  no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
nn1            = dens_1[0]
nn2            = dens_2[0]
tt1            = temp_1[0]
tt2            = temp_2[0]
test           = (is_a_number(nn1,/NOMSSG) EQ 0) OR (is_a_number(nn2,/NOMSSG) EQ 0) OR $
                 (is_a_number(tt1,/NOMSSG) EQ 0) OR (is_a_number(tt2,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,notnum_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define params
nn1            = REFORM(dens_1,N_ELEMENTS(dens_1))*1d6      ;;  n_s1 [# m^(-3)]
nn2            = REFORM(dens_2,N_ELEMENTS(dens_2))*1d6      ;;  n_s2 [# m^(-3)]
tt1            = REFORM(temp_1,N_ELEMENTS(temp_1))          ;;  T_s1 [eV]
tt2            = REFORM(temp_2,N_ELEMENTS(temp_2))          ;;  T_s2 [eV]
n1             = N_ELEMENTS(nn1)
n2             = N_ELEMENTS(nn2)
t1             = N_ELEMENTS(tt1)
t2             = N_ELEMENTS(tt2)
test           = (n1[0] NE n2[0]) OR (t1[0] NE t2[0]) OR (n1[0] NE t1[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
nn             = n1[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords
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
CASE spec1[0] OF
  0     :  BEGIN
    CASE spec2[0] OF
      0     :  BEGIN
        ;;  ee
        zfactor = zfac___ee
        mufac   = mu_ee
        const   = const_ee
      END
      1     :  BEGIN
        ;;  ep
        zfactor = zfac___ep
        mufac   = mu_ep
        const   = const_ep
      END
      2     :  BEGIN
        ;;  ea
        zfactor = zfac___ea
        mufac   = mu_ea
        const   = const_ea
      END
      ELSE  :  STOP     ;;  Should NOT happen!
    ENDCASE
  END
  1     :  BEGIN
    CASE spec2[0] OF
      0     :  BEGIN
        ;;  pe
        zfactor = zfac___ep
        mufac   = mu_ep
        const   = const_ep
      END
      1     :  BEGIN
        ;;  pp
        zfactor = zfac___pp
        mufac   = mu_pp
        const   = const_pp
      END
      2     :  BEGIN
        ;;  pa
        zfactor = zfac___pa
        mufac   = mu_pa
        const   = const_pa
      END
      ELSE  :  STOP     ;;  Should NOT happen!
    ENDCASE
  END
  2     :  BEGIN
    CASE spec2[0] OF
      0     :  BEGIN
        ;;  ae
        zfactor = zfac___ea
        mufac   = mu_ea
        const   = const_ea
      END
      1     :  BEGIN
        ;;  ap
        zfactor = zfac___pa
        mufac   = mu_pa
        const   = const_pa
      END
      2     :  BEGIN
        ;;  aa
        zfactor = zfac___aa
        mufac   = mu_aa
        const   = const_aa
      END
      ELSE  :  STOP     ;;  Should NOT happen!
    ENDCASE
  END
  ELSE  :  STOP     ;;  Should NOT happen!
ENDCASE
;;  Define frequency and thermal speed conversion factors
wps1fac        = wpsfac[spec1[0]]
wps2fac        = wpsfac[spec2[0]]
vts1fac        = vtsfac[spec1[0]]
vts2fac        = vtsfac[spec2[0]]
;;----------------------------------------------------------------------------------------
;;  Define plasma frequencies [rad/s] and thermal speeds (most probable speeds) [m/s]
;;----------------------------------------------------------------------------------------
wps1           = wps1fac[0]*SQRT(nn1)
wps2           = wps2fac[0]*SQRT(nn2)
vts1           = vts1fac[0]*SQRT(tt1)
vts2           = vts2fac[0]*SQRT(tt2)
;;----------------------------------------------------------------------------------------
;;  Calculate effective thermal speeds [m s^(-1)]
;;        V_Tab = [ V_Ta^2 + V_Tb^2 ]^(1/2)
;;----------------------------------------------------------------------------------------
temp           = lbw__add(vts1^2d0,vts2^2d0,/NAN)
vt_s12         = SQRT(temp)
;;----------------------------------------------------------------------------------------
;;  Calculate Coulomb logarithm parameter
;;----------------------------------------------------------------------------------------
;;         numer_ab = (4π eps_o)*mu_ab*V_Tab^2
fac0           = (4d0*!DPI*epo[0])
numer_s12      = fac0[0]*mufac[0]*vt_s12^2d0
;;    denom_ab = [ (wpa/Vta)^2 + (wpb/Vtb)^2 ]^(1/2)
temp           = lbw__add((wps1/vts1)^2d0,(wps2/vts2)^2d0,/NAN)
denom_s12      = SQRT(temp)
;;    Lambda_ab = numer_ab/(zfac_ab * denom_ab)
lambd_s12      = numer_s12/(zfactor[0]*denom_s12)
;;----------------------------------------------------------------------------------------
;;  Calculate particle collision rates [# s^(-1)]
;;----------------------------------------------------------------------------------------
;;  nu_ab = const_ab * n_b * V_Tab^(-3) * ln | Lambda_ab |
nu___s12       = const[0]*nn2*ALOG(ABS(lambd_s12))/vt_s12^3d0
;;----------------------------------------------------------------------------------------
;;  Calculate particle mean free path [# s^(-1)]
;;----------------------------------------------------------------------------------------
;;  L_mfp_ab ~ V_rmss / nu_ab
l_mfp_12       = vt_s12/nu___s12/SQRT(2d0)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,nu___s12
END






















