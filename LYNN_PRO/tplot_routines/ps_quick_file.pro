;+
;*****************************************************************************************
;
;  PROCEDURE:   ps_quick_file.pro
;  PURPOSE  :   This routine is aimed to allow a user to quickly create a PS file from
;                  a current TPLOT plot with useful information in the file name
;                  including the time range and variables.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tnames.pro
;               tplot_com.pro
;               str_element.pro
;               set_tplot_times.pro
;               file_name_times.pro
;               popen.pro
;               pclose.pro
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               ;;   
;               ;; say you plotted THEMIS-A FGM data in 'fgh' mode in GSE coords
;               ;;   for time range 15:01:35.120 to 17:49:52.395 UT on 2010-01-01
;               ;;   
;               tplot,'tha_fgh_'+['mag','gse']
;               ;;   
;               ;; define structures
;               ;;   
;               sc   = 'THA'
;               tags = 'T'+STRTRIM(STRING(LINDGEN(5),FORMAT='(I2.2)'),2)
;               bmstr = CREATE_STRUCT(tags,'fgh','B','','mag','')
;               bfstr = CREATE_STRUCT(tags,'fgh','B','','gse','')
;               fstr  = [bmstr,bfstr]
;               ;;   
;               ;; save data
;               ;;   
;               ps_quick_file,FIELDS=fstr
;               ;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ;; Produces the following PS file with the file name:
;               ;;   THA_fgh-Bmag_fgh-Bgse_2010-01-01_1501x35.120-1749x52.395.ps
;               ;;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;
;  KEYWORDS:    
;               SPACECRAFT   :  Scalar [string] defining the spacecraft(s) associated
;                                 with the TPLOT data to save
;                                 [e.g., 'Wind' or 'THEMIS-A' or 'THA_THB' etc.]
;               _EXTRA       :  Keywords accepted by popen.pro
;               PREFIX       :  Scalar [string] defining the prefix for the file name to
;                                 use for the PS file [no need to add '_' to end]
;               SUFFIX       :  Scalar [string] defining the suffix for the file name to
;                                 use for the PS file [no need to add '_' to start]
;               TIME_LINES   :  Scalar [structure] defining times to mark with vertical
;                                 lines on the plot [see also:  time_bar.pro],
;                                 containing the following tags:
;                                   0th Tag  :  [T]-Element array of Unix Times
;                                   1st Tag  :  [T]-Element array of corresponding color
;                                                 indices for each line
;
;               ***  Specifiers  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               ***     the following keywords are structures     ***
;               ***  pay attention to the comments for formating  ***
;               !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;               DENSITY      :  [K]-Element structure, each containing the following
;                                 0th Tag  :  instrument or identifier
;                                               [e.g., 'IESA' or '3DP', etc.]
;                                 1st Tag  :  species [e.g., 'e' or 'i', etc.]
;                                 2nd Tag  :  type [e.g., 'core' or 'halo', etc.]
;                                 3rd Tag  :  set = ''
;                                 4th Tag  :  extra info [e.g., 'corrected', etc.]
;               TEMPERATURE  :  [J]-Element structure, each containing the following
;                                 0th Tag  :  instrument or identifier
;                                               [e.g., 'IESA' or '3DP', etc.]
;                                 1st Tag  :  species [e.g., 'e' or 'i', etc.]
;                                 2nd Tag  :  type 1 [e.g., 'core' or 'halo', etc.]
;                                 3rd Tag  :  type 2 [e.g., 'avg', or 'perp', etc.]
;                                 4th Tag  :  extra info [e.g., 'corrected', etc.]
;               VELOCITY     :  [L]-Element structure, each containing the following
;                                 0th Tag  :  instrument or identifier
;                                               [e.g., 'IESA' or '3DP', etc.]
;                                 1st Tag  :  species [e.g., 'e' or 'i', etc.]
;                                 2nd Tag  :  type 1 [e.g., 'thermal' or 'bulk', etc.]
;                                 3rd Tag  :  coord [e.g., 'gse', or 'core', etc.]
;                                 4th Tag  :  extra info [e.g., 'corrected', etc.]
;               PRESSURE     :  [M]-Element structure, each containing the following
;                                 0th Tag  :  instrument or identifier
;                                               [e.g., 'IESA' or '3DP', etc.]
;                                 1st Tag  :  species [e.g., 'e' or 'i', etc.]
;                                 2nd Tag  :  type 1 [e.g., 'thermal' or 'bulk', etc.]
;                                 3rd Tag  :  coord [e.g., 'gse', or 'core', etc.]
;                                 4th Tag  :  extra info [e.g., 'corrected', etc.]
;               FIELDS       :  [N]-Element structure, each containing the following
;                                 0th Tag  :  instrument or identifier
;                                               [e.g., 'fgl' or 'FGM' or 'MFI', etc.]
;                                 1st Tag  :  field [e.g., 'B' or 'E' or 'S', etc.]
;                                 2nd Tag  :  type [e.g., 'AC' or 'DC', etc.]
;                                 3rd Tag  :  coord [e.g., 'gse', or 'mag', etc.]
;                                 4th Tag  :  extra info
;                                               [e.g., 'calibrated' or 'filtered', etc.]
;               SPECTRA      :  [H]-Element structure, each containing the following
;                                 0th Tag  :  instrument or identifier
;                                               [e.g., 'efw' or 'scp' or 'TDS', etc.]
;                                 1st Tag  :  field [e.g., 'B' or 'E' or 'S', etc.]
;                                 2nd Tag  :  type [e.g., 'wavelet' or 'FFT', etc.]
;                                 3rd Tag  :  coord [e.g., 'gse', or 'mag', etc.]
;                                 4th Tag  :  extra info
;                                               [e.g., 'calibrated' or 'filtered', etc.]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  All keyword strings should contain no spaces or characters not
;                     recognized by DEVICE.PRO for a PostScript file name
;               2)  For each keyword, every element does not need to be defined, but
;                     each structure MUST contain exactly 5 elements
;               3)  Be careful not to include too many variables so the file name does
;                     exceed your OS's limitations
;               4)  Pay attention to the strings you use on input so they do not
;                     violate the rules for file names in your OS
;               5)  If PREFIX and any other specified keyword [e.g., DENSITY] are used
;                     together, then the specifier string will be attached to the end
;                     of the PREFIX string
;               6)  No need to add '_' to end(start) of the input PREFIX(SUFFIX) keyword
;
;   CREATED:  12/12/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/12/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO ps_quick_file,SPACECRAFT=spacecraft,DENSITY=density,TEMPERATURE=temperature,    $
                  VELOCITY=velocity,PRESSURE=pressure,FIELDS=fields,SPECTRA=spectra,$
                  _EXTRA=ex_key,PREFIX=prefix,SUFFIX=suffix,TIME_LINES=time_lines

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
no_tplot       = 'You must first load some data into TPLOT!'
no_plot        = 'You must first plot something in TPLOT!'
def_pref       = 'TPLOT_plot_'
;;----------------------------------------------------------------------------------------
;; => Make sure TPLOT variables exist
;;----------------------------------------------------------------------------------------
tpn_all        = tnames()
IF (tpn_all[0] EQ '') THEN BEGIN
  MESSAGE,no_tplot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;;----------------------------------------------------------------------------------------
