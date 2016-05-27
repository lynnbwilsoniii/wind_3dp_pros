;+
;*****************************************************************************************
;
;  FUNCTION :   tplot_struct_format_test.pro
;  PURPOSE  :   Tests an IDL structure to determine if it has the necessary structure 
;                 tags etc. to be compatible with TPLOT.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               is_a_3_vector.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STRUCT          :  Scalar [structure] defining a valid TPLOT structure
;                                    the the user wishes to clip (in time) in order to
;                                    examine only data between the limits defined by the
;                                    TRANGE keyword.  The minimum required structure tags
;                                    for a TPLOT structure are as follows:
;                                      X  :  [N]-Element array of Unix times
;                                      Y  :  [N,?]-Element array of data, where ? can be
;                                              up to two additional dimensions
;                                              [e.g., pitch-angle and energy bins]
;                                    additional potential tags are:
;                                      V  :  [N,E]-Element array of Y-Axis values
;                                              [e.g., energy bin values]
;                                    or in the special case of particle data:
;                                      V1 :  [N,E]-Element array of energy bin values
;                                      V2 :  [N,A]-Element array of pitch-angle bins
;                                    If V1 AND V2 are present, then Y must be an
;                                    [N,E,A]-element array.  If only V is present, then
;                                    Y must be an [N,E]-element array, where E is either
;                                    the 1st dimension of V [if 1D array] or the 2nd
;                                    dimension of V [if 2D array].
;
;  EXAMPLES:    
;               [calling sequence]
;               test = tplot_struct_format_test(struct [,/YNDIM] [,/YVECT]      $
;                                                      [,TEST__V=test__v]       $
;                                                      [,TEST_V1_V2=test_v1_v2] $
;                                                      [,/NOMSSG])
;
;               ;;  Example of BAD structure
;               struct         = {A:LINDGEN(20),B:DINDGEN(10)}
;               test           = tplot_struct_format_test(struct,/NOMSSG)
;               PRINT, test[0]
;                  0
;
;               ;;  Example of a GOOD structure
;               struct         = {X:DINDGEN(20),Y:FINDGEN(20)}
;               test           = tplot_struct_format_test(struct,/NOMSSG)
;               PRINT, test[0]
;                  1
;
;               ;;  Example [GOOD] of YVECT keyword usage
;               struct         = {X:DINDGEN(20),Y:FINDGEN(20,3)}
;               test           = tplot_struct_format_test(struct,/YVECT,/NOMSSG)
;               PRINT, test[0]
;                  1
;
;               ;;  Example [BAD] of YVECT keyword usage
;               struct         = {X:DINDGEN(20),Y:FINDGEN(20,5)}
;               test           = tplot_struct_format_test(struct,/YVECT,/NOMSSG)
;               PRINT, test[0]
;                  0
;
;               ;;  Example [BAD] of YVECT keyword usage
;               struct         = {X:DINDGEN(20),Y:FINDGEN(20)}
;               test           = tplot_struct_format_test(struct,/YVECT,/NOMSSG)
;               PRINT, test[0]
;                  0
;
;               ;;  Example [GOOD] of TEST__V keyword usage { TEST__V = 2 --> 2D array }
;               struct         = {X:DINDGEN(20),Y:FINDGEN(20,5),V:FINDGEN(20,5)}
;               test           = tplot_struct_format_test(struct,TEST__V=test__v,/NOMSSG)
;               PRINT, test[0], test__v[0]
;                  1   2
;
;               ;;  Example [GOOD] of TEST__V keyword usage { TEST__V = 1 --> 1D array }
;               struct         = {X:DINDGEN(20),Y:FINDGEN(20,5),V:FINDGEN(5)}
;               test           = tplot_struct_format_test(struct,TEST__V=test__v,/NOMSSG)
;               PRINT, test[0], test__v[0]
;                  1   1
;
;               ;;  Example [BAD] of TEST__V keyword usage
;               struct         = {X:DINDGEN(20),Y:FINDGEN(20,5),V:FINDGEN(15,25)}
;               test           = tplot_struct_format_test(struct,TEST__V=test__v,/NOMSSG)
;               PRINT, test[0], test__v[0]
;                  1   0
;
;               ;;  Example [GOOD] of TEST_V1_V2 keyword usage
;               struct         = {X:DINDGEN(50),Y:FINDGEN(50,10,5),V1:FINDGEN(50,10),V2:FINDGEN(50,5)}
;               test           = tplot_struct_format_test(struct,TEST_V1_V2=test_v1_v2,/NOMSSG)
;               PRINT, test[0], test_v1_v2[0]
;                  1   1
;
;               ;;  Example [BAD] of TEST_V1_V2 keyword usage
;               struct         = {X:DINDGEN(50),Y:FINDGEN(50,10,5),V1:FINDGEN(50,5),V2:FINDGEN(50,10)}
;               test           = tplot_struct_format_test(struct,TEST_V1_V2=test_v1_v2,/NOMSSG)
;               PRINT, test[0], test_v1_v2[0]
;                  1   0
;
;               ;;  Example [BAD] of TEST_V1_V2 keyword usage
;               struct         = {X:DINDGEN(50),Y:FINDGEN(50,10,5),V1:FINDGEN(5),V2:FINDGEN(10)}
;               test           = tplot_struct_format_test(struct,TEST_V1_V2=test_v1_v2,/NOMSSG)
;               PRINT, test[0], test_v1_v2[0]
;                  1   0
;
;               ;;  Example [BAD] of TEST_V1_V2 keyword usage
;               struct         = {X:DINDGEN(50),Y:FINDGEN(50,10,5),V:FINDGEN(5)}
;               test           = tplot_struct_format_test(struct,TEST_V1_V2=test_v1_v2,/NOMSSG)
;               PRINT, test[0], test_v1_v2[0]
;                  1   0
;
;               ;;  Example [BAD] of TEST_V1_V2 keyword usage
;               struct         = {X:DINDGEN(50),Y:FINDGEN(50,10,5)}
;               test           = tplot_struct_format_test(struct,TEST_V1_V2=test_v1_v2,/NOMSSG)
;               PRINT, test[0], test_v1_v2[0]
;                  1   0
;
;  KEYWORDS:    
;               YNDIM       :  Scalar [numeric] defining the number of dimensions desired
;                                in the STRUCT.Y array, if present
;               YVECT       :  If set, program determines if STRUCT.Y is an 
;                                [N,3]-Element array of 3-vectors
;               TEST__V     :  Set to a named varible to return logic tests that inform
;                                the user about the existence and format of the V
;                                structure tag.  The outputs are:
;                                  0  :  bad/incorrect format/non-existent
;                                  1  :  exists and is 1D
;                                  2  :  exists and is 2D (see notes above for STRUCT)
;               TEST_V1_V2  :  Set to a named varible to return logic tests that inform
;                                the user about the existence and format of the V1 and V2
;                                structure tags.  The outputs are:
;                                  0  :  bad/incorrect format/non-existent
;                                  1  :  both are set and correctly formatted
;               NOMSSG      :  If set, routine will not print out warning/error message(s)
;                                [Default = FALSE]
;
;   CHANGED:  1)  Added error handling in case user entered a null variable
;                                                                   [10/19/2010   v1.1.0]
;             2)  Updated Man. page, cleaned up, and
;                   added keywords: TEST__V, TEST_V1_V2, NOMSSG
;                   and now calls is_a_3_vector.pro, is_a_number.pro
;                                                                   [11/28/2015   v1.2.0]
;
;   NOTES:      
;               1)  See also:  t_resample_tplot_struc.pro
;                              t_insert_nan_at_interval_se.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/23/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/28/2015   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION tplot_struct_format_test,struct,YNDIM=yndim,YVECT=yvect,TEST__V=test__v,$
                                  TEST_V1_V2=test_v1_v2,NOMSSG=nomssg

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, is_a_3_vector
;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
;;  Constants
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  logic outputs
good           = 0b           ;;  Main output
test__v        = 0b           ;;  Test for V structure tag
test_v1_v2     = 0b           ;;  Test for V1 and V2 structure tags
;;  Dummy error messages
notstr_mssg    = 'Must be an IDL structure...'
badstr_mssg    = 'Not an appropriate TPLOT structure...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF N_PARAMS() EQ 0 THEN RETURN,0b
str            = struct[0]   ;;  In case it is an array of structures of the same format
IF (SIZE(str[0],/TYPE) NE 8L) THEN BEGIN
  ;;  Not an IDL structure
  IF ~KEYWORD_SET(nomssg) THEN MESSAGE,notstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Examine input
