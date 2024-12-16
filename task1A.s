;define const values
WRITE EQU 4
STDOUT EQU 1
EXIT EQU 1

global main
extern system_call
section .data
newLine db 10 ;the ASCII value 

section .text
main:
    mov ebp, esp
    push ebp
    pushad ;in [ebp+4] is the return adress
    mov eax, [ebp+8] ;to get argc which is the first arguent above, size of 8
    mov ebx, [ebp+12] ;argv is the second argument on stack
    jmp loop_args


loop_args:
    test eax, eax ; no more arguments to print
    jz exit ;jump to exit
    
    mov ecx, [ebx] ;ecx points to the current argument string

loop_char_argv:
    mov dl, [ecx] ;dl now hodls the first char
    test dl, dl ;Check if it is the last char
    jz print_newline
    jmp encoder
;if no null, move to print_char anyway

print_char: ;the arg is in ecx
    pushad
     ; Print the character
    push edx           ; Save edx
    mov [esp-1], dl    ; Store the character on the stack
    mov eax, WRITE
    mov ebx, STDOUT
    lea ecx, [esp-1]   ; Load the address of the character
    mov edx, 1         ; Length of the character
    call system_call
    popad
    add ecx, 1
    jmp loop_char_argv

encoder: ;dl holds the char
    cmp dl, 'a'
    jl check_capital
    cmp dl, 'z'
    jg check_capital ;if grether than 'Z'
    add dl, 1 ;encoder by 1
    jmp print_char

check_capital:
    cmp dl, 'A'
    jl print_char
    cmp dl, 'Z'
    jg print_char
    add dl,1

 print_newline:
    mov eax, WRITE
    mov ebx, STDOUT
    lea ecx, [newLine]
    mov edx, 1
    int 0x80
    add ebx, 4 ;moving the *pointer* to the next elemnt
    sub eax, 1 ;decrece the numner of elements
    jmp loop_args 


exit:
    system_call(1)
