;;  print_ip_shocks_ramp_whistler_times_crib.pro

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
vec_str        = ['x','y','z']
vec_col        = [250,150,50]
;;----------------------------------------------------------------------------------------
;;  Initialize and setup
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_ip_shocks_whistler_stats_batch.pro
;;  Convert zoom times to Unix
start_unix     = time_double(start_times)
end___unix     = time_double(end___times)
midt__unix     = (start_unix + end___unix)/2d0
;;----------------------------------------------------------------------------------------
;;  Define time ranges to load into TPLOT
;;----------------------------------------------------------------------------------------
delt           = [-1,1]*1d0*36d2        ;;  load ±1 hour about ramp
all_stunix     = midt__unix + delt[0]
all_enunix     = midt__unix + delt[1]
all__trans     = [[all_stunix],[all_enunix]]
;;  Look at only events with definite whistlers
good           = good_y_all0
gd             = gd_y_all[0]

;;----------------------------------------------------------------------------------------
;;  Load MFI into TPLOT, filter, and plot
;;----------------------------------------------------------------------------------------
jj             = 112L
@/Users/lbwilson/Desktop/low_beta_Ma_whistlers/crib_sheets/print_ip_shocks_ramp_whistler_times_batch.pro
;;----------------------------------------------------------------------------------------
;;  Initialize and setup
;;----------------------------------------------------------------------------------------
;;  Zoom in
tlimit

;;  Determine shock ramp and whistler precursor times
DELVAR,data_out
t_get_values_from_plot,tpnm_str[0],NDATA=2,DATA_OUT=data_out
PRINT,';;  Precursor Times:  ',time_string(t_get_struc_unix(data_out),PREC=3)

