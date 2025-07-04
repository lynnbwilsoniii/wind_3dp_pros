;+
;*****************************************************************************************
;
;  PROCEDURE:   get_moment3d.pro
;  PURPOSE  :    Calculates 3D particle moments for a given time range and returns data
;                  to TPLOT for later use.  This program only calculates up through
;                  the pressure tensor (2nd moment), but if you want through the 4th
;                  moment (R-Tensor), use mom3d.pro.
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               get_??.pro  [?? = el, pl, ehb, etc.]
;               minmax.pro
;               data_cut.pro
;               moments_3d.pro
;               str_element.pro
;               get_3dp_structs.pro
;               add_magf2.pro
;               mom3d.pro
;               xyz_to_polar.pro
;               store_data.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               GET_DAT    :  Scalar [string] defining the 3DP detector from which to
;                               get data [e.g., 'el' for EESA Low]
;
;  EXAMPLES:    
;               [calling sequence]
;               get_moment3d,get_dat [,ERANGE=erange] [,NAME=name] [,TRANGE=trange]     $
;                                    [,DENS_NAME=dens_name] [,BKG=bkg]                  $
;                                    [,POT_NAME=pot_name] [,MAG_NAME=mag_name]          $
;                                    [,BINS=bins] [,EESALOW=eesalow] [,PROTONS=protons] $
;                                    [,ALPHAS=alphas] [,DATA=data] [,HEATF=heatf]
;
;               ;;  Example
;               get_moment3d,'plb',NAME='plb',TRANGE=tr3,MAG_NAME='wi_B3(GSE)'
;
;  KEYWORDS:    
;               ERANGE     :  Set to a 2-element array specifying the energy bins to use
;                               when calculating the particle moments
;               NAME       :  Set to a string defining the type of data (e.g. 'el')
;               TRANGE     :  Set to a 2-element double array in Unix times specifying
;                               the time range to get 3D data moments for
;               DENS_NAME  :  Set to a string TPLOT name associated with the density
;                               to use for calibrating the moment calculations
;               BKG        :  Defines the background estimates ???
;               POT_NAME   :  Set to a string TPLOT name associated with the spacecraft
;                               potential (eV) to use for calculating moments
;               MAG_NAME   :  Set to a string TPLOT name associated with the magnetic
;                               field to use when calculating moments
;               BINS       :  Set to a two element array defining the data bins to use
;               EESALOW    :  If set, program gets data from get_el.pro
;               PROTONS    :  If set, program gets data from get_pl.pro and assumes 
;                               counts represent only protons
;               ALPHAS     :  If set, program gets data from get_pl.pro and assumes
;                               counts represent alpha-particles (different mass
;                               estimates and charge estimates)
;               DATA       :  Set to a named variable program returns as an array
;                               of 3D data structures containing the moments
;               HEATF      :  If set, program calculates the heat flux for each moment
;
;   CHANGED:  1)  Davin Larson created
;                                                                   [??/??/????   v1.0.0]
;             2)  Added keyword HEATF
;                                                                   [09/14/2008   v1.0.1]
;             3)  Updated man page
;                                                                   [02/08/2009   v1.0.2]
;             2)  Changed functions called
;                                                                   [02/08/2009   v2.0.0]
;             4)  Did some minor "clean up"
;                                                                   [03/20/2009   v2.0.1]
;             5)  Updated man page
;                                                                   [06/17/2009   v2.1.0]
;             6)  Changed program my_3dp_str_call_2.pro to get_3dp_structs.pro
;                                                                   [09/24/2009   v2.2.0]
;             7)  Fixed an indexing bug and cleaned up
;                                                                   [09/26/2017   v2.2.1]
;             8)  Added error handling to avoid breaking when get_3dp_structs.pro returns
;                   either no structure or a bad structure
;                                                                   [11/25/2024   v2.2.2]
;
;   NOTES:      
;               NA
;
;  REFERENCES:  
;               NA
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  11/25/2024   v2.2.2
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO get_moment3d,   get_dat,              $
                    ERANGE    = er,       $
                    NAME      = name,     $
                    TRANGE    = trange,   $
                    DENS_NAME = dens_name,$
                    BKG       = bkg,      $
                    POT_NAME  = pot_name, $
                    MAG_NAME  = mag_name, $
                    BINS      = bins,     $
                    EESALOW   = eesalow,  $
                    PROTONS   = protons,  $
                    ALPHAS    = alphas,   $
                    DATA      = ds,       $
                    HEATF     = qf

