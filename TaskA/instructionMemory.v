module instructionMemory(
    input  [31:0] instAddress,
    output reg [31:0] instruction
);
    reg [7:0] memory [0:255];

    always @(*) begin
        instruction = {
            memory[instAddress + 3],
            memory[instAddress + 2],
            memory[instAddress + 1],
            memory[instAddress + 0]
        };
    end
endmodule