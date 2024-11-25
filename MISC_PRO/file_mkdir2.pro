;+
;PROCEDURE  FILE_MKDIR2, dir
;PURPOSE:  Wrapper for FILE_MKDIR that also sets the mode for each newly created directory.
;   dir must be a scalar.
;D. Larson, April, 2008
;
pro file_mkdir2,dirs,mode=mode,dir_mode=dir_mode,writeable=writeable $
    ,dlevel=dlevel,verbose=verbose,add_link=add_link,add_parent_link=add_parent_link

for i = 0,n_elements(dirs)-1  do begin
  dir = dirs[i]
  fi = file_info(dir)
  writeable = fi.write
  if keyword_set(dir_mode) then mode=dir_mode
  if fi.directory then  continue
  if (~fi.directory and fi.exists) then begin ;if it is an existing file, skip
    dprint, 'File exists but it is not a directory: ',  dir, dlevel=dlevel,verbose=verbose
    writeable=0
  endif else begin
    parent_dir = file_dirname(dir)
    ;dprint,parent_dir
    if parent_dir ne dir then file_mkdir2,parent_dir,mode=mode,writeable=writeable,verbose=verbose  $
         ,add_parent_link=add_parent_link, add_link = keyword_set(add_parent_link) ? add_link : ''    ; Make parent directories if needed.
    if writeable then begin
      dprint,'Creating new directory: ',dir,dlevel=dlevel,verbose=verbose
      file_mkdir,dir
      if keyword_set(mode) then file_chmod,dir,mode
      writeable = 1b
      if keyword_set(add_link) then begin
        dprint,'Creating link to: '+add_link,verbose=verbose
        file_link,add_link,dir +'/'+file_basename(add_link)
      endif
    endif else dprint,dlevel=dlevel,verbose=verbose,'Unable to create Directory: ',dir
  endelse
  
endfor



end

