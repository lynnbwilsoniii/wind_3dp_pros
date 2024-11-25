
;+
;FUNCTION:  root_data_dir
;PURPOSE:  Returns the root data directory used by numerous file retrieval procedures.
;     By default it returns either:
;          for unix:    '/disks/data/' if it exists,  '~/data/' otherwise
;          for Windows: 'c:/data/' if it exists; else 'e:/data/' if it exists,  else 'c:/data/' regardless.
;
;     These data sets can grow to very large size. These defaults are intended to allow multiple
;     users to share a common data directory system.
;
;     It is recommended that PC users create a separate partition (e:/data/) to store files so that
;     disk backups do not have to include these large (easily replaced) files.
;
;     On unix systems, it is recommended to create a common directory with global write permission
;     that multiple users can share. This will reduce internet traffic and disk storage requirements for users
;     that use common data files.
;
;CHANGING THE DEFAULT:
;     The default directory can be changed by creating an environment variable: 'ROOT_DATA_DIR'
;     Example 1:
;          setenv,'ROOT_DATA_DIR=/mydata/'
;     Example 2:  A temporary directory:
;          setenv,'ROOT_DATA_DIR=' + getenv('IDL_TMPDIR') + 'data/'     ;  trailing '/' IS required.
;     If the value of the environment variable ROOT_DATA_DIR is a list of directories, then the first
;     existing directory is returned.
;
;     Notes:
;     1)  The environment variable should be set prior to running initialization routines (put it in your IDL_STARTUP file)
;     2)  The trailing '/' is required!    PC users should also use '/'   (not backslash: '\')
;     3)  The total size of all files can grow immense and there is no need to back them up.
;            We suggest placing them on a partition that is not backed up
;     4)  File storage space can be shared with other users if a commonly accessible data directory is chosen.
;     5)  Use a temporary directory if you do not want to permanently store these cached files.
;     6)  The root data directory should be writable by all.
;
;This routine is called by:
;    wind_init
;    istp_init
;    stereo_init
;    lanl_spa_load
;    thm_config (through thm_init)
;
;
;$LastChangedBy: adrozdov $
;$LastChangedDate: 2018-01-10 17:03:26 -0800 (Wed, 10 Jan 2018) $
;$LastChangedRevision: 24506 $
;$URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/misc/root_data_dir.pro $
;-


function root_data_dir,verbose=verbose


  common root_data_dir_com, rootdir,last_warning_time
  def_root = getenv('ROOT_DATA_DIR')
  if not keyword_set(def_root) then begin   ;  Determine default directory.
       homedir = (file_search('~',/expand_tilde))[0]+'/'
       case !version.os_family of
        'Windows': def_root = 'c:/data/;e:/data/;'+homedir+'data/;c:/data/'         ; Use c: if it exists ; else use e: if it exists ; else use c: regardless
        'unix' : def_root = '/disks/data/:'+homedir+'data/'
         else :  def_root = getenv('IDL_TMPDIR')+'data/'
       endcase
       if not keyword_set(last_warning_time) then last_warning_time = 1
  endif else last_warning_time = 0

  rootdirs = strsplit(def_root,path_sep(/search_path),/extract ,count=n )
  for i=0,n-1 do begin
      rootdir = rootdirs[i]
      if file_test(/direc,rootdir) then break
  endfor
  ;if not keyword_set(rootdir) then rootdir = getenv('IDL_TMPDIR')+'data/'

  if keyword_set(last_warning_time) && (systime(1) - last_warning_time) gt 3600  then begin           ; Display message only once every hour
;      beep
      dprint,verbose=verbose,'Warning: No Root Data Directory has been defined! Using default: "'+rootdir+'" (Which might change in the future!)'
      stack = scope_traceback(/structure)
      proc = stack[n_elements(stack)-1]
      dprint,verbose=verbose,'To define the Root Data Directory, see documentation in '+proc.filename
      last_warning_time = systime(1)
  endif
  if strlen(rootdir) gt 0 && strmid(rootdir, 0, 1, /reverse_offset) ne path_sep() then rootdir = rootdir + path_sep()
  return,rootdir
end


