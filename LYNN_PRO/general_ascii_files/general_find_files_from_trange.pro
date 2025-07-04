;+
;*****************************************************************************************
;
;  FUNCTION :   general_find_files_from_trange.pro
;  PURPOSE  :   This is meant to be a generalized routine that finds all files within
;                 a given time range or on a specific date, given either and optionally
;                 a file prefix.  The routine will require the base search directory
;                 and the format of the date in the file name.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_os_slash.pro
;               is_a_number.pro
;               get_valid_trange.pro
;               doy_to_month_date.pro
;               time_double.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               BASE_DIR   :  Scalar [string] defining the base directory in which to
;                               start searching for the user desired files
;               DATE_FORM  :  Scalar [string] defining the format of the dates used to
;                               name the files, which must contain the characters:
;                                 'Y'    :  year specification, e.g., 'YY' for 2 character
;                                           years or 'YYYY' for full year specification
;                                 'M'    :  month specification, e.g., 'YY' for 2
;                                           character months
;                                 'D'    :  day of month specification, e.g., 'MM' for 2
;                                           character days
;                               or if the file name is defined by day of year, then:
;                                 'Y'    :  year specification, e.g., 'YY' for 2 character
;                                           years or 'YYYY' for full year specification
;                                 'DOY'  :  doy of year specification as 3 character
;                                           string representation of the number
;                               The allowed year, month, and day forms include:
;                                 [*** can interchange '-' or '_' with ' ' ***]
;                                 'YYYY-MM-DD'
;                                 'YYYY_MM_DD'
;                                 'YYYY-DD-MM'
;                                 'YYYY_DD_MM'
;                                 'MM-DD-YYYY'
;                                 'MM_DD_YYYY'
;                                 'DD-MM-YYYY'
;                                 'DD_MM_YYYY'
;                                 'YYYYMMDD'
;                                 'YYYYDDMM'
;                                 'MMDDYYYY'
;                                 'DDMMYYYY'
;                                 'YY-MM-DD'
;                                 'YY_MM_DD'
;                                 'YY-DD-MM'
;                                 'YY_DD_MM'
;                                 'MM-DD-YY'
;                                 'MM_DD_YY'
;                                 'DD-MM-YY'
;                                 'DD_MM_YY'
;                                 'YYMMDD'
;                                 'YYDDMM'
;                                 'MMDDYY'
;                                 'DDMMYY'
;                               The allowed DOY forms include:
;                                 'YYYY-DOY'
;                                 'YYYY_DOY'
;                                 'DOY-YYYY'
;                                 'DOY_YYYY'
;                                 'DOYYYYY'
;                                 'YYYYDOY'
;                                 'YY-DOY'
;                                 'YY_DOY'
;                                 'DOY-YY'
;                                 'DOY_YY'
;                                 'DOYYY'
;                                 'YYDOY'
;
;  EXAMPLES:    
;               [calling sequence]
;               files = general_find_files_from_trange(base_dir, date_form [,TDATE=tdate] $
;                                                 [,TRANGE=trange] [,FILE_PREF=file_pref] $
;                                                 [,FILE_SUFF=file_suff])
;
;  KEYWORDS:    
;               TDATE      :  Scalar [string] defining the date of interest of the form:
;                               'YYYY-MM-DD' [MM=month, DD=day, YYYY=year]
;                               [Default = prompted by get_valid_trange.pro]
;               TRANGE     :  [2]-Element [double] array specifying the Unix time
;                               range for which to limit the data in DATA
;                               [Default = prompted by get_valid_trange.pro]
;               FILE_PREF  :  Scalar [string] defining a file prefix to use to filter
;                               results when searching for the user desired files
;                               [Default = '*']
;               FILE_SUFF  :  Scalar [string] defining the file name extension to use to
;                               filter results when searching for the user desired files.
;                               Do not include the '.' character, as that will be added
;                               within the routine automatically.
;                               [Default = '*']
;               IGNORE_2D  :  If set, routine will ignore any 2nd dates within file name
;                               (e.g., sometimes date of creation is added for versions)
;                               [Default = FALSE]
;
;   CHANGED:  1)  Fixed an issue when only TDATE is set (odd that this did not occur
;                   before... must be a rounding error issue in new version of time_*
;                   routines for SPEDAS update)
;                                                                   [10/12/2016   v1.1.0]
;             2)  Fixed an issue when TRANGE starts and/or ends in middle of a day
;                                                                   [11/11/2016   v1.2.0]
;             3)  Prevent TDATE from taking precedence over TRANGE if both are set
;                                                                   [12/07/2018   v1.2.1]
;             4)  Fixed a potential issue that arises when only TDATE is set
;                   (not actually a problem herein, but may be one in above level)
;                                                                   [05/01/2019   v1.2.2]
;             5)  Added keyword:  IGNORE_2D
;                                                                   [10/29/2021   v1.2.3]
;
;   NOTES:      
;               1)  *** DOY specification must be 3 characters ***
;                   --> not currently handling variable file name lengths for DOY forms
;               2)  *** MM and DD specifications must be 2 characters ***
;                   --> not currently handling variable file name lengths for year,
;                       month, and day forms
;               3)  The '-' and '_' separator characters can also be a ' ' space as an
;                     allowable form
;               4)  Do not include the '*' character in either the FILE_PREF or FILE_SUFF
;                     keywords, as the routine will do that for you
;               5)  CDF files from CDAWeb (should) have a date format matching:
;                     'YYYYMMDD'
;                   The ASCII orbit files in
;                     ~/wind_3dp_pros/wind_data_dir/Wind_Orbit_Data/
;                   have a date format matching:
;                     'MM-DD-YYYY'
;                   The LZ 3DP files in
;                     ~/wind_3dp_pros/wind_data_dir/data1/wind/3dp/lz/yyyy/
;                   have a date format matching:
;                     'YYYYMMDD'
;                   The 3DP IDL save files in
;                     ~/wind_3dp_pros/wind_data_dir/Wind_3DP_DATA/IDL_Save_Files/
;                   have a date format matching:
;                     'YYYY-MM-DD'
;               6)  For formats with 2 character years, routine assumes any year less
;                     70 must correspond to dates after Dec. 31, 1999
;
;  REFERENCES:  
;               NA
;
;   CREATED:  04/08/2016
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/29/2021   v1.2.3
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION general_find_files_from_trange,base_dir,date_form,TDATE=tdate,TRANGE=trange,$
                                        FILE_PREF=file_pref,FILE_SUFF=file_suff,     $
                                        IGNORE_2D=ignore_2d

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
all_sep_str    = ['','-','_',' ']
;;  Default time-related values
start_of_day   = '00:00:00.000'
end___of_day   = '23:59:59.999'
str_19_20      = ['19','20']
;;  Base strings for date formats
year_2_4       = ['YY','YYYY']
mons_2         = 'MM'
days_2         = 'DD'
doy__3         = 'DOY'
md_all         = mons_2[0]+all_sep_str+days_2[0]
dm_all         = days_2[0]+all_sep_str+mons_2[0]
;;  All 2 character year YMD forms
ymdb2_first    = year_2_4[0]+all_sep_str
ymdb2__last    = all_sep_str+year_2_4[0]
ydmb2_first    = year_2_4[0]+all_sep_str
ydmb2__last    = all_sep_str+year_2_4[0]
;;  All 4 character year YMD forms
ymdb4_first    = year_2_4[1]+all_sep_str
ymdb4__last    = all_sep_str+year_2_4[1]
ydmb4_first    = year_2_4[1]+all_sep_str
ydmb4__last    = all_sep_str+year_2_4[1]
;;  All 2 character year DOY forms
y2doy_first    = year_2_4[0]+all_sep_str
y2doy__last    = all_sep_str+year_2_4[0]
;;  All 4 character year DOY forms
y4doy_first    = year_2_4[1]+all_sep_str
y4doy__last    = all_sep_str+year_2_4[1]
FOR cc=0L, 3L DO BEGIN
  ;;  All 2 character year YMD forms
  ymdb2_first[cc]    = ymdb2_first[cc]+md_all[cc]
  ydmb2_first[cc]    = ydmb2_first[cc]+dm_all[cc]
  ymdb2__last[cc]    = md_all[cc]+ymdb2__last[cc]
  ydmb2__last[cc]    = dm_all[cc]+ydmb2__last[cc]
  ;;  All 4 character year YMD forms
  ymdb4_first[cc]    = ymdb4_first[cc]+md_all[cc]
  ydmb4_first[cc]    = ydmb4_first[cc]+dm_all[cc]
  ymdb4__last[cc]    = md_all[cc]+ymdb4__last[cc]
  ydmb4__last[cc]    = dm_all[cc]+ydmb4__last[cc]
  ;;  All 2 character year DOY forms
  y2doy_first[cc]    = y2doy_first[cc]+doy__3[0]
  y2doy__last[cc]    = doy__3[0]+y2doy__last[cc]
  ;;  All 4 character year DOY forms
  y4doy_first[cc]    = y4doy_first[cc]+doy__3[0]
  y4doy__last[cc]    = doy__3[0]+y4doy__last[cc]
