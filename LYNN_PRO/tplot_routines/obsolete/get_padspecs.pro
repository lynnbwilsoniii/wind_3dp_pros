;+
;*****************************************************************************************
;
;  FUNCTION :   get_padspecs.pro
;  PURPOSE  :   Creates a particle spectra "TPLOT" variable by summing 3DP data over 
;                 selected angle bins.  The output is a structure which has the format:
;
;               {YTITLE:[string],X:[times(n)],Y:[data(n,m,l)],V1:[energy(n,m)],
;                V2:[pangls(n,l)],'YLOG':1,'PANEL_SIZE':2.0}
;               WHERE:  n = # of 3D data structures
;                       m = # of energy bins in each 3D data structure
;                       l = # of pitch-angles chosen by the keyword NUM_PA
;
;  CALLED BY: 
;               calc_padspecs.pro
;               write_padspec_ascii.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;               gettime.pro
;               interp.pro
;               minmax.pro
;               get_3dp_structs.pro
;               pesa_high_str_fill.pro
;               add_magf2.pro
;               dat_3dp_energy_bins.pro
;               sst_foil_bad_bins.pro
;               data_cut.pro
;               convert_vframe.pro
;               str_element.pro
;               conv_units.pro
;               pad.pro
;               store_data.pro
;
;  REQUIRES:  
;               "LOAD_3DP_DATA" must be called first to load up WIND data.
;
;  INPUT:
;               DATA_STR  :  [string] Specify the type of structure you wish to 
;                               get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:
;               get_padspecs,name,BSOURCE='wi_B3(GSE)',NUM_PA=mynpa,vsource=vsw,$
;                            UNITS=gunits,TRANGE=trange,DAT_ARR=dat_arr,        $
;                            G_MAGF=g_magf,STORE_RE=store_re
;
;  KEYWORDS:  
;               BINS      :  -Keyword telling which data bins to sum over
;               GAP_TIME  :  -Time gap big enough to signify a data gap (def 200)
;               NO_DATA   :  -Returns 1 if no_data else returns 0
;               UNITS     :  -Convert to these units if included
;               NAME      :  -New name of the Data Quantity
;               BKG       :  -A 3d data structure containing the background counts.
;               MISSING   :  -Value for bad data.
;               BSOURCE   :  -String associated with TPLOT variable for magnetic field
;               VSOURCE   :  -String associated with TPLOT variable for solar wind
;                              velocity vector
;               ETHRESH   :  -A threshold for the energy bins to use
;               TRANGE    :  [Double] 2 element array specifying the range over 
;                              which to get data structures [Unix time]
;               NUM_PA    :  Number of pitch-angles to sum over 
;                              [Default = defined by instrument]
;               FLOOR     :  -Sets the minimum value of any data point to sqrt(bkg).
;               BKGBINS   :  -Array of energy which bins to sum over
;               ENBINS    :  -A 2-element array, single integer/long, or an array
;                              of values specifying which energy bins to use when
;                              creating the pitch-angle distributions (PADs)
;               STORE_RE  :  -If set, the function will return the data structure to
;                              the user, but will NOT store that data as a TPLOT
;                              variable.  Set as a named variable for returning data.
;               DAT_ARR   :  N-Element array of data structures from get_??.pro
;                              [?? = 'el','eh','elb',etc.]
;               G_MAGF    :  If set, tells program that the structures in DAT_ARR 
;                              already have the magnetic field added to them thus 
;                              preventing this program from calling add_magf2.pro 
;                              again.
;               NO_KILL   :  If set, get_padspecs.pro will NOT call the routine
;                              sst_foil_bad_bins.pro
;
;  CHANGED:   1)  Changed the functionality/robustness            [08/18/2008   v1.2.35]
;             2)  Altered manner in which pads are dealt with for 
;                   EESA High                                     [02/09/2009   v1.2.36]
;             3)  Updated man page                                [03/18/2009   v1.2.37]
;             4)  Added keyword:  DAT_ARR                         [04/24/2009   v1.3.0]
;             5)  Rewrote most of program                         [04/24/2009   v2.0.0]
;             6)  Changed my_pesa_high_str_fill.pro calling sequence
;                                                                 [04/26/2009   v2.0.1]
;             7)  Added keyword:  G_MAGF                          [04/26/2009   v2.0.2]
;             8)  Fixed syntax error                              [04/30/2009   v2.0.3]
;             9)  Fixed syntax error                              [06/01/2009   v2.0.4]
;            10)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and my_str_names.pro to dat_3dp_str_names.pro
;                                                                 [08/05/2009   v2.1.0]
;            11)  Changed program my_pad_dist.pro to pad.pro
;                   and renamed from get_padspec_5.pro            [08/10/2009   v2.2.0]
;            12)  Changed program my_3dp_str_call_2.pro to get_3dp_structs.pro
;                                                                 [08/12/2009   v2.3.0]
;            13)  Updated 'man' page                              [10/05/2008   v2.3.1]
;            14)  Changed program my_pesa_high_str_fill.pro to pesa_high_str_fill.pro
;                   and added program:  sst_foil_bad_bins.pro     [02/13/2010   v2.4.0]
;            15)  Added keyword:  NO_KILL                         [02/25/2010   v2.5.0]
;            16)  Added some error handling to deal with BINS keyword
;                                                                 [11/23/2010   v2.5.1]
;            17)  Fixed typo in previous addition                 [11/29/2010   v2.5.2]
;
;   ADAPTED FROM: get_padspec.pro    BY: Davin Larson
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/29/2010   v2.5.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO get_padspecs,data_str,     $
        BINS     = bins,       $
        GAP_TIME = gap_time,   $
        NO_DATA  = no_data,    $
        UNITS    = units,      $
        NAME     = name,       $
        BKG      = bkg,        $
        MISSING  = missing,    $
        BSOURCE  = bsource,    $
        VSOURCE  = vsource,    $
        ETHRESH  = ethresh,    $
        TRANGE   = trange,     $
        NUM_PA   = num_pa,     $
        FLOOR    = floor,      $
        BKGBINS  = bkgbins,    $
        ENBINS   = enbins,     $
        STORE_RE = store_re,   $
        DAT_ARR  = dat_arr,    $
        G_MAGF   = g_magf,     $
        NO_KILL  = no_kill
