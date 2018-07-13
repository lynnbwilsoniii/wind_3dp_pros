;+
;*****************************************************************************************
;
;  FUNCTION :   t_resample_mms_dist_tplot_struc.pro
;  PURPOSE  :   This is a wrapping routine for t_resample_tplot_struc.pro that allows
;                 a user to resample the MMS FPI distributions on a new time grid
;                 because t_resample_tplot_struc.pro cannot handle the V3 tag.
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
;               t_get_struc_unix.pro
;               struct_value.pro
;               t_resample_tplot_struc.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries; and
;               2)  latest SPEDAS libraries
;
;  INPUT:
;               DATA            :  Scalar [structure] defining a valid TPLOT structure
;                                    the the user wishes to resample (in time) on the
;                                    new time grid defined by NEW_T.  The routine expects
;                                    this structure to conform to the TPLOT structures
;                                    returned by mms_load_fpi.pro for the 'dist' datatype.
;                                    The structure must have the following format:
;                                      X  :  [N]-Element array of Unix times
;                                      Y  :  [N,Z,L,E]-Element array of data values
;                                      V1 :  [N,Z]-Element array of azimuthal angle bin values [deg]
;                                      V2 :  [L]-Element array of poloidal angle bin values [deg]
;                                      V3 :  [N,E]-Element array of energy bin values [eV]
;               NEW_T           :  [K]-Element [long/float/double] array of new
;                                    abscissa values to which DATA will be interpolated
;                                    [e.g., x_k in F(x_k)]
;
;  EXAMPLES:    
;               [calling sequence]
;               newstr = t_resample_mms_dist_tplot_struc(data, new_t [,/LSQUADRATIC] $
;                                               [,/QUADRATIC] [,/ISPLINE]            $
;                                               [,/NO_EXTRAPOLATE] [,/IGNORE_INT]    )
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
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  See also:  trange_clip_data.pro, resample_2d_vec.pro, and
;                              t_resample_tplot_struc.pro
;               2)  Can handle data sets with gaps, but assumes NEW_T is continuous
;                     without gaps
;               3)  Assumes NEW_T is a Unix time
;               4)  Will ignore DY or any other tags in structure besides:
;                     X, Y, V1, V2, and V3
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/12/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/12/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_resample_mms_dist_tplot_struc,data,new_t,LSQUADRATIC=lsquadratic,  $
                                         QUADRATIC=quadratic,ISPLINE=ispline, $
                                         NO_EXTRAPOLATE=no_extrapolate,       $
                                         IGNORE_INT=ignore_int

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
;;  Not extracted tags
excpt_tags     = ['X','Y','V','V1','V2','DY','TSHIFT']
;;  Dummy error messages
no_inpt_msg    = 'User must supply an IDL TPLOT structure...'
baddfor_msg    = 'Incorrect input format:  DATA must be a MMS FPI TPLOT structure'
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
test           = tplot_struct_format_test(data,TEST__V=test__v,TEST_V1_V2=test_v1_v2,$
                                          TEST_DY=test_dy,TEST_V123=test_v123,/NOMSSG)
IF (~test[0] OR ~test_v123[0]) THEN BEGIN
  MESSAGE,baddfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define parameters
;;----------------------------------------------------------------------------------------
nt             = N_TAGS(data)
unix           = t_get_struc_unix(data,TSHFT_ON=tshft_on)     ;;  [N]-Element array of Unix times
IF (tshft_on[0]) THEN BEGIN
  tshift         = struct_value(data,'TSHIFT',DEFAULT=0d0)
ENDIF ELSE BEGIN
  tshift         = 0d0
ENDELSE
;;  Define structure parameters
v1             = data.V1              ;;  [N,Z]-Element array of azimuthal angle bin values [deg]
v2             = data.V2              ;;  [L]-Element array of poloidal angle bin values [deg]
v3             = data.V3              ;;  [N,E]-Element array of energy bin values [eV]
dats           = data.Y               ;;  [N,Z,L,E]-Element array of data
nph            = N_ELEMENTS(v1[0,*])  ;;  Z  :  # of azimuthal bins
nth            = N_ELEMENTS(v2)       ;;  L  :  # of latitudinal/poloidal bins
nes            = N_ELEMENTS(v3[0,*])  ;;  E  :  # of energy bins
;;  Sort OLD_T
sp             = SORT(unix)
xx             = unix[sp]
yy             = dats[sp,*,*,*]
vv1            = v1[sp,*]
vv2            = v2
vv3            = v3[sp,*]
;;  Sort NEW_T
newt           = REFORM(new_t)
sp             = SORT(newt)
xout           = newt[sp]
nx             = N_ELEMENTS(xout)
;;  Clean up
dats           = 0
newt           = 0 & unix = 0 & v1 = 0 & v2 = 0 & v3 = 0 & sp = 0
;;----------------------------------------------------------------------------------------
;;  Interpolate data
;;----------------------------------------------------------------------------------------
;;  Define dummy arrays
new_yy         = REPLICATE(d,nx[0],nph[0],nth[0],nes[0])
new_v1         = REPLICATE(d,nx[0],nph[0])
new_v3         = REPLICATE(d,nx[0],nes[0])
exp_yy         = SIZE(REFORM(new_yy[*,*,0,*]),/DIMENSIONS)
exp_v1         = SIZE(new_v1,/DIMENSIONS)
exp_v3         = SIZE(new_v3,/DIMENSIONS)
;;  Loop through poloidal bins
FOR ll=0L, nth[0] - 1L DO BEGIN
  ;;  Define dummy structure to use for interpolation
  dumb    = {X:xx,Y:REFORM(yy[*,*,ll,*]),V1:vv1,V2:vv3}
  ;;  Interpolate L-th poloidal bin
  temp    = t_resample_tplot_struc(dumb,xout,LSQUADRATIC=lsquadratic,QUADRATIC=quadratic,$
                                   ISPLINE=ispline,NO_EXTRAPOLATE=no_extrapolate,        $
                                   IGNORE_INT=ignore_int)
  ;;  Check if routine failed
  IF (SIZE(temp,/TYPE) NE 8) THEN CONTINUE
  ;;  Make sure the output structure format is correct
  szdyy   = SIZE(temp.Y,/DIMENSIONS)
  szdv1   = SIZE(temp.V1,/DIMENSIONS)
  szdv3   = SIZE(temp.V2,/DIMENSIONS)
  test    = (TOTAL(szdyy EQ exp_yy) NE 3) OR (TOTAL(szdv1 EQ exp_v1) NE 3) OR $
            (TOTAL(szdv3 EQ exp_v3) NE 3)
  IF (test[0]) THEN CONTINUE
  ;;  Fill variables
  new_yy[*,*,ll,*] = REFORM(temp.Y,nx[0],nph[0],1L,nes[0])
  IF (ll[0] EQ 0) THEN BEGIN
    ;;  Should only need to do this once
    new_v1 = temp.V1
    new_v3 = temp.V2
  ENDIF
  ;;  Reset variables
  dumb    = 0
  temp    = 0
ENDFOR
;;  Clean up
dumb           = 0
temp           = 0
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
xx             = xout - tshift[0]
IF (tshft_on[0]) THEN BEGIN
  output = {X:xx,Y:new_yy,V1:new_v1,V2:vv2,V3:new_v3,TSHIFT:tshift[0]}
ENDIF ELSE BEGIN
  output = {X:xx,Y:new_yy,V1:new_v1,V2:vv2,V3:new_v3}
ENDELSE
;;  Clean up
new_yy         = 0
new_v1         = 0 & new_v3 = 0 & xx = 0 & vv2 = 0
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,output
END
