;+
;*****************************************************************************************
;
;  PROCEDURE:   print_dokuwiki_program_list.pro
;  PURPOSE  :   This routine prints out the dokuwiki program list of changes/additions to
;                 the original Wind/3DP TPLOT distribution.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               get_months_of_year.pro
;               read_gen_ascii.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  list_of_3DP-TPLOT_pros-changed.txt
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               print_dokuwiki_program_list
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Finished writing routine and cleaned up
;                                                                   [08/26/2013   v1.0.0]
;             2)  Forgot to remove a STOP statement and forgot to print all extra info
;                   for string_replace_char.pro
;                                                                   [08/27/2013   v1.0.0]
;             3)  Added new folders to LYNN_PRO directory
;                                                                   [08/12/2015   v1.1.0]
;
;   NOTES:      
;               1)  Do not change format of list_of_3DP-TPLOT_pros-changed.txt without
;                     changing this routine to accomodate the new format...
;               2)  Remember to change ___ to _**_**_ to avoid underlining in Dokuwiki
;                     syntax
;
;  REFERENCES:  
;               NA
;
;   CREATED:  08/26/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO print_dokuwiki_program_list

;;  Let IDL know that the following are functions
FORWARD_FUNCTION get_os_slash, get_months_of_year, read_gen_ascii
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()         ;;  '/' for Unix, '\' for Windows
;;  Define strings to find in file
cc_line        = ';;  '
line0          = ';;----------------------------------------------------------------------------------------'
date_ver0      = '; => '
last_list_s    = ';;  List of added crib sheets'  ;;  Use only lines before this one...
;;  Define section and subsection strings to find in file
sec_strs       = cc_line[0]+['Initialization and startup software',                   $
                 'List of added TPLOT routines for THEMIS ESA',                       $
                 'List of added particle beam fitting routines',                      $
                 'List of added numerical Rankine-Hugoniot solving routines',         $
                 'List of added ESA MCP analysis software',                           $
                 'List of added cold plasma parameter routines',                      $
                 'List of added wavelet and Fourier analysis routines',               $
                 'List of added minimum variance analysis routines',                  $
                 'List of general math routines',                                     $
                 'List of general plotting routines',                                 $
                 "List of routines that use Justin C. Kasper's CFA Shock Database",   $
                 'List of added date/time calculation routines',                      $
                 'List of added TPLOT-specific routines',                             $
                 'List of added shock-specific routines',                             $
                 'List of added time series manipulation routines',                   $
                 'List of added miscellaneous routines',                              $
                 'List of added Wind/WAVES Radio Receiver Routines'                   ]
sub_strs       = cc_line[0]+['Crib Sheets','Main Routine','Common Block Routines',    $
                 'Fit Wrapping Routines','General Routines','Plotting Routines',      $
                 'Prompting Routines','Supporting External Routines','Documentation', $
                 'List of added PESA Low calibration routines']
nsec           = N_ELEMENTS(sec_strs)
nsub           = N_ELEMENTS(sub_strs)

;;  Define directory location of file
dir_str        = '.'+slash[0]+'wind_3dp_pros'+slash[0]+'LYNN_PRO'+slash[0]
defdir         = FILE_EXPAND_PATH(dir_str[0])
;;  Define  input file name
fname__in      = 'list_of_3DP-TPLOT_pros-changed.txt'
;;  Define output file name
fname_out      = 'doku-wiki_UMN_3DP_Documentation_routines.txt'
;;  Define output strings
pro_pre_suf    = ['  - **','**']         ;;  String before and after routine names
des_pre_suf    = ['    - [',']  ']       ;;  String before and after routine date and version
sec_pre_suf    = ['==== ',' ====']       ;;  " " section divisions
sub_pre_suf    = ['=== ',' ===']         ;;  " " subsection divisions

