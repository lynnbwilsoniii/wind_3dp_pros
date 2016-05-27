;+
;NAME:fieldrot
;
;PURPOSE: to rotate ac field fluctuations from an arbitrary
;         coordinate system in one with Z aligned along the field direction
;
;INPUTS: DX,DY,DZ the dc field values in the initial coordinate system
;        X,Y,Z the ac field values in the same coordinate system
;
;OUTPUTS:returns the three component vector (fieldx,fieldy,fieldz)
;        which is  the ac field rotated in to the
;        righthanded coord system defined by the direction of DC
;        field vector. In this new coord system Z points along the DC
;        field vector, Y points in the direction perpendicular to the
;        projection of the DC field vector into the plane defined by
;        the original X and Y axes, and X completes the orthogonal
;        right-handed set. 
;
;
;RESTRICTIONS: The initial AC and DC fields must be defined in the
;               same orthogonal right-handed coordinate system
;
;
;EXAMPLE:fields=fieldrot(dcx,dcy,dcz,acx,acy,acz)
;
;
;
; MODIFICATION HISTORY: Chris Chaston, 30-10-96
;
;-
function fieldrot,DX,DY,DZ,X,Y,Z

;rotates XYZ into the field aligned direction given by the vector DX,DY,DZ

thetaB=arctangent(SQRT(DX^2+DY^2),DZ)
phib=arctangent(DY,DX)
fieldx=cos(thetaB)*cos(phib)*X+cos(thetaB)*sin(phiB)*Y-sin(thetaB)*Z
fieldy=-sin(phiB)*X+cos(phiB)*Y
fieldz=sin(thetaB)*cos(phiB)*X+sin(thetaB)*sin(phiB)*Y+cos(thetaB)*Z 
return,[fieldx,fieldy,fieldz]
end
