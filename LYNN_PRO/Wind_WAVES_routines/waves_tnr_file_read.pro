;+
;*****************************************************************************************
;
;  FUNCTION :   waves_tnr_file_read.pro
;  PURPOSE  :   Reads in WAVES-TNR ASCII files and returns an structure filled with
;                 data from those files, with associated background levels.
;
;  CALLED BY:   
;               waves_get_ascii_file_wrapper.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;               2)  ASCII files found at:
;                     http://www-lep.gsfc.nasa.gov/waves/data_products.html
;
;  INPUT:
;               FILES  :  [N]-Element [string] array of file names, including the full
;                           directory path, for WAVES TNR ASCII files
;
;  EXAMPLES:    
;               tnr_data = waves_tnr_file_read(files)
;
;  KEYWORDS:    
;               NA
;
;   CHANGED:  1)  Updated website location
;                                                                 [03/11/2011   v1.0.1]
;             2)  Updated man page and changed name to waves_tnr_file_read.pro
;                   and now moved to ~/wind_3dp_pros/LYNN_PRO/ directory
;                                                                 [03/21/2013   v2.0.0]
;
;   NOTES:      
;               1)  This program should NOT be called by a user, let
;                     waves_get_ascii_file_wrapper.pro call this program
;
;               ==================================================================
;               = -Documentation on WAVES TNR, RAD1&2 ASCII file documentation   =
;               =   PROVIDED BY:  Michael L. Kaiser (Michael.kaiser@nasa.gov)    =
;               ==================================================================
;
;               One minute averages of the WAVES RAD1, RAD2, and TNR receivers are
;               available. All of the files are in idl 'save' format and in ASCII
;               (compressed) and are named in the form YYYYMMDD.RCVR where RCVR is
;               R1, R2 or tnr (i.e. 19981025.R1 or R2 or tnr for RAD1, RAD2, or tnr
;               for October 25, 1998).  For RAD1, see the warning a couple of
;               paragraphs below.
;
;               For the rads, files are arrays that are 1441 X 256 -- 256 for the
;               channels (and yes I already do the interpolation for times when we're
;               in LIST mode), and 1440 for every minute of the day with position 1441
;               reserved for the background values (and there are only background
;               entries for 'real' channels -- i.e. those that the receiver actually
;               samples rather than interpolated frequencies). For the tnr I have
;               daily arrays that are 1441 X 96 (no interpolation here). All values
;               are in terms of ratio to background and the background values are
;               listed in position 1441 in microvolts per root Hz.
;
;               For RAD1 and RAD2, there are also daily dynamic spectra plotted in
;               four six-hour long strips.  These are available as pdf files (e.g.
;               RADx Adobe pdf files).  Be forewarned that for the RAD1 plots,
;               artifacts exist below about 150 kHz created by IDL and due to the
;               fact that often there is not a sample every 1 minute at these low
;               frequencies.  These artifacts appear as ‘picket fences’ in the
;               dynamic spectra.
;
;               So much for documentation. With IDL, one can 'restore' these files
;               and plot a dynamic spectrum in a matter of seconds -- I have a
;               dynamic spectrum program (xwavesds) that will plot rad or tnr
;               dynamic spectra for anything from 1 minute to 30 days. Either click
;               on the 'IDL programs' button on the WAVES Web page (left panel) or go
;               to anonymous ftp 'pub/waves1m' directory on panacea.gsfc.nasa.gov
;               and take a look at README.txt.  For those interested in the ASCII
;               form, the format used to write the files is: 1440(1x,f9.3),1e10.3
;
;  REFERENCES:  
;               1)  Bougeret, J.-L., M.L. Kaiser, P.J. Kellogg, R. Manning, K. Goetz,
;                      S.J. Monson, N. Monge, L. Friel, C.A. Meetre, C. Perche,
;                      L. Sitruk, and S. Hoang (1995) "WAVES:  The Radio and Plasma
;                      Wave Investigation on the Wind Spacecraft," Space Sci. Rev.
;                      Vol. 71, pp. 231-263, doi:10.1007/BF00751331.
;
;   CREATED:  05/11/2010
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  03/21/2013   v2.0.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION waves_tnr_file_read,files

;;----------------------------------------------------------------------------------------
;; => Define Constants and dummy variables
;;----------------------------------------------------------------------------------------
nfi            = N_ELEMENTS(files)     ;;  # of files
td             = 1441L                 ;;  # of total columns per file [ = # of timestamps]
nt             = (td - 1L)             ;;  # of timestamps
nf             = 96L                   ;;  # of total rows per file [ = # of frequencies]
nx             = nfi*nt
data_t         = FLTARR(nx,nf)         ;;  data array to be returned
bckgrd         = FLTARR(nf,nf)         ;;  Background values of data
mform          = '(1440f9.3,1e10.3)'   ;;  Read format of ASCII file
dn_el          = 0L
up_el          = 0L
;;----------------------------------------------------------------------------------------
;; => Read in file
;;----------------------------------------------------------------------------------------
FOR j=0L, nfi - 1L DO BEGIN
  nn     = FILE_LINES(files[j])  ;;  Length of any given file
  data   = FLTARR(td,nn)         ;;  Dummy array for each file
  dat0   = FLTARR(td)
  infile = files[j]
  ;;  Open file
  OPENR, gunit, infile, /GET_LUN
    ;;  Read file, row-by-row
    FOR k=0L, nn - 1L DO BEGIN
      READF,FORMAT=mform,gunit,dat0
      data[*,k] = dat0
    ENDFOR
  FREE_LUN, gunit
  ;;  Add output to return array
  ndim                         = SIZE(data,/DIMENSIONS)
  n_p_d                        = (ndim[0] - 1L)
  dn_el                        = j[0]*n_p_d[0]               ;;  lower bound for elements
  up_el                        = dn_el[0] + (n_p_d[0] - 1L)  ;;  upper " "
  n_el                         = up_el[0] - dn_el[0] + 1L
  g_tind                       = LINDGEN(n_el) + dn_el[0]
  data_t[g_tind,0L:(nn - 1L)]  = data[0L:(n_p_d[0] - 1L),*]
  bckgrd[j,0L:(nn - 1L)]       = data[n_p_d[0],*]
ENDFOR
;;----------------------------------------------------------------------------------------
;; => Return appropriate data
;;----------------------------------------------------------------------------------------
d_str          = CREATE_STRUCT('DATA',data_t,'BKG',bckgrd)

RETURN,d_str
END
