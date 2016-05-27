;+
;*****************************************************************************************
;
;  FUNCTION :   generate_rh_eq.pro
;  PURPOSE  :   Produces the RH equations from a set of input data.
;
;  CALLED BY:   
;               rh_eq_solve.pro
;
;  CALLS:
;               my_dot_prod.pro
;               my_crossp_2.pro
;               
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DENS   :  [N,2]-Element array of densities [cm^(-3)]
;               MAGF   :  [N,3,2]-Element array of B-field vectors [nT]
;               VSW    :  [N,3,2]-Element array of solar wind velocity vectors [km/s]
;               GNORM  :  [M,M,3]-Element array of shock normal vectors
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               TEMPK  :  [N,2]-Element array of temperatures (eV)
;
;   CHANGED:  1)  Continued work on writing the routine          [04/27/2011   v1.0.0]
;
;   NOTES:      
;               1)  VS = Vinas and Scudder, [1986] JGR Vol. 91
;               2)  User should not call this routine independently.
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
;   CREATED:  04/26/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/27/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION generate_rh_eq,dens,magf,vsw,gnorm,TEMPK=tempk

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
muo        = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
K_eV       = 1.160474d4        ; => Conversion = degree Kelvin/eV
kB         = 1.3806504d-23     ; => Boltzmann Constant (J/K)
qq         = 1.60217733d-19    ; => Fundamental charge (C) [or = J/eV]
polyti     = 5d0/3d0           ; => Polytrope index
gfactor    = polyti[0]/(polyti[0] - 1d0)
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 4) THEN RETURN,0
n_i        = REFORM(dens)*1d6     ; => convert to [m^(-3)]
bo         = REFORM(magf)*1d-9    ; => convert to [T]
vo         = REFORM(vsw)*1d3      ; => convert to [m/s]
nv         = REFORM(gnorm)        ; => shock normal unit vectors
szd        = SIZE(n_i,/DIMENSIONS)
szb        = SIZE(bo,/DIMENSIONS)
szv        = SIZE(vo,/DIMENSIONS)
szn        = SIZE(nv,/DIMENSIONS)
nd         = szd[0]               ; => # of data points on either side of shock
nn         = szn[0]               ; => # of angular bins used to construct dummy n-vector

IF KEYWORD_SET(tempk) THEN BEGIN
  to   = REFORM(tempk)*qq         ; => Convert to Joules
  szt  = SIZE(to,/DIMENSIONS)
  IF (szt[0] EQ nd AND szt[1] EQ 2 AND N_ELEMENTS(szt) EQ 2) THEN BEGIN
    po   = n_i*to     ; => kinetic pressure [Pa]
    pp   = 1
  ENDIF ELSE BEGIN
    pp   = 0
    po   = REPLICATE(d,nd,2L)
  ENDELSE
ENDIF ELSE BEGIN
  pp   = 0
  po   = REPLICATE(d,nd,2L)
ENDELSE

n_iu       = n_i[*,0]     ; => [ND]-Element    array of upstream   densities
n_id       = n_i[*,1]     ; => [ND]-Element    array of downstream densities
bo_u       = bo[*,*,0]    ; => [ND,3L]-Element array of upstream   B-field vectors
bo_d       = bo[*,*,1]    ; => [ND,3L]-Element array of downstream B-field vectors
vo_u       = vo[*,*,0]    ; => [ND,3L]-Element array of upstream   solar wind velocity vectors
vo_d       = vo[*,*,1]    ; => [ND,3L]-Element array of downstream solar wind velocity vectors
po_u       = po[*,0]      ; => [ND]-Element array of upstream   kinetic pressures
po_d       = po[*,1]      ; => [ND]-Element array of downstream kinetic pressures
;-----------------------------------------------------------------------------------------
; => first create an array of possible shock speeds
;-----------------------------------------------------------------------------------------
vshn = REPLICATE(d,nd,nn,nn)  ; => Eq. 7 [Koval and Szabo, 2008]
; => ND  : # of data points
; => NN  : # of azimuthal angles [phi   for 1st NN]
; => NN  : # of poloidal  angles [theta for 2nd NN]
stvs = REPLICATE(d,nd,nn)     ; => Standard Deviation of VSHN when 
FOR j=0L, nn - 1L DO BEGIN
  norm00   = REFORM(nv[j,*,*])  ; => [N,3]-Element array
  FOR k=0L, nd - 1L DO BEGIN
    del0        = (n_id[k]*REFORM(vo_d[k,*]) - n_iu[k]*REFORM(vo_u[k,*]))  ; => [3]-Element array
    dot00       = my_dot_prod(del0,norm00,/NOM)/(n_id[k] - n_iu[k])        ; => [NN]-Element array
    vshn[k,j,*] = dot00
    stvs[k,j]   = STDDEV(dot00,/NAN,/DOUBLE)
  ENDFOR
