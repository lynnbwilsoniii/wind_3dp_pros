;*****************************************************************************************
;
;  FUNCTION :   find_wind_ascii_orbit.pro
;  PURPOSE  :   Finds all the Wind orbit ASCII files that have data which lie between
;                 the user specified time range.
;
;  CALLED BY:   
;               read_wind_orbit.pro
;
;  CALLS:
;               time_range_define.pro
;               time_double.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII Files created by SPDF Data Orbit Services at:
;                     http://spdf.gsfc.nasa.gov/data_orbits.html
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DATE     :  [string] Scalar or array of the form:
;                             'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE   :  [Double] 2 element array specifying the range over 
;                             which to get data structures [Unix time]
;
;   CHANGED:  1)  Fixed an issue that occurs when TRANGE is less than a day
;                                                                   [09/21/2012   v1.0.1]
;             2)  Updated Man. page and cleaned up routine
;                                                                   [09/19/2014   v1.1.0]
;
;   NOTES:      
;               1)  Initialize the IDL directories with start_umn_3dp.pro prior
;                     to use.
;               2)  The ASCII files should contain the orbit information for an entire
;                     day, but ONLY ONE DAY
;               3)  See read_wind_ascii_orbit.pro for more on ASCII file format
;
;   CREATED:  09/19/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/19/2014   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION find_wind_ascii_orbit,DATE=date,TRANGE=trange

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
ndays          = 0L             ;;  Dummy variable assigned to # of days of ASCII files to load
fdate          = ''             ;;  'MM-DD-YYYY' date string format for files
fpref          = 'wind_'

;;  dummy error messages
nodatamssg = 'No Wind orbit data was found'
ndatdatems = 'No Wind orbit data was found for that date'
pick_mssg  = 'Select all the wind orbit files of interest...'
badtrmssg  = 'Incorrect use of TRANGE:  Time range does not overlap with data...'
;;----------------------------------------------------------------------------------------
;;  Determine time range of interest
;;----------------------------------------------------------------------------------------
tdates     = ''    ;;  Date string ['YYYY-MM-DD']

time_ra    = time_range_define(DATE=date,TRANGE=trange)
tra        = time_ra.TR_UNIX
tdates     = time_ra.TDATE_SE
fdate      = time_ra.FDATE_SE
IF (fdate[0] NE fdate[1]) THEN multi_f = 1 ELSE multi_f = 0
;;----------------------------------------------------------------------------------------
;;  Find orbit files
;;----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(EXISTS) THEN BEGIN
  mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/Wind_Orbit_Data/')+'/'
ENDIF ELSE BEGIN
  mdir = !wind3dp_umn.WIND_ORBIT_DIR
  IF (mdir[0] EQ '') THEN mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/Wind_Orbit_Data/')+'/'
ENDELSE
tfiles         = FILE_SEARCH(mdir,'*.txt')
IF (tfiles[0] EQ '') THEN BEGIN
  ;;  No orbit files were found
  MESSAGE,nodatamssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,''
