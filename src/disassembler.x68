*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Mem Opt-in
* Date       : 05-09-2012
* Description:
*-----------------------------------------------------------

                  ORG     $1000     

SP                EQU     $FFFF00
goodBuffer        EQU     $FF0000

************* Program code **************

start             movea.l #goodBuffer,a4          ;Set up the start of the goodBuffer for outputing instructions
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
                  bra     decideOpcode

returnFromEA
                  jsr     checkClearScreen        ;Check and clear screen needed
                  jsr     printInstruction                      
                  
                  cmpa.l  a6,a5                   ;If there are no more instructions, finish/restart program
                  blt     runAgain

                  movea.l #goodBuffer,a4          ;Set the start of the goodBuffer for outputing instructions
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
                 

******************  START OP-CODE HERE ***************************
; Determine Opcode, write hex value to good buffer
decideOpcode
                move.b	#12,d1
				move.w	d2,d3
				LSR.W	D1,D3				;get the first 4 bits of the instruction
				MULU	#6, d3
				jsr     0(A2, D3)
				
******************  0001 ***************************
writeMoveByte            	    							
				move.l  #$4d4f5645, (a4)+   ;print ASCII value of MOVE.B into the good buffer
				move.w  #$2e42, (a4)+
                clr.l   d3
                clr.l   d4
                jsr    moveByteEA       
******************  0010 ***************************
writeMoveLong
				;move.l	#$00000000, d3			;check if MOVEA or MOVE
				move.w	d2, d3
				move.b	#23, d4
				lsl.l	d4, d3
				
				move.l	#29, d4
				lsr.l	d4,d3				
				
				cmp.b	#%001, d3
				beq	    writeMoveALong
                clr.l   d3
                clr.l   d4
				move.l	#$4d4f5645, (a4)+		;print ASCII value of MOVE.L into the good buffer
				move.w	#$2e4c,	(a4)+
				jsr		moveLongEA			;jump to EA person's subroutine for MOVE.L
				
writeMoveALong
                clr.l   d3
                clr.l   d4
				move.l	#$4d4f5645, (a4)+		;print ASCII value of MOVEA.L into the good buffer
				move.w	#$412e, (a4)+
				move.b	#$4c,	(a4)+
				
				jsr		moveALongEA 			;jump to EA person's subroutine for MOVE.L	

******************  0011 ***************************	    	
writeMoveWord    
				;move.l	#$00000000, d3			;check if MOVEA or MOVE
				move.w	d2, d3
				move.b	#23, d4
				lsl.l	d4, d3
				
				move.l	#29, d4
				lsr.l	d4,d3				
				
				cmp.b	#%001, d3
				beq	    writeMoveAWord
                clr.l   d3
                clr.l   d4
				move.l	#$4d4f5645, (a4)+		;print ASCII value of MOVE.L into the good buffer
				move.w	#$2e57,	(a4)+   
				jsr	moveWordEA			;jump to EA person's subroutine for MOVE.W
				
writeMoveAWord
                clr.l   d3
                clr.l   d4
				move.l	#$4d4f5645, (a4)+		;print ASCII value of MOVEA.L into the good buffer
				move.w	#$412e, (a4)+
				move.b	#$57,	(a4)+	    			
                jsr	    moveAWordEA			;jump to EA person's subroutine for MOVEA.W 
******************  0100 ***************************    
writeLEA
                move.w	d2, d3
				move.b	#23, d4
				lsl.l	d4, d3
				
				move.l	#29, d4
				lsr.l	d4,d3				
				
				cmp.b	#%111, d3
				beq     writeRTS
				clr.l   d3
				clr.l   d4
				move.w  #$4c45, (a4)+   
				move.b  #$41, (a4)+
               ;jsr      leaEA
                
writeRTS
                clr.l   d3
                clr.l   d4    
                move.w  #$5242, (a4)+
                move.b  #$53, (a4)+
                ;jsr     rtsEA               
 
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
               
               
code0000       STOP        #$2700

