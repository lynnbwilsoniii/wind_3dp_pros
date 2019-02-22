;+
;*****************************************************************************************
;
;  FUNCTION :   fix_bfield_data.pro
;  PURPOSE  :   Removes data spikes and zeroed values from the Wind MFI data.
;
;  CALLED BY:   
;               read_wind_mfi.pro
;
;  CALLS:
;               interp.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               UNIX    :  N-Element array of Unix times
;               FIELD   :  [N,3]-Element array of B-field data
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               THRESH  :  Scalar value defining the maximum absolute value for the
;                            any B-field component [Default = 3d4]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  User should not call this routine
;
;   CREATED:  02/25/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/25/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION fix_bfield_data,unix,field,THRESH=thresh

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
IF NOT KEYWORD_SET(thresh) THEN thsh = 3d4 ELSE thsh = (DOUBLE(thresh[0]))[0]

data   = REFORM(field)
time   = REFORM(unix)
nt     = N_ELEMENTS(time)
good   = WHERE(FINITE(time),gd)
IF (gd EQ 0) THEN BEGIN
  mssg = 'No finite time stamps found...'
  MESSAGE,mssg,/INFORMATIONAL,/CONTINUE
  RETURN,{X:REPLICATE(d,nt),Y:REPLICATE(d,nt,3L)}
ENDIF

nt     = gd
data   = data[good,*]
time   = time[good]
;-----------------------------------------------------------------------------------------
; => Eliminate data spikes/gaps
;-----------------------------------------------------------------------------------------
testx  = (ABS(data[*,0]) GT thsh[0])
testy  = (ABS(data[*,1]) GT thsh[0])
testz  = (ABS(data[*,2]) GT thsh[0])

badx   = WHERE(testx,bdx,COMPLEMENT=goodx,NCOMPLEMENT=gdx)
bady   = WHERE(testy,bdy,COMPLEMENT=goody,NCOMPLEMENT=gdy)
badz   = WHERE(testz,bdz,COMPLEMENT=goodz,NCOMPLEMENT=gdz)
IF (bdx GT 0) THEN data[badx,0] = f
IF (bdy GT 0) THEN data[bady,1] = f
IF (bdz GT 0) THEN data[badz,2] = f
; => Fix NaNs in data
spmagx = SMOOTH(data[*,0],1,/EDGE_TRUNCATE,/NAN)
spmagy = SMOOTH(data[*,1],1,/EDGE_TRUNCATE,/NAN)
spmagz = SMOOTH(data[*,2],1,/EDGE_TRUNCATE,/NAN)
sdata  = [[spmagx],[spmagy],[spmagz]]
;-----------------------------------------------------------------------------------------
; => Get rid of non-finite or zeroed data by interpolating
;-----------------------------------------------------------------------------------------
testx  = (ABS(sdata[*,0]) EQ 0.) OR (FINITE(sdata[*,0]) EQ 0)
testy  = (ABS(sdata[*,1]) EQ 0.) OR (FINITE(sdata[*,1]) EQ 0)
testz  = (ABS(sdata[*,2]) EQ 0.) OR (FINITE(sdata[*,2]) EQ 0)

badx   = WHERE(testx,bdx,COMPLEMENT=goodx,NCOMPLEMENT=gdx)
bady   = WHERE(testy,bdy,COMPLEMENT=goody,NCOMPLEMENT=gdy)
badz   = WHERE(testz,bdz,COMPLEMENT=goodz,NCOMPLEMENT=gdz)

sdatx  = REPLICATE(d,nt)
sdaty  = REPLICATE(d,nt)
sdatz  = REPLICATE(d,nt)
IF (gdx GT 0) THEN sdatx = interp(sdata[goodx,0],time[goodx],time,/NO_EXTRAP)
IF (gdy GT 0) THEN sdaty = interp(sdata[goody,1],time[goody],time,/NO_EXTRAP)
IF (gdz GT 0) THEN sdatz = interp(sdata[goodz,2],time[goodz],time,/NO_EXTRAP)
sdata  = [[sdatx],[sdaty],[sdatz]]
;-----------------------------------------------------------------------------------------
; => Return data to user
;-----------------------------------------------------------------------------------------

