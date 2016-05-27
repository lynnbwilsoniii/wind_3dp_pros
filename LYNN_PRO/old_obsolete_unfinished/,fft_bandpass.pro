;+
;*****************************************************************************************
;
;  FUNCTION : fft_bandpass.pro
;  PURPOSE  :  The program returns the FFT filtered data, separated into low 
;               and high frequency bands (defined by user in program).  The data
;               is then used to calculate new power specturms and new frequency bin
;               values.  
;
;  CALLS:  fft_power_calc.pro
;
;  REQUIRES:  NA
;
;  INPUT:
;             TX   :   Time array (s) associated with input signal
;             EF   :   Input signal(data) which is to be filtered/split into
;                        low/high frequency bands
;
;  EXAMPLES:  flow_high = fft_bandpass(ef,tx,LOWF_CUT=5.)  ; -to separate at 5 kHz
;
;  KEYWORDS:
;             LOWF_CUT  :  Set to a value that is between the low and high
;                           frequency (kHz) limits of your frequency array.  If
;                           you set to 'q', a dummy structure will be returned 
;                           of the same form as the actual structure returned 
;                           when data is input correctly. 
;             BANDPASS  :  Set to a 2-Element array corresponding to a frequency
;                           range (kHz) that tells the program to separate from the
;                           rest of the data.  If this keyword is set, it will return
;                           the data within the frequency range as the 'LOWF_*' tags
;                           and the data outside the frequency range as the 
;                           'HIGHF_*' tags in the structure.
;
;   CHANGED:  1)  Fixed frequency bin separation          [09/09/2008   v1.0.10]
;             2)  Changed auto frequency and time scaling [09/10/2008   v1.0.10]
;             3)  Added keyword bandpass                  [09/11/2008   v1.0.11]
;             4)  Fixed reverse FFT calc for low Freq.    [02/25/2009   v1.0.12]
;
;   CREATED:  08/21/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/25/2009   v1.0.12
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION fft_bandpass,ts,ef,LOWF_CUT=lowf,BANDPASS=bandpass

;*****************************************************************************************
; -Define dummy variables and return structure
;*****************************************************************************************
npoints = SIZE(ts,/n_elements) ; -Number of data points
mvl     = FLTARR(npoints)      ; -dummy array of field for low freq. signal
mvh     = FLTARR(npoints)      ; -dummy array of field for high freq. signal
frl     = DBLARR(npoints/2+1L) ; -" " low frequencies
frh     = DBLARR(npoints/2+1L) ; -" " high frequencies
pvl     = DBLARR(npoints/2+1L) ; -" " powers for low freq.
pvh     = DBLARR(npoints/2+1L) ; -" " powers for high freq.
prl     = DBLARR(npoints/2+1L) ; -" " range of low freq. powers
prh     = DBLARR(npoints/2+1L) ; -" " range of high freq. powers

dum = CREATE_STRUCT('LOWF_SIGNAL',mvl,'HIGHF_SIGNAL',mvh,'LOWF_BINS',frl,    $
                    'HIGHF_BINS',frh,'LOWF_POWER',pvl,'HIGHF_POWER',pvh,     $
                    'MIN_LP',prl,'MIN_HP',prh)
;*****************************************************************************************
; -Define variables for FFT windowing and power spectrum analysis
;*****************************************************************************************
s          = 0L                   ; -start element
e          = 0L                   ; -end element
evlength   = 0d0                  ; -length of event (s)
nsps       = 0d0                  ; -approx. sample rate (Hz)
n_mid      = 0L                   ; -Subscript of most negative freq. in FFT frequencies
freqbins   = DBLARR(npoints/2+1L) ; -frequency bins used for FFT (kHz)
power_temp = DBLARR(npoints/2+1L) ; -power (?)
power      = DBLARR(npoints/2+1L) ; -power (dB)
mv_temp    = FLTARR(npoints)      ; -Electric Field (mV/m)
fft_freq   = DBLARR(npoints)      ; -FFT frequencies (see IDL help)

