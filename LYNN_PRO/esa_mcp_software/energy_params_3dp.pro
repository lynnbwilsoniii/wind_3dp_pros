;+
;*****************************************************************************************
;
;  FUNCTION :   energy_params_3dp.pro
;  PURPOSE  :   Returns default #'s of pitch-angles, # of energy bins (-1), and energy
;                 values relative to the type of structure being called for each
;                 instrument.
;
;  CALLED BY:   NA
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:  
;               NAME  :  [string,structure] associated with a known 3DP data structure
;                          {i.e. el = get_el() => dat = el, or dat = 'Eesa Low'}
;
;  EXAMPLES:    
;               name = 'pl'
;               myen = energy_params_3dp(name)
;
;               or
;
;               name = get_pl(t)
;               myen = energy_params_3dp(name)
;
;  KEYWORDS:    NA
;
;   CHANGED:  1)  Updated man page                        [11/11/2008   v1.0.2]
;             2)  Changed mynpa for EH and EHB            [02/09/2009   v1.0.3]
;             3)  Rewrote and renamed with more comments  [07/20/2009   v2.0.0]
;             4)  Updated man page                        [08/10/2009   v2.0.1]
;
;   CREATED:  04/10/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION energy_params_3dp,name

;-----------------------------------------------------------------------------------------
; => Make sure input is correct
;-----------------------------------------------------------------------------------------
strn = dat_3dp_str_names(name)
snam = strn.SN
;-----------------------------------------------------------------------------------------
; => Define default values
;-----------------------------------------------------------------------------------------
CASE snam[0] OF
  'el' : BEGIN
    mynpa = 16L
    mener = 14L   ; # of energy bins - 1
    myen  = [1112.99,689.161,426.769,264.837,164.957,103.320,65.2431,41.7663,27.2489,$
             18.2895,12.8144,9.41314,7.25626,5.92896,5.18234]
  END
  'elb' : BEGIN
    mynpa = 16L
    mener = 14L
    myen  = [1112.99,689.161,426.769,264.837,164.957,103.320,65.2431,41.7663,27.2489,$
             18.2895,12.8144,9.41314,7.25626,5.92896,5.18234]
  END
  'eh' : BEGIN
    mynpa = 16L
    mener = 14L
    myen  = [27662.7,18944.4,12965.8,8874.88,6076.48,4161.27,2849.21,1952.32,1339.37,$
             920.296,634.385,432.729,292.064,200.056,136.845]
  END
  'ehb' : BEGIN
    mynpa = 16L
    mener = 14L
    myen  = [27662.7,18944.4,12965.8,8874.88,6076.48,4161.27,2849.21,1952.32,1339.37,$
             920.296,634.385,432.729,292.064,200.056,136.845]
  END
  'pl' : BEGIN
    mynpa = 4L
    mener = 13L
    myen  = [5060.50,4322.26,3690.04,3150.10,2688.70,2294.05,1958.3,1671.65,1428.19,$
             1218.10,1037.47,886.284,756.699,644.785]
  END
  'plb' : BEGIN
    mynpa = 4L
    mener = 13L
    myen  = [5060.50,4322.26,3690.04,3150.10,2688.70,2294.05,1958.3,1671.65,1428.19,$
             1218.10,1037.47,886.284,756.699,644.785]
  END
  'ph' : BEGIN
    mynpa = 8L
    mener = 14L
    myen  = [28433.7,21151.4,15730.1,11699.1,8701.90,6474.69,4820.5,3589.76,2674.06,$
             1994.67,1490.55,1114.42,834.792,628.022,474.421]
  END
  'phb' : BEGIN
    mynpa = 8L
    mener = 14L
    myen  = [28433.7,21151.4,15730.1,11699.1,8701.90,6474.69,4820.5,3589.76,2674.06,$
             1994.67,1490.55,1114.42,834.792,628.022,474.421]
  END
  'sf' : BEGIN
    mynpa = 8L
    mener = 6L
    myen  = [26.1615,41.5949,68.3086,111.690,185.962,316.103,529.135] ; low -> high (keV)
  END
  'sfb' : BEGIN
    mynpa = 8L
    mener = 6L
    myen  = [26.1615,41.5949,68.3086,111.690,185.962,316.103,529.135] ; low -> high (keV)
  END
  'sft' : BEGIN
    mynpa = 3L
    mener = 6L
    myen  = [366754.,461998.,581053.,747730.,934250.,1.18823e+06,1.56524e+06]
  END
  'so' : BEGIN
    mynpa = 8L
    mener = 8L
    myen  = [58.7879,118.677,187.726,325.842,546.873,1016.81,2082.16,4467.58,6801.17] ; low -> high (keV)
  END
  'sob' : BEGIN
    mynpa = 8L
    mener = 8L
    myen  = [58.7879,118.677,187.726,325.842,546.873,1016.81,2082.16,4467.58,6801.17] ; low -> high (keV)
  END
  'sot' : BEGIN
    mynpa = 3L
    mener = 8L
    myen  = [402086.,497162.,616007.,782390.,972542.,1.42415e+06,6.98610e+06,$
             9.24415e+06,1.15973e+07]
  END
  ELSE : BEGIN
    mynpa = 16L
    mener = 14L
    myen  = REPLICATE(!VALUES.F_NAN,15)
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Define data structure with relevant quantities and return
;-----------------------------------------------------------------------------------------
enpa = CREATE_STRUCT('ENERGIES',myen,'ANGLES',mynpa,'NENER',mener)

RETURN,enpa
END
