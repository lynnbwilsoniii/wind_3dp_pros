;+
;*****************************************************************************************
;
;  FUNCTION :   velocity.pro
;  PURPOSE  :   Returns the relativistic momentum (over mass = velocity) or
;                 nonrelativistic velocity given the energy and mass.  It can also return
;                 the energy if given a velocity. (~115.86 eV = ~1 Earth Radius/s)
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               NRG       :  N-Element array of energies in (eV)
;               MASS      :  Scalar mass [eV/(km/sec)^2] of particles
;
;  EXAMPLES:
;               **[Note:  electron mass = 5.6967578e-06 eV/(km/sec)^2]
;               IDL> masse  = 5.6967578e-06
;               IDL> print, velocity([100.,200.,3000.],masse)
;                      6242.8967       8380.2799       32501.020
;               IDL> print, velocity([100.,200.,3000.],masse,/TRUE)     ; -returns km/s
;                      6241.5435       8377.0076       32311.693
;               IDL> print, velocity([100.,200.,3000.],masse,/INVERSE)  ; -returns eV
;                    0.035094875      0.11393514       25.634768
;
;  KEYWORDS:  
;               TRUE_VELOCITY  :  If set, includes relativistic corrections to velocity 
;                                    calculations
;               MOMEN_ON_MASS  :  [Seems to be obselete]
;               ELECTRON       :  Set if you don't know the electron mass (program 
;                                    figures it out for you)
;               PROTON         :  Set if you don't know the proton mass (program 
;                                    figures it out for you)
;               INVERSE        :  Set if you are giving the program velocities (km/s)
;                                    and expecting energies (eV) in return
;
;   CHANGED:  1)  Davin Larson created                     [??/??/????   v1.0.0]
;             2)  Did some minor "clean up"                [07/10/2008   v1.0.1]
;             2)  Updated man page                         [02/15/2009   v1.0.2]
;             6)  Updated man page                         [06/17/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/17/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION velocity,nrg,mass,TRUE_VELOCITY=trv,MOMEN_ON_MASS=mom,      $
                           ELECTRON=el,PROTON=proton,INVERSE=inverse

;-----------------------------------------------------------------------------------------
; [mass] = eV/(km/sec)^2
;-----------------------------------------------------------------------------------------
c2   = 2.99792458d5^2   ; -speed of light squared (km^2/s^2)
IF KEYWORD_SET(el)     THEN mass = 0.51099906d6/c2
IF KEYWORD_SET(proton) THEN mass = 938.27231d6/c2
e0 = mass*c2
;-----------------------------------------------------------------------------------------
;3dp> print, e0
;       510999.99  -> rest mass energy of an electron in eV/c^2
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(trv) THEN BEGIN
   rgamma = (nrg + e0)/e0   
   vmag   = SQRT((1d0 - 1d0/rgamma^2)*c2)
   IF KEYWORD_SET(inverse) THEN message,'not working!'
   RETURN,vmag
ENDIF ELSE BEGIN ; -momentum over mass
  IF KEYWORD_SET(inverse) THEN BEGIN
    mvel = nrg
    RETURN, e0 * (SQRT(1d0 + (mvel^2/c2)) - 1d0)
  ENDIF
  vmag = SQRT(2d0*nrg/mass * (1d0 + nrg/(2d0*e0)))
  RETURN ,vmag
ENDELSE
END




  
