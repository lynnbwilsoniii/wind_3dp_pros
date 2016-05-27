;+
;*****************************************************************************************
;
;  FUNCTION :   thm_k_to_n_rebin.pro
;  PURPOSE  :   Downsamples an input array from [K]-points to [N]-points.
;
;  CALLED BY:   
;               thm_efi_x_scm_poyntingflux.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DATA  :  [K]-Element array of complex timeseries data.
;               N     :  Scalar defining the number of data points desired for output
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Finished writing routine                          [05/17/2012   v1.0.0]
;
;   NOTES:      
;               1)  This routine uses CONGRID to rebin from K-points to N-points in
;                     complex space.  It first separates the real and imaginary parts
;                     before it rebins the data.
;               2)  User should not call this routine
;
;   CREATED:  05/15/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/17/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION thm_k_to_n_rebin,data,n

;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,0b
dat    = REFORM(data)
kk     = N_ELEMENTS(dat)
nn     = n[0]

rdat   = REAL_PART(dat)  ;; = Re[x]
idat   = IMAGINARY(dat)  ;; = Im[x]
;;----------------------------------------------------------------------------------------
;;  Linearly interpolate in complex space to new dimensions using nearest-neighbor
;;    sampling [see CONGRID.PRO]
;;----------------------------------------------------------------------------------------
n_rdat = CONGRID(rdat,nn[0],/INTERP,/MINUS_ONE)
n_idat = CONGRID(idat,nn[0],/INTERP,/MINUS_ONE)
;;----------------------------------------------------------------------------------------
;; => Return complex result
;;----------------------------------------------------------------------------------------

RETURN, COMPLEX(n_rdat,n_idat,/DOUBLE)
END

