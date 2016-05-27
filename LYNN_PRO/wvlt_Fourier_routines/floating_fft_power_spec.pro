;+
;*****************************************************************************************
;
;  FUNCTION :   floating_fft_power_spec.pro
;  PURPOSE  :   Calculates the floating FFT of an input signal and returns a structure
;                 containing the dynamic power spectrum.  The calculation assumes a
;                 half overlap of the floating FFT windows.
;
;  CALLED BY:   
;               fft_window_spec.pro
;
;  CALLS:
;               fft_power_calc.pro
;
;  REQUIRES:  
;               NA
;
;  INPUT:
;               TT  :  Time (s) associated with EE
;               EE  :  N-Element array of data to be used for floating FFT
;               WX  :  Fractional Width of the window to use for floating FFT
;                        window (try to make this so that the resulting window
;                        has 2^N elements, where N is an integer)
;
;  EXAMPLES:
;               NA
;
;  KEYWORDS:  
;               NA
;
;   CHANGED:  1)  Fixed array size/element issue for TPLOT        [09/27/2008   v1.0.1]
;             2)  Eliminated fft_power_calc.pro dependence        [10/07/2008   v1.1.0]
;             3)  Changed freq. bin # calculation                 [10/16/2008   v1.1.1]
;             4)  Changed windowf.pro to my_windowf.pro           [10/16/2008   v1.1.2]
;             5)  Changed floating FFT window width calc          [10/27/2008   v1.2.0]
;             6)  Fixed some syntax errors                        [11/02/2008   v1.2.1]
;             7)  Changed floating FFT window calc                [11/02/2008   v1.3.0]
;             8)  Fixed an indexing issue                         [11/03/2008   v1.3.1]
;             9)  Re-wrote program                                [04/06/2009   v2.0.0]
;            10)  Renamed from my_float_fft_spec.pro              [09/10/2009   v3.0.0]
;            11)  Added generalized forced number of points to compute in FFT
;                                                                 [09/14/2009   v3.0.1]
;
;   CREATED:  09/25/2008
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  09/14/2009   v3.0.1
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION floating_fft_power_spec,tt,ee,wx

;*****************************************************************************************
ex_start = SYSTIME(1)
;*****************************************************************************************
;-----------------------------------------------------------------------------------------
; => Create Dummy Variables
;-----------------------------------------------------------------------------------------
tx  = REFORM(tt)
ex  = REFORM(ee)
wid = DOUBLE(REFORM(wx))
nn  = N_ELEMENTS(tx)
d   = !VALUES.D_NAN
f   = !VALUES.F_NAN
ll  = -170d0                        ; -Background estimate (dB)
pow = REPLICATE(d,10L,10L)          ; -Dummy power array
frq = REPLICATE(d,10L,10L)          ; -Dummy frequency array
t_c = REPLICATE(d,10L)              ; -Dummy time array for freq. and power
dum = CREATE_STRUCT('TIME',t_c,'FREQ',frq,'POWER',pow)

nntest = [(nn GE 256L),(nn GE 512L),(nn GE 1024L),(nn GE 2048L),(nn GE 4096L),$
          (nn GE 8192L),(nn GE 16384L),(nn GE 32768L),(nn GE 65536L),         $
          (nn GE 131072L)] GT 0
