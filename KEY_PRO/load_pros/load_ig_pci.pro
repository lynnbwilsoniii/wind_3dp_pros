;+
;PROCEDURE:	load_ig_pci
;PURPOSE:	
;   loads INTERBALL Ground key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;SEE ALSO: 
;  "make_cdf_index"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_epa.pro
;LAST MODIFICATION: 96/08/23
;
;-
pro load_ig_pci,time_range=time_range

masterfile = 'ig_k0_pci_files'
cdfnames = ['PC_Vostok','PC_Thule','Flag_Vostok','Flag_Thule']

loadallcdf,masterfile=masterfile,tplot='ig_pci',cdfnames=cdfnames,$
	time_range=time_range

end
