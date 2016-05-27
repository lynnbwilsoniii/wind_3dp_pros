;+
;*****************************************************************************************
;
;  FUNCTION :   pesa_low_moment_calibrate.pro
;  PURPOSE  :   This program calls the ion moments from the PESA Low detector on the
;                 Wind spacecrafts 3DP instrument.  The data is interpolated to
;                 eliminate data gaps and if near a shock, the downstream can be
;                 re-calibrated according to the "known" compression ratio determined
;                 by J.C. Kasper or by examination of the plasma line from WAVES.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               get_pl.pro
;               get_plb.pro
;               tnames.pro
;               moments_3d.pro
;               get_moment3d.pro
;               store_data.pro
;               get_data.pro
;               interp.pro
;               sc_pot.pro
;
;  REQUIRES:    
;               LOAD_3DP_DATA must be ran first or user must supply 3DP data structures
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               RESTORE,mfile[0]
;               date = '040396'
;               pesa_low_moment_calibrate,DATE=date,/NOLOAD,PLM=apl,PLBM=aplb
;               **[Note:  apl and aplb were in the IDL save file, mfile[0] ]**
;
;  KEYWORDS:    
;               DATE      :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               TRANGE    :  [Double] 2-Element array specifying the time range over 
;                              which to get data structures for [Unix time]
;               NOLOAD    :  If set, program does not attempt to call the program
;                              get_moment3d.pro because it assumes you've already
;                              loaded the relevant ion data.  [use on iMac]
;               PLM       :  N-Element array of Pesa Low 3DP moment structures.  
;                              This keyword is intended to be used in association 
;                              with the NOLOAD keyword specifically for users with
;                              IDL save files on a non-SunMachine computer.
;               PLBM      :  N-Element array of Pesa Low Burst 3DP moment structures.
;                              This keyword is intended to be used in association 
;                              with the NOLOAD keyword specifically for users with
;                              IDL save files on a non-SunMachine computer.
;               COMPRESS  :  Scalar defining the shock compression ratio if the desired
;                              data is in/around a shock => used to calibrate ion
;                              ion density and SC potential
;               MIDRA     :  If COMPRESS is set, set to a scalar defining the Unix
;                              time associated with the middle of the shock ramp
;                              to differentiate between upstream and downstream
;                              [Default = middle of ion moment time range]
;               G_MAGF    :  If set, tells program that the structures in PLM or PLBM
;                              already have the magnetic field added to them thus 
;                              preventing this program from calling add_magf2.pro 
;                              again.
;               BNAME     :  Scalar string defining the TPLOT name of the B-field
;                              times you wish to interpolate the positions to
;                              [Default = 'wi_B3(GSE)']
;               SUFFX     :  Scalar string to differentiate TPLOT handles if program
;                              called multiple times
;
;   CHANGED:  1)  Renamed and updated man page                    [08/05/2009   v2.0.0]
;             2)  Changed some minor syntax                       [08/26/2009   v2.0.1]
;             3)  Fixed syntax error                              [08/28/2009   v2.0.2]
;             4)  Fixed a possible issue                          [09/09/2009   v2.0.3]
;             5)  Fixed syntax error with indexing when TRANGE is not set
;                                                                 [09/14/2009   v2.0.4]
;             6)  Added keyword:  G_MAGF                          [09/23/2009   v2.0.5]
;             7)  Changed SC Pot calibration for 02/11/2000       [12/02/2009   v2.0.6]
;             8)  Changed SC Pot calibration for 04/30/1998 and 05/15/1998
;                                                                 [03/07/2010   v2.1.0]
;             9)  Changed color assignments on vector quantities  [04/27/2010   v2.1.1]
;            10)  Added keyword:  BNAME                           [04/16/2011   v2.1.2]
;            11)  Fixed typo in BNAME default                     [05/05/2011   v2.1.3]
;            12)  Added keyword:  SUFFX and changed some TPLOT handles on output
;                                                                 [10/11/2011   v2.1.4]
;
;   CREATED:  08/05/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/11/2011   v2.1.4
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO pesa_low_moment_calibrate,DATE=date,TRANGE=trange,NOLOAD=noload,$
                              PLM=plm,PLBM=plbm,COMPRESS=compress,  $
                              MIDRA=midra,G_MAGF=g_magf,BNAME=bname,$
                              SUFFX=suffx

