;+
;*****************************************************************************************
;
;  FUNCTION :   clean_spec_spikes.pro
;  PURPOSE  :   Removes data spikes and smooths out the result by smoothing and
;                 interpolating spectra data gaps.
;
;  CALLED BY:   NA
;
;  CALLS:
;               get_data.pro
;               ytitle_tplot.pro
;               store_data.pro
;               dat_3dp_energy_bins.pro
;               tnames.pro
;               ylim.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NAME      :  [String] A defined TPLOT variable name with associated spectra
;                              data separated by pitch-angle as TPLOT variables
;                              [e.g. 'nelb_pads']
;
;  EXAMPLES:
;            clean_spec_spikes,'nsf_pads',NSMOOTH=5,ESMOOTH=[0,2,12],NEW_NAME='nsf_test'
;               => results are smoothed over 5 data points for every energy except
;                  3 highest energies are smoothed over 12 points
;
;  KEYWORDS:  
;               NEW_NAME  :  New string name for returned TPLOT variable
;               NSMOOTH   :  # of data points to smooth over (default = 3)
;               THRESH    :  Old keyword from original version
;               ESMOOTH   :  Array for weighted smoothing (e.g. [0,2,10]) in the cases 
;                              where the higher energies have more fluctuations/noise
;                              due to the crude background approximations or 
;                              counting statistics
;                              [Example smooths 3 highest energies over 10 points]
;
;   CHANGED:  1)  NA                                         [07/10/2008   v1.2.21]
;             2)  Updated man page                           [03/19/2009   v1.2.22]
;             3)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                                                            [08/05/2009   v1.3.0]
;             4)  Renamed and cleaned up                     [08/10/2009   v2.0.0]
;             5)  Changed some minor syntax                  [09/21/2009   v2.0.1]
;             6)  Changed program my_ytitle_tplot.pro to ytitle_tplot.pro
;                                                            [10/07/2008   v2.1.0]
;             7)  Fixed order of energy bin labels for SST data 
;                                                            [10/08/2008   v2.1.1]
;
;   ADAPTED FROM: clean_spikes.pro    BY: Davin Larson
;   CREATED:  04/05/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/08/2008   v2.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO clean_spec_spikes,name,NEW_NAME=new_name,NSMOOTH=ns,THRESH=ft,ESMOOTH=es

;-----------------------------------------------------------------------------------------
; => Make sure name is either a tplot index or tplot string name
;-----------------------------------------------------------------------------------------
IF (SIZE(name,/TYPE) GT 1L AND SIZE(name,/TYPE) LT 8L) THEN BEGIN
  IF (SIZE(name,/TYPE) EQ 7L) THEN BEGIN
    name = name
  ENDIF ELSE BEGIN
    name = (tnames(ROUND(name)))[0]
  ENDELSE
  get_data,name,DATA=d,DLIM=dlim,LIM=lim
ENDIF ELSE BEGIN
  MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
  RETURN
ENDELSE
ds = d
sname = STRMID(name,0,3)
;-----------------------------------------------------------------------------------------
; => Make sure d is a structure
;-----------------------------------------------------------------------------------------
IF (SIZE(d,/TYPE) NE 8) THEN BEGIN
  MESSAGE,'Undefined input:  '+name,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF

IF NOT KEYWORD_SET(ns) THEN  ns = 3
ns = (LONG(ns)/2L)*2L + 1L

IF NOT KEYWORD_SET(ft) THEN  ft = 10.
ft = FLOAT(ft)
;-----------------------------------------------------------------------------------------
; => Determine new Y-title
;
; => get an array(scalar) of the # of elements in each dimension
;-----------------------------------------------------------------------------------------
ndims = SIZE(d.Y,/DIMENSIONS) 
mdims = N_ELEMENTS(ndims)     ; # of dimensions
nytt1   = ','+STRTRIM(ns,2)
IF NOT KEYWORD_SET(es) THEN BEGIN
  ns1   = REPLICATE(ns,ndims[1])
  nytt2 = ']'
  yttle = ytitle_tplot(name,EX_STR=['[Smoothed'+nytt1+nytt2])
ENDIF ELSE BEGIN
  ensm       = dat_3dp_energy_bins(d,EBINS=[es[0],es[1]])
  e1         = ensm.E_BINS[0]
  e2         = ensm.E_BINS[1]
  e3         = ABS(e2-e1)
  ns1        = REPLICATE(ns,ndims[1])
  ns1[e1:e2] = es[2]
  nytt2      = ',E'+STRTRIM(es[0],2)+':'+STRTRIM(es[1],2)+'-'+STRTRIM(es[2],2)+']'
  yttle      = ytitle_tplot(name,EX_STR=['[Smoothed'+nytt1+nytt2])
ENDELSE
;-----------------------------------------------------------------------------------------
; => Determine the type of spectra structure
;-----------------------------------------------------------------------------------------
IF (mdims LT 2L) THEN BEGIN
  MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine energy bin values
