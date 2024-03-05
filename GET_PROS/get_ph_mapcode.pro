;+
;*****************************************************************************************
;
;  FUNCTION :   get_ph_mapcode.pro
;  PURPOSE  :   Program returns the current mapcode for PESA High relevant to the
;                 date defined by the input time T.  There are two files in the
;                 Windlib libraries referencing these codes:  map3d.c and map3d.h
;
;  CALLED BY:   
;               get_ph.pro
;
;  INCLUDES:
;               NA
;
;  COMMON:
;               wind_com.pro
;
;  CALLS:
;               str_to_time.pro
;
;  REQUIRES:    
;               1)  External Windlib shared object libraries
;                     [e.g., ~/WIND_PRO/wind3dp_lib_darwin_x86_64.so]
;               2)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               T        :  Scalar (or [2]-Element array of) [double] Unix time(s)
;                             defining start (and stop) time(s) of interest.  If input
;                             is a [2]-element array, then all the data structures
;                             between T[0] and T[1] will be summed together into one
;                             IDL structure on output.  The summing is performed in units
;                             of counts and the DT and INTEG_T values change accordingly.
;
;  EXAMPLES:    
;               [calling sequence]
;               mapph = get_ph_mapcode(t [,/ADVANCE] [,INDEX=idx] [,OPTIONS=options] [,/PRESET])
;
;               ;;  Example
;               map0 = get_ph_mapcode(index=0)
;               map1 = get_ph_mapcode(str_to_time('1995-09-28/20'))
;               PRINT,'Map0: ',map0,',    Map1: ',map1,FORMAT='(a,z,a,z)'
;               Map0:     D4A4,    Map1:     D4FE
;               ;;  --> on 1995-09-28 the telemetry rate changed from S2x to S1x
;
;  KEYWORDS:    
;               ADVANCE  :  If set, program gets the next distribution relative to the
;                             previously retrieved distribution
;                             [Default = FALSE]
;               INDEX    :  Scalar [integer] telling program to select data by sample
;                             index instead of Unix time
;               OPTIONS  :  Options [numeric] array that decides how the packet is chosen:
;                             options[1] GE  0  =>  get packet by index
;                             options[1] EQ -1  =>  get packet by time
;               PRESET   :  If set, T, ADVANCE, OPTIONS, and INDEX are predefined so that
;                             no changes will be made to these variables within the
;                             routine
;                             [Default = FALSE]
;
;   CHANGED:  1)  Frank notes:  the telemetry rate changed from S2x to S1x
;                                                                   [09/28/1995   v1.0.?]
;             2)  Fixed up man page, program, and other minor changes 
;                                                                   [02/18/2011   v1.1.0]
;             3)  Fixed up a bit more
;                                                                   [02/28/2024   v1.1.1]
;
;   NOTES:      
;               1)  The procedure "load_3dp_data" must be called prior to use
;               2)  See:  http://sprg.ssl.berkeley.edu/wind3dp/wi_3dp_log
;               3)  From the 3DP Wind_lib source code:
;                     Currently only two possible outputs
;                       1: MAP11b, or 2: MAP11d  (constants defined in map3d.h)
;                     See also:  map3d.c and map3d.h
;               4)  See ~/WIND_PRO/wind_3dp_log.txt for instrument changes vs time
;
;  REFERENCES:  
;               0)  Lin et al., "A Three-Dimensional Plasma and Energetic particle
;                      investigation for the Wind spacecraft," Space Sci. Rev.
;                      71, pp. 125--153, 1995.
;               1)  Meeks, C., and P.B. Siegel "Dead time correction via the time
;                      series," Amer. J. Phys. 76, pp. 589--590, doi:10.1119/1.2870432,
;                      2008.
;               2)  M. Wüest, D.S. Evans, and R. von Steiger "Calibration of Particle
;                      Instruments in Space Physics," ESA Publications Division,
;                      Keplerlaan 1, 2200 AG Noordwijk, The Netherlands, 2007.
;               3)  M. Wüest, et al., "Review of Instruments," ISSI Sci. Rep. Ser.
;                      Vol. 7, pp. 11--116, 2007.
;               4)  Wilson III, L.B., et al., "A Quarter Century of Wind Spacecraft
;                      Discoveries," Rev. Geophys. 59(2), pp. e2020RG000714,
;                      doi:10.1029/2020RG000714, 2021.
;
;   CREATED:  ??/??/????
;   CREATED BY:  Frank Marcoline
;    LAST MODIFIED:  02/28/2024   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_ph_mapcode,t,ADVANCE=adv,INDEX=idx,OPTIONS=options,PRESET=preset

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Load common blocks
;;----------------------------------------------------------------------------------------
@wind_com.pro
;;----------------------------------------------------------------------------------------
;;  Get mapcode hex value(s)
;;----------------------------------------------------------------------------------------
;;  Make sure .so was called to load data
IF (N_ELEMENTS(refdate) EQ 0 OR N_ELEMENTS(wind_lib) EQ 0) THEN BEGIN
  MESSAGE,'You must first load 3DP data by calling load_3dp_data.pro',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check if user wants routine to define T, ADVANCE, and INDEX
;;----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(preset) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  User wants routine to define T, ADVANCE, OPTIONS, and INDEX
  ;;--------------------------------------------------------------------------------------
  IF (N_ELEMENTS(options) LT 3) THEN options = [2,0,0]
  IF (N_ELEMENTS(t) EQ 0) THEN t = str_to_time(refdate)
  time           = DBLARR(4)
  time[0]        = t[0]
  IF NOT KEYWORD_SET(adv) THEN adv = 0
  ;;  Determine if input T should be reset to original value upon return
  IF (adv[0] NE 0 AND N_ELEMENTS(t) EQ 1) THEN reset_time = 1 ELSE reset_time = 0
  IF (N_ELEMENTS(idx) GT 0) THEN options[1] = LONG(idx[0]) ELSE options[1] = -1L
  IF (N_ELEMENTS(t) GT 1)   THEN time2      = t[1] - t[0] + time[0] ELSE time2 = t[0]
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Assume T, ADVANCE, OPTIONS, and INDEX are all set properly
  ;;--------------------------------------------------------------------------------------
  time           = t
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Get mapcode
;;----------------------------------------------------------------------------------------
;;  Initialize dummy variables that will change upon return from get_ph_mapcode_idl.c
options        = LONG(options)
mapcode        = 0L
idtype         = 0
instseq        = 0
ok             = CALL_EXTERNAL(wind_lib,'get_ph_mapcode_idl',options,time,adv,mapcode,$
                                        idtype,instseq)
;;  First check if T should be reset
IF NOT KEYWORD_SET(preset) THEN IF (reset_time[0]) THEN t = time[0]
;;  See if a mapcode was successfully found
IF (ok[0] EQ 0) THEN BEGIN 
  MESSAGE,'get_ph_mapcode:  failed to get packet type',/INFORMATIONAL,/CONTINUE
  mapcode        = 0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,mapcode
END



;    IF NOT KEYWORD_SET(options) THEN options = [2,0,0]

