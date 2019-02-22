;+
;*****************************************************************************************
;
;  FUNCTION :   calc_poynting_flux_freq.pro
;  PURPOSE  :   Calculates the Poynting flux [in frequency space] from electric and
;                 magnetic field inputs.  The output result is the summed |S| over
;                 the FFT frequency bins multiplied by the bandwidth.  Therefore, the
;                 output flux is in µW m^(-2).
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_struct_format_test.pro
;               sample_rate.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               EFW           :  IDL TPLOT structure containing the E-Field data with
;                                  the format:
;                                  X  :  [N]-Element array of Unix times
;                                  Y  :  [N,3]-Element array of E-field vectors (mV/m)
;               SCW           :  IDL TPLOT structure containing the B-Field data with
;                                  the format:
;                                  X  :  [N]-Element array of Unix times
;                                  Y  :  [N,3]-Element array of B-field vectors (nT)
;                          *******************************************
;                          ** timestamps for the SCW must match EFW **
;                          *******************************************
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               FLOW          :  Scalar [float/double] defining the low frequency [Hz]
;                                  cutoff to use for the Poynting flux analysis
;                                  [Default = 0.0]
;               NFFT          :  Scalar [long] defining the # of frequency bins in each
;                                  FFT
;                                  [Default = 128]
;               NSHFT         :  Scalar [long] defining the # of points to shift between
;                                  each FFT
;                                  [Default = 32]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  12/17/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/17/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_poynting_flux_freq,efw,scw,FLOW=flow,NFFT=nfft,NSHFT=nshft

;;----------------------------------------------------------------------------------------
;; => Define dummy variables
;;----------------------------------------------------------------------------------------
f           = !VALUES.F_NAN
d           = !VALUES.D_NAN
muo         = (4d0*!DPI)*1d-7            ;; Permeability of free space (N/A^2 or H/m)
sfac        = 1d-3*1d-9*1d6/muo[0]       ;; mV->V, nT->T, W->µW, divide by µ_o
ph_yra      = [0d0,36d1]

; => Dummy error messages
badt___msg  = 'Timestamps must match for both inputs!'
badtsp_msg  = 'Bad timestamp inputs...'
badtpn_msg  = 'TPLOT structures are incorrectly formatted...'
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,-1

teste       = tplot_struct_format_test(efw,/YVECT) EQ 0
testb       = tplot_struct_format_test(scw,/YVECT) EQ 0
test        = teste OR testb
IF (test) THEN BEGIN
  ;; bad input
  MESSAGE,badtpn_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,-1
ENDIF
;; Make sure timestamps overlap
diff        = efw.X - scw.X
test        = (TOTAL(diff,/NAN) NE 0) OR (N_ELEMENTS(efw.X) NE N_ELEMENTS(scw.X))
IF (test) THEN BEGIN
  ;; bad input
  MESSAGE,badt___msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,-1
ENDIF
;;----------------------------------------------------------------------------------------
;; => Check keyword inputs
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(flow) NE 1) THEN  fcut  = 0d0  ELSE fcut  = DOUBLE(flow[0])
IF (N_ELEMENTS(nfft) NE 1) THEN  nfft  = 128L ELSE nfft  = LONG(nfft[0])
IF (N_ELEMENTS(nshft) NE 1) THEN nshft = 32L  ELSE nshft = LONG(nshft[0])
;;----------------------------------------------------------------------------------------
;; => Define some parameters
;;----------------------------------------------------------------------------------------
flow        = fcut[0]
stride      = nshft[0]