ENDFOR
;;  All 2 and 4 character year YMD forms
all_y2md_forms = [ymdb2_first,ymdb2__last]
all_y2dm_forms = [ydmb2_first,ydmb2__last]
all_y4md_forms = [ymdb4_first,ymdb4__last]
all_y4dm_forms = [ydmb4_first,ydmb4__last]
;;  All 2 and 4 character year DOY forms
all_y2doy_form = [y2doy_first,y2doy__last]
all_y4doy_form = [y4doy_first,y4doy__last]
;;  Define all offsets for STRMID.PRO (i.e., offsets and lengths)
all_y2md_off_y = [0L,0L,0L,0L,4L,6L,6L,6L]
all_y2md_off_m = [2L,3L,3L,3L,0L,0L,0L,0L]
all_y2md_off_d = [4L,6L,6L,6L,2L,3L,3L,3L]
all_y2dm_off_y = [0L,0L,0L,0L,4L,6L,6L,6L]
all_y2dm_off_m = [4L,6L,6L,6L,2L,3L,3L,3L]
all_y2dm_off_d = [2L,3L,3L,3L,0L,0L,0L,0L]
all_y4md_off_y = [0L,0L,0L,0L,4L,6L,6L,6L]
all_y4md_off_m = [4L,5L,5L,5L,0L,0L,0L,0L]
all_y4md_off_d = [6L,8L,8L,8L,2L,3L,3L,3L]
all_y4dm_off_y = [0L,0L,0L,0L,4L,6L,6L,6L]
all_y4dm_off_m = [6L,8L,8L,8L,2L,3L,3L,3L]
all_y4dm_off_d = [4L,5L,5L,5L,0L,0L,0L,0L]
all_y2doy_offy = [0L,0L,0L,0L,3L,4L,4L,4L]
all_y2doy_offd = [2L,3L,3L,3L,0L,0L,0L,0L]
all_y4doy_offy = [0L,0L,0L,0L,3L,4L,4L,4L]
all_y4doy_offd = [4L,5L,5L,5L,0L,0L,0L,0L]
;;  Define all character lengths for STRMID.PRO (i.e., offsets and lengths)
all_y4_len_y   = REPLICATE(4L,N_ELEMENTS(all_y2md_forms))
all_y2_len_y   = REPLICATE(2L,N_ELEMENTS(all_y4md_forms))
all_doy_lens   = REPLICATE(3L,N_ELEMENTS(all_y2doy_form))
all_mon_lens   = REPLICATE(2L,N_ELEMENTS(all_y4md_forms))
all_day_lens   = REPLICATE(2L,N_ELEMENTS(all_y4md_forms))
all_zero_len   = REPLICATE(0L,N_ELEMENTS(all_y4md_forms))
;;  Define single arrays for which to match
all_date_forms = STRLOWCASE([all_y2md_forms,all_y2dm_forms,all_y4md_forms,all_y4dm_forms,$
                             all_y2doy_form,all_y4doy_form])
