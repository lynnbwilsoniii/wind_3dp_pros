;+
;*****************************************************************************************
;
;  FUNCTION :   keep_best_mva_from_adapint.pro
;  PURPOSE  :   This routine takes the output from extract_good_mva_from_adapint.pro
;                 and renders it easily useable and transferable to any other analysis
;                 software.  The input structures should contain two different levels
;                 of tags outside of the direct output from the extraction routine,
;                 where the outermost level is the interval index and the next level
;                 is for each frequency filter used on that interval.  If only one
;                 interval and frequency filter range were used, e.g., the user wants
;                 to get values from a single output of the extraction routine, then
;                 before input, just modify the outputs from the extraction routine in
;                 the following way (assuming mva_0 and bind0 are the outputs):
;
;                   IDL> best_subint = {I0:{F0:bind0}}
;                   IDL> mva_results = {I0:{F0:mva_0}}
;
;                 The input for this routine is the output from the routine:
;                   calc_and_save_mva_res_by_int.pro
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               num2int_str.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               BEST_SUBINT  :  Scalar [structure] containing multiple tags corresponding
;                                 to analysis on multiple intervals from the output of
;                                 the BEST_NO_OVRLP keyword in the routine
;                                 extract_good_mva_from_adapint.pro
;               MVA_RESULTS  :  Scalar [structure] containing multiple tags corresponding
;                                 to analysis on multiple intervals from the output of
;                                 the routine extract_good_mva_from_adapint.pro
;
;  EXAMPLES:    
;               [calling sequence]
;               best_res = keep_best_mva_from_adapint(best_subint, mva_results)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Renamed to keep_best_mva_from_adapint.pro from
;                   temp_keep_best_mva_from_adapint.pro and cleaned up a little
;                                                                   [08/01/2016   v1.0.0]
;             2)  Fixed a bug when no good intervals were found
;                                                                   [08/02/2016   v1.0.1]
;
;   NOTES:      
;               1)  Make sure input structures have two layers of tags above those
;                     from the output of extract_good_mva_from_adapint.pro, as explained
;                     in the PURPOSE section above.
;               2)  The idea is to apply the extract_good_mva_from_adapint.pro routine
;                     to several intervals, within a burst interval, each with their own
;                     set of frequency filters.  The output will then be stored in a
;                     structure with tags for the intervals and the frequency ranges
;                     within each interval, thus the two outer structure layers.
;               3)  The input for this routine is the output from the routine:
;                     calc_and_save_mva_res_by_int.pro
;               4)  See also:
;                     adaptive_mva_interval_wrapper.pro
;                     extract_good_mva_from_adapint.pro
;                     calc_and_save_mva_res_by_int.pro
;
;  REFERENCES:  
;               1)  G. Paschmann and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                     Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                     Int. Space Sci. Inst., 1998.
;               2)  J.C. Samson and J.V. Olson, "Some Comments on the Descriptions of
;                      the Polarization States of Waves," Geophys. J. Astr. Soc. 61,
;                      pp. 115-129, 1980.
;               3)  J.D. Means, "Use of the Three-Dimensional Covariance Matrix in
;                      Analyzing the Polarization Properties of Plane Waves,"
;                      J. Geophys. Res. 77(28), pg 5551-5559, 1972.
;               4)  H. Kawano and T. Higuchi "The bootstrap method in space physics:
;                     Error estimation for the minimum variance analysis," Geophys.
;                     Res. Lett. 22(3), pp. 307-310, 1995.
;               5)  A.V. Khrabrov and B.U.Ö Sonnerup "Error estimates for minimum
;                     variance analysis," J. Geophys. Res. 103(A4), pp. 6641-6651,
;                     1998.
;
;   CREATED:  08/01/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/02/2016   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION keep_best_mva_from_adapint,best_subint,mva_results

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Dummy structure tag arrays
sten_str       = ['ST','EN']
mnmdmx_str     = ['MIN','MID','MAX']
ind_str_tags   = [sten_str+'_'+'R2INT',sten_str+'_'+'R2ALL']
sitw_str_tag   = ['SUB_I','T_WIN']+'_NUM'
eval_str_tag   = mnmdmx_str+'_EIGVALS'
evec_str_tag   = mnmdmx_str+'_EIGVECS'
;;  Dummy error messages
no_inpt_msg    = 'User must supply at least two valid IDL structures...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (SIZE(best_subint,/TYPE) NE 8)  OR $
                 (SIZE(mva_results,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define structure params
;;----------------------------------------------------------------------------------------
;;  Define # of intervals examined
nt             = N_TAGS(best_subint) < N_TAGS(mva_results)
int_strs       = num2int_str(LINDGEN(nt[0]),NUM_CHAR=3,/ZERO_PAD)
itags          = 'INT_'+int_strs
FOR int=0L, nt[0] - 1L DO BEGIN   ;;  Iterate over intervals
  ;;--------------------------------------------------------------------------------------
  ;;  Reset variables
  ;;--------------------------------------------------------------------------------------
  ff_ind_struc      = 0
  ff_sitw_strc      = 0
  ff_eval_strc      = 0
  ff_evec_strc      = 0
  ;;--------------------------------------------------------------------------------------
  ;;  Define interval-specific parameters
  ;;--------------------------------------------------------------------------------------
  bind0          = best_subint.(int[0])
  mva_0          = mva_results.(int[0])
  test           = (SIZE(bind0,/TYPE) NE 8) OR (SIZE(mva_0,/TYPE) NE 8)
  IF (test[0]) THEN BEGIN
    ;;  No MVA was performed on this interval --> skip iteration
    str_element,ii_ind_struc,itags[int[0]],ff_ind_struc,/ADD_REPLACE
    str_element,ii_sitw_strc,itags[int[0]],ff_sitw_strc,/ADD_REPLACE
    str_element,ii_eval_strc,itags[int[0]],ff_eval_strc,/ADD_REPLACE
    str_element,ii_evec_strc,itags[int[0]],ff_evec_strc,/ADD_REPLACE
    CONTINUE
  ENDIF
  ;;--------------------------------------------------------------------------------------
  ;;  Make sure to cleanup dummy variables from previous iterations
  ;;--------------------------------------------------------------------------------------
  IF (N_ELEMENTS(good_ff) GT 0) THEN dumb = TEMPORARY(good_ff)
  IF (N_ELEMENTS(good_b0) GT 0) THEN dumb = TEMPORARY(good_b0)
  IF (N_ELEMENTS(good_m0) GT 0) THEN dumb = TEMPORARY(good_m0)
  ;;  Find all tags within BIND0 that are structures
  FOR ff=0L, N_TAGS(bind0) - 1L DO BEGIN
    good_b00 = (SIZE(bind0.(ff[0]),/TYPE) EQ 8)
    test     = (N_ELEMENTS(good_b0) EQ 0)
    IF (good_b00[0]) THEN IF (test[0]) THEN good_b0 = ff[0] ELSE good_b0 = [good_b0,ff[0]]
  ENDFOR
  ;;  Find all tags within MVA_0 that are structures
  FOR ff=0L, N_TAGS(mva_0) - 1L DO BEGIN
    good_b00 = (SIZE(mva_0.(ff[0]),/TYPE) EQ 8)
    test     = (N_ELEMENTS(good_m0) EQ 0)
    IF (good_b00[0]) THEN IF (test[0]) THEN good_m0 = ff[0] ELSE good_m0 = [good_m0,ff[0]]
  ENDFOR
  test           = (N_ELEMENTS(good_b0) EQ 0) OR (N_ELEMENTS(good_m0) EQ 0)
  IF (test[0]) THEN BEGIN
    ;;  No MVA was performed on this interval --> skip iteration
    str_element,ii_ind_struc,itags[int[0]],ff_ind_struc,/ADD_REPLACE
    str_element,ii_sitw_strc,itags[int[0]],ff_sitw_strc,/ADD_REPLACE
    str_element,ii_eval_strc,itags[int[0]],ff_eval_strc,/ADD_REPLACE
    str_element,ii_evec_strc,itags[int[0]],ff_evec_strc,/ADD_REPLACE
    CONTINUE
  ENDIF
  test           = (N_ELEMENTS(good_b0) NE N_ELEMENTS(good_m0))
  IF (test[0]) THEN gg0 = ([0b,1b])[N_ELEMENTS(good_b0) LT N_ELEMENTS(good_m0)] ELSE gg0 = -1
  IF (gg0[0] EQ  0) THEN IF (N_ELEMENTS(good_m0) GT 0) THEN good_ff = good_m0
  IF (gg0[0] EQ  1) THEN IF (N_ELEMENTS(good_b0) GT 0) THEN good_ff = good_b0
  IF (gg0[0] EQ -1) THEN IF (N_ELEMENTS(good_b0) GT 0) THEN good_ff = good_b0
;  IF (gg0[0] EQ  0) THEN good_ff = good_m0
;  IF (gg0[0] EQ  1) THEN good_ff = good_b0
;  IF (gg0[0] EQ -1) THEN good_ff = good_b0
  nfrq           = N_ELEMENTS(good_ff)
  IF (nfrq[0] EQ 0) THEN BEGIN
    ;;  No MVA was performed on this interval --> skip iteration
    str_element,ii_ind_struc,itags[int[0]],ff_ind_struc,/ADD_REPLACE
    str_element,ii_sitw_strc,itags[int[0]],ff_sitw_strc,/ADD_REPLACE
    str_element,ii_eval_strc,itags[int[0]],ff_eval_strc,/ADD_REPLACE
    str_element,ii_evec_strc,itags[int[0]],ff_evec_strc,/ADD_REPLACE
    CONTINUE
  ENDIF
  ftags          = 'FREQ_'+num2int_str(LINDGEN(nfrq[0]),NUM_CHAR=3,/ZERO_PAD)
  FOR ff=0L, nfrq[0] - 1L DO BEGIN  ;;  Iterate over frequency ranges
    ;;------------------------------------------------------------------------------------
    ;;  Reset variables
    ;;------------------------------------------------------------------------------------
    ind_struc      = 0
    sitw_strc      = 0
    eval_strc      = 0
    evec_strc      = 0
    ;;------------------------------------------------------------------------------------
    ;;  Define frequency range-specific parameters
    ;;------------------------------------------------------------------------------------
    bb             = good_ff[ff[0]]
    bindovr        = bind0.(bb[0])
    fwws_mva       = mva_0.(bb[0])
    test           = (SIZE(bindovr,/TYPE) NE 8) OR (SIZE(fwws_mva,/TYPE) NE 8)
    IF (test[0]) THEN BEGIN
      ;;  No data --> skip iteration
      str_element,ff_ind_struc,ftags[ff[0]],ind_struc,/ADD_REPLACE
      str_element,ff_sitw_strc,ftags[ff[0]],sitw_strc,/ADD_REPLACE
      str_element,ff_eval_strc,ftags[ff[0]],eval_strc,/ADD_REPLACE
      str_element,ff_evec_strc,ftags[ff[0]],evec_strc,/ADD_REPLACE
      CONTINUE
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Define indices for best, non-overlapping results
    ;;------------------------------------------------------------------------------------
    ;;  Define indices relative to subinterval (SI)
    gi_sis         = bindovr.SE_IND[*,0]
    gi_eis         = bindovr.SE_IND[*,1]
    ;;  Define good SI and time window (TW) numbers
    gi_sub0        = bindovr.MVA_SIND                  ;;  Best SI indices
    gi_win0        = bindovr.MVA_WIND                  ;;  Best TW indices
    ;;------------------------------------------------------------------------------------
    ;;  Define MVA results
    ;;------------------------------------------------------------------------------------
    ;;  Define indices relative entire input array
    tr_se          = fwws_mva.ALL_MVA_RESULTS.MVA_INT_STR.TW_IND_SE
    ;;  Define adaptive interval analysis relevant numbers
    ;;    [N_MIN, N_MAX, N_SUB, N_SFT, N_WIN, D__NW, N_INT]
    n_vals         = fwws_mva.ALL_MVA_RESULTS.MVA_INT_STR.N_VALS
    n_int          = n_vals[6]
    ;;  Define eigenvalues and rotation matrices
    all_eval_str   = fwws_mva.ALL_MVA_RESULTS.ALL_EIGVALS
    all_evec_str   = fwws_mva.ALL_MVA_RESULTS.ALL_EIGVECS
    gi_min_eval    = all_eval_str.MIN_VAR[gi_sub0,gi_win0]    ;;  1D array
    gi_mid_eval    = all_eval_str.MID_VAR[gi_sub0,gi_win0]
    gi_max_eval    = all_eval_str.MAX_VAR[gi_sub0,gi_win0]
    test_evals     = FINITE(gi_min_eval) AND FINITE(gi_mid_eval) AND FINITE(gi_max_eval)
    good_evals     = WHERE(test_evals,gd_evals)
    IF (gd_evals[0] EQ 0) THEN BEGIN
      ;;  No good MVA results --> skip iteration
      str_element,ff_ind_struc,ftags[ff[0]],ind_struc,/ADD_REPLACE
      str_element,ff_sitw_strc,ftags[ff[0]],sitw_strc,/ADD_REPLACE
      str_element,ff_eval_strc,ftags[ff[0]],eval_strc,/ADD_REPLACE
      str_element,ff_evec_strc,ftags[ff[0]],evec_strc,/ADD_REPLACE
      CONTINUE
    ENDIF
    ;;------------------------------------------------------------------------------------
    ;;  Limit arrays to GOOD MVA results
    ;;------------------------------------------------------------------------------------
    n_gi           = gd_evals[0]                       ;;  # of good MVA results
    g_gi_sis       = gi_sis[good_evals]
    g_gi_eis       = gi_eis[good_evals]
    tt_sti         = tr_se[0] + g_gi_sis               ;;  Good start array indices relative entire input array
    tt_eni         = tr_se[0] + g_gi_eis               ;;  Good end " "
    nv_int         = tt_eni - tt_sti + 1L
    ;;------------------------------------------------------------------------------------
    ;;  Keep only good MVA results
    ;;------------------------------------------------------------------------------------
    gi_sub         = gi_sub0[good_evals]               ;;  Good SI indices
    gi_win         = gi_win0[good_evals]               ;;  Good TW indices
    gi_min_eval    = all_eval_str.MIN_VAR[gi_sub,gi_win]
    gi_mid_eval    = all_eval_str.MID_VAR[gi_sub,gi_win]
    gi_max_eval    = all_eval_str.MAX_VAR[gi_sub,gi_win]
    ;;  Define eigenvalue ratios
    gi_d2n_eval    = gi_mid_eval/gi_min_eval
    gi_x2d_eval    = gi_max_eval/gi_mid_eval
    ;;  Define eigenvectors
    all_evecx      = all_evec_str.MIN_VAR[*,*,0]  ;;  Minimum variance eigenvector [ICB]
    all_evecy      = all_evec_str.MIN_VAR[*,*,1]  ;;  Intermediate " "
    all_evecz      = all_evec_str.MIN_VAR[*,*,2]  ;;  Maximum " "
    ;;------------------------------------------------------------------------------------
    ;;  Keep only good MVA results
    ;;------------------------------------------------------------------------------------
    tempx          = all_evecx[gi_sub,gi_win]
    tempy          = all_evecy[gi_sub,gi_win]
    tempz          = all_evecz[gi_sub,gi_win]
    gi_min_evec    = [[tempx],[tempy],[tempz]]    ;;  Good minimum variance eigenvector [ICB]
    all_evecx      = all_evec_str.MID_VAR[*,*,0]
    all_evecy      = all_evec_str.MID_VAR[*,*,1]
    all_evecz      = all_evec_str.MID_VAR[*,*,2]
    tempx          = all_evecx[gi_sub,gi_win]
    tempy          = all_evecy[gi_sub,gi_win]
    tempz          = all_evecz[gi_sub,gi_win]
    gi_mid_evec    = [[tempx],[tempy],[tempz]]    ;;  Good intermediate " "
    all_evecx      = all_evec_str.MAX_VAR[*,*,0]
    all_evecy      = all_evec_str.MAX_VAR[*,*,1]
    all_evecz      = all_evec_str.MAX_VAR[*,*,2]
    tempx          = all_evecx[gi_sub,gi_win]
    tempy          = all_evecy[gi_sub,gi_win]
    tempz          = all_evecz[gi_sub,gi_win]
    gi_max_evec    = [[tempx],[tempy],[tempz]]    ;;  Good maximum " "
    ;;  Define good rotation matrices
    gi_rot_scm2mva = [[[gi_min_evec]],[[gi_mid_evec]],[[gi_max_evec]]]
    ;;------------------------------------------------------------------------------------
    ;;  Save results
    ;;------------------------------------------------------------------------------------
    ind_struc      = CREATE_STRUCT(ind_str_tags,g_gi_sis,g_gi_eis,tt_sti,tt_eni)
    sitw_strc      = CREATE_STRUCT(sitw_str_tag,gi_sub,gi_win)
    eval_strc      = CREATE_STRUCT(eval_str_tag,gi_min_eval,gi_mid_eval,gi_max_eval)
    evec_strc      = CREATE_STRUCT(evec_str_tag,gi_min_evec,gi_mid_evec,gi_max_evec)
    str_element,ff_ind_struc,ftags[ff[0]],ind_struc,/ADD_REPLACE
    str_element,ff_sitw_strc,ftags[ff[0]],sitw_strc,/ADD_REPLACE
    str_element,ff_eval_strc,ftags[ff[0]],eval_strc,/ADD_REPLACE
    str_element,ff_evec_strc,ftags[ff[0]],evec_strc,/ADD_REPLACE
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  Save results
  ;;--------------------------------------------------------------------------------------
  str_element,ii_ind_struc,itags[int[0]],ff_ind_struc,/ADD_REPLACE
  str_element,ii_sitw_strc,itags[int[0]],ff_sitw_strc,/ADD_REPLACE
  str_element,ii_eval_strc,itags[int[0]],ff_eval_strc,/ADD_REPLACE
  str_element,ii_evec_strc,itags[int[0]],ff_evec_strc,/ADD_REPLACE
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
tags           = ['INDICES','SI_TW','EIGVALS','EIGVECS']+'_STRUC'
struct         = CREATE_STRUCT(tags,ii_ind_struc,ii_sitw_strc,ii_eval_strc,ii_evec_strc)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END

