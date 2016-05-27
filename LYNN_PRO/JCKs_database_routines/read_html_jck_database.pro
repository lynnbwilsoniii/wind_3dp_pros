;+
;*****************************************************************************************
;
;  PROCEDURE:   read_html_jck_database.pro
;  PURPOSE  :   Copy and paste the source code to the webpages of the data base created
;                 by Justin C. Kasper at http://www.cfa.harvard.edu/shocks/wi_data/ and
;                 keep them as ASCII files labeled as:
;                     source_MM-DD-YYYY_SSSSS.5_FF.html
;                     {where:  SSSSS = seconds of day, MM = month, DD = day, YYYY = year}
;                 The program iteratively reads in the ASCII files and retrieves the 
;                 relevant information from them (since each has a consistent format).
;                 The returned data is a structure containing all the relevant 
;                 data quantities from the method used by J.C. Kasper.
;
;  CALLED BY:   
;               write_shocks_jck_database.pro
;
;  CALLS:
;               get_os_slash.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  HTML files created by user the directory:
;                     ~/wind_data_dir/JCK_Data-Base/JCK_html_files/
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               read_write_jck_database,ALL_STR=all_str
;
;  KEYWORDS:    
;               ALL_STR  :  Set to a named variable to return the data from the ASCII
;                             files from J.C. Kasper's website.
;
;   CHANGED:  1)  Changed some syntax regarding none RH?? methods
;                                                                   [04/02/2009   v1.0.1]
;             2)  Changed line 266 of source_03-04-1998_39766.5_FF.html because
;                   the RH solutions do not converge, so it now uses MX2 instead
;                                                                   [04/02/2009   v1.0.2]
;             3)  Updated notes section with extra stuff
;                                                                   [04/07/2009   v1.0.3]
;             4)  Changed HTML file locations, thus the search syntax changed
;                   and renamed from my_jck_database_read_write.pro to
;                   read_write_jck_database.pro
;                                                                   [09/16/2009   v2.0.0]
;             5)  Cleaned up and changed location of HTML files
;                   and renamed from read_write_jck_database.pro to
;                   read_html_jck_database.pro
;                                                                   [09/20/2013   v3.0.0]
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
;   CREATED:  04/01/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/20/2013   v3.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO  read_html_jck_database,ALL_STR=all_str

;;----------------------------------------------------------------------------------------
;;  Define dummy and constant variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()         ;;  '/' for Unix, '\' for Windows
def_path       = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'wind_data_dir'+slash[0]
def_path       = def_path[0]+'JCK_Data-Base'+slash[0]+'JCK_html_files'+slash[0]
def_files      = '*.html'
;;----------------------------------------------------------------------------------------
;;  Check for files
;;----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(EXISTS) THEN BEGIN
  mdir  = FILE_EXPAND_PATH(def_path[0])
ENDIF ELSE BEGIN
  mdir  = !wind3dp_umn.ASCII_FILE_DIR
  IF (mdir[0] EQ '') THEN BEGIN
    mdir = FILE_EXPAND_PATH(def_path[0])
  ENDIF ELSE BEGIN
    mdir = mdir[0]+'JCK_html_files'+slash[0]
  ENDELSE
