;+
;*****************************************************************************************
;
;  PROCEDURE:   write_shocks_jck_database.pro
;  PURPOSE  :   Creates a formatted ASCII file of containing all the relevant data from
;                 the data base created by Justin C. Kasper at 
;                 http://www.cfa.harvard.edu/shocks/wi_data/
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               read_html_jck_database.pro
;               time_double.pro
;               time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII files of source code (see read_html_jck_database.pro)
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               write_shocks_jck_database
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed dates so they have the format of YYYY-MM-DD
;                                                                   [04/06/2009   v1.0.1]
;             2)  Initially forgot Wind location
;                                                                   [04/07/2009   v1.0.2]
;             3)  Added notes to explain the definition of vars.
;                                                                   [04/07/2009   v1.0.3]
;             4)  Changed HTML file locations, thus the search syntax changed
;                   and changed program my_jck_database_read_write.pro
;                   to read_write_jck_database.pro and renamed from
;                   my_all_shocks_write.pro to write_shocks_jck_database.pro
;                                                                   [09/16/2009   v2.0.0]
;             5)  Changed output format
;                                                                   [11/16/2010   v2.1.0]
;             6)  Cleaned up and changed location of HTML files
;                   and now calls read_html_jck_database.pro instead of
;                   read_write_jck_database.pro
;                   and now calls time_double.pro and time_string.pro instead of
;                   my_time_string.pro
;                                                                   [09/20/2013   v2.2.0]
;
;   NOTES:      
;               1)  Initialize the IDL directories with start_umn_3dp.pro prior
;                     to use.
;               2)  Methods Used by J.C. Kasper:
;                     MC   :  Magnetic Coplanarity    (Viñas and Scudder, [1986])
;                     VC   :  Velocity Coplanarity    (Viñas and Scudder, [1986])
;                     MX1  :  Mixed Mode Normal 1     (Russell et. al., [1983])
;                     MX2  :  Mixed Mode Normal 2     (Russell et. al., [1983])
;                     MX3  :  Mixed Mode Normal 3     (Russell et. al., [1983])
;                     RH08 :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])
;                     RH09 :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])
;                     RH10 :  Rankine-Hugoniot 10 Eqs (Viñas and Scudder, [1986])
;
;                     Shock Speed         :  Shock velocity dotted into the normal vector
;                                           [ = |Vsh \dot norm| ]
;                     Flow Speed          :  |Vsw \dot norm| - |Vsh \dot norm|
;                                           (= dV on JCK's site)
;                     Compression Ratio   :  Downstream density over Upstream density
;                     Shock Normal Angle  :  Theta_Bn = ArcCos( (B \dot norm)/|B|)
;               3)  Removed '*****' by hand from 2002-09-25 file
;               4)  Changed method for 2002-09-07 to RH08
;
;  REFERENCES:  
;               1)  Viñas, A.F. and J.D. Scudder (1986), "Fast and Optimal Solution to
;                      the 'Rankine-Hugoniot Problem'," J. Geophys. Res. 91, pp. 39-58.
;               2)  A. Szabo (1994), "An improved solution to the 'Rankine-Hugoniot'
;                      problem," J. Geophys. Res. 99, pp. 14,737-14,746.
;               3)  Koval, A. and A. Szabo (2008), "Modified 'Rankine-Hugoniot' shock
;                      fitting technique:  Simultaneous solution for shock normal and
;                      speed," J. Geophys. Res. 113, pp. A10110.
;               4)  Russell, C.T., J.T. Gosling, R.D. Zwickl, and E.J. Smith (1983),
;                      "Multiple spacecraft observations of interplanetary shocks:  ISEE
;                      Three-Dimensional Plasma Measurements," J. Geophys. Res. 88,
;                      pp. 9941-9947.
;
;   CREATED:  04/04/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/20/2013   v2.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO write_shocks_jck_database

