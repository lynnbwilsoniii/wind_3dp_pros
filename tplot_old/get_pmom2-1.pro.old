;+
;*****************************************************************************************
;
;  FUNCTION :   get_pmom2.pro
;  PURPOSE  :   Gets Pesa Low moment structures from onboard calculations and calibrates
;                 the data using a rough instrumental response reduction algorithm.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               wind_com.pro
;               fix_pmom_spin_time.pro
;               read_asc.pro
;               interp.pro
;               store_data.pro
;               xyz_to_polar.pro
;               data_cut.pro
;               rot_mat.pro
;               rotate_tensor.pro
;               tnames.pro
;               options.pro
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
;               PROTONS     :  If set, program gets data from get_pl.pro and assumes 
;                                counts represent only protons
;               ALPHAS      :  If set, program gets data from get_pl.pro and assumes
;                                counts represent alpha-particles (different mass
;                                estimates and charge estimates)
;               POLAR       :  If set, program changes particle velocities into
;                                polar coordinates
;               PREFIX      :  Scalar string to prepend the TPLOT handles
;               MAGF        :  Set to a named variable to return the magnetic field
;                                used to rotate the data
;               NO_TPLOT    :  If set, program will not send data to TPLOT
;               MAGNAME     :  Scalar string defining the TPLOT handle associated with
;                                the GSE magnetic field you wish to use to rotate data
;               NOFIXTIME   :  
;               NOFIXWIDTH  :  If set, program will not calibrate the data by removing
;                                the instrument response
;               NOFIXMCP    :  If set, program will not calibrate the data using the
;                                multi-channel plate efficiency files
;               TIME_SHIFT  :  Scalar double used to offset the times
;
;   CHANGED:  1)  Davin Larson created                     [??/??/????   v1.0.0]
;             2)  Davin Larson changed something...        [11/01/2002   v1.0.4]
;             3)  Re-wrote and cleaned up                  [10/06/2010   v1.1.0]
;
;   NOTES:      
;               1)  load_3dp_data.pro must be called 1st.
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  10/06/2010   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO get_pmom2,PROTONS=protons,ALPHAS=alphas,POLAR=polar,PREFIX=prefix,MAGF=magf, $
              NO_TPLOT=no_tplot,MAGNAME=magname,NOFIXTIME=nofixtime,             $
              NOFIXWIDTH=nofixwidth,NOFIXMCP=nofixmcp,TIME_SHIFT=time_shift

;-----------------------------------------------------------------------------------------
; => Define common block variables
;-----------------------------------------------------------------------------------------
@wind_com.pro
IF (N_ELEMENTS(wind_lib) EQ 0) THEN BEGIN
   PRINT,'You must first load some data'
   RETURN
ENDIF

IF (N_ELEMENTS(polar) EQ 0) THEN polar = 1

mom = {pmomdata,CHARGE:0,MASS:0d0,DENS:0d0,TEMP:0d0,VEL:DBLARR(3), $
       VV:DBLARR(3,3),Q:DBLARR(3)}

moment = {moment_str,TIME:0d0,SPIN:0,GAP:0,VALID:0,E_S:0B,PS:0B, $
          CMOM:BYTARR(10),VC:0,E_RAN:FLTARR(2),DIST:mom}

rec_len = LONG(N_TAGS(moment,/LENGTH))
;-----------------------------------------------------------------------------------------
; => Check to see if PL data is loaded
;-----------------------------------------------------------------------------------------
num     = CALL_EXTERNAL(wind_lib,'pmom_to_idl')

IF (num LE 0) THEN BEGIN
  MESSAGE,/INFO,'No pmom data available'
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Define some dummy variables variables
;-----------------------------------------------------------------------------------------
protons  = REPLICATE(moment,num)   ; => Array of structures for protons
alphas   = REPLICATE(moment,num)   ; => " " alpha-particles
vv_uniq  = [0,4,8,1,2,5]           ; => Uniq elements of a symmetric 3x3 matrix
vv_trace = [0,4,8]                 ; => diagonal elements of a 3x3 matrix
;-----------------------------------------------------------------------------------------
; => call data into IDL from shared object libraries
;-----------------------------------------------------------------------------------------
num = CALL_EXTERNAL(wind_lib,'pmom_to_idl',num,rec_len,protons,alphas)

IF NOT KEYWORD_SET(nofixtime) THEN BEGIN
  protons = fix_pmom_spin_time(protons)
  alphas  = fix_pmom_spin_time(alphas)
ENDIF

time = protons.TIME
IF KEYWORD_SET(time_shift) THEN time = time + time_shift

