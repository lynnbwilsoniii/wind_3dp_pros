;+
;*****************************************************************************************
;
;  CRIBSHEET:   wind_load_and_plot_3dp_vdf_then_fit_crib.pro
;  PURPOSE  :   To load and model particle velocity distributions from the Wind/3DP
;                 instrument by fitting them to the sum of multiple velocity
;                 distributions.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               time_double.pro
;               wind_load_and_plot_3dp_vdf_compare_shocks_batch.pro
;               fill_range.pro
;               find_strahl_direction.pro
;               time_string.pro
;               mag__vec.pro
;               conv_units.pro
;               conv_vdfidlstr_2_f_vs_vxyz_thm_wi.pro
;               trange_str.pro
;               wrapper_fit_vdf_2_sumof2funcs.pro
;               num2int_str.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  The following data:
;                     Wind/3DP level zero files
;                     Wind/MFI H0 CDF files
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               [calling sequence]
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Follow notes in crib and enter each line by hand in the command line
;               2)  Definitions
;                     SWF  :  solar wind frame of reference
;                     FAC  :  field-aligned coordinates
;                     VDF  :  velocity distribution function
;
;  REFERENCES:  
;               0)  Barnes, A. "Collisionless Heating of the Solar-Wind Plasma I. Theory
;                      of the Heating of Collisionless Plasma by Hydromagnetic Waves,"
;                      Astrophys. J. 154, pp. 751--759, 1968.
;               1)  Mace, R.L. and R.D. Sydora "Parallel whistler instability in a plasma
;                      with an anisotropic bi-kappa distribution," J. Geophys. Res. 115,
;                      pp. A07206, doi:10.1029/2009JA015064, 2010.
;               2)  Livadiotis, G. "Introduction to special section on Origins and
;                      Properties of Kappa Distributions: Statistical Background and
;                      Properties of Kappa Distributions in Space Plasmas,"
;                      J. Geophys. Res. 120, pp. 1607--1619, doi:10.1002/2014JA020825,
;                      2015.
;               3)  Dum, C.T., et al., "Turbulent Heating and Quenching of the Ion Sound
;                      Instability," Phys. Rev. Lett. 32(22), pp. 1231--1234, 1974.
;               4)  Dum, C.T. "Strong-turbulence theory and the transition from Landau
;                      to collisional damping," Phys. Rev. Lett. 35(14), pp. 947--950,
;                      1975.
;               5)  Jain, H.C. and S.R. Sharma "Effect of flat top electron distribution
;                      on the turbulent heating of a plasma," Beitraega aus der
;                      Plasmaphysik 19, pp. 19--24, 1979.
;               6)  Goldman, M.V. "Strong turbulence of plasma waves," Rev. Modern Phys.
;                      56(4), pp. 709--735, 1984.
;               7)  Horton, W., et al., "Ion-acoustic heating from renormalized
;                      turbulence theory," Phys. Rev. A 14(1), pp. 424--433, 1976.
;               8)  Horton, W. and D.-I. Choi "Renormalized turbulence theory for the
;                      ion acoustic problem," Phys. Rep. 49(3), pp. 273--410, 1979.
;               9)  Livadiotis, G. "Statistical origin and properties of kappa
;                      distributions," J. Phys.: Conf. Ser. 900(1), pp. 012014, 2017.
;              10)  Livadiotis, G. "Derivation of the entropic formula for the
;                      statistical mechanics of space plasmas,"
;                      Nonlin. Proc. Geophys. 25(1), pp. 77-88, 2018.
;              11)  Livadiotis, G. "Modeling anisotropic Maxwell-Jüttner distributions:
;                      derivation and properties," Ann. Geophys. 34(1),
;                      pp. 1145-1158, 2016.
;              12)  Markwardt, C. B. "Non-Linear Least Squares Fitting in IDL with
;                     MPFIT," in proc. Astronomical Data Analysis Software and Systems
;                     XVIII, Quebec, Canada, ASP Conference Series, Vol. 411,
;                     Editors: D. Bohlender, P. Dowler & D. Durand, (Astronomical
;                     Society of the Pacific: San Francisco), pp. 251-254,
;                     ISBN:978-1-58381-702-5, 2009.
;              13)  Moré, J. 1978, "The Levenberg-Marquardt Algorithm: Implementation and
;                     Theory," in Numerical Analysis, Vol. 630, ed. G. A. Watson
;                     (Springer-Verlag: Berlin), pp. 105, doi:10.1007/BFb0067690, 1978.
;              14)  Moré, J. and S. Wright "Optimization Software Guide," SIAM,
;                     Frontiers in Applied Mathematics, Number 14,
;                     ISBN:978-0-898713-22-0, 1993.
;              15)  The IDL MINPACK routines can be found on Craig B. Markwardt's site at:
;                     http://cow.physics.wisc.edu/~craigm/idl/fitting.html
;              16)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 1. Analysis Techniques and Methodology,"
;                      J. Geophys. Res. 119(8), pp. 6455--6474, 2014a.
;              17)  Wilson III, L.B., et al., "Quantified Energy Dissipation Rates in the
;                      Terrestrial Bow Shock: 2. Waves and Dissipation,"
;                      J. Geophys. Res. 119(8), pp. 6475--6495, 2014b.
;              18)  Wilson III, L.B., et al., "Relativistic electrons produced by
;                      foreshock disturbances observed upstream of the Earth’s bow
;                      shock," Phys. Rev. Lett. 117(21), pp. 215101, 2016.
;              19)  Location of MPFIT software
;                     https://www.physics.wisc.edu/~craigm/idl/fitting.html
;
;   CREATED:  04/27/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/27/2018   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;---------------------------------------------------
;;  1996-04-03
;;---------------------------------------------------
date           = '040396'
tdate          = '1996-04-03'
tramp          = '1996-04-03/09:47:17.152'

