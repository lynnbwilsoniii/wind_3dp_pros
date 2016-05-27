pro mk_elpd_sumplot,name=name

if not keyword_set(no_reduce) then begin
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

load_if_needed,'wi_swe_Np'

xyz_to_polar,'VSW',/PH_0_360
xyz_to_polar,'elf.MAGF',/PH_0_360
xyz_to_polar,'elm.VELOCITY',/PH_0_360
xyz_to_polar,'elf.VSW',/PH_0_360

dif_data,'elf.VSW','elm.VELOCITY',newn = 'Vc-Vt'
dif_data,'elm.VELOCITY','VSW',newn = 'Vt-Vp'


store_data,'Vsw',data='wi_swe_Vp_mag VSW_mag Vp_mag elm.VELOCITY_mag'
store_data,'V_th',data='wi_swe_Vp_th VSW_th Vp_th elm.VELOCITY_th'
store_data,'V_phi',data='wi_swe_Vp_phi VSW_phi Vp_phi elm.VELOCITY_phi'
store_data,'B_mag',data='elf.MAGF_mag wi_B3_mag'
store_data,'B_th',data='elf.MAGF_th wi_B3_th'
store_data,'B_phi',data='elf.MAGF_phi wi_B3_phi'
store_data,'Nsw',data='wi_swe_Np elf.CORE.N NSW Np elm.DENSITY'
store_data,'sc_pot',data='elm.ERANGE sc_pot_el sc_pot_nsw elm.SC_POT elf.SC_POT'
store_data,'T',data='wi_swe_Tp Tp TSW elm.MAGT3 elf.CORE.T'
options,'wi_swe*',colors='y'
options,'VSW_* NSW Np Vp_* Tp TSW',colors='b'
options,'elm.VELOCITY_*',colors='r'
options,'sc_pot_nsw',colors='b'
options,'sc_pot_el',colors='r'
options,'elm.DENSITY',ytitle='Ne',colors='r'
options,'elm.VELOCITY',ytitle='Ve'
options,'elm.MAGT3',ytitle='T3'
options,'elm.TRAT',ytitle='Trat',colors='r'
options,'elm.SKEWNESS',ytitle='Qnorm',colors='r'
options,'elm.QVEC',ytitle='Qe'
options,'elm.EXCESS',ytitle='Re',colors='r'
options,'B_mag',ytitle='|B|'
options,'elm.ERANGE',linestyle=1,colors='bg'

ylim,'sc_pot',.8,50,1,/default
ylim,'Vsw',300,700,/default
ylim,'V_th',-20,20,/default
ylim,'V_phi',160,200,/default
ylim,'Nsw',.5,50,1,/default
ylim,'T',.5,50,1,/default
ylim,'B_mag',0,30,/default
ylim,'B_th',-90,90,/default
ylim,'B_phi',0,360,/default
ylim,'elm.VELOCITY',-800,200,/default
ylim,'elm.MAGT3',3,40,1,/default
ylim,'elm.EXCESS',0,4,0,/default
ylim,'elm.SC_POT',-5,30,/default
ylim,'elm.QVEC',-1.0e5,1.0e5,/default
ylim,'elm.SKEWNESS',-1,1,/default
ylim,'elm.TRAT',.7,4,1,/default

vars='Nsw Vsw V_th V_phi T elm.TRAT elm.QVEC elm.EXCESS elpd-1-4:4 elpd-1-4:4_norm B_mag B_th B_phi sc_pot fitres_chi2 fitres_vflags'


  tplot,vars
  
  get_timespan,t
  t0 = average(t)
  lab = time_string(/date,format=2,t0)
  if not keyword_set(name) then name=strcompress('sum_'+lab,/remove)
;  wset,0
  makegif,name,/no_expose


end