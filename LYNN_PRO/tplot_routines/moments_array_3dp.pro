;+
;*****************************************************************************************
;
;  FUNCTION :   moments_array_3dp.pro
;  PURPOSE  :   This is a wrapping program for moments_3d.pro and it includes the option
;                 to calculate the heat flux vector in GSE or FACs.  Set the appropriate
;                 keywords one wishes to return for relevant quantities.  Note that if
;                 user sends in an array for survey sampled data (e.g. Eesa Low) AND
;                 burst sampled data (e.g. Eesa Low Burst), the data will be sorted
;                 and combined into one set of arrays.
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               dat_3dp_energy_bins.pro
;               moments_3d.pro
;               tnames.pro
;               store_data.pro
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
;               PLM       :  N-Element array of 3DP particle data structures from a 
;                              non-burst mode program (e.g. get_el.pro)
;               PLBM      :  M-Element array of 3DP particle data structuresfrom a 
;                              burst mode program (e.g. get_elb.pro)
;               AVGTEMP   :  Set to a named variable to return an array of average 
;                              temperatures dependent on energy bins used, density, 
;                              etc. [eV] {[M+N]-Element array}
;               T_PERP    :  Set to a named variable to return an array of perpendicular
;                              (to the magnetic field) temperatures [eV] 
;                              {[M+N]-Element array}
;               T_PARA    :  Set to a named variable to return an array of parallel
;                              (to the magnetic field) temperatures [eV]
;                              {[M+N]-Element array}
;               V_THERM   :  Set to a named variable to return an array of average 
;                              thermal speeds [km/s] {[M+N]-Element array}
;               VELOCITY  :  Set to a named variable to return an [(M+N),3]-element
;                              array of average velocity vectors [km/s]
;               PRESSURE  :  Set to a named variable to return an [M+N]-element
;                              array of average dynamic pressures [eV cm^(-3)]
;               DENSITY   :  Set to a named variable to return an [M+N]-element
;                              array of average particle densities [# cm^(-3)]
;               SC_POT    :  [M+N]-Element array defining the spacecraft potential (eV)
;               MAGDIR    :  [M+N,3]-Element vector array defining the magnetic
;                              field (nT) associated with the data structure
;                              [Note:  This can be useful if one wishes to calculate
;                                 moments with respect to some other vector direction]
;               ERANGE    :  Set to a [M+N,2]-Element array specifying the first and
;                              last elements of the energy bins desired to be used for
;                              calculating the moments
;               MOMS      :  Set to a named variable to return an array of particle
;                              moment structures
;               TO_TPLOT  :  If set, data quantities are sent to TPLOT
;               SUFFX     :  Scalar string to differentiate TPLOT handles if program
;                              called multiple times
;
;   CHANGED:  1)  Added a few comments to explain logic statement  
;                   and added keyword END_TIME to output structure MOMS
;                                                                 [09/28/2009   v1.0.1]
;             2)  Added density to output TPLOT handles and keyword:  DENSITY
;                                                                 [09/29/2009   v1.1.0]
;
;   NOTES:      
;               1)  The MAGDIR keyword can be useful if one wishes to calculate
;                     moments with respect to some other vector direction (e.g. shock
;                     normal vector)
;               2)  For the electrostatic analyzers, the first energy bin corresponds
;                     to the highest energy while the SST energy bins are reversed.
;                     Thus if one wished to worry about ONLY the 5 highest energies for
;                     an Eesa Low Burst sample, set ERANGE=[0,4].
;               3)  The keywords, ERANGE and MAGDIR can be a 2-element and 3-element
;                     array, respectively, if one wants to consider set values over
;                     the entire set of particle structures.
;
;   CREATED:  08/20/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/29/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO moments_array_3dp,PLM=plm,PLBM=plbm,AVGTEMP=avgtemp,T_PERP=t_perp,T_PARA=t_para, $
                      V_THERM=v_therm,VELOCITY=velocity,PRESSURE=pressure,           $
                      DENSITY=density,SC_POT=scpot,MAGDIR=magdir,ERANGE=erange,      $
                      MOMS=moms,TO_TPLOT=to_tplot,SUFFX=suffx

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f        = !VALUES.F_NAN
d        = !VALUES.D_NAN
xsuff    = ''          ; => String used for suffix to TPLOT names 
tp_hands = ''          ; => Strings of base TPLOT handles
v_units  = ''          ; => String used for Y-Title Velocity units
t_units  = ''          ; => String used for Y-Title Temperature units
p_units  = ''          ; => String used for Y-Title Pressure units
d_units  = ''          ; => String used for Y-Title Density units
t_pref   = ''          ; => String used for Y-Title Velocity units
v_pref   = ''          ; => String used for Y-Title Temperature units
p_pref   = ''          ; => String used for Y-Title Pressure units
d_pref   = ''          ; => String used for Y-Title Density units
t_ttle   = ''          ; => Avg. Temp Y-Title
vv_ttle  = ''          ; => Velocity Y-Title
vt_ttle  = ''          ; => Thermal Speed Y-Title
den_ttle = ''          ; => Density Y-Title
tpa_ttle = ''          ; => Parallel Temp Y-Title
tpe_ttle = ''          ; => Perpendicular Temp Y-Title
pre_ttle = ''          ; => Avg. Pressure Y-Title
tan_ttle = ''          ; => Temperature anisotropy Y-Title
tp_ttles = ''          ; => String array of Y-Titles