gntest = WHERE(nntest,gnt)
CASE gnt OF
  3L   : BEGIN     ; => (nn GE 1024L)
    focn = 1024L*2*wx
  END
  4L   : BEGIN     ; => (nn GE 2048L)
    focn = 2048L*2*wx
  END
  5L   : BEGIN     ; => (nn GE 4096L)
    focn = 4096L*2*wx
  END
  6L   : BEGIN     ; => (nn GE 8192L)
    focn = 8192L*2*wx
  END
  7L   : BEGIN     ; => (nn GE 16384L)
    focn = 16384L*2*wx
  END
  8L   : BEGIN     ; => (nn GE 32768L)
    focn = 32768L*2*wx
  END
  9L   : BEGIN     ; => (nn GE 65536L)
    focn = 65536L*2*wx
  END
  10L  : BEGIN     ; => (nn GE 131072L)
    focn = 131072L*2*wx
  END
  ELSE : BEGIN
    MESSAGE,'There are either too few or too many points...',/INFORMATIONAL,/CONTINUE
    RETURN,dum
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; -Determine some relevant parameters
;-----------------------------------------------------------------------------------------
evl = MAX(tx,/NAN) - MIN(tx,/NAN)  ; -Event Length (s)
sr  = (nn - 1L)/evl                ; -Average sample rate of data
fr  = LINDGEN(nn/2L)*(sr/(nn-1L))  ; -Freq. Bins for FFT power spec.
;-----------------------------------------------------------------------------------------
; -Determine floating FFT window width based upon total time input of data
;-----------------------------------------------------------------------------------------
wd    = wid[0]                         ; -Fractional size of FFT window
gwin  = 1
nt    = nn
q_e   = evl*wd                         ; -Fractional size of FFT window (s)
s_w   = q_e/2d0                        ; -Lower bound on FFT window (s)
e_w   = ABS(evl - s_w)                 ; -Upper bound on FFT window (s)
b_wt  = q_e                            ; -Size of Bounding FFT window (s)
b_sam = ROUND(b_wt*sr)                 ; -Samples/bounding window
olaps = ROUND(b_sam*1d0 - b_sam*5d-1)  ; -# of Samples/Overlap
s_sam = ROUND(s_w*sr)                  ; -Samples at start window point
e_sam = ROUND(e_w*sr)                  ; -Samples at end window point
;-----------------------------------------------------------------------------------------
; -Determine # of floating FFT windows being used
;-----------------------------------------------------------------------------------------
y     = s_sam
cc    = 1       ; => # of FFT Windows
gel   = 1       ; => Dummy Logic Variable
WHILE(gel) DO BEGIN
  y  += olaps
  IF (y + olaps LT e_sam) THEN gel = 1 ELSE gel = 0
  IF (gel) THEN cc += 1L
ENDWHILE
width = wd
t_els = LINDGEN(cc)*(olaps) + b_sam/2L ; -Elements of time series at center of window
t_c   = DBLARR(cc+2L)                  ; -Times at center of windows
t_c[0]     = tx[0]
t_c[cc+1L] = tx[nt-1L]
t_c[1L:cc] = tx[t_els]
;-----------------------------------------------------------------------------------------
; -Need to redefine frequencies
;-----------------------------------------------------------------------------------------
test  = fft_power_calc(t_c,ee[0L:(cc+1L)],/READ_WIN,FORCE_N=focn,SAMP_RA=sr)

gdt     = N_ELEMENTS(t_c)
myfreqs = N_ELEMENTS(test.FREQ)
tevl    = (tx[b_sam-1L] - tx[0])
tsr     = (b_sam - 1L)/tevl
nfr     = test.FREQ
;-----------------------------------------------------------------------------------------
; -Calculate power spectrum
;-----------------------------------------------------------------------------------------
power_spec = MAKE_ARRAY(gdt,myfreqs,/DOUBLE)
freq_spec  = MAKE_ARRAY(gdt,myfreqs,/DOUBLE)
power_spec[0,*]      = d
power_spec[gdt-1L,*] = d
freq_spec[0,*]       = nfr
freq_spec[gdt-1L,*]  = nfr
gel   = 1       ; => Dummy Logic Variable
j     = 0L
WHILE(gel) DO BEGIN
  gtim = WHERE(tx GE t_c[j]-b_wt/2d0 AND tx LE t_c[j]+b_wt/2d0,gti)
  IF (gti GT 0L) THEN BEGIN
    telv   = MAX(tx[gtim],/NAN) - MIN(tx[gtim],/NAN)  ; -Window width (s)
    test   = fft_power_calc(tx[gtim],ex[gtim],/READ_WIN,FORCE_N=focn,SAMP_RA=sr)
    npower = N_ELEMENTS(test.FREQ)
    nfreq  = npower
    power_spec[j,0:(npower-1L)] = test.POWER_A  ; => [dB (mV/m)^2/Hz]
    freq_spec[j,0:(nfreq-1L)]   = test.FREQ
  ENDIF ELSE BEGIN
    power_spec[j,*] = d
    freq_spec[j,*]  = nfr
  ENDELSE
  IF (j LT gdt - 1L) THEN gel = 1 ELSE gel = 0
  IF (gel) THEN j += 1L
ENDWHILE
;-----------------------------------------------------------------------------------------
; -Eliminate zeros to avoid infinite plot range errors
;-----------------------------------------------------------------------------------------
bdpow = WHERE(power_spec EQ 0d0,bdp)
IF (bdp GT 0L) THEN BEGIN
  pind = ARRAY_INDICES(power_spec,bdpow)
  power_spec[pind[0,*],pind[1,*]] = d
ENDIF
f_str = CREATE_STRUCT('TIME',t_c,'FREQ',freq_spec,'POWER',power_spec)
;*****************************************************************************************
ex_time = SYSTIME(1) - ex_start
MESSAGE,STRING(ex_time)+' seconds execution time.',/INFORMATIONAL,/CONTINUE
;*****************************************************************************************
RETURN,f_str
END
