;+
;*****************************************************************************************
;
;  FUNCTION :   rh_eq_solve.pro
;  PURPOSE  :   Solves the Rankine-Hugoniot Equations for the shock normal vector
;                 and shock normal speed in the normal direction.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               generate_nvec.pro
;               generate_rh_eq.pro
;               merit_function.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DENS   :  [N,2]-Element array of densities [cm^(-3)]
;               MAGF   :  [N,3,2]-Element array of B-field vectors [nT]
;               VSW    :  [N,3,2]-Element array of solar wind velocity vectors [km/s]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               NDAT   :  Scalar value defining the number of angles to use to
;                           generate the dummy array of possible normal vectors
;                           [Default = 100L]
;               TEMPK  :  [N,2]-Element array of temperatures (eV)
;
;   CHANGED:  1)  Continued work on writing the routine          [04/27/2011   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  04/26/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/27/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_eq_solve,dens,magf,vsw,NDAT=ndat,TEMPK=tempk

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
muo        = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
polyti     = 5d0/3d0           ; => Polytrope index
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN RETURN,0
n_i        = REFORM(dens)
bo         = REFORM(magf)
vo         = REFORM(vsw)
szd        = SIZE(n_i,/DIMENSIONS)
szb        = SIZE(bo,/DIMENSIONS)
szv        = SIZE(vo,/DIMENSIONS)
badd       = (szd[1] NE 2)
badb       = ((szb[1] NE 3) OR (szb[2] NE 2))
badv       = ((szv[1] NE 3) OR (szv[2] NE 2))
badn       = (szd[0] NE szb[0]) OR (szd[0] NE szv[0]) OR (szb[0] NE szv[0])
bad        = badd OR badb OR badv OR badn
IF (bad) THEN RETURN,0
; => Now we know we have the right format
nd         = szd[0]       ; => # of data points on either side of shock
IF ~KEYWORD_SET(ndat) THEN nn = 100L ELSE nn = LONG(ndat[0])
;-----------------------------------------------------------------------------------------
; => Find possible normal vectors
;-----------------------------------------------------------------------------------------
poss_norm = generate_nvec(nn)  ; => possible shock normal vectors
; [phi[j],theta[k],3L]

;-----------------------------------------------------------------------------------------
; => Generate the RH Equations
;-----------------------------------------------------------------------------------------
rh_eqs  = generate_rh_eq(n_i,bo,vo,poss_norm,TEMPK=tempk)
IF (SIZE(rh_eqs,/TYPE) NE 8) THEN RETURN,0      ; => Must be a structure

rheqs   = rh_eqs.EQS
tags    = ['EQ2','EQ3','EQ4','EQ5','EQ6']
eqstruc = CREATE_STRUCT(tags,rheqs.EQ2,rheqs.EQ3,rheqs.EQ4,rheqs.EQ5,rheqs.EQ6)
rhstd   = rh_eqs.STDEVS
tags    = 'STDEV_'+['EQ2','EQ3','EQ4','EQ5','EQ6']
stdstru = CREATE_STRUCT(tags,rhstd.STDEV_EQ2,rhstd.STDEV_EQ3,rhstd.STDEV_EQ4,$
                             rhstd.STDEV_EQ5,rhstd.STDEV_EQ6)
;-----------------------------------------------------------------------------------------
; => Generate the merit functions
;-----------------------------------------------------------------------------------------
rh_mer  = merit_function(eqstruc,stdstru)


STOP

solns = 0
RETURN,solns
END