;;****************************************************************************************
ex_start       = SYSTIME(1)
;;****************************************************************************************
f              = !VALUES.F_NAN
ions           = KEYWORD_SET(protons) OR KEYWORD_SET(alphas)
IF KEYWORD_SET(eesalow) THEN BEGIN
  IF NOT KEYWORD_SET(get_dat) THEN get_dat = 'el'
ENDIF
IF (ions AND NOT KEYWORD_SET(name)) THEN  get_dat = 'pl'

time           = CALL_FUNCTION('get_'+get_dat[0],/TIMES)
start_index    = 0L
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
IF KEYWORD_SET(trange) THEN BEGIN
  tr = minmax(trange)
  w  = WHERE(time GE tr[0] AND time LE tr[1],c)
  IF (c[0] GT 0) THEN time = time[w]
  start_index = w[0]
ENDIF
mx             = N_ELEMENTS(time)
IF NOT KEYWORD_SET(time) THEN BEGIN
  PRINT,"No data for ",get_dat[0]
  RETURN
ENDIF
IF KEYWORD_SET(eesalow) THEN BEGIN 
  IF KEYWORD_SET(dens_name) THEN dens = data_cut(dens_name,time)
  IF KEYWORD_SET(pot_name) THEN  pot  = data_cut(pot_name,time)
  IF (KEYWORD_SET(dens) EQ 0 and KEYWORD_SET(pot) EQ 0) THEN  comp = 1
  IF NOT KEYWORD_SET(name) THEN name = 'em'
ENDIF

IF (KEYWORD_SET(alphas) AND NOT KEYWORD_SET(name))  THEN name = 'am'
IF (KEYWORD_SET(protons) AND NOT KEYWORD_SET(name)) THEN name = 'pm'
;;----------------------------------------------------------------------------------------
;;  Get an empty data structure template
;;----------------------------------------------------------------------------------------
str_format     = moments_3d()
IF KEYWORD_SET(alphas) OR KEYWORD_SET(protons) THEN $
  str_element,str_format,'MXB',0,/ADD_REPLACE
IF KEYWORD_SET(qf) THEN BEGIN
  str_element,str_format,'QVEC',REPLICATE(f,3),/ADD_REPLACE
ENDIF
IF NOT KEYWORD_SET(mag_name) THEN mag_name = 'wi_B3(GSE)'
magf           = data_cut(mag_name,time)
IF NOT KEYWORD_SET(magf) THEN BEGIN
  magf = REPLICATE(f,mx,3)
  MESSAGE,/INFORMATION,'No Magnetic field data!'
ENDIF
ds             = REPLICATE(str_format[0],mx[0])
;;----------------------------------------------------------------------------------------
;;  Get 3D data structures
;;----------------------------------------------------------------------------------------
tdats          = get_3dp_structs(get_dat[0],TRANGE=trange)
IF (SIZE(tdats,/TYPE) NE 8) THEN BEGIN
  ;;  No 3DP VDFs (as IDL structures) were found --> Return
  MESSAGE,'No '+get_dat[0]+' VDFs were found...',/INFORMATION,/CONTINUE
  RETURN