;; => Load common block
;;----------------------------------------------------------------------------------------
@tplot_com.pro
;; => Determine current settings
str_element,tplot_vars,'OPTIONS.TRANGE',trange
str_element,tplot_vars,'OPTIONS.TRANGE_FULL',trange_full
str_element,tplot_vars,'SETTINGS.TRANGE_OLD',trange_old
str_element,tplot_vars,'SETTINGS.TIME_SCALE',time_scale
str_element,tplot_vars,'SETTINGS.TIME_OFFSET',time_offset
;;  Check time ranges
test_tr0       = (trange[0] EQ trange[1])
test_trf       = (trange_full[0] EQ trange_full[1])
test_tro       = (trange_old[0] EQ trange_old[1])
IF (test_tr0) THEN BEGIN
  ;; set TPLOT times
  set_tplot_times
ENDIF
;;----------------------------------------------------------------------------------------
;;  Make sure something is plotted
;;----------------------------------------------------------------------------------------
tpv_set_tags   = TAG_NAMES(tplot_vars.SETTINGS)
idx            = WHERE(tpv_set_tags EQ 'X',icnt)
IF (icnt GT 0) THEN BEGIN
  ; => define time range
  tr = tplot_vars.SETTINGS.X.CRANGE*time_scale[0] + time_offset[0]
ENDIF ELSE BEGIN
  MESSAGE,no_plot[0],/INFORMATIONAL,/CONTINUE
  RETURN
