pro restore_plot_state,ps,show=show,icon=icon,window=win

common plot_state_com, pstates

if n_elements(win) eq 1 then ps = pstates[win]
if keyword_set(show) then wshow ,icon=icon
if size(/type,ps) ne 8 then return
if !d.name eq 'X' || !d.name eq 'WIN' then wset, ps.d.window
!p = ps.p
!x = ps.x
!y = ps.y
!z = ps.z


end
