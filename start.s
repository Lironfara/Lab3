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
    pushad ;in [ebp+4] is the return address
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
    jz exit ;jump to exit

    push dword [esi] ;push the pointer to the current argument
    call strlen ;len of the word
    mov edx, eax ;edx holds the length of the string
    add esp, 4 ;pop the pointer
    call print_string
    add esi, 4 ;move to the next argument - add pointrt size
    sub ecx, 1 ;decrease the number of arguments
    jmp loop_args
   
print_string:
    push eax
    push ebx
    push ecx
    push edx
    mov eax, WRITE
    mov ebx, STDOUT
    mov ecx, [esi]
    call system_call
    pop edx
    pop ecx ;restore ecx
    pop ebx
    pop eax
    call print_newline
    ret
    
print_newline:
    push eax
    push ebx
    push ecx ; Save ecx
    push edx
    mov eax, WRITE
    mov ebx, STDOUT
    lea ecx, [newLine]
    mov edx, 1
    call system_call
    pop edx
    pop ecx ; Restore ecx
    pop ebx
    pop eax
    ret


exit:
    mov eax, 1        ; Set the system call number for exit (1)
    xor ebx, ebx      ; Set the exit code (0)
    int 0x80          ; Trigger the system call

