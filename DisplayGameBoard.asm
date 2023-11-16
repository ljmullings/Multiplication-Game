.data
    # Define the ASCII table
    asciiTable: .word 1, 2, 3, 4, 5, 6,
                     7, 8, 9, 10, 12, 14,
                     15, 16, 18, 20, 21, 24,
                     25, 27, 28, 30, 32, 35,
                     36, 40, 42, 45, 48, 49,
                     54, 56, 63, 64, 72, 81
    rowSize: .word 6 # Number of elements per row
    numRows: .word 6 # Number of rows
    additionalLine: .word 1, 2, 3, 4, 5, 6, 7, 8, 9
    additionalLineSize: .word 9 # Number of elements in the additional line

.text
.globl main

main:
    # Load table base address
    la $t0, asciiTable

    # Load row and column sizes
    lw $t1, rowSize
    lw $t2, numRows

    # Row loop
    row_loop:
        beq $t2, $zero, display_additional_line # Go to additional line display if all rows are done
        move $t3, $t1 # Column counter

        # Column loop
        col_loop:
            beq $t3, $zero, next_row # Go to next row if all columns are done
            lw $a0, 0($t0) # Load the current table element
            li $v0, 1 # Prepare to print integer
            syscall

            # Print a space
            li $a0, 32
            li $v0, 11
            syscall

            addiu $t0, $t0, 4 # Move to the next table element
            addiu $t3, $t3, -1 # Decrement column counter
            j col_loop

        next_row:
            # Print a newline
            li $a0, 10
            li $v0, 11
            syscall

            addiu $t2, $t2, -1 # Decrement row counter
            j row_loop

    display_additional_line:
        # Load additional line base address and size
        la $t0, additionalLine
        lw $t1, additionalLineSize
        move $t3, $t1 # Element counter for additional line

        # Loop to display additional line
        additional_line_loop:
            beq $t3, $zero, end # Go to end if all elements are displayed
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

    end:
        # Exit the program
        li $v0, 10
        syscall
