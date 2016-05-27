
FUNCTION temp_excited_cold_surf,lf_str,hf_str,tr_str,no_str,kv_str,bv_str,$
                                bm_str,NVEC=nvec,NDAT=ndat,PREFX=prefx,   $
                                NOMSSG=nom,DATE=date

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
epo            = 8.854187817d-12        ; => Permittivity of free space (F/m)
muo            = 4d0*!DPI*1d-7          ; => Permeability of free space (N/A^2 or H/m)
me             = 9.1093897d-31          ; => Electron mass (kg)
mp             = 1.6726231d-27          ; => Proton mass (kg)
qq             = 1.60217733d-19         ; => Fundamental charge (C)
K_eV           = 1.160474d4             ; => Conversion = degree Kelvin/eV
kB             = 1.380658d-23           ; => Boltzmann Constant (J/K)
c              = 2.99792458d8           ; => Speed of light in vacuum (m/s)
wcefac         = qq/me                  ; => Factor for angular electron cyclotron freq.
wcpfac         = qq/mp                  ; => Factor for angular proton cyclotron freq.
wpefac         = SQRT(qq^2/me/epo)      ; => Factor for angular electron plasma freq.
wppfac         = SQRT(qq^2/mp/epo)      ; => Factor for angular proton plasma freq.
tags           = ['t0','t1','t2','t3','t4','t5','t6','t7','t8','t9','t10','t11','t12','t13',$
                  't14','t15','t16','t17','t18','t19','t20','t21','t22','t23','t24']
;-----------------------------------------------------------------------------------------
; => Check date
;-----------------------------------------------------------------------------------------
mydate = my_str_date(DATE=date)
date   = mydate.S_DATE[0]  ; -('MMDDYY')
mdate  = mydate.DATE[0]    ; -('YYYYMMDD')
zdate  = ''                ; -['YYYY-MM-DD']
ldate  = mdate[0]
zdate  = mydate.TDATE[0]
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
test0 = (SIZE(lf_str,/TYPE) NE 0) OR (SIZE(hf_str,/TYPE) NE 0) OR $
        (SIZE(tr_str,/TYPE) NE 0) OR (SIZE(no_str,/TYPE) NE 0) OR $
        (SIZE(kv_str,/TYPE) NE 0) OR (SIZE(bv_str,/TYPE) NE 0) OR $
        (SIZE(bm_str,/TYPE) NE 0)
IF (N_PARAMS() EQ 7 AND test0) THEN GOTO,JUMP_SKIP_CASE
;-----------------------------------------------------------------------------------------
; => If not supplied, then supply below
;-----------------------------------------------------------------------------------------

CASE date[0] OF
  '121097' : BEGIN
    prefd  = '1997-12-10/'
;
; => For  2.5 Hz < f < 20 Hz  at  1997-12-10/04:33:15.605 UT
;
tr0     = time_double([prefd[0]+'04:33:15.8103',prefd[0]+'04:33:16.1612'])
tr1     = time_double([prefd[0]+'04:33:16.2748',prefd[0]+'04:33:16.3874'])
tr2     = time_double([prefd[0]+'04:33:16.3874',prefd[0]+'04:33:16.4722'])
tr3     = time_double([prefd[0]+'04:33:16.6162',prefd[0]+'04:33:16.6946'])
kvec0   = [ 0.68403,-0.48642, 0.54360]
kvec1   = [ 0.81891,-0.10754, 0.56375]
kvec2   = [ 0.97406, 0.22072,-0.04988]
kvec3   = [-0.30185,-0.85539,-0.42095]
dkvec0  = ABS([-0.30185,-0.85539,-0.42095])
dkvec1  = ABS([-0.30185,-0.85539,-0.42095])
dkvec2  = ABS([-0.30185,-0.85539,-0.42095])
dkvec3  = ABS([-0.30185,-0.85539,-0.42095])
elam0   = [96.58478,1.193800]
elam1   = [446.0954,3.972372]
elam2   = [56.45282,3.185235]
elam3   = [105.7124,6.277017]
bvec0   = [ 0.18202,-0.88395,-0.42956]
bvec1   = [ 0.12796,-0.87844,-0.46034]
bvec2   = [ 0.10310,-0.87890,-0.46570]
bvec3   = [ 0.13200,-0.87068,-0.47379]
bmag0   = [16.11884]
bmag1   = [15.99577]
bmag2   = [16.25960]
bmag3   = [16.88358]
tr_str_00 = CREATE_STRUCT(tags[0L:3L],tr0,tr1,tr2,tr3)
kv_str_00  = CREATE_STRUCT(tags[0L:3L],kvec0,kvec1,kvec2,kvec3)
bv_str_00  = CREATE_STRUCT(tags[0L:3L],bvec0,bvec1,bvec2,bvec3)
bm_str_00  = CREATE_STRUCT(tags[0L:3L],bmag0,bmag1,bmag2,bmag3)
eg_str_00  = CREATE_STRUCT(tags[0L:3L],elam0,elam1,elam2,elam3)
;
; => For  5 Hz < f < 20 Hz  at  1997-12-10/04:33:15.605 UT
;
tr0     = time_double([prefd[0]+'04:33:15.6626',prefd[0]+'04:33:15.7474'])
tr1     = time_double([prefd[0]+'04:33:15.7474',prefd[0]+'04:33:15.8332'])
tr2     = time_double([prefd[0]+'04:33:15.9138',prefd[0]+'04:33:16.0482'])
tr3     = time_double([prefd[0]+'04:33:16.2818',prefd[0]+'04:33:16.4706'])
kvec0   = [-0.93910,-0.04680,-0.34043]
kvec1   = [-0.97115,-0.23560,-0.03678]
kvec2   = [ 0.50057,-0.40599, 0.76460]
kvec3   = [-0.91903,-0.11778,-0.37619]
dkvec0  = ABS([-0.91903,-0.11778,-0.37619])
dkvec1  = ABS([-0.91903,-0.11778,-0.37619])
dkvec2  = ABS([-0.91903,-0.11778,-0.37619])
dkvec3  = ABS([-0.91903,-0.11778,-0.37619])
elam0   = [113.5504,3.093403]
elam1   = [148.5123,2.848682]
elam2   = [28.04291,1.196697]
elam3   = [104.8835,2.155593]
bvec0   = [ 0.22626,-0.91021,-0.34610]
bvec1   = [ 0.20760,-0.89294,-0.39931]
bvec2   = [ 0.18591,-0.88202,-0.43261]
bvec3   = [ 0.11680,-0.87872,-0.46260]
bmag0   = [15.49161]
bmag1   = [16.95673]
bmag2   = [15.62541]
bmag3   = [16.09916]
tr_str_01 = CREATE_STRUCT(tags[0L:3L],tr0,tr1,tr2,tr3)
kv_str_01  = CREATE_STRUCT(tags[0L:3L],kvec0,kvec1,kvec2,kvec3)
bv_str_01  = CREATE_STRUCT(tags[0L:3L],bvec0,bvec1,bvec2,bvec3)
bm_str_01  = CREATE_STRUCT(tags[0L:3L],bmag0,bmag1,bmag2,bmag3)
eg_str_01  = CREATE_STRUCT(tags[0L:3L],elam0,elam1,elam2,elam3)
;
; => For  20 Hz < f < 100 Hz  at  1997-12-10/04:33:15.605 UT
;
tr0     = time_double([prefd[0]+'04:33:15.9196',prefd[0]+'04:33:15.9580'])
tr1     = time_double([prefd[0]+'04:33:15.9986',prefd[0]+'04:33:16.0306'])
tr2     = time_double([prefd[0]+'04:33:16.2818',prefd[0]+'04:33:16.3074'])
tr3     = time_double([prefd[0]+'04:33:16.3250',prefd[0]+'04:33:16.3468'])
tr4     = time_double([prefd[0]+'04:33:16.3890',prefd[0]+'04:33:16.4210'])
kvec0   = [ 0.05839,-0.99634,-0.06242]
kvec1   = [ 0.03595, 0.88868, 0.45711]
kvec2   = [-0.23249,-0.89230,-0.38696]
kvec3   = [ 0.55222,-0.74685,-0.37050]
kvec4   = [-0.97167,-0.21784,-0.09167]
dkvec0  = ABS([-0.97167,-0.21784,-0.09167])
dkvec1  = ABS([-0.97167,-0.21784,-0.09167])
dkvec2  = ABS([-0.97167,-0.21784,-0.09167])
dkvec3  = ABS([-0.97167,-0.21784,-0.09167])
dkvec4  = ABS([-0.97167,-0.21784,-0.09167])
elam0   = [38.28363,2.996438]
elam1   = [112.1144,1.299654]
elam2   = [38.47570,6.624100]
elam3   = [77.38411,3.597302]
elam4   = [31.57337,11.69731]
bvec0   = [ 0.20316,-0.87657,-0.43627]
bvec1   = [ 0.17165,-0.88697,-0.42871]
bvec2   = [ 0.13254,-0.87748,-0.46093]
bvec3   = [ 0.13232,-0.87832,-0.45938]
bvec4   = [ 0.10362,-0.88091,-0.46179]
bmag0   = [15.81205]
bmag1   = [15.51477]
bmag2   = [16.11753]
bmag3   = [15.89856]
bmag4   = [16.00851]
tr_str_02 = CREATE_STRUCT(tags[0L:4L],tr0,tr1,tr2,tr3,tr4)
kv_str_02  = CREATE_STRUCT(tags[0L:4L],kvec0,kvec1,kvec2,kvec3,kvec4)
bv_str_02  = CREATE_STRUCT(tags[0L:4L],bvec0,bvec1,bvec2,bvec3,bvec4)
bm_str_02  = CREATE_STRUCT(tags[0L:4L],bmag0,bmag1,bmag2,bmag3,bmag4)
eg_str_02  = CREATE_STRUCT(tags[0L:4L],elam0,elam1,elam2,elam3,elam4)
;
; => For  30 Hz < f < 100 Hz  at  1997-12-10/04:33:15.605 UT
;
tr0     = time_double([prefd[0]+'04:33:15.7815',prefd[0]+'04:33:15.8130'])
tr1     = time_double([prefd[0]+'04:33:15.8690',prefd[0]+'04:33:15.8882'])
tr2     = time_double([prefd[0]+'04:33:16.2946',prefd[0]+'04:33:16.3154'])
tr3     = time_double([prefd[0]+'04:33:16.3314',prefd[0]+'04:33:16.3522'])
tr4     = time_double([prefd[0]+'04:33:16.3602',prefd[0]+'04:33:16.3836'])
tr5     = time_double([prefd[0]+'04:33:16.4514',prefd[0]+'04:33:16.4754'])
kvec0   = [-0.88348, 0.02381,-0.46787]
kvec1   = [ 0.51037,-0.71242, 0.48164]
kvec2   = [-0.11486, 0.76815, 0.62988]
kvec3   = [ 0.73296,-0.56850,-0.37361]
kvec4   = [-0.98644, 0.16236, 0.02416]
kvec5   = [-0.77078,-0.27676,-0.57385]
dkvec0  = ABS([-0.77078,-0.27676,-0.57385])
dkvec1  = ABS([-0.77078,-0.27676,-0.57385])
dkvec2  = ABS([-0.77078,-0.27676,-0.57385])
dkvec3  = ABS([-0.77078,-0.27676,-0.57385])
dkvec4  = ABS([-0.77078,-0.27676,-0.57385])
dkvec5  = ABS([-0.77078,-0.27676,-0.57385])
elam0   = [191.7947,2.775103]
elam1   = [36.46038,6.188570]
elam2   = [46.41595,3.434396]
elam3   = [39.24726,3.172341]
elam4   = [19.11506,6.359791]
elam5   = [270.9110,1.245265]
bvec0   = [ 0.20690,-0.89160,-0.40279]
bvec1   = [ 0.21641,-0.88032,-0.42214]
bvec2   = [ 0.13388,-0.87762,-0.46029]
bvec3   = [ 0.12976,-0.87859,-0.45961]
bvec4   = [ 0.11732,-0.87978,-0.46066]
bvec5   = [ 0.10485,-0.87557,-0.47156]
bmag0   = [17.04673]
bmag1   = [16.84607]
bmag2   = [16.03882]
bmag3   = [15.90741]
bmag4   = [15.95254]
bmag5   = [16.65421]
tr_str_03 = CREATE_STRUCT(tags[0L:5L],tr0,tr1,tr2,tr3,tr4,tr5)
kv_str_03 = CREATE_STRUCT(tags[0L:5L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5)
bv_str_03 = CREATE_STRUCT(tags[0L:5L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5)
bm_str_03 = CREATE_STRUCT(tags[0L:5L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5)
eg_str_03 = CREATE_STRUCT(tags[0L:5L],elam0,elam1,elam2,elam3,elam4,elam5)
;
; => For  40 Hz < f < 200 Hz  at  1997-12-10/04:33:15.605 UT
;
tr0     = time_double([prefd[0]+'04:33:15.7714',prefd[0]+'04:33:15.8130'])
tr1     = time_double([prefd[0]+'04:33:15.9106',prefd[0]+'04:33:15.9890'])
tr2     = time_double([prefd[0]+'04:33:16.2802',prefd[0]+'04:33:16.3042'])
tr3     = time_double([prefd[0]+'04:33:16.3602',prefd[0]+'04:33:16.3762'])
tr4     = time_double([prefd[0]+'04:33:16.4322',prefd[0]+'04:33:16.4412'])
kvec0   = [ 0.96398,-0.26284, 0.04066]
kvec1   = [ 0.94528,-0.31998, 0.06364]
kvec2   = [-0.07267,-0.93689,-0.34200]
kvec3   = [-0.74666,-0.63494,-0.19836]
kvec4   = [-0.29323,-0.74049,-0.60473]
dkvec0  = ABS([-0.29323,-0.74049,-0.60473])
dkvec1  = ABS([-0.29323,-0.74049,-0.60473])
dkvec2  = ABS([-0.29323,-0.74049,-0.60473])
dkvec3  = ABS([-0.29323,-0.74049,-0.60473])
dkvec4  = ABS([-0.29323,-0.74049,-0.60473])
elam0   = [22.77719,1.569511]
elam1   = [14.19772,3.124856]
elam2   = [40.04663,4.230864]
elam3   = [23.18955,2.058274]
elam4   = [27.73853,4.237506]
bvec0   = [ 0.20602,-0.89237,-0.40152]
bvec1   = [ 0.19904,-0.87756,-0.43612]
bvec2   = [ 0.13223,-0.87745,-0.46108]
bvec3   = [ 0.11876,-0.87965,-0.46055]
bvec4   = [ 0.10109,-0.87892,-0.46613]
bmag0   = [17.04379]
bmag1   = [15.73206]
bmag2   = [16.13570]
bmag3   = [15.94714]
bmag4   = [16.28558]
tr_str_04 = CREATE_STRUCT(tags[0L:4L],tr0,tr1,tr2,tr3,tr4)
kv_str_04  = CREATE_STRUCT(tags[0L:4L],kvec0,kvec1,kvec2,kvec3,kvec4)
bv_str_04  = CREATE_STRUCT(tags[0L:4L],bvec0,bvec1,bvec2,bvec3,bvec4)
bm_str_04  = CREATE_STRUCT(tags[0L:4L],bmag0,bmag1,bmag2,bmag3,bmag4)
eg_str_04  = CREATE_STRUCT(tags[0L:4L],elam0,elam1,elam2,elam3,elam4)
;
; => For  100 Hz < f < 200 Hz  at  1997-12-10/04:33:15.605 UT
;
tr0     = time_double([prefd[0]+'04:33:16.3826',prefd[0]+'04:33:16.3996'])
tr1     = time_double([prefd[0]+'04:33:16.4050',prefd[0]+'04:33:16.4210'])
tr2     = time_double([prefd[0]+'04:33:16.4322',prefd[0]+'04:33:16.4578'])
tr3     = time_double([prefd[0]+'04:33:16.4578',prefd[0]+'04:33:16.4706'])
kvec0   = [-0.77058, 0.30337,-0.56050]
kvec1   = [-0.54645,-0.42471,-0.72182]
kvec2   = [-0.38518,-0.71445,-0.58413]
kvec3   = [-0.45882,-0.75824,-0.46319]
dkvec0  = ABS([-0.45882,-0.75824,-0.46319])
dkvec1  = ABS([-0.45882,-0.75824,-0.46319])
dkvec2  = ABS([-0.45882,-0.75824,-0.46319])
dkvec3  = ABS([-0.45882,-0.75824,-0.46319])
elam0   = [20.66103,1.202361]
elam1   = [209.2267,2.495151]
elam2   = [14.56270,5.114054]
elam3   = [22.83043,8.932517]
bvec0   = [ 0.10935,-0.88048,-0.46130]
bvec1   = [ 0.10043,-0.88113,-0.46208]
bvec2   = [ 0.10230,-0.87785,-0.46788]
bvec3   = [ 0.10495,-0.87548,-0.47172]
bmag0   = [15.98283]
bmag1   = [16.02419]
bmag2   = [16.40230]
bmag3   = [16.66516]
tr_str_05 = CREATE_STRUCT(tags[0L:3L],tr0,tr1,tr2,tr3)
kv_str_05  = CREATE_STRUCT(tags[0L:3L],kvec0,kvec1,kvec2,kvec3)
bv_str_05  = CREATE_STRUCT(tags[0L:3L],bvec0,bvec1,bvec2,bvec3)
bm_str_05  = CREATE_STRUCT(tags[0L:3L],bmag0,bmag1,bmag2,bmag3)
eg_str_05  = CREATE_STRUCT(tags[0L:3L],elam0,elam1,elam2,elam3)
;
; => For  100 Hz < f < 400 Hz  at  1997-12-10/04:33:15.605 UT
;
tr0     = time_double([prefd[0]+'04:33:16.3842',prefd[0]+'04:33:16.3964'])
tr1     = time_double([prefd[0]+'04:33:16.4066',prefd[0]+'04:33:16.4258'])
tr2     = time_double([prefd[0]+'04:33:16.4332',prefd[0]+'04:33:16.4524'])
tr3     = time_double([prefd[0]+'04:33:16.4562',prefd[0]+'04:33:16.4642'])
kvec0   = [-0.76165, 0.32894,-0.55829]
kvec1   = [ 0.59091, 0.34742, 0.72810]
kvec2   = [-0.40189,-0.69595,-0.59510]
kvec3   = [-0.41781,-0.80555,-0.42015]
dkvec0  = ABS([-0.41781,-0.80555,-0.42015])
dkvec1  = ABS([-0.41781,-0.80555,-0.42015])
dkvec2  = ABS([-0.41781,-0.80555,-0.42015])
dkvec3  = ABS([-0.41781,-0.80555,-0.42015])
elam0   = [25.17809,1.315200]
elam1   = [28.54558,2.129758]
elam2   = [13.94615,4.722475]
elam3   = [26.54913,8.395762]
bvec0   = [ 0.10968,-0.88045,-0.46128]
bvec1   = [ 0.09991,-0.88100,-0.46244]
bvec2   = [ 0.10196,-0.87815,-0.46739]
bvec3   = [ 0.10441,-0.87597,-0.47093]
bmag0   = [15.98153]
bmag1   = [16.04666]
bmag2   = [16.36946]
bmag3   = [16.61035]
tr_str_06 = CREATE_STRUCT(tags[0L:3L],tr0,tr1,tr2,tr3)
kv_str_06  = CREATE_STRUCT(tags[0L:3L],kvec0,kvec1,kvec2,kvec3)
bv_str_06  = CREATE_STRUCT(tags[0L:3L],bvec0,bvec1,bvec2,bvec3)
bm_str_06  = CREATE_STRUCT(tags[0L:3L],bmag0,bmag1,bmag2,bmag3)
eg_str_06  = CREATE_STRUCT(tags[0L:3L],elam0,elam1,elam2,elam3)
tr_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4','T5','T6'],tr_str_00,$
                           tr_str_01,tr_str_02,tr_str_03,tr_str_04,tr_str_05, $
                           tr_str_06)
kv_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4','T5','T6'],kv_str_00,$
                           kv_str_01,kv_str_02,kv_str_03,kv_str_04,kv_str_05, $
                           kv_str_06)
bv_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4','T5','T6'],bv_str_00,$
                           bv_str_01,bv_str_02,bv_str_03,bv_str_04,bv_str_05, $
                           bv_str_06)
bm_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4','T5','T6'],bm_str_00,$
                           bm_str_01,bm_str_02,bm_str_03,bm_str_04,bm_str_05, $
                           bm_str_06)
eg_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4','T5','T6'],eg_str_00,$
                           eg_str_01,eg_str_02,eg_str_03,eg_str_04,eg_str_05, $
                           eg_str_06)
tags      = ['t0']
tr_str    = CREATE_STRUCT(tags,tr_str_0)
kv_str    = CREATE_STRUCT(tags,kv_str_0)
bv_str    = CREATE_STRUCT(tags,bv_str_0)
bm_str    = CREATE_STRUCT(tags,bm_str_0)
eg_str    = CREATE_STRUCT(tags,eg_str_0)
lfc0      = [2.5d0,5d0,2d1,3d1,4d1,1d2,1d2]   ; => For 1997-12-10/04:33:15.605 UT
hfc0      = [2d1  ,2d1,1d2,1d2,2d2,2d2,4d2]   ; => For 1997-12-10/04:33:15.605 UT
lf_str    = CREATE_STRUCT(tags,lfc0)
hf_str    = CREATE_STRUCT(tags,hfc0)
no_str    = CREATE_STRUCT(tags,14.002)
nvec       = [-0.903, 0.168,-0.397]   ; => Using RH08 from JCK's site
scet_1210  = ['1997/12/10 04:33:15.605']+' UT'
scets0     = string_replace_char(STRMID(scet_1210[*],0L,23L),'/','-')
scets1     = string_replace_char(scets0,' ','/')
tr0        = file_name_times(scets1,PREC=3)   
prefx      = tr0.F_TIME
  END
;-----------------------------------------------------------------------------------------
  '082698' : BEGIN
    prefd     = '1998-08-26/'
