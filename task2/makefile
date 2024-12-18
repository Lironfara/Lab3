# Compiler and assembler settings
AS = nasm
CC = gcc
CFLAGS = -m32 -Wall -g -no-pie
LDFLAGS = -m32 -no-pie

# File names
ASM_SRC = start.s
C_SRC = main.c
OBJ_ASM = start.o
OBJ_C = main.o
EXE = virus

# Targets
all: $(EXE)

# Link the object files to create the final executable
$(EXE): $(OBJ_C) $(OBJ_ASM)
	$(CC) $(LDFLAGS) -o $(EXE) $(OBJ_C) $(OBJ_ASM)

# Assemble the assembly file
$(OBJ_ASM): $(ASM_SRC)
	$(AS) -f elf32 -o $(OBJ_ASM) $(ASM_SRC)

# Compile the C file
$(OBJ_C): $(C_SRC)
	$(CC) -m32 -Wall -g -c $(C_SRC)

# Clean up the generated files
clean:
	rm -f $(OBJ_C) $(OBJ_ASM) $(EXE)

.PHONY: all clean
