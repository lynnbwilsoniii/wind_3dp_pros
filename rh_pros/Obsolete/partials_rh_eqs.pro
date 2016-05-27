;+
;*****************************************************************************************
;
;  FUNCTION :   partials_rh_eqs.pro
;  PURPOSE  :   Generates the partial derivatives of a user specified Rankine-Hugoniot
;                 equation with respect to the shock normal azimuthal and poloidal
;                 angles and the shock normal speed in the SC-frame.
;
;  CALLED BY:   
;               rh_eqs.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               RHO    :  [2]-Element [up,down] array corresponding to the mass
;                           density [kg m^(-3)]
;               VSW    :  [3,2]-Element [up,down] array corresponding to the solar wind
;                           velocity vectors [SC-frame, m/s]
;               MAG    :  [3,2]-Element [up,down] array corresponding to the ambient
;                           magnetic field vectors [T]
;               PRE    :  [2]-Element [up,down] array corresponding to the total plasma
;                           thermal pressure [J m^(-3)]
;               PHI    :  Scalar value defining the azimuthal angle [rad] of the shock
;                           normal vector [0 < phi < 2 Pi]
;               THE    :  Scalar value defining the poloidal  angle [rad] of the shock
;                           normal vector [0 < the <   Pi]
;               VSH    :  Scalar shock normal velocity [m/s] in SC-frame
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               EQNUM  :  The equation number to call from the input list.
;                           [Default = 1]
;
;   CHANGED:  1)  Changed parameters so now use Eq. 7 from Koval and Szabo, [2008] 
;                   to determine the shock normal speed first from each data pair
;                                                                 [05/03/2011   v1.0.1]
;             2)  Fixed a typo in Eqs 5 and 6                     [06/21/2011   v1.0.2]
;
;   NOTES:      
;               1)  User should not call this routine
;
;  REFERENCES:  
;               1)  Vinas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               2)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               3)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;
;   CREATED:  05/01/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/21/2011   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION partials_rh_eqs, rho, vsw, mag, pre, phi, the, vsh, EQNUM=eqnum

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
K_eV       = 1.160474d4        ; => Conversion = degree Kelvin/eV
kB         = 1.3806504d-23     ; => Boltzmann Constant (J/K)
qq         = 1.60217733d-19    ; => Fundamental charge (C) [or = J/eV]
me         = 9.1093897d-31     ; => Electron mass [kg]
mp         = 1.6726231d-27     ; => Proton mass [kg]
mi         = (me + mp)         ; => Total mass [kg]
muo        = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
polyti     = 5d0/3d0           ; => Polytrope index
gfactor    = polyti[0]/(polyti[0] - 1d0)
IF ~KEYWORD_SET(eqnum) THEN eqn = 1 ELSE eqn = LONG(eqnum[0])

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
rho1       = rho[0]               ; => Upstream   mass density [kg m^(-3)]
rho2       = rho[1]               ; => Downstream mass density [kg m^(-3)]
bf1        = REFORM(mag[*,0])     ; => Upstream   magnetic field vector [Tesla]
bf2        = REFORM(mag[*,1])     ; => Downstream magnetic field vector [Tesla]
vel1       = REFORM(vsw[*,0])     ; => Upstream   solar wind velocity [m/s]
vel2       = REFORM(vsw[*,1])     ; => Downstream solar wind velocity [m/s]
press1     = pre[0]               ; => Upstream   thermal pressure [J m^(-3)]
press2     = pre[1]               ; => Downstream thermal pressure [J m^(-3)]

