;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_calc_vec_para_tran_comp.pro
;  PURPOSE  :   This routine calculates the parallel and transverse components of an
;                 input vector A relative to an input vector B.  That is, the output
;                 will resemble the result of:
;                   A_para = (A.B)B/|B|^2
;                   A_tran = A - A_para = [(B x A) x B]/|B|^2
;                   theta  = ACOS((A.B)/|B|/|A|)
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_3_vector.pro
;               calc_1var_stats.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               AV      :  [3]- or [N,3]-element [numeric] array of 3-vectors for which
;                            to compute the parallel and transverse components
;               BV      :  [3]- or [N,3]-element [numeric] array of 3-vectors relative
;                            to which AV will be projected
;
;  EXAMPLES:    
;               [calling sequence]
;               test = lbw_calc_vec_para_tran_comp(av,bv [,DA=da] [,DB=db])
;
;               ;;  Example Test
;               av             = [0.036715138d0,0.0053981686d0,0.0069602318d0]
;               bv             = [7.0140848d0,-3.1775579d0,2.5290260d0]
;               da             = [0.00560192650d0,0.00093305395d0,0.00244558530d0]
;               db             = [0.30923915d0,0.77715969d0,0.78949928d0]
;               
;               .compile /Users/lbwilson/Desktop/temp_idl/lbw_calc_vec_para_tran_comp.pro
;               test           = lbw_calc_vec_para_tran_comp(av,bv,DA=da,DB=db)
;               PRINT,';;  ',REFORM(test.A_PARA.VAL)         & $
;               PRINT,';;  ',(mag__vec(test.A_PARA.VAL))[0]  & $
;               PRINT,';;  ',REFORM(test.A_TRAN.VAL)         & $
;               PRINT,';;  ',(mag__vec(test.A_TRAN.VAL))[0]  & $
;               PRINT,';;  ',test.THETA.VAL[0],' +/- ',test.THETA.UNC[0]
;               ;;       0.027545076    -0.012223739    0.0099317609
;               ;;       0.031729968
;               ;;      0.0091217015     0.017503189   -0.0029715291
;               ;;       0.019959886
;               ;;         35.355234 +/-        7.6346859
;
;  KEYWORDS:    
;               DA      :  [3]- or [N,3]-element [numeric] array of 3-vector
;                            uncertainties for AV
;                            [Default = 10% of |AV|]
;               DB      :  [3]- or [N,3]-element [numeric] array of 3-vector
;                            uncertainties for AV
;                            [Default = 10% of |AV|]
;
;   CHANGED:  1)  Continued to write routine
;                                                                   [12/18/2020   v1.0.0]
;             2)  Continued to write routine
;                                                                   [12/23/2020   v1.0.0]
;
;   NOTES:      
;               1)  Finds statistical uncertainties by perturbing the input vectors
;                     by either the user-defined uncertainties given by DA and DB or
;                     assuming 10% errors.  Then it calculates all the permutations of
;                     the perturbed values, performs one-variable statistics on those
;                     perturbed values, then outputs the median +/- half the difference
;                     between the quartiles.
;
;  REFERENCES:  
;               NA
;
;   CREATED:  12/15/2020
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  12/23/2020   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_calc_vec_para_tran_comp,av,bv,DA=dda,DB=ddb

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
del            = [-1d0,-5d-1,0d0,5d-1,1d0]
nd             = N_ELEMENTS(del)
ones           = REPLICATE(1d0,nd[0])
del2d          = del # REPLICATE(1d0,3L)
nv_fix         = 0b
;;  Define indices of confidence intervals
conflim        = 25d-2
lind           = LONG(((1d0 - conflim[0])/2L)*nd[0]) > 0L
uind           = nd[0] - lind[0] - 1L
;;  Dummy error messages
no_inpt_msg    = 'User must supply two 3-vectors either as single or arrays of vectors'
badvfor_msg    = 'Incorrect input format:  AV and BV must be [N,3]-element [numeric] arrays of 3-vectors'
badndim_msg    = 'Incorrect input format:  AV and BV must both have N 3-vectors as [N,3]-element [numeric] arrays'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 2) THEN BEGIN
  MESSAGE,no_inpt_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (is_a_3_vector(av,V_OUT=aa,/NOMSSG) EQ 0) OR  $
                 (is_a_3_vector(bv,V_OUT=bb,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
IF (N_ELEMENTS(aa[*,0]) NE N_ELEMENTS(bb[*,0])) THEN BEGIN
  MESSAGE,badndim_msg[0],/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
nv             = N_ELEMENTS(aa[*,0])
;;----------------------------------------------------------------------------------------
;;  Check keywords
;;----------------------------------------------------------------------------------------
;;  Check DA and DB
IF (is_a_3_vector(dda,V_OUT=da,/NOMSSG) EQ 0) THEN da = 1d-1*ABS(aa)
IF (N_ELEMENTS(da[*,0]) NE nv[0]) THEN da = 1d-1*ABS(aa)
IF (is_a_3_vector(ddb,V_OUT=db,/NOMSSG) EQ 0) THEN db = 1d-1*ABS(bb)
IF (N_ELEMENTS(db[*,0]) NE nv[0]) THEN db = 1d-1*ABS(bb)
;;----------------------------------------------------------------------------------------
;;  Check NV
;;----------------------------------------------------------------------------------------
;;  If NV = 1 --> increase to 2 to prevent REFORM from removing last dimension
IF (nv[0] EQ 1) THEN BEGIN
  nv_fix         = 1b
  nv             = 2L
  aa             = REPLICATE(1d0,2L) # REFORM(aa)
  bb             = REPLICATE(1d0,2L) # REFORM(bb)
  da             = REPLICATE(1d0,2L) # REFORM(da)
  db             = REPLICATE(1d0,2L) # REFORM(db)
ENDIF
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Calculate components
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  resize each vector array
dumb           = REPLICATE(d,nd[0],nv[0],3L)                                            ;;  [D,N,3]-Element array
szd            = SIZE(dumb,/DIMENSIONS)
del3d          = TRANSPOSE(REBIN(REFORM(del,1,1,nd[0]),nv[0],3L,nd[0]))                 ;;  [D,N,3]-Element array
ind2d          = LINDGEN(nd[0],nv[0])                                                   ;;  Used for indexing later
aa2            = REBIN(REFORM(aa,1,nv[0],3L),nd[0],nv[0],3L)                            ;;  [D,N,3]-Element array
bb2            = REBIN(REFORM(bb,1,nv[0],3L),nd[0],nv[0],3L)                            ;;  [D,N,3]-Element array
da2            = REBIN(REFORM(da,1,nv[0],3L),nd[0],nv[0],3L)
db2            = REBIN(REFORM(db,1,nv[0],3L),nd[0],nv[0],3L)
;;  Perturb each vector
ap             = aa2 + del3d*da2
bp             = bb2 + del3d*db2
;;  Same as the following
;;    FOR k=0L, 2L DO BEGIN
;;      ap[*,*,k]      = (ones # aa[*,k]) + (del # da[*,k])
;;      bp[*,*,k]      = (ones # bb[*,k]) + (del # db[*,k])
;;    ENDFOR
;;
;;----------------------------------------------------------------------------------------
;;  Calculate:
;;    A_para = (A.B)B/|B|^2
;;    A_tran = A - A_para = [(B x A) x B]/|B|^2
;;    theta  = ACOS((A.B)/|B|/|A|)
;;----------------------------------------------------------------------------------------
;;  Calculate |A|
amag20         = SQRT(TOTAL(ap^2d0,/NAN,3))                                             ;;  [D,N]-Element array
amag3d         = TRANSPOSE(REBIN(REFORM(amag20,1,nd[0],nv[0]),3L,nd[0],nv[0]),[1,2,0])
;;  Calculate |B|
bmag20         = SQRT(TOTAL(bp^2d0,/NAN,3))                                             ;;  [D,N]-Element array
bmag3d         = TRANSPOSE(REBIN(REFORM(bmag20,1,nd[0],nv[0]),3L,nd[0],nv[0]),[1,2,0])
;;  Define dummy variables
apara          = REPLICATE(d,nd[0],nd[0],nv[0],3L)
atran          = apara
a_the          = apara[*,*,*,0L]
FOR i=0L, nd[0] - 1L DO BEGIN
  tb             = REBIN(REFORM(bp[i,*,*],1L,nv[0],3L),nd[0],nv[0],3L)
  am             = REBIN(REFORM(amag3d[i,*,*],1L,nv[0],3L),nd[0],nv[0],3L)
  bm             = REBIN(REFORM(bmag3d[i,*,*],1L,nv[0],3L),nd[0],nv[0],3L)
  ;;  Calculate (A.B)
  temp0          = TRANSPOSE(REBIN(REFORM(TOTAL(ap*tb,/NAN,3L),1,nd[0],nv[0]),3L,nd[0],nv[0]),[1,2,0])
  ;;  Calculate ACOS((A.B)/|B|/|A|)
  thet0          = ACOS(temp0/bm/am)*18d1/!DPI
  ;;  Calculate (A.B)/|B|^2
  temp           = temp0/bm/bm
  ;;  Define A_para
  apara[i,*,*,*] = temp*bp
  ;;  Define A_tran
  atran[i,*,*,*] = ap - apara[i,*,*,*]
  ;;  Define theta
  a_the[i,*,*]   = thet0[*,*,0L] < (18d1 - thet0[*,*,0L])
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Define values with uncertainties
;;----------------------------------------------------------------------------------------
par_med        = REPLICATE(d,nv[0],3L)
trn_med        = par_med
the_med        = par_med[*,0L]
par_qrt        = REPLICATE(d,nv[0],3L,2L)
trn_qrt        = par_qrt
the_qrt        = REFORM(par_qrt[*,0L,*])
FOR j=0L, nv[0] - 1L DO BEGIN
  tp             = REFORM(apara[*,*,j,*])
  tt             = REFORM(atran[*,*,j,*])
  th             = REFORM(a_the[*,*,j])
  FOR k=0L, 2L DO BEGIN
    onvsp          = calc_1var_stats(tp[*,*,k],/NAN,/NOMSSG)
    IF (N_ELEMENTS(onvsp) EQ 13) THEN BEGIN
      par_med[j,k]   = onvsp[3]
      par_qrt[j,k,*] = onvsp[8:9]
    ENDIF
    onvst          = calc_1var_stats(tt[*,*,k],/NAN,/NOMSSG)
    IF (N_ELEMENTS(onvst) EQ 13) THEN BEGIN
      trn_med[j,k]   = onvst[3]
      trn_qrt[j,k,*] = onvst[8:9]
    ENDIF
  ENDFOR
  ;;  Define the median and uncertainties for theta now
  onvsh          = calc_1var_stats(th[*,*],/NAN,/NOMSSG)
  IF (N_ELEMENTS(onvsh) EQ 13) THEN BEGIN
    the_med[j]     = onvsh[3]
    the_qrt[j,*]   = onvsh[8:9]
  ENDIF
ENDFOR
par_unc        = (par_qrt[*,*,1] - par_qrt[*,*,0])/2d0
trn_unc        = (trn_qrt[*,*,1] - trn_qrt[*,*,0])/2d0
the_unc        = (the_qrt[*,1]   - the_qrt[*,0]  )/2d0
;;----------------------------------------------------------------------------------------
;;  Define magnitudes with uncertainties
;;----------------------------------------------------------------------------------------
pmg_med        = REPLICATE(d,nv[0])
tmg_med        = pmg_med
pmg_qrt        = REPLICATE(d,nv[0],2L)
tmg_qrt        = pmg_qrt
;;  Perturb each vector
pm2            = REBIN(REFORM(par_med,1,nv[0],3L),nd[0],nv[0],3L)                            ;;  [D,N,3]-Element array
tm2            = REBIN(REFORM(trn_med,1,nv[0],3L),nd[0],nv[0],3L)                            ;;  [D,N,3]-Element array
pu2            = REBIN(REFORM(par_unc,1,nv[0],3L),nd[0],nv[0],3L)                            ;;  [D,N,3]-Element array
tu2            = REBIN(REFORM(trn_unc,1,nv[0],3L),nd[0],nv[0],3L)                            ;;  [D,N,3]-Element array
par2           = pm2 + del3d*pu2
trn2           = tm2 + del3d*tu2
FOR j=0L, nv[0] - 1L DO BEGIN
  pp             = REFORM(par2[*,j,*])
  tt             = REFORM(trn2[*,j,*])
  mp             = mag__vec(pp,/NAN)
  mt             = mag__vec(tt,/NAN)
  onvsp          = calc_1var_stats(mp,/NAN,/NOMSSG)
  IF (N_ELEMENTS(onvsp) EQ 13) THEN BEGIN
    pmg_med[j]     = onvsp[3]
    pmg_qrt[j,*]   = onvsp[8:9]
  ENDIF
  onvst          = calc_1var_stats(mt,/NAN,/NOMSSG)
  IF (N_ELEMENTS(onvst) EQ 13) THEN BEGIN
    tmg_med[j]     = onvst[3]
    tmg_qrt[j,*]   = onvst[8:9]
  ENDIF
ENDFOR
;;  Define uncertainties
pmg_unc        = (pmg_qrt[*,1] - pmg_qrt[*,0])/2d0
tmg_unc        = (tmg_qrt[*,1] - tmg_qrt[*,0])/2d0
;;----------------------------------------------------------------------------------------
;;  Undo fake expansion of vectors
;;----------------------------------------------------------------------------------------
IF (nv_fix[0]) THEN BEGIN
  ;;  Undo fake expansion of vectors
  par_med        = REFORM(par_med[0L,*],1L,3L)
  trn_med        = REFORM(trn_med[0L,*],1L,3L)
  the_med        = [the_med[0L]]
  pmg_med        = [pmg_med[0L]]
  tmg_med        = [tmg_med[0L]]
  par_unc        = REFORM(par_unc[0L,*,*],1L,3L)
  trn_unc        = REFORM(trn_unc[0L,*,*],1L,3L)
  the_unc        = [the_unc[0L]]
  pmg_unc        = [pmg_unc[0L]]
  tmg_unc        = [tmg_unc[0L]]
ENDIF
;;----------------------------------------------------------------------------------------
;;  Define output
;;----------------------------------------------------------------------------------------
tags           = ['VAL','UNC']
apar_str       = CREATE_STRUCT(tags,par_med,par_unc)
atrn_str       = CREATE_STRUCT(tags,trn_med,trn_unc)
athe_str       = CREATE_STRUCT(tags,the_med,the_unc)
mpar_str       = CREATE_STRUCT(tags,pmg_med,pmg_unc)
mtrn_str       = CREATE_STRUCT(tags,tmg_med,tmg_unc)
tags           = ['A_PARA','A_TRAN','THETA','PARA_MAG','TRAN_MAG']
struc          = CREATE_STRUCT(tags,apar_str,atrn_str,athe_str,mpar_str,mtrn_str)
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,struc[0]
END







;tempx          = REFORM(apara[*,*,0L])                                                  ;;  [D,N]-Element array
;tempy          = REFORM(apara[*,*,1L])
;tempz          = REFORM(apara[*,*,2L])
;ind2x          = REFORM(ind2d[SORT(tempx)],nd[0],nv[0])
;ind2y          = REFORM(ind2d[SORT(tempy)],nd[0],nv[0])
;ind2z          = REFORM(ind2d[SORT(tempz)],nd[0],nv[0])
;tem2x          = tempx[ind2x]
;tem2y          = tempy[ind2y]
;tem2z          = tempz[ind2z]
;parm3d         = REBIN(REFORM(par_med,1,nv[0],3L),nd[0],nv[0],3L)
;trnm3d         = REBIN(REFORM(trn_med,1,nv[0],3L),nd[0],nv[0],3L)
;diffpx         = parm3d[*,*,0L] - tem2x
;diffpy         = parm3d[*,*,1L] - tem2y
;diffpz         = parm3d[*,*,2L] - tem2z
;difftx         = trnm3d[*,*,0L] - tem2x
;diffty         = trnm3d[*,*,1L] - tem2y
;difftz         = trnm3d[*,*,2L] - tem2z
;;;  Determine quartile indices
;good25x        = WHERE(diffpx LE 0,gd25x)
;good25y        = WHERE(diffpy LE 0,gd25y)
;good25z        = WHERE(diffpz LE 0,gd25z)
;good75x        = WHERE(diffpx GT 0,gd75x)
;good75y        = WHERE(diffpy GT 0,gd75y)
;good75z        = WHERE(diffpz GT 0,gd75z)



