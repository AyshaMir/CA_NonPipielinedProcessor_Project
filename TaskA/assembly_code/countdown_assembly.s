#countdown of assembly fsm 
.equ led_address,     256
.equ switch_address,  512

.globl _start

_start:
    addi x2, x0, 200        # stack pointer
    addi x4, x0, 256        # LED base address
    addi x5, x0, 512        # switch base address

    sw x0, 0(x4)            # clear LEDs

# IDLE STATE
idle_state:
    lw x7, 0(x5)            # read switches
    beq x7, x0, idle_state  # stay if 0

    add x10, x7, x0         # pass value
    jal x1, countdown

    beq x0, x0, idle_state  # unconditional jump

# COUNTDOWN FUNCTION
countdown:
    addi x2, x2, -12
    sw x1, 8(x2)
    sw x8, 4(x2)
    sw x9, 0(x2)

    add x8, x10, x0         # current value

countdown_loop:
    sw x8, 0(x4)            # display

    beq x8, x0, countdown_done

    addi x8, x8, -1

    beq x0, x0, countdown_loop

countdown_done:
    lw x1, 8(x2)
    lw x8, 4(x2)
    lw x9, 0(x2)
    addi x2, x2, 12

    jalr x0, 0(x1)