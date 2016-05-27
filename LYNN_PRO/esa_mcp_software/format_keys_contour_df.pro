;+
;*****************************************************************************************
;
;  PROCEDURE:   format_keys_contour_df.pro
;  PURPOSE  :   This routine formats the keywords specific to the distribution function
;                 contour plotting routines, e.g. contour_3d_htr_1plane.pro.
;
;  CALLED BY:   
;               contour_3d_htr_1plane.pro
;
;  CALLS:
;               tplot_struct_format_test.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure either from get_??.pro
;                               with defined structure tag quantities for VSW
;               BGSE_HTR   :  HTR B-field structure of format:
;                               {X:Unix Times, Y:[K,3]-Element Vector}
;               VECTOR2    :  3-Element vector to be used with BGSE_HTR to define a 3D
;                               rotation matrix.  The new basis will have the following:
;                                 X'  :  parallel to BGSE_HTR
;                                 Z'  :  parallel to (BGSE_HTR x VECTOR2)
;                                 Y'  :  completes the right-handed set
;                               [Default = VSW ELSE {0.,1.,0.}]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;               NGRID      :  # of isotropic velocity grids to use to triangulate the data
;                               [Default = 30L]
;               XNAME      :  Scalar string defining the name of vector associated with
;                               the VECTOR1 input
;                               [Default = 'B!Do!N'+'[HTR]']
;               YNAME      :  Scalar string defining the name of vector associated with
;                               the VECTOR2 input
;                               [Default = 'Y']
;               SM_CUTS    :  If set, program plots the smoothed cuts of the DF
;                               [Default:  Not Smoothed]
;               NSMOOTH    :  Scalar # of points over which to smooth the DF
;                               [Default = 3]
;               ONE_C      :  If set, program makes a copy of the input array, redefines
;                               the data points equal to 1.0, and then calculates the 
;                               parallel cut and overplots it as the One Count Level
;               EX_VEC0    :  3-Element unit vector for a quantity like heat flux or
;                               a wave vector, etc.
;               EX_VN0     :  A string name associated with EX_VEC0
;                               [Default = 'Vec 1']
;               EX_VEC1    :  3-Element unit vector for another quantity like the sun
;                               direction or shock normal vector vector, etc.
;               EX_VN1     :  A string name associated with EX_VEC1
;                               [Default = 'Vec 2']
;               NOKILL_PH  :  If set, program will not call pesa_high_bad_bins.pro for
;                               PESA High structures to remove "bad" data bins
;                               [Default = 0]
;               NO_REDF    :  If set, program will plot only cuts of the distribution,
;                               not quasi-reduced distributions
;                               [Default:  program plots quasi-reduced distributions]
;               PLANE      :  Scalar string defining the plane projection to plot with
;                               corresponding cuts [Let V1 = VECTOR1, V2 = VECTOR2]
;                                 'xy'  :  horizontal axis parallel to V1 and normal
;                                            vector to plane defined by (V1 x V2)
;                                            [default]
;                                 'xz'  :  horizontal axis parallel to (V1 x V2) and
;                                            vertical axis parallel to V1
;                                 'yz'  :  horizontal axis defined by (V1 x V2) x V1
;                                            and vertical axis (V1 x V2)
;               NO_TRANS   :  If set, routine will not transform data into SW frame
;                               [Default = 0 (i.e. DAT transformed into SW frame)]
;               INTERP     :  If set, data is interpolated to original energy estimates
;                               after transforming into new reference frame
;               SM_CONT    :  If set, program plots the smoothed contours of DF
;                               [Note:  Smoothed to the minimum # of points]
;               LOG_HTR    :  Set to a named variable to return whether the calling
;                               routine should use HTR MFI data or not
;               VEC[1,2]   :  Set to a named variable to return the vectors to use for
;                               the [X,Y]-Axis
;               V_VSWS     :  Set to a named variable to return the bulk flow velocity
;                               [km/s] defined by the structure tag VSW
;               V_MAGF     :  Set to a named variable to return the 3s average magnetic
;                               field vector [nT] defined by the structure tag MAGF
;               VNAME      :  Set to a named variable to return the string defining the
;                               name associated with V_VSWS
;               BNAME      :  Set to a named variable to return the string defining the
;                               name associated with V_MAGF
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If LOG_HTR = TRUE, then VEC1 is set to 0
;               2)  See also:  contour_3d_htr_1plane.pro or contour_esa_htr_1plane.pro
;
;   CREATED:  08/08/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/08/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO format_keys_contour_df,dat,bgse_htr,vector2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                           YNAME=yname,SM_CUTS=sm_cuts,NSMOOTH=nsmooth,ONE_C=one_c,     $
                           EX_VEC0=ex_vec0,EX_VN0=ex_vn0,EX_VEC1=ex_vec1,EX_VN1=ex_vn1, $
                           NOKILL_PH=nokill_ph,NO_REDF=no_redf,PLANE=plane,             $
                           NO_TRANS=no_trans,INTERP=interpo,SM_CONT=sm_cont,            $
                           LOG_HTR=log_htr,VEC1=vec1,VEC2=vec2,V_VSWS=v_vsws,           $
                           V_MAGF=v_magf,VNAME=vname,BNAME=bname

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN

