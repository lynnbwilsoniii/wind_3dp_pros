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
;-----------------------------------------------------------------------------------------
; => Dates, Times, and Shock Info
;-----------------------------------------------------------------------------------------

;---------------------------------------------------
;  1997-12-10
;---------------------------------------------------
date        = '121097'
t           = ['1997-12-10/03:33:00','1997-12-10/05:33:00']
tramp       = '1997-12-10/04:33:14.664'
gnorm8      = [-0.903, 0.168,-0.397]   ; => Using RH08 from JCK's site
dgnorm8     = [ 0.015, 0.032, 0.374]
gnorm9      = [-0.971, 0.094,-0.218]   ; => Using RH08 from JCK's site
dgnorm9     = [ 0.016, 0.071, 0.214]
ushn        = [ 132.3,  54.3]          ; => Up/Downstream normal flow speed [shock frame] RHO8
ushn2       = [ 124.0,  50.4]          ; => Up/Downstream normal flow speed [shock frame] RHO9
v_shn89     = [ 391.2, 403.9]          ; => Shock normal speed [SC-Frame, km/s] {RHO8, RHO9}
dv_shn89    = [  12.4,  11.7]
thetaBn89   = [  70.9,  71.9]          ; => Theta_Bn [degrees, (RH08, RH09)]
sound_updn  = [ 34.04, 43.73]          ; => Sound Speed [km/s, (up,down)stream]
valf_updn   = [ 48.44, 68.60]          ; => Alfven Speed [km/s, (up,down)stream]
machf_89    = [  2.26,  2.12]          ; => Fast Mode Mach # [RH08, RH09]
compr       = [  2.49,  0.35]          ; => Compression Ratio [value, uncertainty]
ni_up       = 11.18                    ; => Avg. upstream density [cm^(-3)]

;---------------------------------------------------
;  1998-08-26
;---------------------------------------------------
date        = '082698'
t           = ['1998-08-26/05:40:00','1998-08-26/07:40:00']  ; -For moment writing
tramp       = '1998-08-26/06:40:24.972'
gnorm8      = [-0.655, 0.040,-0.754]   ; => Using RH08 from JCK's site
dgnorm8     = [ 0.010, 0.009, 0.561]
gnorm9      = [-0.822, 0.138,-0.553]   ; => Using RH09 from JCK's site
dgnorm9     = [ 0.040, 0.070, 0.488]
ushn        = [ 401.3, 142.3]          ; => Up/Downstream normal flow speed [shock frame] RHO8
ushn2       = [ 379.6, 135.6]          ; => Up/Downstream normal flow speed [shock frame] RHO9
v_shn89     = [ 687.4, 747.2]          ; => Shock normal speed [SC-Frame, km/s] {RHO8, RHO9}
dv_shn89    = [  26.8,  25.5]
thetaBn89   = [  82.2,  78.7]          ; => Theta_Bn [degrees, (RH08, RH09)]
sound_updn  = [ 54.98,163.47]          ; => Sound Speed [km/s, (up,down)stream]
valf_updn   = [ 64.75,111.14]          ; => Alfven Speed [km/s, (up,down)stream]
machf_89    = [  4.74,  4.49]          ; => Fast Mode Mach # [RH08, RH09]
compr       = [  2.88,  0.31]          ; => Compression Ratio [value, uncertainty]
ni_up       =  6.68                    ; => Avg. upstream density [cm^(-3)]

;---------------------------------------------------
;  1998-09-24
;---------------------------------------------------
date        = '092498'
t           = ['1998-09-24/22:20:00','1998-09-25/00:20:00']
tramp       = '1998-09-24/23:20:37.374'
gnorm8      = [-0.914,-0.220,-0.341]   ; => Using RH08 from JCK's site
dgnorm8     = [ 0.004, 0.009, 0.327]
gnorm9      = [-0.939,-0.175,-0.296]   ; => Using RH09 from JCK's site
dgnorm9     = [ 0.024, 0.070, 0.287]
ushn        = [ 386.3, 174.6]          ; => Up/Downstream normal flow speed [shock frame] RHO8
ushn2       = [ 381.2, 171.3]          ; => Up/Downstream normal flow speed [shock frame] RHO9
v_shn89     = [ 772.4, 780.0]          ; => Shock normal speed [SC-Frame, km/s] {RHO8, RHO9}
dv_shn89    = [  95.6,  95.5]
thetaBn89   = [  82.1,  78.6]          ; => Theta_Bn [degrees, (RH08, RH09)]
sound_updn  = [ 68.20,133.24]          ; => Sound Speed [km/s, (up,down)stream]
valf_updn   = [114.45,213.44]          ; => Alfven Speed [km/s, (up,down)stream]
machf_89    = [  2.91,  2.87]          ; => Fast Mode Mach # [RH08, RH09]
compr       = [  2.17,  0.38]          ; => Compression Ratio [value, uncertainty]
ni_up       =  8.40                    ; => Avg. upstream density [cm^(-3)]