;;****************************************************************************************
ex_start = SYSTIME(1)
;;****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Define dummy and constant variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()         ;;  '/' for Unix, '\' for Windows
def_path       = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'wind_data_dir'+slash[0]
def_path       = def_path[0]+'JCK_Data-Base'+slash[0]
def_file       = 'All_JCKaspers_Shock_Parameters.txt'
;;----------------------------------------------------------------------------------------
;;  Read in all shock information
;;----------------------------------------------------------------------------------------
read_html_jck_database,ALL_STR=allstr

mheader        = allstr.HEADER_STR      ;;  Structure with all Header info
msolar         = allstr.SOLAR_WIND_STR  ;;  Structure with all solar wind info
mshock         = allstr.SHOCK_STR       ;;  Shock specific info like Mach number etc.
;;----------------------------------------------------------------------------------------
;;  Convert arrival times to useful formats
;;----------------------------------------------------------------------------------------
udate          = ''                        ;;  e.g., '1995-01-01'
sod_t0         = mheader.TIMES             ;;  seconds of day
dates          = mheader.DATES             ;;  e.g., '01/01/1995'
udate          = STRMID(dates,6L,4L)+'-'+STRMID(dates,0L,2L)+'-'+STRMID(dates,3L,2L)
;;  Define times at start of date
ymdb_t0        = udate+'/00:00:00.000'     ;;  e.g., '1995-01-01/00:00:00.000'
;;  Convert to Unix times
unix_t0        = time_double(ymdb_t0)
;;  Add on seconds of day to Unix times
unix           = unix_t0 + sod_t0
;;  Define time strings
ymdb           = time_string(unix,PREC=4)  ;;  'YYYY-MM-DD/HH:MM:SS.ssss'
;mts            = my_time_string(mheader.TIMES,SECONDS=1)
;utc            = mts.TIME_C              ;;  Seconds of day to 'HH:MM:SS.ssss'
;ymdb           = udate+'/'+utc           ;;  'YYYY-MM-DD/HH:MM:SS.ssss'
;mts            = my_time_string(ymdb,STR=1,FORM=1)
;unix           = mts.UNIX                ;;  Unix times of shock arrivals at Wind
;;----------------------------------------------------------------------------------------
;;  Sort event info
;;----------------------------------------------------------------------------------------
sp             = SORT(unix)
ns             = N_ELEMENTS(sp)
unix           = unix[sp]
ymdb           = ymdb[sp]
ymdb           = STRMID(ymdb,0L,23L)
;;----------------------------------------------------------------------------------------
;;  Define useful parameters
;;----------------------------------------------------------------------------------------
wloc           = mheader.WIND_LOCATION[sp,*]    ;; Wind satellite location (Re)
methd          = mheader.METHODS[sp]            ;; Analysis method used
gmeth          = WHERE(STRPOS(methd,'RH') GE 0,gmt,COMPLEMENT=bmeth,NCOMPLEMENT=bmt)
IF (bmt GT 0L) THEN methd[bmeth] = STRMID(methd[bmeth],0L,3L)
;;  Remove any trailing 

