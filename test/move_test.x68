*-----------------------------------------------------------
* Title      : MOVE Test
* Written by : John Paul Wallway
* Date       : 05-08-2013
* Description: Initial test file for testing 
*-----------------------------------------------------------
    
START: ORG    $7000         ; first instruction of program

      move.w  #$0CCC,D4
      move.w  D4,D6
      
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source
