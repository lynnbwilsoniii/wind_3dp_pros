;+
;*****************************************************************************************
;
;  FUNCTION :   lbw_la_minvar.pro
;  PURPOSE  :   This routine calculates the minimum variance (MVA) matrix and returns the
;                 matrix in addition to the associated eigen values of the analysis.
;                 The resulting matrix is a [3,3]-element array composed of the unit
;                 vectors of the MVA coordinate basis [from min to max] in the input
;                 vector coordinate basis.
;
;                 The returned matrix is in the rotation matrix form where
;                        N = R * O
;                   where
;                       N = New matrix (Rotated into Min. Var. Coordinates)
;                       R = Rotation matrix (Result from MIN_VAR)
;                       O = Original matrix
;                       * = Standard Matrix Multipication
;
;  CALLED BY:   
;               NA
;
;  INCLUDES:
;               NA
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               
;
;  INPUT:
;               [X,Y,Z]_DATA  :  [N]-Element [float/double] arrays defining the [X,Y,Z]-
;                                  components of the vector to which the analysis should
;                                  be applied
;
;  EXAMPLES:    
;               [calling sequence]
;               test = lbw_la_minvar(x, y, z [,EIG_VALS=eig_vals])
;               
;
;  KEYWORDS:    
;               EIG_VALS  :  Set to a named variable to return the eigen values of the
;                              minimum variance analysis [from min to max]
;
;   CHANGED:  1)  NA
;                                                                   [MM/DD/YYYY   v1.0.0]
;
;   NOTES:      
;               1)  Make sure inputs are numeric and of equal length
;               2)  This differs from lbw_minvar.pro in that is uses the
;                     LA_*.PRO versions of the qr-factorization routines in IDL
;
;  REFERENCES:  
;               1)  G. Paschmann and P.W. Daly "Analysis Methods for Multi-Spacecraft
;                     Data," ISSI Scientific Report, Noordwijk, The Netherlands.,
;                     Int. Space Sci. Inst., 1998.
;               2)  J.C. Samson and J.V. Olson, "Some Comments on the Descriptions of
;                      the Polarization States of Waves," Geophys. J. Astr. Soc. 61,
;                      pp. 115-129, 1980.
;               3)  J.D. Means, "Use of the Three-Dimensional Covariance Matrix in
;                      Analyzing the Polarization Properties of Plane Waves,"
;                      J. Geophys. Res. 77(28), pg 5551-5559, 1972.
;               4)  H. Kawano and T. Higuchi "The bootstrap method in space physics:
;                     Error estimation for the minimum variance analysis," Geophys.
;                     Res. Lett. 22(3), pp. 307-310, 1995.
;               5)  A.V. Khrabrov and B.U.Ö Sonnerup "Error estimates for minimum
;                     variance analysis," J. Geophys. Res. 103(A4), pp. 6641-6651,
;                     1998.
;               6)  LA_TRIQL.PRO and LA_TRIRED.PRO found at:
;                     https://www.harrisgeospatial.com/docs/LA_TRIQL.html
;                     https://www.harrisgeospatial.com/docs/la_trired.html
;
; ADAPTED FROM: lbw_minvar.pro    BY: Lynn B. Wilson III
;   CREATED:  08/16/2019
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  08/16/2019   v1.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION lbw_la_minvar,x_data,y_data,z_data,EIG_VALS=eig_vals

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
;;----------------------------------------------------------------------------------------
;;  Check input
;;----------------------------------------------------------------------------------------
IF (N_PARAMS() LT 3) THEN BEGIN
  MESSAGE,"[X,Y,Z]_DATA all required on input as [N]-element numeric arrays...",/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
nx             = N_ELEMENTS(x_data)
ny             = N_ELEMENTS(y_data)
nz             = N_ELEMENTS(z_data)
test           = (nx[0] NE ny[0]) OR (nx[0] NE nz[0]) OR (nx[0] EQ 0) OR (ny[0] EQ 0) OR (nz[0] EQ 0)
IF (test[0]) THEN BEGIN
  MESSAGE,"Number of input elements mismatch or insufficient elements",/INFORMATIONAL,/CONTINUE
  RETURN,0b