;---------------------------------------------------
;  2000-02-11 [B]
;---------------------------------------------------
date        = '021100'
t           = ['2000-02-11/22:33:00','2000-02-12/00:33:00']
tramp       = '2000-02-11/23:33:55.319'
gnorm8      = [-0.865,-0.452, 0.218]   ; => Using RH08 from JCK's site
dgnorm8     = [ 0.017, 0.030, 0.214]
gnorm9      = [-0.930,-0.367,-0.028]   ; => Using RH09 from JCK's site
dgnorm9     = [ 0.025, 0.063, 0.028]
ushn        = [ 263.6,  81.7]          ; => Up/Downstream normal flow speed [shock frame] RHO8
ushn2       = [ 255.3,  79.3]          ; => Up/Downstream normal flow speed [shock frame] RHO9
v_shn89     = [ 641.4, 661.1]          ; => Shock normal speed [SC-Frame, km/s] {RHO8, RHO9}
dv_shn89    = [  13.2,  12.3]
thetaBn89   = [  86.5,  89.9]          ; => Theta_Bn [degrees, (RH08, RH09)]
sound_updn  = [ 46.87, 77.54]          ; => Sound Speed [km/s, (up,down)stream]
valf_updn   = [ 66.20,123.23]          ; => Alfven Speed [km/s, (up,down)stream]
machf_89    = [  3.25,  3.15]          ; => Fast Mode Mach # [RH08, RH09]
compr       = [  3.27,  0.50]          ; => Compression Ratio [value, uncertainty]
ni_up       =  5.31                    ; => Avg. upstream density [cm^(-3)]

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

store_data,'wi_B3_MAG',DATA=bmags
store_data,'wi_B3_GSE',DATA=bgse
store_data,'wi_B3_GSM',DATA=bgsm
nn0    = ['wi_B3_MAG','wi_B3_GSE']
options,'wi_B3_MAG','YTITLE','|B| [3s, nT]'
options,'wi_B3_GSE','YTITLE','B (nT)!C[GSE, 3s]'
options,'wi_B3_GSM','YTITLE','B (nT)!C[GSM, 3s]'
options,['wi_B3_GSE','wi_B3_GSM'],'COLORS',[250,150,50]
tplot_options,'XMARGIN',[18,12]
tplot_options,'YMARGIN',[5,5]

WINDOW,0,RETAIN=2,XSIZE=1700,YSIZE=1100
tplot,nn0,TRANGE=tr3
;-----------------------------------------------------------------------------------------
; => HTR B-fields
;-----------------------------------------------------------------------------------------
mfihtr   = read_wind_htr_mfi(TRANGE=tr3)
bgse_htr = mfihtr.BGSE
bgsm_htr = mfihtr.BGSM
bmag_htr = mfihtr.BMAG
t3x_htr  = bgse_htr.X
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


;;-------------------------------------------------------------
;; => Send to TPLOT
;;-------------------------------------------------------------
store_data,'wi_BHTR_MAG',DATA=bmag_htr
store_data,'wi_BHTR_GSE',DATA=bgse_htr
store_data,'wi_BHTR_GSM',DATA=bgsm_htr
nnh      = ['wi_BHTR_MAG','wi_BHTR_GSE']

