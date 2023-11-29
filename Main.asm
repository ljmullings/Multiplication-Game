# Main.asm File
# Include the displayGameboard and LogicHandler procedures
.include "GameBitMap.asm"

.include "LogicHandler.asm"
.data
    .globl endPrompt
    .globl computer_prompt
    .globl process_prompt
    .globl start_prompt
    

    currentTurn: .word 0
    
    endPrompt:       .asciiz "Would you like to exit the game?"
    computer_prompt: .asciiz "The Computer picked... "
    process_prompt:  .asciiz "Product is..."

    start_prompt:    .asciiz "Welcome to the multiplication game! Let's get started!"

.text
.globl main
main:
    # Initialize game (Set seed for pseudorandom number generator, etc.)
	li $v0, 4                # Syscall for printing string
	la $a0, start_prompt   # Load address of the you win prompt message
	syscall                  # Execute syscall to print the message
	li $v0, 11               # Syscall for printing character
    	li $a0, 10               # ASCII code for newline (or use 32 for space)
    	syscall
    # Display the initial state of the game board
    # jal displayGameboard

    # Computer's initial turn to generate the first number
    jal randomGenerator       # Generate a number
    move $t3, $v0             # Store the computer's choice in $t3
    # ... [Code to handle the computer's initial choice] ...

    # Set current turn to user's turn
    li $t5, 0
    sw $t5, currentTurn

    # Game Loop
    .globl game_loop
    game_loop:
    	jal displayGameboard
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
    	move $t9, $v0            # Store the user's choice in a different register, e.g., $t7
    	# Update Turn Indicator to Computer's Turn
    	li $t5, 1
    	sw $t5, currentTurn
    	j process_turn

    computer_turn:
    
   	 # Print the prompt message
    	li $v0, 4                # Syscall for printing string
    	la $a0, computer_prompt      # Load address of the prompt message
    	syscall                  # Execute syscall to print the message
    	# Computer's Turn Logic
    	
    	jal randomGenerator
    	move $t3, $v0            # Store the computer's choice in $t3
    	
    	# Print the computer's choice
    	li $v0, 1                   # Syscall for printing integer
   	move $a0, $t3               # Move the computer's choice to $a0
	syscall                     # Execute syscall to print the number

    	# Optionally print a newline or space after the number
    	li $v0, 11                  # Syscall for printing character
    	li $a0, 10                  # ASCII code for newline (or use 32 for space)
    	syscall

    	# Update Turn Indicator to User's Turn
    	li $t5, 0
        sw $t5, currentTurn
        j process_turn

    process_turn:
 	# Print values before multiplication
    	li $v0, 1
    	move $a0, $t3
    	syscall
    	move $a0, $t9
    	syscall
       # Multiply Choices
   	move $a0, $t3            # Computer's choice
    	move $a1, $t9            # User's choice
    	jal multiplyNumbers
    	move $t2, $v0            # Store the multiplication result in $t2

    	# Save $t2 on the stack if alter_board might modify it
    	addi $sp, $sp, -4
    	sw $t2, 0($sp)

    	# Update the gameboard
    	move $a0, $t5            # Current turn
    	move $a1, $t2            # The cell to update
    	jal alter_board

    	# Restore $t2 from the stack
    	lw $t2, 0($sp)
    	addi $sp, $sp, 4

    	# Print the result prompt message
    	li $v0, 4                # Syscall for printing string
    	la $a0, process_prompt
    	syscall

    	# Print the multiplication result
    	li $v0, 1
    	move $a0, $t2
    	syscall

    	# Optionally print a newline or space after the number
    	li $v0, 11               # Syscall for printing character
    	li $a0, 10               # ASCII code for newline (or use 32 for space)
    	syscall
    	# jal check_for_win
        j game_loop