;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Create Dummy Structure and variables
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN
mynpa  = 0L                     ; # of angle bins to sum over for different spec plots
pname  = ''                     ; -E.G. 'EL'
funits = '(# cm!U-2!Ns!U-1!Nsr!U-1!NeV!U-1!N)'  ; => Units of # Flux
name   = STRLOWCASE(data_str)
dum_v1 = REPLICATE(f,100,15)    ; => {i.e. [100 time steps,15 Energies] }
dum_v2 = REPLICATE(f,100,16)    ; => {i.e. [100 time steps,16 Pitch-Angles] }
dum_x  = REPLICATE(d,100)       ; => Dummy time variable
dum_y  = REPLICATE(f,100,15,16) ; => {i.e. [100 time steps,15 Energies,16 Pitch-Angles]}
dum_l  = REPLICATE('',15)       ; => Dummy data labels
dum_t  = ['YTITLE','X','Y','V1','V2','YLOG','LABELS','PANEL_SIZE']
dummy  = CREATE_STRUCT(dum_t,name,dum_x,dum_y,dum_v1,dum_v2,0,dum_l,2.0)
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
; -Make sure data_str is in the correct format
;-----------------------------------------------------------------------------------------
strns    = dat_3dp_str_names(name)
data_str = strns.SN
routine  = 'get_'+data_str
;-----------------------------------------------------------------------------------------
; -get an example data structure 
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(dat_arr) THEN BEGIN  ; -> Need to get data structures
  dat     = CALL_FUNCTION(routine, t, INDEX=0)
  yname   = data_str+'_pads'
  nenergy = dat.NENERGY
  times   = CALL_FUNCTION(routine,/TIMES)
  ndt     = N_ELEMENTS(times)
  istart  = 0
ENDIF ELSE BEGIN                        ; -> Data structures given on input
  ndt     = N_ELEMENTS(dat_arr)
  times   = dat_arr.TIME
  istart  = 0
  nenergy = dat_arr.NENERGY
