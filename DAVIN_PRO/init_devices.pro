pro init_devices
  ;display = getenv('DISPLAY')

  ;if display eq '' then begin
  ;   set_plot,'z'
  ;   print,'Warning: No display!; Using Z buffer.'
  ;endif

  old_dev = !d.name   ;  save current device name
  set_plot,'PS'       ;  change to PS so we can edit the font mapping
  loadct2,34
  device,/symbol,font_index=19  ;set font !19 to Symbol
  set_plot,old_dev    ;  revert to old device



  if !d.name eq 'WIN' then begin
    device,decompose = 0
  endif


  if !d.name eq 'X' then begin
    ; device,pseudo_color=8  ;fixes color table problem for machines with 24-bit color
    device,decompose = 0
    if !version.os_name eq 'linux' then device,retain=2  ; Linux does not provide backing store by default
  endif

;  !p.font = -1
  loadct2,34

  ; black on white
  !p.background = !d.table_size-1
  !p.color=0

  if !version.os_family eq 'Windows' then idl_prompt='SWODNIW'

  if !version.os_family eq  'unix' then idl_prompt= getenv('USER')+'@'+getenv('HOST')

  setenv,'IDL_PROMPT='+idl_prompt
  !prompt=idl_prompt+' >'

  cwd  ; Display current working directory

end
