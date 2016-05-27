;+
;*****************************************************************************************
;
;  FUNCTION :   rh_func.pro
;  PURPOSE  :   Finds the sum of the Rankine-Hugoniot equations from 
;                 Eq. 10 of Koval and Szabo, [2008].
;
;  CALLED BY:   
;               rh_solve_vars.pro
;
;  CALLS:
;               rh_eqs.pro
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
;               *************************************************************************
;               **Note:  the default is to take the standard deviation of the input
;                           data for each shock region and define each keyword element
;                           accordingly
;               *************************************************************************
;               SIGR   :  [N,2]-Element array of standard deviations corresponding to
;                           each number density data point [cm^(-3)]
;               SIGV   :  [N,3,2]-Element array of standard deviations corresponding to
;                           each solar wind velocity vector [SC-frame, km/s]
;               SIGB   :  [N,3,2]-Element array of standard deviations corresponding to
;                           each ambient magnetic field vector [nT]
;               SIGT   :  [N,2]-Element array of standard deviations corresponding to
;                           each total plasma temperature data point [eV]
;
;   CHANGED:  1)  Fixed calculation of beta_k                      [05/03/2011   v1.0.1]
;
;   NOTES:      
;               1) procedure is for the Levenberg-Marquardt method
;                  A)  beta refers to the 1st partial of the merit function
;                  B)  alpha is Hessian or curvature matrix
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
;    LAST MODIFIED:  05/03/2011   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_func, rho, vsw, mag, tot, phi, the, vsh, $
                  SIGR=sigr, SIGV=sigv, SIGB=sigb, SIGT=sigt

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
;bfac0      = 1d0/2d0
bfac0      = -1d0/2d0
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
ni         = REFORM(rho)          ; => [N,2]-Element array
bo         = REFORM(mag)          ; => [N,3,2]-Element array
vo         = REFORM(vsw)          ; => [N,3,2]-Element array
te         = REFORM(tot)          ; => [N,2]-Element array
sz         = SIZE(ni,/DIMENSIONS)
nd         = sz[0]                ; => # of data points
vs         = REFORM(vsh[0])
dumv       = REPLICATE(1d0,nd,3L,2L)
dums       = REPLICATE(1d0,nd,2L)

