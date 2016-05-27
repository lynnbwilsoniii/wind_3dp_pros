;+
;
;Name: is_num
;
;Purpose: determines if input is a number
;
;Inputs: num: the number can be single element or array
;
;Outputs: 1:yes 0:no
;
;Keywords: unsigned: set this if you only want to know if it is
;                    unsigned
;          signed: set this if you only want to know if it is signed
; 
;          real: set this if you want to know only if it is real
;
;          complex: set this if want to know only if it is complex
;
;          floating: set this if you want to know if it is floating
;                    point
;          
;          integer: set this is you want to know if it is not floating point
;          
;          single: set this if you want to know if it is single precision floating point
;          
;          double: set this if you want to know if it is double precision floating point
;
;
; NOTES: if you can think of other classes of number worth testing
;that involve more than one idl type feel free to add
;        if you specify and impossible numerical class like: 
;        b = is_num(1,/signed,/unsigned) 
;           -or-
;        b = is_num(1,/unsigned,/complex)
;
;        it will return 0
;
;LAST MODIFICATION:  02/11/01
; $LastChangedBy: davin-win $
; $LastChangedDate: 2007-10-22 07:26:16 -0700 (Mon, 22 Oct 2007) $
; $LastChangedRevision: 1758 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/ssl_general/trunk/tplot/tplot.pro $
;-

function is_num,num,unsigned=unsigned,signed=signed,real=real,floating=floating,integer=integer,single=single,double=double

  t = size(num,/type)

  ;unsigned integral types
  if (t eq 1 || $
      t eq 12 || $
      t eq 13 || $
      t eq 15) && $
     ~keyword_set(signed) && $
     ~keyword_set(floating) && $
     ~keyword_set(complex) $
  then return,1
  
  ;signed integral types
  if (t eq 2 || $
      t eq 3 || $
      t eq 14) && $
     ~keyword_set(unsigned) && $
     ~keyword_set(floating) && $
     ~keyword_set(complex) $
  then return,1

  ;single precision floating
  if t eq 4 && $
     ~keyword_set(unsigned) && $
     ~keyword_set(integer) && $
     ~keyword_set(complex) && $
     ~keyword_set(double) $
  then return,1
  
  ;double precision floating
   if t eq 5 && $
     ~keyword_set(unsigned) && $
     ~keyword_set(integer) && $
     ~keyword_set(complex) && $
     ~keyword_set(single) $
  then return,1

  ;complex types
  if (t eq 6 || $
      t eq 9) && $
     ~keyword_set(unsigned) && $
     ~keyword_set(integer) && $
     ~keyword_set(complex) $
  then return,1

  return,0
  

end
