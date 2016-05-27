;+
;*****************************************************************************************
;
;  FUNCTION :   mom_translate.pro
;  PURPOSE  :   This program translates structure data into center of momentum frame
;                 unless a specific velocity is set, then it translates into that
;                 center of velocity frame.
;
;  CALLED BY: 
;               mom3d.pro
;
;  CALLS:       NA
;
;  REQUIRES:    NA
;
;  INPUT:
;               M     :  A 3D moment structure created by my_mom_sum.pro
;
;  EXAMPLES:    NA
;
;  KEYWORDS:  
;               MVEL  :  3-Element velocity vector used to translate from the center
;                          of momentum frame to another frame of reference [eV^(1/2)]
;
;   CHANGED:  1)  Davin Larson created                    [??/??/????   v1.0.0]
;             2)  Did some minor "clean up"               [04/06/2008   v1.0.1]
;             3)  Re-wrote and cleaned up                 [04/13/2009   v1.1.0]
;             4)  Updated man page                        [06/17/2009   v1.1.1]
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  06/17/2009   v1.1.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION mom_translate, m, mvel

mxm = m.MAXMOMENT
mom = m
IF (mom.N LE 0) THEN RETURN,mom
IF (mxm LE 0) THEN GOTO,skipahead

v   = mom.NV/mom.N    ; => Velocity [eV^(1/2)]
;-----------------------------------------------------------------------------------------
; =>Rank 1  [km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
mom.NV = 0                         ; = mom.NV -  mom.N * v  => Flux [km/s cm^(-3)]
IF (mxm LE 1) THEN GOTO,skipahead
;-----------------------------------------------------------------------------------------
; =>Rank 2  [eV^(1/2) km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
mt      = mom.NVV[mom.MAP_R2]     ; => [eV^(1/2) km/s cm^(-3)]
pt      = mt - mom.N*(v # v)
mom.NVV = pt[mom.MAP_V2]          ; => [eV^(1/2) km/s cm^(-3)]
IF (mxm LE 2) THEN GOTO,skipahead
;-----------------------------------------------------------------------------------------
; =>Rank 3  [eV km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
nvvv     = mom.NVVV[mom.MAP_R3]
up0      = REFORM(REFORM(pt,9) # v,3,3,3)
up1      = TRANSPOSE(up0,[1,2,0])
up2      = TRANSPOSE(up0,[2,0,1])
nuuu     = mom.N * REFORM(REFORM(v#v,9) # v,3,3,3)
qt       = nvvv - (up0 + up1 + up2 + nuuu)
mom.NVVV = qt[mom.MAP_V3]
IF (mxm LE 3) THEN GOTO,skipahead
;-----------------------------------------------------------------------------------------
; =>Rank 4  [eV^(3/2) km/s cm^(-3)]
;-----------------------------------------------------------------------------------------
Rf        = mom.NVVVV[mom.MAP_R4]
vv        = REFORM(v#v,9)
uq0       = REFORM(REFORM(qt,27) # v,3,3,3,3)
uq1       = TRANSPOSE(uq0,[1,2,3,0])
uq2       = TRANSPOSE(uq0,[2,3,0,1])
uq3       = TRANSPOSE(uq0,[3,0,1,2])
uup0      = REFORM((vv # REFORM(pt,9)),3,3,3,3)
uup1      = TRANSPOSE(uup0,[0,2,1,3])
uup2      = TRANSPOSE(uup0,[0,3,1,2])
uup3      = TRANSPOSE(uup0,[1,2,0,3])
uup4      = TRANSPOSE(uup0,[1,3,0,2])
uup5      = TRANSPOSE(uup0,[2,3,0,1])
nuuuu     = mom.N * REFORM((vv # vv),3,3,3,3)
r         = Rf - (uq0+uq1+uq2+uq3 + uup0+uup1+uup2+uup3+uup4+uup5 + nuuuu)
mom.NVVVV = r[mom.MAP_V4]
;-----------------------------------------------------------------------------------------
skipahead:
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(mvel) THEN BEGIN   ; =>Translate from center of mom. to another frame
  v      = mvel - v
  mom.NV = mom.N * v              ; => [km/s cm^(-3)]
  IF (mxm LE 1) THEN RETURN,mom
  
  mt      = pt + mom.N*(v # v)
  mom.NVV = mt[mom.MAP_V2]        ; => [eV^(1/2) km/s cm^(-3)]
  IF (mxm LE 2) THEN RETURN,mom
 
  vv       = REFORM(v#v,9)
  up0      = REFORM(REFORM(pt,9) # v,3,3,3)
  up1      = TRANSPOSE(up0,[1,2,0])
  up2      = TRANSPOSE(up0,[2,0,1])
  nuuu     = mom.n * REFORM( vv # v,3,3,3)
  hft      = qt + (up0 + up1 + up2 + nuuu)
  mom.NVVV = hft[mom.MAP_V3]      ; => [eV km/s cm^(-3)]
  IF (mxm LE 3) THEN RETURN,mom
  
  uq0       = REFORM((REFORM(qt,27) # v),3,3,3,3)
  uq1       = TRANSPOSE(uq0,[1,2,3,0])
  uq2       = TRANSPOSE(uq0,[2,3,0,1])
  uq3       = TRANSPOSE(uq0,[3,0,1,2])
  uup0      = REFORM( vv # REFORM(pt,9) , 3,3,3,3)
  uup1      = TRANSPOSE(uup0,[0,2,1,3])
  uup2      = TRANSPOSE(uup0,[0,3,1,2])
  uup3      = TRANSPOSE(uup0,[1,2,0,3])
  uup4      = TRANSPOSE(uup0,[1,3,0,2])
  uup5      = TRANSPOSE(uup0,[2,3,0,1])
  nuuuu     = mom.N * REFORM( vv # vv , 3,3,3,3)
  Rf        = r + (uq0+uq1+uq2+uq3 + uup0+uup1+uup2+uup3+uup4+uup5 + nuuuu)
  mom.nvvvv = Rf[mom.map_v4]      ; => [eV^(3/2) km/s cm^(-3)]
ENDIF
  
RETURN,mom
END