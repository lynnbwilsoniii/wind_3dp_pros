;*****************************************************************************************
;
;  FUNCTION :   sub_calc_psd_complex_phase_4sc.pro
;  PURPOSE  :   Calculates the power spectral density of an input 3-vector array of data.
;
;  CALLED BY:   
;               lbw_calc_complex_phase_4sc.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               sample_rate.pro
;               power_of_2.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               UNIX    :  [N]-Element [numeric] array of time stamps for VECS
;               VECS    :  [N,3]- or [N,N,3]-element [numeric] array of 3-vectors
;
;  EXAMPLES:    
;               [calling sequence]
;               fft_str = sub_calc_psd_complex_phase_4sc(unix,vecs)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [11/11/2020   v1.0.0]
;
;   NOTES:      
;               1)  User should not call this routine directly
;
;  REFERENCES:  
;               NA
;
;   CREATED:  11/10/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/11/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION sub_calc_psd_complex_phase_4sc,unix,vecs

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Define sample rate [sps] and # of bins
;;----------------------------------------------------------------------------------------
srate          = sample_rate(unix,/AVE)
IF (srate[0] GT 10) THEN srate = 1d0*(ROUND(srate[0]))[0] ELSE srate = 1d0*srate[0]
nfbin_0        = N_ELEMENTS(unix)
;;----------------------------------------------------------------------------------------
;;  Zero pad the data
;;----------------------------------------------------------------------------------------
szdv           = SIZE(vecs,/DIMENSIONS)
sznv           = SIZE(vecs,/N_DIMENSIONS)
CASE sznv[0] OF
  2L    :  BEGIN
    vecsx          = power_of_2(vecs[*,0])
    vecsy          = power_of_2(vecs[*,1])
    vecsz          = power_of_2(vecs[*,2])
    ;;  Define # of frequency bins, but NOT sample rate
    nfbin_1        = N_ELEMENTS(vecsx)
  END
  3L    :  BEGIN
    vecsx          = REFORM(vecs[*,*,0])
    vecsy          = REFORM(vecs[*,*,1])
    vecsz          = REFORM(vecs[*,*,2])
    ;;  Define # of frequency bins, but NOT sample rate
    nfbin_1        = N_ELEMENTS(vecsx[*,0])
  END
  ELSE  :  STOP     ;;  Should not happen --> debug
ENDCASE
;;  Define normalization parameter due to zero-padding
zfact_1        = 2d0*(1d0*nfbin_1[0])^2d0/(1d0*nfbin_0[0]*srate[0])
;;  Define frequency bins [Hz]
psd_freq       = DINDGEN(nfbin_1[0]/2L)*srate[0]/(nfbin_1[0] - 1L)
;;----------------------------------------------------------------------------------------
;;  Define FFT frequencies
;;----------------------------------------------------------------------------------------
nd             = nfbin_1[0]
n_m            = nd[0]/2L + 1L                              ;;  mid point element (i.e., where frequencies go negative in FFT)
frn            = nd[0] - n_m[0]
frel           = LINDGEN(frn[0]) + n_m[0]                   ;;  Elements for negative frequencies
fft_freq       = DINDGEN(nd[0])
fft_freq[frel] = (n_m[0] - nd[0]) + DINDGEN(n_m[0] - 2L)
fft_freq      *= (srate[0]/nd[0])
;;----------------------------------------------------------------------------------------
;;  Calculate FFT
;;----------------------------------------------------------------------------------------
fftbx          = FFT(vecsx)*SQRT(zfact_1[0])
fftby          = FFT(vecsy)*SQRT(zfact_1[0])
fftbz          = FFT(vecsz)*SQRT(zfact_1[0])
;;  Remove factor of 2 from 1st and last elements to avoid double-counting
ind_phi        = LINDGEN(nfbin_1[0]/2L)
bd_1l          = [0L,(nfbin_1[0]/2L - 1L)]
CASE sznv[0] OF
  2L    :  BEGIN
    fftbx[bd_1l]  /= 2d0
    fftby[bd_1l]  /= 2d0
    fftbz[bd_1l]  /= 2d0
    ;;  Combine into an [N,3]-element [dcomplex] array
    fft__psd       = [[fftbx],[fftby],[fftbz]]
  END
  3L    :  BEGIN
    fftbx[bd_1l,*]  /= 2d0
    fftby[bd_1l,*]  /= 2d0
    fftbz[bd_1l,*]  /= 2d0
    fftbx[*,bd_1l]  /= 2d0
    fftby[*,bd_1l]  /= 2d0
    fftbz[*,bd_1l]  /= 2d0
    ;;  Combine into an [N,3]-element [dcomplex] array
    fft__psd       = [[[fftbx]],[[fftby]],[[fftbz]]]
  END
  ELSE  :  STOP     ;;  Should not happen --> debug
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
tags           = ['PSD_FREQ','FFT_FREQ','FFT__PSD']
struc          = CREATE_STRUCT(tags,psd_freq,fft_freq,fft__psd)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END