;
; => For  4 Hz < f < 20 Hz  at  1998/08/26 06:40:26.120 UT
;
tr0       = time_double([prefd[0]+'06:40:26.2501',prefd[0]+'06:40:26.5269'])
kvec0     = [-0.75528, 0.55880,-0.34249]
bvec0     = [-0.09312, 0.98823, 0.11685]
bmag0     = [17.64474]
elam0     = [45.233531,1.2735423]
tr_str_00 = CREATE_STRUCT(tags[0L:0L],tr0)
kv_str_00 = CREATE_STRUCT(tags[0L:0L],kvec0)
bv_str_00 = CREATE_STRUCT(tags[0L:0L],bvec0)
bm_str_00 = CREATE_STRUCT(tags[0L:0L],bmag0)
eg_str_00 = CREATE_STRUCT(tags[0L:0L],elam0)
;
; => For  7 Hz < f < 30 Hz  at  1998/08/26 06:40:26.120 UT
;
tr0       = time_double([prefd[0]+'06:40:26.2704',prefd[0]+'06:40:26.7296'])
tr1       = time_double([prefd[0]+'06:40:26.2720',prefd[0]+'06:40:26.6245'])
tr2       = time_double([prefd[0]+'06:40:26.2731',prefd[0]+'06:40:26.5776'])
tr3       = time_double([prefd[0]+'06:40:26.2741',prefd[0]+'06:40:26.5248'])
tr4       = time_double([prefd[0]+'06:40:26.6053',prefd[0]+'06:40:26.7899'])
tr5       = time_double([prefd[0]+'06:40:26.4251',prefd[0]+'06:40:26.7845'])
tr6       = time_double([prefd[0]+'06:40:26.7904',prefd[0]+'06:40:26.8896'])
tr7       = time_double([prefd[0]+'06:40:26.9253',prefd[0]+'06:40:27.0661'])
kvec0   = [ 0.88528,-0.11080, 0.45167]
kvec1   = [ 0.88917,-0.30740, 0.33895]
kvec2   = [-0.81224, 0.45489,-0.36516]
kvec3   = [-0.74506, 0.56526,-0.35408]
kvec4   = [ 0.89282, 0.03908, 0.44872]
kvec5   = [ 0.90320,-0.05326, 0.42590]
kvec6   = [-0.92841,-0.36634, 0.06200]
kvec7   = [ 0.95386, 0.21550, 0.20907]
bvec0   = [-0.07556, 0.98903, 0.05111]
bvec1   = [-0.09954, 0.98837, 0.10659]
bvec2   = [-0.09956, 0.98753, 0.11718]
bvec3   = [-0.09312, 0.98823, 0.11646]
bvec4   = [ 0.00914, 0.98721,-0.13268]
bvec5   = [-0.05223, 0.98609,-0.00412]
bvec6   = [-0.01856, 0.99266,-0.11068]
bvec7   = [ 0.02999, 0.99886,-0.03120]
bmag0   = [18.70196]
bmag1   = [18.33008]
bmag2   = [18.07262]
bmag3   = [17.71259]
bmag4   = [19.78089]
bmag5   = [19.48486]
bmag6   = [18.30282]
bmag7   = [19.01694]
elam0   = [11.369266,1.5493357]
elam1   = [13.394446,1.5012153]
elam2   = [30.811204,1.2267413]
elam3   = [79.826478,1.1297338]
elam4   = [24.020896,1.5808126]
elam5   = [11.332868,1.6004137]
elam6   = [34.964636,2.1990164]
elam7   = [30.394394,4.6116373]
tr_str_01 = CREATE_STRUCT(tags[0L:7L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7)
kv_str_01 = CREATE_STRUCT(tags[0L:7L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7)
bv_str_01 = CREATE_STRUCT(tags[0L:7L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7)
bm_str_01 = CREATE_STRUCT(tags[0L:7L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7)
eg_str_01 = CREATE_STRUCT(tags[0L:7L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7)
;
; => For 10 Hz < f < 30 Hz  at  1998/08/26 06:40:26.120 UT
;
tr0       = time_double([prefd[0]+'06:40:26.3237',prefd[0]+'06:40:26.5264'])
tr1       = time_double([prefd[0]+'06:40:26.3744',prefd[0]+'06:40:26.4997'])
tr2       = time_double([prefd[0]+'06:40:26.3920',prefd[0]+'06:40:26.6000'])
tr3       = time_double([prefd[0]+'06:40:26.3920',prefd[0]+'06:40:26.5899'])
tr4       = time_double([prefd[0]+'06:40:26.6656',prefd[0]+'06:40:27.2117'])
tr5       = time_double([prefd[0]+'06:40:26.6656',prefd[0]+'06:40:27.0400'])
tr6       = time_double([prefd[0]+'06:40:26.6656',prefd[0]+'06:40:27.0197'])
kvec0   = [ 0.97753,-0.19375, 0.08310]
kvec1   = [ 0.98265,-0.18422, 0.02172]
kvec2   = [ 0.98946,-0.09520,-0.10915]
kvec3   = [-0.98757, 0.10656, 0.11557]
kvec4   = [ 0.93488,-0.22788, 0.27217]
kvec5   = [-0.93604, 0.22445,-0.27100]
kvec6   = [-0.93492, 0.22550,-0.27399]
bvec0   = [-0.09959, 0.98680, 0.12427]
bvec1   = [-0.10322, 0.98548, 0.13300]
bvec2   = [-0.11300, 0.98505, 0.12696]
bvec3   = [-0.11326, 0.98465, 0.13068]
bvec4   = [ 0.02046, 0.99382,-0.06466]
bvec5   = [ 0.01502, 0.99164,-0.10498]
bvec6   = [ 0.01290, 0.99125,-0.10946]
bmag0   = [17.95993]
bmag1   = [18.05028]
bmag2   = [18.90074]
bmag3   = [18.84022]
bmag4   = [18.93319]
bmag5   = [19.00311]
bmag6   = [19.00202]
elam0   = [24.959507,1.1318334]
elam1   = [79.445986,1.1979660]
elam2   = [48.277253,1.0837785]
elam3   = [45.040525,1.2288479]
elam4   = [20.044077,1.0676473]
elam5   = [25.678349,1.0526309]
elam6   = [29.448864,1.0521651]
tr_str_02 = CREATE_STRUCT(tags[0L:6L],tr0,tr1,tr2,tr3,tr4,tr5,tr6)
kv_str_02 = CREATE_STRUCT(tags[0L:6L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6)
bv_str_02 = CREATE_STRUCT(tags[0L:6L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6)
bm_str_02 = CREATE_STRUCT(tags[0L:6L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6)
eg_str_02 = CREATE_STRUCT(tags[0L:6L],elam0,elam1,elam2,elam3,elam4,elam5,elam6)
;
; => For 40 Hz < f < 400 Hz  at  1998/08/26 06:40:26.120 UT
;
tr0       = time_double([prefd[0]+'06:40:26.5301',prefd[0]+'06:40:26.6309'])
tr1       = time_double([prefd[0]+'06:40:26.5301',prefd[0]+'06:40:26.6245'])
tr2       = time_double([prefd[0]+'06:40:26.5536',prefd[0]+'06:40:26.6245'])
tr3       = time_double([prefd[0]+'06:40:26.5547',prefd[0]+'06:40:26.6197'])
tr4       = time_double([prefd[0]+'06:40:27.0645',prefd[0]+'06:40:27.1019'])
tr5       = time_double([prefd[0]+'06:40:27.0645',prefd[0]+'06:40:27.1008'])
tr6       = time_double([prefd[0]+'06:40:27.0672',prefd[0]+'06:40:27.1008'])
tr7       = time_double([prefd[0]+'06:40:27.0693',prefd[0]+'06:40:27.0896'])
tr8       = time_double([prefd[0]+'06:40:27.0891',prefd[0]+'06:40:27.0992'])
tr9       = time_double([prefd[0]+'06:40:27.1109',prefd[0]+'06:40:27.1189'])
kvec0   = [-0.94571,-0.32443, 0.01933]
kvec1   = [-0.95320,-0.30214, 0.01062]
kvec2   = [-0.94307,-0.33022, 0.03975]
kvec3   = [-0.95488,-0.29440, 0.03924]
kvec4   = [ 0.22309,-0.97434,-0.02993]
kvec5   = [ 0.22294,-0.97431,-0.03192]
kvec6   = [ 0.22949,-0.97296,-0.02617]
kvec7   = [-0.20060, 0.97763, 0.06322]
kvec8   = [ 0.36635,-0.92961, 0.04006]
kvec9   = [ 0.59689,-0.79017, 0.13910]
bvec0   = [-0.11065, 0.98948, 0.07512]
bvec1   = [-0.11394, 0.98892, 0.08174]
bvec2   = [-0.11069, 0.99045, 0.06727]
bvec3   = [-0.11325, 0.99007, 0.07160]
bvec4   = [ 0.03830, 0.99924,-0.00150]
bvec5   = [ 0.03849, 0.99923,-0.00180]
bvec6   = [ 0.03801, 0.99925,-0.00103]
bvec7   = [ 0.03964, 0.99920,-0.00365]
bvec8   = [ 0.03426, 0.99940, 0.00498]
bvec9   = [ 0.02693, 0.99950, 0.01675]
bmag0   = [19.95038]
bmag1   = [19.94608]
bmag2   = [20.05509]
bmag3   = [20.06384]
bmag4   = [18.88103]
bmag5   = [18.88249]
bmag6   = [18.87871]
bmag7   = [18.89113]
bmag8   = [18.84988]
bmag9   = [18.79719]
elam0   = [10.52580,1.760759]
elam1   = [11.51083,1.799406]
elam2   = [13.83718,1.806977]
elam3   = [16.71457,1.719318]
elam4   = [11.34309,1.514604]
elam5   = [11.86638,1.515406]
elam6   = [13.12482,1.526484]
elam7   = [20.78835,1.301744]
elam8   = [42.05218,2.455791]
elam9   = [34.63979,2.646214]
tr_str_03 = CREATE_STRUCT(tags[0L:9L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9)
kv_str_03 = CREATE_STRUCT(tags[0L:9L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,kvec9)
bv_str_03 = CREATE_STRUCT(tags[0L:9L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,bvec9)
bm_str_03 = CREATE_STRUCT(tags[0L:9L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,bmag9)
eg_str_03 = CREATE_STRUCT(tags[0L:9L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,elam9)
;
; => For 60 Hz < f < 500 Hz  at  1998/08/26 06:40:26.120 UT
;
tr_str_04 = 0
kv_str_04 = 0
bv_str_04 = 0
bm_str_04 = 0
eg_str_04 = 0
;
; => For 60 Hz < f < 200 Hz  at  1998/08/26 06:40:26.120 UT
;
tr0       = time_double([prefd[0]+'06:40:26.5813',prefd[0]+'06:40:26.6197'])
tr1       = time_double([prefd[0]+'06:40:26.6768',prefd[0]+'06:40:26.7147'])
tr2       = time_double([prefd[0]+'06:40:26.8784',prefd[0]+'06:40:26.9248'])
tr3       = time_double([prefd[0]+'06:40:27.0640',prefd[0]+'06:40:27.0992'])
tr4       = time_double([prefd[0]+'06:40:27.1056',prefd[0]+'06:40:27.1184'])
kvec0   = [-0.97078,-0.01012, 0.23974]
kvec1   = [-0.65773, 0.44369,-0.60872]
kvec2   = [-0.73401,-0.65436,-0.18178]
kvec3   = [ 0.25802,-0.96360,-0.06999]
kvec4   = [ 0.33709,-0.93821,-0.07830]
bvec0   = [-0.10111, 0.99330, 0.04603]
bvec1   = [ 0.01916, 0.98800,-0.15250]
bvec2   = [-0.02029, 0.99807,-0.05769]
bvec3   = [ 0.03887, 0.99922,-0.00242]
bvec4   = [ 0.02790, 0.99949, 0.01520]
bmag0   = [20.07243]
bmag1   = [19.93110]
bmag2   = [18.53309]
bmag3   = [18.88544]
bmag4   = [18.80395]
elam0   = [25.65646,1.405713]
elam1   = [10.19848,2.709354]
elam2   = [12.79326,1.363889]
elam3   = [51.57766,1.170164]
elam4   = [30.86751,2.074014]
tr_str_05 = CREATE_STRUCT(tags[0L:4L],tr0,tr1,tr2,tr3,tr4)
kv_str_05 = CREATE_STRUCT(tags[0L:4L],kvec0,kvec1,kvec2,kvec3,kvec4)
bv_str_05 = CREATE_STRUCT(tags[0L:4L],bvec0,bvec1,bvec2,bvec3,bvec4)
bm_str_05 = CREATE_STRUCT(tags[0L:4L],bmag0,bmag1,bmag2,bmag3,bmag4)
eg_str_05 = CREATE_STRUCT(tags[0L:4L],elam0,elam1,elam2,elam3,elam4)
;
; => For 60 Hz < f < 150 Hz  at  1998/08/26 06:40:26.120 UT
;
tr0       = time_double([prefd[0]+'06:40:27.0528',prefd[0]+'06:40:27.1051'])
kvec0   = [ 0.23114,-0.97065,-0.06637]
bvec0   = [ 0.03983, 0.99915,-0.00396]
bmag0   = [18.89349]
elam0   = [31.09800,1.259110]
tr_str_06 = CREATE_STRUCT(tags[0L:0L],tr0)
kv_str_06 = CREATE_STRUCT(tags[0L:0L],kvec0)
bv_str_06 = CREATE_STRUCT(tags[0L:0L],bvec0)
bm_str_06 = CREATE_STRUCT(tags[0L:0L],bmag0)
eg_str_06 = CREATE_STRUCT(tags[0L:0L],elam0)
;
; => For 150 Hz < f < 200 Hz  at  1998/08/26 06:40:26.120 UT
;
tr0       = time_double([prefd[0]+'06:40:26.7200',prefd[0]+'06:40:26.8000'])
tr1       = time_double([prefd[0]+'06:40:26.7301',prefd[0]+'06:40:26.7899'])
tr2       = time_double([prefd[0]+'06:40:26.7301',prefd[0]+'06:40:26.7659'])
tr3       = time_double([prefd[0]+'06:40:27.0325',prefd[0]+'06:40:27.0725'])
kvec0   = [-0.07895,-0.99658, 0.02448]
kvec1   = [-0.06465,-0.99725, 0.03609]
kvec2   = [-0.02118,-0.99832, 0.05399]
kvec3   = [-0.23192,-0.97041,-0.06713]
bvec0   = [ 0.05342, 0.97874,-0.19698]
bvec1   = [ 0.05889, 0.97723,-0.20328]
bvec2   = [ 0.06308, 0.97619,-0.20715]
bvec3   = [ 0.04915, 0.99858,-0.01916]
bmag0   = [19.33826]
bmag1   = [19.36724]
bmag2   = [19.53251]
bmag3   = [18.97081]
elam0   = [9.136816,1.936666]
elam1   = [14.76190,2.084845]
elam2   = [29.83702,1.874888]
elam3   = [18.97383,1.299618]
tr_str_07 = CREATE_STRUCT(tags[0L:3L],tr0,tr1,tr2,tr3)
kv_str_07 = CREATE_STRUCT(tags[0L:3L],kvec0,kvec1,kvec2,kvec3)
bv_str_07 = CREATE_STRUCT(tags[0L:3L],bvec0,bvec1,bvec2,bvec3)
bm_str_07 = CREATE_STRUCT(tags[0L:3L],bmag0,bmag1,bmag2,bmag3)
eg_str_07 = CREATE_STRUCT(tags[0L:3L],elam0,elam1,elam2,elam3)
tr_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4','T5','T6','T7'],tr_str_00,$
                           tr_str_01,tr_str_02,tr_str_03,tr_str_04,tr_str_05, $
                           tr_str_06,tr_str_07)
kv_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4','T5','T6','T7'],kv_str_00,$
                           kv_str_01,kv_str_02,kv_str_03,kv_str_04,kv_str_05, $
                           kv_str_06,kv_str_07)
bv_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4','T5','T6','T7'],bv_str_00,$
                           bv_str_01,bv_str_02,bv_str_03,bv_str_04,bv_str_05, $
                           bv_str_06,bv_str_07)
bm_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4','T5','T6','T7'],bm_str_00,$
                           bm_str_01,bm_str_02,bm_str_03,bm_str_04,bm_str_05, $
                           bm_str_06,bm_str_07)
eg_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4','T5','T6','T7'],eg_str_00,$
                           eg_str_01,eg_str_02,eg_str_03,eg_str_04,eg_str_05, $
                           eg_str_06,eg_str_07)
;
; => For  3 Hz < f < 30 Hz  at  1998-08-26/06:40:54.941 UT
;
prefd   = '1998-08-26/'
tr0     = time_double([prefd[0]+'06:40:55.9202',prefd[0]+'06:40:56.0141'])
tr1     = time_double([prefd[0]+'06:40:55.9442',prefd[0]+'06:40:56.0141'])
kvec0   = [ 0.52086,-0.68992, 0.50270]
kvec1   = [-0.38681, 0.70088,-0.59929]
elam0   = [27.651000,1.4960640]
elam1   = [149.76101,4.0979031]
bvec0   = [-0.53815, 0.57695, 0.61443]
bvec1   = [-0.53737, 0.57671, 0.61533]
bmag0   = [21.41130]
bmag1   = [21.39625]
tr_str_10 = CREATE_STRUCT(tags[0L:1L],tr0,tr1)
kv_str_10 = CREATE_STRUCT(tags[0L:1L],kvec0,kvec1)
bv_str_10 = CREATE_STRUCT(tags[0L:1L],bvec0,bvec1)
bm_str_10 = CREATE_STRUCT(tags[0L:1L],bmag0,bmag1)
eg_str_10 = CREATE_STRUCT(tags[0L:1L],elam0,elam1)
tr_str_1  = CREATE_STRUCT(['T0'],tr_str_10)
kv_str_1  = CREATE_STRUCT(['T0'],kv_str_10)
bv_str_1  = CREATE_STRUCT(['T0'],bv_str_10)
bm_str_1  = CREATE_STRUCT(['T0'],bm_str_10)
eg_str_1  = CREATE_STRUCT(['T0'],eg_str_10)
;
; => For  3 Hz < f < 30 Hz  at  1998-08-26/06:41:10.001 UT
;
prefd   = '1998-08-26/'
tr0     = time_double([prefd[0]+'06:41:10.0538',prefd[0]+'06:41:10.1093'])
tr1     = time_double([prefd[0]+'06:41:10.2554',prefd[0]+'06:41:10.3242'])
tr2     = time_double([prefd[0]+'06:41:10.3247',prefd[0]+'06:41:10.4618'])
tr3     = time_double([prefd[0]+'06:41:10.4623',prefd[0]+'06:41:10.5642'])
tr4     = time_double([prefd[0]+'06:41:10.6010',prefd[0]+'06:41:10.6778'])
tr5     = time_double([prefd[0]+'06:41:10.7605',prefd[0]+'06:41:10.8693'])
tr6     = time_double([prefd[0]+'06:41:11.0634',prefd[0]+'06:41:11.0927'])
kvec0   = [ 0.88332, 0.12394,-0.45209]
kvec1   = [ 0.11374,-0.01262,-0.99343]
kvec2   = [ 0.34592, 0.08953, 0.93398]
kvec3   = [ 0.47222,-0.29015, 0.83236]
kvec4   = [-0.58702,-0.34816,-0.73089]
kvec5   = [-0.44233,-0.16770,-0.88103]
kvec6   = [ 0.48910, 0.49246, 0.71991]
elam0   = [26.980988,2.5218807]
elam1   = [17.490835,2.6499166]
elam2   = [69.054751,2.9738111]
elam3   = [28.710902,2.3045157]
elam4   = [53.723311,16.734548]
elam5   = [1112.9460,1.3748762]
elam6   = [2393.8907,2.6093743]
bvec0   = [-0.44884, 0.87273, 0.19189]
bvec1   = [-0.47113, 0.84903, 0.23907]
bvec2   = [-0.44744, 0.85709, 0.25507]
bvec3   = [-0.41948, 0.87274, 0.24954]
bvec4   = [-0.39878, 0.88634, 0.23530]
bvec5   = [-0.38009, 0.89680, 0.22643]
bvec6   = [-0.40973, 0.87782, 0.24807]
bmag0   = [22.99710]
bmag1   = [23.92546]
bmag2   = [24.22296]
bmag3   = [24.70969]
bmag4   = [24.60894]
bmag5   = [24.52808]
bmag6   = [24.11260]
tr_str_20 = CREATE_STRUCT(tags[0L:6L],tr0,tr1,tr2,tr3,tr4,tr5,tr6)
kv_str_20 = CREATE_STRUCT(tags[0L:6L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6)
bv_str_20 = CREATE_STRUCT(tags[0L:6L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6)
bm_str_20 = CREATE_STRUCT(tags[0L:6L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6)
eg_str_20 = CREATE_STRUCT(tags[0L:6L],elam0,elam1,elam2,elam3,elam4,elam5,elam6)
tr_str_2  = CREATE_STRUCT(['T0'],tr_str_20)
kv_str_2  = CREATE_STRUCT(['T0'],kv_str_20)
bv_str_2  = CREATE_STRUCT(['T0'],bv_str_20)
bm_str_2  = CREATE_STRUCT(['T0'],bm_str_20)
eg_str_2  = CREATE_STRUCT(['T0'],eg_str_20)
;
; => For  30 Hz < f < 130 Hz  at  1998-08-26/06:41:37.623 UT
;
prefd   = '1998-08-26/'
tr0     = time_double([prefd[0]+'06:41:37.9249',prefd[0]+'06:41:37.9622'])
tr1     = time_double([prefd[0]+'06:41:37.9627',prefd[0]+'06:41:38.0449'])
tr2     = time_double([prefd[0]+'06:41:38.0454',prefd[0]+'06:41:38.2118'])
tr3     = time_double([prefd[0]+'06:41:38.2587',prefd[0]+'06:41:38.3995'])
kvec0   = [-0.54803, 0.39120, 0.73934]
kvec1   = [ 0.69208,-0.27042,-0.66926]
kvec2   = [-0.71918, 0.38116, 0.58095]
kvec3   = [ 0.70806,-0.35198,-0.61218]
elam0   = [20.436502,1.0498023]
elam1   = [36.379200,1.1394255]
elam2   = [51.245744,1.0409382]
elam3   = [60.206391,1.0554272]
bvec0   = [-0.58682, 0.36427, 0.72315]
bvec1   = [-0.58188, 0.36486, 0.72682]
bvec2   = [-0.57921, 0.35917, 0.73177]
bvec3   = [-0.59508, 0.33813, 0.72906]
bmag0   = [20.64521]
bmag1   = [20.69357]
bmag2   = [20.69774]
bmag3   = [20.88043]
tr_str_30 = CREATE_STRUCT(tags[0L:3L],tr0,tr1,tr2,tr3)
kv_str_30 = CREATE_STRUCT(tags[0L:3L],kvec0,kvec1,kvec2,kvec3)
bv_str_30 = CREATE_STRUCT(tags[0L:3L],bvec0,bvec1,bvec2,bvec3)
bm_str_30 = CREATE_STRUCT(tags[0L:3L],bmag0,bmag1,bmag2,bmag3)
eg_str_30 = CREATE_STRUCT(tags[0L:3L],elam0,elam1,elam2,elam3)
tr_str_3  = CREATE_STRUCT(['T0'],tr_str_30)
kv_str_3  = CREATE_STRUCT(['T0'],kv_str_30)
bv_str_3  = CREATE_STRUCT(['T0'],bv_str_30)
bm_str_3  = CREATE_STRUCT(['T0'],bm_str_30)
eg_str_3  = CREATE_STRUCT(['T0'],eg_str_30)
;
; => For  30 Hz < f < 130 Hz  at  1998-08-26/06:41:44.013 UT
;
prefd   = '1998-08-26/'
tr0     = time_double([prefd[0]+'06:41:44.0130',prefd[0]+'06:41:44.1138'])
tr1     = time_double([prefd[0]+'06:41:44.1394',prefd[0]+'06:41:44.2077'])
tr2     = time_double([prefd[0]+'06:41:44.2082',prefd[0]+'06:41:44.3197'])
tr3     = time_double([prefd[0]+'06:41:44.3399',prefd[0]+'06:41:44.3895'])
tr4     = time_double([prefd[0]+'06:41:44.4573',prefd[0]+'06:41:44.5234'])
tr5     = time_double([prefd[0]+'06:41:44.5239',prefd[0]+'06:41:44.5682'])
tr6     = time_double([prefd[0]+'06:41:44.5895',prefd[0]+'06:41:44.6546'])
tr7     = time_double([prefd[0]+'06:41:44.6546',prefd[0]+'06:41:44.7186'])
tr8     = time_double([prefd[0]+'06:41:44.8898',prefd[0]+'06:41:44.9714'])
tr9     = time_double([prefd[0]+'06:41:45.0045',prefd[0]+'06:41:45.0839'])
kvec0   = [ 0.64594,-0.28969,-0.70629]
kvec1   = [-0.72505, 0.28523, 0.62686]
kvec2   = [-0.67761, 0.24410, 0.69373]
kvec3   = [ 0.78077,-0.24585,-0.57442]
kvec4   = [-0.70521, 0.32770, 0.62872]
kvec5   = [-0.69401, 0.24030, 0.67868]
kvec6   = [ 0.65592,-0.28391,-0.69940]
kvec7   = [ 0.67964,-0.35864,-0.63989]
kvec8   = [-0.63806, 0.41326, 0.64969]
kvec9   = [ 0.65344,-0.37936,-0.65506]
elam0   = [77.257208,1.0786112]
elam1   = [141.34440,1.0405578]
elam2   = [82.674630,1.0186937]
elam3   = [15.947115,1.1605405]
elam4   = [68.704042,1.0654233]
elam5   = [57.099761,1.1194410]
elam6   = [68.970768,1.0651076]
elam7   = [107.01331,1.0715389]
elam8   = [33.224218,1.0332873]
elam9   = [54.825617,1.0682807]
bvec0   = [-0.67032, 0.42498, 0.60832]
bvec1   = [-0.68673, 0.40902, 0.60087]
bvec2   = [-0.70327, 0.39143, 0.59344]
bvec3   = [-0.71039, 0.38494, 0.58921]
bvec4   = [-0.71209, 0.39106, 0.58310]
bvec5   = [-0.71205, 0.39192, 0.58256]
bvec6   = [-0.71080, 0.39057, 0.58499]
bvec7   = [-0.70754, 0.38988, 0.58938]
bvec8   = [-0.69172, 0.39232, 0.60630]
bvec9   = [-0.68935, 0.38578, 0.61316]
bmag0   = [21.92541]
bmag1   = [22.33346]
bmag2   = [22.53878]
bmag3   = [22.61108]
bmag4   = [22.69026]
bmag5   = [22.63639]
bmag6   = [22.60861]
bmag7   = [22.66954]
bmag8   = [22.53012]
bmag9   = [22.28330]
tr_str_40 = CREATE_STRUCT(tags[0L:9L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9)
kv_str_40 = CREATE_STRUCT(tags[0L:9L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,kvec9)
bv_str_40 = CREATE_STRUCT(tags[0L:9L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,bvec9)
bm_str_40 = CREATE_STRUCT(tags[0L:9L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,bmag9)
eg_str_40 = CREATE_STRUCT(tags[0L:9L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,elam9)
tr_str_4  = CREATE_STRUCT(['T0'],tr_str_40)
kv_str_4  = CREATE_STRUCT(['T0'],kv_str_40)
bv_str_4  = CREATE_STRUCT(['T0'],bv_str_40)
bm_str_4  = CREATE_STRUCT(['T0'],bm_str_40)
eg_str_4  = CREATE_STRUCT(['T0'],eg_str_40)
;
; => For  35 Hz < f < 150 Hz  at  1998-08-26/06:41:53.249 UT
;
prefd   = '1998-08-26/'
tr0     = time_double([prefd[0]+'06:41:53.2490',prefd[0]+'06:41:53.3498'])
tr1     = time_double([prefd[0]+'06:41:53.3775',prefd[0]+'06:41:53.4602'])
tr2     = time_double([prefd[0]+'06:41:53.4986',prefd[0]+'06:41:53.5695'])
tr3     = time_double([prefd[0]+'06:41:53.5978',prefd[0]+'06:41:53.6799'])
tr4     = time_double([prefd[0]+'06:41:53.7205',prefd[0]+'06:41:53.7882'])
tr5     = time_double([prefd[0]+'06:41:53.8154',prefd[0]+'06:41:53.9050'])
tr6     = time_double([prefd[0]+'06:41:53.9050',prefd[0]+'06:41:53.9397'])
tr7     = time_double([prefd[0]+'06:41:53.9402',prefd[0]+'06:41:53.9802'])
tr8     = time_double([prefd[0]+'06:41:54.1055',prefd[0]+'06:41:54.1610'])
tr9     = time_double([prefd[0]+'06:41:54.1839',prefd[0]+'06:41:54.2159'])
tr10    = time_double([prefd[0]+'06:41:54.2282',prefd[0]+'06:41:54.2618'])
kvec0   = [-0.71857, 0.33705, 0.60832]
kvec1   = [-0.72340, 0.42194, 0.54649]
kvec2   = [-0.65096, 0.44022, 0.61843]
kvec3   = [ 0.79728,-0.36430,-0.48127]
kvec4   = [-0.79802, 0.29995, 0.52267]
kvec5   = [ 0.75311,-0.31901,-0.57537]
kvec6   = [-0.64898, 0.41304, 0.63892]
kvec7   = [-0.68468, 0.42833, 0.58970]
kvec8   = [ 0.77272,-0.31673,-0.55008]
kvec9   = [-0.63062, 0.60421, 0.48707]
kvec10  = [-0.78678, 0.30459, 0.53684]
elam0   = [23.020496,1.0845570]
elam1   = [50.388286,1.0429588]
elam2   = [72.809370,1.0743070]
elam3   = [101.32968,1.0516733]
elam4   = [80.458615,1.0762210]
elam5   = [72.917958,1.0670922]
elam6   = [141.82521,1.0994739]
elam7   = [87.225966,1.1017825]
elam8   = [56.650936,1.0821324]
elam9   = [191.07466,1.0133163]
elam10  = [50.177812,1.0688639]
bvec0   = [-0.71270, 0.33756, 0.61490]
bvec1   = [-0.71329, 0.33851, 0.61370]
bvec2   = [-0.71272, 0.33591, 0.61579]
bvec3   = [-0.71097, 0.33992, 0.61560]
bvec4   = [-0.71155, 0.34745, 0.61071]
bvec5   = [-0.71200, 0.35256, 0.60726]
bvec6   = [-0.71065, 0.35034, 0.61011]
bvec7   = [-0.70905, 0.34747, 0.61360]
bvec8   = [-0.70680, 0.33889, 0.62096]
bvec9   = [-0.70979, 0.33921, 0.61736]
bvec10  = [-0.71310, 0.33966, 0.61329]
bmag0   = [22.67592]
bmag1   = [22.68315]
bmag2   = [22.68923]
bmag3   = [22.64278]
bmag4   = [22.60146]
bmag5   = [22.62789]
bmag6   = [22.66160]
bmag7   = [22.69207]
bmag8   = [22.65236]
bmag9   = [22.57604]
bmag10  = [22.54052]
tr_str_50 = CREATE_STRUCT(tags[0L:10L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,tr10)
kv_str_50 = CREATE_STRUCT(tags[0L:10L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,kvec9,kvec10)
bv_str_50 = CREATE_STRUCT(tags[0L:10L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,bvec9,bvec10)
bm_str_50 = CREATE_STRUCT(tags[0L:10L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,bmag9,bmag10)
eg_str_50 = CREATE_STRUCT(tags[0L:10L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,elam9,elam10)
tr_str_5  = CREATE_STRUCT(['T0'],tr_str_50)
kv_str_5  = CREATE_STRUCT(['T0'],kv_str_50)
bv_str_5  = CREATE_STRUCT(['T0'],bv_str_50)
bm_str_5  = CREATE_STRUCT(['T0'],bm_str_50)
eg_str_5  = CREATE_STRUCT(['T0'],eg_str_50)
;
; => For  30 Hz < f < 150 Hz  at  1998-08-26/06:41:56.315 UT
;
prefd   = '1998-08-26/'
tr0     = time_double([prefd[0]+'06:41:56.4083',prefd[0]+'06:41:56.4499'])
tr1     = time_double([prefd[0]+'06:41:56.4505',prefd[0]+'06:41:56.4835'])
tr2     = time_double([prefd[0]+'06:41:56.4841',prefd[0]+'06:41:56.5182'])
tr3     = time_double([prefd[0]+'06:41:56.6574',prefd[0]+'06:41:56.7401'])
tr4     = time_double([prefd[0]+'06:41:56.7518',prefd[0]+'06:41:56.8329'])
tr5     = time_double([prefd[0]+'06:41:56.8334',prefd[0]+'06:41:56.8846'])
tr6     = time_double([prefd[0]+'06:41:56.8851',prefd[0]+'06:41:56.9299'])
tr7     = time_double([prefd[0]+'06:41:56.9582',prefd[0]+'06:41:56.9929'])
tr8     = time_double([prefd[0]+'06:41:57.1294',prefd[0]+'06:41:57.2137'])
tr9     = time_double([prefd[0]+'06:41:57.2622',prefd[0]+'06:41:57.3998'])
kvec0   = [-0.70166, 0.36776, 0.61027]
kvec1   = [-0.69818, 0.32148, 0.63968]
kvec2   = [-0.72924, 0.24473, 0.63899]
kvec3   = [ 0.76439,-0.25870,-0.59058]
kvec4   = [-0.73884, 0.27150, 0.61677]
kvec5   = [ 0.69332,-0.33404,-0.63853]
kvec6   = [-0.67065, 0.32021, 0.66910]
kvec7   = [-0.76972, 0.17812, 0.61303]
kvec8   = [-0.70929, 0.29576, 0.63986]
kvec9   = [-0.73789, 0.37022, 0.56431]
elam0   = [81.726651,1.0213823]
elam1   = [69.891152,1.0270812]
elam2   = [158.59619,1.0957155]
elam3   = [64.842003,1.0403833]
elam4   = [34.172169,1.0331742]
elam5   = [30.555324,1.0833266]
elam6   = [50.009890,1.0545905]
elam7   = [17.834343,1.0485336]
elam8   = [24.794096,1.0663217]
elam9   = [25.319988,1.1668849]
bvec0   = [-0.70662, 0.30808, 0.63701]
bvec1   = [-0.70540, 0.30560, 0.63954]
bvec2   = [-0.70287, 0.29850, 0.64565]
bvec3   = [-0.66893, 0.34714, 0.65678]
bvec4   = [-0.64365, 0.41604, 0.64219]
bvec5   = [-0.63018, 0.44739, 0.63457]
bvec6   = [-0.62131, 0.46437, 0.63112]
bvec7   = [-0.61584, 0.47424, 0.62916]
bvec8   = [-0.62204, 0.47015, 0.62611]
bvec9   = [-0.62723, 0.46341, 0.62596]
bmag0   = [22.68244]
bmag1   = [22.66097]
bmag2   = [22.71204]
bmag3   = [22.59012]
bmag4   = [22.21371]
bmag5   = [22.11794]
bmag6   = [22.17453]
bmag7   = [22.40475]
bmag8   = [22.36374]
bmag9   = [22.02134]
tr_str_60 = CREATE_STRUCT(tags[0L:9L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9)
kv_str_60 = CREATE_STRUCT(tags[0L:9L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,kvec9)
bv_str_60 = CREATE_STRUCT(tags[0L:9L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,bvec9)
bm_str_60 = CREATE_STRUCT(tags[0L:9L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,bmag9)
eg_str_60 = CREATE_STRUCT(tags[0L:9L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,elam9)
tr_str_6  = CREATE_STRUCT(['T0'],tr_str_60)
kv_str_6  = CREATE_STRUCT(['T0'],kv_str_60)
bv_str_6  = CREATE_STRUCT(['T0'],bv_str_60)
bm_str_6  = CREATE_STRUCT(['T0'],bm_str_60)
eg_str_6  = CREATE_STRUCT(['T0'],eg_str_60)
;
; => For  30 Hz < f < 150 Hz  at  1998-08-26/06:41:57.909 UT
;
prefd   = '1998-08-26/'
tr0     = time_double([prefd[0]+'06:41:57.9453',prefd[0]+'06:41:58.0178'])
tr1     = time_double([prefd[0]+'06:41:58.0407',prefd[0]+'06:41:58.0941'])
tr2     = time_double([prefd[0]+'06:41:58.0946',prefd[0]+'06:41:58.1170'])
tr3     = time_double([prefd[0]+'06:41:58.1666',prefd[0]+'06:41:58.2029'])
tr4     = time_double([prefd[0]+'06:41:58.2274',prefd[0]+'06:41:58.3239'])
tr5     = time_double([prefd[0]+'06:41:58.3618',prefd[0]+'06:41:58.4034'])
tr6     = time_double([prefd[0]+'06:41:58.4279',prefd[0]+'06:41:58.4759'])
tr7     = time_double([prefd[0]+'06:41:58.4759',prefd[0]+'06:41:58.5234'])
tr8     = time_double([prefd[0]+'06:41:58.5655',prefd[0]+'06:41:58.6135'])
tr9     = time_double([prefd[0]+'06:41:58.6141',prefd[0]+'06:41:58.7069'])
tr10    = time_double([prefd[0]+'06:41:58.7202',prefd[0]+'06:41:58.7575'])
tr11    = time_double([prefd[0]+'06:41:58.7981',prefd[0]+'06:41:58.8295'])
tr12    = time_double([prefd[0]+'06:41:58.8418',prefd[0]+'06:41:58.8781'])
tr13    = time_double([prefd[0]+'06:41:58.9223',prefd[0]+'06:41:58.9874'])
kvec0   = [ 0.69946,-0.40614,-0.58805]
kvec1   = [-0.73531, 0.20694, 0.64537]
kvec2   = [-0.77695, 0.20943, 0.59370]
kvec3   = [-0.76155, 0.25899, 0.59411]
kvec4   = [-0.75206, 0.29026, 0.59174]
kvec5   = [-0.63854, 0.24379, 0.72996]
kvec6   = [-0.68236, 0.48338, 0.54838]
kvec7   = [ 0.78393,-0.31785,-0.53331]
kvec8   = [-0.65764, 0.47323, 0.58614]
kvec9   = [-0.78878, 0.32017, 0.52471]
kvec10  = [-0.06527,-0.00717, 0.99784]
kvec11  = [ 0.56993,-0.41903,-0.70683]
kvec12  = [ 0.66194,-0.41899,-0.62151]
kvec13  = [ 0.70517,-0.38336,-0.59647]
elam0   = [56.776628,1.0441361]
elam1   = [13.250825,1.0871106]
elam2   = [133.75925,1.2015846]
elam3   = [26.465349,1.0410327]
elam4   = [44.176349,1.0355746]
elam5   = [16.349479,1.3005424]
elam6   = [110.47582,1.0307918]
elam7   = [19.609831,1.1260466]
elam8   = [99.257377,1.2330834]
elam9   = [51.923459,1.1399952]
elam10  = [18.291772,1.8304973]
elam11  = [23.457846,1.1202276]
elam12  = [21.967218,1.1684371]
elam13  = [54.982449,1.0423804]
bvec0   = [-0.70341, 0.31087, 0.63919]
bvec1   = [-0.70318, 0.30140, 0.64396]
bvec2   = [-0.70573, 0.29406, 0.64458]
bvec3   = [-0.70227, 0.30172, 0.64481]
bvec4   = [-0.69872, 0.31332, 0.64313]
bvec5   = [-0.69229, 0.31891, 0.64733]
bvec6   = [-0.68340, 0.31974, 0.65629]
bvec7   = [-0.67936, 0.32190, 0.65943]
bvec8   = [-0.68066, 0.33197, 0.65306]
bvec9   = [-0.67829, 0.33670, 0.65311]
bvec10  = [-0.67570, 0.33874, 0.65474]
bvec11  = [-0.67492, 0.33952, 0.65514]
bvec12  = [-0.67485, 0.33865, 0.65566]
bvec13  = [-0.67474, 0.32887, 0.66073]
bmag0   = [22.92490]
bmag1   = [22.82689]
bmag2   = [22.74834]
bmag3   = [22.70143]
bmag4   = [22.90626]
bmag5   = [22.95597]
bmag6   = [23.15103]
bmag7   = [23.23489]
bmag8   = [23.10665]
bmag9   = [23.14444]
bmag10  = [23.22434]
bmag11  = [23.22989]
bmag12  = [23.22379]
bmag13  = [23.29114]
tr_str_70 = CREATE_STRUCT(tags[0L:13L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,tr10,tr11,tr12,tr13)
kv_str_70 = CREATE_STRUCT(tags[0L:13L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,kvec9,kvec10,kvec11,kvec12,kvec13)
bv_str_70 = CREATE_STRUCT(tags[0L:13L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,bvec9,bvec10,bvec11,bvec12,bvec13)
bm_str_70 = CREATE_STRUCT(tags[0L:13L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,bmag9,bmag10,bmag11,bmag12,bmag13)
eg_str_70 = CREATE_STRUCT(tags[0L:13L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,elam9,elam10,elam11,elam12,elam13)
tr_str_7  = CREATE_STRUCT(['T0'],tr_str_70)
kv_str_7  = CREATE_STRUCT(['T0'],kv_str_70)
bv_str_7  = CREATE_STRUCT(['T0'],bv_str_70)
bm_str_7  = CREATE_STRUCT(['T0'],bm_str_70)
eg_str_7  = CREATE_STRUCT(['T0'],eg_str_70)
;
; => For  30 Hz < f < 150 Hz  at  1998-08-26/06:41:59.233 UT
;
prefd   = '1998-08-26/'
tr0     = time_double([prefd[0]+'06:41:59.2533',prefd[0]+'06:41:59.3605'])
tr1     = time_double([prefd[0]+'06:41:59.3733',prefd[0]+'06:41:59.4741'])
tr2     = time_double([prefd[0]+'06:41:59.6853',prefd[0]+'06:41:59.7514'])
tr3     = time_double([prefd[0]+'06:41:59.7621',prefd[0]+'06:41:59.8431'])
tr4     = time_double([prefd[0]+'06:41:59.8618',prefd[0]+'06:41:59.9333'])
tr5     = time_double([prefd[0]+'06:41:59.9818',prefd[0]+'06:42:00.0245'])
tr6     = time_double([prefd[0]+'06:42:00.0847',prefd[0]+'06:42:00.1210'])
tr7     = time_double([prefd[0]+'06:42:00.2271',prefd[0]+'06:42:00.2991'])
kvec0   = [-0.70808, 0.37290, 0.59964]
kvec1   = [-0.60926, 0.36730, 0.70278]
kvec2   = [-0.72152, 0.25778, 0.64262]
kvec3   = [-0.80005, 0.22679, 0.55542]
kvec4   = [ 0.78940,-0.25745,-0.55729]
kvec5   = [ 0.64275,-0.38038,-0.66496]
kvec6   = [ 0.76937,-0.35960,-0.52798]
kvec7   = [ 0.70212,-0.38897,-0.59643]
elam0   = [63.862653,1.0490634]
elam1   = [33.267954,1.0975649]
elam2   = [85.550629,1.0431188]
elam3   = [30.605358,1.0460319]
elam4   = [55.939098,1.1386847]
elam5   = [30.838095,1.1280847]
elam6   = [12.901196,1.1734808]
elam7   = [15.364887,1.0556720]
bvec0   = [-0.66915, 0.34159, 0.65996]
bvec1   = [-0.66965, 0.35371, 0.65303]
bvec2   = [-0.68565, 0.34109, 0.64306]
bvec3   = [-0.69202, 0.32187, 0.64607]
bvec4   = [-0.69914, 0.29971, 0.64913]
bvec5   = [-0.70414, 0.29858, 0.64422]
bvec6   = [-0.71262, 0.28753, 0.63993]
bvec7   = [-0.71044, 0.29128, 0.64064]
bmag0   = [23.24000]
bmag1   = [23.14751]
bmag2   = [22.91241]
bmag3   = [22.63211]
bmag4   = [22.39244]
bmag5   = [22.20046]
bmag6   = [22.01527]
bmag7   = [22.28983]
tr_str_80 = CREATE_STRUCT(tags[0L:7L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7)
kv_str_80 = CREATE_STRUCT(tags[0L:7L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7)
bv_str_80 = CREATE_STRUCT(tags[0L:7L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7)
bm_str_80 = CREATE_STRUCT(tags[0L:7L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7)
eg_str_80 = CREATE_STRUCT(tags[0L:7L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7)
tr_str_8  = CREATE_STRUCT(['T0'],tr_str_80)
kv_str_8  = CREATE_STRUCT(['T0'],kv_str_80)
bv_str_8  = CREATE_STRUCT(['T0'],bv_str_80)
bm_str_8  = CREATE_STRUCT(['T0'],bm_str_80)
eg_str_8  = CREATE_STRUCT(['T0'],eg_str_80)
;
; => For  40 Hz < f < 200 Hz  at  1998-08-26/06:42:05.763 UT
;
prefd   = '1998-08-26/'
tr0     = time_double([prefd[0]+'06:42:05.9166',prefd[0]+'06:42:05.9737'])
tr1     = time_double([prefd[0]+'06:42:05.9742',prefd[0]+'06:42:06.0590'])
tr2     = time_double([prefd[0]+'06:42:06.0595',prefd[0]+'06:42:06.1299'])
tr3     = time_double([prefd[0]+'06:42:06.1305',prefd[0]+'06:42:06.2398'])
tr4     = time_double([prefd[0]+'06:42:06.2462',prefd[0]+'06:42:06.3475'])
tr5     = time_double([prefd[0]+'06:42:06.3731',prefd[0]+'06:42:06.4110'])
tr6     = time_double([prefd[0]+'06:42:06.4515',prefd[0]+'06:42:06.5566'])
tr7     = time_double([prefd[0]+'06:42:06.5737',prefd[0]+'06:42:06.6478'])
tr8     = time_double([prefd[0]+'06:42:06.6483',prefd[0]+'06:42:06.7230'])
tr9     = time_double([prefd[0]+'06:42:06.7262',prefd[0]+'06:42:06.7865'])
tr10    = time_double([prefd[0]+'06:42:06.8035',prefd[0]+'06:42:06.8547'])
kvec0   = [-0.70233,-0.04321, 0.71054]
kvec1   = [-0.74212,-0.02971, 0.66961]
kvec2   = [-0.72277, 0.01366, 0.69096]
kvec3   = [-0.74717,-0.08665, 0.65896]
kvec4   = [-0.70841,-0.00184, 0.70580]
kvec5   = [ 0.76314, 0.12361,-0.63430]
kvec6   = [-0.67356,-0.05522, 0.73706]
kvec7   = [ 0.65235, 0.01233,-0.75781]
kvec8   = [-0.64128, 0.11754, 0.75825]
kvec9   = [-0.75391, 0.09869, 0.64952]
kvec10  = [-0.55192,-0.07111, 0.83086]
elam0   = [81.799620,1.0472895]
elam1   = [130.25913,1.0250858]
elam2   = [250.63236,1.0710043]
elam3   = [63.346781,1.0600819]
elam4   = [88.783803,1.0802446]
elam5   = [66.939244,1.0565737]
elam6   = [44.099089,1.0605337]
elam7   = [35.157734,1.3644207]
elam8   = [23.327832,1.2197354]
elam9   = [41.460500,1.3833670]
elam10  = [151.40903,1.1111955]
bvec0   = [-0.72532,-0.03620, 0.68742]
bvec1   = [-0.73649,-0.06588, 0.67315]
bvec2   = [-0.74452,-0.07290, 0.66360]
bvec3   = [-0.74628,-0.08145, 0.66062]
bvec4   = [-0.74196,-0.06997, 0.66673]
bvec5   = [-0.72941,-0.04611, 0.68251]
bvec6   = [-0.71540,-0.02219, 0.69835]
bvec7   = [-0.72215,-0.02966, 0.69109]
bvec8   = [-0.72191,-0.04130, 0.69075]
bvec9   = [-0.71961,-0.04429, 0.69297]
bvec10  = [-0.71426,-0.04714, 0.69829]
bmag0   = [21.71395]
bmag1   = [21.69367]
bmag2   = [21.60414]
bmag3   = [21.70569]
bmag4   = [22.06434]
bmag5   = [22.17538]
bmag6   = [21.69396]
bmag7   = [21.33414]
bmag8   = [21.30489]
bmag9   = [21.34068]
bmag10  = [21.27862]
tr_str_90 = CREATE_STRUCT(tags[0L:10L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,tr10)
kv_str_90 = CREATE_STRUCT(tags[0L:10L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,kvec9,kvec10)
bv_str_90 = CREATE_STRUCT(tags[0L:10L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,bvec9,bvec10)
bm_str_90 = CREATE_STRUCT(tags[0L:10L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,bmag9,bmag10)
eg_str_90 = CREATE_STRUCT(tags[0L:10L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,elam9,elam10)
tr_str_9  = CREATE_STRUCT(['T0'],tr_str_90)
kv_str_9  = CREATE_STRUCT(['T0'],kv_str_90)
bv_str_9  = CREATE_STRUCT(['T0'],bv_str_90)
bm_str_9  = CREATE_STRUCT(['T0'],bm_str_90)
eg_str_9  = CREATE_STRUCT(['T0'],eg_str_90)
;
; => For  50 Hz < f < 200 Hz  at  1998-08-26/06:42:09.131 UT
;
prefd   = '1998-08-26/'
tr0     = time_double([prefd[0]+'06:42:09.3934',prefd[0]+'06:42:09.4563'])
tr1     = time_double([prefd[0]+'06:42:09.5790',prefd[0]+'06:42:09.6302'])
tr2     = time_double([prefd[0]+'06:42:09.6302',prefd[0]+'06:42:09.7054'])
tr3     = time_double([prefd[0]+'06:42:09.7331',prefd[0]+'06:42:09.7678'])
tr4     = time_double([prefd[0]+'06:42:09.9667',prefd[0]+'06:42:10.0595'])
tr5     = time_double([prefd[0]+'06:42:10.0601',prefd[0]+'06:42:10.1817'])
kvec0   = [ 0.66072, 0.05899,-0.74831]
kvec1   = [ 0.67158, 0.06644,-0.73795]
kvec2   = [ 0.70597, 0.25995,-0.65882]
kvec3   = [ 0.51442, 0.14403,-0.84535]
kvec4   = [ 0.83767, 0.22470,-0.49781]
kvec5   = [ 0.80344, 0.29902,-0.51486]
elam0   = [137.56003,1.6282660]
elam1   = [55.292936,1.3841160]
elam2   = [81.218768,1.4295861]
elam3   = [108.77635,1.3089999]
elam4   = [35.623546,1.4451388]
elam5   = [22.175074,1.5491978]
bvec0   = [-0.69691,-0.16769, 0.69724]
bvec1   = [-0.69133,-0.20644, 0.69241]
bvec2   = [-0.67879,-0.19808, 0.70705]
bvec3   = [-0.65808,-0.19168, 0.72813]
bvec4   = [-0.61778,-0.22393, 0.75380]
bvec5   = [-0.61610,-0.23278, 0.75245]
bmag0   = [19.04467]
bmag1   = [18.79389]
bmag2   = [18.71999]
bmag3   = [18.64730]
bmag4   = [18.53768]
bmag5   = [18.47439]
tr_str_100 = CREATE_STRUCT(tags[0L:5L],tr0,tr1,tr2,tr3,tr4,tr5)
kv_str_100 = CREATE_STRUCT(tags[0L:5L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5)
bv_str_100 = CREATE_STRUCT(tags[0L:5L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5)
bm_str_100 = CREATE_STRUCT(tags[0L:5L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5)
eg_str_100 = CREATE_STRUCT(tags[0L:5L],elam0,elam1,elam2,elam3,elam4,elam5)

tr_str_10 = CREATE_STRUCT(['T0'],tr_str_100)
kv_str_10 = CREATE_STRUCT(['T0'],kv_str_100)
bv_str_10 = CREATE_STRUCT(['T0'],bv_str_100)
bm_str_10 = CREATE_STRUCT(['T0'],bm_str_100)
eg_str_10 = CREATE_STRUCT(['T0'],eg_str_100)
  ;-----------------------------------------------------------------------------------------
tags      = ['t0','t1','t2','t3','t4','t5','t6','t7','t8','t9','t10']
tr_str    = CREATE_STRUCT(tags,tr_str_0,tr_str_1,tr_str_2,tr_str_3,tr_str_4,tr_str_5,$
                          tr_str_6,tr_str_7,tr_str_8,tr_str_9,tr_str_10)
kv_str    = CREATE_STRUCT(tags,kv_str_0,kv_str_1,kv_str_2,kv_str_3,kv_str_4,kv_str_5,$
                          kv_str_6,kv_str_7,kv_str_8,kv_str_9,kv_str_10)
bv_str    = CREATE_STRUCT(tags,bv_str_0,bv_str_1,bv_str_2,bv_str_3,bv_str_4,bv_str_5,$
                          bv_str_6,bv_str_7,bv_str_8,bv_str_9,bv_str_10)
bm_str    = CREATE_STRUCT(tags,bm_str_0,bm_str_1,bm_str_2,bm_str_3,bm_str_4,bm_str_5,$
                          bm_str_6,bm_str_7,bm_str_8,bm_str_9,bm_str_10)
eg_str    = CREATE_STRUCT(tags,eg_str_0,eg_str_1,eg_str_2,eg_str_3,eg_str_4,eg_str_5,$
                          eg_str_6,eg_str_7,eg_str_8,eg_str_9,eg_str_10)
lfc1      = [4d0,7d0,1d1,4d1,6d1,6d1,6d1,15d1]   ; => For 1998-08-26/06:40:26.120 UT
hfc1      = [2d1,3d1,3d1,4d2,5d2,2d2,15d1,20d1]  ; => For 1998-08-26/06:40:26.120 UT
lfc2  = [3d0]                                ; => For 1998-08-26/06:40:54.941 UT
hfc2  = [3d1]                                ; => For 1998-08-26/06:40:54.941 UT
lfc3  = [3d0]                                ; => For 1998-08-26/06:41:10.001 UT
hfc3  = [3d1]                                ; => For 1998-08-26/06:41:10.001 UT
lfc4  = [3d1]                                ; => For 1998-08-26/06:41:37.623 UT
hfc4  = [13d1]                               ; => For 1998-08-26/06:41:37.623 UT
lfc5  = [3d1]                                ; => For 1998-08-26/06:41:44.013 UT
hfc5  = [13d1]                               ; => For 1998-08-26/06:41:44.013 UT
lfc6  = [3.5d1]                              ; => For 1998-08-26/06:41:53.249 UT
hfc6  = [15d1]                               ; => For 1998-08-26/06:41:53.249 UT
lfc7  = [3d1]                                ; => For 1998-08-26/06:41:56.315 UT
hfc7  = [15d1]                               ; => For 1998-08-26/06:41:56.315 UT
lfc8  = [3d1]                                ; => For 1998-08-26/06:41:57.909 UT
hfc8  = [15d1]                               ; => For 1998-08-26/06:41:57.909 UT
lfc9  = [3d1]                                ; => For 1998-08-26/06:41:59.233 UT
hfc9  = [15d1]                               ; => For 1998-08-26/06:41:59.233 UT
lfc10 = [4d1]                                ; => For 1998-08-26/06:42:05.763 UT
hfc10 = [20d1]                               ; => For 1998-08-26/06:42:05.763 UT
lfc11 = [5d1]                                ; => For 1998-08-26/06:42:09.131 UT
hfc11 = [20d1]                               ; => For 1998-08-26/06:42:09.131 UT
tags  = ['t1','t2','t3','t4','t5','t6','t7','t8','t9','t10','t11']
lf_str = CREATE_STRUCT(tags,lfc1,lfc2,lfc3,lfc4,lfc5,lfc6,lfc7,lfc8,lfc9,lfc10,lfc11)
hf_str = CREATE_STRUCT(tags,hfc1,hfc2,hfc3,hfc4,hfc5,hfc6,hfc7,hfc8,hfc9,hfc10,hfc11)
no_str = CREATE_STRUCT(tags,14.147,22.911,21.810,20.740,19.820,18.489,18.048,17.818,$
                            17.628,16.687,16.734)
nvec       = [-0.655,0.040,-0.754]   ; => Using RH08 from JCK's site
scet_0826  = ['1998/08/26 06:40:26.120','1998/08/26 06:40:54.941',$
              '1998/08/26 06:41:10.001','1998/08/26 06:41:37.623',$
              '1998/08/26 06:41:44.013','1998/08/26 06:41:53.249',$
              '1998/08/26 06:41:56.315','1998/08/26 06:41:57.909',$
              '1998/08/26 06:41:59.233','1998/08/26 06:42:05.763',$
              '1998/08/26 06:42:09.131'                           ]+' UT'
scets0     = string_replace_char(STRMID(scet_0826[*],0L,23L),'/','-')
scets1     = string_replace_char(scets0,' ','/')
tr0        = file_name_times(scets1,PREC=3)   
prefx      = tr0.F_TIME
  END
;-----------------------------------------------------------------------------------------
  '092498' : BEGIN
    prefd     = '1998-09-24/'
;
; => For  3 Hz < f < 20 Hz  at  1998-09-24/23:20:38.842 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:20:38.9636',prefd[0]+'23:20:39.1204'])
kvec0   = [ 0.98245,-0.06481,-0.17490]
elam0   = [22.211779,1.4924634]
bvec0   = [-0.44466, 0.89448, 0.03813]
bmag0   = [32.45339]
tr_str_00 = CREATE_STRUCT(tags[0L:0L],tr0)
kv_str_00 = CREATE_STRUCT(tags[0L:0L],kvec0)
bv_str_00 = CREATE_STRUCT(tags[0L:0L],bvec0)
bm_str_00 = CREATE_STRUCT(tags[0L:0L],bmag0)
eg_str_00 = CREATE_STRUCT(tags[0L:0L],elam0)
;
; => For  5 Hz < f < 20 Hz  at  1998-09-24/23:20:38.842 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:20:38.8420',prefd[0]+'23:20:38.9945'])
tr1     = time_double([prefd[0]+'23:20:38.9951',prefd[0]+'23:20:39.1476'])
tr2     = time_double([prefd[0]+'23:20:39.6953',prefd[0]+'23:20:39.7999'])
kvec0   = [-0.96622, 0.25768, 0.00417]
kvec1   = [-0.93003, 0.05771, 0.36291]
kvec2   = [ 0.83241,-0.53206, 0.15495]
elam0   = [46.245752,1.4360068]
elam1   = [26.226143,1.9333287]
elam2   = [15.446947,3.7815021]
bvec0   = [-0.40480, 0.91022, 0.08413]
bvec1   = [-0.45594, 0.88818, 0.04329]
bvec2   = [-0.33727, 0.93930, 0.02883]
bmag0   = [31.93903]
bmag1   = [32.56262]
bmag2   = [29.98178]
tr_str_01 = CREATE_STRUCT(tags[0L:2L],tr0,tr1,tr2)
kv_str_01 = CREATE_STRUCT(tags[0L:2L],kvec0,kvec1,kvec2)
bv_str_01 = CREATE_STRUCT(tags[0L:2L],bvec0,bvec1,bvec2)
bm_str_01 = CREATE_STRUCT(tags[0L:2L],bmag0,bmag1,bmag2)
eg_str_01 = CREATE_STRUCT(tags[0L:2L],elam0,elam1,elam2)
;
; => For  10 Hz < f < 45 Hz  at  1998-09-24/23:20:38.842 UT
;
tr_str_02 = 0
kv_str_02 = 0
bv_str_02 = 0
bm_str_02 = 0
eg_str_02 = 0
;
; => For  50 Hz < f < 200 Hz  at  1998-09-24/23:20:38.842 UT
;
tr_str_03 = 0
kv_str_03 = 0
bv_str_03 = 0
bm_str_03 = 0
eg_str_03 = 0
;
; => For  100 Hz < f < 200 Hz  at  1998-09-24/23:20:38.842 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:20:39.0761',prefd[0]+'23:20:39.0985'])
tr1     = time_double([prefd[0]+'23:20:39.4303',prefd[0]+'23:20:39.4559'])
tr2     = time_double([prefd[0]+'23:20:39.4804',prefd[0]+'23:20:39.5071'])
tr3     = time_double([prefd[0]+'23:20:39.7236',prefd[0]+'23:20:39.7524'])
kvec0   = [-0.93772,-0.09010, 0.33551]
kvec1   = [-0.40512, 0.88622,-0.22471]
kvec2   = [-0.07652, 0.86164,-0.50172]
kvec3   = [-0.38297, 0.90500,-0.18520]
elam0   = [34.847261,6.8065886]
elam1   = [37.324974,3.3453533]
elam2   = [52.233217,2.8496824]
elam3   = [16.348417,2.2699986]
bvec0   = [-0.46003, 0.88709, 0.03686]
bvec1   = [-0.35493, 0.93484, 0.00657]
bvec2   = [-0.31217, 0.94961,-0.02675]
bvec3   = [-0.33825, 0.93971, 0.04764]
bmag0   = [32.66495]
bmag1   = [31.36147]
bmag2   = [30.05675]
bmag3   = [29.83430]
tr_str_04 = CREATE_STRUCT(tags[0L:3L],tr0,tr1,tr2,tr3)
kv_str_04 = CREATE_STRUCT(tags[0L:3L],kvec0,kvec1,kvec2,kvec3)
bv_str_04 = CREATE_STRUCT(tags[0L:3L],bvec0,bvec1,bvec2,bvec3)
bm_str_04 = CREATE_STRUCT(tags[0L:3L],bmag0,bmag1,bmag2,bmag3)
eg_str_04 = CREATE_STRUCT(tags[0L:3L],elam0,elam1,elam2,elam3)
tr_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4'],tr_str_00,tr_str_01,tr_str_02,tr_str_03,tr_str_04)
kv_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4'],kv_str_00,kv_str_01,kv_str_02,kv_str_03,kv_str_04)
bv_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4'],bv_str_00,bv_str_01,bv_str_02,bv_str_03,bv_str_04)
bm_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4'],bm_str_00,bm_str_01,bm_str_02,bm_str_03,bm_str_04)
eg_str_0  = CREATE_STRUCT(['T0','T1','T2','T3','T4'],eg_str_00,eg_str_01,eg_str_02,eg_str_03,eg_str_04)
;
; => For  3 Hz < f < 20 Hz  at  1998-09-24/23:22:26.632 UT
;
tr_str_10 = 0
kv_str_10 = 0
bv_str_10 = 0
bm_str_10 = 0
eg_str_10 = 0
;
; => For  6 Hz < f < 30 Hz  at  1998-09-24/23:22:26.632 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:22:27.2005',prefd[0]+'23:22:27.2875'])
tr1     = time_double([prefd[0]+'23:22:27.6037',prefd[0]+'23:22:27.6437'])
kvec0   = [-0.21261, 0.93610, 0.28021]
kvec1   = [ 0.12887, 0.49341, 0.86020]
elam0   = [22.594221,1.1930579]
elam1   = [16.226427,1.5508503]
bvec0   = [-0.30468, 0.84697, 0.43565]
bvec1   = [-0.36636, 0.85765, 0.36085]
bmag0   = [42.37826]
bmag1   = [42.11877]
tr_str_11 = CREATE_STRUCT(tags[0L:1L],tr0,tr1)
kv_str_11 = CREATE_STRUCT(tags[0L:1L],kvec0,kvec1)
bv_str_11 = CREATE_STRUCT(tags[0L:1L],bvec0,bvec1)
bm_str_11 = CREATE_STRUCT(tags[0L:1L],bmag0,bmag1)
eg_str_11 = CREATE_STRUCT(tags[0L:1L],elam0,elam1)
;
; => For  15 Hz < f < 150 Hz  at  1998-09-24/23:22:26.632 UT
;
tr_str_12 = 0
kv_str_12 = 0
bv_str_12 = 0
bm_str_12 = 0
eg_str_12 = 0
;
; => For  30 Hz < f < 150 Hz  at  1998-09-24/23:22:26.632 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:22:26.7173',prefd[0]+'23:22:26.7536'])
tr1     = time_double([prefd[0]+'23:22:27.1584',prefd[0]+'23:22:27.2160'])
tr2     = time_double([prefd[0]+'23:22:27.2304',prefd[0]+'23:22:27.2528'])
tr3     = time_double([prefd[0]+'23:22:27.2624',prefd[0]+'23:22:27.2955'])
tr4     = time_double([prefd[0]+'23:22:27.2960',prefd[0]+'23:22:27.3296'])
tr5     = time_double([prefd[0]+'23:22:27.3813',prefd[0]+'23:22:27.4117'])
tr6     = time_double([prefd[0]+'23:22:27.4123',prefd[0]+'23:22:27.4464'])
kvec0   = [ 0.71280,-0.69465,-0.09679]
kvec1   = [-0.52456, 0.79264, 0.31075]
kvec2   = [ 0.34924,-0.85848,-0.37556]
kvec3   = [-0.44432, 0.89542,-0.02824]
kvec4   = [-0.32069, 0.88028, 0.34966]
kvec5   = [ 0.76191,-0.63565,-0.12426]
kvec6   = [-0.66600, 0.73099, 0.14869]
elam0   = [10.506212,1.8029687]
elam1   = [31.226731,1.1158382]
elam2   = [12.160326,1.2067213]
elam3   = [16.545702,1.2760096]
elam4   = [24.801793,1.4979471]
elam5   = [109.30998,1.6059219]
elam6   = [98.827240,1.0302008]
bvec0   = [-0.28970, 0.88420, 0.36642]
bvec1   = [-0.30146, 0.85067, 0.43067]
bvec2   = [-0.30327, 0.84642, 0.43773]
bvec3   = [-0.30940, 0.84618, 0.43387]
bvec4   = [-0.31625, 0.84668, 0.42791]
bvec5   = [-0.33350, 0.85107, 0.40551]
bvec6   = [-0.34033, 0.85328, 0.39506]
bmag0   = [42.41395]
bmag1   = [42.23297]
bmag2   = [42.39689]
bmag3   = [42.41665]
bmag4   = [42.41032]
bmag5   = [42.49598]
bmag6   = [42.54431]
tr_str_13 = CREATE_STRUCT(tags[0L:6L],tr0,tr1,tr2,tr3,tr4,tr5,tr6)
kv_str_13 = CREATE_STRUCT(tags[0L:6L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6)
bv_str_13 = CREATE_STRUCT(tags[0L:6L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6)
bm_str_13 = CREATE_STRUCT(tags[0L:6L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6)
eg_str_13 = CREATE_STRUCT(tags[0L:6L],elam0,elam1,elam2,elam3,elam4,elam5,elam6)
tr_str_1  = CREATE_STRUCT(['T0','T1','T2','T3'],tr_str_10,tr_str_11,tr_str_12,tr_str_13)
kv_str_1  = CREATE_STRUCT(['T0','T1','T2','T3'],kv_str_10,kv_str_11,kv_str_12,kv_str_13)
bv_str_1  = CREATE_STRUCT(['T0','T1','T2','T3'],bv_str_10,bv_str_11,bv_str_12,bv_str_13)
bm_str_1  = CREATE_STRUCT(['T0','T1','T2','T3'],bm_str_10,bm_str_11,bm_str_12,bm_str_13)
eg_str_1  = CREATE_STRUCT(['T0','T1','T2','T3'],eg_str_10,eg_str_11,eg_str_12,eg_str_13)
;
; => For  3 Hz < f < 20 Hz  at  1998-09-24/23:22:26.632 UT
;
tr_str_20 = 0
kv_str_20 = 0
bv_str_20 = 0
bm_str_20 = 0
eg_str_20 = 0
;
; => For  6 Hz < f < 30 Hz  at  1998-09-24/23:22:48.150 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:22:48.1500',prefd[0]+'23:22:48.2396'])
tr1     = time_double([prefd[0]+'23:22:48.2401',prefd[0]+'23:22:48.2855'])
tr2     = time_double([prefd[0]+'23:22:48.3351',prefd[0]+'23:22:48.3831'])
tr3     = time_double([prefd[0]+'23:22:48.5244',prefd[0]+'23:22:48.6380'])
tr4     = time_double([prefd[0]+'23:22:48.7788',prefd[0]+'23:22:48.8412'])
tr5     = time_double([prefd[0]+'23:22:49.0124',prefd[0]+'23:22:49.0748'])
kvec0   = [-0.01574,-0.76014,-0.64956]
kvec1   = [-0.07880,-0.70006,-0.70972]
kvec2   = [-0.19814,-0.74365,-0.63853]
kvec3   = [-0.20663, 0.82608, 0.52431]
kvec4   = [ 0.19920, 0.95497, 0.21990]
kvec5   = [ 0.58830,-0.17706,-0.78902]
elam0   = [111.82964,2.1455052]
elam1   = [42.189306,1.8269140]
elam2   = [778.13114,1.3627853]
elam3   = [12.742375,1.2129027]
elam4   = [48.934482,1.9241530]
elam5   = [24.942817,2.2288402]
bvec0   = [-0.33802, 0.88378, 0.32349]
bvec1   = [-0.33598, 0.88827, 0.31320]
bvec2   = [-0.33019, 0.89351, 0.30432]
bvec3   = [-0.32260, 0.90142, 0.28872]
bvec4   = [-0.30031, 0.91380, 0.27344]
bvec5   = [-0.27801, 0.91480, 0.29299]
bmag0   = [42.32958]
bmag1   = [42.30051]
bmag2   = [42.25578]
bmag3   = [42.54726]
bmag4   = [42.32404]
bmag5   = [42.44916]
tr_str_21 = CREATE_STRUCT(tags[0L:5L],tr0,tr1,tr2,tr3,tr4,tr5)
kv_str_21 = CREATE_STRUCT(tags[0L:5L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5)
bv_str_21 = CREATE_STRUCT(tags[0L:5L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5)
bm_str_21 = CREATE_STRUCT(tags[0L:5L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5)
eg_str_21 = CREATE_STRUCT(tags[0L:5L],elam0,elam1,elam2,elam3,elam4,elam5)
;
; => For  15 Hz < f < 150 Hz  at  1998-09-24/23:22:26.632 UT
;
tr_str_22 = 0
kv_str_22 = 0
bv_str_22 = 0
bm_str_22 = 0
eg_str_22 = 0
;
; => For  30 Hz < f < 150 Hz  at  1998-09-24/23:22:48.150 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:22:48.1836',prefd[0]+'23:22:48.2508'])
tr1     = time_double([prefd[0]+'23:22:48.3473',prefd[0]+'23:22:48.3713'])
tr2     = time_double([prefd[0]+'23:22:48.3996',prefd[0]+'23:22:48.4220'])
tr3     = time_double([prefd[0]+'23:22:48.5068',prefd[0]+'23:22:48.5447'])
tr4     = time_double([prefd[0]+'23:22:48.6225',prefd[0]+'23:22:48.6577'])
tr5     = time_double([prefd[0]+'23:22:48.6583',prefd[0]+'23:22:48.7127'])
tr6     = time_double([prefd[0]+'23:22:48.9489',prefd[0]+'23:22:48.9729'])
tr7     = time_double([prefd[0]+'23:22:49.0817',prefd[0]+'23:22:49.1057'])
kvec0   = [ 0.30632,-0.81107,-0.49834]
kvec1   = [ 0.39593,-0.79206,-0.46462]
kvec2   = [-0.06917, 0.92173, 0.38161]
kvec3   = [ 0.66870,-0.70251,-0.24357]
kvec4   = [ 0.59137,-0.56090,-0.57938]
kvec5   = [ 0.40501,-0.48346,-0.77603]
kvec6   = [-0.04915,-0.94556,-0.32172]
kvec7   = [-0.72440, 0.61616, 0.30918]
elam0   = [27.160724,1.5877689]
elam1   = [36.690574,1.1342159]
elam2   = [19.944872,1.2697517]
elam3   = [31.924088,1.6022743]
elam4   = [12.620580,1.5001507]
elam5   = [21.035347,1.0558565]
elam6   = [67.094544,1.0558747]
elam7   = [21.044902,1.5351499]
bvec0   = [-0.33760, 0.88533, 0.31971]
bvec1   = [-0.33021, 0.89350, 0.30433]
bvec2   = [-0.32621, 0.89574, 0.30205]
bvec3   = [-0.32344, 0.89947, 0.29383]
bvec4   = [-0.32080, 0.90274, 0.28662]
bvec5   = [-0.31811, 0.90388, 0.28603]
bvec6   = [-0.28310, 0.91451, 0.28900]
bvec7   = [-0.27319, 0.91639, 0.29258]
bmag0   = [42.31942]
bmag1   = [42.25590]
bmag2   = [42.23702]
bmag3   = [42.52070]
bmag4   = [42.50772]
bmag5   = [42.44091]
bmag6   = [42.14798]
bmag7   = [42.49588]
tr_str_23 = CREATE_STRUCT(tags[0L:7L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7)
kv_str_23 = CREATE_STRUCT(tags[0L:7L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7)
bv_str_23 = CREATE_STRUCT(tags[0L:7L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7)
bm_str_23 = CREATE_STRUCT(tags[0L:7L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7)
eg_str_23 = CREATE_STRUCT(tags[0L:7L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7)
tr_str_2  = CREATE_STRUCT(['T0','T1','T2','T3'],tr_str_20,tr_str_21,tr_str_22,tr_str_23)
kv_str_2  = CREATE_STRUCT(['T0','T1','T2','T3'],kv_str_20,kv_str_21,kv_str_22,kv_str_23)
bv_str_2  = CREATE_STRUCT(['T0','T1','T2','T3'],bv_str_20,bv_str_21,bv_str_22,bv_str_23)
bm_str_2  = CREATE_STRUCT(['T0','T1','T2','T3'],bm_str_20,bm_str_21,bm_str_22,bm_str_23)
eg_str_2  = CREATE_STRUCT(['T0','T1','T2','T3'],eg_str_20,eg_str_21,eg_str_22,eg_str_23)
;
; => For  3 Hz < f < 30 Hz  at  1998-09-24/23:30:00.465 UT
;
tr_str_30 = 0
kv_str_30 = 0
bv_str_30 = 0
bm_str_30 = 0
eg_str_30 = 0
tr_str_3  = CREATE_STRUCT(['T0'],tr_str_30)
kv_str_3  = CREATE_STRUCT(['T0'],kv_str_30)
bv_str_3  = CREATE_STRUCT(['T0'],bv_str_30)
bm_str_3  = CREATE_STRUCT(['T0'],bm_str_30)
eg_str_3  = CREATE_STRUCT(['T0'],eg_str_30)
;
; => For  3 Hz < f < 40 Hz  at  1998-09-24/23:30:48.542 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:30:48.8737',prefd[0]+'23:30:49.0177'])
tr1     = time_double([prefd[0]+'23:30:49.3260',prefd[0]+'23:30:49.4988'])
tr2     = time_double([prefd[0]+'23:30:49.3692',prefd[0]+'23:30:49.4988'])
kvec0   = [ 0.78336, 0.62028, 0.03993]
kvec1   = [ 0.69672,-0.60070,-0.39209]
kvec2   = [ 0.71066,-0.58173,-0.39567]
elam0   = [38.810429,3.2816307]
elam1   = [61.373437,1.6935611]
elam2   = [46.618949,2.6676104]
bvec0   = [-0.44455, 0.73332, 0.51438]
bvec1   = [-0.46540, 0.75193, 0.46689]
bvec2   = [-0.46517, 0.75298, 0.46544]
bmag0   = [40.47744]
bmag1   = [41.20196]
bmag2   = [41.21673]
tr_str_40 = CREATE_STRUCT(tags[0L:2L],tr0,tr1,tr2)
kv_str_40 = CREATE_STRUCT(tags[0L:2L],kvec0,kvec1,kvec2)
bv_str_40 = CREATE_STRUCT(tags[0L:2L],bvec0,bvec1,bvec2)
bm_str_40 = CREATE_STRUCT(tags[0L:2L],bmag0,bmag1,bmag2)
eg_str_40 = CREATE_STRUCT(tags[0L:2L],elam0,elam1,elam2)
;
; => For  10 Hz < f < 40 Hz  at  1998-09-24/23:30:48.542 UT
;
tr_str_41 = 0
kv_str_41 = 0
bv_str_41 = 0
bm_str_41 = 0
eg_str_41 = 0
;
; => For  40 Hz < f < 100 Hz  at  1998-09-24/23:30:48.542 UT
;
tr_str_42 = 0
kv_str_42 = 0
bv_str_42 = 0
bm_str_42 = 0
eg_str_42 = 0
;
; => For  200 Hz < f < 400 Hz  at  1998-09-24/23:30:48.542 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:30:48.5500',prefd[0]+'23:30:48.5697'])
tr1     = time_double([prefd[0]+'23:30:48.5799',prefd[0]+'23:30:48.5991'])
tr2     = time_double([prefd[0]+'23:30:48.6188',prefd[0]+'23:30:48.6508'])
tr3     = time_double([prefd[0]+'23:30:48.6524',prefd[0]+'23:30:48.6668'])
tr4     = time_double([prefd[0]+'23:30:48.6679',prefd[0]+'23:30:48.6999'])
tr5     = time_double([prefd[0]+'23:30:48.7004',prefd[0]+'23:30:48.7244'])
tr6     = time_double([prefd[0]+'23:30:48.8055',prefd[0]+'23:30:48.8497'])
tr7     = time_double([prefd[0]+'23:30:48.8503',prefd[0]+'23:30:48.9265'])
tr8     = time_double([prefd[0]+'23:30:48.9265',prefd[0]+'23:30:48.9996'])
tr9     = time_double([prefd[0]+'23:30:49.0001',prefd[0]+'23:30:49.0396'])
tr10    = time_double([prefd[0]+'23:30:49.0449',prefd[0]+'23:30:49.0609'])
tr11    = time_double([prefd[0]+'23:30:49.0615',prefd[0]+'23:30:49.0967'])
tr12    = time_double([prefd[0]+'23:30:49.1100',prefd[0]+'23:30:49.1196'])
tr13    = time_double([prefd[0]+'23:30:49.1201',prefd[0]+'23:30:49.1457'])
tr14    = time_double([prefd[0]+'23:30:49.1463',prefd[0]+'23:30:49.2023'])
tr15    = time_double([prefd[0]+'23:30:49.2028',prefd[0]+'23:30:49.2268'])
tr16    = time_double([prefd[0]+'23:30:49.2353',prefd[0]+'23:30:49.2673'])
tr17    = time_double([prefd[0]+'23:30:49.2679',prefd[0]+'23:30:49.3143'])
tr18    = time_double([prefd[0]+'23:30:49.3148',prefd[0]+'23:30:49.3255'])
tr19    = time_double([prefd[0]+'23:30:49.3313',prefd[0]+'23:30:49.3799'])
tr20    = time_double([prefd[0]+'23:30:49.3804',prefd[0]+'23:30:49.4327'])
tr21    = time_double([prefd[0]+'23:30:49.4503',prefd[0]+'23:30:49.4972'])
tr22    = time_double([prefd[0]+'23:30:49.4977',prefd[0]+'23:30:49.5228'])
tr23    = time_double([prefd[0]+'23:30:49.5271',prefd[0]+'23:30:49.5585'])
tr24    = time_double([prefd[0]+'23:30:49.5591',prefd[0]+'23:30:49.5815'])
kvec0   = [ 0.73044,-0.33271,-0.59646]
kvec1   = [ 0.67852,-0.37579,-0.63119]
kvec2   = [ 0.72408,-0.29306,-0.62436]
kvec3   = [ 0.67540,-0.17251,-0.71699]
kvec4   = [ 0.72033,-0.15381,-0.67637]
kvec5   = [ 0.75824,-0.25189,-0.60135]
kvec6   = [ 0.69150,-0.19666,-0.69509]
kvec7   = [ 0.73929,-0.14663,-0.65723]
kvec8   = [ 0.70436,-0.13724,-0.69645]
kvec9   = [ 0.69449,-0.25131,-0.67419]
kvec10  = [-0.00132,-0.00100,-1.00000]
kvec11  = [ 0.00049,-0.00278,-1.00000]
kvec12  = [ 0.76387,-0.10524,-0.63674]
kvec13  = [ 0.74922,-0.13205,-0.64902]
kvec14  = [ 0.70280,-0.01649,-0.71120]
kvec15  = [ 0.72118,-0.18955,-0.66631]
kvec16  = [ 0.70746,-0.29336,-0.64299]
kvec17  = [ 0.70623,-0.21445,-0.67473]
kvec18  = [ 0.72313, 0.05159,-0.68878]
kvec19  = [ 0.71911,-0.21629,-0.66038]
kvec20  = [ 0.73942,-0.17522,-0.65004]
kvec21  = [ 0.69126,-0.37399,-0.61829]
kvec22  = [ 0.66885,-0.14658,-0.72880]
kvec23  = [ 0.71783,-0.13677,-0.68265]
kvec24  = [ 0.73450,-0.05978,-0.67597]
elam0   = [32.757588,5.1725034]
elam1   = [62.194347,4.7739488]
elam2   = [48.937657,5.1513222]
elam3   = [23.549643,3.7793534]
elam4   = [77.206839,4.1681879]
elam5   = [101.18191,6.5764968]
elam6   = [29.282799,3.9740805]
elam7   = [49.101080,5.0518233]
elam8   = [28.073362,4.1683115]
elam9   = [97.902561,4.9495011]
elam10  = [476.73567,3.2062222]
elam11  = [866.20227,4.7873677]
elam12  = [78.061251,8.0932010]
elam13  = [98.450390,6.2249150]
elam14  = [25.594481,3.7443254]
elam15  = [53.183527,4.6590059]
elam16  = [22.054444,5.0732422]
elam17  = [86.002268,4.4865663]
elam18  = [20.103518,5.6225363]
elam19  = [73.235820,4.7609461]
elam20  = [35.416067,5.1683691]
elam21  = [27.318875,5.5871040]
elam22  = [36.201868,3.3711832]
elam23  = [63.946748,4.8253759]
elam24  = [412.23440,5.3330883]
bvec0   = [-0.40252, 0.73549, 0.54501]
bvec1   = [-0.40679, 0.73415, 0.54364]
bvec2   = [-0.41308, 0.73212, 0.54163]
bvec3   = [-0.41614, 0.73127, 0.54043]
bvec4   = [-0.41834, 0.73097, 0.53914]
bvec5   = [-0.42087, 0.73061, 0.53765]
bvec6   = [-0.43090, 0.73223, 0.52741]
bvec7   = [-0.43826, 0.73367, 0.51927]
bvec8   = [-0.44652, 0.73327, 0.51276]
bvec9   = [-0.45160, 0.73168, 0.51058]
bvec10  = [-0.45369, 0.73247, 0.50760]
bvec11  = [-0.45526, 0.73333, 0.50493]
bvec12  = [-0.45731, 0.73458, 0.50127]
bvec13  = [-0.45822, 0.73559, 0.49894]
bvec14  = [-0.46034, 0.73794, 0.49348]
bvec15  = [-0.46241, 0.74032, 0.48796]
bvec16  = [-0.46440, 0.74281, 0.48224]
bvec17  = [-0.46628, 0.74547, 0.47628]
bvec18  = [-0.46644, 0.74719, 0.47343]
bvec19  = [-0.46603, 0.74922, 0.47063]
bvec20  = [-0.46549, 0.75183, 0.46697]
bvec21  = [-0.46470, 0.75468, 0.46315]
bvec22  = [-0.46295, 0.75587, 0.46296]
bvec23  = [-0.46096, 0.75686, 0.46333]
bvec24  = [-0.45911, 0.75781, 0.46362]
bmag0   = [40.62561]
bmag1   = [40.62074]
bmag2   = [40.61554]
bmag3   = [40.61911]
bmag4   = [40.63281]
bmag5   = [40.64889]
bmag6   = [40.47960]
bmag7   = [40.43920]
bmag8   = [40.48725]
bmag9   = [40.58921]
bmag10  = [40.67957]
bmag11  = [40.75786]
bmag12  = [40.85480]
bmag13  = [40.87585]
bmag14  = [40.92627]
bmag15  = [40.98466]
bmag16  = [41.05859]
bmag17  = [41.13369]
bmag18  = [41.15280]
bmag19  = [41.15898]
bmag20  = [41.18728]
bmag21  = [41.25762]
bmag22  = [41.26371]
bmag23  = [41.26001]
bmag24  = [41.26249]
tr_str_43  = CREATE_STRUCT(tags[0L:24L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,tr10,tr11,tr12,$
                           tr13,tr14,tr15,tr16,tr17,tr18,tr19,tr20,tr21,tr22,tr23,tr24)
kv_str_43  = CREATE_STRUCT(tags[0L:24L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,$
                           kvec9,kvec10,kvec11,kvec12,kvec13,kvec14,kvec15,kvec16,kvec17,$
                           kvec18,kvec19,kvec20,kvec21,kvec22,kvec23,kvec24)
bv_str_43  = CREATE_STRUCT(tags[0L:24L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,$
                           bvec9,bvec10,bvec11,bvec12,bvec13,bvec14,bvec15,bvec16,bvec17,$
                           bvec18,bvec19,bvec20,bvec21,bvec22,bvec23,bvec24)
bm_str_43  = CREATE_STRUCT(tags[0L:24L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,$
                           bmag9,bmag10,bmag11,bmag12,bmag13,bmag14,bmag15,bmag16,bmag17,$
                           bmag18,bmag19,bmag20,bmag21,bmag22,bmag23,bmag24)
eg_str_43  = CREATE_STRUCT(tags[0L:24L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,$
                           elam9,elam10,elam11,elam12,elam13,elam14,elam15,elam16,elam17,$
                           elam18,elam19,elam20,elam21,elam22,elam23,elam24)
tr_str_4  = CREATE_STRUCT(['T0','T1','T2','T3'],tr_str_40,tr_str_41,tr_str_42,tr_str_43)
kv_str_4  = CREATE_STRUCT(['T0','T1','T2','T3'],kv_str_40,kv_str_41,kv_str_42,kv_str_43)
bv_str_4  = CREATE_STRUCT(['T0','T1','T2','T3'],bv_str_40,bv_str_41,bv_str_42,bv_str_43)
bm_str_4  = CREATE_STRUCT(['T0','T1','T2','T3'],bm_str_40,bm_str_41,bm_str_42,bm_str_43)
eg_str_4  = CREATE_STRUCT(['T0','T1','T2','T3'],eg_str_40,eg_str_41,eg_str_42,eg_str_43)
;
; => For  3 Hz < f < 30 Hz  at  1998-09-24/23:43:18.951 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:43:19.0694',prefd[0]+'23:43:19.2214'])
tr1     = time_double([prefd[0]+'23:43:19.6502',prefd[0]+'23:43:19.7110'])
tr2     = time_double([prefd[0]+'23:43:19.9270',prefd[0]+'23:43:19.9995'])
kvec0   = [-0.35115,-0.92369, 0.15326]
kvec1   = [-0.59098, 0.26256, 0.76276]
kvec2   = [ 0.31415,-0.94866,-0.03686]
elam0   = [40.543304,1.4272298]
elam1   = [20.759092,19.873908]
elam2   = [14.219221,1.8227521]
bvec0   = [-0.21307, 0.97271, 0.09178]
bvec1   = [-0.23299, 0.97078, 0.05740]
bvec2   = [-0.24149, 0.96958, 0.03952]
bmag0   = [35.06914]
bmag1   = [35.94601]
bmag2   = [35.86503]
tr_str_50 = CREATE_STRUCT(tags[0L:2L],tr0,tr1,tr2)
kv_str_50 = CREATE_STRUCT(tags[0L:2L],kvec0,kvec1,kvec2)
bv_str_50 = CREATE_STRUCT(tags[0L:2L],bvec0,bvec1,bvec2)
bm_str_50 = CREATE_STRUCT(tags[0L:2L],bmag0,bmag1,bmag2)
eg_str_50 = CREATE_STRUCT(tags[0L:2L],elam0,elam1,elam2)
tr_str_5  = CREATE_STRUCT(['T0'],tr_str_50)
kv_str_5  = CREATE_STRUCT(['T0'],kv_str_50)
bv_str_5  = CREATE_STRUCT(['T0'],bv_str_50)
bm_str_5  = CREATE_STRUCT(['T0'],bm_str_50)
eg_str_5  = CREATE_STRUCT(['T0'],eg_str_50)
;
; => For  3 Hz < f < 30 Hz  at  1998-09-24/23:45:52.184 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:45:52.4485',prefd[0]+'23:45:52.5099'])
tr1     = time_double([prefd[0]+'23:45:52.5504',prefd[0]+'23:45:52.6272'])
tr2     = time_double([prefd[0]+'23:45:53.1765',prefd[0]+'23:45:53.2757'])
kvec0   = [ 0.30986, 0.93395, 0.17814]
kvec1   = [ 0.40732,-0.89024, 0.20388]
kvec2   = [-0.74647, 0.60257, 0.28228]
elam0   = [13.853695,3.2561507]
elam1   = [111.40141,2.4391355]
elam2   = [10.556916,4.0535800]
bvec0   = [-0.40030, 0.84940, 0.34392]
bvec1   = [-0.41103, 0.86811, 0.27573]
bvec2   = [-0.32137, 0.94226, 0.09228]
bmag0   = [36.98357]
bmag1   = [37.39432]
bmag2   = [37.65568]
tr_str_60 = CREATE_STRUCT(tags[0L:2L],tr0,tr1,tr2)
kv_str_60 = CREATE_STRUCT(tags[0L:2L],kvec0,kvec1,kvec2)
bv_str_60 = CREATE_STRUCT(tags[0L:2L],bvec0,bvec1,bvec2)
bm_str_60 = CREATE_STRUCT(tags[0L:2L],bmag0,bmag1,bmag2)
eg_str_60 = CREATE_STRUCT(tags[0L:2L],elam0,elam1,elam2)
;
; => For  10 Hz < f < 100 Hz  at  1998-09-24/23:45:52.184 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:45:52.4560',prefd[0]+'23:45:52.5045'])
tr1     = time_double([prefd[0]+'23:45:52.5403',prefd[0]+'23:45:52.6683'])
tr2     = time_double([prefd[0]+'23:45:53.0869',prefd[0]+'23:45:53.1013'])
kvec0   = [ 0.61631, 0.76502, 0.18685]
kvec1   = [-0.26467, 0.95178,-0.15513]
kvec2   = [ 0.21001, 0.77953, 0.59011]
elam0   = [14.575075,3.2713029]
elam1   = [12.309177,2.5921494]
elam2   = [31.044317,2.6369960]
bvec0   = [-0.40027, 0.84930, 0.34420]
bvec1   = [-0.41357, 0.87300, 0.25217]
bvec2   = [-0.32230, 0.92363, 0.20741]
bmag0   = [36.97547]
bmag1   = [37.52479]
bmag2   = [38.47757]
tr_str_61 = CREATE_STRUCT(tags[0L:2L],tr0,tr1,tr2)
kv_str_61 = CREATE_STRUCT(tags[0L:2L],kvec0,kvec1,kvec2)
bv_str_61 = CREATE_STRUCT(tags[0L:2L],bvec0,bvec1,bvec2)
bm_str_61 = CREATE_STRUCT(tags[0L:2L],bmag0,bmag1,bmag2)
eg_str_61 = CREATE_STRUCT(tags[0L:2L],elam0,elam1,elam2)
;
; => For  30 Hz < f < 100 Hz  at  1998-09-24/23:45:52.184 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:45:52.2805',prefd[0]+'23:45:52.3189'])
tr1     = time_double([prefd[0]+'23:45:52.4144',prefd[0]+'23:45:52.4299'])
tr2     = time_double([prefd[0]+'23:45:52.6053',prefd[0]+'23:45:52.6181'])
tr3     = time_double([prefd[0]+'23:45:52.9051',prefd[0]+'23:45:52.9200'])
tr4     = time_double([prefd[0]+'23:45:52.9888',prefd[0]+'23:45:53.0085'])
tr5     = time_double([prefd[0]+'23:45:53.0091',prefd[0]+'23:45:53.0421'])
tr6     = time_double([prefd[0]+'23:45:53.0592',prefd[0]+'23:45:53.0752'])
kvec0   = [ 0.12098, 0.99264, 0.00599]
kvec1   = [-0.50622,-0.80133, 0.31875]
kvec2   = [-0.38381, 0.75559,-0.53082]
kvec3   = [ 0.48207, 0.15612,-0.86211]
kvec4   = [-0.91343,-0.28841,-0.28717]
kvec5   = [-0.13019, 0.95333, 0.27241]
kvec6   = [-0.00459, 0.45789, 0.88900]
elam0   = [17.020331,2.3618471]
elam1   = [11.045271,4.1551802]
elam2   = [105.62444,3.3581263]
elam3   = [14.628501,2.2880040]
elam4   = [23.218763,1.9591213]
elam5   = [69.760363,2.7773742]
elam6   = [177.88869,1.7117800]
bvec0   = [-0.39363, 0.86680, 0.30613]
bvec1   = [-0.40175, 0.85313, 0.33282]
bvec2   = [-0.41674, 0.87697, 0.23921]
bvec3   = [-0.37812, 0.88589, 0.26874]
bvec4   = [-0.35177, 0.89643, 0.26956]
bvec5   = [-0.34326, 0.90304, 0.25813]
bvec6   = [-0.33056, 0.91603, 0.22716]
bmag0   = [36.96551]
bmag1   = [37.33871]
bmag2   = [37.62800]
bmag3   = [38.00787]
bmag4   = [37.89287]
bmag5   = [37.96736]
bmag6   = [38.26227]
tr_str_62 = CREATE_STRUCT(tags[0L:6L],tr0,tr1,tr2,tr3,tr4,tr5,tr6)
kv_str_62 = CREATE_STRUCT(tags[0L:6L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6)
bv_str_62 = CREATE_STRUCT(tags[0L:6L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6)
bm_str_62 = CREATE_STRUCT(tags[0L:6L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6)
eg_str_62 = CREATE_STRUCT(tags[0L:6L],elam0,elam1,elam2,elam3,elam4,elam5,elam6)
;
; => For  100 Hz < f < 300 Hz  at  1998-09-24/23:45:52.184 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:45:52.2720',prefd[0]+'23:45:52.2965'])
tr1     = time_double([prefd[0]+'23:45:52.3051',prefd[0]+'23:45:52.3168'])
tr2     = time_double([prefd[0]+'23:45:52.5173',prefd[0]+'23:45:52.5392'])
tr3     = time_double([prefd[0]+'23:45:52.5504',prefd[0]+'23:45:52.5680'])
tr4     = time_double([prefd[0]+'23:45:52.6064',prefd[0]+'23:45:52.6443'])
tr5     = time_double([prefd[0]+'23:45:52.6560',prefd[0]+'23:45:52.6768'])
tr6     = time_double([prefd[0]+'23:45:52.6864',prefd[0]+'23:45:52.7136'])
tr7     = time_double([prefd[0]+'23:45:52.7381',prefd[0]+'23:45:52.7643'])
tr8     = time_double([prefd[0]+'23:45:52.7648',prefd[0]+'23:45:52.7797'])
tr9     = time_double([prefd[0]+'23:45:52.7883',prefd[0]+'23:45:52.8048'])
tr10    = time_double([prefd[0]+'23:45:52.8160',prefd[0]+'23:45:52.8432'])
tr11    = time_double([prefd[0]+'23:45:52.8501',prefd[0]+'23:45:52.8688'])
tr12    = time_double([prefd[0]+'23:45:52.9072',prefd[0]+'23:45:52.9307'])
tr13    = time_double([prefd[0]+'23:45:53.0757',prefd[0]+'23:45:53.1019'])
tr14    = time_double([prefd[0]+'23:45:53.1312',prefd[0]+'23:45:53.1483'])
tr15    = time_double([prefd[0]+'23:45:53.2080',prefd[0]+'23:45:53.2192'])
kvec0   = [-0.26831, 0.96178,-0.05470]
kvec1   = [-0.15521, 0.98393,-0.08824]
kvec2   = [-0.44551, 0.88835, 0.11117]
kvec3   = [-0.37382, 0.92745,-0.00937]
kvec4   = [-0.43834, 0.87636, 0.19961]
kvec5   = [-0.56609, 0.80905, 0.15807]
kvec6   = [-0.01452, 0.03111, 0.99941]
kvec7   = [-0.24328, 0.96967,-0.02354]
kvec8   = [-0.17117, 0.98360, 0.05690]
kvec9   = [-0.11893, 0.95587,-0.26864]
kvec10  = [-0.50855, 0.86087,-0.01666]
kvec11  = [-0.30145, 0.92449,-0.23332]
kvec12  = [-0.39123, 0.86238,-0.32129]
kvec13  = [-0.89916, 0.14206, 0.41392]
kvec14  = [-0.95488,-0.04277,-0.29390]
kvec15  = [ 0.95346, 0.29549,-0.05992]
elam0   = [10.491600,3.5389407]
elam1   = [21.914105,3.4254733]
elam2   = [30.109949,2.0537280]
elam3   = [53.748889,3.8948033]
elam4   = [75.312227,2.9754440]
elam5   = [24.034594,3.1534748]
elam6   = [28.038376,12.250312]
elam7   = [38.539052,2.0964882]
elam8   = [14.175149,3.6809604]
elam9   = [13.241567,2.4419507]
elam10  = [45.270082,2.4018341]
elam11  = [20.998343,2.1831746]
elam12  = [29.284075,1.7958114]
elam13  = [62.121487,3.6812325]
elam14  = [15.798078,2.3363247]
elam15  = [50.222982,1.2351845]
bvec0   = [-0.39118, 0.86844, 0.30462]
bvec1   = [-0.39549, 0.86553, 0.30733]
bvec2   = [-0.40051, 0.85089, 0.33997]
bvec3   = [-0.40321, 0.85583, 0.32389]
bvec4   = [-0.41965, 0.88121, 0.21688]
bvec5   = [-0.41930, 0.89091, 0.17448]
bvec6   = [-0.41365, 0.89748, 0.15295]
bvec7   = [-0.40422, 0.90199, 0.15142]
bvec8   = [-0.40003, 0.89909, 0.17774]
bvec9   = [-0.39469, 0.89479, 0.20863]
bvec10  = [-0.38779, 0.88891, 0.24379]
bvec11  = [-0.38415, 0.88761, 0.25410]
bvec12  = [-0.37678, 0.88622, 0.26953]
bvec13  = [-0.32387, 0.92222, 0.21115]
bvec14  = [-0.31817, 0.93359, 0.16477]
bvec15  = [-0.31875, 0.94267, 0.09886]
bmag0   = [36.74172]
bmag1   = [37.13659]
bmag2   = [37.02854]
bmag3   = [37.11294]
bmag4   = [37.81704]
bmag5   = [37.65031]
bmag6   = [37.07808]
bmag7   = [36.62094]
bmag8   = [36.77810]
bmag9   = [37.00132]
bmag10  = [37.33335]
bmag11  = [37.57768]
bmag12  = [38.02568]
bmag13  = [38.43571]
bmag14  = [38.25774]
bmag15  = [37.75819]
tr_str_63 = CREATE_STRUCT(tags[0L:15L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,$
                          tr10,tr11,tr12,tr13,tr14,tr15)
kv_str_63  = CREATE_STRUCT(tags[0L:15L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,$
                           kvec9,kvec10,kvec11,kvec12,kvec13,kvec14,kvec15)
bv_str_63  = CREATE_STRUCT(tags[0L:15L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,$
                           bvec9,bvec10,bvec11,bvec12,bvec13,bvec14,bvec15)
bm_str_63  = CREATE_STRUCT(tags[0L:15L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,$
                           bmag9,bmag10,bmag11,bmag12,bmag13,bmag14,bmag15)
eg_str_63  = CREATE_STRUCT(tags[0L:15L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,$
                           elam9,elam10,elam11,elam12,elam13,elam14,elam15)
tr_str_6  = CREATE_STRUCT(['T0','T1','T2','T3'],tr_str_60,tr_str_61,tr_str_62,tr_str_63)
kv_str_6  = CREATE_STRUCT(['T0','T1','T2','T3'],kv_str_60,kv_str_61,kv_str_62,kv_str_63)
bv_str_6  = CREATE_STRUCT(['T0','T1','T2','T3'],bv_str_60,bv_str_61,bv_str_62,bv_str_63)
bm_str_6  = CREATE_STRUCT(['T0','T1','T2','T3'],bm_str_60,bm_str_61,bm_str_62,bm_str_63)
eg_str_6  = CREATE_STRUCT(['T0','T1','T2','T3'],eg_str_60,eg_str_61,eg_str_62,eg_str_63)
;
; => For  3 Hz < f < 30 Hz  at  1998-09-24/23:45:53.379 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:45:53.3790',prefd[0]+'23:45:53.4830'])
tr1     = time_double([prefd[0]+'23:45:53.9603',prefd[0]+'23:45:54.0563'])
tr2     = time_double([prefd[0]+'23:45:54.1977',prefd[0]+'23:45:54.3625'])
kvec0   = [ 0.84150, 0.42724,-0.33067]
kvec1   = [-0.61395,-0.78848, 0.03698]
kvec2   = [-0.81915,-0.56581, 0.09404]
elam0   = [36.294570,3.4691180]
elam1   = [18.098118,2.7334335]
elam2   = [11.662294,4.6997212]
bvec0   = [-0.33137, 0.94228, 0.04754]
bvec1   = [-0.17263, 0.97093, 0.16525]
bvec2   = [-0.13380, 0.98966, 0.04879]
bmag0   = [36.55270]
bmag1   = [37.31338]
bmag2   = [37.31278]
tr_str_70 = CREATE_STRUCT(tags[0L:2L],tr0,tr1,tr2)
kv_str_70 = CREATE_STRUCT(tags[0L:2L],kvec0,kvec1,kvec2)
bv_str_70 = CREATE_STRUCT(tags[0L:2L],bvec0,bvec1,bvec2)
bm_str_70 = CREATE_STRUCT(tags[0L:2L],bmag0,bmag1,bmag2)
eg_str_70 = CREATE_STRUCT(tags[0L:2L],elam0,elam1,elam2)
;
; => For  10 Hz < f < 30 Hz  at  1998-09-24/23:45:53.379 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:45:53.4105',prefd[0]+'23:45:53.4670'])
tr1     = time_double([prefd[0]+'23:45:53.5315',prefd[0]+'23:45:53.5662'])
tr2     = time_double([prefd[0]+'23:45:53.5795',prefd[0]+'23:45:53.6318'])
tr3     = time_double([prefd[0]+'23:45:53.6510',prefd[0]+'23:45:53.7017'])
tr4     = time_double([prefd[0]+'23:45:53.7443',prefd[0]+'23:45:53.8147'])
tr5     = time_double([prefd[0]+'23:45:54.2206',prefd[0]+'23:45:54.2830'])
tr6     = time_double([prefd[0]+'23:45:54.4238',prefd[0]+'23:45:54.4707'])
kvec0   = [ 0.83506, 0.48611,-0.25763]
kvec1   = [ 0.83370, 0.52747,-0.16346]
kvec2   = [ 0.13241,-0.71833, 0.68298]
kvec3   = [-0.66941,-0.73580,-0.10243]
kvec4   = [ 0.23506, 0.96530, 0.11377]
kvec5   = [ 0.96623, 0.23769,-0.09950]
kvec6   = [ 0.98563,-0.16033,-0.05316]
elam0   = [12.422212,2.9564838]
elam1   = [3207.9226,6.6885591]
elam2   = [21.865255,1.4370167]
elam3   = [12.129272,3.1620564]
elam4   = [62.979651,5.1292091]
elam5   = [72.433134,3.4183791]
elam6   = [1579.4425,1.3766043]
bvec0   = [-0.33056, 0.94251, 0.04900]
bvec1   = [-0.29953, 0.95266, 0.05196]
bvec2   = [-0.27956, 0.95902, 0.04580]
bvec3   = [-0.26621, 0.96266, 0.04860]
bvec4   = [-0.26988, 0.95990, 0.07561]
bvec5   = [-0.12963, 0.98994, 0.05621]
bvec6   = [-0.21097, 0.97530, 0.06354]
bmag0   = [36.54142]
bmag1   = [36.66088]
bmag2   = [36.54723]
bmag3   = [36.25351]
bmag4   = [36.19436]
bmag5   = [37.62001]
bmag6   = [35.57579]
tr_str_71 = CREATE_STRUCT(tags[0L:6L],tr0,tr1,tr2,tr3,tr4,tr5,tr6)
kv_str_71 = CREATE_STRUCT(tags[0L:6L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6)
bv_str_71 = CREATE_STRUCT(tags[0L:6L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6)
bm_str_71 = CREATE_STRUCT(tags[0L:6L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6)
eg_str_71 = CREATE_STRUCT(tags[0L:6L],elam0,elam1,elam2,elam3,elam4,elam5,elam6)
;
; => For  15 Hz < f < 60 Hz  at  1998-09-24/23:45:53.379 UT
;
tr_str_72 = 0
kv_str_72 = 0
bv_str_72 = 0
bm_str_72 = 0
eg_str_72 = 0
;
; => For  30 Hz < f < 100 Hz  at  1998-09-24/23:45:53.379 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:45:53.8787',prefd[0]+'23:45:53.8990'])
tr1     = time_double([prefd[0]+'23:45:53.9134',prefd[0]+'23:45:53.9342'])
tr2     = time_double([prefd[0]+'23:45:53.9721',prefd[0]+'23:45:54.0009'])
tr3     = time_double([prefd[0]+'23:45:54.0014',prefd[0]+'23:45:54.0409'])
tr4     = time_double([prefd[0]+'23:45:54.0414',prefd[0]+'23:45:54.0595'])
tr5     = time_double([prefd[0]+'23:45:54.1182',prefd[0]+'23:45:54.1577'])
tr6     = time_double([prefd[0]+'23:45:54.2830',prefd[0]+'23:45:54.3022'])
kvec0   = [ 0.94764, 0.28012, 0.15335]
kvec1   = [-0.83295,-0.26101,-0.48793]
kvec2   = [ 0.86884, 0.46138, 0.17959]
kvec3   = [ 0.55075, 0.80295, 0.22792]
kvec4   = [ 0.78905, 0.61418,-0.01347]
kvec5   = [ 0.63555, 0.49466,-0.59278]
kvec6   = [ 0.85932, 0.30861, 0.40783]
elam0   = [41.533379,4.0895355]
elam1   = [38.376669,1.6240703]
elam2   = [34.812951,4.2771430]
elam3   = [38.793612,4.5146921]
elam4   = [56.005101,4.4059436]
elam5   = [38.873166,1.7444184]
elam6   = [15.980759,5.5799013]
bvec0   = [-0.22172, 0.96990, 0.10052]
bvec1   = [-0.19922, 0.97237, 0.12157]
bvec2   = [-0.17888, 0.97108, 0.15801]
bvec3   = [-0.16901, 0.97014, 0.17391]
bvec4   = [-0.16011, 0.97218, 0.17096]
bvec5   = [-0.13697, 0.98135, 0.13447]
bvec6   = [-0.13185, 0.99053, 0.03811]
bmag0   = [36.76622]
bmag1   = [36.74579]
bmag2   = [37.15865]
bmag3   = [37.42200]
bmag4   = [37.58584]
bmag5   = [37.88613]
bmag6   = [37.41882]
tr_str_73 = CREATE_STRUCT(tags[0L:6L],tr0,tr1,tr2,tr3,tr4,tr5,tr6)
kv_str_73 = CREATE_STRUCT(tags[0L:6L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6)
bv_str_73 = CREATE_STRUCT(tags[0L:6L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6)
bm_str_73 = CREATE_STRUCT(tags[0L:6L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6)
eg_str_73 = CREATE_STRUCT(tags[0L:6L],elam0,elam1,elam2,elam3,elam4,elam5,elam6)
tr_str_7  = CREATE_STRUCT(['T0','T1','T2','T3'],tr_str_70,tr_str_71,tr_str_72,tr_str_73)
kv_str_7  = CREATE_STRUCT(['T0','T1','T2','T3'],kv_str_70,kv_str_71,kv_str_72,kv_str_73)
bv_str_7  = CREATE_STRUCT(['T0','T1','T2','T3'],bv_str_70,bv_str_71,bv_str_72,bv_str_73)
bm_str_7  = CREATE_STRUCT(['T0','T1','T2','T3'],bm_str_70,bm_str_71,bm_str_72,bm_str_73)
eg_str_7  = CREATE_STRUCT(['T0','T1','T2','T3'],eg_str_70,eg_str_71,eg_str_72,eg_str_73)
;
; => For  3 Hz < f < 30 Hz  at  1998-09-24/23:48:39.020 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:48:39.0893',prefd[0]+'23:48:39.1592'])
tr1     = time_double([prefd[0]+'23:48:39.4568',prefd[0]+'23:48:39.5896'])
tr2     = time_double([prefd[0]+'23:48:39.8269',prefd[0]+'23:48:39.8808'])
tr3     = time_double([prefd[0]+'23:48:39.9443',prefd[0]+'23:48:40.0003'])
kvec0   = [-0.69954,-0.70333, 0.12641]
kvec1   = [-0.99818, 0.02093,-0.05653]
kvec2   = [ 0.19072, 0.85902, 0.47508]
kvec3   = [-0.94753, 0.06257,-0.31350]
elam0   = [154.74879,1.2726007]
elam1   = [45.537709,2.4461524]
elam2   = [11.657016,4.1448612]
elam3   = [22.399406,1.3734763]
bvec0   = [-0.57094, 0.13760, 0.80938]
bvec1   = [-0.48937, 0.06926, 0.86869]
bvec2   = [-0.52446, 0.06980, 0.84855]
bvec3   = [-0.53003, 0.05332, 0.84630]
bmag0   = [35.77160]
bmag1   = [33.45378]
bmag2   = [35.60096]
bmag3   = [36.19178]
tr_str_80 = CREATE_STRUCT(tags[0L:3L],tr0,tr1,tr2,tr3)
kv_str_80 = CREATE_STRUCT(tags[0L:3L],kvec0,kvec1,kvec2,kvec3)
bv_str_80 = CREATE_STRUCT(tags[0L:3L],bvec0,bvec1,bvec2,bvec3)
bm_str_80 = CREATE_STRUCT(tags[0L:3L],bmag0,bmag1,bmag2,bmag3)
eg_str_80 = CREATE_STRUCT(tags[0L:3L],elam0,elam1,elam2,elam3)
;
; => For  4 Hz < f < 40 Hz  at  1998-09-24/23:48:39.020 UT
;
tr_str_81 = 0
kv_str_81 = 0
bv_str_81 = 0
bm_str_81 = 0
eg_str_81 = 0
;
; => For  10 Hz < f < 40 Hz  at  1998-09-24/23:48:39.020 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:48:39.0200',prefd[0]+'23:48:39.1555'])
tr1     = time_double([prefd[0]+'23:48:39.9987',prefd[0]+'23:48:40.0808'])
kvec0   = [ 0.47453,-0.38843, 0.78990]
kvec1   = [ 0.93018, 0.16024,-0.33029]
elam0   = [32.196043,2.3319916]
elam1   = [27.053090,2.2106113]
bvec0   = [-0.57287, 0.13625, 0.80823]
bvec1   = [-0.53793, 0.04520, 0.84176]
bmag0   = [35.97463]
bmag1   = [36.30701]
tr_str_82 = CREATE_STRUCT(tags[0L:1L],tr0,tr1)
kv_str_82 = CREATE_STRUCT(tags[0L:1L],kvec0,kvec1)
bv_str_82 = CREATE_STRUCT(tags[0L:1L],bvec0,bvec1)
bm_str_82 = CREATE_STRUCT(tags[0L:1L],bmag0,bmag1)
eg_str_82 = CREATE_STRUCT(tags[0L:1L],elam0,elam1)
tr_str_8  = CREATE_STRUCT(['T0','T1','T2'],tr_str_80,tr_str_81,tr_str_82)
kv_str_8  = CREATE_STRUCT(['T0','T1','T2'],kv_str_80,kv_str_81,kv_str_82)
bv_str_8  = CREATE_STRUCT(['T0','T1','T2'],bv_str_80,bv_str_81,bv_str_82)
bm_str_8  = CREATE_STRUCT(['T0','T1','T2'],bm_str_80,bm_str_81,bm_str_82)
eg_str_8  = CREATE_STRUCT(['T0','T1','T2'],eg_str_80,eg_str_81,eg_str_82)
;
; => For  3 Hz < f < 30 Hz  at  1998-09-24/23:48:42.131 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:48:43.1358',prefd[0]+'23:48:43.2227'])
kvec0   = [-0.87410, 0.03281,-0.48464]
elam0   = [53.356093,2.1415350]
bvec0   = [-0.36657, 0.10617, 0.92429]
bmag0   = [36.70069]
tr_str_90 = CREATE_STRUCT(tags[0L:0L],tr0)
kv_str_90 = CREATE_STRUCT(tags[0L:0L],kvec0)
bv_str_90 = CREATE_STRUCT(tags[0L:0L],bvec0)
bm_str_90 = CREATE_STRUCT(tags[0L:0L],bmag0)
eg_str_90 = CREATE_STRUCT(tags[0L:0L],elam0)
;
; => For  5 Hz < f < 30 Hz  at  1998-09-24/23:48:42.131 UT
;
tr_str_91 = 0
kv_str_91 = 0
bv_str_91 = 0
bm_str_91 = 0
eg_str_91 = 0
;
; => For  7 Hz < f < 30 Hz  at  1998-09-24/23:48:42.131 UT
;
tr_str_92 = 0
kv_str_92 = 0
bv_str_92 = 0
bm_str_92 = 0
eg_str_92 = 0
;
; => For  65 Hz < f < 300 Hz  at  1998-09-24/23:48:42.131 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:48:42.9134',prefd[0]+'23:48:42.9486'])
tr1     = time_double([prefd[0]+'23:48:43.0430',prefd[0]+'23:48:43.1177'])
kvec0   = [ 0.50505,-0.35900,-0.78488]
kvec1   = [-0.37503, 0.18313, 0.90874]
elam0   = [41.869068,1.5556371]
elam1   = [17.150403,1.4015240]
bvec0   = [-0.35979, 0.04736, 0.93183]
bvec1   = [-0.35951, 0.08646, 0.92908]
bmag0   = [36.62919]
bmag1   = [36.61893]
tr_str_93 = CREATE_STRUCT(tags[0L:1L],tr0,tr1)
kv_str_93 = CREATE_STRUCT(tags[0L:1L],kvec0,kvec1)
bv_str_93 = CREATE_STRUCT(tags[0L:1L],bvec0,bvec1)
bm_str_93 = CREATE_STRUCT(tags[0L:1L],bmag0,bmag1)
eg_str_93 = CREATE_STRUCT(tags[0L:1L],elam0,elam1)
tr_str_9  = CREATE_STRUCT(['T0','T1','T2','T3'],tr_str_90,tr_str_91,tr_str_92,tr_str_93)
kv_str_9  = CREATE_STRUCT(['T0','T1','T2','T3'],kv_str_90,kv_str_91,kv_str_92,kv_str_93)
bv_str_9  = CREATE_STRUCT(['T0','T1','T2','T3'],bv_str_90,bv_str_91,bv_str_92,bv_str_93)
bm_str_9  = CREATE_STRUCT(['T0','T1','T2','T3'],bm_str_90,bm_str_91,bm_str_92,bm_str_93)
eg_str_9  = CREATE_STRUCT(['T0','T1','T2','T3'],eg_str_90,eg_str_91,eg_str_92,eg_str_93)
;
; => For  3 Hz < f < 30 Hz  at  1998-09-24/23:48:51.622 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:48:51.7292',prefd[0]+'23:48:51.7676'])
tr1     = time_double([prefd[0]+'23:48:51.8305',prefd[0]+'23:48:51.8700'])
tr2     = time_double([prefd[0]+'23:48:51.9985',prefd[0]+'23:48:52.0465'])
tr3     = time_double([prefd[0]+'23:48:52.1255',prefd[0]+'23:48:52.2140'])
tr4     = time_double([prefd[0]+'23:48:52.2140',prefd[0]+'23:48:52.2828'])
tr5     = time_double([prefd[0]+'23:48:52.4204',prefd[0]+'23:48:52.5100'])
tr6     = time_double([prefd[0]+'23:48:52.5745',prefd[0]+'23:48:52.6188'])
tr7     = time_double([prefd[0]+'23:48:52.6193',prefd[0]+'23:48:52.6700'])
tr8     = time_double([prefd[0]+'23:48:52.6705',prefd[0]+'23:48:52.7137'])
kvec0   = [ 0.97104,-0.07546,-0.22668]
kvec1   = [ 0.33812, 0.93928, 0.05848]
kvec2   = [ 0.80539,-0.09212, 0.58554]
kvec3   = [ 0.78323,-0.53048, 0.32427]
kvec4   = [ 0.11369,-0.25738, 0.95960]
kvec5   = [ 0.21867,-0.55855,-0.80013]
kvec6   = [-0.12104, 0.79854,-0.58965]
kvec7   = [ 0.87821,-0.35410, 0.32150]
kvec8   = [-0.19853, 0.39234, 0.89814]
elam0   = [17.035350,1.1485499]
elam1   = [21.521769,7.0496031]
elam2   = [24.369127,9.5501529]
elam3   = [27.153925,2.0031317]
elam4   = [76.307833,2.7608438]
elam5   = [14.580223,4.1599116]
elam6   = [42.643769,2.3939870]
elam7   = [26.732400,11.262658]
elam8   = [97.883290,4.5885985]
bvec0   = [-0.44006,-0.05226, 0.89645]
bvec1   = [-0.43928,-0.07447, 0.89525]
bvec2   = [-0.43960,-0.08303, 0.89435]
bvec3   = [-0.43170,-0.06896, 0.89937]
bvec4   = [-0.42504,-0.07594, 0.90195]
bvec5   = [-0.43640,-0.08465, 0.89575]
bvec6   = [-0.42788,-0.07712, 0.90054]
bvec7   = [-0.42489,-0.08280, 0.90145]
bvec8   = [-0.42234,-0.08726, 0.90223]
bmag0   = [35.99808]
bmag1   = [36.22013]
bmag2   = [36.40689]
bmag3   = [36.82518]
bmag4   = [36.70990]
bmag5   = [37.06684]
bmag6   = [36.77235]
bmag7   = [36.79766]
bmag8   = [36.84108]
tr_str_100  = CREATE_STRUCT(tags[0L:8L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8)
kv_str_100  = CREATE_STRUCT(tags[0L:8L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8)
bv_str_100  = CREATE_STRUCT(tags[0L:8L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8)
bm_str_100  = CREATE_STRUCT(tags[0L:8L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8)
eg_str_100  = CREATE_STRUCT(tags[0L:8L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8)
;
; => For  6 Hz < f < 30 Hz  at  1998-09-24/23:48:51.622 UT
;
prefd   = '1998-09-24/'
tr0     = time_double([prefd[0]+'23:48:51.7292',prefd[0]+'23:48:51.7708'])
tr1     = time_double([prefd[0]+'23:48:51.8012',prefd[0]+'23:48:51.8396'])
tr2     = time_double([prefd[0]+'23:48:51.8396',prefd[0]+'23:48:51.8727'])
tr3     = time_double([prefd[0]+'23:48:51.8988',prefd[0]+'23:48:51.9772'])
tr4     = time_double([prefd[0]+'23:48:51.9969',prefd[0]+'23:48:52.0407'])
tr5     = time_double([prefd[0]+'23:48:52.1121',prefd[0]+'23:48:52.1452'])
tr6     = time_double([prefd[0]+'23:48:52.1628',prefd[0]+'23:48:52.1980'])
tr7     = time_double([prefd[0]+'23:48:52.2407',prefd[0]+'23:48:52.2860'])
tr8     = time_double([prefd[0]+'23:48:52.5793',prefd[0]+'23:48:52.6060'])
tr9     = time_double([prefd[0]+'23:48:52.6449',prefd[0]+'23:48:52.6833'])
kvec0   = [ 0.97591,-0.10233, 0.19267]
kvec1   = [-0.26654, 0.19362, 0.94417]
kvec2   = [-0.87608,-0.10477, 0.47065]
kvec3   = [-0.94313, 0.31190, 0.11497]
kvec4   = [ 0.78947, 0.03079, 0.61301]
kvec5   = [-0.91682, 0.39446, 0.06195]
kvec6   = [-0.08897, 0.05393, 0.99457]
kvec7   = [-0.53149, 0.42313,-0.73381]
kvec8   = [ 0.52519, 0.56150,-0.63945]
kvec9   = [-0.85805, 0.40195, 0.31967]
elam0   = [59.084627,2.2420611]
elam1   = [42.325833,4.2162804]
elam2   = [29.079338,1.8947801]
elam3   = [96.270569,11.498885]
elam4   = [152.72944,6.1228892]
elam5   = [122.13862,16.406894]
elam6   = [31.633553,16.152013]
elam7   = [57.354470,11.282906]
elam8   = [109.46513,2.4674859]
elam9   = [60.743539,4.9412592]
bvec0   = [-0.44005,-0.05247, 0.89644]
bvec1   = [-0.43961,-0.06764, 0.89563]
bvec2   = [-0.43918,-0.07548, 0.89522]
bvec3   = [-0.43586,-0.07279, 0.89707]
bvec4   = [-0.43938,-0.08250, 0.89450]
bvec5   = [-0.43742,-0.07189, 0.89638]
bvec6   = [-0.43009,-0.06838, 0.90019]
bvec7   = [-0.42618,-0.08185, 0.90091]
bvec8   = [-0.42812,-0.07656, 0.90047]
bvec9   = [-0.42372,-0.08535, 0.90176]
bmag0   = [35.99711]
bmag1   = [36.13456]
bmag2   = [36.23442]
bmag3   = [36.29160]
bmag4   = [36.40070]
bmag5   = [36.87651]
bmag6   = [36.80124]
bmag7   = [36.72199]
bmag8   = [36.76735]
bmag9   = [36.81766]
tr_str_101  = CREATE_STRUCT(tags[0L:9L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9)
kv_str_101  = CREATE_STRUCT(tags[0L:9L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,kvec9)
bv_str_101  = CREATE_STRUCT(tags[0L:9L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,bvec9)
bm_str_101  = CREATE_STRUCT(tags[0L:9L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,bmag9)
eg_str_101  = CREATE_STRUCT(tags[0L:9L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,elam9)
;
; => For  10 Hz < f < 100 Hz  at  1998-09-24/23:48:51.622 UT
;
tr_str_102 = 0
kv_str_102 = 0
bv_str_102 = 0
bm_str_102 = 0
eg_str_102 = 0
tr_str_10  = CREATE_STRUCT(['T0','T1','T2'],tr_str_100,tr_str_101,tr_str_102)
kv_str_10  = CREATE_STRUCT(['T0','T1','T2'],kv_str_100,kv_str_101,kv_str_102)
bv_str_10  = CREATE_STRUCT(['T0','T1','T2'],bv_str_100,bv_str_101,bv_str_102)
bm_str_10  = CREATE_STRUCT(['T0','T1','T2'],bm_str_100,bm_str_101,bm_str_102)
eg_str_10  = CREATE_STRUCT(['T0','T1','T2'],eg_str_100,eg_str_101,eg_str_102)
;
; => For  3 Hz < f < 30 Hz  at  1998-09-25/00:04:04.545 UT
;
prefd   = '1998-09-25/'
tr0     = time_double([prefd[0]+'00:04:04.6714',prefd[0]+'00:04:04.7482'])
tr1     = time_double([prefd[0]+'00:04:04.9002',prefd[0]+'00:04:04.9690'])
tr2     = time_double([prefd[0]+'00:04:05.0522',prefd[0]+'00:04:05.0954'])
tr3     = time_double([prefd[0]+'00:04:05.2682',prefd[0]+'00:04:05.3530'])
tr4     = time_double([prefd[0]+'00:04:05.3311',prefd[0]+'00:04:05.3866'])
tr5     = time_double([prefd[0]+'00:04:05.4527',prefd[0]+'00:04:05.5098'])
kvec0   = [-0.07775,-0.78702,-0.61201]
kvec1   = [-0.97773,-0.06902, 0.19821]
kvec2   = [-0.89497,-0.19178,-0.40280]
kvec3   = [ 0.84838, 0.24190, 0.47090]
kvec4   = [ 0.99316, 0.10809,-0.04425]
kvec5   = [ 0.93980, 0.28381, 0.19032]
elam0   = [44.67490,7.648347]
elam1   = [37.91687,3.085668]
elam2   = [76.34742,29.75200]
elam3   = [50.19652,1.461794]
elam4   = [80.99939,4.727877]
elam5   = [1636.188,4.059537]
bvec0   = [-0.10802, 0.97756,-0.18084]
bvec1   = [-0.14572, 0.97975,-0.13716]
bvec2   = [-0.17636, 0.97927,-0.09965]
bvec3   = [-0.18466, 0.97561,-0.11852]
bvec4   = [-0.19465, 0.97332,-0.12142]
bvec5   = [-0.20073, 0.96818,-0.14933]
bmag0   = [23.77359]
bmag1   = [23.31873]
bmag2   = [23.31872]
bmag3   = [23.24363]
bmag4   = [23.18337]
bmag5   = [23.18519]
tr_str_110  = CREATE_STRUCT(tags[0L:5L],tr0,tr1,tr2,tr3,tr4,tr5)
kv_str_110  = CREATE_STRUCT(tags[0L:5L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5)
bv_str_110  = CREATE_STRUCT(tags[0L:5L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5)
bm_str_110  = CREATE_STRUCT(tags[0L:5L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5)
eg_str_110  = CREATE_STRUCT(tags[0L:5L],elam0,elam1,elam2,elam3,elam4,elam5)
;
; => For  5 Hz < f < 50 Hz  at  1998-09-25/00:04:04.545 UT
;
tr_str_111 = 0
kv_str_111 = 0
bv_str_111 = 0
bm_str_111 = 0
eg_str_111 = 0
;
; => For  7 Hz < f < 50 Hz  at  1998-09-25/00:04:04.545 UT
;
prefd   = '1998-09-25/'
tr0     = time_double([prefd[0]+'00:04:05.0666',prefd[0]+'00:04:05.1130'])
tr1     = time_double([prefd[0]+'00:04:05.2815',prefd[0]+'00:04:05.3354'])
tr2     = time_double([prefd[0]+'00:04:05.3498',prefd[0]+'00:04:05.3914'])
tr3     = time_double([prefd[0]+'00:04:05.4559',prefd[0]+'00:04:05.4874'])
tr4     = time_double([prefd[0]+'00:04:05.4879',prefd[0]+'00:04:05.5418'])
tr5     = time_double([prefd[0]+'00:04:05.5823',prefd[0]+'00:04:05.6106'])
kvec0   = [ 0.95221, 0.05256, 0.30090]
kvec1   = [ 0.85275, 0.24633, 0.46058]
kvec2   = [-0.94919, 0.23615,-0.20804]
kvec3   = [-0.89935,-0.36793, 0.23623]
kvec4   = [-0.81977, 0.14215,-0.55476]
kvec5   = [-0.99147,-0.07696, 0.10516]
elam0   = [16.01954,5.404104]
elam1   = [536.5472,5.093474]
elam2   = [46.49745,2.695802]
elam3   = [41.23364,3.844631]
elam4   = [41.94646,3.269069]
elam5   = [89.75117,1.702374]
bvec0   = [-0.17864, 0.97896,-0.09857]
bvec1   = [-0.18435, 0.97576,-0.11787]
bvec2   = [-0.19663, 0.97269,-0.12332]
bvec3   = [-0.20134, 0.96850,-0.14653]
bvec4   = [-0.19905, 0.96719,-0.15781]
bvec5   = [-0.19773, 0.96529,-0.17061]
bmag0   = [23.41982]
bmag1   = [23.23606]
bmag2   = [23.19373]
bmag3   = [23.19260]
bmag4   = [23.16525]
bmag5   = [23.15012]
tr_str_112  = CREATE_STRUCT(tags[0L:5L],tr0,tr1,tr2,tr3,tr4,tr5)
kv_str_112  = CREATE_STRUCT(tags[0L:5L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5)
bv_str_112  = CREATE_STRUCT(tags[0L:5L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5)
bm_str_112  = CREATE_STRUCT(tags[0L:5L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5)
eg_str_112  = CREATE_STRUCT(tags[0L:5L],elam0,elam1,elam2,elam3,elam4,elam5)
tr_str_11  = CREATE_STRUCT(['T0','T1','T2'],tr_str_110,tr_str_111,tr_str_112)
kv_str_11  = CREATE_STRUCT(['T0','T1','T2'],kv_str_110,kv_str_111,kv_str_112)
bv_str_11  = CREATE_STRUCT(['T0','T1','T2'],bv_str_110,bv_str_111,bv_str_112)
bm_str_11  = CREATE_STRUCT(['T0','T1','T2'],bm_str_110,bm_str_111,bm_str_112)
eg_str_11  = CREATE_STRUCT(['T0','T1','T2'],eg_str_110,eg_str_111,eg_str_112)
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
jj      = 12L
;
; => For  3 Hz < f < 30 Hz  at  1998-09-25/00:05:23.432 UT
;
prefd   = '1998-09-25/'
tr0     = time_double([prefd[0]+'00:05:23.5024',prefd[0]+'00:05:23.6352'])
tr1     = time_double([prefd[0]+'00:05:23.8000',prefd[0]+'00:05:23.8832'])
tr2     = time_double([prefd[0]+'00:05:23.8832',prefd[0]+'00:05:24.0026'])
tr3     = time_double([prefd[0]+'00:05:24.0448',prefd[0]+'00:05:24.1232'])
tr4     = time_double([prefd[0]+'00:05:24.2629',prefd[0]+'00:05:24.3472'])
tr5     = time_double([prefd[0]+'00:05:24.3472',prefd[0]+'00:05:24.4512'])
kvec0   = [-0.11640, 0.21932, 0.96869]
kvec1   = [ 0.52467, 0.55136,-0.64863]
kvec2   = [-0.75587,-0.64998, 0.07862]
kvec3   = [ 0.33095, 0.94358,-0.01133]
kvec4   = [-0.90514,-0.19579, 0.37735]
kvec5   = [-0.67826, 0.66451, 0.31368]
elam0   = [28.30867,2.740280]
elam1   = [50.15574,10.98032]
elam2   = [48.82638,3.673204]
elam3   = [56.84211,12.16274]
elam4   = [16.72766,3.656796]
elam5   = [16.60950,1.863353]
bvec0   = [-0.46626, 0.80732, 0.36156]
bvec1   = [-0.49286, 0.83919, 0.22942]
bvec2   = [-0.47873, 0.85567, 0.19650]
bvec3   = [-0.46905, 0.85942, 0.20335]
bvec4   = [-0.44775, 0.87069, 0.20319]
bvec5   = [-0.44929, 0.88446, 0.11779]
bmag0   = [22.78819]
bmag1   = [24.16436]
bmag2   = [23.88314]
bmag3   = [23.40712]
bmag4   = [24.16453]
bmag5   = [24.03419]
tr_str_120  = CREATE_STRUCT(tags[0L:5L],tr0,tr1,tr2,tr3,tr4,tr5)
kv_str_120  = CREATE_STRUCT(tags[0L:5L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5)
bv_str_120  = CREATE_STRUCT(tags[0L:5L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5)
bm_str_120  = CREATE_STRUCT(tags[0L:5L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5)
eg_str_120  = CREATE_STRUCT(tags[0L:5L],elam0,elam1,elam2,elam3,elam4,elam5)
;
; => For  5 Hz < f < 50 Hz  at  1998-09-25/00:05:23.432 UT
;
tr_str_121 = 0
kv_str_121 = 0
bv_str_121 = 0
bm_str_121 = 0
eg_str_121 = 0
;
; => For  40 Hz < f < 200 Hz  at  1998-09-25/00:05:23.432 UT
;
prefd   = '1998-09-25/'
tr0     = time_double([prefd[0]+'00:05:23.4592',prefd[0]+'00:05:23.4816'])
tr1     = time_double([prefd[0]+'00:05:23.5008',prefd[0]+'00:05:23.5162'])
tr2     = time_double([prefd[0]+'00:05:23.5328',prefd[0]+'00:05:23.5658'])
tr3     = time_double([prefd[0]+'00:05:23.6128',prefd[0]+'00:05:23.6234'])
tr4     = time_double([prefd[0]+'00:05:23.7376',prefd[0]+'00:05:23.7658'])
tr5     = time_double([prefd[0]+'00:05:23.7728',prefd[0]+'00:05:23.7904'])
tr6     = time_double([prefd[0]+'00:05:23.8208',prefd[0]+'00:05:23.8528'])
tr7     = time_double([prefd[0]+'00:05:23.9408',prefd[0]+'00:05:23.9834'])
tr8     = time_double([prefd[0]+'00:05:24.0405',prefd[0]+'00:05:24.0592'])
tr9     = time_double([prefd[0]+'00:05:24.0928',prefd[0]+'00:05:24.1088'])
tr10    = time_double([prefd[0]+'00:05:24.1520',prefd[0]+'00:05:24.1680'])
tr11    = time_double([prefd[0]+'00:05:24.1744',prefd[0]+'00:05:24.1920'])
tr12    = time_double([prefd[0]+'00:05:24.3920',prefd[0]+'00:05:24.4160'])
kvec0   = [ 0.74360, 0.52564,-0.41324]
kvec1   = [ 0.86050, 0.31942,-0.39688]
kvec2   = [-0.89009,-0.41376, 0.19116]
kvec3   = [-0.99850, 0.04916, 0.02395]
kvec4   = [ 0.83505, 0.46736,-0.29028]
kvec5   = [-0.77294,-0.61234, 0.16615]
kvec6   = [ 0.80826, 0.54728, 0.21726]
kvec7   = [-0.82616,-0.56179,-0.04289]
kvec8   = [-0.81419,-0.54185,-0.20858]
kvec9   = [-0.85966,-0.45820, 0.22593]
kvec10  = [-0.61446,-0.53876, 0.57634]
kvec11  = [ 0.73035, 0.06084, 0.68036]
kvec12  = [ 0.92761, 0.31431,-0.20189]
elam0   = [46.37128,6.088881]
elam1   = [39.93233,3.328742]
elam2   = [69.55151,3.968775]
elam3   = [113.8069,4.732501]
elam4   = [16.63271,1.794867]
elam5   = [192.6935,1.209217]
elam6   = [22.42992,1.856203]
elam7   = [42.68345,3.854229]
elam8   = [34.09875,1.501903]
elam9   = [19.95830,6.366848]
elam10   = [18.91188,7.481237]
elam11   = [16.84900,3.517154]
elam12   = [30.64021,3.922757]
bvec0   = [-0.44980, 0.81470, 0.36598]
bvec1   = [-0.45408, 0.81098, 0.36894]
bvec2   = [-0.46143, 0.80812, 0.36609]
bvec3   = [-0.47723, 0.80474, 0.35306]
bvec4   = [-0.49707, 0.81869, 0.28746]
bvec5   = [-0.49867, 0.82524, 0.26513]
bvec6   = [-0.49376, 0.83808, 0.23194]
bvec7   = [-0.47667, 0.85745, 0.19380]
bvec8   = [-0.47226, 0.85910, 0.19727]
bvec9   = [-0.46694, 0.85972, 0.20699]
bvec10  = [-0.45506, 0.86160, 0.22489]
bvec11  = [-0.45103, 0.86311, 0.22718]
bvec12  = [-0.44884, 0.88664, 0.11090]
bmag0   = [22.28275]
bmag1   = [22.49725]
bmag2   = [22.69914]
bmag3   = [23.00872]
bmag4   = [23.96739]
bmag5   = [24.12446]
bmag6   = [24.17150]
bmag7   = [23.80768]
bmag8   = [23.46935]
bmag9   = [23.39295]
bmag10  = [23.48533]
bmag11  = [23.55203]
bmag12  = [23.96985]
tr_str_122  = CREATE_STRUCT(tags[0L:12L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,$
                            tr10,tr11,tr12)
kv_str_122  = CREATE_STRUCT(tags[0L:12L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,$
                            kvec9,kvec10,kvec11,kvec12)
bv_str_122  = CREATE_STRUCT(tags[0L:12L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,$
                            bvec9,bvec10,bvec11,bvec12)
bm_str_122  = CREATE_STRUCT(tags[0L:12L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,$
                            bmag9,bmag10,bmag11,bmag12)
eg_str_122  = CREATE_STRUCT(tags[0L:12L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,$
                            elam9,elam10,elam11,elam12)
tr_str_12  = CREATE_STRUCT(['T0','T1','T2'],tr_str_120,tr_str_121,tr_str_122)
kv_str_12  = CREATE_STRUCT(['T0','T1','T2'],kv_str_120,kv_str_121,kv_str_122)
bv_str_12  = CREATE_STRUCT(['T0','T1','T2'],bv_str_120,bv_str_121,bv_str_122)
bm_str_12  = CREATE_STRUCT(['T0','T1','T2'],bm_str_120,bm_str_121,bm_str_122)
eg_str_12  = CREATE_STRUCT(['T0','T1','T2'],eg_str_120,eg_str_121,eg_str_122)
;
; => For  3 Hz < f < 30 Hz  at  1998-09-25/00:14:50.603 UT
;
prefd   = '1998-09-25/'
tr0     = time_double([prefd[0]+'00:14:50.6478',prefd[0]+'00:14:50.7032'])
tr1     = time_double([prefd[0]+'00:14:50.9112',prefd[0]+'00:14:51.0158'])
tr2     = time_double([prefd[0]+'00:14:51.3822',prefd[0]+'00:14:51.4424'])
tr3     = time_double([prefd[0]+'00:14:51.4899',prefd[0]+'00:14:51.5678'])
tr4     = time_double([prefd[0]+'00:14:51.6467',prefd[0]+'00:14:51.6947'])
kvec0   = [ 0.74314,-0.33136,-0.58133]
kvec1   = [-0.97299,-0.20495, 0.10626]
kvec2   = [ 0.76670, 0.56290,-0.30871]
kvec3   = [-0.82809,-0.00588,-0.56056]
kvec4   = [ 0.76815, 0.62058, 0.15759]
elam0   = [51.32791,2.290718]
elam1   = [43.49175,1.476469]
elam2   = [16.63086,1.498320]
elam3   = [60.74822,1.520173]
elam4   = [211.9974,7.537972]
bvec0   = [-0.38238, 0.77342,-0.50559]
bvec1   = [-0.38277, 0.76930,-0.51153]
bvec2   = [-0.37472, 0.78302,-0.49644]
bvec3   = [-0.37477, 0.78392,-0.49498]
bvec4   = [-0.37646, 0.78298,-0.49519]
bmag0   = [23.57741]
bmag1   = [23.49861]
bmag2   = [23.38134]
bmag3   = [23.16161]
bmag4   = [22.82554]
tr_str_130  = CREATE_STRUCT(tags[0L:4L],tr0,tr1,tr2,tr3,tr4)
kv_str_130  = CREATE_STRUCT(tags[0L:4L],kvec0,kvec1,kvec2,kvec3,kvec4)
bv_str_130  = CREATE_STRUCT(tags[0L:4L],bvec0,bvec1,bvec2,bvec3,bvec4)
bm_str_130  = CREATE_STRUCT(tags[0L:4L],bmag0,bmag1,bmag2,bmag3,bmag4)
eg_str_130  = CREATE_STRUCT(tags[0L:4L],elam0,elam1,elam2,elam3,elam4)
;
; => For  7 Hz < f < 50 Hz  at  1998-09-25/00:14:50.603 UT
;
tr_str_131 = 0
kv_str_131 = 0
bv_str_131 = 0
bm_str_131 = 0
eg_str_131 = 0
;
; => For  10 Hz < f < 100 Hz  at  1998-09-25/00:14:50.603 UT
;
tr_str_132 = 0
kv_str_132 = 0
bv_str_132 = 0
bm_str_132 = 0
eg_str_132 = 0
;
; => For  20 Hz < f < 100 Hz  at  1998-09-25/00:14:50.603 UT
;
tr_str_133 = 0
kv_str_133 = 0
bv_str_133 = 0
bm_str_133 = 0
eg_str_133 = 0
tr_str_13  = CREATE_STRUCT(['T0','T1','T2','T3'],tr_str_130,tr_str_131,tr_str_132,tr_str_133)
kv_str_13  = CREATE_STRUCT(['T0','T1','T2','T3'],kv_str_130,kv_str_131,kv_str_132,kv_str_133)
bv_str_13  = CREATE_STRUCT(['T0','T1','T2','T3'],bv_str_130,bv_str_131,bv_str_132,bv_str_133)
bm_str_13  = CREATE_STRUCT(['T0','T1','T2','T3'],bm_str_130,bm_str_131,bm_str_132,bm_str_133)
eg_str_13  = CREATE_STRUCT(['T0','T1','T2','T3'],eg_str_130,eg_str_131,eg_str_132,eg_str_133)
;
; => For  3 Hz < f < 30 Hz  at  1998-09-25/00:28:42.305 UT
;
tr_str_140 = 0
kv_str_140 = 0
bv_str_140 = 0
bm_str_140 = 0
eg_str_140 = 0
;
; => For  10 Hz < f < 50 Hz  at  1998-09-25/00:28:42.305 UT
;
tr_str_141 = 0
kv_str_141 = 0
bv_str_141 = 0
bm_str_141 = 0
eg_str_141 = 0
;
; => For  30 Hz < f < 200 Hz  at  1998-09-25/00:28:42.305 UT
;
tr_str_142 = 0
kv_str_142 = 0
bv_str_142 = 0
bm_str_142 = 0
eg_str_142 = 0
tr_str_14  = CREATE_STRUCT(['T0','T1','T2'],tr_str_140,tr_str_141,tr_str_142)
kv_str_14  = CREATE_STRUCT(['T0','T1','T2'],kv_str_140,kv_str_141,kv_str_142)
bv_str_14  = CREATE_STRUCT(['T0','T1','T2'],bv_str_140,bv_str_141,bv_str_142)
bm_str_14  = CREATE_STRUCT(['T0','T1','T2'],bm_str_140,bm_str_141,bm_str_142)
eg_str_14  = CREATE_STRUCT(['T0','T1','T2'],eg_str_140,eg_str_141,eg_str_142)
  ;-----------------------------------------------------------------------------------------
tags      = ['t0','t1','t2','t3','t4','t5','t6','t7','t8','t9','t10','t11','t12','t13','t14']
tr_str    = CREATE_STRUCT(tags,tr_str_0,tr_str_1,tr_str_2,tr_str_3,tr_str_4,tr_str_5,$
                          tr_str_6,tr_str_7,tr_str_8,tr_str_9,tr_str_10,tr_str_11,   $
                          tr_str_12,tr_str_13,tr_str_14)
kv_str    = CREATE_STRUCT(tags,kv_str_0,kv_str_1,kv_str_2,kv_str_3,kv_str_4,kv_str_5,$
                          kv_str_6,kv_str_7,kv_str_8,kv_str_9,kv_str_10,kv_str_11,   $
                          kv_str_12,kv_str_13,kv_str_14)
bv_str    = CREATE_STRUCT(tags,bv_str_0,bv_str_1,bv_str_2,bv_str_3,bv_str_4,bv_str_5,$
                          bv_str_6,bv_str_7,bv_str_8,bv_str_9,bv_str_10,bv_str_11,   $
                          bv_str_12,bv_str_13,bv_str_14)
bm_str    = CREATE_STRUCT(tags,bm_str_0,bm_str_1,bm_str_2,bm_str_3,bm_str_4,bm_str_5,$
                          bm_str_6,bm_str_7,bm_str_8,bm_str_9,bm_str_10,bm_str_11,   $
                          bm_str_12,bm_str_13,bm_str_14)
eg_str    = CREATE_STRUCT(tags,eg_str_0,eg_str_1,eg_str_2,eg_str_3,eg_str_4,eg_str_5,$
                          eg_str_6,eg_str_7,eg_str_8,eg_str_9,eg_str_10,eg_str_11,   $
                          eg_str_12,eg_str_13,eg_str_14)
lfc1  = [3d0,5d0,1d1, 5d1,1d2]   ; => For 1998-09-24/23:20:38.842 UT
hfc1  = [2d1,2d1,45d0,2d2,2d2]   ; => For 1998-09-24/23:20:38.842 UT
lfc2  = [3d0,6d0,15d0, 3d1]      ; => For 1998-09-24/23:22:26.632 UT
hfc2  = [2d1,3d1,15d1,15d1]      ; => For 1998-09-24/23:22:26.632 UT
lfc3  = [3d0,6d0,15d0, 3d1]      ; => For 1998-09-24/23:22:48.150 UT
hfc3  = [2d1,3d1,15d1,15d1]      ; => For 1998-09-24/23:22:48.150 UT
lfc4  = [3d0]                    ; => For 1998-09-24/23:30:00.465 UT
hfc4  = [3d1]                    ; => For 1998-09-24/23:30:00.465 UT
lfc5  = [3d0,1d1,4d1,2d2]        ; => For 1998-09-24/23:30:48.542 UT
hfc5  = [4d1,4d1,1d2,4d2]        ; => For 1998-09-24/23:30:48.542 UT
lfc6  = [3d0]                    ; => For 1998-09-24/23:43:18.951 UT
hfc6  = [3d1]                    ; => For 1998-09-24/23:43:18.951 UT
lfc7  = [3d0,1d1,3d1,1d2]        ; => For 1998-09-24/23:45:52.184 UT
hfc7  = [3d1,1d2,1d2,3d2]        ; => For 1998-09-24/23:45:52.184 UT
lfc8  = [3d0,1d1,15d0,30d0]      ; => For 1998-09-24/23:45:53.379 UT
hfc8  = [3d1,3d1,6d1 ,1d2 ]      ; => For 1998-09-24/23:45:53.379 UT
lfc9  = [3d0,4d0,1d1]            ; => For 1998-09-24/23:48:39.020 UT
hfc9  = [3d1,4d1,4d1]            ; => For 1998-09-24/23:48:39.020 UT
lfc10 = [3d0,5d0,7d0,65d0]       ; => For 1998-09-24/23:48:42.131 UT
hfc10 = [3d1,3d1,3d1,3d2]        ; => For 1998-09-24/23:48:42.131 UT
lfc11 = [3d0,6d0,1d1]            ; => For 1998-09-24/23:48:51.622 UT
hfc11 = [3d1,3d1,1d2]            ; => For 1998-09-24/23:48:51.622 UT
lfc12 = [3d0,5d0,7d0]            ; => For 1998-09-25/00:04:04.545 UT
hfc12 = [3d1,5d1,5d1]            ; => For 1998-09-25/00:04:04.545 UT
lfc13 = [3d0,5d0,4d1]            ; => For 1998-09-25/00:05:23.432 UT
hfc13 = [3d1,5d1,2d2]            ; => For 1998-09-25/00:05:23.432 UT
lfc14 = [3d0,7d0,1d1,2d1]        ; => For 1998-09-25/00:14:50.603 UT
hfc14 = [3d1,5d1,1d2,1d2]        ; => For 1998-09-25/00:14:50.603 UT
lfc15 = [3d0,1d1,3d1]            ; => For 1998-09-25/00:28:42.305 UT
hfc15 = [3d1,5d1,2d2]            ; => For 1998-09-25/00:28:42.305 UT
tags  = ['t1','t2','t3','t4','t5','t6','t7','t8','t9',$
         't10','t11','t12','t13','t14','t15']
lf_str = CREATE_STRUCT(tags,lfc1,lfc2,lfc3,lfc4,lfc5,lfc6,lfc7,lfc8,lfc9,$
                       lfc10,lfc11,lfc12,lfc13,lfc14,lfc15)
hf_str = CREATE_STRUCT(tags,hfc1,hfc2,hfc3,hfc4,hfc5,hfc6,hfc7,hfc8,hfc9,$
                       hfc10,hfc11,hfc12,hfc13,hfc14,hfc15)
no_str = CREATE_STRUCT(tags,16.586,21.087,21.499,24.340,24.016,24.699,20.004,19.946,$
                            24.534,24.764,25.467,22.313,21.804,14.165,15.225)
nvec       = [-0.914,-0.220,-0.341]   ; => Using RH08 from JCK's site
scet_0924  = ['1998/09/24 23:20:38.842',$
              '1998/09/24 23:22:26.632','1998/09/24 23:22:48.150',$
              '1998/09/24 23:30:00.465','1998/09/24 23:30:48.542',$
              '1998/09/24 23:43:18.951','1998/09/24 23:45:52.184',$
              '1998/09/24 23:45:53.379','1998/09/24 23:48:39.020',$
              '1998/09/24 23:48:42.131','1998/09/24 23:48:51.622',$
              '1998/09/25 00:04:04.545','1998/09/25 00:05:23.432',$
              '1998/09/25 00:14:50.603'                           ]+' UT'
scets0     = string_replace_char(STRMID(scet_0924[*],0L,23L),'/','-')
scets1     = string_replace_char(scets0,' ','/')
tr0        = file_name_times(scets1,PREC=3)   
prefx      = tr0.F_TIME
  END
;-----------------------------------------------------------------------------------------
  '021100' : BEGIN
;
; => For  7 Hz < f < 20 Hz  at  2000-02-11/23:33:56.4910
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:33:57.1945',prefd[0]+'23:33:57.3091'])
kvec0   = [ 0.25824, 0.25999,-0.93044]
elam0   = [18.300543,1.5197602]
bvec0   = [ 0.47839,-0.87323, 0.09219]
bmag0   = [16.01923]
tr_str_00 = CREATE_STRUCT(tags[0L:0L],tr0)
kv_str_00 = CREATE_STRUCT(tags[0L:0L],kvec0)
bv_str_00 = CREATE_STRUCT(tags[0L:0L],bvec0)
bm_str_00 = CREATE_STRUCT(tags[0L:0L],bmag0)
eg_str_00 = CREATE_STRUCT(tags[0L:0L],elam0)
;
; => For  5 Hz < f < 30 Hz  at  2000-02-11/23:33:56.4910
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:33:56.7417',prefd[0]+'23:33:56.8809'])
tr1     = time_double([prefd[0]+'23:33:57.3230',prefd[0]+'23:33:57.4574'])
kvec0   = [-0.24222,-0.97005, 0.01833]
kvec1   = [-0.48803, 0.84713,-0.21023]
elam0   = [22.678361,1.9369928]
elam1   = [20.717787,2.1567536]
bvec0   = [ 0.50215,-0.85842, 0.10389]
bvec1   = [ 0.49012,-0.86459, 0.11043]
bmag0   = [15.89010]
bmag1   = [16.36391]
tr_str_01 = CREATE_STRUCT(tags[0L:1L],tr0,tr1)
kv_str_01 = CREATE_STRUCT(tags[0L:1L],kvec0,kvec1)
bv_str_01 = CREATE_STRUCT(tags[0L:1L],bvec0,bvec1)
bm_str_01 = CREATE_STRUCT(tags[0L:1L],bmag0,bmag1)
eg_str_01 = CREATE_STRUCT(tags[0L:1L],elam0,elam1)
;
; => For  60 Hz < f < 200 Hz  at  2000-02-11/23:33:56.4910
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:33:56.9038',prefd[0]+'23:33:56.9438'])
tr1     = time_double([prefd[0]+'23:33:56.9838',prefd[0]+'23:33:57.0238'])
tr2     = time_double([prefd[0]+'23:33:57.0979',prefd[0]+'23:33:57.1267'])
tr3     = time_double([prefd[0]+'23:33:57.1582',prefd[0]+'23:33:57.1886'])
tr4     = time_double([prefd[0]+'23:33:57.3267',prefd[0]+'23:33:57.3598'])
kvec0   = [-0.93012,-0.31953, 0.18107]
kvec1   = [-0.05634, 0.03255,-0.99788]
kvec2   = [ 0.79120,-0.61141,-0.01346]
kvec3   = [ 0.52006,-0.82175, 0.23295]
kvec4   = [ 0.74656,-0.60278, 0.28161]
elam0   = [20.958997,1.2709385]
elam1   = [23.848992,3.4184175]
elam2   = [22.530403,1.9510260]
elam3   = [30.835012,1.9016011]
elam4   = [12.407574,3.0307718]
bvec0   = [ 0.48246,-0.87155, 0.08731]
bvec1   = [ 0.50117,-0.85965, 0.09906]
bvec2   = [ 0.49845,-0.86243, 0.08810]
bvec3   = [ 0.49350,-0.86575, 0.08321]
bvec4   = [ 0.48063,-0.87036, 0.10700]
bmag0   = [15.00932]
bmag1   = [15.01967]
bmag2   = [14.34922]
bmag3   = [13.98559]
bmag4   = [17.17220]
tr_str_02  = CREATE_STRUCT(tags[0L:4L],tr0,tr1,tr2,tr3,tr4)
kv_str_02  = CREATE_STRUCT(tags[0L:4L],kvec0,kvec1,kvec2,kvec3,kvec4)
bv_str_02  = CREATE_STRUCT(tags[0L:4L],bvec0,bvec1,bvec2,bvec3,bvec4)
bm_str_02  = CREATE_STRUCT(tags[0L:4L],bmag0,bmag1,bmag2,bmag3,bmag4)
eg_str_02  = CREATE_STRUCT(tags[0L:4L],elam0,elam1,elam2,elam3,elam4)
;
; => For  120 Hz < f < 200 Hz  at  2000-02-11/23:33:56.4910
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:33:57.0542',prefd[0]+'23:33:57.0755'])
tr1     = time_double([prefd[0]+'23:33:57.1529',prefd[0]+'23:33:57.1715'])
tr2     = time_double([prefd[0]+'23:33:57.2073',prefd[0]+'23:33:57.2345'])
tr3     = time_double([prefd[0]+'23:33:57.2563',prefd[0]+'23:33:57.2713'])
tr4     = time_double([prefd[0]+'23:33:57.3438',prefd[0]+'23:33:57.3662'])
kvec0   = [ 0.60726,-0.79446,-0.00831]
kvec1   = [ 0.46846,-0.66102, 0.58618]
kvec2   = [ 0.38544,-0.90111,-0.19859]
kvec3   = [ 0.41348,-0.90874,-0.05678]
kvec4   = [ 0.73419,-0.59849, 0.32058]
elam0   = [11.860285,3.9235154]
elam1   = [22.780190,2.3577605]
elam2   = [42.398469,2.2102617]
elam3   = [64.419407,2.9166148]
elam4   = [54.159185,2.9471408]
bvec0   = [ 0.50294,-0.85896, 0.09608]
bvec1   = [ 0.49439,-0.86517, 0.08400]
bvec2   = [ 0.48648,-0.86958, 0.08456]
bvec3   = [ 0.47552,-0.87460, 0.09458]
bvec4   = [ 0.48426,-0.86814, 0.10871]
bmag0   = [14.71856]
bmag1   = [14.04857]
bmag2   = [14.47077]
bmag3   = [16.61083]
bmag4   = [16.84065]
tr_str_03  = CREATE_STRUCT(tags[0L:4L],tr0,tr1,tr2,tr3,tr4)
kv_str_03  = CREATE_STRUCT(tags[0L:4L],kvec0,kvec1,kvec2,kvec3,kvec4)
bv_str_03  = CREATE_STRUCT(tags[0L:4L],bvec0,bvec1,bvec2,bvec3,bvec4)
bm_str_03  = CREATE_STRUCT(tags[0L:4L],bmag0,bmag1,bmag2,bmag3,bmag4)
eg_str_03  = CREATE_STRUCT(tags[0L:4L],elam0,elam1,elam2,elam3,elam4)
tr_str_0  = CREATE_STRUCT(['T0','T1','T2','T3'],tr_str_00,tr_str_01,tr_str_02,tr_str_03)
kv_str_0  = CREATE_STRUCT(['T0','T1','T2','T3'],kv_str_00,kv_str_01,kv_str_02,kv_str_03)
bv_str_0  = CREATE_STRUCT(['T0','T1','T2','T3'],bv_str_00,bv_str_01,bv_str_02,bv_str_03)
bm_str_0  = CREATE_STRUCT(['T0','T1','T2','T3'],bm_str_00,bm_str_01,bm_str_02,bm_str_03)
eg_str_0  = CREATE_STRUCT(['T0','T1','T2','T3'],eg_str_00,eg_str_01,eg_str_02,eg_str_03)
;
; => For  7 Hz < f < 20 Hz  at  2000-02-11/23:33:58.3510
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:33:58.3510',prefd[0]+'23:33:58.7995'])
tr1     = time_double([prefd[0]+'23:33:59.0454',prefd[0]+'23:33:59.2998'])
kvec0   = [-0.72774,-0.46936, 0.50010]
kvec1   = [-0.67979, 0.59794, 0.42468]
elam0   = [23.480970,1.9075689]
elam1   = [21.317289,1.0233540]
bvec0   = [ 0.49487,-0.86162, 0.11254]
bvec1   = [ 0.48708,-0.86813, 0.09514]
bmag0   = [14.70694]
bmag1   = [15.88742]
tr_str_10 = CREATE_STRUCT(tags[0L:1L],tr0,tr1)
kv_str_10 = CREATE_STRUCT(tags[0L:1L],kvec0,kvec1)
bv_str_10 = CREATE_STRUCT(tags[0L:1L],bvec0,bvec1)
bm_str_10 = CREATE_STRUCT(tags[0L:1L],bmag0,bmag1)
eg_str_10 = CREATE_STRUCT(tags[0L:1L],elam0,elam1)
;
; => For  5 Hz < f < 30 Hz  at  2000-02-11/23:33:58.3510
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:33:58.4870',prefd[0]+'23:33:58.7590'])
kvec0   = [ 0.76785, 0.46050,-0.44536]
elam0   = [32.628216,2.2558137]
bvec0   = [ 0.49510,-0.86154, 0.11205]
bmag0   = [14.22236]
tr_str_11 = CREATE_STRUCT(tags[0L:0L],tr0)
kv_str_11 = CREATE_STRUCT(tags[0L:0L],kvec0)
bv_str_11 = CREATE_STRUCT(tags[0L:0L],bvec0)
bm_str_11 = CREATE_STRUCT(tags[0L:0L],bmag0)
eg_str_11 = CREATE_STRUCT(tags[0L:0L],elam0)
;
; => For  60 Hz < f < 200 Hz  at  2000-02-11/23:33:58.3510
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:33:58.4497',prefd[0]+'23:33:58.4806'])
tr1     = time_double([prefd[0]+'23:33:58.8801',prefd[0]+'23:33:58.9169'])
tr2     = time_double([prefd[0]+'23:33:58.9201',prefd[0]+'23:33:58.9841'])
tr3     = time_double([prefd[0]+'23:33:58.9979',prefd[0]+'23:33:59.0395'])
tr4     = time_double([prefd[0]+'23:33:59.0737',prefd[0]+'23:33:59.1334'])
tr5     = time_double([prefd[0]+'23:33:59.3734',prefd[0]+'23:33:59.4086'])
kvec0   = [ 0.63228,-0.75146, 0.18851]
kvec1   = [ 0.57048,-0.82100,-0.02238]
kvec2   = [ 0.63156,-0.77411, 0.04344]
kvec3   = [ 0.61795,-0.78239, 0.07747]
kvec4   = [ 0.42935,-0.89678, 0.10700]
kvec5   = [ 0.77918,-0.62678, 0.00592]
elam0   = [22.771399,1.6280719]
elam1   = [44.036298,1.8230859]
elam2   = [24.742561,2.0503321]
elam3   = [20.190239,1.8138823]
elam4   = [39.462053,1.9879186]
elam5   = [34.424645,2.4125351]
bvec0   = [ 0.49410,-0.86199, 0.11329]
bvec1   = [ 0.49085,-0.86483, 0.10546]
bvec2   = [ 0.48431,-0.86772, 0.11180]
bvec3   = [ 0.48698,-0.86727, 0.10335]
bvec4   = [ 0.48762,-0.86707, 0.10205]
bvec5   = [ 0.48872,-0.86976, 0.06830]
bmag0   = [15.02517]
bmag1   = [15.85908]
bmag2   = [15.64792]
bmag3   = [15.81611]
bmag4   = [16.21382]
bmag5   = [15.02834]
tr_str_12 = CREATE_STRUCT(tags[0L:5L],tr0,tr1,tr2,tr3,tr4,tr5)
kv_str_12 = CREATE_STRUCT(tags[0L:5L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5)
bv_str_12 = CREATE_STRUCT(tags[0L:5L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5)
bm_str_12 = CREATE_STRUCT(tags[0L:5L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5)
eg_str_12 = CREATE_STRUCT(tags[0L:5L],elam0,elam1,elam2,elam3,elam4,elam5)
;
; => For  120 Hz < f < 200 Hz  at  2000-02-11/23:33:58.3510
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:33:58.4038',prefd[0]+'23:33:58.5046'])
tr1     = time_double([prefd[0]+'23:33:58.8374',prefd[0]+'23:33:58.9051'])
tr2     = time_double([prefd[0]+'23:33:58.9051',prefd[0]+'23:33:58.9542'])
tr3     = time_double([prefd[0]+'23:33:58.9665',prefd[0]+'23:33:58.9862'])
tr4     = time_double([prefd[0]+'23:33:58.9953',prefd[0]+'23:33:59.0299'])
tr5     = time_double([prefd[0]+'23:33:59.0721',prefd[0]+'23:33:59.1889'])
kvec0   = [-0.29655, 0.80886,-0.50775]
kvec1   = [ 0.86545,-0.49705, 0.06280]
kvec2   = [ 0.76346,-0.64276, 0.06318]
kvec3   = [ 0.74219,-0.66109, 0.11006]
kvec4   = [ 0.76159,-0.61944, 0.19046]
kvec5   = [ 0.37032,-0.92083, 0.12220]
elam0   = [20.761596,1.3629859]
elam1   = [281.90511,2.2548164]
elam2   = [44.230854,2.7014728]
elam3   = [26.978841,2.6210763]
elam4   = [38.892673,2.5036579]
elam5   = [103.67217,2.3045400]
bvec0   = [ 0.49370,-0.86212, 0.11402]
bvec1   = [ 0.49419,-0.86332, 0.10223]
bvec2   = [ 0.48627,-0.86681, 0.11036]
bvec3   = [ 0.48393,-0.86807, 0.11075]
bvec4   = [ 0.48656,-0.86739, 0.10438]
bvec5   = [ 0.48729,-0.86734, 0.10129]
bmag0   = [15.17707]
bmag1   = [15.91070]
bmag2   = [15.70396]
bmag3   = [15.65546]
bmag4   = [15.79353]
bmag5   = [16.20729]
tr_str_13 = CREATE_STRUCT(tags[0L:5L],tr0,tr1,tr2,tr3,tr4,tr5)
kv_str_13 = CREATE_STRUCT(tags[0L:5L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5)
bv_str_13 = CREATE_STRUCT(tags[0L:5L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5)
bm_str_13 = CREATE_STRUCT(tags[0L:5L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5)
eg_str_13 = CREATE_STRUCT(tags[0L:5L],elam0,elam1,elam2,elam3,elam4,elam5)
tr_str_1  = CREATE_STRUCT(['T0','T1','T2','T3'],tr_str_10,tr_str_11,tr_str_12,tr_str_13)
kv_str_1  = CREATE_STRUCT(['T0','T1','T2','T3'],kv_str_10,kv_str_11,kv_str_12,kv_str_13)
bv_str_1  = CREATE_STRUCT(['T0','T1','T2','T3'],bv_str_10,bv_str_11,bv_str_12,bv_str_13)
bm_str_1  = CREATE_STRUCT(['T0','T1','T2','T3'],bm_str_10,bm_str_11,bm_str_12,bm_str_13)
eg_str_1  = CREATE_STRUCT(['T0','T1','T2','T3'],eg_str_10,eg_str_11,eg_str_12,eg_str_13)
;
; => For  3 Hz < f < 20 Hz  at  2000-02-11/23:34:00.731 UT
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:34:01.5369',prefd[0]+'23:34:01.7321'])
kvec0   = [ 0.54918,-0.06113, 0.83347]
elam0   = [15.080181,1.9596324]
bvec0   = [ 0.48760,-0.87141, 0.05363]
bmag0   = [16.05295]
tr_str_20  = CREATE_STRUCT(tags[0L:0L],tr0)
kv_str_20  = CREATE_STRUCT(tags[0L:0L],kvec0)
bv_str_20  = CREATE_STRUCT(tags[0L:0L],bvec0)
bm_str_20  = CREATE_STRUCT(tags[0L:0L],bmag0)
eg_str_20  = CREATE_STRUCT(tags[0L:0L],elam0)
;
; => For  3 Hz < f < 30 Hz  at  2000-02-11/23:34:00.731 UT
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:34:00.8238',prefd[0]+'23:34:00.8990'])
kvec0   = [ 0.33514,-0.90311,-0.26847]
elam0   = [12.069603,1.9974408]
bvec0   = [ 0.49938,-0.86576, 0.03284]
bmag0   = [15.01168]
tr_str_21  = CREATE_STRUCT(tags[0L:0L],tr0)
kv_str_21  = CREATE_STRUCT(tags[0L:0L],kvec0)
bv_str_21  = CREATE_STRUCT(tags[0L:0L],bvec0)
bm_str_21  = CREATE_STRUCT(tags[0L:0L],bmag0)
eg_str_21  = CREATE_STRUCT(tags[0L:0L],elam0)
;
; => For  30 Hz < f < 200 Hz  at  2000-02-11/23:34:00.731 UT
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:34:00.7918',prefd[0]+'23:34:00.8126'])
tr1     = time_double([prefd[0]+'23:34:00.8595',prefd[0]+'23:34:00.8942'])
tr2     = time_double([prefd[0]+'23:34:01.0473',prefd[0]+'23:34:01.0761'])
tr3     = time_double([prefd[0]+'23:34:01.0915',prefd[0]+'23:34:01.1118'])
tr4     = time_double([prefd[0]+'23:34:01.1305',prefd[0]+'23:34:01.1561'])
tr5     = time_double([prefd[0]+'23:34:01.1790',prefd[0]+'23:34:01.2057'])
tr6     = time_double([prefd[0]+'23:34:01.2398',prefd[0]+'23:34:01.2627'])
tr7     = time_double([prefd[0]+'23:34:01.2723',prefd[0]+'23:34:01.3022'])
tr8     = time_double([prefd[0]+'23:34:01.3267',prefd[0]+'23:34:01.3998'])
tr9     = time_double([prefd[0]+'23:34:01.4990',prefd[0]+'23:34:01.5422'])
tr10    = time_double([prefd[0]+'23:34:01.6494',prefd[0]+'23:34:01.6974'])
tr11    = time_double([prefd[0]+'23:34:01.7219',prefd[0]+'23:34:01.7449'])
tr12    = time_double([prefd[0]+'23:34:01.7550',prefd[0]+'23:34:01.7838'])
tr13    = time_double([prefd[0]+'23:34:01.7881',prefd[0]+'23:34:01.8179'])
kvec0   = [-0.70834, 0.61539,-0.34575]
kvec1   = [ 0.11876,-0.97744, 0.17468]
kvec2   = [ 0.46183,-0.87804, 0.12556]
kvec3   = [ 0.90899,-0.40131, 0.11263]
kvec4   = [-0.77296, 0.58990,-0.23357]
kvec5   = [ 0.76557,-0.64197, 0.04222]
kvec6   = [ 0.72589,-0.68247, 0.08560]
kvec7   = [ 0.62306,-0.77973, 0.06172]
kvec8   = [ 0.32217,-0.94657,-0.01432]
kvec9   = [ 0.39724,-0.91761, 0.01399]
kvec10  = [ 0.80866,-0.58632,-0.04783]
kvec11  = [ 0.75081,-0.65524, 0.08334]
kvec12  = [ 0.65239,-0.75258, 0.08950]
kvec13  = [ 0.63026,-0.77478, 0.04997]
elam0   = [22.600782,1.7488921]
elam1   = [19.744919,2.4429481]
elam2   = [16.592032,1.8967459]
elam3   = [125.55275,1.6937316]
elam4   = [12.162099,1.5284284]
elam5   = [54.453218,1.8698458]
elam6   = [36.250598,1.6938960]
elam7   = [63.370075,1.7081549]
elam8   = [36.176798,1.3240004]
elam9   = [19.542167,2.1510341]
elam10  = [57.267304,1.4969081]
elam11  = [37.250279,1.6292370]
elam12  = [34.073367,1.2064880]
elam13  = [50.481153,1.4267496]
bvec0   = [ 0.49803,-0.86629, 0.03887]
bvec1   = [ 0.49972,-0.86562, 0.03114]
bvec2   = [ 0.50366,-0.86324, 0.03364]
bvec3   = [ 0.50177,-0.86442, 0.03166]
bvec4   = [ 0.49915,-0.86600, 0.02999]
bvec5   = [ 0.49817,-0.86669, 0.02617]
bvec6   = [ 0.49860,-0.86660, 0.02009]
bvec7   = [ 0.49755,-0.86714, 0.02270]
bvec8   = [ 0.49435,-0.86882, 0.02778]
bvec9   = [ 0.48732,-0.87194, 0.04732]
bvec10  = [ 0.48825,-0.87093, 0.05568]
bvec11  = [ 0.49074,-0.86919, 0.06073]
bvec12  = [ 0.49233,-0.86823, 0.06160]
bvec13  = [ 0.49348,-0.86752, 0.06242]
bmag0   = [15.08172]
bmag1   = [14.99005]
bmag2   = [15.91296]
bmag3   = [16.14093]
bmag4   = [16.39577]
bmag5   = [16.33807]
bmag6   = [15.98144]
bmag7   = [15.83867]
bmag8   = [15.64186]
bmag9   = [15.82107]
bmag10  = [16.09575]
bmag11  = [16.14354]
bmag12  = [16.29521]
bmag13  = [16.43432]
tr_str_22  = CREATE_STRUCT(tags[0L:13L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,$
                           tr10,tr11,tr12,tr13)
kv_str_22  = CREATE_STRUCT(tags[0L:13L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,kvec9,kvec10,kvec11,kvec12,kvec13)
bv_str_22  = CREATE_STRUCT(tags[0L:13L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,bvec9,bvec10,bvec11,bvec12,bvec13)
bm_str_22  = CREATE_STRUCT(tags[0L:13L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,bmag9,bmag10,bmag11,bmag12,bmag13)
eg_str_22  = CREATE_STRUCT(tags[0L:13L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,elam9,elam10,elam11,elam12,elam13)
tr_str_2  = CREATE_STRUCT(['T0','T1','T2'],tr_str_20,tr_str_21,tr_str_22)
kv_str_2  = CREATE_STRUCT(['T0','T1','T2'],kv_str_20,kv_str_21,kv_str_22)
bv_str_2  = CREATE_STRUCT(['T0','T1','T2'],bv_str_20,bv_str_21,bv_str_22)
bm_str_2  = CREATE_STRUCT(['T0','T1','T2'],bm_str_20,bm_str_21,bm_str_22)
eg_str_2  = CREATE_STRUCT(['T0','T1','T2'],eg_str_20,eg_str_21,eg_str_22)
;
; => For  50 Hz < f < 250 Hz  at  2000-02-11/23:34:27.503 UT
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:34:27.5110',prefd[0]+'23:34:27.5766'])
tr1     = time_double([prefd[0]+'23:34:27.6262',prefd[0]+'23:34:27.6630'])
tr2     = time_double([prefd[0]+'23:34:27.7190',prefd[0]+'23:34:27.7590'])
tr3     = time_double([prefd[0]+'23:34:27.7659',prefd[0]+'23:34:27.7878'])
tr4     = time_double([prefd[0]+'23:34:27.7883',prefd[0]+'23:34:27.8486'])
tr5     = time_double([prefd[0]+'23:34:27.8859',prefd[0]+'23:34:27.9094'])
tr6     = time_double([prefd[0]+'23:34:27.9259',prefd[0]+'23:34:27.9606'])
tr7     = time_double([prefd[0]+'23:34:27.9606',prefd[0]+'23:34:27.9910'])
tr8     = time_double([prefd[0]+'23:34:28.0614',prefd[0]+'23:34:28.0977'])
tr9     = time_double([prefd[0]+'23:34:28.1286',prefd[0]+'23:34:28.1542'])
tr10    = time_double([prefd[0]+'23:34:28.1638',prefd[0]+'23:34:28.1889'])
tr11    = time_double([prefd[0]+'23:34:28.1894',prefd[0]+'23:34:28.2545'])
tr12    = time_double([prefd[0]+'23:34:28.2625',prefd[0]+'23:34:28.2966'])
tr13    = time_double([prefd[0]+'23:34:28.3345',prefd[0]+'23:34:28.3782'])
tr14    = time_double([prefd[0]+'23:34:28.3899',prefd[0]+'23:34:28.4118'])
tr15    = time_double([prefd[0]+'23:34:28.4123',prefd[0]+'23:34:28.4422'])
tr16    = time_double([prefd[0]+'23:34:28.4449',prefd[0]+'23:34:28.4769'])
tr17    = time_double([prefd[0]+'23:34:28.4822',prefd[0]+'23:34:28.5147'])
tr18    = time_double([prefd[0]+'23:34:28.5153',prefd[0]+'23:34:28.5350'])
tr19    = time_double([prefd[0]+'23:34:28.5462',prefd[0]+'23:34:28.5686'])
kvec0   = [ 0.33220,-0.94269, 0.03140]
kvec1   = [ 0.45654,-0.87262,-0.17348]
kvec2   = [ 0.43569,-0.89740, 0.06960]
kvec3   = [ 0.32246,-0.92819,-0.18569]
kvec4   = [ 0.22994,-0.96522,-0.12438]
kvec5   = [ 0.29927,-0.95417,-0.00134]
kvec6   = [ 0.27569,-0.94758,-0.16149]
kvec7   = [ 0.42468,-0.90183,-0.07963]
kvec8   = [ 0.22803,-0.97241, 0.04921]
kvec9   = [ 0.48400,-0.87106,-0.08366]
kvec10  = [ 0.44546,-0.89509,-0.01945]
kvec11  = [ 0.17214,-0.97554,-0.13674]
kvec12  = [ 0.43512,-0.89979,-0.03244]
kvec13  = [ 0.41351,-0.91049,-0.00353]
kvec14  = [ 0.40647,-0.90804, 0.10123]
kvec15  = [ 0.45496,-0.88716, 0.07725]
kvec16  = [ 0.05041,-0.98574,-0.16055]
kvec17  = [ 0.36917,-0.92936, 0.00026]
kvec18  = [ 0.04421,-0.95154,-0.30433]
kvec19  = [ 0.29852,-0.94742,-0.11524]
elam0   = [383.75770,1.9485149]
elam1   = [31.780225,2.1409611]
elam2   = [14.929398,2.2364995]
elam3   = [26.588156,2.4096190]
elam4   = [35.372196,1.9203771]
elam5   = [85.772000,2.0837473]
elam6   = [38.353109,1.8715915]
elam7   = [18.797737,2.6274099]
elam8   = [20.987883,2.0629566]
elam9   = [64.190022,1.8835398]
elam10  = [51.940124,1.7325599]
elam11  = [85.031825,1.7938918]
elam12  = [96.641774,1.7700938]
elam13  = [146.93492,2.1287779]
elam14  = [58.557998,1.7800443]
elam15  = [57.466750,2.0760051]
elam16  = [74.696496,1.8213916]
elam17  = [41.665379,1.8602669]
elam18  = [88.277541,1.8124191]
elam19  = [89.956328,1.4816868]
bvec0   = [ 0.39680,-0.91710,-0.03833]
bvec1   = [ 0.39481,-0.91830,-0.02910]
bvec2   = [ 0.39622,-0.91774,-0.02764]
bvec3   = [ 0.39742,-0.91724,-0.02712]
bvec4   = [ 0.39888,-0.91663,-0.02620]
bvec5   = [ 0.40173,-0.91546,-0.02336]
bvec6   = [ 0.40272,-0.91507,-0.02141]
bvec7   = [ 0.40165,-0.91557,-0.01999]
bvec8   = [ 0.39940,-0.91663,-0.01617]
bvec9   = [ 0.39808,-0.91722,-0.01568]
bvec10  = [ 0.39642,-0.91792,-0.01683]
bvec11  = [ 0.39565,-0.91823,-0.01789]
bvec12  = [ 0.39814,-0.91714,-0.01812]
bvec13  = [ 0.40231,-0.91535,-0.01679]
bvec14  = [ 0.40437,-0.91446,-0.01596]
bvec15  = [ 0.40401,-0.91460,-0.01661]
bvec16  = [ 0.40348,-0.91482,-0.01751]
bvec17  = [ 0.40247,-0.91525,-0.01820]
bvec18  = [ 0.40102,-0.91589,-0.01822]
bvec19  = [ 0.39930,-0.91664,-0.01824]
bmag0   = [22.58476]
bmag1   = [22.49612]
bmag2   = [22.33491]
bmag3   = [22.32055]
bmag4   = [22.33803]
bmag5   = [22.39163]
bmag6   = [22.42861]
bmag7   = [22.45613]
bmag8   = [22.52032]
bmag9   = [22.55793]
bmag10  = [22.59392]
bmag11  = [22.62184]
bmag12  = [22.60983]
bmag13  = [22.59909]
bmag14  = [22.59879]
bmag15  = [22.60821]
bmag16  = [22.62098]
bmag17  = [22.64233]
bmag18  = [22.67037]
bmag19  = [22.70382]
tr_str_30  = CREATE_STRUCT(tags[0L:19L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,$
                           tr10,tr11,tr12,tr13,tr14,tr15,tr16,tr17,tr18,tr19)
kv_str_30  = CREATE_STRUCT(tags[0L:19L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,$
                           kvec9,kvec10,kvec11,kvec12,kvec13,kvec14,kvec15,kvec16,kvec17,$
                           kvec18,kvec19)
bv_str_30  = CREATE_STRUCT(tags[0L:19L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,$
                           bvec9,bvec10,bvec11,bvec12,bvec13,bvec14,bvec15,bvec16,bvec17,$
                           bvec18,bvec19)
bm_str_30  = CREATE_STRUCT(tags[0L:19L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,$
                           bmag9,bmag10,bmag11,bmag12,bmag13,bmag14,bmag15,bmag16,bmag17,$
                           bmag18,bmag19)
eg_str_30  = CREATE_STRUCT(tags[0L:19L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,$
                           elam9,elam10,elam11,elam12,elam13,elam14,elam15,elam16,elam17,$
                           elam18,elam19)
tr_str_3  = CREATE_STRUCT(['T0'],tr_str_30)
kv_str_3  = CREATE_STRUCT(['T0'],kv_str_30)
bv_str_3  = CREATE_STRUCT(['T0'],bv_str_30)
bm_str_3  = CREATE_STRUCT(['T0'],bm_str_30)
eg_str_3  = CREATE_STRUCT(['T0'],eg_str_30)
;
; => For  40 Hz < f < 250 Hz  at  2000-02-11/23:34:29.065 UT
;
prefd   = '2000-02-11/'
tr0     = time_double([prefd[0]+'23:34:29.1530',prefd[0]+'23:34:29.2170'])
tr1     = time_double([prefd[0]+'23:34:29.2170',prefd[0]+'23:34:29.2682'])
tr2     = time_double([prefd[0]+'23:34:29.2682',prefd[0]+'23:34:29.3434'])
tr3     = time_double([prefd[0]+'23:34:29.3637',prefd[0]+'23:34:29.4442'])
tr4     = time_double([prefd[0]+'23:34:29.4634',prefd[0]+'23:34:29.5194'])
tr5     = time_double([prefd[0]+'23:34:29.5402',prefd[0]+'23:34:29.5866'])
tr6     = time_double([prefd[0]+'23:34:29.5973',prefd[0]+'23:34:29.6549'])
tr7     = time_double([prefd[0]+'23:34:29.6554',prefd[0]+'23:34:29.7013'])
tr8     = time_double([prefd[0]+'23:34:29.7445',prefd[0]+'23:34:29.7781'])
tr9     = time_double([prefd[0]+'23:34:29.7962',prefd[0]+'23:34:29.8437'])
tr10    = time_double([prefd[0]+'23:34:29.8490',prefd[0]+'23:34:29.8890'])
tr11    = time_double([prefd[0]+'23:34:29.8890',prefd[0]+'23:34:29.9317'])
tr12    = time_double([prefd[0]+'23:34:29.9610',prefd[0]+'23:34:29.9887'])
tr13    = time_double([prefd[0]+'23:34:30.0250',prefd[0]+'23:34:30.0527'])
tr14    = time_double([prefd[0]+'23:34:30.0666',prefd[0]+'23:34:30.1045'])
tr15    = time_double([prefd[0]+'23:34:30.1103',prefd[0]+'23:34:30.1535'])
kvec0   = [ 0.25646,-0.96585,-0.03706]
kvec1   = [ 0.32790,-0.93987, 0.09558]
kvec2   = [ 0.20398,-0.97896,-0.00621]
kvec3   = [ 0.24202,-0.96944,-0.04009]
kvec4   = [ 0.28675,-0.95617,-0.05921]
kvec5   = [ 0.18981,-0.98114,-0.03655]
kvec6   = [ 0.32919,-0.94306, 0.04765]
kvec7   = [ 0.32692,-0.94460, 0.02923]
kvec8   = [ 0.33162,-0.93816,-0.09946]
kvec9   = [ 0.40251,-0.91086,-0.09127]
kvec10  = [ 0.32735,-0.94211, 0.07266]
kvec11  = [ 0.17978,-0.98198, 0.05825]
kvec12  = [ 0.35121,-0.93619, 0.01420]
kvec13  = [ 0.27969,-0.95770, 0.06774]
kvec14  = [ 0.30919,-0.95065, 0.02569]
kvec15  = [ 0.24364,-0.96776, 0.06385]
elam0   = [50.063278,2.0020758]
elam1   = [111.52470,1.9444146]
elam2   = [44.573428,1.7245797]
elam3   = [50.619485,1.8549344]
elam4   = [29.135429,1.9612188]
elam5   = [132.58086,1.9663781]
elam6   = [73.517730,1.8301229]
elam7   = [116.21488,1.8807890]
elam8   = [32.072602,1.8140486]
elam9   = [16.703635,1.8142964]
elam10  = [73.217856,1.7869554]
elam11  = [17.676595,1.8439619]
elam12  = [32.780140,2.0652437]
elam13  = [25.749164,1.9445251]
elam14  = [82.832377,1.8202052]
elam15  = [76.314016,1.8230944]
bvec0   = [ 0.37139,-0.92835,-0.01530]
bvec1   = [ 0.37165,-0.92830,-0.01083]
bvec2   = [ 0.37608,-0.92658, 0.00026]
bvec3   = [ 0.37882,-0.92541, 0.01055]
bvec4   = [ 0.38282,-0.92358, 0.02122]
bvec5   = [ 0.38775,-0.92118, 0.03275]
bvec6   = [ 0.39034,-0.91972, 0.04182]
bvec7   = [ 0.39116,-0.91907, 0.04793]
bvec8   = [ 0.39259,-0.91834, 0.05027]
bvec9   = [ 0.39369,-0.91774, 0.05258]
bvec10  = [ 0.39466,-0.91721, 0.05444]
bvec11  = [ 0.39555,-0.91687, 0.05367]
bvec12  = [ 0.39720,-0.91622, 0.05275]
bvec13  = [ 0.39961,-0.91507, 0.05436]
bvec14  = [ 0.40177,-0.91419, 0.05321]
bvec15  = [ 0.40405,-0.91331, 0.05117]
bmag0   = [22.73225]
bmag1   = [22.74712]
bmag2   = [22.80674]
bmag3   = [22.85485]
bmag4   = [22.96912]
bmag5   = [23.01516]
bmag6   = [22.98980]
bmag7   = [22.93417]
bmag8   = [22.89778]
bmag9   = [22.92235]
bmag10  = [22.95454]
bmag11  = [22.97751]
bmag12  = [23.00664]
bmag13  = [23.01699]
bmag14  = [23.00386]
bmag15  = [22.98312]
tr_str_40  = CREATE_STRUCT(tags[0L:15L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,$
                           tr10,tr11,tr12,tr13,tr14,tr15)
kv_str_40  = CREATE_STRUCT(tags[0L:15L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,$
                           kvec9,kvec10,kvec11,kvec12,kvec13,kvec14,kvec15)
bv_str_40  = CREATE_STRUCT(tags[0L:15L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,$
                           bvec9,bvec10,bvec11,bvec12,bvec13,bvec14,bvec15)
bm_str_40  = CREATE_STRUCT(tags[0L:15L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,$
                           bmag9,bmag10,bmag11,bmag12,bmag13,bmag14,bmag15)
eg_str_40  = CREATE_STRUCT(tags[0L:15L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,$
                           elam9,elam10,elam11,elam12,elam13,elam14,elam15)
tr_str_4  = CREATE_STRUCT(['T0'],tr_str_40)
kv_str_4  = CREATE_STRUCT(['T0'],kv_str_40)
bv_str_4  = CREATE_STRUCT(['T0'],bv_str_40)
bm_str_4  = CREATE_STRUCT(['T0'],bm_str_40)
eg_str_4  = CREATE_STRUCT(['T0'],eg_str_40)
;
; => For  60 Hz < f < 150 Hz  at  2000-02-12/00:14:21.709 UT
;
prefd   = '2000-02-12/'
tr0     = time_double([prefd[0]+'00:14:21.7090',prefd[0]+'00:14:21.7458'])
tr1     = time_double([prefd[0]+'00:14:21.7618',prefd[0]+'00:14:21.8114'])
tr2     = time_double([prefd[0]+'00:14:21.8231',prefd[0]+'00:14:21.9218'])
tr3     = time_double([prefd[0]+'00:14:21.9218',prefd[0]+'00:14:21.9890'])
tr4     = time_double([prefd[0]+'00:14:21.9890',prefd[0]+'00:14:22.0311'])
tr5     = time_double([prefd[0]+'00:14:22.0450',prefd[0]+'00:14:22.0850'])
tr6     = time_double([prefd[0]+'00:14:22.1175',prefd[0]+'00:14:22.1906'])
tr7     = time_double([prefd[0]+'00:14:22.2786',prefd[0]+'00:14:22.3469'])
tr8     = time_double([prefd[0]+'00:14:22.3474',prefd[0]+'00:14:22.4146'])
tr9     = time_double([prefd[0]+'00:14:22.4151',prefd[0]+'00:14:22.4466'])
tr10    = time_double([prefd[0]+'00:14:22.4594',prefd[0]+'00:14:22.4941'])
tr11    = time_double([prefd[0]+'00:14:22.4946',prefd[0]+'00:14:22.5410'])
tr12    = time_double([prefd[0]+'00:14:22.5538',prefd[0]+'00:14:22.6546'])
tr13    = time_double([prefd[0]+'00:14:22.6631',prefd[0]+'00:14:22.7346'])
kvec0   = [ 0.10187, 0.43505, 0.89462]
kvec1   = [-0.25856,-0.57156,-0.77876]
kvec2   = [-0.05983,-0.56854,-0.82048]
kvec3   = [ 0.21329, 0.46489, 0.85930]
kvec4   = [-0.08805,-0.60891,-0.78833]
kvec5   = [-0.25167,-0.40920,-0.87705]
kvec6   = [-0.13029,-0.69964,-0.70252]
kvec7   = [-0.30807,-0.59580,-0.74170]
kvec8   = [-0.20963,-0.58495,-0.78351]
kvec9   = [-0.29483,-0.57041,-0.76662]
kvec10  = [-0.35694,-0.65196,-0.66899]
kvec11  = [-0.26743,-0.68807,-0.67457]
kvec12  = [-0.34462,-0.66908,-0.65846]
kvec13  = [-0.27741,-0.63913,-0.71733]
elam0   = [269.53718,1.0422235]
elam1   = [44.663497,1.3722606]
elam2   = [95.480294,1.3104090]
elam3   = [119.20714,1.3523514]
elam4   = [308.25739,1.1614168]
elam5   = [56.335323,1.2956218]
elam6   = [93.725799,1.2762985]
elam7   = [260.75304,1.3882296]
elam8   = [215.42307,1.3188908]
elam9   = [25.374810,1.2933339]
elam10  = [68.332710,1.6128089]
elam11  = [60.799266,1.5014990]
elam12  = [57.327302,1.4324975]
elam13  = [630.20445,1.2769111]
bvec0   = [-0.12224,-0.64825,-0.75155]
bvec1   = [-0.12241,-0.64658,-0.75296]
bvec2   = [-0.12379,-0.64289,-0.75589]
bvec3   = [-0.12343,-0.64047,-0.75800]
bvec4   = [-0.12263,-0.64003,-0.75850]
bvec5   = [-0.12179,-0.63960,-0.75900]
bvec6   = [-0.12024,-0.63791,-0.76067]
bvec7   = [-0.11694,-0.63645,-0.76240]
bvec8   = [-0.11547,-0.63607,-0.76294]
bvec9   = [-0.11456,-0.63585,-0.76326]
bvec10  = [-0.11558,-0.63558,-0.76334]
bvec11  = [-0.11608,-0.63540,-0.76341]
bvec12  = [-0.11444,-0.63520,-0.76383]
bvec13  = [-0.11292,-0.63378,-0.76522]
bmag0   = [18.10956]
bmag1   = [18.07622]
bmag2   = [18.08044]
bmag3   = [18.06561]
bmag4   = [18.04972]
bmag5   = [18.03890]
bmag6   = [18.05876]
bmag7   = [18.12547]
bmag8   = [18.13595]
bmag9   = [18.14374]
bmag10  = [18.15516]
bmag11  = [18.16480]
bmag12  = [18.18088]
bmag13  = [18.19254]
tr_str_50  = CREATE_STRUCT(tags[0L:13L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,tr10,tr11,tr12,tr13)
kv_str_50  = CREATE_STRUCT(tags[0L:13L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,kvec9,kvec10,kvec11,kvec12,kvec13)
bv_str_50  = CREATE_STRUCT(tags[0L:13L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,bvec9,bvec10,bvec11,bvec12,bvec13)
bm_str_50  = CREATE_STRUCT(tags[0L:13L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,bmag9,bmag10,bmag11,bmag12,bmag13)
eg_str_50  = CREATE_STRUCT(tags[0L:13L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,elam9,elam10,elam11,elam12,elam13)
tr_str_5  = CREATE_STRUCT(['T0'],tr_str_50)
kv_str_5  = CREATE_STRUCT(['T0'],kv_str_50)
bv_str_5  = CREATE_STRUCT(['T0'],bv_str_50)
bm_str_5  = CREATE_STRUCT(['T0'],bm_str_50)
eg_str_5  = CREATE_STRUCT(['T0'],eg_str_50)
;
; => For  36 Hz < f < 100 Hz  at  2000-02-12/00:26:17.217 UT
;
prefd   = '2000-02-12/'
tr0     = time_double([prefd[0]+'00:26:17.2325',prefd[0]+'00:26:17.2970'])
tr1     = time_double([prefd[0]+'00:26:17.7898',prefd[0]+'00:26:17.8586'])
tr2     = time_double([prefd[0]+'00:26:17.8591',prefd[0]+'00:26:17.9290'])
kvec0   = [ 0.19279,-0.97200,-0.13433]
kvec1   = [ 0.34941,-0.92664,-0.13873]
kvec2   = [-0.25181, 0.95126, 0.17801]
elam0   = [96.128769,1.1319358]
elam1   = [511.51227,1.4964371]
elam2   = [178.53006,1.3377061]
bvec0   = [ 0.42626,-0.90204,-0.06793]
bvec1   = [ 0.43669,-0.89770,-0.05870]
bvec2   = [ 0.43886,-0.89663,-0.05875]
bmag0   = [15.04594]
bmag1   = [15.14061]
bmag2   = [15.12228]
tr_str_60 = CREATE_STRUCT(tags[0L:2L],tr0,tr1,tr2)
kv_str_60 = CREATE_STRUCT(tags[0L:2L],kvec0,kvec1,kvec2)
bv_str_60 = CREATE_STRUCT(tags[0L:2L],bvec0,bvec1,bvec2)
bm_str_60 = CREATE_STRUCT(tags[0L:2L],bmag0,bmag1,bmag2)
eg_str_60 = CREATE_STRUCT(tags[0L:2L],elam0,elam1,elam2)
tr_str_6  = CREATE_STRUCT(['T0'],tr_str_60)
kv_str_6  = CREATE_STRUCT(['T0'],kv_str_60)
bv_str_6  = CREATE_STRUCT(['T0'],bv_str_60)
bm_str_6  = CREATE_STRUCT(['T0'],bm_str_60)
eg_str_6  = CREATE_STRUCT(['T0'],eg_str_60)
;
; => For  30 Hz < f < 100 Hz  at  2000-02-12/00:27:19.142 UT
;
prefd   = '2000-02-12/'
tr0     = time_double([prefd[0]+'00:27:19.1980',prefd[0]+'00:27:19.2524'])
tr1     = time_double([prefd[0]+'00:27:19.2716',prefd[0]+'00:27:19.3452'])
tr2     = time_double([prefd[0]+'00:27:19.4561',prefd[0]+'00:27:19.4972'])
tr3     = time_double([prefd[0]+'00:27:19.5116',prefd[0]+'00:27:19.5671'])
tr4     = time_double([prefd[0]+'00:27:19.5676',prefd[0]+'00:27:19.6348'])
tr5     = time_double([prefd[0]+'00:27:19.7340',prefd[0]+'00:27:19.8513'])
tr6     = time_double([prefd[0]+'00:27:19.8604',prefd[0]+'00:27:19.9276'])
tr7     = time_double([prefd[0]+'00:27:19.9281',prefd[0]+'00:27:20.0156'])
tr8     = time_double([prefd[0]+'00:27:20.0460',prefd[0]+'00:27:20.1164'])
tr9     = time_double([prefd[0]+'00:27:20.1223',prefd[0]+'00:27:20.1596'])
tr10    = time_double([prefd[0]+'00:27:20.1969',prefd[0]+'00:27:20.2337'])
kvec0   = [ 0.45898,-0.88673,-0.05524]
kvec1   = [ 0.36747,-0.92973,-0.02390]
kvec2   = [ 0.50717,-0.86183, 0.00551]
kvec3   = [ 0.52313,-0.84176,-0.13336]
kvec4   = [ 0.40270,-0.90921,-0.10570]
kvec5   = [ 0.46709,-0.88280,-0.04984]
kvec6   = [ 0.38243,-0.92297,-0.04322]
kvec7   = [ 0.37606,-0.92293,-0.08233]
kvec8   = [ 0.46029,-0.88747,-0.02275]
kvec9   = [ 0.43724,-0.89920,-0.01594]
kvec10  = [ 0.36780,-0.92975,-0.01704]
elam0   = [215.67397,1.3824462]
elam1   = [218.11937,1.4130172]
elam2   = [769.25053,1.4416568]
elam3   = [89.469035,1.4648732]
elam4   = [60.978005,1.6127469]
elam5   = [118.84870,1.6363366]
elam6   = [320.26853,1.4897381]
elam7   = [74.011701,1.5091619]
elam8   = [225.48382,1.4897473]
elam9   = [67.240799,1.3189971]
elam10  = [83.110468,1.5730526]
bvec0   = [ 0.43186,-0.90162,-0.02392]
bvec1   = [ 0.43281,-0.90108,-0.02683]
bvec2   = [ 0.43025,-0.90215,-0.03165]
bvec3   = [ 0.43041,-0.90201,-0.03360]
bvec4   = [ 0.43204,-0.90116,-0.03529]
bvec5   = [ 0.42572,-0.90426,-0.03234]
bvec6   = [ 0.42739,-0.90383,-0.02086]
bvec7   = [ 0.42488,-0.90512,-0.01547]
bvec8   = [ 0.42272,-0.90615,-0.01394]
bvec9   = [ 0.42342,-0.90583,-0.01359]
bvec10  = [ 0.42420,-0.90547,-0.01352]
bmag0   = [15.27725]
bmag1   = [15.27566]
bmag2   = [15.27873]
bmag3   = [15.24836]
bmag4   = [15.23861]
bmag5   = [15.40943]
bmag6   = [15.50949]
bmag7   = [15.49808]
bmag8   = [15.46496]
bmag9   = [15.46719]
bmag10  = [15.50073]
tr_str_70  = CREATE_STRUCT(tags[0L:10L],tr0,tr1,tr2,tr3,tr4,tr5,tr6,tr7,tr8,tr9,tr10)
kv_str_70 = CREATE_STRUCT(tags[0L:10L],kvec0,kvec1,kvec2,kvec3,kvec4,kvec5,kvec6,kvec7,kvec8,kvec9,kvec10)
bv_str_70 = CREATE_STRUCT(tags[0L:10L],bvec0,bvec1,bvec2,bvec3,bvec4,bvec5,bvec6,bvec7,bvec8,bvec9,bvec10)
bm_str_70 = CREATE_STRUCT(tags[0L:10L],bmag0,bmag1,bmag2,bmag3,bmag4,bmag5,bmag6,bmag7,bmag8,bmag9,bmag10)
eg_str_70 = CREATE_STRUCT(tags[0L:10L],elam0,elam1,elam2,elam3,elam4,elam5,elam6,elam7,elam8,elam9,elam10)
tr_str_7  = CREATE_STRUCT(['T0'],tr_str_70)
kv_str_7  = CREATE_STRUCT(['T0'],kv_str_70)
bv_str_7  = CREATE_STRUCT(['T0'],bv_str_70)
bm_str_7  = CREATE_STRUCT(['T0'],bm_str_70)
eg_str_7  = CREATE_STRUCT(['T0'],eg_str_70)
  ;-----------------------------------------------------------------------------------------
tags      = ['t0','t1','t2','t3','t4','t5','t6','t7']
tr_str    = CREATE_STRUCT(tags,tr_str_0,tr_str_1,tr_str_2,tr_str_3,tr_str_4,tr_str_5,$
                          tr_str_6,tr_str_7)
kv_str    = CREATE_STRUCT(tags,kv_str_0,kv_str_1,kv_str_2,kv_str_3,kv_str_4,kv_str_5,$
                          kv_str_6,kv_str_7)
bv_str    = CREATE_STRUCT(tags,bv_str_0,bv_str_1,bv_str_2,bv_str_3,bv_str_4,bv_str_5,$
                          bv_str_6,bv_str_7)
bm_str    = CREATE_STRUCT(tags,bm_str_0,bm_str_1,bm_str_2,bm_str_3,bm_str_4,bm_str_5,$
                          bm_str_6,bm_str_7)
eg_str    = CREATE_STRUCT(tags,eg_str_0,eg_str_1,eg_str_2,eg_str_3,eg_str_4,eg_str_5,$
                          eg_str_6,eg_str_7)
lfc1  = [7d0,5d0,6d1,12d1]                   ; => For 2000-02-11/23:33:56.491 UT
hfc1  = [2d1,3d1,2d2, 2d2]                   ; => For 2000-02-11/23:33:56.491 UT
lfc2  = [7d0,5d0,6d1,12d1]                   ; => For 2000-02-11/23:33:58.351 UT
hfc2  = [2d1,3d1,2d2, 2d2]                   ; => For 2000-02-11/23:33:58.351 UT
lfc3  = [3d0,3d0,3d1]                        ; => For 2000-02-11/23:34:00.731 UT
hfc3  = [2d1,3d1,2d2]                        ; => For 2000-02-11/23:34:00.731 UT
lfc4  = [5d1]                                ; => For 2000-02-11/23:34:27.503 UT
hfc4  = [25d1]                               ; => For 2000-02-11/23:34:27.503 UT
lfc5  = [4d1]                                ; => For 2000-02-11/23:34:29.065 UT
hfc5  = [25d1]                               ; => For 2000-02-11/23:34:29.065 UT
lfc6  = [6d1]                                ; => For 2000-02-12/00:14:21.709 UT
hfc6  = [15d1]                               ; => For 2000-02-12/00:14:21.709 UT
lfc7  = [36d0]                               ; => For 2000-02-12/00:26:17.217 UT
hfc7  = [10d1]                               ; => For 2000-02-12/00:26:17.217 UT
lfc8  = [30d0]                               ; => For 2000-02-12/00:27:19.142 UT
hfc8  = [10d1]                               ; => For 2000-02-12/00:27:19.142 UT
tags  = ['t1','t2','t3','t4','t5','t6','t7','t8']
lf_str = CREATE_STRUCT(tags,lfc1,lfc2,lfc3,lfc4,lfc5,lfc6,lfc7,lfc8)
hf_str = CREATE_STRUCT(tags,hfc1,hfc2,hfc3,hfc4,hfc5,hfc6,hfc7,hfc8)
no_str = CREATE_STRUCT(tags,14.821,15.463,16.053,16.849,16.895,24.601,20.398,19.291)
nvec       = [-0.865,-0.452,0.218]   ; => Using RH08 from JCK's site
scet_0211  = ['2000/02/11 23:33:56.491','2000/02/11 23:33:58.351',$
              '2000/02/11 23:34:00.731','2000/02/11 23:34:27.503',$
              '2000/02/11 23:34:29.065','2000/02/12 00:14:21.709',$
              '2000/02/12 00:26:17.217','2000/02/12 00:27:19.142' ]+' UT'
scets0     = string_replace_char(STRMID(scet_0211[*],0L,23L),'/','-')
scets1     = string_replace_char(scets0,' ','/')
tr0        = file_name_times(scets1,PREC=3)   
prefx      = tr0.F_TIME
  END
;-----------------------------------------------------------------------------------------
  ELSE     : BEGIN
  END
ENDCASE
;=========================================================================================
JUMP_SKIP_CASE:
;=========================================================================================
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (~KEYWORD_SET(ndat) OR N_ELEMENTS(ndat) EQ 0) THEN ndat = 100L ELSE ndat = LONG(ndat)
;anglew    = DINDGEN(ndat)*(2d0*!DPI)/(ndat - 1L) + !DPI/2d0
n_uq      = N_TAGS(tr_str) - 1L
IF (~KEYWORD_SET(prefx) OR N_ELEMENTS(prefx) EQ 0) THEN pref0 = REPLICATE('',n_uq) ELSE pref0 = prefx

xx        = FINDGEN(ndat)/(ndat - 1L)
anglew    = ((DINDGEN(ndat)*(2d0*!DPI)/(ndat - 1L) + !DPI/2d0) # REPLICATE(1d0,4))
FOR j=0L, n_uq DO BEGIN
  jstr       = 'T'+STRTRIM(j,2)
  lfc0       = lf_str.(j)
  hfc0       = hf_str.(j)
  no         = no_str.(j)
  n_fr       = N_ELEMENTS(lfc0) - 1L
  FOR k=0L, n_fr DO BEGIN
    kstr       = 'T'+STRTRIM(k,2)
    tr_0       = tr_str.(j).(k)        ; => time range (unix)
    nnsxx0     = 0d0
    nnsyy0     = 0d0
    nnsxx1     = 0d0
    nnsyy1     = 0d0
    x_vals     = 0d0
    k_line0    = 0d0
    ns0xy      = 0d0
    ns1xy      = 0d0
    kxy0       = 0d0
    kxy1       = 0d0
    theta_kb   = 0d0
    IF (SIZE(tr_0,/TYPE) NE 8L) THEN GOTO,JUMP_FREE
    n_tras     = N_TAGS(tr_0)
    f0         = lfc0[k]
    f1         = hfc0[k]
    nnsxx0     = DBLARR(n_tras,ndat,4L)
    nnsyy0     = DBLARR(n_tras,ndat,4L)
    nnsxx1     = DBLARR(n_tras,ndat,4L)
    nnsyy1     = DBLARR(n_tras,ndat,4L)
    x_vals     = DBLARR(n_tras,ndat)   
    k_line0    = DBLARR(n_tras,ndat)   
    ns0xy      = DBLARR(n_tras,2L,4L)
    ns1xy      = DBLARR(n_tras,2L,4L)
    kxy0       = DBLARR(n_tras,2L,4L)
    kxy1       = DBLARR(n_tras,2L,4L)
    theta_kb   = DBLARR(n_tras,2L)
    FOR p=0L, n_tras - 1L DO BEGIN
      kvec0      = kv_str.(j).(k).(p)
      bvec0      = bv_str.(j).(k).(p)
      bo         = bm_str.(j).(k).(p)
      kvec0      = kvec0/NORM(kvec0) 
      bvec0      = bvec0/NORM(bvec0) 
      thkb       = !DPI/2d0 - ACOS(my_dot_prod(kvec0,bvec0,/NOM))
      kkperp     = COS(thkb[0])      
      kkpara     = SIN(thkb[0])      
      test       = excited_cold_lhw(bo[0],no[0],f0,f1,NDAT=ndat,NVEC=nvec,BVEC=bvec0,KVEC=kvec0)
      nsrf0      = test.NSURF_STIX92.FLOW
      nsrf1      = test.NSURF_STIX92.FHIGH
      xx0        = xx*MAX([ABS(nsrf0),ABS(nsrf1)]*1.1,/NAN)
      kx0        = kkperp[0]
      ky0        = kkpara[0]
      nx00       = REFORM(ABS(nsrf0))*COS(anglew)
      ny00       = REFORM(ABS(nsrf0))*SIN(anglew)
      nx10       = REFORM(ABS(nsrf1))*COS(anglew)
      ny10       = REFORM(ABS(nsrf1))*SIN(anglew)
      slope0     = ky0[0]/kx0[0]
      line00     = slope0[0]*xx
      line0k     = interp(line00,xx,xx0,/NO_EXTRAP)
      kk0        = line0k
      theta_kb[p,*] = [(thkb[0] + !DPI/2d0),!DPI - (thkb[0] + !DPI/2d0)]*18d1/!DPI
      FOR i=0L, 3L DO BEGIN
        nsxx         = REFORM(nx00[*,i])
        nsyy         = REFORM(ny00[*,i])
        result0      = curveint(xx0,kk0,nsxx,nsyy)
        nsxx         = REFORM(nx10[*,i])
        nsyy         = REFORM(ny10[*,i])
        result1      = curveint(xx0,kk0,nsxx,nsyy)
        kxy0[p,*,i]  = result0[*,0]  
        kxy1[p,*,i]  = result1[*,0]  
        ns0xy[p,*,i] = result0[*,1]  
        ns1xy[p,*,i] = result1[*,1]  
      ENDFOR
      k_line0[p,*]  = line0k
      x_vals[p,*]   = xx0   
      nnsxx0[p,*,*] = nx00  
      nnsxx1[p,*,*] = nx10  
      nnsyy0[p,*,*] = ny00  
      nnsyy1[p,*,*] = ny10  
    ENDFOR
    JUMP_FREE:
    str_element,nsurf_0x,kstr,nnsxx0 ,/ADD_REPLACE
    str_element,nsurf_1x,kstr,nnsxx1 ,/ADD_REPLACE
    str_element,nsurf_0y,kstr,nnsyy0 ,/ADD_REPLACE
    str_element,nsurf_1y,kstr,nnsyy1 ,/ADD_REPLACE
    str_element,xvals_0 ,kstr,x_vals ,/ADD_REPLACE
    str_element,kline_0 ,kstr,k_line0,/ADD_REPLACE
    str_element,ns_0xy  ,kstr,ns0xy  ,/ADD_REPLACE
    str_element,ns_1xy  ,kstr,ns1xy  ,/ADD_REPLACE
    str_element,kxy_0   ,kstr,kxy0   ,/ADD_REPLACE
    str_element,kxy_1   ,kstr,kxy1   ,/ADD_REPLACE
    str_element,th_kb0  ,kstr,theta_kb,/ADD_REPLACE
  ENDFOR
  str_element,nsurf_lx,jstr,nsurf_0x,/ADD_REPLACE
  str_element,nsurf_hx,jstr,nsurf_1x,/ADD_REPLACE
  str_element,nsurf_ly,jstr,nsurf_0y,/ADD_REPLACE
  str_element,nsurf_hy,jstr,nsurf_1y,/ADD_REPLACE
  str_element,xvals_s ,jstr,xvals_0 ,/ADD_REPLACE
  str_element,kline_s ,jstr,kline_0 ,/ADD_REPLACE
  str_element,ns_xyl  ,jstr,ns_0xy  ,/ADD_REPLACE
  str_element,ns_xyh  ,jstr,ns_1xy  ,/ADD_REPLACE
  str_element,kxy_ls  ,jstr,kxy_0   ,/ADD_REPLACE
  str_element,kxy_hs  ,jstr,kxy_1   ,/ADD_REPLACE
  str_element,the_kb  ,jstr,th_kb0  ,/ADD_REPLACE
  ; => Redefine structures to avoid issues with tag names
  nsurf_0x = 0
  nsurf_1x = 0
  nsurf_0y = 0
  nsurf_1y = 0
  xvals_0  = 0
  kline_0  = 0
  ns_0xy   = 0
  ns_1xy   = 0
  kxy_0    = 0
  kxy_1    = 0
  th_kb0   = 0
ENDFOR
;-----------------------------------------------------------------------------------------
; => Plot intercept of N-surface and k-vector
;-----------------------------------------------------------------------------------------
yttl         = 'Blue = Low Freq., Red = High Frez.'
base_str     = {NODATA:1,XSTYLE:1,YSTYLE:1,XMINOR:10,YMINOR:10,YTITLE:yttl}
xxpref       = 'V!Dph,!9x!3'+'!N = '
yypref       = 'V!Dph,!9#!3'+'!N = '
vvsuff       = ' (km/s)'


FOR j=0L, n_uq DO BEGIN
  jstr       = 'T'+STRTRIM(j,2)
  lfc0       = lf_str.(j)
  hfc0       = hf_str.(j)
  fwl_str    = STRTRIM(STRING(FORMAT='(f15.1)',lfc0),2)
  fwh_str    = STRTRIM(STRING(FORMAT='(f15.1)',hfc0),2)
  fil_strl   = fwl_str[*]+'Hz_'
  fil_strh   = fwh_str[*]+'Hz_'
  fil_str    = fwl_str[*]+'-'+fwh_str[*]+'Hz_'
  fil_stl    = STRARR(N_ELEMENTS(fil_strl))
  fil_sth    = STRARR(N_ELEMENTS(fil_strh))
  fil_st2    = STRARR(N_ELEMENTS(fil_str))
  n_fr       = N_ELEMENTS(lfc0) - 1L
  FOR m=0L, n_fr DO fil_st2[m] = STRMID(fil_str[m],0L,STRLEN(fil_str[m])-1L)
  FOR k=0L, n_fr DO BEGIN
    kstr       = 'T'+STRTRIM(k,2)
    tr_0       = tr_str.(j).(k)        ; => time range (unix)
    IF (SIZE(tr_0,/TYPE) NE 8L) THEN GOTO,JUMP_SKIP
    n_tras     = N_TAGS(tr_0)
    th_kb0     = the_kb.(j).(k)
    FOR p=0L, n_tras - 1L DO BEGIN
      tr0      = file_name_times(tr_0.(p),PREC=4)
      sfname   = tr0.F_TIME[0]+'_'+tr0.F_TIME[1]
      ttname   = tr0.UT_TIME[0]+'-'+tr0.UT_TIME[1]
      xx0      = REFORM(xvals_s.(j).(k)[p,*])
      kk0      = REFORM(kline_s.(j).(k)[p,*])
      slopek   = (kk0[10] - kk0[5])/(xx0[10] - xx0[5])
      slopest  = 'K-Vector Slope = '+STRTRIM(STRING(FORMAT='(f15.7)',slopek[0]),2)
      thetakb  = REFORM(th_kb0[p,*])
      thetast  = STRTRIM(STRING(FORMAT='(f15.3)',thetakb),2)
      thetastr = '!7h!3'+'!DkB!N = '+thetast[0]+'!Uo!N'+', '+thetast[1]+'!Uo!N'
      FOR i=0L, 3L DO BEGIN
        istr    = 'N!D'+STRTRIM(i,2)+'!N'+'-Surface' 
        ifstr   = 'N'+STRTRIM(i,2)+'-Surface'        
        ttle    = istr[0]+' For '+ttname[0]          
        xttle   = istr[0]+' For'+' Freq: '+fil_st2[k]
        pname   = ifstr[0]+'_'+pref0[j]+'_'+sfname[0]+'_'+fil_str[k]
        nsxxl   = REFORM(nsurf_lx.(j).(k)[p,*,i])
        nsyyl   = REFORM(nsurf_ly.(j).(k)[p,*,i])
        nsxxh   = REFORM(nsurf_hx.(j).(k)[p,*,i])
        nsyyh   = REFORM(nsurf_hy.(j).(k)[p,*,i])
        xyil    = REFORM(ns_xyl.(j).(k)[p,*,i])
        xyih    = REFORM(ns_xyh.(j).(k)[p,*,i])
        maxxy   = MAX(ABS([nsxxl,nsyyl,nsxxh,nsyyh]),/NAN)
        xyra    = 1.1*[-1*maxxy,maxxy]
        xyoutxl = STRTRIM(STRING(FORMAT='(f15.3)',xyil[0]*c*1d-3),2)  ; => convert to km/s
        xyoutyl = STRTRIM(STRING(FORMAT='(f15.3)',xyil[1]*c*1d-3),2)  ; => convert to km/s
        xyoutxh = STRTRIM(STRING(FORMAT='(f15.3)',xyih[0]*c*1d-3),2)  ; => convert to km/s
        xyoutyh = STRTRIM(STRING(FORMAT='(f15.3)',xyih[1]*c*1d-3),2)  ; => convert to km/s
        pstr    = base_str
        str_element,pstr,'YRANGE',xyra ,/ADD_REPLACE
        str_element,pstr,'XRANGE',xyra ,/ADD_REPLACE
        str_element,pstr,'TITLE' ,ttle ,/ADD_REPLACE
        str_element,pstr,'XTITLE',xttle,/ADD_REPLACE
        popen,pname,/PORT
          PLOT,nsxxl,nsyyl,_EXTRA=pstr
            OPLOT,nsxxl,nsyyl,COLOR= 50L
            OPLOT,nsxxh,nsyyh,COLOR=250L
            OPLOT,xx0,kk0,COLOR=200L
            OPLOT,[xyil[0],xyil[0]],[xyil[1],xyil[1]],COLOR= 50L,PSYM=2
            XYOUTS,.15,.95,/NORMAL,xxpref[0]+xyoutxl[0]+vvsuff[0],COLOR= 50L
            XYOUTS,.15,.90,/NORMAL,yypref[0]+xyoutyl[0]+vvsuff[0],COLOR= 50L
            OPLOT,[xyih[0],xyih[0]],[xyih[1],xyih[1]],COLOR=250L,PSYM=2
            XYOUTS,.15,.85,/NORMAL,xxpref[0]+xyoutxh[0]+vvsuff[0],COLOR=250L
            XYOUTS,.15,.80,/NORMAL,yypref[0]+xyoutyh[0]+vvsuff[0],COLOR=250L
            XYOUTS,.15,.20,thetastr,/NORMAL,COLOR=200L
            XYOUTS,.15,.15,slopest,/NORMAL,COLOR=200L
            XYOUTS,.75,.95,'x = '+STRTRIM(STRING(FORMAT='(f15.7)',xyil[0]),2),/NORMAL,COLOR= 50L
            XYOUTS,.75,.90,'y = '+STRTRIM(STRING(FORMAT='(f15.7)',xyil[1]),2),/NORMAL,COLOR= 50L
            XYOUTS,.75,.85,'x = '+STRTRIM(STRING(FORMAT='(f15.7)',xyih[0]),2),/NORMAL,COLOR=250L
            XYOUTS,.75,.80,'y = '+STRTRIM(STRING(FORMAT='(f15.7)',xyih[1]),2),/NORMAL,COLOR=250L
        pclose
      ENDFOR
    ENDFOR
    JUMP_SKIP:
  ENDFOR
ENDFOR
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
IF NOT KEYWORD_SET(nom) THEN BEGIN
  MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
ENDIF
;*****************************************************************************************
RETURN,1
END