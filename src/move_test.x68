*-----------------------------------------------------------
* Title      : MOVE Test
* Written by : Mem Opt-in
* Date       : 05-08-2013
* Description: Initial test file for testing 
*-----------------------------------------------------------
    
      ORG    $7FF4         ; first instruction of program

start ;move.w  #$0CCC,D4
      ;move.b  #$0C,D4
      ;move.l  #$123456FA,D4
      move.b  D2, D4
      move.b  A2, D4
      move.w  D4,D6
      move.w  A4,D6
      move.l  D2, D4
      move.l  A2, D4
      ;movea.w #$1234, A4
      ;movea.l #$123456FA, A4
      ;movea.w $1234, A4
      ;movea.l $123456FA, A4
      movea.w D6, A4
      movea.l D6, A4
      
      
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    end    start        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
