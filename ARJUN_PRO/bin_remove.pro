;sets certain bins to -1.  Outputs good bins in outbins.
;theta and phi set angle range around sun to be removed

function bin_remove, thedata, anglerange = anglerange,outbins = outbins,$
                      whichbins = whichbins,phi=phi,theta=theta,en_pa = en_pa

if thedata.valid eq 0 then return, thedata

if not keyword_set(phi) then phi = 20
if not keyword_set(theta) then theta = 41


if not keyword_set(anglerange) then anglerange = 30


toreturn = thedata


n_bins = thedata.nbins
n_energy = thedata.nenergy

for i = 0, n_energy-1 do begin
	index = where(abs(thedata.theta(i,*)) le theta and abs(thedata.phi(i,*)-180) le phi, count)

;print, index

	if count ne 0 then begin
;REMOVE THE FOLLOWING LINE WHEN ALL THE PROGRAMS HAVE BEEN UPDATED
	if not keyword_set(en_pa) then toreturn.data(i,index) = 0. else toreturn.data(i,index) = 0.
;	if not keyword_set(en_pa) then toreturn.data(i,index) = -1. else toreturn.data(i,index) = 0.
		toreturn.bins(i,index) = 0
	endif
endfor


;index = where( abs(thedata.theta(0,*)) le theta and abs(thedata.phi(0,*)-180) le phi,count)



if keyword_set(whichbins) then print, index


;toreturn.data(*,index)=-1

somebins = indgen(n_bins)
somebins(*) = 1
if count ne 0 then somebins(index)=0
outbins=somebins  ;(where(somebins ne -1))


return, toreturn


end


