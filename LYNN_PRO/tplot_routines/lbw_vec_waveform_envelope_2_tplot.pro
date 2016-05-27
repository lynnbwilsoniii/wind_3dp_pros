;*****************************************************************************************
;
;  FUNCTION :   lbw_wrapper_envelope_2_tplot.pro
;  PURPOSE  :   This is a wrapping routine for the storing of data in TPLOT sent from
;                 lbw_vec_waveform_envelope_2_tplot.pro
;
;  CALLED BY:   
;               lbw_vec_waveform_envelope_2_tplot.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               find_vector_waveform_envelope.pro
;               store_data.pro
;               options.pro
;               tnames.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME      :  [N]-Element [double] array of time [s] abscissa points for
;                              each field vector component in FIELD
;               VECTOR    :  [N,3]-Element [float/double] array of data points defining
;                              the vectors (i.e., V^3) for each timestamp in TIME
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               OUT_TPN   :  Scalar [string or integer] defining the base TPLOT handle
;                              to use on output with the suffixes associated with the
;                              envelope, its smoothed version, and the median filtered
;                              version.  These strings will define the output TPLOT
;                              handles.
;                              [Default = TPNAME]
;               X_LOAD    :  If set, routine will send the envelope of the x-component
;                              to TPLOT
;                              [Default = FALSE]
;               Y_LOAD    :  If set, routine will send the envelope of the y-component
;                              to TPLOT
;                              [Default = FALSE]
;               Z_LOAD    :  If set, routine will send the envelope of the z-component
;                              to TPLOT
;                              [Default = FALSE]
;               A_LOAD    :  If set, routine will send the envelopes of all components
;                              to TPLOT
;                              [Default = FALSE]
;               TPN_INT   :  Scalar [long/integer] defining the interval number to be
;                              converted to a string suffix of the form:
;                              '_int'+STRTRIM(STRING(tpn_int[0],FORMAT='(I)'),2)
;               YTTLE     :  Scalar [string] defining the Y-Axis title to use for output
;                              TPLOT handles YTITLE keywords
;               YSUBT     :  Scalar [string] defining the Y-Axis subtitle to use for
;                              output TPLOT handles YTITLE keywords
;               TPNS_OUT  :  Set to a named variable to return the TPLOT handles stored
;                              after completion of this routine
;               ************************************************************
;               ***  keywords used by find_vector_waveform_envelope.pro  ***
;               ************************************************************
;               SM_WIDTH  :  Scalar [long] defining the width (i.e., # of array elements)
;                              to use for smoothing the lower and upper bounds of the
;                              waveform envelope
;                              [Default = 3]
;               RM_EDGES  :  If set, routine sets the start and end envelope values to
;                              NaNs.  This is useful for filtered data that has
;                              artificial divergences at the start/end of the time
;                              series due to the filtering.
;                              [Default = FALSE]
;               *********************************************
;               ***  keywords used by partition_data.pro  ***
;               *********************************************
;               LENGTH    :  Scalar [long] defining the # of elements to use when
;                              defining the time ranges for partitioning the data to
;                              find the envelope around the waveform
;                              [Default = 4]
;               OFFSET    :  Scalar [long] defining the # of elements to shift from the
;                              start of each time stamp
;                              [Default = 4]
;
;   CHANGED:  1)  Fixed a typo in the Man. page
;                                                                   [08/14/2015   v1.0.1]
;
;   NOTES:      
;               1)  User should not call this routine alone
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/11/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/14/2015   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION lbw_wrapper_envelope_2_tplot,time,vector,OUT_TPN=out_tpn,X_LOAD=x_load, $
                                      Y_LOAD=y_load,Z_LOAD=z_load,A_LOAD=a_load, $
                                      TPN_INT=tpn_int,YTTLE=yttle,YSUBT=ysubt,   $
                                      SM_WIDTH=sm_width,RM_EDGES=rm_edges,       $   ;;  ***  keywords used by find_vector_waveform_envelope.pro  ***
                                      LENGTH=length,OFFSET=offset,               $   ;;  ***  keywords used by partition_data.pro  ***
                                      TPNS_OUT=tpns_out                              ;;  ***  Output Keywords  ***

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, find_vector_waveform_envelope, tnames
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_midnms     = ['x','y','z','v']
def_suffxs     = 'env_'+['vals','vals_sm','vals_med']
def_load       = [0b,0b,0b,1b]
env_labs       = ['lower','upper']
env_cols       = [ 50,250]
;;  LABFLAG settings:  defines lable positions
;;    2  :  locations at vertical location of last component data point shown
;;    1  :  equally spaced with zeroth component at bottom
;;    0  :  no labels shown
;;   -1  :  equally spaced with zeroth component at top
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:env_cols,LABELS:env_labs,LABFLAG:1}
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TPN_INT
test           = (N_ELEMENTS(tpn_int) LT 1) OR (is_a_number(tpn_int,/NOMSSG) EQ 0)
IF (test[0]) THEN tpn_suffx = '' ELSE tpn_suffx = '_int'+STRTRIM(STRING(tpn_int[0],FORMAT='(I)'),2)
;;  Check YTTLE
test           = (N_ELEMENTS(yttle) LT 1) OR (SIZE(yttle,/TYPE) NE 7)
IF (test[0]) THEN test_yttl = 0b ELSE test_yttl = 1b
;;  Check YSUBT
test           = (N_ELEMENTS(ysubt) LT 1) OR (SIZE(ysubt,/TYPE) NE 7)
IF (test[0]) THEN test_ysub = 0b ELSE test_ysub = 1b
;;  Check X_LOAD
load_comps     = def_load
test           = (N_ELEMENTS(x_load) GT 0) AND KEYWORD_SET(x_load)
IF (test[0]) THEN load_comps[0] = 1b
;;  Check Y_LOAD
test           = (N_ELEMENTS(y_load) GT 0) AND KEYWORD_SET(y_load)
IF (test[0]) THEN load_comps[1] = 1b
;;  Check Z_LOAD
test           = (N_ELEMENTS(z_load) GT 0) AND KEYWORD_SET(z_load)
IF (test[0]) THEN load_comps[2] = 1b
;;  Check A_LOAD
test           = (N_ELEMENTS(a_load) GT 0) AND KEYWORD_SET(a_load)
IF (test[0]) THEN load_comps[*] = 1b
;;----------------------------------------------------------------------------------------
;;  Calculate envelopes
;;----------------------------------------------------------------------------------------
envs           = find_vector_waveform_envelope(time,vector,SM_WIDTH=sm_width,   $
                                               RM_EDGES=rm_edges,LENGTH=length, $
                                               OFFSET=offset)