ENDELSE
yname   = data_str+'_pads'
;-----------------------------------------------------------------------------------------
; -Determine time range, indices, and then call all 3D data structures within 
;   defined time range or index range
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(trange) THEN BEGIN
  ; -get range of index values for calling the get_??.pro routines
  irange = FIX(interp(FINDGEN(ndt),times,gettime(trange)))
  PRINT,irange
  irange = (irange < (ndt-1)) > 0
  irange = minmax(irange)
  istart = irange[0]
  times  = times[istart:irange[1]]
  PRINT,'Index range: ',irange
  ndt    = N_ELEMENTS(times)
ENDIF

IF NOT KEYWORD_SET(dat_arr) THEN BEGIN  ; -> Need to get data structures
  mystr    = get_3dp_structs(data_str,TRANGE=trange)
  mytim    = mystr.TIMES
  myn_tags = N_TAGS(mystr)
ENDIF ELSE BEGIN                        ; -> Data structures given on input
  s_dat  = SIZE(dat_arr,/TYPE) EQ 8
  IF (s_dat) THEN BEGIN
    dat      = dat_arr
    mytim    = [[dat.TIME],[dat.END_TIME]]
    myn_tags = 0
  ENDIF ELSE BEGIN                      ; -> Bad input, try calling structures
    MESSAGE,'Improper Input [dat_arr]:  Must be a data structure!',/INFORMATION,/CONTINUE
    mystr    = get_3dp_structs(data_str,TRANGE=trange)
    mytim    = mystr.TIMES
    myn_tags = N_TAGS(mystr)
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; -Define parameters
;-----------------------------------------------------------------------------------------
IF (myn_tags GT 2L) THEN BEGIN
  ;---------------------------------------------------------------------------------------
  ; -More than 1 mapcode (Pesa High) was found during time period of interest
  ;---------------------------------------------------------------------------------------
  CASE myn_tags OF
    3L : BEGIN
      dat1     = mystr.DATA1
      dat2     = mystr.DATA2
      dat3     = 0
      mydim1   = SIZE(dat1.DATA,/DIMENSIONS)
      mydim2   = SIZE(dat2.DATA,/DIMENSIONS)
      mydim3   = 0
      nde1     = mydim1[0]  ; -# of energy bins in each moment
      ndx1     = mydim1[1]  ; -# of data bins per energy bin
      nde2     = mydim2[0]  ; -# of energy bins in each moment
      ndx2     = mydim2[1]  ; -# of data bins per energy bin
      nde3     = 0
      ndx3     = 0
      ndt      = N_ELEMENTS(dat1) + N_ELEMENTS(dat2) ; -# of moments found
      abins    = MAX([ndx1,ndx2],/NAN)
    END
    4L : BEGIN
      dat1     = mystr.DATA1
      dat2     = mystr.DATA2
      dat3     = mystr.DATA3
      mydim1   = SIZE(dat1.DATA,/DIMENSIONS)
      mydim2   = SIZE(dat2.DATA,/DIMENSIONS)
      mydim3   = SIZE(dat3.DATA,/DIMENSIONS)
      nde1     = mydim1[0]  ; -# of energy bins in each moment
      ndx1     = mydim1[1]  ; -# of data bins per energy bin
      nde2     = mydim2[0]  ; -# of energy bins in each moment
      ndx2     = mydim2[1]  ; -# of data bins per energy bin
      nde3     = mydim3[0]  ; -# of energy bins in each moment
      ndx3     = mydim3[1]  ; -# of data bins per energy bin
      ndt      = N_ELEMENTS(dat1) + N_ELEMENTS(dat2) + N_ELEMENTS(dat3)
      abins    = MAX([ndx1,ndx2,ndx3],/NAN)
    END
    ELSE : BEGIN
      MESSAGE,'There are no '+data_str+' moments for those times!',/INFORMATION,/CONTINUE
      RETURN
    END
  ENDCASE
  CASE abins[0] OF   ; => Determine mapcode of largest nbin-structure
    121  :  BEGIN
      mapcode = 54436L
    END
    97   :  BEGIN
      mapcode = 54526L
    END
    56   :  BEGIN
      mapcode = 54764L
    END
    65   :  BEGIN
      mapcode = 54971L
    END
    88   :  BEGIN
      mapcode = 54877L
    END
  ENDCASE
  pesa_high_str_fill,dat,NAME=data_str,DUM1=dat1,DUM2=dat2,DUM3=dat3
  dat0  = dat[0]
  nde   = nde1        ; -# of energy bins in each moment
