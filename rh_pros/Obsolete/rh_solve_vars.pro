;+
;*****************************************************************************************
;
;  FUNCTION :   rh_solve_vars.pro
;  PURPOSE  :   Performs a Levenberg-Marquardt method on the Rankine-Hugoniot equations
;                 from Koval and Szabo, [2008].
;
;  CALLED BY:   
;               
;
;  CALLS:
;               my_min_var_rot.pro
;               rh_func.pro
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
;
;  EXAMPLES:    
;               NA
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
;               NMAX   :  Scalar defining the maximum # of iterations to perform in
;                           Levenberg-Marquardt method
;                           [Default = 100]
;               PHI0   :  Scalar value defining initial guess at azimuthal angle [deg]
;                           of shock normal vector
;                           [Default = result from minimum variance analysis]
;               THE0   :  Scalar value defining initial guess at poloidal angle [deg]
;                           of shock normal vector
;                           [Default = result from minimum variance analysis]
;
;   CHANGED:  1)  Fixed manner in which one solves for delta a_k   [05/03/2011   v1.0.1]
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

FUNCTION rh_solve_vars,rho,vsw,mag,tot,SIGR=sigr,SIGV=sigv,SIGB=sigb,SIGT=sigt,$
                       NMAX=nmax,PHI0=phi0,THE0=the0

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
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
lamda0     = 0.001d0
unitmat    = [[1d0,0d0],[0d0,1d0]]
lammat     = unitmat*(1d0 + lamda0[0])
nn         = 100L
IF ~KEYWORD_SET(nmax) THEN nmax = nn ELSE nmax = LONG(nmax[0])
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
ni         = REFORM(rho)          ; => [N,2]-Element array
bo         = REFORM(mag)          ; => [N,3,2]-Element array
vo         = REFORM(vsw)          ; => [N,3,2]-Element array
te         = REFORM(tot)          ; => [N,2]-Element array
sz         = SIZE(ni,/DIMENSIONS)
nd         = sz[0]                ; => # of data points
;-----------------------------------------------------------------------------------------
; => Determine an initial guess for unknowns
;-----------------------------------------------------------------------------------------
vdiff      = vo[*,*,1] - vo[*,*,0]
vdmag      = SQRT(TOTAL(vdiff^2,2,/NAN))
vshavg     = MEAN(vdmag,/NAN)

IF (~KEYWORD_SET(phi0) OR ~KEYWORD_SET(the0)) THEN BEGIN
  ; => Perform minimum variance on magnetic field as an initial guess for shock normal
  ;      direction
  field      = [bo[*,*,0],bo[*,*,1]]
  mva        = my_min_var_rot(field,/NOMSSG)
  norm0      = mva.EIGENVECTORS[*,0]         ; => initial guess at normal in GSE
  ; => coordinates used by Koval and Szabo, [2008] correspond to:
  ;      theta = ACOS(nx)
  ;      phi   = ATAN(nz,ny)
  the0       = ACOS(norm0[0])*18d1/!DPI
  phi0       = ATAN(norm0[2],norm0[1])*18d1/!DPI
ENDIF ELSE BEGIN
  phi0       = phi0[0] MOD 36d1
  the0       = the0[0] MOD 18d1
ENDELSE
; => require:  0 < theta < 180
; => require:  0 <  phi  < 360
IF (phi0 LT 0) THEN phi0  = (phi0 + 18d1) MOD 36d1
;IF (the0 LT 0) THEN the0  = (the0 + 18d1) MOD 18d1
;-----------------------------------------------------------------------------------------
; => Find the initial chi^2, alpha, and beta
;-----------------------------------------------------------------------------------------
test0      = rh_func(ni,vo,bo,te,phi0*!DPI/18d1,the0*!DPI/18d1,vshavg, $
                     SIGR=sigr,SIGV=sigv,SIGB=sigb,SIGT=sigt)

lambda     = lamda0[0]
lammat     = unitmat*(1d0 + lambda[0])
chisq0     = test0.CHISQ
alpha0     = test0.ALPHA
beta0      = test0.BETA
vsh0       = test0.VSHN
; => Find delta a_k = [alpha]^(-1) . beta_k
dela0      = CRAMER(alpha0+lammat,beta0,/DOUBLE)
;-----------------------------------------------------------------------------------------
; => minimize chi^2, alpha, and beta
;-----------------------------------------------------------------------------------------
phi        = phi0*!DPI/18d1 + dela0[0]
the        = the0*!DPI/18d1 + dela0[1]
; => require:  0 < theta < 180
; => require:  0 <  phi  < 360
IF (the LT 0) THEN the += !DPI
IF (phi LT 0) THEN phi += 2d0*!DPI

delchi     = 1d1