;-----------------------------------------------------------------------------------------
my_ena   = dat_3dp_energy_bins(d)
nener    = N_ELEMENTS(my_ena.ALL_ENERGIES)      ; => Total number of energies available
allen    = my_ena.ALL_ENERGIES                  ; => An array of all the energy values
allel    = LINDGEN(nener)                       ; => An array for all the energy bin elements
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
;-----------------------------------------------------------------------------------------
; =>  Make sure TPLOT variable exists and can be used
;-----------------------------------------------------------------------------------------
CASE mdims OF
  3 : BEGIN
    nd1 = ndims[0]  ; typically for spec data => # of samples
    nd2 = ndims[1]  ; " " => # of energy bins
    nd3 = ndims[2]  ; " " => # of pitch-angles which have been summed over
    mener = nd2 - 1L
    GOTO,JUMP_3D
  END
  2 : BEGIN
    nd1 = ndims[0]
    nd2 = ndims[1]
    nd3 = 0L
    mener = nd2 - 1L
    GOTO,JUMP_2D
  END
  ELSE : BEGIN
    MESSAGE,'No changes were made to data!',/INFORMATIONAL,/CONTINUE
    RETURN
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; =>  3D input array
;-----------------------------------------------------------------------------------------
;=========================================================================================
JUMP_3D:
;=========================================================================================
;-----------------------------------------------------------------------------------------
; => use weighted smoothing for large background fluctuations in high E bins
;-----------------------------------------------------------------------------------------
tdy   = FLTARR(nd1,nd2,nd3)
FOR j = 0L,nd2 - 1L DO BEGIN
  FOR k = 0L,nd3 - 1L DO BEGIN
    tdaty = d.Y[*,j,k]
    ns1y  = ns1[j]
    tempy = SMOOTH(tdaty,ns1y,/EDGE_TRUNCATE,/NAN)
    tdy[*,j,k] = tempy
  ENDFOR
ENDFOR
;-----------------------------------------------------------------------------------------
; => find bad data points
;-----------------------------------------------------------------------------------------
bad = d.Y GT ((ft*ns*tdy)/(ns - 1 + ft))  ; => results in bad=TRUE when smoothing is bad
wbad = WHERE(bad GT .5,wb)
IF (wb GT 0) THEN BEGIN
  wbind = ARRAY_INDICES(d.Y,wbad)
  d.Y[wbind[0,*],wbind[1,*],wbind[2,*]] = !VALUES.F_NAN
ENDIF
;-----------------------------------------------------------------------------------------
; => Eliminate data that is negative {spectral fluxes are magnitudes, NOT vectors}
;   let the "direction" part come from pitch-angles etc.
;-----------------------------------------------------------------------------------------
wlow = WHERE(d.Y LT 0d0,wl)
IF (wl GT 0) THEN BEGIN
  wlind = ARRAY_INDICES(d.Y,wlow)
  d.Y[wlind[0,*],wlind[1,*],wlind[2,*]] = !VALUES.F_NAN
ENDIF

gooddat = WHERE(FINITE(d.Y) AND d.Y GT 0d0,gdd,COMPLEMENT=baddat)
IF (gdd GT 0) THEN BEGIN
  IF (gdd LT SIZE(d.Y,/N_ELEMENTS)) THEN BEGIN
    gind   = ARRAY_INDICES(d.Y,gooddat)
    bind   = ARRAY_INDICES(d.Y,baddat)
    newy   = FLTARR(nd1,nd2,nd3)
    newd1  = FLTARR(nd1,nd2,nd3)
    newy[gind[0,*],gind[1,*],gind[2,*]] = d.Y[gind[0,*],gind[1,*],gind[2,*]]
    FOR j = 0L, nd2 - 1L DO BEGIN
      FOR k = 0L, nd3 - 1L DO BEGIN
        tdaty = newy[*,j,k]
        ns1y  = ns1[j]
        tempy = SMOOTH(tdaty,ns1y,/EDGE_TRUNCATE,/NAN)
        newd1[*,j,k] = tempy
      ENDFOR
    ENDFOR
  ENDIF ELSE BEGIN  ; => all data is good
    newy   = FLTARR(nd1,nd2,nd3)
    newd1  = FLTARR(nd1,nd2,nd3)
    newy   = d.Y
    FOR j = 0L, nd2 - 1L DO BEGIN
      FOR k = 0L, nd3 - 1L DO BEGIN
        tdaty        = newy[*,j,k]
        ns1y         = ns1[j]
        tempy        = SMOOTH(tdaty,ns1y,/EDGE_TRUNCATE,/NAN)
        newd1[*,j,k] = tempy
      ENDFOR
    ENDFOR
  ENDELSE
ENDIF ELSE BEGIN
  MESSAGE,'There is no finite data...',/INFORMATIONAL,/CONTINUE
  RETURN
ENDELSE
myd = CREATE_STRUCT('YTITLE',yttle,'X',d.X,'Y',newd1,'V1',d.V1,'V2',d.V2,$
                    'YLOG',d.YLOG,'LABELS',mylb,'PANEL_SIZE',d.PANEL_SIZE)