ENDIF
;;  Define parameters
data           = [[x_data],[y_data],[z_data]]      ;;  [N,3]-Element array
;;----------------------------------------------------------------------------------------
;;  Compute component means and correspondance means
;;----------------------------------------------------------------------------------------
comp_av        = MAKE_ARRAY(  3,/DOUBLE,VALUE=0)       ;;  component averages
corrsp_av      = MAKE_ARRAY(3,3,/DOUBLE,VALUE=0)       ;;  correspondance averages
;;  Compute the average for each 3-vector component
comp_av        = TOTAL(data,1,/NAN,/DOUBLE)/TOTAL(FINITE(data),1,/NAN,/DOUBLE)
;;  Compute correspondance averages
corrsp_av      = (data ## TRANSPOSE(data))/(1d0*nx[0])
;;  The above is equivalent to the following:
;;    FOR ii=0L, 2L DO BEGIN
;;      FOR jj=0L, 2L DO BEGIN
;;        tmp_arr          = data[*,ii]*data[*,jj]
;;        corrsp_av[ii,jj] = TOTAL(tmp_arr,/NAN)/nx
;;      ENDFOR
;;    ENDFOR
;;----------------------------------------------------------------------------------------
;;  Perform minimum variance analysis
;;----------------------------------------------------------------------------------------
;;  Find M matrix
m_mat          = MAKE_ARRAY(3,3,/DOUBLE,VALUE=0)
m_mat          = corrsp_av - (comp_av # TRANSPOSE(comp_av))
;;  The above is equivalent to the following:
;;    FOR ii=0L, 2L DO FOR jj=0L, 2L DO m_mat[ii,jj] = corrsp_av[ii,jj] - (comp_av[ii]*comp_av[jj])
;;----------------------------------------------------------------------------------------
;;  Compute eigenvectors and eigenvalues of M matrix
;;----------------------------------------------------------------------------------------
a_mat          = m_mat
;;  LA_TRIRED Input
;;    A_MAT = [NxN]-Element real symmetric matrix
;;  LA_TRIRED Output Results
;;    DIAG  = Returned [N]-Element vector of the diagonal elements of t3evec
;;    OFFD  = Returned [N]-Element vector of the off-diagonal " " 
LA_TRIRED,a_mat,diag,offd,/DOUBLE
;;  LA_TRIQL Output Results
;;    DIAG  = Eigenvalues of the input matrix A_MAT
;;    OFFD  = Destroyed by TRIQL.PRO
;;    A_MAT = [N]-Eigenvectors of A_MAT
LA_TRIQL,diag,offd,a_mat,/DOUBLE,STATUS=mva_status
IF (mva_status[0] GT 0) THEN BEGIN
  ;;  Failed!!!
  MESSAGE,"Algorithm did not converge in 30*N iterations:  Exiting without further computations...",/INFORMATIONAL,/CONTINUE
  RETURN,MAKE_ARRAY(3,3,/DOUBLE,VALUE=0)
ENDIF
;;----------------------------------------------------------------------------------------
;;  Order results from minimum to maximum variance
;;    (DIAG[0] checked first for min and DIAG[1] first for max just in case all
;;     three eigenvalues are the same - all vectors will still be used)
;;----------------------------------------------------------------------------------------
mn             = -1          ;;  Index of minimum variance direction
md             = -1          ;;  Index of intermediate variance direction
mx             = -1          ;;  Index of maximum variance direction
IF (diag[0] EQ MIN(diag)) THEN mn = 0 ELSE IF (diag[1] EQ MIN(diag)) THEN mn = 1 ELSE mn = 2
IF (diag[1] EQ MAX(diag)) THEN mx = 1 ELSE IF (diag[0] EQ MAX(diag)) THEN mx = 0 ELSE mx = 2
md             = 3 - mn[0] - mx[0]
ind_o          = [mn[0],md[0],mx[0]]                   ;;  Indices in order
;;----------------------------------------------------------------------------------------
;;  Save MVA results
;;----------------------------------------------------------------------------------------
eig_vals       = MAKE_ARRAY(  3,/DOUBLE,VALUE=0)       ;;  eigen values [from min to max]
eig_vecs       = MAKE_ARRAY(3,3,/DOUBLE,VALUE=0)       ;;  eigen vectors [from min to max]
eig_vals       = diag[ind_o]
eig_vecs       = a_mat[*,ind_o]
;;  The above is equivalent to the following:
;;    FOR kk=0L, 2L DO BEGIN
;;      ii              = ind_o[kk]
;;      eig_vals[kk]    = diag[ii]
;;      eig_vecs[*,kk]  = EXTRAC(a_mat,0L,ii,3L,1L)
;;    ENDFOR
;;----------------------------------------------------------------------------------------
;;  Ensure that the eigen vectors form an orthonormal basis
;;----------------------------------------------------------------------------------------
;;  1st, make right-hand orthogonal
n_x_i          = CROSSP(eig_vecs[*,0],eig_vecs[*,1])
mxv            = REFORM(eig_vecs[*,2])
test           = (TOTAL(n_x_i*mxv/(ABS(n_x_i)*ABS(mxv)) LT 0) GT 0)
IF (test[0]) THEN eig_vecs[*,2] *= -1      ;;  Change sign of maximum variance eigen vector
;;  2nd, normalize
FOR kk=0L, 2L DO BEGIN
  vec             = REFORM(eig_vecs[*,kk])
  mag             = SQRT(TOTAL(vec^2d0,/NAN,/DOUBLE))
  uvc             = vec/mag[0]
  eig_vecs[*,kk]  = REFORM(uvc)
ENDFOR
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN,eig_vecs
END








