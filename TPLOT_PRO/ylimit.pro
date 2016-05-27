;+
;PROCEDURE: ylimit
;PURPOSE:  Interactive setting of y-limits for the "TPLOT" procedure.
;
;SEE ALSO:	"YLIM", a noninteractive version which calls this routine.
;
;NOTES:  This procedure will probably be made obsolete by embedding it in.
;    "YLIM".
;        Run "TPLOT" prior to using this procedure.
;
;CREATED BY:	Davin Larson
;FILE: ylimit.pro
;VERSION:  1.11
;LAST MODIFICATION: 98/08/06
;-
pro ylimit
@tplot_com
str_element,tplot_vars,'names',tplot_var
str_element,tplot_vars,'settings.y',tplot_y
np = dimen1(tplot_y)

if !d.name ne 'X' then begin
   print,'Must use X windows for this routine.'
   return
endif
current_window = !d.window
wset,tplot_vars.settings.window
wshow

print,'Select the lower limit with the cursor.'
cursor,x0,y0,/norm,/down
print,'Select the upper limit.
cursor,x1,y1,/norm,/down

y = [y0,y1]
x = [x0,x1]

;print,y,np

for i= 0,np-1 do begin
  w = tplot_y(i).window
;print,w
  if( (y0 lt w(0)) and (y1 gt w(1)) ) then begin
     print,'Setting limits of ',tplot_var(i),' to full scale...'
     ylim,tplot_var(i),0.,0.
  endif
  if( (y0 ge w(0)) and (y1 le w(1)) ) then begin
     if y0 eq y1 then begin
        prmpt = 'Enter lower, then upper limits for '+tplot_var(i)+': '
        read,t0,t1,prompt=prmpt
        read,ylog,prompt='linear (0) or log (1)? '
        data=[t0,t1]
        style = 1
     endif else begin
        data = normal_to_data(y,tplot_y(i))
        style = 0
     endelse
     print,'Setting limits of ',tplot_vars.settings.varnames(i),' from ',$
     	data(0),' to ',data(1)
     ylim,tplot_vars.settings.varnames(i),data(0),data(1),ylog,style=style
  endif
endfor

;tplot
wset,current_window
return
end