;;----------------------------------------------------------------------------------------
tags           = STRLOWCASE(TAG_NAMES(str))
ntags          = N_TAGS(str)
test__x        = WHERE(tags EQ  'x',gd__x)
test__y        = WHERE(tags EQ  'y',gd__y)
test__v        = WHERE(tags EQ  'v',gd__v)
test_v1        = WHERE(tags EQ 'v1',gd_v1)
test_v2        = WHERE(tags EQ 'v2',gd_v2)
;good           = (gdx EQ 1) AND (gdy EQ 1)  ;;  TRUE = Good TPLOT structure, FALSE = incorrect format
;IF NOT good THEN RETURN,0b
;;  good = TRUE --> Good TPLOT structure;  good = FALSE --> incorrect input
good           = (gd__x EQ 1) AND (gd__y EQ 1)
;;  Make sure it is TPLOT appropriate before checking keywords
IF (good[0] EQ 0) THEN BEGIN
  ;;  Not a TPLOT structure
  IF ~KEYWORD_SET(nomssg) THEN MESSAGE,badstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check YNDIM
x_ddim         = SIZE(str[0].X,/DIMENSIONS)
y_ndim         = SIZE(str[0].Y,/N_DIMENSIONS)
y_ddim         = SIZE(str[0].Y,/DIMENSIONS)
IF KEYWORD_SET(yndim) THEN BEGIN
;  y_dim = SIZE(str[0].Y,/N_DIMENSIONS)
;  ytest = y_dim[0] EQ yndim[0]
;  ytest = (y_ndim[0] EQ yndim[0])
  good = (y_ndim[0] EQ yndim[0])
