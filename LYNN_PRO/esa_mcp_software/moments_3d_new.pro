;+
;*****************************************************************************************
;
;  FUNCTION :   d_omega_weights.pro
;  PURPOSE  :   Determines the detector solid angles given an input of spherical
;                 coordinate angles.  The returned array is a [13,N,M,K]-element array,
;                 where the dimensions are:
;                     N  =  # of energy bins
;                     M  =  # of angle bins
;                     K  =  # of data structures
;
;  CALLED BY:   
;               moments_3d_new.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               TH     :  Polar angle (deg) determined by get_?? structure tag THETA
;               PH     :  Azimuthal " " PHI
;               DTH    :  Polar angular resolution (deg) " " DTHETA
;               DPH    :  Azimuthal " " DPHI
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               ORDER  :  Obselete usage for this specific routine
;
;   CHANGED:  1)  Jim altered something                           [04/21/2011   v1.0.?]
;             2)  Re-wrote and cleaned up                         [06/14/2011   v1.1.0]
;             3)  Fixed typo in man page                          [08/16/2011   v1.1.1]
;             4)  Added to moments_3d_new.pro                     [06/01/2012   v1.2.0]
;
;   NOTES:      
;               1)  The polar angles define zero in the XY-Plane, not at the Z-axis
;               2)  User should not call this routine
;
;   ADAPTED FROM: moments_3d_omega_weights.pro  BY: Jim McTiernan
;   CREATED:  ??/??/????
;   CREATED BY:  Jim McTiernan
;    LAST MODIFIED:  06/01/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION d_omega_weights,th,ph,dth,dph,ORDER=order  ;;, tgeom   inputs may be up to 3 dimensions

;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
dim    = SIZE(th,/DIMENSIONS)
dmph   = SIZE(ph,/DIMENSIONS)
dmdth  = SIZE(dth,/DIMENSIONS)
dmdph  = SIZE(dph,/DIMENSIONS)
test0  = (ARRAY_EQUAL(dim,dmph) EQ 0) OR (ARRAY_EQUAL(dim,dmdth) EQ 0) OR $
         (ARRAY_EQUAL(dim,dmdph) EQ 0)
IF (test0) THEN MESSAGE,'Bad Input'
omega  = DBLARR([13,dim])
;;----------------------------------------------------------------------------------------
;;  Angular moment integrals
;;----------------------------------------------------------------------------------------
ph2    = ph + dph/2       ;;  upper bound on azimuthal angle
ph1    = ph - dph/2       ;;  lower " "
th2    = th + dth/2       ;;  upper bound on polar angle
th1    = th - dth/2       ;;  lower " "
;;  Define the Sine/Cosine of each
sth1   = SIN(th1*!DPI/18d1)
cth1   = COS(th1*!DPI/18d1)
sph1   = SIN(ph1*!DPI/18d1)
cph1   = COS(ph1*!DPI/18d1)
sth2   = SIN(th2*!DPI/18d1)
cth2   = COS(th2*!DPI/18d1)
sph2   = SIN(ph2*!DPI/18d1)
cph2   = COS(ph2*!DPI/18d1)
;;  Define various permutations of each
ip     = dph*!DPI/18d1
ict    =  sth2 - sth1
icp    =  sph2 - sph1
isp    = -cph2 + cph1
is2p   = dph/2d0*!DPI/18d1 - sph2*cph2/2d0 + sph1*cph1/2d0
ic2p   = dph/2d0*!DPI/18d1 + sph2*cph2/2d0 - sph1*cph1/2d0
ic2t   = dth/2d0*!DPI/18d1 + sth2*cth2/2d0 - sth1*cth1/2d0
ic3t   = sth2 - sth1 - (sth2^3 - sth1^3)/3d0
ictst  = (sth2^2 - sth1^2)/2d0
icts2t = (sth2^3 - sth1^3)/3d0
ic2tst = (-cth2^3 + cth1^3)/3d0
icpsp  = (sph2^2 - sph1^2)/2d0
;;  Define the solid angle
omega[0,*,*,*]  = ict    * ip
omega[1,*,*,*]  = ic2t   * icp
omega[2,*,*,*]  = ic2t   * isp
omega[3,*,*,*]  = ictst  * ip
omega[4,*,*,*]  = ic3t   * ic2p
omega[5,*,*,*]  = ic3t   * is2p
omega[6,*,*,*]  = icts2t * ip
omega[7,*,*,*]  = ic3t   * icpsp
omega[8,*,*,*]  = ic2tst * icp
omega[9,*,*,*]  = ic2tst * isp
omega[10,*,*,*] = omega[1,*,*,*]
omega[11,*,*,*] = omega[2,*,*,*]
omega[12,*,*,*] = omega[3,*,*,*]
;;----------------------------------------------------------------------------------------
;;  Return result to user
;;----------------------------------------------------------------------------------------

