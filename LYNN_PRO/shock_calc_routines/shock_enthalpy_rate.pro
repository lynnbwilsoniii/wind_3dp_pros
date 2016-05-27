;+
;*****************************************************************************************
;
;  FUNCTION :   shock_enthalpy_rate.pro
;  PURPOSE  :   This routine numerically solves the shock pressure ratio for a magneto-
;                 sonic shock wave propagating at an oblique angle to the upstream
;                 average magnetic field.  An analytic expression can be found in
;                 Gurnett and Bhattacharjee, [2005], Equation 7.3.57.
;
;                 Next, the routine uses that pressure ratio to numerically estimate
;                 the change in specific entropy across an oblique magnetosonic shock
;                 wave.  An analytic expression can be found in Gurnett and
;                 Bhattacharjee, [2005], Equation 7.3.56.
;
;                 The routine uses observations to estimate the shock pressure ratio
;                 and then, in turn, estimate a corresponding change in specific entropy.
;                 Both change in specific entropy results are used to estimate a change
;                 in enthalpy density.  The change in enthalpy density with respect to
;                 time is a measure of the change in total interal energy density with
;                 respect to time or a measure of the total energy density dissipated
;                 across the shock.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_dot_prod.pro
;               shock_pressure_ratio.pro
;               shock_entropy_change.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               N[1,2]   :  [N]-Element [float] array of [upstream,downstream] particle
;                             number densities [cm^(-3)]
;               T[e,i]1  :  [N]-Element [float] array of [electron,ion] average upstream
;                             temperatures [eV]
;               T[e,i]2  :  [N]-Element [float] array of [electron,ion] average
;                             downstream temperatures [eV]
;               BV1      :  [N,3]-Element [float] array of average upstream quasi-static
;                             magnetic field vectors [nT]
;               UN1      :  Scalar [float] defining the upstream shock normal flow speed
;                             in the shock rest frame [km/s]
;               DUN1     :  Scalar [float] defining the uncertainty in UN1 [km/s]
;               NVEC     :  [3]-Element [float] array defining the shock normal vector
;               DNVEC    :  [3]-Element [float] array defining the uncertainty in NVEC
;               DT       :  Scalar [double] defining the shock ramp duration [s]
;
;  EXAMPLES:    
;               test = shock_enthalpy_rate(n1,n2,te1,ti1,te2,ti2,bv1,un1,dun1,nv,dnv,dt)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed typo in structure tag assignment for THEORIES tags
;                                                                 [02/11/2013   v1.1.0]
;
;   NOTES:      
;               1)  This routine estimates average dissipation rates for a magnetosonic
;                     shock wave assuming Rankine-Hugoniot relations are satisfied.
;                     These rates are derived from the thermodynamic relation between
;                     entropy change and enthalpy change.
;
;  REFERENCES:  
;               1)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;
;   CREATED:  02/05/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/11/2013   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION shock_enthalpy_rate,n1,n2,te1,ti1,te2,ti2,bv1,un1,dun1,nvec,dnvec,dt

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epo            = 8.854187817d-12        ;; => Permittivity of free space (F/m)
muo            = 4d0*!DPI*1d-7          ;; => Permeability of free space (N/A^2 or H/m)
me             = 9.10938291d-31         ;; => Electron mass (kg) [2010 value]
mp             = 1.672621777d-27        ;; => Proton mass (kg) [2010 value]
qq             = 1.602176565d-19        ;; => Fundamental charge (C) [2010 value]
kB             = 1.3806488d-23          ;; => Boltzmann Constant (J/K) [2010 value]
K_eV           = 1.1604519d4            ;; => Factor [Kelvin/eV] [2010 value]
c              = 2.99792458d8           ;; => Speed of light in vacuum (m/s)
eV_to_J        = kB[0]*K_eV[0]          ;; => Conversion from eV to J
press_fac      = eV_to_J[0]*1d6         ;;  eV --> J, cm^(-3) --> m^(-3)
rho_fac        = (me[0] + mp[0])*1d6    ;;  kg, cm^(-3) --> m^(-3)
kB_mass        = kB[0]/(me[0] + mp[0])  ;;  specific entropy factor [J K^(-1) kg^(-1)]
diss_fac       = K_eV[0]*1d6            ;;  eV --> deg K, cm^(-3) --> m^(-3)
;;  Define polytrope index [ratio of specific heats]
;;    gam[0]  :  6 degrees of freedom
;;    gam[1]  :  monatomic gas
;;    gam[2]  :  diatomic gas
gam            = [[4d0,5d0]/3d0,7d0/5d0]
;;  Factor used for ± uncertainty estimates
nfac           = [-1d0,0d0,1d0]
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 12) THEN RETURN,0

