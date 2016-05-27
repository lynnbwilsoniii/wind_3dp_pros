;+
;PROCEDURE:	load_wi_3dp_sfsp
;PURPOSE:	
;   loads WIND 3D Plasma Experiment key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  TIME_RANGE:  2 element vector specifying the time range
;RESTRICTIONS:
;  This routine expects to find the master file: 'wi_ehsp_3dp_files'
;  In the directory specified by the environment variable: 'CDF_INDEX_DIR'
;  See "make_cdf_index" for more info.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  %M%
;LAST MODIFICATION: %E%
;-
pro load_wi_3dp_sfsp $
   ,trange=trange $
   ,bartel=bartel $
   ,prefix = prefix 
   

format = 'wi_3dp_sfsp_files'
if keyword_set(bartel) then format='wi_3dp_sfsp_B_files'

varnames = ['sfsp_hg','sfsp_lg','val_sfsp_hg','val_sfsp_lg' ]

verbose = 1
cdf2tplot,format=format,/verb,trange=trange
;filenames=cdf_file_names(format,trange=trange,verbose=verbose)
;dp = cdf_ptrs(filenames=filenames,varnames=varnames,verbose=verbose, $
;   resolution=resolution,trange=trange,depend_0=depend_0)
;d0 = array_union(dp.depend_0, dp.name)
;tp = ([ptr_new(),dp.dataptr])[d0+1]



ylim,'sfsp_?g',1e-8,10,1
ylim,'val_sfsp_?g',1e4,1e6,1

end
