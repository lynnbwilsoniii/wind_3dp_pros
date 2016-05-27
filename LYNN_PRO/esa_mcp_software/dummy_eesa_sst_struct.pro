;+
;*****************************************************************************************
;
;  FUNCTION :   dummy_eesa_sst_struct.pro
;  PURPOSE  :   Returns either an Eesa or SST dummy structure appropriate for 
;                 replicating.
;
;  CALLED BY: 
;               dummy_3dp_str.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NAME   : [string] Specify the type of structure you wish to 
;                          get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Added program my_str_names.pro          [08/18/2008   v1.0.2]
;             2)  Updated man page                        [03/19/2009   v1.0.3]
;             3)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                   and renamed                           [08/10/2009   v2.0.0]
;
;   CREATED:  06/16/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION dummy_eesa_sst_struct,name

;-----------------------------------------------------------------------------------------
; -Determine Str. Name
;-----------------------------------------------------------------------------------------
gn    = dat_3dp_str_names(name)
name  = gn.LC
chnn  = STRCOMPRESS(STRLOWCASE(name),/REMOVE_ALL)
IF (STRPOS(chnn,'eesa') GE 0) THEN BEGIN
  check = [STRPOS(chnn,'low'),STRPOS(chnn,'high'),STRPOS(chnn,'burst')]
  gche  = WHERE(check NE -1,gch)
  IF (gch GT 0) THEN BEGIN
    CASE gche[0] OF
      0 : BEGIN
        nyn1 = ' Low'
      END
      1 : BEGIN
        nyn1 = ' High'
      END
    ENDCASE
    IF (gch GT 1) THEN BEGIN
      IF (gche[1] EQ 2) THEN nyn2 = ' Burst' ELSE nyn2 = ''
    ENDIF ELSE BEGIN
      nyn2 = ''
    ENDELSE
  ENDIF
ENDIF ELSE BEGIN
  nyn1 = ''
  nyn2 = ''
ENDELSE
;-----------------------------------------------------------------------------------------
; -Eesa (Low, Low Burst, High, or High Burst) dummy str
;-----------------------------------------------------------------------------------------
IF (nyn1 NE '') THEN mynes = 'Eesa'+nyn1+nyn2 ELSE mynes = 'Eesa Low'
eesa_str = CREATE_STRUCT('PROJECT_NAME','Wind 3D Plasma','DATA_NAME',mynes, $
             'UNITS_NAME','Counts','UNITS_PROCEDURE','convert_esa_units',   $
             'TIME',0d0,'END_TIME',0d0,'TRANGE',[0d0,0d0],'INTEG_T',0d0,    $
             'DELTA_T',0d0,'MASS',0d0,'GEOMFACTOR',0d0,'INDEX',0l,          $
             'N_SAMPLES',0l,'SHIFT',0b,'VALID',0,'SPIN',0l,'NBINS',88,      $
             'NENERGY',15,'DACCODES',INTARR(8,15),'VOLTS',FLTARR(8,15),     $
             'DATA',FLTARR(15, 88),'ENERGY',FLTARR(15, 88),'DENERGY',       $
             FLTARR(15, 88),'PHI',FLTARR(15, 88),'DPHI',FLTARR(15, 88),     $
             'THETA',FLTARR(15, 88),'DTHETA',FLTARR(15, 88),'BINS',         $
             REPLICATE(1b,15,88),'DT',FLTARR(15, 88),'GF',FLTARR(15, 88),   $
             'BKGRATE',FLTARR(15, 88),'DEADTIME',FLTARR(15, 88),'DVOLUME',  $
             FLTARR(15, 88),'DDATA',REPLICATE(!VALUES.F_NAN,15,88),'MAGF',  $
             REPLICATE(!VALUES.F_NAN,3),'VSW',REPLICATE(!VALUES.F_NAN,3),   $
             'DOMEGA',FLTARR(88),'SC_POT',0.0,'E_SHIFT',0.0)
