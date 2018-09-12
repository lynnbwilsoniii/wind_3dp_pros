;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
me             = 9.1093829100d-31     ;;  Electron mass [kg]
mp             = 1.6726217770d-27     ;;  Proton mass [kg]
ma             = 6.6446567500d-27     ;;  Alpha-Particle mass [kg]
c              = 2.9979245800d+08     ;;  Speed of light in vacuum [m/s]
epo            = 8.8541878170d-12     ;;  Permittivity of free space [F/m]
muo            = !DPI*4.00000d-07     ;;  Permeability of free space [N/A^2 or H/m]
qq             = 1.6021765650d-19     ;;  Fundamental charge [C]
kB             = 1.3806488000d-23     ;;  Boltzmann Constant [J/K]
hh             = 6.6260695700d-34     ;;  Planck Constant [J s]
GG             = 6.6738400000d-11     ;;  Newtonian Constant [m^(3) kg^(-1) s^(-1)]

f_1eV          = qq[0]/hh[0]          ;;  Freq. associated with 1 eV of energy [Hz]
J_1eV          = hh[0]*f_1eV[0]       ;;  Energy associated with 1 eV of energy [J]
;;  Temp. associated with 1 eV of energy [K]
K_eV           = qq[0]/kB[0]          ;; ~ 11,604.519 K
R_E            = 6.37814d3            ;;  Earth's Equitorial Radius [km]

wpefac         = SQRT(1d6*qq[0]^2/(epo[0]*me[0]))
wpifac         = SQRT(1d6*qq[0]^2/(epo[0]*mp[0]))
wcefac         = qq[0]*1d-9/me[0]
wcifac         = qq[0]*1d-9/mp[0]
ckm            = c[0]*1d-3            ;;  m --> km

nkT_fac        = 1d6*J_1eV[0]                        ;;  cm^(-3) --> m^(-3), eV --> J
B2_2muo_fac    = 1d-9^2/(2d0*muo[0])                 ;;  nT^(2) --> T^(2), divide by 2µ_o
VA_fac         = (1d-9/SQRT(1d6*muo[0]*mp[0]))*1d-3  ;;  nT --> T, cm^(-3) --> m^(-3), m/s --> km/s
;;  Define shock normal vectors [GSE]
all_norms      = [ [ 0.99533337d0, 0.02216223d0,-0.09391658d0],$
                   [ 0.93992965d0, 0.32618259d0,-0.10068357d0],$
                   [ 0.99364314d0, 0.04657624d0, 0.10248889d0],$
                   [ 0.99382696d0,-0.10677753d0,-0.03010859d0],$
                   [ 0.99606840d0, 0.01022162d0,-0.08799578d0],$
                   [ 0.91986927d0, 0.36689695d0, 0.13866201d0],$
                   [ 0.92968239d0, 0.30098043d0,-0.21237099d0],$
                   [ 0.93123543d0, 0.29478399d0, 0.21424979d0],$
                   [ 0.99876535d0,-0.03063744d0,-0.03910405d0],$
                   [ 0.91407238d0, 0.28739631d0, 0.28613816d0],$
                   [ 0.87114907d0, 0.13374096d0, 0.47245387d0] ]
;;  Define shock normal speeds [SCF]
all_Ushn_up    = ABS([-275.05217133d0,-199.60966279d0,$
                      -425.46426924d0,-504.39410371d0,$
                      -416.94499688d0,-269.64752023d0,$
                      -219.90948937d0,-357.43730189d0,$
                      -339.45568562d0,-360.92006888d0,$
                      -365.26227172d0 ])


;;  Setup margins
!X.MARGIN      = [15,5]
!Y.MARGIN      = [8,4]
;;----------------------------------------------------------------------------------------
;;  Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

