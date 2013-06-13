*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7FF4
START:                  ; first instruction of program

* Put program code here
    
      ADDI.W    #$8888, D2 
      ADDI.W    #$8888, (A1)+     
      ADDI.W    #$8888, -(A1)       
      ADDI.W    #%1000, $FFFFFF
      ADDI.W    #$8888, (A1)       
      
      ADDI.W    $8888, $FFFFFF      ; Error        
      ADDI.W    D1, D2              ; Error 
      ADDI.W    A1, A2              ; Error 
      ADDI.W    D1, A2              ; Error    
      ADDI.W    A2, D1              ; Error   #5     
      ADDI.W    #$8888, A2          ; Error     
      ADDI.W    #$888888888888, D2   ; Error
      ;ANDI
      ANDI.W    #$8888, D2 
      ANDI.W    #$8888, (A1)+     
      ANDI.W    #$8888, -(A1)       
      ANDI.W    #%1000, $FFFFFF
      ANDI.W    #$8008, (A1)     
      
      ANDI.W    $8888, $FFFFFF      ; Error        
      ANDI.W    D1, D2              ; Error 
      ANDI.W    A1, A2              ; Error 
      ANDI.W    D1, A2              ; Error    
      ANDI.W    A2, D1              ; Error   #5     
      ANDI.W    #$8888, A2          ; Error     
      ANDI.W    #$888888888888, D2   ; Error      
      
      ;CMPI
      CMPI.W    #$8888, D2 
      CMPI.W    #$8888, (A1)+     
      CMPI.W    #$8888, -(A1)       
      CMPI.W    #%1000, $FFFFFF
      CMPI.W    #$8008, (A1)     
      
      CMPI.W    $8888, $FFFFFF      ; Error        
      CMPI.W    D1, D2              ; Error 
      CMPI.W    A1, A2              ; Error 
      CMPI.W    D1, A2              ; Error    
      CMPI.W    A2, D1              ; Error   #5     
      CMPI.W    #$8888, A2          ; Error     
      CMPI.W    #$888888888888, D2   ; Error

      ;EORI
      EORI.W    #$8888, D2 
      EORI.W    #$8888, (A1)+     
      EORI.W    #$8888, -(A1)       
      EORI.W    #%1000, $FFFFFF
      EORI.W    #$8008, (A1)     
      
      EORI.W    $8888, $FFFFFF      ; Error        
      EORI.W    D1, D2              ; Error 
      EORI.W    A1, A2              ; Error 
      EORI.W    D1, A2              ; Error    
      EORI.W    A2, D1              ; Error   #5     
      EORI.W    #$8888, A2          ; Error     
      EORI.W    #$888888888888, D2   ; Error  

      ;SUBI
      SUBI.W    #$8888, D2 
      SUBI.W    #$8888, (A1)+     
      SUBI.W    #$8888, -(A1)       
      SUBI.W    #%1000, $FFFFFF
      SUBI.W    #$8008, (A1)     
      
      SUBI.W    $8888, $FFFFFF      ; Error        
      SUBI.W    D1, D2              ; Error 
      SUBI.W    A1, A2              ; Error 
      SUBI.W    D1, A2              ; Error    
      SUBI.W    A2, D1              ; Error   #5     
      SUBI.W    #$8888, A2          ; Error     
      SUBI.W    #$888888888888, D2   ; Error     

      
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