n_mid      = npoints/2L + 1L
mv_temp    = ef
s          = 0L
e          = npoints - 1L
evlength   = (ts[e] - ts[s])          ; -event length (s)
;*****************************************************************************************
; -Make sure event time is milliseconds
;*****************************************************************************************
evlength = evlength*1d0
tx       = ts*1d0
fscale   = 1d-3   ; -Assumes time in seconds => converts frequencies to kHz

nsps       = ((npoints - 1L)/evlength)*fscale  ; -samples/s
freqbins   = LINDGEN(npoints/2L)*(nsps/(npoints - 1L))
;freqbins   = LINDGEN(npoints/2L)*(nsps/(1e3*(npoints - 1L)))

fft_freq   = LINDGEN(npoints)
fft_freq[n_mid:(npoints - 1L)] = (n_mid - npoints) + DINDGEN(n_mid - 2L)
fft_freq   = fft_freq*(nsps)/npoints
;*****************************************************************************************
; -eliminate the large k-values [or high freq.]
; -effectively acts as a low-pass filter
;*****************************************************************************************
freqbins_low  = 0d0        ; -Frequencies used for plotting FFT (Only low freqs.)
freqbins_high = 0d0        ; -" " (Only high freq.)
fftl          = 0d0        ; -Frequency bins used for FFT indexing low freq.
ffth          = 0d0        ; -Frequency bins used for FFT indexing high freq.
mv_t3         = mv_temp    ; -copy of original
mv_ff3        = FFT(mv_t3) ; -FFT of original
IF KEYWORD_SET(bandpass) THEN BEGIN
  IF (SIZE(bandpass,/TYPE) GT 1L AND SIZE(bandpass,/TYPE) LT 6L AND $
      SIZE(bandpass,/N_ELEMENTS) EQ 2L) THEN BEGIN
    lowf  = bandpass[0]
    highf = bandpass[1]
  ENDIF ELSE BEGIN
    JUMP_BAND:
    print,""
    print,"Incorrect keyword format: [BANDPASS]"
    print,"Enter a low and high frequency (kHz) to "
    print," separate from the rest of the data."
    print,""
    print,"The frequency range is from 0.00 - "+$
           STRTRIM(STRING(FORMAT='(f12.2)',nsps/2d3),2)+" kHz"
    READ,lowf, PROMPT='Please enter the low frequency (kHz) bound : '
    IF (STRTRIM(lowf,2) EQ 'q') THEN RETURN,dum
    READ,highf,PROMPT='Please enter the high frequency (kHz) bound: '
  ENDELSE
  gglow = WHERE(freqbins GE lowf AND freqbins LE highf,ggl,COMPLEMENT=gghigh)
  fftl  = WHERE(ABS(fft_freq) GE lowf AND ABS(fft_freq) LE highf,nfft,COMPLEMENT=ffth)
  IF (ggl EQ 0L AND nfft EQ 0L) THEN BEGIN
    print,"Low frequency is out of range!"
    print,"Please try again..."
    print,"[or type in 'q' at prompt to exit...]"
    GOTO,JUMP_BAND
  ENDIF
ENDIF ELSE BEGIN
  TRUE = 1
  FALSE = 0
  searching = TRUE
  WHILE(searching) DO BEGIN
    IF KEYWORD_SET(lowf) THEN BEGIN
      lowf = lowf
    ENDIF ELSE BEGIN
      JUMP_PROMPT:
      print,""
      print,"The frequency range is from 0.00 - "+$
             STRTRIM(STRING(FORMAT='(f12.2)',nsps/2d3),2)+" kHz"
      READ,lowf,PROMPT='Please enter cut-off frequency (kHz): '
      print,""
    ENDELSE
    IF (STRTRIM(lowf,2) EQ 'q') THEN RETURN,dum
    gglow = WHERE(freqbins LT lowf,ggl,COMPLEMENT=gghigh)
    fftl  = WHERE(ABS(fft_freq) LT lowf,nfft,COMPLEMENT=ffth)
    IF (ggl GT 0L) THEN BEGIN
      searching = FALSE
    ENDIF ELSE BEGIN
      print,"Low frequency is out of range!"
      print,"Please try again..."
      print,"[or type in 'q' at prompt to exit...]"
      searching = TRUE
      GOTO,JUMP_PROMPT
    ENDELSE
  ENDWHILE
