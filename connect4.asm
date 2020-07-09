# Created by Bikram Ce on 4/25/20.
# Copyright © 2020 Bikram Ce. All rights reserved.
# connect4.h
# Connect Four

.globl main
.text
   
# Global Register Map:
# $s0: m_w
# $s1: m_z
# $s2: ROW
# $s3: COL
# $s4: gameBoard
# $s5: colSpaceTrack
# $s6: currPlayer

# Function used set the range of values between which a random number will be generated
# using the function get_random and return the resultant random number
# Requires two arguments: low and high which is the lower and upper limit of the range
# Returns a Random Number
random_in_range:

   # Register Map for random_in_range:
   # $s0: m_w (global)
   # $s1: m_z (global)
   # $t0: range
   # $t1: rand_num
   # $t2: (rand_num % range) + low
   # $a0: low
   # $a1: high
   # $ra: Return Address of main
        
   # Storing Current $ra in Stack
   addi $sp, $sp, -4   # Adjust Stack Pointer
   sw $ra, 0($sp)      # Save current $ra (Return Address of main)
        
   # Function Operations
   # Operations involve generating specified range using the lower and upper limit
   # Operations also involve calling get_random to generate random number
   subu $t0, $a1, $a0  # range = high - low
   addiu $t0, $t0, 1   # result += 1
        
   # Function Call to get_random for generating a random number
   jal get_random      # Function Call to get_random
   move $t1, $v0       # rand_num = return value of get_random
   
   # Restore Saved Register Values of $ra from Stack in Opposite Order
   lw $ra, 0($sp)      # Restore $ra (Return Address of main)
   addi $sp, $sp, 4    # Adjust Stack Pointer
   
   # Compute Random Number
   divu $t1, $t0       # rand_num/range (Remainder Stored in $HI)
   mfhi $t2            # Copy remainder of rand_num/range from special register $HI to $t2
   addu $t2, $t2, $a0  # $t2 = (rand_num % range) + low
   
   # Return Resultant Random Number
   move $v0, $t2       # $v0 = (rand_num % range) + low (Save return value in $v0)
   jr $ra              # return to main

# Function Used to Generate a Random Number
# Requires 0 Arguments
# Returns result
get_random:
       
        # Register Map for get_random:
        # $s0: m_w (global)
        # $s1: m_z (global)
        # $t3: 36969
        # $t4: 18000
        # $t5: Used for first storing (m_z & 65535) and then rewrritten to (m_w & 65535)
        # $t6: Used for first storing (m_z >> 16) and then rewrritten to (m_w >> 16)
        # $t7: (m_z << 16)
        # $t9: result

        # Initializing Registers
        li $t3, 36969         # $t3 = 36969
        li $t4, 18000         # $t4 = 18000

        # Function Operations
        # Operations involve using the seeds m_z and m_w to generate a random number
        
        # Operations for Computing m_z
        andi $t5, $s1, 65535  # $t5 = (m_z & 65535)
        srl $t6, $s1, 16      # $t6 = (m_z >> 16)
        mul $s1, $t3, $t5     # m_z = 36969 * (m_z & 65535)
        addu $s1, $s1, $t6    # m_z += (m_z >> 16)
        
        # Operations for Computing m_w
        andi $t5, $s0, 65535  # $t5 = (m_w & 65535)
        srl $t6, $s0, 16      # $t6 = (m_w >> 16)
        mul $s0, $t4, $t5     # m_w = 18000 * (m_w & 65535)
        addu $s0, $s0, $t6    # m_w += (m_w >> 16)
        
        # Operations for Computing result
        sll $t7, $s1, 16      # $t7 = (m_z << 16)
        addu $t9, $t7, $s0    # result = (m_z << 16) + m_w
        
        # Return Resultant Random Number
        move $v0, $t9         # $v0 = result (Save return value in $v0)
        jr $ra                # return to random_in_range

