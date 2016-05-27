;+
;*****************************************************************************************
;
;  FUNCTION :   spec_2dim_shift.pro
;  PURPOSE  :   Shifts stacked spectra plots and normalizes data (if desired)
;                 {for spec structures w/ pitch-angle data separated already}
;
;  CALLED BY: 
;               spec_vec_data_shift.pro
;
;  CALLS:
;               get_data.pro
;               dat_3dp_energy_bins.pro
;               ytitle_tplot.pro
;               ylim.pro
;               options.pro
;               store_data.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT        :  3D data structure of the form =>
;                               {YTITLE:[string],X:[times(N)],Y:[data(N,M)],$
;                                     V:[energy(N,M)]}
;                               where:  N = # of time steps
;                                       M = # of energy bins
;               NAME       :  Scalar string for corresponding TPLOT variable name with
;                               associated spectra (or vector) data separated by 
;                               pitch-angle or component as TPLOT variables 
;                               [e.g. 'nsf_pads-2-0:1_N']
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               NEW_NAME   :  New string name for returned TPLOT variable
;               DATN       :  If set, data is returned normalized by 
;                               the AVG. for each energy bin
;                               [i.e. still a stacked spectra plot but normalized]
;               DATS       :  If set, data is shifted to avoid overlaps
;               WSHIFT     :  Performs a weighted shift of only the specified 
;                               energy bins {e.g. 1st 3 -> lowest energies [0,2]}
;               RANGE_AVG  :  Two element double array specifying the time range
;                               (Unix time) to use for constructing an average to
;                               normalize the data by when using the keyword DATN
;
;   CHANGED:  1)  NA                                         [07/10/2008   v1.0.1]
;             2)  Updated man page                           [03/19/2009   v1.0.2]
;             3)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                   and renamed from my_2dim_spec_shift.pro  [08/10/2009   v2.0.0]
;             4)  Added keyword:  RANGE_AVG                  [09/19/2009   v2.1.0]
;             5)  Changed program my_ytitle_tplot.pro to ytitle_tplot.pro
;                   and now calls get_data.pro
;                                                            [10/07/2008   v2.2.0]
;
;   CREATED:  06/13/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/07/2008   v2.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO spec_2dim_shift,dat,name,WSHIFT=wshift,DATN=datn,DATS=datns,NEW_NAME=new_name,$
                             RANGE_AVG=range_avg

;-----------------------------------------------------------------------------------------
; => Make sure dat is a structure
;-----------------------------------------------------------------------------------------
d     = dat
IF (SIZE(d,/TYPE) NE 8) THEN BEGIN
  messg = 'Incorrect input format:  '+name+' (MUST be a TPLOT structure)'
  MESSAGE,messg,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Check input format
;-----------------------------------------------------------------------------------------
mytags  = TAG_NAMES(d)
ntags   = N_TAGS(d)
gtplotv = WHERE(STRLOWCASE(mytags) EQ 'v',gtpv)
IF (gtpv EQ 0) THEN BEGIN
  MESSAGE,'Incorrect TPLOT structure format:  '+name,/INFORMATIONAL,/CONTINUE
  PRINT,'No shifting or normalization will be done...'
  RETURN
ENDIF
; => Get Plot Limits structures
get_data,name,DATA=d,DLIM=dlim,LIM=lim
;-----------------------------------------------------------------------------------------
; => Define default energy bin values
;-----------------------------------------------------------------------------------------
my_ena   = dat_3dp_energy_bins(d)
nener    = N_ELEMENTS(my_ena.ALL_ENERGIES)      ; => Total number of energies available
allen    = my_ena.ALL_ENERGIES                  ; => An array of all the energy values
allel    = LINDGEN(nener)                       ; => An array for all the energy bin elements
sname    = STRMID(name,0,3)
CASE STRMID(sname,1,1) OF
  'e'  : mylb = STRTRIM(STRING(FORMAT='(f12.1)',allen),2)+' eV'
  'p'  : mylb = STRTRIM(STRING(FORMAT='(f12.1)',allen),2)+' eV'
  's'  : mylb = STRTRIM(STRING(FORMAT='(f12.1)',allen*1e-3),2)+' keV'
  ELSE : mylb = STRTRIM(STRING(FORMAT='(f12.1)',allen),2)+' eV'
