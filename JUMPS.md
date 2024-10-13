## Проверка на то, что в `al` находится десятичная цифра
Можно написать прямолинейно, через
```c
if (al >= '0' && al <= '9')
```
Получится два conditional jump:
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    call                read_char

                    cmp                 al, '0'
                    jb                  not_digit

                    cmp                 al, '9'
                    ja                  not_digit

                    push                format_digit
                    call                printf
                    add                 esp, 4
                    jmp                 end

not_digit:
                    push                format_not_digit
                    call                printf
                    add                 esp, 4

end:
                    xor                 eax, eax
                    ret

; reads one char from stdin and returns it in eax
read_char:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    pop                 ebp
                    ret

                    section             .rdata
scanf_format:       db                  "%c", 0
format_not_digit:   db                  "NOT a digit", 0xA, 0
format_digit:       db                  "a digit", 0xA, 0
```

А можно написать вот так:
```c
if (al - '0' <= 9u)
``` 
Суффикс `u` у девятки
здесь обязателен, чтобы это было `unsigned` сравнение.

Тогда будет один conditional jump:
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    call                read_char

                    sub                 al, '0'
                    cmp                 al, '9' - '0'
                    ja                  not_digit

                    push                format_digit
                    call                printf
                    add                 esp, 4
                    jmp                 end

not_digit:
                    push                format_not_digit
                    call                printf
                    add                 esp, 4

end:
                    xor                 eax, eax
                    ret

; reads one char from stdin and returns it in eax
read_char:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    section             .rdata
scanf_format:       db                  "%c", 0
format_not_digit:   db                  "NOT a digit", 0xA, 0
format_digit:       db                  "a digit", 0xA, 0
```

## Проверка на то, что в `al` находится шестандцатеричная цифра
Можно написать прямолинейно:
```c
if (
    al >= '0' && al <= '9' ||
    al >= 'a' && al <= 'f' ||
    al >= 'A' && al <= 'F'
)
```
Получится шесть conditional jump:
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    call                read_char

                    cmp                 al, '0'
                    jb                  not_decimal_digit
                    cmp                 al, '9'
                    ja                  not_decimal_digit
                    jmp                 digit

not_decimal_digit:
                    cmp                 al, 'a'
                    jb                  not_lowercase_letter
                    cmp                 al, 'f'
                    ja                  not_lowercase_letter
                    jmp                 digit

not_lowercase_letter:
                    cmp                 al, 'A'
                    jb                  not_digit
                    cmp                 al, 'F'
                    ja                  not_digit
                    jmp                 digit

not_digit:
                    push                format_not_digit
                    call                printf
                    add                 esp, 4
                    jmp                 end

digit:
                    push                format_digit
                    call                printf
                    add                 esp, 4

end:
                    xor                 eax, eax
                    ret

; reads one char from stdin and returns it in eax
read_char:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    pop                 ebp
                    ret

                    section             .rdata
scanf_format:       db                  "%c", 0
format_not_digit:   db                  "NOT a digit", 0xA, 0
format_digit:       db                  "a digit", 0xA, 0
```

А можно заметить, что буквы в нижнем
и верхнем регистре отличает
ровно один бит &mdash; `0x20`.
У букв в верхнем регистре он `0`,
а у букв в нижнем &mdash; `1`.
Остальные биты при этом совпадают.
Поэтому мы можем проставить `0x20` и проверять только
верхний регистр.
Комбинируем с предыдущим трюком:
```c
if (al - '0' <= 9u || (al | 0x20) - 'a' <= 5u)
```
(я не проверял этот код на C, он может не работать :D)

Получаем два conditional jump:
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    call                read_char

                    sub                 al, '0'
                    cmp                 al, '9' - '0'
                    ja                  not_decimal_digit
                    jmp                 digit

not_decimal_digit:
                    add                 al, '0'
                    or                  al, 0x20
                    sub                 al, 'a'
                    cmp                 al, 'f' - 'a'
                    ja                  not_digit
                    jmp                 digit

not_digit:
                    push                format_not_digit
                    call                printf
                    add                 esp, 4
                    jmp                 end

digit:
                    push                format_digit
                    call                printf
                    add                 esp, 4

end:
                    xor                 eax, eax
                    ret

; reads one char from stdin and returns it in eax
read_char:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    pop                 ebp
                    ret

                    section             .rdata
scanf_format:       db                  "%c", 0
format_not_digit:   db                  "NOT a digit", 0xA, 0
format_digit:       db                  "a digit", 0xA, 0
```

