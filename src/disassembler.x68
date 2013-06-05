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
                  move.b  #14,d0                  ;Display feedMe header
                  lea     feedMe,a1
                  trap    #15

                  move.w  #$1234,$7FF4
                  move.w  #$AAAA,$7FF8

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
                  ;bra     decideOpcode

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


******************  START EA CODE HERE ***************************
; Determine EA (and Data), write hex values to good buffer 


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
                  SIMHALT                 ; halt simulator
 
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
