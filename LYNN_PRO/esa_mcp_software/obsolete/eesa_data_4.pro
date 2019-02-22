;+
;*****************************************************************************************
;
;  FUNCTION :   eesa_data_4.pro
;  PURPOSE  :   Takes an array of 3DP moment structures and converts them to
;                 the solar wind reference frame, calculates the pitch-angle
;                 distributions (PADs) and then the full distribution functions.
;                 It returns a structure which has arrays of PADs, DFs, and the
;                 solar wind reference frame 3DP moments.
;
;  CALLED BY: 
;               my_3dp_structs.pro  (or directly by user)
;
;  CALLS:
;               convert_vframe.pro
;               pad.pro
;               distfunc.pro
;               extract_tags.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               D2  :  An array of 3DP moment structures from either EESA High or
;                        EESA Low (this includes the burst samples too).
;
;  EXAMPLES:
;               eldat = my_3dp_str_call_2('el' ,TRANGE=tr3)
;               ael   = eldat.DATA
;               moms  = eesa_data_4(ael)
;
;  KEYWORDS:  
;               ESTEPS :  Energy bins to use [2-Element array corresponding to first and
;                           last energy bin element or an array of energy bin elements]
;               NUM_PA :  Number of pitch-angles to sum over (Default = 8L)
;               SPIKES :  If set, tells program to look for data spikes and eliminate them
;
;   CHANGED:  1)  got rid of pointers by creating dummy structures
;                  {Need pointers for DISTFUNC.PRO though}
;                  Now calls MY_PAD_DIST.PRO instead of pad.pro and
;                  MY_DISTFUNC.PRO instead of distfunc.pro
;             2)  Changed syntax and updated man page  [11/07/2008   v1.1.22]
;             3)  Updated man page                     [03/21/2009   v1.1.23]
;             4)  Added keywords:  ESTEPS and NUM_PA   [03/21/2009   v1.2.0]
;             5)  Added keyword:  SPIKES               [03/21/2009   v1.2.1]
;             6)  Changed programs called:  convert_vframe.pro, pad.pro, and distfunc.pro
;                                                      [08/05/2009   v2.0.0]
;
;   ADAPTED FROM:   eesa_data_3.pro  BY: Lynn B. Wilson III
;   CREATED:  03/10/2007
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/05/2009   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION eesa_data_4,d2,ESTEPS=esteps,NUM_PA=num_pa,SPIKES=spikes

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
IF KEYWORD_SET(num_pa) THEN npas  = num_pa ELSE npas  = 10L
IF KEYWORD_SET(esteps) THEN eners = esteps ELSE eners = [0L,14L]
;-----------------------------------------------------------------------------------------
; -Create dummy structures
;-----------------------------------------------------------------------------------------
dd0  = conv_units(d2[0],'df')
pd0  = pad(dd0,NUM_PA=npas,ESTEPS=eners,SPIKES=spikes)
df0  = distfunc(pd0.ENERGY,pd0.ANGLES,MASS=pd0.MASS,DF=pd0.DATA)
extract_tags,dd0,df0

dum0 = REPLICATE(dd0,2L)
dpd0 = REPLICATE(pd0,2L)
dfd0 = REPLICATE(df0,2L)
dum  = CREATE_STRUCT('MOMENTS',dum0,'PADS',dpd0,'DISTS',dfd0)
;-----------------------------------------------------------------------------------------
;  -Make sure the data exists within time range of scphi
;-----------------------------------------------------------------------------------------
myn    = N_ELEMENTS(d2)
pots   = d2.SC_POT
vsw    = d2.VSW
magf   = d2.MAGF

gscphi = WHERE(FINITE(pots) AND pots NE 0. AND FINITE(vsw[0]) AND FINITE(magf[0]),gsc)
IF (gsc GT 0) THEN BEGIN
  myn = gsc
  j0  = gscphi
ENDIF ELSE BEGIN
  MESSAGE,"There is no finite SC POT for the structures!",/INFORMATIONAL,/CONTINUE
  RETURN,dum
ENDELSE
;-----------------------------------------------------------------------------------------
; -Create dummy structures
;-----------------------------------------------------------------------------------------
dumb     = d2[j0[0]]
dumb     = convert_vframe(dumb,/INTERP)   ; -Dummy structure in SW frame
dupd     = pad(dumb,NUM_PA=npas,ESTEPS=eners,SPIKES=spikes)
dufp     = distfunc(dupd.ENERGY,dupd.ANGLES,MASS=dupd.MASS,DF=dupd.DATA)
extract_tags,dumb,dufp
mydat    = REPLICATE(dumb,myn)  ; -array of data structures (in SW frame) to be returned
mypds    = REPLICATE(dupd,myn)  ; -array of PAD structures to be returned
mydfs    = REPLICATE(dufp,myn)  ; -array of distribution func. to be returned

ss = 1
k  = 0L
WHILE(ss) DO BEGIN
  tdat     = d2[k]
  ;---------------------------------------------------------------------------------------
  ; =>Convert into the solar wind frame
  ;---------------------------------------------------------------------------------------
  dd1      = convert_vframe(tdat,/INTERP)
  ;---------------------------------------------------------------------------------------
  ; -Create pitch-angle distributions (PADs) and distribution functions (DFs)
  ;---------------------------------------------------------------------------------------
  pd        = pad(dd1,NUM_PA=npas,ESTEPS=eners,SPIKES=spikes)
  mdfp      = distfunc(pd.ENERGY,pd.ANGLES,MASS=pd.MASS,DF=pd.DATA)
  extract_tags,dd1,mdfp
  mydat[k]  = dd1
  mypds[k]  = pd
  mydfs[k]  = mdfp
  IF (k LT myn - 1L) THEN ss = 1 ELSE ss = 0
  IF (ss) THEN k += 1L
ENDWHILE

mystrs = CREATE_STRUCT('MOMENTS',mydat,'PADS',mypds,'DISTS',mydfs)

;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/CONT,/INFO
;*****************************************************************************************
RETURN,mystrs
END
