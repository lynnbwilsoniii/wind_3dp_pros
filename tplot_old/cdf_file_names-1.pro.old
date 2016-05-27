pro cdf_file_names_index,name,info,set=set,get=get

common cdf_file_names_index_com,index

f = {indexformat,name:'',ptr:ptr_new()}

n = 0
i = -1
if size(/type,name) eq 7 and keyword_set(index) then  $
    i = (where(name eq index.name,n))[0]
if n ge 2 then message,'Error'

if keyword_set(set) then begin
   if keyword_set(info) then begin
     if n eq 0 then begin
        f.name = name
        f.ptr = ptr_new(info)
        index = keyword_set(index) ? [index,f] : [f]
     endif else begin
        *index[i].ptr = info
     endelse
   endif else begin           ; Delete
     if n ne 0 then begin
        ptr_free,index[i].ptr
        ni = where(name ne index.name,n)
        if n ne 0 then index=index[ni] else index=0        
     endif
   endelse
   return
endif

if keyword_set(get) then begin
   info = (n ne 0) ? *index[i].ptr : 0
   return
endif

if not keyword_set(index) then begin
   dprint,  'Nothing stored!'
   return
endif

if n_elements(name) eq 0 then begin
   dprint,  transpose(["'"+ index.name +"'"]) 
   return
endif

if i ge 0 then   printdat,index[i] else dprint, 'Name not found!'

end


pro file_YYYYMMDD_to_time,allfiles

  datepos = 16
    n = n_elements(allfiles)
    pos = strlen(allfiles.name)-datepos
    
    if n gt 1 then $
    	date = long(strmid(allfiles.name,transpose(pos),8)) $
    else date = long(strmid(allfiles.name,pos,8))

    t = replicate(time_struct(0d),n)
    t.year = date/10000
    date = date mod 10000
    t.month = date/100
    t.date = date mod 100
    allfiles.start= time_double(t)
  	
    st = sort(allfiles.start)
    allfiles = allfiles[st]
    allfiles.stop = allfiles.start + 86400d -1d
;    allfiles.stop = shift(allfiles.start,-1) - 1d
;    allfiles[n-1].stop = allfiles[n-1].start + 86400d - 1d

end


pro file_bartel_to_time,allfiles

  datepos = 12
    n = n_elements(allfiles)
    pos = strlen(allfiles.name)-datepos
    
    bartnum = long(strmid(allfiles.name,transpose(pos),4))

    allfiles.start= bartel_time(bartnum)
  	
    st = sort(allfiles.start)
    allfiles = allfiles[st]
    allfiles.stop = shift(allfiles.start,-1) - 1d
    allfiles[n-1].stop = allfiles[n-1].start + 27*86400d - 1d

end




;+
;FUNCTION: cdf_file_names
;PURPOSE:
;   Returns an array of filenames within a timerange.
;USAGE:
;   files=cdf_file_names(FORMAT,trange=trange,/verbose)
;INPUT:
;   FORMAT is a string that will be interpreted as one of two things:
;     CASE 1:  
;        e.g.    FORMAT = '/home/wind/dat/wi/3dp/k0/????/wi_k0_3dp*.cdf'
;        if FORMAT contains * or ? then filenames are returned that match that
;        pattern and for which YYYYMMDD falls within the specified timerange.
;        for example:  
;        (UNIX only)
;     CASE 2:
;        e.g.    FORMAT = 'fa_k0_ees_files'
;        The name of an indexfile that associates filenames with start and 
;        end times. If his file is not found, then the environment variable 
;        getenv('CDF_INDEX_DIR') is prepended and searched for.
;        See "make_cdf_index" for information on producing this file.
;     SPECIAL NOTE:
;        If strupcase(FORMAT) is the name of an environment varible. Then
;        the value of that environment variable is used instead.
;KEYWORDS:
;     TRANGE: 
;        Two element array specifying the time range for which data files should
;        be returned.  If not provided then "timerange" is called to provide
;        the time range.  See also "timespan".
;     NFILES:
;        Named variable that returns the number of files found.
;     VERBOSE:
;        Set to print some useful info.
;     FILEINFO:  OBSOLETE!
;        Set to a named variable that will return a table of file info.
;NOTES:
;     UNIX only!
;-
function cdf_file_names,format, pathname=pathname, use_master=use_master, $
  trange=trange,nfiles=n,fileinfo=fileinfo,reset=reset,verbose=verbose,$
  routine=routine
  
ts_ = systime(1)
tr=timerange(trange)

if keyword_set(fileinfo) then dprint,'FILEINFO keyword is obsolete'

mfileformat = {mfileformat, name:'',start:0d,stop:0d,len:0l}
n=0


if getenv('FILE_ENV_SET') ne '1' then setfileenv
  
if size(/type,format) ne 7 then begin
    dprint,'Input format must be a string'
    return,''
endif

