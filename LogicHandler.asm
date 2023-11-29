# LogicHandler.asm File

.data
	.globl win_message
    	.globl you_lose_prompt
    	win_message:  .asciiz "You win!"
    	you_lose_prompt: .asciiz "You lose!"

.text
.globl multiplyNumbers
# Multiplies two numbers and returns the product
multiplyNumbers:
    # Assuming the numbers to be multiplied are passed in $a0 and $a1
    mul $v0, $a0, $a1  # Multiply $a0 and $a1, store the result in $v0
    jr $ra             # Return the product in $v0

# Check for Horizontal Win
.globl check_horizontal_win
check_horizontal_win:
    # ... Loop through each row
    # ... Check for four consecutive 'X's or 'O's
    # ... Set a flag or use a register to indicate win
    jr $ra

# Check for Vertical Win
.globl check_vertical_win
check_vertical_win:
    # ... Loop through each column
    # ... Check for four consecutive 'X's or 'O's
    # ... Set a flag or use a register to indicate win
    jr $ra

# Check for Diagonal Win
.globl check_diagonal_win
check_diagonal_win:
    # Save registers
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Call the procedure to check major diagonals
    jal check_major_diagonals

    # Check if a win was detected in major diagonals
    beq $v0, $zero, check_minor_diagonals  # If no win, proceed to check minor diagonals

    # Win detected in major diagonals, set $v0 to 1 and return
    li $v0, 1
    j restore_and_return

    restore_and_return:
    # Restore registers and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

.globl check_minor_diagonals
check_minor_diagonals:
    # Save registers
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)  # $s1 will store the count of consecutive characters

    #la $s0, bitmapData   # Base address of the game board

    # Iterate over potential starting points for a 4-cell diagonal (0 to 2 for rows, 3 to 5 for columns)
    li $t0, 0  # Row index
    row_loop_minor:
        li $t1, 5  # Column index, starting from the right
        column_loop_minor:
            # Reset the count for each diagonal
            li $s1, 0

            # Set up variables for diagonal traversal
            move $t2, $t0  # Current row for traversal
            move $t3, $t1  # Current column for traversal

            # Traverse the diagonal
            diagonal_loop_minor:
                # Check bounds for 4-cell diagonal
                li $t4, 3
                blt $t2, $t4, continue_traversal_minor
                bge $t3, 2, continue_traversal_minor  # Column index should be >= 2
                j end_diagonal_check_minor

                continue_traversal_minor:
                # Calculate the index in the bitmapData
                mul $t5, $t2, 6    # Index = row * 6 (width of the grid)
                add $t5, $t5, $t3  # Add the column
                add $t5, $s0, $t5  # Add base address to get the actual address

                # Load the value at the current cell
                lb $t6, 0($t5)
                
                # Check for 'X' or 'O' and update count
                li $t7, 88  # ASCII for 'X'
                beq $t6, $t7, increment_count_minor
                li $t7, 79  # ASCII for 'O'
                beq $t6, $t7, increment_count_minor

                # Reset the count if the current cell is not part of a sequence
                li $s1, 0

                increment_count_minor:
                addi $s1, $s1, 1

                # Check if four in a row are found
                li $t7, 4
                beq $s1, $t7, win_detected_minor

                # Move to the next cell in the diagonal
                addi $t2, $t2, 1
                addi $t3, $t3, -1  # Move left for minor diagonal
                j diagonal_loop_minor

            end_diagonal_check_minor:
            addi $t1, $t1, -1
            li $t4, 2
            bge $t1, $t4, column_loop_minor

        addi $t0, $t0, 1
        li $t4, 3
        blt $t0, $t4, row_loop_minor

    # No win detected, set $v0 to 0
    li $v0, 0
    j restore_and_return_minor

    win_detected_minor:
    # Win detected, set $v0 to 1
    li $v0, 1

    restore_and_return_minor:
    # Restore registers and return
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

.globl check_major_diagonals
check_major_diagonals:
    # Save registers
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)  # $s1 will store the count of consecutive characters

    la $s0, bitmapData   # Base address of the game board

    # Iterate over potential starting points for a 4-cell diagonal (0 to 2 for rows, 0 to 2 for columns)
    li $t0, 0  # Row index
    row_loop1:
        li $t1, 0  # Column index
        column_loop1:
            # Reset the count for each diagonal
            li $s1, 0

            # Set up variables for diagonal traversal
            move $t2, $t0  # Current row for traversal
            move $t3, $t1  # Current column for traversal

            # Traverse the diagonal
            diagonal_loop1:
                # Check bounds for 4-cell diagonal
                li $t4, 3
                blt $t2, $t4, continue_traversal
                blt $t3, $t4, continue_traversal
                j end_diagonal_check  # End the check for this diagonal

                continue_traversal:
                # Calculate the index in the bitmapData
                mul $t5, $t2, 6    # Index = row * 6 (width of the grid)
                add $t5, $t5, $t3  # Add the column
                add $t5, $s0, $t5  # Add base address to get the actual address

                # Load the value at the current cell
                lb $t6, 0($t5)
                
                # Check for 'X' or 'O' and update count
                li $t7, 88  # ASCII for 'X'
                beq $t6, $t7, increment_count
                li $t7, 79  # ASCII for 'O'
                beq $t6, $t7, increment_count

                # Reset the count if the current cell is not part of a sequence
                li $s1, 0

                increment_count:
                addi $s1, $s1, 1

                # Check if four in a row are found
                li $t7, 4
                beq $s1, $t7, win_detected

                # Move to the next cell in the diagonal
                addi $t2, $t2, 1
                addi $t3, $t3, 1
                j diagonal_loop1

            end_diagonal_check:
            addi $t1, $t1, 1
            li $t4, 3
            blt $t1, $t4, column_loop1

        addi $t0, $t0, 1
        li $t4, 3
        blt $t0, $t4, row_loop

    # No win detected, set $v0 to 0
    li $v0, 0
    j restore_and_return

    win_detected:
    # Win detected, set $v0 to 1
    li $v0, 1


# Main Procedure to Check for Any Win
.globl check_for_win
check_for_win:
    # Save registers
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Check for horizontal win
    jal check_horizontal_win
    beq $v0, $zero, check_vertical   # If win, proceed to end game

    # Check for vertical win
    check_vertical:
    jal check_vertical_win
    beq $v0, $zero, check_diagonal   # If win, proceed to end game

    # Check for diagonal win
    check_diagonal:
    jal check_diagonal_win
    beq $v0, $zero, no_win           # If no win, return to game loop

    j end_game                       # Jump to end game procedure

    # No win, return to game loop
    no_win:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    .globl end_game
    end_game:
        # Code for ending the game and exiting
        li $v0, 10
        syscall
