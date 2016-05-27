

function integrate_resp_ept,f,g,m,e,p,t
m = 4
dm = 17-1
p0 = p*m
t0 = t*m
e0 = e*m
fr = f(e0:e0+dm  , p0:p0+dm , t0:d0+dm)
rate = total(fr * g)
e0 = e0+m/4
fr = f(e0:e0+dm  , p0:p0+dm , t0:d0+dm)
rate = rate+total(fr * g)
e0 = e0+m/4
fr = f(e0:e0+dm  , p0:p0+dm , t0:d0+dm)
rate = rate+total(fr * g)
e0 = e0+m/4
fr = f(e0:e0+dm  , p0:p0+dm , t0:d0+dm)
rate = rate+total(fr * g)
return,rate
end


