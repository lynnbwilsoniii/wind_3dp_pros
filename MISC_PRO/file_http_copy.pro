 ;+
 ;  WARNING: the interface to this routine is not yet solidified. Use the wrapper routine:
 ;  file_retrieve instead. This routine is still under development.
 ;
 ; NAME:
 ;    file_http_copy
 ;
 ; PURPOSE:
 ;    Downloads file(s) from http servers.
 ;    Also performs Searches without download.
 ;    Copies the file to a user specified local directory.
 ;    By default, files are only downloaded if the remote file is newer than
 ;    the local file (based on mtime) or if the files differ in size.
 ;    This routine is intended for use with simple HTTP file servers.
 ;    Wildcard matching and recursive file searching can be used as well.
 ;
 ; CALLING SEQUENCE: There are two methods:
 ; Method 1:
 ;    FILE_HTTP_COPY, pathnames, SERVERDIR=serverdir, LOCALDIR=localdir
 ;    where:
 ;      pathnames = (input string(s), scalar or array)  Relative path name of file to download.;
 ;      serverdir = (scalar input string)  Root name of source URL, must
 ;                                         begin with: 'http://' and end with '/'
 ;      localdir  = (scalar input string)  Root name of local directory, typically
 ;                                         ends with '/'
 ;    Note:   The source is at:    serverdir + pathnames
 ;            The destination is:  localdir + pathnames
 ; Method 2:
 ;    FILE_HTTP_COPY, URL
 ;       URL = full URL(S) of source file
 ;       Directory structure is not retained with this call method
 ;
 ; Example:
 ;    FILE_HTTP_COPY, 'ssl_general/misc/file_http_copy.pro',  $
 ;              SERVERDIR='http://themis.ssl.berkeley.edu/data/themis/socware/bleeding_edge/idl/' $
 ;              localdir = 'myidl/'
 ;
 ;    Note: Unix style directory separaters '/' should be used throughout. This convention will 
 ;          work with WINDOWS.
 ;
 ; Alternate calling sequence:
 ;    FILE_HTTP_COPY,URL
 ;        where URL is an input (string) such as:  URL = '
 ;
 ; INPUTS:
 ;      URL - scalar or array string giving a fully qualified url
 ;
 ; OPTIONAL KEYWORDS:
 ;     NO_CLOBBER:   (0/1) Set this keyword to prevent overwriting local files.
 ;     NO_UPDATE:    (0/1) Set this keyword to prevent contacting the remote server to update existing files. Ignored with directory lists
 ;     IGNORE_FILESIZE: (0/1) Set this keyword to ignore file size when
 ;           evaluating need to download.   OCT 2015 - this keyword is effectively deprecated - file size is always ignored now.
 ;     NO_DOWNLOAD:  (0/1,2) Set this keyword to prevent file downloads (url_info
 ;           is still returned)
 ;     URL_INFO=url_info: (output) Named variable that returns information about
 ;           remote file such as modification time and file size as determined
 ;           from the HTML header. A zero is returned if the remote file is
 ;           invalid.
 ;     FILE_MODE= file_mode:     If non-zero, sets the permissions for downloaded files.
 ;     DIR_MODE = dir_mode:      Sets permissions for newly created directories
 ;                            (Useful for shared directories)
 ;     ASCII_MODE:  (0/1)   When set to 1 it forces files to be downloaded as ascii text files (converts CR/LF)
 ;                          Setting this keyword will force ignore_filesize keyword to be set as well because
 ;                          files will be of different sizes typically.
 ;     USER_PASS:    string with format:  'user:password' for sites that require Basic authentication. Digest authentication is not supported.
 ;     LINKS:   Set this keyword to a named variable in which to return the html links.
 ;     STRICT_HTML:  Only useful when extracting links. Set this keyword to enforce strict rules when searching for links (Much slower but more robust)
 ;     VERBOSE:      (input; integer) Set level of verboseness:   Uses "DPRINT"
 ;           0-nearly silent;  2-typical messages;  4: debugging info
 ;      PRESERVE_MTIME:  Uses the server modification time instead of local modification time.  This keyword is ignored
 ;        on windows machines that don't have touch installed. (No cygwin or GNU utils)
 ;        Note: The PRESERVE_MTIME option is experimental and highly platform
 ;        dependent.  Behavior may change in future releases, so use with
 ;        caution.
 ;
 ;
 ; Examples:
 ;   ;Download most recent version of this file to current directory:
 ;   FILE_HTTP_COPY,'http://themis.ssl.berkeley.edu/data/themis/socware/bleeding_edge/idl/ssl_general/misc/file_http_copy.pro'
 ;
 ; OPTIONAL INPUT KEYWORD PARAMETERS:
 ;       PATHNAME = pathname   ; pathname is the filename to be created.
 ;                If the directory does not exist then it will be created.
 ;                If PATHNAME does not exist then the original filename is used
 ;                and placed in the current directory.
 ;;
 ; RESTRICTIONS:
 ;
 ;     PROXY: If you are behind a firewall and have to access the net through a
 ;         Web proxy,  set the environment variable 'http_proxy' to point to
 ;         your proxy server and port, e.g.
 ;         setenv,  'http_proxy=http://web-proxy.mpia-hd.mpg.de:3128'
 ;         setenv,  'http_proxy=http://www-proxy1.external.lmco.com'
 ;
 ;               The URL *MUST* begin with "http://".
 ;
 ; PROCEDURE:
 ;     Open a socket to the webserver and download the header.
 ;
 ; EXPLANATION:
 ;     FILE_HTTP_COPY can access http servers - even from behind a firewall -
 ;     and perform simple downloads. Currently,
 ;     Requires IDL V5.4 or later on Unix or Windows, V5.6 on
 ;     Macintosh
 ;
 ; EXAMPLE:
 ;      IDL> FILE_HTTP_COPY,'http://themis.ssl.berkeley.edu/themisdata/thg/l1/asi/whit/2006/thg_l1_asf_whit_2006010103_v01.cdf'
 ;      IDL> PRINTDAT, file_info('thg_l1_asf_whit_2006010103_v01.cdf')
 ;      or
 ;
 ;
 ; MINIMUM IDL VERSION:
 ;     V5.4  (uses SOCKET)
 ; MODIFICATION HISTORY:
 ;   Original version:  WEBGET()
 ;     Written by M. Feldt, Heidelberg, Oct 2001 <mfeldt@mpia.de>
 ;     Use /swap_if_little_endian keyword to SOCKET  W. Landsman August 2002
 ;     Less restrictive search on Content-Type   W. Landsman   April 2003
 ;     Modified to work with FIRST image server-  A. Barth, Nov 2006
 ;   FILE_HTTP_COPY:   New version created by D Larson:  March 2007.
 ;     Checks last modification time of remote file to determine need for download
 ;     Checks size of remote file to determine need to download
 ;     Very heavily modified from WEBGET():
 ;   May/June 2007 - Modified to allow file globbing (wildcards).
 ;   July 2007   - Modified to return remote file info  (without download)
 ;   July 2007   - Modified to allow recursive searches.
 ;   August 2007 - Added file_mode keyword.
 ;   April  2008 - Added dir_mode keyword
 ;   Sep 2009    - Fixed user-agent
 ;   October 2015 - Major Overhaul
 ;       It was found that the previous version was not "Network Friendly"
 ;       The previous version would read the header from the 'GET' request and then make a quick decision whether to
 ;       continue the download based on remote file modification time and file size. If the local version was current
 ;       then the connection would be closed
 ;
 ; $LastChangedBy: nikos $
 ; $LastChangedDate: 2020-04-15 11:56:17 -0700 (Wed, 15 Apr 2020) $
 ; $LastChangedRevision: 28584 $
 ; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/misc/file_http_copy.pro $
 ; $Id: file_http_copy.pro 28584 2020-04-15 18:56:17Z nikos $
 ;-
 
 
 ; Function encode_url replaces
 ; the HTML URL encoding that starts with a % sign
 ; with regular charecters
 function encode_url, urln
   ; The list of posible URL encodings is very long,
   ; here we only include a few cases only
   ; This list should be expanded if needed
   ; Full list can be found at http://en.wikipedia.org/wiki/Percent-encoding
 
   str_replace, urln, "%24", "$"
   str_replace, urln, "%26", "&"
   str_replace, urln, "%27", "'"
   str_replace, urln, "%3F", "?"
   str_replace, urln, "%21", "!"
   str_replace, urln, "%20", " "
   
   return, urln
 end
 
 ; Function compare_urls compares two URLs and returns 1 if the are the same, 0 otherwise
