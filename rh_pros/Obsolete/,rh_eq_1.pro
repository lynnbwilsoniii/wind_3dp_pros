;+
;*****************************************************************************************
;
;  FUNCTION :   rh_eq_1.pro
;  PURPOSE  :   Computes the mass flux conservation relation for an input set of data
;                 points and the gradients with respect to the shock normal angles
;                 [azimuthal,poloidal] and the shock speed.  These three variables
;                 are free parameters in the minimization of the merit function
;                 defined by the Rankine-Hugoniot equations from 
;                 Koval and Szabo, [2008].
;
;  CALLED BY:   
;               
;
;  CALLS:
;               
;
;  REQUIRES:    
;               
;
;  INPUT:
;               RHO   :  [N,2]-Element [up,down] array corresponding to the mass/number
;                          density [kg cm^(-3)]
;               VSW   :  [N,3,2]-Element [up,down] array corresponding to the solar wind
;                          velocity vectors [SC-frame, km/s]
;               MAG   :  [N,3,2]-Element [up,down] array corresponding to the ambient
;                          magnetic field vectors [nT]
;               TOT   :  [N,2]-Element [up,down] array corresponding to the total plasma
;                          temperature [eV]
;               PHI   :  Scalar value defining the azimuthal angle [deg] of the shock
;                          normal vector [0 < phi < 2 Pi]
;               THE   :  Scalar value defining the poloidal  angle [deg] of the shock
;                          normal vector [0 < the <   Pi]
;               VSH   :  Scalar shock normal velocity [km/s] in SC-frame
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               SIGS  :  [N,4,3]-Element array of standard deviations corresponding to
;                          the [N,4]-element array of input data arrays/vectors
;               NDAT  :  Scalar value defining the number of angles to use to
;                          generate the dummy array of possible normal vectors
;                          [Default = 100L]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
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
;   CREATED:  04/27/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/27/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_eq_1, rho, vsw, mag, tot, phi, the, vsh, SIGS=sigs

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
polyti     = 5d0/3d0           ; => Polytrope index
gfactor    = polyti[0]/(polyti[0] - 1d0)

