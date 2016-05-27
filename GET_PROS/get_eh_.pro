function get_eh_,t;,ehbkg = bkg

;common get_eh__com,ehbkg

;if n_elements(bkg) ne 0 then ehbkg=bkg
;if not keyword_set(ehbkg) then restore,file='~davin/wind/analysis/ehbkg.dat',/verbose
eh = get_eh(t)
add_magf,eh,'wi_B3',gap_thresh=7200.,/averag
add_ddata,eh
add_vsw,eh,'Vp'
;if keyword_set(ehbkg) then eh = sub3d(eh,ehbkg,siglev=2.)
return,eh
end
