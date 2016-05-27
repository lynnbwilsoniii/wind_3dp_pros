;+
;*****************************************************************************************
;
;  FUNCTION :   calc_padspecs.pro
;  PURPOSE  :   Creates particle spectra "TPLOT" variables by summing 3DP data over
;                 selected angle bins.  The output is a series of TPLOT variables
;                 including the raw data (e.g. 'nel_pads'), pitch-angle separated
;                 data (e.g. 'nel_pads-2-0:1'), smoothed/cleaned pitch-angle separated
;                 data (e.g. 'nel_pads-2-0:1_cln'), and shifted&normalized pitch-angle
;                 separated data (e.g. 'nel_pads-2-0:1_cln_shn').
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               wind_3dp_units.pro
;               get_padspecs.pro
;               energy_params_3dp.pro
;               get_data.pro
;               dat_3dp_energy_bins.pro
;               store_data.pro
;               options.pro
;               my_3dp_plot_labels.pro
;               reduce_pads.pro
;               clean_spec_spikes.pro
;               spec_vec_data_shift.pro
;               omni_z_pads.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NAME       :  [string] Specify the type of structure you wish to 
;                               get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:
;               elbspec = calc_padspecs('elb',TRANGE=tr)
;
;  KEYWORDS:  
;               EBINS      :  [array,scalar] specifying which energy bins to create 
;                               particle spectra plots for
;               VSW        :  [string,tplot index] specifying a solar wind velocity
;               TRANGE     :  [Double] 2 element array specifying the range over 
;                               which to get data structures for
;               DAT_ARR    :  N-Element array of data structures from get_??.pro
;                               [?? = 'el','eh','elb',etc.]
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
;               G_MAGF     :  If set, tells program that the structures in DAT_ARR 
;                               already have the magnetic field added to them thus 
;                               preventing this program from calling add_magf2.pro 
;                               again.
;               NUM_PA     :  Number of pitch-angles to sum over 
;                               [Default = defined by instrument]
;               UNITS      :  Wind/3DP data units for particle data include:
;                               'df','counts','flux','eflux',etc.
;                                [Default = 'flux']
;               RANGE_AVG  :  Two element double array specifying the time range
;                               (Unix time) to use for constructing an average to
;                               normalize the data by when using the keyword DAT_NORM
;               NO_KILL    :  If set, get_padspecs.pro will NOT call the routine
;                               sst_foil_bad_bins.pro
;
;   CHANGED:  1)  Altered return TPLOT variables             [07/10/2008   v1.2.31]
;             2)  Updated man page                           [03/18/2009   v1.2.32]
;             3)  Added keyword:  DAT_ARR                    [04/24/2009   v1.3.0]
;             4)  Added keywords: DAT_SHFT, DAT_NORM, and DAT_CLN
;                                                            [04/24/2009   v1.3.1]
;             5)  Added keyword:  G_MAGF                     [04/26/2009   v1.3.2]
;             6)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_energy_params.pro to energy_params_3dp.pro
;                   and my_get_padspec_5.pro to get_padspecs.pro
;                   and renamed from my_padspec_4.pro        [08/11/2009   v2.1.0]
;             7)  Changed program my_clean_spikes_2.pro to clean_spec_spikes.pro
;                   and my_data_shift_2.pro to spec_vec_data_shift.pro
;                   and added keyword:  NUM_PA
;                   and z_pads_2.pro to omni_z_pads.pro      [08/12/2009   v2.2.0]
;             8)  Fixed syntax error                         [09/09/2009   v2.2.1]
;             9)  Added keywords:  UNITS and RANGE_AVG
;                   and now depends on wind_3dp_units.pro    [09/30/2009   v2.3.0]
;            10)  Fixed typo in calling get_data.pro and added keyword:
;                   NO_KILL                                  [08/13/2010   v2.3.1]
;            11)  Forgot to actually add RANGE_AVG to calling sequence
;                                                            [11/01/2010   v2.4.0]
;            12)  Fixed a typo with EBINS                    [04/25/2011   v2.4.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  04/25/2011   v2.4.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION calc_padspecs,name,EBINS=ebins,VSW=vsw,TRANGE=trange,DAT_ARR=dat_arr,   $
                            DAT_SHFT=dat_shft,DAT_NORM=dat_norm,DAT_CLN=dat_cln, $
                            G_MAGF=g_magf,NUM_PA=num_pa,UNITS=units,             $
                            RANGE_AVG=range_avg,NO_KILL=no_kill

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Create Dummy Structure and variables
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(num_pa) EQ 0) THEN num_pa = 8
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
mynpa  = 0L                          ; # of angle bins to sum over for different spec plots
pname  = ''                          ; -E.G. 'EL'
funits = '(# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'  ; => Units of # Flux
name   = STRLOWCASE(name)
dum_v1 = REPLICATE(f,100,15)         ; => {i.e. [100 time steps,15 Energies] }
dum_v2 = REPLICATE(f,100,num_pa)     ; => {i.e. [100 time steps,num_pa Pitch-Angles] }
dum_x  = REPLICATE(d,100)            ; => Dummy time variable
dum_y  = REPLICATE(f,100,15,num_pa)  ; => {i.e. [100 time steps,15 Energies,num_pa Pitch-Angles]}
dum_l  = REPLICATE('',15)            ; => Dummy data labels
dum_t  = ['YTITLE','X','Y','V1','V2','YLOG','LABELS','PANEL_SIZE']
dummy  = CREATE_STRUCT(dum_t,name,dum_x,dum_y,dum_v1,dum_v2,0,dum_l,2.0)