ENDIF ELSE BEGIN
  ;;  If structure, check for proper tags
  tnms           = TAG_NAMES(tdats)
  IF (TOTAL(STRLOWCASE(tnms) EQ 'data') LE 0) THEN BEGIN
    ;;  Routine returned a structure but had bad tag names (shouldn't happen!)
    MESSAGE,'1:  No '+get_dat[0]+' VDFs were found...',/INFORMATION,/CONTINUE
    RETURN
  ENDIF
ENDELSE
;;  Define VDFs
tdat           = tdats.DATA
times          = tdats.TIMES
mynn           = N_ELEMENTS(tdat) < mx[0]
;;----------------------------------------------------------------------------------------
;;  Add B-field data to each structure
;;----------------------------------------------------------------------------------------
add_magf2,tdat,mag_name[0]
;;----------------------------------------------------------------------------------------
;;  Calc 3D moments from data structures
;;----------------------------------------------------------------------------------------
FOR n=0L, mynn[0] - 1L DO BEGIN
    dat = tdat[n]
    IF dat[0].VALID[0] THEN BEGIN
      IF ions[0] THEN BEGIN
        todat = TOTAL(dat.data,2)
        mx    = MAX(todat,mxb)
        IF KEYWORD_SET(protons) THEN er = [mxb[0] - 3L,13L] ELSE er = [0L,mxb[0] - 4L]
        IF KEYWORD_SET(alphas) THEN BEGIN
          dat.ENERGY *= 2e0
          dat.MASS   *= 4e0
;          dat.ENERGY = dat.ENERGY*2
;          dat.MASS   = dat.MASS*4
        ENDIF
      ENDIF
      IF KEYWORD_SET(pot)  THEN  pot_n = pot[n]  ELSE  pot_n = 0.
      IF KEYWORD_SET(dens) THEN dens_n = dens[n] ELSE dens_n = 0.
      ds[n] = moments_3d(dat,ERANGE=er,FORMAT=str_format, $
                         TRUE_DENS=dens_n,COMP=comp,BINS=bins)
      IF KEYWORD_SET(qf) THEN BEGIN
        temp       = mom3d(dat)
        qvec       = REFORM(temp.QVEC)
        ds[n].QVEC = qvec
;        str_element,ds[n],'QVEC',temp.QVEC,/ADD_REPLACE
      ENDIF
    ENDIF
ENDFOR
;*****************************************************************************************
;3dp> help, ds
;DS              STRUCT    = -> <Anonymous> Array[898]
;
;3dp> help, ds,/str
;** Structure <24a6890>, 23 tags, length=192, data length=186, refs=1:
;   TIME            DOUBLE       8.7644166e+08
;   SC_POT          FLOAT           5.72294
;   SC_CURRENT      FLOAT       1.97221e+09
;   MAGF            FLOAT     Array[3]
;   DENSITY         FLOAT           5.75944
;   AVGTEMP         FLOAT           13.3697
;   VTHERMAL        FLOAT           2168.63
;   VELOCITY        FLOAT     Array[3]
;   FLUX            FLOAT     Array[3]
;   PTENS           FLOAT     Array[6]
;   MFTENS          FLOAT     Array[6]
;   T3              FLOAT     Array[3]
;   SYMM            FLOAT     Array[3]
;   SYMM_THETA      FLOAT          -41.0259
;   SYMM_PHI        FLOAT           166.965
;   SYMM_ANG        FLOAT           8.95638
;   MAGT3           FLOAT     Array[3]
;   ERANGE          FLOAT     Array[2]
;   MASS            FLOAT       5.68566e-06
;   VALID           INT              1
;   VEL_MAG         FLOAT           439.503
;   VEL_TH          FLOAT         -0.819507
;   VEL_PHI         FLOAT           179.259
;*****************************************************************************************
PRINT," number of data points = ",n
xyz_to_polar,TRANSPOSE(ds.velocity),MAG=mag,THETA=th,PHI=phi,/PH_0_360
str_element,ds,'VEL_MAG',mag,/ADD_REPLACE
str_element,ds,'VEL_TH',th,/ADD_REPLACE
str_element,ds,'VEL_PHI',phi,/ADD_REPLACE
IF KEYWORD_SET(protons) THEN BEGIN
  vth_v  = ds.VTHERMAL/ds.VEL_MAG
  vth_v2 = SQRT(vth_v^2 - .055^2)
  vth2   = vth_v2 * ds.VEL_MAG
  temp2  = 0.5 * dat.MASS * vth2^2
  str_element,ds,'TEMP2',temp2,/ADD_REPLACE
ENDIF
IF KEYWORD_SET(er) THEN comment = STRING('Energy range: ',er) $
                   ELSE comment = 'Full energy range'
IF NOT KEYWORD_SET(name) THEN name = get_dat+'_mom'
store_data,name,DATA=ds,DLIM={comment:comment}
;;****************************************************************************************
ex_time        = SYSTIME(1) - ex_start[0]
MESSAGE,STRING(ex_time[0])+' seconds execution time.',/CONTINUE,/INFOR
;;****************************************************************************************
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END
