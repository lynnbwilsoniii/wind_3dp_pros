;+
;*****************************************************************************************
;
;  FUNCTION :   readme_file_info.pro
;  PURPOSE  :   Returns most recent modification time for associated files.
;
;  CALLED BY:   
;               readme_update_ascii.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               FILE  :  String array for full path to files with file names
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Fixed a typo in determination of YEAR          [03/14/2011   v1.0.1]
;             2)  Now this is in its own file [used to be with readme_update_ascii.pro]
;                                                                [04/22/2011   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  03/11/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/22/2011   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION readme_file_info,file

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
monlists   = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec' ]
monlistn   = STRING(LINDGEN(12L)+1L,FORMAT='(I2.2)')
tdate      = ''  ; => e.g. '2008-07-09'
time       = ''  ; => e.g. '2008-07-09/16:14:25 UTC'

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
; => If desired, print out modification times:
ffile      = REFORM(file)
nf         = N_ELEMENTS(ffile)
finfo      = FILE_INFO(ffile,/NOEXPAND_PATH)  ; => assume wrapping pro checked file paths
; => Examples are for time of 2008-07-09/16:14:25 UTC
temp       = STRARR(nf)    ; => e.g. 'Wed Jul  9 16:14:25 2008'
spltt      = STRARR(nf,5)  ; => temp split up into sub strings
dayofweek  = STRARR(nf)    ; => e.g. 'Wed'
monofyear  = STRARR(nf)    ; => e.g. 'Jul'
numofweek  = STRARR(nf)    ; => e.g. '9'
scet       = STRARR(nf)    ; => e.g. '16:14:25'
year       = STRARR(nf)    ; => e.g. '2008'
FOR j=0L, nf - 1L DO BEGIN
  t0           = SYSTIME(0,finfo[j].MTIME,/UTC)
  temp[j]    = t0[0]
ENDFOR
; => the following is vectorized, thus faster than looping with STRSPLIT(t0,' ',/EXTRACT)
dayofweek  = STRLOWCASE(STRTRIM(STRMID(temp[*],0L,3L),2L))
monofyear  = STRLOWCASE(STRTRIM(STRMID(temp[*],4L,3L),2L))
numofweek  = STRING(LONG(STRMID(temp[*],7L,3L)),FORMAT='(I2.2)')
scet       = STRMID(temp[*],11L,8L)
year       = STRTRIM(STRMID(temp[*],19L),2L)
;-----------------------------------------------------------------------------------------
; => Determine month numbers from 3 letter strings
;-----------------------------------------------------------------------------------------
mon        = STRARR(nf)    ; => e.g. '07'
test_jan   = WHERE(monofyear EQ  monlists[0],g01)
test_feb   = WHERE(monofyear EQ  monlists[1],g02)
test_mar   = WHERE(monofyear EQ  monlists[2],g03)
test_apr   = WHERE(monofyear EQ  monlists[3],g04)
test_may   = WHERE(monofyear EQ  monlists[4],g05)
test_jun   = WHERE(monofyear EQ  monlists[5],g06)
test_jul   = WHERE(monofyear EQ  monlists[6],g07)
test_aug   = WHERE(monofyear EQ  monlists[7],g08)
test_sep   = WHERE(monofyear EQ  monlists[8],g09)
test_oct   = WHERE(monofyear EQ  monlists[9],g10)
test_nov   = WHERE(monofyear EQ monlists[10],g11)
test_dec   = WHERE(monofyear EQ monlists[11],g12)

IF (g01 GT 0) THEN mon[test_jan] = monlistn[0]
IF (g02 GT 0) THEN mon[test_feb] = monlistn[1]
IF (g03 GT 0) THEN mon[test_mar] = monlistn[2]
IF (g04 GT 0) THEN mon[test_apr] = monlistn[3]
IF (g05 GT 0) THEN mon[test_may] = monlistn[4]
IF (g06 GT 0) THEN mon[test_jun] = monlistn[5]
IF (g07 GT 0) THEN mon[test_jul] = monlistn[6]
IF (g08 GT 0) THEN mon[test_aug] = monlistn[7]
IF (g09 GT 0) THEN mon[test_sep] = monlistn[8]
IF (g10 GT 0) THEN mon[test_oct] = monlistn[9]
IF (g11 GT 0) THEN mon[test_nov] = monlistn[10]
IF (g12 GT 0) THEN mon[test_dec] = monlistn[11]
; => make sure no strings are null
bad = WHERE(mon EQ '',bd)
IF (bd GT 0) THEN mon[bad] = '00'
; => Reformat the day of week number
day   = STRING(LONG(STRTRIM(numofweek,2)),FORMAT='(I2.2)')

tdate = year+'-'+mon+'-'+day
time  = tdate+'/'+scet+' UTC'

; => Return file modification times
RETURN,time
END

