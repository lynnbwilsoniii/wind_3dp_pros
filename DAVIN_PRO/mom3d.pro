;+
;*****************************************************************************************
;
;  FUNCTION :   mom3d.pro
;  PURPOSE  :   Calculates the 3-Dimensional particle distribution functions from the 
;                 first 4 moments of the distribution function.
;
;              If magnetic field vector provided, then:
;               => mom.PTENS = [perp1,perp2,para,xy,xz,yz],    [eV cm^(-3)]
;               => mom.MAGT3 = [perp1,perp2,para],             [eV]
;               => mom.QVEC  = [perp1,perp2,para],             [eV cm^-3 km/s]
;               => mom.RTENS =     [eV^(3/2) cm^(-3)]
;              If magnetic field vector is NOT provided, then:
;               => mom.PTENS = [xx,yy,zz,xy,xz,yz] [GSE],    [eV cm^(-3)]
;               => etc.
;
;  CALLED BY:   NA
;
;  CALLS:  
;               mom_sum.pro
;               mom_translate.pro
;               rot_mat.pro
;               mom_rotate.pro
;
;  REQUIRES:  NA
;
;  INPUT:  
;               DATA    : [Structure] A 3D data structure returned by the programs
;                           get_?? [?? = el, eh, pl, ph, elb, etc.]
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               SC_POT  :  A scalar defining an estimate of the spacecraft potential 
;                           [eV]
;               MAGDIR  :  A named variable which can either define the B-field
;                           direction or be returned
;               PARDENS :  A named variable to be returned to a higher level program 
;                           which is calculated in mom_sum.pro
;               SUMTENS :  A structure returned by mom_sum.pro
;               ERANGE  :  Set to a 2-Element array specifying the first and last
;                           elements of the energy bins desired to be used for
;                           calculating the moments
;               FORMAT  :  A dummy structure format used for preventing conflicting
;                           data structures
;               VALID   :  A returned varialbe which determines whether data 
;                           structures are useful or not
;
;   CHANGED:  1)  Davin Larson created                     [??/??/????   v1.0.0]
;             2)  Did some minor "clean up"                [04/06/2008   v1.0.1]
;             3)  Added comments regarding pressure tensor [09/22/2008   v1.0.1]
;             4)  Fixed comments regarding tensors         [01/28/2009   v1.0.2]
;             5)  Re-wrote and cleaned up                  [04/13/2009   v1.1.0]
;             6)  Updated man page                         [06/17/2009   v1.1.1]
;             7)  Fixed note on charge conversion constant [06/19/2009   v1.1.2]
;             8)  Fixed keyword description of ERANGE      [07/20/2009   v1.1.3]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  07/20/2009   v1.1.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION mom3d ,data,        $
         SC_POT  = sc_pot,   $
         MAGDIR  = magdir,   $
         PARDENS = pardens,  $
         SUMTENS = sum,      $
         ERANGE  = er,       $
         FORMAT  = momformat,$
         VALID   = valid

;-----------------------------------------------------------------------------------------
; -Create a dummy structure for error handling
;-----------------------------------------------------------------------------------------
f   = !VALUES.F_NAN
f3  = [f,f,f]
f6  = [f,f,f,f,f,f]
f10 = REPLICATE(f,10)
d   = !VALUES.D_NAN
dum = CREATE_STRUCT('TIME',d,'SC_POT',f,'MAGF',f3,'DENSITY',f,'VELOCITY',f3,  $
                    'AVGTEMP',f,'VTHERMAL',f,'PTENS',f6,'PTOT',f,'QTENS',f10, $
                    'QVEC',f3,'SKEWNESS',f,'RTENS',REPLICATE(f,15),'RTOT',f,  $
                    'EXCESS',f,'MAGT3',f3,'TRAT',f,'T3',f3,'SYMM',f3,         $
                    'SYMM_ANG',f,'ERANGE',[f,f],'VALID',0)
;-----------------------------------------------------------------------------------------
; -> BE CAREFUL of defining LONGs in place of INTEGERS (and other formats)
;-----------------------------------------------------------------------------------------
IF (SIZE(momformat,/TYPE) NE 8L) THEN BEGIN
  mom = dum
ENDIF ELSE BEGIN
  ntags = N_TAGS(momformat)
  ndum  = N_TAGS(dum)
  IF (ndum NE ntags) THEN BEGIN
    mom = dum
  ENDIF ELSE BEGIN
    test = BYTARR(ntags)
    FOR j=0L, ntags - 1L DO BEGIN
      test[j] = ARRAY_EQUAL(momformat.(j),dum.(j),/NO_TYPECONV)
    ENDFOR
    btest = WHERE(test EQ 0b,bt)
    IF (bt GT 0L) THEN mom = dum ELSE mom = momformat
  ENDELSE
ENDELSE

mom.VALID = 0
valid     = 0

IF (N_PARAMS() EQ 1) THEN BEGIN
  sum      = mom_sum(data,SC_POT=sc_pot,PARDENS=pardens,ERANGE=er)
  mom.TIME = data.TIME
endif
IF (SIZE(sum,/TYPE) NE 8L) THEN RETURN,mom

