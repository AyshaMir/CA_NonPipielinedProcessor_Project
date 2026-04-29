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

    // INSTRUCTION FETCH
    //hold current add
    programCounter pc_reg (
        .clk(clk),
        .rst(rst),
        .PC_Next(PC_Next),
        .PC(PC)
    );
     // reads inst sititng at that add
    instructionMemory #(
        .MEMFILE(MEMFILE)
    ) imem (
        .instAddress(PC),
        .instruction(instruction)
    );
    
    //calc pc+4
    pcAdder pc_adder (
        .PC(PC),
        .PC_add4(PC_add4)
    );
    // add pc+imm to get jump ki destination
    branchAdder branch_adder (
        .PC(PC),
        .imm(Imm),
        .branchTarget(branchTarget)
    );

    // Branch type decode
    //flags for konsi branch inst hai
    assign branch_beq = (instruction[14:12] == 3'b000);
    assign branch_blt = (instruction[14:12] == 3'b100);
    assign branch_bge = (instruction[14:12] == 3'b101);

    // Final branch decision
    //checks flag and condition
    //beq, jump when rs1==rs2 blt whne < and bge whne >
    assign branch_taken =
        (branch_beq && (readdata1 == readdata2)) ||
        (branch_blt && ($signed(readdata1) <  $signed(readdata2))) ||
        (branch_bge && ($signed(readdata1) >= $signed(readdata2)));

    assign PCSrc = Branch & branch_taken; //if this 1 then pc goes to branch target not next line

    // jal or bracnhc taken, jump to pc+imm
    // jalr, jump to rs1+imm
    // else pc+4
    assign PC_Next = Jalr ? {ALUResult[31:1], 1'b0} :
                     ((Jump || PCSrc) ? branchTarget : PC_add4);

    // DECODE
    //loops at opcode and goves control signals
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
    
    //reads rs1 and rs2
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
    
    //extracts imm val based on inst
    immGen imm_gen (
        .instruction(instruction),
        .Imm(Imm)
    );

    // EXECUTE
    //figs out which alu op to run
    alu_control alu_ctrl (
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7_5(instruction[30]),
        .ALUControl(ALUControl)
    );
    
    //picks bw imm or rs2
    mux2 alu_mux (
        .in0(readdata2),
        .in1(Imm),
        .select(ALUSrc),
        .out(ALU_B)
    );
    
    //math calc
    alu alu_unit (
        .A(readdata1),
        .B(ALU_B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    // ADDRESS DECODING
    //checks alu result and decides, is it ram, leds, swicthes
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

    // MEMORY + I/O, only one hands back data as memreaddata
    //will act when decoder says so 
    datamemory dmem (
        .clk(clk),
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

    // WRITEBACK
    //picks final val, if lui use imm, if jalor jalr save pc+4, if load use mem data, else alureuslt
    //goe sback to reg file
    assign WriteData = Lui ? Imm :
                       ((Jump || Jalr) ? PC_add4 :
                       (MemtoReg ? MemReadData : ALUResult));

endmodule