
;+
; matrix_array_lib
;
; Helpful functions for dealing with arrays of 3x3 matrixes (Nx3x3)
;
;
; $LastChangedBy: nikos $
; $LastChangedDate: 2015-12-09 14:11:53 -0500 (Wed, 09 Dec 2015) $
; $LastChangedRevision: 19553 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/general/cotrans/special/matrix_array_lib.pro $
;-

;helper function
;used to determine if values are equal within some standard of computational error
function ctv_err_test,vals,val
  compile_opt idl2, hidden
  err = 1d-5

  return,(vals ge val-err and vals le val+err)

end

;helper function
;returns the determinant of a list of 3x3 matrices

function ctv_determ_mats,m

  compile_opt idl2, hidden

  return,reform(m[*,0,0] * m[*,1,1] * m[*,2,2] $
    -m[*,0,0] * m[*,1,2] * m[*,2,1] $
    -m[*,0,1] * m[*,1,0] * m[*,2,2] $
    +m[*,0,1] * m[*,1,2] * m[*,2,0] $
    +m[*,0,2] * m[*,1,0] * m[*,2,1] $
    -m[*,0,2] * m[*,1,1] * m[*,2,0])

end

;helper function
;determines if a list of 3x3 matrices are identity matrices
;will return the indexes of the identity matrices in the list of matrices
function ctv_identity_mats,m

  compile_opt idl2, hidden

  dim = dimen(m)

  out = lonarr(dim[0])

  return,ctv_err_test(m[*,0,0],1) and ctv_err_test(m[*,0,1],0) and ctv_err_test(m[*,0,2],0) and $
    ctv_err_test(m[*,1,0],0) and ctv_err_test(m[*,1,1],1) and ctv_err_test(m[*,1,2],0) and $
    ctv_err_test(m[*,2,0],0) and ctv_err_test(m[*,2,1],0) and ctv_err_test(m[*,2,2],1)

end

;helper function
;vectorized multiplication of two lists of 3x3 matrices
function ctv_mm_mult,m1,m2

  compile_opt idl2, hidden

  out = make_array(dimen(m1),type=size(m1,/type))

  out[*,0,0] = total(m1[*,0,*] * m2[*,*,0],3)
  out[*,1,0] = total(m1[*,1,*] * m2[*,*,0],3)
  out[*,2,0] = total(m1[*,2,*] * m2[*,*,0],3)

  out[*,0,1] = total(m1[*,0,*] * m2[*,*,1],3)
  out[*,1,1] = total(m1[*,1,*] * m2[*,*,1],3)
  out[*,2,1] = total(m1[*,2,*] * m2[*,*,1],3)

  out[*,0,2] = total(m1[*,0,*] * m2[*,*,2],3)
  out[*,1,2] = total(m1[*,1,*] * m2[*,*,2],3)
  out[*,2,2] = total(m1[*,2,*] * m2[*,*,2],3)

  return,out

end

;helper function
;verifies whether a list of matrices
;contains valid rotation matrices.
;This is determined using 2 constraints.
;#1 Where determ(matrix) eq 1
;#2 Where matrix#transpose(matrix) eq I
;returns 0 if the matrices use a mixed system
;returns 1 if there are no valid mats
;returns 2 if the data are all nans
;returns 3 if there are some invalid mats
;returns 4 if there are some nans
;returns 5 win!
function ctv_verify_mats,m

  compile_opt idl2, hidden

  identity_mats = ctv_identity_mats(ctv_mm_mult(m,transpose(m,[0,2,1])))

  ;make sure matrix is self-inverting and the determinate is either 1 in all cases or -1 in all cases
  idx = where(ctv_err_test(ctv_determ_mats(m),1) and identity_mats,c_right)

  idx = where(ctv_err_test(ctv_determ_mats(m),-1) and identity_mats,c_left)

  idx = where(~finite(ctv_determ_mats(m)),c_nan)

  dim = dimen(m)

  if c_left ne 0 && c_right ne 0 then begin ;mixed system
    return,0
  endif else if (c_left eq 0 && c_right eq 0) then begin ;all matrices fail
    return,1
  endif else if c_nan eq dim[0] then begin ;all nans
    return,2
  endif else if (c_left+c_right+c_nan lt 0) then begin ;some matrices fail
    return,3
  endif else if c_nan ne 0 then begin ;some nans
    return,4
  endif else begin ;all mats are rotation mats and there is no missing data
    return,5
  endelse

end

;is this a set of left-handed permutation matrices?
function ctv_left_mats,m

  compile_opt idl2, hidden

  t = where(ctv_err_test(ctv_determ_mats(m),-1),c)

  if c gt 0 then return,1 else return,0

end

;turns a 3x3 matrix with a left-handed basis into a right-handed basis and vice-versa
function ctv_swap_hands,m
  compile_opt idl2, hidden
  out = m
  out[*,0,*] *= -1

  return,out

end

;helper function
;calculates the norm of a bunch of vectors simultaneously
function ctv_norm_vec_rot,v

  compile_opt idl2, hidden

  if not keyword_set(v) then return, -1L

  if size(v,/n_dim) ne 2 then return,-1L

  return, sqrt(total(v^2,2))

end

;helper function
;normalizes a bunch of vectors simultaneously
function ctv_normalize_vec_rot,v

    compile_opt idl2, hidden

  if not keyword_set(v) then return, -1L

  if size(v,/n_dim) ne 2 then return,-1L

  n_a = ctv_norm_vec_rot(v)

  if(size(n_a,/n_dim) eq 0 && n_a eq -1L) then return,-1L

  v_s = size(v,/dimension)

  ;calculation is pretty straight forward
  ;we turn n_a into an N x D so computation can be done element by element
  n_b = rebin(n_a,v_s[0],v_s[1])

  return,v/n_b

end

;helper function
;vectorized fx to multiply n matrices by n vectors
function ctv_mx_vec_rot,m,x

    compile_opt idl2, hidden

  ;input checks
  if(~keyword_set(m)) then return, -1L

  if(~keyword_set(x)) then return, -1L

  m_s = size(m,/dimension)

  x_s = size(x,/dimension)

  ;make sure number of dimensions in input arrays is correct
  if(n_elements(m_s) ne 3) then return, -1L

  if(n_elements(x_s) ne 2) then return, -1L

  ;make sure dimensions match
  if(not array_equal(x_s,[m_s[0],m_s[1]])) then return,-1L

  if(not array_equal(m_s,[x_s[0],x_s[1],x_s[1]])) then return,-1L

  ;calculation is pretty straight forward
  ;we turn x into an N x 3 x 3 so computation can be done element by element
  y_t = rebin(x,x_s[0],x_s[1],x_s[1])

  ;custom multiplication requires rebin to stack vector across rows,
  ;not columns
  y_t = transpose(y_t, [0, 2, 1])

  ;9 multiplications and 3 additions per matrix
  y = total(y_t*m,3)

  return, y

end

pro matrix_array_lib

  ;does nothing, just puts the functions in scope
  compile_opt idl2, hidden
    
end