IF KEYWORD_SET(dat_cln)  THEN d_cln   = 1 ELSE d_cln   = 0
IF KEYWORD_SET(dat_shft) THEN d_shift = 1 ELSE d_shift = 0
IF KEYWORD_SET(dat_norm) THEN d_norm  = 1 ELSE d_norm  = 0
IF (d_shift) THEN sffx_d0  = '_sh'  ELSE sffx_d0 = ''
IF (d_norm)  THEN sffx_d0 += '_n'
IF (d_cln)   THEN sffx_d1  = '_cln' ELSE sffx_d1 = ''
;-----------------------------------------------------------------------------------------
; => Make sure name is in the correct format
;-----------------------------------------------------------------------------------------
strns = dat_3dp_str_names(name)
name  = strns.SN
pname = STRUPCASE(name)
;-----------------------------------------------------------------------------------------
; => Check input units
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(units)  THEN gunits = 'flux' ELSE gunits = units[0]
new_units = wind_3dp_units(gunits)
gunits    = new_units.G_UNIT_NAME      ; => e.g. 'flux'
punits    = new_units.G_UNIT_P_NAME    ; => e.g. ' (# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'
;-----------------------------------------------------------------------------------------
; => Define Default energy and pitch-angle information
;-----------------------------------------------------------------------------------------
meps  = energy_params_3dp(name)
; -pitch-angle estimates for non-finite angle estimates
IF NOT KEYWORD_SET(num_pa) THEN mynpa = meps.ANGLES ELSE mynpa = num_pa[0]
mener = meps.NENER

IF KEYWORD_SET(ebins) THEN BEGIN
  ebins2 = ebins
ENDIF ELSE BEGIN
  ebins2 = ebins2
ENDELSE
;-----------------------------------------------------------------------------------------
; => Create PA Stacked Spectra TPLOT variable
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(vsw) THEN BEGIN  
  get_padspecs,name,BSOURCE='wi_B3(GSE)',NUM_PA=mynpa,vsource=vsw,$
                    TRANGE=trange,DAT_ARR=dat_arr,G_MAGF=g_magf,$
                    UNITS=gunits,NO_KILL=no_kill
  get_data, name+'_pads',DATA=dat,DLIM=dlim,LIM=lim
ENDIF ELSE BEGIN
  get_padspecs,name,BSOURCE='wi_B3(GSE)',NUM_PA=mynpa,$
                    TRANGE=trange,DAT_ARR=dat_arr,G_MAGF=g_magf,$
                    UNITS=gunits,NO_KILL=no_kill
  get_data, name+'_pads',DATA=dat,DLIM=dlim,LIM=lim
ENDELSE

my_ens = dat_3dp_energy_bins(dat,EBINS=ebins2)

estart = my_ens.E_BINS[0]
eend   = my_ens.E_BINS[1]
myen   = my_ens.ALL_ENERGIES