bmag1      = SQRT(bf1[0]^2 + bf1[1]^2 + bf1[2]^2)
bmag2      = SQRT(bf2[0]^2 + bf2[1]^2 + bf2[2]^2)
; => The following are the current initial guesses
ph         = phi[0]               ; => azimuthal angle
th         = the[0]               ; => poloidal  angle
vs         = vsh[0]               ; => shock normal speed [m/s] {SC-Frame}
; => define cosine and sine of angles
sph        = SIN(ph[0])
cph        = COS(ph[0])
sth        = SIN(th[0])
cth        = COS(th[0])
sph2       = sph[0]^2
cph2       = cph[0]^2
sth2       = sth[0]^2
cth2       = cth[0]^2
stcp       = sth[0]*cph[0]
stsp       = sth[0]*sph[0]
ctcp       = cth[0]*cph[0]
ctsp       = cth[0]*sph[0]
; => define resulting shock normal
nor        = [ cth[0],  stcp[0],  stsp[0] ]
dn_phi     = [    0d0, -stsp[0],  stcp[0] ]   ; => d(n)/d(phi)
dn_the     = [-sth[0],  ctcp[0],  ctsp[0] ]   ; => d(n)/d(the)
;-----------------------------------------------------------------------------------------
; => Define shock normal speed [SC-frame] from Eq. 7 of Koval and Szabo, [2008]
;-----------------------------------------------------------------------------------------
fac00      = (rho2[0]*vel2 - rho1[0]*vel1)                   ; => [3]-Element array
fac11      = (rho2[0] - rho1[0])
fac22      = fac00/fac11                                     ; => [3]-Element array
vs0        = fac22[0]*nor[0] + fac22[1]*nor[1] + fac22[2]*nor[2]  ; => scalar
;-----------------------------------------------------------------------------------------
; => Pre-define relevant quantities
;-----------------------------------------------------------------------------------------
vn         = REPLICATE(d,3L,2L)  ; => Vsw . n
bn         = REPLICATE(d,3L,2L)  ; => Bo  . n
vt         = REPLICATE(d,3L,2L)  ; => (n x Vsw) x n
bt         = REPLICATE(d,3L,2L)  ; => (n x Bo ) x n
ncrossVt   = REPLICATE(d,3L,2L)  ; => (n x Vt) = n x [(n x Vsw) x n] = n x Vsw
ncrossBt   = REPLICATE(d,3L,2L)  ; => (n x Bt) = n x [(n x Bo ) x n] = n x Bo
; => Define velocity differences
vdiffvn    = REPLICATE(d,3L,2L)  ; => [Vsw - Vsh] . n
vshv       = REPLICATE(d,3L,2L)  ; => Vsh  = (rho2*Vsw2 - rho1*Vsw1)/(rho2 - rho1) [vector]
vshn       = REPLICATE(d,3L,2L)  ; => Vshn = Vsh . n  [ Eq. 7 of Koval and Szabo, [2008] ]
vsnv       = REPLICATE(d,3L,2L)  ; => (Vsh) n
vdiffv     = REPLICATE(d,3L,2L)  ; => [Vsw - (Vshn) n]
vdiff2     = REPLICATE(d,3L,2L)  ; => [Vsw - (Vshn) n]^2
vdfdb      = REPLICATE(d,3L,2L)  ; => [Vsw - (Vshn) n] . Bo
bt2        = REPLICATE(d,3L,2L)  ; => Bt . Bt
;-----------------------------------------------------------------------------------------
; => Define normal component of solar wind velocity and magnetic field
;-----------------------------------------------------------------------------------------
bf12x    = [bf1[0],bf2[0]]
bf12y    = [bf1[1],bf2[1]]
bf12z    = [bf1[2],bf2[2]]
vo12x    = [vel1[0],vel2[0]]
vo12y    = [vel1[1],vel2[1]]
vo12z    = [vel1[2],vel2[2]]
temp     = vo12x*nor[0] + vo12y*nor[1] + vo12z*nor[2]
vn[*,0]  = temp[0] & vn[*,1] = temp[1]
temp     = bf12x*nor[0] + bf12y*nor[1] + bf12z*nor[2]
bn[*,0]  = temp[0] & bn[*,1] = temp[1]
;-----------------------------------------------------------------------------------------
; => Define transverse component of solar wind velocity and magnetic field
;-----------------------------------------------------------------------------------------
vt[*,0]       = CROSSP(CROSSP(nor,vel1),nor)
vt[*,1]       = CROSSP(CROSSP(nor,vel2),nor)
bt[*,0]       = CROSSP(CROSSP(nor,bf1),nor)
bt[*,1]       = CROSSP(CROSSP(nor,bf2),nor)
; => Calculate the magnitude of Bt^2 for later use
bt2[*,0]      = bt[0,0]^2 + bt[2,0]^2 + bt[2,0]^2
bt2[*,1]      = bt[0,1]^2 + bt[2,1]^2 + bt[2,1]^2
;-----------------------------------------------------------------------------------------
; => Calculate the diff. in vel.
;-----------------------------------------------------------------------------------------
; => Define some other useful factors
ncrossVt[*,0] = CROSSP(nor,vt[*,0])
ncrossVt[*,1] = CROSSP(nor,vt[*,1])
ncrossBt[*,0] = CROSSP(nor,bt[*,0])
ncrossBt[*,1] = CROSSP(nor,bt[*,1])
;-----------------------------------------------------------------------------------------
; => Define shock speeds parameters
;-----------------------------------------------------------------------------------------

; => Define:  Vsh   = (rho2*Vsw2 - rho1*Vsw1)/(rho2 - rho1)  {vector}  [shock speed]
vshv[*,0]       = fac22 & vshv[*,1] = fac22
; => Define:  Vshn  = Vsh . n                                {scalar}  [shock normal speed]
vshn[*,0]       = vshv[0,0]*nor[0] + vshv[1,0]*nor[1] + vshv[2,0]*nor[2]
vshn[*,1]       = vshn[*,0]
; => Define:  (Vshn) n                                       {vector}  [shock normal speed]
vsnv[*,0]       = vshn[0,0]*nor
vsnv[*,1]       = vshn[0,0]*nor
; => Define:  [Vsw - (Vshn) n]                               {vector}
vdiffv[*,0]     = (vel1 - vsnv[*,0])
vdiffv[*,1]     = (vel2 - vsnv[*,1])
; => Define:  [Vsw - Vsh] . n                                {scalar}
;vdiffvn[*,0]    = (vel1 - vshv[*,0])
;vdiffvn[*,1]    = (vel2 - vshv[*,1])
;vdiffvn[0,*]   *= nor[0] & vdiffvn[1,*] *= nor[1] & vdiffvn[2,*] *= nor[2]
vdiffvn[*,0]    = (vel1[0] - vshv[0,0])*nor[0] + (vel1[1] - vshv[1,0])*nor[1] + $
                  (vel1[2] - vshv[2,0])*nor[2]
vdiffvn[*,1]    = (vel2[0] - vshv[0,1])*nor[0] + (vel2[1] - vshv[1,1])*nor[1] + $
                  (vel2[2] - vshv[2,1])*nor[2]