;IF ~KEYWORD_SET(sigr) THEN sgr = dums ELSE sgr = sigr
;IF ~KEYWORD_SET(sigv) THEN sgv = dumv ELSE sgv = sigv
;IF ~KEYWORD_SET(sigb) THEN sgb = dumv ELSE sgb = sigb
;IF ~KEYWORD_SET(sigt) THEN sgt = dums ELSE sgt = sigt
; => For now, let all uncertainties be = 10% as a test
sgr = 1d-1 & sgv = 1d-1 & sgb = 1d-1 & sgt = 1d-1
;-----------------------------------------------------------------------------------------
; => Calc. the Rankine-Hugoniot equations for given input
;-----------------------------------------------------------------------------------------
kk    = 6                                                ; => # of equations
eq2   = rh_eqs(ni,vo,bo,te,phi[0],the[0],vs[0],EQNUM=2)  ; => Bn equation [Eq. 2 from Koval and Szabo, 2008]
eq3   = rh_eqs(ni,vo,bo,te,phi[0],the[0],vs[0],EQNUM=3)  ; => transverse momentum flux equation [Eq. 3 from Koval and Szabo, 2008]
eq4   = rh_eqs(ni,vo,bo,te,phi[0],the[0],vs[0],EQNUM=4)  ; => transverse electric field equation [Eq. 4 from Koval and Szabo, 2008]
eq5   = rh_eqs(ni,vo,bo,te,phi[0],the[0],vs[0],EQNUM=5)  ; => normal momentum flux equation [Eq. 5 from Koval and Szabo, 2008]
eq6   = rh_eqs(ni,vo,bo,te,phi[0],the[0],vs[0],EQNUM=6)  ; => energy flux equation [Eq. 6 from Koval and Szabo, 2008]
;-----------------------------------------------------------------------------------------
; => Define the functional results
;-----------------------------------------------------------------------------------------
f_x2  = eq2.FUNC[*,0]
f_x3x = eq3.FUNC[*,0]
f_x3y = eq3.FUNC[*,1]
f_x3z = eq3.FUNC[*,2]
f_x4x = eq4.FUNC[*,0]
f_x4y = eq4.FUNC[*,1]
f_x4z = eq4.FUNC[*,2]
f_x5  = eq5.FUNC[*,0]
f_x6  = eq6.FUNC[*,0]
;-----------------------------------------------------------------------------------------
; => partials of Bn equation [Eq. 2 from Koval and Szabo, 2008]
;-----------------------------------------------------------------------------------------
dfx2_phi     = eq2.PARTS.DPHI[*,0]
dfx2_the     = eq2.PARTS.DTHE[*,0]
sig_eq2      = STDDEV(f_x2,/NAN)^2
; => alpha matrix terms
df2_phi_phi  = dfx2_phi^2/sig_eq2[0]
df2_the_the  = dfx2_phi^2/sig_eq2[0]
df2_phi_the  = dfx2_phi*dfx2_the/sig_eq2[0]
; => beta vector terms
beq2_phi     = (f_x2/sig_eq2[0])*dfx2_phi;*bfac0[0]
beq2_the     = (f_x2/sig_eq2[0])*dfx2_the;*bfac0[0]
;-----------------------------------------------------------------------------------------
; => partials of transverse momentum flux equation [Eq. 3 from Koval and Szabo, 2008]
;-----------------------------------------------------------------------------------------
dfx3x_phi    = eq3.PARTS.DPHI[*,0]
dfx3x_the    = eq3.PARTS.DTHE[*,0]
dfx3y_phi    = eq3.PARTS.DPHI[*,1]
dfx3y_the    = eq3.PARTS.DTHE[*,1]
dfx3z_phi    = eq3.PARTS.DPHI[*,2]
dfx3z_the    = eq3.PARTS.DTHE[*,2]
sig_eq3      = STDDEV(f_x3x,/NAN)^2 + STDDEV(f_x3y,/NAN)^2 + STDDEV(f_x3z,/NAN)^2
; => alpha matrix terms
df3_phi_phi  = (dfx3x_phi^2 + dfx3y_phi^2 + dfx3z_phi^2)/sig_eq3[0]
df3_the_the  = (dfx3x_the^2 + dfx3y_the^2 + dfx3z_the^2)/sig_eq3[0]
df3_phi_the  = (dfx3x_phi*dfx3x_the + dfx3y_phi*dfx3y_the + dfx3z_phi*dfx3z_the)/sig_eq3[0]
; => beta vector terms
beq3_phi     = ((f_x3x/sig_eq3[0])*dfx3x_phi + (f_x3y/sig_eq3[0])*dfx3y_phi + (f_x3z/sig_eq3[0])*dfx3z_phi);*bfac0[0]
beq3_the     = ((f_x3x/sig_eq3[0])*dfx3x_the + (f_x3y/sig_eq3[0])*dfx3y_the + (f_x3z/sig_eq3[0])*dfx3z_the);*bfac0[0]
;-----------------------------------------------------------------------------------------
; => partials of transverse electric field equation [Eq. 4 from Koval and Szabo, 2008]
;-----------------------------------------------------------------------------------------
dfx4x_phi    = eq4.PARTS.DPHI[*,0]
dfx4x_the    = eq4.PARTS.DTHE[*,0]
dfx4y_phi    = eq4.PARTS.DPHI[*,1]
dfx4y_the    = eq4.PARTS.DTHE[*,1]
dfx4z_phi    = eq4.PARTS.DPHI[*,2]
dfx4z_the    = eq4.PARTS.DTHE[*,2]
sig_eq4      = STDDEV(f_x4x,/NAN)^2 + STDDEV(f_x4y,/NAN)^2 + STDDEV(f_x4z,/NAN)^2
; => alpha matrix terms
df4_phi_phi  = (dfx4x_phi^2 + dfx4y_phi^2 + dfx4z_phi^2)/sig_eq4[0]
df4_the_the  = (dfx4x_the^2 + dfx4y_the^2 + dfx4z_the^2)/sig_eq4[0]
df4_phi_the  = (dfx4x_phi*dfx4x_the + dfx4y_phi*dfx4y_the + dfx4z_phi*dfx4z_the)/sig_eq4[0]
; => beta vector terms
beq4_phi     = ((f_x4x/sig_eq4[0])*dfx4x_phi + (f_x4y/sig_eq4[0])*dfx4y_phi + (f_x4z/sig_eq4[0])*dfx4z_phi);*bfac0[0]
beq4_the     = ((f_x4x/sig_eq4[0])*dfx4x_the + (f_x4y/sig_eq4[0])*dfx4y_the + (f_x4z/sig_eq4[0])*dfx4z_the);*bfac0[0]
;-----------------------------------------------------------------------------------------
; => partials of normal momentum flux equation [Eq. 5 from Koval and Szabo, 2008]
;-----------------------------------------------------------------------------------------
dfx5_phi     = eq5.PARTS.DPHI[*,0]
dfx5_the     = eq5.PARTS.DTHE[*,0]
sig_eq5      = STDDEV(f_x5,/NAN)^2
; => alpha matrix terms
df5_phi_phi  = dfx5_phi^2/sig_eq5[0]
df5_the_the  = dfx5_phi^2/sig_eq5[0]
df5_phi_the  = dfx5_phi*dfx5_the/sig_eq5[0]
; => beta vector terms
beq5_phi     = (f_x5/sig_eq5[0])*dfx5_phi;*bfac0[0]
beq5_the     = (f_x5/sig_eq5[0])*dfx5_the;*bfac0[0]
;-----------------------------------------------------------------------------------------
; => partials of energy flux equation [Eq. 6 from Koval and Szabo, 2008]
;-----------------------------------------------------------------------------------------
dfx6_phi     = eq6.PARTS.DPHI[*,0]
dfx6_the     = eq6.PARTS.DTHE[*,0]
sig_eq6      = STDDEV(f_x6,/NAN)^2
; => alpha matrix terms
df6_phi_phi  = dfx6_phi^2/sig_eq6[0]
df6_the_the  = dfx6_phi^2/sig_eq6[0]
df6_phi_the  = dfx6_phi*dfx6_the/sig_eq6[0]
; => beta vector terms
beq6_phi     = (f_x6/sig_eq6[0])*dfx6_phi;*bfac0[0]
beq6_the     = (f_x6/sig_eq6[0])*dfx6_the;*bfac0[0]
;-----------------------------------------------------------------------------------------
; => Calc. the sum
;-----------------------------------------------------------------------------------------
mg3   = (f_x3x^2 + f_x3y^2 + f_x3z^2)/sig_eq3[0]
mg4   = (f_x4x^2 + f_x4y^2 + f_x4z^2)/sig_eq4[0]
; => The sum of [ Yj(xi) - yj ]^2  {for us, yj = 0 which is the expected result}
sum   = (f_x2^2/sig_eq2[0]) + mg3 + mg4 + $
        (f_x5^2/sig_eq5[0]) + (f_x6^2/sig_eq6[0])
