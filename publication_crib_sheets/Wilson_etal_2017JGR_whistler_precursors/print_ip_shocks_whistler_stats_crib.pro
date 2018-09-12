;;  print_ip_shocks_whistler_stats_crib.pro

;;----------------------------------------------------------------------------------------
;;  Initialize and setup
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_ip_shocks_whistler_stats_batch.pro

;;----------------------------------------------------------------------------------------
;;  Print statistical results
;;----------------------------------------------------------------------------------------
PRINT,';;  N_all_CfA = ',n_all_cfa[0],';  N_good_sh = ',n_all[0]                                        & $
PRINT,';;  N_whistler = ',gd_y_all[0],';  N_nothing = ',gd_n_all[0],';  N_maybe = ',gd_m_all[0]         & $
PRINT,';;  N_undersampled = ',gd_2_aum[0],';  N_resolved = ',gd_2_asg[0],';  N_partres = ',gd_2_alp[0]  & $
PRINT,';;  N_ww_usam = ',gd_y_aum[0],';  N_ww_rsol = ',gd_y_asg[0],';  N_ww_part = ',gd_y_alp[0]        & $
PRINT,';;  N_no_usam = ',gd_n_aum[0],';  N_no_rsol = ',gd_n_asg[0]
;;  N_all_CfA =           430;  N_good_sh =          145
;;  N_whistler =          113;  N_nothing =           17;  N_maybe =             15
;;  N_undersampled =       83;  N_resolved =          13;  N_partres =           33
;;  N_ww_usam =            67;  N_ww_rsol =           13;  N_ww_part =           33
;;  N_no_usam =             1;  N_no_rsol =            0

PRINT,';;  N_good_sh [%] = ',1d2*n_all[0]/(1d0*n_all_cfa[0])                                            & $
PRINT,';;  N_[ww,nn,mb] [%] = ',1d2*[gd_y_all[0],gd_n_all[0],gd_m_all[0]]/(1d0*n_all[0])                & $
PRINT,';;  N_[um,sg,pr] [%] = ',1d2*[gd_2_aum[0],gd_2_asg[0],gd_2_alp[0]]/(1d0*n_all[0])                & $
PRINT,';;  N_ww_[um,sg,pr] [%] = ',1d2*[gd_y_aum[0],gd_y_asg[0],gd_y_alp[0]]/(1d0*n_all[0])             & $
PRINT,';;  N_no_[um,sg] [%] = ',1d2*[gd_n_aum[0],gd_n_asg[0]]/(1d0*n_all[0])
;;  N_good_sh [%] =           33.720930
;;  N_[ww,nn,mb] [%] =        77.931034       11.724138       10.344828
;;  N_[um,sg,pr] [%] =        57.241379       8.9655172       22.758621
;;  N_ww_[um,sg,pr] [%] =     46.206897       8.9655172       22.758621
;;  N_no_[um,sg] [%] =         0.68965517     0.0000000

;;----------------------------------------------------------------------------------------
;;  Create histograms of all good shocks results [combine]
;;----------------------------------------------------------------------------------------
WINDOW,0,XSIZE=1000,YSIZE=600
;;  Define indices
ind0           = good_A                   ;;  All good shocks
ind1           = good_A[good_y_all0]      ;;  All good shocks with whistlers
ind2           = good_A[good_n_all0]      ;;  All good shocks without whistlers

;;  Upstream plasma beta
xran_beta_up   = [0e0,1e0]
bins_beta_up   = 1e-1
binbeta_up     = HISTOGRAM(beta_t_up[ind0],BINSIZE=bins_beta_up[0],MIN=xran_beta_up[0],MAX=xran_beta_up[1],LOCATIONS=lx_beta_up,/NAN)
yran_beta_up   = [0e0,MAX(binbeta_up,/NAN) + 1e0]
xx_beta_up     = lx_beta_up + bins_beta_up[0]/2e0
xdata0         = xx_beta_up
ydata0         = binbeta_up
xran0          = xran_beta_up
yran0          = yran_beta_up
binbeta_up     = HISTOGRAM(beta_t_up[ind1],BINSIZE=bins_beta_up[0],MIN=xran_beta_up[0],MAX=xran_beta_up[1],LOCATIONS=lx_beta_up,/NAN)
yran_beta_up   = [0e0,MAX(binbeta_up,/NAN) + 1e0]
xx_beta_up     = lx_beta_up + bins_beta_up[0]/2e0
xdata1         = xx_beta_up
ydata1         = binbeta_up
xran1          = xran_beta_up
yran1          = yran_beta_up
binbeta_up     = HISTOGRAM(beta_t_up[ind2],BINSIZE=bins_beta_up[0],MIN=xran_beta_up[0],MAX=xran_beta_up[1],LOCATIONS=lx_beta_up,/NAN)
yran_beta_up   = [0e0,MAX(binbeta_up,/NAN) + 1e0]
xx_beta_up     = lx_beta_up + bins_beta_up[0]/2e0
xdata2         = xx_beta_up
ydata2         = binbeta_up
xran2          = xran_beta_up
yran2          = yran_beta_up
xran           = xran0
yran           = [0e0,MAX([yran0,yran1,yran2],/NAN)]

;;  Shock normal angle [degrees]
xran_thbn_up   = [45e0,90e0]
bins_thbn_up   = 5e0
binthbn_up     = HISTOGRAM(thetbn_up[ind0],BINSIZE=bins_thbn_up[0],MIN=xran_thbn_up[0],MAX=xran_thbn_up[1],LOCATIONS=lx_thbn_up,/NAN)
yran_thbn_up   = [0e0,MAX(binthbn_up,/NAN) + 1e0]
xx_thbn_up     = lx_thbn_up + bins_thbn_up[0]/2e0
xdata0         = xx_thbn_up
ydata0         = binthbn_up
xran0          = xran_thbn_up
yran0          = yran_thbn_up
binthbn_up     = HISTOGRAM(thetbn_up[ind1],BINSIZE=bins_thbn_up[0],MIN=xran_thbn_up[0],MAX=xran_thbn_up[1],LOCATIONS=lx_thbn_up,/NAN)
yran_thbn_up   = [0e0,MAX(binthbn_up,/NAN) + 1e0]
xx_thbn_up     = lx_thbn_up + bins_thbn_up[0]/2e0
xdata1         = xx_thbn_up
ydata1         = binthbn_up
xran1          = xran_thbn_up
yran1          = yran_thbn_up
binthbn_up     = HISTOGRAM(thetbn_up[ind2],BINSIZE=bins_thbn_up[0],MIN=xran_thbn_up[0],MAX=xran_thbn_up[1],LOCATIONS=lx_thbn_up,/NAN)
yran_thbn_up   = [0e0,MAX(binthbn_up,/NAN) + 1e0]
xx_thbn_up     = lx_thbn_up + bins_thbn_up[0]/2e0
xdata2         = xx_thbn_up
ydata2         = binthbn_up
xran2          = xran_thbn_up
yran2          = yran_thbn_up
xran           = xran0
yran           = [0e0,MAX([yran0,yran1,yran2],/NAN)]

