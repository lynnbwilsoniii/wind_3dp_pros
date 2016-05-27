;+
;*****************************************************************************************
;
;  COMMON   :   beam_fit_keyword_com.pro
;  PURPOSE  :   Common block for the beam fitting routine package keywords
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
;               VLIM       :  Scalar [float/double] defining the maximum speed [km/s]
;                               to plot for both the contour and cuts
;                               [Default = Vel. defined by maximum energy bin value]
;               NGRID      :  Scalar [long] defining the # of contour levels to use on
;                               output
;                               [Default = 30L]
;               NSMOOTH    :  Scalar [long] defining the # of points over which to
;                               smooth the DF contours and cuts
;                               [Default = 3]
;               SM_CUTS    :  If set, program plots the smoothed (by NSMOOTH points)
;                               cuts of the DF
;                               [Default:  FALSE]
;               SM_CONT    :  If set, program plots the smoothed (by NSMOOTH points)
;                               contours of DF
;                               [Default:  Smoothed to the minimum # of points]
;               DFRA       :  [2]-Element array [float/double] defining the DF range
;                               [cm^(-3) km^(-3) s^(3)] that defines the minimum and
;                               maximum value for both the contour levels and the
;                               Y-Axis of the cuts plot
;                               [Default = {DFMIN,DFMAX}]
;               DFMIN      :  Scalar [float/double] defining the minimum allowable phase
;                               (velocity) space density to plot, which is useful for
;                               ion distributions with large angular gaps in data
;                               [i.e. prevents lower bound from falling below DFMIN]
;                               [Default = 1d-18]
;               DFMAX      :  Scalar [float/double] defining the maximum allowable phase
;                               (velocity) space density to plot, which is useful for
;                               distributions with data spikes
;                               [i.e. prevents upper bound from exceeding DFMAX]
;                               [Default = 1d-2]
;               PLANE      :  Scalar [string] defining the plane projection to plot with
;                               corresponding cuts [Let V1 = MAGF, V2 = VSW]
;                                 'xy'  :  horizontal axis parallel to V1 and normal
;                                            vector to plane defined by (V1 x V2)
;                                            [default]
;                                 'xz'  :  horizontal axis parallel to (V1 x V2) and
;                                            vertical axis parallel to V1
;                                 'yz'  :  horizontal axis defined by (V1 x V2) x V1
;                                            and vertical axis (V1 x V2)
;                               [Default = 'xy']
;               ANGLE      :  Scalar [float/double] defining the angle [deg] from the
;                               Y-Axis by which to rotate the [X,Y]-cuts
;                               [Default = 0.0]
;               FILL       :  Scalar [float/double] defining the lowest possible values
;                               to consider and the value to use for replacing zeros
;                               and NaNs when fitting to beam peak
;                               [Default = 1d-20]
;               PERC_PK    :  Scalar [float/double] defining the percentage of the peak
;                               beam amplitude, A_b [cm^(-3) km^(-3) s^(3)], to use in
;                               the fit analysis
;                               [Default = 0.01 (or 1%)]
;               SAVE_DIR   :  Scalar [string] defining the directory where the plots
;                               will be stored
;                               [Default = FILE_EXPAND_PATH('')]
;               FILE_PREF  :  [N]-Element array [string] defining the prefix associated
;                               with each PostScript plot on output
;                               [Default = 'DF_000j', j = index # of DAT]
;               FILE_MIDF  :  Scalar [string] defining the plane of projection and number
;                               grids used for contour plot levels
;                               [Default = 'V1xV2xV1_vs_V1_30Grids_']
;
;   CHANGED:  1)  Continued to write routine                       [08/28/2012   v1.0.0]
;             2)  Changed name to beam_fit_keyword_com.pro         [08/28/2012   v2.0.0]
;             3)  Updated man page                                 [09/07/2012   v2.1.0]
;
;   NOTES:      
;               1)  This routine should only be called by the routines in the
;                     'CALLED BY' section shown above
;
;   CREATED:  08/27/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/07/2012   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

COMMON beam_fit_keyword_com,vlim,ngrid,nsmooth,sm_cuts,sm_cont,dfra,dfmin,dfmax,plane,$
                            angle,fill,perc_pk,save_dir,file_pref,file_midf

