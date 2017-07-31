;+
;*****************************************************************************************
;
;  FUNCTION :   vbulk_change_test_cont_str_form.pro
;  PURPOSE  :   This routine tests the structure format of the plotting structure whose
;                 tags correspond to keywords for general_vdf_contour_plot.pro in
;                 addition to a few extra.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               vbulk_change_get_default_struc.pro
;               tag_names_r.pro
;               struct_value.pro
;               str_element.pro
;               structure_compare.pro
;               convert_num_type.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               CONT_STR   :  Scalar [structure] containing the following tags defining
;                               all of the current plot settings for the contour and
;                               1D cut plots:
;                                 VFRAME     :  [3]-Element [float/double] array defining
;                                                 the 3-vector velocity of the K'-frame
;                                                 relative to the K-frame [km/s] to use
;                                                 to transform the velocity distribution
;                                                 into the bulk flow reference frame
;                                                 [ Default = [0,0,0] ]
;                                 VEC1       :  [3]-Element vector to be used for
;                                                 "parallel" direction in a 3D rotation
;                                                 of the input data
;                                                 [e.g. see rotate_3dp_structure.pro]
;                                                 [ Default = [1.,0.,0.] ]
;                                 VEC2       :  [3]--Element vector to be used with VEC1
;                                                 to define a 3D rotation matrix.  The
;                                                 new basis will have the following:
;                                                   X'  :  parallel to VEC1
;                                                   Z'  :  parallel to (VEC1 x VEC2)
;                                                   Y'  :  completes the right-handed set
;                                                 [ Default = [0.,1.,0.] ]
;                                 VLIM       :  Scalar [numeric] defining the velocity
;                                                 [km/s] limit for x-y velocity axes over
;                                                 which to plot data
;                                                 [Default = 1e3]
;                                 NLEV       :  Scalar [numeric] defining the # of
;                                                 contour levels to plot
;                                                 [Default = 30L]
;                                 XNAME      :  Scalar [string] defining the name of
;                                                 vector associated with
;                                                 the VEC1 input
;                                                 [Default = 'X']
;                                 YNAME      :  Scalar [string] defining the name of
;                                                 vector associated with
;                                                 the VEC2 input
;                                                 [Default = 'Y']
;                                 SM_CUTS    :  If set, program smoothes the cuts of the
;                                                 VDF before plotting
;                                                 [Default = FALSE]
;                                 SM_CONT    :  If set, program smoothes the contours of
;                                                 the VDF before
;                                                 plotting
;                                                 [Default = FALSE]
;                                 NSMCUT     :  Scalar [numeric] defining the # of points
;                                                 over which to smooth the 1D cuts of the
;                                                 VDF before plotting
;                                                 [Default = 3]
;                                 NSMCON     :  Scalar [numeric] defining the # of points
;                                                 over which to smooth the 2D contour of
;                                                 the VDF before plotting
;                                                 [Default = 3]
;                                 PLANE      :  Scalar [string] defining the plane
;                                                 projection to plot with corresponding
;                                                 cuts [Let V1 = VEC1, V2 = VEC2]
;                                                   'xy'  :  horizontal axis parallel to
;                                                              V1 and normal vector to
;                                                              plane defined by (V1 x V2)
;                                                              [default]
;                                                   'xz'  :  horizontal axis parallel to
;                                                              (V1 x V2) and vertical
;                                                              axis parallel to V1
;                                                   'yz'  :  horizontal axis defined by
;                                                              (V1 x V2) x V1 and
;                                                              vertical axis (V1 x V2)
;                                                 [Default = 'xy']
;                                 DFMIN      :  Scalar [numeric] defining the minimum
;                                                 allowable phase space density to plot,
;                                                 which is useful for ion distributions
;                                                 with large angular gaps in data
;                                                 (prevents lower bound from falling
;                                                 below DFMIN)
;                                                 [Default = 1d-20]
;                                 DFMAX      :  Scalar [numeric] defining the maximum
;                                                 allowable phase space density to plot,
;                                                 which is useful for distributions with
;                                                 data spikes (prevents upper bound from
;                                                 exceeding DFMAX)
;                                                 [Default = 1d-2]
;                                 DFRA       :  [2]-Element [numeric] array specifying
;                                                 the VDF range in phase space density
;                                                 [e.g., # s^(+3) km^(-3) cm^(-3)] for
;                                                 the cuts and contour plots
;                                                 [Default = [DFMIN,DFMAX]]
;                                 V_0X       :  Scalar [float/double] defining the
;                                                 velocity [km/s] along the X-Axis
;                                                 (horizontal) to shift the location
;                                                 where the perpendicular (vertical) cut
;                                                 of the VDF will be performed
;                                                 [Default = 0.0]
;                                 V_0Y       :  Scalar [float/double] defining the
;                                                 velocity [km/s] along the Y-Axis
;                                                 (vertical) to shift the location where
;                                                 the parallel (horizontal) cut of the
;                                                 VDF will be performed
;                                                 [Default = 0.0]
;                                 SAVE_DIR   :  Scalar [string] defining the directory
;                                                 where the plots will be stored
;                                                 [Default = FILE_EXPAND_PATH('')]
;                                 FILE_PREF  :  [N]-Element array [string] defining the
;                                                 prefix associated with each PostScript
;                                                 plot on output
;                                                 [Default = 'VDF_ions']
;                                 FILE_MIDF  :  Scalar [string] defining the plane of
;                                                 projection and number grids used for
;                                                 contour plot levels
;                                                 [Default = 'V1xV2xV1_vs_V1_xxGrids_']
;
;  EXAMPLES:    
;               [calling sequence]
;               test = vbulk_change_test_cont_str_form(cont_str [,DAT_OUT=dat_out])
;
;  KEYWORDS:    
;               DAT_OUT    :  Set to a named variable to return the correctly formatted
;                               version of CONT_STR that has the expected structure tags,
;                               IDL type codes, and dimensions
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [05/23/2017   v1.0.0]
;
;   NOTES:      
;               1)  This is meant to be called by other routines within the
;                     Vbulk Change library of routines
;
;  REFERENCES:  
;               NA
;
;   CREATED:  05/17/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/23/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vbulk_change_test_cont_str_form,cont_str,DAT_OUT=dat_out

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_min        = 5b                          ;;  Min. allowed output from structure_compare.pro
;;  Define default structure format
def_struct     = vbulk_change_get_default_struc()
;;  Define required tags and types
def_tags       = tag_names_r(def_struct,TYPE=def_types,COUNT=def_nt)
def_tags       = STRLOWCASE(def_tags)
;;  Define number and size of dimensions
def_ddims      = 0
def_ndims      = LONARR(def_nt[0])
FOR j=0L, def_nt[0] - 1L DO BEGIN
  val          = struct_value(def_struct,def_tags[j],INDEX=ind)
  IF (ind[0] GE 0) THEN BEGIN
    def_ndims[j] = SIZE(val,/N_DIMENSIONS)
    dims         = SIZE(val,/DIMENSIONS)
    str_element,def_ddims,def_tags[j],dims,/ADD_REPLACE
  ENDIF
