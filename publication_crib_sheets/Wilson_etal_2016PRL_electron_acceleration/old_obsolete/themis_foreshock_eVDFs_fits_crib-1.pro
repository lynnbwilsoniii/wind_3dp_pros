;;----------------------------------------------------------------------------------------
;;  Constants
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
R_E            = 6.37814d3            ;;  Earth's Equatorial Radius [km]
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;----------------------------------------------------------------------------------------
;;  Compile relevant routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;;  Potential Interesting VDFs:  Date/Time and Probe
;;----------------------------------------------------------------------------------------
;;  Probe A

;;  Probe B

probe          = 'b'
tdate          = '2008-07-14'
date           = '071408'

probe          = 'b'
tdate          = '2008-07-22'
date           = '072208'

probe          = 'b'
tdate          = '2008-07-26'
date           = '072608'

probe          = 'b'
tdate          = '2008-07-30'
date           = '073008'

probe          = 'b'
tdate          = '2008-08-07'
date           = '080708'

probe          = 'b'
tdate          = '2008-08-11'
date           = '081108'

probe          = 'b'
tdate          = '2008-08-23'
date           = '082308'

probe          = 'b'
tdate          = '2009-07-13'
date           = '071309'

;;  Probe C
;probe          = 'c'
;tdate          = '2008-06-21'
;date           = '062108'

;probe          = 'c'
;tdate          = '2008-06-26'
;date           = '062608'

probe          = 'c'
tdate          = '2008-07-14'
date           = '071408'

;probe          = 'c'
;tdate          = '2008-07-15'
;date           = '071508'

;probe          = 'c'
;tdate          = '2008-08-11'
;date           = '081108'

probe          = 'c'
tdate          = '2008-08-12'
date           = '081208'

probe          = 'c'
tdate          = '2008-08-19'
date           = '081908'

;probe          = 'c'
;tdate          = '2008-08-22'
;date           = '082208'

probe          = 'c'
tdate          = '2008-09-08'
date           = '090808'

;probe          = 'c'
;tdate          = '2008-09-09'
;date           = '090908'

probe          = 'c'
tdate          = '2008-09-16'
date           = '091608'

probe          = 'c'
tdate          = '2008-10-03'
date           = '100308'

;probe          = 'c'
;tdate          = '2008-10-06'
;date           = '100608'

probe          = 'c'
tdate          = '2008-10-09'
date           = '100908'

probe          = 'c'
tdate          = '2008-10-12'
date           = '101208'

;probe          = 'c'
;tdate          = '2008-10-20'
;date           = '102008'

;probe          = 'c'
;tdate          = '2008-10-22'
;date           = '102208'

probe          = 'c'
tdate          = '2008-10-29'
date           = '102908'

;probe          = 'c'
;tdate          = '2009-07-12'
;date           = '071209'

;probe          = 'c'
;tdate          = '2009-07-15'
;date           = '071509'

;probe          = 'c'
;tdate          = '2009-07-16'
;date           = '071609'

probe          = 'c'
tdate          = '2009-07-25'
date           = '072509'

;probe          = 'c'
;tdate          = '2009-07-26'
;date           = '072609'

;probe          = 'c'
;tdate          = '2009-09-06'
;date           = '090609'

;probe          = 'c'
;tdate          = '2009-10-02'
;date           = '100209'

;probe          = 'c'
;tdate          = '2009-10-05'
;date           = '100509'

;probe          = 'c'
;tdate          = '2009-10-13'
;date           = '101309'

;;  Probe D

;;  Probe E

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_foreshock_eVDFs_batch.pro
tlimit,/full

