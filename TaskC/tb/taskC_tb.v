`timescale 1ns / 1ps

module taskC_tb;
    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] leds;

    TopLevelProcessor #(
        .MEMFILE("factorial.mem")
    ) cpu (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .leds(leds)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        sw  = 16'd0;

        repeat(2) @(posedge clk);
        rst = 0;

        // TEST 1: 0! = 1
        wait(leds == 16'h0001);

        $display("================================");
        $display("0! TEST PASSED");
        $display("Final LEDs/display value = %h", leds);
        $display("Expected final value = 0001");
        $display("================================");

        repeat(5) @(posedge clk);

        // TEST 2: 4! = 24
        sw = 16'd4;

        wait(leds == 16'h4018);

        $display("================================");
        $display("4! TEST PASSED");
        $display("Final LEDs/display value = %h", leds);
        $display("Expected final value = 4018");
        $display("================================");

        $display("TASK C PASS");
        $finish;
    end

    always @(posedge clk) begin
        if (cpu.LEDWriteEnable) begin
            $display("time=%0t PC=%h sw=%0d raw_display=%h", 
                     $time, cpu.PC, sw, cpu.readdata2[15:0]);
        end
    end

endmodule