ph         = phi[0]*!DPI/18d1     ; => convert to radians
th         = the[0]*!DPI/18d1     ; => convert to radians
; => define cosine and sine of angles
sph        = SIN(ph[0])
cph        = COS(ph[0])
sth        = SIN(th[0])
cth        = COS(th[0])
; => define resulting shock normal
nor        = [ cth[0],  sth[0]*cph[0],  sth[0]*sph[0] ]
dn_phi     = [    0d0, -sth[0]*sph[0],  sth[0]*cph[0] ]   ; => dn/dphi
dn_the     = [-sth[0],  cth[0]*cph[0],  cth[0]*sph[0] ]   ; => dn/dthe
;-----------------------------------------------------------------------------------------
; => Convert to SI units
;-----------------------------------------------------------------------------------------
md         = REFORM(rho)*1d6      ; => convert to [kg m^(-3)]  {[N,2]-Element array}
bo         = REFORM(mag)*1d-9     ; => convert to [Tesla]      {[N,3,2]-Element array}
vo         = REFORM(vsw)*1d3      ; => convert to [m/s]        {[N,3,2]-Element array}
vs         = REFORM(vsh[0])*1d3   ; => convert to [m/s]        {scalar}
te         = REFORM(tot)*qq       ; => convert to [Joules]     {[N,2]-Element array}
; => Define thermal pressure [Pa]
pt         = md/mp*te             ; => Pa = N m^(-2) = J m^(-3)
sz         = SIZE(md,/DIMENSIONS)
nd         = sz[0]                ; => # of data points
;-----------------------------------------------------------------------------------------
; => Pre-define relevant quantities
;-----------------------------------------------------------------------------------------
po         = REPLICATE(d,nd,3L,2L)  ; => [N,3,2]-Element version of pt {see above}
bmg        = REPLICATE(d,nd,3L,2L)  ; => [N,3,2]-Element version |B|
md3        = REPLICATE(d,nd,3L,2L)  ; => [N,3,2]-Element version md
vn         = REPLICATE(d,nd,3L,2L)  ; => Vsw . n
bn         = REPLICATE(d,nd,3L,2L)  ; => Bo  . n
vs2        = REPLICATE(d,nd,3L,2L)  ; => (Vsh) n
vt         = REPLICATE(d,nd,3L,2L)  ; => (n x Vsw) x n
bt         = REPLICATE(d,nd,3L,2L)  ; => (n x Bo ) x n
ncrossVt   = REPLICATE(d,nd,3L,2L)  ; => (n x Vt) = n x [(n x Vsw) x n] = n x Vsw
ncrossBt   = REPLICATE(d,nd,3L,2L)  ; => (n x Bt) = n x [(n x Bo ) x n] = n x Bo
; => Define velocity differences
vdiffs     = REPLICATE(d,nd,3L,2L)  ; => [(Vsw . n) - Vsh]
vdiffv     = REPLICATE(d,nd,3L,2L)  ; => [Vsw - (Vsh) n]
vdiff2     = REPLICATE(d,nd,3L,2L)  ; => [Vsw - (Vsh) n]^2
vdfdb      = REPLICATE(d,nd,3L,2L)  ; => [Vsw - (Vsh) n] . Bo
bt2        = REPLICATE(d,nd,3L,2L)  ; => Bt . Bt
; => factors for partial derivatives
dn_phi3    = REPLICATE(d,nd,3L,2L)  ; => d(n)/d(phi)
dn_the3    = REPLICATE(d,nd,3L,2L)  ; => d(n)/d(the)
dvt_phi    = REPLICATE(d,nd,3L,2L)  ; => dVt/dphi
dvt_the    = REPLICATE(d,nd,3L,2L)  ; => dVt/dthe
dbt_phi    = REPLICATE(d,nd,3L,2L)  ; => dBt/dphi
dbt_the    = REPLICATE(d,nd,3L,2L)  ; => dBt/dthe
; => define the angular gradient of a normal vector
bn_dn_phi  = REPLICATE(d,nd,3L,2L)  ; => Bo  . d(n)/d(phi)
bn_dn_the  = REPLICATE(d,nd,3L,2L)  ; => Bo  . d(n)/d(the)
vn_dn_phi  = REPLICATE(d,nd,3L,2L)  ; => Vsw . d(n)/d(phi)
vn_dn_the  = REPLICATE(d,nd,3L,2L)  ; => Vsw . d(n)/d(the)
; => define the angular gradient of a transverse vector
bt_dn_phi  = REPLICATE(d,nd,3L,2L)  ; => d(Bt)/d(phi) = - { Bn [d(n)/d(phi)] + [Bo  . d(n)/d(phi)] n }
bt_dn_the  = REPLICATE(d,nd,3L,2L)  ; => d(Bt)/d(the) = - { Bn [d(n)/d(the)] + [Bo  . d(n)/d(the)] n }
vt_dn_phi  = REPLICATE(d,nd,3L,2L)  ; => d(Vt)/d(phi) = - { Vn [d(n)/d(phi)] + [Vsw . d(n)/d(phi)] n }
vt_dn_the  = REPLICATE(d,nd,3L,2L)  ; => d(Vt)/d(the) = - { Vn [d(n)/d(the)] + [Vsw . d(n)/d(the)] n }
; => define the cross product of an angular gradient and a transverse vector
btcrdn_phi = REPLICATE(d,nd,3L,2L)  ; => d(n)/d(phi) x Bt
btcrdn_the = REPLICATE(d,nd,3L,2L)  ; => d(n)/d(the) x Bt
vtcrdn_phi = REPLICATE(d,nd,3L,2L)  ; => d(n)/d(phi) x Vt
vtcrdn_the = REPLICATE(d,nd,3L,2L)  ; => d(n)/d(the) x Vt
; => Define partial derivatives
df_dphi    = REPLICATE(d,nd,3L,2L)  ; => d(Eq)/d(phi)
df_dthe    = REPLICATE(d,nd,3L,2L)  ; => d(Eq)/d(the)
df_dvsh    = REPLICATE(d,nd,3L,2L)  ; => d(Eq)/d(Vsh)
equation   = REPLICATE(d,nd,3L,2L)  ; => Eq. of user's choice
;-----------------------------------------------------------------------------------------
; => Define scalar parameters as [N,3,2]-Element arrays
;-----------------------------------------------------------------------------------------
po[*,0,*]  = pt & po[*,1,*] = pt & po[*,2,*] = pt
; => Calculate the magnitude of the B-field for later use
bmg[*,0,*] = SQRT(bo[*,0,*]^2 + bo[*,1,*]^2 + bo[*,2,*]^2)
bmg[*,1,*] = bmg[*,0,*] & bmg[*,2,*] = bmg[*,0,*]

