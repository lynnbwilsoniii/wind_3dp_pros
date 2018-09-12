;;----------------------------------------------------------------------------------------
;;  Status Bar Legend
;;
;;    yellow       :  slow survey
;;    red          :  fast survey
;;    black below  :  particle burst
;;    black above  :  wave burst
;;
;;----------------------------------------------------------------------------------------

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
;;  Compile necessary routines
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

probe          = 'b'
tdate          = '2013-03-06'
date           = '030613'

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


;;---------------------------------------------
;;  Interesting time ranges [for THEMIS-C]
;;---------------------------------------------
;;  YYYY-MM-DD/hh:mm  YYYY-MM-DD/hh:mm
;;=============================================
;;  2008-06-21/07:21  2008-06-21/07:23
;;  2008-06-26/21:12  2008-06-26/21:14
;;  2008-07-07/05:21  2008-07-07/05:23
;;  2008-07-14/14:59  2008-07-14/15:01
;;  2008-07-14/20:03  2008-07-14/20:05
;;  2008-07-14/21:57  2008-07-14/21:59
;;  2008-07-14/23:25  2008-07-14/23:27
;;  2008-07-15/08:53  2008-07-15/08:55
;;  2008-07-15/09:13  2008-07-15/09:15
;;  2008-07-15/12:45  2008-07-15/12:47
;;  2008-08-11/05:08  2008-08-11/05:10
;;  2008-08-11/05:20  2008-08-11/05:22
;;  2008-08-11/05:28  2008-08-11/05:30
;;  2008-08-11/18:49  2008-08-11/18:51
;;  2008-08-12/01:05  2008-08-12/01:07
;;  2008-08-19/07:53  2008-08-19/07:55
;;  2008-08-19/12:49  2008-08-19/12:51
;;  2008-08-19/23:38  2008-08-19/23:40
;;  2008-08-22/22:18  2008-08-22/22:20
;;  2008-09-08/10:56  2008-09-08/10:58
;;  2008-09-08/17:01  2008-09-08/17:03
;;  2008-09-08/20:26  2008-09-08/20:28
;;  2008-09-09/19:26  2008-09-09/19:28
;;  2008-09-16/02:14  2008-09-16/02:16
;;  2008-10-03/19:34  2008-10-03/19:36
;;  2008-10-06/10:18  2008-10-06/10:20
;;  2008-10-09/23:30  2008-10-09/23:32
;;  2008-10-12/11:01  2008-10-12/11:03
;;  2008-10-20/07:58  2008-10-20/08:00
;;  2008-10-22/09:38  2008-10-22/09:40
;;  2008-10-29/22:13  2008-10-29/22:15
;;  2009-07-12/03:25  2009-07-12/03:27
;;  2009-07-12/03:51  2009-07-12/03:53
;;  2009-07-15/23:58  2009-07-16/00:00
;;  2009-07-16/07:14  2009-07-16/07:16
;;  2009-07-16/09:53  2009-07-16/09:55
;;  2009-07-25/22:30  2009-07-25/22:32
;;  2009-07-26/05:20  2009-07-26/05:22
;;  2009-07-26/05:42  2009-07-26/05:44
;;  2009-07-26/05:43  2009-07-26/05:45
;;  2009-07-26/09:34  2009-07-26/09:36
;;  2009-07-26/15:13  2009-07-26/15:15
;;  2009-09-06/12:44  2009-09-06/12:46
;;  2009-10-02/20:39  2009-10-02/20:41
;;  2009-10-05/13:54  2009-10-05/13:56
;;  2009-10-05/14:03  2009-10-05/14:05
;;  2009-10-05/14:13  2009-10-05/14:15
;;  2009-10-05/14:23  2009-10-05/14:25
;;  2009-10-13/01:33  2009-10-13/01:35
;;  2009-10-13/01:38  2009-10-13/01:40
;;---------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Load all relevant data
;;----------------------------------------------------------------------------------------
;@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_and_save_themis_foreshock_eVDFs_batch.pro
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/foreshock_eVDFs_fits/load_and_save_themis_foreshock_eVDFs_batch.pro

;;  Manually zoom to time range including fgh
tlimit

;;  Define |Bo| for fgs, fgl, and fgh
coord_mag      = 'mag'
fgm_modes      = 'fg'+['s','l','h']
tpn_names      = scpref[0]+fgm_modes+'_'+coord_mag[0]
scname         = STRUPCASE(STRMID(scpref[0],0,3))
;;  Define structures for ps_quick_file.pro
tags           = 'T'+STRTRIM(STRING(LINDGEN(5),FORMAT='(I2.2)'),2)
fgs_str        = CREATE_STRUCT(tags,fgm_modes[0],'B','DC',coord_mag[0],'L2')
fgl_str        = CREATE_STRUCT(tags,fgm_modes[1],'B','DC',coord_mag[0],'L2')
fgh_str        = CREATE_STRUCT(tags,fgm_modes[2],'B','DC',coord_mag[0],'L2')
fstr           = [fgs_str,fgl_str,fgh_str]
ps_quick_file,SPACECRAFT=scname[0],FIELDS=fstr

































