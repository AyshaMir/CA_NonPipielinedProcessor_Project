`timescale 1ns / 1ps

module fpgatop_taskB(
    input  wire clk,
    input  wire rst,
    input  wire [15:0] sw,
    output wire [6:0] seg,
    output wire [3:0] an,
    output reg  [15:0] leds
);

    reg [27:0] counter = 0;
    reg slow_clk = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter  <= 0;
            slow_clk <= 0;
        end else begin
            if (counter == 28'd99_999_999) begin
                counter  <= 0;
                slow_clk <= ~slow_clk;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    wire [15:0] cpu_leds;

    TopLevelProcessor #(
        .MEMFILE("temp_warning_test.mem")
    ) cpu (
        .clk(slow_clk),
        .rst(rst),
        .sw(sw),
        .leds(cpu_leds)
    );

    wire [4:0]  rd = cpu.rd;
    wire [31:0] wdata  = cpu.WriteData;
    wire regwrite = cpu.RegWrite;
    wire lui = cpu.Lui;

    reg [15:0] display_data;

    reg [3:0] rd_tens;
    reg [3:0] rd_ones;

    reg blt_flag;
    reg bge_flag;
    reg fail_flag;
    
    //5-bit register number into teo separate decimal digits for ex 25 split into 2 and 5 
    always @(*) begin
        if (rd >= 5'd20) begin
            rd_tens = 4'd2;
            rd_ones = rd - 5'd20;
        end
        else if (rd >= 5'd10) begin
            rd_tens = 4'd1;
            rd_ones = rd - 5'd10;
        end
        else begin
            rd_tens = 4'd0;
            rd_ones = rd[3:0];
        end
    end
    
    //If a LUI instruction writes to a register, show the lower 16 bits of wdata directly on seg and rest on leds
    //otherwise decimal of register and hex value of it 
    //leds map branhc, jup, jalr, if blt, bge wastaken and fail
    always @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            display_data <= 16'h0000;
            leds  <= 16'h0000;
            blt_flag <= 1'b0;
            bge_flag   <= 1'b0;
            fail_flag   <= 1'b0;
        end
        else begin
            if (regwrite && rd != 5'd0) begin
                if (lui) begin
                    display_data <= wdata[15:0];
                end
                else begin
                    display_data <= {
                        rd_tens,
                        rd_ones,
                        wdata[7:4],
                        wdata[3:0]
                    };
                end
            end

            if (regwrite && rd == 5'd10)
                blt_flag <= wdata[0];

            if (regwrite && rd == 5'd11)
                bge_flag <= wdata[0];

            if (regwrite && rd == 5'd12)
                fail_flag <= wdata[0];

            if (lui) begin
                leds <= wdata[31:16];
            end
            else begin
                leds <= {
                    10'b0,
                    fail_flag,
                    bge_flag,
                    blt_flag,
                    cpu.Jalr,
                    cpu.Jump,
                    cpu.Branch
                };
            end
        end
    end

    seven_seg ssd (
        .clk(clk),
        .data(display_data),
        .seg(seg),
        .an(an)
    );

endmodule