;;  Upstream fast mode Mach number
xran_m_f__up   = [1e0,3e0]
bins_m_f__up   = 15e-2
binm_f__up     = HISTOGRAM(Mfast__up[ind0],BINSIZE=bins_m_f__up[0],MIN=xran_m_f__up[0],MAX=xran_m_f__up[1],LOCATIONS=lx_m_f__up,/NAN)
yran_m_f__up   = [0e0,MAX(binm_f__up,/NAN) + 1e0]
xx_m_f__up     = lx_m_f__up + bins_m_f__up[0]/2e0
xdata0         = xx_m_f__up
ydata0         = binm_f__up
xran0          = xran_m_f__up
yran0          = yran_m_f__up
binm_f__up     = HISTOGRAM(Mfast__up[ind1],BINSIZE=bins_m_f__up[0],MIN=xran_m_f__up[0],MAX=xran_m_f__up[1],LOCATIONS=lx_m_f__up,/NAN)
yran_m_f__up   = [0e0,MAX(binm_f__up,/NAN) + 1e0]
xx_m_f__up     = lx_m_f__up + bins_m_f__up[0]/2e0
xdata1         = xx_m_f__up
ydata1         = binm_f__up
xran1          = xran_m_f__up
yran1          = yran_m_f__up
binm_f__up     = HISTOGRAM(Mfast__up[ind2],BINSIZE=bins_m_f__up[0],MIN=xran_m_f__up[0],MAX=xran_m_f__up[1],LOCATIONS=lx_m_f__up,/NAN)
yran_m_f__up   = [0e0,MAX(binm_f__up,/NAN) + 1e0]
xx_m_f__up     = lx_m_f__up + bins_m_f__up[0]/2e0
xdata2         = xx_m_f__up
ydata2         = binm_f__up
xran2          = xran_m_f__up
yran2          = yran_m_f__up
xran           = xran0
yran           = [0e0,MAX([yran0,yran1,yran2],/NAN)]

;;  Upstream Alfvenic Mach number
xran_m_A__up   = [1e0,3e0]
bins_m_A__up   = 15e-2
binm_A__up     = HISTOGRAM(M_VA___up[ind0],BINSIZE=bins_m_A__up[0],MIN=xran_m_A__up[0],MAX=xran_m_A__up[1],LOCATIONS=lx_m_A__up,/NAN)
yran_m_A__up   = [0e0,MAX(binm_A__up,/NAN) + 1e0]
xx_m_A__up     = lx_m_A__up + bins_m_A__up[0]/2e0
xdata0         = xx_m_A__up
ydata0         = binm_A__up
xran0          = xran_m_A__up
yran0          = yran_m_A__up
binm_A__up     = HISTOGRAM(M_VA___up[ind1],BINSIZE=bins_m_A__up[0],MIN=xran_m_A__up[0],MAX=xran_m_A__up[1],LOCATIONS=lx_m_A__up,/NAN)
yran_m_A__up   = [0e0,MAX(binm_A__up,/NAN) + 1e0]
xx_m_A__up     = lx_m_A__up + bins_m_A__up[0]/2e0
xdata1         = xx_m_A__up
ydata1         = binm_A__up
xran1          = xran_m_A__up
yran1          = yran_m_A__up
binm_A__up     = HISTOGRAM(M_VA___up[ind2],BINSIZE=bins_m_A__up[0],MIN=xran_m_A__up[0],MAX=xran_m_A__up[1],LOCATIONS=lx_m_A__up,/NAN)
yran_m_A__up   = [0e0,MAX(binm_A__up,/NAN) + 1e0]
xx_m_A__up     = lx_m_A__up + bins_m_A__up[0]/2e0
xdata2         = xx_m_A__up
ydata2         = binm_A__up
xran2          = xran_m_A__up
yran2          = yran_m_A__up
xran           = xran0
yran           = [0e0,MAX([yran0,yran1,yran2],/NAN)]

;;  Upstream shock normal speed [SCF]
xran_Vshn_up   = [0e0,1e3]
bins_Vshn_up   = 5e1
binVshn_up     = HISTOGRAM(vshn___up[ind0],BINSIZE=bins_Vshn_up[0],MIN=xran_Vshn_up[0],MAX=xran_Vshn_up[1],LOCATIONS=lx_Vshn_up,/NAN)
yran_Vshn_up   = [0e0,MAX(binVshn_up,/NAN) + 1e0]
xx_Vshn_up     = lx_Vshn_up + bins_Vshn_up[0]/2e0
xdata0         = xx_Vshn_up
ydata0         = binVshn_up
xran0          = xran_Vshn_up
yran0          = yran_Vshn_up
binVshn_up     = HISTOGRAM(vshn___up[ind1],BINSIZE=bins_Vshn_up[0],MIN=xran_Vshn_up[0],MAX=xran_Vshn_up[1],LOCATIONS=lx_Vshn_up,/NAN)
yran_Vshn_up   = [0e0,MAX(binVshn_up,/NAN) + 1e0]
xx_Vshn_up     = lx_Vshn_up + bins_Vshn_up[0]/2e0
xdata1         = xx_Vshn_up
ydata1         = binVshn_up
xran1          = xran_Vshn_up
yran1          = yran_Vshn_up
binVshn_up     = HISTOGRAM(vshn___up[ind2],BINSIZE=bins_Vshn_up[0],MIN=xran_Vshn_up[0],MAX=xran_Vshn_up[1],LOCATIONS=lx_Vshn_up,/NAN)
yran_Vshn_up   = [0e0,MAX(binVshn_up,/NAN) + 1e0]
xx_Vshn_up     = lx_Vshn_up + bins_Vshn_up[0]/2e0
xdata2         = xx_Vshn_up
ydata2         = binVshn_up
xran2          = xran_Vshn_up
yran2          = yran_Vshn_up
xran           = xran0
yran           = [0e0,MAX([yran0,yran1,yran2],/NAN)]