IF KEYWORD_SET(suffx) THEN xsuff = suffx[0] ELSE xsuff = ''
tp_hands = ['T_avg','V_Therm','N','Velocity','Tpara','Tperp','Tanisotropy','Pressure']
v_units  = ' (km/s)'
t_units  = ' (eV)'
p_units  = ' (eV/cm!U3!N'+')'
d_units  = ' (#/cm!U3!N'+')'
t_pref   = ['T!D','!N'+t_units]
v_pref   = ['V!D','!N'+v_units]
p_pref   = ['P!D','!N'+p_units]
d_pref   = ['N!D','!N'+d_units]
t_ttle   = t_pref[0]+xsuff+t_pref[1]
vv_ttle  = v_pref[0]+xsuff+v_pref[1]
vt_ttle  = v_pref[0]+'T'+xsuff+v_pref[1]
den_ttle = d_pref[0]+xsuff+d_pref[1]
tpa_ttle = t_pref[0]+'!9#!3'+xsuff+t_pref[1]
tpe_ttle = t_pref[0]+'!9x!3'+xsuff+t_pref[1]
pre_ttle = p_pref[0]+xsuff+p_pref[1]
tan_ttle = t_pref[0]+'!9x!3'+xsuff+'!N'+'/'+t_pref[0]+'!9#!3'+xsuff+'!N'
tp_ttles = [t_ttle,vt_ttle,den_ttle,vv_ttle,tpa_ttle,tpe_ttle,tan_ttle,pre_ttle]
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF (NOT KEYWORD_SET(plm) AND NOT KEYWORD_SET(plbm)) THEN BEGIN
  MESSAGE,'No data was loaded...',/INFORMATIONAL,/CONTINUE
  RETURN
END

