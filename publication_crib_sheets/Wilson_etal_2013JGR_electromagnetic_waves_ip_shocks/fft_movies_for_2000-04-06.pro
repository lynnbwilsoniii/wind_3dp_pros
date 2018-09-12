;-----------------------------------------------------------------------------------------
; => Constants and dummy variables
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
epo    = 8.854187817d-12   ; => Permittivity of free space (F/m)
muo    = 4d0*!DPI*1d-7     ; => Permeability of free space (N/A^2 or H/m)
me     = 9.10938291d-31    ; => Electron mass (kg) [2010 value]
mp     = 1.672621777d-27   ; => Proton mass (kg) [2010 value]
ma     = 6.64465675d-27    ; => Alpha-Particle mass (kg) [2010 value]
qq     = 1.602176565d-19   ; => Fundamental charge (C) [2010 value]
kB     = 1.3806488d-23     ; => Boltzmann Constant (J/K) [2010 value]
K_eV   = 1.1604519d4       ; => Factor [Kelvin/eV] [2010 value]
c      = 2.99792458d8      ; => Speed of light in vacuum (m/s)
R_E    = 6.37814d3         ; => Earth's Equitorial Radius (km)
NG     = 6.67384d-11       ; => Newtonian constant of gravitation [m^3 kg^(-1) s^(-2)]
c2     = (c*1d-3)^2        ; -" " squared (km/s)^2
me_ev  = 0.5109906d6       ; -Electron mass in eV/c^2
me_3dp = me_ev/c2          ; -Electron mass [eV/(km/s)^2]
mp_ev  = 938.27231d6       ; -Proton mass in eV/c^2
mp_3dp = mp_ev/c2          ; -Proton mass [eV/(km/s)^2]

invdenf = 1d-6*(2d0*!DPI)^2*(me*epo/qq^2)  ; => [cm^(-3) s^2]

fcefac  = qq/me*1d-9/(2d0*!DPI)
fcpfac  = qq/mp*1d-9/(2d0*!DPI)
fpefac  = SQRT(1d6*qq^2/me/epo)/(2d0*!DPI)
fppfac  = SQRT(1d6*qq^2/mp/epo)/(2d0*!DPI)
beta_fac = 1d6*(kB*K_eV)*(2d0*muo)
; => Multiplication factors for plasma frequency calculations [to angular frequency]
wpefac  = SQRT(1d6*qq^2/me/epo)
wppfac  = SQRT(1d6*qq^2/mp/epo)
;---------------------------------------------------
;  2000-04-06
;---------------------------------------------------
date        = '040600'
t           = ['2000-04-06/15:00:00','2000-04-06/18:00:00']
tramp       = '2000-04-06/16:32:09.237'
gnorm8      = [-0.984,-0.078,-0.162]   ; => Using RH08 from JCK's site
dgnorm8     = [ 0.002, 0.009, 0.161]
gnorm9      = [-0.988,-0.061,-0.140]   ; => Using RH09 from JCK's site
dgnorm9     = [ 0.011, 0.070, 0.139]
ushn        = [ 278.1, 79.8]           ; => Up/Downstream normal flow speed [shock frame] RHO8
ushn2       = [ 277.4, 79.7]           ; => Up/Downstream normal flow speed [shock frame] RHO9
v_shn89     = [ 646.9, 647.1]          ; => Shock normal speed [SC-Frame, km/s] {RHO8, RHO9}
dv_shn89    = [  97.9,  97.6]
thetaBn89   = [  69.6,  68.5]          ; => Theta_Bn [degrees, (RH08, RH09)]
sound_updn  = [ 29.87, 92.08]          ; => Sound Speed [km/s, (up,down)stream]
valf_updn   = [ 64.81,136.41]          ; => Alfven Speed [km/s, (up,down)stream]
machf_89    = [  3.97,  3.97]          ; => Fast Mode Mach # [RH08, RH09]
compr       = [  3.84,  1.25]          ; => Compression Ratio [value, uncertainty]
ni_up       =  8.62                    ; => Avg. upstream density [cm^(-3)]
;-----------------------------------------------------------------------------------------
; => Dates and Times
;-----------------------------------------------------------------------------------------
tr3         = time_double(t)
tura        = time_double(tramp)
mydate      = my_str_date(DATE=date)
date        = mydate.S_DATE[0]  ; -('MMDDYY')
mdate       = mydate.DATE[0]    ; -('YYYYMMDD')
tdate       = mydate.TDATE[0]
;-----------------------------------------------------------------------------------------
; => 3s B-fields
;-----------------------------------------------------------------------------------------
mfi3s  = read_wind_mfi(TRANGE=tr3)
bgse   = mfi3s.BGSE
bgsm   = mfi3s.BGSM
bmags  = mfi3s.MAG
t3x    = bgse.X
nt     = N_ELEMENTS(t3x)
;----------------------------------------------
; => Special 1998-08-26 and 2000-04-06 cases
;----------------------------------------------
mdir   = FILE_EXPAND_PATH('IDL_stuff/cribs/wind_htr_mfi_files/')
mfiles = FILE_SEARCH(mdir,'wi_h2_mfi_*_sine_and_spline.cdf')
; => Read CDF file with splined and sine-wave fits
bnm_epoch = STRLOWCASE('Epoch')   ; => " " HTR Epoch times
bnm_gse   = STRLOWCASE('BGSE')    ; => CDF tag for HTR GSE B-field data
bnm_gsm   = STRLOWCASE('BGSM')    ; => CDF tag for HTR GSM B-field data
IF (date EQ '082698') THEN tyfile = mfiles[0]
IF (date EQ '040600') THEN tyfile = mfiles[1]
; => Read CDF file with GSE/GSM data ("fixed" saturated)
windmm    = read_cdf(tyfile[0],data_gse,var_gse,/NOTIME)
!QUIET    = 0

