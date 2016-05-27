PRO wi_mfi_print

;-----------------------------------------------------------------------------------------
; => Define parameters
;-----------------------------------------------------------------------------------------
days   = LINDGEN(31L) + 1L
months = LINDGEN(12L) + 1L
years  = LINDGEN(17L) + 1994L

dstr   = STRING(FORMAT='(I2.2)',days)
mstr   = STRING(FORMAT='(I2.2)',months)
ystr   = STRING(FORMAT='(I4.4)',years)
pref0  = 'wi_h0_mfi_'
suff0  = '_v04.cdf'
tsuff  = '/00:00:00'
fpref  = '/Users/lynnwilson/Desktop/swidl-0.1/wind_3dp_pros/wind_data_dir/MFI_CDF/'
defdr  = fpref[0]
fname  = pref0+'files'
mform  = '(a138)'

d_string = STRARR(17,12,32)
dfstring = STRARR(17,12,32)
FOR i=0L, 16L DO BEGIN
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

gfile = defdr[0]+'/'+fname[0]
OPENW,gunit,gfile[0],/GET_LUN
; => print strings to file
FOR i=0L, 16L DO BEGIN
  FOR j=0L, 11L DO BEGIN
    FOR k=0L, 30L DO BEGIN

      IF (k LE 29L) THEN BEGIN
        ; => day < or = 30
        d_str_0         = d_string[i,j,k]
        d_str_1         = d_string[i,j,k+1L]
;        d_string[i,j,k] = ystr[i]+'-'+mstr[j]+'-'+dstr[k]+tsuff
;        dfstring[i,j,k] = ystr[i]+mstr[j]+dstr[k]
      ENDIF ELSE BEGIN
        ; => figure out roll over for k = 31
        IF (j LE 10L) THEN BEGIN
          ; => Month < or = 11
          d_str_0         = d_string[i,j,k]
          d_str_1         = d_string[i,j+1L,0L]
;          d_string[i,j,k] = ystr[i]+'-'+mstr[j+1L]+'-'+dstr[k]+tsuff
        ENDIF ELSE BEGIN
          ; => rollover into January of next year
          t_year          = STRING(FORMAT='(I4.4)',FLOAT(ystr[i]) + 1.0)
          t_mon           = '01'
          t_day           = '01'
          d_str_0         = d_string[i,j,k]
          d_str_1         = t_year[0]+'-'+t_mon[0]+'-'+t_day[0]+tsuff
;          d_string[i,j,k] = t_year[0]+'-'+t_mon[0]+'-'+t_day[0]+tsuff
;          dfstring[i,j,k] = t_year[0]+t_mon[0]+t_day[0]
        ENDELSE
      ENDELSE
      df_str_0 = dfstring[i,j,k]
      p_string = d_str_0[0]+' '+d_str_1[0]+' '+fpref+pref0+df_str_0[0]+suff0
      PRINTF,gunit,p_string
    ENDFOR
  ENDFOR
ENDFOR
FREE_LUN,gunit


RETURN
END