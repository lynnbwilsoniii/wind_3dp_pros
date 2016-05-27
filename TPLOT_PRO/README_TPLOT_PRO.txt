Last Modification =>  2008-06-23/22:24:09 UTC
;+
;FUNCTION:	cal_bsn2(sx,sy,sz,bx,by,bz,vmag,bow=bow)
;INPUT:
;	sx,sy,sz:	x, y, and z coodinates of spacecraft in GSE with
;			units of Re
;	bx,by,bz:	magnetic field direction
;OPTIONS:
;	bow:	structure containing {L,ecc,x0}
;		L:	standoff parameter with units of Re
;		ecc:	eccentricity of shock
;		x0:	focus location in Re
;
;       hyperbolic bow shock, see JGR 1981, p.11401, Slavin Fig.7
;       r = L/(1+ecc*cos(theta))
;       1 = (x-x0-c)^2/a^2 - (y^2+z^2)/b^2
;       default L = b^2/a = 23.5
;               ecc = c/a = 1.15
;               xoffset= 3
;               c = (a^2 + b^2)^.5 = L*e/(e^2-1) = 83.8
;               a = L/(e^2-1) = 72.87
;               b = L/(e^2-1)^.5 = 41.38
;PURPOSE:
;	Function returns a structure that describes the interaction of a B-field
;	with a hyperboloid bow shock model.
;	Returned structure elements include:
;		th_bn: the angle (in degrees) between shock normal and the
;			field line that passes through the spacecraft
;		l1: the distance along the field line to the shock
;		l2: the distance from a point that is missdist from the
;			spacecraft in x to the tangent point
;		d,m: the distance along x from the spacecraft to a point
;			where the B field line would be tangent to the
;			bow shock.  A postive d means that the field
;			line has already intersected the shock.  A positive
;			m indicates that the field line has not yet
;			intersected the shock.
;		intpos: position vector in GSE of point where field line
;			originating at spacecraft intersects bow shock
;	All distances are in Re.
;CREATED BY:
;	P. Schroeder
;LAST MODIFICATION: 
;       L. Winslow 9/15/00
;LAST MODIFICATION: %W% %E%
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;NAME:                  crosshairs
;PURPOSE:
;Display crosshairs on the plot window, display the data coordinates of the
;cursor position on the plot, and return the coordinates of clicked points.
;			Use the mouse buttons to control operation:
;			1: Record and print a point
;			2: Delete the previously recorded point
;			3: Quit.
;CALLING SEQUENCE:      crosshairs,x,y
;INPUTS:                x,y:  set to named variables to return the data
;                             coordinates of the cursor position where mouse
;                             button 1 was pressed.
;
;KEYWORD PARAMETERS:    
;	COLOR:  set to a scalar byte to change the color of the crosshairs.
;		note:  you will not get the color you ask for.  it's the nature 
;		of XOR graphics.  could be useful to change colors though.
;	LEGEND: set a position for the legend, in data coords.
;	DOT_CURSOR:  change the cursor to a dot.  it's smaller and makes seeing
;		the data easier.  warning:  will reset the cursor to crosshairs
;		after quitting.  if you had set your own cursor (changed from
;		the default) it'll be replaced.
;	FIX:	if crosshairs crashes  (if you Control-C out of it) then 
;		you probabaly want to call crosshairs,/fix
;		all it does is calls:  device,set_graphics=3,/cursor_cross
;		but do you want to remember that line?
;		FIX repairs the changes to the X device that crosshairs made.
;	SILENT: don't print clicked points
;       NOLEGEND:  don't display the legend
;OUTPUTS:       prints clicked data points to the terminal, prints the current 
;		cursor position on the graphics window (or last position before
;		leaving the window)
;SIDE EFFECTS:          can mess up your display.  use crosshairs,/fix to fix.
;			can leave junk on your plot.  not recommended for use
;			if you intend to call tvrd() before reploting.
;LAST MODIFICATION:     @(#)crosshairs.pro	1.5 98/07/31
;CREATED BY:            Frank V. Marcoline
;NOTES:			Inspired by IDL's box_cursor.pro
;-


Last Modification =>  2009-09-21/15:37:17 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   ctime_get_exact_data.pro
;  PURPOSE  :   Get a data structure for ctime.  if var is a string or a strarr,
;                 create a structure of data structures.  Get the new values for 
;                 hx and hy, the crosshairs position.  Also check the spec option.
;                 ctime need never see the actual data structures.
;                 
;                 All work is done with pointers to reduce data duplication 
;                 and increase speed.
;
;  CALLED BY: 
;               ctime.pro
;
;  CALLS:
;               tplot_com.pro
;               get_data.pro
;               str_element.pro
;               dimen2
;               ndimen
;               data_to_normal
;               
;  COMMON BLOCKS: 
;               ctime_common.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               VAR     :  TPLOT variable name
;               V       :  V-Value at desired time
;               T       :  Time at which program is getting data
;               PAN     :  A scalar defining the panel number
;               HX      :  
;               HY      :  
;               SUBVAR  :  
;               YIND    :  
;               YIND2   :  
;               Z       :  Z-Value at desired time
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               SPEC    :  If set, tells program that plot is a spec plot
;               DTYPE   :  Named variable to hold the data type value.  These values are:
;                            0  :  Undefined data type
;                            1  :  Normal data in x,y format
;                            2  :  Structure-type data in time,y1,y2,etc. format
;                            3  :  An array of tplot variable names
;               LOAD    :  If set, loads data in the new plot panel
;
;   CHANGED:  1)  NA                                [MM/DD/YYYY   v1.0.29]
;             2)  Rewrote and organized/cleaned up  [06/04/2009   v1.0.30]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson & Frank Marcoline
;    LAST MODIFIED:  06/04/2009   v1.0.30
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   time_round.pro
;  PURPOSE  :   This program determines the granularity of the time string returned.
;
;  CALLED BY: 
;               ctime.pro
;
;  CALLS:
;               interp.pro
;               time_double.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               TIME       :  String of times ['YYYY-MM-DD/HH:MM:SS.sss']
;               RES        :  Resolution of time data
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               PRECISION  :  A scalar defining the decimal places beyond seconds to use
;               DAYS       :  If set, the resolution is in # of days
;               HOURS      :  " " hours
;               MINUTES    :  " " minutes
;               SECONDS    :  " " seconds
;
;   CHANGED:  1)  Rewrote and organized/cleaned up  [06/04/2009   v1.0.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson & Frank Marcoline
;    LAST MODIFIED:  06/04/2009   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   ctime.pro
;  PURPOSE  :   Interactively uses the cursor to select a time (or times) for TPLOT
;
;  CALLED BY: 
;               tplot.pro
;
;  CALLS:
;               tplot_com.pro
;               data_type.pro
;               normal_to_data.pro
;               time_string.pro
;               append_array.pro
;               ctime_get_exact_data.pro
;               time_round.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               TIME     :  Named variable in which to return the selected time (seconds
;                             since Jan 1st, 1970)
;               Y        :  Named variable in which to return the y value
;               Z        :  Named variable in which to return the z value
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               APPEND   :  If set, points are appended to the input arrays, instead
;                             of overwriting the old values.
;               EXACT    :  Get the time,y, and (if applicable) z values from the data 
;                             arrays.  If on a multi-line plot, get the value from the 
;                             line closest to the cursor along y.
;               NPOINTS  :  Max number of points to return
;               INDS     :  Return the indices into the data arrays for the points 
;                             nearest the recorded times to this named variable.
;               VINDS    :  Return the second dimension of the v or y array.
;                             Thus  TIME(i) is  data.x(INDS(i))           and
;                               Y(i)    is  data.y(INDS(i),VINDS(i))  and
;                               V(i)    is  data.v(VINDS(i)) or data.v(INDS(i),VINDS(i))
;                             for get_data,VNAME(i),data=data,INDS=INDS,VINDS=VINDS             
;               PANEL    :  Set to a named variable to return an array of tplot 
;                             panel numbers coresponding to the variables points 
;                             were chosen from.
;               COUNTS   :  
;               VNAME    :  Set to a named variable to return an array of tplot 
;                             variable names, cooresponding to the variables points 
;                             were chosen from.
;               PROMPT   :  Optional prompt string
;               PSYM     :  If set to a psym number, the cooresponding psym is plotted
;                             at selected points
;               SILENT   :  Do not print data point information
;               NOSHOW   :  Do not show the plot window.
;               DEBUG    :  Avoids default error handling.  Useful for debugging.
;               COLOR    :  An alternative color for the crosshairs.  
;                             0<=color<=!d.n_colors-1
;               SLEEP    :  Sleep time (seconds) between polling the cursor for events.
;                             Defaults to 0.1 seconds.  Increasing SLEEP will slow 
;                             ctime down, but will prevent ctime from monopolizing 
;                             cpu time.
;               DAYS     :  Sets time granularity to days
;               HOURS    :  Sets time granularity to hours
;               MINUTES  :  Sets time granularity to minutes
;               SECONDS  :  Sets time granularity to seconds
;                             For example with MINUTES=1, CTIME will find the nearest
;                               minute to cursor position.
;
;  NOTES:       
;               If you use the keyword EXACT, ctime may run noticeablly slower.
;                 Reduce the number of time you cross panels, especially with
;                 tplots of large data sets.
;
;****WARNING!****
;  If ctime crashes, you may need to call:
;  IDL> device,set_graph=3,/cursor_crosshair
;
;   CHANGED:  1)  ?? Davin changed something                       [11/01/2002   v1.0.44]
;             2)  Rewrote and organized/cleaned up                 [06/04/2009   v1.0.45]
;             3)  Fixed issue of allocating X-Window on iMac       [08/10/2009   v1.1.0]
;             4)  Second attempt to fix issue of allocating X-Window on iMac...
;                                                                  [09/21/2009   v1.2.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson & Frank Marcoline
;    LAST MODIFIED:  09/21/2009   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE:	cuts
;PURPOSE:	to show x cuts or y cuts of a 
;		"tplot" spectrogram
;INPUT:		none
;KEYWORDS:	name:	name of the variable you want cuts for
;
;CREATED BY:	Peter Schroeder
;LAST MODIFICATION:	@(#)cuts.pro	1.6 98/01/29
;
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;*****************************************************************************
;FUNCTION: A = data_cut(name, t)
;PURPOSE:  Interpolates data from a data structure.
;INPUT:
;  name:  Either a data structure or a string that can be associated with
;      a data structure.  (see "get_data" routine)
;      the data structure must contain the element tags:  "x" and "y"
;      the y array may be multi dimensional.
;  t:   (scalar or array)  x-values for interpolated quantities.
;RETURN VALUE:
;  a data array: the first dimension is the dimension of t
;                the second dimension is the dimension of name
;
; NOTE!!  keyword options have been temporarily removed!!!!
;
;KEYWORDS:
;  EXTRAPOLATE:  Controls interpolation of the ends of the data. Effects:
;                0:  Default action.  Set new y data to NAN or to MISSING.
;                1:  Extend the endpoints horizontally.
;                2:  Extrapolate the ends.  If the range of 't' is
;                    significantly larger than the old time range, the ends
;                    are likely to blow up.
;  INTERP_GAP:   Determines if points should be interpolated between data gaps,
;                together with the GAP_DIST.  IF the data gap > GAP_DIST, 
;                follow the action of INTERP_GAP
;                0:  Default action.  Set y data to MISSING.
;                1:  Interpolate gaps
;  GAP_DIST:     Determines the size of a data gap above which interpolation
;                is regulated by INTERP_GAP.
;                Default value is 5, in units of the average time interval:
;                delta_t = (t(end)-t(start)/number of data points)
;  MISSING:      Value to set the new y data to for data gaps.  Default is NAN.
;
;CREATED BY:	 Davin Larson
;LAST MODIFICATION:     @(#)data_cut.pro	1.19 02/04/17
;                Added the four keywords. (fvm 9/27/95)
;
;    LAST MODIFIED:  06/08/2008
;    MODIFIED BY: Lynn B. Wilson III
;
;    CHANGED        : added GTIMES keyword so data_cut.pro would return the times
;                      associated with the data it returned
;
;*****************************************************************************
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;Procedure:	diag_p, p, n, t=t, s=s
;INPUT:	
;	p:	pressure array of n by 6 or a string (e.g., 'p_3d_el')
;	n:	density array of n or a string (e.g., 'n_3d_el')
;PURPOSE:
;	Returns the temperature: [Tpara,Tperp,Tperp], and 
;		the unit symmetry axis s. Also returns 'T_diag' and 'S.axis'
;		for plotting purposes.  
;
;CREATED BY:
;	Tai Phan	95-09-28
;LAST MODIFICATION:
;	95-9-29		Tai Phan
;-


Last Modification =>  2009-10-22/18:22:45 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   draw_color_scale.pro
;  PURPOSE  :   Creates a color bar for plotting spectra or other images.
;
;  CALLED BY:   
;               specplot.pro
;
;  CALLS:
;               bytescale.pro
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
;               RANGE     :  2-Element array defining the range of the data values
;               BRANGE    :  2-Element array defining the color map values that the
;                              data scale spans
;               LOG       :  If set, scale is logarithmic
;               CHARSIZE  :  Character size to be used for scale
;               YTICKS    :  IDL keyword for plotting routines like PLOT.PRO
;               POSITION  :  4-Element Float array of color bar position [x0,y0,x1,y1]
;               OFFSET    :  2-Element array giving the offsets from the right side of
;                              the current plot for calculating the x0 and x1 positions
;                              of the color scale. In device units. Ignored if
;                              POSITION keyword is set.
;               TITLE     :  String title for color bar
;
;   CHANGED:  1)  Davin's last modification               [06/25/2001   v1.1.16]
;             2)  Updated man page and rewrote            [06/21/2009   v1.2.0]
;             3)  Fixed tick label issue                  [08/13/2009   v1.2.1]
;             3)  Fixed Y-Axis issue                      [10/22/2009   v1.2.2]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  10/22/2009   v1.2.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE:  edit3dbins,dat,bins
;PURPOSE:   Interactive procedure to produce a bin array for selectively 
;    turning angle bins on and off.  Works on a 3d structure (see 
;    "3D_STRUCTURE" for more info)
;
;INPUT:
;   dat:  3d data structure.  (will not be altered)
;   bins:  a named variable in which to return the results.
;KEYWORDS:
;   EBINS:     Specifies energy bins to plot.
;   SUM_EBINS: Specifies how many bins to sum, starting with EBINS.  If
;              SUM_EBINS is a scaler, that number of bins is summed for
;              each bin in EBINS.  If SUM_EBINS is an array, then each
;              array element will hold the number of bins to sum starting
;              at each bin in EBINS.  In the array case, EBINS and SUM_EBINS
;              must have the same number of elements.
;SEE ALSO:  "PLOT3D" and "PLOT3D_OPTIONS"
;CREATED BY:	Davin Larson
;FILE: edit3dbins.pro
;VERSION:  1.14
;LAST MODIFICATION: 98/01/16
;-


