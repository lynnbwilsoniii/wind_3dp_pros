pro pl_plot ,dat3d, limits=lim, plot_type=plot_type

str_element,lim,'units',value=units
if keyword_set(units) then pl = conv_units(dat3d,units) else pl=dat3d

title = trange_str(pl.time,pl.end_time) +'  ('+pl.units_name+')'
deflim = {ytitle:'',xtitle:'Vx',title:title,aspect:1,units:'df'}

np = floor(sqrt(pl.nbins))
nrg = reform(pl.energy,14,np,np)
dat = reform(pl.data,14,np,np)
phi = reform(pl.phi,14,np,np)
th  = reform(pl.theta,14,np,np)

if n_elements(plot_type) eq 0 then plot_type = 1
str_element,lim,'plot_type',value=plot_type

case plot_type of
  1: begin & dim=3 & deflim.ytitle='Vy' & end
  2: begin & dim=2 & deflim.ytitle='Vz' & end
endcase
  
e = average(nrg,dim)
d = average(dat,dim)
p = average(phi,dim)
t = average(th,dim)

v = velocity(e,pl.mass)

sphere_to_cart,v,t,p,vx,vy,vz

if plot_type eq 2 then vy=vz

l = dgen(21,ran=[.1,1000],/log)


xlim,deflim,minmax_range(vx)+[-50,50],log=0
ylim,deflim,minmax_range(vy)+[-50,50],log=0

extract_tags,deflim,lim

box,deflim

zlog = 1
if keyword_set(zlog) then begin
  m = minmax_range(d,/pos)
  d = alog10(d > m(0)/3.)
  l = alog10(l)
endif

str_element,lim,'levels',l

contour,d,vx,vy,lev=l,/over,/fill
contour,d,vx,vy,lev=l,/over
oplot,vx,vy,/psym

end
