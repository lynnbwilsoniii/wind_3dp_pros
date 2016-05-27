;+
;*****************************************************************************************
;
;  FUNCTION :   test_wind_vs_themis_esa_struct.pro
;  PURPOSE  :   This routine determines which spacecraft (Wind or THEMIS) an input
;                 data structure originates from.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               test_3dp_struc_format.pro
;               test_themis_esa_struc_format.pro
;               dat_3dp_str_names.pro
;               dat_themis_esa_str_names.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT     :  [string,structure] associated with a known THEMIS ESA or Wind
;                            3DP data structure
;                              THEMIS Structure Inputs:
;                                  dat = get_th?_p???()
;                                  {outputs from thm_load_p???.pro routines should work}
;                              Wind Structure Inputs:
;                                  dat = get_???()
;                                    ???  =  el, ehb, sft, etc.
;
;  EXAMPLES:    
;               test = test_wind_vs_themis_esa_struct(dat,NOM=nom,PAD=test_pad)
;
;  KEYWORDS:    
;               NOM     :  If set, routine will not print out messages
;               PAD     :  If set, routine will test if routine was returned by pad.pro
;
;   CHANGED:  1)  Fixed a typo in the error handling checks
;                                                                   [03/14/2012   v1.0.1]
;             2)  Added keyword:  NOM
;                                                                   [03/29/2012   v1.1.0]
;             3)  Now routine should work with structures returned by pad.pro and
;                   added keyword:  PAD
;                                                                   [10/02/2014   v1.2.0]
;
;   NOTES:      
;               1)  See also:  test_3dp_struc_format.pro and
;                              test_themis_esa_struc_format.pro
;               2)  Routine should now be able to handle structures returned by pad.pro
;
;  REFERENCES:  
;               
;
;   CREATED:  03/13/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/02/2014   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION test_wind_vs_themis_esa_struct,dat,NOM=nom,PAD=test_pad

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
notstr_mssg    = 'Must be an IDL structure...'
badstr_wind    = 'Not an appropriate 3DP structure...'
badstr_themis  = 'Not an appropriate THEMIS ESA structure...'
badstr_mssg    = 'Not an appropriate Wind nor THEMIS structure...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF N_PARAMS() EQ 0 THEN RETURN,{WIND:0b,THEMIS:0b}
str = dat[0]   ;;  in case it is an array of structures of the same format
IF (SIZE(str,/TYPE) NE 8L) THEN BEGIN
  IF ~KEYWORD_SET(nom) THEN MESSAGE,notstr_mssg,/INFORMATIONAL,/CONTINUE
  RETURN,{WIND:0b,THEMIS:0b}
ENDIF
;;----------------------------------------------------------------------------------------
;;  Determine if input is from Wind or THEMIS
;;----------------------------------------------------------------------------------------
test_wind   = test_3dp_struc_format(str,NOM=nom,PAD=test_pad)
test_themis = test_themis_esa_struc_format(str,NOM=nom,PAD=test_pad)
good        = WHERE([test_wind,test_themis],gd)

CASE gd OF
  1 : BEGIN
    ;;  either Wind or THEMIS structure
    CASE good[0] OF
      0 : BEGIN
        ;;  Wind structure
        RETURN,{WIND:1b,THEMIS:0b}
      END
      1 : BEGIN
        ;;  THEMIS structure
        RETURN,{WIND:0b,THEMIS:1b}
      END
    ENDCASE
  END
  0 : BEGIN
    ;;  neither Wind nor THEMIS structure
    IF ~KEYWORD_SET(nom) THEN MESSAGE,badstr_mssg,/INFORMATIONAL,/CONTINUE
    RETURN,{WIND:0b,THEMIS:0b}
  END
  2 : BEGIN
    ;;  modified Wind or THEMIS structure
    test_wind   = SIZE(dat_3dp_str_names(str,NOM=nom),/TYPE) EQ 8L
    test_themis = SIZE(dat_themis_esa_str_names(str,NOM=nom),/TYPE) EQ 8L
    good_test   = TOTAL([test_wind,test_themis]) EQ 1
    test        = (test_wind NE test_themis) AND good_test
    IF (test) THEN BEGIN
      RETURN,{WIND:test_wind[0],THEMIS:test_themis[0]}
    ENDIF ELSE BEGIN
      test2  = (test_wind EQ test_themis)
      test3  = (good_test NE 1)
      IF (test2) THEN badmssg = badstr_mssg ELSE badmssg = 'How did you managed this?'
      IF ~KEYWORD_SET(nom) THEN MESSAGE,badmssg,/INFORMATIONAL,/CONTINUE
      RETURN,{WIND:0b,THEMIS:0b}
    ENDELSE
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Return
;;----------------------------------------------------------------------------------------

END