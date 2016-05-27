;+
;*****************************************************************************************
;
;  PROCEDURE:   write_shocks_jck_database_new.pro
;  PURPOSE  :   This routine creates an IDL save file containing all the results from
;                 the Harvard CfA Wind shock database for fast forward (FF) shocks.
;                 The save file is stored in the same place as the ASCII file created
;                 by the older version of this routine, write_shocks_jck_database.pro.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               read_html_jck_database_new.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  HTML files created by using
;                       create_html_from_cfa_winddb_urls.pro
;                     in the directory:
;                       ~/wind_3dp_pros/wind_data_dir/JCK_Data-Base/JCK_html_files/
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               write_shocks_jck_database_new
;
;  KEYWORDS:    
;               DIRECT       :  Scalar [string] defining the directory location
;                                 of the HTML ASCII files one is interested in
;                [Default = '~/wind_3dp_pros/wind_data_dir/JCK_Data-Base/JCK_html_files/']
;               STATUS       :  If set, routine will print out status updates
;                                 [Default = FALSE]
;
;   CHANGED:  1)  Finished writing the routine and moved to
;                   ~/wind_3dp_pros/LYNN_PRO/JCKs_database_routines
;                                                                   [02/18/2015   v1.0.0]
;
;   NOTES:      
;               1)  Definitions
;                     SCF   :  Spacecraft frame of reference
;                     SHF   :  Shock rest frame of reference
;                     n     :  Shock normal unit vector [GSE basis]
;                     Vsh   :  Shock velocity in SCF [km/s]
;                     Vshn  :  Shock normal speed in SCF [km/s]
;                                [ = |Vsh . n| ]
;                     Ushn  :  Shock normal speed in SHF [km/s]
;                                [ = (Vsw . n) - (Vsh . n) ]
;                     Vs    :  Phase speed of MHD slow mode [km/s]
;                     Vi    :  Phase speed of MHD intermediate mode [km/s]
;                     Vf    :  Phase speed of MHD fast mode [km/s]
;                     Q_j   :  Avg. of quantity Q in region j, where
;                                j = 1 (upstream), 2 (downstream)
;                     
;               2)  Methods Used by J.C. Kasper:
;                     MC    :  Magnetic Coplanarity    (Viñas and Scudder, [1986])
;                     VC    :  Velocity Coplanarity    (Viñas and Scudder, [1986])
;                     MX1   :  Mixed Mode Normal 1     (Russell et. al., [1983])
;                     MX2   :  Mixed Mode Normal 2     (Russell et. al., [1983])
;                     MX3   :  Mixed Mode Normal 3     (Russell et. al., [1983])
;                     RH08  :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])
;                     RH09  :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])
;                     RH10  :  Rankine-Hugoniot 10 Eqs (Viñas and Scudder, [1986])
;               3)  Definition of Parameters on website
;                     Nj                  :  j-th component of n [GSE basis]
;                     Theta               :  Spherical poloidal angle of n [GSE basis]
;                     Phi                 :  Spherical azimuthal angle of n [GSE basis]
;                     Shock Speed         :  Vshn [km/s]
;                     Compression Ratio   :  N_2/N_1, where N_j = <N> in region j
;                     Shock Normal Angle  :  Angle between n and upstream <B> [degrees]
;                     dV                  :  Ushn [km/s]
;                     Slow                :  Vs [km/s]
;                     Intermediate        :  Vi [km/s]
;                     Fast                :  Vf [km/s]
;                     Slow Mach           :  Ms = |Ushn,j|/<Vs,j>
;                     Fast Mach           :  Mf = |Ushn,j|/<Vf,j>
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
;   CREATED:  02/18/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/18/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO write_shocks_jck_database_new,DIRECT=direct,STATUS=status

;;----------------------------------------------------------------------------------------
;;  Define dummy and constant variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()         ;;  '/' for Unix, '\' for Windows
;;  Define output IDL save file name
file           = 'All_JCKaspers_Shock_Parameters.sav'
;;----------------------------------------------------------------------------------------
;;  Define default search paths and file names
;;----------------------------------------------------------------------------------------
;;  Define location of locally saved HTML files
def_cfa_path   = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'wind_data_dir'+slash[0]+ $
                     'JCK_Data-Base'+slash[0]