;;  Compile critical Mach number routines
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/genarr.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/zbrent.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/marcs_cr-Mach_number/crit_mf.pro
;;----------------------------------------------------------------------------------------
;;  Load Rankine-Hugoniot results
;;----------------------------------------------------------------------------------------
.compile thm_load_bowshock_rhsolns
thm_load_bowshock_rhsolns,R_STRUCT=diss_rates

n_cross        = N_TAGS(diss_rates)          ;;  # of bow shock crossings
diss_tags      = STRLOWCASE(TAG_NAMES(diss_rates))
;;  Define shock normal vectors [GSE]
all_gnorm      = REPLICATE(d,n_cross,3L,2L)  ;;  shock normal vectors [GSE, SCF]
all_gnorm[*,*,0] = TRANSPOSE(all_norms)
;;  Define shock normal angles [deg]
all_thbn       = REPLICATE(d,n_cross,2L)     ;;  shock normal angles [deg, for † = 5/3]
FOR j=0L, n_cross - 1L DO BEGIN                                                       $
  jstr                  = 'T'+STRING(j[0],FORMAT='(I2.2)')                          & $
  plasma_p_up           = diss_rates.(j).UP                                         & $
  all_gnorm[j,*,1]      = REFORM(diss_rates.(j).SHOCK.NVEC[*,1])                    & $
  t_gnorm               = REFORM(all_gnorm[j,*,0])                                  & $
  t_gnorm              /= SQRT(TOTAL(t_gnorm^2,/NAN))                               & $
  t_bvec_up             = REFORM(plasma_p_up.BO)                                    & $
  t_bmag_up             = SQRT(TOTAL(t_bvec_up^2,2,/NAN))                           & $
  t_bvec_up            /= (t_bmag_up # REPLICATE(1d0,3))                            & $
  n_dot_bup             = my_dot_prod(t_gnorm,t_bvec_up,/NOM)                       & $
  t_theta_Bn            = ACOS(n_dot_bup)*18d1/!DPI                                 & $
  all_thbn_up           = REFORM(t_theta_Bn < (18d1 - t_theta_Bn))                  & $
  str_element,theta_bn_str,jstr[0],all_thbn_up,/ADD_REPLACE                         & $
  all_thbn[j,0]         = MEAN(t_theta_Bn,/NAN)                                     & $
  all_thbn[j,1]         = STDDEV(t_theta_Bn,/NAN)

;;  Define upstream Mach numbers
M_Cs_all_up    = 0
M_VA_all_up    = 0
M_Vf_all_up    = 0
FOR j=0L, n_cross - 1L DO BEGIN                                                          $
  jstr                  = 'T'+STRING(j[0],FORMAT='(I2.2)')                             & $
  ushn_up               = all_Ushn_up[j]                                               & $
  all_thbn_up           = theta_bn_str.(j)*!DPI/18d1                                   & $
  plasma_p_up           = diss_rates.(j).UP                                            & $
  diss_struc            = diss_rates.(j).DISS_RATE.OBSERVED                            & $
  t_bmag_up             = SQRT(TOTAL(plasma_p_up.BO^2,2,/NAN))                         & $
  temp_ratio            = t_bmag_up/SQRT(plasma_p_up.NI)                               & $
  t_VA_up               = VA_fac[0]*temp_ratio                                         & $
  t_Cs_up               = diss_struc.CS_UP[*,1]*1d-3                                   & $
  t_Vs2_up              = (t_VA_up^2 + t_Cs_up^2)                                      & $
  b2_4ac                = t_Vs2_up^2 + 4d0*t_VA_up^2*t_Cs_up^2*SIN(all_thbn_up)^2      & $
  t_Vf_up               = SQRT((t_Vs2_up + SQRT(b2_4ac))/2d0)                          & $
  str_element,M_Cs_all_up,jstr[0],(ushn_up[0]/t_Cs_up),/ADD_REPLACE                    & $
  str_element,M_VA_all_up,jstr[0],(ushn_up[0]/t_VA_up),/ADD_REPLACE                    & $
  str_element,M_Vf_all_up,jstr[0],(ushn_up[0]/t_Vf_up),/ADD_REPLACE

;;  Define critical Mach numbers
Mcr1_EK84_up   = 0                           ;;  1st critical Mach number [Edmiston&Kennel, 1984]
FOR j=0L, n_cross - 1L DO BEGIN                                                          $
  jstr                  = 'T'+STRING(j[0],FORMAT='(I2.2)')                             & $
  all_thbn_up           = theta_bn_str.(j)*!DPI/18d1                                   & $
  plasma_p_up           = diss_rates.(j).UP                                            & $
  t_bvec_up             = REFORM(plasma_p_up.BO)                                       & $
  t_bmag_up             = SQRT(TOTAL(t_bvec_up^2,2,/NAN))                              & $
  b2_2muo_up            = TOTAL(plasma_p_up.BO^2,2L,/NAN)*B2_2muo_fac[0]               & $
  nkTT_up               = nkT_fac[0]*plasma_p_up.NI*(plasma_p_up.TE + plasma_p_up.TI)  & $
  all_beta_up           = nkTT_up/b2_2muo_up                                           & $
  temp_Mcr1             = DBLARR(N_ELEMENTS(all_thbn_up))                              & $
  FOR i=0L, N_ELEMENTS(all_thbn_up) - 1L DO BEGIN                                        $
    temp_Mcr1[i] = crit_mf(5d0/3d0,all_beta_up[i],all_thbn_up[i],TYPE='1',/SILENT)     & $
  ENDFOR                                                                               & $
  str_element,Mcr1_EK84_up,jstr[0],temp_Mcr1,/ADD_REPLACE

;;  Define critical Mach numbers
Mcr2__K85_up   = 0                           ;;  2nd critical Mach number [Kennel et al., 1985]
gg             = 5d0/3d0
FOR j=0L, n_cross - 1L DO BEGIN                                                          $
  jstr                  = 'T'+STRING(j[0],FORMAT='(I2.2)')                             & $
  all_thbn_up           = theta_bn_str.(j)*!DPI/18d1                                   & $
  plasma_p_up           = diss_rates.(j).UP                                            & $
  plasma_p_dn           = diss_rates.(j).DOWN                                          & $
  t_bvec_up             = REFORM(plasma_p_up.BO)                                       & $
  t_bmag_up             = SQRT(TOTAL(t_bvec_up^2,2,/NAN))                              & $
  b2_2muo_up            = TOTAL(plasma_p_up.BO^2,2L,/NAN)*B2_2muo_fac[0]               & $
  nkTT_up               = nkT_fac[0]*plasma_p_up.NI*(plasma_p_up.TE + plasma_p_up.TI)  & $
  all_beta_up           = nkTT_up/b2_2muo_up                                           & $
  all_Ti_dn             = plasma_p_dn.TI                                               & $
  all_Te_dn             = plasma_p_dn.TE                                               & $
  Te_Ti_dn              = all_Te_dn/all_Ti_dn                                          & $
  temp_Mcr2             = DBLARR(N_ELEMENTS(all_thbn_up))                              & $
  FOR i=0L, N_ELEMENTS(all_thbn_up) - 1L DO BEGIN                                        $
    x            = all_beta_up[i]                                                      & $
    y            = all_thbn_up[i]                                                      & $
    temp_Mcr2[i] = crit_mf(gg[0],x,y,TYPE='2G',TETI2_IN=Te_Ti_dn[i],/SILENT)           & $
  ENDFOR                                                                               & $
  str_element,Mcr2__K85_up,jstr[0],temp_Mcr2,/ADD_REPLACE

;;  Define upstream Mach number ratios
Mf_Mcr1_up     = 0
Mf_Mcr2_up     = 0
FOR j=0L, n_cross - 1L DO BEGIN                                                          $
  jstr                  = 'T'+STRING(j[0],FORMAT='(I2.2)')                             & $
  temp_Mfup             = M_Vf_all_up.(j)                                              & $
  temp_Mcr1             = Mcr1_EK84_up.(j)                                             & $
  temp_Mcr2             = Mcr2__K85_up.(j)                                             & $
  str_element,Mf_Mcr1_up,jstr[0],(temp_Mfup/temp_Mcr1),/ADD_REPLACE                    & $
  str_element,Mf_Mcr2_up,jstr[0],(temp_Mfup/temp_Mcr2),/ADD_REPLACE



FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = theta_bn_str.(j)                          & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),1d0*N_ELEMENTS(x)]  & $
  PRINT,z,FORMAT='(";;",5f15.4,f15.1)'
