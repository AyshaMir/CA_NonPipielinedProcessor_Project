## Project Overview

This project implements a non-pipelined single-cycle RISC-V processor on FPGA. The processor was tested through three tasks.

Task A: Basic Processor Execution with Memory-Mapped I/O
- Wrote a countdown assembly program.
- The processor reads input from switches and displays the countdown value on LEDs.
- Created a Task A testbench to verify countdown behavior in simulation.
- Added an FPGA top module with a clock divider so the countdown is visible on hardware.

---
Task B: Instruction Extension and Hardware Display

- Extended the processor to support additional RISC-V instructions:
  - `BLT`
  - `BGE`
  - `JAL`
  - `JALR`
  - `LUI`
- Updated branch decision logic to support signed comparisons for `BLT` and `BGE`.
- Updated control logic to generate signals for jump, branch, JALR, and LUI instructions.
- Modified write-back logic so:
  - `JAL` and `JALR` write `PC + 4`
  - `LUI` writes the upper immediate value
- Wrote a Task B assembly program to test:
  - branch taken cases
  - branch not taken cases
  - jump and return behavior
  - LUI output
- Added seven-segment display support for hardware output.
- Created a Task B FPGA top module to display register/output values using LEDs and seven-segment display.
- Created a Task B testbench to verify register values after execution.

---

Task C: Student-Selected Program — Factorial

- Designed and implemented a factorial program in RISC-V assembly.
- Implemented iterative multiplication using repeated addition.
- Output format:
  - upper 4 bits show the current iteration value `i`
  - lower 12 bits show the factorial result
- Added support for the edge case `0! = 1`.
- Added a decimal display module to convert the factorial output into readable decimal digits for the seven-segment display.
- Created a Task C FPGA top module that connects:
  - CPU output to LEDs
  - CPU output to decimal display
  - decimal display to seven-segment display
- Created a Task C testbench to verify:
  - `0! = 1`
  - `4! = 24`
- Final expected hardware/simulation outputs include:
  - `0! → 0x0001`
  - `4! → 0x4018`
