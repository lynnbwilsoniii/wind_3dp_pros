;+
;*****************************************************************************************
;
;  FUNCTION :   find_strahl_direction.pro
;  PURPOSE  :   This routine determines from which direction comes, parallel to an input
;                 magnetic field vector, the narrow electron beam known as the strahl.
;                 The determination of the strahl direction is shown below assuming the
;                 input magnetic field is in the GSE coordinate basis.
;
;                                      X
;                                      |
;                                      |
;                             I        |      IV
;                                      |
;                    Y ----------------|----------------
;                                      |
;                            II        |      III
;                                      |
;                                      |
;
;                      quadrant     Sun Dir.     Strahl Dir.
;                                   (// Bo)        (// Bo)
;                 =============================================
;                          I          +1             -1
;                         II          -1             +1
;                        III          -1             +1
;                         IV          +1             -1
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               is_a_number.pro
;               unit_vec.pro
;               sign.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               BVEC  :  [N,3]-Element [float/double] array of magnetic field vectors in
;                          the GSE coordinate basis.
;
;  EXAMPLES:    
;               strahl_dir = find_strahl_direction(bvec)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Moved to ~/wind_3dp_pros/LYNN_PRO/general_math/ and
;                   now calls is_a_number.pro
;                                                                   [08/12/2015   v1.1.0]
;
;   NOTES:      
;               1)  BVEC can be a unit vector or a vector with non-unity magnitude
;
;  REFERENCES:  
;               1)  Feldman, W.C., J.R. Asbridge, S.J. Bame, J.T. Gosling, and D.S.
;                      Lemons "Characteristic electron variations across simple
;                      high-speed solar wind streams," J. Geophys. Res. 83,
;                      pp. 5285-5295, (1978).
;               2)  Pilipp, W.G., H. Miggenrieder, M.D. Montgomery, K.-H. Mühlhäuser,
;                      H. Rosenbauer, and R. Schwenn "Characteristics of electron
;                      velocity distribution functions in the solar wind derived
;                      from the HELIOS plasma experiment," J. Geophys. Res. 92,
;                      pp. 1075-1092, (1987).
;
;   CREATED:  04/25/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/12/2015   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION find_strahl_direction,bvec

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number, unit_vec, sign
;;----------------------------------------------------------------------------------------
;;  Define some constants and dummy variables
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
all_strahl_dir = [-1,1,1,-1]     ;;  sign of strahl direction for each quadrant
strahl_on      = 0               ;;  dummy logic variable
strahl_dir     = 0
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() NE 1) OR (is_a_number(bvec,/NOMSSG) EQ 0) OR $
                 (N_ELEMENTS(bvec) LT 3)
IF (test[0]) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;;  Define unit vector
;;----------------------------------------------------------------------------------------
bu             = unit_vec(bvec)
test           = ((N_ELEMENTS(bu) MOD 3) NE 0)
IF (test) THEN RETURN,0b
;;  Define sign of each component of the unit vectors
bu_s           = sign(bu)
;;----------------------------------------------------------------------------------------
;;  Determine quadrant
;;
;;                      X
;;                      |
;;                      |
;;             I        |      IV
;;                      |
;;    Y ----------------|----------------
;;                      |
;;            II        |      III
;;                      |
;;                      |
;;----------------------------------------------------------------------------------------
test_r13       = (bu_s[*,0]*bu_s[*,1] GE 0)                ;;  logic test for quadrants I and III
test_r24       = (TOTAL(bu_s[*,0:1],2) EQ 0)               ;;  logic test for quadrants II and IV
test_r1        = test_r13 AND (TOTAL(bu_s[*,0:1],2) GT 0)  ;;  logic test for quadrant   I
test_r3        = test_r13 AND (TOTAL(bu_s[*,0:1],2) LT 0)  ;;  logic test for quadrant III
test_r2        = test_r24 AND (bu_s[*,0] LT 0)             ;;  logic test for quadrant  II
test_r4        = test_r24 AND (bu_s[*,1] LT 0)             ;;  logic test for quadrant  VI
test__r        = [[test_r1],[test_r2],[test_r3],[test_r4]]
;test__r        = [test_r1,test_r2,test_r3,test_r4]
;;----------------------------------------------------------------------------------------
;;  Define strahl direction
;;
;;         quadrant     Sun Dir.     Strahl Dir.
;;                      (// Bo)        (// Bo)
;;    =============================================
;;             I          +1             -1
;;            II          -1             +1
;;           III          -1             +1
;;            IV          +1             -1
;;----------------------------------------------------------------------------------------
nt             = N_ELEMENTS(test_r1)
strahl_dir     = INTARR(nt)
all_sdir_2d    = REPLICATE(1,nt) # all_strahl_dir
good_all       = REPLICATE(0,nt,4)
FOR k=0L, 3L DO BEGIN
  good__r        = WHERE(test__r[*,k],gd__r)
  IF (gd__r GT 0) THEN good_all[good__r,k] = all_sdir_2d[good__r,k]
ENDFOR
good           = WHERE(good_all NE 0,gd)
IF (gd GT 0) THEN BEGIN
  gind           = ARRAY_INDICES(good_all,good)
  strahl_dir[gind[0,*]] = good_all[gind[0,*],gind[1,*]]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,strahl_dir
END
