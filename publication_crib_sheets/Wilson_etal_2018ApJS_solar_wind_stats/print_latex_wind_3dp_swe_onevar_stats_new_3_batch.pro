;;  @/Users/lbwilson/Desktop/temp_idl/solar_wind_stats/print_latex_wind_3dp_swe_onevar_stats_new_3_batch.pro
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
      nf        = N_ELEMENTS(y)                                                                  & $
      x         = TEMPORARY(x[y])                                                                & $
      stat0     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),N_ELEMENTS(y)]  & $
      ind25     = WHERE(x LE stat0[3],cntlow)                                                    & $
      ind75     = WHERE(x GT stat0[3],cntupp)                                                    & $
      qtr25     = MEDIAN(x[ind25])                                                               & $
      qtr75     = MEDIAN(x[ind75])                                                               & $
      stats     = [stat0[0:1],stat0[3],qtr25[0],qtr75[0],nf[0]]                                  & $
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
      nf        = N_ELEMENTS(y)                                                                  & $
      x         = TEMPORARY(x[y])                                                                & $
      stat0     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),N_ELEMENTS(y)]  & $
      ind25     = WHERE(x LE stat0[3],cntlow)                                                    & $
      ind75     = WHERE(x GT stat0[3],cntupp)                                                    & $
      qtr25     = MEDIAN(x[ind25])                                                               & $
      qtr75     = MEDIAN(x[ind75])                                                               & $
      stats     = [stat0[0:1],stat0[3],qtr25[0],qtr75[0],nf[0]]                                  & $
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
      nf        = N_ELEMENTS(y)                                                                  & $
      x         = TEMPORARY(x[y])                                                                & $
      stat0     = [MIN(x,/NAN),MAX(x,/NAN),MEAN(x,/NAN),MEDIAN(x),STDDEV(x,/NAN),N_ELEMENTS(y)]  & $
      ind25     = WHERE(x LE stat0[3],cntlow)                                                    & $
      ind75     = WHERE(x GT stat0[3],cntupp)                                                    & $
      qtr25     = MEDIAN(x[ind25])                                                               & $
      qtr75     = MEDIAN(x[ind75])                                                               & $
      stats     = [stat0[0:1],stat0[3],qtr25[0],qtr75[0],nf[0]]                                  & $
      PRINT,str_pref0[0],stats,FORMAT=texform[0]                                                 & $
    ENDFOR                                                                                       & $
    PRINT,';;  ',hline_tex[0]




