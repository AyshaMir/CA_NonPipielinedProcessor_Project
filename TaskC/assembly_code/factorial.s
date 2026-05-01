.equ led_address,     256
.equ switch_address,  512

.globl _start

_start:
    addi x2, x0, 200        # stack pointer
    addi x4, x0, 256        # LED/display base address
    addi x5, x0, 512        # switch base address

    sw x0, 0(x4)            # clear LEDs

# IDLE STATE
idle_state:
    lw x7, 0(x5)            # read switches

    add x10, x7, x0         # x10 = n
    jal x1, factorial       # calculate factorial

    beq x0, x0, idle_state  # repeat forever


# FACTORIAL FUNCTION
# input: x10 = n
# output: x10 = n!
# display: [i (4 bits)][factorial (12 bits)]
factorial:
    addi x2, x2, -28
    sw x1, 24(x2)
    sw x8, 20(x2)
    sw x9, 16(x2)
    sw x18, 12(x2)
    sw x19, 8(x2)
    sw x20, 4(x2)
    sw x21, 0(x2)

    add x8, x10, x0         # x8 = n

    # BASE CASE: 0! = 1
    beq x8, x0, fact_zero

    addi x18, x0, 1         # i = 1
    addi x19, x0, 1         # result = 1


fact_loop:
    # PACK: [i << 12] | result
    slli x20, x18, 12       # i in top 4 bits
    or   x21, x20, x19      # combine with factorial
    sw   x21, 0(x4)         # send to LEDs + display

    beq x18, x8, fact_done  # if i == n, done

    addi x18, x18, 1        # i++

    # MULTIPLY: result *= i
    addi x20, x0, 0         # temp = 0
    add  x21, x19, x0       # counter = old result

mul_loop:
    beq x21, x0, mul_done
    add  x20, x20, x18      # temp += i
    addi x21, x21, -1
    beq  x0, x0, mul_loop

mul_done:
    add x19, x20, x0        # result = temp
    beq x0, x0, fact_loop


fact_zero:
    addi x18, x0, 0         # i = 0
    addi x19, x0, 1         # result = 1

    # PACK: [0 << 12] | 1 = 0001
    slli x20, x18, 12
    or   x21, x20, x19
    sw   x21, 0(x4)         # display 0! = 1

    beq x0, x0, fact_done


fact_done:
    add x10, x19, x0        # return result

    lw x1, 24(x2)
    lw x8, 20(x2)
    lw x9, 16(x2)
    lw x18, 12(x2)
    lw x19, 8(x2)
    lw x20, 4(x2)
    lw x21, 0(x2)
    addi x2, x2, 28

    jalr x0, 0(x1)