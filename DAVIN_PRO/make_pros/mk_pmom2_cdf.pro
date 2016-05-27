pro mk_pmom2_cdf,trange=trange,no_load=no_load,verbose=verbose

; assumes that L zero data and mag data (wi_B3) have been loaded!

magname = 'wi_B3'
if not keyword_set(no_load) then begin
  
  get_pmom2,magname=magname,protons=p,alphas=a,magf=magf,/polar
  
endif


if keyword_set(trange) then  $
  dates = time_string(trange[0],f=2,prec=-3)+'_v02' $
else dates='vXX'

filename = 'wi_pm_3dp_'+dates
vars = 'Np Vp Tp VTHp RVVp Tp_rat Na Ta Va RVVa VTHa Eff magf'
tplot_to_cdf,file=filename,vars,trange=trange,verbose=verbose
;print,'file ',filename,'.cdf created'

end
