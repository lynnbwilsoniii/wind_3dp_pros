;          
;                     POLARWAVE.PRO
;
;                written by John Dombeck
;                  Univ. of Minnesota
;                       09/18/98
;
;                       ver. 1.0
;                       09/18/98
;
;
;   TO RUN THIS PROGRAM, from IDL type:
;    '.run polarwave.pro'
;    'go_polarwave'
;
; (The following procedure contains the basic program directions)
;  (programming comments follow the procedure)
;
;
; Program adapted from DELAYTIME.PRO ver 2.0
;
;
;
;


pro helpout

print    
print,'                 POLARWAVE.PRO  ver. 1.0  09/18/98                    '
print
print,'       written by John Dombeck, Univ. of Minnesota, 9/18/98          '
print
end


;   ***   MAIN WIDGETS   ***


;* MODEWIDG_EVENT *  xmanager control for the IDL mode widget

pro modewidg_event,event
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  widget_control,event.id,get_uvalue=evtval
  case evtval of
    'demo':begin
             demo=1             ;set mode to IDL demo
             help=0             ;set help to NO HELP
           end
    'std':begin
             demo=0              ;set mode to IDL normal
             help=0             ;set help to NO HELP
           end
    'help':help=1             ;set help to PRINT HELP
  endcase
  widget_control,event.top,/destroy
end


;* MODEWIDG *  widget to determine IDL mode, or print help screen

pro modewidg,group=group

  base=widget_base(title='IDL Mode',xoffset=2.0,xsize=157,/row)
  but=widget_button(base,value='Normal',uvalue='std')
  but=widget_button(base,value='Demo',uvalue='demo')
  but=widget_button(base,value='Help',uvalue='help')
  widget_control,base,/realize
  xmanager,'modewidg',base,group_leader=group
end


;* PRNTRWIDG_EVENT *  xmanager control for the printer select widget

pro prntrwidg_event,event
common prntr,prtr

  widget_control,event.id,get_uvalue=evtval
  case evtval of
    'spr1':prtr="spr1"
    'hp2':prtr="hp2"
    'file':prtr="file"
  endcase
  widget_control,event.top,/destroy
end


;* PRNTRWIDG *  widget to select printer for output

pro prntrwidg,group=group

  base=widget_base(title='Printer',xoffset=2.0,xsize=210,/row)
  but=widget_button(base,value='hp2',uvalue='hp2')
  but=widget_button(base,value='spr1',uvalue='spr1')
  but=widget_button(base,value='File Only',uvalue='file')
  widget_control,base,/realize
  xmanager,'prntrwidg',base,group_leader=group
end


;* DATEWIDG_EVENT *  xmanager control for getting the date

pro datewidg_event,event
common dt,date,mnth,day,yr
common dtfields,flds

  widget_control,event.id,get_uvalue=evtval
  widget_control,event.id,get_value=val

  if evtval eq 'mnth' then mnth=val $
  else if evtval eq 'day' then day=val $
  else if evtval eq 'year' then yr=val

  if evtval eq 'DONE' then begin
    widget_control,flds(0),get_value=val
    mnth=val[0]
    widget_control,flds(1),get_value=val
    day=val[0]
    widget_control,flds(2),get_value=val
    yr=val[0]
    datestr=string(format='(I4.4,"-",I2.2,"-",I2.2,"/00:00:00")',yr,mnth,day)
    date=time_double(datestr)
    widget_control,event.top,/destroy
  endif

  if evtval eq 'exit' then begin
    widget_control,event.top,/destroy
    print
    print
    print,'Program time_shock.pro ended by user'
    print
    print,'WARNING -- Please exit and re-enter IDL before running'
    print,'           another (or the same) IDL program to assure'
    print,'           system integrity.'
    print
    stop
  endif
end


;* DATEWIDG *  widget to enter data date

pro datewidg,group=group
common dt,date,mnth,day,yr
common dtfields,flds

  base=widget_base(title='Enter Data Date',/row,xoffset=2.0)
  fld0=cw_field(base,title='Month',value=mnth,uvalue='mnth', $
         xsize=3,/return_events)
  flds=replicate(fld0,3)
  flds(0)=fld0
  flds(1)=cw_field(base,title='Day',value=day,uvalue='day', $
         xsize=3,/return_events)
  flds(2)=cw_field(base,title='Year',value=yr,uvalue='year', $
         xsize=6,/return_events)
  lbl=widget_label(base,value='   ')
  done=widget_button(base,value='  Done  ',uvalue='DONE')
  lbl=widget_label(base,value=' ')
  but=widget_button(base,value='Exit Program',uvalue='exit')
  lbl=widget_label(base,value=' ')
  widget_control,base,/realize
  xmanager,'datewidg',base,group_leader=group
end


;* TIMEWIDG_EVENT *  xmanager control for Time Range widget

pro timewidg_event,event
common times,bgtim,edtim,bgstr,edstr,bgtimlmt,edtimlmt,bgstrlmt,edstrlmt
common timeid,time1,time2
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  widget_control,event.id,get_uvalue=evtval
  case evtval of
    'done':begin
             widget_control,time1,get_value=inpstr   ;Get time range for
             bgstr=inpstr(0)                         ;Analysis
             widget_control,time2,get_value=inpstr   ;xxstr=inpstr(0) needed
             edstr=inpstr(0)                         ;to eliminate array
             
             hr=strmid(bgstr,0,2)
             mn=strmid(bgstr,3,2)
             sc=strmid(bgstr,6,10)
             bgtim=double(hr)*3600+double(mn)*60+double(sc)
             hr=strmid(edstr,0,2)                            ;Convert time
             mn=strmid(edstr,3,2)                            ;strings to
             sc=strmid(edstr,6,10)                           ;seconds
             edtim=double(hr)*3600+double(mn)*60+double(sc)
           end
    'full': begin
              bgtim=bgtimlmt                ;Use Entire allowable range
              edtim=edtimlmt
              bgstr=bgstrlmt
              edstr=edstrlmt
            end
  endcase
  widget_control,event.top,/destroy
end


;* TIMEWIDG *  widget to determine Time Range for Analysis

pro timewidg,group=group
common times,bgtim,edtim,bgstr,edstr,bgtimlmt,edtimlmt,bgstrlmt,edstrlmt
common timeid,time1,time2

  base=widget_base(title='Time Range',xoffset=2.0,xsize=245,/column)
  txt=widget_text(base,value='Use 2-digits for hour and minute')  
  time1=cw_field(base,title='Start Time',value=bgstr)
  time2=cw_field(base,title='End Time  ',value=edstr)
  but=widget_button(base,value='Done',uvalue='done') 
  but=widget_button(base,value='Cancel',uvalue='cancel')
  but=widget_button(base,value='Full Range',uvalue='full')
  widget_control,base,/realize
  xmanager,'timewidg',base,group_leader=group
end


;* MFILEWIDG_EVENT *  xmanager control for input MFE file widget

pro mfilewidg_event,event
common mfiles,mdirc,mfile1,mfile2,mfile3
common files,dirc,file1,file2,file3,file4,file5,file6,sufx,desp
common mfields,mfld0,mfld1,mfld2,mfld3

  widget_control,event.id,get_uvalue=evtval
  widget_control,event.id,get_value=val
  case evtval of
    'dirc':mdirc=val
    'file1':mfile1=val     ;These lines handle if a <CR> is hit while
    'file2':mfile2=val     ;entering data
    'file3':mfile3=val
    'DONE':begin
             widget_control,mfld0,get_value=val
             mdirc=val
             widget_control,mfld1,get_value=val   ;These lines read all
             mfile1=val                           ;four fields when 'DONE'
             widget_control,mfld2,get_value=val   ;is clicked on
             mfile2=val
             widget_control,mfld3,get_value=val
             mfile3=val            
             widget_control,event.top,/destroy
             dirc=mdirc
           end
    'exit':begin
             widget_control,event.top,/destroy
             print
             print
             print,'Program polarwave.pro ended by user'
             print
             print,'WARNING -- Please exit and re-enter IDL before running'
             print,'           another (or the same) IDL program to assure'
             print,'           system integrity.'
             print
             stop
           end
  endcase
end


;* MFILEWIDG *  widget to enter input MFE files and directory

pro mfilewidg,group=group
common mfiles,mdirc,mfile1,mfile2,mfile3
common mfields,mfld0,mfld1,mfld2,mfld3

  base=widget_base(title='Input MFE Files',xoffset=2.0,xsize=255,/column)
  mfld0=cw_field(base,title='Directory',value=mdirc,uvalue='dirc',   $
                   /return_events)
  mfld1=cw_field(base,title='File 1 (MFEX)',value=mfile1,uvalue='file1',$
                   /return_events)
  mfld2=cw_field(base,title='File 2 (MFEY)',value=mfile2,uvalue='file2',$ 
                   /return_events)
  mfld3=cw_field(base,title='File 3 (MFEZ)',value=mfile3,uvalue='file3',$ 
                   /return_events)
  done=widget_button(base,value='Done',uvalue='DONE')
  but=widget_button(base,value='Exit Program',uvalue='exit')
  widget_control,base,/realize
  xmanager,'mfilewidg',base,group_leader=group
