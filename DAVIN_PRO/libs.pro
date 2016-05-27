;+
;Name: libs
;Purpose:
;  Displays location of source files.
;
;Usage:
;  libs,string  ; string is the name of an IDL source file.
;                 It may contain wildcard characters
;Restrictions:
;
;-

pro libs,name,routine_names=rt_names,verbose=verbose,multiples=multiples, $
   date_sort=date_sort


slash = path_sep()
sep   = path_sep(/search_path)

dirs = ['.',strsplit(!path,sep,/extract)]
vb = keyword_set(verbose) ? verbose : 0

if keyword_set(multiples) then begin

  files = dirs+slash+name+'.pro'
  f = file_search(files)
  rt_names=file_basename(f)
  rt_dirs =file_dirname(f)
  s = sort(rt_names)
  rt_names=rt_names[s]
  rt_dirs =rt_dirs[s]
  f = f[s]
;   rt_names=rt_names[uniq(rt_names)]
  u = uniq(rt_names)
  du = u-shift(u,1)
  du[0]=1
  wm = where(du gt 1,nm)
  uwm = u[wm]
  rt=rt_names
  printdat,width=150,rt[uwm]
  printdat,width=150,rt[uwm-1]
  for i=0,nm-1 do begin
     print,f[uwm[i]]
     print,f[uwm[i]-1]
     print
  endfor

  return


endif



if n_elements(name) eq 0 then begin
   print,transpose(dirs)
   return
endif

files = dirs+slash+name+'.pro'

;for i=0,n_elements(dirs)-1 do  begin     The loop over directories is not needed
;   f = file_search(files[i])
;   if keyword_set(f) then  print,transpose(f)
;endfor

f = file_search(files)

if arg_present(rt_names) then begin
   if vb ge 2 then if keyword_set(f) then  print,transpose(f) else print,'"',name,'" not found'
   rt_names=file_basename(f,'.pro')
   rt_names=rt_names[sort(rt_names)]
   rt_names=rt_names[uniq(rt_names)]
   return
endif


if keyword_set(date_sort) then begin
   fs = file_info(f)
   s = sort(fs.mtime)
   f = time_string(/local,fs.mtime) +'  ' + f
   f = f[s]
endif



if keyword_set(f) then  print,transpose(f)


end
