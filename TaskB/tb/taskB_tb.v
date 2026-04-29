`timescale 1ns / 1ps

module taskB_tb;

    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] leds;

    // Instantiate CPU
    TopLevelProcessor #(
        .MEMFILE("temp_warning_test.mem")
    ) cpu (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .leds(leds)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        sw  = 16'd0;

        // Reset
        repeat(2) @(posedge clk);
        rst = 0;

        // Run simulation
        repeat(100) @(posedge clk);

        // Final values
        $display("\n======== FINAL REGISTER VALUES ========");
        $display("x10 (BLT result) = %0d", cpu.regfile.regs[10]);
        $display("x11 (BGE result) = %0d", cpu.regfile.regs[11]);
        $display("x12 (FAIL flag)  = %0d", cpu.regfile.regs[12]);
        $display("x20 (LUI value)  = %h", cpu.regfile.regs[20]);
        $display("=======================================\n");

        $finish;
    end

    // FLAG TRACKING
    always @(posedge clk) begin

        if (cpu.RegWrite && cpu.rd == 5'd10)
            $display("PC=%h | x10 (BLT) = %0d", cpu.PC, cpu.WriteData);

        if (cpu.RegWrite && cpu.rd == 5'd11)
            $display("PC=%h | x11 (BGE) = %0d", cpu.PC, cpu.WriteData);

        if (cpu.RegWrite && cpu.rd == 5'd12)
            $display("PC=%h | x12 (FAIL) = %0d", cpu.PC, cpu.WriteData);

    end

endmodule