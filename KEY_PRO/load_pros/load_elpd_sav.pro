function load_elpd_sav,files=files,format=format,verbose=verbose

if not keyword_set(format) then $
  format ='/home/davin/dat/wi/3dp/elpd/????/wi*v06.sav'
if not keyword_set(files) then $
  files = cdf_file_names(format,verbose=verbose)

nf = n_elements(files)
for i=0,nf-1 do begin
  restore,file=files[i],verbose=verbose
  print,i,nf
  append_array,d0,d,index=ind
endfor

append_array,d0,/done,index=ind
return,d0

end
