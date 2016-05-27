Last Modification =>  2011-04-19/12:37:31 UTC
;+
; NAME:
;       BLOB_ANALYZER__DEFINE
;
; PURPOSE:
; 
;       The purpose of this routine is to create a system for analyzing
;       regions of interest (ROIs) or (more commonly) "blobs" inside images.
;       In particular, given a suitable image (this will require judgement on
;       your part), the program will automatically select "blobs" or connected
;       regions in the image and make it possible for you to analyze these
;       blobs. An example program is provided to show you one way the program
;       can be used.
;       
;       The code is a wrapper, essentially, for LABEL_REGION and HISTOGRAM, with
;       a couple of my other image processing routines (FIND_BOUNDARY and FIT_ELLIPSE)
;       used in a supporting role.
;
; AUTHOR:
; 
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
; 
;       Analysis, Image Processing
;
; CALLING SEQUENCE:
; 
;       analyzer = Obj_New("BLOB_ANALYZER", image)
;
; INPUTS:
; 
;   image:           A two-dimensional image array. To make this program memory efficient,
;                    a copy of the image is *not* stored in the object. You will be responsible
;                    for image operations outside this program.
;
; KEYWORDS:
;
;   ALL_NEIGHBORS:    Set this keyword to look at all eight neighbors when searching
;                     for connectivity. The default is to look for four neighbors on
;                     each side of the starting pixel. Passed directly to LABEL_REGION.
;                     
;   MASK:             A two-dimensional array, the same size as image, that identifies the
;                     foreground and background pixels in the image. Applying the mask
;                     should result in a bi-level image of 0s and 1s, where 1 identifies the 
;                     blobs you wish to analyze. If a mask is not provided, the mask is created
;                     like this:
;                     
;                     mask = image > 0
;
;   SCALE:            A one- or two-dimensional given the pixel scaling parameters. By default [1.0, 1.0].
;                     If passed a scalar, the scale parameter is applied to both the X and Y directions of
;                     each pixel. Statistical output is reported with scaling unless the NOSCALE keyword
;                     is set. Scaling also effects the data that is output from the various methods.
;
; OBJECT METHODS:
; 
;   The following methods are provided. Please see the documentation header for each method for
;   information on arguments and keywords that can be used with the method.
;
;   FitEllipse:       This method fits an ellipse to the blob. It returns information about the fitted
;                     ellipse, including the points that all the ellipse to be drawn.
;                     
;   GetIndices:       This method returns the indices for a particular blob in the image.
;   
;   GetStats:         This method returns a structure containing statistics for a particular blob in the image.
;                     The structure is defined as follows:
;                     
;                     stats = {INDEX: indexNumber, $                  ; The index number of this blob.
;                              COUNT: N_Elements(indices), $          ; The number of indices in this blob.
;                              PERIMETER_PTS: boundaryPts, $          ; A [2,n] array of points that describe the blob perimeter.
;                              PIXEL_AREA: pixelArea, $               ; The area as calculated by pixels in the blob.
;                              PERIMETER_AREA: perimeterArea, $       ; The area as calculated by the blob perimeter. (Smaller than pixel area.)
;                              CENTER: centroid[0:1], $               ; The [x,y] array that identifies the centroid of the blob.
;                              PERIMETER_LENGTH: perimeter_length, $  ; The perimenter length (scaled unless the NOSCALE keyword is set).
;                              SCALE: scale, $                        ; The [xscale, yscale] array used in scaling.
;                              MINCOL: Min(xyindices[0,*]), $         ; The minimum column index in the blob.
;                              MAXCOL: Max(xyindices[0,*]), $         ; The maximum column index in the blob.
;                              MINROW: Min(xyindices[1,*]), $         ; The minimum row index in the blob.
;                              MAXROW: Max(xyindices[1,*])}           ; The maximum row index in the blob.
;   
;   NumberOfBlobs:     The number of blobs identified in the image.
;   
;   ReportStats:       This methods reports statistics on every identified blob in the image. The 
;                      report can be sent to the display (the default) or to a file. The format for
;                      the report works for most images, but you may have to change the format or override
;                      this method for your particular image. The reported statistics are basically the
;                      output of the GetStats and FitEllipse methods.
;
;    Here is an example of statistical output from the example program below.
;    
;  INDEX   NUM_PIXELS   CENTER_X    CENTER_Y   PIXEL_AREA   PERIMETER_AREA   PERIMETER_LENGTH  MAJOR_AXIS   MINOR_AXIS    ANGLE
;     0        426        107.89       9.78       106.50          98.00            37.56          12.15        11.29       -8.05
;     1        580        151.97      10.22       145.00         134.25            49.21          17.49        11.77       -0.99
;     2        812        266.29      15.36       203.00         190.75            52.56          17.88        14.65     -107.48
;     3       1438        204.53      43.29       359.50         344.13            70.23          21.68        21.12      -76.47
;
; RESTRICTIONS:
; 
;       Requires programs from the Coyote Library. At the very least, those below are required.
;       It is *highly* recommended that you install the entire library. FIT_ELLIPSE has been
;       changed specifically for this release, so by sure you get a copy of that with this
;       source code.
;       
;       http://www.dfanning.com/programs/coyoteprograms.zip
;       
;       ERROR_MESSAGE     http://www.dfanning.com/programs/error_message.pro
;       FIND_BOUNDARY     http://www.dfanning.com/programs/find_boundary.pro
;       FIT_ELLIPSE       http://www.dfanning.com/programs/fit_ellipse.pro
;       
;       The program currently works only with 2D bi-level images.
;
; EXAMPLE:
; 
;       To run an example program. Compile the file and type "example" at the IDL command line.
;       
;       IDL> .compile blob_analyzer__define
;       IDL> example
;
; MODIFICATION HISTORY:
; 
;       Written by David W. Fanning, Fanning Software Consulting, 17 August 2008.
;       Ideas taken from discussion with Ben Tupper and Ben's program HBB_ANALYZER.
;-
;+
; NAME:
;  blob_analyzer::FitEllipse
;
; PURPOSE:
;
;   This function fits an ellipse to a particular blob and returns information
;   about the fit to the user.
;
; CALLING SEQUENCE:
;
;   ellipsePts = theBlobs -> FitEllipse(indexNumber)
;
; RETURN VALUE:
;
;     ellipsePts:   A [2,n] array containing the XY points of the fitted ellipse. The values
;                   are in scaled units unless the NOSCALE keyword is set, in which case the
;                   values are in DEVICE units.
;
; ARGUMENTS:
;
;    indexNumber:   The index number of the blob. Indices start at 0 and go to n-1.
;  
; INPUT KEYWORDS:  
; 
;    NOSCALE:       Set this keyword if you would prefer that lengths and positions NOT be
;                   scaled in the output of this function. If not scaled, results are in pixel
;                   or device coordinates. The default is to scale all output.
;                   
;    NPOINTS:       The number of points in the ellipse. By default, 120.
;
; OUTPUT KEYWORDRS:
;
;    AXES:          A two-element array containing the lengths of the major and minor axes,
;                   respectively. Lenghts are scaled unless the NOSCALE keyword is set.
;                   
;    CENTER:        A two-element array containing the [x,y] values of the center of the ellipse.
;                   Values are scaled unless the NOSCALE keyword is set.
;                   
;    ORIENTATION:   The orientation of the ellipse. The value is in degrees counter-clockwise of 
;                   the postive X direction.  Note that a value of 60 is the same as a value of 240.
;                   In other words, there is no direction associated with this value.
;                   
;    SEMIAXES:      A two-element array containing the lengths of the semi-major and semi-minor axes,
;                   respectively. Lenghts are scaled unless the NOSCALE keyword is set. (Half the length
;                   of AXES.
;
;-
;+
; NAME:
;  blob_analyzer::GetIndices
;
; PURPOSE:
;
;   This function returns the indices of a blob to the caller.
;
; CALLING SEQUENCE:
;
;   indices = theBlobs -> GetIndices(indexNumber)
;
; RETURN VALUE:
;
;     indices:     A vector of blob indices that describes the blob in the original image.
;
; ARGUMENTS:
;
;    indexNumber:   The index number of the blob. Indices start at 0 and go to n-1.
;  
; INPUT KEYWORDS:  
; 
;    None.
;
; OUTPUT KEYWORDRS:
;
;    COUNT:         The number of indices in the indices vector.
;                   
;    XSIZE:         The X size of the image from which the blob is taken.
;                   
;    YSIZE:         The Y size of the image from which the blob is taken.
;
;-
;+
; NAME:
;  blob_analyzer::GetStats
;
; PURPOSE:
;
;   This function returns statistics of the blob in question.
;
; CALLING SEQUENCE:
;
;   statistics = theBlobs -> GetStats(indexNumber)
;
; RETURN VALUE:
;
;     statistics:   A structure of statistics that is defined like this.
;     
;                     stats = {INDEX: indexNumber, $                  ; The index number of this blob.
;                              COUNT: N_Elements(indices), $          ; The number of indices in this blob.
;                              PERIMETER_PTS: boundaryPts, $          ; A [2,n] array of points that describe the blob perimeter.
;                              PIXEL_AREA: pixelArea, $               ; The area as calculated by pixels in the blob.
;                              PERIMETER_AREA: perimeterArea, $       ; The area as calculated by the blob perimeter. (Smaller than pixel area.)
;                              CENTER: centroid[0:1], $               ; The [x,y] array that identifies the centroid of the blob.
;                              PERIMETER_LENGTH: perimeter_length, $  ; The perimenter length (scaled unless the NOSCALE keyword is set).
;                              SCALE: scale, $                        ; The [xscale, yscale] array used in scaling.
;                              MINCOL: Min(xyindices[0,*]), $         ; The minimum column index in the blob.
;                              MAXCOL: Max(xyindices[0,*]), $         ; The maximum column index in the blob.
;                              MINROW: Min(xyindices[1,*]), $         ; The minimum row index in the blob.
;                              MAXROW: Max(xyindices[1,*])}           ; The maximum row index in the blob.
;                              
; ARGUMENTS:
;
;    indexNumber:   The index number of the blob. Indices start at 0 and go to n-1.
;  
; INPUT KEYWORDS:  
; 
;    NOSCALE:       Set this keyword if you would prefer that lengths and positions NOT be
;                   scaled in the output of this function. If not scaled, results are in pixel
;                   or device coordinates. The default is to scale all output.
;
; OUTPUT KEYWORDRS:
;
;    INDICES:       A vector of blob indices that describes the blob in the original image.
;                   
;    XYINDICES:     A 2xN array of column/row indices that describes teh blob in the original image.
;    
; NOTES:
; 
;     The statistics are calculated by calling FIND_BOUNDARY from the Coyote Library. This program
;     uses a chain-code algorithm to calculate the perimeter and report the blob area using either of
;     two methods: a strict pixel area (counts the number of pixels in the blob times the scale factor
;     and takes the total), or it uses the perimeter to calculate an area using the method described in
;     Russ, The Image Processing Handbook, 2nd Edition, pp490+. The perimeter area is almost always less 
;     than the pixel area.
;-
;+
; NAME:
;  blob_analyzer::NumberOfBlobs
;
; PURPOSE:
;
;   This function returns the number of blobs in the input image.
;
; CALLING SEQUENCE:
;
;   numBlobs = theBlobs -> NumberOfBlobs()
;   
; RETURN VALUE:
;
;     numBlobs:   The number of blobs in the input image.
;                              
; ARGUMENTS:
;
;    None.
;  
; KEYWORDS:  
; 
;    None.
;-
;+
; NAME:
;  blob_analyzer::ReportStats
;
; PURPOSE:
;
;   This function reports statistics on blobs in the image.
;
; CALLING SEQUENCE:
;
;   theBlobs -> ReportStats
;
; ARGUMENTS:
;
;    None.
;  
; INPUT KEYWORDS:  
; 
;    FILENAME:      The name of a file to contain the statistical output.
; 
;    NOSCALE:       Set this keyword if you would prefer that lengths and positions NOT be
;                   scaled in the output of this function. If not scaled, results are in pixel
;                   or device coordinates. The default is to scale all output.
;
;    TOFILE:         Normally the report is sent to standard ouput. If this keyword is set,
;                    the output is sent to a file.
;
; OUTPUT KEYWORDRS:
;
;    None.
;
; EXAMPLE:
; 
;    Here is an example of statistical output from the example program below.
;    
;  INDEX   NUM_PIXELS   CENTER_X    CENTER_Y   PIXEL_AREA   PERIMETER_AREA   PERIMETER_LENGTH  MAJOR_AXIS   MINOR_AXIS    ANGLE
;     0        426        107.89       9.78       106.50          98.00            37.56          12.15        11.29       -8.05
;     1        580        151.97      10.22       145.00         134.25            49.21          17.49        11.77       -0.99
;     2        812        266.29      15.36       203.00         190.75            52.56          17.88        14.65     -107.48
;     3       1438        204.53      43.29       359.50         344.13            70.23          21.68        21.12      -76.47
;-
;+
; NAME:
;  blob_analyzer::INIT
;
; PURPOSE:
;
;   This function initializes the blob_analyzer object.
;
; CALLING SEQUENCE:
;
;   theBlobs = Obj_New('blob_analyzer', image)
;   
; ARGUMENTS:
;
;   image:           A two-dimensional image array. To make this program memory efficient,
;                    a copy of the image is *not* stored in the object. You will be responsible
;                    for image operations outside this program.
;
; KEYWORDS:
;
;   ALL_NEIGHBORS:    Set this keyword to look at all eight neighbors when searching
;                     for connectivity. The default is to look for four neighbors on
;                     each side of the starting pixel. Passed directly to LABEL_REGION.
;                     
;   MASK:             A two-dimensional array, the same size as image, that identifies the
;                     foreground and background pixels in the image. Applying the mask
;                     should result in a bi-level image of 0s and 1s, where 1 identifies the 
;                     blobs you wish to analyze. If a mask is not provided, the mask is created
;                     like this:
;                     
;                     mask = image > 0
;
;   SCALE:            A one- or two-dimensional given the pixel scaling parameters. By default [1.0, 1.0].
;                     If passed a scalar, the scale parameter is applied to both the X and Y directions of
;                     each pixel. Statistical output is reported with scaling unless the NOSCALE keyword
;                     is set. Scaling also effects the data that is output from the various methods.
;-


Last Modification =>  2008-09-18/14:42:54 UTC
;+
; NAME:
;   COLORBAR
;
; PURPOSE:
;
;       The purpose of this routine is to add a color bar to the current
;       graphics window.
;
; AUTHOR:
;
;   FANNING SOFTWARE CONSULTING
;   David Fanning, Ph.D.
;   1645 Sheely Drive
;   Fort Collins, CO 80526 USA
;   Phone: 970-221-0438
;   E-mail: davidf@dfanning.com
;   Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; CATEGORY:
;
;       Graphics, Widgets.
;
; CALLING SEQUENCE:
;
;       COLORBAR
;
; INPUTS:
;
;       None.
;
; KEYWORD PARAMETERS:
;
;       ANNOTATECOLOR: The name of the "annotation color" to use. The names are those for
;                     FSC_COLOR, and using the keyword implies that FSC_COLOR is also in
;                     your !PATH. If this keyword is used, the annotation color is loaded
;                     *after* the color bar is displayed. The color will be represented
;                     as theColor = FSC_COLOR(ANNOTATECOLOR, COLOR). This keyword is provide
;                     to maintain backward compatibility, but also to solve the problem of
;                     and extra line in the color bar when this kind of syntax is used in
;                     conjunction with the indexed (DEVICE, DECOMPOSED=0) model is used:
;
;                          LoadCT, 33
;                          TVImage, image
;                          Colorbar, Color=FSC_Color('firebrick')
;
;                     The proper syntax for device-independent color is like this:
;
;                          LoadCT, 33
;                          TVImage, image
;                          Colorbar, AnnotateColor='firebrick', Color=255
;
;       BOTTOM:       The lowest color index of the colors to be loaded in
;                     the bar.
;
;       CHARSIZE:     The character size of the color bar annotations. Default is !P.Charsize.
;
;       COLOR:        The color index of the bar outline and characters. Default
;                     is !P.Color..
;
;       DIVISIONS:    The number of divisions to divide the bar into. There will
;                     be (divisions + 1) annotations. The default is 6.
;
;       FONT:         Sets the font of the annotation. Hershey: -1, Hardware:0, True-Type: 1.
;
;       FORMAT:       The format of the bar annotations. Default is '(I0)'.
;
;       INVERTCOLORS: Setting this keyword inverts the colors in the color bar.
;
;       MAXRANGE:     The maximum data value for the bar annotation. Default is
;                     NCOLORS.
;
;       MINRANGE:     The minimum data value for the bar annotation. Default is 0.
;
;       MINOR:        The number of minor tick divisions. Default is 2.
;
;       NCOLORS:      This is the number of colors in the color bar.
;
;       NODISPLAY:    COLORBAR uses FSC_COLOR to specify some of it colors. Normally, 
;                     FSC_COLOR loads "system" colors as part of its palette of colors.
;                     In order to do so, it has to create an IDL widget, which in turn 
;                     has to make a connection to the windowing system. If your program 
;                     is being run without a window connection, then this program will 
;                     fail. If you can live without the system colors (and most people 
;                     don't even know they are there, to tell you the truth), then setting 
;                     this keyword will keep them from being loaded, and you can run
;                     COLORBAR without a display.
;
;       POSITION:     A four-element array of normalized coordinates in the same
;                     form as the POSITION keyword on a plot. Default is
;                     [0.88, 0.10, 0.95, 0.90] for a vertical bar and
;                     [0.10, 0.88, 0.90, 0.95] for a horizontal bar.
;
;       RANGE:        A two-element vector of the form [min, max]. Provides an
;                     alternative way of setting the MINRANGE and MAXRANGE keywords.
;
;       REVERSE:      Setting this keyword reverses the colors in the colorbar.
;
;       RIGHT:        This puts the labels on the right-hand side of a vertical
;                     color bar. It applies only to vertical color bars.
;
;       TICKNAMES:    A string array of names or values for the tick marks.
;
;       TITLE:        This is title for the color bar. The default is to have
;                     no title.
;
;       TOP:          This puts the labels on top of the bar rather than under it.
;                     The keyword only applies if a horizontal color bar is rendered.
;
;       VERTICAL:     Setting this keyword give a vertical color bar. The default
;                     is a horizontal color bar.
;
; COMMON BLOCKS:
;
;       None.
;
; SIDE EFFECTS:
;
;       Color bar is drawn in the current graphics window.
;
; RESTRICTIONS:
;
;       The number of colors available on the graphics display device (not the
;       PostScript device) is used unless the NCOLORS keyword is used.
;
;       Requires the FSC_COLOR program from the Coyote Library:
;
;          http://www.dfanning.com/programs/fsc_color.pro
;
; EXAMPLE:
;
;       To display a horizontal color bar above a contour plot, type:
;
;       LOADCT, 5, NCOLORS=100
;       CONTOUR, DIST(31,41), POSITION=[0.15, 0.15, 0.95, 0.75], $
;          C_COLORS=INDGEN(25)*4, NLEVELS=25
;       COLORBAR, NCOLORS=100, POSITION=[0.15, 0.85, 0.95, 0.90]
;
; MODIFICATION HISTORY:
;
;       Written by: David W. Fanning, 10 JUNE 96.
;       10/27/96: Added the ability to send output to PostScript. DWF
;       11/4/96: Substantially rewritten to go to screen or PostScript
;           file without having to know much about the PostScript device
;           or even what the current graphics device is. DWF
;       1/27/97: Added the RIGHT and TOP keywords. Also modified the
;            way the TITLE keyword works. DWF
;       7/15/97: Fixed a problem some machines have with plots that have
;            no valid data range in them. DWF
;       12/5/98: Fixed a problem in how the colorbar image is created that
;            seemed to tickle a bug in some versions of IDL. DWF.
;       1/12/99: Fixed a problem caused by RSI fixing a bug in IDL 5.2. Sigh... DWF.
;       3/30/99: Modified a few of the defaults. DWF.
;       3/30/99: Used NORMAL rather than DEVICE coords for positioning bar. DWF.
;       3/30/99: Added the RANGE keyword. DWF.
;       3/30/99: Added FONT keyword. DWF
;       5/6/99: Many modifications to defaults. DWF.
;       5/6/99: Removed PSCOLOR keyword. DWF.
;       5/6/99: Improved error handling on position coordinates. DWF.
;       5/6/99. Added MINOR keyword. DWF.
;       5/6/99: Set Device, Decomposed=0 if necessary. DWF.
;       2/9/99: Fixed a problem caused by setting BOTTOM keyword, but not NCOLORS. DWF.
;       8/17/99. Fixed a problem with ambiguous MIN and MINOR keywords. DWF
;       8/25/99. I think I *finally* got the BOTTOM/NCOLORS thing sorted out. :-( DWF.
;       10/10/99. Modified the program so that current plot and map coordinates are
;            saved and restored after the colorbar is drawn. DWF.
;       3/18/00. Moved a block of code to prevent a problem with color decomposition. DWF.
;       4/28/00. Made !P.Font default value for FONT keyword. DWF.
;       9/26/00. Made the code more general for scalable pixel devices. DWF.
;       1/16/01. Added INVERTCOLORS keyword. DWF.
;       5/11/04. Added TICKNAME keyword. DWF.
;       9/29/05. Added REVERSE keywords, which does the *exact* same thing as
;           INVERTCOLORS, but I can never remember the latter keyword name. DWF.
;       1/2/07. Added ANNOTATECOLOR keyword. DWF.
;       4/14/07. Changed the default FORMAT to I0. DWF.
;       5/1/07. Unexpected consequence of default format change is colorbar annotations
;           no longer match contour plot levels. Changed to explicit formating of
;           colorbar axis labels before PLOT command. DWF.
;       5/25/07. Previous change has unanticipated effect on color bars using
;           logarithmic scaling, which is not really supported, but I have an
;           article on my web page describing how to do it: http://www.dfanning.com/graphics_tips/logcb.html.
;           Thus, I've fixed the program to accommodate log scaling, while still not OFFICIALLY
;           supporting it. DWF.
;       10/3/07. Method used to calculate TICKNAMES produces incorrect values in certain cases when
;           the min and max range values are integers. Now force range values to be floats. DWF.
;       10/17/07. Accidentaly use of INTERP keyword in CONGRID results in wrong bar values for
;           low NCOLORS numbers when INVERTCOLORS or REVERSE keyword is used. Removed INTERP keyword. DWF.
;       11/10/07. Finished fixing program to accommodate log scaling in ALL possible permutations. DWF.
;       8 Feb 2008. Added CRONJOB keyword and decided to use month names when I write the date. DWF.
;       8 Feb 2008. Renamed CRONJOB to NODISPLAY to better reflect its purpose. DWF.
;      21 May 2008. Changed the default CHARSIZE to !P.CHARSIZE from 1.0. DWF.
;-


Last Modification =>  2009-06-15/20:41:59 UTC
;+
; NAME:
;       CONVERT_TO_TYPE
;
; PURPOSE:
;
;       Converts its input argument to a specified data type.
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Utilities
;
; CALLING SEQUENCE:
;
;       result = Convert_To_Type(input, type)
;
; INPUT_PARAMETERS:
;
;       input:          The input data to be converted.
;       type:           The data type. Accepts values as given by Size(var, /TNAME) or Size(var, /TYPE).
;                       If converting to integer types, values are truncated (similar to FLOOR keyword below),
;                       unless keywords are set.
;
; OUTPUT_PARAMETERS:
;
;      result:          The input data is converted to specified data type.
;
; KEYWORDS:
;
;     CEILING:          If set and converting to an integer type, the CEIL function is applied before conversion.
;
;     FLOOR:            If set and converting to an integer type, the FLOOR function is applied before conversion.
;
;     ROUND:            If set and converting to an integer type, the ROUND function is applied before conversion.
;
;
; RESTRICTIONS:
;
;     Data types STRUCT, POINTER, and OBJREF are not allowed.
;
; MODIFICATION HISTORY:
;
;     Written by David W. Fanning, 19 February 2006.
;     Typo had "UNIT" instead of "UINT". 23 February 2009. DWF.
;     Added CEILING, FLOOR, and ROUND keywords. 1 April 2009. DWF.
;-


Last Modification =>  2011-04-21/01:46:22 UTC
;+
; NAME:
;       CONVEXHULL
; PURPOSE:
;       Return the convex hull of a polygon.
; CATEGORY:
; CALLING SEQUENCE:
;       convexhull, x, y, xh, yh
; INPUTS:
;       x,y = original polygon vertices.       in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xh,yh = convex hull polygon vertices.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: The convex hull of a polygon is the minimum polygon
;         that circumscribes the original polygon.  It is the shape
;         a rubber band would take if placed around the original
;         polygon.
; MODIFICATION HISTORY:
;       R. Sterner, 2 Oct, 1990
;       R. Sterner, 26 Feb, 1991 --- renamed from convex_hull.pro
;
; Copyright (C) 1990, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-


Last Modification =>  2011-04-19/12:36:23 UTC
;+
; NAME:
;    error_message
;
; PURPOSE:
;
;    The purpose of this function  is to have a device-independent
;    error messaging function. The error message is reported
;    to the user by using DIALOG_MESSAGE if widgets are
;    supported and MESSAGE otherwise.
;
;    In general, the error_message function is not called directly.
;    Rather, it is used in a CATCH error handler. Errors are thrown
;    to error_message with the MESSAGE command. A typical CATCH error
;    handler is shown below.
;
;       Catch, theError
;       IF theError NE 0 THEN BEGIN
;          Catch, /Cancel
;          void = Error_Message()
;          RETURN
;       ENDIF
;
;    Error messages would get into the error_message function by
;    throwing an error with the MESSAGE command, like this:
;
;       IF test NE 1 THEN Message, 'The test failed.'
;
; AUTHOR:
;
;   FANNING SOFTWARE CONSULTING
;   David Fanning, Ph.D.
;   1645 Sheely Drive
;   Fort Collins, CO 80526 USA
;   Phone: 970-221-0438
;   E-mail: davidf@dfanning.com
;   Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; CATEGORY:
;
;    Utility.
;
; CALLING SEQUENCE:
;
;    ok = Error_Message(the_Error_Message)
;
; INPUTS:
;
;    the_Error_Message: This is a string argument containing the error
;       message you want reported. If undefined, this variable is set
;       to the string in the !Error_State.Msg system variable.
;
; KEYWORDS:
;
;    ERROR: Set this keyword to cause Dialog_Message to use the ERROR
;       reporting dialog. Note that a bug in IDL causes the ERROR dialog
;       to be used whether this keyword is set to 0 or 1!
;
;    INFORMATIONAL: Set this keyword to cause Dialog_Message to use the
;       INFORMATION dialog instead of the WARNING dialog. Note that a bug
;       in IDL causes the ERROR dialog to be used if this keyword is set to 0!
;       
;    NONAME: Normally, the name of the routine in which the error occurs is
;       added to the error message. Setting this keyword will suppress this
;       behavior.
;
;    TITLE: Set this keyword to the title of the DIALOG_MESSAGE window. By
;       default the keyword is set to 'System Error' unless !ERROR_STATE.NAME
;       equals "IDL_M_USER_ERR", in which case it is set to "Trapped Error'.
;
;    TRACEBACK: Setting this keyword results in an error traceback
;       being printed to standard output with the PRINT command. Set to
;       1 (ON) by default. Use TRACEBACK=0 to turn this functionality off.
;       
;    QUIET: Set this keyword to suppress the DIALOG_MESSAGE pop-up dialog.
;
; OUTPUTS:
;
;    Currently the only output from the function is the string "OK".
;
; RESTRICTIONS:
;
;    The WARNING Dialog_Message dialog is used by default.
;
; EXAMPLE:
;
;    To handle an undefined variable error:
;
;    IF N_Elements(variable) EQ 0 THEN $
;       ok = Error_Message('Variable is undefined')
;
; MODIFICATION HISTORY:
;
;    Written by: David W. Fanning, 27 April 1999.
;    Added the calling routine's name in the message and NoName keyword. 31 Jan 2000. DWF.
;    Added _Extra keyword. 10 February 2000. DWF.
;    Forgot to add _Extra everywhere. Fixed for MAIN errors. 8 AUG 2000. DWF.
;    Adding call routine's name to Traceback Report. 8 AUG 2000. DWF.
;    Added ERROR, INFORMATIONAL, and TITLE keywords. 19 SEP 2002. DWF.
;    Removed the requirement that you use the NONAME keyword with the MESSAGE
;      command when generating user-trapped errors. 19 SEP 2002. DWF.
;    Added distinctions between trapped errors (errors generated with the
;      MESSAGE command) and IDL system errors. Note that if you call error_message
;      directly, then the state of the !ERROR_STATE.NAME variable is set
;      to the *last* error generated. It is better to access error_message
;      indirectly in a Catch error handler from the MESSAGE command. 19 SEP 2002. DWF.
;    Change on 19 SEP 2002 to eliminate NONAME requirement did not apply to object methods.
;      Fixed program to also handle messages from object methods. 30 JULY 2003. DWF.
;    Removed obsolete STR_SEP and replaced with STRSPLIT. 27 Oct 2004. DWF.
;    Made a traceback the default case without setting TRACEBACK keyword. 19 Nov 2004. DWF.
;    Added check for window connection specifically for CRON jobs. 6 May 2008. DWF.
;    Added QUIET keyword. 18 October 2008. DWF.
;    The traceback information was bypassed when in the PostScript device. Not what I
;      had in mind. Fixed. 6 July 2009. DWF.
;-


Last Modification =>  2011-04-19/12:59:40 UTC
;+
; NAME:
;       FIND_BOUNDARY
;
; PURPOSE:
;
;       This program finds the boundary points about a region of interest (ROI)
;       represented by pixel indices. It uses a "chain-code" algorithm for finding
;       the boundary pixels.
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Graphics, math.
;
; CALLING SEQUENCE:
;
;       boundaryPts = Find_Boundary(indices, XSize=xsize, YSize=ysize)
;
; OPTIONAL INPUTS:
;
;       indices - A 1D vector of pixel indices that describe the ROI. For example,
;            the indices may be returned as a result of the WHERE function.
;
; OUTPUTS:
;
;       boundaryPts - A 2-by-n points array of the X and Y points that describe the
;            boundary. The points are scaled if the SCALE keyword is used.
;
; INPUT KEYWORDS:
;
;       SCALE - A one-element or two-element array of the pixel scale factors, [xscale, yscale],
;            used to calculate the perimeter length or area of the ROI. The SCALE keyword is
;            NOT applied to the boundary points. By default, SCALE=[1,1].
;
;       XSIZE - The X size of the window or array from which the ROI indices are taken.
;            Set to !D.X_Size by default.
;
;       YSIZE - The Y size of the window or array from which the ROI indices are taken.
;            Set to !D.Y_Size by default.
;
; OUTPUT KEYWORDS:
;
;       AREA - A named variable that contains the pixel area represented by the input pixel indices,
;            scaled by the SCALE factors.
;
;       CENTER - A named variable that contains a two-element array containing the center point or
;            centroid of the ROI. The centroid is the position in the ROI that the ROI would
;            balance on if all the index pixels were equally weighted. The output is a two-element
;            floating-point array in device coordinate system, unless the SCALE keyword is used,
;            in which case the values will be in the scaled coordinate system.
;
;       PERIM_AREA - A named variable that contains the (scaled) area represented by the perimeter
;            points, as indicated by John Russ in _The Image Processing Handbook, 2nd Edition_ on
;            page 490. This is the same "perimeter" that is returned by IDLanROI in its
;            ComputeGeometry method, for example. In general, the perimeter area will be
;            smaller than the pixel area.
;
;       PERIMETER - A named variable that will contain the perimeter length of the boundary
;            upon returning from the function, scaled by the SCALE factors.
;
;  EXAMPLE:
;
;       LoadCT, 0, /Silent
;       image = BytArr(400, 300)+125
;       image[125:175, 180:245] = 255B
;       indices = Where(image EQ 255)
;       Window, XSize=400, YSize=300
;       TV, image
;       PLOTS, find_boundary(indices, XSize=400, YSize=300, Perimeter=length), $
;           /Device, Color=cgColor('red')
;       Print, length
;           230.0
;
; DEPENDENCIES:
;
;       Requires error_message from the Coyote Library.
;
;           http://www.dfanning.com/programs/error_message.pro
;
; MODIFICATION HISTORY:
;
;       Written by David W. Fanning, April 2002. Based on an algorithm written by Guy
;       Blanchard and provided by Richard Adams.
;       Fixed a problem with distinction between solitary points and
;          isolated points (a single point connected on a diagonal to
;          the rest of the mask) in which the program can't get back to
;          the starting pixel. 2 Nov 2002. DWF
;       Added the ability to return the perimeter length with PERIMETER and
;           SCALE keywords. 2 Nov 2002. DWF.
;       Added AREA keyword to return area enclosed by boundary. 2 Nov 2002. DWF.
;       Fixed a problem with POLYFILLV under-reporting the area by removing
;           POLYFILLV and using a pixel counting method. 10 Dec 2002. DWF.
;       Added the PERIM_AREA and CENTER keywords. 15 December 2002. DWF.
;       Replaced the error_message routine with the latest version. 15 December 2002. DWF.
;       Fixed a problem in which XSIZE and YSIZE have to be specified as integers to work. 6 March 2006. DWF.
;       Fixed a small problem with very small ROIs that caused the program to crash. 1 October 2008. DWF.
;       Modified the algorithm that determines the number of boundary points for small ROIs. 28 Sept 2010. DWF.
;-


Last Modification =>  2011-04-19/12:31:57 UTC
;+
; NAME:
;       fit_ellipse
;
; PURPOSE:
;
;       This program fits an ellipse to an ROI given by a vector of ROI indices.
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Graphics, math.
;
; CALLING SEQUENCE:
;
;       ellipsePts = Fit_Ellipse(indices)
;
; OPTIONAL INPUTS:
;
;       indices - A 1D vector of pixel indices that describe the ROI. For example,
;            the indices may be returned as a result of the WHERE function.
;
; OUTPUTS:
;
;       ellipsePts - A 2-by-npoints array of the X and Y points that describe the
;            fitted ellipse. The points are in the device coodinate system.
;
; INPUT KEYWORDS:
;
;       NPOINTS - The number of points in the fitted ellipse. Set to 120 by default.
;       
;       SCALE - A two-element array that gives the scaling parameters for each X and Y pixel, respectively.
;            Set to [1.0,1.0] by default.
;
;       XSIZE - The X size of the window or array from which the ROI indices are taken.
;            Set to !D.X_Size by default.
;
;       YSIZE - The Y size of the window or array from which the ROI indices are taken.
;            Set to !D.Y_Size by default.
;
; OUTPUT KEYWORDS:
;
;       CENTER -- Set to a named variable that contains the X and Y location of the center
;            of the fitted ellipse in device coordinates.
;
;       ORIENTATION - Set to a named variable that contains the orientation of the major
;            axis of the fitted ellipse. The direction is calculated in degrees
;            counter-clockwise from the X axis.
;
;       AXES - A two element array that contains the length of the major and minor
;            axes of the fitted ellipse, respectively.
;
;       SEMIAXES - A two element array that contains the length of the semi-major and semi-minor
;            axes of the fitted ellipse, respectively. (This is simple AXES/2.)
;
;  EXAMPLE:
;
;       LoadCT, 0, /Silent
;       image = BytArr(400, 300)+125
;       image[180:245, 125:175] = 255B
;       indices = Where(image EQ 255)
;       Window, XSize=400, YSize=300
;       TV, image
;       PLOTS, Fit_Ellipse(indices, XSize=400, YSize=300), /Device, Color=cgColor('red')
;
; MODIFICATION HISTORY:
;
;       Written by David W. Fanning, April 2002. Based on algorithms provided by Craig Markwardt
;            and Wayne Landsman in his TVEllipse program.
;       Added SCALE keyword and modified the algorithm to use memory more efficiently.
;            I no longer have to make huge arrays. The arrays are only as big as the blob
;            being fitted. 17 AUG 2008. DWF.
;       Fixed small typo that caused blobs of indices with a longer X axis than Y axis
;            to misrepresent the center of the ellipse. 23 February 2009.
;-


Last Modification =>  2009-06-15/20:41:50 UTC
;+
; NAME:
;       FPUFIX
;
; PURPOSE:
;
;       This is a utility routine to examine a variable and fix problems
;       that will create floating point underflow errors.
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Utilities
;
; CALLING SEQUENCE:
;
;       fixedData = FPUFIX(data)
;
; ARGUMENTS:
;
;       data :         A numerical variable to be checked for values that will cause
;                      floating point underflow errors. Suspect values are set to 0.
;
; KEYWORDS:
;
;       None.
; RETURN VALUE:
;
;       fixedData:    The output is the same as the input, except that any values that
;                     will cause subsequent floating point underflow errors are set to 0.
;
; COMMON BLOCKS:
;       None.
;
; EXAMPLES:
;
;       data = FPTFIX(data)
;
; RESTRICTIONS:
;
;     None.
;
; MODIFICATION HISTORY:
;
;       Written by David W. Fanning, from Mati Meron's example FPU_FIX. Mati's
;          program is more robust that this (ftp://cars3.uchicago.edu/midl/),
;          but this serves my needs and doesn't require other programs from
;          Mati's library.  24 February 2006.
;-


Last Modification =>  2008-09-18/14:40:58 UTC
;+
; NAME:
;       FSC_COLOR
;
; PURPOSE:
;
;       The purpose of this function is to obtain drawing colors
;       by name and in a device/decomposition independent way.
;       The color names and values may be read in as a file, or 104 color
;       names and values are supplied with the program. These colors were
;       obtained from the file rgb.txt, found on most X-Window distributions.
;       Representative colors were chosen from across the color spectrum. To
;       see a list of colors available, type:
;
;          Print, FSC_Color(/Names), Format='(6A18)'
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING:
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Graphics, Color Specification.
;
; CALLING SEQUENCE:
;
;       color = FSC_Color(theColor, theColorIndex)
;
; NORMAL CALLING SEQUENCE FOR DEVICE-INDEPENDENT COLOR:
;
;       If you write your graphics code *exactly* as it is written below, then
;       the same code will work in all graphics devices I have tested.
;       These include the PRINTER, PS, and Z devices, as well as X, WIN, and MAC.
;
;       In practice, graphics code is seldom written like this. (For a variety of
;       reasons, but laziness is high on the list.) So I have made the
;       program reasonably tolerant of poor programming practices. I just
;       point this out as a place you might return to before you write me
;       a nice note saying my program "doesn't work". :-)
;
;       axisColor = FSC_Color("Green", !D.Table_Size-2)
;       backColor = FSC_Color("Charcoal", !D.Table_Size-3)
;       dataColor = FSC_Color("Yellow", !D.Table_Size-4)
;       thisDevice = !D.Name
;       Set_Plot, 'toWhateverYourDeviceIsGoingToBe', /Copy
;       Device, .... ; Whatever you need here to set things up properly.
;       IF (!D.Flags AND 256) EQ 0 THEN $
;         POLYFILL, [0,1,1,0,0], [0,0,1,1,0], /Normal, Color=backColor
;       Plot, Findgen(11), Color=axisColor, Background=backColor, /NoData, $
;          NoErase= ((!D.Flags AND 256) EQ 0)
;       OPlot, Findgen(11), Color=dataColor
;       Device, .... ; Whatever you need here to wrap things up properly.
;       Set_Plot, thisDevice
;
; OPTIONAL INPUT PARAMETERS:
;
;       theColor: A string with the "name" of the color. To see a list
;           of the color names available set the NAMES keyword. This may
;           also be a vector of color names. Colors available are these:
;
;           Active            Almond     Antique White        Aquamarine             Beige            Bisque
;             Black              Blue       Blue Violet             Brown         Burlywood        Cadet Blue
;          Charcoal        Chartreuse         Chocolate             Coral   Cornflower Blue          Cornsilk
;           Crimson              Cyan    Dark Goldenrod         Dark Gray        Dark Green        Dark Khaki
;       Dark Orchid          Dark Red       Dark Salmon   Dark Slate Blue         Deep Pink       Dodger Blue
;              Edge              Face         Firebrick      Forest Green             Frame              Gold
;         Goldenrod              Gray             Green      Green Yellow         Highlight          Honeydew
;          Hot Pink        Indian Red             Ivory             Khaki          Lavender        Lawn Green
;       Light Coral        Light Cyan        Light Gray      Light Salmon   Light Sea Green      Light Yellow
;        Lime Green             Linen           Magenta            Maroon       Medium Gray     Medium Orchid
;          Moccasin              Navy             Olive        Olive Drab            Orange        Orange Red
;            Orchid    Pale Goldenrod        Pale Green            Papaya              Peru              Pink
;              Plum       Powder Blue            Purple               Red              Rose        Rosy Brown
;        Royal Blue      Saddle Brown            Salmon       Sandy Brown         Sea Green          Seashell
;          Selected            Shadow            Sienna          Sky Blue        Slate Blue        Slate Gray
;              Snow      Spring Green        Steel Blue               Tan              Teal              Text
;           Thistle            Tomato         Turquoise            Violet        Violet Red             Wheat
;             White            Yellow
;
;           In addition, these system colors are available if a connection to the window system is available.
;
;           Frame   Text   Active   Shadow   Highlight   Edge   Selected   Face
;
;           The color WHITE is used if this parameter is absent or a color name is mis-spelled. To see a list
;           of the color names available in the program, type this:
;
;              IDL> Print, FSC_Color(/Names), Format='(6A18)'
;
;       theColorIndex: The color table index (or vector of indices the same length
;           as the color name vector) where the specified color is loaded. The color table
;           index parameter should always be used if you wish to obtain a color value in a
;           color-decomposition-independent way in your code. See the NORMAL CALLING
;           SEQUENCE for details. If theColor is a vector, and theColorIndex is a scalar,
;           then the colors will be loaded starting at theColorIndex.
;
;        When the BREWER keyword is set, you must use more arbitrary and less descriptive color
;        names. To see a list of those names, use the command above with the BREWER keyword set,
;        or call PICKCOLORNAME with the BREWER keyword set:
;
;               IDL> Print, FSC_Color(/Names, /BREWER), Format='(8A10)'
;               IDL> color = PickColorName(/BREWER)
;
;         Here are the Brewer names:
;
;       WT1       WT2       WT3       WT4       WT5       WT6       WT7       WT8
;      TAN1      TAN2      TAN3      TAN4      TAN5      TAN6      TAN7      TAN8
;      BLK1      BLK2      BLK3      BLK4      BLK5      BLK6      BLK7      BLK8
;      GRN1      GRN2      GRN3      GRN4      GRN5      GRN6      GRN7      GRN8
;      BLU1      BLU2      BLU3      BLU4      BLU5      BLU6      BLU7      BLU8
;      ORG1      ORG2      ORG3      ORG4      ORG5      ORG6      ORG7      ORG8
;      RED1      RED2      RED3      RED4      RED5      RED6      RED7      RED8
;      PUR1      PUR2      PUR3      PUR4      PUR5      PUR6      PUR7      PUR8
;      PBG1      PBG2      PBG3      PBG4      PBG5      PBG6      PBG7      PBG8
;      YGB1      YGB2      YGB3      YGB4      YGB5      YGB6      YGB7      YGB8
;      RYB1      RYB2      RYB3      RYB4      RYB5      RYB6      RYB7      RYB8
;       TG1       TG2       TG3       TG4       TG5       TG6       TG7       TG8
;
;       As of 3 July 2008, the Brewer names are also now available to the user without using 
;       the BREWER keyword. If the BREWER keyword is used, *only* Brewer names are available.
;       
; RETURN VALUE:
;
;       The value that is returned by FSC_Color depends upon the keywords
;       used to call it, on the version of IDL you are using,and on the depth
;       of the display device when the program is invoked. In general,
;       the return value will be either a color index number where the specified
;       color is loaded by the program, or a 24-bit color value that can be
;       decomposed into the specified color on true-color systems. (Or a vector
;       of such numbers.)
;
;       If you are running IDL 5.2 or higher, the program will determine which
;       return value to use, based on the color decomposition state at the time
;       the program is called. If you are running a version of IDL before IDL 5.2,
;       then the program will return the color index number. This behavior can
;       be overruled in all versions of IDL by setting the DECOMPOSED keyword.
;       If this keyword is 0, the program always returns a color index number. If
;       the keyword is 1, the program always returns a 24-bit color value.
;
;       If the TRIPLE keyword is set, the program always returns the color triple,
;       no matter what the current decomposition state or the value of the DECOMPOSED
;       keyword. Normally, the color triple is returned as a 1 by 3 column vector.
;       This is appropriate for loading into a color index with TVLCT:
;
;          IDL> TVLCT, FSC_Color('Yellow', /Triple), !P.Color
;
;       But sometimes (e.g, in object graphics applications) you want the color
;       returned as a row vector. In this case, you should set the ROW keyword
;       as well as the TRIPLE keyword:
;
;          viewobj= Obj_New('IDLgrView', Color=FSC_Color('charcoal', /Triple, /Row))
;
;       If the ALLCOLORS keyword is used, then instead of a single value, modified
;       as described above, then all the color values are returned in an array. In
;       other words, the return value will be either an NCOLORS-element vector of color
;       table index numbers, an NCOLORS-element vector of 24-bit color values, or
;       an NCOLORS-by-3 array of color triples.
;
;       If the NAMES keyword is set, the program returns a vector of
;       color names known to the program.
;
;       If the color index parameter is not used, and a 24-bit value is not being
;       returned, then colorIndex is typically set to !D.Table_Size-1. However,
;       this behavior is changed on 8-bit devices (e.g., the PostScript device,
;       or the Z-graphics buffer) and on 24-bit devices that are *not* using
;       decomposed color. On these devices, the colors are loaded at an
;       offset of !D.Table_Size - ncolors - 2, and the color index parameter reflects
;       the actual index of the color where it will be loaded. This makes it possible
;       to use a formulation as below:
;
;          Plot, data, Color=FSC_Color('Dodger Blue')
;
;       on 24-bit displays *and* in PostScript output! Note that if you specify a color
;       index (the safest thing to do), then it will always be honored.
;
; INPUT KEYWORD PARAMETERS:
;
;       ALLCOLORS: Set this keyword to return indices, or 24-bit values, or color
;              triples, for all the known colors, instead of for a single color.
;
;       BREWER: Set this keyword if you wish to use the Brewer Colors, as defined
;              in this reference:
;
;              http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_intro.html
;              
;              As of 3 July 2008, the BREWER names are always available to the user, with or
;              without this keyword. If the keyword is used, only BREWER names are available.
;
;       DECOMPOSED: Set this keyword to 0 or 1 to force the return value to be
;              a color table index or a 24-bit color value, respectively.
;
;       CHECK_CONNECTION: If this keyword is set, the program will check to see if it can obtain
;              a window connection before it tries to load system colors (which require one). If you
;              think you might be using FSC_COLOR in a cron job, for example, you would want to set this
;              keyword. If there is no window connection, the system colors are not available from the program.
;
;       FILENAME: The string name of an ASCII file that can be opened to read in
;              color values and color names. There should be one color per row
;              in the file. Please be sure there are no blank lines in the file.
;              The format of each row should be:
;
;                  redValue  greenValue  blueValue  colorName
;
;              Color values should be between 0 and 255. Any kind of white-space
;              separation (blank characters, commas, or tabs) are allowed. The color
;              name should be a string, but it should NOT be in quotes. A typical
;              entry into the file would look like this:
;
;                  255   255   0   Yellow
;
;       NAMES: If this keyword is set, the return value of the function is
;              a ncolors-element string array containing the names of the colors.
;              These names would be appropriate, for example, in building
;              a list widget with the names of the colors. If the NAMES
;              keyword is set, the COLOR and INDEX parameters are ignored.
;
;                 listID = Widget_List(baseID, Value=GetColor(/Names), YSize=16)
;
;
;       NODISPLAY: Normally, FSC_COLOR loads "system" colors as part of its palette of colors.
;              In order to do so, it has to create an IDL widget, which in turn has to make
;              a connection to the windowing system. If your program is being run without a 
;              window connection, then this program will fail. If you can live without the system 
;              colors (and most people don't even know they are there, to tell you the truth), 
;              then setting this keyword will keep them from being loaded, and you can run
;              FSC_COLOR without a display. THIS KEYWORD NOW DEPRECIATED IN FAVOR OF CHECK_CONNECTION.
;
;       ROW:   If this keyword is set, the return value of the function when the TRIPLE
;              keyword is set is returned as a row vector, rather than as the default
;              column vector. This is required, for example, when you are trying to
;              use the return value to set the color for object graphics objects. This
;              keyword is completely ignored, except when used in combination with the
;              TRIPLE keyword.
;
;       SELECTCOLOR: Set this keyword if you would like to select the color name with
;              the PICKCOLORNAME program. Selecting this keyword automaticallys sets
;              the INDEX positional parameter. If this keyword is used, any keywords
;              appropriate for PICKCOLORNAME can also be used. If this keyword is used,
;              the first positional parameter can be either a color name or the color
;              table index number. The program will figure out what you want.
;
;       TRIPLE: Setting this keyword will force the return value of the function to
;              *always* be a color triple, regardless of color decomposition state or
;              visual depth of the machine. The value will be a three-element column
;              vector unless the ROW keyword is also set.
;
;       In addition, any keyword parameter appropriate for PICKCOLORNAME can be used.
;       These include BOTTOM, COLUMNS, GROUP_LEADER, INDEX, and TITLE.
;
; OUTPUT KEYWORD PARAMETERS:
;
;       CANCEL: This keyword is always set to 0, unless that SELECTCOLOR keyword is used.
;              Then it will correspond to the value of the CANCEL output keyword in PICKCOLORNAME.
;
;       COLORSTRUCTURE: This output keyword (if set to a named variable) will return a
;              structure in which the fields will be the known color names (without spaces)
;              and the values of the fields will be either color table index numbers or
;              24-bit color values. If you have specified a vector of color names, then
;              this will be a structure containing just those color names as fields.
;
;       NCOLORS: The number of colors recognized by the program. It will be 104 by default.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;
;   Required programs from the Coyote Library:
;
;      http://www.dfanning.com/programs/error_message.pro
;      http://www.dfanning.com/programs/pickcolorname.pro
;
; EXAMPLE:
;
;       To get drawing colors in a device-decomposed independent way:
;
;           axisColor = FSC_Color("Green", !D.Table_Size-2)
;           backColor = FSC_Color("Charcoal", !D.Table_Size-3)
;           dataColor = FSC_Color("Yellow", !D.Table_Size-4)
;           Plot, Findgen(11), Color=axisColor, Background=backColor, /NoData
;           OPlot, Findgen(11), Color=dataColor
;
;       To set the viewport color in object graphics:
;
;           theView = Obj_New('IDLgrView', Color=FSC_Color('Charcoal', /Triple))
;
;       To change the viewport color later:
;
;           theView->SetProperty, Color=FSC_Color('Antique White', /Triple)
;
;       To load the drawing colors "red", "green", and "yellow" at indices 100-102, type this:
;
;           IDL> TVLCT, FSC_Color(["red", "green", and "yellow"], /Triple), 100
;
; MODIFICATION HISTORY:
;
;       Written by: David W. Fanning, 19 October 2000. Based on previous
;          GetColor program.
;       Fixed a problem with loading colors with TVLCT on a PRINTER device. 13 Mar 2001. DWF.
;       Added the ROW keyword. 30 March 2001. DWF.
;       Added the PICKCOLORNAME code to the file, since I keep forgetting to
;          give it to people. 15 August 2001. DWF.
;       Added ability to specify color names and indices as vectors. 5 Nov 2002. DWF.
;       Fixed a problem with the TRIPLE keyword when specifying a vector of color names. 14 Feb 2003. DWF.
;       Fixed a small problem with the starting index when specifying ALLCOLORS. 24 March 2003. DWF.
;       Added system color names. 23 Jan 2004. DWF
;       Added work-around for WHERE function "feature" when theColor is a one-element array. 22 July 2004. DWF.
;       Added support for 8-bit graphics devices when color index is not specified. 25 August 2004. DWF.
;       Fixed a small problem with creating color structure when ALLCOLORS keyword is set. 26 August 2004. DWF.
;       Extended the color index fix for 8-bit graphics devices on 25 August 2004 to
;         24-bit devices running with color decomposition OFF. I've concluded most of
;         the people using IDL don't have any idea how color works, so I am trying to
;         make it VERY simple, and yet still maintain the power of this program. So now,
;         in general, for most simple plots, you don't have to use the colorindex parameter
;         and you still have a very good chance of getting what you expect in a device-independent
;         manner. Of course, it would be *nice* if you could use that 24-bit display you paid
;         all that money for, but I understand your reluctance. :-)   11 October 2004. DWF.
;       Have renamed the first positional parameter so that this variable doesn't change
;         while the program is running. 7 December 2004. DWF.
;       Fixed an error I introduced on 7 December 2004. Sigh... 7 January 2005. DWF.
;       Added eight new colors. Total now of 104 colors. 11 August 2005. DWF.
;       Modified GUI to display system colors and removed PickColorName code. 13 Dec 2005. DWF.
;       Fixed a problem with colorIndex when SELECTCOLOR keyword was used. 13 Dec 2005. DWF.
;       Fixed a problem with color name synonyms. 19 May 2006. DWF.
;       The previous fix broke the ability to specify several colors at once. Fixed. 24 July 2006. DWF.
;       Updated program to work with 24-bit Z-buffer in IDL 6.4. 11 June 2007. DWF
;       Added the CRONJOB keyword. 07 Feb 2008. DWF.
;       Changed the CRONJOB keyword to NODISPLAY to better reflect its purpose. 7 FEB 2008. DWF.
;       Added the BREWER keyword to allow selection of Brewer Colors. 15 MAY 2008. DWF.
;       Added the CHECK_CONNECTION keyword and depreciated the NODISPLAY keyword for cron jobs. 15 MAY 2008. DWF.
;       Added the BREWER names to the program with or without the BREWER keyword set. 3 JULY 2008. DWF.
;-


Last Modification =>  2010-10-22/18:51:23 UTC
;+
; NAME:
;       LINT
; PURPOSE:
;       Find the intersection of two lines in the XY plane.
; CATEGORY:
; CALLING SEQUENCE:
;       lint, a, b, c, d, i
; INPUTS:
;       a, b = Points on line 1.          in
;       c, d = Points on line 2.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         FLAG=f  Returned flag:
;           0 means no intersections (lines parallel).
;           1 means one intersection.
;           2 means all points intersect (lines coincide).
;         /COND print condition number for linear system.
; OUTPUTS:
;       i1, i2 = Returned intersection.   out
;         Both i1 and i2 should be the same.
; COMMON BLOCKS:
; NOTES:
;       Notes: Each point has the form [x,y].
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Feb 4
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-


Last Modification =>  2009-06-15/20:29:39 UTC
;+
; NAME:
;        LOGLEVELS (function)
;
; PURPOSE:
;        Compute default values for logarithmic axis labeling
;        or contour levels. For a range from 1 to 100 these
;        would be 1., 2., 5., 10., 20., 50., 100.
;        If the range spans more than (usually) 3 decades, only
;        decadal values will be returned unless the /FINE keyword
;        is set.
;
; CATEGORY:
;        Tools
;
; CALLING SEQUENCE:
;        result = LOGLEVELS([range | MIN=min,MAX=max] [,/FINE], [COARSE=dec])
;
; INPUTS:
;        RANGE -> A 2-element vector with the minimum and maximum
;            value to be returned. Only levels _within_ this range
;            will be returned. If RANGE contains only one element,
;            this is interpreted as MAX and MIN will be assumed as
;            3 decades smaller. RANGE superseeds the MIN and MAX
;            keywords. Note that RANGE must be positive definite
;            but can be given in descending order in which case
;            the labels will be reversed.
;
; KEYWORD PARAMETERS:
;        MIN, MAX -> alternative way of specifying a RANGE. If only
;            one keyword is given, the other one is computed as
;            3 decades smaller/larger than the given parameter.
;            RANGE superseeds MIN and MAX.
;
;        /FINE -> always return finer levels (1,2,5,...)
;
;        COARSE -> the maximum number of decades for which LOGLEVELS
;            shall return fine labels. Default is 3. (non-integer
;            values are possible).
;
; OUTPUTS:
;        A vector with "round" logarithmic values within the given
;        range. The original (or modified) RANGE will be returned
;        unchanged if RANGE does not span at least one label interval.
;        The result will always contain at least two elements.
;
;
; SUBROUTINES:
;        none
;
; REQUIREMENTS:
;        none
;
; NOTES:
;        If COARSE is lt 0, the nearest decades will be returned
;        instead. The result will always have at least two elements.
;        If COARSE forces decades, the result values may be out-of-
;        range if RANGE spans less than a decade.
;
;        Caution with type conversion from FLOAT to DOUBLE !!
;
; EXAMPLE:
;        range = [ min(data), max(data) ]
;        c_level = LOGLEVELS(range)
;        contour,...,c_level=c_level
;
;
; MODIFICATION HISTORY:
;        mgs, 17 Mar 1999: VERSION 1.00
;
;-


Last Modification =>  2008-09-18/14:39:29 UTC
;+
; NAME:
;       SCALE_VECTOR
;
; PURPOSE:
;
;       This is a utility routine to scale the elements of a vector
;       (or an array) into a given data range. The processed vector
;       [MINVALUE > vector < MAXVECTOR] is scaled into the data range
;       given by MINRANGE and MAXRANGE.
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Utilities
;
; CALLING SEQUENCE:
;
;       scaledVector = SCALE_VECTOR(vector, [minRange], [maxRange], [MINVALUE=minvalue], [MAXVALUE=maxvalue])
;
; INPUT POSITIONAL PARAMETERS:
;
;       vector:   The vector (or array) to be scaled. Required.
;       minRange: The minimum value of the scaled vector. Set to 0 by default. Optional.
;       maxRange: The maximum value of the scaled vector. Set to 1 by default. Optional.
;       Note that it is the processed vector [MINVALUE > vector < MAXVALUE] that is
;       scaled between minRange and maxRange. See the MINVALUE and MAXVALUE keywords below.
;
; INPUT KEYWORD PARAMETERS:
;
;       DOUBLE:        Set this keyword to perform scaling in double precision.
;                      Otherwise, scaling is done in floating point precision.
;
;       MAXVALUE:      MAXVALUE is set equal to (vector < MAXVALUE) prior to scaling.
;                      The default value is MAXVALUE = Max(vector).
;
;       MINVALUE:      MINVALUE is set equal to (vector > MAXVALUE) prior to scaling.
;                      The default value is MINXVALUE = Min(vector).
;
;       NAN:           Set this keyword to enable not-a-number checking. NANs
;                      in vector will be ignored.
;
;       PRESERVE_TYPE: Set this keyword to preserve the input data type in the output.
;
; RETURN VALUE:
;
;       scaledVector: The vector (or array) values scaled into the data range.
;
; COMMON BLOCKS:
;       None.
;
; EXAMPLES:
;
;       x = [3, 5, 0, 10]
;       xscaled = SCALE_VECTOR(x, -50, 50)
;       Print, xscaled
;          -20.0000     0.000000     -50.0000      50.0000
;       Suppose your image has a minimum value of -1.7 and a maximum value = 2.5.
;       You wish to scale this data into the range 0 to 255, but you want to use
;       a diverging color table. Thus, you want to make sure value 0.0 is scaled to 128.
;       You proceed like this:
;
;       scaledImage = SCALE_VECTOR(image, 0, 255, MINVALUE=-2.5, MAXVALUE=2.5)
;
; RESTRICTIONS:
;
;     Requires the following programs from the Coyote Library:
;
;        http://www.dfanning.com/programs/convert_to_type.pro
;        http://www.dfanning.com/programs/fpufix.pro
;
; MODIFICATION HISTORY:
;
;       Written by:  David W. Fanning, 12 Dec 1998.
;       Added MAXVALUE and MINVALUE keywords. 5 Dec 1999. DWF.
;       Added NAN keyword. 18 Sept 2000. DWF.
;       Removed check that made minRange less than maxRange to allow ranges to be
;          reversed on axes, etc. 28 Dec 2003. DWF.
;       Added PRESERVE_TYPE and DOUBLE keywords. 19 February 2006. DWF.
;       Added FPUFIX to cut down on floating underflow errors. 11 March 2006. DWF.
;-


Last Modification =>  2011-03-25/19:40:36 UTC
;+
; NAME:
;  setintersection
;
; PURPOSE:
;
;   This function is used to find the intersection between two sets of integers.
;
; AUTHOR:
;
;   FANNING SOFTWARE CONSULTING
;   David Fanning, Ph.D.
;   1645 Sheely Drive
;   Fort Collins, CO 80526 USA
;   Phone: 970-221-0438
;   E-mail: davidf@dfanning.com
;   Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; CATEGORY:
;
;   Utilities
;
; CALLING SEQUENCE:
;
;   intersection = setintersection(set_a, set_b)
;
; RETURN VALUE:
;
;   intersection:  A vector of values that are found in both set_a and set_b.
;
; ARGUMENTS:
;
;   set_a:         A vector of integers.
;   
;   set_b:         A vector of integers.
;
; KEYWORDRS:
;
;  NORESULT:       Set this keyword to a value that will be returned from the function
;                  if no intersection between the two sets of numbers is found. By default, -1.
;
;  SUCCESS:        An output keyword that is set to 1 if an intersection was found, and to 0 otherwise.
;
; EXAMPLE:
;
;  IDL> set_a = [1,2,3,4,5]
;  IDL> set_b = [4,5,6,7,8,9,10,11]
;  IDL> Print, SetIntersection(set_a, set_b)
;          4   5
;
;  See http://www.dfanning.com/tips/set_operations.html for other types of set operations.
;  
; NOTES:
; 
;  If you read the Set Operations article pointed to above, you will see quite a lot of
;  discussion about what kinds of algorithms are faster than others. The Histogram 
;  algorithms implemented here are sometimes NOT the fastest algorithms, especially 
;  for sparse arrays. If this is a concern in your application, please be sure to read
;  that article.
;  
; MODIFICATION HISTORY:
;
;  Written by: David W. Fanning, October 31, 2009, from code originally supplied to the IDL
;     newsgroup by Research Systems software engineers.
;  Yikes, bug in original code only allowed positive integers. Fixed now. 2 Nov 2009. DWF.
;  Fixed a problem when one or both of the sets was a scalar value. 18 Nov 2009. DWF.
;  Changed name to all lower case                                   25 Mar 2011. LBW III.
;-


Last Modification =>  2011-03-25/19:40:37 UTC
;+
; NAME:
;  setunion
;
; PURPOSE:
;
;   This function is used to find the union between two sets of integers.
;
; AUTHOR:
;
;   FANNING SOFTWARE CONSULTING
;   David Fanning, Ph.D.
;   1645 Sheely Drive
;   Fort Collins, CO 80526 USA
;   Phone: 970-221-0438
;   E-mail: davidf@dfanning.com
;   Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; CATEGORY:
;
;   Utilities
;
; CALLING SEQUENCE:
;
;   union = setunion(set_a, set_b)
;
; RETURN VALUE:
;
;   union:  A vector of values that are found in the combined integer sets.
;
; ARGUMENTS:
;
;   set_a:         A vector of integers.
;   
;   set_b:         A vector of integers.
;
; KEYWORDRS:
;
;    None.
;    
; EXAMPLE:
;
;  IDL> set_a = [1,2,3,4,5]
;  IDL> set_b = [4,5,6,7,8,9,10,11]
;  IDL> Print, SetUnion(set_a, set_b)
;          1  2  3  4  5  6  7  8  9  10  11
;
;  See http://www.dfanning.com/tips/set_operations.html for other types of set operations.
;  
; NOTES:
; 
;  If you read the Set Operations article pointed to above, you will see quite a lot of
;  discussion about what kinds of algorithms are faster than others. The Histogram 
;  algorithms implemented here are sometimes NOT the fastest algorithms, especially 
;  for sparse arrays. If this is a concern in your application, please be sure to read
;  that article.
;  
;  One alternative for the SetUnion algorithm, provided by Maarten Sneep, is simply this:
;  
;      superset = [set_a, set_b]
;      union = superset[Uniq(superset, Sort(superset))]
;  
; MODIFICATION HISTORY:
;
;  Written by: David W. Fanning, November 25, 2009, from code originally supplied to the IDL
;     newsgroup by Research Systems software engineers.
;  Changed name to all lower case                                   25 Mar 2011. LBW III.
;-


Last Modification =>  2010-10-22/18:39:25 UTC
;+
; NAME:
;       SKEWINT
; PURPOSE:
;       Give the near-intersection point for two skew lines.
; CATEGORY:
; CALLING SEQUENCE:
;       skewint, a, b, c, d, m, e
; INPUTS:
;       a, b = two points on line 1.          in
;       c, d = two points on line 2.          in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       m = midpoint of closest approach.     out
;       e = distance between lines.           out
;           -1 for parallel lines.
; COMMON BLOCKS:
; NOTES:
;       Notes: a,b,c,d,m are 3 element arrays (x,y,z),
;         e is a scalar.  Two lines in 3-d that should
;         intersect will, because of errors, in general
;         miss.  This routine gives the point halfway
;         between the two lines at closest approach.
; MODIFICATION HISTORY:
;       R. Sterner. 30 Dec, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;
; Copyright (C) 1986, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-


Last Modification =>  2011-04-19/15:26:07 UTC
;+
; NAME:
;  str_size
;
; PURPOSE:
;
;  The purpose of this function is to return the proper
;  character size to make a specified string a specifed
;  width in a window. The width is specified in normalized
;  coordinates. The function is extremely useful for sizing
;  strings and labels in resizeable graphics windows.
;
; AUTHOR:
;
;   FANNING SOFTWARE CONSULTING
;   David Fanning, Ph.D.
;   1645 Sheely Drive
;   Fort Collins, CO 80526 USA
;   Phone: 970-221-0438
;   E-mail: davidf@dfanning.com
;   Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; CATEGORY:
;
;  Graphics Programs, Widgets.
;
; CALLING SEQUENCE:
;
;  thisCharSize = str_size(thisSting, targetWidth)
;
; INPUTS:
;
;  thisString:  This is the string that you want to make a specifed
;     target size or width.
;
; OPTIONAL INPUTS:
;
;  targetWidth:  This is the target width of the string in normalized
;     coordinates in the current graphics window. The character
;     size of the string (returned as thisCharSize) will be
;     calculated to get the string width as close as possible to
;     the target width. The default is 0.25.
;
; KEYWORD PARAMETERS:
;
;  INITSIZE:  This is the initial size of the string. Default is 1.0.
;
;  STEP:   This is the amount the string size will change in each step
;     of the interative process of calculating the string size.
;     The default value is 0.05.
;
;  XPOS:   X position of the output test string. This can be
;     used on the Postscript device, where no pixmap windows are
;     available and where therefore the test strings would appear on
;     the printable area. Default is 0.5 on most devices. If !D.NAME
;     is PS, the default is 2.0 to draw the test string out of the
;     drawable window area.
;
;  YPOS:   Y position of the output test string. This can be
;     used on the Postscript device, where no pixmap windows are
;     available and where therefore the test strings would appear on
;     the printable area. Default is 0.5 on most devices. If !D.NAME
;     is PS, the default is 2.0 to draw the test string out of the
;     drawable window area.
;
; OUTPUTS:
;
;  thisCharSize:  This is the size the specified string should be set
;     to if you want to produce output of the specified target
;     width. The value is in standard character size units where
;     1.0 is the standard character size.
;
; EXAMPLE:
;
;  To make the string "Happy Holidays" take up 30% of the width of
;  the current graphics window, type this:
;
;      XYOUTS, 0.5, 0.5, ALIGN=0.5, "Happy Holidays", $
;        CHARSIZE=str_size("Happy Holidays", 0.3)
;
; MODIFICATION HISTORY:
;
;  Written by: David Fanning, 17 DEC 96.
;  Added a scaling factor to take into account the aspect ratio
;     of the window in determing the character size. 28 Oct 97. DWF
;  Added check to be sure hardware fonts are not selected. 29 April 2000. DWF.
;  Added a pixmap to get proper scaling in skinny windows. 16 May 2000. DWF.
;  Forgot I can't do pixmaps in all devices. :-( Fixed. 7 Aug 2000. DWF.
;  Added support of PostScript at behest of Benjamin Hornberger. 11 November 2004. DWF.
;  Cleaned up the code a bit. 28 Feb 2011. DWF.
;-


Last Modification =>  2008-09-18/14:38:23 UTC
;+
; NAME:
;     TVIMAGE
;
; PURPOSE:
;     This purpose of TVIMAGE is to enable the TV command in IDL
;     to be a completely device-independent and color-decomposition-
;     state independent command. On 24-bit displays color decomposition
;     is always turned off for 8-bit images and on for 24-bit images.
;     The color decomposition state is restored for those versions of
;     IDL that support it (> 5.2). Moreover, TVIMAGE adds features
;     that TV lacks. For example, images can be positioned in windows
;     using the POSITION keyword like other IDL graphics commands.
;     TVIMAGE also supports the !P.MULTI system variable, unlike the
;     TV command. TVIMAGE was written to work especially well in
;     resizeable graphics windows. Note that if you wish to preserve
;     the aspect ratio of images in resizeable windows, you should set
;     the KEEP_ASPECT_RATIO keyword, described below. TVIMAGE works
;     equally well on the display, in the PostScript device, and in
;     the Printer and Z-Graphics Buffer devices. The TRUE keyword is
;     set automatically to the correct value for 24-bit images, so you
;     don't need to specify it when using TVIMAGE.
;
; AUTHOR:
;       FANNING SOFTWARE CONSULTING:
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com/
;
; CATEGORY:
;     Graphics display.
;
; CALLING SEQUENCE:
;
;     TVIMAGE, image
;
; INPUTS:
;     image:    A 2D or 3D image array. It should be byte data.
;
;       x  :    The X position of the lower-left corner of the image.
;               This parameter is only recognized if the TV keyword is set.
;               If the Y position is not used, X is taken to be the image
;               "position" in the window. See the TV command documenation
;               for details.
;
;       y  :    The Y position of the lower-left corner of the image.
;               This parameter is only recognized if the TV keyword is set.
;
; KEYWORD PARAMETERS:
;
;     ACOLOR:   Set this keyword to the axis color. If a byte or integer value,
;               it will assume you are using INDEXED color mode. If a long integer
;               is will assume you are using DECOMPOSED color mode. If a string,
;               is will pass the string color name along to FSC_COLOR for processing.
;
;     AXES:     Set this keyword to draw a set of axes around the image.
;
;     AXKEYWORDS:   An IDL structure variable of PLOT keywords as structure fields
;               and keyword values as the values of the fields. Pass directly to the
;               PLOT command that draws the axes for the image. Ignored unless the
;               AXES keyword is set. For example,
;
;               TVImage, image, /AXES, AXKEYWORDS={CHARSIZE:1.5, XTITLE:'Distance (mm)', $
;                    YTITLE:'Signal', TICKLEN:-0.025}, ACOLOR='NAVY'
;
;     BACKGROUND:   This keyword specifies the background color. Note that
;               the keyword ONLY has effect if the ERASE keyword is also
;               set or !P.MULTI is set to multiple plots and TVIMAGE is
;               used to place the *first* plot. Can be a string (e.g., 'ivory'), or
;               a 24-bit value that can be decomposed into a color, or an 8-bit
;               index number into the current color table. ERASE and BACKGROUND
;               should only be used on 24-bit devices that support windows!
;
;     BREWER:   If set, applies only to BACKGROUND AND ACOLOR keywords. Selects
;               brewer colors, rather than standard FSC_COLOR colors as strings.
;
;     ERASE:    If this keyword is set an ERASE command is issued
;               before the image is displayed. ERASE and BACKGROUND 
;               should only be used on 24-bit devices that support windows! 
;               The keyword is ignored on 8-bit devices or devices that do
;               not support windows.
;
;     _EXTRA:   This keyword picks up any TV keywords you wish to use.
;
;     HALF_HALF: If set, will tell CONGRID to extrapolate a *half* row
;               and column on either side, rather than the default of
;               one full row/column at the ends of the array.  If you
;               are interpolating images with few rows, then the
;               output will be more consistent with this technique.
;               This keyword is intended as a replacement for
;               MINUS_ONE, and both keywords probably should not be
;               used in the same call to CONGRID.
;
;     KEEP_ASPECT_RATIO: Normally, the image will be resized to fit the
;               specified position in the window. If you prefer, you can
;               force the image to maintain its aspect ratio in the window
;               (although not its natural size) by setting this keyword.
;               The image width is fitted first. If, after setting the
;               image width, the image height is too big for the window,
;               then the image height is fitted into the window. The
;               appropriate values of the POSITION keyword are honored
;               during this fitting process. Once a fit is made, the
;               POSITION coordiates are re-calculated to center the image
;               in the window. You can recover these new position coordinates
;               as the output from the POSITION keyword.
;
;     MARGIN:   A single value, expressed as a normalized coordinate, that
;               can easily be used to calculate a position in the window.
;               The margin is used to calculate a POSITION that gives
;               the image an equal margin around the edge of the window.
;               The margin must be a number in the range 0.0 to 0.333. This
;               keyword is ignored if the POSITION or OVERPLOT keywords are
;               used. It is also ignored when TVImage is executed in a
;               multi-plot window, EXCEPT if it's value is zero. In this
;               special case, the image will be drawn into its position in
;               the multi-plot window with no margins whatsoever. (The
;               default is to have a slight margin about the image to separate
;               it from other images or graphics.
;
;     MINUS_ONE: The value of this keyword is passed along to the CONGRID
;               command. It prevents CONGRID from adding an extra row and
;               column to the resulting array, which can be a problem with
;               small image arrays.
;
;     NOINTERPOLATION: Setting this keyword disables the default bilinear
;               interpolation done to the image when it is resized. Nearest
;               neighbor interpolation is done instead. This is preferred
;               when you do not wish to change the pixel values of the image.
;               This keyword must be set, for example, when you are displaying
;               GIF files that come with their own non-IDL color table vectors.
;
;     NORMAL:   Setting this keyword means image position coordinates x and y
;               are interpreted as being in normalized coordinates. This keyword
;               is only valid if the TV keyword is set.
;
;     OVERPLOT: Setting this keyword causes the POSITION keyword to be ignored
;               and the image is positioned in the location established by the
;               last graphics command. For example:
;
;                    Plot, Findgen(11), Position=[0.1, 0.3, 0.8, 0.95]
;                    TVImage, image, /Overplot
;
;     POSITION: The location of the image in the output window. This is
;               a four-element floating array of normalized coordinates of
;               the type given by !P.POSITION or the POSITION keyword to
;               other IDL graphics commands. The form is [x0, y0, x1, y1].
;               The default is [0.0, 0.0, 1.0, 1.0]. Note that this keyword is ALSO
;               an output keyword. That is to say, upon return from TVIMAGE
;               this keyword (if passed by reference) contains the actual
;               position in the window where the image was displayed. This
;               may be different from the input values if the KEEP_ASPECT_RATIO
;               keyword is set, or if you are using TVIMAGE with the POSITION
;               keyword when !P.MULTI is set to something other than a single
;               plot. One use for the output values might be to position other
;               graphics (e.g., a colorbar) in relation to the image.
;
;               Note that the POSITION keyword should not, normally, be used
;               when displaying multiple images with !P.MULTI. If it *is* used,
;               its meaning differs slightly from its normal meaning. !P.MULTI
;               is responsible for calculating the position of graphics in the
;               display window. Normally, it would be a mistake to use a POSITION
;               graphics keyword on a graphics command that was being drawn with
;               !P.MULTI. But in this special case, TVIMAGE will use the POSITION
;               coordinates to calculate an image position in the actual position
;               calculated for the image by !P.MULTI. The main purpose of this
;               functionality is to allow the user to display images along with
;               colorbars when using !P.MULTI. See the example below.
;
;    QUIET:      There are situations when you would prefer that TVIMAGE does not
;                advertise itself by filling out the FSC_$TVIMAGE common block. For
;                example, if you are using TVIMAGE to draw a color bar, it would
;                not be necessary. Setting this keyword means that TVIMAGE just
;                goes quietly about it's business without bothering anyone else.
;
;    SCALE:     Set this keyword to byte scale the image before display.
;
;     TV:       Setting this keyword makes the TVIMAGE command work much
;               like the TV command, although better. That is to say, it
;               will still set the correct DECOMPOSED state depending upon
;               the kind of image to be displayed (8-bit or 24-bit). It will
;               also allow the image to be "positioned" in the window by
;               specifying the coordinates of the lower-left corner of the
;               image. The NORMAL keyword is activated when the TV keyword
;               is set, which will indicate that the position coordinates
;               are given in normalized coordinates rather than device
;               coordinates.
;
;               Setting this keyword will ensure that the keywords
;               KEEP_ASPECT_RATIO, MARGIN, MINUS_ONE, MULTI, and POSITION
;               are ignored.
;
;      XRANGE:  If the AXES keyword is set, this keyword is a two-element vector
;               giving the X axis range. By default, [0, size of image in X].
;
;      YRANGE:  If the AXES keyword is set, this keyword is a two-element vector
;               giving the Y axis range. By default, [0, size of image in Y].
;
; OUTPUTS:
;     None.
;
; SIDE EFFECTS:
;     Unless the KEEP_ASPECT_RATIO keyword is set, the displayed image
;     may not have the same aspect ratio as the input data set.
;
; RESTRICTIONS:
;     If the POSITION keyword and the KEEP_ASPECT_RATIO keyword are
;     used together, there is an excellent chance the POSITION
;     parameters will change. If the POSITION is passed in as a
;     variable, the new positions will be returned in the same variable
;     as an output parameter.
;
;     If a 24-bit image is displayed on an 8-bit display, the
;     24-bit image must be converted to an 8-bit image and the
;     appropriate color table vectors. This is done with the COLOR_QUAN
;     function. The TVIMAGE command will load the color table vectors
;     and set the NOINTERPOLATION keyword if this is done. Note that the
;     resulting color table vectors are normally incompatible with other
;     IDL-supplied color tables. Hence, other graphics windows open at
;     the time the image is display are likely to look strange.
;
;     Other programs from Coyote Library (e.g., FSC_COLOR) may also be
;     required.
;
; EXAMPLE:
;     To display an image with a contour plot on top of it, type:
;
;        filename = FILEPATH(SUBDIR=['examples','data'], 'worldelv.dat')
;        image = BYTARR(360,360)
;        OPENR, lun, filename, /GET_LUN
;        READU, lun, image
;        FREE_LUN, lun
;
;        TVIMAGE, image, POSITION=thisPosition, /KEEP_ASPECT_RATIO
;        CONTOUR, image, POSITION=thisPosition, /NOERASE, XSTYLE=1, $
;            YSTYLE=1, XRANGE=[0,360], YRANGE=[0,360], NLEVELS=10
;
;     To display four images in a window without spacing between them:
;
;     !P.Multi=[0,2,2]
;     TVImage, image, Margin=0
;     TVImage, image, Margin=0
;     TVImage, image, Margin=0
;     TVImage, image, Margin=0
;     !P.Multi = 0
;
;     To display four image in a window with associated color bars:
;
;     !P.Multi=[0,2,2]
;     p = [0.02, 0.3, 0.98, 0.98]
;     LoadCT, 0
;     TVImage, image, Position=p
;     Colorbar, Position=[p[0], p[1]-0.1, p[2], p[1]-0.05]
;     p = [0.02, 0.3, 0.98, 0.98]
;     LoadCT, 2
;     TVImage, image, Position=p
;     Colorbar, Position=[p[0], p[1]-0.1, p[2], p[1]-0.05]
;     p = [0.02, 0.3, 0.98, 0.98]
;     LoadCT, 3
;     TVImage, image, Position=p
;     Colorbar, Position=[p[0], p[1]-0.1, p[2], p[1]-0.05]
;     p = [0.02, 0.3, 0.98, 0.98]
;     LoadCT, 5
;     TVImage, image, Position=p
;     Colorbar, Position=[p[0], p[1]-0.1, p[2], p[1]-0.05]
;     !P.Multi =0
;
; MODIFICATION HISTORY:
;      Written by:     David Fanning, 20 NOV 1996.
;      Fixed a small bug with the resizing of the image. 17 Feb 1997. DWF.
;      Removed BOTTOM and NCOLORS keywords. This reflects my growing belief
;         that this program should act more like TV and less like a "color
;         aware" application. I leave "color awareness" to the program
;         using TVIMAGE. Added 24-bit image capability. 15 April 1997. DWF.
;      Fixed a small bug that prevented this program from working in the
;          Z-buffer. 17 April 1997. DWF.
;      Fixed a subtle bug that caused me to think I was going crazy!
;          Lession learned: Be sure you know the *current* graphics
;          window! 17 April 1997. DWF.
;      Added support for the PRINTER device. 25 June 1997. DWF.
;      Extensive modifications. 27 Oct 1997. DWF
;          1) Removed PRINTER support, which didn't work as expected.
;          2) Modified Keep_Aspect_Ratio code to work with POSITION keyword.
;          3) Added check for window-able devices (!D.Flags AND 256).
;          4) Modified PostScript color handling.
;      Craig Markwart points out that Congrid adds an extra row and column
;          onto an array. When viewing small images (e.g., 20x20) this can be
;          a problem. Added a Minus_One keyword whose value can be passed
;          along to the Congrid keyword of the same name. 28 Oct 1997. DWF
;      Changed default POSITION to fill entire window. 30 July 1998. DWF.
;      Made sure color decomposition is OFF for 2D images. 6 Aug 1998. DWF.
;      Added limited PRINTER portrait mode support. The correct aspect ratio
;          of the image is always maintained when outputting to the
;          PRINTER device and POSITION coordinates are ignored. 6 Aug 1998. DWF
;      Removed 6 August 98 fixes (Device, Decomposed=0) after realizing that
;          they interfere with operation in the Z-graphics buffer. 9 Oct 1998. DWF
;      Added a MARGIN keyword. 18 Oct 1998. DWF.
;      Re-established Device, Decomposed=0 keyword for devices that
;         support it. 18 Oct 1998. DWF.
;      Added support for the !P.Multi system variable. 3 March 99. DWF
;      Added DEVICE, DECOMPOSED=1 command for all 24-bit images. 2 April 99. DWF.
;      Added ability to preserve DECOMPOSED state for IDL 5.2 and higher. 4 April 99. DWF.
;      Added TV keyword to allow TVIMAGE to work like the TV command. 11 May 99. DWF.
;      Added the OVERPLOT keyword to allow plotting on POSITION coordinates
;         estabished by the preceding graphics command. 11 Oct 99. DWF.
;      Added automatic recognition of !P.Multi. Setting MULTI keyword is no
;         longer required. 18 Nov 99. DWF.
;      Added NOINTERPOLATION keyword so that nearest neighbor interpolation
;         is performed rather than bilinear. 3 Dec 99. DWF
;      Changed ON_ERROR condition from 1 to 2. 19 Dec 99. DWF.
;      Added Craig Markwardt's CMCongrid program and removed RSI's. 24 Feb 2000. DWF.
;      Added HALF_HALF keyword to support CMCONGRID. 24 Feb 2000. DWF.
;      Fixed a small problem with image start position by adding ROUND function. 19 March 2000. DWF.
;      Updated the PRINTER device code to take advantage of available keywords. 2 April 2000. DWF.
;      Reorganized the code to handle 24-bit images on 8-bit displays better. 2 April 2000. DWF.
;      Added BACKGROUND keyword. 20 April 2000. DWF.
;      Fixed a small problem in where the ERASE was occuring. 6 May 2000. DWF.
;      Rearranged the PLOT part of code to occur before decomposition state
;         is changed to fix Background color bug in multiple plots. 23 Sept 2000. DWF.
;      Removed MULTI keyword, which is no longer needed. 23 Sept 2000. DWF.
;      Fixed a small problem with handling images that are slices from 3D image cubes. 5 Oct 2000. DWF.
;      Added fix for brain-dead Macs from Ben Tupper that restores Macs ability to
;         display images. 8 June 2001. DWF.
;      Fixed small problem with multiple plots and map projections. 29 June 2003. DWF.
;      Converted all array subscripts to square brackets. 29 June 2003. DWF.
;      Removed obsolete STR_SEP and replaced with STRSPLIT. 27 Oct 2004. DWF.
;      Small modification at suggestion of Karsten Rodenacker to increase size of
;         images in !P.MULTI mode. 8 December 2004. DWF.
;      Minor modifications on Karsten Rodenacker's own account concerning margination
;         and TV behaviour. 8 December 2004. KaRo
;      There was a small inconsistency in how the image was resized for PostScript as
;         opposed to the display, which could occasionally result in a small black line
;         to the right of the image. This is now handled consistently. 3 January 2007. DWF.
;      Made a small change to CMCONGRID to permit nearest-neighbor interpolation for 3D arrays.
;         Previously, any 24-bit image was interpolated, no matter the setting of the NOINTERP
;         keyword. 22 April 2007. DWF.
;      Updated the program for the 24-bit Z-buffer in IDL 6.4. 11 June 2007. DWF.
;      Added new POSITION keyword functionality for !P.MULTI display. 9 Sept 2007. DWF.
;      Bit one too many times. Added _STRICT_EXTRA keywords for all _EXTRA keywords. 1 Feb 2008. DWF.
;      Added FSC_$TVIMAGE common block for interactive interaction with TVINFO. 16 March 2008. DWF.
;      Added SCALE keyword. 18 March 2008. DWF.
;      Added keywords to allow axes to be drawn around the image. 18 March 2008. DWF.
;      Added QUIET keyword to allow by-passing of FSC_$TVIMAGE common block updating. 21 March 2008. DWF.
;      Made BACKGROUND and ERASE valid keywords only on 24-bit devices. Ignored on others. 28 May 2008. DWF.
;      Cannot make color work in device independent way for axes, unless I handle axis color directly. To this
;          end, I have added an ACOLOR keyword. 16 June 2008. DWF.
;      Added BREWER keyword so I can specify Brewer colors with BACKGROUND and ACOLOR keywords. 16 June 2008. DWF.
;-