ENDCASE
newlabs = mylb
;-----------------------------------------------------------------------------------------
; => Define dimensions
;-----------------------------------------------------------------------------------------
ndims = SIZE(REFORM(d.Y),/DIMENSIONS)  ; => # of elements/dimension
mdims = N_ELEMENTS(ndims)              ; => # of dimensions of data in D-structure
nd1   = ndims[0]                       ; => Typically for spec data = # of time steps
nd2   = ndims[1]                       ; => Typically for spec data = # of energy bins
;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
newy = FLTARR(nd1,nd2)                 ; => New data array
;-----------------------------------------------------------------------------------------
; => Determine order of energy bins (SST data reverses order from electrostatic detectors)
;-----------------------------------------------------------------------------------------
mxen = MAX(d.V,/NAN,lxd1)              ; => Max energy which in structure
mnen = MIN(d.V,/NAN,lnd1)              ; => Min " "
myne = (ARRAY_INDICES(d.V,lnd1))[1]    ; => Element corresponding to mnen
myxe = (ARRAY_INDICES(d.V,lxd1))[1]
IF (myxe LT myne) THEN BEGIN           ; => energies indexed from high to low (Eesa/Pesa)
  low1 = 0
ENDIF ELSE BEGIN                       ; => energies indexed from low to high (SST, typically)
  low1 = 1
ENDELSE
;-----------------------------------------------------------------------------------------
; => If RANGE_AVG is set, normalize the data by the average for this time range
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(range_avg) THEN BEGIN
  avg_inds = LINDGEN(nd1)
ENDIF ELSE BEGIN
  nra = N_ELEMENTS(range_avg)
  IF (nra EQ 2) THEN BEGIN
    gnra = WHERE(d.X LE range_avg[1] AND d.X GE range_avg[0],gn)
    IF (gn GT 1L) THEN avg_inds = gnra ELSE avg_inds = LINDGEN(nd1)
  ENDIF ELSE BEGIN
    MESSAGE,'Incorrect keyword format:  RANGE_AVG MUST be a 2-Element Array!',/INFORMATIONAL,/CONTINUE
    PRINT,'Using default setting...'
    avg_inds = LINDGEN(nd1)
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Determine energy-bin averages
;-----------------------------------------------------------------------------------------
flav = FLTARR(nd2)                     ; => Average for specified energy bin and time range
sig1 = FLTARR(nd2)                     ; => Array of standard deviations of flav
FOR j=0L, nd2 - 1L DO BEGIN
  flav[j] = MEAN(d.Y[avg_inds,j],/NAN)
  sig1[j] = STDDEV(d.Y[avg_inds,j],/NAN)
ENDFOR
;-----------------------------------------------------------------------------------------
; => If wshift is set, perform a energy-weighted data shift
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(wshift) THEN BEGIN
  wener   = dat_3dp_energy_bins(d,EBINS=wshift)
  nd4     = wener.E_BINS[1] - wener.E_BINS[0] + 1L
  tenv    = FLTARR(nd2)   ; => energy estimates eliminating NaNs (hopefully)
  tenv    = TOTAL(d.V,1,/NAN)/TOTAL(FINITE(d.V),1,/NAN)
  tener   = STRTRIM(STRING(FORMAT='(f12.2)',tenv),2)
;  newlabs = tener+' eV'
  CASE low1 OF
    0 : BEGIN       ; => energies indexed from high to low (Eesa/Pesa)
      m_o = (nd2 - 1L)
      m_1 = 0L
      m_2 = m_o - nd4
    END
    1 : BEGIN       ; => energies indexed from low to high (SST, typically)
      m_o = 0L
      m_1 = nd4
      m_2 = nd2 - 1L
    END
  ENDCASE
  FOR k=0L, nd4 - 1L DO BEGIN
    m           = ABS(m_o - k)
    tfactor     = 1.2d0^(m + 1d0)/(k + 1d0)
    newy[*,m,*] = d.y[*,m]*tfactor
    newlabs[m]  = newlabs[m]+' x '+STRTRIM(STRING(FORMAT='(f12.2)',tfactor),2)
  ENDFOR
  ;---------------------------------------------------------------------------------------
  ; => Reset data that was NOT to be shifted
  ;---------------------------------------------------------------------------------------
  newy[*,m_1:m_2] = d.y[*,m_1:m_2]
  ylg   = 1  ; ylog = true
  yttl  = ytitle_tplot(name,EX_STR=[STRTRIM(nd3,2)+' shifted Energies'])
;  yttl  = my_ytitle_tplot(name,TAG1=' Flux !C',TAG2=STRTRIM(nd3,2),$
;                               TAG3=' shifted Energies')
  tname = '_wsh'
  myd   = CREATE_STRUCT('X',d.X,'Y',newy,'V',d.V)
  IF NOT KEYWORD_SET(new_name) THEN new_name = name+tname
  GOTO,JUMP_FIN