function compare_urls, url1, url2
  result = 0
  
  ;_tmp, prevent modifying variable in the parent routine
  url1_tmp = encode_url(url1)
  url2_tmp = encode_url(url2)
  
  url1_tmp = strtrim(strlowcase(url1_tmp),2)
  url2_tmp = strtrim(strlowcase(url2_tmp),2)
  
  result = strcmp(url1_tmp, url2_tmp)
  
  return, result
end
 
 
 
;deprecated, see extract_html_links_regex pcruce 2013-04-09
;undeprecated  Davin Larson - October 2015
pro extract_html_links,s,links,ind, $   ; input: string  ;    output: links appended to array
  relative=relative,$   ; Set to return only relative links
  normal=normal , $     ; Set to return only normal links (without ? or *)
  no_parent_links=no_parent_links,  $ ;Set to the parent domain to automatically exclude backlinks to the parent directory
  strict_html=strict_html


  if keyword_set(strict_html) then begin          ;  sort of slow routine
    if n_params() eq 3 then      extract_html_links_regex,s,links,ind,relative=relative,normal=normal,no_parent_links=no_parent_links  $
    else                         extract_html_links_regex,s,links    ,relative=relative,normal=normal,no_parent_links=no_parent_links       ; Very SLOW for large numbers of links
;;    if debug(5,verbose) then stop
    return
  endif

  ;compile_opt  idl2,hidden

  p0 = strpos(strlowcase(s),'<a href="')
  if p0 ge 0 then begin
    p1 = strpos(s,'">',p0)
    if p1 ge p0+9 then begin
      link = strmid(s,p0+9,p1-p0-9)
      bad = strlen(link) eq 0
      if keyword_set(normal) then bad = (strpos(link,'?') ge 0) or bad
      if keyword_set(normal) then bad = (strpos(link,'*') ge 0) or bad
      if keyword_set(relative) then bad = (strpos(link,'/') eq 0) or bad   ; remove absolute links (which start with '/')
      if not bad then begin
        if n_params() eq 3 then   append_array,links, link,index=ind ,/fillnan  else  append_array,links ,link
      endif
    endif
  endif

end


 
 
 ;Procedure: extract_html_links_regex
 ;Purpose: subroutine to parse <a>(link) tags from html.  
 ;It is exclusively used to parse .remote-index.html files byt file_http_copy.
 ; 
 ;The _regex version of this routine is replacing the original version because 
 ;the old version made assumptions about the formatting of the .remote-index.html file
 ;that were dependent upon the type of web server that was producing the file.  We think that 
 ;these bugs took so long to show up because Apache servers are extremely common.
 ;Modification prompted so that file_http_copy can work more reliably rbspice & rb-emfisis
 ;New version: 
 ;#1 Handles html that doesn't place the href attribute exactly one space after the link tag
 ;#2 Handles cases where the server doesn't include newlines, or where multiple links are included per line of returned html by the server
 ;
 ;Inputs:
 ;s: An html string to be parsed.
 ;links: An empty string, or an array of strings from previous extract operation
 ;
 ;Outputs:
 ;links:  extracted links are concatenated onto the links argument provided as input and returned through this argument
 ;
 pro extract_html_links_regex,s,links_all,nlinks, $   ; input: string  ;    output: links appended to array
     relative=relative,$   ; Set to strip out everything but the filename from a link
     normal=normal,$       ; Set to links that don't have '*' or '?' (don't think this should every actually happen, but option retained just in case.
     no_parent_links=no_parent_links ;Set to the parent domain to automatically exclude backlinks to the parent directory
     
   compile_opt  idl2,hidden

   s_copy = s ;prevent modification of string
   
   ;this regex is a little tricky, most of the complexity is to prevent it from matching two links when it should match one
   ;e.g. It could match <a href="blah"></a><a href="blah"></a> instead of <a href="blah"> (matching between the first <a and the last >, rather than first & first)
   
   if keyword_set(normal) then begin
     ;match a string containing the following in order
     ;#1 "<a " 
     ;#2 zero or more characters that are not '<' or '>'
     ;#3 "href="
     ;#4 '"' (quotation mark)
     ;#5 0 or more characters that are not '"' '*' or '?'
     ;#6 '"' (quotation mark)
     ;#7 0 or more characters that are not '<' or '>'
     ;#8 The '>' character
     ;
     ;Other notes:
     ;#1 The () are not a part of the pattern.  They indicate that anything matching inside the parentheses is a captured sub-expression
     link_finder_regex='<a [^>^<]*href="([^"^*^?]*)"[^<^>]*>'
   endif else begin
     ;match a string containing the following in order
     ;#1 "<a " 
     ;#2 zero or more characters that are not '<' or '>'
     ;#3 "href="
     ;#4 '"' (quotation mark)
     ;#5 0 or more characters that are not '"'
     ;#6 '"' (quotation mark)
     ;#7 0 or more characters that are not '<' or '>'
     ;#8 The '>' character
     ;
     ;Other notes:
     ;#1 The () are not a part of the pattern.  They indicate that anything matching inside the parentheses is a captured sub-expression
     link_finder_regex='<a [^>^<]*href="([^"]*)"[^<^>]*>'
   endelse
   
   ;/subexp indicates that everything inside the () of the regex should be returned in the results so that they can be extracted
   pos = stregex(s_copy,link_finder_regex,/subexp,length=length,/fold_case)
   
   while pos[1] ne -1 do begin 
     
     link = strmid(s_copy,pos[1],length[1]) ; remove a copy of the link from the string
     
     s_copy = strmid(s_copy,pos[0]+length[0]) ; remove link from string, so that we can process the next string
        
     ;exclude parent links, if keyword set and domain provided
     if n_elements(no_parent_links) gt 0 then begin
       if file_http_is_parent_dir(no_parent_links,link) then begin
         link = ''
       endif
     endif
        
     if keyword_set(relative) then begin
       
       ;match a string containing the following in order
       ;#1 a "/"
       ;#2 one or more characters that are not "/"
       ;#3 one or more "/" characters
       ;#4 the end of the string
       rel_pos = stregex(link,'/[^/]+/?$',/fold_case)
       if rel_pos[0] ne -1 then begin
         link = strmid(link,rel_pos+1)
       endif
     endif
 
     append_array,links,link                     ;  Efficient as long as the array links has a small number of elements     
