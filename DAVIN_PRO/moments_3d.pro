;+
;*****************************************************************************************
;
;  FUNCTION :   moments_3d.pro
;  PURPOSE  :   Returns all useful moments of a distribution function as a structure
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               convert_ph_units.pro
;               conv_units.pro
;               moments_3d.pro
;               str_element.pro
;               moments_3d.pro
;               sc_pot.pro
;               rot_mat.pro
;               xyz_to_polar.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA            : 3d data structure.  (i.e. see "GET_EL")
;
;  EXAMPLES:    
;               test = moments_3d()
;
;  KEYWORDS:    
;               SC_POT          :  Scalar defining the spacecraft potential (eV)
;               MAGDIR          :  3-Element vector defining the magnetic field (nT)
;                                    associated with the data structure
;               TRUE_DENS       :  Scalar defining the true density (cc)
;               PARDENS         :  Scalar defining the density (cc) ??
;               DENS_ONLY       :  If set, program only returns the density estimate (cc)
;               MOM_ONLY        :  If set, program only returns through flux (1/cm/s^2)
;               ADD_MOMENT      :  Set to a structure of identical format to the return
;                                    format of this program to be added to the structure
;                                    being manipulated
;               ERANGE          :  Set to a 2-Element array specifying the first and last
;                                    elements of the energy bins desired to be used for
;                                    calculating the moments
;               FORMAT          :  Set to a dummy variable which will be returned the
;                                    as the structure format associated with the output
;                                    structure of this program
;               BINS            :  Old keyword apparently
;               VALID           :  Set to a dummy variable which will return a 1 for a
;                                    structure with useful data or 0 for a bad structure
;               DMOM            :  Set to a named variable to return the uncertainties in
;                                    the distribution moment calculations
;               DOMEGA_WEIGHTS  :  If set, routine uses solid angle estimates determined
;                                    by moments_3d_omega_weights.pro instead of using
;                                    DOMEGA values existing in IDL structures
;
;   CHANGED:  1)  Davin Larson created                     [??/??/????   v1.0.0]
;             2)  Updated man page                         [01/05/2009   v1.0.1]
;             3)  Fixed comments regarding tensors         [01/28/2009   v1.0.2]
;             4)  Changed an assignment variable           [03/01/2009   v1.0.3]
;             5)  Changed SC Potential calc to avoid redefining the original variable
;                                                          [03/04/2009   v1.0.4]
;             6)  Updated man page                         [03/20/2009   v1.0.5]
;             7)  Changed SC Potential keyword to avoid conflicts with
;                   sc_pot.pro calling                     [04/17/2009   v1.0.6]
;             8)  Updated man page                         [06/17/2009   v1.1.0]
;             9)  Added comments and units to calcs        [08/20/2009   v1.1.1]
;            10)  Added error handling and the programs:  
;                   convert_ph_units.pro and dat_3dp_str_names.pro
;                                                          [08/25/2009   v1.2.0]
;            11)  Fixed a typo that ONLY affected Pesa High data structures
;                                                          [04/09/2010   v1.2.1]
;            12)  Updated man page and cleaned up comments [06/14/2011   v1.3.0]
;            13)  Added charge to calculations to give a sign to the SC potential
;                                                          [07/25/2011   v1.4.0]
;
;   NOTES:      
;               1)  Adaptations from routines written by Jim McFadden are used
;
;  REFERENCES:  
;               1)  Curtis et al., (1989), "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372.
;               2)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  07/25/2011   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION moments_3d,data,     $
   SC_POT      = scpot,       $
   MAGDIR      = magdir,      $
   TRUE_DENS   = tdens,       $
   COMP_SC_POT = comp_sc_pot, $
   PARDENS     = pardens,     $
   DENS_ONLY   = dens_only,   $
   MOM_ONLY    = mom_only,    $
   ADD_MOMENT  = add_moment,  $
   ERANGE      = er,          $
   FORMAT      = momformat,   $
   BINS        = bins,        $ 
   VALID       = valid

;-----------------------------------------------------------------------------------------
; => Define dummy variables and structures
;-----------------------------------------------------------------------------------------
f   = !VALUES.F_NAN
f3  = [f,f,f]
f6  = [f,f,f,f,f,f]
f33 = [[f3],[f3],[f3]]
d   = !VALUES.D_NAN

IF (SIZE(momformat,/TYPE) EQ 8) THEN mom = momformat ELSE $
   mom = {TIME:d, SC_POT:f, SC_CURRENT:f, MAGF:f3, DENSITY:f, AVGTEMP:f, VTHERMAL:f, $
          VELOCITY:f3, FLUX:f3, PTENS:f6, MFTENS:f6,T3:f3, SYMM:f3, SYMM_THETA:f,    $
          SYMM_PHI:f, SYMM_ANG:f,MAGT3:f3, ERANGE:[f,f], MASS:f,VALID:0} 

