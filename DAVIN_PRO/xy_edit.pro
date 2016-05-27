;+
;PROCEDURE: xy_edit,x,y,bins
;PURPOSE: 
;   Interactively select data points
;-
pro xy_edit,x,y,bins,limits = lim,norm=distance,indexes=indexes,oplot=oplot

if not keyword_set(norm) then distance = 5
extract_tags,plotstuff,lim,/plot
psym = 1


if not keyword_set(oplot) then  plot,x,y,_extra = plotstuff,psym=psym
n = n_elements(x)
if n_elements(bins) ne n then bins = fix(x) * 0


c = get_colors()

on = c.green
off = c.red

res = convert_coord(x,y,/data,/to_device)
xn = reform(res(0,*))
yn = reform(res(1,*))

ind = where(bins,count)
if count ne 0 then oplot,x(ind),y(ind),psym=psym,color=on
ind = where(bins eq 0,count)
if count ne 0 then oplot,x(ind),y(ind),psym=psym,color=off


prompt = 'Select a point...'
repeat  begin
   cursor,xp,yp,/down,/device
   button = !err
   if button eq 4 then goto,quit
   
   dist = sqrt((xn-xp)^2 + (yn-yp)^2)
   ind = where(dist lt distance,count)
;stop
   if count ne 0 then begin
      if button eq 1 then begin 
         bins(ind) = 1
         col = on
      endif  else  begin
         bins(ind) = 0
         col = off
      endelse
      oplot,x(ind),y(ind),psym=psym,color=col
      for i=0,count-1 do $
         print,ind(i),x(ind(i)),y(ind(i)),button
   endif
endrep  until 0

quit:
indexes = where(bins)

end


