;+
;*****************************************************************************************
;
;  FUNCTION :   one_count_level.pro
;  PURPOSE  :   This program calculates the one count level of a 3D particle distribution
;                 given a particle moment with the same format as those returned
;                 by the Wind/3DP get_??.pro programs.  
;
;  CALLED BY:   
;               cont2d.pro
;
;  CALLS:
;               dat_3dp_str_names.pro
;               velocity.pro
;               convert_ph_units.pro
;               convert_vframe.pro
;               pad.pro
;               distfunc.pro
;               extract_tags.pro
;               add_df2d_to_ph.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               DAT  :  A 3D data structure produced by get_??.pro that has NOT been
;                         altered other than adding velocity frame (Tag VSW), magnetic
;                         field (Tag MAGF), and spacecraft potential (Tag SC_POT) data
;                         to the structure.
;                         [?? = el, eh, elb, ehb, ph, etc.]
;
;  EXAMPLES:    
;               t    = '1995-04-04/09:45:00'
;               td   = time_double(t)
;               el   = get_el(td)
;               add_vsw2,el,'[TPLOT Name for Vsw]'
;               add_magf2,el,'[TPLOT Name for B-field data]'
;               add_scpot,el,'[TPLOT Name for SC Potential]'
;               onct = one_count_level(el)
;
;  KEYWORDS:    
;               VLIM     :  Limit for x-y axes over which to plot data
;               NGRID    :  # of isotropic velocity grids to use to triangulate the data
;                             [Default = 20L]
;               NUM_PA   :  Number of pitch-angles to sum over (Default = 24L)
;               
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   CREATED:  08/10/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/10/2009   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION one_count_level,dat,VLIM=vlim,NGRID=ngrid,NUM_PA=num_pa

;-----------------------------------------------------------------------------------------
; => Define some dummy variables
;-----------------------------------------------------------------------------------------
f      = !VALUES.F_NAN
d      = !VALUES.D_NAN

dtags  = ['PROJECT_NAME','DATA_NAME','UNITS_NAME','UNITS_PROCEDURE','TIME','END_TIME', $
          'TRANGE','INTEG_T','DELTA_T','MASS','GEOMFACTOR','INDEX','N_SAMPLES','SHIFT',$
          'VALID','SPIN','NBINS','NENERGY','DACCODES','VOLTS','DATA','ENERGY',         $
          'DENERGY','PHI','DPHI','THETA','DTHETA','BINS','DT','GF','BKGRATE',          $
          'DEADTIME','DVOLUME','DDATA','MAGF','VSW','DOMEGA','SC_POT']

needed = ['PROJECT_NAME','DATA_NAME','UNITS_NAME','UNITS_PROCEDURE','MAGF','VSW','SC_POT']
;-----------------------------------------------------------------------------------------
; => Check distribution to see if it's worth going any further
;-----------------------------------------------------------------------------------------
dat3d  = dat[0]
o_type = SIZE(dat3d,/TYPE)
CASE o_type[0] OF
  8    : BEGIN
    tags = TAG_NAMES(dat3d)
    good = WHERE(tags EQ 'VALID',gd)
    IF (gd GT 0L) THEN BEGIN
      IF (dat3d.VALID EQ 0) THEN BEGIN
        MESSAGE,'There is no valid data for this 3D moment sample.',/INFORMATIONAL,/CONTINUE
        RETURN,dat
      ENDIF
    ENDIF ELSE BEGIN
      MESSAGE,'Incorrect input format: DAT (Must be a structure)',/INFORMATIONAL,/CONTINUE
      RETURN,dat
    ENDELSE
  END
  ELSE : BEGIN
    MESSAGE,'Incorrect input format: DAT (Must be a structure)',/INFORMATIONAL,/CONTINUE
    RETURN,dat
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Determine how to handle structure
;-----------------------------------------------------------------------------------------
strn    = dat_3dp_str_names(dat3d)
u_name  = STRLOWCASE(dat3d.UNITS_NAME)
sh_nme  = STRLOWCASE(STRMID(strn.SN,0L,1L))
test_el = (sh_nme EQ 'e')
test_ph = (STRLOWCASE(STRMID(strn.SN,0L,2L)) EQ 'ph')
IF (test_el) THEN ufunc = 'convert_vframe' ELSE ufunc = ''
IF (test_ph) THEN ufunc = 'convert_ph_units' ELSE ufunc = ''
IF (ufunc EQ '') THEN ufunc = 'conv_units'
;-----------------------------------------------------------------------------------------
; => Create false 1.0 Count Data
;-----------------------------------------------------------------------------------------
ddims = SIZE(dat3d.DATA,/DIMENSIONS)
nrg   = TOTAL(dat3d.ENERGY,2,/NAN)/ TOTAL(FINITE(dat3d.ENERGY),2,/NAN)
CASE u_name[0] OF
  'counts' : BEGIN
    dat3d.DATA = REPLICATE(1.0,ddims[0],ddims[1]) ; -change data to 1.0
  END
  'df'     : BEGIN
    dat3d.UNITS_NAME = 'Counts'
    dat3d.ENERGY     = nrg # REPLICATE(1.0,ddims[1])
    dat3d.DATA       = REPLICATE(1.0,ddims[0],ddims[1]) ; -change data to 1.0
  END
  ELSE     : BEGIN
    MESSAGE,'Incorrect input format: DAT (incorrect units)',/INFORMATIONAL,/CONTINUE
    RETURN,dat
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Convert units appropriately then calculate PAD and DF accordingly
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(ngrid) THEN ngrid = 20L ; => # of levels to use
IF NOT KEYWORD_SET(vlim) THEN vlim = MAX(velocity(nrg,dat3d.MASS,/TRUE),/NAN)
vout   = (DINDGEN(2L*ngrid + 1L)/ngrid - 1L) * vlim

atests = [test_el,test_ph,(ufunc EQ '')]
gates  = WHERE(atests GT 0,gat)
CASE gates[0] OF
  0L   : BEGIN  ; => EL structure
    IF NOT KEYWORD_SET(num_pa) THEN num_pa = 24L
    onct = convert_vframe(dat3d,/INTERP)
    pd   = pad(onct,NUM_PA=num_pa)
    df   = distfunc(pd.ENERGY,pd.ANGLES,MASS=pd.MASS,DF=pd.DATA)
    extract_tags,onct,df
    dfpara = distfunc(vout,0.,PARAM=onct)
  END
  1L   : BEGIN  ; => PH structure
    onct   = dat3d
    add_df2d_to_ph,onct,VLIM=vlim,NGRID=ngrid
    dfpara = SMOOTH(onct.DF_PARA,3L,/EDGE_TRUNCATE,/NAN)
  END
  2L   : BEGIN  ; => Some other structure
    onct   = dat3d
    add_df2d_to_ph,onct,VLIM=vlim,NGRID=ngrid
    dfpara = SMOOTH(onct.DF_PARA,3L,/EDGE_TRUNCATE,/NAN)
  END
  ELSE : BEGIN
    MESSAGE,'I am not sure how you managed this...',/INFORMATIONAL,/CONTINUE
    RETURN,dat
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return One Count Level
;-----------------------------------------------------------------------------------------
RETURN,dfpara
END