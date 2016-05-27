Last Modification =>  2008-06-23/22:23:36 UTC
;+
;PROCEDURE:	append_array, a0, a1
;PURPOSE:
;	Append an array to another array.  Can also copy an array into a
;	subset of another. 
;INPUT:
;	a0:	Array to modify.
;	a1:	Array to append to, or copy into, a0.
;KEYWORDS:
;	index:	Index of a0 at which to append or copy a1.  If index is
;		greater than the number of elements of a0, then
;		a0 is enlarged to append a1. Returns the index of the first
;		element of a0 past the section copied from a1.
;	done:	If set, make a0 equal to the first index elements of a0.
;CREATED BY:	Davin Larson
;LAST MODIFIED:	@(#)append_array.pro	1.6 98/08/13
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;FUNCTION:	average_str(data, res)
;PURPOSE:
;	Average data in res second time segments.
;INPUTS:
;	DATA:	array of structures.  One element of structure must be TIME.
;	RES:	resolution in seconds.
;KEYWORDS:
;	NAN:	If set, treat the IEEE NAN value as missing data.
;CREATED BY:	Davin Larson
;LAST MODIFIED:	%W% %E%
;-


Last Modification =>  2009-08-11/13:37:58 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   box.pro
;  PURPOSE  :   Generalized routine to produce plot outlines for TPLOT routines.
;
;  CALLED BY:   
;               specplot.pro
;
;  CALLS:
;               str_element.pro
;               minmax.pro
;               extract_tags.pro
;               plot_positions.pro
;               xlim.pro
;               ylim.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               LIMITS  :  Plot structure with PLOT.PRO keywords
;               X       :  N-Element array of X-Axis data (semi-optional)
;               Y       :  N-Element array of Y-Axis data (semi-optional)
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DATA    :  Obselete keyword
;               MPOSI   :  Set to a named variable to return the plot position
;
;   CHANGED:  1)  I modified something...                 [03/18/2008   v1.0.?]
;             2)  Re-wrote and cleaned up                 [08/11/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/11/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;FUNCTION: cdf_file_names
;PURPOSE:
;   Returns an array of filenames within a timerange.
;USAGE:
;   files=cdf_file_names(FORMAT,trange=trange,/verbose)
;INPUT:
;   FORMAT is a string that will be interpreted as one of two things:
;     CASE 1:  
;        e.g.    FORMAT = '/home/wind/dat/wi/3dp/k0/????/wi_k0_3dp*.cdf'
;        if FORMAT contains * or ? then filenames are returned that match that
;        pattern and for which YYYYMMDD falls within the specified timerange.
;        for example:  
;        (UNIX only)
;     CASE 2:
;        e.g.    FORMAT = 'fa_k0_ees_files'
;        The name of an indexfile that associates filenames with start and 
;        end times. If his file is not found, then the environment variable 
;        getenv('CDF_INDEX_DIR') is prepended and searched for.
;        See "make_cdf_index" for information on producing this file.
;     SPECIAL NOTE:
;        If strupcase(FORMAT) is the name of an environment varible. Then
;        the value of that environment variable is used instead.
;KEYWORDS:
;     TRANGE: 
;        Two element array specifying the time range for which data files should
;        be returned.  If not provided then "timerange" is called to provide
;        the time range.  See also "timespan".
;     NFILES:
;        Named variable that returns the number of files found.
;     VERBOSE:
;        Set to print some useful info.
;     FILEINFO:  OBSOLETE!
;        Set to a named variable that will return a table of file info.
;NOTES:
;     UNIX only!
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;COMMON BLOCK  colors_com
;WARNING!  Don't rely on this file to remain stable!
;USE "get_colors" to get color information.
;SEE ALSO:
;  "get_colors","bytescale","loadct2"
;CREATED BY: Davin Larson
;File:      96/08/30
;Version:   1.2
;Last Mod:  colors_com.pro
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;FUNCTION:  data_type(x)
;PURPOSE:
;   Returns the variable type (ignores dimension).
;INPUTS: x:   Any idl variable.
;OUTPUT: integer variable type:
;   0 = undefined
;   1 = byte
;   2 = integer
;   3 = long
;   4 = float
;   5 = double
;   6 = complex
;   7 = string
;   8 = structure
;   9 = double precision complex
;
;KEYWORDS:
;   STRUCTURE: When set and if input is a structure, then an array
;       of data types are returned.
;
;SEE ALSO:  "dimen", "ndimen"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)data_type.pro	1.7 00/07/05
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;NAME:
;   day_to_year_doy
;PURPOSE:
;   determines year and day of year given day since 0000 AD
;USAGE:
;   day_to_year_doy,daynum,year,doy
;INPUT:
;   daynum:   (long int)  day since 0 AD
;OUTPUT:
;   year:     year         (0 <= year <= 14699 AD)
;   doy:      day of year  (1 <= doy  <=  366) 
;NOTES:
;  This procedure is reasonably fast, it works on arrays and works from
;  0 AD to 14699 AD
;
;CREATED BY:	Davin Larson  Oct 1996
;FILE:  day_to_year_doy.pro
;VERSION:  1.2
;LAST MODIFICATION:  97/01/27
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;FUNCTION:   dimen(x)
;PURPOSE:
;  Returns the dimensions of an array as an array of integers.
;INPUT:  matrix
;RETURNS:  vector of dimensions of matrix.
;   If the input is undefined then 0 is returned.
;   if the input is a scaler then 1 is returned.
;
;SEE ALSO:  "dimen", "data_type", "dimen1", "dimen2"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)dimen.pro	1.6 96/12/16
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;FUNCTION:   dimen1
;INPUT:  matrix
;RETURNS:  scaler int:  size of first dimension  (1 if dimension doesn't exist)
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION;	@(#)dimen1.pro	1.3 95/08/24
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;FUNCTION:   dimen2
;INPUT:  matrix
;RETURNS:  scaler int:  size of second dimension  (1 if dimension doesn't exist)
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION;	@(#)dimen2.pro	1.3 95/08/24
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;PROCEDURE:
;  doy_to_month_date, year, doy, month, date
;NAME:
;  doy_to_month_date
;PURPOSE:
; Determines month and date given the year and day of year.
; fast, vector oriented routine that returns the month and date given year and 
; day of year (1<=doy<=366)
;
;CREATED BY:	Davin Larson  Oct 1996
;FILE:  doy_to_month_date.pro
;VERSION:  1.2
;LAST MODIFICATION:  97/01/27
;-


Last Modification =>  2009-09-08/16:44:25 UTC
;+
; PROJECT:
;       SOHO - CDS/SUMER
;       THEMIS
;
; NAME:
;       DPRINT
;
; PURPOSE:
;       Diagnostic PRINT (activated only when DEBUG reaches DLEVEL)
;
; EXPLANATION:
;       This routine acts similarly to the PRINT command, except that
;       it is activated only when the common block variable DEBUG is
;       set to be equal to or greater than the debugging level set by
;       DLEVEL (default to 0).  It is useful for debugging.
;       If DLEVEL is not provided it uses a persistent (common block) value set with the
;       keyword SETDEBUG.
;
; CALLING SEQUENCE (typically written into code):
;       DPRINT, v1 [,v2 [,v3...]]] [,format=format] [,dlevel=dlevel] [,verbose=verbose]
;             The values of v1,v2,v3 will only be printed if verbose >= dlevel
;
; CALLING SEQUENCE to change options (typically typed from IDL command line)
;       DPRINT, setdebug=d   ; define persistent debug level
;       DPRINT, print_trace=[0,1,2, or 3]  ; Display program trace info in subsequent calls to DPRINT
;       DPRINT, /print_dtime       ; Display delta time between DPRINT statements.
;
; INPUTS:
;       V1, V2, ... - List of variables to be printed out (20 max).
;
; OPTIONAL INPUTS:
;       None.
;
; OUTPUTS:
;       All input variables are printed out on the screen (or the
;       given unit)
;
; OPTIONAL Keywords:
;       FORMAT - Output format to be used
;       UNIT   - Output unit through which the variables are printed. If
;                missing, the standard output (i.e., your terminal) is used.
;
; KEYWORD PARAMETERS:
;       DLEVEL = DLEVEL - An integer indicating the debugging level; defaults to 0
;       VERBOSE = VERBOSE - An integer indicating current verbosity level, If verbose is set
;       it will override the current value of debug, for the specific call of dprint in which
;       it is set.
;       SETDEBUG=value            - Set debug level to value
;       GETDEBUG=named variable   - Get current debug level
;       DWAIT = NSECONDS  ; provides an additional constraint on printing.
;              It will only print if more than NSECONDS has elapsed since last dprint.
;
; CALLS:
;       PTRACE()
;
; COMMON BLOCKS:
;       DPRINT_COM.
;
; RESTRICTIONS:
;     - Changed see SETDEBUG above
;       Can print out a maximum of 12 variables (depending on how many
;          is listed in the code)
;
; SIDE EFFECTS:
;       None.
;
; CATEGORY:
;       Utility, miscellaneous
;
; PREVIOUS HISTORY:
;       Written March 18, 1995, Liyun Wang, GSFC/ARC
;
; MODIFICATION HISTORY:
;       Version 1, Liyun Wang, GSFC/ARC, March 18, 1995
;       Version 2, Zarro, SM&A, 30 November 1998 - added error checking
;       Version 3, Zarro, (EIT/GSFC), 23 Aug 2000 - removed DATATYPE calls
;       Version 4, Larson  (2007) stripped out calls to "execute" so that it can be called from IDL VM
;                          Fixed bug that allows format keyword to be used.
;                          Added PTRACE() call
;                          Added SETDEBUG keyword and GETDEBUG keyword
;                          Added DWAIT keyword
;
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;PROCEDURE:  extract_tags, newstruct, oldstruct
;PURPOSE: takes the named tag elements from oldstruct and puts them into
;   newstruct.  This procedure is very useful for creating a structure that
;   can be passed onto the PLOT or OPLOT subroutines using the _EXTRA keyword.
;   If no tag keywords are included then all tag elements of oldstruct are 
;   added to newstruct.  The mode keyword PRESERVE is used to prevent the
;   overwritting of an existing keyword. 
;INPUTS:
;  newstruct:  new structure to be created or added to.
;  oldstruct:  old structure from which elements are extracted.
;KEYWORDS:  Only one of the following should be given:; 
; (TAG KEYWORDS)
;  TAGS:  array of strings.  (tag names) to be taken from oldstruct and put in
;      newstruct
;  EXCEPT: array of strings.  Tag names not to be copied from old to new.
;  OPLOT:  (flag)  If set, then TAGS is set to an array of valid keywords
;     for the OPLOT subroutine.
;  PLOT:   (flag)  If set, then TAGS is set to an array of valid keywords
;     for the PLOT subroutine.
;  CONTOUR: (flag) If set, then TAGS is set to an array of valid keywords
;     for the CONTOUR procedure.   (might not be complete)
;If no KEYWORDS are set then all elements of oldstruct are put into newstruct
;  (MODE KEYWORDS)
;  PRESERVE: (flag) Prevents the overwritting of an existing, non-null keyword.
;     Adds tags to newstruct that were not already there, or if they were there
;     and their values were either "" or 0.
;CREATED BY:	Davin Larson
;FILE:  extract_tags.pro  
;VERSION  1.21
;LAST MODIFICATION: 02/04/17
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
; **** OBSOLETE!!! Please use "str_element"instead! ***
;
;FUNCTION:  find_str_element
;PURPOSE:  find an element within a structure
; Input:
;   struct,  generic structure
;   name,    string  (tag name)
; Purpose:
;   Returns index of structure tag.
;   Returns -1 if not found   
;   Returns -2 if struct is not a structure
;KEYWORDS:
;  If VALUE is set to a named variable then  the value of that element is
;   returned in it.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)find_str_element.pro	1.6 95/10/06
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;PROCEDURE:	fname_to_time, fname, time
;PURPOSE:
;	To translate the name of a standard WIND data file into the starting
;	time of the data.
;INPUT:
;	fname: filename (string) to be translated
;	time: variable in which to return time (double)
;
;CREATED BY:	Peter Schroeder
;LAST MODIFICATION:	%W% %E%
;-


Last Modification =>  2009-10-12/13:45:39 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   interp.pro
;  PURPOSE  :   Linearly Interpolates vectors with an irregular grid.  INTERP is 
;                 functionally the same as INTERPOL (with no keywords defining the type
;                 of interpolation), however it is typically much faster for most 
;                 applications.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               interp.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               Y                   :  N-Element array of data of any form except 
;                                        a string
;               X                   :  N-Element absicissae values for Y.
;                                        The values MUST be monotonically ascending
;                                        or descending.
;               U                   :  M-Element absicissae values for the result.
;                                        The returned array will have the same number of
;                                        elements as U.
;
;  EXAMPLES:    
;               result = interp(y,x,u)
;
;  KEYWORDS:    
;               INDEX               :  Set to named variable to return the index of 
;                                        the closest X less than U. (will have the same
;                                        number of elements as U)
;               NO_CHECK_MONOTONIC  :  If set, program does not check for monotonic data.
;               NO_EXTRAPOLATE      :  If set, program will not extrapolate end point data.
;               INTERP_THRESHOLD    :  Scalar defining the minimum allowable gap size.
;
;   CHANGED:  1)  Davin Larson changed something...       [04/17/2002   v1.0.15]
;             2)  Re-wrote and cleaned up                 [10/12/2009   v1.1.0]
;
;   NOTES:      
;               1)  To avoid spurious spikes or negative data points near the end points
;                     of the input array Y, use the NO_EXTRAPOLATE keyword.
;
;   CREATED:  04/30/1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  10/12/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;PROCEDURE loadct2, colortable
;
;KEYWORDS:
;   FILE:  Color table file
;          Uses the environment variable IDL_CT_FILE to determine 
;          the color table file if FILE is not set.
;common blocks:
;   colors:      IDL color common block.  Many IDL routines rely on this.
;   colors_com:  
;See also:
;   "get_colors","colors_com","bytescale"
;
;Created by Davin Larson;  August 1996
;Version:           1.4
;File:              00/07/05
;Last Modification: loadct2.pro
;-


