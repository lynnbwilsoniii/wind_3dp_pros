;+
;*****************************************************************************************
;
;  FUNCTION :   padspecs_writer.pro
;  PURPOSE  :   Creates an ASCII file associated with any given pitch-angle (PA)
;                 spectra you desire from the 3DP instruments.  The files are 
;                 printed with repeating time values because of the 3-D input 
;                 array format.  So each row is the data and energy bin values
;                 for every PA at a given time.  Thus if one has 15 PA's, then
;                 the first 15 rows will represent data at a single time stamp
;                 but at different PA's.  The column represents the data in each
;                 energy bin, row is the PA, and every 15 rows (in this example)
;                 a new time step occurs.  The last columns are the energy bin
;                 values determined by the routine, my_3dp_energy_bins.pro.
;                 This program is useful for loading large time periods with 
;                 a lot of 3DP moments because it allows one to create ASCII files
;                 which don't require WindLib to run, thus saving on RAM and time.
;                 The output is the same result one might get from the routine
;                 get_padspecs.pro.  The only thing done to the data is a separation
;                 into PA's and unit conversion to flux from counts.
;
;  CALLED BY:   NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               get_padspecs.pro
;               energy_params_3dp.pro
;               get_data.pro
;               dat_3dp_energy_bins.pro
;               my_3dp_plot_labels.pro
;
;  REQUIRES:    
;               Wind 3DP AND magnetic field data MUST be loaded first
;
;  INPUT:
;               NAME    :  [string] Specify the type of structure you wish to 
;                            get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    print, my_padspec_writer('sf',TRANGE=trange)
;
;  KEYWORDS:  
;               EBINS   :  [array,scalar] specifying which energy bins to create 
;                            particle spectra plots for
;               VSW     :  [string,tplot index] specifying a solar wind velocity
;               TRANGE  :  [Double] 2 element array specifying the range over 
;                            which to get data structures [Unix time]
;               NUM_PA  :  Number of pitch-angles to sum over (Default = 8L)
;
;   CHANGED:  1)  Changed structure formats                 [08/13/2008   v1.0.2]
;             2)  Changed 'man' page                        [09/15/2008   v1.0.3]
;             3)  Updated 'man' page                        [11/11/2008   v1.0.4]
;             4)  Added keyword:  NUM_PA                    [02/25/2009   v1.1.0]
;             5)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                   and my_get_padspec_5.pro to get_padspecs.pro
;                   and my_energy_params.pro to energy_params_3dp.pro
;                   and renamed from my_padspec_writer.pro  [08/12/2009   v2.0.0]
;
;   CREATED:  08/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-


FUNCTION padspecs_writer,name,EBINS=ebins,VSW=vsw,TRANGE=trange,NUM_PA=num_pa

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
mynpa = 0L  ; # of angle bins to sum over for different spec plots
pname = ''  ; -E.G. 'EL'
name  = STRLOWCASE(name)
;-----------------------------------------------------------------------------------------
; -Make sure name is in the correct format
;-----------------------------------------------------------------------------------------
strns = dat_3dp_str_names(name)
name  = strns.SN
pname = STRUPCASE(name)

meps  = energy_params_3dp(name)
mener = meps.NENER
IF NOT KEYWORD_SET(num_pa) THEN BEGIN
  mynpa = meps.ANGLES             ; -pitch-angle estimates for non-finite angle estimates
ENDIF ELSE BEGIN
  mynpa = num_pa
ENDELSE

store_re = 1
IF KEYWORD_SET(vsw) THEN BEGIN  
  get_padspecs,name,BSOURCE='wi_B3(GSE)',NUM_PA=mynpa,VSOURCE=vsw,TRANGE=trange,$
                    STORE_RE=store_re
  dat = store_re
ENDIF ELSE BEGIN
  get_padspecs,name,BSOURCE='wi_B3(GSE)',NUM_PA=mynpa,TRANGE=trange,STORE_RE=store_re
  dat = store_re
ENDELSE
;-----------------------------------------------------------------------------------------
; -Determine energy bin values
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(ebins) THEN BEGIN
  ebins2 = ebins
