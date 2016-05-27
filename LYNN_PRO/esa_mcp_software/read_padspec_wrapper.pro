;+
;*****************************************************************************************
;
;  FUNCTION :   read_padspec_wrapper.pro
;  PURPOSE  :   This is a wrapping program for read_padspec_ascii.pro.
;
;  CALLED BY:   
;               padspec_ascii_to_tplot.pro
;
;  CALLS:
;               my_str_date.pro
;               dat_3dp_str_names.pro
;               wind_3dp_units.pro
;               read_padspec_ascii.pro
;               dat_3dp_energy_bins.pro
;               my_3dp_plot_labels.pro
;               str_element.pro
;
;  REQUIRES:    
;               ASCII files created by write_padspec_ascii.pro
;
;  INPUT:
;               NAME    :  [string] Specify the type of structure you wish to 
;                            get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    
;               date  = '040396'
;               dat   = read_padspec_wrapper('sf',DATE=date)
;
;  KEYWORDS:    
;               EBINS   :  [array,scalar] specifying which energy bins to create 
;                            particle spectra plots for
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures for
;               DATE    :  Scalar string (e.g. 'MMDDYY') specifying the date of interest
;               UNITS   :  Wind/3DP data units for particle data include:
;                            'df','counts','flux','eflux',etc.
;                             [Default = 'flux']
;
;   CHANGED:  1)  Fixed a typo                                    [09/20/2009   v1.0.1]
;             2)  Changed return structure format                 [09/21/2009   v1.0.2]
;             3)  Added keyword:  UNITS                           [09/21/2009   v1.1.0]
;             4)  Updated 'man' page                              [10/05/2008   v1.1.1]
;
;   NOTES:      
;               1)  This program calls read_padspec_ascii.pro ONCE for each file
;
;   CREATED:  09/19/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/05/2008   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION read_padspec_wrapper,name,EBINS=ebins,TRANGE=trange,DATE=date,UNITS=units

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Find input date
;-----------------------------------------------------------------------------------------
mydate = my_str_date(DATE=date)
date   = mydate.S_DATE[0]  ; => ['MMDDYY']
mdate  = mydate.DATE[0]    ; => ['YYYYMMDD']
tdate  = mydate.TDATE[0]   ; => ['YYYY-MM-DD']
;-----------------------------------------------------------------------------------------
; => Make sure name is in the correct format
;-----------------------------------------------------------------------------------------
name  = STRLOWCASE(name)

strns = dat_3dp_str_names(name)
name  = strns.SN
pname = STRUPCASE(name)
sname = STRMID(name,0,2)        ; => e.g. 'el'
;-----------------------------------------------------------------------------------------
; => Check input units
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(units)  THEN gunits = 'flux' ELSE gunits = units[0]
new_units = wind_3dp_units(gunits)
gunits    = new_units.G_UNIT_NAME      ; => e.g. 'flux'
punits    = new_units.G_UNIT_P_NAME    ; => e.g. ' (# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f     = !VALUES.F_NAN
d     = !VALUES.D_NAN
npas  = 10L                             ; => Dummy number of pitch-angles (PAs)
nen   = 15L                             ; => " " energy bins
ntx   = 100L                            ; => " " time steps
dumx  = REPLICATE(d,ntx)                ; => Dummy array for Unix times
dumy  = REPLICATE(f,ntx,nen,npas)       ; => " " data
dumv1 = REPLICATE(f,ntx,nen)            ; => " " energy bin values
dumv2 = REPLICATE(f,ntx,npas)           ; => " " pitch-angles
dumlb = REPLICATE('NaN',nen)            ; => " " TPLOT energy bin labels
dtags = ['YTITLE','X','Y','V1','V2','YLOG','LABELS','PANEL_SIZE']
dumb  = CREATE_STRUCT(dtags,name,dumx,dumy,dumv1,dumv2,1,dumlb,2.0)

bfr   = -245.981                        ; => Dummy variable for labeling bad float elements
bdr   = -245.981d0                      ; => " " for labeling bad double elements
nk    = 0L                              ; => " " defining the total number of lines
;-----------------------------------------------------------------------------------------
; => Find if files exist
;-----------------------------------------------------------------------------------------
DEFSYSV,'!wind3dp_umn',EXISTS=exists
IF NOT KEYWORD_SET(EXISTS) THEN BEGIN
  mdir  = FILE_EXPAND_PATH('')
  mdir  = mdir+'/wind_3dp_pros/wind_data_dir/ascii_spec_3dp/'+date+'/'
ENDIF ELSE BEGIN
  mdir  = !wind3dp_umn.WIND_DATA_DIR+'ascii_spec_3dp/'+date+'/'
  IF (mdir[0] EQ '') THEN BEGIN
    mdir = FILE_EXPAND_PATH('wind_3dp_pros/wind_data_dir/ascii_spec_3dp/')
    mdir = mdir+date+'/'
  ENDIF
ENDELSE

file  = FILE_SEARCH(mdir,name+'_spec_*_'+gunits+'.txt')
gfile = WHERE(file NE '',gfi)
IF (gfi GT 0) THEN BEGIN
  file = file[gfile]