;;        $\beta{\scriptstyle_{e, avg}}$ [N/A]\tnote{a} & 0.006 & 8870 & 1.09 & 0.64 & 1.99 & 820056  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A]\tnote{a} & 0.007 & 8914 & 1.17 & 0.71 & 2.06 & 820056  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A]\tnote{a} & 0.005 & 8848 & 1.05 & 0.60 & 1.96 & 820056  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A]\tnote{a} & 0.001 & 4568 & 1.05 & 0.54 & 1.77 & 1095171  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A]\tnote{a} & 4.e-05 & 4391 & 0.92 & 0.47 & 1.62 & 1124001  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A]\tnote{a} & 6.e-05 & 4923 & 1.29 & 0.62 & 2.18 & 1103741  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A]\tnote{a} & 5.e-05 & 612 & 0.05 & 0.02 & 0.17 & 476129  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A]\tnote{a} & 5.e-05 & 594 & 0.08 & 0.02 & 0.22 & 883409  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A]\tnote{a} & 2.e-05 & 647 & 0.07 & 0.02 & 0.27 & 564081  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{e, avg}}$ [N/A] & 0.006 & 8870 & 1.11 & 0.65 & 2.01 & 760814  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A] & 0.007 & 8914 & 1.19 & 0.73 & 2.07 & 760814  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A] & 0.005 & 8848 & 1.07 & 0.61 & 1.98 & 760814  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A] & 0.001 & 4568 & 1.07 & 0.57 & 1.78 & 1001816  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A] & 8.e-05 & 4391 & 0.94 & 0.49 & 1.63 & 1028396  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A] & 0.0001 & 4923 & 1.32 & 0.66 & 2.20 & 1009616  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A] & 5.e-05 & 295 & 0.05 & 0.02 & 0.18 & 428411  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A] & 8.e-05 & 373 & 0.08 & 0.02 & 0.22 & 804136  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A] & 2.e-05 & 415 & 0.07 & 0.02 & 0.28 & 512064  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{e, avg}}$ [N/A] & 0.006 & 37 & 0.40 & 0.23 & 0.62 & 29389  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A] & 0.007 & 38 & 0.42 & 0.25 & 0.66 & 29389  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A] & 0.005 & 36 & 0.38 & 0.22 & 0.60 & 29389  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A] & 0.001 & 159 & 0.13 & 0.05 & 0.31 & 72530  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A] & 4.e-05 & 157 & 0.12 & 0.04 & 0.29 & 73349  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A] & 6.e-05 & 164 & 0.13 & 0.05 & 0.35 & 73149  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A] & 5.e-05 & 29 & 0.01 & 0.00 & 0.02 & 43343  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A] & 5.e-05 & 49 & 0.01 & 0.00 & 0.03 & 63344  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A] & 2.e-05 & 32 & 0.01 & 0.00 & 0.02 & 45878  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{e, avg}}$ [N/A] & 0.02 & 8870 & 1.13 & 0.67 & 2.04 & 790667  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A] & 0.03 & 8914 & 1.21 & 0.74 & 2.10 & 790667  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A] & 0.02 & 8848 & 1.09 & 0.63 & 2.01 & 790667  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A] & 0.002 & 4568 & 1.11 & 0.63 & 1.85 & 1022641  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A] & 0.0003 & 4391 & 0.98 & 0.54 & 1.69 & 1050652  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A] & 0.0001 & 4923 & 1.38 & 0.73 & 2.27 & 1030592  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A] & 0.0002 & 612 & 0.06 & 0.02 & 0.19 & 432786  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A] & 5.e-05 & 594 & 0.09 & 0.03 & 0.23 & 820065  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A] & 6.e-05 & 647 & 0.09 & 0.02 & 0.29 & 518203  \tabularnewline
;;        \hline
;;  Fast vs. Slow Wind
;;        $\beta{\scriptstyle_{e, avg}}$ [N/A] & 0.02 & 680 & 0.73 & 0.51 & 1.08 & 60700  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A] & 0.02 & 710 & 0.84 & 0.61 & 1.20 & 60700  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A] & 0.02 & 665 & 0.67 & 0.46 & 1.02 & 60700  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A] & 0.001 & 2347 & 1.25 & 0.70 & 1.95 & 169997  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A] & 4.e-05 & 2198 & 1.21 & 0.68 & 1.89 & 190122  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A] & 6.e-05 & 2646 & 1.40 & 0.71 & 2.28 & 173560  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A] & 0.0002 & 612 & 0.08 & 0.02 & 0.28 & 31497  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A] & 5.e-05 & 594 & 0.21 & 0.10 & 0.37 & 106749  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A] & 8.e-05 & 647 & 0.17 & 0.02 & 0.50 & 45991  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{e, avg}}$ [N/A] & 0.01 & 4329 & 1.61 & 0.94 & 2.88 & 394244  \tabularnewline
;;        $\beta{\scriptstyle_{e, \perp}}$ [N/A] & 0.01 & 4332 & 1.67 & 1.00 & 2.93 & 394244  \tabularnewline
;;        $\beta{\scriptstyle_{e, \parallel}}$ [N/A] & 0.01 & 4328 & 1.58 & 0.91 & 2.85 & 394244  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{p, avg}}$ [N/A] & 0.001 & 4568 & 1.01 & 0.52 & 1.73 & 925174  \tabularnewline
;;        $\beta{\scriptstyle_{p, \perp}}$ [N/A] & 0.0006 & 4391 & 0.87 & 0.45 & 1.55 & 933870  \tabularnewline
;;        $\beta{\scriptstyle_{p, \parallel}}$ [N/A] & 0.0001 & 4923 & 1.27 & 0.61 & 2.17 & 930181  \tabularnewline
;;        \hline
;;        $\beta{\scriptstyle_{\alpha, avg}}$ [N/A] & 5.e-05 & 295 & 0.05 & 0.02 & 0.17 & 444632  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \perp}}$ [N/A] & 5.e-05 & 373 & 0.07 & 0.02 & 0.19 & 776660  \tabularnewline
;;        $\beta{\scriptstyle_{\alpha, \parallel}}$ [N/A] & 2.e-05 & 415 & 0.07 & 0.02 & 0.25 & 518090  \tabularnewline
;;        \hline


