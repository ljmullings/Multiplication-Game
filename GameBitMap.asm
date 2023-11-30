.data
	.globl prompt
	.globl seed
	.globl win_message
    	.globl you_lose_prompt 
    	win_message:  	.asciiz "You win!"
    	you_lose_prompt:.asciiz "You lose!"
    	game_over:	.asciiz "Game Over!"
	seed: 		.word 123456789  # Initial seed value
	prompt: 	.asciiz "Enter your number (1-9): "
    	BoardRows: 	.word 6
    	BoardCols: 	.word 6
	# bitmapData: 	.space 36  # 36 bytes for a 6x6 grid
	bitmapData: 	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	labelMap:   	.word  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 24, 25, 27, 28, 30, 32, 35, 36, 40, 42, 45, 48, 49, 54, 56, 63, 64, 72, 81	# Array mapping each cell to its label
	debug_statement: .asciiz "CODE VISITED"
	var_id: 		.asciiz " var id "
	val: 		.asciiz " val "
.text
.globl displayGameboard 
displayGameboard:
    # Save the original value of $s0
    addi $sp, $sp, -4
    sw $s0, 0($sp)

    la $t0, bitmapData   
    la $t1, labelMap     

    li $t2, 6            # Number of rows
    li $t3, 0            # Row counter

    row_loop:
        beq $t3, $t2, end_display   # Check if all rows are processed
        li $t4, 6                    # Number of columns
        li $t5, 0                    # Column counter

	col_loop:
		beq $t5, $t4, next_row   

		# Calculate index in bitmapData (1D index from 2D coordinates)
		mul $t6, $t3, $t4        # row_index * row_size
		add $t6, $t6, $t5        # + col_index
		add $s0, $t0, $t6        # address of the current cell in bitmapData

		# Load the byte value 
		lb $t7, 0($s0)

		# if statement essentially
		li $t8, 88               # ASCII for 'X'
		beq $t7, $t8, print_char
		li $t8, 79               # ASCII for 'O'
		beq $t7, $t8, print_char

		# For numbers, load from labelMap
		sll $t8, $t6, 2        
		add $t8, $t1, $t8        
		lw $a0, 0($t8)          
		li $v0, 1                
		syscall

		j print_space

		print_char:
			move $a0, $t7            # Load 'X' or 'O'
			li $v0, 11               # Syscall for printing character
			syscall

		print_space:
            	li $a0, 32              
            	li $v0, 11               
            	syscall

          addi $t5, $t5, 1         # Increment column counter
		j col_loop

       next_row:
		li $a0, 10
		li $v0, 11
		syscall

		addi $t3, $t3, 1         # Increment row counter
		j row_loop

	end_display:
    		# Restore 
    		lw $s0, 0($sp)
    		addi $sp, $sp, 4
    		jr $ra
            
.globl randomGenerator
randomGenerator:
	# linear congruential generator formula: X_{n+1} = (a * X_n + c) % m
    
    	li $t0, 40      # a - Multiplier
    	li $t1, 36243670  # c - Increment
    	li $t2, 9       # m - Modulus (for generating numbers in the range 1-9)

    	# Load the last generated number (or seed if first time)
    	lw $t3, seed    

    	# Compute a * X_n + c
    	mul $t3, $t3, $t0 
    	add $t3, $t3, $t1  

    	rem $v0, $t3, $t2  # X_{n+1} = (a * X_n + c) % m to get range

    	# shift 1 to 9 instead of 0 to 8
    	addi $v0, $v0, 1
	# Store the new number back to seed for next use
    	sw $v0, seed
	jr $ra
    
# alter the game board based on the current turn and selection
# $a0 - Turn indicator (0 for user, 1 for computer)
# $a1 - Selection (number chosen)
.globl alter_board
alter_board:
	# Save registers
    	addi $sp, $sp, -12
    	sw $t0, 0($sp)
    	sw $t1, 4($sp)
    	sw $t2, 8($sp)

    	# Initialize loop variables
    	li $t0, 0          # Index for looping
    	la $t1, labelMap   # Address of labelMap

    	find_index_loop:
        	li $t3, 36

        	# Load the current label
        	lw $t3, 0($t1)
        	addi $t1, $t1, 4  # Move to next

        	# Compare with product
        	beq $t3, $a1, index_found

        	addi $t0, $t0, 1  # Increment index
        	j find_index_loop

	index_found:
        	la $t1, bitmapData
        	add $t1, $t1, $t0  

        	# Check if the cell already contains 'X' or 'O'
        	lb $t2, 0($t1)
        	li $t3, 88  
        	li $t4, 79 
        	beq $t2, $t3, skip_update
        	beq $t2, $t4, skip_update

        	# Store ASCII 'X' for user (88) and 'O' for computer (79)
        	beq $a0, $zero, mark_user
		li $t2, 79  
        	j update_board

	mark_user:
        	li $t2, 88 

    	update_board:
        		sb $t2, 0($t1)    # Store value

    	skip_update:
        		j end_alterboard
    
    	end_alterboard:
    			lw $t0, 0($sp)
    			lw $t1, 4($sp)
    			lw $t2, 8($sp)
    			addi $sp, $sp, 12
    			jr $ra

    # Restore registers and return
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    addi $sp, $sp, 12
    jr $ra
    
