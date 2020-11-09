;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_scpot_el.pro
;  PURPOSE  :   This routine attempts to determine the spacecraft potential numerically
;                 from a given Wind 3DP EESA Low distribution.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_wind_vs_themis_esa_struct.pro
;               is_a_number.pro
;               struct_value.pro
;               dat_3dp_str_names.pro
;               conv_units.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA       :  Scalar [structure] containing a Wind/3DP EESA Low
;                               distribution
;                               [see get_el.pro and get_elb.pro]
;
;  EXAMPLES:    
;               [calling sequence]
;               sc_pot = lbw_scpot_el(data [,DENS=dens] [,SC_POT_2=sc_pot_2])
;
;  KEYWORDS:    
;               DENS       :  Scalar or [N]-element [numeric] array defining the number
;                               density [cm^(-3)] to use for estimating the spacecraft
;                               potential [eV] output as SC_POT_2
;               SC_POT_2   :  Set to a named variable to return the numerical
;                               spacecraft potential [eV] estimate from an input
;                               number density [cm^(-3)], DENS
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: sc_pot_el.pro and sc_pot.pro    BY: Davin Larson
;   CREATED:  10/27/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/27/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_scpot_el,data,DENS=dens,SC_POT_2=sc_pot_2

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define model energy fluxes of photoelectrons for Wind
mod_enrg       = [1112.99, 689.161, 426.769, 264.837, 164.957, 103.320, 65.2431, 41.7663, 27.2489, 18.2895, 12.8144, 9.41315, 7.25627, 5.92896, 5.18234]
mod_efph       = [118.573, 535.125, 2771.57, 13780.8, 77791.3, 469253., 2.43850e+06, 1.00494e+07, 2.43219e+07, 4.05564e+07, 8.78649e+07, 1.45688e+08, 1.91214e+08, 2.66451e+08, 3.37626e+08]
;;  Define dummy array of energies for later
n_e0           = 40L
deran          = [4d0,3d2]
l10dran        = ALOG10(deran)
l10es          = DINDGEN(n_e0[0])*(l10dran[1] - l10dran[0])/(n_e0[0] - 1L) + l10dran[0]
dumb_es        = 1d1^l10es
;;  Error messages
noinput_mssg   = 'No input was supplied...'
badstr_mssg    = 'Not an appropriate 3DP structure...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check DAT structure format
test0          = test_wind_vs_themis_esa_struct(data[0],/NOM)
test           = (test0.(0) + test0.(1)) NE 1
IF (test[0]) THEN BEGIN
  MESSAGE,badstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DENS
IF (is_a_number(dens,/NOMSSG)) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  ADAPTED FROM: sc_pot.pro    BY: Davin Larson
  ;;--------------------------------------------------------------------------------------
  ;;--------------------------------------------------------------------------------------
  ;;  Define model params of interest
  ;;    ***  No explanation or rational given for these numbers in sc_pot.pro  ***
  ln_x           = ALOG([0.287739d0,0.892897d0,2.87739d0,22.0925d0])
  y0             = [22.0322d0,14.7480d0,9.80201d0,5.30560d0]
;  y2             = [0.00000d0,2.50982d0,1.43188d0,0.00000d0]
  y2             = SPL_INIT(ln_x,y0)
  ;;  Calculate ln|n|
  n_t            = 8d-1*REFORM(dens,N_ELEMENTS(dens))
  ln_n           = ALOG(n_t)
  ;;  Spline interpolate to find approximate spacecraft potential [eV]
  sc_pot_2       = SPL_INTERP(ln_x,y0,y2,ln_n,/DOUBLE)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Convert units to energy flux
;;----------------------------------------------------------------------------------------
dat            = data[0]
;;  Check for E_SHIFT tag
eshift         = struct_value(dat,'E_SHIFT',DEFAULT=0e0,INDEX=ind_eshft)
IF (ind_eshft[0] GE 0) THEN dat[0].ENERGY += eshift[0]    ;;  Adjust by E_SHIFT
;;  Check which instrument is being used
strns          = dat_3dp_str_names(dat[0])
IF (SIZE(strns,/TYPE) NE 8) THEN BEGIN
  ;;  Incorrect structure type
  MESSAGE,'Name Fail: '+badstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
shnme   = STRLOWCASE(STRMID(strns.SN[0],0L,2L))
CASE shnme[0] OF
  'el' :  elef   = conv_units(dat,'eflux')
  ELSE :  BEGIN
    MESSAGE,'Only EESA Low Allowed!',/INFORMATIONAL,/CONTINUE
    RETURN,0b
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Calculate relevant terms
;;----------------------------------------------------------------------------------------
;;  Calc omnidirectional average, <ef> [eV s^(-1) sr^(-1) cm^(-1) eV^(-1)]
omnidf         = MEAN(elef.DATA/elef.ENERGY^2d0,DIMENSION=2)
;;  Calculate energies [eV]
ener           = REVERSE(MEAN(elef.ENERGY,DIMENSION=2))
lnof           = REVERSE(ALOG(omnidf))
;;  Calculate a cheap derivative
dlnf           = (SHIFT(lnof,1) + SHIFT(lnof,-1) - 2d0*lnof)[1L:13L]
denr           = ener[1L:13L]
;;  Interpolate model eflux to energies of interest
ratio          = ALOG(1d0*mod_efph/mod_enrg^2d0)
photodf        = INTERPOL(ratio,mod_enrg,denr)
;;  Calculate spline of difference between observation and model
delta          = dlnf - (lnof[1L:13L] - photodf)
ddys           = SPLINE(denr,delta,dumb_es)
;;  Find maximum of the splined difference
mx_ddys        = MAX(ddys,/NAN,lx)
;;  The index corresponds to roughly the spacecraft potential [eV]
sc_pot         = dumb_es[lx[0]]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,sc_pot[0]
END
