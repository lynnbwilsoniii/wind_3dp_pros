;+ open
;Procedure:  tplot_ascii
;Purpose:
;  Creates an ascii file for selected tplot variables.
;Input:
;  Names names of tplot variables. May use glob patterns  to specify
;        a set of variables.
;Keywords:
;  fname: file name, by default 'tplot_name' where name is set to
;		  tvar[n] (variable name)
;  Ext:  by default, a separate file will be created in the
;        current directory with name tplot_name.txt.  Use this
;        keyword to set the .txt extension to a different extension.
;  dir:  Put output  in dir as opposed to current working directory.
;  precise: increases precision to maximum (microseconds)
;  trange: array[2] of double  or string. Specify time range for output.
;  header: optional keyword, if set ascii file will contain header information
;History:
;  08-Jul-2008, cg, added formating to handle 3 d data sets
;  09-may-2008, cg, added format statement to print so that the values didn't 
;               run together
;  09-may-2008, cg, added use of precision keyword, set default value = 3
;  29-apr-2008, cg, fixed bug with dlimits
;  28-mar-2008, cg, added keyword fname to allow user to specify a file
;               name (thm_ui_dproc procedure determines and passes the
;               filename)
;  28-mar-2008, cg, added file header
;  27-aug-2008, cg, added another time precision keyword /msec to print format
;  09-jul-2009, cg, added code to write the v component to a file, also added
;                   print statements indicating success or failure.
;  30-nov-2010, jmm, removed /msec from time_string call
;-

pro tplot_ascii,names,trange=trange,fname=fname,ext=ext,dir=dir,$
                precise=precise,header=header, format_string=format_string

if not keyword_set(fname) then fname = '' else fname = fname+'_'
if not keyword_set(ext) then ext = '.txt'
if not keyword_set(dir) then dir = '' else dir = file_expand_path(dir)+ '/'
if not keyword_set(precise) then precise=3 else precise=6
time_precision_str = 'A' + strtrim(20 + precise,2) ;this will now be either 23 or 26 characters

tvar=tnames(names)

nv = n_elements(tvar)