RETURN,omega
END


;+
;*****************************************************************************************
;
;  FUNCTION :   moments_3d_new.pro
;  PURPOSE  :   Returns all useful moments of a distribution function as a structure,
;                 which includes:
;
;        ** {Scalar} = rank-0 tensor                        -> [1]-element array **
;        ** {Vector} = rank-1 tensor                        -> [3]-element array **
;        ** {Matrix} = rank-2 tensor                        -> [3,3]-element array **
;        ** {DiagEl} = diagonal elements of a rank-2 tensor -> [3]-element array **
;        ** {QTense} = quasi-tensor                         -> just symmetric elements **
;
;        ** Symmetry Direction  :  See Section II.B (Software) of Curtis et al., [1988]
;
;                   SC_CURRENT  :  {Scalar} Current density [# cm^(-2) s^(-1)]
;                   DENSITY     :  {Scalar} Number density [cm^(-3)]
;                   AVGTEMP     :  {Scalar} Average particle temperature [eV]
;                   VTHERMAL    :  {Scalar} Average thermal speed [km s^(-1)]
;                   VELOCITY    :  {Vector} Bulk flow velocity [km s^(-1)]
;                   FLUX        :  {Vector} Number flux [cm^(-2) s^(-1)]
;                     ** Velocity flux [cm^(-1) s^(-2)] **
;                   MFTENS      :  {QTense} Momentum flux [eV cm^(-3)]
;                   EFLUX       :  {Vector} Energy flux [eV cm^(-2) s^(-1)]
;                   PTENS       :  {QTense} Pressure tensor [eV cm^(-3)]
;                   T3          :  {DiagEl} Eigenvalues of "temperature tensor" in
;                                             the input coordinate system [xx,yy,zz]
;                   MAGT3       :  {DiagEl} Eigenvalues of "temperature tensor" in
;                                             field-aligned coordinates [perp1,perp2, para]
;                   SYMM        :  {Vector} Symmetry direction of distribution
;                   SYMM_THETA  :  {Scalar} Poloidal angle of symmetry direction [deg]
;                   SYMM_PHI    :  {Scalar} Azimuthal angle of symmetry direction [deg]
;                   SYMM_ANG    :  {Scalar} Angle between symmetry direction and Bo [deg]
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               dat_3dp_str_names.pro
;               convert_ph_units.pro
;               conv_units.pro
;               d_omega_weights.pro
;               str_element.pro
;               moments_3d_new.pro
;               sc_pot.pro
;               struct_value.pro
;               rot_mat.pro
;               xyz_to_polar.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries and UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA            :  Scalar particle distribution from either Wind/3DP
;                                    or THEMIS ESA
;                                    [See:  get_??.pro for Wind]
;                                    [See:  thm_part_dist_array.pro for THEMIS]
;
;  EXAMPLES:    
;               ;;  Return just the default structure format
;               test = moments_3du()
;               
;               ;;  Return the moments of the particle distribution
;               test = moments_3du(data,SC_POT=data.SC_POT)
;
;  KEYWORDS:    
;               SC_POT          :  Scalar [float] defining the spacecraft potential (eV)
;               MAGDIR          :  [3]-Element [float] vector defining the magnetic field
;                                    vector (nT) associated with the data structure
;               TRUE_DENS       :  Scalar defining the true density (cc)
;                                    [Used to constrain SC potential estimates]
;               COMP_SC_POT     :  If set, routine attempts to estimate the SC potential
;               PARDENS         :  Set to a named variable to return the partial
;                                    densities for each energy/angle bin
;               DENS_ONLY       :  If set, program only returns the density estimate (cc)
;               MOM_ONLY        :  If set, program only returns through flux (1/cm/s^2)
;               ADD_MOMENT      :  Set to a structure of identical format to the return
;                                    format of this program to be added to the structure
;                                    being manipulated
;               ADD_DMOMENT     :  The same format as ADD_MOMENT but for an uncertainty
;                                    structure
;               ERANGE          :  [2]-Element array specifying the first and last
;                                    elements of the energy bins desired to be used for
;                                    calculating the moments
;               FORMAT          :  Set to a dummy variable which will be returned the
;                                    as the structure format associated with the output
;                                    structure of this program
;               BINS            :  Old keyword apparently
;               VALID           :  Set to a dummy variable which will return a 1 for a
;                                    structure with useful data or 0 for a bad structure
;               DMOM            :  Set to a named variable to return the uncertainties in
;                                    the distribution moment calculations
;                                    *** Not working yet ***
;               DOMEGA_WEIGHTS  :  If set, routine uses solid angle estimates determined
;                                    by domega_weights.pro instead of using
;                                    DOMEGA values existing in IDL structures
;               PH_0_360        :  Determines the range of azimuthal angles of symmetry
;                                    direction
;                                      > 0  :     0 < phi < +360
;                                      = 0  :  -180 < phi < +180
;                                      < 0  :     routine determines best range
;               TRUE_VBULK      :  [3]-Element [float] defining the "true" or a priori
;                                    known bulk flow velocity [km/s].  If not set, the
;                                    routine will compute this value from the first
;                                    moment.
;
;   CHANGED:  1)  Moved out of the ~/distribution_fit_LM_pro directory
;                                                                   [08/21/2012   v1.1.0]
;             2)  Added keyword:  TRUE_VBULK
;                                                                   [05/09/2013   v1.2.0]
;
;   NOTES:      
;               1)  Adaptations from routines written by Jim McTiernan are used
;               2)  See also:  moments_3d.pro or moments_3du.pro
;               3)  MAGDIR and TRUE_VBULK must be in the same coordinate basis as
;                     the angles found in the input data structure
;
;  REFERENCES:  
;               1)  Carlson et al., (1983), "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70.
;               2)  Curtis et al., (1989), "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372.
;               3)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;
;   ADAPTED FROM: moments_3d.pro and moments_3du.pro  BY: Davin Larson
;   CREATED:  06/01/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/09/2013   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION moments_3d_new,data,SC_POT=scpot,MAGDIR=magdir,TRUE_DENS=tdens,       $
                             COMP_SC_POT=comp_sc_pot,PARDENS=pardens,          $
                             DENS_ONLY=dens_only,MOM_ONLY=mom_only,            $
                             ADD_MOMENT=add_moment,ADD_DMOMENT=add_dmoment,    $
                             ERANGE=er,FORMAT=momformat,BINS=bins,VALID=valid, $
                             DMOM=dmom,DOMEGA_WEIGHTS=domega_weights,          $
                             PH_0_360=ph_0_360,TRUE_VBULK=true_vbulk

