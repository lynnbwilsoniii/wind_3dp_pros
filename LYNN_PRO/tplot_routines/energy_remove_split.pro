;+
;*****************************************************************************************
;
;  PROCEDURE:   energy_remove_split.pro
;  PURPOSE  :   Separates or removes desired energy level data to avoid overlaps
;                and/or bad data which is not removed by other means in stacked
;                spectra plots.  One can remove energy bins (i.e. individual lines)
;                or separate them to form two new TPLOT variables.  This can be
;                very useful for SST data since the low and high energy bins often
;                overlap in flux at times and it can be useful to view them separately.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               get_data.pro
;               store_data.pro
;               dat_3dp_energy_bins.pro
;               tnames.pro
;               ytitle_tplot.pro
;               wind_3dp_units.pro
;               options.pro
;               ylim.pro
;
;  REQUIRES:    
;               TPLOT variables associated particle spectra data
;
;  INPUT:
;               NAME       :  Scalar [string] defining the TPLOT handle the user wants
;                               to split/remove energy bins for/from
;
;  EXAMPLES:    
;               energy_remove_split,'npl_pads',NEW_NAME1='npl_low',$
;                                   NEW_NAME2='npl_high',/SPLIT,ENERGIES=[0,3]
;               energy_remove_split,'nso_pads_omni',NEW_NAME1='nso_pads_omni_E0-3',$
;                                   ENERGIES=[0,3]
;
;              {Both of the above examples separate the highest 4 energies from
;                the rest, the first case creating two new tplot variables, 
;                the second making only 1 new tplot variable WITHOUT the
;                highest 4 energies.  **Note that entering the scalar value of 
;                4 or LINDGEN(4) would have given the same result for both.**}
;
;  KEYWORDS:    
;               NEW_NAME1  :  Scalar [string] defining the new TPLOT handle containing
;                               the low energies not included in the range defined by
;                               the ENERGIES keyword
;                               [Default = NAME[0]+'_Low']
;               NEW_NAME2  :  Scalar [string] defining the new TPLOT handle containing
;                               the high energies included in the range defined by the
;                               ENERGIES keyword, IFF SPLIT keyword is set
;                               [Default = '']
;               SPLIT      :  Defines whether the values in the ENERGIES keyword are to
;                               be removed or whether they are to be used to create
;                               a new TPLOT handle defined by NEW_NAME2
;                                 TRUE   :  the energy bins defined are removed from
;                                           the initial data structure and used for a
;                                           new TPLOT handle defined by NEW_NAME2 and
;                                           the rest of the energy bins are put in
;                                           the new TPLOT handle NEW_NAME1
;                                 FALSE  :  the energy bins defined will be removed
;                                           from the TPLOT handle NAME
;               ENERGIES   :  Scalar or array [long] defining the energy bin indices
;                               which are to be either removed [SPLIT=0] or stored as
;                               a new TPLOT handle [SPLIT=1] defined by NEW_NAME2
;                               [Default = indices of all energy bins]
;
;   CHANGED:  1)  Added program my_ytitle_tplot.pro
;                                                                   [06/22/2008   v1.1.18]
;             2)  Updated man page
;                                                                   [03/18/2009   v1.1.19]
;             3)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and renamed from my_energy_remove_2.pro
;                                                                   [08/11/2009   v2.0.0]
;             4)  Output options for dat_3dp_energy_bins.pro changed, thus requiring a
;                   slightly different syntax
;                                                                   [08/12/2009   v2.0.1]
;             5)  Rewrote most of program
;                                                                   [09/30/2009   v3.0.0]
;             6)  Changed program my_ytitle_tplot.pro to ytitle_tplot.pro
;                                                                   [10/07/2008   v3.1.0]
;             7)  Fixed order of energy bin labels for SST data
;                                                                   [10/08/2008   v3.1.1]
;             8)  Now calls wind_3dp_units.pro and Y-Title now has units
;                                                                   [10/08/2008   v3.2.0]
;             9)  Fixed a bug when LIM or DLIM are not structures and
;                   cleaned up a little
;                                                                   [06/30/2014   v3.2.1]
;
;   NOTES:      
;               1)  The ENERGIES keyword can be a scalar value, [2]-element array, or
;                     [N]-element array.  If scalar value, X, then the first X energies
;                     are used.  If [2]-element array, [X,Y], then the energies included
;                     in the array starting at X and ending with Y are used.  If ENERGIES
;                     is set to an [N]-element array, then the values in the array are
;                     assumed to be the indices of the desired energy bins.
;
;  REFERENCES:  
;               
;
;   CREATED:  06/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  06/30/2014   v3.2.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO energy_remove_split,name,NEW_NAME1=new_name1,NEW_NAME2=new_name2,$
                             SPLIT=split,ENERGIES=energies

