pro load_elft2,trange = trange,alldat


d = alldat

if data_type(prefix) eq 7 then pdname=prefix else pdname = 'elpd'

flux = dimen_shift(d.flux,1)
energies = dimen_shift(d.energy,1)
angles = average(d.pangle,1,/nan)
angles = dimen_shift(angles,1)

store_data,pdname,data={x:d.time,y:flux, $
  v1:energies,v2:angles}$
  ,min=-1e30,dlim={ylog:1}


ang_size = size(angles)
e_size = size(energies)

n_ang = ang_size(ang_size(0))
n_nrg = e_size(e_size(0))


if not keyword_set(no_reduce) then begin
for i = 0, n_nrg-1 do  reduce_pads,pdname,1,i,i


reduce_pads,pdname,2,7,7
reduce_pads,pdname,2,3,4
reduce_pads,pdname,2,0,0
reduce_pads,pdname,2,0,7
; ylim,iton(pdname+'-2-'),10,1e8,1
endif

;help,alldat,/st

fit = d.fit
f3 = replicate(1.,3)

str_element,/add,fit,'time',d.time
;str_element,/add,fit,'chi2',d.chi
mass=5.6856591e-06
halo_t = .5*mass*fit.halo.vth^2
str_element,/add,fit,'halo.t',halo_t
t2 =[[fit.core.t],[fit.core.t/(1+fit.core.tdif)]]
nt = fit.core.n + fit.halo.n

bhat = d.magf/(replicate(1.,3) # total(d.magf^2,1))
vcore = fit.vsw + bhat*(f3 # fit.core.v)
vhalo = fit.vsw + bhat*(f3 # fit.halo.v)

store_data,'elf.VCORE',data={x:d.time,y:transpose(vcore)}
xyz_to_polar,'elf.VCORE',/ph_0_360



vtot = ((f3 # fit.core.n)*vcore + (f3 # fit.halo.n)*vhalo)/(f3 # nt)

;help ,vtot,fit,fit.vsw
;str_element,/add,fit,'vtot',vtot
store_data,'elf.VTOT',data={x:d.time,y:transpose(vtot)}
xyz_to_polar,'elf.VTOT',/ph_0_360

dvcore = vcore - d.vsw

dvc_par = total(dvcore * bhat,1)
dvc_perp = dvcore - bhat * (replicate(1.,3) # dvc_par)
dvc_perp = sqrt(total(dvc_perp^2,1))

str_element,/add,fit,'dvc_par',dvc_par
str_element,/add,fit,'dvc_perp',dvc_perp

pr_core = fit.core.t * fit.core.n
pr_halo = fit.halo.t * fit.halo.n
Te_avg = (pr_core + pr_halo) / nt
str_element,/add,fit,'core.P',pr_core
str_element,/add,fit,'halo.P',pr_halo
str_element,/add,fit,'Ptot',pr_halo+pr_core
str_element,/add,fit,'tavg',te_avg
str_element,/add,fit,'ntot',nt


store_data,'elf',data=fit

store_data,'elf_core_t2',data={x:d.time,y:t2},dlim={ytitle:'Tperp Tpar'}
ylim,'elf_core_t2',.3,50,1

;store_data,'elf_n_tot',data={x:d.time,y:nt}
;ylim,'elf_n_tot',1,100,1

store_data,'elm',data=d.mt
store_data,'elmh',data=d.mh


ylim,'elf.CORE.N',.1,200,1
options,'elf.CORE.N','ytitle','N!dC!n (cc!u-1!n)

ylim,'elf.CORE.T',.3,50,1
options,'elf.CORE.T','ytitle','T!dC!n (eV)

store_data,'elf.CHI',data={x:d.time,y:transpose(d.chi),v:indgen(15)}
options,'elf.CHI','spec',1
options,'elf.CHI','no_interp',1
zlim,'elf.CHI',1,20,1








end