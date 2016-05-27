;+
;*****************************************************************************************
;
;  FUNCTION :   distfunc_template.pro
;  PURPOSE  :   Create a dummy distribution function structure or array to prevent
;                 the code from breaking upon multiple callings of the program
;                 my_distfunc.pro.  The returned structure is template which
;                 can be used as a reference or an empty structure for
;                 error handling.
;
;  CALLED BY:  
;               distfunc.pro
;
;  CALLS:
;               velocity.pro
;
;  REQUIRES:    NA
;
;  INPUT:
;               VPAR     :  An array of data corresponding to either the energy or 
;                             parallel(wrt B-field) velocity associated with the data
;               VPERP    :  An array of data corresponding to either the angle or the
;                             perpendicular velocity associated with the data
;
;  EXAMPLES:
;               test    = distfunc(dat.ENERGY,dat.ANGLE,MASS=dat.MASS,DF=dat.DATA)
;               test    = distfunc(vpar,vperp,PARAM=dfpar) 
;               
;               df_temp = distfunc_template(vpar,vperp,PARAM=dfpar)
;               dfpar   = distfunc(vx0,vy0,df=df0)   
;                   => Create structure dfpar using values of df0 known at the 
;                         positions of vx0,vy0 as a structure
;               df_new  = distfunc(vx_new,vy_new,par=dfpar)   
;                   => returns interpolated values of df at the new points as an array
;
;  KEYWORDS:  
;               DF       :  [float] Array of data from my_pad_dist.pro
;               PARAM    :  A 3D data structure with the tag names VX0, VY0, and DFC
;               MASS     :  [float] Value representing the mass of particles for the
;                             distribution of interest [eV/(km/sec)^2]
;
;   CHANGED:  1)  Fixed syntax error                   [07/10/2008   v1.0.1]
;             2)  Updated man page                     [02/25/2009   v1.0.2]
;             3)  Changed return values and robustness [02/25/2009   v1.0.3]
;             4)  Updated man page                     [06/22/2009   v1.0.4]
;             5)  Changed name from my_distfunc_template.pro to distfunc_template.pro
;                                                      [07/20/2009   v1.1.0]
;
;   ADAPTED FROM: distfunc.pro  BY: Davin Larson
;   CREATED:  02/05/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  07/20/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION distfunc_template,vpar,vperp,DF=df,PARAM=dfpar,MASS=mass

IF KEYWORD_SET(mass) THEN BEGIN
   vx = velocity(vpar,mass) * COS(vperp*!DTOR)
   vy = velocity(vpar,mass) * SIN(vperp*!DTOR)
ENDIF ELSE BEGIN
   vx = vpar
   vy = vperp
ENDELSE

IF KEYWORD_SET(df) THEN BEGIN
  vx01 = REPLICATE(-0.0145,500)  ; -forces all arrays to be of the same size
  vy01 = REPLICATE(-0.0145,500)  ; - to prevent "Conflicting Data Str.'s"
  dfc1 = REPLICATE(-0.0145,500)
  mystr = CREATE_STRUCT('VX0',vx01,'VY0',vy01,'DFC',dfc1)
  RETURN,mystr
ENDIF
;*****************************************************************************
; - prior use of my_distfunc.pro may have produced extra array elements with
;    values of -0.0145 which was a unique value chosen to mark "empty" 
;    data elements for later removal to avoid "Conflicting Data Structures"
;    errors
; - It is also important to remove non-finite quantities to avoid 
;    "Infinite Plot Range" errors in the calculation of a new distribution
;    function
;
; - Use 500 elements because typically num_pa = 17 in my_pad_dist.pro for 
;    creating contour plots from my_cont2d.pro.  So 15 energy bins times
;    17 pitch-angles equals 255.
;*****************************************************************************
IF KEYWORD_SET(dfpar) THEN BEGIN
  vx0  = REPLICATE(!VALUES.F_NAN,500)
  vy0  = REPLICATE(!VALUES.F_NAN,500)
  c    = REPLICATE(!VALUES.F_NAN,500)
  n    = N_ELEMENTS(vx0)
  nc   = N_ELEMENTS(c)
  divx = SIZE(vx,/DIMENSIONS)
  nivx = N_ELEMENTS(divx)
  IF (nivx EQ 2L) THEN BEGIN
    s  = REPLICATE(!VALUES.F_NAN,divx[0],divx[1])
  ENDIF ELSE BEGIN
    n2 = 2L*n + 1L
    s  = REPLICATE(!VALUES.F_NAN,n2,n2)
  ENDELSE
  RETURN,s
ENDIF
END
