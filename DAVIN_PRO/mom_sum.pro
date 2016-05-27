;+
;*****************************************************************************************
;
;  FUNCTION :   mom_sum.pro
;  PURPOSE  :   This program calculates up to the 4th moment for a 3D particle structure.
;
;  CALLED BY: 
;               mom3d.pro
;
;  CALLS:
;               data_type.pro
;               conv_units.pro
;               str_element.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DATA       :  A 3D moment structure from get_??.pro 
;                               (?? = el, eh, phb, etc.)
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               FORMAT     :  A structure with the desired format (see program)
;               SC_POT     :  A scalar defining the SC Potential (eV)
;               MAXMOMENT  :  A scalar defining the max moment desired for return
;               OLDWAY     :  If set, an "old" method is used to calculate differential
;                               energy
;               PARDENS    :  Set to a named variable to return the particle density
;                               [cm^(-3)]
;               DVOLUME    :  Set to an array with the same dimensions as data.DATA
;                               specifying the sterradians of the sampled data
;               ERANGE     :  Set to a 2-element array defining the first and last energy
;                               bins to use in the moment calculations
;               MASS       :  Set to a scalar defining the particle mass [eV/(km/sec)^2]
;
;   CHANGED:  1)  Davin Larson created                     [??/??/????   v1.0.0]
;             2)  Did some minor "clean up"                [06/16/2008   v1.0.1]
;             3)  Re-wrote and cleaned up                  [04/13/2009   v1.1.0]
;             4)  Updated man page                         [06/17/2009   v1.1.1]
;             6)  Fixed note on charge conversion constant [06/19/2009   v1.1.2]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/19/2009   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION mom_sum,data,FORMAT=sumformat,SC_POT=pot,MAXMOMENT=mm,      $  ;   bins = bins, $
                      OLDWAY=oldway,PARDENS=pardens,DVOLUME=dvolume, $
                      ERANGE=er,MASS=mass
;-----------------------------------------------------------------------------------------
; => Define dummy variables and structures
;-----------------------------------------------------------------------------------------
f = !VALUES.F_NAN
IF KEYWORD_SET(mm) THEN mxm = mm ELSE mxm = 4
;mxm = KEYWORD_SET(mm) ? mm : 4
IF (data_type(sumformat) EQ 8) THEN BEGIN
  sum = sumformat
ENDIF ELSE BEGIN
   sum = {N:f,NV:REPLICATE(f,3),NVV:REPLICATE(f,6),NVVV:REPLICATE(f,10), $
         NVVVV:REPLICATE(f,15),MAP_R2:BYTARR(3,3),MAP_V2:BYTARR(6),      $
         MAP_R3:BYTARR(3,3,3),MAP_V3:BYTARR(10),MAP_R4:BYTARR(3,3,3,3),  $
         MAP_V4:BYTARR(15),SC_POT:f,MASS:f,CHARGE:0,MAGF:REPLICATE(f,3), $
         ERANGE:[f,f],MAXMOMENT:mxm}
ENDELSE

sum.MAP_R2 = [[0,3,4],[3,1,5],[4,5,2]]
sum.MAP_V2 = [0,4,8,1,2,5]

sum.MAP_R3 = [[[3,5,2],[5,6,9],[2,9,7]],[[5,6,9],[6,4,1],[9,1,8]],[[2,9,7],[9,1,8],[7,8,0]]]
sum.MAP_V3 = [26,14,2,0,13,1,4,8,17,5]

sum.MAP_R4 =[ 2,14,10,14, 3,11,10,11, 5, $
             14, 3,11, 3,13,12,11,12, 8, $
             10,11, 5,11,12, 8, 5, 8, 7, $
             14, 3,11, 3,13,12,11,12, 8, $
              3,13,12,13, 1, 9,12, 9, 4, $
             11,12, 8,12, 9, 4, 8, 4, 6, $
             10,11, 5,11,12, 8, 5, 8, 7, $
             11,12, 8,12, 9, 4, 8, 4, 6, $
              5, 8, 7, 8, 4, 6, 7, 6, 0]

sum.MAP_V4 = [80,40,0,4,44,8,53,26,17,41,2,5,14,13,1]
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() EQ 0) THEN RETURN,sum
IF (data.VALID EQ 0) THEN RETURN,sum

