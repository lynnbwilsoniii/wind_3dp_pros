;+
;*****************************************************************************************
;
;  FUNCTION :   vec_2dim_shift.pro
;  PURPOSE  :   Shifts vectors in plots and normalizes data (if desired)
;                 {for vector structures [e.g. 'wi_B3(GSE)', 'Vp', etc.]}
;                 and, if labels already present, returns new labels if 
;                 selected vector-components were shifted.
;
;  CALLED BY: 
;               spec_vec_data_shift.pro
;
;  CALLS:
;               store_data.pro
;               options.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT        :  3D data structure of the form =>
;                               {X:[times([N]-Elements)],Y:[data([N,3]-Elements)]}
;               NAME       :  Scalar string for corresponding TPLOT variable name with
;                               associated spectra (or vector) data separated by 
;                               pitch-angle or component as TPLOT variables 
;                               [e.g. 'wi_B3(GSE)']
;
;  EXAMPLES:
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
;   CHANGED:  1)  NA                                         [06/15/2008   v1.0.1]
;             2)  Updated man page                           [03/19/2009   v1.0.2]
;             3)  Cleaned up syntax and comments
;                   and renamed from my_padspec_4.pro        [08/10/2009   v2.0.0]
;             4)  Added keyword:  RANGE_AVG                  [09/19/2009   v2.1.0]
;
;   NOTES:      
;               1)  User should NOT call this program directly, use spec_vec_data_shift.pro
;
;   CREATED:  06/15/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/19/2009   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO vec_2dim_shift,dat,name,WSHIFT=wshift,DATN=datn,DATS=datns,NEW_NAME=new_name,$
                            RANGE_AVG=range_avg

;-----------------------------------------------------------------------------------------
; => Make sure dat is a structure
;-----------------------------------------------------------------------------------------
d     = dat
IF (SIZE(d,/TYPE) NE 8) THEN BEGIN
  messg = 'Incorrect input format:  '+name+' (MUST be a TPLOT structure)'
  MESSAGE,messg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Check input format
;-----------------------------------------------------------------------------------------
IF (SIZE(d.Y,/TYPE) LT 3L OR SIZE(d.Y,/TYPE) GT 6L) THEN BEGIN
  MESSAGE,'Incorrect input format:  DAT',/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
mytags = TAG_NAMES(d)
ntags  = N_TAGS(d)
gtags  = WHERE(mytags EQ 'MLABS1' OR mytags EQ 'MLABS2',gtgs)
IF (gtgs GT 0) THEN BEGIN
  IF (gtgs GT 1) THEN BEGIN
    labs = d.(gtags[0])
  ENDIF ELSE BEGIN
    labs = d.(gtags[0])
  ENDELSE
ENDIF ELSE BEGIN
  labs = STRARR(3)
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define dimensions
;-----------------------------------------------------------------------------------------
ndims = SIZE(REFORM(d.Y),/DIMENSIONS)  ; -# of elements/dimension
mdims = N_ELEMENTS(ndims)              ; -# of dimensions
gd1   = WHERE(ndims EQ 3L,g1)
IF (g1 GT 0) THEN BEGIN
  CASE gd1[0] OF
    0    : BEGIN
      newy = TRANSPOSE(d.Y)
    END
    ELSE : BEGIN
      newy = d.Y
    END
  ENDCASE
  nnm  = N_ELEMENTS(d.X)
  dims = SIZE(newy,/DIMENSIONS)
  nd1  = dims[0]
  nd2  = dims[1]
ENDIF ELSE BEGIN
  MESSAGE,'Incorrect input format:  DAT.Y MUST be an [N,3]-Element Array!',/INFORMATIONAL,/CONTINUE
  RETURN
ENDELSE
;-----------------------------------------------------------------------------------------
; -If RANGE_AVG is set, normalize the data by the average for this time range
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(range_avg) THEN BEGIN
  avg_inds = LINDGEN(nd1)
