;+
;*****************************************************************************************
;
;  FUNCTION :   self_write_3dp_dfs.pro
;  PURPOSE  :   
;
;  CALLED BY:   
;               
;
;  CALLS:
;               
;
;  REQUIRES:    
;               
;
;  INPUT:
;               
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               NUM_PA  :  Number of pitch-angles to sum over (Default = 8L)
;               BURST   :  If set redefines the name of the string associated with
;                            the particle data structures to 'aelb'
;                            [Default = 'ael']
;               INTERP  :  If set, program will write a string to tell 
;                            convert_vframe.pro to interpolate the data that was
;                            removed by converting into the solar wind frame and
;                            taking into account the spacecraft potential
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               
;
;   CREATED:  02/17/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  02/17/2010   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO self_write_3dp_dfs,nels,NUM_PA=num_pa,BURST=burst,INTERP=interp

;-----------------------------------------------------------------------------------------
; => Check input parameters
;-----------------------------------------------------------------------------------------
IF N_ELEMENTS(num_pa) EQ 0 THEN num_pa = 8L
;-----------------------------------------------------------------------------------------
; => Define some constants and dummy variables
;-----------------------------------------------------------------------------------------
dat_pref  = 'del'
IF KEYWORD_SET(burst) THEN BEGIN
  name      = 'aelb'
ENDIF ELSE BEGIN
  name      = 'ael'
ENDELSE

IF KEYWORD_SET(interp) THEN BEGIN
  cvf_suff  = '],/INTERP)'
ENDIF ELSE BEGIN
  cvf_suff  = '])'
ENDELSE

cvf_pref  = ' = convert_vframe('+name[0]+'['


pa_str    = STRTRIM(STRING(FORMAT='(I)',num_pa[0]),2)
pd_pref   = 'pd'
pad_pref  = ' = pad(del'
pad_suff  = ',NUM_PA='+pa_str[0]+')'

df_pref   = 'df'
dist_pref = ' = distfunc(pd'
dist_ener = '.ENERGY,pd'
dist_angl = '.ANGLES,MASS=pd'
dist_mass = '.MASS,DF=pd'
dist_suff = '.DATA)'

ext_pref  = 'extract_tags,del'
ext_mid   = ',df'

astr      = 'adel = ['
pstr      = 'apd  = ['
;astr2     = ',adel]'
;test_j    = 'IF (j EQ 0L) THEN '+astr[0]+dat_pref[0]+'] ELSE '+astr[0]


tdat   = ''         ; => e.g. 'del0 = convert_vframe(ael[0])'
tpd    = ''         ; => e.g. 'pd0 = pad(del0,NUM_PA=17)'
tdf    = ''         ; => e.g. 'df0 = distfunc(pd0.ENERGY,pd0.ANGLES,MASS=pd0.MASS,DF=pd0.DATA)'
ext    = ''
all_d  = astr[0]    ; => e.g. 'adel = [del0,del1,del2]'
all_p  = pstr[0]    ; => e.g. 'apd  = [pd0,pd1,pd2]'
all_0  = 'DELVAR,'  ; => e.g. 'DELVAR,del0,del1,del2'
all_1  = 'DELVAR,'  ; => e.g. 'DELVAR,pd0,pd1,pd2'

fname  = 'dummy_3dp_string_file.pro'
;-----------------------------------------------------------------------------------------
; => Determine strings to print to file
;-----------------------------------------------------------------------------------------
OPENW,gunit,fname,/GET_LUN
;  PRINTF,gunit,'!QUIET = 1'     ; => Kill error messages
  PRINTF,gunit,'FUNCTION dummy_3dp_string_file, '+name[0]
  PRINTF,gunit,''
  PRINTF,gunit,'ex_start = SYSTIME(1)'
  PRINTF,gunit,''
  FOR j=0L, nels - 1L DO BEGIN
    jstr  = STRTRIM(j,2L)
    tdat  = dat_pref[0]+jstr[0]+cvf_pref[0]+jstr[0]+cvf_suff[0]
    tpd   = pd_pref[0]+jstr[0]+pad_pref[0]+jstr[0]+pad_suff[0]
    tdf   = df_pref[0]+jstr[0]+dist_pref[0]+jstr[0]+dist_ener[0]+jstr[0]
    tdf   = tdf[0]+dist_angl[0]+jstr[0]+dist_mass[0]+jstr[0]+dist_suff[0]
    ext   = ext_pref[0]+jstr[0]+ext_mid[0]+jstr[0]
    all_d = all_d[0]+dat_pref[0]+jstr[0]+','
    all_p = all_p[0]+pd_pref[0]+jstr[0]+','
    all_0 = all_0[0]+dat_pref[0]+jstr[0]+','
    all_1 = all_1[0]+pd_pref[0]+jstr[0]+','
    PRINTF,gunit,tdat
    PRINTF,gunit,tpd
    PRINTF,gunit,tdf
    PRINTF,gunit,ext
  ENDFOR

  all_d = STRMID(all_d[0],0L,STRLEN(all_d[0])-1L)+']'
  all_p = STRMID(all_p[0],0L,STRLEN(all_p[0])-1L)+']'
  
  all_0 = STRMID(all_0[0],0L,STRLEN(all_0[0])-1L)
  all_1 = STRMID(all_1[0],0L,STRLEN(all_1[0])-1L)
  
  PRINTF,gunit,''
  PRINTF,gunit,all_d
  PRINTF,gunit,all_p
;  PRINTF,gunit,all_0
;  PRINTF,gunit,all_1
  
  PRINTF,gunit,''
  PRINTF,gunit,'ex_time = SYSTIME(1) - ex_start'
  PRINTF,gunit,"MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE"
  
  PRINTF,gunit,''
  PRINTF,gunit,'RETURN, {DF:adel,PAD:apd}'
  PRINTF,gunit,'END'
;  PRINTF,gunit,'!QUIET = 0'     ; => Allow error messages
; => Close/Finalize file writing process
FREE_LUN,gunit

END