tb          = scw.X
evecs       = efw.Y                        ;; [N,3]-Element array of E-fields [mV/m]
bvecs       = scw.Y                        ;; [N,3]-Element array of B-fields [nT]
nefi        = N_ELEMENTS(tb)               ;; # of vectors
;;----------------------------------------------------------------------------------------
;; => Calculate Sample Rate [sps]
;;----------------------------------------------------------------------------------------
smratb      = DOUBLE(ROUND(sample_rate(tb,GAP_THRESH=2d0,/AVE)))
;;----------------------------------------------------------------------------------------
;; => Define some dummy parameters
;;----------------------------------------------------------------------------------------
nefi_a      = nefi - 1L                    ;; # of vectors in each interval
n_dft       = nefi_a - nfft[0]             ;; # of timestamps per interval
;;  Create a Hanning window
win         = HANNING(nfft[0],/DOUBLE)*2d0
;;  Define the bandwidth [Hz] of each FFT frequency bin
bw          = smratb[0]/nfft[0]
freq        = DINDGEN(nfft[0]/2d0)*bw[0]   ;; FFT frequency bin values [Hz]
ind_sf      = WHERE(freq GE fcut[0],gdsf)
;;----------------------------------------------------------------------------------------
;; => Convert to Frequency Domain
;;----------------------------------------------------------------------------------------
;; Define # of timestamps for FFTs
n_ts        = nefi[0]/stride[0] + 1L
;; Define dummy arrays for the complex FFTs of the two fields
efw_fft     = DCOMPLEXARR(n_ts[0],nfft[0],3L)  ;;  [K,W,3]-Element array
scw_fft     = DCOMPLEXARR(n_ts[0],nfft[0],3L)
;; Dummy timestamps
tt          = DBLARR(n_ts[0])
i           = 0L
FOR j=0L, n_dft[0] - 1L, stride[0] DO BEGIN
  upj       = j + nfft[0] - 1L
  FOR k=0L, 2L DO efw_fft[i,*,k] = FFT(evecs[j[0]:upj[0],k]*win)
  FOR k=0L, 2L DO scw_fft[i,*,k] = FFT(bvecs[j[0]:upj[0],k]*win)
  ;; increment i
  i++
ENDFOR
;; Keep only relevant values
ind         = (i[0] - 1L)
n_ts        = ind[0]
;; Remove extra spectra on end
efw_fft     = efw_fft[0L:(ind - 1L),*,*]
scw_fft     = scw_fft[0L:(ind - 1L),*,*]
;; Define timestamps
tt          = tb[0] + (DINDGEN(ind[0])*stride[0] + nfft[0]/2d0)/smratb[0]
;;----------------------------------------------------------------------------------------
;; => Calculate Poynting Flux [Frequency Domain]
;;----------------------------------------------------------------------------------------
conj_bfft   = CONJ(scw_fft)  ;; Complex conjugate of the FFT of B-field
sx_f        = DOUBLE(efw_fft[*,*,1]*CONJ(scw_fft[*,*,2]) - efw_fft[*,*,2]*CONJ(scw_fft[*,*,1]))*sfac[0]/2d0
sy_f        = DOUBLE(efw_fft[*,*,2]*CONJ(scw_fft[*,*,0]) - efw_fft[*,*,0]*CONJ(scw_fft[*,*,2]))*sfac[0]/2d0
sz_f        = DOUBLE(efw_fft[*,*,0]*CONJ(scw_fft[*,*,1]) - efw_fft[*,*,1]*CONJ(scw_fft[*,*,0]))*sfac[0]/2d0
s_f         = [[[sx_f]],[[sy_f]],[[sz_f]]]  ;;  [K,W,3]-Element array
;;  S [µW m^(-2)]
IF (gdsf GT 0) THEN BEGIN
  power_sf    = SQRT(TOTAL(TOTAL(s_f[*,ind_sf,*]^2,3L,/NAN),2L))*smratb[0]/nfft[0]  ;;  [N]-Element array
ENDIF ELSE power_sf = REPLICATE(!VALUES.D_NAN,N_ELEMENTS(tt))
;;  remove negative or zero values from POWER_SF
bad         = WHERE(power_sf LE 0,bd)
IF (bd GT 0) THEN power_sf[bad] = !VALUES.D_NAN

;;  Create return structure
poyn_flux   = {X:tt,Y:power_sf}
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,poyn_flux
END