all_separators = [all_sep_str,all_sep_str,all_sep_str,all_sep_str,all_sep_str,all_sep_str,$
                  all_sep_str,all_sep_str,all_sep_str,all_sep_str,all_sep_str,all_sep_str]
all_yr_offsets = [all_y2md_off_y,all_y2dm_off_y,all_y4md_off_y,all_y4dm_off_y,$
                  all_y2doy_offy,all_y4doy_offy]
all_yr_lengths = [all_y2_len_y,all_y2_len_y,all_y4_len_y,all_y4_len_y,$
                  all_y2_len_y,all_y4_len_y]
all_mm_offsets = [all_y2md_off_m,all_y2dm_off_m,all_y4md_off_m,all_y4dm_off_m,$
                  all_zero_len,all_zero_len]
all_mm_lengths = [all_mon_lens,all_mon_lens,all_mon_lens,all_mon_lens,$
                  all_zero_len,all_zero_len]
all_dd_offsets = [all_y2md_off_d,all_y2dm_off_d,all_y4md_off_d,all_y4dm_off_d,$
                  all_y2doy_offd,all_y4doy_offd]
all_dd_lengths = [all_day_lens,all_day_lens,all_day_lens,all_day_lens,$
                  all_doy_lens,all_doy_lens]
doy_gind0      = WHERE(all_date_forms EQ STRLOWCASE(all_y2doy_form[0]))
;;  Error messages
noinput_mssg   = 'User must supply a base directory and a date format...'
incorrf_mssg   = 'Incorrect input format:  BASE_DIR and DATE_FORM must be scalar strings...'
notdir__mssg   = 'Incorrect input format:  BASE_DIR must be a valid directory path to an existing directory...'
baddfor_mssg   = 'Incorrect input format:  DATE_FORM must match an acceptable date format (see Man. page for examples)...'
nofiles_mssg   = 'No files were found in BASE_DIR...'
baddform_msg   = 'Incorrect date format:  DATE_FORM must match the date format in the file name...'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2)
IF (test[0]) THEN BEGIN
  MESSAGE,noinput_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (SIZE(base_dir,/TYPE) NE 7) OR (SIZE(date_form,/TYPE) NE 7)
