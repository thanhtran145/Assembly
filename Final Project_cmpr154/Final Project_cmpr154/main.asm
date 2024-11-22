;------------------------------------------------------------
; main.asm is a the quiz game
; CMPR 154 - Fall 2024
; Team Name : Miyagi-Do
; Team Member Names: Thanh Tran, Christopher Vu, Joseph Jimenez, Daniel Contreras
; Creation Date: 11/13/2034
; Collaboration: None
;----------------------------------------------------------

INCLUDE Irvine32.inc

; Functions
DisplayBanner proto
DisplayStats proto
GuessingGame proto
AddCredits proto
DisplayMenu proto

.data

    balance DWORD 0          ; initial credits
    MAX_ALLOWED DWORD 20     ; max credits user can insert at a time
    amount DWORD 0           ; amount of credits that is entered by the users

    correctGuesses BYTE 0
    missedGuesses BYTE 0
    username BYTE 15 DUP(0)
    actualSize DWORD 0

    ;=================================================
    ;Main Menu Strings

    askName BYTE "  *What is your name? ", 0
    badPrompt BYTE "    *Invalid input, please try again:", 0

    line1 BYTE "======================== (MYAGI - DO) ==========================",0
    line2 BYTE "  ____               _                ____                      ",0
    line3 BYTE " / ___|_   _ ___ ___(_)_ __   __ _   / ___| __ _ _ __ ___   ___ ",0
    line4 BYTE "| |  _| | | / __/ __| | '_ \ / _` | | |  _ / _` | '_ ` _ \ / _ \",0
    line5 BYTE "| |_| | |_| \__ \__ \ | | | | (_| | | |_| | (_| | | | | | |  __/",0
    line6 BYTE " \____|\__,_|___/___/_|_| |_|\__, |  \____|\__,_|_| |_| |_|\___|",0
    line7 BYTE "                             |___/                              ",0
    line8 BYTE "================================================================",0

    menuPrompt BYTE 0dH, 0ah, "           *** Menu *** ", 0dH, 0ah,
                              "     1: Display my available credit ",0dh, 0ah,
                              "     2: Add credits to my account ",0dh, 0ah,
                              "     3: Play the guessing game", 0dh, 0ah,
                              "     4: Display my statistics", 0dh, 0ah,
                              "     5: Exit Program", 0dh, 0ah, 0dh, 0ah,
                              "     Enter your option: ", 0



    ;==================================================
    ;Option One
    availableBalance BYTE " Your available balance is: $", 0

    ;==================================================
    ;Option Two

    EnterAmount BYTE 0dH, 0ah," Please enter the amount you would like to add: $", 0
    MaxError BYTE  0dh, 0ah, " Error: Maximum allowable credit is $20.00", 0dh, 0ah, 0
    NegativeError BYTE 0dh, 0ah, " Error: Credit has to be positive", 0dh, 0ah, 0
    TryAgain BYTE " Please enter a different amount and try again.", 0
    NewBalance BYTE 0dh, 0ah, "   Your new balance: $", 0

    ;==================================================
    ;Option Three
    chooseNumber BYTE " Please guess a number between 1 and 10: ", 0
    generatedNumber BYTE ?
    chosenNumber BYTE ?
    winnerText1 BYTE 0ah, 0dh, "  Congratulations! You guessed the correct number!", 0ah, 0dh
    winnerText2 BYTE "  $2 were added to your account!", 0Ah, 0Ah, 0
    loserText1 BYTE 0ah, 0dh, "   The correct answer was ", 0
    loserText2 BYTE 0ah, "  You guessed wrong. Better luck next time!", 0ah, 0ah, 0
    playAgain BYTE 0dh, 0ah, 0dh, 0ah, "  Would you like to play again (y/n)? ", 0
    invalidGoReturn BYTE "  Invalid answer, returning to main menu.", 0ah, 0
    noCredits BYTE "    You do not have enough credits to play the game. Returning to menu . . .", 0Ah, 0Ah, 0
    errorMsg BYTE 0dh, 0ah, " You did not enter a valid input.", 0dh, 0ah, 0


    ;==================================================
    ;Option Four
    ; Existing data definitions...
    gamesPlayed DWORD 0
    moneyWon DWORD 0
    moneyLost DWORD 0

    ;Strings for Option 4
    playerName BYTE "       **Player Name: ", 0
    availableCreditLabel BYTE "Available Credit: ", 0
    statisticsHeader BYTE "Here are your statistics: ", 0Ah, 0Ah, 0
    gamesPlayedLabel BYTE "Games Played: ", 0
    correctGuessesLabel BYTE "Correct Guesses: ", 0
    missedGuessesLabel BYTE "Missed Guesses: ", 0.
    moneyWonLabel BYTE "Money Won: $", 0
    moneyLostLabel BYTE "Money Lost: $", 0

