;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_high_moment_calibrate.pro
;  PURPOSE  :   This program calls the ion moments from the PESA High detector on the
;                 Wind spacecrafts 3DP instrument.  The data is interpolated to
;                 eliminate data gaps and data glitch unique to the PESA high detector.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               get_ph.pro
;               get_phb.pro
;               get_3dp_structs.pro
;               tnames.pro
;               pesa_high_dummy_str.pro
;               pesa_high_bad_bins.pro
;               dat_3dp_energy_bins.pro
;               str_element.pro
;               mom3d.pro
;               interp.pro
;               store_data.pro
;               options.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               DATE      :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE    :  [Double] 2-Element array specifying the time range over 
;                              which to get data structures for [Unix time]
;               NOLOAD    :  If set, program does not attempt to call the program
;                              get_moment3d.pro because it assumes you've already
;                              loaded the relevant ion data.  [use on iMac]
;               PHM       :  N-Element array of Pesa High 3DP moment structures.  
;                              This keyword is intended to be used in association 
;                              with the NOLOAD keyword specifically for users with
;                              IDL save files on a non-SunMachine computer.
;               PHBM      :  N-Element array of Pesa High Burst 3DP moment structures.
;                              This keyword is intended to be used in association 
;                              with the NOLOAD keyword specifically for users with
;                              IDL save files on a non-SunMachine computer.
;               G_MAGF    :  If set, tells program that the structures in PLM or PLBM
;                              already have the magnetic field added to them thus 
;                              preventing this program from calling add_magf2.pro 
;                              again.
;               BNAME     :  Scalar string defining the TPLOT name of the B-field
;                              times you wish to interpolate the positions to
;                              [Default = 'wi_B3(GSE)']
;
;   CHANGED:  1)  Fixed typo when NOLOAD is not set               [08/05/2010   v1.0.1]
;             2)  Fixed typo associated with NOLOAD keyword       [08/10/2010   v1.0.2]
;             3)  Added keyword:  BNAME                           [04/16/2011   v1.0.3]
;             4)  Fixed typo in BNAME default                     [05/05/2011   v1.0.4]
;
;   NOTES:      
;               
;
;   CREATED:  04/27/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  05/05/2011   v1.0.4
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO pesa_high_moment_calibrate,DATE=date,TRANGE=trange,NOLOAD=noload,$
                              PHM=phm,PHBM=phbm,G_MAGF=g_magf,BNAME=bname

;-----------------------------------------------------------------------------------------
; -Define dummy variables
;-----------------------------------------------------------------------------------------
f         = !VALUES.F_NAN
d         = !VALUES.D_NAN
IF KEYWORD_SET(bname) THEN tbname = bname[0] ELSE tbname = 'wi_B3(GSE)'
;-----------------------------------------------------------------------------------------
; -Get Date associated with files of interest
;-----------------------------------------------------------------------------------------
mydate  = my_str_date(DATE=date)
date    = mydate.S_DATE[0]  ; -('MMDDYY')
mdate   = mydate.DATE[0]    ; -('YYYYMMDD')
tdate   = mydate.TDATE[0]   ; -['YYYY-MM-DD']
;-----------------------------------------------------------------------------------------
; => Look at time range
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(trange) THEN BEGIN
  tr3 = DOUBLE(trange)
ENDIF ELSE BEGIN
  IF NOT KEYWORD_SET(noload) THEN BEGIN
    tt0 = [get_ph(/TIMES),get_phb(/TIMES)]
    tr3 = [MIN(tt0,/NAN),MAX(tt0,/NAN)]
  ENDIF ELSE BEGIN
    phtype    = SIZE(phm,/TYPE)
    phbtype   = SIZE(phbm,/TYPE)
    IF (KEYWORD_SET(phm) AND phtype EQ 8L) THEN BEGIN
      test = (STRLOWCASE(TAG_NAMES(phm)) EQ 'time')
      good = WHERE(test,gd)
      IF (gd GT 0) THEN t_00 = phm[good].TIME ELSE t_00 = d
    ENDIF
    IF (KEYWORD_SET(phbm) AND phbtype EQ 8L) THEN BEGIN
      test = (STRLOWCASE(TAG_NAMES(phbm)) EQ 'time')
      good = WHERE(test,gd)
      IF (gd GT 0) THEN t_11 = phbm[good].TIME ELSE t_11 = d
    ENDIF ELSE t_11 = d
    tt0 = [t_00,t_11]
    tr3 = [MIN(tt0,/NAN),MAX(tt0,/NAN)]
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => First check for ion moments
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(noload) THEN BEGIN
  ph_times  = get_ph(/TIMES)
  phb_times = get_phb(/TIMES)
  nph       = N_ELEMENTS(ph_times)
  nphb      = N_ELEMENTS(phb_times)
  aphd      = get_3dp_structs('ph' ,TRANGE=tr3)
  aphbd     = get_3dp_structs('phb' ,TRANGE=tr3)