;;----------------------------------------------------------------------------------------
;;  Get fgh data intervals
;;----------------------------------------------------------------------------------------
get_data,scpref[0]+'fgh_gse',DATA=temp
;;  Define parameters
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN tstart = time_double(tdate[0]+'/14:59:00.000')
IF (N_ELEMENTS(tstart) EQ 0)  THEN tstart = time_double(tdate[0]+'/00:00:00.000')
fgh_t          = temp.X[WHERE(temp.X GT tstart[0])]
test           = t_interval_find(fgh_t,GAP_THRESH=1d0/32d0,/NAN,/MERGE,THR_MERGE=1)
fgh_st         = fgh_t[test[*,0]]
fgh_en         = fgh_t[test[*,1]]
;;  Define range of eVDFs to plot and save
all_e_st       = dat_egse.TIME
all_e_en       = dat_egse.END_TIME
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'b') THEN start_t = time_double(tdate[0]+'/'+['16:35','17:37']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'b') THEN end___t = time_double(tdate[0]+'/'+['17:05','17:47']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-07-22' AND sc[0] EQ 'b') THEN start_t = time_double(tdate[0]+'/'+['12:00']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-07-22' AND sc[0] EQ 'b') THEN end___t = time_double(tdate[0]+'/'+['20:00']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-07-26' AND sc[0] EQ 'b') THEN start_t = time_double(tdate[0]+'/'+['16:00']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-07-26' AND sc[0] EQ 'b') THEN end___t = time_double(tdate[0]+'/'+['23:59']+':59.999') + 6d1*2d0
IF (tdate[0] EQ '2008-07-30' AND sc[0] EQ 'b') THEN start_t = time_double(tdate[0]+'/'+['12:00']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-07-30' AND sc[0] EQ 'b') THEN end___t = time_double(tdate[0]+'/'+['22:00']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-08-07' AND sc[0] EQ 'b') THEN start_t = time_double(tdate[0]+'/'+['12:00']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-08-07' AND sc[0] EQ 'b') THEN end___t = time_double(tdate[0]+'/'+['20:00']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-08-11' AND sc[0] EQ 'b') THEN start_t = time_double(tdate[0]+'/'+['12:00']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-08-11' AND sc[0] EQ 'b') THEN end___t = time_double(tdate[0]+'/'+['18:00']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-08-23' AND sc[0] EQ 'b') THEN start_t = time_double(tdate[0]+'/'+['12:00']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-08-23' AND sc[0] EQ 'b') THEN end___t = time_double(tdate[0]+'/'+['21:00']+':00.000') + 6d1*2d0

IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+['14:59','20:03','21:57','23:25']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-07-14' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+['15:01','20:05','21:59','23:27']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+['01:05']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-08-12' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+['01:07']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-08-19' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+['07:53','12:49','23:38']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-08-19' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+['07:55','12:51','23:40']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-09-08' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+['10:56','17:01','20:26']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-09-08' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+['10:58','17:03','20:28']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+['02:14']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-09-16' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+['02:16']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-10-03' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+['19:34']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-10-03' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+['19:36']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-10-09' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+['23:30']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-10-09' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+['23:32']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2008-10-12' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+['11:01']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-10-12' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+['11:03']+':00.000') + 6d1*2d0


IF (tdate[0] EQ '2008-10-29' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+['22:13']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2008-10-29' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+['22:15']+':00.000') + 6d1*2d0
IF (tdate[0] EQ '2009-07-25' AND sc[0] EQ 'c') THEN start_t = time_double(tdate[0]+'/'+['22:30']+':00.000') - 6d1*2d0
IF (tdate[0] EQ '2009-07-25' AND sc[0] EQ 'c') THEN end___t = time_double(tdate[0]+'/'+['22:32']+':00.000') + 6d1*2d0
IF (N_ELEMENTS(start_t) GE 1) THEN all_st  = [start_t,fgh_st] ELSE all_st  = fgh_st
IF (N_ELEMENTS(end___t) GE 1) THEN all_en  = [end___t,fgh_en] ELSE all_en  = fgh_en

;IF (tdate[0] EQ '2008-07-14') THEN all_st = st_20080714
;IF (tdate[0] EQ '2008-07-14') THEN all_en = en_20080714
;IF (tdate[0] EQ '2008-07-14') THEN all_st = [st_20080714,fgh_st]
;IF (tdate[0] EQ '2008-07-14') THEN all_en = [en_20080714,fgh_en]
;IF (tdate[0] EQ '2008-08-12') THEN all_st = [st_20080812,fgh_st]
;IF (tdate[0] EQ '2008-08-12') THEN all_en = [en_20080812,fgh_en]
;;  Sort
sp             = SORT(all_st)
all_st         = all_st[sp]
all_en         = all_en[sp]
nint           = N_ELEMENTS(all_st)
FOR jj=0L, nint[0] - 1L DO BEGIN                                                        $
  test0 = ((all_e_st GE all_st[jj]) AND (all_e_en LE all_en[jj]))                     & $
;  IF (N_ELEMENTS(atest) EQ 0) THEN atest = test0 ELSE atest = [[atest], [test0]]
  IF (N_ELEMENTS(atest) EQ 0) THEN atest = test0 ELSE atest = test0 OR atest

;;  Clean up
DELVAR,temp,test,test0,all_st,all_en,all_e_st,all_e_en,fgh_t,fgh_st,fgh_en
;;----------------------------------------------------------------------------------------
;;  Plot all electron spectra
;;----------------------------------------------------------------------------------------
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/SCIENCE_PRO/spec3d.pro
.compile /Users/lbwilson/Desktop/temp_idl/wrapper_multi_func_fit.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_fit_evdf_para_perp_anti.pro

;;------------------------------------------------
;;  Setup directory tree for date of interest
;;------------------------------------------------
slash          = get_os_slash()         ;;  '/' for Unix, '\' for Windows
vers           = !VERSION.OS_FAMILY     ;;  e.g., 'unix'
vern           = !VERSION.RELEASE       ;;  e.g., '7.1.1'
test_ll        = (STRMID(FILE_EXPAND_PATH(''),STRLEN(FILE_EXPAND_PATH('')) - 1L,1L) NE slash[0])
;;  Define the current working directory character
;;    e.g., './' [for unix and linux] otherwise guess './' or '.\'
test           = (vern[0] GE '6.0')
IF (test[0]) THEN cwd_char = FILE_DIRNAME('',/MARK_DIRECTORY) ELSE cwd_char = '.'+slash[0]
cur_wdir       = FILE_EXPAND_PATH(cwd_char[0])
IF (test_ll) THEN cur_wdir += slash[0]  ;;  Add slash if necessary
;;  Define new directory
new_dir        = cur_wdir[0]+'eVDF_'+scpref[0]+'Fits_'+tdate[0]+slash[0]
FILE_MKDIR,new_dir[0]
;;  Define sub-directories
all_frames     = ['SW_Frame','SC_Frame']+slash[0]
all_subdirs    = ['Power_Law','Exponential','Power_Law_Exponential']+'_Fits'+slash[0]
all_directs    = new_dir[0]+all_frames[*]
FOR frame=0L, 1L DO FOR s=0L, 2L DO FILE_MKDIR,all_directs[frame]+all_subdirs[s]
all_dirs       = STRARR(N_ELEMENTS(all_frames),N_ELEMENTS(all_subdirs))
all_dirs[0,*]  = new_dir[0]+all_frames[0]+all_subdirs[*]
all_dirs[1,*]  = new_dir[0]+all_frames[1]+all_subdirs[*]

;;  Define range of eVDFs to plot and save
good           = WHERE(atest,gd)
PRINT,';;',gd,' ;;  For '+tdate[0]+', THEMIS-'+scu[0]
;;        1387 ;;  For 2008-07-14, THEMIS-B
;;        1675 ;;  For 2008-07-22, THEMIS-B
;;        1687 ;;  For 2008-07-26, THEMIS-B
;;        1749 ;;  For 2008-07-30, THEMIS-B
;;        1677 ;;  For 2008-08-07, THEMIS-B
;;        1604 ;;  For 2008-08-11, THEMIS-B
;;        1713 ;;  For 2008-08-23, THEMIS-B
;;         978 ;;  For 2008-07-14, THEMIS-C
;;         202 ;;  For 2008-08-12, THEMIS-C
;;        1362 ;;  For 2008-08-19, THEMIS-C
;;        1209 ;;  For 2008-09-08, THEMIS-C
;;        1412 ;;  For 2008-09-16, THEMIS-C
;;         202 ;;  For 2008-10-03, THEMIS-C
;;         807 ;;  For 2008-10-09, THEMIS-C
;;        1585 ;;  For 2008-10-12, THEMIS-C
;;        1166 ;;  For 2009-07-13, THEMIS-B

;;  Keep only "good" eVDFs
DELVAR,dat_e,dat_i,dat_igse
gd_degse       = dat_egse[good]
gnne           = N_ELEMENTS(gd_degse)

nnd            = gd_degse[0].NBINS[0]
units          = 'flux'
xran           = [1d0,30d3]
yran           = [1d-1,2d7]
l10yr          = ALOG10(yran*[1d1,5d-1])
temp           = DINDGEN(nnd[0])*(l10yr[1] - l10yr[0])/(nnd[0] - 1L) + l10yr[0]
yposi          = 1d1^(temp)

all_funcs      = [1,2,4]
all_jpref      = ['PowLaw','Expon','PowLawExpon']+'.VDF_'
all_frame      = [0,1]
all_fr_str     = ['SWF','SCF']+'.'
pa_bin_wd      = 25d0
;;  Define energy ranges
bad_tdates_b   = ['2008-07-22','2008-07-26']
test_td_b      = TOTAL(tdate[0] EQ bad_tdates_b) GT 0
IF (test_td_b[0] AND (sc[0] EQ 'b')) THEN ener_high = 7e3 ELSE ener_high = 15e3
;test_td_b      = WHERE(tdate[0] EQ bad_tdates_b,gdttdb)
;IF ((gdttdb[0] GT 0) AND (sc[0] EQ 'b')) THEN ener_high = ([7e3,6e3])[test_td_b[0]] ELSE ener_high = 15e3
scf_eran       = [50e0,ener_high[0]]
swf_eran       = [30e0,ener_high[0]]


;;  Test for Burst, Full, or Both
test           = [0b,0b]
FOR j=0L, gnne[0] - 1L DO BEGIN                                                        $
  dat0 = gd_degse[j]                                                                 & $
  str  = dat_themis_esa_str_names(dat0[0],/NOM)                                      & $
  tesn = STRMID(str[0].SN[0],3) EQ ['b','f']                                         & $
  good = WHERE(tesn,gd)                                                              & $
  IF (gd GT 0) THEN test[good] = tesn[good]                                          & $
  IF (test[0] AND test[1]) THEN BREAK

teste0         = (TOTAL(test) GT 0)
teste1         = (TOTAL(test) GT 1)
IF (teste0) THEN IF (teste1) THEN esatype = 'Both' ELSE esatype = (['Burst','Full'])[WHERE(test)]
IF (SIZE(esatype,/TYPE) NE 7) THEN PRINT,';;  What happened?'
;esatype        = (['Burst','Full','Both'])[TOTAL(test)]

;;  Try using pointers?  str_element.pro gets progressively slower after time
pl_fit_pnt     = PTRARR(gnne[0],/ALLOCATE_HEAP)
exp_fit_pnt    = PTRARR(gnne[0],/ALLOCATE_HEAP)
plexp_fit_pnt  = PTRARR(gnne[0],/ALLOCATE_HEAP)
;;########################################################################################
;;  Define version for output
;;########################################################################################
;; Change the file path accordingly for your system
mdir     = FILE_EXPAND_PATH('/Users/lbwilson/Desktop/temp_idl/')+'/'
file     = 'temp_fit_evdf_para_perp_anti.pro'
vers0    = routine_version(file,mdir)
;;  Remove time so it can be updated for each plot
gposi    = STRPOS(vers0[0],',')
vers1    = STRMID(vers0[0],0L,gposi[0] + 2L)     ;;  e.g., 'temp_fit_evdf_para_perp_anti.pro : 10/22/2014   v1.0.0, '

;;------------------------------------------------
;;  Power-Law Fits
;;    Y = A X^(B) + C
;;------------------------------------------------
ex_start = SYSTIME(1)
FOR frame=0L, 1L DO BEGIN                                                                  $
  IF (frame EQ 1) THEN eran = scf_eran ELSE eran = swf_eran                              & $
;  IF (frame EQ 1) THEN eran = [50e0,15e3] ELSE eran = [30e0,15e3]                        & $
  FOR k=0L, 0L DO BEGIN                                                                    $
    func           = all_funcs[k]                                                        & $
    jpref          = all_fr_str[frame]+all_jpref[k]                                      & $
    filedir        = all_dirs[frame,k]                                                   & $
;    FOR j=jstart[0], jmax[0] DO BEGIN                                                      $
    FOR j=0L, gnne[0] - 1L DO BEGIN                                                        $
      jstr = jpref[0]+STRTRIM(STRING(j[0],FORMAT='(I4.4)'),2L)                           & $
;      dat0 = dat_egse[j]                                                                 & $
      curt    = time_string(SYSTIME(1,/SECONDS),PREC=3)+' UT'                            & $
      version = vers1[0]+curt[0]                                                         & $
      dat0 = gd_degse[j]                                                                 & $
      lim0 = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}    & $
      extr = {LIMITS:lim0,FIT_FUNC:func,ERA_1C_SC:1,PA_BIN_WD:pa_bin_wd,SC_FRAME:frame,    $
              E_RANGE:eran,FILE_DIR:filedir,VERSION:version[0]}                          & $
      temp = temp_fit_evdf_para_perp_anti(dat0,_EXTRA=extr)                              & $
      *pl_fit_pnt[j] = temp
;      *pl_fit_pnt[k] = temp
;      str_element,pl_fit_strucs,jstr[0],temp,/ADD_REPLACE
MESSAGE,STRING(SYSTIME(1) - ex_start)+' seconds execution time.',/CONTINUE,/INFORMATIONAL

;;  Define save file for output structures
k--                                        ;;  decrement
fnm            = file_name_times([MIN(gd_degse.END_TIME,/NAN),MAX(gd_degse.END_TIME,/NAN)],PREC=3)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
all_subfnms    = ['Power_Law','Exponential','Power_Law_Exponential']
all_fr_fnms    = ['SWF','SCF']+'_'
suffix         = all_fr_fnms[0]+all_fr_fnms[1]+all_subfnms[k]+'_Fit-Results_'+tsuffx[0]+'.sav'
fitname        = new_dir[0]+'THEMIS_EESA_'+esatype[0]+'_'+sc[0]+'_'+suffix[0]
SAVE,pl_fit_pnt,FILENAME=fitname
;SAVE,pl_fit_strucs,FILENAME=fitname

;;------------------------------------------------
;;  Exponential Fits
;;    Y = A e^(B X) + C
;;------------------------------------------------
ex_start = SYSTIME(1)
FOR frame=0L, 1L DO BEGIN                                                                  $
  IF (frame EQ 1) THEN eran = scf_eran ELSE eran = swf_eran                              & $
;  IF (frame EQ 1) THEN eran = [50e0,15e3] ELSE eran = [30e0,15e3]                        & $
  FOR k=1L, 1L DO BEGIN                                                                    $
    func           = all_funcs[k]                                                        & $
    jpref          = all_fr_str[frame]+all_jpref[k]                                      & $
    filedir        = all_dirs[frame,k]                                                   & $
;    FOR j=jstart[0], jmax[0] DO BEGIN                                                      $
    FOR j=0L, gnne[0] - 1L DO BEGIN                                                        $
      jstr = jpref[0]+STRTRIM(STRING(j[0],FORMAT='(I4.4)'),2L)                           & $
;      dat0 = dat_egse[j]                                                                 & $
      curt    = time_string(SYSTIME(1,/SECONDS),PREC=3)+' UT'                            & $
      version = vers1[0]+curt[0]                                                         & $
      dat0 = gd_degse[j]                                                                 & $
      lim0 = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}    & $
      extr = {LIMITS:lim0,FIT_FUNC:func,ERA_1C_SC:1,PA_BIN_WD:pa_bin_wd,SC_FRAME:frame,    $
              E_RANGE:eran,FILE_DIR:filedir,VERSION:version[0]}                          & $
      temp = temp_fit_evdf_para_perp_anti(dat0,_EXTRA=extr)                              & $
      *exp_fit_pnt[j] = temp
