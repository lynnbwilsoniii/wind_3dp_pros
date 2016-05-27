;+
;*****************************************************************************************
;
;  FUNCTION :   get_greek_letter.pro
;  PURPOSE  :   Returns the embedded font command string associated with a Greek letter
;                 for the current setting of !P.FONT.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               LETTER  :  Scalar [string] that matches any of the Greek letter names
;                            shown in the NOTES section below
;
;  EXAMPLES:    
;               ;;-------------------------------------------------------
;               ;;  Check the result when TrueType fonts are used
;               ;;-------------------------------------------------------
;               IDL> !P.FONT = 1
;               IDL> omega   = get_greek_letter('omega')
;               IDL> PRINT,omega
;               !9w!X
;               ;;-------------------------------------------------------
;               ;;  Check the result when Hershey Vector fonts are used
;               ;;-------------------------------------------------------
;               IDL> !P.FONT = -1
;               IDL> omega   = get_greek_letter('omega')
;               IDL> PRINT,omega
;               !7x!X
;               ;;-------------------------------------------------------
;               ;; => Print example to window display
;               ;;-------------------------------------------------------
;               IDL> greekstr    = ['alpha','beta','gamma','delta','epsilon','zeta',   $
;               IDL>                'eta','theta','iota','kappa','lambda','mu','nu',   $
;               IDL>                'xi','omicron','pi','rho','sigma','tau','upsilon', $
;               IDL>                'phi','chi','psi','omega']
;               IDL> WINDOW,1,RETAIN=2
;               IDL> WSET,1
;               IDL> x0 = 0.05
;               IDL> y0 = 0.95
;               IDL> !P.FONT = -1  ;; use Hershey Vector Fonts
;               IDL> cc = 0L
;               IDL> FOR j=0L, 1L DO BEGIN                                    $
;               IDL>   FOR k=0L, 11L DO BEGIN                                 $
;               IDL>     PRINT,cc,'  '+symbol_str[cc]                       & $
;               IDL>     x = x0 + 0.03*k                                    & $
;               IDL>     y = y0 - 0.03*j                                    & $
;               IDL>     s = get_greek_letter(greekstr[cc])                 & $
;               IDL>     xyouts,x[0],y[0],s[0],/NORMAL,SIZE=2.5,ALIGN=0.50  & $
;               IDL>     cc++
;
;  KEYWORDS:    
;               SIMPLE  :  If set, routine uses Simplex Greek (!4) instead of
;                            Complex Greek (!7)
;
;   CHANGED:  1)  Corrected issue that occurred when calling routine before setting
;                   device to PS, for instance
;                                                                  [07/16/2013   v1.1.0]
;
;   NOTES:      
;               1)  Here are the possible inputs for LETTER [under Greek Letter column]
;                     where the ASCII letters map to the Complex Greek column octals
;    ``````````````````````````````````````````````````````````````````````````````````
;    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;    ´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
;                [lower case]
;      ASCII     Greek Letter          Symbol (!9)          Complex Greek (!7)
;                                        Octal                   Octal
;    =====================================================================================
;        a           alpha               14x01                   14x01
;        b           beta                14x02                   14x02
;        c           gamma               14x07                   14x03
;        d           delta               14x04                   14x04
;        e           epsilon             14x05                   14x05
;        f           zeta                16x12                   14x06
;        g           eta                 14x10                   14x07
;        h           theta               16x01                   14x10
;        i           iota                14x11                   14x11
;        j           kappa               14x13                   14x12
;        k           lambda              14x14                   14x13
;        l           mu                  14x15                   14x14
;        m           nu                  14x16                   14x15
;        n           xi                  16x10                   14x16
;        o           omicron             14x17                   14x17
;        p           pi                  16x00                   16x00
;        q           rho                 16x02                   16x01
;        r           sigma               16x03                   16x02
;        s           tau                 16x04                   16x03
;        t           upsilon             16x05                   16x04
;        u           phi                 14x06                   16x05
;        v           chi                 14x03                   16x06
;        w           psi                 16x11                   16x07
;        x           omega               16x07                   16x10
;    ``````````````````````````````````````````````````````````````````````````````````
;    ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;    ´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
;               2)  The first N characters of LETTER must be enough to match to a unique
;                     substring associated with one of the above Greek letter names
;                       => if LETTER = 'eta', then the Greek letter name eta is returned
;                            ONLY...  the routine assumes the first character corresponds
;                            to the first letter of the Greek letter name you wish to
;                            return
;                       => if LETTER = 'om', then '' is returned since LETTER was not
;                            unique [omega and omicron would satisfy this search]
;               3)  To get the uppercase equivalents, just use STRUPCASE on the result
;                     [at least this is true for Hershey Vector Fonts]
;
;   CREATED:  08/24/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/16/2013   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_greek_letter,letter,SIMPLE=simple

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
;; Define the execution command to convert the octal strings below to octal #'s
;; => Octal Number Conversions
;;      To convert the above to the below, do the following
;;
;;     IDL> cform     = "(1H',I3.3,1H','OL')"
;;     IDL> octstr    = octal_tt
;;     IDL> octnum    = LONG(STRMID(octstr,0L,2L))*10L + LONG(STRMID(octstr,3L,2L))
;;     IDL> PRINT, octnum, FORMAT=cform
;;
;;---------------------------------------------------------
;; TrueType Octals [Symbol Font]
;;---------------------------------------------------------
octal_tt    = ['14x01','14x02','14x07','14x04','14x05','16x12','14x10','16x01','14x11',$
               '14x13','14x14','14x15','14x16','16x10','14x17','16x00','16x02','16x03',$
               '16x04','16x05','14x06','14x03','16x11','16x07']
