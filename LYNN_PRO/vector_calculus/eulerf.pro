;+
;*****************************************************************************************
;
;  FUNCTION :  eulerf.pro
;  PURPOSE  :  Given three angles, this program will return the Euler matrix for those
;                input angles [Note: Make sure to define the units using the keywords].
;                The format is specific to match the format given in the Fränz paper
;                cited below.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               OMEGA  :  Scalar [numeric] defining the first rotation angle about original Z-axis
;               THETA  :  Scalar [numeric] defining the second rotation angle about X'-Axis
;               PHI    :  Scalar [numeric] defining the third rotation angle about Z"-Axix
;
;  EXAMPLES:    
;               [calling sequence]
;               rmat = eulerf(Omega,Theta,Phi [,/DEG] [,/RAD])
;
;  KEYWORDS:    
;               DEG    :  If set, tells program the angles are in degrees
;                           [Default = TRUE]
;               RAD    :  If set, tells program the angles are in radians
;                           [Default = FALSE]
;
;   CHANGED:  1)  Updated man page
;                                                                   [09/15/2009   v1.0.1]
;             2)  Cleaned up
;                                                                   [06/12/2025   v1.0.2]
;
;   NOTES:      
;               0)  There is no error handling in this routine to increase speed so
;                     user beware
;
;  REFERENCES:  
;               0)  M. Fränz and D. Harper, "Heliospheric Coordinate Systems," 
;                    Planetary and Space Science Vol. 50, 217-233, (2002).
;               1)  2017 Erratum to Fränz and Harper [2002]
;
;   CREATED:  07/22/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/12/2025   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION eulerf,Omega,Theta,Phi,DEG=deg,RAD=rad

;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Ensure angles are in radians
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(rad) THEN BEGIN
  ;;  Angles are already in radians
  ome            = Omega
  the            = Theta
  phh            = Phi
ENDIF ELSE BEGIN
  ;;  Angles are explicitly in degrees or routine will assume as much
  IF KEYWORD_SET(deg) THEN BEGIN
    ome            = Omega*!DTOR
    the            = Theta*!DTOR
    phh            = Phi*!DTOR
  ENDIF ELSE BEGIN
    PRINT,'Program assumed you sent in angles in degrees!'
    ome            = Omega*!DTOR
    the            = Theta*!DTOR
    phh            = Phi*!DTOR
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define cosine and sine of each angle
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
come           = COS(ome)
cthe           = COS(the)
cphi           = COS(phh)
some           = SIN(ome)
sthe           = SIN(the)
sphi           = SIN(phh)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Construct Euler rotation matrix
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
myeuler        = [[    cphi*come - sphi*some*cthe    ,  cphi*some + sphi*come*cthe  , sphi*sthe ],$
                  [-1d0*(sphi*come + cphi*some*cthe) , -sphi*some + cphi*come*cthe  , cphi*sthe ],$
                  [            some*sthe             ,        -1d0*come*sthe        ,    cthe   ]]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to User
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN, myeuler
END