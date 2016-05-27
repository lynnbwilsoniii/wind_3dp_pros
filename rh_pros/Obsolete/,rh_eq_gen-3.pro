;+
;*****************************************************************************************
;
;  FUNCTION :   rh_eq_gen.pro
;  PURPOSE  :   Computes the conservation relations and the gradients with respect to
;                 the shock normal angles [azimuthal,poloidal] and the shock speed
;                 for an input set of data points.  The shock normal angles and shock
;                 normal speed in the spacecraft frame are free variables in the
;                 minimization of the merit function defined by the Rankine-Hugoniot
;                 equations from Koval and Szabo, [2008].
;
;  CALLED BY:   
;               
;
;  CALLS:
;               del_vsn.pro
;               vec_norm.pro
;               vec_trans.pro
;               vec_cross.pro
;
;  REQUIRES:    
;               
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
;               NOR0   :  [M,3]-Element unit shock normal vectors
;               VSHN0  :  [N,M]-Element array defining the shock normal
;                           velocities [m/s] in SC-frame
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               EQNUM  :  The equation number to generate
;                           1 = mass flux
;                           2 = normal B-field
;                           3 = transverse momentum flux
;                           4 = transverse E-field
;                           5 = normal momentum flux
;                           6 = energy flux
;                           [Default = 1]
;               POLYT  :  Scalar value defining the polytrope index
;                           [Default = 5/3]
;
;   CHANGED:  1)  Changed input and output format so that N RH Eqs
;                   are calculated for each shock normal vector     [09/07/2011   v1.1.0]
;             2)  Changed/Checked calculations                      [09/09/2011   v1.2.0]
;             3)  Vectorized routine and now calls rh_resize.pro and vec_cross.pro
;                                                                   [09/10/2011   v1.3.0]
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
;   CREATED:  06/21/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/10/2011   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_eq_gen,rho,vsw,mag,tot,nor0,vshn0,EQNUM=eqnum,POLYT=polyt

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
IF ~KEYWORD_SET(polyt) THEN polyti = 5d0/3d0 ELSE polyti = polyt[0]
IF ~KEYWORD_SET(eqnum) THEN eqn    = 1       ELSE eqn    = LONG(eqnum[0])
; => Make sure polytrope index is between 1-3
IF (polyti[0] LT 1d0 OR polyti[0] GT 3d0) THEN polyti = 5d0/3d0
gfactor    = polyti[0]/(polyti[0] - 1d0)
;-----------------------------------------------------------------------------------------
; => Convert input to SI units
;-----------------------------------------------------------------------------------------
; => Know these values are in the correct format from wrapping routine
nor        = nor0                 ; =>                         [M,3]-Element array
vshn       = vshn0*1d3            ; => convert to [m/s]        [N,M]-Element array
rhoud      = rho*1d6*mp[0]        ; => convert to [kg m^(-3)]  [N,2]-Element array
bo         = mag*1d-9             ; => convert to [Tesla]      [N,3,2]-Element array
vo         = vsw*1d3              ; => convert to [m/s]        [N,3,2]-Element array
te         = tot*qq[0]            ; => convert to [Joules]     [N,2]-Element array
; => Define thermal pressure { = n kB T } [Pa = N m^(-2) = J m^(-3)]
pt         = (rho*1d6)*te         ; =>                         [N,2]-Element array

m_n        = N_ELEMENTS(nor[*,0]) ; => # of shock normal vectors
nd         = N_ELEMENTS(te[*,0])  ; => # of data pairs
;-----------------------------------------------------------------------------------------
; => Define upstream/downstream values
;-----------------------------------------------------------------------------------------
rhou       = REFORM(rhoud[*,0])      ; => Mass Density      [N]-Element array
rhod       = REFORM(rhoud[*,1])      ; => Mass Density      [N]-Element array
ptup       = REFORM(pt[*,0])         ; => Thermal Pressure  [N]-Element array
ptdn       = REFORM(pt[*,1])         ; => Thermal Pressure  [N]-Element array