code0001       BRA         writeMoveByte    

code0010       BRA         writeMoveLong

code0011       BRA         writeMoveWord  

code0100       STOP        #$2700

code0101       STOP        #$2700

code0110       STOP        #$2700

code0111       STOP        #$2700

code1000       STOP        #$2700

code1001       STOP        #$2700

code1010       STOP        #$2700

code1011       STOP        #$2700  

code1100       STOP        #$2700

code1101       STOP        #$2700

code1110       STOP        #$2700

code1111       STOP        #$2700


******************  START EA CODE HERE ***************************
; Determine EA (and Data), write hex values to good buffer 

        	;SIMHALT             ; halt simulator


**************************************************
* Subroutines from OP code jump table
* Check Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

* code0000
addIEA      stop    #$2700  ; NOT DONE

andIEA      stop    #$2700  ; NOT DONE

cmpIEA      stop    #$2700  ; NOT DONE

eorIEA      stop    #$2700  ; NOT DONE

subIEA      stop    #$2700  ; NOT DONE

movePEA     stop    #$2700  ; NOT DONE

* code0001
moveByteEA  bra     printMoveSource ; NOT DONE

* code0010
moveLongEA	bra     printMoveSource ; NOT DONE

moveALongEA stop    #$2700  ; NOT DONE

* code0011
moveWordEA  bra     printMoveSource ; NOT DONE

moveAWordEA stop    #$2700  ; NOT DONE

* code0100
leaEA       stop    #$2700  ; NOT DONE

rtsEA       stop    #$2700  ; NOT DONE

* code0101
addQEA      stop    #$2700  ; NOT DONE

subQEA      stop    #$2700  ; NOT DONE

sccQA       stop    #$2700  ; NOT DONE

dbccEA      stop    #$2700  ; NOT DONE

* code0110
braEA       stop    #$2700  ; NOT DONE

bsrEA       stop    #$2700  ; NOT DONE

bccEA       stop    #$2700  ; NOT DONE

* code0111
moveQEA     stop    #$2700  ; NOT DONE

* code1000 - nothing??


* code1001
subEA       stop    #$2700  ; NOT DONE

subAEA      stop    #$2700  ; NOT DONE

* code1010 - nothing??


* code1011
eorEA       stop    #$2700  ; NOT DONE

cmpEA       stop    #$2700  ; NOT DONE

cmpAEA      stop    #$2700  ; NOT DONE

* code1100
andEA       stop    #$2700  ; NOT DONE

* code1101
addEA       stop    #$2700  ; NOT DONE

addAEA      stop    #$2700  ; NOT DONE

* code1110
aslEA       stop    #$2700  ; NOT DONE

asrEA       stop    #$2700  ; NOT DONE

lslEA       stop    #$2700  ; NOT DONE

lsrEA       stop    #$2700  ; NOT DONE

* code1111 - nothing??


**************************************************
* moveByte, moveWord, moveLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits
printMoveSource move.l	d2,d4
			    move.b	#26,d5
			    lsl.l	d5,d4
			    
			    lsr.l	#8,d4
			    lsr.l	#8,d4
			    lsr.l	#8,d4
			    lsr.l	#5,d4
			
			    cmpi.l	#%000,d4	* Data Register Direct
			    beq     printMoveSourceDRegister
			    cmpi.l	#%001,d4	* Address Register Direct
			    beq		printMoveSourceARegister
			    cmp.b	#%010,d4	* Address Register Indirect
			    beq		dest
			    cmp.b	#%011,d4	* Address Register Indirect With Post Incrementing
			    beq		dest
			    cmp.b	#%100,d4	* Address Register Indirect With Pre Decrementing
			    beq		dest
			    cmp.b	#%101,d4	* Invalid?
			    beq		invalidEA
			    cmp.b	#%110,d4	* Invalid?
			    beq		invalidEA
			    cmp.b	#%111,d4	* Immediate Data, Absolute Long Address, or Absolute Word Address
			    beq		dest


**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source mode bits

