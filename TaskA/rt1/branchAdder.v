module branchAdder(
    input  [31:0] PC,
    input  [31:0] imm,
    output [31:0] branchTarget
);
    assign branchTarget = PC + imm;
endmodule