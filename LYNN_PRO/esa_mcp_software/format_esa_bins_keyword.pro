;+
;*****************************************************************************************
;
;  FUNCTION :   format_esa_bins_keyword.pro
;  PURPOSE  :   Several of the TDAS/SPEDAS and SSL General routines require an input
;                 BINS keyword.  However, each routine may wish for a different type
;                 of input.  For instance, get_spec.pro requires that BINS have the
;                 same number of elements as dat.NBINS and the elements which should
;                 be used are set to 1.  However, other routines require that BINS
;                 represent only the elements of dat.DATA[j,*] that are to be used.
;                 Thus, format_esa_bins_keyword.pro attempts to format the result
;                 and return all options so that the user may choose which is necssary.
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
;               DAT         :  Scalar [structure] of a THEMIS ESA or Wind/3DP IDL data
;                                structures containing the 3D velocity distribution
;                                function
;
;  EXAMPLES:    
;               ;;..................................
;               ;;  Correct TRUE/FALSE input
;               ;;..................................
;               n_b       = dat[0].NBINS
;               bins      = REPLICATE(1b,n_b[0])
;               bad       = [1,5,8,24]
;               bins[bad] = 0b
;               bstr      = format_esa_bins_keyword(dat,BINS=bins)
;               HELP,bstr,/STRUC
;               ** Structure <2d1f3a8>, 3 tags, length=440, data length=440, refs=1:
;                  BINS_TRUEFALSE  BYTE      Array[88]
;                  BINS_GOOD_INDS  LONG      Array[84]
;                  BINS__BAD_INDS  LONG      Array[4]
;               ;;..................................
;               ;;  Correct indices input
;               ;;..................................
;               good      = [1,2,3,5,8,13,21,34,55]
;               bins      = good
;               bstr      = format_esa_bins_keyword(dat,BINS=bins)
;               HELP,bstr,/STRUC
;               ** Structure <5c3c2c8>, 3 tags, length=440, data length=440, refs=1:
;                  BINS_TRUEFALSE  BYTE      Array[88]
;                  BINS_GOOD_INDS  LONG      Array[9]
;                  BINS__BAD_INDS  LONG      Array[79]
;
;  KEYWORDS:    
;               **********************************
;               ***       DIRECT  INPUTS       ***
;               **********************************
;               BINS        :  [N]-Element [byte] array defining which solid angle bins
;                                should be plotted [i.e., BINS[good] = 1b] and which
;                                bins should not be plotted [i.e., BINS[bad] = 0b].
;                                One can also define bins as an array of indices that
;                                define which solid angle bins to plot.  If this is the
;                                case, then on output, BINS will be redefined to an
;                                array of byte values specifying which bins are TRUE or
;                                FALSE.
;               **********************************
;               ***      INDIRECT OUTPUTS      ***
;               **********************************
;               BINS        :  [N]-Element [byte] array defining which solid angle bins
;                                should be plotted [i.e., BINS[good] = 1b] and which
;                                bins should not be plotted [i.e., BINS[bad] = 0b].
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  In the above KEYWORDS section, the value N is defined by the
;                     structure tag NBINS in the input DAT.  If DAT is not a structure
;                     or does not contain the tag NBINS, the routine will return a zero.
;               2)  The output structure (i.e., RETURN value) contains both the output
;                     version of BINS and the corresponding indices satisfying TRUE and
;                     another tag for the indices satisfying FALSE.
;
;  REFERENCES:  
;               NA
;
;   CREATED:  02/06/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/06/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION format_esa_bins_keyword,dat,BINS=bins

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
mission_logic  = [0b,0b]                ;;  Logic variable used for determining which mission is associated with DAT
;;  Dummy error messages
noinpt_msg     = 'User must supply an array of velocity distribution functions as IDL structures...'
notstr_msg     = 'DAT must be an IDL structure...'
notesa_msg     = 'Input must be a velocity distribution function as an IDL structure with similar format to THEMIS ESA or Wind/3DP...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 1) THEN BEGIN
  MESSAGE,noinpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
