;+
;*****************************************************************************************
;
;  FUNCTION :   beam_fit___set_common_call.pro
;  PURPOSE  :   This is actual routine that changes the value associated with a
;                 common block variable.
;
;  CALLED BY:   
;               beam_fit___set_common.pro
;
;  CALLS:
;               beam_fit_keyword_com.pro
;               beam_fit_params_com.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NEW_VALUE  :  Scalar [type] that matches the format and defines a new
;                               value for the common block variable associated with
;                               INDEX
;               INDEX      :  Scalar [type] that defines which common block variable
;                               to replace with NEW_VALUE
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Continued to write routine                       [09/07/2012   v1.0.0]
;
;   NOTES:      
;               1)  User should not call this routine
;               2)  See also:  beam_fit_keyword_com.pro, beam_fit_params_com.pro
;               3)  NEW_VALUE can be an array for the following variables:
;                     VSW        :  [3]-Element array [float]
;                     VB_REG     :  [4]-Element array [float/double]
;                     DFRA       :  [2]-Element array [float/double]
;                     FILE_PREF  :  [N]-Element array [string]
;                     DEF_PREF   :  [N]-Element array [string]
;
;   CREATED:  08/30/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/07/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION beam_fit___set_common_call,new_value,index

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
status         = 0b
;;----------------------------------------------------------------------------------------
;; => Load Common Block
;;----------------------------------------------------------------------------------------
@beam_fit_keyword_com.pro
@beam_fit_params_com.pro
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2)
IF (test) THEN RETURN,status
;;----------------------------------------------------------------------------------------
;; => Define parameters
;;----------------------------------------------------------------------------------------
nval           = new_value
kk             = index[0]
status         = 1b
;;----------------------------------------------------------------------------------------
;; => Redefine/Define common block variable
;;----------------------------------------------------------------------------------------
CASE kk[0] OF
  0L   :  vlim       = nval[0]
  1L   :  ngrid      = nval[0]
  2L   :  nsmooth    = nval[0]
  3L   :  sm_cuts    = nval[0]
  4L   :  sm_cont    = nval[0]
  5L   :  dfra       = nval
  6L   :  dfmin      = nval[0]
  7L   :  dfmax      = nval[0]
  8L   :  plane      = nval[0]
  9L   :  angle      = nval[0]
  10L  :  fill       = nval[0]
  11L  :  perc_pk    = nval[0]
  12L  :  save_dir   = nval[0]
  13L  :  file_pref  = nval
  14L  :  file_midf  = nval[0]
  15L  :  vsw        = nval
  16L  :  vcmax      = nval[0]
  17L  :  v_bx       = nval[0]
  18L  :  v_by       = nval[0]
  19L  :  vb_reg     = nval
  20L  :  vbmax      = nval[0]
  21L  :  def_fill   = nval[0]
  22L  :  def_perc   = nval[0]
  23L  :  def_dfmin  = nval[0]
  24L  :  def_dfmax  = nval[0]
  25L  :  def_ngrid  = nval[0]
  26L  :  def_nsmth  = nval[0]
  27L  :  def_plane  = nval[0]
  28L  :  def_sdir   = nval[0]
  29L  :  def_pref   = nval
  30L  :  def_midf   = nval[0]
  31L  :  def_vlim   = nval[0]
  ELSE :  status     = 0b
