;+
;*****************************************************************************************
;
;  FUNCTION :   smear_data_plot.pro
;  PURPOSE  :   This program produces a series of data points surrounding the input
;                 data to produce the effect of "discrete smearing" of the data points.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  User must have plotted some data with !D.NAME = 'X' prior to running
;                     this routine
;
;  INPUT:
;               XX      :  N-Element array of x-data
;               YY      :  N-Element array of y-data
;
;  EXAMPLES:    
;               nn   = 100L
;               xx   = DINDGEN(nn)*2d0*!DPI/(nn - 1L)
;               yy   = COS(xx)
;               PLOT,xx,yy,/NODATA,/XSTYLE,/YSTYLE,XTITLE='x (rad)',YTITLE='COS(x)'
;                 OPLOT,xx,yy,PSYM=3
;               test = smear_data_plot(xx,yy,NS=2L,/CIRCLE,/OPLT)
;
;  KEYWORDS:    
;               NS      :  Scalar defining the number of points to add in the surrounding
;                            area to act as a smear.
;                            [Default = 1]
;               SQUARE  :  If set, program adds NS-rows of points in a square lattice
;                            around initial point
;                            [Default]
;               CIRCLE  :  If set, program adds NS-concentric circles of points
;                            around initial point
;               OPLT    :  If set, program will overplot the extra points in the current
;                            plot window
;
;   CHANGED:  1)  Finished writing and cleaning up the program [04/20/2011   v1.0.0]
;
;   NOTES:      
;               1)  Below is an example of [NS=1] square-smearing which just adds
;                     points in square around the initial point at [i,j]
;
;                  [(i-1),(j+1)]  [i,(j+1)]  [(i+1),(j+1)]
;
;                    [(i-1),j]      [i,j]      [(i+1),j]
;
;                  [(i-1),(j-1)]  [i,(j-1)]  [(i+1),(j-1)]
;
;
;   CREATED:  04/19/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/20/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION smear_data_plot,xx,yy,NS=ns,SQUARE=sqr,CIRCLE=circ,OPLT=oplt

;-----------------------------------------------------------------------------------------
; => Define dummy variables and check keywords
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
badinmssg      = 'Incorrect input:  XX and YY must have the same number of elements.'
devicemssg     = "Incorrect device:  !D.NAME MUST equal 'X' or 'WIN'"
windowmssg     = 'A X-Window must be in use!'
; => Check device usage
IF (STRLOWCASE(!D.NAME) NE 'x' AND STRLOWCASE(!D.NAME) NE 'win') THEN BEGIN
  MESSAGE,devicemssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
; => Make sure a Window is open and in use
IF (!D.WINDOW LT 0 OR !X.CRANGE[0] EQ !X.CRANGE[1]) THEN BEGIN
  MESSAGE,windowmssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF

IF ~KEYWORD_SET(ns) THEN nsm = 1 ELSE nsm = LONG(ns[0])

IF ~KEYWORD_SET(circ) THEN cc = 0 ELSE cc = 1
IF (~KEYWORD_SET(cc) AND ~KEYWORD_SET(sqr)) THEN BEGIN
  ss = 1
ENDIF ELSE BEGIN
  IF KEYWORD_SET(sqr) THEN ss = 1 ELSE ss = 0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
xo    = REFORM(xx)
yo    = REFORM(yy)
nx    = N_ELEMENTS(xo)
ny    = N_ELEMENTS(yo)
IF (nx NE ny) THEN BEGIN
  MESSAGE,badinmssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
nn    = nx                ; => # of data points
xydev = CONVERT_COORD(xo,yo,/DATA,/TO_DEVICE)
xdev  = REFORM(xydev[0,*])
ydev  = REFORM(xydev[1,*])
;-----------------------------------------------------------------------------------------
; => Determine character size as a way to scale the shifts in X and Y
;-----------------------------------------------------------------------------------------
nwx     = !D.X_SIZE       ; => X-Axis size of Window (Device coordinates, e.g. pixels)
nwy     = !D.Y_SIZE       ; => Y-Axis size of Window (Device coordinates, e.g. pixels)
chsize0 = 0.75
; => TEXT_AXES = 0 -> [X = horizontal, Y = vertical]
XYOUTS,0.5,0.5,/NORMAL,'.',WIDTH=twdthx,TEXT_AXES=0,CHARSIZE=-chsize0
dotdev  = REFORM(CONVERT_COORD(twdthx[0],twdthx[0],/NORMAL,/TO_DEVICE))
delx    = dotdev[0]       ; => Shift in X-data [Device Coordinates]
dely    = delx[0]
mxexpts = 8L*nsm[0]       ; => # of extra points in outermost level
gridx   = 2L*nsm[0] + 1L  ; => # of points per side of outermost level

