;+
;*****************************************************************************************
;
;  FUNCTION :   cal_bs_param.pro
;  PURPOSE  :   Procedure returns parameters that describe intersection w/ Bow Shock.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               POS      :  [N,3]-Element array of GSE spacecraft positions [Re]
;               MAGF     :  [N,3]-Element array of magnetic field values
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               BOW      :  Structure with the format {L, ecc, X0}, where:
;                             L   = standoff parameter [Re]
;                               [Default:  L = b^2/a = 23.5]
;                             ecc = eccentricity of shock
;                               [Default:  ecc = c/a = 1.15]
;                             X0  = focus location [Re]
;                               [Default:  X0 = 3]
;               VPAR     :  **Obsolete**
;               VSW      :  [N,3]-Element array of solar wind velocities [km/s]
;               BSN      :  Set to a named variable to return the angle between the
;                             shock normal and field line that passes through the SC
;               LSN      :  " " the distance along the field line to the shock [Re]
;               NSN      :  " " the distance from the shock nose to the field line
;                             crossing [Re]
;               SHPOS    :  " " the position at the shock B-field intersection
;               SHNORM   :  " " the shock normal vector at the shock B-field intersection
;               CONNECT  :  " " a logic parameter that defines whether the SC is
;                             magnetically connected to the shock
;                             [0 = unconnected, 1 = connected]
;               STRUCT   :  " " all output keyword parameters in a structure
;
;   CHANGED:  1)  Davin Larson changed major mods and added shock normal vector
;                                                                   [10/01/1995   v1.0.?]
;             2)  McFadden added BOW keword                         [10/05/1995   v1.0.?]
;             3)  Cleaned up and vectorized for 2D input vectors    [11/21/2011   v1.1.0]
;             4)  Fixed typo in error handling                      [12/16/2011   v1.1.1]
;             5)  Fixed that occurs when only one B-field vector is input
;                                                                   [01/05/2012   v1.1.2]
;             6)  Included aberration corrections                   [01/12/2012   v1.1.3]
;
;   NOTES:      
;               1)  SC = spacecraft
;               2)  hyperbolic bow shock, see JGR 1981, p.11401, Slavin Fig.7
;                     r = L/[1 + ecc*Cos(theta)]
;                     1 = [(x - X0 - c)/a]^2 + [(y/b)]^2 + [(z/b)]^2
;               3)  Default hyperbola parameters used:
;                     c = [a^2 + b^2]^(1/2) = L*e/(e^2 - 1) = 83.8
;                     a = L/(e^2 - 1)                       = 72.87
;                     b = L/(e^2 - 1)^.5                    = 41.38
;               4)  See also:  get_bsn.pro or add_bsn.pro
;
;   CREATED:  09/20/1995
;   CREATED BY:  Jim McFadden
;    LAST MODIFIED:  01/12/2012   v1.1.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO cal_bs_param,pos,magf,BOW=bow,VPAR=vpar,VSW=vsw,BSN=bsn,LSN=lsn,NSN=nsn, $
                 SHPOS=shpos,SHNORM=shnorm,CONNECT=connect,STRUCT=struct

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
missing    = !VALUES.F_NAN
; => Define the mean orbital speed of Earth
vel_earth  = 29.78
; => Define an average aberration angle [rad] for a 450 km/s solar wind speed
avg_alpha  = ATAN(vel_earth[0],450d0)  ; roughly 3.8 degrees
IF (SIZE(bow,/TYPE) NE 8) THEN bow = {STANDOFF:23.3,ECCENTRICITY:1.16,X_OFFSET:3.0}
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
po         = REFORM(pos)
bo         = REFORM(magf)

szp        = SIZE(po,/DIMENSIONS)
szb        = SIZE(bo,/DIMENSIONS)
test1D     = (N_ELEMENTS(szp) LE 1) AND (N_ELEMENTS(szb) LE 1)
test2D     = (N_ELEMENTS(szp) EQ 2) AND (N_ELEMENTS(szb) EQ 2)
IF (test1D) THEN BEGIN
  ; => 1D Input
  sc_pos  = REFORM(po,1L,3L)
  sc_magf = REFORM(bo,1L,3L)
  oned    = 1
ENDIF ELSE BEGIN
  IF ~(test2D) THEN RETURN      ; => bad input
  ; => 2D Input
  sc_pos  = po
  sc_magf = bo
  oned    = 0
ENDELSE
;npts       = N_ELEMENTS(po[*,0])  ; => # of vectors
;  LBW III  01/05/2012
npts       = N_ELEMENTS(sc_pos[*,0])  ; => # of vectors
;-----------------------------------------------------------------------------------------
; => Define dummy arrays
;-----------------------------------------------------------------------------------------
shpos      = REPLICATE(missing,npts,3L)
shnorm     = REPLICATE(missing,npts,3L)
bsn        = REPLICATE(missing,npts)
lsh        = REPLICATE(missing,npts)
nsn        = REPLICATE(missing,npts)
connect    = REPLICATE(missing,npts)