end


;* FILEWIDG_EVENT *  xmanager control for input file widget

pro filewidg_event,event
common files,dirc,file1,file2,file3,file4,file5,file6,sufx,desp
common fields,fld0,fld1,fld2,fld3,fld4,fld5,fld6,fld7,fld8

  widget_control,event.id,get_uvalue=evtval
  widget_control,event.id,get_value=val
  if data_type(val) eq 7 then begin
    case evtval of
      'dirc':dirc=val
      'file1':file1=val     ;These lines handle if a <CR> is hit while
      'file2':file2=val     ;entering data
      'file3':file3=val
;     'file4':file4=val
;     'file5':file5=val
;     'file6':file6=val
      'sufx':sufx=val
      'DONE':begin
               widget_control,fld0,get_value=val
               dirc=val
               widget_control,fld1,get_value=val   ;These lines read all
               file1=val                           ;eight fields when 'DONE'
               widget_control,fld2,get_value=val   ;is clicked on
               file2=val
               widget_control,fld3,get_value=val
               file3=val            
;              widget_control,fld4,get_value=val
;              file4=val            
;              widget_control,fld5,get_value=val
;              file5=val            
;              widget_control,fld6,get_value=val
;              file6=val            
               widget_control,fld7,get_value=val
               sufx=val            
               widget_control,fld8,get_value=val
               desp=val[0]
               widget_control,event.top,/destroy
             end
      'exit':begin
               widget_control,event.top,/destroy
               print
               print
               print,'Program polarwave.pro ended by user'
               print
               print,'WARNING -- Please exit and re-enter IDL before running'
               print,'           another (or the same) IDL program to assure'
               print,'           system integrity.'
               print
               stop
             end
    endcase
  endif
end


;* FILEWIDG *  widget to enter input files and directory

pro filewidg,group=group
common files,dirc,file1,file2,file3,file4,file5,file6,sufx,desp
common fields,fld0,fld1,fld2,fld3,fld4,fld5,fld6,fld7,fld8

  base=widget_base(title='Input Data Files',xoffset=2.0,xsize=300,/column)
  fld0=cw_field(base,title='Directory',value=dirc,uvalue='dirc',   $
                   /return_events)
  fld1=cw_field(base,title='File 1 (V1U)',value=file1,uvalue='file1',$
                   /return_events)
  fld2=cw_field(base,title='File 2 (V2U)',value=file2,uvalue='file2',$ 
                   /return_events)
  fld3=cw_field(base,title='File 3 (V3U)',value=file3,uvalue='file3',$ 
                   /return_events)
; fld4=cw_field(base,title='File 4 (V4U)',value=file4,uvalue='file4',$ 
;                  /return_events)
; fld5=cw_field(base,title='File 5 (V12USCPOT)',value=file5,uvalue='file5',$
;                  /return_events)
; fld6=cw_field(base,title='File 6 (V34USCPOT)',value=file6,uvalue='file6',$
;                  /return_events)
  fld7=cw_field(base,title='Suffix',value=sufx,uvalue='sufx',        $
                   /return_events)
  fld8=cw_bgroup(base,['Despin Data'],/column,/nonexclusive,set_value=[desp])

  done=widget_button(base,value='Done',uvalue='DONE')
  but=widget_button(base,value='Exit Program',uvalue='exit')
  widget_control,base,/realize
  xmanager,'filewidg',base,group_leader=group
end


;   ***   END -- MAIN WIDGETS   ***

;

;   ***   VARIABLE INITIALIZATION   ***


;* INIT_DELAYTIME *  initialize global variables that need it at start up
 
pro init_program
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var
common files,dirc,file1,file2,file3,file4,file5,file6,sufx,desp
common mfiles,mdirc,mfile1,mfile2,mfile3
common cnsts,splinefactor,errpct
common satdata,spinper,rate,stagger
common dt,date,mnth,day,yr

  finish=0                      ;set NOT finished
  same=0                        ;set GET new files
  help=1                        ;set PRINT HELP

     ;define filenames as strings

  file1='.B_SCoilX'
  file2='.B_SCoilY'
  file3='.B_SCoilZ'
; file4='.B_V4U'
; file5='.BV12USCPOT'
; file6='.BV34USCPOT'
  desp=0
  dirc='./'
  sufx=''

  mfile1='.MagMFEX'
  mfile2='.MagMFEY'
  mfile3='.MagMFEZ'
  mdirc='./'

     ;Constants

  spinper=5.9
  stagger=0.000025
  splinefactor=5
  errpct=0.2

     ; Date

  mnth=1
  day=1
  yr=2001

end


;* ERR *  report input error without hard crashing the program
;          errstr is the message reported

pro err,errstr

  print
  print
  print,errstr
  print,"Program Halted -- No cleanup needed"
  print,"type 'go_polarwave' to re-run program"
  print
stop
end



;* ERRMFILEWIDG_EVENT *  xmanager control for MFE file error widget

pro errmfilewidg_event,event
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  widget_control,event.id,get_uvalue=evtval
  case evtval of
    'retry':begin
             widget_control,event.top,/destroy
             jump=1
            end
    'exit':begin
             widget_control,event.top,/destroy
             print
             print
             print,'Program polarwave.pro ended by user.'
             print
             print,'WARNING -- Please exit and re-enter IDL before running'
             print,'           another (or the same) IDL program to assure'
             print,'           system integrity.'
             print
             stop
           end
  endcase
end


;* ERRMFILEWIDG *  widget to report error involving MFE files and 
;                   react accordingly

pro errmfilewidg,errstr

  base=widget_base(title='MFE FILE ERROR',xoffset=2.0,xsize=600,/column)
  txt=widget_text(base,value="ERROR -- "+errstr)
  but=widget_button(base,value='Re-enter or Select Different MFE Files', $
        uvalue='retry')
  but=widget_button(base,value='Exit Program',uvalue='exit')
  widget_control,base,/realize
  xmanager,'errmfilewidg',base,group_leader=group
end


;* ERRFILEWIDG_EVENT *  xmanager control for data file error widget

pro errfilewidg_event,event
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  widget_control,event.id,get_uvalue=evtval
  case evtval of
    'mfe':begin
             widget_control,event.top,/destroy
             jump=1
            end
    'data':begin
             widget_control,event.top,/destroy
             jump=2
            end
    'exit':begin
             widget_control,event.top,/destroy
             print
             print
             print,'Program polarwave.pro ended by user'
             print
             print,'WARNING -- Please exit and re-enter IDL before running'
             print,'           another (or the same) IDL program to assure'
             print,'           system integrity.'
             print
             stop
           end
  endcase
end


;* ERRFILEWIDG *  widget to report error involving data files and 
;                   react accordingly

pro errfilewidg,errstr

  base=widget_base(title='Data FILE ERROR',xoffset=2.0,xsize=650,/column)
  txt=widget_text(base,value="ERROR -- "+errstr)
  but=widget_button(base,value='Re-enter or Select Different MFE & Data '$
        +'Files',uvalue='mfe')
  but=widget_button(base,value='Re-enter or Select Different Data Files '$
        +'only',uvalue='data')
  but=widget_button(base,value='Exit Program',uvalue='exit')
  widget_control,base,/realize
  xmanager,'errfilewidg',base,group_leader=group
end

;* ERRGAPWIDG_EVENT *  xmanager control for data file error/de-gap widget
;                      (Note: this procedure is no longer used)


pro errgapwidg_event,event
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  widget_control,event.id,get_uvalue=evtval
  case evtval of
    'mfe':begin
             widget_control,event.top,/destroy
             jump=1
            end
    'data':begin
             widget_control,event.top,/destroy
             jump=2
            end
    'exit':begin
             widget_control,event.top,/destroy
             print
             print
             print,'Program polarwave.pro ended by user'
             print
             print,'WARNING -- Please exit and re-enter IDL before running'
             print,'           another (or the same) IDL program to assure'
             print,'           system integrity.'
             print
             stop
           end
  endcase
end


;* ERRGAPWIDG *  widget to report data file errors that may be corrected 
;                   by de-gaping and react accordingly

pro errgapwidg,errstr

  base=widget_base(title='Data FILE ERROR/DE-GAP?',xoffset=2.0,xsize=650,/column)
  txt=widget_text(base,value="ERROR -- "+errstr)
  txt=widget_text(base,value=" ")
  but=widget_button(base,value='Re-enter or Select Different MFE & Data '$
        +'Files',uvalue='mfe')
  but=widget_button(base,value='Re-enter or Select Different Data Files '$
        +'only',uvalue='data')
  but=widget_button(base,value='Exit Program',uvalue='exit')
  widget_control,base,/realize
  xmanager,'errgapwidg',base,group_leader=group
end

;   ***   END -- VARIABLE INITIALIZATION   ***