sec_str_out    = STRMID(sec_strs[*],STRLEN(cc_line[0]))
sub_str_out    = STRMID(sub_strs[*],STRLEN(cc_line[0]))
sec_str_out    = sec_pre_suf[0]+sec_str_out+sec_pre_suf[1]
sub_str_out    = sub_pre_suf[0]+sub_str_out+sub_pre_suf[1]
;;----------------------------------------------------------------------------------------
;;  Define extra outputs
;;----------------------------------------------------------------------------------------
ex_pref_0      = 'This set of routines can be found in the //~/wind_3dp_pros/'
ex_pref_1      = ex_pref_0[0]+'LYNN_PRO/ //directory'
ex_pref_2      = ex_pref_0[0]+'THEMIS_PRO/ //directory'
ex_midn_0      = ' in the directory '

;;  Startup routines extra
stu_ex_out     = ex_pref_0[0]+' //'
;;  THEMIS routines extra
thm_ex_out     = ex_pref_2[0]+'.'
;;  Beam fitting intro extra
ion_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//beam_fitting_routines//.'
;;  Common block extra
com_ex_out     = 'These routines allow the user to interactively alter, retrieve, and '+$
                 'undefine common block variables used by this set of software.'
;;  Craig B. Markwardt's IDL extra
cow_ex_out     = "The following routines are part of Craig B. Markwardt's IDL "+$
                 "library found at:  "+$
                 "[[http://cow.physics.wisc.edu/~craigm/idl/idl.html|Cow Physics]]"
;;  numerical Rankine-Hugoniot solving routines extra
rhs_ex_out     = "Software for numerically solving the Rankine-Hugoniot conservation relations and numerically estimating the critical Mach number can be found at:  [[umn_wind3dp_downloads|UMN 3DP Downloads]]"
;;  ESA MCP analysis routines extra
mcp_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//esa_mcp_software//.'
;;  PESA Low calibration routines extra
plc_ex_out     = ex_pref_0[0]+'LYNN_PRO/esa_mcp_software/ //directory'+ex_midn_0[0]
plc_ex_out     = plc_ex_out[0]+'//pesa_low_calibration//.'
;;  cold plasma routines extra
clp_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//cold_plasma_pros//.'
;;  wavelet and Fourier analysis routines extra
wvl_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//wvlt_Fourier_routines//.'
;;  minimum variance analysis routines extra
mva_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//Minimum_Variance_Analysis//.'
;;  general math routines extra
gnm_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//general_math//.'
;;  general plotting routines extra
gnp_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//plotting_routines//.'
;;  Justin C. Kasper's database routines extra
JCK_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//JCKs_database_routines//.'
;;  date/time calculation routines extra
dtt_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//date_time_routines//.'
;;  TPLOT-specific routines extra
tpt_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//tplot_routines//.'
;;  shock-specific routines extra
shk_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//shock_calc_routines//.'
;;  time series manipulation routines extra
t_s_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//time_series_routines//.'
;;  miscellaneous routines extra
mis_ex_out     = ex_pref_1[0]+'.'
;;  string_replace_char.pro extra
src_ex_out     = ["However, we do not want to do this by hand iteratively, so we are"+$
                  " lazy and use this program in the following way: <code idl>",      $
                  "    strs     = '2001-11-14/01:14:06.127 UT'",                      $
                  "    old_char = '/'",                                               $
                  "    new_char = ' '",                                               $
                  "    new_strs = string_replace_char(strs,old_char,new_char)",       $
                  "    old_char = '-'",                                               $
                  "    new_char = '/'",                                               $
                  "    new_str2 = string_replace_char(new_strs,old_char,new_char)",   $
                  "    PRINT,new_str2",                                               $
                  ";    2001/11/14 01:14:06.127 UT",                                  $
                  "</code>"                                                           ]
;;  Wind/WAVES Radio Receiver routines extra
wav_ex_out     = ex_pref_1[0]+ex_midn_0[0]+'//Wind_WAVES_routines//.'
;;  Define output structure
jstr           = 'T'+STRING(LINDGEN(nsec),FORMAT='(I3.3)')
ex_out_str     = CREATE_STRUCT(jstr,stu_ex_out[0],thm_ex_out[0],             $
                               [ion_ex_out[0],com_ex_out[0],cow_ex_out[0]],  $
                               rhs_ex_out[0],[mcp_ex_out[0],plc_ex_out[0]],  $
                               clp_ex_out[0],wvl_ex_out[0],mva_ex_out[0],    $
                               gnm_ex_out[0],gnp_ex_out[0],JCK_ex_out[0],    $
                               dtt_ex_out[0],tpt_ex_out[0],shk_ex_out[0],    $
                               t_s_ex_out[0],                                $
                               [mis_ex_out[0],src_ex_out[*]],wav_ex_out[0]   )
