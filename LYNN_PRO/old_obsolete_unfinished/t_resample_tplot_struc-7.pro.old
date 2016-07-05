;+
;*****************************************************************************************
;
;  FUNCTION :   t_resample_tplot_struc.pro
;  PURPOSE  :   This routine interpolates an input TPLOT structure, DATA, to a new set
;                 of time stamps, NEW_T, and returns a TPLOT structure containing data
;                 at the new time stamps.  If an error occurs or the input format is
;                 incorrect, then the routine will return a scalar zero.  The routine
;                 allows for linear, quadratic, least-squares quadratic, or cubic spline
;                 fit interpolation schemes.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               tplot_struct_format_test.pro
;               str_element.pro
;               sample_rate.pro
;               t_interval_find.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA            :  Scalar [structure] defining a valid TPLOT structure
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
;                                    If the TSHIFT tag is present, the routine will assume
;                                    that NEW_T is a Unix time and DATA.X is seconds from
;                                    DATA.TSHIFT[0].
;               NEW_T           :  [K]-Element [long/float/double] array of new
;                                    abscissa values to which DATA will be interpolated
;                                    [e.g., x_k in F(x_k)]
;
;  EXAMPLES:    
;               [calling sequence]
;               newstr = t_resample_tplot_struc(data, new_t [,/LSQUADRATIC] $
;                                               [,/QUADRATIC] [,/ISPLINE]   $
;                                               [,/NO_EXTRAPOLATE])
;
;               ;;  Linear interpolation example
;               newstr = t_resample_tplot_struc(data,new_t,/NO_EXTRAPOLATE)
;
;  KEYWORDS:    
;               LSQUADRATIC     :  If set, routine will use a least squares quadratic
;                                    fit to the equation y = a + bx + cx^2, for each
;                                    4 point neighborhood
;                                    [Default = FALSE]
;               QUADRATIC       :  If set, routine will use a least squares quadratic
;                                    fit to the equation y = a + bx + cx^2, for each
;                                    3 point neighborhood
;                                    [Default = FALSE]
;               ISPLINE         :  If set, routine will use a cubic spline for each
;                                    4 point neighborhood
;                                    [Default = FALSE]
;               NO_EXTRAPOLATE  :  If set, program will not extrapolate end points
;                                    [Default = FALSE]
;               IGNORE_INT      :  If set, program will not find the subintervals within
;                                    the input time series array individually, it will
;                                    just use the entire time range and interpolate if
;                                    it overlaps with the output time steps
;                                    [Default = FALSE]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [11/10/2015   v1.0.0]
;             2)  Continued to write routine
;                                                                   [11/10/2015   v1.0.0]
;             3)  Now uses new functionality of tplot_struct_format_test.pro for handling
;                   of V or V1 and V2 structure tags
;                   and no longer calls str_element.pro
;                                                                   [11/28/2015   v1.1.0]
;             4)  Cleaned up a bit
;                                                                   [11/28/2015   v1.1.1]
;             5)  Fixed a bug that occurs when # of good overlapping intervals does not
;                   equal the total # of intervals found
;                                                                   [01/12/2016   v1.1.2]
;             6)  Routine can now handle TSHIFT structure tag for TPLOT structures
;                                                                   [04/21/2016   v1.2.0]
;             7)  Added keyword:  IGNORE_INT
;                                                                   [05/17/2016   v1.3.0]
;
;   NOTES:      
;               1)  See also:  trange_clip_data.pro, resample_2d_vec.pro
;               2)  Now handles data sets with gaps, but assumes NEW_T is continuous
;                     without gaps
;               3)  Assumes NEW_T is a Unix time
;
;  REFERENCES:  
;               NA
;
;   CREATED:  11/10/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/17/2016   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_resample_tplot_struc,data,new_t,LSQUADRATIC=lsquadratic,QUADRATIC=quadratic,  $
                                           ISPLINE=ispline,NO_EXTRAPOLATE=no_extrapolate,$
                                           IGNORE_INT=ignore_int

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, tplot_struct_format_test, sample_rate, t_interval_find
;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy logic variables
test_vv        = 0b
test_vv_2d     = 0b
test_v1        = 0b
test_v2        = 0b
;;  Dummy error messages
no_inpt_msg    = 'User must supply an IDL TPLOT structure...'
baddfor_msg    = 'Incorrect input format:  DATA must be an IDL TPLOT structure'
baddinp_msg    = 'Incorrect input:  DATA must be a valid TPLOT structure with numeric times and data'
bad_tra_msg    = 'Could not define proper time range... Exiting without computation...'
nod_tra_msg    = 'No data within user specified time range... Exiting without computation...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (SIZE(data,/TYPE) NE 8) OR $
                 (is_a_number(new_t,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check if TPLOT structure
test           = tplot_struct_format_test(data,TEST__V=test__v,TEST_V1_V2=test_v1_v2,/NOMSSG)
IF (test[0] EQ 0) THEN BEGIN
  MESSAGE,baddfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define parameters
;;----------------------------------------------------------------------------------------
nt             = N_TAGS(data)
time           = data.X            ;;  [N]-Element array of Unix times
dats           = data.Y            ;;  [N [,M , L]]-Element array of data
str_element,data,'TSHIFT',tshift
newt           = REFORM(new_t)
szdt           = SIZE(time,/DIMENSIONS)
szdd           = SIZE(dats,/DIMENSIONS)
sznd           = SIZE(dats,/N_DIMENSIONS)
sznnt          = SIZE(newt,/N_DIMENSIONS)
;;  Make sure data format is okay
test           = (szdt[0] NE szdd[0]) OR (is_a_number(time,/NOMSSG) EQ 0) OR $
                 (is_a_number(dats,/NOMSSG) EQ 0) OR (sznnt[0] NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,baddinp_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check interpolation types
i_type         = [0L,KEYWORD_SET(lsquadratic),KEYWORD_SET(quadratic),KEYWORD_SET(spline)]
good_it        = WHERE(i_type,gdit)
IF (gdit GT 1) THEN BEGIN
  ;;  More than one option is set --> Default to the one first set
  i_type = good_it[0]
ENDIF ELSE BEGIN
  ;;  One or fewer options are set
  IF (gdit GT 0) THEN BEGIN
    ;;  One option is set
    i_type = good_it[0]
  ENDIF ELSE BEGIN
    ;;  No options were set --> Use linear interpolation
    i_type = 0
  ENDELSE
ENDELSE
;;  Check IGNORE_INT
test           = KEYWORD_SET(ignore_int) AND (N_ELEMENTS(ignore_int) GT 0)
IF (test[0]) THEN no_int_find = 1b ELSE no_int_find = 0b
;;----------------------------------------------------------------------------------------
;;  Check for other time-dependent structure tags
;;----------------------------------------------------------------------------------------
;;  Check for V
test_vv_2d     = (test__v[0] EQ 2)
IF (test__v[0] GT 0) THEN BEGIN
  vv         = data.V
ENDIF ELSE test_vv = 0b
;;  Check for V1 and V2
v1_v2_on       = test_v1_v2[0]
IF (v1_v2_on[0]) THEN BEGIN
  ;;  Both V1 and V2 present --> define variables
  v1             = data.V1
  v2             = data.V2
ENDIF
;;----------------------------------------------------------------------------------------
;;  Sort time stamps [just in case]
;;----------------------------------------------------------------------------------------
sp             = SORT(time)
xx_in          = time[sp]
CASE sznd[0] OF
  1    :  yy = dats[sp]          ;;  [N]-Element array
  2    :  yy = dats[sp,*]        ;;  [N,M]-Element array
  3    :  yy = dats[sp,*,*]      ;;  [N,M,L]-Element array
  ELSE : STOP  ;;  What did you do?  --> debug
ENDCASE
;;  Check for V or V1 AND V2
IF (test_vv[0]) THEN BEGIN
  IF (test_vv_2d[0]) THEN BEGIN
    ;;  V is 2D
    vvout          = vv[sp,*]
  ENDIF ELSE BEGIN
    ;;  V is 1D  -->  Assume 1st dimension is independent of # of time stamps
    vvout          = vv
  ENDELSE
ENDIF
IF (v1_v2_on[0]) THEN BEGIN
  ;;  Both V1 and V2 present and correctly formatted
  v1out          = v1[sp,*]      ;;  [N,M]-Element array
  v2out          = v2[sp,*]      ;;  [N,L]-Element array
ENDIF
;;  Sort time stamps [just in case]
sp             = SORT(newt)
xout           = newt[sp]
IF (N_ELEMENTS(tshift) GT 0) THEN xout -= tshift[0]  ;;  Remove TSHIFT (if present)
nx             = N_ELEMENTS(xout)
;;----------------------------------------------------------------------------------------
;;  First, check for intervals
;;    --> in case of burst data, do not want to use absolute TRANGE
;;  Second, check for overlaps
;;    --> if exist, then keep only overlapping intervals and toss the rest
;;----------------------------------------------------------------------------------------
srate          = sample_rate(xx_in,/AVERAGE)
xperd          = 1.5d0/srate[0]
;se_int         = t_interval_find(xx_in,GAP_THRESH=xperd[0],/NAN)
IF (no_int_find[0]) THEN BEGIN
  ;;  User does not want to worry about intervals --> use all input data points
  se_int         = TRANSPOSE([0L,(N_ELEMENTS(xx_in) - 1L)])
ENDIF ELSE BEGIN
  se_int         = t_interval_find(xx_in,GAP_THRESH=xperd[0],/NAN)
ENDELSE
n__int         = N_ELEMENTS(se_int[*,0])
se_unx         = xx_in[se_int]
;mnmx           = [1d30,-1d30]
overln         = REPLICATE(0b,n__int)
FOR ii=0L, n__int[0] - 1L DO BEGIN
  se_tra     = REFORM(se_unx[ii,*])
  test       = (xout GE se_tra[0]) AND (xout LE se_tra[1])
  good       = WHERE(test,gd)
  overln[ii] = (gd[0] GT 0)
ENDFOR
good_int       = WHERE(overln,gd_int,COMPLEMENT=bad_int,NCOMPLEMENT=bd_int)
IF (gd_int[0] GT 0) THEN BEGIN
  ;;  Found overlaping intervals
  yes_overlap = 1b
  ;;  Redefine input ranges
  good_se     = se_int[good_int,*]
  good_st     = REFORM(good_se[*,0])
  good_en     = REFORM(good_se[*,1])
  ni          = good_en - good_st + 1L    ;;  # of elements in each good interval
  ind         = LINDGEN(ni[0]) + good_st[0]
  IF (gd_int[0] GT 1) THEN FOR ii=1L, gd_int[0] - 1L DO ind = [ind,LINDGEN(ni[ii]) + good_st[ii]]
;  IF (gd_int[0] GT 1) THEN FOR ii=1L, n__int[0] - 1L DO ind = [ind,LINDGEN(ni[ii]) + good_st[ii]]
  unq         = UNIQ(ind,SORT(ind))
  ind         = TEMPORARY(ind[unq])
  sp          = SORT(ind)
  ind         = TEMPORARY(ind[sp])
  xx_in       = TEMPORARY(xx_in[ind])
  CASE sznd[0] OF
    1    :  BEGIN
      yy   = TEMPORARY(yy[ind])                     ;;  [N]-Element array
    END
    2    :  BEGIN
      yy   = TEMPORARY(yy[ind,*])                   ;;  [N,M]-Element array
      IF (test_vv[0]) THEN BEGIN
        IF (test_vv_2d[0]) THEN vvout = TEMPORARY(vvout[ind,*])
      ENDIF
    END
    3    :  BEGIN
      yy   = TEMPORARY(yy[ind,*,*])                 ;;  [N,M,L]-Element array
      IF (v1_v2_on[0]) THEN BEGIN
        v1out = TEMPORARY(v1out[ind,*])
        v2out = TEMPORARY(v2out[ind,*])
      ENDIF
    END
  ENDCASE
ENDIF ELSE BEGIN
  ;;  No overlaping intervals --> kill all
  yes_overlap = 0b
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define dummy outputs
;;----------------------------------------------------------------------------------------
CASE sznd[0] OF
  1    :  BEGIN
    yout = REPLICATE(d,nx)
  END
  2    :  BEGIN
    yout = REPLICATE(d,nx,szdd[1])                ;;  [N,M]-Element array
    vout = REPLICATE(d,nx,szdd[1])
  END
  3    :  BEGIN
    yout = REPLICATE(d,nx,szdd[1],szdd[2])        ;;  [N,M,L]-Element array
    vv1  = REPLICATE(d,nx,szdd[1])                ;;  [N,M]-Element array
    vv2  = REPLICATE(d,nx,szdd[2])                ;;  [N,L]-Element array
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Interpolate
;;----------------------------------------------------------------------------------------
lsquad         = 0b & quad = 0b & ispl = 0b
CASE i_type[0] OF
  0L   :                ;;  Linearly interpolate
  1L   :  lsquad = 1b   ;;  Least-squares quadratic interpolation
  2L   :  quad   = 1b   ;;  Quadratic interpolation
  3L   :  ispl   = 1b   ;;  Cubic spline interpolation
  ELSE :  BEGIN
    ;;  Incorrect choice of interpolation type
    weird_mssg = 'I am not sure how this happened... Using linear interpolation'
    MESSAGE,weird_mssg[0],/INFORMATIONAL,/CONTINUE
  END
ENDCASE
int_str        = {LSQUADRATIC:lsquad,QUADRATIC:quad,SPLINE:ispl}
;;  Interpolate [IFF overlaps exist]
IF (yes_overlap[0]) THEN BEGIN
  CASE sznd[0] OF
    1    :  BEGIN
      ;;  1D array --> just find new Y values
      yout = INTERPOL(yy,xx_in,xout,_EXTRA=int_str)
    END
    2    :  BEGIN
      ;;  2D array --> may have V tag
      FOR d2=0L, szdd[1] - 1L DO BEGIN
        yout[*,d2] = INTERPOL(yy[*,d2],xx_in,xout,_EXTRA=int_str)
        IF (test_vv[0]) THEN BEGIN
          IF (test_vv_2d[0]) THEN BEGIN
            vout[*,d2] = INTERPOL(vvout[*,d2],xx_in,xout,_EXTRA=int_str)
          ENDIF ELSE BEGIN
            vout[*,d2] = vvout
          ENDELSE
        ENDIF
      ENDFOR
    END
    3    :  BEGIN
      FOR d2=0L, szdd[1] - 1L DO BEGIN
        FOR d3=0L, szdd[2] - 1L DO BEGIN
          yout[*,d2,d3] = INTERPOL(yy[*,d2,d3],xx_in,xout,_EXTRA=int_str)
          IF (v1_v2_on[0]) THEN vv2[*,d3] = INTERPOL(v2out[*,d3],xx_in,xout,_EXTRA=int_str)
        ENDFOR
        IF (v1_v2_on[0]) THEN vv1[*,d2] = INTERPOL(v1out[*,d2],xx_in,xout,_EXTRA=int_str)
      ENDFOR
    END
  ENDCASE
ENDIF
;;----------------------------------------------------------------------------------------
;;  Remove end points if they were extrapolated
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(no_extrapolate) NE 0) AND KEYWORD_SET(no_extrapolate)
IF (test[0] AND yes_overlap[0]) THEN BEGIN
  CASE sznd[0] OF
    1    :  test  = FINITE(yy)
    2    :  BEGIN
      ;;  2D array --> may have V tag
      test  = FINITE(yy[*,0])
      FOR d2=1L, szdd[1] - 1L DO test = test OR FINITE(yy[*,d2])    ;;  Should I use AND instead or is that too restrictive?
    END
    3    :  BEGIN
      test  = FINITE(yy[*,0,0])
      FOR d2=1L, szdd[1] - 1L DO BEGIN
        FOR d3=1L, szdd[2] - 1L DO test = test OR FINITE(yy[*,d2,d3])
      ENDFOR
    END
  ENDCASE
  ;;  Define time-stamp elements associated with finite data
  good  = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
  IF (gd GT 0) THEN BEGIN
    ;;  Remove end points
    mnmx  = [MIN(xx_in[good],/NAN),MAX(xx_in[good],/NAN)]
    test  = (xout LT mnmx[0]) OR (xout GT mnmx[1])
    bad   = WHERE(test,bd)
  ENDIF
  ;;  Remove any and all "bad" points
  IF (bd GT 0) THEN BEGIN
    CASE sznd[0] OF
      1    :  yout[bad]     = f
      2    :  yout[bad,*]   = f
      3    :  yout[bad,*,*] = f
    ENDCASE
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
test           = (v1_v2_on[0] OR test_vv[0])
IF (test[0]) THEN BEGIN
  ;;  Either V or V1 AND V2 are present
  IF (v1_v2_on[0]) THEN BEGIN
    ;;  V1 AND V2 are present
    struc          = {X:xout,Y:yout,V1:vv1,V2:vv2}
  ENDIF ELSE BEGIN
    ;;  V is present
    struc          = {X:xout,Y:yout,V:vout}
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Only X and Y tags are present or correctly set
  struc          = {X:xout,Y:yout}
ENDELSE
;;  Check for TSHIFT
IF (N_ELEMENTS(tshift) GT 0) THEN str_element,struc,'TSHIFT',tshift[0],/ADD_REPLACE  ;;  Add TSHIFT (if present)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END