ENDELSE
;;  Check time ranges
test_tr0       = (tr[0] EQ tr[1])
test_trc       = ((trange[0] EQ tr[0]) AND (trange[1] EQ tr[1]))
test_trf       = (trange_full[0] EQ trange_full[1])
test_tro       = (trange_old[0] EQ trange_old[1])
IF (test_tr0 AND test_trc) THEN BEGIN
  ;; use default TPLOT time range
  tr = trange
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define time range part of file name
;;----------------------------------------------------------------------------------------
fnm            = file_name_times(tr,PREC=3)
ftimes         = fnm.F_TIME[0]+'-'+STRMID(fnm.F_TIME[1],11L)  ; e.g. 1998-08-09_0801x09.494
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
test_sc        = (N_ELEMENTS(spacecraft) EQ 1)
test_pr        = (N_ELEMENTS(prefix) EQ 1)
test_sf        = (N_ELEMENTS(suffix) EQ 1)
test_nn        = (N_ELEMENTS(density) NE 0)
test_tt        = (N_ELEMENTS(temperature) NE 0)
test_vv        = (N_ELEMENTS(velocity) NE 0)
test_pp        = (N_ELEMENTS(pressure) NE 0)
test_ff        = (N_ELEMENTS(fields) NE 0)
test_ss        = (N_ELEMENTS(spectra) NE 0)
;;----------------------------------------------------------------------------------------
;;  Define file name prefix
;;----------------------------------------------------------------------------------------
sc_pref        = ''
f_pref         = ''
IF (test_sc) THEN BEGIN
  test0          = (spacecraft[0] NE '')
ENDIF ELSE test0 = 0
IF (test0) THEN sc_pref = spacecraft[0]+'_' ELSE sc_pref = ''

IF (test0 AND test_pr) THEN BEGIN
  IF (prefix[0] NE '') THEN BEGIN
    f_pref = sc_pref[0]+prefix[0]+'_'
  ENDIF ELSE BEGIN
    f_pref = sc_pref[0]
  ENDELSE
ENDIF ELSE BEGIN
  IF (test_pr) THEN test1 = (prefix[0] NE '') ELSE test1 = 0
  IF (test0) THEN f_pref = sc_pref[0]
  IF (test1) THEN f_pref = prefix[0]+'_'
ENDELSE

;;  Check for file name suffix
IF (test_sf) THEN BEGIN
  IF (suffix[0] NE '') THEN BEGIN
    f_suff = '_'+suffix[0]
  ENDIF ELSE BEGIN
    f_suff = ''
  ENDELSE
ENDIF ELSE BEGIN
  f_suff = ''
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Check for particle plots
;;----------------------------------------------------------------------------------------
;;
;;  Density
;;
mid_fname      = ''
IF (test_nn) THEN BEGIN
  str_s   = density
  IF (SIZE(str_s,/TYPE) EQ 8) THEN BEGIN
    IF (N_TAGS(str_s) EQ 5) THEN BEGIN
      ;;  Add Density info to file name
      nd      = N_ELEMENTS(str_s)
      FOR j=0L, nd - 1L DO BEGIN
        IF (str_s[j].(0) NE '') THEN zero  = str_s[j].(0)+'-N' ELSE zero  = 'N'
        IF (str_s[j].(1) NE '') THEN first = str_s[j].(1)      ELSE first = ''
        IF (str_s[j].(2) NE '') THEN secon = str_s[j].(2)      ELSE secon = ''
        IF (str_s[j].(3) NE '') THEN third = str_s[j].(3)      ELSE third = ''
        IF (str_s[j].(4) NE '') THEN forth = str_s[j].(4)      ELSE forth = ''
        ;; Create dummy middle
        t_midf    = zero[0]
        IF (first[0] NE '') THEN t_midf = t_midf[0]+'-'+first[0]
        IF (secon[0] NE '') THEN t_midf = t_midf[0]+'-'+secon[0]
        IF (third[0] NE '') THEN t_midf = t_midf[0]+'-'+third[0]
        IF (forth[0] NE '') THEN t_midf = t_midf[0]+'-'+forth[0]
        ;; Add to middle part of file name
        mid_fname = mid_fname[0]+t_midf[0]+'_'
      ENDFOR
    ENDIF
  ENDIF
