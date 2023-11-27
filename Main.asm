# Data Segment
.data
    .globl asciiTable
    .globl rowSize
    .globl numRows
    .globl additionalLine
    .globl additionalLineSize
    .globl prompt
    .globl upperBound

asciiTable: 
    .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 30, 32, 35, 36, 40, 42, 45, 48, 49, 54, 56, 63, 64, 72, 81

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

    
    # Load table base address
    la $t0, asciiTable 

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
            beq $t3, $zero, game_loop # Go to game loop if all elements are displayed
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
    

# Game Loop
game_loop:
    
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
    # [Your code for ending the game]
    # Exit the program
    li $v0, 10
    syscall
.end