ENDIF ELSE BEGIN
  nra = N_ELEMENTS(range_avg)
  IF (nra EQ 2) THEN BEGIN
    gnra = WHERE(d.X LE range_avg[1] AND d.X GE range_avg[0],gn)
    IF (gn GT 1L) THEN avg_inds = gnra ELSE avg_inds = LINDGEN(nd1)
  ENDIF ELSE BEGIN
    MESSAGE,'Incorrect keyword format:  RANGE_AVG MUST be a 2-Element Array!',/INFORMATIONAL,/CONTINUE
    PRINT,'Using default setting...'
    avg_inds = LINDGEN(nd1)
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; -If wshift is set, perform a energy-weighted data shift
;-----------------------------------------------------------------------------------------
newlabs = STRARR(nd2)
newlabs = labs
IF KEYWORD_SET(wshift) THEN BEGIN
  flav    = FLTARR(N_ELEMENTS(wshift))
  FOR i=0L, N_ELEMENTS(wshift)-1L DO BEGIN
    flav[i]                  = ((-1.)^i)*5e-1*ABS(MIN(newy[avg_inds,wshift[i]],/NAN))
    newy[avg_inds,wshift[i]] = newy[avg_inds,wshift[i]] + flav[i]
    newlabs[i]               = newlabs[i]+' +'
    newlabs[i]              += STRTRIM(STRING(FORMAT='(e15.3)',flav[i]),2)
  ENDFOR
ENDIF
;-----------------------------------------------------------------------------------------
; -If datn is set, normalize the data by flav[i]
;-----------------------------------------------------------------------------------------
flav    = FLTARR(2)
avx     = MEAN(newy[avg_inds,0],/NAN)
avy     = MEAN(newy[avg_inds,1],/NAN)
avz     = MEAN(newy[avg_inds,2],/NAN)
mnav    = MIN([avx[0],avy[0],avz[0]],/NAN,lnn)
mxav    = MAX([avx[0],avy[0],avz[0]],/NAN,lxx)
; => Determine which component had min value, thus which one to shift -
CASE lnn OF
  0 : BEGIN
    flav[0] = -1.*5e-1*ABS(MIN(newy[avg_inds,0],/NAN))
  END
  1 : BEGIN
    flav[0] = -1.*5e-1*ABS(MIN(newy[avg_inds,1],/NAN))
  END
  2 : BEGIN
    flav[0] = -1.*5e-1*ABS(MIN(newy[avg_inds,2],/NAN))
  END
ENDCASE
; => Determine which component had max value, thus which one to shift +
CASE lxx OF
  0 : BEGIN
    flav[1] = 5e-1*ABS(MAX(newy[avg_inds,0],/NAN))
  END
  1 : BEGIN
    flav[1] = 5e-1*ABS(MAX(newy[avg_inds,1],/NAN))
  END
  2 : BEGIN
    flav[1] = 5e-1*ABS(MAX(newy[avg_inds,2],/NAN))
  END
ENDCASE
; => Check if data should be normalized too
IF NOT KEYWORD_SET(datn) THEN BEGIN
  newy[*,lnn]  += flav[0]
  newy[*,lxx]  += flav[1]
  newlabs[lnn]  = newlabs[lnn]+STRTRIM(STRING(FORMAT='(e15.3)',flav[0]),2)
  newlabs[lxx]  = newlabs[lxx]+STRTRIM(STRING(FORMAT='(e15.3)',flav[1]),2)
ENDIF ELSE BEGIN
  IF KEYWORD_SET(dats) THEN BEGIN
    avys          = [avx[0],avy[0],avz[0]]
    newy[*,lnn]  += flav[0]
    newy[*,lxx]  += flav[1]
    newy[*,lnn]  /= avys[lnn]
    newy[*,lxx]  /= avys[lxx]
    newlabs[lnn]  = newlabs[lnn]+STRTRIM(STRING(FORMAT='(e15.3)',flav[0]/avys[lnn]),2)
    newlabs[lxx]  = newlabs[lxx]+STRTRIM(STRING(FORMAT='(e15.3)',flav[1]/avys[lxx]),2)
  ENDIF ELSE BEGIN
    newy[*,lnn]  /= avys[lnn]
    newy[*,lxx]  /= avys[lxx]
  ENDELSE
ENDELSE
; => Send normalized and/or shifted data back to TPLOT
myd = CREATE_STRUCT('X',d.X,'Y',newy)
IF NOT KEYWORD_SET(new_name) THEN new_name = name+tname
store_data,new_name,DATA=myd
IF (STRLEN(labs[0]) GT 0) THEN BEGIN
  options,new_name,'LABELS',newlabs
ENDIF
RETURN
END