; => For now, assume sigma_ij = 1d0
chisq = TOTAL(sum,/NAN)
;-----------------------------------------------------------------------------------------
; => Calc. alpha_jk
;-----------------------------------------------------------------------------------------
alpha       = DBLARR(2,2)
;  (phi,phi)  (phi,the)
;  (the,phi)  (the,the)

; => Diagonal elements
df_phi_phi  = -2d0*(df2_phi_phi + df3_phi_phi + $
                    df4_phi_phi + df5_phi_phi + df6_phi_phi )
df_the_the  = -2d0*(df2_the_the + df3_the_the + $
                    df4_the_the + df5_the_the + df6_the_the )
; => Off diagonal
df_phi_the  = -2d0*(df2_phi_the + df3_phi_the + $
                    df4_phi_the + df5_phi_the + df6_phi_the )
; => sum over data points
sum_phi_phi = TOTAL(df_phi_phi,/NAN)
sum_the_the = TOTAL(df_the_the,/NAN)
sum_phi_the = TOTAL(df_phi_the,/NAN)

alpha[0,0]  = sum_phi_phi
alpha[1,1]  = sum_the_the
; => make symmetric (partials commute here)
alpha[0,1]  = sum_phi_the
alpha[1,0]  = sum_phi_the
alpha      /= 2d0