ENDIF ELSE BEGIN
  ebins2 = ebins2
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
;gvals  = WHERE(datv1 EQ 0.0,gvls)
IF (gvls GT 0) THEN BEGIN
  datv1 = dat.V1
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
dat2 = CREATE_STRUCT('YTITLE',name,'X',dat.X,'Y',daty[*,estart:eend,*],'V1',datv1,$
                     'V2',dat.V2,'YLOG',1,'LABELS',mylb[estart:eend],'PANEL_SIZE',2.0)

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
mstr = CREATE_STRUCT('YTITLE',name+'_PADS (FLUX)','X',dat.X,'Y',daty[*,estart:eend,*],$
                     'V1',datv1,'V2',dat.V2,'YLOG',1,'LABELS',mylabs,'PANEL_SIZE',2.0)
;-----------------------------------------------------------------------------------------
; -get rid of negative and/or zeroed data points
;-----------------------------------------------------------------------------------------
bdpts = WHERE(mstr.Y LE 0.0,bp)
IF (bp GT 0) THEN BEGIN
  dind = ARRAY_INDICES(mstr.Y,bdpts)
  mstr.Y[dind[0,*],dind[1,*],dind[2,*]] = !VALUES.F_NAN
ENDIF
;-----------------------------------------------------------------------------------------
; -Create variables for header
;-----------------------------------------------------------------------------------------
nm = ''         ; -Name associated w/ 3DP data structures used for data
un = ''         ; -Units associated w/ data
da = ''         ; -Date of event
la = ''         ; -Energy bin labels
pa = ''         ; -Pitch-Angle labels

tra = time_string([MIN(mstr.X,/NAN),MAX(mstr.X,/NAN)],prec=3)  ; -['YYYY-MM-DD/HH:MM:SS.xxx']
d1  = STRMID(tra[0],5,2)+'-'+STRMID(tra[0],8,2)+'-'+STRMID(tra[0],0,4)  ; -['MM-DD-YYYY']
d2  = STRMID(tra[1],5,2)+'-'+STRMID(tra[1],8,2)+'-'+STRMID(tra[1],0,4)  ; -['MM-DD-YYYY']
t1  = STRMID(tra[0],11,8)  ; -['HH:MM:SS']
t2  = STRMID(tra[1],11,8)
s1  = STRMID(t1,0,2)+STRMID(t1,3,2)+STRMID(t1,6,2)  ; -['HHMMSS']
s2  = STRMID(t2,0,2)+STRMID(t2,3,2)+STRMID(t2,6,2)


pas = TOTAL(mstr.V2,1,/NAN)/TOTAL(FINITE(mstr.V2),1,/NAN)
pas = STRTRIM(STRING(format='(f12.2)',pas),2)+'!Uo!N'

ndim = SIZE(mstr.Y,/DIMENSIONS)
n    = ndim[0]  ; -# of time steps
m    = ndim[1]  ; -# of energy bins
l    = ndim[2]  ; -# of pitch-angles

llabs = ''
FOR i=0L, m-1L DO BEGIN
  llabs = llabs+' '+mylabs[i]
ENDFOR
ppans = ''
FOR i=0L, l-1L DO BEGIN
  ppans = ppans+' '+pas[i]
ENDFOR


nm = strns.LC   ; -E.G. 'Eesa Low Burst'
nm = 'NAME   :  '+nm
un = 'UNITS  :  Flux (# cm!U-2!N s!U-1!N sr!U-1!N eV!U-1!N)'
da = 'DATE   :  '+d1+'/'+t1+' - '+d2+'/'+t2
la = 'LABELS :  '+llabs
pa = 'PANGS  :  '+ppans
;-----------------------------------------------------------------------------------------
; -Define output file name and print data to file
;-----------------------------------------------------------------------------------------
mdir    = FILE_EXPAND_PATH('')
outfile = mdir+'/'+name+'_'+'spec'+'_'+d1+'-'+s1+'_'+d2+'-'+s2+'.txt'
myformat = '(e20.12,'+STRTRIM(m,2)+'e24.12,'+STRTRIM(m,2)+'f12.2)'
OPENW,gunit,outfile,/GET_LUN
  PRINTF,gunit,nm
  PRINTF,gunit,un
  PRINTF,gunit,da
  PRINTF,gunit,la
  PRINTF,gunit,pa
  PRINTF,gunit,"FORMAT :  "+myformat
  PRINTF,gunit,""
  FOR j=0L, n - 1L DO BEGIN
    FOR k=0L, l - 1L DO BEGIN
      PRINTF,gunit,mstr.X[j],mstr.Y[j,*,k],mstr.V1[j,*],FORMAT=myformat
    ENDFOR
  ENDFOR
FREE_LUN,gunit
;**************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;**************************************************************************
RETURN,0
END
