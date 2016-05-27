;+
;*****************************************************************************************
;
;  FUNCTION :   plot_vector_hodo_scale.pro
;  PURPOSE  :   Program determines the relative plot scales associated with an input
;                 array of data.  The scales are determined by all three components
;                 of your input vector array.  So the component with the maximum
;                 absolute magnitude will determine your plot scales to be used.
;
;  CALLED BY: 
;               plot_vector_mv_data.pro
;               my_box.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               V1      :  An [N,3] or [3,N] array of vectors
;
;  EXAMPLES:
;               NA
;
;  KEYWORDS:  
;               LSCALE  :  If set, program subtracts off the average of the normalized
;                            data to center it about zero when plotting
;               RANGE   :  Set to a 2-element array defining the start and end elements
;                            of the input data array, V1
;
;   CHANGED:  1)  Updated man page                               [02/12/2009   v1.0.1]
;             2)  Updated man page
;                   and no longer calls my_dimen_force.pro
;                   and renamed from my_plot_scale.pro           [08/12/2009   v2.0.0]
;             3)  Fixed typo in RETURN statement on line 73      [09/16/2009   v2.0.1]
;
;   CREATED:  06/29/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/16/2009   v2.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION plot_vector_hodo_scale,v1,LSCALE=lscale,RANGE=range

;-----------------------------------------------------------------------------------------
; -Define dummy variables and return structure
;-----------------------------------------------------------------------------------------
nd  = 100L
hra = 0d0
vf  = DBLARR(nd)
nvf = DBLARR(nd)
dum = CREATE_STRUCT('PLOT_RANGE',hra,'FIELD',vf,'N_FIELD',nvf)
;-----------------------------------------------------------------------------------------
; -Determine if data is of correct format
;-----------------------------------------------------------------------------------------
d     = REFORM(v1)              ; -Prevent any [1,n] or [n,1] array from going on
mdime = SIZE(d,/DIMENSIONS)     ; -# of elements in each dimension of data
ndime = SIZE(mdime,/N_ELEMENTS) ; - determine if 2D array or 1D array
g3    = WHERE(mdime EQ 3L,gg,COMPLEMENT=b3)
CASE g3[0] OF
  0L   : BEGIN
    m1 = TRANSPOSE(d)
    mg = SQRT(TOTAL(m1^2,2L,/NAN))                   ; => Magnitude of vector
  END
  1L   : BEGIN
    m1 = REFORM(d)
    mg = SQRT(TOTAL(m1^2,2L,/NAN))                   ; => Magnitude of vector
  END
  ELSE : BEGIN
    IF (ndime[0] GT 1L) THEN BEGIN
      MESSAGE,'Incorrect input format: V1 (Must be [N,3] or [3,N] element array)',/INFORMATIONAL,/CONTINUE
      RETURN,dum
    ENDIF ELSE BEGIN
      ;-----------------------------------------------------------------------------------
      ; => Entered a 1D array of data
      ;-----------------------------------------------------------------------------------
      MESSAGE,'Incorrect input format: You entered a 1D array for V1',/INFORMATIONAL,/CONTINUE
      nd      = N_ELEMENTS(d)
      m1      = REPLICATE(d[0],nd,3)
      m1[*,0] = d
      m1[*,1] = d
      m1[*,2] = d
      mg      = NORM(d)
    ENDELSE
  END
ENDCASE
gn = N_ELEMENTS(m1[*,0])                             ; => # of data points
;-----------------------------------------------------------------------------------------
; -Define data range
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(range) THEN BEGIN
  myn = range[1] - range[0]  ; -number of elements used for min. var. calc.
  IF (myn LE gn AND range[0] GE 0 AND range[1] LE gn) THEN BEGIN
    s = range[0]
    e = range[1]
  ENDIF ELSE BEGIN
    print,'Too many elements demanded in keyword: RANGE (mps)'
    s   = 0
    e   = gn - 1L
    myn = gn
  ENDELSE
ENDIF ELSE BEGIN
  s   = 0
  e   = gn - 1L
  myn = gn
ENDELSE
;-----------------------------------------------------------------------------------------
; -Determine how to normalize field and whether to shift them
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(lscale) THEN BEGIN
  bnx        = m1[*,0]/mg
  bny        = m1[*,1]/mg
  bnz        = m1[*,2]/mg
  avx        = MEAN(bnx[s:e],/NAN)
  avy        = MEAN(bny[s:e],/NAN)
  avz        = MEAN(bnz[s:e],/NAN)
  my_pscale  = 1.02
ENDIF ELSE BEGIN
  bnx        = m1[*,0]
  bny        = m1[*,1]
  bnz        = m1[*,2]
  avx        = 0.0
  avy        = 0.0
  avz        = 0.0
  my_pscale  = 1.1
ENDELSE
;-----------------------------------------------------------------------------------------
; -Subtract off average if desired
;-----------------------------------------------------------------------------------------
nagx = (bnx-avx)
nagy = (bny-avy)
nagz = (bnz-avz)
n_v1 = [[nagx],[nagy],[nagz]]
;-----------------------------------------------------------------------------------------
; -Rescale data ranges
;-----------------------------------------------------------------------------------------
xyc_range = my_pscale*MAX([MAX(ABS(nagx[s:e]),/NAN),MAX(ABS(nagy[s:e]),/NAN)],/NAN)
xzc_range = my_pscale*MAX([MAX(ABS(nagx[s:e]),/NAN),MAX(ABS(nagz[s:e]),/NAN)],/NAN)
yzc_range = my_pscale*MAX([MAX(ABS(nagy[s:e]),/NAN),MAX(ABS(nagz[s:e]),/NAN)],/NAN)

h_range   = MAX([xyc_range,xzc_range,yzc_range],/NAN)  ; -range used for hodograms

field_str = CREATE_STRUCT('PLOT_RANGE',h_range,'FIELD',v1,'N_FIELD',n_v1)

RETURN,field_str
END