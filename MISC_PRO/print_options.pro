;+
;*****************************************************************************************
;
;  PROCEDURE:   print_options.pro
;  PURPOSE  :   This program controls the options used for postscript (PS) printing and
;                 files.
;
;  CALLED BY:   
;               popen.pro
;
;  CALLS:
;               popen_com.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               PORTRAIT   :  If set, forces portrait format for output
;                               [Default = TRUE]
;               LANDSCAPE  :  If set, forces landscape format for output
;                               [Default = FALSE]
;               BW         :  Forces images to black&white color scale
;                               [** untested **]
;               COLOR      :  Sets image to a color image
;                               [Default = TRUE]
;               ASPECT     :  Scalar defining the aspect ratio
;               XSIZE      :  Scalar defining the X-Dimension of output in PS file
;                               [Default = 8.5 inches]
;               YSIZE      :  Scalar defining the Y-Dimension of output in PS file
;                               [Default = 11.0 inches]
;               UNITS      :  Scalar string defining the units for XSIZE and YSIZE
;                               [Default = 'inches']
;               FONT       :  Scalar defining the type of fonts to use on output
;                               -1  :  Use Hershey vector-drawn fonts
;                                0  :  Use device fonts (defined by graphics device)
;                               +1  :  Use TrueType fonts
;               PRINTER    :  Scalar string defining the name of the printer to
;                               send PS files to for a hard copy
;                               [** Unix specific keyword **]
;               DIRECTORY  :  Scalar string defining the directory where the PS file
;                               will be written
;                               [Default = FILE_EXPAND_PATH('')]
;
;   CHANGED:  1)  Davin Larson changed something...                [05/30/1997   v1.0.16]
;             2)  Re-wrote and cleaned up (UMN Modified Wind/3DP version)
;                                                                  [06/09/2009   v1.1.0]
;             3)  [CG] added optional keywords for postscript file size and
;                   file size units
;                                                                  [04/04/2008   v1.?.?]
;             4)  Updated to be in accordance with newest version of print_options.pro
;                   in TDAS IDL libraries
;                   A)  Cleaned up and added some comments
;                   B)  Changed () usage to []
;                                                                  [08/11/2012   v1.2.0]
;
;   NOTES:      
;               1)  Future Options
;                   A)  ecapsulated postscript format
;                   B)  changing plotting area
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/11/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO print_options,PORTRAIT=port,LANDSCAPE=land,BW=bw,COLOR=col,ASPECT=aspect,    $
                  XSIZE=xsize,YSIZE=ysize,UNITS=units,FONT=font,PRINTER=printer, $
                  DIRECTORY=printdir

;;----------------------------------------------------------------------------------------
;; => Load common block variables
;;----------------------------------------------------------------------------------------
@popen_com.pro
;;----------------------------------------------------------------------------------------
;; => Set defaults
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(portrait)        EQ 0) THEN portrait        = 1
IF (N_ELEMENTS(in_color)        EQ 0) THEN in_color        = 1
IF (N_ELEMENTS(printer_name)    EQ 0) THEN printer_name    = ''
IF (N_ELEMENTS(print_directory) EQ 0) THEN print_directory = ''
IF (N_ELEMENTS(print_font)      EQ 0) THEN print_font      = 0
IF (N_ELEMENTS(print_aspect)    EQ 0) THEN print_aspect    = 0
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(land)                  THEN  portrait        = 0
IF KEYWORD_SET(port)                  THEN  portrait        = 1
IF KEYWORD_SET(col)                   THEN  in_color        = 1
IF KEYWORD_SET(bw)                    THEN  in_color        = 0
IF (N_ELEMENTS(printer)         NE 0) THEN  printer_name    = printer[0]
IF (N_ELEMENTS(printdir)        NE 0) THEN  print_directory = printdir[0]
IF (N_ELEMENTS(font)            NE 0) THEN  print_font      = font[0]

