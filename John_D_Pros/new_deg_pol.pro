;+
; NAME:deg_pol 
;
;PURPOSE:To perform polarisation analysis of three orthogonal component time
;         series data.
;
;CALLING SEQUENCE: deg_pol,quanx,quany,quanz,start,totpoints,rotatefield 
;
;
; 
;INPUTS: quanx,quany,quanz:- are the data quantity descriptors (DQDs) of
;        the time series data which must be currently loaded in SDT, 
;        eg 'Mag1ac_S','Mag2ac_S','Mag3ac_S'
;                            OR they are arrays of equal length in IDL         
;        
;        start:- is the start time for the interval to be analysed. If
;        using SDT DQDS this must be given in the format
;        '1996-09-23/16:54:29.20'.If using arrays from inside IDL then
;        you can set this to whatever you like since it is reset to
;        zero anyway.The Start time for all three time series is the same. 
;
;        totpoints:-is the total number of points in the time series
;        to be analysed. Maximum values are set by the maximum array
;        size in IDL and the total time for computation. Maximum values of
;        30000-40000 seem to be reasonable  
;
;        rotatefield:-if set greater than 0.0 deg_pol will iteratively call
;        the subroutine fieldrot to rotate the given time series into a
;        righthanded fieldaligned coordinate system with Z pointing the
;        direction of the ambient magnetic field(see documentation on fieldrot)
;        before performing the
;        polarisation analysis. This option requires that the DQDs 
;       'Mag1dc_S','Mag2dc_S','Mag3dc_S' are currently loaded in
;        SDT and that  quanx,quany,quanz are defined in the same coord
;        system as  'Mag1dc_S','Mag2dc_S','Mag3dc_S'. If the sampling
;        frequency of the dc field data is not the same as the ac data
;        and is less than 32 Hz then the dc and ac data should be
;        despun before running deg_pol. If using arrays from inside
;        IDL setting fieldrot is not invoked.  
;
;
;OUTPUTS: The program outputs five spectral results derived from the
;         fourier transform of the covariance matrix (spectral matrix)
;         and plots each using TPLOT. These are
;         follows:

;         Wave power: On a linear scale, at this stage no units
;         
;         Degree of Polarization: This is similar to a measure of coherency
;                                 between the input
;                                 signals, however unlike coherency it is
;                                 invariant under
;                                 coordinate transformation and can detect pure
;                                 state waves
;                                 which may exist in one channel only.  100%
;                                 indicates a pure
;                                 state wave. Less than 70% indicates noise.
;                                 For more
;                                 information see J. C. Samson and J. V. Olson
;                                 'Some comments
;                                 on the description of the polarization states
;                                 of waves'
;                                 Geophys. J. R. Astr. Soc. (1980) v61 115-130
;
;
;
;         Wavenormal Angle: the angle between the direction of minimum
;                           variance calculated from the complex off diagonal
;                           elements of the spectral matrix and the Z direction
;                           of the input
;                           ac field data. For magnetic field data in
;                           field aligned coordinates this is the
;                           wavenormal angle assuming a plane wave.
;          
;          
;         Ellipticity:The ratio (minor axis)/(major axis) of the
;                     ellipse transcribed by the field variations in the
;                     components transverse to the Z direction. The sign of
;                     indicates the direction of rotation of the field vector in
;                     the plane. Negative signs refer to left-handed
;                     rotation about the Z direction. In the field
;                     aligned coordinate system these signs refer to
;                     plasma waves of left and right handed
;                     polarisation.
; 
;         Helicity:Similar to Ellipticity except defined in terms of the 
;                  direction of minimum variance instead of Z. Stricltly the
;                  Helicity 
;                  is defined in terms of the wavenormal direction or k. 
;                  However since from single point observations the 
;                  sense of k cannot be determined,  helicity here is 
;                  simply the ratio of the minor to major axis transverse to the
;                  minimum variance direction without sign.     
;                                            
;
;RESTRICTIONS:-If one component is an order of magnitude or more  greater than
;             the other two then the polarisation results saturate and
;             erroneously
;             indicate high degrees of polarisation at all times and
;             frequencies. Time series should be eyeballed before running the
;             program. 
;             -For time series containing very rapid changes or spikes
;             the usual problems with Fourier analysis arise.
;             -Care should be taken in evaluating degree of polarisation
;             results. For a
;             meaningful results there should be significant wave power at the
;             frequency where the polarisation approaches
;             100%. Remembercomparing two straight lines yields 100%
;             polarisation. 
;
;
; EXAMPLE:deg_pol, 'Mag1ac_S','Mag2ac_S','Mag3ac_S', '1996-09-23/16:54:29.20',20000,1,'psprnfile' 
;
;
;
; MODIFICATION HISTORY:Written By Chris Chaston, 30-10-96
;                      Modified by Kris Sigsbee before I got it to work with
;                         Polar data, John Dombeck 9/28/98
;                      Further modified to work with despun Polar data and
;                         made it readable in 80 columns,
;                         John Dombeck, 10/19/98
;
;-
pro new_deg_pol,quanx,quany,quanz,start,totpoints,rotatefield,pol_lmt,pow_lmt,  $
            pow_lmt_typ,corse,sampfreq,outps,npts=npts,ylmt=ylmt