ENDIF
;;----------------------------------------------------------------------------------------
;;  Separate file name from directory name
;;----------------------------------------------------------------------------------------
file_only      = STRMID(tfiles,STRLEN(mdir[0]))
;; separate file dates
file_dates     = STRMID(file_only,STRLEN(fpref[0]),10)     ;;  e.g. '12-01-1997'
;; re-order characters to TPLOT format
file_years     = STRMID(file_dates,6L)
file_month     = STRMID(file_dates,0L,2L)
file__days     = STRMID(file_dates,3L,2L)
file_tdates    = file_years+'-'+file_month+'-'+file__days  ;; e.g. '1997-12-01'
;; define Unix time for start/end of dates
file_ymdbs     = file_tdates+'/00:00:00.000'               ;; e.g. '1997-12-01/00:00:00.000'
file_ymdbe     = file_tdates+'/23:59:59.999'
file_unixs     = time_double(file_ymdbs)
file_unixe     = time_double(file_ymdbe)
;; Sort
sp             = SORT(file_unixs)
file_unixs     = file_unixs[sp]
file_unixe     = file_unixe[sp]
tfiles         = tfiles[sp]
file_ymdbs     = file_ymdbs[sp]
file_ymdbe     = file_ymdbe[sp]
;;----------------------------------------------------------------------------------------
;;  Find all files within time range
;;----------------------------------------------------------------------------------------
good_s         = WHERE(file_unixs GE tra[0],gds)
IF (gds EQ 0) THEN BEGIN
  ;;  file does not exist
  MESSAGE,ndatdatems[0],/INFORMATIONAL,/CONTINUE
  ;;  let user pick file
  yesfile  = ''
  yesf     = ''
  jj       = 0L
  WHILE (yesfile NE 'y' AND yesfile NE 'n') DO BEGIN
    tout    = 'Do you wish to find correct files?  Type y for YES and n for NO:  '
    READ,yesf,PROMPT=tout[0]
    yesfile = STRLOWCASE(yesf)
    jj += 1L
    IF (jj GT 5) THEN RETURN,''   ;; exit loop and program
  ENDWHILE
  ;;  Determine what to do
  test     = (yesfile NE 'y')
  IF (test) THEN RETURN,''   ;; exit loop and program
  ;;  prompt user to find relevant files
  pfiles = DIALOG_PICKFILE(PATH=mdir[0],/MULTI,TITLE=pick_mssg)
  IF (pfiles[0] EQ '') THEN BEGIN
    MESSAGE, "Wow... I have no clue how you managed this...",/INFORMATIONAL,/CONTINUE
    RETURN,''
  ENDIF
  gfiles  = pfiles[*]
  picked = 1
  ;;  Return files
  RETURN,gfiles
ENDIF
;; Make sure first element is correct
IF (good_s[0] NE 0) THEN first_gel = good_s[0] - 1L ELSE first_gel = 0L
;good_e         = WHERE(file_unixe GE tra[1],gde)
good_e         = WHERE(tra[1] GE file_unixs,gde)
IF (gde EQ 0) THEN BEGIN
  ;; load all files after 1st
;  first_gel = good_s[0]
  last__gel = N_ELEMENTS(tfiles) - 1L
ENDIF ELSE BEGIN
  ;; define files
;  first_gel = good_s[0]
  last__gel = MAX(good_e,/NAN)
ENDELSE
;; define good elements
IF (last__gel[0] LT first_gel[0]) THEN BEGIN
  nf        = 1L
  gind      = LINDGEN(nf) + last__gel[0]
ENDIF ELSE BEGIN
  nf        = last__gel[0] - first_gel[0] + 1L
  gind      = LINDGEN(nf) + first_gel[0]
ENDELSE
gfiles    = tfiles[gind]
;;----------------------------------------------------------------------------------------
;;  Return to calling routine
;;----------------------------------------------------------------------------------------

RETURN,gfiles
END


