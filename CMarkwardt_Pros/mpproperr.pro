;+
; NAME:
;   MPPROPERR
;
; AUTHOR:
;   Craig B. Markwardt, NASA/GSFC Code 662, Greenbelt, MD 20770
;   craigm@lheamail.gsfc.nasa.gov
;   UPDATED VERSIONs can be found on my WEB PAGE: 
;      http://cow.physics.wisc.edu/~craigm/idl/idl.html
;
; PURPOSE:
;   Propagate fitted model uncertainties to measured data points
;
; MAJOR TOPICS:
;   Curve and Surface Fitting
;
; CALLING SEQUENCE:
;   YCOVAR = MPPROPERR(BEST_FJAC, PCOVAR, PFREE_INDEX, [/DIAGONAL])
;
; DESCRIPTION:
;
;   MPPROPERR propagates the parameter uncertainties of a fitted
;   model to provide estimates of the model uncertainty at each 
;   measurement point.
;
;   When fitting a model to data with uncertainties, the parameters
;   will have estimated uncertainties.  In fact, the parameter
;   variance-covariance matrix indicates the estimated uncertainties
;   and correlations between parameters.  These uncertainties and
;   correlations can, in turn, be used to estimate the "error in the
;   model" for each measurement point.  In a sense, this quantity also
;   reflects the sensitivity of the model to each data point.
;
;   The algorithm used by MPPROPERR uses standard propagation of error
;   techniques, assuming that errors are small.  The input values of
;   MPPROPERR should be found from the output keywords of MPFIT or
;   MPFITFUN, as documented below.
;
;   The user has a choice whether to compute the *full*
;   variance-covariance matrix or not, depending on the setting of the
;   DIAGONAL keyword.  The full matrix is large, and indicates the
;   correlation the sampled model function between each measurement
;   point and every other point.  The variance terms lie on the
;   diagonal, and the covariance terms are on the off-diagonal.
;   
;   Usually however, the user will want to set /DIAGONAL, which only
;   returns the "diagonal" or variance terms, which represent the
;   model "uncertainty" at each measurement point.  The /DIAGONAL
;   setting only controls the amount of data returned to the user.
;   the full *parameter* covariance matrix is always used to compute
;   the output regardless of the setting for /DIAGONAL.
;
;   When using MPPROPERR, keep in mind the following dimensions of
;   the problem:
;     NPOINTS - number of measurement points
;     NPAR    - total number of fit parameters
;     NFREE   - number of *free* fit parameters
;
;   The inputs to this function are:
;     BEST_FJAC - the partial derivative matrix, or Jacobian matrix,
;                 as estimated by MPFIT or MPFITFUN (see below),
;                 which has dimensions of ARRAY(NPOINTS,NFREE).
;     PCOVAR - the parameter covariance matrix, as estimated by MPFIT
;              or MPFITFUN (see below), which has dimensions of
;              ARRAY(NPAR,NPAR).
;     PFREE_INDEX - an index array which describes which of the
;                   parameter set were variable, as returned by MPFIT
;                   or MPFITFUN.  Of the total parameter set PARMS,
;                   only PARMS[PFREE_INDEX] were varied by MPFIT.
;
;   There are special considerations about the values returned by
;   MPPROPERR.  First, if a parameter is touching a boundary
;   limit when the fit is complete, then it will be marked as having
;   variance and covariance of zero.  To avoid this situation, one can
;   re-run MPFIT or MPFITFUN with MAXITER=0 and boundary limits
;   disabled.  This will permit MPFIT to estimate variance and
;   covariance for all parameters, without allowing them to actually
;   vary during the fit.
;
;   Also, it is important to have a quality parameter covariance
;   matrix PCOVAR.  If the matrix is singular or nearly singular, then
;   the measurement variances and covariances will not be meaningful.
;   It helps to parameterize the problem to minimize parameter
;   covariances.  Also, consider fitting with double precision
;   quantities instead of single precision to minimize the chances of
;   round-off error creating a singular covariance matrix.
;
;   IMPORTANT NOTE: the quantities returned by this function are the
;   *VARIANCE* and covariance.  If the user wishes to compute
;   estimated standard deviation, then one should compute
;   SQRT(VARIANCE).  (see example below)
;
; INPUTS:
;
;   BEST_FJAC - the Jacobian matrix, as estimated by MPFIT/MPFITFUN
;               (returned in keyword BEST_FJAC).  This should be an
;               array ARRAY(NPOINTS,NFREE) where NFREE is the number
;               of free parameters.
;
;   PCOVAR - the full parameter covariance matrix, as returned in the
;            COVAR keyword of MPFIT/MPFITFUN.  This should be an array
;            ARRAY(NPAR,NPAR) where NPAR is the *total* number of
;            parameters.
;
; RETURNS:
;
;   The estimated uncertainty at each measurement point, due to
;   propagation of errors.  The dimensions depend on the value of the
;   DIAGONAL keyword.
;     DIAGONAL=1: returned value is ARRAY(NPOINTS)
;                 corresponding to the *VARIANCE* of the model
;                 function sampled at each measurment point
;                 **NOTE**: the propagated standard deviation would
;                 then be SQRT(RESULT).
;
;     DIAGONAL=0: returned value is ARRAY(NPOINTS,NPOINTS)
;                 corresponding to the variance-covariance matrix of
;                 the model function, sampled at the measurement
;                 points.
;
;
; KEYWORD PARAMETERS:
;
;   DIAGONAL - if set, then compute only the "diagonal" (variance)
;              terms.  If not set, then propagate the full covariance
;              matrix for each measurement point.
;
;   NAN - if set, then ignore NAN values in BEST_FJAC or PCOVAR
;         matrices (they would be set to zero).
;
;   PFREE_INDEX - index list of free parameters, as returned in the
;                 PFREE_INDEX keyword of MPFIT/MPFITFUN.  This should
;                 be an integer array ARRAY(NFREE), such that
;                 parameters PARMS[PFREE_INDEX] were freely varied during
;                 the fit, and the remaining parameters were not.
;                 Thus it should also be the case that PFREE_INDEX
;                 indicates the rows and columns of the parameter
;                 covariance matrix which were allowed to vary freely.
;                 Default: All parameters will be considered free.
;
;   
; EXAMPLE:
;
;   ; First, generate some synthetic data
;   npts = 200
;   x  = dindgen(npts) * 0.1 - 10.                  ; Independent variable 
;   yi = gauss1(x, [2.2D, 1.4, 3000.])              ; "Ideal" Y variable
;   y  = yi + randomn(seed, npts) * sqrt(1000. + yi); Measured, w/ noise
;   sy = sqrt(1000.D + y)                           ; Poisson errors
;
;   ; Now fit a Gaussian to see how well we can recover
;   p0 = [1.D, 1., 1000.]                   ; Initial guess (cent, width, area)
;   p = mpfitfun('GAUSS1', x, y, sy, p0, $  ; Fit a function
;                 best_fjac=best_fjac, pfree_index=pfree_index, /calc_fjac, $
;                 covar=pcovar)
;   ; Above statement calculates best Jacobian and parameter
;   ; covariance matrix
;
;   ; Propagate errors from parameter covariance matrix to estimated
;   ; measurement uncertainty.  The /DIAG call returns only the
;   ; "diagonal" (variance) term for each measurement.
;   ycovar = mpproperr(best_fjac, pcovar, pfree_index=pfree_index, /diagonal)
;
;   sy_prop = sqrt(ycovar)  ; Estimated sigma 
;   
;
; REFERENCES:
;
;   MINPACK-1, Jorge More', available from netlib (www.netlib.org).
;   "Optimization Software Guide," Jorge More' and Stephen Wright, 
;     SIAM, *Frontiers in Applied Mathematics*, Number 14.
;
; MODIFICATION HISTORY:
;   Written, 2010-10-27, CM
;   Updated documentation, 2011-06-26, CM
;
;  $Id: mpproperr.pro,v 1.5 2011/12/22 02:08:22 cmarkwar Exp $
;-
; Copyright (C) 2011, Craig Markwardt
; This software is provided as is without any warranty whatsoever.
; Permission to use, copy, modify, and distribute modified or
; unmodified copies is granted, provided this copyright and disclaimer
; are included unchanged.
;-

