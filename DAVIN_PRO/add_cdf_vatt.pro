pro add_cdf_vatt,files,cdfatt

nf = n_elements(files)
nv = n_elements(cdfatt)
for i=0,nf-1 do begin
   id = cdf_open(files[i])
   for j=0,nv-1 do begin
      cdf_vatt_put,id,*cdfatt[j].name,*cdfatt[j].attr
   endfor
   cdf_close,id
endfor

end



