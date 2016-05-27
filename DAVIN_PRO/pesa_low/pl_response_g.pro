
pl_response_g(dat,param = par)

if not keyword_set(par) then begin
  resp = {area:1.,gtg:float([1.,1.,1.,0.,0.,0.]),vc:fltarr(3)}
  spec = {n:10.d,v:[400.d,0.d,0.d],vth:50.d,q:1,m:1}
  par =    {resp:resp,p:spec, a:spec }         ;, deadtime:1e-6 }
  par.a.m = 4
  par.a.q = 2
  par.a.n = par.p.n/25
endif
e_s= dat.e_s
volts = dat.volts
p_s = dat.p_s
t_s = dat.t_s
n_e = 14
n_p = 5
n_t = 5

rad = !dpi/180.d
ttt = dblarr(3,3)
ttt([1,4,7]) = par.p.vth

vsw = par.p.v

resp_center = par.resp.vc
ind = [[0,3,4],[4,1,5],[4,5,2]]
resp_mat  = par.resp.gtg(ind)

t=2
p=2
e=0
i=0

for t=0,n_t-1 do begin
for p=0,n_p-1 do begin
for e=0,n_e-1 do begin
for i=0,4-1   do begin

phi = 225. - (p_s + p + e/16. + i/64.)*5.625
th = -45. + (t_s + t + .5) * 5.625
vlts = dat.volts(i,e)


ct = cos(th  * rad)
st = sin(th  * rad)
cp = cos(phi * rad)
sp = sin(phi * rad)
rot1 = [[cp,sp,0.d], [-sp,cp,0.d], [0.d,0.d,1.d]]
rot2 = [[ct,0.d,st], [0.d,1.d,0.d],[-st,0.d,0.d]]
rot = rot2 ## rot1
irot = invert(rot)
v_sample = rot ## resp_center
gtg = irot ## resp_mat ## rot
help,v_sample,gtt,ttt
intgral = int_gaussian3d(gtg,ttt,v_sample-vsw)
r(e,p,t) 

endfor
endfor
endfor


return,resp
end