IF (test[0]) THEN BEGIN
  MESSAGE,incorrf_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check if BASE_DIR is an actual directory
test           = (FILE_TEST(base_dir[0],/DIRECTORY) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,notdir__mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Check if DATE_FORM matches an acceptible format
dform          = STRLOWCASE(STRTRIM(date_form[0],2L))
good           = WHERE(all_date_forms EQ dform[0],gd)
IF (gd[0] EQ 0) THEN BEGIN
  MESSAGE,baddfor_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define regular expression to find file date formats
;;----------------------------------------------------------------------------------------
;;  Define associated character lengths and offsets
doy_on         = (good[0] GE doy_gind0[0])
yy_len_off     = [all_yr_lengths[good[0]],all_yr_offsets[good[0]]]
mm_len_off     = [all_mm_lengths[good[0]],all_mm_offsets[good[0]]]
dd_len_off     = [all_dd_lengths[good[0]],all_dd_offsets[good[0]]]
yy2ch_on       = (yy_len_off[0] EQ 2L)
yy1st_on       = (yy_len_off[1] LT dd_len_off[1])
mm1st_on       = (mm_len_off[1] LT dd_len_off[1])
g_sep_char     = all_separators[good[0]]
regex_yy       = '([0-9]){'+STRTRIM(STRING(yy_len_off[0],FORMAT='(I)'),2)+'}'
regex_mm       = '([0-9]){'+STRTRIM(STRING(mm_len_off[0],FORMAT='(I)'),2)+'}'
regex_dd       = '([0-9]){'+STRTRIM(STRING(dd_len_off[0],FORMAT='(I)'),2)+'}'
test_sep       = (g_sep_char[0] EQ '')
IF (test_sep[0]) THEN regex_sep = '' ELSE regex_sep = '('+g_sep_char[0]+'){1}'
IF (doy_on[0]) THEN BEGIN
  ;;  DOY format --> ignore months
  CASE 1 OF
    yy1st_on[0]  :  regex = regex_yy[0]+regex_sep[0]+regex_dd[0]
    ELSE         :  regex = regex_dd[0]+regex_sep[0]+regex_yy[0]
  ENDCASE
ENDIF ELSE BEGIN
  ;;  YMD format --> keep months
  CASE 1 OF
    yy1st_on[0]  :  BEGIN
      CASE 1 OF
        mm1st_on[0]  :  regex = regex_yy[0]+regex_sep[0]+regex_mm[0]+regex_sep[0]+regex_dd[0]
        ELSE         :  regex = regex_yy[0]+regex_sep[0]+regex_dd[0]+regex_sep[0]+regex_mm[0]
      ENDCASE
    END
    ELSE         :  BEGIN
      CASE 1 OF
        mm1st_on[0]  :  regex = regex_mm[0]+regex_sep[0]+regex_dd[0]+regex_sep[0]+regex_yy[0]
        ELSE         :  regex = regex_dd[0]+regex_sep[0]+regex_mm[0]+regex_sep[0]+regex_yy[0]
      ENDCASE
    END
  ENDCASE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check TDATE and TRANGE
test           = ((N_ELEMENTS(tdate) GT 0) AND (SIZE(tdate,/TYPE) EQ 7)) OR $
                 ((N_ELEMENTS(trange) EQ 2) AND is_a_number(trange,/NOMSSG))
IF (test[0]) THEN BEGIN
  ;;  At least one is set --> use that one
  testd          = ((N_ELEMENTS(tdate) GT 0) AND (SIZE(tdate,/TYPE) EQ 7))
  testt          = (N_ELEMENTS(trange) EQ 2) AND is_a_number(trange,/NOMSSG)
  IF (testd[0] AND testt[0]) THEN BEGIN
    ;;  Both are set --> use both
    time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange,PREC=3)
  ENDIF ELSE BEGIN
    ;;  Only one is set --> use that one
    IF (testd[0]) THEN time_ra = get_valid_trange(TDATE=tdate,TRANGE=trange,PREC=3) ELSE time_ra = get_valid_trange(TDATE=tdate,TRANGE=trange,PREC=3)
