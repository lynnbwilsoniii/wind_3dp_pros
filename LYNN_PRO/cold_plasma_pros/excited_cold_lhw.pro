;+
;*****************************************************************************************
;
;  FUNCTION :   excited_cold_lhw.pro
;  PURPOSE  :   Attempts to calculate the wave normal surface for an arbitrary propagation
;                 angle with respect to the magnetic field.  The program also calculates
;                 some parameters determined by Bell and Ngo, [1990] 
;                 {see reference below} to determine possible propagation surfaces for
;                 different wave properties and environments (i.e. density and B-field
;                 strength).
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               cold_plasma_params.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MAGF   :  1-Element array of magnetic field magnitudes [nT]
;               DENS   :  " " plasma densities [cm^(-3)]
;               F0(1)  :  Lower(Upper) frequency bound [Hz]
;
;  EXAMPLES:    
;               no        = 14.147
;               bo        = 17.279
;               f0        = 150.0
;               f1        = 200.0
;               ndat      = 1000L
;               kvec      = [-0.07895,-0.99658, 0.02448]
;               bvec      = [0.053,0.979,-0.197]
;               nvec      = [-0.655,0.040,-0.754]
;               test      = excited_cold_lhw(bo,no,f0,f1,NDAT=ndat,NVEC=nvec,BVEC=bvec,KVEC=kvec)
;               ; => Determine wave propagation angle with respect to magnetic field
;               kvec      = kvec/NORM(kvec)
;               bvec      = bvec/NORM(bvec)
;               thkb      = ACOS(my_dot_prod(kvec,bvec,/NOM))
;               PRINT, thkb*18d1/!DPI
;                      169.94078
;               ; => Now define wave normal surfaces
;               nsurf0    = test.NSURF_STIX92.FLOW
;               nsurf1    = test.NSURF_STIX92.FHIGH
;               ; => remember the angle is from z-axis, NOT x-axis so rotate!
;               anglew    = DINDGEN(ndat)*(2d0*!DPI)/(ndat - 1L) + !DPI/2d0
;               ; => Now plot wave normal surface with k-vector overplotted
;               WINDOW,0,RETAIN=2,XSIZE=850,YSIZE=800
;               xyra = [-1.1*MAX(ABS(nsurf0),/NAN),1.1*MAX(ABS(nsurf0),/NAN)]
;               pstr = {POLAR:1,NODATA:1,YRANGE:xyra,XRANGE:xyra,XSTYLE:1,YSTYLE:1}
;               PLOT,REFORM(ABS(nsurf0[*,0])),anglew,_EXTRA=pstr
;                 OPLOT,REFORM(ABS(nsurf0[*,0])),anglew,/POLAR,COLOR=30
;                 OPLOT,[0d0,xyra[1]],[0d0,!DPI/2d0 - thkb[0]],/POLAR,COLOR=250
;               
;
;  KEYWORDS:    
;               NDAT   :  Scalar number of values to create for dummy frequencies or
;                           angles
;               CHI    :  Scalar angle (deg) that defines the angle between the ambient
;                           magnetic field vector and the surface of the density irreg.
;                           [e.g. for a shock surface, chi = 90 - theta_Bn]
;               NVEC   :  3-Element array corresponding to the unit vector normal
;                           to the density irreg. surface
;               BVEC   :  3-Element array corresponding to the magnetic field unit 
;                           vector
;               KVEC   :  3-Element array corresponding to the wave propagation
;                           unit vector
;
;   CHANGED:  1)  Fixed a typo in n^2 root finding loop            [10/26/2010   v1.0.1]
;
;   NOTES:      
;               1)  The calculations in this program are referenced to either:
;                   A.
;                     T.F. Bell and H.D. Ngo (1990), "Electrostatic Lower Hybrid Waves
;                       Excited by Electromagnetic Whistler Mode Waves Scattering from
;                       Planar Magnetic-Field-Aligned Plasma Density Irregularities,"
;                       J. Geophys. Res. Vol. 95, pg. 149-172.
;                   B.
;                     T.H. Stix (1992), "Waves in Plasmas," Springer-Verlag,
;                       New York, Inc.
;               2)  The keywords NVEC, BVEC, and KVEC must be used together if used
;                     at all
;               3)  Coordinate system is as follows:
;                     X'  =  parallel to normal vector of density irreg. plane
;                     Z'  =  parallel to ambient magnetic field
;                     Y'  =  (Z x X)
;
;   CREATED:  10/22/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/26/2010   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION excited_cold_lhw,magf,dens,f0,f1,NDAT=ndat,CHI=chi,NVEC=nvec,BVEC=bvec,KVEC=kvec

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
wcefac         = qq/me                  ; => Factor for angular electron cyclotron freq.
wcpfac         = qq/mp                  ; => Factor for angular proton cyclotron freq.
wpefac         = SQRT(qq^2/me/epo)      ; => Factor for angular electron plasma freq.
wppfac         = SQRT(qq^2/mp/epo)      ; => Factor for angular proton plasma freq.
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (~KEYWORD_SET(ndat) OR N_ELEMENTS(ndat) EQ 0) THEN ndat = 100L ELSE ndat = LONG(ndat)
; => Use angles from 0 to 2 pi
angle      = DINDGEN(ndat)*(2d0*!DPI)/(ndat - 1L)
costhkb    = COS(angle)                    ; => Convert angles to cosines
sinthkb    = SIN(angle)                    ; => Convert angles to sines

