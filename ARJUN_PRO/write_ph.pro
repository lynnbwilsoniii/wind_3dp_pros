;Writes a ph.data structure to a file for use in background subtraction.
;Use load_ph to load data
;reads from write_ph.doc

pro write_ph,ph,filename = filename

if not keyword_set(filename) then filename = 'write_ph1.txt'

openw,getlfn,filename,/get_lun

ph1 = conv_units(ph,'eflux')

printf,getlfn,ph1.nenergy
printf,getlfn,ph1.nbins

printf,getlfn,ph1.data

close, getlfn
free_lun,getlfn

end
