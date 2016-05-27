pro init_devices
  display = getenv('DISPLAY')

  if display eq '' then begin
     set_plot,'z'
     print,'Warning: No display!; Using Z buffer.'
  endif

  old_dev = !d.name   ;  save current device name
  set_plot,'PS'       ;  change to PS so we can edit the font mapping
  loadct2,34
  device,/symbol,font_index=19  ;set font !19 to Symbol
  set_plot,old_dev    ;  revert to old device
  
  if !d.name eq 'X' then begin
    device,pseudo_color=8  ;fixes color table problem for machines with 24-bit color
    device,decompose = 0
  endif

;  !p.font = -1  
  loadct2,34


  !prompt = getenv('HOST')+'> '   ;  change prompt

end