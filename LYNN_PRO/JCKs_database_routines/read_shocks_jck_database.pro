;+
;*****************************************************************************************
;
;  FUNCTION :   read_shocks_jck_database.pro
;  PURPOSE  :   Reads in file created by write_shocks_jck_database.pro and returns a
;                 structure containing all the relevant information determined by
;                 Justin C. Kasper at:  http://www.cfa.harvard.edu/shocks/wi_data/
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_os_slash.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII file created by write_shocks_jck_database.pro
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               test = read_shocks_jck_database()
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed indexing error in Mach numbers
;                                                                   [04/08/2009   v1.0.1]
;             2)  Changed HTML file locations, thus the search syntax changed
;                   and renamed from my_all_shocks_read.pro to 
;                   read_shocks_jck_database.pro
;                                                                   [09/16/2009   v2.0.0]
;             3)  Changed read statement format and output
;                                                                   [11/16/2010   v2.1.0]
;             4)  Cleaned up and changed location of HTML files
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
;   CREATED:  04/07/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/20/2013   v2.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  read_shocks_jck_database

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
;;  Find Data file
;;----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(EXISTS) THEN BEGIN
  mdir  = FILE_EXPAND_PATH(def_path[0])
ENDIF ELSE BEGIN
  mdir  = !wind3dp_umn.ASCII_FILE_DIR
  IF (mdir[0] EQ '') THEN mdir = FILE_EXPAND_PATH(def_path[0])
ENDELSE

test           = FILE_SEARCH(mdir,def_file[0])
IF (test[0] EQ '') THEN BEGIN
  MESSAGE,'Unable to find data file...',/INFORMATIONAL,/CONTINUE
  RETURN,0
END
;;----------------------------------------------------------------------------------------
;;  Define Dummy Variables
;;----------------------------------------------------------------------------------------
infile         = test[0]
nn             = FILE_LINES(infile)           ;;  # of shock events
nn             = nn[0]

adate          = REPLICATE('',nn)             ;;  Dates of events ['MM-DD-YYYY/HH:MM:SS.sss']
ameth          = REPLICATE('',nn)             ;;  Shock Analysis Method used by J.C. Kasper
alocs          = REPLICATE(0.0,nn,3)          ;;  Wind GSE-location at shock arrival (Re) 
vswud          = REPLICATE(0.0,nn,3,2)        ;;  Up&down-stream solar wind velocity (km/s)
dvsw           = REPLICATE(0.0,nn,3,2)        ;;  Uncertainty
magud          = REPLICATE(0.0,nn,3,2)        ;;  Up&down-stream magnetic field vectors (nT)
dmagf          = REPLICATE(0.0,nn,3,2)        ;;  Uncertainty
idens          = REPLICATE(0.0,nn,2)          ;;  Up&down-stream ion density (cm^-3)
ddens          = REPLICATE(0.0,nn,2)          ;;  Uncertainty
pbeta          = REPLICATE(0.0,nn,2)          ;;  Up&down-stream ion beta
dbeta          = REPLICATE(0.0,nn,2)          ;;  Uncertainty
Cs_ud          = REPLICATE(0.0,nn,2)          ;;  " " Sound speed (km/s)
dCsud          = REPLICATE(0.0,nn,2)          ;;  Uncertainty
Va_ud          = REPLICATE(0.0,nn,2)          ;;  " " Alfven speed (km/s)
dVaud          = REPLICATE(0.0,nn,2)          ;;  Uncertainty