# Function to Print Game Board
# Loops Through The Entire Array And Prints Value of All Locations
# Requires 0 Arguments
printGameBoard:

   # Register Map for get_random:
   # $s2: ROW (global)
   # $s3: COL (global)
   # $s4: Base Address of gameBoard (global)
   # $t0: i
   # $t1: j
   # $t3: Address of &gameBoard[i][j]
        
   # Storing Current $t0 and $t1 in Stack
   addi $sp, $sp, -4                    # Adjust Stack Pointer
   sw $t0, 0($sp)                       # Save current $t0 (Loop Counter i in main)
   addi $sp, $sp, -4                    # Adjust Stack Pointer
   sw $t1, 0($sp)                       # Save current $t1 (Loop Counter j in main)
   
   # Initializing Registers
   li $t0, 0                            # i = 0
            
   # Print Board Column Numbers
   li $v0, 4                            # print_string syscall code = 4
   la $a0, board1                       # load the address of board1
   syscall                              # system call
   
   # Print Board Borders
   li $v0, 4                            # print_string syscall code = 4
   la $a0, board2                       # load the address of board1
   syscall                              # system call
   
   # Outer FOR-LOOP
   FOR_PRINT_i: bge $t0, $s2, RETURN    # if(i >= ROW(6)), Branch to RETURN
                li $t1, 0               # j = 0
   
      # Inner FOR-LOOP
      # Access gameBoard[i][j]
      FOR_PRINT_j: bge $t1, $s3, NWLINE # if (j >= COL(9)), Branch to NWLINE
              mul $t3, $t0, $s3         # $t3 = i * COL
              add $t3, $t3, $t1         # $t3 += j
              add $t3, $s4, $t3         # $t3 = &gameBoard[i][j] (Base + Offset)
              
              # Print Board Array
              li $v0, 11                # print_char syscall code = 11
              lb $a0, 0($t3)            # $a0 = gameBoard[i][j]
              syscall                   # system call
              
              # Print Space in Board for Formatting Purposes
              li $v0, 4                 # print_string syscall code = 4
              la $a0, board3            # load the address of board3
              syscall                   # system call
             
              addi $t1, $t1, 1          # j++
              j FOR_PRINT_j             # jump to FORPRINTj
   
      # Print New Line and Jump to Outer Loop
      NWLINE:  li $v0, 4                # print_string syscall code = 4
               la $a0, newline          # load the address of board3
               syscall                  # system call
               addi $t0, $t0, 1         # i++
               j FOR_PRINT_i            # jump to Outer Loop
   
   # Restore Register Values From Stack and Return to main
   # Print Board Borders
   RETURN: li $v0, 4                    # print_string syscall code = 4
           la $a0, board2               # load the address of board2
           syscall                      # system call
   
           # Restore Saved Register Values of $t0 and $t1 from Stack in Opposite Order
           lw $t1, 0($sp)               # Restore $t1 (Loop Counter j in main)
           addi $sp, $sp, 4             # Adjust Stack Pointer
           lw $t0, 0($sp)               # Restore $t0 (Loop Counter i in main)
           addi $sp, $sp, 4             # Adjust Stack Pointer
           jr $ra                       # Return to main
      