;-----------------------------------------------------------------------------------------
; -Define dummy variables
;-----------------------------------------------------------------------------------------
f         = !VALUES.F_NAN
d         = !VALUES.D_NAN
IF KEYWORD_SET(bname) THEN tbname = bname[0] ELSE tbname = 'wi_B3(GSE)'
IF KEYWORD_SET(suffx) THEN xsuff  = suffx[0] ELSE xsuff  = ''
;-----------------------------------------------------------------------------------------
; -Get Date associated with files of interest
;-----------------------------------------------------------------------------------------
mydate  = my_str_date(DATE=date)
date    = mydate.S_DATE[0]  ; -('MMDDYY')
mdate   = mydate.DATE[0]    ; -('YYYYMMDD')
tdate   = mydate.TDATE[0]   ; -['YYYY-MM-DD']
;-----------------------------------------------------------------------------------------
; -First check for ion moments
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(noload) THEN BEGIN
  pl_times  = get_pl(/TIMES)
  plb_times = get_plb(/TIMES)
  npl       = N_ELEMENTS(pl_times)
  nplb      = N_ELEMENTS(plb_times)
ENDIF ELSE BEGIN
  pltype  = SIZE(plm,/TYPE)
  plbtype = SIZE(plbm,/TYPE)
  IF (NOT KEYWORD_SET(plm) OR pltype NE 8L) THEN BEGIN
    pl_times  = 0d0
    npl       = 0L
  ENDIF ELSE BEGIN
    pl_times  = REFORM(plm.TIME)
    npl       = N_ELEMENTS(plm)
  ENDELSE
  IF (NOT KEYWORD_SET(plbm) OR plbtype NE 8L) THEN BEGIN
    plb_times  = 0d0
    nplb       = 0L
  ENDIF ELSE BEGIN
    plb_times  = REFORM(plbm.TIME)
    nplb       = N_ELEMENTS(plbm)
  ENDELSE
ENDELSE
; => Make sure something was found or sent to program
IF (pl_times[0] EQ 0d0)  THEN g_l = 0L  ELSE g_l  = N_ELEMENTS(pl_times)
IF (plb_times[0] EQ 0d0) THEN g_lb = 0L ELSE g_lb = N_ELEMENTS(plb_times)
IF (g_l EQ 0L AND g_lb EQ 0L) THEN BEGIN
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
; => Look at time range
;-----------------------------------------------------------------------------------------
mytags = ['t0','t1','t2','t3','t4','t5','t6','t7','t8','t9','t10']
pl_str = CREATE_STRUCT(mytags[0:1],pl_times,plb_times)
IF KEYWORD_SET(trange) THEN BEGIN
  tr3 = trange
  IF (g_l GT 0L OR g_lb GT 0L) THEN BEGIN
    IF (g_l GT 0L) THEN BEGIN
      g_pl  = WHERE(pl_times LE MAX(tr3,/NAN) AND pl_times GE MIN(tr3,/NAN),g_l)
      IF (g_l GT 0) THEN BEGIN
        pl_times = pl_times[g_pl]
        npl      = g_l
      ENDIF ELSE BEGIN
        pl_times  = 0d0
        npl       = 0L
      ENDELSE
    ENDIF ELSE BEGIN
      g_l  = 0L
      npl  = 0L
    ENDELSE
    IF (g_lb GT 0L) THEN BEGIN
      g_plb  = WHERE(plb_times LE MAX(tr3,/NAN) AND plb_times GE MIN(tr3,/NAN),g_lb)
      IF (g_lb GT 0) THEN BEGIN
        plb_times = plb_times[g_plb]
        nplb      = g_lb
      ENDIF ELSE BEGIN
        plb_times  = 0d0
        nplb       = 0L
      ENDELSE
    ENDIF ELSE BEGIN
      g_lb  = 0L
      nplb  = g_lb
    ENDELSE
  ENDIF ELSE BEGIN
    g_l   = 0L
    g_lb  = 0L
    npl   = g_l
    nplb  = g_lb
  ENDELSE
