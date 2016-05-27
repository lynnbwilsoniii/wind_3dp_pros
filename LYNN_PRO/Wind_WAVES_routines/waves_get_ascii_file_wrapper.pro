;+
;*****************************************************************************************
;
;  FUNCTION :   find_waves_ascii_files.pro
;  PURPOSE  :   This routine finds the ASCII files associated with a user defined
;                 Wind/WAVES radio receiver.  The routine returns the file name with
;                 full directory path included.
;
;  CALLED BY:   
;               waves_get_ascii_file_wrapper.pro
;
;  CALLS:
;               get_os_slash.pro
;               time_range_define.pro
;               time_double.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               files = find_waves_ascii_files(DATE=date,TRANGE=trange,RECEIVER=receiver)
;
;  KEYWORDS:    
;               DATE      :  Scalar [string] or array of the form:
;                              'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE    :  [2]-Element [Double] array specifying the time range from
;                              which the user desires to get data [Unix time]
;               RECEIVER  :  Scalar [string] defining the WAVES receiver from which the
;                              user wishes to find data
;                              'tnr'   :  WAVES Thermal Noise Receiver (TNR)
;                              'rad1'  :  WAVES RADio receiver band 1
;                              'rad2'  :  WAVES RADio receiver band 2
;                              [Default = 'tnr']
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  03/21/2013
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/21/2013   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_waves_ascii_files,DATE=date,TRANGE=trange,RECEIVER=receiver

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
ndays          = 0L             ;;  Dummy variable assigned to # of days of ASCII files to load
fdates         = ''             ;;  'YYYYMMDD' date string format for files
tdates         = ''             ;;  Date string ['YYYY-MM-DD']
;;  Get directory separator for current OS
slash          = get_os_slash()
def_exten      = ''             ;;  Default directory path extension from current working directory
def_exten      = 'wind_3dp_pros'+slash[0]+'wind_data_dir'+slash[0]+'Wind_WAVES_Data'+slash[0]
;;  Define receiver directory extensions
tnr__exten     = 'TNR__ASCII'
rad1_exten     = 'RAD1_ASCII'
rad2_exten     = 'RAD2_ASCII'
;; => dummy error messages
nodatamssg     = 'No Wind WAVES data files were found...'
ndatdatems     = 'No Wind WAVES data files were found for that date...'
pick_mssg      = 'Select all the wind WAVES files of interest...'
badtrmssg      = 'Incorrect use of TRANGE:  Time range does not overlap with data...'
;;----------------------------------------------------------------------------------------
;; => Determine time range of interest
;;----------------------------------------------------------------------------------------
time_ra        = time_range_define(DATE=date,TRANGE=trange)
trange         = time_ra.TR_UNIX    ;;  Define keyword for return if originally unset
tra            = trange
tdates         = time_ra.TDATE_SE
fdate          = time_ra.FDATE_SE   ;;  'MM-DD-YYYY'
IF (fdate[0] NE fdate[1]) THEN multi_f = 1 ELSE multi_f = 0
;;----------------------------------------------------------------------------------------
;; => Find ASCII file directory
;;----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(EXISTS) THEN BEGIN
  mdir = FILE_EXPAND_PATH(def_exten[0])
ENDIF ELSE BEGIN
  mdir = !wind3dp_umn.WIND_WAVES_DIR
  IF (mdir[0] EQ '') THEN mdir = FILE_EXPAND_PATH(def_exten[0])
ENDELSE
;; => Check for trailing '/'
ll             = STRMID(mdir, STRLEN(mdir) - 1L,1L)
test_ll        = (ll[0] NE slash[0])
IF (test_ll) THEN mdir  = mdir[0]+slash[0]

;;  Determine for which receiver data should be retrieved
test_rec       = (N_ELEMENTS(receiver) NE 1) OR (SIZE(receiver,/TYPE) NE 7)
IF (test_rec) THEN rec = 'tnr' ELSE rec = STRLOWCASE(receiver[0])
CASE rec[0] OF
  'tnr'  :  mdir = mdir[0]+tnr__exten[0]+slash[0]
  'rad1' :  mdir = mdir[0]+rad1_exten[0]+slash[0]
  'rad2' :  mdir = mdir[0]+rad2_exten[0]+slash[0]
  ELSE   :  BEGIN
    mdir = mdir[0]+tnr__exten[0]+slash[0]  ;;  Use default ['tnr']
    rec  = 'tnr'
  END