Last Modification =>  2010-09-23/18:58:42 UTC
;+
; NAME:
;       UNDEFINE
;
; PURPOSE:
;       The purpose of this program is to delete or undefine
;       an IDL program variable from within an IDL program or
;       at the IDL command line. It is a more powerful DELVAR.
;       Pointer and structure variables are traversed recursively
;       to undefine any variables pointed to in the pointer or in
;       a structure dereference.
;
; AUTHOR:
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1642 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;       Utilities.
;
; CALLING SEQUENCE:
;       UNDEFINE, variable
;
; REQUIRED INPUTS:
;       variable: The variable to be deleted. Up to 10 variables may be specified as arguments.
;
; SIDE EFFECTS:
;       The variable no longer exists.
;
; EXAMPLE:
;       To delete the variable "info", type:
;
;        IDL> Undefine, info
;        
;        IDL> var = ptr_new({a:ptr_New(5), b:findgen(11), c: {d:ptr_New(10), f:findgen(11)}})
;        IDL> Help, /Heap
;        Heap Variables:
;            # Pointer: 3
;            # Object : 0
;        <PtrHeapVar3>   LONG      =            5
;        <PtrHeapVar4>   LONG      =            10
;        <PtrHeapVar5>   STRUCT    = -> <Anonymous> Array[1]
;         
;        IDL> Undefine, var
;        IDL> Help, /Heap
;        Heap Variables:
;            # Pointer: 0
;            # Object : 0
;        IDL> Help, var
;         VAR               UNDEFINED = <Undefined>
;
; MODIFICATION HISTORY:
;       Written by David W. Fanning, 8 June 97, from an original program
;       given to me by Andrew Cool, DSTO, Adelaide, Australia.
;       Simplified program so you can pass it an undefined variable. :-) 17 May 2000. DWF
;       Simplified it even more by removing the unnecessary SIZE function. 28 June 2002. DWF.
;       Added capability to delete up to 10 variables at suggestion of Craig Markwardt. 10 Jan 2008. DWF.
;       If the variable is a pointer, object or structure reference the variable is recursively traversed
;          to free up all variables pointed to before the variable is itself destroyed. 10 June 2009. DWF.
;       Updated to allow undefining of pointer arrays. 8 October 2009. DWF.
;-


