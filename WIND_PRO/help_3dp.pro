;+
;PROCEDURE:	help_3dp
;PURPOSE:	Calls netscape and brings up our on_line help.  One of the pages
;		accessed by this on_line help provides documentation on all of
;		our procedures and is produced by"makehelp"
;INPUT:		none
;KEYWORDS:	
;	MOSAIC:	if set uses mosaic instead of netscape
;
;CREATED BY:	Jasper Halekas
;FILE:   help_3dp.pro
;VERSION:  1.7
;LAST MODIFICATION: 02/04/17
;-
pro help_3dp

if keyword_set(mosaic) then browser = 'Mosaic ' else browser = 'firefox '

;sourcedir = getenv('IDL_3DP_DIR')
;spawn, browser+sourcedir+'/help_3dp.html &'

command = "firefox http://sprg.ssl.berkeley.edu/~wind/idl/help_3dp.html"
spawn, command

end
