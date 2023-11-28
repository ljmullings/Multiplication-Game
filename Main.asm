# Main.asm File
# Include the displayGameboard and LogicHandler procedures
.include "Gameboard.asm"
.include "LogicHandler.asm"

.data
    .globl endPrompt
    
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
        # Prompt the user to continue or exit
        li $v0, 4
        la $a0, endPrompt
        syscall

        li $v0, 12
        syscall
        move $t0, $v0

        li $t1, 'Y'
        beq $t0, $t1, end_game
        # Before calling computerSelectNumber
        jal randomGenerator      # Call random number generation
        move $a0, $v0            # Move generated number to $a0 for computerSelectNumber
        # Computer's Turn Logic
        jal computerSelectNumber
        move $t3, $v0 # Store the random number in $t3

        # Print a newline before computer's choice
        li $a0, 10
        li $v0, 11
        syscall
        # Print the computer's choice
        li $v0, 1
        move $a0, $t3
        syscall

        # Print a newline
        li $a0, 10
        li $v0, 11
        syscall

        # User's Turn Logic
        la $a0, prompt
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        move $t1, $v0 # Store the user's choice in $t1

        # Multiply Computer's choice and User's choice
        move $a0, $t3 # Computer's choice
        move $a1, $t1 # User's choice
        jal multiplyNumbers

        # Check for Win Condition (Placeholder)
        # [Your logic to check for 4 in a row]
        # Condition to Exit Game Loop (Placeholder)
        # beq $t4, $some_value, end_game


        # Loop back for next turn
        j game_loop

    .globl end_game
    end_game:
        # Code for ending the game and exiting
        li $v0, 10
        syscall