ENDIF
;-----------------------------------------------------------------------------------------
; => If datn is set, normalize the data by flav[i]
;-----------------------------------------------------------------------------------------
tempv   = TOTAL(FINITE(d.V),1,/NAN)  ; => Normalization factor for next line
tenv    = TOTAL(d.V,1,/NAN)/tempv    ; => Energy estimates eliminating NaNs (hopefully)
tener   = ''                         ; => String array of energy estimates
tener   = STRTRIM(STRING(FORMAT='(f12.2)',tenv),2)
;newlabs = tener+' eV'
IF NOT KEYWORD_SET(datn) THEN BEGIN
  ;---------------------------------------------------------------------------------------
  ; => No normalization, just shift each energy bin
  ;---------------------------------------------------------------------------------------
  CASE low1 OF
    0 : BEGIN
      m_o = nd2 - 1L
    END
    1 : BEGIN
      m_o = 0L
    END
  ENDCASE
  tname   = '_sh'
  shname  = '[Shifted]'
  FOR k=0L, nd2 - 1L DO BEGIN
    m = ABS(m_o - k)
    tfactor     = 1.2d0^(m + 1d0)/(k + 1d0)
    newy[*,m]   = d.y[*,m]*tfactor
    newlabs[m]  = newlabs[m]+' x '+STRTRIM(STRING(FORMAT='(e12.2)',tfactor),2)
  ENDFOR
  ylg  = 1  ; => ylog = true
  yttl = ytitle_tplot(name,EX_STR=shname,PRE_STR='SH-')
;  yttl = my_ytitle_tplot(name,TAG1=' !C'+shname,TAG2='SH-',LOCTAG=[1,2,0,3,4])
ENDIF ELSE BEGIN
  ;---------------------------------------------------------------------------------------
  ; => Normalization and possibly shift each energy bin
  ;---------------------------------------------------------------------------------------
  CASE low1 OF
    0 : BEGIN
      m_o = nd2 - 1L
    END
    1 : BEGIN
      m_o = 0L
    END
  ENDCASE
  FOR k=0L, nd2 - 1L DO BEGIN
    m = ABS(m_o - k)
    IF KEYWORD_SET(dats) THEN BEGIN
      tfactor = 1.2d0^(m + 1d0)/flav[m]/(k + 1d0)
      shname  = '[Shifted]'
      tname   = '_sh_n'
    ENDIF ELSE BEGIN
      tfactor = 1d0/flav[m]
      shname  = ''
      tname   = '_n'
    ENDELSE
    newy[*,m]   = d.Y[*,m]*tfactor
    newlabs[m]  = newlabs[m]+' x '+STRTRIM(STRING(FORMAT='(e12.2)',tfactor),2)
  ENDFOR
  ylg  = 1  ; ylog = true
  yttl = ytitle_tplot(name,EX_STR=shname,PRE_STR='N')
;  yttl = my_ytitle_tplot(name,TAG1=' !C'+shname,TAG2='N',LOCTAG=[1,2,0,3,4])
ENDELSE
; => Send normalized and/or shifted data back to TPLOT
myd = CREATE_STRUCT('X',d.X,'Y',newy,'V',d.V)
IF NOT KEYWORD_SET(new_name) then new_name = name+tname
;=========================================================================================
JUMP_FIN:
;=========================================================================================
str_element,lim,'YTITLE',yttl,/ADD_REPLACE
str_element,lim,'LABELS',newlabs,/ADD_REPLACE
store_data,new_name,DATA=myd,DLIM=dlim,LIM=lim
;options,new_name,'YTITLE',yttl
;options,new_name,'LABELS',newlabs
options,new_name,'MAX_VALUE',newmax
options,new_name,'PANEL_SIZE',2.0
options,new_name,'XMINOR',4    ; => set # of minor X-Tick marks to 4
options,new_name,'YMINOR',9    ; => set # of minor Y-Tick marks to 9
options,new_name,'COLORS',LINDGEN(nd2)*(250L - 30L)/(nd2 - 1L) + 30L
;-----------------------------------------------------------------------------------------
; => Make sure y-limits are not determined by "zeroed" data or NAN's
;-----------------------------------------------------------------------------------------
gylim = WHERE(newy NE 0.0 AND FINITE(newy),gyli)
IF (gyli GT 0) THEN BEGIN
  gyind1 = ARRAY_INDICES(newy,gylim)
  ymin1  = MIN(newy[gyind1[0,*],gyind1[1,*]],/NAN)/1.1
  ymax1  = MAX(newy[gyind1[0,*],gyind1[1,*]],/NAN)*1.1
  ylim,new_name,ymin1,ymax1,1
ENDIF

RETURN
END
