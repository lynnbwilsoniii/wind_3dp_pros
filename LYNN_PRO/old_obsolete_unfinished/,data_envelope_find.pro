;+
;*****************************************************************************************
;
;  FUNCTION :   data_envelope_find.pro
;  PURPOSE  :   Determines the upper and lower bounds of an envelope of data.
;                ** Unfinished! **
;
;  CALLED BY:   
;               
;
;  CALLS:
;               
;
;  REQUIRES:    
;               
;
;  INPUT:
;               XX      :  N-Element array of x-data
;               YY      :  N-Element array of y-data
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;-------------------
;               SM      :  Scalar defining the number of points over which to determine
;                            the local max/min values for the envelope
;                            [Default and MIN = 10]
;-------------------
;               LENGTH  :  Scalar defining the # of elements in XX to treat as a
;                            single bin
;                            [Default and MIN = 10% of N]
;               OFFSET  :  Scalar defining the # of elements to shift each time
;                            the program recalculates the distribution in a bin
;                            [Default = 1/4 of LENGTH]
;               THRESH  :  Scalar defining the tolerance one allows when determining the
;                            local upper/lower bound that exceeds 2 STDEV
;                            [Default =  5%]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  STDEV   = Standard Deviation [std = STDDEV(X)]
;               2)  STDEVMN = Std. Dev. of the Mean = STDDEV(X)/SQRT(N)
;
;   CREATED:  04/19/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/19/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  data_envelope_find,xx,yy,SM=sm,LENGTH=length,OFFSET=offset,THRESH=thr

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
mnpt           = 10L
mnth           = 5d-2
nstdevs        = 2d0
badinmssg      = 'Incorrect input:  XX and YY must have the same number of elements'
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
xo  = REFORM(xx)
yo  = REFORM(yy)
nx  = N_ELEMENTS(xo)
ny  = N_ELEMENTS(yo)
IF (nx NE ny) THEN BEGIN
  MESSAGE,badinmssg,/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDIF
nn    = nx                ; => # of data points
mnlen = LONG(DOUBLE(nn)*1d-1)
; => Check keyword:  LENGTH
IF ~KEYWORD_SET(length) THEN len = mnlen[0]  ELSE len = LONG(length[0])
IF (len[0] LT mnlen[0]) THEN len = mnlen[0]
; => Check keyword:  OFFSET
IF ~KEYWORD_SET(offset) THEN off = len[0]/4L ELSE off = LONG(offset[0])
; => Check keyword:  THRESH
IF ~KEYWORD_SET(thr) THEN tol = mnth[0] ELSE tol = DOUBLE(thr[0])
;-----------------------------------------------------------------------------------------
; => Partition data
;-----------------------------------------------------------------------------------------
sp     = SORT(xo)  ; => Very important to sort X-data prior to partitioning
xo     = xo[sp]
yo     = yo[sp]

partd  = partition_data(xo,len[0],off[0],YY=yo)
partx  = REFORM(partd[*,*,0])
party  = REFORM(partd[*,*,1])
sz     = SIZE(partx,/DIMENSIONS)
dxbin  = sz[0]     ; => width in # elements of X-Axis bins
nxbin  = sz[1]     ; => # of X-Axis bins
;-----------------------------------------------------------------------------------------
; => Find local envelopes
;-----------------------------------------------------------------------------------------
convexhullx = REPLICATE(d,nxbin,500L)      ; => I assume hull cannot be more than 500 pts
convexhully = REPLICATE(d,nxbin,500L)
FOR j=0L, nxbin - 1L DO BEGIN
  xdatp  = REFORM(partx[*,j])
  ydatp  = REFORM(party[*,j])
  good   = WHERE(FINITE(xdatp) AND FINITE(ydatp),gd)
  IF (gd GT 0) THEN BEGIN
    xdatp       = xdatp[good]
    ydatp       = ydatp[good]
    TRIANGULATE,xdatp,ydatp,triangles,hull,TOLERANCE=1d-14*MAX([xdatp,ydatp],/NAN)
    xhull       = [xdatp[hull],xdatp[hull[0]]]
    yhull       = [ydatp[hull],ydatp[hull[0]]]
    nxh         = N_ELEMENTS(xhull) - 1L
    nyh         = N_ELEMENTS(yhull) - 1L
    convexhullx[j,0L:nxh] = xhull
    convexhully[j,0L:nyh] = yhull
    PLOTS,xhull,yhull,COLOR=150
    STOP
  ENDIF
ENDFOR
STOP


;-----------------------------------------------------------------------------------------
; => Smear out data to make the next steps easier
;-----------------------------------------------------------------------------------------
smear = smear_data_plot(xo,yo,NS=2L,/CIRCLE)
x1    = REFORM(smear[*,*,0])
y1    = REFORM(smear[*,*,1])
sz    = SIZE(x1,/DIMENSIONS)
dimn  = sz[0]*sz[1]
x1    = REFORM(x1,dimn)
y1    = REFORM(y1,dimn)
; => Return data to DATA coordinates
xydat = CONVERT_COORD(x1,y1,/DEVICE,/TO_DATA)
x1    = REFORM(xydat[0,*])
y1    = REFORM(xydat[1,*])
sp    = SORT(x1)
xo    = x1[sp]
yo    = y1[sp]
nn    = N_ELEMENTS(xo)


;-----------------------------------------------------------------------------------------
; => Find mean and standard deviations
;-----------------------------------------------------------------------------------------
stdevy = REPLICATE(d,nxbin)       ; => Standard Deviation of Y-data in X[j]-bin
avgyy  = REPLICATE(d,nxbin)       ; => Average value  of Y-data in X[j]-bin
avgxx  = REPLICATE(d,nxbin)       ; => Average value  of X-data in X[j]-bin
FOR j=0L, nxbin - 1L DO BEGIN
  tavgy     = MEAN(party[*,j],/NAN,/DOUBLE)
  tstdy     = STDDEV(party[*,j],/NAN,/DOUBLE)
  ; => Eliminate data points that are > tolerance * 2 * STDEV away
  tolyu     = MAX(party[*,j],/NAN) - (tol[0]*nstdevs[0]*tstdy[0])
  tolyd     = MIN(party[*,j],/NAN) + (tol[0]*nstdevs[0]*tstdy[0])
  test      = (party[*,j] GE tolyu) OR (party[*,j] LE tolyd)
  bad       = WHERE(test,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
  IF (gd GT 0) THEN BEGIN
    avgyy[j]  = MEAN(party[good,j],/NAN,/DOUBLE)
    avgxx[j]  = MEAN(partx[good,j],/NAN,/DOUBLE)
    stdevy[j] = STDDEV(party[good,j],/NAN,/DOUBLE)
  ENDIF
ENDFOR
lows_y  = avgyy - nstdevs[0]*stdevy
high_y  = avgyy + nstdevs[0]*stdevy
;-----------------------------------------------------------------------------------------
; => Smooth partitioned results
;-----------------------------------------------------------------------------------------
smlowsy = fourier_filter(lows_y,4L,/PAD)
smhighy = fourier_filter(high_y,4L,/PAD)




stop


END


;-----------------------------------------------------------------------------------------
