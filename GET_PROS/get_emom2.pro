;+
;PROCEDURE:	get_emom2
;PURPOSE:	
;  Gets eesa moment structure.
;INPUT:	
;	none, but "load_3dp_data" must be called 1st.
;KEYWORDS:
;   POLAR
;   VTHERMAL
;CREATED BY:	Davin Larson
;FILE:  get_emom2.pro
;VERSION:  1.3
;LAST MODIFICATION:  97/11/14
;
;
; MODIFIED BY: Lynn B. Wilson III
;  DATE MODIFIED: 06-13-2007
;-


pro get_emom2,data=data,polar=polar,vthermal=vthermal, $
    no_tplot=no_tplot,mag_name=mag_data

@wind_com.pro
if n_elements(wind_lib) eq 0 then begin
   print,'You must first load some data'
   return
endif

mom={momdata,charge:0,mass:0.d,dens:0.d,temp:0.d,vel:dblarr(3), $
   vv:dblarr(3,3),q:dblarr(3)}

;*****************************************************************************
;** Structure MOMDATA, 7 tags, length=152, data length=146:
;   CHARGE          INT              0
;   MASS            DOUBLE           0.0000000
;   DENS            DOUBLE           0.0000000
;   TEMP            DOUBLE           0.0000000
;   VEL             DOUBLE    Array[3]
;   VV              DOUBLE    Array[3, 3]
;   Q               DOUBLE    Array[3]




moment={emoment_str,time:0.d,spin:0,gap:0,valid:0, $
   cmom:bytarr(14),dist:mom}
   
;*****************************************************************************
;** Structure EMOMENT_STR, 6 tags, length=184, data length=174:
;   TIME            DOUBLE           0.0000000
;   SPIN            INT              0
;   GAP             INT              0
;   VALID           INT              0
;   CMOM            BYTE      Array[14]
;   DIST            STRUCT    -> MOMDATA Array[1]
;*****************************************************************************
;** Structure MOMDATA, 7 tags, length=152, data length=146:
;   CHARGE          INT              0
;   MASS            DOUBLE           0.0000000
;   DENS            DOUBLE           0.0000000
;   TEMP            DOUBLE           0.0000000
;   VEL             DOUBLE    Array[3]
;   VV              DOUBLE    Array[3, 3]
;   Q               DOUBLE    Array[3]




rec_len = long( n_tags(moment,/length) )

num = call_external(wind_lib,'emom_to_idl')
if num le 0 then begin
  message,/info,'No electron moment data during this time'
  return
endif

data = replicate(moment,num)
vv_uniq = [0,4,8,1,2,5]
vv_trace = [0,4,8]

sze = call_external(wind_lib,'emom_to_idl',num,rec_len,data)

if not keyword_set(no_tplot) then begin
time = ptr_new(data.time)

;*****************************************************************************
; The mass is actually a compilation of values
;  m_e/K_B = 6.59767e-8 (deg K s^2/m^2)
;  The velocities are in km/s => need to convert
;  Since it's v^2, then the conversion factor is 10^6
; 10.^6 * 6.59767e-8 = 0.0659767 (" ")
;
; The energy associated w/ 1 deg K = 8.6174e-5 eV
;
; => 0.0659767*8.6174e-5 = 5.68548e-6
;
; mass eV/(km/sec)^2

mass = 5.6856591e-6 

;*****************************************************************************
;DATA            STRUCT    = -> EMOMENT_STR Array[2480]
;
;3dp> help,data,/str
;
;** Structure EMOMENT_STR, 6 tags, length=184, data length=174:
;   TIME            DOUBLE       8.7649604e+08
;   SPIN            INT         -28144
;   GAP             INT              1
;   VALID           INT              1
;   CMOM            BYTE      Array[14]
;   DIST            STRUCT    -> MOMDATA Array[1]
;
;3dp> help,data.dist,/str
;
;** Structure MOMDATA, 7 tags, length=152, data length=146:
;   CHARGE          INT             -1
;   MASS            DOUBLE       5.6856591e-06
;   DENS            DOUBLE           15.125648
;   TEMP            DOUBLE           6.7558124
;   VEL             DOUBLE    Array[3]
;   VV              DOUBLE    Array[3, 3]
;   Q               DOUBLE    Array[3]
;
;
;
; Therefore there are 2480 of each data.dist calculation!
;*****************************************************************************

