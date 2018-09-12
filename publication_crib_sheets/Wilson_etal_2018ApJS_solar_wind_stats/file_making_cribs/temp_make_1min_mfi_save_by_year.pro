;;  .compile /Users/lbwilson/Desktop/temp_idl/solar_wind_stats/temp_make_1min_mfi_save_by_year.pro

PRO temp_make_1min_mfi_save_by_year,YEAR=year

;;----------------------------------------------------------------------------------------
;;  Constants
;;----------------------------------------------------------------------------------------
f              = !VALUES.F_NAN
d              = !VALUES.D_NAN
slash          = get_os_slash()       ;;  '/' for Unix, '\' for Windows
;;----------------------------------------------------------------------------------------
;;  Coordinates and vectors
;;----------------------------------------------------------------------------------------
coord_gse      = 'gse'
coord_mag      = 'mag'
coord_gseu     = STRUPCASE(coord_gse[0])
vec_str        = ['x','y','z']
vec_col        = [250,200,75]
xyz_str        = vec_str
xyz_col        = vec_col
;;  Define spacecraft name
sc             = 'Wind'
probe          = 'wind'
probeu         = 'Wind'
scpref         = probe[0]+'_'
scprefu        = probeu[0]+'_'
;;  Date/Time stuff
start_of_day_t = '00:00:00.000000000'
end___of_day_t = '23:59:59.999999999'
start_of_day   = '00:00:00.000000'
end___of_day   = '23:59:59.999999'
;;----------------------------------------------------------------------------------------
;;  Define date/time of interest
;;----------------------------------------------------------------------------------------
year0          = num2int_str(year[0],NUM_CHAR=4)
tdate0         = year0[0]+'-01-01'
test           = test_tdate_format(tdate0[0],/NOMSSG)
IF (~test[0]) THEN STOP        ;;  Stop before user runs into issues
lyr_st         = LONG(year[0])
lyr_en         = lyr_st[0] + 1L
year1          = num2int_str(lyr_en[0],NUM_CHAR=4)
tdate1         = year1[0]+'-01-01'
test           = test_tdate_format(tdate1[0],/NOMSSG)
IF (~test[0]) THEN STOP        ;;  Stop before user runs into issues
;;  Define time string
tr_str         = [tdate0[0],tdate1[0]]+'/'+start_of_day[0]
tran           = time_double(tr_str)
;;  Check time range
test           = get_valid_trange(TRANGE=tran,PRECISION=6)
IF (SIZE(test[0],/TYPE) NE 8) THEN STOP        ;;  Stop before user runs into issues
;tran           = trange
tr_lim         = tran + [-1,1]*864d2
;;  Load 1 minute B-field data
;;wind_h0_mfi_2_tplot,/B3SEC,/LOAD_GSE,TRANGE=tr_lim
wind_h0_mfi_2_tplot,/B1MIN,B3SEC=0,/LOAD_GSE,TRANGE=tr_lim
;;  Define time suffix for output files
tsuffx         = year0[0]+'-'+year1[0]
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
;;  Save TPLOT file
;;----------------------------------------------------------------------------------------
;;----------------------------------------------------------------------------------------
sav_dir        = slash[0]+'Users'+slash[0]+'lbwilson'+slash[0]+'Desktop'+slash[0]+$
                 'temp_idl'+slash[0]+'solar_wind_stats'+slash[0]+'sav_files'+slash[0]
fname_out      = scpref[0]+'1min_MFI_'+tsuffx[0]
fname          = sav_dir[0]+fname_out[0]
tplot_save,FILENAME=fname[0]

;;  Clean up
tpns           = tnames()
IF (tpns[0] NE '') THEN store_data,DELETE=tpns
;;----------------------------------------------------------------------------------------
;;  Return to user
;;----------------------------------------------------------------------------------------

RETURN
END