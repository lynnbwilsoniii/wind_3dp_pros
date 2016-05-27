;+
;*****************************************************************************************
;
;  FUNCTION :   beam_fit_struc_common.pro
;  PURPOSE  :   This routine returns a structure containing tags defined by the
;                 values associated with the common block variables.
;
;  CALLED BY:   
;               beam_fit___get_common.pro
;
;  CALLS:
;               beam_fit_keyword_com.pro
;               beam_fit_params_com.pro
;               beam_fit_struc_create.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               test  = beam_fit_struc_common(DEFINED=defined)
;
;  KEYWORDS:    
;               DEFINED  :  Set to a named variable to return an array where each
;                             element [set to TRUE or FALSE] shows whether the
;                             associated common block variable is defined
;
;   CHANGED:  1)  Continued to write routine                       [08/31/2012   v1.0.0]
;             2)  Continued to write routine                       [09/07/2012   v1.0.0]
;
;   NOTES:      
;               1)  User should not call this routine
;               2)  See also:  beam_fit_keyword_com.pro, beam_fit_params_com.pro
;
;   CREATED:  08/30/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/07/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION beam_fit_struc_common,DEFINED=defined

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
s              = ''
l              = -1L
b              = -1b

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
all_types      = LONARR(nkey)  ;; Dummy array
all_nels       = LONARR(nkey)
defined        = REPLICATE(0b,nkey)  ;; logic
;;  Define default type codes for each common block variable
;;    => Result of SIZE([variable],/TYPE)
def_types      = [5L,3L,3L,2L,2L,5L,5L,5L,7L,5L,5L,5L,7L,7L,7L,4L,5L,5L,5L,5L,5L,5L,5L,$
                  5L,5L,3L,3L,7L,7L,7L,7L,5L]
;;  Define default # of elements for each common block variable
def_elmnt      = [1L,1L,1L,1L,1L,2L,1L,1L,1L,1L,1L,1L,1L,10L,1L,3L,1L,1L,1L,4L,1L,1L,1L,$
                  1L,1L,1L,1L,1L,1L,10L,1L,1L]
;;----------------------------------------------------------------------------------------
;; => Load Common Block
;;----------------------------------------------------------------------------------------
@beam_fit_keyword_com.pro
@beam_fit_params_com.pro
;;----------------------------------------------------------------------------------------
;; => Determine which, if any, common block variables are defined
;;----------------------------------------------------------------------------------------
;;  Define # of elements associated with each common block variable
;;    [0 = undefined]
nele_key       = [N_ELEMENTS(vlim),N_ELEMENTS(ngrid),N_ELEMENTS(nsmooth),              $
                  N_ELEMENTS(sm_cuts),N_ELEMENTS(sm_cont),N_ELEMENTS(dfra),            $
                  N_ELEMENTS(dfmin),N_ELEMENTS(dfmax),N_ELEMENTS(plane),               $
                  N_ELEMENTS(angle),N_ELEMENTS(fill),N_ELEMENTS(perc_pk),              $
                  N_ELEMENTS(save_dir),N_ELEMENTS(file_pref),                          $
                  N_ELEMENTS(file_midf)]
nele_par       = [N_ELEMENTS(vsw),N_ELEMENTS(vcmax),N_ELEMENTS(v_bx),N_ELEMENTS(v_by), $
                  N_ELEMENTS(vb_reg),N_ELEMENTS(vbmax),N_ELEMENTS(def_fill),           $
                  N_ELEMENTS(def_perc),N_ELEMENTS(def_dfmin),N_ELEMENTS(def_dfmax),    $
                  N_ELEMENTS(def_ngrid),N_ELEMENTS(def_nsmth),N_ELEMENTS(def_plane),   $
                  N_ELEMENTS(def_sdir),N_ELEMENTS(def_pref),N_ELEMENTS(def_midf),      $
                  N_ELEMENTS(def_vlim)]
neles          = [nele_key,nele_par]
;;  Define the type code associated with each common block variable
;;    [0 = undefined]
type_key       = [SIZE(vlim,/TYPE),SIZE(ngrid,/TYPE),SIZE(nsmooth,/TYPE),              $
                  SIZE(sm_cuts,/TYPE),SIZE(sm_cont,/TYPE),SIZE(dfra,/TYPE),            $
                  SIZE(dfmin,/TYPE),SIZE(dfmax,/TYPE),SIZE(plane,/TYPE),               $
                  SIZE(angle,/TYPE),SIZE(fill,/TYPE),SIZE(perc_pk,/TYPE),              $
                  SIZE(save_dir,/TYPE),SIZE(file_pref,/TYPE),SIZE(file_midf,/TYPE)]
