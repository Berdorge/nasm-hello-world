                    extern              printf

                    global              main

                    section             .text
main:
                    mov                 eax, 8
                    mov                 ebx, 1
                    cmp                 eax, 0
begin_factorial:
                    jz                  end_factorial
                    mov                 ebp, eax
                    mul                 ebx
                    mov                 ebx, eax
                    mov                 eax, ebp
                    sub                 eax, 1
                    jmp                 begin_factorial

end_factorial:
                    mov                 eax, ebx
                    mov                 ebx, 10
                    mov                 ebp, esp
                    sub                 ebp, 1
                    sub                 esp, buffer_size
                    mov                 byte [ebp], 0
begin_digitify:
                    cmp                 eax, 0
                    jz                  end_digitify

                    mov                 edx, 0
                    div                 ebx
                    add                 edx, '0'
                    sub                 ebp, 1
                    mov                 [ebp], dl

                    jmp                 begin_digitify

end_digitify:
                    push                ebp
                    push                format 
                    call                printf
                    add                 esp, 8
                    add                 esp, buffer_size

                    xor                 eax, eax
                    ret

                    section             .rdata
buffer_size:        equ                 20
format:             db                  "Factorial is %s", 0xA, 0