ENDELSE
files          = FILE_SEARCH(mdir[0],def_files[0])
nf             = N_ELEMENTS(files)
nk             = 0L                  ;;  # of total lines to be read in by program
FOR q=0L, nf - 1L DO nk += FILE_LINES(files[q])
;;----------------------------------------------------------------------------------------
;;  Define some dummy variables
;;----------------------------------------------------------------------------------------
a_odate        = REPLICATE('',nf)      ;;  Dates of events ['MM/DD/YYYY']
a_atime        = REPLICATE(f,nf)       ;;  Time of shock arrival (seconds of day)
a_dtime        = REPLICATE(f,nf)       ;;  Uncertainty
a_stype        = REPLICATE('',nf)      ;;  Type of shock (e.g. FF = fast forward, FR = fast reverse, etc.)
a_gselc        = REPLICATE(f,nf,3)     ;;  Wind GSE Positions (Re) at time of shock arrival
a_methd        = REPLICATE('',nf)      ;;  Type of analysis used (e.g. RH08)
a_pdely        = REPLICATE(f,nf)       ;;  Propagation Delay to Earth (min)
a_dpdly        = REPLICATE(f,nf)       ;;  Uncertainty
a_vsw          = REPLICATE(f,nf,3,2)   ;;  Solar Wind Velocity [GSE] (km/s) [up,down]
a_dvsw         = REPLICATE(f,nf,3,2)   ;;  Uncertainty
a_magf         = REPLICATE(f,nf,3,2)   ;;  Avg. Magnetic Field [GSE] (nT) [up,down]
a_dmagf        = REPLICATE(f,nf,3,2)   ;;  Uncertainty
a_idens        = REPLICATE(f,nf,2)     ;;  Ion density (cm^-3) [up,down]
a_ddens        = REPLICATE(f,nf,2)     ;;  Uncertainty
a_pbeta        = REPLICATE(f,nf,2)     ;;  Plasma Beta [up,down]
a_dbeta        = REPLICATE(f,nf,2)     ;;  Uncertainty
a_cspd         = REPLICATE(f,nf,2)     ;;  Sound Speed (km/s) [up,down]
a_dcspd        = REPLICATE(f,nf,2)     ;;  Uncertainty
a_vapd         = REPLICATE(f,nf,2)     ;;  Alfven Speed (km/s) [up,down]
a_dvapd        = REPLICATE(f,nf,2)     ;;  Uncertainty

