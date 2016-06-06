;+
;*****************************************************************************************
;
;  FUNCTION :   color_setup_vectors.pro
;  PURPOSE  :   Returns the color strings and RGB values associated with those strings.
;
;  CALLED BY:   
;               get_color_by_name.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  08/25/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/25/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION color_setup_vectors

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
badstr_msg0    = 'Incorrect COLOR format [must be scalar string]...'

;; => Leave if no device set up
IF (STRLOWCASE(!D.NAME) EQ 'null') THEN RETURN,0b
;; => Get the Decomposed State
DEVICE,GET_DECOMPOSED=decomp
;; => On 24-bit displays, make sure color decomposition is ON.
IF ((!D.Flags AND 256) NE 0) THEN BEGIN
  DEVICE,GET_VISUAL_DEPTH=theDepth
  IF (theDepth GT 8) THEN BEGIN
    DEVICE,DECOMPOSED=1
    IF (theDepth EQ 24) THEN truecolor = 1 ELSE truecolor = 0
  ENDIF ELSE truecolor = 0
ENDIF ELSE BEGIN
   truecolor = 0
   theDepth  = 8
ENDELSE

IF (FLOAT(!VERSION.RELEASE) GE 6.4) AND (!D.NAME EQ 'Z') THEN DEVICE,GET_PIXEL_DEPTH=theDepth
;;----------------------------------------------------------------------------------------
;; => Set up device parameters
;;----------------------------------------------------------------------------------------
;; => Set up PostScript device for working with colors.
IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN DEVICE,COLOR=1,BITS_PER_PIXEL=8
;; => Load the colors from the current color table
IF (STRLOWCASE(!D.NAME) NE 'null') THEN TVLCT,rrr,ggg,bbb,/GET
;; Get the pixel value of the "opposite" color.  This is the pixel color
;;   opposite the pixel color in the upper right corner of the display.
IF ((!D.WINDOW GE 0) && ((!D.FLAGS AND 256) NE 0)) || (!D.NAME EQ 'Z') THEN BEGIN
  ;; => Get the screen dump. 2D image on 8-bit displays. 3D image on 24-bit displays.
  xstart         = !D.X_SIZE - 1L
  ystart         = !D.Y_SIZE - 1L
  ncols          = 1L
  nrows          = 1L
  opixel         = TVRD(xstart,ystart,ncols,nrows,TRUE=truecolor,ORDER=order)
  ;; Need to set color decomposition back?
  IF (theDepth GT 8) THEN DEVICE,DECOMPOSED=decomp
  IF (N_ELEMENTS(opixel) NE 3) THEN BEGIN
    opixel = [rrr[opixel], ggg[opixel], bbb[opixel]]
  ENDIF
ENDIF ELSE BEGIN
  ;; Need to set color decomposition back?
  IF (theDepth GT 8) THEN DEVICE,DECOMPOSED=decomp
  IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN opixel = [255,255,255] ELSE opixel = [0,0,0]
