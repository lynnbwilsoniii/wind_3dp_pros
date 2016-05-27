;+
;*****************************************************************************************
;
;  FUNCTION :   cold_plasma_etob_ratio.pro
;  PURPOSE  :   This program estimates the ratio of the electric to magnetic energy
;                 densities using cold plasma theory.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               cold_plasma_params.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGFO  :  Scalar ambient magnetic field magnitude (nT)
;               DENS   :  Scalar plasma density [cm^(-3)]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               FREQF  :  Scalar wave frequency (Hz)
;               ANGLE  :  Scalar wave propagation angle with respect to the magnetic
;                           field (degrees)
;               NDAT   :  Scalar number of values to create for dummy frequencies or
;                           angles  [Default = 100]
;               MAGF   :  Scalar wave amplitude (nT) used to estimate E-field amplitude
;               ELECF  :  Scalar wave amplitude (mV/m) used to estimate B-field amplitude
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If MAGF or ELECF keywords are set, then program will return estimate
;                     of corresponding wave amplitude in mV/m or nT, respectively.
;               2)  Theory is taken from:
;                    -Stix, T.H. (1962), The Theory of Plasma Waves, McGraw-Hill.
;                    -Mosier, S.R. and D.A. Gurnett (1971), Theory of the Injun 5 Very-
;                         Low-Frequency Poynting Flux Measurements, J. Geophys. Res.
;                         Vol. 76, pp. 972-977.
;                    -Lengyel-Frey, D. et al. (1994), An analysis of whistler waves at
;                         interplanetary shocks, J. Geophys. Res. Vol. 99, pp. 13,325.
;               3)  Default return is the ratio of the E-field energy density to the
;                     B-field energy density [i.e. ratio of Eq. 4 to 3 from 
;                     Lengyel-Frey et al. 1994]
;
;   CREATED:  04/12/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/12/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION cold_plasma_etob_ratio,magfo,dens,FREQF=freqf,ANGLE=angle,$
                                NDAT=ndat,MAGF=magf,ELECF=elecf

;-----------------------------------------------------------------------------------------
; => Constants
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
c        = 2.99792458d8      ; -Speed of light in vacuum (m/s)
kB       = 1.380658d-23      ; -Boltzmann Constant (J/K)
epo      = 8.854187817d-12   ; -Permittivity of free space (F/m)
muo      = 4d0*!DPI*1d-7     ; -Permeability of free space (N/A^2 or H/m)
me       = 9.1093897d-31     ; -Electron mass (kg)
mp       = 1.6726231d-27     ; -Proton mass (kg)
qq       = 1.60217733d-19    ; => Fundamental charge (C)
wcefac   = qq/me
wcpfac   = qq/mp
wpefac   = SQRT(qq^2/me/epo)
wppfac   = SQRT(qq^2/mp/epo)
tags     = ['PLUS_SIGN','MINUS_SIGN','DEF','POYNTING_FLUX_P','POYNTING_FLUX_M',$
            'GTERM_P','GTERM_M','FTERM_P','FTERM_M','LTERM_P','LTERM_M']

badmssg  = 'Incorrect input, calling sequence:  test = cold_plasma_etob_ratio(magfo,dens)'
badkeym  = 'Incorrect keyword use:  Must only set EITHER MAGF OR ELECF, not both...'

IF (~KEYWORD_SET(ndat) OR N_ELEMENTS(ndat) EQ 0) THEN ndat = 100L ELSE ndat = LONG(ndat)

IF (~KEYWORD_SET(magf)  OR N_ELEMENTS(magf)  EQ 0) THEN bfield = 0 ELSE bfield = 1
IF (~KEYWORD_SET(elecf) OR N_ELEMENTS(elecf) EQ 0) THEN efield = 0 ELSE efield = 1
IF (~efield AND ~bfield) THEN edensity = 1 ELSE edensity = 0
keys     = [bfield,efield,edensity]
temp     = TOTAL(keys) NE 1.0
IF (temp) THEN BEGIN
  MESSAGE,badkeym,/INFORMATIONAL,/CONTINUE
  bfield   = 0
  efield   = 0
  edensity = 1
ENDIF
keys     = [bfield,efield,edensity]

IF (N_PARAMS() NE 2) THEN BEGIN
  MESSAGE,badmssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;-----------------------------------------------------------------------------------------