Last Modification =>  2009-08-11/13:47:29 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   minmax.pro
;  PURPOSE  :   Returns a two element array containing the minimum and maximum values
;                 of a data input.  The values can be forced to be positive and the
;                 indices of the max and min values can be returned as well.  One can
;                 also find the relative min-max values in between two values defined
;                 by the keywords MAX_VALUE and MIN_VALUE.
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
;               TDATA        :  An N-Dimensional M-Element array of finite data
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               MAX_VALUE    :  Scalar defining the maximum value the program should
;                                 consider when calculating the min-max range
;               MIN_VALUE    :  Scalar defining the minimum value the program should
;                                 consider when calculating the min-max range
;               POSITIVE     :  If set, only positive real results will be returned
;                                 [Effective for Log-Scale plot ranges]
;               MXSUBSCRIPT  :  Set to a named variable to return the element 
;                                 associated with the maximum value returned
;               MNSUBSCRIPT  :  Set to a named variable to return the element 
;                                 associated with the minimum value returned
;
;   NOTES:
;               1)  If BOTH MIN_VALUE and POSITIVE are set AND MIN_VALUE < 0, then
;                     the program will let the keyword POSITIVE trump MIN_VALUE
;
;   CHANGED:  1)  Davin Larson changed something...       [04/17/2002   v1.0.2]
;             2)  Added /NAN keywords to MIN.PRO and MAX.PRO function calls 
;                                                         [03/13/2008   v1.0.3]
;             3)  Re-wrote and cleaned up                 [08/11/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/11/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;FUNCTION: ndimen
;PURPOSE:
;  Returns the number of dimensions in an array.
;INPUT:  array
;RETURNS number of dimensions  (0 for scalers,-1 for undefined)
;
;SEE ALSO:  "dimen", "data_type"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)ndimen.pro	1.6 97/03/10
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
; PROCEDURE:
;	oplot_err, x, low, high
; PURPOSE:
;	Plot error bars over a previously drawn plot.
;
;-


