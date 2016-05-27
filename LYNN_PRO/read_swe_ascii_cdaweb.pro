;+
;*****************************************************************************************
;
;  FUNCTION :   read_swe_ascii_cdaweb.pro
;  PURPOSE  :   Reads in ASCII files produced on CDAWeb from the Wind SWE experiment
;                 with H1 100 second proton moments from nonlinear analysis.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               my_str_date.pro
;               time_double.pro
;               read_gen_ascii.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII files with name formats:
;                     SWE_YYYY-MM-DD_hhmm_YYYY-MM-DD_hhmm_Vsw-Vth-Np.txt
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               date = '051500'
;               test = read_swe_ascii_cdaweb(DATE=date)
;
;  KEYWORDS:    
;               DATE    :  [string] 'MMDDYY' [MM=month, DD=day, YY=year] defining the
;                            start date of interest
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data [Unix time]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  To create appropriate ASCII files for this routine, go to CDAWeb
;                     [http://cdaweb.gsfc.nasa.gov/] and do the following:
;                     A)  choose "Public data from current (1992 -> present)..."
;                     B)  choose Wind spacecraft and click "Submit"
;                     C)  Select the "Click here to CLEAR All checkboxes, OR" option
;                     D)  Select only WI_H1_SWE, then hit "Submit"
;                     E)  Choose a relevant time range and click on the following:
;                               [choose both nonlinear and moment for all]
;                           i)  Proton bulk speed, and XYZ-GSE bulk velocities
;                          ii)  Scalar proton thermal speed W (km/s)
;                         iii)  Proton thermal speed Wperpendicular [and parallel] (km/s)
;                          iv)  Proton number density Np (n/cc)
;                     F)  Choose "List Data (ASCII)" option, then hit "Submit"
;                     G)  Copy data and save
;                     H)  Make sure the last 2 lines are not left at the bottom of the
;                           ASCII file to avoid file reading errors
;                     I)  You may remove header if you with, but make sure you keep the 
;                           column labels and units
;
;   CREATED:  06/07/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/07/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION read_swe_ascii_cdaweb,DATE=date,TRANGE=trange

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Determine date of interest
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(trange) THEN BEGIN
  mydate = my_str_date(DATE=date)
ENDIF ELSE BEGIN
  tra    = DOUBLE(trange)
  mts    = my_time_string(tra,UNIX=1,/NOM)
  ymdb   = mts.DATE_TIME    ; => 'YYYY-MM-DD/HH:MM:SS.sss'
  ydts   = STRMID(ymdb[*],8L,2L)  ; => Check days
  fdates = STRMID(ymdb[*],5L,2L)+STRMID(ymdb[*],8L,2L)+STRMID(ymdb[*],2L,2L)
  IF KEYWORD_SET(date) THEN BEGIN
    mydate = my_str_date(DATE=date)
  ENDIF ELSE BEGIN
    mydate = my_str_date(DATE=fdates[0])
  ENDELSE
ENDELSE
dir_date = mydate.S_DATE[0]  ; => ['MMDDYY']
mdate    = mydate.DATE[0]    ; => ['YYYYMMDD']
ldate    = mdate
zdate    = mydate.TDATE[0]
;-----------------------------------------------------------------------------------------
; => Define possible file names
;-----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(exists) THEN BEGIN
  mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/Wind_SWE_ASCII/')
ENDIF ELSE BEGIN
  mdir = !wind3dp_umn.WIND_DATA_DIR+'Wind_SWE_ASCII/'
  IF (mdir[0] EQ '') THEN mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/Wind_SWE_ASCII/')
