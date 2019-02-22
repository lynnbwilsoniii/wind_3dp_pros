;+
;*****************************************************************************************
;
;  FUNCTION :  eulerf.pro
;  PURPOSE  :  Given three angles, this program will return the Euler matrix for those
;                input angles [Note: Make sure to define the units using the keywords].
;                The format is specific to match the format given in the Fränz paper
;                cited below.
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               OMEGA  :  First rotation angle about original z-axis
;               THETA  :  Second rotation angle about X'-Axis
;               PHI    :  Third rotation angle about Z"-Axix
;
;  EXAMPLES:
;
;  KEYWORDS:
;               DEG : If set, tells program the angles are in degrees (default)
;               RAD : If set, tells program the angles are in radians
;
;   CHANGED:  1)  Updated man page                               [09/15/2009   v1.0.1]
;
;  NOTES:  
;               See coord_trans_documentation.txt for explanation of each 
;                 coordinate system.  Calculations come from the paper:
;
;                  M. Fränz and D. Harper, "Heliospheric Coordinate Systems," 
;                    Planetary and Space Science Vol. 50, 217-233, (2002).
;
;   CREATED:  07/22/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/15/2009   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION eulerf,Omega,Theta,Phi,DEG=deg,RAD=rad

;*****************************************************************************************
; -Convert angles to radians
;*****************************************************************************************
IF KEYWORD_SET(rad) THEN BEGIN
  ome = Omega
  the = Theta
  phh = Phi
ENDIF ELSE BEGIN
  IF KEYWORD_SET(deg) THEN BEGIN
    ome = Omega*!DTOR
    the = Theta*!DTOR
    phh = Phi*!DTOR
  ENDIF ELSE BEGIN
    print,'Program assumed you sent in angles in degrees!'
    ome = Omega*!DTOR
    the = Theta*!DTOR
    phh = Phi*!DTOR    
  ENDELSE
ENDELSE
;*****************************************************************************************
; -Define cosine and sine of each angle
;*****************************************************************************************
come = COS(ome)
cthe = COS(the)
cphi = COS(phh)
some = SIN(ome)
sthe = SIN(the)
sphi = SIN(phh)

myeuler = [[    cphi*come - sphi*some*cthe    ,  cphi*some + sphi*come*cthe  , sphi*sthe ],$
           [-1d0*(sphi*come + cphi*some*cthe) , -sphi*some + cphi*come*cthe  , cphi*sthe ],$
           [            some*sthe             ,        -1d0*come*sthe        ,    cthe   ]]

;myeuler = [[come*cthe - some*sthe*cphi   ,  come*sthe + some*cthe*cphi, some*sphi ],$
;           [-(some*cthe + come*sthe*cphi), -some*sthe + come*cthe*cphi, come*sphi ],$
;           [         sthe*sphi           ,         -cthe*sphi         ,   cphi    ] ]

RETURN, myeuler
END