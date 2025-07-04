;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_bandpass_filter_data.pro
;  PURPOSE  :   Performs a bandpass filter on a N-dimensional array of data, where the
;                 user specifies the dimension over which to filter.
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
;               DAT    :  [N,K,P,...,W]-Element [numeric] array defining the data for which
;                           to apply the bandpass filter
;               SR     :  Scalar [numeric] defining the sample rate [(unit time)^(-1)]
;               LF     :  Scalar [numeric] defining the low frequency cutoff [(unit time)^(-1)]
;                          [Default = 0]
;               HF     :  Scalar [numeric] defining the high frequency cutoff [(unit time)^(-1)]
;                          [Default = SR[0]/2]
;
;  EXAMPLES:    
;               [calling sequence]
;               filt = lbw_bandpass_filter_data(dat,sr [,lf] [,hf] [,DIMENSION=dimension])
;
;  KEYWORDS:    
;               DIMENSION  :  Scalar [integer] defining the dimension over which to
;                               filter the data
;                               [Default = 1 (1 corresponds to element 0)]
;
;   CHANGED:  1)  Continued writing routine
;                                                                   [11/09/2022   v1.0.0]
;             2)  Finished writing routine (at least first draft in working order)
;                                                                   [11/09/2022   v1.0.0]
;
;   NOTES:      
;               1)  This routine performs a standard box Fourier bandpass filter
;               2)  The number of dimensions in DAT should not exceed 5
;                     (otherwise it just gets too messy)
;               3)  ***  Still testing this on arrays with >2 dimensions  ***
;
;  REFERENCES:  
;               1)  Harris, F.J. (1978), "On the Use of Windows for Harmonic Analysis
;                      with the Discrete Fourier Transform," Proc. IEEE Vol. 66,
;                      No. 1, pp. 51-83
;               2)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               3)  Torrence, C. and G.P. Compo "A Practical Guide to Wavelet Analysis,"
;                      Bull. Amer. Meteor. Soc. 79, pp. 61-78, (1998).
;               4)  Donnelly, D. and B. Rust "The Fast Fourier Transform for
;                      Experimentalists, Part I:  Concepts," Comput. Sci. & Eng. 7(2),
;                      pp. 80-88, (2005).
;               5)  Donnelly, D. and B. Rust "The Fast Fourier Transform for
;                      Experimentalists, Part II:  Convolutions," Comput. Sci.
;                      & Eng. 7(4), pp. 92-95, (2005).
;               6)  Rust, B. and D. Donnelly "The Fast Fourier Transform for
;                      Experimentalists, Part III:  Classical Spectral Analysis,"
;                      Comput. Sci. & Eng. 7(5), pp. 74-78, (2005).
;               7)  Rust, B. and D. Donnelly "The Fast Fourier Transform for
;                      Experimentalists, Part IV:  Autoregressive Spectral Analysis,"
;                      Comput. Sci. & Eng. 7(6), pp. 85-90, (2005).
;               8)  Donnelly, D. "The Fast Fourier Transform for Experimentalists,
;                      Part V:  Filters," Comput. Sci. & Eng. 8(1), pp. 92-95, (2006).
;
;   CREATED:  11/08/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/09/2022   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_bandpass_filter_data,dat,srt,lfr,hfr,DIMENSION=dimension

