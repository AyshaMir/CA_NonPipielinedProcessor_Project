`timescale 1ns / 1ps
module datamemory(
    input clk,
    input MemRead,
    input MemWrite,
    input [2:0] funct3,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
);

    reg [7:0] mem [0:511]; //512 slots each 1byte
    wire [8:0] addr = address[8:0];

    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: mem[addr] <= write_data[7:0]; // SB, writes lowest 8 bits of writedata inot mem

                3'b001: begin // SH, 16bits in 2 mem slots 
                    mem[addr]     <= write_data[7:0];
                    mem[addr + 1] <= write_data[15:8];
                end

                3'b010: begin // SW, 32 bits in 4 slots 
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
                3'b000: read_data = {{24{mem[addr][7]}}, mem[addr]}; // LB, reads 1 byte, sign extend to 32

                3'b001: read_data = {{16{mem[addr + 1][7]}},
                                     mem[addr + 1], mem[addr]}; // LH, reads 2Bs assemble and extend

                3'b010: read_data = {mem[addr + 3], mem[addr + 2],
                                     mem[addr + 1], mem[addr]}; // LW

                3'b100: read_data = {24'b0, mem[addr]}; // LBU, no sign extn, reads 1B

                3'b101: read_data = {16'b0, mem[addr + 1], mem[addr]}; // LHU, no sign extned reads 2B

                default: read_data = 32'b0;
            endcase
        end
        else begin
            read_data = 32'b0;
        end
    end

endmodule