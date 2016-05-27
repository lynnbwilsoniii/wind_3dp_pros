function circle,pos,param=p

if not keyword_set(p) then begin

p ={ cx:0.d, cy:0.d, r:1.d}
return,p
endif

x = pos[*,0]
y = pos[*,1]

d = sqrt( (x - p.cx)^2 + (y-p.cy)^2 ) - p.r

return,d

end


