.include "Gameboard.asm"


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
        # (Generate random number and handle computer's turn)
        jal randomGenerator
        move $t3, $v0 # Store the random number in $t3
    	
    	# Generate a random number for the computer's turn using syscall
    	li $v0, 42       # syscall for random int in range
    	li $a0, 12345    # ID of the pseudorandom number generator
    	li $a1, 9      # Upper bound (assuming you want numbers from 0 to 9)
    	syscall
    	add $t3, $a0, 1    # Move the generated random number into $t3 for later use

    	# Display Computer's Choice
    	li $v0, 1        # syscall to print an integer
    	move $a0, $t3    # move the generated random number into $a0
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

    	add $t1, $v0, $t1 # adds the user input in v0 to the counter t1. This updates the value of t1, which heps genereate the next random varibale
    
    	# Check for Win Condition (Placeholder)
    	# [Your logic to check for 4 in a row]
    	# Condition to Exit Game Loop (Placeholder)
    	# beq $t4, $some_value, end_game
    
    	j game_loop
	
    .globl end_game
    end_game:
        # Code for ending the game and exiting
        li $v0, 10
        syscall