;  IF (ytest[0]) THEN good = ytest[0] ELSE good = 0b
ENDIF
;;  Check YVECT
IF KEYWORD_SET(yvect) THEN good = is_a_3_vector(str[0].Y,NOMSSG=nomssg)
;;  Check of V, or V1 and V2 even exist
check_vs       = (gd__v EQ 0) AND ((gd_v1 EQ 0) OR (gd_v2 EQ 0))
IF (check_vs[0]) THEN RETURN,good[0]         ;;  check_vs = FALSE --> stop here and return to user
;;----------------------------------------------------------------------------------------
;;  Determine TEST__V output
;;----------------------------------------------------------------------------------------
;;  Define TEST__V for output
IF (gd__v GT 0) THEN vv = str[0].V  ELSE vv = ''
szdvv          = SIZE(vv,/DIMENSIONS)
test           =  (szdvv[0] NE 0) AND is_a_number(vv,NOMSSG=nomssg)
IF (test[0]) THEN BEGIN
  test_vv_2d = (N_ELEMENTS(szdvv) EQ 2);; ELSE test_vv_2d = 0b
  IF (test_vv_2d[0]) THEN BEGIN
    ;;  V is 2D
    test_vv = (x_ddim[0] EQ szdvv[0]) AND (y_ddim[1] EQ szdvv[1])   ;;  Make sure dimensions match if 2D
    IF (test_vv[0]) THEN test__v = 2b ELSE test__v = 0b
  ENDIF ELSE BEGIN
    ;;  V is 1D
    test_vv = (y_ddim[1] EQ szdvv[0])
    IF (test_vv[0]) THEN test__v = 1b ELSE test__v = 0b
  ENDELSE
ENDIF ELSE test__v = 0b
;;----------------------------------------------------------------------------------------
;;  Determine TEST_V1_V2 output
;;----------------------------------------------------------------------------------------
;;  Define V1 and V2, if exist
IF (gd_v1 GT 0) THEN v1 = str[0].V1 ELSE v1 = ''
IF (gd_v2 GT 0) THEN v2 = str[0].V2 ELSE v2 = ''
szdv1          = SIZE(v1,/DIMENSIONS)
szdv2          = SIZE(v2,/DIMENSIONS)
test           = (N_ELEMENTS(szdv1) EQ 2) AND (N_ELEMENTS(szdv2) EQ 2) AND $
                 (y_ndim[0] EQ 3)
IF (test[0]) THEN BEGIN
  test_v1        = ((szdv1[0] NE 0) AND is_a_number(v1,NOMSSG=nomssg)) AND $
                    (x_ddim[0] EQ szdv1[0]) AND (y_ddim[1] EQ szdv1[1])
  test_v2        = ((szdv2[0] NE 0) AND is_a_number(v2,NOMSSG=nomssg)) AND $
                    (x_ddim[0] EQ szdv2[0]) AND (y_ddim[2] EQ szdv2[1])
  ;;  Define TEST_V1_V2
  test_v1_v2     = (test_v1[0] AND test_v2[0])
ENDIF ELSE test_v1_v2 = 0b
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,good
END



;IF KEYWORD_SET(yvect) THEN BEGIN
;  y_dim = SIZE(str.Y,/DIMENSIONS)
;  gdim  = WHERE(y_dim EQ 3L,gd)
;  IF (gd GT 0) THEN good = 1b ELSE good = 0b
;ENDIF
