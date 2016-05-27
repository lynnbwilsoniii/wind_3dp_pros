;+
;*****************************************************************************************
;
;  FUNCTION :   master_file_list_create.pro
;  PURPOSE  :   Creates an ASCII file for the master file lists necessary to find
;                 all the files relevant to a particular date/time for the 3DP
;                 software.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               LZ3DP  :  If set, program writes master file for 3DP level zero data
;                           [Default]
;               HK3DP  :  " " 3DP House Keeping data
;               K03DP  :  " " 3DP Key Paramter data
;               K0SWE  :  " " SWE Key Paramter data
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  06/17/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/17/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO master_file_list_create,LZ3DP=lz3dp,HK3DP=hk3dp,K03DP=k03dp,K0SWE=k0swe

;-----------------------------------------------------------------------------------------
; => Define default parameters
;-----------------------------------------------------------------------------------------
defdr  = FILE_EXPAND_PATH('')
ny     = 20L
days   = LINDGEN(31L) + 1L
months = LINDGEN(12L) + 1L
years  = LINDGEN(ny) + 1994L
; => convert days, months, and years to strings
dstr   = STRING(FORMAT='(I2.2)',days)
mstr   = STRING(FORMAT='(I2.2)',months)
ystr   = STRING(FORMAT='(I4.4)',years)
tsuff  = '/00:00:00'

IF KEYWORD_SET(lz3dp) THEN lz3 = 1 ELSE lz3 = 0
IF KEYWORD_SET(hk3dp) THEN hk3 = 1 ELSE hk3 = 0
IF KEYWORD_SET(k03dp) THEN k03 = 1 ELSE k03 = 0
IF KEYWORD_SET(k0swe) THEN k0s = 1 ELSE k0s = 0

good   = WHERE([lz3,hk3,k03,k0s],gd)
IF (gd EQ 0) THEN good = 0   ; => Default is for level zero data

CASE good[0] OF
  0L   : BEGIN
    ; => LZ3DP is set 3dp level zero
    mform  = '(a138)'
    pref0  = 'wi_lz_3dp_'
    suff0  = '_v01.dat'
    fpref    = GETENV('WIND_DATA_DIR')
    IF (fpref[0] EQ '') THEN fpref  = '/data1/wind/3dp/lz/'
  END
  1L   : BEGIN
    ; => HK3DP is set 3dp level zero
    mform  = '(a140)'
    pref0  = 'wi_hkp_3dp_'
    suff0  = '_v01.dat'
    fpref    = GETENV('WI_HKP_3DP_FILES')
    IF (fpref[0] EQ '') THEN fpref  = '/data1/wind/3dp/hkp/'
  END
  2L   : BEGIN
    ; => K03DP is set 3dp level zero
    mform  = '(a138)'
    pref0  = 'wi_k0_3dp_'
    suff0  = '_v01.cdf'
    fpref    = GETENV('WI_K0_3DP_FILES')
    IF (fpref[0] EQ '') THEN fpref  = '/data1/wind/3dp/k0/'
  END
  3L   : BEGIN
    ; => K0SWE is set 3dp level zero
    ;  wi_k0_swe_20000508_v01.cdf
    mform  = '(a138)'
    pref0  = 'wi_k0_swe_'
    suff0  = '_v01.cdf'
    fpref    = GETENV('WI_K0_SWE_FILES')
    IF (fpref[0] EQ '') THEN fpref  = '/data1/wind/swe/k0/'
  END
  ELSE : BEGIN
    ; => [Default] 3dp level zero
    mform  = '(a138)'
    pref0  = 'wi_lz_3dp_'
    suff0  = '_v01.dat'
    fpref    = GETENV('WIND_DATA_DIR')
    IF (fpref[0] EQ '') THEN fpref  = '/data1/wind/3dp/lz/'
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Define time/date strings
;-----------------------------------------------------------------------------------------
d_string = STRARR(ny,12,32)  ; => e.g. '1994-01-01/00:00:00'
dfstring = STRARR(ny,12,32)  ; => e.g. '19940101'
FOR i=0L, ny - 1L DO BEGIN
  ; => Years
  FOR j=0L, 11L DO BEGIN
    ; => Months
    FOR k=0L, 30L DO BEGIN
      ; => Days
      d_string[i,j,k] = ystr[i]+'-'+mstr[j]+'-'+dstr[k]+tsuff
      dfstring[i,j,k] = ystr[i]+mstr[j]+dstr[k]
    ENDFOR
  ENDFOR
ENDFOR
;-----------------------------------------------------------------------------------------
; => Write file
;-----------------------------------------------------------------------------------------
fname  = pref0+'files'
gfile  = defdr[0]+'/'+fname[0]
; => Open
OPENW,gunit,gfile[0],/GET_LUN
; => Begin printing
FOR i=0L, ny - 1L DO BEGIN
  FOR j=0L, 11L DO BEGIN
    FOR k=0L, 30L DO BEGIN

      IF (k LE 29L) THEN BEGIN
        ; => day < or = 30
        d_str_0         = d_string[i,j,k]
        d_str_1         = d_string[i,j,k+1L]
      ENDIF ELSE BEGIN
        ; => figure out roll over for k = 31
        IF (j LE 10L) THEN BEGIN
          ; => Month < or = 11
          d_str_0         = d_string[i,j,k]
          d_str_1         = d_string[i,j+1L,0L]
        ENDIF ELSE BEGIN
          ; => rollover into January of next year
          t_year          = STRING(FORMAT='(I4.4)',FLOAT(ystr[i]) + 1.0)
          t_mon           = '01'
          t_day           = '01'
          d_str_0         = d_string[i,j,k]
          d_str_1         = t_year[0]+'-'+t_mon[0]+'-'+t_day[0]+tsuff
        ENDELSE
      ENDELSE
      df_str_0 = dfstring[i,j,k]
      p_string = d_str_0[0]+' '+d_str_1[0]+' '+fpref+ystr[i]+'/'+pref0+df_str_0[0]+suff0
      PRINTF,gunit,p_string
    ENDFOR
  ENDFOR
ENDFOR
; => close
FREE_LUN,gunit


RETURN
END