# Check if Either Player or Computer has Won the Game
# Detect if 5 Tokens are Connected Either Horizontally, Vertically, or Diagonally
# Requires 0 Arguments
isGameOver:

   # Register Map for isGameOver:
   # $s0: m_w (global)
   # $s1: m_z (global)
   # $s2: ROW (global)
   # $s3: COL (global)
   # $s4: Base Address of gameBoard (global)
   # $s5: Base Address of colSpaceTrack (global)
   # $s6: currPlayer (global)
   # $t0: i (Outer Loop Counter)
   # $t1: j (Middle Loop Counter)
   # $t2: k (Inner Loop Counter)
   # $t3: Value of gameBoard[i][j]
   # $t4: numHori (Number of Horizontal Matches)
   # $t5: numVert (Number of Vertical Matches)
   # $t6: numRD (Number of Right Diagonal Matches)
   # $t7: numLD (Number of Left Diagonal Matches)
   # $t8: 5 (Inner Loop Limit)
   # $t9: j + k, j - k
   # $s7: i + k
   # $a0: 2
   # $a1: 3
   
   # Initializing Registers
   li $t0, 0                                     # i = 0
   li $t1, 0                                     # j = 0
   li $t8, 5                                     # $t8 = 5
   li $a0, 2                                     # $a0 = 2
   li $a1, 3                                     # $a1 = 3
   
   # Outer For-Loop
   FOR_OUT: bge $t0, $s2, RETURN_CONT            # if (i >= ROW), Branch to RETURN_CONT
            li $t1, 0                            # j = 0
             
      # Middle For-Loop
      FOR_MID: bge $t1, $s3, INCi                # if (j >= COL), Branch to INCi
               li $t2, 0                         # k = 0
               li $t4, 0                         # numHori = 0
               li $t5, 0                         # numVert = 0
               li $t6, 0                         # numRD = 0
               li $t7, 0                         # numLD = 0

         FOR_IN: bge $t2, $t8, IS_WIN            # if(k >= 5), Branch to IS_WIN
                 add $s7, $t0, $t2               # $s7 = i + k
                 add $t9, $t1, $t2               # $t9 = j + k
                 
                 # Check if 5 Tokens are Connected Horizontally
                 IF_HOR:  bge $t1, $t8, IF_VER   # if(j >= 5), Branch to IF_VER
                          
                          # Access gameBoard[i][j + k]
                          # If gameBoard[i][j + k] != currPlayer, G
                          mul $t3, $t0, $s3      # $t3 = i * COL
                          add $t3, $t3, $t9      # $t3 += (j + k)
                          add $t3, $s4, $t3      # $t3 = &gameBoard[i][j + k] (Base + Offset)
                          lb $t3, 0($t3)         # $t3 = gameBoard[i][j + k]
                          bne $t3, $s6, IF_VER   # if(gameBoard[i][j + k] != currPlayer), Branch to IF_VER
                                   
                          # If gameBoard[i][j + k] = currPlayer, Increment numHori
                          addi $t4, $t4, 1       # numHori++
                        

                 # Check if 5 Tokens are Connected Vertically
                 IF_VER: bge $t0, $a0, IF_RD     # if(i >= 2), Branch to IF_RD
                        
                         # Access gameBoard[i + k][j]
                         # If gameBoard[i + k][j] != currPlayer, Break from Loop
                         mul $t3, $s7, $s3       # $t3 = (i + k) * COL
                         add $t3, $t3, $t1       # $t3 += j
                         add $t3, $s4, $t3       # $t3 = &gameBoard[i + k][j] (Base + Offset)
                         lb $t3, 0($t3)          # $t3 = gameBoard[i + k][j]
                         bne $t3, $s6, IF_RD     # if(gameBoard[i + k][j] != currPlayer), Branch to IF_RD
                                   
                         # If gameBoard[i + k][j] = currPlayer, Increment numVert
                         addi $t5, $t5, 1        # numVert++
                
                 # Check if 5 Tokens are Connected Right-Diagonally
                 IF_RD:  bge $t0, $a0, IF_LD     # if(i >= 2), Branch to IF_LD
                         bge $t1, $t8, IF_LD     # if(j >= 5), Branch to IF_LD
                         
                         # Access gameBoard[i + k][j + k]
                         # If gameBoard[i + k][j + k] != currPlayer, Break from Loop
                         mul $t3, $s7, $s3       # $t3 = (i + k) * COL
                         add $t3, $t3, $t9       # $t3 += (j + k)
                         add $t3, $s4, $t3       # $t3 = &gameBoard[i + k][j + k] (Base + Offset)
                         lb $t3, 0($t3)          # $t3 = gameBoard[i + k][j + k]
                         bne $t3, $s6, IF_LD     # if(gameBoard[i + k][j + k] != currPlayer), Branch to IF_LD
                                   
                         # If gameBoard[i + k][j + k] = currPlayer, Increment numRD
                         addi $t6, $t6, 1        # numRD++
                
                 # Check if 5 Tokens are Connected Left-Diagonally
                 IF_LD:  bge $t0, $a0, INCk      # if(i >= 2), Branch to INCk
                         ble $t1, $a1, INCk      # if(j <= 3), Branch to INCk
                         sub $t9, $t1, $t2       # $t9 = j - k
                         
                         # Access gameBoard[i + k][j - k]
                         # If gameBoard[i + k][j + k] != currPlayer, Break from Loop
                         mul $t3, $s7, $s3       # $t3 = (i + k) * COL
                         add $t3, $t3, $t9       # $t3 += (j - k)
                         add $t3, $s4, $t3       # $t3 = &gameBoard[i + k][j - k] (Base + Offset)
                         lb $t3, 0($t3)          # $t3 = gameBoard[i + k][j - k]
                         bne $t3, $s6, INCk      # if(gameBoard[i + k][j - k] != currPlayer), Branch to INCk
                                   
                         # If gameBoard[i + k][j - k] = currPlayer, Increment numLD, k, and Loop
                         addi $t7, $t7, 1        # numLD++
                         
                         # Increment k, Continue to Iterate in Inner Loop
                         INCk: addi $t2, $t2, 1  # k++
                               j FOR_IN          # jump to FOR_IN
                               

         # Check If There Are 5 Tokens in a Row
         # If Match Not Found, Continue to Iterate in Middle Loop
         IS_WIN: beq $t4, $t8, RETURN_WIN        # if(numHori == 5), Branch to RETURN_WIN
                 beq $t5, $t8, RETURN_WIN        # if(numVert == 5), Branch to RETURN_WIN
                 beq $t6, $t8, RETURN_WIN        # if(numRD == 5), Branch to RETURN_WIN
                 beq $t7, $t8, RETURN_WIN        # if(numLD == 5), Branch to RETURN_WIN
                 addi $t1, $t1, 1                # j++
                 j FOR_MID                       # jump to FOR_MID
      
      # Increment i, Continue to Iterate in Outer Loop
      INCi: addi $t0, $t0, 1                     # i++
            j FOR_OUT                            # jump to FOR_OUT
   
   # Return 1, if 5 Tokens in a Row is Not Detected
   RETURN_CONT: li $v0, 1                        # $v0 (Return Value) = 1
                jr $ra                           # Return to main

   
   # Return 0, if 5 Tokens in a Row is Detected
   RETURN_WIN: li $v0, 0                         # $v0 (Return Value) = 0
               jr $ra                            # Return to main


