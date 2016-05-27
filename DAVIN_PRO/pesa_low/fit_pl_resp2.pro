
function alphalim,x
return,[-15.,15.]
end

function xresp,x,y
return,x * plea_resp(x,y)
end

function x2resp,x,y
return,x^2 * plea_resp(x,y)
end

;delvar,par0
;common pl_response_com, e_s,p_s,volts,par0

f0={lp:0,total:0l,rot:0., yaw:0., lin:0., swpl:0., $
 mcpl:0.,  data:fltarr(16) }

read_asc,plea,'~davin/wind/misc/plea3c.srt',format=f0  ;,/verb
gunvoltage = 1000.
plea = reform(plea,25,17,/over)

data = replicate({f:0.,x:0.,y:0.,z:0.},25,17)
data.f = plea.total
data.x= gunvoltage / plea.swpl
data.y = plea.yaw

dat = data.f * data.x
ddat = sqrt(data.f+2.) *data.x
d_x = (data.x - shift(data.x,-1,0)) > 0
d_y = (data.y - shift(data.y,0,1)) > 0

norm = total(dat * d_x * d_y)

dat = dat/norm
ddat = ddat/norm

mplot,transpose(data.x),transpose(dat)
mplot,data.x,dat


l = findgen(11)*.03
;contour,dat,data.y,data.x ,levels=l
lim=0
xlim,lim,4.5,8,0
ylim,lim,-10,10
box,lim

contour,dat,data.x,data.y,levels=l,/fol,/over,/fill
;contour,dat,data.x,data.y,levels=l,/fol,/over,c_cha=1.
oplot,data.x,data.y,/ps


par = 0
f = gaussian_3d(par=par)
par.pk = [6.2,-.8,0]
par.width = [.05*6.2, 2,  2., .70,0,0]
par.area = 1.

names = 'pk(0,1) width(0,1,3) area'
f = fitfunc(data,dat,func='gaussian_3d',par=par,p_names=names)
ea_resp = par
printdat,par
map =[[0,3,4],[3,1,5],[4,5,2]]
print,par.width(map)

x = dgen(100,/x) # replicate(1.,100)
y = replicate(1.,100) # dgen(100,/y)
z = fltarr(100,100)
f = gaussian_3d(x,y,z,par=par)
contour,f,x,y,levels=l,/fol,/over,c_cha=1

if 0 then begin
  pos = data
  pos.x = sqrt(data.x) * cos(data.y / !radeg)
  pos.y = sqrt(data.x) * sin(data.y / !radeg)
  log=0

  contour,dat,pos.x,pos.y,levels=l,/fol,c_cha=1.,/fill
  contour,dat,pos.x,pos.y,levels=l,/fol,c_cha=1.,/over
  oplot,pos.x,pos.y,/psym
  x = dgen(100,/x) # replicate(1.,100)
  y = replicate(1.,100) # dgen(100,/y)

  dfpar = min_curv(pos.x,pos.y,data=dat,log=log)
  f = min_curv(x,y,par=dfpar)
  contour,f,x,y,levels=l,/fol,c_cha=1.,/fill
  contour,f,x,y,levels=l,/fol,c_cha=1.,/over
  getxy,x1,y1
  f1 = min_curv(x1,y1,par=dfpar)
  dfpar1 = min_curv(x1,y1,data=f1,log=log)
  
  help,dfpar1,/st
  fit=fitfunc(pos,dat,par=dfpar1,p_names='dfc',funct='min_curv')
  
  f1 = min_curv(x,y,par=dfpar1)
  contour,f1,x,y,levels=l,/fol,c_cha=1.,/fill
  contour,f1,x,y,levels=l,/fol,c_cha=1.,/over
  oplot,x1,y1,/ps
  oplot,pos.x,pos.y,psym=3
  
  ;error
  contour,dat-fit,pos.x,pos.y,levels=l/10,/fol,c_cha=1.,/fill
  contour,f-f1,x,y,levels=l/10,/fol,c_cha=1.,/fill
  
endif


;oplot,x,y,ps=3
;contour,f,data.ev,data.alpha,levels=l,/fol,/over,c_cha=1.


;intgral = int_2d('plea_resp',[3.,9.],'alphalim',96)
;intgralx = int_2d('xresp',[3.,9.],'alphalim',96)
;print,intgral,intgralx/intgral
;ea_resp.h = 1.
;;ea_resp.h = ea_resp.h / intgral^2 * intgralx
;f = plea_resp(data,par=ea_resp)
;intgral = int_2d('plea_resp',[3.,9.],'alphalim',96)
;intgralx = int_2d('xresp',[3.,9.],'alphalim',96)
;intgralx2 = int_2d('x2resp',[3.,9.],'alphalim',96)
;print,intgral,intgralx/intgral,sqrt(intgralx2/intgral-(intgralx/intgral)^2)
;print,ea_resp.h

end

