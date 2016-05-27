;+
;*****************************************************************************************
;
;  FUNCTION :   pad.pro
;  PURPOSE  :   Creates a pitch-angle distribution (PAD) from a 3DP data structure
;                 specifically for use in distfunc.pro
;
;  CALLED BY:   NA
;
;  CALLS:
;               xyz_to_polar.pro
;               dat_3dp_energy_bins.pro
;               pangle.pro
;               pad_template.pro
;               add_magf.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               DAT    :  A 3d data structure such as those gotten from get_el,
;                           get_pl,etc. [e.g. "get_el"]
;
;  EXAMPLES:
;               pd = pad(el,NUM_PA=17L,ESTEPS=[0L,12L])
;
;  KEYWORDS:  
;               BDIR   :  Add B-field direction
;               MAGF   :  B-field vector to use for PAD calculation (if not already part
;                           dat structure)
;               ESTEPS :  Energy bins to use [2-Element array corresponding to first and
;                           last energy bin element or an array of energy bin elements]
;               BINS   :  Data bins to sum over  {e.g. [2,87] => 3rd to last data bin}
;               NUM_PA :  Number of pitch-angles to sum over (Default = 8L)
;               SPIKES :  If set, tells program to look for data spikes and eliminate them
;
;   CHANGED:  1)  Davin Larson changed something...          [04/17/2002   v1.0.21]
;             2)  Vectorized most of the calculations        [02/10/2008   v1.2.0]
;             3)  Created dummy structures to return when no finite 
;                   data is found [calls my_pad_template.pro]   
;                                                            [03/17/2008   v2.0.0]
;             4)  Forced ONLY positive results to be returned, otherwise 
;                   set to !VALUES.F_NAN                     [04/05/2008   v2.1.0]
;             5)  Fixed indexing issue for ESTEPS keyword  
;                   [calls my_3dp_energy_bins.pro]           [12/08/2008   v2.1.10]
;             6)  Try to correct for data spikes             [01/29/2009   v2.1.11]
;             7)  Added keyword:  SPIKES                     [02/08/2009   v2.1.12]
;             8)  Updated man page                           [06/22/2009   v2.2.0]
;             9)  Fixed syntax error                         [07/13/2009   v2.2.1]
;            10)  Changed called program my_pad_template.pro to pad_template.pro
;                                                            [07/20/2009   v2.2.2]
;            11)  Changed program my_3dp_energy_bins.pro to dat_3dp_energy_bins.pro
;                                                            [08/05/2009   v2.3.0]
;            12)  Fixed syntax error                         [08/05/2009   v2.3.1]
;            13)  Now allows for the use of SST Foil inputs  [09/18/2009   v2.4.0]
;            14)  Changed error message outputs slightly     [03/02/2011   v2.4.1]
;            15)  Fixed energy bin assignment for bad bin values
;                                                            [01/17/2012   v2.5.0]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  01/17/2012   v2.5.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION pad,dat,BDIR=bdir,MAGF=magf,ESTEPS=esteps,BINS=bins,NUM_PA=num_pa,SPIKES=spikes

;-----------------------------------------------------------------------------------------
; => Check input parameters
;-----------------------------------------------------------------------------------------
IF N_ELEMENTS(num_pa) EQ 0 THEN num_pa = 8
IF N_PARAMS() EQ 1 THEN use_symm = 1
;-----------------------------------------------------------------------------------------
; => Check to see if input data is an SST Foil sample
;-----------------------------------------------------------------------------------------
strn    = dat_3dp_str_names(dat)
sh_nme  = STRLOWCASE(STRMID(strn.SN,0L,2L))
IF (sh_nme[0] EQ 'sf') THEN logic_sf = 1 ELSE logic_sf = 0
;-----------------------------------------------------------------------------------------
; => Make sure energies haven't been labeled as zeros
;-----------------------------------------------------------------------------------------
my_ens  = dat_3dp_energy_bins(dat,EBINS=esteps)
estart  = my_ens.E_BINS[0]      ; -Lowest energy array element
eend    = my_ens.E_BINS[1]      ; -Highest " "
myen    = my_ens.ALL_ENERGIES   ; -Energy values (eV) for this particular 3D dist.
newbins = [estart,eend]

