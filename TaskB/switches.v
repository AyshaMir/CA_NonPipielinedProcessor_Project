`timescale 1ns / 1ps
module switches(
    input clk,
    input rst,
    input [31:0] writeData,     // not used
    input writeEnable,          // not used
    input readEnable,
    input [29:0] memAddress,    // not used
    input [15:0] sw,
    output reg [31:0] readData
);

    always @(*) begin
        if (rst)
            readData = 32'b0;
        else if (readEnable)
            readData = {16'b0, sw};
        else
            readData = 32'b0;
    end

endmodule