; => Define:  [Vsw - (Vshn) n]^2                             {scalar}
vdiff2[*,0]     = vdiffv[0,0]^2 + vdiffv[1,0]^2 + vdiffv[2,0]^2
vdiff2[*,1]     = vdiffv[0,1]^2 + vdiffv[1,1]^2 + vdiffv[2,1]^2
; => Define:  [Vsw - (Vshn) n] . Bo                          {scalar}
vdfdb[*,0]      = vdiffv[0,0]*bf1[0] + vdiffv[1,0]*bf1[1] + vdiffv[2,0]*bf1[2]
vdfdb[*,1]      = vdiffv[0,1]*bf2[0] + vdiffv[1,1]*bf2[1] + vdiffv[2,1]*bf2[2]
;-----------------------------------------------------------------------------------------
; => define [Vsw - Vsh] . d(n)/d(xi)
;-----------------------------------------------------------------------------------------
delvn_phi  = REPLICATE(d,3L,2L)  ; => [Vsw - Vsh] . d(n)/d(phi)
delvn_the  = REPLICATE(d,3L,2L)  ; => [Vsw - Vsh] . d(n)/d(the)
vshdn_phi  = REPLICATE(d,3L,2L)  ; => Vshn = Vsh . d(n)/d(phi)
vshdn_the  = REPLICATE(d,3L,2L)  ; => Vshn = Vsh . d(n)/d(the)
;-----------------------------------------------------------------------------------------
; => define d(Qt)/d(xi) = -[ (d(n)/d(xi) . Q) n + (n . Q) d(n)/d(xi) ]
;-----------------------------------------------------------------------------------------
dvt_phi    = REPLICATE(d,3L,2L)  ; => dVt/d(phi)
dvt_the    = REPLICATE(d,3L,2L)  ; => dVt/d(the)
dbt_phi    = REPLICATE(d,3L,2L)  ; => dBt/d(phi)
dbt_the    = REPLICATE(d,3L,2L)  ; => dBt/d(the)
; => define the angular gradient of a normal vector
bn_dn_phi  = REPLICATE(d,3L,2L)  ; => Bo  . d(n)/d(phi)
bn_dn_the  = REPLICATE(d,3L,2L)  ; => Bo  . d(n)/d(the)
vn_dn_phi  = REPLICATE(d,3L,2L)  ; => Vsw . d(n)/d(phi)
vn_dn_the  = REPLICATE(d,3L,2L)  ; => Vsw . d(n)/d(the)
; => define the angular gradient of a transverse vector
bt_dn_phi  = REPLICATE(d,3L,2L)  ; => d(Bt)/d(phi) = - { Bn [d(n)/d(phi)] + [Bo  . d(n)/d(phi)] n }
bt_dn_the  = REPLICATE(d,3L,2L)  ; => d(Bt)/d(the) = - { Bn [d(n)/d(the)] + [Bo  . d(n)/d(the)] n }
vt_dn_phi  = REPLICATE(d,3L,2L)  ; => d(Vt)/d(phi) = - { Vn [d(n)/d(phi)] + [Vsw . d(n)/d(phi)] n }
vt_dn_the  = REPLICATE(d,3L,2L)  ; => d(Vt)/d(the) = - { Vn [d(n)/d(the)] + [Vsw . d(n)/d(the)] n }
; => define the cross product of an angular gradient and a transverse vector
btcrdn_phi = REPLICATE(d,3L,2L)  ; => d(n)/d(phi) x Bt
btcrdn_the = REPLICATE(d,3L,2L)  ; => d(n)/d(the) x Bt
vtcrdn_phi = REPLICATE(d,3L,2L)  ; => d(n)/d(phi) x Vt
vtcrdn_the = REPLICATE(d,3L,2L)  ; => d(n)/d(the) x Vt
; => define the cross product of normal and an angular gradient of the transverse vector
ncrdbt_phi = REPLICATE(d,3L,2L)  ; => n x d(Bt)/d(phi)
ncrdbt_the = REPLICATE(d,3L,2L)  ; => n x d(Bt)/d(the)
ncrdvt_phi = REPLICATE(d,3L,2L)  ; => n x d(Vt)/d(phi)
ncrdvt_the = REPLICATE(d,3L,2L)  ; => n x d(Vt)/d(the)
;-----------------------------------------------------------------------------------------
; => Define angular gradients
;-----------------------------------------------------------------------------------------
temp1           = (vel1 - vshv[*,0])
temp2           = (vel2 - vshv[*,1])
; => [Vsw - Vsh] . d(n)/d(phi)
delvn_phi[0,0]  = temp1[0]*dn_phi[0] + temp1[1]*dn_phi[1] + temp1[2]*dn_phi[2]
delvn_phi[0,1]  = temp2[0]*dn_phi[0] + temp2[1]*dn_phi[1] + temp2[2]*dn_phi[2]
delvn_phi[1,0]  = delvn_phi[0,0] & delvn_phi[2,0] = delvn_phi[0,0]
delvn_phi[1,1]  = delvn_phi[0,1] & delvn_phi[2,1] = delvn_phi[0,1]
; => [Vsw - Vsh] . d(n)/d(the)
delvn_the[0,0]  = temp1[0]*dn_the[0] + temp1[1]*dn_the[1] + temp1[2]*dn_the[2]
delvn_the[0,1]  = temp2[0]*dn_the[0] + temp2[1]*dn_the[1] + temp2[2]*dn_the[2]
delvn_the[1,0]  = delvn_the[0,0] & delvn_the[2,0] = delvn_the[0,0]
delvn_the[1,1]  = delvn_the[0,1] & delvn_the[2,1] = delvn_the[0,1]

