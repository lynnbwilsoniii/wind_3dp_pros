Last Modification =>  2008-09-24/15:26:02 UTC
;+
;FUNCTION: date_time_0.pro
;
;PURPOSE: Find Unix time of 12:00 AM for a given date
;
;ARGUMENTS:
;         MTH   -> Month (1-12)
;         DAY   -> Day (1-31)
;         YR    -> Year, full 4-digit year
;
;KEYWORDS: None
;
;RETURNS: Unix time, in seconds
;         0 on error
;
;CALLING SEQUENCE: value=date_time_0(4,24,1997)
;
;NOTES: None
;
;CREATED BY:  John Dombeck  1/11/01
;
;MODIFICATION HISTORY:
;       01/11/01-J. Dombeck     created
;       07/24/01-J. Dombeck     Added input checking
;-


Last Modification =>  2008-08-11/22:00:32 UTC
;+
;FUNCTION: epoch2unix.pro
;
;PURPOSE: Convert CDF Epoch time to Unix time
;
;ARGUMENTS:
;       EPOCHTIME -> Epoch time (Milli-seconds since January 1, year 0)
;
;KEYWORDS: None
;
;RETURNS: Unix time (Seconds since January 1, 1970)
;
;CALLING SEQUENCE: utime=epoch2unix(etime)
;
;NOTES: None
;
;CREATED BY:  John Dombeck  1/11/01
;
;MODIFICATION HISTORY:
;       01/11/01-J. Dombeck     created
;-


Last Modification =>  2008-10-15/19:02:47 UTC
;+
;NAME:fieldrot
;
;PURPOSE: to rotate ac field fluctuations from an arbitrary
;         coordinate system in one with Z aligned along the field direction
;
;INPUTS: DX,DY,DZ the dc field values in the initial coordinate system
;        X,Y,Z the ac field values in the same coordinate system
;
;OUTPUTS:returns the three component vector (fieldx,fieldy,fieldz)
;        which is  the ac field rotated in to the
;        righthanded coord system defined by the direction of DC
;        field vector. In this new coord system Z points along the DC
;        field vector, Y points in the direction perpendicular to the
;        projection of the DC field vector into the plane defined by
;        the original X and Y axes, and X completes the orthogonal
;        right-handed set. 
;
;
;RESTRICTIONS: The initial AC and DC fields must be defined in the
;               same orthogonal right-handed coordinate system
;
;
;EXAMPLE:fields=fieldrot(dcx,dcy,dcz,acx,acy,acz)
;
;
;
; MODIFICATION HISTORY: Chris Chaston, 30-10-96
;
;-


Last Modification =>  2009-02-24/00:08:20 UTC
;+
;FUNCTION: fix_sdt_time,ptr_array,month,day,year
;
;PURPOSE: To convert times of sdt data into standard Unix times
;
;ARGUMENTS:
;	PTR_ARRAY  <> pointer array returned from MREAD_SDT or
;                          array of doubles with zeroth column sdt times
;	MONTH      -> month data was taken
;	DAY        -> day data was taken
;	YEAR       -> year data was taken
;
;RETURNS: status
;           0 - Failure
;           1 - Success
;
;KEYWORDS: N/A
;
;CALLING SEQUENCE: status=fix_sdt_time(ptr_array,mon,day,yr)
;
;NOTES: Original month day and year that data was taken must be known to 
;	use this function.
;
;CREATED BY: Lisa Rassel June 2001
;
;MODIFICATION HISTORY: 
;      06/11/2001-L. Rassel	created
;-