;      *exp_fit_pnt[k] = temp
;      str_element,exp_fit_strucs,jstr[0],temp,/ADD_REPLACE
MESSAGE,STRING(SYSTIME(1) - ex_start)+' seconds execution time.',/CONTINUE,/INFORMATIONAL

;;  Define save file for output structures
k--                                        ;;  decrement
fnm            = file_name_times([MIN(gd_degse.END_TIME,/NAN),MAX(gd_degse.END_TIME,/NAN)],PREC=3)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
all_subfnms    = ['Power_Law','Exponential','Power_Law_Exponential']
all_fr_fnms    = ['SWF','SCF']+'_'
;fitname        = new_dir[0]+'THEMIS_EESA_Burst_'+sc[0]+'_'+all_fr_fnms[frame]+all_subfnms[k]+'_Fit-Results_'+tsuffx[0]+'.sav'
suffix         = all_fr_fnms[0]+all_fr_fnms[1]+all_subfnms[k]+'_Fit-Results_'+tsuffx[0]+'.sav'
fitname        = new_dir[0]+'THEMIS_EESA_'+esatype[0]+'_'+sc[0]+'_'+suffix[0]
SAVE,exp_fit_pnt,FILENAME=fitname
;SAVE,exp_fit_strucs,FILENAME=fitname

