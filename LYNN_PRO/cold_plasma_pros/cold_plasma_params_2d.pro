;+
;*****************************************************************************************
;
;  FUNCTION :   stix_params_1962_1d.pro
;  PURPOSE  :   Calculates the cold plasma parameters from Stix, [1962].
;
;  CALLED BY:   
;               cold_plasma_params_2d.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  N-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;               FREQW  :  N-Element array of wave frequencies (rad/s)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed a typo where wce was not < 0               [05/10/2011   v1.0.1]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  04/15/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/10/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  stix_params_1962_1d,magf,dens,freqw

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epo            = 8.854187817d-12        ; => Permittivity of free space (F/m)
muo            = 4d0*!DPI*1d-7          ; => Permeability of free space (N/A^2 or H/m)
me             = 9.1093897d-31          ; => Electron mass (kg)
mp             = 1.6726231d-27          ; => Proton mass (kg)
qq             = 1.60217733d-19         ; => Fundamental charge (C)
K_eV           = 1.160474d4             ; => Conversion = degree Kelvin/eV
kB             = 1.380658d-23           ; => Boltzmann Constant (J/K)
c              = 2.99792458d8           ; => Speed of light in vacuum (m/s)
wcefac         = qq/me                  ; => Electron cyclotron frequency factor
wcpfac         = qq/mp                  ; => Proton cyclotron frequency factor
wpefac         = SQRT(qq^2/me/epo)      ; => Electron plasma frequency factor
wppfac         = SQRT(qq^2/mp/epo)      ; => Proton plasma frequency factor
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
pdens   = REFORM(dens)*1d6              ; => Convert density to # m^(-3)
bmag    = REFORM(magf)*1d-9             ; => Convert B-field to T
nn      = N_ELEMENTS(pdens)             ; => # of density and B-field data points
nf      = N_ELEMENTS(freqw)             ; => # of frequency data points
wce     = wcefac[0]*bmag                ; => Electron Cyclotron frequency (radians/s)
wpe     = wpefac[0]*SQRT(pdens)         ; => Electron Plasma frequency (radians/s)
wcp     = wcpfac[0]*bmag                ; => Proton Cyclotron frequency (radians/s)
wpp     = wppfac[0]*SQRT(pdens)         ; => Proton Plasma frequency (radians/s)
; => wce < 0 due to electron charge
wce    *= -1d0
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
S_term   = DBLARR(nf)       ; => Eq. 10 from [S1962]  [NF x NN]-Element Array
D_term   = DBLARR(nf)       ; => Eq. 10 from [S1962]  [NF x NN]-Element Array
R_term   = DBLARR(nf)       ; => Eq. 11 from [S1962]  [NF x NN]-Element Array
L_term   = DBLARR(nf)       ; => Eq. 12 from [S1962]  [NF x NN]-Element Array
P_term   = DBLARR(nf)       ; => Eq. 13 from [S1962]  [NF x NN]-Element Array
res_cang = REPLICATE(d,nf)  ; => Resonance cone angle (deg) {Eq. 36 from [S1962], pg. 12}
; => Alfven index of refraction {Eq. 4.4.28 from [GB2005]}
;       [derived by taking n^2 to the limit of zero frequency]
n_Alfv   = DBLARR(nf)                   
n_Alfv   = 1d0 + (wpe^2)/(wce^2) + (wpp^2)/(wcp^2)
; => These terms only depend upon the wave frequency, not the propagation direction
;      so we can calculate them regardless of the number of elements in FREQW
S_term   = 1d0 - (wpe^2)/(freqw^2 - wce^2) -          $
                 (wpp^2)/(freqw^2 - wcp^2)
D_term   = (wce*wpe^2)/(freqw*(freqw^2 - wce^2)) + $
           (wcp*wpp^2)/(freqw*(freqw^2 - wcp^2))
