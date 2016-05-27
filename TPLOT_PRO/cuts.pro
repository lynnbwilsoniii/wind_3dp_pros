;+
;PROCEDURE:	cuts
;PURPOSE:	to show x cuts or y cuts of a 
;		"tplot" spectrogram
;INPUT:		none
;KEYWORDS:	name:	name of the variable you want cuts for
;
;CREATED BY:	Peter Schroeder
;LAST MODIFICATION:	@(#)cuts.pro	1.6 98/01/29
;
;-
pro cuts, name = name

on_error,2
@tplot_com
str_element,tplot_vars,'settings.x',tplot_x
str_element,tplot_vars,'settings.y',tplot_y
str_element,tplot_vars,'options.varnames',tplot_var
str_element,tplot_vars,'settings.time_scale',time_scale
str_element,tplot_vars,'settings.time_offset',time_offset

n = dimen1(tplot_y)

if not  keyword_set(name) then name = tplot_var(n-1)

plot = where(tplot_var eq name)

plot = plot(0)
plot_name = tplot_var(plot)

x = tplot_x.window
y = tplot_y(plot).window

low = convert_coord(x(0), y(0), /normal, /to_device)
high = convert_coord(x(1), y(1), /normal, /to_device)

image = tvrd(low(0), low(1), high(0) - low(0), high(1)-low(1))
sx = low(0)
sy = low(1)
s = size(image)

get_data,plot_name,alim=alim

wsize = 0.75
tickl = 0.1

print,'Left mouse button to toggle between rows and columns.'
print,'Right mouse button to Exit.'

orig_w = !d.window
nx = s[1]
ny = s[2]
tvcrs,(tplot_x.window(0)+tplot_x.window(1))/2,$
	(tplot_y(plot).window(0)+tplot_y(plot).window(1))/2,/norm
window,/free ,xs=wsize*640, ys=wsize*512,title='Profiles' ;Make new window
new_w = !d.window

old_mode = -1				;Mode = 0 for rows, 1 for cols
new_w = !d.window
old_font = !p.font			;Use hdw font
!p.font = 0
mode = 0
order = !order

minx = tplot_x.crange(0)
maxx = tplot_x.crange(1)
miny = tplot_y(plot).crange(0)
maxy = tplot_y(plot).crange(1)
minz = min(image)
maxz = max(image)

str_element,alim,'num_lab_min',value=num_lab_min
str_element,alim,'tickinterval',value=tickinterval
str_element,alim,'xtitle',value=xtitle
str_element,tplot_vars,'settings.trange_cur',trange_cur
if not keyword_set(num_lab_min) then num_lab_min= 2.
time_setup = time_ticks(trange_cur,time_offset,num_lab_min=num_lab_min, $
   side=vtitle,xtitle=xtitle,tickinterval=tickinterval)
time = time_setup.xtickv+time_offset
extract_tags,alim,time_setup
tshift=0.d
str_element,data,'tshift',tshift

plotstuff = {xstyle: 1, ystyle: 1, zstyle: 1}	
extract_tags,plotstuff,alim,/plot
str_element,plotstuff,'zlog',0,/add
str_element,plotstuff,'zrange',[minz,maxz],/add
str_element,plotstuff,'ylog',ylog
plot_tag_names = tag_names(plotstuff)
for i=0,n_elements(plot_tag_names)-1 do begin
	first_letter = strmid(plot_tag_names(i),0,1)
	case strlowcase(first_letter) of
		'x': str_element,xzplotstuff,plot_tag_names(i),plotstuff.(i),/add
		'y': str_element,zyplotstuff,plot_tag_names(i),plotstuff.(i),/add
		'z': begin
			length = strlen(plot_tag_names(i))
			xzname = 'y'+strmid(plot_tag_names(i),1,length-1)
			zyname = 'x'+strmid(plot_tag_names(i),1,length-1)
			str_element,xzplotstuff,xzname,plotstuff.(i),/add
			str_element,zyplotstuff,zyname,plotstuff.(i),/add
		     end
		else: begin
			str_element,xzplotstuff,plot_tag_names(i),plotstuff.(i),/add
			str_element,zyplotstuff,plot_tag_names(i),plotstuff.(i),/add
		      end
	endcase
endfor

while 1 do begin
	wset,orig_w		;Image window
	cursor,x,y,2,/dev	;Read position

	if !err eq 1 then begin
		mode = 1-mode	;Toggle mode
		repeat cursor,x,y,0,/dev until !err eq 0
	endif
	
	x = round(x - sx)
	y = round(y - sy)
	
	datx = x*(maxx-minx)/nx+minx
	daty = y*(maxy-miny)/ny+miny

	wset,new_w
	
        if !err eq 4 then begin
        	wset,orig_w
        	tvcrs,nx/2,ny/2,/dev
        	tvcrs,0
        	wdelete,new_w
        	!p.font = old_font
        	return
        endif

	if mode ne old_mode then begin
		old_mode = mode
		first = 1
		if mode then begin	;Columns?
			plot,[minz,maxz],[miny,maxy],/nodat,$
				title='Column Profile',_extra=zyplotstuff
			vecy = findgen(ny)*(maxy-miny)/ny + miny
			crossx = [-tickl, tickl]*(maxz-minz)
			crossy = [-tickl, tickl]*(maxy-miny)
			if keyword_set(ylog) then vecy = 10.^vecy
		end else begin
			plot,[minx,maxx],[minz,maxz],/nodata,$
				title='Row Profile',_extra=xzplotstuff
			vecx = findgen(nx)*(maxx-minx)/nx + minx
			crossx = [-tickl, tickl]*(maxx-minx)
			crossy = [-tickl, tickl]*(maxz-minz)
		endelse
	endif
	
	if (x lt nx) and (y lt ny) and $
		(x ge 0) and (y ge 0) then begin	;Draw it
		
		if order then y = (ny-1)-y	;Invert y?
		if first eq 0 then begin	;Erase?
			plots, vecx, vecy,col=0	;Erase graph
			plots, old_x, old_y, col=0	;Erase cross
			plots, old_x1, old_y1, col=0
			xyouts,.1,0,/norm,value,col=0	;Erase text
			empty
		  endif else first = 0
;;;;		value = string([x,y],format="('(',i4,',',i4,')')")
;;;;		value = strtrim(x,2) + string(y)
		value = time_string((datx+time_offset)*time_scale)+' '+string(daty)
		ixy = image[x,y]		;Data value
		if mode then begin		;Columns?
			vecx = float(image[x,*])	;get column
			old_x = crossx + ixy
			old_y = [daty,daty]
			old_x1 = [ixy, ixy]
			old_y1 = crossy + daty
			if keyword_set(ylog) then begin
				old_y = 10.^old_y
				old_y1 = 10.^old_y1
			endif
		  endif else begin
			vecy = float(image[*,y])	;get row
			old_x = [ datx,datx]
			old_y = crossy + ixy
			old_x1 = crossx + datx
			old_y1 = [ixy,ixy]
		  endelse
		xyouts,.1,0,/norm,value	;Text of locn
		plots,vecx,vecy	;Graph
		plots,old_x, old_y	;Cross
		plots,old_x1, old_y1
		endif
endwhile
return
end