options,'wi_BHTR_MAG','YTITLE','|B| [HTR, nT]'
options,'wi_BHTR_GSE','YTITLE','B (nT)!C[GSE, HTR]'
options,'wi_BHTR_GSM','YTITLE','B (nT)!C[GSM, HTR]'
options,['wi_BHTR_GSE','wi_BHTR_GSM'],'COLORS',[250,150,50]
;-----------------------------------------------------------------------------------------
; => Get TDSS times
;-----------------------------------------------------------------------------------------
ntds     = 2048L
waves0   = tdss_sort_relevant(DATE=date,/FIXFILE)
sceta0   = waves0.SCETS                  ; => e.g. '1998-08-26/06:40:24.472'
tt0      = REFORM(waves0.TIMES)          ; => Times (ms)
unixs0   = time_double(sceta0)
unixa0   = (unixs0 # REPLICATE(1d0,ntds)) + tt0*1d-3
unixe0   = unixa0[*,(ntds - 1L)]

tdss_unx = unixs0
;-----------------------------------------------------------------------------------------
; => Load orbit data
;-----------------------------------------------------------------------------------------
wind_orbit_to_tplot,BNAME='wi_B3_GSE',TRANGE=tr3
options,'Wind_Radial_Distance','YTITLE','Radial Dist. (R!DE!N)'
options,'Wind_GSE_Latitude','YTITLE','GSE Lat. [deg]'
options,'Wind_GSE_Longitude','YTITLE','GSE Lon. [deg]'
gnames = ['Wind_Radial_Distance','Wind_GSE_Latitude','Wind_GSE_Longitude','Wind_MLT']
tplot_options, var_label=gnames

htr_t  = t3x_htr
nhtr_t = htr_t - tura[0]   ; => normalize to zero
ndist  = v_shn89[0]*nhtr_t   ; => km
; => Compute estimates of upstream inertial lengths
IF (FINITE(ni_up[0])) THEN einert = c/(wpefac[0]*SQRT(ni_up[0])) ELSE einert = f
IF (FINITE(ni_up[0])) THEN iinert = c/(wppfac[0]*SQRT(ni_up[0])) ELSE iinert = f
einert *= 1d-3  ; => Convert to km
iinert *= 1d-3  ; => Convert to km

store_data,'normal_distance',DATA={X:htr_t,Y:ndist}
options,'normal_distance','YTITLE','Dist. [Normal, km]'
store_data,'normal_distance_c-wpe',DATA={X:htr_t,Y:ndist/einert[0]}
options,'normal_distance_c-wpe','YTITLE','Dist. [Normal, c/'+'!7x!3'+'!Dpe!N'+']'
store_data,'normal_distance_c-wpi',DATA={X:htr_t,Y:ndist/iinert[0]}
options,'normal_distance_c-wpi','YTITLE','Dist. [Normal, c/'+'!7x!3'+'!Dpi!N'+']'

gnames = ['Wind_Radial_Distance','normal_distance','normal_distance_c-wpe','normal_distance_c-wpi']
tplot_options, VAR_LABEL=gnames

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04
;-----------------------------------------------------------------------------------------
; => Load 3DP Distributions into TPLOT
;-----------------------------------------------------------------------------------------
eesa    = 1
pesa    = 1
sstf    = 0
ssto    = 0
test    = wind_3dp_save_file_get(TRANGE=tr3,EESA=eesa,PESA=pesa,SSTF=sstf,SSTO=ssto)

; => Define EESA structures
ael     = eesa.EL
aelb    = eesa.ELB
aeh     = eesa.EH
aehb    = eesa.EHB
; => Define PESA structures
apl     = pesa.PL
aplb    = pesa.PLB
aph     = pesa.PH
aphb    = pesa.PHB
;-----------------------------------------------------------------------------------------
; => Calc Density, temp, etc... for ions and electrons
;-----------------------------------------------------------------------------------------
eesa_pesa_low_to_tplot,DATE=date,TRANGE=tr3,/G_MAGF,PLM=apl,PLBM=aplb, $
                       ELM=ael,ELBM=aelb,/TO_TPLOT,BNAME='wi_B3_GSE'

nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04


add_vsw2,ael,'V_sw2'
add_magf2,ael,'wi_B3_GSE'
add_scpot,ael,'sc_pot_3'
add_vsw2,aelb,'V_sw2'
add_magf2,aelb,'wi_B3_GSE'
add_scpot,aelb,'sc_pot_3'


add_vsw2,aph,'V_sw2'
add_magf2,aph,'wi_B3_GSE'
add_scpot,aph,'sc_pot_3'
add_vsw2,aphb,'V_sw2'
add_magf2,aphb,'wi_B3_GSE'
add_scpot,aphb,'sc_pot_3'


;;add_vsw2,aelb,'Velocity_el_sc'
;-----------------------------------------------------------------------------------------
; => Get spacecraft spin rates
;-----------------------------------------------------------------------------------------
wi_spin = read_wind_spinphase(TRANGE=tr3)
wi_spru = wi_spin.UNIX         ; => Unix times
wi_sprd = wi_spin.SPIN_RATE_D  ; => Wind spin rate [deg/s]
;-----------------------------------------------------------------------------------------
; => Calculate PAD using HTR MFI data instead of single 3s B-field value
;-----------------------------------------------------------------------------------------
WINDOW,1,RETAIN=2,XSIZE=800,YSIZE=1100

num_pa  = 24L            ; => # of pitch-angle bins
ngrid   = 30L
vlim    = 20e3
sunv    = [1.,0.,0.]
sunn    = 'Sun Dir.'
gnorm   = gnorm8
dfra    = [1e-15,1e-10]     ; => For 1998-08-26
;dfra    = [1e-15,5e-11]     ; => For 2000-02-11 [B]

j       = 77L
dat0    = aelb[j]        ; => EESA Low Burst 3DP IDL data structure
t0      = dat0.TIME[0]
t1      = dat0.END_TIME[0]
n_e     = dat0.NENERGY   ; => # of energy bins
n_a     = dat0.NBINS     ; => # of angle bins

sprated = interp(wi_sprd,wi_spru,t0[0],INDEX=ind)
sprated = wi_sprd[ind]
; => Determine time stamps associated with each angle bin
time_a  = timestamp_3dp_angle_bins(dat0,sprated[0])
; => Convert into solar wind frame
tad     = convert_vframe(dat0,/INTERP)
; => Calculate pitch-angle distribution (PAD)
times_0 = time_a
magfhtr = bgse_htr
pd_htr  = pad_htr_magf(tad,times_0,magfhtr,NUM_PA=num_pa[0])
; => Calculate corresponding velocity distribution function (DF)
df      = distfunc(pd_htr.ENERGY,pd_htr.ANGLES,MASS=pd_htr.MASS,DF=pd_htr.DATA)
extract_tags,tad,df

; => Plot PAD
WSET,1
my_padplot_both,pd_htr,UNITS='flux',EBINS=[0L,9L]

; => Plot DF assuming gyrotropy
WSET,1
vgy     = velocity(tad.SC_POT[0],tad.MASS[0],/TRUE)
cont2d,tad,NGRID=ngrid,VLIM=vlim,GNORM=gnorm8,/HEAT_F,/V_TH,/ANI_TEMP,MYONEC=dat0,$
           VCIRC=vgy[0],EX_VEC0=sunv,EX_VN0=sunn
;-----------------------------------------------------------------------------------------
; => Plot DFs using 3s B-field value
;-----------------------------------------------------------------------------------------
trr      = tura[0] + [-1d0,1d0]*15d1
nna      = nnh
WSET,0
tplot,nna,TRANGE=trr
time_bar,tdss_unx,VARNAME=nna,COLOR=250

WINDOW,1,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,2,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,3,RETAIN=2,XSIZE=800,YSIZE=1100
WINDOW,4,RETAIN=2,XSIZE=800,YSIZE=1100

;PRINT,'; ', TRANSPOSE(sceta0[gels])
;  1998-08-26/06:41:08.353   [EL :  66-69, PH : 69-72]
;  1998-08-26/06:42:04.115   [EL :  84-89, PH : 86-91]

ngrid   = 30L
sunv    = [1.,0.,0.]
sunn    = 'Sun Dir.'
gnorm   = gnorm8
normnm  = 'Shock Normal'
xname   = 'B!Do!N'
yname   = 'V!Dsw!N'


; => EESA Low
vlim    = 20e3
; => Put a circles of constant energy at 5000 km/s increments on contours
vcirc   = 5d3*[1d0,2d0,3d0]
dfra    = [1e-15,1e-10]     ; => For 1998-08-26
;dfra    = [1e-15,5e-11]     ; => For 2000-02-11 [B]
ns      = 3L
smc     = 1
smct    = 1
inter   = 1



j       = 63L
dat     = aelb[j]
vec1    = dat.MAGF
vec2    = dat.VSW

WSET,1
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[*],PLANE='xy',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

WSET,2
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[*],PLANE='xz',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

WSET,3
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[*],PLANE='yz',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter


;; save plots
dfra     = [1e-15,1e-10]     ; => For 1998-08-26
;dfra     = [1e-15,5e-11]     ; => For 2000-02-11 [B]
yra_str  = STRING(dfra,FORMAT='(E10.1)')
yra_s2   = STRCOMPRESS(string_replace_char(yra_str,'+',''),/REMOVE_ALL)
yra_suf  = yra_s2[0]+'_'+yra_s2[1]
df_sfx   = yra_suf[0]


gael     = aelb
nall     = N_ELEMENTS(gael)

fnm      = file_name_times(aelb.TIME[0],PREC=3)
ftimes   = fnm.F_TIME          ;; e.g. 1998-08-09_0801x09.494
dfdir    = FILE_EXPAND_PATH('')+'/'
gr_str   = STRTRIM(STRING(FORMAT='(I2.2)',ngrid),2)+'Grids'
dfsuff   = '_3D-'+gr_str[0]+'-one-count_SCPot-Vsw-Bo_norm-RH08_DF_'

pref     = dfdir[0]+'elb_3s-mfi_'
fnames   = pref[0]+ftimes+dfsuff[0]+yra_suf[0]

FOR j=0L, nall - 1L DO BEGIN                                                         $
  dat    = gael[j]                                                                 & $
  vec1   = dat[0].MAGF                                                             & $
  vec2   = dat[0].VSW                                                              & $
  vcirc   = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])                         & $
  popen,fnames[j],/PORT                                                            & $
    contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,               $
                              YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,             $
                              DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv,      $
                              EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],         $
                              SM_CONT=smct,/NO_REDF,INTERP=inter                   & $
  pclose


