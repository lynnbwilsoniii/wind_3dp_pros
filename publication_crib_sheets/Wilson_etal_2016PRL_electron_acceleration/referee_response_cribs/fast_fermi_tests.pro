;;  Default to entire day
tr_00          = tdate[0]+'/'+['00:00:00.000','23:59:59.999']
;;  Define time range to use for foreshock overviews
IF (tdate[0] EQ '2008-07-14') THEN tr_bs_cal = time_double(tdate[0]+'/'+['11:52:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-08-19') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:00:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-09-08') THEN tr_bs_cal = time_double(tdate[0]+'/'+['16:30:00','21:32:00'])
IF (tdate[0] EQ '2008-09-16') THEN tr_bs_cal = time_double(tdate[0]+'/'+['12:20:00',end___of_day_t[0]])
IF (tdate[0] EQ '2008-07-14') THEN tra_overv = tr_bs_cal + [-1,1]*6d1*1d1                 ;;  expand by ±10 mins
IF (tdate[0] EQ '2008-08-19') THEN tra_overv = tr_bs_cal + [1,0e0]*4d1*6d1                ;;  shrink by 40 minutes at start
IF (tdate[0] EQ '2008-09-08') THEN tra_overv = tr_bs_cal
IF (tdate[0] EQ '2008-09-16') THEN tra_overv = tr_bs_cal
;;  Define time of last (i.e., crossing at largest distance from Earth) bow shock crossings
IF (tdate[0] EQ '2008-07-14') THEN t_bs_last = time_double(tdate[0]+'/'+'12:32:18')
IF (tdate[0] EQ '2008-08-19') THEN t_bs_last = time_double(tdate[0]+'/'+'22:43:42')
IF (tdate[0] EQ '2008-09-08') THEN t_bs_last = time_double(tdate[0]+'/'+'21:18:10')
IF (tdate[0] EQ '2008-09-16') THEN t_bs_last = time_double(tdate[0]+'/'+'18:08:50')
;;  Define center-times for specific TIFP
IF (tdate[0] EQ '2008-07-14') THEN t_slam_cent = tdate[0]+'/'+['13:16:26','13:19:30']
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__cent = tdate[0]+'/'+['15:21:00','22:37:22']
IF (tdate[0] EQ '2008-07-14') THEN t_fb___cent = tdate[0]+'/'+['20:03:21','21:55:45','21:58:10']

IF (tdate[0] EQ '2008-08-19') THEN t_slam_cent = tdate[0]+'/'+['21:48:55','21:53:45','22:17:35','22:18:30','22:22:30','22:37:45','22:42:48']
IF (tdate[0] EQ '2008-08-19') THEN t_hfa__cent = tdate[0]+'/'+['12:50:57','21:46:17','22:41:00']
IF (tdate[0] EQ '2008-08-19') THEN t_fb___cent = tdate[0]+'/'+['20:43:35','21:51:45']

IF (tdate[0] EQ '2008-09-08') THEN t_slam_cent = tdate[0]+'/'+['17:28:23','20:24:50','20:36:11','21:12:24','21:15:33']
IF (tdate[0] EQ '2008-09-08') THEN t_hfa__cent = tdate[0]+'/'+['17:01:41','19:13:57','20:26:44']
IF (tdate[0] EQ '2008-09-08') THEN t_fb___cent = tdate[0]+'/'+['20:25:22']

IF (tdate[0] EQ '2008-09-16') THEN t_slam_cent = tdate[0]+'/'+['00:00:00']
IF (tdate[0] EQ '2008-09-16') THEN t_hfa__cent = tdate[0]+'/'+['17:26:45']
IF (tdate[0] EQ '2008-09-16') THEN t_fb___cent = tdate[0]+'/'+['17:46:13']
;;  Define time ranges for upstream averages
IF (tdate[0] EQ '2008-07-14') THEN t_slam_upst = time_double(tdate[0]+'/'+['13:43:00','13:43:00'])
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__upst = time_double(tdate[0]+'/'+['15:35:00','22:42:00'])
IF (tdate[0] EQ '2008-07-14') THEN t_fb___upst = time_double(tdate[0]+'/'+['20:42:00','22:30:00','22:30:00'])
IF (tdate[0] EQ '2008-07-14') THEN t_slam_upen = time_double(tdate[0]+'/'+['13:46:00','13:46:00'])
IF (tdate[0] EQ '2008-07-14') THEN t_hfa__upen = time_double(tdate[0]+'/'+['15:38:00','22:45:00'])
IF (tdate[0] EQ '2008-07-14') THEN t_fb___upen = time_double(tdate[0]+'/'+['20:45:00','22:33:00','22:33:00'])
IF (tdate[0] EQ '2008-08-19') THEN t_slam_upst = time_double(tdate[0]+'/'+['21:59:45','21:59:45','22:18:42','22:18:42','22:25:24','22:41:36','22:42:54'])
IF (tdate[0] EQ '2008-08-19') THEN t_hfa__upst = time_double(tdate[0]+'/'+['12:42:00','21:59:45','22:41:36'])
IF (tdate[0] EQ '2008-08-19') THEN t_fb___upst = time_double(tdate[0]+'/'+['20:47:45','21:59:45'])
IF (tdate[0] EQ '2008-08-19') THEN t_slam_upen = time_double(tdate[0]+'/'+['22:00:45','22:00:45','22:19:12','22:19:12','22:26:00','22:42:12','22:43:20'])
IF (tdate[0] EQ '2008-08-19') THEN t_hfa__upen = time_double(tdate[0]+'/'+['12:43:00','22:00:45','22:42:12'])
IF (tdate[0] EQ '2008-08-19') THEN t_fb___upen = time_double(tdate[0]+'/'+['20:48:45','22:00:45'])
IF (tdate[0] EQ '2008-09-08') THEN t_slam_upst = time_double(tdate[0]+'/'+['17:55:00','20:29:30','20:46:00','21:01:00','21:16:45'])
IF (tdate[0] EQ '2008-09-08') THEN t_hfa__upst = time_double(tdate[0]+'/'+['16:47:40','19:29:00','20:29:30'])
IF (tdate[0] EQ '2008-09-08') THEN t_fb___upst = time_double(tdate[0]+'/'+['20:29:30'])
IF (tdate[0] EQ '2008-09-08') THEN t_slam_upen = time_double(tdate[0]+'/'+['17:57:00','20:31:00','20:47:00','21:03:00','21:17:05'])
IF (tdate[0] EQ '2008-09-08') THEN t_hfa__upen = time_double(tdate[0]+'/'+['16:49:00','19:31:00','20:31:00'])
IF (tdate[0] EQ '2008-09-08') THEN t_fb___upen = time_double(tdate[0]+'/'+['20:31:00'])
IF (tdate[0] EQ '2008-09-16') THEN t_slam_upst = time_double(tdate[0]+'/'+['00:00:00'])
IF (tdate[0] EQ '2008-09-16') THEN t_hfa__upst = time_double(tdate[0]+'/'+['17:13:00'])
IF (tdate[0] EQ '2008-09-16') THEN t_fb___upst = time_double(tdate[0]+'/'+['17:38:00'])
IF (tdate[0] EQ '2008-09-16') THEN t_slam_upen = time_double(tdate[0]+'/'+['00:01:00'])
IF (tdate[0] EQ '2008-09-16') THEN t_hfa__upen = time_double(tdate[0]+'/'+['17:16:00'])
IF (tdate[0] EQ '2008-09-16') THEN t_fb___upen = time_double(tdate[0]+'/'+['17:41:00'])


;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;          Center Time                     Box            Boy            Boz           Vix            Viy            Viz             Ni            Ti              Te        Enhancement?            Bmax
;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------
;;  SLAMS
;;------------------------------------------
;;  2008-07-14/13:16:26                   0.85049       -0.31672        3.88123     -650.22908       90.15677       42.21723        1.91967      109.77699        8.23216          No                 29.0
;;  2008-07-14/13:19:30                   0.85049       -0.31672        3.88123     -650.22908       90.15677       42.21723        1.91967      109.77699        8.23216          No                 38.0
;;------------------------------------------
;;  HFAS
;;------------------------------------------
;;  2008-07-14/15:21:00                   2.48377       -2.48814        1.89316     -640.43485       82.70524       46.93154        1.64736      119.51045       10.19904          No                  8.0
;;  2008-07-14/22:37:22                   0.19018       -3.03753        1.62743     -641.21237       45.39197       43.38304        1.14985      160.68942        7.91641          No                  7.5
;;------------------------------------------
;;  FBS
;;------------------------------------------
;;  2008-07-14/20:03:21                   1.20617        0.49537        3.32983     -647.11353       92.40317       47.82591        1.53499      110.96140        7.75536          No                 13.5
;;  2008-07-14/21:55:45                   2.67225       -2.01985       -0.68892     -611.82270       67.34560       34.61422        1.40825      136.74590       10.34374         Yes                 12.0
;;  2008-07-14/21:58:10                   2.67225       -2.01985       -0.68892     -611.82270       67.34560       34.61422        1.40825      136.74590       10.34374         Yes                 27.0
;;------------------------------------------
;;  BS Last
;;------------------------------------------
;;  2008-07-14/12:32:18                      -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN         Yes
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;          Center Time                     Box            Boy            Boz           Vix            Viy            Viz             Ni            Ti              Te        Enhancement?            Bmax
;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------
;;  SLAMS
;;------------------------------------------
;;  2008-08-19/21:48:55                  -4.45233       -0.06901       -1.15697     -469.44272       34.38181        1.61049        2.50447      151.28587       17.68887         Yes                 10.0
;;  2008-08-19/21:53:45                  -4.45233       -0.06901       -1.15697     -469.44272       34.38181        1.61049        2.50447      151.28587       17.68887         Yes                 27.0
;;  2008-08-19/22:17:35                  -4.39718        0.28863        0.06444     -467.18404       77.76149       10.80489        2.19373      235.13506       20.04340          No                 14.0
;;  2008-08-19/22:18:30                  -4.39718        0.28863        0.06444     -467.18404       77.76149       10.80489        2.19373      235.13506       20.04340         Yes                 14.5
;;  2008-08-19/22:22:30                  -1.93209       -0.12498        0.49713     -425.21411       51.14974       17.56595        0.98637      397.24945       22.39241         Yes                 16.0
;;  2008-08-19/22:37:45                  -3.16708        0.01073        2.00969     -457.38987       62.89950       10.59020        1.97246      216.40127       17.81489          No                 24.0
;;  2008-08-19/22:42:48                  -2.54822       -0.60778       -0.00241     -422.17666        4.21968        6.56874        1.23396      373.79191       19.46202          No                 11.0
;;------------------------------------------
;;  HFAS
;;------------------------------------------
;;  2008-08-19/12:50:57                  -0.59589        2.11973        1.65043     -537.10808       66.54217       -3.81991        1.87271       99.05405       11.60155         Yes                 24.0
;;  2008-08-19/21:46:17                  -4.45233       -0.06901       -1.15697     -469.44272       34.38181        1.61049        2.50447      151.28587       17.68887          No                  7.0
;;  2008-08-19/22:41:00                  -3.16708        0.01073        2.00969     -457.38987       62.89950       10.59020        1.97246      216.40127       17.81489          No                 12.5
;;------------------------------------------
;;  FBS
;;------------------------------------------
;;  2008-08-19/20:43:35                  -2.10610        3.12914        2.48182     -490.34641       24.42429       12.29568        2.12607      105.82797       15.80333          No                 23.0
;;  2008-08-19/21:51:45                  -4.45233       -0.06901       -1.15697     -469.44272       34.38181        1.61049        2.50447      151.28587       17.68887         Yes                 25.0
;;------------------------------------------
;;  BS Last
;;------------------------------------------
;;  2008-08-19/22:43:42                      -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN         Yes
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;          Center Time                     Box            Boy            Boz           Vix            Viy            Viz             Ni            Ti              Te        Enhancement?            Bmax
;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------
;;  SLAMS
;;------------------------------------------
;;  2008-09-08/17:28:23                   0.85124        1.72442       -2.96099     -540.60555       83.72737       16.68197        2.58563       66.17962        7.76400         N/A                 33.0
;;  2008-09-08/20:24:50                   2.57605        1.74533       -1.17876     -485.02222       96.29847        9.82804        2.84599      207.16648       10.41375         Yes                 17.0
;;  2008-09-08/20:36:11                   1.52944       -2.85974        0.81420     -509.54535       68.39345       22.94066        2.15886       70.38499       10.29908         N/A                 38.0
;;  2008-09-08/21:12:24                   2.45793       -2.46567       -0.00004     -418.51076       -9.40862      -20.31297        3.05208      554.53174       11.69417          No                 46.0
;;  2008-09-08/21:15:33                   2.42018       -1.62909       -1.41548     -450.44696       38.93449      -35.64142        3.29650      426.96240       10.61059          No                 36.0
;;------------------------------------------
;;  HFAS
;;------------------------------------------
;;  2008-09-08/17:01:41                   2.24290        1.82921       -2.58035     -524.98055       82.47949       20.57287        2.51951       61.53185       10.34733         Yes                 21.0
;;  2008-09-08/19:13:57                   2.14398       -1.18783       -2.79062     -513.47464       78.96290       14.23585        2.63643       65.74817       11.05542          No                  8.0
;;  2008-09-08/20:26:44                   2.57605        1.74533       -1.17876     -485.02222       96.29847        9.82804        2.84599      207.16648       10.41375          No                  9.0
;;------------------------------------------
;;  FBS
;;------------------------------------------
;;  2008-09-08/20:25:22                   2.57605        1.74533       -1.17876     -485.02222       96.29847        9.82804        2.84599      207.16648       10.41375         Yes                 36.0
;;------------------------------------------
;;  BS Last
;;------------------------------------------
;;  2008-09-08/21:18:10                      -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN         N/A
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;          Center Time                     Box            Boy            Boz           Vix            Viy            Viz             Ni            Ti              Te        Enhancement?            Bmax
;;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;;------------------------------------------
;;  SLAMS
;;------------------------------------------
;;  2008-09-16/00:00:00                      -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN         N/A
;;------------------------------------------
;;  HFAS
;;------------------------------------------
;;  2008-09-16/17:26:45                  -0.78851        2.21302       -0.46251     -494.94709       57.72019       18.45764        1.62316       82.20419       12.36006          No                  9.5
;;------------------------------------------
;;  FBS
;;------------------------------------------
;;  2008-09-16/17:46:13                  -1.45213        1.64859       -0.78888     -477.73508       69.39961       23.87302        1.93743       71.60427       12.95875          No                 14.5
;;------------------------------------------
;;  BS Last
;;------------------------------------------
;;  2008-09-16/18:08:50                      -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN           -NaN         Yes
;;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;;  Define energy [eV] bin values for SSTe and SSTi
me             = 9.1093835600d-31         ;;  Electron mass [kg, 2014 CODATA/NIST]
mp             = 1.6726218980d-27         ;;  Proton mass [kg, 2014 CODATA/NIST]
enere          = [31d0,41d0,52d0,66d0,93d0,139d0,204d0,293d0]*1d3
enerp          = [38d0,49d0,63d0,75d0,103d0,152d0,214d0,303d0,427d0]*1d3
nne            = N_ELEMENTS(enere)
nnp            = N_ELEMENTS(enerp)

;;  Define upstream average parameters
bo_up_all      = [[  0.85049d0,  -0.31672d0,   3.88123d0],$
                  [  0.85049d0,  -0.31672d0,   3.88123d0],$
                  [  2.48377d0,  -2.48814d0,   1.89316d0],$
                  [  0.19018d0,  -3.03753d0,   1.62743d0],$
                  [  1.20617d0,   0.49537d0,   3.32983d0],$
                  [  2.67225d0,  -2.01985d0,  -0.68892d0],$
                  [  2.67225d0,  -2.01985d0,  -0.68892d0],$
                  [ -4.45233d0,  -0.06901d0,  -1.15697d0],$
                  [ -4.45233d0,  -0.06901d0,  -1.15697d0],$
                  [ -4.39718d0,   0.28863d0,   0.06444d0],$
                  [ -4.39718d0,   0.28863d0,   0.06444d0],$
                  [ -1.93209d0,  -0.12498d0,   0.49713d0],$
                  [ -3.16708d0,   0.01073d0,   2.00969d0],$
                  [ -2.54822d0,  -0.60778d0,  -0.00241d0],$
                  [ -0.59589d0,   2.11973d0,   1.65043d0],$
                  [ -4.45233d0,  -0.06901d0,  -1.15697d0],$
                  [ -3.16708d0,   0.01073d0,   2.00969d0],$
                  [ -2.10610d0,   3.12914d0,   2.48182d0],$
                  [ -4.45233d0,  -0.06901d0,  -1.15697d0],$
                  [  0.85124d0,   1.72442d0,  -2.96099d0],$
                  [  2.57605d0,   1.74533d0,  -1.17876d0],$
                  [  1.52944d0,  -2.85974d0,   0.81420d0],$
                  [  2.45793d0,  -2.46567d0,  -0.00004d0],$
                  [  2.42018d0,  -1.62909d0,  -1.41548d0],$
                  [  2.24290d0,   1.82921d0,  -2.58035d0],$
                  [  2.14398d0,  -1.18783d0,  -2.79062d0],$
                  [  2.57605d0,   1.74533d0,  -1.17876d0],$
                  [  2.57605d0,   1.74533d0,  -1.17876d0],$
                  [ -0.78851d0,   2.21302d0,  -0.46251d0],$
                  [ -1.45213d0,   1.64859d0,  -0.78888d0] ]

Vi_up_all      = [[ -650.22908d0,  90.15677d0,  42.21723d0],$
                  [ -650.22908d0,  90.15677d0,  42.21723d0],$
                  [ -640.43485d0,  82.70524d0,  46.93154d0],$
                  [ -641.21237d0,  45.39197d0,  43.38304d0],$
                  [ -647.11353d0,  92.40317d0,  47.82591d0],$
                  [ -611.82270d0,  67.34560d0,  34.61422d0],$
                  [ -611.82270d0,  67.34560d0,  34.61422d0],$
                  [ -469.44272d0,  34.38181d0,   1.61049d0],$
                  [ -469.44272d0,  34.38181d0,   1.61049d0],$
                  [ -467.18404d0,  77.76149d0,  10.80489d0],$
                  [ -467.18404d0,  77.76149d0,  10.80489d0],$
                  [ -425.21411d0,  51.14974d0,  17.56595d0],$
                  [ -457.38987d0,  62.89950d0,  10.59020d0],$
                  [ -422.17666d0,   4.21968d0,   6.56874d0],$
                  [ -537.10808d0,  66.54217d0,  -3.81991d0],$
                  [ -469.44272d0,  34.38181d0,   1.61049d0],$
                  [ -457.38987d0,  62.89950d0,  10.59020d0],$
                  [ -490.34641d0,  24.42429d0,  12.29568d0],$
                  [ -469.44272d0,  34.38181d0,   1.61049d0],$
                  [ -540.60555d0,  83.72737d0,  16.68197d0],$
                  [ -485.02222d0,  96.29847d0,   9.82804d0],$
                  [ -509.54535d0,  68.39345d0,  22.94066d0],$
                  [ -418.51076d0,  -9.40862d0, -20.31297d0],$
                  [ -450.44696d0,  38.93449d0, -35.64142d0],$
                  [ -524.98055d0,  82.47949d0,  20.57287d0],$
                  [ -513.47464d0,  78.96290d0,  14.23585d0],$
                  [ -485.02222d0,  96.29847d0,   9.82804d0],$
                  [ -485.02222d0,  96.29847d0,   9.82804d0],$
                  [ -494.94709d0,  57.72019d0,  18.45764d0],$
                  [ -477.73508d0,  69.39961d0,  23.87302d0] ]
;;  fix form
bo_up_all      = TRANSPOSE(bo_up_all)
Vi_up_all      = TRANSPOSE(Vi_up_all)

ni_up_all      = [ 1.91967d0, 1.91967d0, 1.64736d0, 1.14985d0, 1.53499d0, 1.40825d0, $
                   1.40825d0, 2.50447d0, 2.50447d0, 2.19373d0, 2.19373d0, 0.98637d0, $
                   1.97246d0, 1.23396d0, 1.87271d0, 2.50447d0, 1.97246d0, 2.12607d0, $
                   2.50447d0, 2.58563d0, 2.84599d0, 2.15886d0, 3.05208d0, 3.29650d0, $
                   2.51951d0, 2.63643d0, 2.84599d0, 2.84599d0, 1.62316d0, 1.93743d0]

Ti_up_all      = [ 109.77699d0, 109.77699d0, 119.51045d0, 160.68942d0, 110.96140d0, $
                   136.74590d0, 136.74590d0, 151.28587d0, 151.28587d0, 235.13506d0, $
                   235.13506d0, 397.24945d0, 216.40127d0, 373.79191d0,  99.05405d0, $
                   151.28587d0, 216.40127d0, 105.82797d0, 151.28587d0,  66.17962d0, $
                   207.16648d0,  70.38499d0, 554.53174d0, 426.96240d0,  61.53185d0, $
                    65.74817d0, 207.16648d0, 207.16648d0,  82.20419d0,  71.60427d0]

Te_up_all      = [  8.23216d0,  8.23216d0, 10.19904d0,  7.91641d0,  7.75536d0, $
                   10.34374d0, 10.34374d0, 17.68887d0, 17.68887d0, 20.04340d0, $
                   20.04340d0, 22.39241d0, 17.81489d0, 19.46202d0, 11.60155d0, $
                   17.68887d0, 17.81489d0, 15.80333d0, 17.68887d0,  7.76400d0, $
                   10.41375d0, 10.29908d0, 11.69417d0, 10.61059d0, 10.34733d0, $
                   11.05542d0, 10.41375d0, 10.41375d0, 12.36006d0, 12.95875d0]
;;  Define max Bo value associated with TIFP
bmax_tifp      = [ 29.0d0, 38.0d0,  8.0d0,  7.5d0, 13.5d0, 12.0d0, 27.0d0, 10.0d0, $
                   27.0d0, 14.0d0, 14.5d0, 16.0d0, 24.0d0, 11.0d0, 24.0d0,  7.0d0, $
                   12.5d0, 23.0d0, 25.0d0, 33.0d0, 17.0d0, 38.0d0, 46.0d0, 36.0d0, $
                   21.0d0,  8.0d0,  9.0d0, 36.0d0,  9.5d0, 14.5d0]


enhanced       = [ ' No', ' No', ' No', ' No', ' No', 'Yes', 'Yes', 'Yes', 'Yes', ' No', $
                   'Yes', 'Yes', ' No', ' No', 'N/A', ' No', ' No', ' No', 'Yes', 'N/A', $
                   'Yes', 'N/A', ' No', ' No', 'Yes', ' No', ' No', 'Yes', ' No', ' No']
test_enh       = (STRLOWCASE(STRTRIM(enhanced,2)) EQ 'yes')
good_enh       = WHERE(test_enh,gd_enh,COMPLEMENT=bad__enh,NCOMPLEMENT=bd__enh)
PRINT,';;',gd_enh,bd__enh
;;          10          20
;;----------------------------------------------------------------------------------------
;;  Calculate relativistically correct gyroradii and frequencies for Bup and Bmax
;;----------------------------------------------------------------------------------------
bm_up_all      = mag__vec(bo_up_all)
Vm_up_all      = mag__vec(Vi_up_all)
nn             = N_ELEMENTS(bm_up_all)
rhoce_bup      = DBLARR(nn[0],nne[0])
rhoce_bmx      = DBLARR(nn[0],nne[0])
rhocp_bup      = DBLARR(nn[0],nnp[0])
rhocp_bmx      = DBLARR(nn[0],nnp[0])
frqce_bup      = DBLARR(nn[0],nne[0])
frqce_bmx      = DBLARR(nn[0],nne[0])
frqcp_bup      = DBLARR(nn[0],nnp[0])
frqcp_bmx      = DBLARR(nn[0],nnp[0])

FOR j=0L, nn[0] - 1L DO BEGIN                                           $
  bup = REPLICATE(bm_up_all[j],nne[0])                                & $
  bmx = REPLICATE(bmax_tifp[j],nne[0])                                & $
  rce_bup = lbw_gyroradius(bup,enere,/ELECTRON)                       & $
  rce_bmx = lbw_gyroradius(bmx,enere,/ELECTRON)                       & $
  wce_bup = lbw_gyrofrequency(bup,SP_OR_EN=enere,/ELECTRON,/ANGULAR)  & $
  wce_bmx = lbw_gyrofrequency(bmx,SP_OR_EN=enere,/ELECTRON,/ANGULAR)  & $
  bup = REPLICATE(bm_up_all[j],nnp[0])                                & $
  bmx = REPLICATE(bmax_tifp[j],nnp[0])                                & $
  rcp_bup = lbw_gyroradius(bup,enerp,/ELECTRON)                       & $
  rcp_bmx = lbw_gyroradius(bmx,enerp,/ELECTRON)                       & $
  wcp_bup = lbw_gyrofrequency(bup,SP_OR_EN=enerp,/PROTON,/ANGULAR)    & $
  wcp_bmx = lbw_gyrofrequency(bmx,SP_OR_EN=enerp,/PROTON,/ANGULAR)    & $
  rhoce_bup[j,*] = rce_bup                                            & $
  rhoce_bmx[j,*] = rce_bmx                                            & $
  frqce_bup[j,*] = ABS(wce_bup)/(2d0*!DPI)                            & $
  frqce_bmx[j,*] = ABS(wce_bmx)/(2d0*!DPI)                            & $
  rhocp_bup[j,*] = rcp_bup                                            & $
  rhocp_bmx[j,*] = rcp_bmx                                            & $
  frqcp_bup[j,*] = ABS(wcp_bup)/(2d0*!DPI)                            & $
  frqcp_bmx[j,*] = ABS(wcp_bmx)/(2d0*!DPI)

PRINT,';;  ',bm_up_all[6],bmax_tifp[6] & $
FOR j=0L, nne[0] - 1L DO PRINT,';;  ',enere[j]*1d-3,rhoce_bup[6,j],frqce_bup[6,j],rhoce_bmx[6,j],frqce_bmx[6,j]
;;          <Bo>_up         Bo_max
;;           [nT]            [nT]
;;         3.4198428       27.000000
;;
;;        Energy [keV]      rho [km]        fce [Hz]        rho [km]        fce [Hz]
;;                                  <Bo>_up                          Bo_max
;;======================================================================================
;;         31.000000       176.22509       90.254578       22.320819       712.56889
;;         41.000000       203.62508       88.619528       25.791325       699.66001
;;         52.000000       230.50297       86.888060       29.195701       685.98990
;;         66.000000       261.37205       84.779854       33.105604       669.34540
;;         93.000000       314.08822       80.990020       39.782679       639.42428
;;         139.00000       391.82871       75.258409       49.629356       594.17264
;;         204.00000       487.79022       68.416726       61.783921       540.15687
;;         293.00000       605.43773       60.843223       76.685254       480.36331

;;  Omidi et al. [2010] shows thicknesses of ~20-50 c/wpi
c              = 2.9979245800d+08         ;;  Speed of light in vacuum [m s^(-1), 2014 CODATA/NIST]
ckm            = c[0]*1d-3                ;;  m --> km
qq             = 1.6021766208d-19         ;;  Fundamental charge [C, 2014 CODATA/NIST]
epo            = 8.8541878170d-12         ;;  Permittivity of free space [F m^(-1), 2014 CODATA/NIST]
muo            = !DPI*4.00000d-07         ;;  Permeability of free space [N A^(-2) or H m^(-1), 2014 CODATA/NIST]
wpi_up         = SQRT(ni_up_all*1d6*qq[0]^2/mp[0]/epo[0])
Li_up          = ckm[0]/wpi_up

PRINT,';;  ',wpi_up[6],Li_up[6],2d1*Li_up[6],5d1*Li_up[6]
;;            wpi            c/wpi          20 c/wpi        50 c/wpi
;;          [rad/s]          [km]            [km]            [km]
;;         1562.3453       191.88618       3837.7235       9594.3088

;;  Determine transit times [s] for energetic electrons, ∆t
speede         = energy_to_vel(enere,/ELECTRON)
speedp         = energy_to_vel(enerp,/ELECTRON)

dt_01_li       = Li_up[6]/speede
dt_10_li       = 2d1*Li_up[6]/speede
dt_50_li       = 5d1*Li_up[6]/speede

;;  Determine ratio of gyroradii and c/wpi at Bup and Bmax completed in ∆t
r_Li_01_bup    = REFORM(rhoce_bup[6,*])/Li_up[6]
r_Li_10_bup    = REFORM(rhoce_bup[6,*])/Li_up[6]/2d1
r_Li_50_bup    = REFORM(rhoce_bup[6,*])/Li_up[6]/5d1
r_Li_01_bmx    = REFORM(rhoce_bmx[6,*])/Li_up[6]
r_Li_10_bmx    = REFORM(rhoce_bmx[6,*])/Li_up[6]/2d1
r_Li_50_bmx    = REFORM(rhoce_bmx[6,*])/Li_up[6]/5d1
FOR j=0L, nne[0] - 1L DO PRINT,';;  ',LONG(enere[j]*1d-3),r_Li_01_bup[j],r_Li_10_bup[j],r_Li_50_bup[j]
;;            31      0.91838346     0.045919173     0.018367669
;;            41       1.0611764     0.053058821     0.021223528
;;            52       1.2012485     0.060062423     0.024024969
;;            66       1.3621203     0.068106013     0.027242405
;;            93       1.6368465     0.081842325     0.032736930
;;           139       2.0419851      0.10209926     0.040839702
;;           204       2.5420811      0.12710406     0.050841622
;;           293       3.1551920      0.15775960     0.063103840

FOR j=0L, nne[0] - 1L DO PRINT,';;  ',LONG(enere[j]*1d-3),r_Li_01_bmx[j],r_Li_10_bmx[j],r_Li_50_bmx[j]
;;            31      0.11632323    0.0058161613    0.0023264645
;;            41      0.13440950    0.0067204750    0.0026881900
;;            52      0.15215114    0.0076075572    0.0030430229
;;            66      0.17252730    0.0086263651    0.0034505461
;;            93      0.20732436     0.010366218    0.0041464872
;;           139      0.25863956     0.012931978    0.0051727912
;;           204      0.32198214     0.016099107    0.0064396428
;;           293      0.39963929     0.019981964    0.0079927857


;;  Determine fraction of gyration at Bup and Bmax completed in ∆t
frac_gy_01_bup = dt_01_li*REFORM(frqce_bup[6,*])
frac_gy_10_bup = dt_10_li*REFORM(frqce_bup[6,*])
frac_gy_50_bup = dt_50_li*REFORM(frqce_bup[6,*])
frac_gy_01_bmx = dt_01_li*REFORM(frqce_bmx[6,*])
frac_gy_10_bmx = dt_10_li*REFORM(frqce_bmx[6,*])
frac_gy_50_bmx = dt_50_li*REFORM(frqce_bmx[6,*])

FOR j=0L, nne[0] - 1L DO PRINT,';;  ',LONG(enere[j]*1d-3),frac_gy_01_bup[j],frac_gy_10_bup[j],frac_gy_50_bup[j]
;;            31      0.17329901       3.4659802       8.6649504
;;            41      0.14997972       2.9995944       7.4989861
;;            52      0.13249128       2.6498256       6.6245639
;;            66      0.11684353       2.3368707       5.8421766
;;            93     0.097232662       1.9446532       4.8616331
;;           139     0.077941285       1.5588257       3.8970642
;;           204     0.062608130       1.2521626       3.1304065
;;           293     0.050442237       1.0088447       2.5221118

FOR j=0L, nne[0] - 1L DO PRINT,';;  ',LONG(enere[j]*1d-3),frac_gy_01_bmx[j],frac_gy_10_bmx[j],frac_gy_50_bmx[j]
;;            31       1.3682129       27.364259       68.410647
;;            41       1.1841049       23.682097       59.205243
;;            52       1.0460318       20.920637       52.301592
;;            66      0.92249134       18.449827       46.124567
;;            93      0.76766156       15.353231       38.383078
;;           139      0.61535421       12.307084       30.767711
;;           204      0.49429743       9.8859485       24.714871
;;           293      0.39824649       7.9649298       19.912324



test           = print_1var_stats(bm_up_all)
;;             Min. value of X  =         1.9989322
;;             Max. value of X  =         4.6007156
;;             Avg. value of X  =         3.6112472
;;           Median value of X  =         3.5760321
;;     Standard Deviation of X  =        0.70838299
;;  Std. Dev. of the Mean of X  =        0.12933245

test           = print_1var_stats(bmax_tifp)
;;             Min. value of X  =         7.0000000
;;             Max. value of X  =         46.000000
;;             Avg. value of X  =         20.366667
;;           Median value of X  =         17.000000
;;     Standard Deviation of X  =         11.074149
;;  Std. Dev. of the Mean of X  =         2.0218538


;;----------------------------------------------------------------------------------------
;;  Calculate parameters for fast Fermi acceleration
;;----------------------------------------------------------------------------------------
bu_up_all      = unit_vec(bo_up_all)
Vu_up_all      = unit_vec(Vi_up_all)

;;  Calc angle between <Vsw>_up and <Bo>_up
c_psi          = my_dot_prod(bu_up_all,Vu_up_all,/NOM)
psi            = ACOS(c_psi)*18d1/!DPI

;;  Calculate critical angle for electron reflection
bu_bmax_rat    = bm_up_all/bmax_tifp
thetac         = ASIN(bu_bmax_rat)*18d1/!DPI
Ti_Te_rat      = Ti_up_all/Te_up_all

;;  Calculate rough energy gain estimate (~Ef/Ei)
cc             = COS(thetac*!DPI/18d1)
sc             = SIN(thetac*!DPI/18d1)
ef_ei_0        = (1d0 + cc^2)/sc^2
ef_0_Te        = ef_ei_0*Te_up_all         ;;  Assume Te is initial energy
ef_0_6Te       = ef_ei_0*Te_up_all*6d0     ;;  Assume 6*Te is initial energy [Wu, 1984 JGR]


test           = print_1var_stats(ef_ei_0)
;;             Min. value of X  =         3.6299393
;;             Max. value of X  =         348.14760
;;             Avg. value of X  =         87.150651
;;           Median value of X  =         57.663838
;;     Standard Deviation of X  =         90.270031
;;  Std. Dev. of the Mean of X  =         16.480978

test           = print_1var_stats(ef_0_Te)
;;             Min. value of X  =         64.209524
;;             Max. value of X  =         4071.2972
;;             Avg. value of X  =         1039.5581
;;           Median value of X  =         804.33927
;;     Standard Deviation of X  =         1008.6560
;;  Std. Dev. of the Mean of X  =         184.15454

test           = print_1var_stats(ef_0_6Te)
;;             Min. value of X  =         385.25714
;;             Max. value of X  =         24427.783
;;             Avg. value of X  =         6237.3489
;;           Median value of X  =         4826.0356
;;     Standard Deviation of X  =         6051.9359
;;  Std. Dev. of the Mean of X  =         1104.9273

test           = print_1var_stats(ni_up_all)
;;             Min. value of X  =        0.98637000
;;             Max. value of X  =         3.2965000
;;             Avg. value of X  =         2.1301660
;;           Median value of X  =         2.1588600
;;     Standard Deviation of X  =        0.59111605
;;  Std. Dev. of the Mean of X  =        0.10792253

test           = print_1var_stats(Ti_up_all)
;;             Min. value of X  =         61.531850
;;             Max. value of X  =         554.53174
;;             Avg. value of X  =         179.63311
;;           Median value of X  =         151.28587
;;     Standard Deviation of X  =         118.62483
;;  Std. Dev. of the Mean of X  =         21.657831

test           = print_1var_stats(Te_up_all)
;;             Min. value of X  =         7.7553600
;;             Max. value of X  =         22.392410
;;             Avg. value of X  =         13.236154
;;           Median value of X  =         11.601550
;;     Standard Deviation of X  =         4.4171869
;;  Std. Dev. of the Mean of X  =        0.80646429

test           = print_1var_stats(Ti_Te_rat)
;;             Min. value of X  =         5.5255538
;;             Max. value of X  =         47.419504
;;             Avg. value of X  =         14.011684
;;           Median value of X  =         12.147213
;;     Standard Deviation of X  =         9.3838209
;;  Std. Dev. of the Mean of X  =         1.7132435

test           = print_1var_stats(bm_up_all)
;;             Min. value of X  =         1.9989322
;;             Max. value of X  =         4.6007156
;;             Avg. value of X  =         3.6112472
;;           Median value of X  =         3.5760321
;;     Standard Deviation of X  =        0.70838299
;;  Std. Dev. of the Mean of X  =        0.12933245

test           = print_1var_stats(Vm_up_all)
;;             Min. value of X  =         419.10905
;;             Max. value of X  =         657.80574
;;             Avg. value of X  =         519.49093
;;           Median value of X  =         494.58724
;;     Standard Deviation of X  =         75.620021
;;  Std. Dev. of the Mean of X  =         13.806264

test           = print_1var_stats(bmax_tifp)
;;             Min. value of X  =         7.0000000
;;             Max. value of X  =         46.000000
;;             Avg. value of X  =         20.366667
;;           Median value of X  =         17.000000
;;     Standard Deviation of X  =         11.074149
;;  Std. Dev. of the Mean of X  =         2.0218538

test           = print_1var_stats(bu_bmax_rat)
;;             Min. value of X  =       0.075685114
;;             Max. value of X  =        0.65724509
;;             Avg. value of X  =        0.23932054
;;           Median value of X  =        0.19573025
;;     Standard Deviation of X  =        0.14763895
;;  Std. Dev. of the Mean of X  =       0.026955061

test           = print_1var_stats(thetac)
;;             Min. value of X  =         4.3405883
;;             Max. value of X  =         41.090105
;;             Avg. value of X  =         14.062079
;;           Median value of X  =         11.287386
;;     Standard Deviation of X  =         9.0685394
;;  Std. Dev. of the Mean of X  =         1.6556812


LOADCT,39
DEVICE,DECOMPOSED=0


xxg            = bmax_tifp[good_enh]
yyg            = ef_ei_0[good_enh]
xxb            = bmax_tifp[bad__enh]
yyb            = ef_ei_0[bad__enh]
xran           = [5,50]
yran           = [1,350]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA,/XLOG,/YLOG
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = bmax_tifp[good_enh]
yyg            = ef_0_Te[good_enh]
xxb            = bmax_tifp[bad__enh]
yyb            = ef_0_Te[bad__enh]
xran           = [5,50]
yran           = [10,5e3]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA,/XLOG,/YLOG
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = bmax_tifp[good_enh]
yyg            = ef_0_6Te[good_enh]
xxb            = bmax_tifp[bad__enh]
yyb            = ef_0_6Te[bad__enh]
xran           = [5,50]
yran           = [100,30e3]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA,/XLOG,/YLOG
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5








xxg            = good_enh
yyg            = thetac[good_enh]
xxb            = bad__enh
yyb            = thetac[bad__enh]
xran           = [0,nn[0]]
yran           = [0,90]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

nn             = N_ELEMENTS(thetac)
xxg            = good_enh
yyg            = COS(thetac[good_enh]*!DPI/18d1)
xxb            = bad__enh
yyb            = COS(thetac[bad__enh]*!DPI/18d1)
xran           = [0,nn[0]]
yran           = [0,1.1]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

nn             = N_ELEMENTS(thetac)
xxg            = good_enh
yyg            = SIN(thetac[good_enh]*!DPI/18d1)
xxb            = bad__enh
yyb            = SIN(thetac[bad__enh]*!DPI/18d1)
xran           = [0,nn[0]]
yran           = [0,1.1]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5


xxg            = bmax_tifp[good_enh]
yyg            = thetac[good_enh]
xxb            = bmax_tifp[bad__enh]
yyb            = thetac[bad__enh]
xran           = [0,50]
yran           = [0,90]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = bm_up_all[good_enh]
yyg            = thetac[good_enh]
xxb            = bm_up_all[bad__enh]
yyb            = thetac[bad__enh]
xran           = [0,5]
yran           = [0,90]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = Vm_up_all[good_enh]
yyg            = thetac[good_enh]
xxb            = Vm_up_all[bad__enh]
yyb            = thetac[bad__enh]
xran           = [400,700]
yran           = [0,90]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = Vm_up_all[good_enh]
yyg            = bmax_tifp[good_enh]
xxb            = Vm_up_all[bad__enh]
yyb            = bmax_tifp[bad__enh]
xran           = [400,700]
yran           = [0,50]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = ni_up_all[good_enh]
yyg            = bmax_tifp[good_enh]
xxb            = ni_up_all[bad__enh]
yyb            = bmax_tifp[bad__enh]
xran           = [0,5]
yran           = [0,50]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = Ti_up_all[good_enh]
yyg            = bmax_tifp[good_enh]
xxb            = Ti_up_all[bad__enh]
yyb            = bmax_tifp[bad__enh]
xran           = [10,600]
yran           = [1,50]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA,/XLOG,/YLOG
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = Te_up_all[good_enh]
yyg            = bmax_tifp[good_enh]
xxb            = Te_up_all[bad__enh]
yyb            = bmax_tifp[bad__enh]
xran           = [0,25]
yran           = [0,50]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = Te_up_all[good_enh]
yyg            = thetac[good_enh]
xxb            = Te_up_all[bad__enh]
yyb            = thetac[bad__enh]
xran           = [0,25]
yran           = [0,90]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = Te_up_all[good_enh]
yyg            = ef_ei_0[good_enh]
xxb            = Te_up_all[bad__enh]
yyb            = ef_ei_0[bad__enh]
xran           = [5,30]
yran           = [1,350]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA,/XLOG,/YLOG
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = ef_ei_0[good_enh]
yyg            = thetac[good_enh]
xxb            = ef_ei_0[bad__enh]
yyb            = thetac[bad__enh]
xran           = [1,350]
yran           = [0,90]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = Ti_up_all[good_enh]
yyg            = thetac[good_enh]
xxb            = Ti_up_all[bad__enh]
yyb            = thetac[bad__enh]
xran           = [10,600]
yran           = [0,90]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA,/XLOG
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = Ti_Te_rat[good_enh]
yyg            = thetac[good_enh]
xxb            = Ti_Te_rat[bad__enh]
yyb            = thetac[bad__enh]
xran           = [0,50]
yran           = [0,90]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = Ti_Te_rat[good_enh]
yyg            = thetac[good_enh]
xxb            = Ti_Te_rat[bad__enh]
yyb            = thetac[bad__enh]
xran           = [1,50]
yran           = [0,90]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA,/XLOG
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5

xxg            = Ti_Te_rat[good_enh]
yyg            = COS(thetac[good_enh]*!DPI/18d1)
xxb            = Ti_Te_rat[bad__enh]
yyb            = COS(thetac[bad__enh]*!DPI/18d1)
xran           = [1,50]
yran           = [0,1.1]

PLOT,xxg,yyg,XRANGE=xran,YRANGE=yran,/XSTYLE,/YSTYLE,/NODATA,/XLOG
  OPLOT,xxg,yyg,COLOR=250,PSYM=4
  OPLOT,xxb,yyb,COLOR= 50,PSYM=5





















