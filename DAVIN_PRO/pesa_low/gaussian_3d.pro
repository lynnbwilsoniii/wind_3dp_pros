
forward_function gaussian_3d

function gaussian_3d,vx,vy,vz,parameters=par

if n_params() eq 1 then return,gaussian_3d(vx.x,vx.y,vx.z,param=par)

if data_type(par) ne 8 then  $
    par={area:1.d,width:double([1,1,1,0,0,0]),pk:dblarr(3)}
if n_params() eq 0 then return,0

d = dimen(vx)
nd = ndimen(vx)

dv = [[vx(*)-par.pk(0)],[vy(*)-par.pk(1)],[vz(*)-par.pk(2)]] 

map = [[0,3,4],[3,1,5],[4,5,2]]

t  = par.width[map]
ttt = t # transpose(t)

ittt = invert(ttt)

z = dv # ittt
z1 = total(z * dv,2)

;help,dv,ttt,z,z1

f = par.area * sqrt( determ(ttt) / !dpi^3) * exp(-z1)
if nd eq 0 then f=f(0) else f = reform(f,d)

return,f

end