; => Vsh . d(n)/d(phi)
vshdn_phi[0,0]  = vshv[0,0]*dn_phi[0] + vshv[1,0]*dn_phi[1] + vshv[2,0]*dn_phi[2]
vshdn_phi[0,1]  = vshv[0,1]*dn_phi[0] + vshv[1,1]*dn_phi[1] + vshv[2,1]*dn_phi[2]
vshdn_phi[1,0]  = vshdn_phi[0,0] & vshdn_phi[2,0] = vshdn_phi[0,0]
; => Vsh . d(n)/d(the)
vshdn_the[0,0]  = vshv[0,0]*dn_the[0] + vshv[1,0]*dn_the[1] + vshv[2,0]*dn_the[2]
vshdn_the[0,1]  = vshv[0,1]*dn_the[0] + vshv[1,1]*dn_the[1] + vshv[2,1]*dn_the[2]
vshdn_the[1,0]  = vshdn_the[0,0] & vshdn_the[2,0] = vshdn_the[0,0]
;---------------------------------------------------------------------
; => Q  . d(n)/d(xi)
;---------------------------------------------------------------------
; => Bo  . d(n)/d(phi)
temp            = bf12x*dn_phi[0] + bf12y*dn_phi[1] + bf12z*dn_phi[2]
bn_dn_phi[*,0]  = temp[0] & bn_dn_phi[*,1]  = temp[1]
; => Bo  . d(n)/d(the)
temp            = bf12x*dn_the[0] + bf12y*dn_the[1] + bf12z*dn_the[2]
bn_dn_the[*,0]  = temp[0] & bn_dn_the[*,1]  = temp[1]
; => Vsw . d(n)/d(phi)
temp            = vo12x*dn_phi[0] + vo12y*dn_phi[1] + vo12z*dn_phi[2]
vn_dn_phi[*,0]  = temp[0] & vn_dn_phi[*,1]  = temp[1]
; => Vsw . d(n)/d(the)
temp            = vo12x*dn_the[0] + vo12y*dn_the[1] + vo12z*dn_the[2]
vn_dn_the[*,0]  = temp[0] & vn_dn_the[*,1]  = temp[1]
;---------------------------------------------------------------------
; => d(Q)/d(xi)
;---------------------------------------------------------------------
; => d(Bt)/d(phi)
temp1           = -1d0*(bn_dn_phi[0,0]*nor + bn[0,0]*dn_phi)
temp2           = -1d0*(bn_dn_phi[0,1]*nor + bn[0,1]*dn_phi)
bt_dn_phi[*,0]  = temp1 & bt_dn_phi[*,1] = temp2
; => d(Bt)/d(the)
temp1           = -1d0*(bn_dn_the[0,0]*nor + bn[0,0]*dn_the)
temp2           = -1d0*(bn_dn_the[0,1]*nor + bn[0,1]*dn_the)
bt_dn_the[*,0]  = temp1 & bt_dn_the[*,1] = temp2
; => d(Vt)/d(phi)
temp1           = -1d0*(vn_dn_phi[0,0]*nor + vn[0,0]*dn_phi)
temp2           = -1d0*(vn_dn_phi[0,1]*nor + vn[0,1]*dn_phi)
vt_dn_phi[*,0]  = temp1 & vt_dn_phi[*,1] = temp2
; => d(Vt)/d(the)
temp1           = -1d0*(vn_dn_the[0,0]*nor + vn[0,0]*dn_the)
temp2           = -1d0*(vn_dn_the[0,1]*nor + vn[0,1]*dn_the)
vt_dn_the[*,0]  = temp1 & vt_dn_the[*,1] = temp2
;---------------------------------------------------------------------
; => d(n)/d(xi) x Qt
;---------------------------------------------------------------------
; => d(n)/d(phi) x Bt
temp1           = CROSSP(dn_phi,bt[*,0])
temp2           = CROSSP(dn_phi,bt[*,1])
btcrdn_phi[*,0] = temp1 & btcrdn_phi[*,1] = temp2
; => d(n)/d(the) x Bt
temp1           = CROSSP(dn_the,bt[*,0])
temp2           = CROSSP(dn_the,bt[*,1])
btcrdn_the[*,0] = temp1 & btcrdn_the[*,1] = temp2
; => d(n)/d(phi) x Vt
temp1           = CROSSP(dn_phi,vt[*,0])
temp2           = CROSSP(dn_phi,vt[*,1])
vtcrdn_phi[*,0] = temp1 & vtcrdn_phi[*,1] = temp2
; => d(n)/d(the) x Vt
temp1           = CROSSP(dn_the,vt[*,0])
temp2           = CROSSP(dn_the,vt[*,1])
vtcrdn_the[*,0] = temp1 & vtcrdn_the[*,1] = temp2
;---------------------------------------------------------------------
; => n x d(Q)/d(xi)
;---------------------------------------------------------------------
; => n x d(Bt)/d(phi)
temp1           = CROSSP(nor,bt_dn_phi[*,0])
temp2           = CROSSP(nor,bt_dn_phi[*,1])
ncrdbt_phi[*,0] = temp1 & ncrdbt_phi[*,1] = temp2
; => n x d(Bt)/d(the)
temp1           = CROSSP(nor,bt_dn_the[*,0])
temp2           = CROSSP(nor,bt_dn_the[*,1])
ncrdbt_the[*,0] = temp1 & ncrdbt_the[*,1] = temp2

; => n x d(Vt)/d(phi)
temp1           = CROSSP(nor,vt_dn_phi[*,0])
temp2           = CROSSP(nor,vt_dn_phi[*,1])
ncrdvt_phi[*,0] = temp1 & ncrdvt_phi[*,1] = temp2
; => n x d(Vt)/d(the)
temp1           = CROSSP(nor,vt_dn_the[*,0])
temp2           = CROSSP(nor,vt_dn_the[*,1])
ncrdvt_the[*,0] = temp1 & ncrdvt_the[*,1] = temp2

