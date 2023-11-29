.data
	.globl prompt
	.globl seed
	.globl win_message
    	.globl you_lose_prompt
    	win_message:  	.asciiz "You win!"
    	you_lose_prompt:.asciiz "You lose!"
    	game_over:	.asciiz "Game Over!"
	seed: 		.word 123456789  # Initial seed value
	prompt: 	.asciiz "Enter your number (1-9): "
    	BoardRows: 	.word 6
    	BoardCols: 	.word 6
	bitmapData: 	.space 36  # 36 bytes for a 6x6 grid
	labelMap:   	.word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 30, 32, 35, 36, 40, 42, 45, 48, 49, 54, 56, 63, 64, 72, 81	# Array mapping each cell to its label
	debug_statement: .asciiz "CODE VISITED"

.text
.globl displayGameboard # ----------------------------------------- DISPLAY GAMEBOARD CODE: FINISHED DO NOT TOUCH
displayGameboard:
    # Save the original value of $s0
    addi $sp, $sp, -4
    sw $s0, 0($sp)

    la $t0, bitmapData   # Load address of bitmap
    la $t1, labelMap     # Load address of label map

    li $t2, 6            # Number of rows
    li $t3, 0            # Row counter

    row_loop:
        beq $t3, $t2, end_display   # Check if all rows are processed
        li $t4, 6                    # Number of columns
        li $t5, 0                    # Column counter

        col_loop:
            beq $t5, $t4, next_row   # Check if all columns in this row are processed

            # Calculate index in bitmapData (1D index from 2D coordinates)
            mul $t6, $t3, $t4        # row_index * row_size
            add $t6, $t6, $t5        # + col_index
            add $s0, $t0, $t6        # Address of the current cell in bitmapData

            # Load the byte value from bitmapData
            lb $t7, 0($s0)

            # Check if the cell contains 'X' (88) or 'O' (79)
            li $t8, 88               # ASCII for 'X'
            beq $t7, $t8, print_char
            li $t8, 79               # ASCII for 'O'
            beq $t7, $t8, print_char

            # For numbers, load from labelMap
            sll $t8, $t6, 2          # Convert index to word offset
            add $t8, $t1, $t8        # Address of the number in labelMap
            lw $a0, 0($t8)           # Load the number to print
            li $v0, 1                # Syscall for printing integer
            syscall

            j print_space

            print_char:
            move $a0, $t7            # Load 'X' or 'O'
            li $v0, 11               # Syscall for printing character
            syscall

            print_space:
            # Optionally print a separator like a space
            li $a0, 32               # ASCII code for space
            li $v0, 11               # Syscall for printing character
            syscall

            addi $t5, $t5, 1         # Increment column counter
            j col_loop

        next_row:
            # Print a newline character
            li $a0, 10
            li $v0, 11
            syscall

            addi $t3, $t3, 1         # Increment row counter
            j row_loop

    end_display:
    # Restore the original value of $s0 and return
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
            
# Procedure for Random Number Generation  -------------------- RANDOM NUMBER GENERATOR CODE: FINISHED DO NOT TOUCH
.globl randomGenerator
randomGenerator:
    # Simple linear congruential generator formula: X_{n+1} = (a * X_n + c) % m
    # Constants (can be chosen for better randomness)
    li $t0, 40      # a - Multiplier
    li $t1, 362436069  # c - Increment
    li $t2, 9       # m - Modulus (for generating numbers in the range 1-9)

    # Load the last generated number (or seed if first time)
    lw $t3, seed    # Load X_n (seed at first)

    # Compute a * X_n + c
    mul $t3, $t3, $t0  # a * X_n
    add $t3, $t3, $t1  # a * X_n + c

    # Modulus m to get the range 1-9
    rem $v0, $t3, $t2  # X_{n+1} = (a * X_n + c) % m

    # Since we want numbers from 1 to 9 instead of 0 to 8
    addi $v0, $v0, 1

    # Store the new number back to seed for next use
    sw $v0, seed

    jr $ra           # Return the random number in $v0
    