;;--------------------------------------------------------------------------------------------
;;  Stats for upstream shock normal angle [degrees]
;;--------------------------------------------------------------------------------------------
;;           Min            Max            Avg            Std            Med              #
;;============================================================================================
;;        34.8658        52.0862        42.6051         4.9502        41.8669           29.0
;;        39.6124        60.6641        50.5482         5.1586        50.8060           22.0
;;        79.0404        88.4006        83.4293         2.5489        83.1410           15.0
;;        84.5513        89.9871        88.1496         1.8327        88.7577           13.0
;;        47.4525        59.9775        54.3839         3.6673        54.4381           21.0
;;        69.1052        75.9771        73.1532         2.1033        73.2283           11.0
;;        32.4157        37.6485        35.3264         1.6665        35.3305           15.0
;;        50.6867        59.2176        55.6706         2.6881        56.7764           14.0
;;        49.7156        75.9215        59.7491         8.7866        55.4177           47.0
;;        73.7106        89.8251        84.0209         4.5296        85.2513           31.0
;;        85.3027        89.9791        87.5910         1.3847        87.6858           28.0
;;--------------------------------------------------------------------------------------------



FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = M_Vf_all_up.(j)                           & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),1d0*N_ELEMENTS(x)]  & $
  PRINT,z,FORMAT='(";;",5f15.4,f15.1)'
