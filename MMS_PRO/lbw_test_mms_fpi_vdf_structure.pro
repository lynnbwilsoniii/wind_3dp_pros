;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_test_mms_fpi_vdf_structure.pro
;  PURPOSE  :   This routine tests whether the input data structure is consistent with
;                 the output from mms_get_fpi_dist.pro and whether the additional
;                 routine add_velmagscpot_to_mms_dist.pro has been run on the
;                 structure.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               structure_compare.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries; and
;               2)  latest SPEDAS libraries
;
;  INPUT:
;               DATA     :  Scalar [structure] containing an MMS velocity distribution
;                             from FPI DIS or DES that has had the SC_POT tag added
;
;  EXAMPLES:    
;               [calling sequence]
;               test = lbw_test_mms_fpi_vdf_structure(data [,/NOMSSG] [,POST=post])
;
;  KEYWORDS:    
;               NOMSSG   :  If set, routine will not print out warning message
;                             [Default = FALSE]
;               POST     :  Set to a named variable to return a numeric result to inform
;                             whether the input structure has only been processed by
;                             mms_get_fpi_dist.pro (POST=1), further processed by
;                             add_velmagscpot_to_mms_dist.pro (POST=2), or neither
;                             (POST=0)
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The data structures for the MMS FPI VDFs are originally loaded into
;                     TPLOT with the routine mms_load_fpi.pro and then modified with
;                     the routine mms_get_fpi_dist.pro.  The modifying routine is
;                     critical because the angles from the initial part are the
;                     instrument look directions but are converted to the particle
;                     trajectories by mms_get_fpi_dist.pro.  Then the user should have
;                     called add_velmagscpot_to_mms_dist.pro to add the VELOCITY, MAGF,
;                     and SC_POT tags the the VDFs.
;               2)  See also:  mms_get_fpi_dist.pro (SPEDAS), add_velmagscpot_to_mms_dist.pro,
;                              lbw_mms_energy_angle_to_velocity.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/02/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/02/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_test_mms_fpi_vdf_structure,data,POST=post,NOMSSG=nomssg

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
good           = 0b
post           = 0b
n_e            = 32L
nph            = 32L
nth            = 16L
dumb3df        = FLTARR(n_e[0],nph[0],nth[0])
;;  Define dummy comparison structures
dumb_pre_str   = {                                                      $
                   PROJECT_NAME    : 'MMS',                             $
                   SPACECRAFT      : '1',                               $
                   DATA_NAME       : 'FPI Electron',                    $
                   UNITS_NAME      : 'df_cm',                           $
                   UNITS_PROCEDURE : 'mms_part_conv_units',             $
                   SPECIES         : 'e',                               $
                   VALID           : 1b,                                $
                   CHARGE          : 0e0,                               $
                   MASS            : 0e0,                               $
                   TIME            : 0d0,                               $
                   END_TIME        : 0d0,                               $
                   DATA            : dumb3df,                           $
                   BINS            : dumb3df,                           $
                   ENERGY          : dumb3df,                           $
                   DENERGY         : dumb3df,                           $
                   NENERGY         : n_e[0],                            $
                   NBINS           : nph[0]*nth[0],                     $
                   PHI             : dumb3df,                           $
                   DPHI            : dumb3df,                           $
                   THETA           : dumb3df,                           $
                   DTHETA          : dumb3df                            }
dumb_poststr   = {                                                      $
                   PROJECT_NAME    : 'MMS',                             $
                   SPACECRAFT      : '1',                               $
                   DATA_NAME       : 'FPI Electron',                    $
                   UNITS_NAME      : 'df_cm',                           $
                   UNITS_PROCEDURE : 'mms_part_conv_units',             $
                   SPECIES         : 'e',                               $
                   VALID           : 1b,                                $
                   CHARGE          : 0e0,                               $
                   MASS            : 0e0,                               $
                   TIME            : 0d0,                               $
                   END_TIME        : 0d0,                               $
                   DATA            : dumb3df,                           $
                   BINS            : dumb3df,                           $
                   ENERGY          : dumb3df,                           $
                   DENERGY         : dumb3df,                           $
                   NENERGY         : n_e[0],                            $
                   NBINS           : nph[0]*nth[0],                     $
                   PHI             : dumb3df,                           $
                   DPHI            : dumb3df,                           $
                   THETA           : dumb3df,                           $
                   DTHETA          : dumb3df,                           $
                   VELOCITY        : DBLARR(3),                         $
                   MAGF            : DBLARR(3),                         $
                   SC_POT          : 0d0                                }
;;  Dummy error messages
notstr_mssg    = 'Must be an IDL structure...'
badstr_mssg    = 'Not an appropriate FPI VDF structure...'
;;  Check if user wants to see messages
mssg_on        = ~KEYWORD_SET(nomssg)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 1) THEN RETURN,good[0]
str            = data[0]   ;;  in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  IF (mssg_on[0]) THEN MESSAGE,notstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check structure format
;;----------------------------------------------------------------------------------------
;;  structure_compare.pro has the following possible outputs:
;;    0 --> no overlap (i.e., structures match in no way)
;;    1 --> At least one tag name matches
;;    2 --> At least one tag name matches and the type is the same
;;    3 --> MATCH_NT = TRUE
;;    4 --> MATCH_NT = TRUE & MATCH_TT = TRUE
;;    5 --> MATCH_NT = TRUE & MATCH_TG = TRUE
;;    6 --> MATCH_NT = TRUE & MATCH_TG = TRUE & MATCH_TT = TRUE
;;    7 --> EXACT = TRUE
test           = structure_compare(str[0],dumb_pre_str[0],EXACT=exact,MATCH_NT=match_nt,$
                                   MATCH_TG=match_tg,MATCH_TT=match_tt)
IF (test[0] LT 6) THEN BEGIN
  ;;  Check input structure again
  test           = structure_compare(str[0],dumb_poststr[0],EXACT=exact,MATCH_NT=match_nt,$
                                     MATCH_TG=match_tg,MATCH_TT=match_tt)
  good           = (test[0] GE 6)
  IF (good[0]) THEN post = 2b
ENDIF ELSE BEGIN
  ;;  Input structure went through mms_get_fpi_dist.pro but not add_velmagscpot_to_mms_dist.pro
  good           = 1b
  post           = good[0]
ENDELSE
IF (mssg_on[0]) THEN IF (~good[0]) THEN MESSAGE,badstr_mssg[0],/INFORMATIONAL,/CONTINUE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,good[0]
END
