;+
;FUNCTION: PTRACE()
;PURPOSE: Returns a string that provides the current program location.
;KEYWORDS:
;    OPTION:  The value of the option is retained in a common block
;           OPTION=0  : returns null string
;           OPTION=1  : returns highest level routine name.
;           OPTION=2  : returns highest level routine name (indented).
;           OPTION=3  : returns all levels
;
;Usage: Generally useful for debugging code and following code execution.
;Example:
;  if keyword_set(verbose) then  print,ptrace(),'X=',x
;
;Written:  Jan 2007,  D. Larson
;-
function ptrace,option=option,sublevel=sublevel,dtime=dtime,str

common ptrace_com2,display_option,lasttime ,prefix

if n_elements(dtime) ne 0 then lasttime= keyword_set(dtime) ? systime(1) : 0
if n_elements(option) ne 0 then display_option = option
if n_elements(display_option) eq 0 then display_option = 1
if n_elements(prefix) eq 0 then prefix=''

if display_option eq 0 then return,''

stack = scope_traceback(/structure)
level = n_elements(stack)-1
if keyword_set(sublevel) then level -= sublevel
level = level > 1
stack = stack[0:level-1]

rnames=stack.routine + string(stack.line,format='("(",i0,"): ")')

case display_option of
0:  rnames[*] = ''
1:  if  level ge 2 then rnames[0:level-2] = ''
2:  if  level ge 2 then rnames[0:level-2] = '  '
else:
endcase

res = prefix+strjoin(rnames)

if keyword_set(lasttime) then begin
    newtime=systime(1)
    res = string(format='(f6.3,": ")',newtime-lasttime)+res
    lasttime = newtime
endif

if keyword_set(str) then res = str+res

return,res

end
