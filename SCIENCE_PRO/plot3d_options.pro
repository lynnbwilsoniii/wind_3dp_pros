;+
;*****************************************************************************************
;
;  FUNCTION :   plot3d_options.pro
;  PURPOSE  :   This program sets up the default options for the plot3d.pro routine.
;
;  CALLED BY:   
;               plot3d.pro
;
;  CALLS:
;               plot3d_com.pro
;
;  REQUIRES:    
;               NA
;
;  INPUT:
;               NA
;
;  EXAMPLES:    
;              ..........................................................................
;              :=> To use the Hammer-Aitoff equal area projection, a logarithmic        :
;              :     Z-Axis range, triangulation, full map resolution, and              :
;              :     an output with grid lines every 30 degrees both latitudinally and  :
;              :     longitudinally, do the following                                   :
;              ..........................................................................
;               plot3d_options,MAP='ham',LOG =1,TRIANGULATE=1,COMPRESS=1,GRID=[30.,30.]
;
;  KEYWORDS:    
;               MAP          :  Scalar string corresponding to one the 3D map projections
;                                 allowed by the IDL built-in MAP_SET.PRO, which include:
;                                 [Default = 'ait']
;                                 'ait'  :  Aitoff projection
;                                 'cyl'  :  Cylindrical equidistant projection
;                                 'gno'  :  Gnomonic projection
;                                 'ham'  :  Hammer-Aitoff (equal area projection)
;                                 'lam'  :  Lambert's azimuthal equal area projection
;                                 'mer'  :  Mercator projection
;                                 'mol'  :  Mollweide projection
;                                 'ort'  :  Orthographic projection
;               SMOOTH       :  If set, data is rebinned and smoothed
;               GRID         :  2-Element array defining the grid spacing of the lines 
;                                 created by the IDL built-in MAP_GRID.PRO [degrees]
;                                 [Default = [45.,45.] ]
;               LOG          :  If set, color scale is on a log-scale, else linear
;                                 [Default = 0]
;               COMPRESS     :  Scalar integer defining map resolution controlled by the
;                                 COMPRESS keyword in the IDL built-in MAP_IMAGE.PRO
;                                 [Default = 1 which solves the inverse map 
;                                   transformation for every pixel of the output image]
;               TRIANGULATE  :  If set, plot3d.pro will use spherical triangulation
;                                 [Default = 0]
;               LATITUDE     :  Scalar value defining the center latitude of the map
;                                 projection to use as the observed center when plotted
;                                 [Default = 0]
;               LONGITUDE    :  Same as LATITUDE keyword, but for longitude
;                                 [Default = 180]
;               ZRANGE       :  ??
;
;   CHANGED:  1)  Davin Larson changed something...             [09/24/1996   v1.0.10]
;             2)  Fixed syntax with keyword functionalities:  GRID and ZRANGE
;                   and cleaned up and updated Man. page        [09/25/2009   v1.1.0]
;
;   NOTES:      
;               1)  Both LATITUDE and LONGITUDE are in degrees
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  09/25/2009   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO plot3d_options,MAP=map,SMOOTH=smoth,GRID=grid,LOG=log,COMPRESS=compress,  $
                   TRIANGULATE=triang,LATITUDE=latitude,LONGITUDE=longitude,  $
                   ZRANGE=zrange

;-----------------------------------------------------------------------------------------
; => Define common blocks
;-----------------------------------------------------------------------------------------
@plot3d_com.pro
;-----------------------------------------------------------------------------------------
; => Define parameters if keywords are set
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(map)           ) THEN mapname_3d   = map
IF (N_ELEMENTS(compress)      ) THEN compress_3d  = compress
IF (N_ELEMENTS(smoth)         ) THEN smooth_3d    = smoth
IF (N_ELEMENTS(grid)      NE 0) THEN grid_3d      = grid
IF (N_ELEMENTS(log)           ) THEN logscale_3d  = log
IF (N_ELEMENTS(triang)        ) THEN triang_3d    = triang
IF (N_ELEMENTS(zrange)    NE 0) THEN zrange_3d    = zrange
IF (N_ELEMENTS(latitude)      ) THEN latitude_3d  = latitude
IF (N_ELEMENTS(longitude)     ) THEN longitude_3d = longitude
;-----------------------------------------------------------------------------------------
; => Define default parameters and check input format
;-----------------------------------------------------------------------------------------
IF (N_ELEMENTS(mapname_3d)   EQ 0) THEN mapname_3d   = 'ait'
IF (N_ELEMENTS(compress_3d)  EQ 0) THEN compress_3d  = 1
IF (N_ELEMENTS(smooth_3d)    EQ 0) THEN smooth_3d    = 0
IF (N_ELEMENTS(grid_3d)      EQ 0) THEN grid_3d      = [45,45]
IF (N_ELEMENTS(logscale_3d)  EQ 0) THEN logscale_3d  = 0
IF (N_ELEMENTS(triang_3d)    EQ 0) THEN triang_3d    = 0
IF (N_ELEMENTS(latitude_3d)  EQ 0) THEN latitude_3d  = 0.
IF (N_ELEMENTS(longitude_3d) EQ 0) THEN longitude_3d = 180.
IF (N_ELEMENTS(zrange_3d)    EQ 0) THEN zrange_3d    = REPLICATE(0.,64,2)

END