nopoints=totpoints

;;if not keyword_set(ylmt) then ylmt=4000
if not keyword_set(ylmt) then ylmt=fix(sampfreq)/2
if n_elements(npts) eq 0 then nopfft=128 else nopfft=npts ;no. of points in FFT
steplength = nopfft/2                           ; Overlap between sucessive FFT bins
nosteps=(nopoints-nopfft)/steplength            ;total number of FFTs 
leveltplot=0.0025                                ;power rejection level 0 to 1
lam=dblarr(2)
nosmbins=7                                      ;No. of bins in frequency domain
;!p.charsize=2                                  ;to include in smoothing
                                                ; (must be odd)
aa=[0.024,0.093,0.232,0.301,0.232,0.093,0.024]  ;smoothing profile based on
                                                ; Hanning

;ARRAY DEFINITIONS

fields=make_array(3, nopoints,/double)
power=Make_Array(nosteps,nopfft/2)
specx=Make_Array(nosteps,nopfft,/dcomplex)
specy=Make_Array(nosteps,nopfft,/dcomplex)
specz=Make_Array(nosteps,nopfft,/dcomplex)
wnx=DBLARR(nosteps,nopfft/2)
wny=DBLARR(nosteps,nopfft/2)
wnz=DBLARR(nosteps,nopfft/2)
vecspec=Make_Array(nosteps,nopfft/2,3,/dcomplex)
matspec=Make_Array(nosteps,nopfft/2,3,3,/dcomplex)
ematspec=Make_Array(nosteps,nopfft/2,3,3,/dcomplex)
matsqrd=Make_Array(nosteps,nopfft/2,3,3,/dcomplex)
matsqrd1=Make_Array(nosteps,nopfft/2,3,3,/dcomplex)
trmatspec=Make_Array(nosteps,nopfft/2,/double)
powspec=Make_Array(nosteps,nopfft/2,/double)
trmatsqrd=Make_Array(nosteps,nopfft/2,/double)
degpol=Make_Array(nosteps,nopfft/2,/double)
alpha=Make_Array(nosteps,nopfft/2,/double)
alphasin2=Make_Array(nosteps,nopfft/2,/double)
alphacos2=Make_Array(nosteps,nopfft/2,/double)
alphasin3=Make_Array(nosteps,nopfft/2,/double)
alphacos3=Make_Array(nosteps,nopfft/2,/double)
alphax=Make_Array(nosteps,nopfft/2,/double)
alphasin2x=Make_Array(nosteps,nopfft/2,/double)
alphacos2x=Make_Array(nosteps,nopfft/2,/double)
alphasin3x=Make_Array(nosteps,nopfft/2,/double)
alphacos3x=Make_Array(nosteps,nopfft/2,/double)
alphay=Make_Array(nosteps,nopfft/2,/double)
alphasin2y=Make_Array(nosteps,nopfft/2,/double)
alphacos2y=Make_Array(nosteps,nopfft/2,/double)
alphasin3y=Make_Array(nosteps,nopfft/2,/double)
alphacos3y=Make_Array(nosteps,nopfft/2,/double)
alphaz=Make_Array(nosteps,nopfft/2,/double)
alphasin2z=Make_Array(nosteps,nopfft/2,/double)
alphacos2z=Make_Array(nosteps,nopfft/2,/double)
alphasin3z=Make_Array(nosteps,nopfft/2,/double)
alphacos3z=Make_Array(nosteps,nopfft/2,/double)
gamma=Make_Array(nosteps,nopfft/2,/double)
gammarot=Make_Array(nosteps,nopfft/2,/double)
upper=Make_Array(nosteps,nopfft/2,/double)
lower=Make_Array(nosteps,nopfft/2,/double)
lambdau=Make_Array(nosteps,nopfft/2,3,3,/dcomplex)
lambdaurot=Make_Array(nosteps,nopfft/2,2,/dcomplex)
thetarot=Make_Array(nopfft/2,/double)
thetax=DBLARR(nosteps,nopfft)
thetay=DBLARR(nosteps,nopfft)
thetaz=DBLARR(nosteps,nopfft)
aaa2=DBLARR(nosteps,nopfft/2)
helicity=Make_Array(nosteps,nopfft/2,3)
ellip=Make_Array(nosteps,nopfft/2,3)
WAVEANGLE=Make_Array(nosteps,nopfft/2)
halfspecx=Make_Array(nosteps,nopfft/2,/dcomplex)
halfspecy=Make_Array(nosteps,nopfft/2,/dcomplex)
halfspecz=Make_Array(nosteps,nopfft/2,/dcomplex)