P_term   = 1d0 - (wpe^2)/(freqw^2) - (wpp^2)/(freqw^2)
R_term   = 1d0 - (wpe^2)/(freqw*(freqw + wce)) -      $
                 (wpp^2)/(freqw*(freqw + wcp))
L_term   = 1d0 - (wpe^2)/(freqw*(freqw - wce)) -      $
                 (wpp^2)/(freqw*(freqw - wcp))
; => Test to see if the sign of P_term and S_term are not the same
test_res      = P_term/ABS(P_term) NE S_term/ABS(S_term)
good_res      = WHERE(test_res,gdres,COMPLEMENT=bad_res,NCOMPLEMENT=bdres)
IF (gdres GT 0) THEN BEGIN
  res_cang[good_res] = ATAN(SQRT(-1d0*P_term[good_res]/S_term[good_res]))*18d1/!DPI
ENDIF
;-----------------------------------------------------------------------------------------
; => Return data structure
;-----------------------------------------------------------------------------------------
tags  = ['S_TERM','D_TERM','P_TERM','R_TERM','L_TERM','INDEX_ALFVEN','CONE_ANG']
struc = CREATE_STRUCT(tags,S_term,D_term,P_term,R_term,L_term,n_Alfv,res_cang)

RETURN,struc
END

;+
;*****************************************************************************************
;
;  FUNCTION :   stix_params_1962_2d.pro
;  PURPOSE  :   Calculates the cold plasma parameters from Stix, [1962].
;
;  CALLED BY:   
;               cold_plasma_params_2d.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  N-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;               FREQW  :  M-Element array of wave frequencies (rad/s)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed a typo where wce was not < 0               [05/10/2011   v1.0.1]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  04/15/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/10/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  stix_params_1962_2d,magf,dens,freqw

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epo            = 8.854187817d-12        ; => Permittivity of free space (F/m)
muo            = 4d0*!DPI*1d-7          ; => Permeability of free space (N/A^2 or H/m)
me             = 9.1093897d-31          ; => Electron mass (kg)
mp             = 1.6726231d-27          ; => Proton mass (kg)
qq             = 1.60217733d-19         ; => Fundamental charge (C)
K_eV           = 1.160474d4             ; => Conversion = degree Kelvin/eV
kB             = 1.380658d-23           ; => Boltzmann Constant (J/K)
c              = 2.99792458d8           ; => Speed of light in vacuum (m/s)
wcefac         = qq/me                  ; => Electron cyclotron frequency factor
wcpfac         = qq/mp                  ; => Proton cyclotron frequency factor
wpefac         = SQRT(qq^2/me/epo)      ; => Electron plasma frequency factor
wppfac         = SQRT(qq^2/mp/epo)      ; => Proton plasma frequency factor
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
pdens   = REFORM(dens)*1d6              ; => Convert density to # m^(-3)
bmag    = REFORM(magf)*1d-9             ; => Convert B-field to T
nn      = N_ELEMENTS(pdens)             ; => # of density and B-field data points
nf      = N_ELEMENTS(freqw)             ; => # of frequency data points
wce     = wcefac[0]*bmag                ; => Electron Cyclotron frequency (radians/s)
wpe     = wpefac[0]*SQRT(pdens)         ; => Electron Plasma frequency (radians/s)
wcp     = wcpfac[0]*bmag                ; => Proton Cyclotron frequency (radians/s)
wpp     = wppfac[0]*SQRT(pdens)         ; => Proton Plasma frequency (radians/s)
; => wce < 0 due to electron charge
wce    *= -1d0
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
S_term   = DBLARR(nf,nn)       ; => Eq. 10 from [S1962]  [NF x NN]-Element Array
D_term   = DBLARR(nf,nn)       ; => Eq. 10 from [S1962]  [NF x NN]-Element Array
R_term   = DBLARR(nf,nn)       ; => Eq. 11 from [S1962]  [NF x NN]-Element Array
L_term   = DBLARR(nf,nn)       ; => Eq. 12 from [S1962]  [NF x NN]-Element Array
P_term   = DBLARR(nf,nn)       ; => Eq. 13 from [S1962]  [NF x NN]-Element Array
res_cang = REPLICATE(d,nf,nn)  ; => Resonance cone angle (deg) {Eq. 36 from [S1962], pg. 12}
; => Alfven index of refraction {Eq. 4.4.28 from [GB2005]}
;       [derived by taking n^2 to the limit of zero frequency]
n_Alfv   = DBLARR(nn)                   
n_Alfv   = 1d0 + (wpe^2)/(wce^2) + (wpp^2)/(wcp^2)
; => These terms only depend upon the wave frequency, not the propagation direction
;      so we can calculate them regardless of the number of elements in FREQW
ns       = (nn < nf) EQ [nn,nf]
good     = WHERE(ns,gd)
CASE good[0] OF
  0L   : BEGIN
    ; => There are less density and B-field data points
    FOR j=0L, nn - 1L DO BEGIN
      S_term[*,j]   = 1d0 - (wpe[j]^2)/(freqw^2 - wce[j]^2) -          $
                            (wpp[j]^2)/(freqw^2 - wcp[j]^2)
      D_term[*,j]   = (wce[j]*wpe[j]^2)/(freqw*(freqw^2 - wce[j]^2)) + $
                      (wcp[j]*wpp[j]^2)/(freqw*(freqw^2 - wcp[j]^2))
      P_term[*,j]   = 1d0 - (wpe[j]^2)/(freqw^2) - (wpp[j]^2)/(freqw^2)
      R_term[*,j]   = 1d0 - (wpe[j]^2)/(freqw*(freqw + wce[j])) -      $
                            (wpp[j]^2)/(freqw*(freqw + wcp[j]))
      L_term[*,j]   = 1d0 - (wpe[j]^2)/(freqw*(freqw - wce[j])) -      $
                            (wpp[j]^2)/(freqw*(freqw - wcp[j]))
      ; => Test to see if the sign of P_term and S_term are not the same
      test_res      = P_term[*,j]/ABS(P_term[*,j]) NE S_term[*,j]/ABS(S_term[*,j])
      good_res      = WHERE(test_res,gdres,COMPLEMENT=bad_res,NCOMPLEMENT=bdres)
      IF (gdres GT 0) THEN BEGIN
        res_cang[good_res,j] = ATAN(SQRT(-1d0*P_term[good_res,j]/S_term[good_res,j]))*18d1/!DPI
      ENDIF
    ENDFOR
  END
  1L   : BEGIN
    ; => There are less frequency data points
    FOR j=0L, nf - 1L DO BEGIN
      S_term[j,*]   = 1d0 - (wpe^2)/(freqw[j]^2 - wce^2) -          $
                            (wpp^2)/(freqw[j]^2 - wcp^2)
      D_term[j,*]   = (wce*wpe^2)/(freqw[j]*(freqw[j]^2 - wce^2)) + $
                      (wcp*wpp^2)/(freqw[j]*(freqw[j]^2 - wcp^2))
      P_term[j,*]   = 1d0 - (wpe^2)/(freqw[j]^2) - (wpp^2)/(freqw[j]^2)
      R_term[j,*]   = 1d0 - (wpe^2)/(freqw[j]*(freqw[j] + wce)) -      $
                            (wpp^2)/(freqw[j]*(freqw[j] + wcp))
      L_term[j,*]   = 1d0 - (wpe^2)/(freqw[j]*(freqw[j] - wce)) -      $
                            (wpp^2)/(freqw[j]*(freqw[j] - wcp))
      ; => Test to see if the sign of P_term and S_term are not the same
      test_res      = P_term[j,*]/ABS(P_term[j,*]) NE S_term[j,*]/ABS(S_term[j,*])
      good_res      = WHERE(test_res,gdres,COMPLEMENT=bad_res,NCOMPLEMENT=bdres)
      IF (gdres GT 0) THEN BEGIN
        res_cang[j,good_res] = ATAN(SQRT(-1d0*P_term[j,good_res]/S_term[j,good_res]))*18d1/!DPI
      ENDIF
    ENDFOR
  END
  ELSE :   ; => Not sure how you managed this...
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return data structure
;-----------------------------------------------------------------------------------------
tags  = ['S_TERM','D_TERM','P_TERM','R_TERM','L_TERM','INDEX_ALFVEN','CONE_ANG']
struc = CREATE_STRUCT(tags,S_term,D_term,P_term,R_term,L_term,n_Alfv,res_cang)

