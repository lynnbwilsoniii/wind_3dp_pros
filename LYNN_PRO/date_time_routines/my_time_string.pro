;+
;*****************************************************************************************
;
;  FUNCTION :   my_time_string.pro
;  PURPOSE  :  Creates a structure of times with strings of the form ('HH:MM:SS.sss') 
;                 and ('HHMMSS.sss'), time arrays in seconds of day, unix time, and
;                 epoch times.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               epoch2unix.pro
;               time_double.pro
;               my_str_date.pro
;               time_struct.pro
;               unix2epoch.pro
;               string_replace_char.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               RT2       :  N-Element array of times in one of the following forms:
;                            1 = 'YYYY-MM-DD/HH:MM:SS[.ssss]'
;                            2 = 'MM/DD/YYYY HH:MM:SS[.ssss]'
;                            3 = 'MMDDYY HH:MM:SS[.ssss]'
;                            4 = 'HH:MM:SS.ssss'
;                            5 = 'HH:MM:SS'
;                            6 = 'YYYY/MM/DD hh:mm:ss[.xxxx...]'
;                            7 = Seconds of day (SOD) [float or double]
;                            8 = Unix time            [double]
;                            9 = Epoch time           [double]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               FORM      :  
;                            1 = Assumes ['YYYY-MM-DD/HH:MM:SS[.ssss]'] {Default}
;                            2 = Assumes ['MM/DD/YYYY HH:MM:SS[.ssss]'] 
;                            3 = Assumes ['MMDDYY HH:MM:SS[.ssss]']
;                            4 = Assumes ['HH:MM:SS.ssss']
;                            5 = Assumes ['HH:MM:SS']
;                            6 = Returns ['YYYY/MM/DD hh:mm:ss[.xxxx...]']
;                              but assumes input ['YYYY-MM-DD/HH:MM:SS[.ssss]']
;                               => FORM:6 is to change FORM:1 into a time_string.pro or
;                                    time_double.pro format-friendly string
;                      ...................................................................
;                      :   Define a format for string inputs which tells the             :
;                      :   program the locations of each element of the string           :
;                      :=>  {MON:0L,DAY:3L,YEAR:6L,HH:11L,MM:14L,SS:17L,MS:20L}          :
;                      :    for 'MM/DD/YYYY HH:MM:SS.ssss'                               :
;                      ...................................................................
;               SECONDS   :  Specifies the type of input given is in seconds
;                              of day => forces you to only get data in terms of one day
;               UNIX      :  Tells the program the times are in unix times
;               EPOCH     :  Time is in epoch format
;               STR       :  Tells program that input is a string of one of the forms:
;                              1)  ['YYYY-MM-DD/HH:MM:SS'] => can get unix and epoch times
;                              2)  ['MM/DD/YYYY HH:MM:SS'] => can get unix and epoch times
;                              3)  ['MMDDYY HH:MM:SS']     => can get unix and epoch times
;                              4)  ['HH:MM:SS.ssss']       => can ONLY get sec. of day
;                              5)  ['HH:MM:SS']            => can ONLY get sec. of day
;                              [Note: Forms 1-3 could have '.sss[s]' added on potentially]
;               TO_UNIX   :  Tells program to ONLY return an associated unix time
;               TO_SOD    :  Tells program to ONLY return seconds of day 
;               TO_EPOCH  :  Tells program to ONLY return an associated EPOCH time
;               TO_YMD    :  Tells program to ONLY return an array of form 
;                              ['YYYY-MM-DD/HH:MM:SS.ssss']
;               DATE      :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]  ONLY send in
;                              this parameter when your array is in seconds of day to allow
;                              program to find other useful times (i.e. unix)
;               PREC      :  Scalar defining the number of decimal places to use for the
;                              fractional seconds
;                              [Default = 4, limit to 6 or less]
;
;   CHANGED:  1)  Changed manner in which to handle milliseconds if 
;                  a form is given, but data doesn't have millisecond
;                  data [09/04/2008   v1.1.1]
;             2)  Complete re-write                          [09/04/2008   v2.0.0]
;             3)  Changed output                             [09/05/2008   v2.0.1]
;             4)  Added keyword DATE                         [09/11/2008   v2.0.2]
;             5)  Changed order of Case statement for speed  [09/24/2008   v2.0.3]
;                 [increased speed by factor of 1.22961 from v2.0.2]
;             6)  Added function time_struct.pro             [09/24/2008   v2.0.4]
;                 [increased speed by factor of 2.33970 from v2.0.2]
;             7)  Removed function my_time_to_epoch.pro      [09/24/2008   v2.0.5]
;                 [increased speed by factor of 2.74314 from v2.0.2]
;             8)  my_str_date.pro output changed => changed indexing in my_time_string.pro
;                                                            [05/25/2009   v2.0.6]
;             9)  Added keyword:  NOMSSG                     [05/25/2009   v2.0.7]
;            10)  Changed precision of milliseconds          [07/16/2009   v2.1.0]
;            11)  Added keyword:  PREC                       [01/31/2010   v2.2.0]
;            12)  Fixed a typo                               [02/01/2010   v2.2.1]
;            13)  Fixed a typo                               [02/09/2010   v2.3.0]
;            14)  Added FORM = 6 (not a functionality issue)
;                                                            [05/29/2010   v2.3.1]
;            15)  Fixed issue with keyword PREC that occasionally became a problem
;                   and now calls string_replace_char.pro
;                   and updated man page and cleaned up program a little
;                                                            [10/15/2010   v2.4.0]
;            16)  Fixed an issue with keyword PREC that only affected string inputs
;                   of FORM=1, where user wished to change precision
;                                                            [05/24/2011   v2.4.1]
;
;   NOTES:      
;               1)  The keywords STR and FORM must be used together
;               2)  If input is a string, tell the program what the format is
;               3)  If input is a double, inform program if it is Epoch, SOD, or Unix
;
;   CREATED:  03/26/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/24/2011   v2.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION my_time_string,rt2,SECONDS=seconds,UNIX=unix,EPOCH=epoch,STR=str,  $
                            TO_SOD=to_sod,TO_UNIX=to_unix,TO_EPOCH=to_epoch,$
                            TO_YMD=to_ymd,FORM=form,DATE=date,NOMSSG=nom,   $
                            PREC=prec

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; -Define relevant parameters
;-----------------------------------------------------------------------------------------
rt2  = REFORM(rt2)
np   = N_ELEMENTS(rt2)
nty  = SIZE(rt2,/TYPE)
ndi  = SIZE(rt2,/N_DIMENSIONS)
IF (ndi GT 1L) THEN RETURN,rt2     ; -I am not dealing with multiple dimensions!
tcs  = REPLICATE(' ',np)           ; -['HH:MM:SS.sss'] 
tns  = REPLICATE(' ',np)           ; -['HHMMSS.sss'] 
sod  = REPLICATE(!VALUES.D_NAN,np) ; -seconds of day
unxt = REPLICATE(!VALUES.D_NAN,np) ; -unix time
epoc = REPLICATE(!VALUES.D_NAN,np) ; -epoch time
hh   = REPLICATE(' ',np)           ; -['HH']   = hour of day
mm   = REPLICATE(' ',np)           ; -['MM']   = minutes
ss   = REPLICATE(' ',np)           ; -['SS']   = seconds
ms   = REPLICATE(' ',np)           ; -['ssss']  = milliseconds
yr   = REPLICATE(' ',np)           ; -['YYYY'] = year
mnth = REPLICATE(' ',np)           ; -['MM']   = month
days = REPLICATE(' ',np)           ; -['DD']   = days
ymd  = REPLICATE(' ',np)           ; -['YYYY-MM-DD/HH:MM:SS[.sss]']
dum  = CREATE_STRUCT('TIME_C',tcs,'TIME_N',tns,'HOUR',hh,'MINUTE',mm,'SECOND',ss,$
                     'MSec',ms,'SOD',sod,'UNIX',unxt,'EPOCH',epoc)