ENDIF ELSE BEGIN
  phtype    = SIZE(phm,/TYPE)
  phbtype   = SIZE(phbm,/TYPE)
  IF (NOT KEYWORD_SET(phm) OR phtype NE 8L) THEN BEGIN
    pl_times  = 0d0
    npl       = 0L
    aph       = pesa_high_dummy_str('Pesa High',121L,54436L)
  ENDIF ELSE BEGIN
    aph       = phm
    ph_times  = REFORM(aph.TIME)
    nph       = N_ELEMENTS(aph)
  ENDELSE
  IF (NOT KEYWORD_SET(phbm) OR phbtype NE 8L) THEN BEGIN
    phb_times  = 0d0
    nphb       = 0L
    aphb       = pesa_high_dummy_str('Pesa High Burst',121L,54436L)
  ENDIF ELSE BEGIN
    aphb       = phbm
    phb_times  = REFORM(phbm.TIME)
    nphb       = N_ELEMENTS(phbm)
  ENDELSE
ENDELSE
; => Make sure something was found or sent to program
IF (ph_times[0] EQ 0d0)  THEN g_h = 0L  ELSE g_h  = N_ELEMENTS(ph_times)
IF (phb_times[0] EQ 0d0) THEN g_hb = 0L ELSE g_hb = N_ELEMENTS(phb_times)
IF (g_h EQ 0L AND g_hb EQ 0L) THEN BEGIN
  MESSAGE,'No ion moments were found...',/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for B-field
;-----------------------------------------------------------------------------------------
mname = tnames('*'+tbname[0]+'*')
IF (mname[0] EQ '' AND NOT KEYWORD_SET(g_magf)) THEN BEGIN
  MESSAGE,'No magnetic field data has been loaded...',/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Keep data within time range and calculate moments
