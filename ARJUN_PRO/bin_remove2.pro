;subtracts characteristic noise from data, using stored data in new
;Use load_ph to get variable new
;                      req        opt                    req               opt                  opt     opt          req        req
function bin_remove2, thedata, anglerange = anglerange, $
                      outbins = outbins,whichbins = whichbins,$
                      phi=phi,theta=theta,new = new,nlow = nlow

if thedata.valid ne 0 then begin

if not keyword_set(nlow) then nlow = 1.e5
if not keyword_set(phi) then phi = 20
if not keyword_set(theta) then theta = 41


if not keyword_set(anglerange) then anglerange = 30

n_bins = thedata.nbins



index = where( abs(thedata.theta(0,*)) le theta and abs(thedata.phi(0,*)-180) le phi,count)

if count eq 0 then stop


if keyword_set(whichbins) then print, index

toreturn = conv_units(thedata,'eflux')

toreturn.data(*,index)=toreturn.data(*,index) - new(*,index) + nlow

for i = 0, toreturn.nenergy -1 do begin
	index2 = where(toreturn.data(i,*) lt 0. , count)

;print, 'count',count
	

	if count ne 0 then toreturn.data(i,index2)=0.

endfor


somebins = indgen(n_bins)
somebins(*) = 1
somebins(index)=0
outbins=somebins  ;(where(somebins ne -1))


return, toreturn

endif else return,thedata

end


