;+
;*****************************************************************************************
;
;  FUNCTION :   make_3dmap.pro
;  PURPOSE  :   Program returns a 2-dimensional array of bin values that reflect
;                 the 3D mapping.
;
;  CALLED BY: 
;               plot3d.pro
;
;  CALLS:
;               str_element.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT      :  A 3DP data structure
;               NX       :  X-Dimension of output array
;               NY       :  Y-" "
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               HIGHEST  :  If set, force the highest bin number to prevail for 
;                             overlapping bins.
;
;  NOTES:
;               1)  If there are any overlapping bins, then the lowest bin number 
;                     will win, unless the HIGHEST keyword is set.
;               2)  theta +/- dtheta should be in the range:  -90 to +90 degrees
;
;   CHANGED:  1)  Davin Larson changed something...       [10/22/1999   v1.0.7]
;             2)  Re-wrote and cleaned up                 [06/22/2009   v1.1.0]
;             3)  Fixed typo                              [09/18/2009   v1.1.1]
;             4)  Fixed typo                              [12/07/2011   v1.1.2]
;
;   CREATED:  02/08/1996
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  12/07/2011   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


FUNCTION make_3dmap, dat,nx,ny, HIGHEST=highest

;-----------------------------------------------------------------------------------------
; => Define default parameters and check input format
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(nx) EQ 0) THEN nx = 64
IF (N_ELEMENTS(ny) EQ 0) THEN ny = 32

str_element,dat,'BINS',bins
IF (N_ELEMENTS(bins) EQ dat.NENERGY*dat.NBINS) THEN BEGIN
  bins = TOTAL(bins,1,/NAN) GT 0
ENDIF
;-----------------------------------------------------------------------------------------
; => Define relevant parameters
;-----------------------------------------------------------------------------------------
phi    = TOTAL(dat.PHI,1,/NAN)/ TOTAL(FINITE(dat.PHI),1)         ; => Avg. (over energies) Phi (deg) 
theta  = TOTAL(dat.THETA,1,/NAN)/ TOTAL(FINITE(dat.THETA),1)     ; => Avg. (over energies) Theta (deg) 
dphi   = TOTAL(dat.DPHI,1,/NAN)/ TOTAL(FINITE(dat.DPHI),1)
dtheta = TOTAL(dat.DTHETA,1,/NAN)/ TOTAL(FINITE(dat.DTHETA),1)
map    = REPLICATE(-1,nx,ny)                                     ; => 3D map to return
nbins  = N_ELEMENTS(phi)                                         ; => # of data bins

p1     = ROUND((phi - dphi/2.)*nx/36e1)
p2     = ROUND((phi + dphi/2.)*nx/36e1) - 1
t1     = ROUND((theta - dtheta/2. + 9e1)*ny/18e1)
t2     = ROUND((theta + dtheta/2. + 9e1)*ny/18e1) - 1
;-----------------------------------------------------------------------------------------
; => Do some error handling to prevent indexing errors in FOR loop below
;-----------------------------------------------------------------------------------------
gtt   = WHERE(t2 GT t1,ctt)
IF (ctt GT 1L) THEN BEGIN
  t1    = t1[gtt]
  t2    = t2[gtt]
  p1    = p1[gtt]
  p2    = p2[gtt]
  ;  LBW III  12/07/2011
  nbins = ctt                                         ; => # of data bins
ENDIF ELSE BEGIN
  MESSAGE, 'No Valid Data',/CONTINUE,/INFORMATIONAL
  RETURN,map
ENDELSE
;-----------------------------------------------------------------------------------------
; => Determine mapping
;-----------------------------------------------------------------------------------------
FOR b1=0L, ctt - 1L DO BEGIN
;  IF KEYWORD_SET(highest) THEN b = b1 ELSE b = gbins - b1 - 1L
;  LBW III  12/07/2011
  IF KEYWORD_SET(highest) THEN b = b1 ELSE b = nbins - b1 - 1L
  IF ((bins[b] GT 0) AND (p2[b] NE -1) AND (p1[b] NE -1)) THEN BEGIN
    np = p2[b] - p1[b] - 1L
    IF (np eq 0) THEN CONTINUE
    p  = INDGEN(np)
    p += p1[b]
    pi = (p + nx) MOD nx   ; => Array of p-indices
    t  = INDGEN(t2[b] - t1[b] + 1L) + t1[b]
    ti = (t + ny) MOD ny   ; => Array of t-indices
    IF (N_ELEMENTS(ti) GE 1) THEN BEGIN
      FOR i=0L, N_ELEMENTS(ti) - 1L DO BEGIN
        map[pi,ti[i]] = b
      ENDFOR
    ENDIF ELSE BEGIN
      MESSAGE, 'Invalid Data',/CONTINUE,/INFORMATIONAL
    ENDELSE
  ENDIF
ENDFOR
RETURN,map
END
