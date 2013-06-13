*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Mem Opt-in
* Date       : 05-09-2012
* Description:
*-----------------------------------------------------------

                  ORG     $1000     

SP                EQU     $FFFF00
goodBuffer        EQU     $F00000
badBuffer         EQU     $FFF000

************* Program code **************

start             movea.l #goodBuffer,a4          ;Set up the start of the goodBuffer for outputing instructions
                  movea.l #badBuffer,a0           ;Set up the start of the badBuffer for outputing instructions
                  LEA     jmp_table,a2     
                  move.b  #14,d0                  ;Display feedMe header
                  lea     feedMe,a1
                  trap    #15

                  move.b  #14,d0                  ;Ask for the starting address of user's program
                  lea     getStartMsg,a1
                  trap    #15

                  movea.l #0000,a1                ;Clear out a1, before use
                  move.b  #2,d0                   ;Store the starting address of the users assembled program in a1
                  trap    #15     
                  move.l  (a1),d1 
                  move.b  #4,d7                   ;Set up loop counter

                  jsr     charsToHex              ;Convert ascii to hex
                  swap    d3
                  movea.l d3,a6                   ;Store start address in a6

                  move.b  #14,d0                  ;Ask for the ending address of user's program
                  lea     getEndMsg,a1
                  trap    #15

                  movea.l #0000,a1                ;Clear out a1, before use
                  move.b  #2,d0                   ;Store the starting address of the users assembled program in a1
                  trap    #15     
                  move.l  (a1),d1 
                  move.b  #4,d7                   ;Set up loop counter

                  jsr     charsToHex              ;Convert ascii to hex
                  swap    d3
                  movea.l d3,a5                   ;Store end address in a5 

                  move.b  #11,d0
                  move.w  #$FF00,d1                ;Clear output screen, before beginning output
                  trap    #15

                  move.b  #14,d0                  ;Display disassembled code
                  lea     assembly,a1
                  trap    #15

                  move.b  #14,d5


processNextInstruction   
                  clr.l   d2
                  movea.l a6,a3                   ;Store last instruction address in a3 before we increment a6
                  move.w  (a6)+,d2 

                  jsr     checkClearScreen        ;Check and clear screen needed
                  jsr     printInstruction                      
                  
checkCompletion
                  cmpa.l  a6,a5                   ;If there are no more instructions, finish/restart program
                  blt     runAgain

                  movea.l #goodBuffer,a4          ;Set the start of the goodBuffer for outputing instructions
                  movea.l #badBuffer,a0           ;Set the start of the badBuffer for outputing instructions
                  bra     processNextInstruction

runAgain
                  move.b  #14,d0                  ;Display continue program message, prompt
                  lea     runAgainMsg,a1
                  trap    #15

                  move.b  #5,d0                   ;Grab input character
                  trap    #15

                  cmp.b   #$30,d1                 ;Check if user wants to stop the program, entered 0
                  beq     finished

                  cmp.b   #$31,d1                 ;Check if user wants to stop the program, entered 0
                  beq     restart

restart
                  move.b  #11,d0
                  move.w  #$FF00,d1                ;Clear output screen, before beginning output
                  trap    #15

                  clr     d0
                  clr     d1
                  clr     d2
                  clr     d3
                  clr     d4
                  clr     d5
                  clr     d6
                  clr     d7

                  suba.l a0,a0
                  suba.l a1,a1
                  suba.l a2,a2
                  suba.l a3,a3
                  suba.l a4,a4
                  suba.l a5,a5
                  suba.l a6,a6
                  bra     start

finished                                  ; branch for end of program
                  
        	        ;SIMHALT                 ; halt simulator
                  
 
************************************************************************
************************  START OP-CODE HERE ***************************
************************************************************************
; Determine Opcode, write hex value to good buffer
decideOpcode
                  move.b	#12,d1
                  move.w	d2,d3
                  LSR.W	  D1,D3				;get the first 4 bits of the instruction
                  MULU	  #6, d3
                  jsr     0(A2, D3)





******************  0000 ***************************    
writeImmediate
                move.w  d2, d3
                move.b  #20, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #28, d4 
                lsr.l   d4, d3
                cmp.b   #%0010, d3  
                beq     writeAndi
                cmp.b   #%0100, d3 
                beq     writeSubi
                cmp.b   #%0110, d3
                beq     writeAddi
                cmp.b   #%1010, d3  
                beq     writeEori
                cmp.b   #%1100, d3  
                beq     writeCmpi


writeAndi
                clr.l   d3  
                clr.l   d4
                move.l  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeAndiByte
                cmp.b   #$01, d3
                beq     writeAndiWord
                cmp.b   #$02, d3
                beq     writeAndiLong
                
writeAndiByte
                jsr     pushAndToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$42, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
               ; jsr     andiByteEA 

writeAndiWord
                jsr     pushAndToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$57, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
               ; jsr     andiWordEA     

writeAndiLong               
                jsr     pushAndToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$4c, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
              ;  jsr     andiLongEA  

writeSubi
                clr.l   d3  
                clr.l   d4
                move.l  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeSubiByte
                cmp.b   #$01, d3
                beq     writeSubiWord
                cmp.b   #$02, d3
                beq     writeSubiLong
writeSubiByte
                jsr     pushSubToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$42, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
              ;  jsr     subiByteEA 

writeSubiWord
                jsr     pushSubToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$57, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
              ;  jsr     subiWordEA

writeSubiLong
                jsr     pushSubToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$4c, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
              ;  jsr     subiLongEA  



                  
writeAddi
                clr.l   d3  
                clr.l   d4
                move.l  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeAddiByte
                cmp.b   #$01, d3
                beq     writeAddiWord
                cmp.b   #$02, d3
                beq     writeAddiLong
writeAddiByte
                jsr     pushAddToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$42, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
              ;  jsr     addiByteEA 

writeAddiWord
                jsr     pushAddToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$57, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
               ; jsr     addiWordEA

writeAddiLong
                jsr     pushAddToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$4c, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
               ; jsr     addiLongEA  
                  

                
writeEori
                clr.l   d3  
                clr.l   d4
                move.l  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeEoriByte
                cmp.b   #$01, d3
                beq     writeEoriWord
                cmp.b   #$02, d3
                beq     writeEoriLong
writeEoriByte
                jsr     pushEorToBuffer
                move.b  #$49, (a4)+		    ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$42, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
              ;  jsr     eoriByteEA 

writeEoriWord
                jsr     pushEorToBuffer
                move.b  #$49, (a4)+		    ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$57, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
              ;  jsr     eoriWordEA

writeEoriLong
                jsr     pushEorToBuffer
                move.b  #$49, (a4)+		    ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$4c, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
              ;  jsr     eoriLongEA  
                
                
                
writeCmpi
                clr.l   d3  
                clr.l   d4
                move.l  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeCmpiByte
                cmp.b   #$01, d3
                beq     writeCmpiWord
                cmp.b   #$02, d3
                beq     writeCmpiLong
writeCmpiByte
                jsr     pushCmpToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$42, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
               ; jsr     cmpiByteEA 

writeCmpiWord
                jsr     pushCmpToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$57, (a4)+   
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
               ; jsr     cmpiWordEA

writeCmpiLong
                jsr     pushCmpToBuffer
                move.b  #$49, (a4)+		      ;push i to buffer
                move.b  #$2e, (a4)+   
                move.b  #$4c, (a4)+   
                move.b  #tab,(a4)+                  ;add a tab
                move.b	#' ',	(a4)+
                clr.l   d3  
                clr.l   d4
                ;jsr     cmpiLongEA				


                
******************  0001 ***************************
writeMoveByte            	    							
                jsr     pushMoveToBuffer
                move.b  #$2e, (a4)+
                move.b  #$42, (a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3
                clr.l   d4
                jsr     moveByteEA       

******************  0010 ***************************
writeMoveLong
                  ;move.l	#$00000000, d3			;check if MOVEA or MOVE
                  move.w	d2, d3
                  move.b	#23, d4
                  lsl.l	  d4, d3
                  
                  move.l	#29, d4
                  lsr.l	  d4,d3				
                  
                  cmp.b	  #%001, d3
                  beq	    writeMoveALong
                  clr.l   d3
                  clr.l   d4
                  jsr     pushMoveToBuffer
                  move.b	#$2e,	(a4)+
                  move.b	#$4c,	(a4)+
                  move.b	#' ',	(a4)+
                  move.b  #tab,(a4)+                  ;add a tab
                  jsr 		moveLongEA			;jump to EA person's subroutine for MOVE.L
				
writeMoveALong
                  clr.l   d3
                  clr.l   d4
                  jsr     pushMoveToBuffer
                  move.b	#$41, (a4)+
                  move.b	#$2e, (a4)+
                  move.b	#$4c,	(a4)+
                  move.b  #tab,(a4)+                  ;add a tab
				
                  jsr 		moveALongEA 			;jump to EA person's subroutine for MOVE.L	

******************  0011 ***************************	    	
writeMoveWord    
                  ;move.l	#$00000000, d3			;check if MOVEA or MOVE
                  move.w	d2, d3
                  move.b	#23, d4
                  lsl.l 	d4, d3
                  
                  move.l	#29, d4
                  lsr.l	  d4,d3				
                  
                  cmp.b	  #%001, d3
                  beq	    writeMoveAWord
                  clr.l   d3
                  clr.l   d4
                  jsr     pushMoveToBuffer
                  move.b	#$2e,	(a4)+ 
                  move.b  #$57,	(a4)+   
                  move.b	#' ',	(a4)+
                  move.b  #tab,(a4)+                  ;add a tab
                  jsr	    moveWordEA			;jump to EA person's subroutine for MOVE.W
				
writeMoveAWord
                  clr.l   d3
                  clr.l   d4
                  jsr     pushMoveToBuffer
                  move.b	#$41, (a4)+
                  move.b	#$2e, (a4)+
                  move.b	#$57,	(a4)+	    			
                  move.b  #tab,(a4)+                  ;add a tab
                  jsr	    moveAWordEA			;jump to EA person's subroutine for MOVEA.W 
******************  0100 ***************************    
writeRts
                  move.w	d2, d3
                  move.b	#23, d4
                  lsl.l	  d4, d3
                  
                  move.l	#29, d4
                  lsr.l	  d4,d3				
                  
                  cmp.b 	#%111, d3
                  beq     writeLea
                   clr.l   d3
                  clr.l   d4    
                  move.b  #$52, (a4)+
                  move.b  #$54, (a4)+
                  move.b  #$53, (a4)+
                  ;add a tab
                  jsr     leaEA 

                
