pro load_eq_pp_aux,time_range=trange,data=d

setenv,'EQ_PP_AUX_FILES=/home/phan/eqs/cdf/esic/eq_pp_aux*'

masterfile = 'EQ_PP_AUX_FILES'

loadallcdf,time_range=trange,masterfile=masterfile,data=d

store_data,'eq_pp_aux',data=d

end