Last Modification =>  2008-09-18/20:57:12 UTC
;+
;FUNCTION: min_var.pro
;
;PURPOSE: Minimum Variance Analysis
;
;ARGUMENTS: 
;    X_DATA   -> X component of original data
;    Y_DATA   -> Y component of original data
;    Z_DATA   -> Z component of original data
;
;
;RETURNS: Minimum variance rotation matix (Eigen vectors, min to max)
;           0 on failure
;
;         The returned matrix is in the rotation matrix form where
;                N = R * O
;           where
;               N = New matrix (Rotated into Min. Var. Coordinates)
;               R = Rotation matrix (Result from MIN_VAR)
;               O = Original matrix
;               * = Standard Matrix Multipication
;
;KEYWORDS:
;    EIG_VALS <- Eigen values of minimum variance analysis (min to max)
;
;CALLING SEQUENCE: 
;       vectors=min_var(data.x,data.y,data.z,eig_vals=values)
;                 or
;       rot_arr=min_var(orig_arr[*,0],orig_arr[*,1],orig_arr[*,2]) ## orig_arr
;                 or
;       rot_arr=orig_arr # min_var(orig_arr[*,0],orig_arr[*,1],orig_arr[*,2])
;                 or
;       rot_arr=orig_arr ##
;                 transpose(min_var(orig_arr[0,*],orig_arr[1,*],orig_arr[2,*]))
;        (These last three forms will crash if min_var fails)
;
;
;NOTES: 
;
;CREATED BY: John Dombeck August 2001
;
;MODIFICATION HISTORY: 
;	08/06/01-J. Dombeck              Created
;-


Last Modification =>  2009-02-24/00:07:09 UTC
;+
;FUNCTION: mread_sdt.pro
;
;PURPOSE: to provide a way to read in single file or array of files
;        used with function read_sdt.pro and pro findstart.pro
;
;ARGUMENTS:
;       FILE_NAME    -> array of names of file to be input
;       DATA_ARRAY   <- name of variable for data to be stored in
;       NAME_ARRAY   <- name of variable for quatity names (and units) to be
;                       stored in
;
;KEYWORDS: 
;       VERBOSE      /  Prints filenames as read
;
;RETURNS: Status
;            0 - Failure
;            1 - Success
;
;CALLING SEQUENCE: status=mread_sdt(file_name_array,data,name)
;                  if status then status=fix_sdt_time(data,month,day,year)
;
;NOTES: Times are listed in UT from day data was taken. Use FIX_SDT_TIME
;       to set time points to standard UT time
;
;       IMPORTANT: Use SDT_FREE on returned pointer array (DATA_ARRAY) to
;                  free associated memory.
;
;CREATED BY: Lisa Rassel May 2001
;
;LAST MODIFICATION: 
;	06/11/2001-L.Rassel	now tracks file names 
;	07/25/2001-J. Dombeck   added VERBOSE keyword
;-


