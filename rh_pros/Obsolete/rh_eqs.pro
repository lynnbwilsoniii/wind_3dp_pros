;+
;*****************************************************************************************
;
;  FUNCTION :   rh_eqs.pro
;  PURPOSE  :   Computes the conservation relations and the gradients with respect to
;                 the shock normal angles [azimuthal,poloidal] and the shock speed
;                 for an input set of data points.  The shock normal angles and shock
;                 normal speed in the spacecraft frame are free variables in the
;                 minimization of the merit function defined by the Rankine-Hugoniot
;                 equations from Koval and Szabo, [2008].
;
;  CALLED BY:   
;               rh_func.pro
;
;  CALLS:
;               partials_rh_eqs.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               RHO    :  [N,2]-Element [up,down] array corresponding to the number
;                           density [cm^(-3)]
;               VSW    :  [N,3,2]-Element [up,down] array corresponding to the solar wind
;                           velocity vectors [SC-frame, km/s]
;               MAG    :  [N,3,2]-Element [up,down] array corresponding to the ambient
;                           magnetic field vectors [nT]
;               TOT    :  [N,2]-Element [up,down] array corresponding to the total plasma
;                           temperature [eV]
;               PHI    :  Scalar value defining the azimuthal angle [rad] of the shock
;                           normal vector [0 < phi < 2 Pi]
;               THE    :  Scalar value defining the poloidal  angle [rad] of the shock
;                           normal vector [0 < the <   Pi]
;               VSH    :  Scalar shock normal velocity [km/s] in SC-frame
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               EQNUM  :  The equation number to call from the input list.
;                           [Default = 1]
;
;   CHANGED:  1)  Changed input units for THE and PHI and
;                   now use Eq. 7 from Koval and Szabo, [2008] to determine the shock
;                   normal speed first from each data pair       [05/03/2011   v1.0.1]
;             2)  Fixed a typo in calling of partials_rh_eqs.pro for different RH Eqs
;                                                                [06/21/2011   v1.0.2]
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
;   CREATED:  05/01/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/21/2011   v1.0.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_eqs, rho, vsw, mag, tot, phi, the, vsh, EQNUM=eqnum

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

ph         = phi[0]
th         = the[0]
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
md         = REFORM(rho)*1d6*mp   ; => convert to [kg m^(-3)]  {[N,2]-Element array}
bo         = REFORM(mag)*1d-9     ; => convert to [Tesla]      {[N,3,2]-Element array}
vo         = REFORM(vsw)*1d3      ; => convert to [m/s]        {[N,3,2]-Element array}
vs         = REFORM(vsh[0])*1d3   ; => convert to [m/s]        {scalar}
te         = REFORM(tot)*qq       ; => convert to [Joules]     {[N,2]-Element array}
; => Define thermal pressure [Pa]
pt         = md/mp*te             ; => Pa = N m^(-2) = J m^(-3)
sz         = SIZE(md,/DIMENSIONS)
nd         = sz[0]                ; => # of data points

po         = REPLICATE(d,nd,3L,2L)  ; => [N,3,2]-Element version of pt {see above}
bmg        = REPLICATE(d,nd,3L,2L)  ; => [N,3,2]-Element version |B|
md3        = REPLICATE(d,nd,3L,2L)  ; => [N,3,2]-Element version md
;-----------------------------------------------------------------------------------------
; => Define scalar parameters as [N,3,2]-Element arrays
;-----------------------------------------------------------------------------------------
po[*,0,*]  = pt & po[*,1,*] = pt & po[*,2,*] = pt
; => Calculate the magnitude of the B-field for later use
bmg[*,0,*] = SQRT(bo[*,0,*]^2 + bo[*,1,*]^2 + bo[*,2,*]^2)
bmg[*,1,*] = bmg[*,0,*] & bmg[*,2,*] = bmg[*,0,*]