.globl check_win
check_win:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	
    	# Call horizontal_check and check result
    	jal horizontal_check
    	beq $v0, 1, user_win    # If $v0 is 1, user wins
    	beq $v0, 2, computer_win # If $v0 is 2, computer wins
    	
    	jal vertical_check
    	beq $v0, 1, user_win    
    	beq $v0, 2, computer_win 

    	jal diagonal_check
    	beq $v0, 1, user_win   
    	beq $v0, 2, computer_win 

    	# No win detected, return to caller
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4

	jr $ra

user_win:
    	li $v0, 4               
    	la $a0, win_message  
    	syscall                  
    	j end_game 

computer_win:
    	li $v0, 4                
    	la $a0, you_lose_prompt 
    	syscall                  
    	j end_game        

.globl end_game
end_game: 
	li $v0, 10
	syscall
    
.globl horizontal_check
horizontal_check:

    # Save registers
    	addi $sp, $sp, -16
    	sw $ra, 0($sp)
    	sw $s0, 4($sp)  # Counter for 'X's
    	sw $s1, 8($sp)  # Counter for 'O's
    	sw $s2, 12($sp) # Index for accessing bitmapData

	
	
    	la $t0, bitmapData  

  
    	li $t1, 0  # Row index
    	hc_row_loop:
        li $s0, 0
        li $s1, 0
        
        li $t2, 0  # Column index
		hc_column_loop:
            	# Calculate the index in bitmapData
            	mul $s2, $t1, 6 
            	add $s2, $s2, $t2 

            	# Load the cell value
            	add $t3, $t0, $s2
           
            	lb $t3, 0($t3)  

            	#if the cell contains 'X' or 'O'...
            	li $t4, 88 
            	li $t5, 79  
            	beq $t3, $t4, check_x
           	beq $t3, $t5, check_o
            	j reset_counters  

		check_x:
            	addi $s0, $s0, 1
            	li $s1, 1
            	j check_win_horizontal

		check_o:
            	addi $s1, $s1, 1
            	li $s0, 1
            	j check_win_horizontal

		reset_counters:
            	li $s0, 0
			li $s1, 0

		check_win_horizontal:
            	li $t6, 4
            	beq $s0, $t6, win_computer_horizontal
			beq $s1, $t6, win_user_horizontal
	
			addi $t2, $t2, 1
			li $t6, 6
			blt $t2, $t6, hc_column_loop
            
	addi $t1, $t1, 1
	blt $t1, 6, hc_row_loop

    # No win detected
    	li $v0, 0
    	j end_horizontal_check

win_user_horizontal:
    	li $v0, 1  # User win
    	jal user_win


win_computer_horizontal:
    	li $v0, 2  # Computer win
    	jal computer_win


end_horizontal_check:
    # Restore registers and return
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra
    
    
.globl vertical_check
vertical_check:
    # Save registers
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $s0, 4($sp)  # Counter for 'X's
    sw $s1, 8($sp)  # Counter for 'O's
    sw $s2, 12($sp) # Index for accessing bitmapData

    la $t0, bitmapData  # Load the address of bitmapData

    # Iterate over each column
    li $t1, 0  # Column index
    vc_column_loop:
        # Reset counters
        li $s0, 0
        li $s1, 0

        # Iterate over each row in the column
        li $t2, 0  # Row index
        vc_row_loop:
            # Calculate the index in bitmapData
            mul $s2, $t2, 6  # Multiply row index by number of columns (6)
            add $s2, $s2, $t1 # Add column index

            # Load the cell value
            add $t3, $t0, $s2
            lb $t3, 0($t3)  

            # Check if the cell contains 'X' or 'O'
            li $t4, 88  # ASCII for 'X'
            li $t5, 79  # ASCII for 'O'
            beq $t3, $t4, check_x_vertical
            beq $t3, $t5, check_o_vertical
            j reset_counters_vertical  # Reset counters if the cell contains neither 'X' nor 'O'

            check_x_vertical:
            addi $s0, $s0, 1
            li $s1, 1
            j check_win_vertical

            check_o_vertical:
            addi $s1, $s1, 1
            li $s0, 1
            j check_win_vertical

            reset_counters_vertical:
            li $s0, 0
            li $s1, 0

            check_win_vertical:
            li $t6, 4
            beq $s0, $t6, win_computer_vertical
            beq $s1, $t6, win_user_vertical

            # Increment row index and loop
            addi $t2, $t2, 1
            li $t6, 6
            blt $t2, $t6, vc_row_loop

        # Increment column index and loop
        addi $t1, $t1, 1
        blt $t1, 6, vc_column_loop

    # No win detected
    li $v0, 0
    j end_vertical_check