ENDCASE
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,status
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   beam_fit___set_common.pro
;  PURPOSE  :   This routine sets the specified common block variable defined by the
;                 inputs.
;
;  CALLED BY:   
;               beam_fit_change_parameter.pro
;               beam_fit_fit_wrapper.pro
;               beam_fit_1df_plot_fit.pro
;
;  CALLS:
;               beam_fit_struc_common.pro
;               beam_fit___set_common_call.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               LOGIC   :  Scalar [string] that matches the name of a common block
;                            variable
;               VALUE   :  Scalar [type] that matches the format and defines a new value
;                            for the common block variable associated with LOGIC
;
;  EXAMPLES:    
;               ;;  To define the variable VSW, enter the following:
;               beam_fit___set_common,'vsw',[-400.,0.,0.]
;
;  KEYWORDS:    
;               STATUS  :  Set to a named variable to return the status of the program
;                            0  :  Failed to change/set common block variable
;                            1  :  Successfully changed/set common block variable
;
;   CHANGED:  1)  Continued to write routine                       [08/30/2012   v1.0.0]
;             2)  Continued to write routine                       [09/07/2012   v1.0.0]
;
;   NOTES:      
;               1)  VALUE can be an array for the following variables:
;                     VSW        :  [3]-Element array [float]
;                     VB_REG     :  [4]-Element array [float/double]
;                     DFRA       :  [2]-Element array [float/double]
;                     FILE_PREF  :  [N]-Element array [string]
;                     DEF_PREF   :  [N]-Element array [string]
;               2)  See also:  beam_fit_keyword_com.pro, beam_fit_params_com.pro,
;                              beam_fit_unset_common.pro, beam_fit___get_common.pro,
;                              beam_fit_struc_common.pro
;
;   CREATED:  08/29/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/07/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO beam_fit___set_common,logic,value,STATUS=status

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
status         = 0b

;;  Define strings associated with all the common block variables available
key_com_str    = ['vlim','ngrid','nsmooth','sm_cuts','sm_cont','dfra','dfmin','dfmax',$
                  'plane','angle','fill','perc_pk','save_dir','file_pref','file_midf']
key_par_str    = ['vsw','vcmax','v_bx','v_by','vb_reg','vbmax','def_fill','def_perc', $
                  'def_dfmin','def_dfmax','def_ngrid','def_nsmth','def_plane',        $
                  'def_sdir','def_pref','def_midf','def_vlim']
;key_par_str    = ['vsw','vcmax','v_bx','v_by','vb_reg','def_fill','def_perc','def_dfmin',$
;                  'def_dfmax','def_ngrid','def_nsmth','def_plane','def_sdir','def_pref', $
;                  'def_midf','def_vlim']
key_all_str    = [key_com_str,key_par_str]
nkey           = N_ELEMENTS(key_all_str)
;;  Define a dummy array with null strings
key_def_str    = REPLICATE('',nkey)
;;  Define default type codes for each common block variable
;;    => Result of SIZE([variable],/TYPE)
def_types      = [5L,3L,3L,2L,2L,5L,5L,5L,7L,5L,5L,5L,7L,7L,7L,4L,5L,5L,5L,5L,5L,5L,5L,$
                  5L,5L,3L,3L,7L,7L,7L,7L,5L]
;;  Define default # of elements for each common block variable
def_elmnt      = [1L,1L,1L,1L,1L,2L,1L,1L,1L,1L,1L,1L,1L,10L,1L,3L,1L,1L,1L,4L,1L,1L,1L,$
                  1L,1L,1L,1L,1L,1L,10L,1L,1L]
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR ((N_ELEMENTS(logic) EQ 0) AND (N_ELEMENTS(value) EQ 0))
IF (test) THEN RETURN
;;----------------------------------------------------------------------------------------
;; => Get common block variables in structure form
;;----------------------------------------------------------------------------------------
dumb           = beam_fit_struc_common(DEFINED=defined)
test           = (SIZE(dumb,/TYPE) NE 8)
IF (test) THEN RETURN
;;  Find the common block variable index associated with LOGIC
log            = STRLOWCASE(logic[0])
nv             = N_ELEMENTS(value)
test           = (key_all_str EQ log[0])
good_all       = WHERE(test,gdall,COMPLEMENT=bad_all,NCOMPLEMENT=bdall)
IF (gdall GT 0) THEN BEGIN
  index          = good_all[0]
  IF (nv GT 1) THEN nval = value ELSE nval = value[0]
  status         = beam_fit___set_common_call(nval,index)
ENDIF
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