;-----------------------------------------------------------------------------------------
; -Determine precision of fractional time
;-----------------------------------------------------------------------------------------
dummy_str0 = '000000'
IF (NOT KEYWORD_SET(prec) AND N_ELEMENTS(prec) EQ 0) THEN BEGIN
  prcs = 4
ENDIF ELSE BEGIN
  prcs = LONG(prec < 6)
ENDELSE
prcstr    = STRTRIM(prcs,2)
IF (prcs NE 0) THEN dummy_str = '.'+STRMID(dummy_str0,0L,LONG(prcstr)) ELSE $
                    dummy_str = ''
;-----------------------------------------------------------------------------------------
; -Determine type of input times
;-----------------------------------------------------------------------------------------
check = [KEYWORD_SET(unix),KEYWORD_SET(str),KEYWORD_SET(seconds),KEYWORD_SET(epoch)]
gchck = WHERE(check GT 0L,gch)
IF (gch GT 0L) THEN BEGIN
  IF (gch GT 1L) THEN BEGIN
    print,"Improper keyword settings: = Too many keywords set"
    RETURN,dum
  ENDIF
  chck2 = [KEYWORD_SET(to_sod),KEYWORD_SET(to_unix),$
           KEYWORD_SET(to_epoch),KEYWORD_SET(to_ymd)]
  gchk2 = WHERE(chck2 GT 0L,gch2)
  IF (gch2 GT 0L) THEN BEGIN
    print,"Specific data type desired ..."
    only_str = 1
  ENDIF
  ;*****************************************************************************************
  ;*****************************************************************************************
  CASE gchck[0] OF
    0 : BEGIN  
      ;-----------------------------------------------------------------------------------
      ; => Entered data in form of unix time
      ;-----------------------------------------------------------------------------------
      IF (nty GT 3L AND nty LT 6L) THEN BEGIN
        unxt  = rt2
        tstr  = time_struct(rt2)
        ms    = STRMID(STRTRIM(STRING(FORMAT='(d10.'+prcstr[0]+')',tstr.FSEC),2),2)
        ss    = STRING(FORMAT='(I2.2)',STRTRIM(tstr.SEC,2))
        mm    = STRING(FORMAT='(I2.2)',STRTRIM(tstr.MIN,2))
        hh    = STRING(FORMAT='(I2.2)',STRTRIM(tstr.HOUR,2))
        yr0   = STRING(FORMAT='(I4.4)',STRTRIM(tstr.YEAR,2))
        mnth0 = STRING(FORMAT='(I2.2)',STRTRIM(tstr.MONTH,2))
        days0 = STRING(FORMAT='(I2.2)',STRTRIM(tstr.DATE,2))
        sod   = tstr.SOD
        epoc  = unix2epoch(rt2)
        tcs   = hh+':'+mm+':'+ss+'.'+ms
        tns   = hh+mm+ss+'.'+ms
        ymd  = yr0+'-'+mnth0+'-'+days0+'/'+tcs
        GOTO,JUMP_END
      ENDIF ELSE BEGIN
        print,"Improper data input: = wrong format type"
        RETURN,dum
      ENDELSE
    END
    1 : BEGIN
      ;-----------------------------------------------------------------------------------
      ; => Entered data in form of a string
      ;-----------------------------------------------------------------------------------
      IF (nty EQ 7L) THEN BEGIN
        stng = rt2
        CASE form OF
          ;-------------------------------------------------------------------------------
          1    : BEGIN  ; -['YYYY-MM-DD/hh:mm:ss[.xxxx]']
            ;  {MON:5L,DAY:8L,YEAR:0L,HH:11L,MM:14L,SS:17L,MS:20L}
            arr  = [5L,8L,0L,11L,14L,17L,20L]
            IF (STRLEN(stng[0]) LE 19L) THEN BEGIN
              estr = stng[*]+dummy_str[0]
            ENDIF ELSE BEGIN
              estr = stng
            ENDELSE
            unxt = time_double(estr)
            epoc = unix2epoch(unxt)
