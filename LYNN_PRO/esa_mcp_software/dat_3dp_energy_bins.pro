;+
;*****************************************************************************************
;
;  FUNCTION :   dat_3dp_energy_bins.pro
;  PURPOSE  :   Determine energy bins one wants to use for generalized input.  The 
;                 program returns a data structure containing the start and end
;                 elements for the desired energy bins (if EBINS is set, else the
;                 default is [0,# of energies - 1]) and the "actual" energies
;                 associated with the data structure D2.
;
;  CALLED BY:   NA
;
;  CALLS:
;               get_data.pro
;               pesa_high_bad_bins.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               D2 :  3DP data structure either from spec plots (i.e. get_padspec.pro)
;                        or from pad.pro, get_el.pro, get_sf.pro, etc.
;
;  EXAMPLES:
;
;               3dp> my_get_padspec,'el', bsource='wi_B3(GSE)',num_pa=16,ENBINS=10
;               3dp> get_data,'el_pads', data = dat, dlim=dlim,lim=lim
;
;               3dp> my_ens = dat_3dp_energy_bins(dat,EBINS=10)
;               3dp> help, my_ens,/str
;               ** Structure <aa96b8>, 2 tags, length=48, data length=48, refs=1:
;                  E_BINS          LONG      Array[2]
;                  ENERGIES        FLOAT     Array[10]
;
;
;               3dp> print, my_ens.e_bins
;                          0           9
;               3dp> print, my_ens.ALL_ENERGIES 
;                     1122.55      768.461      528.102      363.049      249.577
;                     171.631      118.545      82.1101      57.0127      39.9383
;
;               {The following give the same results as above}
;
;               3dp> my_ens1 = dat_3dp_energy_bins(dat,EBINS=[0,9])
;               3dp> my_ens2 = dat_3dp_energy_bins(dat,EBINS=lindgen(10))
;
;               {Or try the following...}
;
;               3dp> tt = dat.x[0]
;               3dp> el = get_el(tt)
;               3dp> my_ens3 = dat_3dp_energy_bins(el,EBINS=10)
;
;  KEYWORDS:  
;               EBINS : number of energy bins wanted (e.g. 10 or [0,9] or [2,11])
;                         which mark high -> low energy bins where bin 9 has a 
;                         lower energy associated with it than bin 0 (sf and so 
;                         reverse)  {i.e. [high #,low #]}
;
;   CHANGED:  1)  Fixed a possible issue which occurs with Pesa High
;                  data energy values                     [11/07/2008   v1.0.5]
;             2)  Added program:  my_pesa_high_bad_bins.pro which is more
;                  efficient at dealing with Change 1)    [04/26/2009   v1.0.6]
;             3)  Rewrote and renamed with more comments  [07/20/2009   v2.0.0]
;             4)  Fixed syntax error when in EBINS keyword usage/calcs
;                                                         [08/31/2009   v2.0.1]
;             5)  Changed my_pesa_high_bad_bins.pro to pesa_high_bad_bins.pro
;                                                         [10/13/2009   v2.1.0]
;
;   CREATED:  06/06/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/13/2009   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION dat_3dp_energy_bins,d2,EBINS=ebins

;-----------------------------------------------------------------------------------------
; -Make sure we have the correct type of data
;-----------------------------------------------------------------------------------------
IF (SIZE(d2,/TYPE) NE 8) THEN BEGIN
  IF (SIZE(d2,/TYPE) EQ 7) THEN BEGIN
    get_data,d2,DATA=d
    IF (SIZE(d,/N_DIMENSIONS) EQ 0L) THEN BEGIN
      MESSAGE,'Null data quantity and/or structure...',/INFORMATIONAL,/CONTINUE
      PRINT,'No labels or positions will be returned!'
      RETURN,0
    ENDIF
  ENDIF ELSE BEGIN
    MESSAGE,'Incorrect data entry, MUST be STRUCTURE!',/INFORMATIONAL,/CONTINUE
    RETURN,0
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; -Determine what type of structure this is
;-----------------------------------------------------------------------------------------
d      = d2
mytags = TAG_NAMES(d)
gtags  = WHERE(mytags EQ 'DATA_NAME',gags)   ; -check for get_el.pro or pad.pro str.'s
gtags1 = WHERE(mytags EQ 'Y',gags1)          ; -general tplot structure
gtags2 = WHERE(mytags EQ 'V',gags2)          ; -3D particle spec structure w/o separated angle bins
gtags3 = WHERE(mytags EQ 'V1',gags3)         ; -3D particle spec w/ separated angle bins

