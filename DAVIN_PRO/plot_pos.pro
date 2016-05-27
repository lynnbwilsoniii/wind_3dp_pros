function plot_pos, aspect, top=top, xmargin=xmargin,ymargin=ymargin,limits=lim

print,"Using obsolete routine: PLOT_POS!"

str_element,lim,'xmargin',value=xmargin
str_element,lim,'ymargin',value=ymargin

str_element,lim,'xrange',value=xrange
str_element,lim,'yrange',value=yrange

if not keyword_set(xmargin) then xmargin = !x.margin
if not keyword_set(ymargin) then ymargin = !y.margin

if not keyword_set(xrange) then xrange = !x.range
if not keyword_set(yrange) then yrange = !y.range

if not keyword_set(aspect) then begin
   dx = abs(xrange(1)-xrange(0))
   dy = abs(yrange(1)-yrange(0))
   if dx ne 0 and dy ne 0 then  aspect = dy/dx else aspect = 1.
endif


xm = !x.margin * !d.x_ch_size
ym = !y.margin * !d.y_ch_size

p_size = [!d.x_size,!d.y_size]
m0 = [xm(0),ym(0)]
m1 = [xm(1),ym(1)]

bs = p_size-(m0+m1)

s = [1.,aspect] * (bs(0) < bs(1)/aspect)

bsp = m0 + (bs-s)/2
if keyword_set(top) then bsp(1) = m0(1) - s(1) + bs(1)

return,[bsp,bsp+s] / [p_size,p_size]
end