ENDELSE
;-----------------------------------------------------------------------------------------
; => Find files
;-----------------------------------------------------------------------------------------
; => Only the file name (e.g. 'SWE_2000-05-15_1600_2000-05-16_0000_Vsw-Vth-Np.txt')
mfile    = ''
tdates   = ''                            ; => Start date associated with each file
tdatee   = ''                            ; => End   date associated with each file
uttimes  = ''                            ; => Start time for each file [e.g. 'hhmm']
uttimee  = ''                            ; => End   time for each file [e.g. 'hhmm']
ftrange  = ''                            ; => Time range of files 'YYYY-MM-DD/HH:MM:SS.sss'
funixra  = 0d0                           ; => Unix time range of files

allfiles = FILE_SEARCH(mdir,'*.txt')     ; => All files with entire path set
t_length = STRLEN('SWE_YYYY-MM-DD_hhmm_YYYY-MM-DD_hhmm_Vsw-Vth-Np.cdf') - 1L
mfile    = STRMID(STRCOMPRESS(allfiles[*],/REMOVE),t_length,/REVERSE)
; => Define date/time ranges of files
tdates   = STRMID(mfile[*],4L,10L)       ; => Start date associated w/ file ['YYYY-MM-DD']
tdatee   = STRMID(mfile[*],20L,10L)      ; => End   date associated w/ file ['YYYY-MM-DD']
uttimes  = STRMID(mfile[*],15L,4L)       ; => Start times
uttimee  = STRMID(mfile[*],31L,4L)       ; => Start times
uttimes  = STRMID(uttimes[*],0L,2L)+':'+STRMID(uttimes[*],2L,2L)+':'+'00.000'
uttimee  = STRMID(uttimee[*],0L,2L)+':'+STRMID(uttimee[*],2L,2L)+':'+'00.000'

ftrange  = [[tdates+'/'+uttimes],[tdatee+'/'+uttimee]]
funixra  = time_double(ftrange)
;-----------------------------------------------------------------------------------------
; => Find which file(s) is(are) needed
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(tra) THEN BEGIN
  good  = WHERE(tdates EQ zdate[0],gd)
ENDIF ELSE BEGIN
  good0 = WHERE(tra[0] GE funixra[*,0] AND tra[0] LE funixra[*,1],gd0)
  good1 = WHERE(tra[1] GE funixra[*,0] AND tra[1] LE funixra[*,1],gd1)
  IF (gd0 GT 0 OR gd1 GT 0) THEN BEGIN
    IF (gd0 GT 0 AND gd1 GT 0) THEN BEGIN
      ; => both start and end times overlap with part of user defined time range
      good = WHERE(tra[0] GE funixra[*,0] AND tra[1] LE funixra[*,1],gd)
    ENDIF ELSE BEGIN
      IF (gd0 GT 0) THEN BEGIN
        ; => start times overlap with part of user defined time range
        good = WHERE(tra[0] GE funixra[*,0] AND tra[0] LE funixra[*,1],gd)
      ENDIF ELSE BEGIN
        ; => end   times overlap with part of user defined time range
        good = WHERE(tra[1] GE funixra[*,0] AND tra[1] LE funixra[*,1],gd)
      ENDELSE
    ENDELSE
  ENDIF ELSE BEGIN
    gd   = 0
    good = -1
  ENDELSE
ENDELSE

IF (gd GT 0) THEN BEGIN
  ttfile = allfiles[good]
  tyfile = STRARR(gd)
  FOR j=0L, gd - 1L DO BEGIN
    tyfile[j] = FILE_SEARCH(ttfile[j])
  ENDFOR
ENDIF ELSE BEGIN
  MESSAGE,'No files were found...',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check for SWE ASCII files
;-----------------------------------------------------------------------------------------
goodf  = WHERE(tyfile NE '',gg)
IF (gg GT 0) THEN BEGIN
  tyfile = tyfile[goodf]
ENDIF ELSE BEGIN
  MESSAGE,'No files were found...',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define dummy variables and read in data