;     if strlen(link) gt 0 then begin
;       if strlen(links[0]) gt 0 then begin
;         links = [links,link]
;       endif else begin
;         links = [link]
;       endelse
;     endif
      
     pos = stregex(s_copy,link_finder_regex,/subexp,length=length,/fold_case)
   endwhile
   if n_params() eq 3 then append_array, links_all, links, index = nlinks,/fillnan   else   append_array,links_all,links
   
 end
 
 
 
 ;FUNCTION file_extract_html_links(filename,count)
 ;PURPOSE:  returns links within an html file on disk.
 ;Used by file_http_copy to extract link tags from locally cached version of html files. 
 ;INPUT:  filename: (string) valid filename
 ;OUTPUT:  count:  number of links found
 function file_extract_html_links,filename,count,verbose=verbose,no_parent_links=no_parent_links,STRICT_HTML=STRICT_HTML   ; Links with '*' or '?' or leading '/' are removed.
   
   count=0                                   ; this should only return the relative links.

;   if debug(4,verbose) then stop
   on_ioerror, badfile
   openr,lun,filename,/get_lun
   s=''
   links = ''
   while not eof(lun) do begin
     readf,lun,s     
    ; The REGEX version of this code typically takes about 2.5 times longer to run than the older code - is there a way to avoid having to use REGEX?
     ; extract_html_links_regex,s,links,/relative,/normal,no_parent_links=no_parent_links   ; 
       extract_html_links,s,links,ind,/relative,/normal,STRICT_HTML=STRICT_HTML,no_parent_links=no_parent_links  ; undeprecated - Davin Larson October 2015     ;deprecated, see extract_html_links_regex pcruce 2013-04-09
   endwhile
   free_lun,lun
   append_array,links,index = ind,/done      ; Truncate links array to appropriate length
   bad = strlen(links) eq 0
   w = where(bad eq 0,count)
;   if count ne 0 then begin
;     links = links[sort(links)]
;   endif
   dprint,verbose=verbose,dlevel=3,'Extracted '+strtrim(count,2)+' links from: '+filename
   return,count gt 0 ? links[w] : ''
   badfile:
   dprint,dlevel=1,verbose=verbose,'Bad file: '+filename
   return,''
 end
 
