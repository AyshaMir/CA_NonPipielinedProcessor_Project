`timescale 1ns / 1ps

module taskB_tb;

    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] leds;

    // Instantiate DUT with MEMFILE parameter
    TopLevelProcessor #(
        .MEMFILE("temp_warning_test.mem")
    ) uut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .leds(leds)
    );

    // Clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        sw  = 16'd0;

        // Reset for 2 cycles
        repeat(2) @(posedge clk);
        rst = 0;

        // Run simulation
        repeat(100) @(posedge clk);

        // Display results
        $display("======== FINAL REGISTER VALUES ========");
        $display("x10 (BLT result) = %0d", uut.regfile.regs[10]);
        $display("x11 (BGE result) = %0d", uut.regfile.regs[11]);
        $display("x12 (fail flag)  = %0d", uut.regfile.regs[12]);
        $display("x20 (LUI value)  = %h", uut.regfile.regs[20]);
        $display("=======================================");

        $finish;
    end

endmodule