;;----------------------------------------------------------------------------------------
;;  Get months of year strings
;;----------------------------------------------------------------------------------------
months         = get_months_of_year()
umonth_3l      = months.MONTH_3LETTERS
months_3l      = STRLOWCASE(umonth_3l)
nm             = N_ELEMENTS(months_3l)
m_str          = '*'+date_ver0[0]+months_3l
;;----------------------------------------------------------------------------------------
;;  Define character positions of relevance
;;----------------------------------------------------------------------------------------
sc__loc        = 38L                          ;;  chars before '; => ' and date specification
mon_loc        = 46L                          ;;  chars before, e.g., 'aug' in date specification
des_loc        = 68L
date_spec      = [43L,14L]                    ;;  chars to define date specification
vers_spec      = [60L, 8L]                    ;;  chars to define version specification
;;----------------------------------------------------------------------------------------
;;  Find list file and read in
;;----------------------------------------------------------------------------------------
gfile          = FILE_SEARCH(defdir[0],fname__in[0])
flines         = read_gen_ascii(gfile[0],/REMOVE_NULL)
;;  Find element of last relevant line
test           = (flines EQ last_list_s[0])
g_last_l       = WHERE(test,gll)
IF (gll EQ 0) THEN BEGIN
  MESSAGE,'Incorrect file read in...',/INFORMATIONAL,/CONTINUE
  RETURN            ;;  Wrong file read in...
