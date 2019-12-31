;*****************************************************************************************
;
;  FUNCTION :   oploterrxy_input.pro
;  PURPOSE  :   Formats the input values for oploterrxy.pro
;
;  CALLED BY:   
;               oploterrxy.pro
;
;  CALLS:
;               
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X          :  [N]-Element [numeric] array of independent variable data
;               Y          :  [N]-Element [numeric] array of dependent variable data
;               XERR       :  [N,2]-Element [numeric] array of errors for the independent
;                                variable data.  If three parameters are passed, then
;                                the third parameter is treated as YERR.
;               YERR       :  [N,2]-Element [numeric] array of errors for the dependent
;                                variable data.
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Updated Man. page and cleaned up routine
;                                                                   [07/28/2015   v1.0.1]
;             2)  Cleaned up main routine
;                                                                   [07/28/2015   v1.0.1]
;
;   NOTES:      
;               1)  The error inputs should represent the low end range of the data
;                     minus the low end uncertainty, while the high end is just the
;                     converse:
;                       High end plotted result  :  [x,y] + [x,y]err
;                       Low  end plotted result  :  [x,y] - [x,y]err
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/10/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/28/2015   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION oploterrxy_input,x,y,xerr,yerr

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
zero     = 0d0
;;----------------------------------------------------------------------------------------
;;  Define error return
;;----------------------------------------------------------------------------------------
ON_ERROR, 0
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
np = N_PARAMS()
IF (np LT 2) THEN BEGIN
  PRINT, "OPLOTERR must be called with at least two parameters."
  PRINT, "Syntax: oploterr, [x,] y, [xerr], yerr"
  RETURN,0
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define plotting parameters
;;----------------------------------------------------------------------------------------
npars = [N_ELEMENTS(x),N_ELEMENTS(y),N_ELEMENTS(xerr),N_ELEMENTS(yerr)]
np    = LONG(TOTAL(npars NE 0))
IF (np EQ 2) THEN BEGIN
  ;; Only Y and YERR passed.
  yerr = REFORM(y)
  yy   = x
  xx   = INDGEN(N_ELEMENTS(yy))
  xerr = MAKE_ARRAY(SIZE=SIZE(xx))
ENDIF ELSE IF (np EQ 3) THEN BEGIN
  ;; X, Y, and YERR passed.
  yerr = REFORM(xerr)
  yy   = y
  xx   = x
  xerr = MAKE_ARRAY(SIZE=SIZE(xx))
ENDIF ELSE BEGIN
  ;; X, Y, XERR and YERR passed.
  yerr = REFORM(yerr)
  yy   = y
  xerr = REFORM(xerr)
  xx   = x
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check size of error inputs
;;----------------------------------------------------------------------------------------
szxer          = SIZE(xerr,/DIMENSIONS)
szyer          = SIZE(yerr,/DIMENSIONS)
;;--------------------------------------------------
;;  XERR
;;--------------------------------------------------
CASE N_ELEMENTS(szxer) OF
  1    : BEGIN
    ;; 1D input
    IF (N_ELEMENTS(xerr) EQ 1) THEN BEGIN
      ;; Scalar input => apply to all
      xerr = REPLICATE(xerr[0],N_ELEMENTS(xx),2L)
    ENDIF ELSE BEGIN
      xerr = xerr # REPLICATE(1d0,2L)
    ENDELSE
  END
  2    : BEGIN
    ;; 2D input
    test = TOTAL(szxer EQ 2)
    CASE test[0] OF
      0    : BEGIN
        ;; bad input format => make dummy values
        xerr = REPLICATE(zero[0],N_ELEMENTS(xx),2L)
      END
      1    : BEGIN
        IF (szxer[1] NE 2) THEN BEGIN
          ;; [2,N]-Element array input
          xerr = TRANSPOSE(xerr)
        ENDIF ELSE BEGIN
          ;; [N,2]-Element array input
          xerr = REFORM(xerr)
        ENDELSE
      END
      ELSE : BEGIN
        ;; [2,2]-Element array input => leave alone
        xerr = REFORM(xerr)
      END
    ENDCASE
  END
  ELSE : BEGIN
    ;; Redefine X-Errors to zero
    xerr = REPLICATE(zero,N_ELEMENTS(xx),2L)
  END