pdens      = REFORM(dens)*1d6              ; => Convert density to # m^(-3)
bmag       = REFORM(magf)*1d-9             ; => Convert B-field to T

no         = REFORM(dens[0])
bo         = REFORM(magf[0])

test0      = cold_plasma_params(bo[0],no[0],FREQF=f0,NDAT=ndat)
test1      = cold_plasma_params(bo[0],no[0],FREQF=f1,NDAT=ndat)

dummy      = REPLICATE(d,ndat)
;nsquared0  = test0.INDEX_REF_1      ; => Eq. (1-34), Stix [1992] {negative sign}
pp0        = test0.P_TERM[0]        ; => Eq. (1-22), Stix [1992]
ss0        = test0.S_TERM[0]        ; => Eq. (1-19), Stix [1992]
rr0        = test0.R_TERM[0]        ; => Eq. (1-20), Stix [1992]
ll0        = test0.L_TERM[0]        ; => Eq. (1-21), Stix [1992]
aterm0     = ss0[0]*sinthkb^2 + pp0[0]*costhkb^2  ; => Eq. (1-30), Stix [1992]
bterm0     = rr0[0]*ll0[0]*sinthkb^2 + pp0[0]*ss0[0]*(1d0 + costhkb^2)
cterm0     = pp0[0]*rr0[0]*ll0[0]

;nsquared1  = test1.INDEX_REF_1
pp1        = test1.P_TERM[0]
ss1        = test1.S_TERM[0]
rr1        = test1.R_TERM[0]
ll1        = test1.L_TERM[0]
aterm1     = ss1[0]*sinthkb^2 + pp1[0]*costhkb^2  ; => Eq. (1-30), Stix [1992]
bterm1     = rr1[0]*ll1[0]*sinthkb^2 + pp1[0]*ss1[0]*(1d0 + costhkb^2)
cterm1     = pp1[0]*rr1[0]*ll1[0]
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; => Now solve the polynomial:  e n^4 + d n^3 + c n^2 + b n + a = 0
;     for the special case of:  A n^4 - B n^2 + C = 0
;     {where:  n^2 = nx^2 + ny^2 + nz^2}
;
;     e = A
;     d = 0
;     c = -B
;     b = 0
;     a = C
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
nn0    = DCOMPLEXARR(ndat,4)  ; => Roots of Eq. (1-29), Stix [1992] for low frequency
nn1    = DCOMPLEXARR(ndat,4)  ; => Roots of Eq. (1-29), Stix [1992] for high frequency
nsurf0 = DCOMPLEXARR(ndat,4)  ; => Roots of Eq. (1-46), Stix [1992] for low frequency
nsurf1 = DCOMPLEXARR(ndat,4)  ; => Roots of Eq. (1-46), Stix [1992] for high frequency
IF (FINITE(cterm0[0]) EQ 0 AND FINITE(cterm1[0]) EQ 0) THEN BEGIN
  GOTO,JUMP_SKIP