test           = (SIZE(envs,/TYPE) NE 8)
IF (test[0]) THEN RETURN,0b          ;;  Assume error messages were handled by find_vector_waveform_envelope.pro
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
;;  Define # of components and time stamps
n_comps        = N_TAGS(envs) - 1L
env__t         = envs.TIME                ;;  Unix times for all envelopes
bad            = (load_comps EQ 0b)
;;  Define strings for keywords on output
smwd           = sm_width[0]
rmed           = rm_edges[0]
elen           = length[0]
shft           = offset[0]
rmed_str       = (['w__edges','wo_edges'])[rmed[0]]        ;;  w = with, wo = without
smwd_str       = STRTRIM(STRING(smwd[0],FORMAT='(I)'),2)
elen_str       = STRTRIM(STRING(elen[0],FORMAT='(I)'),2)
shft_str       = STRTRIM(STRING(shft[0],FORMAT='(I)'),2)
;;  Define extras for Y-Axis titles
len_shf_tpn    = 'len_'+elen_str[0]+'_shft_'+shft_str[0]+'_'+rmed_str[0]
smmd_wd_tpn    = ['','_'+['sm_','mdfilt_']+'width_'+smwd_str[0]]
;;  Define extras for Y-Axis titles
len_shf_yttl   = '[Ln.: '+elen_str[0]+'pts, Sh.: '+shft_str[0]+'pts]'
smmd_wd_yttl   = ['','['+['Smooth','Med. Filt.']+': '+smwd_str[0]+'pts]']
yttl_pref      = 'Env. of '