ENDCASE
;;--------------------------------------------------
;;  YERR
;;--------------------------------------------------
CASE N_ELEMENTS(szyer) OF
  1    : BEGIN
    ;; 1D input
    IF (N_ELEMENTS(yerr) EQ 1) THEN BEGIN
      ;; Scalar input => apply to all
      yerr = REPLICATE(yerr[0],N_ELEMENTS(yy),2L)
    ENDIF ELSE BEGIN
      yerr = yerr # REPLICATE(1d0,2L)
    ENDELSE
  END
  2    : BEGIN
    ;; 2D input
    test = TOTAL(szyer EQ 2)
    CASE test[0] OF
      0    : BEGIN
        ;; bad input format => make dummy values
        yerr = REPLICATE(zero[0],N_ELEMENTS(yy),2L)
      END
      1    : BEGIN
        IF (szyer[1] NE 2) THEN BEGIN
          ;; [2,N]-Element array input
          yerr = TRANSPOSE(yerr)
        ENDIF ELSE BEGIN
          ;; [N,2]-Element array input
          yerr = REFORM(yerr)
        ENDELSE
      END
      ELSE : BEGIN
        ;; [2,2]-Element array input => leave alone
        yerr = REFORM(yerr)
      END
    ENDCASE
  END
  ELSE : BEGIN
    ;; Redefine X-Errors to zero
    yerr = REPLICATE(zero,N_ELEMENTS(yy),2L)
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Determine the number of points being plotted.  This is the size of the smallest of
;;      the three arrays passed to the procedure.  Truncate any overlong arrays.
;;----------------------------------------------------------------------------------------
n              = N_ELEMENTS(xx) < N_ELEMENTS(yy)
IF (np GT 2) THEN n = n < N_ELEMENTS(yerr)
IF (np EQ 4) THEN n = n < N_ELEMENTS(xerr)

xx             = xx[0L:(n - 1L)]
yy             = yy[0L:(n - 1L)]
yerr           = yerr[0L:(n - 1L),*]
xerr           = xerr[0L:(n - 1L),*]
;; Define high/low values for Y-Error
ylo            = yy - yerr[*,0]
yhi            = yy + yerr[*,1]
;; Define high/low values for X-Error
xlo            = xx - xerr[*,0]
xhi            = xx + xerr[*,1]
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
tag_suf        = ['_DATA','__LOW','_HIGH']
tags           = ['X'+tag_suf,'Y'+tag_suf]
struct         = CREATE_STRUCT(tags,xx,xlo,xhi,yy,ylo,yhi)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END


;*****************************************************************************************
;
;  PROCEDURE:   oploterrxy_keywords.pro
;  PURPOSE  :   Interprets the input keywords set by user.
;
;  CALLED BY:   
;               oploterrxy.pro
;
;  CALLS:
;               NA
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
;               See IDL documentation for "Graphics Keywords"
;
;   CHANGED:  1)  Updated Man. page and cleaned up routine
;                                                                   [07/28/2015   v1.0.1]
;             2)  Cleaned up main routine
;                                                                   [07/28/2015   v1.0.1]
;
;   NOTES:      
;               1)  J.R. Woodroffe originally named this plot_keywords.pro
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/27/2007
;   CREATED BY:  J.R. Woodroffe
;    LAST MODIFIED:  07/28/2015   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

PRO oploterrxy_keywords,BACKGROUND=back,CHANNEL=chan,CHARSIZE=chsiz,CHARTHICK=chthck,   $
                        COLOR=color,DATA=data,DEVICE=device,FONT=font,                  $
                        LINESTYLE=linestyle,NOCLIP=noclip,NODATA=nodata,NOERASE=noerase,$
                        NORMAL=normal,NSUM=nsum,PSYM=psym,SUBTITLE=subtit,T3D=t3d,      $
                        SYMSIZE=symsize,THICK=thick,TICKLEN=ticklen,TITLE=title,        $
                        XCHARSIZE=xchsiz,XMARGIN=xmargn,XMINOR=xminor,XRANGE=xrange,    $
                        XSTYLE=xstyle,XTHICK=xthick,XTICKLEN=xtickln,XTICKNAME=xticknm, $
                        XTICKS=xticks,XTICKV=xtickv,XTITLE=xtitle,XTYPE=xtype,          $
                        YCHARSIZE=ychsiz,YMARGIN=ymargn,YMINOR=yminor,YNOZERO=ynozero,  $
                        YRANGE=yrange,YSTYLE=ystyle,YTHICK=ythick,YTICKLEN=ytickln,     $
                        YTICKNAME=yticknm,YTICKS=yticks,YTICKV=ytickv,YTITLE=ytitle,    $
                        YTYPE=ytype

