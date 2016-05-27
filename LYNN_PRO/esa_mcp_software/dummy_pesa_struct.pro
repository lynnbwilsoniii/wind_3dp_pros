;+
;*****************************************************************************************
;
;  FUNCTION :   dummy_pesa_struct.pro
;  PURPOSE  :   Returns either a Pesa Low or Pesa High dummy structure appropriate for 
;                 replicating.
;
;  CALLED BY: 
;               dummy_3dp_str.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;               get_??.pro (?? = eh,elb,pl,plb,ph,phb...)
;               get_ph_mapcode.pro
;               get_phb_mapcode.pro
;               pesa_high_dummy_str.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               NAME   : [string] Specify the type of structure you wish to 
;                          get the data for [i.e. 'el','eh','elb',etc.]
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               INDEX  :  [long] Array of indicies associated w/ data structs
;
;   CHANGED:  1)  Added keyword: INDEX                    [08/18/2008   v1.0.5]
;             2)  Updated man page                        [03/19/2009   v1.0.6]
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

FUNCTION dummy_pesa_struct,name,INDEX=indx

;*****************************************************************************************
; -Determine which detector we're interested in
;*****************************************************************************************
gn    = dat_3dp_str_names(name)
name  = gn.LC
chnn  = STRCOMPRESS(STRLOWCASE(name),/REMOVE_ALL)
check = [STRPOS(chnn,'pesa'),STRPOS(chnn,'low'),STRPOS(chnn,'high')]
gche  = WHERE(check NE -1,gch)
myn1  = name
IF (gche[0] LT 0) THEN BEGIN
  MESSAGE,'Incorrect input format:  '+name,/INFORMATIONAL,/CONTINUE
  RETURN,name
ENDIF ELSE BEGIN
  IF (gch LT 2) THEN BEGIN
    MESSAGE,'Incomplete structure name:  '+name,/INFORMATIONAL,/CONTINUE
    READ,tn,PROMPT='Enter Low or High to specify detector: '
    tn = STRCOMPRESS(STRLOWCASE(tn),/REMOVE_ALL)
    CASE tn OF
      'low'  : myn2 = 'pesa low'
      'high' : myn2 = 'pesa high'
      ELSE   : BEGIN
        PRINT,'Seriously?...'
        RETURN,0
      END
    ENDCASE
    READ,bur,PROMPT='Enter 1 if you want Burst data, else 0: '
    CASE bur OF
      1    : nyn1 = ' Burst'
      ELSE : nyn1 = ''
    ENDCASE
    myn2 = myn2+STRLOWCASE(nyn1)
  ENDIF ELSE BEGIN
    CASE gche[1] OF
      1 : myn2 = 'pesa low'
      2 : myn2 = 'pesa high'
    ENDCASE
    check2 = STRPOS(chnn,'burst')
    IF (check2 LT 0) THEN nyn1 = '' ELSE nyn1 = ' Burst'
    myn2 = myn2+STRLOWCASE(nyn1)
  ENDELSE
ENDELSE

IF KEYWORD_SET(indx) THEN BEGIN
  fn1    = 'get_'+gn.SN
  idx    = indx  ; -indices of desired pesa structures
  myto   = CALL_FUNCTION(fn1,/TIMES)  ; Str. moment times
  gmto   = WHERE(FINITE(myto[idx]),gmt)
  myto   = myto[idx]
  IF (gmt GT 0) THEN BEGIN
    myto = myto[gmto]
  ENDIF ELSE BEGIN
    myto = !VALUES.F_NAN
    MESSAGE,"No data was loaded...",/INFORMATIONAL,/CONTINUE
    RETURN,0
  ENDELSE
  myopt  = LONG([2,47,0])
  istart = idx[0]
  irange = [istart,idx[(N_ELEMENTS(idx)-1L)]]
ENDIF ELSE BEGIN
  fn1    = 'get_'+gn.SN
  myto   = CALL_FUNCTION(fn1,/TIMES)  ; Str. moment times
  gmto   = WHERE(FINITE(myto),gmt)
  istart = 0L
  irange = [istart,N_ELEMENTS(myto) - 1L]
  idx    = LINDGEN(gmt) + istart
  myopt  = LONG([2,-1,0])
