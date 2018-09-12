;;  @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/print_latex_wind_3dp_swe_onevar_stats_new_2_batch.pro
;;
;;  Note:  User must call the following prior to running this batch file
;;         @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/wind_load_and_analyze_3dp_swe_mfi_new_2_batch.pro

test           = (N_ELEMENTS(Tr_avg_epeaap) LT 2) OR (is_a_number(beta_per_epa,/NOMSSG) EQ 0)
IF (test[0]) THEN STOP

hline_tex      = '      \hline'
nform0         = 'g8.1'
nform1         = 'I'
nform2         = 'f8.2'
texform        = '(";;  ",a56," & ",'+nform0[0]+'," & ",'+nform1[0]+'," & ",'+nform2[0]+'," & ",'+nform2[0]+'," & ",'+nform2[0]+'," & ",'+nform1[0]+',"  \tabularnewline")'
spec_latex     = ['e','p','\alpha']                                                                            ;;  i
comp_latex_str = ['avg','\perp','\parallel']                                                                   ;;  j
str_beta_pref  = '$\beta{\scriptstyle_{'
str_beta_suff0 = '}}$ [N/A]\tnote{a}'
str_beta_suff1 = '}}$ [N/A]'
nx             = N_ELEMENTS(beta_avg_epa[*,0,1])
aind           = LINDGEN(nx[0])
tags           = 'T'+num2int_str(LINDGEN(20),NUM_CHAR=3,/ZERO_PAD)
ind_struc      = CREATE_STRUCT(tags[0:5],aind,out_ip_shock,in__mo_all,out_mo_all,good_fast_swe,good_slow_swe)  ;;  k
struc_betae    = CREATE_STRUCT(tags[0:2],beta_avg_epa[*,0,1],beta_per_epa[*,0,1],beta_par_epa[*,0,1])
struc_betap    = CREATE_STRUCT(tags[0:2],beta_avg_epa[*,1,1],beta_per_epa[*,1,1],beta_par_epa[*,1,1])
struc_betaa    = CREATE_STRUCT(tags[0:2],beta_avg_epa[*,2,1],beta_per_epa[*,2,1],beta_par_epa[*,2,1])
beta_stru      = CREATE_STRUCT(tags[0:2],struc_betae,struc_betap,struc_betaa)

nk             = N_TAGS(ind_struc)
FOR k=0L, nk[0] - 1L DO BEGIN                                                                      $
  gind0   = ind_struc.(k)                                                                        & $
  IF (k EQ 0) THEN suff0 = str_beta_suff0[0] ELSE suff0 = str_beta_suff1[0]                      & $
  FOR i=0L, 2L DO BEGIN                                                                            $
    beta_ss = beta_stru.(i)                                                                      & $
    spec_s  = spec_latex[i]                                                                      & $
    FOR j=0L, 2L DO BEGIN                                                                          $
      str_pref0 = str_beta_pref[0]+spec_s[0]+', '+comp_latex_str[j]+suff0[0]                     & $
      x         = (beta_ss.(j))[gind0]                                                           & $
      y         = WHERE(FINITE(x))                                                               & $
      stats     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),N_ELEMENTS(y)]  & $
      PRINT,str_pref0[0],stats,FORMAT=texform[0]                                                 & $
    ENDFOR                                                                                       & $
    PRINT,';;  ',hline_tex[0]




hline_tex      = '      \hline'
nform0         = 'g8.1'
nform1         = 'f8.1'
nform2         = 'f8.2'
nform3         = 'I'
texform        = '(";;  ",a105," & ",'+nform0[0]+'," & ",'+nform1[0]+'," & ",'+nform2[0]+'," & ",'+nform2[0]+'," & ",'+nform2[0]+'," & ",'+nform3[0]+',"  \tabularnewline")'
str_trat_pref  = '$\left(T{\scriptstyle_{'
str_trat_midf  = '}}/T{\scriptstyle_{'
str_trat_suf0  = '}}\right){\scriptstyle_{'
spec_latex1    = ['e','e','\alpha']                                                                            ;;  i
spec_latex2    = ['p','\alpha','p']                                                                            ;;  i
comp_latex_str = ['avg','\perp','\parallel']                                                                   ;;  j
str_trat_suff0 = '}}$ [N/A]\tnote{a}'
str_trat_suff1 = '}}$ [N/A]'

