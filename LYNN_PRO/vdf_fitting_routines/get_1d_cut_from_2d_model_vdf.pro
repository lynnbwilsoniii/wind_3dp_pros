;+
;*****************************************************************************************
;
;  FUNCTION :   get_1d_cut_from_2d_model_vdf.pro
;  PURPOSE  :   This routine is a wrapper to get the 1D cut of a 2D slice (or projection)
;                 of a 3D velocity distribution function (VDF).  The routine allows for
;                 user-defined specification of which model VDF to choose from.
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
;               is_a_number.pro
;               bimaxwellian_fit.pro
;               bikappa_fit.pro
;               biselfsimilar_fit.pro
;               biselfsimilar_2exp_fit.pro
;               find_1d_cuts_2d_dist.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               VPARA      :  [N]-Element [numeric] array of velocities parallel to the
;                               quasi-static magnetic field direction [km/s]
;               VPERP      :  [M]-Element [numeric] array of velocities orthogonal to the
;                               quasi-static magnetic field direction [km/s]
;               PARAM      :  [6]-Element [numeric] array where each element is defined by
;                               the following quantities:
;                                 PARAM[0] = Number Density [cm^(-3)]
;                                 PARAM[1] = Para. Thermal Speed [km/s] or Temperature [eV]
;                                 PARAM[2] = Perp. Thermal Speed [km/s] or Temperature [eV]
;                                 PARAM[3] = Para. Drift Speed [km/s]
;                                 PARAM[4] = Perp. Drift Speed [km/s] or Para. Exponent for AS VDF
;                                 PARAM[5] = Exponent value of:
;                                   bi-Maxwellian          :  BIMAX = TRUE
;                                   bi-kappa               :  BIKAP = TRUE
;                                   symm. bi-self similar  :  SSVDF = TRUE
;                                   asym. bi-self similar  :  ASVDF = TRUE
;
;  EXAMPLES:    
;               [calling sequence]
;               f2d = get_1d_cut_from_2d_model_vdf(vpara,vperp,param [,/BIMAX] [,/BIKAP] $
;                                      [,/SSVDF] [,/ASVDF] [,PARAC=parac] [,PERPC=perpc] $
;                                      [,V_OXC=v_oxc] [,V_OYC=v_oyc] [,/ISTEMP]          $
;                                      [,/ELECTRONS] [,/PROTONS] [,/ALPHAS])
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               BIMAX      :  If set, routine will compute cuts for bi-Maxwellian VDF
;                               [Default = TRUE]
;               BIKAP      :  If set, routine will compute cuts for bi-kappa VDF
;                               [Default = FALSE]
;               SSVDF      :  If set, routine will compute cuts for symmetric bi-self similar VDF
;                               [Default = FALSE]
;               ASVDF      :  If set, routine will compute cuts for asymmetric bi-self similar VDF
;                               [Default = FALSE]
;               V_OXC      :  Scalar [numeric] defining the offset along VPARA along which
;                               to compute the perpendicular cut
;                               [Default = 0]
;               V_OYC      :  Scalar [numeric] defining the offset along VPARA along which
;                               to compute the parallel cut
;                               [Default = 0]
;               ISTEMP     :  If set, PARAM[1] and PARAM[2] are assumed to be temperatures
;                               in units of eV, thus need to be converted to thermal speeds
;                               in units of km/s
;                               [Default = FALSE]
;               ELECTRONS  :  If set, routine assumes model VDF is for electrons
;                               [Default = TRUE]
;               PROTONS    :  If set, routine assumes model VDF is for protons
;                               [Default = FALSE]
;               ALPHAS     :  If set, routine assumes model VDF is for alpha-particles
;                               [Default = FALSE]
;               **********************************
;               ***       DIRECT OUTPUTS       ***
;               **********************************
;               PARAC      :  Set to a named variable to return the 1D parallel cut along
;                               V_OYC for all VPARA
;               PERPC      :  Set to a named variable to return the 1D parallel cut along
;                               V_OXC for all VPERP
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Routine requires N and M for VPARA and VPERP to be ≥3
;               2)  Make sure units are consistent, i.e., all speeds/velocities in km/s
;
;  REFERENCES:  
;               0)  Barnes, A. "Collisionless Heating of the Solar-Wind Plasma I. Theory
;                      of the Heating of Collisionless Plasma by Hydromagnetic Waves,"
;                      Astrophys. J. 154, pp. 751--759, 1968.
;               1)  Mace, R.L. and R.D. Sydora "Parallel whistler instability in a plasma
;                      with an anisotropic bi-kappa distribution," J. Geophys. Res. 115,
;                      pp. A07206, doi:10.1029/2009JA015064, 2010.
;               2)  Livadiotis, G. "Introduction to special section on Origins and
;                      Properties of Kappa Distributions: Statistical Background and
;                      Properties of Kappa Distributions in Space Plasmas,"
;                      J. Geophys. Res. 120, pp. 1607--1619, doi:10.1002/2014JA020825,
;                      2015.
;               3)  Dum, C.T., et al., "Turbulent Heating and Quenching of the Ion Sound
;                      Instability," Phys. Rev. Lett. 32(22), pp. 1231--1234, 1974.
;               4)  Dum, C.T. "Strong-turbulence theory and the transition from Landau
;                      to collisional damping," Phys. Rev. Lett. 35(14), pp. 947--950,
;                      1975.
;               5)  Jain, H.C. and S.R. Sharma "Effect of flat top electron distribution
;                      on the turbulent heating of a plasma," Beitraega aus der
;                      Plasmaphysik 19, pp. 19--24, 1979.
;               6)  Goldman, M.V. "Strong turbulence of plasma waves," Rev. Modern Phys.
;                      56(4), pp. 709--735, 1984.
;               7)  Horton, W., et al., "Ion-acoustic heating from renormalized
;                      turbulence theory," Phys. Rev. A 14(1), pp. 424--433, 1976.
;               8)  Horton, W. and D.-I. Choi "Renormalized turbulence theory for the
;                      ion acoustic problem," Phys. Rep. 49(3), pp. 273--410, 1979.
;               9)  Wilson III, L.B., et al., "Relativistic electrons produced by
;                      foreshock disturbances observed upstream of the Earth’s bow
;                      shock," Phys. Rev. Lett. 117(21), pp. 215101, 2016.
;              10)  Wilson III, L.B., et al., "The Statistical Properties of Solar Wind
;                      Temperature Parameters Near 1 au," Astrophys. J. Suppl. 236(2),
;                      pp. 41, doi:10.3847/1538-4365/aab71c, 2018.
;              11)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl. 243(8), doi:10.3847/1538-4365/ab22bd, 2019a.
;              12)  Wilson III, L.B., et al., "Supplement to: Electron energy partition
;                      across interplanetary shocks," Zenodo (data product),
;                      doi:10.5281/zenodo.2875806, 2019b.
;              13)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: II. Statistics," Astrophys. J. Suppl.
;                      245(24), doi:10.3847/1538-4365/ab5445, 2019c.
;              14)  Wilson III, L.B., et al., "Electron energy partition across
;                      interplanetary shocks: III. Analyis," Astrophys. J. Suppl.,
;                      Submitted on Feb. 7, 2020.
;
;   CREATED:  02/21/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/21/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_1d_cut_from_2d_model_vdf,vpara,vperp,param,BIMAX=bimax,BIKAP=bikap,$
                                      SSVDF=ssvdf,ASVDF=asvdf,PARAC=parac,PERPC=perpc,$
                                      V_OXC=v_oxc,V_OYC=v_oyc,ISTEMP=istemp,          $
                                      ELECTRONS=electrons,PROTONS=protons,ALPHAS=alphas

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Get fundamental and astronomical
@load_constants_fund_em_atomic_c2014_batch.pro
@load_constants_extra_part_co2014_ci2015_batch.pro
@load_constants_astronomical_aa2015_batch.pro
;;  Conversion factors
;;    Energy and Temperature
f_1eV          = qq[0]/hh[0]              ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
eV2J           = hh[0]*f_1eV[0]           ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
eV2K           = qq[0]/kB[0]              ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> eV2K*energy{eV} = Temp{K}]
K2eV           = kB[0]/qq[0]              ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> K2eV*Temp{K} = energy{eV}]
;;  Speed factors
vtefac         = SQRT(2d0*eV2J[0]/me[0])*1d-3
vtpfac         = SQRT(2d0*eV2J[0]/mp[0])*1d-3
vtafac         = SQRT(2d0*eV2J[0]/ma[0])*1d-3
;;  Dummy/Default stuff
dpder          = REPLICATE(0,6)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN BEGIN
  ;;  no input???
  RETURN,0b
