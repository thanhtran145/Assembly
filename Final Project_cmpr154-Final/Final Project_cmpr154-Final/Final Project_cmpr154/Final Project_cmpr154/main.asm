;------------------------------------------------------------
; main.asm is a the quiz game
; CMPR 154 - Fall 2024
; Team Name : Miyagi-Do
; Team Member Names: Thanh Tran, Christopher Vu, Joseph Jimenez, Daniel Contreras
; Creation Date: 11/13/2024
; Collaboration: None
;----------------------------------------------------------

INCLUDE Irvine32.inc

; Functions
showBanner proto
displayStats proto
guessingGame proto
addCredits proto
showMainMenu proto

.data

    balance DWORD 0          ; initial credits
    MAX_ALLOWED DWORD 20      ; max credits user can insert at a time
    amount DWORD 0      ; amount of credits entered by the user

    correctGuesses BYTE 0
    missedGuesses BYTE 0
    username BYTE 15 DUP(0)
    actualSize DWORD 0

    ;=================================================
    ;Main Menu Strings

    promptName BYTE "  *What is your name? ", 0
    invalidInputMsg BYTE "    *Invalid input, please try again:", 0

    bannerLine1 BYTE "======================== (MYAGI - DO) ==========================",0
    bannerLine2 BYTE "  ____               _                ____                      ",0
    bannerLine3 BYTE " / ___|_   _ ___ ___(_)_ __   __ _   / ___| __ _ _ __ ___   ___ ",0
    bannerLine4 BYTE "| |  _| | | / __/ __| | '_ \ / _` | | |  _ / _` | '_ ` _ \ / _ \",0
    bannerLine5 BYTE "| |_| | |_| \__ \__ \ | | | | (_| | | |_| | (_| | | | | | |  __/",0
    bannerLine6 BYTE " \____|\__,_|___/___/_|_| |_|\__, |  \____|\__,_|_| |_| |_|\___|",0
    bannerLine7 BYTE "                             |___/                              ",0
    bannerLine8 BYTE "================================================================",0

    mainMenuPrompt BYTE 0dH, 0ah, "          ** Menu ** ", 0dh, 0ah,
                              "     1: Display my available credit ",0dh, 0ah,
                              "     2: Add credits to my account ",0dh, 0ah,
                              "     3: Play the guessing game", 0dh, 0ah,
                              "     4: Display my statistics", 0dh, 0ah,
                              "     5: Exit Program", 0dh, 0ah, 0dh, 0ah,
                              "     Enter your option: ", 0



    ;==================================================
    ;Option One
    balanceMsg BYTE " Your available balance is: $", 0

    ;==================================================
    ;Option Two

    enterCreditAmount BYTE 0dh, 0ah," Please enter the amount you would like to add: $", 0
    maxCreditError BYTE  0dh, 0ah, " Error: Maximum allowable credit is $20.00", 0dh, 0ah, 0
    negativeCreditError BYTE 0dh, 0ah, " Error: Credit has to be positive", 0dh, 0ah, 0
    tryAgainMsg BYTE " Please enter a different amount and try again.", 0
    newBalanceMsg BYTE 0dh, 0ah, "   Your new balance: $", 0

    ;==================================================
    ;Option Three
    guessNumberPrompt BYTE " Please guess a number between 1 and 10: ", 0
    randomNum BYTE ?
    guessedNum BYTE ?
    winMsg1 BYTE 0ah, 0dh, "  Congratulations! You guessed the correct number!", 0ah, 0dh
    winMsg2 BYTE "  $2 were added to your account!", 0ah, 0ah, 0
    loseMsg1 BYTE 0ah, 0dh, "   The correct answer was ", 0
    loseMsg2 BYTE 0ah, "  You guessed wrong. Better luck next time!", 0ah, 0ah, 0
    playAgainPrompt BYTE 0dh, 0ah, 0dh, 0ah, "  Would you like to play again (y/n)? ", 0
    invalidResponseMsg BYTE "  Invalid answer, returning to main menu.", 0ah, 0
    noCreditsMsg BYTE "    You do not have enough credits to play the game. Returning to menu . . .", 0ah, 0ah, 0
    invalidInputError BYTE 0dh, 0ah, " You did not enter a valid input.", 0dh, 0ah, 0


    ;==================================================
    ;Option Four
    totalGames DWORD 0
    totalMoneyWon DWORD 0
    totalMoneyLost DWORD 0

    ;Strings for Option 4
    displayPlayerName BYTE "       **Player Name: ", 0
    displayAvailableCredit BYTE "Available Credit: ", 0
    statsHeader BYTE "Here are your statistics: ", 0ah, 0ah, 0
    gamesPlayedMsg BYTE "Games Played: ", 0
    correctGuessesMsg BYTE "Correct Guesses: ", 0
    missedGuessesMsg BYTE "Missed Guesses: ", 0.
    moneyWonMsg BYTE "Money Won: $", 0
    moneyLostMsg BYTE "Money Lost: $", 0