;;----------------------------------------------------------------------------------------
;;  Define error return
;;----------------------------------------------------------------------------------------
ON_ERROR, 2
;;----------------------------------------------------------------------------------------
;;  General plotting keywords
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS( back )      EQ 0) THEN back      = !P.BACKGROUND
IF (N_ELEMENTS( chan )      EQ 0) THEN chan      = !P.CHANNEL
IF (N_ELEMENTS( chsiz )     EQ 0) THEN chsiz     = !P.CHARSIZE
IF (N_ELEMENTS( chthck )    EQ 0) THEN chthck    = !P.CHARTHICK
IF (N_ELEMENTS( clip )      EQ 0) THEN clip      = !P.CLIP
IF (N_ELEMENTS( color )     EQ 0) THEN color     = !P.COLOR
IF (N_ELEMENTS( data )      EQ 0) THEN data      = 0
IF (N_ELEMENTS( device )    EQ 0) THEN device    = 0
IF (N_ELEMENTS( font )      EQ 0) THEN font      = !P.FONT
IF (N_ELEMENTS( linestyle ) EQ 0) THEN linestyle = !P.LINESTYLE
IF (N_ELEMENTS( noclip )    EQ 0) THEN noclip    = 0
IF (N_ELEMENTS( nodata )    EQ 0) THEN nodata    = 0
IF (N_ELEMENTS( noerase )   EQ 0) THEN noerase   = 0
IF (N_ELEMENTS( normal )    EQ 0) THEN normal    = 0
IF (N_ELEMENTS( nsum )      EQ 0) THEN nsum      = !P.NSUM
IF (N_ELEMENTS( position )  EQ 0) THEN position  = !P.POSITION
IF (N_ELEMENTS( psym )      EQ 0) THEN psym      = !P.PSYM
IF (N_ELEMENTS( subtit )    EQ 0) THEN subtit    = !P.SUBTITLE
IF (N_ELEMENTS( symsize )   EQ 0) THEN symsize   = 1.0
IF (N_ELEMENTS( t3d )       EQ 0) THEN t3d       = 0
IF (N_ELEMENTS( thick )     EQ 0) THEN thick     = !P.THICK
IF (N_ELEMENTS( ticklen )   EQ 0) THEN ticklen   = !P.TICKLEN
IF (N_ELEMENTS( title )     EQ 0) THEN title     = !P.TITLE
;;----------------------------------------------------------------------------------------
;;  X-axis keywords
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS( xchsiz )    EQ 0) THEN xchsiz    = !X.CHARSIZE
IF (N_ELEMENTS( xmargn )    EQ 0) THEN xmargn    = !X.MARGIN
IF (N_ELEMENTS( xminor )    EQ 0) THEN xminor    = !X.MINOR
IF (N_ELEMENTS( xrange )    EQ 0) THEN xrange    = !X.RANGE
IF (N_ELEMENTS( xstyle )    EQ 0) THEN xstyle    = !X.STYLE
IF (N_ELEMENTS( xthick )    EQ 0) THEN xthick    = !X.THICK
IF (N_ELEMENTS( xtickln )   EQ 0) THEN xtickln   = !X.TICKLEN
IF (N_ELEMENTS( xticknm )   EQ 0) THEN xticknm   = !X.TICKNAME
IF (N_ELEMENTS( xticks )    EQ 0) THEN xticks    = !X.TICKS
IF (N_ELEMENTS( xtickv )    EQ 0) THEN xtickv    = !X.TICKV
IF (N_ELEMENTS( xtitle )    EQ 0) THEN xtitle    = !X.TITLE
IF (N_ELEMENTS( xtype )     EQ 0) THEN xtype     = 0
;;----------------------------------------------------------------------------------------
;;  Y-axis keywords
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS( ychsiz )    EQ 0) THEN ychsiz    = !Y.CHARSIZE
IF (N_ELEMENTS( ymargn )    EQ 0) THEN ymargn    = !Y.MARGIN
IF (N_ELEMENTS( yminor )    EQ 0) THEN yminor    = !Y.MINOR
IF (N_ELEMENTS( ynozero )   EQ 0) THEN ynozero   = (!Y.STYLE AND 16)
IF (N_ELEMENTS( yrange )    EQ 0) THEN yrange    = !Y.RANGE
IF (N_ELEMENTS( ystyle )    EQ 0) THEN ystyle    = !Y.STYLE
IF (N_ELEMENTS( ythick )    EQ 0) THEN ythick    = !Y.THICK
IF (N_ELEMENTS( ytickln )   EQ 0) THEN ytickln   = !Y.TICKLEN
IF (N_ELEMENTS( yticknm )   EQ 0) THEN yticknm   = !Y.TICKNAME
IF (N_ELEMENTS( yticks )    EQ 0) THEN yticks    = !Y.TICKS
IF (N_ELEMENTS( ytickv )    EQ 0) THEN ytickv    = !Y.TICKV
IF (N_ELEMENTS( ytitle )    EQ 0) THEN ytitle    = !Y.TITLE
IF (N_ELEMENTS( ytype )     EQ 0) THEN ytype     = 0
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   oploterrxy.pro
;  PURPOSE  :   Plots data points with error bars for both the independent and dependent
;                 variables.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               oploterrxy_input.pro
;               oploterrxy_keywords.pro
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               X          :  [N]-Element array of independent variable data
;               Y          :  [N]-Element array of dependent variable data
;               XERR       :  [N,2]-Element array of errors for the independent variable
;                                data.  If three parameters are passed, then the third
;                                parameter is treated as YERR.
;               YERR       :  [N,2]-Element array of errors for the dependent variable
;                                data.
;
;  EXAMPLES:    
;               PLOT,x,y
;               oploterr, [x,] y, [xerr], yerr
;
;  KEYWORDS:    
;               *****************
;               ***   INPUT   ***
;               *****************
;               NOHAT      :  If set, routine does not plot X-errors
;                               [Default = 1]
;               HATLENGTH  :  Scalar defining a scale factor for the size of the error
;                               bars in DEVICE units
;                               [Default = !D.[X,Y]_VSIZE/100.]
;               ERRTHICK   :  The THICK format for error bars
;                               [Default = defined by THICK]
;               ERRSTYLE   :  The LINESTYLE format for error bars
;                               [Default = 0]
;               ***  Keywords accepted by PLOT.PRO  ***
;               COLOR      :  Same as COLOR in PLOT.PRO documentation
;               LINESTYLE  :  Same as LINESTYLE in PLOT.PRO documentation
;               NOCLIP     :  Same as NOCLIP in PLOT.PRO documentation
;               NSUM       :  Same as NSUM in PLOT.PRO documentation
;               PSYM       :  Same as PSYM in PLOT.PRO documentation
;               SYMSIZE    :  Same as SYMSIZE in PLOT.PRO documentation
;               T3D        :  Same as T3D in PLOT.PRO documentation
;               THICK      :  Same as THICK in PLOT.PRO documentation
;               
;
;   CHANGED:  1)  Updated man page, added comments, cleaned up, and now calls:
;                   oploterrxy_input.pro and oploterrxy_keywords.pro
;                                                                   [09/10/2012   v1.1.0]
;             2)  Updated Man. page and cleaned up routine; and
;                   changed SYMSIZ keyword to SYMSIZE; and changed
;                   keyword variable names for NOHAT, ERRTHICK, and ERRSTYLE; and
;                   now calls is_a_number.pro
;                                                                   [07/28/2015   v1.2.0]
;             3)  Cleaned up
;                                                                   [07/28/2015   v1.2.1]
;
;   NOTES:      
;               1)  If # of parameters passed are less than 4, here are the results:
;                     0 or 1  :  routine returns without plotting
;                     2       :  X --> Y and Y --> YERR
;                     3       :  X --> X, Y --> Y, and XERR --> YERR
;               2)  If XERR or YERR are only 1D arrays, then the plot uses +/- ERR for
;                     error bars
;               3)  The error inputs should represent the low end range of the data
;                     minus the low end uncertainty, while the high end is just the
;                     converse
;               4)  It is probably better to let IDL define the size of the error bar
;                     hat lengths (i.e., do not set HATLENGTH)
;
;  REFERENCES:  
;               NA
;
;   CREATED:  09/27/2007
;   CREATED BY:  J.R. Woodroffe
;    LAST MODIFIED:  07/28/2015   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO oploterrxy,x,y,xerr,yerr,NOHAT=nohat,HATLENGTH=hln,ERRTHICK=ethick,ERRSTYLE=estyle,   $
                             COLOR=color,LINESTYLE=linest,NOCLIP=noclip,NSUM=nsum,  $
                             PSYM=psym,SYMSIZE=symsize,T3D=t3d,THICK=thick

