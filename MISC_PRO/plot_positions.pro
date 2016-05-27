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

FUNCTION plot_positions,XSIZES=xsizes,YSIZES=ysizes,OPTIONS=opts,OUT_POSITION=pos, $
                        XGAP=xgap,YGAP=ygap,REGION=region,ASPECT=aspect

;-----------------------------------------------------------------------------------------
; => check input values and set defaults
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(region) THEN region = !P.REGION

default = {REGION:region,POSITION:!P.POSITION,XMARGIN:!X.MARGIN,$
           YMARGIN:!Y.MARGIN,CHARSIZE:!P.CHARSIZE}

IF (default.CHARSIZE EQ 0) THEN default.CHARSIZE = 1.

IF (N_ELEMENTS(ysizes) EQ 0) THEN ysizes = 1.
IF (N_ELEMENTS(xsizes) EQ 0) THEN xsizes = 1.

extract_tags,default,opts

pos = default.POSITION
IF KEYWORD_SET(region) THEN pos[[0,2]] = 0.
;-----------------------------------------------------------------------------------------
; => normalize units
;-----------------------------------------------------------------------------------------
xspace = default.CHARSIZE * !D.X_CH_SIZE/!D.X_SIZE
yspace = default.CHARSIZE * !D.Y_CH_SIZE/!D.Y_SIZE

IF (pos[0] EQ pos[2]) THEN BEGIN
   reg = default.REGION
   IF (reg[0] EQ reg[2]) THEN reg = [0.,0.,1.,1.]
   xm    = default.XMARGIN * xspace
   ym    = default.YMARGIN * yspace
   delta = [xm[0],ym[0],-xm[1],-ym[1]]
   pos   = reg + delta
ENDIF
;-----------------------------------------------------------------------------------------
; => determine [X,Y]-margins
;-----------------------------------------------------------------------------------------
;if n_elements(ygap) ne nsy then begin
;   if n_elements(ygap) eq 0 then ygap=1.
;   ygap = replicate(ygap(0),nsy)
;   ygap(0) = 0.
;endif
nsy = N_ELEMENTS(ysizes)
IF (N_ELEMENTS(ygap) EQ 0)    THEN ygaps = 1. ELSE ygaps = ygap
IF (N_ELEMENTS(ygaps) NE nsy) THEN ygaps = REPLICATE(ygaps[0],nsy)
ygaps[0] = 0 

nsx = N_ELEMENTS(xsizes)
IF (N_ELEMENTS(xgap) EQ 0)    THEN xgaps = 1. ELSE xgaps = xgap
IF (N_ELEMENTS(xgaps) NE nsx) THEN xgaps = REPLICATE(xgaps[0],nsx)
xgaps[0] = 0 

;if n_elements(xgap) ne nsx then begin
;   if n_elements(xgap) eq 0 then xgap=1.
;   xgap = replicate(xgap(0),nsx)
;   xgap(0) = 0.
;endif

yw = [pos[1],pos[3]]
xw = [pos[0],pos[2]]

tygap = TOTAL(ygaps,/NAN)*yspace
ynorm = (yw[1] - yw[0] - tygap)/TOTAL(ysizes,/NAN)

txgap = TOTAL(xgaps,/NAN)*xspace
xnorm = (xw[1] - xw[0] - txgap)/TOTAL(xsizes,/NAN)
;-----------------------------------------------------------------------------------------
; => determine plot positions
;-----------------------------------------------------------------------------------------
positions = FLTARR(4,nsy*nsx)
ypos      = yw[1]
n         = 0
FOR i=0L, nsy - 1L DO BEGIN
  xpos = xw[0]
  gy   = ygaps[i] * yspace
  sy   = ysizes[i]  * ynorm
  FOR j=0L, nsx - 1L DO BEGIN
     gx = xgaps[j]*xspace
     sx = xsizes[j]*xnorm
     p  = [xpos + gx, ypos - sy - gy, xpos + gx + sx, ypos - gy]
     positions[*,n] = p
     n   += 1
     xpos = p[2]
  ENDFOR
  ypos = p[1]
ENDFOR
;-----------------------------------------------------------------------------------------
; => determine aspect ratio
;-----------------------------------------------------------------------------------------
aspect = (positions[3,*] - positions[1,*])/(positions[2,*] - positions[0,*])
aspect = aspect * !D.Y_SIZE/!D.X_SIZE
IF (N_ELEMENTS(aspect) EQ 1) THEN aspect = aspect[0]

RETURN,positions
END