;;****************************************************************************************
ex_start = SYSTIME(1)
;;****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Define dummy variables
;;----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;;  Define default tag names for 3D Spectra TPLOT Variables
dum3dt     = ['YTITLE','X','Y','V1','V2','YLOG','LABELS','PANEL_SIZE']
;;  Define default tag names for 2D Spectra TPLOT Variables
dum2dt     = ['X','Y','V']
def_3d_str = 0                   ;;  Logic:  1 if default 3D structure ELSE 0
def_labs   = ''                  ;;  Dummy array of default labels
;;----------------------------------------------------------------------------------------
;;  Make sure name is either a tplot index or tplot string name
;;----------------------------------------------------------------------------------------
IF (SIZE(name,/TYPE) GT 1L AND SIZE(name,/TYPE) LT 8L) THEN BEGIN
  IF (SIZE(name,/TYPE) EQ 7L) THEN BEGIN
    get_data,name,DATA=d,DLIM=dlim,LIM=lim
  ENDIF ELSE BEGIN
    name = (tnames(ROUND(name)))[0]
    get_data,name,DATA=d,DLIM=dlim,LIM=lim
  ENDELSE
ENDIF ELSE BEGIN
  MESSAGE,'Incorrect input format:  NAME NOT FOUND: '+name,/INFORMATION,/CONTINUE
  RETURN
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Make sure d is a structure
;;----------------------------------------------------------------------------------------
IF (SIZE(d,/TYPE) NE 8) THEN BEGIN
  MESSAGE,'Incorrect input format:  NAME NOT FOUND: '+name,/INFORMATION,/CONTINUE
  GOTO,JUMP_FIN
ENDIF
ylg   = 1
mtags = TAG_NAMES(d)       ;;  Structure tags
ntags = N_TAGS(d)          ;;  Number of structure tags
IF (ntags LT 3) THEN BEGIN
  MESSAGE,'Incorrect structure format:  '+name,/INFORMATION,/CONTINUE
  GOTO,JUMP_FIN
ENDIF
IF (SIZE(lim,/TYPE)  NE 8) THEN glimtags = STRLOWCASE(TAG_NAMES(lim))  ELSE glimtags = ''
IF (SIZE(dlim,/TYPE) NE 8) THEN gdeftags = STRLOWCASE(TAG_NAMES(dlim)) ELSE gdeftags = ''
;;  LBW III  06/30/2014   v3.2.1
;glimtags = STRLOWCASE(TAG_NAMES(lim))
;gdeftags = STRLOWCASE(TAG_NAMES(dlim))
;;  Check if default 3D TPLOT structure
gstrtags = STRLOWCASE(mtags) EQ STRLOWCASE(dum3dt)
good     = WHERE(gstrtags,gstr)
IF (gstr EQ 8L) THEN def_3d_str = 1 ELSE def_3d_str = 0
;;  Check for LABELS structure tag in 3D TPLOT structure plot limits structures
test_l   = WHERE(glimtags EQ 'labels',t_l)
test_d   = WHERE(gdeftags EQ 'labels',t_d)
lab_test = WHERE([t_l,t_d] GT 0,lab_t)
;;----------------------------------------------------------------------------------------
;;   Make sure TPLOT variable exists and can be used
;;----------------------------------------------------------------------------------------
ndims = SIZE(d.y,/DIMENSIONS) 
mdims = N_ELEMENTS(ndims)     ;; # of dimensions
CASE mdims OF
  3 : BEGIN
    nd1   = ndims[0]          ;; typically for spec data => # of samples
    nd2   = ndims[1]          ;; " " => # of energy bins
    nd3   = ndims[2]          ;; " " => # of pitch-angles which have been summed over
    mener = nd2 - 1L
  END
  2 : BEGIN
    nd1   = ndims[0]
    nd2   = ndims[1]
    nd3   = 0L
    mener = nd2 - 1L
  END
  1 : BEGIN
    MESSAGE,'Data structure has incorrect format...',/INFORMATION,/CONTINUE
    GOTO,JUMP_FIN
  END
  ELSE : BEGIN
    MESSAGE,'Data structure has incorrect format...',/INFORMATION,/CONTINUE
    GOTO,JUMP_FIN
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;  Determine energy bin values
;;----------------------------------------------------------------------------------------
my_ena   = dat_3dp_energy_bins(d)
nener    = N_ELEMENTS(my_ena.ALL_ENERGIES)      ;;  Total number of energies available
allen    = my_ena.ALL_ENERGIES                  ;;  An array of all the energy values
allel    = LINDGEN(nener)                       ;;  An array for all the energy bin elements
gkeV     = WHERE(allen GE 1e3,gkv,COMPLEMENT=bkeV,NCOMPLEMENT=bkv)
IF (gkv GT 0) THEN BEGIN
  mylb = STRARR(nener)
  mylb[gkeV] = STRTRIM(STRING(FORMAT='(f12.1)',allen[gkeV]*1e-3),2)+' keV'
  IF (bkv GT 0) THEN mylb[bkeV] = STRTRIM(STRING(FORMAT='(f12.1)',allen[bkeV]),2)+' eV'