md3[*,0,*] = md & md3[*,1,*] = md & md3[*,2,*] = md
;-----------------------------------------------------------------------------------------
; => Define shock normal speed [SC-frame] from Eq. 7 of Koval and Szabo, [2008]
;-----------------------------------------------------------------------------------------
fac00      = (md3[*,*,1]*vo[*,*,1] - md3[*,*,0]*vo[*,*,0])   ; => [N,3]-Element array
fac11      = (md3[*,*,1] - md3[*,*,0])
fac22      = fac00/fac11                                     ; => [N,3]-Element array
vs_2       = fac22[*,0]*nor[0] + fac22[*,1]*nor[1] + fac22[*,2]*nor[2]  ; => [N]-Element array
;-----------------------------------------------------------------------------------------
; => Pre-define relevant quantities
;-----------------------------------------------------------------------------------------
vn         = REPLICATE(d,nd,3L,2L)  ; => Vsw . n
bn         = REPLICATE(d,nd,3L,2L)  ; => Bo  . n
vt         = REPLICATE(d,nd,3L,2L)  ; => (n x Vsw) x n
bt         = REPLICATE(d,nd,3L,2L)  ; => (n x Bo ) x n
ncrossVt   = REPLICATE(d,nd,3L,2L)  ; => (n x Vt) = n x [(n x Vsw) x n] = n x Vsw
ncrossBt   = REPLICATE(d,nd,3L,2L)  ; => (n x Bt) = n x [(n x Bo ) x n] = n x Bo
; => Define velocity differences and velocity parameters
vdiffvn    = REPLICATE(d,nd,3L,2L)  ; => [Vsw - Vsh] . n
vshv       = REPLICATE(d,nd,3L,2L)  ; => Vsh  = (rho2*Vsw2 - rho1*Vsw1)/(rho2 - rho1) [vector]
vshn       = REPLICATE(d,nd,3L,2L)  ; => Vshn = Vsh . n  [ Eq. 7 of Koval and Szabo, [2008] ]
vsnv       = REPLICATE(d,nd,3L,2L)  ; => (Vshn) n
vdiffv     = REPLICATE(d,nd,3L,2L)  ; => [Vsw - (Vshn) n]
vdiff2     = REPLICATE(d,nd,3L,2L)  ; => [Vsw - (Vshn) n]^2
vdfdb      = REPLICATE(d,nd,3L,2L)  ; => [Vsw - (Vshn) n] . Bo
bt2        = REPLICATE(d,nd,3L,2L)  ; => Bt . Bt
; => factors for partial derivatives
dn_phi3    = REPLICATE(d,nd,3L,2L)  ; => d(n)/d(phi)
dn_the3    = REPLICATE(d,nd,3L,2L)  ; => d(n)/d(the)
dvt_phi    = REPLICATE(d,nd,3L,2L)  ; => dVt/dphi
dvt_the    = REPLICATE(d,nd,3L,2L)  ; => dVt/dthe
dbt_phi    = REPLICATE(d,nd,3L,2L)  ; => dBt/dphi
dbt_the    = REPLICATE(d,nd,3L,2L)  ; => dBt/dthe
; => Define partial derivatives
df_dphi    = REPLICATE(d,nd,3L)     ; => d(Eq)/d(phi)
df_dthe    = REPLICATE(d,nd,3L)     ; => d(Eq)/d(the)
df_dvsh    = REPLICATE(d,nd,3L)     ; => d(Eq)/d(Vsh)
equation   = REPLICATE(d,nd,3L)     ; => Eq. of user's choice
;-----------------------------------------------------------------------------------------
; => Define shock speeds parameters
;-----------------------------------------------------------------------------------------

