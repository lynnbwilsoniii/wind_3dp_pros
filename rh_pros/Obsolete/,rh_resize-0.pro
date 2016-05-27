;+
;*****************************************************************************************
;
;  FUNCTION :   rh_resize.pro
;  PURPOSE  :   This routine forces the input parameters to have the correct array size/
;                 number of elements for use in other routines.
;
;  CALLED BY:   
;               rh_solve_lmq.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;               IDL> n = 10
;               IDL> x = DINDGEN(2,3,n)
;               IDL> rh_resize,MAG=x,NPTS=nx
;               IDL> PRINT,';',nx
;               ;          10
;               IDL> HELP,x
;               X               DOUBLE    = Array[10, 3, 2]
;
;  KEYWORDS:    
;               RHO     :  [N,2]-Element [up,down] array corresponding to the number
;                            density [cm^(-3)]
;               VSW     :  [N,3,2]-Element [up,down] array corresponding to the solar
;                            wind velocity vectors [SC-frame, km/s]
;               MAG     :  [N,3,2]-Element [up,down] array corresponding to the ambient
;                            magnetic field vectors [nT]
;               TOT     :  [N,2]-Element [up,down] array corresponding to the total
;                            plasma temperature [eV]
;               NOR     :  [M,3]-Element unit normal vectors
;               VSH     :  [N,M]-Element array shock normal speeds in SC-frame
;               NPTS    :  Set to a named variable to return the # of data points
;                            entered
;               MNOR    :  Set to a named variable to return the # of shock normal
;                            vectors entered
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Definition of dimensions:
;                     N  :  # of data pairs on either side of shock ramp
;                     M  :  # of artificial shock normal vectors generated to create
;                             chi-squared map
;               2)  SC-Frame  :  Spacecraft Frame of Reference
;               3)  When using the VSH keyword, make sure to set either NPTS or MNOR
;                     keyword so that the routines knows what the appropriate elements
;                     are and what order they should be in
;
;   CREATED:  09/10/2011
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/10/2011   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO rh_resize,RHO=rho,VSW=vsw,MAG=mag,TOT=tot,NOR=nor,VSH=vsh,NPTS=npts,MNOR=mnor

;-----------------------------------------------------------------------------------------
; => Define dummy variables
;-----------------------------------------------------------------------------------------
f          = !VALUES.F_NAN
d          = !VALUES.D_NAN
;-----------------------------------------------------------------------------------------
; => Check input
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(rho) THEN gden = 1 ELSE gden = 0
IF KEYWORD_SET(vsw) THEN gvsw = 1 ELSE gvsw = 0
IF KEYWORD_SET(mag) THEN gmag = 1 ELSE gmag = 0
IF KEYWORD_SET(tot) THEN gtot = 1 ELSE gtot = 0
IF KEYWORD_SET(nor) THEN gnor = 1 ELSE gnor = 0
IF KEYWORD_SET(vsh) THEN gvsh = 1 ELSE gvsh = 0

