*-----------------------------------------------------------
* Title      : MOVE Test
* Written by : John Paul Wallway
* Date       : 05-08-2013
* Description: Initial test file for testing 
*-----------------------------------------------------------
    
START: ORG    $7000         ; first instruction of program

      MOVE.B  #55,D2
      MOVE.B  #55,D3
      
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source