ENDFOR
;;  Dummy error messages
notstr1msg     = 'User must input CONT_STR as a scalar IDL structure...'
notstr2msg     = 'CONT_STR must be a scalar IDL structure...'
badstr_msg0    = 'CONT_STR must have the following structure tags:  '
badstr_msg1    = STRUPCASE(def_tags)
badstr_msg2    = 'CONT_STR must have the same format as that returned by vbulk_change_get_default_struc.pro...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
test           = (N_ELEMENTS(cont_str)  EQ 0) OR (N_PARAMS() NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr1msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check input type
str            = cont_str[0]
test           = (SIZE(str,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr2msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Verify # of structure tags
tags           = STRLOWCASE(TAG_NAMES(str[0]))
nt             = N_ELEMENTS(tags)
test           = (nt[0] LT def_nt[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badstr_msg0[0],/INFORMATIONAL,/CONTINUE
  FOR j=0L, def_nt[0] - 1L DO PRINT,'%%  '+badstr_msg1[j]
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check input against default structure for minimum requirements
;;----------------------------------------------------------------------------------------
value_out      = structure_compare(def_struct,str,EXACT=exact,MATCH_NT=match_nt,    $
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,             $
                                   MATCH__L=match__l,MATCH_DL=match_dl,             $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt          )
test           = (value_out[0] LT def_min[0]) AND (numovr_tg[0] LT def_nt[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badstr_msg2[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Redefine, if necessary, structure tag TYPE and DIMENSIONS to match requirements
;;----------------------------------------------------------------------------------------
FOR j=0L, nt[0] - 1L DO BEGIN
  good         = WHERE(tags[j] EQ def_tags,gd)
  IF (gd[0] GT 0) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Good structure tag
    ;;------------------------------------------------------------------------------------
    val          = struct_value(str,tags[j],INDEX=ind)
    def_val      = struct_value(def_struct,def_tags[good[0]],INDEX=d_ind)
    ;;------------------------------------------------------------------------------------
    ;;  First verify default
    ;;------------------------------------------------------------------------------------
    IF (d_ind[0] LT 0) THEN BEGIN
      def_val0 = MAKE_ARRAY(def_ndims[good[0]],TYPE=def_types[good[0]])
      IF (N_ELEMENTS(def_val0) EQ 1) THEN def_val = def_val0[0] ELSE def_val = def_val0
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Now check structure tag format
    ;;------------------------------------------------------------------------------------
    IF (ind[0] GE 0) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Tag found --> Check value format
      ;;----------------------------------------------------------------------------------
      check = [(SIZE(val,/TYPE) NE def_types[good[0]]),(SIZE(val,/N_DIMENSIONS) NE def_ndims[good[0]])]
      bad   = WHERE(check,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
      IF (bd[0] GT 0) THEN BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Bad format --> Check dimensions and type
        ;;--------------------------------------------------------------------------------
        IF (bd[0] GT 1) THEN BEGIN
          ;;  Bad format --> reset to default
          str_element,str,tags[j],def_val,/ADD_REPLACE
        ENDIF ELSE BEGIN
          ;;  See if it's just a type issue --> convert type
          IF (bad[0] EQ 0 AND SIZE(val,/TYPE) NE 7) THEN BEGIN
            ;;  Convert type
            n_val = convert_num_type(val,def_types[good[0]],/NO_ARRAY)
            str_element,str,tags[j],n_val,/ADD_REPLACE
          ENDIF ELSE BEGIN
            ;;  Nope, bad input --> reset to default
            str_element,str,tags[j],def_val,/ADD_REPLACE
          ENDELSE
        ENDELSE
      ENDIF ELSE BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Good format so far --> Check dimensions
        ;;--------------------------------------------------------------------------------
        dims = SIZE(val,/DIMENSIONS)
        test = 0b
        FOR k=0L, def_ndims[good[0]] - 1L DO test += TOTAL(dims[k] NE def_ddims.(j)[k])
        IF (test[0] GT 0) THEN str_element,str,tags[j],def_val,/ADD_REPLACE  ;;  Bad format --> reset to default
      ENDELSE
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Tag not found --> reset to default
      ;;----------------------------------------------------------------------------------
      str_element,str,tags[j],def_val,/ADD_REPLACE
    ENDELSE
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Remove irrelevant structure tag
    ;;------------------------------------------------------------------------------------
    str_element,str,tags[j],/DELETE
  ENDELSE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define output structure to ensure proper format in future use
;;----------------------------------------------------------------------------------------
dat_out        = str[0]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END
