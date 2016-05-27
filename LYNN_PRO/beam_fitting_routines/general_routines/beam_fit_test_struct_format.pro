;+
;*****************************************************************************************
;
;  FUNCTION :   beam_fit_test_struct_format.pro
;  PURPOSE  :   This routine checks the format of the output associated with the
;                 DATA_OUT keyword in beam_fit_1df_plot_fit.pro to determine if
;                 the relevant tag values printed to the ASCII file are present/valid.
;
;  CALLED BY:   
;               wrapper_beam_fit_array.pro
;
;  CALLS:
;               tag_names_r.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA_OUT   :  Scalar structure output from beam_fit_1df_plot_fit.pro
;                               associated with the DATA_OUT keyword
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Updated to include moment analysis results       [09/08/2012   v1.1.0]
;             2)  Now includes smoothing and plane of projection information
;                                                                  [09/08/2012   v1.2.0]
;
;   NOTES:      
;               1)  This is just an error handling routine
;
;   CREATED:  09/04/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/08/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION beam_fit_test_struct_format,data_out

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define needed tags
tag_time       = 'DAT.IDL_DIST.ORIG.'+['TIME','END_TIME']
tag_fitr       = 'FIT_RESULTS.FITS.MODEL_PARAMS'
tag_fitc       = 'FIT_RESULTS.CONSTRAINTS.'+['LIMITS','FIXED']
tag_velc       = 'VELOCITY.'+['ORIG.VSW','CORE.VCMAX']
tag_velb       = 'VELOCITY.BEAM.'+['SC_FRAME.V_B_GSE','VBMAX','BULK_FRAME.V_0X','BULK_FRAME.V_0Y']
tag_momt       = 'MOMENT_ANALYSIS.PARAMS'
tag_smoo       = 'KEYWORDS.BEAM.'+['PLANE','NSMOOTH','SM_CUTS','SM_CONT']
;;  Define default values associated with each tag
def_time       = REPLICATE(d,2L)
def_fitr       = REPLICATE(d,6L)
def_momt       = REPLICATE(d,6L)
def_fitc       = {LIMITS:REPLICATE(d,2L,6L),FIXED:REPLICATE(0b,6L)}
def_velc       = {ORIG_VSW:REPLICATE(d,3L),CORE_VCMAX:d}
def_velb       = {V_B_GSE_SC:REPLICATE(d,3L),VBMAX:d,V_B_BFRAME:REPLICATE(d,2L)}
def_smoo       = {PLANE:'xy',NSMOOTH:3L,SM_CUTS:0L,SM_CONT:0L}
;;  Define dummy return structure
tags           = ['TIME','FIT_RESULTS','FIT_CONSTRAINTS','CORE_VELS','BEAM_VELS',$
                  'MOMENTS','SMOOTHING']
