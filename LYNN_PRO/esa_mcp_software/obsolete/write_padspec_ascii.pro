;+
;*****************************************************************************************
;
;  FUNCTION :   write_padspec_ascii.pro
;  PURPOSE  :   Creates an ASCII file associated with any given pitch-angle (PA)
;                 spectra you desire from the 3DP instruments.  The files are 
;                 printed with repeating time values because of the 3-D input 
;                 array format.  So each row is the data and energy bin values
;                 for every PA at a given time.  Thus if one has 15 PA's, then
;                 the first 15 rows will represent data at a single time stamp
;                 but at different PA's.  The column represents the data in each
;                 energy bin, row is the PA, and every 15 rows (in this example)
;                 a new time step occurs.  The last columns are the energy bin
;                 values determined by the routine, dat_3dp_energy_bins.pro.
;                 This program is useful for loading large time periods with 
;                 a lot of 3DP moments because it allows one to create ASCII files
;                 which don't require WindLib to run, thus saving on RAM and time.
;                 The output is the same result one might get from the routine
;                 get_padspecs.pro.  The only thing done to the data is 
;                 a separation into PA's and unit conversion to flux from counts.
;
;  CALLED BY:   NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               wind_3dp_units.pro
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
;               NAME     :  [string] Specify the type of structure you wish to 
;                             get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    
;               ...................................................
;               : Produce energy flux spectra with 8 pitch-angles :
;               ...................................................
;               write_padspec_ascii,'sf',TRANGE=trange,BSOURCE='wi_B3(GSE)',NUM_PA=8L
;                                        UNITS='eflux'
;
;  KEYWORDS:  
;               EBINS    :  [array,scalar] specifying which energy bins to create 
;                             particle spectra plots for
;               VSW      :  [string,tplot index] specifying a solar wind velocity
;               TRANGE   :  [Double] 2 element array specifying the range over 
;                             which to get data structures [Unix time]
;               NUM_PA   :  Number of pitch-angles to sum over (Default = 8L)
;               DAT_ARR  :  N-Element array of data structures from get_??.pro
;                              [?? = 'el','eh','elb',etc.]
;               BSOURCE  :  Scalar string associated with TPLOT variable defining the 
;                              relevant magnetic field data to use for calculation of 
;                              pitch-angles
;               UNITS    :  Wind/3DP data units for particle data include:
;                             'df','counts','flux','eflux',etc.
;                              [Default = 'flux']
;               G_MAGF   :  If set, tells program that the structures in DAT_ARR 
;                             already have the magnetic field added to them thus 
;                             preventing this program from calling add_magf2.pro 
;                             again.
;               NO_KILL  :  If set, get_padspecs.pro will NOT call the routine
;                             sst_foil_bad_bins.pro
;
;   CHANGED:  1)  Changed structure formats                       [08/13/2008   v1.0.2]
;             2)  Changed 'man' page                              [09/15/2008   v1.0.3]
;             3)  Updated 'man' page                              [11/11/2008   v1.0.4]
;             4)  Added keyword:  NUM_PA                          [02/25/2009   v1.1.0]
;             5)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_energy_params.pro to energy_params_3dp.pro
;                   and my_get_padspec_5.pro to get_padspecs.pro
;                   and added keywords:  DAT_ARR, BSOURCE, G_MAGF, and UNITS
;                   and added program:  wind_3dp_units.pro
;                   and renamed from my_padspec_writer.pro        [09/19/2009   v2.0.0]
;             6)  Changed file naming to allow for the units to become part of the 
;                   file name for easier sorting and finding      [09/21/2009   v2.0.1]
;             7)  Added keyword:  NO_KILL                         [02/25/2010   v2.1.0]
;
;   CREATED:  08/12/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/25/2010   v2.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO write_padspec_ascii,name,EBINS=ebins,VSW=vsw,TRANGE=trange,NUM_PA=num_pa,  $
                             DAT_ARR=dat_arr,UNITS=units,BSOURCE=bsource,      $
                             G_MAGF=g_magf,NO_KILL=no_kill

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************

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
; => Define dummy variables
;-----------------------------------------------------------------------------------------
meps  = energy_params_3dp(name)
; -pitch-angle estimates for non-finite angle estimates
IF NOT KEYWORD_SET(num_pa) THEN mynpa = meps.ANGLES ELSE mynpa = num_pa[0]
mener = meps.NENER              ; => Number of available energy bins for specified type
; => Check to see if only specific energy bins are desired
IF KEYWORD_SET(ebins) THEN BEGIN
  ebins2 = ebins
