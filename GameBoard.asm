.data
	.globl prompt
	.globl seed
	seed: 
	.word 123456789  # Initial seed value
	prompt: 
    		.asciiz "Enter your number (1-9): "
    	BoardRows: .word 6
    	BoardCols: .word 6
	bitmapData: .space 36  # 36 bytes for a 6x6 grid
	labelMap:   .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 30, 32, 35, 36, 40, 42, 45, 48, 49, 54, 56, 63, 64, 72, 81	# Array mapping each cell to its label


.text
.globl displayGameboard
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
            
# Procedure for Random Number Generation
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
    
# Procedure to alter the game board based on the current turn and selection
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