;;  Upstream shock normal speed [SHF]
xran_Ushn_up   = [0e0,3e2]
bins_Ushn_up   = 10e0
binUshn_up     = HISTOGRAM(ushn___up[ind0],BINSIZE=bins_Ushn_up[0],MIN=xran_Ushn_up[0],MAX=xran_Ushn_up[1],LOCATIONS=lx_Ushn_up,/NAN)
yran_Ushn_up   = [0e0,MAX(binUshn_up,/NAN) + 1e0]
xx_Ushn_up     = lx_Ushn_up + bins_Ushn_up[0]/2e0
xdata0         = xx_Ushn_up
ydata0         = binUshn_up
xran0          = xran_Ushn_up
yran0          = yran_Ushn_up
binUshn_up     = HISTOGRAM(ushn___up[ind1],BINSIZE=bins_Ushn_up[0],MIN=xran_Ushn_up[0],MAX=xran_Ushn_up[1],LOCATIONS=lx_Ushn_up,/NAN)
yran_Ushn_up   = [0e0,MAX(binUshn_up,/NAN) + 1e0]
xx_Ushn_up     = lx_Ushn_up + bins_Ushn_up[0]/2e0
xdata1         = xx_Ushn_up
ydata1         = binUshn_up
xran1          = xran_Ushn_up
yran1          = yran_Ushn_up
binUshn_up     = HISTOGRAM(ushn___up[ind2],BINSIZE=bins_Ushn_up[0],MIN=xran_Ushn_up[0],MAX=xran_Ushn_up[1],LOCATIONS=lx_Ushn_up,/NAN)
yran_Ushn_up   = [0e0,MAX(binUshn_up,/NAN) + 1e0]
xx_Ushn_up     = lx_Ushn_up + bins_Ushn_up[0]/2e0
xdata2         = xx_Ushn_up
ydata2         = binUshn_up
xran2          = xran_Ushn_up
yran2          = yran_Ushn_up
xran           = xran0
yran           = [0e0,MAX([yran0,yran1,yran2],/NAN)]


WSET,0
WSHOW,0
PLOT,xdata0,ydata0,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xdata0,ydata0,PSYM=10,COLOR=250
  OPLOT,xdata1,ydata1,PSYM=10,COLOR=150
  OPLOT,xdata2,ydata2,PSYM=10,COLOR= 50




;  data = [vshn___up[j],thetbn_up[j],beta_t_up[j],N2_N1__up[j],M_VA___up[j],Mfast__up[j]]   & $


;;  Summary:
;;    Of the 430 FF IP shocks in the CfA database between Jan. 1, 1995 and Mar. 15, 2016,
;;    there were 145 satisfying:
;;      (M_f ≥ 1) && (ø_Bn ≥ 45) && (1 ≤ M_A ≤ 3) && (1 ≤ N2/N1 ≤ 3) && (ß_1 ≤ 1)
;;
;;    Of the 145 meeting these requirements:
;;      --  113(~77.93%) show clear whistler precursors, 17(~11.72%) show no evidence
;;          of whistler precursors, and 15(~10.34%) have ambiguous features that may be
;;          or may not be whistler precursors;
;;      --  83(~57.24%) were observed as undersampled and/or under resolved,
;;          only 13(~8.97%) appeared to be fully resolved (i.e., no spiky-discontinuous
;;          features or triangle-like fluctuations), and 33(~22.76%) were partially
;;          resolved (i.e., not triangle-like but not completely smooth either); and
;;      --  thus, only 13(~8.97%) of the 113 shocks with whistlers were fully resolved.


;;  Observations:
;;    Ramírez Vélez et al.  [2012] JGR  :  looked at beta vs. wave occurrence for STEREO shocks

;;  Simulations:
;;    Matsukiyo & Scholer,  [2003] JGR  :  PIC with beta ~ 0.1 with upstream waves (2 MTSI)
;;    Hellinger et al.,     [2007] GRL  :  Hybrid showing whistler occurrence vs. upstream beta and M_A
;;    Hellinger & Mangeney, [1997] ESA  :  Hybrid with beta ~ 0.5 and M_A ~ 2.6 with upstream whistlers





