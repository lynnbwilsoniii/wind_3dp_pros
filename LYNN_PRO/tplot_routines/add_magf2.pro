;+
;;****************************************************************************************
;
;  PROCEDURE:   add_magf2.pro
;  PURPOSE  :   Adds the magnetic field vector (nT) to an array of 3DP data
;                 structures obtained from get_??.pro (e.g. ?? = el, eh, sf, phb, etc.)
;                 with the tag name MAGF.  This program is vectorized and at least
;                 an order of magnitude faster than add_magf.pro for inputs being
;                 arrays of 3DP data structures.
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
;                                 [Note:  MAGF tag must be part of structure]
;               SOURCE       :  Scalar [string or integer] defining the TPLOT handle
;                                 associated with the magnetic field vector the user
;                                 wishes to add to DAT
;
;  EXAMPLES:    
;               [calling sequence]
;               add_magf2, dat, source [,LEAVE_ALONE=leave] [,INT_THRESH=int_thr]   $
;                         [,MAGF_TAG=magf_tag]
;
;               ;;;  Get ALL EESA Low Burst data structures within time range, tr
;               elb  = get_3dp_structs('elb',TRANGE=tr)
;               del  = elb.DATA
;               add_magf2,del,'wi_B3_GSE'
;
;  KEYWORDS:    
;               LEAVE_ALONE  :  If set, routine only alters the tag values of the
;                                 structures within the time range of the specified
;                                 SOURCE
;                                 [Default:  sets values to NaNs outside time range]
;               INT_THRESH   :  If set, routine uses 20x's the ESA duration for an
;                                 interpolation threshold [used by interp.pro]
;               MAGF_TAG     :  Scalar [string] defining the structure tag within DAT
;                                 to fill with magnetic field vectors
;                                 [Default = 'MAGF']
;
;   CHANGED:  1)  Rewrote entire program to vectorize as many operations as possible
;                   for increased speed
;                                                                   [11/06/2008   v2.0.0]
;             2)  Changed function INTERPOL.PRO to interp.pro
;                                                                   [11/07/2008   v2.0.1]
;             3)  Updated man page
;                                                                   [06/17/2009   v2.0.2]
;             4)  Rewrote to optimize a few parts and clean up some cludgy parts
;                                                                   [06/22/2009   v2.1.0]
;             5)  Changed a little syntax
;                                                                   [08/28/2009   v2.1.1]
;             6)  Added error handling to check if DAT is a data structure and
;                   added NO_EXTRAP option to interp.pro call
;                                                                   [12/15/2011   v2.1.2]
;             7)  Updated to be in accordance with newest version of TDAS IDL libraries
;                   A)  Cleaned up and updated man page
;                   B)  Added keyword:  LEAVE_ALONE
;                   C)  Removed a lot of unnecessary code
;                   D)  Added use of INTERP_THRESHOLD in interp.pro call
;                                                                   [04/19/2012   v3.0.0]
;             8)  Added keyword:  INT_THRESH
;                                                                   [05/24/2012   v3.1.0]
;             9)  Updated to include new routines and improve robustness/functionality
;                   and fixed an odd issue from use of t_resample_tplot_struc.pro
;                                                                   [05/22/2018   v4.0.0]
;
;   NOTES:      
;               1)  If DAT and SOURCE time ranges do not overlap, then tag values
;                     not overlapping are changed to NaNs if LEAVE_ALONE keyword is
;                     not set
;
;  REFERENCES:  
;               NA
;
;   ADAPTED FROM: add_magf.pro  BY: Davin Larson
;   CREATED:  04/27/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/22/2018   v4.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;;****************************************************************************************
;-

PRO add_magf2,dat,source,LEAVE_ALONE=leave,INT_THRESH=int_thr,MAGF_TAG=magf_tag