diffen  = eend - estart + 1L
mebins  = INTARR(diffen)
FOR i=0L, diffen - 1L DO BEGIN
  j         = i + estart
  mebins[i] = j
ENDFOR
;-----------------------------------------------------------------------------------------
; => Define some dummy variables
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(bins) NE 0) THEN ind = WHERE(bins) ELSE ind = INDGEN(dat.NBINS)
nbins    = N_ELEMENTS(ind)
nenergy  = dat.NENERGY                   ; => # of energy bins
eind     = LINDGEN(nenergy)              ; => Indices for energies
data     = FLTARR(nenergy,num_pa)        ; => Dummy array of PAD data
geom     = FLTARR(nenergy,num_pa)        ; => " " geometry factor data
dt       = FLTARR(nenergy,num_pa)        ; => " " Integration times (s)
energy   = FLTARR(nenergy,num_pa)        ; => " " energies (eV)
denergy  = FLTARR(nenergy,num_pa)        ; => " " differential energies (eV)
pang     = FLTARR(nenergy,num_pa)        ; => " " pitch-angles (deg)
count    = FLTARR(nenergy,num_pa)        ; => " " # of points calculated
deadtime = FLTARR(nenergy,num_pa)        ; => " " times when plate detector is off (s)
feff     = FLTARR(nenergy,num_pa)        ; => SST Foil electron efficiency [only if 'sf' is the name of the structure]
;-----------------------------------------------------------------------------------------
; => Get B-field data and determine its polar direction (i.e. theta and phi)
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(magf) THEN BEGIN
  gmagf = WHERE(FINITE(dat.MAGF),gmag)
  IF (gmag GT 2) THEN BEGIN
    magf = dat.MAGF
  ENDIF ELSE BEGIN
    add_magf,dat,'wi_B3(GSE)'
    gmagf2 = WHERE(FINITE(dat.MAGF),gmag2)
    IF (gmag2 GT 2) THEN BEGIN
      magf = dat.MAGF
    ENDIF ELSE BEGIN
      MESSAGE, 'No B-field data loaded or no finite data exists for this time!',/CONTINUE,/INFORMATIONAL
      dummy = pad_template(dat,NUM_PA=num_pa,ESTEPS=mebins)
      IF (logic_sf) THEN str_element,dummy,'FEFF',feff[mebins,*],/ADD_REPLACE
      RETURN,dummy
    ENDELSE
  ENDELSE
ENDIF ELSE BEGIN
  magf = magf
ENDELSE

xyz_to_polar,magf,THETA=bth,PHI=bph
;-----------------------------------------------------------------------------------------
; => Calculate Pitch-Angles from data and B-field
;-----------------------------------------------------------------------------------------
pa    = pangle(dat.THETA,dat.PHI,bth,bph)
pab   = FIX(pa/18e1*num_pa)  < (num_pa - 1) 
IF (ABS(bth) GT 9e1) THEN pab[*,*] = 0   ; -Non-physical solutions
;-----------------------------------------------------------------------------------------
; => Calculate Pitch-Angle Distributions (PADs)
;-----------------------------------------------------------------------------------------
FOR i=0L, nbins - 1L DO BEGIN
   b        = ind[i]
   e        = eind       ; -Energy bin array elements
   n_e      = e
   n_b      = pab[n_e,b] ; -Bins to use for pitch-angle estimates
   n_b_indx = WHERE(n_b GE 0 AND n_b LT num_pa,n_b_cnt)
   IF (n_b_cnt GT 0) THEN BEGIN
     e                  = e[n_b_indx]
     n_e                = e
     n_b                = n_b[n_b_indx]
     data[n_e,n_b]     += dat.DATA[e,b]
     geom[n_e,n_b]     += dat.GF[e,b]
     dt[n_e,n_b]       += dat.DT[e,b]
     energy[n_e,n_b]   += dat.ENERGY[e,b]
     denergy[n_e,n_b]  += dat.DENERGY[e,b]
     pang[n_e,n_b]     += pa[e,b]
     count[n_e,n_b]    += 1
     deadtime[n_e,n_b] += dat.DEADTIME[e,b]
     IF (logic_sf) THEN feff[n_e,n_b] += dat.FEFF[e,b]
   ENDIF
