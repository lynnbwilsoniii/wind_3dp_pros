;+
;Function: tt2000_config_filedir.pro
;Purpose: Get the applications user directory for TT2000 leapsecond table
;
;$LastChangedBy: pcruce $
;$LastChangedDate: 2012-04-18 15:14:40 -0700 (Wed, 18 Apr 2012) $
;$LastChangedRevision: 10350 $
;$URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/trunk/CDF/TT2000/tt2000_config_filedir.pro $
;-
Function tt2000_config_filedir, app_query = app_query, _extra = _extra

  readme_txt = ['Directory for configuration files for use by ', $
                'TT2000 CDF read code']

  If(keyword_set(app_query)) Then Begin
    tdir = app_user_dir_query('tt2000', 'tt2000_config', /restrict_os)
    If(n_elements(tdir) Eq 1) Then tdir = tdir[0] 
    Return, tdir
  Endif Else Begin
    Return, app_user_dir('tt2000', 'TT2000 Configuration Process', $
                         'tt2000_config', $
                         'tt2000 configuration Directory', $
                         readme_txt, 1, /restrict_os)
  Endelse

End