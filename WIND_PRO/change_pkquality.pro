;+
;PROCEDURE change_pkquality, pkquality
;
;PURPOSE:
;  Change the level of packet quality used when filtering packets through
;  the WIND decommutation software.
;
;INPUTS:
;  pkquality: set bits to determine level of packet quality.
;	      the following bits will allow packets with these possible
;	      quality problems through the decommutator filter:
;		1: frame contains some fill data
;		2: the following packet is invalid
;		4: packet contains fill data
;	      the most conservative option is to set pkquality = 0
;
;CREATED BY:	Peter Schroeder
;LAST MODIFICATION: @(#)change_pkquality.pro	1.1 97/12/18
;-
pro change_pkquality,pkquality
@wind_com

err = call_external(wind_lib,'change_pkquality',pkquality)

return
end

