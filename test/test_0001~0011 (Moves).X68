*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
     
   move.l    D2, D4    
   move.l    A2, D4   
    move.w    D4,D6    
   movea.w   D6, A4   
   move.b    d0, d7   
   movea.l   d6, a4   
      move.b        (a1), (A4)+ 
      
      move.l          a1, #$5000  ; error
      movea.b       a1, a2         ; error
      
      
      
      
       
         
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