ENDCASE
;;  Define file name prefix
fpref          = STRUPCASE(rec[0])+'_'                     ;;  e.g., 'TNR_'
;;----------------------------------------------------------------------------------------
;; => Find ASCII files
;;----------------------------------------------------------------------------------------
tfiles         = FILE_SEARCH(mdir,'*.txt')
IF (tfiles[0] EQ '') THEN BEGIN
  ;; => No WAVES files were found
  MESSAGE,nodatamssg[0],/INFORMATIONAL,/CONTINUE
  RETURN,''
ENDIF
;;----------------------------------------------------------------------------------------
;; => Separate file name from directory name
;;----------------------------------------------------------------------------------------
file_only      = STRMID(tfiles,STRLEN(mdir[0]))            ;;  e.g., 'TNR_19970108.txt'
;;  Separate file dates from file names
file_dates     = STRMID(file_only,STRLEN(fpref[0]),8L)     ;;  e.g., '19970108'
;;  Re-order characters to TPLOT format  ['YYYY-MM-DD']
file_years     = STRMID(file_dates,0L,4L)
file_month     = STRMID(file_dates,4L,2L)
file__days     = STRMID(file_dates,6L,2L)
file_tdates    = file_years+'-'+file_month+'-'+file__days  ;; e.g. '1997-01-08'
;;  Define Unix time for start/end of dates
file_ymdbs     = file_tdates+'/00:00:00.000'               ;; e.g. '1997-01-08/00:00:00.000'
file_ymdbe     = file_tdates+'/23:59:59.999'
file_unixs     = time_double(file_ymdbs)
file_unixe     = time_double(file_ymdbe)
;;  Sort files chronologically
sp             = SORT(file_unixs)
file_unixs     = file_unixs[sp]
file_unixe     = file_unixe[sp]
tfiles         = tfiles[sp]
file_ymdbs     = file_ymdbs[sp]
file_ymdbe     = file_ymdbe[sp]
file_tdates    = file_tdates[sp]
;;----------------------------------------------------------------------------------------
;; => Find all files within time range
;;----------------------------------------------------------------------------------------
good_s         = WHERE(file_unixs GE tra[0],gds)
IF (gds EQ 0) THEN BEGIN
  ;;--------------------------------------------------------------------------------------
  ;;  File does not exist or cannot be found => try finding manually
  ;;--------------------------------------------------------------------------------------
  MESSAGE,ndatdatems[0],/INFORMATIONAL,/CONTINUE
  ;;  Let user pick file
  yesfile  = ''
  yesf     = ''
  jj       = 0L
  WHILE (yesfile NE 'y' AND yesfile NE 'n') DO BEGIN
    yesf    = ''  ;; reset
    tout    = 'Do you wish to find correct files?  Type y for YES and n for NO:  '
    READ,yesf,PROMPT=tout[0]
    testy   = (yesf NE 'y' AND yesf NE 'n')
    IF (testy) THEN BEGIN
      ;;  Make sure user doesn't get more than 5 tries
      jj     += 1L
      IF (jj GT 5) THEN RETURN,''   ;;  Exit loop and return empty string
    ENDIF ELSE BEGIN
      yesfile = STRLOWCASE(yesf)
    ENDELSE
  ENDWHILE
  ;; => Determine what to do
  test     = (yesfile NE 'y')
  IF (test) THEN RETURN,''        ;;  Exit loop and return empty string
  ;;--------------------------------------------------------------------------------------
  ;;  Prompt user to find relevant files
  ;;--------------------------------------------------------------------------------------
  pfiles = DIALOG_PICKFILE(PATH=mdir[0],/MULTI,TITLE=pick_mssg)
  IF (pfiles[0] EQ '') THEN BEGIN
    MESSAGE, "Wow... I have no clue how you managed this...",/INFORMATIONAL,/CONTINUE
    RETURN,''
  ENDIF
  gfiles  = pfiles[*]
  ;;--------------------------------------------------------------------------------------
  ;;  Return files
  ;;--------------------------------------------------------------------------------------
  RETURN,gfiles
