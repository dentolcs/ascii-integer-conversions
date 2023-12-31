TITLE Designing low-level I/O Procedures     (Proj6_tolentid.asm)

; Author: Denyse Tolentino
; Last Modified: 12/10/2023
; OSU email address: tolentid@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 12/10/2023
; Description: Program asks user to enter 10 valid signed integers (user will be re-prompted if input is invalid), 
;			   displays the entered numbers, displays the sum, and displays the average.

INCLUDE Irvine32.inc

;--------------------------------------------------------------------------------------------------------
; Name: mGetString
;
; Prompts user to enter a string of characters and saves it into given memory address.
;		Length of characters entered by user is also saved into another given memory address.
;
; Preconditions:		buffer and prompt are type BYTE, bufferSize is an integer, bytesRead is type DWORD.
;
; Postconditions:		none.
;
; Receives: 
;		prompt			= address of prompt to display to user
;		buffer			= address to store user input
;		bufferSize		= positive integer that specifies maximum number of characters allowed in user input
;		bytesRead		= number of characters from user input
;
; Returns: 
;		buffer			= address of user input
;		bytesRead		= number of characters from user input
;--------------------------------------------------------------------------------------------------------
mGetString MACRO prompt, buffer, bufferSize, bytesRead
	push	eax
	push	ecx
	push	edx
	
	mov		edx, prompt
	call	WriteString					; display prompt
	mov		edx, buffer
	mov		ecx, bufferSize
	call	ReadString					; get user input
	mov		bytesRead, eax

	pop		edx
	pop		ecx
	pop		eax
ENDM



;--------------------------------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays string from given address.
;
; Preconditions: given address is a reference to a string.
;
; Postconditions: none.
;
; Receives: 	
;		string		= address of string to print
;
; Returns: none.
;--------------------------------------------------------------------------------------------------------
mDisplayString MACRO string
	push	edx
	
	mov		edx, string
	call	WriteString					; display string

	pop		edx
ENDM

MAX_INPUT_SIZE		= 13
ASCII_START_NUM		= 48

.data
header			BYTE	"Designing low-level I/O Procedures		Programmed by Denyse Tolentino",13,10,0
intro			BYTE	"Please provide 10 signed decimal integers.",13,10,
						"Each number needs to be small enough to fit inside a 32 bit register.",13,10,
						"After you have finished inputting the raw numbers I will display a list of the integers,",13,10,
						"their sum, and their average value.",13,10,0
getNumPrompt	BYTE	"Please enter a signed number: ",0
errorPrompt		BYTE	13,10,"ERROR: You did not enter an signed number or your number was too big.",13,10,
						"Please try again: ",0
userInput		BYTE	13 DUP(?)
byteCount		DWORD	?
userVal			SDWORD	0
numString		BYTE	12 DUP(?)
numArr			SDWORD	10 DUP(?)
spacer			BYTE	", ",0
numsMsg			BYTE	"You entered the following numbers: ",13,10,0
sumMsg			BYTE	"The sum of these numbers is: ",0
avgMsg			BYTE	"The truncated average is: ",0
sum				SDWORD  ?
avg				SDWORD  ?
bye				BYTE	13,10,"Thanks for trying it out. Byeeeeee",13,10,0

.code
main PROC
;--------------------------------------------------------------------------------------------------------
; Display header and introduction using mDisplayString macro.
;--------------------------------------------------------------------------------------------------------
	mDisplayString offset header
	call	Crlf
	mDisplayString offset intro
	call	Crlf

;--------------------------------------------------------------------------------------------------------
; Asks user for 10 valid signed decimal integers using ReadVal procedure and stores them in an array.
;		ReadVal ensures user inputs are valid and converts user input into SDWORD numerical value.
;--------------------------------------------------------------------------------------------------------
	mov		ecx, 10						; set up counter
	mov		edi, offset numArr			; store starting address of num array to edi
_getNum:
	push	offset getNumPrompt
	push	offset errorPrompt
	push	offset userInput
	push	offset byteCount
	push	offset userVal
	call	ReadVal						; get user input and convert string input to numerical value
_insertInArr:
	mov		eax, userVal				; store result from ReadVal
	mov		[edi], eax					; add result to array
	add		edi, 4						; go to next element in num array
	dec		ecx
	cmp		ecx, 0						; check if counter is finished
	jg		_getNum
	call	Crlf