;;  Let IDL know that the following are functions
FORWARD_FUNCTION oploterrxy_input, is_a_number
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
zero           = 0d0
;;----------------------------------------------------------------------------------------
;;  Define error return
;;----------------------------------------------------------------------------------------
ON_ERROR, 0
;;----------------------------------------------------------------------------------------
;;  Other keywords
;;      If no x array has been supplied, create one.  Make sure the rest of the procedure
;;      can know which parameter is which.
;;----------------------------------------------------------------------------------------
np             = N_PARAMS()
input          = oploterrxy_input(x,y,xerr,yerr)
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (SIZE(input,/TYPE) NE 8) THEN BEGIN
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define plotting parameters
;;----------------------------------------------------------------------------------------
xx             = input.X_DATA
yy             = input.Y_DATA
;; Define high/low values for Y-Error
ylo            = input.Y__LOW
yhi            = input.Y_HIGH
;; Define high/low values for X-Error
xlo            = input.X__LOW
xhi            = input.X_HIGH
;;  Define # of points
n              = N_ELEMENTS(xx)
;;----------------------------------------------------------------------------------------
;;  Initialize plot keywords
;;----------------------------------------------------------------------------------------
oploterrxy_keywords,COLOR=color,LINESTYLE=linest,NOCLIP=noclip,NSUM=nsum, $
                    PSYM=psym,SYMSIZE=symsize,T3D=t3d,THICK=thick
