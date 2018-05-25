;+
;*****************************************************************************************
;
;  PROCEDURE:   add_vsw2.pro
;  PURPOSE  :   Adds the bulk flow velocity vector (km/s) to an array of 3DP or ESA data
;                 structures obtained from get_??.pro (e.g. ?? = el, eh, sf, phb, etc.)
;                 with the tag name VSW or that defined by user through the VBULK_TAG
;                 keyword.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               test_tplot_handle.pro
;               get_data.pro
;               tplot_struct_format_test.pro
;               struct_value.pro
;               t_resample_tplot_struc.pro
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT          :  Scalar (or array) [structure] associated with a known
;                                 THEMIS ESA or SST data structure(s)
;                                 [e.g., see get_th?_p*@b.pro, ? = a-f, * = e,s @ = e,i]
;                                 or a Wind/3DP data structure(s)
;                                 [see get_?.pro, ? = el, elb, pl, ph, eh, etc.]
;                                 [Note:  VSW or VELOCITY tag must be defined]
;               SOURCE       :  Scalar [string or integer] defining the TPLOT handle
;                                 associated with the bulk flow velocity the user wishes
;                                 to add to DAT
;
;  EXAMPLES:    
;               [calling sequence]
;               add_vsw2, dat, source [,LEAVE_ALONE=leave] [,INT_THRESH=int_thr]   $
;                         [,VBULK_TAG=vbulk_tag]
;
;  KEYWORDS:    
;               LEAVE_ALONE  :  If set, routine only alters the tag values of the
;                                 structures within the time range of the specified
;                                 SOURCE
;                                 [Default:  sets values to NaNs outside time range]
;               INT_THRESH   :  If set, routine uses 20x's the ESA duration for an
;                                 interpolation threshold [used by interp.pro]
;               VBULK_TAG    :  Scalar [string] defining the structure tag within DAT
;                                 to fill with bulk flow velocity vectors
;                                 [Default = 'VSW']
;
;   CHANGED:  1)  Rewrote entire program to resemble add_magf2.pro
;                   for increased speed
;                                                                   [11/06/2008   v2.0.0]
;             2)  Changed function INTERPOL.PRO to interp.pro
;                                                                   [11/07/2008   v2.0.1]
;             3)  Updated man page
;                                                                   [06/17/2009   v2.0.2]
;             4)  Rewrote to optimize a few parts and clean up some cludgy parts
;                                                                   [06/22/2009   v2.1.0]
;             5)  Fixed syntax error
;                                                                   [08/28/2009   v2.1.1]
;             6)  Added error handling to check if DAT is a data structure and
;                   added NO_EXTRAP option to interp.pro call
;                                                                   [12/15/2011   v2.1.2]
;             7)  Updated to be in accordance with newest version of TDAS IDL libraries
;                   A)  Cleaned up and updated man page
;                   B)  Added keyword:  LEAVE_ALONE
;                   C)  Removed a lot of unnecessary code
;                   D)  Added use of INTERP_THRESHOLD in interp.pro call at 20x's the
;                         minimum duration of a particle data structure
;                                                                   [04/19/2012   v3.0.0]
;             8)  Added keyword:  INT_THRESH
;                                                                   [05/24/2012   v3.1.0]
;             9)  Updated to include new routines and improve robustness/functionality
;                                                                   [03/11/2016   v4.0.0]
;            10)  Fixed an odd issue from use of t_resample_tplot_struc.pro
;                                                                   [05/22/2018   v4.0.1]
;
;   NOTES:      
;               1)  If DAT and SOURCE time ranges do not overlap, then tag values
;                     not overlapping are changed to NaNs if LEAVE_ALONE keyword is
;                     not set
;               2)  ESA data structures do not have the VSW structure tag by default,
;                     so user must call modify_themis_esa_struc.pro on DAT prior to
;                     using this routine
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: add_vsw.pro  BY: Davin Larson
;   CREATED:  03/11/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/22/2018   v4.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO add_vsw2,dat,source,LEAVE_ALONE=leave,INT_THRESH=int_thr,VBULK_TAG=vbulk_tag