;GET TIME SERIES

if (idl_type([quanx,quany,quanz]) eq 'string') then begin  
    
   xmag=get_fa_fields(quanx, start, NPTS=totpoints)
   ymag=get_fa_fields(quany, start, NPTS=totpoints)
   zmag=get_fa_fields(quanz, start, NPTS=totpoints)

   sampfreq=1/(xmag.time(1)-xmag.time(0))
   endsampfreq=1/(xmag.time(totpoints-1)-xmag.time(totpoints-2))
   print,' '
   if sampfreq NE endsampfreq then print,'Warning ac file sampling ' + $
  'frequency changes',sampfreq,'Hz to',endsampfreq,'Hz' else print,'ac ' + $
  'file sampling frequency',sampfreq,'Hz' 

;ROTATION TO FIELD ALIGNED COORDINATES

   if (rotatefield GT 0.0) then begin
   print,'rotating to field aligned coords'
   xdmag=get_fa_fields('Mag1dc_S', start, NPTS=2,/calibrate)

   sampfreqdc=1/(xdmag.time(1)-xdmag.time(0))
   dcpoints=abs(totpoints*(sampfreqdc/sampfreq))+1
   print, dcpoints
    xdmag=get_fa_fields('Mag1dc_S', start, NPTS=dcpoints,/calibrate)
    ydmag=get_fa_fields('Mag2dc_S', start, NPTS=dcpoints,/calibrate)
    zdmag=get_fa_fields('Mag3dc_S', start, NPTS=dcpoints,/calibrate)
    countdc=0
    endfreqdc=1/(xdmag.time(dcpoints-1)-xdmag.time(dcpoints-2))
    print,' '
    if sampfreqdc NE endfreqdc then print,'Warning dc file sampling ' + $
    'frequency changes',sampfreqdc,'Hz to',endfreqdc,'Hz' else print,'dc ' + $
    'file sampling frequency', sampfreqdc,'Hz'
     for j=0L,totpoints-1 DO BEGIN
     if                                                     $
      (ABS(j/(sampfreq/sampfreqdc)-round(j/(sampfreq/sampfreqdc)))) LT 0.00001 $
      then begin
    
       dcx=xdmag.comp1(countdc)
       dcy=ydmag.comp1(countdc)
       dcz=zdmag.comp1(countdc)
       countdc=countdc+1
      ;print, countdc
     endif    
   fields(*,j)=fieldrot(dcx,-dcy,dcz,xmag.comp1(j)*cos(21/180*!DPI),     $
              -ymag.comp1(j),xmag.comp1(j)*sin(21/180*!DPI)+zmag.comp1(j))
  endfor

;SET TIME SERIES TO BE ANALYSED

   xs=fields(0,*)
   ys=fields(1,*)
   zs=fields(2,*)

  endif else begin
    
  xs=xmag.comp1
  ys=ymag.comp1
  zs=zmag.comp1    
    
  endelse

endif else begin                                        ;direct array entry 
    
    xs=quanx
    ys=quany
    zs=quanz
;   Read, sampfreq, Prompt='Enter sampling frequency (Hz) '
;   start=0
    totpoints = n_elements(xs)
    if (n_elements(ys) ne totpoints) or $
       (n_elements(zs) ne totpoints) then begin
      message,'All arrays must be same size!',/continue
      return
   endif
   if (totpoints gt 20000) then begin
      message,'Wow, that''s a lot of points! I hope you''re not in a hurry!', $
              /continue
   endif
endelse 

;PLOT TIME SERIES ON WHICH POLARIZATION ANALYSIS IS PERFORMED

window, 0, xsize=800, ysize=900
;; !p.multi=[0,1,3]    
;; plot,xs
;; plot,ys
;; plot,zs
;; !p.multi=[0,1,1]    


; xdmag=get_fa_fields('MagDC', start, NPTS=2,/calibrate)

;   sampfreqdc=1/(xdmag.time(1)-xdmag.time(0))
;   points=totpoints

