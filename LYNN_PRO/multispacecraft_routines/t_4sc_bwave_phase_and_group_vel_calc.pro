;*****************************************************************************************
;
;  FUNCTION :   t_sub_4sc_calc_fft_psd_and_freqs.pro
;  PURPOSE  :   Calculates the power spectral density of an input 3-vector array of data.
;
;  CALLED BY:   
;               t_4sc_bwave_phase_and_group_vel_calc.pro
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
;               fft_str = t_sub_4sc_calc_fft_psd_and_freqs(unix,vecs)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  User should not call this routine directly
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
;   CREATED:  09/21/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/21/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION t_sub_4sc_calc_fft_psd_and_freqs,unix,vecs

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
IF (nfbin_0[0] LT 1024L) THEN fn_on = 1b ELSE fn_on = 0b
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Zero pad the data
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
szdv           = SIZE(vecs,/DIMENSIONS)
sznv           = SIZE(vecs,/N_DIMENSIONS)
CASE sznv[0] OF
  2L    :  BEGIN
    IF (fn_on[0]) THEN vecsx = power_of_2(vecs[*,0],FORCE_N=1024L) ELSE vecsx = power_of_2(vecs[*,0])
    IF (fn_on[0]) THEN vecsy = power_of_2(vecs[*,1],FORCE_N=1024L) ELSE vecsy = power_of_2(vecs[*,1])
    IF (fn_on[0]) THEN vecsz = power_of_2(vecs[*,2],FORCE_N=1024L) ELSE vecsz = power_of_2(vecs[*,2])
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
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define FFT frequencies
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
nd             = nfbin_1[0]
n_m            = nd[0]/2L + 1L                              ;;  mid point element (i.e., where frequencies go negative in FFT)
frn            = nd[0] - n_m[0]
frel           = LINDGEN(frn[0]) + n_m[0]                   ;;  Elements for negative frequencies
fft_freq       = DINDGEN(nd[0])
fft_freq[frel] = (n_m[0] - nd[0]) + DINDGEN(n_m[0] - 2L)
fft_freq      *= (srate[0]/nd[0])
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate FFT
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

RETURN,struc
END


;*****************************************************************************************
;
;  FUNCTION :   t_sub_4sc_calc_complex_phase_4sc.pro
;  PURPOSE  :   Calculates the complex FFT, covariance, phase, and coherence between
;                 any two inputs from two different spacecraft.
;
;  CALLED BY:   
;               t_4sc_bwave_phase_and_group_vel_calc.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;               test_tplot_handle.pro
;               test_plot_axis_range.pro
;               get_data.pro
;               trange_clip_data.pro
;               t_get_struc_unix.pro
;               t_sub_4sc_calc_fft_psd_and_freqs.pro
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
;               struc = t_sub_4sc_calc_complex_phase_4sc(tpn_magf,tran_se [,DT_EXPND=dt_expnd])
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
;                                                                   [09/22/2021   v1.0.0]
;
;   NOTES:      
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
;               7)  Beall, J.M., Y.C. Kim, and E.J. Powers "Estimation of wavenumber and
;                      frequency spectra using fixed probe pairs," J. Appl. Phys. 53(6),
;                      pp. 3933--3940, doi:10.1063/1.331279, 1982.
;
;   CREATED:  09/21/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/22/2021   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************


