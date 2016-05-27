pro add_ddata,dat

if strlowcase(dat.units_name) eq 'counts' then begin
   add_str_element,dat,'ddata',sqrt(dat.data) > .7
endif else print,"Units must be in Counts"

return
end
