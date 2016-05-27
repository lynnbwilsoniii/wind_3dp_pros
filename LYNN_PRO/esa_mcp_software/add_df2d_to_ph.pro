;+
;*****************************************************************************************
;
;  FUNCTION :   add_df2d_to_ph.pro
;  PURPOSE  :   Calculates an estimate of the reduced distribution function and adds
;                 the tags to the input data structure.
;
;  CALLED BY:   NA
;
;  CALLS:
;               dat_3dp_str_names.pro
;               cart_to_sphere.pro
;               cal_rot.pro
;               str_element.pro
;               data_velocity_transform.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               DAT        :  3DP data structure either from get_eh.pro etc.
;
;  EXAMPLES:
;
;  KEYWORDS:  
;               VLIM       :  Limit for x-y velocity axes over which to plot data
;                               [Default = max vel. from energy bin values]
;               NGRID      :  # of isotropic velocity grids to use to triangulate the data
;                               [Default = 50L]
;               VBROT      :  Set to a named variable to return the rotation matrix used to
;                               rotate the velocities into the Vector1 x Vector2 plane
;               VECTOR1    :  3-Element vector to be used for parallel axis 
;                               [Default = dat.MAGF or Magnetic Field Vector]
;               VECTOR2    :  3-Element vector to be used to define the plane made with 
;                               VECTOR1  [Default = dat.VSW or Solar Wind Velocity]
;               NSMOOTH    :  Scalar # of points over which to smooth the DF
;                               [Default = 3]
;               VXB_PLANE  :  If set, tells program to plot the DF in the plane defined
;                               by the (V x B) and B x (V x B) directions
;                               [Default:  plane defined by V and B directions set by
;                                           VSW and MAGF structure tags of DAT]
;               NOKILL_PH  :  If set, data_velocity_transform.pro will not call
;                               pesa_high_bad_bins.pro
;               NO_REDF    :  If set, program will plot only cuts of the distribution,
;                               not quasi-reduced distributions
;                               [Note:  this option is only passed to 
;                                 data_velocity_transform.pro, it is not used here]
;
;   CHANGED:  1)  Added tag name BDIR to output structure     [03/25/2009   v1.0.1]
;             2)  Fixed syntax error with vel2dx variable     [03/25/2009   v1.0.2]
;             3)  Added keyword:  VBROT and changed default # of grids
;                                                             [03/26/2009   v1.0.3]
;             4)  Changed the triangulation points            [04/08/2009   v1.0.4]
;             5)  Changed tags added to structure to include actual points where
;                   data was calculated for house keeping and honesty
;                                                             [04/08/2009   v1.0.5]
;             6)  Changed bad bin indexing                    [04/08/2009   v1.0.6]
;             7)  Fixed "glitch" with 56 bin PH structures    [04/08/2009   v1.0.7]
;             8)  Changed bad bin indexing to include the "mirror" bins of the original
;                   bad data bins                             [04/16/2009   v1.0.8]
;             9)  Fixed "glitch" with 97 bin PH structures    [04/26/2009   v1.0.9]
;            10)  Added program:  my_pesa_high_bad_bins.pro   [04/26/2009   v1.1.0]
;            11)  Eliminated the statements that removed the thermal core for 
;                   the distribution cuts (parallel/perp.) and changed calling of
;                   my_velocity.pro to velocity.pro           [06/21/2009   v1.1.1]
;            12)  Added keywords:  VECTOR1 and VECTOR2        [06/24/2009   v1.2.0]
;            13)  Added program:  data_velocity_transform.pro [06/24/2009   v2.0.0]
;            14)  Changed program my_str_names.pro to dat_3dp_str_names.pro
;                                                             [08/05/2009   v2.1.0]
;            15)  Updated man page                            [08/07/2009   v2.1.1]
;            16)  Updated man page                            [08/10/2009   v2.1.2]
;            17)  Added keyword:  NSMOOTH                     [08/27/2009   v2.1.3]
;            18)  Changed minor syntax issue                  [08/31/2009   v2.1.4]
;            19)  Added error handling to deal with situations where dat.VSW or
;                   dat.MAGF were either all = 0.0 or = !VALUES.F_NAN
;                                                             [09/23/2009   v2.1.5]
;            20)  Added keyword:  VXB_PLANE                   [03/03/2010   v2.2.0]
;            21)  Added keyword:  NOKILL_PH                   [01/13/2012   v2.3.0]
;            22)  Added keyword:  NO_REDF                     [01/27/2012   v2.4.0]
;
;   NOTES:      
;               1)  Make sure that the structure tags MAGF and VSW have finite 
;                    values
;               2)  This program is adapted from software by K. Meziane
;
;   CREATED:  03/24/2009
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/27/2012   v2.4.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO add_df2d_to_ph,dat,VLIM=vlim,NGRID=ngrid,VBROT=vbrot,NSMOOTH=nsmooth,$
                       VECTOR1=vector1,VECTOR2=vector2,VXB_PLANE=vxbplane,$
                       NOKILL_PH=nokill_ph,NO_REDF=no_redf