FUNCTION t_sub_4sc_calc_complex_phase_4sc,tpn_magf,tran_se,DT_EXPND=dt_expnd

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
wdth           = 4L
;wdth           = [4L,4L]
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
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Get TPLOT data
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Trim off excess edge points
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate FFT of each
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
fft_str_1      = t_sub_4sc_calc_fft_psd_and_freqs(bunix_1,bgsev_1)
fft_str_2      = t_sub_4sc_calc_fft_psd_and_freqs(bunix_2,bgsev_2)
fft_str_3      = t_sub_4sc_calc_fft_psd_and_freqs(bunix_3,bgsev_3)
fft_str_4      = t_sub_4sc_calc_fft_psd_and_freqs(bunix_4,bgsev_4)
;;  Define relevant outputs
fftbxyz_1      = fft_str_1.FFT__PSD
fftbxyz_2      = fft_str_2.FFT__PSD
fftbxyz_3      = fft_str_3.FFT__PSD
fftbxyz_4      = fft_str_4.FFT__PSD
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate FFT covariance between any two signals:
;;    C_ij = < Xi* Xj >_t
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
cvfbx12        = SMOOTH(CONJ(fftbxyz_1[*,0]) * fftbxyz_2[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx13        = SMOOTH(CONJ(fftbxyz_1[*,0]) * fftbxyz_3[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx14        = SMOOTH(CONJ(fftbxyz_1[*,0]) * fftbxyz_4[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby12        = SMOOTH(CONJ(fftbxyz_1[*,1]) * fftbxyz_2[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfby13        = SMOOTH(CONJ(fftbxyz_1[*,1]) * fftbxyz_3[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfby14        = SMOOTH(CONJ(fftbxyz_1[*,1]) * fftbxyz_4[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz12        = SMOOTH(CONJ(fftbxyz_1[*,2]) * fftbxyz_2[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz13        = SMOOTH(CONJ(fftbxyz_1[*,2]) * fftbxyz_3[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz14        = SMOOTH(CONJ(fftbxyz_1[*,2]) * fftbxyz_4[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx23        = SMOOTH(CONJ(fftbxyz_2[*,0]) * fftbxyz_3[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx24        = SMOOTH(CONJ(fftbxyz_2[*,0]) * fftbxyz_4[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby23        = SMOOTH(CONJ(fftbxyz_2[*,1]) * fftbxyz_3[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfby24        = SMOOTH(CONJ(fftbxyz_2[*,1]) * fftbxyz_4[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz23        = SMOOTH(CONJ(fftbxyz_2[*,2]) * fftbxyz_3[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz24        = SMOOTH(CONJ(fftbxyz_2[*,2]) * fftbxyz_4[*,2],wdth,/NAN,/EDGE_TRUNCATE)
;;  Calculate the self covariance terms
cvfbx11        = SMOOTH(CONJ(fftbxyz_1[*,0]) * fftbxyz_1[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby11        = SMOOTH(CONJ(fftbxyz_1[*,1]) * fftbxyz_1[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz11        = SMOOTH(CONJ(fftbxyz_1[*,2]) * fftbxyz_1[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx22        = SMOOTH(CONJ(fftbxyz_2[*,0]) * fftbxyz_2[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby22        = SMOOTH(CONJ(fftbxyz_2[*,1]) * fftbxyz_2[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz22        = SMOOTH(CONJ(fftbxyz_2[*,2]) * fftbxyz_2[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx33        = SMOOTH(CONJ(fftbxyz_3[*,0]) * fftbxyz_3[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby33        = SMOOTH(CONJ(fftbxyz_3[*,1]) * fftbxyz_3[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz33        = SMOOTH(CONJ(fftbxyz_3[*,2]) * fftbxyz_3[*,2],wdth,/NAN,/EDGE_TRUNCATE)
cvfbx44        = SMOOTH(CONJ(fftbxyz_4[*,0]) * fftbxyz_4[*,0],wdth,/NAN,/EDGE_TRUNCATE)
cvfby44        = SMOOTH(CONJ(fftbxyz_4[*,1]) * fftbxyz_4[*,1],wdth,/NAN,/EDGE_TRUNCATE)
cvfbz44        = SMOOTH(CONJ(fftbxyz_4[*,2]) * fftbxyz_4[*,2],wdth,/NAN,/EDGE_TRUNCATE)
;;----------------------------------------------------------------------------------------
;;  Return only the positive frequency parts of each
;;----------------------------------------------------------------------------------------
nn             = N_ELEMENTS(cvfbx12[*,0L])
nind           = LINDGEN(nn[0]/2L + 1L)
cvfbx12        = cvfbx12[nind] & cvfbz24 = cvfbz24[nind]
cvfbx13        = cvfbx13[nind] & cvfbx11 = cvfbx11[nind]
cvfbx14        = cvfbx14[nind] & cvfby11 = cvfby11[nind]
cvfby12        = cvfby12[nind] & cvfbz11 = cvfbz11[nind]
cvfby13        = cvfby13[nind] & cvfbx22 = cvfbx22[nind]
cvfby14        = cvfby14[nind] & cvfby22 = cvfby22[nind]
cvfbz12        = cvfbz12[nind] & cvfbz22 = cvfbz22[nind]
cvfbz13        = cvfbz13[nind] & cvfbx33 = cvfbx33[nind]
cvfbz14        = cvfbz14[nind] & cvfby33 = cvfby33[nind]
cvfbx23        = cvfbx23[nind] & cvfbz33 = cvfbz33[nind]
cvfbx24        = cvfbx24[nind] & cvfbx44 = cvfbx44[nind]
cvfby23        = cvfby23[nind] & cvfby44 = cvfby44[nind]
cvfby24        = cvfby24[nind] & cvfbz44 = cvfbz44[nind]
cvfbz23        = cvfbz23[nind]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate FFT phase between any two signals:
;;    phi_ij = ArcTan(Im[Xi],Re[Xj])
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
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
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate coherence between any two signals:
;;    gamma_ij^2 =|C_ij|^2/[ |C_ii| |C_jj| ]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
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
;;  Values > 1.0 are "bad" --> remove
bad_x12        = WHERE(ABS(gammx12) GT 1 OR gammx12 LT 0,bd_x12)
bad_x13        = WHERE(ABS(gammx13) GT 1 OR gammx13 LT 0,bd_x13)
bad_x14        = WHERE(ABS(gammx14) GT 1 OR gammx14 LT 0,bd_x14)
bad_y12        = WHERE(ABS(gammy12) GT 1 OR gammy12 LT 0,bd_y12)
bad_y13        = WHERE(ABS(gammy13) GT 1 OR gammy13 LT 0,bd_y13)
bad_y14        = WHERE(ABS(gammy14) GT 1 OR gammy14 LT 0,bd_y14)
bad_z12        = WHERE(ABS(gammz12) GT 1 OR gammz12 LT 0,bd_z12)
bad_z13        = WHERE(ABS(gammz13) GT 1 OR gammz13 LT 0,bd_z13)
bad_z14        = WHERE(ABS(gammz14) GT 1 OR gammz14 LT 0,bd_z14)
bad_x23        = WHERE(ABS(gammx23) GT 1 OR gammx23 LT 0,bd_x23)
bad_x24        = WHERE(ABS(gammx24) GT 1 OR gammx24 LT 0,bd_x24)
bad_y23        = WHERE(ABS(gammy23) GT 1 OR gammy23 LT 0,bd_y23)
bad_y24        = WHERE(ABS(gammy24) GT 1 OR gammy24 LT 0,bd_y24)
bad_z23        = WHERE(ABS(gammz23) GT 1 OR gammz23 LT 0,bd_z23)
bad_z24        = WHERE(ABS(gammz24) GT 1 OR gammz24 LT 0,bd_z24)
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
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Group arrays
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Covariances
cvfb_12        = [[cvfbx12],[cvfby12],[cvfbz12]]
cvfb_13        = [[cvfbx13],[cvfby13],[cvfbz13]]
cvfb_14        = [[cvfbx14],[cvfby14],[cvfbz14]]
cvfb_23        = [[cvfbx23],[cvfby23],[cvfbz23]]
cvfb_24        = [[cvfbx24],[cvfby24],[cvfbz24]]
cvfb_11        = [[cvfbx11],[cvfby11],[cvfbz11]]
cvfb_22        = [[cvfbx22],[cvfby22],[cvfbz22]]
cvfb_33        = [[cvfbx33],[cvfby33],[cvfbz33]]
cvfb_44        = [[cvfbx44],[cvfby44],[cvfbz44]]
;;  Phases
phib_12        = [[phibx12],[phiby12],[phibz12]]
phib_13        = [[phibx13],[phiby13],[phibz13]]
phib_14        = [[phibx14],[phiby14],[phibz14]]
phib_23        = [[phibx23],[phiby23],[phibz23]]
phib_24        = [[phibx24],[phiby24],[phibz24]]
;;  Coherence squared
gam2_12        = [[gam2x12],[gam2y12],[gam2z12]]
gam2_13        = [[gam2x13],[gam2y13],[gam2z13]]
gam2_14        = [[gam2x14],[gam2y14],[gam2z14]]
gam2_23        = [[gam2x23],[gam2y23],[gam2z23]]
gam2_24        = [[gam2x24],[gam2y24],[gam2z24]]
;;  Coherence
gamm_12        = [[gammx12],[gammy12],[gammz12]]
gamm_13        = [[gammx13],[gammy13],[gammz13]]
gamm_14        = [[gammx14],[gammy14],[gammz14]]
gamm_23        = [[gammx23],[gammy23],[gammz23]]
gamm_24        = [[gammx24],[gammy24],[gammz24]]
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
;crs_strucs     = CREATE_STRUCT(cross_tags,crsp_12,crsp_13,crsp_14,crsp_23,crsp_24)
tags           = ['FFT_STRUCS','AVG_VECS','COV_STRUCS','PHI_STRUCS','GM2_STRUCS','GAM_STRUCS']
struc          = CREATE_STRUCT(tags,fft_strucs,avv_strucs,cov_strucs,phi_strucs,gm2_strucs,gam_strucs)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END


;*****************************************************************************************
;
;  FUNCTION :   t_sub_4sc_calc_kmag_proj_ij.pro
;  PURPOSE  :   This routine calculates the projection of the wavenumber along the
;                 displacement vectors between any two spacecraft, ∆r_ij, for the kth
;                 field component.
;
;  CALLED BY:   
;               t_4sc_bwave_phase_and_group_vel_calc.pro
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;               is_a_number.pro
;               unit_vec.pro
;               lbw_diff.pro
;               mag__vec.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               CMPLX_STR  :  Scalar [structure] returned by t_sub_4sc_calc_complex_phase_4sc.pro
;               VGR_STR    :  Scalar [structure] returned by t_4sc_bwave_group_vel_calc.pro
;
;  EXAMPLES:    
;               [calling sequence]
;               kstr = t_sub_4sc_calc_kmag_proj_ij(cmplx_str,vgr_str [,VBULK=vbulk] [,DELVB=delvb] $
;                                                  [,K_VEC=k_vec] [,DKVEC=dkvec])
;
;  KEYWORDS:    
;               VBULK        :  [3]-Element [numeric] array defining the plasma bulk
;                                 flow velocity to use to convert the spacecraft frame
;                                 group speed to the plasma rest frame speed [km/s]
;                                 [Default = [0,0,0]]
;               DELVB        :  [3]-Element [numeric] array defining the uncertainty in
;                                 VBULK [km/s]
;                                 [Default = [0,0,0]]
;               K_VEC        :  [4,3]-Element [numeric] array defining the wave unit
;                                 vector determined from minimum variance analysis
;                                 [Default = FALSE]
;               DKVEC        :  [4,3]-Element [numeric] array defining the uncertainty in
;                                 the wave unit vector determined from minimum variance
;                                 analysis
;                                 [Default = 10% of K_VEC]
;
;   CHANGED:  1)  Added to output structure
;                                                                   [02/03/2022   v1.0.1]
;
;   NOTES:      
;               1)  This routine uses LU decomposition
;                     A . X = B
;                       A_ijm = (∆r_ij)_m
;                       B_ijm = (t_i - t_j)_m
;                       X     = (g/|g|)/V_gr,sc
;               2)  ∆r . k = V_gr,sc ∆t
;                       V_gr,sc         = 1/|X|
;                       (k/|k|)         = X/|X|
;                       V_gr,sc         = V_gr + Vsw
;                       V_gr            = V_gr,sc - Vsw
;               3)  ICB  =  Input Coordinate Basis
;               4)  Coordinate Systems
;                     SPG    :  Spinning Probe Geometric
;                     SSL    :  Spinning Sun-Sensor L-Vector
;                     DSL    :  Despun Sun-L-VectorZ (THEMIS and MMS Mission)
;                     BCS    :  Body Coordinate System (MMS Mission)
;                     DBCS   :  despun-BCS (MMS Mission)
;                     SMPA   :  Spinning, Major Principal Axis (MMS Mission)
;                     DMPA   :  Despun, Major Principal Axis (MMS Mission)
;                     GEI    :  Geocentric Equatorial Inertial
;                     GEO    :  Geographic
;                     GSE    :  Geocentric Solar Ecliptic
;                     GSM    :  Geocentric Solar Magnetospheric
;                     ICB    :  Input Coordinate Basis (e.g., GSE)
;               5)  Calculate of the cross spectral density or spectral covariance
;                     starts by defining the FFT of the jth field component from the
;                     ith spacecraft, S_i,j, so that we have:
;
;                       C_ik,j = < S_i,j* S_k,j >_t
;
;                     where * denotes the complex conjugate and <>_t denotes the
;                     temporal ensemble average.  From this, we can calculate the complex
;                     phase between the signals from two spacecraft given as:
;
;                       Phi_ik,j = ATAN( Im[ C_ik,j ] / Re[ C_ik,j ] )
;
;                     We can also calculate the complex coherency spectrum given as:
;
;                       Gamma_ik,j^2 = |C_ik,j|/( |C_ii,j|  |C_kk,j| )
;
;                     where in general 0.0 ≤ Gamma_ik,j ≤ 1.0 must be true.
;
;                     If we define the time lag between any two spacecraft as ∆t_ik and
;                     the displacement vector as ∆r_ik, then we can define:
;
;                       |k_ik| = | k . ∆r_ik |
;
;                     as the magnitude of the projection of k along ∆r_ik.  We can use
;                     the Doppler-shift equation and our knowledge of the complex phase
;                     to determine |k_ik| without having to assume a form for the
;                     dispersion relation given by:
;
;                                               { Phi_ik,j + w_sc ∆t_ik }
;                       |k_ik|_j = ------------------------------------------------------
;                                  { |∆r_ik| Cos(theta_k∆r) + Vbulk ∆t_ik Cos(theta_kV) }
;
;                     where w_sc is the spacecraft frame angular frequency, Vbulk is the
;                     magnitude of the solar wind velocity, theta_kV is the angle
;                     between k and Vbulk, and theta_k∆r is the angle between k and
;                     ∆r_ik.  We can determine these angles using previously determined
;                     minimum variance analysis (MVA) wave unit vectors.
;
;                     Once we determine |k_12|, |k_13|, and |k_24| we need to convert
;                     these to a physically meaningful coordinate basis.  We are starting
;                     in a non-orthonormal basis, so the rotation matrix given by:
;
;                           [ ∆r_12 ]
;                     R   = [ ∆r_13 ]
;                           [ ∆r_24 ]
;
;                     does not rotate from the orthonormal to non-orthonormal basis.  The
;                     correct rotation matrix to get from the non-orthonormal basis to
;                     the orthonormal one is the inverse of R, i.e., A = (R^(-1))^(T).
;                     Applying A to a quasi-3-vector comprised of |k_12|, |k_13|, and
;                     |k_24| will return k in the ICB.
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
;               7)  Beall, J.M., Y.C. Kim, and E.J. Powers "Estimation of wavenumber and
;                      frequency spectra using fixed probe pairs," J. Appl. Phys. 53(6),
;                      pp. 3933--3940, doi:10.1063/1.331279, 1982.
;
;   CREATED:  02/02/2022
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/03/2022   v1.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION t_sub_4sc_calc_kmag_proj_ij,cmplx_str,vgr_str,VBULK=vbulk,DELVB=delvb,      $
                                     K_VEC=k_vec,DKVEC=dkvec

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Error messages
noinput_mssg   = 'No input was supplied...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = ((N_PARAMS() LT 2) OR (SIZE(cmplx_str,/TYPE) NE 8) OR (SIZE(vgr_str,/TYPE) NE 8))
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check VBULK
test           = (is_a_3_vector(vbulk,V_OUT=vswo ,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  vbulk_on = 0b
  delvb_on = 0b
  vswo     = REPLICATE(0d0,3L)
ENDIF ELSE BEGIN
  ;;  VBULK is on --> check if it's properly used
  vswo     = REFORM(vswo)
  vbulk_on = (TOTAL(FINITE(vswo)) EQ 3)
  IF (vbulk_on[0]) THEN BEGIN
    ;;  Check DELVB
    test   = (is_a_3_vector(delvb,V_OUT=dvsw ,/NOMSSG) EQ 0)
    IF (test[0]) THEN BEGIN
      delvb_on = 0b
    ENDIF ELSE BEGIN
      dvsw     = ABS(REFORM(dvsw))
      delvb_on = (TOTAL(FINITE(dvsw)) EQ 3)
    ENDELSE
  ENDIF ELSE delvb_on = 0b
ENDELSE
;;  Check K_VEC
test           = (is_a_3_vector(k_vec,V_OUT=kkvec,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  k_vec_on = 0b
  dkvec_on = 0b
  kkvec    = REPLICATE(0d0,3L)
ENDIF ELSE BEGIN
  ;;  K_VEC is on --> check if it's properly used
  kkvec    = REFORM(kkvec)
  k_vec_on = (TOTAL(FINITE(kkvec)) MOD 3) EQ 0
  IF (k_vec_on[0]) THEN BEGIN
    ;;  Check DKVEC
    test   = (is_a_3_vector(dkvec,V_OUT=dkkvc,/NOMSSG) EQ 0)
    IF (test[0]) THEN BEGIN
      dkvec_on = 0b
    ENDIF ELSE BEGIN
      dkkvc    = ABS(REFORM(dkkvc))
      dkvec_on = (TOTAL(FINITE(dkkvc)) EQ 3)
    ENDELSE
  ENDIF ELSE dkvec_on = 0b
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define theta_kV
;;----------------------------------------------------------------------------------------
IF (~k_vec_on[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  No phase information can be derived without khat --> define dummy variables
  ;;--------------------------------------------------------------------------------------
  STOP
ENDIF ELSE BEGIN
  IF (vbulk_on[0] OR k_vec_on[0]) THEN BEGIN
    IF (vbulk_on[0] AND k_vec_on[0]) THEN BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Both are set
      ;;----------------------------------------------------------------------------------
      thkv_1         = REPLICATE(d,2L)
      thkv_2         = thkv_1
      thkv_3         = thkv_1
      thkv_4         = thkv_1
      ;;  Define preliminary values
      thkv_1[0]      = ACOS(TOTAL(unit_vec(kkvec[0,*],/NAN)*unit_vec(vswo,/NAN)))
      thkv_2[0]      = ACOS(TOTAL(unit_vec(kkvec[1,*],/NAN)*unit_vec(vswo,/NAN)))
      thkv_3[0]      = ACOS(TOTAL(unit_vec(kkvec[2,*],/NAN)*unit_vec(vswo,/NAN)))
      thkv_4[0]      = ACOS(TOTAL(unit_vec(kkvec[3,*],/NAN)*unit_vec(vswo,/NAN)))
      thkv_1[1]      = !DPI - thkv_1[0]
      thkv_2[1]      = !DPI - thkv_2[0]
      thkv_3[1]      = !DPI - thkv_3[0]
      thkv_4[1]      = !DPI - thkv_4[0]
      IF (delvb_on[0] OR dkvec_on[0]) THEN BEGIN
        IF (delvb_on[0] AND dkvec_on[0]) THEN BEGIN
          ;;------------------------------------------------------------------------------
          ;;  Both are set
          ;;------------------------------------------------------------------------------
        ENDIF ELSE BEGIN
          ;;------------------------------------------------------------------------------
          ;;  Only one is set
          ;;------------------------------------------------------------------------------
        ENDELSE
      ENDIF ELSE BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Neither uncertainty is set --> Don't change preliminary values
        ;;--------------------------------------------------------------------------------
      ENDELSE
    ENDIF ELSE BEGIN
      ;;----------------------------------------------------------------------------------
      ;;  Only one is set
      ;;----------------------------------------------------------------------------------
      STOP
;      IF (~k_vec_on[0]) THEN STOP
    ENDELSE
  ENDIF ELSE BEGIN
    ;;------------------------------------------------------------------------------------
    ;;  Assume the worst --> k is either parallel or anti-parallel to V
    ;;------------------------------------------------------------------------------------
    thkv_1         = [0d0,!DPI]
    thkv_2         = thkv_1
    thkv_3         = thkv_1
    thkv_4         = thkv_1
  ENDELSE
ENDELSE
;;  Make sure to sort
thkv_1         = thkv_1[SORT(thkv_1)]
thkv_2         = thkv_2[SORT(thkv_2)]
thkv_3         = thkv_3[SORT(thkv_3)]
thkv_4         = thkv_4[SORT(thkv_4)]
thkv_a         = [[thkv_1],[thkv_2],[thkv_3],[thkv_4]]
;;  Define Cos(theta_kV)
costhkv_1      = COS(thkv_1)
costhkv_2      = COS(thkv_2)
costhkv_3      = COS(thkv_3)
costhkv_4      = COS(thkv_4)
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters from group stuff
;;----------------------------------------------------------------------------------------
;;  Define proper shift value and corresponding array index (i.e., determines time lag)
jshft_arr      = [0L,vgr_str.CC_SHIFT_ARR]
scpos_arr      = vgr_str.SC_POSI
unix__arr      = vgr_str.UNIX
mx_cc_ij       = vgr_str.MAX_CC_IJ                ;;  Maximum correlation coefficient for SC pair ij for k-th field component
mx_ci_ij       = vgr_str.MAX_CC_IND               ;;  Index informing user of which B-field component has the best CC [12,13,14,24]
;;----------------------------------------------------------------------------------------
;;  Define differences
;;----------------------------------------------------------------------------------------
;;  ∆r_ij = r_i - r_j
dr_12_all      = MEDIAN(lbw_diff(REFORM(scpos_arr[*,0L,*]),REFORM(scpos_arr[*,1L,*]),/NAN),DIMENSION=1)
dr_13_all      = MEDIAN(lbw_diff(REFORM(scpos_arr[*,0L,*]),REFORM(scpos_arr[*,2L,*]),/NAN),DIMENSION=1)
dr_24_all      = MEDIAN(lbw_diff(REFORM(scpos_arr[*,4L,*]),REFORM(scpos_arr[*,3L,*]),/NAN),DIMENSION=1)
;;  ∆t_ij = t_i - t_j [s]
dt_12_all      = MEDIAN(lbw_diff(REFORM(unix__arr[*,0L]),REFORM(unix__arr[*,1L]),/NAN))
dt_13_all      = MEDIAN(lbw_diff(REFORM(unix__arr[*,0L]),REFORM(unix__arr[*,2L]),/NAN))
dt_24_all      = MEDIAN(lbw_diff(REFORM(unix__arr[*,4L]),REFORM(unix__arr[*,3L]),/NAN))
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters from complex phase stuff
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define FFT frequencies [Hz]
fft_freq_1     = cmplx_str.FFT_STRUCS.SC1.FFT_FREQ
nn             = N_ELEMENTS(fft_freq_1)
fft_freq_1     = fft_freq_1[0L:(nn[0]/2L)]
n1             = N_ELEMENTS(fft_freq_1)
;;  Define FFT phase [rad] between any two signals:  phi_ij = ArcTan(Im[Xi],Re[Xj])
phibx12        = cmplx_str.PHI_STRUCS.SC12[*,0]
phiby12        = cmplx_str.PHI_STRUCS.SC12[*,1]
phibz12        = cmplx_str.PHI_STRUCS.SC12[*,2]
phibx13        = cmplx_str.PHI_STRUCS.SC13[*,0]
phiby13        = cmplx_str.PHI_STRUCS.SC13[*,1]
phibz13        = cmplx_str.PHI_STRUCS.SC13[*,2]
phibx24        = cmplx_str.PHI_STRUCS.SC24[*,0]
phiby24        = cmplx_str.PHI_STRUCS.SC24[*,1]
phibz24        = cmplx_str.PHI_STRUCS.SC24[*,2]
nfft           = N_ELEMENTS(phibx12)
;;  Define FFT covariance between any two signals:
;;    C_ij = < Xi* Xj >_t
cvfbx12        = EXP(SMOOTH(ALOG(ABS(cmplx_str.COV_STRUCS.SC12[*,0])),4L,/NAN,/EDGE_TRUNCATE))
cvfby12        = EXP(SMOOTH(ALOG(ABS(cmplx_str.COV_STRUCS.SC12[*,1])),4L,/NAN,/EDGE_TRUNCATE))
cvfbz12        = EXP(SMOOTH(ALOG(ABS(cmplx_str.COV_STRUCS.SC12[*,2])),4L,/NAN,/EDGE_TRUNCATE))
cvfbx13        = EXP(SMOOTH(ALOG(ABS(cmplx_str.COV_STRUCS.SC13[*,0])),4L,/NAN,/EDGE_TRUNCATE))
cvfby13        = EXP(SMOOTH(ALOG(ABS(cmplx_str.COV_STRUCS.SC13[*,1])),4L,/NAN,/EDGE_TRUNCATE))
cvfbz13        = EXP(SMOOTH(ALOG(ABS(cmplx_str.COV_STRUCS.SC13[*,2])),4L,/NAN,/EDGE_TRUNCATE))
cvfbx24        = EXP(SMOOTH(ALOG(ABS(cmplx_str.COV_STRUCS.SC24[*,0])),4L,/NAN,/EDGE_TRUNCATE))
cvfby24        = EXP(SMOOTH(ALOG(ABS(cmplx_str.COV_STRUCS.SC24[*,1])),4L,/NAN,/EDGE_TRUNCATE))
cvfbz24        = EXP(SMOOTH(ALOG(ABS(cmplx_str.COV_STRUCS.SC24[*,2])),4L,/NAN,/EDGE_TRUNCATE))
;;  Define coherence between any two signals:
;;    gamma_ij = { |C_ij|^2/[ |C_ii| |C_jj| ] }^(1/2)
gammx12        = cmplx_str.GAM_STRUCS.SC12[*,0]
gammy12        = cmplx_str.GAM_STRUCS.SC12[*,1]
gammz12        = cmplx_str.GAM_STRUCS.SC12[*,2]
gammx13        = cmplx_str.GAM_STRUCS.SC13[*,0]
gammy13        = cmplx_str.GAM_STRUCS.SC13[*,1]
gammz13        = cmplx_str.GAM_STRUCS.SC13[*,2]
gammx24        = cmplx_str.GAM_STRUCS.SC24[*,0]
gammy24        = cmplx_str.GAM_STRUCS.SC24[*,1]
gammz24        = cmplx_str.GAM_STRUCS.SC24[*,2]
;;  Calculate theta_kr_ij = ArcCos(k . ∆r_ij)
costhkr_p1_12  = TOTAL(unit_vec(kkvec[0,*],/NAN)*unit_vec(dr_12_all,/NAN))
costhkr_m1_12  = TOTAL(-1d0*unit_vec(kkvec[0,*],/NAN)*unit_vec(dr_12_all,/NAN))
costhkr_p1_13  = TOTAL(unit_vec(kkvec[0,*],/NAN)*unit_vec(dr_13_all,/NAN))
costhkr_m1_13  = TOTAL(-1d0*unit_vec(kkvec[0,*],/NAN)*unit_vec(dr_13_all,/NAN))
costhkr_p1_24  = TOTAL(unit_vec(kkvec[0,*],/NAN)*unit_vec(dr_24_all,/NAN))
costhkr_m1_24  = TOTAL(-1d0*unit_vec(kkvec[0,*],/NAN)*unit_vec(dr_24_all,/NAN))
;;----------------------------------------------------------------------------------------
;;  Calculate denominator
;;    ∆r_ij Cos(the_krij) + |Vsw| ∆t Cos(the_kVij)
;;----------------------------------------------------------------------------------------
vbulk_mag      = (mag__vec(vswo,/NAN))[0]
;;  SC12
term0_p1_12    = (mag__vec(dr_12_all,/NAN))[0]*costhkr_p1_12[0]
term1_p1_12    = vbulk_mag[0]*dt_12_all[0]*costhkv_1[0L]
term0_m1_12    = (mag__vec(dr_12_all,/NAN))[0]*costhkr_m1_12[0]
term1_m1_12    = vbulk_mag[0]*dt_12_all[0]*costhkv_1[1L]
denom_p1_12    = term0_p1_12 + term1_p1_12
denom_m1_12    = term0_m1_12 + term1_m1_12
;;  SC13
term0_p1_13    = (mag__vec(dr_13_all,/NAN))[0]*costhkr_p1_13[0]
term0_m1_13    = (mag__vec(dr_13_all,/NAN))[0]*costhkr_m1_13[0]
term1_p1_13    = vbulk_mag[0]*dt_13_all[0]*costhkv_1[0L]
term1_m1_13    = vbulk_mag[0]*dt_13_all[0]*costhkv_1[1L]
denom_p1_13    = term0_p1_13 + term1_p1_13
denom_m1_13    = term0_m1_13 + term1_m1_13
;;  SC24
term0_p1_24    = (mag__vec(dr_24_all,/NAN))[0]*costhkr_p1_24[0]
term0_m1_24    = (mag__vec(dr_24_all,/NAN))[0]*costhkr_m1_24[0]
term1_p1_24    = vbulk_mag[0]*dt_24_all[0]*costhkv_2[0L]
term1_m1_24    = vbulk_mag[0]*dt_24_all[0]*costhkv_2[1L]
denom_p1_24    = term0_p1_24 + term1_p1_24
denom_m1_24    = term0_m1_24 + term1_m1_24
;;----------------------------------------------------------------------------------------
;;  Calculate numerator
;;    phi_ij + wsc * ∆t_ij
;;----------------------------------------------------------------------------------------
;;  Initialize numerator
numer_x1_12    = phibx12 + fft_freq_1*dt_12_all[0]
numer_y1_12    = phiby12 + fft_freq_1*dt_12_all[0]
numer_z1_12    = phibz12 + fft_freq_1*dt_12_all[0]
numer_x1_13    = phibx13 + fft_freq_1*dt_13_all[0]
numer_y1_13    = phiby13 + fft_freq_1*dt_13_all[0]
numer_z1_13    = phibz13 + fft_freq_1*dt_13_all[0]
numer_x1_24    = phibx24 + fft_freq_1*dt_24_all[0]
numer_y1_24    = phiby24 + fft_freq_1*dt_24_all[0]
numer_z1_24    = phibz24 + fft_freq_1*dt_24_all[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate |k| [km^(-1)]
;;    |k|_ij = [phi_ij + wsc * ∆t_ij]/[∆r_ij Cos(the_krij) + |Vsw| ∆t Cos(the_kVij)]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  XYZ labels below correspond to component of field from which the spectral values were
;;    computed, not the component of the resultant wave vector.  The latter is determined
;;    by the projection onto the SC separation vector here, so currently the wave vector
;;    is defined in a non-orthogonal coordinate system and needs to be corrected (below).
;;  SC12
kmag_xp1_12    = numer_x1_12/denom_p1_12[0]
kmag_yp1_12    = numer_y1_12/denom_p1_12[0]
kmag_zp1_12    = numer_z1_12/denom_p1_12[0]
kmag_xm1_12    = numer_x1_12/denom_m1_12[0]
kmag_ym1_12    = numer_y1_12/denom_m1_12[0]
kmag_zm1_12    = numer_z1_12/denom_m1_12[0]
;;  SC13
kmag_xp1_13    = numer_x1_13/denom_p1_13[0]
kmag_yp1_13    = numer_y1_13/denom_p1_13[0]
kmag_zp1_13    = numer_z1_13/denom_p1_13[0]
kmag_xm1_13    = numer_x1_13/denom_m1_13[0]
kmag_ym1_13    = numer_y1_13/denom_m1_13[0]
kmag_zm1_13    = numer_z1_13/denom_m1_13[0]
;;  SC24
kmag_xp1_24    = numer_x1_24/denom_p1_24[0]
kmag_yp1_24    = numer_y1_24/denom_p1_24[0]
kmag_zp1_24    = numer_z1_24/denom_p1_24[0]
kmag_xm1_24    = numer_x1_24/denom_m1_24[0]
kmag_ym1_24    = numer_y1_24/denom_m1_24[0]
kmag_zm1_24    = numer_z1_24/denom_m1_24[0]
;;----------------------------------------------------------------------------------------
;;  Convert phase to degrees and force range 0 ≤ phi_ij ≤ 360 deg
;;----------------------------------------------------------------------------------------
;;  SC12
phibx12        = (phibx12*18d1/!DPI + 36d1) MOD 36d1
phiby12        = (phiby12*18d1/!DPI + 36d1) MOD 36d1
phibz12        = (phibz12*18d1/!DPI + 36d1) MOD 36d1
;;  SC13
phibx13        = (phibx13*18d1/!DPI + 36d1) MOD 36d1
phiby13        = (phiby13*18d1/!DPI + 36d1) MOD 36d1
phibz13        = (phibz13*18d1/!DPI + 36d1) MOD 36d1
;;  SC24
phibx24        = (phibx24*18d1/!DPI + 36d1) MOD 36d1
phiby24        = (phiby24*18d1/!DPI + 36d1) MOD 36d1
phibz24        = (phibz24*18d1/!DPI + 36d1) MOD 36d1
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define rotation matrix
;;    Rotate from a non-orthogonal to an orthogonal coordinate system
;;      k_i = A_ij . k_ij
;;    where A = B^(T) and B = R^(-1), where
;;          [ ∆r12 ]
;;      R = [ ∆r13 ]
;;          [ ∆r24 ]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
avec1          = unit_vec(dr_12_all,/NAN)
avec2          = unit_vec(dr_13_all,/NAN)
avec3          = unit_vec(dr_24_all,/NAN)
t_rot          = [avec1,avec2,avec3]
b_rot          = LA_INVERT(t_rot,/DOUBLE,STATUS=status)
a_rot          = TRANSPOSE(b_rot)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tags           = 'SC'+['12','13','24']
kmpx_str       = CREATE_STRUCT(tags,kmag_xp1_12,kmag_xp1_13,kmag_xp1_24)
kmpy_str       = CREATE_STRUCT(tags,kmag_yp1_12,kmag_yp1_13,kmag_yp1_24)
kmpz_str       = CREATE_STRUCT(tags,kmag_zp1_12,kmag_zp1_13,kmag_zp1_24)
kmmx_str       = CREATE_STRUCT(tags,kmag_xm1_12,kmag_xm1_13,kmag_xm1_24)
kmmy_str       = CREATE_STRUCT(tags,kmag_ym1_12,kmag_ym1_13,kmag_ym1_24)
kmmz_str       = CREATE_STRUCT(tags,kmag_zm1_12,kmag_zm1_13,kmag_zm1_24)
phix_str       = CREATE_STRUCT(tags,phibx12,phibx13,phibx24)
phiy_str       = CREATE_STRUCT(tags,phiby12,phiby13,phiby24)
phiz_str       = CREATE_STRUCT(tags,phibz12,phibz13,phibz24)
delt_str       = CREATE_STRUCT(tags,dt_12_all,dt_13_all,dt_24_all)
delr_str       = CREATE_STRUCT(tags,dr_12_all,dr_13_all,dr_24_all)
tags           = 'B'+['X','Y','Z']
kmpa_str       = CREATE_STRUCT(tags,kmpx_str,kmpy_str,kmpz_str)
kmma_str       = CREATE_STRUCT(tags,kmmx_str,kmmy_str,kmmz_str)
phia_str       = CREATE_STRUCT(tags,phix_str,phiy_str,phiz_str)
tags           = ['PHASE','WAVENUMBER'+['_P','_M'],'FFT_F_SCF','THETA_KV','ROT_MAT','A_MAT','DELTA_T_IJ','DELTA_R_IJ']
struc          = CREATE_STRUCT(tags,phia_str,kmpa_str,kmma_str,fft_freq_1,thkv_a,b_rot,a_rot,delt_str,delr_str)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END


;+
;*****************************************************************************************
;
;  FUNCTION :   t_4sc_bwave_phase_and_group_vel_calc.pro
;  PURPOSE  :   This routine takes the TPLOT handles associated with spacecraft positions
;                 and magnetic fields, from at least 4 spacecraft, to calculate the
;                 phase and group speeds (and unit vectors) of the waves within the user
;                 defined time ranges from each spacecraft.  This requires that the user
;                 provide the bulk flow velocity of the plasma to determine rest frame
;                 parameters.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               t_sub_4sc_calc_fft_psd_and_freqs.pro
;               t_sub_4sc_calc_complex_phase_4sc.pro
;               t_sub_4sc_calc_kmag_proj_ij.pro
;
;  CALLS:
;               is_a_number.pro
;               test_tplot_handle.pro
;               is_a_3_vector.pro
;               test_plot_axis_range.pro
;               t_4sc_bwave_group_vel_calc.pro
;               get_data.pro
;               t_get_struc_unix.pro
;               store_data.pro
;               t_sub_4sc_calc_complex_phase_4sc.pro
;               unit_vec.pro
;               lbw_diff.pro
;               mag__vec.pro
;               lbw_window.pro
;               calc_1var_stats.pro
;               str_element.pro
;               num2flt_str.pro
;               file_name_times.pro
;               popen.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TPN_POSI     :  [4]-Element [string] array defining set and valid TPLOT
;                                 handles associated with spacecraft positions all in
;                                 the same coordinate basis
;               TPN_MAGF     :  [4]-Element [string] array defining set and valid TPLOT
;                                 handles associated with magnetic field data all in
;                                 the same coordinate basis
;               TRAN_SE      :  [4,2]-Element [double] array defining the time stamps of
;                                 points of interest to use for calculating the normal
;                                 unit vector.
;
;  EXAMPLES:    
;               [calling sequence]
;               struc = t_4sc_bwave_phase_and_group_vel_calc(tpn_posi,tpn_magf,tran_se   $
;                                  [,PERTDT=pertdt] [,VBULK=vbulk] [,DELVB=delvb]        $
;                                  [,FRAN=fran] [,K_VEC=k_vec] [,DKVEC=dkvec]            $
;                                  [,CHTHRSH=chthrsh] [,BCOMP=bcomp]                     $
;                                  [,/NOMSSG] [,/SAVEF] )
;
;  KEYWORDS:    
;               PERTDT       :  Scalar [numeric] defining the delta-t for the perturbing
;                                 time stamps about the time of interest
;                                 [Default = 0.01]
;               VBULK        :  [3]-Element [numeric] array defining the plasma bulk
;                                 flow velocity to use to convert the spacecraft frame
;                                 group speed to the plasma rest frame speed [km/s]
;                                 [Default = [0,0,0]]
;               DELVB        :  [3]-Element [numeric] array defining the uncertainty in
;                                 VBULK [km/s]
;                                 [Default = [0,0,0]]
;               FRAN         :  [2]-Element [numeric] array defining the range of
;                                 frequencies to use to filter the data before applying
;                                 the cross-correlation algorithm
;                                 [Default = FALSE]
;               K_VEC        :  [4,3]-Element [numeric] array defining the wave unit
;                                 vector determined from minimum variance analysis
;                                 [Default = FALSE]
;               DKVEC        :  [4,3]-Element [numeric] array defining the uncertainty in
;                                 the wave unit vector determined from minimum variance
;                                 analysis
;                                 [Default = 10% of K_VEC]
;               CHTHRSH      :  Scalar [numeric] defining the minimum complex coherency
;                                 allowed in finding the output solutions for |k_ij|
;                                 etc.  Allowed values satisfy:  0.6000--0.9999
;                                 [Default = 0.6]
;               BCOMP        :  Scalar [integer] defining the field component to use
;                                 in the analysis for all signals
;                                 0  :  X
;                                 1  :  Y
;                                 2  :  Z
;                                 [Default = 0]
;               NOMSSG       :  If set, routine will not inform user of elapsed
;                                 computational time [s]
;                                 [Default = FALSE]
;               SAVEF        :  If set, routine will generate output PS files of the
;                                 plots of coherence, phase, and wavenumber projection
;                                 [Default = FALSE]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [08/13/2021   v1.0.0]
;             2)  Continued to write routine
;                                                                   [09/09/2021   v1.0.0]
;             3)  Continued to write routine
;                                                                   [09/21/2021   v1.0.0]
;             4)  Finished to writing routine
;                                                                   [09/22/2021   v1.0.0]
;             5)  Now tries to calculate the range of wave numbers and rest frame
;                   frequencies for a coherency threshold of 0.6
;                                                                   [09/23/2021   v1.0.1]
;             6)  Fixed an issue with the output plots
;                                                                   [09/24/2021   v1.0.2]
;             7)  Added keyword:  CHTHRSH
;                                                                   [01/28/2022   v1.0.3]
;             8)  Now checks to make sure all three projections share the same spacecraft
;                   frame frequency
;                                                                   [01/31/2022   v1.0.4]
;             9)  Now has user specify which field component to use so that it's always
;                   uniform for each SC pair projection and changed lots of things
;                   to clean up and reduce clutter/sprawl and
;                   added keyword:  BCOMP and
;                   now includes t_sub_4sc_calc_kmag_proj_ij.pro
;                                                                   [02/02/2022   v1.1.0]
;            10)  Cleaned up and removed redundant calculations, where possible
;                                                                   [02/03/2022   v1.1.1]
;
;   NOTES:      
;               1)  This routine uses LU decomposition
;                     A . X = B
;                       A_ijm = (∆r_ij)_m
;                       B_ijm = (t_i - t_j)_m
;                       X     = (g/|g|)/V_gr,sc
;               2)  ∆r . k = V_gr,sc ∆t
;                       V_gr,sc         = 1/|X|
;                       (k/|k|)         = X/|X|
;                       V_gr,sc         = V_gr + Vsw
;                       V_gr            = V_gr,sc - Vsw
;               3)  ICB  =  Input Coordinate Basis
;               4)  Coordinate Systems
;                     SPG    :  Spinning Probe Geometric
;                     SSL    :  Spinning Sun-Sensor L-Vector
;                     DSL    :  Despun Sun-L-VectorZ (THEMIS and MMS Mission)
;                     BCS    :  Body Coordinate System (MMS Mission)
;                     DBCS   :  despun-BCS (MMS Mission)
;                     SMPA   :  Spinning, Major Principal Axis (MMS Mission)
;                     DMPA   :  Despun, Major Principal Axis (MMS Mission)
;                     GEI    :  Geocentric Equatorial Inertial
;                     GEO    :  Geographic
;                     GSE    :  Geocentric Solar Ecliptic
;                     GSM    :  Geocentric Solar Magnetospheric
;                     ICB    :  Input Coordinate Basis (e.g., GSE)
;               5)  Calculate of the cross spectral density or spectral covariance
;                     starts by defining the FFT of the jth field component from the
;                     ith spacecraft, S_i,j, so that we have:
;
;                       C_ik,j = < S_i,j* S_k,j >_t
;
;                     where * denotes the complex conjugate and <>_t denotes the
;                     temporal ensemble average.  From this, we can calculate the complex
;                     phase between the signals from two spacecraft given as:
;
;                       Phi_ik,j = ATAN( Im[ C_ik,j ] / Re[ C_ik,j ] )
;
;                     We can also calculate the complex coherency spectrum given as:
;
;                       Gamma_ik,j^2 = |C_ik,j|/( |C_ii,j|  |C_kk,j| )
;
;                     where in general 0.0 ≤ Gamma_ik,j ≤ 1.0 must be true.
;
;                     If we define the time lag between any two spacecraft as ∆t_ik and
;                     the displacement vector as ∆r_ik, then we can define:
;
;                       |k_ik| = | k . ∆r_ik |
;
;                     as the magnitude of the projection of k along ∆r_ik.  We can use
;                     the Doppler-shift equation and our knowledge of the complex phase
;                     to determine |k_ik| without having to assume a form for the
;                     dispersion relation given by:
;
;                                               { Phi_ik,j + w_sc ∆t_ik }
;                       |k_ik|_j = ------------------------------------------------------
;                                  { |∆r_ik| Cos(theta_k∆r) + Vbulk ∆t_ik Cos(theta_kV) }
;
;                     where w_sc is the spacecraft frame angular frequency, Vbulk is the
;                     magnitude of the solar wind velocity, theta_kV is the angle
;                     between k and Vbulk, and theta_k∆r is the angle between k and
;                     ∆r_ik.  We can determine these angles using previously determined
;                     minimum variance analysis (MVA) wave unit vectors.
;
;                     Once we determine |k_12|, |k_13|, and |k_24| we need to convert
;                     these to a physically meaningful coordinate basis.  We are starting
;                     in a non-orthonormal basis, so the rotation matrix given by:
;
;                           [ ∆r_12 ]
;                     R   = [ ∆r_13 ]
;                           [ ∆r_24 ]
;
;                     does not rotate from the orthonormal to non-orthonormal basis.  The
;                     correct rotation matrix to get from the non-orthonormal basis to
;                     the orthonormal one is the inverse of R, i.e., A = (R^(-1))^(T).
;                     Applying A to a quasi-3-vector comprised of |k_12|, |k_13|, and
;                     |k_24| will return k in the ICB.
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
;               7)  Beall, J.M., Y.C. Kim, and E.J. Powers "Estimation of wavenumber and
;                      frequency spectra using fixed probe pairs," J. Appl. Phys. 53(6),
;                      pp. 3933--3940, doi:10.1063/1.331279, 1982.
;
;   CREATED:  08/12/2021
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/03/2022   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION t_4sc_bwave_phase_and_group_vel_calc,tpn_posi,tpn_magf,tran_se,PERTDT=pertdt,$
                                              VBULK=vbulk,DELVB=delvb,FRAN=fran,      $
                                              K_VEC=k_vec,DKVEC=dkvec,                $
                                              CHTHRSH=chthrsh,BCOMP=bcomp,            $
                                              NOMSSG=nomssg,SAVEF=savef

ex_start       = SYSTIME(1)
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;  Define defaults
npert          = 33L                                   ;;  # of perturbing points about selected time
npmid          = 16L                                   ;;  Element of midpoint in perturbing array
perd           = DINDGEN(npert[0]) - npmid[0]          ;;  Array of perturbing elements
usearr         = LINDGEN(5) + (npmid[0] - 2L)          ;;  Array of perturbing elements to use in analysis
del            = [-1d0,-5d-1,0d0,5d-1,1d0]
nd             = N_ELEMENTS(del)
;;  Define popen structure
popen_str      = {LAND:0,PORT:1,UNITS:'inches',XSIZE:8e0,YSIZE:10.5e0,ASPECT:0}
;;  Get routine version
scopetb        = SCOPE_TRACEBACK(/STRUCTURE)
fdir           = add_os_slash(FILE_DIRNAME(scopetb[1].FILENAME[0]))
rvers          = routine_version('t_4sc_bwave_phase_and_group_vel_calc.pro',fdir[0])
;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
;;  Define some default strings
coord_dsl      = 'dsl'
coord_gse      = 'gse'
coord_gsm      = 'gsm'
coord_bcs      = 'bcs'                    ;;  Body Coordinate System (of MMS spacecraft)
coord_dbcs     = 'dbcs'                   ;;  despun-BCS
coord_dmpa     = 'dmpa'                   ;;  Despun, Major Principal Axis (coordinate system)
coordj2000     = 'j2000'                  ;;  GEI/J2000
coord_mag      = 'mag'
vec_str        = ['x','y','z']
vec_col        = [250,150, 50]
fac_lab        = ['par','per','tot']
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
;;  Error messages
noinput_mssg   = 'No input was supplied...'
no_tpns_mssg   = 'Not enough valid TPLOT handles supplied...'
badinpt_mssg   = 'Incorrect input format was supplied:  TRAN_SE must be an [4,2]-element [double] array'
battpdt_mssg   = 'The TPLOT handles supplied did not contain data...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = ((N_PARAMS() LT 2) OR (SIZE(tpn_posi,/TYPE) NE 7) OR                 $
                  (SIZE(tpn_magf,/TYPE) NE 7) OR (is_a_number(tran_se,/NOMSSG) EQ 0))
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
testp          = test_tplot_handle(tpn_posi,TPNMS=tpnposi)
testm          = test_tplot_handle(tpn_magf,TPNMS=tpnmagf)
test           = testp[0] AND testm[0]
goodp          = WHERE(tpnposi NE '',gdp)
goodm          = WHERE(tpnmagf NE '',gdm)
IF (gdp[0] LT 4 OR gdm[0] LT 4 OR ~test[0]) THEN BEGIN
  MESSAGE,no_tpns_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
sznd           = SIZE(tran_se,/N_DIMENSIONS)
szdd           = SIZE(tran_se,/DIMENSIONS)
test           = ((N_ELEMENTS(tran_se) MOD 4) NE 0) OR ((sznd[0] NE 2) AND (N_ELEMENTS(tran_se) NE 8))
IF (test[0]) THEN BEGIN
  MESSAGE,badinpt_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define time ranges
IF (szdd[1] NE 2) THEN trans = TRANSPOSE(tran_se) ELSE trans = REFORM(tran_se,4,2)
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check PERTDT
IF (is_a_number(pertdt,/NOMSSG)) THEN pdt = ABS(1d0*pertdt[0]) ELSE pdt = 1d-2
;;  Define perturbing time array
pert           = perd*pdt[0]                             ;;  Converted to ∆t about t_j
;;  Check VBULK
test           = (is_a_3_vector(vbulk,V_OUT=vswo ,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  vbulk_on = 0b
  delvb_on = 0b
  vswo     = REPLICATE(0d0,3L)
ENDIF ELSE BEGIN
  ;;  VBULK is on --> check if it's properly used
  vswo     = REFORM(vswo)
  vbulk_on = (TOTAL(FINITE(vswo)) EQ 3)
  IF (vbulk_on[0]) THEN BEGIN
    ;;  Check DELVB
    test   = (is_a_3_vector(delvb,V_OUT=dvsw ,/NOMSSG) EQ 0)
    IF (test[0]) THEN BEGIN
      delvb_on = 0b
    ENDIF ELSE BEGIN
      dvsw     = ABS(REFORM(dvsw))
      delvb_on = (TOTAL(FINITE(dvsw)) EQ 3)
    ENDELSE
  ENDIF ELSE delvb_on = 0b
ENDELSE
;;  Check FRAN
IF (test_plot_axis_range(fran,/NOMSSG)) THEN BEGIN
  frq_ran = 1d0*fran[SORT(fran)]
  filt_on = 1b
ENDIF ELSE BEGIN
  filt_on = 0b
  frq_ran = REPLICATE(d,2L)
ENDELSE
;;  Check K_VEC
test           = (is_a_3_vector(k_vec,V_OUT=kkvec,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  k_vec_on = 0b
  dkvec_on = 0b
  kkvec    = REPLICATE(0d0,3L)
ENDIF ELSE BEGIN
  ;;  K_VEC is on --> check if it's properly used
  kkvec    = REFORM(kkvec)
  k_vec_on = (TOTAL(FINITE(kkvec)) MOD 3) EQ 0
  IF (k_vec_on[0]) THEN BEGIN
    ;;  Check DKVEC
    test   = (is_a_3_vector(dkvec,V_OUT=dkkvc,/NOMSSG) EQ 0)
    IF (test[0]) THEN BEGIN
      dkvec_on = 0b
    ENDIF ELSE BEGIN
      dkkvc    = ABS(REFORM(dkkvc))
      dkvec_on = (TOTAL(FINITE(dkkvc)) EQ 3)
    ENDELSE
  ENDIF ELSE dkvec_on = 0b
ENDELSE
;;  Check CHTHRSH
IF (is_a_number(chthrsh,/NOMSSG)) THEN cthsh = (ABS(1d0*chthrsh[0]) > 6d-1) < 0.9999d0 ELSE cthsh = 6d-1
;;  Check BCOMP
IF (is_a_number(bcomp,/NOMSSG)) THEN BEGIN
  CASE bcomp[0] OF
    0L    :  ix_mx_ij = REPLICATE(0L,3L)
    1L    :  ix_mx_ij = REPLICATE(1L,3L)
    2L    :  ix_mx_ij = REPLICATE(2L,3L)
    ELSE  :  ix_mx_ij = REPLICATE(0L,3L)
  ENDCASE
ENDIF ELSE ix_mx_ij = REPLICATE(0L,3L)
;;----------------------------------------------------------------------------------------
;;  Calculate group speed, velocity, and time-lag indices
;;----------------------------------------------------------------------------------------
IF (filt_on[0]) THEN BEGIN
  ;;  Do filter data
  vg_struc       = t_4sc_bwave_group_vel_calc(tpnposi,tpnmagf,trans,PERTDT=pert,VBULK=vswo,$
                                              DELVB=dvsw,FRAN=frq_ran)
ENDIF ELSE BEGIN
  ;;  Do not filter data
  vg_struc       = t_4sc_bwave_group_vel_calc(tpnposi,tpnmagf,trans,PERTDT=pert,VBULK=vswo,$
                                              DELVB=dvsw)
ENDELSE
;;  Check output
IF (SIZE(vg_struc[0],/TYPE) NE 8) THEN STOP        ;;  Something went wrong --> Debug
;;----------------------------------------------------------------------------------------
;;  Define relevant parameters from group stuff
;;----------------------------------------------------------------------------------------
;;  Define proper shift value and corresponding array index (i.e., determines time lag)
jshft_arr      = [0L,vg_struc.CC_SHIFT_ARR]
scpos_arr      = vg_struc.SC_POSI
unix__arr      = vg_struc.UNIX
mx_cc_ij       = vg_struc.MAX_CC_IJ               ;;  Maximum correlation coefficient for SC pair ij for k-th field component
mx_ci_ij       = vg_struc.MAX_CC_IND              ;;  Index informing user of which B-field component has the best CC [12,13,14]
;;----------------------------------------------------------------------------------------
;;  Get TPLOT data
;;----------------------------------------------------------------------------------------
;;  Get Bo [nT, GSE]
get_data,tpnmagf[0],DATA=temp_magfv_1,DLIMIT=dlim_magfv_1,LIMIT=lim_magfv_1
get_data,tpnmagf[1],DATA=temp_magfv_2,DLIMIT=dlim_magfv_2,LIMIT=lim_magfv_2
get_data,tpnmagf[2],DATA=temp_magfv_3,DLIMIT=dlim_magfv_3,LIMIT=lim_magfv_3
get_data,tpnmagf[3],DATA=temp_magfv_4,DLIMIT=dlim_magfv_4,LIMIT=lim_magfv_4
;;  Define new TPLOT variables [do not use shifted data]
store_data,tpnmagf[0]+'_shifted',DATA=temp_magfv_1,DLIMIT=dlim_magfv_1,LIMIT=lim_magfv_1
store_data,tpnmagf[1]+'_shifted',DATA=temp_magfv_2,DLIMIT=dlim_magfv_2,LIMIT=lim_magfv_2
store_data,tpnmagf[2]+'_shifted',DATA=temp_magfv_3,DLIMIT=dlim_magfv_3,LIMIT=lim_magfv_3
store_data,tpnmagf[3]+'_shifted',DATA=temp_magfv_4,DLIMIT=dlim_magfv_4,LIMIT=lim_magfv_4
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate complex phase
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
new_tpnmagf    = tpnmagf+'_shifted'
cmplx_struc    = t_sub_4sc_calc_complex_phase_4sc(new_tpnmagf,trans);,DT_EXPND=[-1d0,1d0])
;;  Clean up no longer necessary TPLOT handles
store_data,DELETE=new_tpnmagf
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate |k| [km^(-1)]
;;    |k|_ij = [phi_ij + wsc * ∆t_ij]/[∆r_ij Cos(the_krij) + |Vsw| ∆t Cos(the_kVij)]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
kstruc_out     = t_sub_4sc_calc_kmag_proj_ij(cmplx_struc,vg_struc,VBULK=vbulk,DELVB=delvb,      $
                                             K_VEC=k_vec,DKVEC=dkvec)
;;  Check output
IF (SIZE(kstruc_out[0],/TYPE) NE 8) THEN STOP        ;;  Something went wrong --> Debug
;;  Define FFT frequencies [Hz]
fft_freq_1     = kstruc_out.FFT_F_SCF
b_rot          = kstruc_out.ROT_MAT
a_rot          = kstruc_out.A_MAT
kmpa_str       = kstruc_out.WAVENUMBER_P
kmma_str       = kstruc_out.WAVENUMBER_M
phia_str       = kstruc_out.PHASE
thkv_a         = kstruc_out.THETA_KV
;;  ∆r_ij = r_i - r_j
dr_12_all      = kstruc_out.DELTA_R_IJ.SC12
dr_13_all      = kstruc_out.DELTA_R_IJ.SC13
dr_24_all      = kstruc_out.DELTA_R_IJ.SC24
;;  ∆t_ij = t_i - t_j [s]
dt_12_all      = kstruc_out.DELTA_T_IJ.SC12
dt_13_all      = kstruc_out.DELTA_T_IJ.SC13
dt_24_all      = kstruc_out.DELTA_T_IJ.SC24
;;  Define component-specific strctures
kmpx_str       = kmpa_str.BX
kmpy_str       = kmpa_str.BY
kmpz_str       = kmpa_str.BZ
kmmx_str       = kmma_str.BX
kmmy_str       = kmma_str.BY
kmmz_str       = kmma_str.BZ
phix_str       = phia_str.BX
phiy_str       = phia_str.BY
phiz_str       = phia_str.BZ
;;  Define spacecraft pair-specific arrays
;;  SC12
kmag_xp1_12    = kmpx_str.SC12
kmag_yp1_12    = kmpy_str.SC12
kmag_zp1_12    = kmpz_str.SC12
kmag_xm1_12    = kmmx_str.SC12
kmag_ym1_12    = kmmy_str.SC12
kmag_zm1_12    = kmmz_str.SC12
phibx12        = phix_str.SC12
phiby12        = phiy_str.SC12
phibz12        = phiz_str.SC12
nfft           = N_ELEMENTS(phibx12)
;;  SC13
kmag_xp1_13    = kmpx_str.SC13
kmag_yp1_13    = kmpy_str.SC13
kmag_zp1_13    = kmpz_str.SC13
kmag_xm1_13    = kmmx_str.SC13
kmag_ym1_13    = kmmy_str.SC13
kmag_zm1_13    = kmmz_str.SC13
phibx13        = phix_str.SC13
phiby13        = phiy_str.SC13
phibz13        = phiz_str.SC13
;;  SC24
kmag_xp1_24    = kmpx_str.SC24
kmag_yp1_24    = kmpy_str.SC24
kmag_zp1_24    = kmpz_str.SC24
kmag_xm1_24    = kmmx_str.SC24
kmag_ym1_24    = kmmy_str.SC24
kmag_zm1_24    = kmmz_str.SC24
phibx24        = phix_str.SC24
phiby24        = phiy_str.SC24
phibz24        = phiz_str.SC24
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define coherence between any two signals:
;;    gamma_ij = { |C_ij|^2/[ |C_ii| |C_jj| ] }^(1/2)
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
gammx12        = cmplx_struc.GAM_STRUCS.SC12[*,0]
gammx13        = cmplx_struc.GAM_STRUCS.SC13[*,0]
gammx14        = cmplx_struc.GAM_STRUCS.SC14[*,0]
gammy12        = cmplx_struc.GAM_STRUCS.SC12[*,1]
gammy13        = cmplx_struc.GAM_STRUCS.SC13[*,1]
gammy14        = cmplx_struc.GAM_STRUCS.SC14[*,1]
gammz12        = cmplx_struc.GAM_STRUCS.SC12[*,2]
gammz13        = cmplx_struc.GAM_STRUCS.SC13[*,2]
gammz14        = cmplx_struc.GAM_STRUCS.SC14[*,2]
gammx23        = cmplx_struc.GAM_STRUCS.SC23[*,0]
gammx24        = cmplx_struc.GAM_STRUCS.SC24[*,0]
gammy23        = cmplx_struc.GAM_STRUCS.SC23[*,1]
gammy24        = cmplx_struc.GAM_STRUCS.SC24[*,1]
gammz23        = cmplx_struc.GAM_STRUCS.SC23[*,2]
gammz24        = cmplx_struc.GAM_STRUCS.SC24[*,2]
;;----------------------------------------------------------------------------------------
;;  Combine into 3D arrays
;;----------------------------------------------------------------------------------------
;;  Combine |k| projections
kmag_ip1_12    = [[kmag_xp1_12],[kmag_yp1_12],[kmag_zp1_12]]                ;;  [N,{bx,by,bz}]-Element array from r12 for +k/|k|
kmag_ip1_13    = [[kmag_xp1_13],[kmag_yp1_13],[kmag_zp1_13]]                ;;  " " r13 " "
;kmag_ip1_14    = [[kmag_xp1_14],[kmag_yp1_14],[kmag_zp1_14]]                ;;  " " r14 " "
kmag_im1_12    = [[kmag_xm1_12],[kmag_ym1_12],[kmag_zm1_12]]                ;;  " " r12 for -k/|k|
kmag_im1_13    = [[kmag_xm1_13],[kmag_ym1_13],[kmag_zm1_13]]                ;;  " " r13 " "
;kmag_im1_14    = [[kmag_xm1_14],[kmag_ym1_14],[kmag_zm1_14]]                ;;  " " r14 " "
kmag_ip1_24    = [[kmag_xp1_24],[kmag_yp1_24],[kmag_zp1_24]]                ;;  " " r24 " "
kmag_im1_24    = [[kmag_xm1_24],[kmag_ym1_24],[kmag_zm1_24]]                ;;  " " r24 " "
;;  Combine in k_ij vectors
ksep_ip1__x    = [[kmag_xp1_12],[kmag_xp1_13],[kmag_xp1_24]]                ;;  [N,{12,13,24}]-Element array from bx for +k/|k|
ksep_ip1__y    = [[kmag_yp1_12],[kmag_yp1_13],[kmag_yp1_24]]                ;;  " " by " "
ksep_ip1__z    = [[kmag_zp1_12],[kmag_zp1_13],[kmag_zp1_24]]                ;;  " " bz " "
ksep_im1__x    = [[kmag_xm1_12],[kmag_xm1_13],[kmag_xm1_24]]                ;;  " " bx for -k/|k|
ksep_im1__y    = [[kmag_ym1_12],[kmag_ym1_13],[kmag_ym1_24]]                ;;  " " by " "
ksep_im1__z    = [[kmag_zm1_12],[kmag_zm1_13],[kmag_zm1_24]]                ;;  " " bz " "
;;----------------------------------------------------------------------------------------
;;  Find frequencies within observed range of interest
;;----------------------------------------------------------------------------------------
good_frq       = WHERE(fft_freq_1 GE frq_ran[0] AND fft_freq_1 LE frq_ran[1],gd_frq)
IF (gd_frq[0] EQ 0) THEN STOP  ;;  Something is wrong --> Debug
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Set up plotting stuff
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Open plot window
xysz           = [800L,960L]
lbw_window,WIND_N=1,/CLEAN,XSIZE=xysz[0],YSIZE=xysz[1],TITLE='Coherence'
lbw_window,WIND_N=2,/CLEAN,XSIZE=xysz[0],YSIZE=xysz[1],TITLE='Phase'
lbw_window,WIND_N=3,/CLEAN,XSIZE=xysz[0],YSIZE=xysz[1],TITLE='Wavenumber'
;;----------------------------------------------------------------------------------------
;;  Define data
;;----------------------------------------------------------------------------------------
xdat           = fft_freq_1
CASE ix_mx_ij[0] OF
  0L    :  BEGIN
    ;;  Bx
    gydt0          =  gammx12
    pydt0          =  phibx12
    kydt0          = kmag_xp1_12
    kydm0          = kmag_xm1_12
    gydt1          =  gammx13
    pydt1          =  phibx13
    kydt1          = kmag_xp1_13
    kydm1          = kmag_xm1_13
    gydt2          =  gammx24
    pydt2          =  phibx24
    kydt2          = kmag_xp1_24
    kydm2          = kmag_xm1_24
  END
  1L    :  BEGIN
    ;;  By
    gydt0          =  gammy12
    pydt0          =  phiby12
    kydt0          = kmag_yp1_12
    kydm0          = kmag_ym1_12
    gydt1          =  gammy13
    pydt1          =  phiby13
    kydt1          = kmag_yp1_13
    kydm1          = kmag_ym1_13
    gydt2          =  gammy24
    pydt2          =  phiby24
    kydt2          = kmag_yp1_24
    kydm2          = kmag_ym1_24
  END
  2L    :  BEGIN
    ;;  Bz
    gydt0          =  gammz12
    pydt0          =  phibz12
    kydt0          = kmag_zp1_12
    kydm0          = kmag_zm1_12
    gydt1          =  gammz13
    pydt1          =  phibz13
    kydt1          = kmag_zp1_13
    kydm1          = kmag_zm1_13
    gydt2          =  gammz24
    pydt2          =  phibz24
    kydt2          = kmag_zp1_24
    kydm2          = kmag_zm1_24
  END
  ELSE  :  BEGIN
    ;;  Should not happen --> Use Bx
    gydt0          =  gammx12
    pydt0          =  phibx12
    kydt0          = kmag_xp1_12
    kydm0          = kmag_xm1_12
    gydt1          =  gammx13
    pydt1          =  phibx13
    kydt1          = kmag_xp1_13
    kydm1          = kmag_xm1_13
    gydt2          =  gammx24
    pydt2          =  phibx24
    kydt2          = kmag_xp1_24
    kydm2          = kmag_xm1_24
  END
ENDCASE
;;  Define structures for later use
;;  SC12
gdat0          = {X:xdat,Y:gydt0}
pdat0          = {X:xdat,Y:pydt0}
kdat0          = {X:xdat,Y:kydt0}
kdam0          = {X:xdat,Y:kydm0}
;;  SC13
gdat1          = {X:xdat,Y:gydt1}
pdat1          = {X:xdat,Y:pydt1}
kdat1          = {X:xdat,Y:kydt1}
kdam1          = {X:xdat,Y:kydm1}
;;  SC24
gdat2          = {X:xdat,Y:gydt2}
pdat2          = {X:xdat,Y:pydt2}
kdat2          = {X:xdat,Y:kydt2}
kdam2          = {X:xdat,Y:kydm2}
;;----------------------------------------------------------------------------------------
;;  Determine reasonable |k_ij| range
;;----------------------------------------------------------------------------------------
xran           = [-0.1d0,1d0]
xran[1]        = xran[1] > frq_ran[1]
gind_freq      = WHERE(xdat GE xran[0] AND xdat LE xran[1],gd_freq)
IF (gd_freq[0] GT 0) THEN all_kmag = ABS([kdat0.Y[gind_freq],kdat1.Y[gind_freq],kdat2.Y[gind_freq]]) ELSE all_kmag = ABS([kdat0.Y,kdat1.Y,kdat2.Y])
conlim         = 9d-1
onvs_kmag_all  = calc_1var_stats(all_kmag,/NAN,CONLIM=conlim,PERCENTILES=perc_kmag)
upper          = 1d1^(1d0*CEIL(ALOG10(perc_kmag)))
lower          = 1d1^(1d0*FLOOR(ALOG10(perc_kmag)))
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Print solution results to screen
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Find max coherency in frequency range and above threshold!
good_g0        = WHERE(gdat0.Y[good_frq] GE cthsh[0],gd_g0)
good_g1        = WHERE(gdat1.Y[good_frq] GE cthsh[0],gd_g1)
good_g2        = WHERE(gdat2.Y[good_frq] GE cthsh[0],gd_g2)
good_g012      = WHERE(gdat0.Y[good_frq] GE cthsh[0] AND gdat1.Y[good_frq] GE cthsh[0] AND gdat2.Y[good_frq] GE cthsh[0],gd_g012)
IF (gd_g012[0] GT 0) THEN gind_012 = good_frq[good_g012] ELSE gind_012 = -1L
all_12_on      = 0b
all_13_on      = 0b
all_24_on      = 0b
IF (gd_g0[0] GT 0) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate a range:  12
  ;;--------------------------------------------------------------------------------------
  gind_g0        = good_frq[good_g0]
  max_g0         = MAX(gdat0.Y[gind_g0],/NAN,lx_g0)
  gind_0         = gind_g0[lx_g0[0]]
  kmaxp12        = kdat0.Y[gind_0[0]]
  kmaxm12        = kdam0.Y[gind_0[0]]
  kallp12        = kdat0.Y[gind_g0]
  kallm12        = kdam0.Y[gind_g0]
  gall_12        =    gdat0.Y[gind_g0]
  pall_12        =    pdat0.Y[gind_g0]
  freq_12        = fft_freq_1[gind_g0]
  all_12_on      = 1b
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate values from max coherence only:  12
  ;;--------------------------------------------------------------------------------------
  gind_g0        = -1L
  max_g0         = MAX(gdat0.Y[good_frq],/NAN,lx_g0)
  gind_0         = good_frq[lx_g0[0]]
  kmaxp12        = kdat0.Y[gind_0[0]]
  kmaxm12        = kdam0.Y[gind_0[0]]
ENDELSE

IF (gd_g1[0] GT 0) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate a range:  13
  ;;--------------------------------------------------------------------------------------
  gind_g1        = good_frq[good_g1]
  max_g1         = MAX(gdat1.Y[gind_g1],/NAN,lx_g1)
  gind_1         = gind_g1[lx_g1[0]]
  kmaxp13        = kdat1.Y[gind_1[0]]
  kmaxm13        = kdam1.Y[gind_1[0]]
  kallp13        = kdat1.Y[gind_g1]
  kallm13        = kdam1.Y[gind_g1]
  gall_13        =    gdat1.Y[gind_g1]
  pall_13        =    pdat1.Y[gind_g1]
  freq_13        = fft_freq_1[gind_g1]
  all_13_on      = 1b
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate values from max coherence only:  13
  ;;--------------------------------------------------------------------------------------
  gind_g1        = -1L
  max_g1         = MAX(gdat1.Y[good_frq],/NAN,lx_g1)
  gind_1         = good_frq[lx_g1[0]]
  kmaxp13        = kdat1.Y[gind_1[0]]
  kmaxm13        = kdam1.Y[gind_1[0]]
ENDELSE

IF (gd_g2[0] GT 0) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate a range:  24
  ;;--------------------------------------------------------------------------------------
  gind_g2        = good_frq[good_g2]
  max_g2         = MAX(gdat2.Y[gind_g2],/NAN,lx_g2)
  gind_2         = gind_g2[lx_g2[0]]
  kmaxp24        = kdat2.Y[gind_2[0]]
  kmaxm24        = kdam2.Y[gind_2[0]]
  kallp24        = kdat2.Y[gind_g2]
  kallm24        = kdam2.Y[gind_g2]
  gall_24        =    gdat2.Y[gind_g2]
  pall_24        =    pdat2.Y[gind_g2]
  freq_24        = fft_freq_1[gind_g2]
  all_24_on      = 1b
ENDIF ELSE BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate values from max coherence only:  24
  ;;--------------------------------------------------------------------------------------
  gind_g2        = -1L
  max_g2         = MAX(gdat2.Y[good_frq],/NAN,lx_g2)
  gind_2         = good_frq[lx_g2[0]]
  kmaxp24        = kdat2.Y[gind_2[0]]
  kmaxm24        = kdam2.Y[gind_2[0]]
ENDELSE
max_ga         = MAX([gdat0.Y[gind_0[0]],gdat1.Y[gind_1[0]],gdat2.Y[gind_2[0]]],/NAN,lx_ga)
gind_a         = ([gind_0[0],gind_1[0],gind_2[0]])[lx_ga[0]]
max_af_g0      = MAX(gdat0.Y[good_frq],/NAN,lx_af_g0)
max_af_g1      = MAX(gdat1.Y[good_frq],/NAN,lx_af_g1)
max_af_g2      = MAX(gdat2.Y[good_frq],/NAN,lx_af_g2)
max_af_ga      = MAX([gdat0.Y[good_frq],gdat1.Y[good_frq],gdat2.Y[good_frq]],/NAN,lx_af_ga)
gind_af_a      = [good_frq[lx_af_g0[0]],good_frq[lx_af_g1[0]],good_frq[lx_af_g2[0]],([good_frq,good_frq,good_frq])[lx_af_ga[0]]]
;;----------------------------------------------------------------------------------------
;;  Define global results
;;----------------------------------------------------------------------------------------
kmax_pp        = [kmaxp12[0], kmaxp13[0], kmaxp24[0]]
kmax_mm        = [kmaxm12[0], kmaxm13[0], kmaxm24[0]]
;;  Rotate |k| projections for maximum coherency
IF (TOTAL(FINITE(b_rot)) EQ 9) THEN BEGIN
  kgse_pp        = REFORM(TRANSPOSE(b_rot) ## kmax_pp)
  kgse_mm        = REFORM(TRANSPOSE(b_rot) ## kmax_mm)
ENDIF ELSE BEGIN
  kgse_pp        = REPLICATE(d,3L)
  kgse_mm        = REPLICATE(d,3L)
ENDELSE
kmag_pp        = (mag__vec(kgse_pp))[0]
kmag_mm        = (mag__vec(kgse_mm))[0]
;;  Calculate k.V/(2π)
kdV__pp        = TOTAL(kgse_pp*vswo,/NAN)/(2d0*!DPI)
kdV__mm        = TOTAL(kgse_mm*vswo,/NAN)/(2d0*!DPI)
;;  Calculate f = fsc - k.V/(2π)
frest_p        = fft_freq_1[gind_a[0]] - kdV__pp[0]
frest_m        = fft_freq_1[gind_a[0]] - kdV__mm[0]
f_sc__0        = fft_freq_1[gind_a[0]]
;;  Calculate phase speed [km/s] for max coherence
Vphp_max       = (2d0*!DPI*frest_p[0])/kmag_pp[0]
Vphm_max       = (2d0*!DPI*frest_m[0])/kmag_mm[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define relevant outputs
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
IF (all_12_on[0] AND all_13_on[0] AND all_24_on[0]) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  Rotate |k| projections for all "good" coherencies
  ;;--------------------------------------------------------------------------------------
  mngd           = LONG(MIN([gd_g0[0],gd_g1[0],gd_g2[0]],/NAN))
  low            = 0L & upp = mngd[0] - 1L
  kall_pp        = [[kallp12[low[0]:upp[0]]],[kallp13[low[0]:upp[0]]],[kallp24[low[0]:upp[0]]]]
  kall_mm        = [[kallm12[low[0]:upp[0]]],[kallm13[low[0]:upp[0]]],[kallm24[low[0]:upp[0]]]]
  nall           = N_ELEMENTS(kall_pp[*,0])
  kgse_alp       = REFORM(TRANSPOSE(b_rot) ## kall_pp,nall[0],3L)
  kgse_alm       = REFORM(TRANSPOSE(b_rot) ## kall_mm,nall[0],3L)
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate k.V/(2π)
  ;;--------------------------------------------------------------------------------------
  kdVa_pp        = TOTAL(kgse_alp*(REPLICATE(1d0,nall[0]) # vswo),2L,/NAN)/(2d0*!DPI)
  kdVa_mm        = TOTAL(kgse_alm*(REPLICATE(1d0,nall[0]) # vswo),2L,/NAN)/(2d0*!DPI)
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate f = fsc - k.V/(2π)
  ;;--------------------------------------------------------------------------------------
  all_gind       = [gind_g0,gind_g1,gind_g2]
  unq            = UNIQ(all_gind,SORT(all_gind))
  unq            = unq[SORT(unq)]
  nuq            = N_ELEMENTS(unq)
  fsc_all        = fft_freq_1[unq]
  frest_p0       = REPLICATE(d,nuq[0],nall[0])
  frest_m0       = frest_p0
  FOR j=0L, nuq[0] - 1L DO BEGIN
    frest_p0[j,*]  = fsc_all[j] - kdVa_pp
    frest_m0[j,*]  = fsc_all[j] - kdVa_mm
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;;  Find ranges of relevant parameters
  ;;--------------------------------------------------------------------------------------
  good_p0        = WHERE(frest_p0 GT 0,gd_p0)
  good_m0        = WHERE(frest_m0 GT 0,gd_m0)
  fsc_med        = MEDIAN(fsc_all)
  fsc_ran        = [MIN(fsc_all,/NAN),MAX(fsc_all,/NAN)]
  frp_ran        = [MIN(frest_p0,/NAN),MAX(frest_p0,/NAN)]
  frp_med        = MEDIAN(frest_p0)
  frm_ran        = [MIN(frest_m0,/NAN),MAX(frest_m0,/NAN)]
  frm_med        = MEDIAN(frest_m0)
  k_ap_med       = MEDIAN(kgse_alp,DIMENSION=1)
  k_am_med       = MEDIAN(kgse_alm,DIMENSION=1)
  k_ap_ran       = TRANSPOSE([[MIN(kgse_alp,/NAN,DIMENSION=1)],[MAX(kgse_alp,/NAN,DIMENSION=1)]])
  k_am_ran       = TRANSPOSE([[MIN(kgse_alm,/NAN,DIMENSION=1)],[MAX(kgse_alm,/NAN,DIMENSION=1)]])
  k_ap_out       = REPLICATE(d,2L,3L)         ;;  {val/unc,xyz}
  k_am_out       = REPLICATE(d,2L,3L)
  f_sc_out       = REPLICATE(d,2L)            ;;  {val/unc}
  f_rp_out       = REPLICATE(d,2L)            ;;  {val/unc}
  f_rm_out       = REPLICATE(d,2L)
  f_sc_out[0]    = fsc_med[0]
  f_sc_out[1]    = (fsc_ran[1] - fsc_ran[0])/2d0
  f_rp_out[0]    = frp_med[0]
  f_rp_out[1]    = (frp_ran[1] - frp_ran[0])/2d0
  f_rm_out[0]    = frm_med[0]
  f_rm_out[1]    = (frm_ran[1] - frm_ran[0])/2d0
  k_ap_out[0,*]  = k_ap_med
  k_am_out[0,*]  = k_am_med
  k_ap_out[1,*]  = (k_ap_ran[1,*] - k_ap_ran[0,*])/2d0
  k_am_out[1,*]  = (k_am_ran[1,*] - k_am_ran[0,*])/2d0
  kper           = [-1d0,-5d-1,0d0,5d-1,1d0]
  kmap_out       = REPLICATE(d,2L)            ;;  {val/unc}
  kmam_out       = REPLICATE(d,2L)            ;;  {val/unc}
  kper_p0        = REPLICATE(d,5L,3L)
  kper_m0        = REPLICATE(d,5L,3L)
  FOR j=0L, 4L DO BEGIN
    kper_p0[j,*] = k_ap_out[0,*] + kper[j]*k_ap_out[1,*]
    kper_m0[j,*] = k_am_out[0,*] + kper[j]*k_am_out[1,*]
  ENDFOR
  kmag_p0        = mag__vec(kper_p0,/NAN)
  kmag_m0        = mag__vec(kper_m0,/NAN)
  kmap_out[0]    = MEDIAN(kmag_p0)
  kmam_out[0]    = MEDIAN(kmag_m0)
  kmap_out[1]    = (MAX(kmag_p0,/NAN) - MIN(kmag_p0,/NAN))/2d0
  kmam_out[1]    = (MAX(kmag_m0,/NAN) - MIN(kmag_m0,/NAN))/2d0
  ;;--------------------------------------------------------------------------------------
  ;;  Calculate phase speed [km/s]
  ;;--------------------------------------------------------------------------------------
  Vphp_out       = REPLICATE(d,2L)            ;;  {val/unc}
  Vphm_out       = REPLICATE(d,2L)            ;;  {val/unc}
  Vphp_out[0]    = (2d0*!DPI*ABS(f_rp_out[0]))/kmap_out[0]
  Vphm_out[0]    = (2d0*!DPI*ABS(f_rm_out[0]))/kmam_out[0]
  Vphp_out[1]    = Vphp_out[0]*SQRT((f_rp_out[1]/f_rp_out[0])^2d0 + (kmap_out[1]/kmap_out[0])^2d0)
  Vphm_out[1]    = Vphm_out[0]*SQRT((f_rm_out[1]/f_rm_out[0])^2d0 + (kmam_out[1]/kmam_out[0])^2d0)
ENDIF ELSE BEGIN
  kgse_alp       = REPLICATE(d,1L,3L)
  kgse_alm       = REPLICATE(d,1L,3L)
  fsc_ran        = REPLICATE(d,2L)
  k_ap_out       = REPLICATE(d,2L,3L)         ;;  {val/unc,xyz}
  k_am_out       = REPLICATE(d,2L,3L)
  f_sc_out       = REPLICATE(d,2L)            ;;  {val/unc}
  f_rp_out       = REPLICATE(d,2L)            ;;  {val/unc}
  f_rm_out       = REPLICATE(d,2L)
  kmap_out       = REPLICATE(d,2L)            ;;  {val/unc}
  kmam_out       = REPLICATE(d,2L)            ;;  {val/unc}
  Vphp_out       = REPLICATE(d,2L)            ;;  {val/unc}
  Vphm_out       = REPLICATE(d,2L)            ;;  {val/unc}
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Print results
;;----------------------------------------------------------------------------------------
posi_on        = (frest_p[0] GT 0)
nega_on        = (frest_m[0] GT 0)
IF (frest_p[0] GT 0 AND frest_m[0] LT 0) THEN posi_on = 1b
IF (frest_p[0] LT 0 AND frest_m[0] GT 0) THEN nega_on = 1b
PRINT, ';;  fsc                      [Hz] = ', f_sc__0[0]                              & $
PRINT, ';;  {k_12+,k_13+,k_24+} [km^(-1)] = ', kmax_pp[0], kmax_pp[1], kmax_pp[2]      & $
PRINT, ';;  k+             [km^(-1), GSE] = ', kgse_pp[0], kgse_pp[1], kgse_pp[2]      & $
PRINT, ';;  |k+|           [km^(-1), GSE] = ', kmag_pp[0]                              & $
PRINT, ';;  frest,+                  [Hz] = ', frest_p[0]                              & $
PRINT, ';;'                                                                            & $
PRINT, ';;  {k_12-,k_13-,k_24-} [km^(-1)] = ', kmax_mm[0], kmax_mm[1], kmax_mm[2]      & $
PRINT, ';;  k-             [km^(-1), GSE] = ', kgse_mm[0], kgse_mm[1], kgse_mm[2]      & $
PRINT, ';;  |k-|           [km^(-1), GSE] = ', kmag_mm[0]                              & $
PRINT, ';;  frest,-                  [Hz] = ', frest_m[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Plot the results
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
xmar           = [20,15]
ymar           = [ 5, 5]
yra0           = [0d0,1d0]                             ;;  Gamma_ik (coherence)
yra1           = [0d0,36d1]                            ;;  Phi_ik   (phase)
yra2           = [MIN(lower,/NAN),MAX(upper,/NAN)]     ;;  |k_ij|   (projected wave number)
chsz           = [2e0,1.25e0]
gtttl          = 'Spectral coherence vs SCF frequency'
ptttl          = 'Spectral phase vs SCF frequency'
ktttl          = 'Wavenumber projection magnitude vs SCF frequency'
lim012         = {XRANGE:xran,YRANGE:yra0,XLOG:0,YLOG:0,THICK:2e0,TITLE:gtttl[0],    $
                  XTITLE:'frequency [Hz, SCF]',YTITLE:'gamma_12 [N/A]',              $
                  XSTYLE:1,YSTYLE:1,NODATA:1,XMARGIN:xmar,YMARGIN:ymar}
lim112         = {XRANGE:xran,YRANGE:yra1,XLOG:0,YLOG:0,THICK:2e0,TITLE:ptttl[0],    $
                  XTITLE:'frequency [Hz, SCF]',YTITLE:'phi_12 [deg]',                $
                  XSTYLE:1,YSTYLE:1,NODATA:1,XMARGIN:xmar,YMARGIN:ymar}
lim212         = {XRANGE:xran,YRANGE:yra2,XLOG:0,YLOG:1,THICK:2e0,TITLE:ktttl[0],    $
                  XTITLE:'frequency [Hz, SCF]',YTITLE:'|k_r12| [km^(-1)]',           $
                  XSTYLE:1,YSTYLE:1,NODATA:1,XMARGIN:xmar,YMARGIN:ymar}
lim013         = lim012
lim024         = lim012
lim113         = lim112
lim124         = lim112
lim213         = lim212
lim224         = lim212
str_element,lim013,'YTITLE','gamma_13 [N/A]',/ADD_REPLACE
str_element,lim024,'YTITLE','gamma_24 [N/A]',/ADD_REPLACE
str_element,lim113,'YTITLE','phi_13 [N/A]',/ADD_REPLACE
str_element,lim124,'YTITLE','phi_24 [N/A]',/ADD_REPLACE
str_element,lim213,'YTITLE','|k_r13| [km^(-1)]',/ADD_REPLACE
str_element,lim224,'YTITLE','|k_r24| [km^(-1)]',/ADD_REPLACE
CASE ix_mx_ij[0] OF
  0L    :  BEGIN
    ;;  Bx
    yttl_a12 = '!C'+'[From Bx]'
    yttl_a13 = '!C'+'[From Bx]'
    yttl_a24 = '!C'+'[From Bx]'
    fsuff_fc = '_Bx'
  END
  1L    :  BEGIN
    ;;  By
    yttl_a12 = '!C'+'[From By]'
    yttl_a13 = '!C'+'[From By]'
    yttl_a24 = '!C'+'[From By]'
    fsuff_fc = '_By'
  END
  2L    :  BEGIN
    ;;  Bz
    yttl_a12 = '!C'+'[From Bz]'
    yttl_a13 = '!C'+'[From Bz]'
    yttl_a24 = '!C'+'[From Bz]'
    fsuff_fc = '_Bz'
  END
  ELSE  :  BEGIN
    ;;  Should not happen --> Use Bx
    yttl_a12 = '!C'+'[From Bx]'
    yttl_a13 = '!C'+'[From Bx]'
    yttl_a24 = '!C'+'[From Bx]'
    fsuff_fc = '_Bx'
  END
ENDCASE
;;  Add to YTITLE tag in plot limits structures
lim012.YTITLE  = lim012.YTITLE[0]+yttl_a12[0]
lim112.YTITLE  = lim112.YTITLE[0]+yttl_a12[0]
lim212.YTITLE  = lim212.YTITLE[0]+yttl_a12[0]
lim013.YTITLE  = lim013.YTITLE[0]+yttl_a13[0]
lim113.YTITLE  = lim113.YTITLE[0]+yttl_a13[0]
lim213.YTITLE  = lim213.YTITLE[0]+yttl_a13[0]
lim024.YTITLE  = lim024.YTITLE[0]+yttl_a24[0]
lim124.YTITLE  = lim124.YTITLE[0]+yttl_a24[0]
lim224.YTITLE  = lim224.YTITLE[0]+yttl_a24[0]
;;----------------------------------------------------------------------------------------
;;  We start by plotting
;;    -- coherence (gamma_ij) vs SCF frequency
;;    -- phase (phi_ij) vs SCF frequency
;;    -- |k_ij| vs SCF frequency
;;----------------------------------------------------------------------------------------
;;  Plot coherence
WSET,1
WSHOW,1
lim1           = lim012
lim2           = lim013
lim3           = lim024
!P.MULTI       = [0,1,3]
;;  Gamma_12
PLOT,gdat0.X,gdat0.Y,_EXTRA=lim1,CHARSIZE=chsz[1]
  OPLOT,gdat0.X,gdat0.Y,THICK=2,COLOR=250
  OPLOT,gdat0.X,gdat0.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
  OPLOT,[f_sc__0[0],f_sc__0[0]],lim1.YRANGE,LINESTYLE=1,THICK=2
  IF (filt_on[0]) THEN BEGIN
    OPLOT,[frq_ran[0],frq_ran[0]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
    OPLOT,[frq_ran[1],frq_ran[1]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
  ENDIF
  ;;  Plot Gamma_ik threshold
  OPLOT,xran,[cthsh[0],cthsh[0]],LINESTYLE=2,THICK=2,COLOR=100
  IF (all_12_on[0]) THEN OPLOT,freq_12,gall_12,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
;;  Gamma_13
PLOT,gdat1.X,gdat1.Y,_EXTRA=lim2,CHARSIZE=chsz[1]
  OPLOT,gdat1.X,gdat1.Y,THICK=2,COLOR=250
  OPLOT,gdat1.X,gdat1.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
  OPLOT,[f_sc__0[0],f_sc__0[0]],lim2.YRANGE,LINESTYLE=1,THICK=2
  IF (filt_on[0]) THEN BEGIN
    OPLOT,[frq_ran[0],frq_ran[0]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
    OPLOT,[frq_ran[1],frq_ran[1]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
  ENDIF
  ;;  Plot Gamma_ik threshold
  OPLOT,xran,[cthsh[0],cthsh[0]],LINESTYLE=2,THICK=2,COLOR=100
  IF (all_13_on[0]) THEN OPLOT,freq_13,gall_13,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
;;  Gamma_24
PLOT,gdat2.X,gdat2.Y,_EXTRA=lim3,CHARSIZE=chsz[1]
  OPLOT,gdat2.X,gdat2.Y,THICK=2,COLOR=250
  OPLOT,gdat2.X,gdat2.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
  OPLOT,[f_sc__0[0],f_sc__0[0]],lim3.YRANGE,LINESTYLE=1,THICK=2
  IF (filt_on[0]) THEN BEGIN
    OPLOT,[frq_ran[0],frq_ran[0]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
    OPLOT,[frq_ran[1],frq_ran[1]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
  ENDIF
  ;;  Plot Gamma_ik threshold
  OPLOT,xran,[cthsh[0],cthsh[0]],LINESTYLE=2,THICK=2,COLOR=100
  IF (all_24_on[0]) THEN OPLOT,freq_24,gall_24,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
!P.MULTI       = 0
;;----------------------------------------------------------------------------------------
;;  Plot phase
;;----------------------------------------------------------------------------------------
WSET,2
WSHOW,2
lim1           = lim112
lim2           = lim113
lim3           = lim124
!P.MULTI       = [0,1,3]
PLOT,pdat0.X,pdat0.Y,_EXTRA=lim1,CHARSIZE=chsz[1]
  OPLOT,pdat0.X,pdat0.Y,THICK=2,COLOR=250
  OPLOT,pdat0.X,pdat0.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
  OPLOT,[f_sc__0[0],f_sc__0[0]],lim1.YRANGE,LINESTYLE=1,THICK=2
  IF (filt_on[0]) THEN BEGIN
    OPLOT,[frq_ran[0],frq_ran[0]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
    OPLOT,[frq_ran[1],frq_ran[1]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
  ENDIF
  IF (all_12_on[0]) THEN OPLOT,freq_12,pall_12,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
PLOT,pdat1.X,pdat1.Y,_EXTRA=lim2,CHARSIZE=chsz[1]
  OPLOT,pdat1.X,pdat1.Y,THICK=2,COLOR=250
  OPLOT,pdat1.X,pdat1.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
  OPLOT,[f_sc__0[0],f_sc__0[0]],lim2.YRANGE,LINESTYLE=1,THICK=2
  IF (filt_on[0]) THEN BEGIN
    OPLOT,[frq_ran[0],frq_ran[0]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
    OPLOT,[frq_ran[1],frq_ran[1]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
  ENDIF
  IF (all_13_on[0]) THEN OPLOT,freq_13,pall_13,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
PLOT,pdat2.X,pdat2.Y,_EXTRA=lim3,CHARSIZE=chsz[1]
  OPLOT,pdat2.X,pdat2.Y,THICK=2,COLOR=250
  OPLOT,pdat2.X,pdat2.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
  OPLOT,[f_sc__0[0],f_sc__0[0]],lim3.YRANGE,LINESTYLE=1,THICK=2
  IF (filt_on[0]) THEN BEGIN
    OPLOT,[frq_ran[0],frq_ran[0]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
    OPLOT,[frq_ran[1],frq_ran[1]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
  ENDIF
  IF (all_24_on[0]) THEN OPLOT,freq_24,pall_24,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
!P.MULTI       = 0
;;----------------------------------------------------------------------------------------
;;  Plot wavenumber magnitudes
;;----------------------------------------------------------------------------------------
WSET,3
WSHOW,3
lim1           = lim212
lim2           = lim213
lim3           = lim224
!P.MULTI       = [0,1,3]
PLOT,kdat0.X,kdat0.Y,_EXTRA=lim1,CHARSIZE=chsz[1]
  OPLOT,kdat0.X,ABS(kdat0.Y),THICK=2,COLOR=250
  OPLOT,kdat0.X,ABS(kdat0.Y),PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
  OPLOT,[f_sc__0[0],f_sc__0[0]],lim1.YRANGE,LINESTYLE=1,THICK=2
  IF (filt_on[0]) THEN BEGIN
    OPLOT,[frq_ran[0],frq_ran[0]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
    OPLOT,[frq_ran[1],frq_ran[1]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
  ENDIF
  IF (all_12_on[0]) THEN OPLOT,freq_12,ABS(kallp12),PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
PLOT,kdat1.X,kdat1.Y,_EXTRA=lim2,CHARSIZE=chsz[1]
  OPLOT,kdat1.X,ABS(kdat1.Y),THICK=2,COLOR=250
  OPLOT,kdat1.X,ABS(kdat1.Y),PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
  OPLOT,[f_sc__0[0],f_sc__0[0]],lim2.YRANGE,LINESTYLE=1,THICK=2
  IF (filt_on[0]) THEN BEGIN
    OPLOT,[frq_ran[0],frq_ran[0]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
    OPLOT,[frq_ran[1],frq_ran[1]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
  ENDIF
  IF (all_13_on[0]) THEN OPLOT,freq_13,ABS(kallp13),PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
PLOT,kdat2.X,kdat2.Y,_EXTRA=lim3,CHARSIZE=chsz[1]
  OPLOT,kdat2.X,ABS(kdat2.Y),THICK=2,COLOR=250
  OPLOT,kdat2.X,ABS(kdat2.Y),PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
  OPLOT,[f_sc__0[0],f_sc__0[0]],lim3.YRANGE,LINESTYLE=1,THICK=2
  IF (filt_on[0]) THEN BEGIN
    OPLOT,[frq_ran[0],frq_ran[0]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
    OPLOT,[frq_ran[1],frq_ran[1]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
  ENDIF
  IF (all_24_on[0]) THEN OPLOT,freq_24,ABS(kallp24),PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
!P.MULTI       = 0
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Save plots if user wants
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
frq_suffx      = ''
IF KEYWORD_SET(savef) THEN BEGIN
  ;;  Define some file name suffixes
  IF (filt_on[0]) THEN BEGIN
    frq_str        = num2flt_str(frq_ran*1d3,NUM_CHAR=5,NUM_DEC=0,/RM_PERI)
    frq_suffx      = '_'+frq_str[0]+'-'+frq_str[1]+'mHz'
  ENDIF
  cthsh_str      = num2flt_str(cthsh[0],NUM_CHAR=5,NUM_DEC=2)        ;;  threshold string
  mnmx_tran      = [MIN(trans,/NAN),MAX(trans,/NAN)]
  fnm            = file_name_times(mnmx_tran,PREC=4,FORMFN=1)
  tran_suffx     = '_'+fnm[0].F_TIME[0]+'_to_'+fnm[0].F_TIME[1]
  fsuffx         = '_GammaThrsh_'+cthsh_str[0]+frq_suffx[0]+tran_suffx[0]
  lim1           = lim012
  lim2           = lim013
  lim3           = lim024
  ;;  Plot coherence
  popen,'wave_4sc_coherence_vs_scf_frequency'+fsuff_fc[0]+fsuffx[0],_EXTRA=popen_str[0]
    !P.MULTI       = [0,1,3]
    PLOT,gdat0.X,gdat0.Y,_EXTRA=lim1,CHARSIZE=chsz[1]
      OPLOT,gdat0.X,gdat0.Y,THICK=2,COLOR=250
      OPLOT,gdat0.X,gdat0.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
      OPLOT,[f_sc__0[0],f_sc__0[0]],lim1.YRANGE,LINESTYLE=1,THICK=2
      IF (filt_on[0]) THEN BEGIN
        OPLOT,[frq_ran[0],frq_ran[0]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
        OPLOT,[frq_ran[1],frq_ran[1]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
      ENDIF
      ;;  Plot Gamma_ik threshold
      OPLOT,xran,[cthsh[0],cthsh[0]],LINESTYLE=2,THICK=2,COLOR=100
      IF (all_12_on[0]) THEN OPLOT,freq_12,gall_12,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
    PLOT,gdat1.X,gdat1.Y,_EXTRA=lim2,CHARSIZE=chsz[1]
      OPLOT,gdat1.X,gdat1.Y,THICK=2,COLOR=250
      OPLOT,gdat1.X,gdat1.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
      OPLOT,[f_sc__0[0],f_sc__0[0]],lim2.YRANGE,LINESTYLE=1,THICK=2
      IF (filt_on[0]) THEN BEGIN
        OPLOT,[frq_ran[0],frq_ran[0]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
        OPLOT,[frq_ran[1],frq_ran[1]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
      ENDIF
      ;;  Plot Gamma_ik threshold
      OPLOT,xran,[cthsh[0],cthsh[0]],LINESTYLE=2,THICK=2,COLOR=100
      IF (all_13_on[0]) THEN OPLOT,freq_13,gall_13,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
    PLOT,gdat2.X,gdat2.Y,_EXTRA=lim3,CHARSIZE=chsz[1]
      OPLOT,gdat2.X,gdat2.Y,THICK=2,COLOR=250
      OPLOT,gdat2.X,gdat2.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
      OPLOT,[f_sc__0[0],f_sc__0[0]],lim3.YRANGE,LINESTYLE=1,THICK=2
      IF (filt_on[0]) THEN BEGIN
        OPLOT,[frq_ran[0],frq_ran[0]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
        OPLOT,[frq_ran[1],frq_ran[1]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
      ENDIF
      ;;  Plot Gamma_ik threshold
      OPLOT,xran,[cthsh[0],cthsh[0]],LINESTYLE=2,THICK=2,COLOR=100
      IF (all_24_on[0]) THEN OPLOT,freq_24,gall_24,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
      ;;  Output routine version for documentation
      XYOUTS,0.95,0.05,rvers[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=1e0
    !P.MULTI       = 0
  pclose
  ;;  Plot phase
  lim1           = lim112
  lim2           = lim113
  lim3           = lim124
  popen,'wave_4sc_phase_vs_scf_frequency'+fsuff_fc[0]+fsuffx[0],_EXTRA=popen_str[0]
    !P.MULTI       = [0,1,3]
    PLOT,pdat0.X,pdat0.Y,_EXTRA=lim1,CHARSIZE=chsz[1]
      OPLOT,pdat0.X,pdat0.Y,THICK=2,COLOR=250
      OPLOT,pdat0.X,pdat0.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
      OPLOT,[f_sc__0[0],f_sc__0[0]],lim1.YRANGE,LINESTYLE=1,THICK=2
      IF (filt_on[0]) THEN BEGIN
        OPLOT,[frq_ran[0],frq_ran[0]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
        OPLOT,[frq_ran[1],frq_ran[1]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
      ENDIF
      IF (all_12_on[0]) THEN OPLOT,freq_12,pall_12,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
    PLOT,pdat1.X,pdat1.Y,_EXTRA=lim2,CHARSIZE=chsz[1]
      OPLOT,pdat1.X,pdat1.Y,THICK=2,COLOR=250
      OPLOT,pdat1.X,pdat1.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
      OPLOT,[f_sc__0[0],f_sc__0[0]],lim2.YRANGE,LINESTYLE=1,THICK=2
      IF (filt_on[0]) THEN BEGIN
        OPLOT,[frq_ran[0],frq_ran[0]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
        OPLOT,[frq_ran[1],frq_ran[1]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
      ENDIF
      IF (all_13_on[0]) THEN OPLOT,freq_13,pall_13,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
    PLOT,pdat2.X,pdat2.Y,_EXTRA=lim3,CHARSIZE=chsz[1]
      OPLOT,pdat2.X,pdat2.Y,THICK=2,COLOR=250
      OPLOT,pdat2.X,pdat2.Y,PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
      OPLOT,[f_sc__0[0],f_sc__0[0]],lim3.YRANGE,LINESTYLE=1,THICK=2
      IF (filt_on[0]) THEN BEGIN
        OPLOT,[frq_ran[0],frq_ran[0]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
        OPLOT,[frq_ran[1],frq_ran[1]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
      ENDIF
      IF (all_24_on[0]) THEN OPLOT,freq_24,pall_24,PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
      ;;  Output routine version for documentation
      XYOUTS,0.95,0.05,rvers[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=1e0
    !P.MULTI       = 0
  pclose
  ;;  Plot wavenumber magnitudes
  lim1           = lim212
  lim2           = lim213
  lim3           = lim224
  popen,'wave_4sc_wavenumber_projection_magnitude_vs_scf_frequency'+fsuff_fc[0]+fsuffx[0],_EXTRA=popen_str[0]
    !P.MULTI       = [0,1,3]
    PLOT,kdat0.X,kdat0.Y,_EXTRA=lim1,CHARSIZE=chsz[1]
      OPLOT,kdat0.X,ABS(kdat0.Y),THICK=2,COLOR=250
      OPLOT,kdat0.X,ABS(kdat0.Y),PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
      OPLOT,[f_sc__0[0],f_sc__0[0]],lim1.YRANGE,LINESTYLE=1,THICK=2
      IF (filt_on[0]) THEN BEGIN
        OPLOT,[frq_ran[0],frq_ran[0]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
        OPLOT,[frq_ran[1],frq_ran[1]],lim1.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
      ENDIF
      IF (all_12_on[0]) THEN OPLOT,freq_12,ABS(kallp12),PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
    PLOT,kdat1.X,kdat1.Y,_EXTRA=lim2,CHARSIZE=chsz[1]
      OPLOT,kdat1.X,ABS(kdat1.Y),THICK=2,COLOR=250
      OPLOT,kdat1.X,ABS(kdat1.Y),PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
      OPLOT,[f_sc__0[0],f_sc__0[0]],lim2.YRANGE,LINESTYLE=1,THICK=2
      IF (filt_on[0]) THEN BEGIN
        OPLOT,[frq_ran[0],frq_ran[0]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
        OPLOT,[frq_ran[1],frq_ran[1]],lim2.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
      ENDIF
      IF (all_13_on[0]) THEN OPLOT,freq_13,ABS(kallp13),PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
    PLOT,kdat2.X,kdat2.Y,_EXTRA=lim3,CHARSIZE=chsz[1]
      OPLOT,kdat2.X,ABS(kdat2.Y),THICK=2,COLOR=250
      OPLOT,kdat2.X,ABS(kdat2.Y),PSYM=4,THICK=2,SYMSIZE=2,COLOR= 50
      OPLOT,[f_sc__0[0],f_sc__0[0]],lim3.YRANGE,LINESTYLE=1,THICK=2
      IF (filt_on[0]) THEN BEGIN
        OPLOT,[frq_ran[0],frq_ran[0]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
        OPLOT,[frq_ran[1],frq_ran[1]],lim3.YRANGE,LINESTYLE=2,THICK=2,COLOR=200
      ENDIF
      IF (all_24_on[0]) THEN OPLOT,freq_24,ABS(kallp24),PSYM=2,THICK=2,SYMSIZE=2,COLOR=100
      ;;  Output routine version for documentation
      XYOUTS,0.95,0.05,rvers[0],CHARSIZE=.65,/NORMAL,ORIENTATION=90.,CHARTHICK=1e0
    !P.MULTI       = 0
  pclose
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
tags           = 'SC'+['12','13','24']
gplot_str      = CREATE_STRUCT(tags,gdat0,gdat1,gdat2)
pplot_str      = CREATE_STRUCT(tags,pdat0,pdat1,pdat2)
kplot_str      = CREATE_STRUCT(tags,kdat0,kdat1,kdat2)
kmlot_str      = CREATE_STRUCT(tags,kdam0,kdam1,kdam2)
gind__str      = CREATE_STRUCT([tags,'SCALL'],gind_0,gind_g1,gind_g2,gind_012)
g_mx__str      = CREATE_STRUCT([tags,'SCALL'],gind_af_a[0],gind_af_a[1],gind_af_a[2],gind_af_a[3])
g_lim_str      = CREATE_STRUCT(tags,lim012,lim013,lim024)
p_lim_str      = CREATE_STRUCT(tags,lim112,lim113,lim124)
k_lim_str      = CREATE_STRUCT(tags,lim212,lim213,lim224)
tags           = ['COHERENCE','PHASE','WAVENUMBER'+['_P','_M']]
data_struc     = CREATE_STRUCT(tags,gplot_str,pplot_str,kplot_str,kmlot_str)
lims_struc     = CREATE_STRUCT(tags,g_lim_str,p_lim_str,k_lim_str,k_lim_str)
tags           = ['DATA','LIMITS']
plot_struc     = CREATE_STRUCT(tags,data_struc,lims_struc)
tags           = ['KGSE_VEC'+['_P','_M'],'F_REST'+['_P','_M'],'KMAG'+['_P','_M'],'VPH'+['_P','_M'],'F_SC','GIND_STR']
kmax_struc     = CREATE_STRUCT(tags,kgse_pp,kgse_mm,frest_p[0],frest_m[0],kmag_pp[0],kmag_mm[0],Vphp_max[0],Vphm_max[0],f_sc__0[0],g_mx__str)
kall_struc     = CREATE_STRUCT(tags,k_ap_out,k_am_out,f_rp_out,f_rm_out,kmap_out,kmam_out,Vphp_out,Vphm_out,f_sc_out,gind__str)
tags           = ['CC_MAX','ALL']
ksol_struc     = CREATE_STRUCT(tags,kmax_struc,kall_struc)
tags           = ['TRANGES','VBULK','FREQ_RANGE','KVECS_IN','PERT','VG_STRUC','CMPLX_STRUC',$
                  'THETA_KV','PLOT_STRUCS','KSOLN_STRUC','ROT_MAT','A_MAT']
struc          = CREATE_STRUCT(tags,trans,vswo,frq_ran,kkvec,pdt[0],vg_struc,cmplx_struc,$
                               thkv_a,plot_struc,ksol_struc,b_rot,a_rot)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END


