printMoveDestination    move.l	d2,d5
			            lsl.l	#7,d5
		    	        lsl.l	#8,d5
			            lsl.l	#8,d5
			
			            lsr.l	#8,d5
			            lsr.l	#8,d5
			            lsr.l	#8,d5
			            lsr.l	#5,d5
			            move.b #$77,d0

			            cmp.b	#%000,d5	* Data Register Direct
			            jsr		printMoveDestinationDRegister
			            bra     finish
			            cmp.b	#%001,d5	* Address Register Direct (Invalid)
			            beq		invalidEA
			            cmp.b	#%010,d5	* Address Register Indirect
			            beq		finish
			            cmp.b	#%011,d5	* Address Register Indirect With Post Incrementing
			            beq		finish
			            cmp.b	#%100,d5	* Address Register Indirect With Pre Decrementing
			            beq		finish
			            cmp.b	#%101,d5	* Invalid?
			            beq		invalidEA
			            cmp.b	#%110,d5	* Invalid?
			            beq		invalidEA
			            cmp.b	#%111,d5	* Immediate Data (Invalid), Absolute Long Address, or Absolute Word Address
			            beq		getData


**************************************************
* moveByte, moveWord, moveLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printMoveSourceDRegister
            move.b	#asciiD,(a4)+          * Put a "D" into the good buffer
			
			jsr     printMoveSourceRegNum
			
			move.b  #comma,(a4)+      * Put a comma into the good buffer
			
			bra     printMoveDestination
			



**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printMoveDestinationDRegister
			move.b	#asciiD,(a4)+	* Put a "D" into the good buffer
			
			jsr     printMoveDestinationRegNum
			
			move.b  #null,(a4)+      * Put a null at the end
			
			rts



**************************************************
* moveByte, moveWord, moveLong
* Source
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 source register bits

printMoveSourceARegister
            move.b	#asciiA,(a4)+   * Put an "A" into the good buffer
			
			jsr     printMoveSourceRegNum
			
			move.b  #comma,(a4)+   * Put a comma into the good buffer
			
			bra     printMoveDestination
			



**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printMoveDestinationARegister
			move.b	#asciiA,(a4)+	* Put an "A" into the good buffer
			
			jsr     printMoveDestinationRegNum
			
			move.b  #null,(a4)+      * Put a null at the end
			
			rts


**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printMoveSourceRegNum
			move.l	d2,d4                   * Put source register into the good buffer
			move.b	#29,d5
			lsl.l	d5,d4
			
		    lsr.l	#8,d4
			lsr.l	#8,d4
			lsr.l	#8,d4
			lsr.l	#4,d4
			
			move.b  d4,d3
			JSR     hexToChar
			move.b  d3,(a4)+
			rts


**************************************************
* moveByte, moveWord, moveLong
* Destination
*	d2: Original Instruction
*	d3: Holder for hextoChar
*	d4: 3 destination register bits
printMoveDestinationRegNum
			move.l	d2,d4                   * Put destination register into the good buffer
			move.b	#20,d5
			lsl.l	d5,d4
			
		    lsr.l	#8,d4
			lsr.l	#8,d4
			lsr.l	#8,d4
			lsr.l	#5,d4
			
			move.b  d4,d3
			JSR     hexToChar
			move.b  d3,(a4)+
			rts


**************************************************
dest


**************************************************
* If there is an invalid EA code, set MSB and return

invalidEA	
		add.l	#80000000, d2
		bra     returnFromEA
		


**************************************************
* If there's data, print it and move a6

getData


**************************************************
* Finish EA

