                    section             .text
                    global              main
main:
                    mov                 eax, 4
                    mov                 ebx, 1
                    mov                 ecx, message
                    mov                 edx, message_size
                    syscall

                    xor                 eax, eax
                    ret

                    section             .rodata
message:            db                  "Hello, World!",0x0a
message_size:       equ                 $ - message
