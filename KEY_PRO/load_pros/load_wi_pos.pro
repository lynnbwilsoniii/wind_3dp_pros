pro load_wi_pos,format=format,trange=trange,data=d,polar=polar,bartel=bartel $
  ,nodata=nodat,resolution=res,hec=hec,var_lab=var_lab,gsm=gsm,lat=lat


if not keyword_set(format) then format= 'wi_or_cmb_files'
if keyword_set(bartel) then format = 'wi_or_cmb_B_files'

cdfnames = ['GSE_POS']

if keyword_set(var_lab) then begin
  tplot_options,var_lab=['wi_pos_mag','wi_pos_phi']
  polar = 1
endif


d=0
nodat=0
loadallcdf,format,cdfnames=cdfnames,data=d,time_range=trange,res=res
pos = dimen_shift(d.gse_pos/6370.,1)
lab = ['X','Y','Z']
store_data,'wi_pos',data={x:d.time,y:pos}, dlim={labels:lab,constant:0.}
if keyword_set(polar) then begin
   xyz_to_polar,'wi_pos',/ph_0_360
   options,'wi_pos_mag','ytitle','D (R!dE!n)',/default
   options,'wi_pos_th','ytitle','!4h!X!DSC!U',/default
   options,'wi_pos_phi','ytitle','!4u!X!DSC!U',/default
   options,'wi_pos_phi','format','(f4.0)',/default
endif
end
