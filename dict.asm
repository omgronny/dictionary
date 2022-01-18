extern string_equals

global find_word

section .text

; rsi - pointer to start of hashmap
; rdi - string

find_word:

	.loop:
	
		cmp rsi,0
		je .end
		
		call string_equals
		
		cmp rax,1
		je .found
		
		mov rsi,[rsi]	; next element
		add rsi,8		; skip the value
		
		jmp .loop


	.found:
	
		mov rax, rsi
		ret
	
	
	.end:
		
		mov rax,0
		ret

	