;+
;*****************************************************************************************
;
;  FUNCTION :   thm_efi_x_scm_poyntingflux.pro
;  PURPOSE  :   In principle, this routine should return the Poynting flux computed
;                 from the THEMIS EFI and SCM instrument data.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_struct_format_test.pro
;               sample_rate.pro
;               thm_k_to_n_rebin.pro
;               tplot_struct_format_test.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               EFI_STR  :  Scalar data structure of THEMIS EFI data with the
;                             following structure tags:
;                               X  :  [N]-Element array of Unix time stamps
;                               Y  :  [N,3]-Array of electric field vectors [mV/m]
;               SCM_STR  :  Scalar data structure of THEMIS SCM data with the
;                             following structure tags:
;                               X  :  [K]-Element array of Unix time stamps
;                               Y  :  [K,3]-Array of magnetic field vectors [nT]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Finished writing routine                          [05/17/2012   v1.0.0]
;
;   NOTES:      
;               1)  This routine assumes the input has been calibrated appropriately
;                     in both frequency-dependent phase and amplitude
;               2)  Both inputs must be forced to the same time range so that when
;                     converting to frequency-space one need not worry about the rebinning
;                     of the frequency bins causing incorrect time shifts.
;               3)  ** Not Finished! **
;
;   CREATED:  05/15/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/17/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION thm_efi_x_scm_poyntingflux,efi_str,scm_str

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
muo            = 4d0*!DPI*1d-7     ; -Permeability of free space (N/A^2 or H/m)
notstr_mssg    = 'must be an IDL structure...'
badstr_mssg    = 'must be TPLOT structures...'
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() NE 2) THEN RETURN,0b
efi            = efi_str[0]   ; => in case it is an array of structures of the same format
scm            = scm_str[0]   ; => in case it is an array of structures of the same format
IF (SIZE(efi,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,'EFI_STR '+notstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

IF (SIZE(scm,/TYPE) NE 8L) THEN BEGIN
  MESSAGE,'SCM_STR '+notstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF

test_efi = tplot_struct_format_test(efi,/YVECT) EQ 0
test_scm = tplot_struct_format_test(scm,/YVECT) EQ 0

IF (test_efi OR test_scm) THEN BEGIN
  MESSAGE,'EFI_STR and SCM_STR '+badstr_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;; => Set NaNs -> 0
;;----------------------------------------------------------------------------------------
;;  EFI
efi_y     = efi.Y
bbx       = WHERE(FINITE(efi_y[*,0]) EQ 0,bx,COMPLEMENT=ggx)
bby       = WHERE(FINITE(efi_y[*,1]) EQ 0,by,COMPLEMENT=ggy)
bbz       = WHERE(FINITE(efi_y[*,2]) EQ 0,bz,COMPLEMENT=ggz)
IF (bx GT 0L) THEN efi_y[bbx,0] = 0d0
IF (by GT 0L) THEN efi_y[bby,1] = 0d0
IF (bz GT 0L) THEN efi_y[bbz,2] = 0d0
;;  SCM
scm_y     = scm.Y
bbx       = WHERE(FINITE(scm_y[*,0]) EQ 0,bx,COMPLEMENT=ggx)
bby       = WHERE(FINITE(scm_y[*,1]) EQ 0,by,COMPLEMENT=ggy)
bbz       = WHERE(FINITE(scm_y[*,2]) EQ 0,bz,COMPLEMENT=ggz)
IF (bx GT 0L) THEN scm_y[bbx,0] = 0d0
IF (by GT 0L) THEN scm_y[bby,1] = 0d0
IF (bz GT 0L) THEN scm_y[bbz,2] = 0d0
;;  Redefine structure
efi.Y     = efi_y
scm.Y     = scm_y
;;----------------------------------------------------------------------------------------
;; => Calculate sample rate
;;----------------------------------------------------------------------------------------
mx_efi_dt = MAX(efi.X,/NAN) - MIN(efi.X,/NAN)
mx_scm_dt = MAX(scm.X,/NAN) - MIN(scm.X,/NAN)
n_efi     = N_ELEMENTS(efi.X)
n_scm     = N_ELEMENTS(scm.X)
t_avg_edt = (n_efi - 1L)/mx_efi_dt[0]
t_avg_sdt = (n_scm - 1L)/mx_scm_dt[0]
;;  sample rate
efi_srate = sample_rate(efi.X,GAP_THRESH=2d0/t_avg_edt[0],/AVERAGE)
scm_srate = sample_rate(scm.X,GAP_THRESH=2d0/t_avg_sdt[0],/AVERAGE)
;;----------------------------------------------------------------------------------------
;; => Calculate FFTs
;;----------------------------------------------------------------------------------------
;;  EFI (convert to V/m)
efx_fft     = FFT(efi_y[*,0]*1d-3,/DOUBLE)
efy_fft     = FFT(efi_y[*,1]*1d-3,/DOUBLE)
efz_fft     = FFT(efi_y[*,2]*1d-3,/DOUBLE)
;;  SCM (convert to T)
bfx_fft     = FFT(scm_y[*,0]*1d-9,/DOUBLE)
bfy_fft     = FFT(scm_y[*,1]*1d-9,/DOUBLE)
bfz_fft     = FFT(scm_y[*,2]*1d-9,/DOUBLE)
;;----------------------------------------------------------------------------------------
;; => Determine which is larger or if the same
;;----------------------------------------------------------------------------------------
sr_e      = efi_srate[0]
sr_b      = scm_srate[0]
test      = [(sr_e[0] GT sr_b[0]),(sr_e[0] LT sr_b[0]),(sr_e[0] EQ sr_b[0])]
good      = WHERE(test,gd)

CASE good[0] OF
  0L   : BEGIN
    ; => EFI sampled faster than SCM
    ;; FFT of EFI
    down_efx = thm_k_to_n_rebin(efx_fft,n_scm)
    down_efy = thm_k_to_n_rebin(efy_fft,n_scm)
    down_efz = thm_k_to_n_rebin(efz_fft,n_scm)
    ;; FFT of SCM
    down_bfx = bfx_fft
    down_bfy = bfy_fft
    down_bfz = bfz_fft
  END
  1L   : BEGIN
    ; => EFI sampled slower than SCM
    ;; FFT of SCM
    down_bfx = thm_k_to_n_rebin(bfx_fft,n_efi)
    down_bfy = thm_k_to_n_rebin(bfy_fft,n_efi)
    down_bfz = thm_k_to_n_rebin(bfz_fft,n_efi)
    ;; FFT of EFI
    down_efx = efx_fft
    down_efy = efy_fft
    down_efz = efz_fft
  END
  2L   : BEGIN
    ; => EFI sample rate equal to SCM
    ;; FFT of EFI
    down_efx = efx_fft
    down_efy = efy_fft
    down_efz = efz_fft
    ;; FFT of SCM
    down_bfx = bfx_fft
    down_bfy = bfy_fft
    down_bfz = bfz_fft
  END
  ELSE : BEGIN
    ;; How did you manage this?
    RETURN,0b
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;; => Calculate Poynting flux in complex frequency space
;;----------------------------------------------------------------------------------------
;;  Let the fields be represented as:  A = Re[A] + i Im[A]
;;    => [(E* x B) - (E x B*)]/2 = i (Re[E] x Im[B]) - i (Im[E] x Re[B])
;;      => keep only the terms that are 90 degrees out of phase
;;  
;;  Cx = Ay * Bz  -  Az * By
;;  Cy = Az * Bx  -  Ax * Bz
;;  Cz = Ax * By  -  Ay * Bx
;;  S  = [(E* x B) - (E x B*)]/2
;;----------------------------------------------------------------------------------------
;;  Compute:  (E* x B)
econj_b_x = CONJ(down_efy)*down_bfz - CONJ(down_efz)*down_bfy
econj_b_y = CONJ(down_efz)*down_bfx - CONJ(down_efx)*down_bfz
econj_b_z = CONJ(down_efx)*down_bfy - CONJ(down_efy)*down_bfx
;;  Compute:  (E x B*)
e_bconj_x = down_efy*CONJ(down_bfz) - down_efz*CONJ(down_bfy)
e_bconj_y = down_efz*CONJ(down_bfx) - down_efx*CONJ(down_bfz)
e_bconj_z = down_efx*CONJ(down_bfy) - down_efy*CONJ(down_bfx)
;;  Compute:  S  = [(E* x B) - (E x B*)]/2
scplx_x   = (econj_b_x - e_bconj_x)/2d0
scplx_y   = (econj_b_y - e_bconj_y)/2d0
scplx_z   = (econj_b_z - e_bconj_z)/2d0
;;  Reverse the FFT to get Poynting Flux [W m^(-2)]
poyntingx = REAL_PART(FFT(scplx_x,1,/DOUBLE))/muo[0]
poyntingy = REAL_PART(FFT(scplx_y,1,/DOUBLE))/muo[0]
poyntingz = REAL_PART(FFT(scplx_z,1,/DOUBLE))/muo[0]
;;  Convert to [µW m^(-2)]
poyntingf = [[poyntingx],[poyntingy],[poyntingz]]*1d6

stop
;;----------------------------------------------------------------------------------------
;; => Return Poynting flux result [µW m^(-2)]
;;----------------------------------------------------------------------------------------

RETURN,poyntingf
END