;*****************************************************************************************
;
;  FUNCTION :   read_wind_ascii_orbit.pro
;  PURPOSE  :   This program reads in an ASCII file created by SPDF Data Orbit Services
;                 and returns a data structure that contains the GSE Cartesian and
;                 sperical coordinates, L-Shell, and invariant latitude to wrapping
;                 program.
;
;  CALLED BY:   
;               read_wind_orbit.pro
;
;  CALLS:
;               format_structure.pro
;               my_str_date.pro
;               my_time_string.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII Files created by SPDF Data Orbit Services at:
;                     http://spdf.gsfc.nasa.gov/data_orbits.html
;               Format of output must be:
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;GROUP 1    Satellite   Resolution   Factor
;            wind          720         1
;
;           Start Time           Stop Time 
;           2000   1  0.00000    2000   2  0.00000
;
;
; Coord/            Min/Max          Range Filter              Filter
;Component   Output Markers      Minimum         Maximum      Mins/Maxes
;GSE X        YES      -           -               -               -   
;GSE Y        YES      -           -               -               -   
;GSE Z        YES      -           -               -               -   
;GSE Lat      YES      -           -               -               -   
;GSE Lon      YES      -           -               -               -   
;GSM X        YES      -           -               -               -   
;GSM Y        YES      -           -               -               -   
;GSM Z        YES      -           -               -               -   
;GSM Lat      YES      -           -               -               -   
;GSM Lon      YES      -           -               -               -   
;
;
;Addtnl             Min/Max          Range Filter              Filter
;Options     Output Markers      Minimum         Maximum      Mins/Maxes
;L_Value      YES      -           -               -               -   
;InvarLat     YES      -           -               -               -   
;
;Output - File: 
;         lines per page: 0
; 
;Formats and units:
;    Day/Time format: YY/MM/DD HH:MM:SS
;    Degrees/Hemisphere format: Decimal degrees with 2 place(s).
;        Longitude 0 to 360, latitude -90 to 90.
;    Distance format: Kilometers with 3 place(s).
;
;wind
;       Time                           GSE [km]                         GSE                          GSM [km]                         GSM                DipInvLat
;yy/mm/dd hh:mm:ss        X               Y               Z          Lat   Long         X               Y               Z          Lat   Long   DipL-Val   (Deg)  
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;
;  INPUT:
;               FILE     :  Scalar string defining the full path name to the orbit
;                             file of interest
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Updated Man. page to reflect the correct format to use for the
;                   output ASCII files and cleaned up routine
;                                                                   [09/19/2014   v1.1.0]
;
;   NOTES:      
;               1)  User should not call this routine
;               2)  The ASCII files should contain the orbit information for an entire
;                     day, but ONLY ONE DAY
;
;   CREATED:  05/26/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/19/2014   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************

FUNCTION read_wind_ascii_orbit,file

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
gfile      = file[0]
;;----------------------------------------------------------------------------------------
;;  Define Header quantities
;;----------------------------------------------------------------------------------------
nHeader = 14L                              ;;  # of lines in the header
nl      = FILE_LINES(gfile[0]) - nHeader   ;;  # of lines in the ASCII file that is data
;;----------------------------------------------------------------------------------------
;;  Open file and read in data
;;----------------------------------------------------------------------------------------
;mform = '(a17,3f16.3,2f7.2,2f10.1)'
OPENR,gunit,gfile[0],ERROR=err,/GET_LUN
  mline = ''
  IF (err NE 0) THEN PRINT, -2, !ERROR_STATE.MSG   ;;  Prints an error message
  ;;  Read in Header
  FOR mvcount = 0L, nHeader - 1L DO BEGIN
    READF,gunit,mline
      CASE mvcount OF
        0  :  stend_t  = STRCOMPRESS(STRMID(mline,6L),/REMOVE_ALL)    ;;  Start and End time strings
        1  :  BEGIN
          doy_start = STRMID(mline,11L,17L)  ;;  ['YYYY DOY x.xxxxx'] at Start
          doy_end   = STRMID(mline,32L)      ;;  ['YYYY DOY x.xxxxx'] at End
        END
        2  :  
        3  :  dateform = STRMID(mline,21L)   ;;  ['YY/MM/DD HH:MM:SS'] Date/Time format
        4  :  
        5  :  
        6  :  
        7  :  
        8  :  BEGIN ;;  [e.g. '(a17,3f16.3,2f7.2,2f10.1)'] format statement of data
          gpos     = STRPOS(STRMID(mline,8L),')')
          dataform = STRMID(mline,8L,gpos[0]+1L)
        END
        9  :  
        10 :  sat      = STRCOMPRESS(STRMID(mline,0L),/REMOVE_ALL)   ;;  Satellite ['wind']
        11 :  datlabs  = STRMID(mline,0L)    ;;  Data labels
        12 :  datnams  = STRMID(mline,0L)    ;;  Data names/types
        13 :  
      ENDCASE
  ENDFOR
  mform = (STRCOMPRESS(dataform,/REMOVE_ALL))[0]  ;;  Format statement of data
  fstr  = format_structure(mform)
  nflo  = (fstr.FLOATS)[0]
  dats  = REPLICATE(d,nl,nflo)   ;;  Data array
  times = REPLICATE('',nl)       ;;  Time array
  utx   = ''              ;;  Dummy time variable
  tdat  = DBLARR(nflo)      ;;  Dummy data variable
  j     = 0L
  ggg   = 1
  WHILE(ggg) DO BEGIN
    READF,gunit,FORMAT=mform,utx,tdat
    dats[j,*]  = tdat
    times[j]   = utx
    IF (j LT nl - 1L) THEN ggg = 1 ELSE ggg = 0
    IF (ggg) THEN j += 1L
  ENDWHILE
