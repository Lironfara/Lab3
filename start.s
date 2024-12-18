WRITE EQU 4
STDOUT EQU 1
READ EQU 3
STDIN EQU 0
OPEN EQU 5
O_RDONLY EQU 0
O_WRONLY EQU 1
O_CREAT EQU 64
O_TRUNC EQU 512
CLOSE EQU 6


section .data
    newLine db 10
    inputFile db 0
    outputFile db 0

section .bss
    inputBuffer resb 100 ; 100-byte buffer for user input

section .text
global _start
global system_call
extern main
extern strlen

_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop

;ecx - number of arguents
;esi - pointer of argv

main: 
    mov ebp, esp
    push ebp
    add esi, 4 ;skip the first argument
    sub ecx, 1 ;decrease the number of arguments
    mov ebx, ecx ; to save the number of arguments
    mov edi, esi ;to save our argumetns for -o/-i

    jmp loop_args
        
system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

loop_args:
    cmp ecx, 0 ; no more arguments to print
    jz check_RW ;if there are no more arguments, get user input

    push ecx ;to save before calling strlen
    push dword [esi] ;push the pointer to the current argument
    call strlen ;len of the word
    add esp, 4 ;pop the pointer
    mov edx, eax ;edx holds the length of the string
    call print_string
    pop ecx ;restore ecx
    sub ecx, 1 ;decrease the number of arguments
    add esi, 4 ;move to the next argument - add pointrt size
    jmp loop_args

check_RW: 
    mov eax, 0 ;to be boolean if we need to get user input or not
    mov ecx, ebx ;to save the number of arguments
    mov esi, [edi] ;get first word
    jmp check_argsRW

check_argsRW:
    ;iterate esi again to check for -i/-o
    cmp ecx, 0 ; no more arguments to print
    jz is_user_input ;if there are no more arguments, get user input
    mov al , [esi] ;get the first character of the word
    cmp al, '-' ;if it is a flag
    jne next_arg 
    mov al, [esi+1] ;get the second character of the word
    cmp al, 'i' ;if it is -i
    je set_input_file_name
    cmp byte [esi+1], 'o'
    je set_output_file_name
    jmp next_arg

next_arg:
    add edi, 4 ;move to the next argument - add pointrt size
    mov esi, [edi] ;get the next word
    sub ecx, 1 ;decrease the number of arguments
    jmp check_argsRW


set_input_file_name:
    add esi, 2 ; skip -i
    mov [inputFile], esi ; save the name of the input file
    jmp next_arg
    

set_output_file_name:
    add esi, 2 ; skip -i
    mov [outputFile], esi ; save the name of the input file
    jmp next_arg


open_error:
    jmp exit

read_error:
    jmp exit

read_input_file:
    ; Open the input file
    mov eax, OPEN
    mov ebx, [inputFile]
    mov ecx, O_RDONLY
    push ecx
    push ebx
    push eax

    call system_call
    add esp, 12 ; pop the arguments
    test eax, eax
    js open_error
    mov edi, eax ; store the file descriptor

    ; Read from the input file
    mov eax, READ
    mov ebx, edi
    lea ecx, [inputBuffer]
    mov edx, 100 ; max length of the input
    push edx
    push ecx
    push ebx
    push eax
    call system_call
    add esp, 16 ; pop the arguments
    
    test eax, eax
    js read_error
    ; inputBuffer now holds the text from the file
    mov esi, inputBuffer ; load the value of the inputBuffer
    jmp encoder


is_user_input:
    cmp dword [inputFile], 0
    jz read_stdin
    jmp read_input_file


print_string:
    push ebx
    push edi
    mov eax, WRITE
    mov ebx, STDOUT
    mov ecx, [esi] ;pointer to the string

    ;writing arguments to system_call
    push edx
    push ecx
    push ebx
    push eax

    call system_call
    add esp, 16 ;pop the arguments
    pop edi ;restore the number of argumetns
    pop ebx ;restore the number of argumetns
    call print_newline
    ret
    
print_newline:
    push ebx ;save the orginal number of arguments
    push edi ;save the orginal number of arguments
    mov eax, WRITE
    mov ebx, STDOUT
    lea ecx, [newLine]
    mov edx, 1

    push edx
    push ecx
    push ebx
    push eax
    
    call system_call
    add esp, 16 ;pop the arguments
    pop edi ;restore the number of argumetns
    pop ebx ;restore the number of argumetns
    ret


read_stdin:

    mov eax, READ
    mov ebx, STDIN
    lea ecx, [inputBuffer] ;store the input in the local variable
    mov edx, 100 ;max length of the input

    push edx
    push ecx
    push ebx
    push eax

    call system_call
    add esp, 16 ;pop the arguments
    lea esi, [inputBuffer] ;load adress of the inputBuffer
    mov esi, inputBuffer ;load the value of the inputBuffer
    jmp encoder

encoder: ;in encoder esi holds the input
    jmp encoder_loop


encoder_loop:
    mov al, [esi] ;get the current character
    cmp al, 0 ;if it is the end of the string
    jz encoded_done ;if there are no more arguments, get user input
    cmp al, 'a' ;if it is a letter
    jl check_uppercase ; Jump if below 'A'
    cmp al, 'z' ;if it is a letter
    jg not_letter ; Jump if above 'Z'
    add al, 1 ;encoder process
    jmp store_char ;store the character back

encoded_done:
    cmp dword [outputFile], 0
    jz print_encoded
    jmp write_output_file

write_output_file:
    ; Open the output file
    mov eax, OPEN
    mov ebx, [outputFile]
    mov ecx, O_WRONLY | O_CREAT | O_TRUNC
    push ecx
    push ebx
    push eax
    call system_call
    add esp, 12 ; pop the arguments
    mov edi, eax ; store the file descriptor

    ; Write to the output file
    mov eax, WRITE
    mov ebx, edi
    lea ecx, [inputBuffer]
    mov edx, 100 ; max length of the input
    push edx
    push ecx
    push ebx
    push eax
    call system_call
    add esp, 16 ; pop the arguments
    jmp read_stdin

print_encoded:
    ; Print the encoded string
    mov ecx, edx       ; Set ecx to the address of the encoded string
    push ecx            ; to save
    push dword edx      ; Push the pointer to the encoded string
    call strlen        ; Get the length of the encoded string

    pop ecx             ; restore
    mov edx, eax        ; Set edx to the length of the string
    mov eax, 4          ; Set the system call number for write (4)
    mov ebx, 1          ; Set the file descriptor for stdout (1)

    push edx            ; Push the length of the string
    push ecx            ; Push the pointer to the string
    push ebx            ; Push the file descriptor
    push eax            ; Push the system call number
    call system_call
    add esp, 16         ; Pop the arguments
    jmp read_stdin

store_char:
    ; Store the character back
    mov [esi], al      ; Store the character back
    inc esi            ; Move to the next character
    jmp encoder_loop   ; Continue looping

check_uppercase:
    ; Check if the character is an uppercase letter (A-Z)
    cmp al, 'A'        ; Compare AL with 'A'
    jl not_letter      ; If below 'A', it's not a valid letter
    cmp al, 'Z'        ; Compare AL with 'Z'
    jg not_letter      ; If above 'Z', it's not a valid letter
    add al, 1          ; Increment the letter
    jmp store_char     ; Store the character back

not_letter:
    inc esi            ; Move to the next character
    jmp encoder_loop   ; Continue looping

exit:
    mov eax, 1        ; Set the system call number for exit (1)
    xor ebx, ebx      ; Set the exit code (0)
    int 0x80          ; Trigger the system call