mass   = sum.MASS     ; -Particle mass [eV/(km/sec)^2]
charge = sum.CHARGE   ; -Particle charge [unitless]
;-----------------------------------------------------------------------------------------
; -Note:  
;  0.010438871 eV/(km/sec)^2 = ([938.27231 x 10^(6) eV/c^2])/([2.9979 x 10^(5) km/s])^2
;
; => Units of proton masses in eV/(km/sec)^2
;-----------------------------------------------------------------------------------------
nnorm      = SQRT(ABS(2*charge/mass))  ; -[(km/s) eV^(-1/2)]
mom.MAGF   = sum.MAGF                  ; -[nT]
mom.SC_POT = sum.SC_POT                ; -[eV]
mom.ERANGE = sum.ERANGE                ; -[eV]
;-----------------------------------------------------------------------------------------
; -Calculate the density [# cm^(-3)]
;-----------------------------------------------------------------------------------------
mom.DENSITY = sum.N/nnorm
;-----------------------------------------------------------------------------------------
; -Calculate the velocity (km/s)
;-----------------------------------------------------------------------------------------
mom.VELOCITY = sum.NV/mom.DENSITY
;-----------------------------------------------------------------------------------------
; -Calculate the velocity flux
;-----------------------------------------------------------------------------------------
sumt  = mom_translate(sum)
ptens = mass*nnorm*sumt.NVV  ; -Pressure Tensor
pt3x3 = ptens[sumt.MAP_R2]   ; -[eV cm^(-3)] => Pressure or Energy Density
t3x3  = pt3x3/mom.DENSITY    ; -[eV] => Temperature = <Kinetic Energy> 
;-----------------------------------------------------------------------------------------
; -Calculate the average temp ([eV] => TRACE/3) and thermal velocity
;-----------------------------------------------------------------------------------------
mom.AVGTEMP  = (t3x3[0] + t3x3[4] + t3x3[8])/3.   ; -[eV]
mom.VTHERMAL = SQRT(2.*mom.AVGTEMP/mass)          ; -[km/s]
sigvth       = mom.VTHERMAL/(SQRT(2.))
;-----------------------------------------------------------------------------------------
; -Calculate the pressure ([eV cm^(-3)] => TRACE/3)
;-----------------------------------------------------------------------------------------
mom.PTOT = (pt3x3[0] + pt3x3[4] + pt3x3[8])/3.

gdens    = WHERE(FINITE(mom.DENSITY),gd)
IF (gd EQ 0L OR mom.DENSITY LE 0.) THEN RETURN,mom
;-----------------------------------------------------------------------------------------
; -> If t3evec = [NxN]-Element real symmetric matrix then:
; -> t3    = N-Element vector of the diagonal elements of t3evec
; -> dummy = N-Element vector of the off-diagonal " " 
;-----------------------------------------------------------------------------------------
t3evec = t3x3

TRIRED,t3evec,t3,dummy
;-----------------------------------------------------------------------------------------
; -> t3     => Now goes to the eigenvalues of the input matrix, t3
; -> dummy  => gets destroyed by TRIQL.PRO
; -> t3evec => Now becomes the N-Eigenvectors of t3
;-----------------------------------------------------------------------------------------
TRIQL ,t3,dummy,t3evec
;-----------------------------------------------------------------------------------------
; -Determine temps, press., etc. w/ respect to B-field
;-----------------------------------------------------------------------------------------
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
  magfn        = mom.MAGF/bmag  ; -normalized B-field
  b_dot_s      = TOTAL((magfn # [1,1,1])*t3evec ,1,/NAN)
  dummy        = MAX(ABS(b_dot_s),num,/NAN)
  ;---------------------------------------------------------------------------------------
  ; => Find an arbitrary rotation matrix for [FA Coords.]
  ;---------------------------------------------------------------------------------------
  mrot         = rot_mat(mom.MAGF)
  trsum        = mom_rotate(sumt,mrot)       ; -Rotate data [FA Coords.]
  mom.PTENS    = mass*nnorm*trsum.NVV        ; -Pressure Tensor [perp1,perp2,para,xy,xz,yz]
  mom.MAGT3    = mom.PTENS[0:2]/mom.DENSITY  ; -[perp1,perp2,para,xy,xz,yz] Temperatures [eV]
  ;---------------------------------------------------------------------------------------
  ; =>mom.PTENS = [perp1,perp2,para,xy,xz,yz],  mom.MAGT3 = [xx,yy,zz]
  ;
  ; => (INVERT(mrot) # (t3x3 # mrot))[0,4,8,1,2,5] = same as 
  ;                       mom.PTENS/mom.DENSITY density above
  ;---------------------------------------------------------------------------------------
  mom.TRAT     = mom.MAGT3[2]*2/(mom.MAGT3[0] + mom.MAGT3[1])  ; => T_para/T_perp
  dot          = TOTAL((magfn*t3evec[*,2]),/NAN)
  mom.SYMM_ANG = ACOS(ABS(dot))*!RADEG
  mom.QTENS    = (mass*nnorm^2)*trsum.NVVV   ; -Heat Flux Tensor  [eV cm^-3 km/s]
  i3           = [[0,4,8],[9,13,17],[18,22,26]]
  mom.QVEC     = TOTAL((trsum.NVVV[trsum.MAP_R3])[i3],1,/NAN); -Heat Flux Vector
  ;---------------------------------------------------------------------------------------
  ; -Statistics stuff...
  ;---------------------------------------------------------------------------------------
  mom.SKEWNESS = (mom.QVEC[2]/mass/mom.DENSITY)/sigvth^3   ; => [eV^(-3) (km/s)^(-1)]
  mom.RTENS    = (mass*mass)*(nnorm^3)*trsum.NVVVV         ; => [eV^(3/2) cm^-3 km/s]
  mom.RTOT     = TOTAL(mom.RTENS[0:2],/NAN) + 2.*TOTAL(mom.RTENS[3:5],/NAN) 
  mom.EXCESS   = (mom.RTOT/(mass^2)/mom.DENSITY/15)/sigvth^4
ENDIF
IF (dot LT 0) THEN t3evec = -t3evec
mom.SYMM  = t3evec[*,2]
magdir    = mom.SYMM
mom.T3    = t3           ; -Eigenvalue temps [eV]
mom.VALID = 1
VALID     = 1
RETURN,mom
END
