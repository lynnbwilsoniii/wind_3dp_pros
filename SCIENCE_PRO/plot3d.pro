;+
;NAME:
;  PLOT3D
;PROCEDURE: plot3d, dat , latitude, longitude
;PURPOSE:
;  Draws a series of 3d color plots, one plot per energy step.
;INPUT:
;  dat:  3d data structure.
;  latitude:  latitude of center of plot
;  longitude:  longitude of center of plot
;KEYWORDS:
;   EBINS:     Specifies energy bins to plot.
;   SUM_EBINS: Specifies how many bins to sum, starting with EBINS.  If
;              SUM_EBINS is a scalar, that number of bins is summed for
;              each bin in EBINS.  If SUM_EBINS is an array, then each
;              array element will hold the number of bins to sum starting
;              at each bin in EBINS.  In the array case, EBINS and SUM_EBINS
;              must have the same number of elements.
;   BNCENTER:  if > 0 then lat,lon set so that B direction is in center
;              if < 0 then lat,lon set so that -B direction is in center
;              ('magf' element must exist in dat structure. See "ADD_MAGF")
;   BINS:    bins to use for autoscaling.
;   SMOOTH:  smoothing parameter.  0=none,  2 is typical
;   TITLE:   overrides default plot title.
;   NOTITLE: if set, suppresses plot title.
;   NOCOLORBAR: if set, suppresses colorbar.
;   NOBORDER: if set, suppresses plot border.
;SEE ALSO:  "PLOT3D_OPTIONS" to see how to set other options.
;
;NOTE: plot3d_new has replaced plot3d to eliminate a naming conflict between plot3d and a library routine that was added to IDL in version 8.1.  
;      The original plot3d.pro remains to preserve backwards compatibility for users using IDL 7.1 or earlier. 
;
;CREATED BY:	Davin Larson
;LAST MODIFICATION:	@(#)plot3d.pro	1.43 02/04/17
;-
pro plot3d,tbindata, latitude,longitude,rotation, $
_ref_extra=rex
;   BINS=bins,            $
;   TBINS=tbins,          $
;   BNCENTER=bncenter,    $
;   LABELS=labs,          $
;   SMOOTH= smoth,        $
;   EBINS=eb,             $
;   SUM_EBINS=seb,        $
;   PTLIMIT=plot_limits,  $
;   MAP= ptmap,           $
;   UNITS = units,        $
;   SETLIM = setlim,      $
;   PROC3D = proc3d,      $
;   ZRANGE = zrange,      $
;   ZERO = zero,          $
;   STACK = stack,        $     ;!p.multi[1:2]
;   ROW_MAJOR = row_major,$     ;!p.multi[4]
;   NOERASE = noerase,    $     ;!p.multi[0]
;   TITLE = title,	 $
;   NOTITLE = notitle,    $
;   NOCOLORBAR = nocolorbar,	$
;   NOBORDER = noborder,$
;   log=log

plot3d_new,tbindata, latitude,longitude,rotation,_strict_extra=rex

end


