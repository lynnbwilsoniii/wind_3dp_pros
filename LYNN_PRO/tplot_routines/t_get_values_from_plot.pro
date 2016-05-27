;+
;*****************************************************************************************
;
;  PROCEDURE:   t_get_values_from_plot.pro
;  PURPOSE  :   This routine allows users to retrieve values from a TPLOT variable by
;                 clicking on the plot at the desired point(s).  The routine allows the
;                 user to define the number of points they wish to return.  Both the
;                 data values and their associated abscissa (i.e., timestamp) values
;                 are returned to the user.
;
;                 The routine was specifically designed to make the process of
;                 identifying the upper hybrid line in electric field dynamic spectra
;                 plots.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tnames.pro
;               tplot_com.pro
;               str_element.pro
;               ctime.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TP_NAME     :  Scalar [string] defining the TPLOT handle that the user
;                                wishes to get data from
;                                [Default = first TPLOT handle plotted]
;
;  EXAMPLES:    
;               ;;..............................................................;;
;               ;;  Get only 1 data point
;               ;;..............................................................;;
;               tpname = 'spectra_plot'  ;; assume this is a valid TPLOT handle
;               tpname = tnames(tpname[0])
;               t_get_values_from_plot,tpname[0],DATA_OUT=data_out
;               HELP, data_out, /STRUCT
;               ** Structure <15b5e38>, 3 tags, length=24, data length=20, refs=1:
;                  X               DOUBLE    Array[1]
;                  Y               DOUBLE    Array[1]
;                  Z               FLOAT     Array[1]
;               ;;..............................................................;;
;               ;;  Get only 10 data points
;               ;;..............................................................;;
;               t_get_values_from_plot,tpname[0],DATA_OUT=data_out,NDATA=10
;               HELP, data_out, /STRUCT
;               ** Structure <233d258>, 3 tags, length=200, data length=200, refs=1:
;                  X               DOUBLE    Array[10]
;                  Y               DOUBLE    Array[10]
;                  Z               FLOAT     Array[10]
;               ;;..............................................................;;
;               ;;  Get only an unspecified # of data points
;               ;;..............................................................;;
;               t_get_values_from_plot,tpname[0],/UNKNOWN,DATA_OUT=data_out
;               HELP, data_out, /STRUCT
;               ** Structure <1394a668>, 3 tags, length=80, data length=80, refs=1:
;                  X               DOUBLE    Array[4]
;                  Y               DOUBLE    Array[4]
;                  Z               FLOAT     Array[4]
;
;  KEYWORDS:    
;               NDATA       :  Scalar [long] defining the # of intervals the user knows,
;                                a priori, that they wish to return
;                                [Default = 1]
;               UNKNOWN     :  If set, routine will prompt user asking whether they wish
;                                retrieve another set of values.  Use this keyword if
;                                you are unaware of how many points you wish to get
;                                prior to calling.
;               DATA_OUT    :  Set to a named variable to return the data values and
;                                their associated timestamps.  The output will be
;                                returned as an IDL structure with the following tags:
;                                  X  :  independent variable (e.g., timestamp or x-axis
;                                          variable or abscissa)
;                                  Y  :  1st dependent variable (e.g., y-axis variable)
;                                  Z  :  2nd dependent variable (e.g., z-axis variable)
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  If the TPLOT handle, TP_NAME, is not associated with a spectral
;                     plot, the routine may not be of much use at the moment.
;               2)  To increase the precision of the output results, it would be wise
;                     to zoom-in (both X and Y) on the points of interest.  Technically,
;                     the use of SPECPLOT.PRO and zooming-in may artificially increase
;                     the resolution of the data.  However, zooming-in should reduce the
;                     errors introduced by "shaky hands" or a particularly stubborn
;                     mouse.
;               3)  I have found it useful to use a linear Y-Axis scale as opposed to
;                     a logarithmic scale that is commonly used in these plots.  However,
;                     using a linear scale typically requires changing the Y-Axis range
;                     so the user can see the features of interest.
;               4)  Currently, the routine does not return valid values for the
;                     Z-Component of the data.  I am not sure if this is an issue
;                     with ctime.pro or my call to ctime.pro.  Eventually, I hope to
;                     correct this issue.
;
;   FUTURE PLANS:
;               1)  Fix the Z-Component output so it returns finite values associated
;                     with dynamic spectra plots.
;               2)  I plan to enhance the routine by introducing prompts that ask the
;                     user if they wish to change the X- and/or Y-axis range prior to
;                     selecting data points.
;               3)  Allow user to dynamically zoom-in and -out for both the X- and/or
;                     Y-axis so they need not call the routine multiple times to
;                     record the points they wish to over a large timespan.
;
;   CREATED:  03/03/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/03/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO t_get_values_from_plot,tp_name,NDATA=ndata,UNKNOWN=unknown,DATA_OUT=data_out

