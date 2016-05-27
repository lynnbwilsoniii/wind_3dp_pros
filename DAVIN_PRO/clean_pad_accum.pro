
function clean_pad_accum,pd

npd = conv_units(pd)

ind = where(finite(npd.data))

angles = npd.angles(ind)
energy = npd.energy(ind)
data   = npd.data(ind)

mass = pd.mass
vmag = sqrt(2.*energy/mass)
newphi = 0.
sphere_to_cart,vmag,angles,newphi,vperp_dat,dummy,vpar_dat,/co_lat

add_str_element,dat,'df_dat',df_dat
add_str_element,dat,'vperp_dat',vperp_dat
add_str_element,dat,'vpar_dat',vpar_dat
add_str_element,dat,'phi_dat',phi

vperp_dat = [vperp_dat,-vperp_dat]
vpar_dat = [vpar_dat,vpar_dat]
df_dat   = [df_dat,df_dat]

triangulate, vpar_dat, vperp_dat, tr

vlim = sqrt(2*100000./mass)
if not keyword_set(ngrid) then ngrid = 100
gs=[vlim,vlim]/ngrid
xylim=[-1*vlim,-1*vlim,vlim,vlim]

df2d  = trigrid(vpar_dat, vperp_dat, df_dat, tr, gs, xylim)
vpar2d  = -1.*vlim+gs(0)*findgen(fix((2.*vlim)/gs(0))+1)
vperp2d = -1.*vlim+gs(1)*findgen(fix((2.*vlim)/gs(1))+1)
add_str_element,dat,'df2d',df2d
add_str_element,dat,'vpar2d',vpar2d
add_str_element,dat,'vperp2d',vperp2d

return,pd

end

