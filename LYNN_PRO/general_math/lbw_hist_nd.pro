;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_hist_nd.pro
;  PURPOSE  :   Calculate the histogram of an [N,M]-dimensional input array, where
;                 M is the number of points in each of the N-dimensions.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               XIN   :  [N,M]-Element [numeric] array, i.e., it is N-dimensions and there
;                          are M-elements in each dimension
;               BSZ   :  Scalar or [N]-element [numeric] array defining the bin size
;                          in the Nth dimension.  If a scalar, then all N-dimensions get
;                          the same bin size.
;                          [Default = FLOAT(MAXX - MINX)/NBIN]
;
;  EXAMPLES:    
;               [calling sequence]
;               ndhist = lbw_hist_nd(xin [,bsz] [,MINX=minx] [,MAXX=maxx] [,NBIN=nbin] [,RIND=rind])
;
;               ;;*****************************************************************
;               ;;  See the discussions at:
;               ;;    http://www.idlcoyote.com/code_tips/matchlists.html
;               ;;    http://www.idlcoyote.com/code_tips/slowloops.html
;               ;;    http://www.idlcoyote.com/code_tips/matchlists.html
;               ;;*****************************************************************
;
;  KEYWORDS:    
;               ***  INPUTS  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all of the following have default settings]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               MINX  :  Scalar or [N]-element [numeric] array defining the minimum
;                          value to allow in the Nth dimension.  If a scalar, then all
;                          N-dimensions get the same minimum.
;                          [Default = MIN(XIN)]
;               MAXX  :  Scalar or [N]-element [numeric] array defining the maximum
;                          value to allow in the Nth dimension.  If a scalar, then all
;                          N-dimensions get the same maximum.
;                          [Default = MAX(XIN)]
;               NBIN  :  Scalar or [N]-element [numeric] array defining the number of
;                          bins to use in the Nth dimension of the output histogram.
;                          If a scalar, then all N-dimensions get the same number of bins.
;                          If set and BSZ not set, then BSZ will be defined as:
;                            BSZ = (MAXX - MINX)/NBIN
;                          [Default = LONG((MAXX - MINX)/BSZ + 1L)]
;               ***  OUTPUT  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***  [all the following changed on output]  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               RIND  :  Set to a named variable to return the reverse indices from
;                          the histogram routine.  This will be a 1D array so to find
;                          the index of the, e.g., [i,j,k]-th location of the histogram,
;                          define the following:
;                            gind  =  [i[0] + ni[0]*(j[0] + nj[0]*k[0])]
;                            gloc  = rind[rind[gind[0]]:(rind[gind[0] + 1L] - 1L)]
;                          To find the location in the original array, use ARRAY_INDICES
;
;   CHANGED:  1)  Updated Man. page and added error handling for some of the
;                   calculations in events where the inputs result in absurdly large
;                   numbers of bins etc.
;                                                                   [04/30/2019   v1.0.1]
;
;   NOTES:      
;               See also:
;                 http://www.idlcoyote.com/code_tips/drizzling.html
;
;  REFERENCES:  
;               https://www.harrisgeospatial.com/docs/HISTOGRAM.html
;               https://www.harrisgeospatial.com/docs/hist_2d.html
;               https://www.harrisgeospatial.com/docs/PRODUCT.html
;               https://www.harrisgeospatial.com/docs/ARRAY_EQUAL.html
;               https://www.harrisgeospatial.com/docs/REBIN.html
;
;   ADAPTED FROM: hist_nd.pro    BY: J.D. Smith  Copyright (C) 2001-2010
;   CREATED:  04/26/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/30/2019   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_hist_nd,xin,bsz,MINX=minx,MAXX=maxx,NBIN=nbin,RIND=rind

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
;;  Dummy error messages
no_inpt_msg    = 'User must supply XIN as an [N,P]-element [numeric] array...'
badndim_msg    = 'Incorrect input format:  XIN cannot have more than 8 dimensions...'
badmnmx_msg    = 'MINX value(s) must not exceed MAXX value(s)...'
nobs_nb_msg    = 'Either BSZ or NBIN must be set and numeric in type on input...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
szdx           = SIZE(xin,/DIMENSIONS)
sznx           = SIZE(xin,/N_DIMENSIONS)
IF (sznx[0] NE 2) THEN BEGIN
  ;;  Incorrect inputs --> exit without plotting
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
IF (szdx[0] GT 8) THEN BEGIN
  ;;  Incorrect input format --> exit without plotting
  MESSAGE,badndim_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = ((N_ELEMENTS(bsz) EQ 0) OR (is_a_number(bsz,/NOMSSG) EQ 0)) AND  $
                 ((N_ELEMENTS(nbin) EQ 0) OR (is_a_number(nbin,/NOMSSG) EQ 0))
IF (test[0]) THEN BEGIN
  ;;  Incorrect input format --> exit without plotting
  MESSAGE,nobs_nb_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define default MAX/MIN