FREE_LUN,gunit
;;----------------------------------------------------------------------------------------
;;  Convert times to unix times
;;----------------------------------------------------------------------------------------
tdates = ''      ;;  Dates of data ['MMDDYY']
ttimes = ''      ;;  Times of data ['HH:MM:SS']
ymdb   = ''      ;;  Date/Time     ['YYYY-MM-DD'/HH:MM:SS.xxxx']
unix   = 0d0     ;;  Unix times (seconds since Jan 1st, 1970)

tdates = STRMID(times[*],3L,2L)+STRMID(times[*],6L,2L)+STRMID(times[*],0L,2L)
ttimes = STRMID(times[*],9L)
ddates = my_str_date(DATE=tdates)
zdates = ddates.TDATE
ymdb   = zdates+'/'+ttimes+'.0000'
mts    = my_time_string(ymdb,STR=1,FORM=1,/NOM)
unix   = mts.UNIX
ymdts  = mts.DATE_TIME
nt     = N_ELEMENTS(unix)
;;----------------------------------------------------------------------------------------
;;  Define data variables
;;----------------------------------------------------------------------------------------
gse_pos = REPLICATE(f,nt,3L)  ;;  GSE Positions [km]
gsm_pos = REPLICATE(f,nt,3L)  ;;  GSM Positions [km]
gse_lat = REPLICATE(f,nt)     ;;  GSE Latitude [deg]
gse_lon = REPLICATE(f,nt)     ;;  GSE Longitude [deg]
gsm_lat = REPLICATE(f,nt)     ;;  GSM Latitude [deg]
gsm_lon = REPLICATE(f,nt)     ;;  GSM Longitude [deg]
L_value = REPLICATE(f,nt)     ;;  Magnetic L-Shell Value [Re]
inv_lat = REPLICATE(f,nt)     ;;  Invariant Latitude [deg]

CASE nflo[0] OF
  7L   : BEGIN                    ;;  Only GSE positions and latitudes
    L_value = REFORM(dats[*,5L])  ;;  Magnetic L-Shell Value [Re]
    inv_lat = REFORM(dats[*,6L])  ;;  Invariant Latitude [deg]
  END
  12L  : BEGIN
    gsm_pos = REFORM(dats[*,5:7])
    gsm_lat = REFORM(dats[*,8])
    gsm_lon = REFORM(dats[*,9])
    L_value = REFORM(dats[*,10L])  ;;  Magnetic L-Shell Value [Re]
    inv_lat = REFORM(dats[*,11L])  ;;  Invariant Latitude [deg]
  END
  ELSE : BEGIN
    MESSAGE,'Input ASCII file has unknown format',/CONT,/INFO
  END
ENDCASE
gse_pos = dats[*,0:2]                      ;;  GSE Positions [km]
gse_lat = REFORM(dats[*,3L])               ;;  GSE Latitude [deg]
gse_lon = REFORM(dats[*,4L])               ;;  GSE Longitude [deg]
radial  = SQRT(TOTAL(gse_pos^2,2L,/NAN))   ;;  Radial distance from Earth [km]
;;----------------------------------------------------------------------------------------
;;  Define data structure to return
;;----------------------------------------------------------------------------------------
tags    = ['UNIX','YMDB','GSE_POSITION','RADIAL_DISTANCE','GSE_LAT',$
           'GSE_LONG','GSM_POSITION','GSM_LAT','GSM_LONG',          $
           'LSHELL','INVAR_LAT']

data    = CREATE_STRUCT(tags,unix,ymdts,gse_pos,radial,gse_lat,gse_lon,$
                        gsm_pos,gsm_lat,gsm_lon,L_value,inv_lat)
;;----------------------------------------------------------------------------------------
;;  Return to calling routine
;;----------------------------------------------------------------------------------------

RETURN,data
END


;+
;*****************************************************************************************
;
;  PROCEDURE:   read_wind_orbit.pro
;  PURPOSE  :   This program reads in an ASCII file created by SPDF Data Orbit Services
;                 and returns a data structure that contains the GSE Cartesian and
;                 sperical coordinates, L-Shell, and invariant latitude.
;
;  CALLED BY:   
;               wind_orbit_to_tplot.pro
;
;  CALLS:
;               time_range_define.pro
;               time_double.pro
;               time_string.pro
;               read_wind_ascii_orbit.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII Files created by SPDF Data Orbit Services at:
;                     http://spdf.gsfc.nasa.gov/data_orbits.html
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;  Get orbit data for April 9, 2000
;               read_wind_orbit,DATE='040900',DATA=data
;
;  KEYWORDS:    
;               DATE     :  Scalar (or array) [string] of the form:
;                             'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE   :  [2]-Element array [double] specifying the Unix time range for
;                             which to get Wind orbit data
;               DATA     :  Set to a named variable to be returned as a structure
;                             containing all the useful data.  The output structure has
;                             the following tags:
;                               UNIX             :  [N]-Element array [double] of Unix
;                                                     time stamps
;                               YMDB             :  [N]-Element array [string] of time
;                                                     stamps of the form
;                                                     'YYYY-MM-DD/hh:mm:ss.xxx'
;                               GSE_POSITION     :  [N,3]-Element array [float] of Wind
;                                                     coordinate positions [km, GSE]
;                               RADIAL_DISTANCE  :  [N]-Element array [float] of Wind
;                                                     radial positions [km]
;                               GSE_LAT          :  [N]-Element array [float] of Wind
;                                                     latitudes [deg, GSE basis]
;                               GSE_LONG         :  [N]-Element array [float] of Wind
;                                                     longitudes [deg, GSE basis]
;                               GSM_POSITION     :  [N,3]-Element array [float] of Wind
;                                                     coordinate positions [km, GSM]
;                               GSM_LAT          :  [N]-Element array [float] of Wind
;                                                     latitudes [deg, GSM basis]
;                               GSM_LONG         :  [N]-Element array [float] of Wind
;                                                     longitudes [deg, GSM basis]
;                               LSHELL           :  [N]-Element array [float] of Wind
;                                                     magnetic dipole L-shell values [Re]
;                               INVAR_LAT        :  [N]-Element array [float] of Wind
;                                                     magnetic dipole invariant
;                                                     latitudes [deg]
;
;   CHANGED:  1)  Changed read statement and added program my_format_structure.pro
;                   to allow for different input ASCII files
;                                                                   [07/21/2009   v1.1.0]
;             2)  Changed location of ASCII files and file searching algorithm
;                                                                   [09/16/2009   v1.2.0]
;             3)  Changed program my_format_structure.pro to format_structure.pro
;                                                                   [11/12/2009   v1.3.0]
;             4)  Fixed a typo
;                                                                   [02/09/2010   v1.4.0]
;             5)  Added keyword:  TRANGE and now calls read_wind_ascii_orbit.pro
;                                                                   [05/26/2011   v1.5.0]
;             6)  Fixed an issue that occurred in # of days calculation
;                                                                   [07/28/2011   v1.6.0]
;             7)  Changed time range calculation and now calls time_range_define.pro
;                                                                   [02/10/2012   v1.7.0]
;             8)  Fixed a typo in file search algorithm
;                                                                   [03/20/2012   v1.7.1]
;             9)  Fixed issue in file search algorithm and
;                   now calls find_wind_ascii_orbit.pro
;                                                                   [09/19/2012   v1.8.0]
;            10)  Fixed issue in find_wind_ascii_orbit.pro and cleaned up
;                                                                   [09/21/2012   v1.8.1]
;            11)  Updated Man. pages and cleaned up routine
;                                                                   [09/19/2014   v1.9.0]
;
;   NOTES:      
;               1)  Initialize the IDL directories with start_umn_3dp.pro prior
;                     to use.
;               2)  The ASCII files should contain the orbit information for an entire
;                     day, but ONLY ONE DAY
;
;  REFERENCES:  
;               1)  See the documentation at:
;                     http://spdf.gsfc.nasa.gov/data_orbits.html
;
;   CREATED:  07/20/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/19/2014   v1.9.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO read_wind_orbit,DATE=date,TRANGE=trange,DATA=data