RETURN,struc
END

;+
;*****************************************************************************************
;
;  FUNCTION :   cold_plasma_params_2d.pro
;  PURPOSE  :   Calculates cold plasma Stix parameters assuming an electron-proton
;                 quasi-neutral plasma.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               stix_params_1962_1d.pro
;               stix_params_1962_2d.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  N-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;
;  EXAMPLES:    
;               ; => Assume:  |B|   = 10 nT
;               ;             n_o   = 7 cm^(-3)
;               ;             freq  = 85 Hz
;               ;             theta = 20 degrees
;               ;             [typical solar wind parameters]
;               test = cold_plasma_params_2d(10.,7.,FREQF=85.,ANGLE=20.)
;
;  KEYWORDS:    
;               FREQF  :  M-Element array of wave frequencies (Hz)
;               ANGLE  :  L-Element array of wave propagation angles with respect to
;                           the magnetic field (degrees)
;               NDAT   :  Scalar number of values to create for dummy frequencies or
;                           angles if FREQF or ANGLE not set [Default = 100]
;               ONED   :  If set, all parameters are assumed to have the same number of
;                           elements and MAGF[j] corresponds to DENS[j] and FREQF[j] and
;                           ANGLE[j] => all returned values with be 1-Dimensional arrays
;
;   CHANGED:  1)  Fixed a typo where wce was not < 0               [05/10/2011   v1.0.1]
;
;   NOTES:      
;               1)  If MAGF and DENS have more than one element, then they must have
;                     the same number of elements.  The program assumes that they
;                     correspond to the same place/time measurement and will use them
;                     as such.
;               2)  FREQF and ANGLE can have different numbers of elements, but be 
;                     careful so you don't run out of memory as the return values
;                     can be [NF x NN x NA]-Element Arrays
;  REFERENCES:
;               **[GB2005]**
;               Gurnett, D. A., and A. Bhattacharjee (2005), "Introduction to Plasma
;                 Physics: With Space and Laboratory Applications," ISBN 0521364833. 
;                 Cambridge, UK: Cambridge University Press.
;               **[S1962]**
;               Stix, T. H. (1962), The Theory of Plasma Waves, McGraw-Hill.
;               
;
;   CREATED:  04/15/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/10/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  cold_plasma_params_2d,magf,dens,FREQF=freqf,ANGLE=angles,NDAT=ndat,ONED=oned

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epo            = 8.854187817d-12        ; => Permittivity of free space (F/m)
muo            = 4d0*!DPI*1d-7          ; => Permeability of free space (N/A^2 or H/m)
me             = 9.1093897d-31          ; => Electron mass (kg)
mp             = 1.6726231d-27          ; => Proton mass (kg)
qq             = 1.60217733d-19         ; => Fundamental charge (C)
K_eV           = 1.160474d4             ; => Conversion = degree Kelvin/eV
kB             = 1.380658d-23           ; => Boltzmann Constant (J/K)
c              = 2.99792458d8           ; => Speed of light in vacuum (m/s)
wcefac         = qq/me                  ; => Electron cyclotron frequency factor
wcpfac         = qq/mp                  ; => Proton cyclotron frequency factor
wpefac         = SQRT(qq^2/me/epo)      ; => Electron plasma frequency factor
wppfac         = SQRT(qq^2/mp/epo)      ; => Proton plasma frequency factor