;;--------------------------------------------------------------------------------------------
;;  Stats for upstream fast mode Mach number, Mf
;;--------------------------------------------------------------------------------------------
;;           Min            Max            Avg            Std            Med              #
;;============================================================================================
;;         2.9978         3.3696         3.1057         0.1009         3.0795           29.0
;;         1.8568         2.2989         2.1224         0.1280         2.1620           22.0
;;         2.9780         3.1230         3.0539         0.0447         3.0633           15.0
;;         3.5262         3.6981         3.6099         0.0528         3.6241           13.0
;;         3.0278         3.2170         3.1241         0.0608         3.1344           21.0
;;         4.2943         4.4820         4.3960         0.0594         4.3991           11.0
;;         3.5335         3.7064         3.6149         0.0446         3.6158           15.0
;;         5.2139         5.4086         5.3001         0.0573         5.3154           14.0
;;         4.5970         5.5478         4.8790         0.2598         4.7398           47.0
;;         2.1666         2.3476         2.2368         0.0405         2.2374           31.0
;;         2.2849         2.3326         2.3113         0.0110         2.3136           28.0
;;--------------------------------------------------------------------------------------------



FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = Mcr1_EK84_up.(j)                          & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),1d0*N_ELEMENTS(x)]  & $
  PRINT,z,FORMAT='(";;",5f15.4,f15.1)'