;; => Define dummy data structure to avoid changing input
data       = dat[0]
;-----------------------------------------------------------------------------------------
; => Check for finite vectors in VSW and MAGF IDL structure tags
;-----------------------------------------------------------------------------------------
v_vsws   = REFORM(data[0].VSW)
v_magf   = REFORM(data[0].MAGF)
test_v   = TOTAL(FINITE(v_vsws)) NE 3
test_b   = TOTAL(FINITE(v_magf)) NE 3

IF (test_b) THEN BEGIN
  ; => MAGF values are not finite
  v_magf       = [1.,0.,0.]
  data[0].MAGF = v_magf
  bname        = 'X!DGSE!N'
ENDIF ELSE BEGIN
  ; => MAGF values are okay
  bname        = 'B!Do!N'+'[3s]'
ENDELSE

IF (test_v) THEN BEGIN
  ; => VSW values are not finite
  v_vsws       = [0.,1.,0.]
  data[0].VSW  = v_vsws
  vname        = 'Y!DGSE!N'
  no_trans     = 1
ENDIF ELSE BEGIN
  ; => VSW values are okay
  vname        = 'V!Dsw!N'
  IF NOT KEYWORD_SET(no_trans) THEN no_trans = 0 ELSE no_trans = 1
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
;; => Define # of levels to use for contour.pro
IF NOT KEYWORD_SET(ngrid) THEN ngrid = 30L 
;; => Define velocity limit (km/s)
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*data[0].ENERGY/data[0].MASS),/NAN)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)
ENDELSE

IF NOT KEYWORD_SET(no_trans)  THEN no_trans  = 0              ELSE no_trans  = 1
IF NOT KEYWORD_SET(nokill_ph) THEN nokill_ph = 0              ELSE nokill_ph = 1
IF NOT KEYWORD_SET(sm_cuts)   THEN sm_cuts   = 0              ELSE sm_cuts   = 1
IF NOT KEYWORD_SET(nsmooth)   THEN nsmooth   = 3              ELSE nsmooth   = LONG(nsmooth)
IF NOT KEYWORD_SET(one_c)     THEN one_c     = 0              ELSE one_c     = 1
IF NOT KEYWORD_SET(no_redf)   THEN no_redf   = 0              ELSE no_redf   = no_redf[0]
IF NOT KEYWORD_SET(plane)     THEN plane     = 'xy'           ELSE plane     = STRLOWCASE(plane[0])
IF NOT KEYWORD_SET(interpo)   THEN interpo   = 0              ELSE interpo   = 1
IF NOT KEYWORD_SET(sm_cont)   THEN sm_cont   = 0              ELSE sm_cont   = 1
;-----------------------------------------------------------------------------------------
; => Check BGSE_HTR structure format
;-----------------------------------------------------------------------------------------
test  = tplot_struct_format_test(bgse_htr,/YVECT)
IF (NOT test) THEN BEGIN
  MESSAGE,nottplot_mssg,/INFORMATIONAL,/CONTINUE
  ;; => Use 3s B-field value instead
  vec1    = v_magf
  log_htr = 0
ENDIF ELSE BEGIN
  ;; => Use HTR B-field values
  vec1    = 0
  log_htr = 1
ENDELSE

IF (log_htr EQ 0) THEN BEGIN
  ;; => Use 3s B-field values
  xname = bname[0]
ENDIF ELSE BEGIN
  ;; => Use HTR B-field values
  IF NOT KEYWORD_SET(xname) THEN xname = 'B!Do!N'+'[HTR]' ELSE xname = xname[0]
ENDELSE

IF (N_ELEMENTS(vector2) NE 3) THEN BEGIN
  ; => V2 is NOT set
  yname = vname[0]
  vec2  = v_vsws
ENDIF ELSE BEGIN
  ; => V2 is set
  IF NOT KEYWORD_SET(yname) THEN yname = 'Y' ELSE yname = yname[0]
  vec2  = REFORM(vector2)
ENDELSE

;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;; => Check for EX_VEC0 and EX_VEC1
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
IF NOT KEYWORD_SET(ex_vec0)  THEN ex_vec0  = REPLICATE(f,3) ELSE ex_vec0  = FLOAT(REFORM(ex_vec0))
IF NOT KEYWORD_SET(ex_vec1)  THEN ex_vec1  = REPLICATE(f,3) ELSE ex_vec1  = FLOAT(REFORM(ex_vec1))
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;; => Check for EX_VN0 and EX_VN1
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
IF NOT KEYWORD_SET(ex_vn0)   THEN ex_vn0   = 'Vec 1'        ELSE ex_vn0   = ex_vn0[0]
IF NOT KEYWORD_SET(ex_vn1)   THEN ex_vn1   = 'Vec 2'        ELSE ex_vn1   = ex_vn1[0]
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


