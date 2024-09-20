                    section             .text
                    global              _start
_start:
                    mov                 rax, 1
                    mov                 rdi, 1
                    mov                 rsi, message
                    mov                 rdx, message_size
                    syscall

                    mov                 rax, 60
                    xor                 rdi, rdi
                    syscall

                    section             .rodata
message:            db                  "Hello, World!",0x0a
message_size:       equ                 $ - message