data3d   = conv_units(data,"eflux")       ; Use Energy Flux
sum.MAGF = data3d.MAGF
e        = data3d.ENERGY
nn       = data3d.NENERGY
IF KEYWORD_SET(er) THEN BEGIN
   err                = 0 >  er < (nn-1)
   s                  = e
   s[*]               = 0.
   s[err[0]:err[1],*] = 1.
   data3d.DATA       *= s
ENDIF ELSE err = [0,nn-1]

sum.ERANGE = data3d.ENERGY[err,0]
IF (N_ELEMENTS(pot) EQ 0) THEN str_element,data3d,'SC_POT',pot
IF (N_ELEMENTS(pot) EQ 0) THEN pot = 0.
IF (NOT FINITE(pot)) THEN pot = 0.

sum.SC_POT = pot
sum.MASS   = data3d.MASS     ; => Particle mass [eV/(km/sec)^2]
;-----------------------------------------------------------------------------------------
; -Note:  
;  0.010438871 eV/(km/sec)^2 = ([938.27231 x 10^(6) eV/c^2])/([2.9979 x 10^(5) km/s])^2
;
; => Units of proton masses in eV/(km/sec)^2
;-----------------------------------------------------------------------------------------
IF (NOT KEYWORD_SET(charge)) THEN charge = ROUND(SQRT(sum.MASS/0.010438871))
IF (charge EQ 0) THEN charge = -1

sum.CHARGE = charge
IF NOT KEYWORD_SET(dvolume) THEN $
   dvolume = REPLICATE(1.,nn) # data3d.DOMEGA  ; cluge

IF KEYWORD_SET(oldway) THEN BEGIN
 de_e         = ABS(SHIFT(e,1) - SHIFT(e,-1))/2./e
 de_e[0,*]    = de_e[1,*]
 de_e[nn-1,*] = de_e[nn-2,*]
 de           = de_e * e
ENDIF ELSE BEGIN
 de   = data3d.DENERGY
 de_e = de/e
ENDELSE
; -Force 0. < weight < 1.
weight = 0. > ((e + pot/charge)/de + .5) < 1.   ; => [Unitless]

; -Force e_inf > 0.
e_inf = (e + pot/charge) > 0.     ; => [eV]
;-----------------------------------------------------------------------------------------
; => Calculate the differential distribution function
;-----------------------------------------------------------------------------------------
wv      = SQRT(e_inf)             ; => [eV^(1/2)]
data_dv = wv/e * data3d.DATA/1e5 * de_e * dvolume * weight  ; => [eV^(-1/2) cm^(-3) km/s]
;-----------------------------------------------------------------------------------------
; => {Note:  1/1e5 = multiplying by 10^5 cm/km to get the extra cm and the km/s in units}
;-----------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------
; at this point the following are required:
;  wv,theta,phi,data_dv
;  mass and charge are NOT needed.
;IF KEYWORD_SET(bins) THEN BEGIN
;  ndb = ndimen(bins)
;  wb = WHERE(bins eq 0,c)
;  IF c NE 0 THEN BEGIN
;    IF ndb EQ 1 THEN data_dv[*,wb] = 0 ELSE data_dv[wb] = 0
;  ENDIF
;ENDIF
;-----------------------------------------------------------------------------------------
wb = WHERE(data3d.BINS EQ 0,c)
IF (c NE 0) THEN data_dv[wb] = 0
IF (c NE 0) THEN wv[wb] = 0
;-----------------------------------------------------------------------------------------
; =>Calculate Density [cm^(-3)]
;-----------------------------------------------------------------------------------------
pardens = TOTAL(data_dv,2,/NAN)
sum.N   = TOTAL(pardens,/NAN)                         ; => [eV^(-1/2) cm^(-3) km/s]
nnorm   = SQRT(ABS(2*sum.CHARGE/sum.MASS))            ; => [(km/s) eV^(-1/2)]
pardens = pardens/nnorm                               ; => [cm^(-3)]

