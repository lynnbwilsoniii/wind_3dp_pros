FUNCTION t3time,x

ON_ERROR,1
;xx = 3000.0*(double(indgen(n_elements(x)*20))) - 28500.0 + double(x(0))
xx = 3.0*(double(indgen(n_elements(x)*20)))-28.5 + double(x(0))
return,xx
end