ENDELSE
IF (N_ELEMENTS(opixel) EQ 0) THEN opixel = [0,0,0]
bgcolor        = opixel
opixel         = 255 - opixel
;;----------------------------------------------------------------------------------------
;; => Set up the color vectors. Both original and Brewer colors.
;;----------------------------------------------------------------------------------------
colors= ['White']
rvalue = [ 255]
gvalue = [ 255]
bvalue = [ 255]
colors = [ colors,   'Snow',     'Ivory','Light Yellow', 'Cornsilk',     'Beige',  'Seashell' ]
rvalue = [ rvalue,     255,         255,       255,          255,          245,        255 ]
gvalue = [ gvalue,     250,         255,       255,          248,          245,        245 ]
bvalue = [ bvalue,     250,         240,       224,          220,          220,        238 ]
colors = [ colors,   'Linen','Antique White','Papaya',     'Almond',     'Bisque',  'Moccasin' ]
rvalue = [ rvalue,     250,        250,        255,          255,          255,          255 ]
gvalue = [ gvalue,     240,        235,        239,          235,          228,          228 ]
bvalue = [ bvalue,     230,        215,        213,          205,          196,          181 ]
colors = [ colors,   'Wheat',  'Burlywood',    'Tan', 'Light Gray',   'Lavender','Medium Gray' ]
rvalue = [ rvalue,     245,        222,          210,      230,          230,         210 ]
gvalue = [ gvalue,     222,        184,          180,      230,          230,         210 ]
bvalue = [ bvalue,     179,        135,          140,      230,          250,         210 ]
colors = [ colors,  'Gray', 'Slate Gray',  'Dark Gray',  'Charcoal',   'Black',  'Honeydew', 'Light Cyan' ]
rvalue = [ rvalue,      190,      112,          110,          70,         0,         240,          224 ]
gvalue = [ gvalue,      190,      128,          110,          70,         0,         255,          255 ]
bvalue = [ bvalue,      190,      144,          110,          70,         0,         255,          240 ]
colors = [ colors,'Powder Blue',  'Sky Blue', 'Cornflower Blue', 'Cadet Blue', 'Steel Blue','Dodger Blue', 'Royal Blue',  'Blue' ]
rvalue = [ rvalue,     176,          135,          100,              95,            70,           30,           65,            0 ]
gvalue = [ gvalue,     224,          206,          149,             158,           130,          144,          105,            0 ]
bvalue = [ bvalue,     230,          235,          237,             160,           180,          255,          225,          255 ]
colors = [ colors,  'Navy', 'Pale Green','Aquamarine','Spring Green',  'Cyan' ]
rvalue = [ rvalue,        0,     152,          127,          0,            0 ]
gvalue = [ gvalue,        0,     251,          255,        250,          255 ]
bvalue = [ bvalue,      128,     152,          212,        154,          255 ]
colors = [ colors, 'Turquoise', 'Light Sea Green', 'Sea Green','Forest Green',  'Teal','Green Yellow','Chartreuse', 'Lawn Green' ]
rvalue = [ rvalue,      64,          143,               46,          34,             0,      173,           127,         124 ]
gvalue = [ gvalue,     224,          188,              139,         139,           128,      255,           255,         252 ]
bvalue = [ bvalue,     208,          143,               87,          34,           128,       47,             0,           0 ]
colors = [ colors, 'Green', 'Lime Green', 'Olive Drab',  'Olive','Dark Green','Pale Goldenrod']
rvalue = [ rvalue,      0,        50,          107,        85,            0,          238 ]
gvalue = [ gvalue,    255,       205,          142,       107,          100,          232 ]
bvalue = [ bvalue,      0,        50,           35,        47,            0,          170 ]
colors = [ colors,     'Khaki', 'Dark Khaki', 'Yellow',  'Gold', 'Goldenrod','Dark Goldenrod']
rvalue = [ rvalue,        240,       189,        255,      255,      218,          184 ]
gvalue = [ gvalue,        230,       183,        255,      215,      165,          134 ]
bvalue = [ bvalue,        140,       107,          0,        0,       32,           11 ]
colors = [ colors,'Saddle Brown',  'Rose',   'Pink', 'Rosy Brown','Sandy Brown', 'Peru']
rvalue = [ rvalue,     139,          255,      255,        188,        244,        205 ]
gvalue = [ gvalue,      69,          228,      192,        143,        164,        133 ]
bvalue = [ bvalue,      19,          225,      203,        143,         96,         63 ]
colors = [ colors,'Indian Red',  'Chocolate',  'Sienna','Dark Salmon',   'Salmon','Light Salmon' ]
rvalue = [ rvalue,    205,          210,          160,        233,          250,       255 ]
gvalue = [ gvalue,     92,          105,           82,        150,          128,       160 ]
bvalue = [ bvalue,     92,           30,           45,        122,          114,       122 ]
colors = [ colors,  'Orange',      'Coral', 'Light Coral',  'Firebrick', 'Dark Red', 'Brown',  'Hot Pink' ]
rvalue = [ rvalue,       255,         255,        240,          178,        139,       165,        255 ]
gvalue = [ gvalue,       165,         127,        128,           34,          0,        42,        105 ]
bvalue = [ bvalue,         0,          80,        128,           34,          0,        42,        180 ]
colors = [ colors, 'Deep Pink',    'Magenta',   'Tomato', 'Orange Red',   'Red', 'Crimson', 'Violet Red' ]
rvalue = [ rvalue,      255,          255,        255,        255,          255,      220,        208 ]
gvalue = [ gvalue,       20,            0,         99,         69,            0,       20,         32 ]
bvalue = [ bvalue,      147,          255,         71,          0,            0,       60,        144 ]
colors = [ colors,    'Maroon',    'Thistle',       'Plum',     'Violet',    'Orchid','Medium Orchid']
rvalue = [ rvalue,       176,          216,          221,          238,         218,        186 ]
gvalue = [ gvalue,        48,          191,          160,          130,         112,         85 ]
bvalue = [ bvalue,        96,          216,          221,          238,         214,        211 ]
colors = [ colors,'Dark Orchid','Blue Violet',  'Purple']
rvalue = [ rvalue,      153,          138,       160]
gvalue = [ gvalue,       50,           43,        32]
bvalue = [ bvalue,      204,          226,       240]
colors = [ colors, 'Slate Blue',  'Dark Slate Blue']
rvalue = [ rvalue,      106,            72]
gvalue = [ gvalue,       90,            61]
bvalue = [ bvalue,      205,           139]
colors = [ colors, 'WT1', 'WT2', 'WT3', 'WT4', 'WT5', 'WT6', 'WT7', 'WT8']
rvalue = [ rvalue,  255,   255,   255,   255,   255,   245,   255,   250 ]
gvalue = [ gvalue,  255,   250,   255,   255,   248,   245,   245,   240 ]
bvalue = [ bvalue,  255,   250,   240,   224,   220,   220,   238,   230 ]
colors = [ colors, 'TAN1', 'TAN2', 'TAN3', 'TAN4', 'TAN5', 'TAN6', 'TAN7', 'TAN8']
rvalue = [ rvalue,   250,   255,    255,    255,    255,    245,    222,    210 ]
gvalue = [ gvalue,   235,   239,    235,    228,    228,    222,    184,    180 ]
bvalue = [ bvalue,   215,   213,    205,    196,    181,    179,    135,    140 ]
colors = [ colors, 'BLK1', 'BLK2', 'BLK3', 'BLK4', 'BLK5', 'BLK6', 'BLK7', 'BLK8']
rvalue = [ rvalue,   250,   230,    210,    190,    128,     110,    70,       0 ]
gvalue = [ gvalue,   250,   230,    210,    190,    128,     110,    70,       0 ]
bvalue = [ bvalue,   250,   230,    210,    190,    128,     110,    70,       0 ]
colors = [ colors, 'GRN1', 'GRN2', 'GRN3', 'GRN4', 'GRN5', 'GRN6', 'GRN7', 'GRN8']
rvalue = [ rvalue,   250,   223,    173,    109,     53,     35,      0,       0 ]
gvalue = [ gvalue,   253,   242,    221,    193,    156,     132,    97,      69 ]
bvalue = [ bvalue,   202,   167,    142,    115,     83,      67,    52,      41 ]
colors = [ colors, 'BLU1', 'BLU2', 'BLU3', 'BLU4', 'BLU5', 'BLU6', 'BLU7', 'BLU8']
rvalue = [ rvalue,   232,   202,    158,     99,     53,     33,      8,       8 ]
gvalue = [ gvalue,   241,   222,    202,    168,    133,    113,     75,      48 ]
bvalue = [ bvalue,   250,   240,    225,    211,    191,    181,    147,     107 ]
colors = [ colors, 'ORG1', 'ORG2', 'ORG3', 'ORG4', 'ORG5', 'ORG6', 'ORG7', 'ORG8']
rvalue = [ rvalue,   254,    253,    253,    250,    231,    217,    159,    127 ]
gvalue = [ gvalue,   236,    212,    174,    134,     92,     72,     51,     39 ]
bvalue = [ bvalue,   217,    171,    107,     52,     12,      1,      3,      4 ]
colors = [ colors, 'RED1', 'RED2', 'RED3', 'RED4', 'RED5', 'RED6', 'RED7', 'RED8']
rvalue = [ rvalue,   254,    252,    252,    248,    225,    203,    154,    103 ]
gvalue = [ gvalue,   232,    194,    146,     97,     45,     24,     12,      0 ]
bvalue = [ bvalue,   222,    171,    114,     68,     38,     29,     19,     13 ]
colors = [ colors, 'PUR1', 'PUR2', 'PUR3', 'PUR4', 'PUR5', 'PUR6', 'PUR7', 'PUR8']
rvalue = [ rvalue,   244,    222,    188,    152,    119,    106,     80,     63 ]
gvalue = [ gvalue,   242,    221,    189,    148,    108,     82,     32,      0 ]
bvalue = [ bvalue,   248,    237,    220,    197,    177,    163,    139,    125 ]
colors = [ colors, 'PBG1', 'PBG2', 'PBG3', 'PBG4', 'PBG5', 'PBG6', 'PBG7', 'PBG8']
rvalue = [ rvalue,   243,    213,    166,     94,     34,      3,      1,      1 ]
gvalue = [ gvalue,   234,    212,    189,    164,    138,    129,    101,     70 ]
bvalue = [ bvalue,   244,    232,    219,    204,    171,    139,     82,     54 ]
colors = [ colors, 'YGB1', 'YGB2', 'YGB3', 'YGB4', 'YGB5', 'YGB6', 'YGB7', 'YGB8']
rvalue = [ rvalue,   244,    206,    127,     58,     30,     33,     32,      8 ]
gvalue = [ gvalue,   250,    236,    205,    175,    125,     95,     48,     29 ]
bvalue = [ bvalue,   193,    179,    186,    195,    182,    168,    137,     88 ]
colors = [ colors, 'RYB1', 'RYB2', 'RYB3', 'RYB4', 'RYB5', 'RYB6', 'RYB7', 'RYB8']
rvalue = [ rvalue,   201,    245,    253,    251,    228,    193,    114,     59 ]
gvalue = [ gvalue,    35,    121,    206,    253,    244,    228,    171,     85 ]
bvalue = [ bvalue,    38,    72,     127,    197,    239,    239,    207,    164 ]
colors = [ colors, 'TG1', 'TG2', 'TG3', 'TG4', 'TG5', 'TG6', 'TG7', 'TG8']
rvalue = [ rvalue,  84,    163,   197,   220,   105,    51,    13,     0 ]
gvalue = [ gvalue,  48,    103,   141,   188,   188,   149,   113,    81 ]
bvalue = [ bvalue,   5,     26,    60,   118,   177,   141,   105,    71 ]
colors = [ colors, 'OPPOSITE', 'BACKGROUND']
rvalue = [ rvalue,  opixel[0],  bgcolor[0]]
gvalue = [ gvalue,  opixel[1],  bgcolor[1]]
bvalue = [ bvalue,  opixel[2],  bgcolor[2]]
;;----------------------------------------------------------------------------------------
;; => Define output structure
;;----------------------------------------------------------------------------------------
tags   = ['COLORS','RVALUE','GVALUE','BVALUE']
struc  = CREATE_STRUCT(tags,colors,rvalue,gvalue,bvalue)
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END

