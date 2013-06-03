*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Mem Opt-in
* Date       : 05-09-2012
* Description:
*-----------------------------------------------------------

                  ORG     $1000     

stack             EQU     $00FFFFFF
goodBuffer        EQU     $00F00000

************* Program code **************

start             movea.l goodBuffer,a4           ;Set up the start of the goodBuffer for outputing instructions
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
                  move.w  $FF00,d1                ;Clear output screen, before beginning output
                  trap    #15

                  move.b  #14,d0                  ;Display disassembled code
                  lea     assembly,a1
                  trap    #15


processNextInstruction   
                  clr.l   d2
                  move.w  (a6)+,d2 
                  ;bra     decideOpcode

returnFromEA
                  jsr     checkClearScreen        ;Check and clear screen needed
                  jsr     printInstruction                      
                  
                  cmpa.w  a5,a6                   ;If there are no more instructions, finish/restart program
                  beq     finished

                  bra     processNextInstruction

;Clear good buffer 
;Write next instruction address to good buffer 

******************  START OP-CODE HERE ***************************
; Determine Opcode, write hex value to good buffer


******************  START EA CODE HERE ***************************
; Determine EA (and Data), write hex values to good buffer 



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
                  movem.l a1/d0-d1,-(SP)
                  
                  cmp.b   #28,d3                  ;If we've printed more than 28 lines, prompt to clear screen
                  bgt     promptForInput
                  rts                             ;Else return to main program 

promptForInput
                  move.b  #14,d0                  ;Display continue program message, prompt
                  lea     continueMsg,a1
                  trap    #15

checkInput                  
                  move.b  #5,d0                   ;Grab input character
                  trap    #15

                  cmp.b   $00,d0                  ;Check if user wants to stop the program
                  beq     finished

                  cmp.b   $0D,d0                  ;If user presses enter, clear screen and continue
                  beq     clearScreen
                  bra     checkInput                      ;Only accept exiting program or clearing screen

clearScreen
                  move.w  $FF00,d1                ;Clear output screen and return to main program
                  move.b  #11,d0
                  trap    #15
                  move.b  #$00,d3                 ;Zero out counter for number-of-lines-printed-to-screen
                  movem.l (SP)+,a1/d0-d1          ;Put back used registers
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
                  move.w  a6,d3                       ;set up d3 to contain the instruction to print
                  move.b  #4,d6                       ;Set up loop counter for subroutine, we're printing 4 bytes
                  jsr     printHexValuesFromD3        ;Print the address of the instruction we are processing
                  move.b  #tab,(a4)+                  ;add a tab

                  cmp.l   #0,d2                       ;If the long in d2 is negative, we've set the error bit
                  blt     invalidInstruction
                  bra     validInstruction
validInstruction
                   
invalidInstruction
                  move.l  #errorInstruction,(a4)+     ;Add 'DATA' to the good buffer for output
                  move.b  #tab,(a4)+                  ;add a tab

                  move.w  (a6),d3 
                  move.b  #4,d6                       ;Set up loop counter for subroutine, we're printing 4 bytes
                  jsr     printHexValuesFromD3        ;Print the invalid instruction code
                 
endPrintInstruction
                  move.b  #$00,(a4)+
                  movea.l a4,a1
                  move.b  #13,d0
                  trap    #15

                  rts

**************************************************************************
* END:            printInstruction                                         
**************************************************************************

**************************************************************************
* BEGIN:          printHexValuesFromD3
*
* Subroutine to print the Hex values stored in d3, the number of bytes (2 hex values)
* to be printed must be stored in d6, e.g move.b #2,d6 would print the 4 rightmost
* hex values stored in d3. 
**************************************************************************
printHexValuesFromD3
                  lsr.b   #4,d3                     ;push off rightmost hex character, so we can convert the leftmost char                      
                  jsr     hexToChar                                                                                                             
                  move.b  d3,(a4)+                  ;push char onto ouput buffer                                                                
                                                                                                                                                
                  move.b  (a6),d3                   ;get the second char of this byte                                                           
                  lsl.b   #4,d3                     ;push off the leftmost hex character, so we can convert the rightmost char                  
                  lsr.b   #4,d3                                                                                                                 
                  adda.w  #1,a2                     ;move to next byte of matrix                                                                
                  jsr     hexToChar                                                                                                             
                  move.b  d3,(a4)+                  ;push char onto ouput buffer                                                                

                  subi.b  #1,d6                     ;Subtract one from loop counter, until entire address has been printed 
                  cmp.b   #0,d6                     ;loop until we have put the whole instruction into good buffer
                  beq     endInstructionPrint       
                  bra     printHexValuesFromD3

endInstructionPrint
                  rts
                                                                                                                                                
**************************************************************************
* END:            printHexValuesFromD3                                         
**************************************************************************

**************************************************************************
* BEGIN:          hexToChar
*
* Subroutine to print current disassembled instruction in good buffer
**************************************************************************
hexToChar                                                                                                   
        cmp.b   #$9,d3                    ;Check if the char is a digit or                            
        ble     digitToAscii              ;convert the hex digit to a char                 
        bra     letterToAscii             ;convert the hex letter to a char
                                                                                                    
digitToAscii                                                                                               
        addi.b  #$30,d3                                                                  
        rts
                                                                                                              
letterToAscii                                                                                            
        addi.b  #$37,d3                                                                   
        rts



* Put variables and constants here

CR                EQU     $0D
LF                EQU     $0A
TAB               EQU     $09

asciiZeroInHex    EQU     $30
asciiNineInHex    EQU     $39
asciiAInHex       EQU     $41
asciiFInHex       EQU     $46
asciiCharToHex    EQU     $37   

errorInstruction  EQU     $44415441       ;ascii bits representing 'DATA'

inputError        dc.b    CR,LF
                  dc.b    'That is not a valid address register. Exiting Program!',CR,LF,CR,LF,0

getStartMsg       dc.b    CR,LF
                  dc.b    'Please enter the 4 digit hexadecimal start address of your assembled assembly: ',CR,LF,CR,LF,0

getEndMsg         dc.b    CR,LF
                  dc.b    'Please enter the 4 digit hexadecimal end address of your assembled assembly: ',CR,LF,CR,LF,0

continueMsg       dc.b    CR,LF
                  dc.b    'Please press enter to continue, or 0 to terminate the program.',CR,LF,CR,LF,0

feedMe            dc.b                                                                                     CR,LF 
                  dc.b    ' ************************************************************************ '    ,CR,LF
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

assembly          dc.b                                                                                      CR,LF
                  dc.b    ' ************************************************************************* '    ,CR,LF
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