;--------------------------------------------------------------------------------------------------------
; Display user input of 10 signed decimal integers using WriteVal procedure and mDisplayString macro.
;--------------------------------------------------------------------------------------------------------
	mDisplayString offset numsMsg		; let user know that their inputs are being displayed
	mov		ecx, 10						; set up counter
	mov		esi, offset numArr			; store starting address of num array to esi
_displayNumArr:
	push	offset numString
	push	[esi]
	call	WriteVal					; convert numerical value to string and display string
	add		esi, 4						; go to next numerical value in num array
	dec		ecx
	cmp		ecx, 0						; check if counter is finished
	je		_getSum
	mDisplayString offset spacer		; format with commas and spacing
	jmp		_displayNumArr

;--------------------------------------------------------------------------------------------------------
; Calculates and displays sum of user inputs using WriteVal procedure and mDisplayString macro.
;--------------------------------------------------------------------------------------------------------
_getSum:
	call	Crlf
	mDisplayString offset sumMsg		; let user know that the sum is being displayed
	mov		ecx, 10						; set up counter
	mov		esi, offset numArr			; store starting address of num array to esi
	mov		eax, 0
_calculateSum:	
	add		eax, [esi]					; add each number to eax
	add		esi, 4						; go to next number in array
	dec		ecx
	cmp		ecx, 0						; check counter
	jg		_calculateSum
	mov		sum, eax					; store sum
_displaySum:
	push	offset numString
	push	sum
	call	WriteVal					; convert sum to string and display string
	call	Crlf

;--------------------------------------------------------------------------------------------------------
; Calculates and displays average of user inputs using WriteVal procedure and mDisplayString macro.
;--------------------------------------------------------------------------------------------------------
	mDisplayString offset avgMsg		; let user know that the sum is being displayed
_calculateAvg:
	mov		eax, sum					; copy sum into eax
	mov		ebx, 10						; use ebx as divisor
	cdq									; sign-extend for idiv
	idiv	ebx
	mov		avg, eax					; store truncated average (quotient only)
_displayAvg:
	push	offset numString
	push	avg
	call	WriteVal					; convert average to string and display string
	call	Crlf

;--------------------------------------------------------------------------------------------------------
; Display farewell message using mDisplayString macro.
;--------------------------------------------------------------------------------------------------------
	mDisplayString offset bye


	Invoke ExitProcess,0	; exit to operating system
main ENDP



;--------------------------------------------------------------------------------------------------------
; Name: ReadVal
;
; Prompts user to enter a signed decimal number that fits into a 32-bit register using mGetString macro. 
;		Validates user input and re-prompts user if user input is invalid. Converts user input of
;		string ASCII digits to its numerical value representation using string primitives. Numerical
;		value is stored in a memory variable.
;		 
; Preconditions: user input is a signed decimal number that fits into a 32-bit register.
;		prompts are type BYTE that contain strings. memory variable for user input is type BYTE.
;		memory variable for length of user input is type DWORD. memory variable for numerical
;		value is type SDWORD.
;
; Postconditions: none.
;
; Receives: 
;		[ebp + 24]		= initial prompt for mGetString
;		[ebp + 20]		= error prompt for mGetString
;		[ebp + 16]		= memory address to store user input
;		[ebp + 12]		= memory address to store length of user input
;		[ebp + 8]		= memory address to store numerical value 
;		
; Returns: stores numerical value in memory address pointed to by [ebp + 8] (before ret)	
;--------------------------------------------------------------------------------------------------------
ReadVal	PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	esi

; prompt for user input
	mGetString [ebp + 24], [ebp + 16],	MAX_INPUT_SIZE, [ebp + 12]
	jmp		_validateUserInput

; display error prompt and get user input
_getUserInput:
	mGetString [ebp + 20], [ebp + 16],	MAX_INPUT_SIZE, [ebp + 12]

; check that user input is a valid number
_validateUserInput:	
	mov		eax, [ebp + 12]				; store length of user input in eax
	cmp		eax, 12						; input is invalid if length of user input is more than 11 (1 sign, 10 digits = 11 characters max)
	jge		_getUserInput
	cmp		eax, 0						; no input is invalid
	je		_getUserInput

