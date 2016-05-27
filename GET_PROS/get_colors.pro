
function get_color_indx,color

;if data_type(color) eq 7 then begin
;  case strmid(color,1,0) of
;  'r': vecs = [255,0,0]
;endif


tvlct,r,g,b,/get
vecs = replicate(1.,n_elements(r)) # reform(color)
tbl = [[r],[g],[b]]
d = sqrt( total((vecs-tbl)^2,2) )
m = min(d,bin)
return,byte(bin)
end


;+
;FUNCTION:    get_colors
;PURPOSE:   returns a structure containing color pixel values
;INPUT:    none
;KEYWORDS:   
;   NOCOLOR:  forces all colors to !d.table_size-1.   
;
;Written by: Davin Larson    96-01-31
;FILE: get_colors.pro
;VERSION:  1.2
;LAST MODIFICATION: 99/04/07
;-
function  get_colors,colors=cols,array=array,input
@colors_com

dt = data_type(input)

if dt ge 1 and dt le 5 then return,round(input)

magenta  = get_color_indx([1,0,1]*255)
red      = get_color_indx([1,0,0]*255)
yellow   = get_color_indx([1,1,0]*255)
green    = get_color_indx([0,1,0]*255)
cyan     = get_color_indx([0,1,1]*255)
blue     = get_color_indx([0,0,1]*255)
white    = get_color_indx([1,1,1]*255)
black    = get_color_indx([0,0,0]*255)

colors = [black,magenta,blue,cyan,green,yellow,red,white]
cols = colors

col = {black:black,magenta:magenta,blue:blue,cyan:cyan,green:green, $
  yellow:yellow,red:red,white:white}

if dt eq 7 then begin
  map = bytarr(256)+!p.color
  map[byte('xmbcgyrw')] = colors
  map[byte('XMBCGYRW')] = colors
  map[byte('0123456789')] = bindgen(10)
  map[byte('Dd')] = !p.color
  map[byte('Zz')] = !p.background
  cb = reform(byte(input))
  return,map[cb]
endif

if keyword_set(array) then return,colors else return,col

end