; => Calculate cold plasma parameters
;-----------------------------------------------------------------------------------------
test    = cold_plasma_params(magfo[0],dens[0],FREQF=freqf,ANGLE=angle,NDAT=ndat)
; => Define cold plasma terms from Eqs. 10-13 and 26 in Stix [1962]
nsqr0   = test.INDEX_REF_0     ; => Soln. with + sign in Eq. 26 of Stix [1962]
nsqr1   = test.INDEX_REF_1     ; => Soln. with - sign in Eq. 26 of Stix [1962]
dterm   = test.D_TERM          ; => Eq. 10 of Stix [1962]
sterm   = test.S_TERM          ; => Eq. 10 of Stix [1962]
pterm   = test.P_TERM          ; => Eq. 13 of Stix [1962]
freqs   = test.W_FREQS         ; => Frequencies used [Hz]
angles  = test.ANGLES          ; => Angles used [deg]

nf      = N_ELEMENTS(freqs)    ; => # of frequencies
na      = N_ELEMENTS(angles)   ; => # of angles
ctheta  = COS(angles*!DPI/18d1)
stheta  = SIN(angles*!DPI/18d1)
ttheta  = TAN(angles*!DPI/18d1)

; => [dterm,sterm,pterm] = [NF]-Element array
; => [nsqr0,nsqr1] = [NF, NA]-Element array
gterm0  = DBLARR(nf,na)
gterm1  = DBLARR(nf,na)
fterm0  = DBLARR(nf,na)
fterm1  = DBLARR(nf,na)
lterm0  = DBLARR(nf,na)
lterm1  = DBLARR(nf,na)
; => use nf < na to make faster
good    = WHERE([(nf < na) EQ nf, (nf < na) EQ na],gd)

CASE good[0] OF
  0L   : BEGIN
    FOR j=0L, nf - 1L DO BEGIN
      gterm0[j,*] = dterm[j]/(sterm[j] - nsqr0[j,*])
      gterm1[j,*] = dterm[j]/(sterm[j] - nsqr1[j,*])
      fterm0[j,*] = pterm[j]*ctheta/(pterm[j] - nsqr0[j,*]*stheta^2)
      fterm1[j,*] = pterm[j]*ctheta/(pterm[j] - nsqr1[j,*]*stheta^2)
      lterm0[j,*] = (nsqr0[j,*]*ctheta*stheta)/(pterm[j] - nsqr0[j,*]*stheta^2)
      lterm1[j,*] = (nsqr1[j,*]*ctheta*stheta)/(pterm[j] - nsqr1[j,*]*stheta^2)
    ENDFOR
  END
  1L   : BEGIN
    FOR j=0L, na - 1L DO BEGIN
      gterm0[*,j] = dterm/(sterm - nsqr0[*,j])
      gterm1[*,j] = dterm/(sterm - nsqr1[*,j])
      fterm0[*,j] = pterm*ctheta[j]/(pterm - nsqr0[*,j]*stheta[j]^2)
      fterm1[*,j] = pterm*ctheta[j]/(pterm - nsqr1[*,j]*stheta[j]^2)
      lterm0[*,j] = (nsqr0[*,j]*ctheta[j]*stheta[j])/(pterm - nsqr0[*,j]*stheta[j]^2)
      lterm1[*,j] = (nsqr1[*,j]*ctheta[j]*stheta[j])/(pterm - nsqr1[*,j]*stheta[j]^2)
    ENDFOR
  END
  ELSE :   ; => Not sure how you managed this...
