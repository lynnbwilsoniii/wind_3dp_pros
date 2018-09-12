;;----------------------------------------------------------------------------------------
;; => Compile necessary routines
;;----------------------------------------------------------------------------------------
@comp_lynn_pros
thm_init
;;----------------------------------------------------------------------------------------
;; => Load all relevant data
;;----------------------------------------------------------------------------------------
@/Users/lbwilson/Desktop/swidl-0.1/IDL_stuff/cribs/THEMIS_cribs/load_themis_e_data_2010-08-23_batch.pro


t_foot_ra0     = time_double(tdate[0]+'/'+['22:09:48.679','22:09:52.218'])
t_foot_ra1     = time_double(tdate[0]+'/'+['22:20:00.150','22:20:10.830'])
t_foot_ra2     = time_double(tdate[0]+'/'+['22:25:00.150','22:25:22.016'])
t_ramp_ra0     = time_double(tdate[0]+'/'+['22:09:48.421','22:09:48.679'])
t_ramp_ra1     = time_double(tdate[0]+'/'+['22:20:10.830','22:20:14.090'])
t_ramp_ra2     = time_double(tdate[0]+'/'+['22:25:15.094','22:25:15.433'])
;;----------------------------------------------------------------------------------------
;;    Convert into bulk flow frame and find new bulk flow velocities
;;
;;    This assumes the maximum peak of the distribution corresponds to the center of
;;      the "core" of the ion distribution.  If the source of error is due to ion beams,
;;      whether field-aligned or gyrating, then their maximum phase (velocity) space
;;      density should be less than the "core" part.  Therefore, the routine
;;      fix_vbulk_ions.pro finds the peak in phase (velocity) space density and then
;;      determines the corresponding velocity.  The steps are as follows:
;;        1)  transform into bulk flow frame  =>  V' = V - V_sw (transform_vframe_3d.pro)
;;        2)  define velocity of the peak, V_peak, in this frame  =>
;;              V" = V' - V_peak = V - (V_sw + V_peak)
;;        3)  return new transformation velocity, V_new = (V_sw + V_peak), from
;;              spacecraft frame to "true" bulk flow frame
;;
;;----------------------------------------------------------------------------------------
vbulk_old      = TRANSPOSE(dat_igse.VSW)  ;;  Level-2 Moment Estimates [km/s, GSE]
;;  Define sheath time ranges
tr_sheath_0    = [tr_00[0],t_ramp_ra0[0]]
tr_sheath_1    = [t_ramp_ra1[0],t_ramp_ra2[0]]

i_time0        = dat_igse.TIME
i_time1        = dat_igse.END_TIME
good_sh_0      = WHERE(i_time0 GE tr_sheath_0[0] AND i_time1 LE tr_sheath_0[1],gd_sh_0)
good_sh_1      = WHERE(i_time0 GE tr_sheath_1[0] AND i_time1 LE tr_sheath_1[1],gd_sh_1)
good_sh        = [good_sh_0,good_sh_1]
PRINT,';; ', gd_sh_0, gd_sh_1


nlon           = 30L                       ;;  # of longitudinal bins
nlat           = 30L                       ;;  # of latitudinal bins
npnt           = 20L
;;  Define speed ranges [for sheath only]
mxVsw          = 5d2
mx_Vx          = 30d1
mx_Vy          = 20d1
mx_Vz          = 20d1
;;  Define angular ranges for solar wind
lonran_sw      = 18d1 + [-1d0,1d0]*45d0
latran_sw      =  0d0 + [-1d0,1d0]*25d0
;;  Define angular ranges for sheath
lonran_sh      = 18d1 + [-1d0,1d0]*95d0
latran_sh      =  0d0 + [-1d0,1d0]*50d0
;;  Define structures for _EXTRA
pstr_sw        = {NLON:nlon,NLAT:nlat,NPNT:npnt,VLIMR:mxVsw[0],LON_RAN:lonran_sw,   $
                  LAT_RAN:latran_sw}