str_check = [KEYWORD_SET(plm),KEYWORD_SET(plbm)]
gcheck    = WHERE(str_check,gch)
CASE gch OF
  1L   : BEGIN
    IF (gcheck[0] EQ 0L) THEN a_str = plm   ELSE a_str = plbm
    IF (gcheck[0] EQ 0L) THEN rstr  = 'PLM' ELSE rstr  = 'PLBM'
    atype  = SIZE(a_str,/TYPE)
    IF (atype NE 8L) THEN MESSAGE,'Incorrect keyword format:  '+rstr
    atimes = a_str.TIME
  END
  2L   : BEGIN
    typ0   = SIZE(plm,/TYPE) NE 8L
    typ1   = SIZE(plbm,/TYPE) NE 8L
    tchck  = WHERE([typ0,typ1],tch)
    ;-------------------------------------------------------------------------------------
    ; => Create dummy strings for error messages
    ;      e.g. IF (typ0 EQ 1 AND typ1 EQ 0) =>> error message for PLM keyword
    ;-------------------------------------------------------------------------------------
    IF (typ0) THEN rstr0 = 'PLM'  ELSE rstr0 = ''
    IF (typ1) THEN rstr1 = 'PLBM' ELSE rstr1 = ''
    rstr   = [rstr0,rstr1]
    IF (typ0 AND typ1) THEN MESSAGE,'Incorrect keyword format:  PLM and PLBM'
    IF (typ0 OR typ1) THEN BEGIN
      MESSAGE,'Incorrect keyword format:  '+rstr[tchck[0]],/INFORMATIONAL,/CONTINUE
      IF (tchck[0] EQ 1L) THEN a_str = plm ELSE a_str = plbm
    ENDIF ELSE BEGIN
      a_str  = [plm,plbm]
    ENDELSE
    atimes = a_str.TIME
  END
  ELSE : BEGIN
    MESSAGE,'How did you manage this...',/INFORMATIONAL,/CONTINUE
    RETURN
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Sort input chronologically
;-----------------------------------------------------------------------------------------
sp     = SORT(atimes)
a_str  = a_str[sp]
atimes = atimes[sp]
nn     = N_ELEMENTS(a_str)
;-----------------------------------------------------------------------------------------
; => Check SC Potential
;-----------------------------------------------------------------------------------------
IF (NOT KEYWORD_SET(scpot) OR N_ELEMENTS(scpot) NE nn) THEN scpots = REFORM(a_str.SC_POT)
;-----------------------------------------------------------------------------------------
; => Check MAGDIR
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(magdir) THEN BEGIN
  mdims = SIZE(magdir,/DIMENSIONS)
  nmdim = SIZE(magdir,/N_DIMENSIONS)
  IF (nmdim LE 1) THEN BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Either a 3-Element vector or somehow undefined...
    ;-------------------------------------------------------------------------------------
    IF (nmdim LT 1) THEN BEGIN
      mgdirs = TRANSPOSE(a_str.MAGF)   ; => somehow it was undefined?
    ENDIF ELSE BEGIN
      CASE mdims[0] OF
        3L   :  mgdirs = REPLICATE(1e0,nn) # magdir
        ELSE :  mgdirs = TRANSPOSE(a_str.MAGF)
      ENDCASE
    ENDELSE
  ENDIF ELSE BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Either a [nn,3] or [3,nn]-Element vector array or something else
    ;-------------------------------------------------------------------------------------
    g3el = WHERE(mdims EQ 3L,g3)
    CASE g3 OF
      0L   :  BEGIN
        mtest = (mdims[1] EQ nn)
        IF (mtest) THEN mgdirs = TRANSPOSE(magdir) ELSE mgdirs = TRANSPOSE(a_str.MAGF)
      END
      1L   :  BEGIN
        mtest = (mdims[0] EQ nn)
        IF (mtest) THEN mgdirs = REFORM(magdir) ELSE mgdirs = TRANSPOSE(a_str.MAGF)
      END
      ELSE :  mgdirs = TRANSPOSE(a_str.MAGF)
    ENDCASE
  ENDELSE
ENDIF ELSE BEGIN
  mgdirs = TRANSPOSE(a_str.MAGF)
ENDELSE
;-----------------------------------------------------------------------------------------
; => Check ERANGE [Energy bin ranges]
;-----------------------------------------------------------------------------------------
n_ener    = N_ELEMENTS(REFORM(erange))
nmdim     = SIZE(REFORM(erange),/N_DIMENSIONS)
mdims     = SIZE(REFORM(erange),/DIMENSIONS)
temp      = [0L, a_str[0].NENERGY - 1L]
IF (nmdim NE 1L) THEN BEGIN
  IF (nmdim EQ 2L) THEN BEGIN
    g2el = WHERE(mdims EQ 2L,g2)
    CASE g2 OF
      0L   :  BEGIN
        mtest = (mdims[1] EQ nn)
        IF (mtest) THEN erge = TRANSPOSE(erange) ELSE erge = REPLICATE(1e0,nn) # temp
      END
      1L   :  BEGIN
        mtest = (mdims[0] EQ nn)
        IF (mtest) THEN erge = REFORM(erange) ELSE erge = REPLICATE(1e0,nn) # temp
      END
      ELSE :  BEGIN
        erge      = LONARR(nn,2)
        erge[*,0] = temp[0]
        erge[*,1] = temp[1]
      END
    ENDCASE
  ENDIF ELSE BEGIN
    erge      = LONARR(nn,2)
    erge[*,0] = temp[0]
    erge[*,1] = temp[1]
  ENDELSE
