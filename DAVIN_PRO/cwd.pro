pro cwd,newdir,pick=pick,current=current,finaldir=finaldir
if keyword_set(pick) then newdir = DIALOG_PICKFILE(/DIRECTORY)
if keyword_set(newdir) then cd,newdir,current=current
cd,current=finaldir
if keyword_set('IDL_PROMPT') then  !prompt=getenv('IDL_PROMPT')+'->'+finaldir+'> '
end