ENDELSE
;*****************************************************************************************
; -mapcodes of Pesa High detector
;*****************************************************************************************
mapcode = LONARR(gmt)
gyn = gn.SN
IF (gyn EQ 'ph' OR gyn EQ 'phb') THEN BEGIN
  adv        = 0
  CASE gyn OF
    'ph' : BEGIN
      FOR i=0L,gmt-1L DO BEGIN
        IF (myopt[1] EQ 47L) THEN myopt[1] = idx[i]
        mapcode[i] = get_ph_mapcode(myto[i],INDEX=idx[i],OPTIONS=myopt,ADVANCE=adv)
      ENDFOR
    END
    'phb' : BEGIN
      myopt[0] = 15L
      FOR i=0L,gmt-1L DO BEGIN
        IF (myopt[1] EQ 47L) THEN myopt[1] = idx[i]
        mapcode[i] = get_phb_mapcode(myto[i],INDEX=idx[i],OPTIONS=options,ADVANCE=adv)
      ENDFOR
    END
  ENDCASE
  mapcode2 = mapcode[0]
  badmap = WHERE(mapcode NE mapcode2,bdmp,COMPLEMENT=goodmap)
  IF (bdmp GT 0) THEN BEGIN
    MESSAGE,"Mapcode is not a single value throughout!",/INFORMATIONAL,/CONTINUE
    nbins = INTARR(gmt)
    FOR i=0L, gmt-1L DO BEGIN
      mapstr = STRUPCASE(STRING(mapcode[i],format='(z4.4)'))
      CASE mapstr OF
        'D4A4' : nbins[i] = 121
        'D4FE' : nbins[i] = 97
        'D5EC' : nbins[i] = 56
        'D6BB' : nbins[i] = 65
        'D65D' : nbins[i] = 88
        ELSE   : BEGIN
          nbins[i] = 88
        END
      ENDCASE
    ENDFOR
    mapcode2 = mapcode[0]
  ENDIF ELSE BEGIN
    mapcode2 = mapcode[0]
    mapstr = STRUPCASE(STRING(mapcode2,format='(z4.4)'))
    CASE mapstr OF
      'D4A4' : nbins = 121
      'D4FE' : nbins = 97
      'D5EC' : nbins = 56
      'D6BB' : nbins = 65
      'D65D' : nbins = 88
      ELSE   : BEGIN
        nbins = 88
      END
    ENDCASE
  ENDELSE
  uncode = UNIQ(nbins,SORT(nbins))
  ncode  = N_ELEMENTS(uncode)
  IF (ncode GT 1L) THEN BEGIN
    nstrs  = ncode  ; -# of different structures needed
    nubin  = LONARR(nstrs)
    mucode = LONARR(nstrs)
    nubin  = nbins[uncode]
    mucode = mapcode[uncode]
    PRINT,"Multiple mapcodes: "
    PRINT,mucode
    PRINT,"Multiple data bins: "
    PRINT,nubin
    PRINT,""
  ENDIF ELSE BEGIN
    nbins    = nbins[0]
    mapcode2 = mapcode[0]
  ENDELSE
ENDIF ELSE BEGIN
  mapcode2 = 54526L
  nbins    = 88
  ncode    = 1L
ENDELSE
;*****************************************************************************************
; -Pesa Low structure
;*****************************************************************************************
myn    = 'Pesa Low'
pl_str = CREATE_STRUCT('PROJECT_NAME','Wind 3D Plasma','DATA_NAME',myn,  $
             'UNITS_NAME','Counts','UNITS_PROCEDURE','convert_esa_units',$
             'TIME',0d0,'END_TIME',0d0,'TRANGE',[0d0,0d0],'INTEG_T',0d0, $
             'DELTA_T',0d0,'MASS',0d0,'GEOMFACTOR',0d0,'INDEX',0l,       $
             'VALID',0,'SPIN',0l,'NBINS',25,'NENERGY',14,'DACCODES',     $
             INTARR(4,14),'VOLTS',FLTARR(4,14),'DATA',FLTARR(14, 25),    $
             'ENERGY',FLTARR(14, 25),'DENERGY',FLTARR(14, 25),'PHI',     $
             FLTARR(14, 25),'DPHI',FLTARR(14, 25),'THETA',FLTARR(14, 25),$
             'DTHETA',FLTARR(14, 25),'BINS',REPLICATE(1b,14,25),'DT',    $
             FLTARR(14, 25),'GF',FLTARR(14, 25),'BKGRATE',FLTARR(14, 25),$
             'DEADTIME',FLTARR(14, 25),'DVOLUME',FLTARR(14, 25),'DDATA', $
             FLTARR(14, 25),'MAGF',REPLICATE(!VALUES.F_NAN,3),'SC_POT',  $
             0.0,'P_SHIFT',0b,'T_SHIFT',0b,'E_SHIFT',0b,'DOMEGA',        $
             FLTARR(25))
             