badinmssg      = 'Incorrect input:  MAGF and DENS must have the same number of elements'
badkeymssg     = 'Incorrect keyword use:  MAGF, DENS, and FREQF must have the same number of elements'
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,0
pdens   = REFORM(dens)*1d6              ; => Convert density to # m^(-3)
bmag    = REFORM(magf)*1d-9             ; => Convert B-field to T
nd      = N_ELEMENTS(pdens)
nb      = N_ELEMENTS(bmag)
IF (nd NE nb) THEN BEGIN
  MESSAGE,badinmssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
nn      = nd                            ; => # of density and B-field data points

wce     = wcefac[0]*bmag                ; => Electron Cyclotron frequency (radians/s)
wpe     = wpefac[0]*SQRT(pdens)         ; => Electron Plasma frequency (radians/s)
wcp     = wcpfac[0]*bmag                ; => Proton Cyclotron frequency (radians/s)
wpp     = wppfac[0]*SQRT(pdens)         ; => Proton Plasma frequency (radians/s)

IF (~KEYWORD_SET(ndat) OR N_ELEMENTS(ndat) EQ 0) THEN BEGIN
  IF KEYWORD_SET(oned) THEN ndat = nn ELSE ndat = 100L
ENDIF ELSE BEGIN
  IF (KEYWORD_SET(oned) AND LONG(ndat[0]) NE nn) THEN BEGIN
    ndat = nn 
  ENDIF ELSE BEGIN
    IF KEYWORD_SET(oned) THEN ndat = nn ELSE ndat = LONG(ndat[0])
  ENDELSE
