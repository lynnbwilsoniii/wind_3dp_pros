;+
;PROCEDURE:	load_so_cel
;PURPOSE:	
;   loads SOHO CEL key parameter data for "tplot".
;
;INPUTS:	none, but will call "timespan" if time
;		range is not already set.
;KEYWORDS:
;  TIME_RANGE:  2 element vector specifying the time range
;  MASTERFILE:  (string) full filename of master index file
;
;CREATED BY:	Davin Larson
;FILE:  load_so_cel.pro
;LAST MODIFICATION: 99/05/27
;
;-

pro load_so_cel,time_range=trange,masterfile=masterfile

if not keyword_set(masterfile) then masterfile = 'so_k0_cel_files'

cdfnames = ['LEMT1','LEMT2','APEB1','APEB2','APEB3','APEB4','APEB5', $
   'STEP1','STEP2','STEP3','STEP4','STEP5','STEP6']

loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange,/tplot

end
