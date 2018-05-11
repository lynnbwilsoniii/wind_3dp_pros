;+
;*****************************************************************************************
;
;  FUNCTION :   zero_pad.pro
;  PURPOSE  :   Appends an [N]-element array with M-zeros such that (M+N) is an integer
;                 power of 2, i.e., 2^(K) = (M+N) for integer K.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_zeros_mins_maxs_type.pro
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               SIGNAL   :  [N]-Element [numeric] array of values to which an [M]-element
;                             array of zeros will be appended on output
;
;  EXAMPLES:    
;               [calling sequence]
;               new_sign = zero_pad(signal [,FORCE_N=force_n])
;
;               n_in           = 35000L
;               x0             = FINDGEN(n_in[0])
;               dj             = 20000L
;               delt           = DBLARR(dj[0])
;               .compile power_of_2.pro
;               FOR j=0L, dj[0] - 1L DO BEGIN                          $
;                 x              = x0                                & $
;                 ex_start       = SYSTIME(1)                        & $
;                 y              = power_of_2(x)                     & $
;                 temp           = SYSTIME(1) - ex_start[0]          & $
;                 delt[j]        = DOUBLE(temp[0])
;
;               ;;  Print out timing stats [convert to microseconds]
;               stats          = calc_1var_stats(delt*1d6,/NAN,/PRINTOUT)
;               ;;
;               ;;             Min. value of X  =         57.935715
;               ;;             Max. value of X  =         2118.8259
;               ;;             Avg. value of X  =         61.922944
;               ;;           Median value of X  =         61.035156
;               ;;     Standard Deviation of X  =         16.993322
;               ;;  Std. Dev. of the Mean of X  =        0.12016093
;               ;;               Skewness of X  =         95.656544
;               ;;               Kurtosis of X  =         11059.139
;               ;;         Lower Quartile of X  =         60.796738
;               ;;         Upper Quartile of X  =         61.988831
;               ;;     Interquartile Mean of X  =         60.999683
;               ;;    Total # of Elements in X  =         20000
;               ;;   Finite # of Elements in X  =         20000
;               ;;
;
;               n_in           = 35000L
;               x0             = FINDGEN(n_in[0])
;               dj             = 20000L
;               delt           = DBLARR(dj[0])
;               .compile zero_pad.pro
;               FOR j=0L, dj[0] - 1L DO BEGIN                          $
;                 x              = x0                                & $
;                 ex_start       = SYSTIME(1)                        & $
;                 z              = zero_pad(x)                       & $
;                 temp           = SYSTIME(1) - ex_start[0]          & $
;                 delt[j]        = DOUBLE(temp[0])
;
;               ;;  Print out timing stats [convert to microseconds]
;               stats          = calc_1var_stats(delt*1d6,/NAN,/PRINTOUT)
;               ;;
;               ;;             Min. value of X  =         57.935715
;               ;;             Max. value of X  =         4875.8984
;               ;;             Avg. value of X  =         64.455318
;               ;;           Median value of X  =         61.035156
;               ;;     Standard Deviation of X  =         65.926651
;               ;;  Std. Dev. of the Mean of X  =        0.46617182
;               ;;               Skewness of X  =         59.309947
;               ;;               Kurtosis of X  =         3842.1001
;               ;;         Lower Quartile of X  =         61.035156
;               ;;         Upper Quartile of X  =         62.942505
;               ;;     Interquartile Mean of X  =         61.354622
;               ;;    Total # of Elements in X  =         20000
;               ;;   Finite # of Elements in X  =         20000
;               ;;
;
;  KEYWORDS:    
;               FORCE_N  :  Scalar [long/integer] defining the number of elements to force
;                             for the output result.  Note that the routine will
;                             ignore this value if it is not an integer number of 2.
;
;   CHANGED:  1)  First version was slower than power_of_2.pro, so let's try removing
;                   dependencies to see if that helps
;                                                                   [04/30/2018   v1.0.1]
;             2)  Cleaned up and optimized further
;                                                                   [04/30/2018   v1.0.2]
;             3)  Cleaned up and optimized further
;                                                                   [04/30/2018   v1.0.3]
;
;   NOTES:      
;               1)  This is meant to be a streamlined version of power_of_2.pro
;               2)  The benchmark tests shown above were performed on a Late 2015
;                     27" iMac with a 4 GHz Intel Core i7 processor and 32 GB of
;                     1867 MHz DDR3 RAM.  I noticed that the times were surprisingly
;                     inconsistent between multiple runs through the for loop and this
;                     inconsistency increased as the value of N_IN increased.  I initially
;                     thought this would be easier to optimize and improve upon the
;                     routine power_of_2.pro but somehow this routine is still a little
;                     slower, despite multiple variations and alterations to the routine.
;
;  REFERENCES:  
;               1)  Harris, F.J. "On the Use of Windows for Harmonic Analysis with the
;                      Discrete Fourier Transform," Proc. IEEE Vol. 66, No. 1,
;                      pp. 51-83, (1978).
;               2)  Paschmann, G. and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                      Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                      Int. Space Sci. Inst, (1998).
;               3)  Torrence, C. and G.P. Compo "A Practical Guide to Wavelet Analysis,"
;                      Bull. Amer. Meteor. Soc. 79, pp. 61-78, (1998).
;               4)  Donnelly, D. and B. Rust "The Fast Fourier Transform for
;                      Experimentalists, Part I:  Concepts," Comput. Sci. & Eng. 7(2),
;                      pp. 80-88, (2005).
;               5)  Donnelly, D. and B. Rust "The Fast Fourier Transform for
;                      Experimentalists, Part II:  Convolutions," Comput. Sci.
;                      & Eng. 7(4), pp. 92-95, (2005).
;               6)  Rust, B. and D. Donnelly "The Fast Fourier Transform for
;                      Experimentalists, Part III:  Classical Spectral Analysis,"
;                      Comput. Sci. & Eng. 7(5), pp. 74-78, (2005).
;               7)  Rust, B. and D. Donnelly "The Fast Fourier Transform for
;                      Experimentalists, Part IV:  Autoregressive Spectral Analysis,"
;                      Comput. Sci. & Eng. 7(6), pp. 85-90, (2005).
;               8)  Donnelly, D. "The Fast Fourier Transform for Experimentalists,
;                      Part V:  Filters," Comput. Sci. & Eng. 8(1), pp. 92-95, (2006).
;
;   CREATED:  04/30/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/30/2018   v1.0.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION zero_pad,signal,FORCE_N=force_n

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
;;  Define allowed number types
all_ok_types   = [1L,2L,3L,4L,5L,6L,9L,12L,13L,14L,15L]
;;  Define allowed type zeros
all_ok_zeros   = {B:0B,IN:0S,L:0L,F:0e0,D:0d0,C:COMPLEX(0e0,0e0), $
                  DC:DCOMPLEX(0d0,0d0),UI:0U,UL:0UL,L64:0LL,      $
                  UL64:0ULL}
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
IF (N_PARAMS() LT 1) THEN RETURN,0b
;;  Check against available types
sz_si          = SIZE(signal)       ;;  [ND,D[0],D[1],...,D[ND-1],Type,N]
n_sz           = N_ELEMENTS(sz_si)
old_t          = sz_si[n_sz[0] - 2L]
;;  Determine which type to use
good           = WHERE(old_t[0] EQ all_ok_types,gd)
IF (gd[0] EQ 0) THEN RETURN,0b
n_a            = sz_si[n_sz[0] - 1L]
;;  Define zero value
zero           = all_ok_zeros.(good[0])        ;;  Zero value of proper type
;;----------------------------------------------------------------------------------------
;;  Define array to manipulate
;;----------------------------------------------------------------------------------------
;;  Force to be 1D
IF (sz_si[0] EQ 1) THEN arr = signal ELSE arr = REFORM(signal,n_a[0])
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check FORCE_N
IF (TOTAL(SIZE(force_n,/TYPE) EQ all_ok_types) GT 0) THEN BEGIN
  IF (((force_n[0] MOD 2) EQ 0) AND (force_n[0] GE n_a[0])) THEN fcn = (ROUND(force_n))[0] ELSE fcn = 0
ENDIF ELSE fcn = 0b
;;----------------------------------------------------------------------------------------
;;  Determine # of zeros to append
;;----------------------------------------------------------------------------------------
;;  Define nearest power of 2 lower bound
upp_pow2       = FLOOR(ALOG(1d0*n_a[0])/ALOG(2d0))
;;  Define nearest power of 2 upper bound
upp_pow2      += 1L
IF (2L^upp_pow2[0] LT n_a[0]) THEN upp_pow2 += 1L   ;;  Make sure upper bound is above input N
IF (fcn[0] GT 0) THEN BEGIN
  new_n          = fcn[0]
ENDIF ELSE BEGIN
  new_n          = 2L^upp_pow2[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define output array
;;----------------------------------------------------------------------------------------
;;  Define array of zeros
app_z          = REPLICATE(zero[0],new_n[0] - n_a[0])
;;  Append to output array
out_arr        = TEMPORARY([arr,app_z])
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,out_arr
END