ENDCASE
;-----------------------------------------------------------------------------------------
; => |E|^2 =     {1 + G^2 + L^2} E_{o}^2
; => |B|^2 = n^2 {G^2 + F^2} E_{o}^2
;
;   =>  E_{o}^2 = |B|^2/( n^2 {G^2 + F^2} )
;
;   =>  |E|^2   = [{1 + G^2 + L^2}/( n^2 {G^2 + F^2} )] |B|^2
;-----------------------------------------------------------------------------------------
; => Let fac_{0,1} = {1 + G^2 + L^2}
fac_0   = 1d0 + gterm0^2 + lterm0^2
fac_1   = 1d0 + gterm1^2 + lterm1^2
eratio0 = fac_0/2d0  ; => [ = (|E|/E_{o})^2]
eratio1 = fac_1/2d0
; => Let fac_{2,3} = {G^2 + H^2}
fac_2   = gterm0^2 + fterm0^2
fac_3   = gterm1^2 + fterm1^2
; => Calculate n^2 {G^2 + H^2} [ = (|B|/E_{o})^2]
bratio0 = nsqr0*fac_2/(2d0*c^2)
bratio1 = nsqr1*fac_3/(2d0*c^2)
; => Calculate Sx/(c<|B|^2>) = (Cos[theta]/(mu_o n) * [FL + G^2 Tan[theta]])
; => Calculate Sy/(c<|B|^2>) = (Cos[theta]/(mu_o n) * [G*(L - Tan[theta])])
; => Calculate Sz/(c<|B|^2>) = (Cos[theta]/(mu_o n) * [F + G^2])
sfb0    = DBLARR(nf,na,3)
sfb1    = DBLARR(nf,na,3)
; => Let JJ = (n Cos[theta])/(mu_o c (1 + G^2 + L^2))
; => Calculate Sx/(<|E|^2>) = JJ * [FL + G^2 Tan[theta]]
; => Calculate Sy/(<|E|^2>) = JJ * [G*(L - Tan[theta])])
; => Calculate Sz/(<|E|^2>) = JJ * [F + G^2])
sfe0    = DBLARR(nf,na,3)
sfe1    = DBLARR(nf,na,3)

FOR j=0L, na - 1L DO BEGIN
  xterm0      = (fterm0[*,j]*lterm0[*,j] + gterm0[*,j]^2*ttheta[j])
  yterm0      = (gterm0[*,j]*(lterm0[*,j] - ttheta[j]))
  zterm0      = (fterm0[*,j] + gterm0[*,j]^2)
  xterm1      = (fterm1[*,j]*lterm1[*,j] + gterm1[*,j]^2*ttheta[j])
  yterm1      = (gterm1[*,j]*(lterm1[*,j] - ttheta[j]))
  zterm1      = (fterm1[*,j] + gterm1[*,j]^2)
  ; => First from B-field estimates
  fac0        = (ctheta[j]/(muo*nsqr0[*,j]))
  fac1        = (ctheta[j]/(muo*nsqr1[*,j]))
  sfb0[*,j,0] = fac0*xterm0
  sfb1[*,j,0] = fac1*xterm1
  sfb0[*,j,1] = fac0*yterm0
  sfb1[*,j,1] = fac1*yterm1
  sfb0[*,j,2] = fac0*zterm0
  sfb1[*,j,2] = fac1*zterm1
  ; => Now from E-field estimates
  fac0        = (nsqr0[*,j]*ctheta[j])/(muo*c*(1d0 + gterm0[*,j]^2 + lterm0[*,j]^2))
  fac1        = (nsqr1[*,j]*ctheta[j])/(muo*c*(1d0 + gterm1[*,j]^2 + lterm1[*,j]^2))
  sfe0[*,j,0] = fac0*xterm0
  sfe1[*,j,0] = fac1*xterm1
  sfe0[*,j,1] = fac0*yterm0
  sfe1[*,j,1] = fac1*yterm1
  sfe0[*,j,2] = fac0*zterm0
  sfe1[*,j,2] = fac1*zterm1
ENDFOR

