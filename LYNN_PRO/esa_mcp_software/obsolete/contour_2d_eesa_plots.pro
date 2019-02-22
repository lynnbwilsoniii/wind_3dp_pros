;+
;*****************************************************************************************
;
;  FUNCTION :   contour_2d_eesa_plots.pro
;  PURPOSE  :   This is a wrapping program for a number of other programs which
;                 allows the user to plot the distribution function (DF) both with
;                 and without assumed gyrotropy for the Eesa detector data.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               my_str_date.pro
;               get_el.pro
;               get_elb.pro
;               get_3dp_structs.pro
;               eesa_data_4.pro
;               moments_array_3dp.pro
;               eh_cont3d.pro
;               one_count_level.pro
;               cont2d.pro
;               interp.pro
;               my_time_string.pro
;
;  REQUIRES:    
;               UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               NA
;
;  KEYWORDS:    
;               DATE     :  [string] 'MMDDYY' [MM=month, DD=day, YY=year]
;               VLIM     :  Limit for x-y velocity axes over which to plot data
;                             [Default = max vel. from energy bin values (km/s)]
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 20L]
;               V_TH     :  If set, program will output of thermal velocity on plot
;               GNORM    :  If set, program will overplot the projection of the shock
;                             normal vector on the contour plot
;               HEAT_F   :  If set, program will overplot the projection of the 
;                             heat flux vector  on the contour plot
;               TRANGE   :  [Double] 2-Element array specifying the time range over 
;                              which to get data structures for [Unix time]
;               NOLOAD   :  If set, program does not attempt to call the programs
;                             get_??.pro because it assumes you've already
;                             loaded the relevant electron data.  [use on iMac]
;               ELM      :  N-Element array of Eesa Low 3DP moment structures.  
;                             This keyword is intended to be used in association 
;                             with the NOLOAD keyword specifically for users with
;                             IDL save files on a non-SunMachine computer.
;               ELBM     :  N-Element array of Eesa Low Burst 3DP moment structures.
;                             This keyword is intended to be used in association 
;                             with the NOLOAD keyword specifically for users with
;                             IDL save files on a non-SunMachine computer.
;               EL_DIR   :  Scalar string defining the directory where you want the 
;                             Eesa Low plots to be saved
;               ELB_DIR  :  Scalar string defining the directory where you want the 
;                             Eesa Low Burst plots to be saved
;
;   CHANGED:  1)  Added one count level outputs to eh_cont3d.pro plots
;                                                                  [10/14/2009   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  09/09/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  10/14/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO contour_2d_eesa_plots,DATE=date,NGRID=ngrid,VLIM=vlim,V_TH=v_th,GNORM=gnorm, $
                          HEAT_F=heat_f,TRANGE=trange,NOLOAD=noload,             $
                          ELM=elm,ELBM=elbm,EL_DIR=el_dir,ELB_DIR=elb_dir
;-----------------------------------------------------------------------------------------
; -Define dummy variables
;-----------------------------------------------------------------------------------------
f         = !VALUES.F_NAN
d         = !VALUES.D_NAN

IF NOT KEYWORD_SET(ngrid) THEN ngrid = 20L ; => # of levels to use for contour.pro
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*dat.ENERGY/dat.MASS),/NAN)  ; => velocity limit (km/s)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)  ; => velocity limit (km/s)
ENDELSE
;-----------------------------------------------------------------------------------------
; -Get Date associated with files of interest
;-----------------------------------------------------------------------------------------
mydate  = my_str_date(DATE=date)
date    = mydate.S_DATE[0]  ; -('MMDDYY')
mdate   = mydate.DATE[0]    ; -('YYYYMMDD')
tdate   = mydate.TDATE[0]   ; -['YYYY-MM-DD']
;-----------------------------------------------------------------------------------------
; -First check for electron moments
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(noload) THEN BEGIN
  eltype    = SIZE(elm,/TYPE)
  elbtype   = SIZE(elbm,/TYPE)
  IF (NOT KEYWORD_SET(elm) OR eltype NE 8L) THEN BEGIN
    el_times  = 0d0
    nel       = 0L
  ENDIF ELSE BEGIN
    el_times  = REFORM(elm.TIME)
    nel       = N_ELEMENTS(elm)
  ENDELSE
  IF (NOT KEYWORD_SET(elbm) OR elbtype NE 8L) THEN BEGIN
    elb_times  = 0d0
    nelb       = 0L
  ENDIF ELSE BEGIN
    elb_times  = REFORM(elbm.TIME)
    nelb       = N_ELEMENTS(elbm)
  ENDELSE
