WRITE EQU 4
STDOUT EQU 1
READ EQU 3
STDIN EQU 0

section .data
    newLine db 10

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

encoder: ;ecx is the string from user
    jmp encoder_loop

print_encoded:
    mov edx, 100 ;max length of the input
    call print_string
    jmp exit

encoder_loop:
    mov al, [esi] ;get the current character
    cmp al, 0 ;if it is the end of the string
    jz get_user_input ;if there are no more arguments, get user input
    cmp al, 'a' ;if it is a letter
    jl check_uppercase ; Jump if below 'A'
    cmp al, 'z' ;if it is a letter
    jg not_letter ; Jump if above 'Z'
    add al, 1 ;make it lowercase
    mov [esi], al ;store the new character
    inc esi ;move to the next character
    jmp encoder_loop

encoded_done:
    ; Print the encoded string
    mov eax, WRITE
    mov ebx, STDOUT
    lea ecx, [inputBuffer]
    call strlen         ; Get the length of the encoded string
    mov edx, eax        ; Set edx to the length of the string
    call system_call


check_uppercase:
    ; Check if the character is an uppercase letter (A-Z)
    cmp al, 'A'        ; Compare AL with 'A'
    jl not_letter      ; If below 'A', it's not a valid letter
    cmp al, 'Z'        ; Compare AL with 'Z'
    jg not_letter      ; If above 'Z', it's not a valid letter
    add al, 1          ; Increment the letter
    mov [esi], al      ; Store the updated letter back
    jmp print_encoded_char ; Print the updated letter
    inc esi            ; Move to the next character
    jmp encoder_loop   ; Continue looping

not_letter:
    ; If the character is not a letter, skip it
    mov [esi], al      ; Store the character back
    jmp print_encoded_char ; Print the character
    inc esi            ; Move to the next character
    jmp encoder_loop   ; Continue looping

exit:
    mov eax, 1        ; Set the system call number for exit (1)
    xor ebx, ebx      ; Set the exit code (0)
    int 0x80          ; Trigger the system call

