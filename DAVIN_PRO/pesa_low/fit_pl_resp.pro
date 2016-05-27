
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

data = replicate({counts:0.,ev:0.,alpha:0.},25,17)
data.counts = plea.total
data.ev = gunvoltage / plea.swpl
data.alpha = plea.yaw

dat = data.counts * data.ev
d_ev = (data.ev - shift(data.ev,-1,0)) > 0
d_a = (data.alpha - shift(data.alpha,0,1)) > 0
sdat = total(dat * d_ev * d_a)

dat = dat/sdat
ddat = sqrt(data.counts+2.)/sdat

mplot,transpose(data.alpha),transpose(dat)
mplot,data.ev,dat


l = findgen(11)*.03
;contour,dat,data.alpha,data.ev ,levels=l
lim=0
xlim,lim,4.5,8,0
ylim,lim,-10,10
box,lim

contour,dat,data.ev,data.alpha,levels=l,/fol,/over,/fill
;contour,dat,data.ev,data.alpha,levels=l,/fol,/over,c_cha=1.
oplot,data.ev,data.alpha,/ps


;par0 = 0
ea_resp =0
f = fitfunc(data,dat,func='plea_resp',par=ea_resp)
;help,par0,/st

x = dgen(100,/x) # replicate(1.,100)
y = replicate(1.,100) # dgen(100,/y)
contour,plea_resp(x,y,par=ea_resp),x,y,levels=l,/fol,/over,c_cha=1
;contour,f,data.ev,data.alpha,levels=l,/fol,/over,c_cha=1.


intgral = int_2d('plea_resp',[3.,9.],'alphalim',96)
intgralx = int_2d('xresp',[3.,9.],'alphalim',96)
print,intgral,intgralx/intgral
ea_resp.h = 1.
;ea_resp.h = ea_resp.h / intgral^2 * intgralx
f = plea_resp(data,par=ea_resp)
intgral = int_2d('plea_resp',[3.,9.],'alphalim',96)
intgralx = int_2d('xresp',[3.,9.],'alphalim',96)
intgralx2 = int_2d('x2resp',[3.,9.],'alphalim',96)
print,intgral,intgralx/intgral,sqrt(intgralx2/intgral-(intgralx/intgral)^2)
print,ea_resp.h

end