;   dcpoints=abs(points*(sampfreqdc/sampfreq))+1
;   print, dcpoints
;    totmag=get_fa_fields('MagDC',start,NPTS=dcpoints,/calibrate)


;GET ORBIT DATA
;endtime=time_to_str(str_to_time(start)+totpoints/sampfreq)
;print, start
;print, endtime
;get_fa_orbit,start,endtime,/all,delta_t=0.01
;get_data,'ALT',data=altitude
;get_data,'ILAT',data=ilatitude
;get_data,'B_model',data=bfield
;totdfield=Sqrt(totmag.comp1^2+totmag.comp2^2+totmag.comp3^2)
;cycdfreq=(1.6e-19*totdfield*1e-9)/(2*!DPI*1.67e-27)
;totfield=Sqrt(bfield.y(*,0)^2+bfield.y(*,1)^2+bfield.y(*,2)^2)
;cycfreq=(1.6e-19*totfield*1e-9)/(2*!DPI*1.67e-27)

;store_data,'CYC',data={x:totmag.time,y:cycdfreq}
;RANDOM TIME SERIES GENERATION

A=1
B=1
C=1

phix=0
phiy=0.25*3.14151
phiz=3.14151/2

;xs=10*(randomu(seed,nopoints)-0.5)                                        $
;  +0*sin(findgen(nopoints)*!DPI/5+phix)*exp(-((findgen(nopoints)-4500)^2) $
;  /(32000000))                                                            $
;  +A*sin(findgen(nopoints)*!DPI/10)*exp(-((findgen(nopoints)-4500)^2)     $
;  /(32000000))
;ys=10*(randomu(seed,nopoints)-0.5)                                        $
;  +*sin(findgen(nopoints)*!DPI/5+phiy)*exp(-((findgen(nopoints)-4500)^2)  $
;  /(32000000))                                                            $
;  +B*sin(findgen(nopoints)*!DPI/10+!DPi/2)*exp(-((findgen(nopoints)-4500)^2) $
;  /(32000000))
;zs=10*(randomu(seed,nopoints)-0.5)                                        $
;  +C*sin(findgen(nopoints)*!DPI/5+phiz)*exp(-((findgen(nopoints)-4500)^2) $
;  /(32000000))                                                            $
; ;+1.0*sin(findgen(nopoints)*!DPI/5+!DPi/2)*exp(-((findgen(nopoints)-4500)^2) $
;  /(32000000))

;MAIN BODY
print,' '
print, 'Total number of steps',nosteps
print,' '
for j=0,(nosteps-1) do begin
if (j mod 100) eq 0 then print,'Step',j

;FFT CALCULATION

     smooth=0.08+0.46*(1-cos(2*!DPI*findgen(nopfft)/nopfft))    
     tempx=smooth*xs(0:nopfft-1)
     tempy=smooth*ys(0:nopfft-1)
     tempz=smooth*zs(0:nopfft-1)		
     specx(j,*)=(fft(tempx,/double));+Complex(0,j*steplength*3.1415/32))
     specy(j,*)=(fft(tempy,/double));+Complex(0,j*steplength*3.1415/32))
     specz(j,*)=(fft(tempz,/double));+Complex(0,j*steplength*3.1415/32))
     halfspecx(j,*)=specx(j,0:(nopfft/2-1))
     halfspecy(j,*)=specy(j,0:(nopfft/2-1))
     halfspecz(j,*)=specz(j,0:(nopfft/2-1))
     xs=shift(xs,-steplength)
     ys=shift(ys,-steplength)
     zs=shift(zs,-steplength)
     
;CALCULATION OF THE SPECTRAL MATRIX
     
    matspec(j,*,0,0)=halfspecx(j,*)*conj(halfspecx(j,*))
    matspec(j,*,1,0)=halfspecx(j,*)*conj(halfspecy(j,*))
    matspec(j,*,2,0)=halfspecx(j,*)*conj(halfspecz(j,*))
    matspec(j,*,0,1)=halfspecy(j,*)*conj(halfspecx(j,*))
    matspec(j,*,1,1)=halfspecy(j,*)*conj(halfspecy(j,*))
    matspec(j,*,2,1)=halfspecy(j,*)*conj(halfspecz(j,*))
    matspec(j,*,0,2)=halfspecz(j,*)*conj(halfspecx(j,*))
    matspec(j,*,1,2)=halfspecz(j,*)*conj(halfspecy(j,*))
    matspec(j,*,2,2)=halfspecz(j,*)*conj(halfspecz(j,*))