test1          = (N_ELEMENTS(n1)   NE N_ELEMENTS(n2) ) OR (N_ELEMENTS(te1)   NE    N_ELEMENTS(ti1))
test2          = (N_ELEMENTS(te2)  NE N_ELEMENTS(ti2)) OR (N_ELEMENTS(bv1)   NE 3L*N_ELEMENTS(n1) )
test3          = (N_ELEMENTS(n1)   NE N_ELEMENTS(te1)) OR (N_ELEMENTS(n2)    NE    N_ELEMENTS(ti1))
test4          = (N_ELEMENTS(n1)   NE N_ELEMENTS(te2)) OR (N_ELEMENTS(n2)    NE    N_ELEMENTS(ti2))
test5          = (N_ELEMENTS(nvec) NE              3L) OR (N_ELEMENTS(dnvec) NE                 3L)
test6          = test1 OR test2 OR test3 OR test4 OR test5

IF (test5) THEN RETURN,-1
;;----------------------------------------------------------------------------------------
;; => Reform input
;;----------------------------------------------------------------------------------------
Nou            = REFORM(n1)
Nod            = REFORM(n2)
Teu            = REFORM(te1)
Tiu            = REFORM(ti1)
Ted            = REFORM(te2)
Tid            = REFORM(ti2)
Bvu            = REFORM(bv1)

Unu            = un1[0]
d_Unu          = dun1[0]
nv             = REFORM(nvec)
d_nv           = REFORM(dnvec)
del_t          = dt[0]