;; Check SC Potential Estimate
j       = 63L
dat     = aelb[j]
vec1    = dat.MAGF
vec2    = dat.VSW
scpot_0 = dat.SC_POT[0]
scpot_n = scpot_0[0]*[125e-2,75e-2,50e-2]
PRINT,';', scpot_0[0], scpot_n[0], scpot_n[1], scpot_n[2], '  :  for  '+time_string(dat.TIME,PREC=3)
;      15.9210      19.9012      11.9407      7.96050  :  for  1998-08-26/06:40:46.484
;      16.5993      20.7491      12.4495      8.29965  :  for  1998-08-26/06:41:36.111


dat.SC_POT = scpot_0[0]
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
WSET,1
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[*],PLANE='xy',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

dat.SC_POT = scpot_n[0]
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
WSET,2
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[*],PLANE='xy',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

dat.SC_POT = scpot_n[1]
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
WSET,3
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[*],PLANE='xy',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

dat.SC_POT = scpot_n[2]
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
WSET,4
contour_3d_1plane,dat,vec1,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,        $
                      DFRA=dfra,VCIRC=vcirc[*],PLANE='xy',EX_VEC1=sunv, $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],    $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

;-----------------------------------------------------------------------------------------
; => Plot DFs using HTR B-field value
;-----------------------------------------------------------------------------------------
magfhtr = bgse_htr       ; => HTR MFI data to use
ngrid   = 30             ; => # of grids in contour
vlim    = 2d4            ; => velocity limit (km/s)
sunv    = [1.,0.,0.]     ; => sun direction in GSE coordinates
sunn    = 'Sun Dir.'     ; => string associated with sun direction
gnorm   = gnorm8
normnm  = 'Shock Normal'
xname   = 'B!Do!N'
yname   = 'V!Dsw!N'
ns      = 3L
smc     = 1
smct    = 1
inter   = 1

