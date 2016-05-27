

pro reduce_timeres_data,name,res,postfix
if n_elements(postfix) ne 1 then postfix='_t'
if n_elements(res) ne 1 then res=300d ; (five minute average)

names = tnames(name,c)

for i=0,c-1 do begin
   newname = names[i]+postfix
   print,'Reducing time resolution of ',names[i],' to ',strtrim(res),'s,  newname: ',newname
   get_data,names[i],time,dat,val,dlim=dlim,lim=lim
   d = reduce_timeres(time,dat,res,newtime=t)
   if size(val,/n_dim) eq 2 then val=reduce_timeres(time,val,res,newtime=t)
   store_data,newname,data={x:t,y:d,v:val},dlim=dlim,lim=lim
endfor

end