;;------------------------------------------------
;;  (Power-Law + Exponential) Fits
;;    Y = A X^(B) e^(C X) + D
;;------------------------------------------------
ex_start = SYSTIME(1)
FOR frame=0L, 1L DO BEGIN                                                                  $
  IF (frame EQ 1) THEN eran = scf_eran ELSE eran = swf_eran                              & $
;  IF (frame EQ 1) THEN eran = [50e0,15e3] ELSE eran = [30e0,15e3]                        & $
  FOR k=2L, 2L DO BEGIN                                                                    $
    func           = all_funcs[k]                                                        & $
    jpref          = all_fr_str[frame]+all_jpref[k]                                      & $
    filedir        = all_dirs[frame,k]                                                   & $
;    FOR j=jstart[0], jmax[0] DO BEGIN                                                      $
    FOR j=0L, gnne[0] - 1L DO BEGIN                                                        $
      jstr = jpref[0]+STRTRIM(STRING(j[0],FORMAT='(I4.4)'),2L)                           & $
;      dat0 = dat_egse[j]                                                                 & $
      curt    = time_string(SYSTIME(1,/SECONDS),PREC=3)+' UT'                            & $
      version = vers1[0]+curt[0]                                                         & $
      dat0 = gd_degse[j]                                                                 & $
      lim0 = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}    & $
      extr = {LIMITS:lim0,FIT_FUNC:func,ERA_1C_SC:1,PA_BIN_WD:pa_bin_wd,SC_FRAME:frame,    $
              E_RANGE:eran,FILE_DIR:filedir,VERSION:version[0]}                          & $
      temp = temp_fit_evdf_para_perp_anti(dat0,_EXTRA=extr)                              & $
      *plexp_fit_pnt[j] = temp
;      *plexp_fit_pnt[k] = temp
;      str_element,plexp_fit_strucs,jstr[0],temp,/ADD_REPLACE
MESSAGE,STRING(SYSTIME(1) - ex_start)+' seconds execution time.',/CONTINUE,/INFORMATIONAL

;;  Define save file for output structures
k--                                        ;;  decrement
fnm            = file_name_times([MIN(gd_degse.END_TIME,/NAN),MAX(gd_degse.END_TIME,/NAN)],PREC=3)
ftimes         = fnm.F_TIME          ; e.g. 1998-08-09_0801x09.494
tsuffx         = ftimes[0]+'-'+STRMID(ftimes[1],11L)
all_subfnms    = ['Power_Law','Exponential','Power_Law_Exponential']
all_fr_fnms    = ['SWF','SCF']+'_'
;fitname        = new_dir[0]+'THEMIS_EESA_Burst_'+sc[0]+'_'+all_fr_fnms[frame]+all_subfnms[k]+'_Fit-Results_'+tsuffx[0]+'.sav'
suffix         = all_fr_fnms[0]+all_fr_fnms[1]+all_subfnms[k]+'_Fit-Results_'+tsuffx[0]+'.sav'
fitname        = new_dir[0]+'THEMIS_EESA_'+esatype[0]+'_'+sc[0]+'_'+suffix[0]
SAVE,plexp_fit_pnt,FILENAME=fitname
;SAVE,plexp_fit_strucs,FILENAME=fitname

;;  Clean up
DELVAR,temp,pl_fit_strucs,exp_fit_strucs,plexp_fit_strucs
FOR j=0L, gnne[0] - 1L DO BEGIN                       $
  PTR_FREE,pl_fit_pnt[j]                            & $
  HEAP_FREE,pl_fit_pnt[j],/PTR

DELVAR,temp,pl_fit_strucs,exp_fit_strucs,plexp_fit_strucs
FOR j=0L, gnne[0] - 1L DO BEGIN                       $
  PTR_FREE,exp_fit_pnt[j]                           & $
  HEAP_FREE,exp_fit_pnt[j],/PTR

DELVAR,temp,pl_fit_strucs,exp_fit_strucs,plexp_fit_strucs
FOR j=0L, gnne[0] - 1L DO BEGIN                       $
  PTR_FREE,plexp_fit_pnt[j]                         & $
  HEAP_FREE,plexp_fit_pnt[j],/PTR

DELVAR,pl_fit_pnt,exp_fit_pnt,plexp_fit_pnt



;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

;;    Y = A e^(B X) + C
temps    = exp_fit_strucs.SWF.EXPON
nt       = N_TAGS(temps)
fitparms = DBLARR(nt,3L,4L)
FOR ii=1L, 3L DO FOR kk=0L, nt - 1L DO fitparms[kk,ii-1L,*] = temps.(kk).(ii).FIT.FIT_PARAMS

bad0     = WHERE(fitparms[*,0,1] GT 0,bd0)
bad1     = WHERE(fitparms[*,1,1] GT 0,bd1)
bad2     = WHERE(fitparms[*,2,1] GT 0,bd2)
PRINT,';;',bd0,bd1,bd2
;;           0           0           0

temps    = exp_fit_strucs.SCF.EXPON
nt       = N_TAGS(temps)
fitparms = DBLARR(nt,3L,4L)
FOR ii=1L, 3L DO FOR kk=0L, nt - 1L DO fitparms[kk,ii-1L,*] = temps.(kk).(ii).FIT.FIT_PARAMS

bad0     = WHERE(fitparms[*,0,1] GT 0,bd0)
bad1     = WHERE(fitparms[*,1,1] GT 0,bd1)
bad2     = WHERE(fitparms[*,2,1] GT 0,bd2)
PRINT,';;',bd0,bd1,bd2
;;           0           0           0


;;    Y = A X^(B) e^(C X) + D
temps    = plexp_fit_strucs.SWF.POWLAWEXPON
nt       = N_TAGS(temps)
fitparms = DBLARR(nt,3L,4L)
FOR ii=1L, 3L DO FOR kk=0L, nt - 1L DO fitparms[kk,ii-1L,*] = temps.(kk).(ii).FIT.FIT_PARAMS

bad01    = WHERE(fitparms[*,0,1] GT 0,bd01)
bad11    = WHERE(fitparms[*,1,1] GT 0,bd11)
bad21    = WHERE(fitparms[*,2,1] GT 0,bd21)
PRINT,';;',bd01,bd11,bd21
;;         215          10          20

bad02    = WHERE(fitparms[*,0,2] GT 0,bd02)
bad12    = WHERE(fitparms[*,1,2] GT 0,bd12)
bad22    = WHERE(fitparms[*,2,2] GT 0,bd22)
PRINT,';;',bd02,bd12,bd22
;;           9           7          21

temps    = plexp_fit_strucs.SCF.POWLAWEXPON
nt       = N_TAGS(temps)
fitparms = DBLARR(nt,3L,4L)
FOR ii=1L, 3L DO FOR kk=0L, nt - 1L DO fitparms[kk,ii-1L,*] = temps.(kk).(ii).FIT.FIT_PARAMS