IF (mxm LE 0) THEN RETURN,sum
;-----------------------------------------------------------------------------------------
; -FLUX calculation [km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
sin_phi = SIN(data3d.PHI/!RADEG)
cos_phi = COS(data3d.PHI/!RADEG)
sin_th  = SIN(data3d.THETA/!RADEG)
cos_th  = COS(data3d.THETA/!RADEG)

x       = cos_th * cos_phi
y       = cos_th * sin_phi
z       = sin_th
dsum    = data_dv * wv             ; => [cm^(-3) km/s]

fx      = TOTAL(x * dsum,/NAN)
fy      = TOTAL(y * dsum,/NAN)
fz      = TOTAL(z * dsum,/NAN)

IF ARG_PRESENT(parvel) THEN $
   parvel = SQRT(TOTAL(fx,2,/NAN)^2 + TOTAL(fy,2,/NAN)^2 + TOTAL(fz,2,/NAN)^2)

sum.NV    = [fx,fy,fz]   ; => Flux [km/s cm^(-3)]
IF (mxm LE 1) THEN RETURN,sum
;-----------------------------------------------------------------------------------------
; -Velocity flux calculation [eV^(1/2) km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
dsum   *= wv                       ; => [eV^(1/2) km/s cm^(-3)]
vfxx    = TOTAL(x*x  * dsum,/NAN) 
vfyy    = TOTAL(y*y  * dsum,/NAN)
vfzz    = TOTAL(z*z  * dsum,/NAN)
vfxy    = TOTAL(x*y  * dsum,/NAN)
vfxz    = TOTAL(x*z  * dsum,/NAN)
vfyz    = TOTAL(y*z  * dsum,/NAN)

sum.NVV = [vfxx,vfyy,vfzz,vfxy,vfxz,vfyz]    ; => Velocity Flux [eV^(1/2) km/s cm^(-3)]
IF (mxm LE 2) THEN RETURN,sum
;-----------------------------------------------------------------------------------------
; =>Heat flux calculation [eV km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
dsum    *= wv                          ; => [eV km/s cm^(-3)]

qfxxx    = TOTAL(x*x*x * dsum,/NAN)
qfxyy    = TOTAL(x*y*y * dsum,/NAN)
qfxzz    = TOTAL(x*z*z * dsum,/NAN)
qfxxy    = TOTAL(x*x*y * dsum,/NAN)
qfxxz    = TOTAL(x*x*z * dsum,/NAN)
qfxyz    = TOTAL(x*y*z * dsum,/NAN)

qfyyz    = TOTAL(y*y*z * dsum,/NAN)
qfyzz    = TOTAL(y*z*z * dsum,/NAN)
qfyyy    = TOTAL(y*y*y * dsum,/NAN)
qfzzz    = TOTAL(z*z*z * dsum,/NAN)
;---------------------------------------------------------------------
; nvvv = ['zzz','yyz','xxz','xxx','yyy','xxy','xyy','xzz','yzz','xyz']
;---------------------------------------------------------------------
sum.NVVV = [qfzzz,qfyyz,qfxxz,qfxxx,qfyyy,qfxxy,qfxyy,qfxzz,qfyzz,qfxyz]
IF (mxm LE 3) THEN RETURN,sum   ; => Heat Flux [eV km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
; => R-Tensor Calculation  [eV^(3/2) km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
dsum     *= wv                          ; => [eV^(3/2) km/s cm^(-3)]

rzzzz     = TOTAL(z*z*z*z * dsum,/NAN)
ryyzz     = TOTAL(y*y*z*z * dsum,/NAN)
rxxzz     = TOTAL(x*x*z*z * dsum,/NAN)
ryyyy     = TOTAL(y*y*y*y * dsum,/NAN)
rxxxx     = TOTAL(x*x*x*x * dsum,/NAN)
rxxyy     = TOTAL(x*x*y*y * dsum,/NAN)

ryzzz     = TOTAL(y*z*z*z * dsum,/NAN)
rxzzz     = TOTAL(x*z*z*z * dsum,/NAN)
rxyzz     = TOTAL(x*y*z*z * dsum,/NAN)
ryyyz     = TOTAL(y*y*y*z * dsum,/NAN)
rxxxz     = TOTAL(x*x*x*z * dsum,/NAN)
rxxyz     = TOTAL(x*x*y*z * dsum,/NAN)
rxyyz     = TOTAL(x*y*y*z * dsum,/NAN)
rxyyy     = TOTAL(x*y*y*y * dsum,/NAN)
rxxxy     = TOTAL(x*x*x*y * dsum,/NAN)

sum.NVVVV = [rzzzz,ryyyy,rxxxx,rxxyy,ryyzz,rxxzz,  $
             ryzzz,rxzzz,rxyzz,ryyyz,rxxxz,rxxyz,  $
             rxyyz,rxyyy,rxxxy]

RETURN,sum   ; =>Dimensions:  [(eV)^((i-1)/2) cm^-3 km/s]
END