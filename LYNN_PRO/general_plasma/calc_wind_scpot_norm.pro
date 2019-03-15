;+
;*****************************************************************************************
;
;  FUNCTION :   calc_wind_scpot_norm.pro
;  PURPOSE  :   Calculates the normalized spacecraft potential for the Wind spacecraft
;                 given the total ion density using the empirical fit from the work
;                 Wilson et al. [2019a]:
;                   Y = A X^(B) e^(C X) + D
;                     Y  :  (ø_sc + E_min)/5
;                     X  :  no [cm^(-3)]
;                     A  =         2.2723683   +/-      0.013018211
;                     B  =       -0.43075336   +/-      0.019704379
;                     C  =      0.0011455842   +/-     0.0015472141
;                     D  =         2.0000000   +/-        0.0000000
;                     
;                     Model Fit Status                    =        1
;                     Number of Iterations                =           14
;                     Degrees of Freedom                  =          486
;                     Chi-Squared                         =        69.766670
;                     Reduced Chi-Squared                 =       0.14355282
;                 The routine returns the numerical values of Y and another routine
;                 must be used to get the values of ø_sc.  The purpose of not including
;                 the last step is so that this routine need only the number densities
;                 as an input.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DENS    :  [N]-Element array of number densities [cm^(-3)]
;
;  EXAMPLES:    
;               [calling sequence]
;               norm_phi = calc_wind_scpot_norm(dens)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  To get the real values of spacecraft potential, one must take the
;                     output from this routine and solve for
;                       ø_sc[i] = 5*Y[i] - E_min[i]
;                     where E_min[i] is the minimum energy bin value of the EESA Low
;                     distribution nearest to the i-th value of Y
;
;  REFERENCES:  
;               0)  L.B. Wilson III, et al., "Electron energy partition across
;                      interplanetary shocks: I. Methodology and Data Product,"
;                      Astrophys. J. Suppl., under review, eprint 1902.01476, 2019a.
;
;   CREATED:  03/07/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/07/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_wind_scpot_norm,dens

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define fit parameters [value,uncertainty]
aa             = [2.2723683d0,0.013018211d0]
bb             = [-0.43075336d0,0.019704379d0]
cc             = [0.0011455842d0,0.0015472141d0]
dd             = [2.0000000d0,0.0000000d0]
perm           = [-1,0,1]
;;  Dummy error messages
noinpt_msg     = 'No input supplied...'
notnum_msg     = 'Input must be of numeric type...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN BEGIN
  ;;  no input???
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(dens,/NOMSSG) EQ 0) OR (N_ELEMENTS(dens) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,notnum_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define params
nx             = N_ELEMENTS(dens)
xx             = REFORM(dens,nx[0])
;;----------------------------------------------------------------------------------------
;;  Compute permuted function:  Y = A X^(B) e^(C X) + D
;;----------------------------------------------------------------------------------------
aa_perm        = aa[0] + perm*aa[1]
bb_perm        = bb[0] + perm*bb[1]
cc_perm        = (cc[0] + perm*cc[1]) > 1d-5
yy_perm        = REPLICATE(d,nx[0],3L,3L,3L)
FOR ii=0L, 2L DO BEGIN
  FOR jj=0L, 2L DO BEGIN
    FOR kk=0L, 2L DO BEGIN
      yy_perm[*,ii,jj,kk] = aa_perm[ii]*xx^(bb_perm[jj])*EXP(cc_perm[kk]*xx) + dd[0]
    ENDFOR
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Compute mean and lower/upper boundaries of function:  Y = A X^(B) e^(C X) + D
;;----------------------------------------------------------------------------------------
yy_lower       = MIN(MIN(MIN(yy_perm,/NAN,DIMENSION=2),/NAN,DIMENSION=2),/NAN,DIMENSION=2)
yy_upper       = MAX(MAX(MAX(yy_perm,/NAN,DIMENSION=2),/NAN,DIMENSION=2),/NAN,DIMENSION=2)
yy___med       = MEDIAN(MEDIAN(MEDIAN(yy_perm,DIMENSION=2),DIMENSION=2),DIMENSION=2)
yy___avg       = MEAN(MEAN(MEAN(yy_perm,/NAN,DIMENSION=2),/NAN,DIMENSION=2),/NAN,DIMENSION=2)
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
output         = {MIN:yy_lower,MAX:yy_upper,MED:yy___med,AVG:yy___avg}
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END