ENDIF ELSE BEGIN
  a0 = cterm0[0]
  a1 = cterm1[0]
ENDELSE

FOR p=0L, ndat - 1L DO BEGIN
  ; => Check coefficients to make sure they are finite 
  good = FINITE(aterm0[p]) AND FINITE(bterm0[p])
  IF (good) THEN BEGIN
    coeffs0  = [a0,0d0,-1d0*bterm0[p],0d0,aterm0[p]]
    roots00  = FZ_ROOTS(coeffs0,/DOUBLE,/NO_POLISH)
    nn0[p,*] =  roots00
  ENDIF ELSE nn0[p,*] = DCOMPLEX(d,d)
  good = FINITE(aterm1[p]) AND FINITE(bterm1[p])
  IF (good) THEN BEGIN
    coeffs1  = [a1,0d0,-1d0*bterm1[p],0d0,aterm1[p]]
    roots01  = FZ_ROOTS(coeffs1,/DOUBLE,/NO_POLISH)
    nn1[p,*] =  roots01
  ENDIF ELSE nn1[p,*] = DCOMPLEX(d,d)
ENDFOR
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; => Now solve the polynomial:  e u^4 + d u^3 + c u^2 + b u + a = 0
;     for the special case of:  C u^4 - B u^2 + A = 0
;     {where:  u = 1/n = omega/(kc)}
;
;     e = C
;     d = 0
;     c = -B
;     b = 0
;     a = A
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FOR p=0L, ndat - 1L DO BEGIN
  ; => Check coefficients to make sure they are finite 
  good = FINITE(aterm0[p]) AND FINITE(bterm0[p])
  IF (good) THEN BEGIN
    coeffs0  = [aterm0[p],0d0,-1d0*bterm0[p],0d0,a0]
    roots00  = FZ_ROOTS(coeffs0,/DOUBLE,/NO_POLISH)
    nsurf0[p,*] =  roots00
  ENDIF ELSE nsurf0[p,*] = DCOMPLEX(d,d)
  good = FINITE(aterm1[p]) AND FINITE(bterm1[p])
  IF (good) THEN BEGIN
    coeffs1  = [aterm1[p],0d0,-1d0*bterm1[p],0d0,a1]
    roots01  = FZ_ROOTS(coeffs1,/DOUBLE,/NO_POLISH)
    nsurf1[p,*] =  roots01
  ENDIF ELSE nsurf1[p,*] = DCOMPLEX(d,d)
ENDFOR
;=========================================================================================
JUMP_SKIP:
;=========================================================================================
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
nsquared0  = REAL_PART(REFORM(nn0[*,0]))^2
angs0      = dummy
; => The next line is assuming that n^2 is either entirely real (i.e. > 0) or entirely
;      imaginary (i.e. < 0)
good0      = WHERE(nsquared0 GE 0.,gd0,COMPLEMENT=bad0,NCOMPLEMENT=bd0)
; => Range of angles away from z-axis (Bo direction) [deg]
IF (gd0 GT 0) THEN angs0[good0] = test0.ANGLES[good0]
IF (bd0 GT 0) THEN nsquared0[bad0] = d
; => The next calculation is from 1st paragraph, page 150 {Bell and Ngo, [1990]}
nzz0       = SQRT(nsquared0[*])*COS(angs0[*]*!DPI/18d1)  ; => NDAT-Element array


nsquared1  = REAL_PART(REFORM(nn1[*,0]))^2
angs1      = dummy
good1      = WHERE(nsquared1 GE 0.,gd1,COMPLEMENT=bad1,NCOMPLEMENT=bd1)
IF (gd1 GT 0) THEN angs1[good1] = test1.ANGLES[good1]
IF (bd1 GT 0) THEN nsquared1[bad1] = d
nzz1       = SQRT(nsquared1[*])*COS(angs1[*]*!DPI/18d1)

