ASM=nasm
ASMFLAGS=-felf64
LD=ld

program: main 

main: main.o dict.o lib.o
	$(LD) -o $@ $^

main.o: main.asm colon.inc words.inc
	$(ASM) $(ASMFLAGS) $<

%.o: %.asm
	$(ASM) $(ASMFLAGS) $<
	
clean:
	rm -f *.o

.PHONY: clean, program