ENDELSE

IF (ggl LT npoints/2L) THEN BEGIN
  freqbins_low  = freqbins[gglow]
  freqbins_high = freqbins[gghigh]
ENDIF ELSE BEGIN
  freqbins_low  = freqbins[gglow]
  freqbins_high = 0.0
ENDELSE
;*****************************************************************************************
; -find elements to eliminate from each FFT for bandpass filtering
;  => In IDL, the result of an FFT has the highest frequency (lowest wavelength)
;       bins located in the middle elements of the result.  Thus, to separate them
;       correctly, one must get rid of the elements that are counter to the result
;       desired.  Meaning, if you want only the lowest 2/3 of the frequencies, 
;       set the FFT'd result's middle third of its elements to zero.
;*****************************************************************************************
my_fft_l = 0L  ; -use for test if not redefined in the following IF statement
my_fft_h = 0L

ff3_low = mv_ff3  ; -copy of FFT'd data
ff3_hig = mv_ff3  ; -copy of FFT'd data
IF (nfft GT 0L AND nfft LT npoints) THEN BEGIN
  ff3_low[ffth] = COMPLEX(0d0)
  ff3_hig[fftl] = COMPLEX(0d0)
  mv_high       = REAL_PART(FFT(ff3_hig,1))  ; -Only high freq. comp. of original signal
  mv_low        = REAL_PART(FFT(ff3_low,1))  ; -Only low freq. " "
  my_fft_l      = fft_power_calc(tx,mv_low, READ_WIN=1)
  my_fft_h      = fft_power_calc(tx,mv_high,READ_WIN=1)
ENDIF ELSE BEGIN
  IF (nfft EQ npoints) THEN BEGIN   ; -All low freq data
    ff3_hig[fftl] = COMPLEX(0d0)
    mv_high       = REPLICATE(0d0,npoints)
    mv_low        = REAL_PART(FFT(ff3_low,1))  ; -Only low freq. " "
    my_fft_l      = fft_power_calc(tx,mv_low, READ_WIN=1)
  ENDIF ELSE BEGIN   ; -All high freq data
    ff3_low[ffth] = COMPLEX(0d0)
    mv_low        = REPLICATE(0d0,npoints)
    mv_high       = REAL_PART(FFT(ff3_hig,1))  ; -Only high freq. comp. of original signal
    my_fft_h      = fft_power_calc(tx,mv_high,READ_WIN=1)
  ENDELSE
ENDELSE

ltyp = SIZE(my_fft_l,/TYPE)
htyp = SIZE(my_fft_h,/TYPE)
CASE ltyp OF
  8L   : BEGIN
    power_l   = my_fft_l.POWER_X           ; -FFT power (dB) for the low freq. data
    power_lra = my_fft_l.POWER_RA[0]       ; -Min power (dB) for low f.
  END
  ELSE : BEGIN
    power_l   = REPLICATE(0d0,npoints/2L)
    power_lra = !VALUES.D_NAN
  END
ENDCASE
CASE htyp OF
  8L   : BEGIN
    power_h   = my_fft_h.POWER_X           ; -FFT power (dB) for the high freq. data
    power_hra = my_fft_h.POWER_RA[0]       ; -Min power (dB) for high f.
  END
  ELSE : BEGIN
    power_h   = REPLICATE(0d0,npoints/2L)
    power_hra = !VALUES.D_NAN
  END
ENDCASE
;*****************************************************************************************
; -Define powers to return
;*****************************************************************************************
power_low  = power_l[0:(npoints/2L-1L)]
power_high = power_h[0:(npoints/2L-1L)]
;*****************************************************************************************
; -Return relevant data
;*****************************************************************************************
fft_str = CREATE_STRUCT('LOWF_SIGNAL',mv_low,'HIGHF_SIGNAL',mv_high,         $
                        'LOWF_BINS',freqbins_low,'HIGHF_BINS',freqbins_high, $
                        'LOWF_POWER',power_low,'HIGHF_POWER',power_high,     $
                        'MIN_LP',power_lra,'MIN_HP',power_hra)
RETURN,fft_str
END