dfra    = [1e-15,1e-10]     ; => For 1998-08-26
;dfra    = [1e-15,5e-11]     ; => For 2000-02-11 [B]

j       = 63L
dat     = aelb[j]
vec2    = dat.VSW


WSET,1
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
contour_3d_htr_1plane,dat,magfhtr,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,             $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv,      $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],         $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

WSET,2
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
contour_3d_htr_1plane,dat,magfhtr,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,             $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xz',EX_VEC1=sunv,      $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],         $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

WSET,3
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
contour_3d_htr_1plane,dat,magfhtr,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,             $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='yz',EX_VEC1=sunv,      $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],         $
                      SM_CONT=smct,/NO_REDF,INTERP=inter



;; Check SC Potential Estimate
j       = 63L
dat     = aelb[j]
vec2    = dat.VSW
scpot_0 = dat.SC_POT[0]
scpot_n = scpot_0[0]*[125e-2,75e-2,50e-2]
PRINT,';', scpot_0[0], scpot_n[0], scpot_n[1], scpot_n[2], '  :  for  '+time_string(dat.TIME,PREC=3)
;      15.9210      19.9012      11.9407      7.96050  :  for  1998-08-26/06:40:46.484
;      16.6475      20.8094      12.4857      8.32377  :  for  1998-08-26/06:41:33.009
;      16.5993      20.7491      12.4495      8.29965  :  for  1998-08-26/06:41:36.111

WSET,1
dat.SC_POT = scpot_0[0]
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
contour_3d_htr_1plane,dat,magfhtr,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,             $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv,      $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],         $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