pstr_sh        = {NLON:nlon,NLAT:nlat,NPNT:npnt,LON_RAN:lonran_sh,LAT_RAN:latran_sh,$
                  VLIMR:mxVsw[0],VLIMX:mx_Vx[0],VLIMY:mx_Vy[0],VLIMZ:mx_Vz[0]}
;;  Define units and method
;;  UNITS
units          = 'flux'
;;  GRID_METH
method         = "invdist"


vbulk_new      = REPLICATE(d,n_i,3L)       ;;  New bulk flow velocities = V_new [km/s, GSE]
all_vbulk      = REPLICATE(d,n_i,npnt,3L)  ;;  All velocities [km/s]
avg_vbulk      = REPLICATE(d,n_i,3L)
med_vbulk      = REPLICATE(d,n_i,3L)
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/grid_on_spherical_shells.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/esa_mcp_software/grid_mcp_esa_data_sphere.pro
.compile /Users/lbwilson/Desktop/swidl-0.1/wind_3dp_pros/LYNN_PRO/esa_mcp_software/find_core_bulk_velocity.pro
FOR j=0L, n_i - 1L DO BEGIN                                                                             $
  dat            = dat_igse[j]                                                                        & $
  test           = TOTAL(j EQ good_sh) EQ 1                                                           & $
  IF (test) THEN pstr = pstr_sh ELSE pstr = pstr_sw                                                   & $
  temp           = find_core_bulk_velocity(dat[0],UNITS=units[0],GRID_METH=method[0],_EXTRA=pstr[0])  & $
  IF (SIZE(temp,/TYPE) EQ 8) THEN all_vbulk[j,*,*] = temp.ALL                                         & $
  IF (SIZE(temp,/TYPE) EQ 8) THEN avg_vbulk[j,*]   = temp.AVG                                         & $
  IF (SIZE(temp,/TYPE) EQ 8) THEN med_vbulk[j,*]   = temp.MED

out_t          = (dat_igse.TIME + dat_igse.END_TIME)/2d0
test_vavgxyz   = FINITE(avg_vbulk[*,0]) AND FINITE(avg_vbulk[*,1]) AND FINITE(avg_vbulk[*,2])
test_vmedxyz   = FINITE(med_vbulk[*,0]) AND FINITE(med_vbulk[*,1]) AND FINITE(med_vbulk[*,2])
good_vavgx     = WHERE(test_vavgxyz,gdvax,COMPLEMENT=bad_vavgx,NCOMPLEMENT=bdvax)
good_vmedx     = WHERE(test_vmedxyz,gdvmx,COMPLEMENT=bad_vmedx,NCOMPLEMENT=bdvmx)
PRINT,';; ', bdvax, bdvmx

;;  Linearly interpolate spikes
;;  Avg. Vbulk
IF (gdvax GT 0) THEN avg_vbulkx = interp(avg_vbulk[good_vavgx,0],out_t[good_vavgx],out_t,/NO_EXTRAP)
IF (gdvax GT 0) THEN avg_vbulky = interp(avg_vbulk[good_vavgx,1],out_t[good_vavgx],out_t,/NO_EXTRAP)
IF (gdvax GT 0) THEN avg_vbulkz = interp(avg_vbulk[good_vavgx,2],out_t[good_vavgx],out_t,/NO_EXTRAP)
IF (gdvax GT 0) THEN avg_vbulkn = [[avg_vbulkx],[avg_vbulky],[avg_vbulkz]] ELSE avg_vbulkn = 0
;;  Med. Vbulk
IF (gdvmx GT 0) THEN med_vbulkx = interp(med_vbulk[good_vmedx,0],out_t[good_vmedx],out_t,/NO_EXTRAP)
IF (gdvmx GT 0) THEN med_vbulky = interp(med_vbulk[good_vmedx,1],out_t[good_vmedx],out_t,/NO_EXTRAP)
IF (gdvmx GT 0) THEN med_vbulkz = interp(med_vbulk[good_vmedx,2],out_t[good_vmedx],out_t,/NO_EXTRAP)
IF (gdvmx GT 0) THEN med_vbulkn = [[med_vbulkx],[med_vbulky],[med_vbulkz]] ELSE med_vbulkn = 0
test_vavg      = (N_ELEMENTS(avg_vbulkn) GT 1)
test_vmed      = (N_ELEMENTS(med_vbulkn) GT 1)


