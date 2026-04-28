`timescale 1ns / 1ps

module fpgatop_taskA(
    input  wire clk,     
    input  wire rst,       
    input  wire [15:0] sw,  
    output wire [15:0] leds  
);

    reg [25:0] clk_div_counter = 26'd0;
    reg slow_clk = 1'b0;

    // 100 MHz -> 2 Hz
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div_counter <= 26'd0;
            slow_clk <= 1'b0;
        end
        else begin
            if (clk_div_counter == 26'd24_999_999) begin
                clk_div_counter <= 26'd0;
                slow_clk <= ~slow_clk;
            end
            else begin
                clk_div_counter <= clk_div_counter + 1'b1;
            end
        end
    end

    TopLevelProcessor #(
        .MEMFILE("countdown.mem")
    ) cpu (
        .clk(slow_clk),
        .rst(rst),
        .sw(sw),
        .leds(leds)
    );

endmodule