if keyword_set(format) then begin
    envformat = getenv( strupcase(format) )
    if keyword_set(envformat) then begin
        if keyword_set(verbose) then $
           dprint, 'Environment variable: ',strupcase(format),' Found.'
    endif
    if not keyword_set(envformat) then envformat = format
    
    if keyword_set(use_master) then envformat = format 
    
    if strpos(envformat,'*') ge 0 or strpos(envformat,'?') ge 0 then begin
       pathname=envformat
       indexfile = 0
    endif else begin
       if file_test(envformat,/reg,/read) then begin
          pathname = envformat
          indexfile = 1    
       endif else begin
          envformat2 = filepath(envformat,root=getenv('CDF_INDEX_DIR'))
          if file_test(envformat2,/reg,/read) then begin
             pathname = envformat2
             indexfile=1
          endif else begin
             if keyword_set(verbose) then dprint, 'Using default path.'
             parts =  strsplit(envformat,/extr,'_')
             parts =  parts[[0,1,2]]
             pathname=getenv('BASE_DATA_DIR')+'/'+strjoin(parts,'/')+'/????/*.*'
             indexfile=0
;             message,/info,'Unable to determine PATHNAME for "'+format+'"'
;             return,''
          endelse
       endelse
    endelse
endif else begin
    dprint,'FORMAT must be set'
    return,''
endelse

cdf_file_names_index,format,fileinfo,/get

if keyword_set(fileinfo) then begin
    reset_time = 3600.*2
    allfiles=fileinfo.allfiles
    if fileinfo.indexfile  ne indexfile  then allfiles=0
    if fileinfo.pathname   ne pathname   then allfiles=0 
    if indexfile then begin
       openr,lun,pathname,/get_lun
       stat=fstat(lun)
       free_lun,lun
;       print,'File: ',time_string(stat.mtime)
;       print,'info: ',time_string(fileinfo.timestamp)
       if stat.mtime gt fileinfo.timestamp then begin
          if keyword_set(verbose) then dprint, 'Index file has been modified!'
          allfiles=0
       endif
    endif else begin
       if fileinfo.timestamp+reset_time lt ts_ then begin
          allfiles=0
          if keyword_set(verbose) then dprint, 'Timer elapsed, checking for more files.'
       endif
    endelse
    if keyword_set(reset) then allfiles=0
endif


if not keyword_set(allfiles) then begin
      
  datepos = 16
  if indexfile then begin
    if keyword_set(verbose) then dprint, "Searching for files in: indexfile='",pathname,"'"
    on_ioerror,bad_file
    openr,lun,pathname,/get_lun
;printdat,fstat(lun)
    mf = mfileformat
    while not eof(lun) do begin
       s = ''
       readf,lun,s
       ss = strsplit(s,/extract)
       ns = n_elements(ss)

       mf.start = time_double(ss[0])
       mf.stop  = time_double(ss[1])
       mf.name  = ss[2]
       mf.len   = (ns gt 3) ? long(ss[3]) : 0
       append_array,allfiles,mf,index=n
    endwhile
    append_array,allfiles,index=n,/done
    free_lun,lun
  endif else begin
    if keyword_set(verbose) then dprint, "Searching for files in: pathname='",pathname,"'"
    allfnames=file_search(pathname,count=n)  ; This is the time consuming call.
    if n eq 0 then begin
       dprint,'No files found in path: "'+pathname+'"'
       return,''
    endif
    allfiles = replicate(mfileformat,n)
    allfiles.name = allfnames
    
    if not keyword_set(routine) then begin
      if strpos(pathname,'bartel') ge 0 then routine='file_BARTEL_to_time' $
      else  routine='file_YYYYMMDD_to_time'
    endif
  
    call_procedure,routine,allfiles
    
  endelse
  
;search for and eliminate duplicate or earlier version files

  if n ge 2 then begin
    p = strpos(allfiles.name,'/',/reverse_search)
    fn1 = strmid(allfiles.name,transpose(p+1))
    st = sort(fn1)
    allfiles = allfiles[st]
    fn1=fn1[st]
    l = strlen(fn1)
    fn2 = strmid(fn1,0,transpose(l-datepos+8))
    dup = fn2 eq shift(fn2,-1)
    dup[n-1] = 0

    wdup = where(dup,ndup)
    if ndup ne 0 then begin
       if indexfile then dprint, 'The indexfile ',pathname,' has the following duplicate entries:' $
       else dprint, 'The following files are either duplicate or earlier version files and should be deleted:'
       dprint, allfiles[transpose(wdup)].name
    endif

    allfiles = allfiles[where(dup eq 0)]
    allfiles = allfiles[sort(allfiles.start)]
  endif
  fileinfo = {timestamp:ts_,pathname:pathname,indexfile:indexfile,allfiles:allfiles}
  if not keyword_set(allfiles) then fileinfo=0
endif 

cdf_file_names_index,format,fileinfo,/set

n = n_elements(allfiles) * keyword_set(allfiles)
if n eq 0 then begin
  dprint,'No matching files found!'
  return,''
endif

w = where(allfiles.stop ge tr[0] and allfiles.start lt tr[1]  ,n)
if n ne 0 then files=allfiles[w].name else files=''

n2=0
if n ne 0 then w = where( file_test(files) ,n2)

if n2 gt 0 then files = files[w] else files=''
n=n2

if keyword_set(verbose) then $
   dprint, n,' of ',n_elements(allfiles),' Files found in ',systime(1)-ts_ ,' seconds'

return,files
bad_file:
  dprint,'Unable to open index file: '+pathname
  return,''
end