;;----------------------------------------------------------------------------------------
;; => Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define some prompt statements and error messages
no_tplot       = 'You must first load some data into TPLOT!'
no_plot        = 'You must first plot something in TPLOT!'
cur_prompt     = "Use cursor to select the point of interest"
notplot_mssg   = 'No TPLOT handles defined... no data will be returned!'
badinput_mssg  = 'Incorrect number of terms entered...'
badform_mssg   = 'Incorrect input format...'
badctime_mssg  = 'CTIME failed!'
;;----------------------------------------------------------------------------------------
;; => Make sure user loaded at least one TPLOT variable
;;----------------------------------------------------------------------------------------
tpn_all        = tnames()
IF (tpn_all[0] EQ '') THEN BEGIN
  MESSAGE,no_tplot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;; => Load common blocks
;;----------------------------------------------------------------------------------------
@tplot_com.pro
;COMMON times_dats, t
;; => Check that common blocks have been loaded already
test           = (SIZE(tplot_vars,/TYPE) NE 8)
IF (test) THEN BEGIN
  MESSAGE,no_tplot[0]+' [must load tplot_com.pro]',/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;; => Determine current settings and options
str_element,tplot_vars,      'OPTIONS.TRANGE',trange
str_element,tplot_vars, 'OPTIONS.TRANGE_FULL',trange_full
str_element,tplot_vars, 'SETTINGS.TRANGE_OLD',trange_old
str_element,tplot_vars, 'SETTINGS.TIME_SCALE',time_scale
str_element,tplot_vars,'SETTINGS.TIME_OFFSET',time_offset
str_element,tplot_vars,   'SETTINGS.X.CRANGE',time_xcrange
str_element,tplot_vars,    'OPTIONS.VARNAMES',plotted_names
;;----------------------------------------------------------------------------------------
;;  Make sure something is plotted
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(time_xcrange) EQ 0) OR (N_ELEMENTS(plotted_names) EQ 0)
IF (test) THEN BEGIN
  MESSAGE,no_plot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
n              = N_PARAMS()
IF (n[0] EQ 0) THEN BEGIN
  ;;  no input entered
  MESSAGE,badinput_mssg[0],/INFORMATIONAL,/CONTINUE
  ;;  use default = 1st plotted TPLOT handle
  tpname = tnames(plotted_names[0])
ENDIF ELSE BEGIN
  ;;  try using input TPLOT handle
  tpname = tnames(tp_name[0])
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Make sure a TPLOT handle was found
;;----------------------------------------------------------------------------------------
good = WHERE(tpname NE '',gd)
IF (gd EQ 0) THEN BEGIN
  ;;  No TPLOT handle was found
  MESSAGE,notplot_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF ELSE gnames = tpname[good[0]]
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
test           = (N_ELEMENTS(unknown) EQ 0) OR (KEYWORD_SET(unknown) NE 1)
IF (test) THEN multi_point = 0 ELSE multi_point = 1

test           = (N_ELEMENTS(ndata) EQ 0)
IF (test) THEN num_data = 1 ELSE num_data = LONG(ndata[0])