## `do while`
Тут всё просто:
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    push                esi
                    push                edi
                    call                read_uint
                    mov                 edi, eax
                    mov                 esi, 0

begin_do_while:
                    push                format_hello
                    call                printf
                    add                 esp, 4

                    add                 esi, 1
                    cmp                 esi, edi
                    jb                  begin_do_while

                    pop                 edi
                    pop                 esi
                    xor                 eax, eax
                    ret

; reads one uint from stdin and returns it in eax
read_uint:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    pop                 ebp
                    ret

                    section             .rdata
scanf_format:       db                  "%u", 0
format_hello:       db                  "Hello, World!", 0xA, 0
```

## `while`
Его можно написать прямолинейно:
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    push                esi
                    push                edi
                    call                read_uint
                    mov                 edi, eax
                    mov                 esi, 0

begin_while:
                    cmp                 esi, edi
                    jnb                 end_while

                    push                format_hello
                    call                printf
                    add                 esp, 4

                    add                 esi, 1
                    jmp                 begin_while

end_while:
                    pop                 edi
                    pop                 esi
                    xor                 eax, eax
                    ret

; reads one uint from stdin and returns it in eax
read_uint:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    pop                 ebp
                    ret

                    section             .rdata
scanf_format:       db                  "%u", 0
format_hello:       db                  "Hello, World!", 0xA, 0
```

Но заметьте, что здесь два jump в теле цикла.
Мы же здесь собрались, чтобы
выжимать производительность, поэтому хотим
оставить в цикле только один jump.
Можем перед циклом прыгнуть в сравнение:
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    push                esi
                    push                edi
                    call                read_uint
                    mov                 edi, eax
                    mov                 esi, 0

                    jmp                 while_comparison

begin_while:
                    push                format_hello
                    call                printf
                    add                 esp, 4

                    add                 esi, 1
while_comparison:   cmp                 esi, edi
                    jb                  begin_while

                    pop                 edi
                    pop                 esi
                    xor                 eax, eax
                    ret

; reads one uint from stdin and returns it in eax
read_uint:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    pop                 ebp
                    ret

                    section             .rdata
scanf_format:       db                  "%u", 0
format_hello:       db                  "Hello, World!", 0xA, 0
```

А можем преобразовать `while` в
```c
if (condition)
{
    do {

    } while (condition);
}
```
Если я правильно понял Павла Сергеевича,
этот способ выбирают компиляторы. Не знаю, почему
конкретно его. Возможно, так просто повелось.

В любом случае, вот он:
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    push                esi
                    push                edi
                    call                read_uint
                    mov                 edi, eax
                    mov                 esi, 0

                    cmp                 esi, edi
                    jnb                 end_while

begin_while:
                    push                format_hello
                    call                printf
                    add                 esp, 4

                    add                 esi, 1
                    cmp                 esi, edi
                    jb                  begin_while

end_while:
                    pop                 edi
                    pop                 esi
                    xor                 eax, eax
                    ret

; reads one uint from stdin and returns it in eax
read_uint:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    pop                 ebp
                    ret

                    section             .rdata
scanf_format:       db                  "%u", 0
format_hello:       db                  "Hello, World!", 0xA, 0
```

## `for`
С привычным `for`
```c
for (unsigned int i = 0; i < n; ++i)
```
Всё понятно. В принципе, он уже написан выше,
только как `while`.

Как быть с `for` в обратную сторону?
```c
for (unsigned int i = n - 1; i != -1; --i)

// offtop: in C the above can also be written as
for (unsigned int i = n; i--;)
```

Всё очень даже красиво, стоит лишь вспомнить
про флаг `CF`:
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    push                edi
                    call                read_uint
                    mov                 edi, eax

                    sub                 edi, 1
                    jc                  end_for

