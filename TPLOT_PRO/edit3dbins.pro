;+
;PROCEDURE:  edit3dbins,dat,bins
;PURPOSE:   Interactive procedure to produce a bin array for selectively 
;    turning angle bins on and off.  Works on a 3d structure (see 
;    "3D_STRUCTURE" for more info)
;
;INPUT:
;   dat:  3d data structure.  (will not be altered)
;   bins:  a named variable in which to return the results.
;KEYWORDS:
;   EBINS:     Specifies energy bins to plot.
;   SUM_EBINS: Specifies how many bins to sum, starting with EBINS.  If
;              SUM_EBINS is a scaler, that number of bins is summed for
;              each bin in EBINS.  If SUM_EBINS is an array, then each
;              array element will hold the number of bins to sum starting
;              at each bin in EBINS.  In the array case, EBINS and SUM_EBINS
;              must have the same number of elements.
;SEE ALSO:  "PLOT3D" and "PLOT3D_OPTIONS"
;CREATED BY:	Davin Larson
;FILE: edit3dbins.pro
;VERSION:  1.14
;LAST MODIFICATION: 98/01/16
;-
pro edit3dbins,dat,bins,lat,lon, $
  spectra= spectralim,   $
  EBINS=ebins,           $
;  SPEC_WINDOW=spwindow,  $
  SUM_EBINS=sum_ebins, $
  tbins=tbins

if(dat.valid eq 0) then begin
  print,'Invalid data'
  return
endif

str_element,spectralim,'bins',bins

nb = dat.nbins
n_e= dat.nenergy
phi = total(dat.phi,1)/n_e
theta = total(dat.theta,1)/n_e

;  Convert from flow direction to look direction
;phi = phi-180.
;theta =  - theta

if keyword_set(ebins) then ebins=ebins(0)  $
else ebins=0

if keyword_set(sum_ebins) then sum_ebins=sum_ebins(0) $
else sum_ebins=dat.nenergy

plot3d,dat,lat,lon,ebins=ebins,sum_ebins=sum_ebins,tbins=tbins

state = ['off','on']
colorcode = [!p.background,!p.color]

if n_elements(bins) ne dat.nbins then bins = bytarr(nb)+1
lab=strcompress(indgen(dat.nbins),/rem)
xyouts,phi,theta,lab,align=.5,COLOR=colorcode(bins)

str_element,spectralim,'bins',bins,/add

print, 'ON: Button1;    OFF: Button2;   QUIT: Button3'
cursor,ph,th
button = !err
while button ne 4 do begin
  if th ge 1000. then goto, ctnu
  pa = pangle(theta,phi,th,ph)
  minpa = min(pa,b)
  current = bins(b)
  bins(b) = button eq 1
  if current ne bins(b) then begin
    print,ph,th,b,'  ',state(bins(b))
    xyouts,phi(b),theta(b),lab(b),align=.5,COLOR=colorcode(bins(b))
    if keyword_set(spectralim) then begin
       w = !d.window
       wi,w+1
       spectralim.bins = bins
       spec3d,dat,lim=spectralim
       wi,w
       plot3d,dat,lat,lon,ebins=ebins,sum_ebins=sum_ebins,/setlim,tbins=tbins
    endif
  endif
ctnu:
  cursor,ph,th
  button = !err
endwhile

return
end