; Function: file_http_strip_domain
; Purpose: removes the domain(http://domain.whatever/) from html link, if present. Otherwise, returns string unmodified
; Inputs: 
;    s: The string to have domain removed
; Returns:
;    s: with domain removed
 
 function file_http_strip_domain,s
 
   compile_opt idl2,hidden
 
   ;match a string containing the following in order
   ;#1 the beginning of the string
   ;#2 "http://"
   ;#2 followed by one or more characters that are not "/"
   ;#3 followed by one "/"
   ;#4 followed by 0 or more characters of any type
   m = stregex(s,"^http://[^/]+/",length=l,/fold_case)
   
   if m[0] ne -1 then begin
     return, strmid(s,l)
   endif else begin
     return, s
   endelse
 
 end 
 
 ;Function: file_http_is_parent_dir
 ;Purpose: predicate function, checks whether the provided link is a parent to the current directory
 ;Inputs:
 ;  Current: Set to the full url for the current directory
 ;  Link: The link to be checked
 ;Returns: 
 ;  1: if link is to current's parent
 ;  0; if link is not to current's parent
 function file_http_is_parent_dir,current,link
 
   compile_opt idl2,hidden
   
   if n_elements(link) eq 0 then return,0
   if strlen(link) eq 0 then return,0
   
   ;match a string containing the following in order
   ;#1 the contents of the variable "link"
   ;#2 one or more characters that are not "/"
   ;#3 the "/" character
   ;#4 the end of the string
   
   ;Other notes:
   ;#1 link will always end in "/" if it is a directory.  So there is no need to specify it in the regex
   ;#2 strip domain will always return a string that does not begin with a "/" (relative link), so we add it back in
   return,stregex("/"+file_http_strip_domain(current),escape_string(link)+"[^/]+/$",/boolean,/fold_case)
   
 end
 
 function file_http_header_element,header,name
   res = strcmp(header,name,strlen(name),/fold_case)
   g = where(res, Ng)
   if Ng GT 0 then return,strmid(header[g[0]],strlen(name)+1)
   return,''
 end
 
 
 
 
 pro file_http_header_info,  Header, hi, verbose=verbose
   ;;
   ;; MIME type recognition
   ;
 
   ;  hi.url = url
   if strmid(hi.url,0,1,/reverse_offset) eq '/' then hi.directory=1
   hi.ltime = systime(1)
   if not keyword_set(header) then return  ;,hi
   
   hi.status_str = header[0]
   header0 = strsplit(/extract,header[0],' ')
   hi.status_code = fix( header0[1] )
   
   ; get server time (date)
   date = file_http_header_element(header,'Date:')
   if keyword_set(date) then hi.atime = str2time(date, informat = 'DMYhms') else hi.atime = hi.ltime
   hi.clock_offset = hi.atime - hi.ltime
   dprint,dlevel=6,verbose=verbose,'date=',date
   
   ; Look for successful return
   ;pos = strpos(strupcase(header[0]),'200 OK')
   hi.exists = hi.status_code eq 200 || hi.status_code eq 304
   ;  if hi.exists eq 0 then return
   
   hi.class = 'text'
   hi.type =  'simple'               ; in case no information found...
   hi.Content_Type = file_http_header_element(header,'Content-Type:')
   if keyword_set(hi.Content_Type) then begin
     hi.Class = (strsplit(hi.Content_Type, '/', /extract))[0]
     hi.Type = (strsplit(hi.Content_Type, '/', /extract))[1]
   ENDIF
   
   ; get file modification time
   last_modified = file_http_header_element(header,'Last-Modified:')
   hi.mtime = keyword_set(last_modified) ? str2time(last_modified, informat = 'DMYhms') : systime(1)
   dprint,dlevel=6,verbose=verbose,'last_modified=',last_modified
   
   ; Try to determine length
   len = file_http_header_element(header,'Content-Length:')
   if keyword_set(len) then  hi.size = long64(len)   else hi.size = -1
   
   return   ;,hi
 END
 

;subsequent block subsumed in more general solution, extract_html_links_regex (pcruce 2013-04-09)
; Function strip_sub_pathnames_from_link, link, sub_pathname, end_pathname
;   ;Kludge for links that come up with 'http' at the start, note that we
;   ;do this here and not in extract_html_links, because we are not sure
;   ;how the change will interact with the rest of the program. jmm,
;   ;11-oct-2012.
;   ;The appropriate link will be that which exists between sub_pathname
;   ;and end_pathname. Note that nothing happens if the link does not
;   ;begin with 'http'.
;   if(strmid(link, 0, 4) Ne 'http') then return, link
;   link_out = link
;   l_sub_pathname = strlen(sub_pathname) ;find the position of sub_pathname and end_pathname in the link
;   l_end_pathname = strlen(end_pathname)
;   if(l_sub_pathname Eq 0) then begin ;if there is no sub_pathname, then use file_basename
;     link_out = file_basename(link)
;   endif else begin
;     pos_sub_pathname = strpos(link, sub_pathname)
;     if(pos_sub_pathname Ne -1) then begin
;       link_out = strmid(link, pos_sub_pathname+l_sub_pathname)
;     endif else link_out = file_basename(link)
;   endelse
;   if(strlen(link_out) gt 0) then begin ;un-append end_pathname, if needed
;     if(l_end_pathname gt 0) then begin
;       pos_end_pathname = strpos(link_out, end_pathname)
;       if(pos_end_pathname Ne -1) then begin
;         if(pos_end_pathname eq 0) then link_out = '' $
;         else link_out = strmid(link_out, pos_end_pathname-1)
;       endif
;     endif
;   endif
;   
;   Return, link_out
; End
 
 PRO file_http_copy, pathnames, newpathnames, $
     recurse_limit=recurse_limit, $
     verbose=verbose, $            ; input:  (integer)  Set level of verbose output.  (2 is typical)
     serverdir=serverdir,  $       ; input:  (string) URL of source files: ie:  'http://themis.ssl.berkeley.edu/data/themis/'      ;trailing '/' is required
     localdir=localdir, $          ; input:  (string) destination directory i.e.:  'e:/data/themis/'        ;trailing '/' is required
     localnames=localname, $       ; output:  Downloaded filenames are returned in this variable
     file_mode=file_mode,  $       ; input: if non-zero, file permissions are set to this value. (use '666'o for shared files.)
     dir_mode=dir_mode,   $        ; input:   defines directory permissions for newly created directories  (use '777'o for shared directories)
     last_version=last_version, $
     min_age_limit=min_age_limit, $
     host=host, $                  ;input string: Used to define HOST in HTTP header
     user_agent=user_agent,   $    ; input string: Used to define user_agent in HTTP message.
     user_pass=user_pass,  $
     preserve_mtime=preserve_mtime,$  ; EXPERIMENTAL, highly platform dependent
     restore_mtime=restore_mtime, $   ; EXPERIMENTAL, highly platform dependent
     if_modified_since = if_modified_since, $
     ascii_mode = ascii_mode, $    ; input  (0/1)  Set this keyword to force downloaded files to be downloaded as ascii Text. (converts CR/LFs)
     no_globbing=no_globbing,  $
     no_clobber=no_clobber, $      ; input: (0/1)  set keyword to prevent overwriting existing files. (url_info is still returned however)
     archive_ext=archive_ext, $ ; input: set to ".ARC??" to rename older files instead of deleting them.
     archive_dir=archive_dir, $ ; input: set to "archive/" to move older files to sub directory archive/.
     no_update=no_update,   $      ; input: (0/1)  set keyword to prevent contacting remote server if file already exists.  
     update_after=update_after, $    ; input: opposite of no_update - Updates to files only occur if the system time is greater than this time.
     no_download=no_download, $    ; input: (0/1/2)  set keyword to prevent downloading files, Useful to obtain url_info only. Set to 2 to get names only.
     ignore_filesize=ignore_filesize, $    ; input: (0/1)  if set then file size is ignored when evaluating need to download.
     ignore_filedate=ignore_filedate, $    ; NOT YET OPERATIONAL! input: (0/1)  if set then file date is ignored when evaluating need to download.
     url_info=url_info_s,  $         ; output:  structure containing URL info obtained from the HTTP Header.
     progobj=progobj, $            ; This keyword is experimental - please don't count on it
     STRICT_HTML=STRICT_HTML, $
     progress=progress, $
     links=links2, $               ; Output: links are returned in this variable if the file is an html file
     get_links=get_links, $        ;  Set this keyword to enable the returning of html links in  files
     force_download=force_download, $  ;Allows download to be forced no matter modification time.  Useful when moving between different repositories(e.g. QA and production data)
     error = error
   ;;
   ;;
   ;; sockets supported in unix & windows since V5.4, Macintosh since V5.6
   tstart = systime(1)
   
   dprint,dlevel=5,verbose=verbose,'Start; $Id: file_http_copy.pro 28584 2020-04-15 18:56:17Z nikos $

   if n_elements(strict_html) eq 0 then begin
      strict_html = 1      ;  set to 1 to be robust,  set to 0 to be much faster
      dprint,verbose=verbose,dlevel=3,'STRICT_HTML is not set. Defaulting to: ',strict_html    
   endif

   if keyword_set(user_agent) eq 0 then begin
     swver = strsplit('$Id: file_http_copy.pro 28584 2020-04-15 18:56:17Z nikos $',/extract)
     if !version.release ge '7' then begin
      login_info = get_login_info()
      user = login_info.user_name+'@'+login_info.machine_name
     endif else begin
       user = getenv('USER')
       if ~user then user=getenv('USERNAME')
       if ~user then user=getenv('LOGNAME')     
     endelse
     user_agent =  strjoin(swver[1:3],' ')+' IDL'+!version.release + ' ' + !VERSION.OS + '/' + !VERSION.ARCH+ ' (' + user +')'
   endif


   request_url_info = arg_present(url_info_s)
   url_info_s = 0
;dprint,dlevel=3,verbose=verbose,no_url_info,/phelp
   if not keyword_set(localdir) then localdir = ''
   if not keyword_set(serverdir) then serverdir = ''
   
   dprint,verbose=verbose,dlevel=4,pathnames
   for pni=0L,n_elements(pathnames)-1 do begin
     localname=''
     links2 = ''
     download_file = 1
     
     url_info = {http_info, $
       url:'',  $            ; Full url of file
       io_error: 0,  $
       localname:'', $       ; local file name
       status_str:'', $
       status_code:0,  $
       content_type:'', $
       type:'', $            ; type of file
       class:'', $           ; Class
       exists: 0b,  $
       directory: 0b, $
       clock_offset: 0l, $   ; difference between server time and local time
       ltime: 0ll, $         ; Time when procedure was run
       atime: 0ll, $         ; server time at time of last access
       mtime: 0ll, $         ; last mod time of file
       size:  0ll $
       }
     ;url_info = 0
       
     if keyword_set(serverdir) then begin
       pathname = pathnames[pni]
       url = serverdir+pathname
     endif else begin
       url = pathnames[pni]
       pathname = file_basename(url)
       if strmid(url,0,1,/reverse_offset) eq '/' then pathname += '/'   ;add the '/' back on for directories
     endelse
     
     cgi_bin = strpos(url,'cgi-bin') gt 0
     
     if keyword_set(newpathnames) then begin
       no_globbing=1
       newpathname = newpathnames[pni]
     endif else newpathname = pathname
     
     if cgi_bin  && n_elements(no_globbing) eq 0 then no_globbing=1
     
     url_info.url = url
     url_info.ltime = systime(1)
     
     dprint,dlevel=4,verbose=verbose,/phelp,pathname
     dprint,dlevel=5,verbose=verbose,/phelp,serverdir
     dprint,dlevel=5,verbose=verbose,/phelp,localdir
     dprint,dlevel=5,verbose=verbose,/phelp,newpathname
     dprint,dlevel=5,verbose=verbose,/phelp,url
     indexfilename =  '.remote-index.html'
     
     globpos = min( uint( [strpos(pathname,'*'),strpos(pathname,'?'),strpos(pathname,'['),strpos(pathname,']')] ) )
     ;if using globbing, then read the server remote index file and extract the links
     if (~ keyword_set(no_globbing)) && globpos le 1000 then begin   ; Look for globbed  ([*?]) filenames
       dprint,dlevel=3,verbose=verbose,'Warning! Using Globbing!'
       slash='/'
       slashpos1 = strpos(pathname,slash,globpos,/reverse_search)
       sub_pathname = strmid(pathname,0,slashpos1+1)
       ; First get directory listing and extract links:  
       file_http_copy,sub_pathname,serverdir=serverdir,localdir=localdir,url_info=index, host=host ,ascii_mode=1 ,progress=progress, progobj=progobj $
            ,min_age_limit=min_age_limit,verbose=verbose,file_mode=file_mode,dir_mode=dir_mode,if_modified_since=if_modified_since,STRICT_HTML=STRICT_HTML $
            , links=links,/get_links, user_agent=user_agent ,user_pass=user_pass,error=error $
            , update_after=update_after ;, no_update=no_update  ;,preserve_mtime=preserve_mtime, restore_mtime=restore_mtime
       if keyword_set(error) then begin
          dprint,dlevel=1,verbose=verbose,'Error detected ',error 
          goto, final_quit
       endif
       dprint,dlevel=5,verbose=verbose,/phelp,links
              
       slashpos2 = strpos(pathname,slash,globpos)
       if slashpos2 eq -1 then slashpos2 = strlen(pathname)  ; special case for non-directories  (files)
       sup_pathname = strmid(pathname,0,slashpos2+1)
       end_pathname = strmid(pathname,slashpos2+1)
       
       w = where(strmatch(sub_pathname+links,sup_pathname),nlinks)
       if nlinks gt 0 then begin
         w = w[sort(links[w])]      ; sort in alphabetical order (needed for last_version keyword)
         dprint,dlevel=5,verbose=verbose,links[w],/phelp
         rec_pathnames = sub_pathname + links[w] + end_pathname
         dprint,dlevel=5,verbose=verbose,/phelp,sup_pathname
         dprint,dlevel=5,verbose=verbose,/phelp,end_pathname
         dprint,dlevel=5,verbose=verbose,/phelp,rec_pathnames
         if keyword_set(last_version) then begin
            i0 = (nlinks-last_version) > 0
            no_update_temp = keyword_set(no_update)  ; (last_version eq 2) or keyword_set(no_update)
         endif else begin
            i0=0L
            no_update_temp = keyword_set(no_update)
         endelse
         for i=i0,nlinks-1 do begin
           dprint,dlevel=4,verbose=verbose,'Retrieve link#'+strtrim(i+1,2)+' of '+strtrim(nlinks,2)+': '+ rec_pathnames[i]
           ; Recursively get files:
           file_http_copy,rec_pathnames[i],serverdir=serverdir,localdir=localdir, host=host  $
             , verbose=verbose,file_mode=file_mode,dir_mode=dir_mode, ascii_mode=ascii_mode,progress=progress, progobj=progobj  $
             , min_age_limit=min_age_limit, last_version=last_version, url_info=ui $
             , update_after = update_after  $
             , no_download=no_download, no_clobber=no_clobber, no_update=no_update_temp, archive_ext=archive_ext, archive_dir=archive_dir $
             , force_download=force_download,STRICT_HTML=STRICT_HTML $
             , ignore_filesize=ignore_filesize,user_agent=user_agent,user_pass=user_pass,if_modified_since=if_modified_since $
             , preserve_mtime=preserve_mtime, restore_mtime=restore_mtime, error=error
;           dprint,dlevel=5,verbose=verbose,/phelp,lns
           if not keyword_set(ui)  then message,'URL info error'
           if keyword_set(error) then goto, final_quit
           w2 = where(ui.exists ne 0,nw2)
           if nw2 ne 0 then uis  = keyword_set(uis)  ?  [uis,ui[w2]]   : ui[w2]  ; only include existing files
           dprint,dlevel=5,verbose=verbose,/phelp,localname
         endfor
         if keyword_set(uis) then url_info = uis
       endif else begin
         dprint,dlevel=2,verbose=verbose,'No files found matching: '+sup_pathname
       endelse
       goto, final
     endif             ;  End of globbed filenames
     
     ; Begin normal file downloads
     localname = localdir + newpathname
     
     if strmid(url,0,1,/reverse_offset) eq '/' then begin    ; Directories
       url_info.directory = 1
       localname = localname + indexfilename
     endif

     lcl = file_info(localname)
     url_info.localname = localname
     url_info.exists = -1   ; remote existence is not known!  (yet)


     if  keyword_set(no_download) && no_download eq 2 then begin
       dprint,dlevel=2,verbose=verbose,'Warning:  URL_INFO is not valid for: "'+url+'"'
;       url_info.localname = localname
;       url_info.exists = -1   ; remote existence is not known!
       goto, final     
     endif
     
     
     if keyword_set(no_update) && lcl.exists then begin
       dprint,dlevel=2,verbose=verbose,'Warning: Updates to existing file: "'+lcl.name+'" are not being checked!'
;       url_info.localname = localname
;       url_info.exists = -1   ; remote file existence is not known!
       if keyword_set(get_links) then begin
          links2 = file_extract_html_links(localname,verbose=verbose,no_parent=url,strict_html=strict_html)         ; Does this belong here?  this might be producing unneeded work
       endif
       goto, final
     endif

     if keyword_set(update_after) && lcl.exists && (systime(1) lt time_double(update_after)) then begin
       dprint,dlevel=2,verbose=verbose,'Warning: Updates to existing file: "'+lcl.name+'" will not be checked until '+time_string(update_after,/local_time)+ ' LT'
       if keyword_set(get_links) then begin
         links2 = file_extract_html_links(localname,verbose=verbose,no_parent=url,strict_html=strict_html)         ; Does this belong here?  this might be producing unneeded work
       endif
       goto, final
     endif

     
     if lcl.exists eq 1 and lcl.write eq 0 then begin
       dprint,dlevel=2,verbose=verbose,'Local file: '+lcl.name+ ' exists and is write protected. Skipping.'
;       url_info.localname = localname
;       url_info.exists = -1   ; existence is not known!
       if keyword_set(get_links) then begin
           links2 = file_extract_html_links(localname,verbose=verbose,no_parent=url,strict_html=strict_html)     ; Does this belong here?
       endif
       goto, final
     endif

     
     ;Warning: The file times (mtime,ctime,atime) can be incorrect (with Windows) if the user has (recently) changed the time zone the computer resides in.
     ;This can lead to unexpected results.
     file_age = tstart-lcl.mtime
     if file_age lt (keyword_set(min_age_limit) ? min_age_limit : 0) then begin
       dprint,dlevel=3,verbose=verbose,'Found recent file ('+strtrim(long(file_age),2)+' secs): "'+localname+'" (assumed valid)'
       ;url_info.ltime = systime(1)
;       url_info.localname = localname
;       url_info.exists = 1
       if keyword_set(get_links) then begin
           links2 = file_extract_html_links(localname,verbose=verbose,no_parent=url,strict_html=strict_html)
           dprint,/phelp,dlevel=4,verbose=verbose,links2
       endif
       goto, final
     endif

     lcl_part = file_info(localname+'.part')
     if lcl_part.exists and lcl_part.mtime gt (systime(1) - 60) then begin
       dprint,dlevel=1,verbose=verbose,'File: '+localname+' is in the process of being downloaded by another process. Download request is aborted.'
;       url_info.localname = localname
;       url_info.exists = -1   ; remote file existence is not known!
       if keyword_set(get_links) then begin
         links2 = file_extract_html_links(localname,verbose=verbose,no_parent=url,strict_html=strict_html)         ; Does this belong here?  this might be producing unneeded work
       endif
       download_file = 0
       goto, final
     endif

     
     if download_file eq 0 then begin
;       url_info.localname = localname
;       url_info.exists = 1
       if keyword_set(get_links) then begin
         links2 = file_extract_html_links(localname,verbose=verbose,no_parent=url,strict_html=strict_html)
         dprint,/phelp,dlevel=3,verbose=verbose,links2
       endif
       goto, final
     endif
     
     
if 0 then begin
    dprint,url,localname
    ;file_download, url,localname
  
endif else begin     
     ;;
     ;; open the connection and request the file
     ;;
     read_timeout = 30
     connect_timeout = 5
     t_connect = systime(1)
;     if debug(4,verbose) then stop
     
     if keyword_set(referrer) and size(/type,referrer) ne 7 then begin
       stack = scope_traceback(/structure)
       referrer = stack.routine + string(stack.line,format='("(",i0,")")')
       referrer = strjoin(referrer,':')
     endif
     
     ;  filemodtime = lcl.mtime
     
     Proxy = getenv('http_proxy')
     IF Proxy NE '' THEN BEGIN    ; sort out proxy name
       dprint,dlevel=1,verbose=verbose,'Using Proxy: ',proxy
       Server = strmid(proxy, 7 )
       Purl = url
     ENDIF ELSE BEGIN    ; Without proxy
       slash1 = StrPos(strmid(url, 7, StrLen(url)), '/')
       Server = StrMid(url, 7, slash1 )
       purl = strmid(url,slash1+7, StrLen(url))
     ENDELSE
     
     lastcolon = strpos(server,':', /reverse_search)
     if lastcolon gt 1 then begin
       port = fix(strmid(server,lastcolon+1)  )
       server = strmid(server,0,lastcolon)
     endif else port = 80
     
     dprint,dlevel=4,verbose=verbose,'Opening server: "',server, '" on Port: ',port
     if not keyword_set(server) then dprint,dlevel=0,verbose=verbose,'Bad server: "'+server+'"'
     dprint,dlevel=5,verbose=verbose,'If IDL hangs soon after printing this statement then it could be a problem with VPN on some versions of MacOS'
     socket, unit, Server,  Port, /get_lun,/swap_if_little_endian,error=error,$
       read_timeout=read_timeout,connect_timeout=connect_timeout
     if error ne 0 then begin
       If(n_elements(unit) Gt 0) Then free_lun, unit  ;jmm, 19-jun-2007 for cases where unit is undefined
       dprint,dlevel=0,verbose=verbose,'Error: '+strtrim(error,2)+'     Message: '+!error_state.msg
       dprint,dlevel=4,verbose=verbose,'Error code:',error,!error_state.code,' ',!error_state.sys_msg
       if error eq -292 then dprint,dlevel=1,verbose=verbose,"It appears that the server "+server+" is down."
       if error eq -291 then dprint,dlevel=1,verbose=verbose,"Do you need to set a proxy server?  (i.e. setenv,'http_proxy=www.proxy-example.com')"
       if error eq -290 then dprint,dlevel=1,verbose=verbose,"Are you connected to the internet?"
       if error eq -297 then dprint,dlevel=1,verbose=verbose,"Is your internet connection working correctly?"
       if error eq -298 then dprint,dlevel=1,verbose=verbose,"Connection refused. Do you need to provide a password?"
       goto, final_quit
     endif
     dprint,dlevel=4,verbose=verbose,'Purl= '+purl     
     ; printf, unit, 'GET '+purl +  ' HTTP/1.0'
     get_str = 'GET '+purl +  ' HTTP/1.0'
     
     ; aaflores july-2012 Allow HOST keyword to overwrite default value
     if ~keyword_set(host) then host = server
     ; lphilpott may-2012 Add Host header to fix problem with site that have a permanent redirect
     ; printf, unit, 'Host: ' + host
     newline = string([13B, 10B])
     get_str += newline + 'Host: ' + host
     
     if keyword_set(user_agent) then begin
       ;printf, unit, 'User-Agent: '+user_agent
       get_str += newline + 'User-Agent: '+user_agent
       dprint,dlevel=4,verbose=verbose,'User Agent: '+user_agent
     endif
     if size(/type,referrer) eq 7 then begin
       ;printf, unit,  'Referer: '+referrer
       get_str += newline + 'Referer: '+referrer
       dprint,dlevel=4,verbose=verbose,'Referer: '+referrer
     endif
     if keyword_set(user_pass) then begin      
       ;printf, unit,  'Authorization: Basic '+ (strpos(user_pass,':') ge 0 ?  idl_base64(byte(user_pass)) : user_pass)
       get_str += newline + 'Authorization: Basic '+ (strpos(user_pass,':') ge 0 ?  idl_base64(byte(user_pass)) : user_pass)
       dprint,dlevel=4,verbose=verbose,'USER_PASS: '+user_pass
     endif
     
     if n_elements(if_modified_since) eq 0 then if_modified_since=1 
     if keyword_set(if_modified_since) then begin
       filemodtime = time_string(if_modified_since lt 2 ? lcl.mtime+1 : if_modified_since , tformat='DOW, DD MTH YYYY hh:mm:ss GMT' )       
       ;printf, unit, 'If-Modified-Since: '+filemodtime
       get_str += newline + 'If-Modified-Since: '+filemodtime
       dprint,dlevel=4,verbose=verbose,'If-Modified-Since: '+filemodtime
     endif
     get_str += newline + newline
     printf, unit, get_str 
     
     LinesRead = 0
     textstr = 'XXX'
     ;;
     ;; now read the header
     ;;
     On_IOERROR, done
     
     Header = strarr(256)
     WHILE  textstr NE '' do begin
       readf, unit, textstr
       Header[LinesRead] = textstr
       LinesRead = LinesRead+1
       IF LinesRead MOD 256 EQ 0 THEN $
         Header=[Header, StrArr(256)]
     ENDWHILE
     DONE: On_IOERROR, NULL
     ;;
     if LinesRead EQ 0 then begin
       free_lun, unit
       url_info.io_error = 1
       dprint,dlevel=0,verbose=verbose,!error_state.msg
       goto, final
     endif
     
     Header = Header[0:LinesRead-1]
     
     url_info.localname = localname     ; line is redundant - already performed
     file_http_header_info,header,url_info,verbose=verbose
     
     dprint,dlevel=4,verbose=verbose,'Server ',server,' Connect time= ',systime(1)-t_connect
     dprint,dlevel=5,verbose=verbose,'Header= ',transpose(header)
     dprint,dlevel=6,verbose=verbose,phelp=2,url_info
     
     if url_info.status_code eq 401 then begin                  ; Not authorized.
        dprint,dlevel=3,verbose=verbose,transpose(header)
        realm = file_http_header_element(header,'WWW-Authenticate:')
        prefix = keyword_set(user_pass) ? 'Invalid USER_PASS: "'+user_pass+'" for: '+realm  : 'keyword USER_PASS required for: '+realm
        dprint,dlevel=1,verbose=verbose,prefix+' Authentication Error: "'+url+'"'
        goto , close_server   
     endif
     
     if url_info.status_code eq 302 then begin     ; temporary redirect  (typically caused by user not logged into wi-fi)
        dprint,dlevel=3,verbose=verbose,transpose(header)
        dprint,dlevel=1,verbose=verbose,'Temporary redirect. Have you logged into WiFi yet?  "'+url+'"'
        goto , close_server
     endif 
     
     if url_info.status_code eq 301 then begin     ; Permanent redirect  (typically caused by server no longer supplying the files)
       dprint,dlevel=2,verbose=verbose,transpose(header)
       location = file_http_header_element(header,'Location:')
       dprint,dlevel=1,verbose=verbose,'Permanent redirect to: '+location
       dprint,dlevel=1,verbose=verbose,'Request Aborted'
       goto , close_server
     endif

     
     ; lphilpott may-2012 call redirect code for permanent redirects (301)
     if url_info.status_code eq 302 || url_info.status_code eq 301 then begin   ; Redirection
       location = file_http_header_element(header,'Location:')
       dprint,dlevel=1,verbose=verbose,'Redirection to: '+location
       if keyword_set(location) then begin
         if compare_urls(location, url_info.url) then begin ; if it redirects to self then exit
           dprint,dlevel=1,verbose=verbose,'Error! Redirects to self: '+location
           goto, close_server
         endif else begin  ; WARNING THIS SECTION OF CODE MIGHT BE INCOMPLETE BECAUSE RECURSIVE CALL IS MISSING MANY KEYWORDS !!!!
           dprint,'Warning:  Redirection may not work properly because not all keywords are set!'

           ; 2014-06-10 JWL  
           ; Removed 'host' keyword from recursive call when resolving HTTP
           ; 301/302 redirections.  It was erroneously sending the original
           ; 'host' parameter to the target of the redirection.

           file_http_copy,location,keyword_set(newpathnames) ? newpathname : '', $
             localdir=file_dirname(localdir+pathname)+'/',verbose=verbose, links=links2,/get_links,$  ; lphilpott may-2012 change localdir so that the final directory the file is saved to is the one intended
             ;localdir=localdir,verbose=verbose, $
             url_info=url_info, file_mode=file_mode,dir_mode=dir_mode, ascii_mode=ascii_mode,progress=progress, progobj=progobj,  $
             archive_ext=archive_ext, archive_dir=archive_dir, $
             user_agent=user_agent,user_pass=user_pass, if_modified_since=if_modified_since,STRICT_HTML=STRICT_HTML  ;,preserve_mtime=preserve_mtime,restore_mtime=restore_mtime              
           goto, close_server
         endelse
       endif
     endif
     
     if abs(url_info.clock_offset) gt 30 then $
       dprint,dlevel=1,verbose=verbose,'Warning! Remote and local clocks differ by:',url_info.clock_offset,' Seconds'
       
  
     if url_info.status_code eq 304 then begin   ;  Not modified since.   Connection will be closed by the server.
       dprint,dlevel=2,verbose=verbose,'Remote file: '+pathname +' not modified since '+filemodtime
       goto,  close_server      
     endif
     
     if url_info.status_code eq 400 then begin   ; Bad Request
       url_info.exists = 1
       localname = localname + '.400'
     endif
     
     if url_info.exists then begin
     
       ; Determine if download is needed
     
       tdiff = (url_info.mtime - lcl.mtime)  ; seconds old
       MB = 2.^20
       if lcl.exists then begin
         download_file = 0
         dprint,verbose=verbose,dlevel=6,'tdiff=',tdiff,' sec'
         if tdiff gt 0  then begin
           if keyword_set(no_clobber) then dprint,dlevel=1,verbose=verbose, format="('Warning!  ',f0.1,' day old local file: ',a  )", tdiff/24d/3600d, localname
           download_file = 1
         endif
         
         if tdiff lt 0 and keyword_set(restore_mtime) then  begin     ; Not working correctly becuause of .part extension
           dprint,dlevel=3,verbose=verbose,'File modification time mismatch. Restoring modification time.   ',lcl.name
           if keyword_set(preserve_mtime) and lcl.size eq url_info.size then begin  
             file_touch,lcl.name,url_info.mtime,/mtime,/no_create,verbose=verbose   ; ,toffset=time_zone_offset()
           endif
         endif
         
         if (lcl.size ne url_info.size) && (~ keyword_set(ascii_mode)) then begin     ; not working with if-modified-since keyword in use
           if keyword_set(no_clobber) then $
             dprint,dlevel=1,verbose=verbose,url_info.size/mb,lcl.size/mb, file_basename(localname), format='("Warning! Different file sizes: Remote=",f0.3," MB, Local=",f0.3," MB file: ",a)'
           if not keyword_set(ignore_filesize) then download_file = 1
         endif
         if keyword_set(no_clobber) then download_file=0
       endif else begin     ; endof lcl.exists
         download_file = 1
         dprint,dlevel=3,verbose=verbose,format="('Found remote (',f0.3,' MB) file: ""',a,'""')",url_info.size/mb,url
       endelse
       
       if keyword_set(no_download) then  download_file = 0
       if keyword_set(force_download) then download_file = 1
       if url_info.status_code ne 200 then begin
;         download_file = 0
         dprint,verbose=verbose,dlevel=1,'Unknown status code: '+string(url_info.status_code)
         dprint,verbose=verbose,dlevel=2,transpose(header)
       endif
;       if 1 then begin           ; this section moved forward  - should not occur
;         fi_part = file_info(localname+'.part')
;         if fi_part.exists and fi_part.mtime gt (systime(1) - 60) then begin
;           dprint,dlevel=1,verbose=verbose,'File: '+localname+' is in the process of being downloaded by another process. Request Aborted.'
;           download_file = 0
;         endif        
;       endif
       
       if download_file then begin    ;  begin file download
         dirname = file_dirname(localname)
         file_mkdir2,dirname,mode = dir_mode,dlevel=2,verbose=verbose
         On_IOERROR, file_error2
         openw, wunit, localname+'.part', /get_lun
         if keyword_set(file_mode) then file_chmod,localname+'.part',file_mode    ; chmod here in case download is aborted
         ts = systime(1)
         t0 = ts
         if keyword_set(ascii_mode) || url_info.size lt 0 || strmid(url_info.type,0,4) eq 'html'  then begin         ; download text file (typically these are directory listings
           dprint,dlevel=3,verbose=verbose,'Downloading "'+localname+'" as a text file.'
           lines=0ul
           while  eof(unit) EQ 0 do begin
             readf, unit, textstr
             printf, wunit, textstr
             dprint,dlevel=5,verbose=verbose,textstr
             if arg_present(links2) then begin
                extract_html_links,strict_html=strict_html,textstr,links2 ,/relative, /normal,no_parent=url
                dprint,/phelp,dlevel=6,verbose=verbose,links2
             endif
             dprint,dwait=5,dlevel=1,verbose=verbose,'Downloading "'+localname+'"  Please wait '+string( lines)+' lines'
             lines = lines +1
           endwhile
           dprint,dlevel=2,verbose=verbose,'Downloaded '+strtrim(lines,2)+' lines in '+string(systime(1)-ts,format='(f0.2)')+' seconds. File:'+localname
           dprint,/phelp,dlevel=3,verbose=verbose,links2
          ; if n_elements(links2) gt 1 then links2 = links2[1:*]   ; get rid of first ''
         endif else begin                                                      ; download Non-text (binary) files
           maxb = 2l^20   ; 1 Megabyte default buffer size
           nb=0l
           b=0l
           messstr=''
           while nb lt url_info.size do begin
             buffsize = maxb  <  (url_info.size-nb)
             aaa = bytarr(buffsize,/nozero)
             readu, unit, aaa
             writeu, wunit, aaa
             nb += buffsize
             t1 = systime(1)
             dt = t1-t0
             b += buffsize
             percent = 100.*float(nb)/url_info.size
;             dt1 = t11-t01
;             rate1 = b/mb/dt1
             if (dt gt 1.) and (nb lt url_info.size) then begin   ; Wait 10 seconds between updates.
               rate = b/mb/dt                             ; This will only display if the filesize (url_info.size) is greater than MAXB
               eta = (url_info.size-nb)/mb/rate +t1 - tstart
               messstr = string(format='("  ",f5.1," %  (",f0.1,"/",f0.1," secs)  @ ",f0.2," MB/s  File: ",a)', percent, t1-tstart,eta, rate,file_basename(localname) ,/print)
               t0 = t1
               b =0l
               if keyword_set(progress) then begin 
                  dprint,dlevel=2,verbose=verbose,messstr,dwait=10
       ;           wait,.01   ; not sure why this wait is here - I think it insure that output is made
               endif
;               if obj_valid(progobj)  then begin
;                 progobj->update,0.,text=messstr
;                 if progobj->checkcancel() then message,'Download cancelled by user',/ioerror
;               endif              
             endif
             if obj_valid(progobj) && progobj->checkcancel(messstr) then begin
               dprint,'Download Canceled by user',dlevel=0,verbose=verbose
               Message,'File Download Canceled',/ioerror               
             endif
           endwhile
           t1 = systime(1)
           dt = t1 - tstart
           messstr = string(/print,format = "('Downloaded ',f0.3,' MBytes in ',f0.1,' secs @ ',f0.2,' MB/s  File: ""', a,'""' )",nb/mb,dt,nb/mb/dt,localname )
           dprint,dlevel=2,verbose=verbose,messstr
           if obj_valid(progobj)  then begin
             progobj->update,0,text=messstr
           endif
         endelse
         free_lun, wunit    ; closes local file.
         if file_test(localname,/regular,/write) then begin
             file_archive,localname,archive_ext=archive_ext,archive_dir=archive_dir,verbose=verbose,dlevel=2   ; archive old version if either ARCHIVE_??? keyword is set
         endif
         file_move,localname+'.part',localname,/overwrite
         if 1 then begin    ;  for testing purposes
            if file_test(localname,/regular) eq 0 then begin
                dprint, dlevel=0,verbose=verbose,'RENAME did not work promptly!   '+localname
            endif
         endif
;         if keyword_set(file_mode) then file_chmod,localname,file_mode     ; this line moved earlier - safe to delete here.
         if keyword_set(preserve_mtime) then begin
              file_touch,localname,url_info.mtime,/mtime,/no_create,verbose=verbose  
         endif 
         if 0 then begin
           file_error2:
           dprint,dlevel=0,verbose=verbose,'Error downloading file: "'+url+'"'
           error = !error_state.msg
           dprint,dlevel=0,verbose=verbose,error
           if obj_valid(progobj)  then begin
             progobj->update,0.,text=error
           endif
           if keyword_set(wunit) then begin
              free_lun, wunit
              file_archive,localname+'.part',archive_ext='.error'
           endif
         ;                 dprint,dlevel=0,verbose=verbose,'Deleting: "' + lcl.name +'"'
         ;                 file_delete,lcl.name     ; This is not desirable!!!
         endif
       endif else begin
         dprint,dlevel=1,verbose=verbose,'Local file: "' + localname + '"  (Not downloaded).  Server '+server+' left hanging'
       endelse
     endif else begin
       dprint,dlevel=1,verbose=verbose,'Can not retrieve: "'+ url + '" '+header[0]
       dprint,dlevel=4,verbose=verbose,'Request Had Header: '
       dprint,dlevel=4,verbose=verbose, transpose(Header)
       dprint,dlevel=4,verbose=verbose,'If file was expected, you should verify that your anti-virus software did not block the connection and add an exception for IDL, if necessary'
       
     ;      url_info = 0
     endelse
     
     close_server:
     free_lun, unit
     dprint,dlevel=5,verbose=verbose,'Closing server: ',server
     
     
endelse     
     
     final:
     
     if keyword_set(recurse_limit) then begin    ; Recursive search for files.
     
       if keyword_set(index) then if index.localname ne localdir+indexfilename then links=''
       
       if not keyword_set(links) then begin   ; Get directory list
         file_http_copy,'',serverdir=serverdir,localdir=localdir, $
           min_age_limit=min_age_limit,verbose=verbose,no_update=no_update,progress=progress, progobj=progobj, $
           file_mode=file_mode,dir_mode=dir_mode,ascii_mode=1 , host=host, error=error, $
           url_info=index,links=links,/get_links,user_agent=user_agent,user_pass=user_pass,if_modified_since=if_modified_since,STRICT_HTML=STRICT_HTML   ;No need to preserve mtime on dir listings ,preserve_mtime=preserve_mtime
       endif
       wdir = where(strpos(links,'/',0) gt 0,ndirs)   ; Look in each directory for the requested file
       for i=0,ndirs-1 do begin
         dir = links[wdir[i]]
         file_http_copy,pathname,recurse_limit=recurse_limit-1,serverdir=serverdir+dir,localdir=localdir+dir $
           , verbose=verbose,file_mode=file_mode,dir_mode=dir_mode,ascii_mode=ascii_mode,progress=progress, progobj=progobj $
           , min_age_limit=min_age_limit, last_version=last_version, url_info=ui $
           , update_after = update_after $
           , no_download=no_download, no_clobber=no_clobber,no_update=no_update, archive_ext=archive_ext,archive_dir=archive_dir $
           , ignore_filesize=ignore_filesize,user_agent=user_agent,user_pass=user_pass, host=host $
           , preserve_mtime=preserve_mtime,restore_mtime=restore_mtime,if_modified_since=if_modified_since,STRICT_HTML=STRICT_HTML
         if not keyword_set(ui)  then message,'URL error  (this error should never occur)'
         w = where(ui.exists ne 0,nw)
         if nw ne 0 then url_info  = keyword_set(url_info)  ?  [url_info,ui[w]]   : ui[w]  ; only include existing files
       endfor
     endif
     
     ;  if keyword_set(url_info) then localname=url_info.localname else localname=''
     
     final2:
     if keyword_set(url_info_s) and keyword_set(url_info) then $
       url_info_s=[url_info_s,url_info] else url_info_s=url_info
       
   endfor
   
   if keyword_set(url_info_s) then localname=url_info_s.localname else localname=''
   dprint,dlevel=5,verbose=verbose,'Done'
   ;if n_elements(verbose) ne 0 then dprint,setdebug=last_dbg           ; Reset previous debug level.
   return
   final_quit:
     if keyword_set(url_info_s) and keyword_set(url_info) then $
       url_info_s=[url_info_s,url_info] else url_info_s=url_info
     dprint,dlevel=1,verbose=verbose,'Abnormal exit.  Aborting. Error:'+string(error)
   
   
 END