xdeva   = REPLICATE(d,nn,gridx)
ydeva   = REPLICATE(d,nn,gridx)
;expts   = 8L*nsm[0] + 1L  ; => 1 -> 9, 2 -> 17, 3 -> 25, etc.

CASE 1 OF
  ss  :  BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Square smearing
    ;-------------------------------------------------------------------------------------
    xdeva   = REPLICATE(d,nn,gridx)
    ydeva   = REPLICATE(d,nn,gridx)
    FOR j=0L, gridx - 1L DO BEGIN
      jj            = j - nsm[0]
      ; => Square smearing
      xdeva[*,j]    = xdev[*] + jj[0]*delx[0]
      ydeva[*,j]    = ydev[*] + jj[0]*dely[0]
    ENDFOR
    dim2 = mxexpts[0]*(nsm[0] + 1L)
  END
  cc  :  BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Circular smearing
    ;-------------------------------------------------------------------------------------
    ;    Determine the angles of the outermost level
    oangs   = DINDGEN(mxexpts[0])*(2d0*!DPI)/(mxexpts[0] - 1L)
    dang    = (MAX(oangs,/NAN) - MIN(oangs,/NAN))/(mxexpts[0] - 1L)
    rads    = SQRT(xdev^2 + ydev^2)   ; => Radial values of original points
    dr      = SQRT(delx[0]^2 + dely[0]^2)
    
    xdeva   = REPLICATE(d,nn,mxexpts[0],nsm[0]+1L)
    ydeva   = REPLICATE(d,nn,mxexpts[0],nsm[0]+1L)
    FOR k=0L, nsm[0] DO BEGIN
      ; => Different # of angle bins for each level
      kk = (nsm[0] - k) + 1L    ; = nsm + 1, nsm, nsm - 1, ... , 3, 2, 1
      IF (k EQ 0) THEN BEGIN
        xdeva[*,0,0] = xdev[*]
        ydeva[*,0,0] = ydev[*]
      ENDIF ELSE BEGIN
        tt = 1             ; => Logic parameter
        jj = 0L            ; => Index that changes for each level
        j  = 0L            ; => Index associated with outermost level
        WHILE(tt) DO BEGIN
          ; => Calculate the radial shift
          dx            = COS(oangs[jj])*(k[0]*dr[0])
          dy            = SIN(oangs[jj])*(k[0]*dr[0])
          xdeva[*,jj,k] = xdev[*] + dx
          ydeva[*,jj,k] = ydev[*] + dy
          ; => iterate if necessary
          jj            = j*kk
          tt            = (jj LT mxexpts - 1L)
          j            += tt
        ENDWHILE
      ENDELSE
    ENDFOR
    dim2 = mxexpts[0]*(nsm[0] + 1L)
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Plot extra points if desired
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(oplt) THEN BEGIN
  CASE 1 OF
    ss  :  BEGIN
      ; => Square smearing
      FOR j=0L, gridx - 1L DO BEGIN
        FOR k=0L, gridx - 1L DO BEGIN
          PLOTS,xdeva[*,j],ydeva[*,k],/DEVICE,PSYM=3
        ENDFOR
      ENDFOR
    END
    cc  :  BEGIN
      ; => Circular smearing
      PLOTS,xdeva[*,0,0],ydeva[*,0,0],/DEVICE,PSYM=3
      FOR j=0L, mxexpts - 1L DO BEGIN
        FOR i=1L, nsm[0] DO BEGIN
          PLOTS,xdeva[*,j,i],ydeva[*,j,i],/DEVICE,PSYM=3
        ENDFOR
      ENDFOR
    END
  ENDCASE
ENDIF
;-----------------------------------------------------------------------------------------
; => Return extra points to user
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(cc) THEN BEGIN
  xdeva = REFORM(xdeva,nn,dim2)
  ydeva = REFORM(ydeva,nn,dim2)
  ; => Note:  return value has [NN, MM, LL]-Elements where
  ;           NN = # of data points
  ;           MM = (Max # of points in outermost level) x (# of levels + 1)
  ;           LL = 2 => 0 = X, 1 = Y
ENDIF

RETURN,[ [[xdeva]], [[ydeva]] ]
;RETURN,[ [[TRANSPOSE(xdeva)]], [[TRANSPOSE(ydeva)]] ]
END
