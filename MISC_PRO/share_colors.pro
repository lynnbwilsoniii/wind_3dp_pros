;+
;PROCEDURE:
;  share_colors
;PURPOSE:
;  Procedure that allows multiple IDL sessions to share the same color table.
;  The procedure should be called in each session before any 
;  windows are created.
;USAGE:
;  Typically this procedure will be put in a startup routine. such as: 
;  share_colors,first=f
;  if f then loadct,39   
;
;KEYWORDS:
;  FIRST Named variable that will be set to 1 if this is the
;      first session, and set to 0 otherwise.
;SIDE EFFECTS:
;  Creates a temporary file with the name 'idl_cmap:NAME' on the users home
;  directory where NAME is the name of the display machine.
;  This file is deleted upon exiting IDL.
;  The procedure is only useful on UNIX for users with a common home directory.
;-
pro share_colors,filename=fname,lun=lun,first=first,colors=colors

if !d.name ne 'X' then begin
  message,/info,'Device not "X"!'
  first=1
  return
endif

path = getenv('HOME')
disp = getenv('DISPLAY')
machine = str_sep(disp,':')
machine = machine(0)
if not keyword_set(machine) then machine = getenv('HOST')
fname = path+'/idl_cmap:'+machine

on_ioerror,create

openr,lun,fname,/get_lun
message,/info,'Using translation table defined in file: '+fname
id=0l
n=0l
readu,lun,id,n
t = bytarr(n)
readu,lun,t
close,lun
device,set_trans = t
window,colors=n
;Note file is NOT closed. It will be closed on exit
first = 0
return

create:
on_ioerror,null
openw,lun,fname,/get_lun,/delete
message,/info,'First Session; created translation table file: '+fname
if keyword_set(colors) then window,get_x_id=id,colors=colors $
else window,get_x_id=id
device,trans = t
n = !d.n_colors
writeu,lun,id,n,t(0:n-1)
flush,lun
; Note file is NOT closed. It will be closed on exit
first=1
return
end