ENDIF
;;  Redefine relevant lines
gind           = g_last_l[0] - 1L
flines         = flines[0L:gind[0]]
nl             = N_ELEMENTS(flines)
lc_lines       = STRLOWCASE(flines)
;;----------------------------------------------------------------------------------------
;;  Define different parts of ASCII file strings
;;----------------------------------------------------------------------------------------
;;  Define character length of each line
f_strlen       = STRLEN(flines)
;;  Find ';;----------------------------------------------------------------------------------------'
test           = (flines EQ line0[0])
gline          = WHERE(test,gl)
;;  Find ';;  '
test           = (STRMID(flines,0L,4L) EQ cc_line[0])
cline          = WHERE(test,cl)
;;  The following include lines that are not associated with routines...
s_flines       = STRMID(lc_lines,0L,mon_loc[0])  ;;  Cut off after month specification
b_flines       = STRMID(lc_lines,0L,sc__loc[0])  ;;  Cut off before date and version specification
;;  Date specification [e.g., 'Aug.  26, 2013']
d_flines       = STRMID(flines,date_spec[0],date_spec[1])
;;  Version specification [e.g., 'v1.5.2']
v_flines       = STRTRIM(STRMID(lc_lines,vers_spec[0],vers_spec[1]),2L)
;;  Routine description
descript_str   = STRMID(flines,des_loc[0])
;;----------------------------------------------------------------------------------------
;;  Define routine descriptions
;;----------------------------------------------------------------------------------------
;;  Remove leading and trailing brackets
descript_str   = STRMID(descript_str[*],1L)
des_slen       = STRLEN(descript_str)
nds            = N_ELEMENTS(descript_str)
FOR j=0L, nds - 1L DO BEGIN
  IF (des_slen[j] GT 0) THEN descript_str[j] = STRMID(descript_str[j],0L,des_slen[j] - 1L)
  IF (des_slen[j] EQ 0) THEN descript_str[j] = ''
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Determine lines for routine output
;;----------------------------------------------------------------------------------------
g_sline        = BYTARR(nl,nm)
FOR j=0L, nm - 1L DO g_sline[*,j] = STRMATCH(s_flines,m_str[j],/FOLD_CASE)
;;  The following will include the bash and all IDL routines
l_inds         = ARRAY_INDICES(g_sline,WHERE(g_sline))
all_probash    = REFORM(l_inds[0L,*])
sp             = SORT(all_probash)
all_probash    = all_probash[sp]
n_all_pro      = N_ELEMENTS(all_probash)
;;  Careful, the following will not include the bash routines
posi_pro       = STRPOS(b_flines,'.pro')
pro_lines      = WHERE(posi_pro GE 0,pl)
;;----------------------------------------------------------------------------------------
;;  Determine lines for different sections and subsections
;;----------------------------------------------------------------------------------------
sec_line       = BYTARR(nl,nsec)
sub_line       = BYTARR(nl,nsub)
FOR j=0L, nsec - 1L DO sec_line[*,j] = STRMATCH(flines,sec_strs[j],/FOLD_CASE)
FOR j=0L, nsub - 1L DO sub_line[*,j] = STRMATCH(flines,sub_strs[j],/FOLD_CASE)
;;  Determine specific lines
sec_inds       = ARRAY_INDICES(sec_line,WHERE(sec_line))
sub_inds       = ARRAY_INDICES(sub_line,WHERE(sub_line))
sec_gind       = REFORM(sec_inds[0L,*])
sub_gind       = REFORM(sub_inds[0L,*])
;;  Add last element as ending boundary
sec_gind       = [sec_gind,MAX(all_probash,/NAN)]
;;  Sort
sp             = SORT(sec_gind)
sec_gind       = sec_gind[sp]
sp             = SORT(sub_gind)
sub_gind       = sub_gind[sp]
;;  Determine upper bound for subsections
test           = (sec_gind - MAX(sub_gind,/NAN)) GT 0
g_upper        = WHERE(test,gup)
;;  Add last element as ending boundary
sub_gind       = [sub_gind,sec_gind[g_upper[0]]]
;;----------------------------------------------------------------------------------------
;;  Determine which routines belong in which sections and subsections
;;----------------------------------------------------------------------------------------
x_dn           = LINDGEN(nsec)
x_up           = x_dn + 1L
bound_sec      = [[sec_gind[x_dn]],[sec_gind[x_up]]]
x_dn           = LINDGEN(nsub)
x_up           = x_dn + 1L
bound_sub      = [[sub_gind[x_dn]],[sub_gind[x_up]]]

gind_sec       = REPLICATE(-1L,nsec,2)       ;;  Range of elements of routines in sections
gind_sub       = REPLICATE(-1L,nsec,nsub,2)  ;;  Range of elements of routines in subsections
nind_sec       = REPLICATE(0L,nsec)          ;;  # of elements in each section
nind_sub       = REPLICATE(0L,nsec,nsub)     ;;  # of elements in each subsection
all_sub_strs   = REPLICATE('',nsec,nsub)     ;;  All the subsection header strings

cc             = 0L
FOR j=0L, nsec - 1L DO BEGIN
  temp = REFORM(bound_sec[j,*])
  test = (all_probash GE temp[0]) AND (all_probash LE temp[1])
  good = WHERE(test,gd)
  IF (gd GT 0) THEN gind = [MIN(good,/NAN),MAX(good,/NAN)] ELSE gind = [-1,-1]
  gind_sec[j,*] = gind
  ;;--------------------------------------------------------------------------------------
  ;;  Check for subsection interval
  ;;--------------------------------------------------------------------------------------
  IF (gd GT 0) THEN BEGIN
    t_nn  = temp[1] - temp[0] + 1L
    ginds = LINDGEN(t_nn) + temp[0]
    sinds = REFORM(bound_sub[*,0])
    tsub  = (sinds GE temp[0]) AND (sinds LE temp[1])
    gsub  = WHERE(tsub,gb)
    IF (gb GT 0) THEN BEGIN
      temp_sub = REFORM(bound_sub[gsub,*]) < MAX(temp,/NAN)
      FOR k=0L, gb - 1L DO BEGIN
        ;;  Define subsection header string
        all_sub_strs[j,gsub[k]] = sub_str_out[cc]
        ;;  Increment subsection header string counter
        cc                     += 1L
        IF (gb GT 1L) THEN BEGIN
          test_sub = (all_probash GE temp_sub[k,0]) AND (all_probash LE temp_sub[k,1])
        ENDIF ELSE BEGIN
          test_sub = (all_probash GE temp_sub[0]) AND (all_probash LE temp_sub[1])
        ENDELSE
        good_sub = WHERE(test_sub,gdsub)
        IF (gd GT 0) THEN gindsub = [MIN(good_sub,/NAN),MAX(good_sub,/NAN)] ELSE gindsub = [-1,-1]
        gind_sub[j,gsub[k],*] = gindsub
        diff     = (gindsub[1] - gindsub[0])
        IF (gindsub[0] GE 0) THEN nind_sub[j,gsub[k]] = diff[0] + 1L
      ENDFOR
    ENDIF
  ENDIF
