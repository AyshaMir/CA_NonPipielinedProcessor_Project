`timescale 1ns / 1ps

module fpgatop_taskC(
    input  wire clk,
    input  wire rst,
    input  wire [15:0] sw,
    output wire [6:0] seg,
    output wire [3:0] an,
    output wire [15:0] leds

);

    // CLOCK DIVIDER
    reg [27:0] counter = 28'd0;
    reg slow_clk = 1'b0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter  <= 28'd0;
            slow_clk <= 1'b0;
        end
        else begin
            if (counter == 28'd2_500_000) begin
                counter  <= 28'd0;
                slow_clk <= ~slow_clk;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
    end

    // CPU OUTPUT TO DISPLAY
    wire [15:0] cpu_out;
    wire [15:0] display_data;
    
    TopLevelProcessor #(
        .MEMFILE("factorial.mem")
    ) cpu (
        .clk(slow_clk),
        .rst(rst),
        .sw(sw),
        .leds(cpu_out) //result
    );
    
    //takes 16 bit top output and converts into deicmal display
    decimal_display dec_disp (
        .cpu_out(cpu_out),
        .display_data(display_data)
    );
    
    seven_seg ssd (
        .clk(clk),
        .data(display_data),
        .seg(seg),
        .an(an)
    );
    assign leds = cpu_out; //leds also get reuslt shown

endmodule