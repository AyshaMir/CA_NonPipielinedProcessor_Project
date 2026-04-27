`timescale 1ns / 1ps
module datamemory(
    input clk,
    input rst,                  // kept for compatibility, not used
    input MemRead,
    input MemWrite,
    input [2:0] funct3,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);

    reg [7:0] mem [0:511];
    wire [8:0] addr = address[8:0];

    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: mem[addr] <= write_data[7:0]; // SB

                3'b001: begin // SH
                    mem[addr]     <= write_data[7:0];
                    mem[addr + 1] <= write_data[15:8];
                end

                3'b010: begin // SW
                    mem[addr]     <= write_data[7:0];
                    mem[addr + 1] <= write_data[15:8];
                    mem[addr + 2] <= write_data[23:16];
                    mem[addr + 3] <= write_data[31:24];
                end

                default: begin
                    // do nothing
                end
            endcase
        end
    end

    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b000: read_data = {{24{mem[addr][7]}}, mem[addr]}; // LB

                3'b001: read_data = {{16{mem[addr + 1][7]}},
                                     mem[addr + 1], mem[addr]}; // LH

                3'b010: read_data = {mem[addr + 3], mem[addr + 2],
                                     mem[addr + 1], mem[addr]}; // LW

                3'b100: read_data = {24'b0, mem[addr]}; // LBU

                3'b101: read_data = {16'b0, mem[addr + 1], mem[addr]}; // LHU

                default: read_data = 32'b0;
            endcase
        end
        else begin
            read_data = 32'b0;
        end
    end

endmodule