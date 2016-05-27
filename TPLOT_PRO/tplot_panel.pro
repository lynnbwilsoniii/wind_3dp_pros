;+
;*****************************************************************************************
;
;  FUNCTION :   tplot_panel.pro
;  PURPOSE  :   Sets the graphics parameters to the specified tplot panel.
;                 The time offset is returned through the optional keyword DELTATIME.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               tplot_com.pro
;               str_element.pro
;               wi.pro
;               get_data.pro
;               data_type.pro
;               mplot.pro
;
;  REQUIRES:    
;               loaded TPLOT data
;
;  INPUT:
;               TIME       :  N-Element array of Unix times associated with input Y
;               Y          :  N-Element array of data associated with input TIME
;
;  EXAMPLES:    
;               tplot_panel,tt_perp,Eperp,PSYM=2,VARIABLE='Epara_0'
;
;  KEYWORDS:    
;               PANEL      :  Set to a named variable to return the panel # of designated
;                               TPLOT variable set by VARIABLE keyword
;               DELTATIME  :  Set to a named variable to return the time offset
;               VARIABLE   :  Scalar string of a previously plotted TPLOT variable
;               OPLOTVAR   :  Scalar string of TPLOT variable to overplot on VARIABLE
;               PSYM       :  IDL keyword for plotting symbols instead of lines etc.
;
;   CHANGED:  1)  ?? Davin changed something                       [04/17/2002   v1.0.9]
;             2)  Rewrote and altered syntax slightly              [09/16/2009   v1.1.0]
;             3)  Made the call to wi.pro optionally dependent on current device name
;                                                                  [09/17/2009   v1.1.1]
;             4)  Added keywords:  COLOR                           [09/18/2009   v1.1.2]
;
;   NOTES:      
;               1)  Plot data in TPLOT that you wish to overplot something else onto.
;                     Then run this program, as in the example above, where the
;                     keyword VARIABLE defines the TPLOT handle to plot the data
;                     EPERP vs. TT_PERP over.  
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/18/2009   v1.1.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO tplot_panel,time,y,PANEL=pan,DELTATIME=dt,VARIABLE=var,OPLOTVAR=opvar ,$
                       PSYM=psym,COLOR=color

@tplot_com.pro

str_element,tplot_vars,'OPTIONS.WINDOW',tplot_window
str_element,tplot_vars,'SETTINGS.X',tplot_x
str_element,tplot_vars,'SETTINGS.Y',tplot_y
str_element,tplot_vars,'SETTINGS.CLIP',tplot_clip
str_element,tplot_vars,'SETTINGS.TIME_OFFSET',time_offset
str_element,tplot_vars,'OPTIONS.VARNAMES',tplot_var

dt = 0.
IF (STRLOWCASE(!D.NAME) EQ 'x') THEN wi,tplot_window
IF KEYWORD_SET(var) THEN BEGIN
   i = WHERE(tplot_var EQ var,n)
   IF (n NE 0) THEN pan = i
ENDIF

IF (N_ELEMENTS(pan) EQ 0) THEN BEGIN
;if not keyword_set(pan) then begin
   MESSAGE,var+' Not plotted yet!',/INFORMATIONAL
   RETURN
ENDIF

!P.CLIP = tplot_clip[*,pan]
!X      = tplot_x
!Y      = tplot_y[pan]
dt      = time_offset

IF N_PARAMS() EQ 2 THEN  opvar = {X:REFORM(time),Y:REFORM(y)}

IF KEYWORD_SET(opvar) THEN BEGIN
   IF (data_type(opvar) EQ 7) THEN  get_data,opvar,DATA=d,ALIMI=l
   IF (data_type(opvar) EQ 8) THEN  d = opvar
   IF (data_type(d) EQ 8) THEN BEGIN
      d.X = (d.X - time_offset)
      str_element,/ADD_REPLACE,l,'PSYM',psym
      IF KEYWORD_SET(color) THEN BEGIN
        str_element,/ADD_REPLACE,l,'COLOR',color[0]
      ENDIF
      mplot,DATA=d,LIMIT=l,/OVERPLOT
   ENDIF
ENDIF


END