writeLea
                     

                  clr.l   d3
                  clr.l   d4
                  move.b  #$4c, (a4)+   
                  move.b  #$45, (a4)+   
                  move.b  #$41, (a4)+
                  move.b	#' ',	(a4)+
                  move.b	#' ',	(a4)+
                  move.b	#' ',	(a4)+
                  move.b	#' ',	(a4)+
                  move.b  #tab,(a4)+                  ;add a tab
                  jsr      returnFromEA             
 
pushMoveToBuffer
                  move.b	#$4d, (a4)+		
                  move.b  #$4f, (a4)+		
                  move.b  #$56, (a4)+		
                  move.b  #$45, (a4)+		
                  rts
pushEorToBuffer
                  move.b	#$45, (a4)+		
                  move.b  #$4f, (a4)+		
                  move.b  #$52, (a4)+		
                  rts

pushAsrToBuffer
                  move.b	#$41, (a4)+		
                  move.b  #$53, (a4)+		
                  move.b  #$52, (a4)+		
                  rts

pushLslToBuffer
                  move.b	#$4c, (a4)+		
                  move.b  #$53, (a4)+		
                  move.b	#$4c, (a4)+		
                  rts
pushLsrToBuffer
                  move.b	#$4c, (a4)+		
                  move.b  #$53, (a4)+		
                  move.b  #$52, (a4)+		
                  rts
pushAslToBuffer
                  move.b	#$41, (a4)+		
                  move.b  #$53, (a4)+		
                  move.b  #$52, (a4)+		
                  rts
pushAddToBuffer
                  move.b	#$41, (a4)+		
                  move.b  #$44, (a4)+		
                  move.b  #$44, (a4)+		
                  rts

pushAndToBuffer
                  move.b	#$41, (a4)+		
                  move.b  #$4e, (a4)+		
                  move.b  #$44, (a4)+		
                  rts

pushSubToBuffer
                  move.b	#$53, (a4)+		
                  move.b  #$55, (a4)+		
                  move.b  #$42, (a4)+		
                  rts

pushCmpToBuffer
                  move.b	#$43, (a4)+		
                  move.b  #$4d, (a4)+		
                  move.b  #$50, (a4)+		
                  rts

******************  0101 ***************************       
writeZeroOneZeroOne   
                move.w  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$02, d3
                beq     writeCCs
                jsr     writeQs
                
writeCCs
                clr.l   d3
                clr.l   d4
                move.w  d2, d3  
                move.b  #24, d3 
                clr.l   d4
                move.b  #27, d4
                lsr.l   d3,d3
                cmp.b   #%00011001, d3
                beq     writeDBcc
                jsr     writeScc
                
writeDBcc
                clr.l   d3
                clr.l   d4
                move.b  #$44, (a4)+
                move.b  #$42, (a4)+
                move.b  #$63, (a4)+
                move.b  #$63, (a4)+
               ; jsr     writeDBccEA                

writeScc
                clr.l   d3
                clr.l   d4
                move.b  #$53, (a4)+
                move.b  #$63, (a4)+
                move.b  #$63, (a4)+
                ;jsr     writeSccEA

writeQs             
                clr.l   d3
                clr.l   d4
                move.w   d2, d3
                move.b  #23, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #31, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeAddq
                cmp.b   #$01, d3
                beq     writeSubq
                jsr     invalidOpcode
writeAddq
                clr.l   d3  
                clr.l   d4
                move.w  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeAddqByte
                cmp.b   #$01, d3
                beq     writeAddqWord
                cmp.b   #$02, d3
                beq     writeAddqLong
writeAddqByte
                jsr     pushAddToBuffer
                move.b  #$51, (a4)+             ;push q to buffer
                move.b  #$2e, (a4)+   
                move.b  #$42, (a4)+   
                clr.l   d3  
                clr.l   d4
                ;jsr     writeAddqByteEA 

writeAddqWord
                jsr     pushAddToBuffer
                move.b  #$51, (a4)+             ;push q to buffer
                move.b  #$2e, (a4)+   
                move.b  #$57, (a4)+   
                clr.l   d3  
                clr.l   d4
                ;jsr     writeAddqWordEA

writeAddqLong
                jsr     pushAddToBuffer
                move.b  #$51, (a4)+             ;push q to buffer
                move.b  #$2e, (a4)+   
                move.b  #$4c, (a4)+   
                clr.l   d3  
                clr.l   d4
                ;jsr     writeAddqLongEA	
                
                
                
writeSubq
                clr.l   d3  
                clr.l   d4
                move.l  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeSubqByte
                cmp.b   #$01, d3
                beq     writeSubqWord
                cmp.b   #$02, d3
                beq     writeSubqLong
writeSubqByte
                jsr     pushSubToBuffer
                move.b  #$51, (a4)+             ;push q to buffer
                move.b  #$2e, (a4)+   
                move.b  #$42, (a4)+   
                clr.l   d3  
                clr.l   d4
                ;jsr     writeSubqByteEA 

writeSubqWord
                jsr     pushSubToBuffer
                move.b  #$51, (a4)+             ;push q to buffer
                move.b  #$2e, (a4)+   
                move.b  #$57, (a4)+   
                clr.l   d3  
                clr.l   d4
                ;jsr     writeSubqWordEA

writeSubqLong
                jsr     pushSubToBuffer
                move.b  #$51, (a4)+             ;push q to buffer
                move.b  #$2e, (a4)+   
                move.b  #$4c, (a4)+   
                clr.l   d3  
                clr.l   d4
                ;jsr     writeSubqLongEA	


******************  0110 ***************************    
writeZeroOneOneZero
                move.w  d2, d3
                move.b  #20, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #28, d4 
                lsr.l   d4, d3
                jsr     writeBcc    
                

writeBcc                
                clr.l   d3
                clr.l   d4
                move.w  d2, d3
                move.l  #20, d4
                lsl.l   d4, d3
                clr.l   d4
                move.l  #28, d4
                lsr.l   d4, d3
                cmp.b   #$02, d3
                beq     writeBhi
                cmp.b   #$03, d3
                beq     writeBls
                cmp.b   #$06, d3
                beq     writeBne
                cmp.b   #$07, d3
                beq     writeBeq
                cmp.b   #$0D, d3
                beq     writeBlt
                jsr     invalidOpcode
                
writeBhi
                move.b  #$42, (a4)+
                move.b  #$48, (a4)+
                move.b  #$49, (a4)+
                clr.l   d3
                clr.l   d4
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+   
                 jsr     writeBcc

writeBls
                move.b  #$42, (a4)+
                move.b  #$4c, (a4)+
                move.b  #$53, (a4)+
                clr.l   d3
                clr.l   d4
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+  
                jsr     writeBcc
                
writeBne
                move.b  #$42, (a4)+
                move.b  #$4e, (a4)+
                move.b  #$45, (a4)+
                clr.l   d3
                clr.l   d4
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+  
                jsr     writeBcc


writeBeq
                move.b  #$42, (a4)+
                move.b  #$45, (a4)+
                move.b  #$51, (a4)+
                clr.l   d3
                clr.l   d4
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+  
                jsr     writeBcc

writeBlt
                move.b  #$42, (a4)+
                move.b  #$4c, (a4)+
                move.b  #$54, (a4)+
                clr.l   d3
                clr.l   d4
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+  
                jsr     writeBcc                


******************  0111 ***************************    
writeMoveq
                jsr     pushMoveToBuffer
                move.b  #$51, (a4)+             ;push q to buffer
                clr.l   d3  
                clr.l   d4  
                ;jsr     writeMoveqEA

******************  1000 ***************************    
;None     
******************  1001 ***************************    
writeSubs
                clr.l   d3  
                clr.l   d4
                move.w  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3    
                beq     writeSubByte
                cmp.b   #$01, d3
                beq     writeSubWord
                cmp.b   #$02, d3
                beq     writeSubLong 
                cmp.b   #$03, d3    
                beq     writeSuba
                
writeSubByte
                jsr      pushSubToBuffer
                move.b   #$2e, (a4)+ 
                move.b   #$42, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l    d3  
                clr.l    d4
                jsr      subByteEA                  
  

writeSubWord
                jsr      pushSubToBuffer
                move.b   #$2e, (a4)+ 
                move.b      #$57, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l       d3  
                clr.l       d4
                jsr         subWordEA                  
  
writeSubLong
                jsr      pushSubToBuffer
                move.b   #$2e, (a4)+ 
                move.b      #$4c, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l       d3  
                clr.l       d4
                jsr         subLongEA     
writeSuba                
                clr.l   d3
                clr.l   d4
                move.w  d2,d3
                move.b  #23, d4
                lsl.l   d4,d3
                clr.l   d4
                move.b  #31, d4
                lsr.l   d4,d3                
                cmp.b   #$00, d3
                beq     writeSubaWord
                cmp.b   #$01, d3    
                beq     writeSubaLong
writeSubaWord
                clr.l   d3
                clr.l   d4
                jsr      pushSubToBuffer
                move.b  #$41, (a4)+
                move.b  #$2e, (a4)+
                move.b  #$57, (a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+   
                jsr     subaWordEA 
writeSubaLong
                clr.l   d3
                clr.l   d4
                jsr      pushSubToBuffer
                move.b  #$41, (a4)+
                move.b  #$2e, (a4)+
                move.b  #$4c, (a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+   

                jsr     subaLongEA 


******************  1011 ***************************           
writeOneZeroOneOne
                clr.l   d3  
                clr.l   d4
                move.w  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3  
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3                
                cmp.b   #$03, d3    
                beq     writeCmpa
                clr.l   d3
                clr.l   d4
                move.w  d2, d3
                move.b  #23, d4
                lsl.l   d4,d3
                clr.l   d4
                move.b  #31, d4
                lsr.l   d4,d3
                cmp.b   #$00, d3
                beq     writeCmp
                jsr     writeEor
                
writeCmp
                clr.l   d3  
                clr.l   d4
                move.l  d2, d3
                move.l  #24, d4     
                lsl.l   d4, d3  
                clr.l   d4
                move.l  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3  
                beq     writeCmpByte
                cmp.b   #$01, d3 
                beq     writeCmpWord
                cmp.b   #02, d3    
                beq     writeCmpLong
writeCmpByte
                jsr     pushCmpToBuffer
                move.b  #$2e, (a4)+    
                move.b  #$42, (a4)+    
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
                jsr     cmpByteEA 

writeCmpWord
                jsr     pushCmpToBuffer
                move.b  #$2e, (a4)+    
                move.b  #$57, (a4)+    
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
                jsr     cmpWordEA