sh1        = REPLICATE(missing,npts,3L)
sh2        = REPLICATE(missing,npts,3L)
;-----------------------------------------------------------------------------------------
; => Define parameters
;-----------------------------------------------------------------------------------------
L          = bow.STANDOFF[0]
ecc        = bow.ECCENTRICITY[0]
x0         = bow.X_OFFSET[0]

;if not keyword_set(vel) then vel=3.e5
IF NOT KEYWORD_SET(vsw) THEN vsw = REPLICATE(0.,npts,3L) ELSE vsw = REFORM(vsw)
IF ((N_ELEMENTS(vsw) EQ 3) OR (N_ELEMENTS(vsw) NE N_ELEMENTS(sc_pos))) THEN BEGIN
  ; => fix # of elements in VSW
  IF (N_ELEMENTS(vsw) EQ 3) THEN BEGIN
    IF (oned) THEN vsw = REFORM(vsw,1L,3L) ELSE vsw = REPLICATE(0.,npts,3L)
  ENDIF ELSE BEGIN
    vsw = REPLICATE(0.,npts,3L)
  ENDELSE
ENDIF
vmag       = SQRT(TOTAL(vsw^2,2L,/NAN))
alpha0     = ATAN(vel_earth[0],vmag)
test0      = (ABS(alpha0) GE 80d0) OR (FINITE(alpha0) EQ 0)
bad_alpha  = WHERE(test0,bda,COMPLEMENT=good_alpha,NCOMPLEMENT=gda)
IF (gda EQ 0) THEN BEGIN
  ; => no good Vsw inputs
  alpha = avg_alpha[0]
ENDIF ELSE BEGIN
  alpha = MEAN(alpha0[good_alpha],/NAN)
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define rotation matrix from original basis to aberrated basis
;-----------------------------------------------------------------------------------------
abrot      = [[1d0*COS(alpha[0]), -1d0*SIN(alpha[0]), 0d0], $
              [1d0*SIN(alpha[0]),  1d0*COS(alpha[0]), 0d0], $
              [        0d0      ,        0d0       ,  1d0]  ]
