WRITE EQU 4
STDOUT EQU 1
READ EQU 3
STDIN EQU 0

section .data
    newLine db 10

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
    jz get_user_input ;if there are no more arguments, get user input

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
   
print_string:
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
    call print_newline
    ret
    
print_newline:
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
    ret


get_user_input:

    mov eax, READ
    mov ebx, STDIN
    lea ecx, [ebp-4] ;store the input in the local variable
    mov edx, 100 ;max length of the input

    push edx
    push ecx
    push ebx
    push eax

    call system_call
    add esp, 16 ;pop the arguments
    jmp encoder

encoder: ;ecx is the string from user
    mov esi, ecx ;esi is the pointer to the string
    push ecx ;to save string before calling
    push dword [esi] ;push the pointer to the current argument
    call strlen ;len of the word
    add esp, 4 ;pop the pointer
    mov edx, eax ;edx holds the length of the string
    jmp encoder_loop

encoder_loop:
    cmp edx, 0 ; no more arguments to print
    jz get_user_input ;if there are no more arguments, get user input

    mov al, [esi] ;get the current character
    cmp al, 65 ;if it is a letter
    jl not_letter
    cmp al, 90 ;if it is a letter
    jg not_letter
    add al, 1 ;make it lowercase
    mov [esi], al ;store the new character
    sub edx, 1 ;decrease the length of the string
    jmp encoder_loop

not_letter:
    cmp al, 97 ;if it is a letter
    sub edx, 1 ;decrease the length of the string
    jl encoder_loop
    cmp al, 122 ;if it is a letter
    sub edx, 1 ;decrease the length of the string
    jg encoder_loop
    sub al, 1 ;make it uppercase
    mov [esi], al ;store the new character
    sub edx, 1 ;decrease the length of the string
    jmp encoder_loop

exit:
    mov eax, 1        ; Set the system call number for exit (1)
    xor ebx, ebx      ; Set the exit code (0)
    int 0x80          ; Trigger the system call

