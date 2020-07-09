# Created by Bikram Ce on 4/25/20.
# Copyright © 2020 Bikram Ce. All rights reserved.
# connect4.h
# Connect Four

# The variable CC specifies which compiler will be used.
# (because different unix systems may use different compilers)
CC=gcc

# The variable CFLAGS specifies compiler options
#   -c :    Only compile (don't link)
#   -Wall:  Enable all warnings about lazy / dangerous C programming 
#   -std=c99: Using newer C99 version of C programming language
CFLAGS = -c -Wall -Wextra -std=c99 -O1

# All of the .h header files to use as dependencies
HEADERS = connect4.h

# All of the object files to produce as intermediary work
OBJECTS = connect4.o

# The final program to build
EXECUTABLE = Connect4

# --------------------------------------------

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(EXECUTABLE)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -rf *.o $(EXECUTABLE)