.code
main PROC

getUserProfile:
    call Clrscr
    ;Get user's name
    mov edx, OFFSET promptName
    call WriteString

    mov edx, OFFSET username
    mov ecx, SIZEOF username
    call ReadString
    mov actualSize, eax

    ;Condition for blank cases
    cmp actualSize, 0                                        ; Check if any characters were entered
    je   displayErrorMsg                                   ; Jump to error message if zero characters entered

    ;Go to main menu
    jmp mainMenuChoice

displayErrorMsg:                                           ; Display error if name is blank
        ; Display error message
        mov edx, OFFSET invalidInputError
        call WriteString
        call Crlf
        call WaitMsg                                       ; Waits for a key press before returning
        jmp getUserProfile                                 ; Loop profile 

mainMenuChoice:
    call showMainMenu                                      ; Display menu and get user input
    call ReadInt
    cmp eax, 5                                             ; Compare for exit option
    je exitProgram

    ; Switch statement for menu choices
    cmp eax, 1                                             ; Compare for 1st option
    je showBalance
    cmp eax, 2                                             ; Compare for 2nd option
    je addCreditsOption
    cmp eax, 3                                             ; Compare for 3rd option
    je playGuessingGame
    cmp eax, 4                                             ; Compare for 4th option
    je showStatistics

    jmp invalidMenuChoice                                  ; Default if none were selected

invalidMenuChoice:                                         ; Check for incorrect input
    mov edx, OFFSET invalidInputError
    call WriteString
    call Crlf
    call WaitMsg
    jmp mainMenuChoice

showBalance:                                               ; Display the available credits
    call Clrscr
    mov edx, OFFSET balanceMsg
    call WriteString
    mov eax,  balance
    call WriteDec

    call Crlf
    call Crlf
    call WaitMsg
    jmp mainMenuChoice                                     ; Go back to main menu

addCreditsOption:
    ; Insert coins, max 20 at a time
    call addCredits
    jmp mainMenuChoice

playGuessingGame:
    call Randomize                                         ; Play the guessing game
    call guessingGame
    jmp mainMenuChoice

showStatistics:
    call displayStats                                      ; Show statistics
    jmp mainMenuChoice

exitProgram:                                               ; Exit option
    invoke ExitProcess, 0

main ENDP


showBanner PROC
    Call Clrscr                                            ; Clear the screen

    mov edx, OFFSET bannerLine1                            ; Display banner line by line
    call WriteString
    call Crlf

    mov eax, red
    call setTextColor
    
    mov edx, OFFSET bannerLine2
    call WriteString
    call Crlf

    mov edx, OFFSET bannerLine3
    call WriteString
    call Crlf

    mov edx, OFFSET bannerLine4
    call WriteString
    call Crlf

    mov edx, OFFSET bannerLine5
    call WriteString
    call Crlf

    mov edx, OFFSET bannerLine6
    call WriteString
    call Crlf

    mov edx, OFFSET bannerLine7
    call WriteString
    call Crlf

    mov eax, white
    call setTextColor

    mov edx, OFFSET bannerLine8
    call WriteString
    call Crlf

    ret
showBanner ENDP



showMainMenu PROC                                          ; Display menu function
    call showBanner
    mov edx, OFFSET mainMenuPrompt
    call WriteString
    ret
showMainMenu ENDP

;==================================================
;Option Two

addCredits PROC                                            ; Add credits to the balance
    call Clrscr
    mov edx, OFFSET enterCreditAmount
    call WriteString
    call ReadInt

    jno GoodInput                                          ; Check Overflow
    jmp AskForAmount

GoodInput:
    mov amount, eax

CheckAmount:                                               ; Check amount added for limit
    mov eax, amount
    cmp eax, MAX_ALLOWED
    jg AmountExceedsMax
    cmp eax, 0

    jl AmountNegative
    jmp AmountOk
    

AmountExceedsMax:                                          ; Display error when exceeded the limit
    mov edx, OFFSET maxCreditError
    call WriteString
    jmp AskForAmount

AmountNegative:                                            ; Display error when the limit is less than 0
    mov edx, OFFSET negativeCreditError
    call WriteString
    jmp AskForAmount

BalanceExceedLimit:
    mov edx, OFFSET maxCreditError
    call WriteString
    call Crlf
    call WaitMsg
    ret

AmountOk:                                                  ; If the amount is okay, update the available balance
    mov eax,  balance
    add eax, amount
    cmp eax, MAX_ALLOWED 
    jg BalanceExceedLimit                                   ; If the amount is larger 

    mov  balance, eax
    mov edx, OFFSET newBalanceMsg
    call WriteString
    mov eax,  balance
    call WriteDec

    call Crlf
    call Crlf
    call WaitMsg
    ret                                                     ; Return to the main menu

