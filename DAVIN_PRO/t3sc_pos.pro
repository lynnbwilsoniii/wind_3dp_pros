; input: s/c positions x at times t
; output: s/c positions at time t3
; cerated by Tai Phan: Oct 3, 1995

FUNCTION t3sc_pos,d,t,t3

ON_ERROR,1
pos= {x:t,y:d}
xx= data_cut(pos,t3)

return,xx
end