check  = WHERE([gags,gtags1,gags2,gags3] GT 0,gcheck)
IF (gcheck GT 0) THEN BEGIN
  IF (gcheck GT 1) THEN BEGIN
    ndims = SIZE(d.Y,/DIMENSIONS)               ; -# of elements in each dimension
    mdims = N_ELEMENTS(ndims)                   ; -# of dimensions
    check2 = WHERE([gags2,gags3] GT 0,gcheck2)
    IF (gcheck2 GT 0) THEN BEGIN
      CASE check2[0] OF
        0 : BEGIN      ; -spec type structure {X:[n],Y:[n,m],V:[n,m]}
          ;-------------------------------------------------------------------------------
          ; -Make sure energies haven't been labeled as zeros
          ;-------------------------------------------------------------------------------
          gvals  = WHERE(d.V EQ 0.0,gvls)
          IF (gvls GT 0) THEN BEGIN
            datv2 = d.V
            gvind = ARRAY_INDICES(datv2,gvals)
            datv2[gvind[0,*],gvind[1,*]] = !VALUES.F_NAN
          ENDIF ELSE BEGIN
            datv2 = d.V
          ENDELSE
          nd1    = ndims[0]                   ; -typically for spec data => # of samples
          nd2    = ndims[1]                   ; -" " => # of energy bins
          nd3    = 0L
          mener  = nd2 - 1L                   ; -variable used for loops
          tnd2   = TOTAL(FINITE(d.V),1,/NAN)
          myener = TOTAL(d.V,1,/NAN)/tnd2     ; -get energies (eV)
          eln    = 1L                         ; -energies are in the 2nd column for specs
        END
        1 : BEGIN     ; -spec type structure {...X:[n],Y:[n,m,l],V1:[n,m],V2:[n,l]...}
          ;-------------------------------------------------------------------------------
          ; -Make sure energies haven't been labeled as zeros
          ;-------------------------------------------------------------------------------
          gvals  = WHERE(d.V1 EQ 0.0,gvls)
          IF (gvls GT 0) THEN BEGIN
            datv2 = d.V1
            gvind = ARRAY_INDICES(datv2,gvals)
            datv2[gvind[0,*],gvind[1,*]] = !VALUES.F_NAN
          ENDIF ELSE BEGIN
            datv2 = d.V1
          ENDELSE
          nd1    = ndims[0]                   ; -typically for spec data => # of samples
          nd2    = ndims[1]                   ; -" " => # of energy bins
          nd3    = ndims[2]                   ; -" " => # of pitch-angles which have been summed over
          mener  = nd2 - 1L                   ; -variable used for loops
          tnd2   = TOTAL(FINITE(d.V1),1,/NAN)
          myener = TOTAL(d.V1,1,/NAN)/tnd2    ; -get energies (eV)
          eln    = 1L                         ; -energies are in the 2nd column for specs
        END
      ENDCASE
    ENDIF ELSE BEGIN
      MESSAGE,'Incorrect data entry!',/INFORMATIONAL,/CONTINUE
      RETURN,0
    ENDELSE
  ENDIF ELSE BEGIN
    CASE check[0] OF
      0 : BEGIN
        ;---------------------------------------------------------------------------------
        ; -Make sure energies haven't been labeled as zeros
        ;---------------------------------------------------------------------------------
        nametest = STRLOWCASE(STRMID(d.DATA_NAME,0L,9L))
        IF (nametest EQ 'pesa high') THEN BEGIN      ; -Prevent energy bin errors
          pesa_high_bad_bins,d
        ENDIF
        gvals  = WHERE(d.ENERGY EQ 0.0,gvls)
        IF (gvls GT 0) THEN BEGIN
          datv2 = d.ENERGY
          gvind = ARRAY_INDICES(datv2,gvals)
          datv2[gvind[0,*],gvind[1,*]] = !VALUES.F_NAN
        ENDIF ELSE BEGIN
          datv2 = d.ENERGY
        ENDELSE
        ndims  = SIZE(d.ENERGY,/DIMENSIONS)          ; -# of elements in each dimension
        mdims  = N_ELEMENTS(ndims)                   ; -# of dimensions
        nd1    = ndims[0]                            ; -Typically for 3DP Mom.=> # of energy bins
        nd2    = ndims[1]                            ; -" " => # of data samples
        mener  = nd1 - 1L ; variable used for loops
        tnd2   = TOTAL(FINITE(datv2),2,/NAN)         ; -# of finite energy bins for next line
        myener = TOTAL(datv2,2,/NAN)/tnd2            ; -Approximate energy values for each bin
        eln    = 0L                                  ; -Energies are in the first column for 3d moms 
      END
      ELSE : BEGIN
        MESSAGE,'I have no clue what you are trying to do...',/INFORMATIONAL,/CONTINUE
        RETURN,0
      END
    ENDCASE
  ENDELSE
