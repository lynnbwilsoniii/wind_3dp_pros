;+
;PROCEDURE:	load_so_ern
;PURPOSE:	
;   loads SOHO ERN key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_so_ern.pro
;LAST MODIFICATION: 99/05/27
;
;-

pro load_so_ern,time_range=trange

masterfile = 'so_k0_ern_files'
cdfnames = ['Electron','Proton','He4','Ratio_H','Ratio_He']

loadallcdf,time_range=trange,masterfile=masterfile,cdfnames=cdfnames,/tplot

end