for n=0,nv-1 do begin
  varnam=tvar[n]
  vflag=0
  v2flag=0
  v3flag=0
  
  get_data,varnam,data=d, limits=l, dlimits=dl    
  if keyword_set(d) then begin
     time = d.x
     data = d.y
     tnames = strupcase(tag_names(d))
     ;test for either v or v1 components
     result = where(tnames eq 'V')
     if result NE -1 then begin
        vflag=1 
        datav = d.v
     endif      
     result = where(tnames eq 'V1')
     if result NE -1 then begin
        vflag=1
        datav = d.v1
     endif      
     result = where(tnames eq 'V2')
     if result NE -1 then begin
        v2flag = 1
        datav2= d.v2
     endif
     result = where(tnames eq 'V3')
     if result NE -1 then begin
        v3flag = 1
        datav3 = d.v3
     endif
     if keyword_set(trange) then begin
         tr=time_double(trange)
         w=where(time ge tr[0] and time le tr[1],c)
         if c gt 0 then begin
           time =time[w]
           dim = size(data, /dimensions)
         endif else begin
           dprint,  'There is no data in specified time range'
           dprint,  time_string(trange)
           return
         endelse
         if n_elements(dim) eq 3 then data = data[w,*,*] else data = data[w,*]         
     endif else c=n_elements(time)
     filename = dir+fname+varnam+ext
     openw,/get_lun,lun,filename,width=2500
     if vflag then openw,/get_lun,lunv,string(dir+fname+varnam+'_v'+ext),width=2500    
     if v2flag then openw, /get_lun, lunv2, string(dir+fname+varnam+'_v2'+ext),width=2500   
     if v3flag then openw, /get_lun, lunv3, string(dir+fname+varnam+'_v3'+ext),width=2500 
 
     if keyword_set(header) then Begin
        printf, lun, ';VARIABLE NAMES: ', varnam
        ndims = size(data, /dimensions)
        Case n_elements(ndims) of
        1: Begin
           printf, lun, ';NUMBER ROWS: ', ndims
           printf, lun, ';NUMBER COLUMNS: ', 2
        End
        2: Begin
           printf, lun, ';NUMBER ROWS: ', ndims[0]
           printf, lun, ';NUMBER COLUMNS: ', ndims[1]+1
        End
        3: Begin
           printf, lun, ';NUMBER ROWS: ', ndims[0]*2
           printf, lun, ';NUMBER COLUMNS: ', ndims[1]+1
        End
        EndCase
                
        ;if data limits exists then add coordinate system, units, and labels
        if size(dl, /type) eq 8 then Begin
          tagnames= tag_names(dl)
          results=strpos(tagnames, 'DATA_ATT')
          index=where(results ge 0)
          if index ge 0 then Begin
              printf, lun, ';DATA LIMIT VALUES '
              tagnames = tag_names(dl.data_att)
              results=strpos(tagnames, 'COORD_SYS')
              index=where(results ge 0)
              if index ge 0 then coord_sys=dl.data_att.coord_sys else $
               coord_sys='Unknown'
            printf, lun, ';COORDINATE SYSTEM: ', coord_sys
            results=strpos(tagnames, 'UNITS')
            index=where(results ge 0)
            if index ge 0 then units=dl.data_att.units else $
               units='Unknown'
            printf, lun, ';UNITS: ', units
            tagnames = tag_names(dl)
            results=strpos(tagnames, 'LABELS')
            index=where(results ge 0)
            if index ge 0 then labels=dl.labels else $
               labels='Unknown'
            printf, lun, ';LABELS: ', labels
           endif else Begin
            printf, lun, ';COORDINATE SYSTEM: Unknown'
            printf, lun, ';UNITS: Unknown'
            printf, lun, ';LABELS: Unknown'
           endelse 
 	     endif else Begin
 	        printf, lun, ';COORDINATE SYSTEM: Unknown'
          printf, lun, ';UNITS: Unknown'
          printf, lun, ';LABELS: Unknown'
 	     endelse
	   endif

     dim = size(data, /dimensions)
     if n_elements(dim) eq 1 then ncol=dim[0]
     if n_elements(dim) ge 2 then ncol=dim[1]
     if n_elements(dim) eq 3 then begin
        col1=reform(data[*,*,0])
        col2=reform(data[*,0,*])
        data = [col1, col2]
     endif    
     
     if ~keyword_set(format_string) then begin
       dtype = size(data, /type)
       Case dtype of 
         2: format_string = '(' + time_precision_str + '(2X,I12))'
         3: format_string = '(' + time_precision_str + ', ' + strtrim(ncol, 2) + '(2X,I12))'
         4: format_string = '(' + time_precision_str + ', ' + strtrim(ncol, 2) + '(2X,e20.7))'
         5: format_string = '(' + time_precision_str + ', ' + strtrim(ncol, 2) + '(2X,e20.7))' 
         12: format_string = '(' + time_precision_str + ', ' + strtrim(ncol, 2) + '(2X,I12))'
         13: format_string = '(' + time_precision_str + ', ' + strtrim(ncol, 2) + '(2X,I12))'
         14: format_string = '(' + time_precision_str + ', ' + strtrim(ncol, 2) + '(2X,I12))'
         15: format_string = '(' + time_precision_str + ', ' + strtrim(ncol, 2) + '(2X,I12))'
       Else: format_string = '(' + time_precision_str + ', ' + strtrim(ncol, 2) + '(2X,e20.7))'
       EndCase
     endif    
    
     for i=0l,c-1 do begin
       printf,lun,time_string(time[i],precision=precise),reform(data[i,*]),$
       format=format_string
     endfor
     close,lun
     free_lun, lun
     dprint,  'File '+filename+' successfully created for variable '+varnam
   endif  
   
   ;if y-axis scaling information exists, write it to a file   
   if vflag then begin
     dim = size(datav, /dimensions)
     if n_elements(dim) eq 1 then ncol=dim[0]
     if n_elements(dim) ge 2 then ncol=dim[1]
     if n_elements(dim) eq 3 then begin
        col1=reform(data[*,*,0])
        col2=reform(data[*,0,*])
        datav = [col1, col2]
     endif 
     for i=0l,dim[0]-1 do begin
       printf,lunv,reform(datav[i,*])
     endfor
     close,lunv
     free_lun, lunv     
   endif
   if v2flag then begin
     dim = size(datav2, /dimensions)
     if n_elements(dim) eq 1 then ncol=dim[0]
     if n_elements(dim) ge 2 then ncol=dim[1]
     if n_elements(dim) eq 3 then begin
       col1=reform(data[*,*,0])
       col2=reform(data[*,0,*])
       datav2 = [col1, col2]
     endif
     for i=0l,dim[0]-1 do begin
       printf,lunv2,reform(datav2[i,*])
     endfor
     close,lunv2
     free_lun, lunv2
   endif
   if v3flag then begin
     dim = size(datav3, /dimensions)
     if n_elements(dim) eq 1 then ncol=dim[0]
     if n_elements(dim) ge 2 then ncol=dim[1]
     if n_elements(dim) eq 3 then begin
       col1=reform(data[*,*,0])
       col2=reform(data[*,0,*])
       datav3 = [col1, col2]
     endif
     for i=0l,dim[0]-1 do begin
       printf,lunv3,reform(datav3[i,*])
     endfor
     close,lunv3
     free_lun, lunv3
   endif
endfor

;notify user if some of the names do not have tplot variables
for i=0,n_elements(names)-1 do begin
   result = where(tvar eq names[i])
   if result eq -1 then dprint,  string('Variable '+names[i]+' does not exist. File not created.')
endfor

end