;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;kluge,  remove when fixed in C - code.
protons.DIST.VV[1*3+2] = -protons.DIST.VV[1*3+2]
protons.DIST.VV[2*3+1] = -protons.DIST.VV[2*3+1]
protons.DIST.VV[0*3+2] = -protons.DIST.VV[0*3+2]
protons.DIST.VV[2*3+0] = -protons.DIST.VV[2*3+0]
;end of kludge
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Vpmag = SQRT(TOTAL(protons.DIST.VEL^2,1,/NAN))  ; => magnitude of proton velocity (km/s)

;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;temp = protons.dist.temp - .074^2 * .00522*vpmag^2
;vtherm = sqrt(temp/.00522)
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;-----------------------------------------------------------------------------------------
; => subtract instrument response here....
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(nofixwidth) THEN BEGIN
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; ctime,t
; wid = average(tsample('VVp',t),1)
; vp2 = average(tsample('Vp_mag',t))^2
; vth2 = average(tsample('wi_swe_VTHp',t))^2
; inst_width2 = float((wid - vth2*[1,1,1,0,0,0]/2) / vp2)
; printdat,/val,wid=300,inst_width2,'instwidth2'
;inst_width2 = [0.00307388, 0.00240956, 0.00274486, 0.00172333, 0,0]
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  ; => Instrument response width
  inst_width2 = [0.00238550, 0.00305542, 0.00185387, 0.00173632, 0, 0]
  vv_map      = [[0,3,4],[3,1,5],[4,5,2]]  ; => mapping elements
  ii          = inst_width2[vv_map]
  FOR i=0L, N_ELEMENTS(time) - 1L DO $
    protons[i].DIST.VV = protons[i].DIST.VV - ii*vpmag[i]^2
  FOR i=0L, N_ELEMENTS(time) - 1L DO $
    alphas[i].DIST.VV = alphas[i].DIST.VV - ii*vpmag[i]^2
  ;---------------------------------------------------------------------------------------
  ; rotate matrix
  ;---------------------------------------------------------------------------------------
  dphi = (protons.PS - 4)/64.*(2*!PI)
  s2   = SIN(dphi)
  c2   = COS(dphi)
  sc   = s2*c2
  s2   = s2^2
  c2   = c2^2
  xx   = protons.DIST.VV[0]
  xy   = protons.DIST.VV[1]
  yy   = protons.DIST.VV[4]

  protons.DIST.VV[0] =  c2 * xx  + 2*sc   * xy + s2 * yy
  protons.DIST.VV[1] = -sc * xx  + (c2-s2)* xy + sc * yy
  protons.DIST.VV[3] = protons.DIST.VV[1]
  protons.DIST.VV[4] = s2  * xx  - 2*sc   * xy + c2 * yy
ENDIF
;-----------------------------------------------------------------------------------------
; => Calculate thermal speeds and average temperatures for both protons and alpha-particles
;-----------------------------------------------------------------------------------------
vthp = SQRT(TOTAL(protons.DIST.VV[vv_trace],1,/NAN)*2/3)
vtha = SQRT(TOTAL(alphas.DIST.VV[vv_trace],1,/NAN)*2/3)

protons.DIST.TEMP = .00522 * vthp^2
alphas.DIST.TEMP  = 4* .00522 * vtha^2
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;vt3 = replicate(!values.f_nan,n_elements(time))
;for i=0l,n_elements(time)-1 do begin
;      vv = reform(protons[i].dist.vv)
;      if finite(total(vv)) then  vt3[i]=sqrt(determ(reform(vv),/check,/double))
;endfor
;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;-----------------------------------------------------------------------------------------
; => calibrate density using multi-channel plate efficiency
;-----------------------------------------------------------------------------------------

IF NOT KEYWORD_SET(nofixmcp) THEN BEGIN
  mdir  = FILE_EXPAND_PATH('')
  file  = mdir[0]+'/wind_3dp_pros/WIND_PRO/pl_mcp_eff_3dp.dat'
  mcp   = read_asc(file,/TAGS,/CONV_TIME)
  t     = protons.TIME
  dummy = interp(mcp.EFF,mcp.TIME,t,INDEX=i)
  eff   = (mcp.EFF)[i]
  dt    = (mcp.DT)[i]
  rmax  = protons.DIST.DENS*(vpmag^4/vthp^3)/1e6
  corr  = (1 + rmax*dt)/eff
  protons.DIST.DENS = protons.DIST.DENS*corr
ENDIF

IF NOT KEYWORD_SET(prefix) THEN prefix = ''        ; => LBW 10/06/2010

