;+
;PROCEDURE:
;   bkg_file,bkg [,filename]
;PURPOSE:
;   saves and restores background data files.
;   if filename is not a string then a filename is generated automatically.
;INPUT:
;   bkg:  a 3d background data structure.
;   filename:  optional filename.
;KEYWORDS:  One must be set!
;   SAVE:   set to save files.
;   RESTORE:set to restore files.
;-
pro bkg_file,bkg,filename,save=save,restore=restore

;dir = getenv('IDL_3DP_DIR')+'/bkgdata'
mdir = FILE_EXPAND_PATH('')+'/BKGDATA/'


if keyword_set(save) then begin
    if data_type(filename) ne 7 then begin
        timestamp = strmid(time_to_str(bkg.time),0,10)
        detector  = strcompress(bkg.data_name,/remove_all)
        filename = detector+'_'+timestamp+'.bkg'
    endif
    save,bkg,filename=mdir+'/'+filename
    return 
endif

if keyword_set(restore) then begin
    if data_type(filename) ne 7 then filename = pickfile(path = mdir,/must_exist)
    if keyword_set(filename) then restore,filename  $
    else print, "No file selected!"
    return
endif

print,"You must use either the SAVE or RESTORE keyword"

end