begin_for:
                    push                format_hello
                    call                printf
                    add                 esp, 4

                    sub                 edi, 1
                    jnc                 begin_for

end_for:
                    pop                 edi
                    xor                 eax, eax
                    ret

; reads one uint from stdin and returns it in eax
read_uint:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    pop                 ebp
                    ret

                    section             .rdata
scanf_format:       db                  "%u", 0
format_hello:       db                  "Hello, World!", 0xA, 0
```
**Важно**, что здесь нужно использовать именно
`sub`, поскольку `dec` не проставляет `CF`.

Как можно заметить, такой `for` получается
даже эффективнее, чем обычный,
по той причине что инструкция `cmp` становится
не нужна. Поэтому, если программист не
использует `i` в теле цикла, компиляторы могут
превратить обычный `for` в обратный.

А если `i` используется только для индексации
в массиве, можно скомпилировать обычный `for` в
`for` от `-n` до `-1` включительно,
при этом при адресации использовать `i + n`
(ведь x86 позволяет):
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    push                esi
                    push                edi
                    call                read_uint
                    mov                 edi, eax
                    mov                 esi, edi
                    neg                 esi

                    test                esi, esi
                    jz                  end_for

begin_for:
                    lea                 eax, [esi + edi]
                    push                eax
                    push                format_hello
                    call                printf
                    add                 esp, 8

                    add                 esi, 1
                    jnz                 begin_for

end_for:
                    pop                 edi
                    pop                 esi
                    xor                 eax, eax
                    ret

; reads one uint from stdin and returns it in eax
read_uint:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    pop                 ebp
                    ret

                    section             .rdata
scanf_format:       db                  "%u", 0
format_hello:       db                  "Hello, World! i is %u", 0xA, 0
```
Снова сэкономили на `cmp`.


## `switch`
Давайте скомпилируем вот такой `switch`:
```c
switch (eax) {
    case 1:
        printf("Case 1\n");
        break;
    case 3:
        printf("Case 3\n");
    case 5:
        printf("Case 5\n");
        break;
    default:
        printf("Default\n");
}
```
Идея в том, чтобы создать табличку
с адресами
размером (максимум из меток) + 1,
проверить, что в `eax` содержится
число, не большее, чем максимум из меток,
и затем прыгнуть в метку, которая находится
в табличке под индексом `eax`:
```asm
                    extern              printf
                    extern              scanf

                    global              main

                    section             .text
main:
                    call                read_uint

                    cmp                 eax, 5
                    ja                  case_default

                    jmp                 [4 * eax + switch_table]

case_1:
                    push                format_case_1
                    call                printf
                    add                 esp, 4
                    jmp                 end_switch

case_3:
                    push                format_case_3
                    call                printf
                    add                 esp, 4

case_5:
                    push                format_case_5
                    call                printf
                    add                 esp, 4
                    jmp                 end_switch

case_default:
                    push                format_default
                    call                printf
                    add                 esp, 4

end_switch:
                    xor                 eax, eax
                    ret

; reads one uint from stdin and returns it in eax
read_uint:
                    push                ebp
                    mov                 ebp, esp
                    sub                 esp, 4

                    push                ebp
                    push                scanf_format
                    call                scanf
                    add                 esp, 8
                    mov                 eax, [ebp]
                    add                 esp, 4

                    pop                 ebp
                    ret

                    section             .rdata
scanf_format:       db                  "%u", 0
format_case_1:      db                  "Case 1", 0xA, 0
format_case_3:      db                  "Case 3", 0xA, 0
format_case_5:      db                  "Case 5", 0xA, 0
format_default:     db                  "Default", 0xA, 0
switch_table:       dd                  case_default, \
                                        case_1, \
                                        case_default, \
                                        case_3, \
                                        case_default, \
                                        case_5

```
Если метки представляют из себя
группы, отдалённые друг от друга,
компилятор может сделать несколько табличек.
Если же меток слишком много,
`switch` может скомпилироваться в последовательность
`if else`.
