.include "GameBitMap.asm"
.include "LogicHandler.asm"

.data
	.globl endPrompt
    	.globl computer_prompt
    	.globl process_prompt
    	.globl start_prompt

    	currentTurn: .word 0
	error_message: .asciiz "Error! Number is outside of bounds. Try again!"
    	endPrompt:       .asciiz "Would you like to exit the game?"
    	computer_prompt: .asciiz "The Computer picked... "
    	process_prompt:  .asciiz "Product is..."
    	start_prompt:    .asciiz "Welcome to the multiplication game! Let's get started!"
	instruction_prompt: .asciiz "Your spaces are represented by Os and the Computer's will be marked by Xs"
.text
.globl main
main:
	# Initialize game
	li $v0, 4                # Syscall for printing start
	la $a0, start_prompt   
	syscall                  
	li $v0, 11               
    	li $a0, 10               
    	syscall  
    	li $v0, 4                # Syscall for printing start
	la $a0, instruction_prompt   
	syscall     
	li $v0, 11               
    	li $a0, 10               
    	syscall      
    	
	# Computer's initial turn to generate the first number (Hidden)
	jal randomGenerator       
	move $t3, $v0             

	# Set current turn to user's turn
	li $t5, 0
	sw $t5, currentTurn
 
	.globl game_loop
    	game_loop:
    		addi $sp, $sp, -4
    		sw $t3, 0($sp) # Saving $t3

    		jal displayGameboard

    		# Restore $t3 
    		lw $t3, 0($sp)
		addi $sp, $sp, 4
	
        	lw $t5, currentTurn

       	# Check whose turn it is
        	beq $t5, $zero, user_turn
        	j computer_turn

	user_turn:
    		# User's Turn Logic
    	get_user_input:
		la $a0, prompt
        	li $v0, 4  # Syscall for printing string
        	syscall

        	li $v0, 5  # Syscall for reading an integer
        	syscall

        	move $t9, $v0  # Store the user's choice in $t9

        	# Check if the input is within the valid range (1-9)
        	li $t6, 1      # Lower bound
        	li $t7, 9      # Upper bound
        	blt $t9, $t6, invalid_input  # If input is less than 1, go to invalid_input
        	bgt $t9, $t7, invalid_input  # If input is greater than 9, go to invalid_input

        	# Valid input, proceed to process_turn
        	li $t5, 1
        	sw $t5, currentTurn
        	j process_turn

    	invalid_input:
        	# Handle invalid input
        	li $v0, 4              # Syscall for printing string
        	la $a0, error_message  # Load address of the error message
        	syscall
        	li $v0, 11               
		li $a0, 10                
        	syscall
        	j get_user_input       # Go back to get_user_input to ask for input again

	computer_turn:
   	 	# Print the prompt message
    		li $v0, 4               
    		la $a0, computer_prompt      
    		syscall                  # Execute syscall to print the message
    		
    		jal randomGenerator
    		move $t3, $v0            # Store the computer's choice in $t3
   	
    		# Print the computer's choice
    		li $v0, 1                   
   		move $a0, $t3               
		syscall                     # Execute syscall to print the number

    	
   		li $v0, 11                  # Print NewLine for formatting
    		li $a0, 10                  
    		syscall

    		# Update Turn Indicator to User's Turn
    		li $t5, 0
        	sw $t5, currentTurn
        	j process_turn

	process_turn:
    		# Save registers before calling check_win
    		addi $sp, $sp, -16   # Allocate space on stack for 4 registers
    		sw $t2, 0($sp)       
    		sw $t3, 4($sp)       
    		sw $t5, 8($sp)       
    		sw $t9, 12($sp)      
 
       	# Multiply Choices
   		move $a0, $t3            # Computer
    		move $a1, $t9            # User
    		jal multiplyNumbers
    		move $t2, $v0            # Store the multiplication result in $t2

    		# Save $t2 on the stack if alter_board might modify it
    		addi $sp, $sp, -4
    		sw $t2, 0($sp)

    		# Update the gameboard
    		move $a0, $t5            
    		move $a1, $t2            # The cell to update
    		jal alter_board

    		# Restore $t2 from the stack
    		lw $t2, 0($sp)
    		addi $sp, $sp, 4

    		# Print the result prompt message
    		li $v0, 4                
    		la $a0, process_prompt
    		syscall

    		# Print the multiplication result
    		li $v0, 1
    		move $a0, $t2
    		syscall

    		li $v0, 11               
    		li $a0, 10               
    		syscall
    		jal check_win
    	
    		# Restore registers after calling check_win
    		lw $t9, 12($sp)     
    		lw $t5, 8($sp)       
    		lw $t3, 4($sp)       
    		lw $t2, 0($sp)       
    		addi $sp, $sp, 16    # Deallocate space on stack
        	j game_loop