; => Define:  Vsh   = (rho2*Vsw2 - rho1*Vsw1)/(rho2 - rho1)  {vector}  [shock speed]
vshv[*,*,0]     = fac22 & vshv[*,*,1] = fac22  ; => [N,3,2]-Element array
; => Define:  Vshn  = Vsh . n                                {scalar}  [shock normal speed]
vshn[*,0,*]     = vshv[*,0,*]*nor[0] + vshv[*,1,*]*nor[1] + vshv[*,2,*]*nor[2]
vshn[*,1,*]     = vshn[*,0,*] & vshn[*,2,*] = vshn[*,0,*]
; => Define:  (Vshn) n                                       {vector}  [shock normal speed]
vsnv            = vshn
vsnv[*,0,*]    *= nor[0] & vsnv[*,1,*]   *= nor[1] & vsnv[*,2,*]   *= nor[2]
; => Define:  [Vsw - (Vshn) n]                               {vector}
vdiffv[*,*,0]   = (vo[*,*,0] - vsnv[*,*,0])
vdiffv[*,*,1]   = (vo[*,*,1] - vsnv[*,*,1])    ; => [N,3,2]-Element array  {vector}
; => Define:  [Vsw - Vsh] . n                                {scalar}
vdiffvn[*,*,0]  = (vo[*,*,0] - vshv[*,*,0])    ; => [N,3,2]-Element array  {scalar}
vdiffvn[*,*,1]  = (vo[*,*,1] - vshv[*,*,0])
vdiffvn[*,0,*] *= nor[0] & vdiffvn[*,1,*] *= nor[1] & vdiffvn[*,2,*] *= nor[2]
; => Define:  [Vsw - (Vshn) n]^2                             {scalar}
vdiff2[*,0,*]   = REFORM(vdiffv[*,0,*])^2 + $
                  REFORM(vdiffv[*,1,*])^2 + $
                  REFORM(vdiffv[*,2,*])^2                      ; => [N,2]-Element array
vdiff2[*,1,*]   = vdiff2[*,0,*] & vdiff2[*,2,*] = vdiff2[*,0,*]
; => Define:  [Vsw - (Vshn) n] . Bo                          {scalar}
vdfdb[*,0,*]    = vdiffv[*,0,*]*bo[*,0,*] + vdiffv[*,1,*]*bo[*,1,*] + $
                  vdiffv[*,2,*]*bo[*,2,*]
