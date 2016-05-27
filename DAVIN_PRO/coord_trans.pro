;	Procedure coord_trans
;
; 	Purpose: transform vectors from one coordinate system to another.
;		
;
;	Input: 	(1) a structure of the form d.x and d.y where d.x contains the
;		time array and d.y the vector array
;		(2) a string indicating the type of transformation
;		example: 'GSEGSM' does the GSE to GSM transformation
;
;	Output: a structure which contains the transformed vector
;
;	Note: At present, this routine can perform the 'GSEGSM', 'GSMGSE',
;		'GEIGSE','GSEGEI' transformations
;
;	Created by: Tai Phan
;
;	First version: 95-10-28
;	last modified: 96-08-20

pro coord_trans, str_in, str_out, type

get_data, str_in, data=d


npt= n_elements(d.x)
vec_out= dblarr(npt,3) 

case type of

'GSEGSM':	begin
		for i=0l, long(npt-1) do begin
		rotmat, d.x(i), GEOGEI, GEIGSE, GEIGSM, GEISM, GEIGSQ,$
 			GEIGSR,DGEI,RGEI,S
		if (npt ne 1) then begin
		vec_out(i,*)= transpose(geigse)#reform(d.y(i,*))
		vec_out(i,*)= geigsm#reform(vec_out(i,*))
		endif else begin
		vec_out(i,*)= transpose(geigse)#d.y(*)
		vec_out(i,*)= geigsm#reform(vec_out(i,*))
		endelse
		endfor
		end

'GSESM':	begin
		for i=0l, long(npt-1) do begin
		rotmat, d.x(i), GEOGEI, GEIGSE, GEIGSM, GEISM, GEIGSQ,$
 			GEIGSR,DGEI,RGEI,S
		if (npt ne 1) then begin
		vec_out(i,*)= transpose(geigse)#reform(d.y(i,*))
		vec_out(i,*)= geism#reform(vec_out(i,*))
		endif else begin
		vec_out(i,*)= transpose(geigse)#d.y(*)
		vec_out(i,*)= geism#reform(vec_out(i,*))
		endelse
		endfor
		end



'GSMGSE':	begin
		for i=0l, long(npt-1) do begin
		rotmat, d.x(i), GEOGEI, GEIGSE, GEIGSM, GEISM, GEIGSQ,$
 			GEIGSR,DGEI,RGEI,S
		if (npt ne 1) then begin
		vec_out(i,*)= transpose(geigsm)#reform(d.y(i,*))
		vec_out(i,*)= geigse#reform(vec_out(i,*))
		endif else begin
		vec_out(i,*)= transpose(geigsm)#d.y(*)
		vec_out(i,*)= geigse#reform(vec_out(i,*))
		endelse
		endfor
		end


'GSEGEI':	begin
		for i=0l, long(npt-1) do begin
		rotmat, d.x(i), GEOGEI, GEIGSE, GEIGSM, GEISM, GEIGSQ,$
 			GEIGSR,DGEI,RGEI,S
		if (npt ne 1) then begin
		vec_out(i,*)= transpose(geigse)#reform(d.y(i,*))
		endif else begin
		vec_out(i,*)= transpose(geigse)#d.y(*)
		endelse

		endfor
		end


'GEIGSE':	begin
		for i=0l, long(npt-1) do begin
		rotmat, d.x(i), GEOGEI, GEIGSE, GEIGSM, GEISM, GEIGSQ,$
 			GEIGSR,DGEI,RGEI,S
		if (npt ne 1) then begin
		vec_out(i,*)= geigse#reform(d.y(i,*))
		endif else begin
		vec_out(i,*)= geigse#d.y(*)
		endelse
		endfor
		end

endcase



store_data,str_out,data={ytitle:str_out,xtitle:'Time',x:d.x,y:vec_out}


end
