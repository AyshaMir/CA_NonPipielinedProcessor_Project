module main_control(
    input  wire [6:0] opcode,
    output reg RegWrite,
    output reg ALUSrc,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg Branch,
    output reg Jump,
    output reg Jalr,
    output reg [1:0] ALUOp
);

    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_ITYPE  = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;

    always @(*) begin
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;
        Jump     = 1'b0;
        Jalr     = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)
            OP_RTYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b10;
            end

            OP_ITYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b11;
            end

            OP_LOAD: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUOp    = 2'b00;
            end

            OP_STORE: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end

            OP_BRANCH: begin
                Branch   = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = 2'b01;
            end

            OP_JAL: begin
                RegWrite = 1'b1;   // rd gets PC+4
                Jump     = 1'b1;
            end

            OP_JALR: begin
                RegWrite = 1'b1;   // rd gets PC+4
                Jalr     = 1'b1;
                ALUSrc   = 1'b1;   // rs1 + imm
                ALUOp    = 2'b00;  // use ADD in ALU
            end

            default: begin
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                Jump     = 1'b0;
                Jalr     = 1'b0;
                ALUOp    = 2'b00;
            end
        endcase
    end
endmodule