# Detect if Game is a Draw
# Consists of a For-Loop Which Traverses The Array To Check if Any '.' is Present
# If '.' is Not Present, Game is a Draw
# Requires 0 Arguments
isDraw:
        # Register Map for isDraw:
        # $s2: ROW (global)
   # $s3: COL (global)
   # $s4: Base Address of gameBoard (global)
        # $t3: Value of gameBoard[i][j]
        # $t4: '.'
        # $t5: i (Outer Loop Counter)
        # $t6: j (Inner Loop Counter)
        
        # Initializing Registers
        li $t4, '.'  # $t4 = '.'
        li $t5, 0    # i = 0
        
        # Operations for Check if any '.' is Present in gameBoard[i][j]
   # Outer FOR-LOOP
   FORi_DRAW: bge $t5, $s2, RETURN_D0    # if(i >= ROW(6)), Branch to RETURN_D0
              li $t6, 0                  # j = 0
   
      # Inner FOR-LOOP
      # Access gameBoard[i][j]
      FORj_DRAW: bge $t6, $s3, end_DRAW  # if (j >= COL(9)), Branch to end_DRAW
            mul $t3, $t5, $s3            # $t3 = i * COL
            add $t3, $t3, $t6            # $t3 += j
            add $t3, $s4, $t3            # $t3 = &gameBoard[i][j] (Base + Offset)
            lb $t3, 0($t3)               # $t3 = gameBoard[i][j]
            beq $t3, $t4, RETURN_D1      # if(gameBoard[i][j] == '.'), Branch to RETURN_D1
            addi $t6, $t6, 1             # j++
            j FORj_DRAW                  # jump to FORj_DRAW

   end_DRAW:  addi $t5, $t5, 1           # i++
              j FORi_DRAW                # jump to FORi_DRAW
   
   # Return 1 to Indicate That Game is a Draw
   RETURN_D0: li $v0, 0                  # $v0 (Return Value = 0)
              jr $ra                     # Return to main
              
   # Return 1 to Indicate That Game is Not a Draw
   RETURN_D1: li $v0, 1                  # $v0 (Return Value = 1)
              jr $ra                     # Return to main
       
# Validates and Inserts User's Move in Board
# Requires 0 Arguments
userMove:
        # Register Map for userMove
        # $s4: Base Address of gameBoard (global)
        # $s5: Base Address of colSpaceTrack (global)
        # $s6: currPlayer (global)
        # $t2: userCol
        # $t3: Value of gameBoard[i][j]
        # $t4: &colSpaceTrack[]
        # $t5: userCol - 1
        # $t6: 4
        # $t7: colSpaceTrack[]
        # $t8: 1
        # $t9: 7
        
        # Initializing Registers
        li $s6, 'H'                    # currPlayer = 'H'
        li $t6, 4                      # $t6 = 4
        li $t8, 1                      # $t8 = 1
        li $t9, 7                      # $t9 = 7
   
   # Print, Ask and Validate User's Move. Loop if Invalid.
   DO_UMOVE: li $v0, 4                 # print_string syscall code = 4
             la $a0, getCol            # load the address of getCol
             syscall                   # system call
             
             # Ask User to Enter Column Number Between 1-7
             li $v0, 5                 # read_int syscall code = 5
             syscall                   # system call
             move $t2, $v0             # $t2 (userCol) = $v0 (User Input)
             
             blt $t2, $t8, ERROR_U     # if(userCol < 1), Branch to ERROR_U
             bgt $t2, $t9, ERROR_U     # if(userCol > 7), Branch to ERROR_U
             
             # Operations for obtaining colSpaceTrack[userCol - 1]
             # Check if colSpaceTrack[userCol - 1] is less than 0
             addi $t5, $t2, -1         # $t5 = userCol - 1
             mul $t4, $t5, $t6         # $t4 = i(userCol - 1) * 4 (index times 4 bytes)
             add $t4, $s5, $t4         # $t4 = &colSpaceTrack[userCol - 1] (Base + Offset)
             lw $t7, 0($t4)            # $t7 = colSpaceTrack[userCol - 1]
             blt $t7, $zero, ERROR_U   # if(colSpaceTrack[userCol - 1] < 0), Branch to ERROR_U
             j BREAK_U                 # jump to BREAK_U if Above Condtions are Not Met
             
             # If Any of the Above Conditions are Not Satisfied, Print Error Message and Loop
             ERROR_U: li $v0, 4        # print_string syscall code = 4
                      la $a0, error    # load the address of error
                      syscall          # system call
                      j DO_UMOVE       # jump to DO_UMOVE
            
   # Set Next Available Row in userCol to 'H'
   # Store 'H' in gameBoard[colSpaceTrack[userCol - 1]][userCol]
   BREAK_U: mul $t3, $t7, $s3          # $t3 = $t7(colSpaceTrack[userCol - 1]) * COL
            add $t3, $t3, $t2          # $t3 += $t2 (userCol)
            add $t3, $s4, $t3          # $t3 = &gameBoard[i][j] (Base + Offset)
            sb $s6, 0($t3)             # gameBoard[i][0] = 'H' (Store 'H' in gameBoard[i][userCol])
   
            # Decrement by 1 to Indicate the Next Row in userCol Which is Available
            addi $t7, $t7, -1          # colSpaceTrack[userCol - 1]--
            sw $t7, 0($t4)             # Store $t7 in Array colSpaceTrack[userCol - 1]
            jr $ra                     # Return to main
            