;;  1st Letter
;;  Y   =  Yes
;;  N   =  No
;;  M   =  Maybe or Unclear
;;
;;  2nd Letter
;;  S   =  resolved or sampled well enough
;;  U   =  fluctuation present but undersampled (e.g., looks like triangle wave)
;;  P   =  mostly resolved but still a little spiky
;;  G   =  data gap or missing data (but still well resolved)
;;  M   =  data gap or missing data (and undersampled)
;;  N   =  nothing
;;
;;-------------------------------------------------------------------------------------------------------------------------------------------
;;             Start                      End              Method     Vshn     Theta     beta_T     N2/N1      M_A       M_f      Whistler
;;===========================================================================================================================================
;;     1995-03-04/00:36:54.500   1995-03-04/00:37:02.500    RH08     380.2      86.1       0.5       1.9       2.6       2.0         MU
;;     1995-04-17/23:33:00.500   1995-04-17/23:33:10.500    RH08     389.2      80.0       0.2       1.8       1.3       1.1         YU
;;     1995-07-22/05:35:39.500   1995-07-22/05:35:47.500    RH08       9.3      52.1       0.2       2.0       1.4       1.2         YP
;;     1995-08-22/12:56:42.500   1995-08-22/12:56:55.500    RH08     381.0      66.1       0.7       2.6       2.6       1.8         YG
;;     1995-08-24/22:11:00.500   1995-08-24/22:11:08.500    RH08     387.7      73.7       0.3       1.5       2.5       2.0         YU
;;     1995-09-14/21:23:50.200   1995-09-14/21:26:00.899    RH08     328.4      81.3       0.5       1.6       2.0       1.5         NN
;;     1995-10-22/21:20:12.500   1995-10-22/21:20:20.500    RH08     333.0      65.7       0.5       1.8       2.7       2.1         YU
;;     1995-12-24/05:57:30.500   1995-12-24/05:57:38.500    RH08     422.8      58.4       0.3       2.6       2.9       2.5         YU
;;     1996-02-06/19:14:18.500   1996-02-06/19:14:30.500    RH08     383.4      48.4       0.4       1.7       1.7       1.4         YU
;;     1996-04-03/09:47:12.500   1996-04-03/09:47:20.500    RH08     379.2      75.7       0.4       1.5       2.0       1.6         YP
;;     1996-04-08/02:41:06.500   1996-04-08/02:41:14.500    RH08     182.3      73.3       0.2       1.7       2.4       2.1         YP
;;     1996-06-18/22:35:51.500   1996-06-18/22:35:59.500    RH08     460.8      49.9       0.3       1.5       1.7       1.4         NN
;;     1997-01-05/03:20:42.500   1997-01-05/03:20:50.500    RH09     384.2      64.3       0.3       1.6       1.4       1.2         MU
;;     1997-03-15/22:30:27.500   1997-03-15/22:30:35.500     MX3     386.1      49.9       0.5       1.5       1.4       1.1         YS
;;     1997-04-10/12:58:30.500   1997-04-10/12:58:38.500    RH08     371.4      58.5       0.3       1.5       1.5       1.2         YU
;;     1997-04-16/12:21:21.500   1997-04-16/12:21:29.500    RH08     401.3      67.7       0.9       1.6       2.2       1.4         MU
;;     1997-05-20/05:10:43.500   1997-05-20/05:10:53.500    RH08     349.6      46.0       0.5       2.5       1.9       1.5         NN
;;     1997-05-25/13:49:51.500   1997-05-25/13:49:59.500    RH08     374.1      85.5       0.6       1.5       2.6       1.8         MU
;;     1997-05-26/09:09:03.500   1997-05-26/09:09:11.500    RH08     335.2      50.3       0.6       1.8       3.0       2.3         NN
;;     1997-08-05/04:59:00.500   1997-08-05/04:59:08.500    RH08     392.4      56.5       0.8       1.5       1.5       1.0         NN
;;     1997-09-03/08:38:36.500   1997-09-03/08:38:44.500     MX3     477.3      78.2       0.3       1.5       1.3       1.1         NN
;;     1997-10-10/15:57:03.500   1997-10-10/15:57:11.500    RH08     477.3      87.7       0.1       1.6       1.6       1.5         MU
;;     1997-10-24/11:18:03.500   1997-10-24/11:18:11.500    RH08     490.9      68.3       0.2       2.5       1.9       1.7         YP
;;     1997-11-01/06:14:39.500   1997-11-01/06:14:47.500    RH08     309.2      77.3       0.4       1.5       2.4       1.8         YP
;;     1997-12-10/04:33:09.500   1997-12-10/04:33:17.500    RH08     391.2      70.9       0.3       2.5       2.7       2.3         YU
;;     1997-12-30/01:13:39.500   1997-12-30/01:13:47.500    RH08     423.4      87.4       0.4       2.0       2.5       1.9         YU
;;     1998-01-06/13:28:57.500   1998-01-06/13:29:05.500    RH08     408.4      82.3       0.3       2.8       2.4       2.0         YU
;;     1998-02-18/07:48:35.500   1998-02-18/07:48:50.500    RH08     463.4      48.7       0.1       1.5       1.2       1.1         YS
;;     1998-05-29/15:12:00.500   1998-05-29/15:12:08.500    RH08     692.5      64.5       0.6       2.1       1.8       1.4         YU
;;     1998-08-06/07:16:03.500   1998-08-06/07:16:11.500    RH08     478.8      80.8       0.1       1.9       1.7       1.6         YU
;;     1998-08-19/18:40:36.500   1998-08-19/18:40:44.500    RH08     334.7      45.5       0.4       2.3       2.8       2.3         YU
;;     1998-11-08/04:41:12.500   1998-11-08/04:41:20.500    RH08     644.5      54.6       0.0       2.2       1.5       1.5         YU
;;     1998-12-26/09:54:13.600   1998-12-26/09:57:59.299    RH09     483.7      78.6       0.4       1.5       1.4       1.1         MU
;;     1998-12-28/18:20:12.500   1998-12-28/18:20:20.500    RH08     465.2      60.7       0.4       1.8       1.8       1.4         YP
;;     1999-01-13/10:47:30.500   1999-01-13/10:48:00.500    RH08     433.1      70.9       0.5       2.1       2.5       1.9         YP
;;     1999-02-17/07:12:09.500   1999-02-17/07:12:17.500    RH08     560.2      86.6       0.2       1.6       1.6       1.4         YU
;;     1999-03-10/01:32:57.500   1999-03-10/01:33:05.500    RH08     509.3      84.7       0.9       1.8       2.8       1.7         NN
;;     1999-04-16/11:12:30.399   1999-04-16/11:14:42.100    RH09     479.8      62.3       0.1       2.1       1.6       1.5         YP
;;     1999-06-26/19:30:54.500   1999-06-26/19:31:02.500    RH08     467.2      59.4       0.3       2.2       2.2       1.8         YM
;;     1999-08-04/01:44:25.500   1999-08-04/01:44:41.500    RH08     418.1      54.1       0.1       1.9       2.1       2.0         YP
;;     1999-08-23/12:11:09.500   1999-08-23/12:11:17.500    RH08     491.2      60.7       0.0       1.6       1.5       1.4         YP
;;     1999-09-15/07:43:35.500   1999-09-15/07:44:00.500    RH08     665.5      73.6       0.7       2.0       2.0       1.4         NN
;;     1999-09-22/12:09:21.500   1999-09-22/12:09:29.500    RH08     510.7      70.8       0.4       2.6       2.4       1.9         YU
;;     1999-10-21/02:20:48.500   1999-10-21/02:20:56.500    RH08     477.3      69.4       0.2       2.3       2.5       2.2         YM
;;     1999-11-05/20:01:45.399   1999-11-05/20:03:37.700    RH08     392.6      52.7       0.3       1.5       1.5       1.2         YP
;;     1999-11-13/12:48:54.500   1999-11-13/12:49:02.500    RH08     470.3      69.1       0.0       1.9       1.4       1.3         YU
;;     2000-02-05/15:26:24.500   2000-02-05/15:26:32.500    RH08     444.0      68.1       0.2       1.9       1.3       1.1         YU
;;     2000-02-14/07:12:50.500   2000-02-14/07:13:10.500    RH08     700.7      56.3       0.4       1.8       1.8       1.5         YP
;;     2000-06-23/12:57:24.100   2000-06-23/12:58:24.500    RH08     527.6      56.1       0.5       2.6       2.8       2.2         YP
;;     2000-07-13/09:43:30.500   2000-07-13/09:43:55.500    RH08     641.4      51.9       0.7       2.4       2.1       1.5         YU
;;     2000-07-26/19:00:09.500   2000-07-26/19:00:17.500    RH08     425.0      86.0       0.6       1.8       2.0       1.4         YU
;;     2000-07-28/06:38:42.500   2000-07-28/06:38:50.500    RH08     491.4      56.2       0.0       2.8       1.9       1.8         YU
;;     2000-08-10/05:13:10.500   2000-08-10/05:13:30.500    RH08     379.9      67.0       0.2       1.7       1.3       1.1         YU
;;     2000-08-11/18:49:30.500   2000-08-11/18:49:38.500    RH08     605.1      78.2       0.0       2.7       1.3       1.3         YM
;;     2000-10-03/01:02:10.500   2000-10-03/01:02:30.500    RH08     457.2      51.5       0.6       1.9       2.2       1.7         NN
;;     2000-10-28/06:35:58.500   2000-10-28/06:41:05.299    RH08     413.6      59.1       0.3       2.1       2.0       1.7         MU
;;     2000-10-28/09:30:20.500   2000-10-28/09:30:55.500    RH08     441.1      51.6       0.7       2.5       2.1       1.5         YU
;;     2000-10-31/17:09:54.500   2000-10-31/17:10:02.500    RH08     475.3      71.1       0.2       2.6       1.8       1.6         YU
;;     2000-11-04/02:25:42.500   2000-11-04/02:25:50.500    RH08     450.1      66.4       0.3       2.3       2.3       1.9         NN
;;     2000-11-06/09:29:40.500   2000-11-06/09:30:15.500    RH08     626.0      70.4       0.3       2.3       2.0       1.7         YP
;;     2000-11-11/04:06:26.000   2000-11-11/04:15:13.000    RH08     975.6      56.7       0.3       2.1       1.8       1.5         MU
;;     2000-11-26/11:43:24.500   2000-11-26/11:43:32.500    RH08     509.7      64.9       0.7       2.5       2.5       1.8         YM
;;     2000-11-28/05:25:40.000   2000-11-28/05:27:51.899    RH08     603.8      58.3       0.3       2.1       1.6       1.4         YP
;;     2001-01-17/04:07:48.500   2001-01-17/04:07:56.500    RH08     379.2      69.7       0.4       1.5       1.7       1.3         YP
;;     2001-03-03/11:29:05.500   2001-03-03/11:29:20.500    RH08     553.6      45.5       0.5       2.2       2.4       1.9         YS
;;     2001-03-22/13:59:03.500   2001-03-22/13:59:11.500    RH08     382.0      73.5       0.2       2.3       1.4       1.3         YU
;;     2001-03-27/18:07:45.500   2001-03-27/18:07:53.500    RH08     552.1      57.2       0.4       2.0       2.1       1.8         YU
;;     2001-04-21/15:29:09.500   2001-04-21/15:29:17.500    RH08     395.4      81.0       0.5       1.7       2.5       1.8         YU
;;     2001-05-06/09:06:03.500   2001-05-06/09:06:11.500    RH08     365.6      45.8       0.4       1.5       1.6       1.3         YP
;;     2001-05-12/10:03:09.500   2001-05-12/10:03:17.500    RH08     574.7      68.2       0.1       1.4       1.2       1.1         YP
;;     2001-08-12/16:12:42.500   2001-08-12/16:12:50.500    RH08     340.2      72.4       0.2       1.7       2.2       1.9         MU
;;     2001-08-31/01:25:00.500   2001-08-31/01:25:08.500    RH08     475.3      82.5       0.3       1.4       1.5       1.2         NN
;;     2001-09-13/02:31:20.500   2001-09-13/02:31:35.500    RH08     454.5      72.1       0.3       1.5       1.3       1.1         YU
;;     2001-10-28/03:13:42.500   2001-10-28/03:13:50.500    RH08     591.8      60.3       0.0       2.9       2.3       2.3         YU
;;     2001-11-30/18:15:35.500   2001-11-30/18:15:55.500    RH08     417.9      59.7       0.4       1.4       2.0       1.6         YP
;;     2001-12-21/14:10:05.500   2001-12-21/14:10:25.500    RH08     565.8      65.1       0.1       1.5       2.2       2.0         YP
;;     2001-12-30/20:05:00.500   2001-12-30/20:05:15.500    RH08     669.0      63.0       0.6       2.3       2.5       1.8         YM
;;     2002-01-17/05:26:51.500   2002-01-17/05:26:59.500    RH09     404.3      51.2       0.2       1.4       1.3       1.1         YP
;;     2002-01-31/21:38:06.500   2002-01-31/21:38:14.500    RH08     363.9      67.9       0.1       2.1       2.4       2.1         YU
;;     2002-03-23/11:24:03.500   2002-03-23/11:24:11.500    RH08     520.1      68.0       0.5       2.6       2.8       2.1         YU
;;     2002-03-29/22:15:09.500   2002-03-29/22:15:17.500    RH08     398.7      82.9       0.7       2.7       2.9       2.0         YU
;;     2002-05-21/21:14:10.500   2002-05-21/21:14:20.500    RH09     257.3      49.5       0.5       2.2       1.9       1.5         YP
;;     2002-06-29/21:10:15.500   2002-06-29/21:10:29.500    RH08     385.4      61.1       0.3       1.4       1.4       1.2         YS
;;     2002-08-01/23:09:03.500   2002-08-01/23:09:11.500    RH08     497.4      70.1       0.1       2.0       1.5       1.4         YU
;;     2002-09-30/07:54:21.500   2002-09-30/07:54:29.500    RH08     326.5      78.8       0.2       2.1       1.4       1.2         YM
;;     2002-10-02/22:41:00.500   2002-10-02/22:41:08.500    RH08     527.2      78.4       0.4       2.1       2.0       1.6         MU
;;     2002-11-09/18:27:45.500   2002-11-09/18:27:53.500    RH08     425.0      70.0       0.1       2.0       1.8       1.7         YU
;;     2003-05-29/18:31:03.500   2003-05-29/18:31:11.500    RH08     907.8      73.0       0.1       2.0       2.0       1.9         YU
;;     2003-06-18/04:42:00.500   2003-06-18/04:42:08.500    RH08     618.7      86.8       0.2       1.5       1.8       1.5         YP
;;     2004-04-12/18:29:32.099   2004-04-12/18:29:56.700    RH08     558.6      60.2       0.5       1.9       2.7       2.0         YU
;;     2005-05-06/12:08:30.500   2005-05-06/12:08:45.500    RH08     416.8      48.6       0.4       1.6       2.4       1.9         YS
;;     2005-05-07/18:26:12.500   2005-05-07/18:26:20.500    RH08     437.9      61.6       0.2       1.5       1.1       1.0         YU
;;     2005-06-16/08:09:06.500   2005-06-16/08:09:14.500    RH08     620.6      66.0       0.0       2.0       1.3       1.3         YU
;;     2005-07-10/02:42:27.500   2005-07-10/02:42:35.500    RH08     540.5      80.7       0.1       1.7       2.3       2.1         YU
;;     2005-07-16/01:40:54.500   2005-07-16/01:41:02.500    RH08     421.8      84.0       0.6       1.7       2.0       1.5         NN
;;     2005-08-01/06:00:48.500   2005-08-01/06:00:56.500    RH08     479.6      84.2       0.2       1.8       1.8       1.6         MU
;;     2005-08-24/05:35:18.500   2005-08-24/05:35:26.500    RH08     579.1      86.9       0.3       2.5       2.0       1.6         YM
;;     2005-09-02/13:50:09.500   2005-09-02/13:50:20.500    RH08     587.0      53.0       0.5       2.2       2.6       2.0         YU
;;     2005-09-15/08:36:15.500   2005-09-15/08:36:45.500    RH08     683.7      54.8       0.4       2.8       2.5       2.1         MU
;;     2005-12-30/23:45:15.500   2005-12-30/23:45:30.500    RH08     619.0      71.7       0.5       1.5       1.6       1.2         NN
;;     2006-08-19/09:38:40.500   2006-08-19/09:38:55.500    RH08     373.3      46.9       0.4       1.5       1.2       1.0         YS
;;     2006-11-03/09:37:12.500   2006-11-03/09:37:20.500    RH08     397.5      87.8       0.4       1.5       2.0       1.6         NN
;;     2007-07-20/03:27:10.500   2007-07-20/03:27:23.500    RH08     357.2      66.3       0.6       1.7       2.0       1.4         NU
;;     2007-08-22/04:33:55.500   2007-08-22/04:34:10.500    RH08     356.9      62.0       0.6       1.5       2.1       1.5         YU
;;     2007-12-17/01:53:12.500   2007-12-17/01:53:23.500    RH08     289.3      53.8       0.6       2.3       2.3       1.7         YP
;;     2008-05-28/01:17:33.500   2008-05-28/01:17:41.500    RH08     402.4      75.1       0.6       2.2       2.9       2.0         YU
;;     2008-06-24/19:10:36.500   2008-06-24/19:10:44.500    RH08     354.8      49.7       0.4       1.6       2.0       1.7         YP
;;     2009-02-03/19:20:57.500   2009-02-03/19:21:05.500    RH08     407.7      85.2       0.1       1.8       1.7       1.6         YU
;;     2009-06-24/09:52:15.500   2009-06-24/09:52:23.500    RH08     350.4      88.1       0.6       1.7       2.8       2.0         YP
;;     2009-06-27/11:04:12.500   2009-06-27/11:04:20.500    RH08     426.1      87.5       0.3       1.5       1.6       1.3         YU
;;     2009-10-21/23:15:06.500   2009-10-21/23:15:14.500    RH08     307.7      66.0       0.6       2.1       2.4       1.7         YU
;;     2010-04-11/12:20:51.500   2010-04-11/12:20:59.500    RH08     465.2      60.3       0.3       2.0       2.5       2.2         YP
;;     2011-02-04/01:50:45.500   2011-02-04/01:50:59.500    RH10     285.1      73.2       0.3       2.1       2.0       1.6         YS
;;     2011-07-11/08:27:21.500   2011-07-11/08:27:29.500    RH08     601.4      78.4       0.6       1.9       2.8       2.0         YU
;;     2011-09-16/18:54:26.099   2011-09-16/18:58:49.200    RH08     291.1      71.2       0.1       2.4       1.3       1.3         YP
;;     2011-09-25/10:46:27.500   2011-09-25/10:46:35.500    RH08      85.6      83.8       0.3       2.4       1.1       1.1         YU
;;     2012-01-21/04:01:57.500   2012-01-21/04:02:05.500    RH08     326.8      83.2       0.1       1.5       1.8       1.7         YU
;;     2012-01-30/15:43:09.500   2012-01-30/15:43:17.500    RH08     411.1      53.2       0.2       2.9       2.8       2.5         YU
;;     2012-03-07/03:28:33.500   2012-03-07/03:28:45.500    RH08     479.0      82.4       0.2       1.9       2.1       1.9         NN
;;     2012-04-19/17:13:27.500   2012-04-19/17:13:35.500    RH08     410.1      84.2       0.6       1.4       2.5       1.7         MU
;;     2012-06-16/19:34:33.500   2012-06-16/19:34:41.500    RH08     486.9      70.2       0.5       1.7       2.4       1.8         YU
;;     2012-10-08/04:12:09.500   2012-10-08/04:12:17.500    RH08     465.4      74.4       0.2       1.9       2.3       2.0         YU
;;     2012-11-12/22:12:36.500   2012-11-12/22:12:44.500    RH08     377.1      65.4       0.3       2.0       2.5       2.1         YU
;;     2012-11-26/04:32:45.500   2012-11-26/04:32:53.500    RH08     586.4      71.0       0.4       2.1       2.2       1.8         YP
;;     2012-12-14/19:06:09.500   2012-12-14/19:06:17.500    RH08     384.3      61.6       0.3       1.5       2.1       1.8         NN
;;     2013-01-17/00:23:39.500   2013-01-17/00:23:47.500    RH08     424.9      78.7       0.7       1.4       1.8       1.3         MU
;;     2013-02-13/00:47:40.500   2013-02-13/00:47:50.500    RH08     447.8      75.7       0.5       1.7       2.6       2.0         YP
;;     2013-04-30/08:52:42.500   2013-04-30/08:52:50.500    RH08     461.4      64.9       0.3       1.5       2.2       1.8         YU
;;     2013-06-10/02:51:57.500   2013-06-10/02:52:05.500    RH08     387.7      72.6       0.6       1.9       1.6       1.2         YP
;;     2013-07-12/16:43:21.500   2013-07-12/16:43:29.500    RH08     499.3      56.8       0.4       2.0       2.3       1.9         YP
;;     2013-09-02/01:56:40.500   2013-09-02/01:56:56.500    RH08     524.7      60.1       0.5       1.6       2.2       1.7         YG
;;     2013-10-26/21:25:57.500   2013-10-26/21:26:05.500    RH08     336.5      46.9       0.1       1.6       1.6       1.5         YS
;;     2014-02-13/08:55:24.500   2014-02-13/08:55:32.500    RH08     465.6      68.3       0.0       1.6       1.7       1.7         YU
;;     2014-02-15/12:46:30.500   2014-02-15/12:46:40.500    RH08     499.6      78.3       0.4       2.1       2.7       2.1         YU
;;     2014-02-19/03:09:33.500   2014-02-19/03:09:41.500    RH08     632.4      72.0       0.0       1.6       2.1       2.0         YU
;;     2014-04-19/17:48:15.500   2014-04-19/17:48:30.500    RH08     549.2      50.5       0.1       1.8       1.6       1.5         YP
;;     2014-05-07/21:19:30.500   2014-05-07/21:19:45.500    RH08     386.4      69.4       0.1       1.6       1.2       1.1         YS
;;     2014-05-29/08:26:34.500   2014-05-29/08:26:46.500    RH08     381.7      64.2       0.2       1.8       1.3       1.1         YS
;;     2014-07-14/13:38:06.500   2014-07-14/13:38:14.500    RH08     278.1      70.2       0.3       1.3       1.3       1.1         YU
;;     2015-05-06/00:55:45.500   2015-05-06/00:55:53.500    RH08     527.5      87.5       0.2       2.2       2.6       2.3         YU
;;     2015-06-05/08:29:38.900   2015-06-05/08:32:15.900    RH08     326.9      84.5       0.8       1.4       2.4       1.6         MU
;;     2015-06-24/13:07:05.500   2015-06-24/13:07:20.500    RH08     591.7      85.5       0.1       1.9       2.1       2.0         YS
;;     2015-08-15/07:43:36.500   2015-08-15/07:43:44.500    RH08     477.4      56.8       0.1       2.3       2.4       2.3         YM
;;     2016-03-11/04:26:46.700   2016-03-11/04:31:27.700    RH08     363.1      53.1       0.7       2.2       2.0       1.5         YU
;;     2016-03-14/16:16:27.500   2016-03-14/16:16:35.500    RH08     412.5      61.4       0.8       1.7       2.3       1.5         YU



























