vdfdb[*,1,*]    = vdfdb[*,0,*] & vdfdb[*,2,*] = vdfdb[*,0,*]
;-----------------------------------------------------------------------------------------
; => Define normal component of solar wind velocity and magnetic field
;-----------------------------------------------------------------------------------------
vn[*,0,*]   = (vo[*,0,*]*nor[0] + vo[*,1,*]*nor[1] + vo[*,2,*]*nor[2])  ; => [N,2]-Element array
bn[*,0,*]   = (bo[*,0,*]*nor[0] + bo[*,1,*]*nor[1] + bo[*,2,*]*nor[2])
vn[*,1,*]   = vn[*,0,*] & vn[*,2,*] = vn[*,0,*]
bn[*,1,*]   = bn[*,0,*] & bn[*,2,*] = bn[*,0,*]
;-----------------------------------------------------------------------------------------
; => Define some relevant multiplicative factors
;-----------------------------------------------------------------------------------------
; => Pre-define relevant equation and partials
dn_phi3[*,*,0]  = REPLICATE(1d0,nd) # dn_phi                   ; => [N,3]-Element array
dn_phi3[*,*,1]  = dn_phi3[*,*,0]
dn_the3[*,*,0]  = REPLICATE(1d0,nd) # dn_the
dn_the3[*,*,1]  = dn_the3[*,*,0]
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
ncrossVt[*,0,*] = (nor[1]*vt[*,2,*] - nor[2]*vt[*,1,*])
ncrossVt[*,1,*] = (nor[2]*vt[*,0,*] - nor[0]*vt[*,2,*])
ncrossVt[*,2,*] = (nor[0]*vt[*,1,*] - nor[1]*vt[*,0,*])
ncrossBt[*,0,*] = (nor[1]*bt[*,2,*] - nor[2]*bt[*,1,*])
ncrossBt[*,1,*] = (nor[2]*bt[*,0,*] - nor[0]*bt[*,2,*])
ncrossBt[*,2,*] = (nor[0]*bt[*,1,*] - nor[1]*bt[*,0,*])
;-----------------------------------------------------------------------------------------
; => Define relevant equation and partials
;-----------------------------------------------------------------------------------------
CASE eqn[0] OF
  1  :  BEGIN
    ; => mass flux equation [Eq. 1 from Koval and Szabo, 2008]
    eq0             = md3*vdiffs        ; => [N,3,2]-Element array
    equation        = eq0[*,*,1] - eq0[*,*,0]
    ; => Define partial derivatives
    FOR j=0L, nd - 1L DO BEGIN
      temp = partials_rh_eqs(md[j,*],REFORM(vo[j,*,*]),REFORM(bo[j,*,*]),pt[j,*],ph[0],th[0],vs[0],EQNUM=1)
      df_dphi[j,0]  = temp.DPHI
      df_dthe[j,0]  = temp.DTHE
      df_dvsh[j,0]  = temp.DVSH
    ENDFOR
  END
  2  :  BEGIN
    ; => Bn equation [Eq. 2 from Koval and Szabo, 2008]
    eq0             = bn              ; => [N,3,2]-Element array
    equation        = eq0[*,*,1] - eq0[*,*,0]
    ; => Define partial derivatives
    FOR j=0L, nd - 1L DO BEGIN
      temp = partials_rh_eqs(md[j,*],REFORM(vo[j,*,*]),REFORM(bo[j,*,*]),pt[j,*],ph[0],th[0],vs[0],EQNUM=2)
      df_dphi[j,0]  = temp.DPHI
      df_dthe[j,0]  = temp.DTHE
      df_dvsh[j,0]  = temp.DVSH
    ENDFOR
  END
  3  :  BEGIN
    ; => transverse momentum flux equation [Eq. 3 from Koval and Szabo, 2008]
    eq0             = md3*vdiffvn*vt - (bn/muo)*bt  ; => [N,3,2]-Element array
    equation        = eq0[*,*,1] - eq0[*,*,0]
    ; => Define partial derivatives
    FOR j=0L, nd - 1L DO BEGIN
      temp = partials_rh_eqs(md[j,*],REFORM(vo[j,*,*]),REFORM(bo[j,*,*]),pt[j,*],ph[0],th[0],vs[0],EQNUM=3)
      df_dphi[j,*]  = temp.DPHI
      df_dthe[j,*]  = temp.DTHE
      df_dvsh[j,*]  = temp.DVSH
    ENDFOR
;    eq0             = md3*vdiffs*vt - (bn/muo)*bt  ; => [N,3,2]-Element array
  END
  4  :  BEGIN
    ; => transverse electric field equation [Eq. 4 from Koval and Szabo, 2008]
    eq0             = ncrossVt*bn - vdiffvn*ncrossBt  ; => [N,3,2]-Element array
    equation        = eq0[*,*,1] - eq0[*,*,0]
    ; => Define partial derivatives
    FOR j=0L, nd - 1L DO BEGIN
      temp = partials_rh_eqs(md[j,*],REFORM(vo[j,*,*]),REFORM(bo[j,*,*]),pt[j,*],ph[0],th[0],vs[0],EQNUM=4)
      df_dphi[j,*]  = temp.DPHI
      df_dthe[j,*]  = temp.DTHE
      df_dvsh[j,*]  = temp.DVSH
    ENDFOR
;    eq0             = ncrossVt*bn - vdiffs*ncrossBt  ; => [N,3,2]-Element array
  END
  5  :  BEGIN
    ; => normal momentum flux equation [Eq. 5 from Koval and Szabo, 2008]
    eq0             = po + bt2/(2d0*muo) + md3*vdiffvn^2  ; => [N,3,2]-Element array
    equation        = eq0[*,*,1] - eq0[*,*,0]
    ; => Define partial derivatives
    FOR j=0L, nd - 1L DO BEGIN
      temp = partials_rh_eqs(md[j,*],REFORM(vo[j,*,*]),REFORM(bo[j,*,*]),pt[j,*],ph[0],th[0],vs[0],EQNUM=5)
      df_dphi[j,0]  = temp.DPHI
      df_dthe[j,0]  = temp.DTHE
      df_dvsh[j,0]  = temp.DVSH
    ENDFOR
