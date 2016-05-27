


pro reduce_yres_data,name,n,postfix
if n_elements(postfix) ne 1 then postfix='_r'
if n_elements(n) ne 1 then n =8

names = tnames(name,c)

for i=0,c-1 do begin
   get_data,names[i],time,dat,val,dlim=dlim,lim=lim
   reduce_yres,dat,val,n
   store_data,names[i]+postfix,data={x:time,y:dat,v:val},dlim=dlim,lim=lim
endfor

end


