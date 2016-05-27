function photo_eflux,e
common photo_eflux_com, lg_photo_e,lg_photo_ef

if not keyword_set(lg_photo_ef) then begin
   restore,file="~davin/myidl/wind/eesal/photo_eflux.sav"
   lg_photo_e = alog(photo_e)
   lg_photo_ef = alog(photo_ef)
endif

ef = exp(interp(lg_photo_ef,lg_photo_e,alog(e)))

return,ef
end