ENDELSE


IF (KEYWORD_SET(freqf) OR N_ELEMENTS(freqf) NE 0) THEN BEGIN
  freqw   = REFORM(freqf)*(2d0*!DPI)      ; => Convert wave frequency to radians/s
ENDIF ELSE BEGIN
  ; => Use frequencies from 0 to w_ce or wpe, which ever is higher
  whigher = wce[0] > wpe[0]
  freqw   = DINDGEN(ndat)*(whigher[0] - wcp[0])/(ndat - 1L) + wcp[0]
ENDELSE
IF (KEYWORD_SET(angles) OR N_ELEMENTS(angles) NE 0) THEN BEGIN
  angle   = REFORM(angles)*!DPI/18d1
ENDIF ELSE BEGIN
  ; => Use angles from 0 to pi/2
  angle   = DINDGEN(ndat)*(!DPI/2d0)/(ndat - 1L)
ENDELSE
; => wce < 0 due to electron charge
wce    *= -1d0

cthkb   = COS(angle)                    ; => Convert angles to cosines
sthkb   = SIN(angle)                    ; => Convert angles to sines
cthkb2  = cthkb^2
sthkb2  = sthkb^2
cthkb4  = cthkb^4
sthkb4  = sthkb^4

na      = N_ELEMENTS(angle)    ; => # of angle bins
nf      = N_ELEMENTS(freqw)    ; => # of frequency data points
nn      = N_ELEMENTS(pdens)    ; => # of density and B-field data points
;-----------------------------------------------------------------------------------------
; => Calculate the S, D, P, R, and L-terms from [S1962] {Eqs. 10-13, pg. 10}
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(oned) THEN BEGIN
  testnn  = (na EQ nf) AND (na EQ nn) AND (nf EQ nn)
  IF (testnn) THEN BEGIN
    sparms  = stix_params_1962_1d(magf,dens,freqw)
  ENDIF ELSE BEGIN
    MESSAGE,badkeymssg,/INFORMATIONAL,/CONTINUE
    RETURN,0
  ENDELSE
ENDIF ELSE BEGIN
  sparms  = stix_params_1962_2d(magf,dens,freqw)
