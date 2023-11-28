# LogicHandler.asm File

.data
    # No data segment needed for this file

.text
.globl multiplyNumbers
.globl computerSelectNumber

# Multiplies two numbers and returns the product
multiplyNumbers:
    # Assuming the numbers to be multiplied are passed in $a0 and $a1
    mul $v0, $a0, $a1  # Multiply $a0 and $a1, store the result in $v0
    jr $ra             # Return the product in $v0

# Computer selects a number and prints it
computerSelectNumber:
    # Assume number is already in $a0
    # Print the computer's choice
    li $v0, 1          # syscall to print an integer
    syscall            # print the number

    # Store the computer's choice in a register for later use
    move $t4, $a0      # Store the computer's choice in $t4 for later

    jr $ra             # Return