mom.VALID = 0
IF (N_PARAMS() EQ 0) THEN GOTO,skipsums
;-----------------------------------------------------------------------------------------
; -Make sure nothing reassigns values to original data
;-----------------------------------------------------------------------------------------
dd     = data
IF (SIZE(dd,/TYPE) NE 8) THEN RETURN,mom
valid  = 0
strn   = dat_3dp_str_names(dd)
sname  = STRLOWCASE(STRMID(strn.SN,0L,2L))
ssname = STRLOWCASE(STRMID(strn.SN,0L,1L))
; => Use Energy Flux [eV cm^(-2) s^(-1) sr^(-1) eV^(-1)]
CASE ssname[0] OF
  'p' : BEGIN
    ; => PESA
    IF (sname[0] EQ 'ph') THEN BEGIN
      convert_ph_units,dd,'eflux'
      data3d = dd
    ENDIF ELSE  BEGIN
      data3d = conv_units(dd,'eflux')
    ENDELSE
    charge =  1e0
  END
  'e' : BEGIN
    ; => EESA
    data3d = conv_units(dd,'eflux')
    charge = -1e0
  END
  ELSE : BEGIN
    ; => SST
    data3d = conv_units(dd,'eflux')
    IF (sname[0] EQ 'sf') THEN BEGIN
      charge = -1e0
    ENDIF ELSE  BEGIN
      charge =  1e0
    ENDELSE
  END
ENDCASE
mom.TIME = data3d.TIME
mom.MAGF = data3d.MAGF
IF (dd.VALID EQ 0) THEN RETURN,mom
e  = data3d.ENERGY
nn = data3d.NENERGY
;-----------------------------------------------------------------------------------------
; -Determine energy range
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(er) THEN BEGIN
   err                = 0 >  er < (nn-1)
   s                  = e
   s[*]               = 0.
   s[err[0]:err[1],*] = 1.
   data3d.DATA        = data3d.DATA * s
ENDIF ELSE  BEGIN
   err = [0,nn-1]
