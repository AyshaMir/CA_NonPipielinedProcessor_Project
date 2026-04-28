`timescale 1ns / 1ps

module taskA_tb;

    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] leds;

    //MEMFILE parameter
    TopLevelProcessor #(
        .MEMFILE("countdown.mem")
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

        // Hold reset for 2 cycles
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        // Stay in idle (sw=0), processor should loop in idle_state
        repeat(5) @(posedge clk);
        $display("LEDs during idle (expect 0): %0d", leds);

        // Set switches to 5 - should countdown 5->0
        sw = 16'd5;
        $display("Switch set to 5, starting countdown...");

        // Wait enough cycles for countdown to complete
        repeat(60) begin
            @(posedge clk);
            $display("t=%0t | sw=%0d | leds=%0d", $time, sw, leds);
        end

        // Clear switches, processor returns to idle
        sw = 16'd0;
        repeat(10) @(posedge clk);
        $display("LEDs after countdown done (expect 0): %0d", leds);

        // Second run with sw=3
        sw = 16'd3;
        $display("Switch set to 3, starting countdown...");
        repeat(30) begin
            @(posedge clk);
            $display("t=%0t | sw=%0d | leds=%0d", $time, sw, leds);
        end

        sw = 16'd0;
        repeat(5) @(posedge clk);

        $display("Simulation done.");
        $finish;
    end

endmodule