Last Modification =>  2008-10-15/18:33:43 UTC
;+
; NAME:deg_pol 
;
;PURPOSE:To perform polarisation analysis of three orthogonal component time
;         series data.
;
;CALLING SEQUENCE: deg_pol,quanx,quany,quanz,start,totpoints,rotatefield 
;
;
; 
;INPUTS: quanx,quany,quanz:- are the data quantity descriptors (DQDs) of
;        the time series data which must be currently loaded in SDT, 
;        eg 'Mag1ac_S','Mag2ac_S','Mag3ac_S'
;                            OR they are arrays of equal length in IDL         
;        
;        start:- is the start time for the interval to be analysed. If
;        using SDT DQDS this must be given in the format
;        '1996-09-23/16:54:29.20'.If using arrays from inside IDL then
;        you can set this to whatever you like since it is reset to
;        zero anyway.The Start time for all three time series is the same. 
;
;        totpoints:-is the total number of points in the time series
;        to be analysed. Maximum values are set by the maximum array
;        size in IDL and the total time for computation. Maximum values of
;        30000-40000 seem to be reasonable  
;
;        rotatefield:-if set greater than 0.0 deg_pol will iteratively call
;        the subroutine fieldrot to rotate the given time series into a
;        righthanded fieldaligned coordinate system with Z pointing the
;        direction of the ambient magnetic field(see documentation on fieldrot)
;        before performing the
;        polarisation analysis. This option requires that the DQDs 
;       'Mag1dc_S','Mag2dc_S','Mag3dc_S' are currently loaded in
;        SDT and that  quanx,quany,quanz are defined in the same coord
;        system as  'Mag1dc_S','Mag2dc_S','Mag3dc_S'. If the sampling
;        frequency of the dc field data is not the same as the ac data
;        and is less than 32 Hz then the dc and ac data should be
;        despun before running deg_pol. If using arrays from inside
;        IDL setting fieldrot is not invoked.  
;
;
;OUTPUTS: The program outputs five spectral results derived from the
;         fourier transform of the covariance matrix (spectral matrix)
;         and plots each using TPLOT. These are
;         follows:
;         Wave power: On a linear scale, at this stage no units
;         
;         Degree of Polarization: This is similar to a measure of coherency
;                                 between the input
;                                 signals, however unlike coherency it is
;                                 invariant under
;                                 coordinate transformation and can detect pure
;                                 state waves
;                                 which may exist in one channel only.  100%
;                                 indicates a pure
;                                 state wave. Less than 70% indicates noise.
;                                 For more
;                                 information see J. C. Samson and J. V. Olson
;                                 'Some comments
;                                 on the description of the polarization states
;                                 of waves'
;                                 Geophys. J. R. Astr. Soc. (1980) v61 115-130
;
;
;
;         Wavenormal Angle: the angle between the direction of minimum
;                           variance calculated from the complex off diagonal
;                           elements of the spectral matrix and the Z direction
;                           of the input
;                           ac field data. For magnetic field data in
;                           field aligned coordinates this is the
;                           wavenormal angle assuming a plane wave.
;          
;          
;         Ellipticity:The ratio (minor axis)/(major axis) of the
;                     ellipse transcribed by the field variations in the
;                     components transverse to the Z direction. The sign of
;                     indicates the direction of rotation of the field vector in
;                     the plane. Negative signs refer to left-handed
;                     rotation about the Z direction. In the field
;                     aligned coordinate system these signs refer to
;                     plasma waves of left and right handed
;                     polarisation.
; 
;         Helicity:Similar to Ellipticity except defined in terms of the 
;                  direction of minimum variance instead of Z. Stricltly the
;                  Helicity 
;                  is defined in terms of the wavenormal direction or k. 
;                  However since from single point observations the 
;                  sense of k cannot be determined,  helicity here is 
;                  simply the ratio of the minor to major axis transverse to the
;                  minimum variance direction without sign.     
;                                            
;
;RESTRICTIONS:-If one component is an order of magnitude or more  greater than
;             the other two then the polarisation results saturate and
;             erroneously
;             indicate high degrees of polarisation at all times and
;             frequencies. Time series should be eyeballed before running the
;             program. 
;             -For time series containing very rapid changes or spikes
;             the usual problems with Fourier analysis arise.
;             -Care should be taken in evaluating degree of polarisation
;             results. For a
;             meaningful results there should be significant wave power at the
;             frequency where the polarisation approaches
;             100%. Remembercomparing two straight lines yields 100%
;             polarisation. 
;
;
; EXAMPLE:deg_pol, 'Mag1ac_S','Mag2ac_S','Mag3ac_S', '1996-09-23/16:54:29.20',20000,1,'psprnfile' 
;
;
;
; MODIFICATION HISTORY:Written By Chris Chaston, 30-10-96
;                      Modified by Kris Sigsbee before I got it to work with
;                         Polar data, John Dombeck 9/28/98
;                      Further modified to work with despun Polar data and
;                         made it readable in 80 columns,
;                         John Dombeck, 10/19/98
;
;-