;+
;*****************************************************************************************
;
;  FUNCTION :   get_color_by_name.pro
;  PURPOSE  :   This routine returns the color determined by a string input name.  The
;                 available colors are:
;
;       Active            Almond     Antique White        Aquamarine             Beige
;       Bisque             Black              Blue       Blue Violet             Brown
;       Burlywood     Cadet Blue           Charcoal       Chartreuse         Chocolate
;       Coral           Cf. Blue           Cornsilk          Crimson              Cyan
;       D. Goldenrod     D. Gray           D. Green         D. Khaki         D. Orchid
;       D. Red         D. Salmon      D. Slate Blue        Deep Pink       Dodger Blue
;       Edge                Face          Firebrick     Forest Green             Frame
;       Gold           Goldenrod               Gray            Green      Green Yellow
;       Highlight       Honeydew           Hot Pink       Indian Red             Ivory
;       Khaki           Lavender         Lawn Green         L. Coral           L. Cyan
;       L. Gray        L. Salmon       L. Sea Green        L. Yellow        Lime Green
;       Linen            Magenta             Maroon          M. Gray         M. Orchid
;       Moccasin            Navy              Olive       Olive Drab            Orange
;       Orange Red        Orchid       P. Goldenrod         P. Green            Papaya
;       Peru                Pink               Plum      Powder Blue            Purple
;       Red                 Rose         Rosy Brown       Royal Blue      Saddle Brown
;       Salmon       Sandy Brown          Sea Green         Seashell          Selected
;       Shadow            Sienna           Sky Blue       Slate Blue        Slate Gray
;       Snow        Spring Green         Steel Blue              Tan              Teal
;       Text             Thistle             Tomato        Turquoise            Violet
;       Violet Red         Wheat              White           Yellow
;
;       D.  =  Dark
;       L.  =  Light
;       P.  =  Pale
;       M.  =  Medium
;       Cf. = Cornflower
;
;  CALLED BY:   
;               
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               COLOR  :  Scalar [string] that matches one of the color names given above
;                           [Note:  the case does not matter]
;
;  EXAMPLES:    
;               PRINT, get_color_by_name('Magenta')
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The input COLOR must match the entire name of the color, not the
;                     abbreviation used => for dark red, COLOR = 'Dark Red'
;
;   ADAPTED FROM: cgColor.pro  BY: David W. Fanning
;   CREATED:  08/25/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/25/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION get_color_by_name,color