def_max        = MAX(xin,DIMENSION=2,MIN=def_min)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check MINX and MAXX
IF ((N_ELEMENTS(minx) EQ 0) OR (is_a_number(minx,/NOMSSG) EQ 0)) THEN minx = def_min
IF ((N_ELEMENTS(maxx) EQ 0) OR (is_a_number(maxx,/NOMSSG) EQ 0)) THEN maxx = def_max
IF (szdx[0] GT 1) THEN BEGIN
  ;;  More than 1D
  IF (N_ELEMENTS(minx) EQ 1) THEN minx = REPLICATE(minx[0],szdx[0])
  IF (N_ELEMENTS(maxx) EQ 1) THEN maxx = REPLICATE(maxx[0],szdx[0])
  IF (N_ELEMENTS(bsz)  EQ 1) THEN bsz  = REPLICATE( bsz[0],szdx[0])
  IF (N_ELEMENTS(nbin) EQ 1) THEN nbin = REPLICATE(nbin[0],szdx[0])
ENDIF ELSE BEGIN
  ;;  Make into arrays
  minx = [minx[0]]
  maxx = [maxx[0]]
ENDELSE
;;  Check that MINX ≤ MAXX
test           = ~ARRAY_EQUAL(minx LE maxx,1b)
IF (test[0]) THEN BEGIN
  ;;  limits are incorrectly set
  MESSAGE,badmnmx_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check BSZ and NBIN
test           = ((N_ELEMENTS(bsz) EQ 0) OR (is_a_number(bsz,/NOMSSG) EQ 0))
IF (test[0]) THEN BEGIN
  ;;  BSZ is not set --> Already checked for NBIN
  nbin           = LONG(nbin)                 ;;  Prevent fractional indices
  bsz            = FLOAT(maxx - minx)/nbin
ENDIF ELSE BEGIN
  ;;  NBIN is not set --> Already checked for BSZ
  nbin           = LONG((maxx - minx)/bsz + 1L)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define parameters
;;----------------------------------------------------------------------------------------
tot_nbins      = PRODUCT(nbin,/PRESERVE_TYPE)
IF (tot_nbins[0] LT 0L) THEN BEGIN
  ;;  Try again using 64-bit integers
  tot_nbins      = PRODUCT(LONG64(nbin))
  IF (tot_nbins[0] LT 0L) THEN BEGIN
    ;;  Still failed --> kick out and inform user of the insanely large number they wished to compute
    tot_nbins    = PRODUCT(DOUBLE(nbin))
    huge_mssg    = 'Total number of bin values is too large at '+STRING(tot_nbins[0],FORMAT='(e12.2)')
    MESSAGE,huge_mssg[0],/INFORMATIONAL,/CONTINUE
    RETURN,0b
  ENDIF ELSE BEGIN
    ;;  Still a very large number --> inform user
    strout       = STRTRIM(STRING(tot_nbins[0],FORMAT='(I)'),2L)
    huge_mssg    = 'WARNING::  You are looking to examine a histogram with a total number of bin values of '+strout[0]
    MESSAGE,huge_mssg[0],/INFORMATIONAL,/CONTINUE
    ;;  Carry on at user's own risk...
  ENDELSE
ENDIF
;;  Initialize scaled indices
ih             = LONG( (xin[(szdx[0] - 1L),*] - minx[(szdx[0] - 1L)])/bsz[(szdx[0] - 1L)] )
;;  Define the scaled indices
FOR i=(szdx[0] - 2L), 0L, -1L DO ih = nbin[i]*TEMPORARY(ih) + LONG( (xin[i,*] - minx[i])/bsz[i] )
;;  Check for out-of-bounds indices
outside        = [~ARRAY_EQUAL(minx LE def_min,1b),~ARRAY_EQUAL(maxx GE def_max,1b)]
IF (~ARRAY_EQUAL(outside,0b)) THEN BEGIN
  ;;  At least one value is out of bounds --> fix
  inside         = 1
  IF (outside[0]) THEN BEGIN
    ;;  Lower bound is bad
    inside = TOTAL((xin GE REBIN(minx,szdx,/SAMPLE)),1L,/PRESERVE_TYPE) EQ szdx[0]
  ENDIF
  IF (outside[1]) THEN BEGIN
    ;;  Upper bound is bad
    ;;    AND=  :  prevents having to put INSIDE on both sides of the = symbol
    inside AND= TOTAL((xin LE REBIN(maxx,szdx,/SAMPLE)),1L,/PRESERVE_TYPE) EQ szdx[0]
  ENDIF
  ;;  Redefine the scaled indices
  ih             = (TEMPORARY(ih) + 1L)*TEMPORARY(inside) - 1L
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define histograms
;;----------------------------------------------------------------------------------------
;;  Construct output array
outarr         = MAKE_ARRAY(TYPE=3,DIMENSION=nbin,/NOZERO)
IF (ARG_PRESENT(rind)) THEN BEGIN
  ;;  User wants to get back reverse indices
  outarr[0]      = HISTOGRAM(ih,MIN=0L,MAX=(tot_nbins[0] - 1L),REVERSE_INDICES=rind)
ENDIF ELSE BEGIN
  ;;  User does not want reverse indices
  outarr[0]      = HISTOGRAM(ih,MIN=0L,MAX=(tot_nbins[0] - 1L))
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,outarr
END