;-----------------------------------------------------------------------------------------
good_ph  = WHERE(ph_times  GE tr3[0] AND ph_times  LE tr3[1],gdph )
good_phb = WHERE(phb_times GE tr3[0] AND phb_times LE tr3[1],gdphb)
IF (gdph  GT 0) THEN BEGIN
  IF NOT KEYWORD_SET(noload) THEN BEGIN
    aph   = aphd.DATA[good_ph]
  ENDIF ELSE BEGIN
    aph   = aph[good_ph]
  ENDELSE
  pesa_high_bad_bins,aph
  teph  = dat_3dp_energy_bins(aph[0])
  aener = teph.ALL_ENERGIES
  ; => Fill energy bins with correct values and change NaN data to zeros
  FOR j=0L, gdph - 1L DO BEGIN
    temp        = aph[j]
    nbins       = temp.NBINS
    tener       = REFORM(aener # REPLICATE(1e0,nbins))
    temp.ENERGY = tener
    test        = (FINITE(temp.DATA) EQ 0)
    bad         = WHERE(test,bd)
    IF (bd GT 0) THEN bind = ARRAY_INDICES(temp.DATA,bad) ELSE bind = 0
    sb          = SIZE(bind,/N_DIMENSIONS) EQ 2L
    IF (sb) THEN temp.DATA[bind[0,*],bind[1,*]] = 0e0
    aph[j]      = temp
  ENDFOR
  ; => Calculate Moments for Pesa High
  sform  = mom3d()
  str_element,sform,'END_TIME',0d0,/ADD_REPLACE
  a_mom  = REPLICATE(sform,gdph)
  FOR j=0L, gdph - 1L DO BEGIN
    dat      = aph[j]
    temp     = mom3d(dat,FORMAT=str_format)
    str_element,temp,'END_TIME',dat.END_TIME,/ADD_REPLACE
    a_mom[j] = temp
  ENDFOR
ENDIF
IF (gdphb GT 0) THEN BEGIN
  IF NOT KEYWORD_SET(noload) THEN BEGIN
    aphb   = aphbd.DATA[good_phb]
  ENDIF ELSE BEGIN
    aphb   = aphb[good_phb]
  ENDELSE
  pesa_high_bad_bins,aph
  teph  = dat_3dp_energy_bins(aphb[0])
  aener = teph.ALL_ENERGIES
  ; => Fill energy bins with correct values and change NaN data to zeros
  FOR j=0L, gdphb - 1L DO BEGIN
    temp        = aphb[j]
    nbins       = temp.NBINS
    tener       = REFORM(aener # REPLICATE(1e0,nbins))
    temp.ENERGY = tener
    test        = (FINITE(temp.DATA) EQ 0)
    bad         = WHERE(test,bd)
    IF (bd GT 0) THEN bind = ARRAY_INDICES(temp.DATA,bad) ELSE bind = 0
    sb          = SIZE(bind,/N_DIMENSIONS) EQ 2L
    IF (sb) THEN temp.DATA[bind[0,*],bind[1,*]] = 0e0
    aphb[j]     = temp
  ENDFOR
  ; => Calculate Moments for Pesa High Burst
  sform  = mom3d()
  str_element,sform,'END_TIME',0d0,/ADD_REPLACE
  a_momb = REPLICATE(sform,gdphb)
  FOR j=0L, gdphb - 1L DO BEGIN
    dat       = aphb[j]
    temp      = mom3d(dat,FORMAT=str_format)
    str_element,temp,'END_TIME',dat.END_TIME,/ADD_REPLACE
    a_momb[j] = temp
  ENDFOR
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for data
;-----------------------------------------------------------------------------------------
aph_type  = SIZE(a_mom,/TYPE) EQ 8
aphb_type = SIZE(a_momb,/TYPE) EQ 8
test0     = (aph_type AND aphb_type)
test1     = (aph_type OR  aphb_type)
ttest     = TOTAL([test0,test1],/NAN)
gtest     = WHERE([aph_type,aphb_type],gdt)
CASE ttest[0] OF
  2L   : BEGIN
  ; => Both PH and PHB structures had moments calculated
    atimes    = [a_mom.TIME,a_momb.TIME]
    avgtemp   = [a_mom.AVGTEMP,a_momb.AVGTEMP]
    v_therm   = [a_mom.VTHERMAL,a_momb.VTHERMAL]
    tempvec   = [TRANSPOSE(a_mom.MAGT3),TRANSPOSE(a_momb.MAGT3)]
    velocity  = [TRANSPOSE(a_mom.VELOCITY),TRANSPOSE(a_momb.VELOCITY)]
    density   = [a_mom.DENSITY,a_momb.DENSITY]
  END
  1L   : BEGIN
  ; => Either PH or PHB structures had moments calculated
    IF (gtest[0] EQ 0L) THEN BEGIN
      ; => PH structures had moments calculated
      atimes    = a_mom.TIME
      avgtemp   = a_mom.AVGTEMP
      v_therm   = a_mom.VTHERMAL
      tempvec   = TRANSPOSE(a_mom.MAGT3)
      velocity  = TRANSPOSE(a_mom.VELOCITY)
      density   = a_mom.DENSITY
    ENDIF ELSE BEGIN
      ; => PHB structures had moments calculated
      atimes    = a_momb.TIME
      avgtemp   = a_momb.AVGTEMP
      v_therm   = a_momb.VTHERMAL
      tempvec   = TRANSPOSE(a_momb.MAGT3)
      velocity  = TRANSPOSE(a_momb.VELOCITY)
      density   = a_momb.DENSITY
    ENDELSE
  END
  ELSE : BEGIN
  ; => Neither PH nor PHB structures had moments calculated
    errmsg = 'No moments were calculated'
    MESSAGE,errmsg,/INFORMATIONAL,/CONTINUE
    RETURN
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Sort and organize data
;-----------------------------------------------------------------------------------------
sp        = SORT(atimes)
atimes    = atimes[sp]           ; => Unix times at start of structures
avgtemp   = avgtemp[sp]          ; => Avg. Temp (eV)
v_therm   = v_therm[sp]          ; => Thermal Speed (km/s)
tempvec   = tempvec[sp,*]        ; => [N,3]-Element array of FAC Temperature vectors (eV)
velocity  = velocity[sp,*]       ; => " " velocities (km/s)
density   = density[sp]          ; => Density [cm^(-3)]
; => Calculate the parallel and perpendicular temps and temp anisotropy
t_perp    = 5e-1*(tempvec[*,0] + tempvec[*,1])
t_para    = REFORM(tempvec[*,2])
tanis     = t_perp/t_para
;-----------------------------------------------------------------------------------------
; => Interpolate gaps in ion moments
;-----------------------------------------------------------------------------------------
x      = LINDGEN(N_ELEMENTS(atimes))
gtip   = WHERE(FINITE(atimes),gtp)
tip    = interp(atimes[gtip],x[gtip],x)
bdens2 = WHERE(density LE 0.0 OR FINITE(density) EQ 0,bdn,COMPLEMENT=gdens2)
IF (bdn GT 0L) THEN BEGIN
  avgtemp   = interp(avgtemp[gdens2],tip[gdens2],tip,/NO_EXTRAP)
  v_therm   = interp(v_therm[gdens2],tip[gdens2],tip,/NO_EXTRAP)
  tempx     = interp(tempvec[gdens2,0],tip[gdens2],tip,/NO_EXTRAP)
  tempy     = interp(tempvec[gdens2,1],tip[gdens2],tip,/NO_EXTRAP)
  tempz     = interp(tempvec[gdens2,2],tip[gdens2],tip,/NO_EXTRAP)
  tempvec   = [[tempx],[tempy],[tempz]]
  tempx     = interp(velocity[gdens2,0],tip[gdens2],tip,/NO_EXTRAP)
  tempy     = interp(velocity[gdens2,1],tip[gdens2],tip,/NO_EXTRAP)
  tempz     = interp(velocity[gdens2,2],tip[gdens2],tip,/NO_EXTRAP)
  velocity  = [[tempx],[tempy],[tempz]]
  density   = interp(density[gdens2],tip[gdens2],tip,/NO_EXTRAP)
  t_perp    = interp(t_perp[gdens2],tip[gdens2],tip,/NO_EXTRAP)
  t_para    = interp(t_para[gdens2],tip[gdens2],tip,/NO_EXTRAP)
  tanis     = interp(tanis[gdens2],tip[gdens2],tip,/NO_EXTRAP)
ENDIF
vmag = SQRT(TOTAL(velocity^2,2L,/NAN))
;-----------------------------------------------------------------------------------------
; => Send initial data to TPLOT
;-----------------------------------------------------------------------------------------
store_data,'N_ph',DATA={X:tip,Y:density}
store_data,'Tavg_ph',DATA={X:tip,Y:avgtemp}
store_data,'VTh_ph',DATA={X:tip,Y:v_therm}
store_data,'Vel_ph',DATA={X:tip,Y:velocity}
store_data,'Vmag_ph',DATA={X:tip,Y:vmag}
store_data,'PH_MAGT3',DATA={X:tip,Y:tempvec}
store_data,'Ti_perp_ph',DATA={X:tip,Y:t_perp}
store_data,'Ti_para_ph',DATA={X:tip,Y:t_para}
store_data,'Ti_anisotropy_ph',DATA={X:tip,Y:tanis}

options,'Tavg_ph','YTITLE','T!Di!N [PH] (eV)'
options,'VTh_ph','YTITLE','V!DTi!N (km/s)'
options,'N_ph','YTITLE','N!Di!N [PH] (cm!U-3!N)'
options,'Vel_ph','YTITLE','Velocity [PH] (km/s)'
options,'Vmag_ph','YTITLE','|V| [PH] (km/s)'
options,'PH_MAGT3','LABELS',$
         ['T!D'+'!9x!3'+'!N'+'!D1!N','T!D'+'!9x!3'+'!N'+'!D2!N','T!D'+'!9#!3'+'!N']
options,'PH_MAGT3','YTITLE','T!Di!N [PH] (eV)'
options,'Ti_perp_ph','YTITLE','T!Di'+'!9x!3'+'!N (eV) [PH]'
options,'Ti_para_ph','YTITLE','T!Di'+'!9#!3'+'!N (eV) [PH]'
options,'Ti_anisotropy_ph','YTITLE','T!Di'+'!9x!3'+'!N/T!Di'+'!9#!3'+'!N [PH]'

options,['Vel_ph','PH_MAGT3'],'COLORS',[250,150,50]
nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04

RETURN
END