ENDIF
;;----------------------------------------------------------------------------------------
;;  Make sure first element is correct
;;----------------------------------------------------------------------------------------
IF (good_s[0] NE 0) THEN first_gel = good_s[0] - 1L ELSE first_gel = 0L

good_e         = WHERE(tra[1] GE file_unixs,gde)
IF (gde EQ 0) THEN BEGIN
  ;;  Get 1 file after 1st
  last__gel = first_gel[0] + 1L
ENDIF ELSE BEGIN
  ;;  Define last element
  last__gel = MAX(good_e,/NAN)
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define good elements
;;----------------------------------------------------------------------------------------
IF (last__gel[0] LT first_gel[0]) THEN BEGIN
  nf        = 1L
  gind      = LINDGEN(nf) + last__gel[0]
ENDIF ELSE BEGIN
  nf        = last__gel[0] - first_gel[0] + 1L
  gind      = LINDGEN(nf) + first_gel[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Define good files and return structure
;;----------------------------------------------------------------------------------------
gfiles         = tfiles[gind]
g_unixs        = file_unixs[gind]
g_unixe        = file_unixe[gind]
g_ymdbs        = file_ymdbs[gind]
g_ymdbe        = file_ymdbe[gind]
g_tdates       = file_tdates[gind]
tags           = ['FILES','UNIX_S','UNIX_E','YMDB_S','YMDB_E','TDATES']
struc          = CREATE_STRUCT(tags,gfiles,g_unixs,g_unixe,g_ymdbs,g_ymdbe,g_tdates)
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END


;+
;*****************************************************************************************
;
;  FUNCTION :   waves_get_ascii_file_wrapper.pro
;  PURPOSE  :   This program is a wrapping program for wave_[]_file_read.pro that
;                 sets up data structure formats to handle the ASCII files to be read
;                 in and it returns the data to waves_tnr_rad_to_tplot.pro which sends
;                 the results to a routine that sends the data to TPLOT.
;                 [] = tnr or rad
;
;  CALLED BY:   
;               waves_tnr_rad_to_tplot.pro
;
;  CALLS:
;               find_waves_ascii_files.pro
;               str_element.pro
;               waves_tnr_file_read.pro
;               waves_rad_file_read.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII files found at:
;                     http://www-lep.gsfc.nasa.gov/waves/data_products.html
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               test = waves_get_ascii_file_wrapper(DATE=date,FLOW=flz0,FHIGH=fhz0,$
;                                                   TRANGE=trange,NODCBLS=nodcbls)
;
;  KEYWORDS:    
;               DATE      :  Scalar [string] or array of the form:
;                              'MMDDYY' [MM=month, DD=day, YY=year]
;               FLOW      :  Scalar [float] frequency (kHz) that defines the low
;                              end of the frequency spectrum you're interested in
;               FHIGH     :  Scalar [float] frequency (kHz) that defines the high
;                              end of the frequency spectrum you're interested in
;               TRANGE    :  [2]-Element [Double] array specifying the time range from
;                              which the user desires to get data [Unix time]
;               NODCBLS   :  If set, program returns dynamic spectra in microvolts
;                              per root Hz instead of dB above background
;
;   CHANGED:  1)  Added keyword:  NODCBLS                         
;                                                                 [10/11/2010   v1.1.0]
;             2)  Updated website location                        
;                                                                 [03/11/2011   v1.1.1]
;             3)  Updated man page and changed name to waves_get_ascii_file_wrapper.pro
;                   and now moved to ~/wind_3dp_pros/LYNN_PRO/ directory
;                   and now calls find_waves_ascii_files.pro
;                                                                 [03/21/2013   v2.0.0]
;
;   NOTES:      
;               1)  This program should NOT be called by a user, let
;                     waves_tnr_rad_to_tplot.pro call this program
;
;  REFERENCES:  
;               1)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang (1995) "WAVES:  The Radio and Plasma
;                      Wave Investigation on the Wind Spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 231-263, doi:10.1007/BF00751331.
;
;   CREATED:  05/11/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/21/2013   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION waves_get_ascii_file_wrapper,DATE=date,FLOW=flz0,FHIGH=fhz0,TRANGE=trange, $
                                      NODCBLS=nodcbls

