;+
; Name:
;   binaryKI
; Purpose:
;   Returns the binary representation of a number of any numerical type.
; Argument:
;   number   scalar or array of numbers (any numerical type)
; Returns:
;   Byte array with binary representation of numbers.
; Examples:
;   Binary representation of 11b:
;     IDL> print, binary(11b)
;     0 0 0 0 1 0 1 1
;   Binary representation of pi (x86: Little-endian IEEE representation):
;     IDL> print, format='(z9.8,5x,4(1x,8i1))', long(!pi,0), binaryKI(!pi)
;      40490fdb      01000000 01001001 00001111 11011011 (x86 Linux)
;      0fdb4149      00001111 11011011 01000001 01001001 (Alpha OpenVMS)
;     IDL> print, format='(8(1x,8i0))', binaryKI(!dpi)
;      01000000 00001001 00100001 11111011 01010100 01000100 00101101 00011000
;   Some first tests before type double was added:
;     print, format='(2a6,4x,2z9.8,4x,8z3.2)', $
;       !version.arch, !version.os, long(!dpi,0,2), BYTE(!dpi,0,8)
;       x86 linux     54442d18 400921fb     18 2d 44 54 fb 21 09 40
;     sparc sunos     400921fb 54442d18     40 09 21 fb 54 44 2d 18
;     alpha   vms     0fda4149 68c0a221     49 41 da 0f 21 a2 c0 68
;     (Beginning with IDL 5.1, Alpha VMS uses IEEE representation as well.)
; Modification history:
;    19 Dec 1997  Originally a news posting by David Fanning.
;                       (Re: bits from bytes)
;    20 Dec 1997  "Complete" rewrite: eliminate loops.
;    22 Dec 1997  Bit shift instead of exponentiation, return byte
;      array, handle input arrays.
;      Think about double and complex types.
;    22 Sep 1998  Complete rewrite: reduce every numerical type to
;      single bytes. Check that big and little endian machines
;      return exactly the same results (if IEEE).
;    07 May 2003  Added newish data types, unsigned and long64.  BT
;    27 Mar 2014  Minor changes to syntax (e.g., use uppercase for built-in functions)
;                   and changed name to avoid conflict with pre-existing routine
;                   -> L.B. Wilson III
;-

FUNCTION binaryKI, number

s    = SIZE(number)
type = s[s[0] + 1]
n_no = s[s[0] + 2]
; Numerical types: (will have to be completed if IDL adds double-long, ...)
; 1:  byte             (1-byte unsigned integer)
; 2:  integer          (2-byte   signed integer)
; 3:  long             (4-byte   signed integer)
; 4:  floating-point   (4-byte, single precision)
; 5:  double-precision (8-byte, double precision)
; 6:  complex          (2x4-byte, single precision)
; 9:  double-complex   (2x8-byte, double precision)
; 12: uInt             (2-byte, unsigned integer)
; 13: uLong            (4-byte, unsigned integer)
; 14: Long64	       (8-byte, signed integer)
; 15: uLong64	       (8-byte, unsigned integer)
; Non-numerical types:
; 0: undefined, 7: string, 8: structure, 10: pointer, 11: object reference
;nbyt = [0, 1, 2, 4, 4, 8, 8, 0, 0, 16, 0, 0] ; number of bytes per type
;code = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
nbyt  = [0, 1, 2, 4, 4, 8, 8, 0, 0, 16, 0, 0,  2,  4,  8,  8]
ntyp  = nbyt[type]
IF (ntyp EQ 0) THEN MESSAGE, 'Invalid argument (must be numerical type).'
bits  = [128, 64, 32, 16,  8,  4,  2,  1] ; = ishft(1b, 7-indgen(8))
; For correct array handling and byte comparison, 'number' and 'bits' require
; same dimensions -> numvalue and bitvalue
bitvalue = ((bits)[*, INTARR(ntyp)])[*, *, INTARR(n_no)]
little_endian = (BYTE(1, 0, 1))[0]
; In case of complex type and little endian machine, swap the two float values
; before the complete second dimension is reversed at returning.
IF (type EQ 6 or type EQ 9) AND little_endian THEN $ ; type complex
  numvalue = REFORM((BYTE([number], 0, 1, ntyp/2, 2, n_no))[INTARR(8), *, [1,0], *], 8, ntyp, n_no) $
  ELSE numvalue = (BYTE([number], 0, 1, ntyp, n_no))[INTARR(8), *, *]
; On little endian machines, the second dimension of the return value must
; be reversed.
IF (little_endian AND (type NE 1)) THEN                 $
  RETURN, REVERSE((numvalue and bitvalue) NE 0, 2) ELSE $
  RETURN,         (numvalue and bitvalue) NE 0

END