;;--------------------------------------------------------------------------------------------
;;  Stats for 1st critical Mach number, Mcr1 [Edmiston&Kennel, 1984]
;;--------------------------------------------------------------------------------------------
;;           Min            Max            Avg            Std            Med              #
;;============================================================================================
;;         1.0212         1.0583         1.0349         0.0094         1.0325           29.0
;;         1.2623         1.5807         1.4168         0.0971         1.4206           22.0
;;         1.1839         1.2599         1.2126         0.0240         1.2052           15.0
;;         1.1840         1.2633         1.2182         0.0249         1.2140           13.0
;;         1.1439         1.2325         1.1911         0.0229         1.1954           21.0
;;         1.0181         1.0251         1.0204         0.0022         1.0196           11.0
;;         1.0226         1.0351         1.0295         0.0044         1.0302           15.0
;;         1.0298         1.0378         1.0328         0.0024         1.0326           14.0
;;         1.0027         1.0687         1.0478         0.0190         1.0486           47.0
;;         1.0653         1.1183         1.0989         0.0119         1.0997           31.0
;;         1.3180         1.3416         1.3290         0.0062         1.3302           28.0
;;--------------------------------------------------------------------------------------------


FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = Mcr2__K85_up.(j)                          & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),1d0*N_ELEMENTS(x)]  & $
  PRINT,z,FORMAT='(";;",5f15.4,f15.1)'
;;--------------------------------------------------------------------------------------------
;;  Stats for 2nd critical Mach number, Mcr2 [Kennel et al., 1985]
;;--------------------------------------------------------------------------------------------
;;           Min            Max            Avg            Std            Med              #
;;============================================================================================
;;         1.1041         1.2098         1.1417         0.0260         1.1331           29.0
;;         1.5621         2.0488         1.7993         0.1363         1.8152           22.0
;;         1.3284         1.4207         1.3590         0.0314         1.3441           15.0
;;         1.3636         1.4732         1.4078         0.0337         1.4040           13.0
;;         1.2719         1.3980         1.3315         0.0316         1.3364           21.0
;;         1.3423         1.4108         1.3656         0.0202         1.3651           11.0
;;         1.0747         1.2249         1.1555         0.0472         1.1641           15.0
;;         1.0967         1.2236         1.1370         0.0332         1.1329           14.0
;;         1.1049         1.2873         1.1753         0.0394         1.1728           47.0
;;         1.2684         1.4613         1.3421         0.0481         1.3329           31.0
;;         1.6911         1.8231         1.7615         0.0369         1.7681           28.0
;;--------------------------------------------------------------------------------------------



FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = Mf_Mcr1_up.(j)                            & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),1d0*N_ELEMENTS(x)]  & $
  PRINT,z,FORMAT='(";;",5f15.4,f15.1)'
;;--------------------------------------------------------------------------------------------
;;  Stats for Mf/Mcr1
;;--------------------------------------------------------------------------------------------
;;           Min            Max            Avg            Std            Med              #
;;============================================================================================
;;         2.8527         3.2909         3.0015         0.1135         2.9680           29.0
;;         1.2248         1.7114         1.5043         0.1310         1.5235           22.0
;;         2.3637         2.6378         2.5199         0.0838         2.5506           15.0
;;         2.7912         3.1234         2.9653         0.1009         2.9667           13.0
;;         2.5061         2.8054         2.6244         0.0927         2.6188           21.0
;;         4.2154         4.3831         4.3080         0.0524         4.3210           11.0
;;         3.4138         3.6219         3.5116         0.0549         3.5014           15.0
;;         5.0401         5.2320         5.1319         0.0574         5.1448           14.0
;;         4.3266         5.5162         4.6622         0.3321         4.5300           47.0
;;         1.9439         2.1718         2.0358         0.0482         2.0321           31.0
;;         1.7206         1.7621         1.7391         0.0101         1.7373           28.0
;;--------------------------------------------------------------------------------------------



FOR j=0L, n_cross[0] - 1L DO BEGIN                  $
  x   = Mf_Mcr2_up.(j)                            & $
  z   = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),STDDEV(x,/NAN),MEDIAN(x),1d0*N_ELEMENTS(x)]  & $
  PRINT,z,FORMAT='(";;",5f15.4,f15.1)'