ENDIF ELSE BEGIN
  MESSAGE,'Incorrect data entry!',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE
;-----------------------------------------------------------------------------------------
; -Determine which array elements are of interest
;-----------------------------------------------------------------------------------------
xener = MAX(datv2,/NAN,lxe)              ; -Max energy and its location
nener = MIN(datv2,/NAN,lne)              ; -Min " "
myxe  = (ARRAY_INDICES(datv2,lxe))[eln]  ; -Indice of max energy
myne  = (ARRAY_INDICES(datv2,lne))[eln]  ; -" " min " "
IF (myxe LT myne) THEN BEGIN             ; -energies indexed from high to low (Eesa/Pesa)
  en_o = 0
  low1 = 0
ENDIF ELSE BEGIN                         ; -energies indexed from low to high (SST, typically)
  en_o = (mener + 1)
  low1 = 1
ENDELSE

estart  = 0L         ; -starting energy array element for energy bins
eend    = 0L         ; -ending " "
newbins = LONARR(2)  ; -[estart,eend]

mytype  = SIZE(ebins,/TYPE)           ; -type code {0:undefined,2:int,3:long,4:flt,5:dbl...}
mydims  = SIZE(ebins,/N_DIMENSIONS)   ; -# of dimensions {e.g. fltarr(3,3) => 2}
myelms  = SIZE(ebins,/DIMENSIONS)     ; -# of elements in each dimension
myelto  = SIZE(ebins,/N_ELEMENTS)     ; -# of total elements {e.g. fltarr(3,3) => 9}
IF KEYWORD_SET(ebins) THEN BEGIN
  ;---------------------------------------------------------------------------------------
  ; -Ebins is undefined, yet set
  ;---------------------------------------------------------------------------------------
  IF (mytype LT 2 OR mytype GT 3) THEN BEGIN
    MESSAGE,'Invalid data index, undefined!',/INFORMATIONAL,/CONTINUE
    PRINT,'Using default energies!'
    estart  = 0
    eend    = mener
    newbins = [estart,eend]
  ENDIF
  ;---------------------------------------------------------------------------------------
  ; -Determine what type of format was entered for ebins
  ;---------------------------------------------------------------------------------------
  CASE mydims[0] OF
    0 : BEGIN  ; -entered a scalar
      my_en_els = LINDGEN(ebins)
      nebins    = N_ELEMENTS(my_en_els) - 1L
    END
    1 : BEGIN  
    ;-------------------------------------------------------------------------------------
    ; -Entered a 2 or more element array {e.g. [start,...,end]} of energy bins
    ;-------------------------------------------------------------------------------------
      temp_ens  = MAX(ebins,/NAN) - MIN(ebins,/NAN) + 1L
      my_en_els = LINDGEN(temp_ens) + MIN(ebins,/NAN)
      nebins    = N_ELEMENTS(my_en_els) - 1L
    END
    ;-------------------------------------------------------------------------------------
    ; -Entered an array or something else with more than 2 dimensions
    ;-------------------------------------------------------------------------------------
    ELSE : BEGIN
      MESSAGE,'Invalid data format!',/INFORMATIONAL,/CONTINUE
      PRINT,'Using default energies!'
      my_en_els = LINDGEN(mener)
      nebins    = N_ELEMENTS(my_en_els) - 1L
    END
  ENDCASE
  CASE low1[0] OF
    0 : BEGIN  ; - Energies indexed from high to low (Eesa/Pesa)
      estart  = my_en_els[0]
      eend    = my_en_els[nebins]
    END
    1 : BEGIN  ; - Energies indexed from low to high (SST, typically)
      estart  = (en_o - my_en_els[nebins]) - 1L
      eend    = (en_o - my_en_els[0]) - 1L
    END
    ELSE : BEGIN
      MESSAGE,'Invalid data format!',/INFORMATIONAL,/CONTINUE
      PRINT,'Using default energies!'
      estart  = 0
      eend    = mener
    END
  ENDCASE
ENDIF ELSE BEGIN
  ;---------------------------------------------------------------------------------------
  ; -Nothing was entered
  ;---------------------------------------------------------------------------------------
  estart  = 0
  eend    = mener
ENDELSE

newbins = CREATE_STRUCT('E_BINS',[estart,eend],'ALL_ENERGIES',myener)
RETURN,newbins
END