;;  Solar Wind Parameters
vswu           = REFORM(msolar.VSW[sp,*,0])     ;; Upstream Solar Wind velocity (km/s)
dvswu          = REFORM(msolar.D_VSW[sp,*,0])   ;;  Uncertainty
vswd           = REFORM(msolar.VSW[sp,*,1])     ;; Downstream Solar Wind velocity (km/s)
dvswd          = REFORM(msolar.D_VSW[sp,*,1])   ;;  Uncertainty
magfu          = REFORM(msolar.MAGF[sp,*,0])    ;; Upstream Solar Wind B-field (nT)
dmagfu         = REFORM(msolar.D_MAGF[sp,*,0])  ;;  Uncertainty
magfd          = REFORM(msolar.MAGF[sp,*,1])    ;; Downstream Solar Wind B-field (nT)
dmagfd         = REFORM(msolar.D_MAGF[sp,*,1])  ;;  Uncertainty
densu          = REFORM(msolar.DENS[sp,0])      ;; Upstream Solar Wind density (cm^-3)
ddensu         = REFORM(msolar.D_DENS[sp,0])    ;;  Uncertainty
densd          = REFORM(msolar.DENS[sp,1])      ;; Downstream Solar Wind density (cm^-3)
ddensd         = REFORM(msolar.D_DENS[sp,1])    ;;  Uncertainty
betau          = REFORM(msolar.BETA[sp,0])      ;; Upstream Ion Plasma Beta
dbetau         = REFORM(msolar.D_BETA[sp,0])    ;;  Uncertainty
betad          = REFORM(msolar.BETA[sp,1])      ;; Upstream Ion Plasma Beta
dbetad         = REFORM(msolar.D_BETA[sp,1])    ;;  Uncertainty
soundu         = REFORM(msolar.CS[sp,0])        ;; Upstream Sound Speed (km/s)
dsoundu        = REFORM(msolar.D_CS[sp,0])      ;;  Uncertainty
soundd         = REFORM(msolar.CS[sp,1])        ;; Downstream Sound Speed (km/s)
dsoundd        = REFORM(msolar.D_CS[sp,1])      ;;  Uncertainty
alfvnu         = REFORM(msolar.VA[sp,0])        ;; Upstream Alfven Speed (km/s)
dalfvnu        = REFORM(msolar.D_VA[sp,0])      ;;  Uncertainty
alfvnd         = REFORM(msolar.VA[sp,1])        ;; Downstream Alfven Speed (km/s)
dalfvnd        = REFORM(msolar.D_VA[sp,1])      ;;  Uncertainty
;;  Shock Parameters
nnorm          = mshock.NORM[sp,*]              ;; Shock Normal Vector
dnorm          = mshock.D_NORM[sp,*]            ;;  Uncertainty
thetbn         = mshock.THETA_BN[sp]            ;; Shock Normal Angle (deg)
dthetbn        = mshock.D_THETA_BN[sp]          ;;  Uncertainty
sh_vel         = mshock.VSHN[sp]                ;; Shock Velocity //-Normal (km/s)
dsh_vel        = mshock.D_VSHN[sp]              ;;  Uncertainty
compr          = mshock.COMPR[sp]               ;; Shock Compression Ratio
dcomp          = mshock.D_COMPR[sp]             ;;  Uncertainty
ush_nu         = mshock.USHN[sp,0]              ;; Normal Flow Velocity [in shock frame] (km/s)
dush_nu        = mshock.D_USHN[sp,0]            ;;  Uncertainty
ush_nd         = mshock.USHN[sp,1]              ;; Normal Flow Velocity [in shock frame] (km/s)
dush_nd        = mshock.D_USHN[sp,1]            ;;  Uncertainty
cs_slu         = mshock.CS_SLOW[sp,0]           ;; Upstream Slow Mode Speed (km/s)
dcs_slu        = mshock.D_CS_SLOW[sp,0]         ;;  Uncertainty
cs_sld         = mshock.CS_SLOW[sp,1]           ;; Downstream Slow Mode Speed (km/s)
dcs_sld        = mshock.D_CS_SLOW[sp,1]         ;;  Uncertainty
cs_inu         = mshock.CS_INT[sp,0]            ;; Upstream Intermediate Mode Speed (km/s)
dcs_inu        = mshock.D_CS_INT[sp,0]          ;;  Uncertainty
cs_ind         = mshock.CS_INT[sp,1]            ;; Downstream Intermediate Mode Speed (km/s)
dcs_ind        = mshock.D_CS_INT[sp,1]          ;;  Uncertainty
cs_fau         = mshock.CS_FAST[sp,0]           ;; Upstream Fast Mode Speed (km/s)
dcs_fau        = mshock.D_CS_FAST[sp,0]         ;;  Uncertainty
cs_fad         = mshock.CS_FAST[sp,1]           ;; Downstream Fast Mode Speed (km/s)
dcs_fad        = mshock.D_CS_FAST[sp,1]         ;;  Uncertainty
;;  Mach Numbers
Mf_u           = mshock.MACH_FAST[sp,0]         ;; Upstream Fast Mode Mach #
dMf_u          = mshock.D_MACH_FAST[sp,0]       ;;  Uncertainty
Mf_d           = mshock.MACH_FAST[sp,1]         ;; Downstream Fast Mode Mach #
dMf_d          = mshock.D_MACH_FAST[sp,1]       ;;  Uncertainty
Msl_u          = mshock.MACH_SLOW[sp,0]         ;; Upstream Slow Mode Mach #
dMsl_u         = mshock.D_MACH_SLOW[sp,0]       ;;  Uncertainty
Msl_d          = mshock.MACH_SLOW[sp,1]         ;; Downstream Slow Mode Mach #
dMsl_d         = mshock.D_MACH_SLOW[sp,1]       ;;  Uncertainty