chisq1     = chisq0
phi_k      = REPLICATE(d,nmax)
the_k      = REPLICATE(d,nmax)
phi_k[0]   = phi
the_k[0]   = the
alpha      = REPLICATE(d,3,3)
betak      = REPLICATE(d,3)
dela       = REPLICATE(d,3)
true       = 1
jj         = 0
gg         = 0
WHILE (true) DO BEGIN
  test  = rh_func(ni,vo,bo,te,phi[0],the[0],vshavg[0],$
                  SIGR=sigr,SIGV=sigv,SIGB=sigb,SIGT=sigt)
  tchi  = test.CHISQ
  IF (tchi GE chisq1[0]) THEN BEGIN
    lambda *= 1d1
    lammat  = unitmat*(1d0 + lambda[0])
    IF (gg EQ 0) THEN BEGIN
      alpha1  = alpha0
      betak1  = beta0
      phi1    = phi0*!DPI/18d1
      the1    = the0*!DPI/18d1
    ENDIF ELSE BEGIN
      alpha1  = alpha
      betak1  = betak
      phi1    = phi_k[gg-1L]
      the1    = the_k[gg-1L]
    ENDELSE
    ; => Re-Calculate the shifts in unknowns
    dela1     = CRAMER(alpha1+lammat,betak1,/DOUBLE)
    phi       = phi1[0] + dela1[0]
    the       = the1[0] + dela1[1]
    phi       = (phi MOD 2d0*!DPI)
    the       = (the MOD 1d0*!DPI)
    ; => now retry calculating chi^2
  ENDIF ELSE BEGIN
    ; => chi(a + da) < chi(a)
    IF (gg EQ 0) THEN BEGIN
      ; => define new defaults
      delchi    = ABS(chisq0 - tchi)
      chisq1    = tchi
    ENDIF ELSE BEGIN
      delchi    = ABS(chisq1 - tchi)
      chisq1    = tchi
    ENDELSE
    gg       += 1
    lambda   /= 1d1
    lammat    = unitmat*(1d0 + lambda[0])
    alpha     = test.ALPHA
    betak     = test.BETA
    dela0     = CRAMER(alpha+lammat,betak,/DOUBLE)
    phi       = phi[0] + dela0[0]
    the       = the[0] + dela0[1]
;    phi       = phi[0] + (dela0[0] MOD 2d0*!DPI)
;    the       = the[0] + (dela0[1] MOD !DPI)
    phi       = (phi MOD 2d0*!DPI)
    the       = (the MOD 1d0*!DPI)
    vsh0      = test.VSHN
    IF (the LT 0) THEN the += !DPI
    IF (phi LT 0) THEN phi += 2d0*!DPI
    phi_k[gg] = phi
    the_k[gg] = the
  ENDELSE
  IF (delchi LE 0.001 OR jj GT nmax) THEN true = 0 ELSE true = 1
  jj += true
  IF (true EQ 0) THEN PRINT,STRTRIM(jj,2)+' iterations performed...'
  IF (true EQ 0) THEN PRINT,STRTRIM(gg,2)+' chi^2 shifts...'
ENDWHILE
;-----------------------------------------------------------------------------------------
; => Define shock normal and Vsh
;-----------------------------------------------------------------------------------------
gnorm = [COS(the),SIN(the)*COS(phi),SIN(the)*SIN(phi)]  ; => Estimate of shock normal [input coordinates]
vsh   = vsh0[0]
;-----------------------------------------------------------------------------------------
; => Define covariance matrix
;-----------------------------------------------------------------------------------------
covmat = LA_INVERT(alpha,STATUS=stat)
IF (stat GT 0) THEN BEGIN
  ; => matrix is singular
  del_phi = d
  del_the = d
ENDIF ELSE BEGIN
  ; => found the inverse
  del_phi = (covmat[0,0] MOD 2d0*!DPI)
  del_the = (covmat[1,1] MOD !DPI)
ENDELSE
;-----------------------------------------------------------------------------------------
; => Return parameters to user
;-----------------------------------------------------------------------------------------
struc = {CHISQ:chisq0,DCHI:delchi,ALPHA:alpha,BETA:betak,DELTA_A:dela0,VSHN:vsh,$
         NVEC:gnorm,PHI_DPHI:[phi,del_phi],THE_DTHE:[the,del_the],LAMBDA:lambda}


RETURN,struc
END



;unitmat    = [[1d0,0d0,0d0],[0d0,1d0,0d0],[0d0,0d0,1d0]]
;dphi       = DINDGEN(nn)*(36d2)/(nn - 1L)
;dthe       = DINDGEN(nn)*(18d2)/(nn - 1L)
;diagal0    = [alpha0[0,0],alpha0[1,1],alpha0[2,2]]   ; => get only diagonal elements
;dela0      = [beta0[0]/(lamda0*diagal0[0]),beta0[1]/(lamda0*diagal0[1]),beta0[2]/(lamda0*diagal0[2])]
;vsh        = vshavg + dela0[2]
;    dela0   = [betak[0]/(lambda*diagal[0]),betak[1]/(lambda*diagal[1]),betak[2]/(lambda*diagal[2])]
;    vsh    += dela0[2]

;    delchi    = ABS(chisq0 - tchi)
;    chisq0    = tchi
;    alpha     = test.ALPHA
;    betak     = test.BETA

