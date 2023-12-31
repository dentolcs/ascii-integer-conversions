# ascii-integer-conversions

## Description

Program asks user to enter 10 valid signed integers (user will be re-prompted if input is invalid), displays the entered numbers, 
displays the sum, and displays the average. Valid input ranges from -2147483648 and 2147483647 since the input must fit into a 
32-bit register.

User-entered numbers are converted from ASCII characters to SDWORD numerical values before calculations and converted back
to ASCII characters before displaying them to the user.

### Macros

`mGetString`: Prompts user to enter a string of characters.
            
`mDisplayString`: Displays a string.

### Procedures

`ReadVal`: Prompts user to enter a number until user-input is valid. Converts user-input of ASCII characters into a numerical value.

`WriteVal`: Displays numerical value by converting it to ASCII characters.