;CALCULATION OF SMOOTHED SPECTRAL MATRIX
    
     for k=(nosmbins-1)/2, (nopfft/2-1)-(nosmbins-1)/2 do begin
          ematspec(j,k,0,0)=TOTAL(aa(0:(nosmbins-1))                  $
                         *matspec(j,(k-(nosmbins-1)/2):(k+(nosmbins-1)/2),0,0))
          ematspec(j,k,1,0)=TOTAL(aa(0:(nosmbins-1))                  $
                         *matspec(j,(k-(nosmbins-1)/2):(k+(nosmbins-1)/2),1,0))
          ematspec(j,k,2,0)=TOTAL(aa(0:(nosmbins-1))                  $
                         *matspec(j,(k-(nosmbins-1)/2):(k+(nosmbins-1)/2),2,0))
          ematspec(j,k,0,1)=TOTAL(aa(0:(nosmbins-1))                  $
                         *matspec(j,(k-(nosmbins-1)/2):(k+(nosmbins-1)/2),0,1))
          ematspec(j,k,1,1)=TOTAL(aa(0:(nosmbins-1))                  $
                         *matspec(j,(k-(nosmbins-1)/2):(k+(nosmbins-1)/2),1,1))
          ematspec(j,k,2,1)=TOTAL(aa(0:(nosmbins-1))                  $
                         *matspec(j,(k-(nosmbins-1)/2):(k+(nosmbins-1)/2),2,1))
          ematspec(j,k,0,2)=TOTAL(aa(0:(nosmbins-1))                  $
                         *matspec(j,(k-(nosmbins-1)/2):(k+(nosmbins-1)/2),0,2))
          ematspec(j,k,1,2)=TOTAL(aa(0:(nosmbins-1))                  $
                         *matspec(j,(k-(nosmbins-1)/2):(k+(nosmbins-1)/2),1,2))
          ematspec(j,k,2,2)=TOTAL(aa(0:(nosmbins-1))                  $
                         *matspec(j,(k-(nosmbins-1)/2):(k+(nosmbins-1)/2),2,2))
      endfor


;CALCULATION OF THE MINIMUM VARIANCE DIRECTION AND WAVENORMAL ANGLE
      
     aaa2(j,*)=SQRT(IMAGINARY(ematspec(j,*,0,1))^2                  $
              +IMAGINARY(ematspec(j,*,0,2))^2+IMAGINARY(ematspec(j,*,1,2))^2)
     wnx(j,*)=ABS(IMAGINARY(ematspec(j,*,1,2))/aaa2(j,*))
     wny(j,*)=-ABS(IMAGINARY(ematspec(j,*,0,2))/aaa2(j,*))
     wnz(j,*)=IMAGINARY(ematspec(j,*,0,1))/aaa2(j,*)
     WAVEANGLE(j,*)=ATAN(Sqrt(wnx(j,*)^2+wny(j,*)^2),abs(wnz(j,*)))

;CALCULATION OF THE DEGREE OF POLARIZATION
     
;calc of square of smoothed spec matrix
     matsqrd(j,*,0,0)=ematspec(j,*,0,0)*ematspec(j,*,0,0)           $
      +ematspec(j,*,0,1)*ematspec(j,*,1,0)+ematspec(j,*,0,2)*ematspec(j,*,2,0)
     matsqrd(j,*,0,1)=ematspec(j,*,0,0)*ematspec(j,*,0,1)           $
      +ematspec(j,*,0,1)*ematspec(j,*,1,1)+ematspec(j,*,0,2)*ematspec(j,*,2,1)
     matsqrd(j,*,0,2)=ematspec(j,*,0,0)*ematspec(j,*,0,2)           $
      +ematspec(j,*,0,1)*ematspec(j,*,1,2)+ematspec(j,*,0,2)*ematspec(j,*,2,2)
     matsqrd(j,*,1,0)=ematspec(j,*,1,0)*ematspec(j,*,0,0)           $
      +ematspec(j,*,1,1)*ematspec(j,*,1,0)+ematspec(j,*,1,2)*ematspec(j,*,2,0)
     matsqrd(j,*,1,1)=ematspec(j,*,1,0)*ematspec(j,*,0,1)           $
      +ematspec(j,*,1,1)*ematspec(j,*,1,1)+ematspec(j,*,1,2)*ematspec(j,*,2,1)
     matsqrd(j,*,1,2)=ematspec(j,*,1,0)*ematspec(j,*,0,2)           $
      +ematspec(j,*,1,1)*ematspec(j,*,1,2)+ematspec(j,*,1,2)*ematspec(j,*,2,2)
     matsqrd(j,*,2,0)=ematspec(j,*,2,0)*ematspec(j,*,0,0)           $
      +ematspec(j,*,2,1)*ematspec(j,*,1,0)+ematspec(j,*,2,2)*ematspec(j,*,2,0)
     matsqrd(j,*,2,1)=ematspec(j,*,2,0)*ematspec(j,*,0,1)           $
      +ematspec(j,*,2,1)*ematspec(j,*,1,1)+ematspec(j,*,2,2)*ematspec(j,*,2,1)
     matsqrd(j,*,2,2)=ematspec(j,*,2,0)*ematspec(j,*,0,2)           $
      +ematspec(j,*,2,1)*ematspec(j,*,1,2)+ematspec(j,*,2,2)*ematspec(j,*,2,2)

     Trmatsqrd(j,*)=matsqrd(j,*,0,0)+matsqrd(j,*,1,1)+matsqrd(j,*,2,2)
     Trmatspec(j,*)=ematspec(j,*,0,0)+ematspec(j,*,1,1)+ematspec(j,*,2,2)
       degpol(j,(nosmbins-1)/2:(nopfft/2-1)-(nosmbins-1)/2)     $
         =(3*Trmatsqrd(j,(nosmbins-1)/2:(nopfft/2-1)            $
         -(nosmbins-1)/2)-Trmatspec(j,(nosmbins-1)/2:           $
          (nopfft/2-1)-(nosmbins-1)/2)^2)/(2*Trmatspec(j,(nosmbins-1)/2: $
          (nopfft/2-1)-(nosmbins-1)/2)^2)
     
   
     
