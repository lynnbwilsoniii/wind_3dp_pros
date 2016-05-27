pro mk_elpd_sumplot2,name=name,reduce_pad=reduce_pad,plottype=plottype,no_swe=no_swe

if keyword_set(reduce_pad) then begin
 pdname ='elpd'
 nenergy = 15
 num_pa = 13
 for i = 0, nenergy-1 do  reduce_pads,pdname,1,i,i
 reduce_pads,pdname,2,num_pa-2,num_pa-1
 reduce_pads,pdname,2, round((num_pa-1)/2.-.9),round((num_pa-1)/2.+.9)
 reduce_pads,pdname,2,0,1
 ylim,tnames(pdname+'-2-*'),10,1e8,1,/def
 normpad
 elpd_lim
endif

if not keyword_set(no_swe) then load_if_needed,'wi_swe_Np'

xyz_to_polar,'VSW',/PH_0_360
xyz_to_polar,'MAGF',/PH_0_360
xyz_to_polar,'elm.VELOCITY',/PH_0_360
xyz_to_polar,'elf.VSW',/PH_0_360

ylim,'VSW_mag elm.VELOCITY_mag',200,1200,0

dif_data,'elf.VSW','elm.VELOCITY',newn = 'Vc-Vt'
dif_data,'elm.VELOCITY','VSW',newn = 'Vt-Vp'
options,'Vt-Vp Vc-Vt',constant=0.,yrange=[-200.,200.]


store_data,'Vsw',data='wi_swe_Vp_mag VSW_mag Vp_mag elm.VELOCITY_mag'
store_data,'V_th',data='wi_swe_Vp_th VSW_th Vp_th elm.VELOCITY_th'
store_data,'V_phi',data='wi_swe_Vp_phi VSW_phi Vp_phi elm.VELOCITY_phi'
store_data,'B_mag',data='MAGF_mag wi_B3_mag'
store_data,'B_th',data='MAGF_th wi_B3_th'
store_data,'B_phi',data='MAGF_phi wi_B3_phi'
store_data,'Nsw',data='wi_swe_Np elf.CORE.N NSW Np elm.DENSITY'
store_data,'sc_pot',data='elm.ERANGE sc_pot_el sc_pot_nsw elm.SC_POT elf.SC_POT'
store_data,'T',data='wi_swe_Tp Tp TSW elm.AVGTEMP elf.CORE.T'
store_data,'Trat',data='elf.CORE.TRAT elm.TRAT',dlim={constant:1.}
options,'Nsw Vsw T',panel_size=1.5
options,'wi_swe*',colors='y'
options,'VSW_* NSW Np Vp_* Tp TSW',colors='b'
options,'elm.VELOCITY_*',colors='r'
options,'sc_pot_nsw',colors='b'
options,'sc_pot_el',colors='r'
options,'B_mag',ytitle='|B|'
options,'VSW_mag',ytitle='Solar Wind Speed (km/s)'

ylim,'Trat',.5,4,1,/def
ylim,'sc_pot',2,50,1,/default
ylim,'Vsw',250,800,/default
ylim,'V_th',-20,20,/default
ylim,'V_phi',160,200,/default
ylim,'Nsw',.5,200,1,/default
ylim,'T',.5,50,1,/default
ylim,'B_mag',0,30,/default
ylim,'B_th',-90,90,/default
ylim,'B_phi',0,360,/default

if n_elements(plottype) eq 0 then plottype=0
case plottype of 
1:    vars='Nsw Vc-Vt Vt-Vp T Trat sc_pot fitres_nits fitres_chi2 fitres_vflags fitres_x2_erange'
else: vars='Nsw Vsw V_th V_phi T Trat elm.QVEC elm.SKEWNESS elm.EXCESS elpd-1-4:4 elpd-1-4:4_norm B_mag B_th B_phi'
endcase

  tplot,vars
  
  if keyword_set(name) then makegif,name,/no_expose
;  get_timespan,t
;  t0 = average(t)
;  lab = time_string(/date,format=2,t0)
;  if not keyword_set(name) then name=strcompress('sum_'+lab,/remove)
;  wset,0
;  makegif,name,/no_expose
;if plottype eq 1 then exit

end