;;----------------------------------------------------------------------------------------
;;  Define some defaults
;;----------------------------------------------------------------------------------------
mtag_on        = 0b
notstr_mssg    = 'DAT must be an IDL structure...'
nofgmd_msg     = 'No magnetic field data loaded...'
nottpn_msg     = 'Not valid TPLOT handle or structure...'
nomagf_msg     = 'No magnetic field data at time of data structures...'
;;----------------------------------------------------------------------------------------
;;  Check input parameters
;;----------------------------------------------------------------------------------------
;;****************************************************************************************
ex_start       = SYSTIME(1)
;;****************************************************************************************
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
    magf = source[0]
  END
  7    : BEGIN
    ;;  SOURCE is a TPLOT handle
    test           = test_tplot_handle(source,TPNMS=tpnms,GIND=gind)
    IF (test[0] EQ 0) THEN RETURN
    ;;  Get data
    get_data,tpnms[0],DATA=magf
    test           = tplot_struct_format_test(magf,/YVECT,/NOMSSG)
    IF (test[0] EQ 0) THEN BEGIN
      MESSAGE,nofgmd_msg[0],/CONTINUE,/INFORMATIONAL
      RETURN
    ENDIF
  END
  ELSE : BEGIN
    MESSAGE,nottpn_msg[0],/CONTINUE,/INFORMATIONAL
    RETURN
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
mxmn_bt        = [MIN(magf.X,/NAN),MAX(magf.X,/NAN)]
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
;;  Check MAGF_TAG
test           = (SIZE(magf_tag,/TYPE) NE 7)
IF (test[0]) THEN magtag = 'magf' ELSE magtag = STRLOWCASE(magf_tag[0])
mtag_on        = (test[0] EQ 0)
;;  Make sure tag exists within DAT
dmag0          = struct_value(dat[0],magtag[0],INDEX=index)
test           = (index[0] LT 0) AND (mtag_on[0])
IF (test[0]) THEN dmag0 = struct_value(dat[0],'magf',INDEX=index)

IF (index[0] LT 0) THEN BEGIN
  ;;  None of the magnetic field tags were found --> return
  MESSAGE,'No magnetic field vector tag found...',/CONTINUE,/INFORMATIONAL
  RETURN
ENDIF ELSE BEGIN
  ;;  Tag found --> keep track of it
  tind = index[0]
  ttyp = SIZE(dmag0,/TYPE)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define time ranges
;;----------------------------------------------------------------------------------------
tra            = mxmn_dt + [-1d0,1d0]*delt[0]
test_tt        = (st_t GT mxmn_bt[0]) AND (en_t LT mxmn_bt[1])
good           = WHERE(test_tt,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
IF (gd GT 0) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Times overlap
  ;;--------------------------------------------------------------------------------------
  d_t            = myavt
  ;;  make sure data type is float
  mag_str        = t_resample_tplot_struc(magf,d_t,/NO_EXTRAPOLATE,/IGNORE_INT)
  mag_v          = struct_value(mag_str[0],'y',INDEX=vind)
  IF (is_a_number(mag_v,/NOMSSG) EQ 0) THEN BEGIN
    ;;  Result is not numeric --> quit
    MESSAGE,'Magnetic field TPLOT variable not numeric...',/CONTINUE,/INFORMATIONAL
    RETURN
  ENDIF
  ;;  Convert to proper type accepted by structure
  CASE ttyp[0] OF
    2L   :  mag =    FIX(mag_str.Y)
    3L   :  mag =   LONG(mag_str.Y)
    4L   :  mag =  FLOAT(mag_str.Y)
    5L   :  mag = DOUBLE(mag_str.Y)
    ELSE :  BEGIN
      MESSAGE,'Not able to handle IDL type of structure tag...',/CONTINUE,/INFORMATIONAL
      RETURN
    END
  ENDCASE
  ;;--------------------------------------------------------------------------------------
  ;;  Alter all "good" values
  ;;--------------------------------------------------------------------------------------
  dat[good].(tind[0])  = TRANSPOSE(mag[good,*])
  test                 = (kill_out_tr[0]) AND (bd GT 0)
  IF (test) THEN dat[bad].(tind[0]) = TRANSPOSE(dumb[bad,*])
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Times do not overlap --> set all to NaNs unless LEAVE_ALONE = TRUE
  ;;--------------------------------------------------------------------------------------
  MESSAGE,nomagf_msg[0],/CONTINUE,/INFORMATIONAL
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