ENDIF
;;
;;  Temperature
;;
IF (test_tt) THEN BEGIN
  str_s   = temperature
  IF (SIZE(str_s,/TYPE) EQ 8) THEN BEGIN
    IF (N_TAGS(str_s) EQ 5) THEN BEGIN
      ;;  Add Pressure info to file name
      nd      = N_ELEMENTS(str_s)
      FOR j=0L, nd - 1L DO BEGIN
        IF (str_s[j].(0) NE '') THEN zero  = str_s[j].(0)+'-T' ELSE zero  = 'T'
        IF (str_s[j].(1) NE '') THEN first = str_s[j].(1)      ELSE first = ''
        IF (str_s[j].(2) NE '') THEN secon = str_s[j].(2)      ELSE secon = ''
        IF (str_s[j].(3) NE '') THEN third = str_s[j].(3)      ELSE third = ''
        IF (str_s[j].(4) NE '') THEN forth = str_s[j].(4)      ELSE forth = ''
        ;; Create dummy middle
        t_midf    = zero[0]
        IF (first[0] NE '') THEN t_midf = t_midf[0]+'-'+first[0]
        IF (secon[0] NE '') THEN t_midf = t_midf[0]+'-'+secon[0]
        IF (third[0] NE '') THEN t_midf = t_midf[0]+'-'+third[0]
        IF (forth[0] NE '') THEN t_midf = t_midf[0]+'-'+forth[0]
        ;; Add to middle part of file name
        mid_fname = mid_fname[0]+t_midf[0]+'_'
      ENDFOR
    ENDIF
  ENDIF
ENDIF
;;
;;  Velocity
;;
IF (test_vv) THEN BEGIN
  str_s   = velocity
  IF (SIZE(str_s,/TYPE) EQ 8) THEN BEGIN
    IF (N_TAGS(str_s) EQ 5) THEN BEGIN
      ;;  Add Pressure info to file name
      nd      = N_ELEMENTS(str_s)
      FOR j=0L, nd - 1L DO BEGIN
        IF (str_s[j].(0) NE '') THEN zero  = str_s[j].(0)+'-V' ELSE zero  = 'V'
        IF (str_s[j].(1) NE '') THEN first = str_s[j].(1)      ELSE first = ''
        IF (str_s[j].(2) NE '') THEN secon = str_s[j].(2)      ELSE secon = ''
        IF (str_s[j].(3) NE '') THEN third = str_s[j].(3)      ELSE third = ''
        IF (str_s[j].(4) NE '') THEN forth = str_s[j].(4)      ELSE forth = ''
        ;; Create dummy middle
        t_midf    = zero[0]
        IF (first[0] NE '') THEN t_midf = t_midf[0]+'-'+first[0]
        IF (secon[0] NE '') THEN t_midf = t_midf[0]+'-'+secon[0]
        IF (third[0] NE '') THEN t_midf = t_midf[0]+'-'+third[0]
        IF (forth[0] NE '') THEN t_midf = t_midf[0]+'-'+forth[0]
        ;; Add to middle part of file name
        mid_fname = mid_fname[0]+t_midf[0]+'_'
      ENDFOR
    ENDIF
  ENDIF
