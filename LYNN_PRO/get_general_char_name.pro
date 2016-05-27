;+
;*****************************************************************************************
;
;  FUNCTION :   get_general_char_name.pro
;  PURPOSE  :   This is a general routine that is supposed to test an input character
;                 designation keyword value to avoid too much repetition of error
;                 handling within multiple routines using similar keywords.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               ALL_POS_CH  :  [N]-Element [string] array defining all the possible
;                                character names to test keyword CHARS against
;
;  EXAMPLES:    
;               ;;  ***  INCORRECT calling sequence  ***
;               all_probes     = ['a','b','c','d','e','f']
;               def_probe      = 'h'
;               probe          = 'k'
;               sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
;               PRINT,';;  ',sat[0]
;               ;;  a
;
;               ;;  ***  INCORRECT calling sequence  ***
;               all_probes     = ['a','b','c','d','e','f']
;               def_probe      = 'd'
;               probe          = 1
;               sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
;               PRINT,';;  ',sat[0]
;               ;;  d
;
;               ;;  ***  INCORRECT calling sequence  ***
;               all_probes     = ['a','b','c','d','e','f']
;               def_probe      = 4.2
;               probe          = 'b'
;               sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
;               PRINT,';;  ',sat[0]
;               ;;  b
;
;               ;;  ***  INCORRECT calling sequence  ***
;               all_probes     = LINDGEN(5)
;               def_probe      = 'a'
;               probe          = 'b'
;               sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
;               % GET_GENERAL_CHAR_NAME: User must supply an [N]-Element [string] array on input...
;               PRINT,';;  ',sat[0]
;               ;;     0
;
;               ;;============================================
;               ;;  Examples:  Changes on return
;               ;;============================================
;               ;;  ***  INCORRECT calling sequence  ***
;               all_probes     = ['a','b','c','d','e','f']
;               def_probe      = 'h'
;               probe          = 'c'
;               sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
;               PRINT,';;  ',sat[0],'  ',def_probe[0]
;               ;;  c  a
;
;               ;;  ***  INCORRECT calling sequence  ***
;               all_probes     = ['a','b','c','d','e','f']
;               def_probe      = 'x'
;               probe          = 'y'
;               sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
;               PRINT,';;  ',sat[0],'  ',def_probe[0]
;               ;;  a  a
;
;               ;;  ***  INCORRECT calling sequence  ***
;               all_probes     = 0
;               dummy          = TEMPORARY(all_probes)     ;;  Method to undefine variable
;               HELP,all_probes,OUTPUT=output
;               FOR j=0L, N_ELEMENTS(output) - 1L DO PRINT,';;  ',output[j]
;               ;;  ALL_PROBES      UNDEFINED = <Undefined>
;               def_probe      = 'a'
;               probe          = 'c'
;               sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
;               % GET_GENERAL_CHAR_NAME: User must supply an [N]-Element [string] array on input...
;               PRINT,';;  ',sat[0],'  ',def_probe[0]
;               ;;     0  a
;
;               ;;============================================
;               ;;  Examples:  Calling sequence
;               ;;============================================
;               ;;  ***  CORRECT calling sequence  ***
;               all_probes     = ['a','b','c','d','e','f']
;               def_probe      = 'a'
;               probe          = 'f'
;               sat            = get_general_char_name(all_probes,CHARS=probe,DEF__NAME=def_probe)
;               PRINT,';;  ',sat[0]
;               ;;  f
;
;  KEYWORDS:    
;               CHARS       :  Scalar [string] defining the character name to test
;                                against the list of possible names defined by ALL_POS_CH
;                                [Default = DEF__NAME[0]]
;               DEF__NAME   :  Scalar [string] defining the default character name to
;                                use in the event that CHARS is undefined on input
;
;   CHANGED:  1)  Renamed from get_general_chars_name.pro to get_general_char_name.pro
;                   so that it is more general than just for spacecraft chars names
;                                                                   [11/04/2015   v2.0.0]
;             2)  Added some more examples to illustrate different uses
;                                                                   [11/06/2015   v2.0.1]
;
;   NOTES:      
;               1)  Make sure that ALL_POS_CH is not only set, but that is an
;                     [N]-element string array otherwise the routine will return
;                     a non-string result (i.e., 0).
;               2)  If CHARS and DEF__NAME are incorrectly set, but ALL_POS_CH is
;                     correctly set on input, the returned result will be ALL_POS_CH[0]
;                       --> DEF__NAME will be redefined to ALL_POS_CH[0]
;               3)  One application of this routine is to reduce error handling for
;                     multi-spacecraft missions like STEREO, THEMIS, MMS, etc.
;
;  REFERENCES:  
;               NA
;
;   CREATED:  11/04/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/06/2015   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_general_char_name,all_pos_ch,CHARS=chars,DEF__NAME=def__name

;;----------------------------------------------------------------------------------------
;;  Define some constants/defaults
;;----------------------------------------------------------------------------------------
;;  Error messages
noinput_mssg   = 'User must supply an [N]-Element [string] array on input...'
incorrf_mssg   = 'Incorrect input format:  ALL_POS_CH must be an [N]-Element [string] array...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (SIZE(all_pos_ch,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define params
all_char       = STRTRIM(all_pos_ch,2)
lowc_chn       = STRLOWCASE(all_char)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DEF__NAME
test           = (N_ELEMENTS(def__name) LT 1)                        ;;  TRUE --> NOT Set, FALSE --> Set
IF (test[0]) THEN def__name = all_char[0] ELSE def__name = def__name[0]
test           = (SIZE(def__name,/TYPE) NE 7)                        ;;  TRUE --> NOT a string, FALSE --> a string
IF (test[0]) THEN def__name = all_char[0] ELSE def__name = STRTRIM(def__name[0],2)
test           = (TOTAL(STRLOWCASE(def__name[0]) EQ lowc_chn) EQ 0)  ;;  TRUE --> NOT a possible chars name, FALSE --> correctly set
IF (test[0]) THEN def__name = all_char[0]
;;  Check CHARS
test           = (N_ELEMENTS(chars) LT 1)                            ;;  TRUE --> NOT Set, FALSE --> Set
IF (test[0]) THEN chn = def__name[0] ELSE chn = chars[0]
test           = (SIZE(chn,/TYPE) NE 7)                              ;;  TRUE --> NOT a string, FALSE --> a string
IF (test[0]) THEN chn = def__name[0] ELSE chn = STRTRIM(chn[0],2)
test           = (TOTAL(STRLOWCASE(chn[0]) EQ lowc_chn) EQ 0)        ;;  TRUE --> NOT a possible chars name, FALSE --> correctly set
IF (test[0]) THEN chn = def__name[0]
;;----------------------------------------------------------------------------------------
;;  Passed test --> Return to user
;;----------------------------------------------------------------------------------------

RETURN,chn[0]
END

