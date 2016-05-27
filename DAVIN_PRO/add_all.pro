;+
;PROCEDURE: add_all
;PURPOSE:
;  adds user defined structure elements to the 3d structures.
;USAGE:
;  add_all,dat,add
;INPUT:
;  dat:  A (3d) data structure.
;  add:  a structure such as:  {vsw:'Vp' , magf:'B3',  sc_pos:'pos'}
;RESULTS:
;  for the above example, the elements, vsw, magf, and sc_pos are
;  added to the dat structure.  The values are obtained from the tplot
;  variables 'Vp', 'B3' and 'pos' respectively.
;-
pro add_all,dat,add

if data_type(add) ne 8 then return


n = n_tags(add)
names = tag_names(add)

for i=0,n-1 do begin
   source = add.(i)
;print,"Obtaining: ",names(i),"   Using: ",source
   if data_type(source) eq 7 then begin
     case strmid(source,0,2) of 
        'f:':  begin
                val = call_function(strmid(source,2,40),dat)
                add_str_element,dat,names(i),val
              end
        'p:':   call_procedure,strmid(source,2,40),dat
        's:':   add_str_element,dat,names(i),strmid(source,2,40)
        else: begin
                val = data_cut(source,(dat.time+dat.end_time)/2.)
                add_str_element,dat,names(i),val
              end
     endcase
   endif else $
        add_str_element,dat,names(i),source
endfor


end