;-----------------------------------------------------------------------------------------
; => Define relevant partial differential equations
;-----------------------------------------------------------------------------------------
CASE eqn[0] OF
  1  :  BEGIN
    ;-------------------------------------------------------------------------------------
    ; => mass flux equation [Eq. 1 from Koval and Szabo, 2008]
    ;-------------------------------------------------------------------------------------
    ; => d[Gn]/d(phi)
    df_dphi = rho2[0]*vn_dn_phi[0,1] - rho1[0]*vn_dn_phi[0,0]
    ; => d[Gn]/d(the)
    df_dthe = rho2[0]*vn_dn_the[0,1] - rho1[0]*vn_dn_the[0,0]
    ; => d[Gn]/d(Vs)
    df_dvsh = rho1[0] - rho2[0]
  END
  2  :  BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Bn equation [Eq. 2 from Koval and Szabo, 2008]
    ;-------------------------------------------------------------------------------------
    ; => d[Bn]/d(phi)
    df_dphi = bn_dn_phi[0,1] - bn_dn_phi[0,0]
    ; => d[Bn]/d(the)
    df_dthe = bn_dn_the[0,1] - bn_dn_the[0,0]
    ; => d[Bn]/d(Vs)
    df_dvsh = 0d0
  END
  3  :  BEGIN
    ;-------------------------------------------------------------------------------------
    ; => transverse momentum flux equation [Eq. 3 from Koval and Szabo, 2008]
    ;-------------------------------------------------------------------------------------
    ; => d[St]/d(phi)
    term10  = rho1[0]*(delvn_phi[0,0]*vt[*,0] + vdiffvn[0,0]*vt_dn_phi[*,0])
    term11  = -1d0/muo*(bn_dn_phi[0,0]*bt[*,0] + bn[0,0]*bt_dn_phi[*,0])
    term20  = rho2[0]*(delvn_phi[0,1]*vt[*,1] + vdiffvn[0,1]*vt_dn_phi[*,1])
    term21  = -1d0/muo*(bn_dn_phi[0,1]*bt[*,1] + bn[0,1]*bt_dn_phi[*,1])
    df_dphi = (term20 + term21) - (term10 + term11)
    ; => d[St]/d(the)
    term10  = rho1[0]*(delvn_the[0,0]*vt[*,0] + vdiffvn[0,0]*vt_dn_the[*,0])
    term11  = -1d0/muo*(bn_dn_the[0,0]*bt[*,0] + bn[0,0]*bt_dn_the[*,0])
    term20  = rho2[0]*(delvn_the[0,1]*vt[*,1] + vdiffvn[0,1]*vt_dn_the[*,1])
    term21  = -1d0/muo*(bn_dn_the[0,1]*bt[*,1] + bn[0,1]*bt_dn_the[*,1])
    df_dthe = (term20 + term21) - (term10 + term11)
    ; => d[St]/d(Vs)
    df_dvsh = -rho2[0]*vt[*,1] + rho1[0]*vt[*,0]
  END
  4  :  BEGIN
    ;-------------------------------------------------------------------------------------
    ; => transverse electric field equation [Eq. 4 from Koval and Szabo, 2008]
    ;-------------------------------------------------------------------------------------
    ; => d[Et]/d(phi)
    ; => term0s = [ d(n)/d(phi) x Vt + n x d(Vt)/d(phi) ] Bn
    term10  = ( vtcrdn_phi[*,0] + ncrdvt_phi[*,0])*bn[0,0]
    term20  = ( vtcrdn_phi[*,1] + ncrdvt_phi[*,1])*bn[0,1]
    ; => term1s = [ (n x Vt) (Bo . d(n)/d(phi)) - (Vsw . d(n)/d(phi)) (n x Bt) ]
    term11  = ncrossVt[*,0]*bn_dn_phi[0,0] - vn_dn_phi[0,0]*ncrossBt[*,0]
    term21  = ncrossVt[*,1]*bn_dn_phi[0,1] - vn_dn_phi[0,1]*ncrossBt[*,1]
    ; => term2s = -(Vn - Vsh) [ d(n)/d(phi) x Bt + n x d(Bt)/d(phi) ]
    term12  = -vdiffvn[0,0]*( btcrdn_phi[*,0] + ncrdbt_phi[*,0] )
    term22  = -vdiffvn[0,1]*( btcrdn_phi[*,1] + ncrdbt_phi[*,1] )
    df_dphi = (term20 + term21 + term22) - (term10 + term11 + term12)
    ; => d[Et]/d(the)
    ; => term0s = [ d(n)/d(the) x Vt + n x d(Vt)/d(the) ] Bn
    term10  = ( vtcrdn_the[*,0] + ncrdvt_the[*,0])*bn[0,0]
    term20  = ( vtcrdn_the[*,1] + ncrdvt_the[*,1])*bn[0,1]
    ; => term1s = [ (n x Vt) (Bo . d(n)/d(the)) - (Vsw . d(n)/d(the)) (n x Bt) ]
    term11  = ncrossVt[*,0]*bn_dn_the[0,0] - vn_dn_the[0,0]*ncrossBt[*,0]
    term21  = ncrossVt[*,1]*bn_dn_the[0,1] - vn_dn_the[0,1]*ncrossBt[*,1]
    ; => term2s = -(Vn - Vsh) [ d(n)/d(the) x Bt + n x d(Bt)/d(the) ]
    term12  = -vdiffvn[0,0]*( btcrdn_the[*,0] + ncrdbt_the[*,0] )
    term22  = -vdiffvn[0,1]*( btcrdn_the[*,1] + ncrdbt_the[*,1] )
    df_dthe = (term20 + term21 + term22) - (term10 + term11 + term12)
    ; => d[Et]/d(Vs)
    df_dvsh = ncrossBt[*,1] - ncrossBt[*,0]
  END
  5  :  BEGIN
    ;-------------------------------------------------------------------------------------
    ; => normal momentum flux equation [Eq. 5 from Koval and Szabo, 2008]
    ;-------------------------------------------------------------------------------------
    ; => d[Sn]/d(phi)
    ; => term0s = 2 [ (Bt/2muo) . d(Bt)/d(phi) ]
    term10  = (bt[0,0]*bt_dn_phi[0,0] + bt[1,0]*bt_dn_phi[1,0] + bt[2,0]*bt_dn_phi[2,0])/muo
    term20  = (bt[0,1]*bt_dn_phi[0,1] + bt[1,1]*bt_dn_phi[1,1] + bt[2,1]*bt_dn_phi[2,1])/muo
    ; => term1s = 2 [ rho (Vn - Vs) (d(n)/d(phi) . Vsw) ]
    term11  = 2d0*rho1[0]*vdiffvn[0,0]*vn_dn_phi[0,0]
    term21  = 2d0*rho2[0]*vdiffvn[0,1]*vn_dn_phi[0,1]
    df_dphi = (term20 + term21) - (term10 + term11)
    ; => d[Sn]/d(the)
    ; => term0s = 2 [ (Bt/2muo) . d(Bt)/d(the) ]
    term10  = (bt[0,0]*bt_dn_the[0,0] + bt[1,0]*bt_dn_the[1,0] + bt[2,0]*bt_dn_the[2,0])/muo
    term20  = (bt[0,1]*bt_dn_the[0,1] + bt[1,1]*bt_dn_the[1,1] + bt[2,1]*bt_dn_the[2,1])/muo
    ; => term1s = 2 [ rho (Vn - Vs) (d(n)/d(the) . Vsw) ]
    term11  = 2d0*rho1[0]*vdiffvn[0,0]*vn_dn_the[0,0]
    term21  = 2d0*rho2[0]*vdiffvn[0,1]*vn_dn_the[0,1]
    df_dthe = (term20 + term21) - (term10 + term11)
    ; => d[Sn]/d(Vs)
    df_dvsh = -2d0*rho2[0]*vdiffvn[0,1] + 2d0*rho1[0]*vdiffvn[0,0]
  END
  6  :  BEGIN
    ;-------------------------------------------------------------------------------------
    ; => energy flux equation [Eq. 6 from Koval and Szabo, 2008]
    ;-------------------------------------------------------------------------------------
    ; => Define internal energy
    ; => eners = { rho [Vsw - (Vsh) n]^2 + 2 g/(g-1) P + B^2/muo }/2
    ener1   = (rho1[0]*vdiff2[0,0] + 2d0*gfactor[0]*press1[0] + bmag1^2/muo)/2d0
    ener2   = (rho2[0]*vdiff2[0,1] + 2d0*gfactor[0]*press2[0] + bmag2^2/muo)/2d0
    ; => term0s = [(Vsw - Vsh) . d(n)/d(phi)] Es
    term10  = delvn_phi[0,0]*ener1[0]
    term20  = delvn_phi[0,1]*ener2[0]
    ; => term1s0 = - { (Vsh . d(n)/d(phi)) n + Vshn d(n)/d(phi) }
    term110 = -1d0*(vshdn_phi[0,0]*nor + vshn[0,0]*dn_phi)
    term210 = -1d0*(vshdn_phi[0,1]*nor + vshn[0,1]*dn_phi)
    ; => term1s = - rho (Vsw - Vshn) ([Vsw - (Vshn) n] . { (Vsh . d(n)/d(phi)) n + Vshn d(n)/d(phi) })
    term11  = rho1[0]*vdiffvn[0,0]*(vdiffv[0,0]*term110[0] + vdiffv[1,0]*term110[1] + vdiffv[2,0]*term110[2])
    term21  = rho2[0]*vdiffvn[0,1]*(vdiffv[0,1]*term210[0] + vdiffv[1,1]*term210[1] + vdiffv[2,1]*term210[2])
    ; => term2s = -{ [B . d(n)/d(phi)] [Vsw - (Vshn) n] - Bn [Vshn d(n)/d(phi)] } . B/muo
    term12  = -1d0*((bn_dn_the[0,0]*vdfdb[0,0]) - (bn[0,0]*vshn[0,0]*bn_dn_phi[0,0]))/muo
    term22  = -1d0*((bn_dn_the[0,1]*vdfdb[0,1]) - (bn[0,1]*vshn[0,1]*bn_dn_phi[0,1]))/muo
    ; => d[En]/d(phi)
    df_dphi = (term20 + term21 + term22) - (term10 + term11 + term12)
    ; => term0s = [(Vsw - Vsh) . d(n)/d(the)] Es
    term10  = delvn_the[0,0]*ener1[0]
    term20  = delvn_the[0,1]*ener2[0]
    ; => term1s0 = - { (Vsh . d(n)/d(the)) n + Vshn d(n)/d(the) }
    term110 = -1d0*(vshdn_the[0,0]*nor + vshn[0,0]*dn_the)
    term210 = -1d0*(vshdn_the[0,1]*nor + vshn[0,1]*dn_the)
    ; => term1s = - rho (Vsw - Vshn) ([Vsw - (Vshn) n] . { (Vsh . d(n)/d(the)) n + Vshn d(n)/d(the) })
    term11  = rho1[0]*vdiffvn[0,0]*(vdiffv[0,0]*term110[0] + vdiffv[1,0]*term110[1] + vdiffv[2,0]*term110[2])
    term21  = rho2[0]*vdiffvn[0,1]*(vdiffv[0,1]*term210[0] + vdiffv[1,1]*term210[1] + vdiffv[2,1]*term210[2])
    ; => term2s = -{ [B . d(n)/d(the)] [Vsw - (Vshn) n] - Bn [Vshn d(n)/d(the)] } . B/muo
    term12  = -1d0*((bn_dn_the[0,0]*vdfdb[0,0]) - (bn[0,0]*vshn[0,0]*bn_dn_the[0,0]))/muo
    term22  = -1d0*((bn_dn_the[0,1]*vdfdb[0,1]) - (bn[0,1]*vshn[0,1]*bn_dn_the[0,1]))/muo
    ; => d[En]/d(the)
    df_dthe = (term20 + term21 + term22) - (term10 + term11 + term12)
    ; => d[En]/d(Vs)
    ; => term0s = rho { [Vsw - (Vsh) n]^2 + 2 g/(g-1) P + B^2/muo }/2
    term10  = rho1[0]*(vdiff2[0,0] + gfactor[0]*press1[0] + bmag1^2/muo)/2d0
    term20  = rho2[0]*(vdiff2[0,1] + gfactor[0]*press2[0] + bmag2^2/muo)/2d0
    ; => term1s = {([Vsw - (Vsh) n] . n) }
    term11  = vdiffv[0,0]*nor[0] + vdiffv[1,0]*nor[1] + vdiffv[2,0]*nor[2]
    term21  = vdiffv[0,1]*nor[0] + vdiffv[1,1]*nor[1] + vdiffv[2,1]*nor[2]
    ; => term2s = { -rho [(Vsw . n) - Vsh]*([Vsw - (Vsh) n] . n) + Bn^2/muo }
    term12  = -1d0*rho1[0]*vdiffvn[0,0]*term11 + (bn[0,0]^2)/muo
    term22  = -1d0*rho2[0]*vdiffvn[0,1]*term21 + (bn[0,1]^2)/muo
    df_dvsh = (term20 + term22) - (term10 + term12)
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return partials to user
;-----------------------------------------------------------------------------------------
RETURN,{DPHI:df_dphi,DTHE:df_dthe,DVSH:df_dvsh}
END