writeCmpLong
                jsr     pushCmpToBuffer
                move.b  #$2e, (a4)+    
                move.b  #$4c, (a4)+   
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
                jsr     cmpLongEA                
   
                
writeCmpa                
                clr.l   d3
                clr.l   d4
                move.w  d2,d3
                move.b  #23, d4
                lsl.l   d4,d3
                clr.l   d4
                move.b  #31, d4
                lsr.l   d4,d3                
                cmp.b   #$00, d3
                beq     writeCmpaWord
                cmp.b   #$01, d3    
                beq     writeCmpaLong
writeCmpaWord
                 clr.l   d3
                clr.l   d4
                jsr     pushCmpToBuffer
                move.b  #$41, (a4)+         ;push a to buffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$57, (a4)+         ;push w to buffer
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                jsr     cmpaWordEA
writeCmpaLong
                clr.l   d3
                clr.l   d4
                jsr     pushCmpToBuffer
                move.b  #$41, (a4)+         ;push a to buffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$4c, (a4)+         ;push l to buffer
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                jsr     cmpaLongEA
                
                
writeEor
                clr.l   d3  
                clr.l   d4
                move.l  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3  
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeEorByte
                cmp.b   #$01, d3
                beq     writeEorWord
                cmp.b   #$02, d3
                beq     writeEorLong
writeEorByte
                jsr     pushEorToBuffer
                move.b	#$2e,	(a4)+
                move.b  #$42, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
                jsr     eorByteEA 

writeEorWord
                jsr     pushEorToBuffer
                move.b  #$2e, (a4)+  
                move.b  #$57, (a4)+                
                 move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
                jsr     eorWordEA

writeEorLong
                jsr     pushEorToBuffer
                 move.b	#$2e,	(a4)+
                move.b  #$4c, (a4)+   
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
                jsr     eorLongEA 
                

******************  1100 ***************************   
writeAnds
                clr.l   d3  
                clr.l   d4
                move.l  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeAndByte
                cmp.b   #$01, d3
                beq     writeAndWord
                cmp.b   #$02, d3
                beq     writeAndLong
writeAndByte
                jsr     pushAndToBuffer
                move.b  #$2e,   (a4)+
                move.b  #$42, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+   
    
                clr.l   d3  
                clr.l   d4
                jsr     andByteEA 

writeAndWord
                jsr     pushAndToBuffer
                move.b  #$2e,   (a4)+
                move.b  #$57, (a4)+    
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
                jsr     andWordEA

writeAndLong
                jsr     pushAndToBuffer
                move.b  #$2e,   (a4)+
                move.b  #$4c, (a4)+   
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l   d3  
                clr.l   d4
                jsr     andLongEA 

******************  1101 ***************************    
writeAdds
                clr.l   d3  
                clr.l   d4
                move.w  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3    
                beq     writeAddByte
                cmp.b   #$01, d3
                beq     writeAddWord
                cmp.b   #$02, d3
                beq     writeAddLong 
                cmp.b   #$03, d3    
                beq     writeAdda
                
writeAddByte
                jsr     pushAddToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b      #$42, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l       d3  
                clr.l       d4
                jsr         addByteEA                  
  

writeAddWord
                jsr     pushAddToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b      #$57, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l       d3  
                clr.l       d4
                jsr         addWordEA                  
  
writeAddLong
                jsr     pushAddToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b      #$4c, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                clr.l       d3  
                clr.l       d4
                jsr         addLongEA     

                
writeAdda               
                clr.l   d3
                clr.l   d4
                move.w  d2,d3
                move.b  #23, d4
                lsl.l   d4,d3
                clr.l   d4
                move.b  #31, d4
                lsr.l   d4,d3                
                cmp.b   #$00, d3
                beq     writeAddaWord   
                cmp.b   #$01, d3    
                beq     writeAddaLong   
writeAddaWord
                 clr.l   d3
                clr.l   d4
                jsr     pushAddToBuffer
                move.b  #$41, (a4)+         ;push a to buffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$57, (a4)+         ;push w to buffer
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+                  ;add a tab
                jsr     addAEA
writeAddaLong
                clr.l   d3
                clr.l   d4
                jsr     pushAddToBuffer
                move.b  #$41, (a4)+         ;push a to buffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$4c, (a4)+         ;push l to buffer
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+        
          ;add a tab
                jsr     addAEA                

******************  1110 ***************************
writeOneOneOneZero
                move.w  d2,d3
                move.b  #27, d4
                lsl.l   d4,d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3
                beq     writeASd
                cmp.b   #$01, d3
                beq     writeLSd
                jsr     invalidOpcode

writeASd
                clr.l       d3
                clr.l       d4
                move.w      d2, d3
                move.b      #23, d4  
                lsl.l       d4,d3
                clr.l       d4
                move.b      #31, d4  
                lsr.l       d4,d3
                cmp.b       #$00, d3
                beq         writeAsr
                jsr         writeAsl
writeAsr
                clr.l   d3  
                clr.l   d4
                move.w  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3    
                beq     writeAsrByte
                cmp.b   #$01, d3
                beq     writeAsrWord
                cmp.b   #$02, d3
                beq     writeAsrLong 
                cmp.b   #$03, d3    
                beq     invalidOpcode
                
                
writeAsrByte
                clr.l   d3
                clr.l   d4
                jsr     pushAsrToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$42, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     asrByteEA
    

writeAsrWord
                clr.l   d3
                clr.l   d4
                jsr     pushAsrToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b      #$57, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     asrWordEA
writeAsrLong                
                clr.l   d3
                clr.l   d4
                jsr     pushAsrToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b      #$4c, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
               jsr     asrLongEA 
    
writeAsl   
                clr.l   d3  
                clr.l   d4
                move.w  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3    
                beq     writeAslByte    
                cmp.b   #$01, d3
                beq     writeAslWord    
                cmp.b   #$02, d3
                beq     writeAslLong    
                cmp.b   #$03, d3    
                beq     invalidOpcode   
                
writeAslByte    
                clr.l   d3
                clr.l   d4
                jsr     pushAslToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$42, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     aslByteEA
    
writeAslWord    
                clr.l   d3
                clr.l   d4
                jsr     pushAslToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$57, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     aslWordEA  
writeAslLong                  
                clr.l   d3
                clr.l   d4
                jsr     pushAslToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$4c, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     aslLongEA   

writeLSd                 
                move.w      d2, d3
                move.b      #23, d4  
                lsl.l       d4,d3
                clr.l       d4
                move.b      #31, d4
                lsr.l       d4,d3
                cmp.b       #$00, d3
                beq         writeLsr
                jsr         writeLsl
             
writeLsr
                clr.l   d3  
                clr.l   d4
                move.w  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3    
                beq     writeLsrByte    
                cmp.b   #$01, d3
                beq     writeLsrWord    
                cmp.b   #$02, d3
                beq     writeLsrLong    
                cmp.b   #$03, d3    
                beq     invalidOpcode   


writeLsrByte    
                clr.l   d3
                clr.l   d4
                jsr     pushAsrToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$42, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     lsrByteEA
    
writeLsrWord    
                clr.l   d3
                clr.l   d4
                jsr     pushAsrToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$57, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     lsrWordEA  
writeLsrLong                  
                clr.l   d3
                clr.l   d4
                jsr     pushAsrToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$4c, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     lsrLongEA 


writeLsl
                clr.l   d3  
                clr.l   d4
                move.w  d2, d3
                move.b  #24, d4
                lsl.l   d4, d3
                clr.l   d4
                move.b  #30, d4
                lsr.l   d4, d3
                cmp.b   #$00, d3    
                beq     writeLslByte    
                cmp.b   #$01, d3
                beq     writeLslWord    
                cmp.b   #$02, d3
                beq     writeLslLong    
                cmp.b   #$03, d3    
                beq     invalidOpcode

writeLslByte    
                clr.l   d3
                clr.l   d4
                jsr     pushLslToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$42, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     lslByteEA
    
writeLslWord    
                clr.l   d3
                clr.l   d4
                jsr     pushLslToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$57, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     lslWordEA  
writeLslLong                  
                clr.l   d3
                clr.l   d4
                jsr     pushLslToBuffer
                move.b  #$2e, (a4)+         ;push , to buffer
                move.b  #$4c, (a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b	#' ',	(a4)+
                move.b  #tab,(a4)+
                jsr     lslLongEA 



   

   
invalidOpcode
                add.l   #$80000000, d2
                 jsr    returnFromEA

******************  OP-CODE JUMP TABLE ***************************
; Determine Opcode, write hex value to good buffer

jmp_table      JMP         code0000

               JMP         code0001

               JMP         code0010

               JMP         code0011

               JMP         code0100

               JMP         code0101

               JMP         code0110

               JMP         code0111

               JMP         code1000

               JMP         code1001

               JMP         code1010

               JMP         code1011

               JMP         code1100

               JMP         code1101

               JMP         code1110

               JMP         code1111
               
               
code0000       BRA         writeImmediate    

code0001       BRA         writeMoveByte        

code0010       BRA         writeMoveLong    

code0011       BRA         writeMoveWord    

code0100       BRA         writeLea    

code0101       BRA         writeZeroOneZeroOne  

code0110       BRA         writeZeroOneOneZero  

code0111       BRA         writeMoveq       

code1000       BRA         invalidOpcode    

code1001       BRA         writeSubs

code1010       BRA         invalidOpcode       

code1011       BRA         writeOneZeroOneOne    

code1100       BRA         writeAnds

code1101       BRA         writeAdds       

code1110       BRA         writeOneOneOneZero

code1111       BRA         invalidOpcode 


************************************************************************
************************  START EA CODE HERE ***************************
************************************************************************

**************************************************
* Subroutines from OP code jump table

* code0000
addIEA      stop    #$2700  ; NOT DONE

andIEA      stop    #$2700  ; NOT DONE

cmpIEA      stop    #$2700  ; NOT DONE

eorIEA      stop    #$2700  ; NOT DONE

subIEA      stop    #$2700  ; NOT DONE

* code0001
moveByteEA  bra     printMoveSource

* code0010
moveLongEA	bra     printMoveSource

moveALongEA bra     printMoveSource

* code0011
moveWordEA  bra     printMoveSource

moveAWordEA bra     printMoveSource

* code0100
leaEA       bra     printLeaSource

rtsEA       bra     finish

* code0101
addQEA      stop    #$2700  ; NOT DONE

subQEA      stop    #$2700  ; NOT DONE