;-----------------------------------------------------------------------------------------
; -SST Foil dummy str
;-----------------------------------------------------------------------------------------
mynfo  = 'SST Foil'
sf_str = CREATE_STRUCT('PROJECT_NAME','Wind 3D Plasma','DATA_NAME',mynfo, $
             'UNITS_NAME','Counts','UNITS_PROCEDURE','convert_sf_units',  $
             'TIME',0d0,'END_TIME',0d0,'TRANGE',[0d0,0d0],'INTEG_T',0d0,  $
             'DELTA_T',0d0,'MASS',0d0,'GEOMFACTOR',0d0,'INDEX',0l,        $
             'N_SAMPLES',0L,'VALID',0,'SPIN',0l,'NBINS',48,'NENERGY',7,   $
             'DETECTOR',REPLICATE(0,48),'DATA',FLTARR(7,48),'ENERGY',     $
             FLTARR(7,48),'DENERGY',FLTARR(7,48),'PHI',FLTARR(7,48),      $
             'DPHI',FLTARR(7,48),'THETA',FLTARR(7,48),'DTHETA',           $
             FLTARR(7,48),'BINS',BYTARR(7,48),'DT',FLTARR(7,48),'GF',     $
             FLTARR(7,48),'BKGRATE',FLTARR(7,48),'DEADTIME',FLTARR(7,48), $ 
             'DVOLUME',FLTARR(7,48),'DDATA',FLTARR(7,48),'MAGF',          $
             REPLICATE(!VALUES.F_NAN,3),'VSW',REPLICATE(!VALUES.F_NAN,3), $
             'SC_POT',0.0,'DOMEGA',FLTARR(48),'FEFF',FLTARR(7,48))
;-----------------------------------------------------------------------------------------
; -SST Foil+Thick dummy str
;-----------------------------------------------------------------------------------------
mynft   = 'SST Foil+Thick'
sft_str = CREATE_STRUCT('PROJECT_NAME','Wind 3D Plasma','DATA_NAME',mynft,$
             'UNITS_NAME','Counts','UNITS_PROCEDURE','convert_sf_units',  $
             'TIME',0d0,'END_TIME',0d0,'TRANGE',[0d0,0d0],'INTEG_T',0d0,  $
             'DELTA_T',0d0,'MASS',0d0,'GEOMFACTOR',0d0,'INDEX',0l,        $
             'N_SAMPLES',0L,'VALID',0,'SPIN',0l,'NBINS',16,'NENERGY',7,   $
             'DETECTOR',REPLICATE(0,16),'DATA',FLTARR(7,16),'ENERGY',     $
             FLTARR(7,16),'DENERGY',FLTARR(7,16),'PHI',FLTARR(7,16),      $
             'DPHI',FLTARR(7,16),'THETA',FLTARR(7,16),'DTHETA',           $
             FLTARR(7,16),'BINS',BYTARR(7,16),'DT',FLTARR(7,16),'GF',     $
             FLTARR(7,16),'BKGRATE',FLTARR(7,16),'DEADTIME',FLTARR(7,16), $
             'DVOLUME',FLTARR(7,16),'DDATA',FLTARR(7,16),'MAGF',          $
             REPLICATE(!VALUES.F_NAN,3),'VSW',REPLICATE(!VALUES.F_NAN,3), $
             'SC_POT',0.0,'DOMEGA',FLTARR(16),'FEFF',FLTARR(7,16))
