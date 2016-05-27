;+
;*****************************************************************************************
;
;  FUNCTION :   moments_3d_omega_weights.pro
;  PURPOSE  :   Determines the detector solid angles given an input of spherical
;                 coordinate angles.
;
;  CALLED BY:   
;               moments_3du.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               TH     :  Polar angle (deg) determined by get_?? structure tag THETA
;               PH     :  Azimuthal " " PHI
;               DTH    :  Polar angular resolution (deg) " " DTHETA
;               DPH    :  Azimuthal " " DPHI
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               ORDER  :  Obselete usage for this specific routine
;
;   CHANGED:  1)  Jim altered something                           [04/21/2011   v1.0.?]
;             2)  Re-wrote and cleaned up                         [06/14/2011   v1.1.0]
;             3)  Fixed typo in man page                          [08/16/2011   v1.1.1]
;
;   NOTES:      
;               1)  The polar angles define zero in the XY-Plane, not at the Z-axis
;
;   CREATED:  ??/??/????
;   CREATED BY:  Jim McTiernan
;    LAST MODIFIED:  08/16/2011   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION moments_3d_omega_weights,th,ph,dth,dph,ORDER=order  ;, tgeom   inputs may be up to 3 dimensions

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
dim    = SIZE(th,/DIMENSIONS)
dmph   = SIZE(ph,/DIMENSIONS)
dmdth  = SIZE(dth,/DIMENSIONS)
dmdph  = SIZE(dph,/DIMENSIONS)
test0  = (ARRAY_EQUAL(dim,dmph) EQ 0) OR (ARRAY_EQUAL(dim,dmdth) EQ 0) OR $
         (ARRAY_EQUAL(dim,dmdph) EQ 0)
IF (test0) THEN MESSAGE,'Bad Input'
omega  = DBLARR([13,dim])
;-----------------------------------------------------------------------------------------
; => Angular moment integrals
;-----------------------------------------------------------------------------------------
ph2    = ph + dph/2       ; => upper bound on azimuthal angle
ph1    = ph - dph/2       ; => lower " "
th2    = th + dth/2       ; => upper bound on polar angle
th1    = th - dth/2       ; => lower " "
; => Define the Sine/Cosine of each
sth1   = SIN(th1*!DPI/18d1)
cth1   = COS(th1*!DPI/18d1)
sph1   = SIN(ph1*!DPI/18d1)
cph1   = COS(ph1*!DPI/18d1)
sth2   = SIN(th2*!DPI/18d1)
cth2   = COS(th2*!DPI/18d1)
sph2   = SIN(ph2*!DPI/18d1)
cph2   = COS(ph2*!DPI/18d1)
; => Define various permutations of each
ip     = dph*!DPI/18d1
ict    =  sth2 - sth1
icp    =  sph2 - sph1
isp    = -cph2 + cph1
is2p   = dph/2d0*!DPI/18d1 - sph2*cph2/2d0 + sph1*cph1/2d0
ic2p   = dph/2d0*!DPI/18d1 + sph2*cph2/2d0 - sph1*cph1/2d0
ic2t   = dth/2d0*!DPI/18d1 + sth2*cth2/2d0 - sth1*cth1/2d0
ic3t   = sth2 - sth1 - (sth2^3 - sth1^3)/3d0
ictst  = (sth2^2 - sth1^2)/2d0
icts2t = (sth2^3 - sth1^3)/3d0
ic2tst = (-cth2^3 + cth1^3)/3d0
icpsp  = (sph2^2 - sph1^2)/2d0
; => Define the solid angle
omega[0,*,*,*]  = ict    * ip
omega[1,*,*,*]  = ic2t   * icp
omega[2,*,*,*]  = ic2t   * isp
omega[3,*,*,*]  = ictst  * ip
omega[4,*,*,*]  = ic3t   * ic2p
omega[5,*,*,*]  = ic3t   * is2p
omega[6,*,*,*]  = icts2t * ip
omega[7,*,*,*]  = ic3t   * icpsp
omega[8,*,*,*]  = ic2tst * icp
omega[9,*,*,*]  = ic2tst * isp
omega[10,*,*,*] = omega[1,*,*,*]
omega[11,*,*,*] = omega[2,*,*,*]
omega[12,*,*,*] = omega[3,*,*,*]

;-----------------------------------------------------------------------------------------
; => Return result to user
;-----------------------------------------------------------------------------------------
RETURN,omega
END
