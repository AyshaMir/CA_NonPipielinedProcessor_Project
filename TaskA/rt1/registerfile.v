`timescale 1ns / 1ps
module registerfile(
    input clk,
    input rst,
    input WriteEnable,
    input [4:0] rs1, rs2,
    input [4:0] rd,
    input [31:0] WriteData,
    output [31:0] readdata1,
    output [31:0] readdata2
);

reg [31:0] regs [31:0];
integer i;

// reset + write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] <= 32'b0;
    end
    else begin
        if (WriteEnable && rd != 5'b00000)
            regs[rd] <= WriteData;
        else
            regs[rd] <= regs[rd];
        regs[0] <= 32'b0;   // always force x0 = 0
    end
end

assign readdata1 = (rs1 == 5'b00000) ? 32'b0 : regs[rs1];
assign readdata2 = (rs2 == 5'b00000) ? 32'b0 : regs[rs2];

endmodule