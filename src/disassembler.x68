*-----------------------------------------------------------
* Title      : 68K Disassembler
* Written by : Mem Opt-in
* Date       : 05-09-2012
* Description:
*-----------------------------------------------------------

                  ORG     $1000     



stack             EQU     $8000

************* Program code **************

start         move.b  #14,d0                  ;Display feedMe header
              lea     feedMe,a1
              trap    #15

              move.b  #14,d0                  ;Ask for the starting address of user's program
              lea     getStartMsg,a1
              trap    #15

              move.b  #2,d0                   ;Store the starting address of the users assembled program in a1
              trap    #15     
              move.l  (a1),d1 
              move.b  #4,d7                   ;Set up loop counter
              movem.l d1/d7,-(SP)             ;pass in chars and registers

              bra     charsToHex
              movea.l  d2,a6

              move.b  #14,d0                  ;Ask for the ending address of user's program
              lea     getEndMsg,a1
              trap    #15

     ;         move.b  #14,d0                  ;Ask for the ending address of user's program
     ;         lea     userStart,a1
     ;         trap    #15

     ;         move.b  #14,d0                  ;Ask for the ending address of user's program
     ;         lea     #userEnd,a1
     ;         trap    #15

;              move.b  #14,d0                  ;Ask for the ending address of user's program
;              move.l  userStart,d1
;              lea     d1,a1
;              trap    #15

                  move.b  #14,d0                  ;Display disassembled code
                  lea     assembly,a1
                  trap    #15

; This function requires that d7 be loaded with an integer representing the number of chars to convert
charsToHex   
              move.b  d1,d2                   ;Move this char into d2
              lsr.l   #8,d1                   ;Shift to be ready to read next char in d1
              bra     isValidAscii            ;Determines whether the inputed ascii is valid
              cmp.b   #asciiNineInHex,d2      ;Check if the char is a digit or
              ble     digitInD2ToHex          ;convert the char to actual value of digit
              ble     LetterInD2ToHex         ;convert the char to actual value of digit

nextChar
              rol.b   #8,d2                   ;Rotate bits to make room for next conversion
              sub.b   #1,d7                   ;Subtract one from the loop counter
              cmp.b   #0,d7
              bgt     charsToHex              ;Loop until we translate all 4 chars to hex
               
digitInD2ToHex
              movem.l d3-d5,-(SP)             ;save-off required registers
              subi.b   #asciiZeroInHex,d2
              movem.l (SP)+,d3-d5             ;bring back saved data registers
              bra     nextChar

LetterInD2ToHex
              subi.b   #asciiAInHex,d2
              bra     nextChar

isValidAscii  
              cmp.b   #asciiZeroInHex,d2       ;Check if the char is valid 
              blt     invalidAddress          ;If the char is less than '0', it isn't valid
              cmp.b   #asciiNineInHex,d2       ;Check if the char is valid 
              bgt     checkIsLessThanA        ;If the char is greater than '9', check if it is also less than 'A' 
              cmp.b   #asciiFInHex,d2          ;If the char is greater than 'F', it isn't valid
              bgt     invalidAddress
              rts 

checkIsLessThanA  
              cmp.b   #asciiAInHex,d2          ;Check if the first char is valid 
              blt     invalidAddress          ;If the char is greater than '9' and less than 'A', it isn't valid
              
invalidAddress
              move.b  #14,d0                  ;Ask for the starting address of user's program
              lea     inputError,a1
              trap    #15


end               SIMHALT                                       ; halt simulator
  
* Put variables and constants here

userStart         EQU     $4000
userEnd           EQU     $4002

CR                EQU     $0D
LF                EQU     $0A

asciiZeroInHex    EQU     $30
asciiNineInHex    EQU     $39
asciiAInHex       EQU     $41
asciiFInHex       EQU     $46

d1ToHex

d1ToAscii
              movem.l d2-d5,-(SP)         save-off required registers
              move    #14,d0              task number into D0
              lea     CR,a1             address of string
              trap    #15                 display return, linefeed
              movem.l (SP)+,d2-d5         bring back saved data registers
              rts                         return

inputError    dc.b    CR,LF
              dc.b    'That is not a valid address register, please enter a valid hexadecimal address.',CR,LF,CR,LF,0

getStartMsg   dc.b    CR,LF
              dc.b    'Please enter the 4 digit hexadecimal start address of your assembled assembly: ',CR,LF,CR,LF,0

getEndMsg     dc.b    CR,LF
              dc.b    'Please enter the 4 digit hexadecimal end address of your assembled assembly: ',CR,LF,CR,LF,0

feedMe        dc.b                                                                                     CR,LF 
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

assembly      dc.b                                                                                      CR,LF
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