md3[*,0,*] = md & md3[*,1,*] = md & md3[*,2,*] = md
;-----------------------------------------------------------------------------------------
; => Define normal component of solar wind velocity and magnetic field
;-----------------------------------------------------------------------------------------
vn[*,0,*]  = (vo[*,0,*]*nor[0] + vo[*,1,*]*nor[1] + vo[*,2,*]*nor[2])  ; => [N,2]-Element array
bn[*,0,*]  = (bo[*,0,*]*nor[0] + bo[*,1,*]*nor[1] + bo[*,2,*]*nor[2])
vn[*,1,*]  = vn[*,0,*] & vn[*,2,*] = vn[*,0,*]
bn[*,1,*]  = bn[*,0,*] & bn[*,2,*] = bn[*,0,*]

vs2[*,*,0] = REPLICATE(1d0,nd) # (vs[0]*nor)
vs2[*,*,1] = vs2[*,*,0]
;-----------------------------------------------------------------------------------------
; => Define some relevant multiplicative factors
;-----------------------------------------------------------------------------------------
; => Pre-define relevant equation and partials
dn_phi3[*,*,0]  = REPLICATE(1d0,nd) # dn_phi                   ; => [N,3]-Element array
dn_phi3[*,*,1]  = dn_phi3[*,*,0]
dn_the3[*,*,0]  = REPLICATE(1d0,nd) # dn_the
dn_the3[*,*,1]  = dn_the3[*,*,0]
; => Calculate the diff. in vel.
vdiffs          = (vn - vs[0])                                 ; => [N,3,2]-Element array  {scalar version}
vdiffv          = (vo - vs2  )                                 ; => [N,3,2]-Element array  {vector version}
vdiff2[*,0,*]   = REFORM(vdiffv[*,0,*])^2 + $
                  REFORM(vdiffv[*,1,*])^2 + $
                  REFORM(vdiffv[*,2,*])^2                      ; => [N,2]-Element array
vdiff2[*,1,*]   = vdiff2[*,0,*] & vdiff2[*,2,*] = vdiff2[*,0,*]

vdfdb[*,0,*]    = REFORM(vdiffv[*,0,*])*REFORM(bo[*,0,*]) + $
                  REFORM(vdiffv[*,1,*])*REFORM(bo[*,1,*]) + $
                  REFORM(vdiffv[*,2,*])*REFORM(bo[*,2,*])