ENDIF ELSE BEGIN
  MESSAGE,'No files could be found for '+tdate,/INFORMATIONAL,/CONTINUE
  RETURN,dumb
ENDELSE
;-----------------------------------------------------------------------------------------
; => Get ASCII file format statement
;    [Note:  Program assumes ALL files have the same format!]
;-----------------------------------------------------------------------------------------
nf  = N_ELEMENTS(file)
snf = STRTRIM(STRING(FORMAT='(I)',nf),2)
PRINT,'Getting '+snf+' '+strns.LC+' Files'
; => Get the total # of file lines
FOR q=0L, nf - 1L DO nk += FILE_LINES(file[q]) - 7L


OPENR,gunit,file[0],/GET_LUN
  mline = ''
  FOR mvcount=0L, 6L DO BEGIN
    READF,gunit,mline
    CASE mvcount OF
      0 : dname = STRMID(mline,10)     ; -Name of 3D Spectra data (e.g. Eesa Low)
      1 : dunit = STRMID(mline,10)     ; -Units of data quantities
      2 : ddate = STRMID(mline,10)     ; -['MM-DD-YYYY/HH:MM:SS - MM-DD-YYYY/HH:MM:SS']
      3 : dlabe = STRMID(mline,10)     ; -Energy bin labels
      4 : dpang = STRMID(mline,10)     ; -Pitch-Angles (deg)
      5 : dform = STRMID(mline,10)     ; -Read/Print Format statement
      6 : 
    ENDCASE
  ENDFOR
FREE_LUN,gunit
; => Determine read format
form = STRTRIM(dform,2)
strl = STRSPLIT(STRCOMPRESS(dlabe,/REMOVE),'eV',/EXTRACT)
strp = STRSPLIT(STRCOMPRESS(dpang,/REMOVE),'!Uo!N',/EXTRACT)
l    = N_ELEMENTS(strp)         ; => # of pitch-angles
m    = N_ELEMENTS(strl)         ; => # of energy bins
n    = nk                       ; => Total # of time steps
; => Define dummy data arrays to fill
daxx = REPLICATE(bdr,nk)        ; => Dummy array of Unix times
dayy = REPLICATE(bfr,nk,m,l)    ; => Dummy for final data
dv11 = REPLICATE(bfr,nk,m)      ; => Dummy for final energies
dv22 = REPLICATE(bfr,nk,l)      ; => " " pitch-angles
dllb = STRARR(nf,m)             ; => " " energy bin labels
guns = STRARR(nf)               ; => String array of units for each file
;-----------------------------------------------------------------------------------------
; => Get ASCII file data
;-----------------------------------------------------------------------------------------
cc   = 0L
true = 1
j    = 0L
WHILE(true) DO BEGIN
  file0 = file[j]
  dat0  = read_padspec_ascii(name,EBINS=ebins,TRANGE=trange,DATE=date,FILENAME=file0,$
                             F_FORMAT=form)
  ; => Define useful parameters
  guns[j]     = dat0.UNITS
  
  ndims       = SIZE(REFORM(dat0.Y),/DIMENSIONS)
  mdims       = N_ELEMENTS(ndims)
  nd1         = ndims[0]
  nd2         = ndims[1]
  nd3         = ndims[2]
  bb          = (nd1 - 1L) + cc
  daxx[cc:bb]                     = dat0.X
  dayy[cc:bb,0L:(m-1L),0L:(l-1L)] = dat0.Y
  dv11[cc:bb,0L:(m-1L)]           = dat0.V1
  dv22[cc:bb,0L:(l-1L)]           = dat0.V2
  dllb[j,0L:(m-1L)]               = dat0.LABELS
  
  IF (j LT nf - 1L) THEN true = 1 ELSE true = 0
  IF (true) THEN j  += 1L
  IF (true) THEN cc += nd1
ENDWHILE
;-----------------------------------------------------------------------------------------
; => Get rid of bad data
;-----------------------------------------------------------------------------------------
gdata = WHERE(daxx NE bdr AND daxx NE 0d0,gdat,COMPLEMENT=bdata)
IF (gdat GT 0) THEN BEGIN
  dy1 = dayy[gdata,0L:(m-1L),0L:(l-1L)]
  tt1 = daxx[gdata]
  vv1 = dv11[gdata,0L:(m-1L)]
  vv2 = dv22[gdata,0L:(l-1L)]
  s1  = SORT(tt1)
  tt1 = tt1[s1]
  dy1 = dy1[s1,*,*]
  vv1 = vv1[s1,*]
  vv2 = vv2[s1,*]
ENDIF ELSE BEGIN
  dy1 = REPLICATE(f,100,m,l)
  tt1 = REPLICATE(d,100)
  vv1 = REPLICATE(f,100,m)
  vv2 = REPLICATE(f,100,l)
