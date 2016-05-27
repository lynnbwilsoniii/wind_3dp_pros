function fill_nan,data,intfill=intfill

if n_elements(intfill) eq 0 then intfill=0
dt = data_type(data)
rdat = data
case dt of
1:  rdat[*] = intfill
2:  rdat[*] = intfill
3:  rdat[*] = intfill
4:  rdat[*] = !values.f_nan
5:  rdat[*] = !values.d_nan
6:  rdat[*] = !values.f_nan
7:  rdat[*] = ''
8:  begin
      n = n_tags(rdat)
      for i=0,n-1 do rdat.(i) = fill_nan(rdat.(i),intfill=intfill)
    end
9:  rdat[*] = !values.d_nan
else:  message,/info,'Data type not implemented'
endcase
return,rdat
end