n              = N_ELEMENTS(Nou)
;;----------------------------------------------------------------------------------------
;; => Calculate parameters
;;----------------------------------------------------------------------------------------
;;  Define upstream/downstream mass density [kg m^(-3)] and total temperature [K]
rho_up         = rho_fac[0]*Nou           ;;  [kg m^(-3)]
rho_dn         = rho_fac[0]*Nod           ;;  [kg m^(-3)]
;;  Define total upstream/downstream temperature [eV]
temp_up        = (Teu + Tiu)              ;;  [eV]
temp_dn        = (Ted + Tid)              ;;  [eV]
;;  Define change in mass density [kg m^(-3)] and total temperature [K]
diff_rho       = rho_dn - rho_up          ;;  mass density change [kg m^(-3)]
;;  Define upstream/downstream electron thermal pressures [J m^(-3)]
Pe_up          = Nou*Teu*press_fac[0]
Pe_dn          = Nod*Ted*press_fac[0]
;;  Define upstream/downstream ion thermal pressures [J m^(-3)]
Pi_up          = Nou*Tiu*press_fac[0]
Pi_dn          = Nod*Tid*press_fac[0]
;;  Define upstream/downstream total thermal pressures [J m^(-3)]
Press_up       = Pe_up + Pi_up
Press_dn       = Pe_dn + Pi_dn
;;  Define |Bo| [nT]
Bo_up          = SQRT(TOTAL(Bvu^2,2L,/NAN))
Bo_2d_up       = Bo_up # REPLICATE(1d0,3L)
;;  Define Bo/|Bo| [unitless]
bvec_up        = Bvu/Bo_2d_up
;;----------------------------------------------------------------------------------------
;;  Define empty arrays for later use
;;----------------------------------------------------------------------------------------
nsh            = DBLARR(3,3)              ;;  shock normal vectors
Ushn           = DBLARR(3)                ;;  shock normal speeds [km/s, SCF]
theta_Bn       = DBLARR(n,3)              ;;  shock normal angles [deg]
press_ratio    = DBLARR(n,3,3,3)          ;;  pressure ratio jump [shock adiabat Eq., unitless]
entropy        = DBLARR(n,3,3,3)          ;;  change in specific entropy, ∆s [shock adiabat Eq., J K^(-1) kg^(-1)]
entropy_obs    = DBLARR(n,3)              ;;  " " using observed pressure ratios
Cs_up          = DBLARR(n,3)              ;;  upstream sound speed [m/s]
diss_rate      = DBLARR(n,3,3,3)          ;;  dissipation rate due to ∆s [from shock adiabat Eq., µW m^(-3)]
diss_rate_obs  = DBLARR(n,3)              ;;  " " using observed pressure ratios
work_rate      = DBLARR(n,3)              ;;  rate of work done to displace/compress plasma [µW m^(-3)]
enthalpy       = DBLARR(n,3,3,3)          ;;  rate of change of specific enthalpy, ∆h [from shock adiabat Eq., µW m^(-3)]
enthalpy_obs   = DBLARR(n,3)              ;;  " " using observed pressure ratios
;;----------------------------------------------------------------------------------------
;;  Define shock normal vector ranges = n ± ∂n and
;;    shock normal speed ranges = Un ± ∂Un
;;----------------------------------------------------------------------------------------
FOR j=0L, 2L DO BEGIN
  nsh[j,*] = nv + nfac[j]*d_nv
  ;;  Normalize n ± ∂n
  nsh[j,*] = nsh[j,*]/NORM(REFORM(nsh[j,*]))
  ;;  Un ± ∂Un
  Ushn[j]  = ABS(Unu[0]) + nfac[j]*ABS(d_Unu[0])
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define upstream sound speed [m/s]
;;    Cs^(2) = ¥ P_up/rho_up
;;----------------------------------------------------------------------------------------
FOR i=0L, 2L DO Cs_up[*,i] = SQRT(gam[i]*Press_up/rho_up)
;;----------------------------------------------------------------------------------------
;;  Calculate shock normal angles
;;----------------------------------------------------------------------------------------
FOR j=0L, 2L DO BEGIN
  n00           = REFORM(nsh[j,*])
  ;;  (B . n)
  bdn_00        = my_dot_prod(bvec_up,n00,/NOM)
  ;;  ø_Bn = Cos^(-1) [(B . n)/|B|]
  temp          = ACOS(bdn_00)*18d1/!DPI
  ;;  Force 0 ≤ ø_Bn ≤ 90
  theta_Bn[*,j] = temp < (18d1 - temp)
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define pressure ratio jump [from shock adiabat Eq., unitless] and
;;    specific entropy change, ∆s [from shock adiabat Eq., J K^(-1) kg^(-1)]
;;
;;       [N,I,J,K]-Element array
;;         N  :  # of upstream/downstream plasma parameter values
;;         I  :  # of different shock normal speeds [km/s, SCF] to consider
;;         J  :  # of different shock normal angles [deg] due to J shock normal vectors
;;         K  :  # of polytrope indices used
;;----------------------------------------------------------------------------------------
FOR i=0L, 2L DO BEGIN
  FOR j=0L, 2L DO BEGIN
    FOR k=0L, 2L DO BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  P_dn/P_up
      ;;----------------------------------------------------------------------------------
      ;;  make sure # of elements for each array match
      un0  = REPLICATE(Ushn[i],n)
      thbn = REFORM(theta_Bn[*,j])
      temp = shock_pressure_ratio(Nou,Nod,Teu,Tiu,un0,Bo_up,thbn,gam[k])
      IF (N_ELEMENTS(temp) NE n) THEN STOP
      press_ratio[*,i,j,k] = temp
      temp = 0
      ;;----------------------------------------------------------------------------------
      ;;  ∆s = C_v ln| (P_dn/P_up) * (rho_up/rho_dn)^¥ |
      ;;----------------------------------------------------------------------------------
      temp = shock_entropy_change(Nou,Nod,Teu,Tiu,un0,Bo_up,thbn,gam[k])
      IF (N_ELEMENTS(temp) NE n) THEN STOP
      entropy[*,i,j,k] = temp
      temp = 0
    ENDFOR
  ENDFOR