;-----------------------------------------------------------------------------------------
nf    = N_ELEMENTS(tyfile)
jj    = 0
past  = 0
kpast = 0
WHILE (jj LE nf - 1L) DO BEGIN
  temp   = read_gen_ascii(tyfile[jj])
  nn     = N_ELEMENTS(temp)
  FOR k=0L, nn - 1L DO BEGIN
    test = STRLOWCASE(STRMID(temp[k],0L,22L)) EQ 'dd-mm-yyyy_hh:mm:ss.ms'
    IF (test) THEN BEGIN
      past  = 1
      kpast = k
    ENDIF
    IF (past AND k GT kpast) THEN BEGIN
      tstamp  = STRMID(temp[k],0L,23L)
      ; => fix time stamp to 'YYYY-MM-DD/HH:MM:SS.sss' format
      ts_date = STRMID(tstamp,6L,4L)+'-'+STRMID(tstamp,3L,2L)+'-'+STRMID(tstamp,0L,2L)
      ts_time = STRMID(tstamp,11L)
      ts_ymdb = ts_date[0]+'/'+ts_time[0]
      IF (k EQ kpast + 1) THEN ymdb0 = ts_ymdb[0] ELSE ymdb0 = [ymdb0,ts_ymdb[0]]
      tdata   = STRMID(temp[k],23L)
      st0     = STRSPLIT(tdata,'  ',/EXTRACT)
      ; => Define data
      IF (k EQ kpast + 1) THEN BEGIN
        ; => Nonlinear analysis
        vmagnl0 = DOUBLE(st0[0L])        ; => |Vsw|   [km/s]
        vswnl0x = DOUBLE([st0[1L]])      ; => Vsw,x   [km/s]
        vswnl0y = DOUBLE([st0[2L]])      ; => Vsw,y   [km/s]
        vswnl0z = DOUBLE([st0[3L]])      ; => Vsw,z   [km/s]
        vtherl0 = DOUBLE([st0[4L]])      ; => Vtherm  [km/s]
        vtheral = DOUBLE([st0[5L]])      ; => Vthperp [km/s]
        vtherel = DOUBLE([st0[6L]])      ; => Vthpara [km/s]
        densnl0 = DOUBLE(st0[7L])        ; => Density [cm^(-3)]
        ; => Moment analysis
        vmagmo0 = DOUBLE(st0[8L])        ; => |Vsw|
        vswmo0x = DOUBLE([st0[9L]])
        vswmo0y = DOUBLE([st0[10L]])
        vswmo0z = DOUBLE([st0[11L]])
        vtherm0 = DOUBLE([st0[12L]])     ; => Vtherm
        vtheram = DOUBLE([st0[13L]])     ; => Vthperp [km/s]
        vtherem = DOUBLE([st0[14L]])     ; => Vthpara [km/s]
        densmo0 = DOUBLE(st0[15L])       ; => Density [cm^(-3)]
      ENDIF ELSE BEGIN
        ; => Nonlinear analysis
        vmagnl0 = [vmagnl0,DOUBLE(st0[0L])]
        vswnl0x = [vswnl0x,DOUBLE([st0[1L]])]
        vswnl0y = [vswnl0y,DOUBLE([st0[2L]])]
        vswnl0z = [vswnl0z,DOUBLE([st0[3L]])]
        vtherl0 = [vtherl0,DOUBLE([st0[4L]])]
        vtheral = [vtheral,DOUBLE([st0[5L]])]
        vtherel = [vtherel,DOUBLE([st0[6L]])]
        densnl0 = [densnl0,DOUBLE(st0[7L])]
        ; => Moment analysis
        vmagmo0 = [vmagmo0,DOUBLE(st0[7L])]
        vswmo0x = [vswmo0x,DOUBLE([st0[9L]])]
        vswmo0y = [vswmo0y,DOUBLE([st0[10L]])]
        vswmo0z = [vswmo0z,DOUBLE([st0[11L]])]
        vtherm0 = [vtherm0,DOUBLE([st0[12L]])]
        vtheram = [vtheram,DOUBLE([st0[13L]])]
        vtherem = [vtherem,DOUBLE([st0[14L]])]
        densmo0 = [densmo0,DOUBLE(st0[15L])]
      ENDELSE
    ENDIF
  ENDFOR
  ; => Add to arrays
  IF (jj EQ 0) THEN BEGIN
    ymdb     = ymdb0
    ; => Nonlinear analysis
    vmag_nl  = vmagnl0
    vsw_nl   = [[vswnl0x],[vswnl0y],[vswnl0z]]
    vth_nl   = vtherl0
    vthpa_nl = vtheral
    vthpe_nl = vtherel
    dens_nl  = densnl0
    ; => Moment analysis
    vmag_mo  = vmagmo0
    vsw_mo   = [[vswmo0x],[vswmo0y],[vswmo0z]]
    vth_mo   = vtherm0
    vthpa_mo = vtheram
    vthpe_mo = vtherem
    dens_mo  = densmo0
  ENDIF ELSE BEGIN
    ymdb     = [ymdb,ymdb0]
    ; => Nonlinear analysis
    vmag_nl  = [vmag_nl,vmagnl0]
    testv    = [[vswnl0x],[vswnl0y],[vswnl0z]]
    vsw_nl   = [vsw_nl,testv]
    vth_nl   = [vth_nl,vtherl0]
    vthpa_nl = [vthpa_nl,vtheral]
    vthpe_nl = [vthpe_nl,vtherel]
    dens_nl  = [dens_nl,densnl0]
    ; => Moment analysis
    vmag_mo  = [vmag_mo,vmagmo0]
    testv    = [[vswmo0x],[vswmo0y],[vswmo0z]]
    vsw_mo   = [vsw_mo,testv]
    vth_mo   = [vth_mo,vtherm0]
    vthpa_mo = [vthpa_mo,vtheram]
    vthpe_mo = [vthpe_mo,vtherem]
    dens_mo  = [dens_mo,densmo0]
  ENDELSE
  jj   += 1
  past  = 0
  kpast = -1
