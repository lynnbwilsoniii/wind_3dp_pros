;+
;*****************************************************************************************
;
;  FUNCTION :   cold_plasma_params.pro
;  PURPOSE  :   Calculates cold plasma Stix parameters assuming an electron-proton
;                 quasi-neutral plasma.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  1-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;
;  EXAMPLES:    
;               test = cold_plasma_params(magf,dens,freqf,angle)
;
;  KEYWORDS:    
;               FREQF  :  " " wave frequencies (Hz)
;               ANGLE  :  " " wave propagation angles with respect to the magnetic
;                           field (degrees)
;               NDAT   :  Scalar number of values to create for dummy frequencies or
;                           angles
;
;   CHANGED:  1)  Fixed typo in calculation of n_Alfven and allowed frequencies
;                   to extend beyond the electron cyclotron frequency
;                                                              [09/22/2010   v1.1.0]
;             2)  Added the resonance cone angle to output     [09/28/2010   v1.2.0]
;             3)  Fixed typo with resonance cone angle calc.   [09/29/2010   v1.2.1]
;             4)  Changed keyword ANGLE variable to "angles" to prevent program from
;                   possibly changing the value of an input variable
;                                                              [04/22/2011   v1.2.2]
;
;   NOTES:      
;               1)  Set only one of the keywords at a time or at least make sure
;                     they have the same number of elements
;
;   CREATED:  09/20/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/22/2011   v1.2.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  cold_plasma_params,magf,dens,FREQF=freqf,ANGLE=angles,NDAT=ndat

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
wcefac         = qq/me
wcpfac         = qq/mp
wpefac         = SQRT(qq^2/me/epo)
wppfac         = SQRT(qq^2/mp/epo)
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
pdens   = REFORM(dens)*1d6              ; => Convert density to # m^(-3)
bmag    = REFORM(magf)*1d-9             ; => Convert B-field to T
wce     = wcefac[0]*bmag                ; => Electron Cyclotron frequency (radians/s)
wpe     = wpefac[0]*SQRT(pdens)         ; => Electron Plasma frequency (radians/s)
wcp     = wcpfac[0]*bmag                ; => Proton Cyclotron frequency (radians/s)
wpp     = wppfac[0]*SQRT(pdens)         ; => Proton Plasma frequency (radians/s)

IF (~KEYWORD_SET(ndat) OR N_ELEMENTS(ndat) EQ 0) THEN ndat = 100L ELSE ndat = LONG(ndat)

IF (KEYWORD_SET(freqf) OR N_ELEMENTS(freqf) NE 0) THEN BEGIN
  freqw   = REFORM(freqf)*(2d0*!DPI)      ; => Convert wave frequency to radians/s
ENDIF ELSE BEGIN
  ; => Use frequencies from 0 to w_ce or wpe, which ever is higher
  whigher = wce[0] > wpe[0]
  freqw   = DINDGEN(ndat)*(whigher[0] - wcp[0])/(ndat - 1L) + wcp[0]
ENDELSE
; => wce < 0 due to electron charge
wce *= -1d0

IF (KEYWORD_SET(angles) OR N_ELEMENTS(angle) NE 0) THEN BEGIN
  angle   = REFORM(angles)*!DPI/18d1
ENDIF ELSE BEGIN
  ; => Use angles from 0 to pi/2
  angle   = DINDGEN(ndat)*(!DPI/2d0)/(ndat - 1L)
ENDELSE

costhkb = COS(angle)                    ; => Convert angles to cosines
sinthkb = SIN(angle)                    ; => Convert angles to sines
nfterm  = N_ELEMENTS(freqw)
naterm  = N_ELEMENTS(angle)

test_f  = nfterm EQ 1
test_a  = naterm EQ 1
gtest   = WHERE([test_f,test_a],gts)
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
S_term   = DBLARR(nfterm)
D_term   = DBLARR(nfterm)
P_term   = DBLARR(nfterm)
R_term   = DBLARR(nfterm)
L_term   = DBLARR(nfterm)
; => These terms only depend upon the wave frequency, not the propagation direction
;      so we can calculate them regardless of the number of elements in FREQW
S_term   = 1d0 - (wpe[0]^2)/(freqw^2 - wce[0]^2) -          $
                 (wpp[0]^2)/(freqw^2 - wcp[0]^2)
D_term   = (wce[0]*wpe[0]^2)/(freqw*(freqw^2 - wce[0]^2)) + $
           (wcp[0]*wpp[0]^2)/(freqw*(freqw^2 - wcp[0]^2))
P_term   = 1d0 - (wpe[0]^2)/(freqw^2) -                     $
                 (wpp[0]^2)/(freqw^2)

R_term   = 1d0 - (wpe[0]^2)/(freqw*(freqw + wce[0])) -      $
                 (wpp[0]^2)/(freqw*(freqw + wcp[0]))
L_term   = 1d0 - (wpe[0]^2)/(freqw*(freqw - wce[0])) -      $
                 (wpp[0]^2)/(freqw*(freqw - wcp[0]))