ENDIF ELSE BEGIN      ; => Only one structure format
;  gtags    = TAG_NAMES(mystr)
;  dat      = mystr.DATA
  IF NOT KEYWORD_SET(dat_arr) THEN dat = mystr.DATA
  mydims   = SIZE(dat.DATA,/DIMENSIONS)
  ndt      = mydims[2]  ; -# of moments found
  nde      = mydims[0]  ; -# of energy bins in each moment
  ndx      = mydims[1]  ; -# of data bins per energy bin
  dat0     = dat[0]
ENDELSE
IF (ndt EQ 0L) THEN BEGIN
  MESSAGE,'There are no '+data_str+' moments for those times!',/INFORMATION,/CONTINUE
  RETURN
ENDIF ELSE BEGIN
  count = ndt
ENDELSE
;-----------------------------------------------------------------------------------------
; -get B-field data
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(bsource) THEN bsource = 'wi_B3(GSE)'
IF NOT KEYWORD_SET(g_magf) THEN add_magf2,dat,bsource

IF KEYWORD_SET(num_pa) EQ 0 THEN num_pa = 8
;-----------------------------------------------------------------------------------------
; -Find energies and energy bins
;-----------------------------------------------------------------------------------------
my_eners = dat_3dp_energy_bins(dat0,EBINS=enbins)
mener    = dat0.nenergy - 1L
estart   = my_eners.E_BINS[0]
eend     = my_eners.E_BINS[1]
myen     = my_eners.ALL_ENERGIES
newbins  = [estart,eend]
diffen   = eend-estart+1
mebins   = INTARR(diffen)
FOR i = 0, diffen-1L DO BEGIN
  j = i + estart
  mebins[i] = j
ENDFOR
;-----------------------------------------------------------------------------------------
; - Create labels and send data structure to TPLOT
;-----------------------------------------------------------------------------------------
tn1   = STRUPCASE(STRMID(data_str,0,1)) ; -1st letter of structure name
CASE tn1 OF
  'E' : BEGIN
    labels  = STRMID(STRTRIM(STRING(FORMAT='(f12.1)',myen),2),0,6)+' eV'
  END
  'P' :  BEGIN
    labels  = STRMID(STRTRIM(STRING(FORMAT='(f12.1)',myen),2),0,6)+' eV'
  END
  'S' :  BEGIN
    kens = WHERE(myen/1e6 GT 1.0,kns) 
    IF (kns GT 0) THEN myen2 = myen/1000. ELSE myen2 = myen
    labels  = STRMID(STRTRIM(STRING(FORMAT='(f12.1)',myen2),2),0,6)+' keV'
    ; => Remove "noisy/bad" and small geometry factor bins for SST Foil str.
    IF (STRUPCASE(STRMID(data_str,0L,2L)) EQ 'SF') THEN BEGIN
      IF NOT KEYWORD_SET(no_kill) THEN sst_foil_bad_bins,dat
    ENDIF
  END
  ELSE : BEGIN
    MESSAGE,'Improper Data Structure Name!',/INFORMATION,/CONTINUE
    MESSAGE,"Examples: 'el', 'eh', 'pl', 'ph', 'elb', 'ehb', 'sf', etc.",$
            /INFORMATION,/CONTINUE
    RETURN
  END
ENDCASE

newbins2 = newbins
IF (nde NE diffen) THEN BEGIN
  nenergy = diffen    ; -# of energy bins specified in calling of program
ENDIF ELSE BEGIN
  nenergy = nde
