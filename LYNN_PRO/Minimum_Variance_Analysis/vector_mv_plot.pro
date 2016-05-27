;+
;*****************************************************************************************
;
;  FUNCTION :   list_read_options.pro
;  PURPOSE  :   Prints to screen all the optional values allowed for user input
;                 and their purpose.
;
;  CALLED BY:   
;               vector_mv_plot.pro
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
;               list_read_options
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added a new option                               [09/26/2011   v1.1.0]
;
;   NOTES:      
;               1)  This should NOT be called by user
;
;   CREATED:  03/04/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/26/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO list_read_options

PRINT,""
PRINT,"++++++++++++++++++++++++++++++++++++++++"
PRINT,"-------- PLOT_MVTDS COMMANDS -----------"
PRINT,"ps       output PostScript plot"
PRINT,"z        change plot range       (format = automated zoom)"
PRINT,"tr       change plot range       (format = 'HH:MM:SS.ssss')"
PRINT,"left     change start plot range (format = 'HH:MM:SS.ssss')"
PRINT,"right    change end plot range   (format = 'HH:MM:SS.ssss')"
PRINT,"last_tr  return to previous plot range"
PRINT,"thick    change thickness of lines [keyword for PLOT]"
PRINT,"s        slow hodogram plot"
PRINT,"sc       re-scale vector field"
PRINT,"log      change lin/log frequency scale for FFT plots"
PRINT,"freq     change the frequency scale in FFT plots"
PRINT,"q        quit [Enter at any time to leave program]"
PRINT,"----------------------------------------"
PRINT,"++++++++++++++++++++++++++++++++++++++++"
PRINT,""

RETURN
END


;+
;*****************************************************************************************
;
;  FUNCTION :   plot_mv_freq_ticks.pro
;  PURPOSE  :   This routine allows the user to dynamically change the frequency axis
;                 range of the FFT plots.
;
;  CALLED BY:   
;               vector_mv_plot.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NYQST   :  Scalar defining the Nyquist frequency [Hz] of the input
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               FREQRA  :  [2]-Element array specifying the current frequency range
;                            which will be replaced with new frequency range
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  This should NOT be called by user
;
;   CREATED:  09/26/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/26/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION plot_mv_freq_ticks,nyqst,FREQRA=freqra

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f                = !VALUES.F_NAN
d                = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => change frequency range plotted  (format = 0.0 [Hz])
;-----------------------------------------------------------------------------------------
srate0 = nyqst[0]*2d0
sr_str = STRTRIM(STRING(srate0[0],FORMAT='(f15.1)'),2)
PRINT,''
PRINT,'The current sample rate is set at '+sr_str[0]+' Hz'
PRINT,''
PRINT,''
PRINT,'Do you wish to change the X-Axis range of the FFT spectrogram?'
PRINT,''
read_frange = ''
check       = 0
fr_low      = 0.
fr_hig      = 0.
WHILE (read_frange NE '0' AND read_frange NE '1') DO BEGIN
  READ,read_frange,PROMPT="Type 0 for default Freq. range, 1 to change Freq. range: "
  CASE read_frange[0] OF
    '0'  : BEGIN
      ; => Default settings
      check  = 0
      freqra = freqra
    END
    '1'  : BEGIN
      ; => user wishes to change settings
      check  = 1
    END
  ENDCASE
ENDWHILE
;-----------------------------------------------------------------------------------------
; => Prompt user for input
;-----------------------------------------------------------------------------------------
WHILE (check) DO BEGIN
  READ,fr_low,PROMPT="Enter the lowest frequency (Hz) value to plot:  "
  READ,fr_hig,PROMPT="Enter the highest frequency (Hz) value to plot:  "
  check = (fr_low[0] GT fr_hig[0]) OR (fr_low[0] EQ fr_hig[0]) OR $
          ((fr_low[0] GE srate0[0]) OR (fr_hig[0] GE srate0[0])) OR $
          ((fr_low[0] LT 0.) OR (fr_hig[0] LE 0.))
  IF (check) THEN BEGIN
    PRINT,'Bad input frequency range...'
    PRINT,'(flow < fhigh) AND ((flow AND fhigh) < sample rate)'
    PRINT,'Try Again!'
  ENDIF ELSE BEGIN
    freqra = [fr_low[0],fr_hig[0]]
  ENDELSE
ENDWHILE

RETURN,1
END


;+
;*****************************************************************************************
;
;  FUNCTION :   change_tr_lrtr.pro
;  PURPOSE  :   Determines the new elements to use depending upon the different
;                 time range/scaling desired by user.
;
;  CALLED BY:   
;               vector_mv_plot.pro
;
;  CALLS:
;               my_time_string.pro
;               time_double.pro
;               change_tr_lrtr.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               SS0    :  Scalar defining the current start element
;               EE0    :  Scalar defining the current end   element
;               UNIX   :  N-Element array of Unix times
;
;  EXAMPLES:    
;               s0   = 0L
;               e0   = N_ELEMENTS(tx) - 1L
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               ; => Change the end element
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               rels = change_tr_lrtr(s0,e0,tx,LEFT=0,RIGHT=1,TR=0,ZOOMT=0)
;               s1   = rels[0]
;               e1   = rels[1]
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               ; => Change the start element
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               lels = change_tr_lrtr(s0,e0,tx,LEFT=1,RIGHT=0,TR=0,ZOOMT=0)
;               s1   = lels[0]
;               e1   = lels[1]
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               ; => Change the both the start and end elements
;               ;++++++++++++++++++++++++++++++++++++++++++++++
;               bels = change_tr_lrtr(s0,e0,tx,LEFT=0,RIGHT=0,TR=1,ZOOMT=0)
;               s1   = bels[0]
;               e1   = bels[1]
;
;  KEYWORDS:    
;               LEFT     :  If set, program will adjust the start elment
;                             from user a defined start time
;               RIGHT    :  If set, program will adjust the end   element
;                             from user a defined end time
;               TR       :  If set, program will adjust the both start and end elements
;                             from user defined start and end times
;               ZOOMT    :  If set, program will adjust the time range by zooming by
;                             a power of 4, 8, or 10 [user selects]
;               FROM_TR  :  Specifically used internally by routine to prevent infinite
;                             loop from occurring when using TR keyword that results when
;                             new window start time exceeds old window end time
;
;   CHANGED:  1)  Fixed a bug that occurred when changing time ranges and
;                   added keyword:  FROM_TR                        [03/04/2011   v1.0.0]
;             2)  Fixed a bug that occurred when more than one day is loaded
;                                                                  [01/28/2012   v1.0.1]
;
;   NOTES:      
;               1)  This should NOT be called by user
;
;   CREATED:  03/04/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/28/2012   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION change_tr_lrtr,ss0,ee0,unix,LEFT=left,RIGHT=right,TR=tr,$
                        ZOOMT=zoomt,FROM_TR=from_tr

