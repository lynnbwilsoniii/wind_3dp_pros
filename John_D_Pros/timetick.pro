;+
; FUNCTION:
; 	 TIMETICK
;
; DESCRIPTION:
;
;	Function to build the anotatation for time axes labeling.
;
; 	Input parameters are the start and end seconds since 1970, Jan 1,
; 	00:00:00.
;
; 	The return value is a structure of the format:
;
;	 {time_tk_str                       $
;	             ,xtickname: STRARR(22) $   ; Actual labels for ticks
;	             ,xtickv:    FLTARR(22) $   ; Actual tick locations
;	             ,xticks:    1          $   ; number of major ticks
;	             ,xminor:    1          $   ; number of minor ticks
;	             ,xrange:    FLTARR(2)  $   ; min and max time of plot
;		     ,xstyle:    1          $   ; const specifying plot style
;	 }
;
; USAGE (SAMPLE CODE FRAGMENT):
; 
;    ; get the start and end values.  Assume time_pts array has been
;    ; sorted appropriately
;
;       start_sec = time_pts(0)                
;       end_sec = time_pts(N_ELEMENTS(time_pts)-1)
;
;    ; now we do the plot 
;
; 	time_setup = timetick(start_sec, end_sec, min_max_flag, offset,
;		datelab)
; 	PLOT, time_pts-offset, value_pts, _EXTRA=time_setup,
;		XTITLE='Time UT from: ' + datelab
;
; KEYWORDS:
;
;    FMT	Controls the format of the dates in the time labels.
;		If FMT is zero, or is not given, then dates will be given as
;		95/12/30.  If FMT is non-zero, then dates will be given as
;		30 Dec 95.
;
;    DATELABFMT	Controls the format of the datelab string.  If it's
;		not set or zero, the datelab string will include the full
;		date and time for the start of the plot.  If it's non-zero,
;		the datelab string will include only the most significant
;		portion of the date and time of the start of the plot that is
; 		not included in the actual tick marks.
;	
; NOTES:
;
;	The returned time_tk_str has tags named so that it can be used
;	with the special _EXTRA keyword in the call to PLOT or OPLOT.
;
;	The offset value that is returned from timetick must be
;	subtracted from the time-axis data values before plotting.
;	This is to maintain resolution in the PLOT routines, which use
;	single precision floating point internally.  Remember that if
;	the CURSOR routine is used to read a cursor position from the
;	plot, this offset will need to be added back to the time-axis
;	value to get seconds since 00:00:00 1-1-1970.
;
; 	The datelab returned parameter gives the most significant part
;	of the date/time that is not included in the tick labels.  It will
; 	be derived from the first tick time.  It can then be used in
;	a title to give the date/time of the start of the data, when the
;	plot duration is to short for this to be included in the xticks.
;	if the full date is included in the xticks, datelab will be a
;	null string.
;
;	The parameter min_max_flag determines how the start and end times
;	for the plot will be calculated.  If it greater than or equal to 1, 
;	the start and end times will be fourced to align upon a major 
;	tick mark.  Otherwise, the start and end times will be set to
;	the start_sec and end_sec parameters.
;
; 	This function only makes sense for linear X-axes, though it
; 	should work with the log case as well.
;
; 	Be warned that usage of large fonts may cause the time labels
; 	to run into eachother.  Time labels can be much wider than normal
; 	numeric labels.
;
;	Time plot durations of approximately 10 milliseconds to 20 years
;	are handled.
;
;	If arrays of start and end times are given, then an array
;	of N_ELEMENTS(inputs vals) of time_tk_str, offset and datelab
;	will be returned.
;
;	If an error is encountered, then -1 is returned
;
;	This function calls upon the "sectime", "secdate", "datesec",
;	"monthyrfrom" and  "yrfrom" procedures.
;
; REVISION HISTORY:
;
;	@(#)timetick.pro	1.7 01/15/98 	
; 	Originally written by Jonathan M. Loran,  University of 
; 	California at Berkeley, Space Sciences Lab.   Dec. '91
;
;	Revised Jan. '92 to cover time durations up to 20 years
;-

FUNCTION timetick, start_tm, end_tm,st_en_flag, offset, datelab, FMT=fmt,    $
                  DATELABFMT=dlfmt

; set error break

ON_ERROR, 2

; check for equal dimensions and existance of input parameters

IF( N_ELEMENTS(start_tm) NE N_ELEMENTS(end_tm))                      $
	OR ( N_ELEMENTS(start_tm)   EQ 0 )                           $
	OR ( N_ELEMENTS(end_tm)     EQ 0 )                           $
	OR ( N_ELEMENTS(st_en_flag) EQ 0 )   THEN RETURN, -1

; Define parameter arrays

; length of time between major ticks for given plot time durations (seconds).
; These ticks must be aligned on multiples of these values.  A 
; negitive number (except -100.) implies align on month boundaries
; with frequency given, and -100. implies align on year boundaries.

frequency = [-100.         , -6.          , -2.          , -1.          $
              , 864000.    , 259200.      , 86400.       , 43200.       $
              , 14400.     , 10800.       , 7200.        , 3600.        $
              , 1800.      , 1200.        , 600.         , 300.         $
              , 120.       , 60.          , 30.          , 20.          $
              , 10.        , 5.           , 2.           , 1.           $
              , .5         , .2           , .1           , .05          $
              , .025       , .01          , .005         , .002         $
             ]

; plot duration boundaries in seconds.  For durations less than one day,
; we will just make these 7.5 times the tick frequency.  For longer
; plot durations, we will need to set the boundaries explicitly.

boundaries = frequency * 7.5

boundaries (0) = 94608000.
boundaries (1) = 94608000.
boundaries (2) = 47433600.
boundaries (3) = 15724800.
boundaries (4) = 7776000.
boundaries (5) = 3024000.
boundaries (6) = 864000.
boundaries (7) = 302400.

; number of minor ticks for given plot time durations.

minors    = [ 12      , 6      , 2      , 2              $
            , 10      , 3      , 24     , 12             $
            , 4       , 3      , 12     , 6              $
            , 3       , 20     , 10     , 5              $
            , 2       , 1      , 3      , 20             $
            , 10      , 5      , 20     , 10             $
            , 5       , 20     , 10     , 5              $
            , 5       , 10     , 5      , 2              $
            ]

; the length of the datelab string based on plot duration

IF KEYWORD_SET (fmt) THEN BEGIN
; (first, time string format is DY MON YR HR:MN:SC.MSC. )
   datelab_len = [ 0       , 0       , 0       , 0              $
                 , 0       , 0       , 0       , 0              $
                 , 9       , 9       , 9       , 9              $
                 , 9       , 9       , 9       , 9              $
                 , 9       , 9       , 12      , 12             $
                 , 12      , 12      , 12      , 12             $
                 , 15      , 15      , 15      , 15             $
                 , 15      , 15      , 15      , 15             $
                  ]
ENDIF ELSE BEGIN
; (second, time string format is YY-MM-DD HR:MN:SC.MSC. )
   datelab_len = [ 0        , 0       , 4       , 4              $
                 , 4        , 4       , 4       , 7              $
                 , 10       , 10      , 10      , 10             $
                 , 10       , 10      , 10      , 10             $
                 , 10       , 10      , 13      , 13             $
                 , 13       , 13      , 13      , 13             $
                 , 16       , 16      , 16      , 16             $
                 , 16       , 16      , 16      , 16             $
                 ]
ENDELSE

; This array holds the units strings for each of the tick mark ranges.
datelab_units = [   'Years'  , 'Months' , 'Months' , 'Months'      $
                  , 'Days'   , 'Days'   , 'Days'   , 'Hours'       $
                  , 'Hours'  , 'Hours'  , 'Hours'  , 'Hours'       $
                  , 'Hours'  , 'Hours'  , 'Hours'  , 'Hours'       $
                  , 'Hours'  , 'Hours'  , 'Minutes', 'Minutes'     $
                  , 'Minutes', 'Minutes', 'Minutes', 'Minutes'     $
                  , 'Seconds', 'Seconds', 'Seconds', 'Seconds'     $
                  , 'Seconds', 'Seconds', 'Seconds', 'Seconds'     $
                  ]

; the length of the time strings that will be returned.
IF KEYWORD_SET (fmt) THEN BEGIN
; (first, time string format is DY MON YR HR:MN:SC.MSC. )
   tk_str_len = [ 2         , 6       , 6       , 6             $
	        , 9         , 9       , 9       , 15            $
                , 5         , 5       , 5       , 5             $
                , 5         , 5       , 5       , 5             $
                , 5         , 5       , 5       , 5             $
                , 5         , 5       , 5       , 5             $
                , 4         , 4       , 4       , 5             $
                , 6         , 5       , 6       , 6             $
	        ]
ENDIF ELSE BEGIN
; (second, time string format is YY-MM-DD HR:MN:SC.MSC. )
   tk_str_len = [ 4         , 7       , 2       , 2             $
	        , 5         , 5       , 5       , 5             $
                , 5         , 5       , 5       , 5             $
                , 5         , 5       , 5       , 5             $
                , 5         , 5       , 6       , 6             $
                , 6         , 6       , 6       , 6             $
                , 5         , 5       , 5       , 6             $
                , 7         , 7       , 7       , 7             $
	        ]
ENDELSE

; the starting char of date plus time string to be returned.  

IF KEYWORD_SET (fmt) THEN BEGIN
; (first, time string format is DY MON YR HR:MN:SC.MSC. )
tk_str_st = [ 7            ,3            ,3            ,3            $
	     ,0            ,0            ,0            ,0            $
	     ,10           ,10           ,10           ,10           $
             ,10           ,10           ,10           ,10           $
	     ,10           ,10           ,13           ,13           $
	     ,13           ,13           ,13           ,13           $
             ,16           ,16	         ,16           ,16           $
             ,16           ,16	         ,16           ,16           $
            ]
ENDIF ELSE BEGIN
; (second, time string format is YYYY-MM-DD HR:MN:SC.MSC. )
tk_str_st = [ 0            ,0            ,5            ,5            $
	     ,5            ,5            ,5            ,8            $
	     ,11           ,11           ,11           ,11           $
             ,11           ,11           ,11           ,11           $
	     ,11           ,11           ,13           ,13           $
	     ,13           ,13           ,13           ,13           $
             ,16           ,16	         ,16           ,16           $
             ,16           ,16	         ,16           ,16           $
	    ]
ENDELSE

; set up the output structure

tick_setup =  {time_tk_str                  $
	             ,xtickname: STRARR(22) $   ; Actual labels for ticks
	             ,xtickv:    FLTARR(22) $   ; Actual tick locations
	             ,xticks:    1          $   ; number of major ticks
	             ,xminor:    1          $   ; number of minor ticks
	             ,xrange:    FLTARR(2)  $   ; min and max time of plot
		     ,xstyle:    1          $   ; const specifying plot style
              }

; initialize the time axis offset

offset = 0.D
datelab = ""

;  Now loop through input pairs

FOR i=0, N_ELEMENTS(start_tm)-1 DO BEGIN

;    Extend output struct array if necessary

   IF i GT 0  THEN BEGIN
      tick_setup = [tick_setup, time_tk_str]
      offset = [offset, 0.D]
      datelab = [datelab, ""]
   ENDIF
   
;    check for start LE end time, and if so, adjust

	st_tm = start_tm(i) < end_tm(i)
	en_tm = start_tm(i) > end_tm(i)

	IF st_tm GE (en_tm - .01) THEN en_tm = st_tm + .011

;    Detemine the time span index of this plot

	dt_index = (WHERE((en_tm-st_tm) GE boundaries))(0) -1
	IF (dt_index LT 0) AND ((en_tm-st_tm) LT 1.) THEN               $
		     dt_index = N_ELEMENTS(boundaries) - 1 $ ; small dt case
	ELSE IF dt_index LT 0 THEN                                      $
		     dt_index = 0                            ; large dt case

;    calculate the offset.
;    time alignment

	IF frequency(dt_index) GT 0. THEN                               $

;    Here we take care of longword overflow and round off errors, if 
;    necessary.  This is caused by large start times combined with 
;    reletively small spacing between tickmarcks (small duration plot)

		IF en_tm-st_tm LT 60.*7.5  THEN BEGIN

			tempoffset = datesec(secdate(st_tm,rem,/FMT))   $
			             + timesec(STRMID(STRTRIM(sectime(  $
			             rem),2),0,5))

			offset(i)=((DOUBLE(LONG((st_tm                  $
			                     - tempoffset)              $
			                     /frequency(dt_index))))    $
			                     * frequency(dt_index))     $
			                     + tempoffset              

		ENDIF ELSE offset(i) = (DOUBLE(LONG(st_tm               $
			                     /frequency(dt_index))))    $
			                     * frequency(dt_index)      $

;    monthly alignment

	ELSE IF frequency(dt_index) LT 0. AND                           $
		frequency(dt_index) GT -100.  THEN                      $
		offset(i) = datesec((monthyrfrom(st_tm                  $
				       ,1,1))(0))                       $

;    yearly alignment

	ELSE offset(i) = datesec((yrfrom(st_tm,1))(0))

;    get the values of the major ticks.  We make sure they fall on 
;    even multiples their spacing.  If we are forcing alignment on a 
;    year or month boundary, we use the routine monthyrfrom(start)
;    and yrfrom(start) to do so.

;    first, for non-monthly/non-yearly alignments

	IF frequency(dt_index) GT 0. THEN                               $
		tempvalues =      DINDGEN(14)*frequency(dt_index)       $
				+ offset(i)                             $
				- frequency(dt_index)                   $

;    forced monthly alignment

	ELSE IF frequency(dt_index) LT 0. AND                           $
		frequency(dt_index) GT -100.  THEN                      $
		tempvalues =    datesec(                                $
				monthyrfrom(st_tm,23                    $
				,FIX(-frequency(dt_index)))             $
				)                                       $

;    forced yearly alignment

	ELSE                                                            $
		tempvalues =    datesec(yrfrom(st_tm,23))      

;    start plot time, determine based on st_en_flag
;    align on major tick mark

	IF st_en_flag GE 1 THEN   BEGIN
		tick_setup(i).xrange(0) = 0. 
		tempmin = offset(i)  ; save plot min for next step

;    else align on given start time

	ENDIF ELSE  BEGIN
		tick_setup(i).xrange(0) = st_tm - offset(i)
		tempmin = st_tm  ; save plot min for next step
	ENDELSE
	

;    set the actual values in the output struct where the major ticks 
;    will go 
        
	tempvalues=  (tempvalues(WHERE(tempvalues                       $
		     GE (tempmin))))(0:21<N_ELEMENTS(                   $
		     tempvalues(WHERE(tempvalues GE tempmin)))-1)

;    now get the tick mark labels

	tick_setup(i).xtickname =  STRMID(secdate(tempvalues,rem,FMT=fmt)  $
				+ '/' + sectime(rem)                    $
				, tk_str_st(dt_index)                   $
				, tk_str_len(dt_index)                  $
				)

;    for yearly labels, prepend 19 or 20 to year, only if /FMT set

	IF frequency(dt_index) EQ -100. THEN BEGIN

                IF KEYWORD_SET (fmt) THEN BEGIN 

		   templabels = 999999   ; use impossible year as flag

;    years in 1900's
                   IF (WHERE(FIX(tick_setup(i).xtickname) GT 69))(0)        $
			   NE -1 THEN                                       $
			   templabels = 1900 +                              $
			                (FIX(tick_setup(i).xtickname))(     $
			                WHERE(FIX(                          $
			                tick_setup(i).xtickname) GT 69)     $
			                )

;    years in 2000's and there where years in 1900's

		   IF ( (WHERE(FIX(tick_setup(i).xtickname) LE 69))(0)      $
			   NE -1) AND (templabels(0) NE 999999)  THEN       $
			   templabels = [templabels, 2000                   $
			                + (FIX(tick_setup(i).xtickname))(   $
			                WHERE(FIX(                          $
			                tick_setup(i).xtickname) LE 69)     $
			                )]                                  $

;    years in 2000's and no years in 1900's

		   ELSE IF  (WHERE(FIX(tick_setup(i).xtickname)             $
			   LE 69))(0) NE -1 THEN                            $
			   templabels = 2000                                $
			                + (FIX(tick_setup(i).xtickname))(   $
			                WHERE(FIX(                          $
			                tick_setup(i).xtickname) LE 69)     $
			                )

                ENDIF ELSE templabels = tick_setup(i).xtickname
                
;    convert back to strings

		tick_setup(i).xtickname = STRTRIM(templabels,2)

	ENDIF

;    subtract offset and set tick_setup.value array

	tick_setup(i).xtickv = tempvalues  - offset(i)

;    end plot time
;    on major tick mark time alignment

	IF frequency(dt_index) GT 0. AND st_en_flag GE 1 THEN            $

;    once again, we take care of longword over flow, if necessary
;    (same reason as for offset calculation above).  The tempoffset
;    we use from above.

		IF en_tm-st_tm LT 60.*7.5  THEN BEGIN

			tick_setup(i).xrange(1) = (DOUBLE(LONG((en_tm    $
			                     - tempoffset)               $
			                     /frequency(dt_index))))     $
			                     * frequency(dt_index)       $
			                     + ((en_tm                   $
			                     MOD frequency(dt_index))    $
			                     GT 0.)                      $
			                     * frequency(dt_index)       $
			                     +tempoffset                 $
			                     - offset(i)  

		ENDIF ELSE  tick_setup(i).xrange(1) = (DOUBLE(LONG(en_tm $
			                     / frequency(dt_index))      $
			                     + ((en_tm                   $
			                     MOD frequency(dt_index))    $
			                     GT 0.)))                    $
			                     * frequency(dt_index)       $
			                     - offset(i)                 $

;    on major tick mark, monthly alignment

	ELSE IF frequency(dt_index) LT 0. AND                            $
		frequency(dt_index) GT -100. AND st_en_flag GE 1 THEN    $
		tick_setup(i).xrange(1) = datesec((monthyrfrom(en_tm     $
		                    ,2,1))(1))- offset(i)                $

;    on major tick, yearly alignment

	ELSE IF st_en_flag GE 1 THEN                                     $
		tick_setup(i).xrange(1) = datesec((yrfrom(en_tm,2))(1))  $
	                          - offset(i)                            $

;    aligned on given end time

	ELSE    tick_setup(i).xrange(1) = en_tm - offset(i)

;    set up the number of major tick marks

	tick_setup(i).xticks=  N_ELEMENTS(WHERE(                         $
				(tick_setup(i).xtickv                    $
				LE (tick_setup(i).xrange(1) + .00005))   $
				AND (tick_setup(i).xtickv GT 0.))-1)

;    just in case..

	IF tick_setup(i).xtickv(tick_setup(i).xticks)                    $
		GT tick_setup(i).xrange(1)  THEN                         $
		tick_setup(i).xticks = tick_setup(i).xticks - 1

;   and the number of minor ticks

	tick_setup(i).xminor = minors(dt_index)

;   finally, set up the datelab

        IF datelab_len(dt_index) GT 0 THEN BEGIN
           stripmslen = 19
           IF KEYWORD_SET(fmt) THEN stripmslen = 18
             datelab(i) = STRMID (secdate(tempvalues(0), rem, FMT = fmt) $
                                  + '/' + sectime(rem)                   $
                                  , 0, stripmslen)
           IF KEYWORD_SET(dlfmt) THEN                                    $
             datelab(i) = STRMID (datelab(i), 0, datelab_len(dt_index))
           datelab(i) = datelab_units (dt_index) + ' from ' + dateLab(i)
        ENDIF

; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; the following is a hack to get around an IDL 3.6.1a bug where plots
; always align limits on tick mark boundaries.  It should be taken out at
; a later date when IDL is fixed, since it messes up the minor tickmarks.
;
;        IF st_en_flag EQ 0 THEN BEGIN
;           nticksM1 = N_ELEMENTS(tick_setup(i).xtickname) - 1
;           templabs = [' '                                                   $
;                        , tick_setup(i).xtickname(0:tick_setup(i).xticks)    $
;                        , REPLICATE(' ', nticksM1)]
;           tick_setup(i).xtickname = templabs(0:nticksM1)
;           tempvals = [tick_setup(i).xrange(0)                               $
;                        , tick_setup(i).xtickv(0:tick_setup(i).xticks)       $
;                        , REPLICATE(tick_setup(i).xrange(1), nticksM1)]
;           tick_setup(i).xtickv = tempvals(0:nticksM1)
;           tick_setup(i).xticks = tick_setup(i).xticks + 2
;        ENDIF 
; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

ENDFOR                                          ; main loop

RETURN, tick_setup                              ; normal return

END                                             ; TIMETICK
