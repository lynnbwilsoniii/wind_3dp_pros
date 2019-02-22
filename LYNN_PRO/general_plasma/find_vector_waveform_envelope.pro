;+
;*****************************************************************************************
;
;  FUNCTION :   find_vector_waveform_envelope.pro
;  PURPOSE  :   This routine finds the outer envelope of a three-component vector time
;                 series of data, e.g., an electric field waveform.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               format_2d_vec.pro
;               partition_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TIME        :  [N]-Element [double] array of time [s] abscissa points for
;                                each field vector component in FIELD
;               VECTOR      :  [N,3]-Element [float/double] array of data points defining
;                                the 3-vectors for each timestamp in TIME
;
;  EXAMPLES:    
;               test = find_vector_waveform_envelope(time,vector,SM_WIDTH=sm_width,  $
;                                                    RM_EDGES=rm_edges,LENGTH=length,$
;                                                    OFFSET=offset)
;
;  KEYWORDS:    
;               SM_WIDTH    :  Scalar [long] defining the width (i.e., # of elements)
;                                to use for smoothing the lower and upper bounds of the
;                                waveform envelope
;                                [Default = 3]
;               RM_EDGES    :  If set, routine sets the start and end envelope values to
;                                NaNs.  This is useful for filtered data that has
;                                artificial divergences at the start/end of the time
;                                series due to the filtering.
;                                [Default = FALSE]
;               NO_LIM_OFF  :  If set, routine will allow the user to define
;                                (OFFSET < LENGTH), whereas the default limits the
;                                values to (OFFSET > LENGTH)
;                                [Default = FALSE]
;               *********************************************
;               ***  keywords used by partition_data.pro  ***
;               *********************************************
;               LENGTH      :  Scalar [long] defining the # of elements to use when
;                                defining the time ranges for partitioning the data to
;                                find the envelope around the waveform
;                                [Default = 4]
;               OFFSET      :  Scalar [long] defining the # of elements to shift from the
;                                start of each time stamp
;                                [Default = 4]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [08/11/2015   v1.0.0]
;             2)  Now returns envelopes for each component in addition to an overall
;                   envelope for the waveform
;                                                                   [08/11/2015   v1.1.0]
;             3)  Added keyword:  NO_LIM_OFF
;                                                                   [07/25/2016   v1.2.0]
;
;   NOTES:      
;               1)  The routine requires that N ≥ 64
;               2)  Units do not matter as long as one is consistent
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/10/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/25/2016   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_vector_waveform_envelope,time,vector,SM_WIDTH=sm_width,RM_EDGES=rm_edges,$
                                       NO_LIM_OFF=no_lim_off,LENGTH=length,OFFSET=offset

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, format_2d_vec, partition_data
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
min_n          = 64L                         ;;  Minimum # of time stamps for TIME and FIELD
min_n_str      = STRTRIM(STRING(min_n[0],FORMAT='(I)'),2L)
;;  Defaults
def_smwd       = 3L                          ;;  Default value for SM_WIDTH keyword
def_len        = 4L                          ;;  Default value for LENGTH keyword
def_off        = 4L                          ;;  Default value for OFFSET keyword
;;  Dummy error messages
no_inpt_msg    = 'User must supply dependent and independent data arrays'
badvfor_msg    = 'Incorrect input format:  VECTOR must be an [N,3]-element [numeric] array'
badin_n_msg    = 'Incorrect input format:  TIME and FIELD[*,0] must have at least '+min_n_str[0]+' elements'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(time,/NOMSSG) EQ 0) OR  $
                 (is_a_number(vector,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check formats
vec2d          = format_2d_vec(vector)
test           = (N_ELEMENTS(vec2d) LT 3) OR ((N_ELEMENTS(vec2d) MOD 3) NE 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  So far so good --> define time and check format
tt             = REFORM(time)
szdt           = SIZE(tt,/DIMENSIONS)
szdv           = SIZE(vec2d,/DIMENSIONS)
test           = (szdv[0] NE szdt[0]) OR (szdt[0] LE min_n[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badin_n_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
nt             = szdt[0]                  ;;  N = # of elements in each array
sp             = SORT(tt)
tts            = tt[sp]
vecs           = vec2d[sp,*]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check SM_WIDTH
test           = (N_ELEMENTS(sm_width) EQ 1) AND is_a_number(sm_width,/NOMSSG)
IF (test[0]) THEN smwd = (sm_width[0] < (nt[0]/def_smwd[0]/2L)) ELSE smwd = def_smwd[0]
smwd           = smwd[0] > def_smwd[0]            ;;  Make sure SM_WIDTH is at least the default minimum
;;  Check RM_EDGES
test           = (N_ELEMENTS(rm_edges) GT 0) AND KEYWORD_SET(rm_edges)
IF (test[0]) THEN kill_edge = 1b ELSE kill_edge = 0b
;;  Check NO_LIM_OFF
test           = (N_ELEMENTS(no_lim_off) GT 0) AND KEYWORD_SET(no_lim_off)
IF (test[0]) THEN yes_limit = 0b ELSE yes_limit = 1b
;;  Check LENGTH
test           = (N_ELEMENTS(length) EQ 1) AND is_a_number(length,/NOMSSG)
IF (test[0]) THEN nlen = (length[0] < (nt[0]/def_len[0])) ELSE nlen = def_len[0]
nlen           = nlen[0] > def_len[0]             ;;  Make sure LENGTH is at least the default minimum
;;  Check OFFSET
test           = (N_ELEMENTS(offset) EQ 1) AND is_a_number(offset,/NOMSSG)
IF (test[0]) THEN nshft = (offset[0] < (nt[0]/def_off[0])) ELSE nshft = def_off[0]
IF (yes_limit[0]) THEN off_low = nlen[0] ELSE off_low = def_off[0]
nshft          = nshft[0] > off_low[0]            ;;  Make sure OFFSET is at least LENGTH
;    LBW III  07/25/2016   v1.2.0
;nshft          = nshft[0] > nlen[0]               ;;  Make sure OFFSET is at least LENGTH
;;----------------------------------------------------------------------------------------
;;  Find envelope around waveform (i.e., high/low values for each time range)
;;
;;    Note:  return value has [NN, MM, LL]-Elements where
;;             NN = # of elements in LENGTH
;;             MM = # of divisions = K/NN, where K = # of points in input array
;;             LL = 2 => 0 = times, 1 = vectors
;;----------------------------------------------------------------------------------------
envelope_x     = partition_data(tts,nlen[0],nshft[0],YY=vecs[*,0])
envelope_y     = partition_data(tts,nlen[0],nshft[0],YY=vecs[*,1])
envelope_z     = partition_data(tts,nlen[0],nshft[0],YY=vecs[*,2])
n_envel        = N_ELEMENTS(envelope_x[0,*,0])
env_tt         = REPLICATE(d,n_envel[0])
env_xx         = REPLICATE(d,n_envel[0],2L)     ;;  Envelope for X-component
env_yy         = REPLICATE(d,n_envel[0],2L)     ;;  Envelope for Y-component
env_zz         = REPLICATE(d,n_envel[0],2L)     ;;  Envelope for Z-component
env_vv         = REPLICATE(d,n_envel[0],2L)     ;;  Envelope for all components
FOR i=0L, n_envel[0] - 1L DO BEGIN
  tempt       = REFORM(envelope_x[*,i,0])
  tempx       = REFORM(envelope_x[*,i,1])
  tempy       = REFORM(envelope_y[*,i,1])
  tempz       = REFORM(envelope_z[*,i,1])
  mnmx_x      = [MIN(tempx,/NAN),MAX(tempx,/NAN)]
  mnmx_y      = [MIN(tempy,/NAN),MAX(tempy,/NAN)]
  mnmx_z      = [MIN(tempz,/NAN),MAX(tempz,/NAN)]
  temp_mnv    = [mnmx_x[0],mnmx_y[0],mnmx_z[0]]
  temp_mxv    = [mnmx_x[1],mnmx_y[1],mnmx_z[1]]
  ;;  Define time stamps for each envelope lower/upper bound
  env_tt[i]   = MEAN(tempt,/NAN)       ;;  Avg. time [time units] of binned range
  ;;  Find lower/upper bound for X-component
  env_xx[i,0] = mnmx_x[0]              ;;  Lower bound on waveform [vector units] in binned range
  env_xx[i,1] = mnmx_x[1]              ;;  Upper bound on waveform [vector units] in binned range
  ;;  Find lower/upper bound for Y-component
  env_yy[i,0] = mnmx_y[0]              ;;  Lower bound on waveform [vector units] in binned range
  env_yy[i,1] = mnmx_y[1]              ;;  Upper bound on waveform [vector units] in binned range
  ;;  Find lower/upper bound for Z-component
  env_zz[i,0] = mnmx_z[0]              ;;  Lower bound on waveform [vector units] in binned range
  env_zz[i,1] = mnmx_z[1]              ;;  Upper bound on waveform [vector units] in binned range
  ;;  Find lower/upper bound for all components
  env_vv[i,0] = MIN(temp_mnv,/NAN)     ;;  Lower bound on waveform [vector units] in binned range
  env_vv[i,1] = MAX(temp_mxv,/NAN)     ;;  Upper bound on waveform [vector units] in binned range
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Smooth envelope [use boxcar average and median filter]
;;----------------------------------------------------------------------------------------
env_xx_md      = env_xx             ;;  initialize variable
env_xx_sm      = env_xx             ;;  initialize variable
env_yy_md      = env_yy             ;;  initialize variable
env_yy_sm      = env_yy             ;;  initialize variable
env_zz_md      = env_zz             ;;  initialize variable
env_zz_sm      = env_zz             ;;  initialize variable
env_vv_md      = env_vv             ;;  initialize variable
env_vv_sm      = env_vv             ;;  initialize variable
;;  boxcar smooth
env_xx_sm[*,0] = SMOOTH(env_xx[*,0],smwd[0],/NAN)
env_xx_sm[*,1] = SMOOTH(env_xx[*,1],smwd[0],/NAN)
env_yy_sm[*,0] = SMOOTH(env_yy[*,0],smwd[0],/NAN)
env_yy_sm[*,1] = SMOOTH(env_yy[*,1],smwd[0],/NAN)
env_zz_sm[*,0] = SMOOTH(env_zz[*,0],smwd[0],/NAN)
env_zz_sm[*,1] = SMOOTH(env_zz[*,1],smwd[0],/NAN)
env_vv_sm[*,0] = SMOOTH(env_vv[*,0],smwd[0],/NAN)
env_vv_sm[*,1] = SMOOTH(env_vv[*,1],smwd[0],/NAN)
;;  median filter
env_xx_md[*,0] = MEDIAN(env_xx[*,0],smwd[0])
env_xx_md[*,1] = MEDIAN(env_xx[*,1],smwd[0])
env_yy_md[*,0] = MEDIAN(env_yy[*,0],smwd[0])
env_yy_md[*,1] = MEDIAN(env_yy[*,1],smwd[0])
env_zz_md[*,0] = MEDIAN(env_zz[*,0],smwd[0])
env_zz_md[*,1] = MEDIAN(env_zz[*,1],smwd[0])
env_vv_md[*,0] = MEDIAN(env_vv[*,0],smwd[0])
env_vv_md[*,1] = MEDIAN(env_vv[*,1],smwd[0])
IF (kill_edge[0]) THEN BEGIN
  ;;  User wishes to remove the edges --> set to NaNs
  se              = [0L,(n_envel[0] - 1L)]
  env_xx[se,*]    = d
  env_yy[se,*]    = d
  env_zz[se,*]    = d
  env_vv[se,*]    = d
  ;;  remove edges from median filtered
  env_xx_md[se,*] = d
  env_yy_md[se,*] = d
  env_zz_md[se,*] = d
  env_vv_md[se,*] = d
  ;;  remove edges from smoothed
  env_xx_sm[se,*] = d
  env_yy_sm[se,*] = d
  env_zz_sm[se,*] = d
  env_vv_sm[se,*] = d
ENDIF
;;----------------------------------------------------------------------------------------
;;  Re-define keywords to return to user
;;----------------------------------------------------------------------------------------
sm_width       = smwd[0]
rm_edges       = kill_edge[0]
length         = nlen[0]
offset         = nshft[0]
;;----------------------------------------------------------------------------------------
;;  Define return structures
;;----------------------------------------------------------------------------------------
tags           = 'ENV_'+['VALS'+['','_SM','_MED']]
x_struc        = CREATE_STRUCT(tags,env_xx,env_xx_sm,env_xx_md)
y_struc        = CREATE_STRUCT(tags,env_yy,env_yy_sm,env_yy_md)
z_struc        = CREATE_STRUCT(tags,env_zz,env_zz_sm,env_zz_md)
v_struc        = CREATE_STRUCT(tags,env_vv,env_vv_sm,env_vv_md)
tags           = ['TIME','X','Y','Z','V']
struc          = CREATE_STRUCT(tags,env_tt,x_struc,y_struc,z_struc,v_struc)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END