function mpproperr, fjac, pcovar, pfree_index=ifree, diagonal=diag, $
                        nan=nan, status=status, errmsg=errmsg

  COMPILE_OPT strictarr
  status = 0

  szf = size(fjac)
  if szf[0] NE 2 then begin
      errmsg = 'ERROR: BEST_FJAC must be an NPOINTxNFREE array'
      return, !values.d_nan
  endif
  npoints = szf[1]  ;; Number of measurement points
  nfree   = szf[2]  ;; Number of free parameters

  nfree1 = n_elements(ifree)
  if nfree1 EQ 0 then begin
      ifree1 = lindgen(nfree)
  endif else if nfree1 NE nfree then begin
      errmsg = 'ERROR: Dimensions of PFREE_INDEX and BEST_FJAC must match'
      return, !values.d_nan
  endif

  szc = size(pcovar)
  if szc[0] NE 2 then begin
      PCOVAR_BAD_DIMS:
      errmsg = 'ERROR: PCOVAR must be an NPARxNPAR array'
      return, !values.d_nan
  endif
  if szc[1] NE szc[2] then goto, PCOVAR_BAD_DIMS
  npar = szc[1]
  if npar LT nfree then begin
      errmsg = 'ERROR: size of PCOVAR array is smaller than PFREE_INDEX'
      return, !values.d_nan
  endif
  
  fjac1 = fjac
  ;; NOTE: if there are parts of the covariance matrix which are zero,
  ;; that is OK, since they will contribute nothing to the output.
  pcovar1 = (pcovar[ifree,*])[*,ifree]

  ;; Check for NAN values and, if requested, set them to zero.
  if keyword_set(nan) then begin
      wh = where(finite(pcovar1) EQ 0, ct)
      if ct GT 0 then pcovar1[wh] = 0
      wh = where(finite(fjac1) EQ 0, ct)
      if ct GT 0 then fjac1[wh] = 0
  endif
  
  if NOT keyword_set(diag) then begin
      ;; Pull out the full covariance matrix (using matrix notation)
      ycovar = (fjac # pcovar1) # transpose(fjac)
  endif else begin

      ;; Only pull out the variance (diagonal) terms, and optimize a
      ;; little so that we don't use all the memory.
      ycovar = 0
      for i = 0, nfree-1 do begin
          for j = 0, nfree-1 do begin
              ycovar = ycovar + fjac[*,i]*fjac[*,j]*pcovar1[i,j]
          endfor
      endfor
  endelse
  
  return, ycovar
end