bad01    = WHERE(fitparms[*,0,1] GT 0,bd01)
bad11    = WHERE(fitparms[*,1,1] GT 0,bd11)
bad21    = WHERE(fitparms[*,2,1] GT 0,bd21)
PRINT,';;',bd01,bd11,bd21
;;          51           2           3

bad02    = WHERE(fitparms[*,0,2] GT 0,bd02)
bad12    = WHERE(fitparms[*,1,2] GT 0,bd12)
bad22    = WHERE(fitparms[*,2,2] GT 0,bd22)
PRINT,';;',bd02,bd12,bd22
;;           7          10          12
;;----------------------------------------------------------------------------------------
;;  Plot electron spectra
;;----------------------------------------------------------------------------------------
jj             = 820L
dat0           = dat_egse[jj]
nnd            = dat0[0].NBINS[0]
nne            = dat0[0].NENERGY[0]

PRINT,';;  ',time_string(dat0[0].TIME,PREC=3)
;;  2008-07-14/21:57:12.796


.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/SCIENCE_PRO/spec3d.pro

units          = 'flux'
xran           = [1d0,30d3]
yran           = [1d-1,2d7]
l10yr          = ALOG10(yran*[1d1,5d-1])
temp           = DINDGEN(nnd[0])*(l10yr[1] - l10yr[0])/(nnd[0] - 1L) + l10yr[0]
yposi          = 1d1^(temp)
pang           = 1
s3d_lim        = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}

.compile /Users/lbwilson/Desktop/temp_idl/wrapper_multi_func_fit.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_fit_evdf_para_perp_anti.pro

func           = 1  ;;  Y = A X^(B) + C
pa_bin_wd      = 25d0
test_1         = temp_fit_evdf_para_perp_anti(dat0,LIMITS=s3d_lim,FIT_FUNC=func,$
                                              /ERA_1C_SC,PA_BIN_WD=pa_bin_wd)

func           = 2  ;;  Y = A e^(B X) + C
pa_bin_wd      = 25d0
test_2         = temp_fit_evdf_para_perp_anti(dat0,LIMITS=s3d_lim,FIT_FUNC=func,$
                                              /ERA_1C_SC,PA_BIN_WD=pa_bin_wd)

func           = 4  ;;  Y = A X^(B) e^(C X) + D
pa_bin_wd      = 25d0
test_4         = temp_fit_evdf_para_perp_anti(dat0,LIMITS=s3d_lim,FIT_FUNC=func,$
                                              /ERA_1C_SC,PA_BIN_WD=pa_bin_wd)

func           = 1  ;;  Y = A X^(B) + C
pa_bin_wd      = 25d0
test_1         = temp_fit_evdf_para_perp_anti(dat0,LIMITS=s3d_lim,FIT_FUNC=func,$
                                              /ERA_1C_SC,PA_BIN_WD=pa_bin_wd,/SC_FRAME)

func           = 2  ;;  Y = A e^(B X) + C
pa_bin_wd      = 25d0
test_2         = temp_fit_evdf_para_perp_anti(dat0,LIMITS=s3d_lim,FIT_FUNC=func,$
                                              /ERA_1C_SC,PA_BIN_WD=pa_bin_wd,/SC_FRAME)

func           = 4  ;;  Y = A X^(B) e^(C X) + D
pa_bin_wd      = 25d0
test_4         = temp_fit_evdf_para_perp_anti(dat0,LIMITS=s3d_lim,FIT_FUNC=func,$
                                              /ERA_1C_SC,PA_BIN_WD=pa_bin_wd,/SC_FRAME)
;test           = temp_fit_evdf_para_perp_anti(dat0,LIMITS=s3d_lim,FIT_FUNC=func,$
;                                              /ERA_1C_SC,PA_BIN_WD=pa_bin_wd,$
;                                              B_RANGE=[1,1,-20d0,-1.8d0])

;;----------------------------------------------------------------------------------------
;;  Plot all electron spectra
;;----------------------------------------------------------------------------------------
.compile /Users/lbwilson/Desktop/temp_idl/wrapper_multi_func_fit.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_fit_evdf_para_perp_anti.pro

IF (tdate[0] EQ '2008-07-14') THEN tstart = time_double(tdate[0]+'/15:00:00.000')
IF (N_ELEMENTS(tstart) EQ 0) THEN tstart = 0d0

good           = WHERE(dat_egse.TIME GE tstart[0],gd)
IF (gd EQ 0) THEN jstart = 0L ELSE jstart = good[0]
nne            = N_ELEMENTS(dat_egse)
jmax           = jstart[0] + 10L
;jmax           = jstart[0] + 2L

units          = 'flux'
xran           = [1d1,30d3]
yran           = [1d-1,2d7]
l10yr          = ALOG10(yran*[1d1,5d-1])
temp           = DINDGEN(nnd[0])*(l10yr[1] - l10yr[0])/(nnd[0] - 1L) + l10yr[0]
yposi          = 1d1^(temp)

all_funcs      = [1,2,4]
all_jpref      = 'VDF_'+['PowLaw','Expon','PowLawExpon']+'_'
all_frame      = [0,1]
all_fr_str     = ['SWF','SCF']+'.'
pa_bin_wd      = 25d0
;eran           = [50e0,15e3]

FOR frame=0L, 1L DO BEGIN                                                                  $
  IF (frame EQ 1) THEN eran = [50e0,15e3] ELSE eran = [30e0,15e3]                        & $
  FOR k=0L, 2L DO BEGIN                                                                    $
    func           = all_funcs[k]                                                        & $
    jpref          = all_fr_str[frame]+all_jpref[k]                                      & $
    FOR j=jstart[0], jmax[0] DO BEGIN                                                      $
      jstr = jpref[0]+STRTRIM(STRING(j[0],FORMAT='(I4.4)'),2L)                           & $
      dat0 = dat_egse[j]                                                                 & $
      lim0 = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}    & $
      extr = {LIMITS:lim0,FIT_FUNC:func,ERA_1C_SC:1,PA_BIN_WD:pa_bin_wd,SC_FRAME:frame,    $
              E_RANGE:eran}                                                              & $
      temp = temp_fit_evdf_para_perp_anti(dat0,_EXTRA=extr)                              & $
      str_element,fit_strucs,jstr[0],temp,/ADD_REPLACE

;      temp = temp_fit_evdf_para_perp_anti(dat0,LIMITS=lim0,FIT_FUNC=func,/ERA_1C_SC,     $
;                                          PA_BIN_WD=pa_bin_wd,SC_FRAME=frame)          & $

;;  Test explicit vs. implicit/passive keyword settings
j              = jstart[0]
dat0           = dat_egse[j]
lim0           = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}
func           = 1
frame          = 1
pa_bin_wd      = 25d0
temp           = temp_fit_evdf_para_perp_anti(dat0,LIMITS=lim0,FIT_FUNC=func,/ERA_1C_SC, $
                                              PA_BIN_WD=pa_bin_wd,SC_FRAME=frame)


