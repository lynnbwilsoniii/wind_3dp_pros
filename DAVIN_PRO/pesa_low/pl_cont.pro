pro pl_cont, dat3d, limit=lim


str_element,lim,'units',value=units
units = 'df'
if keyword_set(units) then pl = conv_units(dat3d,units) else pl=dat3d

title = trange_str(pl.time,pl.end_time) +' ('+pl.units_name+')'
deflim = {ytitle:'',xtitle:'Vx',title:title}


;np = floor(sqrt(pl.nbins))
nb = n_elements(pl.energy)
nrg = reform(pl.energy,nb);   ,14,np,np)
d   = reform(pl.data,nb);   ,14,np,np)
phi = reform(pl.phi,nb);   ,14,np,np)
th  = reform(pl.theta,nb);   ,14,np,np)

v = velocity(nrg,pl.mass)

sphere_to_cart,v,th,phi,vx,vy,vz

vsw = pl.vsw 

vx = vx-vsw(0)
vy = vy-vsw(1)
vz = vz-vsw(2)
vel = [[vx],[vy],[vz]]
v = sqrt(total(vel^2,2))

ang = angl(vel,pl.magf,/rad)

vx = v*cos(ang)
vy = v*sin(ang)

l = dgen(21,ran=d,/log)


xlim,deflim,minmax_range(vx)+[-50,50],log=0
ylim,deflim,minmax_range(vy)+[-50,50],log=0

extract_tags,deflim,lim

;box,deflim

dfpar = distfunc(vx,vy,df=d)
extract_tags,pl,dfpar


zlog = 1
if keyword_set(zlog) then begin
  m = minmax_range(d,/pos)
  d = alog10(d > m(0)/3.)
  l = alog10(l)
endif

;oplot,vx,vy,/psym

;triangulate,vx,vy,tri
;vxg =trigrid(vx,vy,vx,tri)
;vyg =trigrid(vx,vy,vy,tri)
;dg =trigrid(vx,vy,d,tri)

cpd=3
cont2d,pl,200.,cpd=cpd,lim=clim,redf=redf,vout=vout,ngr=100
plots,vx,vy,/psym,color=bytescale(d)


;contour,dg,vxg,vyg,lev=l,/over,/fill
;contour,dg,vxg,vyg,lev=l,/over

end