;; => Octal Number Conversions
oct_byte_tt = ['141'OL,'142'OL,'147'OL,'144'OL,'145'OL,'172'OL,'150'OL,'161'OL,'151'OL,$
               '153'OL,'154'OL,'155'OL,'156'OL,'170'OL,'157'OL,'161'OL,'162'OL,'163'OL,$
               '164'OL,'165'OL,'146'OL,'143'OL,'171'OL,'167'OL]
;;---------------------------------------------------------
;; Hershey Vector Octals [Complex (and Simplex) Greek Font]
;;---------------------------------------------------------
octal_hv    = ['14x01','14x02','14x03','14x04','14x05','14x06','14x07','14x10','14x11',$
               '14x12','14x13','14x14','14x15','14x16','14x17','16x00','16x01','16x02',$
               '16x03','16x04','16x05','16x06','16x07','16x10']
;; => Octal Number Conversions
oct_byte_hv = ['141'OL,'142'OL,'143'OL,'144'OL,'145'OL,'146'OL,'147'OL,'150'OL,'151'OL,$
               '152'OL,'153'OL,'154'OL,'155'OL,'156'OL,'157'OL,'160'OL,'161'OL,'162'OL,$
               '163'OL,'164'OL,'165'OL,'166'OL,'167'OL,'170'OL]
;;---------------------------------------------------------
;; String names of greek letters
;;---------------------------------------------------------
greekstr    = ['alpha','beta','gamma','delta','epsilon','zeta','eta','theta','iota',$
               'kappa','lambda','mu','nu','xi','omicron','pi','rho','sigma','tau',  $
               'upsilon','phi','chi','psi','omega']
;;----------------------------------------------------------------------------------------
;; => Define current device settings
;;----------------------------------------------------------------------------------------
old_name       = STRLOWCASE(!D.NAME)
old_font       = !P.FONT
;;  Make sure isolatin is set
IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN DEVICE,ISOLATIN1=1
;;  Get current device settings
IF (STRLOWCASE(!D.NAME) NE 'ps') THEN SET_PLOT,'PS'
HELP,/DEVICE,OUTPUT=current_device_ps
;; Return to previous device
SET_PLOT,old_name[0]
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (SIZE(letter,/TYPE) NE 7) OR (N_PARAMS() NE 1)
IF (test) THEN BEGIN
  ;; => no (or bad) input???
  noinpt_msg     = 'No(or incorrect) input supplied...'
  MESSAGE,noinpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,''
ENDIF
glett          = STRLOWCASE(letter[0])
;;----------------------------------------------------------------------------------------
;; => Make sure it matches one of the greek letter names
;;----------------------------------------------------------------------------------------
match          = STRMATCH(greekstr,glett[0]+'*',/FOLD_CASE)
test           = TOTAL(match) NE 1
IF (test) THEN BEGIN
  ;; => no (or bad) input???
  badinp_msg     = 'LETTER must represent the first [N]-unique characters of a Greek letter name...'
  MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,''
ENDIF
good_let       = WHERE(match,gdlt)
;;----------------------------------------------------------------------------------------
;; => Determine the current font mapping
;;----------------------------------------------------------------------------------------
test           = STRMATCH(current_device_ps,'*Symbol*',/FOLD_CASE)
good           = WHERE(test,gd)

CASE old_font[0] OF
  -1   : BEGIN
    ;; Using Hershey Vector Fonts
    oct_byte = BYTE(oct_byte_hv)
    IF KEYWORD_SET(simple) THEN nmap = '!4' ELSE nmap = '!7'
  END
   1   : BEGIN
    ;; Using TrueType Fonts
    oct_byte = BYTE(oct_byte_tt)
    IF (gd GT 0) THEN BEGIN
      ;; determine font index of Symbol TrueType Font
      gdevc = current_device_ps[good[0]]
      gposi = STRPOS(gdevc[0],'Symbol')
      pmap  = STRTRIM(STRMID(gdevc[0],gposi[0]-6L,6L),2L)
      IF (STRLEN(pmap) EQ 4) THEN gels = [1L,2L] ELSE gels = [1L,3L]
      nmap  = STRMID(pmap[0],gels[0],gels[1])
    ENDIF ELSE BEGIN
      ;; couldn't find Symbol => quit?
      badmap_msg     = 'Could not find mapping to Symbol font...'
      MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
      RETURN,''
    ENDELSE
  END
  ELSE : BEGIN
    ;; Using Device Fonts
    oct_byte = BYTE(oct_byte_tt)
    IF (gd GT 0) THEN BEGIN
      ;; determine font index of Symbol TrueType Font
      gdevc = current_device_ps[good[0]]
      gposi = STRPOS(gdevc[0],'Symbol')
      pmap  = STRTRIM(STRMID(gdevc[0],gposi[0]-6L,6L),2L)
      IF (STRLEN(pmap) EQ 4) THEN gels = [1L,2L] ELSE gels = [1L,3L]
      nmap  = STRMID(pmap[0],gels[0],gels[1])
    ENDIF ELSE BEGIN
      ;; couldn't find Symbol => quit?
      badmap_msg     = 'Could not find mapping to Symbol font...'
      MESSAGE,badinp_msg[0],/INFORMATIONAL,/CONTINUE
      RETURN,''
    ENDELSE
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;; => Define output
;;                       TrueType       Hershey Vector
;;      e.g. '!7x!X' =      xi               omega
;;----------------------------------------------------------------------------------------
oct_str   = STRING(oct_byte[good_let[0]])
IF (oct_str[0] NE '') THEN str_embed = nmap[0]+oct_str[0]+'!X' ELSE str_embed = ''
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,str_embed
END