;;----------------------------------------------------------------------------------------
;;  Define dummy variables and structures
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
f3             = [f,f,f]
f6             = [f,f,f,f,f,f]
f33            = [[f3],[f3],[f3]]
d              = !VALUES.D_NAN

IF (SIZE(momformat,/TYPE) EQ 8) THEN mom = momformat ELSE $
  mom = {TIME:d, SC_POT:f, SC_CURRENT:f, MAGF:f3, DENSITY:f, AVGTEMP:f, VTHERMAL:f, $
         VELOCITY:f3, FLUX:f3, PTENS:f6, MFTENS:f6, EFLUX:f3,                       $
         T3:f3, SYMM:f3, SYMM_THETA:f, SYMM_PHI:f, SYMM_ANG:f,                      $
         MAGT3:f3, ERANGE:[f,f], MASS:f,VALID:0}

mom.VALID      = 0
IF (N_PARAMS() EQ 0) THEN GOTO,SKIPSUMS
;;----------------------------------------------------------------------------------------
;;  Check input structure format
;;----------------------------------------------------------------------------------------
;;  Make sure nothing reassigns values to original data
dd             = data[0]
IF (SIZE(dd,/TYPE) NE 8) THEN RETURN,mom
valid          = 0

test0          = test_wind_vs_themis_esa_struct(dd,/NOM)
test           = (test0.(0) + test0.(1)) NE 1
IF (test) THEN BEGIN
  RETURN,mom