FOR cc=0L, n_comps[0] - 1L DO BEGIN
  t_comp = envs.(cc+1L)
  IF (bad[cc]) THEN CONTINUE              ;;  Skip to next component
  ;;--------------------------------------------------------------------------------------
  ;;  User wishes to load this component --> define variables and send to TPLOT
  ;;--------------------------------------------------------------------------------------
  ;;  Define envelope results for this component
  env__v         = t_comp.ENV_VALS
  env__v_sm      = t_comp.ENV_VALS_SM
  env__v_md      = t_comp.ENV_VALS_MED
  ;;  Define TPLOT structures
  vals_struc     = {X:env__t,Y:env__v}
  v_sm_struc     = {X:env__t,Y:env__v_sm}
  v_md_struc     = {X:env__t,Y:env__v_md}
  strucs         = {T0:vals_struc,T1:v_sm_struc,T2:v_md_struc}
  ;;  Define TPLOT handles
  tpnout_pref    = out_tpn[0]+'_'+def_midnms[cc]+'_'+len_shf_tpn[0]
  tpnouts        = tpnout_pref[0]+smmd_wd_tpn+tpn_suffx[0]
  ;;  Define subtitles
  IF (test_ysub[0]) THEN BEGIN
    ;;  Add to subtitle
    t_ysubt = ysubt[0]+'!C'+len_shf_yttl[0]+'!C'+smmd_wd_yttl
  ENDIF ELSE BEGIN
    ;;  Define subtitles since not present
    t_ysubt = len_shf_yttl[0]+'!C'+smmd_wd_yttl
  ENDELSE
  ;;  Define titles
  IF (test_yttl[0]) THEN BEGIN
    ;;  Add to title
    t_yttl = yttl_pref[0]+'!C'+yttle[0]
  ENDIF ELSE BEGIN
    ;;  Define title since not present
    t_yttl = yttl_pref[0]+'data'
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  Send to TPLOT
  ;;--------------------------------------------------------------------------------------
  n_tpn          = N_ELEMENTS(smmd_wd_tpn)
  FOR j=0L, n_tpn[0] - 1L DO BEGIN
    store_data,tpnouts[j],DATA=strucs.(j),DLIM=def_dlim,LIM=def__lim
    ;;  Add/Replace YSUBTITLE
    options,tpnouts[j],YSUBTITLE=t_ysubt[j],/DEF
  ENDFOR
  ;;  Add/Replace YTITLE
  options,tpnouts,YTITLE=t_yttl[0],/DEF
  ;;  Add to output TPLOT handles
  IF (cc EQ 0) THEN tpns_out = tnames(tpnouts) ELSE tpns_out = [tpns_out,tnames(tpnouts)]
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,envs
END

