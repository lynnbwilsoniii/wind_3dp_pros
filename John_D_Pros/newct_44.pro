;; Create New Color Table by intepolating between set of defined
;; fixed colors

pro newct_44,tbl_num,tbl_name


;; Set Table number and name

  if not keyword_set(tbl_num) then tbl_num=41
  if not keyword_set(tbl_name) then tbl_name='no name'


;; Set number of fixed points and allocate fixed points
;; evenly though the 256 color points

  num_fixpts = 8
  max_count = num_fixpts - 1
  fix_pt_arr=make_array(num_fixpts)
  for x=0,max_count do fix_pt_arr(x)=round(x*255./max_count)
  fix_val_arr=make_array(3,num_fixpts)


;; Example Fixed Color Arrays
;;  Note:  Pure colors generally need to be tinted so transitions are
;;         smooth

;; Pure Colors
; fix_val_arr(*,0)=[238,0,0]           ; red
; fix_val_arr(*,1)=[255,165,0]         ; orange
; fix_val_arr(*,2)=[255,255,0]         ; yellow
; fix_val_arr(*,3)=[0,255,0]           ; green
; fix_val_arr(*,4)=[0,255,255]         ; cyan
; fix_val_arr(*,5)=[0,0,255]           ; blue
; fix_val_arr(*,6)=[158,48,255]        ; purple
; fix_val_arr(*,7)=[0,0,0]             ; black

;; (41) Smooth Rainbow + Black
; fix_val_arr(*,0)=[200,0,0]           ; dark red
; fix_val_arr(*,1)=[255,80,0]          ; bright red
; fix_val_arr(*,2)=[255,180,0]         ; orange
; fix_val_arr(*,3)=[255,255,0]         ; yellow
; fix_val_arr(*,4)=[190,255,0]         ; yellow-green
; fix_val_arr(*,5)=[40,170,50]         ; green
; fix_val_arr(*,6)=[0,110,120]         ; blue-green
; fix_val_arr(*,7)=[40,30,140]         ; blue
; fix_val_arr(*,8)=[70,20,100]         ; purple
; fix_val_arr(*,9)=[15,0,30]           ; 'black' (purple tint)
 
;; (42) Smooth Rainbow to White
; fix_val_arr(*,0)=[200,0,0]           ; dark red
; fix_val_arr(*,1)=[255,80,0]          ; bright red
; fix_val_arr(*,2)=[255,180,0]         ; orange
; fix_val_arr(*,3)=[255,255,0]         ; yellow
; fix_val_arr(*,4)=[190,255,0]         ; yellow-green
; fix_val_arr(*,5)=[40,170,50]         ; green
; fix_val_arr(*,6)=[0,110,120]         ; blue-green
; fix_val_arr(*,7)=[30,60,140]         ; blue
; fix_val_arr(*,8)=[90,30,140]         ; purple
; fix_val_arr(*,9)=[220,200,230]       ; 'white' (purple tint)

;; (43) Smooth Rainbow 
  fix_val_arr(*,0)=[150,0,0]           ; dark red
  fix_val_arr(*,1)=[255,65,0]          ; bright red
  fix_val_arr(*,2)=[255,135,0]         ; orange
  fix_val_arr(*,3)=[255,235,0]         ; yellow
; fix_val_arr(*,4)=[190,255,0]         ; yellow-green
  fix_val_arr(*,4)=[210,255,0]         ; yellow-green
  fix_val_arr(*,5)=[40,170,50]         ; green
; fix_val_arr(*,6)=[0,110,120]         ; blue-green
; fix_val_arr(*,6)=[30,60,140]         ; blue
  fix_val_arr(*,6)=[40,70,135]         ; blue
  fix_val_arr(*,7)=[70,20,100]         ; purple
; fix_val_arr(*,7)=[100,40,160]        ; bright purple
 

;; Set 'broadness' number for amount of 'spreading' of fixed colors

  broadness = 0.2
  sharpness = 1.0 - broadness    ; Modify broadness Only, Not sharpness


;; Interpolate colors between fixed values an spread as appropriate

  rgb_arr=make_array(3,256,/integer)
  for x=1,max_count do begin
    dif=fix_pt_arr(x)-fix_pt_arr(x-1)
    for y=1,dif do                                                      $
     rgb_arr(*,255-(fix_pt_arr(x-1)+y))                                 $
        = round((sharpness*float(y)/dif                                 $
         + broadness*(1-cos(float(y)/dif*!PI))/2)                       $
         * (fix_val_arr(*,x)-fix_val_arr(*,x-1))+fix_val_arr(*,x-1))
  endfor


;; Shift

  orig_arr=make_array(4,256,/float,value=0.)
  orig_arr(0,*)=findgen(256)
  orig_arr(1:3,*)=rgb_arr(*,*)
  shift_arr=make_array(256,/float,value=0.)
  for x=1,254 do begin
    if x lt 128 then begin
      shift_arr(x)=146*(1+(float(x)-127)/126)+1
    endif else begin
      shift_arr(x)=106*(float(x)-128)/126+148
    endelse
  endfor

  rgb_arr(0,*)=round(interpol(orig_arr(1,*),orig_arr(0,*),shift_arr(*)))
  rgb_arr(1,*)=round(interpol(orig_arr(2,*),orig_arr(0,*),shift_arr(*)))
  rgb_arr(2,*)=round(interpol(orig_arr(3,*),orig_arr(0,*),shift_arr(*)))

;; Set -- NaN = Black, Text = White

  rgb_arr(*,0)=[0,0,0]
  rgb_arr(*,255)=[255,255,255]

;; Save new Color Table

  modifyct,tbl_num,tbl_name,rgb_arr(0,*),rgb_arr(1,*),rgb_arr(2,*),   $
    file='/home/johnd/idl/common/colors1.tbl'
    
return
end
