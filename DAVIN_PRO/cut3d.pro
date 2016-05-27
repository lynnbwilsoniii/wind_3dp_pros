pro cut3d,dat,theta,phi,direction=dir,limits=limits,overplot=overplot,fit=fit,$
  bin=bin,vel_shift=vel_shift,colors=colors,units=units,psym=psym,xvel=xvel

lim = {xtitle:'Velocity  Km/s',ytitle:'',title:'', $
   xrange:[-21000,21000.], xlog:0, xstyle:1, $
   yrange:[1e-17,2e-9], ylog:1, ystyle:1  }
   
if not keyword_set(xvel) then lim.xrange=[-200,200]
if not keyword_set(xvel) then lim.yrange=[1e-12,2e-9]
if not keyword_set(xvel) then lim.xtitle='Energy'

lim.title = time_string(dat.time)

extract_tags,lim,limits


;df = conv_units(dat,'df')
if keyword_set(vel_shift) then vel=dat.vsw else vel=[0.,0.,0.]
if debug() ne 0 then printdat,vel,'vel'
df = convert_vframe(dat,vel)
if keyword_set(units) then df=conv_units(df,units)
lim.ytitle = units_string(df.units_name)

if not keyword_set(overplot) then box,lim
overplot=1

if keyword_set(bin) then begin
  phi = dat.phi[7,bin]
  theta = dat.theta[7,bin]
endif

if keyword_set(phi) then begin
  sphere_to_cart,1,theta,phi,x,y,z
  dir = [x,y,z]
endif


if not keyword_set(dir) then dir = [1.,0.,0.]
rot = transpose(rot_mat(dir,[0.,0.,1.]))

;th = average(dat.theta,1)
;ph = average(dat.phi,1)
sphere_to_cart,1,dat.theta,dat.phi,x,y,z
x = average(x,1)
y = average(y,1)
z = average(z,1)
cart_to_sphere,x,y,z,r,th,ph

ndir = dir

dot = ndir[0]*x+ndir[1]*y+ndir[2]*z
s = sort(dot)

nc = 1
wf = (reverse(s))[0:nc-1]
wb = s[0:nc-1]

print,wf,th[wf],ph[wf]
print,wb,th[wb],ph[wb]

;if not keyword_set(colors) then colors = bytescale(findgen(nc),range=[0,nc-1])
;cls = replicate(1,15) # colors


;e = df.energy-df.sc_pot
;bad = where(df.energy lt df.sc_pot*1.4,c)
;if c ne 0 then e[bad] = !values.f_nan
;v = velocity(/el,e)

v = velocity(/el,df.energy)
if not keyword_set(xvel) then x=df.energy else x = v 
d = df.data
dd = df.ddata


;vs = [-v[*,wb],v[*,wf]]
;ds = [ d[*,wb],d[*,wf]]
;dds = [ dd[*,wb],dd[*,wf]]
;cls = [cls,cls]

;printdat,lim
plotxyerr,-x[*,wb], d[*,wb],x[*,wb]*.05,dd[*,wb],col=colors,/over,psym=psym,_extra=lim
plotxyerr, x[*,wf], d[*,wf],x[*,wf]*.05,dd[*,wf],col=colors,/over,psym=psym,_extra=lim
;plots,noclip=0,-v[*,wb], d[*,wb],psym=1,_extra=lim,col=cls
;plots,noclip=0,v[*,wf], d[*,wf],psym=1,_extra=lim,col=cls
;if debug() ne 0 then printdat,dd
;oplot_err,-v[*,wb],d[*,wb]- dd[*,wb],d[*,wb]- dd[*,wb] ;,col=cls
;oplot_err,v[*,wf],d[*,wf]- dd[*,wf],d[*,wf]- dd[*,wf] ;,col=cls

if keyword_set(fit) then begin
  n = 200
  vv = dgen(n)
  vvp = [[fltarr(n)],[fltarr(n)],[vv]]
  vvp = rot ## vvp
  vx = vvp[*,0]
  vy = vvp[*,1]
  vz = vvp[*,2]
  print,vx[n-1],vy[n-1],vz[n-1]
  mass = 5.6856591e-06
  vsw = fit.vsw
  magf =fit.magf
  bdir = magf/sqrt(total(magf^2))
  bx = bdir(0)
  by = bdir(1)
  bz = bdir(2)
  vcore = vsw + bdir * fit.core.v
  vsx = vx - vcore[0] 
  vsy = vy - vcore[1]
  vsz = vz - vcore[2]
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2/vtot2

  e = exp( -0.5*mass*vtot2 / fit.core.t * (1.d + cos2a*fit.core.tdif) )
  k = (mass/2/!dpi)^1.5 * 1e10

  fcore = (k * fit.core.n * sqrt((1+fit.core.tdif)/fit.core.t^3) ) * e
;  w = where(energy le (fit.sc_pot > 0.),c)
;  if c ne 0 then fcore[w]=0.
  f=  fcore/1e10
  
  vhalo = vsw + bdir *fit.halo.v
  vsx = vx - vhalo(0)
  vsy = vy - vhalo(1)
  vsz = vz - vhalo(2)
  vtot2 = vsx*vsx + vsy*vsy + vsz*vsz
  cos2a = (vsx*bx + vsy*by + vsz*bz)^2/vtot2
  vh2 = (fit.halo.k-1.5)*fit.halo.vth^2
  kc = (!dpi*vh2)^(-1.5) *  gamma(fit.halo.k+1)/gamma(fit.halo.k-.5) *1e10
  fhalo = fit.halo.n*kc*(1+(vtot2/vh2))^(-fit.halo.k-1) 
  f2 =  fhalo/1e10


  
  lim2 = lim
  options,lim2,'psym',0
  oplot,vv,f,_extra=lim2
  oplot,vv,f2,_extra=lim2
  oplot,vv,f+f2,_extra=lim2

endif
end
