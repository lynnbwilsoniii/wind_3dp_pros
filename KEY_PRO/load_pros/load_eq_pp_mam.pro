pro load_eq_pp_mam,time_range=trange,data=d

setenv,'EQ_PP_MAM_FILES=/home/phan/eqs/cdf/esic/eq_pp_mam*'

masterfile = 'EQ_PP_MAM_FILES'

loadallcdf,time_range=trange,masterfile=masterfile,data=d

store_data,'eq_pp_mam',data=d

end
