# Main.asm File
# Include the displayGameboard and LogicHandler procedures
.include "Gameboard.asm"
.include "LogicHandler.asm"
.data
    .globl endPrompt
    
currentTurn: .word 0
   
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

    	# Read user input for continuation
    	li $v0, 12
    	syscall
    	move $t0, $v0

    	# Check if the user wants to exit
    	li $t1, 'Y'
    	beq $t0, $t1, end_game

    	# Load current turn
    	lw $t5, currentTurn

    	# Check whose turn it is
    	beq $t5, $zero, user_turn
    	j computer_turn

	user_turn:
    	# User's Turn Logic
    	la $a0, prompt
    	li $v0, 4
    	syscall
    	li $v0, 5
    	syscall
    	move $t1, $v0            # Store the user's choice in $t1

    	# Update Turn Indicator to Computer's Turn
    	li $t6, 1
    	sw $t6, currentTurn
    	j continue_turn

	computer_turn:
    	# Computer's Turn Logic
    	jal randomGenerator
    	move $t3, $v0            # Store the computer's choice in $t3

    	# Update Turn Indicator to User's Turn
    	sw $zero, currentTurn

	continue_turn:
    	# Multiply Choices (if both choices are available)
    	move $a0, $t3            # Computer's choice
    	move $a1, $t1            # User's choice
    	jal multiplyNumbers
    	move $t2, $v0            # Store the multiplication result in $t2

    	# Print the computer's choice (if it was computer's turn)
    	beq $t5, $zero, skip_printing_computers_choice
    	li $v0, 1
    	move $a0, $t3
    	syscall
    	li $a0, 10
    	li $v0, 11
    	syscall

	skip_printing_computers_choice:
    	# Print the multiplied result (if both choices are available)
    	# ... [Code to print multiplied result] ...

    	# Check for Win Condition (Placeholder)
    	# ...

    	# Loop back for next turn
    	j game_loop

.globl end_game
end_game:
    # Code for ending the game and exiting
    li $v0, 10
    syscall