; => LBW 10-15-2010
            tlen = 9L                   ; => length of 'HH:MM:SS.' string
            ylen = 20L                  ; => length of ''YYYY-MM-DD HH:MM:SS.'
            IF (prcs NE 0) THEN tcs = STRMID(estr[*],11L,tlen+prcs) ELSE tcs = STRMID(estr[*],11L,tlen-1L)
;            tcs  = STRMID(estr[*],11L)  ; -['HH:MM:SS.ssss']
            tns  = STRMID(tcs[*],0L,2L)+STRMID(tcs[*],3L,2L)+STRMID(tcs[*],6L,2L)+$
                   STRMID(tcs[*],8L,prcs+1L) ; -['HHMMSS.ssss']
            sod  = (unxt MOD 864d2)
; => LBW 05-24-2011
            ymd  = STRMID(estr[*],0L,11L)+tcs[*]
            hh   = STRMID(tcs[*],0L,2L)
            mm   = STRMID(tcs[*],3L,2L)
            ss   = STRMID(tcs[*],6L,2L)
            ms   = STRMID(tcs[*],9L,prcs)
            GOTO,JUMP_END
          END
          ;-------------------------------------------------------------------------------
          2    : BEGIN  ; -['MM/DD/YYYY hh:mm:ss[.ssss]']
            ;  {MON:0L,DAY:3L,YEAR:6L,HH:11L,MM:14L,SS:17L,MS:20L}
            arr  = [0L,3L,6L,11L,14L,17L,20L]
            IF (STRLEN(stng[0]) LE 19L) THEN BEGIN
              stng = stng[*]+dummy_str[0]
            ENDIF ELSE BEGIN
              stng = stng
            ENDELSE