* code0110
bccEA       bra     printBcc

* code0111
moveQEA     stop    #$2700  ; NOT DONE

* code1000 - nothing


* code1001
subByteEA   bra     printSubSource

subWordEA   bra     printSubSource

subLongEA   bra     printSubSource

subaWordEA  bra     printSubSource

subaLongEA  bra     printSubSource

* code1010 - nothing


* code1011
eorByteEA   bra     printCmpSource

eorWordEA   bra     printCmpSource

eorLongEA   bra     printCmpSource

cmpByteEA   bra     printCmpSource

cmpWordEA   bra     printCmpSource

cmpLongEA   bra     printCmpSource

cmpAWordEA  bra     printCmpSource

cmpALongEA  bra     printCmpSource

* code1100
andByteEA   bra     printAndSource

andWordEA   bra     printAndSource

andLongEA   bra     printAndSource

* code1101
addByteEA   bra     printAddSource

addWordEA   bra     printAddSource

addLongEA   bra     printAddSource

addAEA      bra     printAddSource

* code1110
aslByteEA   bra     printAsdSource

aslWordEA   bra     printAsdSource

aslLongEA   bra     printAsdSource

asrByteEA   bra     printAsdSource

asrWordEA   bra     printAsdSource

asrLongEA   bra     printAsdSource

lslByteEA   bra     printAsdSource

lslWordEA   bra     printAsdSource

lslLongEA   bra     printAsdSource

lsrByteEA   bra     printAsdSource

lsrWordEA   bra     printAsdSource

lsrLongEA   bra     printAsdSource

* code1111 - nothing


**************************************************
* moveByte, moveWord, moveLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printMoveSource         ;clr.l   d2
                        ;move.l  #$0000161F,d2
                        move.l	d2,d4
                        move.b	#26,d5
                        lsl.l	  d5,d4
                        
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #5,d4
                    
                        cmpi.l	    #%000,d4	    * Data Register Direct
                        beq         printMoveSourceDRegister
                        cmpi.l	    #%001,d4	    * Address Register Direct
                        beq		    printMoveSourceARegister
                        cmp.b	    #%010,d4	    * Address Register Indirect
                        beq		    printMoveSourceAIndRegister
                        cmp.b	    #%011,d4	    * Address Register Indirect With Post Incrementing
                        beq		    printMoveSourceAIndPlusRegister
                        cmp.b	    #%100,d4	    * Address Register Indirect With Pre Decrementing
                        beq		    printMoveSourceAIndMinRegister
                        cmp.b	    #%101,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%110,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%111,d4	    * Immediate Data, Absolute Long Address, or Absolute Word Address
                        beq         printMoveSourceOneOneOne


**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

printMoveDestination    move.b      #comma,(a4)+    * Put a comma into the good buffer

                        move.l	    d2,d5
                        lsl.l	    #7,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #5,d5
                        move.b      #$77,d0

                        cmp.b	    #%000,d5	    * Data Register Direct
                        beq		    printMoveDestDRegister
                        cmp.b	    #%001,d5	    * Address Register Direct (Invalid)
                        beq		    printMoveDestARegister
                        cmp.b	    #%010,d5	    * Address Register Indirect
                        beq		    printMoveDestAIndRegister
                        cmp.b	    #%011,d5	    * Address Register Indirect With Post Incrementing
                        beq		    printMoveDestAIndPlusRegister
                        cmp.b	    #%100,d5	    * Address Register Indirect With Pre Decrementing
                        beq		    printMoveDestAIndMinRegister
                        cmp.b	    #%101,d5	    * Invalid?
                        beq	  	    invalidEA
                        cmp.b 	    #%110,d5	    * Invalid?
                        beq	  	    invalidEA
                        cmp.b 	    #%111,d5	    * Immediate Data (Invalid), Absolute Long Address, or Absolute Word Address 
                        beq	  	    printMoveDestOneOneOne
                        
                        
**************************************************
printMoveSourceOneOneOne
						movem.l		d5,-(SP)
                        move.l	    d2,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
                        lsl.l		#5,d5
			
            			lsr.l	    #8,d5
						lsr.l	    #8,d5
						lsr.l	    #8,d5
						lsr.l	    #5,d5
			
                        cmp.b	    #%000,d5	    * Word
                        beq		    printMoveSourceWord
                        cmp.b	    #%001,d5	    * Long
                        beq		    printMoveSourceLong
                        cmp.b	    #%010,d5	    * Invalid
                        beq		    invalidEA
                        cmp.b	    #%011,d5	    * Invalid
                        beq		    invalidEA
                        cmp.b	    #%100,d5	    * Immediate Data
                        beq		    printMoveSourceData
                        cmp.b	    #%101,d5	    * Invalid
                        beq	  	    invalidEA
                        cmp.b 	    #%110,d5	    * Invalid
                        beq	  	    invalidEA
                        cmp.b 	    #%111,d5	    * Invalid
                        beq	  	    invalidEA


**************************************************
printMoveSourceWord
			movem.l		(SP)+,d5
			
			jsr printWord
			
			bra printMoveDestination


**************************************************
printMoveSourceLong
			movem.l		(SP)+,d5
			
			jsr printLong
			
			bra printMoveDestination


**************************************************
printMoveSourceData
			;jsr printData
			movem.l		(SP)+,d5

			bra printMoveDestination



**************************************************
printMoveDestOneOneOne
						movem.l		d5,-(SP)
						move.l	    d2,d5       * Check Destination Register
						lsl.l		#8,d5
						lsl.l		#8,d5
						lsl.l		#4,d5
			
            			lsr.l	    #8,d5
						lsr.l	    #8,d5
						lsr.l	    #8,d5
						lsr.l	    #5,d5
			
                        cmp.b	    #%000,d5	    * Word
                        beq		    printMoveDestWord
                        cmp.b	    #%001,d5	    * Long
                        beq		    printMoveDestLong
                        cmp.b	    #%010,d5	    * Invalid
                        beq		    invalidEA
                        cmp.b	    #%011,d5	    * Invalid
                        beq		    invalidEA
                        cmp.b	    #%100,d5	    * Immediate Data
                        beq		    invalidEA
                        cmp.b	    #%101,d5	    * Invalid
                        beq	  	    invalidEA
                        cmp.b 	    #%110,d5	    * Invalid
                        beq	  	    invalidEA
                        cmp.b 	    #%111,d5	    * Invalid
                        beq	  	    invalidEA


**************************************************
printMoveDestWord
			movem.l		(SP)+,d5

			jsr printWord
			
			bra finish


**************************************************
printMoveDestLong
			movem.l		(SP)+,d5

			jsr printLong
			
			bra finish



**************************************************
* moveByte, moveWord, moveLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printMoveSourceDRegister
      move.b  #asciiD,(a4)+          * Put a "D" into the good buffer
			
			jsr     printSourceRegNum
			
			bra     printMoveDestination



**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printMoveDestDRegister
			move.b	#asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish



**************************************************
* moveByte, moveWord, moveLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printMoveSourceARegister
            move.b	#asciiA,(a4)+   * Put an "A" into the good buffer
			
			jsr     printSourceRegNum
			
			bra     printMoveDestination


**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printMoveDestARegister
			move.b	#asciiA,(a4)+       * Put an "A" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish


**************************************************
* moveByte, moveWord, moveLong
* Source
printMoveSourceAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     printMoveDestination


**************************************************
* moveByte, moveWord, moveLong
* Destination
printMoveDestAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printDestinationRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     finish


**************************************************
* moveByte, moveWord, moveLong
* Source
printMoveSourceAIndPlusRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            move.b  #plus,(a4)+         * Put a "+" into the good buffer    
            
            bra     printMoveDestination


**************************************************
* moveByte, moveWord, moveLong
* Destination
printMoveDestAIndPlusRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printDestinationRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            move.b  #plus,(a4)+         * Put a "+" into the good buffer    
            
            bra     finish


**************************************************
* moveByte, moveWord, moveLong
* Source
printMoveSourceAIndMinRegister
            move.b  #minus,(a4)+        * Put a "-" into the good buffer

            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer    
            
            bra     printMoveDestination


**************************************************
* moveByte, moveWord, moveLong
* Destination
printMoveDestAIndMinRegister
            move.b  #minus,(a4)+        * Put a "-" into the good buffer

            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printDestinationRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer    
            
            bra     finish

**************************************************
* printBcc 
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printBcc
                        move.b  d2,d4    ;move the 8 bit displacement value to branch on
                        cmpi.b  #$00,d4
                        beq     printBccWord
                        cmpi.b  #$FF,d4
                        beq     printBccLong
                        bra     printBccByte
  
printBccByte
                        move.b  #1,d6
                        jsr     pushD6HexValuesFromD4 
                        bra     returnFromEA
printBccWord
                        
                        move.w  (a6)+,d4 
                        move.b  #2,d6
                        jsr     pushD6HexValuesFromD4 
                        bra     returnFromEA

printBccLong
                        move.l  (a6)+,d4 
                        move.b  #4,d6
                        jsr     pushD6HexValuesFromD4 
                        bra     returnFromEA

 **************************************************
* cmpByte, cmpWord, cmpLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printCmpSource         ;clr.l   d2
                        ;move.l  #$0000161F,d2
                        move.l	d2,d4
                        move.b	#26,d5
                        lsl.l	  d5,d4
                        
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #5,d4
                    
                        cmpi.l	    #%000,d4	    * Data Register Direct
                        beq         printCmpSourceDRegister
                        cmpi.l	    #%001,d4	    * Address Register Direct
                        beq		    printCmpSourceARegister
                        cmp.b	    #%010,d4	    * Address Register Indirect
                        beq		    printCmpSourceAIndRegister
                        cmp.b	    #%011,d4	    * Address Register Indirect With Post Incrementing
                        beq		    printCmpSourceAIndPlusRegister
                        cmp.b	    #%100,d4	    * Address Register Indirect With Pre Decrementing
                        beq		    printCmpSourceAIndMinRegister
                        cmp.b	    #%101,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%110,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%111,d4	    * Immediate Data, Absolute Long Address, or Absolute Word Address
                        beq         dest


**************************************************
* cmpByte, cmpWord, cmpLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