dat0           = dat_egse[j]
lim0           = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}
func           = 1
frame          = 1
pa_bin_wd      = 25d0
eran           = [50e0,15e3]
extra          = {LIMITS:lim0,FIT_FUNC:func,ERA_1C_SC:1,PA_BIN_WD:pa_bin_wd,SC_FRAME:frame,E_RANGE:eran}
temp2          = temp_fit_evdf_para_perp_anti(dat0,_EXTRA=extra)

.compile /Users/lbwilson/Desktop/temp_idl/temp_fit_evdf_para_perp_anti.pro
pa_bin_wd      = 25d0
eran           = [50e0,15e3]
extra          = {LIMITS:lim0,FIT_FUNC:func,ERA_1C_SC:1,PA_BIN_WD:pa_bin_wd,SC_FRAME:frame,E_RANGE:eran}
temp2          = temp_fit_evdf_para_perp_anti(dat0,_EXTRA=extra)


;;FOR j=jstart[0], nne[0] - 1L DO BEGIN                                                $
;FOR j=jstart[0], jstart[0] + 10L DO BEGIN                                            $
;  jstr = 'VDF_'+STRTRIM(STRING(j[0],FORMAT='(I4.4)'),2L)                           & $
;  dat0 = dat_egse[j]                                                               & $
;  lim0 = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}  & $
;  temp = temp_fit_evdf_para_perp_anti(dat0,LIMITS=lim0)                            & $
;  str_element,fit_strucs,jstr[0],temp,/ADD_REPLACE


;;  Clean up
DELVAR,temp,fit_strucs


;;----------------------------------------------------------------------------------------
;;  Plot electron spectra
;;----------------------------------------------------------------------------------------
;;  Open window
WINDOW,1,RETAIN=2,XSIZE=800,YSIZE=800,TITLE='EESA Plots ['+tdate[0]+']'
WINDOW,2,RETAIN=2,XSIZE=800,YSIZE=800,TITLE='EESA Plots ['+tdate[0]+']'
WINDOW,3,RETAIN=2,XSIZE=800,YSIZE=800,TITLE='EESA Plots ['+tdate[0]+']'

jj             = 820L
dat0           = dat_egse[jj]
nnd            = dat0[0].NBINS[0]
nne            = dat0[0].NENERGY[0]

PRINT,';;  ',time_string(dat0[0].TIME,PREC=3)
;;  2008-07-14/21:57:12.796

.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/SCIENCE_PRO/spec3d.pro
.compile /Users/lbwilson/Desktop/temp_idl/temp_fit_evdf_para_perp_anti.pro

;units          = 'df'
;yran           = [1d-18,2d-10]
units          = 'flux'
;;  Calculate the one-count levels for error estimates
;dat1c          = conv_units(dat0[0],'crate')
;dat1c          = conv_units(dat0[0],'rate')
dat1c          = dat0[0]
dat1c[0].DATA  = 1e0
dat1c          = conv_units(dat1c[0],units[0],/FRACTIONAL_COUNTS)
onec0          = dat1c[0].DATA

xran           = [1d1,10d3]
yran           = [1d1,2d7]
l10yr          = ALOG10(yran*[1d1,5d-1])
temp           = DINDGEN(nnd[0])*(l10yr[1] - l10yr[0])/(nnd[0] - 1L) + l10yr[0]
yposi          = 1d1^(temp)
pang           = 1
s3d_lim        = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}
test           = temp_fit_evdf_para_perp_anti(dat0,LIMITS=s3d_lim)







WSET,1
WSHOW,1
spec3d,dat0[0],UNITS=units,XDAT=energy0,YDAT=data0,LIMITS=s3d_lim,/RM_PHOTO_E,$
               PITCHANGLE=pang,/LABEL,COLOR=pa_cols


;;  Sort by pitch-angle
sp             = SORT(pang)
pang           = pang[sp]
pa_cols        = pa_cols[sp]
data_pa        = data0[*,sp]
ener_pa        = energy0[*,sp]
onec_pa        = onec0[*,sp]
;;  Define parallel, anti-parallel, and perpendicular
para_ra        = [0d0,2d1]
anti_ra        = [16d1,18d1]
perp_ra        = [8d1,10d1]
test_para      = (pang GE para_ra[0]) AND (pang LE para_ra[1])
test_perp      = (pang GE perp_ra[0]) AND (pang LE perp_ra[1])
test_anti      = (pang GE anti_ra[0]) AND (pang LE anti_ra[1])
good_para      = WHERE(test_para,gd_para,COMPLEMENT=bad_para,NCOMPLEMENT=bd_para)
good_perp      = WHERE(test_perp,gd_perp,COMPLEMENT=bad_perp,NCOMPLEMENT=bd_perp)
good_anti      = WHERE(test_anti,gd_anti,COMPLEMENT=bad_anti,NCOMPLEMENT=bd_anti)
PRINT,';;  ',gd_para,gd_perp,gd_anti
;;             3          16           3

;;  Find PA bin closest to parallel, perpendicular, and anti-parallel for one-count
pang_para      = pang[good_para]
pang_perp      = pang[good_perp]
pang_anti      = pang[good_anti]
diff_para      = MIN(ABS( 0d0 - pang_para),gind_para,/NAN)
diff_perp      = MIN(ABS(90d0 - pang_perp),gind_perp,/NAN)
diff_anti      = MIN(ABS(18d1 - pang_anti),gind_anti,/NAN)


;;  Define data and energy in each direction
data_para      = data_pa[*,good_para]
data_perp      = data_pa[*,good_perp]
data_anti      = data_pa[*,good_anti]
ener_para      = ener_pa[*,good_para]
ener_perp      = ener_pa[*,good_perp]
ener_anti      = ener_pa[*,good_anti]
onec_para      = onec_pa[*,good_para[gind_para[0]]]
onec_perp      = onec_pa[*,good_perp[gind_perp[0]]]
onec_anti      = onec_pa[*,good_anti[gind_anti[0]]]


;;  Average data over each direction
Avgf_para      = TOTAL(data_para,2L,/NAN)/TOTAL(FINITE(data_para),2L,/NAN)
Avgf_perp      = TOTAL(data_perp,2L,/NAN)/TOTAL(FINITE(data_perp),2L,/NAN)
Avgf_anti      = TOTAL(data_anti,2L,/NAN)/TOTAL(FINITE(data_anti),2L,/NAN)
AvgE_para      = TOTAL(ener_para,2L,/NAN)/TOTAL(FINITE(ener_para),2L,/NAN)
AvgE_perp      = TOTAL(ener_perp,2L,/NAN)/TOTAL(FINITE(ener_perp),2L,/NAN)
AvgE_anti      = TOTAL(ener_anti,2L,/NAN)/TOTAL(FINITE(ener_anti),2L,/NAN)
Avg1_para      = onec_para
Avg1_perp      = onec_perp
Avg1_anti      = onec_anti
;Avg1_para      = TOTAL(onec_para,2L,/NAN)/TOTAL(FINITE(onec_para),2L,/NAN)
;Avg1_perp      = TOTAL(onec_perp,2L,/NAN)/TOTAL(FINITE(onec_perp),2L,/NAN)
;Avg1_anti      = TOTAL(onec_anti,2L,/NAN)/TOTAL(FINITE(onec_anti),2L,/NAN)