IF NOT KEYWORD_SET(no_tplot) THEN BEGIN
  IF (SIZE(/TYPE,prefix[0]) NE 7) THEN prefix = ''
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ;store_data,prefix+'Vc',data={x:time,y:protons.Vc}
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
  ; => send the proton density to TPLOT
  store_data,prefix[0]+'Np',DATA={X:time,Y:FLOAT(protons.DIST.DENS)}
  IF KEYWORD_SET(corr) THEN store_data,prefix[0]+'Eff',DATA={X:time,Y:FLOAT(1/corr)}

  store_data,prefix[0]+'Tp',DATA={X:time,Y:FLOAT(protons.DIST.TEMP)}
  store_data,prefix[0]+'Vp',DATA={X:time,Y:FLOAT(TRANSPOSE(protons.DIST.VEL))}
  options,prefix[0]+'Vp','COLORS',[250,150,50]
  ; => If POLAR is set, then change proton velocities to polar coordinates
  IF KEYWORD_SET(polar) THEN xyz_to_polar,prefix[0]+'Vp',/PH_0_360

  ; => Second moment of proton distribution
  store_data,prefix[0]+'VVp',DATA={X:time,Y:FLOAT(TRANSPOSE(protons.DIST.VV[vv_uniq]))}
         
  store_data,prefix[0]+'VTHp',DATA={X:time,Y:FLOAT(vthp)}
  store_data,prefix[0]+'VTHp/Vp',DATA={X:time,Y:FLOAT(vthp/vpmag)}
  store_data,prefix[0]+'Na/Np',DATA={X:time,Y:FLOAT(alphas.DIST.DENS/protons.DIST.DENS)}
         
  ; => send the alpha-particle density to TPLOT
  store_data,prefix[0]+'Na',DATA={X:time,Y:FLOAT(alphas.DIST.DENS)}
  store_data,prefix[0]+'Ta',DATA={X:time,Y:FLOAT(alphas.DIST.TEMP)}
  store_data,prefix[0]+'Va',DATA={X:time,Y:FLOAT(TRANSPOSE(alphas.DIST.VEL))}
  options,prefix[0]+'Va','COLORS',[250,150,50]
  ; => If POLAR is set, then change alpha-particle velocities to polar coordinates
  IF KEYWORD_SET(polar) THEN xyz_to_polar,prefix[0]+'Va',/PH_0_360
  ; => Second moment of alpha-particle distribution
  store_data,prefix[0]+'VVa',DATA={X:time,Y:FLOAT(TRANSPOSE(alphas.DIST.VV[vv_uniq]))}
  store_data,prefix[0]+'VTHa',DATA={X:time,Y:FLOAT(vtha)}
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ;store_data,prefix+'VTHp^3',data={x:time,   y:float(vt3)}
  ;store_data,prefix+'spin',data={x:time, y:long(uint(protons.spin))}
  ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  magf = 0
  mass = protons[0].DIST.MASS  ; => Proton mass [eV/(km/s)^2]

  IF KEYWORD_SET(magname) THEN BEGIN
    P3   = FLTARR(N_ELEMENTS(time),6)
    vt3  = FLTARR(N_ELEMENTS(time))
    magf = data_cut(magname,time)
    FOR i=0L, N_ELEMENTS(time) - 1L DO BEGIN
      rmat    = rot_mat(REFORM(magf[i,*]))
      vv      = REFORM(protons[i].DIST.VV)
      ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      ; vv = transpose(rmat) ## (vv ## rmat)
      ;;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      vv      = rotate_tensor(vv,rmat)
      P3[i,*] = vv[vv_uniq]
    ENDFOR
    store_data,prefix[0]+'RVVp',DATA={X:time,Y:FLOAT(P3)}
    ; => Trace of pressure tensor multiplied by the particle mass
    T3 = P3[*,0:2]*mass
;    HELP,T3,mass,P3
    ; => Tpara/Tperp
    assym = 2*P3[*,2]/(p3[*,1] + p3[*,0])
    store_data,prefix[0]+'T3p',DATA={X:time,Y:FLOAT(T3)}
    store_data,prefix[0]+'Tp_rat',DATA={X:time,Y:FLOAT(assym)}
    store_data,prefix[0]+'magf',DATA={X:time,Y:FLOAT(magf)}
    options,prefix[0]+'magf','COLORS',[250,150,50]
  ENDIF
  nnw = tnames()
  options,nnw,'PANEL_SIZE',2.
  options,nnw,'XMINOR',5
  options,nnw,'YSTYLE',1
  options,nnw,'XTICKLEN',0.04
ENDIF


RETURN
END


