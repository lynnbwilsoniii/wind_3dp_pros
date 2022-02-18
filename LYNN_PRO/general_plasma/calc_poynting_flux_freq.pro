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
;  INCLUDES:
;               NA
;
;  CALLS:
;               tplot_struct_format_test.pro
;               t_get_struc_unix.pro
;               sample_rate.pro
;               is_a_number.pro
;               delete_variable.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               EFW           :  IDL TPLOT structure containing the E-Field data with
;                                  the format:
;                                  X  :  [N]-Element array of Unix times
;                                  Y  :  [N,3]-Element array of E-field vectors [mV/m]
;               SCW           :  IDL TPLOT structure containing the B-Field data with
;                                  the format:
;                                  X  :  [N]-Element array of Unix times
;                                  Y  :  [N,3]-Element array of B-field vectors [nT]
;                          *******************************************
;                          ** timestamps for the SCW must match EFW **
;                          *******************************************
;
;  EXAMPLES:    
;               [calling sequence]
;               pflux = calc_poynting_flux_freq(efw,scw [,FLOW=flow] [,FHIGH=fhigh] $
;                                                       [,NFFT=nfft] [,NSHFT=nshft])
;
;  KEYWORDS:    
;               FLOW          :  Scalar [float/double] defining the low frequency [Hz]
;                                  cutoff to use for the Poynting flux analysis
;                                  [Default = 0.0]
;               FHIGH         :  Scalar [float/double] defining the high frequency [Hz]
;                                  cutoff to use for the Poynting flux analysis
;                                  [Default = sample rate of input]
;               NFFT          :  Scalar [long] defining twice the # of frequency bins in
;                                  each FFT of the sliding FFT output
;                                  [Default = 128]
;               NSHFT         :  Scalar [long] defining the # of points to shift between
;                                  each FFT
;                                  [Default = 32]
;
;   CHANGED:  1)  Finished writing routine
;                                                                   [02/10/2022   v1.0.0]
;
;   NOTES:      
;               1)  If [TIME] = seconds, then the output frequencies will be in Hz.
;                     Technically, any unit of time on input is okay so long as the
;                     user stays consistent and is aware that the routine does not
;                     know the units of TIME or DATA.
;               2)  Make sure the units of FLOW and FHIGH are consistent with the
;                     inverse units of TIME.
;
;  REFERENCES:  
;               1)  Cully, C.M., R.E. Ergun, K. Stevens, A. Nammari, and J. Westfall
;                      (2008), "The THEMIS Digital Fields Board," Space Sci. Rev.
;                      Vol. 141, pp. 343-355.
;               2)  Bonnell, J.W., F.S. Mozer, G.T. Delory, A.J. Hull, R.E. Ergun,
;                      C.M. Cully, V. Angelopoulos, and P.R. Harvey (2008), "The
;                      Electric Field Instrument (EFI) for THEMIS," Space Sci. Rev.
;                      Vol. 141, pp. 303-341.
;               3)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               4)  Harris, F.J. "On the Use of Windows for Harmonic Analysis with the
;                      Discrete Fourier Transform," Proc. IEEE Vol. 66, No. 1,
;                      pp. 51-83, (1978).
;               5)  Gurnett, D.A. and A. Bhattacharjee (2005), "Introduction to Plasma
;                      Physics:  With Space and Laboratory Applications," Cambridge
;                      University Press, Cambridge, UK, ISBN:0-521-36483-3.
;               6)  Stix, T.H. (1962), "The Theory of Plasma Waves,"
;                      McGraw-Hill Book Company, USA.
;               7)  Wilson III, L.B., et al., "Quantified energy dissipation rates in the
;                      terrestrial bow shock: I. Analysis techniques and methodology,"
;                      J. Geophys. Res. 119, pp. 6455--6474, doi:10.1002/2014JA019929,
;                      2014a.
;               8)  Wilson III, L.B., et al., "Quantified energy dissipation rates in the
;                      terrestrial bow shock: II. Waves and dissipation," J. Geophys. Res.
;                      119, pp. 6475--6495, doi:10.1002/2014JA019930, 2014b.
;
;   CREATED:  12/17/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/10/2022   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_poynting_flux_freq,efw,scw,FLOW=flow,FHIGH=fhigh,NFFT=nfft,NSHFT=nshft