Last Modification =>  2009-06-10/14:56:00 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   pclose.pro
;  PURPOSE  :   Closes a PS file and returns device settings to original settings.
;
;  CALLED BY:   NA
;
;  CALLS:
;               popen_com.pro
;
;  REQUIRES:    NA
;
;  INPUT:       NA
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               PRINTER  :  Set to name of printer to send PS files to
;               XVIEW    :  Not sure, something to do with X-Windows
;               COMMENT  :  Appends a comment onto file
;
;  SEE ALSO:
;               popen.pro
;               print_options.pro
;               popen_com.pro
;
;   CHANGED:  1)  Davin Larson changed something...        [02/18/1999   v1.0.10]
;             2)  Re-wrote and cleaned up                  [06/10/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/10/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-12-07/16:15:03 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   plot_positions.pro
;  PURPOSE  :   Procedure that will compute plot positions for multiple plots per page.
;
;  CALLED BY:   
;               box.pro
;
;  CALLS:
;               extract_tags.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               [X,Y]SIZES    :  Scalar defining the # of plots in [X,Y] directions
;                                  [Default:  {!P.MULTI[1],!P.MULTI[2]}]
;               OPTIONS       :  Structure containing parameters relevant to PLOT.PRO
;                                  [Tags accepted are the same as those used for
;                                   _EXTRA keyword in PLOT.PRO]
;               OUT_POSITION  :  Set to a named variable to return the default
;                                  plot positions
;               [X,Y]GAP      :  Scalar defining the [X,Y]-margins
;               REGION        :  A four element vector that specifies the normalized 
;                                  coordinates of the rectangle enclosing the plot 
;                                  region
;                                  [Default:  !P.REGION]
;               ASPECT        :  Set to a named variable to return the aspect 
;                                  ratio of the plots
;
;   CHANGED:  1)  ?? Davin changed something                       [??/??/????   v1.0.?]
;             2)  I changed something                              [01/23/2008   v1.0.?]
;             3)  Re-wrote and cleaned up                          [12/07/2010   v1.1.0]
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