ENDFOR
;;  Define # of elements in each section and subsection
nind_sec       = (gind_sec[*,1] - gind_sec[*,0]) + 1L
;;----------------------------------------------------------------------------------------
;;  Define routine names, descriptions, dates and version specifications
;;----------------------------------------------------------------------------------------
;;  Routine names
all_pro_nms    = STRTRIM(b_flines[all_probash],2L)
;;  Routine descriptions
all_des_nms    = STRTRIM(descript_str[all_probash],2L)
;;  Routine dates
all_dat_nms    = STRTRIM(d_flines[all_probash],2L)  ;;  e.g., 'Aug.  26, 2013'
;;  Routine versions
all_ver_nms    = STRTRIM(v_flines[all_probash],2L)  ;;  e.g., 'v1.5.2'
;;----------------------------------------------------------------------------------------
;;  Define string outputs
;;----------------------------------------------------------------------------------------
;;  Routine names
all_pro_out    = pro_pre_suf[0]+all_pro_nms+pro_pre_suf[1]
;;  Routine dates and versions
all_dvs_out    = des_pre_suf[0]+all_dat_nms+'   '+all_ver_nms+des_pre_suf[1]
;;  Routine dates, versions, and descriptions
all_des_out    = all_dvs_out+all_des_nms

PRINT, ''
PRINT,'Printing file:  ', fname_out[0]
;;----------------------------------------------------------------------------------------
;;  Open output file
;;----------------------------------------------------------------------------------------
OPENW,gunit,fname_out[0],ERROR=err,/GET_LUN
;;  Print to output file
  FOR j=0L, nsec - 1L DO BEGIN
    ;;  Define outputs for this section
    t_sec_ind   = REFORM(gind_sec[j,*])
    tr_sec_inds = all_probash[t_sec_ind]
    t_gind_sec  = LINDGEN(nind_sec[j]) + MIN(t_sec_ind,/NAN)
    n_sub_ind   = REFORM(nind_sub[j,*])
    test_sub    = TOTAL(n_sub_ind) EQ 0
    ;;  Define routine outputs for this section
    out_pro_sec = all_pro_out[t_gind_sec]
    out_des_sec = all_des_out[t_gind_sec]
    ;;  Define extra outputs for this section
    ex__out_sec = ex_out_str.(j)
    n_ex_out    = N_ELEMENTS(ex__out_sec)
    test_ex_out = (n_ex_out GT 1)
    ;;------------------------------------------------------------------------------------
    ;;  Print out section separator
    ;;------------------------------------------------------------------------------------
    PRINTF,gunit,sec_str_out[j]
    ;;  Print out initial extra info
    PRINTF,gunit,ex__out_sec[0]
    CASE test_sub[0] OF
      1    :  BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  No subsections
        ;;--------------------------------------------------------------------------------
        ;;  Print out routine and descriptions
        FOR i=0L, nind_sec[j] - 1L DO BEGIN
          test_str = (all_pro_nms[t_gind_sec[i]] EQ 'string_replace_char.pro')
          FOR pd=0L, 1L DO BEGIN
            IF (pd EQ 0) THEN out_put = out_pro_sec[i] ELSE out_put = out_des_sec[i]
            IF (test_str AND pd EQ 1) THEN BEGIN
              ;;  Print out string_replace_char.pro extra output
              FOR exi=1L, n_ex_out - 1L DO BEGIN
                IF (exi EQ 1) THEN out_put = out_put[0]+ex__out_sec[exi] ELSE out_put = ex__out_sec[exi]
                PRINTF,gunit,out_put[0]
              ENDFOR
            ENDIF ELSE BEGIN
              ;;  Print out one line
              PRINTF,gunit,out_put[0]
            ENDELSE
          ENDFOR
        ENDFOR
      END
      ELSE :  BEGIN
        ;;--------------------------------------------------------------------------------
        ;;  Subsections present
        ;;--------------------------------------------------------------------------------
        t_good_sub  = WHERE(n_sub_ind GT 0,gdsub)
        n_subind    = n_sub_ind[t_good_sub]
        t_sub_inds  = REFORM(gind_sub[j,t_good_sub,*])
        t_sub_hout  = REFORM(all_sub_strs[j,t_good_sub])
        ;;  Check to see if routines come before any subsections
        tr_sub_inds = all_probash[t_sub_inds]
        test_rbef   = (MIN(tr_sec_inds,/NAN) LT MIN(tr_sub_inds,/NAN))
        i           = 0L
        FOR k=0L, gdsub - 1L DO BEGIN
          t_sub_ind   = REFORM(t_sub_inds[k,*])
          n_sub       = n_subind[k]
          t_hout      = t_sub_hout[k]
          IF (test_rbef) THEN BEGIN
            ;;----------------------------------------------------------------------------
            ;;  Routines come first
            ;;----------------------------------------------------------------------------
            n_bef_pro  = nind_sec[j] - n_sub[0]