;;  Send results to TPLOT to compare
coord_gse      = 'gse'
velname0       = tnames(pref[0]+'peib_velocity_'+coord_gse[0])
get_data,velname0[0],DATA=L2_v_str,DLIM=dlim,LIM=lim

scpref_u       = STRUPCASE(STRMID(pref[0],0,3))
out_vavg_tpn   = pref[0]+'SphericalGrid_Vbulk_Avg_'+coord_gse[0]
out_vavg_yttl  = '<'+'V!Dbulk!N'+'> [km/s, '+STRUPCASE(coord_gse[0])+']'
out_vavg_suby  = '['+scpref_u[0]+', IESA Burst]'+'!C'+'[Avg. Core Vbulk]'
out_vmed_tpn   = pref[0]+'SphericalGrid_Vbulk_Med_'+coord_gse[0]
out_vmed_yttl  = 'Median('+'V!Dbulk!N'+') [km/s, '+STRUPCASE(coord_gse[0])+']'
out_vmed_suby  = '['+scpref_u[0]+', IESA Burst]'+'!C'+'[Med. Core Vbulk]'

IF (test_vavg) THEN struc          = {X:out_t,Y:avg_vbulkn}
IF (test_vavg) THEN store_data,out_vavg_tpn[0],DATA=struc,DLIM=dlim,LIM=lim
IF (test_vavg) THEN options,out_vavg_tpn[0],'YTITLE',out_vavg_yttl[0],/DEF
IF (test_vavg) THEN options,out_vavg_tpn[0],'YSUBTITLE',out_vavg_suby[0],/DEF

IF (test_vmed) THEN struc          = {X:out_t,Y:med_vbulkn}
IF (test_vmed) THEN store_data,out_vmed_tpn[0],DATA=struc,DLIM=dlim,LIM=lim
IF (test_vmed) THEN options,out_vmed_tpn[0],'YTITLE',out_vmed_yttl[0],/DEF
IF (test_vmed) THEN options,out_vmed_tpn[0],'YSUBTITLE',out_vmed_suby[0],/DEF

;;  Smooth result to reduce data "spike" amplitudes
get_data,out_vavg_tpn[0],DATA=struc,DLIM=dlim,LIM=lim

vsm            = 5L
sm_str         = STRTRIM(STRING(vsm[0],FORMAT='(I4.4)'),2)
tpnm_suff      = '_sm'+sm_str[0]+'pts'
ysub_suff      = '[Avg. Core, Smooth: '+sm_str[0]+' Pts]'
smvx           = SMOOTH(avg_vbulkx,vsm[0],/EDGE_TRUNCATE,/NAN)
smvy           = SMOOTH(avg_vbulky,vsm[0],/EDGE_TRUNCATE,/NAN)
smvz           = SMOOTH(avg_vbulkz,vsm[0],/EDGE_TRUNCATE,/NAN)
smvel          = [[smvx],[smvy],[smvz]]

;;  Send result to TPLOT
vnew_str       = {X:out_t,Y:smvel}                            ;; TPLOT structure
vname_n        = out_vavg_tpn[0]+tpnm_suff[0]                 ;; TPLOT handle
out_vavg_suby  = '['+scpref_u[0]+', IESA Burst, Vbulk]'+'!C'+ysub_suff[0]

store_data,vname_n[0],DATA=vnew_str,DLIM=dlim,LIM=lim
options,vname_n[0],'YSUBTITLE',out_vavg_suby[0],/DEF