Last Modification =>  2009-06-15/19:34:53 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   popen.pro
;  PURPOSE  :   Controls the plot device and plotting options.
;
;  CALLED BY:   NA
;
;  CALLS:
;               print_options.pro
;               str_element.pro
;               data_type.pro
;               pclose.pro
;
;  REQUIRES:  
;               popen_com.pro
;
;  INPUT:
;               N             :  Optional input of the following format:
;                                  1) String => file name ('.ps' is appended 
;                                                 automatically)
;                                  2) Scalar => file name goes to 'plot[X].ps' where
;                                                 [X] = the user defined scalar value
;                                  3) None   => file name is set to 'plot.ps'
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               PORT          :  If set, device set to portrait
;               LAND          :  If set, device set to landscape
;               COLOR         :  If set, device set to allow color images
;               BW            :  If set, forces black&white color scale
;               PRINTER       :  Set to name of printer to send PS files to
;               DIRECTORY     :  
;               ASPECT        :  Controls the aspect ratio
;               XSIZE         :  X-Dimension (cm) of output to PS file
;               YSIZE         :  Y-" "
;               INTERP        :  Keyword for SET_PLOT.PRO [default = 0]
;               CTABLE        :  Define the color table you wish to use
;               OPTIONS       :  A TPLOT plot options structure
;               COPY          :  Keyword for SET_PLOT.PRO (conserves current color)
;               ENCAPSULATED  :  If set, output is an EPS file instead of a PS file
;
;  SEE ALSO:
;               pclose.pro
;               print_options.pro
;               popen_com.pro
;
;   CHANGED:  1)  Davin Larson changed something...        [06/23/1998   v1.0.21]
;             2)  Re-wrote and cleaned up                  [06/10/2009   v1.1.0]
;             3)  Changed printed device info settings     [06/15/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/15/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;COMMON BLOCK:	popen_com
;PURPOSE:	Common block for print routines
;
;SEE ALSO:	"popen","pclose",
;		"print_options"
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)popen_com.pro	1.10 97/12/05
;-


Last Modification =>  2009-06-10/14:10:08 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   print_options.pro
;  PURPOSE  :   This program controls the options used for postscript (PS) files.
;
;  CALLED BY: 
;               popen.pro
;
;  CALLS:       NA
;
;  REQUIRES:  
;               popen_com.pro
;
;  INPUT:       NA
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               PORTRAIT   :  If set, produces a portrait image
;               LANDSCAPE  :  If set, produces a landscaped image
;               BW         :  Forces images to black&white color scale
;               COLOR      :  Sets image to a color image
;               ASPECT     :  Controls the aspect ratio
;               XSIZE      :  X-Dimension (cm) of output to PS file
;               YSIZE      :  Y-" "
;               PRINTER    :  Set to name of printer to send PS files to
;               DIRECTORY  :  
;
;   CHANGED:  1)  Davin Larson changed something...       [05/30/1997   v1.0.16]
;             2)  Re-wrote and cleaned up                 [06/09/2009   v1.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/10/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-08-27/18:24:05 UTC
;+
;PROCEDURE: printdat,[x]
;PURPOSE:
;   Displays information and contents of a data variable. (Very similar to HELP procedure but much more verbose.)
;   This routine is most useful for displaying contents of complex
;   data structures.
;   If printdat is called without arguments then information on all variables
;   within the calling routine are displayed.
;   POINTER occurences are recursively displayed as well. (only non-null pointers are listed)
;
;Keywords:
;   FULL     Set this keyword to display full variable output.
;   NAMES = string:  Optional list of variables to display (Same as for HELP)
;   WIDTH:   Width of screen (Default is 120).
;   MAX:     Maximum number of array elements to print.  (default is 30)
;   NSTRMAX  Maximum number of structure elements to print. (default is 3)
;   NPTRMAX  Maximum number of structure elements to print. (default is 5)
;   OUTPUT=string :  named variable in which the output is dumped.
;   VARNAME=string : [optional] name of variable to be displayed. (useful if input is an expression instead of a variable)
;   RECURSEMAX = integer :  Maximum number of levels to dive into. (Useful for limiting the output for heavily nested structures or pointers)
;
;Written by Davin Larson, May 1997.
;
; $LastChangedBy: davin-win $
; $LastChangedDate: 2008-02-29 11:40:28 -0800 (Fri, 29 Feb 2008) $
; $LastChangedRevision: 2431 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/trunk/misc/printdat.pro $
;-


Last Modification =>  2007-06-06/07:59:08 UTC
;+
;FUNCTION: PTRACE()
;PURPOSE: Returns a string that provides the current program location.
;KEYWORDS:
;    OPTION:  The value of the option is retained in a common block
;           OPTION=0  : returns null string
;           OPTION=1  : returns highest level routine name.
;           OPTION=2  : returns highest level routine name (indented).
;           OPTION=3  : returns all levels
;
;Usage: Generally useful for debugging code and following code execution.
;Example:
;  if keyword_set(verbose) then  print,ptrace(),'X=',x
;
;Written:  Jan 2007,  D. Larson
;-


Last Modification =>  2010-10-01/16:02:10 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   roundsig.pro
;  PURPOSE  :   Returns values rounded to the user designated number of significant
;                 figures.
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
;               X            :  N-Element array of [float,double] values
;
;  EXAMPLES:    
;               rx = roundsig(10.2357,SIGFIG=2)
;               PRINT, rx
;                     10.2000
;               rx = roundsig(10.2357,SIGFIG=4)
;               PRINT, rx
;                     10.2360
;               rx = roundsig(10.2357d10,SIGFIG=2)
;               PRINT, rx
;                  1.0200000e+11
;
;  KEYWORDS:    
;               SIGFIG       :  Scalar defining the number of significant figures to
;                                 keep
;                                 [Default:  SIGFIG = 1]
;               UNCERTAINTY  :  
;
;   CHANGED:  1)  Re-wrote and cleaned up                    [10/01/2010   v1.1.0]
;
;   NOTES:      
;               1)  Program assumes input can be written as:
;                     x = a b^{c}
;                     where a is the mantissa (or significand), b is 10. here, and
;                     c is the scaled exponent.  The mantissa is defined as:
;                     a = x b^{-c}
;                     such that we have the following:
;                     
;                     Log_{b} |a| = Log_{b} |x| - c
;                     
;                     Thus, in the below calculations we have:
;                     
;                     c           <--> e        = FLOOR(logx - sig)
;                     Log_{b} |a| <--> f        = logx - e
;                     a           <--> mantissa = ROUND(10^f)
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  10/01/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;PROCEDURE:
;  share_colors
;PURPOSE:
;  Procedure that allows multiple IDL sessions to share the same color table.
;  The procedure should be called in each session before any 
;  windows are created.
;USAGE:
;  Typically this procedure will be put in a startup routine. such as: 
;  share_colors,first=f
;  if f then loadct,39   
;
;KEYWORDS:
;  FIRST Named variable that will be set to 1 if this is the
;      first session, and set to 0 otherwise.
;SIDE EFFECTS:
;  Creates a temporary file with the name 'idl_cmap:NAME' on the users home
;  directory where NAME is the name of the display machine.
;  This file is deleted upon exiting IDL.
;  The procedure is only useful on UNIX for users with a common home directory.
;-