; => LBW 10-15-2010
            tlen = 9L                   ; => length of 'HH:MM:SS.' string
            ylen = 20L                  ; => length of ''YYYY/MM/DD HH:MM:SS.'
            IF (prcs NE 0) THEN tcs = STRMID(stng[*],11L,tlen+prcs) ELSE tcs = STRMID(stng[*],11L,tlen-1L)
;            tcs  = STRMID(stng[*],arr[3L])  ; -['hh:mm:ss.xxxx...']
            tns  = STRMID(tcs[*],0L,2L)+STRMID(tcs[*],3L,2L)+STRMID(tcs[*],6L,2L)+$
                   STRMID(tcs[*],8L,prcs+1L)     ; -['HHMMSS.ssss']
            ymd  = STRMID(stng[*],arr[2L],4L)+'-'+STRMID(stng[*],arr[0L],2L)+'-'+$
                   STRMID(stng[*],arr[1L],2L)+'/'+tcs ; -['YYYY-MM-DD/hh:mm:ss[.xxxx]']
            unxt = time_double(ymd)
            epoc = unix2epoch(unxt)
            sod  = (unxt MOD 864d2)
            hh   = STRMID(stng[*],arr[3L],2L)
            mm   = STRMID(stng[*],arr[4L],2L)
            ss   = STRMID(stng[*],arr[5L],2L)
            ms   = STRMID(stng[*],arr[6L],prcs)
            GOTO,JUMP_END
          END
          ;-------------------------------------------------------------------------------
          3    : BEGIN  ; -['MMDDYY HH:MM:SS'] 
            ;  {MON:0L,DAY:2L,YEAR:4L,HH:7L,MM:10L,SS:13L,MS:-1L}
            arr  = [0L,2L,4L,7L,10L,13L,15L]
            IF (STRLEN(stng[0]) GT 15L) THEN BEGIN
              stng = stng
            ENDIF ELSE BEGIN
              stng = stng[*]+dummy_str[0]
            ENDELSE
            date = STRMID(stng[*],0L,6L)
            hh   = STRMID(stng[*],arr[3L],2L)
            mm   = STRMID(stng[*],arr[4L],2L)
            ss   = STRMID(stng[*],arr[5L],2L)
            IF (prcs NE 0) THEN ms = STRMID(stng[*],arr[6L],prcs+1L) ELSE ms = ''