;vdiffs     = REPLICATE(d,3L,2L)  ; => [(Vsw . n) - Vsh]
;vdiffv     = REPLICATE(d,3L,2L)  ; => [Vsw - (Vsh) n]
;vdiff2     = REPLICATE(d,3L,2L)  ; => [Vsw - (Vsh) n]^2
;vdfdb      = REPLICATE(d,3L,2L)  ; => [Vsw - (Vsh) n] . Bo
;bt2        = REPLICATE(d,3L,2L)  ; => Bt . Bt

;vshv[*,*,0]     = fac22 & vshv[*,*,1] = fac22  ; => [N,3,2]-Element array
; => Define:  Vshn  = Vsh . n                                {scalar}  [shock normal speed]
;vshn[*,0,*]     = vshv[*,0,*]*nor[0] + vshv[*,1,*]*nor[1] + vshv[*,2,*]*nor[2]
;vshn[*,1,*]     = vshn[*,0,*] & vshn[*,2,*] = vshn[*,0,*]
; => Define:  (Vshn) n                                       {vector}  [shock normal speed]
;vsnv            = vshn
;vsnv[*,0,*]    *= nor[0] & vsnv[*,1,*]   *= nor[1] & vsnv[*,2,*]   *= nor[2]
; => Define:  [Vsw - (Vshn) n]                               {vector}
;vdiffv[*,*,0]   = (vo[*,*,0] - vsnv[*,*,0])
;vdiffv[*,*,1]   = (vo[*,*,1] - vsnv[*,*,1])    ; => [N,3,2]-Element array  {vector}
; => Define:  [Vsw - Vsh] . n                                {scalar}
;vdiffvn[*,*,0]  = (vo[*,*,0] - vshv[*,*,0])    ; => [N,3,2]-Element array  {scalar}
;vdiffvn[*,*,1]  = (vo[*,*,1] - vshv[*,*,0])
;vdiffvn[*,0,*] *= nor[0] & vdiffvn[*,1,*] *= nor[1] & vdiffvn[*,2,*] *= nor[2]
; => Define:  [Vsw - (Vshn) n]^2                             {scalar}
;vdiff2[*,0,*]   = REFORM(vdiffv[*,0,*])^2 + $
;                  REFORM(vdiffv[*,1,*])^2 + $
;                  REFORM(vdiffv[*,2,*])^2                      ; => [N,2]-Element array
;vdiff2[*,1,*]   = vdiff2[*,0,*] & vdiff2[*,2,*] = vdiff2[*,0,*]
; => Define:  [Vsw - (Vshn) n] . Bo                          {scalar}
;vdfdb[*,0,*]    = vdiffv[*,0,*]*bo[*,0,*] + vdiffv[*,1,*]*bo[*,1,*] + $
;                  vdiffv[*,2,*]*bo[*,2,*]
;vdfdb[*,1,*]    = vdfdb[*,0,*] & vdfdb[*,2,*] = vdfdb[*,0,*]
;vs2[*,0] = (vs[0]*nor)
;vs2[*,1] = vs2[*,0]
;-----------------------------------------------------------------------------------------
; => Calculate the diff. in vel.
;-----------------------------------------------------------------------------------------
; => Calculate the diff. in vel.
;vdiffs          = (vn - vs[0])                                 ; => [3,2]-Element array  {scalar version}
;vdiffv[*,0]     = (vel1 - vs2[*,0]  )                          ; => [3,2]-Element array  {vector version}
;vdiffv[*,1]     = (vel2 - vs2[*,1]  )                          ; => [3,2]-Element array  {vector version}
;vdiff2[0,*]     = REFORM(vdiffv[0,*])^2 + REFORM(vdiffv[1,*])^2 + $
;                  REFORM(vdiffv[2,*])^2                        ; => [3,2]-Element array
;vdiff2[1,*]     = vdiff2[0,*] & vdiff2[2,*] = vdiff2[0,*]
;vdfdb[0,0]      = vdiffv[0,0]*bf1[0] + vdiffv[1,0]*bf1[1] + vdiffv[2,0]*bf1[2]
;vdfdb[0,1]      = vdiffv[0,1]*bf2[0] + vdiffv[1,1]*bf2[1] + vdiffv[2,1]*bf2[2]



    ; => transverse momentum flux equation [Eq. 3 from Koval and Szabo, 2008]
