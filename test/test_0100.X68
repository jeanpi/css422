*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

        * LEA
        * None Errors
    LEA     (a1), a2
    LEA     $8000, a3
    LEA     $1234, a6
    
        * Errors
    LEA     #8000, d2
    LEA     d2, d4
    LEA     (a4)-, a8
    
    
    * RTS
        * None Errors
    RTS
    
    
    SIMHALT             ; halt simulator



    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
