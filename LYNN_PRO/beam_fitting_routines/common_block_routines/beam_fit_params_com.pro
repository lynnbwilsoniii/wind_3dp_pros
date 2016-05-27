;+
;*****************************************************************************************
;
;  COMMON   :   beam_fit_params_com.pro
;  PURPOSE  :   Common block for the beam fitting routine package 
;                 [parameters and defaults]
;
;  CALLED BY:   
;               beam_fit_set_defaults.pro
;               beam_fit___get_common.pro
;               beam_fit___set_common.pro
;               beam_fit_struc_common.pro
;               beam_fit_unset_common.pro
;               beam_fit_keywords_init.pro
;               beam_fit_prompts.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;  COMMON BLOCK VARIABLES:
;
;               VSW        :  [3]-Element vector [float] defining the bulk flow velocity
;                               [km/s] of the distribution
;               VCMAX      :  Set to a named variable to return the maximum "core"
;                               velocity [km/s] to use for masking routine
;                               [V_THRESH keyword in remove_uv_and_beam_ions.pro]
;               V_BX       :  Set to a named variable to return the X-component
;                               (parallel) of the "beam" velocity [km/s] at the peak
;                               phase (velocity) space density of the "beam"
;               V_BY       :  Set to a named variable to return the Y-component
;                               (perpendicular) of the "beam" velocity [km/s] at the
;                               peak phase (velocity) space density of the "beam"
;               VB_REG     :  Set to a named variable to return the rectangular
;                               coordinates [X0,Y0,X1,Y1] defining the region that
;                               outlines where the beam exists
;               VBMAX      :  Set to a named variable to return the maximum "beam"
;                               velocity [km/s] to use for masking routine
;                               [V_THRESH keyword in find_beam_peak_and_mask.pro]
;               *******************************
;               ***  DEFAULT --> Variables  ***
;               *******************************
;               DEF_FILL   :  Scalar [float/double] defining the default value for the
;                               FILL common block variable
;                               [Default = 1d-20]
;               DEF_PERC   :  Scalar [float/double] defining the default value for the
;                               PERC_PK common block variable
;                               [Default = 0.01 (or 1%)]
;               DEF_DFMIN  :  Scalar [float/double] defining the default value for the
;                               DFMIN common block variable
;                               [Default = 1d-18]
;               DEF_DFMAX  :  Scalar [float/double] defining the default value for the
;                               DFMAX common block variable
;                               [Default = 1d-2]
;               DEF_NGRID  :  Scalar [long] defining the default value for the
;                               NGRID common block variable
;                               [Default = 30L]
;               DEF_NSMTH  :  Scalar [long] defining the default value for the
;                               NSMOOTH common block variable
;                               [Default = 3]
;               DEF_PLANE  :  Scalar [string] defining the default value for the
;                               PLANE common block variable
;                               [Default = 'xy']
;               DEF_SDIR   :  Scalar [string] defining the default value for the
;                               SAVE_DIR common block variable
;                               [Default = FILE_EXPAND_PATH('')]
;               DEF_PREF   :  [N]-Element array [string] defining the default value for
;                               the FILE_PREF common block variable
;                               [Default = 'DF_00j', j = index # of DAT]
;               DEF_MIDF   :  Scalar [string] defining the default value for the
;                               FILE_MIDF common block variable
;                               [Default = 'V1xV2xV1_vs_V1_30Grids_']
;               DEF_VLIM   :  Scalar [float/double] defining the default value for the
;                               DFMAX common block variable
;                               [Default = Vel. defined by maximum energy bin value]
;
;   CHANGED:  1)  Added VBMAX to list of parameters                [09/07/2012   v1.1.0]
;
;   NOTES:      
;               1)  This routine should only be called by the routines in the
;                     'CALLED BY' section shown above
;               2)  See also:  beam_fit_keyword_com.pro
;
;   CREATED:  08/28/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/07/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

COMMON beam_fit_params_com,vsw,vcmax,v_bx,v_by,vb_reg,vbmax,                   $  ;; parameters
                           def_fill,def_perc,def_dfmin,def_dfmax,def_ngrid,    $  ;; defaults
                           def_nsmth,def_plane,def_sdir,def_pref,def_midf,     $
                           def_vlim