ENDIF
np             = N_ELEMENTS(param)
nva            = N_ELEMENTS(vpara)
nve            = N_ELEMENTS(vperp)
test           = (np[0] NE 6) OR (nva[0] LT 3L) OR (nve[0] LT 3L)
IF (test[0]) THEN BEGIN
  ;;  bad input???
  RETURN,0b
ENDIF
test           = (is_a_number(vpara,/NOMSSG) EQ 0) OR (is_a_number(vperp,/NOMSSG) EQ 0) OR (is_a_number(param,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  bad input???
  RETURN,0b
ENDIF
vamnmx         = [MIN(vpara,/NAN),MAX(vpara,/NAN)]
vemnmx         = [MIN(vperp,/NAN),MAX(vperp,/NAN)]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check VDF model keywords
checks         = [KEYWORD_SET(bimax),KEYWORD_SET(bikap),KEYWORD_SET(ssvdf),KEYWORD_SET(asvdf)]
good           = WHERE(checks,gd)
CASE good[0] OF
  0     :  func           = 'bimaxwellian_fit'
  1     :  func           = 'bikappa_fit'
  2     :  func           = 'biselfsimilar_fit'
  3     :  func           = 'biselfsimilar_2exp_fit'
  ELSE  :  func           = 'bimaxwellian_fit'  ;;  None set --> Use bi-Maxwellian default
ENDCASE
;;  Check V_O[X,Y]C
IF (is_a_number(v_oxc,/NOMSSG) EQ 0) THEN vox = 0d0 ELSE vox = (DOUBLE(v_oxc[0]) > vamnmx[0]) < vamnmx[1]
IF (is_a_number(v_oyc,/NOMSSG) EQ 0) THEN voy = 0d0 ELSE voy = (DOUBLE(v_oyc[0]) > vemnmx[0]) < vemnmx[1]
;;  Check Particle Species
checks         = [KEYWORD_SET(electrons),KEYWORD_SET(protons),KEYWORD_SET(alphas)]
good           = WHERE(checks,gd)
CASE good[0] OF
  0     :  vthfac         = vtefac[0]
  1     :  vthfac         = vtpfac[0]
  2     :  vthfac         = vtafac[0]
  ELSE  :  vthfac         = vtefac[0]  ;;  None set --> Use electron default
ENDCASE
;;  Check ISTEMP
IF KEYWORD_SET(istemp) THEN BEGIN
  ;;  Convert temps to thermal speeds
  vths           = vthfac[0]*SQRT(param[1:2])
ENDIF ELSE BEGIN
  ;;  Already thermal speeds --> do nothing
  vths           = vthfac[0]*SQRT(param[1:2])
ENDELSE
parm           = param
parm[1:2]      = vths
;;----------------------------------------------------------------------------------------
;;  Calculate 2D Model VDF
;;----------------------------------------------------------------------------------------
f2d            = CALL_FUNCTION(func[0],vpara,vperp,parm,dpder)
;;  Get 1D cuts
cut_str        = find_1d_cuts_2d_dist(f2d,vpara,vperp,X_0=vox[0],Y_0=voy[0])
;;  Define output keywords
parac          = cut_str.X_1D_FXY
perpc          = cut_str.Y_1D_FXY
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,f2d
END














































