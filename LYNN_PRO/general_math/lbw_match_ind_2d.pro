;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_match_ind_2d.pro
;  PURPOSE  :   Finds the nearest neighbors of two input sets of coordinates in 2D.  The
;                 output will be an [N]-element array of indices of XY2 that match those
;                 in XY1.  The MATCH_DIST will be an [N]-element array of distances
;                 between the matched XY2 coordinates and the XY1 coordinates.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               lbw_hist_nd.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               XY1         :  [N,2]-Element [numeric] array of values in which to search
;                                for matches against XY2
;               XY2         :  [M,2]-Element [numeric] array of values in which to search
;                                for matches against XY1
;               SRCH_RAD    :  Scalar or [2]-element [numeric] array defining the maximum
;                                radius in which to search for a neighboring point.  If
;                                [2]-element then SRCH_RAD[0] is used for XY1 and
;                                SRCH_RAD[1] is used for XY2, else SRCH_RAD[0] is used for
;                                both.
;
;  EXAMPLES:    
;               [calling sequence]
;               ind_xy2 = lbw_match_ind_2d(xy1,xy2,srch_rad [,MATCH_DIST=mndist])
;
;               ;;*****************************************************************
;               ;;  The following was adapted from:
;               ;;    http://www.idlcoyote.com/code_tips/matchlists.html
;               ;;
;               ;;  Match stars in one list to another, within some tolerance.
;               ;;  Pre-bin into a 2D histogram, and use DUAL HISTOGRAM matching to select
;               ;;*****************************************************************
;               n1     = 1000000L                     ;;  number of stars
;               x1     = RANDOMU(sd,n1)               ;;  points to find matches near
;               y1     = RANDOMU(sd,n1)
;               ;;  Define points to search in
;               n2     = n1/2
;               x2     = RANDOMU(sd,n2)
;               y2     = RANDOMU(sd,n2)
;               ;;  Define search radius and bin size
;               max_r  = .0005                        ;;  maximum allowed radius for a match
;               ;;  Find matching locations
;               mnposi = lbw_match_ind_2d([[x1],[y1]],[[x2],[y2]],max_r[0],MATCH_DIST=mndist)
;
;               ;;*****************************************************************
;               ;;  Create a known set of arrays against which to test result
;               ;;*****************************************************************
;               n1     = 100000L                      ;;  number of elements
;               xmax   = 15e2
;               x1     = FINDGEN(n1)                  ;;  points to find matches near
;               y1     = FINDGEN(n1)
;               x1    /= xmax[0]
;               y1    /= xmax[0]
;               ;;  Define points to search in
;               x2     = x1                           ;;  initialize
;               y2     = y1                           ;;  initialize
;               x2[0:10] = SHIFT(x2[0:10],1)
;               y2[0:10] = SHIFT(y2[0:10],1)
;               x2[300:1000] = SHIFT(x2[300:1000],13)
;               y2[300:1000] = SHIFT(y2[300:1000],13)
;               ;;  Define search radius and bin size
;               max_r  = 1e-3                         ;;  maximum allowed radius for a match
;               ;;  Find matching locations
;               mnposi = lbw_match_ind_2d([[x1],[y1]],[[x2],[y2]],max_r[0],MATCH_DIST=mndist)
;               ;;  Check result
;               goodx  = WHERE(mnposi GE 0,gdx)
;               diffx  = x1 - x2[mnposi]
;               diffy  = y1 - y2[mnposi]
;               PRINT,';;  ',minmax(diffx[goodx]) & $
;               PRINT,';;  ',minmax(diffy[goodx])
;               ;;        0.00000      0.00000
;               ;;        0.00000      0.00000
;
;               ;;*****************************************************************
;               ;;  For IDL v8.4 or greater
;               ;;*****************************************************************
;               n1     = 100000L                      ;;  number of elements
;               xmax   = 15e2
;               x1     = FINDGEN(n1)                  ;;  points to find matches near
;               y1     = FINDGEN(n1)
;               x1    /= xmax[0]
;               y1    /= xmax[0]
;               ;;  Define points to search in
;               x2     = x1                           ;;  initialize
;               y2     = y1                           ;;  initialize
;               x2[0:10] = x2[0:10].SHIFT(1)          ;;  Use object IDL_Variable class operations
;               y2[0:10] = y2[0:10].SHIFT(1)
;               x2[300:1000] = x2[300:1000].SHIFT(13)
;               y2[300:1000] = y2[300:1000].SHIFT(13)
;               ;;  Define search radius and bin size
;               max_r  = 1e-3                         ;;  maximum allowed radius for a match
;               ;;  Find matching locations
;               mnposi = lbw_match_ind_2d([[x1],[y1]],[[x2],[y2]],max_r[0],MATCH_DIST=mndist)
;               ;;  Check result
;               goodx  = WHERE(mnposi GE 0,gdx)
;               diffx  = x1 - x2[mnposi]
;               diffy  = y1 - y2[mnposi]
;               PRINT,';;  ',minmax(diffx[goodx]) & $
;               PRINT,';;  ',minmax(diffy[goodx])
;               ;;        0.00000      0.00000
;               ;;        0.00000      0.00000
;
;  KEYWORDS:    
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               MATCH_DIST  :  Set to a named variable to return the distances between
;                                any matching coordinates and the coordinate of XY1
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               See also:
;                 http://www.idlcoyote.com/code_tips/drizzling.html
;                 http://www.idlcoyote.com/code_tips/slowloops.html
;                 http://www.idlcoyote.com/code_tips/matchlists.html
;
;  REFERENCES:  
;               https://www.harrisgeospatial.com/docs/HISTOGRAM.html
;               https://www.harrisgeospatial.com/docs/hist_2d.html
;               https://www.harrisgeospatial.com/docs/PRODUCT.html
;               https://www.harrisgeospatial.com/docs/ARRAY_EQUAL.html
;               https://www.harrisgeospatial.com/docs/REBIN.html
;
;   ADAPTED FROM: match_2d.pro    BY: J.D. Smith  Copyright (C) 2007, 2009
;   CREATED:  04/30/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/30/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_match_ind_2d,xy1,xy2,srch_rad,MATCH_DIST=mndist

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
;;  Dummy error messages
no_inpt_msg    = 'User must supply XY1 AND XY2 as [N,2]- and [M,2]-element [numeric] arrays...'
badinsr_msg    = 'User must supply SRCH_RAD as a scalar or [2]-element [numeric] array...'
nobs_nb_msg    = 'Incorrect input format:  XY1, XY2, and SRCH_RAD must ALL be set and numeric in type on input...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
szdx1          = SIZE(xy1,/DIMENSIONS)
sznx1          = SIZE(xy1,/N_DIMENSIONS)
szdx2          = SIZE(xy2,/DIMENSIONS)
sznx2          = SIZE(xy2,/N_DIMENSIONS)
szdsr          = SIZE(srch_rad,/DIMENSIONS)
sznsr          = SIZE(srch_rad,/N_DIMENSIONS)
IF (sznx1[0] NE 2 OR sznx2[0] NE 2) THEN BEGIN
  ;;  Incorrect inputs --> exit without plotting
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF ELSE BEGIN
  IF (szdx1[1] NE 2 OR szdx2[1] NE 2) THEN BEGIN
    MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF
ENDELSE
IF ((N_ELEMENTS(srch_rad) EQ 0) OR (sznsr[0] GT 1) OR (szdsr[0] NE 0 AND szdsr[0] NE 2)) THEN BEGIN
  ;;  Incorrect inputs --> exit without plotting
  MESSAGE,badinsr_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_number(xy1[0],/NOMSSG) EQ 0) OR (is_a_number(xy2[0],/NOMSSG) EQ 0) OR  $
                 (is_a_number(srch_rad[0],/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Incorrect input format --> exit without plotting
  MESSAGE,nobs_nb_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define parameters
;;----------------------------------------------------------------------------------------
x1             = REFORM(xy1[*,0])
y1             = REFORM(xy1[*,1])
x2             = REFORM(xy2[*,0])
y2             = REFORM(xy2[*,1])
;;  Define smallest bin size allowed
bsz            = 2*srch_rad
;;  Define default MAX/MIN
def_maxxy2     = [MAX(x2,MIN=def_minx2),MAX(y2,MIN=def_miny2)]
def_minxy2     = [def_minx2[0],def_miny2[0]]
;;  Expand search range
def_maxxy2    += (1.5*bsz)
def_minxy2    -= (1.5*bsz)
;;  Compute ND histogram
hnd            = lbw_hist_nd([1#x2,1#y2],bsz,MINX=def_minxy2,MAXX=def_maxxy2,RIND=rind)
IF (SIZE(hnd,/TYPE) LE 1) THEN BEGIN
  ;;  Something failed --> Return dummy arrays to user
  n1             = N_ELEMENTS(x1)
  mnposi         = MAKE_ARRAY(n1[0],VALUE=-1L)
  IF ARG_PRESENT(mndist) THEN mndist = FLTARR(n1[0],/NOZERO)
  RETURN,mnposi
ENDIF
dimh           = SIZE(hnd,/DIMENSIONS)
;;----------------------------------------------------------------------------------------
;;  Define bin location of XY1 in the XY2 grid
;;----------------------------------------------------------------------------------------
xoff           = 0e0 > ((x1 - def_minxy2[0])/bsz[0]) < (dimh[0] - 1e0)
yoff           = 0e0 > ((y1 - def_minxy2[1])/((N_ELEMENTS(bsz) GT 1)?bsz[1]:bsz)) < (dimh[1] - 1e0)
x1bin          = FLOOR(xoff)
y1bin          = FLOOR(yoff)
;;  Define the 1D bin location of index
bin1d          = x1bin + dimh[0]*y1bin
;;  Add left/right and up/down bins to offsets
xoff           = 1L - 2L*((xoff - x1bin) LT 5e-1)
yoff           = 1L - 2L*((yoff - y1bin) LT 5e-1)
;;  Define parameters of position and distance
n1             = N_ELEMENTS(x1)
mnposi         = MAKE_ARRAY(n1[0],VALUE=-1L)
mndist         = FLTARR(n1[0],/NOZERO)
radsq          = TOTAL(srch_rad^2d0)/2d0
;; Loop over 4 bins in the correct quadrant direction
FOR i=0L, 1L DO BEGIN
  FOR j=0L, 1L DO BEGIN
    ;;  Define current bin offset
    b0 = 0L > (bin1d + i[0]*xoff + j[0]*yoff*dimh[0]) < (dimh[0]*dimh[1] - 1L)
    ;; Dual histogram method, loop by repeat count in bins
    h2 = HISTOGRAM(hnd[b0],OMIN=om,REVERSE_INDICES=rind2)
    ;; Process all bins with the same number of repeats >= 1
    FOR k=LONG(om[0] EQ 0L), N_ELEMENTS(h2) - 1L DO BEGIN
      IF (h2[k] EQ 0) THEN CONTINUE
      ;;  Define the points with k+1 repeats in bin with (k + om) search points
      these_bins = rind2[rind2[k]:(rind2[(k + 1L)] - 1L)]
      IF ((k[0] + om[0]) EQ 1) THEN BEGIN
        ;;  single point (n)
        these_points = rind[rind[b0[these_bins]]]
      ENDIF ELSE BEGIN
        ;;  range over (k + om) points, (n x (k + om))
        target       = [h2[k],(k[0] + om[0])]
        these_points = rind[rind[REBIN(b0[these_bins],target,/SAMPLE)] + $
                                 REBIN(LINDGEN(1,(k[0] + om[0])),target,/SAMPLE)]
        these_bins   = REBIN(TEMPORARY(these_bins),target,/SAMPLE)
      ENDELSE
      ;;  Define the current distribution of points with closest point in this quadrant
      cdist = (x2[these_points] - x1[these_bins])^2e0 + $
              (y2[these_points] - y1[these_bins])^2e0
      IF ((k[0] + om[0]) EQ 1) THEN BEGIN
        ;;  multiple point in bin: find closest
        cdist        = MIN(cdist,p)
;        cdist        = MIN(cdist,DIMENSION=2,p)
        ;;  index of closest point in bin
        these_points = these_points[p]
        ;;  original bin list
        these_bins   = rind2[rind2[k]:(rind2[(k + 1L)] - 1L)]
      ENDIF
      ;;  Check for already defined minimum at this location
      set = WHERE(mnposi[these_bins] GE 0,nset,COMPLEMENT=unset,NCOMPLEMENT=nunset)
      IF (nset[0] GT 0) THEN BEGIN
        ;;  Only update if there are closer points
        closer = WHERE(cdist[set] LT mndist[these_bins[set]],cnt)
        IF (cnt[0] GT 0) THEN BEGIN
          set                     = set[closer]
          mnposi[these_bins[set]] = these_points[set]
          mndist[these_bins[set]] = cdist[set]
        ENDIF
      ENDIF
      ;;  Nothing set --> it's closest by default
      IF (nunset[0] GT 0) THEN BEGIN
        ;;  Check it's location against radius
        wh = WHERE(cdist[unset] LT radsq[0],cnt)
        IF (cnt[0] GT 0) THEN BEGIN
          unset                     = unset[wh]
          mnposi[these_bins[unset]] = these_points[unset]
          mndist[these_bins[unset]] = cdist[unset]
        ENDIF
      ENDIF
    ENDFOR
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define outputs
;;----------------------------------------------------------------------------------------
IF ARG_PRESENT(mndist) THEN mndist = SQRT(mndist)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,mnposi
END


