CC=g++
CFLAGS=-Wall -std=c++11

all: 	main.o f.o
	$(CC) $(CFLAGS) main.o f.o -o fun -lsfml-graphics -lsfml-window -lsfml-system
main.o:	main.cpp
	$(CC) $(CFLAGS) main.cpp -c -lsfml-graphics -lsfml-window -lsfml-system
f.o:	f.S
	nasm -f elf64 f.S
clean:
	rm -f *.o
	
