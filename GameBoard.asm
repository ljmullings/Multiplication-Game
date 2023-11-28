
# Data Segment
.data
    .globl asciiTable
    .globl rowSize
    .globl numRows
    .globl additionalLine
    .globl additionalLineSize
    .globl prompt
    .globl upperBound
    .globl seed
    .globl currentTurn
    #.globl selectionList


seed: 
	.word 123456789  # Initial seed value
asciiTable: 
    .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 30, 32, 35, 36, 40, 42, 45, 48, 49, 54, 56, 63, 64, 72, 81

#selectionList:
    #.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

rowSize: 
    .word 6

numRows: 
    .word 6

additionalLine: 
    .word 1, 2, 3, 4, 5, 6, 7, 8, 9

additionalLineSize: 
    .word 9

prompt: 
    .asciiz "Enter your number (1-9): "

upperBound: 
    .word 9 # Upper bound for random number generation

# Text Segment
.text
.globl displayGameboard
displayGameboard:
    
    # Load table base addresses
    la $t0, asciiTable 
    #la $t4, selectionList #Assume $t2, $t3 are used for loop counters or other purpose

    # Load row and column sizes
    lw $t1, rowSize
    lw $t2, numRows


    # Row loop
    row_loop:
        beq $t2, $zero, display_additional_line # Go to additional line display if all rows are done
        move $t3, $t1 # Initializes the column counter $t3 with the size of a row $t1
        
        # Column loop
        col_loop:
            beq $t3, $zero, next_row # checks if all columns in the current row have been processed. If so, it jups to next row
            lw $a0, 0($t0) # Load the current table element into $a0
            li $v0, 1 # Prepare to print integer
            syscall # printing the integer in $a0

            # Print a space
            li $a0, 32 
            li $v0, 11
            syscall

            addiu $t0, $t0, 4 # Move to the next table element
            addiu $t3, $t3, -1 # Decrement column counter
            j col_loop

        next_row:
            # Print a newline character
            li $a0, 10
            li $v0, 11
            syscall

            addiu $t2, $t2, -1 # Decrement row counter
            j row_loop # jumps back to the start of the row loop to process the next row

    display_additional_line:
        # Load additional line base address and size
        la $t0, additionalLine
        lw $t1, additionalLineSize
        move $t3, $t1 # Element counter for additional line

        # Loop to display additional line
        additional_line_loop:
            beq $t3, $zero, end_display # Go to game loop if all elements are displayed
            lw $a0, 0($t0) # Load the current element
            li $v0, 1 # Prepare to print integer
            syscall

            # Print a space
            li $a0, 32
            li $v0, 11
            syscall

            addiu $t0, $t0, 4 # Move to the next element
            addiu $t3, $t3, -1 # Decrement element counter
            j additional_line_loop
     jr $ra # Return to caller 
     
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

end_display:
    jr $ra # Return to the caller
