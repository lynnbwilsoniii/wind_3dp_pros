;+
;*****************************************************************************************
;
;  FUNCTION :   transform_velocity.pro
;  PURPOSE  :   Transforms arrays of velocities (theta's and phi's) by subtracting off
;                 an input velocity (deltav)
;
;  CALLED BY:   
;               convert_vframe.pro
;
;  CALLS:
;               NA
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               MVEL      :  Array of velocity magnitudes [km/s]
;               THETA     :  Array of theta (deg) values
;               PHI       :  Array of phi (deg) values
;               DELTAV    :  3-Element vector defining the transformation velocity [km/s]
;
;  EXAMPLES:    
;               transform_velocity,vel,theta, phi,deltav
;
;  KEYWORDS:    
;               V[X,Y,Z]  :  Set each to a named variable to be returned to user as the
;                              transformed velocity component [km/s]
;
;   CHANGED:  1)  NA                                               [09/19/2008   v1.0.11]
;             2)  Updated man page                                 [03/20/2009   v1.0.12]
;             3)  Updated man page                                 [06/21/2009   v1.0.13]
;             4)  Updated man page and changed some minor things
;                                                                  [01/27/2012   v1.1.0]
;
;   NOTES:      
;               
;
;   CREATED:  ??/??/????
;   CREATED BY:  Davin Larson
;    LAST MODIFIED:  01/27/2012   v1.1.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

PRO transform_velocity,mvel,theta,phi,deltav, $
                       VX=vx,VY=vy,VZ=vz,SX=sx,SY=sy,SZ=sz

;-----------------------------------------------------------------------------------------
; => Define unit vector components, S[X,Y,Z]
;-----------------------------------------------------------------------------------------
c     = COS(!DPI/18d1*theta)
sx    = c * COS(!DPI/18d1*phi)
sy    = c * SIN(!DPI/18d1*phi)
sz    = SIN(!DPI/18d1*theta)
;-----------------------------------------------------------------------------------------
; => Transform velocities
;-----------------------------------------------------------------------------------------
vx    = (mvel*sx) - deltav[0]
vy    = (mvel*sy) - deltav[1]
vz    = (mvel*sz) - deltav[2]
;-----------------------------------------------------------------------------------------
; => Define new spherical coordinate angles and velocity magnitude
;-----------------------------------------------------------------------------------------
vxxyy = (vx*vx + vy*vy)
mvel  = SQRT(vxxyy + vz*vz)
phi   = 18d1/!DPI*ATAN(vy,vx)             ;  -180 < phi < +180
phi   = phi + 36d1*(phi LT 0)             ;     0 < phi < +360
theta = 18d1/!DPI*ATAN(vz/ SQRT(vxxyy))

RETURN
END

;+
;*****************************************************************************************
;
;  FUNCTION :   convert_vframe.pro
;  PURPOSE  :   Takes a 3DP data structure and recalculates the relevant parameters after
;                 transforming into another reference frame defined by the input
;                 velocity supplied by the user.  The returned structure is in units of 
;                 distribution function (DF) which are (s^3 cm^-3 km^-3).
;
;  CALLED BY:   
;               NA
;
;  CALLS:
;               str_element.pro
;               dat_3dp_energy_bins.pro
;               conv_units.pro
;               velocity.pro
;               transform_velocity.pro
;               interp.pro
;
;  REQUIRES:    
;               1)  UMN Modified Wind/3DP IDL Libraries
;
;  INPUT:
;               TDATA        :  A 3D data structure
;               VFRAME       :  A vector [Vx,Vy,Vz] for the Solar Wind velocity (km/s)
;                                 [Input is optional]
;
;  EXAMPLES:    
;               el_str  = convert_vframe(ael,/INTERP)
;
;  KEYWORDS:    
;               EVALUES      :  An array of energy bin values (eV)
;               E_SHIFT      :  Amount of energy to shift data by (eV)
;               SC_POT       :  Estimate of spacecraft potential (eV)
;               INTERPOLATE  :  If set, data is interpolated at structure times
;                                 and at original energy estimates
;               EXTRAPOLATE  :  If set, data is extrapolated below min EVALUES
;               ETHRESH      :  Threshold energy for interpolation.
;               BINS         :  Data bins to use to calculate derivative of DF
;               DFDV         :  Velocity derivative of DF (averaged)
;
;   CHANGED:  1)  NA                                               [02/11/2001   v1.0.21]
;             2)  Now use my_velocity.pro                          [06/11/2008   v1.1.10]
;             3)  Updated man page                                 [03/20/2009   v1.1.11]
;             4)  Changed keyword INTERP to INTERPO to avoid syntax errors
;                                                                  [04/13/2009   v1.1.12]
;             5)  Updated man page                                 [06/21/2009   v1.0.13]
;             6)  Fixed syntax error produced when re-writing program and
;                  now calls program:  dat_3dp_energy_bins.pro instead of average.pro
;                                                                  [08/25/2009   v1.1.0]
;             7)  Updated man page and changed some minor things
;                                                                  [01/27/2012   v1.2.0]
;
;   NOTES:      
;               1)  If VFRAME is not given on input, the program uses the value defined
;                     by the structure tag VSW
;
;   ADAPTED FROM:  convert_vframe.pro    BY: Davin Larson
;   CREATED:  ??/??/????
;   CREATED BY:  Lynn B. Wilson III
;    LAST MODIFIED:  01/27/2012   v1.2.0
;    MODIFIED BY: Lynn B. Wilson III
;
;*****************************************************************************************
;-