ENDIF
;;
;;  Pressure
;;
IF (test_pp) THEN BEGIN
  str_s   = density
  IF (SIZE(str_s,/TYPE) EQ 8) THEN BEGIN
    IF (N_TAGS(str_s) EQ 5) THEN BEGIN
      ;;  Add Pressure info to file name
      nd      = N_ELEMENTS(str_s)
      FOR j=0L, nd - 1L DO BEGIN
        t_midf    = ''
        IF (str_s[j].(0) NE '') THEN zero  = str_s[j].(0)+'-P' ELSE zero  = 'P'
        IF (str_s[j].(1) NE '') THEN first = str_s[j].(1)      ELSE first = ''
        IF (str_s[j].(2) NE '') THEN secon = str_s[j].(2)      ELSE secon = ''
        IF (str_s[j].(3) NE '') THEN third = str_s[j].(3)      ELSE third = ''
        IF (str_s[j].(4) NE '') THEN forth = str_s[j].(4)      ELSE forth = ''
        ;; Create dummy middle
        t_midf    = zero[0]
        IF (first[0] NE '') THEN t_midf = t_midf[0]+'-'+first[0]
        IF (secon[0] NE '') THEN t_midf = t_midf[0]+'-'+secon[0]
        IF (third[0] NE '') THEN t_midf = t_midf[0]+'-'+third[0]
        IF (forth[0] NE '') THEN t_midf = t_midf[0]+'-'+forth[0]
        ;; Add to middle part of file name
        mid_fname = mid_fname[0]+t_midf[0]+'_'
      ENDFOR
    ENDIF
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check for field plots
;;----------------------------------------------------------------------------------------
;;
;;  Fields
;;
IF (test_ff) THEN BEGIN
  str_s   = fields
  IF (SIZE(str_s,/TYPE) EQ 8) THEN BEGIN
    IF (N_TAGS(str_s) EQ 5) THEN BEGIN
      ;;  Add Pressure info to file name
      nd      = N_ELEMENTS(str_s)
      FOR j=0L, nd - 1L DO BEGIN
        t_midf    = ''
        IF (str_s[j].(0) NE '') THEN zero  = str_s[j].(0)      ELSE zero  = 'F'
        IF (str_s[j].(1) NE '') THEN first = str_s[j].(1)      ELSE first = ''
        IF (str_s[j].(2) NE '') THEN secon = str_s[j].(2)      ELSE secon = ''
        IF (str_s[j].(3) NE '') THEN third = str_s[j].(3)      ELSE third = ''
        IF (str_s[j].(4) NE '') THEN forth = str_s[j].(4)      ELSE forth = ''
        ;; Create dummy middle
        t_midf    = zero[0]
        IF (first[0] NE '') THEN t_midf = t_midf[0]+'-'+first[0]
        IF (third[0] NE '') THEN t_midf = t_midf[0]+third[0]
        IF (secon[0] NE '') THEN t_midf = t_midf[0]+'-'+secon[0]
        IF (forth[0] NE '') THEN t_midf = t_midf[0]+'-'+forth[0]
;        t_midf    = zero[0]+'-'+first[0]+third[0]+'-'+secon[0]+'-'+forth[0]
        ;; Add to middle part of file name
        mid_fname = mid_fname[0]+t_midf[0]+'_'
      ENDFOR
    ENDIF
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Check for spectra plots
;;----------------------------------------------------------------------------------------
;;
;;  Spectra
;;
IF (test_ss) THEN BEGIN
  str_s   = spectra
  IF (SIZE(str_s,/TYPE) EQ 8) THEN BEGIN
    IF (N_TAGS(str_s) EQ 5) THEN BEGIN
      ;;  Add Pressure info to file name
      nd      = N_ELEMENTS(str_s)
      FOR j=0L, nd - 1L DO BEGIN
        t_midf    = ''
        IF (str_s[j].(0) NE '') THEN zero  = str_s[j].(0)      ELSE zero  = 'F'
        IF (str_s[j].(1) NE '') THEN first = str_s[j].(1)      ELSE first = ''
        IF (str_s[j].(2) NE '') THEN secon = str_s[j].(2)      ELSE secon = ''
        IF (str_s[j].(3) NE '') THEN third = str_s[j].(3)      ELSE third = ''
        IF (str_s[j].(4) NE '') THEN forth = str_s[j].(4)      ELSE forth = ''
        ;; Create dummy middle
        t_midf    = zero[0]
        IF (first[0] NE '') THEN t_midf = t_midf[0]+'-'+first[0]
        IF (third[0] NE '') THEN t_midf = t_midf[0]+third[0]
        IF (secon[0] NE '') THEN t_midf = t_midf[0]+'-'+secon[0]
        IF (forth[0] NE '') THEN t_midf = t_midf[0]+'-'+forth[0]
        ;; Add to middle part of file name
        mid_fname = mid_fname[0]+t_midf[0]+'_'
      ENDFOR
    ENDIF
  ENDIF
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define file name
;;----------------------------------------------------------------------------------------
;;  e.g., 'THA_fgh-Bmag_fgh-Bgse_2010-01-01_1501x35.120-1749x52.395'
fname = f_pref[0]+mid_fname[0]+ftimes[0]+f_suff[0]
;;
;;  Plot and save
;;
popen,fname[0],_EXTRA=ex_key
  tplot,TRANGE=tr
  IF (SIZE(time_lines,/TYPE) EQ 8) THEN BEGIN
    IF (N_TAGS(time_lines) EQ 2) THEN BEGIN
      test0 = (N_ELEMENTS(time_lines.(0)) EQ N_ELEMENTS(time_lines.(1)))
      test1 = (SIZE(time_lines.(0),/TYPE) EQ 5)
      IF (test0 AND test1) THEN BEGIN
        time_bar,time_lines.(0),COLOR=time_lines.(1)
      ENDIF
    ENDIF
  ENDIF
pclose
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN
END