ENDELSE
; => The following are [NF x NN]-Element Arrays unless ONED is set, then they are [NN]-Element Array
S_term  = sparms.S_TERM        ; => Eq. 10 pg. 10 from [S1962]
D_term  = sparms.D_TERM        ; => Eq. 10 pg. 10 from [S1962]
R_term  = sparms.R_TERM        ; => Eq. 11 pg. 10 from [S1962]
L_term  = sparms.L_TERM        ; => Eq. 12 pg. 10 from [S1962]
P_term  = sparms.P_TERM        ; => Eq. 13 pg. 10 from [S1962]
rescone = sparms.CONE_ANG      ; => Eq. 36 from [S1962], pg. 12
; => [NN]-Element Array regardless of whether ONED is set
n_Alfv  = sparms.INDEX_ALFVEN  ; => Eq. 4.4.28 from [GB2005] 
RL_term = R_term*L_term
PS_term = P_term*S_term
PD_term = P_term*D_term
;-----------------------------------------------------------------------------------------
; => Calculate the A, B, and F-terms from [S1962] {Eqs. 22, 23, and 27, pgs. 11 and 12}
;
; => Note:  A_term, B_term, and F_term must be real => Any NaN or imaginary terms should
;            be removed accordingly
;-----------------------------------------------------------------------------------------

; => A_term = S Sin^2[theta] + P Cos^2[theta]
; => B_term = R L Sin^2[theta] + P S (1 + Cos^2[theta])
; => F_term = ((R L - P S)^2 Sin^4[theta] + 4 (P D)^2 Cos^2[theta])^(1/2)

IF KEYWORD_SET(oned) THEN BEGIN
  A_term  = S_term*sthkb2 + P_term*cthkb2
  B_term  = RL_term*sthkb2 + PS_term*(1d0 + cthkb2)
  F_term  = SQRT((RL_term - PS_term)^2*sthkb4 + 4d0*PD_term^2*cthkb2)
ENDIF ELSE BEGIN
  A_term  = DBLARR(nf,nn,na)     ; => Eq. 22 pg. 11 from [S1962]  [NF x NN x NA]-Element Array
  B_term  = DBLARR(nf,nn,na)     ; => Eq. 23 pg. 11 from [S1962]  [NF x NN x NA]-Element Array
  F_term  = DBLARR(nf,nn,na)     ; => Eq. 27 pg. 12 from [S1962]  [NF x NN x NA]-Element Array
  FOR j=0L, na - 1L DO BEGIN
    A_term[*,*,j] = S_term*sthkb2[j] + P_term*cthkb2[j]
    B_term[*,*,j] = RL_term*sthkb2[j] + PS_term*(1d0 + cthkb2[j])
    F_term[*,*,j] = SQRT((RL_term - PS_term)^2*sthkb4[j] + 4d0*PD_term^2*cthkb2[j])
  ENDFOR
ENDELSE
;-----------------------------------------------------------------------------------------
; => Calculate the cold plasma index of refraction {Eq. 26 from [S1962], pg. 12}
;-----------------------------------------------------------------------------------------
nsquared_0  = (B_term + F_term)/(2d0*A_term)
nsquared_1  = (B_term - F_term)/(2d0*A_term)
;-----------------------------------------------------------------------------------------
; => Return data structure
;-----------------------------------------------------------------------------------------
tags  = ['S_TERM','D_TERM','P_TERM','R_TERM','L_TERM','A_TERM','B_TERM','F_TERM',$
         'INDEX_REF_0','INDEX_REF_1','INDEX_ALFVEN','ANGLES','W_FREQS','CONE_ANG']
struc = CREATE_STRUCT(tags,S_term,D_term,P_term,R_term,L_term,A_term,B_term,F_term,$
                      nsquared_0,nsquared_1,n_Alfv,angle*18d1/!DPI,freqw/(2d0*!DPI),$
                      rescone)


RETURN,struc
END