ENDIF ELSE BEGIN
  IF (!VERSION.OS_NAME EQ 'Mac OS X') THEN BEGIN
    mdir   = FILE_EXPAND_PATH('IDL_stuff/Wind_3DP_DATA/IDL_Save_Files/'+date)
    mfiles = FILE_SEARCH(mdir,'*.sav')
    gposi  = WHERE(STRPOS(mfiles,'Eesa_3DP_') GE 0L,gp)
    IF (gp GT 0) THEN RESTORE,mfiles[gposi] ELSE BEGIN
      MESSAGE,'No electron moments were found...',/INFORMATIONAL,/CONTINUE
      RETURN
    ENDELSE
    el_times  = REFORM(ael.TIME)
    elb_times = REFORM(aelb.TIME)
    nel       = N_ELEMENTS(el_times)
    nelb      = N_ELEMENTS(elb_times)
  ENDIF ELSE BEGIN
    el_times  = get_el(/TIMES)
    elb_times = get_elb(/TIMES)
    nel       = N_ELEMENTS(el_times)
    nelb      = N_ELEMENTS(elb_times)
  ENDELSE
ENDELSE
; => Make sure something was found or sent to program
IF (el_times[0] EQ 0d0)  THEN g_l = 0L  ELSE g_l  = N_ELEMENTS(el_times)
IF (elb_times[0] EQ 0d0) THEN g_lb = 0L ELSE g_lb = N_ELEMENTS(elb_times)
IF (g_l EQ 0L AND g_lb EQ 0L) THEN BEGIN
  MESSAGE,'No electron moments were found...',/INFORMATIONAL,/CONTINUE
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Check for electron moments in case user did not supply them
;-----------------------------------------------------------------------------------------
IF (g_l GT 0L ) THEN el_l  = 1 ELSE el_l  = 0   ; -Logic:  1 if Eesa Low data available
IF (g_lb GT 0L) THEN elb_l = 1 ELSE elb_l = 0   ; -Logic:  1 if Eesa Low Burst data available
check = WHERE([el_l,elb_l] GT 0L,gch)
names = ['el','elb']

IF (NOT KEYWORD_SET(noload)) THEN BEGIN
  IF (!VERSION.OS_NAME NE 'Mac OS X') THEN BEGIN
    IF (nel GT 0L) THEN BEGIN
      eldat     = get_3dp_structs(names[0],TRANGE=tr3)
      ael       = eldat.DATA
      el_times  = ael.TIME
    ENDIF
    IF (nelb GT 0L) THEN BEGIN
      elbdat    = get_3dp_structs(names[1],TRANGE=tr3)
      aelb      = elbdat.DATA
      elb_times = ael.TIME
    ENDIF
  ENDIF
ENDIF ELSE BEGIN                                            ; => NOLOAD is set
  IF (eltype EQ 8)  THEN ael  = elm   ELSE ael  = 0
  IF (elbtype EQ 8) THEN aelb = elbm  ELSE aelb = 0
ENDELSE
;-----------------------------------------------------------------------------------------
; => Look at time range
;-----------------------------------------------------------------------------------------
mytags = ['t0','t1','t2','t3','t4','t5','t6','t7','t8','t9','t10']
pl_str = CREATE_STRUCT(mytags[0:1],el_times,elb_times)
IF KEYWORD_SET(trange) THEN BEGIN
  tr3 = trange