; => Calculate parameters from Bell and Ngo, [1990]
beta_10    = (pp0[0] + rr0[0]*ll0[0]/ss0[0] - nzz0^2*(1d0 + pp0[0]/ss0[0]))/2d0  ; => Eq. (1), Bell and Ngo, [1990]
beta_20    = (nzz0^4 - 2d0*ss0[0]*nzz0^2 + rr0[0]*ll0[0])*(pp0[0]/ss0[0])        ; => Eq. (1), Bell and Ngo, [1990]

beta_11    = (pp1[0] + rr1[0]*ll1[0]/ss1[0] - nzz1^2*(1d0 + pp1[0]/ss1[0]))/2d0  ; => Eq. (1), Bell and Ngo, [1990]
beta_21    = (nzz1^4 - 2d0*ss1[0]*nzz1^2 + rr1[0]*ll1[0])*(pp1[0]/ss1[0])        ; => Eq. (1), Bell and Ngo, [1990]
; => Now solve the polynomial:  nperp^4 - 2*beta_10*nperp^2 + beta_20 = 0
;     {where:  nperp^2 = nx^2 + ny^2}
nperp_0    = DCOMPLEXARR(ndat,4)
nperp_1    = DCOMPLEXARR(ndat,4)
FOR p=0L, ndat - 1L DO BEGIN
  good         = FINITE(beta_20[p]) AND FINITE(beta_10[p])
  IF (good) THEN BEGIN
    coeffs0      = [beta_20[p],0d0,-2d0*beta_10[p],0d0,1d0]
    roots00      = FZ_ROOTS(coeffs0,/DOUBLE,/NO_POLISH)
    nperp_0[p,*] = roots00
  ENDIF ELSE nperp_0[p,*] = DCOMPLEX(d,d)
  good         = FINITE(beta_11[p]) AND FINITE(beta_21[p])
  IF (good) THEN BEGIN
    coeffs1      = [beta_21[p],0d0,-2d0*beta_11[p],0d0,1d0]
    roots01      = FZ_ROOTS(coeffs1,/DOUBLE,/NO_POLISH)
    nperp_1[p,*] = roots01
  ENDIF ELSE nperp_1[p,*] = DCOMPLEX(d,d)
ENDFOR
;-----------------------------------------------------------------------------------------
; => Set up coordinate system
;-----------------------------------------------------------------------------------------
test0 = (KEYWORD_SET(nvec) AND KEYWORD_SET(bvec) AND KEYWORD_SET(kvec))
test1 = (SIZE(REFORM(nvec),/DIMENSIONS) EQ 3) AND $
        (SIZE(REFORM(bvec),/DIMENSIONS) EQ 3) AND $
        (SIZE(REFORM(kvec),/DIMENSIONS) EQ 3)

