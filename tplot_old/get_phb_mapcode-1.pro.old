;+
;*****************************************************************************************
;
;  FUNCTION :   get_phb_mapcode.pro
;  PURPOSE  :   Program returns the current mapcode for Pesa High relevant to the
;                 date defined by the input time T.  There are two files in the
;                 Windlib libraries referencing these codes:  map3d.c and map3d.h
;
;  CALLED BY:   
;               get_phb.pro
;
;  CALLS:
;               wind_com.pro
;               str_to_time.pro
;
;  REQUIRES:    
;               1)  External Windlib libraries
;
;  INPUT:
;               T        :  Scalar or 2-Element Unix time telling the program what the
;                             start or start and stop times of interest are
;
;  EXAMPLES:    
;               map0 = get_phb_mapcode(index=0)
;               map1 = get_phb_mapcode(str_to_time('1995-09-28/20'))
;               print,'Map0: ',map0,',    Map1: ',map1,format='(a,z,a,z)'
;               -->  Map0:     D4A4,    Map1:     D4FE
;
;  KEYWORDS:    
;               ADVANCE  :  If set, program gets the next distribution
;               INDEX    :  Scalar integer telling program to select data by sample
;                             index instead of times
;               OPTIONS  :  Options array that decides how the packet is chosen:
;                             options[1] GE  0 => get packet by index
;                             options[1] EQ -1 => get packet by time
;               PRESET   :  If set, T, ADVANCE, and INDEX are preset so that no
;                             changes will be made to these variables
;
;   CHANGED:  1)  Frank Marcoline notes:  the telemetry rate changed from S2x to S1x
;                                                                  [09/28/1995   v1.0.?]
;             2)  Fixed up man page, program, and other minor changes 
;                                                                  [02/18/2011   v1.1.0]
;
;   NOTES:      
;               1)  The procedure "load_3dp_data" must be called prior to use
;               2)  See:  http://sprg.ssl.berkeley.edu/wind3dp/wi_3dp_log
;               3)  Currently only two possible outputs
;                     1: MAP11b, or 2: MAP11d  (constants defined in map3d.h)
;               4)  See also:  map3d.c and map3d.h
;
;   CREATED:  ??/??/????
;   CREATED BY:  Peter Schroeder
;    LAST MODIFIED:  02/18/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_phb_mapcode,t,ADVANCE=adv,INDEX=idx,OPTIONS=options,PRESET=preset

;-----------------------------------------------------------------------------------------
; => Load common blocks
;-----------------------------------------------------------------------------------------
@wind_com.pro

;-----------------------------------------------------------------------------------------
; => Check if data is loaded
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(refdate) EQ 0) THEN BEGIN
  MESSAGE,'You must first load the data',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF

IF NOT KEYWORD_SET(preset) THEN BEGIN 
    IF NOT KEYWORD_SET(options) THEN options = [15,0,0]
    IF (N_ELEMENTS(t) EQ 0) THEN t = str_to_time(refdate)
    time    = DBLARR(4)
    time[0] = t[0]
    IF NOT KEYWORD_SET(adv) THEN adv = 0 
    IF (adv NE 0 AND N_ELEMENTS(t) EQ 1) THEN reset_time = 1 ELSE reset_time = 0
    IF (N_ELEMENTS(idx) GT 0) THEN options[1] = LONG(idx) ELSE options[1] = -1L
    IF (N_ELEMENTS(t) GT 1)   THEN time2      = t[1] - t[0] + time[0] ELSE time2 = t
ENDIF ELSE time = t                ;assume options,t,idx,and adv are set properly

options = LONG(options)
mapcode = 0L
idtype  = 0
instseq = 0
ok      = CALL_EXTERNAL(wind_lib,'get_phb_mapcode_idl',options,time,adv,mapcode,$
                        idtype,instseq)
IF NOT KEYWORD_SET(preset) THEN IF reset_time THEN t = time[0]
  
IF (ok EQ 0) THEN BEGIN 
  PRINT,'get_phb_mapcode:  failed to get packet type'
  RETURN,0
ENDIF ELSE BEGIN
  RETURN,mapcode
ENDELSE

END 