printCmpDestination
            move.b      #comma,(a4)+    * Put a comma into the good buffer
            
            
                        move.l	    d2,d5
                        lsl.l	    #7,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #5,d5
                        move.b      #$77,d0

                        cmp.b	    #%000,d5	    * cmp, data register
                        beq		    printCmpDestDRegister
                        cmp.b	    #%001,d5	    * cmp, data register
                        beq		    printCmpDestDRegister
                        cmp.b	    #%010,d5	    * cmp, data register
                        beq		    printCmpDestDRegister
                        cmp.b	    #%011,d5	    * cmpa, address register
                        beq		    printCmpDestARegister
                        cmp.b	    #%100,d5	    * eor, data register
                        beq		    printCmpDestDRegister
                        cmp.b	    #%101,d5	    * eor, data register
                        beq	  	    printCmpDestDRegister
                        cmp.b 	    #%110,d5	    * eor, data register
                        beq	  	    printCmpDestDRegister
                        cmp.b 	    #%111,d5	    * cmpa, address register
                        beq	  	    printCmpDestARegister


**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printCmpDestDRegister
			move.b	#asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish


**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printCmpDestARegister
			move.b	#asciiA,(a4)+       * Put an "A" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish


**************************************************
* cmpByte, cmpWord, cmpLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printCmpSourceDRegister
            move.b  #asciiD,(a4)+          * Put a "D" into the good buffer
			
			jsr     printSourceRegNum
			
			bra     printCmpDestination


**************************************************
* cmpByte, cmpWord, cmpLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printCmpSourceARegister
            move.b	#asciiA,(a4)+   * Put an "A" into the good buffer
			
			jsr     printSourceRegNum
			
			bra     printCmpDestination


**************************************************
* cmpByte, cmpWord, cmpLong
* Source
printCmpSourceAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     printCmpDestination


**************************************************
* cmpByte, cmpWord, cmpLong
* Source
printCmpSourceAIndPlusRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            move.b  #plus,(a4)+         * Put a "+" into the good buffer    
            
            bra     printCmpDestination


**************************************************
* cmpByte, cmpWord, cmpLong
* Source
printCmpSourceAIndMinRegister
            move.b  #minus,(a4)+        * Put a "-" into the good buffer

            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer    
            
            bra     printCmpDestination


**************************************************
* addByte, addWord, addLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

printAddSource
                        move.l	    d2,d5
                        lsl.l	    #7,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #5,d5
                        move.b      #$77,d0

                        cmp.b	    #%000,d5	    * add, dest is second operand
                        beq		    printAddSourceI
                        cmp.b	    #%001,d5	    * add, dest is second operand
                        beq		    printAddSourceI
                        cmp.b	    #%010,d5	    * add, dest is second operand
                        beq		    printAddSourceI
                        cmp.b	    #%011,d5	    * adda, dest is second operand
                        beq		    printAddSourceI
                        cmp.b	    #%100,d5	    * add, dest is first operand
                        beq		    printAddSourceII
                        cmp.b	    #%101,d5	    * add, dest is first operand
                        beq	  	    printAddSourceII
                        cmp.b 	    #%110,d5	    * add, dest is first operand
                        beq	  	    printAddSourceII
                        cmp.b 	    #%111,d5	    * adda, dest is second operand
                        beq	  	    printAddSourceI


**************************************************
* addByte, addWord, addLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printAddSourceI         ;clr.l   d2
                        ;move.l  #$0000161F,d2
                        move.l	d2,d4
                        move.b	#26,d5
                        lsl.l	  d5,d4
                        
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #5,d4
                    
                        cmpi.l	    #%000,d4	    * Data Register Direct
                        beq         	    printAddSourceIDRegister
                        cmpi.l	    #%001,d4	    * Address Register Direct
                        beq		    printAddSourceIARegister
                        cmp.b	    #%010,d4	    * Address Register Indirect
                        beq		    printAddSourceIAIndRegister
                        cmp.b	    #%011,d4	    * Address Register Indirect With Post Incrementing
                        beq		    printAddSourceIAIndPlusRegister
                        cmp.b	    #%100,d4	    * Address Register Indirect With Pre Decrementing
                        beq		    printAddSourceIAIndMinRegister
                        cmp.b	    #%101,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%110,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%111,d4	    * Immediate Data, Absolute Long Address, or Absolute Word Address
                        beq         dest


**************************************************
* addByte, addWord, addLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printAddSourceII
			move.b	#asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra printAddDestinationII


**************************************************
* addByte, addWord, addLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

printAddDestinationI    move.b      #comma,(a4)+    * Put a comma into the good buffer

                        move.l	    d2,d5
                        lsl.l	    #7,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #5,d5
                        move.b      #$77,d0

                        cmp.b	    #%000,d5	    * add
                        beq		    printAddDestIDRegister
                        cmp.b	    #%001,d5	    * add
                        beq		    printAddDestIDRegister
                        cmp.b	    #%010,d5	    * add
                        beq		    printAddDestIDRegister
                        cmp.b	    #%011,d5	    * adda
                        beq		    printAddDestIARegister
                        cmp.b	    #%100,d5	    * add

			*** this code isn't necessary ***
                        beq		    printAddDestIDRegister
                        cmp.b	    #%101,d5	    * add
                        beq	  	    printAddDestIDRegister
                        cmp.b 	    #%110,d5	    * add
                        beq	  	    printAddDestIDRegister
			*********************************

                        cmp.b 	    #%111,d5	    * adda
                        beq	  	    printAddDestIARegister


**************************************************
* addByte, addWord, addLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printAddDestIDRegister
			move.b	#asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish


**************************************************
* addByte, addWord, addLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printAddDestIARegister
			move.b	#asciiA,(a4)+       * Put an "A" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish


**************************************************
* addByte, addWord, addLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printAddSourceIDRegister
      move.b  #asciiD,(a4)+          * Put a "D" into the good buffer
			
			jsr     printSourceRegNum
			
			bra     printAddDestinationI


**************************************************
* addByte, addWord, addLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printAddSourceIARegister
            move.b	#asciiA,(a4)+   * Put an "A" into the good buffer
			
			jsr     printSourceRegNum
			
			bra     printAddDestinationI


**************************************************
* addByte, addWord, addLong
* Source
printAddSourceIAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     printAddDestinationI


**************************************************
* addByte, addWord, addLong
* Source
printAddSourceIAIndPlusRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            move.b  #plus,(a4)+         * Put a "+" into the good buffer    
            
            bra     printAddDestinationI


**************************************************
* addByte, addWord, addLong
* Source
printAddSourceIAIndMinRegister
            move.b  #minus,(a4)+        * Put a "-" into the good buffer

            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer    
            
            bra     printAddDestinationI


**************************************************
* addByte, addWord, addLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printAddDestinationII
			move.b      #comma,(a4)+    * Put a comma into the good buffer
			;clr.l   d2
                        ;move.l  #$0000161F,d2
                        move.l	d2,d4
                        move.b	#26,d5
                        lsl.l	  d5,d4
                        
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #5,d4
                    
                        cmpi.l	    #%000,d4	    * Data Register Direct
                        beq         	    invalidEA
                        cmpi.l	    #%001,d4	    * Address Register Direct
                        beq		    invalidEA
                        cmp.b	    #%010,d4	    * Address Register Indirect
                        beq		    printAddDestIIAIndRegister
                        cmp.b	    #%011,d4	    * Address Register Indirect With Post Incrementing
                        beq		    printAddDestIIAIndPlusRegister
                        cmp.b	    #%100,d4	    * Address Register Indirect With Pre Decrementing
                        beq		    printAddDestIIAIndMinRegister
                        cmp.b	    #%101,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%110,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%111,d4	    * Immediate Data, Absolute Long Address, or Absolute Word Address
                        beq         dest


**************************************************
* addByte, addWord, addLong
* Destination
printAddDestIIAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     finish


**************************************************
* addByte, addWord, addLong
* Destination
printAddDestIIAIndPlusRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            move.b  #plus,(a4)+         * Put a "+" into the good buffer    
            
            bra     finish


**************************************************
* addByte, addWord, addLong
* Destination
printAddDestIIAIndMinRegister
            move.b  #minus,(a4)+        * Put a "-" into the good buffer

            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer    
            
            bra     finish


**************************************************
* addByte, addWord, addLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

printSubSource
                        move.l	    d2,d5
                        lsl.l	    #7,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #5,d5
                        move.b      #$77,d0

                        cmp.b	    #%000,d5	    * sub, dest is second operand
                        beq		    printSubSourceI
                        cmp.b	    #%001,d5	    * sub, dest is second operand
                        beq		    printSubSourceI
                        cmp.b	    #%010,d5	    * sub, dest is second operand
                        beq		    printSubSourceI
                        cmp.b	    #%011,d5	    * suba, dest is first operand
                        beq		    printSubSourceI
                        cmp.b	    #%100,d5	    * sub, dest is first operand
                        beq		    printSubSourceII
                        cmp.b	    #%101,d5	    * sub, dest is first operand
                        beq	  	    printSubSourceII
                        cmp.b 	    #%110,d5	    * sub, dest is first operand
                        beq	  	    printSubSourceII
                        cmp.b 	    #%111,d5	    * suba, dest is first operand
                        beq	  	    printSubSourceI


**************************************************
* subByte, subWord, subLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printSubSourceI         ;clr.l   d2
                        ;move.l  #$0000161F,d2
                        move.l	d2,d4
                        move.b	#26,d5
                        lsl.l	  d5,d4
                        
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #5,d4
                    
                        cmpi.l	    #%000,d4	    * Data Register Direct
                        beq         	    printSubSourceIDRegister
                        cmpi.l	    #%001,d4	    * Address Register Direct
                        beq		    printSubSourceIARegister
                        cmp.b	    #%010,d4	    * Address Register Indirect
                        beq		    printSubSourceIAIndRegister
                        cmp.b	    #%011,d4	    * Address Register Indirect With Post Incrementing
                        beq		    printSubSourceIAIndPlusRegister
                        cmp.b	    #%100,d4	    * Address Register Indirect With Pre Decrementing
                        beq		    printSubSourceIAIndMinRegister
                        cmp.b	    #%101,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%110,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%111,d4	    * Immediate Data, Absolute Long Address, or Absolute Word Address
                        beq         dest


**************************************************
* subByte, subWord, subLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printSubSourceII
			move.b	#asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra printSubDestinationII


**************************************************
* subByte, subWord, subLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

