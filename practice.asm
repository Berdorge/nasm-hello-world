                    extern              printf

                    global              main

                    section             .text
main:
                    push                message
                    call                printf
                    add                 esp, 4

                    xor                 eax, eax
                    ret

                    section             .rodata
message:            db                  "Hello, World!", 0xA, 0
