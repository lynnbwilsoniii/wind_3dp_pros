PRO wi_3dp_lz_print

;-----------------------------------------------------------------------------------------
; => Define parameters
;-----------------------------------------------------------------------------------------
ny     = 20L
days   = LINDGEN(31L) + 1L
months = LINDGEN(12L) + 1L
years  = LINDGEN(ny) + 1994L

dstr   = STRING(FORMAT='(I2.2)',days)
mstr   = STRING(FORMAT='(I2.2)',months)
ystr   = STRING(FORMAT='(I4.4)',years)
pref0  = 'wi_lz_3dp_'
suff0  = '_v01.dat'
tsuff  = '/00:00:00'
fpref  = '/data1/wind/3dp/lz/'
defdr  = FILE_EXPAND_PATH('')
fname  = pref0+'files'
mform  = '(a138)'

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

gfile = defdr[0]+'/'+fname[0]
OPENW,gunit,gfile[0],/GET_LUN
; => print strings to file
FOR i=0L, ny - 1L DO BEGIN
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
      p_string = d_str_0[0]+' '+d_str_1[0]+' '+fpref+ystr[i]+'/'+pref0+df_str_0[0]+suff0
      PRINTF,gunit,p_string
    ENDFOR
  ENDFOR
ENDFOR
FREE_LUN,gunit


RETURN
END