ENDFOR
energy  /= count
denergy /= count
pang    /= count
feff    /= count
;-----------------------------------------------------------------------------------------
; -Determine Scaling issues
;-----------------------------------------------------------------------------------------
IF (STRLOWCASE(dat.UNITS_NAME) NE 'counts') THEN BEGIN
  data /= count
  IF (logic_sf) THEN feff /= count
  mfac = 0.0
ENDIF ELSE BEGIN
  mfac = 0.999
ENDELSE
;-----------------------------------------------------------------------------------------
; -Eliminate negative data values
;-----------------------------------------------------------------------------------------
goodall = WHERE(FINITE(pang) AND FINITE(energy) AND FINITE(data),gdall,COMPLEMENT=badall)
IF (gdall GT 0 AND gdall LT num_pa*nenergy) THEN BEGIN
  bdind = ARRAY_INDICES(data,badall)
  data[bdind[0,*],bdind[1,*]]   = !VALUES.F_NAN
  pang[bdind[0,*],bdind[1,*]]   = !VALUES.F_NAN
  energy[bdind[0,*],bdind[1,*]] = !VALUES.F_NAN
ENDIF ELSE BEGIN
  IF (gdall EQ 0) THEN BEGIN
    MESSAGE, 'There are no finite pitch-angles! (1)',/CONTINUE,/INFORMATIONAL
    dummy = pad_template(dat,NUM_PA=num_pa,ESTEPS=mebins)
    IF (logic_sf) THEN str_element,dummy,'FEFF',feff[mebins,*],/ADD_REPLACE
    RETURN,dummy
  ENDIF
ENDELSE

bddd = WHERE(data LT 0.0,bdd)
IF (bdd GT 0) THEN BEGIN
  bidd  = ARRAY_INDICES(data,bddd)
  data[bidd[0,*],bidd[1,*]] = !VALUES.F_NAN
