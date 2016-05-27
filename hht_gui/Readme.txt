NAME:
    hht_gui.sav

PURPOSE:
    GUI for HHT

WHERE TO DOWNLOAD AND HOW TO USE THE GUI
    1. Download hht_gui.zip from http://themis.ss.ncu.edu.tw/hht_gui.zip.
    2. Unzip the hht_gui.zip file.
    3. Change the directory to hht_gui. Note that Windows users should
       define the path to this directory.
    4. Execute hht_gui.sav file at the IDL prompt.
       IDL> RESTORE, 'hht_gui.sav'
       IDL> hht_gui
    For more information, users can click the Help button on the GUI menu.

    Corresponding Author: Mr. Beson Lee (beson@jupiter.ss.ncu.edu.tw)

    For more information about HHT, please go to the web site of the Research 
    Center for Adaptive Data Analysis(http://rcada.ncu.edu.tw/).  The HHT 
    technique was patented by NASA.

HOW TO CALL HHT PROCEDURES
    Two main procedures for HHT (EMD and IFNDQ) are included in 
    the hht_gui.sav file.  The two procedures can be used in a way 
    that is independent of the GUI implementation.  After the 
    hht_gui.sav file is restored, the two procedures will be loaded 
    in the IDL system. Users can call the two procedures from their 
    own program.  The usage of the two procedures is listed below:

    1. EMD
       Purpose:
               To decompose data into several modes with the EMD method.
       Syntax:
               EMD, data, rslt
       Input:
               data: A vector of time-series data.
       Output:
               rslt: A M x N array to be created, where M is the number 
                     of modes, and N is the number of elements in the data.
       Example:
              EMD, sin(findgen(100)/!dtor), rslt

    2. IFNDQ
       Purpose:
               To calculate instantaneous frequency for a particular mode.
       Syntax:
               IFNDQ, vimf, dt, omega
       Input:
               vimf : A vector of a particular mode decomposed from the 
                      EMD method.
               dt   : The time resolution of the particular mode.
       Output:
               omega: Calculated instantaneous frequency 2*!PI/T, 
                      where T is the period of an oscillation, and !PI=3.14159.
       Example:
              IFNDQ, sin(findgen(100)/!dtor), 2, omega