ENDIF ELSE BEGIN
  ebins2 = ebins2
ENDELSE

IF NOT KEYWORD_SET(bsource) THEN bsource = 'wi_B3(GSE)'
;-----------------------------------------------------------------------------------------
; => Calculate Pitch-Angle Spectrograms
;-----------------------------------------------------------------------------------------
store_re = 1
IF KEYWORD_SET(vsw) THEN BEGIN  
  get_padspecs,name,BSOURCE='wi_B3(GSE)',NUM_PA=mynpa,vsource=vsw,UNITS=gunits,   $
                    TRANGE=trange,DAT_ARR=dat_arr,G_MAGF=g_magf,STORE_RE=store_re,$
                    NO_KILL=no_kill
ENDIF ELSE BEGIN
  get_padspecs,name,BSOURCE='wi_B3(GSE)',NUM_PA=mynpa,UNITS=gunits,               $
                    TRANGE=trange,DAT_ARR=dat_arr,G_MAGF=g_magf,STORE_RE=store_re,$
                    NO_KILL=no_kill
ENDELSE
;-----------------------------------------------------------------------------------------
; => Determine energy bin values
;-----------------------------------------------------------------------------------------
dat    = store_re
my_ens = dat_3dp_energy_bins(dat,EBINS=ebins2)

estart = my_ens.E_BINS[0]
eend   = my_ens.E_BINS[1]
myen   = my_ens.ALL_ENERGIES

; => Define the energies, pitch-angles (PAs), and data
daty  = dat.Y[*,estart:eend,*]
ndims = SIZE(REFORM(daty),/DIMENSIONS)  ; => # of elements/dimension
nd1   = ndims[0]                        ; => Typically for spec data = # of time steps
nd2   = ndims[1]                        ; => Typically for spec data = # of energy bins
nd3   = ndims[2]                        ; => Typically for spec data = # of pitch-angles
datv1 = FLTARR(nd1,nd2)                 ; => [N-Times,M-Energies]-Element Array of Energies
datv2 = FLTARR(nd1,nd3)                 ; => [N-Times,L-PAs]-Element Array of PAs

datv1 = dat.V1[*,estart:eend]
datv2 = dat.V2
mbins = nd1
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
    RETURN
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Determine plot labels and positions
;-----------------------------------------------------------------------------------------
mstr = CREATE_STRUCT('YTITLE',name,'X',dat.X,'Y',daty,'V1',datv1,$
                     'V2',datv2,'YLOG',1,'LABELS',mylb[estart:eend],'PANEL_SIZE',2.0)