;-----------------------------------------------------------------------------------------
; => Determine default parameters
;-----------------------------------------------------------------------------------------
f     = !VALUES.F_NAN
d     = !VALUES.D_NAN
radd  = !PI/18e1
twph  = dat
IF NOT KEYWORD_SET(ngrid) THEN ngrid = 20L
IF NOT KEYWORD_SET(vlim) THEN BEGIN
  vlim = MAX(SQRT(2*dat.ENERGY/dat.MASS),/NAN)
ENDIF ELSE BEGIN
  vlim = FLOAT(vlim)
ENDELSE
xylim  = [-1*vlim,-1*vlim,vlim,vlim]
dgs    = vlim/5e1
;gs     = [vlim,vlim]/ngrid
;gs     = [vlim,vlim]/dgs
gs     = [dgs,dgs]
index  = twph.INDEX
nbins  = twph.NBINS
nener  = twph.NENERGY
strn   = dat_3dp_str_names(twph)
sname  = STRMID(strn.SN,0L,2L)

IF KEYWORD_SET(vxbplane) THEN vxbp = 1 ELSE vxbp = 0
;-----------------------------------------------------------------------------------------
; => Get B-field data and rotate into spherical coordinates
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(vector1) THEN BEGIN
  vec1  = twph.MAGF
  addv1 = 0           ; => Logic variable for adding extra tag to structure
ENDIF ELSE BEGIN
  vec1  = REFORM(vector1)
  addv1 = 1
ENDELSE

IF NOT KEYWORD_SET(vector2) THEN BEGIN
  vec2  = twph.VSW 
  addv2 = 1
ENDIF ELSE BEGIN
  vec2  = REFORM(vector2)
  addv2 = 1
ENDELSE
;-----------------------------------------------------------------------------------------
; => Define B-field and solar wind velocities
;-----------------------------------------------------------------------------------------
vsw     = twph.VSW
bgse    = twph.MAGF
; => Check to make sure Vsw is defined!
goodvsw = WHERE(FINITE(vsw) AND ABS(vsw) GT 0e0,gdvsw)
IF (gdvsw EQ 0) THEN vsw = [-1e0,0e0,0e0]
; => Check to make sure Magf is defined!
goodmag = WHERE(FINITE(bgse) AND ABS(bgse) GT 0e0,gdmag)
IF (gdmag EQ 0) THEN bgse = [1e0,1e0,0e0]/ SQRT(2e0)

cart_to_sphere,bgse[0],bgse[1],bgse[2],rr,the,phi
bdir = [the,phi]   ; => B-field direction (deg)
str_element,dat,'BDIR',bdir,/ADD_REPLACE
bth  = bdir[0]*radd
bph  = bdir[1]*radd
bb   = [COS(bth)*COS(bph),COS(bth)*SIN(bph),SIN(bth)]