ENDIF
;-----------------------------------------------------------------------------------------
; -Interpolate data (if there aren't too many non-finite values)
;-----------------------------------------------------------------------------------------
tepang = TOTAL(FINITE(pang),1,/NAN)   ; -normalizing factor for next line
tpang1 = TOTAL(pang,1,/NAN)/tepang    ; -new estimates of pitch-angles (deg)
teener = TOTAL(FINITE(energy),2,/NAN) ; -normalizing factor for next line
tener1 = TOTAL(energy,2,/NAN)/ teener ; -new estimates of bin values (eV)
newd   = FLTARR(nenergy,num_pa)       ; -new data (interpolated over /NAN's)
newp   = FLTARR(nenergy,num_pa)       ; -new pitch-angles (interpolated over /NAN's)
;-----------------------------------------------------------------------------------------
; -Get rid of non-finite or negative energy bin values
;-----------------------------------------------------------------------------------------
bener  = WHERE(energy LE 0.0 OR FINITE(energy) EQ 0,ben)
IF (ben GT 0) THEN BEGIN
  bind    = ARRAY_INDICES(energy,bener)
  becheck = WHERE(tener1 LE 0.0 OR FINITE(tener1) EQ 0,bec)
  IF (bec EQ 0) THEN BEGIN
;    LBW III  01/17/2012
;    tener2 = REPLICATE(1.,num_pa) # tener1
    tener2 = tener1 # REPLICATE(1.,num_pa)
    energy[bind[0,*],bind[1,*]] = tener2[bind[0,*],bind[1,*]]
  ENDIF ELSE BEGIN
    tener1[becheck] = myen[becheck]
;    LBW III  01/17/2012
;    tener2 = REPLICATE(1.,num_pa) # tener1
    tener2 = tener1 # REPLICATE(1.,num_pa)
    energy[bind[0,*],bind[1,*]] = tener2[bind[0,*],bind[1,*]]
  ENDELSE
ENDIF

bpang = WHERE(pang LE 0.0 OR FINITE(pang) EQ 0,bpg)
IF (bpg GT 0) THEN BEGIN
  bind    = ARRAY_INDICES(pang,bpang)
  bpcheck = WHERE(tpang1 LE 0.0 OR FINITE(tpang1) EQ 0,bpc,COMPLEMENT=gpcheck)
  IF (bpc EQ 0) THEN BEGIN
    tpang3  = REPLICATE(1.,nenergy) # tpang1
    pang[bind[0,*],bind[1,*]] = tpang3[bind[0,*],bind[1,*]]
  ENDIF ELSE BEGIN
    tpang1[bpcheck] = !VALUES.F_NAN
    tpang3  = REPLICATE(1.,nenergy) # tpang1
    pang[bind[0,*],bind[1,*]] = tpang3[bind[0,*],bind[1,*]]
  ENDELSE
ENDIF
;-----------------------------------------------------------------------------------------
; -Use desired energy bins
;-----------------------------------------------------------------------------------------
energy   = energy[mebins,*]
denergy  = denergy[mebins,*]
newp     = pang[mebins,*]
newd     = data[mebins,*]
geom     = geom[mebins,*]
dt       = dt[mebins,*]
count    = count[mebins,*]
deadtime = deadtime[mebins,*]
nenergy  = N_ELEMENTS(mebins)
;-----------------------------------------------------------------------------------------
; -Make sure no data is < 0.0 (since negative fluxes are meaningless)
;-----------------------------------------------------------------------------------------
badd = WHERE(newd LE 0.0,bdd)
IF (bdd GT 0) THEN BEGIN
  bidd  = ARRAY_INDICES(newd,badd)
  newd[bidd[0,*],bidd[1,*]] = !VALUES.F_NAN
ENDIF
;-----------------------------------------------------------------------------------------
; -Deal with data spikes if possible (typically used for Eesa High data)
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(spikes) THEN BEGIN
  avdata = TOTAL(newd,2,/NAN)/TOTAL(FINITE(newd),2,/NAN)
  FOR jj=0L, nenergy - 1L DO BEGIN
    bdd = WHERE(newd[jj,*] GT avdata[jj],bd,COMPLEMENT=gdd)
    IF (bd GT 0L) THEN BEGIN
      n_mean  = TOTAL(newd[jj,gdd],2,/NAN)/TOTAL(FINITE(newd[jj,gdd]),2,/NAN)
      n_ratio = (n_mean/avdata[jj])*1e2
      IF (n_ratio LT 1e0) THEN newd[jj,bdd] = !VALUES.F_NAN
    ENDIF
  ENDFOR
ENDIF

goodall2 = WHERE(FINITE(newp) AND FINITE(energy) AND FINITE(newd),gdall2,COMPLEMENT=badall2)
IF (gdall2 GT 0 AND gdall2 LT num_pa*nenergy) THEN BEGIN
  bdind2 = ARRAY_INDICES(newd,badall2)
  newd[bdind2[0,*],bdind2[1,*]]   = !VALUES.F_NAN
  newp[bdind2[0,*],bdind2[1,*]]   = !VALUES.F_NAN
  energy[bdind2[0,*],bdind2[1,*]] = !VALUES.F_NAN
ENDIF ELSE BEGIN
  IF (gdall2 EQ 0) THEN BEGIN
    MESSAGE, 'There are no finite pitch-angles! (2)',/CONTINUE,/INFORMATIONAL
    dummy = pad_template(dat,NUM_PA=num_pa,ESTEPS=mebins)
    IF (logic_sf) THEN str_element,dummy,'FEFF',feff[mebins,*],/ADD_REPLACE
    RETURN,dummy
  ENDIF
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define and return data structure
;-----------------------------------------------------------------------------------------
pdtags = ['PROJECT_NAME','DATA_NAME','VALID','UNITS_NAME','TIME','END_TIME','INTEG_T',$
          'NBINS','NENERGY','DATA','ENERGY','ANGLES','DENERGY','BTH','BPH','GF','DT', $
          'GEOMFACTOR','MASS','UNITS_PROCEDURE','DEADTIME']

pad    = CREATE_STRUCT(pdtags,dat.PROJECT_NAME,dat.DATA_NAME+' PAD',1,dat.UNITS_NAME, $
                       dat.TIME,dat.END_TIME,dat.INTEG_T,num_pa,nenergy,newd,         $
                       energy,newp,denergy,bth,bph,geom,dt,dat.GEOMFACTOR,            $
                       dat.MASS,dat.UNITS_PROCEDURE,deadtime)

IF (logic_sf) THEN str_element,pad,'FEFF',feff[mebins,*],/ADD_REPLACE
RETURN,pad
END

