;+
;*****************************************************************************************
;
;  FUNCTION :   reduce_dimen.pro
;  PURPOSE  :   Reduces a 3-Dimensional TPLOT structure to a 2-Dimensional TPLOT 
;                 structure such that it depends on only energy or pitch-angle,
;                 depending on user input.
;
;  CALLED BY:   
;               reduce_pads.pro
;
;  CALLS:
;               get_data.pro
;               dimen.pro
;               ndimen.pro
;               extract_tags.pro
;               store_data.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME     :  Scalar string associated with a TPLOT variable
;               D        :  Set to 1 to split up by energy or 2 to split up pitch-angles
;               N1       :  Scalar integer defining the start element to sum over
;               N2       :  Scalar integer defining the end element to sum over
;
;  EXAMPLES:    
;               reduce_dimen,name,d,n1,n2,DEFLIM=deflim,NEWNAME=newname
;
;  KEYWORDS:    
;               DEFLIM   :  Structure of default TPLOT plotting options
;               NEWNAME  :  Scalar string defining new TPLOT name to use for reduced data
;               DATA     :  Set to a named variable to return the data to
;               VRANGE   :  Set to a named variable to return the data being s
;               NAN      :  If set, program ignores NaNs
;
;   CHANGED:  1)  I did something...?                       [06/20/2008   v1.0.3]
;             2)  Updated man page and cleaned up a little  [08/10/2009   v1.1.0]
;
;   CREATED:  Sept 1995
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/10/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO reduce_dimen, name,d, n1, n2, DEFLIM=options,NEWNAME=newname,DATA=data, $
                                  VRANGE=vrange,NAN=nan

;-----------------------------------------------------------------------------------------
; => Check input format
;-----------------------------------------------------------------------------------------
get_data,name,DATA=data
IF NOT KEYWORD_SET(data) THEN RETURN

IF NOT KEYWORD_SET(newname) THEN BEGIN
  newname = STRING(name,d,n1,n2,FORMAT='(a0,"-",i0,"-",i0,":",i0)')
ENDIF

dim   = dimen(data.Y)
range = [n1,n2]
IF (d EQ 1) THEN BEGIN
   v      = REFORM(data.V2)
   vrange = REFORM(data.V1)
   IF (N_ELEMENTS(range) EQ 0L) THEN range = [0L,dim[1]-1L] 
   y      = data.Y(*,range[0]:range[1],*)
ENDIF ELSE BEGIN
   v      = REFORM(data.V1)
   vrange = REFORM(data.V2)
   IF (N_ELEMENTS(range) EQ 0L) THEN range = [0L,dim[2]-1L]
   y      = data.Y[*,*,range[0]:range[1]]
ENDELSE

IF (ndimen(vrange) EQ 2) THEN vrange = TOTAL(vrange,1,/NAN)/ TOTAL(FINITE(vrange),1,/NAN)
vrange = vrange[range]

IF (ndimen(y) EQ 3) THEN BEGIN
  IF KEYWORD_SET(nan) THEN BEGIN
    y = TOTAL(y,d+1L,/NAN)/ TOTAL(FINITE(y),d+1L,/NAN)
  ENDIF ELSE BEGIN
    y = TOTAL(y,d+1L)/dim[d]
  ENDELSE
ENDIF
data = {X:data.X,Y:y,V:v}
extract_tags,data,options
;-----------------------------------------------------------------------------------------
; => Send new data to new TPLOT name
;-----------------------------------------------------------------------------------------
store_data,newname,DATA=data
RETURN
END