;;----------------------------------------------------------------------------------------
;; => Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;; => Dummy error messages
badstr_msg0    = 'Incorrect COLOR format [must be scalar string]...'

;; => Leave if no device set up
IF (STRLOWCASE(!D.NAME) EQ 'null') THEN RETURN,0b
;; => Get the Decomposed State
DEVICE,GET_DECOMPOSED=decomp
;; => On 24-bit displays, make sure color decomposition is ON.
IF ((!D.Flags AND 256) NE 0) THEN BEGIN
  DEVICE,GET_VISUAL_DEPTH=theDepth
  IF (theDepth GT 8) THEN BEGIN
    DEVICE,DECOMPOSED=1
    IF (theDepth EQ 24) THEN truecolor = 1 ELSE truecolor = 0
  ENDIF ELSE truecolor = 0
ENDIF ELSE BEGIN
   truecolor = 0
   theDepth  = 8
ENDELSE

IF (FLOAT(!VERSION.RELEASE) GE 6.4) AND (!D.NAME EQ 'Z') THEN DEVICE,GET_PIXEL_DEPTH=theDepth
;;----------------------------------------------------------------------------------------
;; => Set up device parameters
;;----------------------------------------------------------------------------------------
;; => Set up PostScript device for working with colors.
IF (STRLOWCASE(!D.NAME) EQ 'ps') THEN DEVICE,COLOR=1,BITS_PER_PIXEL=8
;; => Load the colors from the current color table
IF (STRLOWCASE(!D.NAME) NE 'null') THEN TVLCT,rrr,ggg,bbb,/GET
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (SIZE(color,/TYPE) NE 7) OR (N_PARAMS() NE 1)
IF (test) THEN BEGIN
  ;; => no input???
  MESSAGE,badstr_msg0[0],/INFORMATIONAL,/CONTINUE
  ;; => Return "bad" value
  RETURN,0b
