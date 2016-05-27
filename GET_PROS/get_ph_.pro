function get_ph_,t,phbkg = bkg
common get_ph__com,phbkg

if n_elements(bkg) ne 0 then phbkg=bkg
if not keyword_set(phbkg) then restore,file='~davin/wind/analysis/phbkg.dat',/verbose

ph = get_ph(t)
add_magf,ph,'wi_B3',gap_thresh=7200.
add_ddata,ph
ph = sub3d(ph,phbkg)
;add_vsw,ph,'Vp'
return,ph
end
