*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Mem Opt-in
* Date       : 05-09-2012
* Description:
*-----------------------------------------------------------

                  ORG     $1000     

stack             EQU     $8000

************* Program code **************

start             move.b  #14,d0                  ;Display feedMe header
                  lea     feedMe,a1
                  trap    #15

                  move.b  #14,d0                  ;Ask for the starting address of user's program
                  lea     getStartMsg,a1
                  trap    #15

                  movea.l #0000,a1
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

                  movea.l #0000,a1
                  move.b  #2,d0                   ;Store the starting address of the users assembled program in a1
                  trap    #15     
                  move.l  (a1),d1 
                  move.b  #4,d7                   ;Set up loop counter

                  jsr     charsToHex              ;Convert ascii to hex
                  swap    d3
                  movea.l d3,a5                   ;Store end address in a5 

                  move.b  #14,d0                  ;Display disassembled code
                  lea     assembly,a1
                  trap    #15


processNextInstruction   
;Check if we need to scroll the screen         
;convert line good buffer from hex to ascii and write to STD OUT 
;Clear good buffer 
;Check if we have reached the end of the test program 
;If so, prompt for next memory location
;Write next instruction address to good buffer 

******************  START OP-CODE HERE ***************************
; Determine Opcode, write hex value to good buffer


******************  START EA CODE HERE ***************************
; Determine EA (and Data), write hex values to good buffer 



finished                                  ; branch for end of program
                  SIMHALT                 ; halt simulator
 
**************************************************************************
*BEGIN:         charsToHex
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
*END:         charsToHex
**************************************************************************
               


**************************************************************************
*BEGIN:         isValidAscii
*         Subroutine to verify valid hex in ascii                                          
*    Non-hex addresses are not supported, end program if encountered
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
*END:         isValidAscii                                          
**************************************************************************




* Put variables and constants here

CR                EQU     $0D
LF                EQU     $0A

asciiZeroInHex    EQU     $30
asciiNineInHex    EQU     $39
asciiAInHex       EQU     $41
asciiFInHex       EQU     $46
asciiCharToHex    EQU     $37   

inputError        dc.b    CR,LF
                  dc.b    'That is not a valid address register. Exiting Program!',CR,LF,CR,LF,0

getStartMsg       dc.b    CR,LF
                  dc.b    'Please enter the 4 digit hexadecimal start address of your assembled assembly: ',CR,LF,CR,LF,0

getEndMsg         dc.b    CR,LF
                  dc.b    'Please enter the 4 digit hexadecimal end address of your assembled assembly: ',CR,LF,CR,LF,0

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
