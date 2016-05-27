;+
;Program:	mat_diag, p, EIG_VAL= eig_val, EIG_VEC= eig_vec
;INPUT:	
;	p	6-element vector [Pxx, Pyy, Pzz, Pxy, Pxz, Pyz] of a
;		symmetric matrix
;OUTPUT:
;	eig_val, eig_vec
;PURPOSE:
;	Diagonalize a 3x3 symmetric matrix
;	Returns the eigenvalues and eigenvectors.
;	The eigenvalues are the diagnonal elements of the matrix
;	The eigenvectors are the associated principle axis. 
;NOTES:	
;	The first eigenvalue (eig_val(0)) and eigenvector (eig_vec(*,0))
;	are the distinguisheable eigenvalue and the major (symmetry) axis,
;	respectively.  
;	The "degenerate" eigenvalues are sorted such that the 2nd eigenvalue
;	is smaller than the third one.
;CREATED BY:
;	Tai Phan (95-9-15)
;LAST MODIFICATION:
;	95-9-29		Tai Phan
;-
pro mat_diag , p, EIG_VAL= eig_val, EIG_VEC= eig_vec

	if n_elements(p) ne 6 then print,'matrix must be 3x3'

	p = [[p(0),p(3),p(4)],[p(3),p(1),p(5)],[p(4),p(5),p(2)]]

	trired,p,d,e
	triql,d,e,p
	

;	identification of the distinguisheable (symmetry) axis
	p= p(*,sort(d))
	d= d(sort(d))
	eig_val= fltarr(3)
	eig_vec= fltarr(3,3)

	if (d(2)-d(1) gt d(1)-d(0)) then begin
		eig_val(0)= d(2)
		eig_val(1)= d(0)
		eig_val(2)= d(1)
		eig_vec(*,0)= p(*,2)
		eig_vec(*,1)= p(*,0)
		eig_vec(*,2)= p(*,1)
	endif else begin
		eig_val= d
		eig_vec= p	
	endelse

	

return
end