;;----------------------------------------------
;;  Try plotting
;;----------------------------------------------

;yran           = [1d-18,1d-10]
xdat0          = AvgE_para
xdat1          = AvgE_perp
xdat2          = AvgE_anti
ydat0          = Avgf_para
ydat1          = Avgf_perp
ydat2          = Avgf_anti
;;  Define one-count levels for comparison
yone0          = Avg1_para
yone1          = Avg1_perp
yone2          = Avg1_anti

xran           = [1d1,10d3]
yran           = [1d0,2d7]
xtick_str0     = log10_tickmarks(xdat0,RANGE=xran,MIN_VAL=xran[0],MAX_VAL=xran[1],/FORCE_RA)
ytick_str0     = log10_tickmarks(ydat0,RANGE=yran,MIN_VAL=yran[0],MAX_VAL=yran[1],/FORCE_RA)
xtv            = xtick_str0.TICKV
xtn            = xtick_str0.TICKNAME
xts            = xtick_str0.TICKS
ytv            = ytick_str0.TICKV
ytn            = ytick_str0.TICKNAME
yts            = ytick_str0.TICKS
pstr           = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,XLOG:1,YLOG:1,$
                  XTICKV:xtv,XTICKNAME:xtn,XTICKS:xts,XMINOR:9,           $
                  YTICKV:ytv,YTICKNAME:ytn,YTICKS:yts,YMINOR:9            }
WSET,2
WSHOW,2
PLOT,xdat0,ydat0,_EXTRA=pstr,/NODATA
  OPLOT,xdat0,ydat0,COLOR=250,PSYM=2
  OPLOT,xdat1,ydat1,COLOR=150,PSYM=2
  OPLOT,xdat2,ydat2,COLOR= 50,PSYM=2
  ;;  Plot one-count levels
  OPLOT,xdat0,yone0,COLOR=250,LINESTYLE=2
  OPLOT,xdat1,yone1,COLOR=150,LINESTYLE=2
  OPLOT,xdat2,yone2,COLOR= 50,LINESTYLE=2


;;----------------------------------------------------------------------------------------
;;  Try fitting to Y = A X^(B) e^(C X) + D
;;
;;    Y  =  dJ/dE [flux units]
;;    X  =  E  [eV]
;;    A  =  K  [some constant]
;;    B  =  -¥ = power-law slope = spectral index
;;    C  =  -1/E_o, E_o = e-folding energy [eV]
;;    D  =  (dJ/dE)_o = limit as E --> 0
;;----------------------------------------------------------------------------------------
;;  Use only those elements which satisfy the following two constraints:
;;    1)  E > 30 eV
;;    2)  f > f_1c    [f_1c = one-count level]
e_low          = 30e0
test_para_fit  =  (AvgE_para GE e_low[0]) AND $
                 ((Avgf_para GE Avg1_para) AND (Avgf_para GT 0) AND FINITE(Avgf_para))
test_perp_fit  =  (AvgE_perp GE e_low[0]) AND $
                 ((Avgf_perp GE Avg1_perp) AND (Avgf_perp GT 0) AND FINITE(Avgf_perp))
test_anti_fit  =  (AvgE_anti GE e_low[0]) AND $
                 ((Avgf_anti GE Avg1_anti) AND (Avgf_anti GT 0) AND FINITE(Avgf_anti))
good_para_fit  = WHERE(test_para_fit,gd_para_fit,COMPLEMENT=bad_para_fit,NCOMPLEMENT=bd_para_fit)
good_perp_fit  = WHERE(test_perp_fit,gd_perp_fit,COMPLEMENT=bad_perp_fit,NCOMPLEMENT=bd_perp_fit)
good_anti_fit  = WHERE(test_anti_fit,gd_anti_fit,COMPLEMENT=bad_anti_fit,NCOMPLEMENT=bd_anti_fit)
PRINT,';;  ',gd_para_fit,gd_perp_fit,gd_anti_fit
;;            14           9           9



x              = AvgE_para[good_para_fit]
y              = Avgf_para[good_para_fit]
yerr           = ABS(Avg1_para[good_para_fit])
wghts          = 1d0/ABS(yerr)            ;;  Poisson weighting
func           = 4                        ;;  i.e., Y = A X^(B) e^(C X) + D
param          = DBLARR(4)
param[0]       = 1d6                      ;;  Lim_{E --> 0} (dJ/dE) ~ 10^(6)
param[1]       = -2d0                     ;;  ¥ ~ 2
param[2]       = -1d0/1d2                 ;;  E_o ~ 100 eV
param[3]       = 0d0                      ;;  Lim_{E --> Infinity} (dJ/dE)_o ~ 0
bran           = [1,1,-7d0,-5d-2]         ;;  Constrain spectral index
cran           = [1,1,-1d0/1d1,-1d0/1d4]  ;;  Constrain E_o
fixed_p        = REPLICATE(1b,4)
fixed_p[3]     = 0b
.compile /Users/lbwilson/Desktop/temp_idl/wrapper_multi_func_fit.pro
test           = wrapper_multi_func_fit(x,y,param,FIT_FUNC=func[0],ERROR=yerr,  $
                                        WEIGHTS=wghts,B_RANGE=bran,C_RANGE=cran,$
                                        FIXED_P=fixed_p)
HELP, test,/STRUC

PRINT,';;',test.FIT_PARAMS
;;       3799751.2     -0.52732465   -0.0061059901       0.0000000


xx             = x
ff             = test.YFIT
xran           = [1d1,10d3]
yran           = [1d0,2d7]
xtick_str1     = log10_tickmarks(xx,RANGE=xran,MIN_VAL=xran[0],MAX_VAL=xran[1],/FORCE_RA)
ytick_str1     = log10_tickmarks(ff,RANGE=yran,MIN_VAL=yran[0],MAX_VAL=yran[1],/FORCE_RA)
xtv            = xtick_str1.TICKV
xtn            = xtick_str1.TICKNAME
xts            = xtick_str1.TICKS
ytv            = ytick_str1.TICKV
ytn            = ytick_str1.TICKNAME
yts            = ytick_str1.TICKS
pstr           = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,XLOG:1,YLOG:1,$
                  XTICKV:xtv,XTICKNAME:xtn,XTICKS:xts,XMINOR:9,           $
                  YTICKV:ytv,YTICKNAME:ytn,YTICKS:yts,YMINOR:9            }
WSET,3
WSHOW,3
PLOT,AvgE_para,Avgf_para,_EXTRA=pstr,/NODATA
  OPLOT,AvgE_para,Avgf_para,COLOR=250,PSYM=2
  OPLOT,AvgE_perp,Avgf_perp,COLOR=150,PSYM=2
  OPLOT,AvgE_anti,Avgf_anti,COLOR= 50,PSYM=2
  OPLOT,       xx,       ff,COLOR=250,LINESTYLE=2