;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_calc_complex_phase_4sc.pro
;  PURPOSE  :   Calculates the complex FFT, covariance, phase, and coherence between
;                 any two inputs from two different spacecraft.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               sub_calc_psd_complex_phase_4sc.pro
;
;  CALLS:
;               is_a_number.pro
;               test_tplot_handle.pro
;               test_plot_axis_range.pro
;               get_data.pro
;               trange_clip_data.pro
;               t_get_struc_unix.pro
;               sub_calc_psd_complex_phase_4sc.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TPN_MAGF     :  [4]-Element [string] array defining set and valid TPLOT
;                                 handles associated with magnetic field data all in
;                                 the same coordinate basis [nT, ICB]
;               TRAN_SE      :  [4,2]-Element [double] array defining the time stamps of
;                                 points of interest to use for calculating the group
;                                 velocity unit vector and MVA unit vector associated
;                                 with a wave interval
;
;  EXAMPLES:    
;               [calling sequence]
;               struc = lbw_calc_complex_phase_4sc(tpn_magf,tran_se [,DT_EXPND=dt_expnd])
;
;  KEYWORDS:    
;               DT_EXPND     :  [2]-Element [numeric] array defining the delta-t to by
;                                 which to expand each TRAN_SE for the frequency peak
;                                 finding portion of this routine.  It's useful to have
;                                 more than fewer points to increase the SNR of the peak
;                                 and refine the actual frequency range.
;                                 [Default = [0,0]]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [11/11/2020   v1.0.0]
;
;   NOTES:      
;               0)  ***  Still Testing/Writing  ***
;               1)  Technically the input TPLOT handle could be for any 3-vector other
;                     than the magnetic field and this should still work
;
;  REFERENCES:  
;               1)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk,
;                      The Netherlands., Int. Space Sci. Inst.
;               2)  Harris, F.J. "On the Use of Windows for Harmonic Analysis with the
;                      Discrete Fourier Transform," Proc. IEEE Vol. 66, No. 1,
;                      pp. 51-83, (1978).
;               3)  Balikhin, M.A., et al., "Experimental determination of the dispersion
;                      of waves observed upstream of a quasi-perpendicular shock,"
;                      Geophys. Res. Lett. 24(7), pp. 787--790, doi:10.1029/97GL00671,
;                      1997.
;               4)  Balikhin, M.A., et al., "Determination of the dispersion of low
;                      frequency waves downstream of a quasiperpendicular collisionless
;                      shock," Ann. Geophys. 15(2), pp. 143--151,
;                      doi:10.1007/s005850050429, 1997.
;                      1997.
;               5)  Balikhin, M.A., et al., "Identification of low frequency waves in the
;                      vicinity of the terrestrial bow shock," Planet. Space Sci. 51(11),
;                      pp. 693--702, doi:10.1016/S0032-0633(03)00104-1, 2003.
;               6)  Walker, S.N., et al., "A comparison of wave mode identification
;                      techniques," Ann. Geophys. 22(8), pp. 3021--3032,
;                      doi:10.5194/angeo-22-3021-2004, 2004.
;
;   CREATED:  11/10/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/11/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_calc_complex_phase_4sc,tpn_magf,tran_se,DT_EXPND=dt_expnd

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
wdth           = [4L,4L]
scpref_all     = 'SC'+['1','2','3','4']
;;  Error messages
noinput_mssg   = 'No input was supplied...'
no_tpns_mssg   = 'Not enough valid TPLOT handles supplied...'
badtinp_mssg   = 'Incorrect input format was supplied:  TRAN_SE must be an [4,2]-element [double] array'
battpdt_mssg   = 'The TPLOT handles supplied did not contain data...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = ((N_PARAMS() LT 2) OR (SIZE(tpn_magf,/TYPE) NE 7) OR $
                   (is_a_number(tran_se,/NOMSSG) EQ 0))
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
testm          = test_tplot_handle(tpn_magf,TPNMS=tpnmagf)
goodm          = WHERE(tpnmagf NE '',gdm)
IF (gdm[0] LT 4 OR ~testm[0]) THEN BEGIN
  MESSAGE,no_tpns_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