# Randomly Generates a Valid Move For The Computer
# Requires 0 Arguments
compMove:

        # Register Map for compMove:
        # $s4: Base Address of gameBoard (global)
        # $s5: Base Address of colSpaceTrack (global)
        # $s6: currPlayer (global)
        # $a0: 1 (Lower Limit)
        # $a1: 7 (Upper Limit)
        # $t2: compCol
        # $t3: Value of gameBoard[i][j]
        # $t4: &colSpaceTrack[]
        # $t5: compCol - 1
        # $t6: 4
        # $t7: colSpaceTrack[]
        
        # Initializing Registers
        li $s6, 'C'                        # currPlayer = 'C'
        li $a0, 1                          # $a0 = 1
        li $a1, 7                          # $a1 = 7
        
        # Storing Current $ra in Stack
        addi $sp, $sp, -4                  # Adjust Stack Pointer
        sw $ra, 0($sp)                     # Save Return Address of main
   
        DO_CMOVE: jal random_in_range      # Function Call to random_in_range
                  move $t2, $v0            # $t2 (compCol) = return value of random_in_range
                  addi $t5, $t2, -1        # $t5 = compCol - 1
                  blt $t2, $a0, DO_CMOVE   # if(compcol < 1), Branch to DO_CMOVE
                  bgt $t2, $a1, DO_CMOVE   # if(compcol > 7), Branch to DO_CMOVE
                   
                  # Operations for obtaining colSpaceTrack[compCol - 1]
                  li $t6, 4                # $t6 = 4
                  mul $t4, $t5, $t6        # $t4 = i(compCol - 1) * 4 (index times 4 bytes)
                  add $t4, $s5, $t4        # $t4 = &colSpaceTrack[compCol - 1] (Base + Offset)
                  lw $t7, 0($t4)           # $t7 = colSpaceTrack[compCol - 1]
                  
                  blt $t7, $zero, DO_CMOVE # if(colSpaceTrack[compCol - 1] < 0), Branch to DO_CMOVE
         
        # Set Next Available Row in compCol to 'C'
        # Store 'C' in gameBoard[colSpaceTrack[compCol - 1]][compCol]
        mul $t3, $t7, $s3                  # $t3 = $t7(colSpaceTrack[compCol - 1]) * COL
        add $t3, $t3, $t2                  # $t3 += $t2 (compCol)
        add $t3, $s4, $t3                  # $t3 = &gameBoard[i][j] (Base + Offset)
        sb $s6, 0($t3)                     # gameBoard[][compCol] = 'C' (Store 'C' in gameBoard[i][compCol])
          
        # Decrement by 1 to Indicate the Next Row in compCol Which is Available
        addi $t7, $t7, -1                  # colSpaceTrack[compCol - 1]--
        sw $t7, 0($t4)                     # Store $t7 in Array colSpaceTrack[compCol - 1]
                          
        # Restore Saved Register Values of $ra from Stack in Opposite Order
        lw $ra, 0($sp)                     # Restore Return Address of main
        addi $sp, $sp, 4                   # Adjust Stack Pointer
              
        # Print Computer's Column
        li $v0, 4                          # print_string syscall code = 4
        la $a0, comp1                      # load the address of comp1
        syscall                            # system call
         
        # Print Computer's Column Number
        li $v0, 1                          # print_int syscall code = 1
        move $a0, $t2                      # $a0 = compCol
        syscall                            # system call
         
        # Print Newline
        li $v0, 4                          # print_string syscall code = 4
        la $a0, newline                    # load the address of newline
        syscall                            # system call
         
        jr $ra                             # Return to main

