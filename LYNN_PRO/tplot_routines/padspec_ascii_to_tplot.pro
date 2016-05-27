;+
;*****************************************************************************************
;
;  FUNCTION :   padspec_ascii_to_tplot.pro
;  PURPOSE  :   Gets particle moment spectra from the ASCII files written by
;                 write_padspec_ascii.pro by calling read_padspec_wrapper.pro.  
;                 read_padspec_wrapper.pro reads in the data and returns a TPLOT
;                 formatted structure.  Then padspec_ascii_to_tplot.pro splits the 
;                 returned structure into various Pitch-Angles (PA's) Distributions 
;                 (PADs).  The PAD's are then sent through other programs which either 
;                 smooth the data using IDL's SMOOTH.PRO or they normalize and shift the
;                 data for a more dramatic illustration of relative changes in particle
;                 [UNITS].  The manipulation is similar to that done by 
;                 calc_padspecs.pro, but does not require the Wind/3DP CDF libraries.
;                 Often times the particle spectra can appear very "noisy" which 
;                 prevents one from seeing the important structure which may or may not
;                 exist in the data.  So smoothing is done to allow one to see the
;                 relative structure and to eliminate "bad" or "null" data in some cases
;                 (read IDL's page on SMOOTH.PRO).  The program is MUCH faster than
;                 calling calc_padspecs.pro without pre-loaded Wind/3DP data structures
;                 (i.e. the DAT_ARR not set).  Also, since this program ONLY loads data
;                 from ASCII files and not entire data structures, much longer periods
;                 of time can be loaded than with calc_padspecs.pro for the same
;                 computer.  Though the ASCII files can often exceed 30 MB in size,
;                 they still rarely take longer than 30 seconds to load and manipulate
;                 into TPLOT variables (compared to the often excessive 300+ seconds
;                 get_padspecs.pro may require to load all the 3DP moments, and add
;                 magnetic field data to them, then create PADs, and then create one 
;                 TPLOT variable).  The write_padspec_ascii.pro program may take a while
;                 to write two weeks worth of ASCII files, but it is a passive process
;                 that can be done on a separate machine while the user works elsewhere.
;                 However, once the ASCII files are written, one can load all the data
;                 as often as they want in a relatively short period of time.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               dat_3dp_str_names.pro
;               wind_3dp_units.pro
;               read_padspec_wrapper.pro
;               store_data.pro
;               options.pro
;               reduce_pads.pro
;               clean_spec_spikes.pro
;               spec_vec_data_shift.pro
;               tnames.pro
;
;  REQUIRES:    
;               ASCII files created by write_padspec_ascii.pro
;
;  INPUT:
;               NAME       :  [string] Specify the type of structure you wish to 
;                               get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    
;               .............................................................
;               : If we want to get all the SST Foil data for 1996-04-03,   :
;               : in units of energy flux,                                  :
;               : with extra TPLOT variables of normalized eflux,           :
;               : and extra TPLOT variables of cleaned/smoothed eflux, then :
;               .............................................................
;               date  = '040396'
;               name  = 'sf'
;               units = 'eflux'
;               datn  = 1
;               datcl = 1
;               padspec_ascii_to_tplot,name,DAT_NORM=datn,DAT_CLN=datcl,$
;                                           DATE=date,UNITS=units
;
;  KEYWORDS:    
;               EBINS      :  [array,scalar] specifying which energy bins to create 
;                               particle spectra plots for
;               TRANGE     :  [Double] 2 element array specifying the range over 
;                               which to get data structures for
;               DATE       :  Scalar string (e.g. 'MMDDYY') specifying the date of interest
;               DAT_SHFT   :  If set, new TPLOT variables are created of the data shifted
;                               vertically on the Y-Axis to avoid overlaps (for easier
;                               viewing of data)
;               DAT_NORM   :  If set, new TPLOT variables are created of the data shifted
;                               and normalized [Note:  If this keyword is set, it
;                               overrides the DAT_SHFT keyword]
;               DAT_CLN    :  If set, new TPLOT variables are created of the data smoothed
;                               over a width determined by the type of data (i.e. 'el'
;                               needs less smoothing than 'sf') and the number of data
;                               points
;               UNITS      :  Wind/3DP data units for particle data include:
;                               'df','counts','flux','eflux',etc.
;                                [Default = 'flux']
;               RANGE_AVG  :  Two element double array specifying the time range
;                               (Unix time) to use for constructing an average to
;                               normalize the data by when using the keyword DAT_NORM
;
;   CHANGED:  1)  Program now normalizes the cleaned separated PAD specs
;                                                                   [09/24/2009   v1.1.0]
;             2)  Minor syntax touch-ups                            [09/30/2009   v1.1.1]
;             3)  Changed TPLOT storing such that TPLOT handles now contain the
;                   units of the spectra data for loading multiple unit types for
;                   comparison                                      [10/07/2008   v1.2.0]
;             3)  Changed TPLOT Y-Axis title determination          [10/08/2008   v1.3.0]
;
;   NOTES:      
;               1)  All new TPLOT variables will have suffixes that inform the user of
;                     type of stacked particle data present, including any combination
;                     of the following:
;                     '_cln'  :  Cleaned/Smoothed data      [Use DAT_CLN]
;                     '_sh'   :  Vertically shifted data    [Use DAT_SHFT]
;                     '_n'    :  Normalized by data in time range defined by 
;                                  the RANGE_AVG keyword    [Use DAT_NORM]
;
;   CREATED:  09/21/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/08/2008   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO padspec_ascii_to_tplot,name,EBINS=ebins,TRANGE=trange,DATE=date,DAT_SHFT=dat_shft, $
                                DAT_NORM=dat_norm,DAT_CLN=dat_cln,UNITS=units,         $
                                RANGE_AVG=range_avg

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f     = !VALUES.F_NAN
d     = !VALUES.D_NAN