vou        = REFORM(vo[*,*,0],nd,3)  ; => Upstream     [N,3]-Element array
vod        = REFORM(vo[*,*,1],nd,3)  ; => Downstream   [N,3]-Element array
bou        = REFORM(bo[*,*,0],nd,3)  ; => Upstream     [N,3]-Element array
bod        = REFORM(bo[*,*,1],nd,3)  ; => Downstream   [N,3]-Element array
;-----------------------------------------------------------------------------------------
; => Calculate (V . n - Vs)
;-----------------------------------------------------------------------------------------
delv_sc    = del_vsn(vo,nor,vshn,VEC=0)      ; => [N,M,2]-Element array
delvs_up   = REFORM(delv_sc[*,*,0],nd,m_n)   ; => [N,M]-Element array
delvs_dn   = REFORM(delv_sc[*,*,1],nd,m_n)   ; => [N,M]-Element array
;-----------------------------------------------------------------------------------------
; => Calculate { Vsw . n } and { Bo . n }
;-----------------------------------------------------------------------------------------
; => { Vsw . n }
vnu        = vec_norm(vou,nor)      ; => (Vsw . n)  [upstream]    [N,M]-Element array
vnd        = vec_norm(vod,nor)      ; => (Vsw . n)  [downstream]  [N,M]-Element array
; => { Bo  . n }
bnu        = vec_norm(bou,nor)      ; => (Bo  . n)  [upstream]    [N,M]-Element array
bnd        = vec_norm(bod,nor)      ; => (Bo  . n)  [downstream]  [N,M]-Element array
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  Equation  2 terms all defined
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF (eqn[0] LE 2L) THEN GOTO,JUMP_SKIP
;-----------------------------------------------------------------------------------------
; => Calculate { (n x Vsw) x n } and { (n x Bo ) x n }
;-----------------------------------------------------------------------------------------
vtu        = vec_trans(vou,nor)      ; => (n x Vsw) x n  [upstream]    [N,M,3]-Element array
vtd        = vec_trans(vod,nor)      ; => (n x Vsw) x n  [downstream]  [N,M,3]-Element array
btu        = vec_trans(bou,nor)      ; => (n x Bo ) x n  [upstream]    [N,M,3]-Element array
btd        = vec_trans(bod,nor)      ; => (n x Bo ) x n  [downstream]  [N,M,3]-Element array
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  Equations 2, 3, and 5 terms all defined
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF (eqn[0] LE 3L OR eqn[0] EQ 5L) THEN GOTO,JUMP_SKIP
;-----------------------------------------------------------------------------------------
; => Calculate { (n x Vt) } and { (n x Bt ) }
;      [ (n x Wt) = n x {(n x W) x n} = n x W ]
;-----------------------------------------------------------------------------------------
n_x_Vtu    = REPLICATE(d,nd,m_n,3L)      ; => [N,M,3]-Element array
n_x_Vtd    = REPLICATE(d,nd,m_n,3L)
n_x_Btu    = REPLICATE(d,nd,m_n,3L)
n_x_Btd    = REPLICATE(d,nd,m_n,3L)
j          = 0L
true       = 1
WHILE(true) DO BEGIN
  vt0u           = REFORM(vtu[j,*,*],m_n,3L)
  vt0d           = REFORM(vtd[j,*,*],m_n,3L)
  n_x_Vtu[j,*,*] = vec_cross(nor,vt0u)      ; => [M,3]-Element array
  n_x_Vtd[j,*,*] = vec_cross(nor,vt0d)      ; => [M,3]-Element array
  bt0u           = REFORM(btu[j,*,*],m_n,3L)
  bt0d           = REFORM(btd[j,*,*],m_n,3L)
  n_x_Btu[j,*,*] = vec_cross(nor,bt0u)      ; => [M,3]-Element array
  n_x_Btd[j,*,*] = vec_cross(nor,bt0d)      ; => [M,3]-Element array
  IF (j LT nd - 1L) THEN true = 1 ELSE true = 0
  j             += true
