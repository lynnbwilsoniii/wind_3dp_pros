;+
;*****************************************************************************************
;
;  FUNCTION :   rh_eq_chisq.pro
;  PURPOSE  :   This routine is a wrapper for rh_eq_gen.pro and allows the user to
;                 defined which equations to sum over to calculate the merit function.
;
;  CALLED BY:   
;               rh_solve_lmq.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               rh_resize.pro
;               rh_eq_gen.pro
;
;  REQUIRES:    
;               1)  LBW's Rankine-Hugoniot Analysis Library
;
;  INPUT:
;               RHO     :  [N,2]-Element [numeric] array corresponding to the number
;                            density [cm^(-3)] for upstream and downstream
;               VSW     :  [N,3,2]-Element [numeric] array corresponding to the solar wind
;                            velocity vectors [SC-frame, km/s] for upstream and downstream
;               MAG     :  [N,3,2]-Element [numeric] array corresponding to the ambient
;                            magnetic field vectors [nT] for upstream and downstream
;               TOT     :  [N,2]-Element [numeric] array corresponding to the total plasma
;                            temperature [eV] for upstream and downstream
;               NOR0    :  [M,3]-Element [numeric] unit shock normal vectors
;               VSHN0   :  [N,M]-Element [numeric] array defining the shock normal velocities
;                            [km/s] in SC-frame
;
;  EXAMPLES:    
;               [calling sequence]
;               rhcsq = rh_eq_chisq(rho,vsw,mag,tot,nor0,vshn0 [,POLYT=polyt] [,VSHOCK=vshock] [,SIGX=sigx] [,NEQS=neqs])
;
;  KEYWORDS:    
;               POLYT   :  Scalar [numeric] value defining the polytrope index
;                            [Default = 5/3]
;               VSHOCK  :  Set to a named variable to return the shock normal speeds
;               SIGX    :  Set to a named variable to return the standard
;                            deviations of the solved equations
;               NEQS    :  [5]-Element [integer] array defining which equations to use in
;                            the solution { Eq. 2, Eq. 3, Eq. 4, Eq. 5, Eq. 6 }
;                            [Default = [1,1,1,1,1] or use all]
;
;   CHANGED:  1)  Changed input and output format so that N RH Eqs
;                   are calculated for each shock normal vector
;                                                                   [09/07/2011   v1.1.0]
;             2)  Added keyword:  NEQS
;                                                                   [09/09/2011   v1.2.0]
;             3)  Vectorized routine and now calls rh_resize.pro
;                                                                   [09/10/2011   v1.3.0]
;             4)  Fixed typo in man page
;                                                                   [09/12/2011   v1.3.1]
;             5)  Updated man page now that subroutines are standalone
;                                                                   [07/11/2012   v1.4.0]
;             6)  Cleaned up, updated Man. page, and optimized
;                                                                   [08/28/2020   v1.4.1]
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
;    LAST MODIFIED:  08/28/2020   v1.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_eq_chisq,rho,vsw,mag,tot,nor0,vshn0,POLYT=polyt,VSHOCK=vshock,SIGX=sigx,NEQS=neqs

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Know these values are in the correct format from wrapping routine
ni             = rho                               ;;  [N,2]-Element array
bo             = mag                               ;;  [N,3,2]-Element array
vo             = vsw                               ;;  [N,3,2]-Element array
te             = tot                               ;;  [N,2]-Element array
n_v            = N_ELEMENTS(te[*,0])
;;  Check shock normal vector dimensions
n1             = nor0
rh_resize,NOR=n1,MNOR=m_n                          ;;  [M,3]-Element array
test           = TOTAL(FINITE([n_v,m_n]),/NAN) NE 2
IF (test) THEN RETURN,d
nor            = n1                                ;;  [M,3]-Element array
;;  Check shock normal speed dimensions
vs1            = vshn0
rh_resize,VSH=vs1,NPTS=n_v,MNOR=m_n                ;;  [N,M]-Element array
test           = TOTAL(FINITE([n_v,m_n]),/NAN) NE 2
IF (test) THEN RETURN,d
vshn           = vs1                               ;;  [N,M]-Element array
;;----------------------------------------------------------------------------------------
;;  Calc. the Rankine-Hugoniot equations for given input
;;----------------------------------------------------------------------------------------
;;  rh_eq_gen.pro returns [N,M,3L]-Element arrays
eq2            = rh_eq_gen(ni,vo,bo,te,nor,vshn,EQNUM=2,POLYT=polyt)  ;;  Bn equation [Eq. 2 from Koval and Szabo, 2008]
eq3            = rh_eq_gen(ni,vo,bo,te,nor,vshn,EQNUM=3,POLYT=polyt)  ;;  transverse momentum flux equation [Eq. 3 from Koval and Szabo, 2008]
eq4            = rh_eq_gen(ni,vo,bo,te,nor,vshn,EQNUM=4,POLYT=polyt)  ;;  transverse electric field equation [Eq. 4 from Koval and Szabo, 2008]
eq5            = rh_eq_gen(ni,vo,bo,te,nor,vshn,EQNUM=5,POLYT=polyt)  ;;  normal momentum flux equation [Eq. 5 from Koval and Szabo, 2008]
eq6            = rh_eq_gen(ni,vo,bo,te,nor,vshn,EQNUM=6,POLYT=polyt)  ;;  energy flux equation [Eq. 6 from Koval and Szabo, 2008]
;;  Define Structure of equations
tags           = 'EQ'+['0','1','2','3','4','5','6','7','8']
eqstr          = CREATE_STRUCT(tags,eq2[*,*,0],                      $
                                    eq3[*,*,0],eq3[*,*,1],eq3[*,*,2],$
                                    eq4[*,*,0],eq4[*,*,1],eq4[*,*,2],$
                                    eq5[*,*,0],eq6[*,*,0])