;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
ndays      = 0L             ;;  Dummy variable assigned to # of days of ASCII files to load
fdate      = ''             ;;  'MM-DD-YYYY' date string format for files
fdates     = ''             ;;  'MM-DD-YYYY' list of file dates for finding file names
nodatamssg = 'No Wind orbit data was found'
ndatdatems = 'No Wind orbit data was found for that date'
pick_mssg  = 'Select all the wind orbit files of interest...'
badtrmssg  = 'Incorrect use of TRANGE:  Time range does not overlap with data...'
picked     = 0L             ;;  logic variable telling pro whether user hand picked files

fpref      = 'wind_'
fsuff      = '_XYZ-GSE-GSM_Lat-Long-GSE_L-Value_Invar-Lat.txt'
;;----------------------------------------------------------------------------------------
;;  Determine time range of interest
;;----------------------------------------------------------------------------------------
tdates     = ''    ;;  Date string ['YYYY-MM-DD']

time_ra    = time_range_define(DATE=date,TRANGE=trange)
tra        = time_ra.TR_UNIX
tdates     = time_ra.TDATE_SE
fdate      = time_ra.FDATE_SE
;; If add time to extend beyond trange
tra       += [-1d0,1d0]*12d2
;;----------------------------------------------------------------------------------------
;;  Define directory where orbit files are found
;;----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(EXISTS) THEN BEGIN
  mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/Wind_Orbit_Data/')+'/'