;CALCULATION OF HELICITY, ELLIPTICITY AND THE WAVE STATE VECTOR	

alphax(j,*)=Sqrt(ematspec(j,*,0,0))
alphacos2x(j,*)=Double(ematspec(j,*,0,1))/Sqrt(ematspec(j,*,0,0))
alphasin2x(j,*)=-Imaginary(ematspec(j,*,0,1))/Sqrt(ematspec(j,*,0,0))
alphacos3x(j,*)=Double(ematspec(j,*,0,2))/Sqrt(ematspec(j,*,0,0))
alphasin3x(j,*)=-Imaginary(ematspec(j,*,0,2))/Sqrt(ematspec(j,*,0,0))
lambdau(j,*,0,0)=alphax(j,*)
lambdau(j,*,0,1)=Complex(alphacos2x(j,*),alphasin2x(j,*))
lambdau(j,*,0,2)=Complex(alphacos3x(j,*),alphasin3x(j,*))

alphay(j,*)=Sqrt(ematspec(j,*,1,1))
alphacos2y(j,*)=Double(ematspec(j,*,1,0))/Sqrt(ematspec(j,*,1,1))
alphasin2y(j,*)=-Imaginary(ematspec(j,*,1,0))/Sqrt(ematspec(j,*,1,1))
alphacos3y(j,*)=Double(ematspec(j,*,1,2))/Sqrt(ematspec(j,*,1,1))
alphasin3y(j,*)=-Imaginary(ematspec(j,*,1,2))/Sqrt(ematspec(j,*,1,1))
lambdau(j,*,1,0)=alphay(j,*)
lambdau(j,*,1,1)=Complex(alphacos2y(j,*),alphasin2y(j,*))
lambdau(j,*,1,2)=Complex(alphacos3y(j,*),alphasin3y(j,*))

alphaz(j,*)=Sqrt(ematspec(j,*,2,2))
alphacos2z(j,*)=Double(ematspec(j,*,2,0))/Sqrt(ematspec(j,*,2,2))
alphasin2z(j,*)=-Imaginary(ematspec(j,*,2,0))/Sqrt(ematspec(j,*,2,2))
alphacos3z(j,*)=Double(ematspec(j,*,2,1))/Sqrt(ematspec(j,*,2,2))
alphasin3z(j,*)=-Imaginary(ematspec(j,*,2,1))/Sqrt(ematspec(j,*,2,2))
lambdau(j,*,2,0)=alphaz(j,*)
lambdau(j,*,2,1)=Complex(alphacos2z(j,*),alphasin2z(j,*))
lambdau(j,*,2,2)=Complex(alphacos3z(j,*),alphasin3z(j,*))

;HELICITY CALCULATION

