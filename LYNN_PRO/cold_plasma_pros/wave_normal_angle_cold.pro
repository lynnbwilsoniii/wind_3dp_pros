;+
;*****************************************************************************************
;
;  FUNCTION :   wave_normal_angle_cold.pro
;  PURPOSE  :   Calculates the wave normal angle from cold plasma theory using the
;                 two perpendicular components of the electric field, solving Eq. 1-31
;                 from Stix, [1962].
;
;  CALLED BY:   
;               
;
;  CALLS:
;               
;
;  REQUIRES:    
;               
;
;  INPUT:
;               EP1    :  M-Element array of perpendicular electric fields (mV/m)
;                           corresponding to Ex in Eq. 1-31 from Stix, [1962]
;               EP2    :  M-Element array of perpendicular electric fields (mV/m)
;                           corresponding to Ey in Eq. 1-31 from Stix, [1962]
;               MAGF   :  N-Element array of magnetic field magnitudes (nT)
;               DENS   :  " " plasma densities [cm^(-3)]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               FREQF  :  K-Element array of wave frequencies (Hz)
;               NDAT   :  Scalar number of values to create for dummy frequencies or
;                           angles if FREQF or ANGLE not set [Default = 100 (= L)]
;               ONED   :  If set, all parameters are assumed to have the same number of
;                           elements and MAGF[j] corresponds to DENS[j] and FREQF[j] and
;                           ANGLE[j] => all returned values with be 1-Dimensional arrays
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If MAGF and DENS have more than one element, then they must have
;                     the same number of elements.  The program assumes that they
;                     correspond to the same place/time measurement and will use them
;                     as such.
;               
;
;  REFERENCES:  
;               1)  Stix, T.H. (1962), "The Theory of Plasma Waves,"
;                      McGraw-Hill Book Company, USA.
;               2)  Gurnett, D. A., and A. Bhattacharjee (2005), "Introduction to
;                      Plasma Physics:  With Space and Laboratory Applications,"
;                      ISBN 0521364833. Cambridge, UK: Cambridge University Press.
;
;   CREATED:  05/10/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/10/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION wave_normal_angle_cold,ep1,ep2,magf,dens,FREQF=freqf,NDAT=ndat,ONED=oned

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

badnbmssg      = 'Incorrect input:  MAGF and DENS must have the same number of elements'
badepmssg      = 'Incorrect input:  EP1 and EP2 must have the same number of elements'
badkeymssg     = 'Incorrect keyword use:  MAGF, DENS, and FREQF must have the same number of elements'
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 4) THEN RETURN,0
eperp1         = REFORM(ep1)
eperp2         = REFORM(ep2)
np1            = N_ELEMENTS(eperp1)
np2            = N_ELEMENTS(eperp2)
IF (np1 NE np2) THEN BEGIN
  MESSAGE,badepmssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
MM             = np1                           ; => # of perp. E-field values
pol            = eperp1/eperp2                 ; => polarization ratio [LHS of Eq. 1-31 from Stix, [1962]]

pdens          = REFORM(dens)                  ; => Number density [cm^(-3)]
bmag           = REFORM(magf)                  ; => B-field [nT]
nd             = N_ELEMENTS(pdens)
nb             = N_ELEMENTS(bmag)
IF (nd NE nb) THEN BEGIN
  MESSAGE,badnbmssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
NN             = nd                            ; => # of density and B-field data points

; LL = # of angle bins 
; KK = # of frequency bins [= LL if FREQF not set]
; NN = # of density AND B-field data points
; MM = # of perp. E-field values
;-----------------------------------------------------------------------------------------
; => Determine the cold plasma dispersion relation
;-----------------------------------------------------------------------------------------
cold           = cold_plasma_params_2d(bmag,pdens,FREQF=freqf,NDAT=ndat,ONED=oned)
; => If FREQF not specified, program uses L [=100] dummy frequencies ranging from
;      0 < f < [fce > fpe]
;    => output = [LL,NN]-Element arrays for D_TERM and S_TERM
;              = [LL,NN,LL]-Element array for n^2
nsquared       = cold.INDEX_REF_1              ; => Eq. 1-26 from Stix, [1962]
szn            = SIZE(nsquared,/DIMENSIONS)
KK             = szn[0]                        ; => # of frequency bins
LL             = szn[2]                        ; => # of angle bins