# Procedure to alter the game board based on the current turn and selection -------------------- ALTERING THE GAMEBOARD CODE: FINISHED DO NOT TOUCH AND HAS BEEN DEBUGGED
# Parameters:
# $a0 - Turn indicator (0 for user, 1 for computer)
# $a1 - Selection (number chosen)
.globl alter_board
alter_board:
    # Save registers
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t1, 4($sp)

    # Initialize loop variables
    li $t0, 0          # Index for looping through labelMap
    la $t1, labelMap   # Address of labelMap

    find_index_loop:
        # Check if we've reached the end of labelMap (36 elements)
        li $t2, 36
        beq $t0, $t2, index_not_found

        # Load the current label
        lw $t2, 0($t1)
        addi $t1, $t1, 4  # Move to the next label

        # Compare with the product
        beq $t2, $a1, index_found

        addi $t0, $t0, 1  # Increment index
        j find_index_loop

    index_not_found:
        # Product not found in labelMap, handle error
        # ... error handling code ...

    index_found:
        # $t0 now contains the correct index
        la $t1, bitmapData
        add $t1, $t1, $t0  # Address of the correct cell in bitmapData

        # Store ASCII 'X' for user (88) and 'O' for computer (79)
        beq $a0, $zero, mark_user
        li $t2, 79        # ASCII for 'O'
        j update_board

    mark_user:
        li $t2, 88        # ASCII for 'X'

    update_board:
        sb $t2, 0($t1)    # Store the value in the selected cell

    # Restore registers and return
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    addi $sp, $sp, 8
    jr $ra
# ---------------------------------------------------------------------------- CHECKING STATUS CODE: DEBUG STAGE, BE CAREFUL WITH THIS
.globl print_debug_statement
print_debug_statement:
    li $v0, 4              # Syscall code for print string
    la $a0, debug_statement # Load address of the debug statement
    syscall                # Execute syscall

    jr $ra                 # Return to the calling function

.globl check_for_win
check_for_win:
    # Assume $a1 contains the index of the last tile placed
    # $a0 contains the player who made the move (0 for user, 1 for computer)
	# jal print_debug_statement Visited!
    	# Call procedures to check for wins
    	# Save $ra to stack if needed
    	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	
    	move $a0, $a1
    	# jal print_debug_statement VISITED
    	jal check_horizontal_win
    	beq $v0, 1, win_user
    	beq $v0, 2, win_computer

    	jal check_vertical_win
    	beq $v0, 1, win_user
    	beq $v0, 2, win_computer

    	jal check_diagonal_win
    	beq $v0, 1, win_user
    	beq $v0, 2, win_computer

	# Restore $ra and return
	# Restore $ra and return
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra
    	jr $ra  # No win, return to the main loop
    	
win_user:
    # Handle user win (print "You Win!" etc.)
    # ...

    j end_game  # End the game after the win

win_computer:
    # Handle computer win (print "You Lose!" etc.)
    # ...

    j end_game  # End the game after the win

end_game:
    # Optional: Print a message before ending the game
     li $v0, 4               # Syscall code for print string
     la $a0, game_over    # Address of the message to print
     syscall                 # Execute syscall

    # Terminate the program
    li $v0, 10               # Syscall code for exit
    syscall                  # Execute syscall

    # This line is technically not reached after the syscall for exit
    jr $ra                   # Return to the calling function
    