;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A]\tnote{a} & 0.07 & 25.3 & 1.27 & 0.78 & 2.14 & 445801  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A]\tnote{a} & 0.03 & 184.6 & 1.51 & 0.90 & 2.49 & 454588  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A]\tnote{a} & 0.02 & 161.1 & 1.01 & 0.60 & 1.83 & 445732  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A]\tnote{a} & 0.02 & 22.9 & 0.82 & 0.32 & 1.78 & 193704  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A]\tnote{a} & 0.01 & 42.3 & 0.48 & 0.21 & 1.41 & 393745  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A]\tnote{a} & 0.009 & 45.8 & 0.64 & 0.23 & 1.62 & 207313  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A]\tnote{a} & 0.02 & 19.0 & 1.94 & 1.35 & 3.49 & 476255  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A]\tnote{a} & 0.004 & 200.0 & 3.16 & 1.63 & 4.79 & 883427  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A]\tnote{a} & 0.02 & 271.7 & 2.11 & 1.33 & 3.87 & 564072  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] & 0.07 & 25.3 & 1.27 & 0.78 & 2.14 & 412947  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.06 & 184.6 & 1.52 & 0.91 & 2.51 & 421080  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.02 & 161.1 & 1.00 & 0.60 & 1.82 & 412917  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A] & 0.02 & 22.9 & 0.82 & 0.32 & 1.80 & 177265  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.01 & 42.3 & 0.48 & 0.21 & 1.42 & 363851  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.009 & 45.8 & 0.64 & 0.23 & 1.63 & 190413  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] & 0.02 & 19.0 & 1.91 & 1.33 & 3.48 & 428536  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.01 & 200.0 & 3.16 & 1.62 & 4.77 & 804166  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.02 & 271.7 & 2.12 & 1.32 & 3.92 & 512077  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] & 0.09 & 25.3 & 2.06 & 1.27 & 3.33 & 18203  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.1 & 79.4 & 2.35 & 1.46 & 3.76 & 18356  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.03 & 161.1 & 1.87 & 1.09 & 3.13 & 18186  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A] & 0.04 & 22.9 & 1.45 & 0.60 & 2.65 & 10077  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.02 & 42.3 & 1.02 & 0.38 & 2.35 & 16643  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.02 & 30.0 & 1.34 & 0.58 & 2.55 & 10290  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] & 0.02 & 18.3 & 1.78 & 1.34 & 2.80 & 43343  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.004 & 79.8 & 2.27 & 1.46 & 4.19 & 63318  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.04 & 40.3 & 1.66 & 1.22 & 2.58 & 45837  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] & 0.07 & 23.2 & 1.25 & 0.77 & 2.09 & 427598  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.03 & 184.6 & 1.49 & 0.89 & 2.45 & 436232  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.02 & 129.3 & 0.99 & 0.59 & 1.77 & 427546  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A] & 0.02 & 17.2 & 0.79 & 0.32 & 1.74 & 183627  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.01 & 37.6 & 0.47 & 0.21 & 1.37 & 377102  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.009 & 45.8 & 0.61 & 0.22 & 1.57 & 197023  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] & 0.2 & 19.0 & 1.96 & 1.35 & 3.55 & 432912  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.01 & 200.0 & 3.24 & 1.65 & 4.81 & 820109  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.02 & 271.7 & 2.18 & 1.34 & 3.97 & 518235  \tabularnewline
;;        \hline
;;  Fast vs. Slow Wind
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] & 0.07 & 17.3 & 0.49 & 0.36 & 0.66 & 55111  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.03 & 86.7 & 0.58 & 0.41 & 0.81 & 60628  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.02 & 68.4 & 0.39 & 0.29 & 0.54 & 55125  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A] & 0.02 & 9.5 & 0.19 & 0.12 & 0.45 & 9002  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.01 & 42.1 & 0.14 & 0.10 & 0.20 & 40295  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.009 & 26.7 & 0.14 & 0.09 & 0.36 & 11339  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] & 0.03 & 16.4 & 3.18 & 1.98 & 4.49 & 31498  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.004 & 200.0 & 4.45 & 3.43 & 5.40 & 106725  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.04 & 58.9 & 3.31 & 1.89 & 4.83 & 45980  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] & 0.1 & 25.3 & 1.42 & 0.92 & 2.28 & 390690  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.1 & 184.6 & 1.70 & 1.08 & 2.66 & 393960  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.03 & 161.1 & 1.13 & 0.71 & 1.98 & 390607  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{avg}}$ [N/A] & 0.04 & 22.9 & 0.87 & 0.35 & 1.83 & 184702  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.01 & 42.3 & 0.59 & 0.25 & 1.55 & 353450  \tabularnewline
;;        $\left(T{\scriptstyle_{e}}/T{\scriptstyle_{\alpha}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.02 & 45.8 & 0.69 & 0.25 & 1.68 & 195974  \tabularnewline
;;        \hline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{avg}}$ [N/A] & 0.02 & 19.0 & 1.87 & 1.33 & 3.37 & 444757  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\perp}}$ [N/A] & 0.01 & 134.1 & 2.84 & 1.55 & 4.64 & 776702  \tabularnewline
;;        $\left(T{\scriptstyle_{\alpha}}/T{\scriptstyle_{p}}\right){\scriptstyle_{\parallel}}$ [N/A] & 0.02 & 271.7 & 2.02 & 1.30 & 3.75 & 518092  \tabularnewline
;;        \hline


