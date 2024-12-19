# Compiler and assembler
CC = gcc
AS = nasm

# Compiler and assembler flags
CFLAGS = -m32 -Wall -g
ASFLAGS = -f elf32

# Targets
TARGET = main
OBJS = main.o start.o

# Default target
all: $(TARGET)

# Link the object files to create the final executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# Compile the C source file
main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o

# Assemble the assembly source file
start.o: start.s
	$(AS) $(ASFLAGS) start.s -o start.o

# Clean up generated files
clean:
	rm -f $(TARGET) $(OBJS)