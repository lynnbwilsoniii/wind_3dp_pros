;+
;PROCEDURE:
;   dat_file,dat [,filename]
;PURPOSE:
;   saves and restores 3d data files.
;   if filename is not a string then a filename is generated automatically.
;INPUT:
;   dat:  a 3d background data structure.
;   filename:  optional filename.
;KEYWORDS:  One must be set!
;   SAVE:   set to save files.
;   RESTORE:set to restore files.
;   DIR:  (string) Directory to use. Default is current directory
;-
pro dat_file,dat,filename,save=save,restore=restore

if data_type(dir) ne 7 then dir='.'

if keyword_set(save) then begin
    if data_type(filename) ne 7 then begin
        timestamp = strmid(time_to_str(dat.time),0,10)
        detector  = strcompress(dat.data_name,/remove_all)
        filename = detector+'_'+timestamp+'.dat'
    endif
    save,dat,filename=dir+'/'+filename
    return 
endif

if keyword_set(restore) then begin
    if data_type(filename) ne 7 then filename = pickfile(path = dir,/must_exist)
    if keyword_set(filename) then restore,filename  $
    else print, "No file selected!"
    return
endif

print,"You must use either the SAVE or RESTORE keyword"

end