;-----------------------------------------------------------------------------------------
; => Define default error messages
;-----------------------------------------------------------------------------------------
bad_dstr   = 'On which day is this time time?'
bad_dstr2  = 'I see that you misunderstood.  ONLY a 1 or 2 are acceptable.'

ent_stmssg = "Enter start time ('HH:MM:SS.ssss'): "
ent_enmssg = "Enter end time ('HH:MM:SS.ssss'): "
;-----------------------------------------------------------------------------------------
; => Define dummy variables and check input
;-----------------------------------------------------------------------------------------

bad_drd    = ''
dumbs      = ['left','right','tr','z']
read_pause = ''
start_t    = 0d0          ; => Unix time of start time
end_t      = 0d0          ; => Unix time of end   time
start_s    = ''           ; => 'HH:MM:SS.ssss' for start time
end_s      = ''           ; => 'HH:MM:SS.ssss' for end   time
; => Check keywords
IF KEYWORD_SET(left)    THEN lft = 1 ELSE lft = 0
IF KEYWORD_SET(right)   THEN rht = 1 ELSE rht = 0
IF KEYWORD_SET(tr)      THEN tra = 1 ELSE tra = 0
IF KEYWORD_SET(zoomt)   THEN zmt = 1 ELSE zmt = 0
IF KEYWORD_SET(from_tr) THEN frt = 1 ELSE frt = 0

;-----------------------------------------------------------------------------------------
; => Define some relevant parameters common to each time range calculation
;-----------------------------------------------------------------------------------------
tx         = REFORM(unix)
npts       = N_ELEMENTS(tx)          ; => total # of points available
s0         = ss0[0]
e0         = ee0[0]
num0pts    = (s0 - e0) + 1L          ; => Current number of points in use
even0      = (num0pts MOD 2) EQ 0    ; => 1 = even # of points, ELSE = odd #
; => Shift # of points to an even number if necessary
IF (even0) THEN num0pts = num0pts ELSE num0pts -= 1L

mts        = my_time_string([tx[s0[0]],tx[e0[0]]],UNIX=1,PREC=4,/NOM)
tr_unix    = mts.UNIX                ; => Current unix time range
tr_scet    = mts.DATE_TIME           ; => 'YYYY-MM-DD/HH:MM:SS.ssss'
zdates     = STRMID(tr_scet[*],0L,10L)
; => Check to see if times are straddling a day change
bad_day    = zdates[0] NE zdates[1]

;-----------------------------------------------------------------------------------------
; => Determine which type of time range to use
;-----------------------------------------------------------------------------------------
good       = WHERE([lft,rht,tra,zmt],gd)
read_pause = STRLOWCASE(STRTRIM(dumbs[good[0]],2))

; => Define new elements
CASE read_pause[0] OF
  'left'  : BEGIN
    ;=====================================================================================
    JUMP_LZOOM:
    ;=====================================================================================
    s1      = 0L
    ; => Set e1 = e0 which will mean that ONLY s1 will increment later on...
    e1      = e0[0]
    end_t   = tx[e0[0]]
    PRINT,"Please enter a start time ('HH:MM:SS.ssss') for the data"
    PRINT," range you wish to re-plot."
    WHILE (start_s EQ '') DO BEGIN
      READ,start_s,PROMPT=ent_stmssg[0]
      ;++++++++++++++++++++++++++++++++++
      IF (start_s EQ 'q') THEN RETURN,'q'
      ;++++++++++++++++++++++++++++++++++
    ENDWHILE
    ; => Check to see if times straddling a day change
    IF (bad_day) THEN BEGIN
      PRINT,bad_dstr
      PRINT,'Enter 1 for '+zdates[0]+'and a 2 for '+zdates[1]
      WHILE (bad_day) DO BEGIN
        READ,bad_drd,PROMPT='Enter 1 or 2: '
        ;++++++++++++++++++++++++++++++++++
        IF (bad_drd EQ 'q') THEN RETURN,'q'
        ;++++++++++++++++++++++++++++++++++
        goodday = (LONG(bad_drd) EQ 1L) OR (LONG(bad_drd) EQ 2L)
        bad_day = (goodday EQ 0)
;        bad_day = (LONG(bad_drd) NE 1L) OR (LONG(bad_drd) NE 2L)
        IF (bad_day) THEN PRINT,bad_dstr2
      ENDWHILE
      bdel = LONG(bad_drd)
    ENDIF ELSE bdel = 0L
    start_s = zdates[bdel[0]]+'/'+start_s[0]  ; => 'YYYY-MM-DD/HH:MM:SS.ssss'
    start_t = time_double(start_s[0])         ; => Convert to Unix time
    IF (start_t[0] GE end_t[0] AND frt EQ 0) THEN BEGIN
      MESSAGE,'Start time greater than end time...trying again!',/INFORMATIONAL,/CONTINUE
      start_s = ''     ; => Reset so program does not go into infinite loop
      GOTO,JUMP_LZOOM
    ENDIF
