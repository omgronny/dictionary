section .data
pointer: db 0

section .text
global exit
global string_length
global print_string
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy
global print_error

; Принимает код возврата и завершает текущий процесс
exit:
    xor rax, rax,
	mov rax,  60
	xor rdi, rdi
	syscall
    ret

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:

    xor rax, rax
	
	.loop:
	cmp byte [rax + rdi],0
	
	je .end
	
	;inc pointer
	inc rax
	
	jmp .loop
	
	.end:
	;mov pointer,0
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:

    xor rax, rax
	
    push rdi
    call string_length
    pop rsi
	
    mov rdx, rax
    mov rdi, 1
    mov rax, 1
    syscall
    
  .end:
    ret

; Принимает код символа и выводит его в stdout
print_char:
    xor rax, rax
	
	push rdi
	
	mov rax,1
	mov rdi,1
	mov rsi,rsp
	mov rdx,1
	syscall
	pop rdi
	
    ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    xor rax, rax
    ret

; Выводит беззнаковое 8-байтовое число в десятичном формате					
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
	xor rax,rax
	
    mov rax,rdi
	mov r10,0
	mov r9,10
	mov rdx,0
	
	.loop:
	
		div r9
		push rdx
		inc r10
		mov rdx,0
		
		cmp rax,0
		je .nul
	
	jmp .loop
	
	.nul:
	
		cmp r10,0
		je .end
		
		pop rdi
		add rdi,48
		call print_char
		
		dec r10
		
		jmp .nul
	
	.end:
		ret

; Выводит знаковое 8-байтовое число в десятичном формате
print_int:
    xor rax, rax
	
	cmp rdi,0
	jge print_uint
	
	neg rdi
	mov r9,rdi
	mov rdi,45
	call print_char
	mov rdi,r9
	
	jmp print_uint

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
	push rbx
	xor rbx, rbx			; counter of symb in strings
	xor rax, rax			; local data to equals
	
  .loop_equal:
	mov cl, byte [rdi+rbx]
	cmp cl, byte [rsi+rbx]
	jnz .eq_err
	
	cmp byte [rdi+rbx], 0
	jz .eq_ok

	inc rbx
	jmp .loop_equal

  .eq_ok:
	mov rax, 1
	jmp .end
  .eq_err:
	mov rax, 0
	jmp .end

  .end:
	pop rbx
	ret



; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    xor rax, rax
	
	push 0
	mov rsi,rsp
	
	mov rax,0
	mov rdi,0
	mov rdx,1
	syscall
	
	pop rax
	
    ret

; Принимает: адрес начала буфера (rdi), размер буфера (rsi)
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор

read_word:
  .delete_spaces:
	push rdi
	push rsi
	push rdx	
	call read_char
	pop rdx
	pop rsi
	pop rdi	

	cmp rax, 0x09
	je .delete_spaces
	cmp rax, 0x0A
	je .delete_spaces
	cmp rax, 0x20
	je .delete_spaces
	
  .before_loop:
	xor rdx, rdx
  .read_char_loop:
	cmp rdx, rsi
	je .str_error
	
	cmp rax, 0x00
	je .str_ok
	cmp rax, 0x09
	je .str_ok
	cmp rax, 0x0A
	je .str_ok
	cmp rax, 0x20
	je .str_ok

	mov byte [rdi + rdx], al
	inc rdx
	
	push rdi
	push rsi
	push rdx
	call read_char
	pop rdx
	pop rsi
	pop rdi	

	jmp .read_char_loop

  .str_ok:
	mov byte [rdi + rdx], 0
	mov rax, rdi
	jmp .end
  .str_error:
	xor rax, rax
	jmp .end
  .end:	
 	ret
    

; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось

parse_uint:
    xor rax, rax
    xor rdx, rdx

	mov r9,10
	
	.loop:
	
		push rdx
	
		mov r10,[rdi]
		and r10,0x00000000000000ff

		cmp r10,0x30
		jl .not_a_number
		
		cmp r10,0x39
		jg .not_a_number
		
		cmp r10,0
		je .not_a_number
		
		mul r9
		add rax,r10
		
		sub rax,48
		
		inc rdi
		
		pop rdx
		inc rdx
		
		jmp .loop
		

	.not_a_number:
		pop rdx
		ret

; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был)
; rdx = 0 если число прочитать не удалось
parse_int:
    xor rax, rax
	
	;[rdi] - первый знак. Либо минус, либо число
	mov r11, [rdi]
	
	and r11,0x00000000000000ff
	cmp r11,45
	je .neg
	
	jmp parse_uint
	
	.neg:
	
		inc rdi
		
		call parse_uint
		
		neg rax
		inc rdx
	
		ret

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    xor rax, rax
	
	push rsi
    push rdi
    push rdx
		call string_length
	pop rdx
    pop rdi
    pop rsi
	
	cmp rax,rdx
	jg .zero_end
	
	mov byte [rsi],0
	
	mov rdx,0
	.loop:
	
		cmp byte [rdi],0
		je .not_zero_end
		
		mov r9,[rdi]
		mov [rsi],r9
		
		inc rsi
		inc rdi
		inc rdx
	
	jmp .loop
	
	.not_zero_end:
		mov rax,rdx
		ret
	
	.zero_end:
		mov rax,0
		ret
		
		
print_error:

    xor rax, rax
	
    push rdi
    call string_length
    pop rsi
	
    mov rdx, rax
    mov rdi, 2
    mov rax, 1
    syscall
    
  .end:
    ret