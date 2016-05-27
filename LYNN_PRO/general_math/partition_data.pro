;+
;*****************************************************************************************
;
;  FUNCTION :   partition_data.pro
;  PURPOSE  :   Partitions data into [LENGTH]-element segments with 
;                 [LENGTH - OFFSET]-element overlaps to create a new array of data
;                 that has been binned along one axis.
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
;               XX      :  N-Element array of x-data to be put into bins
;               LENGTH  :  Scalar defining the # of elements in XX to treat as a
;                            single bin
;               OFFSET  :  Scalar defining the # of elements to shift each time
;                            the program recalculates the distribution in a bin
;
;  EXAMPLES:    
;               yy      = [1,2,3,4,5,6,7,8,9]
;               length  = 4
;               offset  = 2
;               test    = partition_data(yy, length, offset)
;               PRINT, test[*,*,0]
;                      1.0000000       2.0000000       3.0000000       4.0000000
;                      3.0000000       4.0000000       5.0000000       6.0000000
;                      5.0000000       6.0000000       7.0000000       8.0000000
;
;  KEYWORDS:    
;               YY      :  N-Element array of y-data to be put into bins
;
;   CHANGED:  1)  Vectorized a few things and cleaned up a bit      [04/19/2011   v1.0.0]
;
;   NOTES:      
;               1)  Make sure that LENGTH < N, where N = # of elements in YY
;               2)  If only one argument is passed, then the program assumes it to be
;                     an array of data
;
;   CREATED:  04/19/2011
;   CREATED BY:  Jesse Woodroffe
;    LAST MODIFIED:  04/19/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION partition_data,xx,length,offset,YY=yy

;-----------------------------------------------------------------------------------------
; => Define dummy variables and check keywords
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
i              = 0L
divs           = 0L
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
xo     = REFORM(xx)
npts   = N_ELEMENTS(xo)
off    = offset[0]
len    = length[0]

IF ~KEYWORD_SET(yy) THEN yo = REPLICATE(d,npts)  ELSE yo = REFORM(yy)
;-----------------------------------------------------------------------------------------
; => Count the # of divisions
;-----------------------------------------------------------------------------------------
t0     = 1
WHILE(t0) DO BEGIN
  i    += off[0]
  t0    = (i + len[0] - 1L) LE npts
  divs += LONG(t0[0])
ENDWHILE
;-----------------------------------------------------------------------------------------
; => Create the output array
;-----------------------------------------------------------------------------------------
i    = 0L
xdat = DBLARR(len,divs)
ydat = DBLARR(len,divs)
FOR j=0L, divs[0] - 1L DO BEGIN
  dnel      = i
  upel      = i + len[0] - 1L
  xdat[*,j] = xo[dnel:upel]
  ydat[*,j] = yo[dnel:upel]
  i        += off[0]
ENDFOR
;-----------------------------------------------------------------------------------------
; => Return the output array
;-----------------------------------------------------------------------------------------

; => Note:  return value has [NN, MM, LL]-Elements where
;           NN = # of elements in LENGTH
;           MM = # of divisions
;           LL = 2 => 0 = X, 1 = Y
RETURN,[ [[xdat]], [[ydat]] ]
END