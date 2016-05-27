;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_high_bad_bins.pro
;  PURPOSE  :   This program kills off all the data bins which have a "glitch" in the
;                 energy bin values AND the data.  This prevents the Pesa High
;                 structures from producing false or irrelevant data at these points.
;                 Note, however, that the Pesa High instrument is plagued with UV
;                 and solar wind contamination so it should be dealt with carefully.
;
;  CALLED BY:   
;               add_df2d_to_ph.pro
;               pesa_high_str_fill.pro
;               dat_3dp_energy_bins.pro
;               plot3d.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT     :  3DP data structure(s) either from get_ph.pro or get_phb.pro
;
;  EXAMPLES:    
;               to  = time_double('1995-04-03/05:40:00')
;               ph  = get_ph(to)
;               pesa_high_bad_bins,ph
;
;  KEYWORDS:    
;               MSSG    :  If set, program outputs the run time of the program
;                            [for optimization tests]
;
;   CHANGED:  1)  Removed program:  my_3dp_energy_bins.pro        [04/26/2009   v1.0.1]
;             2)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed                                   [08/10/2009   v2.0.0]
;             3)  Updated 'man' page                              [10/05/2008   v2.0.1]
;             4)  Updated 'man' page                              [02/13/2010   v2.0.2]
;             5)  Added error handling for moments produced by the Mac OS X shared
;                   object library which produces anomalous data spikes
;                                                                 [02/18/2011   v2.1.0]
;             6)  Fixed an issue with new error handling for arrays of PH structures
;                                                                 [02/22/2011   v2.1.1]
;             7)  Attempted to optimize for large arrays and added keyword MSSG
;                                                                 [12/15/2011   v2.1.2]
;
;   NOTES:      
;               1)  dat.UNITS_NAME = 'Counts' when this routine is called
;               2)  Though I refer to these bad data bins as a "glitch" it is actually
;                     due to a double-sweep mode and UV light contamination.  It can
;                     be easily identified if you plot the sun direction on contour
;                     plots of the phase space density for multiple consecutive 
;                     distributions.  As you scroll through the plots, you will see
;                     a beam-like feature that follows the sun direction.  Even after
;                     removing these "bad" bins, this feature may still exist in your
;                     plots, so be careful.
;               3)  The Mac OS X shared object library issue only seems to affect the
;                     Pesa High distributions.  Anomalous data points with counts
;                     in the tens to hundreds of millions can be found when you use
;                     get_3dp_structs.pro, get_ph.pro, or get_phb.pro on a Mac 
;                     machine with intell processor.  I am assuming there is a formatting
;                     issue in the compiler that causes a NaN to be translated as
;                     some large number (typical vales are roughly 1.91e+07 or greater).
;
;   CREATED:  04/26/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/15/2011   v2.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO pesa_high_bad_bins,dat,MSSG=mssg

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; -Make sure input was a Pesa High(Burst) structure
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d1       = dat
nstrs    = N_ELEMENTS(d1)
nenergy  = d1[0].NENERGY
nbins    = d1[0].NBINS
strns    = dat_3dp_str_names(d1[0].DATA_NAME)
name     = strns.SN
data_str = name
ncheck   = [name NE 'ph',name NE 'phb']
gnchk    = WHERE(ncheck GT 0,gnc)
IF (gnc EQ 0) THEN BEGIN
  MESSAGE,'Incorrect Structure Format:  Must be a Pesa High Str.',/INFORMATION,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine number of data bins and which bins are "bad"
;-----------------------------------------------------------------------------------------
CASE nbins OF
  121  :  BEGIN
    mapcode  = 54436L
    ndat     = 121L
    bad_bins = [0L,1L,8L,9L,16L,17L,24L,25L,35L,36L,43L,44L,51L,52L,59L,60L,$
                61L,68L,69L,76L,77L,84L,85L,95L,96L,103L,104L,111L,112L,119L,120L]
  END
  97   :  BEGIN
    mapcode  = 54526L
    ndat     = 97L
    bad_bins = [0L,1L,5L,6L,10L,11L,15L,16L,23L,24L,28L,29L,33L,34L,38L,39L,$
                57L,58L,62L,63L,67L,68L,72L,73L,80L,81L,85L,86L,90L,91L,95L,96L]
  END
  56   :  BEGIN
    mapcode  = 54764L
    ndat     = 56L
    bad_bins = [0L,1L,2L,8L,9L,10L,19L,20L,21L,27L,28L,29L,34L,35L,36L,45L,$
                46L,47L,53L,54L,55L]
  END
  65   :  BEGIN
    mapcode  = 54971L
    ndat     = 65L
    bad_bins = -1
  END
  88   :  BEGIN
    mapcode  = 54877L
    ndat     = 88L
    bad_bins = -1
  END
  ELSE : BEGIN
    MESSAGE,'Unknown Structure Format!',/INFORMATION,/CONTINUE
    RETURN
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Kill data from "bad" data bins
;-----------------------------------------------------------------------------------------
IF (bad_bins[0] NE -1) THEN BEGIN
  IF (nstrs EQ 1) THEN BEGIN
    d1.ENERGY[*,bad_bins]   = f                ; -Kill energies to avoid bad estimates
    d1.DATA[*,bad_bins]     = f                ; => Don't trust data from these bins
  ENDIF ELSE BEGIN
    d1.ENERGY[*,bad_bins,*] = f
    d1.DATA[*,bad_bins,*]   = f
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; => Now check to see if there are bad bins due to Mac OS X shared object library
;-----------------------------------------------------------------------------------------
bad = WHERE(d1.DATA GE 1d7,bd)
IF (bd GT 0 AND STRLOWCASE(d1[0].UNITS_NAME) EQ 'counts') THEN BEGIN
  IF (nstrs GT 1) THEN BEGIN
    ; => Appears to always be faster to loop than vectorize this operation
    FOR j=0L, nstrs - 1L DO BEGIN
      bad = WHERE(d1[j].DATA GE 1d7,bd)
      IF (bd GT 0) THEN BEGIN
        bind = ARRAY_INDICES(d1[j].DATA,bad)
        d1[j].ENERGY[bind[0,*],bind[1,*]]   = f
        d1[j].DATA[bind[0,*],bind[1,*]]     = f
      ENDIF
    ENDFOR
  ENDIF ELSE BEGIN
    bind = ARRAY_INDICES(d1.DATA,bad)
    d1.ENERGY[bind[0,*],bind[1,*]]   = f
    d1.DATA[bind[0,*],bind[1,*]]     = f
  ENDELSE
ENDIF

dat = d1
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
IF KEYWORD_SET(mssg) THEN BEGIN
  MESSAGE,STRING(ex_time)+' seconds execution time.',/CONTINUE,/INFORMATIONAL
ENDIF
;*****************************************************************************************

RETURN
END