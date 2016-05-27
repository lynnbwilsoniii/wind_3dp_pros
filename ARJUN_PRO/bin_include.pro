function bin_include, thedata, phi = phi, theta = theta,sun = sun, dusk = dusk, dawn = dawn, tail = tail,whichbins = whichbins

if thedata.valid eq 0 then return, thedata

if not keyword_set(phi) then phi = 45.
if not keyword_set(theta) then theta = 30.

if keyword_set(sun) then phioffset = 0.
if keyword_set(dusk) then phioffset = 90.
if keyword_set(tail) then phioffset = 180.
if keyword_set(dawn) then phioffset = 270.


index = where( abs(thedata.theta(0,*)) gt theta or $
		abs(thedata.phi(0,*)-phioffset) gt phi,count)


if count eq 0 then return, thedata

toreturn = thedata

toreturn.data(*,index) = 0.

if keyword_set(whichbins) then print, index

return, toreturn

end