IF KEYWORD_SET(dat_cln)  THEN d_cln   = 1 ELSE d_cln   = 0
IF KEYWORD_SET(dat_shft) THEN d_shift = 1 ELSE d_shift = 0
IF KEYWORD_SET(dat_norm) THEN d_norm  = 1 ELSE d_norm  = 0
IF (d_shift) THEN sffx_d0  = '_sh'  ELSE sffx_d0 = ''
IF (d_norm)  THEN sffx_d0 += '_n'
IF (d_cln)   THEN sffx_d1  = '_cln' ELSE sffx_d1 = ''
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
; => Get data from ASCII files
;-----------------------------------------------------------------------------------------
dat   = read_padspec_wrapper(sname,EBINS=ebins,TRANGE=trange,DATE=date,UNITS=gunits)
newna = 'n'+sname+'_pads_'+gunits
gtags = TAG_NAMES(dat)
;-----------------------------------------------------------------------------------------
; => Get rid of data points < 0.
;-----------------------------------------------------------------------------------------
bdpts = WHERE(dat.Y LE 0.0,bp)
IF (bp GT 0) THEN BEGIN
  dind = ARRAY_INDICES(dat.Y,bdpts)
  dat.Y[dind[0,*],dind[1,*],dind[2,*]] = f
ENDIF

