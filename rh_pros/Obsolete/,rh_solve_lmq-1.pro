;+
;*****************************************************************************************
;
;  FUNCTION :   rh_solve_lmq.pro
;  PURPOSE  :   Performs a Levenberg-Marquardt method on the Rankine-Hugoniot equations
;                 from Koval and Szabo, [2008].
;
;  CALLED BY:   
;               
;
;  CALLS:
;               rh_eq_chisq.pro
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
;               
;
;  KEYWORDS:    
;               NMAX   :  Scalar defining the maximum # of iterations to perform in
;                           Levenberg-Marquardt method
;                           [Default = 100]
;               
;
;   CHANGED:  1)  Changed input and output format so that N RH Eqs
;                   are calculated for each shock normal vector     [09/07/2011   v1.1.0]
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
;    LAST MODIFIED:  09/07/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_solve_lmq,rho,vsw,mag,tot,NMAX=nmax,POLYT=polyt

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
; => Check input
;-----------------------------------------------------------------------------------------
ni         = REFORM(rho)          ; => [N,2]-Element array
bo         = REFORM(mag)          ; => [N,3,2]-Element array
vo         = REFORM(vsw)          ; => [N,3,2]-Element array
te         = REFORM(tot)          ; => [N,2]-Element array
sz         = SIZE(ni,/DIMENSIONS)
szv        = SIZE(vo,/DIMENSIONS)
szb        = SIZE(bo,/DIMENSIONS)
nd         = sz[1]                ; => should = 2
np         = sz[0]
test       = (nd NE 2) OR (nd NE szv[2]) OR (nd NE szb[2]) OR $
             (np NE szv[0]) OR (np NE szb[0])
IF (test) THEN RETURN,d
nd         = np                   ; => # of data points
;-----------------------------------------------------------------------------------------
; => Create polar angles
;-----------------------------------------------------------------------------------------
m          = 100L
phi        = DINDGEN(m)*2d0*!DPI/(m - 1L)
;the        = DINDGEN(m)*!DPI/(m - 1L); - !DPI/2d0
the        = DINDGEN(m)*!DPI/(m - 1L) - !DPI/2d0
ph         = REFORM(phi)
th         = REFORM(the)
;-----------------------------------------------------------------------------------------
; => Generate shock normal vector
;-----------------------------------------------------------------------------------------
;            [theta, phi, 3]
nor        = DBLARR(m,m,3L)
nor[*,*,0] = COS(th) # COS(ph)
nor[*,*,1] = COS(th) # SIN(ph)
nor[*,*,2] = SIN(th) # REPLICATE(1,m)
;nor[*,*,0] = COS(th) # REPLICATE(1,m)
;nor[*,*,1] = SIN(th) # COS(ph)
;nor[*,*,2] = SIN(th) # SIN(ph)
;-----------------------------------------------------------------------------------------
; => Calculate chi-squared
;-----------------------------------------------------------------------------------------
chisq      = DBLARR(m,m)
stddv      = DBLARR(nd,m)

FOR j=0L, m - 1L DO BEGIN
  schi  = DBLARR(nd,m)
  tnor  = REFORM(nor[*,j,*])
  FOR k=0L, m - 1L DO BEGIN            ; => LBW III 09/07/2011
;  FOR k=0L, nd - 1L DO BEGIN
;    tni          = REFORM(ni[k,*])
;    tvo          = REFORM(vo[k,*,*])
;    tbo          = REFORM(bo[k,*,*])
;    tte          = REFORM(te[k,*])
    ; => Calculate shock normal speed [SC-frame] from Eq. 7 of Koval and Szabo, [2008]
;    vshn0        = vshn_calc(tni,TRANSPOSE(tvo),tnor)
    vshn0        = vshn_calc(ni,vo,REFORM(tnor[k,*]))       ; => [N]-Element array
    ; => Calculate chi-squared for k-th data point
;    tchi         = rh_eq_chisq(tni,tvo,tbo,tte,tnor,vshn0,POLYT=polyt,SIGX=sigx)
    tchi         = rh_eq_chisq(ni,vo,bo,te,REFORM(tnor[k,*]),vshn0,POLYT=polyt,SIGX=sigx)
    ; => Calculate the Std. Dev. of the chi-squared values over theta
;    schi[k,*]    = tchi/STDDEV(tchi,/NAN,/DOUBLE)^2
;    schi[k]      = TOTAL(tchi,/NAN,/DOUBLE)
;    chisq[k,j]   = TOTAL(tchi,/NAN,/DOUBLE)
    chisq[k,j]   = TOTAL(tchi,/NAN,/DOUBLE)/STDDEV(tchi,/NAN,/DOUBLE)^2
;    stddv[k,j]   = STDDEV(tchi,/NAN,/DOUBLE)
  ENDFOR
;  chisq[j,*] = TOTAL(schi,1L,/NAN)
ENDFOR


stop










END