check      = TOTAL([gden,gvsw,gmag,gtot,gnor,gvsh]) NE 1
IF (check) THEN BEGIN
  errmsg = 'Incorrect keyword use:  set only ONE keyword at a time!'
  MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
  npts   = d
  RETURN
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine which parameter to resize
;-----------------------------------------------------------------------------------------
good       = WHERE([gden,gvsw,gmag,gtot,gnor,gvsh],gd)
CASE good[0] OF
  0L   : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Density                             :  [N,2]-Element array
    ;-------------------------------------------------------------------------------------
    ni         = REFORM(rho)
    sz         = SIZE(ni,/DIMENSIONS)
    ; => Check # of dimensions
    IF (N_ELEMENTS(sz) EQ 1) THEN BEGIN
      ;-----------------------------------------------------------------------------------
      ; => One-Dimension
      ;-----------------------------------------------------------------------------------
      IF (sz[0] NE 2) THEN BEGIN
        npts = d
        RETURN
      ENDIF
      npts  = 1
      rho   = REFORM(ni,1,2)
    ENDIF ELSE BEGIN
      IF (N_ELEMENTS(sz) GT 2) THEN BEGIN
        npts   = d
        errmsg = 'Keyword RHO has too many dimensions!'
        MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
        RETURN
      ENDIF
      ;-----------------------------------------------------------------------------------
      ; => Multiple Dimensions               :  [N,2]-Element array
      ;-----------------------------------------------------------------------------------
      gzzd  = WHERE(sz EQ 2,gz)
      test  = (N_ELEMENTS(sz) NE 2) OR (gz EQ 0)
      IF (test) THEN BEGIN
        npts = d
        RETURN
      ENDIF
      IF (gzzd[0] EQ 1) THEN rho  = rho   ELSE rho  = TRANSPOSE(rho)
      IF (gzzd[0] EQ 1) THEN npts = sz[0] ELSE npts = sz[1]
    ENDELSE
    ;---------------
    ; => Return
    ;---------------
    RETURN
  END
  1L   : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Solar Wind Velocity                 :  [N,3,2]-Element array
    ;-------------------------------------------------------------------------------------
    vo         = REFORM(vsw)
    sz         = SIZE(vo,/DIMENSIONS)
    ; => Check # of dimensions
    IF (N_ELEMENTS(sz) LE 2) THEN BEGIN
      IF (N_ELEMENTS(sz) EQ 1) THEN BEGIN
        ;---------------------------------------------------------------------------------
        ; => One-Dimension                   :  BAD
        ;---------------------------------------------------------------------------------
        npts = d
        RETURN
      ENDIF ELSE BEGIN
        ;---------------------------------------------------------------------------------
        ; => Two-Dimensions                  :  [3,2]- or [2,3]-Element array
        ;---------------------------------------------------------------------------------
        gz2d  = WHERE(sz EQ 2,gz2)
        gz3d  = WHERE(sz EQ 3,gz3)
        test  = (gz2 EQ 0) OR (gz3 EQ 0)
        IF (test) THEN BEGIN
          npts = d
          RETURN
        ENDIF
        IF (gz2d[0] EQ 1) THEN vsw  = vsw   ELSE vsw  = TRANSPOSE(vsw)
        ; => Now vector is an [3,2]-Element array, so reform to a [1,3,2]-Element array
        vsw   = REFORM(vsw,1,3,2)
        npts  = 1
      ENDELSE
    ENDIF ELSE BEGIN
      ;-----------------------------------------------------------------------------------
      ; => Multiple Dimensions               :  [N,3,2]-Element array
      ;-----------------------------------------------------------------------------------
      IF (N_ELEMENTS(sz) GT 3) THEN BEGIN
        npts   = d
        errmsg = 'Keyword VSW has too many dimensions!'
        MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
        RETURN
      ENDIF
      gz2d  = WHERE(sz EQ 2,gz2)
      gz3d  = WHERE(sz EQ 3,gz3)
      test  = (N_ELEMENTS(sz) NE 3) OR (gz2 EQ 0) OR (gz3 EQ 0)
      IF (test) THEN BEGIN
        npts = d
        RETURN
      ENDIF
      ; => Check to see if N = 2
      IF (gz2 GT 1) THEN BEGIN
        IF (gz3d[0] EQ 1) THEN BEGIN
          ; => Assume : [N,3,2]
          npts   = sz[0]
          vsw    = vsw
        ENDIF ELSE BEGIN
          ; => Too many possibilities...
          errmsg = 'Enter more than 2 data pairs...'
          MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
          npts   = d
          RETURN
        ENDELSE
      ENDIF ELSE BEGIN
        IF (gz3d[0] NE 1 OR gz2d[0] NE 2) THEN BEGIN
          ; => Need to reform 
          ;      Possible permutations :
          ;                                [N,3,2] => Nothing...
          ;                                [N,2,3] => TRANSPOSE(v,[0,2,1])
          IF (gz2d[0] EQ 1 AND gz3d[0] EQ 2) THEN tran = [0,2,1]
          ;                                [2,N,3] => TRANSPOSE(v,[1,2,0])
          IF (gz2d[0] EQ 0 AND gz3d[0] EQ 2) THEN tran = [1,2,0]
          ;                                [2,3,N] => TRANSPOSE(v,[2,1,0])
          IF (gz2d[0] EQ 0 AND gz3d[0] EQ 1) THEN tran = [2,1,0]
          ;                                [3,N,2] => TRANSPOSE(v,[1,0,2])
          IF (gz2d[0] EQ 2 AND gz3d[0] EQ 0) THEN tran = [1,0,2]
          ;                                [3,2,N] => TRANSPOSE(v,[2,0,1])
          IF (gz2d[0] EQ 1 AND gz3d[0] EQ 0) THEN tran = [2,0,1]
          ; => Transpose vector
          vsw    = TRANSPOSE(vsw,tran)
          npts   = N_ELEMENTS(vsw[*,0,0])
        ENDIF ELSE BEGIN
          ; => Input entered correctly
          npts   = sz[0]
          vsw    = vsw
        ENDELSE
      ENDELSE
    ENDELSE
    ;---------------
    ; => Return
    ;---------------
    RETURN
  END
  2L   : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Ambient Magnetic Field              :  [N,3,2]-Element array
    ;-------------------------------------------------------------------------------------
    bo         = REFORM(mag)
    sz         = SIZE(bo,/DIMENSIONS)
    ; => Check # of dimensions
    IF (N_ELEMENTS(sz) LE 2) THEN BEGIN
      IF (N_ELEMENTS(sz) EQ 1) THEN BEGIN
        ;---------------------------------------------------------------------------------
        ; => One-Dimension                   :  BAD
        ;---------------------------------------------------------------------------------
        npts = d
        RETURN
      ENDIF ELSE BEGIN
        ;---------------------------------------------------------------------------------
        ; => Two-Dimensions                  :  [3,2]- or [2,3]-Element array
        ;---------------------------------------------------------------------------------
        gz2d  = WHERE(sz EQ 2,gz2)
        gz3d  = WHERE(sz EQ 3,gz3)
        test  = (gz2 EQ 0) OR (gz3 EQ 0)
        IF (test) THEN BEGIN
          npts = d
          RETURN
        ENDIF
        IF (gz2d[0] EQ 1) THEN mag  = mag   ELSE mag  = TRANSPOSE(mag)
        npts  = 1
        ; => Now vector is an [3,2]-Element array, so reform to a [1,3,2]-Element array
        mag   = REFORM(mag,1,3,2)
      ENDELSE
    ENDIF ELSE BEGIN
      ;-----------------------------------------------------------------------------------
      ; => Multiple Dimensions               :  [N,3,2]-Element array
      ;-----------------------------------------------------------------------------------
      IF (N_ELEMENTS(sz) GT 3) THEN BEGIN
        npts   = d
        errmsg = 'Keyword MAG has too many dimensions!'
        MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
        RETURN
      ENDIF
      gz2d  = WHERE(sz EQ 2,gz2)
      gz3d  = WHERE(sz EQ 3,gz3)
      test  = (N_ELEMENTS(sz) NE 3) OR (gz2 EQ 0) OR (gz3 EQ 0)
      IF (test) THEN BEGIN
        npts = d
        RETURN
      ENDIF
      ; => Check to see if N = 2
      IF (gz2 GT 1) THEN BEGIN
        IF (gz3d[0] EQ 1) THEN BEGIN
          ; => Assume : [N,3,2]
          npts   = sz[0]
          mag    = mag
        ENDIF ELSE BEGIN
          ; => Too many possibilities...
          errmsg = 'Enter more than 2 data pairs...'
          MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
          npts   = d
          RETURN
        ENDELSE
      ENDIF ELSE BEGIN
        IF (gz3d[0] NE 1 OR gz2d[0] NE 2) THEN BEGIN
          ; => Need to reform 
          ;      Possible permutations :
          ;                                [N,3,2] => Nothing...
          ;                                [N,2,3] => TRANSPOSE(v,[0,2,1])
          IF (gz2d[0] EQ 1 AND gz3d[0] EQ 2) THEN tran = [0,2,1]
          ;                                [2,N,3] => TRANSPOSE(v,[1,2,0])
          IF (gz2d[0] EQ 0 AND gz3d[0] EQ 2) THEN tran = [1,2,0]
          ;                                [2,3,N] => TRANSPOSE(v,[2,1,0])
          IF (gz2d[0] EQ 0 AND gz3d[0] EQ 1) THEN tran = [2,1,0]
          ;                                [3,N,2] => TRANSPOSE(v,[1,0,2])
          IF (gz2d[0] EQ 2 AND gz3d[0] EQ 0) THEN tran = [1,0,2]
          ;                                [3,2,N] => TRANSPOSE(v,[2,0,1])
          IF (gz2d[0] EQ 1 AND gz3d[0] EQ 0) THEN tran = [2,0,1]
          ; => Transpose vector
          mag    = TRANSPOSE(mag,tran)
          npts   = N_ELEMENTS(mag[*,0,0])
        ENDIF ELSE BEGIN
          ; => Input entered correctly
          npts   = sz[0]
          mag    = mag
        ENDELSE
      ENDELSE
    ENDELSE
  END
  3L   : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Total Plasma Temperature [Te + Ti]  :  [N,2]-Element array
    ;-------------------------------------------------------------------------------------
    te         = REFORM(tot)
    sz         = SIZE(te,/DIMENSIONS)
    ; => Check # of dimensions
    IF (N_ELEMENTS(sz) EQ 1) THEN BEGIN
      ;-----------------------------------------------------------------------------------
      ; => One-Dimension
      ;-----------------------------------------------------------------------------------
      IF (sz[0] NE 2) THEN BEGIN
        npts = d
        RETURN
      ENDIF
      npts  = 1
      tot   = REFORM(te,1,2)
    ENDIF ELSE BEGIN
      ;-----------------------------------------------------------------------------------
      ; => Multiple Dimensions               :  [N,2]-Element array
      ;-----------------------------------------------------------------------------------
      IF (N_ELEMENTS(sz) GT 2) THEN BEGIN
        npts   = d
        errmsg = 'Keyword TOT has too many dimensions!'
        MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
        RETURN
      ENDIF
      gzzd  = WHERE(sz EQ 2,gz)
      test  = (N_ELEMENTS(sz) NE 2) OR (gz EQ 0)
      IF (test) THEN BEGIN
        npts = d
        RETURN
      ENDIF
      IF (gzzd[0] EQ 1) THEN tot  = tot   ELSE tot  = TRANSPOSE(tot)
      IF (gzzd[0] EQ 1) THEN npts = sz[0] ELSE npts = sz[1]
    ENDELSE
    ;---------------
    ; => Return
    ;---------------
    RETURN
  END
  4L   : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Shock Normal Vector                 :  [M,3]-Element array
    ;-------------------------------------------------------------------------------------
    n1         = REFORM(nor)
    sz         = SIZE(n1,/DIMENSIONS)
    ; => Check # of dimensions
    IF (N_ELEMENTS(sz) EQ 1) THEN BEGIN
      ;-----------------------------------------------------------------------------------
      ; => One-Dimension
      ;-----------------------------------------------------------------------------------
      IF (sz[0] NE 3) THEN BEGIN
        npts = d
        RETURN
      ENDIF
      mnor  = 1
      nor   = REFORM(n1,1,3)
    ENDIF ELSE BEGIN
      IF (N_ELEMENTS(sz) GT 2) THEN BEGIN
        npts   = d
        errmsg = 'Keyword NOR has too many dimensions!'
        MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
        RETURN
      ENDIF
      ;-----------------------------------------------------------------------------------
      ; => Multiple Dimensions
      ;-----------------------------------------------------------------------------------
      gzzd  = WHERE(sz EQ 3,gz)
      test  = (N_ELEMENTS(sz) NE 2) OR (gz EQ 0)
      IF (test) THEN BEGIN
        npts = d
        RETURN
      ENDIF
      IF (gzzd[0] EQ 1) THEN nor  = nor   ELSE nor  = TRANSPOSE(nor)
      IF (gzzd[0] EQ 1) THEN mnor = sz[0] ELSE mnor = sz[1]
    ENDELSE
    ;---------------
    ; => Return
    ;---------------
    RETURN
  END
  5L   : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Shock Normal Speed in SC-Frame      :  [N,M]-Element array
    ;-------------------------------------------------------------------------------------
    test       = KEYWORD_SET(npts) OR KEYWORD_SET(mnor)
    ; => Make sure either NPTS or MNOR keyword is set
    IF (test) THEN BEGIN
      gtest  = WHERE([KEYWORD_SET(npts),KEYWORD_SET(mnor)],gts)
      IF (gts EQ 1) THEN BEGIN
        IF (gtest[0] EQ 0) THEN ndim = npts[0] ELSE ndim = -1L
        IF (gtest[0] EQ 0) THEN mdim = -1L     ELSE mdim = mnor[0]
      ENDIF ELSE BEGIN
        ndim = npts[0]
        mdim = mnor[0]
      ENDELSE
    ENDIF ELSE BEGIN
      ; => Cannot know what dimensions correspond to what...
      errmsg = 'Must set either NPTS or MNOR keyword when using VSH keyword!'
      MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
      npts   = d
      mnor   = d
      RETURN
    ENDELSE
    vs1        = REFORM(vsh)
    sz         = SIZE(vs1,/DIMENSIONS)
    ; => Check # of dimensions
    IF (N_ELEMENTS(sz) EQ 1) THEN BEGIN
      ;-----------------------------------------------------------------------------------
      ; => One-Dimension
      ;-----------------------------------------------------------------------------------
      test = ((sz[0] EQ ndim[0]) OR (sz[0] EQ mdim[0])) NE 1
      IF (test) THEN BEGIN
        test2  = (gts GT 1)
        IF (test2) THEN BEGIN
          errmsg = 'Either NPTS or MNOR must match at least one dimension of VSH!'
          MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
          npts   = d
          mnor   = d
          RETURN
        ENDIF ELSE BEGIN
          IF (ndim[0] LT 0) THEN BEGIN
            ; => MNOR is set and sz[0] = N
            ;      VSH  =  [N]-Element array
            vsh  = REFORM(vsh,sz[0],1)
            npts = sz[0]
            mnor = mdim[0]
          ENDIF ELSE BEGIN
            ; => NPTS is set and sz[0] = M
            ;      VSH  =  [M]-Element array
            vsh  = REFORM(vsh,1,sz[0])
            mnor = sz[0]
            npts = ndim[0]
          ENDELSE
          ;---------------
          ; => Return
          ;---------------
          RETURN
        ENDELSE
      ENDIF
      gzzd  = WHERE([ndim[0],mdim[0]] EQ sz[0],gz)
      IF (gzzd[0] EQ 0) THEN BEGIN
        ; => NPTS set and = N  :  => M = 1
        mnor = 1
        npts = sz[0]
        vsh  = REFORM(vsh,sz[0],1)
      ENDIF ELSE BEGIN
        ; => MNOR set and = M  :  => N = 1
        mnor = sz[0]
        npts = 1
        vsh  = REFORM(vsh,1,sz[0])
      ENDELSE
    ENDIF ELSE BEGIN
      ;-----------------------------------------------------------------------------------
      ; => Multiple Dimensions               :  [N,M]-Element array
      ;-----------------------------------------------------------------------------------
      ; => Make sure it's not too big
      IF (N_ELEMENTS(sz) GT 2) THEN BEGIN
        npts   = d
        mnor   = d
        errmsg = 'Keyword VSH has too many dimensions!'
        MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
        RETURN
      ENDIF
      gzzn  = WHERE(sz EQ ndim[0],gzn)
      gzzm  = WHERE(sz EQ mdim[0],gzm)
      IF (gzn GT 0 OR gzm GT 0) THEN BEGIN
        ; => At least one matches
        gzzd = WHERE([gzn,gzm] GT 0,gz)
        CASE gzzd[0] OF
          0L  :  BEGIN
            ; => NPTS matches
            IF (gzzn[0] EQ 0) THEN vsh  = vsh   ELSE vsh  = TRANSPOSE(vsh)
            IF (gzzn[0] EQ 0) THEN npts = sz[0] ELSE npts = sz[1]
            IF (gzzn[0] EQ 0) THEN mnor = sz[1] ELSE mnor = sz[0]
          END
          1L  :  BEGIN
            ; => MNOR matches
            IF (gzzm[0] EQ 1) THEN vsh  = vsh   ELSE vsh  = TRANSPOSE(vsh)
            IF (gzzm[0] EQ 1) THEN npts = sz[0] ELSE npts = sz[1]
            IF (gzzm[0] EQ 1) THEN mnor = sz[1] ELSE mnor = sz[0]
          END
        ENDCASE
      ENDIF ELSE BEGIN
        ; => Bad input
        errmsg = 'Either NPTS or MNOR must match at least one dimension of VSH!'
        MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
        npts   = d
        mnor   = d
        RETURN
      ENDELSE
    ENDELSE
    ;---------------
    ; => Return
    ;---------------
    RETURN
  END
  ELSE : BEGIN
    ;-------------------------------------------------------------------------------------
    ; => Bad input
    ;-------------------------------------------------------------------------------------
    errmsg = 'I am not sure how you accomplished this but I am impressed...'
    MESSAGE,errmsg[0],/INFORMATIONAL,/CONTINUE
    npts   = d
    RETURN
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Return
;-----------------------------------------------------------------------------------------

RETURN
END
