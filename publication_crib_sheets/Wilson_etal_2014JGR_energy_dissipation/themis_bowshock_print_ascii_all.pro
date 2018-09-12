;;----------------------------------------------------------------------------------------
;; => Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init

;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
;;  2009-07-13 [1 Crossing]
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_b_data_2009-07-13_batch.pro

;;-------------------------------------
;;  2009-07-21 [1 Crossing]
;;-------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_c_data_2009-07-21_batch.pro

;;-------------------------------------
;;  2009-07-23 [3 Crossings]
;;-------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_c_data_2009-07-23_batch.pro

;;-------------------------------------
;;  2009-09-05 [3 Crossings]
;;-------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_c_data_2009-09-05_batch.pro

;;-------------------------------------
;;  2009-09-26 [1 Crossing]
;;-------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_a_data_2009-09-26_batch.pro

;;-------------------------------------
;;  2011-10-24 [2 Crossings]
;;-------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_e_data_2011-10-24_batch.pro




;;----------------------------------------------------------------------------------------
;;  Define some constants used below
;;----------------------------------------------------------------------------------------
nsm            = 10L                     ;;  # of points to smooth Jo
upsample       = 0                       ;;  If set, routines upsample Jo to ∂E timesteps
upsample       = 1                       ;;  If set, routines upsample Jo to ∂E timesteps

;;----------------------------------------------------------------------------------------
;;  Print values to ASCII file
;;    [Note:  Merge files for the same crossing by hand]
;;----------------------------------------------------------------------------------------
;;-------------------------------------
;;  2009-07-13 [1 Crossing]
;;-------------------------------------
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['08:59:45.440','08:59:48.290']),/NAN)
magf_up        = [    -3.04437196d0,     1.33834842d0,    -1.48370236d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [0L]
fsuffx         = '_1st-BS-Crossing-0'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

gint           = [1L]
fsuffx         = '_1st-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

;;-------------------------------------
;;  2009-07-21 [1 Crossing]
;;-------------------------------------
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['19:24:49.530','19:24:53.440']),/NAN)
magf_up        = [     3.66872966d0,     7.62505311d0,     0.87879413d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [4L]
fsuffx         = '_1st-BS-Crossing-0'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

gint           = [5L]
fsuffx         = '_1st-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

;;-------------------------------------
;;  2009-07-23 [3 Crossings]
;;-------------------------------------
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:04:47.030','18:04:58.920']),/NAN)
magf_up        = [     0.18061268d0,     0.28357940d0,    -5.72393987d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [0L]
fsuffx         = '_1st-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)
;; => ASCII [2nd Shock]
nif_suffx      = '-RHS02'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:07:07.340','18:07:08.100']),/NAN)
magf_up        = [    -0.38116612d0,    -0.03737344d0,    -6.40433103d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [1L]
fsuffx         = '_2nd-BS-Crossing-0'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

gint           = [2L]
fsuffx         = '_2nd-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

;; => ASCII [3rd Shock]
nif_suffx      = '-RHS03'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:24:24.910','18:24:49.450']),/NAN)
magf_up        = [     3.60687581d0,    -5.25424805d0,     0.84648225d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

fsuffx         = '_3rd-BS-Crossing-0'
gint           = [5L]
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

gint           = [6L]
fsuffx         = '_3rd-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)


;;-------------------------------------
;;  2009-09-05 [3 Crossings]
;;-------------------------------------
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['16:11:32.910','16:11:33.800']),/NAN)
magf_up        = [ 0.61279484d0,-0.57618533d0,-0.29177513d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [0L]
fsuffx         = '_1st-BS-Crossing-0'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

gint           = [1L]
fsuffx         = '_1st-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

;; => ASCII [2nd Shock]
nif_suffx      = '-RHS02'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['16:37:58.272','16:37:59.000']),/NAN)
magf_up        = [-1.07332678d0,-1.06251983d0,-0.23281553d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [3L]
fsuffx         = '_2nd-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

;; => ASCII [3rd Shock]
nif_suffx      = '-RHS03'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['16:54:31.240','16:54:33.120']),/NAN)
magf_up        = [-0.27134223d0,-1.27554421d0,-0.27749658d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [5L]
fsuffx         = '_3rd-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)


;;-------------------------------------
;;  2009-09-26 [1 Crossing]
;;-------------------------------------
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['15:53:09.911','15:53:10.249']),/NAN)
magf_up        = [     2.23681456d0,     0.21691634d0,    -2.02624458d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [0L]
fsuffx         = '_1st-BS-Crossing-0'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

gint           = [1L]
fsuffx         = '_1st-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)


;;-------------------------------------
;;  2011-10-24 [2 Crossings]
;;-------------------------------------
;; => ASCII [1st Shock]
nif_suffx      = '-RHS01'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['18:31:56.880','18:31:57.290']),/NAN)
magf_up        = [     6.31290579d0,    -2.30937529d0,    -9.69084620d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [2L]
fsuffx         = '_1st-BS-Crossing-0'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

gint           = [3L]
fsuffx         = '_1st-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

;; => ASCII [2nd Shock]
nif_suffx      = '-RHS02'
t_ramp         = MEAN(time_double(tdate[0]+'/'+['23:28:14.596','23:28:16.086']),/NAN)
magf_up        = [     4.22465752d0,    15.18630403d0,    -9.22152162d0]
bo_up_avg      = SQRT(TOTAL(magf_up^2,/NAN))

gint           = [4L]
fsuffx         = '_2nd-BS-Crossing-0'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)

gint           = [5L]
fsuffx         = '_2nd-BS-Crossing'
.compile temp_write_j_E_S_corr
test           = temp_write_j_E_S_corr(PROBE=sc[0],TRANGE=tr_jj,TRAMP=t_ramp[0],   $
                                       NSM=nsm,GINT=gint,NIF_SUFFX=nif_suffx,      $
                                       FILE_SUFFX=fsuffx[0],BO_UP_AVG=bo_up_avg[0],$
                                       UPSAMPLE=upsample)














;;-------------------------------------
;;  2009-07-13 [1 Crossing]
;;-------------------------------------


;;-------------------------------------
;;  2009-07-21 [1 Crossing]
;;-------------------------------------


;;-------------------------------------
;;  2009-07-23 [3 Crossings]
;;-------------------------------------


;;-------------------------------------
;;  2009-09-26 [1 Crossing]
;;-------------------------------------


;;-------------------------------------
;;  2011-10-24 [2 Crossings]
;;-------------------------------------
