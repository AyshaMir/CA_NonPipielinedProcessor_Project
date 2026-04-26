
.globl _start

_start:
    # Test LUI
    lui x20, 0x10000          # x20 = 0x10000000

    # CASE 1: BLT should be taken
    addi x5, x0, 25
    addi x6, x0, 30

    blt x5, x6, blt_taken
    beq x0, x0, fail

blt_taken:
    jal x1, safe_routine
    beq x0, x0, after_safe

safe_routine:
    addi x10, x0, 1           # BLT success marker
    jalr x0, x1, 0

after_safe:
    # CASE 2: BGE should be taken
    addi x5, x0, 35
    addi x6, x0, 30

    bge x5, x6, bge_taken
    beq x0, x0, fail

bge_taken:
    jal x1, warning_routine
    beq x0, x0, after_warning

warning_routine:
    addi x11, x0, 2           # BGE success marker
    jalr x0, x1, 0

after_warning:
    beq x0, x0, done

fail:
    addi x12, x0, 9           # failure marker
    beq x0, x0, done

done:
    beq x0, x0, done