;;----------------------------------------------------------------------------------------
;; => Define Constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
ndays          = 0L              ;;  Dummy variable assigned to # of days of ASCII files to load
def_flow       = '4'
def_fhig       = '13,825'
low_prompt     = 'Enter low frequency in (kHz) ['+def_flow[0]+' < f < '+def_fhig[0]+']:  '
hig_prompt     = 'Enter high frequency in (kHz) ['+def_flow[0]+' < f < '+def_fhig[0]+']:  '

;;  Define dummy structures for each receiver
tags           = ['F_LOW','F_HIGH','N_FREQ','D_FREQ','F_UNIT','STR_NAME']
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;  Note:  
;;    F_LOW   :  Low freq. end of receiver range in units of F_UNIT
;;    F_HIGH  :  High freq. end " "
;;    N_FREQ  :  Total number of different freq. being sampled by the receiver(s)
;;    D_FREQ  :  The spacing of the freq. channels for each receiver
;;    F_UNIT  :  The units of the frequency being used
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
tnr_str        = CREATE_STRUCT(tags,4.,245.146,96L,.188144e-1,'kHz','tnr')
rad1_str       = CREATE_STRUCT(tags,20.,1040.,256L,4.,'kHz','rad1')
rad2_str       = CREATE_STRUCT(tags,1.075*1e3,13.825*1e3,256L,.050*1e3,'kHz','rad2')
r12_str        = CREATE_STRUCT(tags,20.,13825.,512L,[4.,50.],'kHz','rad1+rad2')
all_str        = CREATE_STRUCT(tags,4.,13825.,606L,[.188144e-1,4.,50.],'kHz','all')

;;  Define default channels for each receiver
tnr_ch1        = 0L       ;;  Lowest channel of TNR frequencies
tnr_ch2        = 0L       ;;  Highest " "
rad1_ch1       = 0L       ;;  Lowest channel of RAD1 frequencies
rad1_ch2       = 0L       ;;  Highest " "
rad2_ch1       = 0L       ;;  Lowest channel of RAD2 frequencies
rad2_ch2       = 0L       ;;  Highest " "
;; => TNR Channels
tnr_ch1        = 0
tnr_ch2        = LONG((ALOG10(tnr_str.F_HIGH) - ALOG10(tnr_str.F_LOW))/tnr_str.D_FREQ) + 1L
;; => RAD1 Channels
rad1_ch1       = 0L
rad1_ch2       = LONG((rad1_str.F_HIGH - rad1_str.F_LOW)/rad1_str.D_FREQ)
;; => RAD2 Channels
rad2_ch1       = 0L
rad2_ch2       = LONG((rad2_str.F_HIGH - rad2_str.F_LOW)/rad2_str.D_FREQ)

;;  Define default frequencies for each receiver
tnr_lzl        = 1e1^(ALOG10(tnr_str.F_LOW) + tnr_ch1*tnr_str.D_FREQ) ;; => low freq. end of TNR
tnr_hzl        = 1e1^(ALOG10(tnr_str.F_LOW) + tnr_ch2*tnr_str.D_FREQ) ;; => high " "
rad1_lzl       = rad1_str.F_LOW + rad1_ch1*rad1_str.D_FREQ            ;; => low freq. end of RAD1
rad1_hzl       = rad1_str.F_LOW + rad1_ch2*rad1_str.D_FREQ            ;; => high " "
rad2_lzl       = rad2_str.F_LOW + rad2_ch1*rad2_str.D_FREQ            ;; => low freq. end of RAD2
rad2_hzl       = rad2_str.F_LOW + rad2_ch2*rad2_str.D_FREQ            ;; => high " "
;;  Define all default frequencies for each receiver
tnr_frq        = 1e1^(FINDGEN(tnr_str.N_FREQ)*tnr_str.D_FREQ + ALOG10(tnr_str.F_LOW))
rad1_frq       = FINDGEN(rad1_str.N_FREQ)*rad1_str.D_FREQ + rad1_str.F_LOW
rad2_frq       = FINDGEN(rad2_str.N_FREQ)*rad2_str.D_FREQ + rad2_str.F_LOW

;;  Define time stamp for each column in ASCII files
min_per_day    = 1440L
waves_t_sod    = DINDGEN(min_per_day[0])*6d1  ;;  Seconds of day
;;----------------------------------------------------------------------------------------
;; => Check frequency range keywords
;;----------------------------------------------------------------------------------------
flz            = 0e0
fhz            = 0e0