ENDIF ELSE BEGIN
  IF (g_l GT 0L AND g_lb GT 0L) THEN BEGIN  ; -Both are > 0
    tr3   = [MIN([pl_times,plb_times],/NAN),MAX([pl_times,plb_times],/NAN)]
    g_pl  = LINDGEN(g_l)
    g_plb = LINDGEN(g_lb)
  ENDIF ELSE BEGIN  ; -At least one of them must be > 0
    check = WHERE([g_l,g_lb] GT 0L,ch)
    CASE ch OF
      1L   : BEGIN
        tr3   = [MIN(pl_str.(check[0]),/NAN),MAX(pl_str.(check[0]),/NAN)]
        IF (check[0] EQ 0L) THEN BEGIN
          g_pl   = LINDGEN(g_l)
          g_plb  = -1
        ENDIF ELSE BEGIN
          g_pl   = -1
          g_plb  = LINDGEN(g_lb)
        ENDELSE
      END
      2L   : BEGIN
        tr_max = MAX([pl_str.(check[0]),pl_str.(check[1])],/NAN)
        tr_min = MIN([pl_str.(check[0]),pl_str.(check[1])],/NAN)
        tr3    = [tr_min,tr_max]
        g_pl   = LINDGEN(g_l)
        g_plb  = LINDGEN(g_lb)
      END
      ELSE : BEGIN
        MESSAGE,'No ion moments were found...',/INFORMATIONAL,/CONTINUE
        RETURN
      END
    ENDCASE
  ENDELSE
ENDELSE
pl_str = CREATE_STRUCT(mytags[0:1],pl_times,plb_times)
;-----------------------------------------------------------------------------------------
; -Calculate distribution function moments for PL and PLB and send them to TPLOT
;-----------------------------------------------------------------------------------------
comment    = 'Full energy range'
dens_n     = 0.
comp       = 1
str_format = moments_3d()
IF (npl GT 0L AND KEYWORD_SET(noload)) THEN BEGIN
  name = 'pl'
  dfpl = REPLICATE(str_format,npl)
  plm  = plm[g_pl]
  FOR n=0L, npl - 1L DO BEGIN
    dat     = plm[n]
    temp    = moments_3d(dat,FORMAT=str_format,TRUE_DENS=dens_n,COMP=comp)
    dfpl[n] = temp
  ENDFOR
  store_data,name,DATA=dfpl,DLIM={COMMENT:comment}
ENDIF

IF (nplb GT 0L AND KEYWORD_SET(noload)) THEN BEGIN
  name  = 'plb'
  dfplb = REPLICATE(str_format,nplb)
  plbm  = plbm[g_plb]
  FOR n=0L, nplb - 1L DO BEGIN
    dat      = plbm[n]
    temp     = moments_3d(dat,FORMAT=str_format,TRUE_DENS=dens_n,COMP=comp)
    dfplb[n] = temp
  ENDFOR
  store_data,name,DATA=dfplb,DLIM={COMMENT:comment}
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for ion moments in case user did not supply them
;-----------------------------------------------------------------------------------------
IF (g_l GT 0L ) THEN pl_l  = 1 ELSE pl_l  = 0   ; -Logic:  1 if Pesa Low data available
IF (g_lb GT 0L) THEN plb_l = 1 ELSE plb_l = 0   ; -Logic:  1 if Pesa Low Burst data available
check = WHERE([pl_l,plb_l] GT 0L,gch)
names = ['pl','plb']

plnames  = tnames("pl.*")
plbnames = tnames("plb.*")
log_pln  = (plnames[0] EQ '')
log_plbn = (plbnames[0] EQ '')