GOTO,JUMP_FIN
;-----------------------------------------------------------------------------------------
; => 2D input array
;-----------------------------------------------------------------------------------------
;=========================================================================================
JUMP_2D:
;=========================================================================================
;-----------------------------------------------------------------------------------------
; => use weighted smoothing for large background fluctuations in high E bins
;-----------------------------------------------------------------------------------------
tdy   = FLTARR(nd1,nd2)
FOR j = 0L,nd2 - 1L DO BEGIN
    tdaty    = d.Y[*,j]
    ns1y     = ns1[j]
    tempy    = SMOOTH(tdaty,ns1y,/EDGE_TRUNCATE,/NAN)
    tdy[*,j] = tempy
ENDFOR
;-----------------------------------------------------------------------------------------
; => find bad data points
;-----------------------------------------------------------------------------------------
bad = d.Y GT ((ft*ns*tdy)/(ns - 1 + ft))
wbad = WHERE(bad GT .5,wb)
IF (wb GT 0) THEN BEGIN
  wbind                      = ARRAY_INDICES(d.Y,wbad)
  d.Y[wbind[0,*],wbind[1,*]] = !VALUES.F_NAN 
ENDIF

wlow = WHERE(d.Y LT 0d0,wl)
IF (wl GT 0) THEN BEGIN
  wlind                      = ARRAY_INDICES(d.Y,wlow)
  d.y[wlind[0,*],wlind[1,*]] = !VALUES.F_NAN
ENDIF

gooddat = WHERE(FINITE(d.y) AND d.y GT 0d0,gdd,COMPLEMENT=baddat)
IF (gdd GT 0) THEN BEGIN
  IF (gdd LT SIZE(d.Y,/N_ELEMENTS)) THEN BEGIN
    gind   = ARRAY_INDICES(d.Y,gooddat)
    bind   = ARRAY_INDICES(d.Y,baddat)
    newy   = DBLARR(nd1,nd2)
    newd1  = DBLARR(nd1,nd2)
    newy[gind[0,*],gind[1,*]] = d.Y[gind[0,*],gind[1,*]]
    newy[bind[0,*],bind[1,*]] = !VALUES.F_NAN
    FOR j = 0L, nd2 - 1L DO BEGIN
      tdaty      = newy[*,j]
      ns1y       = ns1[j]
      tempy      = SMOOTH(tdaty,ns1y,/EDGE_TRUNCATE,/NAN)
      newd1[*,j] = tempy
    ENDFOR
  ENDIF ELSE BEGIN  ; => all data is good
    newy   = DBLARR(nd1,nd2)
    newd1  = DBLARR(nd1,nd2)
    newy   = d.Y
    FOR j = 0L, nd2 - 1L DO BEGIN
      tdaty      = newy[*,j]
      ns1y       = ns1[j]
      tempy      = SMOOTH(tdaty,ns1y,/EDGE_TRUNCATE,/NAN)
      newd1[*,j] = tempy
    ENDFOR
  ENDELSE
ENDIF ELSE BEGIN
  MESSAGE,'There is no finite data...',/INFORMATIONAL,/CONTINUE
  RETURN
ENDELSE
myd = CREATE_STRUCT('X',d.X,'Y',newd1,'V',d.V)
str_element,lim,'YTITLE',yttle,/ADD_REPLACE
str_element,lim,'LABELS',mylb,/ADD_REPLACE
;=========================================================================================
JUMP_FIN:
;=========================================================================================
IF NOT KEYWORD_SET(new_name) THEN new_name = name+'_cln'

store_data,new_name,DATA=myd,DLIM=dlim,LIM=lim
options,new_name,'XMINOR',4    ; => set # of minor X-Tick marks to 4
options,new_name,'YMINOR',9    ; => set # of minor Y-Tick marks to 9
;-----------------------------------------------------------------------------------------
; => Make sure y-limits are not determined by "zeroed" data or NAN's
;-----------------------------------------------------------------------------------------
gylim = WHERE(myd.Y NE 0.0 AND FINITE(myd.Y),gyli)
IF (gyli GT 0) THEN BEGIN
  CASE mdims OF
    3 : BEGIN
      gyind1 = ARRAY_INDICES(myd.Y,gylim)
      ymin1  = MIN(myd.Y[gyind1[0,*],gyind1[1,*],gyind1[2,*]],/NAN)/1.1
      ymax1  = MAX(myd.Y[gyind1[0,*],gyind1[1,*],gyind1[2,*]],/NAN)*1.1
      ylim,new_name,ymin1,ymin2,1  
    END
    2 : BEGIN
      gyind1 = ARRAY_INDICES(newy,gylim)
      ymin1  = MIN(newy[gyind1[0,*],gyind1[1,*]],/NAN)/1.1
      ymax1  = MAX(newy[gyind1[0,*],gyind1[1,*]],/NAN)*1.1
      ylim,new_name,ymin1,ymin2,1
    END
    ELSE : BEGIN
      MESSAGE,'Invalid non-finite data...',/INFORMATIONAL,/CONTINUE
      RETURN
    END
  ENDCASE
ENDIF

RETURN
END