ENDIF ELSE BEGIN
  IF (g_l GT 0L AND g_lb GT 0L) THEN BEGIN  ; -Both are > 0
    tr3 = [MIN([el_times,elb_times],/NAN),MAX([el_times,elb_times],/NAN)]
  ENDIF ELSE BEGIN  ; -At least one of them must be > 0
    check = WHERE([g_l,g_lb] GT 0L,ch)
    CASE ch OF
      1L   : BEGIN
        tr3   = [MIN(pl_str.(check[0]),/NAN),MAX(pl_str.(check[0]),/NAN)]
      END
      2L   : BEGIN
        tr_max = MAX([pl_str.(check[0]),pl_str.(check[1])],/NAN)
        tr_min = MIN([pl_str.(check[0]),pl_str.(check[1])],/NAN)
        tr3    = [tr_min,tr_max]
      END
      ELSE : BEGIN
        MESSAGE,'No electron moments were found...',/INFORMATIONAL,/CONTINUE
        RETURN
      END
    ENDCASE
  ENDELSE
ENDELSE
pl_str = CREATE_STRUCT(mytags[0:1],el_times,elb_times)
;-----------------------------------------------------------------------------------------
; => Find good elements of data
;-----------------------------------------------------------------------------------------
IF (nel GT 0L) THEN BEGIN
  g_el  = WHERE(el_times LE MAX(tr3,/NAN) AND el_times GE MIN(tr3,/NAN),g_l)
  IF (g_l GT 0L ) THEN el_l  = 1 ELSE el_l  = 0   ; -Logic:  1 if Eesa Low data available
ENDIF ELSE BEGIN
  el_l = 0
  g_el = -1
  g_l  = 0
ENDELSE

IF (nelb GT 0L) THEN BEGIN
  g_elb  = WHERE(elb_times LE MAX(tr3,/NAN) AND elb_times GE MIN(tr3,/NAN),g_lb)
  IF (g_lb GT 0L ) THEN elb_l  = 1 ELSE elb_l  = 0   ; -Logic:  1 if Eesa Low data available
ENDIF ELSE BEGIN
  elb_l = 0
  g_elb = -1
  g_lb  = 0
ENDELSE

IF (el_l) THEN BEGIN
  ael      = ael[g_el]
  el_times = ael.TIME
  nel      = g_l
ENDIF ELSE BEGIN
  ael      = 0
  el_times = 0d0
  nel      = 0L
ENDELSE

IF (elb_l) THEN BEGIN
  aelb      = aelb[g_elb]
  elb_times = aelb.TIME
  nelb      = g_lb
ENDIF ELSE BEGIN
  aelb      = 0
  elb_times = 0d0
  nelb      = 0L
ENDELSE
;-----------------------------------------------------------------------------------------
; => Look at Electron moments in SW frame
;-----------------------------------------------------------------------------------------
IF (el_l) THEN BEGIN
  ; => Convert to SW frame
  test     = eesa_data_4(ael,NUM_PA=24L) 
  my_delb  = test.MOMENTS
  my_pdb   = test.PADS
ENDIF

IF (elb_l) THEN BEGIN
  ; => Convert to SW frame
  test     = eesa_data_4(aelb,NUM_PA=24L) 
  myb_delb = test.MOMENTS
  myb_pdb  = test.PADS
ENDIF

moments_array_3dp,PLM=my_delb,PLBM=myb_delb,AVGTEMP=avtempe,T_PERP=tperp_e,$
                  T_PARA=tpara_e,V_THERM=vtherme,VELOCITY=elb_vels,$
                  PRESSURE=press_e,MOMS=moms,SUFFX='el'
atimes   = moms.TIME
tanis_e  = tperp_e/tpara_e
;-----------------------------------------------------------------------------------------
; => Plot DFs
;-----------------------------------------------------------------------------------------
IF (NOT KEYWORD_SET(el_dir)) THEN BEGIN
  pldir = FILE_EXPAND_PATH('') 
ENDIF ELSE pldir = FILE_EXPAND_PATH(el_dir[0])+'/'

IF (NOT KEYWORD_SET(elb_dir)) THEN BEGIN
  plbdir = FILE_EXPAND_PATH('') 
ENDIF ELSE plbdir = FILE_EXPAND_PATH(elb_dir[0])+'/'


ngrid    = 30
vlim     = 2d4
vout     = (DINDGEN(2L*ngrid + 1L)/ngrid - 1L) * vlim
suffx3d  = '_3D-30Grids-All-Energies_e-frame-DF'
suffx2d  = '_24PAs-30Grids-All-Energies_e-frame-DF_w-One-Count'