IF (NOT KEYWORD_SET(noload)) THEN BEGIN
  IF (log_pln OR log_plbn) THEN BEGIN      ; => no TPLOT ion moments saved yet
    CASE gch OF
      1    : BEGIN  ; -Only one is available (either PL or PLB)
        get_moment3d,names[check[0]],MAG_NAME=mname[0],NAME=names[check[0]],TRANGE=tr3
      END
      2    : BEGIN  ; -Both are available
        get_moment3d,names[0],MAG_NAME=mname[0],NAME=names[0],TRANGE=tr3
        get_moment3d,names[1],MAG_NAME=mname[0],NAME=names[1],TRANGE=tr3
      END
      ELSE : BEGIN  ; -Not sure how you got here without breaking the program before...
        MESSAGE,'No ion moments were found...',/INFORMATIONAL,/CONTINUE
        RETURN
      END
    ENDCASE
  ENDIF
ENDIF ELSE BEGIN                                            ; => NOLOAD is set
  IF (log_pln AND log_plbn) THEN BEGIN  ; => You lied!
    MESSAGE,'No ion moments were pre-loaded...',/INFORMATIONAL,/CONTINUE
    CASE gch OF
      1    : BEGIN  ; -Only one is available (either PL or PLB)
        get_moment3d,names[check[0]],MAG_NAME=mname[0],NAME=names[check[0]],TRANGE=tr3
      END
      2    : BEGIN  ; -Both are available
        get_moment3d,names[0],MAG_NAME=mname[0],NAME=names[0],TRANGE=tr3
        get_moment3d,names[1],MAG_NAME=mname[0],NAME=names[1],TRANGE=tr3
      END
      ELSE : BEGIN  ; -Not sure how you got here without breaking the program before...
        MESSAGE,'No ion moments were found...',/INFORMATIONAL,/CONTINUE
        RETURN
      END
    ENDCASE
  ENDIF
ENDELSE