a_nnorm        = REPLICATE(f,nf,3)     ;;  Shock normal vector [GSE]
a_dnorm        = REPLICATE(f,nf,3)     ;;  Uncertainty
a_nangs        = REPLICATE(f,nf,2)     ;;  Spherical Coord. Angles (theta and phi)
a_dangs        = REPLICATE(f,nf,2)     ;;  Uncertainty
a_thebn        = REPLICATE(f,nf)       ;;  Shock Normal Angle (deg)
a_dthet        = REPLICATE(f,nf)       ;;  Uncertainty
a_vshck        = REPLICATE(f,nf)       ;;  Shock Speed parallel to normal vector (km/s)
a_dvshk        = REPLICATE(f,nf)       ;;  Uncertainty
a_compr        = REPLICATE(f,nf)       ;;  Compression Ratio
a_dcomp        = REPLICATE(f,nf)       ;;  Uncertainty
a_un_sh        = REPLICATE(f,nf,2)     ;;  Flow Speed (//-Normal) in Shock frame (km/s) [up,down]
a_dn_sh        = REPLICATE(f,nf,2)     ;;  Uncertainty
a_cs_sl        = REPLICATE(f,nf,2)     ;;  Slow Mode speed (km/s) [up,down]
a_dc_sl        = REPLICATE(f,nf,2)     ;;  Uncertainty
a_cs_in        = REPLICATE(f,nf,2)     ;;  Intermediate (Alfven) speed (km/s) [up,down]
a_dc_in        = REPLICATE(f,nf,2)     ;;  Uncertainty
a_cs_fa        = REPLICATE(f,nf,2)     ;;  Fast Mode speed (km/s) [up,down]
a_dc_fa        = REPLICATE(f,nf,2)     ;;  Uncertainty
a_Ma_sl        = REPLICATE(f,nf,2)     ;;  Slow Mode Mach Number [up,down]
a_dM_sl        = REPLICATE(f,nf,2)     ;;  Uncertainty
a_Ma_fa        = REPLICATE(f,nf,2)     ;;  Fast Mode Mach Number [up,down]
a_dM_fa        = REPLICATE(f,nf,2)     ;;  Uncertainty
;;----------------------------------------------------------------------------------------
;;  Read in files and define elements of arrays
;;----------------------------------------------------------------------------------------
qqq            = 1
q              = 0L
WHILE(qqq) DO BEGIN
  n_f0  = FILE_LINES(files[q]) - 7L     ;;  # of lines of data in each file
  OPENR,gunit,files[q],/GET_LUN
  mline = ''
  PRINT,"Reading File..."
  PRINT,files[q]
  mvcount = 0L
  gcount  = 1
  ;;--------------------------------------------------------------------------------------
  ;;  Look at general Header info that does not depend on analysis methods
  ;;--------------------------------------------------------------------------------------
  WHILE(gcount) DO BEGIN
    READF,gunit,mline
    CASE mvcount[0] OF
      135  :  odate = STRMID(mline[0],18L,10L)    ;;  MM/DD/YYYY
      208  :  BEGIN
        atime = STRMID(mline[0],10L,7L)           ;;  Seconds of Day
        dtime = STRMID(mline[0],26L,6L)           ;;  Uncertainty
      END
      213  :  stype = STRMID(mline[0],10L,2L)     ;;  Shock Type (e.g. FF)
      220  :  xlocr = STRMID(mline[0],10L,8L)     ;;  X-GSE Location (Re)
      224  :  ylocr = STRMID(mline[0],10L,8L)     ;;  Y-GSE Location (Re)
      228  :  zlocr = STRMID(mline[0],10L,8L)     ;;  Z-GSE Location (Re)
      266  :  methd = STRMID(mline[0],39L,4L)     ;;  Analysis method used
      272  :  BEGIN
        prop_delay = STRMID(mline[0],40L,8L)      ;;  Propagation Delay to Earth (min)
        del_propd  = STRMID(mline[0],59L,8L)      ;;  Uncertainty (min)
      END
      299  :  BEGIN  ;;  Upstream Solar Wind Velocity (X-GSE) in km/s
        vswxu  = STRMID(mline[0],10L,8L)          ;;  Vsw_x (km/s)
        dvswxu = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      300  :  BEGIN  ;;  Downstream Solar Wind Velocity (X-GSE) in km/s
        vswxd  = STRMID(mline[0],10L,8L)          ;;  Vsw_x (km/s)
        dvswxd = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      304  :  BEGIN  ;;  Upstream Solar Wind Velocity (Y-GSE) in km/s
        vswyu  = STRMID(mline[0],10L,8L)          ;;  Vsw_y (km/s)
        dvswyu = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      305  :  BEGIN  ;;  Downstream Solar Wind Velocity (Y-GSE) in km/s
        vswyd  = STRMID(mline[0],10L,8L)          ;;  Vsw_y (km/s)
        dvswyd = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      309  :  BEGIN  ;;  Upstream Solar Wind Velocity (Z-GSE) in km/s
        vswzu  = STRMID(mline[0],10L,8L)          ;;  Vsw_z (km/s)
        dvswzu = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      310  :  BEGIN  ;;  Downstream Solar Wind Velocity (Z-GSE) in km/s
        vswzd  = STRMID(mline[0],10L,8L)          ;;  Vsw_z (km/s)
        dvswzd = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      324  :  BEGIN  ;;  Upstream Ion density (cm^-3)
        idensu = STRMID(mline[0],10L,8L)          ;;  Ni (cm^-3)
        ddensu = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      325  :  BEGIN  ;;  Downstream Ion density (cm^-3)
        idensd = STRMID(mline[0],10L,8L)          ;;  Ni (cm^-3)
        ddensd = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      329  :  BEGIN  ;;  Upstream estimate of X-GSE B-field (nT)
        magxu  = STRMID(mline[0],10L,8L)          ;;  Bx (nT)
        dmagxu = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      330  :  BEGIN  ;;  Downstream estimate of X-GSE B-field (nT)
        magxd  = STRMID(mline[0],10L,8L)          ;;  Bx (nT)
        dmagxd = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      334  :  BEGIN  ;;  Upstream estimate of Y-GSE B-field (nT)
        magyu  = STRMID(mline[0],10L,8L)          ;;  By (nT)
        dmagyu = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      335  :  BEGIN  ;;  Downstream estimate of Y-GSE B-field (nT)
        magyd  = STRMID(mline[0],10L,8L)          ;;  By (nT)
        dmagyd = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      339  :  BEGIN  ;;  Upstream estimate of Z-GSE B-field (nT)
        magzu  = STRMID(mline[0],10L,8L)          ;;  Bz (nT)
        dmagzu = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      340  :  BEGIN  ;;  Downstream estimate of Z-GSE B-field (nT)
        magzd  = STRMID(mline[0],10L,8L)          ;;  Bz (nT)
        dmagzd = STRMID(mline[0],26L,8L)          ;;  Uncertainty
      END
      345  :  BEGIN  ;;  Upstream estimate of the plasma beta
        pbetau = STRMID(mline[0],39L,8L)
        dbetau = STRMID(mline[0],55L,8L)
      END
      347  :  BEGIN  ;;  Downstream estimate of the plasma beta
        pbetad = STRMID(mline[0],39L,8L)
        dbetad = STRMID(mline[0],55L,8L)
      END
      352  :  BEGIN  ;;  Upstream estimate of the Sound Speed [km/s]
        cs_up  = STRMID(mline[0],39L,8L)
        dcs_up = STRMID(mline[0],55L,8L)
      END
      354  :  BEGIN  ;;  Downstream estimate of the Sound Speed [km/s]
        cs_dn  = STRMID(mline[0],39L,8L)
        dcs_dn = STRMID(mline[0],55L,8L)
      END
      359  :  BEGIN  ;;  Upstream estimate of the Alfven Speed [km/s]
        va_up  = STRMID(mline[0],39L,8L)
        dva_up = STRMID(mline[0],55L,8L)
      END
      361  :  BEGIN  ;;  Downstream estimate of the Alfven Speed [km/s]
        va_dn  = STRMID(mline[0],39L,8L)
        dva_dn = STRMID(mline[0],55L,8L)
      END
      ELSE :                                      ;;  Do Nothing...
    ENDCASE
    IF (mvcount[0] LT 381L) THEN gcount = 1 ELSE gcount = 0
    IF (gcount) THEN mvcount += 1L
  ENDWHILE
  ;;--------------------------------------------------------------------------------------
  ;;  Determine which case/method to use
  ;;    => sline[0]  =  line to start on for shock normal info (5 lines total here)
  ;;    => sline[1]  =  " " theta_Bn, shock speed, compression ratio (3 lines total)
  ;;    => sline[2]  =  " " Upstream Un, slow, inter., fast (6 lines total here)
  ;;    => sline[3]  =  " " Downstream " "
  ;;--------------------------------------------------------------------------------------
  methd = STRLOWCASE(STRTRIM(methd[0],2L))
  CASE methd[0] OF
    'mc<b' :  sline = [383L,486L,590L,728L]
    'vc<b' :  sline = [391L,492L,599L,737L]
    'mx1<' :  sline = [399L,498L,608L,746L]
    'mx2<' :  sline = [407L,504L,617L,755L]
    'mx3<' :  sline = [415L,510L,626L,764L]
    'rh08' :  sline = [423L,516L,635L,773L]
    'rh09' :  sline = [431L,522L,644L,782L]
    'rh10' :  sline = [440L,528L,653L,791L]
    ELSE   :  BEGIN
      STOP
      MESSAGE,'Method position moved for file: '+files[q],/INFORMATIONAL,/CONTINUE
      methd = ''
      ;;  Remember to set all values to NANs
    END
  ENDCASE
  IF (methd EQ '') THEN gcount = 0 ELSE gcount = 1
  ;;--------------------------------------------------------------------------------------
  ;;  Look at method specific info that does depend on analysis methods
  ;;--------------------------------------------------------------------------------------
  nnorm   = REPLICATE('',3)   ;;  Shock normal vector [GSE]
  dnorm   = REPLICATE('',3)   ;;  Uncertainty
  nangs   = REPLICATE('',2)   ;;  Spherical Coord. Angles (theta and phi)
  dangs   = REPLICATE('',2)   ;;  Uncertainty
  thebn   = ''                ;;  Shock Normal Angle (deg)
  dthet   = ''                ;;  Uncertainty
  vshck   = ''                ;;  Shock Speed parallel to normal vector (km/s)
  dvshk   = ''                ;;  Uncertainty
  compr   = ''                ;;  Compression Ratio
  dcomp   = ''                ;;  Uncertainty
  un_sh   = REPLICATE('',2)   ;;  Flow Speed (//-Normal) in Shock frame (km/s) [up,down]
  dn_sh   = REPLICATE('',2)   ;;  Uncertainty
  cs_sl   = REPLICATE('',2)   ;;  Slow Mode speed (km/s) [up,down]
  dc_sl   = REPLICATE('',2)   ;;  Uncertainty
  cs_in   = REPLICATE('',2)   ;;  Intermediate (Alfven) speed (km/s) [up,down]
  dc_in   = REPLICATE('',2)   ;;  Uncertainty
  cs_fa   = REPLICATE('',2)   ;;  Fast Mode speed (km/s) [up,down]
  dc_fa   = REPLICATE('',2)   ;;  Uncertainty
  Ma_sl   = REPLICATE('',2)   ;;  Slow Mode Mach Number [up,down]
  dM_sl   = REPLICATE('',2)   ;;  Uncertainty
  Ma_fa   = REPLICATE('',2)   ;;  Fast Mode Mach Number [up,down]
  dM_fa   = REPLICATE('',2)   ;;  Uncertainty
  WHILE(gcount) DO BEGIN
    CASE mvcount[0] OF
      ;;----------------------------------------------------------------------------------
      ;;  Shock Normal Information
      ;;----------------------------------------------------------------------------------
      sline[0] : BEGIN
        mmm = 1
        j   = 0L
        WHILE(mmm) DO BEGIN
          CASE j OF
            0 : BEGIN
              nnorm[0] = STRMID(mline[0],10L,8L)
              dnorm[0] = STRMID(mline[0],26L,8L)
            END
            1 : BEGIN
              nnorm[1] = STRMID(mline[0],10L,8L)
              dnorm[1] = STRMID(mline[0],26L,8L)
            END
            2 : BEGIN
              nnorm[2] = STRMID(mline[0],10L,8L)
              dnorm[2] = STRMID(mline[0],26L,8L)
            END
            3 : BEGIN
              nangs[0] = STRMID(mline[0],10L,8L)
              dangs[0] = STRMID(mline[0],26L,8L)
            END
            4 : BEGIN
              nangs[1] = STRMID(mline[0],10L,8L)
              dangs[1] = STRMID(mline[0],26L,8L)
            END
          ENDCASE
          ;;  Increment and test index
          IF (j LT 4L) THEN mmm = 1 ELSE mmm = 0
          IF (mmm) THEN j += 1L
          ;;  Read next line
          READF,gunit,mline
        ENDWHILE
        mvcount += 5L
      END
      ;;----------------------------------------------------------------------------------
      ;;  Shock Normal Angle, Shock Speed, and Compression Ratio
      ;;----------------------------------------------------------------------------------
      sline[1] : BEGIN
        mmm = 1
        j   = 0L
        WHILE(mmm) DO BEGIN
          CASE j OF
            0 : BEGIN
              thebn = STRMID(mline[0],10L,5L)  ;;  Shock Normal Angle (deg)
              dthet = STRMID(mline[0],23L,5L)  ;;  Uncertainty
            END
            1 : BEGIN
              vshck = STRMID(mline[0],10L,7L)  ;;  Shock Speed //-Normal Vector (km/s)
              dvshk = STRMID(mline[0],25L,7L)  ;;  Uncertainty
            END
            2 : BEGIN
              compr = STRMID(mline[0],10L,5L)  ;;  Shock Compression Ratio
              dcomp = STRMID(mline[0],23L,6L)  ;;  Uncertainty
            END
          ENDCASE
          ;;  Increment and test index
          IF (j LT 2L) THEN mmm = 1 ELSE mmm = 0
          IF (mmm) THEN j += 1L
          ;;  Read next line
          READF,gunit,mline
        ENDWHILE
        mvcount += 3L
      END
      ;;----------------------------------------------------------------------------------
      ;;  Upstream Un, slow, intermediate, and fast speed info
      ;;----------------------------------------------------------------------------------
      sline[2] : BEGIN
        mmm = 1
        j   = 0L
        WHILE(mmm) DO BEGIN
          CASE j OF
            0 : BEGIN
              un_sh[0] = STRMID(mline[0],10L,8L)  ;;  Un (shock frame) km/s [upstream]
              dn_sh[0] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
            1 : BEGIN
              cs_sl[0] = STRMID(mline[0],10L,8L)  ;;  Slow Mode Speed (km/s) [upstream]
              dc_sl[0] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
            2 : BEGIN
              cs_in[0] = STRMID(mline[0],10L,8L)  ;;  Intermediate Mode Speed (km/s) [upstream]
              dc_in[0] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
            3 : BEGIN
              cs_fa[0] = STRMID(mline[0],10L,8L)  ;;  Fast Mode Speed (km/s) [upstream]
              dc_fa[0] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
            4 : BEGIN
              Ma_sl[0] = STRMID(mline[0],10L,8L)  ;;  Slow Mode Mach Number [upstream]
              dM_sl[0] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
            5 : BEGIN
              Ma_fa[0] = STRMID(mline[0],10L,8L)  ;;  Fast Mode Mach Number [upstream]
              dM_fa[0] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
          ENDCASE
          ;;  Increment and test index
          IF (j LT 5L) THEN mmm = 1 ELSE mmm = 0
          IF (mmm) THEN j += 1L
          ;;  Read next line
          READF,gunit,mline
        ENDWHILE
        mvcount += 6L
      END
      ;;----------------------------------------------------------------------------------
      ;;  Downstream Un, slow, intermediate, and fast speed info
      ;;----------------------------------------------------------------------------------
      sline[3] : BEGIN
        mmm = 1
        j   = 0L
        WHILE(mmm) DO BEGIN
          CASE j OF
            0 : BEGIN
              un_sh[1] = STRMID(mline[0],10L,8L)  ;;  Un (shock frame) km/s [downstream]
              dn_sh[1] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
            1 : BEGIN
              cs_sl[1] = STRMID(mline[0],10L,8L)  ;;  Slow Mode Speed (km/s) [downstream]
              dc_sl[1] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
            2 : BEGIN
              cs_in[1] = STRMID(mline[0],10L,8L)  ;;  Intermediate Mode Speed (km/s) [downstream]
              dc_in[1] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
            3 : BEGIN
              cs_fa[1] = STRMID(mline[0],10L,8L)  ;;  Fast Mode Speed (km/s) [downstream]
              dc_fa[1] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
            4 : BEGIN
              Ma_sl[1] = STRMID(mline[0],10L,8L)  ;;  Slow Mode Mach Number [downstream]
              dM_sl[1] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
            5 : BEGIN
              Ma_fa[1] = STRMID(mline[0],10L,8L)  ;;  Fast Mode Mach Number [downstream]
              dM_fa[1] = STRMID(mline[0],26L,8L)  ;;  Uncertainty
            END
          ENDCASE
          ;;  Increment and test index
          IF (j LT 5L) THEN mmm = 1 ELSE mmm = 0
          IF (mmm) THEN j += 1L
          ;;  Read next line
          READF,gunit,mline
        ENDWHILE
        mvcount += 6L
      END
      ELSE :  BEGIN
        ;;  Read next line
        READF,gunit,mline
        ;;  Increment index
        mvcount += 1L
      END
    ENDCASE
    IF (mvcount[0] LT 800L) THEN gcount = 1 ELSE gcount = 0
  ENDWHILE
  ;;  Close file
  FREE_LUN,gunit
  ;;--------------------------------------------------------------------------------------
  ;;  Assign header values to arrays
  ;;--------------------------------------------------------------------------------------
  a_odate[q]     = STRTRIM(odate,2L)
  a_stype[q]     = STRTRIM(stype,2L)
  a_methd[q]     = STRUPCASE(methd)
  a_atime[q]     = FLOAT(STRTRIM(atime,2L))
  a_dtime[q]     = FLOAT(STRTRIM(dtime,2L))
  a_gselc[q,*]   = FLOAT([STRTRIM(xlocr,2L),STRTRIM(ylocr,2L),STRTRIM(zlocr,2L)])
  a_pdely[q]     = FLOAT(STRTRIM(prop_delay,2L))
  a_dpdly[q]     = FLOAT(STRTRIM(del_propd,2L))
  a_vsw[q,*,0]   = FLOAT([STRTRIM(vswxu,2L),STRTRIM(vswyu,2L),STRTRIM(vswzu,2L)])
  a_vsw[q,*,1]   = FLOAT([STRTRIM(vswxd,2L),STRTRIM(vswyd,2L),STRTRIM(vswzd,2L)])
  a_dvsw[q,*,0]  = FLOAT([STRTRIM(dvswxu,2L),STRTRIM(dvswyu,2L),STRTRIM(dvswzu,2L)])
  a_dvsw[q,*,1]  = FLOAT([STRTRIM(dvswxd,2L),STRTRIM(dvswyd,2L),STRTRIM(dvswzd,2L)])
  a_magf[q,*,0]  = FLOAT([STRTRIM(magxu,2L),STRTRIM(magyu,2L),STRTRIM(magzu,2L)])
  a_magf[q,*,1]  = FLOAT([STRTRIM(magxd,2L),STRTRIM(magyd,2L),STRTRIM(magzd,2L)])
  a_dmagf[q,*,0] = FLOAT([STRTRIM(dmagxu,2L),STRTRIM(dmagyu,2L),STRTRIM(dmagzu,2L)])
  a_dmagf[q,*,1] = FLOAT([STRTRIM(dmagxd,2L),STRTRIM(dmagyd,2L),STRTRIM(dmagzd,2L)])
  a_pbeta[q,*]   = FLOAT([STRTRIM(pbetau,2L),STRTRIM(pbetad,2L)])
  a_dbeta[q,*]   = FLOAT([STRTRIM(dbetau,2L),STRTRIM(dbetad,2L)])
  a_idens[q,*]   = FLOAT([STRTRIM(idensu,2L),STRTRIM(idensd,2L)])
  a_ddens[q,*]   = FLOAT([STRTRIM(ddensu,2L),STRTRIM(ddensd,2L)])
  a_cspd[q,*]    = FLOAT([STRTRIM(cs_up,2L),STRTRIM(cs_dn,2L)])
  a_dcspd[q,*]   = FLOAT([STRTRIM(dcs_up,2L),STRTRIM(dcs_dn,2L)])
  a_vapd[q,*]    = FLOAT([STRTRIM(va_up,2L),STRTRIM(va_dn,2L)])
  a_dvapd[q,*]   = FLOAT([STRTRIM(dva_up,2L),STRTRIM(dva_dn,2L)])
  ;;--------------------------------------------------------------------------------------
  ;;  Assign method values to arrays
  ;;--------------------------------------------------------------------------------------
  a_nnorm[q,*]   = FLOAT(STRTRIM(nnorm[*],2L))
  a_dnorm[q,*]   = FLOAT(STRTRIM(dnorm[*],2L))
  a_nangs[q,*]   = FLOAT(STRTRIM(nangs[*],2L))
  a_dangs[q,*]   = FLOAT(STRTRIM(dangs[*],2L))
  a_thebn[q]     = FLOAT(STRTRIM(thebn[*],2L))
  a_dthet[q]     = FLOAT(STRTRIM(dthet[*],2L))
  a_vshck[q]     = FLOAT(STRTRIM(vshck,2L))
  a_dvshk[q]     = FLOAT(STRTRIM(dvshk,2L))
  a_compr[q]     = FLOAT(STRTRIM(compr,2L))
  a_dcomp[q]     = FLOAT(STRTRIM(dcomp,2L))
  a_un_sh[q,*]   = FLOAT(STRTRIM(un_sh[*],2L))
  a_dn_sh[q,*]   = FLOAT(STRTRIM(dn_sh[*],2L))
  a_cs_sl[q,*]   = FLOAT(STRTRIM(cs_sl[*],2L))
  a_dc_sl[q,*]   = FLOAT(STRTRIM(dc_sl[*],2L))
  a_cs_in[q,*]   = FLOAT(STRTRIM(cs_in[*],2L))
  a_dc_in[q,*]   = FLOAT(STRTRIM(dc_in[*],2L))
  a_cs_fa[q,*]   = FLOAT(STRTRIM(cs_fa[*],2L))
  a_dc_fa[q,*]   = FLOAT(STRTRIM(dc_fa[*],2L))
  a_Ma_sl[q,*]   = FLOAT(STRTRIM(Ma_sl[*],2L))
  a_dM_sl[q,*]   = FLOAT(STRTRIM(dM_sl[*],2L))
  a_Ma_fa[q,*]   = FLOAT(STRTRIM(Ma_fa[*],2L))
  a_dM_fa[q,*]   = FLOAT(STRTRIM(dM_fa[*],2L))
  ;;  Increment and test index
  IF (q LT nf - 1L) THEN qqq = 1 ELSE qqq = 0
  IF (qqq) THEN q += 1
ENDWHILE
;;----------------------------------------------------------------------------------------
;;  Define structures to be returned to user
;;----------------------------------------------------------------------------------------
head_str  = CREATE_STRUCT('DATES',a_odate,'TIMES',a_atime,'D_TIMES',a_dtime,         $
                          'SHOCK_TYPE',a_stype,'METHODS',a_methd,                    $
                          'WIND_LOCATION',a_gselc,'DELAY_TIME',a_pdely,              $
                          'D_DELAY_TIME',a_dpdly)

swind_str = CREATE_STRUCT('VSW',a_vsw,'D_VSW',a_dvsw,'MAGF',a_magf,'D_MAGF',a_dmagf, $
                          'DENS',a_idens,'D_DENS',a_ddens,'BETA',a_pbeta,            $
                          'D_BETA',a_dbeta,'CS',a_cspd,'D_CS',a_dcspd,'VA',a_vapd,   $
                          'D_VA',a_dvapd)

sh_str    = CREATE_STRUCT('NORM',a_nnorm,'D_NORM',a_dnorm,'N_ANGS',a_nangs,          $
                          'D_N_ANGS',a_dangs,'THETA_BN',a_thebn,'D_THETA_BN',a_dthet,$
                          'VSHN',a_vshck,'D_VSHN',a_dvshk,'COMPR',a_compr,           $
                          'D_COMPR',a_dcomp,'USHN',a_un_sh,'D_USHN',a_dn_sh,         $
                          'CS_SLOW',a_cs_sl,'D_CS_SLOW',a_dc_sl,'CS_INT',a_cs_in,    $
                          'D_CS_INT',a_dc_in,'CS_FAST',a_cs_fa,'D_CS_FAST',a_dc_fa,  $
                          'MACH_SLOW',a_Ma_sl,'D_MACH_SLOW',a_dM_sl,                 $
                          'MACH_FAST',a_Ma_fa,'D_MACH_FAST',a_dM_fa)

all_str   = CREATE_STRUCT('HEADER_STR',head_str,'SOLAR_WIND_STR',swind_str,          $
                          'SHOCK_STR',sh_str)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END