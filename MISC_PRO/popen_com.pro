;+
;*****************************************************************************************
;
;  COMMON   :   popen_com.pro
;  PURPOSE  :   Common block for print routines
;
;  CALLED BY:   
;               popen.pro
;               pclose.pro
;               print_options.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  THEMIS TDAS IDL libraries or UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               NA
;
;  OUTPUT:
;               HARDCOPY_STUFF2  :  Common block name tag
;               OLD_DEVICE       :  Scalar [string] defined by !D.NAME prior to any
;                                     changes made by popen.pro
;               PRINT_OPTS       :  *** Not defined ***
;               OLD_PLOT         :  Structure containing !P prior to any changes
;                                     made by popen.pro
;               OLD_FNAME        :  Scalar [string] that defines the full file name
;                                     [with extension] associated with the output
;                                     from popen.pro and pclose.pro
;               OLD_COLORS_COM   :  Structure containing the color variables defined
;                                     by IDL's default common block, COLORS
;               PORTRAIT         :  Scalar [integer] defining whether to use portrait
;                                     format for output
;                                     [Default = TRUE]
;               IN_COLOR         :  Scalar [integer] defining whether the image is a color
;                                     or black-and-white image
;                                     [Default = TRUE]
;               PRINT_ASPECT     :  Keeps track of the aspect ratio for the output
;                                     defined by the user
;                                     [Default = 0]
;               PRINTER_NAME     :  Scalar [string] defining the name of the printer to
;                                     send PS files to for a hard copy
;                                     [** Unix specific keyword **]
;               PRINT_DIRECTORY  :  Scalar [string] that defines the directory where
;                                     the output file should be printed to
;                                     [Default = FILE_EXPAND_PATH('')]
;               PRINT_FONT       :  Scalar [integer] defining the font setting to use
;                                     for file outputs associated with !P.FONT
;               POPENED          :  Scalar [integer] defining whether popen.pro has been
;                                     called already [if TRUE] or not [if FALSE]
;
;  EXAMPLES:    
;               @popen_com.pro
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Davin Larson changed something...                [12/05/1997   v1.0.10]
;             2)  Updated to be in accordance with newest version of popen_com.pro
;                   in TDAS IDL libraries
;                   A)  Cleaned up and added more to manual page
;                                                                  [08/27/2012   v1.1.0]
;
;   NOTES:      
;               1)  See also:  popen.pro, pclose.pro, and print_options.pro
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  08/27/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

COMMON hardcopy_stuff2,old_device, $
       print_opts,                 $
       old_plot,                   $
       old_fname,                  $
       old_colors_com,             $
;    old_color, $
;    old_bckgrnd, $
;    old_font,  $
       portrait,                   $
       in_color,                   $
       print_aspect,               $
       printer_name,               $
       print_directory,            $
       print_font,                 $
       popened