;

;   ***   DATA INPUT   ***


;* FINDSTRT *  set file pointer to the start of data portion of an input file

pro findstrt

  c='' & c1='' & inp=''

  ;  In SDT the data always starts after a line with "Component Depths" in it
  ;  However, sometimes SDT messes up and the data doesn't start after the 
  ;  first such line.  Luckily on the bogus lines, the "Component Depths"
  ;  is always followed by an "S" in the 16th character spot.  This character
  ;  is a number in a good line.

  while (((c ne "Component Depths") or (c1 eq 'S')) and (not eof(3))) do   $
    begin
      readf,3,inp
      c=strmid(inp,0,16)
      c1=strmid(inp,16,1)
  endwhile
end


;* INPT *  Main input routine.  Calls subroutines and does the actual data
;          reading.

pro inpt
common input,mfe_arr,mnum_elmts,data_arr,num_elmts,num_elmts_arr
common filarr,fil
common mfilarr,mfil
common files,dirc,file1,file2,file3,file4,file5,file6,sufx,desp
common mfiles,mdirc,mfile1,mfile2,mfile3
common times,bgtim,edtim,bgstr,edstr,bgtimlmt,edtimlmt,bgstrlmt,edstrlmt
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var
common cklength,elements
common satdata,spinper,rate,stagger
common dt,date,mnth,day,yr

  outfil=''          ;re-initialize output file to help avoid over-writing

mfe_jump:

  jump=0
  datewidg
  mfilewidg          ;get mfe file names

  mfil=strarr(3)
  mfil(0)=mdirc+mfile1  ;append mfe filenames to the directory prefix
  mfil(1)=mdirc+mfile2  ;and put the filenames into an array
  mfil(2)=mdirc+mfile3

  if not mread_sdt(mfil,mfe_data,names,/verbose) then goto,mfe_jump
  data=ptrarr(3)
  data(0)=ptr_new(*mfe_data[0])
  data(1)=ptr_new(*mfe_data[1])
  data(2)=ptr_new(*mfe_data[2])
  bogus=fix_sdt_time(data,fix(mnth),fix(day),fix(yr))
  totplot,data,names
  sdt_free,data
  mnum_elmts=n_elements(*mfe_data[0])/2

data_jump:

  jump=0
  filewidg           ;get data file names

  fil=strarr(3)
  fil(0)=dirc+file1+sufx   ;append data filenames to the directory prefix
  fil(1)=dirc+file2+sufx   ;and suffix, and put the filenames into an array
  fil(2)=dirc+file3+sufx
; fil(3)=dirc+file4+sufx
; fil(4)=dirc+file5+sufx
; fil(5)=dirc+file6+sufx

  if not mread_sdt(fil,raw_data,names,/verbose) then goto,mfe_jump
  data=ptrarr(3)
  data(0)=ptr_new(*raw_data[0])
  data(1)=ptr_new(*raw_data[1])
  data(2)=ptr_new(*raw_data[2])
  bogus=fix_sdt_time(data,fix(mnth),fix(day),fix(yr))
  totplot,data,names
  sdt_free,data
  num_elmts_arr=[n_elements(*raw_data[0])/2,n_elements(*raw_data[1])/2,n_elements(*raw_data[2])/2]
  num_elmts=max(num_elmts_arr)

;
;* INPT (cont.) *

  time_idx=(*mfe_data[0])[*,0]
  mfe_arr=transpose(resample(mfe_data,time_idx))

  tmp_arr=mfe_arr[0,*]
  mfe_arr[0:2,*]=mfe_arr[1:3,*]
  mfe_arr[3,*]=tmp_arr
  sdt_free,mfe_data


  ;Find start and end times for the MFE dataset and determine the
  ;minimum allowable start time and maximum allowable end time
  ;based on their values and the spin period

  bgtim=mfe_arr(3,0)
  edtim=mfe_arr(3,mnum_elmts-1)
  if (edtim-bgtim lt 3*spinper) then errmfilewidg,'Chosen MFE files '  $
     +'(eg. '+mfil(0)+') does NOT span at least 3 complete spin periods'
  bgtim=bgtim+spinper*1.3
  edtim=edtim-spinper*1.3

  data_arr=make_array(3,num_elmts+9,2,/double,value=0) 
  for i=0,2 do                       $
    begin
      data_arr[i,0:num_elmts_arr[i]-1,0]=(*raw_data[i])[*,1]
      data_arr[i,0:num_elmts_arr[i]-1,1]=(*raw_data[i])[*,0]
    endfor
  sdt_free,raw_data

  ;Set data rate

  rate=data_arr(0,1,1)-data_arr(0,0,1)

  ;Find start and end times for dataset and use these to determine
  ;defaults for the time range.  Also convert time in seconds to string
  ;format (include leading zeroes if needed so strings are in consistant
  ;format).
 
  tmpbgtim=max(data_arr(*,0,1))
  tmpedtim=min([ data_arr(0,num_elmts_arr(0)-1,1),                         $
        data_arr(1,num_elmts_arr(1)-1,1),data_arr(2,num_elmts_arr(2)-1,1)])
;       data_arr(3,num_elmts_arr(3)-1,1),data_arr(4,num_elmts_arr(4)-1,1), $
;       data_arr(5,num_elmts_arr(5)-1,1)])
  if (bgtim gt tmpedtim) or (edtim lt tmpbgtim) then errfilewidg,    $
   'Chosen data files do not fall within allowed times of chosen MFE files.'
  if (tmpbgtim gt bgtim) then bgtim=tmpbgtim
  if (tmpedtim lt edtim) then edtim=tmpedtim
  bgtimlmt=bgtim-.00001
  edtimlmt=edtim+.00001

  hr=floor(bgtim/3600)
  mt=floor((bgtim-hr*3600)/60) 
  sc=bgtim-hr*3600-mt*60
  bgstr=strcompress(string(hr),/remove_all)+":"                 $
     +strcompress(string(mt),/remove_all)+":"+strcompress(string(sc), $
     /remove_all)
  if (hr lt 10) then bgstr='0'+bgstr
  if (mt lt 10) then bgstr=strmid(bgstr,0,3)+'0'          $
              +strmid(bgstr,3,12)
  if (sc lt 10) then bgstr=strmid(bgstr,0,6)+'0'          $
              +strmid(bgstr,6,9)
  hr=floor(edtim/3600)
  mt=floor((edtim-hr*3600)/60) 
  sc=edtim-hr*3600-mt*60
  edstr=strcompress(string(hr),/remove_all)+":"                 $
     +strcompress(string(mt),/remove_all)+":"+strcompress(string(sc), $
     /remove_all)
  if (hr lt 10) then edstr='0'+edstr
  if (mt lt 10) then edstr=strmid(edstr,0,3)+'0'          $
              +strmid(edstr,3,12)
  if (sc lt 10) then edstr=strmid(edstr,0,6)+'0'          $
              +strmid(edstr,6,9)
  bgstrlmt=bgstr
  edstrlmt=edstr

  timewidg                 ;Define time range for Anlalysis
  while (bgtim lt bgtimlmt) or (edtim gt edtimlmt) or (bgtim gt edtim) do $
    begin
      print
      if (bgtim gt edtim) then                            $
        print,'START TIME IS AFTER END TIME -- TRY AGAIN' $
       else                                               $
        print,'CHOSEN TIMES ARE OUTSIDE ALLOWABLE RANGE -- TRY AGAIN'
      bgtim=bgtimlmt
      edtim=edtimlmt
      bgstr=bgstrlmt
      edstr=edstrlmt
      timewidg
    end

end
;

;* MCHDIR *  Force '/' between directory and MFE filenames

pro mchdir
common mfilarr,mfil
common mfiles,mdirc,mfile1,mfile2,mfile3

  mfil(0)=mdirc+'/'+mfile1
  mfil(1)=mdirc+'/'+mfile2
  mfil(2)=mdirc+'/'+mfile3
end


;* CHDIR *  Force '/' between directory and filenames

pro chdir
common filarr,fil
common files,dirc,file1,file2,file3,file4,file5,file6,sufx,desp

  fil(0)=dirc+'/'+file1+sufx
  fil(1)=dirc+'/'+file2+sufx
  fil(2)=dirc+'/'+file3+sufx
; fil(3)=dirc+'/'+file4+sufx
; fil(4)=dirc+'/'+file5+sufx
; fil(5)=dirc+'/'+file6+sufx
end


;* GETLNGTH *  Determine number of data points in the first input file
;              fil1 is first input file filename for mfe, each input file
;                 for data files
;              mfe is a flag, 1 if mfe files, 0 if data files