def_path       = def_cfa_path[0]+'JCK_html_files'+slash[0]
;;  Define location of where to put output IDL save file
def_idlsave_pt = def_cfa_path[0]
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Setup file paths to HTML files
;;  Check DIRECT
DEFSYSV,'!wind3dp_umn',EXISTS=exists
test           = ~KEYWORD_SET(exists) AND (SIZE(direct,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  mdir  = FILE_EXPAND_PATH(def_path[0])
ENDIF ELSE BEGIN
  test  = (SIZE(direct,/TYPE) NE 7)
  IF (test[0]) THEN BEGIN
    ;;  !wind3dp_umn system variable has been created
    mdir  = !wind3dp_umn.ASCII_FILE_DIR
    IF (mdir[0] EQ '') THEN BEGIN
      mdir = FILE_EXPAND_PATH(def_path[0])
    ENDIF ELSE BEGIN
      mdir = mdir[0]+'JCK_html_files'+slash[0]
    ENDELSE
  ENDIF ELSE BEGIN
    ;;  DIRECT keyword was set
    ;;    --> check it
    test = FILE_TEST(direct[0],/DIRECTORY)
    IF (test[0]) THEN BEGIN
      ;;  DIRECT is a directory
      mdir  = EXPAND_PATH(direct[0])
    ENDIF ELSE BEGIN
      ;;  DIRECT is NOT a directory
      ;;    --> use default
      mdir  = FILE_EXPAND_PATH(def_path[0])
    ENDELSE
  ENDELSE
ENDELSE
html_path      = mdir[0]
idlsave_path   = FILE_DIRNAME(html_path,/MARK_DIRECTORY)
fname          = idlsave_path[0]+file[0]

;;  Check STATUS
test           = KEYWORD_SET(status) AND (N_ELEMENTS(status) NE 0)
IF (test[0]) THEN verbose = 1 ELSE verbose = 0
;;----------------------------------------------------------------------------------------
;;  Read in results
;;----------------------------------------------------------------------------------------
cfa_db_wind    = read_html_jck_database_new(DIRECT=html_path)
IF (SIZE(cfa_db_wind,/TYPE) NE 8) THEN STOP ;;  Something's wrong --> debug
;;----------------------------------------------------------------------------------------
;;  Create IDL save file
;;----------------------------------------------------------------------------------------
;;  Define a general output statement and prompt
out_geni_str   = ['Please carefully read the following descriptions if you are not familiar with the',    $
                  '  format of the output structure returned by this routine.  Below you will find',      $
                  '  variable descriptions and definitions printed to the screen.',                       $
                  '  If you do(not) wish to print these descriptions, please respond by typing the',      $
                  '  following:  y(n).  If you wish to quit, type q .'                                    ]
out_prom_str   = ['Please type (y/n) to print/not print the structure info:  '                            ]
yes_first_out  = ['The following contains definitions pertaining to the output structure and',            $
                  '  references to the Harvard Center for Astrophysics (CfA) interplanetary shock',       $
                  '  database for the Wind spacecraft or CfAIPSWDB found at:',                            $
                  '',                                                                                     $
                  'https://www.cfa.harvard.edu/shocks/wi_data/',                                          $
                  ''                                                                                      ]
;;  Define some definitions of abbreviations of shock analysis methods
meths_descr    = ['The following are references to labels for shock analysis methods at CfAIPSWDB.',      $
                  '',                                                                                     $
                  'Defintion of Methods used to obtain results:',                                         $
                  '  MC    :  Magnetic Coplanarity    (Viñas and Scudder, [1986])',                       $
                  '  VC    :  Velocity Coplanarity    (Viñas and Scudder, [1986])',                       $
                  '  MX1   :  Mixed Mode Normal 1     (Russell et. al., [1983])',                         $
                  '  MX2   :  Mixed Mode Normal 2     (Russell et. al., [1983])',                         $
                  '  MX3   :  Mixed Mode Normal 3     (Russell et. al., [1983])',                         $
                  '  RH08  :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])',                       $
                  '  RH09  :  Rankine-Hugoniot 8 Eqs  (Viñas and Scudder, [1986])',                       $
                  '  RH10  :  Rankine-Hugoniot 10 Eqs (Viñas and Scudder, [1986])'                        ]
;;  Define the definitions of the top level tags in the output structure
top_lev_tags   = ['The following are definitions of references to headings for shock events at CfAIPSWDB',$
                  'https://www.cfa.harvard.edu/shocks/wi_data/',                                          $
                  '',                                                                                     $
                  'GEN_INFO  :  Contains info from "General Information" tables',                         $
                  'ASY_INFO  :  Contains info from "Asymptotic plasma parameters" tables',                $
                  'BVN_INFO  :  Contains info from "Best values of shock front normal..." tables',        $
                  'KEY_INFO  :  Contains info from "Key shock parameters" table',                         $
                  'UPS_INFO  :  Contains info from "Upstream wave speeds and mach numbers" table',        $
                  'DNS_INFO  :  Contains info from "Downstream wave speeds and mach numbers" table'       ]
;;  Define some description variables of the output structure format and contents
struc_form     = ['In the following discussion of the tags within the main (e.g., GEN_INFO), we define:', $
                  '  N  =  # of shock events',                                                            $
                  '  M  =  # of shock analysis methods',                                                  $
                  '  V  =  # of components (e.g., 3 for vector)',                                         $
                  '  U  =  # of regions (i.e., = 2, 1 for upstream and downstream)',                      $
                  ' - For tags associated with structures below, we define the array dimensions for the', $
                  '     data (tag Y), which matches the uncertainty (tag DY) dimensions.',                $
                  ' - For the shock method below, the string array contains the method that the software',$
                  '     chose as the "best" result, but the user can specify whether to return all',      $
                  '     results if they so desire.',                                                      $
                  ' - Each structure has a general format, described below:',                             $
                  '   1)  If parameter has an uncertainty, then it will be a structure with the tags:',   $
                  '         Y   :  Array of values',                                                      $
                  '         DY  :  Array of uncertainties',                                               $
                  '   2)  If table has associated statistics, then they will be found in an additional',  $
                  '         structure defined by the tag, STATS, that contains the same tags as the',     $
                  '         outer/main structure but each tag is now a structure with the tags:',         $
                  '         AVG  :  Array of averages (over methods) of TAG[i] values',                   $
                  '         MED  :  Array of medians (over methods) of TAG[i] values',                    $
                  '         STD  :  Array of Std. Dev. (over methods) of TAG[i] values'                   ]
;;  Define structure tags for "General Information" table
gen_info_descr = ['In the following, we define the structure tag values taken from the',                  $
                  '  "General Information" table:',                                                       $
                  '',                                                                                     $
                  'TDATES      :  [N]-Element [string] array of shock dates [e.g., "1997-01-05"]',        $
                  'FRAC_DOY    :  [N]-Element [float] array of shock arrival times as fraction of DoY',   $
                  'ARRT_SOD    :  [N]-Element [float] array of shock arrival times as SoD',               $
                  'ARRT_UNIX   :  [N]-Element [double] array of shock arrival times as Unix times',       $
                  'SH_TYPE     :  [N]-Element [string] array of shock types [e.g., "FF"]',                $
                  'E_DATA_YN   :  [N]-Element [byte] array defining whether electron data was used',      $
                  '                  [1 = TRUE, 0 = FALSE]',                                              $
                  'SCPOS_GSE   :  [N,V]-Element [float] array of spacecraft GSE positions at time of',    $
                  '                  the event [Re]',                                                     $
                  'N_UP_P_PTS  :  [N]-Element [long] array defining the number of plasma data points',    $
                  '                  used for upstream analysis',                                         $
                  'N_UP_F_PTS  :  [N]-Element [long] array defining the number of magnetic field data',   $
                  '                  points used for upstream analysis',                                  $
                  'N_DN_P_PTS  :  [N]-Element [long] array defining the number of plasma data points',    $
                  '                  usedfor downstream analysis',                                        $
                  'N_DN_F_PTS  :  [N]-Element [long] array defining the number of magnetic field data',   $
                  '                  points used for downstream analysis',                                $
                  'RH_METHOD   :  [N]-Element [string] array defining the selected method corresponding', $
                  '                  to the "best" one'                                                   ]
;;  Define structure tags for "Asymptotic plasma parameters" table
asy_info_descr = ['In the following, we define the structure tag values taken from the',                  $
                  '  "Asymptotic plasma parameters" table:',                                              $
                  '',                                                                                     $
                  'VBULK_GSE     :  [N,V,U]-Element [float] array of Avg. ion bulk flow velocities',      $
                  '                   in the spacecraft rest frame [GSE, km/s]',                          $
                  '                   {Let:  Vsw_jk = VBULK_GSE[j,*,k]}',                                 $
                  'VTH_ION       :  [N,U]-Element [float] array of Avg. ion thermal speeds [km/s]',       $
                  '                   {Let:  Wi_jk  = VTH_ION[j,k]}',                                     $
                  'VTH_ELE       :  [N,U]-Element [float] array of Avg. electron thermal speeds [km/s]',  $
                  '                   {only has meaning if E_DATA_YN = 1}',                               $
                  'DENS_ION      :  [N,U]-Element [float] array of Avg. ion number densities [cm^(-3)]',  $
                  '                   {Let:  Ni_jk  = DENS_ION[j,k]}',                                    $
                  'MAGF_GSE      :  [N,V,U]-Element [float] array of Avg. magnetic field vectors',        $
                  '                   used in the analysis [GSE, nT]',                                    $
                  '                   {Let:  Bo_jk  = MAGF_GSE[j,*,k]}',                                  $
                  'PLASMA_BETA   :  [N,U]-Element [float] array of Avg. total plasma betas used',         $
                  '                   {Let:  ßt_jk  = PLASMA_BETA[j,k]}',                                 $
                  '                   {where:  ßt_jk = (3/5)*Cs_jk^2/VA_jk^2 }',                          $
                  'SOUND_SPEED   :  [N,U]-Element [float] array of Avg. ion-acoustic sound speeds [km/s]',$
                  '                   {Let:  Cs_jk  = SOUND_SPEED[j,k]}',                                 $
                  '                   {where:  Cs_jk^2 = (5/3)*Wi_jk^2 }',                                $
                  'ALFVEN_SPEED  :  [N,U]-Element [float] array of Avg. Alfven speeds [km/s]',            $
                  '                   {Let:  VA_jk  = ALFVEN_SPEED[j,k]}',                                $
                  '                   {where:  VA_jk^2 = |Bo_jk|^2/(µ_o Mi Ni_jk) }'                      ]
;;  Define structure tags for "Best values of shock front normal for each method" table
bvn_info_descr = ['In the following, we define the structure tag values taken from the',                  $
                  '  "Best values of shock front normal for each method" table:',                         $
                  '',                                                                                     $
                  'SH_N_GSE  :  [N,V,M]-Element [float] array of shock normal unit vectors [GSE]',        $
                  '                   {Let:  n_jk  = SH_N_GSE[j,*,k]}',                                   $
                  'SH_N_THE  :  [N,M]-Element [float] array of spherical poloidal angles of n_jk [deg]',  $
                  'SH_N_PHI  :  [N,M]-Element [float] array of spherical azimuthal angles of n_jk [deg]'  ]
;;  Define structure tags for "Key shock parameters" table
key_info_descr = ['In the following, we define the structure tag values taken from the',                  $
                  '  "Key shock parameters" table:',                                                      $
                  '',                                                                                     $
                  'THETA_BN   :  [N,M]-Element [float] array of Avg. upstream shock normal angles [deg]', $
                  'VSHN_UP    :  [N,M]-Element [float] array of upstream shock normal speeds [km/s]',     $
                  '                  in the spacecraft frame of reference',                               $
                  '                   {Let:  Vshn_jm  = VSHN_UP[j,m]}',                                   $
                  'NIDN_NIUP  :  [N,M]-Element [float] array of shock compression ratios',                $
                  '                   {Let:  ∆_jm  = NIDN_NIUP[j,m]}',                                    $
                  '                   {where:  ∆_jm = Ni_j,down/Ni_j,up }'                                ]
;;  Define structure tags for "Upstream wave speeds and mach numbers" table
ups_info_descr = ['In the following, we define the structure tag values taken from the',                  $
                  '  "Upstream wave speeds and mach numbers" table:',                                     $
                  '',                                                                                     $
                  'USHN    :  [N,M]-Element [float] array of Avg. upstream shock normal speeds [km/s]',   $
                  '                  in the shock rest frame (i.e., upstream flow speed along n)',        $
                  '                   {Let:  Ushn_jm  = USHN[j,m]}',                                      $
                  '                   {where:  Ushn_jm = (Vsw_j,up . n_jm) - Vshn_jm }',                  $
                  'V_SLOW  :  [N,M]-Element [float] array of Avg. upstream MHD slow mode speed [km/s]',   $
                  '                   {Let:  Vs_jm  = V_SLOW[j,m]}',                                      $
                  'V_INTM  :  [N,M]-Element [float] array of Avg. upstream MHD intermediate',             $
                  '                  mode speed [km/s]',                                                  $
                  'V_FAST  :  [N,M]-Element [float] array of Avg. upstream MHD fast mode speed [km/s]',   $
                  '                   {Let:  Vf_jm  = V_FAST[j,m]}',                                      $
                  'M_SLOW  :  [N,M]-Element [float] array of Avg. upstream MHD slow mode Mach number',    $
                  '                   {Let:  Ms_jm  = M_SLOW[j,m]}',                                      $
                  '                   {where:  Ms_jm = |Ushn_jm|/Vs_jm }',                                $
                  'M_FAST  :  [N,M]-Element [float] array of Avg. upstream MHD fast mode Mach number',    $
                  '                   {Let:  Mf_jm  = M_FAST[j,m]}',                                      $
                  '                   {where:  Mf_jm = |Ushn_jm|/Vf_jm }'                                 ]
;;  Define structure tags for "Downstream wave speeds and mach numbers" table
dns_info_descr = ['In the following, we define the structure tag values taken from the',                  $
                  '  "Downstream wave speeds and mach numbers" table:',                                   $
                  '',                                                                                     $
                  'USHN    :  [N,M]-Element [float] array of Avg. downstream shock normal speeds [km/s]', $
                  '                  in the shock rest frame (i.e., downstream flow speed along n)',      $
                  '                   {Let:  Ushn_jm  = USHN[j,m]}',                                      $
                  '                   {where:  Ushn_jm = (Vsw_j,down . n_jm) - Vshn_jm }',                $
                  'V_SLOW  :  [N,M]-Element [float] array of Avg. downstream MHD slow mode speed [km/s]', $
                  '                   {Let:  Vs_jm  = V_SLOW[j,m]}',                                      $
                  'V_INTM  :  [N,M]-Element [float] array of Avg. downstream MHD intermediate',           $
                  '                  mode speed [km/s]',                                                  $
                  'V_FAST  :  [N,M]-Element [float] array of Avg. downstream MHD fast mode speed [km/s]', $
                  '                   {Let:  Vf_jm  = V_FAST[j,m]}',                                      $
                  'M_SLOW  :  [N,M]-Element [float] array of Avg. downstream MHD slow mode Mach number',  $
                  '                   {Let:  Ms_jm  = M_SLOW[j,m]}',                                      $
                  '                   {where:  Ms_jm = |Ushn_jm|/Vs_jm }',                                $
                  'M_FAST  :  [N,M]-Element [float] array of Avg. downstream MHD fast mode Mach number',  $
                  '                   {Let:  Mf_jm  = M_FAST[j,m]}',                                      $
                  '                   {where:  Mf_jm = |Ushn_jm|/Vf_jm }'                                 ]
;;  Define structure containing structure description information
top_tags       = ['GEN_INFO','ASY_INFO','BVN_INFO','KEY_INFO','UPS_INFO','DNS_INFO']
tags           = ['GENERAL_STATEMENT','PROMPT2PRINT','YES1ST','METHODS_DESCR',$
                  'TOP_LEV_TAGS','STRUCTURE_FORMATS',top_tags+'_DESCR']
descript_struc = CREATE_STRUCT(tags,out_geni_str,out_prom_str,yes_first_out,meths_descr,  $
                                    top_lev_tags,struc_form,gen_info_descr,asy_info_descr,$
                                    bvn_info_descr,key_info_descr,ups_info_descr,         $
                                    dns_info_descr)
;;----------------------------------------------------------------------------------------
;;  Create IDL save file
;;----------------------------------------------------------------------------------------
SAVE,cfa_db_wind,descript_struc,FILENAME=fname[0],VERBOSE=verbose
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END