printSubDestinationI    move.b      #comma,(a4)+    * Put a comma into the good buffer

                        move.l	    d2,d5
                        lsl.l	    #7,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #5,d5
                        move.b      #$77,d0

                        cmp.b	    #%000,d5	    * sub
                        beq		    printSubDestIDRegister
                        cmp.b	    #%001,d5	    * sub
                        beq		    printSubDestIDRegister
                        cmp.b	    #%010,d5	    * sub
                        beq		    printSubDestIDRegister
                        cmp.b	    #%011,d5	    * suba
                        beq		    printSubDestIARegister
                        cmp.b	    #%100,d5	    * sub

			*** this code isn't necessary ***
                        beq		    printSubDestIDRegister
                        cmp.b	    #%101,d5	    * sub
                        beq	  	    printSubDestIDRegister
                        cmp.b 	    #%110,d5	    * sub
                        beq	  	    printSubDestIDRegister
			*********************************

                        cmp.b 	    #%111,d5	    * suba
                        beq	  	    printSubDestIARegister


**************************************************
* subByte, subWord, subLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printSubDestIDRegister
			move.b	#asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish


**************************************************
* subByte, subWord, subLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printSubDestIARegister
			move.b	#asciiA,(a4)+       * Put an "A" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish


**************************************************
* subByte, subWord, subLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printSubSourceIDRegister
      move.b  #asciiD,(a4)+          * Put a "D" into the good buffer
			
			jsr     printSourceRegNum
			
			bra     printSubDestinationI


**************************************************
* subByte, subWord, subLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printSubSourceIARegister
            move.b	#asciiA,(a4)+   * Put an "A" into the good buffer
			
			jsr     printSourceRegNum
			
			bra     printSubDestinationI


**************************************************
* subByte, subWord, subLong
* Source
printSubSourceIAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     printSubDestinationI


**************************************************
* subByte, subWord, subLong
* Source
printSubSourceIAIndPlusRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            move.b  #plus,(a4)+         * Put a "+" into the good buffer    
            
            bra     printSubDestinationI


**************************************************
* subByte, subWord, subLong
* Source
printSubSourceIAIndMinRegister
            move.b  #minus,(a4)+        * Put a "-" into the good buffer

            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer    
            
            bra     printSubDestinationI


**************************************************
* subByte, subWord, subLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printSubDestinationII
			move.b      #comma,(a4)+    * Put a comma into the good buffer
			;clr.l   d2
                        ;move.l  #$0000161F,d2
                        move.l	d2,d4
                        move.b	#26,d5
                        lsl.l	  d5,d4
                        
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #5,d4
                    
                        cmpi.l	    #%000,d4	    * Data Register Direct
                        beq         	    invalidEA
                        cmpi.l	    #%001,d4	    * Address Register Direct
                        beq		    invalidEA
                        cmp.b	    #%010,d4	    * Address Register Indirect
                        beq		    printSubDestIIAIndRegister
                        cmp.b	    #%011,d4	    * Address Register Indirect With Post Incrementing
                        beq		    printSubDestIIAIndPlusRegister
                        cmp.b	    #%100,d4	    * Address Register Indirect With Pre Decrementing
                        beq		    printSubDestIIAIndMinRegister
                        cmp.b	    #%101,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%110,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%111,d4	    * Immediate Data, Absolute Long Address, or Absolute Word Address
                        beq         dest


**************************************************
* subByte, subWord, subLong
* Destination
printSubDestIIAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     finish


**************************************************
* subByte, subWord, subLong
* Destination
printSubDestIIAIndPlusRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            move.b  #plus,(a4)+         * Put a "+" into the good buffer    
            
            bra     finish


**************************************************
* subByte, subWord, subLong
* Destination
printSubDestIIAIndMinRegister
            move.b  #minus,(a4)+        * Put a "-" into the good buffer

            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer    
            
            bra     finish


**************************************************
* leaLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printLeaSource          ;clr.l   d2
                        ;move.l  #$0000161F,d2
                        move.l	d2,d4
                        move.b	#26,d5
                        lsl.l	  d5,d4
                        
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #5,d4
                    
                        cmpi.l	    #%000,d4	    * Data Register Direct
                        beq         	    invalidEA
                        cmpi.l	    #%001,d4	    * Address Register Direct
                        beq		    invalidEA
                        cmp.b	    #%010,d4	    * Address Register Indirect
                        beq		    printLeaSourceAIndRegister
                        cmp.b	    #%011,d4	    * Address Register Indirect With Post Incrementing
                        beq		    InvalidEA
                        cmp.b	    #%100,d4	    * Address Register Indirect With Pre Decrementing
                        beq		    invalidEA
                        cmp.b	    #%101,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%110,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%111,d4	    * Immediate Data, Absolute Long Address, or Absolute Word Address
                        beq         dest


**************************************************
* leaLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

printLeaDestination
            move.b      #comma,(a4)+    * Put a comma into the good buffer
            
            
                        move.l	    d2,d5
                        lsl.l	    #7,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #5,d5
                        move.b      #$77,d0

                        cmp.b	    #%000,d5	    * cmp, data register
                        beq		    invalidEA
                        cmp.b	    #%001,d5	    * cmp, data register
                        beq		    invalidEA
                        cmp.b	    #%010,d5	    * cmp, data register
                        beq		    invalidEA
                        cmp.b	    #%011,d5	    * cmpa, address register
                        beq		    invalidEA
                        cmp.b	    #%100,d5	    * eor, data register
                        beq		    invalidEA
                        cmp.b	    #%101,d5	    * eor, data register
                        beq	  	    invalidEA
                        cmp.b 	    #%110,d5	    * eor, data register
                        beq	  	    invalidEA
                        cmp.b 	    #%111,d5	    * cmpa, address register
                        beq	  	    printLeaDestARegister


**************************************************
* leaLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printLeaDestARegister
			move.b	#asciiA,(a4)+       * Put an "A" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish


**************************************************
* leaLong
* Source
printLeaSourceAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     printLeaDestination


**************************************************
* andByte, andWord, andLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

printAndSource
                        move.l	    d2,d5
                        lsl.l	    #7,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #5,d5
                        move.b      #$77,d0

                        cmp.b	    #%000,d5	    * and, dest is second operand
                        beq		    printAndSourceI
                        cmp.b	    #%001,d5	    * and, dest is second operand
                        beq		    printAndSourceI
                        cmp.b	    #%010,d5	    * and, dest is second operand
                        beq		    printAndSourceI
                        cmp.b	    #%011,d5	    * invalid
                        beq		    invalidEA
                        cmp.b	    #%100,d5	    * and, dest is first operand
                        beq		    printAndSourceII
                        cmp.b	    #%101,d5	    * and, dest is first operand
                        beq	  	    printAndSourceII
                        cmp.b 	    #%110,d5	    * and, dest is first operand
                        beq	  	    printAndSourceII
                        cmp.b 	    #%111,d5	    * invalid
                        beq	  	    invalidEA


**************************************************
* andByte, andWord, andLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printAndSourceI         ;clr.l   d2
                        ;move.l  #$0000161F,d2
                        move.l	d2,d4
                        move.b	#26,d5
                        lsl.l	  d5,d4
                        
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #5,d4
                    
                        cmpi.l	    #%000,d4	    * Data Register Direct
                        beq         	    printAndSourceIDRegister
                        cmpi.l	    #%001,d4	    * Address Register Direct
                        beq		    invalidEA
                        cmp.b	    #%010,d4	    * Address Register Indirect
                        beq		    printAndSourceIAIndRegister
                        cmp.b	    #%011,d4	    * Address Register Indirect With Post Incrementing
                        beq		    printAndSourceIAIndPlusRegister
                        cmp.b	    #%100,d4	    * Address Register Indirect With Pre Decrementing
                        beq		    printAndSourceIAIndMinRegister
                        cmp.b	    #%101,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%110,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%111,d4	    * Immediate Data, Absolute Long Address, or Absolute Word Address
                        beq         dest


**************************************************
* andByte, andWord, andLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printAndSourceII
			move.b	#asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra printAndDestinationII


**************************************************
* andByte, andWord, andLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

printAndDestinationI    move.b      #comma,(a4)+    * Put a comma into the good buffer

                        move.l	    d2,d5
                        lsl.l	    #7,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #5,d5
                        move.b      #$77,d0

                        cmp.b	    #%000,d5	    * and
                        beq		    printAndDestIDRegister
                        cmp.b	    #%001,d5	    * and
                        beq		    printAndDestIDRegister
                        cmp.b	    #%010,d5	    * and
                        beq		    printAndDestIDRegister
                        cmp.b	    #%011,d5	    * invalid
                        beq		    invalidEA
                        cmp.b	    #%100,d5	    * and

			*** this code isn't necessary ***
                        beq		    printAndDestIDRegister
                        cmp.b	    #%101,d5	    * and
                        beq	  	    printAndDestIDRegister
                        cmp.b 	    #%110,d5	    * and
                        beq	  	    printAndDestIDRegister
			*********************************

                        cmp.b 	    #%111,d5	    * invalid
                        beq	  	    invalidEA


**************************************************
* andByte, andWord, andLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printAndDestIDRegister
			move.b	#asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish


**************************************************
* andByte, andWord, andLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printAndDestIARegister
			move.b	#asciiA,(a4)+       * Put an "A" into the good buffer
			
			jsr     printDestinationRegNum
			
			bra finish


**************************************************
* andByte, andWord, andLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printAndSourceIDRegister
      move.b  #asciiD,(a4)+          * Put a "D" into the good buffer
			
			jsr     printSourceRegNum
			
			bra     printAndDestinationI


**************************************************
* andByte, andWord, andLong
* Source
printAndSourceIAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     printAndDestinationI


**************************************************
* andByte, andWord, andLong
* Source
printAndSourceIAIndPlusRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            move.b  #plus,(a4)+         * Put a "+" into the good buffer    
            
            bra     printAndDestinationI


**************************************************
* andByte, andWord, andLong
* Source
printAndSourceIAIndMinRegister
            move.b  #minus,(a4)+        * Put a "-" into the good buffer

            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer    
            
            bra     printAndDestinationI


**************************************************
* andByte, andWord, andLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printAndDestinationII
			move.b      #comma,(a4)+    * Put a comma into the good buffer
			;clr.l   d2
                        ;move.l  #$0000161F,d2
                        move.l	d2,d4
                        move.b	#26,d5
                        lsl.l	  d5,d4
                        
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #5,d4
                    
                        cmpi.l	    #%000,d4	    * Data Register Direct
                        beq         	    invalidEA
                        cmpi.l	    #%001,d4	    * Address Register Direct
                        beq		    invalidEA
                        cmp.b	    #%010,d4	    * Address Register Indirect
                        beq		    printAndDestIIAIndRegister
                        cmp.b	    #%011,d4	    * Address Register Indirect With Post Incrementing
                        beq		    printAndDestIIAIndPlusRegister
                        cmp.b	    #%100,d4	    * Address Register Indirect With Pre Decrementing
                        beq		    printAndDestIIAIndMinRegister
                        cmp.b	    #%101,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%110,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%111,d4	    * Immediate Data, Absolute Long Address, or Absolute Word Address
                        beq         dest


