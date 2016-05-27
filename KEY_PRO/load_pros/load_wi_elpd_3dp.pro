;+
;PROCEDURE:	load_wi_elpd_3dp
;PURPOSE:	
;   loads WIND 3D Plasma Experiment key parameter data for "tplot".
;
;INPUTS:
;  none, but will call "timespan" if time_range is not already set.
;KEYWORDS:
;  DATA:        Raw data can be returned through this named variable.
;  NVDATA:	Raw non-varying data can be returned through this variable.
;  TIME_RANGE:  2 element vector specifying the time range.
;  NO_PLOT:	Suppresses the display of the summary plot.
;  MASTERFILE:	(string) full filename of master file.
;  PREFIX:	(string) prefix for returned TPLOT variables.  Default is
;		'elpd'
;  RESOLUTION:	Resolution to return in seconds.
;SEE ALSO: 
;  "make_cdf_index","loadcdf","loadcdfstr","loadallcdf"
;
;CREATED BY:	Davin Larson
;FILE:  load_wi_elpd_3dp.pro
;LAST MODIFICATION: 99/05/27
;-
pro load_wi_elpd_3dp $
   ,time_range=trange $
   ,data=d $
   ,nvdata = nd $
   ,masterfile=masterfile $
   ,prefix = prefix $
   ,plot_it=plot_it $
   ,resolution=res $
   ,no_plot = no_plot

;hours = 0.0d0
;if keyword_set(trange) then $
;	hours = (str_to_time(trange(1)) - str_to_time(trange(0)))/3600. $
;	& print, hours

;if not keyword_set(trange) then $
;	timespan else timespan, trange(0), hours, /hours

if not keyword_set(masterfile) then masterfile = 'wi_elpd_3dp_files'

cdfnames = ['FLUX',  'ENERGY' ,'PANGLE','MAGF','VSW']

loadallcdf,masterfile=masterfile,cdfnames=cdfnames,data=d, $
   novarnames=novarnames,novard=nd,time_range=trange,res=res

if data_type(prefix) eq 7 then px=prefix else px = 'elpd'
;checkcdf1
store_data,px,data={x:d.time,y:dimen_shift(d.flux,1), $
  v1:dimen_shift(d.energy,1),v2:dimen_shift(d.pangle,1)}$
  ,min=-1e30,dlim={ylog:1}

energies = dimen_shift(d.energy,1)
angles = dimen_shift(d.pangle,1)

IF NOT keyword_set(no_plot) then begin
  ;!p.charsize = 0.35
  options, slim, 'spec', 1
  ylim, slim, 0, 180, 0
  ylim, slim2, 1, 1, 1
  options, slim, 'max_value', 1e8

  ang_size = size(angles)
  e_size = size(energies)

  n_ang = ang_size(ang_size(0))
  n_nrg = e_size(e_size(0))

  el_arr1 = strarr(n_nrg)

  for i = 0, n_nrg-1, 1 do begin
    reduce_dimen, px, 1, i, i, deflim = slim
    el_arr1(i) = px +'-1-'+ strcompress(/remove_all, string(i) + $
	':' + string(i))
    append = strcompress('-1-' +   $
	string(i) + ':' + string(i), /remove_all)
    valid = where(finite( energies(*, i) ))
    if valid(0) ne -1 then begin
      E1 =  total(energies(where(finite( energies(*, i) )),i)) $
	/total(finite(energies(*, i)))
      options, px+append, 'ytitle', strcompress(   $
	string(E1, $
	format = '(f6.1,  " eV")'))
    endif else begin
      options, px+append, 'ytitle', 'NaN'
    endelse
  ENDFOR

  el_arr2 = strarr(n_ang)

  FOR i = 0, n_ang-1, 1 do begin
    reduce_dimen, px, 2, i, i, deflim = slim2
    el_arr2(i) = strcompress(/remove_all, px +'-2-'+ string(i) + $
	':' + string(i))
    append = strcompress('-2-' +   $
	string(i) + ':' + string(i), /remove_all)
    valid = where(finite(angles(*, i)))
    if valid(0) ne -1  then begin
      ang1 =  total(angles(where(finite(angles(*, i) )), i)) $
	/total(finite(angles(*, i)))
      options, px+append, 'ytitle', strcompress(   $
	string(ang1, $
	format = '(f6.1, " Deg")'))
    endif else begin
      options, px+append, 'ytitle', 'NaN'
    endelse
  ENDFOR

  zlim, el_arr1, 1, 1, 1

  ylim, el_arr2, 1, 1, 1

  if keyword_set(plot_it) then begin

  ; Plotting the results of the pad =========================================
    pclose
    loadct, 39
    !p.charsize = 0.35
    tplot_options, title = 'Wind 3D Plasma'
    tplot_options, ygap = 0.

    print, [el_arr1, el_arr2]
    tplot, [el_arr1, el_arr2]
  endif
ENDIF

return
end

