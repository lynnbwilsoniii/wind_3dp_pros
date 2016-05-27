; +
;PROCEDURE:      cal_bs_param,pos,magf,BOW=bow,VEL=vel,VSW=vsw
;PURPOSE:
;       Procedure returns parameters that describe intersection w/ Bow Shock.
;INPUT: 
;       pos:    vector(3),  [Xs,Ys,Zs] s/c position in GSE with units of Re
;       magf:   vector(3),  [Bx,By,Bz] magnetic field vector.
;OPTIONS 
;       BOW:    structure       Structure containing {L,ecc,X0}
;               L:      scalar,         standoff parameter with units of Re
;               ecc:    scalar,         eccentricity of shock
;               X0:     scalar,         focus location in Re 
;       VEL:    scalar,         parallel particle velocity along magnetic field
;       VSW:    vector,         solar wind velocity, same units as VEL
;
;       hyperbolic bow shock, see JGR 1981, p.11401, Slavin Fig.7
;       r = L/(1+ecc*cos(theta))
;       1 = (x-x0-c)^2/a^2 + (y^2+z^2)/b^2
;       default L = b^2/a = 23.5
;               ecc = c/a = 1.15
;               x0= 3
;               c = (a^2 + b^2)^.5 = L*e/(e^2-1) = 83.8
;               a = L/(e^2-1) = 72.87
;               b = L/(e^2-1)^.5 = 41.38
;OUTPUTS:    (All through keywords)
;       BSN is the angle between the shock normal and the
;              field line that passes through the s/c.
;       LSN is the distance along the field line to the shock.
;       NSN is the distance from shock nose to field line crossing.
;       SHPOS is the position at the shock-B intersection.
;       SHNORM is the shock normal vector.
;       CONNECT is 0 if unconnected,  1 if connected.
;       STRUCT:  a structure to which all these parameters are added.
;
;NOTES: 
;       see "get_bsn", "add_bsn"
;
;CREATED BY:
;       J.McFadden      95-9-20
;LAST MODIFICATION:  95/10/17
;       95-10-5 McFadden    Added BOW keyword.
;       95-10-0 Larson   Major Mods   changed to procedure. Added shock normal
; -
pro cal_bs_param,pos,magf,bow=bow,vpar=vpar,vsw=vsw,  $
   shpos   = shpos, $
   shnorm  = shnorm, $
   BSN     = bsn,  $
   LSN     = lsn,   $
   NSN     = nsn,   $
   CONNECT = connect,  $
   STRUCT  = struct
   

if data_type(bow) ne 8 then $
    bow={standoff:23.3,eccentricity:1.16,x_offset:3.0}

missing = !values.f_nan
shpos = replicate(missing,3)
shnorm = replicate(missing,3)
bsn = missing
lsh = missing
nsn = missing
connect = missing
 
L=bow.standoff
ecc=bow.eccentricity
x0=bow.x_offset

if not keyword_set(vel) then vel=3.e5
if not keyword_set(vsw) then vsw=[0.,0.,0.]
bfld = magf/sqrt(total(magf^2))    ; normalize
x0=1.d*x0
y0=0.d
z0=0.d
a = L/(ecc^2-1)
b = L/(ecc^2-1)^.5
c = L*ecc/(ecc^2-1)
nsh = [c+x0+a,0,0]

x1=pos(0)-x0-c
y1=pos(1)-y0
z1=pos(2)-z0
a1 = b^2*bfld(0)^2 - a^2*(bfld(1)^2+bfld(2)^2)
b1 = 2*b^2*bfld(0)*x1 - 2*a^2*(bfld(1)*y1+bfld(2)*z1)
c1 = b^2*x1^2 - a^2*(y1^2+z1^2+b^2)

b24ac= b1^2-4*a1*c1
if b24ac ge 0 then begin

   l1 = (-b1+(b24ac)^.5)/(2.*a1)
   l2 = (-b1-(b24ac)^.5)/(2.*a1)

   sh1 = pos + l1 * bfld
   sh2 = pos + l2 * bfld
;   sh1=[pos(0)+l1*bfld(0),pos(1)+l1*bfld(1),pos(2)+l1*bfld(2)]
;   sh2=[pos(0)+l2*bfld(0),pos(1)+l2*bfld(1),pos(2)+l2*bfld(2)]
   connect = 1

   if sh1(0) gt nsh(0) and sh2(0) gt nsh(0) then begin 
;       print,'B field line does not cross shock'
       connect = 0
   endif else if sh1(0) gt nsh(0) then begin
       shpos=sh2
       lsh=l2
   endif else if sh2(0) lt nsh(0) and abs(l1) gt abs(l2) then begin
       shpos=sh2
       lsh=l2
   endif else begin
       shpos=sh1
       lsh=l1
   endelse

 if abs(1-(shpos(0)-x0-c)^2/a^2+(shpos(1)^2+shpos(2)^2)/b^2) gt .0001 then begin
        print,' Shock calculation error!!!'
 endif

; use gradient to dermine shock normal
   shnorm = [2/a^2 , -2/b^2, 2/b^2] * shpos
   shnorm = shnorm/sqrt(total(shnorm^2))        ; normalize it


   bsn= !radeg*acos(total(shnorm*bfld))
endif

add_str_element,struct,'connect',connect
add_str_element,struct,'shpos',shpos
add_str_element,struct,'shnorm',shnorm
add_str_element,struct,'bsn',bsn
add_str_element,struct,'lsn',lsh

return

end