ENDIF ELSE mylb = STRTRIM(STRING(FORMAT='(f12.1)',allen),2)+' eV'
def_labs = mylb

sname    = STRMID(name,0,3)
g_eesa   = WHERE(STRPOS(sname,'el') GE 0 OR STRPOS(sname,'eh') GE 0,g_ee)
g_pesa   = WHERE(STRPOS(sname,'pl') GE 0 OR STRPOS(sname,'ph') GE 0,g_pe)
g_ssts   = WHERE(STRPOS(sname,'sf') GE 0 OR STRPOS(sname,'so') GE 0,g_ss)
good     = WHERE([g_ee,g_pe,g_ss] GT 0,gd)
;;----------------------------------------------------------------------------------------
;;  Determine some default parameters
;;----------------------------------------------------------------------------------------

;;----------------------------------------------------------------------------------------
;;  Check Y-Title to make sure we don't remove PA's
;;----------------------------------------------------------------------------------------
;ytest  = my_ytitle_tplot(name)
ytest  = ytitle_tplot(name)
strch  = STREGEX(ytest,STRMID(sname,1),LENGTH=len1,/FOLD_CASE)
IF (strch GE 0) THEN BEGIN
  yttlen = STRLEN(ytest)
  str2 = STREGEX(ytest,'!Uo!N',LENGTH=len2,/FOLD_CASE) ;;  check for PA string
  IF (str2 GE 0) THEN BEGIN
    IF (str2+len2 EQ yttlen) THEN BEGIN                ;;  PA string at end of ytitle
      myang = STRTRIM(STRMID(ytest,strch+len1),2)
    ENDIF ELSE BEGIN
      anglen = (str2+len2) - (strch+len1)              ;;  length of pitch-angle string
      angst  = (strch+len1)                            ;;  start position of pitch-angle string
      myang  = STRTRIM(STRMID(ytest,angst,anglen))
    ENDELSE
    ;;  Get rid of extra '!C' in angle expression if it exists
    anglen = STRLEN(myang) - 2L
    cposi  = STRPOS(STRLOWCASE(myang),'!c')
    IF (cposi[0] GE 0) THEN BEGIN
      IF (cposi[0] LT anglen) THEN BEGIN
        ;;  '!C' is at beginning of expression
        myang = STRMID(myang,cposi[0] + 2L)
      ENDIF ELSE BEGIN
        ;;  '!C' is at end of expression
        myang = STRMID(myang,0L,cposi[0])
      ENDELSE
    ENDIF
  ENDIF ELSE BEGIN                                     ;;  No PA's, so use default units of flux
    myang = 'Flux'
  ENDELSE
ENDIF ELSE BEGIN
  myang = 'Flux'