;            ms   = STRMID(stng[*],arr[6L],prcs)
            tcs  = hh+':'+mm+':'+ss+ms
            tns  = hh+mm+ss+ms
            myds = STRARR(np)        ; -['YYYY-MM-DD']
            test = my_str_date(DATE=date[*])
            myds = test.TDATE[*]     ; -['YYYY-MM-DD']
            ymd  = myds[*]+'/'+tcs[*]
            unxt = time_double(ymd)
            epoc = unix2epoch(unxt)
            sod  = (unxt MOD 864d2)
            GOTO,JUMP_END
          END
          ;-------------------------------------------------------------------------------
          4    : BEGIN  ; -['HH:MM:SS.ssss'] 
            ;  {MON:-1LL,DAY:-1L,YEAR:-1L,HH:0L,MM:3L,SS:6L,MS:9L}
            arr = [-1L,-1L,-1L,0L,3L,6L,8L]
            IF (STRLEN(stng[0]) LE 9L) THEN BEGIN
              stng = stng[*]+dummy_str[0]
            ENDIF ELSE BEGIN
              stng = stng[*]
            ENDELSE
            hh   = STRMID(stng[*],arr[3L],2L)
            mm   = STRMID(stng[*],arr[4L],2L)
            ss   = STRMID(stng[*],arr[5L],2L)
            IF (prcs NE 0) THEN ms = STRMID(stng[*],arr[6L],prcs+1L) ELSE ms = ''
;            ms   = STRMID(stng[*],arr[6L],prcs)
            tcs  = hh+':'+mm+':'+ss+ms
            tns  = hh+mm+ss+ms
            sod  = 36d2*hh + 6d1*mm + 1d0*ss + 1d-3*ms
            GOTO,JUMP_END
          END
          ;-------------------------------------------------------------------------------
          5    : BEGIN  ; -['HH:MM:SS']
            ;  {MON:-1LL,DAY:-1L,YEAR:-1L,HH:0L,MM:3L,SS:6L,MS:-1L}
            arr = [-1L,-1L,-1L,0L,3L,6L,-1L]
            IF (STRLEN(stng[0]) GT 8L) THEN BEGIN
              stng = stng
            ENDIF ELSE BEGIN
              stng = stng[*]+dummy_str[0]
            ENDELSE
            hh   = STRMID(stng[*],arr[3L],2L)
            mm   = STRMID(stng[*],arr[4L],2L)
            ss   = STRMID(stng[*],arr[5L],2L)
            tcs  = hh+':'+mm+':'+ss+dummy_str[0]
            tns  = hh+mm+ss+dummy_str[0]
            sod  = 36d2*hh + 6d1*mm + 1d0*ss
            GOTO,JUMP_END
          END
          ;-------------------------------------------------------------------------------
          6    : BEGIN  ; -['YYYY/MM/DD hh:mm:ss[.xxxx]']
            ;  {MON:5L,DAY:8L,YEAR:0L,HH:11L,MM:14L,SS:17L,MS:20L}
            arr  = [5L,8L,0L,11L,14L,17L,20L]
            IF (STRLEN(stng[0]) LE 19L) THEN BEGIN
              stng = stng[*]+dummy_str[0]
            ENDIF ELSE BEGIN
              stng = stng
            ENDELSE
            ; => want the format:  'YYYY-MM-DD/HH:MM:SS[.ssss]' so we need to change input
            new_string = string_replace_char(stng,'/','-')
            new_string = string_replace_char(new_string,' ','/')  ; => 'YYYY-MM-DD/HH:MM:SS[.ssss]'
            stng       = new_string
            ymd        = stng