myn    = 'Pesa Low Burst'
plb_str = CREATE_STRUCT('PROJECT_NAME','Wind 3D Plasma','DATA_NAME',myn,  $
             'UNITS_NAME','Counts','UNITS_PROCEDURE','convert_esa_units',$
             'TIME',0d0,'END_TIME',0d0,'TRANGE',[0d0,0d0],'INTEG_T',0d0, $
             'DELTA_T',0d0,'MASS',0d0,'GEOMFACTOR',0d0,'INDEX',0l,       $
             'VALID',0,'SPIN',0l,'NBINS',64,'NENERGY',14,'DACCODES',     $
             INTARR(4,14),'VOLTS',FLTARR(4,14),'DATA',FLTARR(14, 64),    $
             'ENERGY',FLTARR(14, 64),'DENERGY',FLTARR(14, 64),'PHI',     $
             FLTARR(14, 64),'DPHI',FLTARR(14, 64),'THETA',FLTARR(14, 64),$
             'DTHETA',FLTARR(14, 64),'BINS',REPLICATE(1b,14,64),'DT',    $
             FLTARR(14, 64),'GF',FLTARR(14, 64),'BKGRATE',FLTARR(14, 64),$
             'DEADTIME',FLTARR(14, 64),'DVOLUME',FLTARR(14, 64),'DDATA', $
             FLTARR(14, 64),'MAGF',REPLICATE(!VALUES.F_NAN,3),'SC_POT',  $
             0.0,'P_SHIFT',0b,'T_SHIFT',0b,'E_SHIFT',0b,'DOMEGA',        $
             FLTARR(64))

myn    = 'Pesa High'+nyn1
IF (ncode GT 1L) THEN BEGIN
  CASE ncode OF
    2 : BEGIN
      ph_str1 = pesa_high_dummy_str(myn,nubin[0],mucode[0])
      ph_str2 = pesa_high_dummy_str(myn,nubin[1],mucode[1])
      ind_1   = WHERE(nbins EQ nubin[0],in1)
      ind_2   = WHERE(nbins EQ nubin[1],in2)
      gind_r1 = [ind_1[0],ind_1[in1-1L]]  ; -index range for 1st mapcode
      gind_r2 = [ind_2[0],ind_2[in2-1L]]  ; -index range for 2nd mapcode
      my_inds = [[gind_r1],[gind_r2]] + irange[0]
      ph_str  = CREATE_STRUCT('PH1_B',ph_str1,'PH2_B',ph_str2,$
                              'INDX1',my_inds)
      phn     = STRLOWCASE(ph_str1.DATA_NAME)
    END
    3 : BEGIN
      ph_str1 = pesa_high_dummy_str(myn,nubin[0],mucode[0])
      ph_str2 = pesa_high_dummy_str(myn,nubin[1],mucode[1])
      ph_str3 = pesa_high_dummy_str(myn,nubin[2],mucode[2])
      ind_1   = WHERE(nbins EQ nubin[0],in1)
      ind_2   = WHERE(nbins EQ nubin[1],in2)
      ind_3   = WHERE(nbins EQ nubin[2],in3)
      gind_r1 = [ind_1[0],ind_1[in1-1L]]  ; -index range for 1st mapcode
      gind_r2 = [ind_2[0],ind_2[in2-1L]]  ; -index range for 2nd mapcode
      gind_r3 = [ind_3[0],ind_3[in3-1L]]  ; -index range for 3rd mapcode
      my_inds = [[gind_r1],[gind_r2],[gind_r3]] + irange[0]
      ph_str  = CREATE_STRUCT('PH1_B',ph_str1,'PH2_B',ph_str2,$
                              'PH3_B',ph_str3,'INDX',my_inds)
      phn     = STRLOWCASE(ph_str1.DATA_NAME)
    END
    ELSE : BEGIN
      MESSAGE,"Too many mapcodes...load less data...",/INFORMATIONAL,/CONTINUE
      ph_str1 = pesa_high_dummy_str(myn,88,54526L)
      RETURN,ph_str1
    END
  ENDCASE
ENDIF ELSE BEGIN
  ph_str = pesa_high_dummy_str(myn,nbins[0],mapcode2)
  phn  = STRLOWCASE(ph_str.DATA_NAME)
ENDELSE
;*****************************************************************************************
; -Determine which structure to get
;*****************************************************************************************
pln  = STRLOWCASE(pl_str.DATA_NAME)
plbn = STRLOWCASE(plb_str.DATA_NAME)
good = WHERE(myn2 EQ [pln,plbn,phn],gd)
IF (gd GT 0) THEN BEGIN
  CASE good[0] OF
    0 : RETURN,pl_str
    1 : RETURN,plb_str
    2 : RETURN,ph_str
  ENDCASE
ENDIF ELSE BEGIN
  MESSAGE,'Bad structure names...',/INFORMATIONAL,/CONTINUE
  RETURN,0
ENDELSE

END