;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Create histograms of all good shocks results
;;----------------------------------------------------------------------------------------
WINDOW,0,XSIZE=1000,YSIZE=600
WINDOW,1,XSIZE=1000,YSIZE=600
WINDOW,2,XSIZE=1000,YSIZE=600

;;  Define indices
ind0           = good_A
ind1           = good_A[good_y_all0]
ind2           = good_A[good_n_all0]

;;  Upstream plasma beta
xran_beta_up   = [0e0,1e0]
bins_beta_up   = 1e-1
binbeta_up     = HISTOGRAM(beta_t_up[ind0],BINSIZE=bins_beta_up[0],MIN=xran_beta_up[0],MAX=xran_beta_up[1],LOCATIONS=lx_beta_up,/NAN)
yran_beta_up   = [0e0,MAX(binbeta_up,/NAN) + 1e0]
xx_beta_up     = lx_beta_up + bins_beta_up[0]/2e0
xdata0         = xx_beta_up
ydata0         = binbeta_up
xran0          = xran_beta_up
yran0          = yran_beta_up

;;  Shock normal angle [degrees]
xran_thbn_up   = [45e0,90e0]
bins_thbn_up   = 5e0
binthbn_up     = HISTOGRAM(thetbn_up[ind0],BINSIZE=bins_thbn_up[0],MIN=xran_thbn_up[0],MAX=xran_thbn_up[1],LOCATIONS=lx_thbn_up,/NAN)
yran_thbn_up   = [0e0,MAX(binthbn_up,/NAN) + 1e0]
xx_thbn_up     = lx_thbn_up + bins_thbn_up[0]/2e0
xdata0         = xx_thbn_up
ydata0         = binthbn_up
xran0          = xran_thbn_up
yran0          = yran_thbn_up