.code
main PROC

profile:
    call Clrscr
    ;Get user's name
    mov edx, OFFSET askName
    call WriteString

    mov edx, OFFSET username
    mov ecx, SIZEOF username
    call ReadString
    mov actualSize,eax

    ;Condition for blank cases
    cmp actualSize, 0                                        ; Check if any characters were entered
    je   displayError                                        ; Jump to error message if zero characters entered

    ;Go to main menu
    jmp choice

displayError:                                                ; Display error if name is blank
        ; Display error message
        mov edx, OFFSET errorMsg
        call WriteString
        call Crlf
        call WaitMsg ; Waits for a key press before returning
        jmp profile                                          ; Loop profile 

choice:
    call DisplayMenu                                        ; Display menu and get user input
    call ReadInt
    cmp eax, 5                                              ; Compare for exit option
    je done

    ; Switch statement for menu choices
    cmp eax, 1                                              ; Compare for 1st option
    je DisplayCredits
    cmp eax, 2                                              ; Compare for 2nd option
    je InsertCoin
    cmp eax, 3                                              ; Compare for 3rd option
    je PlayGame
    cmp eax, 4                                              ; Compare for 4th option
    je ShowStats

    jmp default                                             ; Default if none were selected

default:
    je   displayError
    jmp choice

DisplayCredits:                                             ; Display the avaliable credits
    call Clrscr
    mov edx, OFFSET availableBalance
    call WriteString
    mov eax, balance
    call WriteDec

    call Crlf
    call Crlf
    call WaitMsg
    jmp choice                                              ; Go back to main menu

InsertCoin:
    ; Insert coins, max 20 at a time
    call AddCredits
    jmp choice

PlayGame:
    call Randomize                                          ; Play the guessing game
    call GuessingGame
    jmp choice

ShowStats:
    call DisplayStats                                       ; Show statistics
    jmp choice

done:                                                       ; Exit option
    invoke ExitProcess, 0

main ENDP


DisplayBanner PROC
    Call CLrScr                                             ; Clear the screen

    mov edx, OFFSET line1                                   ; Display banner line by line
    call WriteString
    call Crlf

    mov eax, red
    call setTextColor
    
    mov edx, OFFSET line2
    call WriteString
    call Crlf

    mov edx, OFFSET line3
    call WriteString
    call Crlf

    mov edx, OFFSET line4
    call WriteString
    call Crlf

    mov edx, OFFSET line5
    call WriteString
    call Crlf

    mov edx, OFFSET line6
    call WriteString
    call Crlf

    mov edx, OFFSET line7
    call WriteString
    call Crlf

    mov eax, white
    call setTextColor

    mov edx, OFFSET line8
    call WriteString
    call Crlf

    ret
DisplayBanner ENDP



DisplayMenu PROC                                             ; DisplayMenu display menu function
    call DisplayBanner
    mov edx, OFFSET menuPrompt
    call WriteString
    ret
DisplayMenu ENDP

;==================================================
;Option Two

AddCredits PROC                                              ; AddCredits add credits into the balance
    call Clrscr
    mov edx, OFFSET EnterAmount
    call WriteString
    call ReadInt

    jno GoodInput                                            ; Check Overflow
    jmp AskForAmount

GoodInput:
    mov amount, eax

CheckAmount:                                                 ; Check amount added for limit
    mov eax, amount
    cmp eax, MAX_ALLOWED
    jg AmountExceedsMax
    cmp eax, 0

    jl AmountNegative
    jmp AmountOk
    

AmountExceedsMax:                                            ; Display error when exceeded the limit
    mov edx, OFFSET MaxError
    call WriteString
    jmp AskForAmount

AmountNegative:                                              ; Display error when the limit is less then 0
    mov edx, OFFSET NegativeError
    call WriteString
    jmp AskForAmount

BalanceExceedLimit:
    mov edx, OFFSET MaxError
    call WriteString
    call Crlf
    call WaitMsg
    ret

AmountOk:                                                    ; If the amount is okay we write to the avaliable balance
    mov eax, balance
    add eax, amount
    cmp eax, MAX_ALLOWED
    jg BalanceExceedLimit                                    ; If the amount is larger 

    mov balance, eax
    mov edx, OFFSET NewBalance
    call WriteString
    mov eax, balance
    call WriteDec

    call Crlf
    call Crlf
    call WaitMsg
    ret                                                       ; Return to the main menu

AskForAmount:  ; Ask for the amount to add if error
    call Crlf   
    mov edx, OFFSET TryAgain
    call WriteString
    call ReadInt
    mov amount, eax
    call Crlf   
    ret                                                       ; Return to the main menu

AddCredits ENDP

;==================================================
;Option Three

