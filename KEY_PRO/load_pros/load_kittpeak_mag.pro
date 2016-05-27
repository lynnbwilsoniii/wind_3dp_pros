pro load_kittpeak_mag

format = {year:0,month:0,date:0,ut:0,tday:0.,Bav:0.,Braw:0.,Bcorr:0.,n:0l}
file = '/home/davin/dat/solar/kittpeak/mag.dat'

dat = read_asc(file,format=format)

time = dat.tday * 86400d
store_data,'kp_mag_Bav',data={x:time, y:dat.bav}
store_data,'kp_mag_Braw',data={x:time, y:dat.braw}
store_data,'kp_mag_Bcorr',data={x:time, y:dat.bcorr},dlim={ytitle:"<|Bsolar|>"}

end