;    IF (testd[0]) THEN time_ra = get_valid_trange(TDATE=tdate,PREC=3) ELSE time_ra = get_valid_trange(TRANGE=trange,PREC=3)
  ENDELSE
;  test           = ((N_ELEMENTS(tdate) GT 0) AND (SIZE(tdate,/TYPE) EQ 7))
;  IF (test[0]) THEN time_ra = get_valid_trange(TDATE=tdate,PREC=3) ELSE time_ra = get_valid_trange(TRANGE=trange,PREC=3)
;  IF (test[0]) THEN time_ra = get_valid_trange(TDATE=tdate) ELSE time_ra = get_valid_trange(TRANGE=trange)
ENDIF ELSE BEGIN
  ;;  Prompt user and ask user for date/times
  time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange,PREC=3)
;  time_ra        = get_valid_trange(TDATE=tdate,TRANGE=trange)
ENDELSE
;;  Define dates and time ranges
tra            = time_ra.UNIX_TRANGE
tdates         = time_ra.DATE_TRANGE        ;;  'YYYY-MM-DD'  e.g., '2009-07-13'
;;  Check to see whether TRANGE ≥ 1 day (to within an hour)
diff           = (tra[1] - tra[0])
test_1dspan    = (diff[0] GE 864d2)
;test_1dspan    = (ABS(864d2 - diff[0]) LE 36d2) OR (diff[0] GE 864d2)
;test_1dspan    = (tra[1] - tra[0]) GE 864d2
;;  Check FILE_PREF and FILE_SUFF
test           = KEYWORD_SET(file_pref) AND (N_ELEMENTS(file_pref) GT 0)
IF (test[0]) THEN fpref_on = 1b ELSE fpref_on = 0b
test           = KEYWORD_SET(file_suff) AND (N_ELEMENTS(file_suff) GT 0)
IF (test[0]) THEN fsuff_on = 1b ELSE fsuff_on = 0b
IF (fpref_on[0] AND fsuff_on[0]) THEN BEGIN
  ;;  Both are set --> define file names
  fname          = file_pref[0]+'*.'+file_suff[0]
ENDIF ELSE BEGIN
  CASE 1 OF
    fpref_on[0]  :  fname = file_pref[0]+'*'
    fsuff_on[0]  :  fname = '*.'+file_suff[0]
    ELSE         :  fname = '*'
  ENDCASE
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Find all files
;;----------------------------------------------------------------------------------------
fpath          = base_dir[0]
all_files      = FILE_SEARCH(fpath[0],fname[0])
test           = (all_files[0] EQ '')
IF (test[0]) THEN BEGIN
  MESSAGE,nofiles_mssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check file date formats
