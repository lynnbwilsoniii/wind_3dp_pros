;+
; PROCEDURE:
;	PLOT_MAP
;
; DESCRIPTION:
;
;	Plot the map from the standard 3-D data structure that is returned
;	from the IDL from SDT interface.  The THETA, PHI, DTHETA, DPHI,
;	DATA_NAME and PROJECT_NAME tags must exist for this routine to work.  
;	(The standard 3-D data structure should contain these.)
;
;	
; CALLING SEQUENCE:
;
; 	plot_map, data_structure
;
; ARGUMENTS:
;
;	data_structure 		The standard 3-D data structure to plot the
;				map from.
;
; REVISION HISTORY:
;
;	@(#)plot_map.pro	1.1 22 Aug 1995
; 	Originally written by Jonathan M. Loran,  University of 
; 	California at Berkeley, Space Sciences Lab.   Aug. '95
;-
 
PRO Plot_map, dat

   ; check existance of THETA, DTHETA, PHI and DPHI tags

   IF N_ELEMENTS (dat) EQ 0 THEN BEGIN
      PRINT, '@(#)plot_map.pro	1.1: An input parameter must be specified'
      RETURN
   ENDIF 

   IF data_type (dat) NE 8 THEN BEGIN 
      PRINT, '@(#)plot_map.pro	1.1: The input parameter must be structure'
      RETURN
   ENDIF 

   dat_tags = TAG_NAMES (dat)
   IF (WHERE (dat_tags EQ 'THETA')) (0) EQ -1 OR                   $
     (WHERE (dat_tags EQ 'DTHETA')) (0) EQ -1 OR                   $
     (WHERE (dat_tags EQ 'PHI')) (0) EQ -1 OR                      $
     (WHERE (dat_tags EQ 'DPHI')) (0) EQ -1 OR                     $
     (WHERE (dat_tags EQ 'PROJECT_NAME')) (0) EQ -1 OR             $
     (WHERE (dat_tags EQ 'DATA_NAME')) (0) EQ -1                   $
     THEN BEGIN
      PRINT, "@(#)plot_map.pro	1.1: The input structure doesn't contain the necessary tags:"
      PRINT, '    PHI, DPHI, THETA, DTHETA and DATA_NAME to draw the map'
      RETURN
   ENDIF

   ; build min/max arrays of angles

   minphi = dat.phi(0, *) - dat.dphi/2.
   maxphi = dat.phi(0, *) + dat.dphi/2.
   mintheta = dat.theta(0, *) - dat.dtheta/2.
   maxtheta = dat.theta(0, *) + dat.dtheta/2.

   ; plot limits

   minx = MIN (minphi)
   maxx = MAX (maxphi)
   miny = MIN (mintheta)
   maxy = MAX (maxtheta)
   
   plotstart = 1
   
   ; loop through bin array 
   
   FOR i = 0, N_ELEMENTS(dat.theta(0, *))-1 DO BEGIN

      ; plot the bin
      
      IF plotstart THEN BEGIN
         plotstart = 0 
         PLOT, TITLE = 'Angle Map of: ' + dat.project_name + ', '       $
           + dat.data_name,                                             $
           XTITLE = 'Phi (degrees)',                                    $
           YTITLE = 'Theta (degrees)',                                  $
           LINESTYLE = 3,                                               $
           XRANGE = [minx, maxx], YRANGE = [miny, maxy],                $
           XSTYLE = 1, YSTYLE = 1,                                      $
           [minphi(i), maxphi(i), maxphi(i), minphi(i)],                $
           [mintheta(i), mintheta(i), maxtheta(i), maxtheta(i)]
      ENDIF ELSE BEGIN
         OPLOT,                                                         $
           LINESTYLE = 3,                                               $
           [minphi(i), maxphi(i), maxphi(i), minphi(i)],                $
           [mintheta(i), mintheta(i), maxtheta(i), maxtheta(i)]

      ENDELSE

      ; mark bin number in bin

      XYOUTS, ALIGN = 1.0, (minphi(i) + maxphi(i))/2.,             $
        (mintheta(i) + maxtheta(i))/2., string(i)

   ENDFOR
END 