ENDIF ELSE BEGIN
  CASE n_ener OF
    2L   : BEGIN
      all_eners  = dat_3dp_energy_bins(a_str[0],EBINS=erange)
      erge0      = all_eners.E_BINS          ; => 2-Element array for energy bin values
      a_energy   = all_eners.ALL_ENERGIES    ; => [eV]
      erge       = LONARR(nn,2)
      erge[*,0]  = erge0[0]
      erge[*,1]  = erge0[1]
    END
    ELSE : BEGIN
      erge      = LONARR(nn,2)
      erge[*,0] = temp[0]
      erge[*,1] = temp[1]
    END
  ENDCASE
ENDELSE
ebins = erge
;-----------------------------------------------------------------------------------------
; => Calculate Particle Moments (from estimates of the distribution function)
;-----------------------------------------------------------------------------------------
sform  = moments_3d()
str_element,sform,'END_TIME',0d0,/ADD_REPLACE
a_moms = REPLICATE(sform,nn)       ; => Dummy array of moment calculation structures
FOR j=0L, nn - 1L DO BEGIN
  delb      = a_str[j]
  tener     = REFORM(ebins[j,*])      ; => Energy bins to use
  tscpot    = scpots[j]               ; => SC Potential (eV)
  tmagf     = REFORM(mgdirs[j,*])     ; => B-field (or other vector) direction [GSE]
  tmoms     = moments_3d(delb,FORMAT=sform,SC_POT=tscpot,MAGDIR=tmagf,ERANGE=tener)
  str_element,tmoms,'END_TIME',delb.END_TIME,/ADD_REPLACE
  a_moms[j] = tmoms
ENDFOR
;-----------------------------------------------------------------------------------------
; => Define return quantities
;-----------------------------------------------------------------------------------------
p_els     = [0L,4L,8L]                   ; => Diagonal elements of a 3x3 matrix
avgtemp   = REFORM(a_moms.AVGTEMP)       ; => Avg. Particle Temp (eV)
v_therm   = REFORM(a_moms.VTHERMAL)      ; => Avg. Particle Thermal Speed (km/s)
tempvec   = TRANSPOSE(a_moms.MAGT3)      ; => Vector Temp [perp1,perp2,para] (eV)
velocity  = TRANSPOSE(a_moms.VELOCITY)   ; => Velocity vectors (km/s)
p_tensor  = TRANSPOSE(a_moms.PTENS)      ; => Pressure tensor [eV cm^(-3)]
density   = REFORM(a_moms.DENSITY)       ; => Particle density [# cm^(-3)]

t_perp    = 5e-1*(tempvec[*,0] + tempvec[*,1])
t_para    = REFORM(tempvec[*,2])
pressure  = TOTAL(p_tensor[*,p_els],2,/NAN)/3.
moms      = a_moms
;-----------------------------------------------------------------------------------------
; => Send to TPLOT of desired
;-----------------------------------------------------------------------------------------
tplot_nms = ''   ; => list of TPLOT handles
IF KEYWORD_SET(to_tplot) THEN BEGIN
  IF (xsuff[0] EQ '') THEN tplot_nms = tp_hands ELSE tplot_nms = tp_hands+'_'+xsuff[0]
  atimes    = moms.TIME
  tanis     = t_perp/t_para
  dstr      = CREATE_STRUCT(tp_hands,avgtemp,v_therm,density,velocity,t_para,t_perp,$
                            tanis,pressure)
  ntphands  = N_ELEMENTS(tp_hands)
  FOR j=0L, ntphands - 1L DO BEGIN
    store_data,tplot_nms[j],DATA={X:atimes,Y:dstr.(j)}
    options,tplot_nms[j],'YTITLE',tp_ttles[j]
  ENDFOR
  ctp0 = tnames('Velocity')
  ctp1 = tnames('Velocity'+'_'+xsuff[0])
  IF (xsuff[0] EQ '') THEN ctpname = ctp0[0] ELSE ctpname = ctp1[0]
  options,ctpname[0],'COLORS',[250L,150L,50L]
  nnw = tplot_nms
  options,nnw,"YSTYLE",1
  options,nnw,"PANEL_SIZE",2.
  options,nnw,'XMINOR',5
  options,nnw,'XTICKLEN',0.04
ENDIF

RETURN
END