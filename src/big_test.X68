*-----------------------------------------------------------
* Title      : Big Test
* Written by : John Paul Wallway
* Date       : 05-08-2013
* Description: Initial test file for testing 
*-----------------------------------------------------------
    
      ORG    $7FF4         ; first instruction of program

start ;move.w  #$0CCC,D4
      move.l    D2, D4
      move.l    A2, D4
      move.w    D4,D6
      movea.w   D6, A4
      move.b    d0, d7
      
      * cmp
      cmp.b     d2,d1
      cmp.w     a3,d5
      cmp.l     -(a4),d7
      cmpa.w    (a1),a0
      cmpa.l    (a5)+,a6
      
      * eor
      
      eor.b     d7,d5
      eor.w     d0,(a4)
      eor.l     d5,(a3)+
      
      * add
      
      add.b     -(a7),d3
      add.w     d4,(a5)
      add.l     a6,d6
      adda.w    d1,a1
      adda.l    (a5),a5
      
      
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    end    start        ; last line of source




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
