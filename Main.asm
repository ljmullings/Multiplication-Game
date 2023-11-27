# Main.asm File
# Include the displayGameboard procedure
.include "Gameboard.asm"

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
    	li $v0, 4                 # syscall to print string
    	la $a0, endPrompt         # load address of the continue prompt
    	syscall

    	li $v0, 12                # syscall to read character
    	syscall
    	move $t0, $v0             # move read character to $t0

    	# Compare input to 'Y' and 'N'
    	li $t1, 'Y'               # ASCII value for 'Y'
    	beq $t0, $t1, end_game    # if input is 'Y', jump to end_game

    	# No need for the bne instruction here
    	# The program will naturally loop back if the user doesn't choose to exit
        # Computer's Turn Logic
        # (Generate random number and handle computer's turn)
        jal randomGenerator
        move $t3, $v0 # Store the random number in $t3
   
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
  

    	j game_loop               # Continue loop
    
   
	
    .globl end_game
    end_game:
        # Code for ending the game and exiting
        li $v0, 10
        syscall