ENDIF
;;----------------------------------------------------------------------------------------
;;  Convert to energy flux units
;;----------------------------------------------------------------------------------------
;;  Check which spacecraft is being used
IF (test0.(0)) THEN BEGIN
  ;;-------------------------------------------
  ;; Wind
  ;;-------------------------------------------
  ;;  Check which instrument is being used
  strns   = dat_3dp_str_names(dd[0])
  IF (SIZE(strns,/TYPE) NE 8) THEN RETURN,mom
  shnme   = STRLOWCASE(STRMID(strns.SN[0],0L,2L))
  CASE shnme[0] OF
    'ph' : BEGIN
      ;;  Now convert actual data to energy flux [eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]
      convert_ph_units,dd,'eflux'
      data3d       = dd
      charge       = 1d0
    END
    ELSE : BEGIN
      ;;  Now convert actual data to energy flux [eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]
      data3d       = conv_units(dd,'eflux')
      IF (STRMID(shnme[0],0L,1L) EQ 's') THEN BEGIN
        charge       = ([-1d0,1d0])[STRMID(shnme[0],1L,1L) EQ 'o']
      ENDIF ELSE BEGIN
        charge       = ([-1d0,1d0])[STRMID(shnme[0],0L,1L) EQ 'p']
      ENDELSE
    END
  ENDCASE
  ;; Define solid-angle
  ;;    [N,M]-element array
  ;;       N = # of energy bins
  ;;       M = # of angle bins
  domega       = REPLICATE(1.,data3d.NENERGY) # data3d.DOMEGA
  ph_0_360     = 1
ENDIF ELSE BEGIN
  ;;-------------------------------------------
  ;; THEMIS
  ;;-------------------------------------------
  ;;  Now convert actual data to energy flux [eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]
  data3d       = conv_units(dd,'eflux')
  charge       = DOUBLE(data3d[0].CHARGE[0])
  ;; Define solid-angle
  domega       = data3d.DOMEGA
ENDELSE

mom.TIME = data3d.TIME
mom.MAGF = data3d.MAGF
IF (data3d[0].VALID EQ 0) THEN RETURN,mom
;;----------------------------------------------------------------------------------------
;;  Define parameters from structure
;;----------------------------------------------------------------------------------------
nn             = data3d[0].NENERGY               ;;  # of energy bins
na             = data3d[0].NBINS                 ;;  # of angle bins
e              = data3d[0].ENERGY                ;;  E [Energy bin energies, eV]
denergy        = struct_value(data3d,'denergy')  ;;  ∆E [eV]
eflux          = data3d[0].DATA                  ;;  ƒ(E,∑,ø) [eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]

nn_1           = nn - 1L
;;----------------------------------------------------------------------------------------
;;  Determine Solid Angle [sr]
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(domega_weights) THEN BEGIN
  domega_weight = d_omega_weights(data3d.THETA,data3d.PHI,data3d.DTHETA,data3d.DPHI)
  ;;  domega_weight = [13,N,M,K]-element array
  ;;                     N  =  # of energy bins
  ;;                     M  =  # of angle bins
  ;;                     K  =  # of data structures
ENDIF ELSE BEGIN
  ;;  The following is the old way from the original Wind/3DP routines
  domega_weight = domega
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Determine energy range
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(er) THEN BEGIN
  err                = 0 >  er < nn_1[0]    ;;  Index range
  s                  = e
  s[*]               = 0.
  s[err[0]:err[1],*] = 1.
  eflux             *= s
ENDIF ELSE  BEGIN
  err                = [0L, nn_1[0]]
ENDELSE
mom.ERANGE = data3d.ENERGY[err,0]

IF KEYWORD_SET(bins) THEN MESSAGE,'bins keyword ignored',/INFO
;;  TDAS Update
bins           = data3d[0].BINS
IF (SIZE(/N_DIMENSIONS,bins) EQ 1) THEN bins = REPLICATE(1,nn) # bins
w    = WHERE(data3d.BINS EQ 0,c)
IF (c NE 0) THEN data3d.DATA[w] = 0
;;----------------------------------------------------------------------------------------
;;  Define or set spacecraft (SC) potential [eV]
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(scpot) NE 0) THEN pot = scpot[0]
IF (N_ELEMENTS(pot) EQ 0)   THEN str_element,data3d,'SC_POT',pot
IF (N_ELEMENTS(pot) EQ 0)   THEN pot = 0.
IF (NOT FINITE(pot))        THEN pot = 6.

