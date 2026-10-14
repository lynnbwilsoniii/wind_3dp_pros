;+
;*****************************************************************************************
;
;  FUNCTION :   test_ranges_4_mpfitparinfostruc.pro
;  PURPOSE  :   This routine tests the range input keywords supplied by the user for
;                 format and compliance with the MPFIT routines.
;
;  CALLED BY:   
;               get_default_pinfo_4_fitvdf2sumof3funcs.pro
;               wrapper_fit_vdf_2_sumof3funcs.pro
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
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               test = test_ranges_4_mpfitparinfostruc( [RKEY_IN=rkey_in]             $
;                                 [,DEF_RAN=def_ran] [,LIMS_OUT=lims_out]             $
;                                 [,LIMD_OUT=limd_out] [,RKEY_ON=rkey_on]             )
;
;  KEYWORDS:    
;               RKEY_IN   :  [4]-Element [numeric] array defining the range of allowed
;                               values to use for the parameter of interest where the
;                               first two elements specify whether to turn on the limits
;                               and the last two specify the values of said limits.
;               DEF_RAN   :  [2]-Element [numeric] array defining the default range to
;                               to use if RKEY_IN[2:3] are bad or the same value
;                               [ Default = [NaN, NaN] ]
;               LIMS_OUT  :  Set to a named variable to return the range of values to
;                               use in the LIMITS tag for the PARINFO structures
;               LIMD_OUT  :  Set to a named variable to return the boolean values to
;                               use in the LIMITED tag for the PARINFO structures
;               RKEY_ON   :  Set to a named variable to return a boolean value informing
;                               the user as to whether the input keyword was set and
;                               properly formatted
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               0)  Make sure to set RKEY_IN properly!!!
;                   [e.g., see Man. page of get_default_pinfo_4_fitvdf2sumof2funcs.pro]
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: test_range_keys_4_fitvdf2sumof2funcs.pro
;   CREATED:  06/19/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/19/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION test_ranges_4_mpfitparinfostruc,RKEY_IN=rkey_in,DEF_RAN=def_ran,          $
                                         LIMS_OUT=lims_out,LIMD_OUT=limd_out,      $
                                         RKEY_ON=rkey_on

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f                       = !VALUES.F_NAN
d                       = !VALUES.D_NAN
dumb0b                  = REPLICATE(0b,2)
dumb1b                  = REPLICATE(1b,2)
dumbd                   = REPLICATE(d,2)
rkey_on                 = 1b
lims_out                = dumbd
limd_out                = dumb0b
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DEF_RAN
test                    = (N_ELEMENTS(def_ran) GE 2) AND is_a_number(def_ran,/NOMSSG)
IF (test[0]) THEN def_range = DOUBLE(REFORM(def_ran[0L:1L])) ELSE def_range = REPLICATE(d,2)
;;  Check RKEY_IN
test                    = (N_ELEMENTS(rkey_in) EQ 4) AND is_a_number(rkey_in,/NOMSSG)
IF (test[0]) THEN BEGIN
  ;;  So far so good, now check elements
  test                    = (TOTAL(rkey_in[0L:1L] EQ 0 OR rkey_in[0L:1L] EQ 1) EQ 2)
  IF (test[0]) THEN BEGIN
    limd_out                = BYTE(rkey_in[0L:1L])
  ENDIF ELSE BEGIN
    ;;  Check if default range is okay to use
    good                    = WHERE(FINITE(def_range) GT 0,gd)
    IF (gd[0] GT 0) THEN limd_out[good] = dumb1b[good] ELSE limd_out = REPLICATE(0b,2)
    rkey_on                 = 0b
  ENDELSE
  test                    = (TOTAL(FINITE(rkey_in[2L:3L])) EQ TOTAL(limd_out))
  IF (test[0]) THEN BEGIN
    ;;  RKEY_IN properly formatted --> define output range
    lims_out                = DOUBLE(rkey_in[2L:3L])
  ENDIF ELSE BEGIN
    ;;  Something is wrong, check if default range is okay to use
    good                    = WHERE((FINITE(def_range) GT 0) AND limd_out,gd)
    IF (gd[0] GT 0) THEN lims_out[good] = def_range[good] ELSE lims_out = REPLICATE(d,2)
    rkey_on                 = 0b
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Check if default range is okay to use
  good                    = WHERE(FINITE(def_range) GT 0,gd)
  IF (gd[0] GT 0) THEN BEGIN
    ;;  Use default range
    limd_out[good]          = dumb1b[good]
    lims_out[good]          = def_range[good]
  ENDIF ELSE BEGIN
    ;;  Bad format --> do not limit parameter
    lims_out                = REPLICATE(d,2)
    limd_out                = REPLICATE(0b,2)
  ENDELSE
  rkey_on                 = 0b
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END