ENDIF ELSE BEGIN
  mdir = !wind3dp_umn.WIND_ORBIT_DIR
  IF (mdir[0] EQ '') THEN mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/Wind_Orbit_Data/')+'/'
ENDELSE
tfiles         = FILE_SEARCH(mdir,'*.txt')
IF (tfiles[0] EQ '') THEN BEGIN
  ;;  No orbit files were found
  MESSAGE,nodatamssg[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;;  Find orbit files
;;----------------------------------------------------------------------------------------
gfile          = find_wind_ascii_orbit(DATE=date,TRANGE=tra)
IF (gfile[0] EQ '') THEN BEGIN
  MESSAGE,ndatdatems[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
ndays          = N_ELEMENTS(gfile)
;;  Separate file name from directory name
file_only      = STRMID(gfile,STRLEN(mdir[0]))
;; separate file dates
fdates         = STRMID(file_only,STRLEN(fpref[0]),10)     ;;  e.g. '12-01-1997'
;;----------------------------------------------------------------------------------------
;;  Read in data files
;;----------------------------------------------------------------------------------------
FOR k=0L, ndays - 1L DO BEGIN
  test = read_wind_ascii_orbit(gfile[k])
  IF (k EQ 0) THEN BEGIN
    unix    = test.UNIX
    ymdb    = test.YMDB
    gse_pos = test.GSE_POSITION
    gsm_pos = test.GSM_POSITION
    gse_lat = test.GSE_LAT
    gse_lon = test.GSE_LONG
    gsm_lat = test.GSM_LAT
    gsm_lon = test.GSM_LONG
    L_value = test.LSHELL
    inv_lat = test.INVAR_LAT
    radial  = test.RADIAL_DISTANCE
  ENDIF ELSE BEGIN
    unix    = [unix,test.UNIX]
    ymdb    = [ymdb,test.YMDB]
    gse_pos = [gse_pos,test.GSE_POSITION]
    gsm_pos = [gsm_pos,test.GSM_POSITION]
    gse_lat = [gse_lat,test.GSE_LAT]
    gse_lon = [gse_lon,test.GSE_LONG]
    gsm_lat = [gsm_lat,test.GSM_LAT]
    gsm_lon = [gsm_lon,test.GSM_LONG]
    L_value = [L_value,test.LSHELL]
    inv_lat = [inv_lat,test.INVAR_LAT]
    radial  = [radial,test.RADIAL_DISTANCE]
  ENDELSE
ENDFOR
;;  Sort data
sp      = UNIQ(unix,SORT(unix))
unix    = unix[sp]        ;;  Unix times for positions
ymdb    = ymdb[sp]        ;;  'YYYY-MM-DD'/HH:MM:SS.ssss'
gse_pos = gse_pos[sp,*]   ;;  GSE Positions [km]
gsm_pos = gsm_pos[sp,*]   ;;  GSM Positions [km]
gse_lat = gse_lat[sp]     ;;  GSE Latitude [deg]
gse_lon = gse_lon[sp]     ;;  GSE Longitude [deg]
gsm_lat = gsm_lat[sp]     ;;  GSM Latitude [deg]
gsm_lon = gsm_lon[sp]     ;;  GSM Longitude [deg]
L_value = L_value[sp]     ;;  Magnetic L-Shell Value [Re]
inv_lat = inv_lat[sp]     ;;  Invariant Latitude [deg]
radial  = radial[sp]      ;;  Radial distance from Earth [km]
;;----------------------------------------------------------------------------------------
;;  Define only elements desired by user
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(tra) THEN BEGIN
  good = WHERE(unix LE tra[1] AND unix GE tra[0],gd)
  IF (gd EQ 0) THEN BEGIN
    ;;  Inform user of keyword failure
    MESSAGE,badtrmssg[0],/INFORMATIONAL,/CONTINUE
    unix    = [d]
    ymdb    = ['']
    gse_pos = REPLICATE(f,3L)
    gsm_pos = REPLICATE(f,3L)
    gse_lat = [f]
    gse_lon = [f]
    gsm_lat = [f]
    gsm_lon = [f]
    L_value = [f]
    inv_lat = [f]
    radial  = [f]
    tags    = ['UNIX','YMDB','GSE_POSITION','RADIAL_DISTANCE','GSE_LAT',$
               'GSE_LONG','GSM_POSITION','GSM_LAT','GSM_LONG',          $
               'LSHELL','INVAR_LAT']
    data    = CREATE_STRUCT(tags,unix,ymdb,gse_pos,radial,gse_lat,gse_lon,$
                            gsm_pos,gsm_lat,gsm_lon,L_value,inv_lat)
    RETURN
  ENDIF
  unix    = unix[good]
  ymdb    = ymdb[good]
  gse_pos = gse_pos[good,*]
  gsm_pos = gsm_pos[good,*]
  gse_lat = gse_lat[good]
  gse_lon = gse_lon[good]
  gsm_lat = gsm_lat[good]
  gsm_lon = gsm_lon[good]
  L_value = L_value[good]
  inv_lat = inv_lat[good]
  radial  = radial[good]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define data structure to return
;;----------------------------------------------------------------------------------------
tags    = ['UNIX','YMDB','GSE_POSITION','RADIAL_DISTANCE','GSE_LAT',$
           'GSE_LONG','GSM_POSITION','GSM_LAT','GSM_LONG',          $
           'LSHELL','INVAR_LAT']
data    = CREATE_STRUCT(tags,unix,ymdb,gse_pos,radial,gse_lat,gse_lon,$
                        gsm_pos,gsm_lat,gsm_lon,L_value,inv_lat)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END