pro getlngth,fil1,mfe
common cklength,elements
common filarr,fil
common mfilarr,mfil

  a=0l & b=0l             ;initialize variables used to read in data
  c='' & d='' & inp=''
  er=0                    ;set NO ERROR

  openr,3,fil1,error=er

  if (er ne 0) then         $  ;if file not found, try forcing '/' between
    begin                 ;directory and filenames
      if (mfe eq 0) then begin                               $
        chdir
        fil1=fil(0)
       endif                                                 $
      else begin                                             $
        mchdir
        fil1=mfil(0)
       endelse 
      openr,3,fil1,error=er
    endif 
  if (er ne 0) then                                      $
    if (mfe eq 1) then errmfilewidg,"File "+fil1+" does not exist."  $
     else errfilewidg,"File "+fil1+" does not exist."           $
   else begin

    findstrt               ;jump past header

    if eof(3) then     $    ;input file not SDT output file
      begin                 ;report and halt program
        close,3
        if (mfe eq 1) then errmfilewidg,"File "+fil1+" not proper type."  $
         else errfilewidg,"File "+fil1+" not proper type."
      endif                                                  $ 
     else begin

      readf,3,a               ;get number of first data point

      while (c ne "End" and not eof(3)) do              $
        begin
          d=inp
          readf,3,inp
          c=strmid(inp,0,3)
        endwhile
      b=long(d)               ;get number of last data point

      if eof(3) then     $    ;Report input file is truncated SDT output file
        begin
          close,3
          if (mfe eq 1) then errmfilewidg,"File "+fil1+" missing End."     $
           else errfilewidg,"File "+fil1+" missing End."
        endif                                                 $
       else begin

        close,3
        elements=b-a+1         ;compute number of data points

      endelse
    endelse
  endelse
end
;

;* CHKLENGTH *  Confirm that lengthes of remaining input files are the
;               the same as the 1st.  'filx' is the input filename.
;               mfe is a flag, 1 if mfe files, 0 if data files
;              (Note: this procedure is no longer used for data files)
                
pro chklngth,filx,mfe
common cklength,elements

  ;This procedure is identical to the 'getlength' procedure except as noted

  a=0l & b=0l
  c='' & d='' & inp=''

  openr,3,filx,error=er

  if (er ne 0) then                                                    $
    if (mfe eq 1) then errmfilewidg,"File "+filx+" does not exist."   $
      else errfilewidg,"File "+filx+" does not exist."                    $
   else begin
     
                                    ;Do not need to attempt force of '/'

    findstrt
    if eof(3) then                                 $
      begin
       close,3
       if (mfe eq 1) then errmfilewidg,"File "+filx+" not proper type."  $
         else errfilewidg,"File "+filx+" not proper type."
      endif                                              $
     else begin
	
      readf,3,a
      while ((c ne "End") and (not eof(3))) do              $
        begin
          d=inp
          readf,3,inp
          c=strmid(inp,0,3)
        endwhile
      b=long(d)
      if eof(3) then                                 $
        begin
          close,3
          if (mfe eq 1) then errmfilewidg,"File "+filx+" missing End."     $
            else errfilewidg,"File "+filx+" missing End."
        endif                                              $
       else begin

        close,3

          ;compare length to that obtained from 'getlngth' procedure.
          ;if different report such

        if ((b-a+1) ne elements) then        $
          if (mfe eq 1) then errmfilewidg,"Files do not have same # of "$
             +"elements.  ("+filx+")" $

;          (Note: else no longer used since only MFE file get here)

           else errgapwidg,"Files do not have same # of elements.  ("  $
             +filx+")"
      endelse
    endelse
  endelse
end


;   ***   END -- DATA INPUT   ***



;   ***   COMPUTATION   ***


;* COMPANGLARR *  Compute angle array

pro companglarr
common comparr,comp_arr,nm_elmts,chris_arr,nmchr_elmts,   $
       comp_raw_arr,nm_raw_elmts,comp_ang_arr
common anglarr,angl_arr,xpls_arr,xnm_elmts
common input,mfe_arr,mnum_elmts,data_arr,num_elmts,num_elmts_arr
common satdata,spinper,rate,stagger
common files,dirc,file1,file2,file3,file4,file5,file6,sufx,desp

;angl_arr=make_array(13,num_elmts,/double,value=0.0)
  angl_arr=make_array(10,num_elmts,/double,value=0.0)
  mfe=make_array(4,/double,value=0.0)
;nmchr_elmts=num_elmts
;chris_arr=make_array(3,nmchr_elmts,/double,value=0)

  if desp eq 1 then begin
    print,"Creating Despinning Angle Arrays ..."
    for i=0l,num_elmts-1 do                                    $
      begin
        j=0l
        mfe(3) = data_arr(0,i,1)
        angl_arr(9,i)=mfe(3) 
        while (j lt mnum_elmts-1) and (mfe(3) gt mfe_arr(3,j)) do j=j+1
        interp=(mfe(3)-mfe_arr(3,j-1))/(mfe_arr(3,j)-mfe_arr(3,j-1))
        mfe(0)=interp*(mfe_arr(0,j)-mfe_arr(0,j-1))+mfe_arr(0,j-1)
        mfe(1)=interp*(mfe_arr(1,j)-mfe_arr(1,j-1))+mfe_arr(1,j-1)
        mfe(2)=interp*(mfe_arr(2,j)-mfe_arr(2,j-1))+mfe_arr(2,j-1)
