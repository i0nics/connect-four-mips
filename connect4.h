//  Created by Bikram Ce on 4/25/20.
//  Copyright © 2020 Bikram Ce. All rights reserved.
//  connect4.h
//  Connect Four

#ifndef FUNCTION_H_
#define FUNCTION_H_
#include <stdio.h> 
#include <stdint.h>
#include <stdlib.h>
uint32_t random_in_range(uint32_t low, uint32_t high);
uint32_t get_random();
void printGameBoard();
int isGameOver();
void userMove();
void compMove();
#endif