; => LBW 10-15-2010
            tlen = 9L                   ; => length of 'HH:MM:SS.' string
            ylen = 20L                  ; => length of ''YYYY/MM/DD HH:MM:SS.'
            IF (prcs NE 0) THEN tcs = STRMID(stng[*],11L,tlen+prcs) ELSE tcs = STRMID(stng[*],11L,tlen-1L)
;            tcs  = STRMID(stng[*],arr[3L])  ; -['hh:mm:ss.xxxx...']
            tns  = STRMID(tcs[*],0L,2L)+STRMID(tcs[*],3L,2L)+STRMID(tcs[*],6L,2L)+$
                   STRMID(tcs[*],8L,prcs+1L)     ; -['hhmmss.xxxx...']
;            ymd  = STRMID(stng[*],arr[2L],4L)+'/'+STRMID(stng[*],arr[0L],2L)+'/'+$
;                   STRMID(stng[*],arr[1L],2L)+' '+tcs[*] ; -['YYYY/MM/DD hh:mm:ss[.xxxx]']
            unxt = time_double(ymd)
            epoc = unix2epoch(unxt)
            sod  = (unxt MOD 864d2)
            hh   = STRMID(tcs[*],0L,2L)
            mm   = STRMID(tcs[*],3L,2L)
            ss   = STRMID(tcs[*],6L,2L)
            ms   = STRMID(tcs[*],9L)
            GOTO,JUMP_END
          END
          ;-------------------------------------------------------------------------------
          ELSE : BEGIN  ; -Use Default ['YYYY-MM-DD/HH:MM:SS[.ssss]']
            IF (STRLEN(stng[0]) LE 19L) THEN BEGIN
              estr = stng[*]+dummy_str[0]
            ENDIF ELSE BEGIN
              estr = stng
            ENDELSE
            unxt = time_double(estr)
            epoc = unix2epoch(unxt)
; => LBW 10-15-2010
            tlen = 9L                   ; => length of 'HH:MM:SS.' string
            ylen = 20L                  ; => length of ''YYYY-MM-DD/HH:MM:SS.'
            IF (prcs NE 0) THEN tcs = STRMID(estr[*],11L,tlen+prcs) ELSE tcs = STRMID(estr[*],11L,tlen-1L)
;            tcs  = STRMID(estr[*],11L)  ; -['HH:MM:SS.ssss']
            tns  = STRMID(tcs[*],0L,2L)+STRMID(tcs[*],3L,2L)+STRMID(tcs[*],6L,2L)+$
                   STRMID(tcs[*],8L) ; -['HHMMSS.ssss']
            sod  = (unxt MOD 864d2)
; => LBW 10-15-2010
            IF (prcs NE 0) THEN ymd = STRMID(estr[*],0L,ylen+prcs) ELSE ymd = STRMID(estr[*],0L,ylen-1L)
            hh   = STRMID(tcs[*],0L,2L)
            mm   = STRMID(tcs[*],3L,2L)
            ss   = STRMID(tcs[*],6L,2L)
            ms   = STRMID(tcs[*],9L)
            GOTO,JUMP_END
          END
          ;-------------------------------------------------------------------------------
        ENDCASE
      ENDIF ELSE BEGIN
        print,"Improper data input: = wrong format type"
        RETURN,dum
      ENDELSE
    END
    2 : BEGIN  
      ;-----------------------------------------------------------------------------------
      ; => Entered data in form of seconds of day
      ;-----------------------------------------------------------------------------------
;      IF (gchk2[0] NE 3L) THEN print,"Impossible request...need date associated w/ times"
      hh  = STRTRIM(STRING(FORMAT='(I2.2)',LONG(rt2/36d2)),2)
      mm  = STRTRIM(STRING(FORMAT='(I2.2)',LONG((rt2 - hh*3600L)/6d1)),2)
      ss  = STRTRIM(STRING(FORMAT='(I2.2)', LONG((rt2 - hh*3600L - 60L*LONG(mm)))),2)