.globl check_horizontal_win
check_horizontal_win:
    # Save registers
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)  # Address of bitmapData
    sw $s1, 8($sp)  # Counter for 'X's
    sw $s2, 12($sp) # Counter for 'O's
    sw $s3, 16($sp) # Row and column index

	# jal print_debug_statement VISITED
    # Initialize base address of bitmapData
    la $s0, bitmapData

    # Iterate through each row
    li $s3, 0
    row_loop_horizontal:
        li $t0, 6
        beq $s3, $t0, end_horizontal_check  # End if all rows processed
        # Reset counters for each new row
        li $s1, 0
        li $s2, 0

        # Iterate through each column in the row
        li $t1, 0
        column_loop_horizontal:
            beq $t1, $t0, next_row_horizontal  # End if all columns processed
	
            # Calculate index in bitmapData
            mul $t2, $s3, $t0
            add $t2, $t2, $t1
            add $t2, $s0, $t2

            # Load the value at the current cell
            lb $t3, 0($t2)

            # Check for 'X' or 'O'
            li $t4, 88  # ASCII for 'X'
            beq $t3, $t4, check_x_horizontal
            li $t4, 79  # ASCII for 'O'
            beq $t3, $t4, check_o_horizontal

            # Reset counters if the current cell is neither 'X' nor 'O'
            li $s1, 0
            li $s2, 0
            j continue_horizontal

            check_x_horizontal:
            addi $s1, $s1, 1  # Increment 'X' counter
            li $s2, 0         # Reset 'O' counter
            j check_win_horizontal

            check_o_horizontal:
            addi $s2, $s2, 1  # Increment 'O' counter
            li $s1, 0         # Reset 'X' counter

            check_win_horizontal:
            # Check if four 'X's or 'O's in a row are found
            li $t4, 4
            beq $s1, $t4, win_x_horizontal
            beq $s2, $t4, win_o_horizontal

            continue_horizontal:
            addi $t1, $t1, 1
            j column_loop_horizontal

        next_row_horizontal:
        addi $s3, $s3, 1
        j row_loop_horizontal

    end_horizontal_check:
    # No win detected, set $v0 to 0
    li $v0, 0
  
    j restore_and_return_horizontal

    win_x_horizontal:
    # 'X' win detected, set $v0 to 2
    li $v0, 2
    j restore_and_return_horizontal

    win_o_horizontal:
    # 'O' win detected, set $v0 to 1
    li $v0, 1

    restore_and_return_horizontal:
    # Restore registers and return
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra

	
.globl check_vertical_win
check_vertical_win:
    # Save necessary registers
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)  # Temporarily store bitmapData address
    sw $s1, 8($sp)  # Temporarily store consecutive count

    la $s0, bitmapData  # Load base address of bitmapData

    # Iterate over each column
    li $t0, 0  # Column index
    column_loop1:
   
        li $s1, 0   # Reset consecutive count for 'X'
        li $t1, 0   # Reset consecutive count for 'O'
        li $t2, 0   # Row index

        # Check each cell in the column
        row_loop1:
            # Calculate address for the current cell
            mul $t3, $t2, 6  # Calculate row offset
            add $t3, $t3, $t0 # Add column index
            add $t3, $s0, $t3 # Calculate actual address

            # Load the value from the current cell
            lb $t4, 0($t3)

            # Check for 'X' or 'O'
            li $t5, 88       # ASCII for 'X'
            li $t6, 79       # ASCII for 'O'
            beq $t4, $t5, check_X
            beq $t4, $t6, check_O
            # Reset count if neither 'X' nor 'O'
            li $s1, 0
            li $t1, 0
            j check_next_row

            check_X:
            addi $s1, $s1, 1  # Increment count for 'X'
            li $t1, 0         # Reset count for 'O'
            j check_win

            check_O:
            addi $t1, $t1, 1  # Increment count for 'O'
            li $s1, 0         # Reset count for 'X'

            check_win:
            # Check if four in a row are found
            li $t7, 4
            beq $s1, $t7, user_win
            beq $t1, $t7, computer_win

            check_next_row:
            addi $t2, $t2, 1
            li $t8, 6
            blt $t2, $t8, row_loop1 # Check next row if within bounds

        # Move to the next column
        addi $t0, $t0, 1
        li $t8, 6
        blt $t0, $t8, column_loop1 # Check next column if within bounds

    # No win detected
    li $v0, 0

    j restore_and_return

    user_win:
    li $v0, 1  # Set return value to 1 for user win
    j restore_and_return

    computer_win:
    li $v0, 2  # Set return value to 2 for computer win

    restore_and_return:
    # Restore registers
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra
check_diagonal_win:
	jr $ra