;-----------------------------------------------------------------------------------------
; => Calc. beta_j
;-----------------------------------------------------------------------------------------
beta_phi    = TOTAL(beq2_phi + beq3_phi + beq4_phi + beq5_phi + beq6_phi,/NAN)*bfac0[0]
beta_the    = TOTAL(beq2_the + beq3_the + beq4_the + beq5_the + beq6_the,/NAN)*bfac0[0]
betav       = [beta_phi,beta_the]
;-----------------------------------------------------------------------------------------
; => Calc. n = [COS(the),SIN(the)*COS(phi),SIN(the)*SIN(phi)], Vsh
;-----------------------------------------------------------------------------------------
gnorm       = [COS(the),SIN(the)*COS(phi),SIN(the)*SIN(phi)]  ; => Estimate of shock normal [GSE]
vo          = REFORM(vsw)*1d3      ; => convert to [m/s]        {[N,3,2]-Element array}
md          = REFORM(rho)*1d6*mp   ; => convert to [kg m^(-3)]  {[N,2]-Element array}
md3         = REPLICATE(d,nd,3L,2L)                           ; => [N,3,2]-Element version md
md3[*,0,*]  = md & md3[*,1,*] = md & md3[*,2,*] = md

fac00       = (md3[*,*,1]*vo[*,*,1] - md3[*,*,0]*vo[*,*,0])   ; => [N,3]-Element array
fac11       = (md3[*,*,1] - md3[*,*,0])
fac22       = fac00/fac11                                     ; => [N,3]-Element array
vs_2        = fac22[*,0]*gnorm[0] + fac22[*,1]*gnorm[1] + fac22[*,2]*gnorm[2]  ; => [N]-Element array
dvsh        = STDDEV(vs_2,/NAN)^2
fac0        = vs_2/dvsh[0]/(1d0*nd)
;fac0        = vs_2/dvsh[0]/(1d0/(nd*dvsh[0]))
vsh_g       = TOTAL(fac0,/NAN)*dvsh[0]                        ; => Eq. 9 from Koval and Szabo, [2008]
;-----------------------------------------------------------------------------------------
; => Return values to user
;-----------------------------------------------------------------------------------------
struc = {CHISQ:chisq,ALPHA:alpha,BETA:betav,VSHN:vsh_g}

RETURN,struc
END

;eq1   = rh_eqs(ni,vo,bo,te,phi[0],the[0],vs[0],EQNUM=1)  ; => mass flux equation [Eq. 1 from Koval and Szabo, 2008]
;f_x1  = eq1.FUNC[*,0]