;;  Precursor Times:   1995-04-17/23:32:57.740 1995-04-17/23:33:07.610
;;  Precursor Times:   1995-07-22/05:34:15.740 1995-07-22/05:35:45.049
;;  Precursor Times:   1995-08-22/12:56:39.240 1995-08-22/12:56:48.970     [nice example (has gaps)]
;;  Precursor Times:   1995-08-24/22:10:53.360 1995-08-24/22:11:04.379
;;  Precursor Times:   1995-10-22/21:20:09.761 1995-10-22/21:20:15.694
;;  Precursor Times:   1995-12-24/05:57:33.368 1995-12-24/05:57:35.006     [extended upstream ULF waves]
;;  Precursor Times:   1996-02-06/19:14:13.830 1996-02-06/19:14:25.350     [extended upstream ULF waves]
;;  Precursor Times:   1996-04-03/09:46:57.259 1996-04-03/09:47:17.037
;;  Precursor Times:   1996-04-08/02:41:03.620 1996-04-08/02:41:09.639
;;  Precursor Times:   1997-03-15/22:29:44.490 1997-03-15/22:30:32.279
;;  Precursor Times:   1997-04-10/12:57:53.649 1997-04-10/12:58:34.480
;;  Precursor Times:   1997-10-24/11:17:03.750 1997-10-24/11:18:09.830     [extended upstream ULF waves]
;;  Precursor Times:   1997-11-01/06:14:27.659 1997-11-01/06:14:45.110
;;  Precursor Times:   1997-12-10/04:33:03.539 1997-12-10/04:33:14.666     [extended upstream ULF waves]
;;  Precursor Times:   1997-12-30/01:13:20.450 1997-12-30/01:13:43.639
;;  Precursor Times:   1998-01-06/13:28:11.509 1998-01-06/13:29:00.182
;;  Precursor Times:   1998-02-18/07:46:50.370 1998-02-18/07:48:43.870     [textbook example of extended precursor; ** wavelet example **]
;;  Precursor Times:   1998-05-29/15:11:58.159 1998-05-29/15:12:04.299     [gap at end of ramp]
;;  Precursor Times:   1998-08-06/07:14:35.190 1998-08-06/07:16:07.495
;;  Precursor Times:   1998-08-19/18:40:34.169 1998-08-19/18:40:41.519     [extended upstream ULF waves]
;;  Precursor Times:   1998-11-08/04:40:53.240 1998-11-08/04:41:17.230     [extended upstream ULF waves]
;;  Precursor Times:   1998-12-28/18:19:57.519 1998-12-28/18:20:16.065     [extended upstream ULF waves]
;;  Precursor Times:   1999-01-13/10:47:36.970 1999-01-13/10:47:44.669     [extended upstream ULF waves]
;;  Precursor Times:   1999-02-17/07:11:31.720 1999-02-17/07:12:13.843
;;  Precursor Times:   1999-04-16/11:13:23.500 1999-04-16/11:14:12.000     [extended upstream ULF waves]
;;  Precursor Times:   1999-06-26/19:30:24.860 1999-06-26/19:30:55.759     [extended upstream ULF waves; gap throughout ramp]
;;  Precursor Times:   1999-08-04/01:44:01.429 1999-08-04/01:44:38.368     [extended upstream ULF waves]
;;  Precursor Times:   1999-08-23/12:09:18.200 1999-08-23/12:11:14.590     [nice example of large amplitude linear precursor; ** wavelet example **]
;;  Precursor Times:   1999-09-22/12:09:24.743 1999-09-22/12:09:25.473     [one spike]
;;  Precursor Times:   1999-10-21/02:19:01.000 1999-10-21/02:20:51.235     [extended upstream ULF waves; includes almost purely transverse waves; two types of precursors (low and high freq.); gap throughout ramp]
;;  Precursor Times:   1999-11-05/20:01:36.899 1999-11-05/20:03:09.659     [textbook example of linear-to-nonlinear precursors; ** wavelet example **]
;;  Precursor Times:   1999-11-13/12:47:31.509 1999-11-13/12:48:57.250
;;  Precursor Times:   2000-02-05/15:25:06.629 2000-02-05/15:26:29.031     [textbook example of linear precursors before sharp ramp; ** wavelet example **]
;;  Precursor Times:   2000-02-14/07:12:32.429 2000-02-14/07:12:59.740     [extended upstream ULF waves; nice linear-to-nonlinear precursors]
;;  Precursor Times:   2000-06-23/12:57:16.379 2000-06-23/12:57:59.327     [extended upstream ULF waves]
;;  Precursor Times:   2000-07-13/09:43:38.389 2000-07-13/09:43:51.580     [extended upstream ULF waves]
;;  Precursor Times:   2000-07-26/18:59:52.940 2000-07-26/19:00:14.860
;;  Precursor Times:   2000-07-28/06:38:15.860 2000-07-28/06:38:45.817     [extended upstream ULF waves; several gaps in and downstream of ramp]
;;  Precursor Times:   2000-08-10/05:12:21.080 2000-08-10/05:13:21.370     [extended upstream ULF waves]
;;  Precursor Times:   2000-08-11/18:49:30.659 2000-08-11/18:49:34.379     [omnipresent upstream waves; several gaps in and downstream of ramp]
;;  Precursor Times:   2000-10-28/09:30:28.309 2000-10-28/09:30:41.879     [extended upstream ULF waves]
;;  Precursor Times:   2000-10-31/17:08:33.149 2000-10-31/17:09:59.284     [several gaps in and downstream of ramp]
;;  Precursor Times:   2000-11-06/09:29:09.789 2000-11-06/09:30:20.669     [extended upstream ULF waves]
;;  Precursor Times:   2000-11-26/11:43:20.870 2000-11-26/11:43:26.710     [extended upstream ULF waves; shocklets upstream; several gaps in and downstream of ramp]
;;  Precursor Times:   2000-11-28/05:25:33.700 2000-11-28/05:27:41.985     [extended upstream ULF waves; shocklets upstream]
;;  Precursor Times:   2001-01-17/04:07:10.799 2001-01-17/04:07:53.059     [extended upstream ULF waves]
;;  Precursor Times:   2001-03-03/11:28:22.080 2001-03-03/11:29:20.899     [extended upstream ULF waves; nice linear-to-nonlinear precursors; ** wavelet example **]
;;  Precursor Times:   2001-03-22/13:58:30.230 2001-03-22/13:59:06.240     [several gaps in and downstream of ramp]
;;  Precursor Times:   2001-03-27/18:07:15.600 2001-03-27/18:07:48.210     [extended upstream ULF waves; precursor separated from ramp]
;;  Precursor Times:   2001-04-21/15:29:02.879 2001-04-21/15:29:14.123     [extended upstream ULF waves]
;;  Precursor Times:   2001-05-06/09:05:27.789 2001-05-06/09:06:08.332     [intermittent upstream ULF waves]
;;  Precursor Times:   2001-05-12/10:01:41.690 2001-05-12/10:03:14.317     [intermittent upstream ULF waves]
;;  Precursor Times:   2001-09-13/02:30:10.129 2001-09-13/02:31:26.029     [extended upstream ULF waves]
;;  Precursor Times:   2001-10-28/03:13:23.950 2001-10-28/03:13:48.500     [extended upstream ULF waves; shocklets upstream]
;;  Precursor Times:   2001-11-30/18:15:10.889 2001-11-30/18:15:45.440     [extended upstream ULF waves]
;;  Precursor Times:   2001-12-21/14:09:42.850 2001-12-21/14:10:17.090     [extended upstream ULF waves]
;;  Precursor Times:   2001-12-30/20:04:29.870 2001-12-30/20:05:05.830     [intermittent upstream ULF waves; several gaps in and downstream of ramp; precursor extends through ramp]
;;  Precursor Times:   2002-01-17/05:26:51.590 2002-01-17/05:26:56.879     [extended upstream ULF waves]
;;  Precursor Times:   2002-01-31/21:37:31.419 2002-01-31/21:38:10.404     [few intermittent upstream ULF waves]
;;  Precursor Times:   2002-03-23/11:23:24.620 2002-03-23/11:24:09.210     [intermittent upstream ULF waves; at least two magnetic holes]
;;  Precursor Times:   2002-03-29/22:15:09.809 2002-03-29/22:15:13.250     [intermittent upstream ULF waves; shocklets and soliton-like pulses upstream]
;;  Precursor Times:   2002-05-21/21:13:11.610 2002-05-21/21:14:15.840     [few intermittent upstream ULF waves; nice linear-to-nonlinear precursors]
;;  Precursor Times:   2002-06-29/21:09:57.429 2002-06-29/21:10:26.399     [extended upstream ULF waves; precursor ends as soliton-like pulse in middle of ramp]
;;  Precursor Times:   2002-08-01/23:08:31.379 2002-08-01/23:09:07.282     [relatively quiet upstream with few intermittent typical solar wind structures/fluctuations]
;;  Precursor Times:   2002-09-30/07:53:38.919 2002-09-30/07:54:24.149     [data gap in ramp]
;;  Precursor Times:   2002-11-09/18:27:30.419 2002-11-09/18:27:49.240     [intermittent medium duration upstream ULF waves]
;;  Precursor Times:   2003-05-29/18:30:49.730 2003-05-29/18:31:07.827     [extended upstream ULF waves; precursors superposed on upstream waves]
;;  Precursor Times:   2003-06-18/04:40:53.679 2003-06-18/04:42:06.159     [intermittent upstream ULF waves; all nonlinear precursor]
;;  Precursor Times:   2004-04-12/18:28:23.210 2004-04-12/18:29:46.279     [intermittent upstream ULF waves; a few magnetic holes upstream; a few shocklets far upstream; very coherent ULF waves immediately upstream]
;;  Precursor Times:   2005-05-06/12:03:02.500 2005-05-06/12:08:38.930     [relatively quiet upstream; intermittent bursts of >0.4 nT "1 Hz waves" upstream]
;;  Precursor Times:   2005-05-07/18:26:09.069 2005-05-07/18:26:16.081     [intermittent upstream ULF waves; extended build-up of IMF magnitude prior to shock; might contain shocklets (unclear)]
;;  Precursor Times:   2005-06-16/08:07:07.720 2005-06-16/08:09:10.069     [relatively quiet upstream; data gap in ramp and downstream]
;;  Precursor Times:   2005-07-10/02:41:17.430 2005-07-10/02:42:30.726     [intermittent upstream ULF waves; shocklets upstream of ramp]
;;  Precursor Times:   2005-08-24/05:34:39.140 2005-08-24/05:35:24.414     [intermittent upstream ULF waves; IMF magnitude gradually decreases toward shock; data gap in ramp and downstream]
;;  Precursor Times:   2005-09-02/13:48:38.779 2005-09-02/13:50:16.069     [intermittent upstream ULF waves]
;;  Precursor Times:   2006-08-19/09:33:17.500 2006-08-19/09:38:48.400     [intermittent upstream ULF waves (some are bursts of coherent waves); extended build-up of IMF magnitude prior to shock; very nice extended precursor; ** wavelet example **]
;;  Precursor Times:   2007-08-22/04:31:24.700 2007-08-22/04:34:03.000     [intermittent upstream ULF waves; upstream IMF is very weak (~2 nT); might contain shocklets (unclear); precursors seen as intermittent, bursty wave packets]
;;  Precursor Times:   2007-12-17/01:52:53.579 2007-12-17/01:53:18.549     [intermittent upstream ULF waves; upstream IMF is weak (< 4 nT); a few magnetic holes upstream; intermittent bursts of >0.4 nT "1 Hz waves" upstream]
;;  Precursor Times:   2008-05-28/01:14:59.750 2008-05-28/01:17:38.161     [intermittent upstream ULF waves]
;;  Precursor Times:   2008-06-24/18:52:21.700 2008-06-24/19:10:41.963     [intermittent upstream ULF waves; upstream IMF is weak (< 4 nT); long duration (>20 minutes) >0.4 nT "1 Hz waves" upstream connected to precursors; precursors are nonlinear in ramp; ** wavelet example **]
;;  Precursor Times:   2009-02-03/19:21:01.865 2009-02-03/19:21:03.157     [intermittent upstream ULF waves; several data gaps up- and downstream of ramp; only ~3 cycle precursor]
;;  Precursor Times:   2009-06-24/09:52:07.650 2009-06-24/09:52:20.400     [long duration (~20 min) Bo pulse followed by depression then gradual rise to shock; might contain shocklets (unclear)]
;;  Precursor Times:   2009-06-27/11:03:13.559 2009-06-27/11:04:18.898     [intermittent upstream ULF waves; upstream IMF is weak (< 4 nT)]
;;  Precursor Times:   2009-10-21/23:13:55.190 2009-10-21/23:15:09.880     [intermittent upstream ULF waves; upstream IMF is weak (< 4 nT); might contain shocklets (unclear)]
;;  Precursor Times:   2010-04-11/12:19:16.900 2010-04-11/12:20:56.220     [intermittent upstream ULF waves; extended coherent ULF waves upstream too; linear-to-nonlinear precursor; several data gaps up- and downstream of ramp]
;;  Precursor Times:   2011-02-04/01:50:37.319 2011-02-04/01:50:55.670     [intermittent upstream ULF waves; upstream IMF is very weak (< 3 nT); large data gap upstream of ramp; ** wavelet example **]
;;  Precursor Times:   2011-07-11/08:26:30.220 2011-07-11/08:27:25.471     [extended upstream ULF waves]
;;  Precursor Times:   2011-09-16/18:54:08.200 2011-09-16/18:57:15.299     [intermittent upstream ULF waves; upstream IMF is weak (< 4 nT); several data gaps upstream of ramp; nice >0.5 nT "1 Hz waves" upstream connected to precursors]
;;  Precursor Times:   2011-09-25/10:43:56.410 2011-09-25/10:46:32.085     [intermittent upstream ULF waves]
;;  Precursor Times:   2012-01-21/04:00:32.019 2012-01-21/04:02:01.809     [intermittent upstream ULF waves; possible magnetic hole upstream; very nice precursor; ** wavelet example **]
;;  Precursor Times:   2012-01-30/15:43:03.640 2012-01-30/15:43:13.309     [intermittent upstream ULF waves; upstream IMF is weak (< 4 nT); large data gap up- and downstream of ramp; might contain shocklets (unclear)]
;;  Precursor Times:   2012-06-16/19:34:25.569 2012-06-16/19:34:39.369     [extended upstream ULF waves; weird, extended foot]
;;  Precursor Times:   2012-10-08/04:11:45.970 2012-10-08/04:12:14.022     [extended upstream ULF waves; large-then-small amplitude precursors (odd)]
;;  Precursor Times:   2012-11-12/22:12:34.461 2012-11-12/22:12:41.579     [intermittent upstream ULF waves; data gap in ramp]
;;  Precursor Times:   2012-11-26/04:32:36.150 2012-11-26/04:32:50.960     [extended upstream ULF waves; weird, extended foot; several data gaps downstream of ramp]
;;  Precursor Times:   2013-02-13/00:46:46.049 2013-02-13/00:47:45.742     [intermittent upstream ULF waves; upstream IMF is weak (< 4 nT); possible magnetic holes upstream]
;;  Precursor Times:   2013-04-30/08:52:30.789 2013-04-30/08:52:46.417     [intermittent upstream ULF waves; several data gaps up- and downstream of ramp]
;;  Precursor Times:   2013-06-10/02:51:45.099 2013-06-10/02:52:01.335     [intermittent upstream ULF waves; several data gaps up- and downstream of ramp; upstream IMF is weak (≤ 4 nT); possible magnetic holes upstream]
;;  Precursor Times:   2013-07-12/16:42:29.809 2013-07-12/16:43:28.516     [extended upstream ULF waves; large data gap upstream of ramp; ** wavelet example **]
;;  Precursor Times:   2013-09-02/01:55:13.480 2013-09-02/01:56:49.119     [several data gaps upstream of ramp]
;;  Precursor Times:   2013-10-26/21:18:46.200 2013-10-26/21:26:02.099     [relatively quiet upstream; upstream IMF is weak (~ 4 nT); nice large amplitude precursor; ** wavelet example **]
;;  Precursor Times:   2014-02-13/08:53:39.980 2014-02-13/08:55:28.934     [large data gap downstream of ramp]
;;  Precursor Times:   2014-02-15/12:46:04.039 2014-02-15/12:46:36.901     [intermittent upstream ULF waves]
;;  Precursor Times:   2014-02-19/03:09:14.809 2014-02-19/03:09:38.861     [relatively quiet upstream; several data gaps upstream of ramp]
;;  Precursor Times:   2014-04-19/17:46:30.859 2014-04-19/17:48:25.604     [intermittent upstream ULF waves; long duration monochromatic ULF wave immediately upstream; ** wavelet example **]
;;  Precursor Times:   2014-05-07/21:17:03.170 2014-05-07/21:19:38.779     [large data gap up- and downstream of ramp; weird, extended foot; ** wavelet example **]
;;  Precursor Times:   2014-05-29/08:25:13.950 2014-05-29/08:26:40.940     [intermittent upstream ULF waves; large data gap upstream of ramp; very nice nonlinear precursor; ** wavelet example **]
;;  Precursor Times:   2014-07-14/13:37:34.940 2014-07-14/13:38:08.971     [intermittent upstream ULF waves; large data gap downstream of ramp]
;;  Precursor Times:   2015-05-06/00:55:30.509 2015-05-06/00:55:49.854     [large data gap up- and downstream of ramp; long duration coherent disconnected ULF waves; somewhat extended foot]
;;  Precursor Times:   2015-06-24/13:06:37.990 2015-06-24/13:07:14.601     [extended upstream waves; large data gap upstream of ramp; might contain shocklets (unclear); several min. extended foot]
;;  Precursor Times:   2015-08-15/07:43:17.430 2015-08-15/07:43:40.250     [extended upstream waves; several data gaps up- and downstream of ramp; data gap in ramp; precursors superposed on ULF waves]
;;  Precursor Times:   2016-03-11/04:24:15.900 2016-03-11/04:29:29.400     [extended upstream waves; very nice/coherent ULF waves]
;;  Precursor Times:   2016-03-14/16:16:06.680 2016-03-14/16:16:31.880     [intermittent upstream ULF waves; several data gaps upstream of ramp; might contain shocklets (unclear); somewhat extended foot]