**************************************************
* andByte, andWord, andLong
* Destination
printAndDestIIAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     finish


**************************************************
* andByte, andWord, andLong
* Destination
printAndDestIIAIndPlusRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            move.b  #plus,(a4)+         * Put a "+" into the good buffer    
            
            bra     finish


**************************************************
* andByte, andWord, andLong
* Destination
printAndDestIIAIndMinRegister
            move.b  #minus,(a4)+        * Put a "-" into the good buffer

            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer    
            
            bra     finish


**************************************************
printAsdSource
                        move.l	    d2,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #6,d5
                        move.b      #$77,d0

                        cmp.b	    #%00,d5	    * Byte Register Shift
                        beq		    printAsdRSource
                        cmp.b	    #%01,d5	    * Word Register Shift
                        beq		    printAsdRSource
                        cmp.b	    #%10,d5	    * Long Register Shift
                        beq		    printAsdRSource
                        cmp.b	    #%11,d5	    * Word Memory Shift
                        beq		    printAsdM


**************************************************
printAsdRSource
			move.l	    d2,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
			lsl.l	    #2,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #7,d5
                        move.b      #$77,d0

                        cmp.b	    #%0,d5	    * Byte Register Shift
                        beq		    printAsdRSourceC
                        cmp.b	    #%1,d5	    * Word Register Shift
                        beq		    printAsdRSourceR


**************************************************
printAsdRSourceC	move.b      #pound,(a4)+          * Put a "#" into the good buffer
			move.l	    d2,d5
                        lsl.l	    #8,d5
                        lsl.l	    #8,d5
                        lsl.l	    #4,d5
            
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #8,d5
                        lsr.l	    #5,d5
                        move.b      #$77,d0

                        cmp.b	    #%000,d5	    * count: 8
                        beq		    printAsdRSourceCEight
                        cmp.b	    #%001,d5	    * count: 1
                        beq		    printAsdRSourceCOne
                        cmp.b	    #%010,d5	    * count: 2
                        beq		    printAsdRSourceCTwo
                        cmp.b	    #%011,d5	    * count: 3
                        beq		    printAsdRSourceCThree
                        cmp.b	    #%100,d5	    * count: 4
                        beq		    printAsdRSourceCFour
                        cmp.b	    #%101,d5	    * count: 5
                        beq	  	    printAsdRSourceCFive
                        cmp.b 	    #%110,d5	    * count: 6
                        beq	  	    printAsdRSourceCSix
                        cmp.b 	    #%111,d5	    * count: 7
                        beq	  	    printAsdRSourceCSeven


**************************************************
printAsdRSourceCEight
			move.b     #asciiEightInHex,(a4)+          * Put a "#" into the good buffer

			bra	   printAsdRDest


**************************************************
printAsdRSourceCOne
			move.b     #asciiOneInHex,(a4)+          * Put a "#" into the good buffer

			bra	   printAsdRDest


**************************************************
printAsdRSourceCTwo
			move.b     #asciiTwoInHex,(a4)+          * Put a "#" into the good buffer

			bra	   printAsdRDest


**************************************************
printAsdRSourceCThree
			move.b     #asciiThreeInHex,(a4)+          * Put a "#" into the good buffer

			bra	   printAsdRDest


**************************************************
printAsdRSourceCFour
			move.b     #asciiFourInHex,(a4)+          * Put a "#" into the good buffer

			bra	   printAsdRDest


**************************************************
printAsdRSourceCFive
			move.b     #asciiFiveInHex,(a4)+          * Put a "#" into the good buffer

			bra	   printAsdRDest


**************************************************
printAsdRSourceCSix
			move.b     #asciiSixInHex,(a4)+          * Put a "#" into the good buffer

			bra	   printAsdRDest


**************************************************
printAsdRSourceCSeven
			move.b     #asciiSevenInHex,(a4)+          * Put a "#" into the good buffer

			bra	   printAsdRDest


**************************************************
printAsdRSourceR
			move.b     #asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr        printDestinationRegNum
			
			bra	   printAsdRDest


**************************************************
printAsdRDest
            move.b     #comma,(a4)+     * Put a comma into the good buffer

			move.b     #asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr        printSourceRegNum
			
			bra	   finish


**************************************************
printAsdM
                        move.l	d2,d4				* Check last 3 bits for ea
                        lsl.l	#8,d4
                        lsl.l	#8,d4
                        lsl.l	#8,d4
                        lsl.l	#2,d4
                        
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #8,d4
                        lsr.l	  #5,d4
                    
                        cmpi.l	    #%000,d4	    * Data Register Direct
                        beq         	    invalidEA
                        cmpi.l	    #%001,d4	    * Address Register Direct
                        beq		    invalidEA
                        cmp.b	    #%010,d4	    * Address Register Indirect
                        beq		    printAsdMAIndRegister
                        cmp.b	    #%011,d4	    * Address Register Indirect With Post Incrementing
                        beq		    printAsdMAIndPlusRegister
                        cmp.b	    #%100,d4	    * Address Register Indirect With Pre Decrementing
                        beq		    printAsdMAIndMinRegister
                        cmp.b	    #%101,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%110,d4	    * Invalid?
                        beq		    invalidEA
                        cmp.b	    #%111,d4	    * Immediate Data, Absolute Long Address, or Absolute Word Address
                        beq         	    dest


**************************************************
printAsdMAIndRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            bra     finish


**************************************************
printAsdMAIndPlusRegister
            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer
            
            move.b  #plus,(a4)+         * Put a "+" into the good buffer    
            
            bra     finish


**************************************************
printAsdMAIndMinRegister
            move.b  #minus,(a4)+        * Put a "-" into the good buffer

            move.b	#openP,(a4)+        * Put a "(" into the good buffer
            
            move.b	#asciiA,(a4)+       * Put an "A" into the good buffer

            jsr     printSourceRegNum
            
            move.b	#closeP,(a4)+       * Put a ")" into the good buffer    
            
            bra     finish


**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printSourceRegNum
			move.l	    d2,d4       * Put source register into the good buffer
			move.b	    #29,d5
			lsl.l	    d5,d4
			
            lsr.l	    #8,d4
			lsr.l	    #8,d4
			lsr.l	    #8,d4
			lsr.l	    #5,d4
			
			move.b      d4,d7
			jsr         hexToChar
			move.b      d7,(a4)+
			rts

                
**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printDestinationRegNum
			move.l      d2,d4       * Put destination register into the good buffer
			move.b	    #20,d5
			lsl.l       d5,d4
			
            lsr.l	    #8,d4
			lsr.l	    #8,d4
			lsr.l	    #8,d4
			lsr.l	    #5,d4
			
			move.b      d4,d7
			jsr         hexToChar
			move.b      d7,(a4)+
			rts


**************************************************
printWord
			movem.l	d4,-(SP)
			move.b  #dollar,(a4)+       * Put a "$" into the good buffer
			move.w	(a6)+,d4
			move.b	#2,d6
			jsr	pushD6HexValuesFromD4
			movem.l	(SP)+,d4
			rts


**************************************************
printLong
			movem.l	d4,-(SP)
			move.b  #dollar,(a4)+       * Put a "$" into the good buffer
			move.l	(a6)+,d4
			move.b	#4,d6
			jsr	pushD6HexValuesFromD4
			movem.l	(SP)+,d4
			rts


**************************************************
dest


**************************************************
* If there is an invalid EA code, set MSB and return

invalidEA	
        ;add.l	  #80000000, d2
		    clr.l   d2
		    move.l  #$80000000,d2
		    bra     returnFromEA
		


**************************************************
* If there's data, print it and move a6

getData


**************************************************
* Finish EA

finish
          bra     returnFromEA



************************************************************************
************************  START IO CODE HERE ***************************
************************************************************************

**************************************************************************
* BEGIN:          charsToHex
*
* This function requires that d7 be loaded with an integer representing the number of chars to convert
* And d1 contains the chars to be converted
**************************************************************************
charsToHex   
                  move.b  d1,d3                   ;Move this char into d2
                  lsr.l   #8,d1                   ;Shift to be ready to read next char in d1
                  jsr     isValidAscii            ;Determines whether the inputed ascii is valid
                  cmp.b   #asciiNineInHex,d3      ;Check if the char is a digit or
                  ble     digitInD2ToHex          ;convert the char to actual value of digit
                  bra     LetterInD2ToHex         ;convert the char to actual value of hex letter
digitInD2ToHex
                  subi.b  #asciiZeroInHex,d3
                  bra     nextChar
LetterInD2ToHex
                  subi.b  #asciiCharToHex,d3
                  bra     nextChar
nextChar
                  ror.l   #4,d3                   ;Rotate bits to make room for next conversion
                  sub.b   #1,d7                   ;Subtract one from the loop counter
                  cmp.b   #0,d7
                  bgt     charsToHex              ;Loop until we translate all 4 chars to hex
                  rts
**************************************************************************
* END:            charsToHex
**************************************************************************
               


**************************************************************************
* BEGIN:          isValidAscii
*
* Subroutine to verify valid hex in ascii                                          
* Non-hex addresses are not supported, end program if encountered
**************************************************************************
isValidAscii  
                  jsr     isLessThanZero
                  jsr     isBetweenNineAndA
                  cmp.b   #asciiFInHex,d3         ;If the char is greater than 'F', it isn't valid
                  bgt     invalidAddress
                  rts 

isLessThanZero
                  cmp.b   #asciiZeroInHex,d3      ;Check if the char is valid 
                  blt     invalidAddress
                  rts

isBetweenNineAndA  
                  cmp.b   #asciiNineInHex,d3       ;Check if the first char is valid 
                  bgt     isLessThanA              ;If the char is greater than '9' check if it's also less than 'A'
                  rts

isLessThanA
                  cmp.b   #asciiAInHex,d3         ;Check if the char is valid 
                  blt     invalidAddress          ;If char is less than 'A' 
                  rts
              
invalidAddress
                  move.b  #14,d0                  ;Ask for the starting address of user's program
                  lea     inputError,a1           ;Print error message and stop program
                  trap    #15
                  bra     finished
**************************************************************************
* END:             isValidAscii                                          
**************************************************************************

