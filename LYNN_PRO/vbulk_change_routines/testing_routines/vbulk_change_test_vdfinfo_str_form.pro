;+
;*****************************************************************************************
;
;  FUNCTION :   vbulk_change_test_vdfinfo_str_form.pro
;  PURPOSE  :   This routine tests the structure format of the informational structure
;                 for each input velocity distribution function (VDF).
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               structure_compare.pro
;               tag_names_r.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Vbulk Change IDL Libraries
;
;  INPUT:
;               DAT        :  Scalar [structure] array containing information
;                               relevant to a VDF with the following format
;                               [*** units and format matter here ***]:
;                                 SE_T   :  [2]-Element [double] array defining to the
;                                             start and end times [Unix] of the VDF
;                                 SCFTN  :  Scalar [string] defining the spacecraft name
;                                             [e.g., 'Wind' or 'THEMIS-B']
;                                 INSTN  :  Scalar [string] defining the instrument name
;                                             [e.g., '3DP' or 'ESA' or 'EESA' or 'SST']
;                                 SCPOT  :  Scalar [float] defining the spacecraft
;                                             electrostatic potential [eV] at the time of
;                                             the VDF
;                                 VSW    :  [3]-Element [float] array defining to the
;                                             bulk flow velocity [km/s] 3-vector at the
;                                             time of the VDF
;                                 MAGF   :  [3]-Element [float] array defining to the
;                                             quasi-static magnetic field [nT] 3-vector at
;                                             the time of the VDF
;
;  EXAMPLES:    
;               [calling sequence]
;               test = vbulk_change_test_vdfinfo_str_form(dat [,DAT_OUT=dat_out])
;
;  KEYWORDS:    
;               DAT_OUT    :  Set to a named variable to return a properly formatted
;                               version of DAT that has the expected structure tags
;                               and dimensions
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [07/25/2017   v1.0.0]
;             2)  Continued to write routine
;                                                                   [07/27/2017   v1.0.0]
;
;   NOTES:      
;               1)  This is meant to be called by other routines within the
;                     Vbulk Change library of routines
;
;  REFERENCES:  
;               NA
;
;   CREATED:  07/24/2017
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/27/2017   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vbulk_change_test_vdfinfo_str_form,dat,DAT_OUT=dat_out

;;----------------------------------------------------------------------------------------
;;  Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define required tags
def_tags       = ['se_t','scftn','instn','scpot','vsw','magf']
def_stype      = ['double','string','string','float','float','float']
def_sdims      = ['[2]-element array','scalar','scalar','scalar','[3]-element array','[3]-element array']
def_vtype      = [5L,7L,7L,4L,4L,4L]

dumb3d         = REPLICATE(0d0,3L)
dumb2d         = dumb3d[0:1]
dumb3f         = FLOAT(dumb3d)
dumb_str       = CREATE_STRUCT(def_tags,dumb2d,'','',0e0,dumb3f,dumb3f)
def_nt         = N_TAGS(dumb_str)
;;  Initialize default output
dat_out        = dumb_str
;;  Dummy error messages
notstr_msg     = 'User must input DAT as a scalar IDL structure...'
notvdf_msg     = 'DAT must be an IDL structure...'
badstr_msg0    = 'DAT must have the following structure tags:  '
badstr_msg1    = STRUPCASE(def_tags)
badfor0msg     = 'The tags within DAT must have the following data type values:'
badfor1msg     = badstr_msg1+'  :  '+STRUPCASE(def_stype)
badfor2msg     = 'The tags within DAT must have the following dimensions:'
badfor3msg     = badstr_msg1+'  :  '+STRUPCASE(def_sdims)
defout_msg     = 'Returning default structure with null values!'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;  Check for an input
test           = (N_ELEMENTS(dat)  EQ 0) OR (N_PARAMS() NE 1)
IF (test[0]) THEN BEGIN
  MESSAGE,notstr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check input type
str            = dat[0]
test           = (SIZE(str,/TYPE) NE 8)
IF (test[0]) THEN BEGIN
  MESSAGE,notvdf_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Verify structure format
;;----------------------------------------------------------------------------------------
temp           = structure_compare(str,dumb_str,EXACT=exact,MATCH_NT=match_nt,$
                                   MATCH_TG=match_tg,MATCH_TT=match_tt,       $
                                   NUMOVR_TG=numovr_tg,NUMOVR_TT=numovr_tt    )
test           = (temp[0] LE 4) OR (~match_nt[0] OR ~match_tg[0])
IF (test[0]) THEN BEGIN
  MESSAGE,badstr_msg0[0],/INFORMATIONAL,/CONTINUE
  FOR j=0L, def_nt[0] - 1L DO PRINT,'%%  '+badstr_msg1[j]
  RETURN,0b
ENDIF
;;  Get info from structure
str_tags       = tag_names_r(str,TYPE=str_types,COUNT=str_nt)
;;  Check if dimensions are the issue
test           = (temp[0] EQ 6) AND (match_nt[0] AND match_tg[0])
IF (test[0]) THEN BEGIN
  ;;  Bad input format:  dimension conflicts
  MESSAGE,badfor2msg[0],/INFORMATIONAL,/CONTINUE
  FOR j=0L, def_nt[0] - 1L DO PRINT,'%%  '+badfor3msg[j]
  MESSAGE,defout_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF ELSE BEGIN
  ;;  Check if types are the issue
  test           = (temp[0] EQ 5) AND (match_nt[0] AND match_tg[0])
  IF (test[0]) THEN BEGIN
    ;;  Bad input format:  type conflicts
    MESSAGE,badfor0msg[0],/INFORMATIONAL,/CONTINUE
    FOR j=0L, def_nt[0] - 1L DO PRINT,'%%  '+badfor1msg[j]
    MESSAGE,defout_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF ELSE BEGIN
    ;;  Exact match --> Good input
;    dat_out  = str[0]
    dat_out  = dat
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,1b
END


