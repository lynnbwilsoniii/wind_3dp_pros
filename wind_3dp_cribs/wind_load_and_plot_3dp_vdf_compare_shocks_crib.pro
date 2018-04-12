;+
;*****************************************************************************************
;
;  CRIBSHEET:   wind_load_and_plot_3dp_vdf_compare_shocks_crib.pro
;  PURPOSE  :   To load and examine particle velocity distributions from the Wind/3DP
;                 instrument.
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
;               time_string.pro
;               mag__vec.pro
;               conv_units.pro
;               conv_vdfidlstr_2_f_vs_vxyz_thm_wi.pro
;               trange_str.pro
;               general_vdf_contour_plot.pro
;               num2int_str.pro
;               popen.pro
;               pclose.pro
;               wrapper_vbulk_change_thm_wi.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  The following data:
;                     Wind/3DP level zero files
;                     Wind/MFI H0 CDF files
;                     Wind orbit ASCII files
;                     Wind WAVES ASCII files
;                     CfA Shock Database IDL Save File (included in distribution)
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
;   CHANGED:  1)  File created
;                                                                   [03/01/2018   v1.0.0]
;             2)  Added additional dates/corrected velocity moments
;                                                                   [03/02/2018   v1.0.1]
;             3)  Moved to ~/wind_3dp_pros/wind_3dp_cribs/ and added Man. page
;                                                                   [04/03/2018   v1.1.0]
;
;   NOTES:      
;               1)  Follow notes in crib and enter each line by hand in the command line
;
;  REFERENCES:  
;               0)  Harten, R. and K. Clark (1995), "The Design Features of the GGS
;                      Wind and Polar Spacecraft," Space Sci. Rev. Vol. 71, pp. 23-40.
;               1)  Carlson et al., (1983), "An instrument for rapidly measuring
;                      plasma distribution functions with high resolution,"
;                      Adv. Space Res. Vol. 2, pp. 67-70.
;               2)  Curtis et al., (1989), "On-board data analysis techniques for
;                      space plasma particle instruments," Rev. Sci. Inst. Vol. 60,
;                      pp. 372.
;               3)  Lin et al., (1995), "A Three-Dimensional Plasma and Energetic
;                      particle investigation for the Wind spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 125.
;               4)  Paschmann, G. and P.W. Daly (1998), "Analysis Methods for Multi-
;                      Spacecraft Data," ISSI Scientific Report, Noordwijk, 
;                      The Netherlands., Int. Space Sci. Inst.
;               5)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang (1995) "WAVES:  The Radio and Plasma
;                      Wave Investigation on the Wind Spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 231-263, doi:10.1007/BF00751331.
;               6)  Viñas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               7)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               8)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;               9)  Russell, C.T., J.T. Gosling, R.D. Zwickl, and E.J. Smith (1983),
;                      "Multiple spacecraft observations of interplanetary shocks:  ISEE
;                      Three-Dimensional Plasma Measurements," J. Geophys. Res. 88,
;                      pp. 9941-9947.
;              10)  Lepping et al., (1995), "The Wind Magnetic Field Investigation,"
;                      Space Sci. Rev. Vol. 71, pp. 207-229.
;              11)  K.W. Ogilvie et al., "SWE, A Comprehensive Plasma Instrument for the
;                     Wind Spacecraft," Space Science Reviews Vol. 71, pp. 55-77,
;                     doi:10.1007/BF00751326, 1995.
;              12)  J.C. Kasper et al., "Physics-based tests to identify the accuracy of
;                     solar wind ion measurements:  A case study with the Wind
;                     Faraday Cups," Journal of Geophysical Research Vol. 111,
;                     pp. A03105, doi:10.1029/2005JA011442, 2006.
;              13)  B.A. Maruca and J.C. Kasper "Improved interpretation of solar wind
;                     ion measurements via high-resolution magnetic field data,"
;                     Advances in Space Research Vol. 52, pp. 723-731,
;                     doi:10.1016/j.asr.2013.04.006, 2013.
;
;   CREATED:  03/01/2018
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/03/2018   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

;;  Plot VDFs for comparison between weak and strong shocks

;;----------------------------------------------------------------------------------------
;;  Special cases
;;----------------------------------------------------------------------------------------

;;---------------------------------------------------
;;  1996-04-03
;;---------------------------------------------------
date           = '040396'
tdate          = '1996-04-03'
tramp          = '1996-04-03/09:47:17.152'

;;---------------------------------------------------
;;  1997-10-24
;;---------------------------------------------------
date           = '102497'
tdate          = '1997-10-24'
tramp          = '1997-10-24/11:18:09.966'

;;---------------------------------------------------
;;  1997-12-10
;;---------------------------------------------------
date           = '121097'
tdate          = '1997-12-10'
tramp          = '1997-12-10/04:33:14.664'

;;---------------------------------------------------
;;  1998-04-30
;;---------------------------------------------------
date           = '043098'
tdate          = '1998-04-30'
tramp          = '1998-04-30/08:43:15.291'

;;---------------------------------------------------
;;  1998-08-06
;;---------------------------------------------------
date           = '080698'
tdate          = '1998-08-06'
tramp          = '1998-08-06/07:16:07.5875'

;;---------------------------------------------------
;;  1998-08-26
;;---------------------------------------------------
date           = '082698'
tdate          = '1998-08-26'
tramp          = '1998-08-26/06:40:24.972'

;;---------------------------------------------------
;;  2000-02-11 [B]
;;---------------------------------------------------
date           = '021100'
tdate          = '2000-02-11'
tramp          = '2000-02-11/23:33:55.319'

;;---------------------------------------------------
;;  2000-04-06
;;---------------------------------------------------
date           = '040600'
tdate          = '2000-04-06'
tramp          = '2000-04-06/16:32:09.237'

;;---------------------------------------------------
;;  2001-11-24 [B]
;;---------------------------------------------------
date           = '112401'
tdate          = '2001-11-24'
tramp          = '2001-11-24/05:51:56.955'