var_lw    = STRLOWCASE(REFORM(var_gse[*,0]))
g_bgse    = WHERE(var_lw EQ bnm_gse  ,ggse)   ; => Elements of Pointer for HTR GSE data
g_bgsm    = WHERE(var_lw EQ bnm_gsm  ,ggsm)   ; => Elements of Pointer for HTR GSM data
g_epo3    = WHERE(var_lw EQ bnm_epoch,gep3)   ; => Element for Epoch times
; => Define dummy variables
IF (ggse GT 0) THEN tgsemag = *data_gse[g_bgse[0]]
IF (ggsm GT 0) THEN tgsmmag = *data_gse[g_bgsm[0]]
IF (gep3 GT 0) THEN tempepo = *data_gse[g_epo3[0]]
; => Convert Epoch times to Unix
unx_gse = epoch2unix(tempepo)
mag_gse = tgsemag
mag_gsm = tgsmmag
; => Release pointer and increment index markers
PTR_FREE,data_gse
DELVAR,tgsemag,tgsmmag,tempepo,var_cnts,var_lw

; => keep only between time range
good     = WHERE(unx_gse GE tr3[0] AND unx_gse LE tr3[1],gd)
t3x_htr  = unx_gse[good]
nhtr     = N_ELEMENTS(t3x_htr)
mag_gse  = mag_gse[good,*]
mag_gsm  = mag_gsm[good,*]
bmag     = SQRT(TOTAL(mag_gse^2,2L,/NAN))
; => Create structures for TPLOT
bgse_htr = {X:t3x_htr,Y:mag_gse}
bgsm_htr = {X:t3x_htr,Y:mag_gsm}
bmag_htr = {X:t3x_htr,Y:bmag}
;-----------------------------------------------------------------------------------------
; => Create FFT Movies
;-----------------------------------------------------------------------------------------
nhtr0   = N_ELEMENTS(t3x_htr)

unix0   = t3x_htr
magf0   = mag_gse
ymdb0   = time_string(unix0,PREC=3)
ztime0  = unix0 - MIN(unix0,/NAN)          ; => Seconds from zero
evlen0  = MAX(unix0,/NAN) - MIN(unix0,/NAN)
samra0  = (nhtr0 - 1L)/evlen0[0]                 ; => Sample Rate [samples per second]
PRINT,';  ',samra0[0],'   =>  For  '+ymdb0[0]
;         10.843639   =>  For  2000-04-06/15:00:00.042



; => Make MPEG Movie
frange   = [1e-3,6e0]
prange   = [1e-4,1e4]
fftlen   = 2048L
;fftst    = 8L
fftst    = 128L
;fftst    = 256L
vecl     = ['x','y','z']
vecu     = STRUPCASE(vecl)
suffx    = '_'+STRING(FORMAT='(I4.4)',fftlen[0])+'pts-'+$
               STRING(FORMAT='(I4.4)',fftst[0])+'pt-shift'