FUNCTION  convert_vframe,   tdata,vframe,            $
                            EVALUES=evalues,         $
                            E_SHIFT=e_shift,         $
                            SC_POT=sc_pot,           $
                            INTERPOLATE=interpo,     $
                            EXTRAPOLATE=extrapolate, $
                            ETHRESH=ethresh,         $
                            DFDV=dfdv,               $
                            BINS=bins

;-----------------------------------------------------------------------------------------
; => Check input format
;-----------------------------------------------------------------------------------------
IF (tdata.VALID EQ 0) THEN BEGIN
   PRINT,'Invalid Data' 
   RETURN,tdata
ENDIF

IF N_PARAMS() LT 2 THEN vframe = tdata.VSW
;-----------------------------------------------------------------------------------------
; => Define default parameters and check input format
;-----------------------------------------------------------------------------------------
IF NOT KEYWORD_SET(e_shift) THEN e_shift = 0.
str_element,tdata,'E_SHIFT',e_shift
data        = tdata
data.ENERGY = data.ENERGY + e_shift

IF (N_ELEMENTS(evalues) EQ 0) THEN BEGIN
  myens     = dat_3dp_energy_bins(tdata)
  evalues   = myens.ALL_ENERGIES
ENDIF
t_units     = data[0].UNITS_NAME
IF (STRUPCASE(t_units) NE 'DF') THEN data = conv_units(data,'df')
o_data      = data.DATA
o_energy    = data.ENERGY

IF NOT KEYWORD_SET(sc_pot) THEN BEGIN
  IF (FINITE(data.SC_POT) OR data.SC_POT NE 0.0) THEN sc_pot = data.SC_POT $
    ELSE sc_pot = 0.
ENDIF ELSE BEGIN
  sc_pot = sc_pot
ENDELSE

str_element,data,'SC_POT', sc_pot
;-----------------------------------------------------------------------------------------
; => Shift energy values by SC Potential 
;-----------------------------------------------------------------------------------------
energy = data.ENERGY - sc_pot 
bad    = WHERE(data.ENERGY LT sc_pot*1.3,nbad)
IF (nbad GT 0) THEN BEGIN
;  bind = ARRAY_INDICES(data.ENERGY,bad)
;  data.DATA[bind[0,*],bind[1,*]] = !VALUES.F_NAN
; => LBW III 01/27/2012
  data.DATA[bad] = !VALUES.F_NAN
ENDIF
;-----------------------------------------------------------------------------------------
; => Determine if relativistic velocity calculation is necessary
;-----------------------------------------------------------------------------------------
tn1   = STRUPCASE(STRMID(data.DATA_NAME,0,1)) ; -1st letter of structure name
hi_lo = WHERE(STRPOS(STRLOWCASE(data.DATA_NAME),'high') GT 0,ghi)

CASE tn1 OF
  'E' : BEGIN
    IF (ghi GT 0) THEN rel_vel = 1 ELSE rel_vel = 0
  END
  'S' : BEGIN
    rel_vel = 1
  END
  ELSE : BEGIN
    rel_vel = 0
  END