IF KEYWORD_SET(tdens) THEN BEGIN
  pota = [3.,12.]
  m0   = moments_3d_new(data3d,SC_POT=pota[0],/DENS_ONLY,DOMEGA_WEIGHTS=domega_weights)
  m1   = moments_3d_new(data3d,SC_POT=pota[1],/DENS_ONLY,DOMEGA_WEIGHTS=domega_weights)
  dens = [m0.DENSITY,m1.DENSITY]
  FOR i=0L, 4L DO BEGIN 
    yp   = (dens[0] - dens[1])/(pota[0] - pota[1])
    pot  = pota[0] - (dens[0] - tdens[0])/yp[0]
    m0   = moments_3d_new(data3d,SC_POT=pot,/DENS_ONLY,DOMEGA_WEIGHTS=domega_weights)
    dens = [m0.DENSITY,dens]
    pota = [pot,pota]
  ENDFOR
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine the spacecraft potential
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(comp_sc_pot) THEN BEGIN
  FOR i = 0L, 3L DO BEGIN 
    m   = moments_3d_new(data3d,SC_POT=pot,/DENS_ONLY,DOMEGA_WEIGHTS=domega_weights)
    pot = sc_pot(m.DENSITY)
  ENDFOR
ENDIF
mom.SC_POT   = pot[0]                                      ;;  [eV]
mom.MASS     = data3d[0].MASS[0]                           ;;  [eV/c^2, with c in km/s]
mass         = mom.MASS[0]
;;----------------------------------------------------------------------------------------
;;  Determine differential energy then calculate DF differential
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(denergy) THEN BEGIN
  de_e            = ABS(SHIFT(e,1) - SHIFT(e,-1))/(2.0*e)     ;; ∆E/E [unitless]
  de_e[0L,*]      = de_e[1L,*]
  de_e[nn_1[0],*] = de_e[nn_1[0] - 1L,*]
  de              = de_e * e                                  ;; ∆E [eV]
ENDIF ELSE BEGIN
  de_e            = denergy/e                                 ;; ∆E/E [unitless]
  de              = denergy
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define weighting factor [Wt] and Energy at infinity [E_inf]
;;----------------------------------------------------------------------------------------
weight         = 0. > ((e + pot[0]*charge[0])/de + .5) < 1.      ;;  Weights [unitless weight factor]
e_inf          = (e + pot[0]*charge[0]) > 0.                     ;;  E_inf [Energy at infinity, eV]
;;----------------------------------------------------------------------------------------
;;  Define a differential volume [∆E/E * Wt * ∆Ω]
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(domega_weights) THEN BEGIN
  ;;  THEMIS TDAS method
  dvolume  = de_e * weight * domega_weight[0,*,*,*]        ;;  [sr]
ENDIF ELSE BEGIN
  ;;  Wind/3DP method
  dvolume  =  de_e * domega_weight * weight                ;;  [sr]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define the differential of ƒ(v) [∆f = (∆E/E * Wt * ∆Ω) * ƒ(E,∑,ø)]