tura           = time_double(tramp[0])
trange         = tura[0] + [-1,1]*2d0*36d2       ;;  Use 2 hour window around ramp
;;----------------------------------------------------------------------------------------
;;  Load 3DP, MFI, and SWE data
;;----------------------------------------------------------------------------------------
;;  ***  Change directory path accordingly!  ***
@/Users/lbwilson/Desktop/swidl-0.1//wind_3dp_pros/wind_3dp_cribs/wind_load_and_plot_3dp_vdf_compare_shocks_batch.pro
;;----------------------------------------------------------------------------------------
;;  Define some default parameters
;;----------------------------------------------------------------------------------------
;;  Define some conversion factors
vte2tekfac      = 1d6*me[0]/2d0/kB[0]      ;;  Converts thermal speed squared to temperature [K]
vte2teevfac     = vte2tekfac[0]*K2eV[0]    ;;  Converts thermal speed squared to temperature [eV]
;;  Define some defaults
dfra_aplb      = [1e-9,5e-5]      ;;  Default VDF range for PESA Low Burst
vlim_aplb      = 75e1             ;;  Default velocity range for PESA Low Burst
dfra_aelb      = [1e-18,1e-9]     ;;  Default VDF range for EESA Low Burst
vlim_aelb      = 20e3             ;;  Default velocity range for EESA Low Burst
xname          = 'Bo'
yname          = 'Vsw'
;;  Use one of the following depending on what one plots
ttl_midfs      = [instnmmode__el[0],instnmmode__pl[0],instnmmode__ph[0]]
;;----------------------------------------------------------------------------------------
;;  Define EESA Low Burst VDFs [could just as well define PESA Low Burst VDFs]
;;----------------------------------------------------------------------------------------
dat1           = aelb
n_elb          = N_ELEMENTS(dat1)
e_ind          = fill_range(0L,n_elb[0]-1L,DIND=1L)        ;;  change as user sees fit
;;  Find strahl direction signs (relative to Bo)
strahl         = find_strahl_direction(TRANSPOSE(dat1.MAGF))
jj             = 0L
ii             = e_ind[jj]
dat0           = dat1[jj]         ;;  EESA Low Burst
dfra           = dfra_aelb        ;;  Default VDF range for PESA Low Burst
vlim           = vlim_aelb        ;;  Default velocity range for PESA Low Burst
tran_vdf       = tran_el
fname_mid      = fname_mid_el
pttl_midf      = ttl_midfs[0]