; => rotate original SC position vectors into aberrated basis
sc_pos_ab0 = (abrot ## sc_pos)

; => Normalize B-field and SC position
;bfld       = sc_magf/(SQRT(TOTAL(magf^2,2L,/NAN)) # REPLICATE(1e0,3L))
;  LBW III  01/05/2012
bfld       = sc_magf/(SQRT(TOTAL(sc_magf^2,2L,/NAN)) # REPLICATE(1e0,3L))
sc_pos_u   = sc_pos/(SQRT(TOTAL(sc_pos^2,2L,/NAN)) # REPLICATE(1e0,3L))
; => Calculate the Sun-Earth-Spacecraft Angle [deg]
sps_ang    = ACOS(sc_pos_u[*,0])*18d1/!DPI
; => Calculate the Angle Between and Radial Direction and Conic-Crossing-Normal [deg]
con_ang    = ATAN(ecc[0]*SIN(sps_ang*!DPI/18d1),(1d0 + ecc[0]*COS(sps_ang*!DPI/18d1)))
con_ang   *= 18d1/!DPI
;-----------------------------------------------------------------------------------------
; => Define bow shock parameters
;-----------------------------------------------------------------------------------------
x0         = 1d0*x0
y0         = 0d0
z0         = 0d0
a          = L[0]/(ecc[0]^2 - 1d0)
b          = L[0]/SQRT(ecc[0]^2 - 1d0)
c          = L[0]*ecc[0]/(ecc[0]^2 - 1d0)
; => vertex of hyperbola at:  [xo +/- a, yo]
nsh        = [c[0] + x0[0] + a[0],0d0,0d0]  ; => nose of shock in aberrated coordinates
; => translate aberrated SC position vectors to aberrated basis origin
sc_pos_ab       = sc_pos_ab0
sc_pos_ab[*,0] -= (x0[0] + c[0])
;-----------------------------------------------------------------------------------------
; => Define relative spacecraft position
;-----------------------------------------------------------------------------------------
x1         =  sc_pos[*,0] - x0[0] - c[0]
; => foci of hyperbola at:  [xo +/- c, yo]
y1         =  sc_pos[*,1] - y0[0]
z1         =  sc_pos[*,2] - z0[0]
; => hyperbola params
a1         = (b[0]*bfld[*,0])^2 - a[0]^2*(bfld[*,1]^2 + bfld[*,2]^2)
b1         = 2d0*b[0]^2*bfld[*,0]*x1 - 2d0*a[0]^2*(bfld[*,1]*y1 + bfld[*,2]*z1)
c1         = b[0]^2*x1^2 - a[0]^2*(y1^2 + z1^2 + b[0]^2)
b24ac      = b1^2 - 4*a1*c1
good       = WHERE(b24ac GE 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
;IF (bd GE 0) THEN b24ac[bad] = !VALUES.D_NAN
;  LBW III  12/16/2011
IF (bd GT 0) THEN b24ac[bad] = !VALUES.D_NAN

;IF (gd GE 0) THEN BEGIN
;  LBW III  12/16/2011
IF (gd GT 0) THEN BEGIN
  ;---------------------------------------------------------------------------------------
  ; => Define length (along Bo) to shock position at intersection with Bo
  ;---------------------------------------------------------------------------------------
  l1      = (-1d0*b1 + SQRT(b24ac))/(2d0*a1)
  l2      = (-1d0*b1 - SQRT(b24ac))/(2d0*a1)
  ;---------------------------------------------------------------------------------------
  ; => Define shock position at intersection with Bo
  ;---------------------------------------------------------------------------------------
  FOR j=0L, 2L DO BEGIN
    sh1[*,j] = sc_pos[*,j] + bfld[*,j]*l1
    sh2[*,j] = sc_pos[*,j] + bfld[*,j]*l2
  ENDFOR
  FOR k=0L, npts - 1L DO BEGIN
    testx1     = (sh1[k,0] GT nsh[0])
    testx2     = (sh1[k,0] GT nsh[0]) AND (sh2[k,0] GT nsh[0])
    testx3     = (sh2[k,0] LT nsh[0]) AND (ABS(l1[k]) GT ABS(l2[k]))
    ; => initially set connection = 1
    connect[k] = 1
    IF (testx2) THEN BEGIN
      ; => B-Field does not cross shock
      ;   => cannot define shock position or length along Bo to shock
      connect[k] = 0
    ENDIF ELSE IF (testx1) THEN BEGIN
      ; => +solution > standoff estimate
      shpos[k,*]   = sh2[k,*]
      lsh[k]       = l2[k]
    ENDIF ELSE IF (testx3) THEN BEGIN
      ; => (-solution < standoff estimate) AND (|l+| > |l-|)
      shpos[k,*]   = sh2[k,*]
      lsh[k]       = l2[k]
    ENDIF ELSE BEGIN
      shpos[k,*]   = sh1[k,*]
      lsh[k]       = l1[k]
    ENDELSE
  ENDFOR
  ;---------------------------------------------------------------------------------------
  ; => Check calcs
  ;---------------------------------------------------------------------------------------
  temp    = 1d0 - (shpos[*,0] - x0[0] - c[0])^2/a[0]^2 + (shpos[*,1]^2 + shpos[*,2]^2)/b[0]^2
  test    = ABS(temp) GT 0.0001
  bad     = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
  IF (bd GT 0) THEN BEGIN
    PRINT,'   Shock calculation error!!!'
    shpos[bad,*] = !VALUES.D_NAN
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; => Use gradient of the surface equation for a hyperboloid to define shock normal
  ;             (x - xo)^2     (y - yo)^2     (z - zo)^2
  ;  S(x,y,z) = ----------  -  ----------  +  ----------  -  1  =  0
  ;                a^2            b^2            b^2
  ;
  ;   {where:  a = semi-major axis, b = semi-minor axis, and
  ;              [x,y,z]o = location of center }
  ;---------------------------------------------------------------------------------------
  shnorm[*,0] =  2d0/a[0]^2*shpos[*,0]
  shnorm[*,1] = -2d0/b[0]^2*shpos[*,1]
  shnorm[*,2] =  2d0/b[0]^2*shpos[*,2]
  ; => Normalize
  shnorm  = shnorm/(SQRT(TOTAL(shnorm^2,2L,/NAN)) # REPLICATE(1e0,3L))
  ; => Calc. angle between B-field and shock normal
  b_dot_n = shnorm[*,0]*bfld[*,0] + shnorm[*,1]*bfld[*,1] + shnorm[*,2]*bfld[*,2]
  bsn     = ACOS(b_dot_n)*18d1/!DPI
ENDIF
;-----------------------------------------------------------------------------------------
; => Define return structure
;-----------------------------------------------------------------------------------------
str_element,struct,'CONNECT',connect,/ADD_REPLACE
str_element,struct,'SHPOS',shpos,/ADD_REPLACE
str_element,struct,'SHNORM',shnorm,/ADD_REPLACE
str_element,struct,'BSN',bsn,/ADD_REPLACE
str_element,struct,'LSN',lsh,/ADD_REPLACE

RETURN
END