;-----------------------------------------------------------------------------------------
; => Check data to make sure no data is LE 0.0
;-----------------------------------------------------------------------------------------
bad = WHERE(mstr.Y LE 0.,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (bd GT 0L) THEN BEGIN
  dind                                  = ARRAY_INDICES(mstr.Y,bdpts)
  mstr.Y[dind[0,*],dind[1,*],dind[2,*]] = !VALUES.F_NAN
ENDIF

dat_lab_posi = my_3dp_plot_labels(mstr)

myposi = dat_lab_posi.POSITIONS
mylabs = dat_lab_posi.LABELS
myen   = myen[estart:eend]
mylb   = mylb[estart:eend]

baabs  = WHERE(FINITE(mylabs) EQ 0,baa)  ; -make sure labels are not NAN's
IF (baa GT 0) THEN BEGIN
  mylabs[baabs] = mylb[baabs]
ENDIF
;-----------------------------------------------------------------------------------------
; => Redefine data structure for later use
;-----------------------------------------------------------------------------------------
mstr = CREATE_STRUCT('YTITLE',name+'_PADS (FLUX)','X',dat.X,'Y',daty,'V1',datv1,$
                     'V2',datv2,'YLOG',1,'LABELS',mylabs,'PANEL_SIZE',2.0)
;-----------------------------------------------------------------------------------------
; => Create variables for header
;-----------------------------------------------------------------------------------------
nm    = ''           ; -Wind/3DP data structure name [e.g. 'Eesa Low Burst']
un    = ''           ; -Unit definition [e.g. 'UNITS  :  flux (# cm!U-2!N s!U-1!N sr!U-1!N eV!U-1!N)']
da    = ''           ; -Date of event [e.g. 'DATE   :  04-06-2000/15:01:22 - 04-06-2000/17:59:50']
la    = ''           ; -Energy bin labels
pa    = ''           ; -Pitch-Angle labels
tra   = [0d0,0d0]    ; => Unix time range of data
ymd   = ['','']      ; => Time range of data ['YYYY-MM-DD/HH:MM:SS.sss']
d1    = ''           ; => Start Date ['MM-DD-YYYY']
d2    = ''           ; => End Date ['MM-DD-YYYY']
t1    = ''           ; => Start Time ['HH:MM:SS']
t2    = ''           ; => End Time ['HH:MM:SS']
s1    = ''           ; => Start Time ['HHMMSS']
pas   = ''           ; => String array of PA values
llabs = ''           ; => Concatenated energy bin labels into one string
ppans = ''           ; => Concatenated PA labels into one string
N     = nd1          ; => # of time steps
M     = nd2          ; => # of energy bins
L     = nd3          ; => # of pitch-angles (PAs)
; => Define some prefixes for header file variables
dpref = 'DATE   :  '
npref = 'NAME   :  '
upref = 'UNITS  :  '
lpref = 'LABELS :  '
ppref = 'PANGS  :  '


tra = [MIN(mstr.X,/NAN),MAX(mstr.X,/NAN)]
ymd = time_string(tra,PREC=3)
d1  = STRMID(ymd[0],5,2)+'-'+STRMID(ymd[0],8,2)+'-'+STRMID(ymd[0],0,4)
d2  = STRMID(ymd[1],5,2)+'-'+STRMID(ymd[1],8,2)+'-'+STRMID(ymd[1],0,4)
t1  = STRMID(ymd[0],11,8)
t2  = STRMID(ymd[1],11,8)
s1  = STRMID(t1,0,2)+STRMID(t1,3,2)+STRMID(t1,6,2)
s2  = STRMID(t2,0,2)+STRMID(t2,3,2)+STRMID(t2,6,2)

pas = TOTAL(mstr.V2,1,/NAN)/ TOTAL(FINITE(mstr.V2),1,/NAN)
pas = STRTRIM(STRING(FORMAT='(f12.2)',pas),2)+'!Uo!N'

FOR i=0L, M - 1L DO llabs = llabs+' '+mylabs[i]
FOR i=0L, L - 1L DO ppans = ppans+' '+pas[i]

nm  = npref+strns.LC
un  = upref+gunits+punits
da  = dpref+d1+'/'+t1+' - '+d2+'/'+t2
la  = lpref+llabs
pa  = ppref+ppans
;-----------------------------------------------------------------------------------------
; => Define output file name and print data to file
;-----------------------------------------------------------------------------------------
mdir     = ''   ; => Base directory for file path
outfile  = ''   ; => File name plus file path
myformat = ''   ; => Read/Write format structure for ASCII file

mdir     = FILE_EXPAND_PATH('')
outfile  = mdir+'/'+name+'_spec_'+d1+'-'+s1+'_'+d2+'-'+s2+'_'+gunits+'.txt'
myformat = '(d25.10,'+STRTRIM(m,2)+'e24.12,'+STRTRIM(m,2)+'f12.2)'
;;++++++++++++++++++++++++++++++++++++++++++++
p_messg  = 'Printing ASCII file:  '+outfile
MESSAGE,p_messg,/INFORMATIONAL,/CONTINUE   
;;++++++++++++++++++++++++++++++++++++++++++++
; => Open file
OPENW,gunit,outfile,/GET_LUN
  ; => Print Header
  PRINTF,gunit,nm
  PRINTF,gunit,un
  PRINTF,gunit,da
  PRINTF,gunit,la
  PRINTF,gunit,pa
  PRINTF,gunit,'FORMAT :  '+myformat
  PRINTF,gunit,''
  ; => Print Data to file
  FOR j=0L, N - 1L DO BEGIN
    FOR k=0L, L - 1L DO BEGIN
      PRINTF,gunit,mstr.X[j],mstr.Y[j,*,k],mstr.V1[j,*],FORMAT=myformat
    ENDFOR
  ENDFOR
; => Close/Finalize file writing process
FREE_LUN,gunit

;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;*****************************************************************************************
RETURN
END
