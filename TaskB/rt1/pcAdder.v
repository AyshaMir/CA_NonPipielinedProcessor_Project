module pcAdder(
    input  [31:0] PC,
    output [31:0] PC_add4
);
    assign PC_add4 = PC + 32'd4;
endmodule