DELVAR,data_out
t_get_values_from_plot,tpnm_str[0],NDATA=2,DATA_OUT=data_out
PRINT,';;       Ramp Times:  ',time_string(t_get_struc_unix(data_out),PREC=3)

;;       Ramp Times:   1995-04-17/23:33:07.616 1995-04-17/23:33:07.894
;;       Ramp Times:   1995-07-22/05:35:45.049 1995-07-22/05:35:45.659
;;       Ramp Times:   1995-08-22/12:56:48.981 1995-08-22/12:56:49.445
;;       Ramp Times:   1995-08-24/22:11:04.371 1995-08-24/22:11:04.682     [nice extended downstream waves]
;;       Ramp Times:   1995-10-22/21:20:15.694 1995-10-22/21:20:16.200     [very nice extended downstream waves]
;;       Ramp Times:   1995-12-24/05:57:35.024 1995-12-24/05:57:36.159
;;       Ramp Times:   1996-02-06/19:14:23.373 1996-02-06/19:14:24.924     [precursor spans ramp]
;;       Ramp Times:   1996-04-03/09:47:17.037 1996-04-03/09:47:17.266
;;       Ramp Times:   1996-04-08/02:41:09.652 1996-04-08/02:41:09.879     [extended downstream waves]
;;       Ramp Times:   1997-03-15/22:30:32.434 1997-03-15/22:30:33.715     [nice short duration downstream waves]
;;       Ramp Times:   1997-04-10/12:58:34.437 1997-04-10/12:58:34.998     [extended downstream waves]
;;       Ramp Times:   1997-10-24/11:18:09.830 1997-10-24/11:18:10.152     [nice short duration downstream waves]
;;       Ramp Times:   1997-11-01/06:14:45.108 1997-11-01/06:14:46.213
;;       Ramp Times:   1997-12-10/04:33:14.666 1997-12-10/04:33:14.947     [extended downstream waves]
;;       Ramp Times:   1997-12-30/01:13:43.644 1997-12-30/01:13:44.199     [nice short duration downstream waves]
;;       Ramp Times:   1998-01-06/13:29:00.182 1998-01-06/13:29:00.554
;;       Ramp Times:   1998-02-18/07:48:43.870 1998-02-18/07:48:45.169
;;       Ramp Times:   1998-05-29/15:12:04.299 1998-05-29/15:12:04.748     [lots of IMF discontinuities up- and downstream]
;;       Ramp Times:   1998-08-06/07:16:07.495 1998-08-06/07:16:07.684
;;       Ramp Times:   1998-08-19/18:40:41.498 1998-08-19/18:40:41.891
;;       Ramp Times:   1998-11-08/04:41:17.194 1998-11-08/04:41:17.636     [extended downstream waves]
;;       Ramp Times:   1998-12-28/18:20:16.065 1998-12-28/18:20:16.358     [lots of IMF discontinuities up- and downstream]
;;       Ramp Times:   1999-01-13/10:47:44.669 1999-01-13/10:47:45.570     [extended downstream waves]
;;       Ramp Times:   1999-02-17/07:12:13.843 1999-02-17/07:12:14.128
;;       Ramp Times:   1999-04-16/11:14:06.179 1999-04-16/11:14:16.000     [precursor spans ramp]
;;       Ramp Times:   1999-06-26/19:30:55.769 1999-06-26/19:31:00.539     [extended downstream waves]
;;       Ramp Times:   1999-08-04/01:44:38.368 1999-08-04/01:44:38.835     [extended downstream waves]
;;       Ramp Times:   1999-08-23/12:11:14.590 1999-08-23/12:11:14.950
;;       Ramp Times:   1999-09-22/12:09:25.473 1999-09-22/12:09:25.661     [lots of IMF discontinuities up- and downstream]
;;       Ramp Times:   1999-10-21/02:20:51.235 1999-10-21/02:20:52.702     [extended downstream waves]
;;       Ramp Times:   1999-11-05/20:03:09.659 1999-11-05/20:03:10.539
;;       Ramp Times:   1999-11-13/12:48:57.141 1999-11-13/12:48:57.593     [sharp ramp with preceeding dip]
;;       Ramp Times:   2000-02-05/15:26:29.031 2000-02-05/15:26:29.396     [sharp ramp with preceeding dip; short duration downstream waves]
;;       Ramp Times:   2000-02-14/07:12:59.740 2000-02-14/07:13:00.210     [extended downstream waves]
;;       Ramp Times:   2000-06-23/12:57:59.327 2000-06-23/12:58:01.001     [strong Bo pulse then depression then rise to downstream ; lots of IMF discontinuities downstream]
;;       Ramp Times:   2000-07-13/09:43:51.639 2000-07-13/09:43:52.399     [precursor spans strong Bo pulse preceeding depression and ramp]
;;       Ramp Times:   2000-07-26/19:00:14.894 2000-07-26/19:00:15.203     [nice short duration downstream waves]
;;       Ramp Times:   2000-07-28/06:38:45.817 2000-07-28/06:38:46.557     [nice short duration downstream waves]
;;       Ramp Times:   2000-08-10/05:13:19.425 2000-08-10/05:13:23.998     [precursor spans ramp]
;;       Ramp Times:   2000-08-11/18:49:34.379 2000-08-11/18:49:34.990     [omnipresent downstream waves]
;;       Ramp Times:   2000-10-28/09:30:40.360 2000-10-28/09:30:42.590     [precursor spans ramp; extended downstream waves]
;;       Ramp Times:   2000-10-31/17:09:59.284 2000-10-31/17:09:59.468     [lots of IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2000-11-06/09:29:54.429 2000-11-06/09:30:36.710     [precursor spans ramp; extended downstream waves]
;;       Ramp Times:   2000-11-26/11:43:26.710 2000-11-26/11:43:36.000     [lots of IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2000-11-28/05:27:41.985 2000-11-28/05:27:42.483     [dip immediately preceeding ramp; CfA shock near 05:25 UT but stronger Bo pulse/change near 05:27:30 UT; lots of IMF discontinuities up- and downstream]
;;       Ramp Times:   2001-01-17/04:07:53.059 2001-01-17/04:07:53.450     [extended downstream waves]
;;       Ramp Times:   2001-03-03/11:29:15.620 2001-03-03/11:29:23.200     [precursor spans ramp; extended downstream waves]
;;       Ramp Times:   2001-03-22/13:59:06.203 2001-03-22/13:59:06.858     [dip immediately preceeding ramp; nice short duration downstream waves]
;;       Ramp Times:   2001-03-27/18:07:48.728 2001-03-27/18:07:49.003     [lots of IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2001-04-21/15:29:14.123 2001-04-21/15:29:15.047     [lots of IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2001-05-06/09:06:08.332 2001-05-06/09:06:09.200     [lots of IMF discontinuities up- and downstream; nice short duration downstream waves]
;;       Ramp Times:   2001-05-12/10:03:14.317 2001-05-12/10:03:14.764     [dip immediately preceeding ramp; lots of IMF discontinuities up- and downstream; intermittent downstream waves]
;;       Ramp Times:   2001-09-13/02:31:25.889 2001-09-13/02:31:30.129     [actually looks like two ramps ~3.5 mins apart; lots of IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2001-10-28/03:13:48.500 2001-10-28/03:13:48.860     [extended downstream waves; data gaps downstream]
;;       Ramp Times:   2001-11-30/18:15:44.500 2001-11-30/18:15:46.700     [precursor extends ~1/2 way into ramp; extended downstream waves]
;;       Ramp Times:   2001-12-21/14:10:17.090 2001-12-21/14:10:19.009     [lots of IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2001-12-30/20:05:05.626 2001-12-30/20:05:08.682     [lots of IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2002-01-17/05:26:56.840 2002-01-17/05:26:59.480     [almost appears as if precursor crosses ramp and persists into downstream; extended downstream waves]
;;       Ramp Times:   2002-01-31/21:38:10.404 2002-01-31/21:38:10.968     [dip immediately preceeding ramp; sharp ramp; nice short duration downstream waves]
;;       Ramp Times:   2002-03-23/11:24:08.962 2002-03-23/11:24:09.434     [precursor extends ~1/2 way into ramp; lots of IMF discontinuities up- and downstream; almost appears as if precursor crosses ramp and persists into downstream followed by lower frequency waves; extended downstream waves]
;;       Ramp Times:   2002-03-29/22:15:13.259 2002-03-29/22:15:13.536     [several IMF discontinuities up- and downstream; medium duration and intermittent downstream waves]
;;       Ramp Times:   2002-05-21/21:14:15.799 2002-05-21/21:14:17.000     [almost appears as if precursor crosses ramp and persists into downstream; several IMF discontinuities downstream; extended downstream waves]
;;       Ramp Times:   2002-06-29/21:10:24.330 2002-06-29/21:10:27.820     [several IMF discontinuities up- and downstream; several intermittent downstream waves]
;;       Ramp Times:   2002-08-01/23:09:07.282 2002-08-01/23:09:07.748     [sharp ramp; almost appears as if precursor crosses ramp and persists into downstream; a few IMF discontinuities downstream; several intermittent downstream waves]
;;       Ramp Times:   2002-09-30/07:54:24.105 2002-09-30/07:54:24.835     [almost appears as if precursor crosses ramp and persists into downstream; several IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2002-11-09/18:27:49.253 2002-11-09/18:27:49.526     [a few IMF discontinuities up- and downstream; medium duration and intermittent downstream waves]
;;       Ramp Times:   2003-05-29/18:31:07.827 2003-05-29/18:31:08.197     [several IMF discontinuities downstream; extended downstream waves; several magnetic holes downstream]
;;       Ramp Times:   2003-06-18/04:42:06.159 2003-06-18/04:42:06.633     [several IMF discontinuities downstream; extended downstream waves]
;;       Ramp Times:   2004-04-12/18:29:46.270 2004-04-12/18:29:46.911     [dip immediately preceeding ramp; extended downstream waves; several IMF discontinuities downstream]
;;       Ramp Times:   2005-05-06/12:08:37.720 2005-05-06/12:08:41.960     [precursor extends ~1/2 way into ramp; relatively quiet downstream]
;;       Ramp Times:   2005-05-07/18:26:16.081 2005-05-07/18:26:16.815     [extended foot preceeding ramp; dip immediately preceeding ramp; short duration, coherent ULF wave immediately downstream; a few IMF discontinuities downstream]
;;       Ramp Times:   2005-06-16/08:09:10.069 2005-06-16/08:09:11.089     [dip immediately preceeding ramp; extended downstream waves; several magnetic holes downstream; data gaps downstream]
;;       Ramp Times:   2005-07-10/02:42:30.726 2005-07-10/02:42:31.180     [several IMF discontinuities downstream; extended downstream waves]
;;       Ramp Times:   2005-08-24/05:35:24.414 2005-08-24/05:35:24.890     [a few IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2005-09-02/13:50:16.069 2005-09-02/13:50:16.539     [spike/overshoot in ramp; several IMF discontinuities up- and downstream; a few magnetic holes downstream]
;;       Ramp Times:   2006-08-19/09:38:48.869 2006-08-19/09:38:49.420     [dip immediately preceeding ramp; a few IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2007-08-22/04:34:03.088 2007-08-22/04:34:03.930     [one strong IMF discontinuity downstream; appear to be several mirror mode storms downstream]
;;       Ramp Times:   2007-12-17/01:53:18.555 2007-12-17/01:53:19.115     [several IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2008-05-28/01:17:38.161 2008-05-28/01:17:38.809     [spike/overshoot in ramp; several IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2008-06-24/19:10:41.506 2008-06-24/19:10:42.426     [a few IMF discontinuities up- and downstream; precursor extends ~1/2 way into ramp; intermittent downstream waves]
;;       Ramp Times:   2009-02-03/19:21:03.157 2009-02-03/19:21:03.440     [a few IMF discontinuities up- and downstream; sharp ramp]
;;       Ramp Times:   2009-06-24/09:52:20.019 2009-06-24/09:52:21.125     [precursor extends short way into ramp; a few IMF discontinuities up- and downstream; nice short duration downstream waves; medium duration and intermittent downstream waves]
;;       Ramp Times:   2009-06-27/11:04:18.898 2009-06-27/11:04:19.444     [a few IMF discontinuities up- and downstream; nice short duration downstream waves; intermittent downstream waves]
;;       Ramp Times:   2009-10-21/23:15:09.894 2009-10-21/23:15:10.456     [a few IMF discontinuities up- and downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2010-04-11/12:20:56.220 2010-04-11/12:20:56.720     [spike/overshoot in ramp; a few IMF discontinuities up- and downstream; almost appears as if precursor crosses ramp and persists into downstream]
;;       Ramp Times:   2011-02-04/01:50:55.638 2011-02-04/01:50:56.005     [dip immediately preceeding ramp; a few IMF discontinuities up- and downstream; data gaps downstream of ramp]
;;       Ramp Times:   2011-07-11/08:27:25.204 2011-07-11/08:27:25.855     [precursor extends short way into ramp; several IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2011-09-16/18:56:39.589 2011-09-16/18:57:19.390     [precursor extends well into ramp; extended downstream waves]
;;       Ramp Times:   2011-09-25/10:46:32.085 2011-09-25/10:46:32.365     [several IMF discontinuities up- and downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2012-01-21/04:02:01.809 2012-01-21/04:02:02.187     [dip immediately preceeding ramp; several IMF discontinuities up- and downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2012-01-30/15:43:12.881 2012-01-30/15:43:13.992     [precursor extends short way into ramp; several IMF discontinuities downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2012-06-16/19:34:39.369 2012-06-16/19:34:39.559     [sharp ramp; several IMF discontinuities up- and downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2012-10-08/04:12:14.022 2012-10-08/04:12:14.385     [several IMF discontinuities downstream; extended downstream waves; large data gap downstream of ramp]
;;       Ramp Times:   2012-11-12/22:12:41.579 2012-11-12/22:12:42.134     [precursor extends short way into ramp; several IMF discontinuities downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2012-11-26/04:32:50.960 2012-11-26/04:32:51.529     [dip immediately preceeding ramp followed by a spike; a few IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2013-02-13/00:47:45.742 2013-02-13/00:47:46.200     [several IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2013-04-30/08:52:46.417 2013-04-30/08:52:46.881     [several IMF discontinuities up- and downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2013-06-10/02:52:01.335 2013-06-10/02:52:01.808     [several IMF discontinuities up- and downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2013-07-12/16:43:26.490 2013-07-12/16:43:29.282     [precursor extends well into ramp; several IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2013-09-02/01:56:49.119 2013-09-02/01:56:51.690     [spike/overshoot in ramp; several IMF discontinuities up- and downstream; extended downstream waves; possible magnetic hole downstream]
;;       Ramp Times:   2013-10-26/21:26:02.099 2013-10-26/21:26:02.769     [sharp ramp; one IMF discontinuity downstream; intermittent downstream ULF waves]
;;       Ramp Times:   2014-02-13/08:55:28.934 2014-02-13/08:55:29.486     [dip immediately preceeding ramp; a few IMF discontinuities downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2014-02-15/12:46:36.901 2014-02-15/12:46:37.187     [several IMF discontinuities up- and downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2014-02-19/03:09:38.861 2014-02-19/03:09:39.230     [extended downstream waves]
;;       Ramp Times:   2014-04-19/17:48:24.688 2014-04-19/17:48:26.061     [precursor extends well into ramp; spike/overshoot in ramp; several IMF discontinuities up- and downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2014-05-07/21:19:37.450 2014-05-07/21:19:40.788     [precursor extends short way into ramp; intermittent downstream ULF waves]
;;       Ramp Times:   2014-05-29/08:26:40.940 2014-05-29/08:26:41.960     [several IMF discontinuities up- and downstream; very nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2014-07-14/13:38:08.971 2014-07-14/13:38:09.250     [several IMF discontinuities up- and downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2015-05-06/00:55:49.673 2015-05-06/00:55:50.040     [precursor extends short way into ramp; several IMF discontinuities up- and downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2015-06-24/13:07:14.601 2015-06-24/13:07:16.476     [several IMF discontinuities downstream; magnetic hole shortly after ramp; extended downstream waves]
;;       Ramp Times:   2015-08-15/07:43:39.740 2015-08-15/07:43:44.440     [precursor extends well into ramp; several IMF discontinuities downstream; nice short duration downstream waves; extended downstream waves]
;;       Ramp Times:   2016-03-11/04:28:57.349 2016-03-11/04:29:37.589     [precursor extends well into ramp; several IMF discontinuities up- and downstream; extended downstream waves]
;;       Ramp Times:   2016-03-14/16:16:31.880 2016-03-14/16:16:32.513     [spike/overshoot in ramp; extended downstream waves]






















;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
good           = good_y_all0
gd             = gd_y_all[0]
FOR j=0L, gd[0] - 1L DO PRINT,';;  ',j[0],'     ',STRMID(start_times[good[j[0]]],0L,10L)
;;             0     1995-04-17
;;             1     1995-07-22
;;             2     1995-08-22
;;             3     1995-08-24
;;             4     1995-10-22
;;             5     1995-12-24
;;             6     1996-02-06
;;             7     1996-04-03
;;             8     1996-04-08
;;             9     1997-03-15
;;            10     1997-04-10
;;            11     1997-10-24
;;            12     1997-11-01
;;            13     1997-12-10
;;            14     1997-12-30
;;            15     1998-01-06
;;            16     1998-02-18
;;            17     1998-05-29
;;            18     1998-08-06
;;            19     1998-08-19
;;            20     1998-11-08
;;            21     1998-12-28
;;            22     1999-01-13
;;            23     1999-02-17
;;            24     1999-04-16
;;            25     1999-06-26
;;            26     1999-08-04
;;            27     1999-08-23
;;            28     1999-09-22
;;            29     1999-10-21
;;            30     1999-11-05
;;            31     1999-11-13
;;            32     2000-02-05
;;            33     2000-02-14
;;            34     2000-06-23
;;            35     2000-07-13
;;            36     2000-07-26
;;            37     2000-07-28
;;            38     2000-08-10
;;            39     2000-08-11
;;            40     2000-10-28
;;            41     2000-10-31
;;            42     2000-11-06
;;            43     2000-11-26
;;            44     2000-11-28
;;            45     2001-01-17
;;            46     2001-03-03
;;            47     2001-03-22
;;            48     2001-03-27
;;            49     2001-04-21
;;            50     2001-05-06
;;            51     2001-05-12
;;            52     2001-09-13
;;            53     2001-10-28
;;            54     2001-11-30
;;            55     2001-12-21
;;            56     2001-12-30
;;            57     2002-01-17
;;            58     2002-01-31
;;            59     2002-03-23
;;            60     2002-03-29
;;            61     2002-05-21
;;            62     2002-06-29
;;            63     2002-08-01
;;            64     2002-09-30
;;            65     2002-11-09
;;            66     2003-05-29
;;            67     2003-06-18
;;            68     2004-04-12
;;            69     2005-05-06
;;            70     2005-05-07
;;            71     2005-06-16
;;            72     2005-07-10
;;            73     2005-08-24
;;            74     2005-09-02
;;            75     2006-08-19
;;            76     2007-08-22
;;            77     2007-12-17
;;            78     2008-05-28
;;            79     2008-06-24
;;            80     2009-02-03
;;            81     2009-06-24
;;            82     2009-06-27
;;            83     2009-10-21
;;            84     2010-04-11
;;            85     2011-02-04
;;            86     2011-07-11
;;            87     2011-09-16
;;            88     2011-09-25
;;            89     2012-01-21
;;            90     2012-01-30
;;            91     2012-06-16
;;            92     2012-10-08
;;            93     2012-11-12
;;            94     2012-11-26
;;            95     2013-02-13
;;            96     2013-04-30
;;            97     2013-06-10
;;            98     2013-07-12
;;            99     2013-09-02
;;           100     2013-10-26
;;           101     2014-02-13
;;           102     2014-02-15
;;           103     2014-02-19
;;           104     2014-04-19
;;           105     2014-05-07
;;           106     2014-05-29
;;           107     2014-07-14
;;           108     2015-05-06
;;           109     2015-06-24
;;           110     2015-08-15
;;           111     2016-03-11
;;           112     2016-03-14