tura           = time_double(tramp[0])
trange         = tura[0] + [-1,1]*2d0*36d2       ;;  Use 2 hour window around ramp
;;----------------------------------------------------------------------------------------
;;  Load 3DP, MFI, and SWE data
;;----------------------------------------------------------------------------------------
;;  ***  Change directory path accordingly!  ***
@/Users/lbwilson/Desktop/swidl-0.1//wind_3dp_pros/wind_3dp_cribs/wind_load_and_plot_3dp_vdf_compare_shocks_batch.pro
;;----------------------------------------------------------------------------------------
;;  Plot VDF data
;;----------------------------------------------------------------------------------------
dfra_aplb      = [1e-9,5e-5]      ;;  Default VDF range for PESA Low Burst
vlim_aplb      = 75e1             ;;  Default velocity range for PESA Low Burst
dfra_aelb      = [1e-18,1e-9]     ;;  Default VDF range for EESA Low Burst
vlim_aelb      = 20e3             ;;  Default velocity range for EESA Low Burst
;;  Use one of the following depending on what one plots
ttl_midfs      = [instnmmode__el[0],instnmmode__pl[0],instnmmode__ph[0]]
;;---------------------------------------------------
;;  Define PESA Low VDF and plot
;;---------------------------------------------------
jj             = 10L

dat0           = aplb[jj]       ;;  PESA Low Burst
dfra           = dfra_aplb        ;;  Default VDF range for PESA Low Burst
vlim           = vlim_aplb        ;;  Default velocity range for PESA Low Burst
tran_vdf       = tran_pl
fname_mid      = fname_mid_pl
pttl_midf      = ttl_midfs[1]

;;---------------------------------------------------
;;  Define EESA Low VDF and plot
;;---------------------------------------------------
dat0           = aelb[jj]       ;;  PESA Low Burst
dfra           = dfra_aelb        ;;  Default VDF range for PESA Low Burst
vlim           = vlim_aelb        ;;  Default velocity range for PESA Low Burst
tran_vdf       = tran_el
fname_mid      = fname_mid_el
pttl_midf      = ttl_midfs[0]

IF ((tdate[0] EQ '1998-08-26') AND (dat0.TIME LT time_double('1998-08-26/06:40:23.999'))) THEN dat0.SC_POT += 2e0
IF (time_string(ROUND(dat0.TIME)) EQ '1998-08-26/06:40:24') THEN dat0.SC_POT += 5e0
IF (time_string(ROUND(dat0.TIME)) EQ '1998-08-26/06:40:27') THEN dat0.SC_POT += 4e0
;;  Prevent interpolation below SC potential
IF (dat0.SC_POT[0] GT 0e0) THEN dat0.DATA[WHERE(dat0.ENERGY LE 1.3e0*dat0.SC_POT[0])] = f
;IF ((tdate[0] EQ '1998-04-30') OR (tdate[0] EQ '1998-08-26')) THEN dat0.DATA[WHERE(dat0.ENERGY LE 1.3e0*dat0.SC_POT[0])] = f

IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:10') THEN dat0[0].VSW = [-352.6083e0,17.4598e0, 6.3212e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:14') THEN dat0[0].VSW = [-353.3347e0,17.7673e0,13.7160e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:17') THEN dat0[0].VSW = [-353.3309e0,19.8303e0,15.7891e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:20') THEN dat0[0].VSW = [-359.5624e0,17.5794e0,16.1354e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:23') THEN dat0[0].VSW = [-363.2769e0,19.0922e0,16.8559e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:26') THEN dat0[0].VSW = [-366.8244e0,13.0794e0,17.8965e0]
IF (time_string(dat0.TIME) EQ '1996-04-03/09:47:29') THEN dat0[0].VSW = [-365.0393e0,17.5948e0,17.0503e0]

IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:01') THEN dat0[0].VSW = [-396.2715e0,-11.7213e0, -5.7434e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:04') THEN dat0[0].VSW = [-397.0874e0,-15.1313e0, -6.0552e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:07') THEN dat0[0].VSW = [-397.3801e0,-17.8075e0,-15.0020e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:10') THEN dat0[0].VSW = [-389.2287e0,-18.8123e0, 19.3357e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:13') THEN dat0[0].VSW = [-465.4079e0,-24.5870e0, 22.4631e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:16') THEN dat0[0].VSW = [-451.3080e0,-19.2740e0, 19.9179e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:19') THEN dat0[0].VSW = [-454.5474e0,-19.8959e0, 22.3670e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:22') THEN dat0[0].VSW = [-453.1703e0,-19.1291e0, 20.7198e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:25') THEN dat0[0].VSW = [-453.8663e0,-15.2789e0, 18.5990e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:28') THEN dat0[0].VSW = [-460.4557e0,-21.7281e0, 22.2094e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:31') THEN dat0[0].VSW = [-454.1637e0,-21.8510e0, 22.7399e0]
IF (time_string(dat0.TIME) EQ '1997-10-24/11:18:34') THEN dat0[0].VSW = [-454.6235e0,-19.4149e0, 22.4293e0]

IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:03') THEN dat0[0].VSW = [-301.4939e0, -6.5476e0,-12.1971e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:06') THEN dat0[0].VSW = [-307.2343e0,-11.8777e0,-14.4613e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:09') THEN dat0[0].VSW = [-286.3262e0, 16.2167e0,-13.6801e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:12') THEN dat0[0].VSW = [-281.2919e0, 16.2553e0,-12.5898e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:15') THEN dat0[0].VSW = [-297.9887e0, 14.1989e0,-13.6837e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:18') THEN dat0[0].VSW = [-354.7150e0, 13.3591e0,-50.6713e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:21') THEN dat0[0].VSW = [-368.5334e0,-15.6973e0,-17.5543e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:24') THEN dat0[0].VSW = [-371.4411e0,-13.1851e0,-49.8553e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:27') THEN dat0[0].VSW = [-350.7532e0, 19.4279e0,-51.7943e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:30') THEN dat0[0].VSW = [-338.5256e0, 21.7314e0,-49.4712e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:33') THEN dat0[0].VSW = [-357.2460e0, 19.3249e0,-52.6108e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:36') THEN dat0[0].VSW = [-355.6217e0, 18.1246e0,-52.8204e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:39') THEN dat0[0].VSW = [-365.0726e0,  3.4802e0,-37.1423e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:42') THEN dat0[0].VSW = [-362.1448e0, 19.7304e0,-52.3882e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:45') THEN dat0[0].VSW = [-364.7437e0, 18.6998e0,-51.9190e0]
IF (time_string(dat0.TIME) EQ '1997-12-10/04:33:48') THEN dat0[0].VSW = [-357.5767e0, 21.1032e0,-54.0312e0]

IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:01') THEN dat0[0].VSW = [-345.2872e0,-15.4274e0,17.6145e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:04') THEN dat0[0].VSW = [-348.9513e0,-13.7826e0,16.3279e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:07') THEN dat0[0].VSW = [-348.4708e0,-14.9936e0,18.1168e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:10') THEN dat0[0].VSW = [-349.4484e0,-13.6721e0,17.5319e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:13') THEN dat0[0].VSW = [-358.3780e0,-13.9305e0,17.4255e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:16') THEN dat0[0].VSW = [-390.5576e0,-20.4922e0,18.2058e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:19') THEN dat0[0].VSW = [-388.8454e0,-18.7983e0,20.3796e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:22') THEN dat0[0].VSW = [-357.7146e0,-14.1013e0,18.5884e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:25') THEN dat0[0].VSW = [-348.0529e0,-15.7437e0,18.4292e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:28') THEN dat0[0].VSW = [-359.3690e0,-15.4323e0,17.3417e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:31') THEN dat0[0].VSW = [-362.6778e0,-50.4187e0,51.2017e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:34') THEN dat0[0].VSW = [-370.0599e0,-50.3053e0,51.5361e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:37') THEN dat0[0].VSW = [-372.4740e0,-53.2994e0,21.4018e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:40') THEN dat0[0].VSW = [-373.9053e0,-17.0087e0,20.2134e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:43') THEN dat0[0].VSW = [-376.8880e0,-16.7596e0,18.2205e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:46') THEN dat0[0].VSW = [-361.6379e0,-45.5949e0,19.6297e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:49') THEN dat0[0].VSW = [-367.5859e0,-50.5058e0,18.9356e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:52') THEN dat0[0].VSW = [-356.3630e0,-15.1541e0,15.8344e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:55') THEN dat0[0].VSW = [-375.0154e0,-51.0531e0,20.3778e0]
IF (time_string(dat0.TIME) EQ '1998-04-30/08:43:58') THEN dat0[0].VSW = [-372.1243e0,-54.4307e0,17.8377e0]

IF (time_string(dat0.TIME) EQ '1998-08-06/07:15:48') THEN dat0[0].VSW = [-380.7909e0,-14.8820e0,19.2323e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:15:51') THEN dat0[0].VSW = [-382.1079e0,-15.0012e0,19.0561e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:15:54') THEN dat0[0].VSW = [-380.4012e0,-15.5850e0,18.5614e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:15:57') THEN dat0[0].VSW = [-387.6821e0,-18.9998e0,17.2767e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:16:00') THEN dat0[0].VSW = [-382.8362e0,-14.9445e0,19.7951e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:16:03') THEN dat0[0].VSW = [-382.3615e0,-16.1359e0,18.6052e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:16:06') THEN dat0[0].VSW = [-383.9690e0,-14.9906e0,18.7057e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:16:09') THEN dat0[0].VSW = [-412.2612e0, 17.1000e0,18.5827e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:16:12') THEN dat0[0].VSW = [-431.4757e0,-17.0877e0,20.7468e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:16:16') THEN dat0[0].VSW = [-428.1243e0,-18.0809e0,20.5188e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:16:19') THEN dat0[0].VSW = [-432.1410e0,-19.2169e0,19.5233e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:16:22') THEN dat0[0].VSW = [-429.1278e0,-17.8274e0,18.8740e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:16:25') THEN dat0[0].VSW = [-430.7565e0,-16.3856e0,18.1271e0]
IF (time_string(dat0.TIME) EQ '1998-08-06/07:16:28') THEN dat0[0].VSW = [-429.9379e0,-19.2849e0,21.1580e0]

IF (time_string(ROUND(dat0.TIME)) EQ '1998-08-26/06:40:09') THEN dat0[0].VSW = [-492.9499e0,-16.6618e0,  14.0201e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:12') THEN dat0[0].VSW = [-491.5336e0,-17.7164e0, -18.8524e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:15') THEN dat0[0].VSW = [-492.7005e0,-21.7100e0,  20.8060e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:18') THEN dat0[0].VSW = [-498.8677e0,-19.3855e0, -21.2150e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:21') THEN dat0[0].VSW = [-487.8462e0,-17.8081e0, -20.6318e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:24') THEN dat0[0].VSW = [-490.9569e0,-18.5235e0, -22.7134e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:27') THEN dat0[0].VSW = [-666.5784e0,-42.6242e0, -99.9397e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:31') THEN dat0[0].VSW = [-614.8766e0,-24.4186e0,-154.4101e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:34') THEN dat0[0].VSW = [-627.4030e0,-26.7732e0, -98.9203e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:37') THEN dat0[0].VSW = [-619.8375e0,-27.3745e0,-117.8697e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:40') THEN dat0[0].VSW = [-623.8822e0,-25.2721e0,-103.8652e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:43') THEN dat0[0].VSW = [-603.7727e0,-24.9962e0,-146.2020e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:46') THEN dat0[0].VSW = [-612.6281e0,-24.6164e0,-150.1705e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:49') THEN dat0[0].VSW = [-613.8556e0,-23.8681e0,-121.4253e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:52') THEN dat0[0].VSW = [-608.2278e0,-28.0873e0,-147.9517e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:55') THEN dat0[0].VSW = [-579.1158e0,-14.3813e0,-142.9327e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:40:58') THEN dat0[0].VSW = [-597.2398e0, 33.7643e0,-149.7675e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:41:02') THEN dat0[0].VSW = [-605.7021e0, 25.5034e0,-152.6580e0]
IF (time_string(dat0.TIME) EQ '1998-08-26/06:41:08') THEN dat0[0].VSW = [-596.1422e0, 30.9912e0,-149.6676e0]

IF (time_string(dat0.TIME) EQ '2000-02-11/23:33:37') THEN dat0[0].VSW = [-472.8263e0,-20.9610e0,-22.2381e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:33:40') THEN dat0[0].VSW = [-473.2933e0,-21.7572e0,-21.8462e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:33:43') THEN dat0[0].VSW = [-475.3442e0,-21.9133e0,-22.6964e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:33:46') THEN dat0[0].VSW = [-484.6417e0,-21.0594e0,-20.6391e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:33:49') THEN dat0[0].VSW = [-491.9308e0,-22.5864e0,-21.8577e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:33:53') THEN dat0[0].VSW = [-492.6399e0,-22.9649e0,-22.0673e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:33:56') THEN dat0[0].VSW = [-505.7203e0,-24.0989e0, -0.3084e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:33:59') THEN dat0[0].VSW = [-600.3887e0,-93.8431e0, 28.2758e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:34:02') THEN dat0[0].VSW = [-579.9476e0,-82.2059e0, -0.5430e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:34:05') THEN dat0[0].VSW = [-585.2974e0,-83.0016e0, 28.3495e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:34:08') THEN dat0[0].VSW = [-593.5575e0,-81.5971e0, 28.3119e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:34:11') THEN dat0[0].VSW = [-595.6447e0,-81.3664e0, 27.8035e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:34:14') THEN dat0[0].VSW = [-607.0254e0,-84.6503e0, 28.9126e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:34:17') THEN dat0[0].VSW = [-606.5227e0,-84.3020e0, 28.3690e0]
IF (time_string(dat0.TIME) EQ '2000-02-11/23:34:20') THEN dat0[0].VSW = [-604.8601e0,-84.3136e0, 30.8187e0]

IF (time_string(dat0.TIME) EQ '2000-04-06/16:31:34') THEN dat0[0].VSW = [-389.2502e0,-13.1531e0,-18.7872e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:31:37') THEN dat0[0].VSW = [-379.0709e0, 16.4840e0,-21.5006e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:31:40') THEN dat0[0].VSW = [-390.6398e0, 18.0433e0,-19.4024e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:31:43') THEN dat0[0].VSW = [-420.2667e0, 18.3183e0,-20.7311e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:31:47') THEN dat0[0].VSW = [-436.8951e0,-20.0484e0,-21.1516e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:31:50') THEN dat0[0].VSW = [-430.3408e0,-16.0621e0,-17.8055e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:31:53') THEN dat0[0].VSW = [-427.1018e0,-19.2418e0,-21.0955e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:31:56') THEN dat0[0].VSW = [-420.5888e0,-15.5337e0,-20.1828e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:31:59') THEN dat0[0].VSW = [-410.9562e0,-17.5703e0,-19.5939e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:02') THEN dat0[0].VSW = [-411.7519e0,-16.6793e0,-20.5630e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:05') THEN dat0[0].VSW = [-407.7568e0,-17.2251e0,-19.5978e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:08') THEN dat0[0].VSW = [-396.8395e0,-14.8818e0,-18.9075e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:11') THEN dat0[0].VSW = [-503.0957e0,-31.3980e0,-25.7689e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:14') THEN dat0[0].VSW = [-528.5543e0,-73.8992e0, 26.9429e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:18') THEN dat0[0].VSW = [-540.7271e0,-25.7308e0, 24.6527e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:21') THEN dat0[0].VSW = [-550.9739e0,-75.3211e0,-26.1076e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:24') THEN dat0[0].VSW = [-552.0690e0,-75.3500e0,-25.0070e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:27') THEN dat0[0].VSW = [-554.2277e0,-77.4804e0,-28.7788e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:30') THEN dat0[0].VSW = [-552.0674e0,-75.3967e0,-26.2087e0]
IF (time_string(dat0.TIME) EQ '2000-04-06/16:32:33') THEN dat0[0].VSW = [-532.8837e0,-24.6482e0,-24.8170e0]

IF (time_string(dat0.TIME) EQ '2001-11-24/05:51:30') THEN dat0[0].VSW = [ -770.0457e0,186.1830e0, -40.2545e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:51:33') THEN dat0[0].VSW = [ -770.5035e0,187.4351e0, -37.0269e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:51:36') THEN dat0[0].VSW = [ -785.7575e0,120.5232e0, -38.9328e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:51:40') THEN dat0[0].VSW = [ -792.5670e0,118.6746e0, -38.8858e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:51:43') THEN dat0[0].VSW = [ -852.7710e0, 81.5535e0, -44.2715e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:51:46') THEN dat0[0].VSW = [ -845.1200e0,118.5280e0,-120.0550e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:51:49') THEN dat0[0].VSW = [ -914.3267e0,314.3166e0, -46.6282e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:51:52') THEN dat0[0].VSW = [ -927.0810e0,133.4790e0, -48.8040e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:51:55') THEN dat0[0].VSW = [ -995.2540e0,131.2900e0, -53.3630e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:51:58') THEN dat0[0].VSW = [ -994.8490e0, 39.1220e0,-144.9870e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:52:01') THEN dat0[0].VSW = [ -999.8957e0,122.9553e0, -50.7414e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:52:04') THEN dat0[0].VSW = [-1060.6019e0,132.3422e0,-156.4150e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:52:08') THEN dat0[0].VSW = [ -984.5492e0,127.6027e0,-146.6133e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:52:11') THEN dat0[0].VSW = [ -993.2774e0, 42.6973e0,-147.7557e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:52:14') THEN dat0[0].VSW = [-1036.4477e0,122.7999e0,-248.8379e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:52:17') THEN dat0[0].VSW = [ -999.3732e0,151.1610e0,-254.7189e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:52:20') THEN dat0[0].VSW = [-1109.4830e0,240.6730e0,-288.8540e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:52:23') THEN dat0[0].VSW = [-1031.3614e0,236.0153e0,-268.2577e0]
IF (time_string(dat0.TIME) EQ '2001-11-24/05:52:26') THEN dat0[0].VSW = [ -966.0320e0,235.0760e0,-239.0970e0]

IF (vlim[0] GT 1e4) THEN vframe = [0d0,0d0,0d0] ELSE vframe = REFORM(dat0[0].VSW)  ;;  Transformation velocity [km/s]
IF (vlim[0] GT 1e4) THEN ttle_ext       = 'SCF' ELSE ttle_ext       = 'SWF'        ;;  string to add to plot title indicating reference frame shown
IF (tdate[0] EQ '1996-04-03') THEN vframe = REFORM(dat0[0].VSW)  ;;  Transformation velocity [km/s]
IF (tdate[0] EQ '1996-04-03') THEN ttle_ext       = 'SWF'        ;;  string to add to plot title indicating reference frame shown
IF (tdate[0] EQ '1998-08-06') THEN vframe = REFORM(dat0[0].VSW)  ;;  Transformation velocity [km/s]
IF (tdate[0] EQ '1998-08-06') THEN ttle_ext       = 'SWF'        ;;  string to add to plot title indicating reference frame shown
IF (tdate[0] EQ '1998-08-26') THEN vframe = REFORM(dat0[0].VSW)  ;;  Transformation velocity [km/s]
IF (tdate[0] EQ '1998-08-26') THEN ttle_ext       = 'SWF'        ;;  string to add to plot title indicating reference frame shown
IF (tdate[0] EQ '2000-04-06') THEN vframe = REFORM(dat0[0].VSW)  ;;  Transformation velocity [km/s]
IF (tdate[0] EQ '2000-04-06') THEN ttle_ext       = 'SWF'        ;;  string to add to plot title indicating reference frame shown
IF (tdate[0] EQ '2001-11-24') THEN vframe = REFORM(dat0[0].VSW)  ;;  Transformation velocity [km/s]
IF (tdate[0] EQ '2001-11-24') THEN ttle_ext       = 'SWF'        ;;  string to add to plot title indicating reference frame shown
vfmag          = mag__vec(vframe,/NAN)
pttl_pref      = sc[0]+' ['+ttle_ext[0]+'] '+pttl_midf[0]
;;----------------------------------------------------------------------------------------
;;  Plot VDFs
;;----------------------------------------------------------------------------------------
;;  Define one-count level VDF
datc           = dat0[0]
datc.DATA      = 1e0            ;;  Create a one-count copy
;;  Convert to phase space density [# cm^(-3) km^(-3) s^(+3)]
dat_df         = conv_units(dat0,'df')
dat_1c         = conv_units(datc,'df')
;;  Convert F(energy,theta,phi) to F(Vx,Vy,Vz)
dat_fvxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_df)
dat_1cxyz      = conv_vdfidlstr_2_f_vs_vxyz_thm_wi(dat_1c)
;;  Define EX_VECS stuff
ex_vecs[0]     = {VEC:FLOAT(dat_df[0].VSW),NAME:'Vsw'}
ex_vecs[1]     = {VEC:FLOAT(dat_df[0].MAGF),NAME:'Bo'}
ex_vecs[2]     = {VEC:FLOAT(gnorm),NAME:'nsh'}
ex_vecs[3]     = {VEC:[1e0,0e0,0e0],NAME:'Sun'}
;;  Define EX_INFO stuff
ex_info        = {SCPOT:dat_df[0].SC_POT,VSW:dat_df[0].VSW,MAGF:dat_df[0].MAGF}
sm_cuts        = 1b               ;;  Do not smooth cuts
sm_cont        = 1b               ;;  Do not smooth contours
IF (vfmag[0] LT 1e0) THEN vxy_offs = [ex_info.VSW[xyind[0:1]]] ELSE vxy_offs = [0e0,0e0]  ;;  XY-Offsets of crosshairs

ptitle         = pttl_pref[0]+': '+trange_str(tran_vdf[jj,0],tran_vdf[jj,1],/MSEC)
;;  Define data
data_1d        = dat_fvxyz.VDF
vels_1d        = dat_fvxyz.VELXYZ
onec_1d        = dat_1cxyz.VDF
;;  Plot 2D contour in spacecraft frame of reference (SCF), in GSE coordinate basis
WSET,1
WSHOW,1
general_vdf_contour_plot,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim[0],     $
                         PLANE=plane[0],NLEV=nlev,SM_CUTS=sm_cuts,SM_CONT=sm_cont,           $
                         XNAME=xname,YNAME=yname,DFRA=dfra,EX_VECS=ex_vecs,                  $
                         EX_INFO=ex_info,V_0X=vxy_offs[0],V_0Y=vxy_offs[1],/SLICE2D,         $
                         ONE_C=onec_1d,P_TITLE=ptitle

;;  Define file name
vlim_str       = num2int_str(vlim[0],NUM_CHAR=6L,/ZERO_PAD)
fname_end      = 'para-red_perp-blue_1count-green_plane-'+plane[0]+'_VLIM-'+vlim_str[0]+'km_s'
fname_pre      = scpref[0]+'df_'+ttle_ext[0]+'_'
fnams_out      = fname_pre[0]+fname_mid+'_'+fname_end[0]

;;  Save Plot
popen,fnams_out[jj],_EXTRA=popen_str
  general_vdf_contour_plot,data_1d,vels_1d,VFRAME=vframe,VEC1=vec1,VEC2=vec2,VLIM=vlim[0],     $
                           PLANE=plane[0],NLEV=nlev,SM_CUTS=sm_cuts,SM_CONT=sm_cont,           $
                           XNAME=xname,YNAME=yname,DFRA=dfra,EX_VECS=ex_vecs,                  $
                           EX_INFO=ex_info,V_0X=vxy_offs[0],V_0Y=vxy_offs[1],/SLICE2D,         $
                           ONE_C=onec_1d,P_TITLE=ptitle
pclose










;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Find proton phase space density peak
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  ***  Change directory paths accordingly!  ***
;;  Compile necessary routines
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_get_default_struc.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_test_cont_str_form.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_test_plot_str_form.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_test_vdf_str_form.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_test_vdfinfo_str_form.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/testing_routines/vbulk_change_test_windn.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/prompting_routines/vbulk_change_list_options.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/prompting_routines/vbulk_change_prompts.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/prompting_routines/vbulk_change_options.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/misc_routines/vbulk_change_get_fname_ptitle.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/misc_routines/vbulk_change_print_index_time.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/prompting_routines/vbulk_change_keywords_init.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/prompting_routines/vbulk_change_change_parameter.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/vbulk_change_vdf_plot_wrapper.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/vbulk_change_routines/wrapper_vbulk_change_thm_wi.pro
;;  Define array of data structures
data           = aplb          ;;  For low Ni, high Ti cases --> avoid chasing one-count noise
dfra_in        = [1e-8,1e-4]
;dfra_in        = [1e-9,5e-5]
wrapper_vbulk_change_thm_wi,data,DFRA_IN=dfra_in,STRUC_OUT=struc_out

;;  Determine which indices were changed
nd             = N_ELEMENTS(data)
inds           = LINDGEN(nd[0])
vbulk          = TRANSPOSE(struc_out.CONT_STR.VFRAME)
vsw0           = REPLICATE(1d0,nd[0]) # REFORM(vbulk[0,*])
diff           = vbulk - vsw0
test           = (ABS(diff[*,0]) NE 0) OR (ABS(diff[*,1]) NE 0) OR (ABS(diff[*,2]) NE 0)
changed        = WHERE(test,chgd)

ch_st_str      = time_string(data[changed].TIME,PREC=3)
ch_en_str      = time_string(data[changed].END_TIME,PREC=3)
ch_vbulk       = vbulk[changed,*]
gind           = inds[changed]
FOR j=0L, chgd[0] - 1L DO BEGIN $
  PRINT,FORMAT='(";;",I12.4,2a27,3f15.4)',gind[j],ch_st_str[j],ch_en_str[j],REFORM(ch_vbulk[j,*])

;;        0016    1996-04-03/09:47:10.966    1996-04-03/09:47:14.126      -352.6083        17.4598         6.3212
;;        0017    1996-04-03/09:47:14.126    1996-04-03/09:47:17.286      -353.3347        17.7673        13.7160
;;        0018    1996-04-03/09:47:17.286    1996-04-03/09:47:20.445      -353.3309        19.8303        15.7891
;;        0019    1996-04-03/09:47:20.445    1996-04-03/09:47:23.605      -359.5624        17.5794        16.1354
;;        0020    1996-04-03/09:47:23.605    1996-04-03/09:47:26.765      -363.2769        19.0922        16.8559
;;        0021    1996-04-03/09:47:26.765    1996-04-03/09:47:29.925      -366.8244        13.0794        17.8965
;;        0022    1996-04-03/09:47:29.925    1996-04-03/09:47:33.085      -365.0393        17.5948        17.0503


;;        0012    1997-10-24/11:18:01.327    1997-10-24/11:18:04.329      -396.2715       -11.7213        -5.7434
;;        0013    1997-10-24/11:18:04.327    1997-10-24/11:18:07.328      -397.0874       -15.1313        -6.0552
;;        0014    1997-10-24/11:18:07.326    1997-10-24/11:18:10.328      -397.3801       -17.8075       -15.0020
;;        0015    1997-10-24/11:18:10.326    1997-10-24/11:18:13.327      -389.2287       -18.8123        19.3357
;;        0016    1997-10-24/11:18:13.325    1997-10-24/11:18:16.327      -465.4079       -24.5870        22.4631
;;        0017    1997-10-24/11:18:16.325    1997-10-24/11:18:19.326      -451.3080       -19.2740        19.9179
;;        0018    1997-10-24/11:18:19.324    1997-10-24/11:18:22.326      -454.5474       -19.8959        22.3670
;;        0019    1997-10-24/11:18:22.324    1997-10-24/11:18:25.325      -453.1703       -19.1291        20.7198
;;        0020    1997-10-24/11:18:25.323    1997-10-24/11:18:28.325      -453.8663       -15.2789        18.5990
;;        0021    1997-10-24/11:18:28.323    1997-10-24/11:18:31.324      -460.4557       -21.7281        22.2094
;;        0022    1997-10-24/11:18:31.322    1997-10-24/11:18:34.324      -454.1637       -21.8510        22.7399
;;        0023    1997-10-24/11:18:34.322    1997-10-24/11:18:37.323      -454.6235       -19.4149        22.4293

;;        0012    1997-12-10/04:33:03.041    1997-12-10/04:33:06.043      -301.4939        -6.5476       -12.1971
;;        0013    1997-12-10/04:33:06.043    1997-12-10/04:33:09.044      -307.2343       -11.8777       -14.4613
;;        0014    1997-12-10/04:33:09.044    1997-12-10/04:33:12.046      -286.3262        16.2167       -13.6801
;;        0015    1997-12-10/04:33:12.046    1997-12-10/04:33:15.047      -281.2919        16.2553       -12.5898
;;        0016    1997-12-10/04:33:15.047    1997-12-10/04:33:18.049      -297.9887        14.1989       -13.6837
;;        0017    1997-12-10/04:33:18.049    1997-12-10/04:33:21.050      -354.7150        13.3591       -50.6713
;;        0018    1997-12-10/04:33:21.050    1997-12-10/04:33:24.052      -368.5334       -15.6973       -17.5543
;;        0019    1997-12-10/04:33:24.052    1997-12-10/04:33:27.053      -371.4411       -13.1851       -49.8553
;;        0020    1997-12-10/04:33:27.053    1997-12-10/04:33:30.055      -350.7532        19.4279       -51.7943
;;        0021    1997-12-10/04:33:30.055    1997-12-10/04:33:33.056      -338.5256        21.7314       -49.4712
;;        0022    1997-12-10/04:33:33.056    1997-12-10/04:33:36.058      -357.2460        19.3249       -52.6108
;;        0023    1997-12-10/04:33:36.058    1997-12-10/04:33:39.060      -355.6217        18.1246       -52.8204
;;        0024    1997-12-10/04:33:39.060    1997-12-10/04:33:42.061      -365.0726         3.4802       -37.1423
;;        0025    1997-12-10/04:33:42.061    1997-12-10/04:33:45.063      -362.1448        19.7304       -52.3882
;;        0026    1997-12-10/04:33:45.063    1997-12-10/04:33:48.064      -364.7437        18.6998       -51.9190
;;        0027    1997-12-10/04:33:48.064    1997-12-10/04:33:51.066      -357.5767        21.1032       -54.0312

;;        0011    1998-04-30/08:43:01.802    1998-04-30/08:43:04.811      -345.2872       -15.4274        17.6145
;;        0012    1998-04-30/08:43:04.806    1998-04-30/08:43:07.815      -348.9513       -13.7826        16.3279
;;        0013    1998-04-30/08:43:07.811    1998-04-30/08:43:10.819      -348.4708       -14.9936        18.1168
;;        0014    1998-04-30/08:43:10.815    1998-04-30/08:43:13.823      -349.4484       -13.6721        17.5319
;;        0015    1998-04-30/08:43:13.819    1998-04-30/08:43:16.827      -358.3780       -13.9305        17.4255
;;        0016    1998-04-30/08:43:16.823    1998-04-30/08:43:19.831      -390.5576       -20.4922        18.2058
;;        0017    1998-04-30/08:43:19.827    1998-04-30/08:43:22.835      -388.8454       -18.7983        20.3796
;;        0018    1998-04-30/08:43:22.831    1998-04-30/08:43:25.839      -357.7146       -14.1013        18.5884
;;        0019    1998-04-30/08:43:25.835    1998-04-30/08:43:28.843      -348.0529       -15.7437        18.4292
;;        0020    1998-04-30/08:43:28.839    1998-04-30/08:43:31.847      -359.3690       -15.4323        17.3417
;;        0021    1998-04-30/08:43:31.843    1998-04-30/08:43:34.852      -362.6778       -50.4187        51.2017
;;        0022    1998-04-30/08:43:34.847    1998-04-30/08:43:37.856      -370.0599       -50.3053        51.5361
;;        0023    1998-04-30/08:43:37.851    1998-04-30/08:43:40.860      -372.4740       -53.2994        21.4018
;;        0024    1998-04-30/08:43:40.855    1998-04-30/08:43:43.864      -373.9053       -17.0087        20.2134
;;        0025    1998-04-30/08:43:43.860    1998-04-30/08:43:46.868      -376.8880       -16.7596        18.2205
;;        0026    1998-04-30/08:43:46.864    1998-04-30/08:43:49.872      -361.6379       -45.5949        19.6297
;;        0027    1998-04-30/08:43:49.868    1998-04-30/08:43:52.876      -367.5859       -50.5058        18.9356
;;        0028    1998-04-30/08:43:52.872    1998-04-30/08:43:55.880      -356.3630       -15.1541        15.8344
;;        0029    1998-04-30/08:43:55.876    1998-04-30/08:43:58.884      -375.0154       -51.0531        20.3778
;;        0030    1998-04-30/08:43:58.880    1998-04-30/08:44:01.888      -372.1243       -54.4307        17.8377

;;        0107    1998-08-06/07:15:48.136    1998-08-06/07:15:51.238      -380.7909       -14.8820        19.2323
;;        0108    1998-08-06/07:15:51.238    1998-08-06/07:15:54.339      -382.1079       -15.0012        19.0561
;;        0109    1998-08-06/07:15:54.339    1998-08-06/07:15:57.440      -380.4012       -15.5850        18.5614
;;        0110    1998-08-06/07:15:57.440    1998-08-06/07:16:00.541      -387.6821       -18.9998        17.2767
;;        0111    1998-08-06/07:16:00.541    1998-08-06/07:16:03.642      -382.8362       -14.9445        19.7951
;;        0112    1998-08-06/07:16:03.642    1998-08-06/07:16:06.743      -382.3615       -16.1359        18.6052
;;        0113    1998-08-06/07:16:06.743    1998-08-06/07:16:09.845      -383.9690       -14.9906        18.7057
;;        0114    1998-08-06/07:16:09.845    1998-08-06/07:16:12.946      -412.2612        17.1000        18.5827
;;        0115    1998-08-06/07:16:12.946    1998-08-06/07:16:16.047      -431.4757       -17.0877        20.7468
;;        0116    1998-08-06/07:16:16.047    1998-08-06/07:16:19.148      -428.1243       -18.0809        20.5188
;;        0117    1998-08-06/07:16:19.148    1998-08-06/07:16:22.249      -432.1410       -19.2169        19.5233
;;        0118    1998-08-06/07:16:22.249    1998-08-06/07:16:25.350      -429.1278       -17.8274        18.8740
;;        0119    1998-08-06/07:16:25.350    1998-08-06/07:16:28.452      -430.7565       -16.3856        18.1271
;;        0120    1998-08-06/07:16:28.452    1998-08-06/07:16:31.553      -429.9379       -19.2849        21.1580

;;        0053    1998-08-26/06:40:09.341    1998-08-26/06:40:12.443      -492.9499       -16.6618        14.0201
;;        0054    1998-08-26/06:40:12.443    1998-08-26/06:40:15.544      -491.5336       -17.7164       -18.8524
;;        0055    1998-08-26/06:40:15.545    1998-08-26/06:40:18.646      -492.7005       -21.7100        20.8060
;;        0056    1998-08-26/06:40:18.646    1998-08-26/06:40:21.748      -498.8677       -19.3855       -21.2150
;;        0057    1998-08-26/06:40:21.748    1998-08-26/06:40:24.850      -487.8462       -17.8081       -20.6318
;;        0058    1998-08-26/06:40:24.850    1998-08-26/06:40:27.951      -490.9569       -18.5235       -22.7134
;;        0059    1998-08-26/06:40:27.951    1998-08-26/06:40:31.053      -666.5784       -42.6242       -99.9397
;;        0060    1998-08-26/06:40:31.053    1998-08-26/06:40:34.155      -614.8766       -24.4186      -154.4101
;;        0061    1998-08-26/06:40:34.155    1998-08-26/06:40:37.257      -627.4030       -26.7732       -98.9203
;;        0062    1998-08-26/06:40:37.257    1998-08-26/06:40:40.358      -619.8375       -27.3745      -117.8697
;;        0063    1998-08-26/06:40:40.358    1998-08-26/06:40:43.460      -623.8822       -25.2721      -103.8652
;;        0064    1998-08-26/06:40:43.460    1998-08-26/06:40:46.562      -603.7727       -24.9962      -146.2020
;;        0065    1998-08-26/06:40:46.562    1998-08-26/06:40:49.663      -612.6281       -24.6164      -150.1705
;;        0066    1998-08-26/06:40:49.663    1998-08-26/06:40:52.765      -613.8556       -23.8681      -121.4253
;;        0067    1998-08-26/06:40:52.765    1998-08-26/06:40:55.867      -608.2278       -28.0873      -147.9517
;;        0068    1998-08-26/06:40:55.867    1998-08-26/06:40:58.969      -579.1158       -14.3813      -142.9327
;;        0069    1998-08-26/06:40:58.969    1998-08-26/06:41:02.070      -597.2398        33.7643      -149.7675
;;        0070    1998-08-26/06:41:02.070    1998-08-26/06:41:05.172      -605.7021        25.5034      -152.6580
;;        0071    1998-08-26/06:41:08.274    1998-08-26/06:41:11.375      -596.1422        30.9912      -149.6676

;;        0064    2000-02-11/23:33:37.568    2000-02-11/23:33:40.665      -472.8263       -20.9610       -22.2381
;;        0065    2000-02-11/23:33:40.665    2000-02-11/23:33:43.762      -473.2933       -21.7572       -21.8462
;;        0066    2000-02-11/23:33:43.762    2000-02-11/23:33:46.860      -475.3442       -21.9133       -22.6964
;;        0067    2000-02-11/23:33:46.860    2000-02-11/23:33:49.957      -484.6417       -21.0594       -20.6391
;;        0068    2000-02-11/23:33:49.957    2000-02-11/23:33:53.055      -491.9308       -22.5864       -21.8577
;;        0069    2000-02-11/23:33:53.055    2000-02-11/23:33:56.152      -492.6399       -22.9649       -22.0673
;;        0070    2000-02-11/23:33:56.152    2000-02-11/23:33:59.249      -505.7203       -24.0989        -0.3084
;;        0071    2000-02-11/23:33:59.249    2000-02-11/23:34:02.347      -600.3887       -93.8431        28.2758
;;        0072    2000-02-11/23:34:02.347    2000-02-11/23:34:05.444      -579.9476       -82.2059        -0.5430
;;        0073    2000-02-11/23:34:05.444    2000-02-11/23:34:08.542      -585.2974       -83.0016        28.3495
;;        0074    2000-02-11/23:34:08.542    2000-02-11/23:34:11.639      -593.5575       -81.5971        28.3119
;;        0075    2000-02-11/23:34:11.639    2000-02-11/23:34:14.736      -595.6447       -81.3664        27.8035
;;        0076    2000-02-11/23:34:14.736    2000-02-11/23:34:17.834      -607.0254       -84.6503        28.9126
;;        0077    2000-02-11/23:34:17.834    2000-02-11/23:34:20.931      -606.5227       -84.3020        28.3690
;;        0078    2000-02-11/23:34:20.931    2000-02-11/23:34:24.028      -604.8601       -84.3136        30.8187

;;        0009    2000-04-06/16:31:34.687    2000-04-06/16:31:37.787      -389.2502       -13.1531       -18.7872
;;        0010    2000-04-06/16:31:37.785    2000-04-06/16:31:40.886      -379.0709        16.4840       -21.5006
;;        0011    2000-04-06/16:31:40.884    2000-04-06/16:31:43.984      -390.6398        18.0433       -19.4024
;;        0012    2000-04-06/16:31:43.983    2000-04-06/16:31:47.083      -420.2667        18.3183       -20.7311
;;        0013    2000-04-06/16:31:47.081    2000-04-06/16:31:50.181      -436.8951       -20.0484       -21.1516
;;        0014    2000-04-06/16:31:50.180    2000-04-06/16:31:53.280      -430.3408       -16.0621       -17.8055
;;        0015    2000-04-06/16:31:53.278    2000-04-06/16:31:56.379      -427.1018       -19.2418       -21.0955
;;        0016    2000-04-06/16:31:56.377    2000-04-06/16:31:59.477      -420.5888       -15.5337       -20.1828
;;        0017    2000-04-06/16:31:59.476    2000-04-06/16:32:02.576      -410.9562       -17.5703       -19.5939
;;        0018    2000-04-06/16:32:02.574    2000-04-06/16:32:05.674      -411.7519       -16.6793       -20.5630
;;        0019    2000-04-06/16:32:05.673    2000-04-06/16:32:08.773      -407.7568       -17.2251       -19.5978
;;        0020    2000-04-06/16:32:08.771    2000-04-06/16:32:11.872      -396.8395       -14.8818       -18.9075
;;        0021    2000-04-06/16:32:11.870    2000-04-06/16:32:14.970      -503.0957       -31.3980       -25.7689
;;        0022    2000-04-06/16:32:14.969    2000-04-06/16:32:18.069      -528.5543       -73.8992        26.9429
;;        0023    2000-04-06/16:32:18.067    2000-04-06/16:32:21.167      -540.7271       -25.7308        24.6527
;;        0024    2000-04-06/16:32:21.166    2000-04-06/16:32:24.266      -550.9739       -75.3211       -26.1076
;;        0025    2000-04-06/16:32:24.264    2000-04-06/16:32:27.365      -552.0690       -75.3500       -25.0070
;;        0026    2000-04-06/16:32:27.363    2000-04-06/16:32:30.463      -554.2277       -77.4804       -28.7788
;;        0027    2000-04-06/16:32:30.462    2000-04-06/16:32:33.562      -552.0674       -75.3967       -26.2087
;;        0028    2000-04-06/16:32:33.560    2000-04-06/16:32:36.660      -532.8837       -24.6482       -24.8170

;;        0081    2001-11-24/05:51:30.707    2001-11-24/05:51:33.823      -770.0457       186.1830       -40.2545
;;        0082    2001-11-24/05:51:33.818    2001-11-24/05:51:36.933      -770.5035       187.4351       -37.0269
;;        0083    2001-11-24/05:51:36.928    2001-11-24/05:51:40.044      -785.7575       120.5232       -38.9328
;;        0084    2001-11-24/05:51:40.039    2001-11-24/05:51:43.154      -792.5670       118.6746       -38.8858
;;        0085    2001-11-24/05:51:43.150    2001-11-24/05:51:46.265      -852.7710        81.5535       -44.2715
;;        0086    2001-11-24/05:51:46.260    2001-11-24/05:51:49.376      -845.1200       118.5280      -120.0550
;;        0087    2001-11-24/05:51:49.371    2001-11-24/05:51:52.486      -914.3267       314.3166       -46.6282
;;        0088    2001-11-24/05:51:52.482    2001-11-24/05:51:55.597      -927.0810       133.4790       -48.8040
;;        0089    2001-11-24/05:51:55.592    2001-11-24/05:51:58.708      -995.2540       131.2900       -53.3630
;;        0090    2001-11-24/05:51:58.703    2001-11-24/05:52:01.818      -994.8490        39.1220      -144.9870
;;        0091    2001-11-24/05:52:01.814    2001-11-24/05:52:04.929      -999.8957       122.9553       -50.7414
;;        0092    2001-11-24/05:52:04.924    2001-11-24/05:52:08.040     -1060.6019       132.3422      -156.4150
;;        0093    2001-11-24/05:52:08.035    2001-11-24/05:52:11.150      -984.5492       127.6027      -146.6133
;;        0094    2001-11-24/05:52:11.146    2001-11-24/05:52:14.261      -993.2774        42.6973      -147.7557
;;        0095    2001-11-24/05:52:14.256    2001-11-24/05:52:17.372     -1036.4477       122.7999      -248.8379
;;        0096    2001-11-24/05:52:17.367    2001-11-24/05:52:20.482      -999.3732       151.1610      -254.7189
;;        0097    2001-11-24/05:52:20.477    2001-11-24/05:52:23.593     -1109.4830       240.6730      -288.8540
;;        0098    2001-11-24/05:52:23.588    2001-11-24/05:52:26.704     -1031.3614       236.0153      -268.2577
;;        0099    2001-11-24/05:52:26.699    2001-11-24/05:52:29.814      -966.0320       235.0760      -239.0970


































