;+
; FUNCTION: FILE_RETRIEVE
; Purpose:
;  FILE_RETRIEVE provides a simple, transportable interface to retrieve data files.
;  It will download files from a remote web server and copy them into a local (cache) directory 
;  maintaining the original directory structure. It returns the list of local file names. 
;  By default files are only downloaded if the remote file is more recent. 
;  This routine is specifically designed to be used with the same file system that the web server is using to serve files.
;  It can look for a MASTER_FILE that indicates the master files system is in use and it then bypasses the download process. 
;  The file system can be a mix of directories that hold the original files being served as well as a copy of files from external servers.
;  The routine correctly handles multiple users sharing (and writing to) the same directories.
;  
;  Works on LINUX, MAC, and Windows 
;  
;Usage:
; files = file_retrieve(pathnames, [keyword options])
;
;Suggested usage:
;
;First get a default structure that specifies where the files come from and where they will be stored locally
;  source = file_retrieve(/default_structure,REMOTE_DATA_DIR='http://sprg.ssl.berkeley.edu/data/',master_file='maven/.master')
;  
;   ; Retrieve a MAVEN mag 1 sec resolution file for 2014-11-18
;  files = file_retrieve( 'maven/data/sci/mag/l2/sav/1sec/2014/11/mvn_mag_l2_pl_1sec_20141118.sav' ,_extra=source)  
;  
;    ; Retrieve an array of filenames within a time range:
;  files = file_retrieve( 'maven/data/sci/mag/l2/sav/1sec/YYYY/MM/mvn_mag_l2_pl_1sec_YYYYMMDD.sav',trange=['2014-12-30','2015-1-3'] ,_extra=source)  
;
;  
;    ; Retrieve "globbed files from the SPDF:    
;    ; A typical URL at SPDF is:  'http://spdf.sci.gsfc.nasa.gov/pub/data/wind/mfi/mfi_h0/2015/wi_h0_mfi_20151008_v03.cdf
;        The source of these files is given by:
;  source = file_retrieve(/default,  REMOTE_DATA_DIR='http://spdf.sci.gsfc.nasa.gov/pub/data/'  , LOCAL_DATA_DIR = root_data_dir()+'istp/'  )
;    ; The path specifiation is given by:  
;  pathname =      'wind/mfi/mfi_h0/YYYY/wi_h0_mfi_YYYYMMDD_v??.cdf'
;  files = file_retrieve(pathname, trange=['2014-12-25','2015-1-4'],_extra=source,/last_version)
;  
;  Subsequent calls will be much faster since the files will have been downloaded.
;  
;
;Arguments:
;    pathnames: String or string array with partial path to the remote file. 
;               (will be appended to remote_data_dir)
;    [newpathnames]: (optional) String or string array with partial path to file destination.
;                   (Will be appended to local_data_dir)  (NOT RECOMMENDED TO USE THIS OPTION.
;
;Keywords:
;    REMOTE_DATA_DIR:  String defining remote data directory
;                      Pathnames will be appended to this variable.
;    LOCAL_DATA_DIR:  String or string array w/ local data directory(s)
;                     If newpathnames is set it will be appended to this variable; if not, 
;                     pathnames will be appended. 
;    MASTER_FILE:     (file pathname)   if the file: LOCAL_DATA_DIR+MASTER_FILE exists then no download or contact with the server is made. (same effect as NO_SERVER - but evaluated at run time)
;    NO_SERVER:       Set this keyword to prevent any contact with a remote server.
;    
;    TRANGE:       One or two element array indicating the time range of interest.  If set, then PATHNAMES will be expanded into an array of pathnames using the special character sequences to translate:
;         YYYY, yy, MM, DD,  hh,  mm, ss, .f, DOY, DOW, TDIFF are special characters that will be substituted with the appropriate date/time field
;         Be especially careful of extensions that begin with '.f' since these will be translated into a fractional second.
;         See "time_string"  TFORMAT keyword for more info.
;         
;    LAST_VERSION:  If set, then only the last of multiple file versions is downloaded and returned. (used in conjuction with "globbed" pathnames and version numbers.)
;    
;    USER_PASS:   Username and password for secured systems;    USER_PASS='username:password'
;    ARCHIVE_EXT:  string;   Set archiving extension. (i.e.:  ARCHIVE_EXT= '.arc'). to rename old files instead of deleting them. Prevents accidental file deletion.
;    ARCHIVE_DIR:  string;   Set archiving subdirectory. (i.e.:  ARCHIVE_DIR = '.archive/')
;
;    VALID_ONLY:  Set this keyword to return only existing files.
;
;    PRESERVE_MTIME: if set, the local file will be given a modification time that is the same as the modification time of the remote server's file modification time.
;       This keyword is ignored on (windows) machines that don't have touch installed. (No cygwin or GNU utils)  Default is 1
;
;    VERBOSE:  Set Verbosity - 0 print almost nothing ,  2 is typical,  4 and above is for debugging.
;
;    if_modified_since:    Set to 0 to force download
;  user_agent:   String - User agent text to be sent to web server.
;  file_mode:   permissions for new files.   Default is '666'o  ; 
;  dir_mode:     permissions for newly created directories.  Default is '777'o  ;
;  progobj:     Experimental option for a progress bar widget.  (please ignore for now)
;  min_age_limit:   Files younger than this age (in seconds) are assumed current (avoids the need to recheck server)  Default is 300
;  no_download:0   ,      $    ; similar to NO_SERVER keyword. Should still allow remote directory retrieval - but not files.
;  no_update:0     ,      $    ; Set to 1 to prevent contact to server if local file already exists. (this is similar to no_clobber)
;  
;History: 
;    2012-6-25:  local_data_dir and remote_data_dir accept array inputs 
;                with the same # of elements as pathnames/newpathnames   -DO NOT USE this option!
;
;$LastChangedBy: davin-mac $
;$LastChangedDate: 2019-02-13 17:49:40 -0800 (Wed, 13 Feb 2019) $
;$LastChangedRevision: 26627 $
;$URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/misc/file_retrieve.pro $
;-


;  The following is a crude function to determine if the internet is available. 
; returns null string if no server can be reached
function server_available,servers,verbose=verbose
   if ~keyword_set(servers) then servers=['sprg.ssl.berkeley.edu','google.com','amazon.com','ssl.berkeley.edu']
   for i=0,n_elements(servers)-1 do begin
      server = servers[i]
      port = 80
      unit = 0
      socket, unit, Server,  Port, /get_lun,/swap_if_little_endian,error=error,read_timeout=5,connect_timeout=5
      dprint,dlevel=2,verbose=verbose,server,error  ;,!error_state.msg
      if keyword_set(unit) then free_lun,unit
      if ~keyword_set(error) then return,server
   endfor
   return,''
end


pro file_retrieve_reset_internet,delay=delay
  common file_retrieve_com, no_internet_until,wait_time
  if ~keyword_set(delay) then delay =-1
  no_internet_until = systime(1) + delay
end



function file_retrieve,pathnames, newpathnames, source=source, psource=psource, structure_format=structure_format,default_structure=default_structure,  $
    use_wget=use_wget, nowait=nowait, $
    local_data_dir=local_data_dir,remote_data_dir=remote_data_dir, $
    master_file=master_file,  $
    trange=trange,monthly_res=monthly_res,daily_res=daily_res,hourly_res=hourly_res,resolution=resolution,phase_shift=phase_shift, $
    min_age_limit=min_age_limit , $
    valid_only=valid_only,   $
    file_mode = file_mode,  $   ; permissions for new files. (if non-zero)
    dir_mode = dir_mode,   $   ; permissions for newly created directories.
    recurse_limit=recurse_limit, $
    user_agent=user_agent,   $
    user_pass=user_pass, $
    preserve_mtime=preserve_mtime,  $
    restore_mtime=restore_mtime, $
    ascii_mode=ascii_mode,   $
    strict_html=strict_html, $
    no_download=no_download,no_server=no_server, $
    no_update=no_update, $
    update_after = update_after, $
    if_modified_since=if_modified_since, $
    archive_ext=archive_ext, $
    archive_dir=archive_dir, $
    last_version = last_version , $
    oldversion_dir = oldversion_dir, $
    oldversion_ext = oldversion_ext, $
    force_download=force_download,$
    no_clobber=no_clobber, ignore_filesize=ignore_filesize, $
    verbose=verbose,progress=progress,progobj=progobj,links=links
    
common file_retrieve_com, no_internet_until,wait_time
if ~keyword_set(wait_time) then wait_time = 180
if ~keyword_set(no_internet_until) then no_internet_until = systime(1)-1.


dprint,dlevel=4,verbose=verbose,'Start; $Id: file_retrieve.pro 26627 2019-02-14 01:49:40Z davin-mac $'
if size(/type, local_data_dir)  ne 7 then local_data_dir = root_data_dir()

if keyword_set(structure_format)  && structure_format eq 1 then begin    ; Old version maintained for legacy code   - don't use this any more.
;   swver = strsplit('$Id: file_retrieve.pro 26627 2019-02-14 01:49:40Z davin-mac $',/extract)
;   user_agent =  strjoin(swver[1:3],' ')+' IDL'+!version.release + ' ' + !VERSION.OS + '/' + !VERSION.ARCH+ ' (' + (getenv('USER') ? getenv('USER') : getenv('USERNAME'))+')'
   if n_elements(user_agent) eq 0 then user_agent=''
   str= {   $
      retrieve_struct,       $
      init:0,                $
      local_data_dir:local_data_dir,  $ ;getenv('ROOT_DATA_DIR'),
      remote_data_dir:'',    $
      progress: 1    ,       $    ; Currently unused keyword   (progress is printed by default)
      user_agent:user_agent, $    ; User agent text to be sent to web server.
      file_mode:'666'o  ,    $    ; permissions for new files. (if non-zero)
      dir_mode: '777'o  ,    $    ; permissions for newly created directories.
      preserve_mtime: 1 ,    $    ; Set file modification to same as on file on server  (uses file_touch executable)
      progobj: obj_new(),    $    ; Experimental option for a progress bar widget.  (please ignore for now)
      min_age_limit: 300L  , $    ;   Files younger than this age (in seconds) are assumed current (avoids the need to recheck server)
      no_server:0     ,      $    ; Set to 1 to prevent any contact with a remote server.
      no_download:0   ,      $    ; similar to NO_SERVER keyword. Should still allow remote directory retrieval - but not files.
      no_update:0     ,      $    ; Set to 1 to prevent contact to server if local file already exists. (this is similar to no_clobber)
      no_clobber:0    ,      $    ; Set to 1 to prevent existing files from being overwritten. (A warning message will be displayed if remote server has)
      archive_ext:''  ,      $    ; Set archiving extension. (i.e.:  '.arc'). to rename old files instead of deleting them. Prevents accidental file deletion.
      archive_dir:''  ,      $    ; Set archiving subdirectory. (i.e.:  'archive/') 
      ignore_filesize:0 ,    $    ; Set to 1 to ignore the remote/local file sizes when determining if updates are needed.
      ignore_filedate:0 ,    $    ; Not yet operational.
      downloadonly:0  ,      $    ; Set to 1 to only download files but not load files into memory.
      use_wget:0          ,   $   ; Experimental option (uses the routine SSL_WGET instead of file_http_copy)
      nowait:0        ,      $    ; Used with wget to download files in the background.
      verbose:2 ,             $
      force_download: 0       $   ;Allows download to be forced no matter modification time.  Useful when moving between different repositories(e.g. QA and production data)
   }
   return, str
endif

if keyword_set(default_structure)  then begin     ; pathnames not provided -  return a default source structure
   if not keyword_set(psource) then psource = {   $
     local_data_dir:  local_data_dir,  $
     remote_data_dir:  size(/type,remote_data_dir) eq 7 ? remote_data_dir : '',    $
;    verbose:2 ,             $
     no_server:0    $           ; Set to 1 to prevent any contact with a remote server.
  }
  str_element,/add,psource,'MASTER_FILE',master_file
  str_element,/add,psource,'VERBOSE',verbose
  str_element,/add,psource,'MIN_AGE_LIMIT',min_age_limit
  str_element,/add,psource,'USER_PASS',user_pass
  str_element,/add,psource,'VALID_ONLY',valid_only
  return,psource
endif

if keyword_set(source) then return, file_retrieve(pathnames,newpathnames,_extra=source,links=links)


;if keyword_set(no_download) then no_server = no_download ; Leave this line commented out.  The keyword NO_SERVER is independent of the NO_DOWNLOAD keyword 
;if not keyword_set(local_data_dir) then   local_data_dir = './'
;if not keyword_set(remote_data_dir) then   remote_data_dir = ''
vb = keyword_set(verbose) ? verbose : 0
if n_elements(progress) eq 0 then progress=1

;if keyword_set(progress) then begin
;    progobj = obj_new('progressbar')
;endif


;  This section will generate filenames based on a time range (and time resolution defaults to 1 day)
if keyword_set(trange) then begin
  filenames = ''
  for i=0,n_elements(pathnames)-1 do begin
    pathnames_expanded = time_intervals(trange=trange,monthly_res=monthly_res,daily_res=daily_res,resolution=resolution,phase_shift=phase_shift,tformat=pathnames[i])
    num_pn = n_elements(pathnames_expanded)
    dprint,dlevel=(num_pn gt 1) ? 2 : 3,verbose=verbose,strtrim(num_pn,2)+' Pathnames expanded from "'+pathnames[i]+'" using TRANGE from: '+strjoin( time_string(trange) ,'  to: ')
    fns = file_retrieve(pathnames_expanded,local_data_dir=local_data_dir,remote_data_dir=remote_data_dir, $
      use_wget=use_wget, nowait=nowait, $
      min_age_limit=min_age_limit ,  valid_only=valid_only,   $
      file_mode = file_mode,  dir_mode = dir_mode,   $
      recurse_limit=recurse_limit, $
      user_agent=user_agent,    user_pass=user_pass, $
      preserve_mtime=preserve_mtime,   restore_mtime=restore_mtime, $
      ascii_mode=ascii_mode,     strict_html=strict_html, $
      no_download=no_download,no_server=no_server, $
      no_update=no_update, if_modified_since=if_modified_since, update_after=update_after, $
      archive_ext=archive_ext,  archive_dir=archive_dir, $
      last_version = last_version , $
      oldversion_dir = oldversion_dir,  oldversion_ext = oldversion_ext, $
      force_download=force_download,   no_clobber=no_clobber, ignore_filesize=ignore_filesize, $
      verbose=verbose,progress=progress,progobj=progobj)
    if keyword_set(fns) then append_array, filenames,fns
  endfor
  return,filenames
endif






;fullnames = filepath(root_dir=local_data_dir, pathnames)
fullnames = local_data_dir + pathnames   ; trailing '/' is recommended, but not required on local_data_dir
n0 = n_elements(fullnames)

if keyword_set(use_wget) and total(/preserv,strmatch(pathnames,'*[ \* \? \[ \] ]*') ) ne 0 then begin
     use_wget=0
     dprint,dlevel=1,verbose=verbose,'Warning! WGET can not be used with wildcards!'
endif


if keyword_set(remote_data_dir) &&  ~(keyword_set(no_server) || keyword_set(no_download) || ( (size(/type,master_file) eq 7) && file_test(local_data_dir+master_file)  ) ) then begin
  
  if systime(1) gt no_internet_until then begin

    if keyword_set(use_wget) then $
      ssl_wget,serverdir=remote_data_dir,localdir=local_data_dir,pathname=pathnames,verbose=verbose ,nowait=nowait $
    else begin
      ;Set some defaults that are really essential for proper working of the system: 
      if ~keyword_set(dir_mode) then dir_mode ='777'o
      if ~keyword_set(file_mode) then file_mode ='666'o
      if n_elements(min_age_limit) eq 0 then min_age_limit=300L   ;  Wait a reasonable time (5 minutes) before trying again
      if n_elements(progress) eq 0 then progress = 1  ;    Display progress on file downloads periodically
      if n_elements(preserve_mtime) eq 0 then preserve_mtime=1  ;   Set the local file modification time to the servers modification time
      
      http0 = strmid(remote_data_dir,0,7) eq 'http://'
      If obj_valid(progobj) Then progobj -> update, 0.0, text = string(format="('Retrieving ',i0,' files from ',a)",n0,remote_data_dir) ;jmm, 15-may-2007
      for i = 0l,n0-1 do begin
        fn = fullnames[i]
        pn = pathnames[i]
        npn = keyword_set(newpathnames) ? newpathnames[i] : ''

        ;2012-6-25: these variables may be single value or array   (Who made this change?  - Might not be consistent with other options/ methods!)
        ; error checks should probably be added to check # of elements between local_data_dir and
        ; remote_data_dir (if arrays), pathnames, and newpathnames
        http = n_elements(http0) gt 1 ? http0[i]:http0
        ldd = n_elements(local_data_dir) gt 1 ? local_data_dir[i]:local_data_dir
        rdd = n_elements(remote_data_dir) gt 1 ? remote_data_dir[i]:remote_data_dir

        ;         if keyword_set(no_update) and file_test(fn,/regular) then continue
        if http then begin
          file_http_copy,pn,npn,url_info=url_info,serverdir=rdd,localdir=ldd,verbose=verbose, $
            no_clobber=no_clobber,no_update=no_update, update_after=update_after , $
            ignore_filesize=ignore_filesize,progobj=progobj, progress=progress, $
            no_download = no_download, archive_ext=archive_ext,archive_dir=archive_dir,  $
            ascii_mode=ascii_mode,  recurse_limit=recurse_limit,   if_modified_since=if_modified_since, $
            user_agent=user_agent, user_pass=user_pass, strict_html=strict_html , $
            preserve_mtime = preserve_mtime, restore_mtime=restore_mtime, $
            file_mode=file_mode,dir_mode=dir_mode,last_version=last_version, $
            min_age_limit=min_age_limit,force_download=force_download, $
            error =error,links=links
            
          if keyword_set(error) then begin   
            dprint,dlevel=1,verbose=verbose,'Network Connection Error detected- Will use local copies only. ',error
            if ~server_available() then begin   ; This is a dangerous solution - Can't distiguish between "Remote server down" and "No connection to internet"
              no_internet_until = systime(1) + wait_time  
              dprint,dlevel=0,verbose=verbose,'Disabling checks of server for '+strtrim(wait_time,2)+' seconds'  
            endif 
            break
          endif
          if url_info[0].io_error ne 0 then begin
            dprint, "File or URL i/o error detected.  See !error_state for more info"
            printdat,!error_state
            return,''
          endif
        endif  else begin
          file_copy2,serverdir=remote_data_dir,localdir=local_data_dir,pathname=pn,verbose=verbose,no_clobber=no_update
        endelse
      endfor

    endelse

  endif else begin
    dprint,'No Internet available until '+time_string(no_internet_until,/local)+ ' Unable to check: '+remote_data_dir+pathnames[0]
  endelse
  
endif

; The following bit of code should find the highest version number if globbing is used.

fullnames2 = ''
for i=0,n_elements(fullnames)-1 do begin
   ff = file_search(fullnames[i],count=c)
   case c of
   0:    begin
           dprint,dlevel=3,verbose=vb,'No matching file: "'+fullnames[i]+'"'
           if ~keyword_set(valid_only) then append_array,fullnames2,fullnames[i]
         end
   1:    begin
           dprint,dlevel=3,verbose=vb,'Found: "'+ff[0]+'"'
;           fullnames[i] = ff[0]
           append_array,fullnames2,ff[0]
         end
   else: begin
           if keyword_set(last_version) then begin
;             dprint,dlevel=2,verbose=vb,strtrim(c,2)+' matches found for: "'+fullnames[i]+'"  Using last version.'
             dprint,dlevel=3,verbose=vb,'Using last version of '+strtrim(c,2)+' matches: '+ff[c-1]
             append_array,fullnames2,ff[c-1]
             file_archive,ff[0:c-2],verbose=verbose,archive_dir=oldversion_dir,archive_ext=oldversion_ext
           endif else begin
             dprint,dlevel=2,verbose=vb,strtrim(c,2)+' matches found for: "'+fullnames[i]+'"'
             append_array,fullnames2,ff
;             fullnames = ff
           endelse
         end
   endcase
endfor

   

return,fullnames2
end

