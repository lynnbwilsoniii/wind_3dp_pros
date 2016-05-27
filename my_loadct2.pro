pro my_loadct2,ct,file=file

COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

@my_colors2.pro  ;define the colors common block

deffile = GETENV('IDL_CT_FILE')
IF NOT KEYWORD_SET(file) AND KEYWORD_SET(deffile) THEN file = deffile

mdir     = FILE_EXPAND_PATH('')
IF NOT KEYWORD_SET(file) THEN BEGIN
  deffile = getenv('IDL_CT_FILE')
  IF KEYWORD_SET(deffile) THEN BEGIN
    file = deffile
  ENDIF ELSE BEGIN
    file = mdir[0]+'/wind_3dp_pros/my_colors.tbl'
  ENDELSE
ENDIF

black    = 0
magenta  = 1
blue     = 2
cyan     = 3
green    = 4
yellow   = 5
red      = 6
bottom_c = 7

LOADCT,ct,BOTTOM=bottom_c,FILE=file

top_c  = !D.N_COLORS - 1L    ;  get the top color index
top_c  = top_c - 1           ;  move back to make room for white
white  = top_c + 1           ;  white is beyond the top color

cols   = [black,magenta,blue,cyan,green,yellow,red,white]

TVLCT,r,g,b,/GET             ;  get the current colors

r[cols] = [0,1,0,0,0,1,1,1]*255b  ;  set up the lower/simple colors
g[cols] = [0,0,0,1,1,1,0,1]*255b
b[cols] = [0,1,1,1,0,0,0,1]*255b

TVLCT,r,g,b                  ;  and make it stick

r_curr = r                   ; Important!  Update the colors common block.
g_curr = g
b_curr = b

END
