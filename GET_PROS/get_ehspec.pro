pro get_ehspec,units=units,bins=bins,bkg=ehbkg

if not keyword_set(units) then units='flux'
if not keyword_set(ehbkg) then begin
 print,'select time for background
 ctime,t
 eh = get_eh(t)
 ehbkg =get_bkg3d(eh,esteps=[1,2])
endif
if not keyword_set(bins) then begin
  bins = bytarr(88)
  bins[22:65] = 1
endif
get_spec,units=units,'eh',bins=bins,bkg=ehbkg



end
