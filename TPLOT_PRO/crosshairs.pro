pro crosshairs,x,y,color=color,legend=legend,dot_cursor=dot,fix=fix,$
     silent=silent,nolegend=nolegend
;+
;NAME:                  crosshairs
;PURPOSE:
;Display crosshairs on the plot window, display the data coordinates of the
;cursor position on the plot, and return the coordinates of clicked points.
;			Use the mouse buttons to control operation:
;			1: Record and print a point
;			2: Delete the previously recorded point
;			3: Quit.
;CALLING SEQUENCE:      crosshairs,x,y
;INPUTS:                x,y:  set to named variables to return the data
;                             coordinates of the cursor position where mouse
;                             button 1 was pressed.
;
;KEYWORD PARAMETERS:    
;	COLOR:  set to a scalar byte to change the color of the crosshairs.
;		note:  you will not get the color you ask for.  it's the nature 
;		of XOR graphics.  could be useful to change colors though.
;	LEGEND: set a position for the legend, in data coords.
;	DOT_CURSOR:  change the cursor to a dot.  it's smaller and makes seeing
;		the data easier.  warning:  will reset the cursor to crosshairs
;		after quitting.  if you had set your own cursor (changed from
;		the default) it'll be replaced.
;	FIX:	if crosshairs crashes  (if you Control-C out of it) then 
;		you probabaly want to call crosshairs,/fix
;		all it does is calls:  device,set_graphics=3,/cursor_cross
;		but do you want to remember that line?
;		FIX repairs the changes to the X device that crosshairs made.
;	SILENT: don't print clicked points
;       NOLEGEND:  don't display the legend
;OUTPUTS:       prints clicked data points to the terminal, prints the current 
;		cursor position on the graphics window (or last position before
;		leaving the window)
;SIDE EFFECTS:          can mess up your display.  use crosshairs,/fix to fix.
;			can leave junk on your plot.  not recommended for use
;			if you intend to call tvrd() before reploting.
;LAST MODIFICATION:     @(#)crosshairs.pro	1.5 98/07/31
;CREATED BY:            Frank V. Marcoline
;NOTES:			Inspired by IDL's box_cursor.pro
;-
if keyword_set(fix) then begin 
  device,set_graphics=3,/cursor_cross
  return
endif 
if keyword_set(dot) then begin  ;change the cursor to a dot
  curs=intarr(16)
  curs(14)=2^9
  mask=curs
  mask([13,15])=2^9
  mask(14)=mask(14)+2^8+2^10
  device,cursor_image=curs,cursor_mask=mask,cursor_xy=[1,1]
endif 
if not keyword_set(nolegend) then leg  = 1 else leg  = 0
if not keyword_set(silent)   then prin = 1 else prin = 0

device, get_graphics = old, set_graphics = 6  ;Set xor
if not keyword_set(color) then color = !d.n_colors -1
if not keyword_set(legend) then $
  legend = [!d.x_size-22*!d.x_ch_size,!d.y_size-6*!d.y_ch_size] $
else legend = convert_coord(legend(0),legend(1),/data,/to_dev)

flag  = 0 

x0 = !d.x_size/2                ;crosshairs initially in middle of window
y0 = !d.y_size/2

data = convert_coord(x0,y0,/dev,/to_data)
button = 0
goto, middle

while 1 do begin
  old_button = button
  cursor, xd, yd, 2, /dev         ;Wait for a button
  data = convert_coord(xd,yd,/dev,/to_data)
  button = !err
  x0 = xd
  y0 = yd
  if (!err eq 1) and (old_button eq 0) then begin 
    if flag eq 0 then begin 
      x = data(0)
      y = data(1)
      flag = 1
    endif else begin 
      x = [x,data(0)]
      y = [y,data(1)]
    endelse 
    ndp = n_elements(x)
    numstr = strcompress(string('(',ndp,')'),/re)
    if prin then $
      print,numstr,x(ndp-1),y(ndp-1),format='(a8,3x,"x: ",g,"      y: ",g)'
  endif 
  plots,[0,!d.x_size-1],[py,py], color=color, /dev, thick=1, lines=0 
  plots,[px,px],[0,!d.y_size-1], color=color, /dev, thick=1, lines=0 
  if leg then begin 
    xyouts,legend(0),legend(1),                  s1, color=color, /dev, size=1.4
    xyouts,legend(0),legend(1) - 3*!d.y_ch_size, s2, color=color, /dev, size=1.4
  end
  empty
  if !err eq 2 then begin ;move legend
    legend = [xd,yd]
  endif
  
  if !err eq 4 then begin       ;Quitting
    device,set_graphics = old, cursor_cross = dot
    return
  endif
middle:
  
  px = x0
  py = y0
  plots,[0,!d.x_size-1],[py,py], color=color, /dev, thick=1, lines=0 
  plots,[px,px],[0,!d.y_size-1], color=color, /dev, thick=1, lines=0 
  s1 = string('x:',data(0))
  s2 = string('y:',data(1))
  if leg then begin 
    xyouts,legend(0),legend(1),                  s1, color=color, /dev, size=1.4
    xyouts,legend(0),legend(1) - 3*!d.y_ch_size, s2, color=color, /dev, size=1.4
  end 
  empty
  wait, .01                      ;be nice!
endwhile
end
