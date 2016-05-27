pro ls,filter,files=files
if not keyword_set(filter) then filter='*'
files=file_search(filter)
if keyword_set(files) then begin
   fs = file_info(files)
   symb= ['','/']
   print,transpose(files + symb[fs.directory])
endif else print,'No match.'
return
end

