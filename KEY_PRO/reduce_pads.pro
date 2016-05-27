;+
;*****************************************************************************************
;
;  FUNCTION :   reduce_pads.pro
;  PURPOSE  :   This program is intended to separate spectra structures produced by
;                 get_padspec.pro or get_padspecs.pro by angle or energy then return
;                 the new separated structures to TPLOT.
;
;  CALLED BY:   
;               calc_padspecs.pro
;
;  CALLS:
;               get_data.pro
;               store_data.pro
;               reduce_dimen.pro
;               options.pro
;               ylim.pro
;               roundsig.pro
;               ndimen.pro
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
;               reduce_pads,name,d,n1,n2,DEFLIM=options,NEWNAME=newname,/NAN,E_UNITS=0,$
;                                        ANGLES=angles
;
;  KEYWORDS:    
;               DEFLIM   :  Structure of default TPLOT plotting options
;               NEWNAME  :  Scalar string defining new TPLOT name to use for reduced data
;               NAN      :  If set, program ignores NaNs
;               E_UNITS  :  Set to one of the following values to change the output units:
;                            0 = eV  [Default]
;                            1 = keV
;                            2 = MeV
;               ANGLES   :  Set to a named variable to return the pitch-angles (IF d=2)
;
;   CHANGED:  1)  Added keyword:  ANGLES                    [06/20/2008   v1.1.0]
;             2)  Updated man page and cleaned up a little  [08/10/2009   v1.2.0]
;             3)  Updated man page                          [10/18/2009   v1.2.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  10/18/2009   v1.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO reduce_pads,name,d,n1,n2,DEFLIM=options,NEWNAME=newname,NAN=nan,E_UNITS=e_units,$
                             ANGLES=angles

;-----------------------------------------------------------------------------------------
; => Define some dummy variables
;-----------------------------------------------------------------------------------------
f    = !VALUES.F_NAN
fmt  = '(g0.0)' 
;-----------------------------------------------------------------------------------------
; => 
;-----------------------------------------------------------------------------------------
IF N_PARAMS() EQ 2 THEN BEGIN
   get_data,name,ptr=p
   n   = N_ELEMENTS(*p.X)
   dim = SIZE(*p.Y,/DIMENSIONS)
   npa = dim[2]
   nd  = N_ELEMENTS(d)
   y   = REPLICATE(f,n,npa,nd)
   y0  = ALOG(*p.Y)
   FOR i=0L, n - 1L DO BEGIN
      FOR j=0L, npa - 1L DO BEGIN
         y[i,j,*] = INTERPOL(REFORM(y0[i,*,j]),REFORM((*p.V1)[i,*]),d)
      ENDFOR
   ENDFOR
   y       = EXP(y)
   newname = STRCOMPRESS(name+'_'+STRING(ROUND(d))+'eV',/REMOVE_ALL)
   dlim    = {SPEC:1,YRANGE:[0,180],YSTYLE:1,ZLOG:1,PANEL_SIZE:.5}
   FOR i=0,nd-1 DO BEGIN
     store_data,newname[i],DATA={X:p.X,Y:y[*,*,i],V:*p.V2},DLIM=dlim
   ENDFOR
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Reduce the dimensions
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(nan) THEN nan = 1
reduce_dimen,name,d,n1,n2,DEFLIM=options,NEWNAME=newname,DATA=data,VRANGE=vrange,NAN=nan

IF NOT KEYWORD_SET(data) THEN RETURN
;-----------------------------------------------------------------------------------------
; => Check units, conversions, and TPLOT labels
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(e_units) THEN e_units = 0
CASE d OF
  1 : BEGIN
    unt   = ([' eV',' keV',' Mev'])[e_units]
    scale = ([1.,1000.,1e6])[e_units]
    options,newname,'SPEC',1,/DEF
    ylim,newname,0,180,/DEF
    options,newname,'YTICKS',2,/DEF
    options,newname,'YTICKV',[0.,90.,180.],/DEF
    options,newname,'PANEL_SIZE',.75,/DEF
  END
  2 : BEGIN
    unt   = ' deg'
    scale = 1.
    ylim,newname,1,1,1,/DEF
    options,newname,'PANEL_SIZE',2.,/DEF
    options,newname,/LABFLAG,COLORS='mbcgyr'
  END
ENDCASE

vrange = roundsig(vrange/scale,SIGFIG=1.3)
vst    = STRCOMPRESS(STRING(vrange,FORMAT=fmt),/REMOVE_ALL)
IF (vrange[0] EQ vrange[1]) THEN BEGIN
  ytitle = vst[0] + unt
ENDIF ELSE BEGIN
  ytitle = vst[0]+'-'+vst[1] + unt
ENDELSE
options,newname,'YTITLE',ytitle,/DEF
options,newname,'S_VALUE',vrange

vals = data.V
IF (ndimen(vals) EQ 2) THEN vals = TOTAL(vals,1,/NAN)/ TOTAL(FINITE(vals),1,/NAN)

vals = roundsig(vals,SIGFIG=1.3)
options,newname,'LABELS',STRCOMPRESS(STRING(vals,FORMAT=fmt),/REMOVE_ALL),/DEF

options,newname,'MAX_VALUE',1e10,/DEF
;-----------------------------------------------------------------------------------------
; -Returns the pitch-angles for plot labeling later if d = 2 on input
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(angles) THEN angles = vrange

END
