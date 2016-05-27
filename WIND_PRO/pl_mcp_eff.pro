;+
;*****************************************************************************************
;
;  FUNCTION :   pl_mcp_eff.pro
;  PURPOSE  :   Returns Pesa Low channel plate efficiency and dead time for a given
;                 PESA Low data structure.
;
;  CALLED BY:   
;               get_pl_extra.pro
;
;  CALLS:
;               umn_default_env.pro
;               read_asc.pro
;               time_double.pro
;               interp.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII files:
;                     pl_mcp_eff.dat
;                     plb_mcp_eff.dat
;
;  INPUT:
;               TIME  :  Scalar Unix time associated with a PESA Low data structure
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               DEADT   :  Set to a named variable to return the 
;               MCPEFF  :  Set to a named variable to return the Pesa Low channel 
;                            plate efficiency
;               RESET   :  If set, uses Modified Pesa Low channel plate efficiency
;               BURST   :  If set, routine reads in efficiencies and dead times from
;                            plb_mcp_eff.dat instead of pl_mcp_eff.dat
;
;   CHANGED:  1)  Updated man page and added error handling for multiple OS's
;                                                                [08/05/2010   v1.1.0]
;             2)  Changed which calibration file is used         [06/09/2011   v1.2.0]
;             3)  Changed hard coded default PESA Low calibration lookup table location
;                   and added keyword:  BURST
;                                                                [07/25/2011   v1.3.0]
;
;   NOTES:      
;               1)  If one uses pl_mcp_eff_3dp.dat instead of pl_mcp_eff.dat, then
;                     the result causes the density estimate (all higher moments too) to
;                     go to zero.
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  07/25/2011   v1.3.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

pro pl_mcp_eff,time,DEADT=dt,MCPEFF=eff,RESET=reset,BURST=burst

;-----------------------------------------------------------------------------------------
; => Load common blocks
;-----------------------------------------------------------------------------------------
COMMON pl_mcp_eff_com,efftime,effval,dtval
IF KEYWORD_SET(reset) THEN effval = 0
IF KEYWORD_SET(burst) THEN filename = '/plb_mcp_eff.dat' ELSE filename = '/pl_mcp_eff.dat'
;-----------------------------------------------------------------------------------------
; => Define directory path to file
;-----------------------------------------------------------------------------------------
IF (STRLOWCASE(!VERSION.OS_NAME) NE 'mac os x') THEN BEGIN
  base_dir     = FILE_EXPAND_PATH('')+'/wind_3dp_pros/WIND_PRO'  ; => LBW III  07/25/2011
ENDIF ELSE BEGIN
  DEFSYSV,'!wind3dp_umn',EXISTS=exists
  IF NOT KEYWORD_SET(exists) THEN BEGIN
    structure = umn_default_env()
    DEFSYSV,'!wind3dp_umn',structure
  ENDIF
  base_dir = !wind3dp_umn.IDL_3DP_LIB_DIR+'WIND_PRO'
ENDELSE
;-----------------------------------------------------------------------------------------
; => Read in data
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(effval) THEN BEGIN
   MESSAGE,/INFO,'Using Modified Pesa Low channel plate efficiency. (reset)'
   d       = {TIME:0d0,EFF:0e0,DT:0e0}
;   file    = base_dir[0]+'/pl_mcp_eff_3dp.dat'       ; => LBW III 06/09/2011
   file    = base_dir[0]+filename[0]
   dat     = read_asc(file,FORMAT=d,/CONV_TIME)
   efftime = dat.TIME
   effval  = dat.EFF
   dtval   = dat.DT
ENDIF
;-----------------------------------------------------------------------------------------
; => Interpolate data and return to user
;-----------------------------------------------------------------------------------------
t   = time_double(time)
eff = interp(effval,efftime,t,INDEX=i)
;dt  = interp(dtval,efftime,t)
eff = effval[i]
dt  = dtval[i]

RETURN
END