win_user_vertical:
    li $v0, 1  # User win
    jal user_win

win_computer_vertical:
    li $v0, 2  # Computer win
    jal computer_win

end_vertical_check:
    # Restore registers and return
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    addi $sp, $sp, 16
    jr $ra
    
.globl diagonal_check
diagonal_check:
    # Save registers
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $s0, 4($sp)  # Counter for 'X's
    sw $s1, 8($sp)  # Counter for 'O's
    sw $s2, 12($sp) # Row index
    sw $s3, 16($sp) # Column index

    la $t0, bitmapData  # Load base address of bitmapData

    # Check major diagonals (top-left to bottom-right)
    li $t1, 0  # Row index 
major_diag_loop:
    # Check if the row index is within bounds
    li $t7, 3
    bge $t1, $t7, end_major_diag_check  # Skip if row index is 3 or greater

    # Reset counters
    li $s0, 0  # Counter for 'X's
    li $s1, 0  # Counter for 'O's

    # Check the diagonal starting from this row
    move $t2, $t1  # Current row n col
    li $t3, 0      

    while_major_diag:

        mul $s2, $t2, 6  
        add $s2, $s2, $t3 


        add $t4, $t0, $s2
        lb $t4, 0($t4)

        li $t5, 88 
        li $t6, 79  
        beq $t4, $t5, x_found_major
        beq $t4, $t6, o_found_major
        j reset_counters_major

        x_found_major:
        addi $s0, $s0, 1
        li $s1, 0
        j check_win_major

        o_found_major:
        addi $s1, $s1, 1
        li $s0, 0
        j check_win_major

        reset_counters_major:
        li $s0, 0
        li $s1, 0

        check_win_major:
        li $t7, 4
        beq $s0, $t7, win_x_major
        beq $s1, $t7, win_o_major


        addi $t2, $t2, 1  # Increment row
        addi $t3, $t3, 1  # Increment column
        blt $t2, 6, while_major_diag

    # Increment starting row and loop
    addi $t1, $t1, 1
    j major_diag_loop

end_major_diag_check:
    # Check minor diagonals (top-right to bottom-left)
    li $t1, 5 
minor_diag_loop:
    # Check if the column index is within bounds
    li $t7, 2
    ble $t1, $t7, end_minor_diag_check  # Skip if column index is 2 or less

    # Reset counters
    li $s0, 0  
    li $s1, 0  

    # Check the diagonal starting from this column
    li $t2, 0   
    move $t3, $t1  

    while_minor_diag:
        mul $s2, $t2, 6  
        add $s2, $s2, $t3 

        # Load the cell value
        add $t4, $t0, $s2
        lb $t4, 0($t4)

        # Check for 'X' or 'O'
        li $t5, 88 
        li $t6, 79 
        beq $t4, $t5, x_found_minor
        beq $t4, $t6, o_found_minor
        j reset_counters_minor

        x_found_minor:
        addi $s0, $s0, 1
        li $s1, 0
        j check_win_minor

        o_found_minor:
        addi $s1, $s1, 1
        li $s0, 0
        j check_win_minor

        reset_counters_minor:
        li $s0, 0
        li $s1, 0

        check_win_minor:
        li $t7, 4
        beq $s0, $t7, win_x_minor
        beq $s1, $t7, win_o_minor

        # Move to next cell
        addi $t2, $t2, 1  # Increment row
        subi $t3, $t3, 1  # Decrement column
        blt $t2, 6, while_minor_diag

    # Decrement starting column and loop
    subi $t1, $t1, 1
    j minor_diag_loop

end_minor_diag_check:
    li $v0, 0
    j end_diagonal_check

win_x_major:
win_x_minor:
    li $v0, 2  # Set win status for computer
    j end_diagonal_check

win_o_major:
win_o_minor:
    li $v0, 1  # Set win status for user

end_diagonal_check:
    # Restore registers and return
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    addi $sp, $sp, 20
    jr $ra