ENDIF
;; Remove underscores
thecolor       = STRJOIN(STRSPLIT(color[0],'_',/EXTRACT,/PRESERVE_NULL),' ')
;; Make sure the color is compressed and uppercase.
thecolor       = STRUPCASE(STRCOMPRESS(STRTRIM(color[0],2),/REMOVE_ALL))

bytecheck      = BYTE(theColor[0])
i              = WHERE(bytecheck LT 48, lessthan)
i              = WHERE(bytecheck GT 57, greaterthan)
test           = (lessthan + greaterthan) EQ 0
IF (test) THEN useCurrentColors = 1 ELSE useCurrentColors = 0
;;----------------------------------------------------------------------------------------
;; => Get color triplets
;;----------------------------------------------------------------------------------------
col_struc      = color_setup_vectors()
colors         = col_struc.COLORS
rvalue         = col_struc.RVALUE
gvalue         = col_struc.GVALUE
bvalue         = col_struc.BVALUE

IF (useCurrentColors) THEN BEGIN
  IF (decomp EQ 0) THEN BEGIN
    colors         = SINDGEN(256)
    rvalue         = rrr
    gvalue         = ggg
    bvalue         = bbb
  ENDIF ELSE BEGIN
    colors         = [colors, SINDGEN(256)]
    rvalue         = [rvalue, rrr]
    gvalue         = [gvalue, ggg]
    bvalue         = [bvalue, bbb]
  ENDELSE
