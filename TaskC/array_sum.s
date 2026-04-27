.equ led_address, 256

.globl _start

_start:
    addi x2, x0, 200        # stack pointer
    addi x4, x0, 256        # display/LED base address
    addi x5, x0, 0          # array base address

# =====================
# INITIALIZE ARRAY
# [5, 10, 15, 20]
# =====================
    addi x6, x0, 5
    sw   x6, 0(x5)

    addi x6, x0, 10
    sw   x6, 4(x5)

    addi x6, x0, 15
    sw   x6, 8(x5)

    addi x6, x0, 20
    sw   x6, 12(x5)

# =====================
# CALL SUM FUNCTION
# =====================
    add x10, x5, x0         # x10 = base address
    addi x11, x0, 4         # x11 = length

    jal x1, sum_array

halt:
    beq x0, x0, halt

# =====================
# SUM_ARRAY FUNCTION
# input:
#   x10 = array base address
#   x11 = length
# output:
#   x10 = final sum
# =====================
sum_array:
    addi x2, x2, -20
    sw x1, 16(x2)
    sw x8, 12(x2)
    sw x9, 8(x2)
    sw x18, 4(x2)
    sw x19, 0(x2)

    add x8, x10, x0         # x8 = array pointer
    add x9, x11, x0         # x9 = length
    addi x18, x0, 0         # i = 0
    addi x19, x0, 0         # sum = 0

sum_loop:
    beq x18, x9, sum_done

    lw x6, 0(x8)            # current value

    slli x20, x6, 8         # current value on left two digits
    or   x21, x20, x19      # old sum on right two digits
    sw   x21, 0(x4)         # display current | old sum

    add x19, x19, x6        # sum = sum + current

    addi x8, x8, 4          # next array element
    addi x18, x18, 1        # i++

    beq x0, x0, sum_loop

sum_done:
    sw x19, 0(x4)           # final display: 0050

    add x10, x19, x0        # return final sum

    lw x1, 16(x2)
    lw x8, 12(x2)
    lw x9, 8(x2)
    lw x18, 4(x2)
    lw x19, 0(x2)
    addi x2, x2, 20

    jalr x0, 0(x1)