bad   = WHERE(FINITE(dat.Y) EQ 0,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (STRLOWCASE(dat.YTITLE) EQ sname OR gd EQ 0) THEN BEGIN
  MESSAGE,'No files could be found for '+tdate,/INFORMATIONAL,/CONTINUE
  PRINT,'No data will be sent to TPLOT...'
  RETURN
ENDIF
; => Set up data structures for TPLOT
yttl    = STRUPCASE(sname)+' '+gunits+'!C'+punits
glabs   = dat.LABELS
limtags = ['XMINOR','YMINOR','XTICKLEN','YSTYLE']
lim0    = CREATE_STRUCT(limtags,5,9,0.04,1)
dat_tp  = dat
str_element,dat_tp,'YTITLE',yttl,/ADD_REPLACE
str_element,dat_tp,'UNITS',/DELETE
; => Send data to TPLOT
store_data,newna,DATA=dat_tp,LIMITS=lim0

IF (sname EQ 'sf' OR sname EQ 'so') THEN lbflg = -1 ELSE lblfg = 1
options,newna,'LABFLAG',lbflg
;-----------------------------------------------------------------------------------------
; => Make sure y-limits are not determined by "zeroed" data or NAN's
;-----------------------------------------------------------------------------------------
gy11 = WHERE(dat.Y GT 0.0 AND FINITE(dat.Y),g11)
IF (g11 GT 0) THEN BEGIN
  gyind1 = ARRAY_INDICES(dat.y,gy11)
  ymin1  = MIN(dat.Y[gyind1[0,*],gyind1[1,*],gyind1[2,*]],/NAN)/1.1
  ymax1  = MAX(dat.Y[gyind1[0,*],gyind1[1,*],gyind1[2,*]],/NAN)*1.1
  options,newna,'YRANGE',[ymin1,ymax1]
  options,newna,'YLOG',1
ENDIF
;-----------------------------------------------------------------------------------------
; => Get structure dimensions etc.
;-----------------------------------------------------------------------------------------
ndims       = SIZE(REFORM(dat.Y),/DIMENSIONS)
mdims       = N_ELEMENTS(ndims)
nd1         = ndims[0]           ; => # of time steps
nd2         = ndims[1]           ; => # of energy bins
nd3         = ndims[2]           ; => # of pitch-angles
;-----------------------------------------------------------------------------------------
; => Determine # of data points to smooth over when "cleaning" data spikes
;-----------------------------------------------------------------------------------------
mysip = nd1/800L
IF (mysip GT 3L AND mysip LE 12L) THEN BEGIN  ; => Between 2,400 and 9,600 data points
  hsmooth = mysip + 1L
  lsmooth = LONG(3./5.*hsmooth)
ENDIF ELSE BEGIN
  IF (mysip GT 12L) THEN BEGIN                ; => GT 9,600 data points
    IF (sname EQ 'sf' OR sname EQ 'so') THEN BEGIN
      hsmooth = 20L
      lsmooth = 10L
    ENDIF ELSE BEGIN
      hsmooth = 12L
      lsmooth = 7L
    ENDELSE
  ENDIF ELSE BEGIN                            ; => LT 2,400 data points
    ; => When the [Width]-Argument in SMOOTH.PRO = 1 or 0 =>> simply replaces NaNs
    hsmooth = 1L
    lsmooth = 1L
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Create a normalized spectrum to observe relative changes in flux
;-----------------------------------------------------------------------------------------
shon = STRMID(newna,0,3)
CASE shon OF
  'nsf' : BEGIN
    mysmp  = [0,2,hsmooth]    ; => weighted smoothing parameters for cleaning program
    mysnp  = lsmooth          ; => base smoothing step " "
  END
  'nso' : BEGIN
    mysmp = [0,2,hsmooth]     ; => weighted smoothing parameters for cleaning program
    mysnp = lsmooth           ; => base smoothing step " "    
  END
  'nel' : BEGIN
    ; => Don't actually "smooth" Eesa Low data initially because it rarely "needs" it
    hsmooth = 1
    lsmooth = 1
    mysmp   = [0,2,hsmooth]
    mysnp   = lsmooth       ; => base smoothing step " "   
  END  
  ELSE : BEGIN
    mysmp = [0,2,hsmooth]
    mysnp = lsmooth           ; => base smoothing step " "        
  END
ENDCASE
; => Smooth data if desired
newna2 = newna
IF (d_cln) THEN BEGIN
  clean_spec_spikes,newna2,NSMOOTH=mysnp,ESMOOTH=mysmp,NEW_NAME=newna2+sffx_d1
ENDIF
; => Normalize and/or Shift data if desired
IF (d_shift OR d_norm) THEN BEGIN 
  spec_vec_data_shift,newna2,NEW_NAME=newna2+sffx_d0,DATN=d_norm,   $
                             DATS=d_shift,RANGE_AVG=range_avg
  spec_vec_data_shift,newna2+sffx_d1,NEW_NAME=newna2+sffx_d1+sffx_d0, $
                                     DATN=d_norm,DATS=d_shift,RANGE_AVG=range_avg
ENDIF
;-----------------------------------------------------------------------------------------
; => Separate PADs by angle w/ respect to B-field direction (deg)
;-----------------------------------------------------------------------------------------
nn1     = newna
myangs  = STRARR(nd3 - 1L)        ; => Strings defining pitch-angles summed over
ang     = FLTARR(2,nd3 - 1L)      ; => Floats " "
FOR i=0, nd3 - 2L DO BEGIN
  j        = i + 1L
  pang     = FLTARR(2)
  reduce_pads,newna,2,i,j,ANGLES=pang,/NAN
  ang[*,i] = pang
  ;---------------------------------------------------------------------------------------
  ; => Add units to Y-Axis title if possible
  ;---------------------------------------------------------------------------------------
  nn2    = nn1+'-2-'+STRTRIM(i,2)+':'+STRTRIM(j,2)
  nn3    = tnames(nn2)
  ytest  = ytitle_tplot(nn3)
  ytest2 = STRSPLIT(ytest,'!c',/EXTRACT,/FOLD_CASE,/REGEX)
  IF (N_ELEMENTS(ytest2) GT 1) THEN BEGIN
    utest = STRPOS(STRLOWCASE(ytest2),'!u') GE 0
    uposi = WHERE(utest,gup,COMPLEMENT=nposi,NCOMPLEMENT=gnp)
    IF (gup GT 0) THEN BEGIN
      angle_string = ytest2[uposi[0]]
    ENDIF ELSE BEGIN
      angle_string = ''
    ENDELSE
    IF (gnp GT 0) THEN name_string = ytest2[nposi[0]] ELSE name_string = ytest2[uposi[1]]
  ENDIF ELSE BEGIN
    angle_string = ''
    name_string  = ytest2
  ENDELSE
  n_ytitle = name_string+' '+gunits+'!C'+angle_string
  options,nn3,'YTITLE',n_ytitle
ENDFOR
myangs  = STRTRIM(STRING(FORMAT='(f5.1)',ang[0,*]),1)
myangs += '-'+STRTRIM(STRING(FORMAT='(f5.1)',ang[1,*]),1)+'!Uo!N'
zdata   = omni_z_pads(newna,LABS=mylabs,PANGS=myangs)
;-----------------------------------------------------------------------------------------
; => Smooth the data to remove noise and NaNs
;-----------------------------------------------------------------------------------------
FOR i=0L, nd3 - 2L DO BEGIN
  tdata = zdata[i]
  tangl = myangs[i]
  options,tdata,'YTITLE',pname+' '+gunits+'!C'+tangl
  IF (d_cln) THEN BEGIN
    clean_spec_spikes,tdata,NSMOOTH=mysnp,ESMOOTH=mysmp,NEW_NAME=tdata+sffx_d1
  ENDIF
ENDFOR
;-----------------------------------------------------------------------------------------
; => Created a normalized spectrum to observe relative changes in flux
;-----------------------------------------------------------------------------------------
FOR i=0L, nd3 - 2L DO BEGIN
  tdata = zdata[i]
  tangl = myangs[i]
  IF (d_shift OR d_norm) THEN BEGIN
    spec_vec_data_shift,tdata+sffx_d1,NEW_NAME=tdata+sffx_d1+sffx_d0,DATN=d_norm,$
                                      DATS=d_shift,RANGE_AVG=range_avg
    IF (d_shift AND d_norm) THEN BEGIN
      options,tdata+sffx_d1+sffx_d0,'YTITLE',pname+' Normalized & Shifted'+'!C'+tangl
    ENDIF
  ENDIF
ENDFOR
; => Define some TPLOT limits for all TPLOT names created by this program
nnw = tnames(newna2+'*')
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'YMINOR',9
options,nnw,'XTICKLEN',0.04
options,nnw,'COLORS',LINDGEN(nd2)*(250L - 30L)/(nd2 - 1L) + 30L
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;*****************************************************************************************
END