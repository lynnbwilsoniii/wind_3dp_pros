;+
;PROCEDURE: scat_plot, xname, yname
;PURPOSE:
;   Produces a scatter plot of selected tplot variables.
;   Colors are scaled according to zname, if present
;INPUTS:
;   xname:    xvariable name
;   yname:    yvariable name
;   zname:    if present, color variable name
;KEYWORDS:
;       TRANGE:  two element vector giving start and end time.
;   limits:     a structure with plotting keywords
;   begin_time:   time at which to start plot
;   end_time: time at which to end plot
;
;CREATED BY:    Davin Larson
;LAST MODIFICATION: @(#)scat_plot.pro   1.13 02/04/17
;-

pro scat_plot,xname,yname, zname,$
   begin_time = t0,  $
   end_time  = t1,  $
   overplot = overplot, $
   trange=trn,  $
   limits = limits


get_data,xname,data=xdata
get_data,yname,data=ydata

if n_elements(xdata) eq 0 then message,'No data associated with: '+xname

prompt = 'Which dimension of '+xname+'? '
if dimen2(xdata.y) gt 1 then read, nx, prompt = prompt else nx = 0
prompt = 'Which dimension of '+yname+'? '
if dimen2(ydata.y) gt 1 then read, ny, prompt = prompt else ny = 0


x = xdata.y(*,nx)
time = xdata.x
y = interp(ydata.y(*,ny),ydata.x,time)

xtitle = xname
ytitle = yname


;get plotting stuff
extract_tags,plotstuff,limits,/plot
str_element, plotstuff, 'psym',  value = psym, index = index
if index lt 0 then psym = 0

three = n_params() eq 3
if three then begin
    get_data,zname,data=zdata
    prompt = 'Which dimension of '+zname+'? '
    if dimen2(zdata.y) gt 1 then read, nz, prompt = prompt else nz = 0

    z = interp(zdata.y(*,nz),zdata.x,time)
    str_element, limits, 'zrange', value = zrange, index = index
    if index lt 0 then zrange = minmax(z)
    str_element, limits, 'log_color', value = log_color, index = index
    if index lt 0 then log_color = 0
    colors = bytescale(z, range = zrange, bottom = 40, log = log_color, $
    missing = 0)
endif else begin
    colors = replicate(!p.color, dimen1(time))
endelse

if n_elements(trn) eq 2 then begin
   trnx = gettime(trn)
   t0 = trnx(0)
   t1 = trnx(1)
endif

; use reduced time range
if n_elements(t0) or n_elements(t1) then begin
   if n_elements(t0) eq 0 then t0 = double(0.)
   if n_elements(t1) eq 0 then t1 = double(1e20)
   i = where((time ge t0) and (time le t1))
   x = x(i)
   y = y(i)
   if three then z = z(i)
endif

; zap bad data
ind = where(x lt 1e20)
x = x(ind) & y = y(ind) & if three then z = z(ind)
ind = where(y lt 1e20)
x = x(ind) & y = y(ind) & if three then z = z(ind)
if three then begin
    ind = where(z lt 1e20)
    x = x(ind) & y = y(ind) &  z = z(ind)
end

;get some nice tplot stuff
@tplot_com
title = tplot_vars.options.title
if not keyword_set(t0) then t0 = time(0)
if not keyword_set(t1) then t1 = max(time)
title = title +'   '+ trange_str(t0,t1)


if not keyword_set(overplot) then plot,x,y,xtitle=xtitle, ytitle=ytitle, title = title, /nodata, _EXTRA = plotstuff
plots,x,y,color=colors, psym = psym, noclip = 0

return
end
