;+
;Procedure:	diag_p, p, n, t=t, s=s
;INPUT:	
;	p:	pressure array of n by 6 or a string (e.g., 'p_3d_el')
;	n:	density array of n or a string (e.g., 'n_3d_el')
;PURPOSE:
;	Returns the temperature: [Tpara,Tperp,Tperp], and 
;		the unit symmetry axis s. Also returns 'T_diag' and 'S.axis'
;		for plotting purposes.  
;
;CREATED BY:
;	Tai Phan	95-09-28
;LAST MODIFICATION:
;	95-9-29		Tai Phan
;-

pro diag_p, p , n, t=t, s=s

	test= data_type(p)

	case test of
		4:	begin
			pressure= p
			dens= n
			end
		7:	begin
			get_data, p, data= tmp
			time= tmp.x
			pressure= tmp.y
			get_data, n, data= tmp
			dens= tmp.y
			end
	endcase

	result= size(pressure)
	npt= result(1)

	eig_val= fltarr(npt,3)
	eig_vec= fltarr(npt,3)
	for i= 0, npt-1 do begin
		mat_diag, pressure(i,*), EIG_VAL= val, EIG_VEC= vec
		eig_val(i,*)= val
		eig_vec(i,*)= vec(*,0)
	endfor

	t= eig_val/(2*dens # [1.,1.,1.])
	t_ani= .5*(t(1)+t(2))/t(0)
	s= eig_vec


	if test eq 7 then begin
		t= {ytitle:'T_diag',xtitle:'Time',x:time,y:t}
		store_data,'T_diag', data=t
		t_ani= {ytitle:'T_ani',xtitle:'Time',x:time,y:t_ani}
		store_data,'T_ani', data=t_ani
		s= {ytitle:'S.axis',xtitle:'Time',x:time,y:s}
		store_data,'S.axis', data=s
	endif


return
end

