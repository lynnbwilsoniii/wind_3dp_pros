pro tprint,filename,printer=printer,times=times,ct=ct
if not keyword_set(filename) then filename='/tmp/idl'
popen,filename
if n_elements(ct) ne 0 then loadct2,ct else loadct2,34
tplot
if keyword_set(times) then timebar,times
pclose
;if n_elements(printer) eq 0 then printer='ctek0'
if keyword_set(printer) then $
   spawn,'lpr -P'+printer+' '+filename+".ps" $
else $
   spawn,'xv '+filename+'.ps &'
end
