;+
;CRIB SHEET EXAMPLE
;PURPOSE:
;  A sample crib sheet that explains how to use the "TPLOT" procedure.
;
;Written by Davin Larson 96-2-19
;
;- 


;
;HINTS:
;  IF using "OpenWindows", then run IDL in an xterm window and open this
;file using textedit or similar editor.  To copy a line of text, triple 
;click on the line and then use the middle button to copy the line into 
;the IDL (xterm) window.  The same technique works with dtpad and dterm.
;
;In the following text all comment lines are preceeded by a ;  (semi-colon)
;All other lines are commands.
;
;This gives only a partial listing of the options that are available.
;

;Set up your device:
device,pseudo_color=8  ;fixes color table problem for machines with 24-bit color
;Pick a color table:
loadct,39         ;Rainbow      (I also recommend 22)



;Generate some sample data:
_get_example_dat          


;list the currently available data (just produced by _get_example_dat)
tplot_names


;Plot the quantities:
tplot, ['amp','slp','flx1','flx2']
;or alternatively:
tplot, [1,2,3,4]



;Some examples of changing plotting options:

;Limits:


ylim,'amp',3e5,3e6,1      ; set logrithmic y-limits from 3e5 to 3e6 for 'amp' 
tplot

ylim,'amp',0,0,0   ; reset to linear auto-scaling
tplot

ylim               ; Use the mouse to set the limit range
tplot


;Time limits

tplot_options,ref = '95-11-22'       ;Set the reference time

tlimit,1,3                           ;time limit from 100 UT to 300 UT

tlimit,/full                         ;full range

tlimit                 ; use cursor to select the time range

tlimit,0,0                           ;back to auto ranging.


;Multiline plots:

tplot,/nocolor     ; Turn of auto coloring on multi-line plots (for hardcopy)

options,'flx1','labflag',-1    ; set evenly spaced labels
tplot

options,'flx1','labflag',0     ; No labels
tplot

options,'flx1','labflag',1     ; Reverse order
tplot

options,'flx1','labflag',2     ; Auto spacing
tplot

bins = replicate(1,15)
bins( [3,6,9] ) = 0            ; turn off channels 3,6 and 9
options,'flx1','bins',bins     ; add bins option 
tplot

options,'flx1','bins',1        ; turn all channels on
tplot



;Spectrogram options:

zlim,'flx2',0,0,0           ; Set linear color scale
tplot

zlim,'flx2',1e3,1e4,1       ; Set limited range
tplot

zlim,'flx2',0,0             ; back to autoscaling  (min = max)
tplot

options,'flx2','y_no_interp',1   ; prevent y-axis interpolation
tplot

options,'flx2','y_no_interp',0   ; allow y-axis interpolation
tplot

options,'flx2','ystyle',1     ; force exact yaxis limits
tplot

options,'flx2','spec',0       ; change to multi-line plot:
tplot

options,'flx2','spec',1       ; back to spectragram
tplot





;Setting global options:   (these will affect the entire plot)

tplot_options,'title','My very own plot'
tplot


tplot_options,'region',[0.,.5,1.,1.]   ; use top half of screen only
tplot

tplot_options,'region'                 ; remove region keyword (full screen)
tplot

tplot_options,'xmargin' ,[15,10]         ; change default xmargin
tplot

tplot_options,'ymargin' ,[6,3]          ; change default ymargin
tplot

tplot_options,'charsize',.5             ; change default character size
tplot


;Adding extra labels at the bottom:
;Any tplot (scaler) variable can also be printed at the bottom, below 
;the time labels.

tplot,var_label=['alt']

options,'alt','ytitle','Alt (km)'       ; Change the label
options,'alt','format','(f8.0)'         ; Change the printing format
tplot






;Adding user defined plotting routines:  (BITPLOT)

;When viewing instrument housekeeping data, it is often useful to view individual
;bits.  The routine BITPLOT will do this, and can be incorporated into TPLOT.

tplot,['slp','hkp_dat']  ;
;Here bits 0-6 are counter bits, bit 7 is a threshold indicator for 'slp'

This can be plotted in normal fashion:
options,'hkp_dat','tplot_routine','mplot'
tplot

Or in BITPLOT mode:
options,'hkp_dat','tplot_routine','bitplot'
tplot







;Miscellaneous:

tplot,mix=[4,1,2]   ;Mix the panel order,  plot the 4th, then 1st, then 2nd

tplot,/pick         ;Use the cursor to pick panels

options,'flx2','panel_size',1.   ;make the spectrogram panel normal size
tplot

time_stamp,/off     ;Turn of the time_stamp
tplot

time_stamp,/on      ;Turn it on again
tplot



;Example of getting to the data and creating new data:

;Suppose one wishs to view the spectral data with the steep slope factored
;out.  The following example shows how this might be done:

tplot,'flx2'                                        ;display the data

get_data,'flx2',data=dat  ,alim=lim                 ; get the data, and limits
help,dat,lim,/st                                        
flux = dat.y                                        ; create flux variable
avg  = total(flux,1,/nan) / total(finite(flux),1)   ; average over dimension 1
n = dimen1(flux)                                    ; determine 1st dimension
avg  = replicate(1.,n) # avg
help,flux,avg,n                                     ; help
flux = flux / avg                                   ; divide by average
dat.y = flux                                        ; replace old data
lim.ztitle= 'New Data'                              ; change the title

store_data,'ndat',data=dat  ,dlim=lim               ; store the data for TPLOT

tplot_names                                         ; Verify it is really there

tplot,'ndat',/add                                   ; 



;Good Luck
