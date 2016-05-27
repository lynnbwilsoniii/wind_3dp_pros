;+
;*****************************************************************************************
;
;  FUNCTION :   eulermat.pro
;  PURPOSE  :   Given three angles, this program will return the Euler matrix for those
;                 input angles.  The rotation convention is the following:
;                   1)  rotation by WW about original Z-Axis to new K' coordinates
;                   2)  rotation by TT about X'-Axis to new K" coordinates
;                   3)  rotation by PP about Z"-Axis to new K''' coordinates
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               PSI  :  Scalar rotation angle about the Z"-Axis
;               PHI  :  Scalar rotation angle about the Z-Axis
;               THE  :  Scalar rotation angle about the X'-Axis
;
;  EXAMPLES:    
;               ;++++++++++++++++++++++++++++++++++++++
;               ; => Rotate 30 degrees about the Z-Axis
;               ;++++++++++++++++++++++++++++++++++++++
;               angle = 3d1
;               zrot  = eulermat(0d0,angle,0d0,/DEG)
;               ;++++++++++++++++++++++++++++++++++++++
;               ; => Rotate 30 degrees about the X-Axis
;               ;++++++++++++++++++++++++++++++++++++++
;               angle = 3d1
;               xrot  = eulermat(0d0,0d0,angle,/DEG)
;               ;++++++++++++++++++++++++++++++++++++++
;               ; => Rotate 30 degrees about the Y-Axis
;               ;++++++++++++++++++++++++++++++++++++++
;               angle = 3d1
;               yrot  = eulermat(0d0,-9d1,0d0,/DEG) ## eulermat(0d0,9d1,angle,/DEG)
;
;  KEYWORDS:    
;               DEG  :  If set, angles are assumed to be in degrees [Default]
;               RAD  :  If set, angles are assumed to be in radians
;
;   CHANGED:  1)  Fixed up man page                                 [05/10/2007   v1.0.2]
;             2)  Added keyword:  DEG                               [05/11/2007   v1.0.3]
;             3)  Added keyword:  RAD                               [05/11/2007   v1.0.4]
;             4)  Fixed a typo in output message                    [09/23/2008   v1.0.5]
;             5)  Cleaned up                                        [02/15/2011   v1.1.0]
;
;   NOTES:      
;               1)  Default units for angles are degrees
;
;   CREATED:  04/30/2007
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/15/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;FUNCTION eulermat,pp2,ww2,tt2,DEG=deg,RAD=rad
FUNCTION eulermat,psi,phi,the,DEG=deg,RAD=rad

;-----------------------------------------------------------------------------------------
; => Convert angles to radians
;-----------------------------------------------------------------------------------------
dtor = !DPI/18d1
IF KEYWORD_SET(rad) THEN BEGIN
  ps = psi
  ph = phi
  th = the
ENDIF ELSE BEGIN
  ; => Assumes input angles are in degrees
  ps = psi*dtor
  ph = phi*dtor
  th = the*dtor
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define cosine and sine of each angle
;-----------------------------------------------------------------------------------------
cps = COS(ps)
cph = COS(ph)
cth = COS(th)
sps = SIN(ps)
sph = SIN(ph)
sth = SIN(th)
;-----------------------------------------------------------------------------------------
; => Define Euler rotation matrix
;-----------------------------------------------------------------------------------------
myeuler = [[cps*cph - sps*sph*cth   ,  cps*sph + sps*cph*cth, sps*sth ],$
           [-(sps*cph + cps*sph*cth), -sps*sph + cps*cph*cth, cps*sth ],$
           [       sph*sth          ,        -cph*sth       , cth     ]  ]

RETURN, myeuler
END