;+
;*****************************************************************************************
;
;  PROCEDURE:   beam_fit_print_index_time.pro
;  PURPOSE  :   Prints to screen the available particle velocity distribution functions
;                 and associated dates/times.
;
;  CALLED BY:   
;               wrapper_beam_fit_array.pro
;
;  CALLS:
;               time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               STIME  :  [N]-Element array [double] of start times [Unix] associated
;                           with an [N]-element array of data structures containing
;                           particle velocity distribution functions (DFs) from either
;                           the Wind/3DP or THEMIS ESA instruments.
;               ETIME  :  [N]-Element array [double] of end times [Unix] corresponding
;                           to STIME
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  time_string.pro can handle string input (result returned by
;                     time_string.pro) or structure inputs (result returned by
;                     time_struct.pro)
;               2)  See also:  time_string.pro, time_struct.pro, or time_double.pro
;
;   CREATED:  08/27/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/27/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO beam_fit_print_index_time,stime,etime

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Format output
mform          = '("  ",a10,"    ",a12,"    ",a12,"        ",I5.5)'
head           = '     Date        Start Time       End Time          Index  '
line           = '==========================================================='
;; => Dummy error messages
badinp_msg     = 'Both inputs must be [N]-Element arrays of Unix times...'
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
stest          = (SIZE(stime,/TYPE) LT 4L) OR (SIZE(stime,/TYPE) GT 5L)
etest          = (SIZE(etime,/TYPE) LT 4L) OR (SIZE(etime,/TYPE) GT 5L)
ttest          = (N_ELEMENTS(stime) NE N_ELEMENTS(etime))
test           = (N_PARAMS() NE 2) OR stest OR etest
IF (test) THEN BEGIN
  MESSAGE,badinp_msg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;; => Define dummy variables to avoid changing input
s_time         = REFORM(stime)
e_time         = REFORM(etime)
;;----------------------------------------------------------------------------------------
;; => Convert to Date/Time
;;----------------------------------------------------------------------------------------
ymdbs          = time_string(s_time,PREC=3L)     ;; e.g.  '2000-10-03/00:01:11.598'
ymdbe          = time_string(e_time,PREC=3L)     ;; e.g.  '2000-10-03/00:01:11.598'
tdates         = STRMID(ymdbs[*],0L,10L)         ;; e.g.  '2000-10-03'
s_t            = STRMID(ymdbs[*],11L)            ;; e.g.  '00:01:11.598'
e_t            = STRMID(ymdbe[*],11L)

nt             = N_ELEMENTS(ymdbs)
index          = LINDGEN(nt)
;;----------------------------------------------------------------------------------------
;; => Print result to screen
;;----------------------------------------------------------------------------------------
PRINT,''
PRINT,head[0]
PRINT,line[0]
FOR j=0L, nt - 1L DO PRINT,tdates[j],s_t[j],e_t[j],index[j],FORMAT=mform
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END