Last Modification =>  2008-10-15/18:19:26 UTC
;+
; NAME: POWER_SPEC
;
; PURPOSE: Transform time series data into averaged frequency power
;          spectra using FFT's. Result is the two-sided Power Spectral
;          Density (PSD) given in (input units)^2/Hz.
;
; CALLING SEQUENCE: power_spec, data, n_ave=n_ave, npnts=npts,
;                   sample=sample, freq, ave_spec, overlap=overlap
;
; INPUTS: 
;         DATA -     A one-dimensional array containing the values of
;                    the time series data for which an average power
;                    spectra is desired.
;
; OUTPUTS:
;         FREQ     - An array returned by the routine containing the
;                    frequency axis of the power spectra.
;
;         AVE_SPEC -An array returned by the routine containing the
;                   amplitudes of the power spectra. The units
;                   returned are (input units)^2/Hz. Thus EACH
;                   AMPLITUDE in the FFT is divided by the bandwidth
;                   in Hz of each frequency interval.
;
; KEYWORDS:
;         OVERLAP - Set this keyword to slide the FFT interval by
;                   one-half of an interval instead of averaging
;                   together each separate interval. For most data
;                   types this will yield a higher number of averages
;                   and less error per data point than straight
;                   sequential averaging (see below!). Note that N_AVE
;                   specifies how many sequential averages are taken
;                   without overlap. Thus N_AVE=4 with /OVERLAP yields
;                   a total of 7 averages, etc.
;
;         N_AVE -   The number of FFT's to average together within
;                   the data series provided. This specifies how many
;                   sequential segments in which to divide the
;                   data. Setting the /OVERLAP keyword increases the
;                   number of segments by 2*N_AVE-1.
;
;         NPNTS -   The number of time series points that each
;                   interval will be for the discrete FFT's.
;
;         SAMPLE -   The sample time (in secs) of each time series
;                    point. If unspecified, an arbitrary sample time
;                    of 1 is assigned to the data.
;
; EXAMPLE: You have 8192 continuous time series points. You want to
;          average together 8 FFT's to obtain a single average spectra
;          for this data. Set n_ave = 8, npnts=1024. Result is
;          a power_spectra obtained by taking a single FFT of each
;          1024 pt sequential interval in the data and averaging them
;          together. For the same parameters, if you set /overlap,
;          then the interval slides 1/2 and then averages, i.e. an FFT
;          is taken of the first 1024 points, then moves forward 512
;          points, another FFT, then slide again by 512 points. Thus
;          for num_ave = 8 and /overlap, you average together 8+7 = 15
;          FFT's for the interval of 8192 points.
;
;    A note about errors:
;          For n sequential (non-sliding) averages FFT's have a
;          statistical error of 1/n^0.5. For the same time interval,
;          if a sliding average is used of 1/2 a window overlap, n
;          goes up by a factor of 2 but the errors are no longer
;          completely independent -- so the new error per point is
;          1/(0.81*N)^0.5 -- but N=2n so there is less error per point
;          than in the non-sliding average case. See any of the
;          numerical recipes books by Press et al for a complete
;          description of this and other aspects of computational FFT's.
;
;    A note about the data:
;          Results may not be valid if the number of points per FFT
;          (npts) is not 2^j where j = any integer.
;          This routine assumes that the input data is continuous and
;          that there are no data gaps or bad time points.
;
; REVISION HISTORY
;  ver 1.0 11/15/96 G.T.Delory
;  ver 1.1 03/26/97 G.T.Delory
;  ver 1.2 04/10/97 G.T.Delory
;
;-


Last Modification =>  2010-01-06/00:35:49 UTC
;+
; FUNCTION: read_cdf.pro
;
; PURPOSE: to read a single cdf file and return all the data contained
;
; ARGUMENTS:
;       FILENAME  -> the cdf file name
;       DATA      <- name of variable for the data to be stored in
;       VAR_NAMES <- the original name of the variables
;       ZVARS     <> list of whether or not variables are zvariables
;
; KEYWORDS:
;       NOTIME    /  don't automatically pre-pend times
;       VARNAME   -> Name(s) of CDF variable to return
;       NAMES     /  Only return CDF variable names - Not Data
;
; RETURNS: Status
;            0 - Failure
;            1 - Success
;
; CALLING SEQUENCE: status=read_cdf('filename',data,varnames)
;
; NOTES:
;         IMPORTANT: Use SDT_FREE on returned pointer array (DATA)
;                    to free associated memory.
;
; CREATED BY: Wira Yusoff Sept 2001.
;
; LAST MODIFICATION:
;       09/20/01-W. Yusoff        Created
;       11/20/01-J. Dombeck       Fixed bug in last z-quantity
;       11/24/01-W. Yusoff        Added keyword VARNAME for loading only 
;                                   given variable(s)
;       11/25/01-W. Yusoff        Added function inq_cdfvar,an improved
;                                 version of cdf_varinq
;       11/28/01-J. Dombeck       Added NAMES keyword, ZVARS argument
;       12/03/01-J. Crumley       Fixed sdt_free typos, fixed /NAMES
;       02/09/09-J. Dombeck       Fixed Names keyword
;       01/05/10-L.B. Wilson III  Attempted to make CDF_VARGET.PRO quiet
;-