n_Alfv   = 1d0 + (wpe[0]^2)/(wce[0]^2) + (wpp[0]^2)/(wcp[0]^2)
; => Note:  A_term, B_term, and F_term must be real => Any NaN or imaginary terms should
;            be removed accordingly
IF (gts EQ 1) THEN BEGIN
  CASE gtest[0] OF
    0 : BEGIN
      ; => Only one frequency
      A_term   = DBLARR(naterm)
      B_term   = DBLARR(naterm)
      F_term   = DBLARR(naterm)
      FOR j=0L, naterm - 1L DO BEGIN
        A_term[j] = S_term[0]*sinthkb[j]^2 + P_term[0]*costhkb[j]^2
        B_term[j] = R_term[0]*L_term[0]*sinthkb[j]^2 + $
                    P_term[0]*S_term[0]*(1d0 + costhkb[j]^2)
        F_term[j] = SQRT((R_term[0]*L_term[0] - P_term[0]*S_term[0])^2*sinthkb[j]^4 + $
                         4d0*P_term[0]^2*D_term[0]^2*costhkb[j]^2)
      ENDFOR
    END
    1    : BEGIN
      ; => Only one angle
      A_term   = DBLARR(nfterm)
      B_term   = DBLARR(nfterm)
      F_term   = DBLARR(nfterm)
      FOR j=0L, nfterm - 1L DO BEGIN
        A_term[j] = S_term[j]*sinthkb[0]^2 + P_term[j]*costhkb[0]^2
        B_term[j] = R_term[j]*L_term[j]*sinthkb[0]^2 + $
                    P_term[j]*S_term[j]*(1d0 + costhkb[0]^2)
        F_term[j] = SQRT((R_term[j]*L_term[j] - P_term[j]*S_term[j])^2*sinthkb[0]^4 + $
                         4d0*P_term[j]^2*D_term[j]^2*costhkb[0]^2)
      ENDFOR
    END
  ENDCASE
ENDIF ELSE BEGIN
  IF (gts EQ 2) THEN BEGIN
    ; => Only one angle and one frequency
    A_term   = S_term[0]*sinthkb[0]^2 + P_term[0]*costhkb[0]^2
    B_term   = R_term[0]*L_term[0]*sinthkb[0]^2 + P_term[0]*S_term[0]*(1d0 + costhkb[0]^2)
    F_term   = SQRT((R_term[0]*L_term[0] - P_term[0]*S_term[0])^2*sinthkb[0]^4 + $
                    4d0*P_term[0]^2*D_term[0]^2*costhkb[0]^2)
  ENDIF ELSE BEGIN
    ; => Multiple angles and Frequencies
    A_term   = DBLARR(nfterm,naterm)
    B_term   = DBLARR(nfterm,naterm)
    F_term   = DBLARR(nfterm,naterm)
    FOR j=0L, nfterm - 1L DO BEGIN
      FOR k=0L, naterm - 1L DO BEGIN
        A_term[j,k] = S_term[j]*sinthkb[k]^2 + P_term[j]*costhkb[k]^2
        B_term[j,k] = R_term[j]*L_term[j]*sinthkb[k]^2 + $
                      P_term[j]*S_term[j]*(1d0 + costhkb[k]^2)
        F_term[j,k] = SQRT((R_term[j]*L_term[j] - P_term[j]*S_term[j])^2*sinthkb[k]^4 + $
                           4d0*P_term[j]^2*D_term[j]^2*costhkb[k]^2)
      ENDFOR
    ENDFOR
  ENDELSE
ENDELSE

nsquared_0 = (B_term + F_term)/(2d0*A_term)
nsquared_1 = (B_term - F_term)/(2d0*A_term)

; => Test to see if the sign of P_term and S_term are not the same
resonance_c = DBLARR(N_ELEMENTS(P_term))       ; => Resonance cone angle (deg)
test_res    = P_term[*]/ABS(P_term[*]) NE S_term[*]/ABS(S_term[*])
good_res    = WHERE(test_res,gdres,COMPLEMENT=bad_res,NCOMPLEMENT=bdres)
IF (gdres GT 0 AND bdres GT 0) THEN BEGIN
  resonance_c[good_res] = ATAN(SQRT(-1d0*P_term[good_res]/S_term[good_res]))*18d1/!DPI
  resonance_c[bad_res]  = ACOS(freqw[bad_res]/ABS(wce[0]))*18d1/!DPI
ENDIF ELSE BEGIN
  IF (gdres GT 0) THEN BEGIN
    ; => All P_term signs are opposite of all S_term signs
    resonance_c = ATAN(SQRT(-1d0*P_term[*]/S_term[*]))*18d1/!DPI
  ENDIF ELSE BEGIN
    ; => All good
    resonance_c = ACOS(freqw[*]/ABS(wce[0]))*18d1/!DPI
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Return data structure
;-----------------------------------------------------------------------------------------
tags  = ['S_TERM','D_TERM','P_TERM','R_TERM','L_TERM','A_TERM','B_TERM','F_TERM',$
         'INDEX_REF_0','INDEX_REF_1','INDEX_ALFVEN','ANGLES','W_FREQS','CONE_ANG']
struc = CREATE_STRUCT(tags,S_term,D_term,P_term,R_term,L_term,A_term,B_term,F_term,$
                      nsquared_0,nsquared_1,n_Alfv,angle*18d1/!DPI,freqw/(2d0*!DPI),$
                      resonance_c)


RETURN,struc
END