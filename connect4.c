//  Created by Bikram Ce on 4/25/20.
//  Copyright © 2020 Bikram Ce. All rights reserved.
//  connect4.c
//  Connect Four

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "connect4.h"

int ROWS = 6;
int COL = 9;
int colSpaceTrack[7] = {5, 5, 5, 5, 5, 5, 5}; // Tracks Current Available Row in Column Marked by Index
char gameBoard[6][9]; // Game Board 2D Array
char currPlayer; // Tracks Current Player
uint32_t m_w = 50000, m_z = 60000; // Random Number Generation

// Generate Random Number in Range
uint32_t random_in_range(uint32_t low, uint32_t high) {
  uint32_t range = high - low + 1;
  uint32_t rand_num = get_random();
  return (rand_num % range) + low;
}

// Generate Random Number
uint32_t get_random() {
   m_z = 36969 * (m_z & 65535) + (m_z >> 16);
   m_w = 18000 * (m_w & 65535) + (m_w >> 16);
   return (m_z << 16) + m_w;
}

// Print Board
void printGameBoard() {
   int i = 0, j = 0;
   
   printf("\n  1 2 3 4 5 6 7\n");
   printf("-----------------\n");
   for(i = 0; i < 6; i++) {
      for(j = 0; j < 9; j++) {
         printf("%c", gameBoard[i][j]);
         printf(" ");
      }
      printf("\n");
   }
   printf("-----------------\n");
}

// Check if Either Player or Computer has Won the Game
// Detect if 5 Tokens are Connected Either Horizontally, Vertically, or Diagonally
int isGameOver() {
   int i = 0, j = 0, k = 0, numHori, numVert, numLD, numRD;
   
   for (i = 0; i < 6; i++) {
      for (j = 0; j < 9; j++) {
         numHori = 0;
         numVert = 0;
         numRD = 0;
         numLD = 0;
         
         for (k = 0; k < 5; k++) {
         
            // Check Horizontal
            if (j < 5 && gameBoard[i][j + k] == currPlayer) {
               numHori++;
            }
         
            // Check Vertical
            if (i < 2 && gameBoard[i + k][j] == currPlayer) {
               numVert++;
            }
         
            // Check Diagonal (Right Down)
            if (i < 2 && j < 5 && gameBoard[i + k][j + k] == currPlayer){
               numRD++;
            }

            // Check Diagonal (Left Down)
            if (i < 2 && j > 3 && gameBoard[i + k][j - k] == currPlayer){
               numLD++;
            }
         }
         
         // Player Wins if 5 Tokens are in a Row
         if(numHori == 5 || numVert == 5 || numRD == 5 || numLD == 5) {
            return 0;
         }
      }    
   }
   return 1;
}

// Detect if Game is a Draw
int isDraw(){
   int i = 0, j = 0;
   
   for (i = 0; i < 6; i++) {
      for(j = 0; j < 9; j++) {
         if(gameBoard[i][j] == '.') { return 1; }
      }
   }
   return 0;
}

// Validates and Inserts User's Move in Board
void userMove() {
   int userCol;
   currPlayer = 'H';
   do{
      printf("What column would you like to drop token into? Enter 1-7: ");
      if(scanf("%d", &userCol) == 0) { ROWS = 6; }
      
      if(userCol >= 1 && userCol <= 7 && colSpaceTrack[userCol - 1] >= 0) {
         break; // Break, if User Has Selected Valid Column
      }
      
      printf("\nERROR 100: Selected Column is Full or Does Not Exist. Try Again.\n\n");
   } while(1);
   gameBoard[colSpaceTrack[userCol - 1]][userCol] = 'H'; // Set Next Available Row in userCol to 'H'
   colSpaceTrack[userCol - 1]--; // Decrement by 1 to Indicate the Next Row in userCol Which is Available
}

// Generates, Validates and Inserts Computer's Move
void compMove() {
   int compCol;
   currPlayer = 'C';
   do {
      compCol = random_in_range(1, 7);
   } while(compCol < 1 || compCol > 7 || colSpaceTrack[compCol - 1] < 0); // If Column is Filled, Generate a Different Random Column
   
   gameBoard[colSpaceTrack[compCol - 1]][compCol] = 'C'; // Set Next Available Row in compCol to 'C'
   colSpaceTrack[compCol - 1]--; // Decrement by 1 to Indicate the Next Row in compCol Which is Available
   
   printf("Computer player selected column %d", compCol);
   printf("\n");
}

int main() {
   int i = 0, j = 0, tossResult;
   
   printf("Welcome to Connect Four, Five-in-a-Row variant!");
   printf("\nVersion 1.0");
   printf("\nDeveloped by Bikram Chatterjee\n\n");
   
   // Set All Elements to "."
   for (i = 0; i < 6; i++) {
      for(j = 0; j < 9; j++) {
         gameBoard[i][j] = '.';
      }
   }
   
   // Populate First and Last Column with Alternating Player Tokens
   for (i = 0; i < 6; i++) {
      if (i % 2 == 0) { // Check if Row is Even
         gameBoard[i][0] = 'C';
         gameBoard[i][8] = 'C';
      }
      
      else {
         gameBoard[i][0] = 'H';
         gameBoard[i][8] = 'H';
      }
   }
   
   printf("Enter two positive numbers to initialize the random number generator.\n");
   printf("Number 1: ");
   if(scanf("%d", &m_w) == 0) { ROWS = 6; }
   printf("Number 2: ");
   if(scanf("%d", &m_z) == 0) { ROWS = 6; }
   printf("Human player (H)");
   printf("\nComputer player (C)");
   
   // Generate Random Number Between 0 and 1
   tossResult = random_in_range(0, 1);
   
   // Computer Plays First
   if(tossResult == 0) {
      printf("\nCoin toss... COMPUTER goes first.\n\n");
      do {
         compMove();
         printGameBoard();
         if(isGameOver() == 0 || isDraw() == 0) { break; } // Break if Game is Over
         userMove();
         printGameBoard();
      } while(isGameOver() != 0 && isDraw() != 0);
   }
   
   // Human Plays First
   else {
      printf("\nCoin toss... HUMAN goes first.\n");
      printGameBoard();
      do {
         userMove();
         if(isGameOver() == 0 || isDraw() == 0) { // Break if Game is Over
            printGameBoard();
            break;
         }
         compMove();
         printGameBoard();
      } while(isGameOver() != 0 && isDraw() != 0);
   }
   
   if(isDraw() == 0) {
      printf("Draw!\n");
   }
   
   else if (currPlayer == 'C') {
      printf("You Lost!\n");
   }
   
   else {
      printf("Congratulations, Human Winner!\n");
   }
   
   return 0;
}