;-----------------------------------------------------------------------------------------
; => Define transverse component of solar wind velocity and magnetic field
;-----------------------------------------------------------------------------------------
vt[*,0,*]       = (nor[1]^2 + nor[2]^2)*vo[*,0,*] - nor[0]*(vo[*,1,*]*nor[1] + vo[*,2,*]*nor[2]) 
vt[*,1,*]       = (nor[0]^2 + nor[2]^2)*vo[*,1,*] - nor[1]*(vo[*,0,*]*nor[0] + vo[*,2,*]*nor[2])
vt[*,2,*]       = (nor[0]^2 + nor[1]^2)*vo[*,2,*] - nor[2]*(vo[*,0,*]*nor[0] + vo[*,1,*]*nor[1])
bt[*,0,*]       = (nor[1]^2 + nor[2]^2)*bo[*,0,*] - nor[0]*(bo[*,1,*]*nor[1] + bo[*,2,*]*nor[2]) 
bt[*,1,*]       = (nor[0]^2 + nor[2]^2)*bo[*,1,*] - nor[1]*(bo[*,0,*]*nor[0] + bo[*,2,*]*nor[2])
bt[*,2,*]       = (nor[0]^2 + nor[1]^2)*bo[*,2,*] - nor[2]*(bo[*,0,*]*nor[0] + bo[*,1,*]*nor[1])
; => Calculate the magnitude of Bt^2 for later use
bt2[*,0,*]      = REFORM(bt[*,0,*])^2 + REFORM(bt[*,1,*])^2 + REFORM(bt[*,2,*])^2
bt2[*,1,*]      = bt2[*,0,*] & bt2[*,2,*] = bt2[*,0,*]
;-----------------------------------------------------------------------------------------
; => Calculate the diff. in vel.
;-----------------------------------------------------------------------------------------
; => Define some other useful factors
ncrossVt[*,0,*] = (nor[1]*vtz - nor[2]*vty)
ncrossVt[*,1,*] = (nor[2]*vtx - nor[0]*vtz)
ncrossVt[*,2,*] = (nor[0]*vty - nor[1]*vtx)
ncrossBt[*,0,*] = (nor[1]*btz - nor[2]*bty)
ncrossBt[*,1,*] = (nor[2]*btx - nor[0]*btz)
ncrossBt[*,2,*] = (nor[0]*bty - nor[1]*btx)
;-----------------------------------------------------------------------------------------
; => Define angular gradients
;-----------------------------------------------------------------------------------------
; => Bo  . d(n)/d(phi)
bn_dn_phi[*,0,*]  = (bo[*,0,*]*dn_phi[0] + bo[*,1,*]*dn_phi[1] + bo[*,2,*]*dn_phi[2])  ; => [N,2]-Element array
bn_dn_phi[*,1,*]  = bn_dn_phi[*,0,*] & bn_dn_phi[*,2,*] = bn_dn_phi[*,0,*]
; => Bo  . d(n)/d(the)
bn_dn_the[*,0,*]  = (bo[*,0,*]*dn_the[0] + bo[*,1,*]*dn_the[1] + bo[*,2,*]*dn_the[2])  ; => [N,2]-Element array
bn_dn_the[*,1,*]  = bn_dn_the[*,0,*] & bn_dn_the[*,2,*] = bn_dn_the[*,0,*]
; => Vsw . d(n)/d(phi)
vn_dn_phi[*,0,*]  = (vo[*,0,*]*dn_phi[0] + vo[*,1,*]*dn_phi[1] + vo[*,2,*]*dn_phi[2])  ; => [N,2]-Element array
vn_dn_phi[*,1,*]  = vn_dn_phi[*,0,*] & vn_dn_phi[*,2,*] = vn_dn_phi[*,0,*]
; => Vsw . d(n)/d(the)
vn_dn_the[*,0,*]  = (vo[*,0,*]*dn_the[0] + vo[*,1,*]*dn_the[1] + vo[*,2,*]*dn_the[2])  ; => [N,2]-Element array
vn_dn_the[*,1,*]  = vn_dn_the[*,0,*] & vn_dn_the[*,2,*] = vn_dn_the[*,0,*]
; => d(Bt)/d(phi)
bt_dn_phi[*,0,*]  = -1d0*(bn*dn_phi[0] + bn_dn_phi*nor[0])
bt_dn_phi[*,1,*]  = -1d0*(bn*dn_phi[1] + bn_dn_phi*nor[1])
bt_dn_phi[*,2,*]  = -1d0*(bn*dn_phi[2] + bn_dn_phi*nor[2])
; => d(Bt)/d(the)
bt_dn_the[*,0,*]  = -1d0*(bn*dn_the[0] + bn_dn_the*nor[0])
bt_dn_the[*,1,*]  = -1d0*(bn*dn_the[1] + bn_dn_the*nor[1])
bt_dn_the[*,2,*]  = -1d0*(bn*dn_the[2] + bn_dn_the*nor[2])
; => d(Vt)/d(phi)
vt_dn_phi[*,0,*]  = -1d0*(vn*dn_phi[0] + vn_dn_phi*nor[0])
vt_dn_phi[*,1,*]  = -1d0*(vn*dn_phi[1] + vn_dn_phi*nor[1])
vt_dn_phi[*,2,*]  = -1d0*(vn*dn_phi[2] + vn_dn_phi*nor[2])
; => d(Vt)/d(the)
vt_dn_the[*,0,*]  = -1d0*(vn*dn_the[0] + vn_dn_the*nor[0])
vt_dn_the[*,1,*]  = -1d0*(vn*dn_the[1] + vn_dn_the*nor[1])
vt_dn_the[*,2,*]  = -1d0*(vn*dn_the[2] + vn_dn_the*nor[2])
; => d(n)/d(phi) x Bt
btcrdn_phi[*,0,*] = (dn_phi[1]*bt[*,2,*] - dn_phi[2]*bt[*,1,*])
btcrdn_phi[*,1,*] = (dn_phi[2]*bt[*,0,*] - dn_phi[0]*bt[*,2,*])
btcrdn_phi[*,2,*] = (dn_phi[0]*bt[*,1,*] - dn_phi[1]*bt[*,0,*])
; => d(n)/d(the) x Bt
btcrdn_the[*,0,*] = (dn_the[1]*bt[*,2,*] - dn_the[2]*bt[*,1,*])
btcrdn_the[*,1,*] = (dn_the[2]*bt[*,0,*] - dn_the[0]*bt[*,2,*])
btcrdn_the[*,2,*] = (dn_the[0]*bt[*,1,*] - dn_the[1]*bt[*,0,*])
; => d(n)/d(phi) x Vt
vtcrdn_phi[*,0,*] = (dn_phi[1]*vt[*,2,*] - dn_phi[2]*vt[*,1,*])
vtcrdn_phi[*,1,*] = (dn_phi[2]*vt[*,0,*] - dn_phi[0]*vt[*,2,*])
vtcrdn_phi[*,2,*] = (dn_phi[0]*vt[*,1,*] - dn_phi[1]*vt[*,0,*])
; => d(n)/d(the) x Vt
vtcrdn_the[*,0,*] = (dn_the[1]*vt[*,2,*] - dn_the[2]*vt[*,1,*])
vtcrdn_the[*,1,*] = (dn_the[2]*vt[*,0,*] - dn_the[0]*vt[*,2,*])
vtcrdn_the[*,2,*] = (dn_the[0]*vt[*,1,*] - dn_the[1]*vt[*,0,*])
;-----------------------------------------------------------------------------------------
; => Define relevant equation and partials
;-----------------------------------------------------------------------------------------
;dn_phi          = [    0d0, -sth[0]*sph[0],  sth[0]*cph[0] ]   ; => dn/dphi
;dn_the          = [-sth[0],  cth[0]*cph[0],  cth[0]*sph[0] ]   ; => dn/dthe