RETURN,{X:time,Y:sdata}
END


;+
;*****************************************************************************************
;
;  FUNCTION :  read_wind_mfi.pro
;  PURPOSE  :  Reads in 3-second Magnetic Field Instrument (MFI) data from 
;               the Wind spacecraft and returns a structure composed of the
;               the GSE magnetic field, its magnitude, and the times 
;               associated with the data in seconds of day (default tag is in
;               unix time).
;
;  CALLS:  
;               time_range_define.pro
;               read_cdf.pro
;               epoch2unix.pro
;               fix_bfield_data.pro
;
;  REQUIRES:  
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  Wind 3s CDF files from CDAWeb
;                     e.g. 'wi_h0_mfi_YYYYMMDD.cdf'
;
;  INPUT:       
;               NA
;
;  KEYWORDS:  
;               DATE    :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures [Unix time]
;
;   CHANGED:  1)  Added keyword:  ALLF                        [09/03/2008   v1.1.2]
;             2)  Fixed an indexing issue and typo            [11/18/2008   v1.1.3]
;                  *[Only affected output for DATE='021100']*
;             3)  Fixed an interpolation abscissa issue       [11/18/2008   v1.1.4]
;                  *[Only affected output for DATE='021100']*
;             4)  Added keyword:  TRANGE                      [04/06/2009   v1.2.0]
;             5)  Fixed syntax issue with ALLF keyword        [05/04/2009   v1.2.1]
;             6)  Fixed syntax issue of array vs scalar values of dates
;                                                             [05/06/2009   v1.2.2]
;             7)  Changed some syntax but not functionality   [07/27/2009   v1.2.3]
;             8)  No longer prints out annoying message from CDF_VARGET.PRO
;                  % CDF_VARGET: Function completed but: VIRTUAL_RECORD_DATA: ....
;                                                             [08/03/2009   v1.2.4]
;             9)  Eliminated dependence on ab_aeterno_7.pro   [09/01/2009   v1.2.5]
;            10)  Changed the manner in which data spikes are dealt with
;                                                             [09/02/2009   v1.2.6]
;            11)  Returned !QUIET to its default setting after calling read_cdf.pro
;                                                             [09/03/2009   v1.2.7]
;            12)  Changed location of CDF files and file searching algorithm
;                   and changed program my_shock_times.pro to read_shocks_jck_database.pro
;                                                             [09/16/2009   v1.3.0]
;            13)  Changed smoothing of NaNs to component by component
;                                                             [09/26/2009   v1.4.0]
;            14)  Fixed syntax issue of program redefining the DATE keyword
;                                                             [10/22/2009   v1.4.1]
;            15)  Fixed some error handling and freeing of pointers
;                                                             [10/22/2009   v1.4.2]
;            16)  Fixed a typo when both DATE and TRANGE keywords were set, specifically
;                   when the date for the start time is before the date defined by
;                   the DATE keyword                          [11/11/2009   v1.5.0]
;            17)  Changed output to include GSE and GSM satellite positions
;                                                             [01/07/2010   v1.6.0]
;            18)  Changed output to include 3s GSM B-field data
;                                                             [04/26/2010   v1.7.0]
;            19)  Fixed a mistake for the time stamp associated with the spacecraft
;                   positions and added routine fix_bfield_data.pro
;                                                             [02/25/2011   v2.0.0]
;            20)  Removed run-time statement produced by my_time_string.pro
;                                                             [03/04/2011   v2.0.1]
;            21)  Changed file location algorithm and now calls
;                   time_range_define.pro and no longer allows ALLF keyword
;                                                             [01/25/2012   v2.1.0]
;            22)  Changed return structure format             [01/26/2012   v2.2.0]
;
;   NOTES:      
;               1)  Initialize the IDL directories with start_umn_3dp.pro prior
;                     to use.
;
;   CREATED:  02/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/26/2012   v2.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION read_wind_mfi,DATE=date,TRANGE=trange

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Determine time range of interest
;-----------------------------------------------------------------------------------------
fdate    = ''    ; => ('YYYYMMDD')
zdate0   = ''    ; => Start date ['YYYY-MM-DD']
zdate1   = ''    ; => End date ['YYYY-MM-DD']
time_ra  = time_range_define(DATE=date,TRANGE=trange)