; => EL DFs
IF (el_l) THEN BEGIN
  el_tani = interp(tanis_e,atimes,el_times,/NO_EXTRAP)
  IF (NOT KEYWORD_SET(v_th)) THEN BEGIN
    vther = REPLICATE(0,nel)
  ENDIF ELSE BEGIN
    vther = interp(vtherme,atimes,el_times,/NO_EXTRAP)
  ENDELSE
  mtsel   = my_time_string(el_times,UNIX=1)
  ymdels  = mtsel.DATE_TIME
  ymdb    = ymdels
  UTtime  = STRMID(ymdb[*],11L,2L)+STRMID(ymdb[*],14L,2L)+$
            STRMID(ymdb[*],17L,2L)+STRMID(ymdb[*],19L,3L)
  gdate   = STRMID(ymdb[*],0L,10L)
  FOR j=0L, nel - 1L DO BEGIN
    ; => Plot 3D DF
    dat  = ael[j]
    fnam = pldir+'el_'+gdate[j]+'_'+UTtime[j]+suffx3d
    popen,fnam,/PORT
      eh_cont3d,dat,VLIM=vlim,NGRID=ngrid,NSMOOTH=5,/SM_CUTS,/ONE_C
    pclose
    ; => Plot 2D DF
    dat      = ael[j]
    dfpara   = one_count_level(dat,VLIM=vlim,NGRID=ngrid,NUM_PA=24L)
    delb     = my_delb[j]
    fnam     = pldir+'el_'+gdate[j]+'_'+UTtime[j]+suffx2d
    popen,fnam,/PORT
      cont2d,delb,NGRID=30,VLIM=2d4,ANI_TEMP=el_tani[j],GNORM=gnorm,$
                  HEAT_F=heat_f,V_TH=vther[j]
      OPLOT,vout*1e-3,dfpara,COLOR=150,LINESTYLE=4
      XYOUTS,.60,.380,'- - - : One-Count Level',COLOR=150,/NORMAL
    pclose
  ENDFOR
ENDIF

; => ELB DFs
IF (elb_l) THEN BEGIN
  el_tani = interp(tanis_e,atimes,elb_times,/NO_EXTRAP)
  IF (NOT KEYWORD_SET(v_th)) THEN BEGIN
    vther = REPLICATE(0,nelb)
  ENDIF ELSE BEGIN
    vther = interp(vtherme,atimes,elb_times,/NO_EXTRAP)
  ENDELSE
  mtsel   = my_time_string(elb_times,UNIX=1)
  ymdels  = mtsel.DATE_TIME
  ymdb    = ymdels
  UTtime  = STRMID(ymdb[*],11L,2L)+STRMID(ymdb[*],14L,2L)+$
            STRMID(ymdb[*],17L,2L)+STRMID(ymdb[*],19L,3L)
  gdate   = STRMID(ymdb[*],0L,10L)
  FOR j=0L, nelb - 1L DO BEGIN
    ; => Plot 3D DF
    dat  = aelb[j]
    fnam = plbdir+'elb_'+gdate[j]+'_'+UTtime[j]+suffx3d
    popen,fnam,/PORT
      eh_cont3d,dat,VLIM=vlim,NGRID=ngrid,NSMOOTH=5,/SM_CUTS,/ONE_C
    pclose
    ; => Plot 2D DF
    dat      = aelb[j]
    dfpara   = one_count_level(dat,VLIM=vlim,NGRID=ngrid,NUM_PA=24L)
    delb     = myb_delb[j]
    fnam     = plbdir+'elb_'+gdate[j]+'_'+UTtime[j]+suffx2d
    popen,fnam,/PORT
      cont2d,delb,NGRID=30,VLIM=2d4,ANI_TEMP=el_tani[j],GNORM=gnorm,$
                  HEAT_F=heat_f,V_TH=vther[j]
      OPLOT,vout*1e-3,dfpara,COLOR=150,LINESTYLE=4
      XYOUTS,.60,.380,'- - - : One-Count Level',COLOR=150,/NORMAL
    pclose
  ENDFOR
ENDIF



END