ENDCASE
;-----------------------------------------------------------------------------------------
; => Calculate velocity in spherical coordinates
;-----------------------------------------------------------------------------------------
mvel  = velocity(energy,data.MASS,TRUE_VELOC=rel_vel)
theta = data.THETA
phi   = data.PHI

IF (KEYWORD_SET(ethresh) AND KEYWORD_SET(dfdv) EQ 0) THEN BEGIN
   IF KEYWORD_SET(bins) THEN BEGIN
     ind = WHERE(bins)
   ENDIF ELSE BEGIN
     ind = INDGEN(data.NBINS)
   ENDELSE
   dfavg = TOTAL(o_data[*,ind],2,/NAN)/TOTAL(FINITE(o_data[*,ind]),2,/NAN)
   vavg  = TOTAL(mvel[*,ind],2,/NAN)/TOTAL(FINITE(mvel[*,ind]),2,/NAN)
   dfdv  = DERIV(vavg,ALOG(dfavg))
ENDIF
;-----------------------------------------------------------------------------------------
; => Transform into new reference frame
;-----------------------------------------------------------------------------------------
transform_velocity,mvel,theta,phi,vframe,SX=sx,SY=sy,SZ=sz

; => Redefine relevant parameters
data.ENERGY = velocity(mvel,data.MASS,/INVERSE)
data.THETA  = theta
data.PHI    = phi
bn          = data.NBINS

; => LBW III 01/27/2012
;ww          = WHERE(FINITE(data.DATA) EQ 0,wc)
;IF (wc GT 0) THEN BEGIN
;  wind = ARRAY_INDICES(data.DATA,ww)
;  data.DATA[wind[0,*],wind[1,*]] = 0.0
;ENDIF
;-----------------------------------------------------------------------------------------
; => Interpolate data to fill NaNs if desired
;-----------------------------------------------------------------------------------------
IF KEYWORD_SET(interpo) THEN BEGIN
  ; => Interpolate [linearly] data back to original measured energy values
  FOR i=0L, bn - 1L DO BEGIN
     df_temp = data.DATA[*,i]
     th_temp = data.THETA[*,i]
     ph_temp = data.PHI[*,i]
     nrg     = data.ENERGY[*,i]
     ; => Redefine NaNs as zeros
     ; => LBW III 01/27/2012
     bad     = WHERE(FINITE(df_temp) EQ 0,wc)
     IF (wc GT 0) THEN df_temp[bad] = 0e0
     ind     = WHERE(df_temp GT 0,count)
     IF (count GT 0) THEN BEGIN
       ; => Interpolate values
       df_temp = interp(ALOG(df_temp[ind]),nrg[ind],evalues)
       th_temp = interp(th_temp[ind],nrg[ind],evalues)
       ph_temp = interp(ph_temp[ind],nrg[ind],evalues)
     ENDIF
     IF NOT KEYWORD_SET(extrapolate) THEN BEGIN
       ; => Remove data at energies below measured energy values
       w = WHERE(evalues LT MIN(nrg,/NAN),count)
       IF (count NE 0) THEN df_temp[w] = !VALUES.F_NAN
     ENDIF
     ; => Redefine structure tag values
     data.DATA[*,i]  = EXP(df_temp)
     data.THETA[*,i] = th_temp
     data.PHI[*,i]   = ph_temp
  ENDFOR
  ; => Redefine energy bin values
  data.ENERGY = evalues # REPLICATE(1.,data.NBINS)
  IF KEYWORD_SET(ethresh)  THEN BEGIN
    ind = WHERE(tdata.ENERGY GT ethresh[0],nind)
    IF (nind GT 0) THEN BEGIN
      eind   = ARRAY_INDICES(tdata.ENERGY,ind)
      bdfdv  = dfdv # REPLICATE(1.,data.NBINS)
      o_data = o_data*(1e0 + (sx*vframe[0] + sy*vframe[1] + sz*vframe[2])*bdfdv)
      data.DATA[eind[0,*],eind[1,*]] = o_data[eind[0,*],eind[1,*]]
    ENDIF
  ENDIF
ENDIF
;-----------------------------------------------------------------------------------------
; => Return altered structure to user
;-----------------------------------------------------------------------------------------

RETURN,data
END

