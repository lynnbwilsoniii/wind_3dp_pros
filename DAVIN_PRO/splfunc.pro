;+
;FUNCTION splfunc
;USAGE:
;  param = splfunc(x_old,y_old)
;  y = splfunc(x_new,param=p)
;-

function splfunc, xs,ys, param=p,xlog=xlog,ylog=ylog,lininterp=lininterp

xl = keyword_set(xlog)
yl = keyword_set(ylog)
li = keyword_set(lininterp)


if not keyword_set(p) then begin
   xps = float(xl ? alog10(xs) : xs)
   yps = double(yl ? alog10(ys) : ys)
   s = sort(xps)
   xps=xps[s]
   yps=yps[s]
   interp_gap,xps,yps
   p = {func:'splfunc', x: xps,  y: yps, xlog:xl, ylog:yl, li:li}
   return,p
endif

if p.li then f= interp(p.y,p.x,p.xlog ? alog10(xs) : xs)   else begin
   ys2 = spl_init(p.x,p.y)
   f = spl_interp(p.x,p.y,ys2,p.xlog ? alog10(xs) : xs)
endelse


return, p.ylog ? 10.^f : f
end