;    term10  = rho1[0]*(vn_dn_phi[0,0]*vt[*,0] + vdiffs[0,0]*vt_dn_phi[*,0])
;    term20  = rho2[0]*(vn_dn_phi[0,1]*vt[*,1] + vdiffs[0,1]*vt_dn_phi[*,1])
;    term11  = -1d0*(bn_dn_phi[0,0]*bt[*,0] + bn[0,0]*bt_dn_phi[*,0])/muo
;    term21  = -1d0*(bn_dn_phi[0,1]*bt[*,1] + bn[0,1]*bt_dn_phi[*,1])/muo
;    term10  = rho1[0]*(vn_dn_the[0,0]*vt[*,0] + vdiffs[0,0]*vt_dn_the[*,0])
;    term20  = rho2[0]*(vn_dn_the[0,1]*vt[*,1] + vdiffs[0,1]*vt_dn_the[*,1])
;    term11  = -1d0*(bn_dn_the[0,0]*bt[*,0] + bn[0,0]*bt_dn_the[*,0])/muo
;    term21  = -1d0*(bn_dn_the[0,1]*bt[*,1] + bn[0,1]*bt_dn_the[*,1])/muo

    ; => transverse electric field equation [Eq. 4 from Koval and Szabo, 2008]
;    term10  = ( vtcrdn_phi[*,0] + CROSSP(nor,vt_dn_phi[*,0]) )*bn[0,0]
;    term20  = ( vtcrdn_phi[*,1] + CROSSP(nor,vt_dn_phi[*,1]) )*bn[0,1]
    ; => term1s = [ (n x Vt) (Bo . d(n)/d(phi)) - (Vsw . d(n)/d(phi)) (n x Bt) ]
