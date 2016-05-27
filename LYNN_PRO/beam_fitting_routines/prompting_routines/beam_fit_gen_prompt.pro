;+
;*****************************************************************************************
;
;  FUNCTION :   beam_fit_gen_prompt.pro
;  PURPOSE  :   Prompts user for information related to STR_OUT or informs user with
;                 information defined by PRO_OUT, WINDN, or ERRMSG.
;
;  CALLED BY:   
;               beam_fit_cursor_select.pro
;               beam_fit_keywords_init.pro
;               beam_fit_fit_prompts.pro
;               beam_fit_fit_wrapper.pro
;               beam_fit_change_parameter.pro
;               beam_fit_options.pro
;               beam_fit_prompts.pro
;               beam_fit_1df_plot_fit.pro
;               wrapper_beam_fit_array.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               STR_OUT    :  Scalar [string] that tells the user what to enter at
;                               prompt
;               PRO_OUT    :  Scalar(or array) [string] containing instructions for
;                               input
;               WINDN      :  Scalar [long] defining the index of the window to use when
;                               selecting the region of interest.  If set, routine will
;                               print out this number for reference to help the user.
;                               [Default = FALSE]
;               ERRMSG     :  Scalar(or array) [string] containing error messages the
;                               user wishes to print to screen
;               FORM_OUT   :  Scalar [long] defining the type code of the prompt
;                               input and output
;                               [Default = 7 (string)]
;
;   CHANGED:  1)  Changed name to beam_fit_gen_prompt.pro          [08/28/2012   v1.0.0]
;             2)  Continued to write routine                       [09/07/2012   v1.0.0]
;
;   NOTES:      
;               1)  This is a generalized prompting routine for the beam fitting
;                     software package
;
;   CREATED:  08/27/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/07/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION beam_fit_gen_prompt,STR_OUT=str_out,PRO_OUT=pro_out,WINDN=windn,ERRMSG=errmsg,$
                             FORM_OUT=form_out

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; Define separators for prompts
str_sta        = "=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>"
str_end        = "<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<=<="
;; Define separators for window reference
str_win        = "<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>"
;; Define separators for error messages
str_ers        = "&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>&>"
str_ere        = "<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&<&"
;; Define separators for instructions
str_pro        = "-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|"
;; Define Default Window titles
w_tt_suff      = [' [Core Bulk Frame]',' [Core Bulk Frame]',' [Core Bulk Frame]',$
                  ' [Beam Bulk Frame]']
wttls          = ['Entire Distribution','Halo Distribution','Beam Cuts',$
                  'Beam Distribution']+w_tt_suff
;;----------------------------------------------------------------------------------------
;; Format Prompt Output
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(form_out) EQ 0) THEN form_out = 7  ;; Use default [string]
CASE form_out OF
  1    :  BEGIN
     ;;  8-bit, Unsigned Long,    Byte
     read_out       = 0b
     func           = 'BYTE'
  END
  2    :  BEGIN
     ;; 16-bit,   Signed Long,    Integer
     read_out       = 0
     func           = 'FIX'
  END
  3    :  BEGIN
     ;; 32-bit,   Signed Long,    Integer
     read_out       = 0L
     func           = 'LONG'
  END
  4    :  BEGIN
     ;; 32-bit, Single-Precision, Float
     read_out       = 0e0
     func           = 'FLOAT'
  END
  5    :  BEGIN
     ;; 64-bit, Double-Precision, Double
     read_out       = 0d0
     func           = 'DOUBLE'
  END
  7    :  BEGIN
     ;;                           String
     read_out       = ''
     func           = 'STRLOWCASE'
  END
  14    :  BEGIN
     ;; 64-bit,   Signed Long,    Integer
     read_out       = 0LL
     func           = 'LONG64'
  END
  6    :  BEGIN
     ;; 32-bit,       Complex Float
     func           = 'COMPLEX'
     read_out       = CALL_FUNCTION(func[0],0d0,0d0)
  END
  9    :  BEGIN
     ;; 64-bit,       Complex Double
     func           = 'DCOMPLEX'
     read_out       = CALL_FUNCTION(func[0],0d0,0d0)
  END
  ELSE  :  BEGIN
     ;;                           String
     read_out       = ''
     func           = 'STRLOWCASE'
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;; => Define error handling
;;----------------------------------------------------------------------------------------
default_out = read_out[0]

CATCH, error_status

IF (error_status NE 0) THEN BEGIN 
  PRINT, 'Error index: ', error_status
  PRINT, 'Error message: ', !ERROR_STATE.MSG
  ;; => Deal with error
  read_out       = default_out[0]           ;; Use default output
  ;; => Cancel error handler
  CATCH, /CANCEL
  ;; => Return to user
  RETURN,read_out
ENDIF
;;----------------------------------------------------------------------------------------
;; => Check to make sure something was entered
;;----------------------------------------------------------------------------------------
test           = ~KEYWORD_SET(pro_out) AND ~KEYWORD_SET(windn) AND $
                 ~KEYWORD_SET(str_out) AND ~KEYWORD_SET(errmsg)
IF (test) THEN STOP
;;----------------------------------------------------------------------------------------
;; => Print out window reference
;;----------------------------------------------------------------------------------------
test           = ((SIZE(windn,/TYPE) GT 0) AND (SIZE(windn,/TYPE) LT 6))
IF (test) THEN BEGIN
  win_out        = "Working in Window #:  "+STRING(windn[0],FORMAT='(I2.2)')
  win_out       += "  [Title:  '"+wttls[windn[0] - 1L]+"']"
  PRINT, ""
  PRINT, str_win[0]
  PRINT, win_out[0]
  PRINT, str_win[0]
  PRINT, ""
ENDIF
;;----------------------------------------------------------------------------------------
;; => Print out procedure/instructions
;;----------------------------------------------------------------------------------------
test           = KEYWORD_SET(pro_out) AND (SIZE(pro_out,/TYPE) EQ 7)
IF (test) THEN BEGIN
  npro           = N_ELEMENTS(pro_out)
  PRINT, ""
  PRINT, ""
  PRINT, str_pro[0]
  FOR j=0L, npro - 1L DO PRINT,pro_out[j]
  PRINT, str_pro[0]
  PRINT, ""
  PRINT, ""
ENDIF
;;----------------------------------------------------------------------------------------
;; => Prompt user
;;----------------------------------------------------------------------------------------
test           = KEYWORD_SET(str_out) AND (SIZE(str_out,/TYPE) EQ 7)
IF (test) THEN BEGIN
  PRINT, ""
  PRINT, str_sta[0]
  READ,read_out,PROMPT=str_out
  PRINT, str_end[0]
  PRINT, ""
  read_out       = CALL_FUNCTION(func[0],read_out[0])
ENDIF
;;----------------------------------------------------------------------------------------
;; => Print out error message
;;----------------------------------------------------------------------------------------
test           = KEYWORD_SET(errmsg) AND (SIZE(errmsg,/TYPE) EQ 7)
IF (test) THEN BEGIN
  nerr           = N_ELEMENTS(errmsg)
  PRINT, ""
  PRINT, str_ers[0]
  FOR j=0L, nerr - 1L DO PRINT,errmsg[j]
  PRINT, str_ere[0]
  PRINT, ""
ENDIF
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,read_out
END