;;----------------------------------------------------------------------------------------
nf             = N_ELEMENTS(all_files)
test_dform     = STREGEX(STRTRIM(all_files,2),regex[0],/BOOLEAN)
test           = (TOTAL(test_dform) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,baddform_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define all file dates
;;----------------------------------------------------------------------------------------
all_fd_pos     = STREGEX(STRTRIM(all_files,2),regex[0],LENGTH=all_fd_len)
all_fdate_st   = STREGEX(STRTRIM(all_files,2),regex[0],/EXTRACT)
;;  Check for multiple date occurrences [e.g., file name may contain time range]
;;    --> just check first file and assume all file names have the same format
tfile          = STRMID(STRTRIM(all_files[0],2),all_fd_pos[0]+all_fd_len[0])
test_exdate    = STREGEX(tfile[0],regex[0],/BOOLEAN)
IF (test_exdate[0] AND NOT KEYWORD_SET(ignore_2d)) THEN BEGIN
  ;;  Multiple dates per file name
  unq            = UNIQ(all_fd_pos,SORT(all_fd_pos))
  test_1pos      = (N_ELEMENTS(unq) EQ 1)
  IF (test_1pos[0]) THEN BEGIN
    ;;  Only one unique starting position
    tfiles       = STRMID(STRTRIM(all_files,2),all_fd_pos[0]+all_fd_len[0])
    all_fdate_en = STREGEX(tfiles,regex[0],/EXTRACT)
  ENDIF ELSE BEGIN
    ;;  multiple starting position --> need to loop
    all_fdate_en = STRARR(nf)
    FOR j=0L, nf[0] - 1L DO BEGIN
      tfile           = STRMID(STRTRIM(all_files[j],2),all_fd_pos[j]+all_fd_len[j])
      all_fdate_en[j] = STREGEX(tfile[0],regex[0],/EXTRACT)
    ENDFOR
  ENDELSE
ENDIF ELSE BEGIN
  ;;  Only one date per file name
  all_fdate_en = all_fdate_st
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Convert file dates to 'YYYY-MM-DD' form
;;----------------------------------------------------------------------------------------
;;  Define 'YYYY'
IF (yy2ch_on[0]) THEN BEGIN
  ;;  Date only had 2 character year
  ;;    -->  Assume values < 70 correspond to dates after Dec. 31, 1999
  year_2ch_st    = STRMID(all_fdate_st,yy_len_off[1],yy_len_off[0])
  test_70_st     = (LONG(year_2ch_st) LT 70L)
  year_4ch_st    = str_19_20[test_70_st]+year_2ch_st
  IF (test_exdate[0]) THEN BEGIN
    year_2ch_en    = STRMID(all_fdate_en,yy_len_off[1],yy_len_off[0])
    test_70_en     = (LONG(year_2ch_en) LT 70L)
    year_4ch_en    = str_19_20[test_70_en]+year_2ch_en
  ENDIF ELSE BEGIN
    year_2ch_en    = year_2ch_st
    test_70_en     = test_70_st
    year_4ch_en    = year_4ch_st
  ENDELSE
ENDIF ELSE BEGIN
  year_4ch_st    = STRMID(all_fdate_st,yy_len_off[1],yy_len_off[0])
  IF (test_exdate[0]) THEN year_4ch_en = STRMID(all_fdate_en,yy_len_off[1],yy_len_off[0]) $
                      ELSE year_4ch_en = year_4ch_st
ENDELSE
;;  Define ('MM' and 'DD') or 'DOY'
IF (doy_on[0]) THEN BEGIN
  ;;  1st convert DOY to months and days
  year_st        = LONG(year_4ch_st)
  doys_3ch_st    = STRMID(all_fdate_st,dd_len_off[1],dd_len_off[0])
  IF (test_exdate[0]) THEN BEGIN
    year_en        = LONG(year_4ch_en)
    doys_3ch_en    = STRMID(all_fdate_en,dd_len_off[1],dd_len_off[0])
  ENDIF ELSE BEGIN
    year_en        = year_st
    doys_3ch_en    = days_3ch_st
  ENDELSE
  doys_st        = LONG(doys_3ch_st)
  doys_en        = LONG(doys_3ch_en)
  ;;  Convert DOY to month and day numbers
  doy_to_month_date,year_st,doys_st,mon_st,day_st
  IF (test_exdate[0]) THEN BEGIN
    doy_to_month_date,year_en,doys_en,mon_en,day_en
  ENDIF ELSE BEGIN
    mon_en         = mon_st
    day_en         = day_st
  ENDELSE
  ;;  Convert month and day numbers to 2 character strings
  mons_2ch_st    = STRING(mon_st,FORMAT='(I2.2)')
  days_2ch_st    = STRING(day_st,FORMAT='(I2.2)')
ENDIF ELSE BEGIN
  mons_2ch_st    = STRMID(all_fdate_st,mm_len_off[1],mm_len_off[0])
  days_2ch_st    = STRMID(all_fdate_st,dd_len_off[1],dd_len_off[0])
ENDELSE
IF (test_exdate[0]) THEN BEGIN
  ;;  Convert month and day numbers to 2 character strings
  mons_2ch_en    = STRMID(all_fdate_en,mm_len_off[1],mm_len_off[0])
  days_2ch_en    = STRMID(all_fdate_en,dd_len_off[1],dd_len_off[0])
ENDIF ELSE BEGIN
  mons_2ch_en    = mons_2ch_st
  days_2ch_en    = days_2ch_st
ENDELSE
all_f_tdate_st = year_4ch_st+'-'+mons_2ch_st+'-'+days_2ch_st
all_f_tdate_en = year_4ch_en+'-'+mons_2ch_en+'-'+days_2ch_en
;;----------------------------------------------------------------------------------------
;;  Define start/end times (assuming beginning and end of 24 hour day)
;;----------------------------------------------------------------------------------------
IF (test_exdate[0]) THEN last_t = start_of_day[0] ELSE last_t = end___of_day[0]
;;  Convert dates to times, i.e., 'YYYY-MM-DD/hh:mm:ss.xxx'
all_f_ymdb_st  = all_f_tdate_st+'/'+start_of_day[0]
all_f_ymdb_en  = all_f_tdate_en+'/'+last_t[0]
;all_f_ymdb_en  = all_f_tdate_en+'/'+end___of_day[0]
;;  Convert times 'YYYY-MM-DD/hh:mm:ss.xxx' to Unix times
all_f_unix_st  = time_double(all_f_ymdb_st)
all_f_unix_en  = time_double(all_f_ymdb_en)
;;----------------------------------------------------------------------------------------
;;  Find files within valid time range
;;----------------------------------------------------------------------------------------
;;  Check if TRANGE starts/ends at start/end of day
st_of_tdate    = time_double(tdates[0]+'/'+start_of_day[0])
en_of_tdate    = time_double(tdates[1]+'/'+end___of_day[0]) + 1d-3
tra_mid_se     = REPLICATE(0b,2)
tra_mid_se[0]  = (tra[0] GT st_of_tdate[0])
tra_mid_se[1]  = (tra[1] LT en_of_tdate[0])
IF (test_1dspan[0]) THEN BEGIN
  tra_00         = tra
  IF (tra_mid_se[0]) THEN tra_00[0] = st_of_tdate[0]
  IF (tra_mid_se[1]) THEN tra_00[1] = en_of_tdate[0]
  ;;  TRANGE spans at least one full day
  test_s         = (all_f_unix_st GE tra_00[0]) AND (all_f_unix_en LE tra_00[1])
;  test_s         = (all_f_unix_st GE tra[0]) AND (all_f_unix_en LE tra[1])
ENDIF ELSE BEGIN
  ;;  TRANGE spans less than one full day
  test_s         = (tdates[0] EQ all_f_tdate_st) OR (tdates[1] EQ all_f_tdate_en)
;  test_s         = (tra[0] GE all_f_unix_st) AND (tra[1] LE all_f_unix_en)
ENDELSE
good_s         = WHERE(test_s,gd_t_s)
test           = (gd_t_s[0] EQ 0)
IF (test[0]) THEN BEGIN
  errmsg = 'No files within the user-specified time range...'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Valid files found!
out_files      = all_files[good_s]
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,out_files
END