ENDWHILE
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  Equations 2, 3, 4, and 5 terms all defined
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
IF (eqn[0] LE 5L) THEN GOTO,JUMP_SKIP
;-----------------------------------------------------------------------------------------
; => Calculate { V - (Vs . n) n }
;-----------------------------------------------------------------------------------------
delv_vec   = del_vsn(vo,nor,vshn,VEC=1)           ; => [N,M,3,2]-Element array
delvv_up   = REFORM(delv_vec[*,*,*,0],nd,m_n,3L)  ; => [N,M,3]-Element array
delvv_dn   = REFORM(delv_vec[*,*,*,1],nd,m_n,3L)  ; => [N,M,3]-Element array
; => Calculate { V - (Vs . n) n } . B
term0      = delvv_up[*,*,0]*(bou[*,0] # REPLICATE(1d0,m_n))
term1      = delvv_up[*,*,1]*(bou[*,1] # REPLICATE(1d0,m_n))
term2      = delvv_up[*,*,2]*(bou[*,2] # REPLICATE(1d0,m_n))
dv_dot_b_u = term0 + term1 + term2                ; => [N,M]-Element array
term0      = delvv_dn[*,*,0]*(bod[*,0] # REPLICATE(1d0,m_n))
term1      = delvv_dn[*,*,1]*(bod[*,1] # REPLICATE(1d0,m_n))
term2      = delvv_dn[*,*,2]*(bod[*,2] # REPLICATE(1d0,m_n))
dv_dot_b_d = term0 + term1 + term2                ; => [N,M]-Element array
;-----------------------------------------------------------------------------------------
; => Calculate { V - (Vs . n) n }^2/2
;-----------------------------------------------------------------------------------------
delvv_up_2 = (delvv_up[*,*,0]^2 + delvv_up[*,*,1]^2 + delvv_up[*,*,2]^2)/2d0
delvv_dn_2 = (delvv_dn[*,*,0]^2 + delvv_dn[*,*,1]^2 + delvv_dn[*,*,2]^2)/2d0
; => make sure we have the correct number of elements
delvv_up_2 = REFORM(delvv_up_2,nd,m_n)
delvv_dn_2 = REFORM(delvv_dn_2,nd,m_n)
;-----------------------------------------------------------------------------------------
; => Define relevant equation and partials
;-----------------------------------------------------------------------------------------
;=========================================================================================
JUMP_SKIP:
;=========================================================================================
dumbm      = REPLICATE(1d0,m_n)
eq0        = REPLICATE(d,nd,m_n,3L)
CASE eqn[0] OF
  1  :  BEGIN
    ; => mass flux equation [Eq. 1 from Koval and Szabo, 2008]
    facu       = rhou # dumbm                   ; => [N,M]-Element array
    facd       = rhod # dumbm                   ; => [N,M]-Element array
    term0      = facd*delvs_dn - facu*delvs_up  ; => [N,M]-Element array
    eq0[*,*,0] = term0
  END
  2  :  BEGIN
    ; => Bn equation [Eq. 2 from Koval and Szabo, 2008]
    eq0[*,*,0] = bnd - bnu
  END
  3  :  BEGIN
    ; => transverse momentum flux equation [Eq. 3 from Koval and Szabo, 2008]
    facu       = (rhou # dumbm)*delvs_up  ; => [N,M]-Element array
    facd       = (rhod # dumbm)*delvs_dn  ; => [N,M]-Element array
    ; => Define  :  rho [(V . n) - Vsh] Vt
    termux     = facu*vtu[*,*,0]                       ; => [N,M]-Element array
    termuy     = facu*vtu[*,*,1]                       ; => [N,M]-Element array
    termuz     = facu*vtu[*,*,2]                       ; => [N,M]-Element array
    termdx     = facu*vtd[*,*,0]                       ; => [N,M]-Element array
    termdy     = facu*vtd[*,*,1]                       ; => [N,M]-Element array
    termdz     = facu*vtd[*,*,2]                       ; => [N,M]-Element array
    ; => Define  :  [(B . n)/muo] Bt
    bermux     = bnu*btu[*,*,0]/muo[0]                 ; => [N,M]-Element array
    bermuy     = bnu*btu[*,*,1]/muo[0]                 ; => [N,M]-Element array
    bermuz     = bnu*btu[*,*,2]/muo[0]                 ; => [N,M]-Element array
    bermdx     = bnd*btd[*,*,0]/muo[0]                 ; => [N,M]-Element array
    bermdy     = bnd*btd[*,*,1]/muo[0]                 ; => [N,M]-Element array
    bermdz     = bnd*btd[*,*,2]/muo[0]                 ; => [N,M]-Element array
    ; => Define  :  { rho [(V . n) - Vsh] Vt } - { [(B . n)/muo] Bt }
    diff_upx   = termux - bermux
    diff_upy   = termuy - bermuy
    diff_upz   = termuz - bermuz
    diff_dnx   = termdx - bermdx
    diff_dny   = termdy - bermdy
    diff_dnz   = termdz - bermdz
    ; => Downstream - Upstream
    eq0[*,*,0] = diff_dnx - diff_upx
    eq0[*,*,1] = diff_dny - diff_upy
    eq0[*,*,2] = diff_dnz - diff_upz
  END
  4  :  BEGIN
    ; => transverse electric field equation [Eq. 4 from Koval and Szabo, 2008]
    ; => Define  :  [(B . n)] (n x Vt)
    termux     = bnu*n_x_Vtu[*,*,0]
    termuy     = bnu*n_x_Vtu[*,*,1]
    termuz     = bnu*n_x_Vtu[*,*,2]
    termdx     = bnd*n_x_Vtd[*,*,0]
    termdy     = bnd*n_x_Vtd[*,*,1]
    termdz     = bnd*n_x_Vtd[*,*,2]
    ; => Define  :  [(V . n) - Vsh] (n x Bt)
    bermux     = delvs_up*n_x_Btu[*,*,0]
    bermuy     = delvs_up*n_x_Btu[*,*,1]
    bermuz     = delvs_up*n_x_Btu[*,*,2]
    bermdx     = delvs_dn*n_x_Btd[*,*,0]
    bermdy     = delvs_dn*n_x_Btd[*,*,1]
    bermdz     = delvs_dn*n_x_Btd[*,*,2]
    ; => Define  :  { [(B . n)] (n x Vt) } - { [(V . n) - Vsh] (n x Bt) }
    diff_upx   = termux - bermux
    diff_upy   = termuy - bermuy
    diff_upz   = termuz - bermuz
    diff_dnx   = termdx - bermdx
    diff_dny   = termdy - bermdy
    diff_dnz   = termdz - bermdz
    ; => Downstream - Upstream
    eq0[*,*,0] = diff_dnx - diff_upx
    eq0[*,*,1] = diff_dny - diff_upy
    eq0[*,*,2] = diff_dnz - diff_upz
  END
  5  :  BEGIN
    ; => normal momentum flux equation [Eq. 5 from Koval and Szabo, 2008]
    ptup_2d    = (ptup # dumbm)             ; => [N,M]-Element array
    ptdn_2d    = (ptdn # dumbm)             ; => [N,M]-Element array
    ; => Define  :  rho [(V . n) - Vsh]^2
    facu       = (rhou # dumbm)*delvs_up^2  ; => [N,M]-Element array
    facd       = (rhod # dumbm)*delvs_dn^2  ; => [N,M]-Element array
    ; => Define  :  [(Bt . Bt)/(2 muo)]
    bterm_up   = (btu[*,*,0]^2 + btu[*,*,1]^2 + btu[*,*,2]^2)/(2d0*muo[0])
    bterm_dn   = (btd[*,*,0]^2 + btd[*,*,1]^2 + btd[*,*,2]^2)/(2d0*muo[0])
    ; => Define  :  P + [(Bt . Bt)/(2 muo)] + { rho [(V . n) - Vsh]^2 }
    term_up    = ptup_2d + bterm_up + facu
    term_dn    = ptdn_2d + bterm_dn + facd
    ; => Downstream - Upstream
    eq0[*,*,0] = term_dn - term_up
  END
  6  :  BEGIN
    ; => energy flux equation [Eq. 6 from Koval and Szabo, 2008]
    ptup_2d    = (ptup # dumbm)             ; => [N,M]-Element array
    ptdn_2d    = (ptdn # dumbm)             ; => [N,M]-Element array
    rhou_2d    = (rhou # dumbm)
    rhod_2d    = (rhod # dumbm)
    ; => Define  :  rho [(V . n) - Vsh]
    facu       = rhou_2d*delvs_up    ; => [N,M]-Element array
    facd       = rhod_2d*delvs_dn    ; => [N,M]-Element array
    ; => Define  :  (gamma * P)/[(gamma - 1) * rho]
    enth_up    = gfactor[0]*ptup_2d/rhou_2d
    enth_dn    = gfactor[0]*ptdn_2d/rhod_2d
    ; => Define  :  [(Bo . Bo)/(rho muo)]
    bmag_up    = (((bou[*,0]^2 + bou[*,1]^2 + bou[*,2]^2)/muo[0]) # dumbm)  ; => [N,M]-Element array
    bmag_dn    = (((bod[*,0]^2 + bod[*,1]^2 + bod[*,2]^2)/muo[0]) # dumbm)  ; => [N,M]-Element array
    bterm_up   = bmag_up/rhou_2d
    bterm_dn   = bmag_dn/rhod_2d
    ; => Define  :  [ V - (Vs . n) n ]^2/2 + (gamma * P)/[(gamma - 1) * rho] + [(Bo . Bo)/(rho muo)]
    ;            :  = energy density
    ener_up    = delvv_up_2 + enth_up + bterm_up      ; => [N,M]-Element array
    ener_dn    = delvv_dn_2 + enth_dn + bterm_dn      ; => [N,M]-Element array
    ; => Define  :  [(B . n)/muo] * {[ V - (Vs . n) n ] . Bo}
    term_up    = bnu*dv_dot_b_u/muo[0]                ; => [N,M]-Element array
    term_dn    = bnd*dv_dot_b_d/muo[0]                ; => [N,M]-Element array
    ; => Define  :  rho [(V . n) - Vsh] * (energy density)  -  [(B . n)/muo] * {[ V - (Vs . n) n ] . Bo}
    diff_up    = facu*ener_up - term_up
    diff_dn    = facd*ener_dn - term_dn
    ; => Downstream - Upstream
    eq0[*,*,0] = diff_dn - diff_up
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return value to user
;-----------------------------------------------------------------------------------------

RETURN, eq0
END
