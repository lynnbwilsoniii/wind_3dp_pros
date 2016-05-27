;+
;FUNCTION: min_var.pro
;
;PURPOSE: Minimum Variance Analysis
;
;ARGUMENTS: 
;    X_DATA   -> X component of original data
;    Y_DATA   -> Y component of original data
;    Z_DATA   -> Z component of original data
;
;
;RETURNS: Minimum variance rotation matix (Eigen vectors, min to max)
;           0 on failure
;
;         The returned matrix is in the rotation matrix form where
;                N = R * O
;           where
;               N = New matrix (Rotated into Min. Var. Coordinates)
;               R = Rotation matrix (Result from MIN_VAR)
;               O = Original matrix
;               * = Standard Matrix Multipication
;
;KEYWORDS:
;    EIG_VALS <- Eigen values of minimum variance analysis (min to max)

;
;CALLING SEQUENCE: 
;       vectors=min_var(data.x,data.y,data.z,eig_vals=values)
;                 or
;       rot_arr=min_var(orig_arr[*,0],orig_arr[*,1],orig_arr[*,2]) ## orig_arr
;                 or
;       rot_arr=orig_arr # min_var(orig_arr[*,0],orig_arr[*,1],orig_arr[*,2])
;                 or
;       rot_arr=orig_arr ##
;                 transpose(min_var(orig_arr[0,*],orig_arr[1,*],orig_arr[2,*]))
;        (These last three forms will crash if min_var fails)
;
;
;NOTES: 
;
;CREATED BY: John Dombeck August 2001
;
;MODIFICATION HISTORY: 
;	08/06/01-J. Dombeck              Created
;-
;INCLUDED MODULES:
;   min_var
;
;LIBRARIES USED:
;   None
;
;DEPENDANCIES
;   None
;
;-


;*** MAIN *** : * MIN_VAR *

function min_var,x_data,y_data,z_data,eig_vals=eig_vals


; Check input

  nx=n_elements(x_data)
  ny=n_elements(y_data)
  nz=n_elements(z_data)

  if nx ne ny or nx ne nz then begin
    message,"Number of input elements mismatch",/cont
    return,0
  endif

  if nx eq 0 then begin
    message,"Data required",/cont
    return,0
  endif

  data=[[x_data],[y_data],[z_data]]


; Compute component means and correspondance means

  comp_av  =make_array(3,/double,value=0)
  corrsp_av=make_array(3,3,/double,value=0)

  for ii=0,2 do begin
    comp_av(ii)=total(data(*,ii))/nx
    for jj=0,2 do begin
      tmp_arr=data(*,ii)*data(*,jj)
      corrsp_av(ii,jj)=total(tmp_arr)/nx
    endfor
  endfor


; Perform minimum variance analysis


; Find M matrix

  m=make_array(3,3,/double,value=0)

  for ii=0,2 do                         $
    for jj=0,2 do                       $
      m(ii,jj)=corrsp_av(ii,jj)-comp_av(ii)*comp_av(jj)


; Compute eigenvectors and eigenvalues of M matrix

  A=m
  trired,A,D,E
  triql,D,E,A


; Order results from minimum to maximum variance
; (D(0) checked first for min and D(1) first for max just in case all
; three eigenvalues are the same - all vectors will still be used)

  if D(0) eq min(D) then mn=0          $
    else if D(1) eq min(D) then mn=1   $
      else mn=2
  if D(1) eq max(D) then mx=1          $
    else if D(0) eq max(D) then mx=0   $
      else mx=2
  md=3-mn-mx


; Store Minimum Variance Analysis results

  eig_vals=make_array(3,/double,value=0)
  eig_vecs=make_array(3,3,/double,value=0)

  eig_vals(0)=D(mn)
  eig_vals(1)=D(md)
  eig_vals(2)=D(mx)
  eig_vecs(*,0)=extrac(A,0,mn,3,1)
  eig_vecs(*,1)=extrac(A,0,md,3,1)
  eig_vecs(*,2)=extrac(A,0,mx,3,1)


return,eig_vecs
end        ;*** MAIN *** : * MIN_VAR *