;;  These are some pre-defined bulk flow velocities determined using the Vbulk Change
;;    software to find the true peak phase space density location from the PESA Low
;;    VDFs.
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:10') THEN dat0[0].VSW = [-352.6083e0,17.4598e0, 6.3212e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:14') THEN dat0[0].VSW = [-353.3347e0,17.7673e0,13.7160e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:17') THEN dat0[0].VSW = [-353.3309e0,19.8303e0,15.7891e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:20') THEN dat0[0].VSW = [-359.5624e0,17.5794e0,16.1354e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:23') THEN dat0[0].VSW = [-363.2769e0,19.0922e0,16.8559e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:26') THEN dat0[0].VSW = [-366.8244e0,13.0794e0,17.8965e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:29') THEN dat0[0].VSW = [-365.0393e0,17.5948e0,17.0503e0]
;;  Prevent interpolation below SC potential
IF (dat0.SC_POT[0] GT 0e0) THEN dat0.DATA[WHERE(dat0.ENERGY LE 1.3e0*dat0.SC_POT[0])] = f

IF (vlim[0] GT 1e4) THEN vframe = [0d0,0d0,0d0] ELSE vframe = REFORM(dat0[0].VSW)  ;;  Transformation velocity [km/s]
IF (vlim[0] GT 1e4) THEN ttle_ext       = 'SCF' ELSE ttle_ext       = 'SWF'        ;;  string to add to plot title indicating reference frame shown
IF (tdate[0] EQ '1996-04-03') THEN vframe = REFORM(dat0[0].VSW)                    ;;  Transformation velocity [km/s]
IF (tdate[0] EQ '1996-04-03') THEN ttle_ext       = 'SWF'                          ;;  string to add to plot title indicating reference frame shown
vfmag          = mag__vec(vframe,/NAN)
pttl_pref      = sc[0]+' ['+ttle_ext[0]+'] '+pttl_midf[0]
;;----------------------------------------------------------------------------------------
;;  Define some plot parameters
;;----------------------------------------------------------------------------------------
;;  Define one-count level VDF
datc           = dat0[0]
datc.DATA      = 1e0            ;;  Create a one-count copy
vec1           = REFORM(dat0[0].MAGF)
vec2           = REFORM(dat0[0].VSW)
;;  Convert to phase space density [# cm^(-3) km^(-3) s^(+3)]
dat_df         = conv_units(dat0,'df')
dat_1c         = conv_units(datc,'df')
;;  Convert F(energy,theta,phi) to F(Vx,Vy,Vz)
dat_fvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_df)
dat_1cxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_1c)
;;  Define EX_VECS stuff  (for general_vdf_contour_plot.pro)
ex_vecs[0]     = {VEC:FLOAT(dat_df[0].VSW),NAME:'Vsw'}
ex_vecs[1]     = {VEC:FLOAT(dat_df[0].MAGF),NAME:'Bo'}
ex_vecs[2]     = {VEC:FLOAT(gnorm),NAME:'nsh'}
ex_vecs[3]     = {VEC:[1e0,0e0,0e0],NAME:'Sun'}
;;  Define EX_INFO stuff  (for general_vdf_contour_plot.pro)
ex_info        = {SCPOT:dat_df[0].SC_POT,VSW:dat_df[0].VSW,MAGF:dat_df[0].MAGF}
sm_cuts        = 1b               ;;  Do not smooth cuts
sm_cont        = 1b               ;;  Do not smooth contours
IF (vfmag[0] LT 1e0) THEN vxy_offs = [ex_info.VSW[xyind[0:1]]] ELSE vxy_offs = [0e0,0e0]  ;;  XY-Offsets of crosshairs

