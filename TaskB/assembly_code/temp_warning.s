.globl _start

_start:
    # Test LUI
    lui x20, 0x12345

    li x10, 0      # flag for BLT
    li x11, 0      # flag for BGE
    li x12, 0      # flag for failure

    # CASE 1: BLT should be taken
    addi x5, x0, 25
    addi x6, x0, 30

    blt x5, x6, blt_taken
    beq x0, x0, fail

blt_taken:
    jal x1, safe_routine
    beq x0, x0, after_safe

safe_routine:
    addi x10, x0, 1
    jalr x0, x1, 0

after_safe:
    # CASE 1B: BLT should NOT be taken
    addi x5, x0, 40
    addi x6, x0, 20

    blt x5, x6, blt_not_taken
    addi x10, x0, 0
    beq x0, x0, after_blt_nt

blt_not_taken:
    beq x0, x0, fail

after_blt_nt:
    # CASE 2: BGE should be taken
    addi x5, x0, 35
    addi x6, x0, 30

    bge x5, x6, bge_taken
    beq x0, x0, fail

bge_taken:
    jal x1, warning_routine
    beq x0, x0, after_warning

warning_routine:
    addi x11, x0, 1
    jalr x0, x1, 0

after_warning:
    # CASE 2B: BGE should NOT be taken
    addi x5, x0, 10
    addi x6, x0, 20

    bge x5, x6, bge_not_taken
    addi x11, x0, 0
    beq x0, x0, done

bge_not_taken:
    beq x0, x0, fail

fail:
    addi x12, x0, 1
    beq x0, x0, done

done:
    beq x0, x0, done