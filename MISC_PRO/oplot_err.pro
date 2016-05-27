Pro oplot_err, X, Low, High, Width = width, color=color
;+
; PROCEDURE:
;	oplot_err, x, low, high
; PURPOSE:
;	Plot error bars over a previously drawn plot.
;
;-
	on_error,2                      ;Return to caller if an error occurs
	if n_elements(color) ne 0 then col = color else col =!p.color
	if n_params(0) eq 3 then begin	;X specified?
		up = high
		down = low
		xx = x
	   endif else begin	;Only 2 params
		up = x
		down = low
		xx=findgen(n_elements(up)) ;make our own x
	   endelse
	    
        if !y.type eq 1 then down = 10^min(!y.crange)  > down


	if n_elements(width) eq 0 then width = .01 ;Default width
	width = width/2		;Centered
;
	n = n_elements(up) < n_elements(down) < n_elements(xx) ;# of pnts
	xxmin = min(!x.crange)	;X range
	xxmax = max(!x.crange)
	yymax = max(!y.crange)  ;Y range
	yymin = min(!y.crange)



	if !x.type eq 0 then begin	;Test for x linear
		;Linear in x
		wid =  (xxmax - xxmin) * width ;bars = .01 of plot wide.
	    endif else begin		;Logarithmic X
		xxmax = 10.^xxmax
		xxmin = 10.^xxmin
		wid  = (xxmax/xxmin)* width  ;bars = .01 of plot wide
	    endelse
;
	for i=0l,n-1 do begin	;do each point.
		xxx = xx(i)	;x value
		if (xxx ge xxmin) and (xxx le xxmax) then begin
                        oplot,[xxx,xxx],[down(i),up(i)],color=col
;			plots,[xxx-wid,xxx+wid,xxx,xxx,xxx-wid,xxx+wid],$
;			  [down(i),down(i),down(i),up(i),up(i),up(i)],/clip
			endif
		endfor
	return
end