ptitle         = pttl_pref[0]+': '+trange_str(tran_vdf[ii,0],tran_vdf[ii,1],/MSEC)
;;  Define data arrays
data_1d        = dat_fvxyz.VDF                  ;;  [N]-Element [numeric] array of phase space densities [# s^(+3) km^(-3) cm^(-3)]
vels_1d        = dat_fvxyz.VELXYZ               ;;  [N,3]-Element [numeric] array of 3-vector velocities [km/s] corresponding to the phase space densities
onec_1d        = dat_1cxyz.VDF                  ;;  [N]-Element [numeric] array of one-count levels in units of phase space densities [# s^(+3) km^(-3) cm^(-3)]
;;----------------------------------------------------------------------------------------
;;  Plot 2D contour in SWF, in FAC coordinate basis, and fit
;;----------------------------------------------------------------------------------------
dumbfix        = REPLICATE(0b,6)
sm_cuts        = 1b               ;;  Do smooth cuts
sm_cont        = 1b               ;;  Do smooth contours
vec1           = REFORM(dat0[0].MAGF)
vec2           = REFORM(dat0[0].VSW)
;;  Define an initial guess for the bi-Maxwellian parameters of the core electrons
bimax          = [6.5d0,22d2,25d2,-4d2,0d0,0d0]
;;  Define an initial guess for the bi-kappa parameters of the halo electrons
bikap          = [4d-1,50d2,50d2, 2d3,0d0,3d0]
bikap[3]      *= -1*strahl[jj]
;;  Define an initial guess for the bi-kappa parameters of the strahl electrons
beamp          = [3d-2,50d2,65d2, 4d3,0d0,2d0]
beamp[3]      *= -1*sign(bikap[3])
fixed_c        = dumbfix
fixed_h        = dumbfix
fixed_b        = dumbfix
fixed_c[4:5]   = 1b                       ;;  Prevent fit routines from varying perpendicular drift velocity and exponent
fixed_h[4]     = 1b                       ;;  Prevent fit routines from varying perpendicular drift velocity
fixed_b[4]     = 1b                       ;;  Prevent fit routines from varying perpendicular drift velocity
;;  Define range for beam parallel drift speed [km/s]
voabeamrn      = [1,1,1d3,15d3]
voabeamrn[2:3] *= -1*sign(bikap[3])       ;;  Make sure the beam is on the strahl side
sp             = SORT(voabeamrn[2:3])
IF (sp[0] NE 0) THEN voabeamrn[2:3] = voabeamrn[[3,2]]
vtabeamrn      = [1,1,5d2,8d3]            ;;  Define range for beam parallel thermal speed [km/s]
vtebeamrn      = [1,1,1d3,9d3]            ;;  Define range for beam perpendicular thermal speed [km/s]
expbeamrn      = [1,1,3d0/2d0,2.5d0]      ;;  Define range for beam kappa value [unitless]
emin_ch        = 2.90d0                   ;;  Lowest energy [eV] to allow for core+halo fits
emin_b         = 10d1                     ;;  Lowest energy [eV] to allow for beam fits

;;  Compile necessary routines to make sure IDL paths are okay and routines are available
.compile mpfit.pro
.compile mpfit2dfun.pro
.compile wrapper_fit_vdf_2_sumof2funcs.pro
;;  Plot and fit
wrapper_fit_vdf_2_sumof2funcs,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,COREP=bimax,$
                          HALOP=bikap,CFUNC='MM',HFUNC='KK',VLIM=vlim[0],PLANE=plane[0],    $
                          NLEV=nlev,SM_CUTS=sm_cuts,SM_CONT=sm_cont,XNAME=xname,YNAME=yname,$
                          DFRA=dfra,EX_VECS=ex_vecs,EX_INFO=ex_info,V_0X=vxy_offs[0],       $
                          V_0Y=vxy_offs[1],/SLICE2D,ONE_C=onec_1d,P_TITLE=ptitle,           $
                          /STRAHL,V1ISB=strahl[jj],OUTSTRC=out_struc,BEAMP=beamp,BFUNC='KK',$
                          FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,/ONLY_TOT,        $
                          VOABEAMRN=voabeamrn,VTABEAMRN=vtabeamrn,VTEBEAMRN=vtebeamrn,      $
                          EXPBEAMRN=expbeamrn,EMIN_CH=emin_ch,EMIN_B=emin_b

;;  Define file name
vlim_str       = num2int_str(vlim[0],NUM_CHAR=6L,/ZERO_PAD)
fname_end      = 'para-red_perp-blue_1count-green_plane-'+plane[0]+'_VLIM-'+vlim_str[0]+'km_s'
fname_pre      = scpref[0]+'df_'+ttle_ext[0]+'_'
fnams_out2     = fname_pre[0]+fname_mid+'_'+fname_end[0]+'_Fits_Core-MM_Halo-KK_wo-strahl_Beam-KK'

;;  Save Plot [showing each 1D cut individually]
wrapper_fit_vdf_2_sumof2funcs,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,COREP=bimax,$
                          HALOP=bikap,CFUNC='MM',HFUNC='KK',VLIM=vlim[0],PLANE=plane[0],    $
                          NLEV=nlev,SM_CUTS=sm_cuts,SM_CONT=sm_cont,XNAME=xname,YNAME=yname,$
                          DFRA=dfra,EX_VECS=ex_vecs,EX_INFO=ex_info,V_0X=vxy_offs[0],       $
                          V_0Y=vxy_offs[1],/SLICE2D,ONE_C=onec_1d,P_TITLE=ptitle,           $
                          /STRAHL,V1ISB=strahl[jj],OUTSTRC=out_struc,BEAMP=beamp,BFUNC='KK',$
                          FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,                  $
                          VOABEAMRN=voabeamrn,VTABEAMRN=vtabeamrn,VTEBEAMRN=vtebeamrn,      $
                          EXPBEAMRN=expbeamrn,EMIN_CH=emin_ch,EMIN_B=emin_b,                $
                          FILENAME=fnams_out2[ii],/SAVEF
;;  Print temperatures [eV] and anisotropies
ch_parms       = out_struc.CORE_HALO.FIT_PARAMS
b__parms       = out_struc.BEAM.FIT_PARAMS
vte_all        = [ch_parms[[1,2,7,8]],b__parms[1:2]]      ;;  V_Tej [km/s]
tempall        = vte2teevfac[0]*vte_all^2d0               ;;  T_ej [eV]
PRINT,';;',ptitle[0]  & $
PRINT,';;',tempall  & $
PRINT,';;',tempall[1]/tempall[0],tempall[3]/tempall[2],tempall[5]/tempall[4]
;;Wind [SWF] Eesa Low Burst: 1996-04-03/09:46:17.248 - 09:46:20.408
;;       8.0033960       9.5067176       38.147286       42.644262       37.260730       9.5750995
;;       1.1878355       1.1178846      0.25697563



;;  Define file name
vlim_str       = num2int_str(vlim[0],NUM_CHAR=6L,/ZERO_PAD)
fname_end      = 'para-red_perp-blue_1count-green_plane-'+plane[0]+'_VLIM-'+vlim_str[0]+'km_s'
fname_pre      = scpref[0]+'df_'+ttle_ext[0]+'_'
fnams_out3     = fname_pre[0]+fname_mid+'_'+fname_end[0]+'_Fits_Core-MM_Halo-KK_wo-strahl_Beam-KK_only_tot'

;;  Save Plot [showing a single 1D cut that is the sum of all parameters]
wrapper_fit_vdf_2_sumof2funcs,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,COREP=bimax,$
                          HALOP=bikap,CFUNC='MM',HFUNC='KK',VLIM=vlim[0],PLANE=plane[0],    $
                          NLEV=nlev,SM_CUTS=sm_cuts,SM_CONT=sm_cont,XNAME=xname,YNAME=yname,$
                          DFRA=dfra,EX_VECS=ex_vecs,EX_INFO=ex_info,V_0X=vxy_offs[0],       $
                          V_0Y=vxy_offs[1],/SLICE2D,ONE_C=onec_1d,P_TITLE=ptitle,           $
                          /STRAHL,V1ISB=strahl[jj],OUTSTRC=out_struc,BEAMP=beamp,BFUNC='KK',$
                          /ONLY_TOT,FIXED_C=fixed_c,FIXED_H=fixed_h,FIXED_B=fixed_b,        $
                          VOABEAMRN=voabeamrn,VTABEAMRN=vtabeamrn,VTEBEAMRN=vtebeamrn,      $
                          EXPBEAMRN=expbeamrn,EMIN_CH=emin_ch,EMIN_B=emin_b,                $
                          /SAVEF,FILENAME=fnams_out3[ii]
;;  Print temperatures [eV] and anisotropies
ch_parms       = out_struc.CORE_HALO.FIT_PARAMS
b__parms       = out_struc.BEAM.FIT_PARAMS
vte_all        = [ch_parms[[1,2,7,8]],b__parms[1:2]]      ;;  V_Tej [km/s]
tempall        = vte2teevfac[0]*vte_all^2d0               ;;  T_ej [eV]
PRINT,';;',ptitle[0]  & $
PRINT,';;',tempall  & $
PRINT,';;',tempall[1]/tempall[0],tempall[3]/tempall[2],tempall[5]/tempall[4]
;;Wind [SWF] Eesa Low Burst: 1996-04-03/09:46:17.248 - 09:46:20.408
;;       8.0033966       9.5067180       38.147286       42.644262       37.260733       9.5751068
;;       1.1878354       1.1178846      0.25697580
;;
;;         Tcpara          Tcperp          Thpara          Thperp          Tspara          Tsperp
;;         Tcanis          Thanis          Tsanis
;;
;;         Tjanis  = Tjperp/Tjpara  =  temperature anisotropy