;chris_arr(0,i)=mfe(0)
;chris_arr(1,i)=mfe(1)
;chris_arr(2,i)=mfe(2)
 
   ;    Components in direction of Bz [Z']
  
        mfemag=sqrt(mfe(0)*mfe(0)+mfe(1)*mfe(1)+mfe(2)*mfe(2))
        angl_arr(6,i)=mfe(0)/mfemag   ;  x X
        angl_arr(7,i)=mfe(1)/mfemag   ;  y Y
        angl_arr(8,i)=mfe(2)/mfemag   ;  z Z
  
   ;    Components in direction of Bz x Z [Y']
  
        mfemag=sqrt(mfe(0)*mfe(0)+mfe(1)*mfe(1))
        angl_arr(3,i)=mfe(1)/mfemag   ;   y X
        angl_arr(4,i)=-mfe(0)/mfemag  ; - x Y
        angl_arr(5,i)=0
  
   ;    Components in direction of Bz x Z x Bz (y' x z') [X']
  
        tmpmag=mfe(0)*mfe(0)+mfe(1)*mfe(1)    ; (x^2 + y^2)
        mfemag=sqrt(tmpmag*mfe(2)*mfe(2)+tmpmag*tmpmag)
        angl_arr(0,i)=-mfe(0)*mfe(2)/mfemag   ; - xz        X
        angl_arr(1,i)=-mfe(1)*mfe(2)/mfemag   ; - yz        Y
        angl_arr(2,i)=tmpmag/mfemag           ; (x^2 + y^2) Z
 
;chris_arr(0,i)=mfe(0)*(angl_arr(0,i))        $
;              +mfe(1)*(angl_arr(1,i))        $
;              +mfe(2)*(angl_arr(2,i))
;angl_arr(10,i)=(angl_arr(0,i)*angl_arr(0,i))        $
;              +(angl_arr(1,i)*angl_arr(1,i))        $
;              +(angl_arr(2,i)*angl_arr(2,i))

;chris_arr(1,i)=mfe(0)*(angl_arr(3,i))        $
;              +mfe(1)*(angl_arr(4,i))        $
;              +mfe(2)*(angl_arr(5,i))
;angl_arr(11,i)=(angl_arr(3,i)*angl_arr(3,i))        $
;              +(angl_arr(4,i)*angl_arr(4,i))        $
;              +(angl_arr(5,i)*angl_arr(5,i))

;chris_arr(2,i)=mfe(0)*(angl_arr(6,i))        $
;              +mfe(1)*(angl_arr(7,i))        $
;              +mfe(2)*(angl_arr(8,i))
;angl_arr(12,i)=(angl_arr(6,i)*angl_arr(6,i))        $
;              +(angl_arr(7,i)*angl_arr(7,i))        $
;              +(angl_arr(8,i)*angl_arr(8,i))
;print,angl_arr(10,i),angl_arr(11,i),angl_arr(12,i)

      endfor
  endif else begin
    angl_arr(0,*)=1.
    angl_arr(1,*)=0.
    angl_arr(2,*)=0.
    angl_arr(3,*)=0.
    angl_arr(4,*)=1.
    angl_arr(5,*)=0.
    angl_arr(6,*)=0.
    angl_arr(7,*)=0.
    angl_arr(8,*)=1.
  endelse

  xnm_elmts=0l
  i=0l
  while (mfe_arr(0,i) gt 0) do i=i+1
  while (mfe_arr(0,i) lt 0) do i=i+1


  for j=i+1,mnum_elmts-1 do                                     $
    begin
      if (mfe_arr(0,j) lt 0) and (mfe_arr(0,j-1) gt 0) then     $
        xnm_elmts=xnm_elmts+1
    endfor

  cross_arr=make_array(2,xnm_elmts,/double,value=0.0)
  i=0l
  j=0l
  while (mfe_arr(0,i) gt 0) do i=i+1
  while (mfe_arr(0,i) lt 0) do i=i+1
  while ((i lt mnum_elmts) and (j lt xnm_elmts)) do                $
    begin
      cross_arr(0,j)=-mfe_arr(0,i-1)/(mfe_arr(0,i)-mfe_arr(0,i-1))  $
             *(mfe_arr(3,i)-mfe_arr(3,i-1))+mfe_arr(3,i-1)
      while ((i lt mnum_elmts-1) and ((mfe_arr(0,i) gt 0)            $
         or (mfe_arr(3,i) lt cross_arr(0,j)+spinper*0.4))) do i=i+1
      cross_arr(1,j)=mfe_arr(0,i-1)/(mfe_arr(0,i-1)-mfe_arr(0,i))  $
             *(mfe_arr(3,i)-mfe_arr(3,i-1))+mfe_arr(3,i-1)
      while ((i lt mnum_elmts-1) and ((mfe_arr(0,i) lt 0)            $
         or (mfe_arr(3,i) lt cross_arr(1,j)+spinper*0.4))) do i=i+1
      j=j+1
    end

  xpls_arr=(cross_arr(0,*)+cross_arr(1,*))/2

end


;* COMPUTEWIDG_EVENT*  xmanager control for "Compute Data?" widget

pro computewidg_event,event
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  widget_control,event.id,get_uvalue=evtval
  if (evtval eq 'go') then                                 $
    begin
      widget_control,event.top,/destroy
      splined=0
      preprocarr
      if (gap ne 1) then                   $
        begin
          computearr
          chriscalc
;         pltwidg                               ;Plot/Print Processed Data?
        endif
    endif                                                   $
   else                                                     $
     widget_control,event.top,/destroy
end


;* COMPUTEWIDG *  widget to determine if rotated data is to be plotted

pro computewidg,group=group

   base=widget_base(title='COMPUTE WHAT?',xoffset=2.0,xsize=200,/column)
   but=widget_button(base,value='Compute',uvalue='go')
   but=widget_button(base,value='Nothing',uvalue='no')
   widget_control,base,/realize
   xmanager,'computewidg',base,group_leader=group
end


;* PREPROCARR *  Pre-process sub-array of input to be used for Analysis

pro preprocarr
common anglarr,angl_arr,xpls_arr,xnm_elmts
common comparr,comp_arr,nm_elmts,chris_arr,nmchr_elmts,   $
       comp_raw_arr,nm_raw_elmts,comp_ang_arr
common times,bgtim,edtim,bgstr,edstr,bgtimlmt,edtimlmt,bgstrlmt,edstrlmt
common input,mfe_arr,mnum_elmts,data_arr,num_elmts,num_elmts_arr
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var
common filarr,fil
common cnsts,splinefactor,errpct
common satdata,spinper,rate,stagger


  upperpt=make_array(3,/long)
  uppertm=make_array(3,/double)
  lowerpt=make_array(3,/long)
  lowertm=make_array(3,/double)

  for x=0,2 do                                          $
    begin
      y=0l
      while (data_arr(x,y,1) lt bgtim) do y=y+1
      lowerpt(x)=y
      lowertm(x)=data_arr(x,y,1)
      while (data_arr(x,y,1) lt edtim) do y=y+1
      upperpt(x)=y-1
      uppertm(x)=data_arr(x,y-10,1)
    endfor
  
  strtlmt=max(lowertm(*))
  endlmt=min(uppertm(*))

  for x=0,2 do                                           $
    begin
      while (lowertm(x) lt (strtlmt-stagger-0.000001)) do $
        begin
          lowerpt(x)=lowerpt(x)+1
          lowertm(x)=data_arr(x,lowerpt(x),1)
        endwhile
      while (uppertm(x) gt (endlmt+stagger+0.000001)) do  $
        begin
          upperpt(x)=upperpt(x)-1
          uppertm(x)=data_arr(x,upperpt(x),1)
        endwhile
    endfor

  print,"Checking for Data Gaps ..."
  gap=0
  x=0
  while ((gap ne 1) and (x lt 3)) do                        $
    begin
      idx=lowerpt(x)
      while ((gap ne 1) and (idx lt upperpt(x))) do    $
        begin
          idx=idx+1
          if (data_arr(x,idx,1) gt                       $
             (data_arr(x,idx-1,1)+rate+0.000001)) then   $
             begin
               skippts=fix((data_arr(x,idx,1)-data_arr(x,idx-1,1))/rate)-1
               if (skippts gt 9) then                    $
                    begin 
                      gap=1
                      print,format='("GAP DIAG: ",I6," ",F14.7," ",F14.7," ",F14.7)',  $
                            idx,data_arr(x,idx,1),data_arr(x,idx-1,1),rate
                    endif                                $
                  else                                   $
                    begin
                      for y=upperpt(x),idx,-1 do                     $
                        data_arr(x,y+skippts,*)=data_arr(x,y,*) 
;                     for y=-1,skippts do                           $
;                       print,format='(I6," ",F14.7,F14.7)',idx+y,  $
;                         data_arr(x,idx+y,1),data_arr(x,idx+y,0)
                      for y=0,skippts-1 do                           $
                        begin
                          data_arr(x,idx+y,0)=(data_arr(x,idx+skippts,0)   $
                                  -data_arr(x,idx-1,0))*(y+1)/(skippts+1)  $
                                  +data_arr(x,idx-1,0)
                          data_arr(x,idx+y,1)=(data_arr(x,idx+skippts,1)   $
                                  -data_arr(x,idx-1,1))*(y+1)/(skippts+1)  $
                                  +data_arr(x,idx-1,1)
                        endfor
;                     for y=-1,skippts do                           $
;                       print,format='(I6," ",F14.7,F14.7)',idx+y,  $
;                         data_arr(x,idx+y,1),data_arr(x,idx+y,0)
                      if x eq 0 then                     $
                        begin
                          for y=upperpt(x),idx,-1 do                     $
                            angl_arr(*,y+skippts)=angl_arr(*,y) 
                          for y=0,skippts-1 do                           $
                            begin
                              angl_arr(*,idx+y)=(angl_arr(*,idx+skippts) $
                                  -angl_arr(x,idx-1))*(y+1)/(skippts+1)  $
                                  +angl_arr(x,idx-1)
                            endfor
                        endif	
                      print,                                                   $
        format='(I1," pt. gap interpolated in array # ",I1," at time ",A12)' $
                        ,skippts,x,strmid(time_string(data_arr(x,idx,1),/msec),11,12)
                    endelse
             endif
        endwhile
      x=x+1
    endwhile
  x=x-1

  nm_raw_elmts=upperpt(0)-lowerpt(0)
; nmchr_elmts=nm_raw_elmts
  if (gap or (nm_raw_elmts ne (upperpt(1)-lowerpt(1)))   $
      or (nm_raw_elmts ne (upperpt(2)-lowerpt(2)))) then $
    begin
      print
      print,'Cannot process requested time range -- Large Data Gap found'
      if (gap) then                                                $
        begin 
          print,'  Gap in file:  '+fil(x)
          print,format='(I3," pt. gap at ~ ",A12," - ",A12)',skippts, $
            strmid(time_string(data_arr(x,idx-1,1),/msec),11,12),  $
            strmid(time_string(data_arr(x,idx,1),/msec),11,12)
        endif                                                      $
       else                                                        $
        begin
          print,'  Gap at beginning or end of time range'
          minpts=min([nm_raw_elmts,upperpt(1)-lowerpt(1),            $
                     upperpt(2)-lowerpt(2)])
          if (minpts eq nm_raw_elmts) then mnptfl=0                 $
           else if (minpts eq (upperpt(1)-lowerpt(1))) then mnptfl=1 $
             else mnptfl=2
          print,'  of file:  '+fil(mnptfl)
          print,'    Start time = '+bgtimstr
          print,'    End time   = '+edtimstr
          gap=1
        endelse
    endif                                                          $
   else                                                            $
    begin
      print,"Preprocessing Arrays ..."
      comp_ang_arr=make_array(9,nm_raw_elmts,/double,value=0)
      tmp_ang_arr=make_array(1,nm_raw_elmts,/double,value=0)
      comp_raw_arr=make_array(3,nm_raw_elmts,2,/double,value=0)
      tmp_raw_arr=make_array(1,nm_raw_elmts,2,/double,value=0)

      tmp_raw_arr=extrac(data_arr,0,lowerpt(0),0,1,nm_raw_elmts,2)
      comp_raw_arr(0,*,*)=tmp_raw_arr(0,*,*)
      tmp_ang_arr=extrac(angl_arr,0,lowerpt(0),1,nm_raw_elmts)
      comp_ang_arr(0,*)=tmp_ang_arr(0,*)
      tmp_ang_arr=extrac(angl_arr,3,lowerpt(0),1,nm_raw_elmts)
      comp_ang_arr(3,*)=tmp_ang_arr(0,*)
      tmp_ang_arr=extrac(angl_arr,6,lowerpt(0),1,nm_raw_elmts)
      comp_ang_arr(6,*)=tmp_ang_arr(0,*)

      tmp_raw_arr=extrac(data_arr,1,lowerpt(0),0,1,nm_raw_elmts,2)
      comp_raw_arr(1,*,*)=tmp_raw_arr(0,*,*)
      tmp_ang_arr=extrac(angl_arr,1,lowerpt(0),1,nm_raw_elmts)
      comp_ang_arr(1,*)=tmp_ang_arr(0,*)
      tmp_ang_arr=extrac(angl_arr,4,lowerpt(0),1,nm_raw_elmts)
      comp_ang_arr(4,*)=tmp_ang_arr(0,*)
      tmp_ang_arr=extrac(angl_arr,7,lowerpt(0),1,nm_raw_elmts)
      comp_ang_arr(7,*)=tmp_ang_arr(0,*)

      tmp_raw_arr=extrac(data_arr,2,lowerpt(0),0,1,nm_raw_elmts,2)
      comp_raw_arr(2,*,*)=tmp_raw_arr(0,*,*)
      tmp_ang_arr=extrac(angl_arr,2,lowerpt(0),1,nm_raw_elmts)
      comp_ang_arr(2,*)=tmp_ang_arr(0,*)
      tmp_ang_arr=extrac(angl_arr,5,lowerpt(0),1,nm_raw_elmts)
      comp_ang_arr(5,*)=tmp_ang_arr(0,*)
      tmp_ang_arr=extrac(angl_arr,8,lowerpt(0),1,nm_raw_elmts)
      comp_ang_arr(8,*)=tmp_ang_arr(0,*)

    endelse

  if ((splined ne 0) and (gap ne 1)) then                              $
    begin
      nm_elmts=floor((min(uppertm)-max(lowertm))/(rate/splinefactor))
      comp_arr=make_array(3,nm_elmts,2,/double,value=0)
      comp_arr(0,*,1)=findgen(nm_elmts)*rate/splinefactor+max(lowertm)
      comp_arr(1,*,1)=comp_arr(0,*,1)
      comp_arr(2,*,1)=comp_arr(0,*,1)

      comp_arr(0,*,0)=spline(comp_raw_arr(0,*,1),comp_raw_arr(0,*,0),   $
                             comp_arr(0,*,1))
      comp_arr(1,*,0)=spline(comp_raw_arr(1,*,1),comp_raw_arr(1,*,0),   $
                             comp_arr(1,*,1))
      comp_arr(2,*,0)=spline(comp_raw_arr(2,*,1),comp_raw_arr(2,*,0),   $
                             comp_arr(2,*,1))
    endif
  
end


;* COMPUTEARR *   Despin into field aligned coordinates

pro computearr
common comparr,comp_arr,nm_elmts,chris_arr,nmchr_elmts,       $
       comp_raw_arr,nm_raw_elmts,comp_ang_arr
common times,bgtim,edtim,bgstr,edstr,bgtimlmt,edtimlmt,bgstrlmt,edstrlmt
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var
common velfactors,totang,bmlng

     ;Despin coordinates into MFE spacecraft coordinates

  factor = sqrt(2)/2
  sat_arr=make_array(3,nm_raw_elmts,/double,value=0)

  sat_arr(0,*)=comp_raw_arr(0,*,0)*factor - comp_raw_arr(1,*,0)*factor
  sat_arr(1,*)=comp_raw_arr(0,*,0)*factor + comp_raw_arr(1,*,0)*factor
  sat_arr(2,*)= comp_raw_arr(2,*,0)


     ;Despin coordinates into chris_arr
 
  print,"Despinning ..."
  nmchr_elmts=nm_raw_elmts
  chris_arr=make_array(3,nmchr_elmts,/double,value=0)
 
  chris_arr(0,*)=sat_arr(0,*,0)*comp_ang_arr(0,*)        $
                +sat_arr(1,*,0)*comp_ang_arr(1,*)        $
                +sat_arr(2,*,0)*comp_ang_arr(2,*)

  chris_arr(1,*)=sat_arr(0,*,0)*comp_ang_arr(3,*)        $
                +sat_arr(1,*,0)*comp_ang_arr(4,*)        $
                +sat_arr(2,*,0)*comp_ang_arr(5,*)

  chris_arr(2,*)=sat_arr(0,*,0)*comp_ang_arr(6,*)        $
                +sat_arr(1,*,0)*comp_ang_arr(7,*)        $
                +sat_arr(2,*,0)*comp_ang_arr(8,*)


  ;find time of first data point to nearest second, and subtract from
  ;times to avoid limitation of plot command to single precision
  ;floating numbers

  strttime=floor(comp_raw_arr(0,0,1))

end


;* CHRISCALC *   Call Chris Chaston's program

pro chriscalc
common comparr,comp_arr,nm_elmts,chris_arr,nmchr_elmts,       $
       comp_raw_arr,nm_raw_elmts,comp_ang_arr
common satdata,spinper,rate,stagger
common velfactors,totang,bmlng
common veldata,deltim,deltimraw,vel,veldf,velraw,delerr,velerr,cor,corraw,dcor
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var
common times,bgtim,edtim,bgstr,edstr,bgtimlmt,edtimlmt,bgstrlmt,edstrlmt
common cnsts,splinefactor,errpct
common dt,date,mnth,day,yr
common files,dirc,file1,file2,file3,file4,file5,file6,sufx,desp
common satdata,spinper,rate,stagger

;;freq=8000
  print,'Data rate = ',rate
  print,'Frequency = ',1./rate
  freq=1./rate

  Read,pow_lmt_typ,Prompt='Power Display Limit Type (0-None,1-Fixed,2-Rel.) '
  if pow_lmt_typ eq 0 then pow_lmt=0         $
  else Read,pow_lmt,Prompt='Power Display Limit '
  Read,pol_lmt,Prompt='Degree of Polarization Display Limit '
  Read,corse,Prompt='Plot type (0-Smoothed,1-Corse) '
  Read,npts,Prompt='# Points for FFT (0-128,1-Other) '
  if npts ne 1 then npts=128 else begin
    repeat begin
      Read,npts,Prompt='# Points for FFT : '
      xx=1
      while xx lt npts do xx=xx*2
      if xx ne npts then print,"# Ponts must be 2^X"
    endrep until xx eq npts
  endelse
  
  strtstr=strmid(time_string(date),0,11)+bgstr

  print,"Calling DEG_POL ..."
; device,pseudo_color=8
; loadct2,38
  new_deg_pol,chris_arr(0,*),chris_arr(1,*),chris_arr(2,*),strtstr,  $
          nmchr_elmts,0.0,pol_lmt,pow_lmt,pow_lmt_typ,corse,freq,npts=npts

  tplot,title=file1
end


;   ***   END -- COMPUTATION   ***

;

;   ***   PLOT/PRINT ROTATED DATA   ***


;* PLTWIDG_EVENT*  xmanager control for "Plot Rotated Data?" widget

pro pltwidg_event,event
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  widget_control,event.id,get_uvalue=evtval
  if (evtval eq 'spline') then                                  $
    begin
      whplt=0
      plotr            ;plot rotated data to screen
    endif                                                   $
   else if (evtval eq 'raw') then                            $
    begin
      whplt=1
      plotr
    endif                                                   $
   else if (evtval eq 'both') then                          $
    begin
      whplt=2
      plotr
    endif
  widget_control,event.top,/destroy
end


;* PLTWIDG *  widget to determine if rotated data is to be plotted

pro pltwidg,group=group
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  base=widget_base(title='PLOT WHICH RESULTS?',xoffset=2.0,xsize=220,/column)

  if (splined ne 0) then                                                  $
    but=widget_button(base,value='Splined V3* & V4*',uvalue='spline')

  but=widget_button(base,value='Raw V3* & V4*',uvalue='raw')

  if (splined ne 0) then                                                  $
    but=widget_button(base,value='Both Splined & Raw',uvalue='both')

  but=widget_button(base,value='None',uvalue='no')
  widget_control,base,/realize
  xmanager,'pltwidg',base,group_leader=group
end
;

;* PLOTR *  Plot data to screen 

pro plotr
common stararr,star_arr,stardf_arr,starraw_arr
common plotlmt,mxrng,mnrng,strttimestr
common times,bgtim,edtim,bgstr,edstr,bgtimlmt,edtimlmt,bgstrlmt,edstrlmt
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var
 
     ;Find Maximum range and average of the range for each plot
     ;so that all three plots have the same scale
 
  mx=max(starraw_arr(1,*))
  mn=min(starraw_arr(1,*))
  mnrng=mn
  mxrng=mx
  mx=max(starraw_arr(0,*))
  mn=min(starraw_arr(0,*))
  if (mx gt mxrng) then mxrng=mx
  if (mn lt mnrng) then mnrng=mn

     ;Set range to maximum of all plots

  if (mnrng gt 0) then mnrng=0.9*mnrng       $
    else mnrng=1.1*mnrng
  if (mxrng lt 0) then mxrng=0.9*mxrng       $
    else mxrng=1.1*mxrng

  strttimestr=strmid(bgstr,0,8)

  usersym,[-.1,.1],[0,0]

  set_plot,'X'              ;plot to screen
  !p.charsize=2.0           ;make characters readable

  if (whplt eq 2) then                                                      $
    begin
      window,ysize=600,xsize=700
      !p.charsize=1.4           ;make characters readable
      !p.multi=[0,2,2]          ;plot 2x2 

      plot,star_arr(2,*),star_arr(0,*),title="Near Probe",            $
        ytitle="Volts",yrange=[mnrng,mxrng],                    $
        xtitle="Seconds since "+strttimestr,psym=8
      plot,starraw_arr(2,*),starraw_arr(0,*),title="Near Probe - RAW",  $
        ytitle="Volts",yrange=[mnrng,mxrng],                    $
        xtitle="Seconds since "+strttimestr,psym=8
      plot,star_arr(2,*),star_arr(1,*),title="Opposite Probe",            $
        ytitle="-Volts",yrange=[mnrng,mxrng],                    $
        xtitle="Seconds since "+strttimestr,psym=8
      plot,starraw_arr(2,*),starraw_arr(1,*),title="Opposite Probe - RAW", $
        ytitle="-Volts",yrange=[mnrng,mxrng],                    $
        xtitle="Seconds since "+strttimestr,psym=8
    endif                                                      $
   else if (whplt eq 1) then                                   $
    begin
      window,ysize=600,xsize=600
      !p.multi=[0,1,2]          ;plot two things

      plot,starraw_arr(2,*),starraw_arr(0,*),title="Near Probe - RAW",  $
        ytitle="Volts",yrange=[mnrng,mxrng],                    $
        xtitle="Seconds since "+strttimestr,psym=8
      plot,starraw_arr(2,*),starraw_arr(1,*),title="Opposite Probe - RAW", $
        ytitle="-Volts",yrange=[mnrng,mxrng],                    $
        xtitle="Seconds since "+strttimestr,psym=8
     endif                                                     $
   else                                                        $
    begin
      window,ysize=600,xsize=600
      !p.multi=[0,1,2]          ;plot two things

      plot,star_arr(2,*),star_arr(0,*),title="Near Probe",            $
        ytitle="Volts",yrange=[mnrng,mxrng],                    $
        xtitle="Seconds since "+strttimestr,psym=8
      plot,star_arr(2,*),star_arr(1,*),title="Opposite Probe",           $
        ytitle="-Volts",yrange=[mnrng,mxrng],                    $
        xtitle="Seconds since "+strttimestr,psym=8
     endelse
  prtwidg         ;Ask if printout of Rotated data is desired
end
;

;* PRTOUT *  Print out Rotated data

pro prtout
common stararr,star_arr,stardf_arr,starraw_arr
common plotlmt,mxrng,mnrng,strttimestr
common filarr,fil
common times,bgtim,edtim,bgstr,edstr,bgtimlmt,edtimlmt,bgstrlmt,edstrlmt
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var
common veldata,deltim,deltimraw,vel,veldf,velraw,delerr,velerr,cor,corraw,dcor
common velfactors,totang,bmlng
common cnsts,splinefactor,errpct
common satdata,spinper,rate,stagger
common prntr,prtr

  set_plot,'PS'                  ;plot to postscript file
  device,ysize=22,yoffset=1.5,xsize=20.0,xoffset=0.35  ;size plot

  if (whplt eq 2) then !p.multi=[0,1,4] else !p.multi=[0,1,2]
                                           ;set number of plots on the page

  usersym,[-.25,0,.25,0,-.25],[0,.25,0,-.25,0]


  !p.charsize=1.2                ;reset character size

  if (whplt eq 2) then                                                  $
   begin                         ;print out splined and raw data

    plot,star_arr(2,*),star_arr(0,*),title="Near Probe"                        $
      ,yrange=[mnrng,mxrng],                                            $
      ytitle="Volts",xtitle="Seconds since "+strttimestr,psym=8
    usersym,[-.25,.25,0,.25,-.25],[.25,-.25,0,.25,-.25]
    plot,star_arr(2,*),star_arr(1,*),title="Opposite Probe"                       $
      ,yrange=[mnrng,mxrng],                                            $
      ytitle="-Volts",xtitle="Seconds since "+strttimestr,psym=8
    usersym,[-.25,0,.25,0,-.25],[0,.25,0,-.25,0]
    plot,starraw_arr(2,*),starraw_arr(0,*),title="Near Probe, RAW",        $
      yrange=[mnrng,mxrng],ytitle="Volts",                               $
      xtitle="Seconds since "+strttimestr,psym=8
    usersym,[-.25,.25,0,.25,-.25],[.25,-.25,0,.25,-.25]
    plot,starraw_arr(2,*),starraw_arr(1,*),title="Opposite Probe, RAW",     $
      yrange=[mnrng,mxrng],ytitle="-Volts",                               $
      xtitle="Seconds since "+strttimestr,psym=8
   endif                                                                $
                                                                        $

;                                                                     $
;* PRTOUT (cont) *                                                      $

  else if (whplt eq 1) then                                             $
   begin                      ;print out just raw data

    plot,starraw_arr(2,*),starraw_arr(0,*),title="Near Probe, RAW",        $
      yrange=[mnrng,mxrng],ytitle="Volts",                               $
      xtitle="Seconds since "+strttimestr,psym=8

    usersym,[-.25,.25,0,.25,-.25],[.25,-.25,0,.25,-.25]

    plot,starraw_arr(2,*),starraw_arr(1,*),title="Opposite Probe, RAW",       $
      yrange=[mnrng,mxrng],ytitle="-Volts",                               $
      xtitle="Seconds since "+strttimestr,psym=8
   endif                                                                $
  else                                                                  $
   begin                      ;print out just splined data

    plot,star_arr(2,*),star_arr(0,*),title="Near Probe",yrange=[mnrng,mxrng],  $
      ytitle="Volts",xtitle="Seconds since "+strttimestr,psym=8

    usersym,[-.25,.25,0,.25,-.25],[.25,-.25,0,.25,-.25]

    plot,star_arr(2,*),star_arr(1,*),title="Opposite Probe",yrange=[mnrng,mxrng], $
      ytitle="-Volts",xtitle="Seconds since "+strttimestr,psym=8
   endelse

  xyouts,.45,1.16,/normal,'FILE 1 = '+fil(0),size=1.0
  xyouts,.15,1.135,/normal,'TIME',size=0.8
  xyouts,.28,1.135,/normal,'TOTAL ANGLE',size=0.8
  xyouts,.41,1.135,/normal,'Spin Angle',size=0.7
  xyouts,.50,1.135,/normal,'Cant Angle',size=0.7
  xyouts,.05,1.12,/normal,'START',size=0.8
  xyouts,.05,1.105,/normal,'END',size=0.8
  xyouts,.12,1.12,/normal,bgstr,size=0.8
  xyouts,.12,1.105,/normal,edstr,size=0.8
  xyouts,.28,1.12,/normal,strcompress(string(totang1*180/!PI),           $
         /remove_all),size=.8
  xyouts,.28,1.105,/normal,strcompress(string(totang2*180/!PI),           $
         /remove_all),size=.8
  xyouts,.41,1.12,/normal,strcompress(string(spinang1*180/!PI),          $
         /remove_all),size=.7
  xyouts,.41,1.105,/normal,strcompress(string(spinang2*180/!PI),          $
         /remove_all),size=.7
  xyouts,.50,1.12,/normal,strcompress(string(cantang1*180/!PI),          $
         /remove_all),size=.7
  xyouts,.50,1.105,/normal,strcompress(string(cantang2*180/!PI),          $
         /remove_all),size=.7
  xyouts,.65,1.138,/normal,"EFFECTIVE BOOM LENGTH",size=0.8
  xyouts,.65,1.123,/normal,'@ AVG. TOTAL ANGLE = '                         $
         +string(bmlng,format='(F6.2)')+' m',size=0.8
  xyouts,.65,1.102,/normal,'DATA RATE',size=0.8 
  xyouts,.76,1.102,/normal,'= '+string(rate,format='(F10.7)')+' s',size=0.8 
  xyouts,.65,1.087,/normal,'SPLINED RATE',size=0.8 
  xyouts,.76,1.087,/normal,'= '+string(rate/splinefactor,format='(F10.7)') $
         +' s',size=0.8 
  xyouts,.145,1.058,/normal,charthick=1.5,'VELOCITY',size=0.8
  xyouts,.155,1.0435,/normal,'(km/s)',size=0.7
  xyouts,.63,1.045,/normal,'CROSS-CORRELATIONS',size=0.8
  xyouts,.37,1.045,/normal,'DELAY',size=0.8

  xyouts,.36,1.03,/normal,'(Seconds)',size=0.7

  xyouts,.46,1.03,/normal,'-4 Points',size=0.65
  xyouts,.53,1.03,/normal,'-2 Points',size=0.7
  xyouts,.61,1.03,/normal,'-1 Point',size=0.7
  xyouts,.69,1.03,/normal,'@DELAY',size=0.8
  xyouts,.76,1.03,/normal,'+1 Point',size=0.7
  xyouts,.83,1.03,/normal,'+2 Points',size=0.7
  xyouts,.91,1.03,/normal,'+4 Points',size=0.65

  if (whplt ne 1) then                                         $
    begin
      xyouts,.28,1.015,/normal,'SPLINED',size=0.8
      xyouts,.35,1.015,/normal,string(deltim,format='(F10.7)'),size=0.8
      xyouts,.47,1.015,/normal,string(cor(0),format='(F7.4)'),size=0.65
      xyouts,.54,1.015,/normal,string(cor(1),format='(F7.4)'),size=0.7
      xyouts,.61,1.015,/normal,string(cor(2),format='(F7.4)'),size=0.7
      xyouts,.68,1.015,/normal,string(cor(3),format='(F7.4)'),size=0.8
      xyouts,.76,1.015,/normal,string(cor(4),format='(F7.4)'),size=0.7
      xyouts,.83,1.015,/normal,string(cor(5),format='(F7.4)'),size=0.7
      xyouts,.91,1.015,/normal,string(cor(6),format='(F7.4)'),size=0.65
      xyouts,.28,1.0,/normal,'RAW',size=0.8
      xyouts,.35,1.0,/normal,string(deltimraw,format='(F10.7)'),size=0.8
      xyouts,.47,1.0,/normal,string(corraw(0),format='(F7.4)'),size=0.65
      xyouts,.54,1.0,/normal,string(corraw(1),format='(F7.4)'),size=0.7
      xyouts,.61,1.0,/normal,string(corraw(2),format='(F7.4)'),size=0.7
      xyouts,.68,1.0,/normal,string(corraw(3),format='(F7.4)'),size=0.8
      xyouts,.76,1.0,/normal,string(corraw(4),format='(F7.4)'),size=0.7
      xyouts,.83,1.0,/normal,string(corraw(5),format='(F7.4)'),size=0.7
      xyouts,.91,1.0,/normal,string(corraw(6),format='(F7.4)'),size=0.65

      xyouts,.28,1.065,/normal,string(errpct,                      $
         format='("Delay Error Range: (",F4.2,")")'),size=0.65
      xyouts,.45,1.065,/normal,string(delerr(1),format='(F10.7)'),size=0.65
      xyouts,.53,1.065,/normal,string(delerr(0),format='("- ",F10.7)'),  $
         size=0.65

      xyouts,.05,1.028,/normal,'SPLINED',size=0.8
      xyouts,.14,1.028,/normal,charthick=1.5,string(round(vel),format='(I5)'),size=0.8
      xyouts,.05,1.012,/normal,'Range',size=0.65
      xyouts,.12,1.012,/normal,string(round(velerr(0)),format='(I5)'),size=0.65
      xyouts,.17,1.012,/normal,string(round(velerr(1)),format='("-",I5)'),  $
         size=0.65
      xyouts,.05,0.998,/normal,'Derivative',size=0.7
      xyouts,.145,0.998,/normal,string(round(veldf),format='(I5)'),size=0.7
      xyouts,.19,0.998,/normal,string(dcor(3),format='("(",F7.4,")")'),     $
         size=0.7
    endif                                                              $
   else                                                                $
    begin
      xyouts,.29,1.015,/normal,'RAW',size=0.8
      xyouts,.35,1.015,/normal,string(deltimraw,format='(F10.7)'),size=0.8
      xyouts,.47,1.015,/normal,string(corraw(0),format='(F7.4)'),size=0.65
      xyouts,.54,1.015,/normal,string(corraw(1),format='(F7.4)'),size=0.7
      xyouts,.61,1.015,/normal,string(corraw(2),format='(F7.4)'),size=0.7
      xyouts,.68,1.015,/normal,string(corraw(3),format='(F7.4)'),size=0.8
      xyouts,.76,1.015,/normal,string(corraw(4),format='(F7.4)'),size=0.7
      xyouts,.83,1.015,/normal,string(corraw(5),format='(F7.4)'),size=0.7
      xyouts,.91,1.015,/normal,string(corraw(6),format='(F7.4)'),size=0.65

      xyouts,.05,1.025,/normal,'RAW',size=0.8
      xyouts,.14,1.025,/normal,string(round(velraw),format='(I5)'),size=0.8
    endelse

  device,/close               ;wait for completion of output to file
  if (prtr eq 'file') then                             $
    begin
      print,'Printout completed; Rename "idl.ps" to save '  ;print confirmation of printout
    endif                                              $
   else                                                $
    begin
      spawn,'lpr -P'+prtr+' idl.ps'          ;send plot to printer
      print,'Printout completed'  ;print confirmation of printout
    endelse
end


;* PRTWIDG_EVENT *  xmanager control for rotated printout widget

pro prtwidg_event,event
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  widget_control,event.id,get_uvalue=evtval
  if (evtval eq 'spline') then                             $
    begin
      whplt=0          ;Only print out rotated data
      prtout          ;Printout Rotated data
    endif                                              $
   else if (evtval eq 'raw') then                       $
    begin
      whplt=1          ;Printout both Original and Rotated data
      prtout
    endif                                              $
   else if (evtval eq 'both') then                     $
    begin
      whplt=2          ;Printout both Original and Rotated data
      prtout
    endif
  widget_control,event.top,/destroy
end
;

;* PRTWIDG *  widget to determine if Rotated data should be printed out

pro prtwidg,group=group
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  base=widget_base(title='PRINT WHICH RESULTS?',xoffset=2.0,xsize=225,/column)

  if (splined ne 0) then                                             $
    but=widget_button(base,value='Splined V3* & V4*',uvalue='spline')

  but=widget_button(base,value='Raw V3* & V4*',uvalue='raw')

  if (splined ne 0) then                                              $
    but=widget_button(base,value='Both Splined & Raw',uvalue='both')

  but=widget_button(base,value='None',uvalue='no')
  widget_control,base,/realize
  xmanager,'prtwidg',base,group_leader=group
end


;   ***   END -- PLOT/PRINT ROTATED DATA   ***



;   ***   DONE?   ***


;* DONEWIDG_EVENT *  xmanager control for DONE? widget

pro donewidg_event,event
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var

  widget_control,event.id,get_uvalue=evtval
  case evtval of
    'same':begin
            finish=0         ;set NOT finished
            same=1           ;set USE SAME files
            widget_control,event.top,/destroy
           end
    'no':begin
          finish=0           ;set NOT finished
          same=0             ;set GET NEW files
          widget_control,event.top,/destroy
         end
    'yes':begin
           finish=1           ;set FINISHED
           widget_control,event.top,/destroy
          end
    'stop':begin
            print,'Paused -- Issue ".cont" command to resume'
            stop
           end
  endcase
end


;* DONEWIDG *  Widget to determine whether finished with program

pro donewidg,group=group

  base=widget_base(title='DONE?',xoffset=2.0,xsize=150,/column)
  but=widget_button(base,value='DONE',uvalue='yes')
  but=widget_button(base,value='Analyze Another',uvalue='no')
  but=widget_button(base,value='Re-run Same Files',uvalue='same')
  but=widget_button(base,value='Pause',uvalue='stop')
  widget_control,base,/realize
  xmanager,'donewidg',base,group_leader=group
end
 

;   ***   END -- DONE?   ***

;


;   ******* MAIN *******


;* MAIN PROGRAM *

pro go_polarwave 
common flags,demo,finish,gap,splined,whplt,same,help,jump,rot,var
common times,bgtim,edtim,bgstr,edstr,bgtimlmt,edtimlmt,bgstrlmt,edstrlmt

  init_program                             ;initial global variables

  while (help ne 0) do                   $
    begin                                  ;determine IDL mode and output
     modewidg                              ;help screen if needed
     if (help ne 0) then helpout
    end

  if (demo eq 0) then prntrwidg

     ;MAIN LOOP

  while (finish ne 1) do             $
    begin

     if (not same) then              $
       begin
         inpt              ;get all new input
         companglarr       ;create array of xpulse times
       endif    $
      else begin                           ;just get new time range
       timewidg
       while (bgtim lt bgtimlmt) or (edtim gt edtimlmt) or        $
             (bgtim gt edtim) do $
        begin
         print
         if (bgtim gt edtim) then                                     $  
           print,'START TIME IS AFTER END TIME -- TRY AGAIN'          $
          else                                                        $
           print,'CHOSEN TIMES ARE OUTSIDE OF ALLOWABLE RANGE -- TRY AGAIN'
         bgtim=bgtimlmt
         edtim=edtimlmt
         bgstr=bgstrlmt
         edstr=edstrlmt
         timewidg
        end
      endelse

     computewidg                           ;Compute ?
     donewidg                              ;Ask if finished with program
    end
end
;    ****** END MAIN ******