;    term11  = ncrossVt[*,0]*bn_dn_phi[0,0] - vn_dn_phi[0,0]*ncrossBt[*,0]
;    term21  = ncrossVt[*,1]*bn_dn_phi[0,1] - vn_dn_phi[0,1]*ncrossBt[*,1]
    ; => term2s = -(Vn - Vsh) [ d(n)/d(phi) x Bt + n x d(Bt)/d(phi) ]
;    term12  = -vdiffs[0,0]*( btcrdn_phi[*,0] + CROSSP(nor,bt_dn_phi[*,0]) )
;    term22  = -vdiffs[0,1]*( btcrdn_phi[*,1] + CROSSP(nor,bt_dn_phi[*,1]) )
    ; => term0s = [ d(n)/d(the) x Vt + n x d(Vt)/d(the) ] Bn
;    term10  = ( vtcrdn_the[*,0] + CROSSP(nor,vt_dn_the[*,0]) )*bn[0,0]
;    term20  = ( vtcrdn_the[*,1] + CROSSP(nor,vt_dn_the[*,1]) )*bn[0,1]
    ; => term1s = [ (n x Vt) (Bo . d(n)/d(the)) - (Vsw . d(n)/d(the)) (n x Bt) ]
;    term11  = ncrossVt[*,0]*bn_dn_the[0,0] - vn_dn_the[0,0]*ncrossBt[*,0]
;    term21  = ncrossVt[*,1]*bn_dn_the[0,1] - vn_dn_the[0,1]*ncrossBt[*,1]
    ; => term2s = -(Vn - Vsh) [ d(n)/d(the) x Bt + n x d(Bt)/d(the) ]
;    term12  = -vdiffs[0,0]*( btcrdn_the[*,0] + CROSSP(nor,bt_dn_the[*,0]) )
;    term22  = -vdiffs[0,1]*( btcrdn_the[*,1] + CROSSP(nor,bt_dn_the[*,1]) )

    ; => normal momentum flux equation [Eq. 5 from Koval and Szabo, 2008]
    ; => term1s = 2 [ rho (Vn - Vs) (d(n)/d(phi) . Vsw) ]
;    term11  = 2d0*rho1[0]*vdiffs[0,0]*vn_dn_phi[0,0]
;    term21  = 2d0*rho2[0]*vdiffs[0,1]*vn_dn_phi[0,1]
    ; => term1s = 2 [ rho (Vn - Vs) (d(n)/d(the) . Vsw) ]
;    term11  = 2d0*rho1[0]*vdiffs[0,0]*vn_dn_the[0,0]
;    term21  = 2d0*rho2[0]*vdiffs[0,1]*vn_dn_the[0,1]

    ; => energy flux equation [Eq. 6 from Koval and Szabo, 2008]
    ; => d[En]/d(phi)
    ; => fac0s = rho Vs [Vsw . d(n)/d(phi)]
;    fac01   = rho1[0]*vs[0]*vn_dn_phi[0,0]
;    fac02   = rho2[0]*vs[0]*vn_dn_phi[0,1]
    ; => term0s = rho { [Vsw . d(n)/d(phi)] ([Vsw - (Vsh) n] . Vs d(n)/d(phi)) }
;    term10  = fac01[0]*(vdiffv[0,0]*dn_phi[0] + vdiffv[1,0]*dn_phi[1] + vdiffv[2,0]*dn_phi[2])
;    term20  = fac02[0]*(vdiffv[0,1]*dn_phi[0] + vdiffv[1,1]*dn_phi[1] + vdiffv[2,1]*dn_phi[2])
    ; => term1s = { [B . d(n)/d(phi)]  [Vsw - (Vsh) n] } . B
;    term11  = bn_dn_phi[0,0]*vdfdb[0,0]
;    term21  = bn_dn_phi[0,1]*vdfdb[0,1]
    ; => term2s = -{ Bn Vsh d(n)/d(phi) } . B
;    term12  = -1d0*bn[0,0]*vs[0]*bn_dn_phi[0,0]
;    term22  = -1d0*bn[0,1]*vs[0]*bn_dn_phi[0,1]
;    df_dphi = (term20 + term21 + term22) - (term10 + term11 + term12)
    ; => d[En]/d(the)
    ; => fac0 = rho Vs [Vsw . d(n)/d(the)]
;    fac0    = rho1[0]*vs[0]*vn_dn_the[0,0]
;    fac1    = rho2[0]*vs[0]*vn_dn_the[0,1]
    ; => term0s = rho { [Vsw . d(n)/d(the)] ([Vsw - (Vsh) n] . Vs d(n)/d(the)) }
;    term10  = fac0[0]*(vdiffv[0,0]*dn_the[0] + vdiffv[1,0]*dn_the[1] + vdiffv[2,0]*dn_the[2])
;    term20  = fac1[0]*(vdiffv[0,1]*dn_the[0] + vdiffv[1,1]*dn_the[1] + vdiffv[2,1]*dn_the[2])
    ; => term1s = { [B . d(n)/d(the)]  [Vsw - (Vsh) n] } . B
;    term11  = bn_dn_the[0,0]*vdfdb[0,0]
;    term21  = bn_dn_the[0,1]*vdfdb[0,1]
    ; => term2s = -{ Bn Vsh d(n)/d(the) } . B
;    term12  = -1d0*bn[0,0]*vs[0]*bn_dn_the[0,0]
;    term22  = -1d0*bn[0,1]*vs[0]*bn_dn_the[0,1]
;    df_dthe = (term20 + term21 + term22) - (term10 + term11 + term12)