type_par       = [SIZE(vsw,/TYPE),SIZE(vcmax,/TYPE),SIZE(v_bx,/TYPE),SIZE(v_by,/TYPE), $
                  SIZE(vb_reg,/TYPE),SIZE(vbmax,/TYPE),SIZE(def_fill,/TYPE),           $
                  SIZE(def_perc,/TYPE),SIZE(def_dfmin,/TYPE),SIZE(def_dfmax,/TYPE),    $
                  SIZE(def_ngrid,/TYPE),SIZE(def_nsmth,/TYPE),SIZE(def_plane,/TYPE),   $
                  SIZE(def_sdir,/TYPE),SIZE(def_pref,/TYPE),SIZE(def_midf,/TYPE),      $
                  SIZE(def_vlim,/TYPE)]
types          = [type_key,type_par]
;;  Determine variables that are defined
defined        = (types NE 0)
;;  Find all the common block variables that are defined
good_all       = WHERE(types NE 0,gdall,COMPLEMENT=bad_all,NCOMPLEMENT=bdall)
;;----------------------------------------------------------------------------------------
;;  Define the type codes and # of elements in each
;;----------------------------------------------------------------------------------------
IF (gdall GT 0) THEN BEGIN
  all_types[good_all]  =  types[good_all]
  all_nels[good_all]   =  neles[good_all]
  IF (bdall GT 0) THEN BEGIN
    ;; Fill in missing values
    all_types[bad_all]   =  def_types[bad_all]
    all_nels[bad_all]    =  def_elmnt[bad_all]
  ENDIF
ENDIF ELSE BEGIN
  ;; None of the variables have been defined yet
  all_types            =  def_types
  all_nels             =  def_elmnt
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define a structure to hold all the common block variables
;;----------------------------------------------------------------------------------------
dumb           = beam_fit_struc_create(all_types,all_nels,TAGS=key_all_str)
IF (SIZE(dumb,/TYPE) NE 8) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;  Fill the structure with all the common block variable values
;;----------------------------------------------------------------------------------------
nt             = N_TAGS(dumb)
IF (nt NE nkey) THEN RETURN,0b      ;; something went very wrong...
IF (gdall EQ 0) THEN RETURN,dumb    ;; return structure format

FOR j=0L, gdall - 1L DO BEGIN
  kk = good_all[j]
  CASE kk[0] OF
    0L   :  dumb.(kk[0]) = vlim
    1L   :  dumb.(kk[0]) = ngrid
    2L   :  dumb.(kk[0]) = nsmooth
    3L   :  dumb.(kk[0]) = sm_cuts
    4L   :  dumb.(kk[0]) = sm_cont
    5L   :  dumb.(kk[0]) = dfra
    6L   :  dumb.(kk[0]) = dfmin
    7L   :  dumb.(kk[0]) = dfmax
    8L   :  dumb.(kk[0]) = plane
    9L   :  dumb.(kk[0]) = angle
    10L  :  dumb.(kk[0]) = fill
    11L  :  dumb.(kk[0]) = perc_pk
    12L  :  dumb.(kk[0]) = save_dir
    13L  :  dumb.(kk[0]) = file_pref
    14L  :  dumb.(kk[0]) = file_midf
    15L  :  dumb.(kk[0]) = vsw
    16L  :  dumb.(kk[0]) = vcmax
    17L  :  dumb.(kk[0]) = v_bx
    18L  :  dumb.(kk[0]) = v_by
    19L  :  dumb.(kk[0]) = vb_reg
    20L  :  dumb.(kk[0]) = vbmax
    21L  :  dumb.(kk[0]) = def_fill
    22L  :  dumb.(kk[0]) = def_perc
    23L  :  dumb.(kk[0]) = def_dfmin
    24L  :  dumb.(kk[0]) = def_dfmax
    25L  :  dumb.(kk[0]) = def_ngrid
    26L  :  dumb.(kk[0]) = def_nsmth
    27L  :  dumb.(kk[0]) = def_plane
    28L  :  dumb.(kk[0]) = def_sdir
    29L  :  dumb.(kk[0]) = def_pref
    30L  :  dumb.(kk[0]) = def_midf
    31L  :  dumb.(kk[0]) = def_vlim
    ELSE : 
  ENDCASE
ENDFOR
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,dumb
END

;;  vlim
;;  ngrid
;;  nsmooth
;;  sm_cuts
;;  sm_cont
;;  dfra
;;  dfmin
;;  dfmax
;;  plane
;;  angle
;;  fill
;;  perc_pk
;;  save_dir
;;  file_pref
;;  file_midf
;;  vsw
;;  vcmax
;;  v_bx
;;  v_by
;;  vb_reg
;;  vbmax
;;  def_fill
;;  def_perc
;;  def_dfmin
;;  def_dfmax
;;  def_ngrid
;;  def_nsmth
;;  def_plane
;;  def_sdir
;;  def_pref
;;  def_midf
;;  def_vlim
