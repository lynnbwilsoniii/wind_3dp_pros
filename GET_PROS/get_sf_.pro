function get_sf_,t

sf = get_sf(t)
add_magf,sf,'wi_B3',gap_thresh=7200.
add_ddata,sf
;add_vsw,sf,'Vp'
return,sf
end
