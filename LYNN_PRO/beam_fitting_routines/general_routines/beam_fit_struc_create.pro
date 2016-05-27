;+
;*****************************************************************************************
;
;  FUNCTION :   beam_fit_struc_create.pro
;  PURPOSE  :   This routine creates a dummy structure to be filled by user given
;                 an array of type codes and # of elements
;
;  CALLED BY:   
;               beam_fit_struc_common.pro
;
;  CALLS:
;               array_where.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TYPES  :  [N]-Element array [long] of type codes defing the type of
;                           data for the i-th structure tag with N_ELS[i]-elements
;               N_ELS  :  [N]-Element array [long] defining the # of elements in the
;                           value associated with the i-th structure tag of type
;                           TYPES[i]
;
;  EXAMPLES:    
;               
;
;  KEYWORDS:    
;               TAGS   :  [N]-Element array [string] defining the names of the output
;                           structure tags
;                           [Default = 'T'+istr for the i-th tag]
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  istr = STRTRIM(STRING([index],FORMAT='(I3.3)'),2L)
;               2)  Currently, this routine only allows outputs with the following
;                     type codes:
;                           Byte      = 1
;                           Integer   = 2
;                           Long      = 3
;                           Float     = 4
;                           Double    = 5
;                           Complex   = 6
;                           String    = 7
;                           DComplex  = 9
;               3)  Any given value of N_ELS cannot exceed 99999
;
;   CREATED:  08/30/2012
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/30/2012   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION beam_fit_struc_create,types,n_els,TAGS=tags

;;----------------------------------------------------------------------------------------
;; => Define the dummy values
;;----------------------------------------------------------------------------------------
b              =  0b              ;; [Byte]     = 1
i              = -1               ;; [Integer]  = 2
l              = -1L              ;; [Long]     = 3
f              = !VALUES.F_NAN    ;; [Float ]   = 4
d              = !VALUES.D_NAN    ;; [Double]   = 5
fc             = COMPLEX(f,f)     ;; [Complex]  = 6
s              = ''               ;; [String]   = 7
fd             = DCOMPLEX(d,d)    ;; [DComplex] = 9
;; => Define these in string format
s_dvals        = ['0b','-1','-1L','!VALUES.F_NAN','!VALUES.D_NAN',$
                  'COMPLEX(!VALUES.F_NAN,!VALUES.F_NAN)',"''",    $
                  'DCOMPLEX(!VALUES.D_NAN,!VALUES.D_NAN)'         ]

def_types      = [1L,2L,3L,4L,5L,6L,7L,9L]
;;----------------------------------------------------------------------------------------
;; => Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (N_ELEMENTS(types) NE N_ELEMENTS(n_els))
IF (test) THEN RETURN,0b

type           = REFORM(types)
nels           = REFORM(n_els)
nt0            = N_ELEMENTS(nels)
;;  Check for bad input [i.e. NELS > 99999]
bad            = WHERE(nels GT 99999L,bd,COMPLEMENT=good,NCOMPLEMENT=gd)
IF (gd EQ 0) THEN RETURN,0b
gtype          = type[good]
gnels          = nels[good]
;;  Redefine N
nt             = N_ELEMENTS(gnels)

;;  Check type codes
good_t         = array_where(gtype,def_types,/N_UNIQ)
IF (good_t[0] LT 0 OR nt0 GT 99L) THEN RETURN,0b

good_tt        = good_t[*,0]
good_dt        = good_t[*,1]
;; => Make sure order has not changed
gind           = LINDGEN(N_ELEMENTS(good_tt))
gind           = gind[good_tt]
sp             = SORT(gind)
good_tt        = good_tt[sp]
good_dt        = good_dt[sp]
;; => Define dummy values string array
s_dval_arr     = s_dvals[good_dt]
;; => Keep matching types
gtype          = gtype[good_tt]
gnels          = gnels[good_tt]
g_els          = good[good_tt]
;;  Redefine N
nt             = N_ELEMENTS(gnels)
;;----------------------------------------------------------------------------------------
;; => Check keywords
;;----------------------------------------------------------------------------------------
test           = KEYWORD_SET(tags) AND (N_ELEMENTS(tags) EQ nt0)
IF (test) THEN BEGIN
  ;;  User defined structure tags
  tags     = tags[g_els]
ENDIF ELSE BEGIN
  ;;  Use default structure tags
  inds     = LINDGEN(nt)
  tags     = 'T'+STRTRIM(STRING(inds,FORMAT='(I3.3)'),2L)
ENDELSE
;;----------------------------------------------------------------------------------------
;; => Define strings
;;----------------------------------------------------------------------------------------
;; convert type codes to one character strings
s_type         = STRTRIM(STRING(gtype,FORMAT='(I1.1)'),2L)+'L'
;; convert # of elements to five character strings
s_nels         = STRTRIM(STRING(gnels,FORMAT='(I5.5)'),2L)+'L'

mk_pref        = 'MAKE_ARRAY('+s_nels
mk_suff        = ",TYPE="+s_type+",VALUE="+s_dval_arr+")"
mk_string      = mk_pref+mk_suff
;; Join the string array
mk_jstr        = STRJOIN(mk_string,",",/SINGLE)
;;----------------------------------------------------------------------------------------
;; => Define string that can be passed to EXECUTE
;;----------------------------------------------------------------------------------------
exc_pref       = "struc = CREATE_STRUCT(tags,"
exc_string     = exc_pref[0]+mk_jstr+")"
status         = EXECUTE(exc_string)
IF (status EQ 0) THEN RETURN,0b
;;----------------------------------------------------------------------------------------
;; => Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc
END
