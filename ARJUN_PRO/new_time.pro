pro new_time,variable,time,erase = erase

@tplot_com


current_window = !d.window
wset,tplot_vars.settings.window

get_data,variable,data = old_time,index = theindex

device, get_graphics = old,set_graphics = 6

color = !d.n_colors -1
tplot_x = tplot_vars.settings.x
time_offset=tplot_vars.settings.time_offset
time_scale = tplot_vars.settings.time_scale


if theindex ne 0 then begin
	px = old_time.x
	coords = data_to_normal((px-time_offset)/time_scale,tplot_x)
	px = coords(0)
	plots,[px,px],[0,1],color = color,/norm,thick = 1,lines = 0
end

if not keyword_set(erase) then begin
	px = time

	coords = data_to_normal((px-time_offset)/time_scale,tplot_x)
	plots,[coords(0),coords(0)],[0,1],color = color,/norm,thick = 1,lines = 0

	device,set_graphics = old
	store_data,variable,data = {x:px,y:px}
endif else begin
	device,set_graphics = old
	del_data,variable
endelse

wset,current_window

end
