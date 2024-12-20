# Targets
all: task1

task1: start.o util.o
	ld -m elf_i386 -e _start start.o util.o -o task1

start.o: start.s
	nasm -g -f elf32 start.s -o start.o

util.o: util.c
	gcc -g -m32 -Wall -c util.c -o util.o

clean:
	rm -f *.o task1
