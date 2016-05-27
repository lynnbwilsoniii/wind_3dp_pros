;+
;*****************************************************************************************
;
;  FUNCTION :  padspecs_reader.pro
;  PURPOSE  :  Reads in ASCII files produced by my_padspec_writer.pro and returns a data
;               structure to my_padspec_rw.pro where the data is manipulated.  [This 
;               program should NOT be called by the user directly.]
;
;  CALLED BY:   
;               padspecs_to_tplot.pro
;
;  CALLS:
;               my_str_date.pro
;               dat_3dp_str_names.pro
;               dat_3dp_energy_bins.pro
;               my_3dp_plot_labels.pro
;
;  REQUIRES:    
;               ASCII files created by my_padspec_writer.pro
;
;  INPUT:
;               NAME    : [string] Specify the type of structure you wish to 
;                          get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               EBINS   : [array,scalar] specifying which energy bins to create 
;                            particle spectra plots for
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures for
;               DATE    : [string] 'MMDDYY' specifying the date of interest
;
;   CHANGED:  1)  Changed structure formats                 [08/18/2008   v1.0.3]
;             2)  Changed 'man' page                        [09/15/2008   v1.0.4]
;             3)  Changed syntax                            [11/07/2008   v1.0.5]
;             4)  Fixed string conversion issue with NaN's in files
;                                                           [11/10/2008   v1.0.6]
;             5)  Changed indexing issue                    [11/10/2008   v1.0.7]
;             6)  Fixed typo                                [11/14/2008   v1.0.8]
;             7)  Fixed indexing issue                      [11/26/2008   v1.0.9]
;     [Note:  v1.0.9 only affects results where ONLY 1 file/name is called]
;             8)  Changed array definition to account for non-default sized
;                  ascii files where the PAs or Energies are different
;                                                           [02/25/2009   v1.0.10]
;             9)  Fixed syntax issue                        [05/04/2009   v1.1.0]
;            10)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed from my_padspec_reader.pro  [08/12/2009   v2.0.0]
;
;   CREATED:  08/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION padspecs_reader,name,EBINS=ebins,TRANGE=trange,DATE=date

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
mydate = my_str_date(DATE=date)
date   = mydate.S_DATE  ; -('MMDDYY')
mdate  = mydate.DATE    ; -('YYYYMMDD')
name  = STRLOWCASE(name)
;-----------------------------------------------------------------------------------------
; -Make sure name is in the correct format
;-----------------------------------------------------------------------------------------
strns = dat_3dp_str_names(name)
name  = strns.SN
;-----------------------------------------------------------------------------------------
; -Define dummy variables
;-----------------------------------------------------------------------------------------
f     = !VALUES.F_NAN
mdir  = FILE_EXPAND_PATH('IDL_stuff/SPEC_3DP_ASCII/'+date)
CASE name OF
  'sf' : BEGIN
    files = FILE_SEARCH(mdir,'/'+name+'_*.txt')  ; -avoid sft data structures
    file2 = FILE_SEARCH(mdir,'/'+name+'b*.txt')
    files = [files,file2]
    nenerbins = 7L   ; -# of energy bins
    npangles  = 10L  ; -Over estimate of # of PA's
  END
  'so' : BEGIN
    files = FILE_SEARCH(mdir,'/'+name+'_*.txt')  ; -avoid sot data structures
    file2 = FILE_SEARCH(mdir,'/'+name+'b*.txt')
    files = [files,file2]
    nenerbins = 9L   ; -# of energy bins
    npangles  = 10L  ; -Over estimate of # of PA's
  END
  'el' : BEGIN
    files = FILE_SEARCH(mdir,'/'+name+'*.txt')
    nenerbins = 15L
    npangles  = 20L
  END
  'pl' : BEGIN
    files = FILE_SEARCH(mdir,'/'+name+'*.txt')
    nenerbins = 14L
    npangles  = 10L
  END
  ELSE : BEGIN
    files = FILE_SEARCH(mdir,'/'+name+'*.txt')
    nenerbins = 15L
    npangles  = 20L
  END
ENDCASE
file  = files
gfile = WHERE(file NE '',gfi)
IF (gfi GT 0) THEN BEGIN
  file = file[gfile]
  GOTO,JUMP_INFILE
ENDIF ELSE BEGIN
  dat2 = CREATE_STRUCT('YTITLE',name,'X',REPLICATE(f,100),$
                       'Y',REPLICATE(f,100,10,5),'V1',REPLICATE(f,100,10),$
                       'V2',REPLICATE(f,100,5),'YLOG',1,'LABELS',         $
                       REPLICATE('NaN',10),'PANEL_SIZE',2.0)
  RETURN,dat2
ENDELSE
;-----------------------------------------------------------------------------------------
JUMP_INFILE:
;-----------------------------------------------------------------------------------------
PRINT,"Getting Files..."
PRINT,file
PRINT,""