sznd           = SIZE(tran_se,/N_DIMENSIONS)
szdd           = SIZE(tran_se,/DIMENSIONS)
test           = ((N_ELEMENTS(tran_se) MOD 4) NE 0) OR ((sznd[0] NE 2) AND (N_ELEMENTS(tran_se) NE 8))
IF (test[0]) THEN BEGIN
  MESSAGE,badtinp_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DT_EXPND
IF (test_plot_axis_range(dt_expnd,/NOMSSG)) THEN BEGIN
  dtexp          = 1d0*dt_expnd[SORT(dt_expnd)]
ENDIF ELSE BEGIN
  dtexp          = [0d0,0d0]
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Get TPLOT data
;;----------------------------------------------------------------------------------------
;;  Get Bo [nT, GSE]
get_data,tpnmagf[0],DATA=temp_magfv_1
get_data,tpnmagf[1],DATA=temp_magfv_2
get_data,tpnmagf[2],DATA=temp_magfv_3
get_data,tpnmagf[3],DATA=temp_magfv_4
;;  Clip to appropriate time ranges
bgse_clip_1    = trange_clip_data(temp_magfv_1,TRANGE=REFORM(tran_se[0,*]) + dtexp,PRECISION=3)
bgse_clip_2    = trange_clip_data(temp_magfv_2,TRANGE=REFORM(tran_se[1,*]) + dtexp,PRECISION=3)
bgse_clip_3    = trange_clip_data(temp_magfv_3,TRANGE=REFORM(tran_se[2,*]) + dtexp,PRECISION=3)
bgse_clip_4    = trange_clip_data(temp_magfv_4,TRANGE=REFORM(tran_se[3,*]) + dtexp,PRECISION=3)
;;  Define relevant parameters
bunix_1        = t_get_struc_unix(bgse_clip_1)
bunix_2        = t_get_struc_unix(bgse_clip_2)
bunix_3        = t_get_struc_unix(bgse_clip_3)
bunix_4        = t_get_struc_unix(bgse_clip_4)
bgsev_1        = bgse_clip_1.Y
bgsev_2        = bgse_clip_2.Y
bgsev_3        = bgse_clip_3.Y
bgsev_4        = bgse_clip_4.Y
;;  Define mean for each component
mean_b1        = MEAN(bgsev_1,/NAN,DIMENSION=1)
mean_b2        = MEAN(bgsev_2,/NAN,DIMENSION=1)
mean_b3        = MEAN(bgsev_3,/NAN,DIMENSION=1)
mean_b4        = MEAN(bgsev_4,/NAN,DIMENSION=1)
;;----------------------------------------------------------------------------------------
;;  Trim off excess edge points
;;----------------------------------------------------------------------------------------
nn1            = N_ELEMENTS(bunix_1) & nn2 = N_ELEMENTS(bunix_2) & nn3 = N_ELEMENTS(bunix_3) & nn4 = N_ELEMENTS(bunix_4)
nmin           = MIN([nn1[0],nn2[0],nn3[0],nn4[0]],ln)
nmnodd         = (nmin[0] MOD 2) NE 0                   ;;  Check if odd or even
IF (ln[0] EQ 0) THEN IF (nmnodd[0]) THEN ind1 = LINDGEN(nn1[0] - 1L) ELSE ind1 = LINDGEN(nn1[0])
IF (ln[0] EQ 1) THEN IF (nmnodd[0]) THEN ind2 = LINDGEN(nn2[0] - 1L) ELSE ind2 = LINDGEN(nn2[0])
IF (ln[0] EQ 2) THEN IF (nmnodd[0]) THEN ind3 = LINDGEN(nn3[0] - 1L) ELSE ind3 = LINDGEN(nn3[0])
IF (ln[0] EQ 3) THEN IF (nmnodd[0]) THEN ind4 = LINDGEN(nn4[0] - 1L) ELSE ind4 = LINDGEN(nn4[0])
nmin           = ([N_ELEMENTS(ind1),N_ELEMENTS(ind2),N_ELEMENTS(ind3),N_ELEMENTS(ind4)])[ln[0]]
ndif           = [nn1[0],nn2[0],nn3[0],nn4[0]] - nmin[0]
IF (ln[0] NE 0) THEN ind1 = LINDGEN(nmin[0]) + ndif[0]/2L
IF (ln[0] NE 1) THEN ind2 = LINDGEN(nmin[0]) + ndif[1]/2L
IF (ln[0] NE 2) THEN ind3 = LINDGEN(nmin[0]) + ndif[2]/2L
IF (ln[0] NE 3) THEN ind4 = LINDGEN(nmin[0]) + ndif[3]/2L
;;  Redefine parameters
bunix_1        = bunix_1[ind1]
bunix_2        = bunix_2[ind2]
bunix_3        = bunix_3[ind3]
bunix_4        = bunix_4[ind4]
bgsev_1        = bgsev_1[ind1,*]
bgsev_2        = bgsev_2[ind2,*]
bgsev_3        = bgsev_3[ind3,*]
bgsev_4        = bgsev_4[ind4,*]
nnn            = N_ELEMENTS(bunix_1)
;;  Remove mean
bgsev_1       -= (REPLICATE(1d0,nnn[0]) # mean_b1)
bgsev_2       -= (REPLICATE(1d0,nnn[0]) # mean_b2)
bgsev_3       -= (REPLICATE(1d0,nnn[0]) # mean_b3)
bgsev_4       -= (REPLICATE(1d0,nnn[0]) # mean_b4)
;;----------------------------------------------------------------------------------------
;;  Calculate FFT of each
;;----------------------------------------------------------------------------------------
fft_str_1      = sub_calc_psd_complex_phase_4sc(bunix_1,bgsev_1)
fft_str_2      = sub_calc_psd_complex_phase_4sc(bunix_2,bgsev_2)
fft_str_3      = sub_calc_psd_complex_phase_4sc(bunix_3,bgsev_3)
fft_str_4      = sub_calc_psd_complex_phase_4sc(bunix_4,bgsev_4)
;;  Define relevant outputs
fftbxyz_1      = fft_str_1.FFT__PSD
fftbxyz_2      = fft_str_2.FFT__PSD
fftbxyz_3      = fft_str_3.FFT__PSD
fftbxyz_4      = fft_str_4.FFT__PSD
;;----------------------------------------------------------------------------------------
;;  Calculate FFT covariance between any two signals:
;;    C_ij = < Xi* Xj >_t
;;----------------------------------------------------------------------------------------
cvfbx12        = SMOOTH(CONJ(fftbxyz_1[*,0]) # fftbxyz_2[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx13        = SMOOTH(CONJ(fftbxyz_1[*,0]) # fftbxyz_3[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx14        = SMOOTH(CONJ(fftbxyz_1[*,0]) # fftbxyz_4[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby12        = SMOOTH(CONJ(fftbxyz_1[*,1]) # fftbxyz_2[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfby13        = SMOOTH(CONJ(fftbxyz_1[*,1]) # fftbxyz_3[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfby14        = SMOOTH(CONJ(fftbxyz_1[*,1]) # fftbxyz_4[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz12        = SMOOTH(CONJ(fftbxyz_1[*,2]) # fftbxyz_2[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz13        = SMOOTH(CONJ(fftbxyz_1[*,2]) # fftbxyz_3[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz14        = SMOOTH(CONJ(fftbxyz_1[*,2]) # fftbxyz_4[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx23        = SMOOTH(CONJ(fftbxyz_2[*,0]) # fftbxyz_3[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx24        = SMOOTH(CONJ(fftbxyz_2[*,0]) # fftbxyz_4[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby23        = SMOOTH(CONJ(fftbxyz_2[*,1]) # fftbxyz_3[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfby24        = SMOOTH(CONJ(fftbxyz_2[*,1]) # fftbxyz_4[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz23        = SMOOTH(CONJ(fftbxyz_2[*,2]) # fftbxyz_3[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz24        = SMOOTH(CONJ(fftbxyz_2[*,2]) # fftbxyz_4[*,2],wdth,/NAN,/EDGE_TRUNCATE)
;;  Calculate the self covariance terms
cvfbx11        = SMOOTH(CONJ(fftbxyz_1[*,0]) # fftbxyz_1[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby11        = SMOOTH(CONJ(fftbxyz_1[*,1]) # fftbxyz_1[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz11        = SMOOTH(CONJ(fftbxyz_1[*,2]) # fftbxyz_1[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx22        = SMOOTH(CONJ(fftbxyz_2[*,0]) # fftbxyz_2[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby22        = SMOOTH(CONJ(fftbxyz_2[*,1]) # fftbxyz_2[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz22        = SMOOTH(CONJ(fftbxyz_2[*,2]) # fftbxyz_2[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx33        = SMOOTH(CONJ(fftbxyz_3[*,0]) # fftbxyz_3[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby33        = SMOOTH(CONJ(fftbxyz_3[*,1]) # fftbxyz_3[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz33        = SMOOTH(CONJ(fftbxyz_3[*,2]) # fftbxyz_3[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx44        = SMOOTH(CONJ(fftbxyz_4[*,0]) # fftbxyz_4[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby44        = SMOOTH(CONJ(fftbxyz_4[*,1]) # fftbxyz_4[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz44        = SMOOTH(CONJ(fftbxyz_4[*,2]) # fftbxyz_4[*,2],wdth,/NAN,/EDGE_TRUNCATE)
;;----------------------------------------------------------------------------------------
;;  Return only the positive frequency parts of each
;;----------------------------------------------------------------------------------------
nn             = N_ELEMENTS(cvfbx12[*,0L])
nind           = LINDGEN(nn[0]/2L + 1L)
cvfbx12        = cvfbx12[nind,*] & cvfbx12 = cvfbx12[*,nind]
cvfbx13        = cvfbx13[nind,*] & cvfbx13 = cvfbx13[*,nind]
cvfbx14        = cvfbx14[nind,*] & cvfbx14 = cvfbx14[*,nind]
cvfby12        = cvfby12[nind,*] & cvfby12 = cvfby12[*,nind]
cvfby13        = cvfby13[nind,*] & cvfby13 = cvfby13[*,nind]
cvfby14        = cvfby14[nind,*] & cvfby14 = cvfby14[*,nind]
cvfbz12        = cvfbz12[nind,*] & cvfbz12 = cvfbz12[*,nind]
cvfbz13        = cvfbz13[nind,*] & cvfbz13 = cvfbz13[*,nind]
cvfbz14        = cvfbz14[nind,*] & cvfbz14 = cvfbz14[*,nind]
cvfbx23        = cvfbx23[nind,*] & cvfbx23 = cvfbx23[*,nind]
cvfbx24        = cvfbx24[nind,*] & cvfbx24 = cvfbx24[*,nind]
cvfby23        = cvfby23[nind,*] & cvfby23 = cvfby23[*,nind]
cvfby24        = cvfby24[nind,*] & cvfby24 = cvfby24[*,nind]
cvfbz23        = cvfbz23[nind,*] & cvfbz23 = cvfbz23[*,nind]
cvfbz24        = cvfbz24[nind,*] & cvfbz24 = cvfbz24[*,nind]
cvfbx11        = cvfbx11[nind,*] & cvfbx11 = cvfbx11[*,nind]
cvfby11        = cvfby11[nind,*] & cvfby11 = cvfby11[*,nind]
cvfbz11        = cvfbz11[nind,*] & cvfbz11 = cvfbz11[*,nind]
cvfbx22        = cvfbx22[nind,*] & cvfbx22 = cvfbx22[*,nind]
cvfby22        = cvfby22[nind,*] & cvfby22 = cvfby22[*,nind]
cvfbz22        = cvfbz22[nind,*] & cvfbz22 = cvfbz22[*,nind]
cvfbx33        = cvfbx33[nind,*] & cvfbx33 = cvfbx33[*,nind]
cvfby33        = cvfby33[nind,*] & cvfby33 = cvfby33[*,nind]
cvfbz33        = cvfbz33[nind,*] & cvfbz33 = cvfbz33[*,nind]
cvfbx44        = cvfbx44[nind,*] & cvfbx44 = cvfbx44[*,nind]
cvfby44        = cvfby44[nind,*] & cvfby44 = cvfby44[*,nind]
cvfbz44        = cvfbz44[nind,*] & cvfbz44 = cvfbz44[*,nind]
;;----------------------------------------------------------------------------------------
;;  Calculate FFT phase between any two signals:
;;    phi_ij = ArcTan(Im[Xi],Re[Xj])
;;----------------------------------------------------------------------------------------
phibx12        = ATAN(IMAGINARY(cvfbx12),REAL_PART(cvfbx12))
phibx13        = ATAN(IMAGINARY(cvfbx13),REAL_PART(cvfbx13))
phibx14        = ATAN(IMAGINARY(cvfbx14),REAL_PART(cvfbx14))
phiby12        = ATAN(IMAGINARY(cvfby12),REAL_PART(cvfby12))
phiby13        = ATAN(IMAGINARY(cvfby13),REAL_PART(cvfby13))
phiby14        = ATAN(IMAGINARY(cvfby14),REAL_PART(cvfby14))
phibz12        = ATAN(IMAGINARY(cvfbz12),REAL_PART(cvfbz12))
phibz13        = ATAN(IMAGINARY(cvfbz13),REAL_PART(cvfbz13))
phibz14        = ATAN(IMAGINARY(cvfbz14),REAL_PART(cvfbz14))
phibx23        = ATAN(IMAGINARY(cvfbx23),REAL_PART(cvfbx23))
phibx24        = ATAN(IMAGINARY(cvfbx24),REAL_PART(cvfbx24))
phiby23        = ATAN(IMAGINARY(cvfby23),REAL_PART(cvfby23))
phiby24        = ATAN(IMAGINARY(cvfby24),REAL_PART(cvfby24))
phibz23        = ATAN(IMAGINARY(cvfbz23),REAL_PART(cvfbz23))
phibz24        = ATAN(IMAGINARY(cvfbz24),REAL_PART(cvfbz24))
;;----------------------------------------------------------------------------------------
;;  Calculate coherence between any two signals:
;;    gamma_ij^2 =|C_ij|^2/[ |C_ii| |C_jj| ]
;;----------------------------------------------------------------------------------------
gam2x12        = ABS(cvfbx12)^2d0/(ABS(cvfbx11)*ABS(cvfbx22))
gam2x13        = ABS(cvfbx13)^2d0/(ABS(cvfbx11)*ABS(cvfbx33))
gam2x14        = ABS(cvfbx14)^2d0/(ABS(cvfbx11)*ABS(cvfbx44))
gam2y12        = ABS(cvfby12)^2d0/(ABS(cvfby11)*ABS(cvfby22))
gam2y13        = ABS(cvfby13)^2d0/(ABS(cvfby11)*ABS(cvfby33))
gam2y14        = ABS(cvfby14)^2d0/(ABS(cvfby11)*ABS(cvfby44))
gam2z12        = ABS(cvfbz12)^2d0/(ABS(cvfbz11)*ABS(cvfbz22))
gam2z13        = ABS(cvfbz13)^2d0/(ABS(cvfbz11)*ABS(cvfbz33))
gam2z14        = ABS(cvfbz14)^2d0/(ABS(cvfbz11)*ABS(cvfbz44))
gam2x23        = ABS(cvfbx23)^2d0/(ABS(cvfbx22)*ABS(cvfbx33))
gam2x24        = ABS(cvfbx24)^2d0/(ABS(cvfbx22)*ABS(cvfbx44))
gam2y23        = ABS(cvfby23)^2d0/(ABS(cvfby22)*ABS(cvfby33))
gam2y24        = ABS(cvfby24)^2d0/(ABS(cvfby22)*ABS(cvfby44))
gam2z23        = ABS(cvfbz23)^2d0/(ABS(cvfbz22)*ABS(cvfbz33))
gam2z24        = ABS(cvfbz24)^2d0/(ABS(cvfbz22)*ABS(cvfbz44))
;;  Values > 1.0 are "bad" --> remove
bad_x12        = WHERE(SQRT(gam2x12) GT 1,bd_x12)
bad_x13        = WHERE(SQRT(gam2x13) GT 1,bd_x13)
bad_x14        = WHERE(SQRT(gam2x14) GT 1,bd_x14)
bad_y12        = WHERE(SQRT(gam2y12) GT 1,bd_y12)
bad_y13        = WHERE(SQRT(gam2y13) GT 1,bd_y13)
bad_y14        = WHERE(SQRT(gam2y14) GT 1,bd_y14)
bad_z12        = WHERE(SQRT(gam2z12) GT 1,bd_z12)
bad_z13        = WHERE(SQRT(gam2z13) GT 1,bd_z13)
bad_z14        = WHERE(SQRT(gam2z14) GT 1,bd_z14)
bad_x23        = WHERE(SQRT(gam2x23) GT 1,bd_x23)
bad_x24        = WHERE(SQRT(gam2x24) GT 1,bd_x24)
bad_y23        = WHERE(SQRT(gam2y23) GT 1,bd_y23)
bad_y24        = WHERE(SQRT(gam2y24) GT 1,bd_y24)
bad_z23        = WHERE(SQRT(gam2z23) GT 1,bd_z23)
bad_z24        = WHERE(SQRT(gam2z24) GT 1,bd_z24)
;;  Define coherence magnitude
gammx12        = SQRT(gam2x12)
gammx13        = SQRT(gam2x13)
gammx14        = SQRT(gam2x14)
gammy12        = SQRT(gam2y12)
gammy13        = SQRT(gam2y13)
gammy14        = SQRT(gam2y14)
gammz12        = SQRT(gam2z12)
gammz13        = SQRT(gam2z13)
gammz14        = SQRT(gam2z14)
gammx23        = SQRT(gam2x23)
gammx24        = SQRT(gam2x24)
gammy23        = SQRT(gam2y23)
gammy24        = SQRT(gam2y24)
gammz23        = SQRT(gam2z23)
gammz24        = SQRT(gam2z24)
;;  Kill "bad" elements
IF (bd_x12[0] GT 0) THEN gammx12[bad_x12] = d
IF (bd_x13[0] GT 0) THEN gammx13[bad_x13] = d
IF (bd_x14[0] GT 0) THEN gammx14[bad_x14] = d
IF (bd_y12[0] GT 0) THEN gammy12[bad_y12] = d
IF (bd_y13[0] GT 0) THEN gammy13[bad_y13] = d
IF (bd_y14[0] GT 0) THEN gammy14[bad_y14] = d
IF (bd_z12[0] GT 0) THEN gammz12[bad_z12] = d
IF (bd_z13[0] GT 0) THEN gammz13[bad_z13] = d
IF (bd_z14[0] GT 0) THEN gammz14[bad_z14] = d
IF (bd_x23[0] GT 0) THEN gammx23[bad_x23] = d
IF (bd_x24[0] GT 0) THEN gammx24[bad_x24] = d
IF (bd_y23[0] GT 0) THEN gammy23[bad_y23] = d
IF (bd_y24[0] GT 0) THEN gammy24[bad_y24] = d
IF (bd_z23[0] GT 0) THEN gammz23[bad_z23] = d
IF (bd_z24[0] GT 0) THEN gammz24[bad_z24] = d
;;----------------------------------------------------------------------------------------
;;  Calculate cross-spectrum between any two signals:
;;    CC_ij = FFT(gamma_ij)
;;----------------------------------------------------------------------------------------
;;  Zero pad inputs to match array sizes of other outputs
nzero          = nn[0]
n_old          = N_ELEMENTS(bgsev_1[*,0])
zeros          = REPLICATE(0d0,(nzero[0] - n_old[0]),3L)
vec_1          = [bgsev_1,zeros]
vec_2          = [bgsev_2,zeros]
vec_3          = [bgsev_3,zeros]
vec_4          = [bgsev_4,zeros]
cov_bx_12      = vec_1[*,0] # vec_2[*,0]
cov_bx_13      = vec_1[*,0] # vec_3[*,0]
cov_bx_14      = vec_1[*,0] # vec_4[*,0]
cov_by_12      = vec_1[*,1] # vec_2[*,1]
cov_by_13      = vec_1[*,1] # vec_3[*,1]
cov_by_14      = vec_1[*,1] # vec_4[*,1]
cov_bz_12      = vec_1[*,2] # vec_2[*,2]
cov_bz_13      = vec_1[*,2] # vec_3[*,2]
cov_bz_14      = vec_1[*,2] # vec_4[*,2]
cov_bx_23      = vec_2[*,0] # vec_3[*,0]
cov_bx_24      = vec_2[*,0] # vec_4[*,0]
cov_by_23      = vec_2[*,1] # vec_3[*,1]
cov_by_24      = vec_2[*,1] # vec_4[*,1]
cov_bz_23      = vec_2[*,2] # vec_3[*,2]
cov_bz_24      = vec_2[*,2] # vec_4[*,2]
cov_b__12      = [[[cov_bx_12]],[[cov_by_12]],[[cov_bz_12]]]
cov_b__13      = [[[cov_bx_13]],[[cov_by_13]],[[cov_bz_13]]]
cov_b__14      = [[[cov_bx_14]],[[cov_by_14]],[[cov_bz_14]]]
cov_b__23      = [[[cov_bx_23]],[[cov_by_23]],[[cov_bz_23]]]
cov_b__24      = [[[cov_bx_24]],[[cov_by_24]],[[cov_bz_24]]]
;;  Calculate cross-spectrum
crsp_str_12    = sub_calc_psd_complex_phase_4sc(bunix_1,cov_b__12)
crsp_str_13    = sub_calc_psd_complex_phase_4sc(bunix_1,cov_b__13)
crsp_str_14    = sub_calc_psd_complex_phase_4sc(bunix_1,cov_b__14)
crsp_str_23    = sub_calc_psd_complex_phase_4sc(bunix_1,cov_b__23)
crsp_str_24    = sub_calc_psd_complex_phase_4sc(bunix_1,cov_b__24)
;;  Define cross-spectra
crsp_12        = crsp_str_12.FFT__PSD
crsp_13        = crsp_str_13.FFT__PSD
crsp_14        = crsp_str_14.FFT__PSD
crsp_23        = crsp_str_23.FFT__PSD
crsp_24        = crsp_str_24.FFT__PSD
;;----------------------------------------------------------------------------------------
;;  Return only the positive frequency parts of each
;;----------------------------------------------------------------------------------------
;nn             = N_ELEMENTS(cvfbx12[*,0L])
;nind           = LINDGEN(nn[0]/2L + 1L)
crsp_12        = crsp_12[nind,*,*] & crsp_12 = crsp_12[*,nind,*]
crsp_13        = crsp_13[nind,*,*] & crsp_13 = crsp_13[*,nind,*]
crsp_14        = crsp_14[nind,*,*] & crsp_14 = crsp_14[*,nind,*]
crsp_23        = crsp_23[nind,*,*] & crsp_23 = crsp_23[*,nind,*]
crsp_24        = crsp_24[nind,*,*] & crsp_24 = crsp_24[*,nind,*]
;;----------------------------------------------------------------------------------------
;;  Group arrays
;;----------------------------------------------------------------------------------------
;;  Covariances
cvfb_12        = [[[cvfbx12]],[[cvfby12]],[[cvfbz12]]]
cvfb_13        = [[[cvfbx13]],[[cvfby13]],[[cvfbz13]]]
cvfb_14        = [[[cvfbx14]],[[cvfby14]],[[cvfbz14]]]
cvfb_23        = [[[cvfbx23]],[[cvfby23]],[[cvfbz23]]]
cvfb_24        = [[[cvfbx24]],[[cvfby24]],[[cvfbz24]]]
cvfb_11        = [[[cvfbx11]],[[cvfby11]],[[cvfbz11]]]
cvfb_22        = [[[cvfbx22]],[[cvfby22]],[[cvfbz22]]]
cvfb_33        = [[[cvfbx33]],[[cvfby33]],[[cvfbz33]]]
cvfb_44        = [[[cvfbx44]],[[cvfby44]],[[cvfbz44]]]
;;  Phases
phib_12        = [[[phibx12]],[[phiby12]],[[phibz12]]]
phib_13        = [[[phibx13]],[[phiby13]],[[phibz13]]]
phib_14        = [[[phibx14]],[[phiby14]],[[phibz14]]]
phib_23        = [[[phibx23]],[[phiby23]],[[phibz23]]]
phib_24        = [[[phibx24]],[[phiby24]],[[phibz24]]]
;;  Coherence squared
gam2_12        = [[[gam2x12]],[[gam2y12]],[[gam2z12]]]
gam2_13        = [[[gam2x13]],[[gam2y13]],[[gam2z13]]]
gam2_14        = [[[gam2x14]],[[gam2y14]],[[gam2z14]]]
gam2_23        = [[[gam2x23]],[[gam2y23]],[[gam2z23]]]
gam2_24        = [[[gam2x24]],[[gam2y24]],[[gam2z24]]]
;;  Coherence
gamm_12        = [[[gammx12]],[[gammy12]],[[gammz12]]]
gamm_13        = [[[gammx13]],[[gammy13]],[[gammz13]]]
gamm_14        = [[[gammx14]],[[gammy14]],[[gammz14]]]
gamm_23        = [[[gammx23]],[[gammy23]],[[gammz23]]]
gamm_24        = [[[gammx24]],[[gammy24]],[[gammz24]]]
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
scpref_all     = 'SC'+['1','2','3','4']
cross_tags     = 'SC'+['12','13','14','23','24']
fft_strucs     = CREATE_STRUCT(scpref_all,fft_str_1,fft_str_2,fft_str_3,fft_str_4)
avv_strucs     = CREATE_STRUCT(scpref_all,mean_b1,mean_b2,mean_b3,mean_b4)
cov_tags       = [cross_tags,'SC'+['11','22','33','44']]
cov_strucs     = CREATE_STRUCT(cov_tags,cvfb_12,cvfb_13,cvfb_14,cvfb_23,cvfb_24,cvfb_11,cvfb_22,cvfb_33,cvfb_44)
phi_strucs     = CREATE_STRUCT(cross_tags,phib_12,phib_13,phib_14,phib_23,phib_24)
gm2_strucs     = CREATE_STRUCT(cross_tags,gam2_12,gam2_13,gam2_14,gam2_23,gam2_24)
gam_strucs     = CREATE_STRUCT(cross_tags,gamm_12,gamm_13,gamm_14,gamm_23,gamm_24)
crs_strucs     = CREATE_STRUCT(cross_tags,crsp_12,crsp_13,crsp_14,crsp_23,crsp_24)
tags           = ['FFT_STRUCS','AVG_VECS','COV_STRUCS','PHI_STRUCS','GM2_STRUCS','GAM_STRUCS','CROSS_SPEC']
struc          = CREATE_STRUCT(tags,fft_strucs,avv_strucs,cov_strucs,phi_strucs,gm2_strucs,gam_strucs,crs_strucs)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END






















