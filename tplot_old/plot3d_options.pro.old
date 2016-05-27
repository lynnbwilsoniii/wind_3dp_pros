;+
;PROCEDURE:  plot3d_options
;PURPOSE:  Sets default options for the "plot3d" routine
;   The only inputs are through keywords:
;KEYWORDS:
;   MAP:  one of the following strings: 
;       'cylindrical', 'molleweide', 'ait' ,'lambert'  .... 
;       (See manual for other maps, only the first 3 characters are req'd)
;   COMPRESS:  integer defining map resolution (see manual)  1 si default
;   SMOOTH:    0 gives no smoothing.
;   LOG:       0: linear color scale;   1: log color scale
;   TRIANGULATE:  Uses spherical triangulation if set
;   LATITUDE:  Center Latitude.
;   LONGITUDE: Center Longitude.
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)plot3d_options.pro	1.10 96/09/24
;-
pro plot3d_options,    $
   MAP=map,            $
   SMOOTH= smoth,      $
   GRID  = grid,      $
   LOG = log,          $
   COMPRESS=compress,  $
   TRIANGULATE=triang, $
   LATITUDE = latitude,$
   LONGITUDE=longitude,$
   zrange = zrange

@plot3d_com.pro
if n_elements(map) then mapname_3d = map
if n_elements(compress) then compress_3d = compress
if n_elements(smoth)  then smooth_3d = smoth
if n_elements(grid)  then grid_3d = grid
if n_elements(log)  then logscale_3d = log
if n_elements(triang)  then triang_3d = triang
if n_elements(zrange) then zrange_3d = zrange
if n_elements(latitude)  then latitude_3d = latitude
if n_elements(longitude) then longitude_3d = longitude

if n_elements(mapname_3d)   eq 0 then mapname_3d = 'ait'
if n_elements(compress_3d)  eq 0 then compress_3d = 1
if n_elements(smooth_3d)    eq 0 then smooth_3d = 0
if n_elements(grid_3d)      eq 0 then grid_3d   = [45,45]
if n_elements(logscale_3d)  eq 0 then logscale_3d = 0
if n_elements(triang_3d)    eq 0 then triang_3d = 0
if n_elements(latitude_3d)  eq 0 then latitude_3d = 0.
if n_elements(longitude_3d) eq 0 then longitude_3d = 180.
if n_elements(zrange_3d)    eq 0 then zrange_3d = replicate(0.,64,2)

end