;;----------------------------------------------------------------------------------------
;;  Define Avg. and Std. Dev. over N-Pairs
;;----------------------------------------------------------------------------------------
dumbn2         = REPLICATE(0d0,n_v[0],m_n[0])
dumbn          = REFORM(dumbn2[*,0]) + 1
neq            = 9L
avg            = REPLICATE(d,neq[0],m_n[0])
std            = avg
j              = 0L
true           = 1
WHILE(true) DO BEGIN
  d_eq0    = eqstr.(j)                     ;;  [N,M]-Element array
  n_gd     = TOTAL(FINITE(d_eq0),1L,/NAN)
  ;;  Define  :  sum_{j}^{N - 1} [ x_ij ]
  sum_0    = TOTAL(d_eq0,1L,/NAN,/DOUBLE)
  ;;  Define  :  <x>_i                    ;;  Mean   [M]-Element array
  avg_0    = sum_0/n_gd[0]
  ;;  Define  :  [ x_ij - <x>_i ]^2       ;;  [N,M]-Element array
  diff     = (d_eq0 - (dumbn # avg_0))^2
  ;;  Define  :  sum_{j}^{N - 1} [ [ x_ij - <x>_i ]^2 ]/[ N - 1 ]
  var_0    = TOTAL(diff,1L,/NAN,/DOUBLE)/(n_gd[0] - 1d0)
  ;;  Define  :  Mean and Std. Dev.
  avg[j,*] = avg_0
  std[j,*] = SQRT(var_0)
  IF (j LT neq - 1L) THEN true = 1 ELSE true = 0
  j       += true
ENDWHILE
;;----------------------------------------------------------------------------------------
;;  Redefine Structure of equations  [N,M]-Element arrays
;;----------------------------------------------------------------------------------------
;std2           = TRANSPOSE(REBIN(std,neq[0],m_n[0],n_v[0]),[2,0,1])
;;  Normalize equations  [N,M]-Element arrays
;eqs2           = eq2[*,*,0]/(REFORM(std2[*,0,*]))
;eqs3x          = eq3[*,*,0]/(REFORM(std2[*,1,*]))
;eqs3y          = eq3[*,*,1]/(REFORM(std2[*,2,*]))
;eqs3z          = eq3[*,*,2]/(REFORM(std2[*,3,*]))
;eqs3           = [[[eqs3x]],[[eqs3y]],[[eqs3z]]]
;eqs4x          = eq4[*,*,0]/(REFORM(std2[*,4,*]))
;eqs4y          = eq4[*,*,1]/(REFORM(std2[*,5,*]))
;eqs4z          = eq4[*,*,2]/(REFORM(std2[*,6,*]))
;eqs4           = [[[eqs4x]],[[eqs4y]],[[eqs4z]]]
;eqs5           = eq5[*,*,0]/(REFORM(std2[*,7,*]))
;eqs6           = eq6[*,*,0]/(REFORM(std2[*,8,*]))
eqs2           = eq2[*,*,0]/(dumbn # REFORM(std[0,*]))
eqs3x          = eq3[*,*,0]/(dumbn # REFORM(std[1,*]))
eqs3y          = eq3[*,*,1]/(dumbn # REFORM(std[2,*]))
eqs3z          = eq3[*,*,2]/(dumbn # REFORM(std[3,*]))
eqs3           = [[[eqs3x]],[[eqs3y]],[[eqs3z]]]
eqs4x          = eq4[*,*,0]/(dumbn # REFORM(std[4,*]))
eqs4y          = eq4[*,*,1]/(dumbn # REFORM(std[5,*]))
eqs4z          = eq4[*,*,2]/(dumbn # REFORM(std[6,*]))
eqs4           = [[[eqs4x]],[[eqs4y]],[[eqs4z]]]
eqs5           = eq5[*,*,0]/(dumbn # REFORM(std[7,*]))
eqs6           = eq6[*,*,0]/(dumbn # REFORM(std[8,*]))
;;  Redefine Structure of equations  [N,M]-Element arrays
tags           = 'EQ'+['2','3','4','5','6']
eqstr          = CREATE_STRUCT(tags,eqs2,eqs3,eqs4,eqs5,eqs6)
;;----------------------------------------------------------------------------------------
;;  Determine which equations to sum
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(neqs) THEN BEGIN
  IF (N_ELEMENTS(neqs) NE 5) THEN BEGIN
    ;;  Default = use all
    nqq = [1,1,1,1,1]
  ENDIF ELSE BEGIN
    good = WHERE(neqs,gnq)
    IF (gnq[0] GT 0) THEN BEGIN
      nqq       = [0,0,0,0,0]
      nqq[good] = 1
    ENDIF ELSE BEGIN
      ;;  Default = use all
      nqq = [1,1,1,1,1]
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Default = use all
  nqq = [1,1,1,1,1]
ENDELSE
neqs           = nqq
good           = WHERE(neqs,gnq)
;;----------------------------------------------------------------------------------------
;;  Add up equation results for each set of points
;;----------------------------------------------------------------------------------------
n              = N_ELEMENTS(REFORM(vshn))
sum            = dumbn2                     ;;   sum_{j=1}^{K} (Y_{j}(x_{i},a)/std[j]_{i})^{2}
dumb           = 0d0
j              = 0L
true           = 1
WHILE(true) DO BEGIN
  d_eq = eqstr.(good[j])
  ndim = SIZE(d_eq,/N_DIMENSIONS)
  IF (ndim[0] GT 2) THEN BEGIN
    ;;  Vector array equation [Eqs 3 or 4]
    dumb += d_eq[*,*,0]^2d0 + d_eq[*,*,1]^2d0 + d_eq[*,*,2]^2d0
  ENDIF ELSE BEGIN
    ;;  Scalar array equation [Eqs 2, 5, or 6]
    dumb += d_eq^2d0
  ENDELSE
  IF (j LT gnq - 1L) THEN true = 1 ELSE true = 0
  j   += true
ENDWHILE
sum            = dumb                  ;;  [N,M]-Element array
;;----------------------------------------------------------------------------------------
;;  Return sum to user
;;----------------------------------------------------------------------------------------

RETURN,sum
END
