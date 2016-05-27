function func,x,parameter=p
;common func_com,func_parameter
;ptype = size(p,/type)
;valid = (ptype eq 8 or ptype eq 7)
;if not valid then p=func_parameter
f = (size(/type,p) eq 8) ? call_function(p.func,x,param=p) : call_function(p,x)
;if valid then func_parameter=p
return,f
end
