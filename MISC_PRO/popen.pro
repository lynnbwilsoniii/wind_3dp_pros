;+
;*****************************************************************************************
;
;  FUNCTION :   popen.pro
;  PURPOSE  :   Controls the plot device and plotting options and changes the plot
;                 device to 'PS'.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               popen_com.pro
;               print_options.pro
;               str_element.pro
;               pclose.pro
;
;  REQUIRES:  
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               N             :  Optional input of the following format:
;                                  1) String => file name ('.ps' is appended 
;                                                 automatically)
;                                  2) Scalar => file name goes to 'plot[X].ps' where
;                                                 [X] = the user defined scalar value
;                                  3) None   => file name is set to 'plot.ps'
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:  
;               PORT          :  If set, device set to portrait
;               LANDSCAPE     :  If set, device set to landscape
;               COLOR         :  If set, device set to allow color images
;               BW            :  If set, forces black&white color scale
;               PRINTER       :  Set to name of printer to send PS files to
;               DIRECTORY     :  Scalar [string] defining the directory where the PS file
;                                  will be written
;               FONT          :  Scalar defining the setting to use for !P.FONT
;                                  -1  :  Use Hershey vector-drawn fonts
;                                   0  :  Use device fonts (defined by graphics device)
;                                  +1  :  Use TrueType fonts
;               ASPECT        :  Controls the aspect ratio
;               XSIZE         :  X-Dimension (cm) of output to PS file
;               YSIZE         :  Y-" "
;               UNITS         :  Scalar string defining the units for XSIZE and YSIZE
;                                  [Default = 'inches']
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
;   CHANGED:  1)  Davin Larson changed something...                [06/23/1998   v1.0.21]
;             2)  Re-wrote and cleaned up                          [06/10/2009   v1.1.0]
;             3)  Changed printed device info settings             [06/15/2009   v1.1.1]
;             4)  Updated to be in accordance with newest version of popen.pro
;                   in TDAS IDL libraries
;                   A)  Cleaned up and added some comments
;                   B)  Added the following keywords:  FONT, UNITS
;                   C)  No longer calls data_type.pro
;                                                                  [08/27/2012   v1.2.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/27/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO popen,n,PORT=port,LANDSCAPE=land,COLOR=color,BW=bw,PRINTER=printer,         $
            DIRECTORY=printdir,FONT=font,ASPECT=aspect,XSIZE=xsize,YSIZE=ysize, $
            UNITS=units,INTERP=interp,CTABLE=ctable,        $
            OPTIONS=options,COPY=copy,ENCAPSULATED=encap

;;----------------------------------------------------------------------------------------
;; Set common blocks:
;;----------------------------------------------------------------------------------------
@popen_com.pro
COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
old_colors_com = {R_ORIG:r_orig,G_ORIG:g_orig,B_ORIG:b_orig,R_CURR:r_curr, $
                  G_CURR:g_curr,B_CURR:b_curr}
;;----------------------------------------------------------------------------------------
;; => Look at currently set device settings
;;----------------------------------------------------------------------------------------
HELP, /DEVICE,OUTPUT=devspecs
IF (STRLOWCASE(!D.NAME) EQ 'z') THEN BEGIN
  PRINT,''
  PRINT,devspecs[1]              ; => e.g. Current graphics device: X
  PRINT,devspecs[3]              ; => e.g. Display Depth, Size: 24 bits, (1680,1028)
  PRINT,devspecs[5]              ; => e.g. Bits Per RGB: 8 (8/8/8)
  PRINT,''
ENDIF
;;----------------------------------------------------------------------------------------
;; Set defaults:
;;----------------------------------------------------------------------------------------
print_options,DIRECTORY=printdir,PORT=port,LANDSCAPE=land

str_element,options,'ENCAPSULATED',encap
str_element,options,'FILENAME',n
str_element,options,'XSIZE',xsize
str_element,options,'YSIZE',ysize
str_element,options,'UNITS',units
str_element,options,'CTABLE',ctable
str_element,options,'CHARSIZE',charsize
str_element,options,'LANDSCAPE',land
str_element,options,'NOPLOT',ignore

IF KEYWORD_SET(ignore) THEN RETURN
;;----------------------------------------------------------------------------------------
;; => Determine file name
;;----------------------------------------------------------------------------------------
extension = (['.ps','.eps'])[KEYWORD_SET(encap)]
IF (N_ELEMENTS(n) NE 0) THEN BEGIN
  IF (SIZE(n,/TYPE) EQ 0) THEN n = 1
  IF (SIZE(n,/TYPE) EQ 2) THEN BEGIN
    fname = STRCOMPRESS('plot'+STRING(n)+extension,/REMOVE_ALL)
    n    += 1
  ENDIF
  IF (SIZE(n,/TYPE) EQ 7) THEN BEGIN
    test  = (STRPOS(n,extension[0]) NE (STRLEN(n) - STRLEN(extension[0])))
    IF (test) THEN BEGIN
      fname = n+extension[0]
    ENDIF ELSE BEGIN
      fname = n
    ENDELSE
  ENDIF
ENDIF

IF (SIZE(fname,/TYPE) NE 7) THEN fname = 'plot'+extension[0]
IF (print_directory NE '')  THEN fname = print_directory+'/'+fname

IF (N_ELEMENTS(old_device) EQ 0) THEN popened = 0
IF (popened) THEN  pclose,PRINTER=printer
;; => Print out message
PRINT,'Opening postscript file ',fname[0],' Use PCLOSE to close'
;;----------------------------------------------------------------------------------------
;; => Remember original default settings
;;----------------------------------------------------------------------------------------
old_device = !D.NAME
old_fname  = fname
old_plot   = !P

IF (N_ELEMENTS(interp) EQ 0) THEN interp = 0
IF (N_ELEMENTS(copy) EQ 0) THEN copy = 0
;; => Change Device to PostScript
SET_PLOT,'PS',INTERPOLATE=interp,COPY=copy

IF KEYWORD_SET(encap) THEN  DEVICE,ENCAPSULATED=1 ELSE DEVICE,ENCAPSULATED=0

IF KEYWORD_SET(charsize) THEN !P.CHARSIZE = charsize
;;----------------------------------------------------------------------------------------
;; => Determine output printing options
;;----------------------------------------------------------------------------------------
print_options,PORT=port,LANDSCAPE=land,COLOR=color,BW=bw,PRINTER=printer, $
              FONT=font,ASPECT=aspect,XSIZE=xsize,YSIZE=ysize,UNITS=units

IF (N_ELEMENTS(ctable) NE 0) THEN loadct2,ctable

IF KEYWORD_SET(bw) THEN BEGIN  ; => Force all colors to black
  TVLCT,r,g,b,/GET
  r[*] = 100 & g[*] = 200 & b[*] = 30
  TVLCT,r,g,b
ENDIF
;; => Define Device file name
DEVICE,FILENAME=old_fname
popened = 1
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