ENDELSE
new_units = wind_3dp_units(name,/SEARCH)
gunits    = new_units.G_UNIT_NAME      ;;  e.g. 'flux'
punits    = new_units.G_UNIT_P_NAME    ;;  e.g. ' (# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
;;----------------------------------------------------------------------------------------
;;  Get an array(scalar) of the # of elements in each dimension
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(energies) THEN BEGIN
  ebins2  = energies
  my_ens  = dat_3dp_energy_bins(d,EBINS=ebins2)
  estart  = my_ens.E_BINS[0]
  eend    = my_ens.E_BINS[1]
  newels2 = (eend - estart)+1L  ;;  new # of high energy levels
  newels1 = nener - newels2     ;;  new # of low energy levels
  glow    = WHERE(allel LT estart OR allel GT eend,glo,COMPLEMENT=ghig,NCOMPLEMENT=ghi)
  ;;--------------------------------------------------------------------------------------
  ;;  Alter plot labels to avoid width issues
  ;;--------------------------------------------------------------------------------------
  CASE good[0] OF
    2    : BEGIN
      allen /= 1e3
      glow   = REVERSE(glow)
      ghig   = REVERSE(ghig)
      eunit  = ' keV'
    END
    ELSE : BEGIN
      allen = allen
      eunit = ' eV'
    END
  ENDCASE
  IF (glo EQ 0 OR glo EQ nener) THEN BEGIN
    MESSAGE,'Bad energy range defined!',/INFORMATION,/CONTINUE
    new_name = name
    IF (def_3d_str) THEN BEGIN
      myd = CREATE_STRUCT('YTITLE',d.YTITLE,'X',d.X,'Y',d.Y,'V1',d.V1,'V2',d.V2,$
                          'YLOG',d.YLOG,'LABELS',def_labs,'PANEL_SIZE',2.0)
    ENDIF ELSE BEGIN
      myd = CREATE_STRUCT('YTITLE',ytest,'X',d.X,'Y',d.Y,'V1',d.V1,'V2',d.V2,$
                          'YLOG',1,'LABELS',def_labs,'PANEL_SIZE',2.0)
    ENDELSE
    store_data,new_name,DATA=myd,DLIM=dlim,LIM=lim
  ENDIF
ENDIF ELSE BEGIN
  MESSAGE,'Keyword NOT SET: ENERGIES => No data was removed or changed!',/INFORMATION,/CONTINUE
  new_name = name
  IF (def_3d_str) THEN BEGIN
    myd = CREATE_STRUCT('YTITLE',d.YTITLE,'X',d.X,'Y',d.Y,'V1',d.V1,'V2',d.V2,$
                        'YLOG',d.YLOG,'LABELS',def_labs,'PANEL_SIZE',2.0)
  ENDIF ELSE BEGIN
    myd = CREATE_STRUCT('YTITLE',ytest,'X',d.X,'Y',d.Y,'V1',d.V1,'V2',d.V2,$
                        'YLOG',1,'LABELS',def_labs,'PANEL_SIZE',2.0)
  ENDELSE
  store_data,new_name,DATA=myd,DLIM=dlim,LIM=lim
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Define colors for low and high energies
;;----------------------------------------------------------------------------------------
cols1 = LINDGEN(glo)*(250L - 30L)/(glo - 1L) + 30L
cols2 = LINDGEN(ghi)*(250L - 30L)/(ghi - 1L) + 30L
IF (good[0] EQ 2) THEN BEGIN
;IF (sname EQ 'nsf' OR sname EQ 'nso') THEN BEGIN
  cols1 = REVERSE(cols1)
  cols2 = REVERSE(cols2)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define Y-Axis Titles
;;----------------------------------------------------------------------------------------
yttl1  = 'Energies:('+STRTRIM(STRING(FORMAT='(f15.1)',allen[glow[glo-1L]]),2)+$
           '-'+STRTRIM(STRING(FORMAT='(f15.1)',allen[glow[0]]),2)+eunit+')!C'+$
           STRUPCASE(STRMID(sname,1))+' '+gunits+' '+myang
yttl2  = 'Energies: ('+STRTRIM(STRING(FORMAT='(f15.1)',allen[ghig[ghi-1L]]),2)+$
           '-'+STRTRIM(STRING(FORMAT='(f15.1)',allen[ghig[0]]),2)+eunit+')!C'+$
           STRUPCASE(STRMID(sname,1))+' '+gunits+' '+myang
;;----------------------------------------------------------------------------------------
;;   Make sure TPLOT variable exists and can be used
;;----------------------------------------------------------------------------------------
CASE mdims OF
  3 : BEGIN
    GOTO,JUMP_3D
  END
  2 : BEGIN
    GOTO,JUMP_2D
  END
  1 : BEGIN
    MESSAGE,'Data structure has incorrect format...',/INFORMATION,/CONTINUE
    GOTO,JUMP_FIN
  END
  ELSE : BEGIN
    MESSAGE,'Data structure has incorrect format...',/INFORMATION,/CONTINUE
    GOTO,JUMP_FIN
  END