ENDWHILE
;-----------------------------------------------------------------------------------------
; => sort data
;-----------------------------------------------------------------------------------------
unix     = time_double(ymdb)
sp       = SORT(unix)
unix     = unix[sp]
ymdb     = ymdb[sp]
IF KEYWORD_SET(tra) THEN BEGIN
  good = WHERE(unix GE tra[0] AND unix LE tra[1],gd)
  IF (gd GT 0) THEN sp = sp[good] ELSE RETURN,0
ENDIF
unix     = unix[sp]
ymdb     = ymdb[sp]
; => Nonlinear analysis
vmag_nl  = vmag_nl[sp]
vsw_nl   = vsw_nl[sp,*]
vth_nl   = vth_nl[sp]
vthpa_nl = vthpa_nl[sp]
vthpe_nl = vthpe_nl[sp]
dens_nl  = dens_nl[sp]
; => Moment analysis
vmag_mo  = vmag_mo[sp]
vsw_mo   = vsw_mo[sp,*]
vth_mo   = vth_mo[sp]
vthpa_mo = vthpa_mo[sp]
vthpe_mo = vthpe_mo[sp]
dens_mo  = dens_mo[sp]
;-----------------------------------------------------------------------------------------
; => Define structure to return to user
;-----------------------------------------------------------------------------------------
tags  = ['SCETS','UNIX','NONLINEAR','MOMENTS']
tagnl = ['V_MAG','VSW','VTH','VTH_PARA','VTH_PERP','DENS_PROTON']
nonst = CREATE_STRUCT(tagnl,vmag_nl,vsw_nl,vth_nl,vthpa_nl,vthpe_nl,dens_nl)
momst = CREATE_STRUCT(tagnl,vmag_mo,vsw_mo,vth_mo,vthpa_mo,vthpe_mo,dens_mo)
strut = CREATE_STRUCT(tags,ymdb,unix,nonst,momst)

RETURN,strut
END