;;----------------------------------------------------------------------------------------
;; => Define dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
muo            = (4d0*!DPI)*1d-7            ;; Permeability of free space (N/A^2 or H/m)
sfac           = 1d-3*1d-9*1d6/muo[0]       ;; mV --> V, nT --> T, W --> µW, divide by µ_o
def_nfft       = 128L                       ;;  Default # of frequency bins in each FFT
def_nsht       = 32L                        ;;  " " points to shift between each FFT
;;  Dummy error messages
noinp__msg     = 'User must input two valid TPLOT structures...'
badt___msg     = 'Timestamps must match for both inputs!'
badtsp_msg     = 'Bad timestamp inputs...'
badtpn_msg     = 'TPLOT structures are incorrectly formatted...'
bad_NfNs_mssg  = 'Keywords must satisfy:  NFFT ≥ 2*NSHFT --> Using default values...'
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2 OR SIZE(efw,/TYPE) NE 8 OR SIZE(scw,/TYPE) NE 8) THEN BEGIN
  ;;  No input
  MESSAGE,noinp__msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (tplot_struct_format_test(efw,/YVECT,/NOMSSG) EQ 0) OR (tplot_struct_format_test(scw,/YVECT,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  ;;  Bad input --> Invalid TPLOT structure(s)
  MESSAGE,badtpn_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Make sure timestamps overlap
eunix          = t_get_struc_unix(efw)
bunix          = t_get_struc_unix(scw)
diff           = eunix - bunix
IF ((TOTAL(diff,/NAN) NE 0) OR (N_ELEMENTS(eunix) NE N_ELEMENTS(bunix))) THEN BEGIN
  ;;  bad input --> timestamps are off
  MESSAGE,badt___msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
tb             = bunix
nefi           = N_ELEMENTS(tb)               ;;   # of 3-vectors
;;  Calculate sample rate [sps]
smratb         = DOUBLE(sample_rate(tb,GAP_THRESH=2d0,/AVE))
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Check FLOW
IF ((is_a_number(flow,/NOMSSG) EQ 0) OR (N_ELEMENTS(flow) EQ 0)) THEN fcut = 0d0 ELSE fcut = ABS(DOUBLE(flow[0])) < (smratb[0]/2.1)
;;  Check FHIGH
IF ((is_a_number(fhigh,/NOMSSG) EQ 0) OR (N_ELEMENTS(fhigh) EQ 0)) THEN fupp = smratb[0] ELSE fupp = ABS(DOUBLE(fhigh[0])) > (1.01*fcut[0])
;;  Check NFFT
IF ((is_a_number(nfft,/NOMSSG) EQ 0) OR (N_ELEMENTS(nfft) EQ 0)) THEN nfft = def_nfft[0] ELSE nfft = LONG(nfft[0])
IF ((nfft[0] MOD 2L) NE 0) THEN nfft = CEIL(ALOG(1d0*nfft[0])/ALOG(2d0))
;;  Check NSHFT
test           = ((is_a_number(nshft,/NOMSSG) EQ 0) OR (N_ELEMENTS(nshft) EQ 0))
IF (test[0]) THEN nshft = def_nsht[0] ELSE nshft = LONG(nshft[0])
IF ((nshft[0] MOD 2L) NE 0) THEN nshft = CEIL(ALOG(1d0*nshft[0])/ALOG(2d0))
;;  Make sure NFFT ≥ 2*NSHFT
IF (nfft[0] LT 2L*nshft[0]) THEN BEGIN
  ;;  Use default values
  MESSAGE,bad_NfNs_mssg[0],/INFORMATIONAL,/CONTINUE
  nfft           = def_nfft[0]
  nshft          = def_nsht[0]
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
flower         = fcut[0]                            ;;  Lower frequency of relevance [Hz]
fupper         = fupp[0]                            ;;  Upper " "
stride         = nshft[0]                           ;;  # of points by which to shift after each FFT
evecs          = efw.Y                              ;;  [N,3]-Element array of E-fields [mV/m]
bvecs          = scw.Y                              ;;  [N,3]-Element array of B-fields [nT]
;;----------------------------------------------------------------------------------------
;;  Define the bandwidth [Hz] of each FFT frequency bin
;;----------------------------------------------------------------------------------------
nefi_a         = nefi[0] - 1L                       ;;  # of 3-vectors in each FFT interval
n_dft          = nefi_a[0] - nfft[0]                ;;  # of timestamps per interval
n_ts           = nefi[0]/stride[0] + 1L             ;;  # of timestamps for FFTs
;;  Create a Hanning window
win            = HANNING(nfft[0],/DOUBLE)*2d0
win           /= MEAN(win^2d0,/NAN)                 ;;  preserve energy
;;  Define the bandwidth [Hz] of each FFT frequency bin
bw             = smratb[0]/nfft[0]                  ;;  Bandwidth [Hz]
freq           = DINDGEN(nfft[0]/2d0)*bw[0]         ;;  FFT frequency bin values [Hz]
ind_sf         = WHERE(freq GE flower[0] AND freq LE fupper[0],gdsf)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Compute sliding FFTs
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
efw_fft0       = DCOMPLEXARR(n_ts[0],nfft[0],3L)    ;;  [K,W,3]-Element array
scw_fft0       = DCOMPLEXARR(n_ts[0],nfft[0],3L)
tt             = DBLARR(n_ts[0])                    ;;  Dummy time stamps
i              = 0L                                 ;;  Timestamp indexing value
FOR j=0L, n_dft[0] - 1L, stride[0] DO BEGIN
  upj            = j + nfft[0] - 1L
  FOR k=0L, 2L DO BEGIN
    ;;  Compute FFT by field component after applying windowing function
    efw_fft0[i,*,k] = FFT(evecs[j[0]:upj[0],k]*win,/DOUBLE)
    scw_fft0[i,*,k] = FFT(bvecs[j[0]:upj[0],k]*win,/DOUBLE)
  ENDFOR
  ;;  Compute time step of sliding FFTs
  tt[i]          = MEAN(tb[j[0]:upj[0]],/NAN)
  ;;  increment i
  i++
ENDFOR
;;  Keep only relevant values
ind            = (i[0] - 1L)
n_ts           = ind[0]
;;  Remove extra spectra on end
efw_fft        = efw_fft0[0L:(ind[0] - 1L),*,*]
scw_fft        = scw_fft0[0L:(ind[0] - 1L),*,*]
;;  Clean up
delete_variable,efw_fft0,scw_fft0
;; Define timestamps of sliding FFTs
tt             = tt[0L:(ind[0] - 1L)]
;;  (this failed for some reason)
;tt             = tb[0] + (DINDGEN(ind[0])*stride[0] + nfft[0]/2d0)/smratb[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate Poynting Flux [in frequency domain]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
conj_bfft      = CONJ(scw_fft)                      ;;  Complex conjugate of the FFT of B-field
;;  S_i = 1/2 Re[ ( E_j B_k* - E_k B_j* )/µ_o ]
sx_f           = REAL_PART((efw_fft[*,*,1]*conj_bfft[*,*,2] - efw_fft[*,*,2]*conj_bfft[*,*,1])*sfac[0]/2d0)
sy_f           = REAL_PART((efw_fft[*,*,2]*conj_bfft[*,*,0] - efw_fft[*,*,0]*conj_bfft[*,*,2])*sfac[0]/2d0)
sz_f           = REAL_PART((efw_fft[*,*,0]*conj_bfft[*,*,1] - efw_fft[*,*,1]*conj_bfft[*,*,0])*sfac[0]/2d0)
;;  Combine components into one array
s_f            = [[[sx_f]],[[sy_f]],[[sz_f]]]/bw[0] ;;  [K,W,3]-Element array  [µW m^(-2) Hz^(-1)]
;;  S [µW m^(-2)]
IF (gdsf[0] GT 0) THEN BEGIN
  ;;  Sum over square of components and square-root
  power_sf       = SQRT(TOTAL(TOTAL(s_f[*,ind_sf,*]^2,3L,/NAN),2L))  ;;  [K]-Element array
ENDIF ELSE power_sf = REPLICATE(d,N_ELEMENTS(tt))
;;  Remove negative or zero values from POWER_SF
bad            = WHERE(power_sf LE 0,bd)
IF (bd[0] GT 0) THEN power_sf[bad] = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
sfout          = {X:tt,Y:s_f}
spout          = {X:tt,Y:power_sf}
tags           = ['S_FREQ_XYZ','S_POWER','UNITS']
struc          = CREATE_STRUCT(tags,sfout,spout,['µW m^(-2) Hz^(-1)','µW m^(-2)'])
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END

























