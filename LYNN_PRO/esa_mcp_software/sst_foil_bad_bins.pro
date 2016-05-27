;+
;*****************************************************************************************
;
;  FUNCTION :   sst_foil_bad_bins.pro
;  PURPOSE  :   This program kills off all the data bins which are generally "bad" for
;                 the SST Foil detector on the Wind/3DP particle detector suite.
;
;  CALLED BY:   
;               plot3d.pro
;               get_padspecs.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure(s) either from get_sf.pro or get_sfb.pro
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               KILL_SMGF  :  If set, not only are the "bad" bins removed from the
;                               SST Foil data structures, the bins with small
;                               geometry factors are removed too (see note below)
;
;   CHANGED:  1)  Added keyword:  KILL_SMGF                        [02/25/2010   v1.1.0]
;             2)  Added a little note about the data bins with small geometry factors
;                                                                  [07/25/2011   v1.1.1]
;
;   NOTES:      
;               1)  Linghua Wang at Berkeley SSL explained that generally the following
;                     bins were "bad:"  [7,8,9,15,31,32,33]
;                     and the following have very small geometry factors making them
;                     generally excluded from data processing:
;                     [20,21,22,23,44,45,46,47]
;               2)  One rarely wants to remove the data bins with small geometry factors
;                     since they are double-counted 
;                     [Personal Communication, D. Larson, July 18, 2011]
;
;   CREATED:  02/13/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/25/2011   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO sst_foil_bad_bins,dat,KILL_SMGF=kill

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f         = !VALUES.F_NAN
d         = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; -Make sure input was a SST Foil structure
;-----------------------------------------------------------------------------------------
d1       = dat
nstrs    = N_ELEMENTS(d1)
nenergy  = d1[0].NENERGY
nbins    = d1[0].NBINS
strns    = dat_3dp_str_names(d1[0].DATA_NAME)
name     = strns.SN
data_str = name
ncheck   = [name NE 'sf',name NE 'sfb']
gnchk    = WHERE(ncheck GT 0,gnc)
IF (gnc EQ 0) THEN BEGIN
  MESSAGE,'Incorrect Structure Format:  Must be a SST Foil Str.',/INFORMATION,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine number of data bins and which bins are "bad"
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(kill) THEN BEGIN
  ; => Eliminate even the small geometry factor bins
  bad_bins = [7L,8L,9L,15L,20L,21L,22L,23L,31L,32L,33L,44L,45L,46L,47L]
ENDIF ELSE BEGIN
  ; => Only eliminate the "bad" bins
  bad_bins = [7L,8L,9L,15L,31L,32L,33L]
ENDELSE
;-----------------------------------------------------------------------------------------
; -Kill data from bad data bins
;-----------------------------------------------------------------------------------------
IF (nstrs EQ 1) THEN BEGIN
  ; => Only 1 structure input
  d1.ENERGY[*,bad_bins]   = f                ; -Kill energies to avoid bad estimates
  d1.DATA[*,bad_bins]     = f                ; => Don't trust data from these bins
ENDIF ELSE BEGIN
  ; => Many structures input
  d1.ENERGY[*,bad_bins,*] = f
  d1.DATA[*,bad_bins,*]   = f
ENDELSE


dat = d1
RETURN
END