Last Modification =>  2008-09-05/19:15:38 UTC
;+
; This procedure returns the directory path associated with
; the routine calling this function.  This is useful for
; building applications that need to bootstrap resource and
; configuration files when the installation directory may not
; be known until run time.  Use this function in conjunction
; with FILEPATH to build platform-independent file path strings
; to your resources. <br>
; For example, <pre>
;   b = WIDGET_BUTTON(tlb, /BITMAP, $
;     VALUE=FILEPATH('up.bmp', ROOT = SourcePath(), SUBDIR = ['resource'])</pre>
; This will search for a file named "up.bmp" in the subdirectory named
; "resource" below the directory in which is located the source code
; (or SAVE file) for the routine containing the above statement.
;
; @Keyword
;   Base_Name {out}{optional}{type=string}
;       Set this keyword to a named variable to retrieve the
;       base file name of the routine's source.
;
; @Returns
;   The return value is the root directory path to
;   the calling routine's source file or SAVE file.
;
; @Examples <pre>
;   Create a file myapp.pro with the contents and run it.
;     PRO MYAPP
;     PRINT, SourcePath()
;     END
;   The printed output will be the full path to the
;   directory in which abc.pro was created, regardless of
;   IDL's current working directory.</pre>
;
; @History
;   03/18/2005  JLP, RSI - Original version
;-


Last Modification =>  2008-09-05/19:15:38 UTC
;+
; The SOURCEROOT function, in combination with
; FILEPATH, allows a program to locate other
; files within a routine source file's related
; directory tree.
; <p>
;
; For example, an IDL routine file named
; C:\myapp\abc.pro calls SOURCEROOT as in
; <p>
; <pre>
;    PRO ABC
;    PRINT, SOURCEROOT()
;    END
; </pre>
; the resulting output will be the string "C:\myapp".
; <p>
;
; If data associated with the application are in
; C:\myapp\mydata, a data file in this directory
; can be located via
; <p>
; <pre>
;    IDL> datafile = FilePath('data.dat',$
;    IDL>   ROOT=SourceRoot(), $
;    IDL>   SUBDIR=['data'])
; </pre>
; The programmer can distribute the application
; to another user who may install the original directory tree
; into "D:\app".
; No code modifications would be required for this
; user to successfully locate the data.dat file.
; <p>
;
; If the routine ABC were compiled and saved to
; an IDL SAVE file and distributed, the SOURCEROOT
; function will return the path to the SAVE file
; instead.
;
; @author Jim Pendleton
;-


Last Modification =>  2009-08-26/00:06:00 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   str_element.pro
;  PURPOSE  :   Find (or add) an element (i.e. tag name w/ or w/o data) of a structure.
;                 This program retrieves the value of a structure element.  This 
;                 function will not produce an error if the tag and/or structure 
;                 does not exist.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               str_element.pro
;               tag_names_r.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               STRUCT       :  An IDL structure
;               TAGNAME      :  Scalar string defining either the structure tag you wish
;                                 to find or one you wish to add
;               VALUE        :  Either a named variable to be returned to the user 
;                                 with the data corresponding to the structure tag
;                                 [TAGNAME] or the value of the new data to use when the
;                                 keyword ADD_REPLACE is set
;
;  EXAMPLES:    
;               str_element,struct,'XRANGE',[-10.,10.],/ADD_REPLACE
;
;  KEYWORDS:    
;               ADD_REPLACE  :  If set, the data associated with the VALUE input
;                                 will be added to or replace the associated tag
;                                 in the structure
;               DELETE       :  Set this keyword to delete the tag associated with
;                                 TAGNAME input
;               CLOSEST      :  Set this keyword to allow near matches of structure
;                                 tags [useful with _EXTRA keyword in PLOT.PRO]
;               SUCCESS      :  Set to a named variable to return a 1 or 0 depending on
;                                 whether the tag was found or not, respectively
;               VALUE        :  Set to a named variable to return to the user
;               INDEX        :  Set to a named variable to return the structure tag
;                                 index.  Return values will be:
;                                 -2  :  STRUCT is not a structure
;                                 -1  :  TAGNAME is not found
;                                >=0  :  successful
;
;   CHANGED:  1)  Added recursive searching of structure hierarchy [05/07/1997   v1.0.9]
;             2)  Davin Larson modified something...               [10/08/2001   v1.0.10]
;             3)  Re-wrote and cleaned up                          [08/25/2009   v1.1.0]
;
;   NOTES:      
;               1)  This program currently only allows one input structure at a time
;                     [Even though it appears as though there is a place for structure
;                      arrays in the program, don't trust it to figure this out for
;                      you.]
;               2)  Value remains unchanged if the structure element does not exist.
;               3)  If tagname contains a '.' then the structure is recursively searched 
;                     and index will be an array of indices.
;               4)  If struct is an array of structures then results may be unpredictable.
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/25/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2009-09-08/15:56:16 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   strfilter.pro
;  PURPOSE  :   Returns the subset of a string array that matches the search string.
;                 1)  '*' will match all (non-null) strings
;                 2)  ''  will match only the null string
;               RETURNS:
;                 1)  Array of matching strings.
;                 2)  Array of string indices.
;                 3)  Byte array with same dimension as input string.
;
;  CALLED BY:   
;               tnames.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               STR        :  N-Element string array to be filtered
;               MATCHS     :  Scalar string used to search for in STR
;                               [may contain wildcards like '*']
;
;  EXAMPLES:    
;               :  To print all files that do NOT end with *.pro
;               PRINT, strfilter(FINDFILE('*'),'*.pro',/NEGATE)    ; => Before Version 6.1
;               PRINT, strfilter(FILE_SEARCH('*'),'*.pro',/NEGATE) ; => After 6.1
;               
;
;  KEYWORDS:    
;               COUNT      :  A named variable that will contain the number of 
;                               matched strings.
;               WILDCARD   :  
;               FOLD_CASE  :  If set, then program is case insensitive
;               DELIMITER  :  
;               INDEX      :  If set, then matching indicies of the STR array with
;                               matching strings from MATCHS
;               STRING     :  If set, then matching strings are returned
;               BYTE       :  If set, then a byte array is returned
;               NEGATE     :  
;
;   CHANGED:  1)  Modified to use the IDL strmatch function so that '?' is accepted 
;                   for versions > 5.4                          [07/??/2000   v1.0.?]
;             2)  Davin Larson changed something...             [10/08/2001   v1.0.?]
;             3)  Re-wrote and cleaned up                       [09/08/2009   v1.1.0]
;
;   NOTES:      
;               1)  this routine is very similar to the STRMATCH routine introduced in 
;                     IDL 5.3 with some enhancements that make it more useful (i.e. 
;                     it can handle string arrays).
;
;   CREATED:  Feb. 1999
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/08/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
; FUNCTION:
;        STRIPPATH
;
; DESCRIPTION:
;
;       Function that strips off any directory components from a full
;       file path, and returns the file name and directory components
;       seperately in the structure:
;               {file_cmp_str,file_name:'file',dir_name:'dir'}
;       This is only implemented for UNIX at this time.
;
; USAGE (SAMPLE CODE FRAGMENT):
; 
;   ; find file component of /usr/lib/sendmail.cf
;       stripped_file = STRIPPATH('/usr/lib/sendmail.cf')
; 
;  The variable stripped_file would contain:
;
;       stripped_file.file_name = 'sendmail.cf'
;       stripped_file.dir_name  = '/usr/lib/'
;
;
; REVISION HISTORY:
;
;   $LastChangedBy: kenb-mac $
;   $LastChangedDate: 2006-12-15 08:13:48 -0800 (Fri, 15 Dec 2006) $
;   $LastChangedRevision: 97 $
;   $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/trunk/misc/strippath.pro $
;       Originally written by Jonathan M. Loran,  University of 
;       California at Berkeley, Space Sciences Lab.   Oct. '92
;   Updated to use IDL 6.0 features for cross-platform usability.
;
;-


