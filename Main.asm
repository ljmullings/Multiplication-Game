# Main.asm File
# Include necessary procedures
.include "utilities.asm"
.include "Gameboard.asm"
.include "LogicHandler.asm"

.data
    .globl seed
    

seed: 
    .word 123456789  # Initial seed value

endPrompt:
    .asciiz "Would you like to exit the game?"

.text
.globl main
main:
    # Initialize game
    # (Set seed for pseudorandom number generator, and other initializations)

    # Game Loop
    .globl game_loop
    game_loop:

    # Display the current state of the game board
    jal displayGameboard

    # Computer's Turn Logic
    jal computerSelectNumber
    move $t3, $v0 # Store the computer's choice

    # Display Computer's Choice
    # [Your existing code to display the computer's choice]

    # User's Turn Logic
    # [Your existing code for the user's input]

    # Call multiplyNumbers with computer's and user's choices
    move $a0, $t3  # Computer's choice
    move $a1, $v0  # User's choice (from user's turn logic)
    jal multiplyNumbers
    move $t4, $v0  # Store the result of multiplication

    # Check for Win Condition or update game state
    # [Your logic here]

    # Prompt the user to continue or exit
    li $v0, 4                 # syscall to print string
    la $a0, endPrompt         # load address of the continue prompt
    syscall

    li $v0, 12                # syscall to read character
    syscall
    move $t0, $v0             # move read character to $t0

    li $t1, 'Y'               # ASCII value for 'Y'
    beq $t0, $t1, end_game    # if input is 'Y', jump to end_game

    # No need for the bne instruction here
    # The program will naturally loop back if the user doesn't choose to exit

    j game_loop               # Continue loop

    .globl end_game
    end_game:
        # Code for ending the game and exiting
        li $v0, 10
        syscall