;    WHILE (tx[s1] LT start_t[0] AND s1 LT npts - 1L) DO s1 += 1L
  END
  'right' : BEGIN
    ;=====================================================================================
    JUMP_RZOOM:
    ;=====================================================================================
    start_t = tx[s0[0]]
    e1      = npts - 1L
    ; => Set s1 = s0 which will mean that ONLY e1 will increment later on...
    s1      = s0[0]
    PRINT,"Please enter an end time ('HH:MM:SS.ssss') for the data"
    PRINT," range you wish to re-plot."
    WHILE (end_s EQ '') DO BEGIN
      READ,end_s,PROMPT=ent_enmssg[0]
      ;++++++++++++++++++++++++++++++++++
      IF (end_s EQ 'q') THEN RETURN,'q'
      ;++++++++++++++++++++++++++++++++++
    ENDWHILE
    ; => Check to see if times straddling a day change
    IF (bad_day) THEN BEGIN
      PRINT,bad_dstr
      PRINT,'Enter 1 for '+zdates[0]+'and a 2 for '+zdates[1]
      WHILE (bad_day) DO BEGIN
        READ,bad_drd,PROMPT='Enter 1 or 2: '
        ;++++++++++++++++++++++++++++++++++
        IF (bad_drd EQ 'q') THEN RETURN,'q'
        ;++++++++++++++++++++++++++++++++++
        goodday = (LONG(bad_drd) EQ 1L) OR (LONG(bad_drd) EQ 2L)
        bad_day = (goodday EQ 0)
;        bad_day = (LONG(bad_drd) NE 1L) OR (LONG(bad_drd) NE 2L)
        IF (bad_day) THEN PRINT,bad_dstr2
      ENDWHILE
      bdel = LONG(bad_drd)
    ENDIF ELSE bdel = 0L
    end_s   = zdates[bdel[0]]+'/'+end_s[0]    ; => 'YYYY-MM-DD/HH:MM:SS.ssss'
    end_t   = time_double(end_s[0])           ; => Convert to Unix time
    IF (end_t[0] LE start_t[0]) THEN BEGIN
      MESSAGE,'End time less than start time...trying again!',/INFORMATIONAL,/CONTINUE
      end_s = ''     ; => Reset so program does not go into infinite loop
      GOTO,JUMP_RZOOM
    ENDIF
;    WHILE (tx[e1] GT end_t[0] AND e1 GT 0L) DO e1 -= 1L
  END
  'tr'    : BEGIN
    s1      = s0[0]
    e1      = e0[0]
    lels    = change_tr_lrtr(s1,e1,tx,LEFT=1,RIGHT=0,TR=0,ZOOMT=0,FROM_TR=1)
    ;++++++++++++++++++++++++++++++++++++++++++++
    IF (SIZE(lels[0],/TYPE) EQ 7) THEN RETURN,'q'
    ;++++++++++++++++++++++++++++++++++++++++++++
    s1      = lels[0]
    rels    = change_tr_lrtr(s1,e1,tx,LEFT=0,RIGHT=1,TR=0,ZOOMT=0)
    ;++++++++++++++++++++++++++++++++++++++++++++
    IF (SIZE(rels[0],/TYPE) EQ 7) THEN RETURN,'q'
    ;++++++++++++++++++++++++++++++++++++++++++++
    e1      = rels[1]
    start_t = tx[s1[0]]
    end_t   = tx[e1[0]]
;    WHILE (tx[s1] LT start_t[0] AND s1 LT npts - 1L) DO s1 += 1L
;    WHILE (tx[e1] GT end_t[0]   AND e1 GT        0L) DO e1 -= 1L
  END
  'z'     : BEGIN
    start_t = tx[s0[0]]
    end_t   = tx[e0[0]]
    zmfac   = ''
    bad     = 1
    PRINT,'Please select a zoom factor by typing a 4, 8, or 10'
    WHILE (bad) DO BEGIN
      READ,zmfac,PROMPT="Enter zoom factor (integer): "
      bad = ( TOTAL(LONG(zmfac[0]) EQ [4L,8L,10L]) ) LE 0
      IF (bad) THEN PRINT,'Zoom factor must be equal to 4, 8, or 10'
    ENDWHILE
    rm_pts  = num0pts/zmfac[0]
    s1      = s0 + rm_pts
    e1      = e0 - rm_pts
;    WHILE (tx[s1] LT start_t[0] AND s1 LT npts - 1L) DO s1 += 1L
;    WHILE (tx[e1] GT end_t[0]   AND e1 GT        0L) DO e1 -= 1L
    IF (s1 GE e1) THEN BEGIN
      errmssg = 'Zoom led to start time >= end time => fail'
      MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
      RETURN,[s0,e0]
    ENDIF
  END
  ELSE    : BEGIN
    errmssg = 'Incorrect use of keywords => fail'
    MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
    RETURN,[s0,e0]
  END
ENDCASE

;-----------------------------------------------------------------------------------------
; => Increment indices if necessary
;-----------------------------------------------------------------------------------------
WHILE (tx[s1] LT start_t[0] AND s1 LT npts - 1L) DO s1 += 1L
WHILE (tx[e1] GT end_t[0]   AND e1 GT        0L) DO e1 -= 1L
;-----------------------------------------------------------------------------------------
; => Return new elements
;-----------------------------------------------------------------------------------------

RETURN,[s1,e1]
END