WSET,2
dat.SC_POT = scpot_n[0]
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
contour_3d_htr_1plane,dat,magfhtr,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,             $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv,      $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],         $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

WSET,3
dat.SC_POT = scpot_n[1]
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
contour_3d_htr_1plane,dat,magfhtr,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,             $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv,      $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],         $
                      SM_CONT=smct,/NO_REDF,INTERP=inter

WSET,4
dat.SC_POT = scpot_n[2]
vcirc      = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])
contour_3d_htr_1plane,dat,magfhtr,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,    $
                      YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,             $
                      DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv,      $
                      EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],         $
                      SM_CONT=smct,/NO_REDF,INTERP=inter


nn         = 30L
scmax      = 150e-2
scmin      =  25e-2
scpot_a    = (FINDGEN(nn)*(scmax[0] - scmin[0])/(nn - 1L) + scmin[0])*scpot_0[0]
scp_str    = STRTRIM(STRING(FORMAT='(f10.2)',scpot_a),2)
scsuff     = '_SCPot_'+scp_str+'eV'

dfra       = [1e-15,1e-10]     ; => For 1998-08-26
;dfra       = [1e-15,5e-11]     ; => For 2000-02-11 [B]
yra_str    = STRING(dfra,FORMAT='(E10.1)')
yra_s2     = STRCOMPRESS(string_replace_char(yra_str,'+',''),/REMOVE_ALL)
yra_suf    = yra_s2[0]+'_'+yra_s2[1]
df_sfx     = yra_suf[0]

fnm        = file_name_times(dat.TIME[0],PREC=3)
ftimes     = fnm.F_TIME[0]          ;; e.g. 1998-08-09_0801x09.494
dfdir      = FILE_EXPAND_PATH('')+'/'
dfsuff     = '_3D-30Grids-one-count_norm-RH08_DF_'+yra_suf[0]
pref       = dfdir[0]+'elb_htr-mfi_'
fnames     = pref[0]+ftimes[0]+dfsuff[0]+scsuff
FOR j=0L, nn - 1L DO BEGIN                                                         $
  vec2   = dat[0].VSW                                                            & $
  scpot  = scpot_a[j]                                                            & $
  vcirc  = energy_to_vel(scpot[0],dat[0].MASS[0])                                & $
  dat.SC_POT = scpot[0]                                                          & $
  popen,fnames[j],/PORT                                                          & $
    contour_3d_htr_1plane,dat,magfhtr,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,      $
                              YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,           $
                              DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv,    $
                              EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],       $
                              SM_CONT=smct,/NO_REDF,INTERP=inter                 & $
  pclose




;; save plots
dfra    = [1e-15,1e-10]     ; => For 1998-08-26
;dfra    = [1e-15,5e-11]     ; => For 2000-02-11 [B]
yra_str = STRING(dfra,FORMAT='(E10.1)')
yra_s2  = STRCOMPRESS(string_replace_char(yra_str,'+',''),/REMOVE_ALL)
yra_suf = yra_s2[0]+'_'+yra_s2[1]
df_sfx  = yra_suf[0]


gael    = aelb
nall    = N_ELEMENTS(gael)

fnm     = file_name_times(gael.TIME,PREC=3)
ftimes  = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
dfdir   = FILE_EXPAND_PATH('')+'/'

dfsuff  = '_3D-30Grids-one-count_SCPot-Vsw-Bo_norm-RH08_DF_'
pref    = dfdir[0]+'elb_htr-mfi_'
fnames  = pref[0]+ftimes+dfsuff[0]+yra_suf[0]

FOR j=0L, nall - 1L DO BEGIN                                                         $
  dat    = gael[j]                                                                 & $
  vec2   = dat[0].VSW                                                              & $
  vcirc   = energy_to_vel(dat[0].SC_POT[0],dat[0].MASS[0])                         & $
  popen,fnames[j],/PORT                                                            & $
    contour_3d_htr_1plane,dat,magfhtr,vec2,VLIM=vlim,NGRID=ngrid,XNAME=xname,        $
                              YNAME=yname,SM_CUTS=smc,NSMOOTH=ns,/ONE_C,             $
                              DFRA=dfra,VCIRC=vcirc[0],PLANE='xy',EX_VEC1=sunv,      $
                              EX_VN1=sunn[0],EX_VEC0=gnorm,EX_VN0=normnm[0],         $
                              SM_CONT=smct,/NO_REDF,INTERP=inter                   & $
  pclose