tra      = time_ra.TR_UNIX
tdates   = time_ra.TDATE_SE
zdate0   = tdates[0]
zdate1   = tdates[1]
fdate    = STRMID(tdates[*],0L,4L)+STRMID(tdates[*],5L,2L)+STRMID(tdates[*],8L,2L)
;-----------------------------------------------------------------------------------------
; => Define possible file names
;-----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(EXISTS) THEN BEGIN
  mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/MFI_CDF/')
ENDIF ELSE BEGIN
  mdir = !wind3dp_umn.WIND_MFI_CDF_DIR
  IF (mdir[0] EQ '') THEN mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/MFI_CDF/')
ENDELSE
mfile    = ''                            ; => Only the file name (e.g. 'wi_h0_mfi_19950401_v04.cdf')
tdate    = ''                            ; => Date associated with each file
allfiles = FILE_SEARCH(mdir,'*.cdf')     ; => All files with entire path set
t_length = STRLEN('wi_h0_mfi_????????_v04.cdf') - 1L
mfile    = STRMID(STRCOMPRESS(allfiles[*],/REMOVE),t_length,/REVERSE)
tdate    = STRMID(mfile[*],10L,8L)       ; => Date associated w/ file ['YYYYMMDD']
gdate    = tdate
;-----------------------------------------------------------------------------------------
; => Find which file(s) is(are) needed
;-----------------------------------------------------------------------------------------
gdated   = 1d0*gdate
good     = WHERE(gdated GE fdate[0]*1d0 AND gdated LE fdate[1]*1d0,gd)
IF (gd GT 0) THEN BEGIN
  ; => Files found
  ttfile = allfiles[good]
  tyfile = STRARR(gd)
  FOR j=0L, gd - 1L DO BEGIN
    tyfile[j] = FILE_SEARCH(ttfile[j])
  ENDFOR
ENDIF ELSE BEGIN
  ; => No files
  errmsg = 'No 3s CDF files for desired time range!'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check cdf B-field files
;-----------------------------------------------------------------------------------------
goodf  = WHERE(tyfile NE '',gg)
IF (gg GT 0) THEN BEGIN
  tyfile = tyfile[goodf]
ENDIF ELSE BEGIN
  ; => No files
  errmsg = 'No 3s CDF files for desired time range!'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define desired tag names in pointer array of CDF files
;-----------------------------------------------------------------------------------------
nsat    = 'Wind'
bname   = 'B3GSE'   ; => CDF tag for 3s GSE B-field data
bname2  = 'B3GSM'   ; => CDF tag for 3s GSM B-field data
btname  = 'Epoch3'  ; => " " 3s Epoch times

posepoc = 'Epoch'   ; => Epoch time associated with Wind SC positions
gsmposs = 'PGSM'    ; => " " GSM Satellite positions
gseposs = 'PGSE'    ; => " " GSE Satellite positions
raddiss = 'DIST'    ; => " " Radial Satellite Distances
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
dumbvec = REPLICATE(d,28800L,3L)
dumbarr = REPLICATE(d,28800L)

tgsemag = 0d0                           ; => Dummy Var. for 3s GSE B-field
tgsmmag = 0d0                           ; => " " for 3s GSM B-field
tempepo = 0d0                           ; => " " Epoch times associated with 3s B-fields
tempunx = 0d0                           ; => " " Unix times associated with 3s B-fields

tgsepos = 0d0                           ; => " " for GSE positions (R_e)
tgsmpos = 0d0                           ; => " " for GSM positions (R_e)
tempep0 = 0d0                           ; => " " Epoch times associated with positions
tempun0 = 0d0                           ; => " " Unix times associated with positions

