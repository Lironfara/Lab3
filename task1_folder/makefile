# Variables
NASM = nasm
LD = ld
NASMFLAGS = -g -f elf32
LDFLAGS = -m elf_i386 -e _start

# Targets
all: task1

task1: start.o util.o
	$(LD) $(LDFLAGS) start.o util.o -o task1

start.o: start.s
	$(NASM) $(NASMFLAGS) start.s -o start.o

util.o: util.c
	gcc -g -m32 -Wall -c -o util.o util.c

clean:
	rm -f *.o task1