;;  Upstream fast mode Mach number
xran_m_f__up   = [1e0,3e0]
bins_m_f__up   = 25e-2
binm_f__up     = HISTOGRAM(Mfast__up[ind0],BINSIZE=bins_m_f__up[0],MIN=xran_m_f__up[0],MAX=xran_m_f__up[1],LOCATIONS=lx_m_f__up,/NAN)
yran_m_f__up   = [0e0,MAX(binm_f__up,/NAN) + 1e0]
xx_m_f__up     = lx_m_f__up + bins_m_f__up[0]/2e0
xdata0         = xx_m_f__up
ydata0         = binm_f__up
xran0          = xran_m_f__up
yran0          = yran_m_f__up

;;  Upstream Alfvenic Mach number
xran_m_A__up   = [1e0,3e0]
bins_m_A__up   = 25e-2
binm_A__up     = HISTOGRAM(M_VA___up[ind0],BINSIZE=bins_m_A__up[0],MIN=xran_m_A__up[0],MAX=xran_m_A__up[1],LOCATIONS=lx_m_A__up,/NAN)
yran_m_A__up   = [0e0,MAX(binm_A__up,/NAN) + 1e0]
xx_m_A__up     = lx_m_A__up + bins_m_A__up[0]/2e0
xdata0         = xx_m_A__up
ydata0         = binm_A__up
xran0          = xran_m_A__up
yran0          = yran_m_A__up