;;----------------------------------------------------------------------------------------
;;   FIT_FUNC  :  Scalar [integer] specifying the type of function to use
;;                    1  :  F(A,B,C,D,X) = A X^(B) + C
;;                    2  :  F(A,B,C,D,X) = A e^(B X) + C
;;                    3  :  F(A,B,C,D,X) = A + B Log_{e} |X^C|
;;                    4  :  F(A,B,C,D,X) = A X^(B) e^(C X) + D
;;                    5  :  F(A,B,C,D,X) = A B^(X) + C
;;                    6  :  F(A,B,C,D,X) = A B^(C X) + D
;;                    7  :  F(A,B,C,D,X) = ( A + B X )^(-1)
;;                    8  :  F(A,B,C,D,X) = ( A B^(X) + C )^(-1)
;;                    9  :  F(A,B,C,D,X) = A X^(B) ( e^(C X) + D )^(-1)
;;                   10  :  F(A,B,C,D,X) = A + B Log_{10} |X| + C (Log_{10} |X|)^2
;;----------------------------------------------------------------------------------------


;fit_func       = test.FUNC
;fit_parm       = test.FIT_PARAMS
;pder           = REPLICATE(1,4)
;xx             = x
;ff             = CALL_FUNCTION(fit_func[0],xx,fit_parm,pder)



;               PARAM     :  [4]-Element array containing the following initialization
;                              quantities for the model functions (see below):
;                                PARAM[0] = A
;                                PARAM[1] = B
;                                PARAM[2] = C
;                                PARAM[3] = D

















;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Old/Obsolete
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------

units          = 'df'
s3d_lim        = {XRANGE:[1d0,10d3],XSTYLE:1,YSTYLE:1}
WSET,1
WSHOW,1
spec3d,dat0[0],UNITS=units,XDAT=energy0,YDAT=data0,LIMITS=s3d_lim

units          = 'df'
s3d_lim        = {XRANGE:[1d0,10d3],XSTYLE:1,YRANGE:[1d-18,1d-9],YSTYLE:1}
WSET,1
WSHOW,1
spec3d,dat0[0],UNITS=units,XDAT=energy0,YDAT=data0,LIMITS=s3d_lim

units          = 'df'
s3d_lim        = {XRANGE:[1d0,10d3],XSTYLE:1,YRANGE:[1d-18,2d-10],YSTYLE:1}
WSET,1
WSHOW,1
spec3d,dat0[0],UNITS=units,XDAT=energy0,YDAT=data0,LIMITS=s3d_lim,/RM_PHOTO_E

units          = 'df'
s3d_lim        = {XRANGE:[1d1,10d3],XSTYLE:1,YRANGE:[1d-18,2d-10],YSTYLE:1}
WSET,1
WSHOW,1
spec3d,dat0[0],UNITS=units,XDAT=energy0,YDAT=data0,LIMITS=s3d_lim,/RM_PHOTO_E,/PITCHANGLE

units          = 'df'
s3d_lim        = {XRANGE:[1d1,10d3],XSTYLE:1,YRANGE:[1d-18,2d-10],YSTYLE:1}
WSET,1
WSHOW,1
spec3d,dat0[0],UNITS=units,XDAT=energy0,YDAT=data0,LIMITS=s3d_lim,/RM_PHOTO_E,/SUNDIR

units          = 'df'
s3d_lim        = {XRANGE:[1d1,10d3],XSTYLE:1,YRANGE:[1d-18,2d-10],YSTYLE:1}
WSET,1
WSHOW,1
spec3d,dat0[0],UNITS=units,XDAT=energy0,YDAT=data0,LIMITS=s3d_lim,/RM_PHOTO_E,A_COLOR='ph'

units          = 'df'
s3d_lim        = {XRANGE:[1d1,10d3],XSTYLE:1,YRANGE:[1d-18,2d-10],YSTYLE:1}
WSET,1
WSHOW,1
spec3d,dat0[0],UNITS=units,XDAT=energy0,YDAT=data0,LIMITS=s3d_lim,/RM_PHOTO_E,A_COLOR='th'


;;  Test BINS keyword
units          = 'df'
s3d_lim        = {XRANGE:[1d0,10d3],XSTYLE:1,YRANGE:[1d-18,2d-10],YSTYLE:1}
gbins          = REPLICATE(0b,nnd[0])
gbins[[0,15,30,45]] = 1b
WSET,1
WSHOW,1
spec3d,dat0[0],UNITS=units,XDAT=energy0,YDAT=data0,LIMITS=s3d_lim,/RM_PHOTO_E,BINS=gbins

units          = 'df'
s3d_lim        = {XRANGE:[1d0,10d3],XSTYLE:1,YRANGE:[1d-18,2d-10],YSTYLE:1}
gbins          = [0,15,30,45]
WSET,2
WSHOW,2
spec3d,dat0[0],UNITS=units,XDAT=energy0,YDAT=data0,LIMITS=s3d_lim,/RM_PHOTO_E,BINS=gbins


data           = data0
energy         = energy0
dat2           = conv_units(dat0[0],units[0])
pos_data       = WHERE(data GT 0 AND FINITE(data),gpos,COMPLEMENT=bad_data,NCOMPLEMENT=bd)
IF (bd GT 0) THEN data[bad_data] = f
data2          = ALOG10(data)
ener2          = dat0[0].ENERGY
;;  Linearly interpolate the data
FOR j=0L, nnd[0] - 1L DO BEGIN                                     $
  x0         = REFORM(ener2[*,j])                                & $
  y0         = REFORM(data2[*,j])                                & $
  good2      = WHERE(FINITE(y0),gp2)                             & $
;  good2      = WHERE(y0 GT 0 AND FINITE(y0),gp2)                 & $
  IF (gp2 GT 5) THEN data2[*,j] = remove_nans(x0,y0,/NO_EXTRAPOLATE) ELSE data2[*,j] = f
;;  Redefine DATA
data2          = 1d1^(data2)
dat2[0].DATA   = data2

;;  Plot only peak look direction
mxdf           = MAX(data2,dlx,/NAN)
gindx          = ARRAY_INDICES(data,dlx)
mxbin          = gindx[1]
gbins          = REPLICATE(1b,nnd[0])
;gbins          = REPLICATE(0b,nnd[0])
;gbins[mxbin[0]] = 1b
;s3d_lim2       = {XRANGE:[1d0,25d3],XSTYLE:1,YSTYLE:1,PSYM:2}
s3d_lim2       = {XRANGE:[1d0,25d3],XSTYLE:1,YSTYLE:1}
WSET,2
WSHOW,2
spec3d,dat2[0],UNITS=units,LIMITS=s3d_lim2,BINS=gbins
;spec3d,dat0[0],UNITS=units,LIMITS=s3d_lim2,BINS=gbins





;;----------------------------------------------
;;  Check output
;;----------------------------------------------
;;  Define average azimuthal and poloidal angles
phi0           = average(dat0[0].PHI,1,/NAN)    ;; average phi
theta0         = average(dat0[0].THETA,1,/NAN)  ;; average theta
;;  Define the azimuthal and poloidal angle for VEC
xyz_to_polar,dat0[0].MAGF,THETA=bth0,PHI=bph0
;;  Define "pitch-angles" relative to VEC
pangs          = pangle(theta0,phi0,bth0,bph0)
;;  Force onto a byte-scale
pang_c         = bytescale(pangs,RANGE=[0.,180.])
