test_fl0       = KEYWORD_SET(flz0) OR (N_ELEMENTS(flz0) EQ 1)
IF (test_fl0) THEN BEGIN
  ;;  FLOW set => check range
  test_fl0       = (flz0[0] GE tnr_str.F_LOW[0]) AND (flz0[0] LE rad2_str.F_HIGH[0])
  IF (test_fl0) THEN flz = flz0[0] ELSE flz = tnr_str.F_LOW[0]
ENDIF ELSE BEGIN
  ;;  FLOW not set => prompt
  PRINT,''
  READ,flz,PROMPT=low_prompt[0]
  PRINT,''
  flz            = FLOAT(flz)
  test_fl0       = (flz[0] GE tnr_str.F_LOW[0]) AND (flz[0] LE rad2_str.F_HIGH[0])
  IF (test_fl0) THEN flz = flz[0] ELSE flz = tnr_str.F_LOW[0]
ENDELSE

test_fh0       = KEYWORD_SET(fhz0) OR (N_ELEMENTS(fhz0) EQ 1)
IF (test_fh0) THEN BEGIN
  ;;  FHIGH set => check range
  test_fh0       = (fhz0[0] GE tnr_str.F_LOW[0]) AND (fhz0[0] LE rad2_str.F_HIGH[0])
  IF (test_fh0) THEN fhz = fhz0[0] ELSE fhz = rad2_str.F_HIGH[0]
ENDIF ELSE BEGIN
  ;;  FHIGH not set => prompt
  PRINT,''
  READ,fhz,PROMPT=hig_prompt[0]
  PRINT,''
  fhz            = FLOAT(fhz)
  test_fh0       = (fhz[0] GE tnr_str.F_LOW[0]) AND (fhz[0] LE rad2_str.F_HIGH[0])
  test_fh1       = test_fh0 AND (fhz[0] GT flz[0])
  IF (test_fh1) THEN fhz = fhz[0] ELSE fhz = rad2_str.F_HIGH[0]
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Determine the frequency range of input
;;----------------------------------------------------------------------------------------
rec_tags       = ['TNR','RAD1','RAD2']
a_freqs        = CREATE_STRUCT(rec_tags,tnr_frq,rad1_frq,rad2_frq)

good_tnr       = WHERE(tnr_frq  GE flz[0] AND tnr_frq  LE fhz[0],gdtnr)
good_rad1      = WHERE(rad1_frq GE flz[0] AND rad1_frq LE fhz[0],gdrd1)
good_rad2      = WHERE(rad2_frq GE flz[0] AND rad2_frq LE fhz[0],gdrd2)

test           = [gdtnr,gdrd1,gdrd2] GT 0
good           = WHERE(test,gd)
CASE gd[0] OF
  1L   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Only one receiver
    ;;------------------------------------------------------------------------------------
    receivers = STRLOWCASE(rec_tags[good[0]])
    temp      = STRUPCASE(receivers)
    mssg      = 'Getting data for the '+temp[0]+' receiver...'
    nnnf      = MAX(N_ELEMENTS(a_freqs.(good[0])),/NAN)
    MESSAGE,mssg[0],/INFORMATIONAL,/CONTINUE
  END
  2L   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Two receivers
    ;;------------------------------------------------------------------------------------
    receivers = STRLOWCASE(rec_tags[good])
    temp      = STRUPCASE(receivers)
    mssg      = 'Getting data for the '+temp[0]+' and '+temp[1]+' receivers...'
    nnnf      = 256L
    MESSAGE,mssg[0],/INFORMATIONAL,/CONTINUE
  END
  3L   : BEGIN
    ;;------------------------------------------------------------------------------------
    ;; => Three receivers
    ;;------------------------------------------------------------------------------------
    receivers = STRLOWCASE(rec_tags[good])
    temp      = STRUPCASE(receivers)
    mssg      = 'Getting data for the '+temp[0]+' and '+temp[1]+' and '+temp[2]+' receivers...'
    nnnf      = 256L
    MESSAGE,mssg[0],/INFORMATIONAL,/CONTINUE
  END
  ELSE : BEGIN
    MESSAGE,'Bad frequency range',/INFORMATIONAL,/CONTINUE
    RETURN,0
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;; => Determine file names
;;----------------------------------------------------------------------------------------
n_rec          = N_ELEMENTS(receivers)
FOR j=0L, n_rec - 1L DO BEGIN
  files = find_waves_ascii_files(DATE=date,TRANGE=trange,RECEIVER=receivers[j])
  test  = (SIZE(files,/TYPE) EQ 8)
  IF (test) THEN BEGIN
    gfiles   = files.FILES
    good     = WHERE(gfiles NE '')
    ;;  Define file name structure
    gfiles   = gfiles[good]
    str_element,myfiles,STRUPCASE(receivers[j]),gfiles,/ADD_REPLACE
    ;;  Define file date structure
    f_tdates = files.TDATES[good]
    str_element,mydates,STRUPCASE(receivers[j]),f_tdates,/ADD_REPLACE
    ;;  Define file Unix structure
    f_unixs  = files.UNIX_S[good]
    f_unixe  = files.UNIX_E[good]
    str_element,my_unixs,STRUPCASE(receivers[j]),f_unixs,/ADD_REPLACE
    str_element,my_unixe,STRUPCASE(receivers[j]),f_unixe,/ADD_REPLACE
  ENDIF