;-----------------------------------------------------------------------------------------
; => Determine what is returned
;-----------------------------------------------------------------------------------------
good = WHERE(keys,gd)
CASE good[0] OF
  0L   : BEGIN
    efield0 = DCOMPLEXARR(nf,na)
    efield1 = DCOMPLEXARR(nf,na)
    ; => B-field given, return E-field estimate
    bf0      = magf[0]*1d-9  ; => Convert to T
    fac0     = (bf0[0]*c)^2
    temp0    = fac0[0]*fac_0/(fac_2*nsqr0)
    temp1    = fac0[0]*fac_1/(fac_3*nsqr1)
    imag0    = WHERE(temp0 LT 0,bd0,COMPLEMENT=real0,NCOMPLEMENT=gd0)
    imag1    = WHERE(temp1 LT 0,bd1,COMPLEMENT=real1,NCOMPLEMENT=gd1)
    ; => Make sure values aren't negative prior to taking the root
    IF (bd0 GT 0) THEN BEGIN
      efield0[imag0] = SQRT(COMPLEX(0d0,temp0[imag0]))
      IF (gd0 GT 0) THEN efield0[real0] = SQRT(COMPLEX(temp0[real0],0d0))
    ENDIF ELSE BEGIN
      efield0 = ABS(SQRT(temp0))
    ENDELSE
    IF (bd1 GT 0) THEN BEGIN
      efield1[imag1] = SQRT(COMPLEX(0d0,temp1[imag1]))
      IF (gd1 GT 0) THEN efield1[real1] = SQRT(COMPLEX(temp1[real1],0d0))
    ENDIF ELSE BEGIN
      efield1        = ABS(SQRT(temp1))
    ENDELSE
    efield0 *= 1d3  ; => the 1d3 is for conversion to mV/m
    efield1 *= 1d3  ; => the 1d3 is for conversion to mV/m
    sfield0  = sfb0*(bf0[0]*c)
    sfield1  = sfb1*(bf0[0]*c)
    sfield0  = SQRT(TOTAL(sfield0^2,3,/NAN))
    sfield1  = SQRT(TOTAL(sfield1^2,3,/NAN))
    struct   = CREATE_STRUCT(tags,efield0,efield1,'EFIELD',sfield0,sfield1,$
                             gterm0,gterm1,fterm0,fterm1,lterm0,lterm1)
    RETURN,struct
  END
  1L   : BEGIN
    bfield0 = DCOMPLEXARR(nf,na)
    bfield1 = DCOMPLEXARR(nf,na)
    ; => E-field given, return B-field estimate
    ef0     = elecf[0]*1d-3  ; => Convert to V/m
    fac0    = (ef0[0]/c)^2
    temp0   = fac0[0]*nsqr0*fac_2/fac_0
    temp1   = fac0[0]*nsqr1*fac_3/fac_1
    imag0    = WHERE(temp0 LT 0,bd0,COMPLEMENT=real0,NCOMPLEMENT=gd0)
    imag1    = WHERE(temp1 LT 0,bd1,COMPLEMENT=real1,NCOMPLEMENT=gd1)
    ; => Make sure values aren't negative prior to taking the root
    IF (bd0 GT 0) THEN BEGIN
      bfield0[imag0] = SQRT(COMPLEX(0d0,temp0[imag0]))
      IF (gd0 GT 0) THEN bfield0[real0] = SQRT(COMPLEX(temp0[real0],0d0))
    ENDIF ELSE BEGIN
      bfield0 = ABS(SQRT(temp0))
    ENDELSE
    IF (bd1 GT 0) THEN BEGIN
      bfield1[imag1] = SQRT(COMPLEX(0d0,temp1[imag1]))
      IF (gd1 GT 0) THEN bfield1[real1] = SQRT(COMPLEX(temp1[real1],0d0))
    ENDIF ELSE BEGIN
      bfield1        = ABS(SQRT(temp1))
    ENDELSE
    bfield0 *= 1d9   ; => Convert to nT
    bfield1 *= 1d9   ; => Convert to nT
    sfield0  = sfb0*(ef0[0])
    sfield1  = sfb1*(ef0[0])
    sfield0  = SQRT(TOTAL(sfield0^2,3,/NAN))
    sfield1  = SQRT(TOTAL(sfield1^2,3,/NAN))
    struct   = CREATE_STRUCT(tags,bfield0,bfield1,'BFIELD',sfield0,sfield1,$
                             gterm0,gterm1,fterm0,fterm1,lterm0,lterm1)
    RETURN,struct
  END
  2L   : BEGIN
    ; => Neither given, return ratio of energy densities
    edens_rat0 = eratio0/bratio0
    edens_rat1 = eratio1/bratio1
    sfield0  = SQRT(TOTAL(sfb1^2,3,/NAN))*(muo/c)  ; => Normalized
    sfield1  = SQRT(TOTAL(sfe1^2,3,/NAN))*(muo*c)
    struct     = CREATE_STRUCT(tags,edens_rat0,edens_rat1,'RATIO',gterm0,gterm1,$
                               fterm0,fterm1,lterm0,lterm1)
    RETURN,struct
  END
  ELSE : RETURN,0  ; => Not sure how you managed this...
ENDCASE

END