# utilities.asm
.text
.globl randomGenerator
randomGenerator:
    # Simple linear congruential generator formula: X_{n+1} = (a * X_n + c) % m
    # Constants (can be chosen for better randomness)
    li $t0, 40         # a - Multiplier
    li $t1, 362436069  # c - Increment
    li $t2, 9          # m - Modulus (for generating numbers in the range 1-9)

    # Load the last generated number (or seed if first time)
    lw $t3, seed       # Load X_n (seed at first)

    # Compute a * X_n + c
    mul $t3, $t3, $t0  # a * X_n
    add $t3, $t3, $t1  # a * X_n + c

    # Modulus m to get the range 1-9
    rem $v0, $t3, $t2  # X_{n+1} = (a * X_n + c) % m

    # Since we want numbers from 1 to 9 instead of 0 to 8
    addi $v0, $v0, 1

    # Store the new number back to seed for next use
    sw $v0, seed

    jr $ra             # Return the random number in $v0