ENDFOR
;;----------------------------------------------------------------------------------------
;; => Define timestamps for each receiver
;;----------------------------------------------------------------------------------------
time_ra        = time_range_define(DATE=date,TRANGE=trange)
tra            = trange

td1            = 1441L
ntype          = N_TAGS(myfiles)   ;;  # of receivers with ASCII files found
FOR j=0L, ntype - 1L DO BEGIN
  tag0    = STRUPCASE(receivers[j])+'_UNIX'
  tdte    = mydates.(j)            ;;  'YYYY-MM-DD'
  ntf     = N_ELEMENTS(tdte)
  t_0     = my_unixs.(j)           ;;  Unix times at start of day
  sod2d   = (waves_t_sod # REPLICATE(1d0,ntf))          ;;  [1440,N]-Element array
  unx2d   = (REPLICATE(1d0,min_per_day) # t_0) + sod2d  ;;  [1440,N]-Element array
  ;;  Reform to 1D array
  unx1d   = REFORM(unx2d,N_ELEMENTS(unx2d))
  ;;  Sort Result
  sp      = SORT(unx1d)
  unx1d   = unx1d[sp]
  ;;  Add to structure
  str_element,myunix,tag0[0],unx1d,/ADD_REPLACE
ENDFOR
;;----------------------------------------------------------------------------------------
;; => Read in files
;;----------------------------------------------------------------------------------------
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;;  Note:  
;;           MYFILES  :  Structure containing the full file path of the relevant files
;;                         to retrieve
;;           MYDATES  :  Structure containing the dates of the relevant files
;;           MYDATA   :  Structure containing the data from the relevant files
;;                         {X=1440-Unix times, Y=[1440,N-Freqs]-Element array of data}
;;           MYBKG    :  Structure containing the background data from the relevant files
;;                         {X=1440-Unix times, Y=[1440,N-Freqs]-Element array of data}
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ntype          = N_TAGS(myfiles)        ;;  # of receiver type ASCII files found
td1            = 1441L
FOR j=0L, ntype - 1L DO BEGIN
  fname      = receivers[j]
  tag0       = STRUPCASE(fname[0])+'_DATA'
  trec       = STRLOWCASE(STRMID(fname[0],0L,3L))
  tfll       = myfiles.(j)              ;;  File names
  tdte       = mydates.(j)              ;;  'YYYY-MM-DD'
  ntf        = N_ELEMENTS(tdte)         ;;  # of dates
  t_0        = my_unixs.(j)             ;;  Unix times at start of day
  unx        = myunix.(j)               ;;  WAVES timesteps [Unix]
  dumb_tnr   = REPLICATE(f,ntf*(td1 - 1L), 96L)
  dumb_rad   = REPLICATE(f,ntf*(td1 - 1L),256L)
  dumb_bkg   = REPLICATE(f,ntf,256L)
  CASE trec[0] OF
    'tnr' : BEGIN
      t_data    = waves_tnr_file_read(tfll)
      IF (gdtnr GT 0) THEN BEGIN
        gfreqs  = tnr_frq[good_tnr]
        good_fq = good_tnr
      ENDIF ELSE BEGIN
        gfreqs  = f
      ENDELSE
    END
    'rad' : BEGIN
      t_data    = waves_rad_file_read(tfll)
      IF (gdrd1 GT 0 OR gdrd2 GT 0) THEN BEGIN
        IF (STRUPCASE(fname[0]) EQ 'RAD1') THEN BEGIN
          gfreqs  = rad1_frq[good_rad1]
          good_fq = good_rad1
        ENDIF ELSE BEGIN
          gfreqs  = rad2_frq[good_rad2]
          good_fq = good_rad2
        ENDELSE
      ENDIF ELSE BEGIN
        gfreqs = f
      ENDELSE
    END
    ELSE  : BEGIN
      t_data    = {DATA:dumb_rad,BKG:dumb_bkg}
      good_fq   = -1
      gfreqs    = REPLICATE(f,256L)
    END
  ENDCASE
  data   = t_data.DATA       ;;  [K,F]-Element array  [K = (N * 1440)]
  bkgd   = t_data.BKG        ;;  [N,F]-Element array
  ;;--------------------------------------------------------------------------------------
  ;;  Change background array to match size of DATA array
  ;;--------------------------------------------------------------------------------------
  szd    = SIZE(data,/DIMENSIONS)
  nbkgd  = REPLICATE(f,szd)  ;;  [K,F]-Element array  [K = (N * 1440)]
  dn_el  = 0L
  up_el  = 0L
  n_p_d  = min_per_day[0]
  FOR k=0L, ntf - 1L DO BEGIN
    dn_el          = k[0]*n_p_d[0]               ;;  lower bound for elements
    up_el          = dn_el[0] + (n_p_d[0] - 1L)  ;;  upper " "
    n_el           = up_el[0] - dn_el[0] + 1L
    g_ind          = LINDGEN(n_el) + dn_el[0]
    nbkgd[g_ind,*] = REFORM(REPLICATE(1e0,n_el) # REFORM(bkgd[k,*]))
  ENDFOR
  ;;--------------------------------------------------------------------------------------
  ;; => Change units if desired
  ;;--------------------------------------------------------------------------------------
  IF KEYWORD_SET(nodcbls) THEN data  *=  nbkgd
  ;;--------------------------------------------------------------------------------------
  ;;  Limit time range
  ;;--------------------------------------------------------------------------------------
  good   = WHERE(tra[0] LE unx AND tra[1] GE unx AND good_fq[0] GE 0,gd)
  IF (gd GT 0) THEN BEGIN
    ;;  Keep only elements within time range of interest
    g_unx  = unx[good]
    gdata  = data[good,*]
    g_bkg  = nbkgd[good,*]
    ;;  Keep only elements within frequency range of interest
    gdata  = gdata[*,good_fq]
    g_bkg  = g_bkg[*,good_fq]
    ;;  Define output structure
    g_str  = {X:g_unx,Y:gdata,F:gfreqs,BKG:g_bkg}
  ENDIF ELSE BEGIN
    g_str  = {X:unx,Y:dumb_rad,F:REPLICATE(f,256L),BKG:dumb_rad}
  ENDELSE
  str_element,mydata,tag0[0],g_str,/ADD_REPLACE
ENDFOR
;;----------------------------------------------------------------------------------------
;; => Reformat data structures
;;----------------------------------------------------------------------------------------
tags      = STRMID(TAG_NAMES(mydata),0L,4L)
g_tnr     = WHERE(tags EQ 'TNR_',gtnr)
g_rad1    = WHERE(tags EQ 'RAD1',grd1)
g_rad2    = WHERE(tags EQ 'RAD2',grd2)
nt        = N_ELEMENTS(tags)
;;------------------------------------------
;; => WAVES/TNR
;;------------------------------------------
num_times = 0L
num_freqs = 0L
IF (gtnr GT 0) THEN BEGIN
  temp          = mydata.(g_tnr[0])
  num_times     = N_ELEMENTS(temp.X)
  num_freqs     = num_freqs > N_ELEMENTS(temp.F)
  all_data_tnr  = FLTARR(num_times,num_freqs)   ;; => All the data in format : [times,frequencies]
  all_times_tnr = DBLARR(num_times)             ;; => All frequencies
  all_freqs_tnr = FLTARR(num_freqs)             ;; => All Unix times
  all_bkgd_tnr  = FLTARR(num_times,num_freqs)   ;; => All background data
  ;;  Fill arrays
  all_data_tnr  = temp.Y
  all_times_tnr = temp.X
  all_freqs_tnr = temp.F
  all_bkgd_tnr  = temp.BKG
ENDIF ELSE BEGIN
  num_times     = 100L
  num_freqs     = 10L
  all_data_tnr  = REPLICATE(f,num_times,num_freqs)
  all_times_tnr = REPLICATE(d,num_times)
  all_freqs_tnr = REPLICATE(f,num_freqs)
  all_bkgd_tnr  = REPLICATE(f,num_times,num_freqs)
ENDELSE

;;------------------------------------------
;; => WAVES/RAD1
;;------------------------------------------
num_times = 0L
num_freqs = 0L
IF (grd1 GT 0) THEN BEGIN
  temp          = mydata.(g_rad1[0])
  num_times     = N_ELEMENTS(temp.X)
  num_freqs     = num_freqs > N_ELEMENTS(temp.F)
  all_data_rd1  = FLTARR(num_times,num_freqs)   ;; => All the data in format : [times,frequencies]
  all_times_rd1 = DBLARR(num_times)             ;; => All frequencies
  all_freqs_rd1 = FLTARR(num_freqs)             ;; => All Unix times
  all_bkgd_rd1  = FLTARR(num_times,num_freqs)   ;; => All background data
  ;;  Fill arrays
  all_data_rd1  = temp.Y
  all_times_rd1 = temp.X
  all_freqs_rd1 = temp.F
  all_bkgd_rd1  = temp.BKG
ENDIF ELSE BEGIN
  num_times     = 100L
  num_freqs     = 10L
  all_data_rd1  = REPLICATE(f,num_times,num_freqs)
  all_times_rd1 = REPLICATE(d,num_times)
  all_freqs_rd1 = REPLICATE(f,num_freqs)
  all_bkgd_rd1  = REPLICATE(f,num_times,num_freqs)
ENDELSE

;;------------------------------------------
;; => WAVES/RAD2
;;------------------------------------------
num_times = 0L
num_freqs = 0L
IF (grd2 GT 0) THEN BEGIN
  temp          = mydata.(g_rad2[0])
  num_times     = N_ELEMENTS(temp.X)
  num_freqs     = num_freqs > N_ELEMENTS(temp.F)
  all_data_rd2  = FLTARR(num_times,num_freqs)   ;; => All the data in format : [times,frequencies]
  all_times_rd2 = DBLARR(num_times)             ;; => All frequencies
  all_bkgd_rd2  = FLTARR(num_times,num_freqs)   ;; => All background data
  ;;  Fill arrays
  all_data_rd2  = temp.Y
  all_times_rd2 = temp.X
  all_freqs_rd2 = temp.F
  all_bkgd_rd2  = temp.BKG
ENDIF ELSE BEGIN
  num_times     = 100L
  num_freqs     = 10L
  all_data_rd2  = REPLICATE(f,num_times,num_freqs)
  all_times_rd2 = REPLICATE(d,num_times)
  all_freqs_rd2 = REPLICATE(f,num_freqs)
  all_bkgd_rd2  = REPLICATE(f,num_times,num_freqs)
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Define dummy return structures
;;----------------------------------------------------------------------------------------
tnr_data       = {X:all_times_tnr,Y:all_data_tnr,V:all_freqs_tnr,SPEC:1}
rad1_data      = {X:all_times_rd1,Y:all_data_rd1,V:all_freqs_rd1,SPEC:1}
rad2_data      = {X:all_times_rd2,Y:all_data_rd2,V:all_freqs_rd2,SPEC:1}

rec            = ['TNR','RAD1','RAD2']
bkgd_struc     = CREATE_STRUCT(rec,all_bkgd_tnr,all_bkgd_rd1,all_bkgd_rd2)
data_structure = CREATE_STRUCT(rec,tnr_data,rad1_data,rad2_data)
tags           = ['DATA','BKG']
struct         = CREATE_STRUCT(tags,data_structure,bkgd_struc)
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,struct
END