;-----------------------------------------------------------------------------------------
; => partials of mass flux equation [Eq. 1 from Koval and Szabo, 2008]
;-----------------------------------------------------------------------------------------
;dfx1_phi     = eq1.PARTS.DPHI[*,0]
;dfx1_the     = eq1.PARTS.DTHE[*,0]
;dfx1_vsh     = eq1.PARTS.DVSH[*,0]
;sig_eq1      = STDDEV(f_x1,/NAN)^2
; => alpha matrix terms
;df1_phi_phi  = dfx1_phi^2/sig_eq1[0]
;df1_the_the  = dfx1_phi^2/sig_eq1[0]
;df1_vsh_vsh  = dfx1_phi^2/sig_eq1[0]
;df1_phi_the  = dfx1_phi*dfx1_the/sig_eq1[0]
;df1_phi_vsh  = dfx1_phi*dfx1_vsh/sig_eq1[0]
;df1_the_vsh  = dfx1_the*dfx1_vsh/sig_eq1[0]
; => beta vector terms
;beq1_phi     = (f_x1/sig_eq1[0])*dfx1_phi*bfac0[0]
;beq1_the     = (f_x1/sig_eq1[0])*dfx1_the*bfac0[0]
;beq1_vsh     = (f_x1/sig_eq1[0])*dfx1_vsh*bfac0[0]

;dfx2_vsh     = eq2.PARTS.DVSH[*,0]
;df2_vsh_vsh  = dfx2_phi^2/sig_eq2[0]
;df2_phi_vsh  = dfx2_phi*dfx2_vsh/sig_eq2[0]
;df2_the_vsh  = dfx2_the*dfx2_vsh/sig_eq2[0]
;beq2_vsh     = (f_x2/sig_eq2[0])*dfx2_vsh*bfac0[0]

;dfx3z_vsh    = eq3.PARTS.DVSH[*,2]
;dfx3y_vsh    = eq3.PARTS.DVSH[*,1]
;dfx3x_vsh    = eq3.PARTS.DVSH[*,0]
;df3_vsh_vsh  = (dfx3x_vsh^2 + dfx3y_vsh^2 + dfx3z_vsh^2)/sig_eq3[0]
;df3_phi_vsh  = (dfx3x_phi*dfx3x_vsh + dfx3y_phi*dfx3y_vsh + dfx3z_phi*dfx3z_vsh)/sig_eq3[0]
;df3_the_vsh  = (dfx3x_the*dfx3x_vsh + dfx3y_the*dfx3y_vsh + dfx3z_the*dfx3z_vsh)/sig_eq3[0]
;beq3_vsh     = ((f_x3x/sig_eq3[0])*dfx3x_vsh + (f_x3y/sig_eq3[0])*dfx3y_vsh + (f_x3z/sig_eq3[0])*dfx3z_vsh)*bfac0[0]

;beq4_vsh     = ((f_x4x/sig_eq4[0])*dfx4x_vsh + (f_x4y/sig_eq4[0])*dfx4y_vsh + (f_x4z/sig_eq4[0])*dfx4z_vsh)*bfac0[0]
;dfx4x_vsh    = eq4.PARTS.DVSH[*,0]
;dfx4y_vsh    = eq4.PARTS.DVSH[*,1]
;dfx4z_vsh    = eq4.PARTS.DVSH[*,2]
;df4_vsh_vsh  = (dfx4x_vsh^2 + dfx4y_vsh^2 + dfx4z_vsh^2)/sig_eq4[0]
;df4_phi_vsh  = (dfx4x_phi*dfx4x_vsh + dfx4y_phi*dfx4y_vsh + dfx4z_phi*dfx4z_vsh)/sig_eq4[0]
;df4_the_vsh  = (dfx4x_the*dfx4x_vsh + dfx4y_the*dfx4y_vsh + dfx4z_the*dfx4z_vsh)/sig_eq4[0]

;beq5_vsh     = (f_x5/sig_eq5[0])*dfx5_vsh*bfac0[0]
;dfx5_vsh     = eq5.PARTS.DVSH[*,0]
;df5_vsh_vsh  = dfx5_phi^2/sig_eq5[0]
;df5_phi_vsh  = dfx5_phi*dfx5_vsh/sig_eq5[0]
;df5_the_vsh  = dfx5_the*dfx5_vsh/sig_eq5[0]