ENDIF
;; Make sure we are looking at compressed, uppercase names.
colors         = STRUPCASE(STRCOMPRESS(STRTRIM(colors,2),/REMOVE_ALL))
;; How many colors do we have?
ncolors        = N_ELEMENTS(colors)
;; Check synonyms of color names.
CASE thecolor[0] OF
  'GREY'        : thecolor = 'GRAY'
  'LIGHTGREY'   : thecolor = 'LIGHTGRAY'
  'MEDIUMGREY'  : thecolor = 'MEDIUMGRAY'
  'SLATEGREY'   : thecolor = 'SLATEGRAY'
  'DARKGREY'    : thecolor = 'DARKGRAY'
  'AQUA'        : thecolor = 'AQUAMARINE'
  'SKY'         : thecolor = 'SKYBLUE'
  'NAVYBLUE'    : thecolor = 'NAVY'
  'CORNFLOWER'  : thecolor = 'CORNFLOWERBLUE'
  'BROWN'       : thecolor = 'SIENNA'
  ELSE          : thecolor = thecolor[0]
ENDCASE
;; Check for offset.
IF ((theDepth EQ 8) OR (decomp EQ 0))   THEN offset = !D.TABLE_SIZE - ncolors - 2 ELSE offset = 0
IF (useCurrentColors AND (decomp EQ 0)) THEN offset = 0
;;----------------------------------------------------------------------------------------
;; => Get the corresponding color index
;;----------------------------------------------------------------------------------------
IF (N_ELEMENTS(colorIndex) EQ 0) THEN BEGIN
  IF ((theDepth GT 8) AND (decomp EQ 1)) THEN BEGIN
    colorIndex = FIX(!P.COLOR < (!D.TABLE_SIZE - 1L))
  ENDIF ELSE BEGIN
    colorIndex = WHERE(colors EQ thecolor[0],count) + offset[0]
    colorIndex = FIX(colorIndex[0])
    IF (count EQ 0) THEN MESSAGE, 'Cannot find color: '+thecolor[0],/NONAME
  ENDELSE
ENDIF ELSE colorIndex = 0S > colorIndex < FIX(!D.TABLE_SIZE - 1L)
;; Find the asked-for color in the color names array.
theNames       = STRUPCASE(STRCOMPRESS(colors,/REMOVE_ALL))
theIndex       = WHERE(theNames EQ STRUPCASE(STRCOMPRESS(thecolor[0],/REMOVE_ALL)),foundIt)
;; If the color can't be found, report it and continue with the color set to "OPPOSITE."
IF (foundIt EQ 0) THEN BEGIN
  MESSAGE, "Can't find color "+thecolor[0]+". Substituting 'OPPOSITE'.", /INFORMATIONAL
  theColor = 'OPPOSITE'
  theIndex = WHERE(STRUPCASE(colors) EQ 'OPPOSITE')
ENDIF ELSE theIndex = theIndex[0]
;; Define the color triple for this color.
r              = rvalue[theIndex[0]]
g              = gvalue[theIndex[0]]
b              = bvalue[theIndex[0]]
;;----------------------------------------------------------------------------------------
;; => Define color index in byte form
;;----------------------------------------------------------------------------------------
IF (decomp) THEN BEGIN
  col   = [r[0], g[0], b[0]]
  ;; convert to the 24-bit long integer
  value = col[0] + (col[1] * 2L^8) + (col[2] * 2L^16)
ENDIF ELSE BEGIN
  IF ((!D.NAME NE 'PRINTER') AND (!D.NAME NE 'NULL')) THEN BEGIN
    TVLCT, rvalue[theIndex[0]], gvalue[theIndex[0]], bvalue[theIndex[0]], colorIndex
    value = BYTE(colorIndex[0])
  ENDIF ELSE BEGIN
    RETURN,0b
  ENDELSE
ENDELSE
;; => Reset the Decomposed State
DEVICE,DECOMPOSED=decomp
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,value
END
