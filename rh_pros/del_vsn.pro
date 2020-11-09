;+
;*****************************************************************************************
;
;  FUNCTION :   del_vsn.pro
;  PURPOSE  :   Returns the difference between an input velocity, V, and
;                 the shock normal speed, Vs.  The result is either a scalar
;                 [N,M,2]-element array (VEC=0) corresponding to the equation
;                 result = { (V . n) - Vs } or a vector [N,M,3,2]-element array
;                 corresponding to the equation result = { V - (Vs . n) n }.  The
;                 input velocities must contain both upstream and downstream values,
;                 thus why it is an [*,*,2]-element array input.
;
;               **Note:  These values must be in the spacecraft (SC) frame of reference**
;
;  CALLED BY:   
;               rh_eq_gen.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               rh_resize.pro
;
;  REQUIRES:    
;               1)  LBW's Rankine-Hugoniot Analysis Library
;
;  INPUT:
;               V    :  [N,3,2]-Element [numeric] array of velocities     [X-Basis, Y-Units]
;               N    :  [M,3]-Element [numeric] unit normal vectors       [X-Basis]
;               VS   :  [N,M]-Element [numeric] array shock normal speeds in SC-frame [Y-Units]
;
;  EXAMPLES:    
;               [calling sequence]
;               ushn = del_vsn(v,n,vs [,VEC=vec])
;
;  KEYWORDS:    
;               VEC  :  Determines which specific difference to return to user
;                         0 = (V . n - Vs)  {scalar  :  [N,M,2]-Element array}
;                         1 = (V - Vs n)    {vector  :  [N,M,3,2]-Element array}
;
;   CHANGED:  1)  Changed input and output format so that N speed differences
;                   are calculated for each shock normal vector
;                                                                   [09/07/2011   v1.1.0]
;             2)  Removed renormalization of n and fixed a typo
;                                                                   [09/09/2011   v1.2.0]
;             3)  Now routine allows for more than 1 normal vector and calls
;                   rh_resize.pro
;                                                                   [09/10/2011   v1.3.0]
;             4)  Cleaned up, updated Man. page, and optimized
;                                                                   [08/28/2020   v1.3.1]
;
;   NOTES:      
;               1)  The units of V and VS do not matter so long as they are the same
;                     and correspond to velocities/speeds in the SC-frame
;               2)  The N-Elements of VS must correspond to the [N,3,2] velocities
;                     and the M-Elements of VS must correspond to the [M,3] shock
;                     normal vectors
;               3)  user should not call this routine
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
;    LAST MODIFIED:  08/28/2020   v1.3.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION del_vsn,v,n,vs,VEC=vec

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 3) THEN RETURN,d

v1             = v
n1             = n
vs1            = vs
rh_resize,VSW=v1,NPTS=n_v                      ;;  V1   :  [N,3,2]-Element array
rh_resize,NOR=n1,MNOR=m_n                      ;;  N1   :  [M,3]-Element array
test           = TOTAL(FINITE([n_v,m_n]),/NAN) NE 2
IF (test) THEN RETURN,d

rh_resize,VSH=vs1,NPTS=n_v,MNOR=m_n            ;;  VS1  :  [N,M]-Element array
test           = TOTAL(FINITE([n_v,m_n]),/NAN) NE 2
IF (test) THEN RETURN,d

IF KEYWORD_SET(vec) THEN vv = 1 ELSE vv = 0
;;----------------------------------------------------------------------------------------
;;  Define normal velocity difference
;;----------------------------------------------------------------------------------------
CASE vv[0] OF
  0  :  BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Calculate normal component of V
    ;;   v_n = V . n        [page 357 Eq. 8.22 {n = z here} of Jackson E&M 3rd Edition]
    ;;------------------------------------------------------------------------------------
    ;;  Upstream
    term0 = v1[*,0,0] # n1[*,0]
    term1 = v1[*,1,0] # n1[*,1]
    term2 = v1[*,2,0] # n1[*,2]
    vnu   = term0 + term1 + term2              ;;  [N,M]-Element array
    ;;  Downstream
    term0 = v1[*,0,1] # n1[*,0]
    term1 = v1[*,1,1] # n1[*,1]
    term2 = v1[*,2,1] # n1[*,2]
    vnd   = term0 + term1 + term2              ;;  [N,M]-Element array
    ;;------------------------------------------------------------------------------------
    ;;   (V . n - Vs)  {scalar}
    ;;------------------------------------------------------------------------------------
    delvu = vnu - vs1                          ;;  [N,M]-Element array
    delvd = vnd - vs1                          ;;  [N,M]-Element array
    vdiff = REPLICATE(d,n_v,m_n,2L)            ;;  [N,M,2]-Element array
    vdiff[*,*,0] = delvu
    vdiff[*,*,1] = delvd
  END
  1  :  BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Define (Vs n)
    ;;------------------------------------------------------------------------------------
    dumb4d     = REPLICATE(1d0,n_v[0],m_n[0],3L,2L)
    dumbn      = REFORM(dumb4d[*,0,0,0])
    ones       = REFORM(dumb4d[0,*,0,0])
    termx      = vs1*(dumbn # n1[*,0])  ;;  [N,M]-Element array
    termy      = vs1*(dumbn # n1[*,1])
    termz      = vs1*(dumbn # n1[*,2])
    nvs        = [[[termx]],[[termy]],[[termz]]]  ;;  [N,M,3]-Element array
    ;;------------------------------------------------------------------------------------
    ;;   (V - Vs n)    {vector}
    ;;------------------------------------------------------------------------------------
    vdiff      = dumb4d                              ;;  [N,M,3,2]-Element array
    vdiff     *= d[0]
;    ones       = REPLICATE(1d0,m_n[0])
    ;;  Upstream
    v1u2dx     = v1[*,0,0] # ones                    ;;  [N,M]-Element array
    v1u2dy     = v1[*,1,0] # ones                    ;;  [N,M]-Element array
    v1u2dz     = v1[*,2,0] # ones                    ;;  [N,M]-Element array
    delvux     = v1u2dx - nvs[*,*,0]                 ;;  [N,M]-Element array
    delvuy     = v1u2dy - nvs[*,*,1]                 ;;  [N,M]-Element array
    delvuz     = v1u2dz - nvs[*,*,2]                 ;;  [N,M]-Element array
    delvu      = [[[delvux]],[[delvuy]],[[delvuz]]]  ;;  [N,M,3]-Element array
    ;;  Downstream
    v1d2dx     = v1[*,0,1] # ones                    ;;  [N,M]-Element array
    v1d2dy     = v1[*,1,1] # ones                    ;;  [N,M]-Element array
    v1d2dz     = v1[*,2,1] # ones                    ;;  [N,M]-Element array
    delvdx     = v1d2dx - nvs[*,*,0]                 ;;  [N,M]-Element array
    delvdy     = v1d2dy - nvs[*,*,1]                 ;;  [N,M]-Element array
    delvdz     = v1d2dz - nvs[*,*,2]                 ;;  [N,M]-Element array
    delvd      = [[[delvdx]],[[delvdy]],[[delvdz]]]  ;;  [N,M,3]-Element array
    ;;  Define velocity difference
    vdiff[*,*,*,0] = delvu
    vdiff[*,*,*,1] = delvd
  END
  ELSE : vdiff = d                             ;;  This should not be possible
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Return velocity difference
;;----------------------------------------------------------------------------------------

RETURN,vdiff
END
