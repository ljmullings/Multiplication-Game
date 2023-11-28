# LogicHandler.asm File

.data
    # No data segment needed for this file

.text
.globl multiplyNumbers

# Multiplies two numbers and returns the product
multiplyNumbers:
    # Assuming the numbers to be multiplied are passed in $a0 and $a1
    mul $v0, $a0, $a1  # Multiply $a0 and $a1, store the result in $v0
    jr $ra             # Return the product in $v0