ENDCASE
;;----------------------------------------------------------------------------------------
;;   3D input array
;;----------------------------------------------------------------------------------------
;;========================================================================================
JUMP_3D:
;;========================================================================================
yttl1  = ''                       ;;  new Y-title for low E data
yttl2  = ''                       ;;  new Y-title for High E data
nlabs1 = STRARR(newels1)          ;;  new labels for low E
nlabs2 = STRARR(newels2)          ;;  new labels for high E
newy1  = FLTARR(nd1,newels1,nd3)  ;;  new data array for low energies
newy2  = FLTARR(nd1,newels2,nd3)  ;;  " " high energy
newv11 = FLTARR(nd1,newels1)      ;;  new energy array for low energies
newv12 = FLTARR(nd1,newels2)      ;;  " " high energies
newv21 = FLTARR(nd1,nd3)          ;;  angle arrays for low E
newv22 = FLTARR(nd1,nd3)          ;;  angle arrays for high E

IF (def_3d_str) THEN BEGIN
  nlabs1 = d.LABELS[glow]
  nlabs2 = d.LABELS[ghig]
ENDIF ELSE BEGIN
  nlabs1 = def_labs[glow]
  nlabs2 = def_labs[ghig]
ENDELSE
IF NOT KEYWORD_SET(new_name1) THEN new_name1 = name+'_Low'
IF NOT KEYWORD_SET(new_name2) THEN new_name2 = name+'_High'
newy1  = d.Y[*,glow,*]
newy2  = d.Y[*,ghig,*]
newv11 = d.V1[*,glow]
newv12 = d.V1[*,ghig]
newv21 = d.V2
newv22 = d.V2
;;----------------------------------------------------------------------------------------
;;  Create structures for tplot labels, Y-Titles, etc.
;;----------------------------------------------------------------------------------------
myd1 = CREATE_STRUCT('YTITLE',yttl1,'X',d.X,'Y',newy1,'V1',newv11,$
                     'V2',newv21,'YLOG',ylg,'LABELS',nlabs1,'PANEL_SIZE',2.0)
myd2 = CREATE_STRUCT('YTITLE',yttl2,'X',d.X,'Y',newy2,'V1',newv12,$
                     'V2',newv22,'YLOG',ylg,'LABELS',nlabs2,'PANEL_SIZE',2.0)

GOTO,JUMP_FIN
;;----------------------------------------------------------------------------------------
;;   2D input array
;;----------------------------------------------------------------------------------------
;;========================================================================================
JUMP_2D:
;;========================================================================================
nlabs1 = STRARR(newels1)          ;;   new labels for low E
nlabs2 = STRARR(newels2)          ;;   new labels for high E
newy1  = FLTARR(nd1,newels1)      ;;   new data array for low energies
newy2  = FLTARR(nd1,newels2)      ;;   " " high energy
newv1  = FLTARR(nd1,newels1)      ;;   new energy array for low energies
newv2  = FLTARR(nd1,newels2)      ;;   " " high energies
CASE lab_test[0] OF
  0    : BEGIN         ;;  LABELS tag in LIMIT structure
    nlabs1 = lim.LABELS[glow]
    nlabs2 = lim.LABELS[ghig]
  END
  1    : BEGIN         ;;  LABELS tag in DLIMIT structure
    nlabs1 = dlim.LABELS[glow]
    nlabs2 = dlim.LABELS[ghig]
  END
  ELSE : BEGIN
    nlabs1 = def_labs[glow]
    nlabs2 = def_labs[ghig]
  END
ENDCASE

IF NOT KEYWORD_SET(new_name1) THEN new_name1 = name+'_Low'
IF NOT KEYWORD_SET(new_name2) THEN new_name2 = name+'_High'
newy1  = d.Y[*,glow]
newy2  = d.Y[*,ghig]
newv1  = d.V[*,glow]
newv2  = d.V[*,ghig]
;;----------------------------------------------------------------------------------------
;;  Create structures for tplot labels, Y-Titles, etc.
;;----------------------------------------------------------------------------------------
mlim1  = CREATE_STRUCT('YTITLE',yttl1,'LABFLAG',1,'LABELS',nlabs1,$
                       'PANEL_SIZE',2.0,'YLOG',1)
