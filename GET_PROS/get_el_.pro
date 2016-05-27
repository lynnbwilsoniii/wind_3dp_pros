function get_el_,t

el = get_el(t)
add_magf,el,'wi_B3(GSE)',gap_thresh=7200.
add_ddata,el
add_vsw,el,'v_3d_pl'
return,el
end
