.data
    # Input values
    num1:   .word 5      # First number
    num2:   .word 8      # Second number

    # Output value
    result: .word 0      # Variable to store the result

.text
    main:
        # Load the first number into register $t0
        lw $t0, num1

        # Load the second number into register $t1
        lw $t1, num2

        # Multiply the numbers and store the result in $t2
        mul $t2, $t0, $t1

        # Store the result in the memory location 'result'
        sw $t2, result

		# Display result
		li $v0, 1           
    	lw $a0, result
   	 	syscall
   	 	
        # Exit program
        li $v0, 10       # System call code for exit
        syscall
