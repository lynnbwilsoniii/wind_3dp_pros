;+
;PROCEDURE: tsmooth2, name, width, newname=newname
;PURPOSE:
;  Smooths the tplot data. 
;INPUTS: name:	The tplot handle.
;	 width:	Integer array, same dimension as the data.
;
;Documentation not complete.... 	
;
;CREATED BY:     REE 10/11/95
;Modified by:  D Larson.
;LAST MODIFICATION:	%M%
;
;-

pro tsmooth2, name, width, esteps=esteps, newname=newname

; Check that width is supplied.
if n_elements(width) eq 0 then begin
  message,/info, 'Smoothing width defaulting to 10.'
  width=10
endif

; Retrieve the data and check.
get_data,name,data=data,alim=alim
if data_type(data) ne 8 then message,'Bad data.'

w = width
d = dimen2(data.y)
if d ne dimen1(w) then w = replicate(width[0],d)


; Start main loop for smoothing.
for i = 0,d-1 do begin
  if w[i] gt 2 then begin
    bad_data=where(data.y[*,i] gt 1.9e20,count)
    if count gt 0 then $
        data.y[bad_data,i]=( data.y[bad_data-1,i] + data.y[bad_data+1,i] ) /2.0
    data.y[*,i] = smooth(data.y[*,i],w[i],/nan)
    if count gt 0 then $
        data.y[bad_data,i]=2.0e20
  endif
endfor

; Store the data.
printdat,out=outs,width,'width',/val
str_element,/add,alim,'comment',outs[0]
if not keyword_set(newname) then newname = name+'_sm'
store_data,newname,data=data,dlim=alim

return

end