;+
;*****************************************************************************************
;
;  FUNCTION :   vector_mv_plot.pro
;  PURPOSE  :   Plots the High Time Resolution (HTR) magnetic field data from
;                 the Wind spacecraft in GSE and minimum variance coordinates.  The
;                 program will also output plots of the field-aligned and 
;                 perpendicular current density estimates if desired.
;
;  CALLS:  
;               my_str_date.pro
;               my_loadct2.pro
;               my_colors2.pro       ; => Common block
;               my_time_string.pro
;               tplot_struct_format_test.pro
;               my_min_var_rot.pro
;               plot_vector_mv_data.pro
;               list_read_options.pro
;               change_tr_lrtr.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:       
;               NA
;
;  EXAMPLES:
;               NA
;
;  KEYWORDS:  
;               DATE    :  Scalar string ('MMDDYY' [MM=month, DD=day, YY=year])
;               MYMAG   :  User defined [n,3]-element array of vector field data with
;                            associated Unix time as part of a structure with tags 
;                            X = time 
;                            Y = [N,3]-field.
;               FCUTOFF :  Set to a two element array specifying the range of 
;                            frequencies to use in power spectrum plots if data has
;                            been bandpass-filtered
;               SAT     :  Defines which spacecraft ('A', 'B', or 'W' to use)
;                              [Default = 'W' corresponding to Wind]
;               COORD   :  Defines which coordinate system to use for plot labels
;                            ['RTN' or 'GSE' or 'SC', Default = 'GSE']
;               FIELD   :  Set to a scalar string defining whether the input is a
;                            magnetic ('B') or electric ('E') field 
;                            [Default = 'B']
;               DCBKGF  :  Structure of format {X:Unix Times, Y:[N,3]-Element Vector}
;                            DCBKGF should contain the background/ambient vector field
;                            data that you wish to use as a reference direction (i.e.
;                            DC B-field) when comparing to the MV-direction
;               STATS   :  Set to a named variable to return the relevant information
;                            for each plot you save
;               SUFFX   :  Scalar string user defines which is appended onto the default
;                            PS file name if saved
;
;   CHANGED:  1)  Added keywords to return plot title information from
;                  my_plot_mv_htr_data.pro                        [09/11/2008   v1.0.1]
;             2)  Changed functionality of keywords in my_plot_mv_htr_data.pro
;                  and added htr_fa_maxwells_2.pro dependence if keyword
;                  CURR is set                                    [09/11/2008   v1.0.2]
;             3)  Changed functionality of in my_plot_mv_htr_data.pro 
;                                                                 [09/18/2008   v1.0.3]
;             4)  Changed functionality of in my_plot_mv_htr_data.pro 
;                  (Added keyword, EIGA)                          [09/18/2008   v1.0.4]
;             5)  Updated Man. Page                               [10/16/2008   v1.0.5]
;             6)  Updated Output                                  [10/26/2008   v1.0.6]
;             7)  Added Keyword: MYMAG                            [10/27/2008   v1.0.7]
;             8)  Fixed/Changed power spectrum calcs => Alters plots!
;                                                                 [11/20/2008   v1.1.0]
;             9)  Added Keyword: FCUTOFF                          [11/20/2008   v1.1.1]
;            10)  Added keyword: SAT                              [12/30/2008   v1.1.2]
;            10)  Added keyword: COORD                            [12/30/2008   v1.1.2]
;            11)  Updated times to be compatible with Unix times (changed other syntax)
;                                                                 [05/24/2009   v1.2.0]
;            12)  Changed some syntax [no functional changes]     [05/25/2009   v1.2.1]
;            13)  Added new JUMP point: JUMP_SAVE                 [06/03/2009   v1.3.0]
;            14)  Changed initial charsize when plotting          [07/16/2009   v1.3.1]
;            15)  Added keyword: FIELD                            [07/16/2009   v1.3.2]
;            16)  Changed program my_plot_mv_htr_data.pro to plot_vector_mv_data.pro
;                   and removed keyword:  CURR
;                   and renamed from htr_mv_plot.pro              [08/12/2009   v2.0.0]
;            17)  Fixed type with 'tr' option                     [09/22/2010   v2.1.0]
;            18)  Added keyword:  DCBKGF and changed output options for
;                   plot_vector_mv_data.pro                       [09/23/2010   v2.2.0]
;            19)  Fixed issue with color table                    [09/24/2010   v2.2.1]
;            20)  Added some error handling with time range options and added two new
;                   options which allow one to change the start/end time independently
;                   and added keyword:  STATS
;                                                                 [10/20/2010   v2.3.0]
;            21)  Fixed typo with keyword DCBKGF error handling   [11/12/2010   v2.3.1]
;            22)  Removed all dependencies on HTR MFI data programs
;                                                                 [11/16/2010   v2.4.0]
;            23)  Added new options and now calls change_tr_lrtr.pro 
;                   and list_read_options.pro [seen above]        [03/04/2011   v2.5.0]
;            24)  Fixed typo with option 'thick'                  [03/08/2011   v2.5.1]
;            25)  Fixed typo with options 'ps' and changed 'sc' so that scaling the
;                   B-field allows you to perform MVA after you remove DC offsets
;                   in the data                                   [03/10/2011   v2.5.2]
;            26)  Added keyword:  SUFFX                           [05/27/2011   v2.5.3]
;            27)  Fixed typo in screen size calculation           [07/25/2011   v2.5.4]
;            28)  Added option to dynamically change frequency range in FFT plots
;                   and now calls plot_mv_freq_ticks.pro
;                                                                 [09/26/2011   v2.6.0]
;            29)  Allow for other spacecraft in SAT keyword       [11/03/2011   v2.6.1]
;            30)  Fixed an issue in change_tr_lrtr.pro            [01/28/2012   v2.6.2]
;
;   NOTES:      
;               1)  MYMAG keyword must be set and used with the correct format.
;               2)  When using the SAT keyword, if you set to a different value use
;                     3 letters to define the spacecraft name
;
;   CREATED:  08/26/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/28/2012   v2.6.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


