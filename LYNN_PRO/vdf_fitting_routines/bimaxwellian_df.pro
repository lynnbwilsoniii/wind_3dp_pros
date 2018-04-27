;+
;*****************************************************************************************
;
;  FUNCTION :   bimaxwellian_df.pro
;  PURPOSE  :   Creates a Bi-Maxwellian Distribution Function (Bi-MDF) from an user
;                 defined thermal speed, density, drift speeds, and array of
;                 velocities to define the Bi-MDF at.  The only note to be careful of
;                 is to make sure the thermal speed and array of velocities are
;                 in the same units.
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
;               DENS        :  Scalar number density (#/length^3)
;               VTHPAR      :  Scalar parallel thermal speed (length/time)
;               VTHPER      :  Scalar perpendicular thermal speed (length/time)
;
;  EXAMPLES:    
;               dens   = 10d0   ; => 10 particles per cm cubed
;               vthpar = 5d2    ; => 500 km/s parallel thermal speed
;               vthper = 6d2    ; => 600 km/s perpendicular thermal speed
;               vdpar  = 1d2    ; => 100 km/s parallel drift speed
;               vdper  = 0d0    ; =>   0 km/s perpendicular drift speed
;               vmax   = 25d2   ; => Max. velocities = 2500 km/s
;               bimdf  = bimaxwellian_df(dens,vthpar,vthper,$
;                                        VDRIFT_PAR=vdpar,VDRIFT_PER=vdper,VMAX=vmax)
;
;  KEYWORDS:    
;               VDRIFT_PAR  :  Scalar parallel drift speed
;               VDRIFT_PER  :  Scalar perpendicular drift speed
;               VMAX        :  Scalar value used as maximum velocity used when creating
;                                a dummy array of velocity values for the Bi-MDF,
;                                which range from [-VMAX,+VMAX]
;               VARR        :  Array of velocity (length/time) values user wishes to use
;                                to create the Bi-MDF
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Units of returned function are: 
;                     [density units]/[thermal speed units]^3
;               2)  Parallel and perpendicular are defined with respect to the magnetic
;                     field direction
;               3)  Default velocities used if neither VMAX nor VARR are set is
;                     six times the larger thermal speed
;
;   CREATED:  06/06/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/06/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION bimaxwellian_df,dens,vthpar,vthper,VDRIFT_PAR=vdpar,VDRIFT_PER=vdper,$
                         VMAX=vmax,VARR=varr

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
kB     = 1.380658d-23      ; -Boltzmann Constant (J/K)
nn     = 1000L
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 3) THEN RETURN,0d0
no     = dens[0]
vtha   = vthpar[0]
vthe   = vthper[0]
; => factor in front of Maxwellian exponent
maxfac = no[0]/(!DPI^(3d0/2d0)*vtha[0]*vthe[0]^2)

IF ~KEYWORD_SET(vdpar) THEN vdpa = 0d0 ELSE vdpa = DOUBLE(vdpar[0])
IF ~KEYWORD_SET(vdper) THEN vdpe = 0d0 ELSE vdpe = DOUBLE(vdper[0])

IF ~KEYWORD_SET(vmax)  THEN vmx  = 0   ELSE vmx  = DOUBLE(vmax[0])
IF ~KEYWORD_SET(varr)  THEN var  = 0   ELSE var  = DOUBLE(varr)

IF (~KEYWORD_SET(vmx[0]) AND ~KEYWORD_SET(var[0])) THEN BEGIN
  vmx = 6d0*(vtha[0] > vthe[0])
  var = DINDGEN(nn)*(2d0*vmx[0])/(nn - 1L) - vmx[0]
ENDIF ELSE BEGIN
  IF ~KEYWORD_SET(var) THEN var = DINDGEN(nn)*(2d0*vmx[0])/(nn - 1L) - vmx[0]
ENDELSE
varr = var
;-----------------------------------------------------------------------------------------
; => Define Bi-Maxwellian Distribution
;-----------------------------------------------------------------------------------------
evpar  = ((var - vdpa[0])/vtha[0])^2
evper  = ((var - vdpe[0])/vthe[0])^2
nm     = N_ELEMENTS(var)
g_dist = DBLARR(nm,nm)
FOR j=0L, nm - 1L DO BEGIN
  temp        = maxfac[0]*EXP(-1d0*(evpar + evper[j]))
  g_dist[*,j] = temp
ENDFOR

;-----------------------------------------------------------------------------------------
; => Return distribution to user
;-----------------------------------------------------------------------------------------
RETURN,g_dist
END