Last Modification =>  2009-08-16/19:28:31 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   find_handle.pro
;  PURPOSE  :   Returns the index associated with a string name.  This function is 
;                 used by the "TPLOT" routines.  If the tag is not found, the program
;                 returns a zero.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME  :  [String] A defined TPLOT variable name with associated spectra
;                          data separated by pitch-angle as TPLOT variables
;                          [e.g. 'nelb_pads']
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Davin Larson changed something...        [02/26/1999   v1.0.14]
;             2)  Re-wrote and cleaned up                  [08/16/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/16/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE makegap,dg,x,y
;PURPOSE:
;   Creates data gaps (by inserting NaN) when the time between data points is
;   larger than a value either passed in by the user or calculated to a
;   default.
;INPUT:
;   dg: If dg is positive, it is the maximum allowed time gap.  Any time gaps
;	greater than dg will be treated as data gaps.  If dg is negative,
;	the procedure will calculate a default value for dg of 20 times the
;	the smallest time gap in the time series.
;    x: The time array.
;    y: The data array.
;KEYWORDS:
;    v: Optional third dimension array.
;    dy: Optional uncertainty in y.
;CREATED BY: Peter Schroeder
;LAST MODIFIED:	@(#)makegap.pro	1.2 98/02/18
;-


Last Modification =>  2009-09-28/13:37:36 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   mplot.pro
;  PURPOSE  :   General purpose procedure used to make multi-line plots.
;
;  CALLED BY: 
;               tplot.pro
;
;  CALLS:
;               str_element.pro
;               extract_tags.pro
;               makegap.pro
;               dimen1.pro
;               dimen2.pro
;               ndimen.pro
;               minmax.pro
;               bytescale.pro
;               my_box.pro
;               get_colors.pro
;               oplot_err.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               XT           :  [M,(1 or 2)]-Element array of X-Values (typically time)
;               YT           :  [M,(1 or 2)]-Element array of Y-Values (typically data)
;               DY           :  Error bars for YT if desired (optional)
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               OVERPLOT     :  If set, plots over already existing panel
;               OPLOT        :  Same as OVERPLOT
;               LABELS       :  N-Element string array of data labels
;               LABPOS       :  N-Element array of data positions
;               LABFLAG      :  Integer, flag that controls label positioning
;                                 -1 : labels placed in reverse order.
;                                  0 : No labels.
;                                  1 : labels spaced equally.
;                                  2 : labels placed according to data.
;                                  3 : labels placed according to LABPOS.
;               COLORS       :  N-Element array of colors used for each curve.
;               BINS         :  Flag array specifying which channels to plot.
;               DATA         :  A structure that contains the elements 'x', 'y' ['dy'].
;                                 This is an alternative way of inputing the data  
;                                 (used by "TPLOT").
;               NOERRORBARS  :  
;               ERRORTHRESH  :  
;               NOXLAB       :  If set, then xlabel tick marks are supressed.
;               NOCOLOR      :  If set, then no colors are used to create plot.
;               LIMITS       :  Structure containing any combination of the 
;                                 following elements:
;                                 1)  ALL PLOT/OPLOT keywords  
;                                     (ie. PSYM,SYMSIZE,LINESTYLE,COLOR,etc.)
;                                 2)  ALL MPLOT keywords
;                                 3)  NSUMS:       N-Element array of NSUM keywords.
;                                 4)  LINESTYLES:  N-Element array of linestyles.
;
;NOTES: 
;    The values of all the keywords can also be put in the limits structure or
;    in the data structure using the full keyword as the tag name.
;    The structure value will overide the keyword value.
;
;   CHANGED:  1)  ?? Davin changed something                       [11/01/2002   v1.0.43]
;             2)  No real changes                                  [03/26/2008   v1.0.44]
;             3)  Rewrote and altered syntax to avoid bad Y-Ranges [06/02/2009   v2.0.0]
;             4)  Fixed Y-Range estimates when < 4 pts in window   [06/03/2009   v2.0.1]
;             5)  Now calls my_box.pro                             [06/03/2009   v2.0.2]
;             6)  Fixed issue when using keyword OVERPLOT          [09/04/2009   v2.0.3]
;             7)  Fixed typo when using keyword OVERPLOT           [09/16/2009   v2.0.4]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/16/2009   v2.0.4
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE: mult_data, n1,n2
;PURPOSE:
;   Creates a tplot variable that is the product of two other tplot variables.
;INPUT: n1,n2  tplot variable names (strings)
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;FUNCTION:	normal_to_data
;PURPOSE:	convert normal coordinates to data coordinates
;INPUT:
;	normv:	normal coordinates
;	s:	!AXIS structure
;KEYWORDS:
;	none
;
;CREATED BY: 	Davin Larson
;LAST MODIFICATION: 	@(#)normal_to_data.pro	1.5 98/08/02
;
;NOTE:	I think this procedure is superceded by convert_coord.
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;FUNCTION:  omni3d
;PURPOSE:  produces an omnidirectional spectrum structure by summing
; over the non-zero bins in the keyword bins.
; this structure can be plotted with "spec3d"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)omni3d.pro	1.12 02/04/17
;
; WARNING:  This is a very crude structure; use at your own risk.
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE:   options, str, tag_name, value
;PURPOSE:
;  Add (or change) an element of a structure.
;  This routine is useful for changing plotting options for tplot, but can also
;  be used for creating limit structures for other routines such as "SPEC3D"
;  or "CONT2D"
;  
;INPUT: 
;  str:
;    Case 1:  String (or array of strings)  
;       The limit structure associated with the "TPLOT" handle name is altered.
;       Warning!  wildcards accepted!  "*" will change ALL tplot quantities!
;    Case 2:  Number (or array of numbers)
;       The limit structure for the given "TPLOT" quantity is altered.  The 
;       number/name association is given by "TPLOT_NAMES"
;    Case 3:  Structure or not set (undefined or zero)
;       Structure to be created, added to, or changed.
;  tag_name:     string,  tag name for value.
;  value:    (any type or dimension) value of new element.
;NOTES:
;  if VALUE is undefined then it will be DELETED from the structure.
;  if TAG_NAME is undefined, then the entire limit structure is deleted.
;   
;KEYWORDS:
;  DEF:  If set, modify the default limits structure rather than the
;	    regular limits structure (tplot variables only).
;SEE ALSO:
;  "GET_DATA","STORE_DATA", "TPLOT", "XLIM", "YLIM", "ZLIM", "STR_ELEMENT"
;
;CREATED BY:	Jasper Halekas
;Modified by:   Davin Larson
;LAST MODIFICATION:	@(#)options.pro	1.19 99/04/07
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
; PROCECURE:	pmplot
;
; PURPOSE:	Used for making log y-axis plots.  Preformats data for
;		use with "mplot".  Plots negative data in red and positive
;		data in green.
;
; KEYWORDS:
;    DATA:     A structure that contains the elements 'x', 'y' ['dy'].  This 
;       is an alternative way of inputing the data  (used by "TPLOT").
;    LIMITS:   Structure containing any combination of the following elements:
;          ALL PLOT/OPLOT keywords  (ie. PSYM,SYMSIZE,LINESTYLE,COLOR,etc.)
;          ALL PMPLOT keywords
;          NSUMS:   array of NSUM keywords.
;          LINESTYLES:  array of linestyles.
;    LABELS:  array of text labels.
;    LABPOS:  array of positions for LABELS.
;    LABFLAG: integer, flag that controls label positioning.
;             -1: labels placed in reverse order.
;              0: No labels.
;              1: labels spaced equally.
;              2: labels placed according to data.
;              3: labels placed according to LABPOS.
;    BINS:    flag array specifying which channels to plot.
;    OVERPLOT: If non-zero then data is plotted over last plot.
;    NOXLAB:   if non-zero then xlabel tick marks are supressed.
;    COLORS:   array of colors used for each curve.
;    NOCOLOR:  do not use color when creating plot.
;NOTES: 
;    The values of all the keywords can also be put in the limits structure or
;    in the data structure using the full keyword as the tag name.
;    The structure value will overide the keyword value.
;
;LAST MODIFIED: @(#)pmplot.pro	1.4 02/04/17
;
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;NAME:                  split_vec
;PURPOSE:               
;                       take a stored vector like 'Vp' and create stored vectors 'Vp_x','Vp_y','Vp_z'
;CALLING SEQUENCE:      split_vec,names
;INPUTS:                names: string or strarr, elements are data handle names
;OPTIONAL INPUTS:       
;KEYWORD PARAMETERS:    polar: Use '_mag', '_th', and '_phi'
;			titles: an array of titles to use instead of the default or polar sufficies
;OUTPUTS:               
;OPTIONAL OUTPUTS:      
;COMMON BLOCKS:         
;SIDE EFFECTS:          
;RESTRICTIONS:          
;EXAMPLE:               
;LAST MODIFICATION:     %W% %E%
;CREATED BY:            Frank V. Marcoline
;-


Last Modification =>  2009-08-12/16:53:47 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   store_data.pro
;  PURPOSE  :   Store time series structures in static memory for later retrieval by the
;                 tplot routine.  Three structures can be associated with the string 
;                 'name':  a data structure (DATA) that typically contains the x and
;                 y data. A default limits structure (DLIMITS) and a user limits 
;                 structure (LIMITS) that will typically contain user defined 
;                 limits and options (typically plot and oplot keywords).  The 
;                 data structure and the default limits structure will be over written
;                 each time a new data set is loaded.  The limit structure is not 
;                 over-written.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               find_handle.pro
;               tag_names_r.pro
;               array_union.pro
;               extract_tags.pro
;               minmax.pro
;               store_data.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME     :  Scalar string to be associated with the data structure
;                             and/or plot limit structure.  One can enter an index too.
;                             [Note:  NAME should NOT contain spaces or the characters
;                                      '*' and '?']
;
;  EXAMPLES:    
;               store_data,name,DATA=data,LIMITS=limits,DLIMITS=dlimits,$
;                               NEWNAME=newname,DELETE=delete
;
;  KEYWORDS:    
;               DATA     :  Set to a variable that contains the data structure to store
;               LIMITS   :  A structure containing the plot limit structure
;               DLIMITS  :  A structure containing the default plot limit structure
;               NEWNAME  :  Scalar string used to define new TPLOT handle(name)
;               MIN      :  If set, values less than this well be set to NaNs
;               MAX      :  If set, values greater than this well be set to NaNs
;               DELETE   :  Set to an array of TPLOT handles (or indices) to be deleted
;                             from the TPLOT list (common block)
;               VERBOSE  :  If set, program prints out information about the 
;                             TPLOT variable
;               NOSTRSW  :  If set, do not transpose multidimensional data arrays in
;                             structures [Default = transpose them]
;               DELALL   :  Set to a 2-element array of start and end TPLOT indices to 
;                             delete from the TPLOT list (common block)
;
;   NOTES:
;
;  SEE ALSO:
;               get_data.pro
;               tplot_names.pro
;               tplot.pro
;               options.pro
;
;   CHANGED:  1)  Peter Schroeder modified something...      [04/17/2002   v1.0.44]
;             2)  Added keyword:  DELALL                     [04/13/2008   v1.0.45]
;             3)  Re-wrote and cleaned up                    [08/11/2009   v1.1.0]
;             4)  Fixed syntax error produced when re-writing program
;                                                            [08/12/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/12/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-10-08/18:01:36 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   time_bar.pro
;  PURPOSE  :   Plots vertical lines at specific times on an existing tplot panel.
;
;  CALLED BY:   NA
;
;  CALLS:
;               tplot_com.pro
;               time_double.pro
;               str_element.pro
;               time_string.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               T1         :  M-Element array of Unix times (seconds since Jan, 1st 1970)
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               COLOR      :  N-Element byte array of color values
;               LINESTYLE  :  N-Element integer array of line styles
;               THICK      :  N-Element integer array of line thickness values
;               VERBOSE    :  If set, print more error messages (??)
;               VARNAME    :  Set to TPLOT name for which vertical lines will be plotted
;                               else, lines plot over all plots
;               BETWEEN    :  2-Element string array of TPLOT names specifying the plots
;                               between which to plot a vertical line
;               TRANSIENT  :  Called once, plots a time bar, twice erases time bar
;                                Note:  1) all other keywords except VERBOSE
;                                be the same for both calls. 2) COLOR will most
;                                likely not come out what you ask for, but
;                                since it's transient anyway, shouldn't matter.
;
;   CHANGED:  1)  Created by Frank V. Marcoline   [??/??/????   v1.0.0]
;             2)  Modified by Frank V. Marcoline  [01/21/1999   v1.0.9]
;             3)  Rewrote Program (no functional changes, just cleaned up)
;                                                 [04/20/2009   v2.0.0]
;             4)  Fixed syntax error              [04/22/2009   v2.0.1]
;             5)  Changed to allow for multiple TPLOT names upon input with keyword
;                   VARNAME                       [06/02/2009   v2.0.2]
;             6)  Updated man page                [06/17/2009   v2.1.0]
;             7)  Fixed an issue regarding un-sorted VARNAME inputs
;                                                 [10/08/2008   v2.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Frank V. Marcoline
;    LAST MODIFIED:  10/08/2008   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;FUNCTION:  timerange
;PURPOSE:	To get timespan from tplot_com or by using timespan, if 
;		tplot time range not set.
;INPUT:		
;	tr (optional)
;KEYWORDS:	
;	none
;RETURNS:
;    two element time range vector.  (double)
;
;SEE ALSO:	"timespan"
;REPLACES:  "get_timespan"
;CREATED BY:	Davin Larson
;
;-


Last Modification =>  2010-12-07/15:19:06 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   timespan.pro
;  PURPOSE  :   Define a time span for the "tplot" routine.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               time_double.pro
;               str_element.pro
;               time_string.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               T1  :  Scalar defining the start time in formats accepted by 
;                        time_struct.pro
;               DT  :  Scalar defining the duration of the time span
;                        [Default:  days]
;
;  EXAMPLES:    
;               timespan, '1995-06-19'
;               
;
;  KEYWORDS:    
;               DAYS       :  If set, the resolution of DT is in # of days
;               HOURS      :  " " hours
;               MINUTES    :  " " minutes
;               SECONDS    :  " " seconds
;
;   CHANGED:  1)  ?? Davin changed something                       [06/04/1997   v1.0.14]
;             2)  Re-wrote and cleaned up                          [12/07/2010   v1.1.0]
;
;   NOTES:      
;               1)  See also time_struct.pro, time_double.pro, or time_string.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  12/07/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-12-07/15:17:14 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   tlimit.pro
;  PURPOSE  :   defines time range for "tplot"
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               ctime.pro
;               gettime.pro
;               wi.pro
;               tplot.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               D1  :  Scalar defining the start time in formats accepted by 
;                        time_struct.pro
;               D2  :  Scalar defining the end time in formats accepted by 
;                        time_struct.pro
;               ** both inputs are optional if TPLOT window open **
;
;  EXAMPLES:    
;               tlimit                     ; Use the cursor
;               tlimit,'12:30','14:30'
;               tlimit, 12.5, 14.5
;               tlimit,'1995-04-05/12:30:00','1995-04-07/14:30:00'
;               tlimit,t,t+3600            ; t must be set previously
;               tlimit,/FULL               ; full limits
;               tlimit,/LAST               ; previous limits
;
;  KEYWORDS:    
;               DAYS       :  If set, the resolution is in # of days
;               HOURS      :  " " hours
;               MINUTES    :  " " minutes
;               SECONDS    :  " " seconds
;               FULL       :  If set, program resets current TPLOT window to the full
;                               time range stored in the TPLOT common blocks
;               LAST       :  If set, program resets current TPLOT window to the last
;                               time range stored in the TPLOT common blocks
;               ZOOM       :  Scalar fraction defining the fractional width of the 
;                               current time range to use for new window
;               REFDATE    :  String reference date for time series ['YYYY-MM-DD']
;               OLD_TVARS  :  Use this to pass an existing tplot_vars structure to
;                               override the one in the tplot_com common block.
;               NEW_TVARS  :  Returns the tplot_vars structure for the plot created.  
;                               Set aside the structure so that it may be restored 
;                               using the OLD_TVARS keyword later. This structure 
;                               includes information about various TPLOT options and 
;                               settings and can be used to recreates a plot.
;               WINDOW     :  Window to be used for all time plots.  If set to 
;                               -1, then the current window is used.
;
;   CHANGED:  1)  ?? Davin changed something                       [08/06/1998   v1.0.26]
;             2)  Re-wrote and cleaned up                          [12/07/2010   v1.1.0]
;
;   NOTES:      
;               1)  tplot must be called first
;               2)  See also time_struct.pro, time_double.pro, or time_string.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  12/07/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-08/19:09:02 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   tnames.pro
;  PURPOSE  :   Returns an array of "TPLOT" names specified by the input filters.  
;                 This routine accepts wildcard characters.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               strfilter.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               S            :  Scalar match string (i.e. '*B3*')
;               N            :  Scalar defining the number of matched strings
;
;  EXAMPLES:    
;               nam = tnames('wi*')
;
;  KEYWORDS:    
;               INDEX        :  Set to a named variable to return the indices of the
;                                 TPLOT names desired/returned
;               ALL          :  If set, all TPLOT names are returned
;               TPLOT        :  If set, all TPLOT names are returned
;               CREATE_TIME  :  Set to a named variable to return the times in which
;                                 the TPLOT variables were created
;               TRANGE       :  Set to a named variable to return the time ranges
;                                 of the TPLOT variables in question
;               DTYPE        :  Set to a named variable to return the data types of
;                                 the TPLOT variables in question
;               DATAQUANTS   :  If set, then the entire array of current stored TPLOT 
;                                 data quantities is returned
;
;   CHANGED:  1)  Davin Larson changed something...        [11/01/2002   v1.0.8]
;             2)  Re-wrote and cleaned up                  [08/16/2009   v1.1.0]
;             3)  Fixed a typo in man page                 [08/19/2009   v1.1.1]
;             4)  THEMIS software update includes:
;                 a)  Altered syntax with TPLOT keyword handling
;                 b)  Forced ind to be a scalar if only 1 element
;                 c)  Added keyword:  DATAQUANTS
;                                                          [09/08/2009   v1.2.0]
;
;   CREATED:  Feb 1999
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/08/2009   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-10-01/12:24:51 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   tplot.pro
;  PURPOSE  :   Creates (a) time series plot(s) of user defined quantities stored as
;                 pointer-heap variables in IDL.  The variables have string and
;                 integer tags associated with them allowing them to be called from
;                 multiple places.
;
;  CALLED BY:   NA
;
;  CALLS:
;               tplot_com.pro
;               printdat.pro
;               tplot_options.pro
;               time_double.pro
;               extract_tags.pro
;               ctime.pro
;               tnames.pro
;               str_element.pro
;               get_data.pro
;               data_type.pro
;               ndimen.pro
;               plot_positions.pro
;               minmax.pro
;               time_ticks.pro
;               data_cut.pro
;               timetick.pro
;               time_string.pro
;               box.pro
;               get_ylimits.pro
;               specplot.pro
;               mplot.pro
;
;  REQUIRES:  
;               Data must be stored as pointers in IDL in the correct format for this
;                 routine to work.  Try running "_GET_EXAMPLE_DAT" for a test.
;
;  INPUT:
;               DATANAMES  :  A string of space separated datanames [wildcard expansion 
;                               is supported].  If omitted, the most recent data values
;                               are used instead.  Each name MUST be associated with
;                               a TPLOT quantity [see store_data.pro and get_data.pro].
;                               This program accepts integers as well which can be 
;                               observed by running tplot_names.pro from the command
;                               line to see the names and numbers associated with
;                               each TPLOT quantity.
;
;  EXAMPLES:
;               **  => [after running _get_example_dat.pro] <=  **
;               tplot,'amp slp flx2'    ; => Plots the named quantities
;           =============================================================
;           **  =>   tplot,['amp','slp','flx2'] OR tplot,[1,2,4]   <=  **
;           =============================================================
;               tplot,'flx1',/ADD_VAR   ; => Adds the quantity to the TPLOT quantities
;               tplot                   ; => Re-plot the last plot
;               tplot,VAR_LABEL=['alt'] ; => Put Distance labels at bottom of plot
;               ;-------------------------------------------------------------------------
;               ; => To get a list of the TPLOT names, do:
;               ;-------------------------------------------------------------------------
;               tplot_names,NAMES=names   ; **  => same as names = tnames()
;               tplot,names[0:2]          ; => Plots 'amp','slp', and 'flx1'
;               ;-------------------------------------------------------------------------
;               ; => To see more examples, look at file:  _tplot_example.pro
;               ;-------------------------------------------------------------------------
;
;  KEYWORDS:  
;               WINDOW     :  Window to be used for all time plots.  If set to 
;                               -1, then the current window is used.
;               NOCOLOR    :  Set this to produce plot without color.
;               VERSION    :  Must be 1,2,3, or 4 (Default=3) [Uses a different labeling]
;               OPLOT      :  Will not erase the previous screen if set.
;               OVERPLOT   :  Will not erase the previous screen if set.
;               TITLE      :  A string to be used for the title. 
;                               [Remembered for future plots.]
;               LASTVAR    :  Set this variable to plot the previous variables 
;                               plotted in a TPLOT window.
;               ADD_VAR    :  Set this variable to add datanames to the previous plot.
;                               If set to 1, the new panels will appear at the top 
;                               (position 1) of the plot.  If set to 2, they will be 
;                               inserted directly after the first panel and so on.  Set 
;                               this to a value greater than the existing number of 
;                               panels in your tplot window to add panels to the bottom 
;                               of the plot.
;               REFDATE    :  String reference date for time series ['YYYY-MM-DD']
;               VAR_LABEL  :  String [array]; Variable(s) used for putting labels along
;                               the bottom. This allows quantities such as altitude to 
;                               be labeled.
;               OPTIONS    :  A TPLOT structure that can contain keywords for the 
;                               IDL built-in PLOT.PRO
;               T_OFFSET   :  A named variable to be returned to the user containing the
;                               Unix time offset from Jan 1st, 1970 (seconds)
;               TRANGE     :  2-Element array of Unix times specifying the time range
;               NAMES      :  The names of the tplot variables that are plotted.
;               PICK       :  If set, user can define desired panels to plot with mouse
;               NEW_TVARS  :  Returns the tplot_vars structure for the plot created.  
;                               Set aside the structure so that it may be restored 
;                               using the OLD_TVARS keyword later. This structure 
;                               includes information about various TPLOT options and 
;                               settings and can be used to recreates a plot.
;               OLD_TVARS  :  Use this to pass an existing tplot_vars structure to
;                               override the one in the tplot_com common block.
;               DATAGAP    :  **Obselete**
;               HELP       :  Set this to print the contents of the tplot_vars.OPTIONS 
;                               (user-defined options) structure.
; **Obselete**  Z_BUFF     :  2-Element array specifying the resolution of a Z-Buffered
;                               image.  The default resolution for images produced by
;                               TV.PRO is 640 x 480, which causes some pixelation when
;                               viewing the images after saved.  Thus one can increase
;                               the resolution to prevent pixelation of TV-images.
;               SPEC_RES   :  A scalar defining the number of pixels per inch for PS files
;               NOMSSG     :  If set, TPLOT will NOT print out the index and TPLOT handle
;                               of the variables being plotted
;
;   NOTES:
;               1)  Lists of examples are found in _tplot_example.pro
;               2)  Use tnames.pro to return an array of current names.
;               3)  Use "TPLOT_NAMES" to print a list of acceptable names to plot.
;               4)  Use "TPLOT_OPTIONS" for setting various global options. 
;               5)  Plot limits can be set with the "YLIM" procedure or by using:
;                       options,[TPLOT Name],'YRANGE',[y_min,y_max]
;                       options,[TPLOT Name],'YSTYLE',1
;               6)  Spectrogram limits can be set with the "ZLIM" procedure or by using:
;                       options,[TPLOT Name],'ZRANGE',[z_min,z_max] etc.
;               7)  Time limits can be set with the "TLIMIT" procedure.
;               8)  The "OPTIONS" procedure can be used to set all IDL plotting
;                       keyword parameters (i.e. psym, color, linestyle, etc) as well
;                       as some keywords that are specific to tplot 
;                       (i.e. panel_size, labels, etc.)  For example, to change the 
;                       relative panel width for the quantity 'slp', run the following:
;                       options,'slp','PANEL_SIZE',1.5
;               9)  TPLOT calls the routine "SPECPLOT" to make spectrograms and 
;                       calls "MPLOT" to make the line plots. See these routines to 
;                       determine what other options are available.
;               10) Use "GET_DATA" to retrieve the data structure (or limit structure) 
;                       associated with a TPLOT quantity.
;               11) Use "STORE_DATA" to create new TPLOT quantities to plot.
;               12) The routine "DATA_CUT" can be used to extract interpolated data.
;               13) The routine "TSAMPLE" can also be used to extract data.
;               14) Time stamping is performed with the routine "TIME_STAMP".
;               15) Use "CTIME" or "GETTIME" to obtain time values.
;               16) TPLOT variables can be stored in files using "TPLOT_SAVE" and loaded
;                       again using "TPLOT_RESTORE"
;
;  SEE ALSO:
;               tplot_names.pro
;               tplot_options.pro
;               mplot.pro
;               specplot.pro
;               get_data.pro
;               store_data.pro
;               time_stamp.pro
;               tplot_save.pro
;               tplot_restore.pro
;               tplot_com.pro
;
;   CHANGED:  1)  Davin Larson changed something...          [11/01/2002   v1.0.97]
;             2)  Re-wrote and cleaned up                    [06/10/2009   v1.1.0]
;             3)  Added keyword:  Z_BUFF                     [06/11/2009   v1.2.0]
;             4)  Added keyword:  SPEC_RES                   [06/11/2009   v1.3.0]
;             5)  Updated man page                           [06/17/2009   v1.3.1]
;             6)  Added keyword:  NOMSSG                     [09/29/2009   v1.3.2]
;             7)  Changed an optional parameter, NUM_LAB_MIN, to force the minimum
;                   number of TPLOT time labels to = 4 instead of 2
;                                                            [09/30/2009   v1.3.3]
;             8)  Changed the tick label format to be more dynamic and robust
;                   and eliminated pointer usage in the plotting part of program
;                                                            [10/01/2010   v1.4.0]
;
;   CREATED:  June, 1995
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  10/01/2010   v1.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;COMMON BLOCK:  tplot_com
;
;WARNING!  THIS COMMON BLOCK IS SUBJECT TO CHANGE!  DON'T BE TOO SURPRISED
;   IF VARIABLES ARE ADDED, CHANGED, OR DISAPPEAR!
;
;   data_quants:  structure array,  handle to location of ALL data.
;   tplot_vars:   structure containing all tplot window and plotting
;			 information.
;SEE ALSO:   "tplot_options" and "tplot"
;MODIFIED BY:	Peter Schroeder
;CREATED BY:	Davin Larson
;LAST MODIFICATION: 01/10/08
;VERSION: @(#)tplot_com.pro	1.21
;
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE:  tplot_file , name [,filename]
;PURPOSE:
;   OBSOLETE PROCEDURE!  Use "TPLOT_SAVE" and "TPLOT_RESTORE" instead.
;   Store tplot data in a file.
;  gets the data, limits and name handle associated with a name string
;   This procedure is used by the tplot routines.
;INPUT:  
;   name    (string, tplot handle)
;   filename:  file name
;KEYWORDS:   
;   SAVE:   set to save files.
;   RESTORE:set to restore files.
;SEE ALSO:      "STORE_DATA", "GET_DATA", "TPLOT"
;
;CREATED BY:    Davin Larson
;LAST MODIFICATION:     tplot_file.pro   98/08/06
;
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE:	tplot_keys
;PURPOSE:
;	Sets up function keys on user keyboard to perform frequent "tplot"
;	functions and procedures.  Definitions will be explained when run.
;INPUT:	(none)
;OUTPUT: (none)
;CREATED BY:	Davin Larson
;LAST MODIFIED:	@(#)tplot_keys.pro	1.5 02/11/22
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE:  tplot_names [, datanames ]
;PURPOSE:    
;   Lists current stored data names that can be plotted with the TPLOT routines.
;INPUT:   (Optional)  An string (or array of strings) to be displayed
;         The strings may contain wildcard characters.
;Optional array of strings.  Each string should be associated with a data
;       quantity.  (see the "store_data" and "get_data" routines)
;KEYWORDS:
;  TIME_RANGE:  Set this keyword to print out the time range for each quantity.
;  CREATE_TIME: Set to print creation time.
;  VERBOSE:     Set this keyword to print out more info on the data structures
;  NAMES:       Named variable in which the array of valid data names is returned.
;  ASORT:       Set to sort by name.
;  TSORT:       Set to sort by creation time.
;  CURRENT:     Set to display only names in last call to tplot.
;EXAMPLE
;   tplot_names,'*3dp*'   ; display all names with '3dp' in the name
;CREATED BY:	Davin Larson
;SEE ALSO:   "TNAMES"  "TPLOT"
;MODS:     Accepts wildcards
;LAST MODIFICATION:	@(#)tplot_names.pro	1.19 01/10/08
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE:  tplot_options [,string,value]
;NAME:
;  tplot_options
;PURPOSE:
;  Sets global options for the "tplot" routine.
;INPUTS:
;   string: 	option to be set.
;   value:	value to be given the option.
;KEYWORDS:
;   HELP:      Display current options structure.
;   VAR_LABEL:   String [array], variable[s] to be used for plot labels.
;   FULL_TRANGE: 2 element double array specifying the full time range.
;   TRANGE:      2 element double array specifying the current time range.
;   DATANAMES:  String containing names of variable to plot
;   REFDATE:    Reference date.  String with format: 'YYYY-MM-DD'.
;         This reference date is used with the gettime subroutine.
;   WINDOW:     Window to be used for all time plots. (-1 specifies current 
;       window.
;   VERSION:    plot label version. (1 or 2 or 3)
;   TITLE:	string used for the tplot title
;   OPTIONS:	tplot options structure to be passed to replace the current
;		structure.
;   GET_OPTIONS:returns the new tplot options structure.
;EXAMPLES:
;   tplot_options,'ynozero',1          ; set all panels to YNOZERO=1
;   tplot_options,'title','My Data'    ; Set title
;   tplot_options,'xmargin',[10,10]    ; Set left/right margins to 10 characters
;   tplot_options,'ymargin',[4,2]      ; Set top/bottom margins to 4/2 lines
;   tplot_options,'position',[.25,.25,.75,.75]  ; Set plot position (normal coord)
;   tplot_options,'wshow',1             ; de-iconify window with each tplot
;   tplot_options,'version',3          ; Sets the best time ticks possible
;   tplot_options,'window',0           ; Makes tplot always use window 0
;   tplot_options,/help                ; Display current options
;   tplot_options,get_options=opt      ; get option structure in the variable opt.
;
;SEE ALSO:  "TPLOT", "OPTIONS", "TPLOT_COM"
;CREATED BY:  Davin Larson   95/08/29
;LAST MODIFICATION: 01/10/08
;VERSION: @(#)tplot_options.pro	1.16
;-


Last Modification =>  2009-09-18/14:09:14 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   tplot_panel.pro
;  PURPOSE  :   Sets the graphics parameters to the specified tplot panel.
;                 The time offset is returned through the optional keyword DELTATIME.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               wi.pro
;               get_data.pro
;               data_type.pro
;               mplot.pro
;
;  REQUIRES:    
;               loaded TPLOT data
;
;  INPUT:
;               TIME       :  N-Element array of Unix times associated with input Y
;               Y          :  N-Element array of data associated with input TIME
;
;  EXAMPLES:    
;               tplot_panel,tt_perp,Eperp,PSYM=2,VARIABLE='Epara_0'
;
;  KEYWORDS:    
;               PANEL      :  Set to a named variable to return the panel # of designated
;                               TPLOT variable set by VARIABLE keyword
;               DELTATIME  :  Set to a named variable to return the time offset
;               VARIABLE   :  Scalar string of a previously plotted TPLOT variable
;               OPLOTVAR   :  Scalar string of TPLOT variable to overplot on VARIABLE
;               PSYM       :  IDL keyword for plotting symbols instead of lines etc.
;
;   CHANGED:  1)  ?? Davin changed something                       [04/17/2002   v1.0.9]
;             2)  Rewrote and altered syntax slightly              [09/16/2009   v1.1.0]
;             3)  Made the call to wi.pro optionally dependent on current device name
;                                                                  [09/17/2009   v1.1.1]
;             4)  Added keywords:  COLOR                           [09/18/2009   v1.1.2]
;
;   NOTES:      
;               1)  Plot data in TPLOT that you wish to overplot something else onto.
;                     Then run this program, as in the example above, where the
;                     keyword VARIABLE defines the TPLOT handle to plot the data
;                     EPERP vs. TT_PERP over.  
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/18/2009   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-12-07/15:43:47 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   tplot_positions.pro
;  PURPOSE  :   
;                    Return a set of plot positions for TPLOT.
;                    Given the number of plots, the margins, and the relative 
;                    sizes of the plot panels, determine the plot coordinates.
;                    The positions are the device coordinates of the plot, not
;                    of the plot region. (See IDL User's Guide Chapter 14.10)
;
;                    If the margins are not specifically set, first the limit
;                    structures are checked, then ![X,Y].MARGIN are checked,
;                    then some defaults are used.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               get_data.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               PANELS   :  Scalar defining the number of plot windows [N]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               [X,Y]M   :  2-Element arrays defining the [X,Y] inner margin
;                             [Default:  ![X,Y].MARGIN]
;               [X,Y]OM  :  2-Element arrays defining the [X,Y] outer margin
;                             [Default:  ![X,Y].OMARGIN]
;               SIZES    :  N-Element array containing the relative plot sizes
;
;   CHANGED:  1)  ?? Davin changed something                       [05/30/1997   v1.0.2]
;             2)  Re-wrote and cleaned up                          [12/07/2010   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  12/07/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE: tplot_quant__define
;
; This procedure defines the tplot_quant structure.
;
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE:  tplot_restore ,filenames=filenames, all=all, sort=sort
;PURPOSE: 
;   Restores tplot data, limits, name handles, options, and settings.
;INPUT:
;KEYWORDS:  
;   filenames:  file name or array of filenames to restore.  If
;               no file name is chosen and the all keyword is not set,
;		tplot_restore will look for and restore a file called
;		saved.tplot.
;   all: restore all *.tplot files in current directory
;   append: append saved data to existing tplot variables
;   sort: sort data by time after loading in
;   get_tvars: load tplot_vars structure (the structure containing tplot
;		options and settings even if such a structure already exists
;		in the current session.  The default is to only load these
;		if no such structure currently exists in the session.
;SEE ALSO:      "TPLOT_SAVE","STORE_DATA", "GET_DATA", "TPLOT"
;
;CREATED BY:    Peter Schroeder
;LAST MODIFICATION:     @(#)tplot_restore.pro	1.23 02/11/01
;
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE:  tplot_save , name ,filename=filename, limits=limits
;PURPOSE: 
;   Store tplot data in a file.
;INPUT:  
;   name:   (optional) tplot handle or array of tplot handles to save.  If
;	    no name is supplied, tplot_save will save all defined tplot
;	    handles.
;KEYWORDS:   
;   filename:  file name in which to save data.  A default suffix of .tplot or
;	       .lim will be added to this depending on whether the limits
;              keyword has been set.  If not given, the default file name is
;	       saved.tplot or saved.lim.
;   limits:    will save only limits structures.  No data will be saved.
;SEE ALSO:      "STORE_DATA", "GET_DATA", "TPLOT", "TPLOT_RESTORE"
;
;CREATED BY:    Peter Schroeder
;LAST MODIFICATION:     tplot_save.pro   97/05/14
;
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;PROCEDURE:  tplot_sort,name
;PURPOSE: 
;   Sorts tplot data by time (or x).
;INPUT:
;   name: name of tplot variable to be sorted.
;KEYWORDS:  
;
;CREATED BY:    Peter Schroeder
;LAST MODIFICATION:     %W% %E%
;
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;FUNCTION:
;  dat = tsample([var,trange],[times=t])
;PURPOSE:
;  Returns a vector (or array) of tplot data values.
;USAGE:
;  dat = tsample()               ;Use cursor to select a subset of data.
;  dat = tsample('Np',[t0,t1])   ;extract all 'Np' data in the given time range
;KEYWORDS:
;  times:  time values returned through this keyword.
;  values: values returned through this keyword.
;  dy :  dy values
;
;-


Last Modification =>  2008-06-23/22:24:09 UTC
;+
;FUNCTION:
;  dat = tsample([var,trange],[times=t])
;PURPOSE:
;  Returns a vector (or array) of tplot data values.
;USAGE:
;  dat = tsample()               ;Use cursor to select a subset of data.
;  dat = tsample('Np',[t0,t1])   ;extract all 'Np' data in the given time range
;KEYWORDS:
;  times:  time values returned through this keyword.
;  values: values returned through this keyword.
;  dy :  dy values
;
;-


Last Modification =>  2008-06-23/22:24:10 UTC
;+
;PROCEDURE:  xlim,lim, [min,max, [log]]
;PURPOSE:    
;   To set plotting limits for plotting routines.
;   This procedure will add the tags 'xrange', 'xstyle' and 'xlog' to the 
;   structure lim.  This structure can be used in other plotting routines such
;   as "SPEC3D".
;INPUTS: 
;   lim:     structure to be added to.  (Created if non-existent)
;   min:     min value of range
;   max:     max value of range
;KEYWORDS:
;   LOG:  (optional)  0: linear,   1: log
;See also:  "OPTIONS", "YLIM", "ZLIM"
;Typical usage:
;   xlim,lim,-20,100      ; create a variable called lim that can be passed to
;                         ; a plotting routine such as "SPEC3D".
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)xlim.pro	1.9 02/04/17
;-


Last Modification =>  2008-06-23/22:24:10 UTC
;+
;PROCEDURE:  ylim [, str [ , min, max, [ LOG=log ] ] ]
;PURPOSE:   
;  Sets y-axis limits for plotting routines.
;  Adds the tags 'yrange', 'ystyle' and 'ylog' to the structure str, or to the 
;  limit structure associated with the string str.
;INPUTS: 
;   str is a:
;      CASE 1: structure (or zero or non-existent)
;         Structure to be added to.  (Created if non-existent)
;      CASE 2: string  (handle associated with a "TPLOT" variable)
;         The limits structure associated with this string is used.  This 
;         structure can be retrieved with the "GET_DATA" procedure.
;   min:     min value of yrange
;   max:     max value of yrange
;KEYWORDS:
;   LOG:   (optional)  0: linear,   1: log
;   DEFAULT:   Sets default tplot limits.
;   STYLE:  value to set the IDL plot YSTYLE keyword
;Typical usage:
;   ylim,lim,-20,100   ; create (or add to) the structure lim
;
;   ylim,'Ne',.01,100,1  ; Change limits of the "TPLOT" variable 'Ne'.
;
;NO INPUTS:
;   ylim                 ; Set "TPLOT" limits using the cursor.
;
;SEE ALSO:  "OPTIONS", "TLIMIT", "XLIM", "ZLIM"
;CREATED BY:	Davin Larson
;VERSION: ylim.pro
;LAST MODIFICATION: 01/06/25
;-


Last Modification =>  2008-06-23/22:24:10 UTC
;+
;PROCEDURE: ylimit
;PURPOSE:  Interactive setting of y-limits for the "TPLOT" procedure.
;
;SEE ALSO:	"YLIM", a noninteractive version which calls this routine.
;
;NOTES:  This procedure will probably be made obsolete by embedding it in.
;    "YLIM".
;        Run "TPLOT" prior to using this procedure.
;
;CREATED BY:	Davin Larson
;FILE: ylimit.pro
;VERSION:  1.11
;LAST MODIFICATION: 98/08/06
;-


Last Modification =>  2008-06-23/22:24:10 UTC
;+
;PROCEDURE:  zlim,lim, [min,max, [log]]
;PURPOSE:    
;   To set plotting limits for plotting routines.
;   This procedure will add the tags 'zrange', 'zstyle' and 'xlog' to the 
;   structure lim.  This structure can be used in other plotting routines.
;INPUTS: 
;   lim:     structure to be added to.  (Created if non-existent)
;   min:     min value of range
;   max:     max value of range
;   log:  (optional)  0: linear,   1: log
;If lim is a string then the limit structure associated with that "TPLOT" 
;   variable is modified.
;See also:  "OPTIONS", "YLIM", "XLIM", "SPEC"
;Typical usage:
;   zlim,'ehspec',1e-2,1e6,1   ; Change color limits of the "TPLOT" variable
;                              ; 'ehspec'.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)zlim.pro	1.2 02/11/01
;-