ENDFOR
;;  Remove ∆s < 0 terms
bad            = WHERE(entropy LT 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0) THEN BEGIN
  ;;  Set negative entropy changes to NaNs
  entropy[bad] = d
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define pressure and density ratio jump [from measurements, unitless] and
;;    specific entropy change, ∆s [from measurements, J K^(-1) kg^(-1)]
;;----------------------------------------------------------------------------------------
;;  Define density and pressure ratio jumps [measurements, unitless]
Press_rat_obs  = Press_dn/Press_up
dens_rat_obs   = Nod/Nou
FOR k=0L, 2L DO BEGIN
  ;;  C_v = specific heat at constant volume
  c_v_fac          = kB_mass[0]/(gam[k] - 1d0)
  ;;  (P_dn/P_up) * (rho_up/rho_dn)^¥  [¥ = polytrope index]
  term1            = ABS(Press_rat_obs/(dens_rat_obs^gam[k]))
  ;;  ∆s = C_v ln| (P_dn/P_up) * (rho_up/rho_dn)^¥ |
  entropy_obs[*,k] = c_v_fac[0]*ALOG(term1)
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define energy dissipation rate due to entropy change [µW m^(-3)]
;;    ∆∑ = (ƒ T ∆s)/∆t
;;    [ƒ = rho_up, T = (Te_up + Ti_up), ∆t = shock duration]
;;----------------------------------------------------------------------------------------
term0          = (rho_up*temp_up)*diss_fac[0]/del_t[0]
;;  from measurements
FOR k=0L,     2L DO diss_rate_obs[*,k] = term0*entropy_obs[*,k]
;;  from theory
FOR i=0L, n - 1L DO diss_rate[i,*,*,*] = term0[i]*entropy[i,*,*,*]
;;----------------------------------------------------------------------------------------
;;  Define rate of work done to displace plasma
;;    ∆W/∆t = Cs^(2) ∆ƒ/∆t  [µW m^(-3)]
;;    [∆ƒ = (rho_dn - rho_up)]
;;----------------------------------------------------------------------------------------
term0          = diff_rho/del_t[0]*1d6
FOR i=0L, 2L DO work_rate[*,i] = ABS(Cs_up[*,i])^2*term0
;;----------------------------------------------------------------------------------------
;;  Define specific enthalpy change, ∆h, per unit time, ∆t  [µW m^(-3)]
;;    ∆h/∆t = (ƒ T ∆s)/∆t  +  Cs^(2) ∆ƒ/∆t
;;----------------------------------------------------------------------------------------
;;  from measurements
FOR k=0L, 2L DO enthalpy_obs[*,k] = diss_rate_obs[*,k] + work_rate[*,k]
;;  from theory
FOR i=0L, 2L DO BEGIN
  FOR j=0L, 2L DO BEGIN
    FOR k=0L, 2L DO BEGIN
      enthalpy[*,i,j,k] = diss_rate[*,i,j,k] + work_rate[*,k]
    ENDFOR
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Avg. ∆s, ∆∑, ∆W/∆t, and ∆h/∆t over the N-plasma terms [µW m^(-3)]
;;----------------------------------------------------------------------------------------
;;  ∆s [from measurements]
sum            = TOTAL(entropy_obs,1,/NAN)    ;; [K]-Element array
num            = TOTAL(FINITE(entropy_obs),1,/NAN)
avg_entro_obs  = sum/num
;;  ∆s [from theory]
sum            = TOTAL(entropy,1,/NAN)    ;; [K]-Element array
num            = TOTAL(FINITE(entropy),1,/NAN)
avg_entropy    = sum/num
;;  ∆∑ [from measurements]
sum            = TOTAL(diss_rate_obs,1,/NAN)    ;; [K]-Element array
num            = TOTAL(FINITE(diss_rate_obs),1,/NAN)
avg_dissr_obs  = sum/num
;;  ∆∑ [from theory]
sum            = TOTAL(diss_rate,1,/NAN)    ;; [I,J,K]-Element array
num            = TOTAL(FINITE(diss_rate),1,/NAN)
avg_diss_rate  = sum/num
;;  ∆W/∆t [from measurements]
sum            = TOTAL(work_rate,1,/NAN)    ;; [K]-Element array
num            = TOTAL(FINITE(work_rate),1,/NAN)
avg_work_rate  = sum/num
;;  ∆h/∆t [from measurements]
sum            = TOTAL(enthalpy_obs,1,/NAN)    ;; [K]-Element array
num            = TOTAL(FINITE(enthalpy_obs),1,/NAN)
avg_enthl_obs  = sum/num
;;  ∆h/∆t [from theory]
sum            = TOTAL(enthalpy,1,/NAN)    ;; [K]-Element array
num            = TOTAL(FINITE(enthalpy),1,/NAN)
avg_enthalpy   = sum/num
;;----------------------------------------------------------------------------------------
;;  Create dummy structure to return to user
;;----------------------------------------------------------------------------------------
;;  Define shock parameters structure
str_element,sh_param,          'NVEC',          nsh,/ADD_REPLACE
str_element,sh_param,          'USHN',         Ushn,/ADD_REPLACE
str_element,sh_param,      'THETA_BN',     theta_Bn,/ADD_REPLACE
;;----------------------------------------------
;;  Define observation results structure
;;----------------------------------------------
;;  Define ∆ƒ, ƒ_dn/ƒ_up
str_element,observed,     'DELTA_RHO',     diff_rho,/ADD_REPLACE
str_element,observed,     'RHO_RATIO', dens_rat_obs,/ADD_REPLACE
;;  Define P_up, P_dn, and P_dn/P_up [measurements]
str_element,observed,    'PRESS_T_UP',     Press_up,/ADD_REPLACE
str_element,observed,    'PRESS_T_DN',     Press_dn,/ADD_REPLACE
str_element,observed,   'PRESS_RATIO',Press_rat_obs,/ADD_REPLACE
;;  Define Cs_up [measurements]
str_element,observed,         'CS_UP',        Cs_up,/ADD_REPLACE
;;  Define ∆W/∆t [measurements]
str_element,observed,     'WORK_RATE',    work_rate,/ADD_REPLACE
;;  Define ∆s [measurements]
str_element,observed, 'DELTA_ENTROPY',  entropy_obs,/ADD_REPLACE
;;  Define ∆∑ [measurements]
str_element,observed,     'DISS_RATE',diss_rate_obs,/ADD_REPLACE
;;  Define ∆h/∆t [measurements]
str_element,observed,'DELTA_ENTHALPY', enthalpy_obs,/ADD_REPLACE
;;  Define Avg. ∆∑, ∆W/∆t, and ∆h/∆t [measurements]
str_element,observed, 'AVG_WORK_RATE',avg_work_rate,/ADD_REPLACE
str_element,observed, 'AVG_D_ENTROPY',avg_entro_obs,/ADD_REPLACE
str_element,observed, 'AVG_DISS_RATE',avg_dissr_obs,/ADD_REPLACE
str_element,observed,'AVG_D_ENTHALPY',avg_enthl_obs,/ADD_REPLACE
;;----------------------------------------------
;;  Define theory results structure
;;----------------------------------------------
;;  Define P_dn/P_up [theory]
str_element,theories,   'PRESS_RATIO',  press_ratio,/ADD_REPLACE
;;  Define ∆s [theory]
str_element,theories, 'DELTA_ENTROPY',      entropy,/ADD_REPLACE
;;  Define ∆∑ [theory]
str_element,theories,     'DISS_RATE',    diss_rate,/ADD_REPLACE
;;  Define ∆h/∆t [theory]
str_element,theories,'DELTA_ENTHALPY',     enthalpy,/ADD_REPLACE
;;  Define Avg. ∆∑, ∆W/∆t, and ∆h/∆t [theory]
str_element,theories, 'AVG_D_ENTROPY',  avg_entropy,/ADD_REPLACE
str_element,theories, 'AVG_DISS_RATE',avg_diss_rate,/ADD_REPLACE
str_element,theories,'AVG_D_ENTHALPY', avg_enthalpy,/ADD_REPLACE
;;----------------------------------------------
;;  Define dummy structure
;;----------------------------------------------
str_element,dummy,         'SH_PARAM',     sh_param,/ADD_REPLACE
str_element,dummy,         'OBSERVED',     observed,/ADD_REPLACE
str_element,dummy,         'THEORIES',     theories,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;; => Return dummy structure to user
;;----------------------------------------------------------------------------------------

RETURN,dummy
END
