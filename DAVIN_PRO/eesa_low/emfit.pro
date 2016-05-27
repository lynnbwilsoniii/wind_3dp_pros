function emfit,dat,parameter=format,names=names,fitdat=fitdat

if data_type(format) eq 8 then par=format else begin
   dummy = elfit4(par=par)
endelse

if not keyword_set(names) then names = 'sc_pot core halo.n:vth:v'


dt = dat.data(where(dat.bins))
ddt = sqrt((.03*dt)^2+ (dt+2.))
foo = fitfunc(dat,dt,dy=ddt,func='elfit4',nam=names,/nod, $
   par=par, silent=silent,chi2 = chisq,maxp=12)

fitdat = dat
dummy = elfit4(par=par,fitdat,/set)


return,par
end

