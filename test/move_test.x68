*-----------------------------------------------------------
* Title      : MOVE Test
* Written by : John Paul Wallway
* Date       : 05-08-2013
* Description: Initial test file for testing 
*-----------------------------------------------------------
    
      ORG    $7FF4         ; first instruction of program

start move.w  #$0CCC,D4
      move.w  D4,D6
      
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    end    start        ; last line of source
