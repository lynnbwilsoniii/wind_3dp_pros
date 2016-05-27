;+
;**************************************************************************
;CREATED BY:    Davin Larson    
;    LAST MODIFIED:  04/06/2008
;    MODIFIED BY: Lynn B. Wilson III
;**************************************************************************
;-
Function mom3d_el ,data, tdensity, $
   debug=debug, $
   sc_pot=sc_pot,  $
   magdir=magdir, $
   pardens = pardens, $
   sumtens = sum, $
   ERANGE=er, $
   format=momformat,  $
;   BINS=bins,   $ 
   valid = valid
;**************************************************************************
;str_element,momformat,'sc_pot',sc_pot
;if keyword_set(sc_pot) eq 0 then sc_pot = 4.
;**************************************************************************
pota = [6.,35.]
m0 = mom3d(data,sc_pot=pota[0])
m1 = mom3d(data,sc_pot=pota[1])
dens = [m0.density,m1.density]
   
err = 1.
i=0
while (err gt .01) and (i lt 30) do begin
      yp = (pota[0]-pota[1])/(dens[0]-dens[1])
      pot = (pota[0] - (dens[0]-tdensity) * yp)
      m0 = mom3d(data,sc_pot=pot,format=momformat)
      dens = [m0.density,dens]
      pota = [pot,pota]
      err = abs((m0.density-tdensity)/tdensity)
      i=i+1
if keyword_set(debug) then begin
      print,i,pot,m0.density,err
      plots,pot,m0.density,/ps
endif
endwhile

return,m0
end

