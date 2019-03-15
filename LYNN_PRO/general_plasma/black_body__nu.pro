;+
;*****************************************************************************************
;
;  FUNCTION :   black_body__nu.pro
;  PURPOSE  :   This routine calculates a blackbody spectrum in frequency space given
;                 a user defined temperature [K], range of frequencies, and number
;                 of points to use.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_plot_axis_range.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               blackbody__nu = black_body__nu([,TEMP=temp] [,FRAN=fran] [,NPTS=npts] $
;                                              [,FOUT=fout] [,/CGSU])
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               TEMP  :  Scalar [numeric] defining the temperature [K] of the blackbody
;                          [Default = 5778 (i.e., roughly the solar spectrum)]
;               FRAN  :  [2]-Element [numeric] array defining the range of frequencies
;                          [ Default = [1d4,1d20] ]
;               NPTS  :  Scalar [numeric] defining the number of frequencies to compute
;                          [Default = 10000]
;               CGSU  :  If set, output will be in cgs units
;                          [B_nu(T)] = [erg s^(-1) cm^(-2) Hz^(-1) sr^(-1)]
;                          [Default = FALSE]
;               ESAU  :  If set, output will be in ESA units
;                          [B_nu(T)] = [eV s^(-1) cm^(-2) eV^(-1) sr^(-1)]
;                          [Default = FALSE]
;               **********************************
;               ***       DIRECT OUTPUTS       ***
;               **********************************
;               FOUT  :  Set to a named variable to return the array of frequencies [Hz]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               Computes the function
;                 B_nu(T) = 2 h nu^(3) c^(-2) [e^(h nu/kB T) - 1]^(-1)
;               Output in SI units
;                 [B_nu(T)] = [J s^(-1) m^(-2) Hz^(-1) sr^(-1)]
;               Output in cgs units
;                 [B_nu(T)] = [erg s^(-1) cm^(-2) Hz^(-1) sr^(-1)]
;
;  REFERENCES:  
;               1)  G.B. Rybicki and A.P. Lightman "Radiative Processes in Astrophysics,"
;                      (1st Edition) John Wiley & Sons, Inc., ISBN 0-471-82759-2, 1979.
;
;   CREATED:  03/05/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/05/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION black_body__nu,TEMP=temp,FRAN=fran,NPTS=npts,FOUT=fout,CGSU=cgsu,ESAU=esau

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Fundamental
cc             = 2.9979245800d+08                    ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
kB             = 1.3806485200d-23                    ;;  Boltzmann Constant [J K^(-1), 2014 CODATA/NIST]
SB             = 5.6703670000d-08                    ;;  Stefan-Boltzmann Constant [W m^(-2) K^(-4), 2014 CODATA/NIST]
hh             = 6.6260700400d-34                    ;;  Planck Constant [J s, 2014 CODATA/NIST]
;;  Electromagnetic
qq             = 1.6021766208d-19                    ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12                    ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07                    ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
;;  Energy and Temperature
f_1eV          = qq[0]/hh[0]                         ;;  Freq. associated with 1 eV of energy [ Hz --> f_1eV*energy{eV} = freq{Hz} ]
J_1eV          = hh[0]*f_1eV[0]                      ;;  Energy associated with 1 eV of energy [ J --> J_1eV*energy{eV} = energy{J} ]
K_eV           = qq[0]/kB[0]                         ;;  Temp. associated with 1 eV of energy [11,604.5221 K/eV, 2014 CODATA/NIST --> K_eV*energy{eV} = Temp{K}]
eV_K           = kB[0]/qq[0]                         ;;  Energy associated with 1 K Temp. [8.6173303 x 10^(-5) eV/K, 2014 CODATA/NIST --> eV_K*Temp{K} = energy{eV}]
J2eV           = 1d0/J_1eV[0]                        ;;  Energy associated with 1 J of energy [ eV --> J2eV*energy{J} = energy{eV} ]
;;  Other
h__si          = hh[0]
h__eV          = hh[0]/qq[0]                         ;;  Planck Constant [eV s, 2014 CODATA/NIST]
h_cgs          = hh[0]*1d7                           ;;  Planck Constant [erg s, 2014 CODATA/NIST]
c__si          = cc[0]                               ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
c_cgs          = cc[0]*1d2                           ;;  Speed of light in vacuum [cm s^(-1), 2014 CODATA/NIST]
t_factors      = [1d0,1d0/qq[0],1d7]                 ;;  [J --> J, J --> eV, J --> erg]
l_factors      = [1d0,1d0,1d2]                       ;;  [m --> m, m --> m, m --> cm]
n_factors      = [1d0,h__eV[0],1d0]
;;  Defaults
def_temp       = 5778d0                              ;;  rough blackbody temperature [K] of sun
def_fran       = [1d4,1d20]                          ;;  frequency [Hz] range of photons
def_npts       = 10000L                              ;;  default number of points to use
c              = c__si[0]
h              = h__si[0]
tfac           = t_factors[0]
nfac           = n_factors[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords [Inputs]
;;----------------------------------------------------------------------------------------
;;  Check TEMP
IF (is_a_number(temp,/NOMSSG) EQ 0) THEN kT = def_temp[0]*kB[0] ELSE kT = (ABS(temp[0]) > 1d0)*kB[0]
;;  Check FRAN
IF ((is_a_number(fran,/NOMSSG) EQ 0) OR (N_ELEMENTS(fran) LT 2)) THEN nuran = def_fran ELSE nuran = ABS(fran)
IF (test_plot_axis_range(nuran,/NOMSSG) EQ 0) THEN nuran = def_fran
;;  Check NPTS
IF (is_a_number(npts,/NOMSSG) EQ 0) THEN nn = def_npts[0] ELSE nn = (LONG(ABS(npts[0])) > 100L)
;;  Check CGSU
IF KEYWORD_SET(cgsu) THEN cgs_on = 1b ELSE cgs_on = 0b
;;  Check ESAU
IF KEYWORD_SET(esau) THEN esa_on = 1b ELSE esa_on = 0b
IF (esa_on[0]) THEN cgs_on = 0b
IF (cgs_on[0]) THEN BEGIN
  ;;  Change units of constants
  nfac = n_factors[2]
  lfac = l_factors[2]
  tfac = t_factors[2]
  c    = c_cgs[0]
  h    = h_cgs[0]
ENDIF
IF (esa_on[0]) THEN BEGIN
  ;;  Change units of constants
  ;;  ***  Still testing  ***
  nfac = n_factors[1]
  lfac = l_factors[1]
  tfac = t_factors[1]
  c    = c__si[0]
  h    = h__eV[0]
ENDIF
kT            *= tfac[0]
;;----------------------------------------------------------------------------------------
;;  Construct abscissa array in log-space
;;----------------------------------------------------------------------------------------
l10ran         = ALOG10(nuran)
l10fac         = (l10ran[1] - l10ran[0])/(nn[0] - 1L)
l10arr         = DINDGEN(nn[0])*l10fac[0] + l10ran[0]
;;----------------------------------------------------------------------------------------
;;  Construct spectrum array in linear-space
;;----------------------------------------------------------------------------------------
xx_arr         = 1d1^(l10arr)
;;  Compute exponent
exp_arr        = (h[0]/kT[0])*xx_arr                ;;  (h nu/kB T) exponent term
;;  Compute normalization constant
xx_fac         = (2d0*h[0]/c[0]^2d0)                ;;  (2 h c^(-2)) constant factor
;;  Define:  B_nu(T) = 2 h nu^(3) c^(-2) [e^(h nu/kB T) - 1]^(-1)
numer          = xx_fac[0]*xx_arr^3d0
denom          = EXP(exp_arr) - 1d0
blckbdy__xx    = numer/denom;/nfac[0]
;;  Set output keyword
fout           = xx_arr*nfac[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,blckbdy__xx
END


