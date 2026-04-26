`timescale 1ns / 1ps

module TopLevelProcessor #(
    parameter MEMFILE = ""
)(
    input  wire clk,
    input  wire rst,
    input  wire [15:0] sw,
    output wire [15:0] leds
);

    // Instruction Fetch
    wire [31:0] PC;
    wire [31:0] PC_Next;
    wire [31:0] PC_add4;
    wire [31:0] branchTarget;
    wire [31:0] instruction;

    // Decode
    wire [31:0] Imm;
    wire [31:0] readdata1;
    wire [31:0] readdata2;

    // Control Signals
    wire RegWrite;
    wire ALUSrc;
    wire MemRead;
    wire MemWrite;
    wire MemtoReg;
    wire Branch;
    wire Jump;
    wire Jalr;
    wire Lui;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    // Execute
    wire [31:0] ALU_B;
    wire [31:0] ALUResult;
    wire Zero;
    wire PCSrc;

    // Memory-mapped I/O select signals
    wire DataMemSelect;
    wire LEDSelect;
    wire SwitchSelect;

    // Memory control after decoding
    wire DataMemReadEnable;
    wire DataMemWriteEnable;
    wire LEDWriteEnable;
    wire SwitchReadEnable;

    // Memory outputs
    wire [31:0] DataMemOut;
    wire [31:0] SwitchOut;
    wire [31:0] LEDReadData;
    wire [31:0] MemReadData;

    // Debug register-number wires
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];

    // Branch debug / decision wires
    wire branch_beq;
    wire branch_blt;
    wire branch_bge;
    wire branch_taken;

    // Writeback
    wire [31:0] WriteData;

    // =========================
    // INSTRUCTION FETCH
    // =========================
    programCounter pc_reg (
        .clk(clk),
        .rst(rst),
        .PC_Next(PC_Next),
        .PC(PC)
    );

    instructionMemory #(
        .MEMFILE(MEMFILE)
    ) imem (
        .instAddress(PC),
        .instruction(instruction)
    );

    pcAdder pc_adder (
        .PC(PC),
        .PC_add4(PC_add4)
    );

    branchAdder branch_adder (
        .PC(PC),
        .imm(Imm),
        .branchTarget(branchTarget)
    );

    // Branch type decode
    assign branch_beq = (instruction[14:12] == 3'b000);
    assign branch_blt = (instruction[14:12] == 3'b100);
    assign branch_bge = (instruction[14:12] == 3'b101);

    // Final branch decision
    assign branch_taken =
        (branch_beq && (readdata1 == readdata2)) ||
        (branch_blt && ($signed(readdata1) <  $signed(readdata2))) ||
        (branch_bge && ($signed(readdata1) >= $signed(readdata2)));

    assign PCSrc = Branch & branch_taken;

    // jal  : PC = PC + imm
    // beq/blt/bge : PC = PC + imm when taken
    // jalr : PC = (rs1 + imm) & ~1
    assign PC_Next = Jalr ? {ALUResult[31:1], 1'b0} :
                     ((Jump || PCSrc) ? branchTarget : PC_add4);

    // =========================
    // DECODE
    // =========================
    main_control main_ctrl (
        .opcode(instruction[6:0]),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .Jump(Jump),
        .Jalr(Jalr),
        .Lui(Lui),
        .ALUOp(ALUOp)
    );

    registerfile regfile (
        .clk(clk),
        .rst(rst),
        .WriteEnable(RegWrite),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .WriteData(WriteData),
        .readdata1(readdata1),
        .readdata2(readdata2)
    );

    immGen imm_gen (
        .instruction(instruction),
        .Imm(Imm)
    );

    // =========================
    // EXECUTE
    // =========================
    alu_control alu_ctrl (
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7_5(instruction[30]),
        .ALUControl(ALUControl)
    );

    mux2 alu_mux (
        .in0(readdata2),
        .in1(Imm),
        .select(ALUSrc),
        .out(ALU_B)
    );

    alu alu_unit (
        .A(readdata1),
        .B(ALU_B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    // =========================
    // ADDRESS DECODING
    // =========================
    adressdecoder add_decoder (
        .address(ALUResult),
        .DataMemSelect(DataMemSelect),
        .LEDSelect(LEDSelect),
        .SwitchSelect(SwitchSelect)
    );

    assign DataMemReadEnable  = MemRead  & DataMemSelect;
    assign DataMemWriteEnable = MemWrite & DataMemSelect;
    assign LEDWriteEnable     = MemWrite & LEDSelect;
    assign SwitchReadEnable   = MemRead  & SwitchSelect;

    // =========================
    // MEMORY + I/O
    // =========================
    datamemory dmem (
        .clk(clk),
        .rst(rst),
        .MemRead(DataMemReadEnable),
        .MemWrite(DataMemWriteEnable),
        .funct3(instruction[14:12]),
        .address(ALUResult),
        .write_data(readdata2),
        .read_data(DataMemOut)
    );

    leds led_unit (
        .clk(clk),
        .rst(rst),
        .writeData(readdata2),
        .writeEnable(LEDWriteEnable),
        .readEnable(1'b0),
        .memAddress(ALUResult[31:2]),
        .readData(LEDReadData),
        .led_out(leds)
    );

    switches switch_unit (
        .clk(clk),
        .rst(rst),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(SwitchReadEnable),
        .memAddress(ALUResult[31:2]),
        .sw(sw),
        .readData(SwitchOut)
    );

    assign MemReadData =
        DataMemSelect ? DataMemOut :
        SwitchSelect  ? SwitchOut  :
        32'b0;

    // =========================
    // WRITEBACK
    // =========================
    assign WriteData = Lui ? Imm :
                       ((Jump || Jalr) ? PC_add4 :
                       (MemtoReg ? MemReadData : ALUResult));

endmodule