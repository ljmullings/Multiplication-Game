# Multiplication-Game
MIPS Project 2- Multiplication Game

The game is for two players: the user v.s. the computer. The numbers in the board do not change (they must be a product of 2 numbers.)
The game board is displayed using ASCII characters (e.g. ., -, +, and |) is the minimum requirement. Creative ways to display the board, e.g. with graphic, will earn the team extra credits.
Implementation of a winning strategy by the computer is NOT required but will earn extra credits if implemented.
All moves by the user and the computer MUST be valid according to the rules of the game.
An error message is displayed to explain the rule that was violated if a move by the user was not valid, e.g., the multiplication result is not on the board.
Extra credits will be given for:

A winning strategy for the computer is implemented and documented.

# Tasks 
(UPDATE README.MD BY ADDING YOUR INITIALS TO INDICATE PROGRESS/COMPLETION)
1. **Create a method to modify gameboard**: Mips code needed to alter the gameboard when computer or user selects. MUST BE DIFFERENT SYMBOLS (MEDIUM)

2. **Create logic to search board for location of product**: After Multiplication Logic has been created, take that product and find its location then call the modify method* (EASY)

3. **Create multiplication logics**: Multiply the two numbers selected (EASY)

4. **Create logic for computer to generate a number (1-9)** Needs to proabbly be random, can select the currently selected number  (MEDIUM)

5. **Create logic for computer to select a number before user selects number** (EASY, DO WITH TASK 4)

6. **Compile gameplay logic**: Put into a loop that ends when the computer or the user wins. 

7. **Handle Game over**: Add text that notifies the user of the winner and the loser

# order of completion at its most efficient:
 print display ->  logic for computer select -> logic for user select -> multiplication logic -> select value in matrix logic -> modify display -> loop -> end game 
 print display is done. 
# Extra Credit
(Last Priority, only if we have extra time)

1. Create logic for winning for computer (HARD)

2. Add Graphic and Sound (MEDIUM) 