;    eq0             = po + bt2/(2d0*muo) + md3*vdiffs^2  ; => [N,3,2]-Element array
  END
  6  :  BEGIN
    ; => energy flux equation [Eq. 6 from Koval and Szabo, 2008]
    en0             = vdiff2/2d0 + gfactor[0]*po/md3 + bmg^2/(muo*md3)
    term0           = md3*vdiffvn*en0
    term1           = (bn/muo)*vdfdb
    eq0             = term0 - term1                      ; => [N,3,2]-Element array
    equation        = eq0[*,*,1] - eq0[*,*,0]
    ; => Define partial derivatives
    FOR j=0L, nd - 1L DO BEGIN
      temp = partials_rh_eqs(md[j,*],REFORM(vo[j,*,*]),REFORM(bo[j,*,*]),pt[j,*],ph[0],th[0],vs[0],EQNUM=6)
      df_dphi[j,0]  = temp.DPHI
      df_dthe[j,0]  = temp.DTHE
      df_dvsh[j,0]  = temp.DVSH
    ENDFOR
;    term0           = md3*vdiffs*(vdiff2/2d0 + gfactor[0]*po/md3 + bmg^2/(muo*md3))
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return functions and partial derivatives to user
;-----------------------------------------------------------------------------------------
struc = {FUNC:equation,PARTS:{DPHI:df_dphi,DTHE:df_dthe,DVSH:df_dvsh}}

RETURN,struc
END


;ph         = phi[0]*!DPI/18d1     ; => convert to radians
;th         = the[0]*!DPI/18d1     ; => convert to radians

;vs2        = REPLICATE(d,nd,3L,2L)  ; => (Vsh) n
;vs2        = REPLICATE(d,nd,3L,2L)  ; => (Vsh)  [ Eq. 7 of Koval and Szabo, [2008] ]
;vdiffs     = REPLICATE(d,nd,3L,2L)  ; => [(Vsw . n) - Vsh]


;vsn[*,*,0]  = vs # REPLICATE(1d0,3)
;vsn[*,*,1]  = vsn[*,*,0]
;vsn[*,0,*] *= nor[0]
;vsn[*,1,*] *= nor[1]
;vsn[*,2,*] *= nor[2]

;vs2[*,*,0]  = vs # REPLICATE(1d0,3)
;vs2[*,*,1]  = vs2[*,*,0]
;vs2[*,*,0] = REPLICATE(1d0,nd) # (vs[0]*nor)
;vs2[*,*,1] = vs2[*,*,0]

; => Calculate the diff. in vel.
;vdiffs          = (vn - vs2)                                   ; => [N,3,2]-Element array  {scalar version}
;vdiffs          = (vn - vs[0])                                ; => [N,3,2]-Element array  {scalar version}
;vdiffv          = (vo - vsn  )                                 ; => [N,3,2]-Element array  {vector version}
;vdiff2[*,0,*]   = REFORM(vdiffv[*,0,*])^2 + $
;                  REFORM(vdiffv[*,1,*])^2 + $
;                  REFORM(vdiffv[*,2,*])^2                      ; => [N,2]-Element array
;vdiff2[*,1,*]   = vdiff2[*,0,*] & vdiff2[*,2,*] = vdiff2[*,0,*]
;vdfdb[*,0,*]    = REFORM(vdiffv[*,0,*])*REFORM(bo[*,0,*]) + $
;                  REFORM(vdiffv[*,1,*])*REFORM(bo[*,1,*]) + $
;                  REFORM(vdiffv[*,2,*])*REFORM(bo[*,2,*])