IF (test0 AND test1) THEN BEGIN
  nvec = REFORM(nvec)
  bvec = REFORM(bvec)
  kvec = REFORM(kvec)
  ; => Renormalize
  nvec = (nvec)/(NORM(nvec))[0]
  bvec = (bvec)/(NORM(bvec))[0]
  kvec = (kvec)/(NORM(kvec))[0]
  ; => rotate vectors into new coordinate system where nvec // X'-direction and
  ;      bvec is in X'Z'-plane
  a    = nvec
  b    = CROSSP(nvec,bvec)
  b    = b/(NORM(b))[0]
  c    = CROSSP(b,nvec)
  c    = c/(NORM(c))[0]
  mrot = [[a],[b],[c]]
  nnv  = REFORM(mrot ## nvec)
  bbv  = REFORM(mrot ## bvec)
  kkv  = REFORM(mrot ## kvec)
  ; => Define chi here [overrides keyword if these three are set]
  chi  = ACOS(bbv[2]/(NORM(bbv))[0])*18d1/!DPI
  ; => Use kkv to define relevant spherical coordinate angles since 
  ;      ny and nx will depend upon these
  phiv = ATAN(kkv[1],kkv[0])
  thev = ACOS(kkv[2]/(NORM(kkv))[0])
  mn0  = MIN(ABS(thev[0] - angs0),/NAN,ln0)
  mn1  = MIN(ABS(thev[0] - angs1),/NAN,ln1)
  nz0t = SQRT(nsquared0[ln0])*COS(angs0[ln0]*!DPI/18d1)
  nz1t = SQRT(nsquared1[ln1])*COS(angs1[ln1]*!DPI/18d1)
  ny0  = SQRT(nsquared0[ln0])*SIN(thev)*SIN(angs0[ln0]*!DPI/18d1)
  ny1  = SQRT(nsquared1[ln1])*SIN(thev)*SIN(angs1[ln1]*!DPI/18d1)
  n0z  = REPLICATE(nz0t[0],ndat)
  n1z  = REPLICATE(nz1t[0],ndat)
  phi0 = phiv
  phi1 = phiv
  the0 = thev
  the1 = thev
ENDIF ELSE BEGIN
  n0z  = nzz0
  n1z  = nzz1
  ny0  = 0d0
  ny1  = 0d0
  phi0 = 0d0
  phi1 = 0d0
  the0 = angs0
  the1 = angs1
  ; => Assume B-field is aligned with the density irreg. plane
  chi  = 0d0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Calculation of nx roots for tilted density irregularity assuming 
;-----------------------------------------------------------------------------------------
IF (KEYWORD_SET(chi) OR N_ELEMENTS(chi) NE 0) THEN BEGIN
  ; => Define some constants related to chi
  chir  = chi[0]*!DPI/18d1
  cchi  = COS(chir)
  c2chi = COS(2d0*chir)
  schi  = SIN(chir)
  s2chi = SIN(2d0*chir)
  cchi2 = cchi^2
  schi2 = schi^2
  chi12 = 1d0 + cchi2
  shi12 = 1d0 + schi2
  ; => Define some constants which appear in coefficient calculations
  dfps  = (pp0[0] - ss0[0])
  addps = (ss0[0] + pp0[0])
  mmps  = pp0[0]*ss0[0]
  mmrl  = rr0[0]*ll0[0]
  dfps1 = (pp1[0] - ss1[0])
  adps1 = (ss1[0] + pp1[0])
  mmps1 = pp1[0]*ss1[0]
  mmrl1 = rr1[0]*ll1[0]
  ; => Calculate coefficient alpha_4, Eq. (16), Bell and Ngo, [1990]
  aa40  = ss0[0]*cchi2 + pp0[0]*schi2
  aa41  = ss1[0]*cchi2 + pp1[0]*schi2
  aa0s  = DBLARR(ndat,5)       ; => Coefficients in Eq. (16), Bell and Ngo, [1990]
  aa1s  = DBLARR(ndat,5)
  nx_0  = DCOMPLEXARR(ndat,4)
  nx_1  = DCOMPLEXARR(ndat,4)
  FOR p=0L, ndat - 1L DO BEGIN 
    nz0        = n0z[p]
    nz1        = n1z[p]
    ;-------------------------------------------------------------------------------------
    ; => Calculate coefficient alpha_3, Eq. (16), Bell and Ngo, [1990]
    ;-------------------------------------------------------------------------------------
    aa30       = dfps[0]*nz0[0]*s2chi
    ;-------------------------------------------------------------------------------------
    ; => Calculate coefficient alpha_2, Eq. (16), Bell and Ngo, [1990]
    ;-------------------------------------------------------------------------------------
    temp0      = addps[0]*nz0[0]^2 + (ss0[0]*chi12 + pp0[0]*schi2)*ny0[0]^2
    temp1      = -1d0*mmrl[0]*cchi2 - mmps[0]*shi12
    aa20       = temp0 + temp1
    ;-------------------------------------------------------------------------------------
    ; => Calculate coefficient alpha_1, Eq. (16), Bell and Ngo, [1990]
    ;-------------------------------------------------------------------------------------
    temp0      = nz0[0]^2*s2chi
    temp1      = dfps[0]*(ny0[0]^2 + nz0[0]^2) + mmrl[0] - mmps[0]
    aa10       = temp0*temp1
    ;-------------------------------------------------------------------------------------
    ; => Calculate coefficient alpha_0, Eq. (16), Bell and Ngo, [1990]
    ;-------------------------------------------------------------------------------------
    temp0      = ss0[0]*(ny0[0]^2 + nz0[0]^2)*(ny0[0]^2 + nz0[0]^2*schi2)
    temp1      = pp0[0]*nz0[0]^2*(ny0[0]^2 + nz0[0]^2)*cchi2
    temp2      = -1d0*mmps[0]*(ny0[0]^2 + nz0[0]^2*chi12) + pp0[0]*mmrl[0]
    temp3      = -1d0*mmrl[0]*(ny0[0]^2 + nz0[0]^2*schi2)
    aa00       = temp0 + temp1 + temp2 + temp3
    ;-------------------------------------------------------------------------------------
    ; => Repeat for higher frequency solutions
    ;-------------------------------------------------------------------------------------
    aa31       = dfps1[0]*nz1[0]*s2chi
    temp0      = adps1[0]*nz1[0]^2 + (ss1[0]*chi12 + pp1[0]*schi2)*ny1[0]^2
    temp1      = -1d0*mmrl1[0]*cchi2 - mmps1[0]*shi12
    aa21       = temp0 + temp1
    temp0      = nz1[0]^2*s2chi
    temp1      = dfps1[0]*(ny1[0]^2 + nz1[0]^2) + mmrl1[0] - mmps1[0]
    aa11       = temp0*temp1
    temp0      = ss1[0]*(ny1[0]^2 + nz1[0]^2)*(ny1[0]^2 + nz1[0]^2*schi2)
    temp1      = pp1[0]*nz1[0]^2*(ny1[0]^2 + nz1[0]^2)*cchi2
    temp2      = -1d0*mmps1[0]*(ny1[0]^2 + nz1[0]^2*chi12) + pp1[0]*mmrl1[0]
    temp3      = -1d0*mmrl1[0]*(ny1[0]^2 + nz1[0]^2*schi2)
    aa01       = temp0 + temp1 + temp2 + temp3
    ;-------------------------------------------------------------------------------------
    ; => Calculate the roots of nx, Eq. (16), Bell and Ngo, [1990]
    ;-------------------------------------------------------------------------------------
    aa0s[p,*]  = [aa00,aa10,aa20,aa30,aa40]
    aa1s[p,*]  = [aa01,aa11,aa21,aa31,aa41]
    roots00    = FZ_ROOTS([aa00,aa10,aa20,aa30,aa40],/DOUBLE,/NO_POLISH)
    roots01    = FZ_ROOTS([aa01,aa11,aa21,aa31,aa41],/DOUBLE,/NO_POLISH)
    nx_0[p,*]  = roots00
    nx_1[p,*]  = roots01
  ENDFOR
ENDIF ELSE BEGIN
  aa0s  = REPLICATE(d,ndat,5)       ; => Coefficients in Eq. (16), Bell and Ngo, [1990]
  aa1s  = REPLICATE(d,ndat,5)
  nx_0  = nperp_0
  nx_1  = nperp_1
ENDELSE
;-----------------------------------------------------------------------------------------
; => Return relevant data to user
;-----------------------------------------------------------------------------------------
tags    = ['FLOW','FHIGH']
nstruct = CREATE_STRUCT(tags,nsquared0,nsquared1)
nsurfct = CREATE_STRUCT(tags,nsurf0,nsurf1)
nrstrct = CREATE_STRUCT(tags,nn0,nn1)
npstrct = CREATE_STRUCT(tags,nperp_0,nperp_1)
nzstrct = CREATE_STRUCT(tags,n0z,n1z)
nystrct = CREATE_STRUCT(tags,ny0,ny1)
nxstrct = CREATE_STRUCT(tags,nx_0,nx_1)
aastrct = CREATE_STRUCT(tags,aa0s,aa1s)
thstrct = CREATE_STRUCT(tags,the0,the1)
phstrct = CREATE_STRUCT(tags,phi0,phi0)

tags    = ['NROOTS_STIX92','NSURF_STIX92','N2_STIX92','NX_BELL90','NY_BELL90',$
           'NZ_BELL90','NX_COEFF_BELL90','NPERP_BELL90','KTHETA','KPHI','CHI']
struct  = CREATE_STRUCT(tags,nrstrct,nsurfct,nstruct,nxstrct,nystrct,nzstrct,aastrct,$
                        npstrct,thstrct,phstrct,chi)

RETURN,struct
END