;+
;*****************************************************************************************
;
;  FUNCTION :   spec_vec_data_shift.pro
;  PURPOSE  :   Shifts (vertically) and/or normalizes the data to look at relative
;                 changes in particle spectra or vectors.  The normalization and shifting
;                 are done with respect to each component (i.e. each line) of the data
;                 individually.  A range of data for normalization purposes can be 
;                 chosen to allow one to normalize by an upstream (with respect to a
;                 shock) average as opposed to the entire data set.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_data.pro
;               str_element.pro
;               spec_2dim_shift.pro
;               spec_3dim_shift.pro
;               vec_2dim_shift.pro
;               tnames.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME       :  Scalar string for corresponding TPLOT variable name with
;                               associated spectra (or vector) data separated by 
;                               pitch-angle or component as TPLOT variables 
;                               [e.g. 'nelb_pads']
;
;  EXAMPLES:
;               ........................
;               : {normalize the data} :
;               ........................
;               spec_vec_data_shift,'nsf_pads',/DATN,NEW_NAME='nsf_pads_n'
;               ..............................
;               : {shift 4 highest energies} :
;               ..............................
;               spec_vec_data_shift,'npl_pads',NEW_NAME='npl_pads_wsh',WSHIFT=[0,3]
;               ................................................
;               : {normalize AND shift data to avoid overlaps} :
;               ................................................
;               spec_vec_data_shift,'nel_pads',/DATN,/DATS,NEW_NAME='nel_pads_sh_n'
;
;  KEYWORDS:  
;               NEW_NAME   :  New string name for returned TPLOT variable
;               DATN       :  If set, data is returned normalized by 
;                               the AVG. for each energy bin
;                               [i.e. still a stacked spectra plot but normalized]
;               DATS       :  If set, data is shifted to avoid overlaps
;               WSHIFT     :  Performs a weighted shift of only the specified 
;                               energy bins {e.g. 1st 3 -> lowest energies [0,2]}
;               RANGE_AVG  :  Two element double array specifying the time range
;                               (Unix time) to use for constructing an average to
;                               normalize the data by when using the keyword DATN
;
;   CHANGED:  1)  NA                                         [06/24/2008   v1.2.26]
;             2)  Updated man page                           [03/19/2009   v1.2.27]
;             3)  Changed program my_2dim_spec_shift.pro to spec_2dim_shift.pro
;                   and my_3dim_spec_shift.pro to spec_3dim_shift.pro
;                   and my_2dim_vec_shift.pro to vec_2dim_shift.pro
;                   and renamed from my_data_shift_2.pro     [08/10/2009   v2.0.0]
;             4)  Added keyword:  RANGE_AVG                  [09/19/2009   v2.1.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/19/2009   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO spec_vec_data_shift,name,NEW_NAME=new_name,DATN=datn,DATS=datns,WSHIFT=wshift,$
                             RANGE_AVG=range_avg

;-----------------------------------------------------------------------------------------
; => Make sure name is either a tplot index or tplot string name
;-----------------------------------------------------------------------------------------
IF (SIZE(name,/TYPE) GT 1L AND SIZE(name,/TYPE) LT 8L) THEN BEGIN
  IF (SIZE(name,/TYPE) EQ 7L) THEN BEGIN
    name = name
  ENDIF ELSE BEGIN
    name = (tnames(ROUND(name)))[0]
  ENDELSE
  get_data,name,DATA=ds,DLIM=dlim,LIM=lim
ENDIF ELSE BEGIN
  MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
  RETURN
ENDELSE
sname = STRMID(name,0,3)

d   = ds
ylg = 1
;-----------------------------------------------------------------------------------------
; => Make sure d is a structure
;-----------------------------------------------------------------------------------------
IF (SIZE(d,/TYPE) NE 8) THEN BEGIN
  messg = 'Incorrect input format:  '+name+' (MUST have a TPLOT structure)'
  MESSAGE,messg,/INFORMATIONAL,/CONTINUE
  GOTO,JUMP_FIN
ENDIF

mytags = TAG_NAMES(d)       ; => Structure Tags (e.g. 'X' or 'V' or 'V1', etc.)
ntags  = N_TAGS(d)          ; => Number of Tags
;-----------------------------------------------------------------------------------------
; => Check if RANGE_AVG is set
;-----------------------------------------------------------------------------------------
gtplotx = WHERE(STRLOWCASE(mytags) EQ 'x',gtpx)
IF (gtpx EQ 0) THEN BEGIN
  MESSAGE,'Incorrect TPLOT structure format:  '+name,/INFORMATIONAL,/CONTINUE
  PRINT,'No shifting or normalization will be done...'
  RETURN
ENDIF

IF NOT KEYWORD_SET(range_avg) THEN BEGIN
  grange   = [MIN(d.X,/NAN),MAX(d.X,/NAN)]
ENDIF ELSE BEGIN
  nra = N_ELEMENTS(range_avg)
  IF (nra EQ 2) THEN BEGIN
    gnra = WHERE(d.X LE range_avg[1] AND d.X GE range_avg[0],gn)
    IF (gn GT 1L) THEN BEGIN
      grange = [MIN(d.X[gnra],/NAN),MAX(d.X[gnra],/NAN)]
    ENDIF ELSE BEGIN
      MESSAGE,'Bad time range:  RANGE_AVG',/INFORMATIONAL,/CONTINUE
      PRINT,'Using default setting...'
      grange   = [MIN(d.X,/NAN),MAX(d.X,/NAN)]
    ENDELSE
  ENDIF ELSE BEGIN
    messg    = 'Incorrect keyword format:  RANGE_AVG MUST be a 2-Element Array!'
    MESSAGE,messg,/INFORMATIONAL,/CONTINUE
    PRINT,'Using default setting...'
    grange   = [MIN(d.X,/NAN),MAX(d.X,/NAN)]
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Look for data labels in 2D vector structures
;-----------------------------------------------------------------------------------------
IF (SIZE(dlim,/TYPE) EQ 8 AND ntags EQ 2) THEN BEGIN
  dltags = TAG_NAMES(dlim)
  gdlabs = WHERE(dltags EQ 'LABELS',gdla)
  IF (gdla GT 0) THEN str_element,d,'MLABS1',dlim.(gdlabs[0]),/ADD_REPLACE
ENDIF
IF (SIZE(lim,/TYPE) EQ 8 AND ntags EQ 2) THEN BEGIN
  ltags  = TAG_NAMES(lim)
  glabs  = WHERE(ltags EQ 'LABELS',gla)
  IF (gla GT 0) THEN str_element,d,'MLABS2',lim.(glabs[0]),/ADD_REPLACE
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine what type of structure this is
;-----------------------------------------------------------------------------------------
gtags  = WHERE(mytags EQ 'DATA_NAME',gags)   ; => check for get_el.pro or pad.pro str.'s
gtags1 = WHERE(mytags EQ 'Y',gags1)          ; => general tplot structure
gtags2 = WHERE(mytags EQ 'V',gags2)          ; => 3D particle spec structure w/o separated angle bins
gtags3 = WHERE(mytags EQ 'V1',gags3)         ; => 3D particle spec w/ separated angle bins
check  = WHERE([gags,gtags1,gags2,gags3] GT 0,gcheck)

IF (gcheck GT 0) THEN BEGIN
  IF (gcheck GT 1) THEN BEGIN
    check2 = WHERE([gags2,gags3] GT 0,gcheck2)
    IF (gcheck2 GT 0) THEN BEGIN
      CASE check2[0] OF
        0 : BEGIN      ; => spec type structure {X:[n],Y:[n,m],V:[n,m]}
          spec_2dim_shift,d,name,WSHIFT=wshift,DATN=datn,DATS=datns,NEW_NAME=new_name,$
                                 RANGE_AVG=grange
          GOTO,JUMP_FIN
        END
        1 : BEGIN     ; => spec type structure {...X:[n],Y:[n,m,l],V1:[n,m],V2:[n,l]...}
          spec_3dim_shift,d,name,WSHIFT=wshift,DATN=datn,DATS=datns,NEW_NAME=new_name,$
                                 RANGE_AVG=grange
          GOTO,JUMP_FIN
        END
        ELSE : BEGIN
          MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
          RETURN
        END
      ENDCASE
    ENDIF ELSE BEGIN
      MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
      RETURN
    ENDELSE
  ENDIF ELSE BEGIN
    CASE check[0] OF
      1 : BEGIN
        vec_2dim_shift,d,name,WSHIFT=wshift,DATN=datn,DATS=datns,NEW_NAME=new_name,$
                              RANGE_AVG=grange
        GOTO,JUMP_FIN
      END
      ELSE : BEGIN
        MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
        RETURN
      END
    ENDCASE
  ENDELSE
ENDIF ELSE BEGIN
  MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
  RETURN
ENDELSE
;=========================================================================================
JUMP_FIN:
;=========================================================================================
END