;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
def_lf         = 0e0
def_hf         = 0e0
is1d           = 0b
;;  Dummy error messages
no_inpt_msg    = 'User must supply an N-dimensional [numeric] array of data and a scalar sample rate [at minimum]...'
badvfor_msg    = 'Incorrect input format:  DAT must be a N-dimensional [numeric] array of data'
baddfor_mssg   = 'Incorrect input format:  DAT must not have the number of dimensions exceeding 5...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(dat,/NOMSSG) EQ 0) OR  $
                 (is_a_number(srt,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
sznd           = SIZE(dat,/N_DIMENSIONS)
szdd           = SIZE(dat,/DIMENSIONS)
IF (sznd[0] EQ 1) THEN BEGIN
  IF (szdd[0] LT 10) THEN BEGIN
    ;;  Not enough points --> bad input
     MESSAGE,badvfor_msg[0],/INFORMATIONAL,/CONTINUE
     RETURN,0b
  ENDIF ELSE BEGIN
    ;;  Seem to be enough points --> reform the array
    data           = REFORM(dat,1L,szdd[0])
    is1d           = 1b
    szdd           = SIZE(data,/DIMENSIONS)
  ENDELSE
ENDIF ELSE BEGIN
  IF (sznd[0] GT 5) THEN BEGIN
    ;;  Too many dimensions
     MESSAGE,baddfor_mssg[0],/INFORMATIONAL,/CONTINUE
     RETURN,0b
  ENDIF ELSE BEGIN
    ;;  Data is formatted properly
    data           = dat
  ENDELSE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define relevant/necessary parameters
;;----------------------------------------------------------------------------------------
sr             = 1d0*srt[0]             ;;  input sample rate [(unit time)^(-1)]
def_hf         = sr[0]/2d0              ;;  Default high frequency limit = Nyquist frequency
;;  Define defaults
IF (N_PARAMS() LT 4) THEN BEGIN
  ;;  User supplied less than 4 parameters
  IF (N_PARAMS() LT 3) THEN BEGIN
    ;;  User only supplied DAT and SR --> Define LF and/or HF
    lf             = def_lf[0]
    hf             = def_hf[0]
  ENDIF ELSE BEGIN
    ;;  User supplied DAT, SR, and LF --> Define HF
    IF (is_a_number(lfr,/NOMSSG) EQ 0) THEN lf = def_lf[0] ELSE lf = lfr[0]
    hf             = def_hf[0]
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Make sure LF and HF are numeric
  IF (is_a_number(lfr,/NOMSSG) EQ 0) THEN lf = def_lf[0] ELSE lf = lfr[0]
  IF (is_a_number(hfr,/NOMSSG) EQ 0) THEN hf = def_hf[0] ELSE hf = hfr[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DIMENSION
IF (is_a_number(dimension,/NOMSSG) EQ 0) THEN BEGIN
  dim            = 1L
ENDIF ELSE BEGIN
  dim            = (LONG(dimension[0]) > 1L) < sznd[0]
ENDELSE
;;  Define the number of points to filter
IF (is1d[0]) THEN fdim = 1L ELSE fdim = dim[0] - 1L
no             = szdd[fdim[0]]
;;----------------------------------------------------------------------------------------
;;  Replace NaNs with zeros so FFT will return finite values
;;----------------------------------------------------------------------------------------
bbx            = WHERE(FINITE(data) EQ 0,bx,COMPLEMENT=ggx)
IF (bx[0] GT 0L) THEN data[bbx] = 0d0
;;----------------------------------------------------------------------------------------
;;  Pad data with zeros to change # of elements --> 2^m  {m = integer}
;;----------------------------------------------------------------------------------------
;;  Define current exponent
expof2         = ALOG(1d0*no[0])/ALOG(2d0)
true           = FLOAT(ABS(LONG(expof2[0]) - expof2[0])) LE 1d-7
IF (~true[0]) THEN BEGIN
  ;;  Not an integer power of 2 --> define the number of elements to pad
  npowof2        = 2L^CEIL(expof2[0])
  nextra         = npowof2[0] - no[0]
  newdim         = szdd
  dumdim         = szdd
  newdim[fdim[0]] += nextra[0]
  dumdim[fdim[0]]  = nextra[0]
  dumb           = MAKE_ARRAY(dumdim,VALUE=!VALUES.D_NAN)
  padd           = [data,dumb]
  ;;  Use the following to track which elements to keep after inverse FFT below
  badp           = WHERE(FINITE(padd) EQ 0,bdp,COMPLEMENT=goodp,NCOMPLEMENT=gdp)
  IF (bdp[0] GT 0) THEN padd[badp] = 0d0
  pad_on         = 1b
ENDIF ELSE BEGIN
  ;;  Already an integer power of 2 --> no need to do anything
  npowof2        = 2L^LONG(expof2[0])
  newdim         = szdd
  padd           = data
  pad_on         = 0b
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define FFT frequencies
;;----------------------------------------------------------------------------------------
IF (fdim[0] NE 0) THEN BEGIN
  szind          = LINDGEN(N_ELEMENTS(newdim))
  badsz          = WHERE(szind EQ fdim[0],bdsz,COMPLEMENT=goodsz,NCOMPLEMENT=gdsz)
  trpin          = [fdim[0],szind[goodsz]]
  trpdim         = newdim[trpin]
  sp             = SORT(trpin)
  fftnd          = MAKE_ARRAY(trpdim,VALUE=!VALUES.D_NAN)
ENDIF ELSE BEGIN
  ;;  No need to change anything
  trpdim         = newdim
  fftnd          = MAKE_ARRAY(trpdim,VALUE=!VALUES.D_NAN)
ENDELSE
nd             = newdim[fdim[0]]
n_m            = nd[0]/2L + 1L               ;;  midpoint element (i.e., where frequencies go negative in FFT)
frn            = nd[0] - n_m[0]
frel           = LINDGEN(frn) + n_m[0]       ;;  Elements for negative frequencies
fft_freq       = LINDGEN(nd)
fft_freq[frel] = (n_m[0] - nd[0]) + DINDGEN(n_m[0] - 2L)
fft_freq       = fft_freq*(sr[0]/nd[0])
CASE sznd[0] OF
  1     :  fftnd = fft_freq
  2     :  fftnd = (fft_freq # REPLICATE(1d0,trpdim[1]))
  3     :  BEGIN
    ;;  3D Input
    FOR k=0L, trpdim[2] - 1L DO BEGIN
      fftnd[*,*,k] = (fft_freq # REPLICATE(1d0,trpdim[1]))
    ENDFOR
  END
  4     :  BEGIN
    ;;  4D Input
    FOR k=0L, trpdim[2] - 1L DO BEGIN
      FOR j=0L, trpdim[3] - 1L DO BEGIN
        fftnd[*,*,k,j] = (fft_freq # REPLICATE(1d0,trpdim[1]))
      ENDFOR
    ENDFOR
  END
  5     :  BEGIN
    ;;  5D Input
    FOR k=0L, trpdim[2] - 1L DO BEGIN
      FOR j=0L, trpdim[3] - 1L DO BEGIN
        FOR i=0L, trpdim[4] - 1L DO BEGIN
          fftnd[*,*,k,j,i] = (fft_freq # REPLICATE(1d0,trpdim[1]))
        ENDFOR
      ENDFOR
    ENDFOR
  END
  ELSE  :  STOP          ;;  Something is wrong --> debug!
ENDCASE
IF (fdim[0] NE 0) THEN fftnd = TRANSPOSE(fftnd,sp)     ;;  If necessary, return to original array dimension order
;;----------------------------------------------------------------------------------------
;;  Determine relevant elements of FFT arrays
;;----------------------------------------------------------------------------------------
midf1          = WHERE((ABS(fftnd) GE lf[0]) AND (ABS(fftnd) LE hf[0]),mf1,COMPLEMENT=other,NCOMPLEMENT=nbad)
;;  Check if filter even needs to be done
IF (nbad[0] EQ 0) THEN RETURN,dat     ;;  return input array without doing anything
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate FFT
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tempx          = FFT(padd,DIMENSION=dim[0],/DOUBLE)
;;  Create dummy copy of FFTs
templx         = tempx
;;----------------------------------------------------------------------------------------
;;  Get rid of unwanted frequencies
;;----------------------------------------------------------------------------------------
IF (nbad[0] GT 0) THEN templx[other] = DCOMPLEX(0d0)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate Inverse FFT
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
rplx           = REAL_PART(FFT(templx,/INVERSE,DIMENSION=dim[0],/DOUBLE))
;;----------------------------------------------------------------------------------------
;;  Keep only useful data [i.e. get rid of the zero-padded elements]
;;----------------------------------------------------------------------------------------
IF (pad_on[0]) THEN BEGIN
  ;;  Remove zero-padded data
  lower          = 0L
  upper          = (no[0] - 1L)
  filter         = REFORM(rplx[goodp],szdd)
ENDIF ELSE BEGIN
  ;;  No need to remove any zero padding
  filter         = rplx
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Return NaNs to arrays if they were present on input
;;----------------------------------------------------------------------------------------
IF (bx[0] GT 0L) THEN filter[bbx] = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,filter
END