ENDELSE
data     = REPLICATE(f,ndt,nenergy,num_pa) ; -data array [# of time samples, energies, angles]
energy   = REPLICATE(f,ndt,nenergy)
pang     = REPLICATE(f,ndt,num_pa)
;-----------------------------------------------------------------------------------------
; => Determine data bins to sum over
;-----------------------------------------------------------------------------------------
mydims = SIZE(dat0[0].DATA,/DIMENSIONS)
ndx    = mydims[1]  ; -# of data bins per energy bin
IF NOT KEYWORD_SET(bins)  THEN BEGIN
  ind    = INDGEN(ndx,nenergy)
  gbins  = BINDGEN(ndx)
ENDIF ELSE BEGIN
  sbin  = SIZE(bins,/DIMENSIONS)
  snbin = N_ELEMENTS(sbin)
  IF (snbin GT 1) THEN BEGIN
    test = [N_ELEMENTS(bins[0,*]),N_ELEMENTS(bins[*,0])] EQ ndt
    good = WHERE(test,gd)
    IF (gd GT 0) THEN BEGIN
      CASE good[0] OF
        0L : BEGIN
          ind = WHERE(REFORM(bins[0,*]),count,COMPLEMENT=bind)
        END
        1L : BEGIN
          ind = WHERE(REFORM(bins[*,0]),count,COMPLEMENT=bind)
        END
      ENDCASE
      gbins = BINDGEN(ndx)
      IF (N_ELEMENTS(bind) GT 0) THEN gbins[bind] = 0B
    ENDIF ELSE BEGIN
      gbins = BINDGEN(ndx)
    ENDELSE
  ENDIF ELSE BEGIN
    ind         = WHERE(bins,count,COMPLEMENT=bind)
    gbins       = BINDGEN(ndx)
    IF (N_ELEMENTS(bind) GT 0) THEN gbins[bind] = 0B
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; -define units
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(units) THEN units = 'flux'
IF KEYWORD_SET(name) EQ 0 THEN name = yname ELSE yname = name
yname = yname+' ('+units+')'
;-----------------------------------------------------------------------------------------
; -If specified, get solar wind velocities
;-----------------------------------------------------------------------------------------
TRUE = 1
FALSE = 0
searching = TRUE
WHILE(searching) DO BEGIN
  IF KEYWORD_SET(vsource) THEN BEGIN
    vsw = data_cut(vsource,mytim,COUNT=count)
    IF (count NE ndt)  THEN $
      MESSAGE,'No finite data for '+vsource+' =>does not work!',/INFORMATION,/CONTINUE
    searching = FALSE
  ENDIF
  searching = FALSE
ENDWHILE
IF NOT KEYWORD_SET(missing) THEN missing = !VALUES.F_NAN
;-----------------------------------------------------------------------------------------
; -
;-----------------------------------------------------------------------------------------
FOR i=0L, ndt - 1L DO BEGIN
   tdat    = dat[i]
   newbins = newbins2  ; -make sure pad.pro doesn't affect newbins in each cycle
   IF KEYWORD_SET(bkgbins) THEN BEGIN
     ener0 = bkgbins[0]
     ener1 = bkgbins[1]
   ENDIF ELSE BEGIN
     ener0 = 0L
     ener1 = N_ELEMENTS(tdat.energy[*,0]) - 1L
   ENDELSE
   IF (tdat.VALID NE 0) THEN BEGIN
     ;------------------------------------------------------------------------------------
     ;str_element,tdat,'magf',REFORM(magf[i,*]),/ADD_REPLACE
     ;------------------------------------------------------------------------------------
     IF KEYWORD_SET(vsource) THEN BEGIN
       svsw = SIZE(vsource,/TYPE,/L64)
       CASE svsw OF
         4 : BEGIN
           nndims = SIZE(vsource,/N_DIMENSIONS,/L64)
           mmdims = SIZE(vsource,/DIMENSIONS,/L64)
           gdims  = WHERE(mmdims EQ 3L, gdi)
           IF (gdi GT 0) THEN BEGIN
             CASE gdims[0] OF
               0 : BEGIN
                 str_element,tdat,'VSW',vsource[*,i],/ADD_REPLACE
                 tdat = convert_vframe(tdat,/INTERP,ETHRESH=ethresh)
               END
               1 : BEGIN
                 str_element,tdat,'VSW',TRANSPOSE(vsource[i,*]),/ADD_REPLACE
                 tdat = convert_vframe(tdat,/INTERP,ETHRESH=ethresh)
               END
               ELSE : BEGIN
                 MESSAGE,'Incorrect array format!',/INFORMATION,/CONTINUE
                 GOTO,JUMP_CONV
               END
             ENDCASE               
           ENDIF ELSE BEGIN
             MESSAGE,'Incorrect array format!',/INFORMATION,/CONTINUE
             GOTO,JUMP_CONV
           ENDELSE
         END
         8 : BEGIN
           add_vsw2,tdat,vsource
           tdat = convert_vframe(tdat,/INTERP,ETHRESH=ethresh)
         END
         7 : BEGIN
           add_vsw2,tdat,vsource
           tdat = convert_vframe(tdat,/INTERP,ETHRESH=ethresh)
         END
         ELSE : BEGIN
           MESSAGE,'Incorrect array format!',/INFORMATION,/CONTINUE
           GOTO,JUMP_CONV
         END
       ENDCASE
     ENDIF
     ;------------------------------------------------------------------------------------
      JUMP_CONV:
     ;------------------------------------------------------------------------------------
     tdat = conv_units(tdat,units)
     ;------------------------------------------------------------------------------------
     ; -Get pitch-angle distributions
     ;------------------------------------------------------------------------------------
     IF (STRMID(STRLOWCASE(data_str),0L,2L) EQ 'eh') THEN spikes = 1 ELSE spikes = 0
     pad = pad(tdat,NUM_PA=num_pa,BINS=gbins,SPIKES=spikes)
     IF (pad.VALID EQ 1) THEN BEGIN
       data[i,*,*] = pad.DATA[newbins2[0]:newbins2[1],*]
     ENDIF
     ;------------------------------------------------------------------------------------
     ; -Adjust the energy and pitch-angle approx by new # of energy bins
     ;------------------------------------------------------------------------------------
     JUMP_ENERGY:
     ;------------------------------------------------------------------------------------
     tempbins    = TOTAL(FINITE(pad.ANGLES[newbins2[0]:newbins2[1],*]),2,/NAN)
     tempener    = TOTAL(FINITE(pad.ENERGY[newbins2[0]:newbins2[1],*]),1,/NAN)
     energy[i,*] = TOTAL(pad.ENERGY[newbins2[0]:newbins2[1],*],2,/NAN)/tempbins
     pang[i,*]   = TOTAL(pad.ANGLES[newbins2[0]:newbins2[1],*],1,/NAN)/tempener     
   ENDIF
   ;--------------------------------------------------------------------------------------
   JUMP_SKIP:
   ;--------------------------------------------------------------------------------------
ENDFOR
;-----------------------------------------------------------------------------------------
; -Get rid of non-finite pitch-angles
;-----------------------------------------------------------------------------------------
gang = WHERE(FINITE(pang) EQ 0,gan)
IF (gan GT 0) THEN BEGIN
  gind    = ARRAY_INDICES(pang,gang)
  temp_an = TOTAL(pang,1,/NAN)/ TOTAL(FINITE(pang),1,/NAN)
  new_ang = REPLICATE(1.0,ndt) # temp_an
  pang[gind[0,*],gind[1,*]] = new_ang[gind[0,*],gind[1,*]]
ENDIF

bener = WHERE(energy EQ 0.0 OR FINITE(energy) EQ 0,bne)
IF (bne GT 0) THEN BEGIN
  eind   = ARRAY_INDICES(energy,bener)
  new_en = TOTAL(energy,1,/NAN)/ TOTAL(FINITE(energy),1,/NAN)
  delta = energy - SHIFT(energy,1,0)
  w = WHERE(delta,c)
  IF (c EQ 0) THEN energy = new_en
ENDIF ELSE BEGIN
  energy2 = energy
  nrgs    = REFORM(energy2[0,*])
ENDELSE
;-----------------------------------------------------------------------------------------
; -Get rid of zero or non-finite data
;-----------------------------------------------------------------------------------------
badd = WHERE(data LE 0.0 OR FINITE(data) EQ 0,bdd,COMPLEMENT=gadd)
IF (bdd GT 0) THEN BEGIN
  bind = ARRAY_INDICES(data,badd)
  data[bind[0,*],bind[1,*]] = !VALUES.F_NAN
ENDIF
;-----------------------------------------------------------------------------------------
; -IF c eq 0 THEN energy = nrgs
;-----------------------------------------------------------------------------------------
dum_t    = ['YTITLE','X','Y','V1','V2','YLOG','LABELS','PANEL_SIZE']
datastr  = CREATE_STRUCT(dum_t,yname,mytim[*,0],data,energy,pang,1,labels,2.0)

IF KEYWORD_SET(store_re) THEN BEGIN
  store_re = datastr
ENDIF ELSE BEGIN
  store_data,name+'_pads',DATA=datastr
ENDELSE
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/cont,/info
;*****************************************************************************************
RETURN
END