; set up registers to convert user input
	mov		edi, [ebp + 8]				; store memory address for numerical value in edi
	mov		SDWORD PTR [edi], 0
	mov		ebx, 1						; use ebx as sign indicator, positive sign is default
	mov		esi, [ebp + 16]				; store starting memory address of user input in esi
	mov		ecx, [ebp + 12]				; use ecx as counter = length of input

; check if first character is a sign
_checkIfPos:
	cld
	lodsb
	cmp		al, 43						; check if positive sign '+'
	je		_indicatePos

_checkIfNeg:
	cmp		al, 45						; check if negative sign '-'
	jne		_checkIfNum

_indicateNeg:
	mov		ebx, -1						; change ebx to -1 to indicate negative number
	lodsb								; move forward since first character has been processsed
	dec		ecx							
	cmp		ecx, 0						; check that there are characters after the sign
	je		_getUserInput				; invalid input if there are no characters after the sign
	jmp		_checkIfNum

_indicatePos:
	mov		ebx, 1
	lodsb								; move forward since first character has been processsed
	dec		ecx
	cmp		ecx, 0						; check that there are characters after the sign
	je		_getUserInput				; invalid input if there are no characters after the sign

; check and convert each character to number
_checkIfNum:
	cmp		al, 48						; check if character's ascii code is below ascii code range for digits
	jl		_getUserInput
	cmp		al, 57						; check if character's ascii code is above ascii code range for digits
	jg		_getUserInput				

	sub		al, ASCII_START_NUM			; subtract 48 from character to get corressponding digit
	imul	bl							; make sure digit has correct sign
	movsx	eax, ax	
	push	eax							; save digit to stack
	push	ebx							; save sign to stack
	mov		ebx, 10
	mov		eax, [edi]					; copy current number in eax 
	imul	ebx							; multiply current number by 10 to shift decimal place to the right
	jo		_getUserInput
	mov		[edi], eax					; store product back into memory variable 
	pop		ebx
	pop		eax							
	add		[edi], eax					; add digit to current number in memory variable
	jo		_getUserInput

	mov		eax, 0						; reset eax for next character
	dec		ecx
	cmp		ecx, 0						; check if finished
	je		_finished

	cld
	lodsb								; go to next character in string
	jmp		_checkIfNum

_finished:
	pop		esi
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	ret		20
ReadVal ENDP


;--------------------------------------------------------------------------------------------------------
; Name: WriteVal
;
; Displays given numerical value using mDisplayString macro by converting numerical value to 
;		string of ASCII digits.
;
; Preconditions: 
;
; Postconditions: array to store string output is type BYTE and has sizeof 11 at minimum.
;		numerical value is type SDWORD.
;
; Receives: 
;		[ebp + 12]		= starting address or array to store string
;		[ebp + 8]		= numerical value
;
; Returns: none.
;--------------------------------------------------------------------------------------------------------
WriteVal	PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	esi

	mov		ebx, 10						; use ebx as divisor
	mov		ecx, 0						; use ecx as counter for number of digits
	mov		edi, [ebp + 12]				; store starting address of array for string output in edi
	; check if negative
	mov		eax, [ebp + 8]				; store numerical value in eax
	cmp		eax, 0
	jl		_indicateNeg				; check if numerical value is negative
	jmp		_convertToASCII

_indicateNeg:
	push	eax							; save numerical value to stack
	mov		al, 45						; add negative sign '-' to string array
	cld
	stosb
	pop		eax							; restore numerical value to eax
	neg		eax							; convert numerical value in eax to positive

; convert each number to ascii digit
_convertToASCII:
	mov		edx, 0						; clear edx for div
	div		ebx							; divide by 10 to isolate right-most digit
	add		edx, ASCII_START_NUM		; edx contains remainder = rihgt-most digit, add 48 to get ascii digit
	push	edx							; push ascii digit to stack (so it can pop back in correct order when done)
	inc		ecx							; increase counter
	cmp		eax, 0						; check if there are still numbers to convert
	jg		_convertToASCII

_fillNumString:
	pop		eax							; pop each ascii digit into eax
	cld
	stosb								; copy ascii digit to string array
	dec		ecx
	cmp		ecx, 0						; check counter
	jg		_fillNumString

_insertNull:
	mov		al, 0						; insert null-terminator
	stosb
	
	mDisplayString [ebp + 12]			; display string of ascii digits

	pop		esi
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	ret		8
WriteVal ENDP

END main