;beq6_vsh     = (f_x6/sig_eq6[0])*dfx6_vsh*bfac0[0]
;dfx6_vsh     = eq6.PARTS.DVSH[*,0]
;df6_vsh_vsh  = dfx6_phi^2/sig_eq6[0]
;df6_phi_vsh  = dfx6_phi*dfx6_vsh/sig_eq6[0]
;df6_the_vsh  = dfx6_the*dfx6_vsh/sig_eq6[0]

;sum   = (f_x1^2/sig_eq1[0]) + (f_x2^2/sig_eq2[0]) + mg3 + mg4 + $
;        (f_x5^2/sig_eq5[0]) + (f_x6^2/sig_eq6[0])

;---------------------------------------------------------------
;alpha       = DBLARR(3,3)
;  (phi,phi)  (phi,the)  (phi,vsh)
;  (the,phi)  (the,the)  (the,vsh)
;  (vsh,phi)  (vsh,the)  (vsh,vsh)
; => Diagonal elements
;df_phi_phi  = 2d0*(df1_phi_phi + df2_phi_phi + df3_phi_phi + $
;                   df4_phi_phi + df5_phi_phi + df6_phi_phi )
;df_the_the  = 2d0*(df1_the_the + df2_the_the + df3_the_the + $
;                   df4_the_the + df5_the_the + df6_the_the )
;df_vsh_vsh  = 2d0*(df1_vsh_vsh + df2_vsh_vsh + df3_vsh_vsh + $
;                   df4_vsh_vsh + df5_vsh_vsh + df6_vsh_vsh )
; => Off diagonal
;df_phi_the  = 2d0*(df1_phi_the + df2_phi_the + df3_phi_the + $
;                   df4_phi_the + df5_phi_the + df6_phi_the )
;df_phi_vsh  = 2d0*(df1_phi_vsh + df2_phi_vsh + df3_phi_vsh + $
;                   df4_phi_vsh + df5_phi_vsh + df6_phi_vsh )
;df_the_vsh  = 2d0*(df1_the_vsh + df2_the_vsh + df3_the_vsh + $
;                   df4_the_vsh + df5_the_vsh + df6_the_vsh )
; => sum over data points
;sum_phi_phi = TOTAL(df_phi_phi,/NAN)
;sum_the_the = TOTAL(df_the_the,/NAN)
;sum_vsh_vsh = TOTAL(df_vsh_vsh,/NAN)
;sum_phi_the = TOTAL(df_phi_the,/NAN)
;sum_phi_vsh = TOTAL(df_phi_vsh,/NAN)
;sum_the_vsh = TOTAL(df_the_vsh,/NAN)
;alpha[0,0]  = sum_phi_phi
;alpha[1,1]  = sum_the_the
;alpha[2,2]  = sum_vsh_vsh
;alpha[0,1]  = sum_phi_the
;alpha[0,2]  = sum_phi_vsh
;alpha[1,2]  = sum_the_vsh
; => make symmetric (partials commute here)
;alpha[1,0]  = sum_phi_the
;alpha[2,0]  = sum_phi_vsh
;alpha[2,1]  = sum_the_vsh
;alpha      /= 2d0
;---------------------------------------------------------------

;beta_phi    = TOTAL(beq1_phi + beq2_phi + beq3_phi + beq4_phi + beq5_phi + beq6_phi,/NAN)
;beta_the    = TOTAL(beq1_the + beq2_the + beq3_the + beq4_the + beq5_the + beq6_the,/NAN)
;beta_vsh    = TOTAL(beq1_vsh + beq2_vsh + beq3_vsh + beq4_vsh + beq5_vsh + beq6_vsh,/NAN)
;betav       = [beta_phi,beta_the,beta_vsh]


;FOR i=0L, nd - 1L DO BEGIN
;  FOR j=0L, kk - 1L DO BEGIN
;    k   = j + 1
;  ENDFOR
;ENDFOR