PRINT,''
PRINT,'estart = ',estart
PRINT,'eend   = ',eend
PRINT,'Energies = ',myen
PRINT,''

myn   = N_ELEMENTS(dat)
datv1 = dat.V1[*,estart:eend]
mbins = N_ELEMENTS(dat.V1[*,0])       ; # of samples
daty  = dat.Y
;-----------------------------------------------------------------------------------------
; -Make sure energies haven't been labeled as zeros
;-----------------------------------------------------------------------------------------
gvals  = WHERE(datv1 LE 0.0 OR FINITE(datv1) EQ 0,gvls)
IF (gvls GT 0) THEN BEGIN
;  datv1 = dat.v1
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
    MESSAGE,'Improper Data Structure Name!',/INFORMATION,/CONTINUE
    MESSAGE,"Examples: 'el', 'eh', 'pl', 'ph', 'elb', 'ehb', 'sf', etc.",$
            /INFORMATION,/CONTINUE
    RETURN,dummy
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; -Determine plot labels and positions
;-----------------------------------------------------------------------------------------
dat2 = CREATE_STRUCT(dum_t,name,dat.X,daty[*,estart:eend,*],datv1,dat.V2,1,$
                     mylb[estart:eend],2.0)

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
nyttl = name+gunits[0]+'!C'+punits[0]
mstr  = CREATE_STRUCT(dum_t,nyttl,dat.X,daty[*,estart:eend,*],datv1,dat.V2,1,mylabs,2.0)
;-----------------------------------------------------------------------------------------
; -Get rid of data points < 0.
;-----------------------------------------------------------------------------------------
bdpts = WHERE(mstr.Y LE 0.0,bp)
IF (bp GT 0) THEN BEGIN
  dind = ARRAY_INDICES(mstr.Y,bdpts)
  mstr.Y[dind[0,*],dind[1,*],dind[2,*]] = f
ENDIF

newna = ''
newna = 'n'+name+'_pads'
;-----------------------------------------------------------------------------------------
; -return new data as TPLOT variable
;-----------------------------------------------------------------------------------------
store_data,newna,DATA=mstr,DLIM=dlim,LIM=lim

shon = ''
shon = STRMID(newna,0,3)
options,newna,'YTITLE',pname+' '+gunits[0]+'!C'+punits[0]
options,newna,'XMINOR',4    ; -set # of minor X-Tick marks to 4
options,newna,'YMINOR',9    ; -set # of minor Y-Tick marks to 9
;-----------------------------------------------------------------------------------------
; -Make sure y-limits are not determined by "zeroed" data or NAN's
;-----------------------------------------------------------------------------------------
gy11 = WHERE(mstr.Y GT 0.0 AND FINITE(mstr.Y),g11)
IF (g11 GT 0) THEN BEGIN
  gyind1 = ARRAY_INDICES(mstr.y,gy11)
  ymin1  = MIN(mstr.Y[gyind1[0,*],gyind1[1,*],gyind1[2,*]],/NAN)/1.1
  ymax1  = MAX(mstr.Y[gyind1[0,*],gyind1[1,*],gyind1[2,*]],/NAN)*1.1
  options,newna,'YRANGE',[ymin1,ymax1]
  options,newna,'YLOG',1
ENDIF
;-----------------------------------------------------------------------------------------
; -Determine # of data points to smooth over when "cleaning" data spikes
;-----------------------------------------------------------------------------------------
mysip = (SIZE(mstr.Y,/DIMENSIONS))[0]/800L
IF (mysip GT 3L AND mysip LE 12L) THEN BEGIN
  hsmooth = mysip + 1L
  lsmooth = LONG(3./5.*hsmooth)