Last Modification =>  2008-06-23/22:23:36 UTC
;+
;PROCEDURE:  strplot, x, y
;INPUT:
;            x:  array of x values.
;            y:  array of y strings.
;PURPOSE:
;    Procedure used to print strings in a "TPLOT" style plot.
;	   
;KEYWORDS:
;    DATA:     A structure that contains the elements 'x', 'y.'  This 
;       is an alternative way of inputing the data.
;    LIMITS:   The limits structure including PLOT and XYOUTS keywords.
;    OVERPLOT: If set, then data is plotted over last plot.
;    DI:       Not used. Exists for backward compatibility.
;
;LAST MODIFIED: @(#)strplot.pro	1.2 98/08/03
;-


Last Modification =>  2010-03-17/00:54:03 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   time_double.pro
;  PURPOSE  :   A fast, vectorized routine that returns the number of seconds since 1970.
;
;  CALLED BY: 
;               time_epoch.pro
;               time_string.pro
;               time_struct.pro
;               time_ticks.pro
;
;  CALLS:
;               time_double.pro
;               pb5_to_time.pro
;               time_struct.pro
;               time_string.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               TIME   :  Scalar or array of one of the following types:
;                           1)  DOUBLE     :  Unix time (s)
;                           2)  STRING     :  YYYY-MM-DD/hh:mm:ss  (see time_string.pro)
;                           3)  STRUCTURE  :  Format returned by time_struct.pro
;                           4)  LONG ARRAY :  2-Dimensional PB5 time (CDF files)
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               EPOCH  :  If set, implies the input, TIME, is a double precision
;                           Epoch time
;               DIM    :  Set to the dimensions of the input
;               PB5    :  If set, implies the input, TIME, is a PB5 time
;
;   CHANGED:  1)  Davin Larson changed something...       [07/12/2001   v1.0.9]
;             2)  Re-wrote and cleaned up                 [06/23/2009   v1.1.0]
;             3)  Fixed typo which seemed to only affect long (> 1 month) time
;                   ranges                                [03/16/2010   v1.2.0]
;
;   CREATED:  October, 1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  03/16/2010   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:37 UTC
;+
;NAME:
;  time_epoch
;PURPOSE:
;  Returns the EPOCH time required by CDF files.
;USAGE:
;  epoch = time_epoch(t)
; NOT TESTED!!!
;
;CREATED BY:	Davin Larson  Oct 1996
;FILE:  time_epoch.pro
;VERSION:  1.1
;LAST MODIFICATION:  96/10/16
;-


