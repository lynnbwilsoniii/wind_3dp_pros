;+
;*****************************************************************************************
;
;  PROCEDURE:   lbw_calc_bs_param.pro
;  PURPOSE  :   Returns parameters that describe the intersection with a model
;                 bow shock (i.e., hyperboloid of two sheets) described in
;                 Slavin & Holzer [1981].
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;               mag__vec.pro
;               unit_vec.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               POS      :  [N,3]-Element [numeric] array of spacecraft positions
;                             [Re, GSE] in non-aberrated coordinates
;               MAGF     :  [N,3]-Element [numeric] array of magnetic field 3-vectors
;                             [nT, GSE] in non-aberrated coordinates
;
;  EXAMPLES:    
;               [calling sequence]
;               lbw_calc_bs_param,pos,magf [,BOW=bow] [,VSW=vsw] [,BSN=bsn] [,LSN=lsn]  $
;                                 [,SHPOS=shpos] [,SHNORM=shnorm] [,CONNECT=connect]    $
;                                 [,STRUCT=struct] [,SCPOSAB=ab_pos] [,SCATSAB=scatsab] $
;                                 [,SCATSH=scatsh] [,SHN_SC=shn_sc]
;
;               ;;  Example
;               posi           = [4.1d0,23.2d0,5.6d0]                                   ;;  Upstream position of SC [Re, GSE]
;               scatsh         = [0.16643598d0,0.95855703d0,0.23123037d0]*24.163496d0   ;;  SC position at time of last bow shock crossing [Re, GSE]
;               bow            = {STANDOFF:23.2428,ECCENTRICITY:1.16,X_OFFSET:3e0}      ;;  Model parameters used
;               magf           = [-1.043d0,-2.968d0,-0.376d0]                           ;;  Upstream average magnetic field [nT, GSE]
;               vsw            = [-463.730d0,30.288d0,3.504d0]                          ;;  Upstream average bulk flow velocity [km/s, GSE]
;               .compile lbw_calc_bs_param.pro
;               lbw_calc_bs_param,posi,magf,BOW=bow,VSW=vsw,BSN=bsn,LSN=lsh,SHPOS=shpos,$
;                                 SHNORM=shnorm,CONNECT=connect,STRUCT=struct,          $
;                                 SCPOSAB=ab_pos,SCATSH=scatsh,SCATSAB=scatsab,SHN_SC=shn_sc
;               PRINT,';;  ',bsn[0],lsh[0],connect[0]     & $
;               PRINT,';;  ',REFORM(shpos)                & $
;               PRINT,';;  ',REFORM(shnorm)               & $
;               PRINT,';;  ',REFORM(shn_sc)               & $
;               PRINT,';;  ',REFORM(scatsab)
;               ;;         33.588875      0.30102986       1.0000000
;               ;;         4.0009020       22.918003       5.5642753
;               ;;        0.79131760      0.59163276      0.15423078
;               ;;        0.78821356      0.59577315      0.15418736
;               ;;         2.5319833       23.371891       5.5873341
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               BOW      :  Structure with the format
;                             {STANDOFF:L,ECCENTRICITY:ecc,X_OFFSET:X0}
;                             where:
;                             L   = standoff parameter or semi-latus rectum [Re]
;                               [Default:  L = b^2/a = 23.3]
;                             ecc = eccentricity of shock [unitless]
;                               [Default:  ecc = c/a = 1.16]
;                             X0  = focus location [Re]
;                               [Default:  X0 = 3]
;               VSW      :  [N,3]-Element [numeric] array of solar wind velocities [km/s]
;               SCATSH   :  [K,3]-Element [numeric] array of spacecraft positions
;                             [Re, GSE] in non-aberrated coordinates corresponding to the
;                             last crossing of the bow shock
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               BOW      :  Set to a named variable to return the structure used to
;                             create the model bow shock in aberrated coordinates
;               BSN      :  Set to a named variable to return the angle [deg] between the
;                             shock normal and field line that passes through the SC
;               LSN      :  " " the distance along the field line to the shock [Re]
;               SHPOS    :  " " the position at the shock B-field intersection
;               SHNORM   :  " " the shock normal vector at the shock B-field intersection
;               CONNECT  :  " " a logic parameter that defines whether the SC is
;                             magnetically connected to the shock
;                             [0 = unconnected, 1 = connected]
;               STRUCT   :  " " all output keyword parameters in a structure
;               SCPOSAB  :  " " [N,3]-element array of aberrated SC positions [Re, Abr.]
;               SCATSAB  :  " " [K,3]-element array of aberrated SC positions [Re, Abr.]
;                             near location of SC crossing of bow shock
;               SHN_SC   :  " " [K,3]-element array of shock normal vectors near location
;                             of SC crossing of bow shock
;
;   CHANGED:  1)  Added keywords:  SCATSH and SCATSAB and
;                   changed output calculated values a bit
;                                                                   [09/09/2020   v1.0.1]
;             2)  Fixed typo in definition of Earth radius and
;                   fixed array concatenation issue with fixing rotations
;                                                                   [09/18/2020   v1.0.2]
;
;   NOTES:      
;               1)  Definitions
;                     SC    = spacecraft
;                     r     = L/[1 + ecc*Cos(theta)]
;                     L     = semi-latus rectum
;                           = b^2/a
;                     e     = eccentricity
;                           = c/a
;                             { a^2 + b^2    for hyperbola
;                     c^2   = {
;                             { a^2 - b^2    for ellipse
;                     Rss   = xo + L/(1 + e) = bow shock standoff distance along x'
;               2)  hyperbolic bow shock, see JGR 1981, p.11401, Slavin Fig.7
;                     1 = [(x - X0 - c)/a]^2 + [(y/b)]^2 + [(z/b)]^2
;                     Note it should be the folowing for a hyperboloid of two-sheets
;                     0 = 1 - [(x - X0 - c)/a]^2 + [(y/b)]^2 + [(z/b)]^2
;               3)  Default hyperbola parameters used:
;                     L   = 23.3 R_E
;                     e   = 1.16
;                     xo  = 3.0 R_E
;                     c   = [a^2 + b^2]^(1/2) = L*e/(e^2 - 1) = 83.8
;                     a   = L/(e^2 - 1)                       = 72.87
;                     b   = L/(e^2 - 1)^.5                    = 41.38
;                     Rss = 13.8 R_E
;               4)  See also:  get_bsn.pro or add_bsn.pro or cal_bs_param.pro
;               5)  Let the following be true:
;                     r     = [x^2 + y^2]^(1/2)
;                             { ArcTan(Vp/Vsw) + ArcCos(x/r)    for y > 0
;                     alpha = {
;                             { ArcTan(Vp/Vsw) - ArcCos(x/r)    for y < 0
;                     x'    = r Cos(alpha)
;                     y'    = r Sin(alpha)
;                     z'    = z
;                     
;                     0     = k1 y^2 + k2 x y + k3 x^2 + k4 y + k5 x + k6
;                           = k1' y'^2 + k3' x'^2 + k4' y' + k5' x' + k6'
;                     k1'   = k3 Sin^2(alpha) - k2 Sin(alpha) Cos(alpha) + k1 Cos^2(alpha)
;                     k2'   = k2 (1 - 2 Sin^2(alpha)) + 2(k1 - k3) Sin(alpha) Cos(alpha) = 0
;                     k3'   = k3 Cos^2(alpha) - k2 Sin(alpha) Cos(alpha) + k1 Sin^2(alpha)
;                     k4'   = -k5 Sin(alpha) + k4 Cos(alpha)
;                     k5'   = k5 Cos(alpha) + k4 Sin(alpha)
;                     k6'   = k6
;                     
;                     1     = [x' - xo]^2/a^2 + [y' - yo]^2/b^2
;                     xo    = -(k5'/2k3') ± c   {+ ellipse, - hyperbola}
;                     yo    = -(k4'/2k1')
;                     a     = [(k4'^2/4k1'k3') + (k5'^2/4k3'^2) - (k6'/k3')]^(1/2)
;                     b     = [(k4'^2/4k1'^2) + (k5'^2/4k1'k3') - (k6'/k1')]^(1/2)
;
;  REFERENCES:  
;               1)  https://en.wikipedia.org/wiki/Hyperboloid
;               2)  http://mathworld.wolfram.com/Two-SheetedHyperboloid.html
;               3)  Slavin, J.A. and R.E. Holzer "Solar wind flow about the terrestrial
;                      planets. I - Modeling bow shock position and shape,"
;                      J. Geophys. Res. 86(A13), pp. 11,401-11,418,
;                      doi:10.1029/JA086iA13p11401, 1981.
;
;   ADAPTED FROM: cal_bs_param.pro    BY: Jim McFadden
;   CREATED:  09/07/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/18/2020   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO lbw_calc_bs_param,pos,magf,BOW=bow,VSW=vsw,BSN=bsn,LSN=lsh,SHPOS=shpos, $
                               SHNORM=shnorm,CONNECT=connect,STRUCT=struct, $
                               SCPOSAB=ab_pos,SCATSH=scatsh,SCATSAB=scatsab,$
                               SHN_SC=shn_sc

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
missing        = d[0]
;;  Define the mean orbital speed of Earth [km/s]
vel_earth      = 29.7854d0
;;  Define mean equatorial radius [m]
R_E_m          = 6.3781366d6
R_E            = R_E_m[0]*1d-3         ;;  m --> km
;;  Define an average aberration angle [rad] for a 450 km/s solar wind speed
def_vsw        = 450d0                     ;;  Default Vsw magnitude [km/s]
avg_alpha      = ATAN(vel_earth[0],450d0)  ;;  roughly 3.8 degrees
;;  Error messages
noinput_mssg   = 'No input was supplied...'
badinfm_mssg   = 'POS and MAGF must be [N,3]-element [numeric] arrays of 3-vectors...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
test           = (is_a_3_vector(pos ,V_OUT=sc_pos ,/NOMSSG) EQ 0) OR $
                 (is_a_3_vector(magf,V_OUT=sc_magf,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badinfm_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
npts           = N_ELEMENTS(sc_pos[*,0])    ;;  # of vectors
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check BOW
IF (SIZE(bow,/TYPE) NE 8) THEN BEGIN
  bow  = {STANDOFF:23.3,ECCENTRICITY:1.16,X_OFFSET:3.0}
ENDIF ELSE BEGIN
  gtag = ['STANDOFF','ECCENTRICITY','X_OFFSET']
  itag = STRUPCASE(TAG_NAMES(bow))
  test = (TOTAL(gtag EQ itag) LT 3)
  IF (test[0]) THEN bow  = {STANDOFF:23.3,ECCENTRICITY:1.16,X_OFFSET:3.0}
ENDELSE
;;  Check VSW
test           = (is_a_3_vector(vsw ,V_OUT=vswo ,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  vswo = REPLICATE(def_vsw[0],npts[0],3L)
ENDIF
;;  Check SCATSH
test           = (is_a_3_vector(scatsh,V_OUT=scbscr,/NOMSSG) EQ 0)
IF (test[0]) THEN shn_at_sc = 0b ELSE shn_at_sc = 1b
;;----------------------------------------------------------------------------------------
;;  Calculate aberration angle
;;----------------------------------------------------------------------------------------
vmag           = mag__vec(vswo,/NAN)
alpha0         = ATAN(vel_earth[0],vmag)*18d1/!DPI
test0          = (ABS(alpha0) GE 80d0) OR (FINITE(alpha0) EQ 0)
bad_alpha      = WHERE(test0,bda,COMPLEMENT=good_alpha,NCOMPLEMENT=gda)
IF (gda[0] EQ 0) THEN BEGIN
  ;;  no good Vsw inputs
  alpha = avg_alpha[0]
ENDIF ELSE BEGIN
  alpha = MEDIAN(alpha0[good_alpha])*!DPI/18d1
  IF (FINITE(alpha[0]) EQ 0) THEN alpha = avg_alpha[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define rotation matrix from original basis to aberrated basis
;;----------------------------------------------------------------------------------------
abrot          = [[1d0*COS(alpha[0]), -1d0*SIN(alpha[0]), 0d0], $
                  [1d0*SIN(alpha[0]),  1d0*COS(alpha[0]), 0d0], $
                  [        0d0      ,        0d0       ,  1d0]  ]
scrot          = TRANSPOSE(abrot)                                  ;;  Rotate from aberrated to original input basis
;;----------------------------------------------------------------------------------------
;; Aberrate SC position and magnetic field vectors
;;----------------------------------------------------------------------------------------
;;  Normalize B-field and SC position
sc_pos_u       = unit_vec(sc_pos ,/NAN)
sc_mag_u       = unit_vec(sc_magf,/NAN)
;;  rotate original SC position vectors into aberrated basis
ab_pos         = (abrot ## sc_pos)
;;  rotate original B-field vectors into aberrated basis
ab_magf        = (abrot ## sc_magf)
;;  Normalize aberrated B-field and SC position
ab_pos_u       = unit_vec(ab_pos ,/NAN)
ab_mag_u       = unit_vec(ab_magf,/NAN)
;;----------------------------------------------------------------------------------------
;;  Define dummy arrays
;;----------------------------------------------------------------------------------------
shpos          = REPLICATE(missing[0],npts[0],3L)
shnorm         = shpos
bsn            = shpos[*,0]
lsh            = bsn
connect        = bsn
sh1            = shpos
sh2            = shpos
IF (shn_at_sc[0]) THEN BEGIN
  kpts           = N_ELEMENTS(scbscr[*,0])
  shn_sc         = REPLICATE(missing[0],kpts[0],3L)
  ;;  Aberrate the SC position at the bow shock
  ab_scatbs      = (abrot ## scbscr)
  ;;  Define output keyword values
  scatsab        = ab_scatbs
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define model bow shock parameters
;;----------------------------------------------------------------------------------------
L              = bow.STANDOFF[0]         ;;  L  = semi-latus rectum [Re]
ecc            = bow.ECCENTRICITY[0]     ;;  e  = eccentricity [unitless]
x0             = bow.X_OFFSET[0]         ;;  xo = offset of focus of hyperboloid [Re]
;;;  Calculate the Sun-Earth-Spacecraft Angle [deg]
;sps_ang        = ACOS(sc_pos_u[*,0])*18d1/!DPI
;;;  Calculate the Angle Between and Radial Direction and Conic-Crossing-Normal [deg]
;con_ang        = ATAN(ecc[0]*SIN(sps_ang*!DPI/18d1),(1d0 + ecc[0]*COS(sps_ang*!DPI/18d1)))
;con_ang       *= 18d1/!DPI
;;----------------------------------------------------------------------------------------
;;  Define bow shock parameters
;;----------------------------------------------------------------------------------------
x0             = 1d0*x0
y0             = 0d0
z0             = 0d0
a              = L[0]/(ecc[0]^2 - 1d0)
b              = L[0]/SQRT(ecc[0]^2 - 1d0)
c              = L[0]*ecc[0]/(ecc[0]^2 - 1d0)
;;  vertex of hyperbola at:  [xo +/- a, yo]
nsh            = [c[0] + x0[0] + a[0],0d0,0d0]  ;;  nose of shock in aberrated coordinates
;;  translate aberrated SC position vectors to aberrated basis origin
sc_pos_ab       = ab_pos
sc_pos_ab[*,0] -= (x0[0] + c[0])
;;----------------------------------------------------------------------------------------
;;  Calculate shock normal at crossing location of SC
;;----------------------------------------------------------------------------------------
IF (shn_at_sc[0]) THEN BEGIN
  temp           = 1d0 - (ab_scatbs[*,0] - x0[0] - c[0])^2d0/a[0]^2d0 + (ab_scatbs[*,1]^2d0 + ab_scatbs[*,2]^2d0)/b[0]^2d0
  test           = ABS(temp) GT 0.1
  bad            = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
  shn_sc[*,0]    = -2d0/a[0]^2d0*(ab_scatbs[*,0] - x0[0] - c[0])
  shn_sc[*,1]    =  2d0/b[0]^2d0*ab_scatbs[*,1]
  shn_sc[*,2]    =  2d0/b[0]^2d0*ab_scatbs[*,2]
  ;;  Normalize
  temp           = unit_vec(shn_sc,/NAN)
  shn_sc         = temp
  IF (bd[0] GT 0) THEN shn_sc[bad,*] = d[0]
  ;;  Un-aberrate the shock normal  near crossing location of SC
  temp           = (scrot ## shn_sc)
  shn_sc         = temp
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define hyperbola parameters in aberrated basis
;;----------------------------------------------------------------------------------------
;;  foci of hyperbola at:  [xo +/- c, yo]
x1             =  sc_pos_ab[*,0]
y1             =  sc_pos_ab[*,1] - y0[0]
z1             =  sc_pos_ab[*,2] - z0[0]
;;  hyperbola params
a1             = (b[0]*ab_mag_u[*,0])^2d0 - a[0]^2d0*(ab_mag_u[*,1]^2d0 + ab_mag_u[*,2]^2d0)
b1             = 2d0*b[0]^2d0*ab_mag_u[*,0]*x1 - 2d0*a[0]^2d0*(ab_mag_u[*,1]*y1 + ab_mag_u[*,2]*z1)
c1             = b[0]^2*x1^2d0 - a[0]^2d0*(y1^2d0 + z1^2d0 + b[0]^2d0)
b24ac          = b1^2d0 - 4d0*a1*c1
good           = WHERE(b24ac GE 0,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
IF (bd GT 0) THEN b24ac[bad] = d[0]
;;----------------------------------------------------------------------------------------
;;  Define relative spacecraft positions in aberrated basis
;;----------------------------------------------------------------------------------------
IF (gd GT 0) THEN BEGIN
  ;---------------------------------------------------------------------------------------
  ;;  Define length (along Bo) to shock position at intersection with Bo
  ;---------------------------------------------------------------------------------------
  l1      = (-1d0*b1 + SQRT(b24ac))/(2d0*a1)
  l2      = (-1d0*b1 - SQRT(b24ac))/(2d0*a1)
  ;---------------------------------------------------------------------------------------
  ;;  Define shock position at intersection with Bo
  ;---------------------------------------------------------------------------------------
  FOR j=0L, 2L DO BEGIN
    sh1[*,j] = sc_pos_ab[*,j] + ab_mag_u[*,j]*l1
    sh2[*,j] = sc_pos_ab[*,j] + ab_mag_u[*,j]*l2
  ENDFOR
  FOR k=0L, npts - 1L DO BEGIN
    testx1     = (sh1[k,0] GT nsh[0])
    testx2     = (sh1[k,0] GT nsh[0]) AND (sh2[k,0] GT nsh[0])
    testx3     = (sh2[k,0] LT nsh[0]) AND (ABS(l1[k]) GT ABS(l2[k]))
    ;;  initially set connection = 1
    connect[k] = 1
    IF (testx2) THEN BEGIN
      ;;  B-Field does not cross shock
      ;;    cannot define shock position or length along Bo to shock
      connect[k] = 0
    ENDIF ELSE IF (testx1) THEN BEGIN
      ;;  +solution > standoff estimate
      shpos[k,*]   = sh2[k,*]
      lsh[k]       = l2[k]
    ENDIF ELSE IF (testx3) THEN BEGIN
      ;;  (-solution < standoff estimate) AND (|l+| > |l-|)
      shpos[k,*]   = sh2[k,*]
      lsh[k]       = l2[k]
    ENDIF ELSE BEGIN
      shpos[k,*]   = sh1[k,*]
      lsh[k]       = l1[k]
    ENDELSE
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  Check calcs
  ;;--------------------------------------------------------------------------------------
  temp    = 1d0 - (shpos[*,0])^2d0/a[0]^2d0 + (shpos[*,1]^2d0 + shpos[*,2]^2d0)/b[0]^2d0
  test    = ABS(temp) GT 0.0001
  bad     = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
  IF (bd[0] GT 0) THEN BEGIN
    PRINT,'   Shock calculation error!!!'
    shpos[bad,*] = d[0]
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Use gradient of the surface equation for a hyperboloid of two sheets with axis of
  ;;    symmetry along X-axis to define shock normal:
  ;;               (x - xo)^2     (y - yo)^2     (z - zo)^2
  ;;  S(x,y,z) = - ----------  +  ----------  +  ----------  +  1  =  0
  ;;                  a^2            b^2            b^2
  ;;
  ;;   {where:  a = semi-major axis, b = semi-minor axis, and
  ;;              [x,y,z]o = location of center }
  ;;--------------------------------------------------------------------------------------
  shnorm[*,0]    = -2d0/a[0]^2d0*shpos[*,0]
  shnorm[*,1]    =  2d0/b[0]^2d0*shpos[*,1]
  shnorm[*,2]    =  2d0/b[0]^2d0*shpos[*,2]
  ;;  Normalize
  temp           = unit_vec(shnorm,/NAN)
  shnorm         = temp
  ;;--------------------------------------------------------------------------------------
  ;;  Try to make the shock position intersection and normal match the side of the
  ;;    shock on which the SC is located
  ;;      Expectations:
  ;;      ================================
  ;;      nx       > 0  (always for hyperboloid)
  ;;      sign(ny) = sign(Yposi)
  ;;      sign(nz) = sign(Zposi)
  ;;--------------------------------------------------------------------------------------
  testz          = (ab_pos[*,2]/shnorm[*,2] LT 0)
  testy          = (ab_pos[*,1]/shnorm[*,1] LT 0)
  testx          = (shnorm[*,0] LT 0)
  testxy1        = testx XOR testy
  testxyb        = testx AND testy
  badx           = WHERE(testx AND ~testxyb,bdx)
  bady           = WHERE(testy AND ~testxyb,bdy)
  badz           = WHERE(testz,bdz)
  badxy          = WHERE(testxyb AND ~testxy1,bdxy)
  IF (bdx[0] GT 0) THEN BEGIN
    ;;  Signs of X are wrong
    ;;    --> Rotate by ±90 degrees about Z
    xangs          = ([-1,1]*!DPI/2d0)[shnorm[badx,0] LT 0]
    ones           = REPLICATE(1d0,bdx[0])
    zero           = 0d0*ones
    xzrot          = [[ 1d0*COS(xangs), -1d0*SIN(xangs),zero], $
                      [ 1d0*SIN(xangs),  1d0*COS(xangs),zero], $
                      [        zero   ,       zero     ,ones]  ]
    xzrot          = REFORM(xzrot,bdx[0],3L,3L)
    temp           = REBIN(shnorm[badx,*],bdx[0],3L,3L)
    shnorm[badx,*] = TOTAL(xzrot*temp,2L,/NAN)
  ENDIF
  IF (bdy[0] GT 0) THEN BEGIN
    ;;  Signs of Y are wrong
    ;;    --> Rotate by ±90 degrees about Z
    yangs          = ([-1,1]*!DPI/2d0)[shnorm[bady,1] GT 0]
    ones           = REPLICATE(1d0,bdy[0])
    zero           = 0d0*ones
    yzrot          = [[ 1d0*COS(yangs), -1d0*SIN(yangs),zero], $
                      [ 1d0*SIN(yangs),  1d0*COS(yangs),zero], $
                      [        zero   ,       zero     ,ones]  ]
    yzrot          = REFORM(yzrot,bdy[0],3L,3L)
    temp           = REBIN(shnorm[bady,*],bdy[0],3L,3L)
    shnorm[bady,*] = TOTAL(yzrot*temp,2L,/NAN)
  ENDIF
  IF (bdxy[0] GT 0) THEN BEGIN
    ;;  Signs of both X and Y are wrong
    ;;    --> Rotate by 180 degrees about Z
    xyangs         = REPLICATE(!DPI,bdxy[0])
    ones           = REPLICATE(1d0,bdxy[0])
    zero           = 0d0*ones
    xyzrot         = [[ 1d0*COS(xyangs), -1d0*SIN(xyangs),zero], $
                      [ 1d0*SIN(xyangs),  1d0*COS(xyangs),zero], $
                      [        zero    ,       zero      ,ones]  ]
    xyzrot         = REFORM(xyzrot,bdxy[0],3L,3L)
    temp           = REBIN(shnorm[badxy,*],bdxy[0],3L,3L)
    shnorm[badxy,*] = TOTAL(xyzrot*temp,2L,/NAN)
  ENDIF
  IF (bdz[0] GT 0) THEN BEGIN
    ;;  Signs of Z are wrong
    ;;    --> Rotate by ±90 degrees about X
    zangs          = ([-1,1]*!DPI/2d0)[shnorm[badz,2] LT 0]
    ones           = REPLICATE(1d0,bdz[0])
    zero           = 0d0*ones
    zxrot          = [[        ones   ,        zero    ,        zero   ], $
                      [        zero   ,  1d0*COS(zangs), 1d0*SIN(zangs)], $
                      [        zero   , -1d0*SIN(zangs), 1d0*COS(zangs)]  ]
    zxrot          = REFORM(zxrot,bdz[0],3L,3L)
    temp           = REBIN(shnorm[badz,*],bdz[0],3L,3L)
    shnorm[badz,*] = TOTAL(zxrot*temp,2L,/NAN)
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Calc. angle between local B-field and projection of shock normal at spacecraft
  ;;--------------------------------------------------------------------------------------
  b_dot_n        = shnorm[*,0]*ab_mag_u[*,0] + shnorm[*,1]*ab_mag_u[*,1] + shnorm[*,2]*ab_mag_u[*,2]
  bsn0           = ACOS(b_dot_n)*18d1/!DPI
  bsn1           = 18d1 - ACOS(b_dot_n)*18d1/!DPI
  bsn            = bsn0 < bsn1
  ;;--------------------------------------------------------------------------------------
  ;;  Un-aberrate the shock normal and shock position
  ;;--------------------------------------------------------------------------------------
  temp           = (scrot ## shnorm)
  shnorm         = temp
  temp0          = shpos
  temp0[*,0]    += (x0[0] + c[0])
  temp           = (scrot ## temp0)
  shpos          = temp
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
str_element,struct,'CONNECT',connect,/ADD_REPLACE
str_element,struct,'SHPOS',shpos,/ADD_REPLACE
str_element,struct,'SHNORM',shnorm,/ADD_REPLACE
str_element,struct,'BSN',bsn,/ADD_REPLACE
str_element,struct,'LSN',lsh,/ADD_REPLACE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END





