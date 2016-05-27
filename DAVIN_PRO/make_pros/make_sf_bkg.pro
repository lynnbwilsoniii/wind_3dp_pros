;+
;*****************************************************************************
;
;  PURPOSE:
;
;
;
;  CALLS:  add_ddata.pro
;
;
;
;  INPUT:  sf = 3d data structure from get_sf.pro
;
;
;  KEYWORDS:  GRATIO = constant of proportionality in Power-Law
;
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  04/05/2008
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************
;-


function make_sf_bkg,sf,gratio=gratio
if n_elements(gratio) eq 0 then gratio = .075

bkg = sf
if sf.units_name ne 'Counts' then print,'Units must be counts!'
add_ddata,bkg

f6bins = [14,16,17,38,40,41]      ; 15 , 39 thrown out
n6 = n_elements(f6bins) 
f2bins = [20,22,23,44,45,46,47]   ; 21 thrown out
n2 = n_elements(f2bins)


ct6=total(sf.data(*,f6bins),2)
dct6 = sqrt(ct6)/n6
ct6 = ct6/n6

ct2=total(sf.data(*,f2bins),2)
dct2 = sqrt(ct2)/n2
ct2 = ct2/n2

de6 = sf.denergy(*,f6bins(0))
de2 = sf.denergy(*,f2bins(0))
e6 = sf.energy(*,f6bins(0))
e2 = sf.energy(*,f2bins(0))

pe = replicate(-3.,7)  ;  power law spectrum for electrons
pb = replicate(-4.,7)  ;  power law spectrum for background

re = gratio * (e2/e6)^pe * de2/de6
rb = (e2/e6)^pb * de2/de6

cb6 = (ct2-re*ct6)/(rb-re)
dcb6 = sqrt(dct2^2+(re*dct6)^2)/(rb-re)

geom = [4, 4, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 4, 4, 2, 2, 2, 2 $
      , 4, 4, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 4, 4, 2, 2, 2, 2]
geom = geom/2.      ; account for factor of 2 in geom

e6f = e6 # replicate(1.,48)
de6f = de6 # replicate(1.,48)
pbf = pb # replicate(1.,48)

b_scale = (sf.energy/e6f)^pbf * (sf.denergy/de6f)

bkg.data = (cb6 # geom) * b_scale
bkg.ddata = (dcb6 # geom) * b_scale
stop

return ,bkg
end