inches      = 1
x_papersize = 8.5    ;; Default X-dimension paper size [inches]
y_papersize = 11.    ;; Default Y-dimension paper size [inches]
x_aspect    = 8.
y_aspect    = 10.5
;;----------------------------------------------------------------------------------------
;; => Define unit-based dimensions
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(units) THEN BEGIN
  units = STRCOMPRESS(/REMOVE_ALL, units)
  IF (units NE 'inches') THEN BEGIN
    ;;  Assumes dimensions are set to centimeters (or cm)
    inches      = 0
    x_papersize = x_papersize*2.54       ;; convert default to cm
    y_papersize = y_papersize*2.54
    IF KEYWORD_SET(aspect) THEN BEGIN
      aspect   = aspect[0]*2.54
      x_aspect = x_aspect[0]*2.54
      y_aspect = y_aspect[0]*2.54
    ENDIF
  ENDIF
ENDIF
IF (N_ELEMENTS(aspect)          NE 0) THEN  print_aspect    = aspect[0]

IF (!D.NAME EQ 'PS') THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Postscript Device
  ;;--------------------------------------------------------------------------------------
  aspect = print_aspect
  IF KEYWORD_SET(aspect) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  User defined aspect ratio
    ;;------------------------------------------------------------------------------------
    IF (portrait) THEN BEGIN
      scale = (x_aspect[0] < y_aspect[0]/aspect[0])
      s     = [1.0,aspect[0]] * scale[0]
      ;;  Define [X,Y]-Offsets
      offs  = [(x_papersize[0] - s[0])/2, y_papersize[0] - 0.5 - s[1]]
    ENDIF ELSE BEGIN
      scale = (y_aspect[0] < x_aspect[0]/aspect[0])
      s     = [1.0,aspect[0]] * scale[0]
      ;;  Define [X,Y]-Offsets
      offs  = [(x_papersize[0] - s[1])/2, y_papersize[0] - (y_papersize[0] - s[0])/2]
    ENDELSE
    ;; => Define device
    IF (inches) THEN BEGIN
      DEVICE,PORTRAIT=portrait,/INCHES,YSIZE=s[1],XSIZE=s[0],YOFFSET=offs[1],XOFFSET=offs[0]
    ENDIF ELSE BEGIN
      DEVICE,PORTRAIT=portrait,YSIZE=s[1],XSIZE=s[0],YOFFSET=offs[1],XOFFSET=offs[0]
    ENDELSE
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Aspect ratio not defined
    ;;------------------------------------------------------------------------------------
    IF (portrait) THEN BEGIN
      IF NOT KEYWORD_SET(xsize) THEN xsize = 7.0
      IF NOT KEYWORD_SET(ysize) THEN ysize = 9.5
      ;;  Define [X,Y]-Offsets
      xoff = (x_papersize[0] - xsize[0])/2
      yoff = (y_papersize[0] - ysize[0])/2
    ENDIF ELSE BEGIN
      IF NOT KEYWORD_SET(xsize) THEN xsize = 9.5
      IF NOT KEYWORD_SET(ysize) THEN ysize = 7.0
      ;; The following lines were incorrect and gave the wrong margins for landscape plots
      ;;      xoff = (x_papersize - xsize)/2
      ;;      yoff = y_papersize - (y_papersize-ysize)/2
      ;;
      ;; Here are the corrected lines - mcfadden, 08-10-11
      xoff = (y_papersize[0] - xsize[0])/2
      yoff =  y_papersize[0] - (x_papersize[0] - ysize[0])/2
      IF (NOT inches) THEN BEGIN
        xoff = (x_papersize[0] - xsize[0])/2
        yoff =  y_papersize[0] - (y_papersize[0] - ysize[0])/2
      ENDIF
    ENDELSE
    ;; => Define device
    IF (inches) THEN BEGIN
      DEVICE,PORTRAIT=portrait,/INCHES,YSIZE=ysize[0],YOFFSET=yoff[0],$
             XSIZE=xsize[0],XOFFSET=xoff[0]
    ENDIF ELSE BEGIN
      DEVICE,PORTRAIT=portrait,YSIZE=ysize[0],YOFFSET=yoff[0],$
             XSIZE=xsize[0],XOFFSET=xoff[0]
    ENDELSE
  ENDELSE
  ;; => Define color in device
  IF (in_color) THEN BEGIN
    ;; color is on and has 256 shades
    DEVICE,/COLOR,BITS_PER_PIXEL=8
  ENDIF ELSE BEGIN
    ;; color is shut off
    DEVICE,COLOR=0
  ENDELSE
  ;; define fonts to use on output
  !P.FONT = print_font
ENDIF
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END

