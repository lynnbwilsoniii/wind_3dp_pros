;pro tcut_plot,ld,noerase=noerase


;end


pro tcut,noshow=noshow,limits=l,np=np,t,varname,ncuts=ncuts

if n_elements(np) eq 0 then np=2
if n_elements(ncuts) eq 0 then ncuts=10000

for i=0,ncuts-1  do begin
 ctime,t,np=np,vnam=varname,noshow=i
 varnames=varname
 n = 0
 repeat begin
  if not keyword_set(t) then return
  ld = 0
  get_data,varnames[n],data=d,alimit=ld
  if data_type(d) eq 7 then begin
     varnames=tnames(d) 
     get_data,varnames[0],data=d,alimit=lim
     extract_tags,lim,ld
     ld = lim
  endif 
 
  lim = 0
  tgs = ['title','range','log','style']
  spec = 0
  str_element,ld,'spec',spec
  if keyword_set(spec) then begin
    extract_tags,lim,ld, tags='z'+tgs, ntags='y'+tgs
    extract_tags,lim,ld, tags='y'+tgs, ntags='x'+tgs
  endif else begin
    extract_tags,lim,ld, tags= 'y'+tgs
  endelse
  str_element,/add,lim,'title',varname[0]+'  '+trange_str(t) 
;help,v,y,lim,/st

  extract_tags,lim,l

  extract_tags,opt,lim,/oplot

  
;help,varname,d,ld,/st
  if not keyword_set(d) then return

  if n_elements(t) eq 2 then w = where(d.x ge t(0) and d.x lt t(1),c)
  if n_elements(t) eq 1 then dummy = min(abs(d.x - t[0]),w)
  y = d.y(w,*)
  x = d.x(w)
  if ndimen(d.v) eq 2 then v = d.v(w,*) else v =d.v
  
  if ndimen(y) eq 2 then y = average(y,1,/nan)
  if ndimen(v) eq 2 then v = average(v,1,/nan)

  box,lim,v,y
  oplot,v,y,_extra=opt
 endrep until 1
endfor
  
end