ENDFOR
;-----------------------------------------------------------------------------------------
; => Construct equations
;-----------------------------------------------------------------------------------------
eq1  = REPLICATE(d,nd,nn,nn)      ; => [rho*(Vn - Vsh)] = 0
eq2    = REPLICATE(d,nd,nn,nn)    ; => [B dot n] = 0
eq3    = REPLICATE(d,nd,nn,nn,3)  ; => [rho*Un*Ut - Bn*Bt/muo] = 0
eq4    = REPLICATE(d,nd,nn,nn,3)  ; => [(n x Vt)*Bn - Un*(n x Bt)] = 0
eq5    = REPLICATE(d,nd,nn,nn)    ; => [P + Bt^2/(2*muo) + rho*Un^2] = 0
eq6    = REPLICATE(d,nd,nn,nn)    ; => [rho*Un*(Un^2/2 + e + wb) - Bn*(Un dot B)/muo] = 0 {e = enthalpy, wb = magnetic energy density}

stdeq1 = REPLICATE(d,nd,nn)       ; => Std. Dev. of Eq. 1
stdeq2 = REPLICATE(d,nd,nn)       ; => Std. Dev. of Eq. 2
stdeq3 = REPLICATE(d,nd,nn,3)     ; => Std. Dev. of Eq. 3
stdeq4 = REPLICATE(d,nd,nn,3)     ; => Std. Dev. of Eq. 4
stdeq5 = REPLICATE(d,nd,nn)       ; => Std. Dev. of Eq. 5
stdeq6 = REPLICATE(d,nd,nn)       ; => Std. Dev. of Eq. 6
FOR j=0L, nn - 1L DO BEGIN
  norm00   = REFORM(nv[j,*,*])  ; => [NN,3]-Element array
  FOR k=0L, nd - 1L DO BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Define parameters
    ;-------------------------------------------------------------------------------------
    vshn0          = REFORM(vshn[k,j,*])  ; => [NN]-Element array of possible shock speeds
    vsw_u          = REFORM(vo_u[k,*])    ; => Upstream   velocity [3]-Element array
    vsw_d          = REFORM(vo_d[k,*])    ; => Downstream velocity [3]-Element array
    magf_u         = REFORM(bo_u[k,*])    ; => Upstream   B-field " "
    magf_d         = REFORM(bo_d[k,*])    ; => Downstream B-field " "
    ; => Define the normal components of vectors
    ;      [_n = (vector) dot (normal vector)]
    vnu0           = my_dot_prod(norm00,vsw_u,/NOM)   ; => [NN]-Element array
    vnd0           = my_dot_prod(norm00,vsw_d,/NOM)   ; => [NN]-Element array
    bnu0           = my_dot_prod(norm00,magf_u,/NOM)  ; => [NN]-Element array
    bnd0           = my_dot_prod(norm00,magf_d,/NOM)  ; => [NN]-Element array
    ; => Define the transverse vectors
    ;      [_t = [(normal vector) x (vector)] x (normal vector)]
    vtu0           = my_crossp_2(my_crossp_2(norm00,vsw_u,/NOM),norm00,/NOM)   ; => [NN,3]-Element array
    vtd0           = my_crossp_2(my_crossp_2(norm00,vsw_d,/NOM),norm00,/NOM)   ; => [NN,3]-Element array
    btu0           = my_crossp_2(my_crossp_2(norm00,magf_u,/NOM),norm00,/NOM)  ; => [NN,3]-Element array
    btd0           = my_crossp_2(my_crossp_2(norm00,magf_d,/NOM),norm00,/NOM)  ; => [NN,3]-Element array
    ;-------------------------------------------------------------------------------------
    ; => Define some useful factors commonly used in RH relations
    ;-------------------------------------------------------------------------------------
    ; 1st factor = [rho*(Vn - Vsh)]
    tempu1         = ((vnu0 - vshn0) # REPLICATE(1d0,3))  ; => [NN,3]-Element array
    tempd1         = ((vnd0 - vshn0) # REPLICATE(1d0,3))  ; => [NN,3]-Element array
    ; 2nd factor = (n x Vt)
    ncrVtu         = my_crossp_2(norm00,vtu0,/NOM)                ; => [NN,3]-Element array
    ncrVtd         = my_crossp_2(norm00,vtd0,/NOM)                ; => [NN,3]-Element array
    ; 3rd factor = (n x Bt)
    ncrBtu         = my_crossp_2(norm00,btu0,/NOM)                ; => [NN,3]-Element array
    ncrBtd         = my_crossp_2(norm00,btd0,/NOM)                ; => [NN,3]-Element array
    ; 4th factor = Bn/muo
    Bnmuu          = ((bnu0/muo) # REPLICATE(1d0,3))              ; => [NN,3]-Element array
    Bnmud          = ((bnd0/muo) # REPLICATE(1d0,3))              ; => [NN,3]-Element array
    ; 5th factor = make VSHN an [NN,3]-Element array for vectorization
    vshn3          = vshn0 # REPLICATE(1d0,3)                     ; => [NN,3]-Element array
    ; 6th factor = Bt^2/(2 muo)
    Bt2muu         = (my_dot_prod(btu0,btu0,/NOM))/(2d0*muo)      ; => [NN]-Element array
    Bt2mud         = (my_dot_prod(btd0,btd0,/NOM))/(2d0*muo)      ; => [NN]-Element array
    ; 7th factor = (V - Vs n) [NN,3]-Element array
    V_Vsnu         = DBLARR(nn,3L)
    V_Vsnd         = DBLARR(nn,3L)
    V_Vsnu[*,0]    = (vsw_u[0] - vshn0*norm00[*,0])
    V_Vsnu[*,1]    = (vsw_u[1] - vshn0*norm00[*,1])
    V_Vsnu[*,2]    = (vsw_u[2] - vshn0*norm00[*,2])
    V_Vsnd[*,0]    = (vsw_d[0] - vshn0*norm00[*,0])
    V_Vsnd[*,1]    = (vsw_d[1] - vshn0*norm00[*,1])
    V_Vsnd[*,2]    = (vsw_d[2] - vshn0*norm00[*,2])
    ;-------------------------------------------------------------------------------------
    ; => Define Eq. 1
    ;-------------------------------------------------------------------------------------
    eq1[k,j,*]   = (n_id[k]*tempd1[*,0] - n_iu[k]*tempu1[*,0])
    stdeq1[k,j]  = STDDEV(eq1[k,j,*],/NAN,/DOUBLE)
    ;-------------------------------------------------------------------------------------
    ; => Define Eq. 2
    ;-------------------------------------------------------------------------------------
    eq2[k,j,*]   = (bnd0 - bnu0)
    stdeq2[k,j]  = STDDEV(eq2[k,j,*],/NAN,/DOUBLE)
    ;-------------------------------------------------------------------------------------
    ; => Define Eq. 3
    ;-------------------------------------------------------------------------------------
    eq3u          = (n_iu[k]*tempu1*vtu0) - (Bnmuu*btu0)
    eq3d          = (n_id[k]*tempd1*vtd0) - (Bnmud*btd0)
    eq3[k,j,*,*]  = (eq3d - eq3u)                  ; => [NN,3]-Element array
    stdeq3[k,j,0] = STDDEV((eq3d[*,0] - eq3u[*,0]),/NAN,/DOUBLE)
    stdeq3[k,j,1] = STDDEV((eq3d[*,1] - eq3u[*,1]),/NAN,/DOUBLE)
    stdeq3[k,j,2] = STDDEV((eq3d[*,2] - eq3u[*,2]),/NAN,/DOUBLE)
    ;-------------------------------------------------------------------------------------
    ; => Define Eq. 4
    ;-------------------------------------------------------------------------------------
    eq4u          = (ncrVtu*(Bnmuu*muo)) - (tempu1*ncrBtu)
    eq4d          = (ncrVtd*(Bnmud*muo)) - (tempd1*ncrBtd)
    eq4[k,j,*,*]  = (eq4d - eq4u)                  ; => [NN,3]-Element array
    stdeq4[k,j,0] = STDDEV((eq4d[*,0] - eq4u[*,0]),/NAN,/DOUBLE)
    stdeq4[k,j,1] = STDDEV((eq4d[*,1] - eq4u[*,1]),/NAN,/DOUBLE)
    stdeq4[k,j,2] = STDDEV((eq4d[*,2] - eq4u[*,2]),/NAN,/DOUBLE)
    ;-------------------------------------------------------------------------------------
    ; => If supplied, then determine the normal momentum and energy conservation relations
    ;-------------------------------------------------------------------------------------
    IF (pp) THEN BEGIN
      ;-----------------------------------------------------------------------------------
      ; => Define Eq. 5
      ;-----------------------------------------------------------------------------------
      eq5u        = po_u[k] + Bt2muu + n_iu[k]*(tempu1[*,0]^2)
      eq5d        = po_d[k] + Bt2mud + n_id[k]*(tempd1[*,0]^2)
      eq5[k,j,*]  = (eq5d - eq5u)                                      ; => [NN]-Element array
      stdeq5[k,j] = STDDEV(eq5[k,j,*],/NAN,/DOUBLE)
      ;-----------------------------------------------------------------------------------
      ; => Define Eq. 6
      ;-----------------------------------------------------------------------------------
      pressu      = (gfactor[0]*po_u[k] + TOTAL(magf_u^2,/NAN)/muo )/(n_iu[k])  ; => Scalar
      pressd      = (gfactor[0]*po_d[k] + TOTAL(magf_d^2,/NAN)/muo )/(n_id[k])  ; => Scalar
      first_u     = n_iu[k]*tempu1[*,0]*(my_dot_prod(V_Vsnu,V_Vsnu,/NOM)/2d0 + pressu[0])  ; => [NN]-Element array
      first_d     = n_id[k]*tempd1[*,0]*(my_dot_prod(V_Vsnd,V_Vsnd,/NOM)/2d0 + pressd[0])  ; => [NN]-Element array
      secondu     = Bnmuu[*,0]*my_dot_prod(V_Vsnu,magf_u,/NOM)                             ; => [NN]-Element array
      secondd     = Bnmud[*,0]*my_dot_prod(V_Vsnd,magf_d,/NOM)                             ; => [NN]-Element array
      eq6u        = (first_u - secondu)
      eq6d        = (first_d - secondd)
      eq6[k,j,*]  = (eq6d - eq6u)
      stdeq6[k,j] = STDDEV(eq6[k,j,*],/NAN,/DOUBLE)
    ENDIF
  ENDFOR
ENDFOR
;-----------------------------------------------------------------------------------------
; => Return equations to user
;-----------------------------------------------------------------------------------------
tags = 'STDEV_'+['VSHN','EQ1','EQ2','EQ3','EQ4','EQ5','EQ6']
stds = CREATE_STRUCT(tags,stvs,stdeq1,stdeq2,stdeq3,stdeq4,stdeq5,stdeq6)
tags = ['VSHN','EQ1','EQ2','EQ3','EQ4','EQ5','EQ6']
eqs  = CREATE_STRUCT(tags,vshn,eq1,eq2,eq3,eq4,eq5,eq6)
stru = CREATE_STRUCT(['EQS','STDEVS'],eqs,stds)

RETURN,stru
END