ndsq           = SIZE(REFORM(nsquared),/N_DIMENSIONS)
d_term         = cold.D_TERM                   ; => Eq. 1-10 from Stix, [1962]
s_term         = cold.S_TERM                   ; => Eq. 1-10 from Stix, [1962]
d_angles       = cold.ANGLES                   ; => Angles (deg) corresponding to n^2
d_freqs        = cold.W_FREQS                  ; => Frequencies (Hz) " "
; => Remove values of n^2 < 0 [due to angles > res. cone angles]
bad        = WHERE(nsquared LE 0,bd)
IF (bd GT 0) THEN BEGIN
  bind           = ARRAY_INDICES(nsquared,bad)
  nsquared[bind] = d
ENDIF
;-----------------------------------------------------------------------------------------
; => Calculate the values of Eq. 1-31 from Stix, [1962]
;-----------------------------------------------------------------------------------------
IF (MM EQ 1) THEN onepo = 1 ELSE onepo = 0
IF (KK EQ 1) THEN onefr = 1 ELSE onefr = 0
IF (NN EQ 1) THEN onebo = 1 ELSE onebo = 0
;IF (LL EQ 1) THEN onean = 1 ELSE onean = 0
nels       = [KK,NN]
dummyc     = [onefr,onebo]
dummy      = [onepo,onefr,onebo]
;  goodc = indices where # of elements = 1
;  badc  = indices where # of elements ≠ 1
goodc      = WHERE(dummyc,gdc,COMPLEMENT=badc,NCOMPLEMENT=bdc)
test       = TOTAL(dummy)         ; => # of dimensions w/ 1-element
testc      = TOTAL(dummyc)        ; => " " [plasma params only]
                                  ;           { 0  :  MM ≠ 1
dtest      = (test - testc) EQ 1  ;  dtest  = {
                                  ;           { 1  :  MM = 1

                            ;---------------------------------------------------------
                            ;           { -1    for goodc = -1
sumgc      = TOTAL(goodc)   ;  sumgc  = {  0    for goodc = [0]
                            ;           {  1    for goodc = [1] OR [0,1]
                            ;---------------------------------------------------------
                            ;---------------------------------------------------------
                            ;           { -1    for badc  = -1
sumbc      = TOTAL(badc)    ;  sumgc  = {  0    for badc  = [0]
                            ;           {  1    for badc  = [1] OR [0,1]
                            ;---------------------------------------------------------

;-----------------------------------------------------------
;           { True   :  (gdc = 2) OR (gdc = 1 AND dtest)
; 1DArray = {
;           { False  :  (gdc = 0) OR (gdc LE 1 AND ~dtest)
;-----------------------------------------------------------
one_d_test = (gdc EQ 2) OR ((gdc EQ 1) AND (dtest))

;-----------------------------------------------------------
;           { True   :  ((gdc EQ 0 AND dtest) OR (gdc EQ 1 AND ~dtest))
; 2DArray = {
;           { False  :  (gdc EQ 0 AND dtest)
;-----------------------------------------------------------
two_d_test = (~one_d_test) AND ((gdc EQ 0) AND (dtest)) OR ((gdc EQ 1) AND (~dtest))

;-----------------------------------------------------------
;           { True   :  (gdc EQ 0 AND ~dtest)
; 3DArray = {
;           { False  :  ELSE
;-----------------------------------------------------------
thr_d_test = (~one_d_test AND ~two_d_test) AND ((gdc EQ 0) AND (~dtest))

good       = WHERE([one_d_test,two_d_test,thr_d_test],gd)
CASE good[0] OF
  ;---------------------------------------------------------------------------------------
  0    : BEGIN
    nsquared = REFORM(nsquared)
    d_term   = REFORM(d_term)
    s_term   = REFORM(s_term)
    ;  NN = 1 & KK = 1
    ; => testc = 3 && test = 3 OR 4
    IF (MM EQ 1) THEN BEGIN
      ; => n^2    = [NN,LL] or [KK,LL] - Element array
      ; => d_term = [NN] or [KK] - Element array
      d1       = nels[badc[0]]
      d2       = -1
      angles   = REPLICATE(d,d1)
      FOR j=0L, d1 - 1L DO BEGIN
        eq0       = d_term[j]*pol[0] + s_term[j] - REFORM(nsquared[j,*])
        mn0       = MIN(ABS(eq0),/NAN,el_mn)
        angles[j] = d_angles[el_mn]
      ENDFOR
    ENDIF ELSE BEGIN
      ; => n^2     = [LL]-Element array
      ; => d_term =  [1]-Element array
      d1       = MM
      d2       = -1
      angles   = REPLICATE(d,d1)
      FOR j=0L, d1 - 1L DO BEGIN
        eq0       = d_term[0]*pol[j] + s_term[0] - nsquared
        mn0       = MIN(ABS(eq0),/NAN,el_mn)
        angles[j] = d_angles[el_mn]
      ENDFOR
    ENDELSE
  END
  ;---------------------------------------------------------------------------------------
  1    : BEGIN
    nsquared = REFORM(nsquared)
    IF (MM EQ 1) THEN BEGIN
      ; => n^2    = [NN,KK,LL]-Element array
      ; => d_term = [NN,KK]-Element array
      d1       = KK
      d2       = NN
      angles   = REPLICATE(d,d1,d2)
      FOR j=0L, d1 - 1L DO BEGIN
        FOR k=0L, d2 - 1L DO BEGIN
          eq0         = d_term[j,k]*pol[0] + s_term[j,k] - REFORM(nsquared[j,k,*])
          mn0         = MIN(ABS(eq0),/NAN,el_mn)
          angles[j,k] = d_angles[el_mn]
        ENDFOR
      ENDFOR
    ENDIF ELSE BEGIN
      ; => n^2    = [NN,LL] or [KK,LL] - Element array
      ; => d_term = [NN] or [KK] - Element array
      d1       = nels[badc[0]]
      d2       = MM
      angles   = REPLICATE(d,d1,d2)
      FOR j=0L, d1 - 1L DO BEGIN
        FOR k=0L, d2 - 1L DO BEGIN
          eq0         = d_term[j]*pol[k] + s_term[j] - REFORM(nsquared[j,*])
          mn0         = MIN(ABS(eq0),/NAN,el_mn)
          angles[j,k] = d_angles[el_mn]
        ENDFOR
      ENDFOR
    ENDELSE
  END
  ;---------------------------------------------------------------------------------------
  2    : BEGIN
    ; => n^2    = [NN,KK,LL]-Element array
    ; => d_term = [NN,KK]-Element array
    angles   = REPLICATE(d,KK,NN,MM)
    d1       = NN
    d2       = KK
    d3       = MM
    
    FOR j=0L, d1 - 1L DO BEGIN      ; => plasma parameter index
      FOR k=0L, d2 - 1L DO BEGIN    ; => frequency bin index
        FOR m=0L, d3 - 1L DO BEGIN  ; => polarization ratio bin index
          eq0           = d_term[j,k]*pol[m] + s_term[j,k] - REFORM(nsquared[j,k,*])
          mn0           = MIN(ABS(eq0),/NAN,el_mn)
          angles[j,k,m] = d_angles[el_mn]
        ENDFOR
      ENDFOR
    ENDFOR
  END
  ;---------------------------------------------------------------------------------------
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return angles to user
;-----------------------------------------------------------------------------------------

RETURN,angles
END