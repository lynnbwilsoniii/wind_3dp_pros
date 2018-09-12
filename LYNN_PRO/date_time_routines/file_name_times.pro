;+
;*****************************************************************************************
;
;  FUNCTION :   file_name_times.pro
;  PURPOSE  :   Returns strings of UT time stamps in a format that is suitable for
;                 file saving.  For example, if you wanted to save a data plot
;                 that showed data for 1995-01-01/10:00:00.101 UT, the program
;                 would produce a string of the form:
;                 '1995-01-01_1000x00.101'
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               time_string.pro
;               time_double.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TT      :  [N]-Element array of UTC [string] or Unix [double] times
;
;  EXAMPLES:    
;               [calling sequence]
;               test = file_name_times(tt [,PREC=prec] [,FORMFN=formfn])
;
;               ;;  Example usage
;               tnrt = '1998-09-24/21:40:00'
;               PRINT, file_name_times(tnrt[0],PREC=5)
;               { 1998-09-24_214000.00000
;               1998-09-24/21:40:00.00000
;                  9.0667320e+08
;               21:40:00.00000
;               1998-09-24
;               }
;
;  KEYWORDS:    
;               PREC    :  Scalar [numeric] defining the number of decimal places to use
;                            for the fractional seconds
;                            [Default = 3]
;               FORMFN  :  Scalar [integer] defining the output form of the F_TIME tag
;                            Example:  For PREC = 3 and the following SCET:
;                                      '2000-04-10/15:10:33.013'
;                            1 = '2000-04-10_1510x33.013'  [Default]
;                            2 = '2000-04-10_1510-33x013'
;                            3 = '20000410_1510-33x013'
;
;   CHANGED:  1)  Fixed typo in FTIME calculation
;                                                                   [10/25/2010   v1.0.1]
;             2)  Added keyword:  FORMFN
;                                                                   [03/02/2011   v1.1.0]
;             3)  Added extra possible output for FORMFN keyword
;                                                                   [07/26/2011   v1.1.1]
;             4)  No longer calls my_time_string.pro, now calls time_string.pro
;                   and time_double.pro
;                                                                   [04/10/2012   v1.2.0]
;             5)  Cleaned up and updated Man. page and now calls is_a_number.pro
;                                                                   [09/04/2018   v1.2.1]
;             6)  Fixed a logic bug in the error handling
;                                                                   [09/05/2018   v1.2.2]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  10/13/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/05/2018   v1.2.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION file_name_times,tt,PREC=prec,FORMFN=formfn

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define default structure format
tags           = ['F_TIME','UT_TIME','UNIX','TIME','DATE']
ddate          = STRARR(10L)        ;;  'YYYY-MM-DD'
dtime          = STRARR(10L)        ;;  'HH:MM:SS.sss[prec]'
dunix          = DBLARR(10L)        ;;  Unix time
duttime        = STRARR(10L)        ;;  'YYYY-MM-DD/HH:MM:SS.sss[prec]'
dftime         = STRARR(10L)        ;;  'YYYY-MM-DD_HHMMxSS.sss[prec]'
dummy          = CREATE_STRUCT(tags,dftime,duttime,dunix,dtime,ddate)
;;  Dummy error messages
no_inpt_msg    = 'User must supply an array of time stamps...'
badin          = 'Incorrect input format for TT'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 1) OR ((SIZE(tt,/TYPE) NE 7) AND $
                 (is_a_number(tt,/NOMSSG) EQ 0))
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check PREC
IF (is_a_number(prec,/NOMSSG)   EQ 0) THEN ndec = 3 ELSE ndec = LONG(prec[0])
;;  Check FORMFN
IF (is_a_number(formfn,/NOMSSG) EQ 0) THEN ffn = 1 ELSE ffn = FIX(formfn[0]) > 1
;;----------------------------------------------------------------------------------------
;;  Determine input type
;;----------------------------------------------------------------------------------------
t_time         = REFORM(tt,N_ELEMENTS(tt))  ;;  Force 1D format
t_type         = SIZE(t_time,/TYPE)
CASE t_type[0] OF
  7L   :  BEGIN
    ;;  Input of form:  'YYYY-MM-DD/HH:MM:SS[.ssss]'
    ymdb = time_string(t_time,PREC=ndec[0])
  END
  5L   :  BEGIN
    ;;  Input must be in Unix time
    ymdb = time_string(t_time,PREC=ndec[0])
  END
  ELSE :  BEGIN
    ;;  Unrecognized time stamp type format
    MESSAGE,badin[0],/CONTINUE,/INFORMATIONAL
    RETURN,dummy
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Assume everything went okay up to here
;;----------------------------------------------------------------------------------------
;;  Initialize variables
cdate          = ''                      ;;  'YYYYMMDD'
ftim1          = ''                      ;;  'YYYY-MM-DD_HHMMxSS.sss[prec]'
ftim2          = ''                      ;;  'YYYY-MM-DD_HHMM-SSxsss[prec]'
ftim3          = ''                      ;;  'YYYYMMDD_HHMM-SSxsss[prec]'
;;  Define Unix times
unix           = time_double(ymdb)
;;  Parse the UTC string version of the time stamp
time           = STRMID(ymdb[*],11L)     ;;  'HH:MM:SS.sss[prec]'
date           = STRMID(ymdb[*],0L,10L)  ;;  'YYYY-MM-DD'
cdate          = STRMID(date[*],0L,4L)+STRMID(date[*],5L,2L)+STRMID(date[*],8L,2L)
;;  Define the three formats for output
ftim1          = date[*]+'_'+STRMID(time[*],0L,2L)+STRMID(time[*],3L,2L)+'x'+STRMID(time[*],6L)
ftim2          = date[*]+'_'+STRMID(time[*],0L,2L)+STRMID(time[*],3L,2L)+'-'+$
                 STRMID(time[*],6L,2L)+'x'+STRMID(time[*],9L)
ftim3          = cdate[*]+'_'+STRMID(time[*],0L,2L)+STRMID(time[*],3L,2L)+'-'+$
                 STRMID(time[*],6L,2L)+'x'+STRMID(time[*],9L)
;;  Define output format
form1 = ffn[0] EQ 1
form2 = ffn[0] EQ 2
form3 = ffn[0] EQ 3
check = WHERE([form1[0],form2[0],form3[0]])
CASE check[0] OF
  0    : ftime = ftim1                    ;;  Form 1:  'YYYY-MM-DD_HHMMxSS.sss[prec]'
  1    : ftime = ftim2                    ;;  Form 2:  'YYYY-MM-DD_HHMM-SSxsss[prec]'
  2    : ftime = ftim3                    ;;  Form 3:  'YYYYMMDD_HHMM-SSxsss[prec]'
  ELSE : ftime = ftim1                    ;;  [Default] Form 1:  'YYYY-MM-DD_HHMMxSS.sss[prec]'
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Define output structure
;;----------------------------------------------------------------------------------------
tags           = ['F_TIME','UT_TIME','UNIX','TIME','DATE']
dummy          = CREATE_STRUCT(tags,ftime,ymdb,unix,time,date)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,dummy
END