;      sr  = STRTRIM(STRING(FORMAT='(d10.'+prcstr[0]+')',rt2 - LONG(rt2)),2)
; => LBW 10-15-2010
      sr  = STRMID(STRTRIM(STRING(FORMAT='(d10.'+prcstr[0]+')',rt2 - LONG(rt2)),2),2)
      ms  = STRMID(sr,1L,prcs+1L)
      tcs = hh+':'+mm+':'+ss+ms     ; => ['HH:MM:SS[.ssss]']
      tns = hh+mm+ss+ms
      sod = DOUBLE(rt2)
      IF KEYWORD_SET(date) THEN BEGIN
        mydate = my_str_date(DATE=date[*])
        mdate  = mydate.DATE[*]    ; -('YYYYMMDD')
        zdate  = mydate.TDATE[*]   ; -['YYYY-MM-DD']
        newtimes = zdate+'/'+tcs
        goodtime = my_time_string(newtimes,STR=1,FORM=1,PREC=prec)
        RETURN,goodtime
      ENDIF ELSE BEGIN
        GOTO,JUMP_END
      ENDELSE
    END
    3 : BEGIN
      ;-----------------------------------------------------------------------------------
      ; => Entered data in form of epoch time
      ;-----------------------------------------------------------------------------------
      IF (nty GT 3L AND nty LT 6L) THEN BEGIN
        epoc  = rt2
        unxt  = epoch2unix(rt2)  ; -convert to unix time
        temp  = unxt
        tstr  = time_struct(temp)
        ms    = STRMID(STRTRIM(STRING(FORMAT='(d10.'+prcstr[0]+')',tstr.FSEC),2),2)
        ss    = STRING(FORMAT='(I2.2)',STRTRIM(tstr.SEC,2))
        mm    = STRING(FORMAT='(I2.2)',STRTRIM(tstr.MIN,2))
        hh    = STRING(FORMAT='(I2.2)',STRTRIM(tstr.HOUR,2))
        yr0   = STRING(FORMAT='(I4.4)',STRTRIM(tstr.YEAR,2))
        mnth0 = STRING(FORMAT='(I2.2)',STRTRIM(tstr.MONTH,2))
        days0 = STRING(FORMAT='(I2.2)',STRTRIM(tstr.DATE,2))
        sod   = tstr.SOD
        epoc  = unix2epoch(rt2)
        tcs   = hh+':'+mm+':'+ss+'.'+ms
        tns   = hh+mm+ss+'.'+ms
        ymd   = yr0+'-'+mnth0+'-'+days0+'/'+tcs
        GOTO,JUMP_END
      ENDIF ELSE BEGIN
        print,"Improper data input: = wrong format type"
        RETURN,dum
      ENDELSE
    END
  ENDCASE
  ;*****************************************************************************************
  ;*****************************************************************************************
ENDIF ELSE BEGIN  ; -Assumes you want an epoch time from you input date
  print,"No specification of data type...cannnot convert data..."
  RETURN,dum
ENDELSE
;-----------------------------------------------------------------------------------------
; -If only_str = 1 => determine which one is to be returned
;-----------------------------------------------------------------------------------------
JUMP_END:
;-----------------------------------------------------------------------------------------
t_str = CREATE_STRUCT('TIME_C',tcs,'TIME_N',tns,'HOUR',hh,'MINUTE',mm,'SECOND',ss,$
                      'MSec',ms,'SOD',sod,'UNIX',unxt,'EPOCH',epoc,'DATE_TIME',ymd)
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
IF NOT KEYWORD_SET(nom) THEN BEGIN
  MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
ENDIF
;*****************************************************************************************
CASE gchk2[0] OF
  0    : BEGIN
    RETURN,sod
  END
  1    : BEGIN
    RETURN,unxt
  END
  2    : BEGIN
    RETURN,epoc
  END
  3    : BEGIN
    RETURN,ymd
  END
  ELSE : BEGIN
    RETURN,t_str
  END
ENDCASE
END