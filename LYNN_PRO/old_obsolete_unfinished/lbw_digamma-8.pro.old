;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_digamma.pro
;  PURPOSE  :   Returns digamma function (i.e., derivative of Gamma function divided
;                 by Gamma function) of argument z.  This routine is used when one
;                 calculates the derivative of a kappa velocity distribution function
;                 analytically.
;
;                 The asymptotic series (about z_o = infinity) is defined as:
;
;                                        z
;                   psi(x) = -¥ + ∑ -----------
;                                    n (n + z)
;
;                 where z = (x - 1), ¥ = Euler-Mascheroni constant, and ∑ is a sum
;                 from n = 1 to +infinity.  To achieve 7 digits of accuracy for x = 5,
;                 we need N ~ 30000000 terms.
;
;                 If we expand psi(z) in a series about +infinity, we find:
;
;                                 1      1        1           1           1
;                   psi(z) = -Ln --- - ----- - -------- + --------- - --------- +
;                                 z     2 z     12 z^2     120 z^4     252 z^6
;
;                                    1           1            691            1
;                                --------- - ---------- + ------------ - --------- +
;                                 240 z^8     132 z^10     32760 z^12     12 z^14
;
;                                    3617         43,867         174,611      77,683
;                                ----------- - ------------ + ----------- - ---------- +
;                                 8160 z^16     14364 z^18     6600 z^20     276 z^22
;
;                                 236,364,091      657931      [  1   ]
;                                ------------- - ---------- + O[------]
;                                 65,520 z^24     12  z^26     [ z^27 ]
;
;                 unfortunately, the number of terms that results in a minimum
;                 difference from the "true" value is neither constant nor an
;                 increasing number with increasing z.  Therefore, we will use the
;                 summation above.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               read_digamma_ascii_file.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII files named
;                     digamma_numerical_estimates_0.01-41.0_0.01-steps.txt
;                     digamma_numerical_estimates_0.0001-0.1_0.0001-steps.txt
;                     digamma_numerical_estimates_0.05-0.15_0.0001-steps.txt
;                     digamma_numerical_estimates_0.09-10.10_0.01-steps.txt
;                     digamma_numerical_estimates_10.00-20.10_0.01-steps.txt
;                     digamma_numerical_estimates_20.00-30.10_0.01-steps.txt
;                     digamma_numerical_estimates_30.00-40.10_0.01-steps.txt
;                   in the following directory
;                     ~/wind_3dp_pros/LYNN_PRO/general_math/
;
;  INPUT:
;               Z  :  Scalar [numeric] defining the argument of the digamma function
;
;  EXAMPLES:    
;               [calling sequence]
;               dg = lbw_digamma(z [,N=n] [,READ_DG=read_dg])
;
;  KEYWORDS:    
;               N        :  Scalar [long] defining the number of terms to use in the
;                             summation to calculate the deviation from the
;                             Euler-Mascheroni constant
;                             [Default = 30000000]
;               READ_DG  :  If set and the following is satisfied, 0.01 ≤ Z ≤ 41.0, then
;                             the routine will read in an ASCII file containing
;                             pre-evaluated results from the digamma function and then
;                             will linearly interpolate to the value of Z
;
;   CHANGED:  1)  Finished writing routine
;                                                                   [04/23/2015   v1.0.0]
;             2)  Changed long integers to unsigned long integers in case
;                   user sends in a number that exceeds the limit of a long integer
;                                                                   [04/24/2015   v1.0.1]
;             3)  Moved to ~/wind_3dp_pros/LYNN_PRO/general_math/ and updated routine
;                                                                   [08/12/2015   v1.1.0]
;             4)  Cleaned up and updated Man. page
;                                                                   [04/04/2018   v1.1.1]
;             5)  Added keyword READ_DG and now calls
;                   read_digamma_ascii_file.pro
;                                                                   [04/07/2018   v1.2.0]
;             6)  Added more fine-grained ASCII files of shorter length to improve
;                   accuracy and speed up computation and now requires argument
;                   input for read_digamma_ascii_file.pro to determine the range
;                   associated with a specific ASCII file and now uses SPLINE
;                   interpolation
;                                                                   [04/12/2018   v1.3.0]
;             7)  Added error handling in case read_digamma_ascii_file.pro fails for
;                   some reason
;                                                                   [04/23/2018   v1.3.1]
;             8)  Added another ASCII file to extend argument range to 101.0
;                                                                   [04/23/2018   v1.3.2]
;
;   NOTES:      
;               1)  The Euler-Mascheroni constant to 50 decimal places is:
;                     0.57721566490153286060651209008240243104215933593992
;               2)  The larger the value of N, the more accurate the result
;                     --> the Default value only gives accurate results to
;                           ~7 decimal places
;               3)  Unfortunately, this routine is slow as it creates an array of values
;                     that can be several billion elements long, depending on the
;                     precision desired by the user
;               4)  If the input Z falls between 0.01 and 41.0 then the use the READ_DG
;                     keyword as this will speed up the routine greatly
;
;  REFERENCES:  
;               Equation (15) at:
;                 http://mathworld.wolfram.com/DigammaFunction.html
;
;   CREATED:  04/01/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/23/2018   v1.3.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_digamma,z,N=n,READ_DG=read_dg

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define the Euler-Mascheroni constant to 50 decimal places
em_gam         = 0.57721566490153286060651209008240243104215933593992d0
def_n          = 30000000UL        ;;  Minimum number of terms in series allowed
min_prec       = 1d-12             ;;  Minimum allowed deviation from Euler-Mascheroni constant
zran           = [0.0003e0,100.09e0]
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 1) OR (is_a_number(z,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  (Incorrect # of inputs) OR (Input was not numeric)
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check READ_DG
test           = KEYWORD_SET(read_dg)
IF (test[0]) THEN test = (z[0] GT zran[0]) AND (z[0] LT zran[1])  ;;  Make sure within allowed range
;IF (test[0]) THEN test = (z[0] GT 0.0003) AND (z[0] LT 40.09e0)  ;;  Make sure within allowed range
IF (test[0]) THEN BEGIN
  ;;  Read in ASCII file
  zz             = z[0]
  dglist         = read_digamma_ascii_file(zz[0])
  IF (N_ELEMENTS(dglist) LT 2) THEN RETURN,d
  temp           = INTERPOL(dglist[*,1],dglist[*,0],zz[0],/NAN,/SPLINE)
  psi_final      = temp[0]
  ;;  Return to user
  RETURN,psi_final[0]
ENDIF
;;  Check N
test           = (is_a_number(n,/NOMSSG) EQ 0)
IF (test[0]) THEN nn = def_n[0] ELSE nn = ULONG(n[0] > def_n[0])
;;  Make sure N is large enough so that the deviation from Euler-Mascheroni constant
;;    is less than ~10^(-12)
zz             = z[0] - 1d0
min_n          = (-zz[0] + SQRT(zz[0]^2 + 4d0*(zz[0]/min_prec[0])))/2d0
nn             = nn[0] > ULONG(ABS(min_n[0]))
;;----------------------------------------------------------------------------------------
;;  Calculate deviation from Euler-Mascheroni constant
;;----------------------------------------------------------------------------------------
listn          = TEMPORARY(ULINDGEN(nn[0]) + 1L)
d_psi_tot      = TOTAL(zz[0]/(listn*(listn + zz[0])),/NAN)
;;----------------------------------------------------------------------------------------
;;  Calculate the value of the digamma function
;;----------------------------------------------------------------------------------------
psi_final      = -em_gam[0] + d_psi_tot[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,psi_final[0]
END

