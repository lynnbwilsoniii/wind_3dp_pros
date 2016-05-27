;+
;PROCEDURE:  tplot_file , name [,filename]
;PURPOSE:
;   OBSOLETE PROCEDURE!  Use "TPLOT_SAVE" and "TPLOT_RESTORE" instead.
;   Store tplot data in a file.
;  gets the data, limits and name handle associated with a name string
;   This procedure is used by the tplot routines.
;INPUT:  
;   name    (string, tplot handle)
;   filename:  file name
;KEYWORDS:   
;   SAVE:   set to save files.
;   RESTORE:set to restore files.
;SEE ALSO:      "STORE_DATA", "GET_DATA", "TPLOT"
;
;CREATED BY:    Davin Larson
;LAST MODIFICATION:     tplot_file.pro   98/08/06
;
;-
pro tplot_file,handlenames,filenames,save=save,restore=restore, $ 
     direc=dir,all=all 

@tplot_com.pro

if keyword_set(save) then begin
   if keyword_set(all) then  handlenames = (data_quants.name)(1:*)
   n = n_elements(handlenames)
   for i=0,n-1 do begin
     handlename = handlenames(i)
     data=0
     limits=0
     get_data,handlename,data=data,limit=limits,dlimit=dlimits
     if data_type(filenames) ne 7 then begin
        timestamp = strmid(time_string(min(data.x)),0,10)
        filename = handlename+'_'+timestamp+'.tplot'
        if keyword_set(dir) then  filename = filepath(filename,root=dir)
     endif else filename = filenames(i)
     save,handlename,data,limits,dlimits,file=filename
     print,'Saved ',handlename,' in file: ',filename
   endfor
endif


if keyword_set(restore) then begin
   if keyword_set(all) then filenames = findfile('*.tplot')
   if data_type(filenames) ne 7 then $
     filenames = pickfile(path = dir,/must_exist,get_path=dir,filter='*.tplot') 
   n = n_elements(filenames)
   for i=0,n-1 do begin
     handlename = ''
     data = 0
     limits = 0
     restore,filenames(i)
     store_data,handlename,data=data,limit=limits,dlimit=dlimits
   endfor
endif

end
