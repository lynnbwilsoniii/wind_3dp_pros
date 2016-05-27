pro load_eq_pp_ici,time_range=trange,data=d

setenv,'EQ_PP_ICI_FILES=/home/phan/eqs/cdf/esic/eq_pp_ici*'

masterfile = 'EQ_PP_ICI_FILES'

loadallcdf,time_range=trange,masterfile=masterfile,data=d

store_data,'eq_pp_ici',data=d

end