Last Modification =>  2008-06-23/22:23:37 UTC
;+
;NAME:
;  time_pb5
;PURPOSE:
;  Returns the PB5 time required by CDF files.
;USAGE:
;  pb5 = time_pb5(t)
;OUTPUT:
;  2 dimensional long integer array with dimensions:  (n,3)  Where n is the number
;  of elements in t
;Not fully TESTED!!!!
;
;CREATED BY:	Davin Larson  Oct 1996
;FILE:  time_pb5.pro
;VERSION:  1.3
;LAST MODIFICATION:  97/01/27
;-


Last Modification =>  2008-06-23/22:23:37 UTC
;+
;PROCEDURE:   time_stamp,charsize=charsize
;PURPOSE:
;     Prints a time stamp along the lower right edge of the current plot box
;KEYWORDS:  
;     CHARSIZE:  The character size to be used.  Default is !p.charsize/2.
;     ON:        if set, then timestamping is turned on. (No other action taken)
;     OFF:       if set, then timestamping is turned off. (Until turned ON)
;-


Last Modification =>  2009-09-09/13:27:51 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   time_substitute.pro
;  PURPOSE  :   Program called by time_string.pro for altering time arrays.
;
;  CALLED BY:   
;               time_string.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               DESTINATION    :  
;               SOURCE         :  
;               POS            :  
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NEXT_POSITION  :  
;
;   CHANGED:  1)  Re-wrote and cleaned up                          [09/08/2009   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/08/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-
;+
;*****************************************************************************************
;
;  FUNCTION :   time_string.pro
;  PURPOSE  :   Converts time to a date string.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               time_struct.pro
;               time_substitute.pro
;               time_double.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               TIME0          :  A scalar or N-element array of type:
;                                   1)  Double    = Unix Time
;                                   2)  String    = 'YYYY-MM-DD/hh:mm:ss'
;                                   3)  Structure = format returned by time_struct.pro
;                                   4)  Float     = ?
;                                   5)  Long      = ?
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               FORMAT         :  Scalar long-type which specifies the output:
;                                   = 0   :  'YYYY-MM-DD/hh:mm:ss'
;                                   = 1   :  'YYYY Mon dd hhmm:ss'
;                                   = 2   :  'YYYYMMDD_hhmmss'
;                                   = 3   :  'YYYY MM dd hhmm:ss'
;                                   = 4   :  'YYYY-MM-DD/hh:mm:ss'
;                                   = 5   :  'YYYY/MM/DD hh:mm:ss'
;                                   = 6   :  'YYYYMMDDhhmmss'
;               PRECISION      :  Scalar long-type which specifies the precision:
;                                   = -5  :  Year only
;                                   = -4  :  Year, month
;                                   = -3  :  Year, month, date
;                                   = -2  :  Year, month, date, hour
;                                   = -1  :  Year, month, date, hour, minute
;                                   = 0   :  Year, month, date, hour, minute, sec
;                                   = >0  :  fractional seconds
;               EPOCH          :  
;               DATE_ONLY      :  Same as setting PRECISION = -3
;               TFORMAT        :  String with following format:  
;                                   "YYYY-MM-DD/hh:mm:ss.ff DOW TDIFF"
;                                   The following tokens are recognized:
;                                     YYYY  - 4 digit year
;                                     yy    - 2 digit year
;                                     MM    - 2 digit month
;                                     DD    - 2 digit date
;                                     hh    - 2 digit hour
;                                     mm    - 2 digit minute
;                                     ss    - 2 digit seconds
;                                     .fff   - fractional seconds
;                                     MTH   - 3 character month
;                                     DOW   - 3 character Day of week
;                                     DOY   - 3 character Day of Year
;                                     TDIFF - 5 character, hours different from UTC
;                                             (useful with LOCAL keyword)
;               LOCAL_TIME     :  If set, then local time is displayed
;               MSEC           :  Same as setting PRECISION = 3
;               SQL            :  If set, produces output format: 
;                                   "YYYY-MM-DD hh:mm:ss.sss"
;                                   (quotes included) which convenient for 
;                                    building SQL queries.
;               IS_LOCAL_TIME  :  
;               AUTOPREC       :  If set, then PRECISION will automatically be set 
;                                   based on the TIME0 array
;               DELTAT         :  Scalar that will define PRECISION
;               TIMEZONE       :  
;               BADSTRING      :  Scalar string valued used for bad time elements
;               
;
;   CHANGED:  1)  Davin Larson changed something...        [11/01/2002   v1.0.14]
;             2)  Re-wrote and cleaned up                  [09/08/2009   v1.1.0]
;             3)  THEMIS software update includes:
;                 a)  now calls time_substitute.pro
;                 b)  changed significant syntax
;                 c)  Added keywords:  TIMEZONE, LOCAL_TIME, IS_LOCAL_TIME, and BADSTRING
;                                                          [09/08/2009   v1.2.0]
;             4)  Fixed typo created when updating for THEMIS software
;                                                          [09/09/2009   v1.2.1]
;
;   NOTES:      
;               A)  If TFORMAT, then the following keywords are ignored:
;                 1)  FORMAT
;                 2)  SQL
;                 3)  PRECISION
;                 4)  AUTOPREC
;                 5)  DELTAT
;                 6)  DATE_ONLY
;                 7)  MSEC
;               B)  This routine works on vectors and is designed to be fast.
;               C)  Output will have the same dimensions as the input.
;
;   CREATED:  Oct 1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/09/2009   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-03-17/00:50:32 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   time_struct.pro
;  PURPOSE  :   This program returns a data structure for the input time array/structure.
;
;  CALLED BY: 
;               time_ticks.pro
;               time_string.pro
;               time_double.pro
;
;  CALLS:
;               time_struct.pro
;               day_to_year_doy.pro
;               doy_to_month_date.pro
;               time_double.pro
;               time_string.pro
;               dprint.pro
;               isdaylightsavingtime.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               TIME           :  Input time which can have the form of a double
;                                   (Unix times), a string (YYYY-MM-DD/hh:mm:ss), or 
;                                   a structure of the same format as the return 
;                                   structure format.
;
;  EXAMPLES:
;
;  OUTPUT:
;** Structure TIME_STRUCT, 11 tags, length=40:
;   YEAR            INT           1970            ; year    (0-14699)
;   MONTH           INT              1            ; month   (1-12)
;   DATE            INT              1            ; date    (1-31)
;   HOUR            INT              0            ; hours   (0-23)
;   MIN             INT              0            ; minutes (0-59)
;   SEC             INT              0            ; seconds (0-59)
;   FSEC            DOUBLE           0.0000000    ; fractional seconds (0-.999999)
;   DAYNUM          LONG            719162        ; days since 0 AD  (subject to change)
;   DOY             INT              0            ; day of year (1-366)
;   DOW             INT              3            ; day of week  (subject to change)
;   SOD             DOUBLE           0.0000000    ; seconds of day
;
;  KEYWORDS:  
;               EPOCH          :  Set if desired return values are epoch times
;               NO_CLEAN       :  Set if first attempt at structure is desired
;               MMDDYYYY       :  
;               TIMEZONE       :  
;               LOCAL_TIME     :  
;               IS_LOCAL_TIME  :  
;
;      NOTE:
;              This routine works on vectors and is designed to be fast.
;                Output will have the same dimensions as the input
;
;   CHANGED:  1)  Davin Larson changed something...       [11/01/2002   v1.0.15]
;             2)  Re-wrote and cleaned up                 [04/20/2009   v1.1.0]
;             3)  Updated man page                        [06/17/2009   v1.1.1]
;             4)  THEMIS software update includes:
;                 a)  Multiple syntax changes
;                 b)  Now calls:  dprint.pro and isdaylightsavingtime.pro
;                 c)  Added keywords:  MMDDYYYY, TIMEZONE, LOCAL_TIME, and IS_LOCAL_TIME
;                 d)  Changed return structure format
;                                                         [09/08/2009   v1.2.0]
;             5)  Minor superficial changes               [03/16/2010   v1.3.0]
;
;   CREATED:  Oct, 1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  03/16/2010   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2010-03-17/00:42:03 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   time_ticks.pro
;  PURPOSE  :   Returns a structure that can be used to create time ticks for a plot.
;
;  CALLED BY: 
;               tplot.pro
;
;  CALLS:
;               dtime.pro
;               minmax.pro
;               time_double.pro
;               time_struct.pro
;               time_string.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               TIMERANGE     :  2-Element array specifying the time range of the plot
;                                  this input can be obtained from: "time_double", 
;                                  "time_struct", or "time_string"
;               OFFSET        :  Set to a named variable to return the time offset
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               HELP          :  If set, program stops (doesn't help)
;               TICKINTERVAL  :  Time between X-Axis major tick marks
;               SIDE_LABEL    :  Label used to define the X-Axis times shown
;               XTITLE        :  Set to a string to define X-Axis title
;               NUM_LAB_MIN   :  Minimum number of labels for bottom axis
;
; NOTES:
;
;               The returned time_tk_str has tags named so that it can be used
;                 with the special _EXTRA keyword in the call to PLOT or OPLOT.
;
;               The offset value that is returned from timetick must be
;                 subtracted from the time-axis data values before plotting.
;                 This is to maintain resolution in the PLOT routines, which use
;                 single precision floating point internally.  Remember that if
;                 the CURSOR routine is used to read a cursor position from the
;                 plot, this offset will need to be added back to the time-axis
;                 value to get seconds since  1970-01-01/00:00:00.
;
; WARNING!:
;               This routine does not yet work on very small time scales.
;
;   CHANGED:  1)  Davin Larson changed something...       [04/17/2002   v1.0.16]
;             2)  Re-wrote and cleaned up                 [04/20/2009   v1.1.0]
;             3)  Updated man page                        [06/17/2009   v1.1.1]
;             4)  Changed program my_time_struct.pro to time_struct.pro
;                                                         [09/17/2009   v1.2.0]
;             5)  Fixed typo which seemed to only affect long (> 1 month) time
;                   ranges                                [03/16/2010   v1.3.0]
;
;   CREATED:  Oct, 1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  03/16/2010   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