for k=0, nopfft/2-1 do begin
    for xyz=0,2 do begin
        upper(j,k)=Total(2*double(lambdau(j,k,xyz,0:2))       $
                  *(Imaginary(lambdau(j,k,xyz,0:2))))
        lower(j,k)=Total((Double(lambdau(j,k,xyz,0:2)))^2     $
                  -(Imaginary(lambdau(j,k,xyz,0:2)))^2)
        if (upper(j,k) GT 0.00) then gamma(j,k)=ATAN(upper(j,k),lower(j,k)) $
        else gamma(j,k)=!DPI+(!DPI+ATAN(upper(j,k),lower(j,k)))

        lambdau(j,k,xyz,*)=exp(Complex(0,-0.5*gamma(j,k)))*lambdau(j,k,xyz,*)

        helicity(j,k,xyz)=1/(SQRT(Double(lambdau(j,k,xyz,0))^2     $
             +Double(lambdau(j,k,xyz,1))^2+Double(lambdau(j,k,xyz,2))^2)  $
             /SQRT(Imaginary(lambdau(j,k,xyz,0))^2                 $
             +Imaginary(lambdau(j,k,xyz,1))^2+Imaginary(lambdau(j,k,xyz,2))^2))

;ELLIPTICITY CALCULATION
        
        uppere=Imaginary(lambdau(j,k,xyz,0))*Double(lambdau(j,k,xyz,0))  $
              +Imaginary(lambdau(j,k,xyz,1))*Double(lambdau(j,k,xyz,1))
        lowere=-Imaginary(lambdau(j,k,xyz,0))^2+Double(lambdau(j,k,xyz,0))^2 $
              -Imaginary(lambdau(j,k,xyz,1))^2+Double(lambdau(j,k,xyz,1))^2
        if uppere GT 0 then gammarot(j,k)=ATAN(uppere,lowere)            $
              else gammarot(j,k)=!DPI+!DPI+ATAN(uppere,lowere) 

        lam=lambdau(j,k,xyz,0:1)
        lambdaurot(j,k,*)=exp(complex(0,-0.5*gammarot(j,k)))*lam(*)

        ellip(j,k,xyz)=Sqrt(Imaginary(lambdaurot(j,k,0))^2               $
            +Imaginary(lambdaurot(j,k,1))^2)/Sqrt(Double(lambdaurot(j,k,0))^2 $
            +Double(lambdaurot(j,k,1))^2)
        ellip(j,k,xyz)=-ellip(j,k,xyz)*(Imaginary(ematspec(j,k,0,1))   $
                      *sin(waveangle(j,k)))/abs(Imaginary(ematspec(j,k,0,1)) $
                      *sin(waveangle(j,k)))


    endfor
    
endfor


endfor ;end of main body

;AVERAGING HELICITY AND ELLIPTICITY RESULTS

e=(ellip(*,*,0)+ellip(*,*,1)+ellip(*,*,2))/3
h=(helicity(*,*,0)+helicity(*,*,1)+helicity(*,*,2))/3

;ELIMINATE RESULTS BELOW A CERTAIN LEVEL
     top=max(trmatspec)
     for j=0,nosteps-1 do begin
      for k=0,nopfft/2-1 do begin
        if pow_lmt_typ eq 0 then tplot_lmt=0.0    $
        else if pow_lmt_typ eq 1 then tplot_lmt=pow_lmt $
        else tplot_lmt=pow_lmt*top
          if (trmatspec(j,k) LT tplot_lmt) or (degpol(j,k) LT pol_lmt) then  $
            begin
              if (trmatspec(j,k) LT tplot_lmt) then   $
                begin
;                 trmatspec(j,k)=!values.f_nan
                  degpol(j,k)=!values.f_nan
                endif
	     
              waveangle(j,k)=!values.f_nan
              e(j,k)=!values.f_nan
              h(j,k)=!values.f_nan
            endif
;         if degpol(j,k) GT 0.7 then degpol(j,k)=1.0 		    
          if (h(j,k) lt 0.15) then waveangle(j,k)=!values.f_nan
      endfor
     endfor
  
    ; top=max(trmatspec)
     ;for k=0,nopfft/2-1 do begin
     ;    if trmatspec(j,k) LT level*top then degpol(j,k)=0
    ; endfor 

;CREATING STRUCTURES FOR TPLOT

timeline=str_to_time(start)+ABS(nopfft/2)/sampfreq+findgen(nosteps)   $
        *steplength/sampfreq
