pro load_ss_map,adat,format=format,trange=trange

if not keyword_set(trange) then get_timespan,trange

crange = floor( carr_rot(minmax_range(time_double(trange))))
nrot = crange[1]-crange[0]+1
crots = indgen(nrot)+crange[0]
car_str = strtrim(crots,2)

dir = '/disks/boreas/disk1/davin/wind/analysis/luhmann/data/'

if not keyword_set(format) then format = 'T'

case format of
'R': begin
   f = {lat0:0.,lon0:0.,lat1:0.,lon1:0.,pol:0.}
nlat= 90l
nlon=180
   end
'S': begin      ;  don't use
   f = {lat0:0.,lon0:0.,lat1:0.,lon1:0.,pol:0.}
   end
'T': begin
   f = {lat0:0.,lon0:0.,lat1:0.,lon1:0.,pol:0.,colat2:0.,xxx:0.,B1:0.,B2:0.,open:0}
   nlat= 90l
   nlon= 180
   end
'sheet': begin
   f = {lat0:0.,lon0:0.,lat1:0.,lon1:0.,pol:0.}
   end
endcase



;files = findfile(dir+format+'*')
files = dir+format+car_str
adat=0

nfiles = n_elements(files)
for i=0,nfiles-1 do begin
   file = files[i]
   print,'Reading file: ',file
   read_asc,dat,file,format=f
crot=(360.-dat.lon0)/360.+crots[i]
; help,dat,crot
   s = reverse(transpose(lindgen(nlon,nlat)),2)
plot,crot,dat.lat0,ps=3
   dat = dat[s[*]]
   crot = crot[s[*]]
 help,dat,crot
   if n_elements(dat) ne nlon*nlat then message,'bad file'
   append_array,adat,dat
   append_array,acrot,crot
endfor
  
;help,adat,acrot

s = transpose(lindgen(nlat,nlon*nfiles))
adat = adat[s]
acrot = acrot[s]
help,adat,acrot

time = carr_rot(average(acrot,2),/inver)
lat = 90.- average(adat.lat0,1)
d =  adat.pol * (adat.open +1) 
store_data,'ph_surf',dat={x:time,y:d,v:lat}, $
  dlim={spec:1,ystyle:1,yrange:[-90,90],no_interp:1,panel_size:2}

time = carr_rot(acrot,/inver)
lat0 = 90.- adat.lat0
open = adat.open
lopen = shift(open,nlon,0)
lopen[0:nlon-1,*] = open[0:nlon-1,*]
new_open = open and (not lopen)
wno = where(new_open,c)
if c ne 0 then $
   store_data,'ph_no',data={x:time[wno],y:lat0[wno]},dlim={psym:3}

close = open eq 0
lclose = lopen eq 0
new_close = close and (not lclose)
wnc = where(new_close,c)
if c ne 0 then $
   store_data,'ph_nc',data={x:time[wnc],y:lat0[wnc]},dlim={psym:3}

store_data,'ph_surf2',data=['ph_surf','ph_no','ph_nc'],$
  dlim={ystyle:1,yrange:[-90,90],no_interp:1,panel_size:2}


wopen = where(adat.open)
acrot1 = (360.-adat.lon1)/360.

save,adat,acrot,file='foo
cols = bytescale([-2,-1.,1.,2.],range=[-2,2])

acrot1= round(acrot-acrot1) + acrot1
time1 = carr_rot(acrot1,/inver)
lat1 = 90.-adat.lat1

store_data,'ss_open',data={x:time1[wopen],y:lat1[wopen]}, $
  dlim={psym:3,yrange:[-90,90],ystyle:1,panel_size:2.}

w = where(new_open)
store_data,'ss_nopen',data={x:time1[w],y:lat1[w]}, $
  dlim={psym:1,yrange:[-90,90],ystyle:1,panel_size:2.,colors:1}

w = where(new_open and (adat.pol eq 1))
store_data,'ss_+nopen',data={x:time1[w],y:lat1[w]}, $
  dlim={psym:1,yrange:[-90,90],ystyle:1,panel_size:2.,colors:cols[3]}

w = where(new_open and (adat.pol eq -1))
store_data,'ss_-nopen',data={x:time1[w],y:lat1[w]}, $
  dlim={psym:1,yrange:[-90,90],ystyle:1,panel_size:2.,colors:cols[0]}

ts = time_double(['1994-10-1','1999-1-1'])
thg = dgen(range=ts,400)
store_data,'hg_lat',data={x:thg,y:7.25*sin((thg/365.25d/24d/3600d -0.423)*2.*!dpi)}, $
   dlim={colors:3,psym_lim:2}

store_data,'ss_open2',data='ss_open ss_-nopen ss_+nopen cur_sheet hg_lat',dlim={panel_size:2.}


end