# The label 'main' represents the starting point
# Generates two random numbers and computes the GCD of them
main:

   # Register Map for main:
        # $s0: m_w (global)
   # $s1: m_z (global)
   # $s2: ROW (global)
   # $s3: COL (global)
   # $s4: Base Address of gameBoard (global)
   # $s5: Base Address of colSpaceTrack (global)
   # $s6: currPlayer (global)
   # $t0: i (Outer Loop Counter), Return Value of isGameOver()
   # $t1: j (Inner Loop Counter), Return Value of isDraw()
   # $t2: tossResult
   # $t3: Value of gameBoard[i][j]
   # $t4: '.'
   # $t5: 2 (For i % 2)
   # $t6: i % 2
   # $t7: 'C'
   # $t8: 'H'
   
   # Initialize Registers
   lw $s0, m_w                  # Load memory m_w to $s0
   lw $s1, m_z                  # Load memory m_z to $s1
   lw $s2, ROW                  # Load memory ROW to $s2
   lw $s3, COL                  # Load memory COL to $s3
   la $s4, gameBoard            # Load address of gameBoard to $s4
   la $s5, colSpaceTrack        # Load address of colSpaceTrack to $s5
   lb $s6, currPlayer           # Load memory currPlayer to $s6
   li $t0, 0                    # i = 0
   li $t4, '.'                  # $t4 = '.'
   li $t5, 2                    # $t5 = 2
   li $t7, 'C'                  # $t7 = 'C'
   li $t8, 'H'                  # $t8 = 'H'
   
   # Print Intro. Messages
   li $v0, 4                    # print_string syscall code = 4
   la $a0, start                # load the address of start
   syscall                      # system call
   
   li $v0, 4                    # print_string syscall code = 4
   la $a0, start1               # load the address of start1
   syscall                      # system call
   
   li $v0, 4                    # print_string syscall code = 4
   la $a0, start2               # load the address of start2
   syscall                      # system call
   
   # Operations for Storing '.' in gameBoard[i][j]
   # Outer FOR-LOOP
   FORi: bge $t0, $s2, RESET    # if(i >= ROW(6)), Branch to FORi1
         li $t1, 0              # j = 0
   
      # Inner FOR-LOOP
      FORj: bge $t1, $s3, endFOR   # if (j >= COL(9)), Branch to endFOR
            mul $t3, $t0, $s3      # $t3 = i * COL
            add $t3, $t3, $t1      # $t3 += j
            add $t3, $s4, $t3      # $t3 = &gameBoard[i][j] (Base + Offset)
            sb $t4, 0($t3)         # gameBoard[i][j] = '.' (Store '.' in gameBoard[i][j])
            addi $t1, $t1, 1       # j++
            j FORj                 # jump to FORj
   
      endFOR: addi $t0, $t0, 1     # i++
              j FORi               # jump to FORi
           
   RESET: li $t0, 0                # i = 0
   
   # Operations for Populating First and Last Column with Alternating Player Tokens
   FORi1: bge $t0, $s2, getRAND # if(i >= ROW(6)), Branch to getRAND
          div $t0, $t5          # i/2
          mfhi $t6              # $t6 = i % 2
          
          # Store 'C' in gameBoard[i][0] and gameBoard[i][8] such that i % 2 = 0
          bne $t6, $zero, ELSE_ODD  # if(i % 2) != 0, Branch to ELSE_ODD
          mul $t3, $t0, $s3     # $t3 = i * COL
          add $t3, $s4, $t3     # $t3 = &gameBoard[i][j] (Base + Offset)
          sb $t7, 0($t3)        # gameBoard[i][0] = 'C' (Store 'C' in gameBoard[i][0])
          
          mul $t3, $t0, $s3     # $t3 = i * COL
          addi $t3, $t3, 8      # $t3 += j
          add $t3, $s4, $t3     # $t3 = &gameBoard[i][j] (Base + Offset)
          sb $t7, 0($t3)        # gameBoard[i][8] = 'C' (Store 'C' in gameBoard[i][8])
          addi $t0, $t0, 1      # i++
          j FORi1               # jump to FORi1
          
          # Store 'H' in gameBoard[i][0] and gameBoard[i][8] such that i % 2 != 0
          ELSE_ODD: mul $t3, $t0, $s3     # $t3 = i * COL
                    add $t3, $s4, $t3     # $t3 = &gameBoard[i][j] (Base + Offset)
                    sb $t8, 0($t3)        # gameBoard[i][0] = 'H' (Store 'H' in gameBoard[i][0])
          
                    mul $t3, $t0, $s3     # $t3 = i * COL
                    addi $t3, $t3, 8      # $t3 += j(8)
                    add $t3, $s4, $t3     # $t3 = &gameBoard[i][j] (Base + Offset)
                    sb $t8, 0($t3)        # gameBoard[i][8] = 'H' (Store 'H' in gameBoard[i][8])
                    addi $t0, $t0, 1      # i++
                    j FORi1               # jump to FORi1
   
   # Print Messages and Ask For Two Random Numbers From The User
   getRAND:
   li $v0, 4                    # print_string syscall code = 4
   la $a0, getNum               # load the address of getNum
   syscall                      # system call
   
   li $v0, 4                    # print_string syscall code = 4
   la $a0, getNum1              # load the address of getNum1
   syscall                      # system call
   
   # Get First Number From The User and Save
   li $v0, 5                    # read_int syscall code = 5
   syscall                      # system call
   move $s0, $v0                # $s0 (m_w) = $v0 (User Input)
   
   li $v0, 4                    # print_string syscall code = 4
   la $a0, getNum2              # load the address of getNum2
   syscall                      # system call
   
   # Get Second Number From The User and Save
   li $v0, 5                    # read_int syscall code = 5
   syscall                      # system call
   move $s1, $v0                # $s1 (m_z) = $v0 (User Input)
   
   # Print Game Legend
   li $v0, 4                    # print_string syscall code = 4
   la $a0, legend1              # load the address of legend1
   syscall                      # system call
   
   li $v0, 4                    # print_string syscall code = 4
   la $a0, legend2              # load the address of legend2
   syscall                      # system call
   
   # Call random_in_range To Generate Random Number Between 0 and 1
   li $a0, 0                    # $a0 = 0
   li $a1, 1                    # $a1 = 1
   jal random_in_range          # Function Call to random_in_range
   move $t2, $v0                # $t2 (tossResult) = return value of random_in_range
   
   # If Coin Toss Generates 0, Then Computer Plays First, Else Human Plays First
   # Consists of Do-While Loop Which Keeps Looping Until Game is Over
   # Consistently Asks Computer For a Move First Followed by the User or Human
   # Prints Board After Each Player's Turn
   bne $t2, $zero, ELSE_HUMAN   # if(tossResult != 0), Branch to ELSE_HUMAN
   
   # Print Result of Coin Toss When tossResult = 0
   li $v0, 4                    # print_string syscall code = 4
   la $a0, game1                # load the address of game1
   syscall                      # system call
   
   # Keeps Looping Until Either Computer or Human Wins or When The Game is a Draw
   DO_COMP: jal compMove              # Function Call to compMove() to Compute Computer's Move First
            jal printGameBoard        # Function Call to printGameBoard
            
            # Check Game Status
            jal isGameOver            # Function Call to isGameOver
            move $t0, $v0             # $t0 = $v0 (Return Value of isGameOver())
            jal isDraw                # Function Call to isDraw to Check if Game is a Draw
            move $t1, $v0             # $t1 = $v0 (Return Value of isDraw())
            
            # if(isGameOver() == 0 || isDraw() == 0), Break from Do-While Loop
            beq $t0, $zero, END_GAME  # if(isGameOver() == 0), Branch to END_GAME
            beq $t1, $zero, END_GAME  # if(isDraw() == 0), Branch to END_GAME
            
            # Get User's Move and Print Board
            jal userMove              # Function Call to userMove to get User's Move
            jal printGameBoard        # Function Call to printGameBoard
            
            # Check Game Status
            jal isGameOver            # Function Call to isGameOver
            move $t0, $v0             # $t0 = $v0 (Return Value of isGameOver())
            jal isDraw                # Function Call to isDraw to Check if Game is a Draw
            move $t1, $v0             # $t1 = $v0 (Return Value of isDraw())
            
            # Loop if Game is Not Over, Branch to END_Game Otherwise
            beq $t0, $zero, END_GAME  # if(isGameOver() == 0), Branch to END_GAME
            beq $t1, $zero, END_GAME  # if(isDraw() == 0), Branch to END_GAME
            j DO_COMP                 # jump to DO_COMP if (isGameOver() != 0 && isDraw() != 0)
   
   # If Coin Toss Generates 1, User Plays First
   # Print Result of Coin Toss When tossResult = 1 and Print Initial Board
   # Consists of Do-While Loop Which Keeps Looping Until Game is Over
   # Prints Board After Each Player's Turn
   ELSE_HUMAN: li $v0, 4              # print_string syscall code = 4
               la $a0, game2          # load the address of game2
               syscall                # system call
               jal printGameBoard     # Function Call to printGameBoard
               
               # Keeps Looping Until Either Computer or Human Wins or When The Game is a Draw
               DO_USER: jal userMove          # Function Call to userMove() to Compute User's Move First
                        
                   # Check Game Status
                   jal isGameOver             # Function Call to isGameOver
                   move $t0, $v0              # $t0 = $v0 (Return Value of isGameOver())
                   jal isDraw                 # Function Call to isDraw to Check if Game is a Draw
                   move $t1, $v0              # $t1 = $v0 (Return Value of isDraw())
                    
                   # if(isGameOver() == 0 || isDraw() == 0), Branch to EXIT_LOOP
                   beq $t0, $zero, EXIT_GAME  # if(isGameOver() == 0), Branch to EXIT_GAME
                   beq $t1, $zero, EXIT_GAME  # if(isDraw() == 0), Branch to EXIT_GAME
                        
                   # Get Computer's Move and Print Board
                   jal compMove               # Function Call to userMove to get User's Move
                   jal printGameBoard         # Function Call to printGameBoard
                        
                   # Check Game Status
                   jal isGameOver             # Function Call to isGameOver
                   move $t0, $v0              # $t0 = $v0 (Return Value of isGameOver())
                   jal isDraw                 # Function Call to isDraw to Check if Game is a Draw
                   move $t1, $v0              # $t1 = $v0 (Return Value of isDraw())
                    
                   # Loop if Game is Not Over, Branch to END_GAME Otherwise
                   beq $t0, $zero, END_GAME   # if(isGameOver() == 0), Branch to END_GAME
                   beq $t1, $zero, END_GAME   # if(isDraw() == 0), Branch to END_GAME
                   j DO_USER                  # jump to DO_COMP if (isGameOver() != 0 && isDraw() != 0)
                        
   # Print Board When User Plays First and Wins
   EXIT_GAME: jal printGameBoard        # Function Call to printGameBoard
   
   # Print Appropriate Results
   END_GAME: beq $t1, $zero, PRINT_DRAW # if(isDraw() == 0), Branch to PRINT_DRAW
        li $t7, 'C'                     # $t7 = 'C'
             beq $s6, $t7, PRINT_LOST   # if(currPlayer == 'C'), Branch to PRINT_LOST
             j PRINT_WON                # jump to PRINT_WON
   
   # Print Message to Indicate That Game is a Draw
   PRINT_DRAW: li $v0, 4                # print_string syscall code = 4
          la $a0, draw                  # load the address of draw
          syscall                       # system call
          j EXIT                        # jump to EXIT
   
   # Print Message to Indicate That the User Has Lost the Game
   PRINT_LOST: li $v0, 4                # print_string syscall code = 4
          la $a0, lost                  # load the address of lost
          syscall                       # system call
          j EXIT                        # jump to EXIT
   
   # Print Message to Indicate That the User Has Won the Game
   PRINT_WON: li $v0, 4                 # print_string syscall code = 4
         la $a0, won                    # load the address of won
         syscall                        # system call
        
   # Update Register Values in Memory
   EXIT: sw $s0, m_w                    # Update memory m_w from $s0
         sw $s1, m_z                    # Update memory m_z fro  $s1
         sb $s6, currPlayer             # Update memory currPlayer from $s6
    
   # Exit the program by means of a syscall.
   li $v0, 10 # Sets $v0 to "10" to select exit syscall
   syscall    # Exit

   # All memory structures are placed after the
   # .data assembler directive
   .data

   # The .word assembler directive reserves space
   # in memory for a single 4-byte word (or multiple 4-byte words)
   # and assigns that memory location an initial value
   # (or a comma separated list of initial values)
   
   # Messages
   start:   .asciiz "Welcome to Connect Four, Five-in-a-Row variant!"
   start1:  .asciiz "\nVersion 1.0"
   start2:  .asciiz "\nDeveloped by Bikram Chatterjee\n\n"
   getNum:  .asciiz "Enter two positive numbers to initialize the random number generator.\n"
   getNum1: .asciiz "Number 1: "
   getNum2: .asciiz "Number 2: "
   legend1: .asciiz "Human player (H)"
   legend2: .asciiz "\nComputer player (C)"
   game1:   .asciiz "\nCoin toss... COMPUTER goes first.\n\n"
   game2:   .asciiz "\nCoin toss... HUMAN goes first.\n"
   board1:  .asciiz "\n  1 2 3 4 5 6 7\n"
   board2:  .asciiz "-----------------\n"
   board3:  .asciiz " "
   getCol:  .asciiz "What column would you like to drop token into? Enter 1-7: "
   error:   .asciiz "\nERROR 100: Selected Column is Full or Does Not Exist. Try Again.\n\n"
   comp1:   .asciiz "Computer player selected column "
   draw:    .asciiz "Draw!"
   lost:    .asciiz "You Lost!"
   won:     .asciiz "Congratulations, Human Winner!"
   newline: .asciiz "\n"

   # Global Variables
   m_w: .word 50000                          # Allocating 50000 32-bit value for m_w
   m_z: .word 60000                          # Allocating 60000 32-bit value for m_z
   ROW: .word 6                              # Allocating 6 32-bit value for ROW
   COL: .word 9                              # Allocating 9 32-bit value for COL
   colSpaceTrack: .word 5, 5, 5, 5, 5, 5, 5  # Initializing array colSpaceTrack[7]
   gameBoard: .space 54                      # Initializing array gameBoard[6][9] (Total bytes = 9 * 6 = 54)
   currPlayer: .space 1                      # Initializing currPLayer