;print,timeline
binwidth=sampfreq/nopfft
freqline=binwidth*findgen(nopfft/2)
;scaling power results to units with meaning
wavedgangle=180*waveangle/!DPI
W=nopfft*Total(smooth^2)
powspec(*,1:nopfft/2-2)=1/W*2*trmatspec(*,1:nopfft/2-2)/binwidth
powspec(*,0)=1/W*trmatspec(*,0)/binwidth
powspec(*,nopfft/2-1)=1/W*trmatspec(*,nopfft/2-1)/binwidth
store_data,'Power',data={x:timeline,y:powspec,v:freqline,spec:1}
store_data,'Degree of Polarization',data={x:timeline,y:degpol,v:freqline,spec:1}
store_data,'Wavenormal Angle',data={x:timeline,y:wavedgangle,v:freqline,spec:1}
store_data,'Ellipticity',data={x:timeline,y:e,v:freqline,spec:1}
store_data,'Helicity',data={x:timeline,y:h,v:freqline,spec:1}
tplot_options,'xmargin',[10,20]
tplot_names
;options,'Power','Title','ORBIT 2404, B field'
options,'Power','ZLOG',1
options,'Power','yrange',[0,ylmt]
options,'Power','ytitle','Frequency, Hz'
options,'Power','ztitle','Power'
options,'Power','x_no_interp',corse
options,'Power','y_no_interp',corse
;;options,'Power','charsize',2

options,'Degree of Polarization','zrange',[0.00,1.00]
options,'Degree of Polarization','ytitle','Frequency, Hz'
options,'Degree of Polarization','yrange',[0,ylmt]
options,'Degree of Polarization','ztitle','!CDegree of!CPolarization'
options,'Degree of Polarization','x_no_interp',corse
options,'Degree of Polarization','y_no_interp',corse
;;options,'Degree of Polarization','charsize',2


options,'Wavenormal Angle','zrange',[0.00,90.0]
options,'Wavenormal Angle','ytitle','Frequency, Hz'
options,'Wavenormal Angle','yrange',[0,ylmt]
options,'Wavenormal Angle','ztitle','!CMin. Var.!CAngle to Bz'
options,'Wavenormal Angle','x_no_interp',corse
options,'Wavenormal Angle','y_no_interp',corse
;;options,'Wavenormal Angle','charsize',2


options,'Ellipticity','zrange',[-1.00,1.00]
options,'Ellipticity','ytitle','Frequency, Hz'
options,'Ellipticity','yrange',[0,ylmt]
options,'Ellipticity','ztitle','!CEllipticity'

options,'Ellipticity','x_no_interp',corse
options,'Ellipticity','y_no_interp',corse
;;options,'Ellipticity','charsize',2


options,'Helicity','zrange',[-1.00,1.00]
options,'Helicity','ytitle','Frequency, Hz'
options,'Helicity','yrange',[0,ylmt]
options,'Helicity','ztitle','!CHelicity'

options,'Helicity','x_no_interp',corse
options,'Helicity','y_no_interp',corse
;;options,'Helicity','charsize',2

;;window, 1, xsize=800, ysize=900

tplot_options,'charsize',1.2
tplot,['Power','Degree of Polarization','Wavenormal Angle','Ellipticity', $
       'Helicity'] ;,var_label=['ILAT','ALT']
tplot_panel,var='Power';,oplotvar='CYC'
tplot_panel,var='Degree of Polarization',oplotvar='CYC'
tplot_panel,var='Wavenormal Angle';,oplotvar='CYC'    
tplot_panel,var='Ellipticity';,oplotvar='CYC'  
tplot_panel,var='Helicity';,oplotvar='CYC'  

;popen,outps,/port
;loadct,38
;tplot,['Power','Degree of Polarization','Wavenormal Angle','Ellipticity', $
;       'Helicity'] ;,var_label=['ILAT','ALT']
;tplot_panel,var='Power';,oplotvar='CYC'
;tplot_panel,var='Degree of Polarization';,oplotvar='CYC'
;tplot_panel,var='Wavenormal Angle';,oplotvar='CYC'    
;tplot_panel,var='Ellipticity';,oplotvar='CYC'  
;tplot_panel,var='Helicity';,oplotvar='CYC'
;pclose

   
;window, 2

;FILTERING OF THE TIME SERIES BASED ON POLARIZATION

;polfilt= fltarr(1,nopfft)
;polfilt(0,0:nopfft/2-1)=degpol(0,*)
;polfilt(0,nopfft/2:nopfft-1)=reverse(degpol(0,*),2)

;polfilt=[degpol(0,*),degpol(0,nopfft/2-1-(indgen(256))) ]

;outxs=fft(polfilt^8*fft(xs(0:nopfft-1),/double),1,/double)

;window, 2

;!p.background=0 

;!p.multi=[0,1,4]
;!p.background=0 
;plot ,xs(0:nopfft-1)
;plot,outxs
;plot, trmatspec(0,*)
;plot,polfilt
;print,alt.y
;print,cycfreq
;print,cycdfreq    
return
end
