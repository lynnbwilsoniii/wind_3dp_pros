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

probe          = 'c'
tdate          = '2008-07-14'
date           = '071408'

probe          = 'c'
tdate          = '2008-08-12'
date           = '081208'

probe          = 'c'
tdate          = '2008-08-19'
date           = '081908'

probe          = 'c'
tdate          = '2008-09-08'
date           = '090808'

probe          = 'c'
tdate          = '2008-09-16'
date           = '091608'

probe          = 'c'
tdate          = '2008-10-03'
date           = '100308'

probe          = 'c'
tdate          = '2008-10-09'
date           = '100908'

probe          = 'c'
tdate          = '2008-10-12'
date           = '101208'

probe          = 'c'
tdate          = '2008-10-29'
date           = '102908'

probe          = 'c'
tdate          = '2009-07-25'
date           = '072509'

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

;;  Try using pointers?  str_element.pro gets progressively slower after time
pl_fit_pnt     = PTRARR(gnne[0],2L,/ALLOCATE_HEAP)
exp_fit_pnt    = PTRARR(gnne[0],2L,/ALLOCATE_HEAP)
plexp_fit_pnt  = PTRARR(gnne[0],2L,/ALLOCATE_HEAP)
;;########################################################################################
;;  Define version for output
;;########################################################################################
;; Change the file path accordingly for your system
;file     = 'temp_fit_evdf_para_perp_anti.pro'
mdir     = FILE_EXPAND_PATH('/Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/esa_mcp_software/')+'/'
file     = 'wrapper_evdf_fits_para_perp_anti.pro'
vers0    = routine_version(file,mdir)
;;  Remove time so it can be updated for each plot
gposi    = STRPOS(vers0[0],',')
vers1    = STRMID(vers0[0],0L,gposi[0] + 2L)     ;;  e.g., 'temp_fit_evdf_para_perp_anti.pro : 10/22/2014   v1.0.0, '

;;  Define "EXCEPT" tags
exc_tags = ['INIT_STRUC.EXTRAS.FIT_CONSTRAINTS','INIT_STRUC.FIT_STRUC']
;;------------------------------------------------
;;  Power-Law Fits
;;    Y = A X^(B) + C
;;------------------------------------------------
ex_start = SYSTIME(1)
FOR frame=0L, 1L DO BEGIN                                                                  $
  IF (frame EQ 1) THEN eran = scf_eran ELSE eran = swf_eran                              & $
  FOR k=0L, 0L DO BEGIN                                                                    $
    func           = all_funcs[k]                                                        & $
    jpref          = all_fr_str[frame]+all_jpref[k]                                      & $
    filedir        = all_dirs[frame,k]                                                   & $
    FOR j=0L, gnne[0] - 1L DO BEGIN                                                        $
      jstr = jpref[0]+STRTRIM(STRING(j[0],FORMAT='(I4.4)'),2L)                           & $
      curt    = time_string(SYSTIME(1,/SECONDS),PREC=3)+' UT'                            & $
      version = vers1[0]+curt[0]                                                         & $
      dat0 = gd_degse[j]                                                                 & $
      lim0 = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}    & $
      extr = {LIMITS:lim0,FIT_FUNC:func,ERA_1C_SC:1,PA_BIN_WD:pa_bin_wd,SC_FRAME:frame,    $
              E_RANGE:eran,FILE_DIR:filedir,VERSION:version[0]}                          & $
      temp = temp_fit_evdf_para_perp_anti(dat0,_EXTRA=extr)                              & $
      str_element,temp,exc_tags[0],/DELETE                                               & $
      str_element,temp,exc_tags[1],/DELETE                                               & $
      *pl_fit_pnt[j,frame] = temp
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

;;------------------------------------------------
;;  Exponential Fits
;;    Y = A e^(B X) + C
;;------------------------------------------------
ex_start = SYSTIME(1)
FOR frame=0L, 1L DO BEGIN                                                                  $
  IF (frame EQ 1) THEN eran = scf_eran ELSE eran = swf_eran                              & $
  FOR k=1L, 1L DO BEGIN                                                                    $
    func           = all_funcs[k]                                                        & $
    jpref          = all_fr_str[frame]+all_jpref[k]                                      & $
    filedir        = all_dirs[frame,k]                                                   & $
    FOR j=0L, gnne[0] - 1L DO BEGIN                                                        $
      jstr = jpref[0]+STRTRIM(STRING(j[0],FORMAT='(I4.4)'),2L)                           & $
      curt    = time_string(SYSTIME(1,/SECONDS),PREC=3)+' UT'                            & $
      version = vers1[0]+curt[0]                                                         & $
      dat0 = gd_degse[j]                                                                 & $
      lim0 = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}    & $
      extr = {LIMITS:lim0,FIT_FUNC:func,ERA_1C_SC:1,PA_BIN_WD:pa_bin_wd,SC_FRAME:frame,    $
              E_RANGE:eran,FILE_DIR:filedir,VERSION:version[0]}                          & $
      temp = temp_fit_evdf_para_perp_anti(dat0,_EXTRA=extr)                              & $
      str_element,temp,exc_tags[0],/DELETE                                               & $
      str_element,temp,exc_tags[1],/DELETE                                               & $
      *exp_fit_pnt[j,frame] = temp
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
SAVE,exp_fit_pnt,FILENAME=fitname

;;------------------------------------------------
;;  (Power-Law + Exponential) Fits
;;    Y = A X^(B) e^(C X) + D
;;------------------------------------------------
ex_start = SYSTIME(1)
FOR frame=0L, 1L DO BEGIN                                                                  $
  IF (frame EQ 1) THEN eran = scf_eran ELSE eran = swf_eran                              & $
  FOR k=2L, 2L DO BEGIN                                                                    $
    func           = all_funcs[k]                                                        & $
    jpref          = all_fr_str[frame]+all_jpref[k]                                      & $
    filedir        = all_dirs[frame,k]                                                   & $
    FOR j=0L, gnne[0] - 1L DO BEGIN                                                        $
      jstr = jpref[0]+STRTRIM(STRING(j[0],FORMAT='(I4.4)'),2L)                           & $
      curt    = time_string(SYSTIME(1,/SECONDS),PREC=3)+' UT'                            & $
      version = vers1[0]+curt[0]                                                         & $
      dat0 = gd_degse[j]                                                                 & $
      lim0 = {XRANGE:xran,XSTYLE:1,YRANGE:yran,YSTYLE:1,LABPOS:yposi,XMARGIN:[10,10]}    & $
      extr = {LIMITS:lim0,FIT_FUNC:func,ERA_1C_SC:1,PA_BIN_WD:pa_bin_wd,SC_FRAME:frame,    $
              E_RANGE:eran,FILE_DIR:filedir,VERSION:version[0]}                          & $
      temp = temp_fit_evdf_para_perp_anti(dat0,_EXTRA=extr)                              & $
      str_element,temp,exc_tags[0],/DELETE                                               & $
      str_element,temp,exc_tags[1],/DELETE                                               & $
      *plexp_fit_pnt[j,frame] = temp
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
SAVE,plexp_fit_pnt,FILENAME=fitname

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