AskForAmount:                                              ; Ask for the amount to add if error
    call Crlf   
    mov edx, OFFSET tryAgainMsg
    call WriteString
    call ReadInt
    mov amount, eax
    call Crlf   
    ret                                                     ; Return to the main menu

addCredits ENDP

;==================================================
;Option Three

guessingGame PROC
    call Clrscr
    cmp balance, 0                                          ; Check if the balance is zero 
    je notAllowed

    add totalGames, 1                                       ; Keep track of the number of games played
    sub balance, 1                                          ; Subtract 1 from the user's balance for each game

    mov edx, OFFSET guessNumberPrompt                       ; Ask the user to choose a random number
    call WriteString
    call ReadInt
    test eax, eax                                           ; Check if any characters were entered
    jz   displayErrorMsg                                    ; Jump to error message if zero characters entered

    cmp eax, 10                                             ; Bound Check
    jg displayErrorMsg                                        

    cmp eax, 1
    jl displayErrorMsg
    

    mov guessedNum, al

    mov eax, 9                                              ; Set a range of 9 and randomize according to the time
    call Randomize
    call RandomRange

    add al, 1                                               ; Modify the range from 0-9 to 1-10
    cmp al, guessedNum
    je winner                                               ; Compare the user's number to the random number
    jne loser                                                   


winner:                                                     ; If the user guesses the correct number
    mov edx, OFFSET winMsg1
    call WriteString
  
    add correctGuesses, 1                                       ; Record the data for the win
    add totalMoneyWon, 2
    add balance, 2
    jmp playAgainChoice                                     ; Prompt to play again


loser:                                                      ; If the user guesses incorrectly
    add missedGuesses, 1
    add totalMoneyLost, 1
    mov edx, OFFSET loseMsg1
    call WriteString
    add ebx, 0
    call WriteDec                                           ; Write correct number
    call Crlf
    jmp playAgainChoice                                     ; Prompt to play again


displayErrorMsg:                                            ; Display error if input is blank
    add balance, 1
    mov edx, OFFSET invalidInputError                       ; Display error message
    call WriteString
    call Crlf
    call WaitMsg                                            ; Waits for a key press before returning
    jmp playAgainChoice                                     ; Prompt to play again


notAllowed:                                                 ; If the user's balance is 0
    call Crlf
    mov edx, OFFSET noCreditsMsg
    call Crlf
    call WriteString
    call WaitMsg
    ret                                                     ; Return to main menu
    
playAgainChoice:                                            ; Prompt to play again
    mov edx, OFFSET playAgainPrompt
    call WriteString

    ; Read user input
    call ReadChar
    call WriteChar
    call Crlf

    test al, 0                                              ; Check if any characters were entered
    call Crlf
    jz   displayErrorMsg                                    ; Jump to error message if zero characters entered
    call Crlf

    ; If the input is not y or n, the program jumps back to the main menu
    cmp al, 'y'                                             ; Continue if yes
    je guessingGame

    cmp al, 'n'                                             ; Return to menu if no
    jne invalidMenuChoice
    call WaitMsg                                            ; Waits for a key press before returning
    call Crlf
    ret

invalidMenuChoice:
    je  displayErrorMsg
    jmp playAgainChoice

guessingGame ENDP

;==================================================
;Option Four

displayStats PROC
    call Clrscr
    mov edx, OFFSET statsHeader                             ; Print the header
    call WriteString

    mov edx, OFFSET displayPlayerName                       ; Display Player Name
    call WriteString
    mov edx, OFFSET username
    call WriteString

    call Crlf
    mov edx, OFFSET displayAvailableCredit                  ; Display Available Credit
    call WriteString
    mov eax, balance
    call WriteDec

    call Crlf
    mov edx, OFFSET gamesPlayedMsg                          ; Display Games Played
    call WriteString
    mov eax, totalGames
    call WriteDec

    call Crlf
    mov edx, OFFSET correctGuessesMsg                       ; Display Correct Guesses
    call WriteString
    movzx eax, correctGuesses
    call WriteDec

    call Crlf
    mov edx, OFFSET missedGuessesMsg                        ; Display Missed Guesses
    call WriteString
    movzx eax, missedGuesses
    call WriteDec

    call Crlf
    mov edx, OFFSET moneyWonMsg                             ; Display Money Won
    call WriteString
    mov eax, totalMoneyWon
    call WriteDec

    call Crlf
    mov edx, OFFSET moneyLostMsg                            ; Display Money Lost
    call WriteString
    mov eax, totalMoneyLost
    call WriteDec

    call Crlf
    call Crlf                                              ; Return to the main menu
    call WaitMsg                                           ; Waits for a key press before returning
    ret

displayStats ENDP

END main