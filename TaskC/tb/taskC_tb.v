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
        sw  = 16'd4;
    
        repeat(2) @(posedge clk);
        rst = 0;
    
        wait(leds == 16'h4018);
    
        $display("Final LEDs/display value = %h", leds);
        $display("Expected final value      = 4018");
        $display("TASK C PASS");
    
        $finish;
    end

    always @(posedge clk) begin
        if (cpu.LEDWriteEnable) begin
            $display("time=%0t PC=%h raw_display=%h", 
                     $time, cpu.PC, cpu.readdata2[15:0]);
        end
    end

endmodule