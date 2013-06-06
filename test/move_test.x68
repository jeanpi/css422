*-----------------------------------------------------------
* Title      : MOVE Test
* Written by : John Paul Wallway
* Date       : 05-08-2013
* Description: Initial test file for testing 
*-----------------------------------------------------------
    
      ORG    $7FF4         ; first instruction of program

start move.w  #$0CCC,D4
      move.l  D2, D4
      move.l  A2, D4
      move.w  D4,D6
      movea.w D6, A4
      move.b  d0, d7
      
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    end    start        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