finish		move.b	CR,(a4)+	* Put a carriage return into the good buffer
			move.b	LF,(a4)+	* Put a line feed into the good buffer
			bra     returnFromEA




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
                  
                 ; halt simulator
 
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
                  movem.l a1/d0-d1/d4/d6,-(SP)
                  
                  cmp.b   #26,d5                  ;If we've printed more than 28 lines, prompt to clear screen
                  bgt     promptForInput
                  movem.l (SP)+,a1/d0-d1/d4/d6
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
                  movem.l d0/d3-d4/d6,-(SP)
                  move.l  a3,d4                       ;get the instruction address to print
                  move.b  #2,d6                       ;Set up loop counter for subroutine, we're printing 2 bytes
                  jsr     pushHexValuesFromD3         ;Print the address of the instruction we are processing
                  move.b  #tab,(a4)+                  ;add a tab

                  cmp.l   #0,d2                       ;If the long in d2 is negative, we've set the error bit
                  blt     invalidInstruction
                  bra     validInstruction
validInstruction
                   
invalidInstruction
                  move.b  #asciiD,(a4)+               ;Add 'DATA' to the good buffer for output
                  move.b  #asciiA,(a4)+
                  move.b  #asciiT,(a4)+
                  move.b  #asciiA,(a4)+
                  move.b  #tab,(a4)+                  ;add a tab

                  move.w  (a3),d4                     ;set up d3 to contain the instruction to print 
                  move.b  #2,d6                       ;Set up loop counter for subroutine, we're printing 2 bytes
                  jsr     pushHexValuesFromD3         ;Print the invalid instruction code
                 
endPrintInstruction
                  move.b  #$00,(a4)+                  ;Add null to terminate string
                  movea.l #goodBuffer,a1
                  move.b  #13,d0                      ;Task 13 prints the null terminated string in a1
                  trap    #15

                  add.b   #1,d5                       ;Add one line to our line-output-counter
                  movem.l (SP)+,d0/d3-d4/d6
                  rts

**************************************************************************
* END:            printInstruction                                         
**************************************************************************

**************************************************************************
* BEGIN:          pushHexValuesFromD3
*
* Subroutine to print the Hex values stored in d4, the number of bytes (2 hex values)
* to be printed must be stored in d6, e.g move.b #2,d6 would print the 4 rightmost
* hex values stored in d4. 
**************************************************************************
pushHexValuesFromD3
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
                  move.b  d3,d2
                  lsr.b   #4,d2                     ;push off rightmost hex character, so we can convert the leftmost char                      
                  jsr     hexToChar                                                                                                             
                  move.b  d2,(a4)+                  ;push char onto ouput buffer                                                                
                                                                                                                                                
                  move.b  d3,d2
                  lsl.b   #4,d2                     ;push off the leftmost hex character, so we can convert the rightmost char                  
                  lsr.b   #4,d2                                                                                                                 
                  jsr     hexToChar                                                                                                             
                  move.b  d2,(a4)+                  ;push char onto ouput buffer                                                                

                  subi.b  #1,d6                     ;Subtract one from loop counter, until all bytes have been printed 
                  cmp.b   #0,d6
                  beq     endInstructionPrint       
                  bra     pushHexValuesFromD3

endInstructionPrint
                  rts
                                                                                                                                                
**************************************************************************
* END:            pushHexValuesFromD3                                         
**************************************************************************

**************************************************************************
* BEGIN:          hexToChar
*
* Subroutine to print current disassembled instruction in good buffer
**************************************************************************
hexToChar                                                                                                   
        cmp.b   #$9,d2                    ;Check if the char is a digit or                            
        ble     digitToAscii              ;convert the hex digit to a char                 
        bra     letterToAscii             ;convert the hex letter to a char
                                                                                                    
digitToAscii                                                                                               
        addi.b  #$30,d2                                                                  
        rts
                                                                                                              
letterToAscii                                                                                            
        addi.b  #$37,d2                                                                   
        rts


* Put variables and constants here

CR                EQU     $0D
LF                EQU     $0A
tab               EQU     $09
comma             EQU     $2C
null              EQU     $00

asciiZeroInHex    EQU     $30
asciiNineInHex    EQU     $39
asciiAInHex       EQU     $41
asciiFInHex       EQU     $46
asciiCharToHex    EQU     $37   

asciiA            EQU     $41
asciiD            EQU     $44
asciiT            EQU     $54

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
