;+
; Procedure: file_copy2
;-
pro file_copy2,serverdir=serverdir,localdir=localdir,pathname=pathname,verbose=verbose,no_clobber=no_clobber

dprint,dlevel=4,'Start; $Id: file_copy2.pro 24506 2018-01-11 01:03:26Z adrozdov $'

rmt = file_info(serverdir+pathname)
lcl = file_info(localdir +pathname)

if rmt.exists and lcl.mtime lt rmt.mtime  then begin
   dirname = file_dirname(lcl.name)
   if file_test(dirname,/dir) eq 0 then begin
       dprint,dlevel=3,verbose=verbose,'Creating new directory: "'+dirname+'"'
       file_mkdir,dirname
   endif
   dprint,dlevel=2,verbose=verbose,'Copying: "',pathname,'" From: "', serverdir, '" To: "',localdir,'"'
   t1 = systime(1)
   file_copy,rmt.name,lcl.name,overwrite =  keyword_set(no_clobber) eq 0
   dt = systime(1) - t1
   tsize = total(rmt.size) / 2d^20
   dprint,dlevel=2,verbose=verbose,'Transferred ',tsize,' MBytes in ',dt,' seconds @ ',tsize/dt,' MB/sec'
   dprint,dwait=5,'Wait'
   rmt = file_info(serverdir+pathname)
   lcl = file_info(localdir +pathname)
endif
if rmt.exists and (lcl.size ne rmt.size) then begin
   dprint,dlevel=0,verbose=verbose,'Warning: Remote and Local versions of "',pathname,'" are different sizes'
endif

end