CASE eqnum OF
  1  :  BEGIN
    ; => mass flux equation [Eq. 1 from Koval and Szabo, 2008]
    eq0             = md3*vdiffs        ; => [N,3,2]-Element array
    equation        = eq0
    df_dphi         = md3*vn_dn_phi
    df_dthe         = md3*vn_dn_the
    df_dvsh         = -1d0*md3
  END
  2  :  BEGIN
    ; => Bn equation [Eq. 2 from Koval and Szabo, 2008]
    eq0             = bn              ; => [N,2]-Element array
    equation[*,0,*] = eq0
    df_dphi         = bn_dn_phi
    df_dthe         = bn_dn_the
    df_dvsh         = REPLICATE(0d0,nd,3L,2L)
  END
  3  :  BEGIN
    ; => transverse momentum flux equation [Eq. 3 from Koval and Szabo, 2008]
    equation        = md3*vdiffs*vt - (bn/muo)*bt
    ; => Define partial derivatives
    term0           = md3*((vn_dn_phi - vs[0])*vt + vdiffs*vt_dn_phi)
    term1           = (bn_dn_phi*bt + bn*bt_dn_phi)/muo
    df_dphi         = term0 - term1
    term0           = md3*((vn_dn_the - vs[0])*vt + vdiffs*vt_dn_the)
    term1           = (bn_dn_the*bt + bn*bt_dn_the)/muo
    df_dthe         = term0 - term1
    df_dvsh         = -1d0*md3*vt
  END
  4  :  BEGIN
    ; => transverse electric field equation [Eq. 4 from Koval and Szabo, 2008]
    equation        = ncrossVt*bn - vdiffs*ncrossBt
    ; => Define partial derivatives
    term0           = vtcrdn_phi*bn + ncrossVt*bn_dn_phi
    term1           = ((vn_dn_phi - vs[0])*ncrossBt) + (vdiffs*btcrdn_phi)
    df_dphi         = term0 - term1
    term0           = vtcrdn_the*bn + ncrossVt*bn_dn_the
    term1           = ((vn_dn_the - vs[0])*ncrossBt) + (vdiffs*btcrdn_the)
    df_dthe         = term0 - term1
    df_dvsh         = ncrossBt
  END
  5  :  BEGIN
    ; => normal momentum flux equation [Eq. 5 from Koval and Szabo, 2008]
    equation        = po + bt2/(2d0*muo) + md3*vdiffs^2
    ; => Define partial derivatives
    term0x          = ((bt2[*,0,*]*bt_dn_phi[*,0,*])/muo + 2d0*md3*vdiffs*vn_dn_phi[*,0,*])
    term0y          = ((bt2[*,1,*]*bt_dn_phi[*,1,*])/muo + 2d0*md3*vdiffs*vn_dn_phi[*,1,*])
    term0z          = ((bt2[*,2,*]*bt_dn_phi[*,2,*])/muo + 2d0*md3*vdiffs*vn_dn_phi[*,2,*])
    df_dphi         = term0x + term0y + term0z
    term0x          = ((bt2[*,0,*]*bt_dn_the[*,0,*])/muo + 2d0*md3*vdiffs*vn_dn_the[*,0,*])
    term0y          = ((bt2[*,1,*]*bt_dn_the[*,1,*])/muo + 2d0*md3*vdiffs*vn_dn_the[*,1,*])
    term0z          = ((bt2[*,2,*]*bt_dn_the[*,2,*])/muo + 2d0*md3*vdiffs*vn_dn_the[*,2,*])
    df_dthe         = term0x + term0y + term0z
    df_dvsh         = -2d0*md3*vdiffs
  END
  6  :  BEGIN
    ; => energy flux equation [Eq. 6 from Koval and Szabo, 2008]
    term0           = md3*vdiffs*(vdiff2/2d0 + gfactor[0]*po/md3 + bmg^2/(muo*md3))
    term1           = (bn/muo)*vdfdb
    equation        = term0 - term1
    ; => Define partial derivatives  [finish tomorrow]
    df_dphi         = 0d0
    df_dthe         = 0d0
    df_dvsh         = 0d0
  END
ENDCASE



;-----------------------------------------------------------------------------------------
; => Define partial derivatives with respect to each unknown
;-----------------------------------------------------------------------------------------
stop






END