nnorm          = REPLICATE(0.0,nn,3)          ;;  Shock normal vector [GSE]
dnorm          = REPLICATE(0.0,nn,3)          ;;  Uncertainty
thebn          = REPLICATE(0.0,nn)            ;;  Shock Normal Angle (deg)
dthet          = REPLICATE(0.0,nn)            ;;  Uncertainty
vshck          = REPLICATE(0.0,nn)            ;;  Shock Speed parallel to normal vector (km/s)
dvshk          = REPLICATE(0.0,nn)            ;;  Uncertainty
compr          = REPLICATE(0.0,nn)            ;;  Compression Ratio
dcomp          = REPLICATE(0.0,nn)            ;;  Uncertainty
un_sh          = REPLICATE(0.0,nn,2)          ;;  Flow Speed (//-n) in Shock frame (km/s) [up,down]
dn_sh          = REPLICATE(0.0,nn,2)          ;;  Uncertainty
cs_sl          = REPLICATE(0.0,nn,2)          ;;  Slow Mode speed (km/s) [up,down]
dc_sl          = REPLICATE(0.0,nn,2)          ;;  Uncertainty
cs_in          = REPLICATE(0.0,nn,2)          ;;  Intermediate (Alfven) speed (km/s) [up,down]
dc_in          = REPLICATE(0.0,nn,2)          ;;  Uncertainty
cs_fa          = REPLICATE(0.0,nn,2)          ;;  Fast Mode speed (km/s) [up,down]
dc_fa          = REPLICATE(0.0,nn,2)          ;;  Uncertainty
Ma_sl          = REPLICATE(0.0,nn,2)          ;;  Slow Mode Mach Number [up,down]
dM_sl          = REPLICATE(0.0,nn,2)          ;;  Uncertainty
Ma_fa          = REPLICATE(0.0,nn,2)          ;;  Fast Mode Mach Number [up,down]
dM_fa          = REPLICATE(0.0,nn,2)          ;;  Uncertainty
;;----------------------------------------------------------------------------------------
;;  Read in file and define data
;;----------------------------------------------------------------------------------------
forms           = '(a30,a8,3f12.3,76f12.3)'
a0              = ''                         ;;  For Date/Time       [dummy variable]
a1              = ''                         ;;  For Analysis Method [dummy variable]
dat0            = FLTARR(3)                  ;;  For Wind Positions  [dummy variable]
dat1            = FLTARR(76)                 ;;  For rest of data    [dummy variable]

qqq             = 1
j               = 0L
;;----------------------------------------------------------------------------------------
;;  Open file and read in data
;;----------------------------------------------------------------------------------------
OPENR,gunit,infile,/GET_LUN
WHILE(qqq) DO BEGIN
  READF,gunit,FORMAT=forms,a0,a1,dat0,dat1
  adate[j]     = a0
  ameth[j]     = a1
  alocs[j,*]   = dat0[*]
  vswud[j,*,0] = dat1[[0L,2L,4L]]
  vswud[j,*,1] = dat1[[6L,8L,10L]]
  dvsw[j,*,0]  = dat1[[1L,3L,5L]]
  dvsw[j,*,1]  = dat1[[7L,9L,11L]]
  magud[j,*,0] = dat1[[12L,14L,16L]]
  magud[j,*,1] = dat1[[18L,20L,22L]]
  dmagf[j,*,0] = dat1[[13L,15L,17L]]
  dmagf[j,*,1] = dat1[[19L,21L,23L]]
  idens[j,*]   = [dat1[24L],dat1[26L]]
  ddens[j,*]   = [dat1[25L],dat1[27L]]
  pbeta[j,*]   = [dat1[28L],dat1[30L]]
  dbeta[j,*]   = [dat1[29L],dat1[31L]]
  ;;  Sound and Alfvén speeds
  Cs_ud[j,*]   = [dat1[32L],dat1[34L]]
  dCsud[j,*]   = [dat1[33L],dat1[35L]]
  Va_ud[j,*]   = [dat1[36L],dat1[38L]]
  dVaud[j,*]   = [dat1[37L],dat1[39L]]
  ;;  Shock geometry variables
  nnorm[j,*]   = [dat1[40L],dat1[42L],dat1[44L]]
  dnorm[j,*]   = [dat1[41L],dat1[43L],dat1[45L]]
  thebn[j]     = dat1[46L]
  dthet[j]     = dat1[47L]
  ;;  Shock speed and compression ratio
  vshck[j]     = dat1[48L]
  dvshk[j]     = dat1[49L]
  compr[j]     = dat1[50L]
  dcomp[j]     = dat1[51L]
  ;;  Shock speeds and Mach numbers
  un_sh[j,*]   = [dat1[52L],dat1[54L]]
  dn_sh[j,*]   = [dat1[53L],dat1[55L]]
  cs_sl[j,*]   = [dat1[56L],dat1[58L]]
  dc_sl[j,*]   = [dat1[57L],dat1[59L]]
  cs_in[j,*]   = [dat1[60L],dat1[62L]]
  dc_in[j,*]   = [dat1[61L],dat1[63L]]
  cs_fa[j,*]   = [dat1[64L],dat1[66L]]
  dc_fa[j,*]   = [dat1[65L],dat1[67L]]
  Ma_fa[j,*]   = [dat1[68L],dat1[70L]]
  dM_fa[j,*]   = [dat1[69L],dat1[71L]]
  Ma_sl[j,*]   = [dat1[72L],dat1[74L]]
  dM_sl[j,*]   = [dat1[73L],dat1[75L]]
  
  IF (j LT nn - 1L) THEN qqq = 1 ELSE qqq = 0
  IF (qqq) THEN j += 1
ENDWHILE
;;----------------------------------------------------------------------------------------
;;  Close file
;;----------------------------------------------------------------------------------------
FREE_LUN,gunit

adate          = STRTRIM(adate,2L)
ameth          = STRTRIM(ameth,2L)
sdate          = ''        ;;  Short Dates ['MMDDYY']
sdate          = STRMID(adate[*],5L,2L)+STRMID(adate[*],8L,2L)+STRMID(adate[*],2L,2L)
;;----------------------------------------------------------------------------------------
;;  Create structures to return data
;;----------------------------------------------------------------------------------------
tags_0 = ['DATE_TIME','METHOD','LOCATION','VSW','D_VSW','MAGF','D_MAGF',  $
          'DENS','D_DENS','BETA','D_BETA','C_SOUND','D_C_SOUND',          $
          'V_ALFVEN','D_V_ALFVEN']
tags_1 = ['SH_NORM','D_SH_NORM','THETA_BN','D_THETA_BN','VSH_N','D_VSH_N',$
          'COMPRESSION','D_COMPRESSION','USH_N','D_USH_N',                $
          'CS_SLOW','D_CS_SLOW','CS_INT','D_CS_INT','CS_FAST','D_CS_FAST',$
          'MACH_SLOW','D_MACH_SLOW','MACH_FAST','D_MACH_FAST']

str_0 = CREATE_STRUCT(tags_0,adate,ameth,alocs,vswud,dvsw,magud,dmagf,idens,ddens,$
                             pbeta,dbeta,Cs_ud,dCsud,Va_ud,dVaud)
str_1 = CREATE_STRUCT(tags_1,nnorm,dnorm,thebn,dthet,vshck,dvshk,compr,dcomp,     $
                             un_sh,dn_sh,cs_sl,dc_sl,cs_in,dc_in,cs_fa,dc_fa,     $
                             Ma_sl,dM_sl,Ma_fa,dM_fa)

r_str = CREATE_STRUCT('SDATES',sdate,'HEADER',str_0,'SHOCK',str_1)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,r_str
END