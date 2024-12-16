# Compiler and flags
CC = gcc
NASM = nasm
LD = ld
CFLAGS = -m32 -Wall -ansi -c -nostdlib -fno-stack-protector
LDFLAGS = -m elf_i386
NASMFLAGS = -f elf32

# Targets and files
TARGET0 = task0
TARGET1 = task1A
ASM_SRC = start.s
C_SRCS = main.c util.c
OBJS0 = start.o main.o util.o
OBJS1 = start.o main.o

# Default target
all: $(TARGET0) $(TARGET1)

# Assemble start.s
start.o: start.s
	$(NASM) $(NASMFLAGS) start.s -o start.o

# Compile C files
main.o: main.c
	$(CC) $(CFLAGS) main.c -o main.o

util.o: util.c
	$(CC) $(CFLAGS) util.c -o util.o

# Link everything for task0
$(TARGET0): $(OBJS0)
	$(LD) $(LDFLAGS) $(OBJS0) -o $(TARGET0)

# Link everything for task1A
$(TARGET1): start.o main.o
	$(LD) $(LDFLAGS) start.o main.o -o $(TARGET1)

# Clean up
clean:
	rm -f $(OBJS0) $(TARGET0) $(TARGET1)