;;----------------------------------------------------------------------------------------
data_dv        = eflux * dvolume                           ;;  DF differential  [eV cm^(-2) s^(-1) eV^(-1)]
;;----------------------------------------------------------------------------------------
;;  Current calculation:
;;----------------------------------------------------------------------------------------
mom.SC_CURRENT = TOTAL(data_dv,/NAN)
;;----------------------------------------------------------------------------------------
;;  Density calculation:  [# cm^(-3)]
;;----------------------------------------------------------------------------------------
dweight        = SQRT(e_inf)/e                               ;;  [eV^(-1/2)]
par_factor     = SQRT(mass[0]/2.) * 1e-5                     ;;  [eV^(1/2) / (cm/s)]
;;  Note:  The factor of 1e-5 is to change [km] to [cm]
pardens        = par_factor * data_dv  * dweight             ;;  [eV cm^(-3) eV^(-1)]
mom.DENSITY    = TOTAL(pardens,/NAN)                         ;;  [# cm^(-3)]

IF KEYWORD_SET(dens_only) THEN RETURN,mom
;;----------------------------------------------------------------------------------------
;;  PARTICLE FLUX:  [cm^(-2) s^(-1)]
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(domega_weights) THEN BEGIN
  ;;  THEMIS TDAS method
  f_fac       = de_e * weight * e_inf / e                  ;;  [Unitless]
  temp        = data3d.DATA  * f_fac                       ;;  [# cm^(-2) s^(-1) sr^(-1)]
  fx          = TOTAL(temp*domega_weight[1,*,*,*],/NAN)    ;;  [# cm^(-2) s^(-1)]
  fy          = TOTAL(temp*domega_weight[2,*,*,*],/NAN)
  fz          = TOTAL(temp*domega_weight[3,*,*,*],/NAN)
ENDIF ELSE BEGIN
  ;;  Wind/3DP method
  fo          = data_dv * (e_inf / e)                      ;;  [# cm^(-2) s^(-1)]
  sin_phi     = SIN(data3d.PHI/!RADEG)
  cos_phi     = COS(data3d.PHI/!RADEG)
  sin_th      = SIN(data3d.THETA/!RADEG)
  cos_th      = COS(data3d.THETA/!RADEG)
  cos2_th     = cos_th^2
  cthsth      = cos_th*sin_th
  fwx         = cos_phi * cos_th * fo                      ;;  [# cm^(-2) s^(-1) sr^(-1)]
  fwy         = sin_phi * cos_th * fo
  fwz         = sin_th * fo
  fx          = TOTAL(fwx,/NAN)                            ;;  [# cm^(-2) s^(-1)]
  fy          = TOTAL(fwy,/NAN)
  fz          = TOTAL(fwz,/NAN)
ENDELSE

mom.FLUX       = [fx,fy,fz]                                ;;  [# cm^(-2) s^(-1)]
;;----------------------------------------------------------------------------------------
;;  VELOCITY FLUX:  [eV^(1/2) cm^(-2) s^(-1)]
;;----------------------------------------------------------------------------------------
;;  Note:  The factor of 1e-5 is to change [km] to [cm]
m_fac          = (SQRT(2/mass[0])*1e5)                     ;;  [eV^(-1/2) cm^(+1) s^(-1)]
IF KEYWORD_SET(domega_weights) THEN BEGIN
  ;;  THEMIS TDAS method
  v_fac       = de_e * weight * e_inf^(3./2.) / e          ;;  [eV^(+1/2)]
  temp        = data3d.DATA  * v_fac                       ;;  [eV^(+3/2) cm^(-2) s^(-1) sr^(-1) eV^(-1)]
  vfxx        = TOTAL(temp*domega_weight[4,*,*,*],/NAN)    ;;  [eV^(+1/2) cm^(-2) s^(-1)]
  vfyy        = TOTAL(temp*domega_weight[5,*,*,*],/NAN)
  vfzz        = TOTAL(temp*domega_weight[6,*,*,*],/NAN)
  vfxy        = TOTAL(temp*domega_weight[7,*,*,*],/NAN)
  vfxz        = TOTAL(temp*domega_weight[8,*,*,*],/NAN)
  vfyz        = TOTAL(temp*domega_weight[9,*,*,*],/NAN)
ENDIF ELSE BEGIN
  ;;  Wind/3DP method
  vfww        = data_dv * (e_inf^(3./2.) / e)              ;;  [eV^(+3/2) cm^(-2) s^(-1) sr^(-1) eV^(-1)]
  pvfwxx      = cos_phi^2 * cos2_th          * vfww        ;;  [eV^(+1/2) cm^(-2) s^(-1) sr^(-1)]
  pvfwyy      = sin_phi^2 * cos2_th          * vfww
  pvfwzz      = sin_th^2                     * vfww
  pvfwxy      = cos_phi * sin_phi * cos2_th  * vfww
  pvfwxz      = cos_phi * cthsth             * vfww
  pvfwyz      = sin_phi * cthsth             * vfww
  vfxx        = TOTAL(pvfwxx,/NAN)                         ;;  [eV^(+1/2) cm^(-2) s^(-1)]
  vfyy        = TOTAL(pvfwyy,/NAN)
  vfzz        = TOTAL(pvfwzz,/NAN)
  vfxy        = TOTAL(pvfwxy,/NAN)
  vfxz        = TOTAL(pvfwxz,/NAN)
  vfyz        = TOTAL(pvfwyz,/NAN)
ENDELSE

vftens      = [vfxx,vfyy,vfzz,vfxy,vfxz,vfyz]*m_fac[0]     ;;  [cm^(-1) s^(-2)]
;;  Note:  The factor of 1e10 is to change [km^(-2)] to [cm^(-2)]
mftens      = vftens*mass[0]/1e10                          ;;  [eV cm^(-3)]
;;  Define MOMENTUM FLUX:  [eV cm^(-3)]
mom.MFTENS  = mftens
;;----------------------------------------------------------------------------------------
;;  ENERGY FLUX:  [eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(domega_weights) THEN BEGIN
  ;;  THEMIS TDAS method
  e_fac       = de_e * weight * e_inf^(2.) / e             ;;  [eV]
  temp        = data3d.DATA  * e_fac                       ;;  [eV cm^(-2) s^(-1) sr^(-1)]
  v2f_x       = TOTAL(temp*domega_weight[1,*,*,*],/NAN)    ;;  [eV cm^(-2) s^(-1)]
  v2f_y       = TOTAL(temp*domega_weight[2,*,*,*],/NAN)
  v2f_z       = TOTAL(temp*domega_weight[3,*,*,*],/NAN)
ENDIF ELSE BEGIN
  ;;  Wind/3DP method
  efo         = data_dv * (e_inf^2 / e)                    ;;  [eV cm^(-2) s^(-1)]
  efwx        = cos_phi * cos_th * efo
  efwy        = sin_phi * cos_th * efo
  efwz        = sin_th * efo
  v2f_x       = TOTAL(efwx,/NAN)                           ;;  [eV cm^(-2) s^(-1)]
  v2f_y       = TOTAL(efwy,/NAN)
  v2f_z       = TOTAL(efwz,/NAN)
ENDELSE
mom.eflux   = [v2f_x,v2f_y,v2f_z]                          ;;  [eV cm^(-2) s^(-1)]

;;========================================================================================
SKIPSUMS:        ;; enter here to calculate remainder of items
;;========================================================================================
;;  Add moment of desired
IF (SIZE(add_moment,/TYPE) EQ 8) THEN BEGIN
  mom.DENSITY = mom.DENSITY + add_moment.DENSITY
  mom.FLUX    = mom.FLUX    + add_moment.FLUX
  mom.MFTENS  = mom.MFTENS  + add_moment.MFTENS
ENDIF
IF KEYWORD_SET(mom_only) THEN RETURN,mom

mass          = mom.MASS[0]                                ;;  [eV/c^2, with c in km/s]
;;----------------------------------------------------------------------------------------
;;  Define bulk flow vector [km/s]
;;----------------------------------------------------------------------------------------
test_vkey      = (N_ELEMENTS(true_vbulk) EQ 3)
IF (test_vkey) THEN BEGIN
  ;;  User has pre-defined bulk flow velocity
;  t_vbulk        = REFORM(true_vbulk)
  test_vkey      = (TOTAL(FINITE(REFORM(true_vbulk))) EQ 3)
  IF (test_vkey) THEN BEGIN
    ;;  Good input
    t_vbulk        = REFORM(true_vbulk)
    ;;  Redefine FLUX [** still testing this **]
;    t_flux         = mom.DENSITY*1e5*t_vbulk
;    mom.FLUX       = t_flux
  ENDIF ELSE BEGIN
    ;;  Non-finite input => Use default calculation
    t_vbulk        = mom.FLUX/mom.DENSITY/1e5
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Note:  The factor of 1e-5 is to change [cm] to [km]
  t_vbulk        = mom.FLUX/mom.DENSITY/1e5
ENDELSE
mom.VELOCITY   = t_vbulk
;;----------------------------------------------------------------------------------------
;;  Map the velocity flux to a 3x3 tensor
;;----------------------------------------------------------------------------------------
map3x3         = [[0,3,4],[3,1,5],[4,5,2]]
mapt           = [0,4,8,1,2,5]
;;  mf3x3  = ptens[map3x3]   [eV cm^(-3)]
mf3x3          = mom.MFTENS[map3x3]
;;  Define pressure tensor   [eV cm^(-3)]
pt3x3          = mf3x3 - (mom.VELOCITY # mom.FLUX)*mass[0]/1e5
mom.PTENS      = pt3x3[mapt]                                ;;  [eV cm^(-3)]
;;  Define "temperature tensor" = T
t3x3           = pt3x3/mom.DENSITY                          ;;  [eV]
;;  Tr[T]/3 = scalar temperature [eV]
mom.AVGTEMP    = (t3x3[0] + t3x3[4] + t3x3[8])/3.
mom.VTHERMAL   = SQRT(2e0*mom.AVGTEMP/mass[0])              ;;  Thermal speed [km/s]
tempt          = t3x3[mapt]                                 ;;  Symmetric elements of tensor

;;   Non-Finite points break TRIQL.PRO
;;     => NaNs  -->  0
gtemp          = WHERE(FINITE(t3x3),gt33,COMPLEMENT=btemp,NCOMPLEMENT=bt33)
IF (bt33 GT 0) THEN BEGIN   
  bind = ARRAY_INDICES(t3x3,btemp)
  t3x3[bind[0,*],bind[1,*]] = 0e0
ENDIF
IF (bt33 EQ 9) THEN mom.DENSITY = f
good         = FINITE(mom.DENSITY)
IF (NOT good OR mom.DENSITY LE 0) THEN RETURN,mom

t3evec       = t3x3
;;----------------------------------------------------------------------------------------
;; -> If T3EVEC = [NxN]-Element real symmetric matrix then:
;; -> T3        = Returned N-Element vector of the diagonal elements of t3evec
;; -> DUMMY     = Returned N-Element vector of the off-diagonal " " 
;;----------------------------------------------------------------------------------------
TRIRED,t3evec,t3,dummy
;;----------------------------------------------------------------------------------------
;; -> T3     => Eigenvalues of the input matrix T3
;; -> DUMMY  => Destroyed by TRIQL.PRO
;; -> T3EVEC => N-Eigenvectors of T3
;;----------------------------------------------------------------------------------------
TRIQL,t3,dummy,t3evec

;;----------------------------------------------------------------------------------------
;;  Define magnetic field direction
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(magdir) NE 3L) THEN magdir = [-1.,1.,0.]
magfn  = magdir/(SQRT(TOTAL(magdir^2,/NAN)))                ;;  normalize [unitless]
;;  intentionally NOT using the NAN keyword in next line
bmag   = SQRT(TOTAL(mom.MAGF^2))                            ;;  |B| [nT]
;;----------------------------------------------------------------------------------------
;;  Sort the temperature tensor eigenvalue elements
;;----------------------------------------------------------------------------------------
s      = SORT(t3)
IF (t3[s[1]] LT .5*(t3[s[0]] + t3[s[2]])) THEN num = s[2] ELSE num = s[0]

shft   = ([-1,1,0])[num]
t3     = SHIFT(t3,shft)
t3evec = SHIFT(t3evec,0,shft)
;;  Define  :  (B . T_zz)/|B|
dot    = TOTAL(magfn*t3evec[*,2],/NAN)
IF (FINITE(bmag)) THEN BEGIN
  ;;  use defined B-field to define parallel/perpendicular temperatures
  magfn        = mom.MAGF/bmag[0]
  ;;  Define dot product between B-field and temperature eigenvectors
  b_dot_s      = TOTAL((magfn # [1,1,1])*t3evec,1,/NAN)  ;;    [3]-element array
  dummy        = MAX(ABS(b_dot_s),num,/NAN)
  ;;  Define rotation matrix where new coordinates are:
  ;;     Z'  :  // to B
  ;;     Y'  :  // to (B x V)
  ;;     X'  :  // to (B x V) x B
  mrot         = rot_mat(mom.MAGF,mom.VELOCITY)
  magt3x3      = INVERT(mrot) # (t3x3 # mrot)
  mom.MAGT3    = magt3x3[[0,4,8]]  ;;  Diagonal elements
  ;;--------------------------------------------------------------------------------------
  ;;  mom.PTENS = [perp1,perp2,para,xy,xz,yz],  mom.MAGT3 = [perp1,perp2,para]
  ;;
  ;;  (INVERT(mrot) # (t3x3 # mrot))[0,4,8,1,2,5] = same as
  ;;                       mom.PTENS/mom.DENSITY in mom3d.pro
  ;;--------------------------------------------------------------------------------------
  dot          = TOTAL(magfn*t3evec[*,2],/NAN)  ;; B . T_zz
  mom.SYMM_ANG = ACOS(ABS(dot))*!RADEG          ;; angle of B-field from symmetry axis
ENDIF

IF (dot LT 0) THEN t3evec = -t3evec
mom.SYMM       = t3evec[*,2]         ;; symmetry direction
magdir         = mom.SYMM

xyz_to_polar,mom.SYMM,THETA=symm_theta,PHI=symm_phi,PH_0_360=ph_0_360
mom.SYMM_THETA = symm_theta
mom.SYMM_PHI   = symm_phi
mom.T3         = t3
valid          = 1
mom.VALID      = 1
;;----------------------------------------------------------------------------------------
;;  Return Moments Structure
;;----------------------------------------------------------------------------------------

RETURN,mom
END