plnames  = tnames('pl.*')
plbnames = tnames('plb.*')
IF (plnames[0] NE '')  THEN store_data,DELETE=plnames
IF (plbnames[0] NE '') THEN store_data,DELETE=plbnames
;-----------------------------------------------------------------------------------------
; => Fix ion moments
;-----------------------------------------------------------------------------------------
ion_names = tnames('pl*')
IF (ion_names[0] NE '') THEN BEGIN
  nnam = N_ELEMENTS(ion_names)
  CASE nnam OF
    1    : BEGIN  ; -Only one is available (either PL or PLB)
      get_data,ion_names[0],DATA=ion1
      tpl     = ion1.TIME    ; => Unix times associated with each moment
      nnpl    = N_ELEMENTS(tpl)
      nipl    = ion1.DENSITY   ; => Ion Density (cm^-3)
      vswpl   = ion1.VELOCITY  ; => Solar Wind Velocity (or ion bulk flow) [km/s]
      vthp    = ion1.VTHERMAL  ; => Thermal Speed (km/s)
      avtemp  = ion1.AVGTEMP   ; => Average Temp (eV)
      tempt3  = ion1.MAGT3     ; => Vector Temp (eV) [x = perp1, y = perp2, z = para]
      plflux  = ion1.FLUX      ; => Flux (# s^-1 cm^-2)
      tip     = REPLICATE(d,nnpl)
      niplb   = REPLICATE(f,nnpl)
      vswplb  = REPLICATE(f,nnpl)
      vthpr   = REPLICATE(f,nnpl)
      avtempb = REPLICATE(f,nnpl)
      tempbt3 = REPLICATE(f,nnpl)
      plbflux = REPLICATE(f,nnpl)
      al_tpl  = tpl
      al_temp = avtemp
      al_vsw  = vswpl
      al_dens = nipl
      al_vthe = vthp
      al_plT3 = tempt3
      al_plfl = plflux
    END
    2    : BEGIN  ; -Both are available (either PL or PLB)
      get_data,ion_names[0],DATA=ion1
      get_data,ion_names[1],DATA=ion2
      tpl     = ion1.TIME    ; => Unix times associated with each moment
      nnpl    = N_ELEMENTS(tpl)
      nipl    = ion1.DENSITY   ; => Ion Density (cm^-3)
      vswpl   = ion1.VELOCITY  ; => Solar Wind Velocity (or ion bulk flow) [km/s] [GSE]
      vthp    = ion1.VTHERMAL  ; => Thermal Speed (km/s)
      avtemp  = ion1.AVGTEMP   ; => Average Temp (eV)
      tempt3  = ion1.MAGT3     ; => Vector Temp (eV) [x = perp1, y = perp2, z = para]
      plflux  = ion1.FLUX      ; => Flux (# s^-1 cm^-2) [GSE]
      tip     = ion2.TIME      ; => Unix times associated with each moment
      nnplb   = N_ELEMENTS(tip)
      niplb   = ion2.DENSITY   ; => Ion Density (cm^-3)
      vswplb  = ion2.VELOCITY  ; => Solar Wind Velocity (or ion bulk flow) [km/s] [GSE]
      vthpr   = ion2.VTHERMAL  ; => Thermal Speed (km/s)
      avtempb = ion2.AVGTEMP   ; => Average Temp (eV)
      tempbt3 = ion2.MAGT3     ; => Vector Temp (eV) [x = perp1, y = perp2, z = para]
      plbflux = ion2.FLUX      ; => Flux (# s^-1 cm^-2) [GSE]
      al_tpl  = [tip,tpl]      ; Burst then regular PESA Low
      al_temp = [avtempb,avtemp]
      al_vsw  = [vswplb,vswpl]
      al_dens = [niplb,nipl]
      al_vthe = [vthpr,vthp]
      al_plT3 = [tempbt3,tempt3]
      al_plfl = [plbflux,plflux]
    END
  ENDCASE
ENDIF ELSE BEGIN
  MESSAGE,'How in the hell did you manage this?',/INFORMATIONAL,/CONTINUE
  RETURN
ENDELSE
sp      = SORT(al_tpl)
tip1    = al_tpl[sp]      ; Unix times associated w/ each array
itemp   = al_temp[sp]     ; Average Ion temp (eV)
idens   = al_dens[sp]     ; Ion density (cc)
ivther  = al_vthe[sp]     ; Ion Thermal Velocity (km/s)
vsw     = al_vsw[sp,*]    ; Solar Wind (SW) velocity (km/s)
vmag    = SQRT(TOTAL(vsw^2,2,/NAN))
plMAGT3 = al_plT3[sp,*]   ; Ion vector temp (eV)  [x = perp1, y = perp2, z = para]
fluxpl  = al_plfl[sp,*]   ; Ion flux (# s^-1 cm^-2) [GSE]

x      = LINDGEN(N_ELEMENTS(vmag))
gtip   = WHERE(FINITE(tip1),gtp)
tip2   = interp(tip1[gtip],x[gtip],x)
bdens2 = WHERE(idens LE 0.0 OR FINITE(idens) EQ 0,bdn,COMPLEMENT=gdens2)
;-----------------------------------------------------------------------------------------
; => Interpolate gaps in ion moments
;-----------------------------------------------------------------------------------------
IF (bdn GT 0L) THEN BEGIN
  test2   = interp(idens[gdens2],tip2[gdens2],tip2,/NO_EXTRAP)
  idens2  = test2   ; -New ion density (cc)
  test2   = interp(ivther[gdens2],tip2[gdens2],tip2,/NO_EXTRAP)
  ivther2 = test2   ; -New ion thermal speed (km/s)
  test2   = interp(itemp[gdens2],tip2[gdens2],tip2,/NO_EXTRAP)
  itemp2  = test2   ; -New ion temp (eV)
  test2x  = interp(vsw[gdens2,0],tip2[gdens2],tip2,/NO_EXTRAP)
  test2y  = interp(vsw[gdens2,1],tip2[gdens2],tip2,/NO_EXTRAP)
  test2z  = interp(vsw[gdens2,2],tip2[gdens2],tip2,/NO_EXTRAP)
  vsw2    = [[test2x],[test2y],[test2z]]  ; -New SW Velocity (km/s) [GSE]
  test2x  = interp(plMAGT3[gdens2,0],tip2[gdens2],tip2,/NO_EXTRAP)
  test2y  = interp(plMAGT3[gdens2,1],tip2[gdens2],tip2,/NO_EXTRAP)
  test2z  = interp(plMAGT3[gdens2,2],tip2[gdens2],tip2,/NO_EXTRAP)
  plMAGT3 = [[test2x],[test2y],[test2z]]  ; -New Vector Temp (eV)  [x = perp1, y = perp2, z = para]
  test2x  = interp(fluxpl[gdens2,0],tip2[gdens2],tip2,/NO_EXTRAP)
  test2y  = interp(fluxpl[gdens2,1],tip2[gdens2],tip2,/NO_EXTRAP)
  test2z  = interp(fluxpl[gdens2,2],tip2[gdens2],tip2,/NO_EXTRAP)
  fluxpl  = [[test2x],[test2y],[test2z]]  ; -New Ion Flux (# s^-1 cm^-2) [GSE]
ENDIF ELSE BEGIN
  idens2  = idens
  ivther2 = ivther
  itemp2  = itemp
  vsw2    = vsw
ENDELSE
vmag2   = SQRT(TOTAL(vsw2^2,2,/NAN))
lvmag   = WHERE(vmag2 LE 0.0 OR FINITE(vmag2) EQ 0,lvm,COMPLEMENT=gvmag)
IF (lvm GT 0L) THEN BEGIN
  test2 = interp(vmag2[gvmag],tip2[gvmag],tip2,/NO_EXTRAP)
  vmag2 = test2   ; -New magnitude of SW Velocity (km/s)
ENDIF
tperpi  = 5e-1*(plMAGT3[*,0] + plMAGT3[*,1])  ; -Perpendicular Ion Temp (eV) [FA]
tparai  = REFORM(plMAGT3[*,2])                ; -Parallel Ion Temp (eV) [FA]
tani_i  = tperpi/tparai                       ; -Ion temperature anisotropy
;-----------------------------------------------------------------------------------------
; => Calculate spacecraft (SC) potential from initial ion dens.
;-----------------------------------------------------------------------------------------
phi2    = sc_pot(idens2)                      ; -SC Potential (eV)
x       = LINDGEN(N_ELEMENTS(phi2))
bphi2   = WHERE(phi2 LT 0.0 OR FINITE(phi2) EQ 0,bph2,COMPLEMENT=gphi2)
IF (bph2 GT 0L AND bph2 LT N_ELEMENTS(phi2)) THEN BEGIN
  test2 = interp(phi2[gphi2],tip2[gphi2],tip2,/NO_EXTRAP)
ENDIF ELSE BEGIN
  test2 = phi2
ENDELSE
sphi2 = test2
bphi4 = WHERE(sphi2 LT 0.0 OR FINITE(sphi2) EQ 0,bph4,COMPLEMENT=gphi4)
IF (bph4 GT 0L AND bph4 LT N_ELEMENTS(sphi2)) THEN BEGIN
  test2 = interp(sphi2[gphi4],tip2[gphi4],tip2)
  sphi2 = test2
ENDIF
;-----------------------------------------------------------------------------------------
; => Send initial data to TPLOT
;-----------------------------------------------------------------------------------------
store_data,'N_i2'+xsuff[0],DATA={X:tip2,Y:idens2}
store_data,'sc_pot_2'+xsuff[0],DATA={X:tip2,Y:sphi2}
store_data,'T_i2'+xsuff[0],DATA={X:tip2,Y:itemp2}
store_data,'V_Ti2'+xsuff[0],DATA={X:tip2,Y:ivther2}
store_data,'V_sw2'+xsuff[0],DATA={X:tip2,Y:vsw2}
store_data,'V_mag2'+xsuff[0],DATA={X:tip2,Y:vmag2}
store_data,'MAGT3'+xsuff[0],DATA={X:tip2,Y:plMAGT3}
store_data,'num_flux'+xsuff[0],DATA={X:tip2,Y:fluxpl}
store_data,'Ti_perp'+xsuff[0],DATA={X:tip2,Y:tperpi}
store_data,'Ti_para'+xsuff[0],DATA={X:tip2,Y:tparai}
store_data,'Ti_anisotropy'+xsuff[0],DATA={X:tip2,Y:tani_i}


options,'sc_pot_2'+xsuff[0],'YTITLE','SC Potential (eV)'
options,'T_i2'+xsuff[0],'YTITLE','T!Di!N [2] (eV)'
options,'V_Ti2'+xsuff[0],'YTITLE','V!DTi!N (km/s)'
options,'N_i2'+xsuff[0],'YTITLE','N!Di!N [2] (cm!U-3!N)'
options,'V_sw2'+xsuff[0],'YTITLE','V!Dsw!N [2] (km/s)'
options,'V_mag2'+xsuff[0],'YTITLE','|V!Dsw!N| [2] (km/s)'
options,'MAGT3'+xsuff[0],'LABELS',$
         ['T!D'+'!9x!3'+'!N'+'!D1!N','T!D'+'!9x!3'+'!N'+'!D2!N','T!D'+'!9#!3'+'!N']
options,'MAGT3'+xsuff[0],'YTITLE','T!Di!N [FA] (eV)'
options,'num_flux'+xsuff[0],'YTITLE','Ion Flux (# s!U-1!N cm!U-2!N)'
options,'Ti_perp'+xsuff[0],'YTITLE','T!Di'+'!9x!3'+'!N (eV) [FA]'
options,'Ti_para'+xsuff[0],'YTITLE','T!Di'+'!9#!3'+'!N (eV) [FA]'
options,'Ti_anisotropy'+xsuff[0],'YTITLE','T!Di'+'!9x!3'+'!N/T!Di'+'!9#!3'+'!N'

options,['V_sw2','MAGT3','num_flux']+xsuff[0],'COLORS',[250,150,50]
;-----------------------------------------------------------------------------------------
; => If near a shock, adjust downstream data [Ion moments are not accurate immediately
;    downstream of a collisionless shock due to turbulence and an inability to estimate
;    spacecraft potential, among other things.]
;-----------------------------------------------------------------------------------------
IF (NOT KEYWORD_SET(compress)) THEN BEGIN
  tura  = 0d0
  compr = 0d0
ENDIF ELSE BEGIN
  compr = compress[0]
  IF (NOT KEYWORD_SET(midra)) THEN BEGIN
    tura = (MAX(tip2,/NAN) + MIN(tip2,/NAN))/2d0
  ENDIF ELSE BEGIN
    tura = midra[0]
  ENDELSE
ENDELSE
;-----------------------------------------------------------------------------------------
; => Determine if downstream density and SC potential needs to be adjusted
;-----------------------------------------------------------------------------------------
IF (tura NE 0d0) THEN BEGIN
  plbu = WHERE(tip2 LE tura,plu)
  plbd = WHERE(tip2 GE tura,pld)
  IF (plu GT 0L AND pld GT 0L) THEN BEGIN   ; -Only "adjust" if data on both sides
    avgrad  = WHERE(tip2 LE tura + 6d2 AND tip2 GT tura + 6d1,avru)
    avgrau  = WHERE(tip2 GE tura - 6d2 AND tip2 LT tura - 6d1,avr)
    nip1u   = idens2[plbu]
    nip1d   = idens2[plbd]
    avdiu   = MEAN(idens2[avgrau],/NAN)  ; -Avg. Upstream ion density (cc)
    avdid   = MEAN(idens2[avgrad],/NAN)  ; -Avg. Downstream " "
    mycomp  = avdiu/avdid
    newavd  = mycomp*(compr < 4.)*avdid  ; -Renormalized downstream average
    newnidn = (nip1d - avdid) + newavd   ; -Redefine downstream ion density
    tip1u   = tip2[plbu]
    tip1d   = tip2[plbd]
    nipar_t = [nip1u,newnidn]            ; -New ion density estimate
    tipar   = [tip1u,tip1d]              ; -Unix times associated with nipar_t
    mynip_t = interp(nipar_t,tipar,tip2,/NO_EXTRAP)
    idens3  = mynip_t                    ; -Fixed/Calibrated Ion Density
    store_data,'N_i3'+xsuff[0],DATA={X:tip2,Y:idens3}
    options,'N_i3'+xsuff[0],'YTITLE','N!Di!N [3] (cm!U-3!N)'
    ; => Compute spacecraft potential (from new estimate)
    phi3    = sc_pot(idens3)
    x       = LINDGEN(N_ELEMENTS(phi3))
    bphi3   = WHERE(phi3 LT 0.0 OR FINITE(phi3) EQ 0,bph3,COMPLEMENT=gphi3)
    IF (bph3 GT 0L AND bph3 LT N_ELEMENTS(phi3)) THEN BEGIN
      test3  = interp(phi3[gphi3],tip2[gphi3],tip2,/NO_EXTRAP)
    ENDIF ELSE BEGIN
      test3  = phi3
    ENDELSE
    sphi3  = test3
    CASE date OF
      '040396' : BEGIN
        phiu_t = sphi3[plbu] + 4.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr + 1.0 ; => Shift SC potential higher
      END
      '040896' : BEGIN
        phiu_t = sphi3[plbu] + 4.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr       ; => Shift SC potential higher
      END
      '102497' : BEGIN
        phiu_t = sphi3[plbu] + 5.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr + 5.0 ; => Shift SC potential higher
      END
      '121097' : BEGIN
        phiu_t = sphi3[plbu] + 3.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr + 2.0 ; => Shift SC potential higher
      END
      '043098' : BEGIN
        phiu_t = sphi3[plbu] + 2.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr + 2.0 ; => Shift SC potential higher
      END
      '051598' : BEGIN
        phiu_t = sphi3[plbu] + 2.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr + 2.0 ; => Shift SC potential higher
      END
      '092498' : BEGIN
        phiu_t = sphi3[plbu] + 5.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr + 2.0 ; => Shift SC potential higher
      END
      '021100' : BEGIN
        phiu_t = sphi3[plbu] + 5.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr + 2.0 ; => Shift SC potential higher
      END
      '102101' : BEGIN
        phiu_t = sphi3[plbu] + 5.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr + 1.0 ; => Shift SC potential higher
      END
      '102501' : BEGIN
        phiu_t = sphi3[plbu] + 11.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr + 11.0 ; => Shift SC potential higher
      END
      '112401' : BEGIN
        phiu_t = sphi3[plbu] + 8.0       ; => Shift SC potential higher
        phid_t = sphi3[plbd]*compr + 5.0 ; => Shift SC potential higher
      END
      ELSE     : BEGIN
        phiu_t = sphi3[plbu]
        phid_t = sphi3[plbd]*compr       ; -Amplify downstream estimate
      END
    ENDCASE
    myphi3 = [phiu_t,phid_t]     ; -New SC Pot. estimate
    ; -Interpolate again to get back to original time step
    test3  = interp(myphi3,tipar,tip2,/NO_EXTRAP)
    sphi3  = test3
    bphi4  = WHERE(sphi3 LT 0.0 OR FINITE(sphi3) EQ 0,bph4,COMPLEMENT=gphi4)
    IF (bph4 GT 0L AND bph4 LT N_ELEMENTS(sphi3)) THEN BEGIN
      test3 = interp(sphi3[gphi4],tip2[gphi4],tip2)
      sphi3 = test3
    ENDIF
    store_data,'sc_pot_3'+xsuff[0],DATA={X:tip2,Y:sphi3}
    options,'sc_pot_3'+xsuff[0],'YTITLE','SC Potential (eV)'
  ENDIF
ENDIF
IF NOT KEYWORD_SET(trange) THEN trange = tr3
IF NOT KEYWORD_SET(date)   THEN date   = date
nnw = tnames()
options,nnw,'YSTYLE',1
options,nnw,'PANEL_SIZE',2.
options,nnw,'XMINOR',5
options,nnw,'XTICKLEN',0.04

RETURN
END