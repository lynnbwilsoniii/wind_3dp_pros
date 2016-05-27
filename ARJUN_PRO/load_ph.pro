;Loads ph.data from file write_ph.doc
;For use with sun noise subtraction.
;Use write_ph.pro to write file


pro load_ph,new,filename = filename

if not keyword_set(filename) then filename = 'write_ph1.txt'

environvar = 'PH_DIR_WRITE='
dir = getenv(environvar)

cd, dir,current=thisdir

print,'loading '+filename
openr,getlfn,filename,/get_lun

;print, 'getLfn = ',getlfn

;nenergy = fix(0)
;nbins = fix(0)

readf,getlfn,nenergy
;print, nenergy


readf,getlfn,nbins
;print, nbins

new = fltarr(nenergy,nbins)

readf,getlfn,new

close,getlfn
free_lun,getlfn

cd, thisdir

;print, getlfn,' getlfn'

end