qq = 1
j  = 0L
cc = 0L
WHILE(qq) DO BEGIN
  ; => Read CDF file
  windmm = read_cdf(tyfile[j],dataww,varww,/NOTIME)
  ;---------------------------------------------------------------------------------------
  ; => Check on B-field tags
  ;---------------------------------------------------------------------------------------
  g_bgse = WHERE(varww[*,0] EQ bname,ggse)   ; => Elements of Pointer for 3-Second GSE data
  g_bgsm = WHERE(varww[*,0] EQ bname2,ggsm)  ; => Elements of Pointer for 3-Second GSM data
  g_epo3 = WHERE(varww[*,0] EQ btname,gep3)  ; => Element for Epoch times
  ; => Define dummy variables
  IF (ggse GT 0) THEN tgsemag = *dataww[g_bgse[0]]  ELSE tgsemag = dumbvec
  IF (ggsm GT 0) THEN tgsmmag = *dataww[g_bgsm[0]]  ELSE tgsmmag = dumbvec
  IF (gep3 GT 0) THEN tempepo = *dataww[g_epo3[0]]  ELSE tempepo = dumbarr
  nmag = TOTAL(FINITE(tempepo))
  IF (nmag GT 0) THEN BEGIN
    ; => Remove bad data points
    bad     = WHERE(tempepo LT 0. OR FINITE(tempepo) EQ 0,bd)
    IF (bd GT 0) THEN tempepo[bad] = d
    ; => Convert Epoch times to Unix
    tempunx = epoch2unix(tempepo)
  ENDIF ELSE BEGIN
    tempunx = dumbarr
  ENDELSE
  ;---------------------------------------------------------------------------------------
  ; => Check on position tags
  ;---------------------------------------------------------------------------------------
  g_epoc = WHERE(varww[*,0] EQ posepoc,gepo)
  g_gsmp = WHERE(varww[*,0] EQ gsmposs,gsmp)
  g_gsep = WHERE(varww[*,0] EQ gseposs,gsep)
  g_radd = WHERE(varww[*,0] EQ raddiss,radp)
  IF (gsep GT 0) THEN tgsepos = *dataww[g_gsep[0]]  ELSE tgsepos = dumbvec
  IF (gsmp GT 0) THEN tgsmpos = *dataww[g_gsmp[0]]  ELSE tgsmpos = dumbvec
  IF (radp GT 0) THEN tradpos = *dataww[g_radd[0]]  ELSE tradpos = dumbvec
  IF (gepo GT 0) THEN tempep0 = *dataww[g_epoc[0]]  ELSE tempep0 = dumbarr
  npos = TOTAL(FINITE(tempep0))
  IF (npos GT 0) THEN BEGIN
    ; => Remove bad data points
    bad     = WHERE(tempep0 LT 0. OR FINITE(tempep0) EQ 0,bd)
    IF (bd GT 0) THEN BEGIN
      tempep0[bad]   = d
      tradpos[bad]   = d
      tgsepos[bad,*] = d
      tgsmpos[bad,*] = d
    ENDIF
    ; => Convert Epoch times to Unix
    tempun0 = epoch2unix(tempep0)
  ENDIF ELSE BEGIN
    tempun0 = dumbarr
  ENDELSE
  ;---------------------------------------------------------------------------------------
  ; => Define 3s GSE B-field data
  ;---------------------------------------------------------------------------------------
  IF (j EQ 0) THEN magf_gse = tgsemag ELSE magf_gse = [magf_gse, tgsemag]
  IF (j EQ 0) THEN magf_gsm = tgsmmag ELSE magf_gsm = [magf_gsm, tgsmmag]
  IF (j EQ 0) THEN magf_unx = tempunx ELSE magf_unx = [magf_unx, tempunx]
  ;---------------------------------------------------------------------------------------
  ; => Define 3s satellite position information
  ;---------------------------------------------------------------------------------------
  IF (j EQ 0) THEN wpos_gse = tgsepos ELSE wpos_gse = [wpos_gse, tgsepos]
  IF (j EQ 0) THEN wpos_gsm = tgsmpos ELSE wpos_gsm = [wpos_gsm, tgsmpos]
  IF (j EQ 0) THEN wpos_rad = tradpos ELSE wpos_rad = [wpos_rad, tradpos]
  IF (j EQ 0) THEN wpos_unx = tempun0 ELSE wpos_unx = [wpos_unx, tempun0]
  ;---------------------------------------------------------------------------------------
  ; => Release pointer and increment index markers
  ;---------------------------------------------------------------------------------------
  PTR_FREE,dataww
  IF (j LT gg - 1L) THEN qq = 1 ELSE qq = 0
  IF (qq) THEN j  += 1L
  IF (qq) THEN cc += nmag