ENDELSE
mom.ERANGE = data3d.ENERGY[err,0]
;-----------------------------------------------------------------------------------------
;if keyword_set(bins) then begin 
;   if ndimen(bins) eq 2 then w = where(bins eq 0,c)   $
;   else  w = where((replicate(1b,nn) # bins) eq 0,c)
;   if c ne 0 then data3d.data[w]=0
;endif
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(bins) THEN MESSAGE,/INFO,'bins keyword ignored'
w = WHERE(data3d.BINS EQ 0,c)
IF (c NE 0) THEN data3d.DATA[w] = 0
;-----------------------------------------------------------------------------------------
; -Determine or set spacecraft (SC) potential
;-----------------------------------------------------------------------------------------
IF (KEYWORD_SET(scpot))   THEN pot = scpot ELSE pot = 0.
IF (N_ELEMENTS(pot) EQ 0) THEN str_element,data3d,'SC_POT',pot
IF (N_ELEMENTS(pot) EQ 0) THEN pot = 0.
IF (NOT FINITE(pot)) THEN pot = 6.

IF KEYWORD_SET(tdens) THEN BEGIN
   pota = [3.,12.]
   m0   = moments_3d(data3d,SC_POT=pota[0],/DENS_ONLY)
   m1   = moments_3d(data3d,SC_POT=pota[1],/DENS_ONLY)
   dens = [m0.DENSITY,m1.DENSITY]
   FOR i = 0L, 4L DO BEGIN 
      yp   = (dens[0] - dens[1])/(pota[0] - pota[1])
      pot  = pota[0] - (dens[0] - tdens) / yp
      m0   = moments_3d(data3d,SC_POT=pot,/DENS_ONLY)
      dens = [m0.DENSITY,dens]
      pota = [pot,pota]
   ENDFOR
ENDIF

IF KEYWORD_SET(comp_sc_pot) THEN BEGIN
;   par = {v0:-1.9036d,n0:533.7d }
   FOR i = 0L, 3L DO BEGIN 
     m   = moments_3d(data3d,SC_POT=pot,/DENS_ONLY)
     pot = sc_pot(m.DENSITY)
   ENDFOR
ENDIF
;-----------------------------------------------------------------------------------------
; -Determine differential energy then calculate DF differential
;-----------------------------------------------------------------------------------------
mom.SC_POT   = pot[0]
domega       = REPLICATE(1.,nn) # data3d.DOMEGA       ; => Solid Angle [sr]

de_e         = ABS(SHIFT(e,1) - SHIFT(e,-1))/(2.0*e)  ; => [unitless]
de_e[0,*]    = de_e[1,*]
de_e[nn-1,*] = de_e[nn-2,*]
de           = de_e * e                               ; => [eV]

weight   = 0. > ((e + pot/charge)/de + .5) < 1.       ; => [unitless]
; => LBW III  07/25/2011
;weight   = 0. > ((e - pot)/de + .5) < 1.              ; => [unitless]
dvolume  =  de_e * domega * weight                    ; => [sr]
data_dv  = data3d.DATA * dvolume                      ; => DF differential  [cm^(-2) s^(-1)]
e_inf    = (e + pot/charge) > 0.                      ; => [eV]
; => LBW III  07/25/2011
;e_inf    = (e - pot) > 0.                             ; => [eV]

mom.MASS = data3d.MASS                                ; => Particle mass [eV/(km/sec)^2]
mass     = mom.MASS
;-----------------------------------------------------------------------------------------
; => Current calculation:
;-----------------------------------------------------------------------------------------
mom.SC_CURRENT = TOTAL(data_dv,/NAN)
;-----------------------------------------------------------------------------------------
; => Density calculation:  cm^(-3)
;-----------------------------------------------------------------------------------------
dweight     = SQRT(e_inf)/e                             ; => [eV^(-1/2)]
par_factor  = SQRT(mass/2.) * 1e-5                      ; => [eV^(1/2) / (cm/s)]
; => Note:  The factor of 1e-5 is to change [km] to [cm]
pardens     = par_factor * data_dv * dweight            ; => [cm^(-3)]
mom.DENSITY = TOTAL(pardens,/NAN)                       ; => [cm^(-3)]
;plot,sqrt(mass/2.) * total(pardens,2) * 1e-5,psym=10
IF KEYWORD_SET(dens_only) THEN RETURN,mom
;-----------------------------------------------------------------------------------------
; => FLUX calculation:  [cm^(-2) s^(-1)]
;-----------------------------------------------------------------------------------------
sin_phi  = SIN(data3d.PHI/!RADEG)
cos_phi  = COS(data3d.PHI/!RADEG)
sin_th   = SIN(data3d.THETA/!RADEG)
cos_th   = COS(data3d.THETA/!RADEG)
cos2_th  = cos_th^2
cthsth   = cos_th*sin_th

fwx      = cos_phi * cos_th * e_inf / e
fwy      = sin_phi * cos_th * e_inf / e
fwz      = sin_th * e_inf / e

parfluxx = data_dv * fwx
parfluxy = data_dv * fwy
parfluxz = data_dv * fwz
fx       = TOTAL(parfluxx,/NAN)
fy       = TOTAL(parfluxy,/NAN)
fz       = TOTAL(parfluxz,/NAN)

mom.FLUX = [fx,fy,fz]     ; Units: [cm^(-2) s^(-1)]
;-----------------------------------------------------------------------------------------
; => VELOCITY FLUX:  [eV^(1/2) cm^(-2) s^(-1)]
;-----------------------------------------------------------------------------------------
vfww   = data_dv * (e_inf^(3./2.) / e)  ; => [eV^(1/2) cm^(-2) s^(-1)]

pvfwxx = cos_phi^2 * cos2_th          * vfww
pvfwyy = sin_phi^2 * cos2_th          * vfww
pvfwzz = sin_th^2                     * vfww
pvfwxy = cos_phi * sin_phi * cos2_th  * vfww
pvfwxz = cos_phi * cthsth             * vfww
pvfwyz = sin_phi * cthsth             * vfww

vfxx   = TOTAL(pvfwxx,/NAN)
vfyy   = TOTAL(pvfwyy,/NAN)
vfzz   = TOTAL(pvfwzz,/NAN)
vfxy   = TOTAL(pvfwxy,/NAN)
vfxz   = TOTAL(pvfwxz,/NAN)
vfyz   = TOTAL(pvfwyz,/NAN)
vftens = [vfxx,vfyy,vfzz,vfxy,vfxz,vfyz]*(SQRT(2/mass)*1e5)  ; => [cm^(-1) s^(-2)]
; => Note:  The factor of 1e10 is to change [km^(-2)] in mass to [cm^(-2)]
mom.MFTENS = vftens*mass/1e10  ; => [eV cm^(-3)]
;-----------------------------------------------------------------------------------------
skipsums:        ; enter here to calculate remainder of items.
;-----------------------------------------------------------------------------------------
IF (SIZE(add_moment,/TYPE) EQ 8) THEN BEGIN
   mom.DENSITY = mom.DENSITY + add_moment.DENSITY
   mom.FLUX    = mom.FLUX    + add_moment.FLUX
   mom.MFTENS  = mom.MFTENS  + add_moment.MFTENS 
ENDIF
IF KEYWORD_SET(mom_only) THEN RETURN,mom

mass   = mom.MASS
map3x3 = [[0,3,4],[3,1,5],[4,5,2]]
mapt   = [0,4,8,1,2,5]
;-----------------------------------------------------------------------------------------
; => mf3x3  = ptens[map3x3]   [eV cm^(-3)]
;-----------------------------------------------------------------------------------------
mom.VELOCITY = mom.FLUX/mom.DENSITY/1e5   ; => [km/s]
mf3x3        = mom.MFTENS[map3x3] 
pt3x3        = mf3x3 - (mom.VELOCITY # mom.FLUX)*mass/1e5
mom.PTENS    = pt3x3[mapt]                ; => [eV cm^(-3)]
t3x3         = pt3x3/mom.DENSITY          ; => [eV]
; => Define the scalar temperature as the trace of temperature tensor divided by 3 [eV]
mom.AVGTEMP  = (t3x3[0] + t3x3[4] + t3x3[8] )/3.
; => Define the thermal speed [km/s]
mom.VTHERMAL = SQRT(2.*mom.AVGTEMP/mass)
; => Only the symmetric elements of temperature tensor
tempt        = t3x3[mapt]      ; => not used...

gtemp        = WHERE(FINITE(t3x3),gt33,COMPLEMENT=btemp,NCOMPLEMENT=bt33)
IF (bt33 GT 0) THEN BEGIN   ; => Non-Finite points break TRIQL.PRO
  bind = ARRAY_INDICES(t3x3,btemp)
  t3x3[bind[0,*],bind[1,*]] = 0e0
ENDIF
IF (bt33 EQ 9) THEN mom.DENSITY = f
good         = FINITE(mom.DENSITY)
IF (NOT good OR mom.DENSITY LE 0) THEN RETURN,mom
t3evec       = t3x3
;-----------------------------------------------------------------------------------------
; -> If t3evec = [NxN]-Element real symmetric matrix then:
; -> t3    = N-Element vector of the diagonal elements of t3evec
; -> dummy = N-Element vector of the off-diagonal " " 
;-----------------------------------------------------------------------------------------
TRIRED,t3evec,t3,dummy
;-----------------------------------------------------------------------------------------
; -> t3     => Now goes to the eigenvalues of the input matrix, t3
; -> dummy  => gets destroyed by TRIQL.PRO
; -> t3evec => Now becomes the N-Eigenvectors of t3
;-----------------------------------------------------------------------------------------
TRIQL,t3,dummy,t3evec

IF (N_ELEMENTS(magdir) NE 3L) THEN magdir = [-1.,1.,0.]
magfn = magdir/(SQRT(TOTAL(magdir^2,/NAN)))
s     = SORT(t3)
IF (t3[s[1]] LT .5*(t3[s[0]] + t3[s[2]])) THEN num = s[2] ELSE num = s[0]

shft   = ([-1,1,0])[num] 
t3     = SHIFT(t3,shft)
t3evec = SHIFT(t3evec,0,shft)
dot    = TOTAL(magfn*t3evec[*,2],/NAN)
bmag   = SQRT(TOTAL(mom.MAGF^2,/NAN))
IF (FINITE(bmag)) THEN BEGIN
  magfn        = mom.MAGF/bmag
  b_dot_s      = TOTAL((magfn # [1,1,1])*t3evec,1,/NAN)
  dummy        = MAX(ABS(b_dot_s),num,/NAN)
  mrot         = rot_mat(mom.MAGF,mom.VELOCITY)
  magt3x3      = INVERT(mrot) # (t3x3 # mrot)
  mom.MAGT3    = magt3x3[[0,4,8]]
  ;---------------------------------------------------------------------------------------
  ; =>mom.PTENS = [perp1,perp2,para,xy,xz,yz],  mom.MAGT3 = [perp1,perp2,para]
  ;
  ; => (INVERT(mrot) # (t3x3 # mrot))[0,4,8,1,2,5] = same as 
  ;                       mom.PTENS/mom.DENSITY in mom3d.pro
  ;---------------------------------------------------------------------------------------
  dot          = TOTAL(magfn*t3evec[*,2],/NAN)
  mom.SYMM_ANG = ACOS(ABS(dot))*!RADEG
ENDIF

IF (dot LT 0) THEN t3evec = -t3evec
mom.SYMM = t3evec[*,2]
magdir   = mom.SYMM
   
xyz_to_polar,mom.SYMM,THETA=symm_theta,PHI=symm_phi,/PH_0_360
mom.SYMM_THETA = symm_theta
mom.SYMM_PHI   = symm_phi
mom.T3         = t3
valid          = 1
mom.VALID      = 1

RETURN,mom
END