nf  = N_ELEMENTS(file)
bfr = -245.981                  ; -dummy variable for identifying which elements of
bdr = -245.981d0                ; -dummy variable for identifying which elements of
nk  = 0L                        ;   the final structure are valid
FOR q=0L, nf - 1L DO nk = nk + FILE_LINES(file[q]) - 7L
dtt  = REPLICATE(bdr,nk)        ; -" " time stamps
cc   = 0L

qqq  = 1
q    = 0L
WHILE(qqq) DO BEGIN
  n_f0  = FILE_LINES(file[q]) - 7L     ; -# of lines of data in each file
  OPENR,gunit,file[q],/GET_LUN
  mline = ''
  PRINT,"Reading File..."
  PRINT,file[q]
  PRINT,""
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
  ; -All files of form:  '(e20.12,[m]e24.12,[m]f12.2)' => width = 20 + m*(24 + 12)
  strl = STRSPLIT(dlabe,' eV ',/EXTRACT)
  strp = STRSPLIT(dpang,'!Uo!N ',/EXTRACT)
  pach = WHERE(strp EQ 'a',pch)
  IF (pch GT 0L) THEN BEGIN  ; -Bad PA's => Use defaults!
    CASE name OF
      'pl'  : strp = ['34.0','67.0','106.0','139.0']
      'sft' : strp = ['30.0','90.0','150.0']
      'sot' : strp = ['30.0','90.0','150.0']
      'el'  : strp = ['7.44','18.1','27.9','39.9','51.1','62.0','73.2','84.2','95.8',$
                     '106.8','118.0','128.9','140.0','152.1','161.9','172.6']
      ELSE  : strp = ['14.7','34.5','56.6','78.7','101.2','123.4','145.5','165.3']
    ENDCASE
  ENDIF
  l    = N_ELEMENTS(strp)         ; -# of pitch-angles
  m    = N_ELEMENTS(strl)         ; -# of energy bins
  n    = LONG((n_f0*1d0)/(l*1d0)) ; -# of time steps
  ;---------------------------------------------------------------------------------------
  ; -Need to define arrays for ALL data
  ;---------------------------------------------------------------------------------------
  IF (q EQ 0L) THEN BEGIN
    dayy = REPLICATE(bfr,nk,m,l)    ; -dummy for final data
    dv11 = REPLICATE(bfr,nk,m)      ; -dummy for final energies
    dv22 = REPLICATE(bfr,nk,l)      ; -" " pitch-angles
    dllb = STRARR(nf,m)             ; -" " energy bin labels
  ENDIF
  width = 20L + m*(36L)
  nform = '(a20,'+STRTRIM(m,2)+'a24,'+STRTRIM(m,2)+'a12)'
  ;---------------------------------------------------------------------------------------
  ; -Need to define arrays for the data in EACH file
  ;---------------------------------------------------------------------------------------
  dy   = FLTARR(n,m,l)     ; -Data array [for each file]
  v1   = FLTARR(n,m)       ; -Energy bin values (eV or keV) [for each file]
  v2   = FLTARR(n,l)       ; -Pitch-Angles (deg) [for each file]
  t0   = ''
  data = STRARR(m)
  dat1 = STRARR(m)
  tt   = DBLARR(n)         ; -Unix time stamp of data [for each file]
  jjj  = 1
  iii  = 1
  j    = 0L
  WHILE(jjj) DO BEGIN
    k    = 0L
    WHILE(iii) DO BEGIN
      READF,gunit,FORMAT=nform,t0,data,dat1
      dy[j,*,k] = FLOAT(STRTRIM(data[*],2))
      IF (k LT l - 1L) THEN iii = 1 ELSE iii = 0
      IF (iii) THEN k += 1L
    ENDWHILE
    tt[j]   = DOUBLE(STRTRIM(t0,2))
    v1[j,*] = FLOAT(STRTRIM(dat1[*],2))
    v2[j,*] = FLOAT(strp[*])
    IF (j LT n - 1L) THEN jjj = 1 ELSE jjj = 0
    IF (jjj) THEN j += 1L
    IF (jjj) THEN iii = 1
  ENDWHILE
  FREE_LUN,gunit
  plabs = STRSPLIT(dpang,' ',/EXTRACT)  ; -Pitch-Angle Labels
  elabs = STRSPLIT(dlabe,' ',/EXTRACT)
  enlas = STRARR(m)                     ; -Energy Bin Labels
  FOR i=0L, N_ELEMENTS(elabs)/2L - 1L DO BEGIN
    zz = 2L*i
    yy = zz + 1L
    enlas[i] = elabs[zz]+' '+elabs[yy]
  ENDFOR
  dayy[cc:(n-1L+cc),0L:(m-1L),0L:(l-1L)] = dy[*,*,*]
  dv11[cc:(n-1L+cc),0L:(m-1L)]           = v1[*,*]
  dv22[cc:(n-1L+cc),0L:(l-1L)]           = v2[*,*]
  dtt[cc:(n-1L+cc)]                      = tt[*]
  dllb[q,0L:(m-1L)]                      = enlas[*]
  IF (q LT nf - 1L) THEN qqq = 1 ELSE qqq = 0
  IF (qqq) THEN q  += 1L
  IF (qqq) THEN cc += n