;;----------------------------------------------------------------------------------------
;;  Initialize error bar keywords (except for HATLENGTH; this one will be taken care
;;      of later, when it is time to deal with the error bar hats).
;;----------------------------------------------------------------------------------------
;;  Check NOHAT
test           = KEYWORD_SET(nohat)
IF (test) THEN hat = 0 ELSE hat = 1
;;  Check ERRTHICK
test           = (N_ELEMENTS(ethick) EQ 0) OR (is_a_number(ethick,/NOMSSG) EQ 0)
IF (test) THEN eth = thick ELSE eth = ethick[0]
;;  Check ERRSTYLE
test           = (N_ELEMENTS(estyle) EQ 0) OR (is_a_number(estyle,/NOMSSG) EQ 0)
IF (test) THEN est = 0 ELSE est = estyle[0]
;;----------------------------------------------------------------------------------------
;;  Plot the positions
;;----------------------------------------------------------------------------------------
IF (n GT 1) THEN BEGIN
  OPLOT,xx,yy,COLOR=color,LINESTYLE=linest,THICK=thick,NOCLIP=noclip,NSUM=nsum, $
              PSYM=psym,SYMSIZE=symsize,T3D=t3d
ENDIF ELSE BEGIN
  IF (n EQ 1) THEN PLOTS,xx,yy,COLOR=color,THICK=thick,NOCLIP=noclip,PSYM=psym,SYMSIZE=symsize,T3D=t3d
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Compute the hat length in device coordinates so that it
;;      remains fixed even when doing logarithmic plots.
;;----------------------------------------------------------------------------------------
data_low       = CONVERT_COORD(xx,ylo,/DATA,/TO_DEVICE)
data_hi        = CONVERT_COORD(xx,yhi,/DATA,/TO_DEVICE)
IF (np EQ 4) THEN BEGIN
  x_low = CONVERT_COORD(xlo,yy,/DATA,/TO_DEVICE)
  x_hi  = CONVERT_COORD(xhi,yy,/DATA,/TO_DEVICE)
