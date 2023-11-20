// Handles game logic, run THIS file!!!
   

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
    li $v0, 4 # sets up a syscall to print a string
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