;corrections: 
data.dist.vv[0,0] = data.dist.vv[0,0] / 1.115
data.dist.vv[1,1] = data.dist.vv[1,1] / 1.115
data.dist.vv[2,2] = data.dist.vv[2,2] / 1.023
data.dist.vv[0,2] = -data.dist.vv[0,2]
data.dist.vv[1,2] = -data.dist.vv[1,2]

data.dist.vv[2,0] = data.dist.vv[0,2]
data.dist.vv[2,1] = data.dist.vv[1,2]

;*****************************************************************************

store_data,'Ne',data={x:time, y:data.dist.dens}
store_data,'Te',data={x:time, y:data.dist.temp}
store_data,'Ve',data={x:time, y:transpose(data.dist.vel)}
store_data,'VVe',data={x:time, y:transpose(data.dist.vv(vv_uniq))}
store_data,'Qe',data={x:time, y:transpose(data.dist.q)}

;*****************************************************************************


t3arr = replicate(!values.f_nan,num,3)
symmarr = replicate(!values.f_nan,num,3)

;*****************************************************************************
;- !values.f_nan is a read only variable that is a single precision 
;  floating NaN
;- replicate creates an array with the desired dimensions and values defined
;  when calling the command

if n_elements(magdir) ne 3 then magdir=[-1.,1.,0.]

magfn = magdir/sqrt(total(magdir^2)) 

;*****************************************************************************
for i=0l,num-1 do begin

   dens = data[i].dist.dens
   vel = data[i].dist.vel
   
;   t3x3 = (data[i].dist.vv) * mass

   t3x3 = (data[i].dist.vv - (vel # vel)) * mass
   t3evec = t3x3
   
   
   t3 = replicate(!values.f_nan,3)
   
   if total(t3evec[[1,3,8]]) gt 0. then begin
   
      trired,t3evec,t3,dummy
      triql,t3,dummy,t3evec

      s = sort(t3)
      if t3[s[1]] lt .5*(t3[s[0]] + t3[s[2]]) then n=s[2] else n=s[0]

      shft = ([-1,1,0])[n] 
      t3 = shift(t3,shft)
      t3evec = shift(t3evec,0,shft)

      dot =  total( magfn * t3evec[*,2] )
      if dot lt 0 then t3evec = -t3evec
      symm = t3evec[*,2]
      
;     symm_ang = acos(abs(dot)) * !radeg

      magdir = symm
      t3arr[i,*]= t3
      symmarr[i,*] = symm
      
   endif
   
endfor
;*****************************************************************************

store_data,'T3e',data={x:time, y:t3arr}
store_data,'SDe',data={x:time, y:symmarr}

;*****************************************************************************

if keyword_set(mag_data) then begin

   magf = data_cut(mag_data,data.time)
   mt3e = replicate(!values.f_nan,num,3)

   for i=0l,num-1 do begin
   
      rot = rot_mat(reform(magf[i,*]))
      t3x3 = (data[i].dist.vv - (vel # vel)) * mass
      tp3x3 = transpose(rot) # (t3x3 # rot)
      mt3e[i,*] = tp3x3[[0,4,8]]
      
   endfor

   store_data,'MT3e',data={x:time,y:mt3e}
   
endif
stop
;*****************************************************************************

if not keyword_set(polar) then xyz_to_polar,'Ve',/ph_0_360

if not keyword_set(vthermal) then begin
   vthe = sqrt(total(data.dist.vv(vv_trace),1))
   store_data,'VTHe',data={x:time, y:vthe}
endif

endif


return
end


