pro load_if_needed,name,method

common load_if_needed,load_index

ind ={nammethformat,name:'',method:'',trange:[0d,0d] }

d2=dblarr(2)
if not keyword_set(load_index) then begin
  
  load_index = [  $
     {nammethformat,'wi_B3','load_wi_h0_mfi,/pol',d2}, $
     {nammethformat,'wi_B' ,'load_wi_mfi,/pol',d2},  $
     {nammethformat,'wi_pos','load_wi_pos,/pol',d2},  $
     {nammethformat,'wi_swe_Np'   ,'load_wi_swe,/pol',d2},  $
     {nammethformat,'Vp'   ,'get_pmom2',d2},  $
     {nammethformat,'Np'   ,'get_pmom2',d2}  $
  ]
   
endif

n = tnames(name)
if keyword_set( n ) then return
i = where( load_index.name eq name ,c)
if c ne 0 then begin
  r = execute(load_index[i[0]].method)
  return
endif

method = ''
prmpt = "Command needed to load '"+name+"' ?"
read,prompt=prmpt,method
if not keyword_set(method) then return
r = execute(method)
if r ne 0 then begin
  ind.name = name
  ind.method = method
  ind.trange = timerange()
  load_index = [load_index,ind]
endif

end