ENDIF
;;  Get plotted data range
ycrange        = !Y.CRANGE
xcrange        = !X.CRANGE
xlog           = !X.TYPE
ylog           = !Y.TYPE
IF (xlog) THEN xcrange = 1d1^(xcrange)
IF (ylog) THEN ycrange = 1d1^(ycrange)
;;  Define XY-visible sizes
xy_v_sz        = [!D.X_VSIZE[0],!D.Y_VSIZE[0]]
;;  Check HATLENGTH
test           = (N_ELEMENTS(hln) EQ 0) OR (is_a_number(hln,/NOMSSG) EQ 0)
IF (test) THEN hlnx = xy_v_sz[0]/100. ELSE hlnx = hln[0]
IF (test) THEN hlny = xy_v_sz[1]/100. ELSE hlny = hln[0]
;;----------------------------------------------------------------------------------------
;;  Plot the error bars
;;----------------------------------------------------------------------------------------
FOR i=0L, n[0] - 1L DO BEGIN
  ;;  Reset test variables
  noplot     = 0b
  ;;  Test whether to plot i-th points
  test_x     = (xx[i] GT MAX(xcrange,/NAN)) OR (xx[i] LT MIN(xcrange,/NAN))
  test_y     = (yy[i] GT MAX(ycrange,/NAN)) OR (yy[i] LT MIN(ycrange,/NAN))
  IF (test_x OR test_y) THEN noplot = 1b
  IF (noplot EQ 0) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Plot Y-error bars
    ;;------------------------------------------------------------------------------------
    PLOTS,[xx[i],xx[i]], [ylo[i],yhi[i]], LINESTYLE=est,THICK=eth,COLOR=color
    ;;------------------------------------------------------------------------------------
    ;;  Plot X-error bars
    ;;------------------------------------------------------------------------------------
    IF (np EQ 4) THEN PLOTS,[xlo[i],xhi[i]],[yy[i],yy[i]],LINESTYLE=est,THICK=eth,COLOR=color
    IF (hat NE 0) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Plot "hats" on ends of error bars
      ;;----------------------------------------------------------------------------------
      ;;  Define X-extent of hat (i.e., length of horizontal line on plot)
      exx1 = data_low[0,i] - hlnx[0]/2.
      exx2 =       exx1[0] + hlnx[0]
      ;;  Output hats on Y-error bars
      PLOTS,[exx1[0],exx2[0]],[data_low[1,i],data_low[1,i]],LINESTYLE=est,THICK=eth,/DEVICE,COLOR=color
      PLOTS,[exx1[0],exx2[0]],[ data_hi[1,i], data_hi[1,i]],LINESTYLE=est,THICK=eth,/DEVICE,COLOR=color
      IF (np EQ 4) THEN BEGIN
        ;;  Define Y-extent of hat (i.e., length of vertical line on plot)
        eyy1 = x_low[1,i] - hlny[0]/2.
        eyy2 =    eyy1[0] + hlny[0]
        PLOTS,[x_low[0,i],x_low[0,i]],[eyy1[0],eyy2[0]],LINESTYLE=est,THICK=eth,/DEVICE,COLOR=color
        PLOTS,[ x_hi[0,i], x_hi[0,i]],[eyy1[0],eyy2[0]],LINESTYLE=est,THICK=eth,/DEVICE,COLOR=color
      ENDIF
    ENDIF
  ENDIF
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Re-plot the positions
;;----------------------------------------------------------------------------------------
IF (n GT 1) THEN BEGIN
  OPLOT,xx,yy,COLOR=color,LINESTYLE=linest,THICK=thick,NOCLIP=noclip,NSUM=nsum, $
              PSYM=psym,SYMSIZE=symsize,T3D=t3d
ENDIF ELSE BEGIN
  IF (n EQ 1) THEN PLOTS,xx,yy,COLOR=color,THICK=thick,NOCLIP=noclip,PSYM=psym,SYMSIZE=symsize,T3D=t3d
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END