ENDELSE
;-----------------------------------------------------------------------------------------
; => Get rid of bad energy bin labels
;-----------------------------------------------------------------------------------------
glabs = WHERE(REFORM(dllb[0,*]) NE '',gla)
IF (gla GT 0) THEN BEGIN
  lbtest = SIZE(REFORM(dllb),/N_DIMENSIONS)
  IF (lbtest GT 1L) THEN BEGIN
    lb1 = dllb[*,glabs]
    ns1 = STRMID(lb1[*,*],0,strlen(lb1[0,*])-3L)
  ENDIF ELSE BEGIN
    lb1 = (REFORM(dllb))[glabs]
    ns1 = STRMID(lb1[*],0,strlen(lb1[*])-3L)
  ENDELSE
  nf1 = (DOUBLE(REFORM(ns1[0,*])) + DOUBLE(REFORM(ns1[1,*])))/2.0  ; -energies (eV)
  ne1 = N_ELEMENTS(nf1)
  nf2 = nf1/1d3                                                    ; -energies (keV)
  lar = WHERE(nf2 GT 1d0,nlr)
  IF (nlr GT ne1/2L) THEN BEGIN
    ln1 = STRTRIM(STRING(FORMAT='(f12.3)',nf2),2)+' keV'
  ENDIF ELSE BEGIN
    ln1 = STRTRIM(STRING(FORMAT='(f12.2)',nf1),2)+' eV'
  ENDELSE
ENDIF ELSE BEGIN
  ln1 = STRARR(m)
ENDELSE
;-----------------------------------------------------------------------------------------
; -Define parameters to return a new data structure with desired quantities
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(ebins) THEN BEGIN
  ebins2 = ebins
ENDIF ELSE BEGIN
  ebins2 = ebins2
ENDELSE
yttl = STRUPCASE(name)+'!C'+dunit  ; => Y-Title for plots
dat  = CREATE_STRUCT('YTITLE',yttl,'X',tt1,'Y',dy1,'V1',vv1,'V2',vv2,'YLOG',1,$
                     'LABELS',ln1,'PANEL_SIZE',2.0)

my_ens = dat_3dp_energy_bins(dat,EBINS=ebins2)
estart = my_ens.E_BINS[0]
eend   = my_ens.E_BINS[1]
myen   = my_ens.ALL_ENERGIES

datv1 = dat.V1[*,estart:eend]
mbins = N_ELEMENTS(dat.V1[*,0])       ; # of samples
daty  = dat.Y
;-----------------------------------------------------------------------------------------
; -Make sure energies haven't been labeled as zeros
;-----------------------------------------------------------------------------------------
gvals  = WHERE(datv1 LE 0.0 OR FINITE(datv1) EQ 0,gvls)
IF (gvls GT 0) THEN BEGIN
  datv1 = dat.v1
  datv2 = REPLICATE(1.,mbins) # myen[estart:eend]
  gvind = ARRAY_INDICES(datv1,gvals)
  datv1[gvind[0,*],gvind[1,*]] = datv2[gvind[0,*],gvind[1,*]]
ENDIF ELSE BEGIN
  datv2 = REPLICATE(1.,mbins) # myen[estart:eend]
  datv1 = datv1
ENDELSE
;-----------------------------------------------------------------------------------------
; => Determine energy bins, labels, and data names
;-----------------------------------------------------------------------------------------
tn1   = STRUPCASE(STRMID(name,0,1)) ; -1st letter of structure name
tn2   = STRUPCASE(STRMID(name,1,1)) ; -2nd letter of structure name
tnlen = STRLEN(name)
CASE tn1[0] OF
  'E' : BEGIN
    mylb  = STRTRIM(STRMID(STRTRIM(STRING(FORMAT='(f12.1)',myen),2),0,6),2)+' eV'
  END
  'P' :  BEGIN
    mylb  = STRTRIM(STRMID(STRTRIM(STRING(FORMAT='(f12.1)',myen),2),0,6),2)+' eV'
  END
  'S' :  BEGIN
    kens = WHERE(myen/1e6 GT 1.0,kns) 
    IF (kns GT 0) THEN myen = myen/1000.
    mylb  = STRTRIM(STRMID(STRTRIM(STRING(FORMAT='(f12.1)',myen),2),0,6),2)+' keV'
  END
  ELSE : BEGIN
    MESSAGE,'Improper input format:  NAME',/INFORMATIONAL,/CONTINUE
    PRINT,"Examples: 'el', 'eh', 'pl', 'ph', 'elb', 'ehb', 'sf', etc."
    RETURN,dat
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; -Determine plot labels and positions
;-----------------------------------------------------------------------------------------
dat  = CREATE_STRUCT('YTITLE',yttl,'X',dat.X,'Y',daty[*,estart:eend,*],'V1',datv1,$
                     'V2',dat.V2,'YLOG',1,'LABELS',mylb[estart:eend],             $
                     'PANEL_SIZE',2.0,'UNITS',guns)

dat_lab_posi = my_3dp_plot_labels(dat)

myposi = dat_lab_posi.POSITIONS
mylabs = dat_lab_posi.LABELS
myen   = myen[estart:eend]
mylb   = mylb[estart:eend]

str_element,dat,'LABELS',mylb,/ADD_REPLACE
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;*****************************************************************************************
RETURN,dat
END