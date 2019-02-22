;+
;*****************************************************************************************
;
;  FUNCTION :   read_wind_htr_mfi.pro
;  PURPOSE  :   Reads in high time resolution (HTR) Magnetic Field Investigation (MFI)
;                 data from the Wind spacecraft.  The files are CDF files and the
;                 program returns a structure composed of the GSE magnetic field, its
;                 magnitude, and the Unix times associated with the data.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               time_range_define.pro
;               read_cdf.pro
;               epoch2unix.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               DATE    :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures [Unix time]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  11/23/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/23/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION read_wind_htr_mfi,DATE=date,TRANGE=trange

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
  mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/HTR_MFI_CDF/')
ENDIF ELSE BEGIN
  mdir = !wind3dp_umn.WIND_HTR_MFI_CDF_DIR
  IF (mdir[0] EQ '') THEN mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/HTR_MFI_CDF/')
ENDELSE
mfile    = ''                            ; => Only the file name (e.g. 'wi_h0_mfi_19950401_v04.cdf')
gdate    = ''                            ; => Date associated with each file
allfiles = FILE_SEARCH(mdir,'*.cdf')     ; => All files with entire path set
;  e.g.  wi_h2_mfi_20020810_v05.cdf
t_length = STRLEN('wi_h2_mfi_????????_v05.cdf') - 1L
mfile    = STRMID(STRCOMPRESS(allfiles[*],/REMOVE),t_length,/REVERSE)
gdate    = STRMID(mfile[*],10L,8L)       ; => Date associated w/ file ['YYYYMMDD']
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
  errmsg = 'No HTR CDF files for desired time range!'
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
  errmsg = 'No HTR CDF files for desired time range!'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define desired tag names in pointer array of CDF files
;-----------------------------------------------------------------------------------------
bnm_gse   = STRLOWCASE('BGSE')   ; => CDF tag for HTR GSE B-field data
bnm_gsm   = STRLOWCASE('BGSM')   ; => CDF tag for HTR GSM B-field data
bnm_epoch = STRLOWCASE('Epoch')   ; => " " HTR Epoch times
bnm_range = STRLOWCASE('RANGE')   ; => " " the mode the instrument is in
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
nvals     = 100000L
dumbvec   = REPLICATE(d,nvals,3L)
dumbarr   = REPLICATE(d,nvals)
dumblon   = REPLICATE(-1L,nvals)

tgsemag   = 0d0                           ; => Dummy Var. for HTR GSE B-field
tgsmmag   = 0d0                           ; => " " for HTR GSM B-field
tempepo   = 0d0                           ; => " " Epoch times associated with HTR B-fields
tempunx   = 0d0                           ; => " " Unix times associated with HTR B-fields
tempran   = 0L                            ; => " " range

qq        = 1
j         = 0L
cc        = 0L
WHILE(qq) DO BEGIN
  ; => Read CDF file
  windmm = read_cdf(tyfile[j],dataww,varww,/NOTIME)
  ;---------------------------------------------------------------------------------------
  ; => Check on B-field tags
  ;---------------------------------------------------------------------------------------
  var_lw = STRLOWCASE(REFORM(varww[*,0]))
  g_bgse = WHERE(var_lw EQ bnm_gse  ,ggse)   ; => Elements of Pointer for HTR GSE data
  g_bgsm = WHERE(var_lw EQ bnm_gsm  ,ggsm)   ; => Elements of Pointer for HTR GSM data
  g_epo3 = WHERE(var_lw EQ bnm_epoch,gep3)   ; => Element for Epoch times
  g_rang = WHERE(var_lw EQ bnm_range,gran)   ; => Element for instrument range/mode
  ; => Define dummy variables
  IF (ggse GT 0) THEN tgsemag = *dataww[g_bgse[0]]  ELSE tgsemag = dumbvec
  IF (ggsm GT 0) THEN tgsmmag = *dataww[g_bgsm[0]]  ELSE tgsmmag = dumbvec
  IF (gep3 GT 0) THEN tempepo = *dataww[g_epo3[0]]  ELSE tempepo = dumbarr
  IF (gran GT 0) THEN tempran = *dataww[g_rang[0]]  ELSE tempran = dumblon
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
  ; => Define HTR GSE B-field data
  ;---------------------------------------------------------------------------------------
  IF (j EQ 0) THEN magf_gse = tgsemag ELSE magf_gse = [magf_gse, tgsemag]
  IF (j EQ 0) THEN magf_gsm = tgsmmag ELSE magf_gsm = [magf_gsm, tgsmmag]
  IF (j EQ 0) THEN magf_unx = tempunx ELSE magf_unx = [magf_unx, tempunx]
  IF (j EQ 0) THEN magf_ran = tempran ELSE magf_ran = [magf_ran, tempran]
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
; => Sort the data
sp       = SORT(magf_unx)
magf_unx = magf_unx[sp]
magf_ran = magf_ran[sp]
magf_gse = magf_gse[sp,*]
magf_gsm = magf_gsm[sp,*]
;-----------------------------------------------------------------------------------------
;  => Limit by time range
;-----------------------------------------------------------------------------------------
gmdata = WHERE(magf_unx LE tra[1] AND magf_unx GE tra[0],gdat)
IF (gdat GT 0L) THEN BEGIN
  magf_gse = magf_gse[gmdata,*]         ; => HTR GSE B-field data  (nT)
  magf_gsm = magf_gsm[gmdata,*]         ; => HTR GSM B-field data  (nT)
  magf_unx = magf_unx[gmdata]           ; => HTR Unix times
  magf_ran = magf_ran[gmdata]           ; => HTR Ranges
  nmag     = gdat
ENDIF ELSE BEGIN
  MESSAGE,"Error, no data in that time range!",/INFORMATIONAL,/CONTINUE
  magf_gse = dumbvec
  magf_gsm = dumbvec
  magf_unx = dumbarr
  magf_ran = dumblon
  nmag     = 0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Calculate |B| (nT)
;-----------------------------------------------------------------------------------------
time_0   = magf_unx
bmag_0   = SQRT(TOTAL(magf_gse^2,2,/NAN))
bad_0    = WHERE(bmag_0 LE 0.,bd0)
IF (bd0 GT 0) THEN bmag_0[bad_0] = d
;-----------------------------------------------------------------------------------------
; => Return data to user
;-----------------------------------------------------------------------------------------
bgse   = CREATE_STRUCT('X',time_0,'Y',magf_gse)
bgsm   = CREATE_STRUCT('X',time_0,'Y',magf_gsm)
bmag   = CREATE_STRUCT('X',time_0,'Y',bmag_0)
bran   = CREATE_STRUCT('X',time_0,'Y',magf_ran)

tags   = ['UNIX','BGSE','BGSM','BMAG','RANGE']
gfield = CREATE_STRUCT(tags,time_0,bgse,bgsm,bmag,bran)
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;*****************************************************************************************
RETURN, gfield
END
