;+
;*****************************************************************************************
;
;  FUNCTION :   wind_3dp_units.pro
;  PURPOSE  :   Creates a structure containing all the relevant Wind/3DP particle
;                 data unit formats/names.  The program returns both all the of the
;                 names and an optional desired name.
;
;  CALLED BY:   
;               write_padspec_ascii.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               UNITS   :  Scalar string associated with a specific Wind/3DP unit name
;                            1)  'counts' = # of registered counts in the detector
;                            2)  'flux'   = number flux
;                            3)  'eflux'  = energy flux
;                            4)  'e2flux' = energy-squared flux
;                            5)  'e3flux' = energy-cubed flux
;                            6)  'df'     = distribution function (phase-space density)
;                            7)  'rate'   = effectively counts per integration time
;                            8)  'crate'  = count rate ? (similar to rate, see:
;                                             convert_esa_units.pro etc. )
;
;  EXAMPLES:    
;               unstr = wind_3dp_units()
;
;  KEYWORDS:    
;               SEARCH  :  If set, program assumes that the input UNITS is NOT
;                            simply a string matching a possible unit string, rather
;                            a concatenated mess of strings that has a possible
;                            unit string embedded within
;
;   CHANGED:  1)  Added the keyword:  SEARCH                   [10/08/2008   v1.1.0]
;
;   NOTES:      
;               ..................................................................
;               : {Let [ ] imply the units of whatever is contained in brackets} :
;               ..................................................................
;               1) [flux]   = # per area per time per solid angle per energy
;               1) [eflux]  = energy * [flux]
;               1) [e2flux] = (energy * energy) * [flux]
;               1) [e3flux] = (energy * energy * energy) * [flux]
;               1) [df]     = # per volume per momentum-cubed
;               1) [rate]   = # per integration time
;               1) [crate]  = # per scaled integration time
;
;   CREATED:  09/19/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/08/2008   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION wind_3dp_units,units,SEARCH=search

;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (N_PARAMS() EQ 0) THEN units = 'counts'
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
count_un  = ' (counts)'
flux_un   = ' (# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
eflux_un  = ' (eV cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
e2flux_un = ' (eV!U2!N cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
e3flux_un = ' (eV!U3!N cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
df_un     = ' (s!U3!N km!U-3!N cm!U-3!N)'
rate_un   = ' (s!U-1!N)'      ; => effectively 1/dat.DT
crate_un  = ' (# s!U-1!N)'    ; => effectively 1/(dat.DT*(1 - dat.DATA*dat.DEADTIME/dat.DT))
all_units = ['counts','flux','eflux','e2flux','e3flux','df','rate','crate']
all_unnms = [count_un,flux_un,eflux_un,e2flux_un,e3flux_un,df_un,rate_un,crate_un]
;-----------------------------------------------------------------------------------------
; => Check input units string
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(search) THEN BEGIN
  nall   = N_ELEMENTS(all_units)
  gchk   = LONARR(nall)
  alllen = STRLEN(all_units)
  unarr  = STRARR(nall)
  FOR j=0L, nall - 1L DO BEGIN
    glen  = alllen[j]
    gposi = STRPOS(units,all_units[j])
    IF (gposi[0] GE 0) THEN BEGIN
      gchk[j]  = 1
      unarr[j] = STRMID(units,gposi[0],glen)
    ENDIF ELSE BEGIN
      gchk[j]  = 0
      unarr[j] = 'null'
    ENDELSE
  ENDFOR
  ; => see if string contains anything...
  good = WHERE(gchk GT 0,gd)
  IF (gd GT 0) THEN BEGIN
    IF (gd GT 1) THEN BEGIN
      ; => More than one match (e.g. if eflux then flux will match too)
      ; => test for eflux, e2flux, or e3flux match
      eftest = (unarr EQ all_units[2]) OR (unarr EQ all_units[3]) OR $
               (unarr EQ all_units[4])
      ; => test for crate match
      crtest = (unarr EQ all_units[6])
      
      efchck = WHERE(eftest,gef)
      crchck = WHERE(crtest,gcr)
      gmulti = WHERE([gef,gcr] GT 0,gmt)
      CASE gmulti[0] OF
        0L   : BEGIN
          ; => eflux, e2flux, or e3flux
          guns = unarr[good[1]]
        END
        1L   : BEGIN
          ; => crate
          guns = unarr[good[1]]
        END
        ELSE : BEGIN
          guns = unarr[good[0]]
        END
      ENDCASE
    ENDIF ELSE BEGIN
      guns = unarr[good[0]]
    ENDELSE
  ENDIF ELSE BEGIN
    guns = ''   ; => use default
  ENDELSE
ENDIF ELSE BEGIN
  guns = STRLOWCASE(STRTRIM(units[0],2))
ENDELSE
;-----------------------------------------------------------------------------------------
; => Determine desired units
;-----------------------------------------------------------------------------------------
CASE guns OF
  'counts' : BEGIN
    gunits = all_unnms[0]
    unitnm = all_units[0]
  END
  'flux'   : BEGIN
    gunits = all_unnms[1]
    unitnm = all_units[1]
  END
  'eflux'  : BEGIN
    gunits = all_unnms[2]
    unitnm = all_units[2]
  END
  'e2flux' : BEGIN
    gunits = all_unnms[3]
    unitnm = all_units[3]
  END
  'e3flux' : BEGIN
    gunits = all_unnms[4]
    unitnm = all_units[4]
  END
  'df'     : BEGIN
    gunits = all_unnms[5]
    unitnm = all_units[5]
  END
  'rate'   : BEGIN
    gunits = all_unnms[6]
    unitnm = all_units[6]
  END
  'crate'  : BEGIN
    gunits = all_unnms[7]
    unitnm = all_units[7]
  END
  ELSE     : BEGIN
    gunits = all_unnms[1]
    unitnm = all_units[1]
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return data to user
;-----------------------------------------------------------------------------------------
tags = ['ALL_UNIT_PLOT_NAMES','ALL_UNIT_NAMES','G_UNIT_P_NAME','G_UNIT_NAME']
unst = CREATE_STRUCT(tags,all_unnms,all_units,gunits,unitnm)
RETURN,unst
END