struct         = CREATE_STRUCT(tags,def_time,def_fitr,def_fitc,def_velc,def_velb,$
                               def_momt,def_smoo)
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(data_out) EQ 0) OR (SIZE(data_out,/TYPE) NE 8)
IF (test) THEN RETURN,struct     ;; nothing supplied, so leave
data_str       = data_out
;;----------------------------------------------------------------------------------------
;; => Determine if input has the correct tags
;;----------------------------------------------------------------------------------------
all_tags       = tag_names_r(data_str)
;;---------------------------------------------------
;;  Check [time] tags
;;---------------------------------------------------
good_tt0       = WHERE(all_tags EQ tag_time[0],gdtt0)
good_tt1       = WHERE(all_tags EQ tag_time[1],gdtt1)
IF (gdtt0 GT 0) THEN def_time[0]            = data_str.DAT.IDL_DIST.ORIG.TIME[0]
IF (gdtt1 GT 0) THEN def_time[1]            = data_str.DAT.IDL_DIST.ORIG.END_TIME[0]
;;---------------------------------------------------
;;  Check [fit results] tags
;;---------------------------------------------------
good_tt0       = WHERE(all_tags EQ tag_fitr[0],gdtt0)
IF (gdtt0 GT 0) THEN def_fitr               = data_str.FIT_RESULTS.FITS.MODEL_PARAMS
;;---------------------------------------------------
;;  Check [fit limits] tags
;;---------------------------------------------------
good_tt0       = WHERE(all_tags EQ tag_fitc[0],gdtt0)
good_tt1       = WHERE(all_tags EQ tag_fitc[1],gdtt1)
IF (gdtt0 GT 0) THEN def_fitc.LIMITS        = DOUBLE(data_str.FIT_RESULTS.CONSTRAINTS.LIMITS)
IF (gdtt1 GT 0) THEN def_fitc.FIXED         = BYTE(data_str.FIT_RESULTS.CONSTRAINTS.FIXED[0])
;;---------------------------------------------------
;;  Check [core velocity] tags
;;---------------------------------------------------
good_tt0       = WHERE(all_tags EQ tag_velc[0],gdtt0)
good_tt1       = WHERE(all_tags EQ tag_velc[1],gdtt1)
IF (gdtt0 GT 0) THEN def_velc.ORIG_VSW      = DOUBLE(data_str.VELOCITY.ORIG.VSW)
IF (gdtt1 GT 0) THEN def_velc.CORE_VCMAX    = DOUBLE(data_str.VELOCITY.CORE.VCMAX[0])
;;---------------------------------------------------
;;  Check [beam velocity] tags
;;---------------------------------------------------
good_tt0       = WHERE(all_tags EQ tag_velb[0],gdtt0)
good_tt1       = WHERE(all_tags EQ tag_velb[1],gdtt1)
good_tt2       = WHERE(all_tags EQ tag_velb[2],gdtt2)
good_tt3       = WHERE(all_tags EQ tag_velb[3],gdtt3)
IF (gdtt0 GT 0) THEN def_velb.V_B_GSE_SC    = DOUBLE(data_str.VELOCITY.BEAM.SC_FRAME.V_B_GSE)
IF (gdtt1 GT 0) THEN def_velb.VBMAX         = DOUBLE(data_str.VELOCITY.BEAM.VBMAX[0])
IF (gdtt2 GT 0) THEN def_velb.V_B_BFRAME[0] = DOUBLE(data_str.VELOCITY.BEAM.BULK_FRAME.V_0X[0])
IF (gdtt3 GT 0) THEN def_velb.V_B_BFRAME[1] = DOUBLE(data_str.VELOCITY.BEAM.BULK_FRAME.V_0Y[0])
;good_tt0       = WHERE(all_tags EQ tag_velb[2],gdtt0)
;good_tt1       = WHERE(all_tags EQ tag_velb[3],gdtt1)
;IF (gdtt0 GT 0) THEN def_velb.V_B_BFRAME[0] = data_str.VELOCITY.BEAM.BULK_FRAME.V_0X[0]
;IF (gdtt1 GT 0) THEN def_velb.V_B_BFRAME[1] = data_str.VELOCITY.BEAM.BULK_FRAME.V_0Y[0]
;;---------------------------------------------------
;;  Check [moment analysis] tags
;;---------------------------------------------------
good_tt0       = WHERE(all_tags EQ tag_momt[0],gdtt0)
IF (gdtt0 GT 0) THEN def_momt               = DOUBLE(data_str.MOMENT_ANALYSIS.PARAMS)
;;---------------------------------------------------
;;  Check [smoothing and plane information] tags
;;---------------------------------------------------
good_tt0       = WHERE(all_tags EQ tag_smoo[0],gdtt0)
good_tt1       = WHERE(all_tags EQ tag_smoo[1],gdtt1)
good_tt2       = WHERE(all_tags EQ tag_smoo[2],gdtt2)
good_tt3       = WHERE(all_tags EQ tag_smoo[3],gdtt3)
IF (gdtt0 GT 0) THEN def_smoo.PLANE         = STRTRIM(data_str.KEYWORDS.BEAM.PLANE[0],2L)
IF (gdtt1 GT 0) THEN def_smoo.NSMOOTH       = LONG(data_str.KEYWORDS.BEAM.NSMOOTH[0])
IF (gdtt2 GT 0) THEN def_smoo.SM_CUTS       = LONG(data_str.KEYWORDS.BEAM.SM_CUTS[0])
IF (gdtt3 GT 0) THEN def_smoo.SM_CONT       = LONG(data_str.KEYWORDS.BEAM.SM_CONT[0])
;;----------------------------------------------------------------------------------------
;; => Create return structure
;;----------------------------------------------------------------------------------------
tags           = ['TIME','FIT_RESULTS','FIT_CONSTRAINTS','CORE_VELS','BEAM_VELS',$
                  'MOMENTS','SMOOTHING']
struct         = CREATE_STRUCT(tags,def_time,def_fitr,def_fitc,def_velc,def_velb,$
                               def_momt,def_smoo)
;;----------------------------------------------------------------------------------------
;; => Return results
;;----------------------------------------------------------------------------------------

RETURN,struct
END