IF (addv1) THEN BEGIN
  cart_to_sphere,vec1[0],vec1[1],vec1[2],rr,the_v1,phi_v1
  v1_dir    = [the_v1,phi_v1]
  str_element,dat,'VEC1_DIR',v1_dir,/ADD_REPLACE
  vrot_1b   = cal_rot(vec1,bb)        ; => Rotation for Vec1 and B-field
  vrot_1vsw = cal_rot(vec1,vsw)       ; => Rotation for Vec1 and Vsw
  bv1_2d    = REFORM(bgse # vrot_1b)
  vswv1_2d  = REFORM(vsw # vrot_1vsw)
  str_element,dat,'BxVec1_ROT_MAT',vrot_1b,/ADD_REPLACE
  str_element,dat,'VswxVec1_ROT_MAT',vrot_1vsw,/ADD_REPLACE
ENDIF
IF (addv2) THEN BEGIN
  cart_to_sphere,vec2[0],vec2[1],vec2[2],rr,the_v2,phi_v2
  v2_dir = [the_v2,phi_v2]
  str_element,dat,'VEC2_DIR',v2_dir,/ADD_REPLACE
  vrot_2b   = cal_rot(vec2,bb)        ; => Rotation for Vec2 and B-field
  vrot_2vsw = cal_rot(vec2,vsw)       ; => Rotation for Vec2 and Vsw
  bv2_2d    = REFORM(bgse # vrot_2b)
  vswv2_2d  = REFORM(vsw # vrot_2vsw)
  str_element,dat,'BxVec2_ROT_MAT',vrot_2b,/ADD_REPLACE
  str_element,dat,'VswxVec2_ROT_MAT',vrot_2vsw,/ADD_REPLACE
ENDIF
IF (addv1 AND addv2) THEN BEGIN
  vrot_12   = cal_rot(vec1,vec2)        ; => Rotation for Vec1 and Vec2
  bv12_2d   = REFORM(bgse # vrot_12)
  vswv12_2d = REFORM(vsw # vrot_12)
  str_element,dat,'Vec1xVec2_ROT_MAT',vrot_12,/ADD_REPLACE
  str_element,dat,'Vec1xVec2_B_2D',bv12_2d,/ADD_REPLACE
  str_element,dat,'Vec1xVec2_Vsw_2D',vswv12_2d,/ADD_REPLACE
ENDIF
;-----------------------------------------------------------------------------------------
; => Rotate everything in new X'-Y' Plane where X' // bb
;-----------------------------------------------------------------------------------------
IF (vxbp EQ 0) THEN BEGIN
  mrot         = cal_rot(bb,vsw)
ENDIF ELSE BEGIN
  unit_magf    = bb
  unit_vsw     = vsw/(SQRT(TOTAL(vsw^2,/NAN)))[0]
  V_cross_B    = my_crossp_2(vsw,unit_magf,/NOMSSG)
  ; => renormalize
  V_cross_Bn   = V_cross_B/(SQRT(TOTAL(V_cross_B^2,/NAN)))[0]
  B_cross_VxB  = my_crossp_2(unit_magf,V_cross_B,/NOMSSG)
  ; => renormalize
  B_cross_VxBn = B_cross_VxB/(SQRT(TOTAL(B_cross_VxB^2,/NAN)))[0]
  mrot         = cal_rot(V_cross_Bn,B_cross_VxBn)
ENDELSE

vd2d  = REFORM(vsw # mrot)  ; => 2D projection of Vsw onto plane of B-field
vbrot = mrot
;-----------------------------------------------------------------------------------------
; => Lower and try to remove Vsw "noise"
;-----------------------------------------------------------------------------------------
cart_to_sphere,vsw[0],vsw[1],vsw[2],rr,the,phi,PH_0_360=1
vdir = [the,phi]
str_element,dat,'VSW_DIR',vdir,/ADD_REPLACE
philh   = [phi - 30., phi + 30.]
thelh   = [the - 30., the + 30.]

ttheta  = twph.THETA
tphi    = twph.PHI
vsw_bad = WHERE(ttheta GE thelh[0] AND ttheta LE thelh[1] AND $
                tphi GE philh[0] AND tphi LE philh[1],v_bad)
IF (v_bad GT 0L AND sname[0] EQ 'ph') THEN BEGIN
  vind = ARRAY_INDICES(tphi,vsw_bad)
  bad_vdat = REFORM(twph.DATA[vind[0,*],vind[1,*]])
  l_b_vdat = WHERE(bad_vdat GE 6.,l_b)
  IF (l_b GT 0L) THEN bad_vdat[l_b_vdat] *= 1e0/6e0
  twph.DATA[vind[0,*],vind[1,*]] = bad_vdat
ENDIF

new_3dp = data_velocity_transform(twph,VLIM=vlim,NGRID=ngrid,ROT_MAT=mrot,NSMOOTH=nsmooth,$
                                  NOKILL_PH=nokill_ph,NO_REDF=no_redf)

dat     = new_3dp
str_element,dat,'VxB_2D',vd2d,/ADD_REPLACE        ; => ** Used to be 'VD2D' **
str_element,dat,'VxB_ROT_MAT',mrot,/ADD_REPLACE   ; => Rotation Matrix to plane of VxB
;-----------------------------------------------------------------------------------------
; => Return altered structure to user
;-----------------------------------------------------------------------------------------

RETURN
END