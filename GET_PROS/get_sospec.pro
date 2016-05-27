pro get_sospec,lowgf=lowgf,pad=pad,units=units

sobins =replicate(1b,48)
sobins[ [7,8,9,31,32,33] ] = 0    ; Sun anti-sun
sobins[ [20,21,22,23,44,45,46,47] ] = 0    ; low gf

if not keyword_set(units) then units='flux'

if keyword_set(lowgf) then begin
  sobins[*]=0
  sobins[ [20,21,22,23,44,45,46,47] ] =1
endif

if keyword_set(pad) then begin
  get_padspec,unit=units,'so',bso='wi_B3',bins=sobins,num_pa=8
  reduce_pads,'so_pads_34',1,0,0,e_un=1
  reduce_pads,'so_pads_34',1,1,1,e_un=1
  reduce_pads,'so_pads_34',1,2,2,e_un=1 
  reduce_pads,'so_pads_34',2,0,7 
  return
endif

get_spec,units=units,'so',bins=sobins



end