PRO vector_mv_plot,DATE=date,MYMAG=mymag,FCUTOFF=fcutoff,SAT=sat,    $
                   COORD=coord,FIELD=field,DCBKGF=dcbkgf,STATS=stats,$
                   SUFFX=suffx

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
ts             = DBLARR(10000)   ; -Time in seconds of day for HTR MFI data
tc             = STRARR(10000)   ; -Time ['HH:MM:SS.xxxx']
tx             = DBLARR(10000)   ; -Unix time
my_date        = ''              ; -Date ['YYYYMMDD']
tdate          = ''              ; -Date ['MMDDYY']
npoints        = 0L              ; -# of vectors being plotted
s              = 0L              ; -element of starting data point
e              = 0L              ; -" " ending " "
evlength       = 0d0             ; -Time duration of data currently used (s)
nsps           = 0d0             ; -Avg. sample rate of data (#/s)
bx             = DBLARR(10000)   ; -X-GSE B-field (nT)
by             = DBLARR(10000)   ; -Y-GSE B-field (nT)
bz             = DBLARR(10000)   ; -Z-GSE B-field (nT)
bmag           = DBLARR(10000)   ; -Magnitude of B-field (nT)
pscount        = 1               ; => Plot output number
pngcount       = 1
stop_slow_plot = ''              ; => 
read_win       = ''              ; => Logic:  For using windowing in FFTs
read_logpower  = ''              ; => Logic:  For using log-scaled frequency axes
read_bscale    = ''              ; => Logic:  For scaling vector field
;-----------------------------------------------------------------------------------------
;  ----DEFINE SOME USABLE COLORS----
;-----------------------------------------------------------------------------------------
DEVICE,GET_DECOMPOSED=decomp0
; => Keep track of original system vars
xyzp_win    = {X:!X,Y:!Y,Z:!Z,P:!P,DECOMP:decomp0}

SET_PLOT,'X'
DEVICE,DECOMPOSED=0
; => Load current colors [*_orig] so they can be reset after done with routine
COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
r_orig0 = r_orig
g_orig0 = g_orig
b_orig0 = b_orig
; => Load special color table
my_loadct2,0
@my_colors2.pro
chcolors = [6,2,4,1]
;-----------------------------------------------------------------------------------------
;  ----SET UP THE PLOT WINDOW----
;-----------------------------------------------------------------------------------------
!P.MULTI    = [0,3,3,0,0]  ;  [# of plots to keep from current plot, columns, rows]
!P.CHARSIZE = 2.2
!P.THICK    = 1.2
thick0      = !P.THICK
;-----------------------------------------------------------------------------------------
; => Define version for output
;-----------------------------------------------------------------------------------------
version = "vector_mv_plot.pro :  01/28/2012   v2.6.2"
t0      = SYSTIME()  ; -time at start of program
;version = version+" "+STRMID(t0,4,6)+", "+STRMID(t0,STRLEN(t0)-4L)

;-----------------------------------------------------------------------------------------
; => Define some default/dummy variables and determine field reading programs
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(coord) THEN crd = 'GSE' ELSE crd = STRUPCASE(coord)
IF KEYWORD_SET(sat) THEN sn = STRLOWCASE(sat) ELSE sn = 'w'
IF NOT KEYWORD_SET(field) THEN fld = 'B' ELSE fld = STRUPCASE(field)

CASE fld[0] OF
  'B'  : xwin_inst = 'MFI'
  'E'  : xwin_inst = 'EFI'
  ELSE : BEGIN
    MESSAGE,'Incorrect keyword format: FIELD',/INFORMATIONAL,/CONTINUE
    MESSAGE,'Using default = B',/INFORMATIONAL,/CONTINUE
    xwin_inst = 'MFI'
  END
ENDCASE

CASE sn OF
  'w'  : BEGIN
    xwint   = 'HTR-'+xwin_inst+'/'
  END
  'a'  : BEGIN
    xwint   = 'STA-'+xwin_inst+'/'
  END
  'b'  : BEGIN
    xwint   = 'STB-'+xwin_inst+'/'
  END
  ELSE : BEGIN
    IF (STRLEN(sn[0]) EQ 3) THEN BEGIN
      xwint   = STRUPCASE(sn[0])+'-'+xwin_inst+'/'
    ENDIF ELSE BEGIN
      MESSAGE,'Incorrect keyword format: SAT',/INFORMATIONAL,/CONTINUE
      MESSAGE,'Using default = W',/INFORMATIONAL,/CONTINUE
      sn      = 'w'
      xwint   = 'HTR-'+xwin_inst+'/'
    ENDELSE
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Define [names] and open windows
;-----------------------------------------------------------------------------------------
DEVICE,GET_SCREEN_SIZE=scsize
; => Define scale size of Windows
IF (scsize[0] GT 1910) THEN BEGIN
  ; => Use default window sizes
  xywsize4 = [1400L, 850L]
  xywsize6 = [ 450L, 620L]
  xypos4   = [ 510L, 330L]
  xypos6   = [  60L, 560L]
ENDIF ELSE BEGIN
  scsize   = DOUBLE(scsize)
  facx4    = scsize[0]*4.11d0/3d0
  facy4    =  facx4[0]*17d0/28d0
  facx6    = scsize[0]/(32d0/(31d0/3d0))
  facy6    =  facx6[0]*62d0/45d0
  xywsize4 = [LONG(facx4[0]), LONG(facy4[0])]
  xywsize6 = [LONG(facx6[0]), LONG(facy6[0])]
  xypos4x  = 60L + xywsize6[0]
  xypos4y  = (11d0/40d0)*scsize[1]
  xypos4   = [LONG(xypos4x),LONG(xypos4y)]
  xypos6x  = 60L           ; => I hope your screen is more than 60 pixels wide...
  xypos6y  = (7d0/15d0)*scsize[1]
  xypos6   = [LONG(xypos6x),LONG(xypos6y)]
ENDELSE
win4lim = {TITLE:xwint+'-MV coords',XSIZE:xywsize4[0],YSIZE:xywsize4[1],$
           XPOS:xypos4[0],YPOS:xypos4[1],RETAIN:2}
win6lim = {TITLE:xwint+'-MV HODO'  ,XSIZE:xywsize6[0],YSIZE:xywsize6[1],$
           XPOS:xypos6[0],YPOS:xypos6[1],RETAIN:2}

WINDOW,4,_EXTRA=win4lim
WINDOW,6,_EXTRA=win6lim
;WINDOW,4,TITLE=xwint+'-MV coords',XSIZE=1400L,YSIZE=850L,XPOS=510L,YPOS=330L,RETAIN=2
;WINDOW,6,TITLE=xwint+'-MV HODO'  ,XSIZE= 450L,YSIZE=620L,XPOS= 60L,YPOS=560L,RETAIN=2
;-----------------------------------------------------------------------------------------
; => Make sure data structure is input and has the correct format
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(mymag) THEN BEGIN
  errmss0 = 'No data structure supplied for analysis...'
  errmss1 = 'Use keyword MYMAG to set structure [see man page for details]'
  MESSAGE,errmss0,/INFORMATIONAL,/CONTINUE
  MESSAGE,errmss1,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF ELSE BEGIN
  smyag = SIZE(mymag,/TYPE)
  IF (smyag NE 8L) THEN BEGIN
    errmssg = 'Input must be a data structure...'
    MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
    RETURN
  ENDIF ELSE BEGIN
    ggd = tplot_struct_format_test(mymag,/YVECT)
    IF (ggd[0] EQ 1) THEN BEGIN
      tx  = mymag.X  ; -time
      bx  = REFORM(mymag.Y[*,0])
      by  = REFORM(mymag.Y[*,1])
      bz  = REFORM(mymag.Y[*,2])
      mts = my_time_string(tx,UNIX=1,/NOMSSG)
      tc  = mts.TIME_C
      ts  = mts.SOD
      my_date = STRMID(mts.DATE_TIME[0],0L,4L)+STRMID(mts.DATE_TIME[0],5L,2L)+$
                STRMID(mts.DATE_TIME[0],8L,2L)
    ENDIF ELSE BEGIN
      errmssg = 'Structure must have the format {X:[unix time],Y:[N,3]-Element Vector}...'
      MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
      RETURN
    ENDELSE
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Get Date associated with files of interest
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(date) THEN date0 = my_date ELSE date0 = date

mydate = my_str_date(DATE=date0)
date   = mydate.S_DATE[0]      ; => 'MMDDYY'
mdate  = mydate.DATE[0]        ; => 'YYYYMMDD'
zdate  = mydate.TDATE[0]       ; => 'YYYY-MM-DD'
ldate  = mdate[0]
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
npoints  = N_ELEMENTS(tx)             ; => # of input vectors
evlength = tx[e] - tx[s]              ; => Time duration of input data [seconds]
nsps     = (npoints - 1L)/evlength    ; => Sample rate [samples per second]
nyqst    = nsps[0]/2d0                ; => Nyquist Frequency [Hz]
s        = 0L                         ; => First element
e        = npoints - 1L               ; => Last element
bmag     = SQRT(bx^2 + by^2 + bz^2)   ; => Magnitude of input field
tdate    = date
;-----------------------------------------------------------------------------------------
; => Define dummy parameters for later use
;-----------------------------------------------------------------------------------------
fft_win     = FLTARR(npoints)      ; -dummy var. used for FFT windowing routine
fft_temp    = COMPLEXARR(npoints)
mv_temp     = FLTARR(npoints)      ; -dummy variable used for plotting B-field in GSE
mvc_temp    = FLTARR(npoints)      ; -" " rotated to Min. Var. Coords.
raw_temp    = FLTARR(npoints)
power_temp  = FLTARR(npoints)
cpower_temp = FLTARR(npoints)
power       = FLTARR(npoints)
cpower      = FLTARR(npoints)
read_pause  = ''
step        = 0d0
slow        = 0
;------------------------------------------
; => Should we use windowing for the FFT?
;------------------------------------------
WHILE (read_win NE 'y' AND read_win NE 'n') DO $
  READ,read_win,PROMPT='Use windowing for power spectrum FFT? (y/n):  '
;------------------------------------------
; => Linear or log on the power spectrum?
;------------------------------------------
WHILE (read_logpower NE '0' AND read_logpower NE '1') DO $
  READ,read_logpower,PROMPT="Type 0 for linear power spectrum, 1 for log: "
;-----------------------------------------------------
; => Do you want to scale the B-field by its magnitude?
;-----------------------------------------------------
WHILE (read_bscale NE '0' AND read_bscale NE '1') DO BEGIN
  PRINT,'Do you wish to normalize the B-field amplitude by its magnitude?'
  READ,read_bscale,PROMPT='Type 1 to normalize the B-field, 0 for regular: '
ENDWHILE

IF NOT KEYWORD_SET(fcutoff) THEN BEGIN
  fmax = nsps[0]/2d0
  IF (read_logpower EQ '1') THEN fmin = nsps[0]/(1d0*e[0]) ELSE fmin = 0d0
ENDIF ELSE BEGIN
  fmin = fcutoff[0]
  fmax = fcutoff[1]
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check to see if user wants to compare MVA results to a DC field
;-----------------------------------------------------------------------------------------
IF (NOT KEYWORD_SET(dcbkgf) OR N_ELEMENTS(dcbkgf) EQ 0) THEN dcbkgf = 0
IF (tplot_struct_format_test(dcbkgf,/YVECT)) THEN BEGIN
  dc_times  = dcbkgf.X
  dc_field  = dcbkgf.Y
  y_dims    = SIZE(dc_field,/N_DIMENSIONS)
  CASE y_dims[0] OF
    1L   : BEGIN
      ; => single vector so check time range to make sure there is overlap
      good = (dc_times[0] LE MAX(tx,/NAN)) AND (dc_times[0] GE MIN(tx,/NAN))
      IF (good) THEN avg_field = REFORM(dc_field) ELSE avg_field = 0
    END
    2L   : BEGIN
      ; => array of vectors so check time range to make sure there is overlap
      good = WHERE(dc_times LE MAX(tx[s:e],/NAN) AND dc_times GE MIN(tx[s:e],/NAN),gd)
      IF (gd GT 0) THEN BEGIN
        g_times      = tx[s:e]
        temp_x       = interp(dc_field[*,0],dc_times,g_times,/NO_EXTRAP)
        temp_y       = interp(dc_field[*,1],dc_times,g_times,/NO_EXTRAP)
        temp_z       = interp(dc_field[*,2],dc_times,g_times,/NO_EXTRAP)
        avg_field    = DBLARR(3)
        avg_field[0] = MEAN(temp_x,/NAN,/DOUBLE)
        avg_field[1] = MEAN(temp_y,/NAN,/DOUBLE)
        avg_field[2] = MEAN(temp_z,/NAN,/DOUBLE)
      ENDIF ELSE avg_field = 0
    END
    ELSE : BEGIN
      avg_field = 0
    END
  ENDCASE
ENDIF ELSE BEGIN
  avg_field = 0
ENDELSE
; => dummy vector used to compare angular changes in minimum variance direction
;      between successive runs of my_min_var_rot.pro
minvardir = [0.,0.,0.]
; => Set dummy start/end element used if you wish to go back to last time range
s_0       = s
e_0       = e
thick     = thick0
;=========================================================================================
JUMP_PLOT:
;=========================================================================================
;-----------------------------------------------------------------------------------------
; => (Re-)Calculate Min. Var. and print results to screen
;-----------------------------------------------------------------------------------------
bxv_last  = minvardir
IF (read_bscale EQ '1') THEN boffset = 1 ELSE boffset = 0

my_min = my_min_var_rot([[bx],[by],[bz]],RANGE=[s,e],$
                        BKG_FIELD=avg_field,OFFSET=boffset)

bxv    = my_min.MV_FIELD[*,0]  ; - X-MV comp. of B-field (nT)
byv    = my_min.MV_FIELD[*,1]  ; - Y-MV " "
bzv    = my_min.MV_FIELD[*,2]  ; - Z-MV " "
lams   = my_min.EIGENVALUES    ; -Eigenvalues of MV analysis [max, mid, min]
; => Calculate the angle between this MV vector and the previous to examine the change
;      in direction between the two calculations
minvardir   = my_min.EIGENVECTORS[*,0]  ; - X-MV dir. 
delta_theta = ACOS(my_dot_prod(bxv_last,minvardir,/NOM))*18d1/!DPI
PRINT,';'
PRINT,';The change in angle from last MVA:  ',delta_theta[0]
PRINT,';'
;=========================================================================================
JUMP_SAVE:
;=========================================================================================

;-----------------------------------------------------------------------------------------
; => Define some logic parameters for later use
;-----------------------------------------------------------------------------------------
IF (read_pause NE 'ps') THEN BEGIN
  fsave = 0
ENDIF ELSE BEGIN
  fsave = 1
ENDELSE
IF (read_win EQ 'y') THEN BEGIN  ; -with windowing
  r_win = 1
ENDIF ELSE BEGIN
  r_win = 0
ENDELSE
IF (read_logpower EQ '1') THEN BEGIN ; -plot freq. on log-scale
  r_log = 1
ENDIF ELSE BEGIN
  r_log = 0
ENDELSE
IF (slow EQ 1)  THEN BEGIN
  tstep     = step
  slow_time = 1
ENDIF ELSE BEGIN
  tstep     = 0
  slow_time = 0
ENDELSE

plot_vector_mv_data,tx,[[bx],[by],[bz]],ROTBF=[[bxv],[byv],[bzv]],RANGE=[s,e], $
                    READ_B=read_bscale,DATE=date,FSAVE=fsave,FIELD=field,      $
                    READ_WIN=r_win,PLOT_CNT=pscount,READ_L=r_log,              $
                    UNITS=units,NORMALIZE=normalize,SLOW_P=slow_time,          $
                    T_STEP=tstep,EIGA=lams,FCUTOFF=[fmin[0],fmax[0]],SAT=sat,  $
                    COORD=crd,THICK=thick,VVERSION=version,SUFFX=suffx
;-----------------------------------------------------------------------------------------
; => Determine options
;-----------------------------------------------------------------------------------------
f_lab    = normalize  ; =>  '/|B|' if read_bscale set, else = ''
unit_lab = units      ; =>  '' if read_bscale set, else = ' (nT)'

; => shut off slow plotting
slow     = 0
;=========================================================================================
JUMP_PAUSE:
;=========================================================================================
READ,read_pause,PROMPT="Enter command (type '?' for help) :"

test_r = ((read_pause NE ''    ) AND (read_pause NE '?'      ) AND $
          (read_pause NE 's'   ) AND (read_pause NE 'q'      ) AND $
          (read_pause NE 'tr'  ) AND (read_pause NE 'z'      ) AND $
          (read_pause NE 'ps'  ) AND (read_pause NE 'right'  ) AND $
          (read_pause NE 'i'   ) AND (read_pause NE 'last_tr') AND $
          (read_pause NE 'sc'  ) AND (read_pause NE 'left'   ) AND $
          (read_pause NE 'log' ) AND (read_pause NE 'thick'  ) AND $
          (read_pause NE 'freq'))

IF (test_r) THEN GOTO,JUMP_PAUSE  ; => Invalid input... try again

;IF (read_pause NE ''     AND read_pause NE '?'     AND read_pause NE 's'  AND   $
;    read_pause NE 'z'    AND read_pause NE 'ps'    AND read_pause NE 'q'  AND   $
;    read_pause NE 'i'    AND read_pause NE 'sc'    AND read_pause NE 'tr' AND   $
;    read_pause NE 'left' AND read_pause NE 'right' AND                          $
;    read_pause NE 'log'  AND read_pause NE 'last_tr') THEN $
;    GOTO,JUMP_PAUSE

IF (read_pause EQ '') THEN GOTO,JUMP_PLOT    ; => User hit Enter
; => List all optional values of READ_PAUSE
IF (read_pause EQ '?') THEN BEGIN
  read_pause = ''
  list_read_options
  GOTO,JUMP_PAUSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Test user option
;-----------------------------------------------------------------------------------------
CASE STRLOWCASE(read_pause[0]) OF
  'left'    : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Change start time 'HH:MM:SS.sss'
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s_0        = s
    e_0        = e
    ; => unset read_pause logical variable
    read_pause = ''
    n_eles     = change_tr_lrtr(s,e,tx,LEFT=1,RIGHT=0,TR=0,ZOOMT=0)
    IF (SIZE(n_eles[0],/TYPE) EQ 7) THEN BEGIN
      read_pause = 'q'
      GOTO,JUMP_QUIT
    ENDIF ELSE BEGIN
      s = n_eles[0]
      e = n_eles[1]
    ENDELSE
    ; => Plot new time range
    GOTO,JUMP_PLOT
  END
  'right'   : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Change end time 'HH:MM:SS.sss'
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s_0        = s
    e_0        = e
    ; => unset read_pause logical variable
    read_pause = ''
    n_eles     = change_tr_lrtr(s,e,tx,LEFT=0,RIGHT=1,TR=0,ZOOMT=0)
    IF (SIZE(n_eles[0],/TYPE) EQ 7) THEN BEGIN
      read_pause = 'q'
      GOTO,JUMP_QUIT
    ENDIF ELSE BEGIN
      s = n_eles[0]
      e = n_eles[1]
    ENDELSE
    ; => Plot new time range
    GOTO,JUMP_PLOT
  END
  'tr'      : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Change time range 'HH:MM:SS.sss'
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s_0        = s
    e_0        = e
    ; => unset read_pause logical variable
    read_pause = ''
    n_eles     = change_tr_lrtr(s,e,tx,LEFT=0,RIGHT=0,TR=1,ZOOMT=0)
    IF (SIZE(n_eles[0],/TYPE) EQ 7) THEN BEGIN
      read_pause = 'q'
      GOTO,JUMP_QUIT
    ENDIF ELSE BEGIN
      s = n_eles[0]
      e = n_eles[1]
    ENDELSE
    ; => Plot new time range
    GOTO,JUMP_PLOT
  END
  'z'       : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Change time range of plots and re-plot the data
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s_0        = s
    e_0        = e
    ; => unset read_pause logical variable
    read_pause = ''
    n_eles     = change_tr_lrtr(s,e,tx,LEFT=0,RIGHT=0,TR=0,ZOOMT=1)
    IF (SIZE(n_eles[0],/TYPE) EQ 7) THEN BEGIN
      read_pause = 'q'
      GOTO,JUMP_QUIT
    ENDIF ELSE BEGIN
      s = n_eles[0]
      e = n_eles[1]
    ENDELSE
    ; => Plot new time range
    GOTO,JUMP_PLOT
  END
  'last_tr' : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Return to previous plot range
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s          = s_0
    e          = e_0
    ; => unset read_pause logical variable
    read_pause = ''
    GOTO,JUMP_PLOT
  END
  'thick'   : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Change the thickness of lines in plots
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s_0        = s
    e_0        = e
    ; => unset read_pause logical variable
    read_pause = ''
    thicks     = ''
    badth      = 1
    WHILE (badth) DO BEGIN
      READ,thicks,PROMPT="Enter a thickness >0.0 and less than 3.0 : "
      thicks = STRTRIM(STRING(thicks,FORMAT='(f8.1)'),2)
      thick  = FLOAT(thicks)
      badth  = (thick[0] LE 0.0) OR (thick[0] GT 3.0)
      IF (badth) THEN PRINT,'Value must be greater than 0.0 and less than 3.0'
    ENDWHILE
    ; => Nothing about MVA will change, so no need to redo calculation
    GOTO,JUMP_SAVE
  END
  'log'     : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Change linear/logarithmic scale of power spectrum
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s_0        = s
    e_0        = e
    ; => unset read_pause logical variable
    read_pause = ''
    IF (read_logpower EQ '1') THEN BEGIN
      old_log = 1 
      outmssg = 'Currently plotting power spectrum in log-base'
    ENDIF ELSE BEGIN
      old_log = 0
      outmssg = 'Currently plotting power spectrum in lin-base'
    ENDELSE
    read_logpower = ''
    PRINT,outmssg
    WHILE (read_logpower NE '0' AND read_logpower NE '1') DO BEGIN
      READ,read_logpower,PROMPT="Type 0 for linear power spectrum, 1 for log: "
    ENDWHILE
    ; => Nothing about MVA will change, so no need to redo calculation
    GOTO,JUMP_SAVE
  END
  'freq'     : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Change the frequency scale of power spectrum
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s_0         = s
    e_0         = e
    ; => unset read_pause logical variable
    read_pause  = ''
    ; => determine new frequency range
    read_frange = plot_mv_freq_ticks(nyqst[0],FREQRA=[fmin,fmax])
    ; => Nothing about MVA will change, so no need to redo calculation
    GOTO,JUMP_SAVE
  END
  'sc'      : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Change B-field scaling if desired...
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s_0        = s
    e_0        = e
    ; => unset read_pause logical variable
    read_pause = ''
    IF (read_bscale EQ '1') THEN BEGIN
      my_oscale = '1/|'+fld[0]+'|'
    ENDIF ELSE BEGIN
      my_oscale = '1.0'
    ENDELSE
    PRINT,'Do you wish to change the scaling of the B-field?'
    PRINT,'It is currently scaled by: ',my_oscale
    read_bscale = ''
    WHILE (read_bscale NE '0' AND read_bscale NE '1') DO BEGIN
      READ,read_bscale,PROMPT='Type 1 to scale by |B|, 0 for 1.0 scale: '
    ENDWHILE
    ; => Nothing about MVA will change, so no need to redo calculation
;    GOTO,JUMP_SAVE
    ; => Plot new scaled field
    GOTO,JUMP_PLOT
  END
  's'       : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Change time rate of plotting if desired...
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s_0        = s
    e_0        = e
    ; => unset read_pause logical variable
    read_pause = ''
    ;--------------------------------------
    PRINT,"Please enter a time step indicating the amount of time to wait in between "
    PRINT," plotting points (0.01 is slow but tolerable)."
    READ,step,PROMPT="Enter timestep in seconds: "
    PRINT,''
    PRINT,"If you get impatient, press 's' to skip to the next hodogram..."
    PRINT,''
    ;--------------------------------------
    stop_slow_plot = ''
    slow           = 1
    ; => Nothing about MVA will change, so no need to redo calculation
    GOTO,JUMP_SAVE
  END
  'ps'      : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => output a postscript plot if desired
    ;-------------------------------------------------------------------------------------
    ; => define old plot range elements
    s_0        = s
    e_0        = e
    ; => unset read_pause logical variable
;    read_pause = ''
    psc_string = 'P'+STRTRIM(pscount,2L)
    structure  = {MVA:my_min,RANGE:[s,e],TRANGE:[tx[s],tx[e]]}
    ; => Keep the MVA stats for this time range
    str_element,stats,psc_string,structure,/ADD_REPLACE
    ; => Make sure the directory ~/output/ exists in your IDL Working directory
    fout_test = FILE_TEST('output',/DIRECTORY)
    mdir      = FILE_EXPAND_PATH('')
    IF (fout_test EQ 0) THEN BEGIN
      out_file = mdir+'/output'
      FILE_MKDIR,out_file,/NOEXPAND_PATH
      FILE_CHMOD,out_file,/A_READ,/A_WRITE,/NOEXPAND_PATH
    ENDIF
    ; => Nothing about MVA will change, so no need to redo calculation
    GOTO,JUMP_SAVE
  END
  'q'       : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Quit so reset defaults
    ;-------------------------------------------------------------------------------------
    ;=====================================================================================
    JUMP_QUIT:
    ;=====================================================================================
    ; => Reset color table
    TVLCT,r_orig0,g_orig0,b_orig0
    ; => Return plot window to original state
    !X   = xyzp_win.X
    !Y   = xyzp_win.Y
    !Z   = xyzp_win.Z
    !P   = xyzp_win.P
    DEVICE,DECOMPOSED=xyzp_win.DECOMP
    ; => Close X-Windows
    SET_PLOT,'X'
    WDELETE,4
    WDELETE,6
    RETURN
  END
  ELSE    : BEGIN
    errmssg = 'Something is missing from the READ_PAUSE error handling => fail'
    MESSAGE,errmssg,/INFORMATIONAL,/CONTINUE
    STOP
  END
ENDCASE

RETURN
END