mlim2  = CREATE_STRUCT('YTITLE',yttl2,'LABFLAG',1,'LABELS',nlabs2,$
                       'PANEL_SIZE',2.0,'YLOG',1)
myd1   = CREATE_STRUCT('X',d.X,'Y',newy1,'V',newv1)
myd2   = CREATE_STRUCT('X',d.X,'Y',newy2,'V',newv2)

;;========================================================================================
JUMP_FIN:
;;========================================================================================

;;----------------------------------------------------------------------------------------
;;  Determine new ylimits
;;----------------------------------------------------------------------------------------
gylim1 = WHERE(newy1 GT 0.0 AND FINITE(newy1),gyli1)
gylim2 = WHERE(newy2 GT 0.0 AND FINITE(newy2),gyli2)
;;  New data set 1
IF (gyli1 GT 0) THEN BEGIN
  gind  = ARRAY_INDICES(newy1,gylim1)
  IF (nd3 EQ 0) THEN BEGIN
    ;;  2D TPLOT structure
    ymin1 = MIN(newy1[gind[0,*],gind[1,*]],/NAN)/1.1
    ymax1 = MAX(newy1[gind[0,*],gind[1,*]],/NAN)*1.1
  ENDIF ELSE BEGIN
    ;;  3D TPLOT structure
    ymin1 = MIN(newy1[gind[0,*],gind[1,*],gind[2,*]],/NAN)/1.1
    ymax1 = MAX(newy1[gind[0,*],gind[1,*],gind[2,*]],/NAN)*1.1
  ENDELSE
ENDIF ELSE BEGIN
  ymin1 = MIN(newy1,/NAN)/1.1
  ymax1 = MAX(newy1,/NAN)*1.1
ENDELSE
;;  New data set 2
IF (gyli2 GT 0) THEN BEGIN
  gind  = ARRAY_INDICES(newy2,gylim2)
  IF (nd3 EQ 0) THEN BEGIN
    ;;  2D TPLOT structure
    ymin2 = MIN(newy2[gind[0,*],gind[1,*]],/NAN)/1.1
    ymax2 = MAX(newy2[gind[0,*],gind[1,*]],/NAN)*1.1
  ENDIF ELSE BEGIN
    ;;  3D TPLOT structure
    ymin2 = MIN(newy2[gind[0,*],gind[1,*],gind[2,*]],/NAN)/1.1
    ymax2 = MAX(newy2[gind[0,*],gind[1,*],gind[2,*]],/NAN)*1.1
  ENDELSE
ENDIF ELSE BEGIN
  ymin2 = MIN(newy2,/NAN)/1.1
  ymax2 = MAX(newy2,/NAN)*1.1
ENDELSE
;;----------------------------------------------------------------------------------------
;;  Split into 2 new TPLOT variables if desired
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(split) THEN BEGIN
  IF (nd3 EQ 0) THEN BEGIN
    ;;  2D TPLOT structure
    store_data,new_name1,DATA=myd1,DLIM=dlim,LIM=mlim1
    store_data,new_name2,DATA=myd2,DLIM=dlim,LIM=mlim2
  ENDIF ELSE BEGIN
    ;;  3D TPLOT structure
    store_data,new_name1,DATA=myd1,DLIM=dlim,LIM=lim
    store_data,new_name2,DATA=myd2,DLIM=dlim,LIM=lim
  ENDELSE
  options,new_name1,'COLORS',cols1
  options,new_name2,'COLORS',cols2
  options,[new_name1,new_name2],'YMINOR',9
  ylim,new_name1,ymin1,ymax1,1
  ylim,new_name2,ymin2,ymax2,1
ENDIF ELSE BEGIN
  IF (nd3 EQ 0) THEN BEGIN
    ;;  2D TPLOT structure
    store_data,new_name1,DATA=myd1,DLIM=dlim,LIM=mlim1
  ENDIF ELSE BEGIN
    ;;  3D TPLOT structure
    store_data,new_name1,DATA=myd1,DLIM=dlim,LIM=lim
  ENDELSE
  IF NOT KEYWORD_SET(new_name1) THEN new_name1 = name+'_rmv'
  options,new_name1,'COLORS',cols1
  options,new_name1,'YMINOR',9
  ;;--------------------------------------------------------------------------------------
  ;;  Determine new ylimits
  ;;--------------------------------------------------------------------------------------
  ylim,new_name1,ymin1,ymax1,1
ENDELSE

;;****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATION,/CONTINUE
;;****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
