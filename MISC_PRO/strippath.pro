;+
; FUNCTION:
;        STRIPPATH
;
; DESCRIPTION:
;
;       Function that strips off any directory components from a full
;       file path, and returns the file name and directory components
;       seperately in the structure:
;               {file_cmp_str,file_name:'file',dir_name:'dir'}
;       This is only implemented for UNIX at this time.
;
; USAGE (SAMPLE CODE FRAGMENT):
; 
;   ; find file component of /usr/lib/sendmail.cf
;       stripped_file = STRIPPATH('/usr/lib/sendmail.cf')
; 
;  The variable stripped_file would contain:
;
;       stripped_file.file_name = 'sendmail.cf'
;       stripped_file.dir_name  = '/usr/lib/'
;
;
; REVISION HISTORY:
;
;   $LastChangedBy: kenb-mac $
;   $LastChangedDate: 2006-12-15 08:13:48 -0800 (Fri, 15 Dec 2006) $
;   $LastChangedRevision: 97 $
;   $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/trunk/misc/strippath.pro $
;       Originally written by Jonathan M. Loran,  University of 
;       California at Berkeley, Space Sciences Lab.   Oct. '92
;   Updated to use IDL 6.0 features for cross-platform usability.
;
;-

FUNCTION strippath, full_path

file_comp= REPLICATE(                                                      $
        {file_cmp_str,file_name:'file',dir_name:'dir'}                     $
        ,N_ELEMENTS(full_path) )

; for each full_path given, get the file components

file_comp(*).file_name = FILE_BASENAME(full_path)
file_comp(*).dir_name = FILE_DIRNAME(full_path)

; return the file names found, being careful to keep scalers as scalers

IF N_ELEMENTS(file_comp) GT 1 THEN   RETURN, file_comp                      $
ELSE                                 RETURN, file_comp(0)

END