IF (SIZE(dat,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,notstr_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
dat_tags       = STRLOWCASE(TAG_NAMES(dat[0]))
good           = WHERE(dat_tags EQ 'nbins',gd)
IF (gd EQ 0) THEN BEGIN
  MESSAGE,notesa_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define parameters relevant to structure format
;;----------------------------------------------------------------------------------------
n_b            = dat[0].NBINS[0]        ;;  # of solid angle bins per structure
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check BINS
n_b            = dat[0].NBINS[0]        ;;  # of solid angle bins per structure
test           = (N_ELEMENTS(bins) EQ 0)
IF (test[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Nothing was set or provided by user
  ;;    --> Use all solid angle bins
  ;;--------------------------------------------------------------------------------------
  bins = REPLICATE(1b,n_b[0])
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  User set or provided BINS --> define parameters
  ;;--------------------------------------------------------------------------------------
  testn = (N_ELEMENTS(bins) NE n_b[0])     ;;  Check if # in BINS matches NBINS
  testx = (MAX(bins,/NAN) GT 1)            ;;  Check if user provided indices or bytes (i.e., 0's and 1's)
  bin0  = REPLICATE(0b,n_b[0])
  ind   = LINDGEN(n_b[0])
  bran  = [0L,n_b[0] - 1L]
  ;;--------------------------------------------------------------------------------------
  ;;  Check format
  ;;--------------------------------------------------------------------------------------
  IF (testn[0]) THEN BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  User provided a subset
    ;;    --> Check if these are indices or TRUE/FALSE bytes
    ;;------------------------------------------------------------------------------------
    IF (testx[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;    --> Assume they provided indices of bins to plot
      ;;          ** Make sure users bin values fall within range of possible values **
      ;;----------------------------------------------------------------------------------
      good  = WHERE(bins GE bran[0] AND bins LE bran[1],gd)
      IF (gd[0] EQ 0) THEN BEGIN
        ;;  Incorrect format --> Plot ALL bins
        bin0[*] = 1b
      ENDIF ELSE BEGIN
        gind       = VALUE_LOCATE(ind,bins[good])
        gind       = (gind > 0) < (n_b[0] - 1L)      ;;  Keep between available range
        bin0[gind] = 1b
      ENDELSE
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  User provided TRUE/FALSE bytes for good bins to plot
      ;;    --> Assume these correspond to the first N_ELEMENTS(BINS) elements of output BINS
      ;;----------------------------------------------------------------------------------
      nb0   = N_ELEMENTS(bins)
      IF (nb0[0] GT n_b[0]) THEN bins = bins[0L:(n_b[0] - 1L)]  ;;  User's input was too long --> shorten
      good  = WHERE(bins GT 0,gd)
      IF (gd[0] GT 0) THEN BEGIN
        ;;  Use good bins
        bin0[good] = 1b
      ENDIF  ;;  ELSE --> Use none
    ENDELSE
    ;;  Redefine BINS for output
    bins       = bin0
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  User provided correct number
    ;;    --> check format (i.e., did user provide indices of bins to plot)
    ;;------------------------------------------------------------------------------------
    IF (testx[0]) THEN BEGIN
      ;;  User provided indices?
      good  = WHERE(bins GE bran[0] AND bins LE bran[1],gd)
      IF (gd[0] EQ 0) THEN BEGIN
        ;;  Incorrect format --> Plot ALL bins
        bin0[*] = 1b
      ENDIF ELSE BEGIN
        gind       = VALUE_LOCATE(ind,bins[good])
        gind       = (gind > 0) < (n_b[0] - 1L)      ;;  Keep between available range
        bin0[gind] = 1b
      ENDELSE
      ;;  Redefine BINS
      bins       = bin0
    ENDIF ELSE BEGIN
      ;;  Good input --> make sure values ≥ 0 and ≤ 1
      bins       = (bins > 0) < 1
;      bad   = WHERE(bins LT 0,bd)
;      IF (bd[0] GT 0) THEN bins[bad] = 0
    ENDELSE
  ENDELSE
ENDELSE
;;  Define TRUE/FALSE indices in BINS
bins           = BYTE(bins)
good           = WHERE(bins,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
;;----------------------------------------------------------------------------------------
;;  Define return structure
;;----------------------------------------------------------------------------------------
;;  Let N = dat[0].NBINS, K = # of elements in BINS satisfying TRUE, and L = # of
;;    elements in BINS satisfying FALSE
;;  BINS_TRUEFALSE  :  [N]-Element [byte] array of TRUE/FALSE values
;;  BINS_GOOD_INDS  :  [K]-Element [integer] array of indices for TRUE values in BINS_TRUEFALSE
;;  BINS__BAD_INDS  :  [L]-Element [integer] array of indices for FALSE values in BINS_TRUEFALSE
out_tags       = ['BINS_TRUEFALSE','BINS_GOOD_INDS','BINS__BAD_INDS']
struct         = CREATE_STRUCT(out_tags,bins,good,bad)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END

