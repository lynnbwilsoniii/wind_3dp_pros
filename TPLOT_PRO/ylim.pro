;+
;PROCEDURE:  ylim [, str [ , min, max, [ LOG=log ] ] ]
;PURPOSE:   
;  Sets y-axis limits for plotting routines.
;  Adds the tags 'yrange', 'ystyle' and 'ylog' to the structure str, or to the 
;  limit structure associated with the string str.
;INPUTS: 
;   str is a:
;      CASE 1: structure (or zero or non-existent)
;         Structure to be added to.  (Created if non-existent)
;      CASE 2: string  (handle associated with a "TPLOT" variable)
;         The limits structure associated with this string is used.  This 
;         structure can be retrieved with the "GET_DATA" procedure.
;   min:     min value of yrange
;   max:     max value of yrange
;KEYWORDS:
;   LOG:   (optional)  0: linear,   1: log
;   DEFAULT:   Sets default tplot limits.
;   STYLE:  value to set the IDL plot YSTYLE keyword
;Typical usage:
;   ylim,lim,-20,100   ; create (or add to) the structure lim
;
;   ylim,'Ne',.01,100,1  ; Change limits of the "TPLOT" variable 'Ne'.
;
;NO INPUTS:
;   ylim                 ; Set "TPLOT" limits using the cursor.
;
;SEE ALSO:  "OPTIONS", "TLIMIT", "XLIM", "ZLIM"
;CREATED BY:	Davin Larson
;VERSION: ylim.pro
;LAST MODIFICATION: 01/06/25
;-
pro ylim,str,min,max,log,log=lg, style=style, default=default
if n_params() eq 0 then begin
    ctime,t,y,vname=var,npoints=2
    while keyword_set(var) ne 0 do begin
      ylim,var(0),y(0),y(1)
      ctime,t,y,vname=var,npoints=2
    endwhile
;    ylimit
    return
end
if n_params() eq 1 then begin
   options,str,'yrange'
   options,str,'ystyle'
   options,str,'ylog'
   return
endif
if n_elements(lg) ne 0 then log=lg
if n_elements(min) eq 2 then max=0
if n_elements(max) eq 0 then range = [0.,0.] else range = float([min,max])
if n_elements(style) eq 0 then style = 1
options,str,'yrange',range(0:1),default=default
if range(0) eq range(1) then style=0
options,str,'ystyle',style,default=default
if n_elements(log) ne 0 then options,str,'ylog',log,default=default
return
end