betau          = REFORM(msolar.BETA[sp,0])      ;; Upstream Ion Plasma Beta
dbetau         = REFORM(msolar.D_BETA[sp,0])    ;;  Uncertainty
betad          = REFORM(msolar.BETA[sp,1])      ;; Upstream Ion Plasma Beta
dbetad         = REFORM(msolar.D_BETA[sp,1])    ;;  Uncertainty
;;----------------------------------------------------------------------------------------
;;  Define file name and path
;;----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(EXISTS) THEN BEGIN
  mdir  = FILE_EXPAND_PATH(def_path[0])
ENDIF ELSE BEGIN
  mdir  = !wind3dp_umn.ASCII_FILE_DIR
  IF (mdir[0] EQ '') THEN mdir = FILE_EXPAND_PATH(def_path[0])
ENDELSE
;;  Check for trailing '/'
ll             = STRMID(mdir[0], STRLEN(mdir[0]) - 1L,1L)
test           = (ll[0] NE slash[0])
IF (test) THEN mdir  = mdir[0]+slash[0]

outfile        = mdir[0]+def_file[0]
;;----------------------------------------------------------------------------------------
;;  Write data to file
;;----------------------------------------------------------------------------------------
qqq            = 1
j              = 0L
forms          = '(a30,a8,3f12.3,76f12.3)'
OPENW,gunit,outfile,/GET_LUN
WHILE(qqq) DO BEGIN
  tloc = REFORM(wloc[j,*])
  PRINTF,gunit,FORMAT=forms,ymdb[j],methd[j],tloc,vswu[j,0],dvswu[j,0],vswu[j,1],      $
               dvswu[j,1],vswu[j,2],dvswu[j,2],vswd[j,0],dvswd[j,0],vswd[j,1],         $
               dvswd[j,1],vswd[j,2],dvswd[j,2],magfu[j,0],dmagfu[j,0],magfu[j,1],      $
               dmagfu[j,1],magfu[j,2],dmagfu[j,2],magfd[j,0],dmagfd[j,0],magfd[j,1],   $
               dmagfd[j,1],magfd[j,2],dmagfd[j,2],densu[j],ddensu[j],densd[j],         $
               ddensd[j],betau[j],dbetau[j],betad[j],dbetad[j],                        $
               soundu[j],dsoundu[j],soundd[j],dsoundd[j],alfvnu[j],                    $
               dalfvnu[j],alfvnd[j],dalfvnd[j],nnorm[j,0],dnorm[j,0],nnorm[j,1],       $
               dnorm[j,1],nnorm[j,2],dnorm[j,2],thetbn[j],dthetbn[j],sh_vel[j],        $
               dsh_vel[j],compr[j],dcomp[j],ush_nu[j],dush_nu[j],ush_nd[j],dush_nd[j], $
               cs_slu[j],dcs_slu[j],cs_sld[j],dcs_sld[j],cs_inu[j],dcs_inu[j],         $
               cs_ind[j],dcs_ind[j],cs_fau[j],dcs_fau[j],cs_fad[j],dcs_fad[j],         $
               Mf_u[j],dMf_u[j],Mf_d[j],dMf_d[j],Msl_u[j],dMsl_u[j],Msl_d[j],dMsl_d[j]
  ;;  Increment index and test
  IF (j LT ns - 1L) THEN qqq = 1 ELSE qqq = 0
  IF (qqq) THEN j += 1
ENDWHILE
;;----------------------------------------------------------------------------------------
;;  Close file
;;----------------------------------------------------------------------------------------
FREE_LUN,gunit

;;****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;;****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END