;;  Shock compression ratio
xran_N2N1_up   = [1e0,3e0]
bins_N2N1_up   = 25e-2
binN2N1_up     = HISTOGRAM(N2_N1__up[ind0],BINSIZE=bins_N2N1_up[0],MIN=xran_N2N1_up[0],MAX=xran_N2N1_up[1],LOCATIONS=lx_N2N1_up,/NAN)
yran_N2N1_up   = [0e0,MAX(binN2N1_up,/NAN) + 1e0]
xx_N2N1_up     = lx_N2N1_up + bins_N2N1_up[0]/2e0
xdata0         = xx_N2N1_up
ydata0         = binN2N1_up
xran0          = xran_N2N1_up
yran0          = yran_N2N1_up

WSET,0
WSHOW,0
PLOT,xdata0,ydata0,PSYM=10,XRANGE=xran0,YRANGE=yran0,/XSTYLE,/YSTYLE

;;----------------------------------------------------------------------------------------
;;  Create histograms of all good shocks with whistlers results
;;----------------------------------------------------------------------------------------

;;  Upstream plasma beta
xran_beta_up   = [0e0,1e0]
bins_beta_up   = 1e-1
binbeta_up     = HISTOGRAM(beta_t_up[ind1],BINSIZE=bins_beta_up[0],MIN=xran_beta_up[0],MAX=xran_beta_up[1],LOCATIONS=lx_beta_up,/NAN)
yran_beta_up   = [0e0,MAX(binbeta_up,/NAN) + 1e0]
xx_beta_up     = lx_beta_up + bins_beta_up[0]/2e0
xdata1         = xx_beta_up
ydata1         = binbeta_up
xran1          = xran_beta_up
yran1          = yran_beta_up