yttlfs   = 'B'+vecl+' Power Spectra [(nT)!U2!N'+'/Hz]'
yttlws   = 'B'+vecl+' [GSE, nT]'
xttl     = 'Time (UT)'

pnames   = ['10!U-4!N','10!U-3!N','10!U-2!N','10!U-1!N','10!U+0!N','10!U+1!N','10!U+2!N','10!U+3!N']
pvals    = [1d-4,1d-3,1d-2,1d-1,1d0,1d1,1d2,1d3]
pticks   = N_ELEMENTS(pvals) - 1L
fstrx    = {XLOG:1,YLOG:1,YTITLE:yttlfs[0],XTITLE:'Frequency (Hz)',$
            YTICKNAME:pnames,YTICKV:pvals,YTICKS:pticks,YMINOR:9L}
fstry    = {XLOG:1,YLOG:1,YTITLE:yttlfs[1],XTITLE:'Frequency (Hz)',$
            YTICKNAME:pnames,YTICKV:pvals,YTICKS:pticks,YMINOR:9L}
fstrz    = {XLOG:1,YLOG:1,YTITLE:yttlfs[2],XTITLE:'Frequency (Hz)',$
            YTICKNAME:pnames,YTICKV:pvals,YTICKS:pticks,YMINOR:9L}


fnm0     = file_name_times(ymdb0[[0L,nhtr0-1L]],PREC=0)
sfname0  = fnm0.F_TIME[0]+'_'+fnm0.F_TIME[1]
fnames0  = 'HTR-MFI_'+vecu+'-GSE_Movie_'+sfname0[0]+suffx[0]

wnames0  = ['15:00','15:15','15:30','15:45','16:00','16:15','16:30','16:45','17:00','17:15','17:30','17:45']
ntcks    = N_ELEMENTS(wnames0)
wvals0   = (DINDGEN(ntcks) + 1d0)*(15d0*6d1)
wticks0  = N_ELEMENTS(wvals0) - 1L
wstr0x   = {XTICKNAME:wnames0,XTICKV:wvals0,XTICKS:wticks0,XTITLE:xttl,YTITLE:yttlws[0]}
wstr0y   = {XTICKNAME:wnames0,XTICKV:wvals0,XTICKS:wticks0,XTITLE:xttl,YTITLE:yttlws[1]}
wstr0z   = {XTICKNAME:wnames0,XTICKV:wvals0,XTICKS:wticks0,XTITLE:xttl,YTITLE:yttlws[2]}

fft_movie,ztime0,magf0[*,0],fftlen,fftst,MOVIENAME=fnames0[0],$
          /FULLSERIES,WSTRUCT=wstr0x,FSTRUCT=fstrx,FRANGE=frange, $
          PRANGE=prange,/NO_INTERP,/READ_WIN,/SNAPSHOTS

fft_movie,ztime0,magf0[*,1],fftlen,fftst,MOVIENAME=fnames0[1],$
          /FULLSERIES,WSTRUCT=wstr0y,FSTRUCT=fstry,FRANGE=frange, $
          PRANGE=prange,/NO_INTERP,/READ_WIN,/SNAPSHOTS

fft_movie,ztime0,magf0[*,2],fftlen,fftst,MOVIENAME=fnames0[2],$
          /FULLSERIES,WSTRUCT=wstr0z,FSTRUCT=fstrz,FRANGE=frange, $
          PRANGE=prange,/NO_INTERP,/READ_WIN,/SNAPSHOTS


yttlfs   = '|B| Power Spectra [(nT)!U2!N'+'/Hz]'
yttlws   = '|B| [GSE, nT]'
xttl     = 'Time (UT)'
fstrx    = {XLOG:1,YLOG:1,YTITLE:yttlfs[0],XTITLE:'Frequency (Hz)',$
            YTICKNAME:pnames,YTICKV:pvals,YTICKS:pticks,YMINOR:9L}
fnames0  = 'HTR-MFI_B-Mag_Movie_'+sfname0[0]+suffx[0]

fft_movie,ztime0,bmag,fftlen,fftst,MOVIENAME=fnames0[0],          $
          /FULLSERIES,WSTRUCT=wstr0x,FSTRUCT=fstrx,FRANGE=frange, $
          PRANGE=prange,/NO_INTERP,/READ_WIN,/SNAPSHOTS


.compile fft_movie_psd
.compile fft_movie_plot
.compile fft_movie