Last Modification =>  2008-06-23/22:23:37 UTC
;+
;FUNCTION:   trange_str,t1,t2
;INPUT:  t1,t2   doubles,   seconds since 1970
;OUTPUT:  string  with the format:  'YYYY-MM-DD/HH:MM:SS - HH:MM:SS'
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)trange_str.pro	1.10 01/23/2008
;    MODIFIED BY: Lynn B. Wilson III
;-


Last Modification =>  2009-06-20/01:14:33 UTC
;+
;*****************************************************************************************
;
;  FUNCTION :   wi.pro
;  PURPOSE  :   Switch or open windows in a slightly easier manner than using the IDL
;                 built-in WINDOW.PRO routine.
;
;  CALLED BY:   NA
;
;  CALLS:
;               data_type.pro
;               str_element.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               WNUM    :  Scalar defining the number of the window to either switch
;                            to or open
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               LIMITS  :  TPLOT structure for plot options
;
;   CHANGED:  1)  Created by REE                           [10/23/1995   v1.0.6]
;             2)  I did something??                        [09/19/2007   v1.0.7]
;             3)  Re-wrote and cleaned up                  [06/10/2009   v1.1.0]
;             4)  Fixed typo in man page                   [06/19/2009   v1.1.1]
;
;   CREATED:  10/23/1995
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/19/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