;;  Shock normal angle [degrees]
xran_thbn_up   = [45e0,90e0]
bins_thbn_up   = 5e0
binthbn_up     = HISTOGRAM(thetbn_up[ind1],BINSIZE=bins_thbn_up[0],MIN=xran_thbn_up[0],MAX=xran_thbn_up[1],LOCATIONS=lx_thbn_up,/NAN)
yran_thbn_up   = [0e0,MAX(binthbn_up,/NAN) + 1e0]
xx_thbn_up     = lx_thbn_up + bins_thbn_up[0]/2e0
xdata1         = xx_thbn_up
ydata1         = binthbn_up
xran1          = xran_thbn_up
yran1          = yran_thbn_up

;;  Upstream fast mode Mach number
xran_m_f__up   = [1e0,3e0]
bins_m_f__up   = 25e-2
binm_f__up     = HISTOGRAM(Mfast__up[ind1],BINSIZE=bins_m_f__up[0],MIN=xran_m_f__up[0],MAX=xran_m_f__up[1],LOCATIONS=lx_m_f__up,/NAN)
yran_m_f__up   = [0e0,MAX(binm_f__up,/NAN) + 1e0]
xx_m_f__up     = lx_m_f__up + bins_m_f__up[0]/2e0
xdata1         = xx_m_f__up
ydata1         = binm_f__up
xran1          = xran_m_f__up
yran1          = yran_m_f__up

;;  Upstream Alfvenic Mach number
xran_m_A__up   = [1e0,3e0]
bins_m_A__up   = 25e-2
binm_A__up     = HISTOGRAM(M_VA___up[ind1],BINSIZE=bins_m_A__up[0],MIN=xran_m_A__up[0],MAX=xran_m_A__up[1],LOCATIONS=lx_m_A__up,/NAN)
yran_m_A__up   = [0e0,MAX(binm_A__up,/NAN) + 1e0]
xx_m_A__up     = lx_m_A__up + bins_m_A__up[0]/2e0
xdata1         = xx_m_A__up
ydata1         = binm_A__up
xran1          = xran_m_A__up
yran1          = yran_m_A__up

;;  Shock compression ratio
xran_N2N1_up   = [1e0,3e0]
bins_N2N1_up   = 25e-2
binN2N1_up     = HISTOGRAM(N2_N1__up[ind1],BINSIZE=bins_N2N1_up[0],MIN=xran_N2N1_up[0],MAX=xran_N2N1_up[1],LOCATIONS=lx_N2N1_up,/NAN)
yran_N2N1_up   = [0e0,MAX(binN2N1_up,/NAN) + 1e0]
xx_N2N1_up     = lx_N2N1_up + bins_N2N1_up[0]/2e0
xdata1         = xx_N2N1_up
ydata1         = binN2N1_up
xran1          = xran_N2N1_up
yran1          = yran_N2N1_up

WSET,1
WSHOW,1
PLOT,xdata1,ydata1,PSYM=10,XRANGE=xran1,YRANGE=yran1,/XSTYLE,/YSTYLE

;;----------------------------------------------------------------------------------------
;;  Create histograms of all good shocks without whistlers results
;;----------------------------------------------------------------------------------------

;;  Upstream plasma beta
xran_beta_up   = [0e0,1e0]
bins_beta_up   = 1e-1
binbeta_up     = HISTOGRAM(beta_t_up[ind2],BINSIZE=bins_beta_up[0],MIN=xran_beta_up[0],MAX=xran_beta_up[1],LOCATIONS=lx_beta_up,/NAN)
yran_beta_up   = [0e0,MAX(binbeta_up,/NAN) + 1e0]
xx_beta_up     = lx_beta_up + bins_beta_up[0]/2e0
xdata2         = xx_beta_up
ydata2         = binbeta_up
xran2          = xran_beta_up
yran2          = yran_beta_up

;;  Shock normal angle [degrees]
xran_thbn_up   = [45e0,90e0]
bins_thbn_up   = 5e0
binthbn_up     = HISTOGRAM(thetbn_up[ind2],BINSIZE=bins_thbn_up[0],MIN=xran_thbn_up[0],MAX=xran_thbn_up[1],LOCATIONS=lx_thbn_up,/NAN)
yran_thbn_up   = [0e0,MAX(binthbn_up,/NAN) + 1e0]
xx_thbn_up     = lx_thbn_up + bins_thbn_up[0]/2e0
xdata2         = xx_thbn_up
ydata2         = binthbn_up
xran2          = xran_thbn_up
yran2          = yran_thbn_up

;;  Upstream fast mode Mach number
xran_m_f__up   = [1e0,3e0]
bins_m_f__up   = 25e-2
binm_f__up     = HISTOGRAM(Mfast__up[ind2],BINSIZE=bins_m_f__up[0],MIN=xran_m_f__up[0],MAX=xran_m_f__up[1],LOCATIONS=lx_m_f__up,/NAN)
yran_m_f__up   = [0e0,MAX(binm_f__up,/NAN) + 1e0]
xx_m_f__up     = lx_m_f__up + bins_m_f__up[0]/2e0
xdata2         = xx_m_f__up
ydata2         = binm_f__up
xran2          = xran_m_f__up
yran2          = yran_m_f__up

;;  Upstream Alfvenic Mach number
xran_m_A__up   = [1e0,3e0]
bins_m_A__up   = 25e-2
binm_A__up     = HISTOGRAM(M_VA___up[ind2],BINSIZE=bins_m_A__up[0],MIN=xran_m_A__up[0],MAX=xran_m_A__up[1],LOCATIONS=lx_m_A__up,/NAN)
yran_m_A__up   = [0e0,MAX(binm_A__up,/NAN) + 1e0]
xx_m_A__up     = lx_m_A__up + bins_m_A__up[0]/2e0
xdata2         = xx_m_A__up
ydata2         = binm_A__up
xran2          = xran_m_A__up
yran2          = yran_m_A__up

;;  Shock compression ratio
xran_N2N1_up   = [1e0,3e0]
bins_N2N1_up   = 25e-2
binN2N1_up     = HISTOGRAM(N2_N1__up[ind2],BINSIZE=bins_N2N1_up[0],MIN=xran_N2N1_up[0],MAX=xran_N2N1_up[1],LOCATIONS=lx_N2N1_up,/NAN)
yran_N2N1_up   = [0e0,MAX(binN2N1_up,/NAN) + 1e0]
xx_N2N1_up     = lx_N2N1_up + bins_N2N1_up[0]/2e0
xdata2         = xx_N2N1_up
ydata2         = binN2N1_up
xran2          = xran_N2N1_up
yran2          = yran_N2N1_up

WSET,2
WSHOW,2
PLOT,xdata2,ydata2,PSYM=10,XRANGE=xran2,YRANGE=yran2,/XSTYLE,/YSTYLE
