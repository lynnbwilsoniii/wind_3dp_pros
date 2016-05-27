;+
;PROCEDURE loadct2, colortable
;
;KEYWORDS:
;   FILE:  Color table file
;          Uses the environment variable IDL_CT_FILE to determine 
;          the color table file if FILE is not set.
;common blocks:
;   colors:      IDL color common block.  Many IDL routines rely on this.
;   colors_com:  
;See also:
;   "get_colors","colors_com","bytescale"
;
;Created by Davin Larson;  August 1996
;Version:           1.4
;File:              00/07/05
;Last Modification: loadct2.pro
;-


pro loadct2,ct,invert=invert,reverse=revrse,file=file
COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
@colors_com

deffile = getenv('IDL_CT_FILE')
if not keyword_set(file) and keyword_set(deffile) then file=deffile

black = 0
magenta=1
blue = 2
cyan = 3
green = 4
yellow = 5
red = 6
bottom_c = 7

loadct,ct,bottom=bottom_c,file=file

top_c = !d.n_colors-2
white =top_c+1
cols = [black,magenta,blue,cyan,green,yellow,red,white]
primary = cols[1:6]


tvlct,r,g,b,/get

if keyword_set(revrse) then begin
  r[bottom_c:top_c] = reverse(r[bottom_c:top_c])
  g[bottom_c:top_c] = reverse(g[bottom_c:top_c])
  b[bottom_c:top_c] = reverse(b[bottom_c:top_c])
endif

r[cols] = [0,1,0,0,0,1,1,1]*255b
g[cols] = [0,0,0,1,1,1,0,1]*255b
b[cols] = [0,1,1,1,0,0,0,1]*255b
tvlct,r,g,b

r_curr = r  ;Important!  Update the colors common block.
g_curr = g
b_curr = b

  ;force end colors  0 is black max is white
;tvlct,r,g,b,/get
;n = n_elements(r)
;lc = n-1
;black = 0
;white = 255
;if keyword_set(revrse) then begin
;  r = reverse(r)
;  g = reverse(g)
;  b = reverse(b)
;endif
;if keyword_set(invert) then begin
;  black = 255
;  white = 0
;endif
;r(0) = black & g(0)=black  & b(0)=black
;r(lc)=white  & g(lc)=white & b(lc)=white
;tvlct,r,g,b

end