nx             = N_ELEMENTS(Tr_avg_epeaap[*,0,1,1])
aind           = LINDGEN(nx[0])
tags           = 'T'+num2int_str(LINDGEN(20),NUM_CHAR=3,/ZERO_PAD)
ind_struc      = CREATE_STRUCT(tags[0:5],aind,out_ip_shock,in__mo_all,out_mo_all,good_fast_swe,good_slow_swe)  ;;  k
struc_trate2p  = CREATE_STRUCT(tags[0:2],Tr_avg_epeaap[*,0,1,1],Tr_per_epeaap[*,0,1,1],Tr_par_epeaap[*,0,1,1])
struc_trate2a  = CREATE_STRUCT(tags[0:2],Tr_avg_epeaap[*,1,1,1],Tr_per_epeaap[*,1,1,1],Tr_par_epeaap[*,1,1,1])
struc_trata2p  = CREATE_STRUCT(tags[0:2],Tr_avg_epeaap[*,2,1,1],Tr_per_epeaap[*,2,1,1],Tr_par_epeaap[*,2,1,1])
trat_stru      = CREATE_STRUCT(tags[0:2],struc_trate2p,struc_trate2a,struc_trata2p)

nk             = N_TAGS(ind_struc)
FOR k=0L, nk[0] - 1L DO BEGIN                                                                      $
  gind0   = ind_struc.(k)                                                                        & $
  IF (k EQ 0) THEN suff0 = str_beta_suff0[0] ELSE suff0 = str_beta_suff1[0]                      & $
  FOR i=0L, 2L DO BEGIN                                                                            $
    trat_ss = trat_stru.(i)                                                                      & $
    spec_1  = spec_latex1[i]                                                                     & $
    spec_2  = spec_latex2[i]                                                                     & $
    FOR j=0L, 2L DO BEGIN                                                                          $
      temp      = str_trat_pref[0]+spec_1[0]+str_trat_midf[0]                                    & $
      str_pref0 = temp[0]+spec_2[0]+str_trat_suf0[0]+comp_latex_str[j]+suff0[0]                  & $
      x         = (trat_ss.(j))[gind0]                                                           & $
      y         = WHERE(FINITE(x))                                                               & $
      stats     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),N_ELEMENTS(y)]  & $
      PRINT,str_pref0[0],stats,FORMAT=texform[0]                                                 & $
    ENDFOR                                                                                       & $
    PRINT,';;  ',hline_tex[0]




hline_tex      = '      \hline'
nform0         = 'f8.2'
nform1         = 'f8.1'
nform2         = 'f8.2'
nform3         = 'I'
texform        = '(";;  ",a55," & ",'+nform0[0]+'," & ",'+nform1[0]+'," & ",'+nform1[0]+'," & ",'+nform1[0]+'," & ",'+nform1[0]+'," & ",'+nform3[0]+',"  \tabularnewline")'
str_temp_pref  = '$T{\scriptstyle_{'

spec_latex     = ['e','p','\alpha']                                                                            ;;  i
comp_latex_str = ['avg','\perp','\parallel']                                                                   ;;  j
str_temp_suff0 = '}}$ [eV]\tnote{a}'
str_temp_suff1 = '}}$ [eV]'

nx             = N_ELEMENTS(gtavg_epa[*,0,1])
aind           = LINDGEN(nx[0])
tags           = 'T'+num2int_str(LINDGEN(20),NUM_CHAR=3,/ZERO_PAD)
ind_struc      = CREATE_STRUCT(tags[0:5],aind,out_ip_shock,in__mo_all,out_mo_all,good_fast_swe,good_slow_swe)  ;;  k
struc_tempe    = CREATE_STRUCT(tags[0:2],gtavg_epa[*,0,1],gtper_epa[*,0,1],gtpar_epa[*,0,1])
struc_tempp    = CREATE_STRUCT(tags[0:2],gtavg_epa[*,1,1],gtper_epa[*,1,1],gtpar_epa[*,1,1])
struc_tempa    = CREATE_STRUCT(tags[0:2],gtavg_epa[*,2,1],gtper_epa[*,2,1],gtpar_epa[*,2,1])
temp_stru      = CREATE_STRUCT(tags[0:2],struc_tempe,struc_tempp,struc_tempa)

