;+
;PROCEDURE:   time_stamp,charsize=charsize
;PURPOSE:
;     Prints a time stamp along the lower right edge of the current plot box
;KEYWORDS:  
;     CHARSIZE:  The character size to be used.  Default is !p.charsize/2.
;     ON:        if set, then timestamping is turned on. (No other action taken)
;     OFF:       if set, then timestamping is turned off. (Until turned ON)
;-
pro time_stamp,charsize = chsize,on=on,off=off
common time_stamp_com, active

if n_elements(active) eq 0 then active = 1
if keyword_set(on)  then begin & active = 1 & return & endif
if keyword_set(off) then begin & active = 0 & return & endif


if n_elements(chsize) eq 0 then chsize = !p.charsize/2.
if chsize le 0 then chsize = .5
if active then begin
  xp = !x.window(1) + chsize * !d.y_ch_size/!d.x_size
  yp = !y.window(0)
  xyouts,xp,yp,systime(),charsize=chsize,/norm,orien=90.
endif
end