;-----------------------------------------------------------------------------------------
; -SST Open dummy str
;-----------------------------------------------------------------------------------------
mynso  = 'SST Open'
so_str = CREATE_STRUCT('PROJECT_NAME','Wind 3D Plasma','DATA_NAME',mynso, $
             'UNITS_NAME','Counts','UNITS_PROCEDURE','convert_so_units',  $
             'TIME',0d0,'END_TIME',0d0,'TRANGE',[0d0,0d0],'INTEG_T',0d0,  $
             'DELTA_T',0d0,'MASS',0d0,'GEOMFACTOR',0d0,'INDEX',0l,        $
             'N_SAMPLES',0L,'VALID',0,'SPIN',0l,'NBINS',48,'NENERGY',9,   $
             'DETECTOR',REPLICATE(0,48),'DATA',FLTARR(9,48),'ENERGY',     $
             FLTARR(9,48),'DENERGY',FLTARR(9,48),'PHI',FLTARR(9,48),      $
             'DPHI',FLTARR(9,48),'THETA',FLTARR(9,48),'DTHETA',           $
             FLTARR(9,48),'BINS',BYTARR(9,48),'DT',FLTARR(9,48),'GF',     $
             FLTARR(9,48),'BKGRATE',FLTARR(9,48),'DEADTIME',FLTARR(9,48), $
             'DVOLUME',FLTARR(9,48),'DDATA',FLTARR(9,48),'MAGF',          $
             REPLICATE(!VALUES.F_NAN,3),'VSW',REPLICATE(!VALUES.F_NAN,3), $
             'SC_POT',0.0,'DOMEGA',FLTARR(48))
;-----------------------------------------------------------------------------------------
; -SST Open+Thick dummy str
;-----------------------------------------------------------------------------------------
mynst   = 'SST Open+Thick'
sot_str = CREATE_STRUCT('PROJECT_NAME','Wind 3D Plasma','DATA_NAME',mynst,$
             'UNITS_NAME','Counts','UNITS_PROCEDURE','convert_so_units',  $
             'TIME',0d0,'END_TIME',0d0,'TRANGE',[0d0,0d0],'INTEG_T',0d0,  $
             'DELTA_T',0d0,'MASS',0d0,'GEOMFACTOR',0d0,'INDEX',0l,        $
             'N_SAMPLES',0L,'VALID',0,'SPIN',0l,'NBINS',16,'NENERGY',9,   $
             'DETECTOR',REPLICATE(0,16),'DATA',FLTARR(9,16),'ENERGY',     $
             FLTARR(9,16),'DENERGY',FLTARR(9,16),'PHI',FLTARR(9,16),      $
             'DPHI',FLTARR(9,16),'THETA',FLTARR(9,16),'DTHETA',           $
             FLTARR(9,16),'BINS',BYTARR(9,16),'DT',FLTARR(9,16),'GF',     $
             FLTARR(9,16),'BKGRATE',FLTARR(9,16),'DEADTIME',FLTARR(9,16), $
             'DVOLUME',FLTARR(9,16),'DDATA',FLTARR(9,16),'MAGF',          $
             REPLICATE(!VALUES.F_NAN,3),'VSW',REPLICATE(!VALUES.F_NAN,3), $
             'SC_POT',0.0,'DOMEGA',FLTARR(16))
;-----------------------------------------------------------------------------------------
; -Determine which structure one should return
;-----------------------------------------------------------------------------------------
check = [STRPOS(chnn,'eesa'),STRPOS(chnn,'ssto'),STRPOS(chnn,'sstf')]
gche  = WHERE(check NE -1,gch)
CASE gche[0] OF
  0 : BEGIN
    dumb = eesa_str
  END
  1 : BEGIN
    IF (STRPOS(chnn,'thick') LT 0) THEN BEGIN
      dumb = so_str
    ENDIF ELSE BEGIN
      dumb = sot_str
    ENDELSE
  END
  2 : BEGIN
    IF (STRPOS(chnn,'thick') LT 0) THEN BEGIN
      dumb = sf_str
    ENDIF ELSE BEGIN
      dumb = sft_str
    ENDELSE
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
    PRINT,'Returning default[Eesa] structure...'
    RETURN,eesa_str
  END
ENDCASE

RETURN,dumb
END