nk             = N_TAGS(ind_struc)
FOR k=0L, nk[0] - 1L DO BEGIN                                                                      $
  gind0   = ind_struc.(k)                                                                        & $
  IF (k EQ 0) THEN suff0 = str_temp_suff0[0] ELSE suff0 = str_temp_suff1[0]                      & $
  FOR i=0L, 2L DO BEGIN                                                                            $
    temp_ss = temp_stru.(i)                                                                      & $
    spec_s  = spec_latex[i]                                                                      & $
    FOR j=0L, 2L DO BEGIN                                                                          $
      str_pref0 = str_temp_pref[0]+spec_s[0]+', '+comp_latex_str[j]+suff0[0]                     & $
      x         = (temp_ss.(j))[gind0]                                                           & $
      y         = WHERE(FINITE(x))                                                               & $
      stats     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),N_ELEMENTS(y)]  & $
      PRINT,str_pref0[0],stats,FORMAT=texform[0]                                                 & $
    ENDFOR                                                                                       & $
    PRINT,';;  ',hline_tex[0]




;;        $\beta{\scriptstyle_{e, avg}}$ [N/A]\tnote{a} &    0.006 &         8870 &     2.31 &     1.09 &    17.57 &       820056  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A]\tnote{a} &    0.007 &         8914 &     2.37 &     1.17 &    17.56 &       820056  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A]\tnote{a} &    0.005 &         8848 &     2.28 &     1.05 &    17.58 &       820056  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A]\tnote{a} &    0.001 &         4568 &     1.79 &     1.05 &    11.37 &      1095171  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A]\tnote{a} &   4.e-05 &         4391 &     1.70 &     0.92 &    11.34 &      1124001  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A]\tnote{a} &   6.e-05 &         4923 &     2.05 &     1.29 &    11.57 &      1103741  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A]\tnote{a} &   5.e-05 &          612 &     0.17 &     0.05 &     1.35 &       476129  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A]\tnote{a} &   5.e-05 &          594 &     0.19 &     0.08 &     1.23 &       883409  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A]\tnote{a} &   2.e-05 &          647 &     0.22 &     0.07 &     1.49 &       564081  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{e, avg}}$ [N/A] &    0.006 &         8870 &     2.35 &     1.11 &    18.15 &       760814  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A] &    0.007 &         8914 &     2.42 &     1.19 &    18.14 &       760814  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A] &    0.005 &         8848 &     2.32 &     1.07 &    18.16 &       760814  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A] &    0.001 &         4568 &     1.81 &     1.07 &    11.58 &      1001816  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A] &   8.e-05 &         4391 &     1.71 &     0.94 &    11.58 &      1028396  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A] &   0.0001 &         4923 &     2.07 &     1.32 &    11.74 &      1009616  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A] &   5.e-05 &          295 &     0.16 &     0.05 &     0.99 &       428411  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A] &   8.e-05 &          373 &     0.19 &     0.08 &     1.04 &       804136  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A] &   2.e-05 &          415 &     0.22 &     0.07 &     1.20 &       512064  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{e, avg}}$ [N/A] &    0.006 &           37 &     0.52 &     0.40 &     0.65 &        29389  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A] &    0.007 &           38 &     0.56 &     0.42 &     0.68 &        29389  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A] &    0.005 &           36 &     0.50 &     0.38 &     0.63 &        29389  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A] &    0.001 &          159 &     0.29 &     0.13 &     1.11 &        72530  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A] &   4.e-05 &          157 &     0.28 &     0.12 &     1.11 &        73349  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A] &   6.e-05 &          164 &     0.34 &     0.13 &     1.18 &        73149  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A] &   5.e-05 &           29 &     0.03 &     0.01 &     0.17 &        43343  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A] &   5.e-05 &           49 &     0.04 &     0.01 &     0.25 &        63344  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A] &   2.e-05 &           32 &     0.03 &     0.01 &     0.19 &        45878  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{e, avg}}$ [N/A] &     0.02 &         8870 &     2.38 &     1.13 &    17.89 &       790667  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A] &     0.03 &         8914 &     2.44 &     1.21 &    17.88 &       790667  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A] &     0.02 &         8848 &     2.34 &     1.09 &    17.90 &       790667  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A] &    0.002 &         4568 &     1.90 &     1.11 &    11.76 &      1022641  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A] &   0.0003 &         4391 &     1.80 &     0.98 &    11.72 &      1050652  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A] &   0.0001 &         4923 &     2.17 &     1.38 &    11.96 &      1030592  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A] &   0.0002 &          612 &     0.18 &     0.06 &     1.42 &       432786  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A] &   5.e-05 &          594 &     0.20 &     0.09 &     1.27 &       820065  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A] &   6.e-05 &          647 &     0.24 &     0.09 &     1.56 &       518203  \tabularnewline
;;        \hline
;;  Fast vs. Slow Wind
;;        $\beta{\scriptstyle_{e, avg}}$ [N/A] &     0.02 &          680 &     1.05 &     0.73 &     3.90 &        60700  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A] &     0.02 &          710 &     1.16 &     0.84 &     4.01 &        60700  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A] &     0.02 &          665 &     1.00 &     0.67 &     3.85 &        60700  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A] &    0.001 &         2347 &     1.80 &     1.25 &     8.49 &       169997  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A] &   4.e-05 &         2198 &     1.79 &     1.21 &     8.91 &       190122  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A] &   6.e-05 &         2646 &     2.01 &     1.40 &     9.25 &       173560  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A] &   0.0002 &          612 &     0.31 &     0.08 &     4.01 &        31497  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A] &   5.e-05 &          594 &     0.34 &     0.21 &     2.23 &       106749  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A] &   8.e-05 &          647 &     0.41 &     0.17 &     3.60 &        45991  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{e, avg}}$ [N/A] &     0.01 &         4329 &     3.35 &     1.61 &    18.05 &       394244  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A] &     0.01 &         4332 &     3.41 &     1.67 &    17.97 &       394244  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A] &     0.01 &         4328 &     3.33 &     1.58 &    18.09 &       394244  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A] &    0.001 &         4568 &     1.79 &     1.01 &    11.83 &       925174  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A] &   0.0006 &         4391 &     1.68 &     0.87 &    11.78 &       933870  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A] &   0.0001 &         4923 &     2.05 &     1.27 &    11.95 &       930181  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A] &   5.e-05 &          295 &     0.16 &     0.05 &     0.90 &       444632  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A] &   5.e-05 &          373 &     0.17 &     0.07 &     1.02 &       776660  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A] &   2.e-05 &          415 &     0.21 &     0.07 &     1.13 &       518090  \tabularnewline
;;        \hline


