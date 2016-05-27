pro tconfig_old,configname,set=set,window=w,help=help
tconfigstr = {tconfig_str,name:'',ptr:ptr_new()}
@tplot_com

if not keyword_set(tplot_configs) then begin
  tplot_configs = {tconfig_str,'base',ptr_new(tplot_vars)}
  current_config = 0
endif

if keyword_set(help) then begin
  print,'The current configuration is "',tplot_configs[current_config].name,'"'
  tplot,/help
  print,'The following configurations are also defined:'
  print,transpose([tplot_configs.name])
  return
endif

last_config = current_config

if keyword_set(configname) then begin
   name = string(configname)
   w = where(name eq tplot_configs.name,n)
   if n eq 0 then begin
      print,'Configuration "',name,'" is now defined.'
      tc = {tconfig_str,name,ptr_new(tplot_vars)}
      tplot_configs = [tplot_configs,tc]
      current_config = n_elements(tplot_configs)-1
   endif else begin
      current_config = w[0]
      if keyword_set(set) then begin
         print,'Configuration "',name,'" is now redefined.'
         *(tplot_configs[current_config].ptr) = tplot_vars
      endif else begin
         *(tplot_configs[last_config].ptr) = tplot_vars
         tplot_vars = *(tplot_configs[current_config].ptr)
      endelse
   endelse
endif
  

if n_elements(w) ne 0 then begin
  tplot_options,window=w
endif

end


pro tconfig,configname,set=set,window=wind,help=help,wshow=wshow,wset=wset
tconfigstr = {tconfig_str,name:'',ptr:ptr_new()}
@tplot_com

;if not keyword_set(tplot_configs) then begin
;  tplot_configs = {tconfig_str,'base',ptr_new(tplot_vars)}
;  current_config = 0
;endif

if keyword_set(help) then begin
  print,'The current configuration is "',tplot_configs[current_config].name,'"'
  tplot,/help
  print,'The following configurations are also defined:'
  print,transpose([tplot_configs.name])
  return
endif

w =  -1
if keyword_set(configname) then begin
   name = string(configname)
   if keyword_set(tplot_configs) then w = where(name eq tplot_configs.name,n)
   w=w[0]
   if keyword_set(set) then begin
      if w lt 0 then begin
         tc = {tconfig_str,name,ptr_new(tplot_vars)}
         if keyword_set(tplot_configs) then tplot_configs = [tplot_configs,tc] else tplot_configs=tc
         print,'Configuration "',name,'" is now defined.'
      endif else begin
         *(tplot_configs[w].ptr) = tplot_vars
      endelse
;      return
   endif else begin
      if w ge 0 then   tplot_vars = *(tplot_configs[w].ptr) $
      else print,'Configuration "',name,'" is not defined!'
;      return
   endelse
endif

if n_elements(wind) ne 0 then begin
  tplot_options,window=wind
endif

tplot,/help
w = !d.window
str_element,tplot_vars,'options.window',w

if keyword_set(tplot_configs) then begin
   print,'The following configurations are also defined:'
   print,"'"+transpose([tplot_configs.name])+"'"
endif

if keyword_set(wshow) then wshow,w,1,iconic=0
if keyword_set(wset) then wset,w

end
