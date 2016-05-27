;+
;*****************************************************************************************
;
;  FUNCTION :   rh_permute.pro
;  PURPOSE  :   Returns new arrays which contain the permutations of each time stamp
;                 upstream with all the possible downstream time stamps.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               RHO     :  [N,2]-Element [up,down] array corresponding to the number
;                            density [cm^(-3)]
;               VSW     :  [N,3,2]-Element [up,down] array corresponding to the solar wind
;                            velocity vectors [SC-frame, km/s]
;               MAG     :  [N,3,2]-Element [up,down] array corresponding to the ambient
;                            magnetic field vectors [nT]
;               TOT     :  [N,2]-Element [up,down] array corresponding to the total plasma
;                            temperature [eV]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Every input has [N,*...]-Elements, which means that each of the
;                     Nth-values is tied to a specific time stamp.
;               2)  This routine is optional and only improves the statistics of ones
;                     results.
;
;   CREATED:  09/12/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/12/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION rh_permute,rho,vsw,mag,tot

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
; => Know these values are in the correct format from wrapping routine
ni         = rho                               ; => [N,2]-Element array
bo         = mag                               ; => [N,3,2]-Element array
vo         = vsw                               ; => [N,3,2]-Element array
te         = tot                               ; => [N,2]-Element array
n_v        = N_ELEMENTS(te[*,0])
;-----------------------------------------------------------------------------------------
; => Define upstream/downstream values
;-----------------------------------------------------------------------------------------
ni_up      = ni[*,0]
te_up      = te[*,0]
vo_up      = vo[*,*,0]
bo_up      = bo[*,*,0]

ni_dn      = ni[*,1]
te_dn      = te[*,1]
vo_dn      = vo[*,*,1]
bo_dn      = bo[*,*,1]
;-----------------------------------------------------------------------------------------
; => Define dummy arrays
;-----------------------------------------------------------------------------------------
ni_per     = REPLICATE(d,n_v,n_v,2L)
te_per     = REPLICATE(d,n_v,n_v,2L)
vo_per     = REPLICATE(d,n_v,n_v,3L,2L)
bo_per     = REPLICATE(d,n_v,n_v,3L,2L)
FOR j=0L, n_v - 1L DO BEGIN
  ; => Shift downstream pairs
  ni2 = SHIFT(ni_dn,j)
  te2 = SHIFT(te_dn,j)
  vo2 = SHIFT(vo_dn,j,0)
  bo2 = SHIFT(bo_dn,j,0)
  ; => Define new pairs
  ni_per[*,j,0]   = ni_up
  ni_per[*,j,1]   = ni2
  te_per[*,j,0]   = te_up
  te_per[*,j,1]   = te2
  vo_per[*,j,*,0] = vo_up
  vo_per[*,j,*,1] = vo2
  bo_per[*,j,*,0] = bo_up
  bo_per[*,j,*,1] = bo2
ENDFOR
;-----------------------------------------------------------------------------------------
; => Reform arrays
;-----------------------------------------------------------------------------------------
ni_per     = REFORM(ni_per,n_v*n_v,2L)
te_per     = REFORM(te_per,n_v*n_v,2L)
vo_per     = REFORM(vo_per,n_v*n_v,3L,2L)
bo_per     = REFORM(bo_per,n_v*n_v,3L,2L)
;-----------------------------------------------------------------------------------------
; => Create data structure and return
;-----------------------------------------------------------------------------------------
tags       = ['DENS','TEMP','VSW','BFIELD']
struc      = CREATE_STRUCT(tags,ni_per,te_per,vo_per,bo_per)

RETURN,struc
END