ENDWHILE
;-----------------------------------------------------------------------------------------
; -Remove bad data
;-----------------------------------------------------------------------------------------
gdata = WHERE(dtt NE bdr AND dtt NE 0d0,gdat,COMPLEMENT=bdata)
IF (gdat GT 0) THEN BEGIN
  dy1 = dayy[gdata,0L:(m-1L),0L:(l-1L)]
  tt1 = dtt[gdata]
  vv1 = dv11[gdata,0L:(m-1L)]
  vv2 = dv22[gdata,0L:(l-1L)]
  s1  = SORT(tt1)
  tt1 = tt1[s1]
  dy1 = dy1[s1,*,*]
  vv1 = vv1[s1,*]
  vv2 = vv2[s1,*]
ENDIF ELSE BEGIN
  dy1 = REPLICATE(f,100,m,l)
  tt1 = REPLICATE(f,100)
  vv1 = REPLICATE(f,100,m)
  vv2 = REPLICATE(f,100,l)
ENDELSE
;-----------------------------------------------------------------------------------------
; -Determine plot labels
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
yttl = STRUPCASE(name)+' '+STRMID(dunit,0,4)+'!C'+STRMID(dunit,5) ; -y-title for plots
dat  = CREATE_STRUCT('YTITLE',yttl,'X',tt1,'Y',dy1,'V1',vv1,'V2',vv2,'YLOG',1,$
                     'LABELS',ln1,'PANEL_SIZE',2.0)

my_ens = dat_3dp_energy_bins(dat,EBINS=ebins2)
estart = my_ens.E_BINS[0]
eend   = my_ens.E_BINS[1]
myen   = my_ens.ALL_ENERGIES

datv1 = dat.v1[*,estart:eend]
mbins = N_ELEMENTS(dat.v1[*,0])       ; # of samples
daty  = dat.y
myn   = N_ELEMENTS(dat)
;-----------------------------------------------------------------------------------------
; -Make sure energies haven't been labeled as zeros
;-----------------------------------------------------------------------------------------
gvals  = WHERE(datv1 LE 0.0 OR FINITE(datv1) EQ 0,gvls)
;gvals  = WHERE(datv1 EQ 0.0,gvls)
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
; -Determine energy bins, labels, and data names
;-----------------------------------------------------------------------------------------
mylb  = STRARR(myn)
tn1   = STRUPCASE(STRMID(name,0,1)) ; -1st letter of structure name
tn2   = STRUPCASE(STRMID(name,1,1)) ; -2nd letter of structure name
tnlen = STRLEN(name)
CASE tn1 OF
  'E' : BEGIN
    mylb  = STRMID(STRTRIM(STRING(FORMAT='(f12.1)',myen),2),0,6)+' eV'
  END
  'P' :  BEGIN
    mylb  = STRMID(STRTRIM(STRING(FORMAT='(f12.1)',myen),2),0,6)+' eV'
  END
  'S' :  BEGIN
    kens = WHERE(myen/1e6 GT 1.0,kns) 
    IF (kns GT 0) THEN myen = myen/1000.
    mylb  = STRMID(STRTRIM(STRING(FORMAT='(f12.1)',myen),2),0,6)+' keV'
  END
  ELSE : BEGIN
    MESSAGE,'Improper Input:  NAME',/INFORMATION,/CONTINUE
    PRINT,"(e.g. 'el', 'eh', 'pl', 'ph', 'elb', 'ehb', 'sf', etc.)"
    RETURN,0
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; -Determine plot labels and positions
;-----------------------------------------------------------------------------------------
dat2 = CREATE_STRUCT('YTITLE',yttl,'X',dat.x,'Y',daty[*,estart:eend,*],'V1',datv1,$
                     'V2',dat.v2,'YLOG',1,'LABELS',mylb[estart:eend],'PANEL_SIZE',2.0)

dat_lab_posi = my_3dp_plot_labels(dat2)

myposi = dat_lab_posi.POSITIONS
mylabs = dat_lab_posi.LABELS
myen   = myen[estart:eend]
mylb   = mylb[estart:eend]

baabs  = WHERE(FINITE(mylabs) EQ 0,baa)  ; -make sure labels are not NAN's
IF (baa GT 0) THEN BEGIN
  mylabs[baabs] = mylb[baabs]
ENDIF
;-----------------------------------------------------------------------------------------
; -Create new data structure for data
;-----------------------------------------------------------------------------------------
mstr = CREATE_STRUCT('YTITLE',yttl,'X',dat.x,'Y',daty[*,estart:eend,*],'V1',datv1,$
                     'V2',dat.v2,'YLOG',1,'LABELS',mylabs,'PANEL_SIZE',2.0)
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;*****************************************************************************************
RETURN,mstr
END