.data

    # Define the ASCII table and game board parameters

    asciiTable: .word 1, 2, 3, 4, 5, 6,
                     7, 8, 9, 10, 12, 14,
                     15, 16, 18, 20, 21, 24,
                     25, 27, 28, 30, 32, 35,
                     36, 40, 42, 45, 48, 49,
                     54, 56, 63, 64, 72, 81

    rowSize: .word 6
    numRows: .word 6
    additionalLine: .word 1, 2, 3, 4, 5, 6, 7, 8, 9
    additionalLineSize: .word 9
    prompt: .asciiz "Enter your number (1-9): "
    upperBound: .word 9 # Upper bound for random number generation

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

.globl display_additional_line
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
            
    # Initialize a counter for simulated randomness
    li $t1, 0

# Game Loop
.globl game_loop
game_loop:
    
    # Simulate randomness for the computer's turn
    li $t2, 9 # loads immediate value 9 into register $t2
    div $t1, $t2 # divides the value in $t1 by 9 (t2) and stores the result. THe quotient goes into LO, and the remainder goes into HI
    mfhi $t3 # moves the remainder from the division above from HI register to $t3
    addi $t3, $t3, 1 # adds 1 to the value in t4. This is done to adjust the range of the randdom number 0-8 to 1-9
    
    # Display Computer's Choice
    li $v0, 1 # sets up a syscall to print a integer
    move $a0, $t3 # moves the computer choice (random vairable) into $a0, which is the arguement for the syscall
    syscall # prints the number
    li $a0, 10 # prints a new line character, loads the ASCII code for newline
    li $v0, 11
    syscall

    # User's Turn Logic
    la $a0, prompt #loads address of the string prompt into $a0
    li $v0, 4 # sets up a stscall to print a string
    syscall # prints the prompt
    li $v0, 5 # sets up a syscall to read an integer from the user
    syscall # waits for the user input and stores it in v0

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