**************************************************************************
* BEGIN:           checkClearScreen
*
* Subroutine to clear output screen 
**************************************************************************
checkClearScreen  
                  movem.l a1/d0/d1/d4/d6,-(SP)
                  
                  cmp.b   #26,d5                  ;If we've printed more than 28 lines, prompt to clear screen
                  bgt     promptForInput
                  movem.l (SP)+,a1/d0/d1/d4/d6
                  rts                             ;Else return to main program 

promptForInput
                  move.b  #14,d0                  ;Display continue program message, prompt
                  lea     continueMsg,a1
                  trap    #15

checkInput                  
                  move.b  #5,d0                   ;Grab input character
                  trap    #15

                  cmp.b   #$30,d1                 ;Check if user wants to stop the program, entered 0
                  beq     finished

                  move.b  #28,d4                  ;Set clearLineLoop counter
                  cmp.b   #$0D,d1                 ;If user presses enter, clear screen and continue, entered 'CR'
                  beq     clearLineLoop
                  bra     checkInput              ;Only accept exiting program or clearing screen

clearLineLoop
                  move.b  #14,d0
                  lea     emptyLine,a1
                  trap    #15
                  subi.b  #1,d4
                  cmp     #1,d4
                  bgt     clearLineLoop

                  move.b  #$00,d5                 ;Zero out counter for number-of-lines-printed-to-screen
                  movem.l (SP)+,a1/d0-d1/d4/d6
                  rts 

**************************************************************************
* END:            checkClearScreen                                         
**************************************************************************


**************************************************************************
* BEGIN:          printInstruction
*
* Subroutine to print current disassembled instruction in good buffer
**************************************************************************
printInstruction
                  movem.l d0/d3/d4/d6,-(SP)
                  move.l  a3,d4                       ;get the instruction address to print
                  move.b  #2,d6                       ;Set up loop counter for subroutine, we're printing 2 bytes
                  jsr     pushD6HexValuesFromD4         ;Print the address of the instruction we are processing
                  move.b  #tab,(a4)+                  ;add a tab

                  movem.l (SP)+,d0/d3/d4/d6
                  bra     decideOpcode
returnFromEA
                  movem.l d0/d3/d4/d6,-(SP)
                  move.b  #tab,(a4)+                  ;add a tab
                  cmp.l   #0,d2                       ;If the long in d2 is negative, we've set the error bit
                  blt     invalidInstruction
                  bra     validInstruction

invalidInstruction
                  move.b  #asciiD,(a0)+               ;Add 'DATA' to the good buffer for output
                  move.b  #asciiA,(a0)+
                  move.b  #asciiT,(a0)+
                  move.b  #asciiA,(a0)+
                  move.b  #tab,(a0)+                  ;add a tab

                  move.w  (a3),d4                     ;set up d4 to contain the instruction to print 
                  move.b  #2,d6                       ;Set up loop counter for subroutine, we're printing 2 bytes
                  jsr     pushD6HexValuesFromD4         ;Print the invalid instruction code
                 
                  move.b  #$00,(a1)+                  ;Add null to terminate string
                  movea.l #badBuffer,a1
                  move.b  #13,d0                      ;Task 13 prints the null terminated string in a1
                  trap    #15
                  bra     endPrintInstruction

validInstruction
                  move.b  #$00,(a4)+                 ;Add null to terminate string
                  movea.l #goodBuffer,a1
                  move.b  #13,d0                      ;Task 13 prints the null terminated string in a1
                  trap    #15
                  bra     endPrintInstruction

endPrintInstruction

                  add.b   #1,d5                       ;Add one line to our line-output-counter
                  movem.l (SP)+,d0/d3/d4/d6
                  bra     checkCompletion

**************************************************************************
* END:            printInstruction                                         
**************************************************************************

**************************************************************************
* BEGIN:          pushD6HexValuesFromD4
*
* Subroutine to print the Hex values stored in d4, the number of bytes (2 hex values)
* to be printed must be stored in d6, e.g move.b #2,d6 would print the 4 rightmost
* hex values stored in d4. The number in d6 must be between 1 and 4.
**************************************************************************
pushD6HexValuesFromD4
                  cmp.b   #4,d6
                  beq     process7thAnd8th
                  cmp.b   #3,d6
                  beq     process5thAnd6th
                  cmp.b   #2,d6
                  beq     process3rdAnd4th
                  bra     process1stAnd2nd

process7thAnd8th
                  move.l  d4,d3
                  rol.l   #8,d3
                  bra     processChars
process5thAnd6th
                  move.l  d4,d3
                  swap    d3
                  bra     processChars
process3rdAnd4th
                  move.w  d4,d3
                  lsr.w   #8,d3
                  bra     processChars

process1stAnd2nd
                  move.w  d4,d3
                  bra     processChars

processChars
                  move.b  d3,d7
                  lsr.b   #4,d7                     ;push off rightmost hex character, so we can convert the leftmost char
                  jsr     hexToChar
                  move.b  d7,(a4)+                  ;push char onto ouput buffer
                  move.b  d7,(a0)+                  ;push char onto bad ouput buffer
                                                                                                                                                
                  move.b  d3,d7
                  lsl.b   #4,d7                     ;push off the leftmost hex character, so we can convert the rightmost char
                  lsr.b   #4,d7
                  jsr     hexToChar
                  move.b  d7,(a4)+                  ;push char onto ouput buffer
                  move.b  d7,(a0)+                  ;push char onto bad ouput buffer

                  subi.b  #1,d6                     ;Subtract one from loop counter, until all bytes have been printed
                  cmp.b   #0,d6
                  beq     endInstructionPrint
                  bra     pushD6HexValuesFromD4

endInstructionPrint
                  rts
                                                                                                                                                
**************************************************************************
* END:            pushD6HexValuesFromD4
**************************************************************************

**************************************************************************
* BEGIN:          hexToChar
*
* Subroutine to convert hex value in d7 into a ascii character
**************************************************************************
hexToChar                                                                                                   
        cmp.b   #$9,d7                    ;Check if the char is a digit or                            
        ble     digitToAsciiII              ;convert the hex digit to a char                 
        bra     letterToAsciiII             ;convert the hex letter to a char
                                                                                                    
digitToAsciiII                                                                                               
        addi.b  #$30,d7                                                                  
        rts
                                                                                                              
letterToAsciiII                                                                                            
        addi.b  #$37,d7                                                                   
        rts


* Put variables and constants here

CR                EQU     $0D
LF                EQU     $0A
tab               EQU     $09
comma             EQU     $2C
null              EQU     $00
openP             EQU     $28
closeP            EQU     $29
plus              EQU     $2B
minus             EQU     $2D
pound             EQU     $23
dollar			  EQU	  $24

asciiZeroInHex    EQU     $30
asciiOneInHex     EQU     $31
asciiTwoInHex     EQU     $32
asciiThreeInHex   EQU     $33
asciiFourInHex    EQU     $34
asciiFiveInHex    EQU     $35
asciiSixInHex     EQU     $36
asciiSevenInHex   EQU     $37
asciiEightInHex   EQU     $38
asciiNineInHex    EQU     $39


asciiAInHex       EQU     $41
asciiFInHex       EQU     $46
asciiCharToHex    EQU     $37   

asciiA            EQU     $41
asciiD            EQU     $44
asciiT            EQU     $54

asciiB            EQU     $42
asciiN            EQU     $4E
asciiE            EQU     $45
asciiL            EQU     $4C
asciiQ            EQU     $51
asciiH            EQU     $48
asciiS            EQU     $53
asciiI            EQU     $49

conditionNE       EQU     %00000110
conditionLS       EQU     %00000011
conditionHI       EQU     %00000010
conditionLT       EQU     %00001101
conditionEQ       EQU     %00000111

inputError        dc.b    CR,LF
                  dc.b    'That is not a valid address register. Exiting Program!',CR,LF,CR,LF,0 

emptyLine         dc.b    '',CR,LF,0

getStartMsg       dc.b    CR,LF
                  dc.b    'Please enter the 4 digit hexadecimal start address of your assembled assembly: ',CR,LF,CR,LF,0

getEndMsg         dc.b    CR,LF
                  dc.b    'Please enter the 4 digit hexadecimal end address of your assembled assembly: ',CR,LF,CR,LF,0

runAgainMsg       dc.b    CR,LF
                  dc.b    'Please press 1 to enter new assembled instruction addresses, or 0 to terminate the program.',CR,LF,CR,LF,0

continueMsg       dc.b    CR,LF
                  dc.b    'Please press enter to continue, or 0 to terminate the program.',CR,LF,CR,LF,0

feedMe            dc.b    ' ************************************************************************ '    ,CR,LF
                  dc.b    '*                                                                        *'    ,CR,LF
                  dc.b    '*  68K68K    68K68K    68K68K    68K6             6        6   68K68K    *'    ,CR,LF
                  dc.b    '*  8         8         8         8   8            8 8    8 8   8         *'    ,CR,LF
                  dc.b    '*  K         K         K         K    K           K  K  K  K   K         *'    ,CR,LF
                  dc.b    '*  68K68K    68K68K    68K68K    6    6           6   66   6   68K68K    *'    ,CR,LF
                  dc.b    '*  8         8         8         8    8           8        8   8         *'    ,CR,LF
                  dc.b    '*  K         K         K         K   K            K        K   K         *'    ,CR,LF
                  dc.b    '*  6         68K68K    68K68K    68K6             6        6   68K68K    *'    ,CR,LF
                  dc.b    '*                                                                        *'    ,CR,LF
                  dc.b    ' ************************************************************************ '    ,CR,LF,CR,LF,0

assembly          dc.b    ' ************************************************************************* '    ,CR,LF
                  dc.b    '*                                                                         *'    ,CR,LF
                  dc.b    '*    68K     68K6   68K6   68K68K   6        6   68K68    6      6     6  *'    ,CR,LF
                  dc.b    '*   8   8   8       8      8        8 8    8 8   8    8   8       8   8   *'    ,CR,LF
                  dc.b    '*  K     K   K       K     K        K  K  K  K   K   K    K        K K    *'    ,CR,LF
                  dc.b    '*  68K68K6    6       6    68K68K   6   66   6   68K6     6         6     *'    ,CR,LF
                  dc.b    '*  8     8     8       8   8        8        8   8   8    8         8     *'    ,CR,LF
                  dc.b    '*  K     K      K       K  K        K        K   K    K   K         K     *'    ,CR,LF
                  dc.b    '*  6     6  68K6    68K6   68K68K   6        6   68K68    68K68K    6     *'    ,CR,LF
                  dc.b    '*                                                                         *'    ,CR,LF
                  dc.b    ' ************************************************************************* '    ,CR,LF,CR,LF,0
              
                  end  start        ;last line of source



















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