;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A]\tnote{a} &     0.07 &     25.3 &     1.64 &     1.27 &     1.26 &       445801  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A]\tnote{a} &     0.03 &    184.6 &     1.89 &     1.51 &     1.49 &       454588  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A]\tnote{a} &     0.02 &    161.1 &     1.44 &     1.01 &     1.47 &       445732  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A]\tnote{a} &     0.02 &     22.9 &     1.24 &     0.82 &     1.25 &       193704  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A]\tnote{a} &     0.01 &     42.3 &     0.99 &     0.48 &     1.20 &       393745  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A]\tnote{a} &    0.009 &     45.8 &     1.14 &     0.64 &     1.34 &       207313  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A]\tnote{a} &     0.02 &     19.0 &     2.50 &     1.94 &     1.45 &       476255  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A]\tnote{a} &    0.004 &    200.0 &     3.47 &     3.16 &     2.25 &       883427  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A]\tnote{a} &     0.02 &    271.7 &     2.86 &     2.11 &     2.40 &       564072  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] &     0.07 &     25.3 &     1.64 &     1.27 &     1.25 &       412947  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.06 &    184.6 &     1.90 &     1.52 &     1.48 &       421080  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.02 &    161.1 &     1.43 &     1.00 &     1.46 &       412917  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A] &     0.02 &     22.9 &     1.26 &     0.82 &     1.26 &       177265  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.01 &     42.3 &     1.00 &     0.48 &     1.20 &       363851  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A] &    0.009 &     45.8 &     1.14 &     0.64 &     1.34 &       190413  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] &     0.02 &     19.0 &     2.49 &     1.91 &     1.45 &       428536  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.01 &    200.0 &     3.45 &     3.16 &     2.21 &       804166  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.02 &    271.7 &     2.88 &     2.12 &     2.45 &       512077  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] &     0.09 &     25.3 &     2.55 &     2.06 &     1.93 &        18203  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] &      0.1 &     79.4 &     2.96 &     2.35 &     2.41 &        18356  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.03 &    161.1 &     2.38 &     1.87 &     2.60 &        18186  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A] &     0.04 &     22.9 &     1.87 &     1.45 &     1.69 &        10077  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.02 &     42.3 &     1.69 &     1.02 &     2.01 &        16643  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.02 &     30.0 &     1.82 &     1.34 &     1.82 &        10290  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] &     0.02 &     18.3 &     2.27 &     1.78 &     1.33 &        43343  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] &    0.004 &     79.8 &     3.20 &     2.27 &     2.69 &        63318  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.04 &     40.3 &     2.17 &     1.66 &     1.64 &        45837  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] &     0.07 &     23.2 &     1.60 &     1.25 &     1.20 &       427598  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.03 &    184.6 &     1.84 &     1.49 &     1.42 &       436232  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.02 &    129.3 &     1.40 &     0.99 &     1.39 &       427546  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A] &     0.02 &     17.2 &     1.21 &     0.79 &     1.21 &       183627  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.01 &     37.6 &     0.96 &     0.47 &     1.14 &       377102  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A] &    0.009 &     45.8 &     1.10 &     0.61 &     1.30 &       197023  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] &      0.2 &     19.0 &     2.52 &     1.96 &     1.46 &       432912  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.01 &    200.0 &     3.49 &     3.24 &     2.21 &       820109  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.02 &    271.7 &     2.92 &     2.18 &     2.44 &       518235  \tabularnewline
;;        \hline
;;  Fast vs. Slow Wind
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] &     0.07 &     17.3 &     0.62 &     0.49 &     0.67 &        55111  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.03 &     86.7 &     0.76 &     0.58 &     1.02 &        60628  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.02 &     68.4 &     0.54 &     0.39 &     0.94 &        55125  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A] &     0.02 &      9.5 &     0.47 &     0.19 &     0.73 &         9002  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.01 &     42.1 &     0.25 &     0.14 &     0.55 &        40295  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A] &    0.009 &     26.7 &     0.43 &     0.14 &     0.92 &        11339  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] &     0.03 &     16.4 &     3.31 &     3.18 &     1.51 &        31498  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] &    0.004 &    200.0 &     4.55 &     4.45 &     2.23 &       106725  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.04 &     58.9 &     4.12 &     3.31 &     4.19 &        45980  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] &      0.1 &     25.3 &     1.78 &     1.42 &     1.25 &       390690  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] &      0.1 &    184.6 &     2.06 &     1.70 &     1.47 &       393960  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.03 &    161.1 &     1.56 &     1.13 &     1.49 &       390607  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A] &     0.04 &     22.9 &     1.28 &     0.87 &     1.26 &       184702  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.01 &     42.3 &     1.08 &     0.59 &     1.22 &       353450  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.02 &     45.8 &     1.18 &     0.69 &     1.35 &       195974  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] &     0.02 &     19.0 &     2.44 &     1.87 &     1.43 &       444757  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] &     0.01 &    134.1 &     3.32 &     2.84 &     2.21 &       776702  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] &     0.02 &    271.7 &     2.75 &     2.02 &     2.13 &       518092  \tabularnewline
;;        \hline