;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
vtag_on        = 0b
novswd_msg     = 'No bulk flow velocity data loaded...'
nottpn_msg     = 'Not valid TPLOT handle or structure...'
novelb_msg     = 'No bulk flow velocity data at time of data structures...'
notstr_mssg    = 'DAT must be an IDL structure...'
;;----------------------------------------------------------------------------------------
;;  Check input parameters
;;----------------------------------------------------------------------------------------
;*****************************************************************************************
ex_start       = SYSTIME(1)
;*****************************************************************************************
IF (N_PARAMS() NE 2) THEN RETURN
;;  Check DAT type
IF (SIZE(dat[0],/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_mssg[0],/CONTINUE,/INFORMATIONAL
  RETURN
ENDIF
;;  Check SOURCE
CASE SIZE(source[0],/TYPE) OF
  8    : BEGIN
    ;;  SOURCE is a structure
    velb           = source[0]
  END
  ELSE : BEGIN
    ;;  Check if SOURCE is a TPLOT handle
    test           = test_tplot_handle(source,TPNMS=tpnms,GIND=gind)
    IF (test[0] EQ 0) THEN RETURN
    ;;  Get data
    get_data,tpnms[0],DATA=velb
    test           = tplot_struct_format_test(velb,/YVECT)
    IF (test[0] EQ 0) THEN RETURN
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Define some parameters
;;----------------------------------------------------------------------------------------
n              = N_ELEMENTS(dat)
dumb           = REPLICATE(!VALUES.F_NAN,n[0],3L)
b              = FLTARR(n[0],3)
st_t           = dat.TIME
en_t           = dat.END_TIME
myavt          = (st_t + en_t)/2d0                  ;;  Avg. time of data structures
mxmn_dt        = [MIN(st_t,/NAN),MAX(en_t,/NAN)]    ;;  Time range of data structures
mxmn_bt        = [MIN(velb.X,/NAN),MAX(velb.X,/NAN)]
delt           = MIN(en_t - st_t,/NAN)*2d0          ;;  2x's minimum duration of data
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check LEAVE_ALONE
test           = ~KEYWORD_SET(leave) AND (N_ELEMENTS(leave) GT 0)
IF (test[0]) THEN kill_out_tr = 1b ELSE kill_out_tr = 0b
;;  Check INT_THRESH
IF KEYWORD_SET(int_thr) THEN BEGIN
  dtmax   = 1d1*delt[0]
ENDIF ELSE BEGIN
  dtmax   = (MAX(en_t,/NAN) - MIN(st_t,/NAN))*1d3
ENDELSE
;;  Check VBULK_TAG
test           = (SIZE(vbulk_tag,/TYPE) NE 7)
IF (test[0]) THEN veltag = 'vsw' ELSE veltag = STRLOWCASE(vbulk_tag[0])
vtag_on        = (test[0] EQ 0)
;;  Make sure tag exists within DAT
dvel0          = struct_value(dat[0],veltag[0],INDEX=index)
test           = (index[0] LT 0) AND (vtag_on[0])
IF (test[0]) THEN dvel0 = struct_value(dat[0],'vsw',INDEX=index)

IF (index[0] LT 0) THEN BEGIN
  ;;  None of the bulk flow velocity tags were found --> return
  MESSAGE,'No bulk flow velocity tag found...',/CONTINUE,/INFORMATIONAL
  RETURN
ENDIF ELSE BEGIN
  ;;  Tag found --> keep track of it
  tind = index[0]
  ttyp = SIZE(dvel0,/TYPE)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define time ranges
;;----------------------------------------------------------------------------------------
tra            = mxmn_dt + [-1d0,1d0]*delt[0]
;tra            = [MIN(dat.TIME,/NAN),MAX(dat.END_TIME,/NAN)] + [-1d0,1d0]*delt[0]
test_tt        = (st_t GT mxmn_bt[0]) AND (en_t LT mxmn_bt[1])
good           = WHERE(test_tt,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
IF (gd GT 0) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Times overlap
  ;;--------------------------------------------------------------------------------------
  d_t            = myavt
  ;;  make sure data type is float
  vsw_str        = t_resample_tplot_struc(velb,d_t,/NO_EXTRAPOLATE,/IGNORE_INT)
  vsw_v          = struct_value(vsw_str[0],'y',INDEX=vind)
  IF (is_a_number(vsw_v,/NOMSSG) EQ 0) THEN BEGIN
    ;;  Result is not numeric --> quit
    MESSAGE,'Bulk flow velocity TPLOT variable not numeric...',/CONTINUE,/INFORMATIONAL
    RETURN
  ENDIF
  ;;  Convert to proper type accepted by structure
  CASE ttyp[0] OF
    2L   :  vsw = FIX(vsw_str.Y)
    3L   :  vsw = LONG(vsw_str.Y)
    4L   :  vsw = FLOAT(vsw_str.Y)
    5L   :  vsw = DOUBLE(vsw_str.Y)
    ELSE :  BEGIN
      MESSAGE,'Not able to handle IDL type of structure tag...',/CONTINUE,/INFORMATIONAL
      RETURN
    END
  ENDCASE
  ;;--------------------------------------------------------------------------------------
  ;;  Alter all "good" values
  ;;--------------------------------------------------------------------------------------
  dat[good].(tind[0])  = TRANSPOSE(vsw[good,*])
  test                 = (kill_out_tr[0]) AND (bd GT 0)
  IF (test) THEN dat[bad].(tind[0]) = TRANSPOSE(dumb[bad,*])
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Times do not overlap --> set all to NaNs unless LEAVE_ALONE = TRUE
  ;;--------------------------------------------------------------------------------------
  MESSAGE,novelb_msg[0],/CONTINUE,/INFORMATIONAL
  IF (kill_out_tr[0]) THEN dat.(tind[0]) = TRANSPOSE(dumb)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;*****************************************************************************************
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFORMATIONAL
;*****************************************************************************************

RETURN
END



;del_t0         = dat.TIME - mxmn_bt[0]
;del_t1         = mxmn_bt[1] - dat.END_TIME
;test_tt        = (del_t0 GT 0) AND (del_t1 GT 0)
;  vswx           = interp(velb.Y[*,0],velb.X,d_t,/NO_EXTRAP,INTERP_THRESHOLD=dtmax[0])
;  vswy           = interp(velb.Y[*,1],velb.X,d_t,/NO_EXTRAP,INTERP_THRESHOLD=dtmax[0])
;  vswz           = interp(velb.Y[*,2],velb.X,d_t,/NO_EXTRAP,INTERP_THRESHOLD=dtmax[0])
;  IF (SIZE(dat.VSW,/TYPE) EQ 4L) THEN BEGIN
;    vsw = FLOAT([[vswx],[vswy],[vswz]])  ;; tag is a float
;  ENDIF ELSE BEGIN
;    vsw = DOUBLE([[vswx],[vswy],[vswz]])  ;; tag is a double
;  ENDELSE
;  dat[good].VSW  = TRANSPOSE(vsw[good,*])
;  test           = (NOT KEYWORD_SET(leave)) AND (bd GT 0)
;  IF (test) THEN dat[bad].VSW = TRANSPOSE(dumb[bad,*])
;  IF ~KEYWORD_SET(leave) THEN dat.VSW = TRANSPOSE(dumb)
;  IF ~KEYWORD_SET(leave) THEN dat.(tind[0]) = TRANSPOSE(dumb)