ENDWHILE
; => Return messaging system variable to default setting
!QUIET   = 0
nmag     = N_ELEMENTS(magf_unx)
npos     = TOTAL(FINITE(wpos_unx))

; => Sort the data
sp       = SORT(magf_unx)
magf_unx = magf_unx[sp]
magf_gse = magf_gse[sp,*]
magf_gsm = magf_gsm[sp,*]

sp       = SORT(wpos_unx)
wpos_unx = wpos_unx[sp]
wpos_rad = wpos_rad[sp]
wpos_gse = wpos_gse[sp,*]
wpos_gsm = wpos_gsm[sp,*]
;-----------------------------------------------------------------------------------------
;  => Limit by time range
;-----------------------------------------------------------------------------------------
gmdata = WHERE(magf_unx LE tra[1] AND magf_unx GE tra[0],gdat)
IF (gdat GT 0L) THEN BEGIN
  magf_gse = magf_gse[gmdata,*]      ; => 3s GSE B-field data  (nT)
  magf_gsm = magf_gsm[gmdata,*]      ; => 3s GSM B-field data  (nT)
  magf_unx = magf_unx[gmdata]           ; => 3s Unix times
  nmag     = gdat
ENDIF ELSE BEGIN
  MESSAGE,"Error, no data in that time range!",/INFORMATIONAL,/CONTINUE
  magf_gse = dumbvec
  magf_gsm = dumbvec
  magf_unx = dumbarr
  nmag     = 0
ENDELSE

; => Position stuff
gpdata = WHERE(wpos_unx LE tra[1] AND wpos_unx GE tra[0],gdat)
IF (gdat GT 0L) THEN BEGIN
  wpos_gse = wpos_gse[gpdata,*]      ; => GSE position (Re)
  wpos_gsm = wpos_gsm[gpdata,*]      ; => GSM position (Re)
  wpos_rad = wpos_rad[gpdata]        ; => Radial Distance (Re)
  wpos_unx = wpos_unx[gpdata]        ; => Unix times associated with positions
ENDIF ELSE BEGIN
  wpos_gse = dumbvec
  wpos_gsm = dumbvec
  wpos_rad = dumbarr
  wpos_unx = dumbarr
ENDELSE
;-----------------------------------------------------------------------------------------
; => Eliminate data spikes/gaps
;-----------------------------------------------------------------------------------------
test_gse = fix_bfield_data(magf_unx,magf_gse,THRESH=3d4)
test_gsm = fix_bfield_data(magf_unx,magf_gsm,THRESH=3d4)

; => Calculate |B| (nT)
temp_gse = test_gse.Y
time_0   = test_gse.X
bmag_0   = SQRT(TOTAL(temp_gse^2,2,/NAN))
bad_0    = WHERE(bmag_0 LE 0.,bd0)
IF (bd0 GT 0) THEN bmag_0[bad_0] = d

; => Define seconds of day
magf_sod = time_0 MOD 864d2
;-----------------------------------------------------------------------------------------
; => Return data to user
;-----------------------------------------------------------------------------------------
bgse   = test_gse
bgsm   = test_gsm
bmags  = CREATE_STRUCT('X',time_0,'Y',bmag_0)
wgsep  = CREATE_STRUCT('X',wpos_unx,'Y',wpos_gse)
wgsmp  = CREATE_STRUCT('X',wpos_unx,'Y',wpos_gsm)
wradp  = CREATE_STRUCT('X',wpos_unx,'Y',wpos_rad)

tags   = ['TIMES','BGSE','BGSM','MAG','GSM_POS','GSE_POS','RADIAL_DIST']
gfield = CREATE_STRUCT(tags,magf_sod,bgse,bgsm,bmags,wgsmp,wgsep,wradp)

;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;*****************************************************************************************
RETURN, gfield
END