;;        $T{\scriptstyle_{e, avg}}$ [eV]\tnote{a} &     2.43 &     58.8 &     12.2 &     11.9 &      3.2 &       820057  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV]\tnote{a} &     2.29 &     77.2 &     13.2 &     12.8 &      3.9 &       820057  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV]\tnote{a} &     2.49 &     58.6 &     11.7 &     11.4 &      3.0 &       820057  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV]\tnote{a} &     0.16 &    940.6 &     12.7 &      8.6 &     14.1 &      1095314  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV]\tnote{a} &     0.05 &   1192.7 &     12.5 &      7.5 &     16.9 &      1124159  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV]\tnote{a} &     0.05 &   1196.1 &     15.4 &     10.7 &     18.0 &      1103884  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV]\tnote{a} &     0.45 &    964.7 &     23.9 &     10.8 &     31.7 &       476255  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV]\tnote{a} &     0.20 &   1198.6 &     40.6 &     21.4 &     52.2 &       883543  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV]\tnote{a} &     0.23 &   1192.2 &     37.3 &     14.8 &     55.9 &       564208  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{e, avg}}$ [eV] &     2.71 &     52.7 &     12.1 &     11.9 &      3.0 &       760815  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV] &     2.59 &     65.2 &     13.1 &     12.8 &      3.7 &       760815  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV] &     2.74 &     46.9 &     11.6 &     11.3 &      2.8 &       760815  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV] &     0.16 &    865.8 &     12.4 &      8.6 &     13.1 &      1001957  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV] &     0.06 &   1192.7 &     12.2 &      7.5 &     15.9 &      1028552  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV] &     0.05 &   1173.6 &     15.1 &     10.8 &     16.8 &      1009757  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV] &     0.49 &    923.3 &     23.1 &     10.5 &     29.3 &       428536  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV] &     0.20 &   1198.6 &     39.8 &     21.3 &     50.4 &       804268  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV] &     0.23 &   1192.2 &     37.3 &     14.9 &     55.4 &       512190  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{e, avg}}$ [eV] &     2.43 &     52.4 &     11.1 &     10.4 &      4.3 &        29389  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV] &     2.29 &     77.2 &     12.1 &     11.1 &      5.4 &        29389  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV] &     2.49 &     52.0 &     10.6 &     10.0 &      3.8 &        29389  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV] &     0.39 &    549.5 &      7.7 &      4.2 &     13.5 &        72530  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV] &     0.06 &    719.6 &      7.6 &      3.9 &     15.1 &        73349  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV] &     0.05 &   1196.1 &      9.7 &      4.4 &     21.3 &        73149  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV] &     0.49 &    525.1 &     13.9 &      5.8 &     22.3 &        43343  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV] &     0.25 &   1169.4 &     22.5 &      8.4 &     41.3 &        63344  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV] &     0.23 &   1135.5 &     17.7 &      5.8 &     42.1 &        45878  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{e, avg}}$ [eV] &     2.71 &     58.8 &     12.2 &     11.9 &      3.1 &       790668  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV] &     2.59 &     65.2 &     13.2 &     12.9 &      3.8 &       790668  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV] &     2.74 &     58.6 &     11.7 &     11.4 &      2.9 &       790668  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV] &     0.16 &    940.6 &     13.0 &      9.0 &     14.1 &      1022784  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV] &     0.05 &   1192.7 &     12.9 &      7.9 &     16.9 &      1050810  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV] &     0.05 &   1128.5 &     15.8 &     11.3 &     17.7 &      1030735  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV] &     0.45 &    964.7 &     24.9 &     11.6 &     32.3 &       432912  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV] &     0.20 &   1198.6 &     42.0 &     23.2 &     52.7 &       820199  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV] &     0.23 &   1192.2 &     39.0 &     16.6 &     56.6 &       518330  \tabularnewline
;;        \hline
;;  Fast vs. Slow Wind
;;        $T{\scriptstyle_{e, avg}}$ [eV] &     3.16 &     53.9 &     12.2 &     11.8 &      3.1 &        60700  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV] &     3.43 &     60.5 &     14.0 &     13.5 &      3.8 &        60700  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV] &     2.83 &     50.6 &     11.3 &     10.9 &      3.0 &        60700  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV] &     0.41 &    940.6 &     28.8 &     24.3 &     23.5 &       170001  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV] &     0.06 &   1192.7 &     30.2 &     24.1 &     28.7 &       190139  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV] &     0.05 &   1196.1 &     32.7 &     27.5 &     29.4 &       173564  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV] &     0.72 &    964.7 &     55.4 &     31.9 &     65.4 &        31498  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV] &     0.25 &   1193.5 &    102.6 &     90.1 &     84.1 &       106751  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV] &     0.33 &   1192.2 &     95.2 &     65.3 &    118.0 &        45993  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{e, avg}}$ [eV] &     2.43 &     52.7 &     11.3 &     11.0 &      2.9 &       394244  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV] &     2.29 &     64.2 &     11.8 &     11.4 &      3.3 &       394244  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV] &     2.49 &     46.9 &     11.0 &     10.8 &      2.8 &       394244  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV] &     0.16 &    578.4 &      9.7 &      7.5 &      8.7 &       925313  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV] &     0.05 &    911.1 &      8.9 &      6.4 &      9.9 &       934011  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV] &     0.05 &   1173.6 &     12.2 &      9.2 &     12.6 &       930320  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV] &     0.45 &    923.3 &     21.6 &     10.2 &     26.4 &       444757  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV] &     0.20 &   1198.6 &     32.1 &     17.1 &     39.1 &       776792  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV] &     0.23 &   1167.9 &     32.2 &     13.4 &     42.9 &       518215  \tabularnewline
;;        \hline











































