;;        $T{\scriptstyle_{e, avg}}$ [eV]\tnote{a} & 2.43 & 58.8 & 11.9 & 10.0 & 14.0 & 820057  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV]\tnote{a} & 2.29 & 77.2 & 12.8 & 10.5 & 15.4 & 820057  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV]\tnote{a} & 2.49 & 58.6 & 11.4 & 9.7 & 13.4 & 820057  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV]\tnote{a} & 0.16 & 940.6 & 8.6 & 4.7 & 15.9 & 1095314  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV]\tnote{a} & 0.05 & 1192.7 & 7.5 & 4.2 & 14.7 & 1124159  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV]\tnote{a} & 0.05 & 1196.1 & 10.7 & 5.2 & 20.0 & 1103884  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV]\tnote{a} & 0.45 & 964.7 & 10.8 & 4.9 & 31.6 & 476255  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV]\tnote{a} & 0.20 & 1198.6 & 21.4 & 6.5 & 58.0 & 883543  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV]\tnote{a} & 0.23 & 1192.2 & 14.8 & 5.4 & 50.7 & 564208  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{e, avg}}$ [eV] & 2.71 & 52.7 & 11.9 & 10.0 & 14.0 & 760815  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV] & 2.59 & 65.2 & 12.8 & 10.5 & 15.4 & 760815  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV] & 2.74 & 46.9 & 11.3 & 9.7 & 13.3 & 760815  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV] & 0.16 & 865.8 & 8.6 & 4.7 & 15.8 & 1001957  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV] & 0.06 & 1192.7 & 7.5 & 4.2 & 14.6 & 1028552  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV] & 0.05 & 1173.6 & 10.8 & 5.2 & 19.9 & 1009757  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV] & 0.49 & 923.3 & 10.5 & 4.8 & 31.1 & 428536  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV] & 0.20 & 1198.6 & 21.3 & 6.4 & 57.5 & 804268  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV] & 0.23 & 1192.2 & 14.9 & 5.4 & 51.3 & 512190  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{e, avg}}$ [eV] & 2.43 & 52.4 & 10.4 & 8.2 & 13.2 & 29389  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV] & 2.29 & 77.2 & 11.1 & 8.5 & 14.5 & 29389  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV] & 2.49 & 52.0 & 10.0 & 7.9 & 12.4 & 29389  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV] & 0.39 & 549.5 & 4.2 & 2.5 & 7.5 & 72530  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV] & 0.06 & 719.6 & 3.9 & 2.3 & 6.9 & 73349  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV] & 0.05 & 1196.1 & 4.4 & 2.5 & 8.9 & 73149  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV] & 0.49 & 525.1 & 5.8 & 3.1 & 14.5 & 43343  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV] & 0.25 & 1169.4 & 8.4 & 3.7 & 23.8 & 63344  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV] & 0.23 & 1135.5 & 5.8 & 3.0 & 14.2 & 45878  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{e, avg}}$ [eV] & 2.71 & 58.8 & 11.9 & 10.1 & 14.0 & 790668  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV] & 2.59 & 65.2 & 12.9 & 10.5 & 15.5 & 790668  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV] & 2.74 & 58.6 & 11.4 & 9.7 & 13.4 & 790668  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV] & 0.16 & 940.6 & 9.0 & 4.9 & 16.4 & 1022784  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV] & 0.05 & 1192.7 & 7.9 & 4.4 & 15.2 & 1050810  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV] & 0.05 & 1128.5 & 11.3 & 5.6 & 20.5 & 1030735  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV] & 0.45 & 964.7 & 11.6 & 5.2 & 33.4 & 432912  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV] & 0.20 & 1198.6 & 23.2 & 6.9 & 60.3 & 820199  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV] & 0.23 & 1192.2 & 16.6 & 5.8 & 53.9 & 518330  \tabularnewline
;;        \hline
;;  Fast vs. Slow Wind
;;        $T{\scriptstyle_{e, avg}}$ [eV] & 3.16 & 53.9 & 11.8 & 10.3 & 13.6 & 60700  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV] & 3.43 & 60.5 & 13.5 & 11.7 & 15.8 & 60700  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV] & 2.83 & 50.6 & 10.9 & 9.4 & 12.6 & 60700  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV] & 0.41 & 940.6 & 24.3 & 16.5 & 35.1 & 170001  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV] & 0.06 & 1192.7 & 24.1 & 15.6 & 36.3 & 190139  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV] & 0.05 & 1196.1 & 27.5 & 17.7 & 39.5 & 173564  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV] & 0.72 & 964.7 & 31.9 & 8.7 & 80.1 & 31498  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV] & 0.25 & 1193.5 & 90.1 & 51.3 & 134.2 & 106751  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV] & 0.33 & 1192.2 & 65.3 & 12.4 & 130.6 & 45993  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{e, avg}}$ [eV] & 2.43 & 52.7 & 11.0 & 9.3 & 13.1 & 394244  \tabularnewline
;;        $T{\scriptstyle_{e, \perp}}$ [eV] & 2.29 & 64.2 & 11.4 & 9.5 & 13.7 & 394244  \tabularnewline
;;        $T{\scriptstyle_{e, \parallel}}$ [eV] & 2.49 & 46.9 & 10.8 & 9.1 & 12.7 & 394244  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{p, avg}}$ [eV] & 0.16 & 578.4 & 7.5 & 4.3 & 12.6 & 925313  \tabularnewline
;;        $T{\scriptstyle_{p, \perp}}$ [eV] & 0.05 & 911.1 & 6.4 & 3.9 & 11.0 & 934011  \tabularnewline
;;        $T{\scriptstyle_{p, \parallel}}$ [eV] & 0.05 & 1173.6 & 9.2 & 4.7 & 16.2 & 930320  \tabularnewline
;;        \hline
;;        $T{\scriptstyle_{\alpha, avg}}$ [eV] & 0.45 & 923.3 & 10.2 & 4.8 & 29.3 & 444757  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \perp}}$ [eV] & 0.20 & 1198.6 & 17.1 & 5.9 & 46.2 & 776792  \tabularnewline
;;        $T{\scriptstyle_{\alpha, \parallel}}$ [eV] & 0.23 & 1167.9 & 13.4 & 5.2 & 45.2 & 518215  \tabularnewline
;;        \hline
