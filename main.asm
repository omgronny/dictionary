
extern find_word

global _start

%include "lib.inc"

section .data

%include "colon.inc"
%include "words.inc"
global _start
pointer_to_buffer: times 256 db 0

section .rodata
incorrect_message: db "You wrote an incorrect key", 0
not_exist_message: db "No such key found in the hashmap.", 0

section .text

_start:

	mov rdi,pointer_to_buffer
	mov rsi,256
	call read_word
	cmp rax,0
	je .incorrect

	mov rdi,pointer_to_buffer
	mov rsi, start_of_dict
	call find_word		; adress of value in rax
	
	cmp rax,0
	je .not_exist
	
	mov rdi,rax
	call print_string
	call print_newline
	call exit
	
.incorrect:

    mov rdi, incorrect_message
    call print_error
    call exit

.not_exist:

    mov rdi, not_exist_message
    call print_error
    call exit
	

	