;            PRINT,'n_bef_pro  = ', n_bef_pro
            FOR i=0L, n_bef_pro - 1L DO BEGIN
              FOR pd=0L, 1L DO BEGIN
                IF (pd EQ 0) THEN out_put = out_pro_sec[i] ELSE out_put = out_des_sec[i]
                PRINTF,gunit,out_put[0]
              ENDFOR
            ENDFOR
            ;;  Print out subsection header
            PRINTF,gunit,t_hout[0]
            test_str = (t_hout[0] EQ '=== List of added PESA Low calibration routines ===')
            IF (test_str) THEN PRINTF,gunit,ex__out_sec[1]
            ;;  Print out routines and descriptions
            FOR is=0L, n_sub - 1L DO BEGIN
              FOR pd=0L, 1L DO BEGIN
                IF (pd EQ 0) THEN out_put = out_pro_sec[i] ELSE out_put = out_des_sec[i]
                PRINTF,gunit,out_put[0]
              ENDFOR
              ;;  increment i
              i += 1L
            ENDFOR
          ENDIF ELSE BEGIN
            ;;----------------------------------------------------------------------------
            ;;  Subsections come first
            ;;----------------------------------------------------------------------------
            ;;  Print out subsection header
            PRINTF,gunit,t_hout[0]
            ;;  Print out routines and descriptions
            test_str = (t_hout[0] EQ '=== Common Block Routines ===')
            IF (test_str) THEN PRINTF,gunit,ex__out_sec[1]
            test_str = (t_hout[0] EQ '=== Supporting External Routines ===')
            IF (test_str) THEN PRINTF,gunit,ex__out_sec[2]
            FOR is=0L, n_sub - 1L DO BEGIN
              FOR pd=0L, 1L DO BEGIN
                IF (pd EQ 0) THEN out_put = out_pro_sec[i] ELSE out_put = out_des_sec[i]
                PRINTF,gunit,out_put[0]
              ENDFOR
              ;;  increment i
              i += 1L
            ENDFOR
          ENDELSE
        ENDFOR
      END
    ENDCASE
  ENDFOR
;;----------------------------------------------------------------------------------------
;;  Close output file
;;----------------------------------------------------------------------------------------
FREE_LUN,gunit
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
