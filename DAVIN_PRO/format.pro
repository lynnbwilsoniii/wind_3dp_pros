function format,value,name,recurs=recurs

sz = size(value,/struct)

wids = [2,3,5,8,10,12,13,20,0]

if sz.type le 5 then begin
  mm = minmax_range(value)
  
endif

sp = '" "'

case sz.type of 
 0:  f = '"??"'
 1:  f = 'i3'
 2:  f = 'i5'
 3:  f = 'i8'
 4:  f = 'f8.2'
 5:  f = 'f10.4'
 7:  f = 'a'+strtrim(max(strlen(value)),2)
 8:  begin
     n = n_tags(value)
     names = tag_names(value)
     f=''
     for i=0,n-1 do begin
       if i ne 0 then f = f+','
       f=f+format(value.(i),names[i],/recurs)
     endfor
     f = '('+f+')'
     end
endcase
f='('+f+','+sp+')'

if sz.n_elements ge 2 then f = strtrim(sz.n_elements,2)+f

if not keyword_set(recurs) then    f = '('+f+')'

return,f
end


