pro get_sfspec,lowgf=lowgf,units=units

sfbins =replicate(1b,48)
sfbins[ [7,8,9,15,31,32,33] ] = 0    ; Sun anti-sun
sfbins[ [20,21,22,23,44,45,46,47] ] = 0    ; low gf

if keyword_set(lowgf) then begin
  sfbins[*]=0
  sfbins[ [20,21,22,23,44,45,46,47] ] =1
endif

if not keyword_set(units) then units='flux'

get_spec,units=units,'sf',bins=sfbins



end