;;--------------------------------------------------------------------------------------------
;;  Stats for Mf/Mcr2
;;--------------------------------------------------------------------------------------------
;;           Min            Max            Avg            Std            Med              #
;;============================================================================================
;;         2.4966         3.0181         2.7224         0.1278         2.7032           29.0
;;         1.0243         1.3326         1.1848         0.0992         1.2191           22.0
;;         2.1053         2.3479         2.2488         0.0808         2.2830           15.0
;;         2.3936         2.7121         2.5663         0.0960         2.5644           13.0
;;         2.2170         2.5016         2.3481         0.0872         2.3368           21.0
;;         3.1334         3.3223         3.2197         0.0576         3.2267           11.0
;;         2.9330         3.4488         3.1338         0.1498         3.1092           15.0
;;         4.3613         4.8924         4.6650         0.1403         4.6867           14.0
;;         3.8146         5.0039         4.1583         0.3037         4.0252           47.0
;;         1.4843         1.8121         1.6692         0.0792         1.6726           31.0
;;         1.2662         1.3613         1.3127         0.0282         1.3107           28.0
;;--------------------------------------------------------------------------------------------








;;  Setup windows
WINDOW,1,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Critical Mach numbers'

smsz        = 2.
thck        = 2.
psym        = 6

nr_perc_low = [1d1,5d0,5d0,1d1,5d0,5d0,15d0,1d0,5d0,1d0,1d0]/1d2
nr_perc_hig = [57d0,2d1,6d1,40d0,53d0,7d1,2d1,2d0,6d1,2d0,4d1]/1d2
nr_perc_avg = (nr_perc_low + nr_perc_hig)/2d0
yran0       = [0d0,1.d0]
;yran0       = [1d-1,1.1d2]
xran0       = [1d0,5d0]
xttle       = 'Mf/Mcrj [j = 1(red), 2(blue)]'
yttle       = 'Nr [% of total]'
pttle       = 'Nr vs. Mach # Ratio'
pstr        = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:0,XLOG:0,NODATA:1,        $
               YMINOR:10L,XMINOR:10L,XRANGE:xran0,YRANGE:yran0,YSTYLE:1,XSTYLE:1    }
;;  Setup plot
  chsz        = 2.
  PLOT,[0,1],[0,1],_EXTRA=pstr,CHARSIZE=chsz[0],THICK=thck[0]
    FOR j=0L, n_cross[0] - 1L DO BEGIN                                                $
      x1  = MEAN(Mf_Mcr1_up.(j),/NAN)                                               & $
      x2  = MEAN(Mf_Mcr2_up.(j),/NAN)                                               & $
      yl  = nr_perc_low[j]                                                          & $
      yh  = nr_perc_hig[j]                                                          & $
      ya  = MEAN([yl[0],yh[0]],/NAN)                                                & $
      OPLOT,[x1[0]],[ya[0]],PSYM=psym[0],COLOR=250,SYMSIZE=smsz[0],THICK=thck[0]    & $
      ERRPLOT,[x1[0]],[yl[0]],[yh[0]],COLOR=250                                     & $
      OPLOT,[x2[0]],[ya[0]],PSYM=psym[0],COLOR= 50,SYMSIZE=smsz[0],THICK=thck[0]    & $
      ERRPLOT,[x2[0]],[yl[0]],[yh[0]],COLOR= 50


;;  Save plot
fname       = 'Reflected_Ion_Perc_vs_MachNumRatios'
popen,fname[0],/LAND
  chsz        = 1.0
  PLOT,[0,1],[0,1],_EXTRA=pstr,CHARSIZE=chsz[0],THICK=thck[0]
    FOR j=0L, n_cross[0] - 1L DO BEGIN                                                $
      x1  = MEAN(Mf_Mcr1_up.(j),/NAN)                                               & $
      x2  = MEAN(Mf_Mcr2_up.(j),/NAN)                                               & $
      yl  = nr_perc_low[j]                                                          & $
      yh  = nr_perc_hig[j]                                                          & $
      ya  = MEAN([yl[0],yh[0]],/NAN)                                                & $
      OPLOT,[x1[0]],[ya[0]],PSYM=psym[0],COLOR=250,SYMSIZE=smsz[0],THICK=thck[0]    & $
      ERRPLOT,[x1[0]],[yl[0]],[yh[0]],COLOR=250                                     & $
      OPLOT,[x2[0]],[ya[0]],PSYM=psym[0],COLOR= 50,SYMSIZE=smsz[0],THICK=thck[0]    & $
      ERRPLOT,[x2[0]],[yl[0]],[yh[0]],COLOR= 50