known_ndata    = (num_data GT 1)
;;----------------------------------------------------------------------------------------
;;  Loop if user wants to get multiple data points at once, otherwise perform one cycle
;;----------------------------------------------------------------------------------------
kind           = 0L
true           = 1
;;  Initialize values
x              = 0
y              = 0
z              = 0
struc          = 0
WHILE (true) DO BEGIN
  ;;  reset variables
  x0             = 0
  y0             = 0
  z0             = 0
  ;;----------------------------------------------------------------------------------
  ;;  Use cursor to select time ranges manually
  ;;----------------------------------------------------------------------------------
  ctime,x0,y0,z0,PROMPT=cur_prompt[0],/SECONDS,NPOINTS=1
  ;;--------------------------------------------------------------------------------------
  ;;  Check if user wants to return multiple points or a single point
  ;;--------------------------------------------------------------------------------------
  IF (known_ndata) THEN BEGIN
    ;;----------------------------------------------------------------------------------
    ;;  User specified they wanted to return a known # of points
    ;;----------------------------------------------------------------------------------
    ;;  Use cursor to select time ranges manually
    ctime,x0,y0,z0,PROMPT=cur_prompt[0],/SECONDS,NPOINTS=num_data[0]
    ;;  Check outputs
    nn     = num_data[0]
    test0  = (x0[0] EQ 0) OR ((SIZE(y0[0],/TYPE) LT 4) OR (SIZE(y0[0],/TYPE) GT 5))
    test1  = (N_ELEMENTS(x0) NE nn) OR (N_ELEMENTS(y0) NE nn) OR (N_ELEMENTS(z0) NE nn)
    test   = test0 OR test1
    IF (test) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Bad CTIME output => move on
      ;;----------------------------------------------------------------------------------
      MESSAGE,badctime_mssg[0],/INFORMATIONAL,/CONTINUE
      RETURN
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Define output arrays
      ;;----------------------------------------------------------------------------------
      x        = x0
      y        = y0
      z        = z0
      ;; => Sort
      sp       = SORT(x)
      x        = x[sp]
      y        = y[sp]
      z        = z[sp]
      ;;----------------------------------------------------------------------------------
      ;; => Define return structure and return to user
      ;;----------------------------------------------------------------------------------
      data_out = {X:x,Y:y,Z:z}
      ;; => Return to user
      RETURN
    ENDELSE
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Check if user wants to return multiple points
    ;;------------------------------------------------------------------------------------
    ;;  reset variables
    x0             = 0
    y0             = 0
    z0             = 0
    IF (multi_point) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Use cursor to select time ranges manually
      ;;----------------------------------------------------------------------------------
      ctime,x0,y0,z0,PROMPT=cur_prompt[0],/SECONDS,NPOINTS=1
      ;;----------------------------------------------------------------------------------
      ;;  User specified they wanted to return an unknown # of points, so check
      ;;----------------------------------------------------------------------------------
      read_out = ''
      info0    = "To get another data point 'y', else type 'n'."
      info1    = "To quit at any time type 'q'."
      mssg     = "Do you wish to get more data (y/n)?  "
      WHILE (read_out NE 'n' AND read_out NE 'y' AND read_out NE 'q') DO BEGIN
        PRINT, ""
        PRINT, info0[0]
        PRINT, info1[0]
        PRINT, ""
        READ,read_out,PROMPT=mssg
        PRINT, ""
        IF (read_out EQ 'debug') THEN STOP
      ENDWHILE
      ;;  make sure index has not exceeded 9999 and user wishes to continue
      true     = (kind LT 9999L) AND (read_out EQ 'y')
      IF (read_out EQ 'q') THEN true = 0  ;; user wishes to quit
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  User only wants to remove 1 interval
      ;;----------------------------------------------------------------------------------
      true     = 0
      ;;----------------------------------------------------------------------------------
      ;;  Use cursor to select time ranges manually
      ;;----------------------------------------------------------------------------------
      ctime,x0,y0,z0,PROMPT=cur_prompt[0],/SECONDS,NPOINTS=1
    ENDELSE
    ;;------------------------------------------------------------------------------------
    ;;  Check CTIME output
    ;;------------------------------------------------------------------------------------
    test = (x0[0] EQ 0) OR ((SIZE(y0[0],/TYPE) LT 4) OR (SIZE(y0[0],/TYPE) GT 5))
    IF (test) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Bad CTIME output => move on
      ;;----------------------------------------------------------------------------------
      MESSAGE,badctime_mssg[0]+' [2]',/INFORMATIONAL,/CONTINUE
      RETURN
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Append output arrays
      ;;----------------------------------------------------------------------------------
      IF (kind EQ 0) THEN BEGIN
        x  = x0[0]
        y  = y0[0]
        z  = z0[0]
      ENDIF ELSE BEGIN
        x  = [x0[0],x]
        y  = [y0[0],y]
        z  = [z0[0],z]
      ENDELSE
    ENDELSE
  ENDELSE
  ;;--------------------------------------------------------------------------------------
  ;;  increment index
  ;;--------------------------------------------------------------------------------------
  kind += 1L
ENDWHILE
;;----------------------------------------------------------------------------------------
;; => Sort
;;----------------------------------------------------------------------------------------
sp             = SORT(x)
x              = x[sp]
y              = y[sp]
z              = z[sp]
;;----------------------------------------------------------------------------------------
;; => Define return structure
;;----------------------------------------------------------------------------------------
data_out       = {X:x,Y:y,Z:z}
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END



;;----------------------------------------------------------------------------------------
;; => Get data
;;----------------------------------------------------------------------------------------
;get_data,gnames[0],DATA=temp_data,DLIM=def_lim,LIM=limits
;test_dq = (SIZE(temp_data,/TYPE) EQ 8)
;IF (test_dq) THEN BEGIN
;  ;;----------------------------------------------------------------------------------
;  ;;  DATA is defined
;  ;;----------------------------------------------------------------------------------
;  
;  IF (gd GT 0) THEN BEGIN
;    ;;  Get data for this 
;  ENDIF
;ENDIF ELSE BEGIN
;ENDELSE

;stop

;  IF (multi_point OR known_ndata) THEN BEGIN
;    IF (known_ndata) THEN BEGIN
;      ;;----------------------------------------------------------------------------------
;      ;;  User specified they wanted to return a known # of points
;      ;;----------------------------------------------------------------------------------
;      ;;  Use cursor to select time ranges manually
;      ctime,x0,y0,z0,PROMPT=cur_prompt[0],/SECONDS,NPOINTS=num_data[0]
;      ;;  make sure index has not exceeded the user specified value
;      true     = (kind LT num_data - 1L)
;    ENDIF ELSE BEGIN