;+
;*****************************************************************************************
;
;  PROCEDURE:   lbw_vec_waveform_envelope_2_tplot.pro
;  PURPOSE  :   This routine takes a TPLOT handle associated with a vector time series
;                 of data, computes the lower/upper envelope of the vectors (by component
;                 if desired), and then sends the results to TPLOT.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               lbw_wrapper_envelope_2_tplot.pro
;
;  CALLS:
;               is_a_number.pro
;               tnames.pro
;               get_data.pro
;               str_element.pro
;               sample_rate.pro
;               t_interval_find.pro
;               lbw_wrapper_envelope_2_tplot.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TPNAME    :  Scalar [string or integer] defining the TPLOT handle for
;                              which the user wishes to find the outer envelope
;
;  EXAMPLES:    
;               tpname         = 'thc_efw_l1_cal_tdas_corrected_rmspikes_dsl'
;               sm_width       = 3L        ;;  Smooth envelope over 3 points
;               rm_edges       = 1b        ;;  remove edges to eliminate extrapolations
;               length         = 128L      ;;  envelope window width = 128 points
;               offset         = 128L      ;;  shift by 128 points for each new envelope window
;               a_load         = 1b        ;;  load envelopes for all vector components
;               sep_int        = 1b        ;;  create unique TPLOT handles for each interval
;               lbw_vec_waveform_envelope_2_tplot,tpname,OUT_TPN=out_tpn,SEP_INT=sep_int,$
;                                                 X_LOAD=x_load,Y_LOAD=y_load,           $
;                                                 Z_LOAD=z_load,A_LOAD=a_load,           $
;                                                 SM_WIDTH=sm_width,RM_EDGES=rm_edges,   $
;                                                 LENGTH=length,OFFSET=offset,           $
;                                                 TPNS_OUT=tpns_out
;
;  KEYWORDS:    
;               OUT_TPN   :  Scalar [string or integer] defining the base TPLOT handle
;                              to use on output with the suffixes associated with the
;                              envelope, its smoothed version, and the median filtered
;                              version.  These strings will define the output TPLOT
;                              handles.
;                              [Default = TPNAME]
;               SEP_INT   :  If set, routine will separate intervals and add suffixes
;                              to OUT_TPN numbering the intervals.  The result will be
;                              an array of TPLOT handles with the # of elements defined
;                              by the # of intervals.
;                              [Default = FALSE]
;               X_LOAD    :  If set, routine will send the envelope of the x-component
;                              to TPLOT
;                              [Default = FALSE]
;               Y_LOAD    :  If set, routine will send the envelope of the y-component
;                              to TPLOT
;                              [Default = FALSE]
;               Z_LOAD    :  If set, routine will send the envelope of the z-component
;                              to TPLOT
;                              [Default = FALSE]
;               A_LOAD    :  If set, routine will send the envelopes of all components
;                              to TPLOT
;                              [Default = FALSE]
;               TPNS_OUT  :  Set to a named variable to return the TPLOT handles stored
;                              after completion of this routine
;               ************************************************************
;               ***  keywords used by find_vector_waveform_envelope.pro  ***
;               ************************************************************
;               SM_WIDTH  :  Scalar [long] defining the width (i.e., # of array elements)
;                              to use for smoothing the lower and upper bounds of the
;                              waveform envelope
;                              [Default = 3]
;               RM_EDGES  :  If set, routine sets the start and end envelope values to
;                              NaNs.  This is useful for filtered data that has
;                              artificial divergences at the start/end of the time
;                              series due to the filtering.
;                              [Default = FALSE]
;               *********************************************
;               ***  keywords used by partition_data.pro  ***
;               *********************************************
;               LENGTH    :  Scalar [long] defining the # of elements to use when
;                              defining the time ranges for partitioning the data to
;                              find the envelope around the waveform
;                              [Default = 4]
;               OFFSET    :  Scalar [long] defining the # of elements to shift from the
;                              start of each time stamp
;                              [Default = 4]
;
;   CHANGED:  1)  Fixed a typo in the Man. page
;                                                                   [08/14/2015   v1.0.1]
;
;   NOTES:      
;               1)  The X, Y, and Z notation used above and herein is shorthand for the
;                     1st, 2nd, and 3rd components of a vector, respectively
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/11/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/14/2015   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO lbw_vec_waveform_envelope_2_tplot,tpname,OUT_TPN=out_tpn,SEP_INT=sep_int,    $
                                      X_LOAD=x_load,Y_LOAD=y_load,Z_LOAD=z_load, $
                                      A_LOAD=a_load,                             $
                                      SM_WIDTH=sm_width,RM_EDGES=rm_edges,       $   ;;  ***  keywords used by find_vector_waveform_envelope.pro  ***
                                      LENGTH=length,OFFSET=offset,               $   ;;  ***  keywords used by partition_data.pro  ***
                                      TPNS_OUT=tpns_out                              ;;  ***  Output Keywords  ***

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, tnames, sample_rate, t_interval_find
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
def_midnms     = ['x','y','z','v']
def_suffxs     = 'env_'+['vals','vals_sm','vals_med']
def_load       = [0b,0b,0b,1b]
env_labs       = ['lower','upper']
env_cols       = [ 50,250]
;;  LABFLAG settings:  defines lable positions
;;    2  :  locations at vertical location of last component data point shown
;;    1  :  equally spaced with zeroth component at bottom
;;    0  :  no labels shown
;;   -1  :  equally spaced with zeroth component at top
def__lim       = {YSTYLE:1,PANEL_SIZE:2.,XMINOR:5,XTICKLEN:0.04,YTICKLEN:0.01}
def_dlim       = {SPEC:0,COLORS:env_cols,LABELS:env_labs,LABFLAG:1}
;;  Dummy error messages
no_inpt_msg    = 'User must supply a TPLOT handle as a string or integer...'
no_tpns_mssg   = 'No TPLOT handles match TPNAME input...'
not_tpn_mssg   = 'Not a valid TPLOT handle: TPNAME...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR  $
                 ((SIZE(tpname,/TYPE) NE 7) AND (is_a_number(tpname,/NOMSSG) EQ 0))
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;  Check for TPLOT handle
tpns           = tnames(tpname)
good           = WHERE(tpns NE '',gd)
test           = (gd[0] EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_tpns_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define relevant variables
;;----------------------------------------------------------------------------------------
g_tpns         = tpns[good[0]]
get_data,g_tpns[0],DATA=temp,DLIM=dlim,LIM=lim
test           = (SIZE(temp,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,not_tpn_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
time           = temp.X
vector         = temp.Y
;;----------------------------------------------------------------------------------------
;;  Check for YTITLE and YSUBTITLE
;;----------------------------------------------------------------------------------------
str_element,dlim,'YTITLE',temp_yttl
test           = (N_ELEMENTS(temp_yttl) LT 1) OR (SIZE(temp_yttl,/TYPE) NE 7)
IF (test[0]) THEN str_element,lim,'YTITLE',temp_yttl
str_element,dlim,'YSUBTITLE',temp_ysub
test           = (N_ELEMENTS(temp_ysub) LT 1) OR (SIZE(temp_ysub,/TYPE) NE 7)
IF (test[0]) THEN str_element,lim,'YSUBTITLE',temp_ysub
;;  Define logic for later use
test_yttl      = (N_ELEMENTS(temp_yttl) GT 0) AND (SIZE(temp_yttl,/TYPE) EQ 7)
test_ysub      = (N_ELEMENTS(temp_ysub) GT 0) AND (SIZE(temp_ysub,/TYPE) EQ 7)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check OUT_TPN
test           = (N_ELEMENTS(out_tpn) GT 0) AND (SIZE(out_tpn,/TYPE) EQ 7)
IF (test[0]) THEN out_thandle = out_tpn[0] ELSE out_thandle = g_tpns[0]
;;  Make sure OUT_TPN is a valid name
test           = (IDL_VALIDNAME(out_thandle[0]) EQ out_thandle[0])
IF (test[0]) THEN out_thandle = IDL_VALIDNAME(out_thandle[0],/CONVERT_ALL)
;;  Check SEP_INT
test           = (N_ELEMENTS(sep_int) GT 0) AND KEYWORD_SET(sep_int)
IF (test[0]) THEN get_ints = 1b ELSE get_ints = 0b
;;----------------------------------------------------------------------------------------
;;  Check for intervals
;;----------------------------------------------------------------------------------------
nt             = N_ELEMENTS(time)
ind_all        = LINDGEN(nt)
IF (get_ints[0]) THEN BEGIN
  ;;  Get intervals
  srate  = sample_rate(time,GAP_THRESH=1d0,/AVE,OUT_MED_AVG=sr_medavg)
  test   = (srate[0] LE 0) OR (FINITE(srate[0]) EQ 0) OR (N_ELEMENTS(sr_medavg) LT 2)
  IF (test[0]) THEN BEGIN
    ;;  Guess at median sample period
    med_dt = 1d0
  ENDIF ELSE BEGIN
    ;;  Define median sample period
    med_sr = sr_medavg[0]
    med_dt = 1d0/med_sr[0]
  ENDELSE
  ;;  Define start/end elements of intervals
  se_int = t_interval_find(time,GAP_THRESH=2d0*med_dt[0],/NAN)
  test   = (se_int[0] LT 0) OR (N_ELEMENTS(se_int) LT 2)
  IF (test[0]) THEN ints_on = 0b ELSE ints_on = 1b
ENDIF ELSE BEGIN
  ;;  Do not get intervals --> find envelopes for all
  ints_on = 0b
ENDELSE
IF (ints_on[0]) THEN n_int = N_ELEMENTS(se_int[*,0]) ELSE n_int = 1L
;;----------------------------------------------------------------------------------------
;;  Calculate envelopes
;;----------------------------------------------------------------------------------------
FOR ii=0L, n_int[0] - 1L DO BEGIN
  IF (ints_on[0]) THEN BEGIN
    se      = REFORM(se_int[ii,*])
    tpn_int = ii[0]
  ENDIF ELSE BEGIN
    se      = [MIN(ind_all,/NAN),MAX(ind_all,/NAN)]
  ENDELSE
  gind = ind_all[se[0]:se[1]]
  t_in = time[gind]
  v_in = vector[gind,*]
  ;;  Calculate envelopes and send to TPLOT
  envs = lbw_wrapper_envelope_2_tplot(t_in,v_in,OUT_TPN=out_thandle[0],X_LOAD=x_load,  $
                                      Y_LOAD=y_load,Z_LOAD=z_load,A_LOAD=a_load,       $
                                      TPN_INT=tpn_int,YTTLE=temp_yttl,YSUBT=temp_ysub, $
                                      SM_WIDTH=sm_width,RM_EDGES=rm_edges,             $
                                      LENGTH=length,OFFSET=offset,TPNS_OUT=tpnouts     )
  ;;  Add to output TPLOT handles
  IF (ii EQ 0) THEN tpns_out = tnames(tpnouts) ELSE tpns_out = [tpns_out,tnames(tpnouts)]
ENDFOR
;;  Remove any null TPLOT handles
good           = WHERE(tpns_out NE '',gd)
IF (gd GT 0) THEN tpns_out = tpns_out[good]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END











