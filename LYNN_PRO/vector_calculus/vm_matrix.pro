;+
;*****************************************************************************************
;
;  FUNCTION :   vm_matrix.pro
;  PURPOSE  :   This routine is a quasi-vectorized algorithm to multiply two arrays of
;                 MxM (i.e., square) matrices without using #, ##, or looping through
;                 each matrix.  The output should be the equivalent of the following:
;                   output = MAKE_ARRAY(DIMENSION=[N,M,M])
;                   FOR j=0L, N - 1L DO output[j,*,*] = REFORM(A[j,*,*]) ## REFORM(B[j,*,*])
;
;                 The algorithm is given by:
;                   Q_i,j,k  =  (A . B)_i,j,k  =  ∑_m A_i,m,k B_m,j,k
;                     where:  k = 0,1,...,N-1  [i.e., IDL matrix index]
;                             i = 0,1,...,M-1  [i.e., IDL row index]
;                             j = 0,1,...,M-1  [i.e., IDL column index]
;
;                 The IDL syntax, if looped, would be given by:
;                   FOR k=0L, N - 1L DO BEGIN
;                     FOR i=0L, M - 1L DO BEGIN
;                       FOR j=0L, M - 1L DO BEGIN
;                         Q[k,j,i] = TOTAL( A[k,*,i]*B[k,j,*] ,/NAN)
;                       ENDFOR
;                     ENDFOR
;                   ENDFOR
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               is_a_number.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               A  :  [N,M,M]-Element [numeric] array of MxM square matrices
;               B  :  [N,M,M]-Element [numeric] array of MxM square matrices
;
;  EXAMPLES:    
;               cmat = vm_matrix(amat,bmat)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  NA [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  The i-th output matrix, Q[i,*,*], is equivalent to the IDL result
;                     from:  REFORM(A[i,*,*]) ## REFORM(B[i,*,*])
;               2)  If these are rotation matrices, then the output, Q, acting on
;                     vector V is the same as first letting B act on V, then letting
;                     A act on that result or Q = A . (B . V)
;
;  REFERENCES:  
;               Useful links:
;                 https://en.wikipedia.org/wiki/Matrix_multiplication
;                 http://www.exelisvis.com/docs/MATRIX_MULTIPLY.html
;                 http://www.exelisvis.com/docs/Matrix_Operators.html
;                 http://www.exelisvis.com/docs/TRANSPOSE.html
;                 https://en.wikipedia.org/wiki/Rotation_matrix
;
;   CREATED:  11/06/2015
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  11/06/2015   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION vm_matrix,amat,bmat

;;  Let IDL know that the following are functions
FORWARD_FUNCTION is_a_number
;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
ident          = IDENTITY(3,/DOUBLE)     ;;  3x3 identity or unit matrix
;;  Dummy error messages
no_inpt_msg    = 'User must supply two MxM-matrices either as single or arrays of matrices'
badvfor_msg    = 'Incorrect input format:  A and B must be [N,M,M]-element [numeric] arrays of MxM-matrices'
baddfor_msg    = 'Incorrect input format:  A and B must have the same dimensions as [N,M,M]-element [numeric] arrays'
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
test           = (N_PARAMS() LT 2) OR (is_a_number(amat,/NOMSSG) EQ 0) OR  $
                 (is_a_number(bmat,/NOMSSG) EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,no_inpt_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
szda           = SIZE(amat,/DIMENSIONS)
szdb           = SIZE(bmat,/DIMENSIONS)
szna           = SIZE(amat,/N_DIMENSIONS)
sznb           = SIZE(bmat,/N_DIMENSIONS)
test           = (szna[0] NE 3) OR (sznb[0] NE 3)
IF (test[0]) THEN BEGIN
  MESSAGE,badvfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
test           = (TOTAL(szda NE szdb) GT 0)
IF (test[0]) THEN BEGIN
  MESSAGE,baddfor_msg,/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;----------------------------------------------------------------------------------------
;;  Calculate the matrix product
;;
;;      (A . B)_ij = ∑_k A_ik B_kj
;;        Q_ij = ith row and jth column of Q matrix
;;
;;    For N matrices, each of dimensions MxM, this looks like:
;;      (A . B)_i,j,k  =  ∑_m A_i,m,k B_m,j,k  =  Q_i,j,k
;;        where:  k = 0,1,...,N-1
;;                i = 0,1,...,M-1
;;                j = 0,1,...,M-1
;;
;;    - In IDL this is equivalent to (A ## B), for each matrix
;;    - If these are rotation matrices, then the output, Q, acting on vector V is
;;        the same as first letting B act on V, then letting A act on that result
;;----------------------------------------------------------------------------------------
ncol           = szda[1]          ;;  # of columns
nrow           = szda[2]          ;;  # of rows
cmat           = MAKE_ARRAY(DIMENSION=[szda[0],ncol[0],nrow[0]],TYPE=SIZE(amat,/TYPE))
FOR row=0L, nrow[0] - 1L DO BEGIN
  tempa = REFORM(amat[*,*,row])                 ;;  = A_i,*,*
  FOR col=0L, ncol[0] - 1L DO BEGIN
    tempb = REFORM(bmat[*,col,*])               ;;  = B_*,j,*
    sumab = TOTAL(tempa*tempb,2L,/DOUBLE,/NAN)  ;;  = ∑_m A_i,m,* B_m,j,*
    cmat[*,col,row] = sumab                     ;;  = C_i,j,*
  ENDFOR
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to User
;;----------------------------------------------------------------------------------------

RETURN,cmat
END