Last Modification =>  2009-02-24/00:08:39 UTC
;+
;FUNCTION: read_sdt.pro
;
;PURPOSE: To read sdt ascii data files and output data in matrix form.
;
;ARGUMENTS: 
;       FILE_NAME    -> name of file to be input
;       DATA_ARRAY   <- name of variable for data to be stored in
;       NAME_ARRAY   <- name of variable for the quantity name (and units) to
;                       be stored in
;
;KEYWORDS: n/a
;
;RETURNS: Status
;            0 - Failure
;            1 - Success
;
;CALLING SEQUENCE: status=read_sdt('file_name',data,name)
;                  if status then status=fix_sdt_time(data,month,day,year)
;
;NOTES: Use FIX_SDT_TIME to change sdt times to Unix times.
;       Works with mread_sdt if multiple files are to be read.
;
;CREATED BY:   Lisa Rassel May 2001
;
;MODIFICATION HISTORY: 
;	5/18/01- L.Rassel	creation
;	6/11/01- L.Rassel	now finds file name
;       8/14/01- L.Rassel       greatly increase speed (by reading twice)
;       9/6/01 - J.Dombeck      fixed crash if wrong file type
;                                (first line cannot be split)   
;      10/04/01- J.Dombeck      names array to include ['UT','sec']
;      10/22/01- J.Dombeck      fixed FINDSTRT to work with 3.4+ SDT files
;- 
;INCLUDED MODULES:
;   rdsdt_findstart
;   rdsdt_getlength
;   read_sdt
;
;LIBRARIES USED:
;   None
;
;DEPENDANCIES
;   None
;
;-


Last Modification =>  2009-06-17/20:08:12 UTC
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


Last Modification =>  2008-09-24/15:22:24 UTC
;+
;FUNCTION: unix2epoch.pro
;
;PURPOSE: Convert Unix time to CDF Epoch time
;
;ARGUMENTS:
;       UNIXTIME -> Unix time (Seconds since January 1, 1970)
;
;KEYWORDS: None
;
;RETURNS: Epoch time (Milli-seconds since January 1, year 0)
;
;CALLING SEQUENCE: etime=unix2epoch(utime)
;
;NOTES: None
;
;CREATED BY:  John Dombeck  1/11/01
;
;MODIFICATION HISTORY:
;       01/11/01-J. Dombeck     created
;-


Last Modification =>  2008-08-11/22:00:35 UTC
;+
;FUNCTION: ymd2unix.pro
;
;PURPOSE: Convert yyyy,mon,day,hh,mm,ss,msec time to Unix time
;
;ARGUMENTS:
;       YEAR -> integer year
;       MON  -> integer month
;       DAY  -> integer day
;       HH   -> integer hour
;       MM   -> integer minute
;       SS   -> integer second
;       MSEC -> integer millisecond (0-999)
;
;KEYWORDS:
;       (none)
;
;RETURNS: Unix time (Seconds since January 1, 1970)
;
;CALLING SEQUENCE: utime=ymd2unix(year,month,day,hout,minute,second,msecond)
;
;NOTES:
;       Vectorized, all arguments can be either single integer values
;       or arrays of integers.
;-


