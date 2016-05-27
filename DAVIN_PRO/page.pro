pro page,message,address,subject=subject,delay_time=delay_time

common page_com,last_time,last_messages,last_count

current_time = systime(1)
if not keyword_set(last_count) then last_count = 0
if not keyword_set(delay_time) then delay_time = 300.
if not keyword_set(last_time) then last_time = 0.d

last_count=last_count+1

if size(/type,message) ne 7 then message='No message.'
if not keyword_set(address) then address='davin@ssl.berkeley.edu'

messages = [message,'Number: '+string(last_count),'Host: '+getenv('HOST'),'User: '+getenv('USER'),'Time: '+systime()]
help,calls = calls
messages = [messages,calls]
cr = string(13b)+string(12b)+string(11b)
command = 'echo '+"'"+strjoin(messages,cr)+"'"+' | mailx '
if keyword_set(subject) then command = command+"-s '"+subject+"' "
command = command+strjoin(address,' ')

logfile = '/tmp/idl_page_errors.log'
openw,/get_lun,lun,logfile,/append
printf,lun
printf,lun,transpose(messages)
free_lun,lun

;print,command
print,transpose(messages)

if current_time gt last_time + delay_time then begin
   spawn,command,result,count=c
   last_time = current_time
endif else begin
   print,'Mail not sent! Check file: ',logfile
endelse

end

