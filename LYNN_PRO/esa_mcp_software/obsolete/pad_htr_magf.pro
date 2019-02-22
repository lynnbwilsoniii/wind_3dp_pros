;+
;*****************************************************************************************
;
;  FUNCTION :   pad_htr_magf.pro
;  PURPOSE  :   Creates a pitch-angle distribution (PAD) from a 3DP data structure
;                 using the instantaneous magnetic field values from the high time
;                 resolution (HTR) data.
;
;  CALLED BY:   
;               
;
;  CALLS:
;               dat_3dp_str_names.pro
;               pad_htr_template.pro
;               dat_3dp_energy_bins.pro
;               htr_3dp_pad.pro
;               str_element.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure(s) either from get_??.pro
;                               [?? = el, elb, phb, sf, etc.]
;               TIME_ANGS  :  [N,M]-Element array of Unix times associated with the
;                               [N,M]-element arrays found in DAT (e.g. DAT.THETA)
;                                 [N = # of energy bins, M = # of angle bins]
;               BGSE_HTR   :  HTR B-field structure of format:
;                               {X:Unix Times, Y:[K,3]-Element Vector}
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               ESTEPS     :  Energy bins to use [2-Element array corresponding to
;                               first and last energy bin element or an array of
;                               energy bin elements]
;               NUM_PA     :  Number of pitch-angles to sum over (Default = 8L)
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  01/17/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/17/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION pad_htr_magf,dat,time_angs,bgse_htr,ESTEPS=esteps,NUM_PA=num_pa

;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input parameters
;-----------------------------------------------------------------------------------------
IF N_ELEMENTS(num_pa) EQ 0 THEN num_pa = 8
;-----------------------------------------------------------------------------------------
; => Check to see if input data is an SST Foil sample
;-----------------------------------------------------------------------------------------
strn    = dat_3dp_str_names(dat)
sh_nme  = STRLOWCASE(STRMID(strn.SN,0L,2L))
IF (sh_nme[0] EQ 'sf') THEN logic_sf = 1 ELSE logic_sf = 0

dummy    = pad_htr_template(dat,NUM_PA=num_pa)
IF (logic_sf) THEN str_element,dummy,'FEFF',FLTARR(dat.NENERGY,num_pa),/ADD_REPLACE
IF (N_PARAMS() LT 3) THEN RETURN,dummy
;-----------------------------------------------------------------------------------------
; => Make sure energies haven't been labeled as zeros
;-----------------------------------------------------------------------------------------
my_ens   = dat_3dp_energy_bins(dat,EBINS=esteps)
estart   = my_ens.E_BINS[0]      ; -Lowest energy array element
eend     = my_ens.E_BINS[1]      ; -Highest " "
myen     = my_ens.ALL_ENERGIES   ; -Energy values (eV) for this particular 3D dist.
newbins  = [estart,eend]

diffen   = eend - estart + 1L
mebins   = INTARR(diffen)
FOR i=0L, diffen - 1L DO BEGIN
  j         = i + estart
  mebins[i] = j
ENDFOR
;-----------------------------------------------------------------------------------------
; => Calculate Pitch-Angles from data and B-field
;-----------------------------------------------------------------------------------------
htrpads  = htr_3dp_pad(dat,time_angs,bgse_htr,BTHE=bthe,BPHI=bphi)
bthe     = FLOAT(bthe)
bphi     = FLOAT(bphi)
; => Define pitch-angles [deg] and associated bin numbers
pa       = htrpads
pab      = FIX(pa/18e1*num_pa[0])  < (num_pa[0] - 1)
;-----------------------------------------------------------------------------------------
; => Define some dummy parameters
;-----------------------------------------------------------------------------------------
nbins    = dat.NBINS
nenergy  = dat.NENERGY                   ; => # of energy bins

ind      = INDGEN(nbins)
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
; => Calculate Pitch-Angle Distributions (PADs)
;-----------------------------------------------------------------------------------------
n_n      = 0
FOR i=0L, nbins - 1L DO BEGIN
   bi       = ind[i]
   n_e      = eind         ; => Energy bin array elements
   n_b      = pab[n_e,bi]  ; => Bins to use for pitch-angle estimates
   n_b_indx = WHERE(n_b GE 0 AND n_b LT num_pa,n_b_cnt)
   IF (n_b_cnt GT 0) THEN BEGIN
     ei                 = n_e[n_b_indx]       ; => Energy bin elements
     n_n                = ei
     n_b                = n_b[n_b_indx]       ; => Pitch-angle bin elements
     data[n_n,n_b]     += dat.DATA[ei,bi]
     geom[n_n,n_b]     += dat.GF[ei,bi]
     dt[n_n,n_b]       += dat.DT[ei,bi]
     energy[n_n,n_b]   += dat.ENERGY[ei,bi]
     denergy[n_n,n_b]  += dat.DENERGY[ei,bi]
     pang[n_n,n_b]     += pa[ei,bi]
     count[n_n,n_b]    += 1
     deadtime[n_n,n_b] += dat.DEADTIME[ei,bi]
     IF (logic_sf) THEN feff[n_n,n_b] += dat.FEFF[ei,bi]
   ENDIF
ENDFOR
energy  /= count
denergy /= count
pang    /= count
feff    /= count
;-----------------------------------------------------------------------------------------
; => Determine Scaling issues
;-----------------------------------------------------------------------------------------
IF (STRLOWCASE(dat.UNITS_NAME) NE 'counts') THEN BEGIN
  data /= count
  IF (logic_sf) THEN feff /= count
  mfac = 0.0
ENDIF ELSE BEGIN
  mfac = 0.999
ENDELSE
;-----------------------------------------------------------------------------------------
; => Eliminate negative data values
;-----------------------------------------------------------------------------------------
test    = FINITE(pang) AND FINITE(energy) AND FINITE(data) AND (data GT 0.0)
good    = WHERE(test,gd,COMPLEMENT=bad,NCOMPLEMENT=bd)
IF (gd EQ 0) THEN BEGIN
  MESSAGE, 'There are no finite data points! (1)',/CONTINUE,/INFORMATIONAL
  ; => No good data points
  dummy    = pad_htr_template(dat,NUM_PA=num_pa,ESTEPS=mebins)
  IF (logic_sf) THEN str_element,pad,'FEFF',feff[mebins,*],/ADD_REPLACE
  RETURN,dummy
ENDIF

IF (bd GT 0) THEN BEGIN
  ; => Make sure negative/zeroed data points are set to NaN
  bind  = ARRAY_INDICES(data,bad)
  data[bind[0,*],bind[1,*]]   = f
  pang[bind[0,*],bind[1,*]]   = f
  energy[bind[0,*],bind[1,*]] = f
ENDIF
;-----------------------------------------------------------------------------------------
; => Define averaged energy and angle bin values
;-----------------------------------------------------------------------------------------
tepang = TOTAL(FINITE(pang),1,/NAN)     ; => normalizing factor for angles
tpang1 = TOTAL(pang,1,/NAN)/tepang      ; => new estimates of pitch-angles (deg)
tpang2 = REPLICATE(1.,nenergy) # tpang1 ; => 2D pitch-angles
tener1 = myen                           ; => new estimates of energy bin values (eV)
tener2 = tener1 # REPLICATE(1.,num_pa)  ; => 2D energies
newd   = FLTARR(nenergy,num_pa)         ; => new data (interpolated over /NAN's)
newp   = FLTARR(nenergy,num_pa)         ; => new pitch-angles (interpolated over /NAN's)
;-----------------------------------------------------------------------------------------
; => Check energy bin values
;-----------------------------------------------------------------------------------------
test   = (energy LE 0.0) OR (FINITE(energy) EQ 0)
bad    = WHERE(test,bd)
IF (bd GT 0) THEN BEGIN
  bind                        = ARRAY_INDICES(energy,bad)
  energy[bind[0,*],bind[1,*]] = tener2[bind[0,*],bind[1,*]]
ENDIF
;-----------------------------------------------------------------------------------------
; => Check pitch-angle bin values
;-----------------------------------------------------------------------------------------
test   = (pang LE 0.0) OR (FINITE(pang) EQ 0)
bad    = WHERE(test,bd)
IF (bd GT 0) THEN BEGIN
  bind                        = ARRAY_INDICES(pang,bad)
  pang[bind[0,*],bind[1,*]]   = tpang2[bind[0,*],bind[1,*]]
ENDIF
;-----------------------------------------------------------------------------------------
; => Use desired energy bins
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
; => Define and return data structure
;-----------------------------------------------------------------------------------------
pdtags = ['PROJECT_NAME','DATA_NAME','VALID','UNITS_NAME','TIME','END_TIME','INTEG_T',$
          'NBINS','NENERGY','DATA','ENERGY','ANGLES','DENERGY','BTH','BPH','GF','DT', $
          'GEOMFACTOR','MASS','UNITS_PROCEDURE','DEADTIME']

pad    = CREATE_STRUCT(pdtags,dat.PROJECT_NAME,dat.DATA_NAME+' PAD',1,dat.UNITS_NAME, $
                       dat.TIME,dat.END_TIME,dat.INTEG_T,num_pa,nenergy,newd,         $
                       energy,newp,denergy,bthe,bphi,geom,dt,dat.GEOMFACTOR,          $
                       dat.MASS,dat.UNITS_PROCEDURE,deadtime)
; => Add SST Foil efficiency if necessary
IF (logic_sf) THEN str_element,pad,'FEFF',feff[mebins,*],/ADD_REPLACE

RETURN,pad
END