pclose




;;  1)  estimate fast mode phase speed for each upstream timestamp used to to calculate nsh
;;  2)  use our "corrected" Ushn results to estimate corresponding Mf values
;;    --> maximum ranges and average of all values
machf_low      = [2.9978,1.8568,2.9780,3.5262,3.0278,4.2943,3.5335,5.2139,4.5970,2.1666,2.2849]
machf_hig      = [3.3696,2.2989,3.1230,3.6981,3.2170,4.4820,3.7064,5.4086,5.5478,2.3476,2.3326]
machf_avg      = [3.1057,2.1224,3.0539,3.6099,3.1241,4.3960,3.6149,5.3001,4.8790,2.2368,2.3113]
pttl_suff      = 'Fast Mode Mach Number'
xttle          = 'Mf [Upstream]'
fnme_suff      = 'Upstream_Mf'
xx             = machf_avg
xerr           = [[machf_low],[machf_hig]]

;;  Dot product of nsh with each B-field vector upstream that was used to calculate nsh
;;    --> maximum ranges and average of all values
theBn_low      = [34.8658,39.6124,79.0404,84.5513,47.4525,69.1052,32.4157,50.6867,49.7156,73.7106,85.3027]
theBn_hig      = [52.0862,60.6641,88.4006,89.9871,59.9775,75.9771,37.6485,59.2176,75.9215,89.8251,89.9791]
theBn_avg      = [42.6051,50.5482,83.4293,88.1496,54.3839,73.1532,35.3264,55.6706,59.7491,84.0209,87.5910]
pttl_suff      = 'Shock Normal Angle'
xttle          = 'Theta_Bn [degrees]'
fnme_suff      = 'Theta_Bn'
xx             = theBn_avg
xerr           = [[theBn_low],[theBn_hig]]

;;  Mf/Mcr1
MfMc1_low      = [2.8527,1.2248,2.3637,2.7912,2.5061,4.2154,3.4138,5.0401,4.3266,1.9439,1.7206]
MfMc1_hig      = [3.2909,1.7114,2.6378,3.1234,2.8054,4.3831,3.6219,5.2320,5.5162,2.1718,1.7621]
MfMc1_avg      = [3.0015,1.5043,2.5199,2.9653,2.6244,4.3080,3.5116,5.1319,4.6622,2.0358,1.7391]
pttl_suff      = 'Mf/Mcr1'
xttle          = 'Mf/Mcr1'
fnme_suff      = '1stCritical_Mf_Mcr'
xx             = MfMc1_avg
xerr           = [[MfMc1_low],[MfMc1_hig]]

;;  Mf/Mcr2
MfMc2_low      = [2.4966,1.0243,2.1053,2.3936,2.2170,3.1334,2.9330,4.3613,3.8146,1.4843,1.2662]
MfMc2_hig      = [3.0181,1.3326,2.3479,2.7121,2.5016,3.3223,3.4488,4.8924,5.0039,1.8121,1.3613]
MfMc2_avg      = [2.7224,1.1848,2.2488,2.5663,2.3481,3.2197,3.1338,4.6650,4.1583,1.6692,1.3127]
pttl_suff      = 'Mf/Mcr2'
xttle          = 'Mf/Mcr2'
fnme_suff      = '2ndCritical_Mf_Mcr'
xx             = MfMc2_avg
xerr           = [[MfMc2_low],[MfMc2_hig]]