ENDIF ELSE BEGIN
  IF (mysip GT 12L) THEN BEGIN
    hsmooth = 12L
    lsmooth = 7L
  ENDIF ELSE BEGIN
    hsmooth = 3L
    lsmooth = 3L
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; - Created a normalized spectrum to observe relative changes in flux
;-----------------------------------------------------------------------------------------
IF (shon EQ 'nsf' OR shon EQ 'nso') THEN lbflg = -1 ELSE lblfg = 1
options,newna,'LABFLAG',lbflg
CASE shon OF
  'nsf' : BEGIN
    mysmp  = [0,2,hsmooth]    ; -weighted smoothing parameters for cleaning program
    mysnp  = lsmooth          ; -base smoothing step " "
  END
  'nso' : BEGIN
    mysmp = [0,2,hsmooth]     ; -weighted smoothing parameters for cleaning program
    mysnp = lsmooth           ; -base smoothing step " "    
  END
  'nel' : BEGIN
    IF (STRMID(newna,0,4) EQ 'nelb') THEN BEGIN
      hsmooth = 2
      lsmooth = 2
      mysmp   = [0,2,hsmooth]
      mysnp   = lsmooth       ; -base smoothing step " "        
    ENDIF ELSE BEGIN
      mysmp = [0,2,hsmooth]
      mysnp = lsmooth         ; -base smoothing step " "        
    ENDELSE
  END  
  ELSE : BEGIN
    mysmp = [0,2,hsmooth]
    mysnp = lsmooth           ; -base smoothing step " "        
  END
ENDCASE

IF (d_cln) THEN BEGIN         ; => Smooth data if desired
  newna2 = newna
  clean_spec_spikes,newna2,NSMOOTH=mysnp,ESMOOTH=mysmp,NEW_NAME=newna2+sffx_d1
ENDIF

IF (d_shift OR d_norm) THEN BEGIN  ; => Normalize and/or Shift data if desired
  spec_vec_data_shift,newna2,NEW_NAME=newna2+sffx_d0,DATN=d_norm,DATS=d_shift,  $
                             RANGE_AVG=range_avg
  spec_vec_data_shift,newna2+'_cln',NEW_NAME=newna2+'_cln'+sffx_d0,DATN=d_norm, $
                             DATS=d_shift,RANGE_AVG=range_avg
ENDIF
;-----------------------------------------------------------------------------------------
; => Separate PADs by angle w/ respect to B-field direction (deg)
;-----------------------------------------------------------------------------------------
myangs  = STRARR(mynpa - 1L)
ang     = FLTARR(2,mynpa - 1L)
FOR i=0, mynpa - 2L DO BEGIN
  j        = i + 1L
  pang     = FLTARR(2)
  reduce_pads,newna,2,i,j,ANGLES=pang,/NAN
  ang[*,i] = pang
ENDFOR
myangs  = STRTRIM(STRING(FORMAT='(f5.1)',ang[0,*]),1)
myangs += '-'+STRTRIM(STRING(FORMAT='(f5.1)',ang[1,*]),1)+'!Uo!N'
zdata   = omni_z_pads(newna,LABS=mylabs,PANGS=myangs)
;-----------------------------------------------------------------------------------------
; => Smooth the data to remove noise and NaNs
;-----------------------------------------------------------------------------------------
FOR i=0L, mynpa - 2L DO BEGIN
  tdata = zdata[i]
  tangl = myangs[i]
  options,tdata,'YTITLE',pname+'!C'+tangl
  IF (d_cln) THEN BEGIN
    clean_spec_spikes,tdata,NSMOOTH=mysnp,ESMOOTH=mysmp,NEW_NAME=tdata+sffx_d1
  ENDIF
ENDFOR
;-----------------------------------------------------------------------------------------
; => Created a normalized spectrum to observe relative changes in flux
;-----------------------------------------------------------------------------------------
FOR i=0L, mynpa - 2L DO BEGIN
  tdata = zdata[i]
  tangl = myangs[i]
  IF (d_shift OR d_norm) THEN BEGIN
    spec_vec_data_shift,tdata,NEW_NAME=tdata+sffx_d0,DATN=d_norm,DATS=d_shift,$
                              RANGE_AVG=range_avg
    IF (d_shift AND d_norm) THEN BEGIN
      options,tdata+sffx_d0,'YTITLE',pname+' Normalized & Shifted'+'!C'+tangl
    ENDIF
  ENDIF
ENDFOR

nnw = tnames()
options,nnw,"YSTYLE",1
options,nnw,"PANEL_SIZE",2.
options,nnw,'XMINOR',5
options,nnw,'YMINOR',9
options,nnw,'XTICKLEN',0.04
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/cont,/info
;*****************************************************************************************
RETURN, mstr
END