GuessingGame PROC
    call Clrscr
    cmp balance, 0                                                              ; Check for the balance is equal zero 
    je notAllowed

    add gamesPlayed, 1                                                          ; Keep track of the amount of games played
    sub balance, 1                                                              ; Subtract the user,s balance by 1 every game

    mov edx, OFFSET chooseNumber                                                ; Ask the user to choose a random number, and allow them to type in a number
    call WriteString
    call Readint
    test eax, eax                                                               ; Check if any characters were entered
    jz   displayError                                                           ; Jump to error message if zero characters entered

    cmp eax, 10                                                                 ; Bound Check
    jg displayError                                                            

    cmp eax, 1
    jl displayError
    

    mov chosenNumber, al

    mov eax, 9                                                                  ; Set a range of 9 and randomize occording to the time
    call Randomize
    call RandomRange

    add al, 1                                                                   ; Add 1 to the range to modify the range from 0-9 into 1-10
    cmp al, chosenNumber
    je winner                                                                   ; Compare the user's number to the random generated number
    jne loser                                                   


    winner :                                                                    ; Jump to this loop if the user guesses the correct number
    mov edx, OFFSET winnerText1
    call WriteString
  
    add correctGuesses, 1                                                       ; Record the data for the win
    add moneyWon, 2
    add balance, 2
    jmp playAgainChoice                                                         ; Prompt to play again


    loser :                                                                     ; Jump to this loop if the user guesses incorrectly
    add missedGuesses, 1
    add moneyLost, 1
    mov edx, OFFSET loserText1
    call WriteString
    add ebx, 0
    call WriteDec                                                               ; Write correct number
    call Crlf
    jmp playAgainChoice                                                         ; Prompt to play again


    displayError:                                                               ; Display number if the number is blank
        add balance, 1
        mov edx, OFFSET errorMsg                                                ; Display error message
        call WriteString
        call Crlf
        call WaitMsg                                                            ; Waits for a key press before returning
        jmp playAgainChoice                                                    ; prompt to play again


    notAllowed :                                                                ; Jump to this loop if the user's balance is 0
        call Crlf
        mov edx, OFFSET noCredits
        call Crlf
        call WriteString
        call WaitMsg
        ret                                                                     ; return to main menu
        
    
    playAgainChoice :                                                           ; Jump to this loop once the user has completed the game
        mov edx, OFFSET playAgain
        call WriteString


        ;Record the user's input and compare in order to determine if the game will be replayed
        ; Read user input
        call ReadChar
        call WriteChar
        call Crlf

        test al, 0                                                             ; Check if any characters were entered
        call Crlf
        jz   displayError                                                       ; Jump to error message if zero characters entered
        call Crlf



        ;If the input is not y or n ;, the program automatically jumps back to the main menu
        cmp al, 'y';                                                            ; continue if yes
        je GuessingGame

        cmp al, 'n';                                                            ; return to menu if no
        jne default
        call WaitMsg                                                            ; Waits for a key press before returning
        call Crlf
        ret

        default:
        je  displayError
        jmp playAgainChoice

GuessingGame ENDP

;==================================================
;Option Four

DisplayStats PROC
    call Clrscr
    mov edx, OFFSET statisticsHeader                                            ; Print the header
    call WriteString

    mov edx, OFFSET playerName                                                  ; Display Player Name
    call WriteString
    mov edx, OFFSET username
    call WriteString

    call Crlf
    mov edx, OFFSET availableCreditLabel                                        ; Display Available Credit
    call WriteString
    mov eax, balance                                                            ;
    call WriteDec

    call Crlf
    mov edx, OFFSET gamesPlayedLabel                                            ; Display Games Played
    call WriteString
    mov eax, gamesPlayed
    call WriteDec

    call Crlf
    mov edx, OFFSET correctGuessesLabel                                         ; Display Correct Guesses
    call WriteString
    movzx eax, correctGuesses
    call WriteDec

    call Crlf
    mov edx, OFFSET missedGuessesLabel                                          ; Display Missed Guesses
    call WriteString
    movzx eax, missedGuesses
    call WriteDec

    call Crlf
    mov edx, OFFSET moneyWonLabel                                               ; Display Money Won
    call WriteString
    mov eax, moneyWon
    call WriteDec

    call Crlf
    mov edx, OFFSET moneyLostLabel                                              ; Display Money Lost
    call WriteString
    mov eax, moneyLost
    call WriteDec

    call Crlf
    call Crlf                                                                   ; Return to the main menu
    call WaitMsg                                                                ; Waits for a key press before returning
    ret

DisplayStats ENDP


END main

;================
; Extra Credits ;
;================
; total instruction = 15
; call, mov, cmp, jmp, je, invoke, ret, jg, ,jl, add, sub, test, jz, jne, jno