;;  Nr/Ni [%]
;;    --> maximum ranges and average of all values
nr_perc_low    = [1d1,5d0,5d0,1d1,5d0,5d0,15d0,1d0,5d0,1d0,1d0]/1d2
nr_perc_hig    = [57d0,2d1,6d1,40d0,53d0,7d1,2d1,2d0,6d1,2d0,4d1]/1d2
nr_perc_avg    = (nr_perc_low + nr_perc_hig)/2d0
yran0          = [0d0,8d-1]
yticks         = (yran0[1] - yran0[0])/5d-2 + 1
ytickv         = DINDGEN(yticks)*5d-2
ytickn         = STRTRIM(STRING(ytickv,FORMAT='(f15.2)'),2L)
yticks         = N_ELEMENTS(ytickn) - 1L
yttle          = 'Nr [% of total]'
pttl_pref      = 'Nr vs. '
fnme_pref      = 'Reflected_Ion_Perc_vs_'


;;  Setup windows
WINDOW,1,RETAIN=2,XSIZE=1700,YSIZE=1100,TITLE='Critical Mach numbers'

smsz           = 2.
thck           = 2.
psym           = 6

;;  Define plot params
yy             = nr_perc_avg
yerr           = [[nr_perc_low],[nr_perc_hig]]
;;  Redefine Y-Errors so that they are differences from mean?
yerr[*,0]      = yy - REFORM(yerr[*,0])
yerr[*,1]      = REFORM(yerr[*,1]) - yy

testx          = (CEIL(MAX(xerr[*,1],/NAN)) GT 20)
IF (testx) THEN xran0 = [0d0,9d1] ELSE xran0 = [1d0,CEIL(MAX(xerr[*,1],/NAN))]
IF (testx) THEN xtfac = 1d1       ELSE xtfac = 5d-1
xticks         = (xran0[1] - xran0[0])/xtfac[0] + 1
xtickv         = DINDGEN(xticks)*xtfac[0] + xran0[0]
xtickn         = STRTRIM(STRING(xtickv,FORMAT='(f15.2)'),2L)
xticks         = N_ELEMENTS(xtickn) - 1L
;;  Redefine X-Errors so that they are differences from mean?
xerr[*,0]      = xx - REFORM(xerr[*,0])
xerr[*,1]      = REFORM(xerr[*,1]) - xx

pttle          = pttl_pref[0]+pttl_suff[0]
pstr           = {TITLE:pttle,XTITLE:xttle,YTITLE:yttle,YLOG:0,XLOG:0,NODATA:1,        $
                  YMINOR:10L,XMINOR:10L,XRANGE:xran0,YRANGE:yran0,YSTYLE:1,XSTYLE:1,   $
                  YTICKNAME:ytickn,YTICKV:ytickv,YTICKS:yticks,                        $
                  XTICKNAME:xtickn,XTICKV:xtickv,XTICKS:xticks                         }

  ;;  Setup plot
  chsz           = 2.
  PLOT,[0,1],[0,1],_EXTRA=pstr,CHARSIZE=chsz[0],THICK=thck[0]
    ;;  Plot w/ error bars
    oploterrxy,xx,yy,xerr,yerr,PSYM=psym[0],COLOR=250,SYMSIZ=smsz[0],THICK=thck[0]

;;  Save Plots
fname          = fnme_pref[0]+fnme_suff[0]
popen,fname[0],/LAND
  chsz        = 1.0
  ;;  Setup plot
  PLOT,[0,1],[0,1],_EXTRA=pstr,CHARSIZE=chsz[0],THICK=thck[0]
    ;;  Plot w/ error bars
    oploterrxy,xx,yy,xerr,yerr,PSYM=psym[0],COLOR=250,SYMSIZ=smsz[0],THICK=thck[0]
pclose






































